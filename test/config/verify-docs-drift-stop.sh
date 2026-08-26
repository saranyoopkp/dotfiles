#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
HOOK="$ROOT/claude/skills/docs/setup/kit/hooks/docs-drift.sh"
SETTINGS="$ROOT/claude/skills/docs/setup/kit/hooks/settings.json"
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

python3 - "$SETTINGS" <<'PY'
import json
import sys

hooks = json.load(open(sys.argv[1], encoding="utf-8"))["hooks"]
assert set(hooks) == {"SessionStart", "PostToolUse", "TaskCompleted", "Stop", "PreCompact"}
assert hooks["PostToolUse"][0]["matcher"] == "Edit|Write"
for event in hooks:
    command = hooks[event][0]["hooks"][0]["args"][1]
    assert command.endswith(f"docs-drift.sh {event}"), (event, command)
PY

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
printf '%s\n' '// baseline one' '// baseline two' '// baseline three' 'const value = 2;' > "$REPO/app.js"
BASELINE_COMMENT="$(run_event PostToolUse ownership-session "{\"hook_event_name\":\"PostToolUse\",\"session_id\":\"ownership-session\",\"tool_input\":{\"file_path\":\"$REPO/app.js\"}}")"
[ -z "$BASELINE_COMMENT" ] || {
  echo "pre-existing dirty paths must not trigger comment audit advice" >&2
  exit 1
}
printf '%s\n' 'const other = 2;' > "$REPO/other.js"
OWNED="$(run_stop ownership-session false)"
[ -z "$OWNED" ] || {
  echo "ordinary source edits must not create Stop ceremony" >&2
  exit 1
}

# Long changed comments are advisory audit leads, never Stop violations.
new_repo comments
run_event SessionStart comment-session >/dev/null
printf '%s\n' '// why one' '// why two' 'const value = 1;' > "$REPO/app.js"
SHORT="$(run_event PostToolUse comment-session "{\"hook_event_name\":\"PostToolUse\",\"session_id\":\"comment-session\",\"tool_input\":{\"file_path\":\"$REPO/app.js\"}}")"
[ -z "$SHORT" ] || {
  echo "one or two line comments must not trigger automatic advice" >&2
  exit 1
}
printf '%s\n' '// why one' '// why two' '// why three' 'const value = 1;' > "$REPO/app.js"
POST="$(run_event PostToolUse comment-session "{\"hook_event_name\":\"PostToolUse\",\"session_id\":\"comment-session\",\"tool_input\":{\"file_path\":\"$REPO/app.js\"}}")"
printf '%s' "$POST" | grep -q '\[comment-audit\]'
printf '%s' "$POST" | grep -q 'app.js:1'
printf '%s' "$POST" | grep -q 'audit candidate, not authority'
! printf '%s' "$POST" | grep -q '"decision":"block"'
REPEAT="$(run_event PostToolUse comment-session "{\"hook_event_name\":\"PostToolUse\",\"session_id\":\"comment-session\",\"tool_input\":{\"file_path\":\"$REPO/app.js\"}}")"
[ -z "$REPEAT" ] || {
  echo "unchanged comment finding must be deduplicated" >&2
  exit 1
}
printf '%s\n' 'const value = 1;' > "$REPO/app.js"
run_event PostToolUse comment-session "{\"hook_event_name\":\"PostToolUse\",\"session_id\":\"comment-session\",\"tool_input\":{\"file_path\":\"$REPO/app.js\"}}" >/dev/null
printf '%s\n' '// why one' '// why two' '// why three' 'const value = 1;' > "$REPO/app.js"
RETURNED="$(run_event PostToolUse comment-session "{\"hook_event_name\":\"PostToolUse\",\"session_id\":\"comment-session\",\"tool_input\":{\"file_path\":\"$REPO/app.js\"}}")"
printf '%s' "$RETURNED" | grep -q '\[comment-audit\]'
FIRST="$(run_stop comment-session false)"
[ -z "$FIRST" ] || {
  echo "comment length must not block Stop" >&2
  exit 1
}

