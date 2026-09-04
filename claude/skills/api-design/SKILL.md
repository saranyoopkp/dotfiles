---
name: api-design
description: Router for HTTP and REST API standards. Use when designing or changing endpoints, request/response contracts, errors, collections, mutations, asynchronous operations, caching/concurrency, or public API evolution. Map the HTTP/data flow and read matching child skills first; every new endpoint or request/response change requires api-design:contract-core.
---

# API Design (HTTP / REST)

Before changing an API, identify whether the client reads a resource, manages a collection, performs a mutation,
waits for an operation, uses conditional caching, or consumes a compatibility-sensitive contract. Read the
matching child before changing the contract or writing the handler.

| Work surface | Required child |
|---|---|
| New or changed endpoint, representation, or HTTP semantics | `api-design:contract-core` |
| Error, validation response, authentication, or authorization failure | `api-design:errors` |
| List, search, filter, sort, or pagination | `api-design:collections` |
| POST/PUT/PATCH/DELETE, side effect, duplicate submission, or retry | `api-design:mutations` |
| 202, background job, long-running action, or operation status | `api-design:async-operations` |
| Cache headers, ETag, conditional request, or stale write | `api-design:caching-concurrency` |
| Public contract change, versioning, deprecation, or migration | `api-design:evolution` |

One endpoint may require several children when its actual flow spans them. Do not load every child as a checklist,
and do not skip a matching child because a handler looks small. `risk-review`, validation boundaries,
performance/N+1, and external-integration safety retain their existing ownership.

## Resource operation inventory

For an API-managed resource, inventory `list/get/create/update/delete` and domain operations from actual contracts
and consumers before designing. An unsupported operation must be an explicit decision, not an omission. Inventory
is analysis, not authorization to add operations outside scope. Use `contract-core` for representations and methods,
`collections` for lists, `mutations` for writes, and `data-design:lifecycle-governance` for deletion or retention.

Before changing client-observable behavior, apply authorization and impact rules from
`claude/rules/core/change-control.md`. A published API is a compatibility surface, not an implementation detail.
