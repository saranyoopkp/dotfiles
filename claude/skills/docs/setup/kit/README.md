# Docs Setup Kit

Kit นี้สร้างระบบเอกสารขั้นต่ำต่อ repository: `CLAUDE.md`, `docs/`, `memory/` และ hook เตือน docs drift

## สิ่งที่สร้างและเจ้าของ

| สิ่ง | หน้าที่ | เจ้าของ |
|---|---|---|
| `CLAUDE.md` | บริบทปัจจุบันที่จำเป็นทุก session | repository |
| `docs/` | รายละเอียดที่เปิดตามหัวข้อ | repository |
| `memory/` | facts/quirks สั้นที่ harness recall ได้ | repository |
| `.claude/hooks/docs-drift.sh` | เตือนจังหวะตรวจเอกสาร | kit |
| `.claude/settings.json` | ตั้งค่า hook | kit |

ไฟล์ที่ copy เข้า repo ต้อง self-contained: ห้ามอ้าง path ของ kit หรือ user-level rule. ข้อมูล sensitive อยู่ใน `docs/private/` หรือ `memory/private/` ที่ gitignore เท่านั้น

## ใช้งาน

```bash
bash <path-to-kit>/init.sh /path/to/repo
```

สำหรับ repo ใหม่ ให้เติม template จากโครงสร้างจริง, manifest/CI, เอกสารเดิม และ git history จากนั้นเพิ่ม memory facts ที่มีประโยชน์

สำหรับ repo เดิม ให้รัน init เพื่อสร้าง link และไฟล์ที่ kit เป็นเจ้าของ แล้ว merge `CLAUDE.template.md` ด้วยตนเองโดยรักษา customization ของ repo

รัน init ซ้ำได้: มันอัปเดต hook และซ่อม memory link แต่ไม่ทับ `CLAUDE.md` หรือ settings ที่ repo เป็นเจ้าของ

## Memory link

`~/.claude/projects/<id>/memory` เป็น junction บน Windows หรือ symlink บน Unix ที่ชี้มายัง `<repo>/memory`; จึงไม่มีการ sync ด้วยมือ

หากย้ายเครื่อง ให้รัน init อีกครั้ง หากพบ memory เดิมที่ไม่ใช่ link ให้ merge เข้า repo ก่อนเก็บ backup

## Hooks

hook ส่ง additional context ที่ SessionStart, TaskCompleted, Stop และ PreCompact เพื่อเตือนเรื่อง docs/memory ไม่ block งาน

hook runner อาจต่างจาก Bash tool ของ agent; การแก้ hook ต้องทดสอบใน session จริงก่อนสรุปผล

## ขอบเขต

- ใช้ `/docs:placement` เมื่อต้องเลือกบ้านของเนื้อหา
- ใช้ `/docs:link` หลังย้าย/rename เอกสาร
- ใช้ `/docs:stale` เพื่อตรวจว่าเอกสารยังตรงกับระบบจริง
- hook เป็น reminder ไม่ใช่หลักฐานว่าเอกสารหรือระบบถูกต้อง
