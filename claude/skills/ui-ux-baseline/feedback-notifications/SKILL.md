---
name: ui-ux-baseline:feedback-notifications
description: Select and design toasts, banners, inline errors, alerts, success/failure messages, status announcements, and recovery feedback, including feedback voice and tone. Use when UI must communicate action results, errors, warnings, background completion, or any state users need to know about.
---

# Feedback & Notifications

Choose a channel based on urgency, how persistent the result is, where users can correct it, and whether they need to act next. Do not default to a toast merely because it is easy to implement.

| Situation | Appropriate default channel |
|---|---|
| Users must correct a field or understand local context | Inline validation/error near that point |
| A resource or entire section is unavailable while the user remains in the same context | Inline state or banner within that context |
| A brief, reversible result that need not be remembered and does not block the flow | Toast/status message |
| An important warning that must remain visible across pages or sections | Persistent banner or notification center, following the product pattern |
| A decision is required before continuing, or the effect is destructive/irreversible | Dialog/confirmation before the action, not a toast afterward |

## Voice & tone

- Use **professional-neutral** user-facing copy by default: clear, calm, respectful, concise, and actionable. Avoid excessive familiarity, slang, jokes, or filler unless the project convention explicitly permits them.
- Before changing wording, inspect the project-owned voice and tone convention in `CLAUDE.md` or its linked documentation. A convention may adjust personality and formality, but must not weaken necessary safety, accuracy, accessibility, consent, or recovery information.
- Adapt tone to state: errors are factual, non-blaming, and actionable; validation is brief; success confirms actual results; destructive, security, or money-related actions are explicit and serious; empty/help states may be friendly but concise; internal/admin surfaces may use technical terms when the audience understands them.

- Map errors to the smallest scope users can correct: field errors → inline at the field; cross-field/domain validation → form level; resource/global failures → context level. If a response does not identify a field, do not guess one. Do not substitute a transient toast for feedback users must fix or revisit.
- Toasts are transient feedback, not a hiding place for correctable errors, results with important detail, or failures requiring retry. Messages users may need later require a more persistent home.
- A toast must concisely identify the result and relevant object or action, remain long enough to read, offer an action or retry only when it actually works, and deduplicate or batch burst events to avoid spam.
- Errors must distinguish what failed, what still succeeded, the effect on data, and what users can do next. Never summarize a partial failure simply as “Success.”
- Success from optimistic UI or background jobs must not imply server confirmation before it exists. Present pending and reconciliation states according to risk.
- Use semantic status/alert roles and announcements appropriate to urgency. Do not rely solely on color, motion, or self-dismissed toasts, and do not steal focus from the user's current work without reason.

Toast and banner component APIs and visual variants belong to `ui-ux-baseline:design-system`; tokens belong to `ui-ux-baseline:design-foundations`; interactive accessibility patterns belong to `ui-ux-baseline:interaction-a11y`; general UI wording belongs to `ui-ux-baseline:content-copy`. This skill owns the **policy for selecting feedback channels and content**.
