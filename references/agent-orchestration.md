# Agent Orchestration

## Role กับ execution topology

`SCC`, `Scout` และ `ACV` คือ role ของผู้ปฏิบัติงานใน repository นี้ ส่วน `subagent`, `fork`,
`agent team`, `background session` และ `worktree` คือกลไกจัด context, coordination และ file
isolation ของ Claude Code จึงไม่ควรสร้าง agent role ใหม่เพียงเพราะมี topology ใหม่.

เลือกจาก boundary ของงาน ไม่ใช่จากจำนวนขั้นตอน. งานใหญ่เริ่มจาก foundation ของ Coordinator ก่อน
แตกออกเป็น slices ที่ self-contained เพื่อให้แต่ละ worker ใช้ context ได้พอดีและไม่ตัดสินใจบน
สมมติฐานที่ยังไม่ถูกกำหนด:

1. objective และ acceptance evidence
2. scope, owner, paths, revision/worktree และสิ่งที่ห้ามแตะ
3. dependency/order, shared contract และ assumption ที่ต้องใช้ร่วมกัน
4. verification plan และรูปแบบผลลัพธ์กลับสู่ Coordinator

หลัง foundation แล้ว Coordinator จึงค่อย fan out งานระดับบนสุดตาม boundary. Worker ไม่ควร
redispatch งานต่อเอง เว้นแต่ Coordinator อนุมัติให้แตก independent subtasks อย่างชัดเจน.

| รูปแบบ | ใช้เมื่อ | ขอบเขตที่ต้องรักษา |
|---|---|---|
| Main session / SCC | งานต้องคุยกับผู้ใช้บ่อย, หลายช่วงใช้ context ร่วมกัน หรือแก้เร็ว | SCC ถือ objective, decision และ final verification |
| `subagent` | งานย่อย self-contained, read-only, review หรือ output เยอะจนรบกวน context หลัก | prompt ต้องพก objective, scope, acceptance evidence และ return format; parent ตรวจผลจริง |
| forked subagent | งาน side task หรือการลองหลายแนวทางที่ต้องเห็น conversation เดิม | fork inherit context/tools/permissions ของ parent จึงไม่ใช่ security boundary; ผลต้องกลับมาเป็นหลักฐานที่ parent ตรวจ |
| `agent team` | หลายส่วนมี ownership แยกกันจริงและต้องสื่อสาร/ท้าทายผลกัน | ใช้แบบ opt-in; ไม่เหมาะกับงาน sequential, same-file หรือ dependency หนาแน่น; lead รวมผลและตรวจ acceptance |
| background session | งานอิสระที่รันแยกและไม่ต้องรวมผลทันที | ส่ง handoff ที่มี revision, changed paths, evidence และ limitation; ห้ามถือว่าการรันจบคือการ merge |
| `worktree` | มีหลาย session/agent ที่อาจแก้ไฟล์พร้อมกัน | เป็น file/branch isolation ที่ประกบกับ topology อื่นได้; ต้อง reconcile diff ก่อนรวมผล |

`/branch` หรือ `--fork-session` เป็นการแตก conversation/session เพื่อทดลองแนวทางใหม่โดยเก็บ
ต้นฉบับไว้ ไม่ใช่การสร้าง worker ใน session เดิม. อย่าสับสนกับ forked subagent.

### Delegation packet

ก่อนส่งงานออกจาก main session ให้ระบุเท่าที่จำเป็น:

1. objective และ acceptance evidence ที่ต้องได้
2. scope, paths, revision/worktree และสิ่งที่ห้ามแตะ
3. dependency หรือข้อมูลที่ worker ต้องรู้เองตั้งแต่ต้น
4. สิทธิ์ในการอ่าน/แก้ และเจ้าของการตัดสินใจ
5. รูปแบบผลลัพธ์: claim, evidence/probe, changed paths, tests และ limitation

### Continue หรือ spawn ใหม่

