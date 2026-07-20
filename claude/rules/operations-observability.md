# Operations & Observability

ระบบที่รันจริงต้อง "มองเห็นได้" และ "กู้คืนได้" — สองคำถามที่ต้องตอบได้เสมอ:
ตอนนี้ระบบโอเคไหม? / ถ้าพังตอนนี้ กู้ยังไง?

## มองเห็นได้
- **ทุก service มี health endpoint** ที่บอกมากกว่า "process ยังอยู่" — เช็ค dependency
  สำคัญด้วย (DB ต่อได้ไหม) และมีอะไรสักอย่างคอยยิงเช็ค (uptime monitor/cron)
  ไม่ใช่รอ user มาบอกว่าเว็บล่ม
- **resource ต้องมีคนดูก่อนเต็ม** — disk/RAM/connection pool มีตัวเช็คหรือ alert
  ที่ threshold (~80%) — "ดิสก์เต็ม 99% เจอโดยบังเอิญ" ต้องไม่เกิดซ้ำ
- **health signal ต้องมาจาก *สถานะ* ไม่ใช่ *เหตุการณ์ที่อาจไม่เกิด*** — "มี log/มี event ไหม"
  แยก **ว่าง** กับ **ตาย** ไม่ออก (งานไม่มีเข้า = เงียบเหมือนกัน) → ใช้ heartbeat/lease
  ที่ต้องถูกต่ออายุ หรือ timestamp ของรอบล่าสุด; ไม่งั้นตัวเฝ้าระวังจะพังเงียบเสียเอง
- **สิ่งที่พังเงียบได้ = ต้องมีตัวจับ** — cron ที่หยุดรัน, webhook ที่หยุดมา, service
  ที่ reboot แล้วไม่ auto-start (เช่น sealed vault), queue ที่ backlog โต — ระบุ
  failure mode เงียบของระบบไว้ใน docs แล้วให้ safety-net poller/alert ครอบ
- log ตามรอยได้ (จุดสำคัญตาม production-readiness) + รู้ว่า log อยู่ไหน ดูยังไง
  จดไว้ใน CLAUDE.md/docs — log ที่หาไม่เจอตอนไฟไหม้ = ไม่มี log

## กู้คืนได้
- **backup อัตโนมัติตามรอบ + เก็บนอกเครื่องที่รัน** — backup บนดิสก์เดียวกับ DB
  = ไม่ใช่ backup
- **restore ต้องเคยซ้อมจริงอย่างน้อยหนึ่งครั้ง** — backup ที่ไม่เคย restore คือ
  ความหวัง ไม่ใช่แผน; จดขั้นตอน restore ไว้ (คนกู้อาจไม่ใช่คนตั้ง)
- **rollback path รู้ก่อน deploy** — image tag เดิมคืออะไร, migration ย้อนได้ไหม,
  ถ้าย้อนไม่ได้ (data migration) แผนคืออะไร — ตอบไม่ได้ = ยังไม่พร้อม deploy
- **หลัง deploy: verify ของจริง** — rollout สำเร็จ ≠ ระบบทำงาน; ยิง flow หลัก
  หนึ่งรอบบน production (หรือ health check ที่ครอบ dependency)
- การกู้คืนที่ต้องทำมือ (unseal, restart ตามลำดับ, secret ที่ต้องใส่ใหม่) →
  จดเป็น runbook ใน docs (sensitive ส่วนไหนไป docs/private/)

## ขั้นต่ำต่อระบบที่ขึ้น production
health check ที่มีตัวคอยดู · backup ที่ซ้อม restore แล้ว · rollback path ที่จดไว้ ·
failure mode เงียบถูก list และมีตัวครอบ — ไม่ครบ = จดเป็น known gap ใน CLAUDE.md ไม่ใช่เงียบไว้
