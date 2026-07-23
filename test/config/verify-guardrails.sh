#!/usr/bin/env bash
# Guardrails that must survive wording/refactor changes.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
check() {
  local file="$1" pattern="$2"
  rg -q --fixed-strings "$pattern" "$ROOT/$file" || {
    echo "missing guardrail: $file :: $pattern" >&2
    exit 1
  }
}

check claude/agents/SCC-v1.0.1.md "Anti-Guessing Protocol"
check claude/agents/SCC-v1.0.1.md "Validation Package"
check claude/agents/SCC-v1.0.1.md "ข้อความคำขอและ scope ที่ผู้ใช้อนุมัติ"
check claude/agents/SCC-v1.0.1.md "comment ตั้งแต่ 2 บรรทัดขึ้นไป"
check claude/agents/SCC-v1.0.1.md "ห้ามวนอ่านโค้ดเพื่อเดาข้อจำกัดภายนอก"
check claude/agents/SCC-v1.0.1.md "แยกคำถาม/ข้อสังเกตออกจากคำสั่งให้ดำเนินการ"
check claude/agents/SCC-v1.0.1.md "ลอง alternative ที่สมเหตุสมผลหนึ่งทาง"
check claude/agents/SCC-v1.0.1.md "สร้าง task list **ก่อน mutation**"
check claude/rules/00-how-to-read-these-rules.md "Execution-tracking gate"
check claude/agents/ACV-v1.0.1.md 'ไม่มีหลักฐานที่ยืนยัน Acceptance Criterion ไม่ใช่ `PASS`'
check claude/agents/ACV-v1.0.1.md "ทุก Finding ต้องมี"
check claude/agents/ACV-v1.0.1.md "Verification ที่จำเป็นล้มเหลว, ถูก skip หรือรันไม่ได้"
check claude/agents/ACV-v1.0.1.md "ห้ามถือว่าการทำงานได้เท่ากับผู้ใช้อนุมัติให้ทำ"
check claude/agents/ACV-v1.0.1.md "อย่างใดอย่างหนึ่งแทนกันไม่ได้"
check claude/agents/ACV-v1.0.1.md "ตรวจการจำแนก behavioral change"
check claude/agents/ACV-v1.0.1.md "ไม่ใช่ตัดสินแทนผู้ใช้ว่าควรเลือกทางใด"
check claude/rules/documentation-discipline.md "ตั้งแต่ 2 บรรทัด"
check claude/skills/docs/placement/SKILL.md "ตั้งแต่ 2 บรรทัดขึ้นไป"
check claude/skills/docs/setup/kit/hooks/docs-drift.sh "New multi-line line-comment(s)"
if rg -q 'docs:placement|docs-setup|/docs:' "$ROOT/claude/skills/docs/setup/kit/hooks/docs-drift.sh"; then
  echo "hook must not reference an optional skill" >&2
  exit 1
fi
check claude/skills/api-design/SKILL.md "api-design:contract-core"
check claude/skills/api-design/contract-core/SKILL.md "OpenAPI หรือ JSON Schema"
check claude/skills/api-design/errors/SKILL.md "Problem Details"
check claude/skills/api-design/collections/SKILL.md "tie-breaker ที่ stable"
check claude/skills/api-design/mutations/SKILL.md "Idempotency-Key"
check claude/skills/api-design/async-operations/SKILL.md "202 Accepted"
check claude/skills/api-design/caching-concurrency/SKILL.md "If-Match"
check claude/skills/api-design/evolution/SKILL.md "behavioral-change gate"
check claude/skills/data-design/SKILL.md "ห้ามใส่ cache จนกว่าจะตอบครบ 3 ข้อ"
check claude/skills/ui-ux-baseline/SKILL.md "interactive element ทุกชนิด"
check claude/skills/ui-ux-baseline/SKILL.md "ui-ux-baseline:visual-direction"
check claude/skills/ui-ux-baseline/resource-states/SKILL.md "เกิดได้จริงจาก data flow"
check claude/skills/ui-ux-baseline/realtime-conversation/SKILL.md "scroll ขึ้น = ปลด sticky"
check claude/skills/ui-ux-baseline/interaction-a11y/SKILL.md "focus-visible"
check claude/skills/ui-ux-baseline/interaction-a11y/SKILL.md "prefers-reduced-motion"
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md "aesthetic thesis"
check claude/skills/ui-ux-baseline/feedback-notifications/SKILL.md "อย่าเริ่มด้วย Toast เพราะทำง่าย"
check claude/skills/ui-ux-baseline/feedback-notifications/SKILL.md "partial failure ห้ามสรุปว่า “สำเร็จ”"
check claude/skills/ops/infra-change/SKILL.md "ก่อน apply อธิบาย target, plan, risk, rollback/mitigation และขอ authorization"
check claude/skills/ops/incident-response/SKILL.md "owner authorization ก่อนทำ"
check claude/skills/ops/observability/SKILL.md "event log เงียบอย่างเดียวไม่ใช่ health signal"
check claude/skills/docs/setup/kit/CLAUDE.template.md 'เป็น **link**'
check claude/skills/docs/setup/kit/CLAUDE.template.md "Research escalation — เริ่มที่ repo แต่ห้ามจมอยู่ใน repo"
check claude/skills/docs/setup/kit/CLAUDE.template.md "## Execution tracking"

echo "guardrails verified"
