# <ProjectName> — <one-line purpose>

> สถานะ: **<LIVE / WIP / phase>** — <สถานะปัจจุบันที่ไม่ใช่ตัวเลขนับเอง>

## ระบบโดยย่อ

- **<module/service>** — <หน้าที่, entry point/source of truth, quirk สั้น ๆ>

## การรันและ deploy

### Local development

`<คำสั่งรัน/ทดสอบหลัก>`

### Deploy

1. `<คำสั่งหรือ pipeline>`
2. `<ขั้นตอนที่ต้องทำมือ ถ้ามี>`

- **Rollback:** <ย้อน code อย่างไร และ state ใดที่ย้อนเองไม่ได้>
- **Verify:** <flow หรือ health check ที่ยืนยันผลจริง>
- **Compatibility:** การเปลี่ยน public contract/schema ที่ลบ เปลี่ยนชื่อ เปลี่ยนความหมาย หรือบังคับ required ต้องวางแผน expand → migrate → contract และต้อง rollback code ได้โดยไม่พึ่งการย้อนข้อมูล

## ขอบเขตและข้อจำกัด

- **Mission:** <ระบบทำอะไร>
- **Boundary:** <สิ่งที่ระบบไม่ทำ/ไม่ควรขยาย>
- **Constraints:** <เวลา งบ infra หรือข้อกำหนดสำคัญ>

## การตัดสินใจที่ยังมีผล

- **<หัวข้อ> (<YYYY-MM-DD>):** เลือก <X> เพราะ <เหตุผล>; ไม่เลือก <Y> เพราะ <เหตุผล>

ย้าย rationale ที่ยาวหรือประวัติไป `docs/`; แก้ decision เดิมเมื่อถูกแทนที่ แทนการเติม changelog

## Conventions และข้อควรระวัง

- <convention หรือ quirk ที่ไม่เห็นแล้วเสี่ยงทำงานผิด>

## งานถัดไป

- [ ] <งานที่ actionable>

## เอกสารและ memory

- `docs/<topic>.md` — <เปิดเมื่อทำเรื่องใด>
- `memory/MEMORY.md` — index ของ fact/quirk ที่ต้อง recall

## ที่อยู่ของความรู้

| ที่อยู่ | ใช้เมื่อ |
|---|---|
| `CLAUDE.md` | ต้องรู้ทุก session เพื่อทำงานให้ถูก |
| `docs/` | รายละเอียด design, runbook, rationale หรือ history ที่เปิดตามหัวข้อ |
| `memory/` | fact/quirk สั้นที่ต้องนึกออกก่อนรู้ว่าจะค้นหา |
| comment/docstring | constraint ติดโค้ด หรือ contract ของ interface |

ความรู้หนึ่งชิ้นมี source of truth เดียว และข้อมูลที่สร้างใหม่ได้ให้ชี้ไปยัง code/schema/command แทนคัดลอกมาไว้ที่นี่

## Memory policy

`memory/` ใน repository นี้เป็น memory ตัวจริง; harness memory link มาที่นี่

- ก่อน commit memory ใหม่ ลบ metadata ส่วนบุคคลและตรวจว่าไม่มี secret
- ข้อมูล sensitive อยู่ `docs/private/` หรือ `memory/private/` ที่ gitignore และไม่ต้อง index ใน `MEMORY.md`
- fact ที่หมดอายุให้ลบทั้งไฟล์และรายการใน index

## ก่อนปิดงาน

1. อัปเดตเอกสารหรือ decision ที่งานนี้ทำให้เปลี่ยน โดยไม่เล่า implementation ซ้ำ
2. บันทึก fact/quirk ที่ต้อง recall ใน memory หากมี
3. ตรวจ link หลังย้ายเอกสาร และ commit เอกสารพร้อมงาน
