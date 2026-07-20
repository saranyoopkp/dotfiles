#!/usr/bin/env bash
# run.sh — verify skill auto-invocation ใน FRESH claude session, วัดจาก GROUND TRUTH
#
# วัดจาก tool_use จริงใน stream-json (Skill tool ถูกเรียก skill ไหน) — ไม่ใช่ self-report ของ
# โมเดลแล้ว grep (นั่น = confirmation bias: filter เหลือ string ที่อยากเห็น + เชื่อคำโมเดล).
# ให้งาน → สังเกตว่าโมเดล *ทำ* อะไร ไม่ใช่ถามว่ามัน *คิดว่า* ทำอะไร.
#
# ทำไม claude -p: subagent สืบทอด context ค้าง โหลด rules/skills ตอนเริ่ม session ไม่ใช่สด.
# ทำไม sandbox นอก dotfiles: รันใน dotfiles จะโหลด dotfiles/CLAUDE.md ปน (ตั้งผ่าน ROUTING_SANDBOX).
# ⚠️ กิน API tokens ต่อ scenario — รันหลังแก้ skill/scenarios ไม่ใช่ทุก commit.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
# on-demand skills ที่มีอยู่ (เพิ่มเมื่อย้าย rule เป็น skill เพิ่ม)
ONDEMAND_SKILLS="ui-ux-baseline data-design api-design"
[ -f "$HERE/.local.sh" ] && . "$HERE/.local.sh"
if [ -n "${ROUTING_SANDBOX:-}" ]; then
  SANDBOX="$ROUTING_SANDBOX"; mkdir -p "$SANDBOX"
else
  SANDBOX="$(mktemp -d)"; trap 'rm -rf "$SANDBOX"' EXIT
fi
pass=0; fail=0
RUN_DIR="$SANDBOX/runs/$(date +%Y%m%d-%H%M%S)"; mkdir -p "$RUN_DIR"
echo "artifacts (raw stream-json ต่อ scenario): $RUN_DIR"

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
            s=str((b.get('input') or {}).get('skill',''))
            for o in ond:
                if o in s: got.add(o)
sys.stdout.write(' '.join(sorted(got)))
" $ONDEMAND_SKILLS
}

# PHASE 1 — ยิงทุก scenario *ขนานกัน* (แต่ละอันเป็น session อิสระ เขียน artifact ของตัวเอง)
# เร็วกว่าเรียงกันมาก: เวลา ≈ scenario ที่ช้าสุด ไม่ใช่ผลรวม
n=0
while IFS=$'\t' read -r expect label task; do
  case "${expect:-}" in ''|'#'*) continue ;; esac
  ( cd "$SANDBOX" && timeout 180 claude -p --output-format stream-json --verbose \
      --agent SCC-v1.0 --dangerously-skip-permissions \
      "งาน: $task

วางแผนจริง (ไม่ต้องเขียนโค้ด)" > "$RUN_DIR/$label.stream.jsonl" 2>/dev/null ) &
  n=$((n+1))
done < "$HERE/scenarios.tsv"
echo "ยิง $n scenario ขนานกัน — รอ..."
wait
echo "เสร็จ — parse:"

# PHASE 2 — parse artifact (อ่าน scenarios ซ้ำเพื่อรักษาลำดับ)
while IFS=$'\t' read -r expect label task; do
  case "${expect:-}" in ''|'#'*) continue ;; esac
  invoked="$(invoked_skills < "$RUN_DIR/$label.stream.jsonl")"
  # PASS: expect=NONE → ไม่มี on-demand skill fire | expect=<skill> → skill นั้น fire (related
  # co-fire เพิ่มได้ เพราะ domain เนื้อทับกัน เช่น webhook↔data-design queue/retry — ไม่ใช่ over-invoke)
  if [ "$expect" = "NONE" ]; then [ -z "$invoked" ] && ok=1 || ok=0
  else ok=1; for e in $expect; do echo " $invoked " | grep -q " $e " || ok=0; done; fi
  if [ "$ok" = 1 ]; then line="  PASS  $(printf '%-12s' "$label") expect=$(printf '%-14s' "$expect") invoked=[${invoked:-}]"; pass=$((pass+1))
  else               line="  FAIL  $(printf '%-12s' "$label") expect=$(printf '%-14s' "$expect") invoked=[${invoked:-}]  → ดู $label.stream.jsonl"; fail=$((fail+1)); fi
  echo "$line" | tee -a "$RUN_DIR/summary.txt"
done < "$HERE/scenarios.tsv"

echo "---- pass=$pass fail=$fail" | tee -a "$RUN_DIR/summary.txt"
[ "$fail" -eq 0 ]
