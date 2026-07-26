#!/usr/bin/env python3
"""Audit tracked Markdown links against independent repository boundaries."""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import unquote

LINK_RE = re.compile(
    r"\]\(\s*<?([^)\s>]+)>?\s*(?:\"[^\"]*\")?\s*\)|^\[[^\]]+\]:[ \t]+(\S+)",
    re.MULTILINE,
)
HOME_RE = re.compile(
    r"(?<![\w./])(?:/Users/[^/\s]+/|/home/[^/\s]+/|[A-Za-z]:[\\/]Users[\\/][^\\/\s]+[\\/])\S+"
)
FENCE_RE = re.compile(r"^[ \t]*(```|~~~).*?^[ \t]*\1[ \t]*$", re.MULTILINE | re.DOTALL)
SKIP_PREFIXES = ("http://", "https://", "mailto:", "tel:", "#", "data:", "//")
PRUNE = {
    "node_modules",
    "vendor",
    "dist",
    "build",
    "coverage",
    ".archive",
    ".cache",
    ".next",
}


def is_git_root(path: Path) -> bool:
    return (path / ".git").is_dir() or (path / ".git").is_file()


def find_repositories(workspace: Path, max_depth: int) -> list[Path]:
    repositories: list[Path] = []
    for current, directories, _files in os.walk(workspace):
        path = Path(current)
        depth = len(path.relative_to(workspace).parts)
        if is_git_root(path):
            repositories.append(path)
            directories[:] = [
                name
                for name in directories
                if name != ".git" and not name.startswith(".") and name not in PRUNE
            ]
        else:
            directories[:] = [
                name
                for name in directories
                if not name.startswith(".") and name not in PRUNE
            ]
        if depth >= max_depth:
            directories.clear()
    return sorted(set(repositories))


def tracked_markdown(repo: Path) -> tuple[list[Path], str | None]:
    result = subprocess.run(
        ["git", "-C", str(repo), "ls-files", "-z", "*.md"],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode:
        return [], (result.stderr or "git ls-files failed").strip().splitlines()[0]
    return [repo / item for item in result.stdout.split("\0") if item], None


def link_targets(text: str):
    for match in LINK_RE.finditer(FENCE_RE.sub("", text)):
        target = unquote(match.group(1) or match.group(2) or "")
        target = target.split("#", 1)[0].split("?", 1)[0].strip()
        if (
            not target
            or target.startswith(SKIP_PREFIXES)
            or target.startswith("/")
            or "<" in target
            or ">" in target
        ):
            continue
        yield target


def audit_repository(repo: Path):
    files, error = tracked_markdown(repo)
    if error:
        return [], error

    findings = []
    root = repo.resolve()
    for path in files:
        try:
            text = path.read_text(encoding="utf-8", errors="replace")
        except OSError as exc:
            findings.append(("READ_ERROR", str(path.relative_to(repo)), str(exc)))
            continue

        relative = str(path.relative_to(repo))
        for match in HOME_RE.finditer(text):
            findings.append(("HOME_PATH", relative, match.group(0).rstrip(".,;:)")))

        for target in link_targets(text):
            candidates = {(path.parent / target).resolve(), (repo / target).resolve()}
            inside = []
            for candidate in candidates:
                try:
                    candidate.relative_to(root)
                    inside.append(candidate)
                except ValueError:
                    pass
            if not inside:
                findings.append(("ESCAPE", relative, target))
                continue
            if not any(candidate.exists() for candidate in inside):
                findings.append(("MISSING", relative, target))
    return findings, None


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Audit Markdown links inside every Git repository in a workspace."
    )
    parser.add_argument("workspace", nargs="?", default=".")
    parser.add_argument("--max-depth", type=int, default=5)
    parser.add_argument("--no-fail", action="store_true")
    args = parser.parse_args()

    workspace = Path(args.workspace).resolve()
    repositories = find_repositories(workspace, args.max_depth)
    if not repositories:
        print(f"no Git repository found under {workspace}")
        return 2

    total = 0
    for repo in repositories:
        label = "." if repo == workspace else str(repo.relative_to(workspace))
        findings, error = audit_repository(repo)
        if error:
            print(f"[SKIP] {label}: {error}")
            continue
        print(f"[{'OK' if not findings else 'FINDING'}] {label}: {len(findings)}")
        for kind, source, target in findings:
            print(f"  {kind:<10} {source} -> {target}")
        total += len(findings)

    print(f"scanned {len(repositories)} repositories; findings={total}")
    return 0 if args.no_fail or total == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
