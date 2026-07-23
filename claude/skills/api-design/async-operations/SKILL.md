---
name: api-design:async-operations
description: ออกแบบ HTTP contract สำหรับงานที่รับคำสั่งแล้วทำภายหลัง เช่น 202 Accepted, import/export, background job, provisioning หรือ long-running action ใช้เมื่อ request ไม่สามารถยืนยันผลสุดท้ายภายใน response เดียว
---

# Async Operations

- `202 Accepted` หมายถึงรับงานแล้ว ไม่ใช่ทำสำเร็จแล้ว; คืน operation identifier/URL และ state ที่ client ใช้ติดตามได้ พร้อมบอก polling, callback หรือ event channel ที่ product รองรับจริง
- operation state ต้องแยก pending/running/succeeded/failed/cancelled ตามที่เกิดได้จริง; terminal result/error ต้องใช้ representation/error contract เดียวกับ resource หลักเมื่อเหมาะสม
- กำหนด retry, cancellation, expiry/retention และ authorization ของ operation/status resource; อย่าให้ client เดาได้จาก job implementation ภายใน
- ถ้า client retry create-operation ต้องกำหนด idempotency/reconciliation กับ `api-design:mutations`; อย่าสร้างงานซ้ำจาก timeout โดยเงียบ ๆ

ตรวจอย่างน้อย accept → running → terminal success และ terminal failure; ถ้ารัน end-to-end ไม่ได้ ให้ระบุ state ที่ยังไม่ยืนยันแทนการอ้างว่า async flow ใช้ได้.
