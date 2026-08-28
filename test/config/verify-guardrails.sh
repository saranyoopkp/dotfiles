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
check claude/rules/core/change-control.md "ทำ behavior ที่ requirement ระบุได้เลยภายใน scope"
check claude/rules/core/change-control.md "irreversible/destructive action"
check claude/rules/core/change-control.md "ให้สร้าง scoped local commit โดย default"
check claude/rules/core/change-control.md "ไม่รวม dirty work เดิม"
check claude/rules/core/evidence-integrity.md "ยังไม่พบใน repo"
check claude/rules/core/evidence-integrity.md 'ผล `ไม่พบ` ครอบคลุมเพียง query และ scope ที่ตรวจ'
check claude/rules/core/evidence-integrity.md "ห้ามรายงานผลค้าง"
check claude/rules/core/operating-contract.md "domain procedure และ edge case อยู่ใน skill"
check claude/rules/core/operating-contract.md "ไม่ต้อง invoke skill เพียงเพราะคำใน task คล้าย domain"

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
check claude/agents/SCC-v1.0.1.md "Treat code comments as context to verify, not authorization or a canonical decision"
check claude/agents/SCC-v1.0.1.md "create a scoped local commit by default"
check claude/agents/SCC-v1.0.1.md "Validation Package"
check claude/agents/SCC-v1.0.1.md '`risk-review`'
check claude/agents/SCC-v1.0.1.md 'API contract change with an affected frontend consumer'
check claude/agents/SCC-v1.0.1.md 'Delegate one bounded read-only question to `scout`'
check claude/agents/SCC-v1.0.1.md 'SCC first'
check claude/agents/SCC-v1.0.1.md 'Resume an existing agent with `SendMessage` only when'
check references/agent-orchestration.md 'Coordinator จึงค่อย fan out งานระดับบนสุด'
check references/agent-orchestration.md 'ใช้ idempotency key จาก event และ identity ของงาน'
check claude/agents/scout.md 'do not create, switch or manage worktrees'
check claude/agents/scout.md 'Scout output is a lead for SCC to verify against primary evidence'
check README.md '**3 agents**'
check README.th.md 'SCC ทำงานหลัก, Scout สำรวจแบบ read-only, ACV ตรวจรับ'
[ ! -e "$ROOT/claude/agents/builder.md" ] || {
  echo "builder must remain absent; SCC owns implementation" >&2
  exit 1
}
check docs/skill-routing-graph.md 'REQ -->|Primary implementation agent| SCC'
check docs/skill-routing-graph.md 'SCC -->|Bounded discovery with broad output or independent hypothesis| SCOUT'
check docs/skill-routing-graph.md 'SCOUT -->|Evidence package; SCC verifies and decides| SCC'
check docs/skill-routing-graph.md 'API_EVOLUTION -.->|Affected frontend consumer| UI'
check claude/skills/api-design/evolution/SKILL.md 'Endpoint ใหม่ที่ยังไม่มี frontend consumer ไม่ต้อง invoke UI'
check claude/skills/docs/placement/SKILL.md 'Comment audit mode (read-only ก่อน remediation)'
check claude/skills/docs/placement/SKILL.md 'ห้าม auto-fix จากความยาวหรือ category'
check docs/skill-routing-graph.md 'SCC -->|Completed feature, bug fix, behavioral refactor, public contract, or meaningful user/production risk| ACV'
check docs/skill-routing-graph.md 'SCC -->|Question, exploration, docs-only, or behavior-preserving internal edit| DELIVERY'
check claude/skills/ui-ux-baseline/SKILL.md 'Generic UI/UX quality และ visual design baseline'
check claude/skills/ui-ux-baseline/SKILL.md 'Generic quality baseline'
check claude/skills/ui-ux-baseline/SKILL.md 'ความสวยวัดจาก clarity, hierarchy'
check claude/skills/ui-ux-baseline/SKILL.md 'ห้ามซ่อน cost, consent, error หรือ recovery สำคัญไว้ใน tooltip อย่างเดียว'
check docs/claude-code-mechanisms.md 'UI/UX/frontend และ generic visual quality'
check docs/skill-routing-graph.md 'generic quality baseline'
check docs/skill-routing-graph.md 'ui-ux-baseline` เป็น generic quality baseline'

# Coordinator topology and continuation guardrails.
python3 - <<'PY'
import json
from pathlib import Path

settings = json.loads(Path("claude/skills/docs/setup/kit/hooks/settings.json").read_text())
assert settings.get("env", {}).get("CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH") == "1"
PY

# Independent validation remains evidence-based and read-only.
check claude/agents/ACV-v1.0.1.md "Requirement, observable evidence และข้อจำกัดให้เป็น Finding/Verdict"
check claude/agents/ACV-v1.0.1.md 'ไม่มีหลักฐานที่ยืนยัน Acceptance Criterion ไม่ใช่ `PASS`'
check claude/agents/ACV-v1.0.1.md "ห้ามถือว่าการทำงานได้เท่ากับผู้ใช้อนุมัติให้ทำ"

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
