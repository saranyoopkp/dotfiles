# Stack Contracts Routing

## Safety floor

- ห้ามเพิ่มเครื่องมือทำ concern เดียวกันหรือสร้าง writable source ของ contract ซ้ำเงียบ ๆ
- consistency เป็น default แต่ความต่างที่มี runtime/deploy/ownership boundary จริงทำได้เมื่อ
  ระบุเหตุผล, owner และ compatibility/migration path

## Routing

ก่อนเพิ่ม/เปลี่ยน dependency, consolidate เครื่องมือ/config หรือสร้าง/แก้ schema, type, enum,
constant และ contract ที่มีหลาย consumer ให้ invoke `stack-contracts`. helper หรือ schema
ภายใน owner/consumer เดียวไม่ต้อง invoke เว้นแต่มีหลักฐานว่าเป็น shared contract.
