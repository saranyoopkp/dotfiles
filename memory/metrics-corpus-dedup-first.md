---
name: metrics-corpus-dedup-first
description: Before measuring a session corpus, remove abandoned rewind or edit siblings, use primary sessions, and inspect time trends rather than only aggregate averages.
metadata:
  type: project
---

The corpus under `~/.claude/projects` contains abandoned sibling branches from rewinds and message edits. `extract_turns.py` keeps the final sibling per parentUuid. Compaction can break parentUuid chains mid-file, so walking backward from a leaf discards pre-compaction history.

**How to apply:** Always use `test/metrics/` instead of scanning raw transcripts. Exclude subagents, Temp sessions, and `-p` runs; separate WORK from META before interpreting concession or correction signals. See `docs/scc-behavior-experiment.md`.
