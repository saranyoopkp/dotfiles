---
name: ui-ux-baseline
description: Baseline UX for building or changing user-facing views: feedback states, interaction safety, accessibility and responsive behavior. Use when a change affects UI behavior or layout.
---

# UI/UX Baseline

Use the project design system and existing interaction patterns first. Apply checks that match the affected user journey rather than adding every state to every component.

- A view that fetches or mutates data gives appropriate loading, empty, error and success feedback where those states are reachable.
- Prevent duplicate destructive or costly actions; make pending work and recoverable failures understandable.
- Lists, feeds and real-time views preserve the user's position and provide a clear strategy for new, missing or failed items when relevant.
- Interactive controls are keyboard-operable, have an accessible name, visible focus and a disabled/loading state when needed.
- Validate responsive layout, overflow and contrast for the changed view; use semantic HTML before custom accessibility workarounds.

Before delivery, exercise the primary changed journey at a representative viewport and state. State any meaningful state or device not checked.
