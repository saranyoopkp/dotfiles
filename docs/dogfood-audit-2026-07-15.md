# Dogfood audit — pain points mined from ~/.claude (snapshot 2026-07-15)

> **Point-in-time document.** Do not keep it current. Corpus: `~/.claude/history.jsonl`
> (9,346 prompts) and `~/.claude/projects/` (153 main sessions, 449 subagent
> transcripts, 636 MB, 2026-06-02 through 2026-07-14).

## Summary

**The system was not broken; it was not enforced.** SCC, ACV, and rules worked when used, but every mechanism depended on model memory rather than system enforcement.

## Enforcement gap

| Mechanism | Observed use | Base |
|---|---:|---:|
| ACV invoked in code-changing work | **21%** | 20/95 sessions |
| SCC invoked ACV as required | **39%** | 19/48 sessions; non-SCC 2% |
| SCC setting active, 07-12 through 07-14 | **97%** | 35/36 |
| SCC citation on completion | **61%** | 353/570 |
| SCC ran a check before completion | **89%** | 510/570; 60 ran nothing |
| Agent stopped despite knowing how to continue | **80%** | 24/30 cases; only 7% were blocked |

The former “25% SCC leak” averaged the whole month, including the period before deployment. The leak stopped on 2026-07-12: 07-06 through 07-11 had 3–5 `NONE` sessions per day; 07-12 through 07-14 had SCC 35 and `NONE` 1. Inspect time trends before describing current state; historical averages can make a dead bug look alive. This was the audit's fourth confound, identified by the user.

The result was predicted by `rules/engineering/compatibility-rollout.md`: **Enforce with systems, not memory. A rule that relies on memory will be violated.**

## ACV worked; do not redesign it

- 48 calls across 20 sessions; last used 2026-07-14.
- 19 PASS, 15 PASS WITH RISKS, 4 FAIL, and 1 BLOCKED: **51% were not clean passes**.
- It found an SSRF guard that failed to decode embedded IPv4, incorrect migration index-column order, and a concurrency path.
- It ran checks and cited `path:line`; one transcript said, “Verified against the actual file, not the claim.”
- Eight sessions invoked it at least three times, showing real FAIL → fix → recheck loops.
- Median cost was about 6.2 minutes, 23 tool calls, and 213k fresh tokens. Requiring it for every edit is unreasonable; triggers must follow risk.

## Main-agent failure mode: defining “done” incorrectly

1. **Stopping despite being able to continue.** The user always answered “continue,” never “pause,” and answered “do all of them” when offered A/B/C.
2. **Evidence downgrade.** Reading code became “clean,” HTTP 200 became “should definitely pass,” and a socket test became “complete end-to-end.” Checkmarks and emoji replaced citations. The user challenged 24 claims and was correct 42% of the time (CI 22–63%; small sample).
3. **Silent omissions followed by completion.** In 33/50 incomplete cases (66%), the report followed a success claim. “Complete” meant the requested diff, not the specification: feature parity, all CRUD operations, environment/CI secrets, and operational steps.

## Withdrawn figures

| Former conclusion | Why withdrawn |
|---|---|
| “SCC is 2.1× worse than non-SCC” | It disappeared after stratifying by session length; direction reversed across bins like noise. |
| “ACV receives more challenges, 1.40 vs 0.86” | Selection bias: ACV covered larger work (median 24.7 vs 5.6 hours), with insufficient sample. |
| “Agents evade problems with any/eslint-disable” | `any` was 75/7,718 edits, `@ts-ignore` was zero, uses had justification, and users never complained. |

The corpus cannot establish whether SCC or ACV reduces misleading output. Only 69 genuine challenges were spread across ten cells, too few to detect a medium effect. Do not revive that conclusion.

## Results after cutover

SCC-v1.0 changed at `2026-07-15T02:44+07`. In 20 sessions and 206 user turns closed afterward:

| Metric | Before | After |
|---|---:|---:|
| Unnecessary “continue” prompts | about 1.8/100 turns; 24/30 cases | **0/206** |
| ACV compliance in SCC sessions | 39% | **64%** (9/14) |

