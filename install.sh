#!/usr/bin/env bash
# install.sh — link dotfiles เข้าเครื่องนี้ (ทุก OS — Windows ใช้ผ่าน Git Bash) — idempotent
set -euo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"

is_windows() { case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) return 0 ;; *) return 1 ;; esac; }
# NOTE: cmd ผ่าน Git Bash ห้ามมี quotes ฝังใน string (MSYS mangle) — no-space = mklink,
# มี space = fallback powershell
make_link() {
  if is_windows; then
    local w1 w2
    w1="$(cygpath -w "$1")"; w2="$(cygpath -w "$2")"
    case "$w1$w2" in
      *" "*) powershell -NoProfile -Command "New-Item -ItemType Junction -Path '$w1' -Target '$w2'" > /dev/null ;;
      *) cmd //c "mklink /J $w1 $w2" > /dev/null ;;
    esac
  else
    ln -s "$2" "$1"
  fi
}

# skills: link รายตัว claude/skills/<name> → ~/.claude/skills/<name>
# (ตัว dir skills เป็นของ harness — ห้าม link ทั้งก้อน)
# group skills (มี sub ที่มี SKILL.md ชั้นใน): harness ไม่ scan nested (ground-truth
# 2026-07-17, docs/claude-code-mechanisms.md §grouping) → ต้อง link แบนรายตัว
# เป็นชื่อ <group>-<sub> ด้วย; ชื่อ invoke จริงมาจาก frontmatter name (มี colon ได้)
mkdir -p "$HOME/.claude/skills"
for sub in "$REPO"/claude/skills/*/*/SKILL.md; do
  [ -f "$sub" ] || continue
  subdir="$(dirname "$sub")"
  gname="$(basename "$(dirname "$subdir")")-$(basename "$subdir")"
  link="$HOME/.claude/skills/$gname"
  if [ -L "$link" ]; then
    echo "skill $gname: link exists - skipped"
  else
    [ -d "$link" ] && { mv "$link" "$link.bak-pre-dotfiles"; echo "skill $gname: backed up old dir"; }
    make_link "$link" "$subdir"
    echo "skill $gname: linked"
  fi
done
for d in "$REPO"/claude/skills/*/; do
  name="$(basename "$d")"
  link="$HOME/.claude/skills/$name"
  if [ -L "$link" ]; then
    echo "skill $name: link exists - skipped"
  else
    [ -d "$link" ] && { mv "$link" "$link.bak-pre-dotfiles"; echo "skill $name: backed up old dir"; }
    make_link "$link" "${d%/}"
    echo "skill $name: linked"
  fi
done

# rules: link ทั้ง dir → dotfiles
# (agents จงใจไม่ทำที่นี่ — owner จัดการ link เองต่อเครื่อง, decision 2026-07-12)
src="$REPO/claude/rules"
link="$HOME/.claude/rules"
if [ -L "$link" ]; then
  echo "rules: link exists - skipped"
else
  if [ -d "$link" ]; then
    for f in "$link"/*; do
      [ -f "$f" ] || continue
      base="$(basename "$f")"
      [ -f "$src/$base" ] || { cp "$f" "$src/"; echo "rules: merged into repo: $base"; }
    done
    mv "$link" "$link.bak-pre-dotfiles"
    echo "rules: backed up old dir"
  fi
  make_link "$link" "$src"
  echo "rules: linked"
fi

echo
echo "done."
