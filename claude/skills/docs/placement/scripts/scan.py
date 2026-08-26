#!/usr/bin/env python3
"""Read-only comment/docstring candidate scanner for docs:placement audits."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path


if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")


CODE_EXT = {
    ".py", ".sh", ".ps1", ".js", ".jsx", ".ts", ".tsx", ".go", ".java",
    ".cs", ".rb", ".php", ".c", ".h", ".cpp", ".rs", ".kt", ".swift",
}
LINE_MARK = re.compile(r"^\s*(#|//)\s?(.*)$")
BLOCK_OPEN = re.compile(r"^\s*(/\*|\"\"\"|''')")
BLOCK_CLOSE = {"/*": "*/", '"""': '"""', "'''": "'''"}
HUNK_RE = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@")


def git(root: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", "-C", str(root), *args], capture_output=True, text=True, encoding="utf-8"
    )
    if result.returncode:
        raise ValueError(result.stderr.strip() or f"git {' '.join(args)} failed")
    return result.stdout


def git_files(root: Path) -> list[str]:
    return [
        line for line in git(root, "ls-files", "-c", "-o", "--exclude-standard").splitlines()
        if line
    ]


def blocks_in(path: Path):
    """Yield (start_line, line_count, source_text) for comment/docstring blocks."""
    try:
        lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError:
        return
    index = 0
    while index < len(lines):
        line_match = LINE_MARK.match(lines[index])
        if line_match and not lines[index].strip().startswith("#!"):
            start = index
            content = []
            while index < len(lines) and (match := LINE_MARK.match(lines[index])):
                content.append(match.group(2))
                index += 1
            yield start + 1, index - start, "\n".join(content)
            continue
        block_match = BLOCK_OPEN.match(lines[index])
        if block_match:
            opener = block_match.group(1)
            closer = BLOCK_CLOSE[opener]
            start = index
            content = [lines[index]]
            if closer in lines[index][lines[index].find(opener) + len(opener):]:
                index += 1
                yield start + 1, 1, content[0].strip()
                continue
            index += 1
            while index < len(lines) and closer not in lines[index]:
                content.append(lines[index])
                index += 1
            if index < len(lines):
                content.append(lines[index])
                index += 1
            yield start + 1, len(content), "\n".join(
                line.strip(" \t*/") for line in content
            )
            continue
        index += 1


def changed_ranges(root: Path, base: str) -> dict[str, list[tuple[int, int]]]:
    """Return current-file line ranges added or modified relative to base."""
    diff = git(
        root, "-c", "core.quotepath=false", "diff", "--no-ext-diff", "--no-color",
        "--unified=0", base, "--",
    )
    ranges: dict[str, list[tuple[int, int]]] = {}
    current_path: str | None = None
    for line in diff.splitlines():
        if line.startswith("+++ "):
            marker = line[4:]
            current_path = None if marker == "/dev/null" else marker.removeprefix("b/")
            continue
        match = HUNK_RE.match(line)
        if match and current_path:
            start = int(match.group(1))
            count = int(match.group(2) or "1")
            if count:
                ranges.setdefault(current_path, []).append((start, start + count - 1))
    for path in git(root, "ls-files", "--others", "--exclude-standard").splitlines():
        candidate = root / path
        if candidate.is_file():
            count = len(candidate.read_text(encoding="utf-8", errors="replace").splitlines())
            if count:
                ranges[path] = [(1, count)]
    return ranges


def intersects(start: int, count: int, ranges: list[tuple[int, int]]) -> bool:
    end = start + count - 1
    return any(start <= range_end and end >= range_start for range_start, range_end in ranges)


def scan(root: Path, max_lines: int, diff_base: str | None) -> dict[str, object]:
    changed = changed_ranges(root, diff_base) if diff_base else None
    blocks: list[dict[str, object]] = []
    hashes: dict[str, list[dict[str, object]]] = {}
    for relative in git_files(root):
        if Path(relative).suffix.lower() not in CODE_EXT:
            continue
        if changed is not None and relative not in changed:
            continue
        for line, count, text in blocks_in(root / relative):
            if count <= max_lines:
                continue
            if changed is not None and not intersects(line, count, changed[relative]):
                continue
            item = {"path": relative, "line": line, "lines": count, "head": line <= 3}
            blocks.append(item)
            normalized = re.sub(r"\s+", " ", text).strip().lower()
            if len(normalized) > 80:
                digest = hashlib.sha1(normalized.encode()).hexdigest()[:10]
                hashes.setdefault(digest, []).append(item)
    duplicates = [
        {"hash": digest, "occurrences": occurrences}
        for digest, occurrences in sorted(hashes.items())
        if len({str(item["path"]) for item in occurrences}) >= 2
    ]
    blocks.sort(key=lambda item: (str(item["path"]), int(item["line"])))
    return {
        "root": str(root.resolve()),
        "max_lines": max_lines,
        "diff_base": diff_base,
        "summary": {"blocks": len(blocks), "duplicate_groups": len(duplicates)},
        "blocks": blocks,
        "duplicates": duplicates,
        "limitations": [
            "Candidates use syntax, length, duplication and changed-line intersection; they are not defects.",
            "Triple-quoted data strings may be classified as docstrings.",
            "Deleted comments are absent from the current tree and are not reported.",
        ],
    }


def print_text(report: dict[str, object]) -> None:
    blocks = report["blocks"]
    duplicates = report["duplicates"]
    scope = f" diff={report['diff_base']}" if report["diff_base"] else ""
    print(f"comment/docstring blocks > {report['max_lines']} lines:{scope} {len(blocks)}")
    by_dir: dict[str, int] = {}
    for item in blocks:
        path = str(item["path"])
        directory = "/".join(path.split("/")[:2])
        by_dir[directory] = by_dir.get(directory, 0) + 1
    for directory, count in sorted(by_dir.items(), key=lambda pair: (-pair[1], pair[0])):
        print(f"  {count:5d}  {directory}")
    print("\ntop 15 longest ([head] = file-top docstring; inspect before classifying):")
    for item in sorted(blocks, key=lambda value: int(value["lines"]), reverse=True)[:15]:
        head = " [head]" if item["head"] else ""
        print(f"  {item['lines']:3d}L  {item['path']}:{item['line']}{head}")
    print(f"\nverbatim duplicates across files: {len(duplicates)} groups")
    for group in duplicates:
        occurrences = group["occurrences"][:6]
        joined = " · ".join(f"{item['path']}:{item['line']}" for item in occurrences)
        print(f"  x{len(group['occurrences'])}  {joined}")
    print("\nlimitations:")
    for limitation in report["limitations"]:
        print(f"  - {limitation}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("repo_root", nargs="?", type=Path)
    parser.add_argument("--max", type=int, dest="max_lines")
    parser.add_argument("--diff", metavar="BASE")
    parser.add_argument("--format", choices=("text", "json"), default="text")
    args = parser.parse_args()
    if args.max_lines is not None and args.max_lines < 0:
        parser.error("--max must be zero or greater")
    max_lines = args.max_lines if args.max_lines is not None else (0 if args.diff else 2)
    try:
        root = args.repo_root or Path(git(Path.cwd(), "rev-parse", "--show-toplevel").strip())
        report = scan(root.resolve(), max_lines, args.diff)
    except (OSError, ValueError) as exc:
        print(f"comment audit scan failed: {exc}", file=sys.stderr)
        return 2
    if args.format == "json":
        json.dump(report, sys.stdout, ensure_ascii=False, indent=2)
        print()
    else:
        print_text(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
