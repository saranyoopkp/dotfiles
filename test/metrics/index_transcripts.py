#!/usr/bin/env python3
"""Build an evidence-grade SQLite index for Claude Code JSONL transcripts."""

import argparse
import hashlib
import json
import os
import sqlite3
import sys
from pathlib import Path


HERE = Path(__file__).resolve().parent
DEFAULT_ROOT = Path.home() / ".claude" / "projects"
DEFAULT_DB = HERE / "data" / "retro-index.sqlite"
SCHEMA_VERSION = "1"
HUMAN_PROMPT_SOURCES = {"typed", "queued", "suggestion_accepted"}
RELATIONS = {
    "CONTINUE", "REFINE", "QUESTION", "PREREQUISITE", "NEW", "REPLACE",
    "DEFER", "RESUME", "CANCEL", "CORRECT", "AMBIGUOUS",
}
ALIGNMENTS = {"aligned", "misaligned", "unclear"}
CONFIDENCES = {"high", "medium", "low"}
COMMAND_TAGS = (
    "<command-name>",
    "<local-command-caveat>",
    "<local-command-stdout>",
    "<system-reminder>",
    "<command-message>",
    "<bash-input>",
    "<bash-stdout>",
    "[Request interrupted by user",
)


SCHEMA = """
PRAGMA foreign_keys = ON;
CREATE TABLE meta (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);
CREATE TABLE sources (
    id INTEGER PRIMARY KEY,
    path TEXT NOT NULL UNIQUE,
    project TEXT NOT NULL,
    file_session_id TEXT NOT NULL,
    size_bytes INTEGER NOT NULL,
    mtime_ns INTEGER NOT NULL,
    sha256 TEXT NOT NULL,
    total_lines INTEGER NOT NULL,
    blank_lines INTEGER NOT NULL,
    parsed_lines INTEGER NOT NULL,
    malformed_lines INTEGER NOT NULL,
    included INTEGER NOT NULL,
    exclusion_reason TEXT,
    status TEXT NOT NULL,
    error TEXT
);
CREATE TABLE records (
    id INTEGER PRIMARY KEY,
    source_id INTEGER NOT NULL REFERENCES sources(id) ON DELETE CASCADE,
    line_no INTEGER NOT NULL,
    byte_offset INTEGER NOT NULL,
    raw_sha256 TEXT NOT NULL,
    record_type TEXT,
    session_id TEXT,
    uuid TEXT,
    parent_uuid TEXT,
    logical_parent_uuid TEXT,
    timestamp TEXT,
    message_id TEXT,
    prompt_source TEXT,
    is_sidechain INTEGER NOT NULL,
    is_meta INTEGER NOT NULL,
    is_compact_summary INTEGER NOT NULL,
    normalized_kind TEXT NOT NULL,
    human_confidence TEXT,
    text TEXT,
    UNIQUE(source_id, line_no)
);
CREATE TABLE ingest_issues (
    id INTEGER PRIMARY KEY,
    source_id INTEGER NOT NULL REFERENCES sources(id) ON DELETE CASCADE,
    line_no INTEGER,
    byte_offset INTEGER,
    kind TEXT NOT NULL,
    raw_sha256 TEXT,
    error TEXT
);
CREATE TABLE content_blocks (
    id INTEGER PRIMARY KEY,
    record_id INTEGER NOT NULL REFERENCES records(id) ON DELETE CASCADE,
    ordinal INTEGER NOT NULL,
    kind TEXT NOT NULL,
    text TEXT,
    tool_name TEXT,
    tool_use_id TEXT,
    is_error INTEGER,
    UNIQUE(record_id, ordinal)
);
CREATE TABLE turns (
    id INTEGER PRIMARY KEY,
    source_id INTEGER NOT NULL REFERENCES sources(id) ON DELETE CASCADE,
    session_id TEXT NOT NULL,
    ordinal INTEGER NOT NULL,
    user_record_id INTEGER NOT NULL UNIQUE REFERENCES records(id) ON DELETE CASCADE,
    alignment_auditable INTEGER NOT NULL,
    branch_relation TEXT,
    human_confidence TEXT NOT NULL,
    user_text TEXT NOT NULL,
    assistant_text TEXT NOT NULL,
    tool_names TEXT NOT NULL,
    response_start_line INTEGER,
    response_end_line INTEGER,
    UNIQUE(source_id, ordinal)
);
CREATE TABLE audit_units (
    turn_id INTEGER PRIMARY KEY REFERENCES turns(id) ON DELETE CASCADE,
    input_sha256 TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    prompt_version TEXT,
    reviewer TEXT,
    relation TEXT,
    objective_before TEXT,
    objective_after TEXT,
    alignment TEXT,
    confidence TEXT,
    rationale TEXT,
    evidence_json TEXT
);
CREATE INDEX records_session_line ON records(session_id, source_id, line_no);
CREATE INDEX records_uuid ON records(uuid);
CREATE INDEX records_parent ON records(parent_uuid);
CREATE INDEX records_kind ON records(normalized_kind);
CREATE INDEX turns_session_ordinal ON turns(session_id, ordinal);
CREATE INDEX turns_auditable ON turns(alignment_auditable, human_confidence);
"""


