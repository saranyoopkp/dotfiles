---
name: code-comments-why-plus-pointer
description: Keep local why and constraints near code; move broader rationale, history, and procedures to docs when that improves ownership, without using line count as a hard rule.
metadata:
  node_type: memory
  type: feedback
---

The user prefers comments that preserve decisions, reasons, and constraints without narrating implementation already visible in code. Keep what an editor must see near that code; use a pointer when rationale, history, experiments, or procedures exceed local context.

**Why:** On 2026-07-17 the user flagged excessive code comments, including a 13-line sweep report in `semantic_classify.py`. The preference aligns with Clean Code and Ousterhout—code explains how, comments explain why—and with push/pull/recall placement.

**How to apply:** Decide from the future reader and fact owner, not line count. Keep necessary local guards inline; move broader rationale to `docs/<topic>.md` with a code pointer when it improves discovery. The old “more than two lines always moves” rule was removed during the 2026-08-26 instruction-overload audit.
