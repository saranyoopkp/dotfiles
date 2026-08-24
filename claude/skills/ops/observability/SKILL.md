---
name: ops:observability
description: ออกแบบ observability เช่น health/heartbeat, logs, metrics, traces, alerts และ SLI/SLO. ใช้เมื่อเพิ่ม service/job/queue/integration, แก้ blind spot หรือต้องพิสูจน์ว่า failure ถูกตรวจพบและวินิจฉัยได้
---

# Observability

เริ่มจาก user/service outcome และ failure mode ไม่ใช่จาก dashboard หรือ metric ที่มีอยู่แล้ว

1. ระบุ critical path, owner และคำถาม operational ที่ต้องตอบได้: system ใช้ได้ไหม, ใครได้รับผล, failure อยู่ชั้นใด, และกู้/rollback แล้วดีขึ้นจริงไหม
2. กำหนด signal ที่แยก `ไม่มีงาน` ออกจาก `ตัวประมวลผลตาย`: health ที่ตรวจ dependency ตามเหมาะสม, heartbeat/lease หรือ timestamp ของ successful run สำหรับ job/queue/webhook; event log เงียบอย่างเดียวไม่ใช่ health signal
3. ให้ logs, metrics และ traces มีหน้าที่ต่างกัน: structured log สำหรับเหตุการณ์และ correlation, metric สำหรับ rate/error/latency/saturation, trace สำหรับเส้นทางข้าม dependency; ใส่ correlation ID ที่ตามเหตุการณ์ได้โดยไม่ log secret/PII
4. Alert ต้อง actionable: มี owner, severity, threshold/window ที่สัมพันธ์ user impact, runbook/next check และ dedupe/aggregation ที่ไม่ทำให้ alert storm; dashboard เฉย ๆ ไม่ใช่ alert
5. วัดทั้ง success และ failure path ที่สำคัญ รวมถึง dependency failure, retry/backlog, timeout และ silent failure; อย่าใช้ metric เฉลี่ยกลบ tail latency หรือ partial outage
6. ทดสอบ signal ด้วย failure ที่ปลอดภัยหรือ controlled evidence: alert ต้องยิง, context ต้องพอ triage และ recovery ต้องทำให้ signal กลับสู่ปกติ; ถ้ายังไม่ทดสอบให้ระบุเป็น gap

ก่อนเพิ่ม telemetry ใหม่ ตรวจ cost/cardinality/retention และ data classification; metric label หรือ log field ที่ cardinality สูงและข้อมูลอ่อนไหวอาจทำให้ observability เองเป็น incident ได้.
