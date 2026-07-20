# dotfiles — personal Claude Code configuration

สถานะ: active · repository: private · config นี้ใช้ข้ามเครื่องผ่าน link/junction

## ทำงานกับ repository นี้

- `claude/rules/` คือ default engineering principles ที่โหลดทุก session; อ่าน [00-how-to-read-these-rules.md](claude/rules/00-how-to-read-these-rules.md) ก่อนเพิ่มหรือย้าย rule
- `claude/skills/` คือ playbook ตามประเภทงาน; description ใช้เป็น routing signal และ body โหลดเมื่อ invoke
- `claude/agents/` คือ SCC (ทำงานหลัก) และ ACV (ตรวจรับอิสระ)
- `references/` และ `docs/` เป็นข้อมูลอ้างอิงแบบ on-demand
- `test/routing/` และ `test/metrics/` ใช้ทดสอบ routing และวัดพฤติกรรม; ดู README ของแต่ละโฟลเดอร์

## กติกาการออกแบบ config

- rules และ agent specs ต้อง generic: ห้ามใส่ชื่อระบบจริงหรือรายละเอียดเฉพาะ repo งาน
- rule ใหม่ต้องมาจากปัญหาซ้ำที่พิสูจน์ได้ และต้องรวมเข้ากฎเดิมก่อนสร้างไฟล์ใหม่
- detail ที่ผูกกับประเภทงานและกู้คืนได้ ให้เป็น skill; cross-cutting/high-impact ให้เป็น rule
- จัดกลุ่ม skill เมื่อมี sub-concern ที่แยก routing ได้จริง ไม่ใช่เพื่อเผื่ออนาคต
- `CLAUDE.md` นี้เก็บ operational context เท่านั้น; เหตุผลยาว ผลทดลอง และ snapshots อยู่ `docs/`

## การติดตั้งและความเข้ากันได้

- `install.sh` ทำ link สำหรับ macOS/Linux; Windows ใช้ Git Bash สำหรับ script ที่ deploy หรือ hook
- `~/.claude/skills` เป็นของ harness: link skill เป็นรายตัว ไม่ link ทั้ง directory
- agent directory บนเครื่องนี้ชี้ที่ `claude/agents/`; เครื่องอื่นต้องสร้าง link ของตนเอง
- script ที่ deploy/hook ใช้ Bash เดียว; เครื่องมือวิเคราะห์ใน `test/` ใช้ Python ได้
- hook ที่รันจริงอาจมี environment ต่างจาก Bash tool ของ agent; การแก้ hook ต้องให้ผู้ใช้ restart session และยืนยันผลจริงก่อนสรุปว่าหาย

## เอกสารและ memory

- `/docs:setup` วางหรือปรับระบบเอกสารของ repo; kit ใน `claude/skills/docs/setup/kit/` คือ source of truth ของกลไก
- template ถูก copy ตอน setup แรก ไม่ sync กลับอัตโนมัติ; re-apply ต้อง merge โดยรักษา customization ของ repo
- memory ของ repo อยู่ใน repository และ harness link เข้ามา; ข้อมูล sensitive อยู่ใน path ที่ gitignore เท่านั้น

## การตรวจและการเปลี่ยนแปลง

- แก้ skill แล้วรัน `test/routing/run.sh` เมื่อ routing หรือ behavior ที่เกี่ยวข้องเปลี่ยน
- อย่าสรุปว่า integration/hook ใช้ได้จาก simulation เพียงอย่างเดียว; ระบุข้อจำกัดของหลักฐานเสมอ
- SCC ส่งงานที่เปลี่ยน behavior, public API หรือมี production/user risk ให้ ACV ตรวจ; งานเอกสารหรือการสำรวจไม่ต้องส่งเว้นแต่กำหนดไว้

## เอกสารอ้างอิง

- กลไก Claude Code และข้อจำกัด: `docs/claude-code-mechanisms.md`
- audit และ baseline: `docs/dogfood-audit-2026-07-15.md`
- การทดลองพฤติกรรม SCC และ cutovers: `docs/scc-behavior-experiment.md`
- hook behavior: `docs/hook-saga.md`

## งานที่ติดตาม

ดู TODO และผลวัดล่าสุดในเอกสาร experiment/audit ที่เกี่ยวข้อง; อย่าคัดลอกตัวเลขหรือสถานะมาไว้ที่นี่.
