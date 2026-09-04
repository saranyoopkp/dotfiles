---
name: ui-ux-baseline:collections
description: Design UI for finding, reading, ordering, selecting, and managing multiple records, including tables, lists, grids, search/filter/sort, pagination, bulk actions, and virtualized collections. Use when users manage collections that are not directly part of a realtime conversation.
---

# Collections

Treat query, filter, sort, pagination, and selection as task state, not widget details.

- Distinguish a genuinely empty collection from an empty query/filter result; show the active query and a reset path that does not disorient the user.
- Preserve state when users return, refresh, or share a URL to the extent supported by the product architecture; do not silently reset filters, pages, or selection.
- Pagination and load-more controls must communicate scope and loading state. Define explicitly how page and selection state reset or reconcile when sort or filter changes.
- Bulk actions must show the number and scope of affected items, including partial failures when they can occur.
- Use virtualization or server-side queries when data size or real measurements justify them; do not break keyboard use, focus, or scroll restoration merely for optimization.

At minimum, verify empty collections, no-match queries, paging/filter transitions, selection, and bulk-action results for flows that actually exist.
