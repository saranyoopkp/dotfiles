---
name: docs:workspace
description: Organize, place, or audit documentation for a workspace containing multiple independent Git repositories. Establish authoritative fact owners, query routing, inventories and pointers; resolve conflicting repository or environment/runtime claims; organize shared conventions, cross-repo contracts, rollouts, and handoffs; and preserve standalone-clone usability. Use for folders containing several repositories, root/app/infra documentation drift, cross-repo references, workspace-level CLAUDE.md/docs placement, or moving knowledge between a workspace root and sub-repositories. Do not use for a monorepo with one Git root.
---

# Documentation Workspace — Multiple Repositories without Duplicate Owners

Each fact has one owner: a repository owns truths it can change and verify itself; the workspace owns only truths that require visibility across repositories.

## Scope gate

1. Find actual Git roots first:
   ```bash
   find <workspace> -name .git -prune -print
   ```
   Support both `.git` directories and files used by worktrees or submodules. Adapt depth and exclusions to the actual tree, and do not conclude the inventory from one query when paths were pruned or inaccessible.
2. One Git root with packages beneath it is a **monorepo**. Use `/docs:setup` and `/docs:placement`; do not add a workspace layer.
3. Several independent Git roots use this skill, whether or not the workspace root has no Git repository or a small repository that tracks top-level documentation.
4. Establish active, in-scope repositories from evidence. A directory alone does not prove activity, and absence from the current inventory does not authorize moving or deleting its documentation.

## Owner test

Ask in order:

1. Can one repository fully change and verify this fact? If yes, it belongs there. If correctness requires coordination across at least two independent repositories, it belongs to the workspace.
2. Does a standalone clone remain understandable and usable without sibling checkouts? If not, move the cross-repo portion to the workspace and retain only that repository's local interface or constraint.
3. Is the content a source of truth or a snapshot? Living truth belongs to its owner. An audit, report, or measurement belongs in a dated point-in-time artifact with scope, command/source, and Verified, Unverified, or Contradicted status.

A repository may name external systems that form part of its interface, but its documentation must not depend on workspace-relative paths, branch or commit state, implementation details, or internal decisions of sibling repositories.

## Authority and query routing

Fact ownership also determines where to look before answering or changing a fact:

| Question or claim | Inspect first |
|---|---|
| Implementation, features, or build/release contracts | The repository owning the code or contract |
| Current deployment, environment, host, database, backup, or runtime health | The infrastructure or operations owner, then a live source when freshness matters |
| Rollout, dependency, or decision whose correctness spans repositories | The workspace contract, plan, or handoff, then pointers to relevant owners |
| Which repositories or documents exist | The workspace inventory first, then owner sources for content verification |

- The current directory, root CLAUDE.md, and open repository docs provide routing context, not automatic authority. Do not use local absence or a stale assertion to reject state held by a sibling or live owner.
- Environment- or runtime-dependent facts must not be mirrored as living claims in roots or siblings that cannot verify them. Keep a pointer and retrieval method; snapshots require explicit date and scope.
- When user information conflicts with nearby documentation, treat it as a contradiction signal. Check the authoritative owner and current state before correcting the user, and report stale documentation separately from the primary answer.

## Documentation homes

| Home | Owns | Must not own |
|---|---|---|
| Workspace `CLAUDE.md` | Workspace boundary, concise pointer inventory, and cross-repo risks, decisions, or TODOs needed every session | Full per-repository stack/status/decisions, or derived counts and lists without reproduction commands |
| Workspace `docs/conventions/` | Vocabulary or delivery conventions genuinely shared across repositories | Single-repository conventions or speculative future standards |
| Workspace `docs/contracts/` | Contracts whose correctness spans repositories and has no single repository owner | APIs or schemas fully owned by a provider repository |
| Workspace `docs/plans/` | Rollouts, migrations, compatibility, and rollback sequencing across repositories | Internal implementation plans for one repository |
| Workspace `docs/handoff/` | Temporary coordination: owners, pending decisions, evidence, and next actions | Transcripts, activity logs, or permanent facts that should be promoted to their true owner |
| Workspace `docs/audits/` | Point-in-time cross-repo findings with provenance | Undated living truth |
| Sub-repository `CLAUDE.md`, `docs/`, or `memory/` | That repository's mission, stack, interface, decisions, runbooks, quirks, and evidence | Sibling paths or internal sibling facts |

Create only directories with real content. Name living documents by domain; dates are appropriate for snapshots and audits.

## Workflow

### 1. Build an evidence-first inventory

- Read existing workspace CLAUDE.md, docs, README, and configuration.
- Map Git roots, remotes, worktree or submodule state, and entry files for each repository.
- Read CLAUDE.md and documentation indexes for in-scope repositories; never infer mission from directory names.
- Compare existing inventory with the real tree and classify entries as `active`, `archived`, or `unknown`. Ask the user only after repository and history evidence cannot resolve intent, grouping questions once.

### 2. Draft the owner map before mutation

Report `fact/topic | current home | evidence | proposed owner | reason | action` before moving or creating many documents. Explain any ownership change or standalone-clone contract change before mutation; a finding is not authorization.

### 3. Make the root a router, not a mirror

- Keep each repository inventory entry to a pointer and one to three lines of context.
- Point local detail into the owning repository rather than copying it into the root.
- Cross-repo decisions record rationale, rejected alternatives, and date; move growing detail into workspace docs.
- Indexes must lead to important documents without hardcoding derivable facts unless they explain how to reproduce them.

### 4. Separate and move one fact at a time

- Move local facts leaked into the root back to the owning repository and leave a root pointer.
- Consolidate cross-repo facts duplicated across repositories into one workspace source, remove duplicate assertions, and preserve constraints needed by standalone clones.
- Promote completed handoff results to durable owner docs, close pending items, and remove logs or noise.
- Avoid big-bang rewrites. Use `git mv` within one repository when appropriate to preserve history.

### 5. Close the loop when an owned fact changes

- Update the owner's living document with the mutation that changes the fact.
- Search workspace and sibling documentation for duplicate assertions; remove them or convert them to pointers instead of synchronizing copies.
- If a conflicting repository is outside authorized scope, create or update a concise workspace handoff containing `owner | contradictory location | evidence | next action`. Findings do not expand authorization.
- Close the handoff once duplicate assertions are removed and owner/pointer paths resolve. Do not retain completed logs as another source of truth.

### 6. Validate real boundaries

Run the deterministic audit:

```bash
python "${CLAUDE_SKILL_DIR}/scripts/audit.py" <workspace>
```

Then:

- Run `/docs:link` separately in the workspace documentation repository and every changed sub-repository.
- Inspect from a standalone-clone perspective: links, commands, and instructions must not require sibling checkouts.
- Open the owner source for every durable finding. Agent and audit reports are leads, not proof.
- Test important queries from both the workspace root and sub-repositories. Routing must reach the authoritative owner and not answer current state from stale mirrors.
- Inspect `git diff` separately for every Git root and report changed repositories with their own validation.

The script detects Markdown link escapes, missing targets, and absolute user-home paths tied to one machine; portable `~` paths are allowed. It cannot determine semantic ownership or prove that mentioning another repository is wrong.

## Report

Summarize:

- Inspected Git roots and inventory limits.
- Owner-map changes with source and destination files.
- Cross-repo contracts, risks, and pending decisions.
- Per-repository validation commands and actual results.
- `Unverified` or `Contradicted` items and remaining questions.

Never combine working trees from several repositories into one status or report the workspace clean after checking only the root repository.
