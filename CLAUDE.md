# dotfiles — personal Claude Code configuration

สถานะ: active · repository: private · config นี้ใช้ข้ามเครื่องผ่าน link/junction

Project vision และขอบเขตหลักมี canonical owner อยู่ที่ [`README.md`](README.md);
ไฟล์นี้เก็บเฉพาะ operational context สำหรับทำงานกับ repository.

## ทำงานกับ repository นี้

- `claude/rules/` คือ safety invariants แบบสั้นที่โหลดทุก session; domain procedure อยู่ใน skills
- `claude/skills/` คือ playbook ตามประเภทงาน; description ใช้เป็น routing signal และ body โหลดเมื่อ invoke
- `claude/agents/` คือ role definitions ที่ผู้ใช้เลือก trigger เอง: SCC, Scout และ ACV
- `references/` และ `docs/` เป็นข้อมูลอ้างอิงแบบ on-demand
- `test/routing/` และ `test/metrics/` ใช้ทดสอบ routing และวัดพฤติกรรม; ดู README ของแต่ละโฟลเดอร์

## กติกาการออกแบบ config

- rules และ agent specs ต้อง generic: ห้ามใส่ชื่อระบบจริงหรือรายละเอียดเฉพาะ repo งาน
- rule ใหม่ต้องมาจากปัญหาซ้ำที่พิสูจน์ได้, ผ่านกรณีงานธรรมดาที่ไม่ควรถูก trigger และต้องรวมเข้ากฎเดิมก่อนสร้างไฟล์ใหม่
- ทุก instruction ต้องเพิ่ม decision leverage: ช่วยให้ agent เข้าใจ ตัดสินใจ ลงมือ ตรวจ หรือ recover
  ได้ดีขึ้นอย่างมีนัยสำคัญ. “มีเนื้อ” ไม่ได้แปลว่าสั้น แต่ทุก detail ต้องให้ context หรือเปลี่ยน
  การทำงานจริง; ตัด prose, checklist, ceremony และ duplication ที่ไม่สร้างผลดังกล่าว
- เขียน desired behavior หรือ decision path ก่อนข้อห้าม. ข้อห้ามใช้กับ boundary ที่มีความเสียหายจริง
  และต้องบอก trigger, เหตุผล และ next action/alternative ที่ทำให้งานเดินต่อได้ ไม่จบที่ restriction
- ก่อนคง instruction ให้ตอบว่า “ถ้าถอดข้อความนี้ออก การตัดสินใจ การลงมือ หรือการตรวจจะแย่ลงอย่างไร?”
  ถ้าตอบไม่ได้ให้ลดหรือถอดออก
- แก้ behavioral incident ด้วย instruction ที่เล็กที่สุดซึ่งครอบ root cause; ห้าม encode transcript,
  ตัวอย่างเฉพาะเคส หรือ checklist รอบเหตุการณ์นั้นจนกลายเป็น universal workflow. เพิ่ม negative/non-trigger
  case เมื่อมีโอกาส overfit และหยุดเพิ่มทันทีเมื่อหนึ่ง rule + หนึ่ง regression พิสูจน์ behavior ที่ต้องการได้
- **Design invariant — แต่ละ surface สร้างคุณค่าต่างกัน:**

  | Surface | เนื้อที่ควรมี |
  |---|---|
  | `agents/` | trigger → judgment → action → verification/reporting ของผู้ปฏิบัติงาน |
  | `rules/` | shared/safety invariant ที่ต้องจริงเสมอและคุ้มกับการโหลดทุก session |
  | `skills/` | domain procedure, decision criteria และ edge case ที่ต้องรู้เมื่อทำงานชนิดนั้น |
  | `docs/` | rationale, evidence และ operational context ที่ช่วยการตัดสินใจในอนาคต |
  | `tests/` | หลักฐานของ observable behavior, routing หรือ invariant ที่เสี่ยงถดถอย |
  | `memory/` | durable fact หรือ preference ที่ลดการค้นและการอธิบายซ้ำข้าม session |

