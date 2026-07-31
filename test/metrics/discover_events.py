#!/usr/bin/env python3
"""Build a branch-aware event-discovery queue without classifying incidents."""

import argparse
import collections
import hashlib
import json
import re
import sqlite3
from pathlib import Path


HERE = Path(__file__).resolve().parent
DEFAULT_DB = HERE / "data" / "retro-index.sqlite"
DEFAULT_MANIFEST = HERE / "data" / "event-candidates.json"
DEFAULT_PACKETS = HERE / "data" / "event-packets.jsonl"

CORRECTION_RE = re.compile(
    r"ไม่ใช่|ไม่ได้หมายถึง|ผมหมายถึง|เดี๋ยว(?:นะ|ก่อน)|เข้าใจผิด|"
    r"not what|i meant|misunderst|wait[,. ]|hold on",
    re.IGNORECASE,
)
BOUNDARY_RE = re.compile(
    r"กลับ(?:มา|ไป)|หลุด|ออกนอก|พา.{0,30}(?:ไป|ออก)|แค่.{0,40}(?:ถาม|แวะ)|"
    r"เจตนา|intent|scope|objective|resume|defer|ไว้ก่อน|ทำ.{0,30}ก่อน",
    re.IGNORECASE,
)
FRICTION_RE = re.compile(
    r"ผมงง|ไม่เข้าใจว่า.{0,40}(?:จะ|ทำไม)|ทำไม.{0,40}(?:ถึง|ยัง)|"
    r"ต้อง.{0,20}(?:ท้วง|บอก|ย้ำ)|conflict|แปลก|ขัด[ๆ]?",
    re.IGNORECASE,
)
MUTATION_TOOLS = {"Bash", "Edit", "Write", "NotebookEdit"}


def load_corpus(db_path):
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    turns = [dict(row) for row in conn.execute(
        """SELECT t.id AS turn_id, t.source_id, t.session_id, t.ordinal,
                  t.alignment_auditable, t.branch_relation, t.human_confidence,
                  t.user_text, t.assistant_text, t.tool_names,
                  a.input_sha256, a.status,
                  r.uuid, r.parent_uuid, r.logical_parent_uuid, r.timestamp, r.line_no,
                  s.path AS source_file, s.project
           FROM turns t
           JOIN audit_units a ON a.turn_id=t.id
           JOIN records r ON r.id=t.user_record_id
           JOIN sources s ON s.id=t.source_id
           ORDER BY s.path, t.ordinal"""
    )]
    records = [dict(row) for row in conn.execute(
        """SELECT source_id, uuid, parent_uuid, logical_parent_uuid
           FROM records WHERE uuid IS NOT NULL"""
    )]
    conn.close()
    return turns, records


def build_lineages(turns, records):
    record_parent = {}
    for record in records:
        parent = record["logical_parent_uuid"] or record["parent_uuid"]
        record_parent[(record["source_id"], record["uuid"])] = parent
    turn_by_uuid = {
        (turn["source_id"], turn["uuid"]): turn["turn_id"]
        for turn in turns if turn["uuid"]
    }
    ancestry = {}
    for turn in turns:
        source_id = turn["source_id"]
        current = turn["logical_parent_uuid"] or turn["parent_uuid"]
        seen = set()
        ancestors = []
        while current and current not in seen:
            seen.add(current)
            ancestor_turn = turn_by_uuid.get((source_id, current))
            if ancestor_turn is not None:
                ancestors.append(ancestor_turn)
            current = record_parent.get((source_id, current))
        ancestry[turn["turn_id"]] = tuple(reversed(ancestors))
    return ancestry


def event_signals(turn):
    user = turn["user_text"]
    assistant = turn["assistant_text"]
    tools = set(json.loads(turn["tool_names"]))
    signals = []
    if CORRECTION_RE.search(user):
        signals.append("explicit_correction")
    if BOUNDARY_RE.search(user):
        signals.append("objective_or_boundary_control")
    if FRICTION_RE.search(user):
        signals.append("explicit_friction")
    is_question = "?" in user or "ไหม" in user or "หรือเปล่า" in user
    if is_question and tools & MUTATION_TOOLS:
        signals.append("question_followed_by_mutation")
    if len(assistant) > max(2000, 8 * max(1, len(user))):
        signals.append("response_expansion")
    if turn["branch_relation"]:
        signals.append("branch_edit")
    return signals


