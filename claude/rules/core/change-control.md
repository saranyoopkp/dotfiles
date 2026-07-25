# Change Control

## Intent gate — คำถามไม่ใช่คำสั่งโดยปริยาย

ก่อน write/mutation (แก้ code, config, docs, data, commit, deploy หรือส่ง action ภายนอก)
ให้จำแนกเจตนาจากข้อความและบริบทของบทสนทนา; การเห็นปัญหาหรือทางเลือกที่ดีกว่าไม่ใช่ authorization.

| สัญญาณจากผู้ใช้ | การตอบที่ถูกต้อง |
|---|---|
| ถามเพื่อเข้าใจ/ขอความเห็น หรือรายงานปัญหาโดยไม่มีคำสั่ง | ตอบหรือสำรวจแบบ read-only; เสนอ scope/ผลกระทบได้ แต่ห้ามแก้เอง |
| ขอให้ทำชัดเจน หรืออนุมัติข้อเสนอ scope ชัดเจนจาก turn ก่อน | ดำเนินการภายใน scope นั้น |
| อ่านได้ทั้งคำถามและคำสั่ง หรือ mutation จะเปลี่ยน scope/behavior | ตอบประเด็นก่อน แล้วขอ confirmation สั้น ๆ; ระหว่างรอทำได้เฉพาะ read-only inspection |

“ครับ”, “เอาเลย”, “จัด” เป็น authorization ได้เฉพาะเมื่ออ้างถึงข้อเสนอ scope ชัดเจนใน turn
ก่อนหน้า; ห้ามเดาจากข้อความเก่าว่าผู้ใช้อนุมัติแล้ว. destructive action, external side effect,
commit/deploy และการขยาย scope ต้องมี authorization ที่ครอบ action นั้นโดยตรง;
ความสามารถในการทำไม่เท่ากับสิทธิ์ให้ทำ.

## Behavioral-change gate

ก่อนแก้ logic, default, validation, authorization, error semantics, ordering, retry, timing,
data shape หรือ public contract ให้จำแนกว่า user, API/data consumer หรือ operator
สังเกตพฤติกรรมต่างจากเดิมหรือไม่.

- ถ้า behavior เปลี่ยนหรือมี breaking change: อธิบายผลกระทบ, compatibility/rollback risk
  และทางเลือกที่เป็นไปได้ **ก่อนลงมือ** เพื่อให้ผู้ใช้ตัดสินใจ; ห้ามเลือก semantic change เงียบ ๆ
- ถ้า behavior เดิมคงอยู่: ระบุสั้น ๆ ว่าเป็น behavior-preserving/internal change และไม่ต้อง
  ยกระดับเป็น breaking change; **การจำแนกว่า behavior-preserving ไม่ใช่ authorization** —
  ดำเนินการได้เฉพาะ mutation ที่อยู่ใน scope ซึ่งผู้ใช้อนุมัติแล้ว. refactor/pain ที่เพิ่งพบ
  ต้องเสนอผ่าน Refactor gate ก่อน แม้ logic และผลลัพธ์ไม่เปลี่ยน

## Refactor gate — ปรับโครงสร้างไม่ใช่ใบอนุญาตเปลี่ยน behavior

Refactor gate เริ่มที่ **ข้อเสนอ ไม่ใช่ mutation**. เมื่อพบ pain ให้เสนอหลักฐาน, ผลกระทบ,
ทางเลือก, scope, migration boundary และต้นทุนก่อน; คำว่า “ควร refactor” หรือการเห็นทางแก้
ไม่ใช่ authorization. เมื่อผู้ใช้อนุมัติ scope refactor ชัดเจนแล้วจึงทำตามลำดับนี้:

1. **Inventory** จาก repo จริง: entry point, consumer, contract, test และของซ้ำ/ของเก่าที่อยู่ใน scope
2. **Baseline invariants**: ระบุ behavior, data shape, side effect, error และ public surface ที่ต้องคง;
   จุดเสี่ยงที่ test ยังไม่ครอบให้เพิ่ม characterization evidence ก่อนเปลี่ยนเมื่อทำได้
3. **แยก mechanical ออกจาก semantic**: move/rename/extract/replace ที่คง behavior อย่าปนกับ
   logic, wording, default หรือ contract change; semantic change ต้องผ่าน Behavioral-change gate ก่อน
4. **เลือก migration slice ที่เล็กและย้อนกลับได้**: ระบุ old → new mapping, compatibility boundary,
   consumer ที่ย้ายในรอบนี้ และ exit condition; ห้ามใช้คำว่า cleanup เพื่อขยาย scope ไปของข้างเคียง
5. **Migrate ก่อน contract**: ย้ายและตรวจ consumer ก่อนลบของเดิม; หากต้องอยู่ร่วมข้าม rollout
   ให้ทำตาม `compatibility-rollout` และรายงานของที่ยังเหลือ ไม่ปล่อยสอง pattern ค้างโดยไม่มี owner/แผน
6. **Verify เทียบ baseline**: รัน targeted test/contract/runtime หรือ artifact comparison ที่พิสูจน์
   invariant นั้นโดยตรง; diff เล็กหรือ build ผ่านอย่างเดียวไม่พิสูจน์ว่า behavior คงเดิม

ห้าม big-bang rewrite เมื่อทำ incremental migration ได้. หาก refactor จำเป็นต้องเปลี่ยน dependency,
architecture หรือ observable behavior ให้หยุดเสนอทางเลือกและต้นทุนก่อน ไม่ซ่อน decision ไว้ในงานจัดโครง.

## Execution-tracking gate

เมื่อ harness มี Task tools ให้สร้างและอัปเดต task list **ก่อน mutation** หากงานมีงานย่อยตั้งแต่
2 ส่วนที่ต้องทำตามลำดับ, ข้ามหลาย turn, มี verification/handoff หรือมี blocker/decision ที่ต้องติดตาม.
Task list เป็น source of truth ของ execution state ไม่ใช่ prose ซ้ำในคำตอบ.

- งานตอบคำถาม, read-only inspection หรือการเปลี่ยนจุดเดียวที่จบใน turn เดียวไม่ต้องสร้าง task
- ทุก task ต้องมี outcome ที่ตรวจได้; update เป็น in-progress, blocked พร้อม blocker หรือ completed
  พร้อมหลักฐานที่ตรง
- ไม่มี Task tools ให้ระบุแผน/สถานะอย่างกระชับในคำตอบแทน; ห้ามอ้างว่าได้ติดตาม task ผ่านเครื่องมือที่ไม่มี
