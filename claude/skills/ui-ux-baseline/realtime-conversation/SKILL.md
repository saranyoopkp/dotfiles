---
name: ui-ux-baseline:realtime-conversation
description: Design chats, feeds, and realtime event streams where messages or records arrive over time. Use for sticky-bottom behavior, unread indicators, prepended history, WebSocket/socket events, presence, or live updates that may disrupt the user's reading position.
---

# Realtime Conversation

- **Sticky bottom**: when the view is already at the bottom and a new message arrives, auto-scroll with it.
- **Scrolling up releases the sticky state**: while users read earlier content, do not scroll over their position. Show a “New messages” indicator and let them choose to return to the bottom.
- Sending a message expresses intent to return to the bottom, so scroll down after the displayed result is reconciled.
- Paginate history while scrolling upward and preserve scroll position when prepending. Do not load all history initially without a data-size reason.
- Realtime events must handle ordering, duplicates, reconnection, and reconciliation with server state. Debounce burst mutations, and do not make effects depend on references that change on every refetch and create a feedback loop.
- Reserve media dimensions before loading, and distinguish new unread events from events the user has already seen.

At minimum, verify being at the bottom, reading earlier content while events arrive, sending a message, prepending history, and reconnect or duplicate-event handling supported by the actual system.
