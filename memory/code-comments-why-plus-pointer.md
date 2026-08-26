---
name: code-comments-why-plus-pointer
description: เก็บ why/constraint ที่จำเป็นต่อ local code ไว้ใกล้จุดใช้; ย้าย rationale/history/procedure ที่กว้างกว่าไป docs เมื่อช่วย ownership โดยไม่ใช้จำนวนบรรทัดเป็นกฎตายตัว
metadata:
  node_type: memory
  type: feedback
---

user ต้องการ comment style ที่เน้น **การตัดสินใจ/ทำไม/constraint** และไม่เล่า implementation
ซ้ำ code. เก็บสิ่งที่คนแก้จุดนั้นต้องเห็นไว้ใกล้ code; ใช้ pointer เมื่อ rationale, history,
experiment หรือ procedure มี scope กว้างกว่า local context.

**Why:** 2026-07-17 user ทักว่า comment ในโค้ดเยอะมาก (เคสจริง: block 13 บรรทัดผล sweep
ใน semantic_classify.py) — แนวนี้ตรงมาตรฐานสากล (Clean Code/Ousterhout: "code = how,
comment = why") และตรงเกณฑ์ push/pull/recall (รายละเอียด = pull → docs)

**How to apply:** ตัดสินจาก future reader และ owner ของ fact ไม่ใช่จำนวนบรรทัด. Local guard/constraint
อยู่ inline ได้เท่าที่จำเป็น; broader rationale ไป `docs/<topic>.md` แล้วชี้จาก code เมื่อ pointer
ช่วย discovery. กฎเดิม `>2 บรรทัด → ย้ายเสมอ` ถูกถอนจาก instruction-overload audit 2026-08-26.
