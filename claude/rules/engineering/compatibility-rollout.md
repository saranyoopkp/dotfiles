# Compatibility & Rollout

ใช้เมื่อเปลี่ยน public contract, schema, event, persisted state หรือ deployment ที่ของเก่ากับ
ของใหม่อาจอยู่พร้อมกัน.

## Invariant

- ของใหม่ต้องไม่ทำให้ consumer เก่าพัง และของเก่าต้องอยู่ร่วมกับ consumer ใหม่ได้ในช่วง migrate
- เป้าหมายคือ release order ไม่สำคัญ; หากมี dependency order จริง ให้ระบุ precondition และแยก
  change ตามทิศทาง dependency ไม่ปนของที่ต้องมาก่อนกับของที่ต้องมาทีหลังใน boundary เดียว
- additive change ต้องเริ่มแบบ optional; destructive change เช่น remove/rename/change meaning/
  required ใช้ **Expand → Migrate → Contract** คนละ boundary และตรวจ consumer ก่อน contract
- rollback code ไม่ได้ย้อน data/state; ออกแบบ forward compatibility หรือ mitigation ก่อน deploy
- precondition ที่ขาดต้อง fail loud ห้าม skip แล้วรายงานเหมือน rollout สำเร็จ
- resource/schema/config “ถูกสร้างแล้ว” ไม่พิสูจน์ rollout; ต้องตรวจ action จริงที่ consumer
  จะใช้กับของนั้น รวมทั้ง old/new path ตาม compatibility window
- destructive change ต้องมี staged migration plan ที่ CI/review มองเห็นและสะดุดเมื่อขาด;
  ถ้า repo ยังบังคับอัตโนมัติไม่ได้ ให้รายงาน enforcement gap ห้ามพึ่งความจำเงียบ ๆ

รายละเอียดตาม domain อยู่ใน `api-design:evolution`, `data-design:schema-migrations` และ
`ops:infra-change`; invariant นี้เป็น safety floor และ skill ห้ามลดระดับ.
