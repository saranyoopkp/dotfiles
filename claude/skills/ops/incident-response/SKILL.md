---
name: ops:incident-response
description: Triage and manage incidents or production degradation systematically. Use for outages, latency, anomalies, data or security concerns, material alerts, or user impact. Gather evidence, assess blast radius, propose mitigation, and verify recovery without independently authorizing external mutation.
---

# Incident Response

Prioritize reducing user or data harm, understanding blast radius, restoring service under control, and preserving
evidence for prevention. Do not declare root cause from symptoms alone.

1. Open a concise incident record with detection time, service and environment, symptoms, reporter or alert, and verified impact; separate facts, inference, and unknowns.
2. Triage read-only first: health, recent deployment or configuration, errors and latency, dependency state, logs or traces, and affected user paths. Preserve timestamps and correlation IDs before data expires.
3. Identify affected users and data, whether impact continues, security/financial/integrity risk, and actions that could worsen it.
4. Propose reversible mitigations in order, with side effects, preconditions, and verification. Restart, rollback, traffic shift, feature disablement, secret or permission changes, and data repair require owner authorization.
5. After selection, perform only authorized actions and verify real signals plus critical user paths. A cleared alert alone is insufficient when dependencies or flows remain broken.
6. Before closure, record recovery state, residual risk, owners, follow-up, evidence, and unknowns. A postmortem separates trigger, contributing factors, detection gaps, and corrective actions without blaming individuals.

Escalate active data, security, or financial incidents under organizational policy before deep analysis or changes
that could destroy evidence.
