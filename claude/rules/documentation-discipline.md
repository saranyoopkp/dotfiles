# Documentation Discipline

ใช้กับทุก repo แม้ยังไม่ setup ระบบเอกสารเต็ม (งาน setup/refactor จริงจัง → skill `/docs:setup`)

## หลักการ
- **CLAUDE.md = สถานะปัจจุบัน ไม่ใช่ changelog** — แก้ section เดิมให้ตรงความจริงวันนี้
  ไม่ต่อบรรทัด ✅ สะสม; ประวัติเป็นหน้าที่ของ git log
- **decision ทุกตัวจดพร้อม "ทำไม" + วันที่** — รวมทางเลือกที่*ไม่*เลือกและเหตุผล
  กัน re-litigate ใน session หน้า
- **อัปเดตเอกสารใน commit เดียวกับงาน** — ไม่มี "เดี๋ยวค่อยตามจด"; commit เล็กและบ่อย
- **จดเฉพาะสิ่งที่โค้ดเล่าเองไม่ได้** — การมีอยู่/จุดเข้า (inventory 1–3 บรรทัด),
  ทำไม, ข้อจำกัด, กับดัก = จด; implementation step-by-step = ให้โค้ด/type/test เล่า
  (เอกสารชนิดที่เล่าซ้ำโค้ด drift เร็วสุดและมีค่าน้อยสุด)
- **section โตเกิน ~15 บรรทัด → promote** ไปไฟล์แยก (docs/ หรือ memory/) เหลือสรุป
  + ลิงก์ — CLAUDE.md ถูกโหลดเต็มทุก session อย่าให้เป็นที่กองเนื้อหา
- **sensitive/private ไม่ลงไฟล์ที่ git track** — secret/IP/path → gitignored (docs/private/) อ้างด้วย pointer
- **สิ่งที่มี source เดียว (ตัวเลขนับได้, JSON/schema shape, DTO) ห้ามมีเจ้าของสองไฟล์** —
  copy/hardcode ซ้ำ (table count, migration count, response shape ที่แปะซ้ำ) จะ stale
  พร้อมกันทุกจุด → เอกสารชี้ไป source (โค้ด/type/คำสั่งนับ) แทนการ copy เนื้อมาแปะ
- **point-in-time doc (design/spec/postmortem) = ยกเว้น drift** — ระบุวันที่กำกับเป็น snapshot ไม่ต้องไล่อัปเดต (อย่าปนไฟล์เดียวกับ living doc)
- **แต่ละ fact มีบ้านเดียว — เลือกบ้านจาก*กลไกที่ถูกอ่าน* ไม่ใช่หัวข้อ**:
  CLAUDE.md = *push* (โหลดทุก session — เฉพาะของที่ไม่เห็นแล้วงานพัง), docs/<topic>.md =
  *pull* (เปิดเมื่อรู้ตัวว่าทำเรื่องนั้น — ยาวได้), memory/<fact>.md = *recall* (ต้องนึกออก
  ก่อนรู้ว่าต้องหา — fact เม็ดเดียว/ไฟล์) — ชั้นอื่นอ้างด้วย pointer เท่านั้น ห้ามเขียน
  เนื้อเดียวกันสองที่ (duplicate = drift แยกกันแน่นอน)
- **docs/ ต้องมีระเบียบ ไม่ใช่กองแบน** — ชื่อไฟล์ตามโดเมนไม่ใช่เวลา; เกิน ~7 ไฟล์
  → จัด subfolder ตามโดเมนของระบบ; CLAUDE.md มี index จัดกลุ่ม (หนึ่งบรรทัด/ไฟล์)
  ที่ sync กับไฟล์จริงใน commit เดียวกันเสมอ
- **ภาษา: internal docs เขียนภาษาที่เร็ว** (ไทยได้ = จดจริง); โค้ด/identifier/commit เป็นอังกฤษ

## ในโค้ด (ยิงทุกงานโค้ด — รายละเอียด/เหตุผลอยู่ skill `/docs:placement`)
- **comment = why/constraint ≤2 บรรทัด + pointer ชี้ของใน repo เท่านั้น** (ห้ามอ้าง
  `~/.claude/...` ลง repo — เครื่องอื่นไม่มี; สาระจาก rule → เขียนเนื้อเอง 1 บรรทัด);
  เรื่องเล่า/ประวัติ/ผลทดลอง/postmortem → docs/ (จะเกิน 2 บรรทัด = เขียน docs ผิดที่)
- **docstring = interface contract เท่านั้น, public ต้องมี** — เปิดด้วย contract ถูกต้อง
  แล้วต่อด้วยเรียงความ/changelog = ผิดบ้านเท่ากับ comment ยาว → เนื้อนั้นไป docs/
- **ขาอ่านบังคับเท่าขาเขียน**: ก่อนแก้/เรียกใช้จุดที่มี docstring หรือ comment-pointer →
  อ่าน/เปิดตามก่อน ไม่เดาจากชื่อ; contract ขัดพฤติกรรมจริง = บั๊กที่ต้องแก้ในงานเดียวกัน

## จังหวะจด
- งานหนึ่งชิ้นเสร็จ = อัปเดตทันที (inventory + decision + quirk — เป้า 1–2 นาที ไม่ใช่เรียงความ)
- แก้ปัญหา/quirk ที่กินเวลา → จด symptom + root cause + fix สั้น ๆ (คนอ่านคือตัวเองในอีก 3 เดือน)
- ถูก user แก้/ทักเรื่องเดิมครั้งที่สอง → ต้องกลายเป็นบันทึกถาวรทันที (CLAUDE.md/memory/rule ตาม scope)
