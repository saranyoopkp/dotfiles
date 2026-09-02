---
name: research:technology-vendor
description: เปรียบเทียบ dependency, framework, database, infrastructure technology, SaaS/vendor หรือ build-vs-buy ด้วยหลักฐานปัจจุบัน. ใช้เป็น owner ของ external comparison และ recommendation ก่อนเพิ่ม dependency ใน brownfield, เลือกหรือเปลี่ยน vendor, ประเมิน maintenance/security/license/pricing/support/compatibility/lock-in หรือทำ recommendation ที่มีต้นทุนและ migration impact; shared inventory/contract ใช้ stack-contracts ร่วมเมื่อจำเป็น
---

# Technology & Vendor

ใช้ `research:research-control` เพื่อกำหนด criteria และ stopping condition ก่อนเปิด comparison.
Greenfield version chain ยังต้องใช้ `greenfield-foundation`; skill นี้เสริมการเปรียบเทียบ ไม่แทน gate นั้น.

1. กำหนด decision boundary: use case, must-have, scale/workload, deployment/data residency,
   team capability, budget horizon, compliance, integration/consumer และ exit constraint.
   ห้ามเลือก candidate ก่อนรู้ criteria
2. Inventory ของเดิมใน repo และต้นทุน migration. การไม่มี direct import ไม่พิสูจน์ว่าไม่มี
   integration; ตาม config, generated client, data, deployment และ operational dependency
3. สร้าง shortlist เฉพาะตัวเลือกที่ผ่าน must-have แล้วตรวจจาก source ปัจจุบัน:
   support/lifecycle, release/maintenance activity, compatibility, security/advisory process,
   license, pricing/limits, SLA/support, data handling/residency, portability และ deprecation policy
4. แยก vendor claim ออกจาก independent evidence. Official docs ยืนยัน contract/pricing/policy;
   benchmark/review ยืนยันได้เฉพาะ workload, version และ methodology ที่เปิดเผยและใกล้บริบทจริง
5. คิด total cost ไม่ใช่ราคาเริ่มต้น: implementation, migration, operations, observability,
   training, usage growth, egress, support, lock-in และ exit/data export
6. หาก source แยกผู้ชนะไม่ได้ ให้ทำ bounded proof-of-concept หรือ measurement ที่พิสูจน์
   uncertainty สำคัญที่สุด; demo สำเร็จไม่เท่ากับ production fit

ส่งมอบ criteria-weighted comparison โดยแยก fact/inference/unknown, source + checked date,
repo applicability, risk และ exit cost. เสนอ recommendation พร้อมเหตุผลและ condition ที่ทำให้
คำแนะนำเปลี่ยน แต่ห้ามเลือกซื้อ เพิ่ม dependency หรือ migration เองหาก scope ยังไม่ได้อนุมัติ.
