---
name: claude-p-testbed-limits
description: claude -p provides a fresh rules, skills, and agent test bed with parallel stream-json measurement, but it does not fire Stop hooks and a running script must not be edited.
metadata:
  type: project
---

Use `claude -p` to verify rule, skill, or agent changes without restarting. A subagent cannot substitute because it inherits existing context. Measure ground truth from actual tool use in `--output-format stream-json`.

**Limits:** It does not fire Stop hooks, which require a real session. Never edit a Bash script while its process runs because incremental reads can mix versions and crash. An LLM may repeat a visible skill description without invoking the registry; only actual invocation is ground truth.
