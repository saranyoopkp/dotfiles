# Production Safety & Recovery

- Validate untrusted input ที่ server boundary; external I/O มี timeout/deadline และ intentional failure path.
  User-facing error ไม่ leak internal detail แต่ operator ต้องตาม root cause ได้.
- Retry/double-submit side effect ต้อง idempotent/deduplicated ตาม semantics; rollout ใช้ compatibility floor.
- Secret อยู่ environment/gitignored secret store ไม่ hardcode/commit/log. Secret ที่หลุดถือว่า compromised
  และต้อง rotate; telemetry เก็บ PII เท่าที่จำเป็นพร้อม access/retention/redaction.
- Health วัด dependency และสถานะปัจจุบัน ไม่ใช่เพียง process/event ยังมี. Resource ที่เต็มได้และ silent
  failure เช่น worker/cron/webhook/queue ค้างต้องมี metric, heartbeat/reconciliation หรือ alert ที่ตรวจได้จริง.
- Backup แยก failure domain และ restore ต้องเคยซ้อม. ก่อน deploy รู้ rollback/forward mitigation ของ code
  และ data; recovery ที่ทำมือมี runbook ที่คนอื่นทำตามได้.
- หลัง deploy ตรวจ consumer flow/health path ที่ครอบ dependency จริง. Build, resource existence หรือ rollout
  completion ไม่พิสูจน์ว่าระบบพร้อมใช้.
- ปรับความเข้มตาม stage/risk ที่มีหลักฐาน; stage ไม่ชัดและเปลี่ยน decision ให้ถาม มิฉะนั้นใช้ safe baseline
  พร้อมบอก assumption และ known recovery gap.
