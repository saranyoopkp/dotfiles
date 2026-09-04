---
name: ui-ux-baseline:content-copy
description: Design or revise general UI text such as headings, labels, buttons, placeholders, helper text, tooltips, empty/help copy, and terminology while preserving meaning, accessibility, and project voice. Use when wording or content clarity is the primary task; do not use in place of feedback-notifications, content-localization, or visual-direction.
---

# UI Content Copy

Derive copy from the user goal, audience, context, and required action. Check the project's terminology and voice/tone before changing wording. If the project defines none, use a professional-neutral voice: clear, respectful, concise, and not overly casual.

- Give each piece of copy one job, and put what users need to know or do before secondary detail. Use progressive disclosure for supporting explanations, but do not hide important cost, consent, error, or recovery information solely in a tooltip.
- Use consistent names for actions, objects, and states throughout a flow. Labels and buttons must describe what will actually happen, and placeholders must not serve as primary labels.
- Remove filler, jargon, and explanations that do not help a decision. Do not invent claims, promises, or terminology without product or domain evidence.
- Copy used as a visible label, accessible name, instruction, or state must remain understandable apart from the layout. Semantic, keyboard, and focus details belong to `interaction-a11y`.
- If wording materially affects meaning, consent, risk, public terminology, or brand, propose concise options and trade-offs before editing. Small refinements within a clear scope may proceed.

## Boundary

- Error, validation, success, warning, notification, and recovery channels or content → `feedback-notifications`
- Translation, locale, pluralization, formatting, text expansion, and RTL → `content-localization`
- Visual identity, composition, or aesthetic direction → `visual-direction`
- Button/input/menu/dialog semantics and accessible interaction → `interaction-a11y`

Before delivery, verify changed terminology, realistic long and short text, and consistency between labels, actions, and results. Do not change product behavior merely to make copy read better.
