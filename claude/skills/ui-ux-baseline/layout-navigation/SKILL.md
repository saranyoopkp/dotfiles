---
name: ui-ux-baseline:layout-navigation
description: Design page layout, information hierarchy, navigation state, and responsive/mobile behavior. Use when creating or changing screens, routes, shells, headers/sidebars, route transitions, responsive CSS, or the placement of actions and content.
---

# Layout & Navigation

- Primary navigation must use consistent placement and language across pages serving the same role. Users must know where they are and how to return to the prior context.
- Primary actions and decision-relevant states should be reachable in the initial viewport when the task context requires it. Do not hide important actions behind overflow without reason.
- Order content by decision priority. Information users need to decide, understand current state, act, or recover belongs in the primary view. Use progressive disclosure for supporting explanations, examples, and technical detail, but never hide important cost, consent, errors, or recovery solely in a tooltip.
- Responsive design reprioritizes information and actions for available space; it is not merely a smaller desktop. Define sidebar, table-overflow, action-group, and content-priority behavior at real breakpoints.
- Verify supported mobile, narrow desktop, and wide viewports. Avoid unintended horizontal overflow and unreachable actions.
- Layout state changes must preserve user orientation: titles, context, selection, and in-progress actions should not jump or disappear silently.

## Navigation state

- Keep the current route, active navigation item, selected tab, and page context aligned, especially for nested routes, direct links, and refreshes. Do not communicate state solely through color or styling that some users cannot perceive.
- Define which state belongs in the URL/history and should be shareable or restorable, and which state is transient to the shell. Back/forward navigation and deep links must not lead users into a misinterpreted context.
- Route changes should intentionally preserve or restore scroll, focus, and reading position. During transitions, communicate loading and errors without suggesting that work or data disappeared.
- Sidebars, menus, drawers, and disclosures need predictable open/close behavior when routes or viewports change. Do not retain state across contexts without a product reason.
- Before leaving a page with unsaved input, warn only when data is genuinely at risk of loss. Do not interrupt ordinary navigation or create duplicate confirmations.

Accessibility criteria for interactive elements belong to `interaction-a11y`; do not repeat ARIA or keyboard details here. Grid and spacing scales belong to `design-foundations`; this skill still owns the ordering and placement of page content and actions.
