---
name: ops:incident-response
description: Triage และจัดการ incident หรือ production degradation อย่างเป็นระบบ ใช้เมื่อระบบล่ม ช้า ผิดปกติ มี data/security concern, alert สำคัญ หรือผู้ใช้ได้รับผลกระทบ ต้องรวบรวมหลักฐาน ประเมิน blast radius เสนอ mitigation และตรวจ recovery โดยไม่ทำ external mutation เอง
---

# Incident Response

เป้าหมายเรียงลำดับ: ลดอันตรายต่อผู้ใช้/ข้อมูล → รู้ blast radius → กู้บริการอย่างควบคุมได้ → เก็บหลักฐานสำหรับการป้องกันซ้ำ. อย่าสรุป root cause ระหว่างที่ยังมีเพียง symptom

1. เปิด incident record แบบสั้น: เวลาเริ่ม/พบ, service/environment, symptom, reporter/alert และผลกระทบที่ยืนยันแล้ว; แยก fact, inference และ unknown
2. ทำ triage แบบ read-only ก่อน: health, recent deploy/config change, error rate/latency, dependency state, logs/traces และ user path ที่ได้รับผล; เก็บ timestamp/correlation ID ก่อนข้อมูลหมุนหาย
3. ระบุ blast radius: ใคร/ข้อมูลใดได้รับผล, ยังเกิดอยู่หรือไม่, มี risk ด้าน security/financial/data integrity หรือไม่ และ action ใดอาจทำให้แย่ลง
4. เสนอ mitigation ที่ย้อนกลับได้ตามลำดับ พร้อมผลข้างเคียง, precondition และวิธี verify; restart, rollback, traffic shift, feature disable, secret/permission change หรือ data repair ต้องมี owner authorization ก่อนทำ
5. หลัง owner เลือก action ให้ทำเฉพาะ scope ที่อนุมัติ แล้ว verify จาก signal จริงและ user-critical path; “alert หาย” อย่างเดียวไม่พอถ้า dependency/user flow ยังพัง
6. ก่อนปิด ระบุสถานะ recovery, residual risk, owner/follow-up, หลักฐานและสิ่งที่ยังไม่ยืนยัน; postmortem ต้องแยก trigger, contributing factors, detection gap และ corrective action ไม่โทษบุคคล

หากมีเหตุ data/security/financial ที่กำลังดำเนินอยู่ ให้ยกระดับตาม incident policy ขององค์กรก่อนการวิเคราะห์เชิงลึกหรือการเปลี่ยนแปลงที่อาจทำลายหลักฐาน.
