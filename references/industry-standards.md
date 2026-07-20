# Industry Standards Reference

> ไว้เปิดดูตอนชนปัญหา ("เรื่องนี้มีมาตรฐานชื่ออะไร ไปค้นต่อ") — ไม่ใช่ backlog ให้ encode เป็น rule

## Architecture & Code
SOLID · DRY / KISS / YAGNI · Separation of Concerns · Clean/Hexagonal Architecture ·
DDD (bounded context) · 12-Factor App · Postel's Law · Principle of Least Astonishment

## Security
OWASP Top 10 · OWASP ASVS · Least Privilege / Defense in Depth / Zero Trust ·
ISO 27001 · NIST CSF 2.0 · CIS Benchmarks / Controls v8 · STRIDE (threat modeling) ·
OWASP Top 10 for LLM (prompt injection ฯลฯ)

## Auth & Identity
OAuth 2.0 / 2.1 · OpenID Connect (OIDC) · SAML 2.0 · JWT (RFC 7519) / JOSE ·
WebAuthn / FIDO2 / Passkeys · SCIM (provisioning) · PKCE

## API & Data
REST / HTTP semantics (RFC 9110) · Problem Details (RFC 7807 — error shape) ·
Idempotency-Key pattern · OpenAPI · JSON Schema · AsyncAPI (event-driven) ·
CloudEvents · GraphQL · gRPC / Protocol Buffers · ACID · CAP theorem ·
ISO 8601 / RFC 3339 (เวลา) · IANA tz database · ISO 4217 (สกุลเงิน) ·
IEEE 754 (ทำไม float+เงินไม่ได้) · Unicode / BCP 47 / CLDR (i18n)

## Frontend & UX
WCAG 2.x (accessibility) · WAI-ARIA / ARIA APG (widget a11y + keyboard model) ·
Core Web Vitals (LCP/INP/CLS) · Material Design / Apple HIG ·
Nielsen's 10 Usability Heuristics · ISO 9241 · Design Tokens (W3C draft)

## Delivery & Git
Conventional Commits · SemVer · Trunk-Based Development vs GitFlow · Keep a Changelog
(สำหรับ release notes — ไม่ใช่ CLAUDE.md)

## Testing & Quality
Testing Pyramid / Testing Trophy · TDD · AAA pattern · Contract Testing (Pact) ·
Property-based testing (QuickCheck) · Mutation testing · Fuzzing

## Code Quality & Metrics
ISO/IEC 25010:2023 (product quality model — 9 characteristics) ·
Cyclomatic complexity (McCabe) · SonarQube quality gate / technical debt ·
Static analysis: SAST / linters · Code coverage (line/branch/MC-DC)

## Distributed Systems & Consistency
Consensus: Raft / Paxos · Two-Phase Commit (2PC) vs Saga (compensating tx) ·
Event Sourcing / CQRS · Outbox pattern (transactional messaging) · CRDT ·
Lamport / Vector clocks · Fencing tokens (lease) · Quorum (R+W>N) ·
Consistency models (linearizable / eventual / read-your-writes) ·
Delivery semantics: at-least-once / exactly-once / idempotent consumer ·
Consistent hashing

## Resilience & Fault Tolerance
Circuit Breaker · Bulkhead · Retry + exponential backoff + jitter · Timeout ·
Backpressure · Dead Letter Queue · Rate limiting (token bucket / leaky bucket) ·
Graceful degradation / Fallback · Chaos Engineering

## Caching
Cache-aside / Read-through / Write-through / Write-behind · TTL + eviction (LRU/LFU) ·
Cache stampede / thundering herd (dogpile) · CDN cache headers (Cache-Control/ETag)

## Data Formats & Serialization
Protobuf · Apache Avro · Apache Parquet / ORC (columnar) · MessagePack ·
CSV (RFC 4180) · Schema Registry / schema evolution (backward/forward compat)

## Release & Deployment
Blue-Green · Canary · Rolling update · Feature Flags / toggles ·
Expand-Contract (parallel change) · Progressive delivery

## Performance & Algorithms
Big-O (complexity) · Amdahl's Law · Little's Law · percentile latency (p95/p99, tail) ·
Load / stress / soak testing (k6 / JMeter / Gatling)

## Operations
Google SRE (SLI/SLO, error budget, runbook, blameless postmortem) ·
Three Pillars of Observability + OpenTelemetry · Four Golden Signals / RED / USE (จะวัดอะไร) ·
DORA metrics · 3-2-1 Backup rule

## Product & Process
Agile / Scrum / Kanban · Lean Startup (MVP) · Shape Up (appetite, เหมาะ solo) ·
RICE / MoSCoW · User Story Mapping / Jobs-to-be-Done · ADR (Architecture Decision Records)

## Documentation
Diátaxis (tutorial/how-to/reference/explanation) · arc42 / C4 Model (architecture diagrams) ·
Mermaid / PlantUML (diagram-as-code)

## Web / Content / SEO
Schema.org / JSON-LD · E-E-A-T · robots.txt / sitemap / canonical / hreflang ·
OpenGraph / Twitter Cards · RSS/Atom · llms.txt (AEO/agentic, เกิดใหม่)

## Email & Messaging
SPF / DKIM / DMARC (deliverability) · ICS (RFC 5545, calendar)

## Infra & Cloud
OCI container standard · Dockerfile best practices (multi-stage, non-root) ·
IaC (Terraform/Ansible) · GitOps · K8s patterns (probes, limits, PDB) ·
SLSA / SBOM (supply chain) · CVE / CVSS

## Networking / Protocol
HTTP/2 · HTTP/3 (QUIC) · TLS 1.3 · WebSocket (RFC 6455)

## Payment
PCI DSS 4.0 · EMV / 3-D Secure · ISO 20022 · ISO 8583

## Legal & Compliance
Software licenses (MIT/Apache-2.0/GPL/**AGPL trap ใน dependency**) ·
PDPA (ไทย) / GDPR (consent, retention, right to erasure) · SOC 2 (Trust Services Criteria) ·
Cookie consent · ภาษี e-Service / VAT ไทย · HIPAA (US health data) ·
a11y legal: Section 508 / ADA (US) / EN 301 549 (EU) · FedRAMP (US gov cloud)

## AI / LLM
MCP (Model Context Protocol) · EU AI Act (เฝ้าดู)
