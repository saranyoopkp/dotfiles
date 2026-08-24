#!/usr/bin/env bash
# Guard behavior, safety floors, and ownership without freezing incidental prose.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

check() {
  local file="$1" pattern="$2"
  rg -q --fixed-strings -- "$pattern" "$ROOT/$file" || {
    echo "missing guardrail: $file :: $pattern" >&2
    exit 1
  }
}

check_map_entry() {
  local path="$1"
  rg -q --fixed-strings -- "$path" "$ROOT/docs/claude-code-mechanisms.md" || {
    echo "missing ownership-map entry: $path" >&2
    exit 1
  }
}

# Project ownership and layer boundaries.
check CLAUDE.md "Design invariant — แต่ละ surface สร้างคุณค่าต่างกัน"
check CLAUDE.md '| `agents/` | trigger → judgment → action → verification/reporting'
check CLAUDE.md '| `rules/` | shared/safety invariant'
check CLAUDE.md '| `skills/` | domain procedure, decision criteria'
check CLAUDE.md "invariant → trigger/action → domain procedure"
check CLAUDE.md "current owner/routing map"
check docs/claude-code-mechanisms.md "Current ownership map"
check docs/claude-code-mechanisms.md "ไม่พิสูจน์ semantic equivalence"

# Agent behavior kernels.
check claude/agents/SCC-v1.0.1.md 'current objective + primary deliverable + acceptance evidence'
check claude/agents/SCC-v1.0.1.md "คำถามไม่ใช่ authorization"
check claude/agents/SCC-v1.0.1.md "ย้อนกลับง่าย"
check claude/agents/SCC-v1.0.1.md "ย้อนยาก"
check claude/agents/SCC-v1.0.1.md "ย้อนกลับไม่ได้/กระทบภายนอกอย่างมีนัยสำคัญ"
check claude/agents/SCC-v1.0.1.md "resume objective เดิมเอง"
check claude/agents/SCC-v1.0.1.md '`required/blocking`, `adjacent` หรือ `known/deferred`'
check claude/agents/SCC-v1.0.1.md '`SendMessage`'
check claude/agents/SCC-v1.0.1.md "สร้าง local commit จาก task-owned paths/hunks"
check claude/agents/SCC-v1.0.1.md "Test fixture, injected state และ diagnostic evidence ต้องสังเกต deliverable"
check claude/agents/SCC-v1.0.1.md "อธิบายเชิงการทำงานก่อน technical detail"
check claude/agents/SCC-v1.0.1.md "การเปิด capability ไม่ใช่ authorization ให้สร้างทีม"
check claude/agents/SCC-v1.0.1.md "minimal foundation, dependency/order และ contract owner"
check claude/agents/SCC-v1.0.1.md "parallel เฉพาะ slices ที่ contract และ path ownership ไม่ทับกัน"
check claude/agents/SCC-v1.0.1.md "review/rollback แยกได้"
check claude/agents/SCC-v1.0.1.md '`Agent` ด้วย `isolation: "worktree"`'
check claude/agents/SCC-v1.0.1.md "coordinator เข้า integration worktree"
check claude/agents/SCC-v1.0.1.md "coordinator เป็น owner ของ Git index"
check claude/agents/SCC-v1.0.1.md 'ห้าม direct merge/cherry-pick เข้า root checkout หรือ `main`'
check claude/agents/ACV-v1.0.1.md "ACV เป็น read-only"
check claude/agents/ACV-v1.0.1.md "model: opus"
check claude/agents/ACV-v1.0.1.md "Implementation, developer report และ test summary เป็น context"
check claude/agents/ACV-v1.0.1.md 'requirement → observable result → probe → actual'
check claude/agents/ACV-v1.0.1.md "หลักฐานต้องสังเกต deliverable ไม่ใช่เปลี่ยน deliverable"
check claude/agents/ACV-v1.0.1.md "PASS with known limitations"
check claude/agents/ACV-v1.0.1.md "ยังไม่สามารถสรุปได้"
check claude/agents/scout.md "model: haiku"
check claude/agents/scout.md "without changing code, config, docs, data, Git state or external systems"
check claude/agents/scout.md "stop and request"
check claude/agents/builder.md "model: sonnet"
check claude/agents/builder.md "foundation/shared contracts, owned paths"
check claude/agents/builder.md 'Do not call `EnterWorktree`'
check claude/agents/builder.md "return the branch, commit and declared PR base"
check claude/agents/builder.md "do not stage, commit, reset or clean Git state"

if rg -q '^isolation:' "$ROOT/claude/agents/builder.md" ||
   rg -q '^tools:.*EnterWorktree' "$ROOT/claude/agents/builder.md"; then
  echo "coordinator/runtime must own Builder worktree assignment" >&2
  exit 1
fi

