---
name: performance
description: Use when analyzing, designing, reviewing, or changing measurable performance involving latency, throughput, queries, lists, pagination, N+1, batching, caching, timeouts, asynchronous work, rendering, or resource constraints, including decisions about caching repeated expensive work. Do not use for bounded CRUD or ordinary work without a performance concern, and never add caching, queues, or virtualization for hypothetical scale.
---

# Performance — Measure First, Choose the Smallest Sufficient Change

## Gate

Before proposing optimization, identify:

- the symptom and affected metric
- relevant workload, data volume, and concurrency
- the budget or required outcome
- a baseline and repeatable measurement

Without evidence, propose the cheapest valid probe first. Never add a cache, queue, index, or abstraction merely
because the pattern is familiar. Analysis is not authorization to mutate.

N+1 on a growing collection, unbounded data growth, and external I/O without a timeout or deadline are baseline
risks when those conditions actually exist; they do not require a benchmark to acknowledge. Measurement selects
and verifies the remedy rather than dismissing an observed risk.

## Data access

- Replace loop queries or N+1 with joins, batches, or `IN` when semantics remain equivalent.
- Bound, paginate, or stream lists that grow with users or data; genuinely fixed small lists need no added machinery.
- Evaluate indexes for frequent filters and sorts from query plans and write cost, not column names.
- Select and serialize only used data from large payloads while preserving the contract.

## Runtime and external I/O

- Give external I/O a timeout or deadline and make failures traceable.
- Move work beyond a request budget to asynchronous execution only when the user accepts deferred-result semantics.
- A cache requires defined key, owner, invalidation, consistency window, and fallback.
- Measure CPU, memory, connections, and queue pressure before increasing concurrency.

## Frontend

- Distinguish network, server, bundle, rendering, and interaction latency before changing code.
- Paginate, window, or virtualize only genuinely long collections.
- Lazy-load below-fold assets and declare dimensions when layout shift is possible.
- Constrain render scope for frequently changing state and measure before and after.

## Verify and report

Run the same workload against comparable states and report
`baseline → change → result → variance/coverage → trade-off`. One benchmark or different environments do not
prove improvement. Stop when the smallest change meets the budget and state a defer trigger for greater complexity.
