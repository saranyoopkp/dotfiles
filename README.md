# dotfiles — an instruction architecture for coding agents

A working configuration for [Claude Code](https://claude.com/claude-code) that treats agent
behaviour as something you design, verify and measure — not something you prompt and hope for.

It has been in daily use across every repository I work in, on more than one machine, since
early 2026.

> Thai version of this document: [`README.th.md`](README.th.md)

## The problem this solves

An agent that can edit files is easy to get. An agent you can trust with a production
repository is not. The failures that matter are not "wrong syntax" — they are:

- widening the scope of a task nobody asked to widen
- taking an irreversible action that was never authorised
- reporting a claim as verified when nothing was actually run
- losing the original objective somewhere inside a detour
- accumulating so many instructions that none of them are read

Prompting harder does not fix these. They are structural, so the fix is structural: separate
what must always hold from what applies to a kind of work, give each surface one job, and then
**test that the routing between them still works.**

## Design

Four surfaces, each earning its place differently:

| Surface | Loading | Holds |
|---|---|---|
| `claude/rules/` | every session, always | safety and correctness invariants that must hold regardless of task |
| `claude/agents/` | on selection | trigger → judgment → action → verification for a role |
| `claude/skills/` | on invocation | domain procedure, decision criteria, edge cases for one kind of work |
| `test/` | on demand | evidence that the above still behave as claimed |

The constraint that keeps this from bloating is a single question, applied to every line:

> *If this instruction were removed, how would the agent's decision, action or verification get
> worse?*

If there is no answer, the line goes. Rules are only created from a failure that has recurred
and can be pointed at; a new rule must first be merged into an existing one before it is allowed
its own file.

**13 rules** cover change control, evidence integrity, compatibility, and the risk domains where
mistakes are expensive — authorization and tenancy, money, time zones, production recovery,
external integrations.

**49 skills** cover the procedures — API contract design, schema migrations, observability,
incident response, performance, testing strategy, documentation placement.

**3 agents** separate primary work, bounded discovery and acceptance: SCC owns implementation,
a read-only Scout isolates broad searches or independent hypothesis checks, and ACV independently
validates qualifying deliverables without editing code. SCC handles routine discovery itself; there
is no separate Builder or worktree orchestration.

These are repository roles. Agent selection and any use of additional sessions are manual decisions made
by the user; the repository does not automatically delegate work or select an execution topology.

### Using the agents

Start with SCC and describe the outcome, scope and constraints. Users may manually select Scout for bounded
read-only discovery or ACV for independent acceptance review; neither is automatically invoked. Scout never
implements, and ACV never edits code.

## Verification

This is the part most agent configurations skip, and it is the part I care about most.

### Routing regression (`test/routing/`)

On-demand skills only help if the model actually invokes them at the right moment. That is a
behaviour, and behaviours regress silently.

Each scenario runs in a **fresh `claude -p` session** — a subagent cannot substitute, because it
inherits context the real case would not have — inside a sandbox outside this repository so the
repo's own instructions cannot contaminate the result. The verdict reads actual `Skill` tool-use
events out of the raw stream-json and requires a clean CLI exit; a harness timeout is recorded as
a harness failure, kept separate from a routing conclusion.

Cases are declared as `require / forbid / label / task`, so the suite catches **over**-invocation
as well as misses. Skills with genuinely overlapping domains are allowed to co-fire rather than
being forced into a false expectation.

Every run keeps per-scenario raw stream-json, stderr and exit status, so a failure can be opened
and read rather than guessed at.

### Friction and guardrail checks (`test/friction/`, `test/config/`)

Simple-task scenarios catch unnecessary tool use and ceremony, while config scripts verify the
guardrails and documentation-drift stop actually fire — including the case where a hook runs in a
different environment than the agent's own shell, which is where "it works" is most often wrong.

### Evidence-grade session index (`test/metrics/`)

A Python pipeline that turns real session transcripts into an auditable corpus.

It indexes every transcript into SQLite with `source file + line + UUID + raw hash` as
provenance, and keeps the raw JSONL as the authoritative record rather than copying it in. The
audit unit is the **human turn**, not the session, and each turn is classified against a fixed
taxonomy — `CONTINUE, REFINE, QUESTION, PREREQUISITE, NEW, REPLACE, DEFER, RESUME, CANCEL,
CORRECT, AMBIGUOUS`.

Three properties I would point at specifically:

**Coverage is reconciled, not asserted.** Status must balance on three separate identities:

```text
discovered files  = indexed + explicitly excluded + failed
indexed lines     = parsed  + malformed          + blank
auditable inputs  = pending + classified + ambiguous + failed + input-only
```

Anything excluded is excluded *by name and reason*. Nothing disappears quietly.

**The evaluator excludes evidence about itself.** Any session that edited this repository — including
through the symlinked config paths — is dropped as `dotfiles_self_modification`. Measuring an
agent using sessions in which the agent was rewriting its own instructions is not independent
evidence.

**Ambiguity is not resolved by convenience.** Records that cannot be classified deterministically
stay in an `ambiguous` bucket and block a completeness claim. The rule is explicit: you may add a
deterministic rule with a fixture and re-index, but you may not force individual records to make
the totals look complete.

Import of reviewed results is rejected on stale input hashes, missing turns, relations outside the
taxonomy, or findings without cited evidence — so coverage can only move forward with something
behind it.

Each analysis script ships with its own regression test (`test_index_transcripts.py`,
`test_prepare_audit.py`, `test_discover_events.py`) covering schema, branch lineage, sampling and
budget edges.

## Layout

```
claude/rules/      13 always-loaded invariants (core, engineering, risk)
claude/skills/     49 on-demand domain procedures
claude/agents/     3 role definitions: SCC, Scout, ACV
test/routing/      skill auto-invocation regression, real sessions
test/friction/     simple-task ceremony regression
test/config/       guardrail and install verification
test/metrics/      session-corpus indexing and evaluation pipeline
docs/              rationale, experiments and measured cutovers
references/        on-demand reference material
install.sh         links ~/.claude/{agents,skills,rules}
```

## Install

```bash
git clone <this-repo> && cd dotfiles && bash install.sh
```

Agents and rules are linked as directories. Skills are linked individually because
`~/.claude/skills` belongs to the harness. Edit here, commit, push; other machines pull and the
links keep pointing at the repo. Existing non-link agent directories are backed up before linking.

One deliberate exception: `claude/skills/docs/setup/kit/CLAUDE.template.md` is **copied** into a
target repository, not linked, because the target may not have this configuration installed at
all. That copy does not sync back, and re-applying it is a documented merge rather than an
overwrite.

## Honest scope

This is a personal system, shaped by the kinds of work I do — multi-tenant backends, production
infrastructure, and repositories that outlive the person who wrote them. It is opinionated by
design and is not trying to be a framework for everyone.

The measurements in `docs/` are from my own sessions, which makes them evidence about this
configuration rather than a general benchmark. Where a result rests on simulation instead of a
real run, the documents say so.
