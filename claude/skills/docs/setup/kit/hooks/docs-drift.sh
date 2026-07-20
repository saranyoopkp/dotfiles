#!/usr/bin/env bash
# docs-drift.sh — docs-setup lifecycle hook (ทุก OS — Windows รันผ่าน Git Bash)
# Called from .claude/settings.json with $1 = SessionStart|Stop|TaskCompleted|PreCompact
# (FileChanged case ยังอยู่ด้านล่างแต่ "not wired" — harness ไม่เคย fire event นี้จริง
# แม้ documented ไว้; ทดสอบยิงจริง 3 ช่องทางแล้วเงียบทุกครั้ง 2026-07-12 — เก็บ dead
# code ไว้เผื่อ harness รองรับอนาคต, ห้ามใส่กลับ settings.json จนกว่าจะพิสูจน์ว่าทำงาน)
set -u
EVENT="${1:-}"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
[ -n "$ROOT" ] || exit 0
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    NATIVE="$(cygpath -w "$ROOT")"   # id ต้องมาจาก path แบบ OS-native (ตรงกับที่ harness ใช้)
    ROOT="$(cygpath -u "$ROOT")" ;;  # file ops ใน bash ใช้ unix style
  *) NATIVE="$ROOT" ;;
esac
ID="$(printf '%s' "$NATIVE" | sed 's/[^A-Za-z0-9]/-/g')"

DRIFT="$(git -C "$ROOT" status --porcelain -- CLAUDE.md docs memory 2>/dev/null | sed 's/^ *//' | paste -sd ';' -)"

json_escape() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

emit() { # $1 = context text, $2 = extra json fields (optional, starts with ,)
  printf '{"hookSpecificOutput":{"hookEventName":"%s","additionalContext":"%s"%s}}\n' \
    "$EVENT" "$(json_escape "$1")" "${2:-}"
}

case "$EVENT" in
  SessionStart)
    PARTS=""
    [ -n "$DRIFT" ] && PARTS="[docs-setup] Uncommitted docs/memory left over from a previous session: $DRIFT. Curate (strip personal metadata like originSessionId, verify no secrets) and commit before starting new work."
    if [ -f "$ROOT/CLAUDE.md" ]; then
      LINES="$(wc -l < "$ROOT/CLAUDE.md" | tr -d ' ')"
      if [ "$LINES" -gt 200 ]; then
        PARTS="$PARTS [docs-setup] CLAUDE.md is $LINES lines (>200) - it is loaded in full every session. Promote oversized sections (>~15 lines) into docs/<topic>.md or memory/ and leave 1-3 line summaries + links."
      fi
    fi
    # link check — เตือนเฉพาะเมื่อ "พิสูจน์ได้ว่าไม่ link" เท่านั้น (fail-safe:
    # env แปลก เช่น bash ตัวอื่น/HOME ไม่ตรง → เงียบ ไม่ปล่อย false positive);
    # เกณฑ์จริงคือ same-file (-ef) ไม่ใช่แค่ -L เพราะ junction detection ต่างกันตาม env
    MEM="$HOME/.claude/projects/$ID/memory"
    if [ -d "$ROOT/memory" ] && [ -d "$HOME/.claude/projects" ] && [ -e "$MEM" ]; then
      if ! [ "$MEM" -ef "$ROOT/memory" ] && ! [ -L "$MEM" ]; then
        PARTS="$PARTS [docs-setup] Harness memory dir exists but is NOT linked to this repo's memory/ (separate copies will drift). Re-run the docs-setup init script to relink (see CLAUDE.md 'Memory policy')."
      fi
    fi
    native_path() { case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) cygpath -w "$1" ;; *) printf '%s' "$1" ;; esac; }
    WATCH=""
    [ -f "$ROOT/CLAUDE.md" ] && WATCH="\"$(json_escape "$(native_path "$ROOT/CLAUDE.md")")\""
    if [ -f "$ROOT/memory/MEMORY.md" ]; then
      [ -n "$WATCH" ] && WATCH="$WATCH,"
      WATCH="$WATCH\"$(json_escape "$(native_path "$ROOT/memory/MEMORY.md")")\""
    fi
    emit "$PARTS" ",\"watchPaths\":[$WATCH]"
    ;;
  Stop)
    PARTS=""
    if [ -n "$DRIFT" ]; then
      STAMP="${TMPDIR:-/tmp}/docs-drift-$ID.stamp"
      HASH="$(printf '%s' "$DRIFT" | cksum | cut -d' ' -f1)"
      LAST="$(cat "$STAMP" 2>/dev/null || true)"
      if [ "$HASH" != "$LAST" ]; then
        printf '%s' "$HASH" > "$STAMP"
        PARTS="[docs-setup] Docs/memory changes are uncommitted: $DRIFT. If a piece of work just finished, update CLAUDE.md/docs to reflect it and commit docs together with the work (or propose the commit to the user)."
      fi
    fi
    # verify reminder — เตือน ณ จุดปิด turn เมื่อมี source change ค้าง (แก้ salience gap:
    # มาตรฐานตรวจรับถูกอ่านครั้งเดียวตอน session start แล้วจมใน context ยาว);
    # generic โดยเจตนา — ชี้ไปที่มาตรฐานของ agent เอง ไม่ผูกกับกลไกตรวจตัวใดตัวหนึ่ง
    SRC="$(git -C "$ROOT" status --porcelain 2>/dev/null | grep -vE '^.. (CLAUDE\.md|docs/|memory/)' | head -1)"
    if [ -n "$SRC" ]; then
      VSTAMP="${TMPDIR:-/tmp}/verify-nudge-$ID.stamp"
      VHASH="$(git -C "$ROOT" status --porcelain 2>/dev/null | grep -vE '^.. (CLAUDE\.md|docs/|memory/)' | cksum | cut -d' ' -f1)"
      VLAST="$(cat "$VSTAMP" 2>/dev/null || true)"
      if [ "$VHASH" != "$VLAST" ]; then
        printf '%s' "$VHASH" > "$VSTAMP"
        PARTS="$PARTS [verify] Uncommitted source changes at turn end. Before reporting this work as done: exercise the affected flow for runtime evidence (build/tests passing is not the same as working), and apply your agent's acceptance/review standard at the level this change's risk calls for."
      fi
    fi
    PARTS="${PARTS# }"
    [ -n "$PARTS" ] && emit "$PARTS"
    ;;
  TaskCompleted)
    MSG="[docs-setup] Task completed - checkpoint: (1) does CLAUDE.md/docs still reflect reality after this task? (2) any new memory worth saving? (3) commit doc changes together with the work. (4) verify the delivered behavior with runtime evidence and apply your acceptance/review standard before reporting done."
    [ -n "$DRIFT" ] && MSG="$MSG Currently uncommitted: $DRIFT."
    emit "$MSG"
    ;;
  PreCompact)
    # NOTE: harness rejects hookSpecificOutput.additionalContext for PreCompact
    # (docs say otherwise - live behavior wins). Use top-level systemMessage.
    printf '{"systemMessage":"[docs-setup] Compacting - persist important decisions/learnings into memory/ or docs/ now; unwritten details may be lost in the summary."}\n'
    ;;
  FileChanged)
    INPUT="$(cat)"
    FP="$(printf '%s' "$INPUT" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
    CT="$(printf '%s' "$INPUT" | sed -n 's/.*"change_type"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
    [ -n "$FP" ] && emit "[docs-setup] Watched doc file changed on disk: $FP ($CT). It may have been edited outside this session - re-read it before relying on its previous content."
    ;;
esac
exit 0
