#!/usr/bin/env python3
"""Broken-reference checker: md<->md links, md->code paths, code->docs pointers.

Usage: python check.py [repo_root]   (default: git root of cwd)
Exit: 0 clean, 1 broken refs found. Output: one line per finding, grouped.

Shorthand resolution (กัน false positive จม signal):
  1. per-file base:  <!-- linkcheck-base: path/one path/two -->  ใน md ไหนก็ได้
     = เพิ่ม base dir ให้ทุก reference ในไฟล์นั้น
  2. unique-suffix:  target ที่ match หางไฟล์ tracked เพียงไฟล์เดียว = ถือว่า resolve ได้
     (match หลายไฟล์ = ยัง BROKEN — ambiguous ต้องเขียนเต็ม)
  3. per-file branch: <!-- linkcheck-branch: feature/x -->  = ไฟล์ที่อยู่บน branch นั้น
     (git ls-tree) รายงานเป็น [INFO] on-branch แทน BROKEN (งานยังไม่ merge — ไม่ใช่ลิงก์ผี)

Anchor check: md link ที่มี #fragment ไปไฟล์ .md → heading ที่ slug ตรงต้องมีจริง
ในไฟล์ปลายทาง (GitHub-style slug, unicode ok) — ไม่มี = BROKEN bad-anchor
"""
import os, re, subprocess, sys

# Windows console (cp874) พิมพ์อักขระนอก charset ไม่ได้ — บังคับ utf-8
sys.stdout.reconfigure(encoding="utf-8", errors="replace")


def git_files(root):
    """Tracked + untracked-unignored files, relative paths with forward slashes."""
    out = subprocess.run(["git", "-C", root, "ls-files", "-c", "-o", "--exclude-standard"],
                         capture_output=True, text=True, encoding="utf-8")
    return [l.strip() for l in out.stdout.splitlines() if l.strip()]


BASE_DECL = re.compile(r"<!--\s*linkcheck-base:\s*([^>]+?)\s*-->")
# per-file: อ้างไฟล์ที่อยู่บน branch อื่น (เช่น doc ของงานใน feature branch ที่ยังไม่ merge)
BRANCH_DECL = re.compile(r"<!--\s*linkcheck-branch:\s*([^>\s]+)\s*-->")
PLACEHOLDER = re.compile(r"[<>*{}]|\.\.\.|ฯลฯ|x{2,}|<topic>|<id>|<name>|<scope>")
MD_LINK = re.compile(r"\[[^\]]*\]\(([^)#\s]+)(#[^)\s]*)?\)")
WIKI = re.compile(r"\[\[([a-z0-9-]+)\]\]")
# path-like token ใน backtick: มี / และลงท้ายดูเป็นไฟล์/dir ที่ควรมีจริง
TICK = re.compile(r"`([A-Za-z0-9_.~/\\-]+/[A-Za-z0-9_.\\-]+(?:\.[A-Za-z0-9]+|/))`")
# pointer ใน comment ของ code: docs/... หรือ *.md
CODE_PTR = re.compile(r"(?:#|//|<!--)\s*.*?((?:docs|memory)/[A-Za-z0-9_./-]+\.md)")


