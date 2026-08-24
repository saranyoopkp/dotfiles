---
name: testing-strategy
description: วางแผนหรือ review test level, regression, fixture/matrix, load/capacity/benchmark และ test harness เมื่อ risk/coverage ไม่ชัด, bug เคยเกิด หรือ suite ผ่านแต่ flow ยังพัง. ไม่ใช้กับการรัน verification command ที่ criterion ชัดแล้ว
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
- test ที่ผ่านยืนยันเฉพาะ path/input/environment ที่รัน; build/typecheck ไม่แทน runtime behavior
- bug fix ต้องมี regression test เมื่อทำให้ reproduce ได้อย่างเสถียร
- รัน targeted test และ flow จริงตาม risk; รันไม่ได้ให้รายงาน criterion ที่ยังไม่พิสูจน์
- test suite ต้องมีคำสั่ง canonical ที่รันซ้ำได้และจดใน operational home ที่ repo กำหนด;
  ถ้ายังไม่พบบ้านให้รายงานและเสนอที่เก็บ ห้ามแต่ง path ขึ้นเอง
- ปรับความลึกตาม stage/risk ที่พิสูจน์จาก repo; production path ใช้ `production-recovery`
  ร่วมกำหนด smoke/health evidence แต่เงิน, authorization และ tenant isolation เป็นขั้นต่ำทุก stage
- เมื่อ scope ครอบ deployment ให้ smoke consumer flow จริงก่อนปล่อยตาม risk และตรวจ flow/health
  หลังปล่อย; การมี resource หรือ process อยู่ไม่แทนการใช้งานจริง

สรุปด้วย primary deliverable, requirement, test level, fixture/matrix, command/result และ coverage gap
ที่เหลือ โดยแยกสิ่งที่สร้างแล้ว, รันแล้ว และยังเป็นเพียง readiness.
