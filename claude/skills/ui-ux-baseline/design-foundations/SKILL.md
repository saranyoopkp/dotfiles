---
name: ui-ux-baseline:design-foundations
description: กำหนดหรือแก้ shared visual foundations เช่น semantic color/contrast, typography roles/scale, spacing/grid, radius/elevation, iconography, theme/density และ motion token ใช้เมื่อค่าพื้นฐานเหล่านี้เปลี่ยนข้ามหลายหน้าหรือ component; ไม่ใช้ปรับเฉพาะหน้าจอหรือเปลี่ยน component API
---

# Design Foundations

Foundation คือค่าร่วมที่ทำให้ UI สม่ำเสมอและเข้าถึงได้ ไม่ใช่ข้ออ้างให้เปลี่ยน brand หรือสร้าง
style guide ใหม่ทุกงาน. ใช้ค่าที่มีอยู่ก่อน และเพิ่ม/เปลี่ยนเมื่อมี consumer ร่วมกับ semantic ที่ชัดเจน.

- กำหนด token ตามเจตนา เช่น surface, text, action, feedback และ focus แทนชื่อสีหรือค่าดิบ; state สำคัญต้องไม่ต่างกันด้วยสีอย่างเดียว และต้องรักษา contrast ที่เหมาะกับบริบท
- กำหนดบทบาทและ scale ของ type, spacing, grid, radius, elevation และ icon ให้ช่วย hierarchy; อย่าให้หน้าจอหนึ่งสร้างค่าพิเศษถ้า semantic เดิมใช้ได้
- theme หรือ density ต้องคงความหมายของ semantic role, contrast และ focus treatment; หลีกเลี่ยง override เฉพาะหน้าจอที่ทำให้ระบบสลาย
- กำหนด duration/easing เป็น shared token เฉพาะเมื่อมี use case ร่วม; เหตุผล, trigger และ interruption ของ motion อยู่ `motion-microinteractions`
- ก่อนเปลี่ยน foundation ที่ใช้แล้ว ให้ระบุ consumer, theme/viewport ที่กระทบ, migration และ visual regression ที่ต้องตรวจ

`visual-direction` เป็น owner ของ identity และ direction ใหม่; `visual-polish` ปรับหน้าจอเดิมโดยใช้
foundation; `layout-navigation` เป็น owner ของ composition ของหน้า; `interaction-a11y` เป็น owner ของ
semantic HTML, keyboard และ focus behavior; `design-system` เป็น owner ของ component API และ variant.

ก่อนส่งมอบ ตรวจ representative screen ที่ได้รับผล รวมถึง theme/contrast/focus treatment ที่เกี่ยวข้อง
จาก artifact จริงเมื่อ environment รองรับ; หากตรวจไม่ได้ ให้ระบุขอบเขตแทนการอ้างว่าผ่าน.
