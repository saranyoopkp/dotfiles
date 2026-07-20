# <ProjectName> — <one-line purpose>

> สถานะ: **<LIVE / WIP / phase>** — <สถานะปัจจุบันที่ไม่ใช่ตัวเลขนับเอง>

## วิธีทำงานกับ repository นี้

เป้าหมายคือส่งมอบการเปลี่ยนแปลงที่เล็กที่สุดซึ่งตอบเจตนาของผู้ใช้ ดูแลต่อได้ และซื่อสัตย์ต่อสิ่งที่ตรวจสอบแล้ว

- **เข้าใจก่อนทำ:** ตรวจ task, repository, contract, เอกสาร และเครื่องมือที่เข้าถึงได้ก่อนถาม หากความกำกวมมีผลต่อ scope, ความปลอดภัย หรือผลลัพธ์อย่างมีนัยสำคัญ ให้ถาม; หากเป็นสมมติฐานที่ปลอดภัยและย้อนกลับได้ ให้ระบุแล้วดำเนินการ
- **รักษา scope และบริบท:** เคารพ decision ที่บันทึกพร้อมเหตุผล เลือกวิธีที่เรียบง่ายและอยู่ในขอบเขต ไม่ rewrite หรือเพิ่ม dependency เพียงเพราะทำได้ โค้ดเดิมเป็นหลักฐาน ไม่ใช่ pattern ที่ต้องลอกเสมอ
- **แยกชั้นความเชื่อมั่น:** ข้อสรุปสำคัญต้องระบุว่าเป็น **Verified** (มีหลักฐาน), **Inferred** (อนุมานพร้อมเหตุผล) หรือ **Assumption** (ยังไม่ยืนยัน) ห้ามเสนอสมมติฐานเป็นข้อเท็จจริง
- **เปลี่ยนอย่างปลอดภัย:** หยุดขอทิศทางก่อนทำสิ่งที่ลบข้อมูล เปลี่ยน public contract/dependency หรือกระทบระบบภายนอกอย่างมีนัยสำคัญ หากไม่มี authorization ชัดเจน
- **ตรวจตามความเสี่ยง:** ใช้หลักฐานที่ตรงกับข้ออ้างที่สุด เช่น targeted test, runtime/API/UI check, contract check, log หรือ static analysis; ระบุสิ่งที่ยังตรวจไม่ได้และเหตุผล ห้ามอ้างว่าทำงานแล้วหรือพร้อมใช้งานหากไม่มีหลักฐานพอ
- **ส่งมอบให้ตรวจสอบได้:** สรุปสิ่งที่เปลี่ยน หลักฐาน ความเสี่ยง/ข้อจำกัด และงานติดตามที่จำเป็น หากมีผู้ตรวจรับอิสระหรือ acceptance process ของโครงการ ให้ส่ง requirement, scope, evidence และ known limits โดยไม่ชี้นำ verdict

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

### วินัยเอกสารในโค้ด

- comment อธิบายเหตุผลหรือข้อจำกัดที่โค้ดสื่อเองไม่ได้; อย่าใช้เป็น changelog หรือเล่า how ที่เห็นจากโค้ดอยู่แล้ว
- docstring อธิบาย contract ของ public interface เมื่อชื่อ/type ไม่เพียงพอ: input/output, side effect และ invariant ที่สำคัญ
- รายละเอียด design, runbook, ผลทดลอง และประวัติอยู่ใน `docs/`; งานค้างที่ผูกกับจุดในโค้ดใช้ `TODO(scope):` และลบเมื่อปิดงาน
- ก่อนย้ายหรือ rename เอกสาร ให้ตรวจ pointer/link ที่เกี่ยวข้องด้วยคำสั่งหรือเครื่องมือที่มีใน repository

## Memory policy

`memory/` ใน repository นี้เป็น **memory ตัวจริงเพียงชุดเดียว**. Path ของ Claude Code harness ที่ `~/.claude/projects/<project-id>/memory` **ต้องเป็น link** (Windows junction / Unix symlink) มาที่ `<repo>/memory`; ห้ามมี memory สองสำเนาแล้ว sync กันเอง

- ก่อน commit memory ใหม่ ลบ metadata ส่วนบุคคลและตรวจว่าไม่มี secret
- ข้อมูล sensitive อยู่ `docs/private/` หรือ `memory/private/` ที่ gitignore และไม่ต้อง index ใน `MEMORY.md`
- fact ที่หมดอายุให้ลบทั้งไฟล์และรายการใน index
- หากย้ายเครื่องหรือ harness path เป็น directory ปกติ ให้ merge fact ที่ยังต้องเก็บเข้า `<repo>/memory` ก่อน แล้วแทน path นั้นด้วย link; setup ยังไม่เสร็จจนกว่าจะยืนยันว่า link ชี้มาที่ repository นี้

ตัวอย่างการสร้าง link เมื่อไม่มี setup script:

```bash
# macOS/Linux
ln -s <repo>/memory ~/.claude/projects/<project-id>/memory

# Windows PowerShell
New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\projects\<project-id>\memory" -Target "<repo>\memory"
```

## ก่อนปิดงาน

1. อัปเดตเอกสารหรือ decision ที่งานนี้ทำให้เปลี่ยน โดยไม่เล่า implementation ซ้ำ
2. บันทึก fact/quirk ที่ต้อง recall ใน memory หากมี
3. เมื่อ setup หรือย้ายเครื่อง ให้ยืนยันว่า harness memory ยัง link มาที่ `memory/`; ตรวจ link หลังย้ายเอกสาร และ commit เอกสารพร้อมงาน

## การตรวจสอบความจริงของเอกสาร

เมื่อเอกสารอ้างพฤติกรรม command, config, schema หรือ deployment ให้ตรวจเทียบกับของจริงก่อนเชื่อหรือแก้ไข: รันคำสั่งแบบอ่านอย่างเดียวเมื่อทำได้ แล้วอ่าน code/config/test ที่เกี่ยวข้อง เอกสารที่ขัดกับระบบจริงต้องแก้ในงานเดียวกัน หรือระบุเป็นข้อสงสัยพร้อมหลักฐานสองฝั่ง
