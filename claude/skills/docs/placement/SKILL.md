---
name: docs:placement
description: Decide where repository knowledge belongs among comments, docstrings, docs, memory, and CLAUDE.md; organize an established docs tree/index; or audit comment/docstring debt. Use when placement, topology, or comment audit is the task; not for kit setup, ordinary comments, or incidental documentation updates with an obvious owner.
---

# Documentation Placement — One Home per Fact

Choose a fact's home according to the mechanism that will surface it.

<!-- This table and discipline mirror kit/CLAUDE.template.md in the placement boundary section.
     A one-sided change creates drift, so update both. The shared template intentionally omits this
     internal pointer; this file alone carries the synchronization warning. -->

## Placement table: nearest to code first

| Layer | Read when | Contains only | Limit |
|---|---|---|---|
| **Codetag** `TODO(scope):` | Searching or reviewing status | A marker for unfinished work (PEP 350), not explanation | **Must disappear** in the commit that completes the work; move persistent items into the CLAUDE.md TODO list |
| **Inline comment** | A reader reaches that line while editing | A local constraint or why that code, types, tests, or good names cannot express, plus a guard at the edit point | Do not write by default; when necessary, keep it readable beside the code and point elsewhere for rationale beyond local context |
| **Docstring** | Calling or changing that function or module | Interface contract: purpose, parameters/return, invariants, and side effects | Concise but contract-complete |
| **`docs/<topic>.md`** | Someone deliberately works on that topic (pull) | Deep topic material: design, runbook, history, or experiment results | May be long |
| **`memory/<fact>.md`** | The fact must surface before someone knows to search for it (recall) | One fact: quirk, trap, preference, or concise decision | One fact per file |
| **CLAUDE.md** | Every session (push; every line is a tax) | Overview plus operational rules whose absence would break work | Each section no more than roughly 15 lines |

Shortcut: *who should encounter this, and when?* Unfinished work → codetag; necessary local why while editing → comment; usage contract → docstring; deliberate topic work → docs; proactive recall → memory; every session → CLAUDE.md.

## Comment discipline: code explains how, comments explain why

- Keep only local constraints and reasons necessary to modify code that code, types, tests, and good names cannot express. If the code already explains it, omit the comment. Move rationale, history, experiments, or procedures beyond local context to docs, regardless of line count.
- **Create the destination file and heading before writing a pointer.** A nonexistent `docs/x.md#heading` pointer is worse than no pointer. `/docs:link` checks both levels.
- Committed pointers must resolve from a clean clone. Do not point to `~/.claude/` or machine-specific paths.
- Do not narrate the next line, justify a change for reviewers, preserve changelog prose such as “previously...,” or retain commented-out code. Git keeps history.

## Docstring discipline

- **Writing:** public functions, classes, modules, and script entry points receive language-idiomatic docstrings describing their contract: purpose, inputs/outputs, invariants, and side effects. Self-explanatory internal helpers do not need them.
- **Reading:** before calling, changing, or reimplementing an existing function, read its docstring rather than inferring from the name. A docstring contradicting actual behavior is a documentation defect to fix in the same task.
- Docstrings own interface-level why; inline comments own implementation-level why. Do not swap or collapse them.
- Docstrings can become bloated too. Tutorials, history, and design justification belong in docs. Do not duplicate usage already provided by argparse or help output.

## Recording knowledge at task close

Use this with the docs-setup task-close checklist:

1. A quirk, trap, or lesson → **memory**, one fact; not a long comment or CLAUDE.md addition.
2. A decision and rationale → CLAUDE.md if concise and operational, otherwise docs/decisions.
3. An experiment or measurement → a dated point-in-time document. If a script reproduces the number, point to the source rather than recording the number.
4. Duplicate knowledge → select one home from the table and leave pointers elsewhere.
5. Creating, moving, renaming, or deleting shared memory → synchronize its pointer and recall hook in `memory/MEMORY.md`; after editing, update the hook if meaning or relevance changed.

