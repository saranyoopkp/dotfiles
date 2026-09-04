---
name: docs:setup
description: Set up, adopt, or re-apply the repo documentation system (CLAUDE.md + docs/ + linked repository memory + lifecycle hooks) using the docs-setup kit. Use for kit installation/upgrade or refactoring those surfaces as one system; not for reorganizing an established docs tree or index alone.
---

# Documentation Setup — Standard Repository Documentation System

The user applies one documentation system across repositories. The canonical kit is `${CLAUDE_SKILL_DIR}/kit/`.

Always read `kit/README.md` first. It is the source of truth for mechanisms, adoption, and refactoring. The always-loaded `documentation-discipline` rule owns principles; this file only routes the work.

## System summary

- `CLAUDE.md` describes **current state**, not a changelog. Every decision records its date and rationale.
- `docs/<topic>.md` holds deep topic material. Promote a CLAUDE.md section once it exceeds roughly 15 lines.
- In monorepos and submodules, module documentation lives with the module; the root retains a pointer and concise context. Submodules must carry their own documentation into every superproject.
- Choose every content home by how it is read: push, pull, or recall. The full table and decision questions are in the placement boundary section of `kit/CLAUDE.template.md`. Apply this criterion whenever setup or reapplication organizes or moves content; topic and length alone are insufficient.
- Repository `memory/` is the single version-controlled copy. The harness path `~/.claude/projects/<id>/memory` is a Windows junction or Unix symlink to it. The harness auto-loads `MEMORY.md`; leaf files open when an index or task points to them, with no manual synchronization.
- Creating, moving, renaming, or deleting a shared memory leaf requires synchronizing its pointer and recall hook in `memory/MEMORY.md` in the same commit. For edits, update the hook only when meaning or relevance changes.
- **Never commit private or sensitive material.** Use Git-root-relative `docs/private/` for sensitive operational notes such as secrets, IPs, or server paths, and `memory/private/` for personal or machine-specific facts. Both are ignored and excluded from `MEMORY.md`. Absence from the shared index does not prove private memory is absent.
- At a cohesive verified checkpoint for authorized mutations, create a local commit by default and include corresponding documentation. Stage only in-scope paths or hunks and never push unless requested. This repository is English-only.
- Lifecycle hooks under `.claude/hooks/` and `.claude/settings.json` check baseline and links at SessionStart, report comment-audit leads after Edit/Write, suggest acceptance and commit checkpoints at TaskCompleted, check the shared-memory index at Stop, and preserve continuity at PreCompact. Reminders are advisory; they do not decide comment placement or block ordinary source edits.

## Context gathering

Complete this before filling or refactoring CLAUDE.md. Gather evidence rather than guessing:

1. **Existing material:** CLAUDE.md, `docs/`, `memory/`, README, and ADRs. Identify existing knowledge, duplication, and drift.
2. **Actual repository structure:** manifests such as package.json, pyproject, or go.mod; workspace layout; Docker, Kubernetes, and CI configuration. Derive the real stack, services, and entry points.
3. **Git history:** `git log --oneline -30` to identify recent work, commit style, and repeated fixes that may indicate a durable quirk.
4. **Declared debt:** scan `TODO(`, `FIXME(`, and `HACK(` markers for local unfinished work.
5. **Ask only what code cannot establish:** mission and boundaries, product stage, and undocumented decisions. Group concise questions once.

Then populate the template: inventory from repository structure, quirks from history, TODOs from markers, and mission or constraints from user input. Every CLAUDE.md line must trace to one of these evidence sources.

Before declaring context gathering complete, cross-reference existing documentation with the actual module, service, and route inventory. Code absent from existing docs is a documentation gap, not evidence that it is unimportant. Existing documentation may simply predate the module or omit it.

When the gap spans many modules and existing rationale is nearly absent, structural evidence can establish what exists but not why. Expand the final question set to cover intent and design rationale for important modules before writing the first CLAUDE.md.

## Usage

### New repository

1. Run `bash ${CLAUDE_SKILL_DIR}/kit/init.sh <repo>` using Git Bash on Windows. It is idempotent and creates CLAUDE.md, memory, docs, private ignored directories, `.gitignore` entries, and the harness link. Existing files are backed up as `.bak-*`. Run the same command for an existing repository on a new machine to create that machine's link.
2. Fill CLAUDE.md placeholders from codebase evidence.
3. Add initial facts such as mission, stack decisions, and quirks under `memory/`, then update `memory/MEMORY.md`.

### Existing repository with CLAUDE.md

1. Run init; it preserves CLAUDE.md while creating the link and merging harness memory into the repository.
2. Merge the “Memory policy” section from `kit/CLAUDE.template.md` into the existing CLAUDE.md.
3. Follow the `kit/README.md` refactoring playbook: separate durable knowledge from history, move deep material into `docs/`, short facts into `memory/`, and reduce status to a concise per-module summary with links.
4. Sweep sensitive data such as IPs, server paths, credentials, and security-sensitive procedures out of tracked documentation into repository `docs/private/`, leaving a pointer.

### Reapply or upgrade

Two layers have genuinely different costs:

1. **Mechanical files** fully owned by the kit, such as `docs-drift.sh` and `settings.json`, update through init. It writes hook scripts atomically, detects legacy PowerShell or path-resolution settings that need manual migration, and repairs the memory link. These files intentionally contain no repository customization.
2. **CLAUDE.md content** may mix kit policy with repository customization. There is no safe shortcut: repeat full context gathering, read the entire existing CLAUDE.md and current template, and merge deliberately. Automatic section replacement could overwrite repository truth.

Upgrade steps:

1. Run init again for the mechanical layer.
2. Gather context, then merge newly introduced template content while preserving repository customization.
3. Apply new conventions from `kit/README.md` that the repository does not yet follow. Invoke `/docs:placement` for established docs topology, subfolders, or indexes; setup continues to own kit adoption and upgrades.
4. Finish with `/docs:link`; when older documentation may have drifted, run `/docs:stale` within the user-agreed scope.
5. Summarize the upgrade for the user.

## Guardrails

- **CLAUDE.md must not hardcode derivable facts** such as file, line, rule, table, or migration counts; generated filename lists; or schema and DTO shapes. Point to a command such as `ls`, `wc -l`, or `grep -c`, or to the owning source. Copied facts become stale while still looking authoritative because CLAUDE.md loads every session. During every setup, refactor, or audit, replace hardcoded derived values with a source or an adjacent reproduction command.
- Never remove the “Memory policy” section; it is how later sessions discover memory behavior.
- New harness memory appears as untracked repository files. Review it before committing, remove personal metadata such as `originSessionId`, and check for secrets.
- If the harness memory directory is not a link after moving repositories or machines, rerun init. Never delete an existing real directory before its facts are merged and backed up.
