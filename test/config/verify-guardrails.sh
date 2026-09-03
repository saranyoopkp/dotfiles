#!/usr/bin/env bash
# Structural guardrails: protect decision boundaries without freezing prose or duplicated checklists.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

check() {
  local file="$1" pattern="$2"
  rg -q --fixed-strings "$pattern" "$ROOT/$file" || {
    echo "missing guardrail: $file :: $pattern" >&2
    exit 1
  }
}

absent() {
  local file="$1" pattern="$2"
  ! rg -q --fixed-strings "$pattern" "$ROOT/$file" || {
    echo "obsolete/overfitted instruction remains: $file :: $pattern" >&2
    exit 1
  }
}

max_lines() {
  local label="$1" limit="$2" file="$3" actual
  actual="$(wc -l < "$file" | tr -d ' ')"
  [ "$actual" -le "$limit" ] || {
    echo "instruction budget exceeded: $label = $actual lines (limit $limit)" >&2
    exit 1
  }
}

# Core safety and autonomy boundaries.
check CLAUDE.md "แก้ behavioral incident ด้วย instruction ที่เล็กที่สุดซึ่งครอบ root cause"
check CLAUDE.md "negative/non-trigger"
check claude/rules/core/change-control.md "คำถาม ขอความเห็น หรือรายงานปัญหาอนุญาตให้ตรวจแบบ read-only ไม่ใช่ mutation"
check claude/rules/core/change-control.md "จำแนกคำขอปัจจุบันเป็น \`explore\`, \`plan\`, \`implement\` หรือ \`mixed\`"
check claude/rules/core/change-control.md "ห้ามแก้ไฟล์หรือ"
check claude/rules/core/change-control.md "ทำ behavior ที่ requirement ระบุได้เลยภายใน scope"
check claude/rules/core/change-control.md "irreversible/destructive action"
check claude/rules/core/change-control.md "ให้สร้าง scoped local commit โดย default"
check claude/rules/core/change-control.md "ไม่รวม dirty work เดิม"
check claude/rules/core/evidence-integrity.md "ยังไม่พบใน repo"
check claude/rules/core/evidence-integrity.md 'ผล `ไม่พบ` ครอบคลุมเพียง query และ scope ที่ตรวจ'
check claude/rules/core/evidence-integrity.md "ห้ามรายงานผลค้าง"
check claude/rules/core/operating-contract.md "domain procedure และ edge case อยู่ใน skill"
check claude/rules/core/operating-contract.md "ไม่ต้อง invoke skill เพียงเพราะคำใน task คล้าย domain"
check claude/rules/core/operating-contract.md "Material-alternative gate"
check claude/rules/core/operating-contract.md 'required/blocking`, `adjacent` หรือ `known/deferred`'
check claude/rules/core/operating-contract.md 'speculation'
check claude/rules/core/operating-contract.md 'pain ที่ไม่เปลี่ยน outcome ไม่ต้อง surface เป็น feedback'

# Thin risk classifier routes to progressive disclosure.
check claude/rules/risk/risk-boundaries.md 'Invoke `risk-review`'
check claude/skills/risk-review/SKILL.md "Read only the reference matching the active risk surface"
for ref in authorization external-integrations money-time production; do
  [ -f "$ROOT/claude/skills/risk-review/references/$ref.md" ] || {
    echo "missing risk-review reference: $ref" >&2
    exit 1
  }
done

