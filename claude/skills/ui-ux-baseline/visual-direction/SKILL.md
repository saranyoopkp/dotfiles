---
name: ui-ux-baseline:visual-direction
description: กำหนด visual direction สำหรับหน้าใหม่, landing page, marketing surface, redesign ที่เปลี่ยนภาพลักษณ์ หรือหน้าเดิมที่ผู้ใช้ขอเสนอ design/ทำให้สวยขึ้น, modern, premium หรือมี character. ใช้เมื่อโจทย์ต้องการ aesthetic direction, brand expression, typography, palette หรือ layout concept; ไม่ใช้กับการ polish เล็ก ๆ ที่ต้องคง visual direction, information architecture และ behavior เดิม
---

# Visual Direction

## Intent boundary

- หน้าเดิมที่ผู้ใช้ขอเพียง clean, simplify, อ่านง่าย หรือเนี้ยบขึ้น โดยคง visual direction, IA และ
  behavior เดิม → ใช้ `visual-polish`
- หน้าเดิมที่ผู้ใช้ขอ “สวยขึ้น”, modern, premium, distinctive, เสนอ design หรือเปิดให้เปลี่ยน
  composition/identity → ใช้ skill นี้ก่อน แม้ยังไม่มีการเปลี่ยน behavior
- ถ้าเจตนาด้านภาพลักษณ์ยังไม่ชัด ให้เสนอ direction capsule สั้น ๆ ก่อนแก้ code; ห้าม default ไป
  `visual-polish` เพียงเพราะเป็นหน้าจอเดิม

เป้าหมายคือ visual identity ที่มาจากโจทย์จริง ไม่ใช่ความแปลกเพื่อความแปลก. งาน operational,
settings, table และ flow ที่ใช้ซ้ำชนะด้วยความชัดเจนและ consistency; ไม่ต้องสร้าง signature element
เพียงเพราะ skill นี้ถูกโหลด.

## ก่อนเขียน UI

กำหนด **aesthetic thesis** หนึ่งประโยคจาก subject, audience และงานหลักหนึ่งอย่างของหน้านี้. ใช้
context, brand system และ preference ที่มีอยู่ก่อนเดา; ถ้าโจทย์เปิดกว้าง ให้เลือก direction ที่มีเหตุผล
และบอกเฉพาะเมื่อเป็น decision ที่ผู้ใช้ต้องตัดสินใจ.

สำหรับหน้าใหม่หรือ redesign ใหญ่ ให้ทำ direction capsule สั้น ๆ ก่อนเขียน code:

- **color**: 3–6 semantic roles หรือ token ที่สอดคล้องกับ foundation เดิม
- **type**: display/body/utility roles เท่าที่เนื้อหาต้องใช้; typography ต้องช่วย hierarchy ไม่ใช่เป็นการตกแต่งลอย ๆ
- **layout**: ลำดับการอ่านและ hero/primary action ที่พิสูจน์ได้จากงานหลักของหน้า
- **signature**: องค์ประกอบเด่นเพียงหนึ่งอย่างที่มาจาก subject หรือ product จริง; อาจไม่มีเมื่อ functional clarity สำคัญกว่า

ก่อนสร้าง ให้ตรวจแผนกับ brief: ถ้าเปลี่ยน subject แล้วหน้าตายังเหมือนเดิม, หรือเลือก bento card,
gradient hero, metric strip, badge/เลขลำดับเพียงเพราะเป็น default ให้แก้ direction แล้วค่อยลงมือ. ใช้
โครงสร้าง, label, divider และ motion เพื่อบอกข้อมูลจริง ไม่ใช่เติม texture.

## ขณะเขียนและตรวจ

- ใช้ copy เป็นส่วนของ interaction: เรียก action เดียวกันตลอด flow (`Publish` → `Published`), บอกสิ่งที่ผู้ใช้ควบคุมได้ และเขียน error/empty state ให้มีทางไปต่อ
- ใช้ motion เป็นจังหวะเดียวที่รับใช้ hierarchy หรือ feedback; ตัด decoration ที่ไม่รับใช้ thesis และให้ `interaction-a11y` เป็นเจ้าของ reduced-motion/focus/keyboard
- ทบทวน hierarchy, spacing, type, contrast, responsive layout และ signature element จากภาพจริงเมื่อ environment รองรับ screenshot; ถ้าไม่มีภาพจริง ให้ระบุข้อจำกัดแทนการอ้างว่า visual QA ผ่าน
- องค์ประกอบ interactive, resource state, mutation, feedback, collection หรือ realtime flow ต้องอ่าน child skill ที่ตรงเพิ่ม; skill นี้ไม่แทน functional UX
- เมื่อ direction ต้องสร้างหรือเปลี่ยน visual role ที่ใช้ข้ามหน้า ให้กำหนดเป็น foundation กับ `design-foundations`; งาน polish เฉพาะหน้าจออยู่ `visual-polish`
