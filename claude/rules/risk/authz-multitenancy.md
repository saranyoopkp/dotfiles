# Authorization / Tenant / Role / Permission

ระบบที่มี tenant หรือ role — หลักการเหล่านี้คือ baseline ไม่ใช่ optional:

## กฎเหล็ก
- **Enforce ที่ server เสมอ** — FE ซ่อนปุ่ม/เมนู = UX เท่านั้น ไม่ใช่ security;
  ทุก endpoint ตรวจสิทธิ์เองแม้ UI จะไม่มีทางกดถึง
- **Deny by default** — endpoint ที่ไม่ระบุสิทธิ์ = ปฏิเสธ ไม่ใช่ปล่อยผ่าน;
  เพิ่ม endpoint ใหม่แล้วลืมประกาศสิทธิ์ต้อง fail-closed
- **Tenant id มาจาก auth context เท่านั้น** — ห้ามรับจาก client (body/query/header)
  แล้วเชื่อ; ทุก query ต้อง scope ด้วย tenant ของ user เสมอ (กัน cross-tenant IDOR:
  เดา id ของ tenant อื่นแล้วต้องได้ 404/403 ไม่ใช่ข้อมูล)

## โครงสร้าง
- **Check แบบรวมศูนย์** — middleware/guard/policy layer จุดเดียว ไม่ใช่ if-else
  โรยตามโค้ด; business logic ไม่ควรรู้จักชื่อ role
- **เช็ค permission/capability ไม่ใช่ role string** — `can('order.delete')` ไม่ใช่
  `role === 'ADMIN'` — เริ่มด้วย RBAC ง่าย ๆ ได้ แต่ mapping role→permission
  ต้องอยู่ที่เดียว จะได้เพิ่ม role/เปลี่ยนสิทธิ์โดยไม่ไล่แก้ทั้ง codebase
- membership model: user↔tenant พร้อม role ต่อ tenant — เว้นแต่ requirement ระบุชัดว่า single-tenant ตลอดชีพ
- **UI สอดคล้องกับสิทธิ์**: ซ่อน/disable สิ่งที่ทำไม่ได้ (ไม่ใช่กดแล้ว 403)
  แต่จำไว้ว่านี่คือชั้น UX — server คือชั้นจริง

## ก่อนปิดงาน
- **ทดสอบ matrix**: endpoint สำคัญ × ทุก role (รวม "ไม่ login") — ยืนยันว่า
  role ที่ไม่มีสิทธิ์ได้ 401/403 จริง และลอง cross-tenant access อย่างน้อยหนึ่งเคส
- privileged action (แก้สิทธิ์, ลบข้อมูล, การเงิน) → audit log ว่าใครทำอะไรเมื่อไหร่
- มี seed/fixture ครบทุก role ให้ทดสอบได้ทันที ไม่ใช่มีแต่ admin

เริ่มระบบใหม่: ถาม requirement เรื่อง tenant/role ตั้งแต่ต้น (single หรือ multi-tenant?
กี่ role? ใครจัดการสิทธิ์?) — retrofit tenant isolation ทีหลังแพงมาก
