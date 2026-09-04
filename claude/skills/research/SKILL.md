---
name: research
description: Router for research that informs software, security, dependency, technology/vendor, product, market, or user decisions. Use when an answer requires current external evidence, dependency or runtime versions must be checked against advisories or CVEs, alternatives or build-vs-buy need comparison, user or market evidence needs evaluation, or scope, appetite, stopping criteria, and source disagreement must be controlled. Define the research question and read matching children before concluding.
---

# Research

Begin with the decision research must support, not link collection. Use `research:research-control` when
research affects a decision, spans sources, or carries uncertainty, then add matching domain children.

| Work | Skill |
|---|---|
| CVE, advisory, affected version, exploit precondition, or remediation | `research:security-advisories` |
| Dependency, technology, vendor, build-vs-buy, pricing, support, license, or lock-in | `research:technology-vendor` |
| Product opportunity, market or competitor, user need, interviews, surveys, or usage evidence | `research:product-market-user` |
| Research question, source plan, appetite, stopping criteria, or conflicting evidence | `research:research-control` |

One decision may require several children, but do not merge their workflows into a universal checklist.

## Shared contract

- Inspect task, repository, decision, and runtime first to establish context and version. An external source does
  not prove repository impact until mapped to code, configuration, runtime, or user context.
- Use current sources closest to each claim. Separate official fact, independent evidence, inference, and unknown,
  with source and checked date.
- Research informs decisions but does not authorize vendor selection, behavioral change, dependencies, upgrades,
  purchases, or user-data collection.
- Follow `claude/rules/core/evidence-integrity.md`: report material claims, evidence, applicability, limitations,
  and unknowns. Link count and confidence do not replace evidence quality.
