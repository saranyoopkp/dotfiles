# memory/

Version-controlled project memory — **the only copy**.

The Claude Code harness memory dir (`~/.claude/projects/<id>/memory`) is a **link**
(Windows junction / unix symlink, created when this repo was set up) pointing here,
so the harness reads/writes these exact files. No manual sync.

กติกา:
- 1 ไฟล์ = 1 fact — สั้น อ่านจบใน 30 วินาที; เรื่องใหญ่ให้ไป `docs/` แล้ว memory เป็น pointer
- ทุกไฟล์มี frontmatter ตาม `_fact.template.md` (name/description/type)
- `MEMORY.md` เก็บเฉพาะ pointer + recall hook ของ shared fact; leaf ไม่ถูกเปิดตาม pointer เอง
- create/move/rename/delete shared leaf → เพิ่ม/แก้/ลบ index entry ใน commit เดียวกัน;
  edit leaf → ตรวจว่า title/hook/relevance ยังตรงและแก้ index เมื่อความหมายเปลี่ยน
- `memory/private/` ของ repo นั้น ๆ (relative จาก Git root) ไม่อยู่ใน index;
  เรื่องเฉพาะเครื่องต้องค้นแยกก่อนสรุปว่าไม่มี
- memory ใหม่ที่ harness บันทึก = untracked file ใน repo → คัดกรองแล้ว commit
- fact ที่ผิดแล้ว = ลบทิ้ง อย่าเก็บของเก่าไว้หลอก session หน้า
- ย้าย repo ไปเครื่องอื่น → link ฝั่ง harness จะไม่มี ต้องสร้างใหม่ (คำสั่งอยู่ใน CLAUDE.md section "Memory policy")
