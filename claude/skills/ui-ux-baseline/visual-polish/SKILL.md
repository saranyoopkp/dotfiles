---
name: ui-ux-baseline:visual-polish
description: Polish visual ของหน้าจอ/component เดิม เช่น spacing, typography, color hierarchy, density และ alignment โดยคง brand, information architecture และ behavior; ไม่ใช้กับ rebrand/redesign ใหญ่
---

# Visual Polish

คง brand/flow เดิมก่อน: งานนี้ปรับการรับรู้และความอ่านง่าย ไม่ใช่ข้ออ้างให้เปลี่ยน
information architecture, copy, interaction หรือ product behavior เงียบ ๆ. ถ้าต้องเปลี่ยนสิ่งเหล่านั้น
ให้อ่าน child skill ที่เป็น owner และผ่าน behavioral-change gate.

- เริ่มจากลำดับการอ่านจริง: primary task, primary action, context และ secondary detail ต้องแยกกันเห็นได้ก่อนปรับสีหรือ decoration
- แก้ตามลำดับ: hierarchy → grid/alignment → spacing/density → typography → color/contrast → surface/detail; อย่าทาสีทับปัญหา layout หรือ content hierarchy
- ใช้ token, component และ visual language เดิมก่อน; สี/spacing/type/theme ใหม่ที่มี consumer ร่วมเป็น owner ของ `design-foundations` และ shared component/variant เป็น owner ของ `design-system` ไม่ใช่แก้เฉพาะหน้าจอโดยพลการ
- UI effect เช่น shadow, blur, gradient, overlay, opacity หรือ texture ต้องบอกลำดับชั้น, depth, grouping หรือ state จริง; ห้ามใช้เป็นหมอกบัง hierarchy/contrast หรือทำทุก surface ให้เด่นเท่ากัน
- ความเนี้ยบต้องไม่ลด contrast, focus-visible, tap target, responsive priority หรือสถานะที่ผู้ใช้พึ่งพา; Visual Design ที่อ่านง่ายกว่าแต่ state หายไม่ใช่ polish
- ตรวจจากหน้าจอจริงหรือ screenshot เปรียบเทียบที่ viewport สำคัญเมื่อ environment รองรับ; ถ้าไม่มี visual artifact ให้ระบุข้อจำกัด ไม่อ้างว่า visual regression ผ่าน

งานที่ต้องเปลี่ยน identity/brand direction อ่าน `visual-direction`; effect ที่เปลี่ยนตามเวลา,
interaction หรือ state transition อ่าน `motion-microinteractions`; interaction/accessibility, layout และ
feedback ยังคงอยู่กับ child owner เดิม.
