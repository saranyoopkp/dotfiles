---
name: ui-ux-baseline
description: Generic UI/UX quality, content, and visual-design baseline for frontend work. Use when planning, designing, reviewing, or modifying user-facing UI, including structure, copy, interaction, state, accessibility, responsive behavior, visual consistency, pages/components, lists/tables, or UI that fetches or presents data, as well as UI requested to be beautiful, clean, polished, or professional. Route on demand to child skills for the relevant surfaces; do not load every child by default, and always read ui-ux-baseline:interaction-a11y for interactive UI.
---

# UI/UX Baseline

Before changing UI, identify whether users are reading content, viewing data, taking action, managing a collection, following time-based information, or using a shared primitive. Separate copy and aesthetic intent before reading child skills: general wording goes to `content-copy`; clean-up or polish that preserves the existing structure goes to `visual-polish`; requests for a design proposal or a more beautiful, modern, premium, or distinctive result go to `visual-direction` **before** design or implementation.

## Generic quality baseline

Use this lens for all UI/UX work, whether the user calls it “beautiful,” “clean,” or “polished,” or asks only for a feature change. It does not automatically authorize adding decoration or changing the brand.

- Start from the user goal, audience, context, and primary action. Evaluate beauty through clarity, hierarchy, proportion, consistency, and confidence in use, not by the number of effects.
- Every user-visible message and element must help users understand, decide, or continue their task. Keep terminology, labels, and actions consistent, and do not add explanation merely because space is available.
- Put the primary task, decision-relevant state, and next step before secondary detail. Use progressive disclosure for supporting explanations, but never hide important cost, consent, errors, or recovery solely in a tooltip.
- Prefer existing brand, tokens, components, and platform conventions. Do not invent generic patterns, palettes, spacing, or visual treatments merely because they look modern by default.
- Account for realistic loading, empty, error, partial, pending, success, disabled, focus, and responsive states. Visual polish that removes a state or recovery path does not pass.
- Preserve semantic interaction, keyboard and focus behavior, contrast, target size, and reduced-motion behavior appropriate to context. Accessibility is part of quality, not final cleanup.
- When the environment supports it, inspect screenshots or the real UI at important viewports and report evidence limitations. Do not claim visual quality passed from code inspection alone.

This section is a shared quality lens only. Decision procedures and implementation details belong to the child skills below. One task may require several children when the actual data flow or states justify them.

## Product surface boundary

- User-facing UI communicates what users can observe, the impact, and what they can do next. Keep implementation detail, raw code, protocol information, and diagnostic evidence in logs, test artifacts, or opt-in technical details unless the audience and task genuinely require them.
- Test evidence must observe product behavior. Do not change product copy or surfaces merely to make screenshots or test artifacts self-explanatory.

| Work characteristic | Must read |
|---|---|
| Create a new page or landing page, redesign visual identity, or respond to a request to propose a design or make an existing page more beautiful, modern, premium, or distinctive | `ui-ux-baseline:visual-direction` |
| Refine the visual design or UI effects of an existing screen—such as cleaning up, simplifying, spacing, typography, shadows, blur, gradients, or overlays—while preserving brand, flow, IA, and direction | `ui-ux-baseline:visual-polish` |
| Add or modify transitions, animation, progress, reveals, scrolling behavior, or microinteractions | `ui-ux-baseline:motion-microinteractions` |
| Create or modify shared color, type, spacing, grid, theme, elevation, icon, or motion tokens | `ui-ux-baseline:design-foundations` |
| Choose an icon or icon library, establish icon language, or encounter decorative emoji in UI | `ui-ux-baseline:design-foundations` |
| i18n/localization, translation, locale formatting, text expansion, or RTL | `ui-ux-baseline:content-localization` |
| General UI wording such as headings, labels, buttons, placeholders, helper text, tooltips, empty/help copy, or terminology | `ui-ux-baseline:content-copy` |
| Render a resource from server or client state | `ui-ux-baseline:resource-states` |
| Submit, edit, toggle, delete, confirm, or retry | `ui-ux-baseline:task-flows` |
| Select or modify toasts, banners, inline errors, alerts, success/failure messages, or recovery feedback | `ui-ux-baseline:feedback-notifications` |
| Search, filter, sort, tables/lists, pagination, selection, or bulk actions | `ui-ux-baseline:collections` |
| Chat, feeds, event streams, presence, or information arriving over time | `ui-ux-baseline:realtime-conversation` |
| Page layout, navigation state, or responsive/mobile hierarchy | `ui-ux-baseline:layout-navigation` |
| Any interactive element | `ui-ux-baseline:interaction-a11y` |
| Create or modify shared components, primitives, or variants | `ui-ux-baseline:design-system` |

A task may read several child skills according to its actual data flow. Do not load all children merely as a checklist, and do not skip a directly triggered child because the UI appears small.

If the requested design conflicts with a child skill's constraints, summarize the impact and options before implementation, following the authorization and impact rules in `claude/rules/core/change-control.md`.