def norm(base_dir, target):
    # strip a leading "./" prefix only — lstrip("./") is a charset strip and
    # eats the dot of ".claude/..." -> false broken on dotdirs
    t = re.sub(r"^(\./)+", "", target.replace("\\", "/"))
    cand = os.path.normpath(os.path.join(base_dir, t)).replace("\\", "/")
    return [cand, t]  # ลองทั้ง relative-to-file และ relative-to-root


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else subprocess.run(
        ["git", "rev-parse", "--show-toplevel"], capture_output=True,
        text=True).stdout.strip()
    files = git_files(root)
    # .linkcheck-ignore ที่ root: regex ต่อบรรทัด match กับ "file -> target" (# = comment)
    ig_path = os.path.join(root, ".linkcheck-ignore")
    ignores = []
    if os.path.exists(ig_path):
        for l in open(ig_path, encoding="utf-8"):
            l = l.strip()
            if l and not l.startswith("#"):
                ignores.append(re.compile(l))
    fileset = set(f.replace("\\", "/") for f in files)
    dirset = {os.path.dirname(f) for f in fileset} | {f for f in fileset}
    mem_names = {os.path.splitext(os.path.basename(f))[0]
                 for f in fileset if "/memory/" in f or f.startswith("memory/")}
    findings = []

    def ignored(file, target):
        line = f"{file} -> {target}"
        return any(p.search(line) for p in ignores)

    # index หางไฟล์+dir สำหรับ unique-suffix resolution
    suffix_count = {}
    for fp in fileset | dirset:
        parts = [p for p in fp.split("/") if p]
        for k in range(1, len(parts)):
            suf = "/".join(parts[-k:])
            suffix_count[suf] = suffix_count.get(suf, 0) + 1

    _ign_cache = {}
    def gitignored(t):
        # path ที่ .gitignore ครอบ = จงใจไม่ track (docs/private, coverage ฯลฯ)
        # การมีอยู่ขึ้นกับเครื่อง → ไม่นับ broken
        if t not in _ign_cache:
            # ลองทั้งแบบมี/ไม่มี trailing slash — pattern dir-only (`x/`) จะ match
            # เฉพาะแบบมี slash เมื่อ dir ไม่มีอยู่จริงบนดิสก์
            ok = False
            for v in (t, t + "/"):
                if subprocess.run(["git", "-C", root, "check-ignore", "-q", v]).returncode == 0:
                    ok = True
                    break
            _ign_cache[t] = ok
        return _ign_cache[t]

    def exists(base_dir, target, extra_bases=()):
        if target.startswith(("http://", "https://", "mailto:", "/")):
            return True  # leading "/" = URL route ไม่ใช่ path ในไฟล์ระบบของ repo
        if PLACEHOLDER.search(target):
            return True
        t = re.sub(r"^(\./)+", "", target.replace("\\", "/")).rstrip("/")
        cands = norm(base_dir, target) + [
            os.path.normpath(os.path.join(b, t)).replace("\\", "/") for b in extra_bases]
        for c in cands:
            c = c.rstrip("/")
            if c in fileset or c in dirset or os.path.exists(os.path.join(root, c)):
                return True
        return suffix_count.get(t, 0) == 1  # unique-suffix shorthand

    HEADING = re.compile(r"^#{1,6}\s+(.*)$")
    _slug_cache = {}

    def slugs_of(md):
        """set ของ GitHub-style heading slugs ในไฟล์ md (fence ไม่นับ, dup ได้ -1 -2)"""
        if md not in _slug_cache:
            s, seen, fence = set(), {}, False
            try:
                lines = open(os.path.join(root, md), encoding="utf-8",
                             errors="replace").read().splitlines()
            except Exception:
                lines = []
            for l in lines:
                if l.strip().startswith("```"):
                    fence = not fence
                    continue
                m = HEADING.match(l)
                if not m or fence:
                    continue
                # ตัด formatting markers — เก็บ "_" (GitHub เก็บ literal _ เช่น snake_case;
                # trade-off: heading แบบ _emphasis_ จะ slug ต่างจาก GitHub — พบน้อยกว่ามาก)
                t = re.sub(r"[`*]|\[|\]|\(|\)", "", m.group(1).strip()).lower()
                # ตัดเฉพาะ ASCII punct — \w ไม่รวม combining mark (วรรณยุกต์ไทย) ห้ามใช้กรอง
                t = "".join(c for c in t if not c.isascii() or c.isalnum()
                            or c.isspace() or c in "-_")
                # GitHub slugger: แต่ละ space → dash ไม่ collapse; รับแบบ collapse ด้วย (คนเขียนมือ)
                slug = re.sub(r"\s", "-", t)
                n = seen.get(slug, 0)
                seen[slug] = n + 1
                s.add(slug if n == 0 else f"{slug}-{n}")
                s.add(re.sub(r"\s+", "-", t.strip()))
            _slug_cache[md] = s
        return _slug_cache[md]

    def resolve_md(base_dir, target, extra_bases):
        """path จริงใน fileset ของ target (รวม unique-suffix) — None ถ้าไม่เจอ"""
        t = re.sub(r"^(\./)+", "", target.replace("\\", "/")).rstrip("/")
        for c in norm(base_dir, target) + [
                os.path.normpath(os.path.join(b, t)).replace("\\", "/") for b in extra_bases]:
            if c.rstrip("/") in fileset:
                return c.rstrip("/")
        if suffix_count.get(t, 0) == 1:
            for fp in fileset:
                if fp == t or fp.endswith("/" + t):
                    return fp
        return None

    _branch_cache = {}
    def branch_files(branch):
        """set path บน branch นั้น (git ls-tree) — branch ไม่มีจริง → set ว่าง (decl เงียบ)"""
        if branch not in _branch_cache:
            r = subprocess.run(["git", "-C", root, "ls-tree", "-r", "--name-only", branch],
                               capture_output=True, text=True, encoding="utf-8")
            _branch_cache[branch] = set(r.stdout.splitlines()) if r.returncode == 0 else set()
        return _branch_cache[branch]

    my_email = subprocess.run(["git", "-C", root, "config", "user.email"],
                              capture_output=True, text=True).stdout.strip()

    def line_author(f, i):
        """email ของคนเขียนบรรทัดนั้น (None ถ้า untracked/blame ไม่ได้)"""
        r = subprocess.run(["git", "-C", root, "blame", "-L", f"{i},{i}",
                            "--line-porcelain", f], capture_output=True,
                           text=True, encoding="utf-8", errors="replace")
        for l in r.stdout.splitlines():
            if l.startswith("author-mail "):
                return l.split(" ", 1)[1].strip("<>")
        return None

    def record(kind, f, i, target, extra=(), branches=()):
        if ignored(f, target):
            return
        # pointer ชี้ home dir ส่วนตัว (~/.claude ฯลฯ) ลง repo = เครื่องอื่น/CI ไม่มี
        # → WARN เสมอ (repo ที่อ้างได้ถูกต้อง เช่น dotfiles เอง ใช้ .linkcheck-ignore)
        if target.replace("\\", "/").startswith(("~", "$HOME", "C:/Users", "/home/", "/Users/")):
            findings.append(("home-path", f, i, target))
            return
        if exists(os.path.dirname(f), target, extra):
            return
        t = re.sub(r"^(\./)+", "", target.replace("\\", "/")).rstrip("/")
        for b in branches:
            bf = branch_files(b)
            cand = [t, os.path.normpath(os.path.join(os.path.dirname(f), t)).replace("\\", "/")]
            if any(c in bf or any(x.startswith(c + "/") for x in bf) for c in cand):
                findings.append(("on-branch", f, i, f"{target} (branch: {b})"))
                return
        if gitignored(t):
            # private/gitignored: มีจริงหรือไม่ขึ้นกับเครื่อง — ไม่นับพัง
            # author ของบรรทัด = user ปัจจุบัน → ของตัวเองที่ไม่อยู่ = ยกเป็น WARN
            # (แยก "เครื่องไหน" ไม่ได้ — email เดียวข้ามเครื่อง — แยกได้แค่ ของคุณ/ของคนอื่น)
            a = line_author(f, i)
            if a and my_email and a == my_email:
                findings.append(("private-yours", f, i, target))
            else:
                findings.append(("private-local", f, i, target))
        else:
            findings.append((kind, f, i, target))

    for f in files:
        p = os.path.join(root, f)
        ext = os.path.splitext(f)[1].lower()
        base = os.path.dirname(f)
        try:
            text = open(p, encoding="utf-8", errors="replace").read()
        except Exception:
            continue
        extra = []
        for m in BASE_DECL.finditer(text):
            extra += m.group(1).split()
        branches = BRANCH_DECL.findall(text)
        if ext == ".md":
            in_fence = False
            for i, line in enumerate(text.splitlines(), 1):
                if line.strip().startswith("```"):
                    in_fence = not in_fence
                    continue
                for m in MD_LINK.finditer(line):
                    record("md-link", f, i, m.group(1), extra, branches)
                    a = m.group(2)
                    if (a and len(a) > 1 and m.group(1).endswith(".md")
                            and not PLACEHOLDER.search(a) and not re.match(r"#l\d+$", a.lower())):
                        tgt = resolve_md(base, m.group(1), extra)
                        if (tgt is not None and a[1:].lower() not in slugs_of(tgt)
                                and not ignored(f, m.group(1) + a)):
                            findings.append(("bad-anchor", f, i, m.group(1) + a))
                for m in WIKI.finditer(line):
                    if m.group(1) not in mem_names:
                        # wiki-link ที่ยังไม่มีไฟล์ = อนุญาตตามกติกา memory แต่รายงานเป็น info
                        findings.append(("wiki-pending", f, i, m.group(1)))
                if in_fence:
                    continue
                for m in TICK.finditer(line):
                    record("md-path", f, i, m.group(1), extra, branches)
        elif ext in (".py", ".sh", ".js", ".ts", ".ps1", ".yml", ".yaml", ".json"):
            for i, line in enumerate(text.splitlines(), 1):
                for m in CODE_PTR.finditer(line):
                    record("code-ptr", f, i, m.group(1), (), branches)

    soft = ("wiki-pending", "private-local", "private-yours", "on-branch", "home-path")
    hard = [x for x in findings if x[0] not in soft]
    for kind, f, i, t in sorted(findings):
        tag = ("WARN" if kind in ("private-yours", "home-path")
               else "INFO" if kind in soft else "BROKEN")
        print(f"[{tag}] {kind:13s} {f}:{i}  ->  {t}")
    n_yours = sum(1 for x in findings if x[0] == "private-yours")
    n_priv = sum(1 for x in findings if x[0] == "private-local")
    n_wiki = sum(1 for x in findings if x[0] == "wiki-pending")
    n_br = sum(1 for x in findings if x[0] == "on-branch")
    n_home = sum(1 for x in findings if x[0] == "home-path")
    if n_home:
        print(f"\n[!] {n_home} home-path: pointer ชี้ path ส่วนตัว (~/.claude ฯลฯ) — "
              "เครื่องอื่น/CI ไม่มี; แทนด้วยสาระหรือ docs ใน repo (จงใจ = .linkcheck-ignore)")
    print(f"\n{len(hard)} broken, {n_yours} private-yours (คุณอ้างเองแต่ไม่อยู่เครื่องนี้), "
          f"{n_priv} private (ของคนอื่น), {n_br} on-branch (อยู่ branch อื่น ยังไม่ merge), "
          f"{n_wiki} pending wiki-links, {len(files)} files scanned")
    sys.exit(1 if hard else 0)


if __name__ == "__main__":
    main()
