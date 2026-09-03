---
name: testing-strategy:behavior-boundaries
description: ออกแบบ minimal test coverage สำหรับ state/lifecycle, time/order, retry/recovery, failure timing, side effects, concurrency และ compatibility จาก observable contract. ใช้เมื่อ behavior เปลี่ยนตาม event หรือ state; ไม่ใช้กับ validation partitions ที่ไม่ขึ้นกับ state หรือการเลือก test level ทั่วไป
---

# Behavior Boundary Coverage

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

หาก stateful behavior ขึ้นกับ validation/input partition จริง ให้อ่าน
[../input-domains/SKILL.md](../input-domains/SKILL.md) เพิ่ม; ไม่ต้องโหลดเพราะ payload ธรรมดาที่ไม่ได้
เปลี่ยน transition หรือ oracle.

