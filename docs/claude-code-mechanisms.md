# Claude Code `.claude/` Mechanisms for On-Demand Rules

Research snapshot: 2026-07-16. Sources were official `code.claude.com/docs` pages for the Claude directory and skills, plus the Claude Code guide agent; selected behavior was verified with `claude -p`. Platform behavior is version-dependent, so recheck official documentation when current behavior differs.

## Instruction loading

| Mechanism | Load time | Notes |
|---|---|---|
| `CLAUDE.md`, `~/.claude/CLAUDE.md` | Every session | Always-on |
| `~/.claude/rules/**/*.md` without `paths:` | Every session | Current always-on rules |
| Rule with `paths:` frontmatter | When Claude reads a matching file | Reloads on every turn touching the file; expensive inside a domain |
| Skill description | Every session through the thin skill listing | Routing signal |
| Skill body | On Skill-tool invocation | Loads once without a pointer; selected mechanism |
| CLAUDE.md `@import` | At launch, inline | Not lazy |
| Nested subdirectory CLAUDE.md | When files in that subdirectory are read | On demand |

Ground-truth stream-json testing found skills to be the only mechanism providing fresh, pointer-free, load-once on-demand behavior. Fresh and long-session invocation both passed. See `dogfood-audit-2026-07-15.md` for the full decision.

## Skill grouping and namespacing

Documented nested directories did not register under Claude Code v2.1.212 on 2026-07-17, whether reached through junctions or real directories. `skills/<group>/<child>/SKILL.md` returned “Unknown skill.”

The verified arrangement is a top-level flat directory with a colon-qualified frontmatter name such as `docs:link`. The repository may retain grouped source structure under `claude/skills/docs/{setup,placement,link}`, while installation creates flat junctions such as `~/.claude/skills/docs-link` and a root `docs` router. Windows directory names avoid colons; invocation uses the frontmatter name.

Split a single skill into a family only after it exceeds roughly 200 lines and contains genuinely separate concerns requiring their own descriptions and routing. Earlier grouping is speculative structure.

## Instruction pointer resolution

- The Read tool usually expands `~`, but not `$HOME` or arbitrary environment variables.
- Junctions and symlinks matched under v2.1.207 and later.
- One long-session `~` lookup failed nondeterministically. Do not rely on instruction pointers when the harness can load a skill directly.
- Skill substitution variables include `${CLAUDE_SKILL_DIR}`, `${CLAUDE_PROJECT_DIR}`, `${CLAUDE_SESSION_ID}`, and `${CLAUDE_EFFORT}`.

## `claude -p` as a fresh-session test bed

- A fresh process reads current rules and skills from disk; a subagent cannot substitute because it inherits context.
- It uses the agent configured in settings unless `--agent <name>` overrides it; unknown names fail loudly and list agents.
- Independent scenarios can run concurrently, reducing observed wall time from 15–18 minutes to about 87 seconds in the recorded run.
- `--output-format stream-json --verbose` exposes actual tool use rather than model self-report.
- Run outside dotfiles to avoid loading its CLAUDE.md, and never edit a script while Bash reads it incrementally.

## Rule versus skill taxonomy

An always-on rule owns an invariant that must be visible before domain classification and whose omission can cause difficult-to-recover harm. Detail tied to a work surface, stage, or specialized decision belongs in a skill even for risky domains. A concise always-on risk classifier routes to `risk-review`.

Current skill entry points include `docs`, `ui-ux-baseline`, `data-design`, `api-design`, `ops`, `greenfield-foundation`, `research`, `retro`, `performance`, `stack-contracts`, `testing-strategy`, and `risk-review`.

## Current ownership map

This describes current ownership rather than history. Rules provide the always-on safety floor, SCC turns triggers into actions, ACV independently checks qualifying outcomes, and skills provide on-demand procedures. One concern may cross layers only when each layer serves a different role.

### Always-on rules

| Concern | Shared invariant owner | Behavior or on-demand owner |
|---|---|---|
| Operating principles, material proposals and pain, complexity, greenfield, and research floor | `claude/rules/core/operating-contract.md` | SCC behavior; `greenfield-foundation`, `research`, and `retro` procedures |
| Claim, report, and durable-finding integrity | `claude/rules/core/evidence-integrity.md` | SCC evidence-backed reporting; independent ACV acceptance evidence |
| Intent, objective continuity, detours, behavioral changes, refactors, instruction-system changes, and task tracking | `claude/rules/core/change-control.md` | SCC behavior; ACV authorization and observable-behavior review |
| Compatibility and rollout | `claude/rules/engineering/compatibility-rollout.md` | SCC routes to API evolution, schema migration, or infrastructure change; ACV reviews authorized outcomes |
| Documentation and memory safety | `claude/rules/engineering/documentation-discipline.md` | SCC routes to `docs`; children own setup, placement, links, stale content, and workspace concerns |
| Test evidence, performance, and shared contracts | Core evidence and operating invariants | SCC routes to `testing-strategy`, `performance`, or `stack-contracts` when their decisions arise |
| Authentication, tenancy, money, time, integration, production, and destructive boundaries | `claude/rules/risk/risk-boundaries.md` | `risk-review` loads only the reference matching the active surface |

### On-demand entry points

| Domain | Entry-point owner | Routing source |
|---|---|---|
| API contracts and evolution | `claude/skills/api-design/SKILL.md` | Router description and child routes; compatibility trigger from SCC |
| Data models, lifecycle, and consistency | `claude/skills/data-design/SKILL.md` | Router description and child routes |
| Documentation and memory | `claude/skills/docs/SKILL.md` | Router description and child routes; SCC documentation trigger |
| Greenfield foundation | `claude/skills/greenfield-foundation/SKILL.md` | Description and SCC greenfield trigger |
| Operations and infrastructure | `claude/skills/ops/SKILL.md` | Router description and child routes |
| Performance | `claude/skills/performance/SKILL.md` | Description, thin rule, and SCC trigger |
| Research | `claude/skills/research/SKILL.md` | Router description, children, and SCC research triggers |
| Behavioral surprise, session feedback, objective loss, and attention drift | `claude/skills/retro/SKILL.md` | Read-only by default; runtime continuity remains in change-control and SCC |
| Shared stack and contracts | `claude/skills/stack-contracts/SKILL.md` | Description, thin rule, and SCC trigger |
| Testing strategy | `claude/skills/testing-strategy/SKILL.md` | Description and SCC trigger |
| UI/UX/frontend and generic visual quality | `claude/skills/ui-ux-baseline/SKILL.md` | Shared quality lens, router description, and child routes |
| Risk-domain procedures | `claude/skills/risk-review/SKILL.md` | Thin risk-boundary rule and SCC trigger; references load by active surface |

### Maintaining the map

- Include every rule and top-level skill entry point. Every child skill must route from its parent by its real name.
- Before changing several owners or routing edges, show an impact map: `preserved | moved old → new | behavior changed | removed | unverified`. Reconcile it with the actual diff and include the same summary in the commit or pull request.
- Separate structural moves from semantic changes when possible. Identify destinations and old-to-new routing for moves, and rationale plus replacement for removals.
- `test/config/verify-guardrails.sh` proves structural coverage and selected invariants, not semantic equivalence. Review the impact map, diff, and targeted behavior tests too.
- Git owns history; do not create a second historical ledger in this map.

After changing a skill or description, run `test/routing/run.sh`.
