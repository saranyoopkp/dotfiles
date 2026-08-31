# dotfiles (ฉบับภาษาไทย)

Personal cross-machine config for Claude Code.

> English version: [`README.md`](README.md)

## Vision

dotfiles นี้คือชุด configuration และกรอบการทำงานสำหรับ software agent
ที่ช่วยเปลี่ยนเจตนาของผู้ใช้ให้เป็นซอฟต์แวร์ที่ถูกต้อง พร้อมใช้งาน
อยู่ในขอบเขตที่ได้รับอนุญาต และตรวจสอบได้ โดยผสานวิจารณญาณของ agent,
engineering invariants, domain procedures และวงจรเรียนรู้จากพฤติกรรม
ที่เกิดขึ้นจริงข้ามทุกโปรเจกต์และทุกเครื่อง

เป้าหมายไม่ใช่สร้าง agent ที่ทำงานมากที่สุดหรือแก้ทุกสิ่งที่พบ แต่สร้าง agent ที่:

- รักษา objective และ authorization boundary ของผู้ใช้
- ทำงานสอดคล้องกับเจตนา วิธีคิด และจังหวะของผู้ใช้ โดยไม่ทำให้ผู้ใช้ต้องคอยดึงกลับ
  ย้ำ scope หรืออธิบายความหมายซ้ำโดยไม่จำเป็น
- ขุด root cause และ dependency ที่จำเป็นต่อผลลัพธ์เดิม โดยไม่ขยาย scope เอง
- เลือกหลักฐานที่พิสูจน์ claim และ behavior ที่กำลังส่งมอบจริง
- ใช้ autonomy ให้ได้สัดส่วนกับความเสี่ยงและผลกระทบ
- เรียนรู้จาก behavioral signals และ pattern ที่ตรวจสอบได้ ทั้งสิ่งที่ควรปรับและสิ่งที่ควรรักษา
  โดยไม่สะสมกฎหรือความซับซ้อนเกินจำเป็น
- ทำงานข้าม repository และเครื่องได้อย่างสม่ำเสมอ โดยเคารพบริบทของแต่ละระบบ

โครงสร้างนำ vision นี้ไปใช้โดยแยกหน้าที่เป็น `rules` สำหรับ shared invariants,
`agents` สำหรับ trigger และการตัดสินใจ, `skills` สำหรับ domain procedures
และ `tests` สำหรับตรวจ routing กับ behavior ที่เกิดขึ้นจริง

รายละเอียดเชิงปฏิบัติอยู่ใน [`CLAUDE.md`](CLAUDE.md) ส่วนเหตุผล การทดลอง
และหลักฐานย้อนหลังอยู่ใน [`docs/`](docs/)

## โครงสร้าง

```
claude/rules/               ← engineering standards — โหลดทุก session ทุก repo
claude/skills/              ← domain procedures แบบ on-demand
claude/agents/              ← SCC ทำงานหลัก, Scout สำรวจแบบ read-only, ACV ตรวจรับ
test/routing/               ← regression ของ skill auto-invocation
test/friction/              ← regression กัน ceremony ในงานง่าย
test/config/                ← ตรวจ guardrail และการติดตั้ง
test/metrics/               ← pipeline วัดพฤติกรรมจาก session corpus
references/                 ← เปิดดูตามต้องการ (ไม่โหลดเข้า session)
install.sh                  ← link ~/.claude/{skills,rules}; agents เป็น link ที่จัดการต่อเครื่อง
```

## การใช้งาน agents

เริ่มงานกับ SCC โดยบอกผลลัพธ์ ขอบเขต และข้อจำกัดตามปกติ. ผู้ใช้เป็นผู้เลือก trigger เองว่าจะใช้
Scout สำหรับ discovery แบบ read-only หรือ ACV สำหรับการตรวจรับอิสระ; ไม่มีการ delegate หรือเลือก
execution topology อัตโนมัติ. Scout ไม่แก้ไฟล์ และ ACV ไม่แก้โค้ด.

คำอธิบายสำหรับคนอ่านเกี่ยวกับ subagent, team, fork, background session และ worktree อยู่ที่
[`docs/agent-topologies.md`](docs/agent-topologies.md); เอกสารนี้ไม่ใช่ active instruction
และไม่เปิดการ delegate อัตโนมัติ.

## Setup เครื่องใหม่

```bash
git clone <this-repo> && cd dotfiles && bash install.sh   # Windows: Git Bash
```
```bash
git clone <this-repo> && ./dotfiles/install.sh            # macOS/Linux
```

แล้วใน repo ไหนก็พิมพ์ `/docs:setup` ใน Claude Code ได้เลย (รวมถึง repo เดิมที่ clone
มาเครื่องใหม่ — ต้องเรียกครั้งหนึ่งเพื่อสร้าง memory link ของเครื่องนั้น)

แก้ skill/rules → แก้ในนี้ + commit + push; เครื่องอื่น pull (link ชี้มาที่ repo นี้ ไม่ต้อง install ซ้ำ)

**ข้อยกเว้น: `claude/skills/docs/setup/kit/CLAUDE.template.md`** — ไฟล์นี้ถูก **copy** เป็น
`CLAUDE.md` ของแต่ละ repo ตอน setup ครั้งแรก ไม่ใช่ link แก้ template แล้ว**ไม่ sync อัตโนมัติ**
ไปยัง repo ที่เคย `/docs:setup` ไปแล้ว — ต้องไป re-apply เองทีละ repo (ดู
`claude/skills/docs/setup/SKILL.md` section "Re-apply / upgrade": diff เนื้อหา
Memory policy/checklist กับ template ปัจจุบันแล้ว merge โดยรักษา customization ของ repo นั้นไว้)
