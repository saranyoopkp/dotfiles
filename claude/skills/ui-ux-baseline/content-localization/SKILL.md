---
name: ui-ux-baseline:content-localization
description: Design or modify UI localization/i18n, translation keys, locale fallbacks, pluralization/interpolation, date/number/currency formatting, text expansion, and RTL. Use when UI supports multiple languages or locales, or when adding text to a localized surface.
---

# Content & Localization

Inspect the repository's existing localization system, locale source, key conventions, and formatters before editing. Do not assume a library, locale, or fallback, and do not create a parallel i18n system.

- Store user-visible text in translation sources according to existing conventions. Do not use translated text as logic keys, persisted enums, or selectors that code depends on.
- Use the existing system's pluralization, gender, and interpolation support. Do not assemble sentences from fragments that translators cannot reorder. Variables need context and escaping appropriate to the output boundary.
- Format dates/times, numbers, and currencies with locale-aware formatters while preserving source values, timezone, and currency semantics from their existing owner. Localization changes presentation, not data.
- Preserve the observed missing-key and fallback behavior, and cover errors, validation, toasts, empty/loading states, accessible names, and user-visible metadata in the same localization surface.
- Design for text expansion, wrapping, font fallback, and languages without spaces. Do not lock dimensions to the text of one language.
- Verify RTL reading/order, alignment, focus/navigation, and directional icons. Mirror only elements that convey direction; do not mirror logos, trademarks, or media content.

## Refactor Existing UI

Inventory user-visible text from the actual repository, including inline strings, validation/errors, states, accessible names, metadata, and runtime-composed text. Separate migration into two layers:

1. **Extract while preserving behavior**: move existing copy into translation keys or sources, wire up fallback behavior, and preserve existing wording, formatting, variables, and fallback behavior.
2. **Localize or change semantics**: add locales, plural rules, formatters, wording, or RTL as separate work. Changes to meaning, defaults, or behavior require the authorization and impact rules in `claude/rules/core/change-control.md`.

Migrate one verifiable surface at a time, use a single key convention and source, and find consumers before removing the old inline source. Do not leave one message owned by two sources without a migration plan. Compare the default locale with the baseline first, then verify fallback, missing keys, plurals, text expansion, and supported RTL behavior.

Visual icon systems belong to `design-foundations`; accessible labels and semantics belong to `interaction-a11y`; timezone and money semantics remain with their existing rule owners. Before delivery, verify the primary locale, fallback, long text/plurals, and RTL when the product declares support. Report unsupported locales accurately.
