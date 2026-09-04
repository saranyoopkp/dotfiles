---
name: ui-ux-baseline:design-foundations
description: Define or modify shared visual foundations such as semantic color/contrast, typography roles/scales, spacing/grids, radius/elevation, iconography, themes/density, and motion tokens, including choosing an icon library or replacing decorative emoji in UI. Use when foundational values change across multiple screens or when making icon/emoji decisions; do not use for ordinary single-screen refinements or component API changes.
---

# Design Foundations

Foundations are shared values that make UI consistent and accessible, not a reason to change the brand or create a new style guide for every task. Prefer existing values, and add or change them only when shared consumers and clear semantics exist.

- Name tokens by intent, such as surface, text, action, feedback, and focus, rather than by color or raw value. Important states must not differ by color alone and must preserve context-appropriate contrast.
- Define type, spacing, grid, radius, and elevation roles and scales that support hierarchy. Do not create one-off values when existing semantics fit.
- Prefer icon libraries and sets observed in the repository, keeping semantics, size, stroke or optical weight, and alignment consistent. Do not assume library names, draw new SVGs, or silently add dependencies when no existing system is found.
- **Do not use decorative emoji in UI by default.** When decorative emoji exists, propose a semantically matching icon from the existing library. If the repository has no icon library, present options and costs before adding a dependency. Emoji is appropriate only for user content, brand requirements, or an explicit user request.
- Themes and density must preserve semantic-role meaning, contrast, and focus treatment. Avoid screen-specific overrides that fragment the system.
- Define duration and easing as shared tokens only when a shared use case exists. Motion purpose, triggers, and interruption belong to `motion-microinteractions`.
- Before changing an existing foundation, identify consumers, affected themes and viewports, migration needs, and required visual regression checks.

## Refactor Icon & Emoji

Before replacing existing items, inventory usage and classify it as decoration, action, state, user content, or brand content. Never bulk-replace user or brand content. Map existing emoji or icons to semantic icons found in the repository's library, then migrate through a shared primitive or one verifiable surface at a time while preserving visible labels, accessible names, interaction states, and layout. Do not combine icon changes with meaning or copy changes; semantic changes require the authorization and impact rules in `claude/rules/core/change-control.md`.

Remove old assets only after finding no remaining consumers, and verify screenshots for relevant states and viewports together with keyboard/accessibility checks from `interaction-a11y`. If migration is incomplete, identify the remaining items and owner.

`visual-direction` owns identity and new directions; `visual-polish` refines existing screens using the foundation; `layout-navigation` owns page composition; `interaction-a11y` owns semantic HTML, keyboard, and focus behavior; `design-system` owns component APIs and variants.

Before delivery, verify representative affected screens, including relevant themes, contrast, and focus treatment, using real artifacts when the environment supports it. If verification is unavailable, state the boundary instead of claiming it passed.
