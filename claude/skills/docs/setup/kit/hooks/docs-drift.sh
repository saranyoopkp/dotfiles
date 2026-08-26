#!/usr/bin/env bash
# docs-drift.sh — scope-aware documentation/memory lifecycle hook (Git Bash on Windows)
set -u

EVENT="${1:-}"
if [ -t 0 ]; then INPUT=""; else INPUT="$(cat 2>/dev/null || true)"; fi
json_value() {
  printf '%s' "$INPUT" | tr -d '\r\n' |
    sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p"
}
json_bool() {
  printf '%s' "$INPUT" | tr -d '\r\n' |
    sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\(true\|false\).*/\1/p"
}

if [ "$EVENT" = "Stop" ] && [ "$(json_bool stop_hook_active)" = "true" ]; then
  exit 0
fi

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$ROOT" ] || exit 0
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    NATIVE="$(cygpath -w "$ROOT")"
    ROOT="$(cygpath -u "$ROOT")" ;;
  *) NATIVE="$ROOT" ;;
esac
ID="$(printf '%s' "$NATIVE" | sed 's/[^A-Za-z0-9]/-/g')"
SESSION_ID="$(json_value session_id)"
[ -n "$SESSION_ID" ] || SESSION_ID="unknown-session"
SESSION_KEY="$(printf '%s' "$SESSION_ID" | sed 's/[^A-Za-z0-9]/-/g')"
STATE_DIR="${TMPDIR:-/tmp}/docs-drift-$ID-$SESSION_KEY"
BASELINE_STATUS="$STATE_DIR/baseline-status"
BASELINE_PATHS="$STATE_DIR/baseline-paths"
STOP_STAMP="$STATE_DIR/stop-stamp"
COMMENT_STAMP="$STATE_DIR/comment-stamp"
TASK_STAMP="$STATE_DIR/task-stamp"
mkdir -p "$STATE_DIR" 2>/dev/null || exit 0

json_escape() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }
emit() {
  printf '{"hookSpecificOutput":{"hookEventName":"%s","additionalContext":"%s"%s}}\n' \
    "$EVENT" "$(json_escape "$1")" "${2:-}"
}
block_stop() { printf '{"decision":"block","reason":"%s"}\n' "$(json_escape "$1")"; }

capture_status() {
  git -C "$ROOT" status --porcelain --untracked-files=all 2>/dev/null
}
status_paths() { sed 's/^...//'; }
ensure_baseline() {
  [ -f "$BASELINE_STATUS" ] && return
  capture_status > "$BASELINE_STATUS"
  status_paths < "$BASELINE_STATUS" > "$BASELINE_PATHS"
}
is_baseline_path() { grep -Fqx -- "$1" "$BASELINE_PATHS" 2>/dev/null; }
session_status() {
  capture_status | while IFS= read -r line; do
    path="${line#???}"
    is_baseline_path "$path" || printf '%s\n' "$line"
  done
}
join_status() { sed 's/^ *//' | paste -sd ';' -; }

diff_for_path() {
  path="$1"
  if git -C "$ROOT" ls-files --error-unmatch -- "$path" >/dev/null 2>&1; then
    git -C "$ROOT" diff --no-ext-diff --unified=0 HEAD -- "$path" 2>/dev/null
  elif [ -f "$ROOT/$path" ]; then
    git -C "$ROOT" diff --no-ext-diff --unified=0 --no-index /dev/null "$ROOT/$path" 2>/dev/null || true
  fi
}

