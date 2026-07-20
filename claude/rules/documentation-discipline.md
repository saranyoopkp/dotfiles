# Documentation Discipline

เอกสารต้องช่วยให้คนทำงานต่อได้โดยไม่แข่งกับโค้ดเป็น source of truth

- `CLAUDE.md` เก็บเฉพาะบริบทปัจจุบันและ operational facts ที่ไม่เห็นแล้วงานเสี่ยงพัง; ประวัติและผลทดลองอยู่ `docs/`
- บันทึก decision ที่ส่งผลต่อการทำงานต่อพร้อมเหตุผล; อัปเดตเอกสารที่เกี่ยวข้องในงานเดียวกันเมื่อพฤติกรรมหรือ decision เปลี่ยน
- ความรู้หนึ่งชิ้นมีเจ้าของเดียว: source ที่ generate ได้ให้ชี้ไปยัง code/schema/command แทนคัดลอก
- ห้าม commit secret หรือข้อมูลอ่อนไหว; ใช้ไฟล์ที่ ignore และ pointer ที่ปลอดภัย
- snapshot เช่น design note หรือ postmortem ต้องติดวันที่; living document ต้องตรวจให้ตรงกับของจริง
- facts ที่นับหรือ generate ได้จาก code/schema/command ต้องชี้ source แทนคัดลอก; comment เก็บ why/constraint, docstring เก็บ contract, history/runbook อยู่ docs

งานจัดวางเนื้อหา, setup, link และ stale check ใช้ skill `/docs:*` ตามประเภทงาน.
