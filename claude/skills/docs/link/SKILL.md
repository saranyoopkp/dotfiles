---
name: docs:link
description: Check broken references and anchors across a repository, including Markdown-to-Markdown links, paths referenced in documentation, code-comment pointers into docs or memory, and memory wiki links. Use after moving, renaming, or deleting files; when refactoring documentation; before committing structural file changes; or when asked to verify that references point to real files. This does not check whether documentation content still matches code.
---

# Link Check — Keep References Alive

Pointers are the backbone of the documentation standard: comments point to docs, CLAUDE.md points to docs, and MEMORY.md points to facts. A broken pointer silently loses knowledge and is worse than no pointer.

## Usage: deterministic first

Do not ask an LLM to sweep manually before running the checker.

```bash
python <skill-dir>/scripts/check.py [repo_root]   # defaults to the current Git root
```

The checker covers four layers: Markdown `[text](path.md)` links; paths in Markdown backticks, excluding code fences and placeholders; `docs/... .md` pointers in code comments; and `[[wiki-link]]` references matched against filenames under `memory/`. It also verifies that `[text](file.md#heading)` targets a real heading, otherwise reporting a broken `bad-anchor`.

GitHub heading slugs use lowercase, replace each space with `-` without collapsing consecutive spaces, remove ASCII punctuation such as `.`, `/`, `(`, and `)` except `_`, preserve Thai and other Unicode including combining marks, and append `-1` to the second duplicate heading. For example, `run_check` becomes `#run_check`. When uncertain, run the script instead of guessing.

Resolution supports paths relative to the referring file, paths from the repository root, and unique-suffix shorthand such as `hooks/useX.ts`. Ambiguous shorthand is broken and must be written in full. Ignored paths such as private documentation do not count as broken, but Git blame distinguishes `[WARN] private-yours` for lines authored by the current identity from `[INFO] private-local` for others; identity alone cannot establish which machine holds the file.

Pointers into home directories such as `~/.claude`, `$HOME`, `C:/Users`, `/home/`, or `/Users/` always produce `[WARN] home-path` because personal paths do not exist on every machine or in CI. Replace them with a concise explanation or a repository-local document. A repository whose purpose requires such references, such as the dotfiles repository itself, may declare them in `.linkcheck-ignore`.

Paths beginning with `/` are treated as URL routes and skipped. A file using many shorthand paths may declare `<!-- linkcheck-base: path/base -->`. Documentation referencing a file on an unmerged branch may declare `<!-- linkcheck-branch: feature/x -->`, which reports `[INFO] on-branch` rather than a failure; remove the declaration after merge. The command exits 1 for broken references. `[INFO] wiki-pending` is allowed by memory policy and marks a wiki link whose fact still needs to be written.

## When to run

- After every move, rename, or deletion of a Markdown file or a file referenced by documentation.
- After editing or renaming headings in frequently referenced files such as CLAUDE.md or primary docs, because anchor changes fail silently.
- At the end of a documentation refactor or `/docs:setup` reapplication.
- Before committing changes spanning several CLAUDE.md, docs, or memory files.

## Repair order for broken references

1. **Target moved:** update the pointer and confirm the content still fulfills the referring context.
2. **Target intentionally deleted:** remove or rewrite the referring sentence too; never leave orphaned prose after deleting only the link.
3. **Target never existed because the pointer was written in advance:** create the target immediately or remove the pointer. Documentation placement requires creating a target before writing its pointer.
4. After repair, **rerun the script until clean** because link fixes can break adjacent references.

## Limits that prevent false confidence

- The script checks file existence, not content freshness. An existing file may still be stale; content review belongs to the docs-drift hook and task-close checks.
- Anchor verification covers Markdown links such as `file.md#heading`, not prose or backtick section references, which are too fuzzy for deterministic checking without false positives.
- Runtime-composed paths such as variables and f-strings are invisible to the checker. Do not claim “clean” beyond this boundary.
