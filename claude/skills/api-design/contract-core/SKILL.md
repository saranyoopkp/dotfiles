---
name: api-design:contract-core
description: กำหนด HTTP/REST request-response contract, resource naming, method/status semantics, representation, content negotiation, rate-limit response contract และ OpenAPI/JSON Schema ที่ repo ใช้อยู่ ใช้ทุกครั้งที่เพิ่มหรือเปลี่ยน endpoint หรือ public request/response shape
---

# Contract Core

- resource เป็นนาม ไม่ใช่กริยา (`POST /orders` ไม่ใช่ `/createOrder`); nesting เกิน 2 ชั้นต้องมีเหตุผลจาก ownership จริง
- GET ต้อง safe + idempotent; PUT/DELETE ต้อง idempotent; PATCH คือ partial update. เลือก 200 (body), 201 (created + `Location`), 202 (งานยังไม่เสร็จ) หรือ 204 (ไม่มี body) ให้ตรงผลจริง
- representation ต้องประกาศชื่อ field, null-vs-omitted, enum/optional field, datetime พร้อม timezone และหน่วย/format ของจำนวนให้ client ตีความได้เดียว; เรื่องเงินและ authorization ชี้ rule เจ้าของเดิม
- รองรับ content negotiation เฉพาะ format/version ที่ product รับจริง; อย่ารับ `Accept` หรือส่ง media type หลายแบบโดยไม่มี contract/consumer ที่พิสูจน์ได้
- rate limit ที่เปิดให้ client รับรู้ต้องมี response contract เดียวกัน: status 429, `Retry-After` เมื่อรู้เวลารอ และ header quota/reset ตาม convention ของ product; algorithm/infra policy อยู่ resilience/ops
- ถ้า repo ใช้ OpenAPI หรือ JSON Schema เป็น canonical contract ให้ update schema และ generated/shared client ในงานเดียวกัน; อย่าสร้าง spec ขนานจาก handler โดยไม่มี owner

ก่อนส่งมอบ ยิงหรือ test อย่างน้อย success และ representation ที่เปลี่ยน; ตรวจ method/status/header/body กับ contract ที่ client หรือ schema คาดจริง ไม่ใช่ดูเฉพาะ handler.
