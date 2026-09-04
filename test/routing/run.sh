#!/usr/bin/env bash
# run.sh — verify skill auto-invocation in fresh Claude sessions from ground truth.
#
# Measure actual Skill tool_use events in stream-json rather than grepping model self-reports,
# which would select desired strings and trust the model. Give a task and observe what it does.
#
# claude -p provides a fresh session; subagents inherit existing context and session-start rules.
# Run outside dotfiles so its CLAUDE.md does not contaminate results; configure ROUTING_SANDBOX.
# Each scenario consumes API tokens, so run after skill or scenario changes, not every commit.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
# Derive the registry from frontmatter so adding a skill cannot silently hide it from the parser.
discover_skill_names() {
  local skill_file raw_name
  while IFS= read -r -d '' skill_file; do
    raw_name="$(sed -n 's/^name:[[:space:]]*//p' "$skill_file" | tr -d '\r')"
    if [ -z "$raw_name" ] || [[ "$raw_name" == *$'\n'* ]] ||
       ! printf '%s\n' "$raw_name" | grep -Eq '^[a-z0-9][a-z0-9:-]*$'; then
      echo "invalid or ambiguous skill name in $skill_file" >&2
      return 1
    fi
    printf '%s\n' "${raw_name//:/-}"
  done < <(find "$ROOT/claude/skills" -type f -name SKILL.md -print0)
}
REGISTRY_NAMES="$(discover_skill_names)" || exit 2
registry_count="$(printf '%s\n' "$REGISTRY_NAMES" | sed '/^$/d' | wc -l | tr -d ' ')"
UNIQUE_REGISTRY_NAMES="$(printf '%s\n' "$REGISTRY_NAMES" | sed '/^$/d' | sort -u)"
unique_registry_count="$(printf '%s\n' "$UNIQUE_REGISTRY_NAMES" | sed '/^$/d' | wc -l | tr -d ' ')"
[ "$registry_count" -gt 0 ] || { echo "no on-demand skills found in $ROOT/claude/skills" >&2; exit 2; }
[ "$registry_count" -eq "$unique_registry_count" ] || { echo "duplicate skill name in registry" >&2; exit 2; }
ONDEMAND_SKILLS="$(printf '%s\n' "$UNIQUE_REGISTRY_NAMES" | tr '\n' ' ')"
if [ "${ROUTING_LIST_SKILLS:-}" = "1" ]; then
  printf '%s\n' "$UNIQUE_REGISTRY_NAMES"
  exit 0
fi
SCENARIO_FILES=("$HERE/scenarios.tsv" "$HERE/scenarios-ui-content-copy.tsv" "$HERE/scenarios-ui-navigation.tsv" "$HERE/scenarios-ui-design-inspiration.tsv" "$HERE/scenarios-ops.tsv" "$HERE/scenarios-research.tsv" "$HERE/scenarios-retro.tsv" "$HERE/scenarios-docs.tsv" "$HERE/scenarios-compatibility.tsv" "$HERE/scenarios-performance.tsv" "$HERE/scenarios-stack-contracts.tsv" "$HERE/scenarios-testing-strategy.tsv" "$HERE/scenarios-risk.tsv" "$HERE/scenarios-simple-negative.tsv")
if [ -n "${ROUTING_SCENARIO_FILES:-}" ]; then
  IFS=':' read -r -a SCENARIO_FILES <<< "$ROUTING_SCENARIO_FILES"
fi
MAX_PARALLEL="${ROUTING_MAX_PARALLEL:-4}"
case "$MAX_PARALLEL" in
  ''|*[!0-9]*|0) echo "ROUTING_MAX_PARALLEL must be a positive integer" >&2; exit 2 ;;
esac
routing_sandbox_from_env="${ROUTING_SANDBOX:-}"
[ -f "$HERE/.local.sh" ] && . "$HERE/.local.sh"
if [ -n "$routing_sandbox_from_env" ]; then
  ROUTING_SANDBOX="$routing_sandbox_from_env"
fi
if [ -n "${ROUTING_SANDBOX:-}" ]; then
  SANDBOX="$ROUTING_SANDBOX"; mkdir -p "$SANDBOX"
else
  SANDBOX="$(mktemp -d)"; trap 'rm -rf "$SANDBOX"' EXIT
fi
pass=0; fail=0
RUN_DIR="$SANDBOX/runs/$(date +%Y%m%d-%H%M%S)"; mkdir -p "$RUN_DIR"
echo "artifacts (raw stream-json per scenario): $RUN_DIR"

