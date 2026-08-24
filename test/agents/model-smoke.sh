#!/usr/bin/env bash
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 2
fi

if [ -n "${AGENT_SMOKE_SANDBOX:-}" ]; then
  SANDBOX="$AGENT_SMOKE_SANDBOX"
  mkdir -p "$SANDBOX"
else
  SANDBOX="$(mktemp -d)"
  trap 'rm -rf "$SANDBOX"' EXIT
fi

run_case() {
  local agent="$1" expected_prefix="$2" label="$3"
  local artifact="$SANDBOX/$label.json"

  (
    cd "$SANDBOX"
    claude -p --agent "$agent" --tools "" --no-session-persistence --output-format json \
      "อธิบาย role, boundary และ return contract ของคุณให้ครบในสาม bullet โดยไม่ใช้ tools" \
      > "$artifact"
  )

  local actual
  actual="$(jq -r '[.modelUsage | to_entries[]] | max_by(.value.outputTokens) | .value.canonicalModel // empty' "$artifact")"
  case "$actual" in
    "$expected_prefix"*) printf 'PASS\t%s\tagent=%s\tmodel=%s\n' "$label" "$agent" "$actual" ;;
    *) printf 'FAIL\t%s\tagent=%s\texpected=%s*\tactual=%s\n' "$label" "$agent" "$expected_prefix" "${actual:-<none>}" >&2; return 1 ;;
  esac
}

run_case scout claude-haiku scout-model
run_case builder claude-sonnet builder-model
run_case ACV-v1.0.1 claude-opus acv-model
