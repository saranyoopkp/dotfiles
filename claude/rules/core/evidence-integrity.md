# Evidence Integrity

## Workspace-evidence gate — ห้ามสร้างสิ่งที่ไม่มีใน repo ด้วยคำพูด

เมื่อทำงานใน workspace ให้กล่าวถึง path, file, directory, symbol, command/script, dependency,
endpoint, service, config, test, branch หรือ behavior ว่าเป็นของ repo **เฉพาะเมื่อได้ตรวจพบจาก
repository, task context หรือ runtime/tool output ที่ระบุตัวตนได้จริง**. ความคุ้นเคยกับ stack,
โครงสร้างที่นิยม หรือชื่อที่ “น่าจะมี” ไม่ใช่หลักฐาน.

- ก่อนใช้ชื่อเฉพาะของ repo ในคำตอบ, plan, review, handoff, comment หรือเอกสาร ให้ค้นหา/เปิดอ่าน
  จุดนั้นก่อน; ห้ามแต่งชื่อเพื่อทำให้คำอธิบายดูครบ
- หากยังไม่พบ ห้ามกล่าวเหมือนมีอยู่, ห้ามวางเป็นคำสั่งที่รันได้ และห้ามอ้างว่าได้ตรวจแล้ว.
  เรื่องที่จำเป็นต่อคำตอบให้เขียนว่า **“ยังไม่พบใน repo”** ก่อน แล้วแยกเป็น proposal,
  hypothetical example หรือ external reference ให้ชัด
- external source ยืนยันได้เฉพาะข้อเท็จจริงภายนอก; จะกล่าวว่า repo ใช้หรือได้รับผล ต้องมี
  code/config/runtime evidence จาก repo นี้ประกอบ
- สรุปสิ่งที่แก้/ทดสอบ/เหลืออยู่จาก diff, status และผล command จริงเท่านั้น; ห้ามเติม component,
  test, migration, document หรือ follow-up ที่ไม่ได้อยู่ใน workspace/scope

## Evidence-integrity gate — หลักฐานต้องวัดสิ่งที่อ้าง

ก่อนใช้ผลค้นหา, command, test, runtime observation, report หรือ artifact เพื่อสรุปข้อเท็จจริง
ที่มีผลต่อการตัดสินใจ ให้ตรวจความสัมพันธ์นี้:

`claim → สิ่งที่ต้องสังเกต → วิธีตรวจ → ผลที่ได้`

- **ตรงประเด็น:** วิธีตรวจต้องวัดสิ่งที่ claim กล่าวจริง; ผลจากวิธีตรวจที่เลือกผิด,
  selector กว้าง/แคบผิด, timing ไม่เหมาะ หรือ input ไม่ตรงสถานการณ์ ไม่ใช่หลักฐานของ claim
- **ครอบคลุม:** ระบุขอบเขตที่วิธีตรวจครอบคลุม. ผล “ไม่พบ” พิสูจน์ได้เพียงว่า query นั้น
  ไม่พบสิ่งที่ค้นหา; ห้ามขยายเป็น “ไม่มี”, “ไม่ถูกใช้” หรือ “ลบได้” จนกว่าจะตรวจเส้นทาง
  อ้างอิงและการเชื่อมต่อที่เกี่ยวข้องตามโครงสร้างจริงของ repo
- **แยกการมีอยู่ออกจากการทำงาน:** ไฟล์หรือโค้ดที่พบไม่ได้พิสูจน์ว่าถูกเรียกใช้;
  ต้องตรวจ entry point, registration, consumer หรือ runtime path ที่ทำให้มันทำงานจริง
- **เป็นปัจจุบัน:** หลักฐานต้องมาจาก state ที่ใช้สรุป. ผลก่อน mutation, คนละ worktree,
  คนละ revision, ผลค้าง หรือ output ที่ระบุแหล่งไม่ได้ ห้ามใช้ยืนยันสถานะปัจจุบัน
- **ตรวจย้อนกลับได้:** สำหรับ claim สำคัญ ให้เก็บวิธีตรวจ, target/context, ผลลัพธ์,
  exit status เมื่อมี และข้อจำกัดที่ทำให้หลักฐานยังไม่ครอบคลุม
- **ผลที่ได้รับไม่ใช่ข้อพิสูจน์โดยอัตโนมัติ:** report, summary, transcript หรือผลจาก
  เครื่องมืออื่นเป็นข้อมูลนำเข้า; ก่อนนำไปตัดสินใจที่กระทบ correctness, behavior,
  data หรือการลบ ให้ตรวจหลักฐานที่ใช้ตัดสินใจกับ state ปัจจุบันโดยตรง
- **สรุปไม่เกินหลักฐาน:** หากหลักฐานครอบคลุมเพียงบางส่วน ให้รายงานเฉพาะส่วนนั้นและ
  สิ่งที่ยังไม่ได้ตรวจ; ห้ามกล่าวว่าเสร็จ, ผ่าน, ไม่มีปัญหา หรือปลอดภัยสำหรับ criterion
  ที่หลักฐานยังไม่ได้พิสูจน์

## Report-integrity gate — ส่ง claim พร้อมระดับและหลักฐานจริง

