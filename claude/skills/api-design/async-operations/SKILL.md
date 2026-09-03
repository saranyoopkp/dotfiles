---
name: api-design:async-operations
description: Design HTTP contracts for commands completed later, including 202 Accepted, import/export, background jobs, provisioning, and long-running actions. Use when one response cannot confirm the final outcome.
---

# Async Operations

- `202 Accepted` means accepted, not completed. Return an operation identifier or URL and a client-observable
  state, plus the polling, callback, or event channel the product actually supports.
- Model only real states such as pending, running, succeeded, failed, and cancelled. Terminal results and errors
  should reuse the primary resource representation or error contract where appropriate.
- Define retry, cancellation, expiry or retention, and authorization for the operation/status resource. Do not
  expose internal job implementation as a client contract.
- If clients may retry operation creation, define idempotency and reconciliation with `api-design:mutations`;
  never create duplicate work silently after a timeout.

Verify accepted → running → terminal success and terminal failure. If end-to-end execution is unavailable, state
which transitions remain unverified instead of claiming the asynchronous flow works.
