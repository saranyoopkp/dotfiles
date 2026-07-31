#!/usr/bin/env python3
"""Build a deterministic semantic-audit pilot manifest without calling a model."""

import argparse
import collections
import hashlib
import itertools
import json
import math
import re
import sqlite3
from pathlib import Path


HERE = Path(__file__).resolve().parent
DEFAULT_DB = HERE / "data" / "retro-index.sqlite"
DEFAULT_OUTPUT = HERE / "data" / "audit-plan.json"

CORRECTION_RE = re.compile(
    r"ไม่ใช่|หมายถึง|กลับมา|ผมไม่ได้|เดี๋ยวก่อน|not what|i meant|go back|instead",
    re.IGNORECASE,
)
OBJECTIVE_RE = re.compile(
    r"พัก|ไว้ก่อน|ทำ.{0,30}ก่อน|ต่อจาก|กลับไป|resume|defer|cancel|replace",
    re.IGNORECASE,
)
RISK_RE = re.compile(
    r"destroy|delete|drop|terraform|production|prod\b|commit|push|deploy|secret|credential|"
    r"ลบ|ทำลาย|โปรดักชัน|รหัสผ่าน",
    re.IGNORECASE,
)
MUTATION_TOOLS = {"Bash", "Edit", "Write", "NotebookEdit"}


def size_bucket(count):
    if count <= 5:
        return "small"
    if count <= 20:
        return "medium"
    if count <= 60:
        return "long"
    return "very_long"


def risk_tags(row):
    text = f"{row['user_text']}\n{row['assistant_text']}"
    tools = set(json.loads(row["tool_names"]))
    tags = []
    if CORRECTION_RE.search(row["user_text"]):
        tags.append("correction_signal")
    if OBJECTIVE_RE.search(row["user_text"]):
        tags.append("objective_control_signal")
    if RISK_RE.search(text):
        tags.append("risk_language")
    if "?" in row["user_text"] or "ไหม" in row["user_text"] or "หรือเปล่า" in row["user_text"]:
        if tools & MUTATION_TOOLS:
            tags.append("question_with_mutation_tools")
    if len(row["assistant_text"]) > max(2000, 8 * max(1, len(row["user_text"]))):
        tags.append("response_expansion")
    if row["branch_relation"]:
        tags.append("executed_branch")
    if row["human_confidence"] == "fallback":
        tags.append("legacy_fallback")
    return tags


def load_rows(db):
    conn = sqlite3.connect(db)
    conn.row_factory = sqlite3.Row
    rows = conn.execute(
        """SELECT t.id AS turn_id, t.session_id, t.ordinal, t.branch_relation,
                  t.human_confidence, t.user_text, t.assistant_text, t.tool_names,
                  t.alignment_auditable, a.input_sha256, a.status,
                  r.uuid, r.timestamp, r.line_no,
                  s.path AS source_file, s.project,
                  sc.session_turn_count
           FROM turns t
           JOIN audit_units a ON a.turn_id=t.id
           JOIN records r ON r.id=t.user_record_id
           JOIN sources s ON s.id=t.source_id
           JOIN (SELECT session_id, count(*) AS session_turn_count
                 FROM turns WHERE alignment_auditable=1 GROUP BY session_id) sc
             ON sc.session_id=t.session_id
           ORDER BY s.path, t.ordinal"""
    ).fetchall()
    conn.close()
    return [dict(row) for row in rows]


def row_stratum(row):
    branch = "executed_branch" if row["branch_relation"] else "linear"
    risk = "signaled" if row["risk_tags"] else "unflagged"
    return "|".join((row["project"], branch, row["human_confidence"],
                     size_bucket(row["session_turn_count"]), risk))


def stable_rank(rows, seed, namespace):
    def key(row):
        payload = f"{seed}:{namespace}:{row['input_sha256']}:{row['turn_id']}".encode("utf-8")
        return hashlib.sha256(payload).hexdigest()
    return sorted(rows, key=key)


def stable_sample(rows, count, seed, namespace="random_holdout"):
    return stable_rank(rows, seed, namespace)[:count]