# Primary agent owns execution behavior, not copies of every shared rule.
check claude/agents/SCC-v1.0.1.md "Do not restate every rule or narrate each internal classification"
check claude/agents/SCC-v1.0.1.md "Resolve ordinary reversible details autonomously"
check claude/agents/SCC-v1.0.1.md "classify the active request as \`explore\`, \`plan\`, \`implement\`, or \`mixed\`"
check claude/agents/SCC-v1.0.1.md "Keep \`explore\` and \`plan\` read-only"
check claude/agents/SCC-v1.0.1.md "suggest an optional ACV review to the user"
check claude/agents/SCC-v1.0.1.md "Do not invoke ACV, block delivery"
check claude/agents/SCC-v1.0.1.md "Treat code comments as context to verify, not authorization or a canonical decision"
check claude/agents/SCC-v1.0.1.md "create a scoped local commit by default"
check claude/agents/SCC-v1.0.1.md '`risk-review`'
check claude/agents/SCC-v1.0.1.md 'API contract change with an affected frontend consumer'
check claude/agents/SCC-v1.0.1.md 'at most one evidence-backed adjacent alternative'
check claude/agents/SCC-v1.0.1.md 'evidence → impact → alternative → why not done → defer trigger'
check claude/agents/SCC-v1.0.1.md 'Do not surface style preference, generic cleanup'
check README.md 'manual decisions made'
check README.th.md 'SCC ทำงานหลัก, Scout สำรวจแบบ read-only, ACV ตรวจรับ'
[ ! -e "$ROOT/claude/agents/builder.md" ] || {
  echo "builder must remain absent; SCC owns implementation" >&2
  exit 1
}
check docs/skill-routing-graph.md 'REQ -->|Primary implementation agent| SCC'
check docs/skill-routing-graph.md 'API_EVOLUTION -.->|Affected frontend consumer| UI'
check claude/skills/api-design/evolution/SKILL.md 'Endpoint ใหม่ที่ยังไม่มี frontend consumer ไม่ต้อง invoke UI'
check claude/skills/api-design/SKILL.md 'POST/PUT/PATCH/DELETE'
check claude/skills/api-design/errors/SKILL.md 'authentication/authorization failure'
check claude/skills/docs/placement/SKILL.md 'Comment audit mode (read-only ก่อน remediation)'
check claude/skills/docs/placement/SKILL.md 'ห้าม auto-fix จากความยาวหรือ category'
check claude/skills/docs/link/SKILL.md 'ไม่ตรวจว่าเนื้อหาเอกสารยังตรงกับโค้ด'
check claude/skills/docs/setup/SKILL.md 'lifecycle hooks'
check claude/skills/retro/SKILL.md 'เทียบหลาย session'
check claude/skills/research/technology-vendor/SKILL.md 'external comparison และ recommendation'
check claude/skills/risk-review/SKILL.md 'destructive, irreversible, or deletion action'
check claude/skills/ui-ux-baseline/SKILL.md 'Generic UI/UX quality, content และ visual design baseline'
check claude/skills/ui-ux-baseline/SKILL.md 'โครงสร้าง, copy, interaction, state, accessibility, responsive behavior, visual consistency'
check claude/skills/ui-ux-baseline/SKILL.md 'แบบ on-demand; ไม่โหลด child ทั้งหมดโดย default'
check claude/skills/ui-ux-baseline/SKILL.md 'Generic quality baseline'
check claude/skills/ui-ux-baseline/SKILL.md 'งาน clean/polish ที่คงโครงเดิมไป `visual-polish`'
check claude/skills/ui-ux-baseline/SKILL.md 'premium หรือมี character ไป `visual-direction`'
check claude/skills/ui-ux-baseline/SKILL.md 'ความสวยวัดจาก clarity, hierarchy'
check claude/skills/ui-ux-baseline/SKILL.md 'ห้ามซ่อน cost, consent, error หรือ recovery สำคัญไว้ใน tooltip อย่างเดียว'
check claude/skills/ui-ux-baseline/SKILL.md 'ทุกข้อความและองค์ประกอบที่ผู้ใช้เห็นต้องช่วยให้เข้าใจ'
check claude/skills/ui-ux-baseline/content-copy/SKILL.md 'UI Content Copy'
check claude/skills/ui-ux-baseline/content-copy/SKILL.md 'ใช้ professional-neutral'
check claude/skills/ui-ux-baseline/content-copy/SKILL.md 'ไม่ใช้แทน feedback-notifications, content-localization หรือ visual-direction'
check claude/skills/ui-ux-baseline/content-copy/SKILL.md 'ไม่ใช้ placeholder เป็น label หลัก'
check claude/skills/ui-ux-baseline/content-copy/SKILL.md 'ให้เสนอทางเลือกสั้น ๆ พร้อม trade-off ก่อนแก้'
check claude/skills/ui-ux-baseline/layout-navigation/SKILL.md '## Navigation state'
check claude/skills/ui-ux-baseline/layout-navigation/SKILL.md 'current route, active navigation item'
check claude/skills/ui-ux-baseline/layout-navigation/SKILL.md 'URL/history และควร share หรือ restore ได้'
check claude/skills/ui-ux-baseline/layout-navigation/SKILL.md 'scroll, focus และตำแหน่งการอ่าน'
check claude/skills/ui-ux-baseline/feedback-notifications/SKILL.md 'professional-neutral'
check claude/skills/ui-ux-baseline/feedback-notifications/SKILL.md 'หลีกเลี่ยงภาษากันเองเกินไป'
check claude/skills/ui-ux-baseline/feedback-notifications/SKILL.md 'project-owned voice/tone convention'
check claude/skills/docs/setup/kit/CLAUDE.template.md 'optional product voice/tone'
check docs/claude-code-mechanisms.md 'UI/UX/frontend และ generic visual quality'
check docs/skill-routing-graph.md 'generic quality baseline'
check docs/skill-routing-graph.md 'ui-ux-baseline` เป็น generic quality baseline'
check docs/skill-routing-graph.md 'usability, accessibility, information hierarchy, content clarity, responsive behavior และ visual consistency'
check docs/skill-routing-graph.md 'New identity, redesign, or aesthetic direction'
check docs/skill-routing-graph.md 'Clean/polish existing screen'
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md 'หน้าเดิมที่ผู้ใช้ขอ “สวยขึ้น”, modern, premium, distinctive'
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md 'ห้าม default ไป'
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md 'ไม่ใช่ hard gate ให้ทำได้แค่ polish'
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md 'visual language จากหน้าพี่น้องหรืองานก่อนหน้า'
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md 'acceptance floor ไม่ใช่ผลลัพธ์ทั้งหมดของงาน aesthetic'
check claude/skills/ui-ux-baseline/visual-polish/SKILL.md 'ไม่ใช้เมื่อผู้ใช้ขอเสนอ design, ทำให้สวยขึ้นแบบเปิดกว้าง'
check claude/skills/ui-ux-baseline/visual-polish/SKILL.md 'effect เช่น shadow, blur, gradient, overlay'
check CLAUDE.md 'Calibrate constraints for creative work'
check CLAUDE.md 'aesthetic preference, convention, “ทำให้น้อยที่สุด”, “ใช้ของเดิม”'
check CLAUDE.md 'คำขอเช่น “ทำให้สวยขึ้น” อนุญาตให้ audit และเสนอทางเลือก'
check CLAUDE.md 'เสนอ 2–3 ทางพร้อม trade-off และ recommendation แล้วรอผู้ใช้เลือก'
check CLAUDE.md 'การรอผู้ใช้เลือกไม่ใช่การโยน decision กลับด้วยคำถามกว้าง ๆ'
check CLAUDE.md 'hard gate ต้องผูกกับ failure mode ที่เสียหายจริง'
check CLAUDE.md 'negative case ยืนยันว่าไม่กดงานสร้างสรรค์'
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md 'Proposal gate'
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md 'เสนอ 2–3 direction ที่แตกต่างกันพอให้เลือกได้'
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md 'ต้องเป็น proposal ที่เห็นภาพและนำไปตัดสินใจได้จริง'
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md 'authorization ให้เลือก direction แล้วเขียน code หรือทำ mutation ทันที'
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md 'รอผู้ใช้เลือกหรือระบุ direction'
check claude/agents/SCC-v1.0.1.md 'Do not add code comments by default'
check claude/agents/SCC-v1.0.1.md 'never use comments to narrate code, explain a diff, justify work, or preserve history'
check claude/skills/docs/placement/SKILL.md 'ไม่เขียนเป็นค่าเริ่มต้น'
check claude/skills/docs/placement/SKILL.md 'code, type, test หรือชื่อที่ดีแสดงเองไม่ได้'
check claude/skills/docs/setup/kit/CLAUDE.template.md 'ถ้า code อธิบายได้แล้วไม่ต้องเขียน comment'
check test/routing/run.sh 'find "$ROOT/claude/skills" -type f -name SKILL.md -print0'
check test/routing/run.sh "tr -d '\\r'"
check test/routing/scenarios.tsv 'ui-visual-direction-existing'
check test/friction/scenarios.tsv 'intent-phase'

