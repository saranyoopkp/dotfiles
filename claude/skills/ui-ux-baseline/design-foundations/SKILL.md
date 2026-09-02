---
name: ui-ux-baseline:design-foundations
description: กำหนดหรือแก้ shared visual foundations เช่น semantic color/contrast, typography roles/scale, spacing/grid, radius/elevation, iconography, theme/density และ motion token รวมถึงเลือก icon library หรือแทน decorative emoji ใน UI ใช้เมื่อค่าพื้นฐานเปลี่ยนข้ามหลายหน้าหรือมีการตัดสินใจเรื่อง icon/emoji; ไม่ใช้ปรับเฉพาะหน้าจอทั่วไปหรือเปลี่ยน component API
---

# Design Foundations

Foundation คือค่าร่วมที่ทำให้ UI สม่ำเสมอและเข้าถึงได้ ไม่ใช่ข้ออ้างให้เปลี่ยน brand หรือสร้าง
style guide ใหม่ทุกงาน. ใช้ค่าที่มีอยู่ก่อน และเพิ่ม/เปลี่ยนเมื่อมี consumer ร่วมกับ semantic ที่ชัดเจน.

- กำหนด token ตามเจตนา เช่น surface, text, action, feedback และ focus แทนชื่อสีหรือค่าดิบ; state สำคัญต้องไม่ต่างกันด้วยสีอย่างเดียว และต้องรักษา contrast ที่เหมาะกับบริบท
- กำหนดบทบาทและ scale ของ type, spacing, grid, radius และ elevation ให้ช่วย hierarchy; อย่าให้หน้าจอหนึ่งสร้างค่าพิเศษถ้า semantic เดิมใช้ได้
- ใช้ icon library และ icon set ที่ตรวจพบใน repo ก่อน โดยรักษา semantic, size, stroke/optical weight และ alignment ให้สม่ำเสมอ; ห้ามสมมติชื่อ library, วาด SVG ใหม่ หรือเพิ่ม dependency เงียบ ๆ เมื่อยังไม่พบของเดิม
- **ห้ามใช้ emoji ตกแต่ง UI โดย default**. เมื่อพบ decorative emoji ให้เสนอ icon ที่มี semantic ตรงจาก library เดิมแทน; หาก repo ยังไม่มี icon library ให้เสนอทางเลือกและต้นทุนก่อนเพิ่ม dependency. ใช้ emoji ได้เมื่อเป็น user content, brand requirement หรือผู้ใช้ขอชัดเจนเท่านั้น
- theme หรือ density ต้องคงความหมายของ semantic role, contrast และ focus treatment; หลีกเลี่ยง override เฉพาะหน้าจอที่ทำให้ระบบสลาย
- กำหนด duration/easing เป็น shared token เฉพาะเมื่อมี use case ร่วม; เหตุผล, trigger และ interruption ของ motion อยู่ `motion-microinteractions`
- ก่อนเปลี่ยน foundation ที่ใช้แล้ว ให้ระบุ consumer, theme/viewport ที่กระทบ, migration และ visual regression ที่ต้องตรวจ

## Refactor Icon & Emoji

ก่อนแทนของเดิม ให้ inventory usage และจำแนกเป็น decoration, action, state, user content หรือ
brand content; ห้าม bulk-replace user/brand content. ทำ mapping จาก emoji/icon เดิมไป semantic icon
ที่ตรวจพบใน library ของ repo แล้ว migrate เป็น shared primitive หรือทีละ surface ที่ตรวจได้ โดยคง
visible label, accessible name, interaction state และ layout. อย่าปนการเปลี่ยน icon กับการเปลี่ยน
meaning/copy; semantic change ต้องใช้ authorization และ impact rules ใน
`claude/rules/core/change-control.md`.

ลบของเดิมเมื่อค้น consumer แล้วไม่เหลือ และตรวจ screenshot ของ state/viewport ที่เกี่ยวข้องพร้อม
keyboard/accessibility ตาม `interaction-a11y`; หาก migration ยังไม่ครบให้ระบุรายการที่เหลือและ owner.

`visual-direction` เป็น owner ของ identity และ direction ใหม่; `visual-polish` ปรับหน้าจอเดิมโดยใช้
foundation; `layout-navigation` เป็น owner ของ composition ของหน้า; `interaction-a11y` เป็น owner ของ
semantic HTML, keyboard และ focus behavior; `design-system` เป็น owner ของ component API และ variant.

ก่อนส่งมอบ ตรวจ representative screen ที่ได้รับผล รวมถึง theme/contrast/focus treatment ที่เกี่ยวข้อง
จาก artifact จริงเมื่อ environment รองรับ; หากตรวจไม่ได้ ให้ระบุขอบเขตแทนการอ้างว่าผ่าน.
