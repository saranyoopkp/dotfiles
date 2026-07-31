#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
HOOK="$ROOT/claude/skills/docs/setup/kit/hooks/docs-drift.sh"
TEST_TMP="$(mktemp -d "${TMPDIR:-/tmp}/docs-drift-stop.XXXXXX")"
trap 'rm -rf "$TEST_TMP"' EXIT
REPO="$TEST_TMP/repo"
STAMPS="$TEST_TMP/stamps"
mkdir -p "$REPO" "$STAMPS"

git -C "$REPO" init -q
git -C "$REPO" config user.email "hook-test@example.invalid"
git -C "$REPO" config user.name "Hook Test"
printf '%s\n' 'const value = 1;' > "$REPO/app.js"
git -C "$REPO" add app.js
git -C "$REPO" commit -qm baseline
printf '%s\n' '// why one' '// why two' 'const value = 1;' > "$REPO/app.js"

run_stop() {
  local active="$1"
  printf '{"hook_event_name":"Stop","stop_hook_active":%s}\n' "$active" |
    (cd "$REPO" && TMPDIR="$STAMPS" bash "$HOOK" Stop)
}

FIRST="$(run_stop false)"
printf '%s' "$FIRST" | grep -q '"decision":"block"'
printf '%s' "$FIRST" | grep -q 'New multi-line line-comment'

ACTIVE="$(run_stop true)"
[ -z "$ACTIVE" ] || {
  echo "Stop continuation must be allowed when stop_hook_active=true" >&2
  exit 1
}

SAME="$(run_stop false)"
[ -z "$SAME" ] || {
  echo "unchanged Stop findings must be deduplicated" >&2
  exit 1
}

printf '%s\n' 'const value = 1;' > "$REPO/app.js"
CLEAR="$(run_stop false)"
[ -z "$CLEAR" ] || {
  echo "clean source state must not block Stop" >&2
  exit 1
}

printf '%s\n' '// why one' '// why two' 'const value = 1;' > "$REPO/app.js"
REAPPEARED="$(run_stop false)"
printf '%s' "$REAPPEARED" | grep -q 'New multi-line line-comment'

echo "docs-drift Stop loop breaker and dedup verified"