- เรื่องเดียวกันอยู่ข้ามชั้นได้เฉพาะเมื่อเป็น `invariant → trigger/action → domain procedure`;
  ห้ามคัด prose/checklist เดียวกันหลายชั้นโดยไม่มีหน้าที่เพิ่ม และห้ามลด safety floor เหลือ pointer
  ที่อาจไม่ถูกอ่าน
- detail ที่ผูกกับประเภทงานและกู้คืนได้ ให้เป็น skill; cross-cutting/high-impact ให้เป็น rule
- จัดกลุ่ม skill เมื่อมี sub-concern ที่แยก routing ได้จริง ไม่ใช่เพื่อเผื่ออนาคต
- `CLAUDE.md` นี้เก็บ operational context เท่านั้น; เหตุผลยาว ผลทดลอง และ snapshots อยู่ `docs/`
- `docs-setup` และ artifact ใน kit เป็นข้อยกเว้น: ของที่ copy ไป repo ปลายทางต้อง self-contained
  เพราะปลายทางอาจไม่มี agents/rules/skills ของ dotfiles

## Calibrate constraints for creative work

- แยกงานที่มีคำตอบถูกต้อง/ความเสี่ยงตายตัว ออกจากงาน creative หรือ open-ended ก่อนใช้กฎเข้ม: safety,
  privacy, data integrity, public contract, accessibility และข้อจำกัดที่ผู้ใช้ระบุยังเป็น hard constraint;
  ส่วน aesthetic preference, convention, “ทำให้น้อยที่สุด”, “ใช้ของเดิม” และ “อย่าเติม decoration” เป็น
  default ที่ต้องชั่งกับ brief ไม่ใช่ veto อัตโนมัติ
- เมื่องานขอ creative direction, ความสวย, novelty หรือการเสนอทางเลือก ให้รักษาพื้นที่สำหรับสมมติฐานที่มี
  point of view: สร้าง direction ที่ coherent พร้อมเหตุผลและ trade-off แล้วค่อยตรวจว่าขัด constraint จริง
  หรือไม่. ห้ามลดโจทย์เหลือ checklist ของความปลอดภัย ความสม่ำเสมอ หรือความเรียบร้อยเพียงอย่างเดียว
- เมื่อ aesthetic choice ยังเปิดและมีผลต่อ composition, identity, approach หรือ scope อย่างมีนัยสำคัญ
  คำขอเช่น “ทำให้สวยขึ้น” อนุญาตให้ audit และเสนอทางเลือก แต่ยังไม่อนุญาตให้ agent เลือก direction
  แล้ว mutate เอง: เสนอ 2–3 ทางพร้อม trade-off และ recommendation แล้วรอผู้ใช้เลือก. เมื่อผู้ใช้ระบุ
  หรือเลือก direction แล้วจึงลงมือ; polish เล็ก ๆ ที่ไม่สร้าง creative decision ใหม่ทำต่อได้
- การรอผู้ใช้เลือกไม่ใช่การโยน decision กลับด้วยคำถามกว้าง ๆ: agent ต้องสร้าง proposal ที่เห็นภาพได้
  จากหลักฐานของงานก่อน แล้วค่อยขอให้ผู้ใช้เลือกหรือปรับทิศทาง
- hard gate ต้องผูกกับ failure mode ที่เสียหายจริง มี trigger ชัด และมีทางเลือกให้เดินต่อ; ถ้าเป็นเพียง
  ความชอบหรือการป้องกันความเสี่ยงเชิงสุนทรียะ ให้ใช้เป็นคำแนะนำ/คำถามตรวจ ไม่ใช่คำสั่งปฏิเสธ
