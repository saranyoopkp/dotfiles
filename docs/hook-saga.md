# Hook path-resolution saga (point in time: resolved 2026-07-13, fully recorded 2026-07-18)

History of 12 `.claude/settings.json` hook-wiring versions. This record exists to prevent reintroducing dead approaches. The current state is **version 12 only**; `CLAUDE.md` §Quirks contains the short summary.

## The lesson that covers the whole saga

**The agent's Bash tool is not the real hook runner.** On Windows, Claude Code's hook execution subsystem always runs through **WSL bash** (`System32\bash.exe`), independently of the interactive Bash tool used by the agent (Git Bash/MSYS, where `uname` reports `MINGW64_NT`). Every simulated fix passed in the Bash tool while the real hook kept failing. An empty `WSL_DISTRO_NAME` in the agent's `env` was evidence about the Bash tool, not the hook subsystem. On 2026-07-13, the user identified the root cause: "you are in WSL." The resulting rule is:

**Validate hook fixes only through a real session restart and user feedback.** The user explicitly requested this on 2026-07-13 at 09:20: "for the next debugging round, use real feedback from me" (commit `809d32e`).

That day's nine-fix, four-hour loop ended as soon as the measurement channel changed, not when the fixes became more sophisticated. This is the main loop-breaker evidence in the third SCC draft (`docs/scc-behavior-experiment.md`).

## Versions 1–12 (all obsolete except 12)

1. Relative path (`.claude/hooks/...`) failed when launched from a subdirectory because resolution used the launch working directory.
2. Passing `"${CLAUDE_PROJECT_DIR}/..."` directly in args failed because the Windows harness stripped backslashes during string substitution, leaving a path without separators (undocumented).
3. `args: ["-c", "...$CLAUDE_PROJECT_DIR...cygpath -u..."]`, expanded by bash, appeared fixed but failed intermittently. The machine had three conflicting bash executables on `PATH`: Git Bash, the WSL launcher at `System32\bash.exe`, and a Windows Store alias. `"command": "bash"` could resolve to WSL bash, which could not see the Windows environment variable and lacked `cygpath` (`cygpath: command not found`).
4. `env.CLAUDE_CODE_GIT_BASH_PATH`, a documented environment variable, did not work. Hook command resolution did not read it; the documented scope did not include hook spawning.
5. Writing a machine-specific absolute Git Bash path into `"command"` during initialization worked but destroyed cross-platform behavior because `settings.json` became bound to the last initialized machine. Superseded.
6. `bash -c` plus `tr '\\' '/'` to normalize `$CLAUDE_PROJECT_DIR` was genuinely cross-platform and passed JSON parsing. The user found this direction. Their first draft emitted debug output rather than executing the hook; that was caught before deployment.
7. **macOS `Permission denied`:** NTFS did not reliably preserve the executable bit in commits from Windows, while macOS enforced it. Calling `bash <path>` instead of executing the file directly removed the dependency on the executable bit. Verified on macOS for all four events on 2026-07-12.
8. `FileChanged` was removed from wiring. It was documented but never fired in the harness; three macOS test paths all remained silent. Four hooks remained verified: `SessionStart`, `Stop`, `TaskCompleted`, and `PreCompact`. The old logic was retained temporarily as dead code, then removed on 2026-08-02. Do not restore it until firing is demonstrated.
9. `$CLAUDE_PROJECT_DIR` was empty in some sessions, so the argument string that computed the `docs-drift.sh` path had no fallback. Added `${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}`.
10. The actual root cause of version 9 was the “Bash tool is not the hook runner” distinction above.
11. Setting `env.CLAUDE_CODE_GIT_BASH_PATH` in machine-local `settings.local.json` also failed, confirming that hook spawning ignored the variable at every level. All environment-variable pinning approaches were abandoned.
12. ✅ **Current version**, verified by the user through a real restart on 2026-07-13 as “the most stable”:

    `args: ["-c", "bash $(git rev-parse --show-toplevel 2>/dev/null | sed 's/\\\\/\\//g')/.claude/hooks/docs-drift.sh <Event>"]`

    The event name is embedded in one string, `bash` is invoked explicitly inside `-c`, and no system environment variable is used. `docs-drift.sh` itself relies only on `git rev-parse`. The exact reason this differs from version 6 inside the WSL bash subsystem remains unknown; argument-position-dependent evaluation of `$(...)` is one hypothesis. It is deployable because real behavior was verified, while the mechanism remains an open question documented in `CLAUDE.md`.

