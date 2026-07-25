---
name: data-design:async-dataflow
description: ออกแบบ queue/worker, derived data, external sync, event/data pipeline, single-writer boundary และ replay/reconciliation ใช้เมื่อข้อมูลถูกประมวลผลภายหลังหรือไหลข้าม service/provider
---

# Async Dataflow

- อย่า queue สิ่งที่ caller ต้องรู้ผลทันที; queue คือ eventual completion ไม่ใช่ sync ที่ปลอมเป็น async
- fact หนึ่งมี writer หลักเดียว. หากหลาย source เขียนได้ ให้กำหนด source priority/conflict resolution และจดไว้ก่อน implement
- derived data ต้อง recompute ได้จาก source; เก็บ source/raw event, external ID และ sync timestamp สำหรับ external sync เพื่อ replay, reconcile และตรวจย้อนกลับได้
- ข้อความ/งานที่ส่งซ้ำได้ต้อง idempotent และ worker ต้อง reconcile หลัง retry/crash; อย่าถือว่า event delivery exactly-once โดยไม่มี evidence
- กำหนด visibility ของ pending/failed work, replay boundary และ owner ของ dead letter ให้ชัด; ห้ามลบหลักฐานที่ยังต้องใช้ recover หรือ audit

reliability ของ inbound/outbound webhook, replay/reconciliation และ DLQ อยู่ `external-integration-safety`; operation ที่
client ติดตามผ่าน HTTP อยู่ `api-design:async-operations`; health/backlog signal อยู่ `ops:observability`.
ตรวจ duplicate, crash/retry และ reconciliation อย่างน้อยหนึ่ง flow ที่ระบบอ้างว่ารองรับ.
