# Memory Index

## Feedback and collaboration preferences
- [Deliverable form: data first](deliverable-form-data-first.md) — Reports and measurements lead with numbers and charts, not essays.
- [Audit questions mean check evidence](audit-questions-mean-check-evidence.md) — Brief “is that true or inferred?” questions trigger inspection of raw evidence, not more explanation.
- [Code comments: local why, broader rationale in docs](code-comments-why-plus-pointer.md) — Decide by scope and reader; length alone does not force a move.
- [Validate whole file after edit](validate-whole-file-after-edit.md) — After append or replacement edits, inspect the complete structure before committing.

## Project quirks and traps
- [Hook fix means verify via real restart](hook-fix-verify-real-restart.md) — The agent Bash environment differs from the WSL hook runner.
- [claude -p test-bed limits](claude-p-testbed-limits.md) — It does not fire Stop hooks; never edit a script while its process is running.
- [Metrics corpus: deduplicate first](metrics-corpus-dedup-first.md) — Remove abandoned siblings, use primary sessions, and inspect time trends.
- [Deploy docs-drift in pairs](deploy-docs-drift-in-pairs.md) — Keep script and settings deployments synchronized.
- [PowerShell commits: avoid quotes](powershell-commit-no-quotes.md) — Here-string parsing can fail.
