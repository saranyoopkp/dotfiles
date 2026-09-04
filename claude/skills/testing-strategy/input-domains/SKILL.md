---
name: testing-strategy:input-domains
description: Design minimal validation and input-domain coverage with equivalence partitions, contract boundaries, nearest-invalid representatives, coupled constraints, and coverage ledgers. Use when input shape, value, or normalization changes observable behavior; not for state/retry flows or already-defined validation cases.
---

# Input Domain Coverage

Model `contract → behavior dimensions → equivalence partitions → boundary representatives → coupled interactions
→ remaining gaps`. Include only dimensions that change behavior: presence, representation or type, range, total
precision, scale or step, format or normalization, cardinality, cross-field invariants, state, or role.

- Use a minimal discriminating set: one normal valid value, each contract boundary, and the nearest invalid crossing.
  Distinguish total precision, fractional scale, and step. Derive and verify numeric crossings from permitted scale.
- Keep one interior valid baseline. Every declared constraint needs a valid boundary and invalid crossing while
  other constraints remain valid where possible. Reuse one crossing that genuinely maps several criteria; do not
  add farther values for the same criterion.
- Derive reject, round, or truncate oracles from the contract. Logical implication does not replace an invalid-side
  test unless an authoritative decision makes it redundant. Use one observable invalid partition for regex or schema
  failures unless clauses produce different behavior.
- Do not add far-out, malformed, parser, overflow, or security variants without a distinct failure mode supported
  by contract, implementation boundary, incident, or risk. Different syntax through one branch and oracle is one partition.
- Never invent minimums, maximums, precision, normalization, or allowed representations. A one-sided constraint
  creates no opposite boundary. Report one contract gap only when an in-scope dimension lacks enough policy for an oracle.
- If an upstream contract makes a boundary structurally unreachable, map it as structurally covered; do not create
  impossible input or request a decision unless contracts conflict.
- Avoid Cartesian products. Couple dimensions only when business rules, transitions, observable error semantics,
  or incidents provide evidence. Plausibility alone is insufficient. Test all contract-permitted representations
  before declaring constraints coupled or unreachable.
- For independent criteria, select inputs that keep other criteria valid where possible. Never accept a shared
  failure merely because the first chosen value crosses several constraints.
- Completeness means every material criterion is tested, intentionally covered elsewhere, deferred, or a documented
  gap—not that every value was enumerated.
- Keep one executable case per ledger row and allow it to map several criteria only when its input crosses each.
  Judge completeness from criterion-to-row mapping, not case count or shared oracle.
- Prune dominated rows whose criteria are fully proven by another row using the same branch and oracle, unless a
  real boundary or failure evidence remains distinct. Validator names and internal branch order are not separate
  observable behavior.
- Show only post-pruning rows in the executable ledger. Discuss alternates collectively when useful, and report
  `none` when no gaps remain rather than appending hypothetical questions.

Read [../behavior-boundaries/SKILL.md](../behavior-boundaries/SKILL.md) only when an input partition actually
changes a transition, retry, or recovery oracle.
