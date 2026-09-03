# dotfiles — personal Claude Code configuration

Status: active · repository: private · this configuration is shared across machines through links or junctions

[`README.md`](README.md) is the canonical owner of project vision and scope. This file contains only the
operational context for working with the repository.

## Working with this repository

- `claude/rules/` contains concise safety invariants loaded in every session; domain procedures belong in skills.
- `claude/skills/` contains task-specific playbooks; descriptions are routing signals and bodies load on invocation.
- `claude/agents/` contains role definitions manually triggered by the user: SCC, Scout, and ACV.
- `references/` and `docs/` provide on-demand reference material.
- `test/routing/` and `test/metrics/` test routing and measure behavior; consult each directory's README.

## Configuration design rules

- Rules and agent specifications must remain generic: do not include real system names or work-repository details.
- A new rule must address a proven recurring problem, pass an ordinary negative case that should not trigger it,
  and be incorporated into an existing rule before creating a new file.
- Every instruction must add decision leverage by materially improving how the agent understands, decides, acts,
  verifies, or recovers. Substance does not require brevity, but every detail must provide context or change actual
  behavior; remove prose, checklists, ceremony, and duplication that do neither.
- State desired behavior or a decision path before prohibitions. Reserve prohibitions for boundaries with real
  harm, and include the trigger, reason, and next action or alternative that keeps work moving.
- Before retaining an instruction, ask: “How would removing this make decisions, actions, or verification worse?”
  Reduce or remove it when there is no concrete answer.
- Correct a behavioral incident with the smallest instruction that covers its root cause. Do not encode the
  transcript, a case-specific example, or an incident-shaped checklist as a universal workflow. Add a negative or
  non-trigger case when overfitting is plausible, and stop once one rule plus one regression proves the behavior.
- **Design invariant—each surface creates different value:**

  | Surface | Appropriate content |
  |---|---|
  | `agents/` | Practitioner trigger → judgment → action → verification/reporting |
  | `rules/` | Shared or safety invariants that must always hold and justify every-session context |
  | `skills/` | Domain procedures, decision criteria, and edge cases needed for that kind of work |
  | `docs/` | Rationale, evidence, and operational context useful to future decisions |
  | `tests/` | Evidence of observable behavior, routing, or invariants at risk of regression |
  | `memory/` | Durable facts or preferences that reduce repeated discovery and explanation across sessions |

- One concern may span layers only as `invariant → trigger/action → domain procedure`. Do not copy the same prose
  or checklist across layers without adding responsibility, and do not reduce a safety floor to a pointer that
  may never be read.
- Put recoverable, task-type-specific detail in a skill; put cross-cutting or high-impact invariants in rules.
- Group skills only when a genuinely distinct sub-concern can be routed independently, not for hypothetical growth.
- Keep only operational context in this `CLAUDE.md`; long rationale, experiment results, and snapshots belong in `docs/`.
- `docs:setup` and artifacts in its kit are exceptions: copied artifacts must be self-contained because a target
  repository may not have the dotfiles agents, rules, or skills.

## Calibrating constraints for creative work

- Distinguish work with fixed correctness or risk constraints from creative or open-ended work before applying
  strict rules. Safety, privacy, data integrity, public contracts, accessibility, and user-stated constraints remain
  hard constraints. Aesthetic preferences, conventions, “do the minimum,” “reuse what exists,” and “avoid
  decoration” are defaults to weigh against the brief, not automatic vetoes.
- For creative direction, aesthetics, novelty, or alternatives, preserve room for a point of view. Produce a
  coherent direction with rationale and trade-offs, then check whether it conflicts with an actual constraint.
  Do not reduce the task to safety, consistency, or tidiness checklists.
- When an open aesthetic choice materially affects composition, identity, approach, or scope, a request such as
  “make it look better” authorizes auditing and proposing alternatives but not choosing a direction and mutating
  autonomously. Present two or three options with trade-offs and a recommendation, then wait for the user's choice.
  Implement once the user specifies or selects a direction; continue minor polish that creates no new creative decision.
- Waiting for a selection is not returning the decision with a broad question. First create evidence-informed,
  concrete proposals the user can evaluate, then ask them to choose or refine the direction.
- Tie a hard gate to a concrete harmful failure mode, a clear trigger, and a path forward. Treat preferences and
  aesthetic risk controls as guidance or review questions rather than refusal conditions.
- Before adding an instruction to prevent bias or overfitting, include a negative case showing that it does not
  suppress unrelated creative work, and stop at the smallest calibration that separates hard constraints from
  creative freedom.

## Installation and compatibility

- `install.sh` creates links on macOS and Linux; use Git Bash for Windows deployment and hook scripts.
- `~/.claude/skills` belongs to the harness: link each skill separately rather than linking the whole directory.
- Link `~/.claude/agents` and `~/.claude/rules` as whole directories from the repository; before installation,
  back up any legacy non-link agent path using a collision-safe name.
- Deployment and hook scripts use one Bash implementation; analysis tools under `test/` may use Python.
- A live hook may have a different environment from the agent's Bash tool. After changing a hook, have the user
  restart the session and verify live behavior before concluding that the issue is resolved.

## Documentation and memory

- `/docs:setup` establishes or updates a repository documentation system; `claude/skills/docs/setup/kit/` is the
  source of truth for its mechanism.
- `/docs:workspace` assigns fact and cross-repository document ownership in workspaces with multiple independent
  Git roots. A single repository or monorepo continues to use the normal setup and placement model.
- Templates are copied during initial setup and do not synchronize automatically. Reapplication must merge while
  preserving repository customization.
- Repository memory lives in the repository and is linked into the harness. Put private data in that repository's
  `docs/private/` or `memory/private/`, relative to its Git root, and add it to `.gitignore`.

## Verification and change management

- The current ownership and routing map is in `docs/claude-code-mechanisms.md`. Before changing agents, rules,
  or skills across owners, produce the impact map required by `claude/rules/core/change-control.md`, then reconcile
  it with the actual diff.
- After changing a skill's routing or relevant behavior, run `test/routing/run.sh`.
- After changing the skill tree or routing graph, run
  `python3 test/config/verify-skill-routing-graph.py --self-test`.
- Do not infer that an integration or hook works from simulation alone; always state evidence limitations.
- ACV is an independent acceptance role triggered by the user. When a change matches one of the five acceptance
  triggers, SCC may suggest an optional ACV review but must not invoke it or block delivery. Documentation and
  exploration do not require acceptance review unless explicitly specified.

## References

- Claude Code mechanisms and constraints: `docs/claude-code-mechanisms.md`
- Skill routing graph and triggers: `docs/skill-routing-graph.md`
- Audit and baseline: `docs/dogfood-audit-2026-07-15.md`
- SCC behavior experiments and cutovers: `docs/scc-behavior-experiment.md`
- Hook behavior: `docs/hook-saga.md`

## Tracked work

Use the relevant experiment or audit document for TODOs and current measurements; do not duplicate numbers or
status snapshots here.
