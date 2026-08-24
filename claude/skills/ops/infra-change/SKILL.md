---
name: ops:infra-change
description: วางแผน ตรวจ หรือเปลี่ยน infrastructure/IaC, cloud resource, network, IAM, secret reference, provisioning, state และ drift ที่อาจกระทบ environment จริง
---

# Infrastructure Change

แยกให้ชัดว่าเป็น `inspect`, `plan`, หรือ `apply`: inspect/plan รวบรวมหลักฐานได้ตาม scope; apply หรือ mutation ของ provider/state ต้องมี authorization ชัดเจนก่อนเสมอ

1. ระบุ environment, account/project/cluster/region, source of truth และ resource ที่จะกระทบ; ห้ามเดาจากชื่อ file หรือ default CLI context
2. อ่าน existing state/config และ dependency ก่อนเปลี่ยน: consumer, permission boundary, network path, data/state ที่มีอยู่ และ rollback/mitigation ที่ทำได้จริง
3. สร้าง plan ที่ตรวจสอบได้และสรุป create/change/destroy, blast radius, precondition, downtime/compatibility risk และสิ่งที่ย้อนกลับไม่ได้; plan สะอาดไม่เท่ากับปลอดภัย
4. secret มีได้เฉพาะ reference/secret manager/env ที่เหมาะสม: ห้าม print, copy ลง state/log/doc ที่ track หรือใช้เป็น output ของ plan
5. ก่อน apply อธิบาย target, plan, risk, rollback/mitigation และขอ authorization; ห้ามขยายจาก resource ที่ขอไปแก้ drift อื่นเงียบ ๆ
6. หลัง apply ตรวจผลที่ผู้ใช้/consumer ใช้จริง ไม่ใช่แค่ tool exit 0: permission ใช้ได้, network เชื่อมได้, service health และ alert/monitor ที่เกี่ยวข้องยังทำงาน
7. บันทึก source of truth, intentional exception และ runbook ที่จำเป็นใน repo docs; sensitive detail ไป private path ตาม policy

rolling change ต้องตรวจของเก่า/ใหม่อยู่ร่วมกัน, dependency order และ rollback ที่ไม่สมมติว่า
data/state ย้อนกลับได้; precondition ขาดต้อง fail loud ห้ามข้ามแล้วรายงานว่าสำเร็จ.

หาก provider/framework behavior เป็นเหตุผลของ plan ให้ใช้ primary documentation ที่ตรง version/context และแยกออกจากหลักฐานว่า environment นี้ได้รับผลจริงอย่างไร.