# Untracked files created by this session are eligible for exact-path comment advice.
printf '%s\n' '# one' '# two' '# three' 'value = 1' > "$REPO/new.py"
UNTRACKED="$(run_event PostToolUse comment-session "{\"hook_event_name\":\"PostToolUse\",\"session_id\":\"comment-session\",\"tool_input\":{\"file_path\":\"$REPO/new.py\"}}")"
printf '%s' "$UNTRACKED" | grep -q 'new.py:1'

# Editing one line inside an existing long block is still a changed long comment.
new_repo existing_comment
printf '%s\n' '// existing one' '// existing two' '// existing three' 'const value = 1;' > "$REPO/app.js"
git -C "$REPO" add app.js
git -C "$REPO" commit -qm 'add existing comment'
run_event SessionStart existing-comment-session >/dev/null
printf '%s\n' '// existing one' '// revised two' '// existing three' 'const value = 1;' > "$REPO/app.js"
EXISTING="$(run_event PostToolUse existing-comment-session "{\"hook_event_name\":\"PostToolUse\",\"session_id\":\"existing-comment-session\",\"tool_input\":{\"file_path\":\"$REPO/app.js\"}}")"
printf '%s' "$EXISTING" | grep -q 'app.js:1'
printf '%s' "$EXISTING" | grep -q 'audit candidate, not authority'

# Deleting adjacent code does not make an unchanged long comment a changed block.
new_repo adjacent_code
printf '%s\n' 'const removed = 0;' '// unchanged one' '// unchanged two' '// unchanged three' 'const value = 1;' > "$REPO/app.js"
git -C "$REPO" add app.js
git -C "$REPO" commit -qm 'add adjacent comment'
run_event SessionStart adjacent-code-session >/dev/null
printf '%s\n' '// unchanged one' '// unchanged two' '// unchanged three' 'const value = 1;' > "$REPO/app.js"
ADJACENT="$(run_event PostToolUse adjacent-code-session "{\"hook_event_name\":\"PostToolUse\",\"session_id\":\"adjacent-code-session\",\"tool_input\":{\"file_path\":\"$REPO/app.js\"}}")"
[ -z "$ADJACENT" ] || {
  echo "deleting adjacent code must not mark an unchanged comment block as changed" >&2
  exit 1
}

# TaskCompleted is a deduplicated checkpoint for session-owned mutation, not a blocker.
new_repo checkpoint
run_event SessionStart checkpoint-session >/dev/null
EMPTY_CHECKPOINT="$(run_event TaskCompleted checkpoint-session)"
[ -z "$EMPTY_CHECKPOINT" ] || {
  echo "TaskCompleted must stay silent without session-owned changes" >&2
  exit 1
}
printf '%s\n' 'const value = 4;' > "$REPO/app.js"
CHECKPOINT="$(run_event TaskCompleted checkpoint-session)"
printf '%s' "$CHECKPOINT" | grep -q '\[checkpoint\]'
printf '%s' "$CHECKPOINT" | grep -q 'required acceptance evidence'
printf '%s' "$CHECKPOINT" | grep -q 'independent acceptance'
printf '%s' "$CHECKPOINT" | grep -q 'scoped local commit'
! printf '%s' "$CHECKPOINT" | grep -q '"decision":"block"'
CHECKPOINT_REPEAT="$(run_event TaskCompleted checkpoint-session)"
[ -z "$CHECKPOINT_REPEAT" ] || {
  echo "unchanged TaskCompleted state must be deduplicated" >&2
  exit 1
}
git -C "$REPO" add app.js
git -C "$REPO" commit -qm checkpoint
run_event TaskCompleted checkpoint-session >/dev/null
printf '%s\n' 'const value = 5;' > "$REPO/app.js"
CHECKPOINT_RETURNED="$(run_event TaskCompleted checkpoint-session)"
printf '%s' "$CHECKPOINT_RETURNED" | grep -q '\[checkpoint\]'

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

echo "docs-drift ownership, advisory checkpoints, memory pointer, and low-ceremony Stop behavior verified"
