---
name: ui-ux-baseline:feedback-notifications
description: เลือกและออกแบบ toast, banner, inline error, alert, success/failure message, status announcement และ recovery feedback ใช้เมื่อ UI ต้องบอกผลของ action, error, warning, background completion หรือสถานะที่ผู้ใช้ต้องรับรู้
---

# Feedback & Notifications

เลือก channel จากความเร่งด่วน, ความคงอยู่ของผล, ตำแหน่งที่ผู้ใช้แก้ได้ และว่าผู้ใช้ต้องลงมืออะไรต่อ — อย่าเริ่มด้วย Toast เพราะทำง่าย

| สถานการณ์ | Channel ที่เหมาะเป็น default |
|---|---|
| ผู้ใช้ต้องแก้ field หรือเข้าใจ context เฉพาะจุด | inline validation/error ใกล้จุดนั้น |
| resource หรือหน้าทั้งส่วนใช้ไม่ได้ แต่ยังอยู่ใน context เดิม | inline state หรือ banner ใน context นั้น |
| ผลสั้น, reversible, ไม่ต้องจำ และไม่บล็อก flow | toast/status message |
| warning สำคัญที่ต้องเห็นขณะทำงานข้ามหน้า/ส่วน | persistent banner หรือ notification center ตาม product pattern |
| ต้องตัดสินใจก่อนทำต่อ หรือมีผล destructive/irreversible | dialog/confirmation ก่อน action ไม่ใช่ toast หลังเกิดเหตุ |

## Voice & tone

- User-facing copy ใช้ **professional-neutral** เป็น default: clear, calm, respectful, concise และ actionable;
  หลีกเลี่ยงภาษากันเองเกินไป, slang, มุก หรือ filler เว้นแต่ project convention อนุญาตชัดเจน
- ก่อนเปลี่ยน wording ให้ตรวจ project-owned voice/tone convention ใน `CLAUDE.md` หรือเอกสารที่ชี้ไว้;
  convention ปรับบุคลิกและระดับความเป็นทางการได้ แต่ห้ามลด safety, accuracy, accessibility, consent หรือ recovery ที่จำเป็น
- ปรับน้ำเสียงตาม state: error ต้อง factual/non-blaming/actionable, validation ต้องสั้น, success ยืนยันผลจริง,
  destructive/security/money ต้องชัดและจริงจัง, empty/help เป็นมิตรแต่กระชับ, internal/admin ใช้ศัพท์เทคนิคได้เมื่อ audience เข้าใจ

- map error ตามขอบเขตที่ผู้ใช้แก้ได้เล็กที่สุด: field error → inline ที่ field, cross-field/domain validation → form-level, resource/global failure → context-level; ถ้า response ไม่ระบุ field ห้ามเดา field เอง และอย่าใช้ transient toast แทน feedback ที่ต้องแก้หรือย้อนกลับมาอ่าน
- toast เป็น transient feedback ไม่ใช่ที่ซ่อน error ที่ผู้ใช้ต้องแก้, ผลลัพธ์ที่มีรายละเอียดสำคัญ หรือ failure ที่ต้อง retry; ข้อความที่ต้องอ้างอิงภายหลังต้องมีบ้านที่คงอยู่กว่า
- toast ต้องระบุผลและ object/action ที่เกี่ยวข้องอย่างกระชับ, ไม่หายก่อนอ่าน, มี action/retry เฉพาะเมื่อทำได้จริง และต้อง dedupe/batch เหตุการณ์ burst เพื่อไม่ spam ผู้ใช้
- error ต้องแยกว่าอะไรล้มเหลว, อะไรยังสำเร็จ, ผลต่อข้อมูลคืออะไร และผู้ใช้ทำอะไรต่อได้; partial failure ห้ามสรุปว่า “สำเร็จ” รวม ๆ
- success จาก optimistic UI หรือ background job ต้องไม่สื่อว่า server ยืนยันแล้วจนกว่าจะยืนยันจริง; แสดง pending/reconciliation ให้เหมาะกับความเสี่ยง
- ใช้ semantic status/alert และ announcement ให้เหมาะกับความเร่งด่วน; อย่าพึ่งสี, motion หรือ toast ที่หายเองเป็นช่องทางเดียว และอย่าขโมย focus จากงานที่ผู้ใช้กำลังทำโดยไม่มีเหตุผล

Toast/Banner component API และ visual variant อยู่ที่ `ui-ux-baseline:design-system`; token อยู่ที่ `ui-ux-baseline:design-foundations`; accessibility pattern เชิง interaction อยู่ที่ `ui-ux-baseline:interaction-a11y`. Skill นี้เป็นเจ้าของ **policy การเลือกและเนื้อหาของ feedback**.
