# memory/

Version-controlled project memory — **the only copy**.

The Claude Code harness memory directory (`~/.claude/projects/<id>/memory`) is a link—a Windows junction or Unix symlink created during repository setup—pointing here. The harness reads and writes these exact files; no manual synchronization exists.

Rules:
- One file equals one concise fact, readable in about 30 seconds. Put larger topics in `docs/` and let memory point there.
- Every file follows `_fact.template.md` frontmatter with `name`, `description`, and `type`.
- Always update the `MEMORY.md` index after adding or changing files; the harness loads it every session.
- New harness memory appears as untracked repository files. Review and commit it deliberately.
- Delete facts that are no longer true rather than misleading future sessions.
- Moving the repository to another machine does not recreate the harness link. Use the command in CLAUDE.md's “Memory policy” section.
