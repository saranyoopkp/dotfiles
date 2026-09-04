---
name: data-design:transactions-invariants
description: Design transaction boundaries, database invariants, locking, isolation, concurrent updates, duplicate races, and transactional outboxes. Use when one operation writes several records or must remain correct across concurrent clients, workers, or retries.
---

# Transactions & Invariants

- State the invariant before selecting a transaction: what must never become negative, duplicated, cross-tenant,
  or impossible. Enforce it with database constraints when possible.
- Keep writes that must commit or roll back together in one transaction. Do not read, decide, and write later
  without locking or a precondition when concurrency can invalidate the result.
- Choose optimistic preconditions or row/advisory locks for actual conflict patterns. Bound retries for serialization
  or deadlock failures and do not hide conflicts from callers.
- Never perform an irreversible external side effect inside a database transaction. To commit data with an event,
  record intent or an outbox entry transactionally and publish idempotently from a worker.
- Worker claims must be atomic and transactional; `FOR UPDATE SKIP LOCKED` outside a transaction does not prevent duplicate work.

Use `api-design:mutations` for API retry or idempotency and `risk-review` for delivery, dead-letter, and webhook
reliability. This skill owns database-state correctness and the state-to-event boundary. Verify the happy path,
mid-operation rollback, and at least one race or retry relevant to the invariant.
