---
name: deliverable-form-data-first
description: "user ขอ \"รายงาน/ผลวัด/trend\" = ต้องการตัวเลขและกราฟเป็นตัวหลัก ไม่ใช่ความเรียงวิเคราะห์"
metadata:
  node_type: memory
  type: feedback
---

เมื่อ user ขอ "รายงาน", "ผลวัด", "trend", "ดูหน่อย" เกี่ยวกับ metrics — deliverable ที่ต้องการคือ
**ตัวเลข + กราฟ/ตาราง เป็นตัวหลัก** (dashboard, ค่ารายวัน, before/after) — ความเรียง/insight
เป็นได้แค่ caption สั้น ๆ ประกอบ

**Why:** 2026-07-17 ผมส่ง HTML narrative report ตอบคำขอ "ทำรายงานมาดูหน่อย" — user แก้สองรอบ:
"ผมหมายถึงตัวเลข metrics แต่ละรอบ (จะดูกราฟ ไม่ได้จะดูคำอธิบาย)" — และ preference นี้ประกาศ
ตั้งแต่แรก ("อยากทำ semantic **ดู graph**"). root cause ที่วัดได้: context ที่โหลดทุก session
เป็น prose 99.3% + ไม่มี counterweight — memory นี้คือ counterweight

**How to apply:** ก่อนสร้าง deliverable เชิงผลวัด: default = ตัวเลข/กราฟก่อน แล้วประกาศ form
หนึ่งบรรทัดตามกฎ assumption-declare ของ SCC (cutover-3) — เกี่ยวข้อง: [[audit-questions-mean-check-evidence]]
