---
name: ui-ux-baseline:task-flows
description: Design user-initiated task flows such as form submission, inline editing, toggles, deletion, confirmation, retry, and asynchronous mutation. Use when users ask the system to create, edit, change the state of, or act on data.
---

# Task Flows

Design the flow as `intent → validation/confirmation → pending → result → recovery`, not merely as a button that invokes a mutation.

- Before submission, show validation near the place where it can be corrected, and preserve entered values when the server rejects the request.
- While pending, prevent duplicate submissions according to the action's semantics; do not disable everything so completely that users cannot tell what is happening.
- Success must reflect the result that actually occurred in the UI. Failure must state the impact and a recovery or retry path without making users guess whether the task succeeded; choose the channel according to `ui-ux-baseline:feedback-notifications`.
- Optimistic updates are appropriate when rollback and reconciliation are clear; the server result is the source of truth when there is a conflict.
- Destructive or irreversible actions, and actions that change important state, must explain the consequence and ask for confirmation while the user can still cancel.

For every mutation flow, test at least the happy path, pending or duplicate intent, and realistic failure and retry paths.