SIGNAL_WEIGHT = {
    "explicit_correction": 50,
    "explicit_friction": 45,
    "objective_or_boundary_control": 35,
    "question_followed_by_mutation": 25,
    "branch_edit": 15,
    "response_expansion": 10,
}


def stable_tiebreak(turn):
    return hashlib.sha256(
        f"{turn['input_sha256']}:{turn['turn_id']}".encode("utf-8")
    ).hexdigest()


def compact_candidate(turn, signals, known):
    return {
        "turn_id": turn["turn_id"],
        "session_id": turn["session_id"],
        "ordinal": turn["ordinal"],
        "timestamp": turn["timestamp"],
        "project": turn["project"],
        "source_file": turn["source_file"],
        "source_line": turn["line_no"],
        "uuid": turn["uuid"],
        "input_sha256": turn["input_sha256"],
        "branch_relation": turn["branch_relation"],
        "known_benchmark": known,
        "signals": signals,
        "priority_score": sum(SIGNAL_WEIGHT[signal] for signal in signals),
    }


def evidence_turn(turn):
    return {
        "turn_id": turn["turn_id"],
        "ordinal": turn["ordinal"],
        "timestamp": turn["timestamp"],
        "source_file": turn["source_file"],
        "source_line": turn["line_no"],
        "uuid": turn["uuid"],
        "branch_relation": turn["branch_relation"],
        "user": turn["user_text"],
        "assistant": turn["assistant_text"],
        "tools": json.loads(turn["tool_names"]),
        "input_sha256": turn["input_sha256"],
    }


def make_packet(target, turns_by_id, session_turns, ancestry, before_count, after_count, signals):
    ancestor_ids = list(ancestry[target["turn_id"]])
    before_ids = ancestor_ids[-before_count:] if before_count else []
    descendants = [
        turn for turn in session_turns[target["session_id"]]
        if turn["ordinal"] > target["ordinal"]
        and target["turn_id"] in ancestry[turn["turn_id"]]
    ][:after_count]
    return {
        "packet_version": 1,
        "target_turn_id": target["turn_id"],
        "session_id": target["session_id"],
        "project": target["project"],
        "signals_for_review_order_only": signals,
        "lineage_before": [evidence_turn(turns_by_id[turn_id]) for turn_id in before_ids],
        "target": evidence_turn(target),
        "lineage_after": [evidence_turn(turn) for turn in descendants],
        "review_contract": {
            "question": "Did an observable agent action diverge from the user's active intent?",
            "required_if_incident": [
                "intent_before",
                "divergence_point",
                "agent_action",
                "user_correction_or_observed_impact",
                "recovery",
                "evidence",
                "dotfile_mechanism_hypothesis",
                "regression_candidate",
            ],
            "allowed_disposition": ["incident", "not_incident", "insufficient_context"],
        },
    }


def ranked(turns, signals_by_id):
    return sorted(
        turns,
        key=lambda turn: (
            -sum(SIGNAL_WEIGHT[s] for s in signals_by_id[turn["turn_id"]]),
            stable_tiebreak(turn),
        ),
    )


