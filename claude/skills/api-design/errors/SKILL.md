---
name: api-design:errors
description: Design HTTP errors, validation responses, and Problem Details contracts. Use when adding or changing 4xx/5xx behavior, authentication or authorization failures, error middleware, field validation, or REST client recovery contracts.
---

# Errors

- Use 400 for malformed requests; 401 for unknown identity; 403 for known identity without permission; 404 for
  absence or authorized cross-tenant hiding; 409 for domain conflict; 422 for semantic validation; 429 for rate
  limiting; 500 for unexpected failure; and 503 for unavailable or maintenance states.
- Use one Problem Details shape across the API: machine-readable `type` or code for client branching, human-readable
  `title` and `detail`, and field errors when users can correct individual fields. Never leak stacks, SQL, internal
  paths, or secrets.
- Partial failure responses must identify successful and failed items or actions. Never hide required recovery
  information behind a generic 200 or “success.”
- Validation rules, authorization visibility, and error logging retain their domain owners. Do not invent another
  error shape to bypass the shared contract.

Exercise at least one real error path for every added or changed semantic and confirm the client parses the same
shape returned at runtime.