def select_plan(rows, known_sessions, random_size, edge_size, seed):
    by_id = {row["turn_id"]: row for row in rows}
    reasons = collections.defaultdict(set)
    known_available = set()
    for row in rows:
        row["risk_tags"] = risk_tags(row)
        row["stratum"] = row_stratum(row)
        if row["session_id"] in known_sessions:
            reasons[row["turn_id"]].add("known_benchmark")
            known_available.add(row["session_id"])
        if row["human_confidence"] == "fallback":
            reasons[row["turn_id"]].add("legacy_fallback")

    non_known = [row for row in rows if row["session_id"] not in known_sessions]
    for row in stable_sample(non_known, min(random_size, len(non_known)), seed):
        reasons[row["turn_id"]].add("random_holdout")

    strata = collections.defaultdict(list)
    for row in non_known:
        strata[row["stratum"]].append(row)
    stratum_keys = sorted(
        strata,
        key=lambda key: hashlib.sha256(f"{seed}:stratum:{key}".encode("utf-8")).hexdigest(),
    )
    edge_added = 0
    for key in stratum_keys:
        if edge_size is not None and edge_added >= edge_size:
            break
        candidates = stable_rank(strata[key], seed, f"edge:{key}")
        chosen = next((row for row in candidates if not reasons[row["turn_id"]]), None)
        if chosen is None:
            continue
        reasons[chosen["turn_id"]].add("stratum_edge")
        edge_added += 1

    selected = []
    for turn_id in sorted(reasons):
        row = by_id[turn_id]
        selected.append({
            "turn_id": turn_id,
            "session_id": row["session_id"],
            "ordinal": row["ordinal"],
            "project": row["project"],
            "timestamp": row["timestamp"],
            "source_file": row["source_file"],
            "source_line": row["line_no"],
            "uuid": row["uuid"],
            "input_sha256": row["input_sha256"],
            "branch_relation": row["branch_relation"],
            "human_confidence": row["human_confidence"],
            "session_size": size_bucket(row["session_turn_count"]),
            "risk_tags": row["risk_tags"],
            "stratum": row["stratum"],
            "selection_reasons": sorted(reasons[turn_id]),
            "content_chars": len(row["user_text"]) + len(row["assistant_text"])
                             + len(row["tool_names"]),
            "content_utf8_bytes": len(row["user_text"].encode("utf-8"))
                                  + len(row["assistant_text"].encode("utf-8"))
                                  + len(row["tool_names"].encode("utf-8")),
        })
    return selected, sorted(known_sessions - known_available)


def content_size(rows):
    chars = sum(len(row["user_text"]) + len(row["assistant_text"])
                + len(row["tool_names"]) for row in rows)
    utf8_bytes = sum(len(row["user_text"].encode("utf-8"))
                     + len(row["assistant_text"].encode("utf-8"))
                     + len(row["tool_names"].encode("utf-8")) for row in rows)
    return {"chars": chars, "utf8_bytes": utf8_bytes}


def token_proxy(size):
    return {
        "heuristic_low": math.ceil(size["chars"] / 4),
        "heuristic_high": math.ceil(size["utf8_bytes"] / 2),
        "note": ("non-bounding planning heuristic, not a model tokenizer; prompt, metadata, "
                 "retries, reviewers, and duplication beyond this surface are excluded"),
    }


def bounded_context_sizes(rows, selected_ids, context_turns):
    by_session = collections.defaultdict(list)
    for row in rows:
        by_session[row["session_id"]].append(row)
    repeated_rows = []
    unique_ids = set()
    for session_rows in by_session.values():
        session_rows.sort(key=lambda row: row["ordinal"])
        for index, row in enumerate(session_rows):
            if row["turn_id"] not in selected_ids:
                continue
            window = session_rows[max(0, index - context_turns):index + 1]
            repeated_rows.extend(window)
            unique_ids.update(item["turn_id"] for item in window)
    unique_rows = [row for row in rows if row["turn_id"] in unique_ids]
    return content_size(unique_rows), content_size(repeated_rows), len(unique_ids)