routing_registry="$(ROUTING_LIST_SKILLS=1 bash "$ROOT/test/routing/run.sh")"
routing_registry_count="$(printf '%s\n' "$routing_registry" | sed '/^$/d' | wc -l | tr -d ' ')"
skill_file_count="$(find "$ROOT/claude/skills" -type f -name SKILL.md | wc -l | tr -d ' ')"
[ "$routing_registry_count" -eq "$skill_file_count" ] || {
  echo "routing registry is incomplete: registry=$routing_registry_count files=$skill_file_count" >&2
  exit 1
}
printf '%s\n' "$routing_registry" | grep -qx 'docs-link' || {
  echo "routing registry omitted docs-link" >&2
  exit 1
}

# Independent validation remains evidence-based and read-only.
check claude/agents/ACV-v1.0.1.md "turns requirements, observable evidence, and constraints into Findings and a Verdict"
check claude/agents/ACV-v1.0.1.md 'Absence of evidence confirming an Acceptance Criterion is not `PASS`'
check claude/agents/ACV-v1.0.1.md "never treat working software as proof that the user authorized the work"

# Skill references must use the canonical owners instead of undefined named gates.
if rg -n -i 'behavior.?change gate|behavioral/compatibility gate|report-integrity gate|calibrated-action' "$ROOT/claude/skills"; then
  echo "undefined named gate remains in skill instructions" >&2
  exit 1