run_with_timeout() {
  if command -v timeout >/dev/null 2>&1; then
    timeout 180 "$@"
  elif command -v gtimeout >/dev/null 2>&1; then
    gtimeout 180 "$@"
  else
    python3 -c '
import os, signal, subprocess, sys
p = subprocess.Popen(sys.argv[2:], start_new_session=True)
try:
    raise SystemExit(p.wait(timeout=int(sys.argv[1])))
except subprocess.TimeoutExpired:
    os.killpg(p.pid, signal.SIGTERM)
    try:
        p.wait(timeout=5)
    except subprocess.TimeoutExpired:
        os.killpg(p.pid, signal.SIGKILL)
        p.wait()
    raise SystemExit(124)
' 180 "$@"
  fi
}

# stdin is stream-json; stdout is the sorted, space-separated set of invoked on-demand skills.
invoked_skills() {
python -c "
import sys,json
ond=set(sys.argv[1:]); got=set()
for line in sys.stdin:
    line=line.strip()
    if not line: continue
    try: d=json.loads(line)
    except: continue
    c=(d.get('message') or {}).get('content')
    if not isinstance(c,list): continue
    for b in c:
        if isinstance(b,dict) and b.get('type')=='tool_use' and b.get('name')=='Skill':
            s=str((b.get('input') or {}).get('skill','')).replace(':','-').lstrip('/')
            if s in ond: got.add(s)
sys.stdout.write(' '.join(sorted(got)))
" $ONDEMAND_SKILLS
}

# PHASE 1 — run scenarios concurrently as independent sessions with separate artifacts.
n=0; batch=0; batch_pids=()
while IFS=$'\t' read -r require forbid label task; do
  case "${require:-}" in ''|'#'*) continue ;; esac
  # Backward compatibility: legacy rows are expect<TAB>label<TAB>task.
  if [ -z "${task:-}" ]; then
    task="$label"; label="$forbid"; forbid="-"
  fi
  (
    status=0
    cd "$SANDBOX" && run_with_timeout claude -p --output-format stream-json --verbose \
      --agent SCC-v1.0.1 --dangerously-skip-permissions \
      "Task: $task

Produce a real plan without writing code." > "$RUN_DIR/$label.stream.jsonl" \
      2> "$RUN_DIR/$label.stderr.log" < /dev/null || status=$?
    printf '%s\n' "$status" > "$RUN_DIR/$label.exit"
  ) &
  batch_pids+=("$!")
  n=$((n+1)); batch=$((batch+1))
  if [ "$batch" -ge "$MAX_PARALLEL" ]; then
    for pid in "${batch_pids[@]}"; do wait "$pid"; done
    batch=0
    batch_pids=()
  fi
done < <(cat "${SCENARIO_FILES[@]}")
echo "running $n scenarios with at most $MAX_PARALLEL in parallel..."
for pid in "${batch_pids[@]}"; do wait "$pid"; done
echo "complete — parsing:"

# PHASE 2 — parse artifacts, rereading scenarios to preserve order.
while IFS=$'\t' read -r require forbid label task; do
  case "${require:-}" in ''|'#'*) continue ;; esac
  if [ -z "${task:-}" ]; then
    task="$label"; label="$forbid"; forbid="-"
  fi
  exit_file="$RUN_DIR/$label.exit"
  exit_status="missing"
  [ -f "$exit_file" ] && exit_status="$(tr -d '[:space:]' < "$exit_file")"
  invoked=""
  if [ -f "$RUN_DIR/$label.stream.jsonl" ]; then
    invoked="$(invoked_skills < "$RUN_DIR/$label.stream.jsonl")"
  fi
  # Legacy NONE forbids every on-demand skill. New rows can require and forbid exact skills.
  if [ "$require" = "NONE" ]; then require="-"; forbid="*"; fi
  ok=1
  [ "$exit_status" = "0" ] || ok=0
  if [ "$require" != "-" ]; then
    for skill in $require; do
      case " $invoked " in *" $skill "*) ;; *) ok=0 ;; esac
    done
  fi
  if [ "$forbid" = "*" ]; then
    [ -z "$invoked" ] || ok=0
  elif [ "$forbid" != "-" ]; then
    for skill in $forbid; do
      case " $invoked " in *" $skill "*) ok=0 ;; esac
    done
  fi
  verdict="require=$require forbid=$forbid cli=$exit_status"
  if [ "$ok" = 1 ]; then line="  PASS  $(printf '%-18s' "$label") $(printf '%-42s' "$verdict") invoked=[${invoked:-}]"; pass=$((pass+1))
  else               line="  FAIL  $(printf '%-18s' "$label") $(printf '%-42s' "$verdict") invoked=[${invoked:-}]  -> see $label.stream.jsonl"; fail=$((fail+1)); fi
  echo "$line" | tee -a "$RUN_DIR/summary.txt"
done < <(cat "${SCENARIO_FILES[@]}")

echo "---- pass=$pass fail=$fail" | tee -a "$RUN_DIR/summary.txt"
[ "$fail" -eq 0 ]