def hash_bytes(raw):
    return hashlib.sha256(raw).hexdigest()


def source_policy(root, path):
    rel = path.relative_to(root)
    project = rel.parts[0] if rel.parts else "unknown"
    if "subagents" in rel.parts or path.name.startswith("agent-"):
        return project, "subagent"
    lower = project.lower()
    if ("temp" in lower or "routing-sandbox" in lower
            or lower.startswith("-private-tmp-") or lower.startswith("-private-var-")):
        return project, "temporary_or_harness"
    return project, None


def text_from_content(content):
    if isinstance(content, str):
        return content
    if not isinstance(content, list):
        return ""
    return "\n".join(
        block.get("text", "")
        for block in content
        if isinstance(block, dict) and block.get("type") == "text"
    )


def normalize_record(data):
    message = data.get("message") or {}
    content = message.get("content")
    record_type = data.get("type")
    is_sidechain = bool(data.get("isSidechain"))
    is_meta = bool(data.get("isMeta"))
    is_compact = bool(data.get("isCompactSummary"))
    prompt_source = data.get("promptSource")
    text = text_from_content(content).strip()
    blocks = content if isinstance(content, list) else []
    block_kinds = {
        block.get("type") for block in blocks if isinstance(block, dict)
    }
    confidence = None

    if record_type == "user":
        if "tool_result" in block_kinds:
            kind = "tool_result"
        elif is_sidechain:
            kind = "delegated_prompt"
        elif is_meta or prompt_source == "system":
            kind = "user_meta"
        elif is_compact:
            kind = "compact_summary"
        elif data.get("interruptedMessageId"):
            kind = "interruption_notice"
        elif text.startswith(COMMAND_TAGS):
            kind = "command_scaffold"
        elif text.startswith("Another Claude session sent a message:"):
            kind = "teammate_notification"
        elif text.startswith("/") and prompt_source is None:
            kind = "slash_command"
        elif prompt_source == "sdk":
            kind = "sdk_prompt"
        elif text and prompt_source in HUMAN_PROMPT_SOURCES:
            kind, confidence = "human_prompt", "strong"
        elif text and prompt_source is None:
            kind, confidence = "human_prompt", "fallback"
        elif text:
            kind, confidence = "ambiguous_user_input", "ambiguous"
        else:
            kind = "empty_user"
    elif record_type == "assistant":
        kind = "assistant_message"
    elif record_type == "system":
        kind = "system_event"
    else:
        kind = "event"

    return {
        "record_type": record_type,
        "session_id": data.get("sessionId"),
        "uuid": data.get("uuid"),
        "parent_uuid": data.get("parentUuid"),
        "logical_parent_uuid": data.get("logicalParentUuid"),
        "timestamp": data.get("timestamp"),
        "message_id": message.get("id"),
        "prompt_source": prompt_source,
        "is_sidechain": int(is_sidechain),
        "is_meta": int(is_meta),
        "is_compact_summary": int(is_compact),
        "normalized_kind": kind,
        "human_confidence": confidence,
        "text": text or None,
        "content": content,
    }


