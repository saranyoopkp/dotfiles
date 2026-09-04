---
name: ui-ux-baseline:motion-microinteractions
description: Design or modify motion, transitions, animation, progress, reveals, scrolling behavior, and microinteractions that communicate state or feedback. Use when movement is part of UI behavior rather than merely static visual design.
---

# Motion Design & Microinteractions

Motion must communicate hierarchy, spatial continuity, state transitions, pending/progress, or action results; remove decoration that serves none of these. Before implementation, define `trigger → communicated state → motion → completion/interruption`.

- User actions must receive immediate feedback. Animation must not obscure pending or error states or imply completion before the server confirms it.
- Each microinteraction should answer one question, such as whether an item is actionable, what is happening, or whether it succeeded. Do not make several elements compete for attention through motion.
- Motion caused by incoming events must not steal focus, change scroll position, or disrupt reading. For chat, feeds, or realtime UI, also read `realtime-conversation`.
- Respect `prefers-reduced-motion`: reduce or replace movement with state, opacity, or instant changes while preserving information, progress, and controls. Accessibility semantics and focus belong to `interaction-a11y`.
- Avoid animations that cause layout shifts or move interaction targets beneath the pointer or focus. Use implementations shown to perform smoothly on the current stack; do not optimize from assumptions.
- Shared duration and easing tokens belong to `design-foundations`. This skill owns the purpose, trigger, and behavior of motion, not merely numeric values.

Verify real interactions or recordings when possible, because screenshots cannot prove timing, interruption, or reduced-motion behavior. For pending, success, and failure states, read `task-flows` or `feedback-notifications`; this skill does not own business flows.
