---
name: data-design:transactions-invariants
description: ออกแบบ transaction boundary, database invariant, locking, isolation, concurrent update, duplicate race และ transactional outbox ใช้เมื่อ operation หนึ่งเขียนหลาย record หรือผลลัพธ์ต้องถูกต้องแม้มี retry/worker/client พร้อมกัน
---

# Transactions & Invariants

- ระบุ invariant ก่อนเลือก transaction: อะไรห้ามติดลบ, ซ้ำ, ข้าม tenant หรืออยู่ใน state ที่เป็นไปไม่ได้ แล้วบังคับด้วย DB constraint เมื่อบังคับได้
- ทำ write ที่ต้อง commit/rollback ร่วมกันใน transaction เดียว; อย่าอ่านแล้วตัดสินใจแล้วเขียนภายหลังโดยไม่มี lock/precondition เมื่อ concurrent request ทำให้ผลผิดได้
- เลือก optimistic precondition หรือ row/advisory lock ตาม conflict ที่เกิดได้จริง; กำหนด retry สำหรับ serialization/deadlock failure แบบ bounded และไม่ซ่อนผล conflict จาก caller
- ห้ามทำ external side effect ที่ย้อนกลับไม่ได้ใน DB transaction. หากต้อง commit data พร้อม publish event ให้บันทึก intent/outbox ใน transaction แล้วให้ worker ส่งแบบ idempotent
- worker claim ต้อง atomic และอยู่ใน transaction; `FOR UPDATE SKIP LOCKED` นอก transaction ไม่กันงานซ้ำ

API retry/idempotency อ่าน `api-design:mutations`; delivery retry/DLQ และ webhook reliability อยู่
`webhook-integration`. Skill นี้เป็น owner ของความถูกต้องของ state ใน database และ boundary ระหว่าง state
นั้นกับ event.

ตรวจ happy path, rollback/failure กลางทาง และ race หรือ retry อย่างน้อยหนึ่ง flow ตาม invariant ที่เพิ่ม.
