---
name: research:research-control
description: ควบคุม research ที่กว้าง, หลาย source, uncertainty/risk สูงหรือหลักฐานขัดกัน. กำหนด question, scope, source/freshness, appetite, stopping criteria และ conflict handling ก่อนค้นหรือสรุป
---

# Research Control

## 1. กำหนด decision ก่อนค้น

- เขียน decision และ research question ที่ตอบได้ชัด; แยก must-know ออกจาก nice-to-know
- ระบุผู้ได้รับผล, context/version/segment/time window, criteria และสิ่งที่ผล research
  จะเปลี่ยน. คำถามกว้างเกินตัดสินใจต้องแบ่งก่อน
- ตรวจ repo, เอกสาร, runtime และข้อมูลที่เข้าถึงได้ก่อนถาม; จากนั้นถามเฉพาะ missing decision
  ที่เปลี่ยน scope, risk, cost, behavior หรือวิธีเก็บหลักฐานอย่างมีนัยสำคัญ

## 2. วาง evidence plan

- แตกคำถามเป็น atomic claim และระบุ evidence ที่จะพิสูจน์/หักล้างแต่ละ claim ก่อนค้น
- เรียง source ตาม claim: authoritative primary source → primary observation/data →
  independent source ที่เปิด methodology → secondary summary → anecdote. ชั้นท้ายใช้หา lead
  แต่ห้ามยกระดับเป็น fact แทน source ที่เหมาะกว่า
- กำหนด freshness จากความผันผวนของเรื่อง; ราคา, support, advisory, regulation และ current
  behavior ต้องตรวจใหม่ พร้อม source date และ checked date

## 3. กำหนด appetite และ stopping criteria

- ตั้ง effort ตาม reversibility และผลกระทบ: decision ที่ย้อนกลับง่ายใช้หลักฐานเท่าที่แยกทางเลือกได้;
  security, legal/data, recurring cost, lock-in หรือ migration แพงต้องใช้หลักฐานเข้มกว่า
- กำหนด stop ก่อนค้น: decision criteria สำคัญมี evidence เพียงพอ, source ใหม่ไม่เปลี่ยนข้อสรุป
  หรือถึง appetite แล้ว. ห้ามใช้จำนวนลิงก์เป็น stopping criterion
- ถึง appetite แต่ claim สำคัญยังไม่ยืนยัน ให้หยุดพร้อม `Unknown`, ผลกระทบ และ next probe;
  timebox ห้ามแปลงความไม่รู้เป็นคำตอบ

## 4. จัดการหลักฐานขัดกัน

- ตรวจ version/date, definition, population/segment, geography, methodology, incentive และ
  measurement ก่อนสรุปว่า source ขัดกันจริง
- อย่าเฉลี่ยหรือโหวตตามจำนวน source. ให้ source ที่มี authority ตรง claim ยืนยัน contract/policy;
  ใช้ observation หรือ independent evidence ยืนยันผลในโลกจริง
- ถ้ายัง reconcile ไม่ได้ ให้เก็บทั้งสอง claim, ระบุเงื่อนไขที่แต่ละข้ออาจจริง และบอกว่า decision
  ใดปลอดภัยภายใต้ความไม่แน่นอน; ห้ามเลือก source ที่เข้ากับข้อสรุปเดิมเงียบ ๆ

## 5. ส่งมอบ

สรุป `decision/question → claim → status → source + checked date → applicability → limitation`
และแยก recommendation ออกจาก fact. ระบุสิ่งที่ไม่ได้ค้นและเหตุผล เพื่อให้ผู้อ่านรู้ coverage
และตรวจซ้ำได้โดยไม่เริ่มใหม่ทั้งหมด.
