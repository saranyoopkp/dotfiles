# test/behavior — lean agent decision regression

ชุดนี้เปรียบเทียบ next-action decision ของ agent ก่อนและหลังลด instruction โดยให้แต่ละ scenario
เลือกคำตอบจาก enum ที่ตรวจแบบ deterministic. ใช้กับ generic behavior ที่เคยเกิด pain จริง เช่น
objective continuity, scope control, reversibility, evidence, delegation และ product/diagnostic boundary.
`team-scenarios.tsv` แยกตรวจ foundation-first orchestration, solo/subagent/team gate, file/contract
ownership และ model escalation; เลือกรันผ่าน `BEHAVIOR_SCENARIOS`.

ชุดนี้วัด **decision ที่ agent ส่งออก** ไม่ได้พิสูจน์ว่า tool execution จริงจะตรงเสมอ. Routing ใช้
`test/routing/` ซึ่งตรวจ `Skill` tool use จาก stream-json; runtime behavior ต้องตรวจใน session จริงเพิ่ม.

## รัน

```bash
bash test/behavior/run.sh
```

ตัวแปรที่ใช้ได้:

- `BEHAVIOR_AGENT` — agent ที่ทดสอบ; default `SCC-v1.0.1`
- `BEHAVIOR_MODEL` — model override; ไม่ตั้ง = ใช้ default ปัจจุบัน
- `BEHAVIOR_SCENARIOS` — path ของ TSV; default `test/behavior/scenarios.tsv`
- `BEHAVIOR_SANDBOX` — ที่เก็บ artifacts; ไม่ตั้ง = temporary directory

Artifacts อยู่ `$BEHAVIOR_SANDBOX/runs/<timestamp>/` และเก็บ JSON/result ต่อ scenario เพื่อเทียบ
เหตุผลภายหลัง. การผ่านยืนยันเฉพาะ decision cases ในชุดนี้ ไม่ใช่ acceptance ของ config ทั้งระบบ.
