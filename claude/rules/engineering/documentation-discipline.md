# Documentation Discipline

ใช้กับทุก repo; งาน setup, placement, workspace, link และ stale audit ใช้ `/docs:*`.

## Invariant

- `CLAUDE.md` คือสถานะปัจจุบัน ไม่ใช่ changelog; decision จดเหตุผล ทางที่ไม่เลือก และวันที่
- อัปเดตเอกสารใน commit เดียวกับงาน และจดเฉพาะสิ่งที่โค้ดเล่าเองไม่ได้
- fact มีบ้านเดียว: `CLAUDE.md` = push, `docs/` = pull, `MEMORY.md` = recall router,
  `memory/<fact>.md` = selective pull; ที่อื่นใช้ pointer ไม่คัดเนื้อซ้ำ
- create/move/rename/delete shared `memory/<fact>.md` ต้องเพิ่ม/แก้/ลบ pointer + recall hook
  ใน `memory/MEMORY.md` commit เดียวกัน; แก้เนื้อหาให้ตรวจว่า hook ยังตรงและแก้เมื่อความหมายเปลี่ยน
- sensitive/private ห้ามอยู่ในไฟล์ที่ git track: operational docs ใช้ `docs/private/` และ
  fact ส่วนตัว/เฉพาะเครื่องใช้ `memory/private/` ของ repo นั้น ๆ (relative จาก Git root);
  gitignore ทั้งคู่และห้าม index private memory ลง shared `MEMORY.md`
- fact ที่สร้างซ้ำได้จาก code/schema/command ให้ชี้ source ไม่ hardcode สำเนา
- point-in-time doc ระบุวันที่/scope; living doc ต้องตรงกับ state ปัจจุบัน
- finding ถาวรต้องมี `status (Verified/Unverified/Contradicted)`, provenance และ checked date
- internal docs ใช้ภาษาที่ทำให้จดจริง (ไทยได้); code, identifier และ commit ใช้อังกฤษ

## จังหวะจด

- เมื่อปิดงาน mutation หนึ่งชิ้น ให้ตรวจและอัปเดต CLAUDE.md/docs/memory ทันที ไม่รอจบ session;
  default คือ inventory/decision/quirk สั้น ๆ ใช้เวลาเป็นนาที ไม่ใช่เรียงความ
- quirk หรือปัญหาที่ใช้เวลาหาสาเหตุให้จด `symptom → root cause → fix` พร้อมข้อจำกัดที่ยังมีผล
- เมื่อผู้ใช้ต้องทัก pain, preference หรือ behavior เดิมเป็นครั้งที่สอง ให้เสนอทำเป็น durable record
  ใน owner ที่ถูกต้อง; ถ้าอยู่ใน scope mutation ที่อนุมัติแล้วให้อัปเดตพร้อมงาน
- docs กองแบนเกิน ~7 ไฟล์, index ไม่ตรงไฟล์จริง หรือบ้านของ fact ไม่ชัด ให้ invoke
  `docs:placement` หรือ `docs:setup`; ห้ามจัดโครงใหม่เกิน scope เงียบ ๆ

## ในโค้ด

- comment ใส่เฉพาะ why/constraint หนึ่งบรรทัดพร้อม pointer; **ตั้งแต่ 2 บรรทัด** ให้ย้าย
  narrative/history/detail ไป docs ก่อน แล้วเหลือ pointer ที่มีปลายทางจริงใน repo; ห้ามเขียน
  pointer ที่ commit แล้วไปพึ่ง `~/.claude/` หรือ path เฉพาะเครื่องซึ่ง clone อื่นเปิดไม่ได้
- docstring คือ public interface contract และ public interface ต้องมีตาม convention ของภาษา;
  tutorial, postmortem และ changelog ไป docs
- ก่อนเรียกใช้/แก้/ทำซ้ำ symbol เดิมให้อ่าน docstring ก่อน; ก่อนแก้จุดที่มี comment-pointer
  ให้เปิดปลายทางก่อน ไม่เดาจากชื่อ. contract ขัด behavior จริงให้แก้พร้อมงาน

รายละเอียดการเลือกบ้านและ remediation อยู่ `/docs:placement`; ห้ามทำ cleanup เกิน scope
เพียงเพราะพบหนี้เอกสาร.
