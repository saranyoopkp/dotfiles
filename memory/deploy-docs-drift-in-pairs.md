---
name: deploy-docs-drift-in-pairs
description: When changing the kit's docs-drift.sh, always check whether settings.json must deploy with it; these files have previously become desynchronized across repositories.
metadata:
  type: project
---

Treat `docs-drift.sh` and `settings.json` as a deployment pair. A change to either requires checking whether the other must follow.

**Why:** When FileChanged was removed, only settings.json was deployed, leaving stale script comments in another repository. macOS exposed the mismatch on 2026-07-12. See the deployment checklist in `docs/hook-saga.md`.
