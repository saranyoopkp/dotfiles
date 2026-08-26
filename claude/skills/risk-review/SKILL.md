---
name: risk-review
description: Review or design work that crosses authorization/tenant, money, time/timezone, external integration, production, recovery, secret, PII, destructive, or irreversible boundaries. Use for a related design, mutation, or acceptance decision; not for incidental mentions.
---

# Risk Review

Read only the reference matching the active risk surface:

- auth, role, permission, tenant isolation → [references/authorization.md](references/authorization.md)
- amount, currency, billing, allocation, or business-time boundary → [references/money-time.md](references/money-time.md)
- webhook, OAuth, provider call, retry, or outbound side effect → [references/external-integrations.md](references/external-integrations.md)
- production release, secrets/PII, monitoring, backup, rollback, or recovery → [references/production.md](references/production.md)

Apply safeguards in proportion to actual stage and impact. Preserve the user's chosen scope; a review finding does
not authorize adjacent hardening or production mutation. Verify the risk-bearing path directly and report gaps
instead of expanding a prototype into production architecture by default.
