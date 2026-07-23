---
name: api-design:caching-concurrency
description: ออกแบบ HTTP cache semantics, ETag, conditional request และ optimistic concurrency ใช้เมื่อ endpoint cacheable, ต้องตอบ 304, ต้องกัน stale write หรือมีหลาย client แก้ resource เดียวกัน
---

# Caching & Concurrency

- ประกาศ cacheability จาก data sensitivity, audience และ freshness requirement; ใช้ `Cache-Control` ที่ตรง policy จริง ไม่ mark response เป็น public/cacheable เพียงเพื่อ performance
- ใช้ ETag/conditional GET เมื่อ client/CDN ได้ประโยชน์จาก validation; `If-None-Match` ที่ตรง ETag คืน 304 โดยไม่มี representation body และรักษา header ที่จำเป็นต่อ cache
- ใช้ `If-Match`/version precondition เมื่อ stale write ทำให้ข้อมูลสูญหาย; precondition ที่ไม่ตรงคืน 412, ส่วน 409 เก็บไว้สำหรับ domain conflict ที่แม้ใช้ version ล่าสุดก็ทำไม่ได้
- cache invalidation, CDN behavior และ persistence consistency เป็น owner ของ caching/data/ops ที่เกี่ยวข้อง; API contract ต้องบอกสิ่งที่ client พึ่งได้ ไม่ใช่บอกรายละเอียด infra ที่เปลี่ยนได้

ตรวจ cache hit/revalidation หรือ concurrent update อย่างน้อยหนึ่ง flow ที่ contract อ้างว่ารองรับ รวมทั้ง response status/header/body จริง.
