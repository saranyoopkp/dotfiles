---
name: api-design:mutations
description: ออกแบบ REST mutation ที่มี side effect, retry, duplicate submit หรือ idempotency ใช้เมื่อเพิ่มหรือแก้ POST/PUT/PATCH/DELETE ที่สร้าง เปลี่ยน หรือลบข้อมูลหรือผลกระทบภายนอก
---

# Mutations

- ออกแบบ flow เป็น intent → validation/authorization → pending effect → committed result หรือ recoverable failure; response ต้องบอกผลที่ server ยืนยันจริง
- POST ที่ side effect ซ้ำแล้วเสียหาย (เงิน, create order, provision, ส่งออก) ต้องรับ `Idempotency-Key`, ผูก key กับ request fingerprint/result และคืนผลเดิมเมื่อ retry ที่เทียบเท่า; key ซ้ำแต่ payload ต่างต้องมี contract ที่ชัด
- PUT/DELETE ต้อง idempotent ตาม semantics; อย่าทำ retry แล้วสร้างผลข้างเคียงเพิ่มเงียบ ๆ
- mutation หลาย item ต้องประกาศ atomicity หรือ per-item result ให้ชัด; partial failure ห้ามยุบเป็น success เดียว
- stale write/conditional update อ่าน `api-design:caching-concurrency`; งานยังไม่เสร็จใน request นี้อ่าน `api-design:async-operations`

ตรวจ happy path, retry/duplicate intent และ failure หลังเริ่ม side effect ตามความเสี่ยงจริงของ operation.