## Workspace level: monorepos and Git submodules

- **Module documentation lives with the module**, such as `packages/<pkg>/docs/`, and submodules own their docs. The root keeps only a pointer and one to three lines of context per module. Root CLAUDE.md is pushed to the entire workspace while module detail is pulled on demand; colocated docs also survive standalone or alternate-superproject use.
- Cross-cutting material such as whole-workspace deployment or inter-module contracts remains at the root. The boundary is “one module” versus “between modules.”
- For a workspace containing several independent Git repositories rather than a monorepo or submodule structure, use `/docs:workspace` to map Git roots, choose fact owners, and verify standalone-clone boundaries before moving documentation.

## Documentation topology

- Name files by domain or purpose, not creation date.
- When `docs/` grows beyond roughly seven flat files, propose domain-based subfolders and move files only when that work is in scope. The threshold is an organization signal, not permission for unrelated cleanup.
- The CLAUDE.md index must be grouped and contain one line per file with its name and a hook explaining when to open it. Keep it synchronized with real files in the same commit as additions, moves, or deletions.

## Organization and remediation mode

**Set scope first.** Remediate only requested files or files touched by the current task. A repository-wide sweep requires explicit authorization under `claude/rules/core/change-control.md`; otherwise suggest out-of-scope work instead of performing it.

The governing distinction is: **rules stay in code; the story of how a rule was discovered goes to docs.** Keep a one-line local guard that editors must see. Move old incidents, measurements, and version history into docs with a pointer.

Measure deterministic signals first:

```bash
python <skill-dir>/scripts/scan.py <repo> [--max N]
```

The scanner counts blocks above a threshold and detects verbatim duplicates across files. Its output is a lead for judgment, not an auto-fix list. Header docstrings may be correct contracts, and triple-quoted data may also be reported.

### Comment audit mode: read-only before remediation

Use when the user asks to audit or review comments or docstrings without requesting edits. Define the scope as a diff, directory, or entire repository. A broad repository audit may use bounded read-only batches, but the requester must inspect primary evidence before summarizing.

```bash
python <skill-dir>/scripts/scan.py <repo> --diff HEAD --format json
python <skill-dir>/scripts/scan.py <repo> --max 2
```

The scanner identifies candidates through block length, duplication, and changed-line intersection; none proves a comment is wrong. Diff mode examines every changed block by default, while a full scan uses more than two lines to reduce noise unless `--max` overrides it. Read surrounding code, tests, and requirements, then report `file:line | severity | category | evidence | recommendation` using only applicable categories: `KEEP`, `STALE`, `NARRATION`, `MOVE`, `DUPLICATE`, `CODETAG`, `DOCSTRING`, or `AUTHORITY-RISK`. Never auto-fix based on length or category; remediation requires user authorization.

For each file:

1. Classify comments whose scope exceeds local code context:
   - Genuine why or constraint → compress to one line and add a pointer.
   - Detail, history, or experiment results → move to `docs/<topic>.md`, creating the destination before the pointer.
   - Verbatim duplicates across files → one document with pointers at each site.
   - Actual unfinished work → convert to `TODO(scope):` only when it represents real work. Do not scatter ownerless codetags during cleanup.
   - Code narration, changelog prose, or commented-out code → remove.
2. Add missing docstrings only under the writing criteria above, for public or non-obvious contracts. Never blanket-document every function.
3. Finish with `/docs:link`; moves are the highest-risk time for broken pointers, so repair until clean.
4. Commit documentation moves with the work and state what moved where.

This follows established principles from Clean Code and Ousterhout (comments explain why), PEP 257 and JSDoc (docstrings define contracts), ADRs (decisions), and Diátaxis plus SSOT (documentation organized by reading purpose). The full policy is in `~/.claude/rules/engineering/documentation-discipline.md`.