def insert_blocks(conn, record_id, normalized):
    content = normalized["content"]
    if not isinstance(content, list):
        return
    for ordinal, block in enumerate(content):
        if not isinstance(block, dict):
            conn.execute(
                "INSERT INTO content_blocks(record_id, ordinal, kind, text) VALUES(?,?,?,?)",
                (record_id, ordinal, "unknown", str(block)),
            )
            continue
        kind = str(block.get("type") or "unknown")
        text = block.get("text")
        tool_name = block.get("name") if kind == "tool_use" else None
        tool_use_id = block.get("id") if kind == "tool_use" else block.get("tool_use_id")
        is_error = block.get("is_error") if kind == "tool_result" else None
        conn.execute(
            """INSERT INTO content_blocks
               (record_id, ordinal, kind, text, tool_name, tool_use_id, is_error)
               VALUES(?,?,?,?,?,?,?)""",
            (record_id, ordinal, kind, text, tool_name, tool_use_id,
             None if is_error is None else int(bool(is_error))),
        )


def scan_source(conn, root, path):
    project, exclusion = source_policy(root, path)
    stat = path.stat()
    digest = hashlib.sha256()
    total = blank = parsed = malformed = 0
    sdk_cli_seen = False
    interactive_prompt_seen = False
    error = None
    status = "excluded" if exclusion else "indexed"
    cur = conn.execute(
        """INSERT INTO sources
           (path, project, file_session_id, size_bytes, mtime_ns, sha256,
            total_lines, blank_lines, parsed_lines, malformed_lines,
            included, exclusion_reason, status, error)
           VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)""",
        (str(path), project, path.stem, stat.st_size, stat.st_mtime_ns, "pending",
         0, 0, 0, 0, int(exclusion is None), exclusion, "indexing", None),
    )
    source_id = cur.lastrowid
    try:
        with path.open("rb") as stream:
            offset = 0
            for line_no, raw in enumerate(stream, 1):
                total += 1
                digest.update(raw)
                if not raw.strip():
                    blank += 1
                    offset += len(raw)
                    continue
                if exclusion:
                    offset += len(raw)
                    continue
                try:
                    data = json.loads(raw)
                except (json.JSONDecodeError, UnicodeDecodeError) as exc:
                    malformed += 1
                    conn.execute(
                        """INSERT INTO ingest_issues
                           (source_id, line_no, byte_offset, kind, raw_sha256, error)
                           VALUES(?,?,?,?,?,?)""",
                        (source_id, line_no, offset, "malformed_json", hash_bytes(raw), str(exc)),
                    )
                    offset += len(raw)
                    continue
                if not isinstance(data, dict):
                    malformed += 1
                    conn.execute(
                        """INSERT INTO ingest_issues
                           (source_id, line_no, byte_offset, kind, raw_sha256, error)
                           VALUES(?,?,?,?,?,?)""",
                        (source_id, line_no, offset, "unsupported_json_shape", hash_bytes(raw),
                         f"top-level {type(data).__name__}"),
                    )
                    offset += len(raw)
                    continue
                parsed += 1
                if data.get("entrypoint") == "sdk-cli":
                    sdk_cli_seen = True
                normalized = normalize_record(data)
                if normalized["normalized_kind"] == "human_prompt":
                    interactive_prompt_seen = True
                cur = conn.execute(
                    """INSERT INTO records
                       (source_id, line_no, byte_offset, raw_sha256, record_type, session_id,
                        uuid, parent_uuid, logical_parent_uuid, timestamp, message_id,
                        prompt_source, is_sidechain, is_meta, is_compact_summary,
                        normalized_kind, human_confidence, text)
                       VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)""",
                    (
                        source_id, line_no, offset, hash_bytes(raw), normalized["record_type"],
                        normalized["session_id"] or path.stem, normalized["uuid"],
                        normalized["parent_uuid"], normalized["logical_parent_uuid"],
                        normalized["timestamp"], normalized["message_id"],
                        normalized["prompt_source"], normalized["is_sidechain"],
                        normalized["is_meta"], normalized["is_compact_summary"],
                        normalized["normalized_kind"], normalized["human_confidence"],
                        normalized["text"],
                    ),
                )
                insert_blocks(conn, cur.lastrowid, normalized)
                offset += len(raw)
    except OSError as exc:
        status, error = "failed", str(exc)

    if not exclusion and sdk_cli_seen and not interactive_prompt_seen:
        exclusion, status = "sdk_or_print_session", "excluded"
        conn.execute("DELETE FROM records WHERE source_id=?", (source_id,))
        conn.execute("DELETE FROM ingest_issues WHERE source_id=?", (source_id,))
        parsed = malformed = 0

    conn.execute(
        """UPDATE sources SET sha256=?, total_lines=?, blank_lines=?, parsed_lines=?,
           malformed_lines=?, included=?, exclusion_reason=?, status=?, error=? WHERE id=?""",
        (digest.hexdigest(), total, blank, parsed, malformed, int(exclusion is None),
         exclusion, status, error, source_id),
    )
    return source_id