การเรียก `Agent` ใหม่สร้าง context ใหม่เสมอ. ถ้างานเดิมยังไม่จบ ให้ resume agent เดิมด้วย
`SendMessage` ก่อน โดยต้องตรงกันทั้ง objective, acceptance, scope/ownership, repository revision
และ worktree. คำว่า "เกี่ยวข้องกัน" อย่างเดียวไม่พอ: ถ้าเปลี่ยน owner, boundary, dependency หรือ
ต้องการมุมมองอิสระ ให้สร้าง agent ใหม่เพื่อกัน context และสิทธิ์เดิมกระทบงานใหม่. การ resume
ไม่ใช่การอนุมัติให้เปลี่ยน permission, config หรือ CLAUDE.md.

### Hook execution และ feedback ซ้ำ

แยกการยิงตาม lifecycle ออกจาก duplicate execution ก่อนแก้: tool hook เกิดทุก tool call,
`Stop` เกิดทุก turn และ settings/plugin hooks อาจทำงานใน subagent ด้วย. ใช้ `agent_id`/`agent_type`
แยก main กับ subagent เมื่อ hook มี owner เฉพาะฝั่งใดฝั่งหนึ่ง. Handler ที่ต้อง repeat-safe ให้
ใช้ idempotency key จาก event และ identity ของงาน; `Stop` ต้องตรวจ `stop_hook_active` ก่อน block
ซ้ำ. ห้ามใช้ delay/debounce แทนการพิสูจน์ว่า event เดิมหรือคนละ event.

งานที่เป็น platform behavior ให้ตรวจเทียบเอกสารทางการตาม version ที่ใช้งานจริง; reference นี้เก็บ
decision boundary ของ repository ไม่ใช่การคัดลอกคู่มือ Claude Code ทั้งหมด.

แหล่งอ้างอิงทางการ: [subagents](https://code.claude.com/docs/en/sub-agents),
[agent teams](https://code.claude.com/docs/en/agent-teams),
[sessions](https://code.claude.com/docs/en/sessions), [worktrees](https://code.claude.com/docs/en/worktrees)
และ [agent view](https://code.claude.com/docs/en/agent-view).

เมื่องานใช้ multi-agent / delegate ให้ worker — หลักการที่ต้องถือ:

- **Verify ผลจริง ไม่เชื่อคำรายงาน** — agent ตอบ "เสร็จแล้ว" ได้โดยไม่มีผลงานจริง;
  งานสำคัญต้องยืนยันด้วยหลักฐาน (อ่านไฟล์ซ้ำว่า edit ลงจริง, รัน build/test, ดู output)
  ก่อนนับว่าเสร็จ
- **งานที่มี dependency ต้อง stage** — งานที่ upstream ยังไม่เสร็จ ต้องอยู่ในสถานะ
  ที่ worker หยิบไม่ได้ จนกว่า dependency จะจบ; และการเปลี่ยนสถานะงานไม่ได้แปลว่า
  re-dispatch — งานที่เคยรันจบ (แม้ blocked) ต้องสั่งใหม่อย่างชัดเจน
- **สถานะของ orchestration ต้องเขียนได้เสมอ** — ถ้า session/บริบทห้ามเขียน state
  แล้วพบว่า fact เก่าผิด ต้องแนบหมายเหตุ "ค่านี้น่าจะ stale" ไปกับผลงาน
  ไม่ปล่อยให้รอบถัดไปหยิบค่าผิดไปใช้ต่อเงียบ ๆ
- **Worker เริ่มจาก context ว่างเสมอ** — สิ่งที่ orchestrator รู้ worker ไม่รู้;
  prompt ต้องพกบริบทที่จำเป็นครบ (env พร้อมไหม, ไฟล์อยู่ไหน, ติดตั้งอะไรแล้ว)
  หรือให้ worker เช็คเองเป็น step แรก
- **ผลลัพธ์จาก worker คือ input ที่ต้อง validate** — เช่นเดียวกับ input จากภายนอก:
  โครงถูกไหม ครบไหม สอดคล้องกับงานที่สั่งไหม ก่อนเอาไปประกอบต่อ
