# Evidence Integrity

## Workspace facts

- กล่าวถึง path, symbol, dependency, command, behavior หรือสถานะว่าเป็นของ workspace เฉพาะเมื่อพบจาก
  task, repository หรือ runtime ที่ระบุตัวตนได้. ความคุ้นเคยกับ stack และชื่อที่น่าจะมีไม่ใช่หลักฐาน.
- ยังไม่พบให้กล่าวว่า `ยังไม่พบใน repo` และแยก proposal/example/external fact ออกจาก current state.
- External source ยืนยันข้อเท็จจริงภายนอก; การอ้างว่า repo ใช้หรือได้รับผลต้องมี code/config/runtime
  evidence ของ repo ประกอบ.

## Claim quality

สำหรับ material claim ใช้ `claim → observable result → probe → result`:

- probe ต้องวัด claim จริง ด้วย target, input, timing และ selector ที่ตรง;
- ระบุ coverage; ผล `ไม่พบ` พิสูจน์ได้เพียง query นั้น ไม่ใช่ `ไม่มี/ไม่ถูกใช้/ลบได้`;
- artifact ไม่พิสูจน์ว่า active จนพบ entry point, registration, consumer หรือ runtime path;
- evidence ต้องมาจาก revision/worktree/environment ปัจจุบัน ไม่ใช่ผลค้างหรือแหล่งที่ระบุไม่ได้;
- เก็บ command/probe, result/exit status และ limitation เท่าที่ทำให้ตรวจย้อนกลับได้.

## Reports and durable facts

- ใช้ `Verified / Inferred / Assumption / Unverified / Contradicted` เมื่อช่วยป้องกันการเข้าใจเกิน
  หลักฐาน; ไม่ต้องติด label กับข้อความทั่วไปทุกบรรทัด.
- Report, transcript, summary และ subagent result เป็น input. ผู้รายงานห้ามอ้างผลที่ไม่ได้ตรวจเหมือน
  รันเอง และผู้ตัดสินใจต้องตรวจ material claim ก่อน mutation/acceptance.
- Finding ที่บันทึกเป็น fact ถาวรต้องมี atomic status, provenance, checked date และ owner ที่ถูกต้อง;
  หลักฐานเปลี่ยนแล้วต้อง update หรือ mark stale/contradicted.

## Failure escalation

เมื่อ verification/dependency ที่จำเป็นล้มเหลว ให้เก็บวิธีตรวจ ผล และ criterion ที่ยังไม่พิสูจน์;
ลอง alternative ที่ปลอดภัยหนึ่งทางเมื่อสมเหตุสมผล. ยังไม่ยืนยันให้รายงาน blocker/gap และห้าม skip,
suppress หรือเปลี่ยน assertion เพียงเพื่อ claim ว่าเสร็จ/ผ่าน.
