---
name: docs
description: "Route documentation-system work: repository setup, cross-repo ownership, knowledge placement, broken links, or stale-content audits. Use when documentation is the task and the relevant child is unclear; invoke a specific docs:* child directly when clear."
---

# Docs — Documentation Family

Select a child by task:

| Child | Use when |
|---|---|
| **/docs:setup** | Install, adopt, or reapply the kit, or refactor CLAUDE.md, docs, linked memory, and hooks into one system |
| **/docs:workspace** | Organize documentation for a workspace containing independent Git repositories: fact ownership, inventory/pointers, cross-repo conventions/contracts/rollouts/handoffs, and standalone-clone boundaries |
| **/docs:placement** | Decide where knowledge belongs, enforce comment/docstring discipline, or organize the topology, subfolders, and index of an existing docs tree |
| **/docs:link** | Check broken references (md↔md, md→code, code→docs) with a deterministic script |
| **/docs:stale** | Check whether documentation content contradicts live code. Live code wins by default; LLM judgment must be evidence-based |

When one task spans several concerns, invoke only the children those concerns require. The order setup → workspace → placement → link → stale describes possible dependencies, not a mandatory checklist for every task.
