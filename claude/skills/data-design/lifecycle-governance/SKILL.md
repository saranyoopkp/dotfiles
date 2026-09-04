---
name: data-design:lifecycle-governance
description: Design data lifecycle and governance, including retention, archival, soft or hard deletion, anonymization, audit/history, PII classification, and erasure. Use when data expires, must be deleted or retained, requires traceability, or is sensitive.
---

# Data Lifecycle & Governance

- Before collecting data, define purpose, source of truth, classification, owner, retention or expiry, and expiry behavior. Ask the owner when business or legal requirements are unclear instead of inventing a period.
- Distinguish soft deletion, hard deletion, archival, and anonymization by real semantics. Soft deletion is not privacy erasure; hard deletion may destroy referential or audit needs; archives must remain searchable or restorable only as promised.
- Deletion covers authoritative stores, derived data, search indexes, caches, attachments, and controlled downstream copies. State asynchronous completion and justified retention exceptions.
- Audit history must answer who acted on which target, when, and with what result without retaining unnecessary secrets or PII. It is neither a source of truth nor justification for indefinite collection.
- Separate PII access and retention from ordinary data, minimize copies, and verify tenant scope across read, export, and delete paths. Authorization belongs to `risk-review`.

Backup, restore, telemetry retention, and privileged-action risk retain their risk owners. This skill owns
consumer-visible lifecycle semantics. Verify create → retain → access → delete or expire and any real recovery
or audit path. Report incomplete downstream erasure or archival as a gap.
