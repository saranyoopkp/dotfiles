---
name: ui-ux-baseline:visual-direction
description: Define visual direction for new pages, landing pages, marketing surfaces, identity-changing redesigns, or existing pages where users ask for a design proposal or a more beautiful, modern, premium, or distinctive result, inheriting an evidenced visual language when appropriate. Use when the task requires aesthetic direction, brand expression, typography, palette, or a layout concept; do not use for minor polish that must preserve the existing visual direction, information architecture, and behavior.
---

# Visual Direction

## Intent boundary

- For an existing page that users only want cleaner, simpler, more readable, or more refined while preserving visual direction, IA, and behavior, use `visual-polish`.
- For an existing page that users want “more beautiful,” modern, premium, distinctive, redesigned, or open to composition or identity changes, use this skill first even if behavior will not change.
- When visual intent is unclear, propose a concise direction capsule before changing code. Do not default to `visual-polish` merely because the screen already exists.

## Creative direction without conservative bias

- Terms such as operational, table, or existing screen provide context; they are not hard gates limiting work to polish. When users request a more beautiful, modern, premium, distinctive, or characterful result or ask for a design proposal, leave room to change composition, grouping, visual anchors, and hierarchy while preserving semantics, behavior, accessibility, and existing contracts.
- Before choosing a direction, inspect related pages, shared tokens and components, and the latest evidenced visual decisions. When sibling pages or prior work establish a visual language, extend it into one system rather than starting from a new generic style. Reusing existing language does not prohibit new expression.
- For an existing page, perform a concise visual audit from code and screenshots or runtime when available. Identify the current visual anchor, what makes the screen feel generic, dense, or weightless, and the constraints that must remain. Then, before implementation, propose a direction with a thesis, composition, type and color roles, visual anchor, and an ordered set of changes that will make a visible difference.
- When the creative request is explicit, do not stop at clean, readable, consistent, or accessible without a visual point of view. Those qualities are the acceptance floor, not the entire aesthetic outcome.
- Do not use “no decoration,” “follow the existing pattern,” or “minimal” alone as reasons to reject a direction. Evaluate whether an element supports the thesis and product goal, then explain its trade-off.

The goal is a visual identity grounded in the actual brief, not novelty for its own sake. Operational screens, settings, tables, and repeated flows still require clarity and consistency as a floor. When the brief requests creative direction, choose expression and a signature that advance the product goal instead of suppressing them merely because this skill is loaded.

## Before writing UI

Define a one-sentence **aesthetic thesis** from the subject, audience, and one primary task of the page. Prefer existing context, brand systems, and preferences over guesses. If the brief is open-ended, propose reasoned directions and separate decisions the user must make from implementation details the agent can decide.

## Proposal gate

- If the brief has not selected an aesthetic direction and multiple approaches would materially change composition, identity, approach, or scope, stop after the audit and propose two or three meaningfully distinct directions.
- Summarize each option's thesis, visual anchor, key moves, preserved elements, trade-offs, and scope. A recommendation is welcome, but label it as a recommendation rather than approving it on the user's behalf.
- Make proposals concrete and decision-ready. Do not merely say the work is creative or ask broadly what the user wants. Generate candidates from the brief, evidence, and constraints.
- A request only to “make it more beautiful,” “modern,” or “distinctive” authorizes exploration and proposals; it does not authorize selecting a direction and immediately writing code or making mutations. Wait for the user to select or specify a direction.
- If the user has specified or selected a direction, or the task is minor polish that introduces no new creative decision, proceed while preserving hard constraints and the agreed visual language.

For a new page or major redesign, create a concise direction capsule before writing code:

- **Color**: three to six semantic roles or tokens aligned with the existing foundation.
- **Type**: only the display, body, and utility roles the content needs; typography must support hierarchy rather than float as decoration.
- **Layout**: reading order and hero or primary action justified by the page's main task.
- **Signature**: one distinctive element grounded in the actual subject or product; omit it when functional clarity matters more.

Before building, test the plan against the brief. If changing the subject would leave the page looking the same, or if it uses a bento-card layout, gradient hero, metric strip, badge, or numbered sequence merely as a default, revise the direction first. Use structure, labels, dividers, and motion to communicate real information rather than add texture.

## During implementation and review

- Treat copy as part of interaction: use the same action term throughout a flow (`Publish` → `Published`), explain what users control, and give error and empty states a next step.
- Use motion as a single rhythm serving hierarchy or feedback. Remove decoration that does not serve the thesis, and let `interaction-a11y` own reduced-motion, focus, and keyboard requirements.
- Review hierarchy, spacing, typography, contrast, responsive layout, and the signature element from real visuals when the environment supports screenshots. Without real visuals, state the limitation instead of claiming visual QA passed.
- For interactive elements, resource states, mutations, feedback, collections, or realtime flows, read the matching child skill. This skill does not replace functional UX.
- When a direction requires creating or changing a visual role shared across screens, define it with `design-foundations`. Screen-specific polish belongs to `visual-polish`.
