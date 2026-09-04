---
name: api-design:mutations
description: Design REST mutations with side effects, retries, duplicate submission, or idempotency. Use for POST, PUT, PATCH, or DELETE operations that create, change, or remove data or external effects.
---

# Mutations

- Model intent → validation/authorization → pending effect → committed result or recoverable failure. A response
  states only the result the server has confirmed.
- A POST whose duplicate side effect is harmful—money, order creation, provisioning, or export—must accept an
  `Idempotency-Key`, bind it to the request fingerprint and result, and replay the prior result for an equivalent
  retry. Define a clear contract for key reuse with a different payload.
- PUT and DELETE must remain idempotent by semantics; a retry must not add hidden effects.
- For multi-item mutations, define atomicity or per-item results. Never collapse partial failure into one success.
- Read `api-design:caching-concurrency` for stale writes and `api-design:async-operations` when completion occurs later.

Verify the happy path, retry or duplicate intent, and failure after side effects begin in proportion to operation risk.