- ก่อนเพิ่ม instruction เพื่อกัน bias หรือ overfit ต้องมี negative case ยืนยันว่าไม่กดงานสร้างสรรค์ที่อยู่นอก
  เหตุการณ์ต้นเหตุ และต้องหยุดเมื่อได้ calibration ที่เล็กที่สุดซึ่งแยก hard constraint ออกจาก creative
  freedom ได้

## การติดตั้งและความเข้ากันได้

- `install.sh` ทำ link สำหรับ macOS/Linux; Windows ใช้ Git Bash สำหรับ script ที่ deploy หรือ hook
- `~/.claude/skills` เป็นของ harness: link skill เป็นรายตัว ไม่ link ทั้ง directory
- `~/.claude/agents` และ `~/.claude/rules` link ทั้ง directory จาก source ใน repo; agent path เดิมที่
  ไม่ใช่ link ต้อง backup แบบ collision-safe ก่อนติดตั้ง
- script ที่ deploy/hook ใช้ Bash เดียว; เครื่องมือวิเคราะห์ใน `test/` ใช้ Python ได้
- hook ที่รันจริงอาจมี environment ต่างจาก Bash tool ของ agent; การแก้ hook ต้องให้ผู้ใช้ restart session และยืนยันผลจริงก่อนสรุปว่าหาย

## เอกสารและ memory

- `/docs:setup` วางหรือปรับระบบเอกสารของ repo; kit ใน `claude/skills/docs/setup/kit/` คือ source of truth ของกลไก
- `/docs:workspace` จัด owner ของ fact และเอกสาร cross-repo ใน workspace ที่มีหลาย independent Git roots; repo เดี่ยว/monorepo ยังใช้ setup/placement เดิม
- template ถูก copy ตอน setup แรก ไม่ sync กลับอัตโนมัติ; re-apply ต้อง merge โดยรักษา customization ของ repo
- memory ของ repo อยู่ใน repository และ harness link เข้ามา; private data ใช้
  `docs/private/` หรือ `memory/private/` ของ repo นั้น ๆ (relative จาก Git root) และต้อง gitignore

## การตรวจและการเปลี่ยนแปลง

- current owner/routing map อยู่ใน `docs/claude-code-mechanisms.md`; การแก้ agents/rules/skills
  ข้าม owner ต้องแสดง impact map ตาม `claude/rules/core/change-control.md` ก่อน mutation
  และ reconcile กับ diff จริงหลังแก้
- แก้ skill แล้วรัน `test/routing/run.sh` เมื่อ routing หรือ behavior ที่เกี่ยวข้องเปลี่ยน
- แก้ skill tree หรือ routing graph แล้วรัน `python3 test/config/verify-skill-routing-graph.py --self-test`
- อย่าสรุปว่า integration/hook ใช้ได้จาก simulation เพียงอย่างเดียว; ระบุข้อจำกัดของหลักฐานเสมอ
- ACV เป็น role ตรวจรับแบบอิสระเมื่อผู้ใช้ trigger; เมื่อ change เข้า 5 acceptance triggers ให้ SCC suggest
  การตรวจ ACV ได้ แต่ห้ามเรียกเองหรือ block delivery; งานเอกสารหรือการสำรวจไม่ต้องตรวจรับเว้นแต่กำหนดไว้

## เอกสารอ้างอิง

- กลไก Claude Code และข้อจำกัด: `docs/claude-code-mechanisms.md`
- routing graph และ trigger ของ skill: `docs/skill-routing-graph.md`
- audit และ baseline: `docs/dogfood-audit-2026-07-15.md`
- การทดลองพฤติกรรม SCC และ cutovers: `docs/scc-behavior-experiment.md`
- hook behavior: `docs/hook-saga.md`

## งานที่ติดตาม

ดู TODO และผลวัดล่าสุดในเอกสาร experiment/audit ที่เกี่ยวข้อง; อย่าคัดลอกตัวเลขหรือสถานะมาไว้ที่นี่.