## Stop continuation loop (fixed 2026-07-30)

The old Stop hook did not read JSON from stdin, and its comment warning had no deduplication stamp. After the hook returned the same feedback, Claude Code continued and invoked Stop again. The script never observed `stop_hook_active=true` and kept blocking until the harness overrode it after nine attempts. The fix:

1. Read stdin for every event and immediately `exit 0` when Stop contains `stop_hook_active=true`.
2. Use `decision:block` and `reason` from the Stop contract instead of relying on `additionalContext`.
3. Deduplicate comment warnings by location state and reset the stamp when the comment disappears.
4. Add deterministic regression coverage: first Stop blocks, active Stop passes, unchanged state stays quiet, and a removed-then-restored comment warns again.

Do not address this by increasing `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`; that only lengthens the loop and does not create a convergence condition. The contract was checked against the Claude Code hooks reference and guide on 2026-07-30. Real behavior still requires a restarted session, following this document's primary rule.

## Deployment checklist (still required)

- Always deploy changes to `docs-drift.sh` together with `settings.json`. One deployment missed this: another repository retained the old comment, a macOS session exposed it, and it was fixed on 2026-07-12.
- Repositories already set up receive updates only by reapplying `/docs:setup`. Junctions affect only rules and skills; hooks are copied per repository.

## Scope-aware enforcement (template updated 2026-08-02)

A transcript audit showed that reminders intended to prevent stale documentation and forgotten commits had become a source of objective drift. The hook treated the entire dirty worktree as current scope and requested documentation edits, runtime tests, and commits without knowing which paths predated the session or what the user had authorized. The revised design therefore:

1. Captures a baseline once per repository and `session_id`. Pre-existing dirty paths are report-only; the hook must not request editing, staging, or committing them.
2. Checks comments immediately after `PostToolUse(Edit|Write)`, with a Stop fallback only for paths clean at session start. Pre-existing dirty files have ambiguous provenance.
3. Expresses verification reminders as `behavior claim / evidence / gap` and forbids expanding the test matrix or mutating shared/runtime state without authorization.
4. Gives documentation a disposition—`updated`, `no durable docs impact`, or `deferred`—instead of forcing file creation.
5. Makes SessionStart check memory links read-only; `/docs:setup` remains the owner of merging and repair.
6. Preserves one-shot Stop behavior, state deduplication, and the `stop_hook_active` loop breaker. A shared-memory leaf/index mismatch created by the session remains a deterministic violation.

The commit boundary changed with the user's workflow on 2026-08-18: authorized mutations that reach a cohesive, verified checkpoint are committed locally by default to preserve task provenance. Baseline dirty paths remain excluded, and pushing, deployment, and history rewriting still require explicit authorization. This replaced temporary wording that required every commit to be explicit, which allowed work from multiple projects to remain mixed and made provenance difficult to establish.

On 2026-08-26, an instruction-overload audit removed that default. Local commits returned to being a user or repository workflow decision. The hook stopped blocking source edits to force commits, documentation dispositions, or comment length; Stop retained only the deterministic shared-memory leaf/index check.

After the audit, the user restored local commits as the default at cohesive, verified checkpoints for tracking and rollback. Enforcement lives directly in core/SCC; the hook remains low-ceremony and does not block source edits to force a commit.

The balanced restoration on 2026-08-26 brought back `PostToolUse(Edit|Write)` as an early warning for changed code-comment blocks longer than two lines in session-owned files. It also restored `TaskCompleted` as an acceptance/evidence/commit checkpoint only when the session owns mutations. Both events are advisory and deduplicated: a comment is an audit candidate, not authority or an instruction to move content into documentation, and `TaskCompleted` does not infer ACV from a path. `Stop` still blocks only a shared-memory index mismatch.

Shell regression tests establish only script and settings logic. Following the primary lesson above, real hook-runner behavior must still be verified in a new Claude Code session after deployment or restart. Never claim that live integration passed solely because the script ran successfully in the Bash tool.
