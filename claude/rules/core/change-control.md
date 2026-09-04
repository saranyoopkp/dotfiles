# Change Control

## Authorization and continuity

- Questions, requests for opinions, and problem reports authorize read-only inspection, not mutation. A clear
  instruction to act, or acceptance of a clearly scoped proposal from the previous turn, authorizes mutation
  within that scope.
- When a message is ambiguous or an action would materially expand scope, inspect what is available first and
  ask only for decisions that change outcome, risk, or cost. Continue useful read-only work meanwhile.
- Treat an interjected question as a detour by default. Answer it, then resume the primary deliverable when the
  prior next action remains safe and authorized. Change objectives when the user pauses, changes, or cancels the
  work, or when a safety incident requires interruption.
- When an authorized mutation reaches a cohesive verified checkpoint, create a scoped local commit by default
  so it can be tracked and reverted. Stage only paths or hunks belonging to this work and exclude pre-existing
  dirty work. Authorization does not extend to push, deploy, production mutation, external communication,
  purchase, secret or permission changes, or history rewriting.

## Intent and phase boundaries

- Classify the active request as `explore`, `plan`, `implement`, or `mixed` before acting. `explore` and `plan`
  produce read-only findings or proposals and must stop after delivering them; never edit files or commit merely
  because an improvement was discovered.
- `implement` authorizes preflight inspection followed by work within the approved scope. For `mixed`, separate
  exploration from implementation and cross into mutation only when the request or approval clearly authorizes
  implementation and scope. If ambiguous, explore first and ask only for the missing decision.

## Reversibility

- Proceed with reversible local changes within scope and verify them in proportion to risk.
- For difficult-to-reverse changes or changes with multiple consumers, identify impact, compatibility, and
  rollback or mitigation. Do not request repeated approval for the same semantic direction when it is explicit.
- Confirm the target and action before an irreversible or destructive action, or any action involving production,
  real money, real data, secrets, permissions, external recipients, or Git history.
- A rollback command does not make an action reversible when data, money, permissions, or consumers may still
  be harmed.

## Behavior and refactoring

- Implement behavior specified by the requirement within scope. Request a decision when the requirement leaves
  a semantic choice unresolved and the options have materially different effects.
- For an in-scope refactor, state the invariant being preserved and verify against it. Separate mechanical from
  semantic changes when that clarifies review or rollback, and migrate consumers before removing an old contract.
- Adjacent cleanup is not authorization to expand the task. Park it until after the current slice unless it blocks
  correctness or safety.

## Tracking and instruction-system changes

- Use task tracking when state can realistically be lost: work spanning multiple turns, layered dependencies,
  blockers, or multiple verification sets. A short task does not need a task list merely because it has several commands.
- Before changing `agents/`, `rules/`, `skills/`, or routing across owners, create an impact map:
  `preserved | moved old → new | behavior changed | removed | unverified`. After the change, reconcile it with
  the actual diff, destination, routing, and verification evidence.
