# Authorization / Tenant / Permission

เมื่องานมี identity, role, permission หรือ tenant:

- Enforce authorization ที่ server และ deny by default; UI hide/disable เป็น UX ไม่ใช่ security boundary.
- Tenant/actor มาจาก trusted auth context ไม่เชื่อ client input; ทุก read/write scope ด้วย tenant และ
  cross-tenant identifier ต้องไม่คืนข้อมูล.
- รวม policy/permission mapping ไว้ที่ owner เดียว; business logic ใช้ capability ไม่โรย role string.
- Test allowed, denied, unauthenticated และ cross-tenant path ที่มีความเสี่ยงจริง.
- Privileged action เรื่อง permission, data หรือ money ต้องมี actor/action/result audit โดยไม่ log secret/PII เกินจำเป็น.
