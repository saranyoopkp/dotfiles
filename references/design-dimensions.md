# Dimension Sweep — “When A, Then Maybe B”

Use this tool while designing a feature: sweep every dimension and make an explicit decision for each. “Never considered it” is the forbidden outcome.

| Decision | Meaning | Action |
|---|---|---|
| **Do now** | Inside current scope | Implement |
| **Preserve the boundary** | Not implemented, but schema or interface remains compatible | Add only justified schema flexibility such as nullable references or extensible enums; do not prebuild code |
| **Defer** | Expected eventually, but not now | Record it under CLAUDE.md Future boundaries and confirm today's design does not block it |
| **Reject permanently** | Conflicts with mission or constraints | Record a one-line rationale to prevent repeated debate |

The distinction between defer and reject is crucial. Deferred work returns; without a waiting place, it becomes a surprise colliding with a closed design. YAGNI remains valid for code, but it does not justify permanently closing schema or contract boundaries.

## Standard dimensions

| Dimension | Trigger question | Message-inbox example |
|---|---|---|
| **Content type** | One format or several? | Text → media, files, voice, stickers, link previews |
| **Cardinality** | One, many, or tens of thousands? | One conversation → tabs → pagination or virtualization |
| **Actor** | Who else can use it? | User → roles, guests, bots, external API systems |
| **Direction** | Read-only or complete lifecycle? | Receive → reply → edit → delete → undo → forward |
| **Time** | Only now, or history and future? | Realtime → history, search, scheduling, expiry, audit |
| **State** | What exists beyond the happy path? | Loading, empty, error, partial → offline, draft, retry |
| **Synchronization** | One location or many? | One screen → devices, concurrent agents, conflicts |
| **Locale** | One language, currency, and timezone? | One locale → i18n, multiple currencies, customer timezones |
| **Scale and failure** | What happens at 100× load or during failure? | Provider outage, duplicate delivery, bursts, rate limits |
| **Permission** | Who can see or do what? | Everyone → per-role, per-tenant, per-conversation |
| **Lifecycle** | How does data age and disappear? | Create → archive → export → irreversible deletion |
| **Integration** | Standalone or connected? | Manual → import/export, API, outbound webhook, embed |

## Usage

1. Before committing a new feature's schema or API, sweep the table once; this should take about five minutes.
2. Reflect “preserve the boundary” in the schema, “defer” in Future boundaries with a non-blocking check, and “reject permanently” with a rationale.
3. User requirements often describe only one happy-path dimension; use the sweep to identify useful questions.
4. Before implementing a deferred item, verify that the original assumptions still hold.

## Adding a dimension

Add a row only after a genuinely expensive retrofit reveals a missed dimension. Like rules, dimensions should be distilled from evidence rather than speculation.
