---
name: claude-p-testbed-limits
description: claude -p = fresh test bed ของ rules/skills/agent (รันเป็น agent จาก settings, ยิงขนานได้, วัดด้วย stream-json) — แต่ไม่ยิง Stop hook และห้ามแก้ script ที่กำลังรัน
metadata:
  type: project
---

`claude -p` ใช้ verify การเปลี่ยน rule/skill/agent โดยไม่ restart — subagent ใช้แทนไม่ได้
(สืบทอด context ค้าง); วัด ground truth ด้วย `--output-format stream-json` ดู tool_use จริง

**ข้อจำกัด:** (1) ไม่ยิง Stop hook — hook ต้อง real session (2) ห้ามแก้ bash script
ที่ process กำลังรัน (อ่าน incremental → ปนเวอร์ชัน crash) (3) LLM อาจตอบชื่อ skill จาก
description ที่เห็น ไม่ใช่จาก registry — invoke จริงเท่านั้นที่เป็น ground truth
