# Webhook & External Integration Reliability

integration ภายนอกพังเสมอ ไม่ใช่ "ถ้า" แต่ "เมื่อไหร่" — ออกแบบให้รับได้ตั้งแต่แรก:

## ฝั่งรับ webhook
- **รับให้เร็ว แยกประมวลผล** — receiver ทำแค่ verify + บันทึก event + ตอบ 2xx;
  งานจริง (reconcile, side effect) ทำ async — provider ส่วนใหญ่ timeout สั้นและ retry เอง
- **verify แหล่งที่มาเสมอ** — signature/HMAC/shared secret (เทียบแบบ constant-time);
  endpoint webhook คือประตูสาธารณะ
- **dedup** — provider ส่งซ้ำได้เสมอ (retry ของเขา) → มี dedup key (event id หรือ
  payload hash + หน้าต่างเวลา) ประมวลผลซ้ำต้องไม่เกิด side effect ซ้ำ;
  **filter echo ของตัวเอง** — platform ที่สะท้อนข้อความที่เราส่งกลับมา (เช่น `is_echo`)
  ต้องถูกกรองก่อน ingest ไม่งั้นข้อมูลผี
- **เก็บ raw event ก่อนประมวลผล** — event ที่ process พลาดต้อง replay ได้
  ไม่ใช่หายไปกับ exception

## ฝั่งเรียก provider (outbound / OAuth / connect flow)
- **ห้าม `catch { return false }` กับ provider call** — surface เหตุผลจริงเสมอ
  (error code/message ของ provider) ไม่งั้น debug connect flow คือการเดาในความมืด
- **verify ด้วย action ที่ต้องทำอยู่แล้ว ไม่ใช่ read ที่ขอ scope เพิ่ม** — เช็คว่า
  ต่อสำเร็จด้วย mutating call ที่จำเป็นต่อ flow ไม่ใช่ยิง field read ที่อาจติด
  permission คนละชุด
- **precondition/uniqueness check ก่อน external side-effect เสมอ** — เช็ค DB ให้ผ่าน
  ก่อนค่อยเรียก provider (สลับลำดับ = fail กลางทางแล้ว orphan สถานะฝั่งโน้น)
- **เชื่อ live API call มากกว่าเอกสาร** — โดยเฉพาะ provider ที่มีหลาย product
  ชื่อ scope/endpoint คล้ายกัน — ยิงจริงแล้วดูผลคือ source of truth

## ความทนทาน
- **retry with exponential backoff + max attempts** สำหรับ event ที่ fail —
  และมีที่เก็บตัวที่เกิน max (dead letter) ให้คนมาดู ไม่ใช่เงียบหาย
- **idempotent ทั้งเส้น** — sync/reconcile รันซ้ำแล้วผลเหมือนเดิม (upsert on
  external id ไม่ใช่ insert)
- **safety-net poller** — webhook หายได้เสมอ → มี sync ตามรอบเป็นตาข่ายอีกชั้น;
  กำหนด path ที่ trigger notification ให้ชัด เพื่อไม่ให้ backfill flood แจ้งเตือน
- ทุก outbound call: timeout + จัดการ failure ที่ตั้งใจ (ตาม performance/production rule)

## ก่อนปิดงาน
- ทดสอบ: ส่ง event ซ้ำ (dedup ทำงาน), event พัง (เข้า retry/dead letter),
  signature ผิด (ถูกปฏิเสธ) — สามเคสนี้คือขั้นต่ำ
- เขียน operator doc: URL ที่ต้องตั้งฝั่ง provider, secret อยู่ไหน, ดู event log ยังไง
