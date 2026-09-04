# memory/

Version-controlled project memory — **the only copy**.

The Claude Code harness memory dir (`~/.claude/projects/<id>/memory`) is a **link**
(Windows junction / unix symlink, created when this repo was set up) pointing here,
so the harness reads/writes these exact files. No manual sync.

Rules:
- One file equals one fact. Keep it short enough to read in about 30 seconds; put larger topics in `docs/` and let memory point there.
- Every file uses the frontmatter from `_fact.template.md` (`name`, `description`, and `type`).
- `MEMORY.md` contains only pointers and recall hooks for shared facts; leaf files are not opened automatically through those pointers.
- When creating, moving, renaming, or deleting a shared leaf, update the index in the same commit. When editing a leaf, verify its title, hook, and relevance and update the index if meaning changes.
- Repository-local `memory/private/`, relative to the Git root, is excluded from the index. Search machine-specific memory separately before concluding that no fact exists.
- New memory written by the harness appears as an untracked repository file. Review and commit it deliberately.
- Delete facts that are no longer true instead of misleading future sessions with obsolete content.
- Moving the repository to another machine does not recreate the harness link. Recreate it using the command in the CLAUDE.md “Memory policy” section.
