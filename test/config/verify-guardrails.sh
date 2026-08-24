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

check_map_entry() {
  local path="$1"
  rg -q --fixed-strings "$path" "$ROOT/docs/claude-code-mechanisms.md" || {
    echo "missing ownership-map entry: $path" >&2
    exit 1
  }
}

check claude/agents/SCC-v1.0.1.md 'current objective + primary deliverable + acceptance evidence'
check claude/agents/SCC-v1.0.1.md "คำถามไม่ใช่ authorization"
check claude/agents/SCC-v1.0.1.md "ย้อนกลับง่าย"
check claude/agents/SCC-v1.0.1.md "ย้อนยาก"
check claude/agents/SCC-v1.0.1.md "ย้อนกลับไม่ได้/กระทบภายนอกอย่างมีนัยสำคัญ"
check claude/agents/SCC-v1.0.1.md "resume objective เดิมเอง"
check claude/agents/SCC-v1.0.1.md '`required/blocking`, `adjacent` หรือ `known/deferred`'
check claude/agents/SCC-v1.0.1.md "invoke skill และ child ที่ตรง"
check claude/agents/SCC-v1.0.1.md 'claim → observable result → probe → result'
check claude/agents/SCC-v1.0.1.md '`SendMessage`'
check claude/agents/SCC-v1.0.1.md '`idle_notification`'
check claude/agents/SCC-v1.0.1.md "สร้าง local commit จาก task-owned paths/hunks"
check claude/agents/SCC-v1.0.1.md "Test fixture, injected state และ diagnostic evidence ต้องสังเกต deliverable"
check claude/agents/SCC-v1.0.1.md "อธิบายเชิงการทำงานก่อน technical detail"
check claude/agents/SCC-v1.0.1.md "ส่ง Acceptance Validator ตรวจ"
check claude/agents/ACV-v1.0.1.md "ACV เป็น read-only"
check claude/agents/ACV-v1.0.1.md "Implementation, developer report และ test summary เป็น context"
check claude/agents/ACV-v1.0.1.md 'requirement → observable result → probe → actual'
check claude/agents/ACV-v1.0.1.md "หลักฐานต้องสังเกต deliverable ไม่ใช่เปลี่ยน deliverable"
check claude/agents/ACV-v1.0.1.md "PASS with known limitations"
check claude/agents/ACV-v1.0.1.md "ยังไม่สามารถสรุปได้"
check claude/agents/ACV-v1.0.1.md 'impact map `คงไว้ / ย้าย / เปลี่ยน / ถอด / ยังไม่ยืนยัน`'
check CLAUDE.md "Design invariant — แต่ละ surface สร้างคุณค่าต่างกัน"
check CLAUDE.md '| `agents/` | trigger → judgment → action → verification/reporting'
check CLAUDE.md '| `rules/` | shared/safety invariant'
check CLAUDE.md '| `skills/` | domain procedure, decision criteria'
check CLAUDE.md "invariant → trigger/action → domain procedure"
check CLAUDE.md 'ของ repo นั้น ๆ (relative จาก Git root)'
check claude/rules/core/operating-contract.md "Bind กับหลักการและ outcome ไม่ใช่ตัวอย่าง"
check claude/rules/core/operating-contract.md '`required/blocking`, `adjacent`'
check claude/rules/core/operating-contract.md '`known/deferred`'
check claude/rules/core/operating-contract.md "Domain procedure อยู่ใน skill แบบ on-demand"
check claude/rules/core/operating-contract.md "ห้ามลด safety floor ของ rules"
check claude/rules/core/operating-contract.md "ห้ามวนอ่านโค้ดเพื่อเดาข้อจำกัดภายนอก"
check claude/rules/core/operating-contract.md "Research และ recommendation ให้ decision evidence ไม่ใช่ authorization"
check claude/rules/core/evidence-integrity.md 'ยังไม่พบใน repo'
check claude/rules/core/evidence-integrity.md 'claim → observable result → probe → result'
check claude/rules/core/evidence-integrity.md 'ผล `ไม่พบ` พิสูจน์ได้เพียง query นั้น'
check claude/rules/core/evidence-integrity.md "artifact ไม่พิสูจน์ว่า active"
check claude/rules/core/evidence-integrity.md "revision/worktree/environment ปัจจุบัน"
check claude/rules/core/evidence-integrity.md "Report, transcript, summary และ subagent result เป็น input"
check claude/rules/core/evidence-integrity.md "atomic status, provenance, checked date และ owner"
check claude/rules/core/evidence-integrity.md "Failure escalation"
check claude/rules/core/change-control.md "ไม่ใช่ authorization ให้ mutate"
check claude/rules/core/change-control.md "local commit เฉพาะ task-owned paths/hunks"
check claude/rules/core/change-control.md "Push, deploy, amend/rebase/history rewrite"
check claude/rules/core/change-control.md "ย้อนกลับได้ง่าย"
check claude/rules/core/change-control.md "ย้อนยาก"
check claude/rules/core/change-control.md "ย้อนกลับไม่ได้/เสียหายยากกู้"
check claude/rules/core/change-control.md "Objective continuity"
check claude/rules/core/change-control.md "resume เมื่อ next action ยัง authorized/safe"
check claude/rules/core/change-control.md "ห้ามแทน deliverable ด้วย readiness, finding หรือ report"
check claude/rules/core/change-control.md "Semantic/breaking change ต้องมี alternatives"
check claude/rules/core/change-control.md "ห้ามใช้ cleanup ซ่อน scope หรือ big-bang"
check claude/rules/core/change-control.md '`คงไว้ | ย้าย old → new | เปลี่ยน behavior | ถอดออก | ยังไม่ยืนยัน`'
check claude/rules/core/change-control.md "ใช้ task tracking ก่อน mutation"
check claude/rules/engineering/documentation-discipline.md "ตั้งแต่ 2 บรรทัด"
check claude/rules/engineering/documentation-discipline.md "current state ไม่ใช่ changelog"
check claude/rules/engineering/documentation-discipline.md "Fact มี canonical owner เดียว"
check claude/rules/engineering/documentation-discipline.md "authoritative owner/live source"
check claude/rules/engineering/documentation-discipline.md "Pre-existing/known/deferred"
check claude/rules/engineering/documentation-discipline.md "sync pointer + recall hook"
check claude/rules/engineering/documentation-discipline.md '`docs/private/` หรือ `memory/private/`'
check claude/rules/engineering/documentation-discipline.md "public interface contract ใช้ docstring"
check claude/rules/engineering/compatibility-rollout.md "Expand → Migrate → Contract"
check claude/rules/engineering/compatibility-rollout.md "release order ไม่สำคัญ"
check claude/rules/engineering/compatibility-rollout.md "change ตามทิศทาง dependency"
check claude/rules/engineering/compatibility-rollout.md "ตรวจ action จริงที่ consumer"
check claude/rules/engineering/compatibility-rollout.md "CI/review มองเห็นและสะดุดเมื่อขาด"
check claude/rules/engineering/compatibility-rollout.md "tab/mobile client ที่ยังไม่ refresh"
check claude/rules/engineering/compatibility-rollout.md "message/event เก่าที่ค้างถึง consumer ใหม่"
check claude/rules/engineering/compatibility-rollout.md "feature flag, dual-read และ dual-write"
check claude/rules/engineering/performance-discipline.md 'invoke `performance`'
check claude/rules/engineering/performance-discipline.md "ไม่ต้อง invoke"
check claude/rules/engineering/stack-contracts.md 'invoke `stack-contracts`'
check claude/rules/engineering/stack-contracts.md "owner/consumer เดียวไม่ต้อง invoke"
check claude/rules/engineering/testing-strategy.md 'invoke `testing-strategy`'
check claude/rules/engineering/testing-strategy.md "ไม่ต้อง invoke"
check claude/rules/risk/authz-multitenancy.md "Enforce authorization ที่ server และ deny by default"
check claude/rules/risk/authz-multitenancy.md "Tenant/actor มาจาก trusted auth context"
check claude/rules/risk/authz-multitenancy.md "cross-tenant"
check claude/rules/risk/external-integration-safety.md "persist raw input ที่ replay ได้"
check claude/rules/risk/external-integration-safety.md "deduplicate ก่อน side effect"
check claude/rules/risk/external-integration-safety.md "Official contract ยืนยัน provider semantics"
check claude/rules/risk/money-handling.md "ไม่ใช้ binary float"
check claude/rules/risk/money-handling.md "amount ต้องมี currency"
check claude/rules/risk/money-handling.md "Split/allocation ต้อง reconcile"
check claude/rules/risk/production-recovery.md "Secret ที่หลุดถือว่า compromised"
check claude/rules/risk/production-recovery.md "Health วัด dependency และสถานะปัจจุบัน"
check claude/rules/risk/production-recovery.md "restore ต้องเคยซ้อม"
check claude/rules/risk/production-recovery.md "หลัง deploy ตรวจ consumer flow/health path"
check claude/rules/risk/time-timezone.md "Instant เก็บเป็น UTC"
check claude/rules/risk/time-timezone.md "business timezone"
check claude/rules/risk/time-timezone.md "calendar arithmetic ต้องรองรับ DST"
check claude/rules/risk/time-timezone.md "Schedule/cron ระบุ timezone"
check claude/skills/api-design/SKILL.md 'inventory `list/get/create/update/delete`'
check claude/skills/api-design/SKILL.md "inventory เป็นการวิเคราะห์ ไม่ใช่ authorization"
check claude/skills/greenfield-foundation/SKILL.md "LTS & Compatibility Gate — บังคับทุก greenfield"
check claude/skills/greenfield-foundation/SKILL.md "ห้ามใช้ความจำของ model ยืนยัน “current LTS”"
check claude/skills/greenfield-foundation/SKILL.md "clean install/build/runtime"
check claude/skills/research/SKILL.md "research:security-advisories"
check claude/skills/research/SKILL.md "research:technology-vendor"
check claude/skills/research/SKILL.md "research:product-market-user"
check claude/skills/research/SKILL.md "research:research-control"
check claude/skills/research/research-control/SKILL.md "timebox ห้ามแปลงความไม่รู้เป็นคำตอบ"
check claude/skills/research/security-advisories/SKILL.md "present → affected version → vulnerable configuration/precondition → reachable/exposed"
check claude/skills/research/technology-vendor/SKILL.md "total cost ไม่ใช่ราคาเริ่มต้น"
check claude/skills/research/product-market-user/SKILL.md "synthetic persona, fabricated quote, market size"
check claude/skills/retro/SKILL.md "เป็น read-only โดย default"
check claude/skills/retro/SKILL.md "ห้ามนับข้อความอ้างถึงเหตุการณ์เดิมเป็น occurrence ใหม่"
check claude/skills/retro/SKILL.md "ตรวจของเดิมใน repository ก่อนเสนอเพิ่ม"
check claude/skills/retro/SKILL.md "instruction gap"
check claude/skills/retro/SKILL.md "objective loss"
check claude/skills/retro/SKILL.md "reopened deferred issue"
check claude/skills/retro/SKILL.md "ผู้ใช้ขอ retro/session feedback"
check claude/skills/retro/SKILL.md "Test/Harness"
check claude/skills/retro/SKILL.md "ยังไม่ควรแก้ dotfiles"
check claude/skills/retro/SKILL.md "ห้ามทำ mutation หลังรายงาน"
check claude/skills/performance/SKILL.md "symptom และ metric ที่กระทบ"
check claude/skills/performance/SKILL.md "จากความคุ้นเคยกับ pattern อย่างเดียว"
check claude/skills/performance/SKILL.md "baseline → change → result → variance/coverage → trade-off"
check claude/skills/stack-contracts/SKILL.md "duplication เป็น contract เดียวจริงหรือเพียงหน้าตาคล้ายกัน"
check claude/skills/stack-contracts/SKILL.md "consumer เดียวหรือ contract ยังไม่นิ่งให้เก็บกับ owner ก่อน"
check claude/skills/stack-contracts/SKILL.md "ห้ามปล่อยสองมาตรฐานโดยไม่มี owner/exit"
check claude/skills/stack-contracts/SKILL.md "folder boundary"
check claude/skills/testing-strategy/SKILL.md "claim → failure mode → observable result → cheapest reliable test"
check claude/skills/testing-strategy/SKILL.md "ห้ามซ้ำเพื่อจำนวน"
check claude/skills/testing-strategy/SKILL.md "test ที่ผ่านยืนยันเฉพาะ path/input/environment ที่รัน"
check claude/skills/testing-strategy/SKILL.md "independent oracle"
check claude/skills/testing-strategy/SKILL.md "smoke consumer flow จริงก่อนปล่อย"
check claude/skills/testing-strategy/SKILL.md 'planned / runnable / measured'
check claude/skills/testing-strategy/SKILL.md "ห้ามเปลี่ยนงานเป็นการเขียน coverage report"
if rg -q 'ทางที่ดีกว่าที่เห็นแต่ไม่ได้ทำ|ปิดงานทุกครั้งด้วยบรรทัดนี้' \
  "$ROOT/claude/rules/core/operating-contract.md" "$ROOT/claude/agents/SCC-v1.0.1.md"; then
  echo "mandatory adjacent-proposal footer must stay removed" >&2
  exit 1
