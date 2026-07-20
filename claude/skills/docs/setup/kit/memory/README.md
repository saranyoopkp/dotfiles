# memory/

Project memory ที่ version-control และ harness link มาอ่าน/เขียนโดยตรง

- หนึ่งไฟล์ต่อหนึ่ง fact/quirk ที่อ่านจบได้เร็ว; เรื่องยาวอยู่ `docs/` แล้ว memory ชี้ไป
- ใช้ frontmatter ตาม `_fact.template.md` และอัปเดต `MEMORY.md` เป็น index ทุกครั้ง
- คัดกรอง metadata ส่วนบุคคลและ secret ก่อน commit
- fact ที่หมดอายุให้ลบ พร้อมลบจาก index
- การย้ายเครื่องต้องสร้าง harness link ใหม่ด้วย init
