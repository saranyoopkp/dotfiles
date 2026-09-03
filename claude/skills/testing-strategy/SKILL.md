---
name: testing-strategy
description: วางแผน เขียน หรือ review tests, เลือก regression test สำหรับ bug fix, เลือก test level, ออกแบบ fixture/input-domain/state-transition/time/concurrency/role-tenant/load/capacity coverage หรือสร้าง test harness ใช้เมื่อ test design หรือ coverage completeness ไม่ชัด, boundary มีความเสี่ยง, bug เคยเกิด, suite ผ่านแต่ flow ยังพัง หรือผู้ใช้ขอ coverage review; ไม่ใช้กับการรัน verification command ปกติที่ repo กำหนดและ criterion ชัดแล้ว
---

# Testing Strategy — พิสูจน์ behavior ตาม coverage contract

## เลือกหลักฐาน

เริ่มจาก `claim → failure mode → observable result → cheapest reliable test` แล้วเลือก:

- **unit**: logic deterministic และ boundary ถูกแทนได้โดยไม่ซ่อนความเสี่ยง
- **integration**: database, queue, filesystem, provider adapter หรือ component contract
- **e2e/runtime flow**: wiring, browser/client behavior, auth/session และ deployment surface
- **smoke**: ยืนยันเส้นทางหลักหลัง build/deploy ไม่ใช่แทน regression suite

test level หลายชั้นใช้เมื่อแต่ละชั้นพิสูจน์คนละ failure mode; ห้ามซ้ำเพื่อจำนวน.

## Priority

1. logic ที่ผิดแล้วกระทบเงิน, สิทธิ์, tenant, data หรือ irreversible side effect
   - การคำนวณเงิน/ส่วนแบ่ง/ภาษีต้องมี independent oracle เช่นคำนวณมือหรือ fixture ที่มีที่มา
2. boundary/edge ที่เกิดได้จริง เช่น negative/zero/empty, duplicate, retry, remainder/split,
   cutoff/time
3. contract ระหว่างส่วนที่ release หรือพัฒนาแยกกัน
4. regression ของ bug ที่พิสูจน์ root cause ได้

glue ตรง ๆ, layout หรือ implementation detail ที่ type/smoke จับได้ไม่ต้องมี test เฉพาะ
เว้นแต่มี regression evidence.

## Behavior-boundary completeness

เริ่มจาก contract/invariant แล้วหา `steady state → boundary event → observable result → recovery`.
เลือกเฉพาะ family ที่ behavior มีจริงจาก contract, implementation, incident หรือ risk; รายการนี้เป็น
discovery prompts ไม่ใช่ checklist ที่ทุกงานต้องสร้าง test:

- **state/lifecycle**: state เริ่มต้น, transition ที่อนุญาต/ปฏิเสธ, terminal/re-entry และ action ซ้ำ
- **time/cardinality/order**: ก่อน/ตรง/หลัง cutoff, empty/first/last/limit และ duplicate/out-of-order
- **identity/context**: role, ownership, tenant/session boundary และการเปลี่ยนหรือถอนสิทธิ์ระหว่าง flow
- **side effect/failure timing**: fail ก่อนเริ่ม, หลังบางส่วน, หลัง commit แต่ก่อนตอบ; retry/resume/cancel
  ต้องพิสูจน์ final state และ side effect ไม่ซ้ำหรือไม่ค้างครึ่งทางตาม contract
- **concurrency/compatibility**: competing actor, stale state และ old/new combination เฉพาะเมื่อมี shared
  state, independent release/persisted contract หรือ rollout window จริง

สำหรับ invariant แต่ละตัว ให้เลือก event ที่ข้าม invariant ได้ใกล้ที่สุดและตรวจทั้ง state/result กับ
observable side effect. ใช้ coverage ledger และ pruning เดียวกับ input-domain; ห้ามทำทุก family × ทุก state
หรือ duplicate semantics จาก domain owner. API/data/UI/ops skill ที่ตรงเป็นเจ้าของ contract detail;
`risk-review` เป็นเจ้าของ auth/tenant/time/irreversible-risk floor; `testing-strategy` เป็นเจ้าของ test
evidence และ completeness mapping.

