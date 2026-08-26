---
name: api-design
description: Router สำหรับมาตรฐาน HTTP/REST API ใช้เมื่อออกแบบหรือแก้ endpoint, request/response contract, error, list/query, mutation, async operation, cache/concurrency หรือ public API evolution. ก่อนออกแบบให้ map HTTP/data flow แล้วอ่าน child skill ที่ตรง; endpoint ใหม่หรือเปลี่ยน request/response ต้องอ่าน api-design:contract-core เสมอ
---

# API Design (HTTP / REST)

ก่อนแก้ API ให้ระบุว่า client อ่าน resource, จัดการ collection, ทำ mutation, รอ operation,
ใช้ cache/conditional request หรือรับ contract ที่ต้อง compatible แล้วอ่าน child ที่ตรง **ก่อน**
เปลี่ยน contract หรือเขียน handler

| ลักษณะงาน | ต้องอ่าน |
|---|---|
| เพิ่ม/แก้ endpoint, request/response representation หรือ HTTP semantics | `api-design:contract-core` |
| error, validation response, authentication/authorization failure | `api-design:errors` |
| list/search/filter/sort/pagination | `api-design:collections` |
| POST/PATCH/DELETE, side effect, duplicate submit หรือ retry | `api-design:mutations` |
| `202 Accepted`, background job, long-running action หรือ operation status | `api-design:async-operations` |
| cache header, ETag, conditional request หรือ stale write | `api-design:caching-concurrency` |
| public contract change, version, deprecation หรือ migration | `api-design:evolution` |

endpoint เดียวอ่านได้หลาย child ตาม flow จริง; ห้ามโหลดครบทุก child เพียงเพื่อ checklist และห้าม
ข้าม child ที่ trigger ตรงเพียงเพราะ handler ดูเล็ก. `risk-review`, validation boundary,
performance/N+1 และ external integration safety ยังเป็น owner เดิม — skill นี้ชี้ boundary
แต่ไม่ซ้ำ policy.

## Resource operation inventory

เมื่อ resource ถูกจัดการผ่าน API ให้ inventory `list/get/create/update/delete` และ operation เฉพาะโดเมน
จาก contract/consumer จริงก่อนออกแบบ. operation ที่ไม่รองรับต้องเป็น decision ที่ระบุเหตุผล ไม่ใช่
ของที่ลืม; **inventory เป็นการวิเคราะห์ ไม่ใช่ authorization ให้สร้าง operation นอก scope**.
อ่าน `contract-core` สำหรับ representation/method, `collections` สำหรับ list และ `mutations`
สำหรับ create/update/delete. lifecycle ของ deletion/retention อยู่ `data-design:lifecycle-governance`.

ถ้า contract เปลี่ยน behavior ที่ client สังเกตได้ ให้ผ่าน behavioral-change gate ก่อน; API ที่ public
แล้วเป็น compatibility surface ไม่ใช่ implementation detail.