# A changed line inside a current 3+ line-comment block is an audit lead, not a placement verdict.
new_long_comments_for_path() {
  path="$1"
  [ -f "$ROOT/$path" ] || return
  changed="$(diff_for_path "$path" | awk '
    /^@@ / { h=$0; sub(/^.*\+/, "", h); sub(/,.*/, "", h); line=h-1; next }
    /^\+/ && !/^\+\+\+/ {
      line++; print line
      next
    }
    /^ / { line++; next }
    /^-/ && !/^---/ {
      text=substr($0,2)
      if (text ~ /^[[:space:]]*(#|\/\/)/) {
        if (line > 0) print line
        print line+1
      }
      next
    }
  ' | awk '$1 > 0' | sort -nu | paste -sd, -)"
  [ -n "$changed" ] || return
  awk -v changed="$changed" -v path="$path" '
    BEGIN {
      count=split(changed, lines, ",")
      for (i=1; i<=count; i++) touched[lines[i]]=1
    }
    function flush() {
      if (run >= 3 && hit) print path ":" start
      run=0; hit=0
    }
    /^[[:space:]]*(#|\/\/)/ {
      if (run == 0) start=NR
      run++
      if (touched[NR]) hit=1
      next
    }
    { flush() }
    END { flush() }
  ' "$ROOT/$path"
}

memory_pointer_findings() {
  status_file="$1"
  [ -f "$ROOT/memory/MEMORY.md" ] || return
  while IFS= read -r line; do
    code="${line%${line#??}}"
    path="${line#???}"
    case "$path" in
      *' -> '*)
        old="${path%% -> *}"
        new="${path##* -> }"
        case "$old:$new" in
          memory/MEMORY.md:*|memory/README.md:*|memory/private/*:*|*:memory/MEMORY.md|*:memory/README.md|*:memory/private/*) continue ;;
          memory/*.md:memory/*.md) ;;
          *) continue ;;
        esac
        old_base="${old##*/}"
        new_base="${new##*/}"
        grep -Fq -- "$old_base" "$ROOT/memory/MEMORY.md" && printf '%s (renamed but old pointer remains)\n' "$old"
        grep -Fq -- "$new_base" "$ROOT/memory/MEMORY.md" || printf '%s (renamed but new pointer is missing)\n' "$new"
        continue
        ;;
    esac
    case "$path" in
      memory/MEMORY.md|memory/README.md|memory/private/*) continue ;;
      memory/*.md) ;;
      *) continue ;;
    esac
    base="${path##*/}"
    case "$code" in
      *D*) grep -Fq -- "$base" "$ROOT/memory/MEMORY.md" && printf '%s (deleted but still indexed)\n' "$path" ;;
      *) grep -Fq -- "$base" "$ROOT/memory/MEMORY.md" || printf '%s (missing from memory/MEMORY.md)\n' "$path" ;;
    esac
  done < "$status_file"
}

ensure_baseline