Contract gap มีเมื่อ observable outcome ภายใน precondition ที่ประกาศยังไม่ชัดจนสร้าง oracle ไม่ได้เท่านั้น.
Mechanism/framework/harness ที่ยังไม่รู้เป็น implementation discovery ให้ inspect ตอนลงมือ ไม่ใช่ gap;
behavior นอก precondition เป็น out of scope และห้ามยกเป็น open question. อย่าขยายคำว่า atomic/idempotent
หรือ result equality ให้เข้มกว่า observable guarantee ที่ contract ระบุ.
Atomicity พิสูจน์ all-or-nothing ที่ commit boundary ไม่ได้รับประกัน reclaim/recovery; at-least-once
พิสูจน์ว่า delivery ซ้ำได้ ไม่ได้กำหนด lease/timing หรือ duplicate outcome; terminal state ก็ไม่กำหนดว่า
redelivery ต้อง reject, no-op/ack หรือคืนผลเดิม. Retry precondition ที่ contract ระบุคือ scope ของ
guarantee—ห้ามสร้าง state อื่นเป็น gap เอง.
เมื่อ repeated delivery ชน non-repeatable side effect ต้องมี authoritative duplicate outcome; ถ้าไม่มีให้
รายงาน contract gap และห้ามตั้ง idempotent/exactly-once row เป็น executable เอง. Terminal จำกัด state
transition เท่านั้น ไม่พิสูจน์ว่า repeated command จะไม่ทำ side effect ซ้ำ; terminal-transition row ตรวจ
เฉพาะ state oracle และ side-effect assertion ต้องอยู่ใน duplicate-outcome row ที่มี contract รองรับ.
การระบุ recovery/redelivery event เป็น scope ไม่ใช่ duplicate-outcome guarantee; ต้องมีคำตอบ observable
เช่น reject/no-op/replay/no-repeat ระบุแยกจึงถือว่ารองรับ.

คำว่า atomic ต้องมี probe ที่ทำให้ partial visibility/failure/race ปรากฏได้ตาม mechanism จริง; sequential
end-state พิสูจน์เพียงผลลัพธ์. ถ้ายังไม่รู้ mechanism ให้ map atomic criterion เป็น implementation discovery
และ verification gap—not contract gap หรือ tested row; อธิบาย required probe shape ได้แต่ row ต้องเป็น
planned/unrunnable จน inspect repo แล้ว map probe ได้ ห้ามสรุปว่า executable/covered.
Sequential boundary row ห้ามใช้ atomic/window/race assertion; เก็บเฉพาะ end-state แล้วแยก assertion
เหล่านั้นไป planned atomic probe. Oracle ที่ประกาศด้านเดียว เช่น rollback ไม่มี partial write พิสูจน์ได้
ด้วย negative assertion; final-state policy ที่ contract ไม่กล่าวถึงไม่ใช่ gap และห้ามเติมเพื่อให้ row สมบูรณ์.

Final report แยก `executable`, `planned/unrunnable verification gap`, `blocked contract gap` และ `pruned`
คนละ table/status; pruned row ห้ามค้างใน ledger. สรุปจำนวนตามสถานะจริง และห้ามเรียก completeness ว่าปิด
เมื่อ material criterion ยังอยู่ planned หรือ blocked.
State ที่ contract จัดเป็น class เดียวและใช้ oracle เดียวเลือกหนึ่ง representative โดยเลือก row ที่ reuse
criterion อื่นได้มากกว่า. ถ้า guarantee ไม่ขึ้นกับ dimension หนึ่ง stronger precondition row จะ dominate
weaker row เมื่อ setup เดิม reuse ได้และ oracle เท่ากัน.

## Input-domain completeness

สร้าง model จาก contract จริงด้วย `contract → behavior dimensions → equivalence
partitions → boundary representatives → coupled interactions → remaining gaps`. เลือกเฉพาะ dimension
ที่เปลี่ยน behavior เช่น presence, representation/type, range, total precision, scale/step,
format/normalization,
cardinality, cross-field invariant หรือ state/role; รายการนี้เป็นคำถามค้น constraint ไม่ใช่ checklist
ที่ต้องใช้กับทุก input.

- ใช้ minimal discriminating set: normal valid หนึ่งค่า, contract boundary แต่ละด้าน และ nearest invalid
  ที่ข้าม boundary. แยก total precision (จำนวน digit ทั้งหมด), scale (digit หลังจุด) และ step/granularity;
  nearest numeric crossing ต้อง derive จาก scale/step ที่ contract อนุญาตและตรวจ arithmetic ก่อนสรุป.
  เก็บ normal valid ภายในช่วงเป็น baseline หนึ่ง row แยกจาก semantic limit boundary; baseline ใช้เป็น
  grammar/schema-valid representative ได้เพื่อไม่เพิ่ม accepted row ตาม syntax boundary.
  constraint ใดมีใน contract ให้ทดสอบที่ limit กับ nearest invalid โดยคง constraint อื่นให้ valid เท่าที่ทำได้.
  ทุก constraint ต้องมีทั้ง valid boundary และ invalid crossing; ถ้า crossing เดียวข้ามหลาย constraint
  ได้ ให้ reuse nearest crossing นั้นเป็น case เดียวแล้ว map ทุก criterion; ห้ามเพิ่ม crossing ที่ไกลกว่า
  สำหรับ criterion เดิม. ระบุ oracle ว่า reject, round หรือ truncate ตาม contract—not
  common sense. Logical implication ไม่ใช่เหตุผลให้ละฝั่ง invalid; `covered elsewhere` ใช้ได้เมื่อมี case
  ที่ข้าม constraint นั้นจริงหรือมี authoritative decision ว่า redundant. ใช้ nearest-invalid กับ semantic
  ordered limit; regex/schema ใช้หนึ่ง representative ต่อ observable invalid partition ไม่แตก test ตาม
  clause หรือ quantifier เว้นแต่ contract ให้ behavior ต่างกัน.