fi
if find "$ROOT/claude/rules" -maxdepth 1 -type f -name '*.md' | rg -q .; then
  echo "rules must be owned by core/, engineering/, or risk/" >&2
  exit 1
fi
check claude/skills/docs/placement/SKILL.md "ตั้งแต่ 2 บรรทัดขึ้นไป"
check claude/skills/docs/placement/SKILL.md "pointer ที่ commit ต้อง resolve จาก clone ของ repo"
check claude/skills/docs/placement/SKILL.md "แม้ยังไม่มีไฟล์จริง"
check claude/skills/docs/placement/SKILL.md '`docs/` กองแบนเกิน ~7 ไฟล์'
check claude/skills/docs/placement/SKILL.md "index ใน CLAUDE.md ต้อง grouped"
check claude/skills/docs/placement/SKILL.md "หนึ่งบรรทัดต่อไฟล์พร้อมชื่อ + hook"
check claude/skills/docs/placement/SKILL.md "shared memory ที่ create/move/rename/delete"
check claude/skills/docs/SKILL.md "/docs:workspace"
check claude/skills/docs/workspace/SKILL.md "มีหลาย independent Git roots"
check claude/skills/docs/workspace/SKILL.md "workspace-relative"
check claude/skills/docs/workspace/SKILL.md "fact/topic | current home | evidence | proposed owner | reason | action"
check claude/skills/docs/workspace/SKILL.md "report จาก agent/audit เป็น lead ไม่ใช่ proof"
check claude/skills/docs/workspace/SKILL.md "## Authority และ query routing"
check claude/skills/docs/workspace/SKILL.md "ปิดวงจรเมื่อ owner fact เปลี่ยน"
check claude/skills/docs/setup/SKILL.md 'ของ repo นั้น ๆ (relative จาก Git root)'
check claude/skills/docs/setup/SKILL.md "shared memory lifecycle"
check claude/skills/docs/setup/kit/hooks/docs-drift.sh "New multi-line line-comment(s)"
check claude/skills/docs/setup/kit/hooks/docs-drift.sh "stop_hook_active"
check claude/skills/docs/setup/kit/hooks/docs-drift.sh '"decision":"block"'
check test/config/verify-docs-drift-stop.sh "docs-drift ownership, authorization, pointer, comment, and Stop convergence verified"
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
check claude/skills/api-design/evolution/SKILL.md "feature flag/rollout mechanism"
check claude/skills/data-design/SKILL.md "data-design:lifecycle-governance"
check claude/skills/data-design/SKILL.md "ใช้ทันทีเมื่อวางแผน, ออกแบบ, review"
check claude/skills/data-design/SKILL.md "แม้ยังไม่มี schema/repo จริงหรือผู้ใช้ขอเพียงแผน"
check claude/skills/data-design/caching/SKILL.md "ห้ามใส่ cache จนกว่าจะตอบครบ 3 ข้อ"
check claude/skills/data-design/transactions-invariants/SKILL.md "transactional outbox"
check claude/skills/data-design/lifecycle-governance/SKILL.md "soft delete ไม่ใช่ privacy erasure"
check claude/skills/ui-ux-baseline/SKILL.md "interactive element ทุกชนิด"
check claude/skills/ui-ux-baseline/SKILL.md "ใช้ทันทีเมื่อวางแผน, ออกแบบ, review"
check claude/skills/ui-ux-baseline/SKILL.md "แม้ยังไม่มีไฟล์จริงหรือผู้ใช้ขอเพียงแผน"
check claude/skills/ui-ux-baseline/SKILL.md "ui-ux-baseline:visual-direction"
check claude/skills/ui-ux-baseline/SKILL.md "ui-ux-baseline:motion-microinteractions"
check claude/skills/ui-ux-baseline/SKILL.md "ui-ux-baseline:design-foundations"
check claude/skills/ui-ux-baseline/SKILL.md "ui-ux-baseline:content-localization"
check claude/skills/ui-ux-baseline/SKILL.md "decorative emoji ใน UI"
check claude/skills/ui-ux-baseline/SKILL.md "สิ่งที่ผู้ใช้สังเกตได้ ผลกระทบ และสิ่งที่ทำต่อได้"
check claude/skills/ui-ux-baseline/SKILL.md "ห้ามเปลี่ยน product copy หรือ surface เพียงเพื่อให้ screenshot หรือ test artifact อธิบายตัวเองได้"
check claude/skills/ui-ux-baseline/resource-states/SKILL.md "เกิดได้จริงจาก data flow"
check claude/skills/ui-ux-baseline/realtime-conversation/SKILL.md "scroll ขึ้น = ปลด sticky"
check claude/skills/ui-ux-baseline/interaction-a11y/SKILL.md "focus-visible"
check claude/skills/ui-ux-baseline/interaction-a11y/SKILL.md "prefers-reduced-motion"
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md "aesthetic thesis"
check claude/skills/ui-ux-baseline/visual-polish/SKILL.md "shadow, blur, gradient, overlay"
check claude/skills/ui-ux-baseline/motion-microinteractions/SKILL.md "prefers-reduced-motion"
check claude/skills/ui-ux-baseline/design-foundations/SKILL.md "color/contrast"
check claude/skills/ui-ux-baseline/design-foundations/SKILL.md "ห้ามใช้ emoji ตกแต่ง UI โดย default"
check claude/skills/ui-ux-baseline/design-foundations/SKILL.md "ให้เสนอ icon ที่มี semantic ตรงจาก library เดิมแทน"
check claude/skills/ui-ux-baseline/design-foundations/SKILL.md "Refactor Icon & Emoji"
check claude/skills/ui-ux-baseline/content-localization/SKILL.md "ห้ามสร้างระบบ i18n ขนาน"
check claude/skills/ui-ux-baseline/content-localization/SKILL.md "Extract โดยคง behavior"
check claude/skills/ui-ux-baseline/feedback-notifications/SKILL.md "อย่าเริ่มด้วย Toast เพราะทำง่าย"
check claude/skills/ui-ux-baseline/feedback-notifications/SKILL.md "partial failure ห้ามสรุปว่า “สำเร็จ”"
check claude/skills/ops/infra-change/SKILL.md "ก่อน apply อธิบาย target, plan, risk, rollback/mitigation และขอ authorization"
check claude/skills/ops/incident-response/SKILL.md "owner authorization ก่อนทำ"
check claude/skills/ops/observability/SKILL.md "event log เงียบอย่างเดียวไม่ใช่ health signal"
check claude/skills/docs/setup/kit/CLAUDE.template.md 'เป็น **link**'
check claude/skills/docs/setup/kit/CLAUDE.template.md "Research escalation — เริ่มที่ repo แต่ห้ามจมอยู่ใน repo"
check claude/skills/docs/setup/kit/CLAUDE.template.md "research/recommendation ไม่ใช่ approval"
check claude/skills/docs/setup/kit/CLAUDE.template.md "## Complexity proposal"
check claude/skills/docs/setup/kit/CLAUDE.template.md "## Execution tracking"
check claude/skills/docs/setup/kit/CLAUDE.template.md "## Report integrity"
check claude/skills/docs/setup/kit/CLAUDE.template.md "## Durable findings"
check claude/skills/docs/setup/kit/CLAUDE.template.md "harness ไม่เปิดตาม pointer เอง"
check claude/skills/docs/setup/kit/CLAUDE.template.md 'ของ repo นั้น ๆ (relative จาก Git root)'
check claude/skills/docs/setup/kit/CLAUDE.template.md "shared memory index lifecycle"
check claude/skills/docs/setup/kit/CLAUDE.template.md "feature flag/dual-read/dual-write ต้องมี owner"
check claude/skills/docs/setup/kit/CLAUDE.template.md "pointer ที่ commit ต้อง resolve จาก clone ของ repo"
check claude/skills/docs/setup/kit/memory/MEMORY.md "ไม่พบใน index ≠ ไม่มี private memory"
check claude/skills/docs/setup/kit/memory/MEMORY.md "create/move/rename/delete shared leaf"
check claude/skills/docs/setup/kit/memory/MEMORY.md "ห้ามคัดเนื้อ fact จาก leaf มาใส่ใน index"
check claude/skills/docs/setup/kit/README.md 'กติกา self-contained ของ kit อยู่ใน `CLAUDE.template.md`'
check claude/skills/docs/setup/kit/README.md 'ของ repo นั้น ๆ (relative จาก Git root)'
check claude/skills/docs/setup/kit/README.md "shared memory create/move/rename/delete"
check claude/skills/docs/setup/kit/memory/README.md 'ของ repo นั้น ๆ (relative จาก Git root)'
check claude/skills/docs/setup/kit/memory/README.md "create/move/rename/delete shared leaf"
check claude/skills/docs/setup/kit/memory/README.md '`MEMORY.md` เก็บเฉพาะ pointer + recall hook'
check claude/skills/docs/setup/kit/init.sh 'git -C "$requested_target" rev-parse --show-toplevel'
check claude/skills/docs/setup/kit/init.sh "printf '/docs/private/"
check claude/skills/docs/setup/kit/init.sh "printf '/memory/private/"
if rg -q 'กติกา .*อยู่ที่ rule' "$ROOT/claude/skills/docs/setup/kit/README.md"; then
  echo "docs topology ownership in kit README is stale" >&2
  exit 1
