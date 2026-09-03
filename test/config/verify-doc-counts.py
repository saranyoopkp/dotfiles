#!/usr/bin/env python3
"""Verify that surface counts written in documentation match what the repository actually has.

A count copied into prose is a fact that depends on memory, and a rule that depends on memory is
a rule that dies quietly: README claimed 13 rules and 49 skills for five days after the
2026-08-26 consolidation, because the edit that changed the counts and the edit that touched the
prose were different commits.

This checks the claim against the tree instead of against anyone's recollection.

Historical or comparative numbers are legitimate ("13 rule files at the first commit"). Those are
written as prose rather than as a bare "<N> rules" claim, and any line that genuinely needs to
state a stale number can opt out with a `counts:ignore` marker.

Usage:
    python3 test/config/verify-doc-counts.py            # check the working tree
    python3 test/config/verify-doc-counts.py --self-test # prove the checker fails on a bad count
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
import tempfile
from pathlib import Path

IGNORE_MARKER = "counts:ignore"

# Documentation copied into other repositories describes those repositories, not this one.
EXCLUDED_PREFIXES = ("claude/skills/docs/setup/kit/",)

SURFACES = {
    "rules": lambda root: sorted(p for p in (root / "claude/rules").rglob("*.md")),
    "skills": lambda root: sorted(p for p in (root / "claude/skills").rglob("SKILL.md")),
    "agents": lambda root: sorted(p for p in (root / "claude/agents").glob("*.md")),
}

# "**6 rules** cover ..." / "50 skills cover ..." — a bare present-tense claim.
# Deliberately narrow: "13 rule files at the first commit" is prose about history, not a claim
# about the current tree, and is not matched.
PROSE = {name: re.compile(rf"(?<![\w.])(\d+)\s+{name}\b") for name in SURFACES}

# "claude/rules/      6 always-loaded invariants" — the layout block.
LAYOUT = re.compile(r"claude/(rules|skills|agents)/\s+(\d+)\b")


def repo_root() -> Path:
    out = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        capture_output=True,
        text=True,
        check=True,
    )
    return Path(out.stdout.strip())


def tracked_markdown(root: Path) -> list[Path]:
    out = subprocess.run(
        ["git", "ls-files", "*.md"],
        cwd=root,
        capture_output=True,
        text=True,
        check=True,
    )
    paths = []
    for rel in out.stdout.splitlines():
        if rel.startswith(EXCLUDED_PREFIXES):
            continue
        paths.append(root / rel)
    return paths


def actual_counts(root: Path) -> dict[str, int]:
    return {name: len(finder(root)) for name, finder in SURFACES.items()}


def check(root: Path) -> tuple[list[str], dict[str, int], int]:
    actual = actual_counts(root)
    findings: list[str] = []
    claims = 0

    for path in tracked_markdown(root):
        rel = path.relative_to(root)
        try:
            text = path.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError) as exc:  # pragma: no cover - unreadable file
            findings.append(f"{rel}: could not read ({exc})")
            continue

        for lineno, line in enumerate(text.splitlines(), start=1):
            if IGNORE_MARKER in line:
                continue

            for surface, pattern in PROSE.items():
                for match in pattern.finditer(line):
                    claims += 1
                    claimed = int(match.group(1))
                    if claimed != actual[surface]:
                        findings.append(
                            f"{rel}:{lineno}: claims {claimed} {surface}, "
                            f"repository has {actual[surface]}"
                        )

            for match in LAYOUT.finditer(line):
                surface, claimed = match.group(1), int(match.group(2))
                claims += 1
                if claimed != actual[surface]:
                    findings.append(
                        f"{rel}:{lineno}: layout block claims {claimed} {surface}, "
                        f"repository has {actual[surface]}"
                    )

    return findings, actual, claims


def self_test(root: Path) -> int:
    """A checker that never fails is not a check. Prove it catches a wrong count."""
    actual = actual_counts(root)
    with tempfile.TemporaryDirectory() as tmp:
        fixture = Path(tmp) / "repo"
        subprocess.run(["git", "init", "-q", str(fixture)], check=True)

        for surface in SURFACES:
            (fixture / "claude" / surface).mkdir(parents=True, exist_ok=True)
        (fixture / "claude/rules/a.md").write_text("rule\n", encoding="utf-8")
        (fixture / "claude/skills/s").mkdir(parents=True, exist_ok=True)
        (fixture / "claude/skills/s/SKILL.md").write_text("skill\n", encoding="utf-8")
        (fixture / "claude/agents/x.md").write_text("agent\n", encoding="utf-8")
        # Fixture truth: 1 rule, 1 skill, 1 agent.

        (fixture / "README.md").write_text(
            "**9 rules** cover things.\n"
            "**1 skills** is right.\n"
            "A line about 9 rules that is historical. counts:ignore\n"
            "```\nclaude/agents/     7 role definitions\n```\n",
            encoding="utf-8",
        )
        subprocess.run(["git", "add", "-A"], cwd=fixture, check=True)

        findings, fixture_actual, claims = check(fixture)

    problems: list[str] = []
    if fixture_actual != {"rules": 1, "skills": 1, "agents": 1}:
        problems.append(f"fixture discovery wrong: {fixture_actual}")
    if not any("claims 9 rules" in f for f in findings):
        problems.append("did not catch the wrong prose count")
    if not any("layout block claims 7 agents" in f for f in findings):
        problems.append("did not catch the wrong layout count")
    if any(":3:" in f for f in findings):
        problems.append(f"{IGNORE_MARKER} line was not skipped")
    if any("1 skills" in f for f in findings):
        problems.append("flagged a correct count")
    if claims < 3:
        problems.append(f"scanned too few claims ({claims})")

    if problems:
        print("self-test FAILED", file=sys.stderr)
        for p in problems:
            print(f"  - {p}", file=sys.stderr)
        return 1

    print(f"self-test ok (checker catches bad counts; live tree has {actual})")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true", help="verify the checker itself")
    args = parser.parse_args()

    root = repo_root()
    if args.self_test:
        return self_test(root)

    findings, actual, claims = check(root)
    if findings:
        print("Documented counts do not match the repository:", file=sys.stderr)
        for finding in findings:
            print(f"  {finding}", file=sys.stderr)
        print(
            f"\nActual: {actual['rules']} rules, {actual['skills']} skills, "
            f"{actual['agents']} agents.\n"
            f"Fix the prose, or mark a deliberately historical line with `{IGNORE_MARKER}`.",
            file=sys.stderr,
        )
        return 1

    print(
        f"ok — {claims} documented count(s) match the tree "
        f"({actual['rules']} rules, {actual['skills']} skills, {actual['agents']} agents)"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
