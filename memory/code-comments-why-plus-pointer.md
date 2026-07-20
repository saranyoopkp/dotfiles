---
name: code-comments-why-plus-pointer
description: comment ในโค้ด = why/constraint ไม่เกิน ~2 บรรทัด + pointer เข้า docs — ห้ามยัดประวัติ/ผลทดลอง/เนื้อหาเอกสารลง inline
metadata:
  node_type: memory
  type: feedback
---

user ต้องการ comment style: **สั้น (การตัดสินใจ/ทำไม/constraint) + pointer เข้าเอกสาร** —
ไม่เอา comment ยาวที่เล่ารายละเอียด/ประวัติ/ผลทดลอง inline

**Why:** 2026-07-17 user ทักว่า comment ในโค้ดเยอะมาก (เคสจริง: block 13 บรรทัดผล sweep
ใน semantic_classify.py) — แนวนี้ตรงมาตรฐานสากล (Clean Code/Ousterhout: "code = how,
comment = why") และตรงเกณฑ์ push/pull/recall (รายละเอียด = pull → docs)

**How to apply:** ก่อนเขียน comment >2 บรรทัด → ย้ายเนื้อไป docs/<topic>.md แล้วเหลือ
why หนึ่งบรรทัด + pointer; ข้อยกเว้นที่ตกลงกัน: guard comment ณ จุดแก้ ("ห้ามแก้โดยไม่ X")
เก็บ inline ได้แต่ ≤2 บรรทัด + pointer เช่นกัน — ดู [[deliverable-form-data-first]]