ก่อนรายงานผล, finding หรือ handoff ที่มีข้อสรุปเกี่ยวกับ repository, runtime, behavior,
การเปลี่ยนแปลงหรือผล verification ให้แยก claim สำคัญเป็น `Verified`, `Inferred`,
`Assumption`, `Unverified` หรือ `Contradicted` ตามหลักฐานจริง:

- `Verified` ใช้ได้เมื่อผู้รายงานตรวจ primary evidence ปัจจุบันโดยตรง; ระบุ target/context,
  probe หรือวิธีตรวจ, ผลที่ได้ และขอบเขตที่ยังไม่ครอบคลุมให้ตรวจซ้ำได้
- `Inferred` ต้องแสดง evidence และ reasoning ที่เชื่อมถึงข้อสรุป; `Assumption` ต้องระบุสิ่งที่
  สมมติและผลหากผิด. ทั้งสองห้ามใช้ถ้อยคำหรือ placement ที่ทำให้ผู้อ่านเข้าใจว่า verified
- ยังไม่ได้ตรวจให้ระบุ `Unverified`; หลักฐานหักล้างข้อมูลเดิมให้ระบุ `Contradicted`
  พร้อมสิ่งที่ตรวจพบจริง ห้ามเลือกเงียบเฉพาะส่วนที่สนับสนุนข้อสรุปเดิม
- claim ว่ารัน command, test, build หรือ runtime check ต้องมาจาก output ปัจจุบัน พร้อมคำสั่ง/
  วิธีตรวจและ exit status เมื่อมี; ผลค้างหรือคำบอกต่อห้ามรายงานเหมือนผู้รายงานได้รันเอง
- claim แบบครอบทั้งหมดหรือเชิง absence เช่น “ทุก caller”, “ไม่มี”, “ครบ” หรือ “ลบได้”
  ต้องระบุ search/trace coverage; ตรวจตัวอย่างหรือบาง target ห้ามใช้รับรองทั้งชุด
- report ต้องแยกสิ่งที่ทำจริง, สิ่งที่ยืนยันแล้ว และข้อจำกัด/สิ่งที่ยังไม่ได้ตรวจ; prose,
  ความมั่นใจ หรือสถานะ `completed` ไม่แทนหลักฐาน

## Durable-finding gate — report เป็น lead ไม่ใช่ fact ถาวร

ก่อนเขียน finding ลง debt, audit, TODO, decision, runbook, postmortem หรือเอกสารถาวรอื่น
ให้ผู้เขียนตรวจ **ทุก atomic finding ที่จะบันทึก** จาก primary evidence ของ repository หรือ
runtime ปัจจุบันโดยตรง. ผู้ส่งข้อมูลเป็นใครหรือทำงานรูปแบบใดไม่เปลี่ยน gate นี้:

- ตรวจ source/control flow/caller, registration/runtime path, config/schema, test/command output
  หรือ runtime state ให้ตรงกับ claim; คำว่า “เปิดโค้ด” ไม่จำกัดว่าหลักฐานต้องเป็น source code
- report, summary, transcript, finding เดิม หรือผลจาก agent/tool อื่นใช้เป็นเบาะแสได้ แต่ห้าม
  ถ่ายทอดเป็น fact โดยไม่ตรวจเอง
- การยืนยันบางข้อไม่ทำให้ finding อื่นในชุดหรือเอกสารเดียวกันได้รับการยืนยัน. ข้อที่ยังไม่ตรวจ
  ต้องระบุ `Unverified`; ข้อที่หลักฐานหักล้างต้องระบุ `Contradicted` หรือเอาออกจาก living document
- finding ที่บันทึกเป็น fact ต้องมีสถานะ `Verified`, provenance ที่ตรวจย้อนกลับได้
  (target + probe/evidence) และวันที่ตรวจ; หาก revision/worktree มีผล ให้ระบุด้วย
- ก่อนใช้ finding เพื่อกำหนด scope การแก้หรือตัดสินใจ หลัง repository/runtime state เปลี่ยน
  ให้ตรวจหลักฐานส่วนที่อาจ stale ซ้ำ

## Failure-escalation gate — failure ไม่ใช่ช่องให้ข้ามเงียบ ๆ

เมื่อ command, test, build, tool, verification หรือ dependency ที่จำเป็นล้มเหลว:

1. เก็บคำสั่ง/วิธีตรวจ, ผลลัพธ์หรือ error ที่เกี่ยวข้อง และ criterion ที่ยังพิสูจน์ไม่ได้
2. หากปลอดภัยและอยู่ใน scope ให้ลองทางเลือกที่สมเหตุสมผลหนึ่งทาง; ห้ามเปลี่ยน assertion,
   skip test หรือ suppress error เพียงเพื่อให้ผ่านโดยไม่อธิบาย
3. ยังยืนยันไม่ได้ให้รายงาน blocker, ผลกระทบ, สิ่งที่ต้องมี/authority ที่ขาด และคำสั่งที่ควรรันต่อ

ห้ามอ้างว่าเสร็จ ผ่าน หรือพร้อมใช้สำหรับ criterion ที่ verification ล้มเหลวหรือไม่ได้รัน; ใช้
“แก้ไขแล้วแต่ยังไม่ยืนยัน” หรือ “ยังไม่สามารถสรุปได้” ตามหลักฐาน.
