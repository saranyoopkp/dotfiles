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
check claude/agents/SCC-v1.0.1.md "comment ตั้งแต่ 2 บรรทัดขึ้นไป"
check claude/agents/ACV-v1.0.1.md 'ไม่มีหลักฐานที่ยืนยัน Acceptance Criterion ไม่ใช่ `PASS`'
check claude/agents/ACV-v1.0.1.md "ทุก Finding ต้องมี"
check claude/rules/documentation-discipline.md "ตั้งแต่ 2 บรรทัด"
check claude/skills/docs/placement/SKILL.md "ตั้งแต่ 2 บรรทัดขึ้นไป"
check claude/skills/api-design/SKILL.md "Idempotency-Key"
check claude/skills/data-design/SKILL.md "ห้ามใส่ cache จนกว่าจะตอบครบ 3 ข้อ"
check claude/skills/ui-ux-baseline/SKILL.md "เกิดได้จริงจาก data flow"
check claude/skills/docs/setup/kit/CLAUDE.template.md 'เป็น **link**'

echo "guardrails verified"
