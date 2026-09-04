---
name: validate-whole-file-after-edit
description: After append, sed, or string-replacement edits to documentation or skills, inspect the entire file structure before committing; local spot checks miss structural defects.
metadata:
  type: feedback
---

After editing a file—especially appending, sed replacement, or string replacement—inspect the full structure: section order, summaries, tables and shortcuts coupled to new content, and whether the footer remains last.

**Why:** On 2026-07-18, full-file review immediately exposed two defects after an append: a shortcut omitted the new layer and the footer remained in the middle. The same day, heredoc string replacement failed silently three times, reinforcing use of a structured edit tool for important files.

**How to apply:** After editing, read the full file or its complete structural tail, verify order and consistency, and finish documentation work with `/docs:link`.
