---
name: api-design
description: มาตรฐานออกแบบ HTTP/REST API — status code ให้ถูก semantic, method semantics (idempotent/safe), error shape RFC 7807 Problem Details, Idempotency-Key สำหรับ mutating, pagination (cursor vs offset), versioning, resource naming, rate-limit headers, content negotiation. ใช้เมื่อออกแบบ/แก้ REST endpoint, กำหนด response/error contract, ทำ API versioning/pagination, หรือแตะ controller/route/handler ของ HTTP API. โหลดก่อนออกแบบ contract ของ API
---

# API Design (HTTP / REST)

เน้นส่วนที่เป็น **HTTP/REST-specific** — ส่วนที่ rule อื่นครอบแล้วชี้ไป ไม่ซ้ำ (single-home):
authz/401-403 → rule `authz-multitenancy` · validation ที่ boundary → `production-readiness` ·
pagination *ต้องมีตั้งแต่แรก* + N+1 → `performance-discipline` · idempotent side-effect (ผล) →
`webhook-integration` · CRUD ครบ operation → `crud-completeness`

## Status code — ให้ตรง semantic (อย่าตอบ 200 กับทุกอย่าง)
- **2xx**: 200 (ok+body) · 201 (created, มี `Location`) · 202 (accepted async) · 204 (no body)
- **4xx (client ผิด)**: 400 (malformed) · 401 (ไม่ auth) · 403 (auth แล้วไม่มีสิทธิ์) ·
  404 (ไม่มี/ซ่อน cross-tenant) · 409 (conflict เช่น version/duplicate) · 422 (semantic invalid) ·
  429 (rate limit + `Retry-After`)
- **5xx (server ผิด)**: 500 (unexpected — อย่า leak) · 503 (down/maintenance)
- **401 vs 403 ต้องแยก**: ไม่รู้ว่าเป็นใคร = 401 · รู้แล้วแต่ห้าม = 403 (cross-tenant ใช้ 404 กัน enumerate)

## Method semantics (client/proxy พึ่งพา)
- GET = safe + idempotent (ห้ามมี side effect) · PUT/DELETE = idempotent (ซ้ำได้ผลเดิม) ·
  PATCH = partial · **POST = ไม่ idempotent** → มี side effect ต้องกัน double-submit ด้วย Idempotency-Key

## Error shape — RFC 7807 Problem Details (envelope เดียวทั้ง API)
```
{ "type": "https://.../errors/insufficient-funds", "title": "...", "status": 409,
  "detail": "...(user-facing, ไม่ leak internal/stack)", "instance": "/orders/123",
  "errors": [{ "field": "amount", "message": "..." }] }   // field errors ถ้ามี
```
- **shape เดียวทั้ง API** (FE parse ที่เดียว) — อย่าให้บาง endpoint คืน string บาง endpoint คืน object
- machine-readable `type`/`code` (ให้ client branch ได้) + human `detail` · **ห้าม leak** stack/SQL/internal path
- shape นี้ = shared contract → อยู่ shared package ทั้ง FE/BE (ตาม `stack-consistency`)

## Idempotency (mutating)
- POST ที่มีผลข้างเคียง (เงิน, สร้าง order) → รับ **`Idempotency-Key` header**, เก็บ key+result,
  ซ้ำ key เดิม → คืน result เดิม ไม่ทำซ้ำ (client retry ปลอดภัย)

## Pagination
- **cursor-based** (opaque cursor) เป็น default สำหรับ list ที่โต/realtime — เสถียรกว่า offset
  (offset เพี้ยนเมื่อมี insert/delete ระหว่างหน้า) · offset ใช้ได้กับข้อมูลนิ่ง/หน้าน้อย
- คืน `next_cursor`/`has_more` · **`total` count แพง** (COUNT ทั้งตาราง) → ให้เมื่อจำเป็นจริง
- default limit + max limit เสมอ (กันขอ 100k rows)

## Versioning & contract
- version เมื่อ **breaking** เท่านั้น (เพิ่ม field = ไม่ breaking, ดู `compatibility-and-rollout`) ·
  URL (`/v2/`) อ่านง่าย/cache ง่าย · header version เนียนกว่าแต่ debug ยาก — เลือกแล้วจดใน CLAUDE.md
- filtering/sorting: convention เดียวทั้ง API (`?status=x&sort=-created_at`) ไม่ใช่แต่ละ endpoint คิดเอง
- resource = **นาม ไม่ใช่กริยา** (`POST /orders` ไม่ใช่ `/createOrder`) · nesting ไม่เกิน ~2 ชั้น

## ก่อนปิดงาน
- response/error contract ตรงกับที่ FE/shared package คาด (ยิงจริง ดู shape ไม่ใช่เดา) ·
  status code ถูก semantic (ลอง error path จริง ไม่ใช่แค่ happy 200)
