---
name: stack-contracts
description: ต้องใช้ทันทีเมื่อผู้ใช้ขอเพิ่ม/เปลี่ยน dependency ทั้งที่ workspace อาจมีเครื่องมือ concern เดียวกัน, ขอ consolidate stack/config หรือออกแบบ/แก้ shared schema/type/enum/constant/contract ระหว่าง package/service/frontend/backend/worker แม้ยังต้อง inventory manifest/consumer เพื่อยืนยันภายหลัง; ไม่ใช้กับ helper ภายในจุดเดียวหรือ schema ที่มี owner/consumer เดียว และห้ามสร้าง shared package หรือ abstraction เผื่ออนาคต
---

# Stack Contracts — owner เดียวก่อน shared abstraction

## Inventory ก่อนตัดสิน

ตรวจจาก repo:

- dependency/config ที่ทำ concern เดียวกันอยู่แล้ว
- producer, consumer และ runtime boundary ของ contract
- source of truth, generated artifact และ compatibility path
- duplication เป็น contract เดียวจริงหรือเพียงหน้าตาคล้ายกัน

ไม่พบจาก query หนึ่งครั้งห้ามสรุปว่าไม่มี; ตรวจ manifest, imports, barrel/registration และ
workspace config ที่เกี่ยว. การวิเคราะห์ไม่ใช่ authorization ให้เพิ่มหรือ migrate dependency.

## Dependency consistency

- concern เดียวกัน default ใช้ของเดิม เพื่อไม่เพิ่ม runtime, API และ maintenance surface
- ตัวใหม่ดีกว่าให้เสนอ benefit, compatibility, security/license, migration cost และ exit path
- อนุมัติให้เปลี่ยนแล้ว migrate ตาม boundary ที่ตกลง; ห้ามปล่อยสองมาตรฐานโดยไม่มี owner/exit
- ความต่างที่มีเหตุผลตาม runtime/team/deploy boundary จดเหตุผล ไม่บังคับ consolidate
- decision ที่ทำให้ stack ต่างหรือเปลี่ยนมาตรฐานต้องจดใน decision/operational home ที่ repo
  กำหนด; ถ้ายังไม่พบบ้านให้เสนอที่เก็บ ห้ามแต่ง path ขึ้นเอง

## Shared contract

- กำหนด owner ของ schema/type/enum/error code ก่อนเลือกที่เก็บ
- generate/infer จาก authoritative schema เมื่อทำได้; ห้ามมี writable sources หลายชุด
- shared package คุ้มเมื่อมีหลาย consumer ที่ต้อง release/verify contract เดียวกัน
- consumer เดียวหรือ contract ยังไม่นิ่งให้เก็บกับ owner ก่อน; อย่าสร้าง package เผื่ออนาคต
- validate ที่ runtime boundary แม้มี shared static type

## Monorepo consistency

- error shape, naming, folder boundary และ formatter/linter/build config ที่เป็น concern ร่วม
  ควรมี owner/source เดียว; package layout/override ต่างได้เมื่อ runtime, deploy หรือ ownership
  boundary ต้องการและมีเหตุผล
- utility ที่ซ้ำเกิน 2 จุดให้ตรวจว่า semantics และ change cadence เดียวกันจริงแล้วเสนอ consolidate;
  ห้ามยกเข้า shared packageจากจำนวนอย่างเดียว
- เจอความไม่สอดคล้องเดิมให้ทักและเสนอ migration; ห้ามเพิ่มความต่างใหม่ตาม precedent เงียบ ๆ

## Migration และ verification

ถ้า public/data consumer สังเกตต่าง ให้ผ่าน behavioral/compatibility gate ก่อน mutation.
Inventory consumer ทั้งหมด, migrate ทีละ boundary และตรวจว่าไม่มี import/config/schema เก่า
เหลือก่อน contract. รายงาน owner, consumers, compatibility window และหลักฐานต่อ consumer.