case "$EVENT" in
  SessionStart)
    PARTS=""
    BASELINE="$(join_status < "$BASELINE_STATUS")"
    if [ -n "$BASELINE" ]; then
      PARTS="[scope] Pre-existing uncommitted paths at session start: $BASELINE. Treat them as user/previous-session work: report them if relevant, but do not edit, stage, commit, or use them to expand this task without explicit direction."
    fi
    POINTERS="$(memory_pointer_findings "$BASELINE_STATUS" | paste -sd ', ' -)"
    [ -n "$POINTERS" ] && PARTS="$PARTS [docs] Pre-existing memory/index mismatch: $POINTERS. Advisory only; do not repair it unless the user puts it in scope."
    if [ -f "$ROOT/CLAUDE.md" ]; then
      LINES="$(wc -l < "$ROOT/CLAUDE.md" | tr -d ' ')"
      [ "$LINES" -gt 200 ] && PARTS="$PARTS [docs] CLAUDE.md is $LINES lines (>200). Consider promoting a substantive oversized section into docs/ when that document is in scope."
    fi
    MEM="$HOME/.claude/projects/$ID/memory"
    if [ -d "$ROOT/memory" ] && [ -d "$HOME/.claude/projects" ]; then
      if [ -L "$MEM" ] && [ ! -e "$MEM" ]; then
        PARTS="$PARTS [docs] Harness memory link is broken. This hook is verify-only; run the repository's docs setup/repair workflow before relying on shared memory."
      elif [ ! -e "$MEM" ]; then
        PARTS="$PARTS [docs] Harness memory link is missing. This hook is verify-only; run the repository's docs setup workflow to create it."
      elif ! [ "$MEM" -ef "$ROOT/memory" ]; then
        PARTS="$PARTS [docs] Harness memory path is not linked to this tree's memory/. Do not delete either copy; use the docs setup/repair workflow to merge and relink it."
      fi
    fi
    native_path() { case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) cygpath -w "$1" ;; *) printf '%s' "$1" ;; esac; }
    WATCH=""
    [ -f "$ROOT/CLAUDE.md" ] && WATCH="\"$(json_escape "$(native_path "$ROOT/CLAUDE.md")")\""
    if [ -f "$ROOT/memory/MEMORY.md" ]; then
      [ -n "$WATCH" ] && WATCH="$WATCH,"
      WATCH="$WATCH\"$(json_escape "$(native_path "$ROOT/memory/MEMORY.md")")\""
    fi
    emit "${PARTS# }" ",\"watchPaths\":[$WATCH]"
    ;;

  PostToolUse)
    FP="$(json_value file_path)"
    case "$(uname -s)" in
      MINGW*|MSYS*|CYGWIN*) FP="$(cygpath -u "$FP" 2>/dev/null || printf '%s' "$FP")" ;;
    esac
    case "$FP" in
      /*) FP="$(cd "$(dirname "$FP")" 2>/dev/null && pwd -P)/$(basename "$FP")" ;;
    esac
    case "$FP" in "$ROOT"/*) FP="${FP#"$ROOT"/}" ;; esac
    [ -n "$FP" ] || exit 0
    case "$FP" in /*) exit 0 ;; esac
    is_baseline_path "$FP" && exit 0
    COMMENTS="$(new_long_comments_for_path "$FP" | sort -u | paste -sd ', ' -)"
    [ -n "$COMMENTS" ] || { : > "$COMMENT_STAMP"; exit 0; }
    CHASH="$(printf '%s' "$COMMENTS" | cksum | cut -d' ' -f1)"
    [ "$CHASH" = "$(cat "$COMMENT_STAMP" 2>/dev/null || true)" ] && exit 0
    printf '%s' "$CHASH" > "$COMMENT_STAMP"
    emit "[comment-audit] Changed comment block (>2 lines) at $COMMENTS. Treat it as an audit candidate, not authority: verify it against code and requirements before following it; keep concise rationale or constraints near code, and move only narrative or history that has a durable documentation owner."
    ;;

  TaskCompleted)
    OWNED_FILE="$STATE_DIR/session-status"
    session_status > "$OWNED_FILE"
    OWNED="$(join_status < "$OWNED_FILE")"
    [ -n "$OWNED" ] || { : > "$TASK_STAMP"; exit 0; }
    THASH="$(cksum < "$OWNED_FILE" | cut -d' ' -f1)"
    [ "$THASH" = "$(cat "$TASK_STAMP" 2>/dev/null || true)" ] && exit 0
    printf '%s' "$THASH" > "$TASK_STAMP"
    emit "[checkpoint] Session-owned changes remain: $OWNED. Before claiming this objective complete, confirm the required acceptance evidence and any verification gap. If the active workflow requires independent acceptance, complete or report it. At a cohesive verified checkpoint, create a scoped local commit unless the user or repository workflow says otherwise; exclude pre-existing paths and do not push without explicit direction."
    ;;

  Stop)
    OWNED_FILE="$STATE_DIR/session-status"
    session_status > "$OWNED_FILE"
    OWNED="$(join_status < "$OWNED_FILE")"
    [ -n "$OWNED" ] || exit 0
    POINTERS="$(memory_pointer_findings "$OWNED_FILE" | paste -sd ', ' -)"
    [ -n "$POINTERS" ] || exit 0
    PARTS="[docs] Session-owned memory lifecycle violation: $POINTERS. Sync the shared leaf and its memory/MEMORY.md pointer before completion."

    HASH="$(printf '%s' "$PARTS" | cksum | cut -d' ' -f1)"
    [ "$HASH" = "$(cat "$STOP_STAMP" 2>/dev/null || true)" ] && exit 0
    printf '%s' "$HASH" > "$STOP_STAMP"
    block_stop "$PARTS"
    ;;

  PreCompact)
    printf '{"systemMessage":"[session-state] Preserve the current objective, deferred/out-of-scope items, authorization boundaries, verification gaps, and session-owned paths in the compacted summary. Do not create or commit repository docs solely because compaction is occurring."}\n'
    ;;
esac
exit 0
