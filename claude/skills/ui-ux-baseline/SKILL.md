---
name: ui-ux-baseline
description: Generic UI/UX quality, content และ visual design baseline สำหรับงาน frontend. ใช้เมื่อวางแผน, ออกแบบ, review หรือแก้ user-facing UI รวมถึงโครงสร้าง, copy, interaction, state, accessibility, responsive behavior, visual consistency หรือ UI ที่สวย, clean, polished และ professional. ให้ route ไป child skill ตาม surface ที่เกี่ยวข้องแบบ on-demand; ไม่โหลด child ทั้งหมดโดย default และ interactive UI ต้องอ่าน ui-ux-baseline:interaction-a11y เสมอ
---

# UI/UX Baseline

ก่อนแก้ UI ให้ระบุว่าผู้ใช้กำลังอ่านเนื้อหา, ดูข้อมูล, สั่งงาน, จัดการข้อมูลหลายรายการ, ติดตามข้อมูลตามเวลา,
หรือใช้ shared primitive แล้วแยก intent ของคำขอด้าน copy/ภาพลักษณ์ก่อนอ่าน child skill: งาน wording ทั่วไปไป
`content-copy`; งาน clean/polish ที่คงโครงเดิมไป `visual-polish`; งานที่ขอเสนอ design, สวยขึ้น, modern,
premium หรือมี character ไป `visual-direction` **ก่อน** ออกแบบหรือเขียนโค้ด

## Generic quality baseline

ใช้เป็นเลนส์ร่วมกับทุกงาน UI/UX ไม่ว่าผู้ใช้จะเรียกว่า “สวย”, “clean”, “polished” หรือขอเพียงแก้
feature; ไม่ใช่คำสั่งให้เติม decoration หรือเปลี่ยน brand โดยอัตโนมัติ

- เริ่มจาก user goal, audience, context และ primary action; ความสวยวัดจาก clarity, hierarchy,
  proportion, consistency และความมั่นใจในการใช้งาน ไม่ใช่จำนวน effect
- ทุกข้อความและองค์ประกอบที่ผู้ใช้เห็นต้องช่วยให้เข้าใจ ตัดสินใจ หรือทำงานต่อได้; ใช้ terminology,
  label และ action ให้สอดคล้องกัน และไม่เพิ่มคำอธิบายเพียงเพราะมีพื้นที่ให้ใส่
- จัดลำดับให้ primary task, สถานะที่ต้องตัดสินใจ และทางไปต่อเห็นก่อนรายละเอียดรอง; ใช้ progressive
  disclosure กับคำอธิบายเสริม แต่ห้ามซ่อน cost, consent, error หรือ recovery สำคัญไว้ใน tooltip อย่างเดียว
- ใช้ brand, token, component และ platform convention ที่มีอยู่ก่อน; อย่าสร้าง pattern สำเร็จรูป,
  palette, spacing หรือ visual treatment ใหม่เพียงเพราะเป็นค่า default ที่ดูทันสมัย
- คิดถึง loading, empty, error, partial, pending, success, disabled, focus และ responsive state ที่
  เกิดได้จริง; visual polish ที่ทำให้ state หรือทางแก้หายไปถือว่าไม่ผ่าน
- รักษา semantic interaction, keyboard/focus, contrast, target size และ reduced motion ตามบริบท;
  accessibility เป็นส่วนหนึ่งของคุณภาพ ไม่ใช่งานเก็บท้าย
- เมื่อ environment รองรับ ให้ตรวจจาก screenshot หรือหน้าจอจริงใน viewport สำคัญ และรายงานข้อจำกัด
  ของหลักฐาน; อย่าอ้างว่า visual quality ผ่านจากการอ่าน code เพียงอย่างเดียว

ส่วนนี้เป็น quality lens กลางเท่านั้น; decision procedure และ implementation detail อยู่ที่ child skill
ตาม ownership ด้านล่าง งานหนึ่งอ่านได้หลาย child เมื่อ data flow หรือ state เรียกร้องจริง.

## Product surface boundary

- User-facing UI สื่อสิ่งที่ผู้ใช้สังเกตได้ ผลกระทบ และสิ่งที่ทำต่อได้. เก็บรายละเอียด implementation, raw code, protocol และ diagnostic evidence ไว้ใน log, test artifact หรือ technical details ที่ผู้ใช้เลือกเปิด เว้นแต่ audience และงานนั้นต้องใช้ข้อมูลดังกล่าวจริง
- หลักฐานทดสอบต้องสังเกต product behavior; ห้ามเปลี่ยน product copy หรือ surface เพียงเพื่อให้ screenshot หรือ test artifact อธิบายตัวเองได้

| ลักษณะงาน | ต้องอ่าน |
|---|---|
| สร้างหน้า/landing page ใหม่, redesign visual identity หรือผู้ใช้ขอเสนอ design, ให้หน้าปัจจุบันสวยขึ้น, modern, premium หรือมี character | `ui-ux-baseline:visual-direction` |
| ปรับ Visual Design หรือ UI effect ของหน้าจอเดิม เช่น clean, simplify, spacing, typography, shadow, blur, gradient, overlay โดยคง brand/flow/IA เดิมและไม่ขอเปลี่ยน direction | `ui-ux-baseline:visual-polish` |
| เพิ่มหรือแก้ transition, animation, progress, reveal, scroll behavior หรือ microinteraction | `ui-ux-baseline:motion-microinteractions` |
| สร้างหรือแก้ shared color/type/spacing/grid/theme/elevation/icon หรือ motion token | `ui-ux-baseline:design-foundations` |
| เลือก icon/icon library, สร้าง icon language หรือพบ decorative emoji ใน UI | `ui-ux-baseline:design-foundations` |
| i18n/localization, translation, locale formatting, text expansion หรือ RTL | `ui-ux-baseline:content-localization` |
| wording ของ UI ทั่วไป เช่น heading, label, button, placeholder, helper text, tooltip, empty/help copy หรือ terminology | `ui-ux-baseline:content-copy` |
| render resource จาก server/client state | `ui-ux-baseline:resource-states` |
| submit, edit, toggle, delete, confirm หรือ retry | `ui-ux-baseline:task-flows` |
| เลือกหรือแก้ toast, banner, inline error, alert, success/failure message หรือ recovery feedback | `ui-ux-baseline:feedback-notifications` |
| search, filter, sort, table/list, pagination, selection หรือ bulk action | `ui-ux-baseline:collections` |
| chat, feed, event stream, presence หรือข้อมูลที่เข้าตามเวลา | `ui-ux-baseline:realtime-conversation` |
| page layout, navigation state, responsive/mobile hierarchy | `ui-ux-baseline:layout-navigation` |
| interactive element ทุกชนิด | `ui-ux-baseline:interaction-a11y` |
| สร้างหรือแก้ shared component, primitive หรือ variant | `ui-ux-baseline:design-system` |

งานเดียวอ่านได้หลาย child ตาม data flow จริง; ห้ามโหลดทั้งหมดเพียงเพื่อทำ checklist และห้ามข้าม child ที่ trigger ตรงเพียงเพราะ UI ดูเล็ก

หาก design ที่ขอมาขัดกับ constraint จาก child skill ให้สรุปผลกระทบและทางเลือกก่อนลงมือ ตาม
authorization และ impact rules ใน `claude/rules/core/change-control.md`
