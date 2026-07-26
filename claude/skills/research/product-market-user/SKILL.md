---
name: research:product-market-user
description: วิจัย product opportunity, market/competitor และ user need/behavior ด้วยหลักฐานที่มี provenance. ใช้เมื่อจะอ้างว่าผู้ใช้ต้องการอะไร, เลือก feature/segment, วิเคราะห์ interview/survey/support/usage data, เปรียบเทียบ competitor/pricing/positioning หรือ recommendation จะเปลี่ยน product behavior; ห้ามใช้ persona หรือความเห็นของ model แทน user evidence
---

# Product, Market & User

ใช้ `research:research-control` กำหนด decision, segment, geography/time window และ evidence plan.

1. แยกคำถามก่อน: product outcome/constraint, market size/dynamics/competitor หรือ user
   need/behavior. หลักฐานคนละชนิดห้ามใช้แทนกัน
2. เริ่มจาก evidence ที่มีอยู่จริง: product analytics/experiment, support/sales feedback,
   interview/research note, churn/request และ decision เดิม. ตรวจ definition, sample, time window,
   instrumentation และ selection bias ก่อนตีความ
3. User evidence ให้ค่าน้ำหนัก observed behavior และ direct research ที่มีบริบทเหนือ opinion;
   interview/anecdote สร้าง hypothesis ได้แต่ไม่พิสูจน์ prevalence. Survey ต้องตรวจ wording,
   sampling และ non-response bias
4. Market/competitor claim ใช้ official product/pricing/changelog/filing หรือ source ที่เปิด
   methodology พร้อม source date + checked date. Marketing copy ยืนยันได้เพียงสิ่งที่ผู้ขายประกาศ
5. ห้ามสร้าง synthetic persona, fabricated quote, market size หรือ “ผู้ใช้ส่วนใหญ่” จาก intuition,
   LLM output หรือ sample ที่ไม่รองรับ. แยก `Observed / Reported / Inferred / Unknown`
6. รักษา consent, purpose, minimization และ privacy ของข้อมูลผู้ใช้; ห้ามรวบรวม PII, ติดต่อคน,
   ส่ง survey หรือใช้ production data นอก authority/scope
7. Triangulate เฉพาะเมื่อหลักฐานวัด claim เดียวกัน; ความเห็นหลายแหล่งไม่ชดเชย sample/method ที่ผิด.
   Source ขัดกันให้แยก segment/time/method ก่อนคงเป็น unknown

ส่งมอบ opportunity/insight พร้อม segment, evidence, confidence limitation และ counter-evidence;
แยก fact จาก recommendation. Research เสนอทางเลือกได้ แต่ product behavior, experiment หรือ
การเก็บข้อมูลใหม่ต้องผ่าน intent/behavioral-change gate ก่อน.
