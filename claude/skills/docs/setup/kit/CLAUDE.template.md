<!-- REQUIRED STANDARD: CLAUDE.md must not hardcode facts that can be counted or listed.
     For file, line, table, or migration counts; generated file lists; or schema/DTO shapes,
     point to a command (`ls`, `wc -l`, `grep -c`) or owning source instead. Copied facts
     become stale while CLAUDE.md keeps presenting them as truth. If a number is essential,
     include the command that derives it. -->

# <ProjectName> (<domain/one-line purpose>)

> Status: **<LIVE / WIP / phase>** — <deployment target or concise current state>
> <genuine point-in-time status such as image tag or phase, not a derivable count>
> **<recent quirk or fix needed before work, including date, reason, remedy, and verification>**

## Inventory / Modules
<!-- Current state per module in one to three lines. Promote longer detail to docs/<module>.md and leave a pointer. -->
- **<module>** — <summary, primary files, and concise quirk>

## Deploy / Redeploy
<!-- Copy-pasteable commands in order, plus conditions such as “when X changes, run only Y.” -->
1. `<command>`
2. `<command>`

<!-- The next items describe stable system properties, not one release. Do not record the
     current migration or ticket here; commits and pull requests own that history. Remove this
     entire section for repositories that are not deployed, such as libraries and local CLIs. -->
- **Pipeline does not automate:** <manual work required when new items appear, or “pipeline is complete; no manual step”>
- **Rollback:** <how to restore the prior tag/image and what state cannot be reversed>
- **Post-deployment verification:** <one real flow that must pass; a green rollout alone is insufficient>

### Compatibility: N / N-1 coexistence

Keep this checklist in every deployed repository. Add system-specific checks below it.

**New components must work with old components, and old components must remain safe around new ones.** Backward and forward compatibility make deployment order and rollback non-critical. “Old and new” includes anything changed at different times: code and schema, a new server and stale browser tab or mobile app, and a new producer with queued old messages and not-yet-upgraded consumers.

- **Deletion, rename, semantic changes, and new required fields use two releases:** expand, then contract. First add the new form, write both forms, and read the new one. Remove the old form only after no consumers remain. Pure additions may ship once.
- Ask whether new code depends on an uncreated migration, grant, environment variable, file, table, or event type. An unmet dependency means the release is not deployable.
- Rollback should require reverting code only. If state must also be reversed, redesign the change.
- Missing preconditions fail loudly rather than skipping silently; silent production corruption is worse than a stopped deployment.
- Test real use of newly created resources. Successful creation does not prove usability; for example, write through a new role rather than merely checking that it exists.
- Feature flags, dual reads, and dual writes need an owner, default, telemetry, rollback conditions, and removal criteria. They do not replace state or contract compatibility.

## Research escalation

- Before explaining or working around platform, framework, runtime, browser, OS, protocol, or third-party behavior, distinguish repository-specific behavior from an external constraint.
- Inspect code, configuration, runtime, integration, and version first. When a conclusion depends on external behavior, conflicts with an expected standard, or motivates a material workaround, consult official documentation, specifications, or release notes for the relevant version and context.
- External sources establish general constraints; repository evidence separately proves their local impact.
- When evidence is unavailable or conflicting, state what remains unverified and the alternatives. Never invent a constraint to finish the task.
- Decision-relevant research defines its question, context/version/segment, source hierarchy, freshness, appetite, and stopping criteria. When the limit is reached without enough evidence, report the unknown and next probe.
- Map advisories and CVEs to exact components, versions, configuration, and reachability. Evaluate dependencies and vendors for maintenance, security, licensing, compatibility, total cost, lock-in, and exit. User and market claims require provenance, segment, and methodology; personas, anecdotes, and model opinion are not user evidence.
- Research and recommendations do not authorize behavior changes, dependencies, vendor selection, upgrades, user contact, or new data collection.

## Complexity proposals

- Before adding abstraction, dependencies, infrastructure, or operational burden, find the driver in repository, runtime, or source evidence. If a minimal approach satisfies outcome, correctness, safety, and compatibility, propose it with a trigger for deferred complexity. Ask only when uncertainty changes behavior, risk, cost, or reversibility; otherwise choose the smallest safe option and state the assumption. Do not remove evidence-backed safety or compatibility controls merely to look simpler.