fi
check test/routing/run.sh "docs-workspace docs-placement docs-setup"
check test/routing/run.sh "scenarios-compatibility.tsv"
check test/routing/scenarios-docs.tsv "docs-placement"
check test/routing/scenarios-docs.tsv "docs-setup"
check test/routing/scenarios-compatibility.tsv "compat-local"
check CLAUDE.md "current owner/routing map"
check docs/claude-code-mechanisms.md "Current ownership map"
check docs/claude-code-mechanisms.md "ไม่พิสูจน์ semantic equivalence"

while IFS= read -r rule; do
  check_map_entry "${rule#"$ROOT/"}"
done < <(find "$ROOT/claude/rules" -type f -name '*.md' | sort)

while IFS= read -r router; do
  check_map_entry "${router#"$ROOT/"}"
done < <(find "$ROOT/claude/skills" -mindepth 2 -maxdepth 2 -type f -name SKILL.md | sort)

while IFS= read -r child; do
  parent="$(dirname "$(dirname "$child")")/SKILL.md"
  name="$(sed -n 's/^name:[[:space:]]*//p' "$child" | head -n 1 | tr -d '\r')"
  if [[ ! -f "$parent" || -z "$name" ]] || ! rg -q --fixed-strings "$name" "$parent"; then
    echo "child skill is not routed by parent: ${child#"$ROOT/"} :: $name" >&2
    exit 1
  fi
done < <(find "$ROOT/claude/skills" -mindepth 3 -type f -name SKILL.md | sort)

bash "$ROOT/test/config/verify-docs-drift-stop.sh"
echo "guardrails verified"
