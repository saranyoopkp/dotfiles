---
name: api-design
description: ออกแบบหรือแก้ HTTP/REST API: resource, method/status semantics, error contract, idempotency, pagination และ compatibility. ใช้ก่อนกำหนด endpoint หรือ public API contract.
---

# API Design

ออกแบบ contract ให้ผู้เรียกใช้เข้าใจและ evolve ได้ โดยยึด convention ของ repo ก่อน

- ใช้ resource-oriented paths และ HTTP method/status ที่สื่อความหมาย; อธิบายข้อยกเว้นเมื่อ protocol หรือ existing contract บังคับให้ต่าง
- response และ error ของ API เดียวกันควรมี shape สม่ำเสมอ, machine-readable code/type และไม่ leak ข้อมูลภายใน
- mutating operation ที่ retry หรือ double-submit ได้ ต้องมี idempotency strategy ตามผลกระทบ
- list ที่โตได้ต้องมี limit/pagination; เลือก cursor หรือ offset ตามความเสถียรและรูปแบบข้อมูล
- เปลี่ยน public contract แบบ additive ก่อน; breaking change ต้องมี compatibility/rollout plan ตาม rule `compatibility-and-rollout`
- contract ที่หลาย consumer ใช้ควรมี source of truth เดียวตาม `stack-consistency`

ก่อนจบงาน ให้ยืนยัน happy path และ error path สำคัญจาก API จริงหรือระบุสิ่งที่ยังไม่ตรวจ.
