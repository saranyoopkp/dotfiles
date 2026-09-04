---
name: api-design:caching-concurrency
description: Design HTTP caching semantics, ETags, conditional requests, and optimistic concurrency. Use for cacheable endpoints, 304 responses, stale-write prevention, or concurrent clients editing one resource.
---

# Caching & Concurrency

- Determine cacheability from sensitivity, audience, and freshness requirements. Use `Cache-Control` that matches
  actual policy; never mark a response public or cacheable merely for performance.
- Use ETags and conditional GET when client or CDN validation is valuable. A matching `If-None-Match` returns 304
  without a representation body while retaining headers required by the cache.
- Use `If-Match` or a version precondition when stale writes can lose data. Return 412 for a failed precondition;
  reserve 409 for a domain conflict that remains invalid against the latest version.
- Caching, data, and operations owners govern invalidation, CDN behavior, and persistence consistency. The API
  contract states what clients may rely on, not mutable infrastructure detail.

Verify at least one claimed cache hit or revalidation flow, or one concurrent update, including real status,
headers, and body.
