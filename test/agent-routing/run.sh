#!/usr/bin/env bash
# Fresh-session regression for optional Scout delegation, based on actual Agent tool-use.
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
SCENARIOS="${AGENT_ROUTING_SCENARIOS:-$HERE/scenarios.tsv}"
if [ -n "${AGENT_ROUTING_SANDBOX:-}" ]; then
  SANDBOX="$AGENT_ROUTING_SANDBOX"
  mkdir -p "$SANDBOX"
else
  SANDBOX="$(mktemp -d "${TMPDIR:-/tmp}/agent-routing.XXXXXX")"
  trap 'rm -rf "$SANDBOX"' EXIT
fi
RUN_DIR="$SANDBOX/runs/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RUN_DIR"
pass=0
fail=0

invoked_agents() {
  python3 -c '
import json, sys
found = set()
for raw in sys.stdin:
    try:
        event = json.loads(raw)
    except json.JSONDecodeError:
        continue
    for block in (event.get("message") or {}).get("content") or []:
        if isinstance(block, dict) and block.get("type") == "tool_use" and block.get("name") == "Agent":
            agent = str((block.get("input") or {}).get("subagent_type", ""))
            if agent:
                found.add(agent)
print(" ".join(sorted(found)))
'
}

while IFS=$'\t' read -r require forbid label task; do
  case "${require:-}" in ''|'#'*) continue ;; esac
  stream="$RUN_DIR/$label.stream.jsonl"
  status=0
  (cd "$SANDBOX" && claude -p --agent SCC-v1.0.1 --dangerously-skip-permissions \
    --output-format stream-json --verbose "งาน: $task

วางแผนจริงโดยไม่แก้ไฟล์" > "$stream" 2> "$RUN_DIR/$label.stderr.log") || status=$?
  invoked=""
  [ -f "$stream" ] && invoked="$(invoked_agents < "$stream")"
  ok=1
  [ "$status" -eq 0 ] || ok=0
  if [ "$require" != "-" ]; then
    case " $invoked " in *" $require "*) ;; *) ok=0 ;; esac
  fi
  if [ "$forbid" != "-" ]; then
    case " $invoked " in *" $forbid "*) ok=0 ;; esac
  fi
  if [ "$ok" -eq 1 ]; then
    printf '  PASS  %-24s invoked=[%s]\n' "$label" "$invoked"
    pass=$((pass + 1))
  else
    printf '  FAIL  %-24s require=%s forbid=%s cli=%s invoked=[%s]\n' \
      "$label" "$require" "$forbid" "$status" "$invoked"
    fail=$((fail + 1))
  fi
done < "$SCENARIOS"

printf '%s\n' "---- pass=$pass fail=$fail artifacts=$RUN_DIR"
[ "$fail" -eq 0 ]
