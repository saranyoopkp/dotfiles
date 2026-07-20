# Docs Setup Kit

Kit นี้สร้างระบบเอกสารขั้นต่ำต่อ repository: `CLAUDE.md`, `docs/`, `memory/` และ hook เตือน docs drift. Repository ปลายทางต้องใช้ต่อได้แม้ไม่มี dotfiles, rules หรือ skills ชุดนี้ติดตั้งอยู่

## สิ่งที่สร้างและเจ้าของ

| สิ่ง | หน้าที่ | เจ้าของ |
|---|---|---|
| `CLAUDE.md` | บริบทปัจจุบันที่จำเป็นทุก session | repository |
| `docs/` | รายละเอียดที่เปิดตามหัวข้อ | repository |
| `memory/` | facts/quirks สั้นที่ harness recall ได้ | repository |
| `.claude/hooks/docs-drift.sh` | เตือนจังหวะตรวจเอกสาร | kit |
| `.claude/settings.json` | ตั้งค่า hook | kit |

ไฟล์ที่ copy เข้า repo ต้อง self-contained: ห้ามอ้าง path ของ kit, user-level rule หรือชื่อ skill ที่อาจไม่มีบนเครื่องอื่น. `CLAUDE.template.md` จึงมี operating contract แบบ portable (scope, evidence, safety, verification และ handoff) พร้อม policy สำหรับการเลือกที่อยู่ของความรู้, memory, task-close และการตรวจความจริงของเอกสารอยู่ในตัว

Identity ของ kit นี้คือ: **lean current context ใน `CLAUDE.md` → รายละเอียดใน `docs/` → facts ที่ต้อง recall ใน `memory/`**. นี่คือ convention ที่คัดลอกไปพร้อมกันทุก repo ไม่ใช่ dependency บน dotfiles repository นี้

## ใช้งาน

```bash
bash <path-to-kit>/init.sh /path/to/repo
```

สำหรับ repo ใหม่ ให้เติม template จากโครงสร้างจริง, manifest/CI, เอกสารเดิม และ git history จากนั้นเพิ่ม memory facts ที่มีประโยชน์

สำหรับ repo เดิม ให้รัน init เพื่อสร้าง link และไฟล์ที่ kit เป็นเจ้าของ แล้ว merge `CLAUDE.template.md` ด้วยตนเองโดยรักษา customization ของ repo

รัน init ซ้ำได้: มันอัปเดต hook และซ่อม memory link แต่ไม่ทับ `CLAUDE.md` หรือ settings ที่ repo เป็นเจ้าของ

## Memory link

`~/.claude/projects/<id>/memory` **ต้อง**เป็น junction บน Windows หรือ symlink บน Unix ที่ชี้มายัง `<repo>/memory`; จึงไม่มีการ sync ด้วยมือ และ setup ไม่สมบูรณ์หาก path นี้เป็น directory ปกติ

หากย้ายเครื่อง ให้รัน init อีกครั้ง หากพบ memory เดิมที่ไม่ใช่ link ให้ merge เข้า repo ก่อนเก็บ backup

## Hooks

hook ส่ง additional context และไม่ block งาน:

| Event | หน้าที่ |
|---|---|
| `SessionStart` | ตรวจงานค้างจาก session ก่อนและ memory link |
| `TaskCompleted` | checkpoint ว่า docs/decision/memory ตามงานทันหรือไม่ |
| `Stop` | เตือน docs หรือ memory ที่ยังไม่ commit โดยไม่ spam |
| `PreCompact` | เตือนให้บันทึก context สำคัญก่อนถูกย่อ |

hook runner อาจต่างจาก Bash tool ของ agent; การแก้ hook ต้องทดสอบใน session จริงก่อนสรุปผล

## ขอบเขต

- เลือกบ้านตามจังหวะที่ผู้อ่านต้องใช้: current context → `CLAUDE.md`, รายละเอียดตามหัวข้อ → `docs/`, fact ที่ต้อง recall → `memory/`, contract/constraint ติดโค้ด → comment หรือ docstring
- หลังย้าย/rename เอกสาร ให้ตรวจ link ด้วยคำสั่งหรือเครื่องมือที่มีอยู่
- เมื่อตรวจ stale ให้เทียบ claim กับ command, code, config หรือ test ที่ live; hook เป็น reminder ไม่ใช่หลักฐานว่าเอกสารหรือระบบถูกต้อง

## Re-apply และ refactor

รัน init ซ้ำได้เพื่ออัปเดตไฟล์ที่ kit เป็นเจ้าของ เช่น hook และซ่อม memory link. อย่า overwrite `CLAUDE.md` ที่ repository ปรับเอง: อ่านของเดิม, gather context จาก code/config/docs/history แล้ว merge policy หรือ section ใหม่อย่างตั้งใจ

หาก `CLAUDE.md` กลายเป็น changelog ยาว ให้แยก:

1. context/decision/quirk ที่ยังมีผลไว้ใน `CLAUDE.md` แบบสั้น
2. rationale, runbook, history และผลทดลองไป `docs/<topic>.md`
3. fact/กับดักที่ session หน้าต้อง recall ไป `memory/<fact>.md`
4. ตรวจ index และ links หลังย้าย; อย่าคัดลอกข้อมูลที่ code หรือคำสั่งสร้างใหม่ได้

สำหรับ monorepo/submodule ให้เก็บ docs ของ module ไว้ใน module และเก็บ root ไว้สำหรับเรื่อง cross-cutting เท่านั้น
