#!/usr/bin/env python3
"""Behavior tests for branch-aware event discovery."""

import importlib.util
import json
import sqlite3
import tempfile
import unittest
from pathlib import Path


MODULE_PATH = Path(__file__).with_name("discover_events.py")
SPEC = importlib.util.spec_from_file_location("discover_events", MODULE_PATH)
DISCOVER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(DISCOVER)


class DiscoverEventsTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.db = Path(self.temp.name) / "index.sqlite"
        conn = sqlite3.connect(self.db)
        conn.executescript("""
            CREATE TABLE sources(id INTEGER PRIMARY KEY, path TEXT, project TEXT);
            CREATE TABLE records(
                id INTEGER PRIMARY KEY, source_id INTEGER, uuid TEXT, parent_uuid TEXT,
                logical_parent_uuid TEXT, timestamp TEXT, line_no INTEGER
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
        conn.execute("INSERT INTO sources VALUES(1, '/tmp/session.jsonl', 'project-a')")
        records = [
            (1, "u-root", None, None, 1),
            (2, "a-root", "u-root", None, 2),
            (3, "u-left", "a-root", None, 3),
            (4, "a-left", "u-left", None, 4),
            (5, "u-right", "a-root", None, 5),
            (6, "a-right", "u-right", None, 6),
            (7, "u-recover", "a-left", None, 7),
        ]
        for record_id, uuid, parent, logical, line in records:
            conn.execute(
                "INSERT INTO records VALUES(?,?,?,?,?,?,?)",
                (record_id, 1, uuid, parent, logical, f"2026-08-01T00:00:0{line}Z", line),
            )
        turns = [
            (1, 0, 1, None, "Start the task", "Starting", ["Read"]),
            (2, 1, 3, "executed_branch:1/2", "No, go back to the original task", "Fixed it", ["Edit"]),
            (3, 2, 5, "executed_branch:2/2", "Another approach", "Alternate branch answer", []),
            (4, 3, 7, None, "Okay, continue", "Continued", ["Bash"]),
        ]
        for turn_id, ordinal, record_id, branch, user, assistant, tools in turns:
            conn.execute(
                "INSERT INTO turns VALUES(?,?,?,?,?,?,?,?,?,?,?)",
                (turn_id, 1, "session-a", ordinal, record_id, 1, branch, "strong",
                 user, assistant, json.dumps(tools)),
            )
            conn.execute(
                "INSERT INTO audit_units VALUES(?,?,?)",
                (turn_id, f"hash-{turn_id}", "pending"),
            )
        conn.commit()
        conn.close()

    def tearDown(self):
        self.temp.cleanup()

    def test_packet_follows_lineage_and_excludes_sibling_branch(self):
        manifest, packets = DISCOVER.build_queue(self.db, set(), 10, 6, 2)
        packet = next(packet for packet in packets if packet["target_turn_id"] == 2)
        self.assertEqual([turn["turn_id"] for turn in packet["lineage_before"]], [1])
        self.assertEqual([turn["turn_id"] for turn in packet["lineage_after"]], [4])
        self.assertNotIn(3, {
            turn["turn_id"]
            for turn in packet["lineage_before"] + packet["lineage_after"]
        })
        self.assertIn("explicit_correction", packet["signals_for_review_order_only"])
        self.assertEqual(manifest["coverage"]["candidate_manifest_turns"], 4)

    def test_manifest_keeps_unflagged_backlog_and_known_sessions(self):
        manifest, packets = DISCOVER.build_queue(self.db, {"session-a"}, 0, 1, 0)
        self.assertEqual(manifest["coverage"]["selected_known_benchmark_turns"], 4)
        self.assertEqual(manifest["coverage"]["selected_discovery_turns"], 0)
        self.assertEqual(len(packets), 4)
        self.assertEqual(manifest["coverage"]["known_sessions_missing"], [])

    def test_discovery_since_limits_packets_but_not_candidate_manifest(self):
        manifest, packets = DISCOVER.build_queue(
            self.db, set(), 10, 1, 0, discovery_since="2026-08-02"
        )
        self.assertEqual(manifest["coverage"]["candidate_manifest_turns"], 4)
        self.assertEqual(
            manifest["coverage"]["flagged_nonbenchmark_turns_in_discovery_window"], 0
        )
        self.assertEqual(packets, [])
        self.assertTrue(all(not candidate["packet_selected"]
                            for candidate in manifest["candidates"]))


if __name__ == "__main__":
    unittest.main()
