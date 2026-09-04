---
name: ui-ux-baseline:visual-polish
description: Refine the visual design of an existing screen or component for clarity, readability, balance, and finish while preserving its brand, visual direction, information architecture, and behavior. Use for requests to clean up, simplify, or polish UI; adjust spacing, typography, color hierarchy, density, or alignment; or refine effects such as shadows, blur, gradients, and overlays. Do not use for open-ended design proposals, requests to make a UI beautiful, modern, premium, or changes to visual direction.
---

# Visual Polish

Preserve the existing brand and flow. This work refines perception and readability; it does not authorize silent changes to information architecture, copy, interaction, or product behavior. If those must change, read the owning child skill and apply the authorization and impact rules in `claude/rules/core/change-control.md` when behavior or meaning is affected.

- Start with the actual reading order: the primary task, primary action, context, and secondary detail must be distinguishable before adjusting color or decoration.
- Refine in this order: hierarchy → grid/alignment → spacing/density → typography → color/contrast → surface/detail. Do not paint over layout or content-hierarchy problems.
- Prefer existing tokens, components, and visual language. New shared colors, spacing, type, or theme values belong to `design-foundations`, and shared components or variants belong to `design-system`; do not improvise them on one screen.
- Effects such as shadows, blur, gradients, overlays, opacity, or texture must communicate real hierarchy, depth, grouping, or state. Do not use them to obscure hierarchy or contrast, or make every surface equally prominent.
- Polish must not weaken contrast, focus visibility, tap targets, responsive priority, or states users depend on. A more readable visual design with missing states is not polished.
- When the environment supports it, compare the real screen or screenshots at important viewports. Without a visual artifact, state the limitation rather than claiming visual regression passed.

For identity or brand-direction changes, read `visual-direction`. For effects that change over time, through interaction, or across state transitions, read `motion-microinteractions`. Interaction/accessibility, layout, and feedback remain with their existing child owners.
