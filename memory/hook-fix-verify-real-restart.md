---
name: hook-fix-verify-real-restart
description: Do not trust agent Bash-tool simulation for hook or settings fixes; the real WSL Bash hook runner is a different environment and requires a real user restart report.
metadata:
  type: project
---

For hook-spawn and `.claude/hooks/` path-resolution defects, the agent's Bash tool runs Git Bash/MSYS while the real hook subsystem runs WSL Bash. A perfect simulation result does not prove the actual hook works.

**Why:** The 2026-07-13 hook saga cycled through nine fixes because the measurement path could not fail. A real restart and user feedback ended the loop. See `docs/hook-saga.md`.

**How to apply:** After changing a hook, ask the user to restart a real session and report the result before claiming the fix works.
