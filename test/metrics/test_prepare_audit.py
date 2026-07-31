#!/usr/bin/env python3
"""Behavior tests for deterministic semantic-audit pilot planning."""

import importlib.util
import json
import sqlite3
import tempfile
import unittest
from pathlib import Path


MODULE_PATH = Path(__file__).with_name("prepare_audit.py")
SPEC = importlib.util.spec_from_file_location("prepare_audit", MODULE_PATH)
PREPARE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(PREPARE)


class PrepareAuditTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.db = Path(self.temp.name) / "index.sqlite"
        conn = sqlite3.connect(self.db)
        conn.executescript("""
            CREATE TABLE meta(key TEXT PRIMARY KEY, value TEXT);
            CREATE TABLE sources(
                id INTEGER PRIMARY KEY, path TEXT, project TEXT, sha256 TEXT, status TEXT
            );
            CREATE TABLE records(
                id INTEGER PRIMARY KEY, source_id INTEGER, uuid TEXT, timestamp TEXT, line_no INTEGER
            );
            CREATE TABLE turns(
                id INTEGER PRIMARY KEY, source_id INTEGER, session_id TEXT, ordinal INTEGER,
                user_record_id INTEGER, alignment_auditable INTEGER, branch_relation TEXT,
                human_confidence TEXT, user_text TEXT, assistant_text TEXT, tool_names TEXT
            );
            CREATE TABLE audit_units(
                turn_id INTEGER PRIMARY KEY, input_sha256 TEXT, status TEXT
            );
        """)
        conn.execute("INSERT INTO meta VALUES('schema_version', '1')")
        conn.execute(
            "INSERT INTO sources VALUES(1, '/tmp/project/session.jsonl', 'project-a', "
            "'source-hash', 'indexed')"
        )
        fixtures = [
            (1, "known", 0, 1, None, "strong", "เริ่มงาน", "รับทราบ", ["Read"], "pending"),
            (2, "known", 1, 1, None, "strong", "กลับมางานเดิม", "ทำต่อ", ["Bash"], "pending"),
            (3, "normal", 0, 1, None, "strong", "คำถามนี้ได้ไหม?", "แก้ไฟล์", ["Edit"], "pending"),
            (4, "normal", 1, 1, None, "strong", "ข้อมูลเพิ่ม", "รับทราบ", [], "pending"),
            (5, "branch", 0, 1, "executed_branch:1/2", "fallback",
             "legacy prompt", "branch answer", ["Read"], "pending"),
            (6, "branch", 1, 0, "unanswered_edit:1/2", "strong",
             "old edit", "", [], "input_only"),
            (7, "context", 0, 1, None, "strong",
             "classified context", "classified answer", [], "classified"),
            (8, "context", 1, 0, None, "strong",
             "input-only context", "", [], "input_only"),
            (9, "context", 2, 1, None, "strong",
             "pending target", "target answer", [], "pending"),
        ]
        for turn_id, session_id, ordinal, auditable, branch, confidence, user, assistant, tools, status in fixtures:
            conn.execute(
                "INSERT INTO records VALUES(?,?,?,?,?)",
                (turn_id, 1, f"uuid-{turn_id}", f"2026-08-01T00:00:0{turn_id}Z", turn_id),
            )
            conn.execute(
                "INSERT INTO turns VALUES(?,?,?,?,?,?,?,?,?,?,?)",
                (turn_id, 1, session_id, ordinal, turn_id, auditable, branch, confidence,
                 user, assistant, json.dumps(tools)),
            )
            conn.execute(
                "INSERT INTO audit_units VALUES(?,?,?)",
                (turn_id, f"hash-{turn_id}", status),
            )
        conn.commit()
        conn.close()

    def tearDown(self):
        self.temp.cleanup()

    def test_plan_is_deterministic_and_excludes_input_only(self):
        first = PREPARE.build_plan(self.db, ["known"], 1, 2, 42, 180)
        second = PREPARE.build_plan(self.db, ["known"], 1, 2, 42, 180)
        self.assertEqual(first, second)
        selected_ids = {item["turn_id"] for item in first["selected"]}
        self.assertTrue({1, 2, 5}.issubset(selected_ids))
        self.assertNotIn(6, selected_ids)
        self.assertEqual(first["coverage"]["pending_alignment_interactions"], 6)
        self.assertEqual(first["coverage"]["known_sessions_missing"], [])
        self.assertGreater(first["coverage"]["strata_total"], 0)
        self.assertLessEqual(
            first["coverage"]["strata_represented"], first["coverage"]["strata_total"]
        )

    def test_selection_records_reasons_and_risk_without_using_them_as_gate(self):
        plan = PREPARE.build_plan(self.db, ["missing"], 5, 0, 7, 100)
        by_id = {item["turn_id"]: item for item in plan["selected"]}
        self.assertEqual(set(by_id), {1, 2, 3, 4, 5})
        self.assertIn("random_holdout", by_id[4]["selection_reasons"])
        self.assertIn("question_with_mutation_tools", by_id[3]["risk_tags"])
        self.assertIn("legacy_fallback", by_id[5]["selection_reasons"])
        self.assertEqual(plan["coverage"]["known_sessions_missing"], ["missing"])

    def test_budget_reports_turn_session_and_full_corpus_surfaces(self):
        plan = PREPARE.build_plan(self.db, [], 1, 0, 3, 50)
        budget = plan["payload_budget"]
        self.assertGreater(budget["full_corpus_normalized"]["chars"], 0)
        self.assertGreaterEqual(
            budget["selected_session_envelopes"]["chars"],
            budget["selected_turns_only"]["chars"],
        )
        self.assertEqual(
            budget["selected_output_token_proxy"],
            plan["coverage"]["selected_unique_interactions"] * 50,
        )
        self.assertGreaterEqual(
            budget["selected_bounded_context_repeated_per_target"]["chars"],
            budget["selected_bounded_context_unique"]["chars"],
        )
        self.assertGreaterEqual(
            budget["selected_objective_spine_plus_target_responses"]["chars"],
            budget["selected_turns_only"]["chars"],
        )

    def test_sampling_uses_pending_but_context_and_corpus_preserve_prior_turns(self):
        plan = PREPARE.build_plan(self.db, ["context"], 0, 0, 3, 50, context_turns=6)
        selected_ids = {item["turn_id"] for item in plan["selected"]}
        self.assertEqual(selected_ids, {5, 9})
        self.assertNotIn(7, selected_ids)
        self.assertNotIn(8, selected_ids)
        self.assertEqual(plan["coverage"]["pending_alignment_interactions"], 6)
        self.assertEqual(plan["coverage"]["all_alignment_interactions"], 7)
        self.assertEqual(plan["coverage"]["all_context_inputs"], 9)
        target_chars = len("pending target") + len("target answer") + len("[]")
        classified_chars = (
            len("classified context") + len("classified answer") + len("[]")
        )
        input_only_chars = len("input-only context") + len("") + len("[]")
        fallback_chars = len("legacy prompt") + len("branch answer") + len('["Read"]')
        self.assertEqual(
            plan["payload_budget"]["selected_turns_only"]["chars"],
            fallback_chars + target_chars,
        )
        self.assertEqual(
            plan["payload_budget"]["selected_bounded_context_unique"]["chars"],
            fallback_chars + classified_chars + input_only_chars + target_chars,
        )
        self.assertGreater(
            plan["payload_budget"]["full_corpus_normalized"]["chars"],
            plan["payload_budget"]["selected_turns_only"]["chars"],
        )

    def test_overlap_and_fail_closed_readiness_are_explicit(self):
        plan = PREPARE.build_plan(
            self.db, ["branch"], 0, 0, 3, 50, max_planned_input_chars=0
        )
        self.assertEqual(plan["coverage"]["multi_reason_interactions"], 1)
        self.assertEqual(
            plan["coverage"]["selection_reason_intersections"],
            {"known_benchmark&legacy_fallback": 1},
        )
        self.assertFalse(plan["readiness"]["pilot_ready"])
        self.assertTrue(plan["readiness"]["over_budget"])
        self.assertIn(
            "branch-aware payload packing is not implemented",
            plan["readiness"]["blockers"],
        )


if __name__ == "__main__":
    unittest.main()
