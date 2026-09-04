---
name: data-design
description: Router for data-layer standards. Use when planning, designing, reviewing, or changing schemas, migrations, indexes, transactions, concurrency, invariants, caches, queues, workers, dataflows, retention, deletion, audit, or PII lifecycle—even for planning without an existing repository. Map source of truth, writers, readers, and lifecycle, then read matching children; schema or migration work always requires data-design:schema-migrations.
---

# Data Design

Before changing the data layer, identify the source of truth, writers and readers, invariants that must hold,
and required lifetime. Read matching children before changing a schema, worker, or cache.

| Work surface | Required child |
|---|---|
| Tables, columns, relations, enums, JSON, indexes, IDs, migration, or backfill | `data-design:schema-migrations` |
| Atomic writes, locks, isolation, duplicate races, or database events/outbox | `data-design:transactions-invariants` |
| Cache keys, TTL, invalidation, staleness, or misses | `data-design:caching` |
| Queues, workers, derived data, external sync, pipelines, or single writers | `data-design:async-dataflow` |
| Retention, archive, deletion, anonymization, audit/history, or PII lifecycle | `data-design:lifecycle-governance` |

Load multiple children only when the actual flow spans them. Do not load all as a checklist or skip a matching
child because work looks small. Authorization, tenant boundaries, query performance, backup/restore, and delivery
reliability retain their existing owners.

Before changing consumer-observable schema, data meaning, or lifecycle, apply authorization and impact rules from
`claude/rules/core/change-control.md`; apply compatibility and rollout rules to public or persisted contracts.
