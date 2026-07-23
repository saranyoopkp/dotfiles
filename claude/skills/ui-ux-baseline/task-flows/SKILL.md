---
name: ui-ux-baseline:task-flows
description: ออกแบบ user-initiated task flow เช่น form submit, inline edit, toggle, delete, confirm, retry และ async mutation ใช้เมื่อผู้ใช้สั่งให้ระบบสร้าง แก้ เปลี่ยนสถานะ หรือดำเนินการกับข้อมูล
---

# Task Flows

ออกแบบ flow เป็น `intent → validation/confirmation → pending → result → recovery` ไม่ใช่แค่ปุ่มที่เรียก mutation

- ก่อนส่ง แสดง validation ใกล้จุดที่แก้ได้ และรักษาค่าที่ผู้ใช้กรอกไว้เมื่อ server ปฏิเสธ
- ระหว่าง pending ป้องกัน duplicate submission ตาม semantics ของ action; อย่าปิดทุกอย่างจนผู้ใช้ไม่รู้ว่ายังเกิดอะไรขึ้น
- success ต้องสะท้อนผลที่เกิดขึ้นจริงใน UI; failure ต้องบอกผลกระทบและทาง recover/retry โดยไม่ทำให้ผู้ใช้เดาว่างานสำเร็จหรือไม่ — เลือก channel ตาม `ui-ux-baseline:feedback-notifications`
- optimistic update ใช้ได้เมื่อ rollback/reconciliation ชัดเจน; ผลลัพธ์จาก server คือ source of truth เมื่อมีความขัดแย้ง
- action ที่ destructive, irreversible หรือเปลี่ยนสถานะสำคัญ ต้องบอก consequence และขอ confirm ในจังหวะที่ผู้ใช้ยังยกเลิกได้

ทุก flow ที่ทำ mutation ต้องทดสอบอย่างน้อย happy path, pending/duplicate intent และ failure/retry ที่เกิดได้จริง
