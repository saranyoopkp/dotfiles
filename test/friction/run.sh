#!/usr/bin/env bash
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
SANDBOX="$(mktemp -d "${TMPDIR:-/tmp}/claude-friction.XXXXXX")"
trap 'rm -rf "$SANDBOX"' EXIT
pass=0
fail=0

while IFS=$'\t' read -r label expected max_chars task; do
  case "${label:-}" in ''|'#'*) continue ;; esac
  stream="$SANDBOX/$label.stream.jsonl"
  status=0
  (cd "$SANDBOX" && claude -p --output-format stream-json --verbose \
    --agent SCC-v1.0.1 --dangerously-skip-permissions "$task" > "$stream" 2> "$SANDBOX/$label.stderr.log") || status=$?
  verdict=""
  if [ "$status" -eq 0 ]; then
    verdict="$(python3 "$HERE/evaluate.py" "$stream" "$expected" "$max_chars" 2>&1)" || status=$?
  fi
  if [ "$status" -eq 0 ]; then
    printf '  PASS  %-16s %s\n' "$label" "$verdict"
    pass=$((pass + 1))
  else
    printf '  FAIL  %-16s cli/eval=%s %s\n' "$label" "$status" "$verdict"
    fail=$((fail + 1))
  fi
done < "$HERE/scenarios.tsv"

echo "---- pass=$pass fail=$fail"
[ "$fail" -eq 0 ]
