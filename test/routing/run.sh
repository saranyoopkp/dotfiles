#!/usr/bin/env bash
# run.sh — verify skill auto-invocation ใน FRESH claude session, วัดจาก GROUND TRUTH
#
# วัดจาก tool_use จริงใน stream-json (Skill tool ถูกเรียก skill ไหน) — ไม่ใช่ self-report ของ
# โมเดลแล้ว grep (นั่น = confirmation bias: filter เหลือ string ที่อยากเห็น + เชื่อคำโมเดล).
# ให้งาน → สังเกตว่าโมเดล *ทำ* อะไร ไม่ใช่ถามว่ามัน *คิดว่า* ทำอะไร.
# จำกัด tools เหลือ Skill เพราะ suite นี้วัด routing ไม่ได้วัด research/implementation หลัง route.
#
# ทำไม claude -p: subagent สืบทอด context ค้าง โหลด rules/skills ตอนเริ่ม session ไม่ใช่สด.
# ทำไม sandbox นอก dotfiles: รันใน dotfiles จะโหลด dotfiles/CLAUDE.md ปน (ตั้งผ่าน ROUTING_SANDBOX).
# ⚠️ กิน API tokens ต่อ scenario — รันหลังแก้ skill/scenarios ไม่ใช่ทุก commit.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
# on-demand skills ที่มีอยู่ (เพิ่มเมื่อย้าย rule เป็น skill เพิ่ม)
ONDEMAND_SKILLS="ui-ux-baseline data-design api-design ops greenfield-foundation research retro docs-workspace docs-placement docs-setup performance stack-contracts testing-strategy"
SCENARIO_FILES=("$HERE/scenarios.tsv" "$HERE/scenarios-ops.tsv" "$HERE/scenarios-research.tsv" "$HERE/scenarios-retro.tsv" "$HERE/scenarios-docs.tsv" "$HERE/scenarios-compatibility.tsv" "$HERE/scenarios-performance.tsv" "$HERE/scenarios-stack-contracts.tsv" "$HERE/scenarios-testing-strategy.tsv")
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
echo "artifacts (raw stream-json ต่อ scenario): $RUN_DIR"

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

# stdin = stream-json; stdout = รายชื่อ on-demand skill ที่ถูก invoke จริง (space-sep, sorted)
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
            s=str((b.get('input') or {}).get('skill','')).replace(':','-')
            for o in ond:
                if o in s: got.add(o)
sys.stdout.write(' '.join(sorted(got)))
" $ONDEMAND_SKILLS
}

# PHASE 1 — ยิงทุก scenario *ขนานกัน* (แต่ละอันเป็น session อิสระ เขียน artifact ของตัวเอง)
# เร็วกว่าเรียงกันมาก: เวลา ≈ scenario ที่ช้าสุด ไม่ใช่ผลรวม
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
      --tools Skill --agent SCC-v1.0.1 --dangerously-skip-permissions \
      "งาน: $task

วางแผนจริง (ไม่ต้องเขียนโค้ด)" > "$RUN_DIR/$label.stream.jsonl" \
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
echo "ยิง $n scenario (พร้อมกันสูงสุด $MAX_PARALLEL) — รอ..."
for pid in "${batch_pids[@]}"; do wait "$pid"; done
echo "เสร็จ — parse:"

# PHASE 2 — parse artifact (อ่าน scenarios ซ้ำเพื่อรักษาลำดับ)
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
  else               line="  FAIL  $(printf '%-18s' "$label") $(printf '%-42s' "$verdict") invoked=[${invoked:-}]  → ดู $label.stream.jsonl"; fail=$((fail+1)); fi
  echo "$line" | tee -a "$RUN_DIR/summary.txt"
done < <(cat "${SCENARIO_FILES[@]}")

echo "---- pass=$pass fail=$fail" | tee -a "$RUN_DIR/summary.txt"
[ "$fail" -eq 0 ]
