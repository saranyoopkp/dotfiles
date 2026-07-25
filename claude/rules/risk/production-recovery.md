# Production Safety & Recovery

สำหรับงานที่จะขึ้น production (ไม่ใช่ prototype/ทดลอง) ต้องตอบได้ว่า **ระบบปลอดภัยและทำงาน
อยู่จริงไหม** และ **ถ้าพังตอนนี้กู้ยังไง**.

## Boundary และ failure safety

- input จาก user, API, file หรือระบบภายนอกต้อง validate ที่ server boundary ก่อนใช้;
  client validation เป็น UX เสริม ไม่ใช่ security boundary
- external call/IO ต้องมี failure path ที่ตั้งใจ; user-facing error ห้าม leak internal detail
  และห้ามกลืน error จน operator ตามเหตุไม่ได้. timeout/unbounded wait อยู่ `performance-discipline`
- side effect ที่ retry/double-submit ได้ต้อง idempotent หรือมี deduplication ที่สอดคล้องกับ
  semantics; UI ป้องกัน duplicate intent แต่ server ยังต้องรับ retry ได้อย่างปลอดภัย
- migration/public contract ต้อง compatible ระหว่าง deploy ตาม `compatibility-rollout`;
  rollback ต้องไม่ตั้งอยู่บนสมมติฐานว่าจะย้อน data state ได้เสมอ

## Secrets, PII และ auditability

- secret อยู่ใน environment หรือ gitignored secret store เท่านั้น ห้าม hardcode/commit;
  ใน CI ค่าอ่านได้หรือโผล่ log ได้ไม่ใช่ secret
- secret ที่เคยหลุดลง git ถือว่า compromised: rotate เสมอ; purge history อย่างเดียวไม่พอ
- log จุดสำคัญ เช่น auth, เงิน, การลบ และ external integration ให้ตาม actor/action/result ได้
  โดยห้าม log secret หรือ PII เกินความจำเป็น
- retention, access และ redaction ของ telemetry ต้องสอดคล้องกับ sensitivity และ audit need;
  operator ต้องรู้ว่า log/metric/trace อยู่ไหนและค้นอย่างไร

## มองเห็นได้

- service มี health signal ที่ตรวจ dependency สำคัญ ไม่ใช่เพียง process ยังอยู่ และมี monitor
  ภายนอกคอยตรวจ ไม่รอ user แจ้ง
- disk, memory, connection pool, queue backlog และ resource ที่เต็มได้มี metric/alert ก่อนหมด
- health signal มาจาก **สถานะ** ไม่ใช่ event ที่อาจไม่เกิด: ใช้ heartbeat, lease หรือ timestamp
  ของรอบล่าสุดเพื่อแยก “ไม่มีงาน” จาก “ตัวทำงานตาย”
- inventory silent failure mode เช่น cron หยุด, webhook หาย, service ไม่ auto-start, queue ค้าง
  แล้วครอบด้วย alert, poller หรือ reconciliation ที่ตรวจ failure นั้นได้จริง

## กู้คืนและปล่อยของ

- backup อัตโนมัติ เก็บแยก failure domain จากระบบหลัก และ restore ต้องเคยซ้อมจริง
- รู้ rollback path ก่อน deploy: artifact/revision เดิม, compatibility ของ migration และ mitigation
  เมื่อ data ย้อนกลับไม่ได้
- recovery ที่ต้องทำมือ เช่น unseal, restart order หรือ rotate/reload secret ต้องมี runbook
  ที่คนอื่นทำตามได้; sensitive detail อยู่ในพื้นที่ที่ repo กำหนดให้ private
- หลัง deploy ตรวจ flow หรือ health path ที่ครอบ dependency จริง; rollout สำเร็จหรือ build ผ่าน
  ไม่ได้พิสูจน์ว่าระบบใช้งานได้

ระดับความเข้มปรับตาม stage ที่ repo ระบุ; ถ้าไม่พบ stage ห้ามแต่งขึ้น ให้ถามเมื่อมีผลต่อ decision
หรือใช้ production-grade เป็น baseline พร้อมระบุสมมติฐาน. ช่องว่างของ health monitoring, restore drill,
rollback หรือ silent-failure coverage ต้องถูกบันทึกเป็น known gap ไม่ใช่เงียบไว้.
