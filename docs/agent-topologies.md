# Agent topologies — reader reference

เอกสารนี้มีไว้ให้คนอ่านเพื่อเข้าใจกลไกการทำงานของ Claude Code เท่านั้น ไม่ใช่ active instruction
และไม่ใช่ routing policy ของ repository. ปัจจุบัน repository นี้ไม่เลือกหรือเรียก topology อัตโนมัติ;
ผู้ใช้เป็นผู้ manual-trigger เองเมื่อเห็นว่าจำเป็น.

## Role กับ topology

`SCC`, `Scout` และ `ACV` เป็น role ของผู้ปฏิบัติงาน ส่วน `subagent`, `fork`, `agent team`,
`background session` และ `worktree` เป็นกลไกจัด context, coordination หรือ file isolation.
การเพิ่ม topology ไม่ได้แปลว่าต้องสร้าง role ใหม่.

| รูปแบบ | ความหมายโดยย่อ | จุดที่ต้องระวัง |
|---|---|---|
| Main session / SCC | session หลักที่คุยกับผู้ใช้และถือ objective | เหมาะกับงานที่ต้องตัดสินใจหรือแก้ต่อเนื่อง |
| `subagent` | context แยกสำหรับงานย่อยที่ self-contained หรือ read-only | context ไม่ได้รู้สิ่งที่ parent รู้โดยอัตโนมัติ; ผลลัพธ์ต้องตรวจซ้ำ |
| `fork` | แตก session จากบทสนทนาเดิมเพื่อทดลอง side task | เห็น context เดิมได้ แต่ไม่ใช่ security boundary และผลไม่ merge เอง |
| `agent team` | หลาย agent ที่มี ownership แยกและประสานงานกัน | ไม่เหมาะกับงาน sequential, same-file หรือ dependency หนาแน่น |
| `background session` | session อิสระที่ทำงานนานโดยไม่ต้องรอผลทันที | การรันจบไม่ได้แปลว่างานถูกรวม, verified หรือส่งมอบแล้ว |
| `worktree` | checkout/branch แยกเพื่อป้องกันการแก้ไฟล์ชนกัน | เป็น file/branch isolation ไม่ใช่ role และต้อง reconcile diff ก่อนรวม |

`/branch` หรือ `--fork-session` คือการแตก conversation/session เพื่อเก็บต้นฉบับไว้ทดลอง
ไม่ใช่การสร้าง worker ใน session เดิม.

## เมื่อ manual-trigger เอง

ควรส่งข้อมูลให้ session/agent ที่ถูกเรียกให้พอทำงานได้โดยไม่ต้องเดาบริบท:

1. objective และผลลัพธ์ที่ต้องการ
2. acceptance evidence
3. scope, paths, revision/worktree และสิ่งที่ห้ามแตะ
4. dependency หรือ assumption ที่จำเป็น
5. รูปแบบผลลัพธ์ที่ต้องส่งกลับ

ผลจาก session อื่นเป็น input สำหรับตรวจสอบ ไม่ใช่หลักฐานยอมรับงานโดยอัตโนมัติ. ก่อนรวมผล
ให้ตรวจ changed paths, diff, test/output และ limitation กับ revision ปัจจุบัน.

หากจะต่อ session เดิม ควรแน่ใจว่า objective, acceptance, scope/owner, revision และ worktree
ยังเป็นเรื่องเดียวกันจริง; ถ้าเป็นคนละ boundary ให้เริ่ม context ใหม่เพื่อกัน blast.

## แหล่งอ้างอิงทางการ

- [Subagents](https://code.claude.com/docs/en/sub-agents)
- [Agent teams](https://code.claude.com/docs/en/agent-teams)
- [Sessions](https://code.claude.com/docs/en/sessions)
- [Worktrees](https://code.claude.com/docs/en/worktrees)
- [Agent view](https://code.claude.com/docs/en/agent-view)
