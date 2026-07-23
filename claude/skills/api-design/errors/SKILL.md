---
name: api-design:errors
description: ออกแบบ HTTP error, validation response และ Problem Details contract ใช้เมื่อเพิ่มหรือแก้ 4xx/5xx, error middleware, field validation response หรือ client recovery contract ของ REST API
---

# Errors

- 400 = malformed request; 401 = ไม่รู้ว่าเป็นใคร; 403 = รู้แล้วแต่ไม่มีสิทธิ์; 404 = ไม่มี resource หรือซ่อน cross-tenant ตาม rule authz; 409 = domain conflict; 422 = semantic validation; 429 = rate limit; 500 = unexpected; 503 = unavailable/maintenance
- ใช้ Problem Details shape เดียวทั้ง API: machine-readable `type`/code สำหรับ client branch, `title`/`detail` ที่ผู้ใช้เข้าใจได้ และ field errors เมื่อแก้ได้เป็นราย field; ห้าม leak stack, SQL, internal path หรือ secret
- response ที่ partial failure ต้องระบุว่า item/action ใดสำเร็จหรือล้มเหลว; ห้ามคืน 200/"success" รวม ๆ เพื่อซ่อนผลที่ client ต้อง recover
- validation rule, authorization/tenant visibility และ error logging เป็น owner ของ rule ที่เกี่ยวข้อง; อย่าสร้าง error shape ใหม่เพื่อหลบ contract กลาง

ตรวจ error path ที่เกิดจริงอย่างน้อยหนึ่ง path ต่อ semantics ที่เพิ่มหรือเปลี่ยน และให้ client parse shape เดียวกับ runtime response.
