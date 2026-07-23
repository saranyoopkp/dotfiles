---
name: api-design:evolution
description: จัดการ REST public contract evolution, compatibility, versioning, deprecation และ migration ใช้เมื่อเปลี่ยน request/response shape, semantics, enum, pagination/query behavior หรือ endpoint ที่ client เดิมอาจพึ่งอยู่
---

# Evolution

- แยก additive change ออกจาก breaking change ด้วย observable client behavior: เพิ่ม optional field มัก additive แต่เปลี่ยน meaning/default, remove/rename field, enum narrowing, status/error/pagination semantics เปลี่ยนคือ compatibility risk
- version เมื่อ compatibility path ไม่พอ; เลือก URL/header/media-type versioning ตาม convention เดิมของ product แล้วจด owner, client migration และ retirement condition
- deprecation ต้องบอก consumer ที่ได้รับผล, replacement, window/timeline และ telemetry/verification ที่ใช้ตัดสินใจปิดของเก่า; ห้ามประกาศ deprecated แล้วตัดทันทีโดยไม่มี evidence
- OpenAPI/schema, generated client, docs และ contract tests ต้องเปลี่ยนร่วมกับ implementation; rollout/feature flag อยู่ compatibility-and-rollout ตาม owner เดิม

ก่อนลงมือ behavioral/breaking change ให้ผ่าน behavioral-change gate พร้อมทางเลือกและ approval; ก่อนปิดงานตรวจ consumer หรือ contract test ที่เป็นตัวแทนของ compatibility จริง.
