#!/usr/bin/env python3
"""Regression tests for diff-scoped and JSON comment audit scanning."""

from __future__ import annotations

import json
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCANNER = ROOT / "claude" / "skills" / "docs" / "placement" / "scripts" / "scan.py"
LONG_COMMENT = """# This rationale is intentionally long enough to qualify for duplicate detection.
# It describes the same historical implementation detail in more than one source file.
# The audit should report it as a candidate, not automatically rewrite either occurrence.
"""


class CommentAuditTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory(prefix="comment-audit-")
        self.repo = Path(self.temp_dir.name)
        subprocess.run(["git", "init", "-q", str(self.repo)], check=True)
        (self.repo / "unchanged.py").write_text(
            "# Existing explanation line one.\n# Existing explanation line two.\n"
            "# Existing explanation line three.\nvalue = 1\n",
            encoding="utf-8",
        )
        (self.repo / "changed.py").write_text("value = 1\n", encoding="utf-8")
        (self.repo / "short.py").write_text("value = 1\n", encoding="utf-8")
        subprocess.run(["git", "-C", str(self.repo), "add", "."], check=True)
        subprocess.run(
            [
                "git", "-C", str(self.repo), "-c", "user.name=Test",
                "-c", "user.email=test@example.invalid", "commit", "-qm", "baseline",
            ],
            check=True,
        )
        (self.repo / "changed.py").write_text(LONG_COMMENT + "value = 2\n", encoding="utf-8")
        (self.repo / "short.py").write_text(
            "# Keep this value aligned with the public response.\nvalue = 2\n", encoding="utf-8"
        )
        (self.repo / "untracked.py").write_text(LONG_COMMENT + "value = 3\n", encoding="utf-8")

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def run_scan(self, *args: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ["python3", str(SCANNER), str(self.repo), *args],
            capture_output=True,
            text=True,
            encoding="utf-8",
        )

    def test_diff_json_includes_changed_and_untracked_only(self) -> None:
        result = self.run_scan("--diff", "HEAD", "--format", "json")
        self.assertEqual(result.returncode, 0, result.stderr)
        report = json.loads(result.stdout)
        paths = {item["path"] for item in report["blocks"]}
        self.assertEqual(paths, {"changed.py", "short.py", "untracked.py"})
        self.assertEqual(report["summary"], {"blocks": 3, "duplicate_groups": 1})

    def test_full_scan_keeps_unchanged_candidates(self) -> None:
        result = self.run_scan("--format", "json")
        self.assertEqual(result.returncode, 0, result.stderr)
        paths = {item["path"] for item in json.loads(result.stdout)["blocks"]}
        self.assertEqual(paths, {"changed.py", "unchanged.py", "untracked.py"})

    def test_invalid_diff_base_fails_loud(self) -> None:
        result = self.run_scan("--diff", "missing-revision")
        self.assertEqual(result.returncode, 2)
        self.assertIn("comment audit scan failed", result.stderr)

    def test_text_output_warns_that_candidates_are_not_defects(self) -> None:
        result = self.run_scan()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("they are not defects", result.stdout)
        self.assertIn("Triple-quoted data strings", result.stdout)
        self.assertIn("Deleted comments", result.stdout)


if __name__ == "__main__":
    unittest.main()