def objective_spine_size(db, selected_rows, selected_sessions):
    if not selected_sessions:
        return {"chars": 0, "utf8_bytes": 0}
    conn = sqlite3.connect(db)
    placeholders = ",".join("?" for _ in selected_sessions)
    user_texts = [row[0] for row in conn.execute(
        f"SELECT user_text FROM turns WHERE session_id IN ({placeholders})",
        sorted(selected_sessions),
    )]
    conn.close()
    selected_responses = [
        f"{row['assistant_text']}{row['tool_names']}" for row in selected_rows
    ]
    texts = user_texts + selected_responses
    return {
        "chars": sum(len(text) for text in texts),
        "utf8_bytes": sum(len(text.encode("utf-8")) for text in texts),
    }


def database_snapshot_hash(db):
    conn = sqlite3.connect(db)
    rows = conn.execute("SELECT path, sha256, status FROM sources ORDER BY path").fetchall()
    schema_version = conn.execute(
        "SELECT value FROM meta WHERE key='schema_version'"
    ).fetchone()
    conn.close()
    payload = json.dumps(
        {"schema_version": schema_version[0] if schema_version else None, "sources": rows},
        ensure_ascii=False,
        separators=(",", ":"),
    ).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def build_plan(db, known_sessions, random_size, edge_size, seed, expected_output_tokens,
               context_turns=6, max_planned_input_chars=None):
    all_rows = load_rows(db)
    target_rows = [
        row for row in all_rows if row["alignment_auditable"] == 1 and row["status"] == "pending"
    ]
    corpus_rows = [row for row in all_rows if row["alignment_auditable"] == 1]
    selected, missing_known = select_plan(
        target_rows, set(known_sessions), random_size, edge_size, seed
    )
    selected_ids = {item["turn_id"] for item in selected}
    selected_rows = [row for row in target_rows if row["turn_id"] in selected_ids]
    selected_sessions = {row["session_id"] for row in selected_rows}
    envelope_rows = [row for row in all_rows if row["session_id"] in selected_sessions]
    spine_size = objective_spine_size(db, selected_rows, selected_sessions)
    context_unique_size, context_repeated_size, context_unique_count = bounded_context_sizes(
        all_rows, selected_ids, context_turns
    )
    corpus_size = content_size(corpus_rows)
    selected_size = content_size(selected_rows)
    envelope_size = content_size(envelope_rows)
    reason_counts = collections.Counter(
        reason for item in selected for reason in item["selection_reasons"]
    )
    project_counts = collections.Counter(item["project"] for item in selected)
    branch_counts = collections.Counter(
        "executed_branch" if item["branch_relation"] else "linear" for item in selected
    )
    all_strata = {row["stratum"] for row in target_rows}
    represented_strata = {item["stratum"] for item in selected}
    multi_reason = sum(1 for item in selected if len(item["selection_reasons"]) > 1)
    intersections = collections.Counter()
    for item in selected:
        for pair in itertools.combinations(item["selection_reasons"], 2):
            intersections["&".join(pair)] += 1
    over_budget = (
        max_planned_input_chars is not None and spine_size["chars"] > max_planned_input_chars
    )
    snapshot_hash = database_snapshot_hash(db)
    plan = {
        "version": 1,
        "source_db": str(db.expanduser().resolve()),
        "database_snapshot_sha256": snapshot_hash,
        "parameters": {
            "known_sessions": list(known_sessions),
            "random_size": random_size,
            "edge_size": edge_size,
            "seed": seed,
            "expected_output_tokens_per_interaction": expected_output_tokens,
            "bounded_context_preceding_turns": context_turns,
            "max_planned_input_chars": max_planned_input_chars,
        },
        "coverage": {
            "pending_alignment_interactions": len(target_rows),
            "all_alignment_interactions": len(corpus_rows),
            "all_context_inputs": len(all_rows),
            "selected_unique_interactions": len(selected),
            "selected_unique_sessions": len(selected_sessions),
            "selected_percent": (
                round(100 * len(selected) / len(target_rows), 2) if target_rows else 0
            ),
            "known_sessions_missing": missing_known,
            "selection_reason_counts": dict(sorted(reason_counts.items())),
            "multi_reason_interactions": multi_reason,
            "selection_reason_intersections": dict(sorted(intersections.items())),
            "selected_project_counts": dict(sorted(project_counts.items())),
            "selected_branch_counts": dict(sorted(branch_counts.items())),
            "strata_total": len(all_strata),
            "strata_represented": len(represented_strata),
            "strata_represented_percent": (
                round(100 * len(represented_strata) / len(all_strata), 2) if all_strata else 0
            ),
            "unrepresented_strata": sorted(all_strata - represented_strata),
        },
        "payload_budget": {
            "full_corpus_normalized": {
                **corpus_size,
                "input_token_proxy": token_proxy(corpus_size),
            },
            "selected_turns_only": {
                **selected_size,
                "input_token_proxy": token_proxy(selected_size),
            },
            "selected_session_envelopes": {
                **envelope_size,
                "input_token_proxy": token_proxy(envelope_size),
            },
            "selected_bounded_context_unique": {
                **context_unique_size,
                "unique_interactions": context_unique_count,
                "input_token_proxy": token_proxy(context_unique_size),
            },
            "selected_bounded_context_repeated_per_target": {
                **context_repeated_size,
                "input_token_proxy": token_proxy(context_repeated_size),
            },
            "selected_objective_spine_plus_target_responses": {
                **spine_size,
                "input_token_proxy": token_proxy(spine_size),
            },
            "selected_output_token_proxy": len(selected) * expected_output_tokens,
            "limitations": [
                "Model prompt, repeated lineage context, retries, and reviewer passes are not included.",
                "Provenance and branch-marker serialization overhead is not included.",
                "Session-envelope size is an upper planning surface, not a safe branch-linear payload.",
                "Bounded physical context can cross alternate branches; it is a budget surface, not a final packer.",
                "Objective-spine size includes every user input in selected sessions plus only selected assistant responses.",
            ],
        },
        "readiness": {
            "pilot_ready": False,
            "over_budget": over_budget,
            "blockers": [
                "branch-aware payload packing is not implemented",
                *( ["hard input budget is not set"] if max_planned_input_chars is None else [] ),
                *( ["objective-spine planning surface exceeds hard input budget"] if over_budget else [] ),
                "model and per-call budget are not selected",
            ],
        },
        "selected": selected,
    }
    identity_payload = json.dumps(
        {key: value for key, value in plan.items() if key != "selected"}
        | {"selected": selected},
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")
    plan["plan_identity_sha256"] = hashlib.sha256(identity_payload).hexdigest()
    return plan


def write_plan(plan, output):
    output = output.expanduser().resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(plan, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    coverage = plan["coverage"]
    budget = plan["payload_budget"]
    print(f"selected {coverage['selected_unique_interactions']}/"
          f"{coverage['pending_alignment_interactions']} interactions "
          f"across {coverage['selected_unique_sessions']} sessions")
    print(f"selection reasons: {coverage['selection_reason_counts']}")
    print(f"turn-only chars: {budget['selected_turns_only']['chars']:,}")
    print(f"bounded-context unique chars: {budget['selected_bounded_context_unique']['chars']:,}")
    print("bounded-context repeated chars: "
          f"{budget['selected_bounded_context_repeated_per_target']['chars']:,}")
    print("objective-spine chars: "
          f"{budget['selected_objective_spine_plus_target_responses']['chars']:,}")
    print(f"session-envelope chars: {budget['selected_session_envelopes']['chars']:,}")
    print(f"full-corpus chars: {budget['full_corpus_normalized']['chars']:,}")
    print(f"-> {output}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--db", type=Path, default=DEFAULT_DB)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--known-session", action="append", default=[])
    parser.add_argument("--random-size", type=int, default=100)
    parser.add_argument("--edge-size", type=int,
                        help="cap extra stratum representatives; default covers every stratum")
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--expected-output-tokens", type=int, default=180)
    parser.add_argument("--context-turns", type=int, default=6)
    parser.add_argument("--max-planned-input-chars", type=int)
    args = parser.parse_args()
    if (args.random_size < 0 or (args.edge_size is not None and args.edge_size < 0)
            or args.expected_output_tokens < 0
            or args.context_turns < 0
            or (args.max_planned_input_chars is not None
                and args.max_planned_input_chars < 0)):
        parser.error("sample sizes and expected output tokens must be non-negative")
    plan = build_plan(
        args.db, args.known_session, args.random_size, args.edge_size,
        args.seed, args.expected_output_tokens, args.context_turns,
        args.max_planned_input_chars,
    )
    write_plan(plan, args.output)


if __name__ == "__main__":
    main()
