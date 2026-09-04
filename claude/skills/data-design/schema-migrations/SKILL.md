---
name: data-design:schema-migrations
description: Design or change database schemas, relations, enums, JSON fields, IDs, constraints, indexes, migrations, and backfills. Use whenever adding or changing a table or column, or when data shapes used by old code may change.
---

# Schema & Migrations

- Normalize by default. Denormalize only with performance evidence, an owner, and a synchronization method—not to avoid joins.
- Use enums or lookup tables for controlled state and type. Use JSON only for genuinely variable data; promote frequently filtered, joined, or aggregated fields to columns.
- Enforce always-true invariants with suitable foreign-key, unique, check, or other constraints. Give tables created and updated timestamps, and index foreign keys used for joins or cascades.
- Choose IDs deliberately, add unique constraints to imported external references, and define relation deletion behavior.
- Derive indexes from real query, filter, and sort paths rather than guessed workloads.

Before migration, identify consumers and compatible schema/code combinations. Removal, rename, meaning changes,
required fields, and rewrites follow expand → migrate/backfill → switch consumers → contract under
`compatibility-rollout`. Backfills must be batched, observable, stoppable, and repeatable. Understand locking,
deployment effects, rollback, or forward repair before applying.

Verify migration from the old schema with representative data and new constraints or indexes. If real locking or
backfill behavior cannot be tested, report the risk and verification plan rather than calling it safe.
