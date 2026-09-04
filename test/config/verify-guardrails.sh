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
check CLAUDE.md "smallest instruction that covers its root cause"
check CLAUDE.md "pass an ordinary negative case that should not trigger it"
check claude/rules/core/change-control.md "Questions, requests for opinions, and problem reports authorize read-only inspection, not mutation"
check claude/rules/core/change-control.md "Classify the active request as \`explore\`, \`plan\`, \`implement\`, or \`mixed\`"
check claude/rules/core/change-control.md "never edit files or commit merely"
check claude/rules/core/change-control.md "Implement behavior specified by the requirement within scope"
check claude/rules/core/change-control.md "irreversible or destructive action"
check claude/rules/core/change-control.md "create a scoped local commit by default"
check claude/rules/core/change-control.md "exclude pre-existing"
check claude/rules/core/evidence-integrity.md "not found in the repository"
check claude/rules/core/evidence-integrity.md 'A `not found` result covers only the query and scope inspected'
check claude/rules/core/evidence-integrity.md "Never report stale"
check claude/rules/core/operating-contract.md "domain procedures and edge cases belong in"
check claude/rules/core/operating-contract.md "Do not invoke a skill merely because task wording resembles its domain"
check claude/rules/core/operating-contract.md "Material-alternative gate"
check claude/rules/core/operating-contract.md 'required/blocking`, `adjacent`, or `known/deferred`'
check claude/rules/core/operating-contract.md 'speculation'
check claude/rules/core/operating-contract.md 'pain that does not change the outcome as feedback'

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
check README.md 'SCC owns implementation'
[ ! -e "$ROOT/claude/agents/builder.md" ] || {
  echo "builder must remain absent; SCC owns implementation" >&2
  exit 1
}
check docs/skill-routing-graph.md 'REQ -->|Primary implementation agent| SCC'
check docs/skill-routing-graph.md 'API_EVOLUTION -.->|Affected frontend consumer| UI'
check claude/skills/api-design/evolution/SKILL.md 'A new endpoint without a frontend consumer does not require UI'
check claude/skills/api-design/SKILL.md 'POST/PUT/PATCH/DELETE'
check claude/skills/api-design/errors/SKILL.md 'authentication or authorization failures'
check claude/skills/docs/placement/SKILL.md 'Comment audit mode: read-only before remediation'
check claude/skills/docs/placement/SKILL.md 'Never auto-fix based on length or category'
check claude/skills/docs/link/SKILL.md 'does not check whether documentation content still matches code'
check claude/skills/docs/setup/SKILL.md 'lifecycle hooks'
check claude/skills/retro/SKILL.md 'Compare only sessions relevant to the same objective'
check claude/skills/research/technology-vendor/SKILL.md 'Own external comparison and recommendations'
check claude/skills/risk-review/SKILL.md 'destructive, irreversible, or deletion action'
check claude/skills/ui-ux-baseline/SKILL.md 'Generic UI/UX quality, content, and visual-design baseline'
check claude/skills/ui-ux-baseline/SKILL.md 'structure, copy, interaction, state, accessibility, responsive behavior, visual consistency'
check claude/skills/ui-ux-baseline/SKILL.md 'Route on demand to child skills'
check claude/skills/ui-ux-baseline/SKILL.md 'Generic quality baseline'
check claude/skills/ui-ux-baseline/SKILL.md 'clean-up or polish that preserves the existing structure goes to `visual-polish`'
check claude/skills/ui-ux-baseline/SKILL.md 'premium, or distinctive result go to `visual-direction`'
check claude/skills/ui-ux-baseline/SKILL.md 'references, moodboards, or visual benchmarking go to `design-inspiration`'
check claude/skills/ui-ux-baseline/SKILL.md 'Evaluate beauty through clarity, hierarchy'
check claude/skills/ui-ux-baseline/SKILL.md 'never hide important cost, consent, errors, or recovery solely in a tooltip'
check claude/skills/ui-ux-baseline/SKILL.md 'Every user-visible message and element must help users understand'
check claude/skills/ui-ux-baseline/content-copy/SKILL.md 'UI Content Copy'
check claude/skills/ui-ux-baseline/content-copy/SKILL.md 'use a professional-neutral voice'
check claude/skills/ui-ux-baseline/content-copy/SKILL.md 'do not use in place of feedback-notifications, content-localization, or visual-direction'
check claude/skills/ui-ux-baseline/content-copy/SKILL.md 'placeholders must not serve as primary labels'
check claude/skills/ui-ux-baseline/content-copy/SKILL.md 'propose concise options and trade-offs before editing'
check claude/skills/ui-ux-baseline/layout-navigation/SKILL.md '## Navigation state'
check claude/skills/ui-ux-baseline/layout-navigation/SKILL.md 'current route, active navigation item'
check claude/skills/ui-ux-baseline/layout-navigation/SKILL.md 'state belongs in the URL/history and should be shareable or restorable'
check claude/skills/ui-ux-baseline/layout-navigation/SKILL.md 'preserve or restore scroll, focus, and reading position'
check claude/skills/ui-ux-baseline/feedback-notifications/SKILL.md 'professional-neutral'
check claude/skills/ui-ux-baseline/feedback-notifications/SKILL.md 'Avoid excessive familiarity'
check claude/skills/ui-ux-baseline/feedback-notifications/SKILL.md 'project-owned voice and tone convention'
check claude/skills/docs/setup/kit/CLAUDE.template.md 'Optional product voice/tone'
check docs/claude-code-mechanisms.md 'UI/UX/frontend and generic visual quality'
check docs/skill-routing-graph.md 'generic quality baseline'
check docs/skill-routing-graph.md '`ui-ux-baseline` is the generic quality baseline'
check docs/skill-routing-graph.md 'Usability, accessibility, information hierarchy, content clarity, responsive behavior, and visual consistency'
check docs/skill-routing-graph.md 'New identity, redesign, or aesthetic direction'
check docs/skill-routing-graph.md 'Clean/polish existing screen'
check docs/skill-routing-graph.md 'Inspiration, references, moodboard, visual benchmark'
check claude/skills/ui-ux-baseline/design-inspiration/SKILL.md 'Research and synthesize visual references'
check claude/skills/ui-ux-baseline/design-inspiration/SKILL.md 'do not invoke for routine UI implementation, minor polish'
check claude/skills/ui-ux-baseline/design-inspiration/SKILL.md 'Treat references as inputs, not templates'
check claude/skills/ui-ux-baseline/design-inspiration/SKILL.md 'If the request is research-only, deliver the synthesis and stop'
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md 'existing page that users want “more beautiful,” modern, premium, distinctive'
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md 'Do not default to `visual-polish`'
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md 'not hard gates limiting work to polish'
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md 'sibling pages or prior work establish a visual language'
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md 'acceptance floor, not the entire aesthetic outcome'
check claude/skills/ui-ux-baseline/visual-polish/SKILL.md 'Do not use for open-ended design proposals'
check claude/skills/ui-ux-baseline/visual-polish/SKILL.md 'effects such as shadows, blur, gradients, and overlays'
check CLAUDE.md 'Calibrating constraints for creative work'
check CLAUDE.md 'Aesthetic preferences, conventions, “do the minimum,” “reuse what exists,”'
check CLAUDE.md '“make it look better” authorizes auditing and proposing alternatives'
check CLAUDE.md 'Present two or three options with trade-offs and a recommendation'
check CLAUDE.md 'Waiting for a selection is not returning the decision with a broad question'
check CLAUDE.md 'Tie a hard gate to a concrete harmful failure mode'
check CLAUDE.md 'include a negative case showing that it does not'
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md 'Proposal gate'
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md 'propose two or three meaningfully distinct directions'
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md 'Make proposals concrete and decision-ready'
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md 'does not authorize selecting a direction and immediately writing code or making mutations'
check claude/skills/ui-ux-baseline/visual-direction/SKILL.md 'Wait for the user to select or specify a direction'
check claude/agents/SCC-v1.0.1.md 'Do not add code comments by default'
check claude/agents/SCC-v1.0.1.md 'never use comments to narrate code, explain a diff, justify work, or preserve history'
check claude/skills/docs/placement/SKILL.md 'Do not write by default'
check claude/skills/docs/placement/SKILL.md 'code, types, tests, and good names cannot express'
check claude/skills/docs/setup/kit/CLAUDE.template.md 'If code explains it, do not write a comment'
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
absent claude/rules/engineering/documentation-discipline.md "two lines or longer"
absent claude/skills/docs/placement/SKILL.md "two lines or longer"
absent claude/agents/SCC-v1.0.1.md "Behavioral Gates (trigger → action)"
absent memory/code-comments-why-plus-pointer.md "comments longer than two lines must move"
check memory/code-comments-why-plus-pointer.md "not line count"
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
python3 "$ROOT/test/config/verify-doc-counts.py"

echo "guardrail ownership and instruction budgets verified"