## Local development
<!-- Development commands and painful machine or toolchain quirks, including symptom and remedy. -->

## Structure & Run
<!-- Workspace structure, schema/config sources of truth, and primary commands. -->

## Conventions
<!-- Language, naming, and established rules. Optional product voice/tone may define audience,
     three to five personality words, formality, and preferred or avoided terms. Move growing
     detail to docs/content-voice-tone.md and leave a pointer. -->

## Mission / Boundary
<!-- What the project does, does not do, and why, preventing scope creep and repeated debate. -->

## Architecture Decisions
<!-- Every decision includes rationale and rejected alternatives. Format:
     **<concise topic> (YYYY-MM-DD):** Choose X because Y, not Z because W.
     This records current state, not a changelog. Update superseded entries in place and mark
     “superseded by <new decision, date>.” Promote decisions longer than roughly 15 lines to
     docs/decisions/<topic>.md and retain a summary and link. -->

## Constraints
<!-- Budget, infrastructure, and time constraints that determine feasible options. -->

## Known pitfalls
<!-- Established strategic or technical traps. -->

## Future boundaries
<!-- Undecided possibilities recorded so today's design does not unnecessarily block them. -->

## Execution tracking
<!-- When task tools exist, create a task list before mutation for multi-step or multi-turn work,
     verification or handoff, and blockers or decisions. Update it from evidence as in progress,
     blocked, or completed. Questions, read-only inspection, and one-point edits do not need
     ceremonial checklists. Without task tools, summarize plans and status concisely; never claim
     tracking through unavailable tools. -->

## Report integrity
<!-- Classify important claims as Verified, Inferred, Assumption, Unverified, or Contradicted before
     reporting results, findings, or handoffs. Verified claims require current primary evidence
     inspected directly by the reporter, with target, probe/result, and coverage. Command or test
     claims include the method and exit status when available. Never present stale output, hearsay,
     or sample inspection as current proof of the whole set. -->

## Durable findings
<!-- Existing reports, summaries, transcripts, and findings are leads rather than facts. Before
     recording a finding in debt, audits, TODOs, decisions, runbooks, postmortems, or durable docs,
     directly verify every atomic claim against current primary evidence. Partial verification does
     not validate the set. Record status, provenance, checked date, and revision/worktree when state
     may differ. Recheck potentially stale portions before using a finding after state changes. -->

## Next TODOs
- [ ] <next actionable task>

## Documentation index
<!-- Make every layer discoverable from this file and synchronize the index with additions, moves,
     and deletions in the same commit. Name files by domain rather than date. When docs/ grows beyond
     roughly seven flat files, organize by domain and group the index accordingly. -->
- `docs/<topic>.md` — <what it contains and why to open it>
- `memory/MEMORY.md` — index of concise shared facts

## CLAUDE.md / docs / memory placement boundary

The boundary is **how content is read**, not its topic:

| Layer | Reading mechanism | Unit | Write when this is true |
|---|---|---|---|
| `CLAUDE.md` | **Push:** loaded fully every session, so every line is a recurring cost | Overview and operational rules | “Missing this in any session would cause incorrect work” |
| `docs/<topic>.md` | **Pull:** opened when someone deliberately works on the topic | One topic per file, any justified length | “Someone starting this topic will know to open it” |
| `memory/MEMORY.md` | **Recall router:** auto-loaded every session | Pointer and hook for each shared fact | “A future session must know this fact exists” |
| `memory/<fact>.md` | **Selective pull:** the harness does not open pointer targets automatically | One concise fact per file | “Once the index or task points here, the detail should open” |

- Creating, moving, renaming, or deleting a shared memory leaf requires updating its pointer and recall hook in `memory/MEMORY.md` in the same commit. For edits, update the hook only when meaning or relevance changes. Keep the index free of copied leaf content.
- One subject may use different homes for different reading purposes: full history and rationale in docs, proactively recalled quirks or preferences in memory, and only a one-to-three-line summary with pointers in CLAUDE.md.
- Do not record numbers or data reproducible from scripts or commands; point to the source.
- In monorepos and submodules, module documentation stays with the module. The root retains concise pointers, while only cross-cutting deployment and inter-module contracts remain at root.

