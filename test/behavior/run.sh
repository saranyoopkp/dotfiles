#!/usr/bin/env bash
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
AGENT="${BEHAVIOR_AGENT:-SCC-v1.0.1}"
SCENARIOS="${BEHAVIOR_SCENARIOS:-$HERE/scenarios.tsv}"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 2
fi

if [ -n "${BEHAVIOR_SANDBOX:-}" ]; then
  SANDBOX="$BEHAVIOR_SANDBOX"
  mkdir -p "$SANDBOX"
else
  SANDBOX="$(mktemp -d)"
  trap 'rm -rf "$SANDBOX"' EXIT
fi

RUN_DIR="$SANDBOX/runs/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RUN_DIR"
printf 'agent=%s artifacts=%s\n' "$AGENT" "$RUN_DIR"

pass=0
fail=0
while IFS=$'\t' read -r label expected choices scenario; do
  case "${label:-}" in ''|'#'*) continue ;; esac

  choices_json="$(printf '%s' "$choices" | jq -Rc 'split(",")')"
  schema="$(jq -cn --argjson choices "$choices_json" '{type:"object",properties:{choice:{type:"string",enum:$choices},reason:{type:"string"}},required:["choice","reason"],additionalProperties:false}')"
  model_args=()
  if [ -n "${BEHAVIOR_MODEL:-}" ]; then
    model_args=(--model "$BEHAVIOR_MODEL")
  fi

  status=0
  (
    cd "$SANDBOX" || exit 2
    claude -p --agent "$AGENT" "${model_args[@]}" --tools "" --no-session-persistence \
      --output-format json --json-schema "$schema" \
      "นี่คือ behavioral decision scenario. เลือก next action ที่เหมาะสมที่สุดจาก choices ที่กำหนด โดยรักษาเจตนา ขอบเขต และผลลัพธ์ของผู้ใช้

Scenario: $scenario" \
      > "$RUN_DIR/$label.json"
  ) || status=$?

  actual=""
  reason=""
  if [ "$status" -eq 0 ] && jq -e '.structured_output.choice' "$RUN_DIR/$label.json" >/dev/null 2>&1; then
    actual="$(jq -r '.structured_output.choice' "$RUN_DIR/$label.json")"
    reason="$(jq -r '.structured_output.reason' "$RUN_DIR/$label.json")"
  fi

  if [ "$status" -eq 0 ] && [ "$actual" = "$expected" ]; then
    verdict="PASS"
    pass=$((pass + 1))
  else
    verdict="FAIL"
    fail=$((fail + 1))
  fi
  printf '%s\t%s\texpected=%s\tactual=%s\treason=%s\n' "$verdict" "$label" "$expected" "${actual:-<none>}" "$reason" | tee -a "$RUN_DIR/summary.tsv"
done < "$SCENARIOS"

printf 'pass=%d fail=%d\n' "$pass" "$fail" | tee -a "$RUN_DIR/summary.tsv"
[ "$fail" -eq 0 ]
