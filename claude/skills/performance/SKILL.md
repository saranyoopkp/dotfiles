---
name: performance
description: วิเคราะห์หรือแก้ performance เมื่อมี workload/constraint หรือ concern ที่วัดได้ เช่น latency, throughput, N+1, unbounded work, cache, async/render/resource pressure. ไม่ใช้กับงานทั่วไปที่ยังไม่มี performance signal และไม่ optimize จาก scale สมมติ
---

# Performance — วัดก่อน เลือกทางเล็กสุดที่พอ

## Gate

ก่อนเสนอ optimization ระบุ:

- symptom และ metric ที่กระทบ
- workload/data volume/concurrency ที่เกี่ยว
- budget หรือผลลัพธ์ที่ต้องการ
- baseline และวิธีวัดซ้ำ

ยังไม่มีหลักฐานให้เสนอ probe ที่ถูกที่สุดก่อน; ห้ามสร้าง cache, queue, index หรือ abstraction
เพื่อ performance จากความคุ้นเคยกับ pattern อย่างเดียว. การวิเคราะห์ไม่ใช่ authorization ให้แก้.

N+1 บน collection ที่โตได้, unbounded data growth และ external I/O ที่ไม่มี timeout/deadline
เป็น safety baseline เมื่อเงื่อนไขนั้นมีอยู่จริง ไม่ต้องรอ benchmark เพื่อยอมรับ risk; measurement
ใช้เลือกและพิสูจน์ทางแก้ ไม่ใช่ใช้ปฏิเสธ risk ที่ตรวจพบ.

## Data access

- หา query ใน loop/N+1 แล้วเปลี่ยนเป็น join, batch หรือ `IN` เมื่อ semantics เท่ากัน
- list ที่โตตาม user/data ต้องมี bound, pagination หรือ streaming; list คงที่และมีเพดานจริงไม่ต้อง
- column ที่ filter/sort บ่อยให้ประเมิน index จาก query plan/write cost ไม่ใช่ชื่อ column
- payload ใหญ่ให้ select/serialize เฉพาะที่ใช้ โดยรักษา contract เดิม

## Runtime และ external I/O

- กำหนด timeout/deadline ให้ I/O ภายนอก; failure path ต้องบอกสาเหตุที่ตามได้
- งานเกิน request budget ให้เลือก async/queue เมื่อผู้ใช้รับ semantics ของ deferred result;
  ห้ามเปลี่ยน synchronous behavior เงียบ ๆ
- cache ต้องตอบให้ได้ว่า key, owner, invalidation, consistency window และ fallback คืออะไร
- วัด CPU, memory, connection/queue pressure ก่อนเพิ่ม concurrency

## Frontend

- แยกว่าช้ามาจาก network, server, bundle, render หรือ interaction ก่อนแก้
- รายการยาวจริงค่อย paginate/window/virtualize; อย่าเพิ่ม complexity ให้รายการเล็ก
- asset ใต้ fold lazy-load และระบุขนาดเมื่อมี layout-shift risk
- state ที่เปลี่ยนถี่ให้จำกัด render scope แล้ววัดก่อน/หลัง

## Verify และ report

รัน workload เดิมบน state ที่เปรียบเทียบได้ แล้วรายงาน:

`baseline → change → result → variance/coverage → trade-off`

ผล benchmark ครั้งเดียวหรือคนละ environment ไม่พิสูจน์ improvement. ถ้าทางขั้นต่ำถึง budget
แล้ว ให้หยุดและเสนอ defer trigger สำหรับทางที่ซับซ้อนกว่า.
