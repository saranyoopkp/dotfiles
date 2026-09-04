---
name: powershell-commit-no-quotes
description: Commit messages passed through the harness PowerShell tool should avoid quotes in here-strings because Windows PowerShell 5.1 parsing can fail; use plain ASCII.
metadata:
  type: project
---

Commit messages passed through the PowerShell tool can fail when a here-string contains quotation marks or special characters.

**How to apply:** Use a plain ASCII commit message without quotes, or commit through Bash.
