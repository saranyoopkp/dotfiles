---
name: retro
description: สกัด feedback จาก session ปัจจุบันเพื่อหา improvement ของ dotfiles จากสิ่งที่ผู้ใช้ต้องบอกหรือแก้ซ้ำ, pain ที่ agent พบ, false claim, near miss และพฤติกรรมที่ควรรักษา ใช้เมื่อผู้ใช้เรียก /retro, ขอ retrospective/session feedback, ถามว่าควรปรับ agents/rules/skills อะไรจากงานที่ผ่านมา หรือขอหา recurring friction โดยต้องรายงานแบบมีหลักฐานและ read-only โดย default
---

# Session Retro

เปลี่ยนเหตุการณ์ใน session ปัจจุบันเป็นข้อเสนอปรับ dotfiles ที่ตรวจย้อนกลับได้ โดยไม่ถือว่าทุก pain ต้องแก้ด้วย instruction เพิ่ม

## Boundary

- วิเคราะห์เฉพาะ session/context และ repository evidence ที่เข้าถึงได้ ห้ามแต่งเหตุการณ์หรือจำนวนครั้ง
- เป็น read-only โดย default: ห้ามแก้ไฟล์, บันทึก memory หรือ promote finding จนกว่าผู้ใช้จะสั่ง
- Retro ไม่ใช่การประเมินความผิดของผู้ใช้หรือ agent; หา system cause ที่แก้ได้
- ถ้าหลักฐานไม่พอ ให้ระบุ `Unverified` และสิ่งที่ต้องตรวจเพิ่ม

## Workflow

1. หาเหตุการณ์ที่มี signal:
   - ผู้ใช้ต้องบอก, แก้ความเข้าใจ หรือท้วงเรื่องเดิมซ้ำ
   - agent ติดขัด, ตรวจซ้ำด้วยมือ, ใช้หลักฐานผิด หรือเสียเวลากับทางตัน
   - false claim, near miss, behavioral surprise หรือ verification ที่วัดผิดสิ่ง
   - วิธีทำงานที่ได้ผลและไม่ควรถดถอย
2. รวมเหตุการณ์ที่มี root concern เดียวกัน แต่เก็บหลักฐานแต่ละเหตุการณ์ไว้ ห้ามนับข้อความอ้างถึงเหตุการณ์เดิมเป็น occurrence ใหม่
3. ตรวจของเดิมใน repository ก่อนเสนอเพิ่ม:
   - ถ้ามี instruction ครอบคลุมแล้ว ให้พิจารณา execution miss, routing, enforcement หรือ test gap
   - ถ้ายังไม่มีหรือ wording ทำให้ตีความผิดซ้ำ จึงจัดเป็น instruction gap
4. จำแนกสาเหตุเป็น `instruction gap`, `instruction overload`, `execution miss`, `tool/harness limitation`, `repository-specific`, `user preference` หรือ `unknown` ได้มากกว่าหนึ่งข้อเมื่อหลักฐานรองรับ
5. เลือก candidate owner ตาม design invariant:
   - trigger → action ของผู้ปฏิบัติงาน: `Agent`
   - invariant กลาง: `Rule`
   - procedure/มาตรฐานเฉพาะงาน: `Skill`
   - การตรวจ regression หรือข้อจำกัดเครื่องมือ: `Test/Harness`
   - preference ที่ต้องคงข้าม session: `Memory`
   - เฉพาะ repository ปลายทาง: `Target repository`
6. เสนอเฉพาะการแก้ขั้นต่ำที่จัดการต้นเหตุ พร้อมความเสี่ยงเรื่อง instruction noise, overlap และ behavior change

## Output

เริ่มด้วยสรุป signal ที่พบ แล้วรายงานแต่ละข้อด้วย:

```text
Finding:
Status: Verified | Inferred | Unverified | Contradicted
Evidence: เหตุการณ์หรือข้อความที่ตรวจย้อนกลับได้
Frequency: จำนวนที่ยืนยันได้ใน scope นี้
Pain/impact:
Likely cause:
Existing coverage: มี/ไม่มี/ยังไม่ตรวจ พร้อมตำแหน่งเมื่อมี
Candidate owner: Agent | Rule | Skill | Test/Harness | Memory | Target repository | None
Minimal improvement:
Risk/overlap:
```

แยกท้ายรายงานเป็น:

- `ควรพิจารณาปรับ` — มีหลักฐานและ owner ที่สมเหตุสมผล
- `ยังไม่ควรแก้ dotfiles` — isolated event, ของเดิมครอบคลุม หรือหลักฐานยังไม่พอ
- `ควรรักษาไว้` — behavior หรือ guardrail ที่ทำงานดีและไม่ควรถดถอย

ห้ามทำ mutation หลังรายงาน แม้ข้อเสนอชัดเจน; รอให้ผู้ใช้เลือกข้อที่จะดำเนินการ
