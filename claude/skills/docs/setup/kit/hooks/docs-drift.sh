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

is_docs_path() {
  case "$1" in CLAUDE.md|docs/*|memory/*) return 0 ;; *) return 1 ;; esac
}

diff_for_path() {
  path="$1"
  if git -C "$ROOT" ls-files --error-unmatch -- "$path" >/dev/null 2>&1; then
    git -C "$ROOT" diff --no-ext-diff --unified=0 HEAD -- "$path" 2>/dev/null
  elif [ -f "$ROOT/$path" ]; then
    git -C "$ROOT" diff --no-ext-diff --unified=0 --no-index /dev/null "$ROOT/$path" 2>/dev/null || true
  fi
}

# Consecutive added line comments are an audit lead; public contract docstrings need judgment.
new_multiline_comments_for_path() {
  path="$1"
  diff_for_path "$path" | awk -v fallback="$path" '
    /^\+\+\+ / { file=fallback; next }
    /^@@ / { h=$0; sub(/^.*\+/, "", h); sub(/,.*/, "", h); line=h-1; run=0; next }
    /^\+/ && !/^\+\+\+/ {
      line++; text=substr($0,2)
      if (text ~ /^[[:space:]]*(#|\/\/)/) { run++; if (run == 2) print file ":" (line-1) }
      else run=0
      next
    }
    /^ / { line++; run=0; next }
    /^-/ { run=0; next }
  '
}

session_comment_findings() {
  session_status | status_paths | while IFS= read -r path; do
    [ -n "$path" ] || continue
    case "$path" in *' -> '*) path="${path##* -> }" ;; esac
    new_multiline_comments_for_path "$path"
  done | sort -u | paste -sd ', ' -
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
    case "$FP" in "$ROOT"/*) FP="${FP#"$ROOT"/}" ;; esac
    [ -n "$FP" ] || exit 0
    is_baseline_path "$FP" && exit 0
    COMMENTS="$(new_multiline_comments_for_path "$FP" | sort -u | paste -sd ', ' -)"
    [ -n "$COMMENTS" ] || { : > "$COMMENT_STAMP"; exit 0; }
    CHASH="$(printf '%s' "$COMMENTS" | cksum | cut -d' ' -f1)"
    [ "$CHASH" = "$(cat "$COMMENT_STAMP" 2>/dev/null || true)" ] && exit 0
    printf '%s' "$CHASH" > "$COMMENT_STAMP"
    emit "[docs] New multi-line line-comment(s) in the session-owned edit: $COMMENTS. Keep concise why/constraint near code and move narrative/history to project docs with a pointer; retain multi-line docstrings when they are genuine public interface contracts."
    ;;

  Stop)
    OWNED_FILE="$STATE_DIR/session-status"
    session_status > "$OWNED_FILE"
    OWNED="$(join_status < "$OWNED_FILE")"
    [ -n "$OWNED" ] || exit 0
    PARTS="[scope] Session-owned uncommitted paths: $OWNED. If the authorized work reached a cohesive verified checkpoint, create a scoped local commit by default unless the user said not to commit. Never include pre-existing paths or push without explicit direction."

    SOURCE_PATHS=""
    DOC_PATHS=""
    while IFS= read -r line; do
      path="${line#???}"
      if is_docs_path "$path"; then DOC_PATHS="$DOC_PATHS $path"; else SOURCE_PATHS="$SOURCE_PATHS $path"; fi
    done < "$OWNED_FILE"
    if [ -n "$SOURCE_PATHS" ]; then
      PARTS="$PARTS [verify] Before claiming completion, state the behavior claim, evidence obtained, and any remaining verification gap for:$SOURCE_PATHS. Choose evidence proportional to this task's risk and requested acceptance level; do not expand the test matrix or mutate shared/runtime state without authorization. [docs] Give the documentation disposition: updated files, 'no durable docs impact' with a reason, or out-of-scope/deferred with owner/follow-up. Do not create docs solely to satisfy this hook."
    fi
    [ -n "$DOC_PATHS" ] && PARTS="$PARTS [docs] Review session-owned docs/memory for accuracy, secrets, and personal metadata before any authorized commit."

    COMMENTS="$(session_comment_findings)"
    [ -n "$COMMENTS" ] && PARTS="$PARTS [docs] New multi-line line-comment(s): $COMMENTS. Resolve only in session-owned files; public interface contracts may remain as docstrings."

    POINTERS="$(memory_pointer_findings "$OWNED_FILE" | paste -sd ', ' -)"
    [ -n "$POINTERS" ] && PARTS="$PARTS [docs] Session-owned memory lifecycle violation: $POINTERS. Sync the shared leaf and its memory/MEMORY.md pointer before completion."

    HASH="$(printf '%s' "$PARTS" | cksum | cut -d' ' -f1)"
    [ "$HASH" = "$(cat "$STOP_STAMP" 2>/dev/null || true)" ] && exit 0
    printf '%s' "$HASH" > "$STOP_STAMP"
    block_stop "$PARTS"
    ;;

  TaskCompleted)
    OWNED="$(session_status | join_status)"
    MSG="[docs] Task checkpoint: state the documentation disposition and verification evidence/gap for the objective just completed. For authorized mutation work, create a scoped local commit by default at a cohesive verified checkpoint unless the user said not to; do not reopen deferred work, expand tests, mutate shared/runtime state, include pre-existing paths, or push without explicit direction."
    [ -n "$OWNED" ] && MSG="$MSG Session-owned uncommitted paths: $OWNED; keep pre-existing paths out of any action."
    emit "$MSG"
    ;;

  PreCompact)
    printf '{"systemMessage":"[session-state] Preserve the current objective, deferred/out-of-scope items, authorization boundaries, verification gaps, and session-owned paths in the compacted summary. Do not create or commit repository docs solely because compaction is occurring."}\n'
    ;;
esac
exit 0
