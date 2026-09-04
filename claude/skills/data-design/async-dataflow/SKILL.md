---
name: data-design:async-dataflow
description: Design queues and workers, derived data, external synchronization, event/data pipelines, single-writer boundaries, replay, and reconciliation. Use when data is processed later or crosses service or provider boundaries.
---

# Async Dataflow

- Do not queue results a caller needs immediately; a queue represents eventual completion, not synchronous work disguised as asynchronous.
- Give each fact one primary writer. If several sources may write it, define source priority and conflict resolution before implementation.
- Derived data must be recomputable from its source. Preserve source or raw events, external IDs, and synchronization timestamps for replay, reconciliation, and traceability.
- Redelivered messages and jobs must be idempotent, and workers must reconcile after retry or crash. Never assume exactly-once delivery without evidence.
- Define visibility for pending or failed work, replay boundaries, and dead-letter ownership. Do not delete evidence still needed for recovery or audit.

Inbound or outbound webhook reliability, replay/reconciliation, and dead letters belong to `risk-review`;
HTTP-tracked operations belong to `api-design:async-operations`; health and backlog signals belong to
`ops:observability`. Verify duplicate delivery, crash/retry, and at least one supported reconciliation flow.
