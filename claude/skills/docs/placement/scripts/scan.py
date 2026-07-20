#!/usr/bin/env python3
"""Comment/docstring debt scanner — deterministic eyes for /docs:placement remediation.

Usage: python scan.py [repo_root] [--max N]   (default: git root, N=2)
Finds: (a) comment/docstring blocks longer than N lines  (b) near-verbatim
duplicate blocks across >=2 files (cheapest debt — fix first).
Output: per-dir summary + top blocks by length + duplicate groups. Read-only;
classification (กฎ vs เรื่องเล่า) is the LLM's job, not this script's.
Known noise: triple-quoted *data* strings (prompts, SQL) count as blocks —
another reason findings are leads to judge, never auto-fix targets.
"""
import hashlib, os, re, subprocess, sys

# Windows console (cp874) ตาย ๆ กับอักขระนอก charset — บังคับ utf-8 ที่ stdout
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

CODE_EXT = {".py", ".sh", ".ps1", ".js", ".jsx", ".ts", ".tsx", ".go", ".java",
            ".cs", ".rb", ".php", ".c", ".h", ".cpp", ".rs", ".kt", ".swift"}
LINE_MARK = re.compile(r"^\s*(#|//)\s?(.*)$")
BLOCK_OPEN = re.compile(r"^\s*(/\*|\"\"\"|''')")
BLOCK_CLOSE = {"/*": "*/", '"""': '"""', "'''": "'''"}


def git_files(root):
    out = subprocess.run(["git", "-C", root, "ls-files", "-c", "-o", "--exclude-standard"],
                         capture_output=True, text=True, encoding="utf-8")
    return [l.strip() for l in out.stdout.splitlines() if l.strip()]


def blocks_in(path):
    """yield (start_line, n_lines, normalized_text) ของทุก comment/docstring block"""
    try:
        lines = open(path, encoding="utf-8", errors="replace").read().splitlines()
    except Exception:
        return
    i, n = 0, len(lines)
    while i < n:
        m = LINE_MARK.match(lines[i])
        if m and not lines[i].strip().startswith("#!"):
            start, buf = i, []
            while i < n and (mm := LINE_MARK.match(lines[i])):
                buf.append(mm.group(2))
                i += 1
            yield start + 1, i - start, "\n".join(buf)
            continue
        b = BLOCK_OPEN.match(lines[i])
        if b:
            opener = b.group(1)
            closer = BLOCK_CLOSE[opener]
            start, buf = i, [lines[i]]
            if closer in lines[i][lines[i].find(opener) + len(opener):]:
                i += 1
                yield start + 1, 1, buf[0].strip()
                continue
            i += 1
            while i < n and closer not in lines[i]:
                buf.append(lines[i])
                i += 1
            if i < n:
                buf.append(lines[i])
                i += 1
            yield start + 1, len(buf), "\n".join(l.strip(" \t*/") for l in buf)
            continue
        i += 1


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    root = args[0] if args else subprocess.run(
        ["git", "rev-parse", "--show-toplevel"], capture_output=True,
        text=True).stdout.strip()
    max_len = 2
    for j, a in enumerate(sys.argv):
        if a == "--max" and j + 1 < len(sys.argv):
            max_len = int(sys.argv[j + 1])

    over, dup = [], {}
    for f in git_files(root):
        if os.path.splitext(f)[1].lower() not in CODE_EXT:
            continue
        for line, nlines, text in blocks_in(os.path.join(root, f)):
            norm = re.sub(r"\s+", " ", text).strip().lower()
            if nlines > max_len:
                over.append((nlines, f, line))
            if nlines > max_len and len(norm) > 80:
                dup.setdefault(hashlib.sha1(norm.encode()).hexdigest()[:10],
                               []).append((f, line, nlines))

    by_dir = {}
    for nlines, f, _ in over:
        d = "/".join(f.split("/")[:2])
        by_dir[d] = by_dir.get(d, 0) + 1
    print(f"comment/docstring blocks > {max_len} lines: {len(over)}")
    for d, c in sorted(by_dir.items(), key=lambda x: -x[1]):
        print(f"  {c:5d}  {d}")
    print("\ntop 15 longest ([head] = file-top docstring — likely legit contract, judge before touching):")
    for nlines, f, line in sorted(over, reverse=True)[:15]:
        tag = " [head]" if line <= 3 else ""
        print(f"  {nlines:3d}L  {f}:{line}{tag}")
    groups = [(k, v) for k, v in dup.items() if len({x[0] for x in v}) >= 2]
    print(f"\nverbatim duplicates across files: {len(groups)} groups (fix first — cheapest)")
    for k, v in sorted(groups, key=lambda x: -len(x[1])):
        print(f"  x{len(v)}  " + " · ".join(f"{f}:{l}" for f, l, _ in v[:6]))


if __name__ == "__main__":
    main()
