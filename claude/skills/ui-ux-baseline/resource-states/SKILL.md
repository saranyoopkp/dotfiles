---
name: ui-ux-baseline:resource-states
description: Design resource UI states loaded or refreshed by the system, including loading, empty, error, loaded, stale-data, and retry states. Use when a component or page displays data from an API, query, cache, or asynchronous read operation.
---

# Resource States

Start from the actual data flow: determine which states can result from requests, cache, permissions, queries, or user actions, and design only those states instead of manufacturing a complete checklist.

- Provide loading, empty, error, and loaded states when the data flow or user actions can actually produce them.
- When the content shape is known, use a skeleton close to the real layout to prevent layout shifts. When it is unknown, use progress feedback that does not falsely imply content already exists.
- Distinguish `no data in the system` from `no search results`; each state must explain its meaning and provide an appropriate next step.
- Errors must explain what users can do next: retry, change the query, check permissions, or return to a safe page. Do not discard entered or selected context unnecessarily. When choosing among toast, banner, and inline error, read `ui-ux-baseline:feedback-notifications`.
- Refresh and stale-data states must communicate how old the data is and which interactions are safe while waiting. Do not silently present old data as current.

At minimum, verify `initial load → loaded`, `load → error → retry`, and query or action transitions that produce empty or refresh states when those flows actually exist.
