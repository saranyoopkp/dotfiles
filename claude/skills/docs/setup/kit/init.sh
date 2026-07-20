#!/usr/bin/env bash
# init.sh — setup docs system ให้ repo (ทุก OS — Windows ใช้ผ่าน Git Bash)
# usage: bash init.sh /path/to/repo [ProjectName]
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"
TARGET="$(cd "$1" && pwd)"
NAME="${2:-$(basename "$TARGET")}"

is_windows() { case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) return 0 ;; *) return 1 ;; esac; }

# make_link <link> <target-dir> — junction บน Windows, symlink บน unix
# NOTE: cmd ผ่าน Git Bash ห้ามมี quotes ฝังใน string (MSYS mangle จน mklink พัง —
# ทดสอบแล้ว); path ไม่มี space = mklink ตรง ๆ, มี space = fallback powershell
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

# 1) CLAUDE.md (ไม่ทับของเดิม)
if [ ! -f "$TARGET/CLAUDE.md" ]; then
  sed "s/<ProjectName>/$NAME/g" "$KIT/CLAUDE.template.md" > "$TARGET/CLAUDE.md"
  echo "created CLAUDE.md"
else
  echo "CLAUDE.md exists - skipped (merge section 'Memory policy' จาก CLAUDE.template.md เอง)"
fi

# 2) memory/ + docs/ + private dirs + .gitignore
if [ ! -d "$TARGET/memory" ]; then
  cp -R "$KIT/memory" "$TARGET/memory"
  echo "created memory/"
else
  echo "memory/ exists - skipped"
fi
mkdir -p "$TARGET/docs/private" "$TARGET/memory/private"
if ! grep -qs 'docs/private/' "$TARGET/.gitignore"; then
  printf '\n# docs-setup: local-only private/sensitive files (never committed)\ndocs/private/\nmemory/private/\n' >> "$TARGET/.gitignore"
  echo "added docs/private/ + memory/private/ to .gitignore"
fi

# 3) lifecycle hooks: .claude/hooks/ + settings.json (docs-drift enforcement)
# atomic write (tmp + mv) — cp ทับตรง ๆ เคยชน Stop hook ของ session ที่รันอยู่
# = transient "No such file or directory" (race จริง 2026-07-12)
mkdir -p "$TARGET/.claude/hooks"
for H in docs-drift; do
  cp "$KIT/hooks/$H.sh" "$TARGET/.claude/hooks/.$H.sh.tmp"
  chmod +x "$TARGET/.claude/hooks/.$H.sh.tmp" 2>/dev/null || true
  mv -f "$TARGET/.claude/hooks/.$H.sh.tmp" "$TARGET/.claude/hooks/$H.sh"
  echo "installed .claude/hooks/$H.sh"
done
# settings.json เป็น static template ล้วน ไม่ต้อง localize ต่อเครื่อง — hook script
# เอง normalize backslash→forward-slash ด้วย `tr` ก่อน exec ตัวเอง (กัน Windows
# multi-bash PATH ambiguity + JSON/harness backslash-eating โดยไม่ต้องพึ่ง absolute
# path เฉพาะเครื่องหรือ cygpath/perl — no-op บน unix ที่ไม่มี backslash อยู่แล้ว)
if [ ! -f "$TARGET/.claude/settings.json" ]; then
  cp "$KIT/hooks/settings.json" "$TARGET/.claude/settings.json"
  echo "created .claude/settings.json (lifecycle hooks)"
elif grep -q 'docs-drift\.ps1' "$TARGET/.claude/settings.json"; then
  echo "MIGRATION NEEDED: .claude/settings.json ยังชี้ docs-drift.ps1 (รุ่นเก่าก่อน bash-only)"
  echo "  -> อัปเดต hook entries เป็นแบบ kit/hooks/settings.json (bash) และลบ .claude/hooks/docs-drift.ps1"
elif ! grep -q "show-toplevel" "$TARGET/.claude/settings.json"; then
  # เช็ค marker "show-toplevel" (git-root fallback) แทนเครื่องมือ normalize
  # backslash (tr/sed/perl) เพราะตัวหลังเปลี่ยนได้ทุกครั้งที่แก้ kit — เจอ mismatch
  # จริง (kit สลับ tr -> sed แต่ check ยังหา tr = MIGRATION NEEDED ผิดทุก repo) 2026-07-13
  echo "MIGRATION NEEDED: .claude/settings.json ยังเป็น hook path resolution รุ่นเก่า"
  echo "  -> แทนที่ args ของทุก hook event ด้วยรูปแบบใน kit/hooks/settings.json ปัจจุบัน"
else
  echo ".claude/settings.json exists - skipped (merge hooks from kit/hooks/settings.json เอง)"
fi
# 3b) settings.local.json = per-machine harness settings (permission ที่ approve ไว้,
# env, agent/model override) — harness เขียนเอง, kit ไม่แตะเนื้อใน แค่กันไม่ให้ commit
# (เคยมี acv-gate wire ไว้ที่นี่ — ถอดออก 2026-07-17 ดู kit/README.md)
if ! grep -qs 'settings\.local\.json' "$TARGET/.gitignore"; then
  printf '\n# docs-setup: per-machine harness settings (never committed)\n.claude/settings.local.json\n' >> "$TARGET/.gitignore"
  echo "added .claude/settings.local.json to .gitignore"
fi

# เก็บกวาด hook script รุ่น powershell ถ้า settings ไม่ได้ใช้แล้ว
if [ -f "$TARGET/.claude/hooks/docs-drift.ps1" ] && ! grep -q 'docs-drift\.ps1' "$TARGET/.claude/settings.json" 2>/dev/null; then
  rm "$TARGET/.claude/hooks/docs-drift.ps1"
  echo "removed obsolete .claude/hooks/docs-drift.ps1"
fi

# 4) link: harness memory dir → repo memory/ (memory ตัวจริงชุดเดียวอยู่ใน repo)
#    <id> = OS-native absolute path โดยแทนอักขระที่ไม่ใช่ a-z/0-9 ด้วย '-'
if is_windows; then NATIVE="$(cygpath -w "$TARGET")"; else NATIVE="$TARGET"; fi
ID="$(printf '%s' "$NATIVE" | sed 's/[^A-Za-z0-9]/-/g')"
HARNESS="$HOME/.claude/projects/$ID/memory"
mkdir -p "$(dirname "$HARNESS")"

if [ -L "$HARNESS" ]; then
  echo "harness memory link exists - skipped ($(readlink "$HARNESS"))"
else
  if [ -d "$HARNESS" ]; then
    # มี dir เดิม: ย้ายไฟล์ที่ repo ยังไม่มีเข้า repo ก่อน แล้วเก็บของเดิมเป็น .bak
    for f in "$HARNESS"/*; do
      [ -f "$f" ] || continue
      base="$(basename "$f")"
      [ -f "$TARGET/memory/$base" ] || { cp "$f" "$TARGET/memory/"; echo "merged into repo: $base"; }
    done
    mv "$HARNESS" "$HARNESS.bak-pre-link"
    echo "backed up old harness memory -> memory.bak-pre-link"
  fi
  make_link "$HARNESS" "$TARGET/memory"
  echo "created link: $HARNESS -> $TARGET/memory"
fi

echo
echo "done. ถัดไป: เติม CLAUDE.md ตาม placeholder + เขียน fact แรกลง memory/ (commit memory ใหม่เป็นระยะ; sensitive ลง docs/private/)"
