---
name: data-design
description: ออกแบบหรือแก้ schema, migration, cache, queue และ dataflow ใช้เมื่อแตะ database, persistent data, worker หรือ external sync.
---

# Data Design

เริ่มจาก lifecycle และ dataflow: ข้อมูลเกิดที่ใด, ใครเป็น writer, ใครอ่าน, และกู้คืนอย่างไร

- normalize เป็น default; denormalize เมื่อมีเหตุผลด้าน query/scale ที่ชัด พร้อมวิธีรักษาความสอดคล้อง
- ใช้ constraint, key และ index ให้ DB ปกป้อง integrity ที่สำคัญ; นิยาม lifecycle, delete behavior และ external identifier ให้ชัด
- ใช้ structured column/type สำหรับข้อมูลที่ต้อง query หรือ validate เป็นประจำ; flexible payload เก็บเป็น document พร้อม contract ที่รู้ได้
- cache เป็นสำเนา ไม่ใช่ source of truth และต้องอธิบาย invalidation/staleness/failure path
- queue/worker ต้อง claim งานอย่างปลอดภัย, ทน retry/duplicate และมีทางเห็นหรือจัดการงานที่ล้มเหลว
- fact สำคัญมี writer หลักเดียว; derived data ต้อง rebuild หรือ reconcile จาก source ได้

ใช้ convention และ database capabilities ของ repo ก่อนกำหนด pattern เฉพาะเทคโนโลยี.
