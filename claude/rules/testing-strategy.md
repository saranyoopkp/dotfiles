# Testing Strategy

ทดสอบเพื่อเพิ่มความมั่นใจในความเสี่ยง ไม่ใช่เพื่อ coverage

- ให้ความสำคัญกับ business logic, authorization, money, boundary/time, contract และ regression ที่เคยเกิด
- happy-path CRUD หรือ UI layout ใช้ type check, targeted test หรือ smoke test ได้เมื่อให้ความมั่นใจพอ
- test ที่พังต้องแก้ ลบ หรืออธิบายการ quarantine อย่างมีเจ้าของ; ห้ามปล่อย skip ค้างเงียบ ๆ
- รันการตรวจที่เกี่ยวข้องและยืนยันพฤติกรรมสำคัญตามความเสี่ยงก่อนสรุปงาน
- fixture ต้องครอบคลุม state ที่มีนัยสำคัญต่องานนั้น ไม่จำเป็นต้องจำลองทุกโลก
- bug ที่แก้แล้วต้องมี regression test เมื่อทดสอบซ้ำได้; test ที่พังห้าม skip ค้างเงียบ ๆ — แก้ ลบ หรือ quarantine พร้อมเหตุผลและเจ้าของ
- ก่อนส่งมอบ ให้รัน targeted test และตรวจ flow จริงเมื่อความเสี่ยงอยู่ที่ integration/runtime; build ผ่านอย่างเดียวไม่ใช่หลักฐานพอ
