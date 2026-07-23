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
check claude/agents/ACV-v1.0.1.md 'ไม่มีหลักฐานที่ยืนยัน Acceptance Criterion ไม่ใช่ `PASS`'
check claude/agents/ACV-v1.0.1.md "ทุก Finding ต้องมี"
check claude/agents/ACV-v1.0.1.md "ห้ามถือว่าการทำงานได้เท่ากับผู้ใช้อนุมัติให้ทำ"
check claude/agents/ACV-v1.0.1.md "อย่างใดอย่างหนึ่งแทนกันไม่ได้"
check claude/agents/ACV-v1.0.1.md "ตรวจการจำแนก behavioral change"
check claude/agents/ACV-v1.0.1.md "ไม่ใช่ตัดสินแทนผู้ใช้ว่าควรเลือกทางใด"
check claude/rules/documentation-discipline.md "ตั้งแต่ 2 บรรทัด"
check claude/skills/docs/placement/SKILL.md "ตั้งแต่ 2 บรรทัดขึ้นไป"
check claude/skills/api-design/SKILL.md "Idempotency-Key"
check claude/skills/data-design/SKILL.md "ห้ามใส่ cache จนกว่าจะตอบครบ 3 ข้อ"
check claude/skills/ui-ux-baseline/SKILL.md "interactive element ทุกชนิด"
check claude/skills/ui-ux-baseline/resource-states/SKILL.md "เกิดได้จริงจาก data flow"
check claude/skills/ui-ux-baseline/realtime-conversation/SKILL.md "scroll ขึ้น = ปลด sticky"
check claude/skills/ui-ux-baseline/interaction-a11y/SKILL.md "focus-visible"
check claude/skills/ui-ux-baseline/feedback-notifications/SKILL.md "อย่าเริ่มด้วย Toast เพราะทำง่าย"
check claude/skills/ui-ux-baseline/feedback-notifications/SKILL.md "partial failure ห้ามสรุปว่า “สำเร็จ”"
check claude/skills/ops/infra-change/SKILL.md "ก่อน apply อธิบาย target, plan, risk, rollback/mitigation และขอ authorization"
check claude/skills/ops/incident-response/SKILL.md "owner authorization ก่อนทำ"
check claude/skills/ops/observability/SKILL.md "event log เงียบอย่างเดียวไม่ใช่ health signal"
check claude/skills/docs/setup/kit/CLAUDE.template.md 'เป็น **link**'
check claude/skills/docs/setup/kit/CLAUDE.template.md "Research escalation — เริ่มที่ repo แต่ห้ามจมอยู่ใน repo"

echo "guardrails verified"
