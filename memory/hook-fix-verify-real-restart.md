---
name: hook-fix-verify-real-restart
description: hook/settings fix ห้ามเชื่อผลทดสอบจาก Bash tool ของ agent — hook runner จริงคือ WSL bash คนละ env สิ้นเชิง ต้องให้ user restart session จริงแล้ว report กลับ
metadata:
  type: project
---

hook-spawn bug (path resolution ใน `.claude/hooks/`) — Bash tool ของ agent = Git Bash/MSYS
แต่ hook subsystem จริง = WSL bash → simulation ผ่าน 100% ไม่ได้แปลว่า hook จริงผ่าน

**Why:** hook saga 2026-07-13 วน 9 fixes เพราะเชื่อช่องทางวัดที่ fail ไม่ได้ — จบทันทีที่
เปลี่ยนเป็น real restart + user feedback — ดูเต็ม: docs/hook-saga.md

**How to apply:** แก้ hook → ขอ user restart จริง + report อาการ ก่อนประกาศ "แก้แล้ว"