def build_queue(db_path, known_sessions, discovery_limit, before_count, after_count,
                known_limit_per_session=10, discovery_since=None):
    turns, records = load_corpus(db_path)
    ancestry = build_lineages(turns, records)
    turns_by_id = {turn["turn_id"]: turn for turn in turns}
    session_turns = collections.defaultdict(list)
    for turn in turns:
        session_turns[turn["session_id"]].append(turn)

    pending = [
        turn for turn in turns
        if turn["alignment_auditable"] == 1 and turn["status"] == "pending"
    ]
    candidates = []
    known_turns = collections.defaultdict(list)
    flagged_nonknown_all = []
    known_available = set()
    signals_by_id = {}
    for turn in pending:
        signals = event_signals(turn)
        signals_by_id[turn["turn_id"]] = signals
        known = turn["session_id"] in known_sessions
        if known:
            known_turns[turn["session_id"]].append(turn)
            known_available.add(turn["session_id"])
        elif signals:
            flagged_nonknown_all.append(turn)
        candidates.append(compact_candidate(turn, signals, known))

    known_ids = {
        turn["turn_id"]
        for session_id in sorted(known_turns)
        for turn in ranked(known_turns[session_id], signals_by_id)[:known_limit_per_session]
    }
    flagged_nonknown = ranked([
        turn for turn in flagged_nonknown_all
        if discovery_since is None or (turn["timestamp"] or "") >= discovery_since
    ], signals_by_id)
    discovery_ids = {
        turn["turn_id"] for turn in flagged_nonknown[:discovery_limit]
    }
    selected_ids = known_ids | discovery_ids
    for candidate in candidates:
        candidate["packet_selected"] = candidate["turn_id"] in selected_ids

    packets = [
        make_packet(
            turns_by_id[turn_id], turns_by_id, session_turns, ancestry,
            before_count, after_count, signals_by_id[turn_id],
        )
        for turn_id in sorted(selected_ids)
    ]
    manifest = {
        "version": 1,
        "purpose": "event discovery; signals prioritize review and never classify incidents",
        "parameters": {
            "known_sessions": sorted(known_sessions),
            "discovery_limit": discovery_limit,
            "known_limit_per_session": known_limit_per_session,
            "discovery_since": discovery_since,
            "lineage_before_turns": before_count,
            "lineage_after_turns": after_count,
        },
        "coverage": {
            "pending_alignment_turns": len(pending),
            "candidate_manifest_turns": len(candidates),
            "flagged_nonbenchmark_turns": len(flagged_nonknown_all),
            "flagged_nonbenchmark_turns_in_discovery_window": len(flagged_nonknown),
            "selected_known_benchmark_turns": len(known_ids),
            "selected_discovery_turns": len(discovery_ids),
            "selected_packets": len(packets),
            "unselected_flagged_turns": max(0, len(flagged_nonknown) - len(discovery_ids)),
            "unflagged_backlog_turns": sum(
                1 for candidate in candidates
                if not candidate["signals"] and not candidate["known_benchmark"]
            ),
            "known_sessions_missing": sorted(set(known_sessions) - known_available),
        },
        "limitations": [
            "A signal is a review-order hint, not evidence that an incident occurred.",
            "Unflagged turns remain in the manifest and require a later semantic sweep.",
            "Lineage follows transcript UUID parent links; packets never concatenate sibling branches.",
            "The after-window includes only descendant human turns and can still be insufficient.",
        ],
        "candidates": candidates,
    }
    return manifest, packets


def write_outputs(manifest, packets, manifest_path, packets_path):
    manifest_path = manifest_path.expanduser().resolve()
    packets_path = packets_path.expanduser().resolve()
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    packets_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    with packets_path.open("w", encoding="utf-8") as stream:
        for packet in packets:
            stream.write(json.dumps(packet, ensure_ascii=False) + "\n")
    coverage = manifest["coverage"]
    print(
        f"selected {coverage['selected_packets']} evidence packets: "
        f"{coverage['selected_known_benchmark_turns']} known + "
        f"{coverage['selected_discovery_turns']} discovery"
    )
    print(
        f"backlog: {coverage['unselected_flagged_turns']} flagged + "
        f"{coverage['unflagged_backlog_turns']} unflagged"
    )
    print(f"-> {manifest_path}")
    print(f"-> {packets_path}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--db", type=Path, default=DEFAULT_DB)
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    parser.add_argument("--packets", type=Path, default=DEFAULT_PACKETS)
    parser.add_argument("--known-session", action="append", default=[])
    parser.add_argument("--discovery-limit", type=int, default=100)
    parser.add_argument("--known-limit-per-session", type=int, default=10)
    parser.add_argument("--discovery-since",
                        help="select discovery packets at/after this ISO timestamp; manifest stays full")
    parser.add_argument("--before", type=int, default=6)
    parser.add_argument("--after", type=int, default=2)
    args = parser.parse_args()
    if (args.discovery_limit < 0 or args.known_limit_per_session < 0
            or args.before < 0 or args.after < 0):
        parser.error("limits must be non-negative")
    manifest, packets = build_queue(
        args.db, set(args.known_session), args.discovery_limit, args.before, args.after,
        args.known_limit_per_session, args.discovery_since,
    )
    write_outputs(manifest, packets, args.manifest, args.packets)


if __name__ == "__main__":
    main()
