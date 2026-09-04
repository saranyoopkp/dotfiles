---
name: testing-strategy
description: Router for planning, writing, or reviewing tests; choosing regression tests and test levels; designing fixtures and coverage; or building test harnesses. Use when test evidence or coverage completeness is unclear, boundaries are risky, a bug has occurred, suites pass while real flows fail, or the user requests coverage review. Route behavior-boundary and input-domain coverage to their children; do not use for routine verification with known criteria.
---

# Testing Strategy — Prove Behavior Against the Coverage Contract

## Choose evidence

Start with `claim → failure mode → observable result → cheapest reliable test`:

- **unit:** deterministic logic whose boundaries can be isolated without hiding risk
- **integration:** database, queue, filesystem, provider adapter, or component contract
- **end-to-end/runtime:** wiring, browser or client behavior, auth/session, and deployment surface
- **smoke:** confirm a primary path after build or deploy; never substitute for regression coverage

Use several levels only when each proves a different failure mode.

## Priority

1. Logic affecting money, permissions, tenancy, data, or irreversible side effects; financial calculations need an independent oracle.
2. Real boundaries such as negative, zero, empty, duplicate, retry, remainder, split, cutoff, and time.
3. Contracts between independently developed or released components.
4. Regression tests that demonstrate the bug's root cause.

Straightforward glue, layout, and implementation details covered by types or smoke checks need no dedicated test
without regression evidence.

## Route only required coverage

- Read `testing-strategy:behavior-boundaries` at [behavior-boundaries/SKILL.md](behavior-boundaries/SKILL.md)
  for state or lifecycle, time or order, retry or recovery,
  side-effect timing, concurrency, and compatibility combinations.
- Read `testing-strategy:input-domains` at [input-domains/SKILL.md](input-domains/SKILL.md) for validation and
  input coverage, equivalence partitions, numeric or
  string boundaries, normalization, and cross-field constraints.
- Load both only when observable behavior genuinely depends on an input partition and a state transition.

API, data, UI, and operations skills own domain contract detail; `risk-review` owns authorization, tenancy,
time, and irreversible-risk floors; this family owns test evidence and completeness mapping.

## Fixtures and matrices

- Build fixtures for the states, roles, tenants, or currencies required by failure modes, not only happy paths.
- Authorization coverage includes allowed, denied, unauthenticated, and cross-tenant cases when relevant.
- Retry or idempotency coverage repeats delivery and checks for duplicate effects.
- Time logic crosses the defined business boundary.

## Load and capacity

Separate `harness/script`, `execution`, and `analysis/report`. Keep the user's requested artifact primary.
For “all” or “complete,” enumerate the executable matrix and track `planned / runnable / measured`; do not silently
reduce scope. Harnesses need scenario tags, target guards, metric schema, and repeatable commands. Without a
performance budget, collect measurements without inventing pass/fail thresholds. Use `performance` for metric
interpretation, bottlenecks, or optimization.

## Discipline and verdict

- Never skip, comment out, or weaken a failing test merely to make the suite green; fix it, isolate a flaky test with an owner, or report the blocker.
- Report path, input, environment, and coverage gaps. Build and typecheck are preconditions, not runtime evidence.
- A reproducible bug fix requires a regression test.
- Run targeted tests and real flows in proportion to risk; identify criteria left unproven when execution is unavailable.
- Preserve one canonical repeatable suite command in the repository's operational home; propose a location if none exists.
- For production scope, combine `risk-review` with smoke and health evidence. Money, authorization, and tenant isolation remain minimum coverage at every stage.

Report the primary deliverable, requirement, test level, fixtures or matrix, commands and results, and remaining
coverage gaps, separating created, executed, and readiness-only work.