The closest-to-code layers follow the same table:

- **Inline comments** are read while editing a line. Keep only local why or constraints that code, types, tests, and good names cannot express. If code explains it, do not write a comment. Move broader rationale, history, experiments, and procedures to docs with a pointer when that improves discovery and maintenance; line count alone is not the criterion. Committed pointers must resolve from a clone and cannot target machine-specific paths. Remove commented-out code and code narration. When editing code near a comment pointer, open its target first.
- **Docstrings** are read before calling or changing a function or module. They state interface contracts—purpose, inputs/outputs, invariants, and side effects—using language conventions such as PEP 257 or JSDoc. Public interfaces require them. Read existing docstrings before inferring from names; a contract contradicting behavior is a documentation defect to fix in the same task. Tutorials, postmortems, and changelog essays belong in docs even when preceded by a correct contract.
- **Codetags** such as `TODO(scope):` mark unfinished work under PEP 350; they do not explain code. Unlike durable comments and docstrings, a codetag must disappear in the same commit that completes the work. Persistent feature debt belongs in CLAUDE.md TODOs rather than one code file.

These choices align with established principles: Clean Code and Ousterhout for comments as why, PEP 257 and JSDoc for contracts, ADRs for decisions, and Diátaxis plus SSOT for documentation organized by reading purpose.

## Memory policy

**The active tree's `memory/` is the real copy.** The harness directory `~/.claude/projects/<project-id>/memory` links here through a Windows junction or Unix symlink. Read and write memory normally; files enter the repository directly. `docs-drift.sh` inspects the link without mutation, while `/docs:setup` owns merging, creation, and repair. In a Git worktree, the link must target that worktree's own `memory/`, not the primary tree, so facts remain with the branch that created them.

- New memory is an untracked repository file. Review and commit it with related work, removing personal metadata such as `originSessionId` and checking for secrets.
- Never commit private or sensitive content. Use Git-root-relative `docs/private/` for operational secrets, IPs, or server paths and `memory/private/` for personal or machine-specific facts. Both are ignored and must not be indexed in committed `memory/MEMORY.md`. Search private memory when the task may depend on machine-specific information before concluding it is absent.
- A `[docs] Harness memory ...` message means the link is missing, broken, or misdirected. Do not detour into repair outside scope; report it and use `/docs:setup` after authorization.
  - Never delete an existing real directory containing facts. Merge missing files into repository `memory/`, rename the original directory to `.bak`, then create the link.
  - Unix: `ln -s <tree>/memory ~/.claude/projects/<id>/memory`
  - Windows: `New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\projects\<id>\memory" -Target "<tree>\memory"`
  - `<id>` is the active tree's absolute path, including a worktree path, with non-alphanumeric characters replaced by `-`.
- Delete expired or false facts and their `memory/MEMORY.md` entries.

### Task-close checklist

Apply this after each completed unit of work rather than waiting for session end:

1. Confirm CLAUDE.md and docs still describe reality. Update immediately when needed. A new feature typically adds one to three inventory lines covering existence, entry point, and quirks plus a reasoned decision when applicable. Record only why, constraints, and traps that code cannot explain; do not narrate implementation.
2. Review potential new memory, remove personal metadata, and check for secrets. Synchronize `memory/MEMORY.md` whenever a shared leaf changes lifecycle, and verify its pointer and hook.
3. At a cohesive verified checkpoint for authorized mutation, create a local commit by default. Commit related documentation with the work, stage only in-scope paths or hunks, preserve pre-existing dirty work, and never push unless requested. Remove codetags completed by the work.
4. Promote any CLAUDE.md section exceeding roughly 15 lines into `docs/<topic>.md`, or a concise `memory/<fact>.md` when appropriate, leaving a one-to-three-line summary and link. Do not let an always-loaded file become a content dump.

Lifecycle hooks in `.claude/settings.json` verify baseline and links, the shared-memory index, and continuity. They do not enforce documentation placement or commits for ordinary source edits.