The signal is strong and consistent but not causal proof: the sample covers only three observed days; ACV came from the SCC prompt, not the undeployed gate; and another two to three weeks outside active observation were needed.

## Tenant-type success case

The new SCC's “better path” field exposed a silent defect. The model wrote that it should search for other `TransactionHistory` creation sites, then rationalized deferral because the main path and fallback seemed sufficient. The user requested the check. It found two paths where `tenant-type enum=null`, routing records to the wrong company at go-live.

The field did not make the model smarter. It exposed knowledge that the model was about to suppress so the user could override it. This single case matches the 66% silent-omission failure mode.

## Universal claims require an underlying command

Claims such as “all creation sites” or “no other paths” were inferred rather than searched. Once searched, two gaps appeared. Candidate third SCC revision:

> A universal claim—complete, all, or no other—must be backed by a search command.
> Before running it, say “not yet checked,” not “covered.”

Preserve this finding, but do not revise SCC again until the first two revisions can be evaluated independently.

## On-demand rules: use a skill

| Mechanism | Fresh | Long session | Cost | Pointer |
|---|---|---|---|---|
| Stub + playbook + junction | yes | failed open with missing file | once/session | fragile |
| Native `paths:` frontmatter | yes | yes | loaded every matching turn | none |
| **Skill** in `~/.claude/skills/<name>` | yes | invoked at turn 6 | once on invocation | none |

A skill provides a small always-loaded description for routing and loads its body once on invocation. Decision: move `ui-ux-baseline` to `claude/skills/ui-ux-baseline`, add accessibility/focus guidance, keep cross-cutting principles in `rules/`, and remove playbook/path routing.

The first test grepped self-reported `SKILL_INVOKED: YES`, creating confirmation bias. The corrected test inspected actual `tool_use name=Skill` events from `--output-format stream-json`, confirming `Skill('ui-ux-baseline')`. `test/routing/run.sh` uses that method.

### Former `claude -p` prototype

`claude -p` provided a fresh-session test bed; a subagent inherited stale parent context. Fresh sessions saw the stub, routed UI cases to the playbook, rejected non-UI time/backend cases, and recognized 4/4 ambiguous cases. No-action questions deferred reading until implementation. One session independently found missing focus/keyboard guidance through WAI-ARIA APG.

On-demand loading primarily enables deeper guidance without bloating always-on context. It does not inherently improve routing or save cost. Roughly five UI cases routed correctly, but routing risk remains. Hooks still require staged real behavior; model process narration is not evidence. Trust outcomes.

## Structural limit of dogfooding

This corpus is the injury history of one machine. It shows what failed, not everything that can fail. The rules came from the same incidents, so deriving a risk list from them merely moves the bias up one layer. Open-ended domain lists fail open.

Use closed, fail-safe property checks:

1. Is the action irreversible: deletion, rename, required fields, secrets, money, or external delivery?
2. Does it touch real state: production data, migrations, or user data?
3. Does it cross a trust boundary: external input, authorization, external calls, or a new endpoint?
4. **If whether 1–3 applies is unknown, treat it as yes.**

The user identified both the corpus limitation and the rules-as-source limitation.

## Traps for future ~/.claude audits

1. **Subagent transcripts contaminate the corpus.** Their “user turns” are parent prompts. Always exclude `/subagents/`; there were 449 subagent files versus 153 main files. A length filter happened to save this audit—luck, not design.
2. **Agent identity.** Main files contain `{"type":"agent-setting","agentSetting":"SCC-v1.0"}`; subagent files do not. This is the only valid SCC separator.
3. **Session length.** Challenge rate rose from 1.05 to 2.2 per 100 turns with session length. Per-turn normalization is insufficient; stratify by length bins.

When validating context gathered by an agent, resume that same agent with `SendMessage` rather than spawning another. The original retains the sample and pipeline; a replacement must rescan 636 MB, costs about 20k unnecessary tokens, and cannot answer case-level questions.
