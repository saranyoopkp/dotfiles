---
name: api-design:evolution
description: Manage evolution, compatibility, versioning, deprecation, and migration of public REST contracts. Use when changing request or response shapes, semantics, enums, query or pagination behavior, or endpoints on which existing clients may depend.
---

# Evolution

- Before changing an existing endpoint contract or observable semantics, inventory consumers from actual usage:
  generated clients, API wrappers, frontend, mobile, services, and external contracts. If an affected frontend
  consumer exists, invoke only the matching `ui-ux-baseline` child before planning or changing it, even during
  plan or review work, then migrate and verify that user flow. If consumer work is outside authorized scope,
  preserve compatibility or request a decision. A new endpoint without a frontend consumer does not require UI
  guidance merely because it is an API.
- Distinguish additive from breaking change by observable client behavior. An optional field is usually additive;
  changed meaning or defaults, removed or renamed fields, narrowed enums, and changed status, error, or pagination
  semantics create compatibility risk.
- Version only when compatibility cannot bridge the change. Follow the product's existing URL, header, or media-type
  convention and record ownership, client migration, and retirement conditions.
- Deprecation identifies affected consumers, replacement, migration window, and telemetry or verification used to
  retire the old surface. Never announce deprecation and remove immediately without evidence.
- For destructive change, expand with an optional replacement, migrate consumers with telemetry, then contract only
  after evidence shows no old consumers remain. A rename is not a one-step change.
- Update OpenAPI or schema, generated clients, documentation, and contract tests with the implementation.

Before a behavioral or breaking change, apply authorization and impact rules in
`claude/rules/core/change-control.md`, including alternatives and approval. Feature flags and rollout mechanisms
must obey `compatibility-rollout` and cannot conceal incompatible state. Before completion, verify a representative
consumer flow or contract test that exercises actual compatibility.
