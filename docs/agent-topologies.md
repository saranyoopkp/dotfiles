# Agent topologies — reader reference

This reader reference explains Claude Code mechanisms. It is neither active instruction nor repository routing policy. The repository does not automatically select or invoke a topology; the user triggers one manually when needed.

## Roles and topologies

`SCC`, `Scout`, and `ACV` are worker roles. Subagents, forks, agent teams, background sessions, and worktrees are mechanisms for context, coordination, or file isolation. Adding a topology does not require a new role.

| Form | Meaning | Caution |
|---|---|---|
| Main session / SCC | Primary user-facing session owning the objective | Appropriate for decisions and continuous edits |
| `subagent` | Separate context for self-contained or read-only subtasks | It does not automatically know parent context; recheck results |
| `fork` | Branch a conversation to experiment with a side task | It sees prior context but is not a security boundary and does not merge results |
| `agent team` | Coordinated agents with separate ownership | Poor fit for sequential, same-file, or tightly coupled work |
| `background session` | Independent long-running session whose result is not immediately needed | Completion does not mean work was merged, verified, or delivered |
| `worktree` | Separate checkout and branch preventing file collisions | Provides file and branch isolation, not a role; reconcile diffs before integration |

`/branch` and `--fork-session` branch a conversation while preserving the original; they do not create workers in the same session.

## Manual triggering

Provide enough information for the invoked session or agent to work without guessing:

1. Objective and desired outcome.
2. Acceptance evidence.
3. Scope, paths, revision or worktree, and prohibited changes.
4. Necessary dependencies and assumptions.
5. Required result format.

Results from another session are inputs to verify, not automatic acceptance evidence. Before integration, inspect changed paths, diffs, tests or outputs, limitations, and the current revision.

Resume a session only when objective, acceptance criteria, scope and owner, revision, and worktree remain the same concern. Start new context across a different boundary to contain blast radius.

## Official references

- [Subagents](https://code.claude.com/docs/en/sub-agents)
- [Agent teams](https://code.claude.com/docs/en/agent-teams)
- [Sessions](https://code.claude.com/docs/en/sessions)
- [Worktrees](https://code.claude.com/docs/en/worktrees)
- [Agent view](https://code.claude.com/docs/en/agent-view)
