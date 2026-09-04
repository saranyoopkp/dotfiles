# Documentation Setup — A System for Every Repository

> Intended for projects developed with Claude Code, including solo and long-running work.
> The user-level `/docs:setup` skill points to this kit and can install or refactor the system from any repository.

## Principles

Safety invariants live in `claude/rules/engineering/documentation-discipline.md`; procedures live in `docs:setup` and `docs:placement`. This README explains kit mechanics: structure, initialization, hooks, and memory links. Artifacts copied into another repository must remain usable without these dotfiles paths.

**Invariant: every copied artifact is self-contained.** This includes CLAUDE.md generated from `CLAUDE.template.md`, `memory/*`, `.claude/hooks/docs-drift.sh`, and `.claude/settings.json`. They must not point to kit paths, init scripts, or `claude/rules/*`, which may not exist for another machine or user. Include required questions or commands directly. This README and `init.sh` are not copied and may reference kit internals.

System-specific mechanics:

- Private directories do not synchronize because Git ignores them. Never index private files in committed `memory/MEMORY.md`.
- Creating, moving, renaming, or deleting shared memory requires updating its pointer and recall hook in `MEMORY.md` in the same commit. Edit hooks when leaf meaning or relevance changes.
- Before committing memory, remove personal metadata such as `originSessionId` from frontmatter.

## What to record after a feature

Drift risk increases with how quickly a fact changes. Record slow-changing knowledge that code cannot explain:

| Kind | Example | Drift | Record? |
|---|---|---|---|
| Existence and entry point | “Feature X begins in `src/foo/`; endpoint `/api/x`” | Low | Yes, one to three inventory lines |
| Rationale, constraints, and quirks | “Choose A rather than B because...”; “missing flag Y fails” | Near zero | Yes, highest value |
| Internal implementation | Step-by-step behavior or parameter shape | Very high | No; let code, types, and tests explain it |

Ask one question before every line: **Can the code explain this itself?** If yes, do not duplicate it. Typical feature cost should remain one or two minutes: a concise inventory update, a decision when one was made, and a quirk when discovered.

## Structure

```text
CLAUDE.md          # Starts from CLAUDE.template.md
docs/              # One topic per file; created as CLAUDE.md sections grow
docs/private/      # Sensitive operational notes, ignored by Git
memory/            # Starts from this kit's memory directory
memory/private/    # Personal or machine-specific facts, ignored by Git
  README.md
  MEMORY.md        # One-line index entry per file
  <fact>.md        # Follows _fact.template.md
```

Private directories are relative to each Git root. A monorepo has one root; in a workspace with independent Git roots, each repository owns its private directories.

The harness directory `~/.claude/projects/<id>/memory` is a junction or symlink to repository `memory/`. Harness recall and auto-loading operate on the same files, so no synchronization step exists.

## Organizing docs

The Documentation Index section in `CLAUDE.template.md` is self-contained: use domain-based filenames, introduce subfolders when a flat directory grows beyond roughly seven files, and keep its index synchronized. Organize when adding the eighth file rather than waiting for a large pile. Like `memory/MEMORY.md`, use one line per file containing a name and a hook explaining when to open it.

## Adopting the kit

```bash
bash <path-to-kit>/init.sh /path/to/repo   # Use Git Bash on Windows
```

The script creates CLAUDE.md from the template, copies initial memory, creates public and private documentation directories, and links harness memory to repository memory. On Windows it uses a junction; on Unix, a symlink. Existing harness memory is merged into the repository and backed up as `.bak-*`. Then fill CLAUDE.md placeholders and add initial mission, stack-decision, and quirk facts.

New harness memory appears as untracked repository files, so review and commit it periodically. After moving the repository to another machine, rerun the idempotent init script. Keep the template's “Memory policy” section so later sessions can detect and route link repair through `/docs:setup`.

## Lifecycle hooks

Init installs `.claude/hooks/docs-drift.sh` and `.claude/settings.json` as tracked, cross-platform files.

| Event | Responsibility |
|---|---|
| `SessionStart` | Store a baseline by `session_id`, classify already-dirty paths as user or previous-session work, inspect the memory link without changing it, and register watch paths; `/docs:setup` owns merging and repair |
| `PostToolUse(Edit\|Write)` | Report long changed-line comment blocks in session-owned files as audit candidates with locations; never treat comments as authority, decide placement, or block work |
| `TaskCompleted` | After session-owned mutation, briefly suggest acceptance evidence or gaps, independent acceptance under the active workflow, and a scoped local commit; never infer ACV from paths and never block |
| `Stop` | Block only shared-memory lifecycle inconsistencies created by this session; ordinary source and documentation edits add no ceremony |
| `PreCompact` | Carry objective, deferred scope, authorization, and verification gaps into the summary; compaction alone creates no repository work |

`FileChanged` wiring was removed on 2026-07-12 after real harness testing showed the documented event never fired. The harness's own external-modification reminder covers the intended behavior, so no effective gap remains.

Temporary baseline state is separated by repository and `session_id`. Paths dirty before SessionStart are report-only and hooks never edit, stage, or commit them. A clean-at-start path that later becomes dirty is session-owned; edits to already-dirty paths remain advisory because provenance is ambiguous.

`Stop` uses one `decision:block` so Claude can receive feedback, observe `stop_hook_active=true`, and exit immediately on continuation; state deduplicates repeats. `PostToolUse` and `TaskCompleted` are advisory and session-deduplicated. `Stop` checks only deterministically provable shared-memory index invariants.

## Inline work notes

Codetags follow PEP 350, using scopes or domains rather than personal assignees:

- Fixed greppable forms: `TODO(scope): message`, `FIXME(scope): message`, and `HACK(scope): reason`. Never leave context-free TODOs.
- Codetags differ from comments and docstrings by **lifetime**. Remove one in the same commit that completes its work. A tag older than roughly two weeks suggests feature-level debt that belongs in CLAUDE.md TODOs or future boundaries.
- Status tables are command output, not handwritten files. Record a scan command such as `grep -rn "TODO(\|FIXME(\|HACK(" src/` in CLAUDE.md instead of maintaining `docs/status.md`.
- Code notes represent line- or function-level debt; CLAUDE.md TODOs and future boundaries represent feature-level debt.
- Answer “what exists and what remains?” from inventory, codetag search results, and future boundaries together.

## Reapply or upgrade

Run `/docs:setup` again at any time. Init updates hook scripts and repairs links but preserves repository-owned CLAUDE.md and settings. The skill deliberately merges new content conventions while retaining repository customization; follow its “Reapply or upgrade” procedure.

## Refactoring a changelog-style repository

1. Separate durable knowledge such as configuration, formulas, quirks, and decisions from debugging history and temporary measurements already preserved by Git.
2. Move substantial durable knowledge to `docs/<topic>.md` and concise facts to `memory/<fact>.md`.
3. Reduce CLAUDE.md status to one concise line per module with links to promoted material.
4. Add synchronized docs and memory indexes so all layers are discoverable from CLAUDE.md.