- ใช้หนึ่ง representative ต่อ equivalence partition. ห้ามเพิ่ม far-out, malformed, parser, overflow หรือ
  security variant เว้นแต่ contract, implementation boundary, incident หรือ risk model พิสูจน์ว่าเป็น
  observable failure mode คนละตัว. Failure หลายรูปแบบของ validation predicate เดียวที่ใช้ branch/oracle
  เดียวกันคือ invalid partition เดียว; จำนวน clause, syntax หรือค่าที่ต่างกันไม่สร้าง coverage ใหม่.
- ห้ามเดา min/max, precision, normalization หรือ allowed representation. หา authoritative source;
  constraint ที่ประกาศด้านเดียว เช่น `max` ไม่ได้สร้าง `min` อีกด้าน และห้าม map boundary ของ dimension
  หนึ่งเป็น boundary ของอีก dimension เพียงเพราะใช้ค่าเดียวกัน.
  ถ้าไม่มีให้รายงาน dimension นั้นเป็น contract gap หนึ่งข้อพร้อม source/decision ที่ต้องการ โดยไม่แจกแจง
  possible policy, format หรือ value ที่ยังไม่มีหลักฐาน. เฉพาะ dimension ที่ contract แตะไว้แต่ตัดสิน
  behavior ไม่ได้จน criterion ทดสอบไม่ได้จึงเป็น gap; malformed envelope หรือกรณีนอก contract ไม่เป็น
  gap โดยอัตโนมัติ และห้ามค้างเป็น open question/readiness work ใน final ledger.
- ถ้า upstream contract ทำให้ boundary ฝั่งหนึ่ง unreachable โดยโครงสร้าง ให้ map ว่า structurally covered
  by constraint นั้น; ไม่สร้าง input ปลอม ไม่เรียกเป็น gap และไม่ขอ decision เว้นแต่ contract ขัดกัน.
- ห้ามทำ Cartesian product ทุก partition. รวม dimensions เมื่อ business rule, state transition หรือ
  observable error semantics/incident ทำให้สัมพันธ์กัน; ห้ามสร้าง interaction เพียงเพราะสอง constraint
  สามารถ fail พร้อมกันหรืออาจมี bug ได้—plausibility อย่างเดียวไม่ใช่ coupling evidence. ก่อนสรุปว่า
  constraints coupled/unreachable ต้องพิสูจน์บน representation ทั้งหมดที่ contract อนุญาต รวม leading
  zero/normalization; counterexample เดียวแปลว่าต้องแยก criteria.
- เมื่อพิสูจน์ว่า criteria อิสระ ให้เลือก invalid row ที่คง criteria อื่น valid ถ้ามี representation ที่
  contract อนุญาต—including alternate scale/length; ห้าม map หรือยอม shared failure เพียงเพราะค่าที่เลือก
  แรก fail พร้อมกัน.
- คำว่า coverage ครบหมายถึง material partition/criterion ทุกตัวมีสถานะ tested, intentionally covered
  elsewhere หรือ gap/deferred พร้อมเหตุผล—not ทุกค่าที่เป็นไปได้ถูก enumerate.
- ทำ coverage ledger หนึ่ง row ต่อ executable case และให้ row เดียว map ได้หลาย criteria. ตัดสิน completeness
  จาก criterion→row/gap mapping—not case count. จำนวน case เป็น optional summary ได้เมื่อ derive จาก
  final ledger แบบตรวจซ้ำได้ แต่ไม่ใช่หลักฐานว่าครบ. Input ของ row ต้องข้าม criterion ที่ map ไว้จริง;
  oracle เดียวกันอย่างเดียวไม่พอ. ใน invalid partition เดียวให้เลือก representative ที่ข้าม declared
  criteria ได้มากที่สุดโดยไม่เพิ่ม interaction.
