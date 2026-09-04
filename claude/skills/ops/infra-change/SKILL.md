---
name: ops:infra-change
description: Plan, inspect, and perform infrastructure changes involving IaC, cloud resources, networks, IAM, secret references, provisioning, state, or drift. Use for Terraform, Pulumi, CloudFormation, Kubernetes, or real environment resource, permission, and configuration changes.
---

# Infrastructure Change

Distinguish `inspect`, `plan`, and `apply`. Inspection and planning may gather in-scope evidence; provider or
state mutation always requires explicit authorization.

1. Identify environment, account/project/cluster/region, source of truth, and affected resources. Never infer them from filenames or default CLI context.
2. Inspect state, configuration, consumers, permissions, network paths, stored data, dependencies, and real rollback or mitigation before change.
3. Produce a reviewable plan summarizing create/change/destroy, blast radius, preconditions, downtime or compatibility risk, and irreversible effects. A clean plan is not proof of safety.
4. Keep secrets in references, secret managers, or appropriate environment variables. Never print or copy them into tracked state, logs, documentation, or plan output.
5. Before apply, present target, plan, risk, and rollback or mitigation and obtain authorization. Do not silently repair unrelated drift.
6. After apply, verify consumer-visible use rather than only exit zero: permissions, connectivity, service health, and relevant monitoring.
7. Record sources of truth, intentional exceptions, and required runbooks; place sensitive detail in policy-approved private paths.

For rolling changes, verify coexistence, dependency order, and rollback without assuming data or state reversibility.
Missing preconditions fail loudly. When platform behavior informs the plan, verify version-specific primary
documentation separately from evidence of impact in this environment.
