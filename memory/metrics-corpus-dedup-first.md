---
name: metrics-corpus-dedup-first
description: วัดอะไรจาก session corpus ต้อง dedup rewind/edit sibling ก่อน (~9% ผี, bias เข้า corrective) + main session เท่านั้น + ดู time trend ไม่ใช่ค่าเฉลี่ยรวม
metadata:
  type: project
---

Corpus ใน ~/.claude/projects มี sibling branch ผีจาก rewind/message-edit (เก็บ sibling
สุดท้ายต่อ parentUuid — extract_turns.py ทำให้) และ compact ตัด parentUuid chain กลางไฟล์
(ห้ามใช้วิธี "เดิน path จาก leaf" — จะทิ้งประวัติก่อน compact)

**How to apply:** ใช้ test/metrics/ เสมอ อย่า scan ดิบ; กรอง subagents/Temp/-p;
แยก WORK/META ก่อนอ่าน concession/corrective — ดู docs/scc-behavior-experiment.md
