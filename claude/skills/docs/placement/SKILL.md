---
name: docs:placement
description: ตัดสินว่าความรู้ควรอยู่ใน comment, docstring, docs, memory หรือ CLAUDE.md และจัดระเบียบเนื้อหาที่อยู่ผิดที่ ใช้เมื่อเขียน/ย้ายเอกสารหรือ comment/docstring
---

# Doc Placement

เลือกบ้านจากเวลาที่ผู้อ่านต้องเห็นข้อมูลนั้น ไม่ใช่จากความยาวเพียงอย่างเดียว

| บ้าน | ใช้เมื่อ | เนื้อหาที่เหมาะ |
|---|---|---|
| code comment | แก้บรรทัดนั้น | why/constraint ที่โค้ดไม่บอกเอง |
| docstring | เรียกใช้หรือแก้ interface | contract, input/output, side effect, invariant |
| `docs/` | ทำเรื่องนั้นโดยตั้งใจ | design, runbook, rationale, ประวัติ, ผลทดลอง |
| `memory/` | ต้องนึกออกก่อนรู้ว่าจะค้นหาอะไร | quirk หรือ fact สั้นหนึ่งเรื่อง |
| `CLAUDE.md` | ทุก session | operational context ที่หายไปแล้วเสี่ยงทำงานผิด |

## หลักปฏิบัติ

- comment และ docstring ต้องช่วยการใช้หรือการแก้โค้ดในอนาคต; อย่าเล่า how ที่โค้ดบอกอยู่แล้วหรือใช้เป็น changelog
- เขียนให้สั้นเท่าที่ข้อมูลสำคัญยังอยู่ติดจุดใช้งานได้; ย้าย tutorial, ประวัติ และรายละเอียดเชิงลึกไป `docs/` พร้อม pointer เมื่อมีประโยชน์
- public interface หรือ contract ที่ชื่อไม่อธิบายพอควรมี docstring; helper ภายในที่ชัดอยู่แล้วไม่จำเป็น
- ความรู้หนึ่งชิ้นมี source of truth เดียว; จุดอื่นใช้ link/pointer แทนการ copy
- ก่อนย้ายเนื้อหา ให้สร้างปลายทางก่อนและตรวจ link หลังย้ายด้วย `/docs:link`

## เมื่อตรวจหนี้เดิม

ทำเฉพาะ scope ที่ได้รับมอบหมาย เว้นแต่ผู้ใช้สั่งกวาดทั้ง repo

1. จำแนกว่าเนื้อหานั้นเป็น contract, constraint, work item, history หรือซ้ำโค้ด
2. เก็บ contract/constraint ที่จำเป็นติดโค้ด; ย้าย history/rationale ยาวไป docs; ลบสิ่งที่ซ้ำโค้ด
3. จัด `TODO(scope):` เฉพาะงานค้างจริงที่มี owner หรือทางปิดงาน
4. รัน `/docs:link` และอัปเดตเอกสารใน commit เดียวกัน
