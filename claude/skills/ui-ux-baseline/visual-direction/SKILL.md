---
name: ui-ux-baseline:visual-direction
description: กำหนด visual direction สำหรับหน้าใหม่, landing page, marketing surface, redesign ที่เปลี่ยนภาพลักษณ์ หรือหน้าเดิมที่ผู้ใช้ขอเสนอ design/ทำให้สวยขึ้น, modern, premium หรือมี character โดยสืบทอด visual language ที่มีหลักฐานอยู่แล้วเมื่อเหมาะสม. ใช้เมื่อโจทย์ต้องการ aesthetic direction, brand expression, typography, palette หรือ layout concept; ไม่ใช้กับการ polish เล็ก ๆ ที่ต้องคง visual direction, information architecture และ behavior เดิม
---

# Visual Direction

## Intent boundary

- หน้าเดิมที่ผู้ใช้ขอเพียง clean, simplify, อ่านง่าย หรือเนี้ยบขึ้น โดยคง visual direction, IA และ
  behavior เดิม → ใช้ `visual-polish`
- หน้าเดิมที่ผู้ใช้ขอ “สวยขึ้น”, modern, premium, distinctive, เสนอ design หรือเปิดให้เปลี่ยน
  composition/identity → ใช้ skill นี้ก่อน แม้ยังไม่มีการเปลี่ยน behavior
- ถ้าเจตนาด้านภาพลักษณ์ยังไม่ชัด ให้เสนอ direction capsule สั้น ๆ ก่อนแก้ code; ห้าม default ไป
  `visual-polish` เพียงเพราะเป็นหน้าจอเดิม

## Creative direction without conservative bias

- คำว่า operational, table หรือหน้าจอเดิมเป็น context ไม่ใช่ hard gate ให้ทำได้แค่ polish. เมื่อผู้ใช้
  ขอให้สวยขึ้น, modern, premium, distinctive, มี character หรือขอเสนอ design ให้เปิดพื้นที่เปลี่ยน
  composition, grouping, visual anchor และ hierarchy ได้ โดยรักษา semantics, behavior, accessibility
  และ contract ที่มีอยู่
- ก่อนเลือก direction ให้ตรวจหน้าที่เกี่ยวข้อง, shared tokens/components และ visual decisions ล่าสุดที่
  มีหลักฐาน. ถ้ามี visual language จากหน้าพี่น้องหรืองานก่อนหน้า ให้ต่อยอดให้เป็นระบบเดียวกัน ไม่เริ่ม
  generic ใหม่ และไม่ถือว่าการใช้ของเดิมหมายถึงห้ามสร้าง expression ใหม่
- สำหรับหน้าเดิม ให้ทำ visual audit สั้น ๆ จาก code และ screenshot/runtime เมื่อเข้าถึงได้: ระบุสิ่งที่
  เป็น visual anchor ปัจจุบัน, จุดที่ทำให้หน้าดู generic/แน่น/ไร้น้ำหนัก และ constraint ที่ห้ามเปลี่ยน.
  จากนั้นเสนอ direction ที่มี thesis, composition, type/color roles, visual anchor และลำดับการปรับที่
  เห็นผลจริงก่อนลงมือ
- ถ้าคำขอ creative ชัด อย่าจบด้วยคำว่า clean, readable, consistent หรือ accessible โดยไม่มี point of
  view ทางภาพ. คำเหล่านี้เป็น acceptance floor ไม่ใช่ผลลัพธ์ทั้งหมดของงาน aesthetic
- อย่าใช้ “ห้าม decoration”, “ใช้ pattern เดิม” หรือ “minimal” เป็นเหตุผลปฏิเสธ direction โดยลำพัง;
  ให้ตรวจว่าองค์ประกอบนั้นช่วย thesis และ product goal หรือไม่ แล้วอธิบาย trade-off แทน

เป้าหมายคือ visual identity ที่มาจากโจทย์จริง ไม่ใช่ความแปลกเพื่อความแปลก. งาน operational,
settings, table และ flow ที่ใช้ซ้ำยังต้องมี clarity และ consistency เป็น floor; เมื่อ brief ขอ creative
direction ให้เลือก expression และ signature ที่ช่วย product goal ได้ ไม่ใช่ตัดทิ้งเพียงเพราะ skill นี้
ถูกโหลด.

## ก่อนเขียน UI

กำหนด **aesthetic thesis** หนึ่งประโยคจาก subject, audience และงานหลักหนึ่งอย่างของหน้านี้. ใช้
context, brand system และ preference ที่มีอยู่ก่อนเดา; ถ้าโจทย์เปิดกว้าง ให้เสนอ direction ที่มีเหตุผล
และแยก decision ที่ผู้ใช้ต้องเป็นคนเลือกออกจากรายละเอียดที่ agent ตัดสินใจได้เอง.

## Proposal gate

- ถ้า brief ยังไม่ได้เลือก aesthetic direction และมีหลายทางที่เปลี่ยน composition, identity, approach
  หรือ scope อย่างมีนัยสำคัญ ให้หยุดหลัง audit แล้วเสนอ 2–3 direction ที่แตกต่างกันพอให้เลือกได้.
- แต่ละตัวเลือกควรสรุป thesis, visual anchor, key moves, สิ่งที่คงไว้, trade-off และขอบเขตงาน. ให้
  recommendation ได้ แต่ติดป้ายว่าเป็น recommendation ไม่ใช่การอนุมัติแทนผู้ใช้.
- ต้องเป็น proposal ที่เห็นภาพและนำไปตัดสินใจได้จริง ไม่ใช่เพียงบอกว่า “งานนี้เป็น creative” หรือถาม
  ผู้ใช้กว้าง ๆ ว่าอยากได้แบบไหน. Agent ต้องสร้าง candidates จาก brief, evidence และ constraints เอง.
- คำขอ “ทำให้สวยขึ้น”, “modern” หรือ “มี character” เพียงอย่างเดียว อนุญาตให้สำรวจและเสนอ ไม่ใช่
  authorization ให้เลือก direction แล้วเขียน code หรือทำ mutation ทันที. รอผู้ใช้เลือกหรือระบุ direction
  ก่อนลงมือ.
- ถ้าผู้ใช้ระบุ/เลือก direction แล้ว หรือเป็น polish เล็ก ๆ ที่ไม่เปิด creative decision ใหม่ ให้ทำต่อได้
  โดยรักษา hard constraints และ visual language ที่ตกลงไว้.

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
