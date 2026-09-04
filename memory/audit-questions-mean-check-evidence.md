---
name: audit-questions-mean-check-evidence
description: Brief user audit questions such as “is that accurate, inferred, or decided by whom?” signal a need to inspect raw evidence rather than explain more.
metadata:
  node_type: memory
  type: feedback
---

This user audits with brief questions such as “Is that accurate?”, “Did you inspect the insight or infer it?”, “Who decided this is expensive?”, and “Does it still not exist?” In every observed case on 2026-07-17, the question exposed a real measurement or claim defect.

**Why:** Answering with more theory is the wrong move. The user expects inspection of actual evidence—raw cases, repository search, or a new measurement—and an explicit withdrawal when an earlier claim exceeded the evidence.

**How to apply:** On an audit-style question, make the first move a tool call for primary evidence rather than an explanatory paragraph. Retract unsupported claims before proposing anything new. See [[deliverable-form-data-first]].