def build_turns(conn, source_id):
    source_path = conn.execute("SELECT path FROM sources WHERE id=?", (source_id,)).fetchone()[0]
    prompts = conn.execute(
        """SELECT id, line_no, session_id, parent_uuid, human_confidence, text,
                  raw_sha256, uuid
           FROM records WHERE source_id=? AND normalized_kind='human_prompt'
           ORDER BY line_no""",
        (source_id,),
    ).fetchall()
    if not prompts:
        return

    siblings_by_parent = {}
    for prompt in prompts:
        parent = prompt[3]
        if parent:
            siblings_by_parent.setdefault(parent, []).append(prompt[0])

    all_prompt_lines = [prompt[1] for prompt in prompts]
    for ordinal, prompt in enumerate(prompts):
        (record_id, line_no, session_id, parent_uuid, confidence, user_text,
         user_raw_sha256, user_uuid) = prompt
        siblings = siblings_by_parent.get(parent_uuid, []) if parent_uuid else []
        next_line = all_prompt_lines[ordinal + 1] if ordinal + 1 < len(all_prompt_lines) else None
        params = [source_id, line_no]
        upper = ""
        if next_line is not None:
            upper = " AND r.line_no < ?"
            params.append(next_line)
        assistant_rows = conn.execute(
            """SELECT r.line_no, r.text, r.raw_sha256 FROM records r
               WHERE r.source_id=? AND r.line_no>? AND r.normalized_kind='assistant_message'"""
            + upper + " ORDER BY r.line_no",
            params,
        ).fetchall()
        tool_rows = conn.execute(
            """SELECT r.line_no, b.tool_name, r.raw_sha256 FROM records r
               JOIN content_blocks b ON b.record_id=r.id
               WHERE r.source_id=? AND r.line_no>? AND b.kind='tool_use'"""
            + upper + " ORDER BY r.line_no, b.ordinal",
            params,
        ).fetchall()
        assistant_text = "\n".join(row[1] for row in assistant_rows if row[1])
        tool_names = [row[1] for row in tool_rows if row[1]]
        response_lines = [row[0] for row in assistant_rows] + [row[0] for row in tool_rows]
        branch_relation = None
        if len(siblings) > 1:
            disposition = "executed_branch" if response_lines else "unanswered_edit"
            branch_relation = f"{disposition}:{siblings.index(record_id) + 1}/{len(siblings)}"
        alignment_auditable = not branch_relation or not branch_relation.startswith("unanswered_edit:")
        cur = conn.execute(
            """INSERT INTO turns
               (source_id, session_id, ordinal, user_record_id, alignment_auditable,
                branch_relation,
                human_confidence, user_text, assistant_text, tool_names,
                response_start_line, response_end_line)
               VALUES(?,?,?,?,?,?,?,?,?,?,?,?)""",
            (source_id, session_id, ordinal, record_id, int(alignment_auditable), branch_relation,
             confidence, user_text, assistant_text,
             json.dumps(tool_names, ensure_ascii=False),
             min(response_lines) if response_lines else None,
             max(response_lines) if response_lines else None),
        )
        payload = json.dumps(
            {"source_file": source_path, "line_no": line_no, "uuid": user_uuid,
             "parent_uuid": parent_uuid, "user_raw_sha256": user_raw_sha256,
             "branch_relation": branch_relation, "user": user_text,
             "assistant": assistant_text, "tools": tool_names,
             "response_lines": response_lines,
             "response_raw_sha256": [row[2] for row in assistant_rows + tool_rows]},
            ensure_ascii=False,
            sort_keys=True,
        ).encode("utf-8")
        conn.execute(
            "INSERT INTO audit_units(turn_id, input_sha256, status) VALUES(?,?,?)",
            (cur.lastrowid, hash_bytes(payload), "pending" if alignment_auditable else "input_only"),
        )


