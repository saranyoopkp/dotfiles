---
name: ui-ux-baseline:interaction-a11y
description: Interaction and accessibility standards for UI with interactive elements. Use whenever adding or changing a button, link, input, menu, dialog, tooltip, disclosure, drag-and-drop interaction, or custom control, regardless of screen size.
---

# Interaction & Accessibility

- Prefer semantic HTML: buttons are `<button>`, navigation uses links and `nav`, and inputs are form controls. Do not substitute `<div onClick>` for controls with existing semantics.
- Interactive elements must expose every observable state that can actually occur: hover, active, **focus-visible**, disabled, and pending. Keyboard users must always be able to see focus.
- Every action must be keyboard reachable and work according to native keyboard expectations. Do not recreate roles or keyboard handlers when a native element already provides them.
- Follow WAI-ARIA APG for dialogs, menus, tooltips, and disclosures, including correct focus management, Escape behavior, labeling, and announcements. Do not duplicate an existing accessible name with ARIA.
- Validation, errors, and dynamic updates must provide names, instructions, and announcements that assistive-technology users can understand. Color alone is not sufficient communication.
- Meaningful or continuous motion must respect `prefers-reduced-motion`; reduce or disable it without hiding information, state, or controls.
- Icon-only controls need accessible names. Ambiguous or risky actions need visible labels and must not rely solely on tooltips. Hide decorative icons from the accessibility tree, and never use emoji as the only signal for an action, state, or severity.

At minimum, use the keyboard to verify tab order, focus visibility, activation, dismissal, and focus return for patterns that actually exist.
