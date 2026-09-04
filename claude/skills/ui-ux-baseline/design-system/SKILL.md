---
name: ui-ux-baseline:design-system
description: Design or modify shared UI components, primitives, component APIs, and variants. Use when changing UI reused across multiple screens or deciding whether to abstract feature UI into a shared component; do not use for shared visual tokens or themes.
---

# Design System

- Separate feature-specific UI from shared primitives. Abstract only when a shared contract and use case are demonstrated, not merely because two instances look alike once.
- Before changing a shared component, identify its consumers, existing API/variants, and the visual and interaction contracts that must remain intact. A component already in use is an internal public surface.
- Use semantic tokens from `design-foundations`; do not invent colors, spacing, type scales, or themes inside an ad hoc component. If a shared foundation is missing, route that work to its owner first.
- Variants must express behavioral or semantic meaning, not expose props that permit arbitrary combinations. Keep feature-specific composition close to the feature.
- Shared primitives must own their semantics, focus, disabled/pending states, and responsive behavior, but should not absorb each feature's business flow.

Before delivery, verify affected consumers, relevant visual and interaction regressions, and API/variant compatibility. If behavior changes, first apply the authorization and impact rules in `claude/rules/core/change-control.md`.
