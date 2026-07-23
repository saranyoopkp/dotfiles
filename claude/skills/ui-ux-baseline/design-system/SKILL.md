---
name: ui-ux-baseline:design-system
description: ออกแบบหรือแก้ shared UI component, primitive, component API และ variant ใช้เมื่อเปลี่ยนของที่ใช้ซ้ำหลายหน้าหรือกำลังตัดสินใจว่าจะ abstract feature UI เป็น shared component; ไม่ใช้กำหนด shared visual token หรือ theme
---

# Design System

- แยก feature-specific UI ออกจาก shared primitive: abstract เมื่อมี contract และ use case ร่วมที่พิสูจน์ได้ ไม่ใช่เพียงหน้าตาคล้ายกันครั้งเดียว
- ก่อนเปลี่ยน shared component ให้ระบุ consumer, existing API/variant และ visual/interaction contract ที่ต้องคงไว้; component ที่ใช้แล้วคือ public surface ภายใน
- ใช้ semantic token จาก `design-foundations`; อย่ากำหนดสี, spacing, type scale หรือ theme ใหม่ใน component เฉพาะกิจ. หาก shared foundation ยังไม่มี ให้ส่งงานนั้นไป owner ก่อน
- variant ต้องมีความหมายเชิงพฤติกรรมหรือ semantic ไม่ใช่ prop ที่เปิดให้ผสมทุกอย่าง; feature-specific composition ให้อยู่ใกล้ feature
- shared primitive ต้องรับ semantics, focus, disabled/pending และ responsive behavior ของมันเอง แต่ไม่ควรกลืน business flow ของแต่ละ feature

ก่อนส่งมอบ ตรวจ consumer ที่ได้รับผล, visual/interaction regression ที่เกี่ยวข้อง และ compatibility ของ API/variant; ถ้า behavior เปลี่ยนให้ผ่าน behavioral-change gate ก่อน
