#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
HOOK="$ROOT/claude/skills/docs/setup/kit/hooks/docs-drift.sh"
TEST_TMP="$(mktemp -d "${TMPDIR:-/tmp}/docs-drift-stop.XXXXXX")"
trap 'rm -rf "$TEST_TMP"' EXIT
export HOME="$TEST_TMP/home"
mkdir -p "$HOME/.claude/projects"

new_repo() {
  local name="$1"
  REPO="$TEST_TMP/$name"
  STAMPS="$TEST_TMP/stamps-$name"
  mkdir -p "$REPO/memory" "$STAMPS"
  git -C "$REPO" init -q
  git -C "$REPO" config user.email "hook-test@example.invalid"
  git -C "$REPO" config user.name "Hook Test"
  printf '%s\n' 'const value = 1;' > "$REPO/app.js"
  printf '%s\n' 'const other = 1;' > "$REPO/other.js"
  printf '%s\n' '# Project' > "$REPO/CLAUDE.md"
  printf '%s\n' '# Memory' > "$REPO/memory/MEMORY.md"
  printf '%s\n' '# Memory files' > "$REPO/memory/README.md"
  git -C "$REPO" add .
  git -C "$REPO" commit -qm baseline
}

run_event() {
  local event="$1" session="$2" payload="${3:-}"
  if [ -z "$payload" ]; then
    payload="{\"hook_event_name\":\"$event\",\"session_id\":\"$session\"}"
  fi
  printf '%s\n' "$payload" | (cd "$REPO" && TMPDIR="$STAMPS" bash "$HOOK" "$event")
}

run_stop() {
  local session="$1" active="$2"
  run_event Stop "$session" "{\"hook_event_name\":\"Stop\",\"session_id\":\"$session\",\"stop_hook_active\":$active}"
}

# A dirty path present at SessionStart belongs to the user/previous session, not this task.
new_repo ownership
printf '%s\n' 'const value = 2;' > "$REPO/app.js"
START="$(run_event SessionStart ownership-session)"
printf '%s' "$START" | grep -q 'Pre-existing uncommitted paths'
printf '%s' "$START" | grep -q 'do not edit, stage, commit'
BASELINE_ONLY="$(run_stop ownership-session false)"
[ -z "$BASELINE_ONLY" ] || {
  echo "pre-existing dirty paths must not block Stop" >&2
  exit 1
}
printf '%s\n' 'const other = 2;' > "$REPO/other.js"
OWNED="$(run_stop ownership-session false)"
[ -z "$OWNED" ] || {
  echo "ordinary source edits must not create Stop ceremony" >&2
  exit 1
}

# Comment length alone is not a documentation violation.
new_repo comments
run_event SessionStart comment-session >/dev/null
printf '%s\n' '// why one' '// why two' 'const value = 1;' > "$REPO/app.js"
POST="$(run_event PostToolUse comment-session "{\"hook_event_name\":\"PostToolUse\",\"session_id\":\"comment-session\",\"tool_input\":{\"file_path\":\"$REPO/app.js\"}}")"
[ -z "$POST" ] || {
  echo "comment length must not trigger PostToolUse output" >&2
  exit 1
}
FIRST="$(run_stop comment-session false)"
[ -z "$FIRST" ] || {
  echo "comment length must not block Stop" >&2
  exit 1
}

# A session-created shared memory leaf must be indexed in the same change.
new_repo memory_pointer
run_event SessionStart memory-session >/dev/null
printf '%s\n' '# New fact' > "$REPO/memory/new-fact.md"
MEMORY="$(run_stop memory-session false)"
printf '%s' "$MEMORY" | grep -q 'Session-owned memory lifecycle violation'
printf '%s' "$MEMORY" | grep -q 'new-fact.md (missing from memory/MEMORY.md)'

# Rename checks both removal of the old pointer and addition of the new pointer.
new_repo memory_rename
printf '%s\n' '# Old fact' > "$REPO/memory/old-fact.md"
printf '%s\n' '# Memory' '- [Old fact](old-fact.md) — open for the old fact' > "$REPO/memory/MEMORY.md"
git -C "$REPO" add memory
git -C "$REPO" commit -qm 'add old memory fact'
run_event SessionStart memory-rename-session >/dev/null
git -C "$REPO" mv memory/old-fact.md memory/new-fact.md
RENAMED="$(run_stop memory-rename-session false)"
printf '%s' "$RENAMED" | grep -q 'old-fact.md (renamed but old pointer remains)'
printf '%s' "$RENAMED" | grep -q 'new-fact.md (renamed but new pointer is missing)'

# Ordinary source work does not get a mandatory disposition, commit, or verification ceremony from this docs hook.
new_repo disposition
run_event SessionStart disposition-session >/dev/null
printf '%s\n' 'const value = 3;' > "$REPO/app.js"
DISPOSITION="$(run_stop disposition-session false)"
[ -z "$DISPOSITION" ] || {
  echo "source-only work must not be blocked by docs lifecycle" >&2
  exit 1
}

# PreCompact preserves task state but cannot manufacture repository work.
PRECOMPACT="$(run_event PreCompact disposition-session)"
printf '%s' "$PRECOMPACT" | grep -q 'Preserve the current objective'
printf '%s' "$PRECOMPACT" | grep -q 'Do not create or commit repository docs solely because compaction is occurring'

echo "docs-drift ownership, memory pointer, and low-ceremony Stop behavior verified"
