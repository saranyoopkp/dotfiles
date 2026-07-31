#!/usr/bin/env python3
"""Behavior tests for the evidence-grade transcript index."""

import importlib.util
import json
import sqlite3
import tempfile
import unittest
from pathlib import Path


MODULE_PATH = Path(__file__).with_name("index_transcripts.py")
SPEC = importlib.util.spec_from_file_location("index_transcripts", MODULE_PATH)
INDEX = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(INDEX)


def record(kind, content=None, **extra):
    data = {
        "type": kind,
        "sessionId": extra.pop("sessionId", "session-main"),
        "uuid": extra.pop("uuid", None),
        "parentUuid": extra.pop("parentUuid", None),
        "timestamp": extra.pop("timestamp", "2026-08-01T00:00:00.000Z"),
    }
    if content is not None:
        data["message"] = {"role": kind, "content": content}
    data.update(extra)
    return data


class TranscriptIndexTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name) / "projects"
        self.root.mkdir()
        self.db = Path(self.temp.name) / "index.sqlite"

    def tearDown(self):
        self.temp.cleanup()

    def write_jsonl(self, path, rows):
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("w", encoding="utf-8") as stream:
            for row in rows:
                if isinstance(row, str):
                    stream.write(row + "\n")
                else:
                    stream.write(json.dumps(row, ensure_ascii=False) + "\n")

    def build_fixture(self):
        main = self.root / "-Users-GSP-Work-App" / "session-main.jsonl"
        rows = [
            record("user", "ทำ load test", uuid="u1", parentUuid="root",
                   promptSource="typed", timestamp="2026-08-01T01:00:03Z"),
            record("assistant", [{"type": "text", "text": "เริ่มตรวจ"}], uuid="a1",
                   parentUuid="u1", timestamp="2026-08-01T01:00:02Z"),
            record("assistant", [{"type": "tool_use", "id": "tool-1", "name": "Read",
                                  "input": {"file_path": "/tmp/example"}}], uuid="a2",
                   parentUuid="a1"),
            record("user", [{"type": "tool_result", "tool_use_id": "tool-1",
                             "content": "result"}], uuid="tr1", parentUuid="a2"),
            record("assistant", [{"type": "text", "text": "พร้อมทำต่อ"}], uuid="a3",
                   parentUuid="tr1"),
            record("user", "ข้อความก่อน edit", uuid="u2-old", parentUuid="edit-parent"),
            record("user", "คำถามแทรกที่แก้แล้ว", uuid="u2", parentUuid="edit-parent",
                   promptSource="queued"),
            record("assistant", [{"type": "text", "text": "ตอบคำถามแทรก"}], uuid="a4",
                   parentUuid="u2"),
            record("user", [{"type": "text", "text": "injected"}], uuid="meta1",
                   parentUuid="a4", isMeta=True, promptSource="system"),
            record("user", "summary", uuid="sum1", isCompactSummary=True),
            record("user", "uncertain", uuid="amb1", promptSource="unknown-source"),
            record("user", "[Request interrupted by user]", uuid="interrupt2"),
            record("user", "Another Claude session sent a message:\nhello", uuid="notify1"),
            record("user", "/compact", uuid="compact-command"),
            "{malformed",
            "[]",
            "",
        ]
        self.write_jsonl(main, rows)
        subagent = (self.root / "-Users-GSP-Work-App" / "session-main" / "subagents"
                    / "agent-123.jsonl")
        self.write_jsonl(subagent, [record("user", "delegated work", isSidechain=True)])
        harness = self.root / "-private-tmp-routing" / "harness.jsonl"
        self.write_jsonl(harness, [record("user", "test prompt", promptSource="typed")])
        sdk = self.root / "-Users-GSP-Work-SDK" / "sdk.jsonl"
        self.write_jsonl(sdk, [record("user", "programmatic prompt", promptSource="sdk",
                                             entrypoint="sdk-cli")])

    def test_reconciles_sources_lines_turns_and_audit_queue(self):
        self.build_fixture()
        INDEX.create_index(self.root, self.db, report=False)
        status = INDEX.status_values(self.db)
        self.assertEqual(status["files_discovered"], 4)
        self.assertEqual(status["files_indexed"], 1)
        self.assertEqual(status["files_excluded"], 3)
        self.assertEqual(status["files_failed"], 0)
        self.assertEqual(status["indexed_lines"], 17)
        self.assertEqual(status["parsed_lines"], 14)
        self.assertEqual(status["malformed_lines"], 2)
        self.assertEqual(status["blank_lines"], 1)
        self.assertEqual(status["human_prompts"], 3)
        self.assertEqual(status["auditable_inputs"], 3)
        self.assertEqual(status["alignment_auditable_turns"], 2)
        self.assertEqual(status["branch_candidate_turns"], 2)
        self.assertEqual(status["audit_pending"], 2)
        self.assertEqual(status["audit_input_only"], 1)
        self.assertEqual(status["ambiguous_user_inputs"], 1)
        self.assertEqual(status["user_records"], 10)
        self.assertEqual(status["nonhuman_user_records"], 6)
        conn = sqlite3.connect(self.db)
        try:
            issues = conn.execute(
                "SELECT line_no, kind, raw_sha256 FROM ingest_issues ORDER BY line_no"
            ).fetchall()
        finally:
            conn.close()
        self.assertEqual([issue[:2] for issue in issues],
                         [(15, "malformed_json"), (16, "unsupported_json_shape")])
        self.assertTrue(all(len(issue[2]) == 64 for issue in issues))

    def test_tool_results_do_not_become_human_turns(self):
        self.build_fixture()
        INDEX.create_index(self.root, self.db, report=False)
        conn = sqlite3.connect(self.db)
        try:
            kinds = dict(conn.execute(
                "SELECT normalized_kind, count(*) FROM records GROUP BY normalized_kind"
            ))
            first = conn.execute(
                "SELECT assistant_text, tool_names FROM turns ORDER BY ordinal LIMIT 1"
            ).fetchone()
        finally:
            conn.close()
        self.assertEqual(kinds["tool_result"], 1)
        self.assertIn("เริ่มตรวจ", first[0])
        self.assertIn("พร้อมทำต่อ", first[0])
        self.assertEqual(json.loads(first[1]), ["Read"])

    def test_physical_order_wins_over_timestamp_and_sibling_is_retained(self):
        self.build_fixture()
        INDEX.create_index(self.root, self.db, report=False)
        conn = sqlite3.connect(self.db)
        try:
            turns = conn.execute(
                """SELECT ordinal, user_text, alignment_auditable, branch_relation
                   FROM turns ORDER BY ordinal"""
            ).fetchall()
        finally:
            conn.close()
        self.assertEqual([row[1] for row in turns],
                         ["ทำ load test", "ข้อความก่อน edit", "คำถามแทรกที่แก้แล้ว"])
        self.assertEqual(turns[1][2:], (0, "unanswered_edit:1/2"))
        self.assertEqual(turns[2][2:], (1, "executed_branch:2/2"))

    def test_mixed_sdk_source_keeps_typed_human_input(self):
        path = self.root / "-Users-GSP-Work-Mixed" / "mixed.jsonl"
        self.write_jsonl(path, [
            record("user", "automated", uuid="sdk1", promptSource="sdk", entrypoint="sdk-cli"),
            record("user", "legacy follow-up", uuid="human1", entrypoint="cli"),
            record("assistant", [{"type": "text", "text": "answer"}], uuid="answer1"),
        ])
        INDEX.create_index(self.root, self.db, report=False)
        status = INDEX.status_values(self.db)
        self.assertEqual(status["files_indexed"], 1)
        self.assertEqual(status["auditable_inputs"], 1)
        conn = sqlite3.connect(self.db)
        try:
            kinds = dict(conn.execute(
                "SELECT normalized_kind, count(*) FROM records GROUP BY normalized_kind"
            ))
        finally:
            conn.close()
        self.assertEqual(kinds["sdk_prompt"], 1)
        self.assertEqual(kinds["human_prompt"], 1)

    def test_export_keeps_every_auditable_input_inside_session_envelope(self):
        self.build_fixture()
        INDEX.create_index(self.root, self.db, report=False)
        output = Path(self.temp.name) / "queue.jsonl"
        INDEX.export_sessions(self.db, output, sessions=["session-main"])
        sessions = [json.loads(line) for line in output.read_text(encoding="utf-8").splitlines()]
        self.assertEqual(len(sessions), 1)
        self.assertEqual(sessions[0]["session_id"], "session-main")
        self.assertEqual([turn["user"] for turn in sessions[0]["turns"]],
                         ["ทำ load test", "ข้อความก่อน edit", "คำถามแทรกที่แก้แล้ว"])
        self.assertEqual(sessions[0]["expected_review_count"], 2)
        self.assertTrue(all(turn["source_file"] and turn["source_line"]
                            for turn in sessions[0]["turns"]))

    def test_import_rejects_partial_session_and_classifies_complete_session(self):
        self.build_fixture()
        INDEX.create_index(self.root, self.db, report=False)
        queue = Path(self.temp.name) / "queue.jsonl"
        INDEX.export_sessions(self.db, queue, sessions=["session-main"])
        session = json.loads(queue.read_text(encoding="utf-8"))
        result = {"session_id": "session-main", "turns": []}
        for turn in session["turns"]:
            if not turn["alignment_auditable"]:
                continue
            result["turns"].append({
                "turn_id": turn["turn_id"],
                "input_sha256": turn["input_sha256"],
                "relation": "CONTINUE",
                "objective_before": ["load-test"],
                "objective_after": ["load-test"],
                "alignment": "aligned",
                "confidence": "high",
                "rationale": "synthetic fixture",
                "evidence": [{"source_file": turn["source_file"],
                              "source_line": turn["source_line"], "uuid": turn["uuid"]}],
            })
        partial = Path(self.temp.name) / "partial.jsonl"
        partial.write_text(json.dumps({**result, "turns": result["turns"][:1]}) + "\n",
                           encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "incomplete result"):
            INDEX.import_results(self.db, partial, "test", "v1")
        complete = Path(self.temp.name) / "complete.jsonl"
        complete.write_text(json.dumps(result) + "\n", encoding="utf-8")
        INDEX.import_results(self.db, complete, "test", "v1")
        status = INDEX.status_values(self.db)
        self.assertEqual(status["audit_pending"], 0)
        self.assertEqual(status["audit_classified"], 2)
        self.assertEqual(status["audit_input_only"], 1)

    def test_reindex_is_deterministic_for_same_corpus(self):
        self.build_fixture()
        other = Path(self.temp.name) / "other.sqlite"
        INDEX.create_index(self.root, self.db, report=False)
        INDEX.create_index(self.root, other, report=False)

        def snapshot(path):
            conn = sqlite3.connect(path)
            try:
                return {
                    "sources": conn.execute(
                        """SELECT path, sha256, total_lines, parsed_lines, malformed_lines,
                                  included, exclusion_reason, status FROM sources ORDER BY path"""
                    ).fetchall(),
                    "records": conn.execute(
                        "SELECT source_id, line_no, raw_sha256, normalized_kind FROM records ORDER BY id"
                    ).fetchall(),
                    "turns": conn.execute(
                        """SELECT session_id, ordinal, alignment_auditable, branch_relation,
                                  user_text, assistant_text,
                                  input_sha256 FROM turns JOIN audit_units ON turn_id=turns.id
                           ORDER BY turns.id"""
                    ).fetchall(),
                }
            finally:
                conn.close()

        self.assertEqual(snapshot(self.db), snapshot(other))


if __name__ == "__main__":
    unittest.main()
