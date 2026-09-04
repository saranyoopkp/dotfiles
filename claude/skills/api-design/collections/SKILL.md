---
name: api-design:collections
description: Design REST collection APIs for lists, search, filtering, sorting, pagination, cursors, and counts. Use when an endpoint returns multiple resources or accepts queries that alter result membership or order.
---

# Collections

- Use consistent filter and sort grammar and naming across the API, with an allowlist of supported fields and
  operators. Do not expose raw queries as a persistence API.
- Prefer opaque cursors for growing or changing collections. Offset pagination is acceptable for small or stable
  datasets when its trade-offs are accepted.
- Bind a cursor to deterministic ordering with a stable tie-breaker. Define whether changing filters or sorting
  invalidates, resets, or reconciles an existing cursor.
- Return `next_cursor` or `has_more` and define default and maximum limits. Provide `total` only when the product
  needs it and accepts its cost.
- Distinguish an actually empty collection from a query yielding no matches without requiring clients to parse text.

Verify first, next, and final pages; filter or sort transitions; and insertion or deletion between pages when the
endpoint claims to support changing data.
