---
name: ui-ux-baseline:content-copy
description: ออกแบบหรือแก้ข้อความ UI ทั่วไป เช่น heading, label, button, placeholder, helper text, tooltip, empty/help copy และ terminology โดยรักษาความหมาย, accessibility และ project voice. ใช้เมื่อโจทย์หลักคือ wording หรือ content clarity; ไม่ใช้แทน feedback-notifications, content-localization หรือ visual-direction
---

# UI Content Copy

กำหนดข้อความจาก user goal, audience, context และ action ที่ผู้ใช้ต้องทำ; ตรวจศัพท์และ voice/tone
ของ project ก่อนเปลี่ยน wording. ถ้า project ไม่ได้กำหนดไว้ ให้ใช้ professional-neutral: ชัด สุภาพ
กระชับ และไม่เป็นกันเองเกินไป.

- ให้ข้อความแต่ละชิ้นมีหน้าที่เดียว และวางสิ่งที่ผู้ใช้ต้องรู้หรือทำก่อนรายละเอียดรอง; ใช้ progressive
  disclosure กับคำอธิบายเสริม แต่ไม่ซ่อน cost, consent, error หรือ recovery สำคัญไว้ใน tooltip อย่างเดียว
- ใช้คำเรียก action, object และสถานะให้คงที่ตลอด flow; label และ button ต้องบอกสิ่งที่จะเกิดขึ้นจริง
  และไม่ใช้ placeholder เป็น label หลัก
- ตัด filler, jargon และคำอธิบายที่ไม่ช่วยตัดสินใจ; อย่าประดิษฐ์ claim, promise หรือ terminology ใหม่
  โดยไม่มีหลักฐานจาก product/domain
- copy ที่เป็น visible label, accessible name, instruction หรือ state ต้องยังเข้าใจได้เมื่ออ่านข้อความ
  แยกจาก layout; รายละเอียดของ semantic/keyboard/focus อยู่ที่ `interaction-a11y`
- ถ้าการเปลี่ยน wording กระทบความหมาย, consent, risk, public terminology หรือ brand อย่างมีนัยสำคัญ
  ให้เสนอทางเลือกสั้น ๆ พร้อม trade-off ก่อนแก้; การเกลาคำเล็กน้อยใน scope ที่ชัดทำต่อได้

## Boundary

- error, validation, success, warning, notification และ recovery channel/content → `feedback-notifications`
- translation, locale, pluralization, formatting, text expansion และ RTL → `content-localization`
- visual identity, composition หรือ aesthetic direction → `visual-direction`
- button/input/menu/dialog semantics และ accessible interaction → `interaction-a11y`

ก่อนส่งมอบ ตรวจ terminology ที่แก้, ข้อความยาว/สั้นที่เกิดได้จริง และความสอดคล้องระหว่าง label,
action และผลลัพธ์ โดยไม่เปลี่ยน product behavior เพียงเพื่อให้ copy ดูดี.
