---
name: docs:stale
description: Check whether documentation content in CLAUDE.md, docs, memory, or docstrings still matches live code. Claims that contradict live code are stale and must be corrected; live code has priority by default. Use when documentation may be outdated, after major refactors or behavior changes, before onboarding or handoff, or when asked to audit docs for staleness or drift. This differs from /docs:link, which checks that references resolve rather than whether their content remains true.
---

# Documentation Staleness Check — Describe Live Reality

**Decision rule: code that is actually live or deployed is the source of truth.** When documentation contradicts that code, the documentation is wrong by default. The sole exception is evidence that the code is defective while the documentation records the intended behavior, such as tests or history confirming the intent. In that case, open a **code defect** instead of rewriting the documentation to match.

## Priority by impact

1. **Documentation for live production code** — trusting stale information can cause real deployment or operational harm.
2. Operational documentation read every session, including CLAUDE.md, memory policy, and deployment steps.
3. Deep documentation for active modules.
4. **Skip** explicitly dated point-in-time snapshots, which are drift-exempt by policy, and archived material.

## Method

This requires LLM judgment rather than one all-purpose script, but every judgment must use evidence. For each documentation file:

1. **Extract verifiable claims.** Find statements about system reality: run or deployment commands, file roles, config or schema shapes, “X does Y,” procedures, counts, and enumerations. Counts and enumerations should usually be commands under the no-hardcoded-facts rule; treat hardcoded instances as immediate findings.
2. **Verify each claim against reality** in evidence order: run the documented read-only command, inspect actual code or configuration, then search. Never decide from memory.
3. **Classify the result:**
   - Matches → pass.
   - **Stale** → correct the documentation in the same pass; do not merely record that it should be fixed.
   - **Code differs from documented intent** with evidence of intent → open a scoped `TODO` or tell the user. Never silently change code in the name of documentation repair.
   - **Undetermined or ambiguous whether code or documentation is correct** → defer that item and finish everything else first. Ask the repository owner only once at the end, grouping concise questions with evidence from both sides: “Documentation says X (path:line); code does Y (path:line). Which is intended?” Do not guess intent or drip questions during the audit. Until answered, classify it as not verified, never passed.
4. Docstrings are in scope. A contract that contradicts actual behavior is a documentation defect and must be fixed in the same task, following the same placement rules.
5. Finish with counts for matching, corrected, code work opened, and unverified claims; commit documentation corrections and cite evidence for each claim using paths and lines or command output.

## Scope discipline

Use the same remediation scope as `/docs:placement`: handle what the user requested and documentation for modules touched by the task. A repository-wide sweep requires an explicit request. Record and suggest stale content found outside scope instead of expanding silently.

## Relationship to other tools

- `/docs:link` checks whether references resolve. Run it first; documentation pointing to missing files is often stale in content too.
- The docs-drift hook warns at moments when documentation and implementation may separate, where staleness begins.
- `/docs:stale` performs the deepest and most expensive content review. Use it for deliberate audits, not every commit.
