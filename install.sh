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

rules_source="$REPO/claude/rules"
rules_target="$HOME/.claude/rules"
backup_legacy_rules_and_stop() {
  [ -d "$rules_target" ] && [ ! -L "$rules_target" ] || return 0

  local backup_path="$rules_target.bak-pre-dotfiles"
  local backup_index=1
  while [ -e "$backup_path" ] || [ -L "$backup_path" ]; do
    backup_path="$rules_target.bak-pre-dotfiles-$backup_index"
    backup_index=$((backup_index + 1))
  done

  mv "$rules_target" "$backup_path"
  echo "rules: legacy directory backed up to $backup_path" >&2
  echo "rules: stopped before linking; classify any rules to keep under claude/rules/{core,engineering,risk}/, then rerun install.sh" >&2
  exit 1
}

# Preflight before linking skills: legacy flat rules require human classification into owner folders.
backup_legacy_rules_and_stop

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

# rules: link ทั้ง recursive tree → dotfiles
# (agents จงใจไม่ทำที่นี่ — owner จัดการ link เองต่อเครื่อง, decision 2026-07-12)
backup_legacy_rules_and_stop
if [ -L "$rules_target" ]; then
  echo "rules: link exists - skipped"
else
  make_link "$rules_target" "$rules_source"
  echo "rules: linked"
fi

echo
echo "done."
