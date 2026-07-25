# dotfiles

Personal cross-machine config for Claude Code.

```
claude/skills/docs/setup/   ← /docs:setup skill + kit (ระบบเอกสารต่อ repo)
claude/rules/               ← engineering standards — โหลดทุก session ทุก repo
references/                 ← เปิดดูตามต้องการ (ไม่โหลดเข้า session) — ดูรายการจากโฟลเดอร์จริง
install.sh                  ← link ~/.claude/{skills,rules} เข้า repo นี้ (junction/symlink)
```

## Setup เครื่องใหม่

```bash
git clone <this-repo> && cd dotfiles && bash install.sh   # Windows: Git Bash
```
```bash
git clone <this-repo> && ./dotfiles/install.sh     # macOS/Linux
```

แล้วใน repo ไหนก็พิมพ์ `/docs:setup` ใน Claude Code ได้เลย (รวมถึง repo เดิมที่ clone
มาเครื่องใหม่ — ต้องเรียกครั้งหนึ่งเพื่อสร้าง memory link ของเครื่องนั้น)

แก้ skill/rules → แก้ในนี้ + commit + push; เครื่องอื่น pull (link ชี้มาที่ repo นี้ ไม่ต้อง install ซ้ำ)

**ข้อยกเว้น: `claude/skills/docs/setup/kit/CLAUDE.template.md`** — ไฟล์นี้ถูก **copy** เป็น `CLAUDE.md` ของแต่ละ repo
ตอน setup ครั้งแรก ไม่ใช่ link แก้ template แล้ว**ไม่ sync อัตโนมัติ**ไปยัง repo ที่เคย
`/docs:setup` ไปแล้ว — ต้องไป re-apply เองทีละ repo (ดู `claude/skills/docs/setup/SKILL.md` section
"Re-apply / upgrade": diff เนื้อหา Memory policy/checklist กับ template ปัจจุบันแล้ว merge
โดยรักษา customization ของ repo นั้นไว้)
