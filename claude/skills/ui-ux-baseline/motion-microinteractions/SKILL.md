---
name: ui-ux-baseline:motion-microinteractions
description: ออกแบบหรือแก้ motion design, transition, animation, progress, reveal, scroll behavior และ microinteraction ที่สื่อ state/feedback ใช้เมื่อการเคลื่อนไหวเป็นส่วนหนึ่งของ UI behavior ไม่ใช่เพียง static Visual Design
---

# Motion Design & Microinteractions

motion ต้องสื่อ hierarchy, spatial continuity, state transition, pending/progress หรือผลของ action; decoration
ที่ไม่รับใช้สิ่งใดให้ตัดออก. กำหนดก่อนเขียนว่า `trigger → state ที่สื่อ → motion → จบ/ถูกขัดจังหวะอย่างไร`.

- user action ต้องเริ่มตอบสนองทันที; animation ห้ามบัง pending, error หรือทำให้ผู้ใช้เข้าใจว่างานเสร็จแล้วก่อน server ยืนยัน
- microinteraction หนึ่งชิ้นควรตอบคำถามเดียว เช่น กดได้ไหม, กำลังทำอะไร, สำเร็จหรือไม่; อย่าให้หลาย element ขยับแข่งกันจน attention กระจาย
- motion จาก event ที่เข้ามาเองห้ามขโมย focus, เปลี่ยน scroll position หรือรบกวนการอ่าน; chat/feed/realtime อ่าน `realtime-conversation` เพิ่ม
- เคารพ `prefers-reduced-motion`: ลดหรือแทน movement ด้วย state/opacity/instant change โดยยังคงข้อมูล, progress และทางสั่งงานครบ; accessibility semantics/focus อยู่ `interaction-a11y`
- เลี่ยง animation ที่ทำให้ layout shift หรือ interaction target เคลื่อนใต้ pointer/focus; ใช้ implementation ที่ลื่นตาม stack เมื่อพิสูจน์ได้ ไม่ optimize จากความเชื่อ
- duration/easing ที่ใช้ร่วมกันเป็น token อยู่ `design-foundations`; skill นี้เป็น owner ของเหตุผล, trigger และ behavior ของ motion ไม่ใช่แค่ค่าตัวเลข

ตรวจ interaction จริงหรือ recording เมื่อทำได้ เพราะ screenshot ยืนยัน timing, interruption และ reduced-motion ไม่ได้. pending/success/failure อ่าน `task-flows` หรือ `feedback-notifications`; skill นี้ไม่เป็น owner ของ business flow.
