---
name: greenfield-foundation
description: วาง foundation เมื่อเริ่ม project/app/service/package/repo จากศูนย์หรือยังไม่มี active implementation/contract ให้ยึด รวม scaffold และเลือก architecture/stack/runtime/database. ตรวจ official lifecycle และ compatibility ปัจจุบันก่อนเลือก
---

# Greenfield Foundation

ใช้ลำดับ `พิสูจน์ขอบเขต → ค้นข้อจำกัด → ตรวจ version chain → ขอ decision → สร้าง vertical slice → verify`.
Greenfield ให้อิสระในการเลือกมากขึ้น แต่ไม่ใช่ใบอนุญาตให้เดา requirement หรือสร้าง architecture เผื่อ.

## 1. พิสูจน์ว่าเป็น greenfield

- ตรวจ task, repository, decision/contract, entry point และ runtime ที่เข้าถึงได้ก่อน. ผลค้นหา
  “ไม่พบ” จาก probe เดียวไม่พิสูจน์ว่าไม่มีระบบเดิม
- แยกทั้งระบบใหม่ออกจาก component ใหม่ใน brownfield. ถ้ามี consumer, public contract, data,
  deployment หรือ convention เดิมที่ต้องอยู่ร่วม ให้ถือส่วนนั้นเป็น compatibility boundary
- ระบุสิ่งที่ verified, inferred และยังเป็น assumption. การไม่มี precedent ไม่ใช่ authorization
  ให้เลือก product behavior, stack, cost หรือ irreversible architecture เอง

## 2. ค้นก่อนถาม

เก็บข้อมูลที่หาได้ก่อน: outcome/ผู้ใช้, stage และ maintenance horizon, environment/deployment target,
data sensitivity, integration, budget/operational constraint และสิ่งที่ผู้ใช้กำหนดไว้แล้ว.
จากนั้นถามเฉพาะ decision ที่คำตอบเปลี่ยน behavior, security, cost, compatibility หรือ scope อย่างมีนัยสำคัญ.

อย่าเริ่มจาก framework. สรุป problem boundary และ minimum end-to-end outcome ที่ต้องพิสูจน์ก่อน.

## 3. LTS & Compatibility Gate — บังคับทุก greenfield

ก่อนเสนอหรือ pin runtime, framework, database, compiler, build tool, SDK หรือ deployment platform:

1. ค้น **primary source ปัจจุบัน** ของแต่ละตัว: official release/support policy, LTS schedule,
   end-of-life, compatibility matrix และ migration/release note ที่ตรง major version
2. ถ้า ecosystem ไม่มีคำว่า LTS อย่างเป็นทางการ ให้เขียนว่า “ไม่มี official LTS” แล้วเลือก
   stable supported release ตาม support policy; ห้ามเรียก version ว่า LTS จากความคุ้นเคย
3. ตรวจ version chain ที่ใช้จริง ไม่ใช่แค่คู่ใดคู่หนึ่ง: OS/architecture → runtime → package manager/
   compiler/build → framework → driver/SDK → database/service → deployment platform เท่าที่เกี่ยวข้อง
4. เทียบ support window กับ maintenance horizon. LTS ที่ใกล้ EOL อาจแย่กว่า supported line
   ที่มี runway ยาวกว่า; “latest” หรือ “LTS” อย่างเดียวไม่ใช่เหตุผลพอ
5. preview, RC, nightly, EOL หรือ version combination ที่ official source ไม่รองรับ ต้องเสนอ
   risk/alternative และขอ authorization ก่อนเลือก
6. บันทึก `component | selected version/line | support status/EOL | compatible-with | source |
   checked date | unresolved risk`. External source ยืนยัน policy; clean install/build/runtime
   ยืนยันว่า combination ของโครงการทำงานจริง — อย่างใดอย่างหนึ่งแทนกันไม่ได้

ถ้าเข้าถึง primary source ไม่ได้ ให้หยุดก่อนตัดสินใจหรือ scaffold ที่ผูก version, รายงานว่า
ยังไม่ยืนยัน และระบุสิ่งที่ต้องตรวจต่อ. ห้ามใช้ความจำของ model ยืนยัน “current LTS”.

## 4. ตัดสิน foundation ก่อน mutation

เสนอเฉพาะ decision ที่มีผลจริง พร้อมเหตุผลและต้นทุน:

- system boundary และ minimum vertical slice
- architecture/dependency direction เท่าที่ use case ปัจจุบันต้องใช้
- stack/version chain จาก gate ข้างบน
- data ownership/lifecycle, auth/tenant และ external integration ที่ requirement ทำให้เกิดจริง
- test, delivery, observability และ recovery baseline ตาม stage/deployment target

ใช้ KISS/YAGNI: interface หรือ abstraction ต้องมี consumer/variation ที่พิสูจน์ได้. เลือกมาตรฐานของ
ecosystem และ dependency ให้น้อยที่สุด; template/starter เป็น input ที่ต้องตรวจ ไม่ใช่ architecture decision.
ก่อน mutation ให้ผู้ใช้ตัดสินใจเรื่องที่เปลี่ยน behavior, vendor lock-in, recurring cost หรือย้อนกลับแพง.

## 5. สร้างและพิสูจน์ vertical slice

- scaffold เท่าที่ vertical slice แรกต้องใช้ แล้ว pin toolchain/lockfile ตาม convention ของ ecosystem
- invoke skill เจ้าของโดเมนเมื่อ flow แตะ API, data, UI/UX หรือ ops; skill นี้ไม่ทำ checklist เหล่านั้นซ้ำ
- ตรวจจาก clean state: install/restore dependency, typecheck/build/test, start runtime และยิง flow
  end-to-end ที่เล็กที่สุดบน environment ที่ใกล้ target เท่าที่ทำได้
- ตรวจว่า version ที่รันจริงตรงกับ compatibility record; generated default ที่ไม่ได้ใช้ให้ลบ
- ส่งมอบ decision, sources/checked date, verification result, assumption และ known gap.
  ห้ามกล่าวว่า foundation พร้อมใช้เมื่อ install/build/runtime หรือ compatibility criterion ยังไม่ผ่าน
