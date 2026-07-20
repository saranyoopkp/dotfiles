# Production Readiness

ใช้กับงานที่มีผู้ใช้หรือระบบจริงได้รับผลกระทบ; ปรับตาม stage และความเสี่ยงของ repo

- boundary ภายนอกมี validation, failure path และ error ที่ไม่รั่วข้อมูลภายใน
- secret ไม่อยู่ใน source, log หรือเอกสารที่ track; หากเคยรั่วให้ rotate
- action สำคัญต้องตามรอยได้โดยไม่ log secret/PII และมีวิธีตรวจ health ของระบบ
- migration, contract และ rollback ต้องปลอดภัยต่อ version ที่อยู่ร่วมกัน (ดู `compatibility-and-rollout`)
- ก่อนอ้างว่าพร้อมใช้งาน ให้ตรวจ flow จริงหรือระบุชัดว่าอะไรยังไม่ได้ตรวจ
- งานที่กระทบข้อมูลหรือผู้ใช้ต้องมี observability/recovery ที่พอดีกับความเสี่ยง: log ที่ตามรอยได้, health signal, backup/rollback path และไม่มี secret/PII หลุดใน log

เรื่อง recovery/monitoring เชิงลึกใช้ `operations-observability`; การทดสอบเลือกตาม `testing-strategy`.
