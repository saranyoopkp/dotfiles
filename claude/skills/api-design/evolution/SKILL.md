---
name: api-design:evolution
description: จัดการ REST public contract evolution, compatibility, versioning, deprecation และ migration ใช้เมื่อเปลี่ยน request/response shape, semantics, enum, pagination/query behavior หรือ endpoint ที่ client เดิมอาจพึ่งอยู่
---

# Evolution

- ก่อนเปลี่ยน contract หรือ observable semantics ของ endpoint เดิม ให้ inventory consumer จาก
  usage จริง เช่น generated client, query/API wrapper, frontend, mobile, service และ external contract.
  ถ้าพบ frontend consumer ที่ behavior ได้รับผล ให้ invoke `ui-ux-baseline` เฉพาะ child ที่ตรง
  ก่อนวางแผนหรือแก้ consumer แม้งานนี้เป็น plan/review แล้ว migrate และ verify user flow นั้น;
  ถ้าอยู่นอก authorized scope ให้รักษา compatibility หรือขอ
  decision แทนการปล่อยให้ UI drift. Endpoint ใหม่ที่ยังไม่มี frontend consumer ไม่ต้อง invoke UI
  เพียงเพราะเป็น API.
- แยก additive change ออกจาก breaking change ด้วย observable client behavior: เพิ่ม optional field มัก additive แต่เปลี่ยน meaning/default, remove/rename field, enum narrowing, status/error/pagination semantics เปลี่ยนคือ compatibility risk
- version เมื่อ compatibility path ไม่พอ; เลือก URL/header/media-type versioning ตาม convention เดิมของ product แล้วจด owner, client migration และ retirement condition
- deprecation ต้องบอก consumer ที่ได้รับผล, replacement, window/timeline และ telemetry/verification ที่ใช้ตัดสินใจปิดของเก่า; ห้ามประกาศ deprecated แล้วตัดทันทีโดยไม่มี evidence
- destructive change ใช้ expand ของใหม่แบบ optional → migrate consumer พร้อม telemetry →
  contract ของเก่าเมื่อมี evidence ว่าไม่มี consumer เหลือ; rename ไม่ใช่ one-step change
- OpenAPI/schema, generated client, docs และ contract tests ต้องเปลี่ยนร่วมกับ implementation

ก่อนลงมือ behavioral/breaking change ให้ใช้ authorization และ impact rules ใน
`claude/rules/core/change-control.md` พร้อมทางเลือกและ approval;
feature flag/rollout mechanism ใช้ safety contract ใน `compatibility-rollout` และห้ามใช้บัง
incompatible state. ก่อนปิดงานตรวจ consumer flow หรือ contract test ที่เป็นตัวแทนของ compatibility จริง.