def create_index(root, db, report=True):
    root = root.expanduser().resolve()
    db = db.expanduser().resolve()
    db.parent.mkdir(parents=True, exist_ok=True)
    temp_db = db.with_name(db.name + ".tmp")
    if temp_db.exists():
        temp_db.unlink()
    conn = sqlite3.connect(temp_db)
    try:
        conn.executescript(SCHEMA)
        conn.execute("INSERT INTO meta(key, value) VALUES('schema_version', ?)", (SCHEMA_VERSION,))
        conn.execute("INSERT INTO meta(key, value) VALUES('source_root', ?)", (str(root),))
        files = sorted(root.rglob("*.jsonl"))
        for index, path in enumerate(files, 1):
            source_id = scan_source(conn, root, path)
            row = conn.execute("SELECT included, status FROM sources WHERE id=?", (source_id,)).fetchone()
            if row == (1, "indexed"):
                build_turns(conn, source_id)
            if index % 50 == 0:
                print(f"indexed {index}/{len(files)} files", file=sys.stderr)
        conn.commit()
    finally:
        conn.close()
    os.replace(temp_db, db)
    if report:
        print_status(db)


def scalar(conn, sql, params=()):
    return conn.execute(sql, params).fetchone()[0]


def status_values(db):
    conn = sqlite3.connect(db)
    try:
        return {
            "files_discovered": scalar(conn, "SELECT count(*) FROM sources"),
            "files_indexed": scalar(conn, "SELECT count(*) FROM sources WHERE status='indexed'"),
            "files_excluded": scalar(conn, "SELECT count(*) FROM sources WHERE status='excluded'"),
            "files_failed": scalar(conn, "SELECT count(*) FROM sources WHERE status='failed'"),
            "physical_lines": scalar(conn, "SELECT coalesce(sum(total_lines),0) FROM sources"),
            "indexed_lines": scalar(conn, "SELECT coalesce(sum(total_lines),0) FROM sources WHERE status='indexed'"),
            "parsed_lines": scalar(conn, "SELECT coalesce(sum(parsed_lines),0) FROM sources WHERE status='indexed'"),
            "malformed_lines": scalar(conn, "SELECT coalesce(sum(malformed_lines),0) FROM sources WHERE status='indexed'"),
            "blank_lines": scalar(conn, "SELECT coalesce(sum(blank_lines),0) FROM sources WHERE status='indexed'"),
            "human_prompts": scalar(conn, "SELECT count(*) FROM records WHERE normalized_kind='human_prompt'"),
            "fallback_human_prompts": scalar(conn, "SELECT count(*) FROM records WHERE normalized_kind='human_prompt' AND human_confidence='fallback'"),
            "ambiguous_user_inputs": scalar(conn, "SELECT count(*) FROM records WHERE normalized_kind='ambiguous_user_input'"),
            "user_records": scalar(conn, "SELECT count(*) FROM records WHERE record_type='user'"),
            "nonhuman_user_records": scalar(conn, "SELECT count(*) FROM records WHERE record_type='user' AND normalized_kind NOT IN ('human_prompt','ambiguous_user_input')"),
            "auditable_inputs": scalar(conn, "SELECT count(*) FROM turns"),
            "alignment_auditable_turns": scalar(conn, "SELECT count(*) FROM turns WHERE alignment_auditable=1"),
            "branch_candidate_turns": scalar(conn, "SELECT count(*) FROM turns WHERE branch_relation IS NOT NULL"),
            "audit_pending": scalar(conn, "SELECT count(*) FROM audit_units WHERE status='pending'"),
            "audit_classified": scalar(conn, "SELECT count(*) FROM audit_units WHERE status='classified'"),
            "audit_ambiguous": scalar(conn, "SELECT count(*) FROM audit_units WHERE status='ambiguous'"),
            "audit_failed": scalar(conn, "SELECT count(*) FROM audit_units WHERE status='failed'"),
            "audit_input_only": scalar(conn, "SELECT count(*) FROM audit_units WHERE status='input_only'"),
        }
    finally:
        conn.close()


