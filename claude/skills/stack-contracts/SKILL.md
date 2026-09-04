---
name: stack-contracts
description: Use when adding or changing a dependency where the workspace may already solve the same concern, consolidating stack or configuration, or designing shared schemas, types, enums, constants, or contracts across packages, services, frontends, backends, or workers. Own inventory and shared boundaries; combine with research:technology-vendor for external comparison. Do not use for one-site helpers or single-owner contracts, and never create shared abstractions for hypothetical future use.
---

# Stack Contracts — Establish One Owner Before Sharing

## Inventory before deciding

Inspect the repository for existing dependencies or configuration serving the concern, producers and consumers,
runtime boundaries, sources of truth, generated artifacts, compatibility paths, and whether apparent duplication
is one contract or merely similar shape. One empty query does not prove absence; inspect manifests, imports,
registrations, barrels, and workspace configuration. Analysis does not authorize additions or migration.

## Dependency consistency

- Prefer the existing solution for the same concern to avoid another runtime, API, and maintenance surface.
- For a better alternative, present benefit, compatibility, security and licensing, migration cost, and exit path.
- After approval, migrate within the agreed boundary; do not leave two standards without owner and exit conditions.
- Preserve justified differences across runtime, team, or deployment boundaries and record their rationale.
- Record decisions that change or diverge stack standards in the repository's decision or operational home. If none
  exists, propose a location rather than inventing a path.

## Shared contracts

- Assign ownership of a schema, type, enum, or error code before choosing storage.
- Generate or infer from the authoritative schema when possible; never maintain several writable sources.
- A shared package is justified by multiple consumers releasing or verifying one contract.
- Keep unstable or single-consumer contracts with their owner; do not extract for future use.
- Validate runtime boundaries even when static types are shared.

## Monorepo consistency

Shared error shapes, naming, folder boundaries, and formatter, linter, or build configuration should have one owner.
Package layouts and overrides may differ for justified runtime, deployment, or ownership boundaries. Before
consolidating a utility repeated in more than two places, verify identical semantics and change cadence; count
alone is insufficient. Report existing inconsistency and propose migration rather than silently extending it.

## Migration and verification

For consumer-visible public or data behavior, apply authorization, impact, and compatibility rules before mutation.
Inventory consumers, migrate one boundary at a time, and verify no old imports, configuration, or schema remain
before contraction. Report owner, consumers, compatibility window, and evidence for each consumer.
