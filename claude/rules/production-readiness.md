# Production Readiness Baseline

สำหรับงานที่จะขึ้น production (ไม่ใช่ prototype/ทดลอง) — ขั้นต่ำที่ต้องมีโดยไม่ต้องรอสั่ง:

- **Error handling**: ทุก external call / IO มี failure path ที่ตั้งใจ (ไม่ใช่ปล่อย exception
  ทะลุ) และ user-facing error ไม่ leak internal detail
- **Validation ที่ boundary**: input จากนอกระบบ (user, API, file) validate ก่อนใช้เสมอ —
  ฝั่ง server เป็นหลัก ฝั่ง client เป็น UX เสริม
- **Logging**: จุดสำคัญ (auth, เงิน, การลบ, integration ภายนอก) มี log ที่ตามรอยได้;
  ห้าม log secret/PII
- **Secrets**: อยู่ใน env/gitignored file เท่านั้น — ห้าม hardcode/ลง git (เอกสารด้วย —
  ใช้ `docs/private/`); ฝั่ง CI: **variable อ่านได้/โผล่ใน log — ของลับต้องเป็น *secret***;
  **เคยหลุดลง git = compromised — purge history ไม่พอ ต้อง rotate เสมอ**
- **Migration / การเปลี่ยน contract ปลอดภัย**: ของเก่ากับของใหม่ต้องอยู่ด้วยกันได้ระหว่าง
  deploy → ดู `compatibility-and-rollout.md` (expand→contract, rollback = ย้อนโค้ดอย่างเดียว)
- **กัน double-submit / retry**: ปุ่มสำคัญ disabled ระหว่างส่ง; endpoint ที่มีผลข้างเคียง
  ควร idempotent
- ก่อนสรุปว่างานเสร็จ: ทดสอบ flow จริงอย่างน้อยหนึ่งรอบ — build ผ่าน ≠ ใช้งานได้

ระดับความเข้มปรับตาม stage ของ project (MVP เข้มน้อยกว่า production) — ถ้า repo ระบุ stage
ใน CLAUDE.md ให้ถือตามนั้น; ไม่ระบุ = ถามหรือ default production-grade
