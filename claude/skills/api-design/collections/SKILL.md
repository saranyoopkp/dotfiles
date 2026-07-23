---
name: api-design:collections
description: ออกแบบ REST API สำหรับ list, search, filter, sort, pagination, cursor และ count ใช้เมื่อ endpoint คืนหลาย resource หรือรับ query ที่เปลี่ยนชุด/ลำดับของผลลัพธ์
---

# Collections

- filtering/sorting ใช้ grammar และ naming เดียวกันทั้ง API (เช่น `?status=x&sort=-created_at`); allowlist field/operator ที่รองรับ ไม่ปล่อย query ดิบกลายเป็น persistence API
- cursor opaque เป็น default สำหรับ list ที่โตหรือมีข้อมูลเข้าออกระหว่างอ่าน; offset ใช้ได้เมื่อข้อมูลนิ่ง/จำนวนน้อยและ trade-off ถูกยอมรับ
- cursor ต้องผูกกับ sort ที่ deterministic รวม tie-breaker ที่ stable; เปลี่ยน filter/sort ต้องกำหนดว่า cursor เดิม invalid, reset หรือ reconcile อย่างไร
- return `next_cursor`/`has_more` และ default/max limit เสมอ; `total` count ให้เฉพาะเมื่อ product ต้องใช้และต้นทุนยอมรับได้
- แยก collection ว่างจริงออกจากผลลัพธ์ว่างเพราะ query; contract ต้องทำให้ client แยกได้โดยไม่เดาจากข้อความ

ตรวจ first/next/end page, filter/sort transition และ insert/delete ระหว่าง page หาก endpoint อ้างว่ารองรับข้อมูลเปลี่ยนตามเวลา.
