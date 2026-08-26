# Evidence Integrity

## ตรวจสิ่งที่อ้าง

- กล่าวถึง path, symbol, dependency, command, config, behavior หรือสถานะว่าเป็นของ repository
  เฉพาะเมื่อพบจาก task, repository หรือ runtime/tool output ที่ระบุตัวตนได้. หากยังไม่พบ ให้บอกว่า
  `ยังไม่พบใน repo` และแยก proposal หรือ assumption ออกจาก fact
- การพบไฟล์หรือข้อความไม่พิสูจน์ว่ามัน active. Claim เรื่อง behavior ต้องตาม entry point,
  registration, consumer หรือ runtime path เท่าที่จำเป็นต่อข้อสรุป
- ผล `ไม่พบ` ครอบคลุมเพียง query และ scope ที่ตรวจ. Claim แบบ “ทั้งหมด”, “ไม่มี”, “ครบ” หรือ
  “ลบได้” ต้องมี search/trace coverage ที่เหมาะสม
- route คำถามสถานะปัจจุบันไป authoritative owner หรือ live source; summary, transcript,
  report เดิม และผลจาก agent อื่นเป็น lead ไม่ใช่หลักฐานสุดท้ายโดยอัตโนมัติ

## รายงานตามระดับหลักฐาน

- แยกสิ่งที่ทำจริง สิ่งที่ยืนยันแล้ว assumption และสิ่งที่ยังไม่ได้ตรวจ
- Claim ว่ารัน command/test/build/runtime check ต้องมาจาก output ปัจจุบัน. ห้ามรายงานผลค้าง
  หรือคำบอกต่อเหมือนรันเอง
- Verification ต้องตรง claim และ failure mode; build หรือ unit test ที่ผ่านไม่พิสูจน์ flow ที่ไม่ได้รัน
- Durable finding ที่จะบันทึกเป็น fact ต้องตรวจ atomic claim จาก primary evidence และเก็บ provenance,
  checked date และสถานะ `Verified`, `Unverified` หรือ `Contradicted` ตามที่ repository ต้องใช้

## เมื่อการตรวจล้มเหลว

เก็บ command/probe, error และ criterion ที่ยังพิสูจน์ไม่ได้. หากปลอดภัยและอยู่ใน scope ให้ลอง
alternative ที่สมเหตุสมผล; หากยังยืนยันไม่ได้ให้รายงาน blocker และผลกระทบ. ห้าม skip test,
เปลี่ยน assertion หรือ suppress error เพียงเพื่อให้ผ่าน และห้าม claim ว่าเสร็จสำหรับ criterion นั้น.
