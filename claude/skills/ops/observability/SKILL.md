---
name: ops:observability
description: Design or improve production observability through health checks, heartbeats, structured logs, metrics, traces, alerts, dashboards, and SLI/SLOs. Use for new services, jobs, queues, webhooks, integrations, blind spots, alerts, or proof that failures can be detected and diagnosed.
---

# Observability

Begin with user or service outcomes and failure modes, not existing dashboards or metrics.

1. Identify the critical path, owner, and operational questions: is it usable, who is affected, where is failure, and did recovery improve it?
2. Distinguish no work from a dead processor with dependency-aware health, heartbeat or lease, or last-success timestamps for jobs, queues, and webhooks. Silence alone is not health.
3. Give logs, metrics, and traces separate roles: structured events and correlation, rates/errors/latency/saturation, and cross-dependency paths. Correlate without logging secrets or PII.
4. Alerts must be actionable, with owner, severity, impact-related threshold and window, runbook or next check, and deduplication. A dashboard is not an alert.
5. Measure important success and failure paths, including dependency failure, retries, backlog, timeout, and silent failure. Averages must not hide tail latency or partial outage.
6. Test signals with safe failure injection or controlled evidence: alerts fire, context supports triage, and recovery normalizes signals. Record untested behavior as a gap.

Before adding telemetry, evaluate cost, cardinality, retention, and data classification. High-cardinality or sensitive
labels can make observability itself an incident.
