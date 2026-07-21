# CRUD Completeness

ทุก entity ที่มี endpoint / หน้า admin / resource ให้จัดการ — ต้องพิจารณาให้ครบทุก operation
ไม่ใช่ทำเฉพาะตัวที่ถูกพูดถึงใน requirement:

- **list** — พร้อม filter + pagination ตั้งแต่แรกถ้าข้อมูลโตได้ (ไม่ใช่ "ค่อยเติมทีหลัง")
- **get** (detail)
- **create** — พร้อม validation ครบ field
- **update** — ระบุชัดว่า partial (PATCH) หรือ replace (PUT) และ field ไหนแก้ไม่ได้
- **delete** — ตัดสินใจ soft/hard delete + ผลต่อ relation (cascade? block? orphan?)

กติกา:
- **ถ้าตัด operation ไหนออก = ตัดสินใจ ไม่ใช่ลืม** — ระบุเหตุผลสั้น ๆ (ใน code comment
  หรือ doc) และแจ้ง user ตอนสรุปงานว่า operation ไหนมี/ไม่มีเพราะอะไร
- operation ที่มี side effect (เงิน, สถานะ, การแจ้งเตือน) ต้อง idempotent หรือกัน double-submit
- ทุก write operation มี authorization check — ไม่ใช่เฉพาะ read