- ก่อนสรุปให้ prune dominated row: ถ้า criteria ของ row หนึ่งถูก row อื่นที่ใช้ branch/oracle เดียวกัน
  ครบแล้ว ให้ตัดออก เว้นแต่มี contract boundary หรือ failure evidence ที่ row อื่นพิสูจน์ไม่ได้. เมื่อ
  constraint เฉพาะ fail predicate ที่กว้างกว่าด้วยและใช้ oracle เดียวกัน ให้ map ทั้งคู่ใน row เฉพาะ
  แล้วตัด standalone row ของ predicate กว้างกว่า. ชื่อ validator, ลำดับ check หรือ internal branch ไม่ใช่
  observable behavior แยก เว้นแต่ contract/result ต่างกัน.
- สมาชิกที่ contract จัดให้อยู่ equivalence class เดียวเลือกหนึ่ง representative แม้ shape/syntax ต่างกัน;
  สมาชิกเพิ่มถือเป็น dominated โดยนิยาม. ห้ามเก็บเป็น required/optional row เพียงเพื่อ confirm class
  หรือเพราะอาจแยก path ได้ ถ้ายังไม่มี evidence.
- Final executable ledger แสดงเฉพาะ rows หลัง prune. Candidate/alternate/pruned values อธิบายรวมได้
  เมื่อช่วย review เหตุผล แต่ห้ามค้างเป็น case table, optional row หรือ readiness work. ถ้าไม่มี gap ให้
  สรุป `none` แล้วจบ ห้ามต่อท้าย hypothetical question.

## Fixture และ matrix

- สร้าง fixture ตาม state/role/tenant/currency ที่ failure mode ต้องการ ไม่ใช่ happy path อย่างเดียว
- authz ต้องมี allowed, denied, unauthenticated และ cross-tenant เมื่อเกี่ยวข้อง
- retry/idempotency ต้องส่งซ้ำและตรวจ side effect ไม่ซ้ำ
- time logic ต้องคร่อม business boundary ที่นิยามไว้

## Load และ capacity tests

แยกผลส่งมอบเป็น `harness/script`, `execution` และ `analysis/report`. ยึดรายการที่ผู้ใช้ขอเป็น
primary deliverable; report เป็นหลักฐานประกอบ เว้นแต่ผู้ใช้ขอ report เป็นงานหลัก.

- คำว่า `ทุก` หรือ `ครบ` ให้ enumerate executable matrix และ track `planned / runnable / measured`
  แยกกัน. ห้ามลดเป็น screening/sample เงียบ ๆ; ถ้า cost หรือ safety บังคับให้ลด scope ให้ขออนุมัติ
  semantic change ก่อน
- harness ต้องมี scenario/dimension tags, target guard, metric schema และคำสั่งที่รันซ้ำได้
- ถ้ายังไม่มี performance budget/NFR ให้เก็บ metric แบบ measurement-only และระบุว่าไม่มี pass/fail
  threshold; ห้ามเปลี่ยนงานเป็นการเขียน coverage report
- probe anomaly เท่าที่จำเป็นต่อความถูกต้องของการวัด. finding ที่ไม่บล็อก valid measurement ให้ park
  แล้วทำ matrix ต่อ; ใช้ `performance` เพิ่มเมื่อจะตีความ metric, หา bottleneck หรือเลือก optimization

## วินัยและ verdict

- test ที่พังห้าม skip/comment เพื่อให้ suite เขียว; แก้, แยก flaky พร้อม owner หรือรายงาน blocker
- รายงาน path/input/environment ที่วัดและ coverage gap; build/typecheck เป็น precondition ไม่ใช่หลักฐานแทน runtime path
- bug fix ต้องมี regression test เมื่อทำให้ reproduce ได้อย่างเสถียร
- รัน targeted test และ flow จริงตาม risk; รันไม่ได้ให้รายงาน criterion ที่ยังไม่พิสูจน์
- test suite ต้องมีคำสั่ง canonical ที่รันซ้ำได้และจดใน operational home ที่ repo กำหนด;
  ถ้ายังไม่พบบ้านให้รายงานและเสนอที่เก็บ ห้ามแต่ง path ขึ้นเอง
- ปรับความลึกตาม stage/risk ที่พิสูจน์จาก repo; production path ใช้ `risk-review`
  ร่วมกำหนด smoke/health evidence แต่เงิน, authorization และ tenant isolation เป็นขั้นต่ำทุก stage
- เมื่อ scope ครอบ deployment ให้ smoke consumer flow จริงก่อนปล่อยตาม risk และตรวจ flow/health
  หลังปล่อย; การมี resource หรือ process อยู่ไม่แทนการใช้งานจริง

สรุปด้วย primary deliverable, requirement, test level, fixture/matrix, command/result และ coverage gap
ที่เหลือ โดยแยกสิ่งที่สร้างแล้ว, รันแล้ว และยังเป็นเพียง readiness.
