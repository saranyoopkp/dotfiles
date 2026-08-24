# Change Control

## Intent and checkpoint

- คำถาม การขอความเห็น หรือการรายงานอาการไม่ใช่ authorization ให้ mutate. คำสั่งชัดหรือการอนุมัติ
  scope จาก turn ก่อนให้ดำเนินการใน scope นั้น; ยังคลุมเครือและเปลี่ยนผลสำคัญให้ถามสั้น ๆ ก่อน write.
- เมื่อ authorized mutation slice เสร็จและตรวจแล้ว ให้ local commit เฉพาะ task-owned paths/hunks เป็น
  checkpoint โดย default. Dirty work แยกไม่ได้ให้รายงานแทนการเดา.
- Push, deploy, amend/rebase/history rewrite, destructive/irreversible action และ external side effect
  ต้องมี authorization ที่ครอบ target/action นั้นโดยตรง.

## Reversibility

| ระดับ | การกระทำ |
|---|---|
| **ย้อนกลับได้ง่าย** | อยู่ใน scope แล้วทำได้ทันที; แสดงผลและหลักฐาน |
| **ย้อนยาก** | target/authorization ชัดแล้วให้อธิบายเหตุผล ผลกระทบ และ rollback/mitigation ก่อนลงมือ |
| **ย้อนกลับไม่ได้/เสียหายยากกู้** | หยุดขอ authorization ที่ระบุ target/action ก่อนเสมอ |

มี rollback command อย่างเดียวไม่ทำให้ย้อนง่าย; ต้องไม่สูญเสีย data, money, permission หรือกระทบ
consumer นอก scope. ระดับไม่ชัดให้ถือว่าย้อนยาก.

## Objective continuity

- รักษา `current objective`, `primary deliverable` และ acceptance จนกว่าจะส่งมอบ, cancel, defer หรือ
  replace อย่างชัดเจน. คำถามแทรกเป็น detour; ตอบแล้ว resume เมื่อ next action ยัง authorized/safe.
- Prerequisite, probe และ diagnostic ที่รับใช้ outcome เดิมเป็น child objective; จำกัดเท่าที่ parent
  เดินต่อ แล้ว resume parent. ห้ามแทน deliverable ด้วย readiness, finding หรือ report.
- Dependency/finding ใช้ `required/blocking`, `adjacent`, `known/deferred`; เรื่องที่ผู้ใช้รับทราบหรือ
  defer แล้วไม่ reopen เว้นแต่เงื่อนไขเปลี่ยนจนบล็อก objective.
- Switch/pause เมื่อผู้ใช้จัดลำดับใหม่ชัดหรือมี safety interrupt; เก็บ resume point ของงานเดิม.

## Behavioral and structural change

- ก่อนเปลี่ยน logic, default, validation, authorization, error semantics, ordering, retry, timing,
  data shape หรือ public contract ให้ระบุ observable impact. Semantic/breaking change ต้องมี alternatives,
  compatibility/rollback risk และ user decision ก่อน mutation.
- Refactor เริ่มจาก proposal เมื่อยังไม่ authorized. หลังอนุมัติให้ inventory entry point/consumer/
  contract/test, ระบุ baseline invariant, แยก mechanical/semantic, migrate เป็น slice เล็ก แล้ว verify
  เทียบ baseline; ห้ามใช้ cleanup ซ่อน scope หรือ big-bang เมื่อ incremental ได้.
- การจำแนกว่า internal/behavior-preserving ไม่ใช่ authorization และ build/diff เล็กไม่พิสูจน์ invariant.

## Instruction-system change

ก่อนแก้หลาย owner ใน agents/rules/skills ให้แสดง impact map
`คงไว้ | ย้าย old → new | เปลี่ยน behavior | ถอดออก | ยังไม่ยืนยัน`. หลังแก้ reconcile กับ diff,
owner/routing และ behavior evidence จริง; ประวัติอยู่ Git ไม่สร้าง ledger ซ้ำ.

## Execution tracking

ใช้ task tracking ก่อน mutation เมื่องานมีหลายขั้น/หลาย turn, handoff, blocker หรือ verification ที่ต้อง
ติดตาม. Task ต้องมี outcome ที่ตรวจได้และสถานะจากหลักฐาน; งานสั้น/read-only ไม่สร้าง checklist.
Anchor parent ด้วย primary deliverable + acceptance evidence และอย่านับ child ที่จบแทน progress ของ parent.
