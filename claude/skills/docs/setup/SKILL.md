---
name: docs:setup
description: Set up or refactor a repo documentation system (CLAUDE.md, docs, memory and hooks) from the user's docs kit. Use when asked to set up/refactor project docs, CLAUDE.md, or project memory.
---

# Docs Setup

อ่าน `${CLAUDE_SKILL_DIR}/kit/README.md` ก่อนเสมอ: kit เป็น source of truth ของกลไก ส่วนหลักการใช้ rule `documentation-discipline` และ skill `/docs:placement`.

## ผลลัพธ์ที่ต้องการ

- `CLAUDE.md` เป็นบริบทปัจจุบันแบบสั้น ไม่ใช่ changelog
- `docs/` เก็บรายละเอียดที่เปิดตามหัวข้อ; `memory/` เก็บ fact/quirk สั้นที่ต้อง recall
- memory ของ harness link เข้าสู่ repo เดียวกัน และข้อมูล sensitive อยู่ใน path ที่ gitignore
- hook เตือนจังหวะที่ docs drift ได้ แต่ไม่แทนการตรวจเนื้อหา

## Gather ก่อนเขียน

1. อ่านเอกสารและ memory เดิมเพื่อรักษา decision ที่ยังใช้ได้
2. ตรวจ manifest, layout, CI และ entry points เพื่อเห็นระบบจริง
3. ดู git history ล่าสุดและ TODO/FIXME เพื่อหา quirks หรือหนี้ที่มีหลักฐาน
4. เทียบสิ่งที่เอกสารกล่าวกับโครงสร้างจริง; ถ้า intent สำคัญหาไม่ได้จากหลักฐาน ให้ถามผู้ใช้เป็นชุดเดียว

ทุก claim ใน `CLAUDE.md` ต้องชี้กลับไปที่หลักฐานหรือ decision ของผู้ใช้ได้

## ทำงาน

- repo ใหม่: รัน `bash ${CLAUDE_SKILL_DIR}/kit/init.sh <repo>` แล้วเติม context ที่ตรวจพบ, สร้าง memory facts ที่มีประโยชน์
- repo เดิม: รัน init เพื่อ setup link/mechanical files แล้ว merge template ด้วยตนเอง โดยไม่เขียนทับ customization
- re-apply: ให้ init จัดการไฟล์ที่ kit เป็นเจ้าของ; ส่วนเนื้อหาให้ gather และ merge เหมือน repo เดิม
- หลังจัดหรือย้ายเนื้อหา ใช้ `/docs:link`; ใช้ `/docs:stale` เมื่อต้องตรวจความจริงของเนื้อหา

อย่าใส่ secret, IP, credential หรือ procedure ที่เสี่ยงลงไฟล์ tracked.