fi

# Regressions that previously created universal ceremony.
absent claude/rules/engineering/documentation-discipline.md "ตั้งแต่ 2 บรรทัด"
absent claude/skills/docs/placement/SKILL.md "ตั้งแต่ 2 บรรทัด"
absent claude/agents/SCC-v1.0.1.md "Behavioral Gates (trigger → action)"
absent memory/code-comments-why-plus-pointer.md "ก่อนเขียน comment >2 บรรทัด"
check memory/code-comments-why-plus-pointer.md "ไม่ใช่จำนวนบรรทัด"
[ -x "$ROOT/test/friction/run.sh" ] || {
  echo "missing executable simple-task friction regression" >&2
  exit 1
}

# Keep always-on context and the default primary agent intentionally small.
rule_lines="$(find "$ROOT/claude/rules" -name '*.md' -type f -exec cat {} + | wc -l | tr -d ' ')"
[ "$rule_lines" -le 220 ] || {
  echo "instruction budget exceeded: always-on rules = $rule_lines lines (limit 220)" >&2
  exit 1
}
max_lines "SCC primary agent" 160 "$ROOT/claude/agents/SCC-v1.0.1.md"
max_lines "Scout agent" 60 "$ROOT/claude/agents/scout.md"

# Ownership map covers every current always-on rule and top-level skill entry point.
while IFS= read -r file; do
  rel="${file#"$ROOT/"}"
  check docs/claude-code-mechanisms.md "$rel"
done < <(find "$ROOT/claude/rules" -name '*.md' -type f | sort)
while IFS= read -r file; do
  rel="${file#"$ROOT/"}"
  check docs/claude-code-mechanisms.md "$rel"
done < <(find "$ROOT/claude/skills" -mindepth 2 -maxdepth 2 -name SKILL.md -type f | sort)

python3 "$ROOT/test/config/verify-skill-routing-graph.py" "$ROOT" --self-test
python3 "$ROOT/test/config/test-comment-audit.py"

echo "guardrail ownership and instruction budgets verified"
