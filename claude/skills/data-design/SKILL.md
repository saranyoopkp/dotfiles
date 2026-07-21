---
name: data-design
description: หลักการออกแบบ data — DB schema (normalize, enum, FK+index, JSONB, id strategy), cache (invalidate/staleness/miss), queue/async (idempotent consumer, retry+dead-letter, atomic claim), dataflow (single writer, derived-recompute, external sync). ใช้เมื่อออกแบบ/แก้ schema ตาราง migration index, เพิ่ม cache, ทำ message queue/worker/consumer, วาง data pipeline/sync, หรือแตะไฟล์ .sql/schema/migration. โหลดก่อนตัดสินใจเรื่องโครงสร้างข้อมูล
---

# Data Design (DB / Cache / Queue / Dataflow)

หลักการระดับ principle ไม่ผูก technology — การเลือก tech และ pattern หนัก (CQRS ฯลฯ)
เป็น per-project decision → จดใน CLAUDE.md ของ repo พร้อมเหตุผล

## Schema
- **normalize by default** — denormalize ได้เมื่อมีเหตุผล (perf ที่วัดแล้ว) และ*จดเป็น
  decision* พร้อมวิธี keep-in-sync; ไม่ denormalize เพราะขี้เกียจ join
- **enum จริง ไม่ใช่ string flag** — สถานะ/ประเภท ใช้ enum type หรือ lookup table;
  string ลอย ๆ = typo กลายเป็น state ใหม่โดยไม่มีใครรู้
- **FK constraint + created/updated timestamps ทุกตาราง** — ให้ DB บังคับ integrity
  ไม่ใช่หวังว่า app layer จะไม่พลาด; ลบ/แก้ระบุ on-delete behavior ชัด;
  **FK ที่ถูก join/cascade ต้องมี index** (Postgres ไม่สร้างให้เอง — self-FK ไร้ index
  = DELETE กลายเป็น O(n²) เงียบ ๆ)
- **schemaless field (JSONB ฯลฯ) สำหรับข้อมูลที่ variable จริง** — พร้อมจด shape ที่
  คาดหวังไว้; field ที่ต้อง filter/join/aggregate บ่อย = column จริง ไม่ใช่ฝังใน JSON
- id strategy ตัดสินใจตั้งแต่แรก (auto-increment vs UUID vs external id) + unique
  constraint บน external ref ทุกตัวที่ import เข้ามา (กัน duplicate ตั้งแต่ DB)

## Cache
- **ห้ามใส่ cache จนกว่าจะตอบครบ 3 ข้อ**: (1) invalidate เมื่อไหร่/ด้วยอะไร
  (2) ทน staleness ได้แค่ไหน (3) cache miss แล้ว path เป็นยังไง
- **cache = สำเนา ไม่ใช่ source of truth** — เขียนลง store จริงก่อนเสมอ แล้ว cache
  ตาม; ระบบต้องถูกต้อง (แค่ช้าลง) เมื่อ cache หายทั้งก้อน
- key มี naming convention + TTL ทุกตัว (ไม่มี key อมตะที่ไม่มีใครรู้ว่าใครสร้าง)

## Queue / Async
> async reliability ทั่วไป (idempotent consumer, retry+backoff+max, dead-letter,
> safety-net poller) = อยู่ใน rule `webhook-integration` (always-on) แล้ว — ไม่ซ้ำที่นี่
> single-home. ที่เหลือคือส่วน DB/worker-specific:
- อย่า queue สิ่งที่ caller ต้องการคำตอบ sync — queue คือ "ทำให้เสร็จในที่สุด"
  ไม่ใช่ "ทำให้เสร็จเดี๋ยวนี้แบบเนียน ๆ"
- **การ claim งานต้อง atomic** — lock แบบ `FOR UPDATE SKIP LOCKED` มีผลเฉพาะ*ใน
  transaction* (นอก txn = สอง worker คว้างานเดียวกัน = double-send); ใช้
  single-statement claim + visibility timeout และระวัง worker process ซ้ำ

## Dataflow
- **fact หนึ่ง มี writer หลักเดียว** — สองระบบเขียน field เดียวกัน = conflict รอวันเกิด;
  ถ้าจำเป็นต้องนิยามว่าใครชนะ (last-write-wins? source-priority?) และจดไว้
- **derived data ต้อง recompute ได้จาก source เสมอ** — ยอดรวม/รายงาน/สถิติ
  ที่คำนวณเก็บไว้ ต้องมีทางคำนวณใหม่จากข้อมูลดิบ (จุดนี้คือเส้นแบ่ง data กับ garbage)
- external data ที่ sync เข้ามา: เก็บ raw + upsert on external id + timestamp การ sync (replay/ตรวจย้อนได้)

เริ่มระบบใหม่: วาด dataflow ก่อน (ข้อมูลเกิดไหน ไหลไปไหน ใครเขียน/อ่าน) แล้วค่อยลง schema
— ตารางที่ออกแบบจาก flow จริงแทบไม่ต้อง refactor