# Always-on rules: retain shared judgment and safety floors, not every example.
check claude/rules/core/operating-contract.md '`required/blocking`, `adjacent`'
check claude/rules/core/operating-contract.md '`known/deferred`'
check claude/rules/core/operating-contract.md "Domain procedure อยู่ใน skill แบบ on-demand"
check claude/rules/core/operating-contract.md "version/protocol mismatch และ operator remediation"
check claude/rules/core/evidence-integrity.md 'claim → observable result → probe → result'
check claude/rules/core/evidence-integrity.md "artifact ไม่พิสูจน์ว่า active"
check claude/rules/core/evidence-integrity.md "Failure escalation"
check claude/rules/core/change-control.md "ไม่ใช่ authorization ให้ mutate"
check claude/rules/core/change-control.md "local commit เฉพาะ task-owned paths/hunks"
check claude/rules/core/change-control.md "Push, deploy, amend/rebase/history rewrite"
check claude/rules/core/change-control.md "Objective continuity"
check claude/rules/core/change-control.md "ห้ามแทน deliverable ด้วย readiness, finding หรือ report"
check claude/rules/engineering/documentation-discipline.md "ตั้งแต่ 2 บรรทัด"
check claude/rules/engineering/documentation-discipline.md "Fact มี canonical owner เดียว"
check claude/rules/engineering/documentation-discipline.md '`docs/private/` หรือ `memory/private/`'
check claude/rules/engineering/compatibility-rollout.md "Expand → Migrate → Contract"
check claude/rules/engineering/compatibility-rollout.md "product copy ไม่ใช่ integration control plane"
check claude/rules/engineering/performance-discipline.md 'invoke `performance`'
check claude/rules/engineering/stack-contracts.md 'invoke `stack-contracts`'
check claude/rules/engineering/testing-strategy.md 'invoke `testing-strategy`'
check claude/rules/risk/authz-multitenancy.md "Enforce authorization ที่ server และ deny by default"
check claude/rules/risk/external-integration-safety.md "deduplicate ก่อน side effect"
check claude/rules/risk/money-handling.md "ไม่ใช้ binary float"
check claude/rules/risk/production-recovery.md "Secret ที่หลุดถือว่า compromised"
check claude/rules/risk/production-recovery.md "restore ต้องเคยซ้อม"
check claude/rules/risk/time-timezone.md "Instant เก็บเป็น UTC"
check claude/rules/risk/time-timezone.md "Schedule/cron ระบุ timezone"

# On-demand procedures: retain one or two decision-critical invariants per domain.
check claude/skills/greenfield-foundation/SKILL.md "ห้ามใช้ความจำของ model ยืนยัน “current LTS”"
check claude/skills/research/research-control/SKILL.md "timebox ห้ามแปลงความไม่รู้เป็นคำตอบ"
check claude/skills/research/security-advisories/SKILL.md "present → affected version → vulnerable configuration/precondition → reachable/exposed"
check claude/skills/retro/SKILL.md "เป็น read-only โดย default"
check claude/skills/retro/SKILL.md "ห้ามนับข้อความอ้างถึงเหตุการณ์เดิมเป็น occurrence ใหม่"
check claude/skills/retro/SKILL.md "ห้ามทำ mutation หลังรายงาน"
check claude/skills/performance/SKILL.md "baseline → change → result → variance/coverage → trade-off"
check claude/skills/stack-contracts/SKILL.md "duplication เป็น contract เดียวจริงหรือเพียงหน้าตาคล้ายกัน"
check claude/skills/testing-strategy/SKILL.md "claim → failure mode → observable result → cheapest reliable test"
check claude/skills/testing-strategy/SKILL.md "ห้ามเปลี่ยนงานเป็นการเขียน coverage report"
check claude/skills/docs/placement/SKILL.md "pointer ที่ commit ต้อง resolve จาก clone ของ repo"
check claude/skills/docs/workspace/SKILL.md "report จาก agent/audit เป็น lead ไม่ใช่ proof"
check claude/skills/api-design/mutations/SKILL.md "Idempotency-Key"
check claude/skills/api-design/evolution/SKILL.md "behavioral-change gate"
check claude/skills/data-design/transactions-invariants/SKILL.md "transactional outbox"
check claude/skills/data-design/lifecycle-governance/SKILL.md "soft delete ไม่ใช่ privacy erasure"
check claude/skills/ui-ux-baseline/SKILL.md "interactive element ทุกชนิด"
check claude/skills/ui-ux-baseline/SKILL.md "ห้ามเปลี่ยน product copy หรือ surface เพียงเพื่อให้ screenshot หรือ test artifact อธิบายตัวเองได้"
check claude/skills/ui-ux-baseline/SKILL.md '`ui-ux-baseline:surface-audit`'
check claude/skills/ui-ux-baseline/surface-audit/SKILL.md "keyword match หรือ no-match เป็น coverage"
check claude/skills/ui-ux-baseline/surface-audit/SKILL.md "copy บน UI ไม่ใช่ตัวควบคุม rollout"
check claude/skills/ui-ux-baseline/surface-audit/SKILL.md "entry path ของผู้ใช้"
check claude/skills/ui-ux-baseline/interaction-a11y/SKILL.md "focus-visible"
check claude/skills/ui-ux-baseline/interaction-a11y/SKILL.md "prefers-reduced-motion"
check claude/skills/ops/infra-change/SKILL.md "ก่อน apply อธิบาย target, plan, risk, rollback/mitigation และขอ authorization"
check claude/skills/ops/incident-response/SKILL.md "owner authorization ก่อนทำ"
check claude/skills/ops/observability/SKILL.md "event log เงียบอย่างเดียวไม่ใช่ health signal"

