---
name: data-design:lifecycle-governance
description: ออกแบบ data lifecycle และ governance เช่น retention, archival, soft/hard delete, anonymization, audit/history, PII classification และ erasure ใช้เมื่อข้อมูลต้องมีอายุ, ต้องลบ/เก็บต่อ, ต้องตรวจย้อนหลัง หรือมีข้อมูลอ่อนไหว
---

# Data Lifecycle & Governance

- ก่อนเก็บข้อมูล ให้ระบุ purpose, source of truth, data class, owner, retention/expiry และสิ่งที่ต้องเกิดเมื่อหมดอายุ; หากข้อกำหนดทางธุรกิจหรือกฎหมายไม่ชัด ให้ถาม owner แทนการเดาระยะเวลา
- แยก soft delete, hard delete, archive และ anonymization ตามความหมายจริง: soft delete ไม่ใช่ privacy erasure, hard delete อาจทำลาย referential/audit need, archive ต้องยังค้น/restore ได้ตาม contract ที่ระบุ
- deletion ต้องครอบคลุม primary store, derived data, search index, cache, attachment และ downstream copy ที่ระบบควบคุมได้; ระบุ asynchronous completion และข้อยกเว้นที่เก็บต่ออย่างชัดเจน
- audit/history ต้องตอบได้ว่าใครทำอะไรกับ target ใด เมื่อไร และผลคืออะไร โดยไม่ใส่ secret หรือ PII เกินจำเป็น; อย่าใช้ audit log แทน source of truth หรือเหตุผลรองรับการเก็บข้อมูลทุกอย่างตลอดไป
- แยก access/retention ของ PII จากข้อมูลทั่วไป, ลดการเก็บและการคัดลอก, และตรวจ tenant scope ทุกทางที่ read/export/delete; authorization อยู่ `authz-multitenancy`

backup/restore และ retention ของ telemetry อยู่ `production-recovery`; privileged-action audit อยู่
`authz-multitenancy`/`money-handling` ตามโดเมน. Skill นี้เป็น owner ของ lifecycle semantics ของ data และ
ผลของ deletion/retention ที่ consumer พึ่งพาได้.

ตรวจอย่างน้อย create → retain → access → delete/expire และ recovery/audit path ที่มีจริง; ถ้า
downstream erasure หรือ archive ยังทำไม่ได้ ให้รายงานเป็น gap ไม่อ้างว่า delete จบแล้ว.
