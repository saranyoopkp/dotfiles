# Time / Timezone / Date

- Instant เก็บเป็น UTC พร้อม offset/zone semantics; date-only และ business cutoff ต้องมี business timezone
  ชัดเจน. ห้ามพึ่ง server `TZ` โดยไม่ตั้งใจ.
- Parse/compare ด้วย date-time type/library ไม่เทียบ string; calendar arithmetic ต้องรองรับ DST,
  leap day และ month boundary ไม่แทนวันด้วยชั่วโมงคงที่.
- แยก instant, local datetime และ calendar date. การนับวันให้ normalize ใน business timezone ก่อน;
  range query แปลงขอบเขต local เป็น UTC แล้วค่อย query.
- Schedule/cron ระบุ timezone; display ใช้ user/business timezone ตาม contract เดียวกัน.
- Test boundary ที่เกี่ยวจริง เช่น midnight, month/year/DST cutoff และผู้ใช้ต่าง timezone.