def print_status(db, as_json=False):
    values = status_values(db)
    if as_json:
        print(json.dumps(values, ensure_ascii=False, indent=2))
        return
    width = max(len(key) for key in values)
    for key, value in values.items():
        print(f"{key:<{width}}  {value}")
    reconciled = (
        values["files_discovered"]
        == values["files_indexed"] + values["files_excluded"] + values["files_failed"]
    )
    lines_reconciled = (
        values["indexed_lines"]
        == values["parsed_lines"] + values["malformed_lines"] + values["blank_lines"]
    )
    user_reconciled = values["user_records"] == (
        values["human_prompts"] + values["ambiguous_user_inputs"]
        + values["nonhuman_user_records"]
    )
    queue_reconciled = values["auditable_inputs"] == (
        values["audit_pending"] + values["audit_classified"]
        + values["audit_ambiguous"] + values["audit_failed"] + values["audit_input_only"]
    )
    print(f"source_reconciliation       {'PASS' if reconciled else 'FAIL'}")
    print(f"line_reconciliation         {'PASS' if lines_reconciled else 'FAIL'}")
    print(f"user_record_reconciliation  {'PASS' if user_reconciled else 'FAIL'}")
    print(f"audit_queue_reconciliation  {'PASS' if queue_reconciled else 'FAIL'}")


def search(db, query, limit):
    conn = sqlite3.connect(db)
    conn.row_factory = sqlite3.Row
    try:
        rows = conn.execute(
            """SELECT t.session_id, t.ordinal, r.timestamp, s.project, s.path, r.line_no,
                      t.user_text, t.assistant_text
               FROM turns t JOIN records r ON r.id=t.user_record_id
               JOIN sources s ON s.id=t.source_id
               WHERE instr(t.user_text, ?) > 0 OR instr(t.assistant_text, ?) > 0
               ORDER BY r.timestamp, s.path, r.line_no LIMIT ?""",
            (query, query, limit),
        ).fetchall()
        for row in rows:
            print(json.dumps(dict(row), ensure_ascii=False))
    finally:
        conn.close()


def context(db, session_id, ordinal, radius):
    conn = sqlite3.connect(db)
    conn.row_factory = sqlite3.Row
    try:
        rows = conn.execute(
            """SELECT t.session_id, t.ordinal, r.uuid, r.timestamp, s.path, r.line_no,
                      t.human_confidence, t.user_text, t.assistant_text, t.tool_names
               FROM turns t JOIN records r ON r.id=t.user_record_id
               JOIN sources s ON s.id=t.source_id
               WHERE t.session_id=? AND t.ordinal BETWEEN ? AND ?
               ORDER BY t.ordinal""",
            (session_id, max(0, ordinal - radius), ordinal + radius),
        ).fetchall()
        for row in rows:
            print(json.dumps(dict(row), ensure_ascii=False))
    finally:
        conn.close()


