# Stack Consistency & Shared Contracts

ใช้สิ่งที่มีอยู่สำหรับ concern เดียวกันเป็น default; เพิ่มความต่างเมื่อประโยชน์ชัดและผู้รับผิดชอบรับรู้ต้นทุน

- ก่อนเพิ่ม dependency หรือ pattern ใหม่ ตรวจของเดิมและผลต่อ maintenance/migration
- contract ที่หลายส่วนพึ่งพาต้องมี source of truth เดียว เช่น schema, types, constants และ error shape
- convention ที่ใช้ร่วมกันควรอยู่ร่วมกัน; utility หรือ contract ที่ซ้ำและมี owner ร่วมจึงค่อย consolidate
- ความไม่สอดคล้องเดิมไม่ใช่เหตุผลให้เพิ่มความไม่สอดคล้องใหม่

ไม่บังคับ consolidate ทุกกรณี: เลือกตาม coupling, lifecycle และต้นทุน migration.