# Docs kit is copied into other repositories, so its safety and portability remain explicit.
check claude/skills/docs/setup/kit/hooks/docs-drift.sh "New multi-line line-comment(s)"
check claude/skills/docs/setup/kit/hooks/docs-drift.sh "stop_hook_active"
check claude/skills/docs/setup/kit/hooks/docs-drift.sh '"decision":"block"'
check claude/skills/docs/setup/kit/hooks/settings.json '"PostToolUse"'
check claude/skills/docs/setup/kit/hooks/settings.json '"matcher": "Edit|Write"'
check claude/skills/docs/setup/kit/CLAUDE.template.md "research/recommendation ไม่ใช่ approval"
check claude/skills/docs/setup/kit/CLAUDE.template.md "pointer ที่ commit ต้อง resolve จาก clone ของ repo"
check claude/skills/docs/setup/kit/memory/MEMORY.md "ไม่พบใน index ≠ ไม่มี private memory"
check claude/skills/docs/setup/kit/memory/MEMORY.md "ห้ามคัดเนื้อ fact จาก leaf มาใส่ใน index"
check claude/skills/docs/setup/kit/init.sh 'git -C "$requested_target" rev-parse --show-toplevel'
check claude/skills/docs/setup/kit/init.sh "ขาด PostToolUse(Edit|Write)"
check claude/skills/docs/setup/kit/init.sh "printf '/docs/private/"
check claude/skills/docs/setup/kit/init.sh "printf '/memory/private/"

if rg -q 'ทางที่ดีกว่าที่เห็นแต่ไม่ได้ทำ|ปิดงานทุกครั้งด้วยบรรทัดนี้' \
  "$ROOT/claude/rules/core/operating-contract.md" "$ROOT/claude/agents/SCC-v1.0.1.md"; then
  echo "mandatory adjacent-proposal footer must stay removed" >&2
  exit 1
fi

if find "$ROOT/claude/rules" -maxdepth 1 -type f -name '*.md' | rg -q .; then
  echo "rules must be owned by core/, engineering/, or risk/" >&2
  exit 1
fi

if rg -q 'docs:placement|docs-setup|/docs:' "$ROOT/claude/skills/docs/setup/kit/hooks/docs-drift.sh"; then
  echo "hook must not reference an optional skill" >&2
  exit 1
fi

# Every installed skill must have lean, one-line routing metadata.
while IFS= read -r skill; do
  rel="${skill#"$ROOT/"}"
  if [[ "$(sed -n '1p' "$skill" | tr -d '\r')" != "---" ]] ||
     [[ "$(rg -c '^name:[[:space:]]*[^[:space:]]+' "$skill")" != "1" ]] ||
     [[ "$(rg -c '^description:[[:space:]]*[^[:space:]].*' "$skill")" != "1" ]]; then
    echo "invalid skill frontmatter: $rel" >&2
    exit 1
  fi
done < <(find "$ROOT/claude/skills" -type f -name SKILL.md | sort)

# Every agent must expose discoverable one-line routing metadata.
while IFS= read -r agent; do
  rel="${agent#"$ROOT/"}"
  if [[ "$(sed -n '1p' "$agent" | tr -d '\r')" != "---" ]] ||
     [[ "$(rg -c '^name:[[:space:]]*[^[:space:]]+' "$agent")" != "1" ]] ||
     [[ "$(rg -c '^description:[[:space:]]*[^[:space:]].*' "$agent")" != "1" ]]; then
    echo "invalid agent frontmatter: $rel" >&2
    exit 1
  fi
done < <(find "$ROOT/claude/agents" -type f -name '*.md' | sort)

# Ownership map and parent routers must cover every rule/router/child.
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

# Harnesses must stay syntactically runnable and retain routing coverage.
while IFS= read -r script; do bash -n "$script"; done \
  < <(find "$ROOT/test" "$ROOT/claude/skills/docs/setup/kit" -type f -name '*.sh' | sort)
check test/routing/run.sh "--tools Skill"
check test/routing/run.sh "docs-workspace docs-placement docs-setup"
check test/routing/run.sh "scenarios-compatibility.tsv"
check test/routing/scenarios-docs.tsv "docs-placement"
check test/routing/scenarios-docs.tsv "docs-setup"
check test/routing/scenarios-compatibility.tsv "compat-local"

bash "$ROOT/test/config/verify-docs-drift-stop.sh"
echo "guardrails verified"
