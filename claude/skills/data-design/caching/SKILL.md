---
name: data-design:caching
description: ออกแบบหรือแก้ application/data cache, cache key, TTL, invalidation, staleness และ cache-miss path ใช้เมื่อเพิ่ม cache หรือเมื่อความถูกต้อง/performance ขึ้นกับข้อมูลที่เก็บสำเนาไว้
---

# Caching

- **ห้ามใส่ cache จนกว่าจะตอบครบ 3 ข้อ**: (1) invalidate เมื่อไหร่/ด้วยอะไร (2) ทน staleness ได้แค่ไหน (3) cache miss แล้ว path เป็นยังไง
- cache เป็นสำเนา ไม่ใช่ source of truth: เขียน store จริงก่อน และระบบต้องยังถูกต้องเมื่อ cache หายทั้งก้อน
- กำหนด key naming, scope/tenant และ TTL ทุกตัว; อย่าให้ key อมตะหรือข้าม tenant โดยไม่มี owner ที่รู้จัก
- ระบุ consistency ตอน write, invalidation failure และ stampede/hot key เมื่อมีความเสี่ยงจริง; อย่าซ่อน stale result ที่เปลี่ยน decision หรือ authorization ของผู้ใช้

HTTP cache/ETag/conditional request อยู่ `api-design:caching-concurrency`; query plan และหลักฐานด้าน
performance อยู่ `performance-discipline`. ตรวจ miss, hit และ write/invalidation อย่างน้อยหนึ่ง flow ที่
contract อ้างว่ารองรับ.
