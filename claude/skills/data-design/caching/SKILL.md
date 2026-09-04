---
name: data-design:caching
description: Design or change application and data caches, keys, TTL, invalidation, staleness, and miss paths. Use when adding a cache or when correctness or performance depends on copied data.
---

# Caching

- If the task begins with latency, expensive repetition, or whether caching would improve performance, invoke
  `performance` before concluding. This skill owns cache correctness; `performance` owns workload, baseline, and measurement.
- Do not add a cache until three questions are answered: what invalidates it, how much staleness is acceptable,
  and what happens on a miss.
- A cache is a copy, not the source of truth. Write the authoritative store first, and remain correct after complete cache loss.
- Define key naming, scope or tenant, and TTL. Do not create immortal or cross-tenant keys without an accountable owner.
- Address write consistency, invalidation failure, stampede, and hot keys when evidence shows real risk. Never hide a stale result that changes user decisions or authorization.

HTTP caching and ETags belong to `api-design:caching-concurrency`; query plans and performance evidence belong
to `performance`. Verify at least one claimed miss, hit, and write/invalidation flow.
