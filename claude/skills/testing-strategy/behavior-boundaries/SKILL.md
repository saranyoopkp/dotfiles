---
name: testing-strategy:behavior-boundaries
description: Design minimal coverage for state and lifecycle, time and order, retries and recovery, failure timing, side effects, concurrency, and compatibility from an observable contract. Use when behavior changes with events or state; not for state-independent validation partitions or routine test-level selection.
---

# Behavior Boundary Coverage

Begin with `steady state → boundary event → observable result → recovery`. Select only families supported by
contract, implementation, incident, or risk; these are discovery prompts, not a universal checklist:

- state/lifecycle: initial state, allowed and rejected transitions, terminal or re-entry, and repeated actions
- time/cardinality/order: before, at, and after cutoffs; empty, first, last, and limits; duplicates and disorder
- identity/context: role, ownership, tenant or session boundaries, and permission changes during a flow
- side-effect/failure timing: failure before start, after partial work, or after commit before response; retry,
  resume, and cancel must prove final state and absence of unintended duplicate or partial effects
- concurrency/compatibility: competing actors, stale state, and old/new combinations only with shared state,
  independent release, persisted contracts, or a real rollout window

For each invariant, choose the nearest event that can cross it and inspect state or result plus observable side
effects. Use a minimal coverage ledger; do not multiply every family by every state or duplicate domain-owner semantics.

A contract gap exists only when an observable outcome within a declared precondition is too unclear to form an
oracle. Unknown mechanisms or harnesses are implementation discovery, not contract gaps. Do not strengthen
atomicity, idempotency, result equality, or retry guarantees beyond the observable contract.

Atomicity proves all-or-nothing at a commit boundary, not reclaim or recovery. At-least-once permits repeated
delivery but defines neither lease timing nor duplicate outcomes. Terminal state restricts transitions but does
not specify whether redelivery rejects, acknowledges as a no-op, or replays a result. A non-repeatable side effect
requires an authoritative duplicate outcome before an idempotent or exactly-once executable row can be claimed.

An atomic claim needs a probe capable of exposing partial visibility, failure, or race under the actual mechanism.
A sequential final-state check proves only final state. Until the mechanism is mapped, mark the atomic criterion
as a planned, unrunnable verification gap—not tested and not a contract gap. Keep sequential rows free of race or
window assertions. A one-sided rollback guarantee may use a negative assertion; do not invent unspecified final state.

Separate final statuses into `executable`, `planned/unrunnable verification gap`, `blocked contract gap`, and
`pruned`. Never call coverage complete while a material criterion is planned or blocked. Choose one representative
for states sharing an oracle, and prune a weaker-precondition row when a stronger row reuses its setup and proves
the same guarantee.

Read [../input-domains/SKILL.md](../input-domains/SKILL.md) only when a validation partition actually changes
transition or oracle.