def export_sessions(db, output, sessions=None, project=None, since=None):
    conn = sqlite3.connect(db)
    conn.row_factory = sqlite3.Row
    clauses = ["1=1"]
    params = []
    if sessions:
        clauses.append("t.session_id IN (%s)" % ",".join("?" for _ in sessions))
        params.extend(sessions)
    if project:
        clauses.append("s.project=?")
        params.append(project)
    if since:
        clauses.append("r.timestamp>=?")
        params.append(since)
    selected = [row[0] for row in conn.execute(
        """SELECT DISTINCT t.session_id FROM turns t
           JOIN records r ON r.id=t.user_record_id
           JOIN sources s ON s.id=t.source_id WHERE """ + " AND ".join(clauses),
        params,
    )]
    if not selected:
        rows = []
    else:
        placeholders = ",".join("?" for _ in selected)
        rows = conn.execute(
            """SELECT t.id AS turn_id, t.session_id, t.ordinal, t.alignment_auditable,
                      t.branch_relation,
                      r.uuid, r.parent_uuid,
                      r.timestamp, s.project, s.path, r.line_no, t.human_confidence,
                      t.user_text, t.assistant_text, t.tool_names, a.input_sha256
               FROM turns t JOIN records r ON r.id=t.user_record_id
               JOIN sources s ON s.id=t.source_id
               JOIN audit_units a ON a.turn_id=t.id
               WHERE t.session_id IN (""" + placeholders
            + ") ORDER BY t.session_id, s.path, t.ordinal",
            selected,
        ).fetchall()
    grouped = {}
    for row in rows:
        session = grouped.setdefault(row["session_id"], {
            "session_id": row["session_id"],
            "project": row["project"],
            "source_files": [],
            "turns": [],
        })
        if row["path"] not in session["source_files"]:
            session["source_files"].append(row["path"])
        session["turns"].append({
            "turn_id": row["turn_id"],
            "ordinal": row["ordinal"],
            "alignment_auditable": bool(row["alignment_auditable"]),
            "branch_relation": row["branch_relation"],
            "uuid": row["uuid"],
            "parent_uuid": row["parent_uuid"],
            "timestamp": row["timestamp"],
            "source_file": row["path"],
            "source_line": row["line_no"],
            "human_confidence": row["human_confidence"],
            "user": row["user_text"],
            "assistant": row["assistant_text"],
            "tools": json.loads(row["tool_names"]),
            "input_sha256": row["input_sha256"],
        })
    for session in grouped.values():
        session["expected_turn_count"] = len(session["turns"])
        session["expected_review_count"] = sum(
            turn["alignment_auditable"] for turn in session["turns"]
        )
    conn.close()
    output = output.expanduser().resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("w", encoding="utf-8") as stream:
        for session in grouped.values():
            stream.write(json.dumps(session, ensure_ascii=False) + "\n")
    print(f"exported {len(rows)} turns in {len(grouped)} session envelopes -> {output}")


