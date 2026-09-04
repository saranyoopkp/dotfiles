---
name: ops
description: Router for operations, infrastructure, and production reliability. Use when planning or changing IaC, cloud, network, IAM, secrets, incidents, production outages, logs, metrics, traces, alerts, health checks, or SLI/SLOs. Select the matching child before analysis or mutation.
---

# Operations

Production-readiness, compatibility/rollout, and observability rules remain the safety floor. These skills add
task-specific workflows without lowering requirements or authorizing external mutation.

| Work surface | Required child |
|---|---|
| IaC, cloud resources, network, IAM, secrets, state, drift, or provisioning | `ops:infra-change` |
| Outage, incident, degradation, mitigation, or post-incident evidence | `ops:incident-response` |
| Health, logs, metrics, traces, alerts, dashboards, SLI/SLO, or silent failure | `ops:observability` |

Before any external mutation, identify environment, target, blast radius, rollback or mitigation, and explicit
authorization. Read-only evidence gathering may proceed, but a plan is not approval and an incident does not
authorize restart, rollback, or deployment.
