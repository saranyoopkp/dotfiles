---
name: api-design:contract-core
description: Define HTTP/REST request-response contracts, resource naming, method/status semantics, representations, content negotiation, rate-limit responses, and repository-owned OpenAPI or JSON Schema. Use whenever adding or changing an endpoint or public request/response shape.
---

# Contract Core

- Name resources with nouns rather than verbs; nesting deeper than two levels requires genuine ownership rationale.
- GET is safe and idempotent; PUT and DELETE are idempotent; PATCH is partial update. Choose 200, 201 with
  `Location`, 202, or 204 according to the real outcome.
- Define fields, null versus omission, enums and optional fields, timezone-aware datetimes, and units or numeric
  formats so clients have one interpretation. Money and authorization remain owned by their risk rules.
- Support only content formats or versions the product genuinely accepts. Do not advertise multiple media types
  without a verified contract and consumer.
- A client-visible rate limit needs a consistent contract: 429, `Retry-After` when known, and quota/reset headers
  following product conventions. Algorithms and infrastructure policy belong to resilience and operations.
- When OpenAPI or JSON Schema is canonical, update it and generated or shared clients in the same work. Do not
  create an ownerless parallel specification from a handler.

Before delivery, exercise at least success and each changed representation. Compare method, status, headers, and
body with the actual client or schema contract, not only the handler.
