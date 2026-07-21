# Performance Discipline

กันปัญหาที่ต้องมาไล่ตบทีหลัง — เช็คตัวเองก่อนส่งงานทุกครั้ง:

## Data access
- **ห้าม query ใน loop (N+1)** — join/batch/`IN` เสมอ; ORM relation ให้ eager load เมื่อรู้ว่าใช้
- **list ต้องมี pagination/limit ตั้งแต่แรก** — ห้าม "โหลดทั้งหมด" แม้ตอนนี้ข้อมูลน้อย
  (chat history, log, order list = ตัวอย่างคลาสสิกที่โตแล้วพัง)
- query บน column ที่ filter/sort บ่อย → พิจารณา index และบอกไว้ใน migration
- select เฉพาะ field ที่ใช้เมื่อ payload ใหญ่ (โดยเฉพาะ list ที่มี blob/text ยาว)

## Runtime
- งานที่อาจเกิน ~1s (ส่งเมล, gen ไฟล์, เรียก API ภายนอก) → ห้าม block request;
  ทำ async/queue/fire-and-forget แล้วรายงานสถานะ
- อะไรที่เรียกซ้ำด้วย input เดิมและแพง → พิจารณา cache (พร้อมตอบว่า invalidate เมื่อไหร่)
- external call ทุกตัวมี timeout — ห้ามรอ indefinite

## Frontend
- รายการยาว → virtualize หรือ paginate, ไม่ render หมดใน DOM
- asset/รูป → ระบุขนาด (กัน layout shift), lazy load ส่วนใต้ fold
- อย่า re-render ทั้ง tree จาก state ที่เปลี่ยนถี่ (พิมพ์, scroll) — แยก scope ให้แคบ

trade-off กับความเรียบง่าย → บอกให้ user เลือก อย่า premature-optimize เอง —
แต่ pagination/N+1/timeout คือ baseline ไม่ใช่ optimization
