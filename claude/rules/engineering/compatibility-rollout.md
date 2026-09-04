# Compatibility & Rollout

Apply this rule when changing a public contract, schema, event, persisted state, or deployment where old and new
versions may coexist.

## Invariants

- New code must not break old consumers, and old code must coexist with new consumers during migration.
- Old/new combinations include concurrently rolling instances, browser tabs or mobile clients that have not
  refreshed, and old messages or events reaching a new consumer. These failures may remain silent and surface
  during someone else's deployment.
- Aim for release-order independence. When a real dependency order exists, state its preconditions and split
  changes in dependency order rather than mixing prerequisites and dependents in one boundary.
- Begin additive changes as optional. Put destructive changes—remove, rename, meaning changes, or required fields—
  through separate **Expand → Migrate → Contract** boundaries and verify consumers before contraction.
- Rolling back code does not reverse data or state. Design forward compatibility or mitigation before deployment.
- Missing preconditions must fail loudly; never skip them and report the rollout as successful.
- A resource, schema, or configuration being “created” does not prove rollout. Exercise the actual consumer action,
  including old and new paths across the compatibility window.
- Destructive changes require a staged migration plan visible to CI or review, with failure when a stage is absent.
  If the repository cannot enforce this automatically, report the enforcement gap rather than relying on memory.
- Feature flags, dual reads, and dual writes are rollout mechanisms. They need an owner, default, telemetry,
  and rollback or removal conditions, and cannot replace state or contract compatibility.

Domain detail belongs in `api-design:evolution`, `data-design:schema-migrations`, and `ops:infra-change`.
This invariant is the safety floor and skills must not weaken it.