def import_results(db, input_path, reviewer, prompt_version):
    results = [json.loads(line) for line in input_path.expanduser().read_text(encoding="utf-8").splitlines()
               if line.strip()]
    conn = sqlite3.connect(db)
    try:
        with conn:
            for session in results:
                session_id = session.get("session_id")
                expected = dict(conn.execute(
                    """SELECT t.id, a.input_sha256 FROM turns t
                       JOIN audit_units a ON a.turn_id=t.id
                       WHERE t.alignment_auditable=1 AND t.session_id=?""",
                    (session_id,),
                ))
                if not expected:
                    raise ValueError(f"{session_id}: session has no auditable turns")
                supplied = session.get("turns") or []
                supplied_ids = [turn.get("turn_id") for turn in supplied]
                if len(supplied_ids) != len(set(supplied_ids)):
                    raise ValueError(f"{session_id}: duplicate turn_id in results")
                if set(supplied_ids) != set(expected):
                    missing = sorted(set(expected) - set(supplied_ids))
                    extra = sorted(set(supplied_ids) - set(expected))
                    raise ValueError(f"{session_id}: incomplete result missing={missing} extra={extra}")
                for turn in supplied:
                    turn_id = turn["turn_id"]
                    if turn.get("input_sha256") != expected[turn_id]:
                        raise ValueError(f"{session_id}: stale input hash for turn {turn_id}")
                    relation = turn.get("relation")
                    alignment = turn.get("alignment")
                    confidence = turn.get("confidence")
                    objective_before = turn.get("objective_before")
                    objective_after = turn.get("objective_after")
                    rationale = turn.get("rationale")
                    if relation not in RELATIONS:
                        raise ValueError(f"{session_id}: invalid relation {relation!r}")
                    if alignment not in ALIGNMENTS:
                        raise ValueError(f"{session_id}: invalid alignment {alignment!r}")
                    if confidence not in CONFIDENCES:
                        raise ValueError(f"{session_id}: invalid confidence {confidence!r}")
                    if (not isinstance(objective_before, list)
                            or not all(isinstance(item, str) for item in objective_before)):
                        raise ValueError(f"{session_id}: objective_before must be a string list")
                    if (not isinstance(objective_after, list)
                            or not all(isinstance(item, str) for item in objective_after)):
                        raise ValueError(f"{session_id}: objective_after must be a string list")
                    if not isinstance(rationale, str) or not rationale.strip():
                        raise ValueError(f"{session_id}: rationale is required")
                    evidence = turn.get("evidence") or []
                    if not evidence:
                        raise ValueError(f"{session_id}: turn {turn_id} has no evidence")
                    for item in evidence:
                        source_file = item.get("source_file")
                        source_line = item.get("source_line")
                        evidence_uuid = item.get("uuid")
                        found = conn.execute(
                            """SELECT r.uuid FROM records r JOIN sources s ON s.id=r.source_id
                               WHERE s.path=? AND r.line_no=?""",
                            (source_file, source_line),
                        ).fetchone()
                        if not found or (evidence_uuid and found[0] != evidence_uuid):
                            raise ValueError(
                                f"{session_id}: invalid evidence for turn {turn_id}: "
                                f"{source_file}:{source_line}"
                            )
                    status = "ambiguous" if relation == "AMBIGUOUS" or alignment == "unclear" else "classified"
                    conn.execute(
                        """UPDATE audit_units SET status=?, prompt_version=?, reviewer=?, relation=?,
                           objective_before=?, objective_after=?, alignment=?, confidence=?, rationale=?,
                           evidence_json=? WHERE turn_id=?""",
                        (status, prompt_version, reviewer, relation,
                         json.dumps(objective_before, ensure_ascii=False),
                         json.dumps(objective_after, ensure_ascii=False),
                         alignment, confidence, rationale,
                         json.dumps(evidence, ensure_ascii=False), turn_id),
                    )
    finally:
        conn.close()
    print(f"imported {sum(len(session.get('turns') or []) for session in results)} reviewed turns")


def main():
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)
    index_cmd = sub.add_parser("index")
    index_cmd.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    index_cmd.add_argument("--db", type=Path, default=DEFAULT_DB)
    status_cmd = sub.add_parser("status")
    status_cmd.add_argument("--db", type=Path, default=DEFAULT_DB)
    status_cmd.add_argument("--json", action="store_true")
    search_cmd = sub.add_parser("search")
    search_cmd.add_argument("query")
    search_cmd.add_argument("--db", type=Path, default=DEFAULT_DB)
    search_cmd.add_argument("--limit", type=int, default=20)
    context_cmd = sub.add_parser("context")
    context_cmd.add_argument("session_id")
    context_cmd.add_argument("ordinal", type=int)
    context_cmd.add_argument("--radius", type=int, default=2)
    context_cmd.add_argument("--db", type=Path, default=DEFAULT_DB)
    export_cmd = sub.add_parser("export")
    export_cmd.add_argument("--db", type=Path, default=DEFAULT_DB)
    export_cmd.add_argument("--output", type=Path,
                            default=HERE / "data" / "objective-audit-queue.jsonl")
    export_cmd.add_argument("--session", action="append", dest="sessions")
    export_cmd.add_argument("--project")
    export_cmd.add_argument("--since")
    import_cmd = sub.add_parser("import")
    import_cmd.add_argument("input", type=Path)
    import_cmd.add_argument("--db", type=Path, default=DEFAULT_DB)
    import_cmd.add_argument("--reviewer", required=True)
    import_cmd.add_argument("--prompt-version", required=True)
    args = parser.parse_args()

    if args.command == "index":
        create_index(args.root, args.db)
    elif args.command == "status":
        print_status(args.db, args.json)
    elif args.command == "search":
        search(args.db, args.query, args.limit)
    elif args.command == "context":
        context(args.db, args.session_id, args.ordinal, args.radius)
    elif args.command == "export":
        export_sessions(args.db, args.output, args.sessions, args.project, args.since)
    elif args.command == "import":
        import_results(args.db, args.input, args.reviewer, args.prompt_version)


if __name__ == "__main__":
    main()
