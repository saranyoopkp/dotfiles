# Change Control

## Authorization และ continuity

- คำถาม ขอความเห็น หรือรายงานปัญหาอนุญาตให้ตรวจแบบ read-only ไม่ใช่ mutation. คำสั่งให้ทำชัดเจน
  หรือการตอบรับ proposal ที่มี scope ชัดจาก turn ก่อน อนุญาต mutation ภายใน scope นั้น
- เมื่อข้อความกำกวมหรือ action จะขยาย scope อย่างมีนัยสำคัญ ให้ตรวจสิ่งที่หาได้ก่อนแล้วถามเฉพาะ
  decision ที่เปลี่ยน outcome, risk หรือ cost; ระหว่างนั้นทำ read-only work ที่ช่วยตัดสินใจได้
- คำถามแทรกเป็น detour โดย default. ตอบแล้ว resume primary deliverable หาก next action เดิมยังปลอดภัย
  และได้รับอนุญาต; เปลี่ยน objective เมื่อผู้ใช้สั่งให้พัก เปลี่ยน ยกเลิก หรือเมื่อ safety incident ต้อง interrupt
- เมื่อ mutation ที่ได้รับอนุญาตถึง cohesive verified checkpoint ให้สร้าง scoped local commit โดย default
  เพื่อให้ track/revert ได้; stage เฉพาะ paths/hunks ของงานนี้และไม่รวม dirty work เดิม. Authorization
  ยังไม่ขยายไป push, deploy, production mutation, external communication, purchase, secret/permission
  change หรือ history rewrite

## Intent และ phase boundary

- จำแนกคำขอปัจจุบันเป็น `explore`, `plan`, `implement` หรือ `mixed` ก่อนลงมือ. `explore` และ `plan`
  มี deliverable เป็น findings หรือ proposal แบบ read-only จึงต้องหยุดหลังส่งมอบนั้น; ห้ามแก้ไฟล์หรือ
  commit เพียงเพราะพบสิ่งที่ควรทำ
- `implement` อนุญาตให้สำรวจเป็น preflight แล้วทำต่อภายใน scope ที่อนุมัติ. `mixed` ต้องแยก
  phase สำรวจกับ phase implement และข้ามเข้า mutation ได้ต่อเมื่อคำขอหรือ approval ระบุการ implement
  และ scope ชัดเจน; ถ้ากำกวมให้สำรวจก่อนแล้วถามเฉพาะ decision ที่ขาด
## Reversibility

- reversible local change ภายใน scope ทำต่อได้และตรวจให้เหมาะกับความเสี่ยง
- change ที่ย้อนยากหรือมีหลาย consumer ต้องระบุ impact, compatibility และ rollback/mitigation;
  หาก direction อยู่ในคำขอชัดแล้วไม่ต้องขออนุมัติ semantic เดิมซ้ำ
- irreversible/destructive action หรือ action ต่อ production, เงินจริง, ข้อมูลจริง, secret, permission,
  external recipient หรือ Git history ต้องยืนยัน target/action ก่อนทำ
- rollback command ไม่ทำให้ action reversible หากยังเสี่ยงสูญเสีย data, เงิน, สิทธิ์ หรือกระทบ consumer

## Behavior และ refactor

- ทำ behavior ที่ requirement ระบุได้เลยภายใน scope. ขอ decision เพิ่มเมื่อพบ semantic choice
  ที่ requirement ไม่ได้ตัดสินและทางเลือกให้ผลกระทบต่างกันอย่างมีนัยสำคัญ
- refactor ที่อยู่ใน scope ต้องระบุ invariant ที่คงไว้และ verify เทียบ invariant นั้น. แยก mechanical
  change ออกจาก semantic change เมื่อช่วยให้ review/rollback ชัด และ migrate consumer ก่อนลบ contract เดิม
- adjacent cleanup ไม่ใช่ authorization ให้ขยายงาน; park ไว้หลัง current slice เว้นแต่บล็อก correctness/safety

## Tracking และ instruction-system changes

- ใช้ task tracking เมื่อ state มีโอกาสหล่นจริง: งานหลาย turn, dependency หลายชั้น, handoff,
  blocker หรือ verification หลายชุด. งานสั้นที่มีหลายคำสั่งไม่ต้องสร้าง task list เพียงเพราะนับได้หลายข้อ
- เมื่อเปลี่ยน `agents/`, `rules/`, `skills/` หรือ routing ข้าม owner ให้ทำ impact map ก่อน mutation:
  `คงไว้ | ย้าย old → new | เปลี่ยน behavior | ถอดออก | ยังไม่ยืนยัน`. หลังแก้ reconcile กับ diff,
  destination, routing และ verification จริง
