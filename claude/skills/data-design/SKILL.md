---
name: data-design
description: Router สำหรับการออกแบบ data layer ใช้เมื่อออกแบบหรือแก้ DB schema, migration, index, transaction/invariant, cache, queue/worker/dataflow, data retention, soft/hard delete, audit หรือ PII lifecycle. ก่อนตัดสินใจให้ map source of truth, writer, reader และ lifecycle แล้วอ่าน child ที่ตรง; งาน schema หรือ migration ต้องอ่าน data-design:schema-migrations เสมอ
---

# Data Design

ก่อนเปลี่ยน data layer ให้ระบุ source of truth, ใครเขียน/อ่าน, invariant ที่ห้ามพัง และ data ต้องอยู่
นานเท่าไร แล้วอ่าน child ที่ตรง **ก่อน** แก้ schema, worker หรือ cache.

| ลักษณะงาน | ต้องอ่าน |
|---|---|
| ตาราง, column, relation, enum, JSON, index, ID หรือ migration/backfill | `data-design:schema-migrations` |
| หลาย write ต้องถูกต้องร่วมกัน, lock, isolation, duplicate race หรือ DB event/outbox | `data-design:transactions-invariants` |
| cache key, TTL, invalidation, staleness หรือ cache miss | `data-design:caching` |
| queue/worker, derived data, external sync, event/data pipeline หรือ single writer | `data-design:async-dataflow` |
| retention, archive, soft/hard delete, anonymization, audit/history หรือ PII lifecycle | `data-design:lifecycle-governance` |

งานเดียวอ่านได้หลาย child ตาม flow จริง; ห้ามโหลดทั้งหมดเพียงเพื่อ checklist และห้ามข้าม child ที่
trigger ตรงเพียงเพราะ migration หรือ worker ดูเล็ก. authz/tenant scope, query performance,
backup/restore และ delivery reliability มี owner ใน rules/ops เดิม; skill นี้ไม่ลด requirement เหล่านั้น.

การเปลี่ยน schema, data meaning หรือ lifecycle ที่ consumer สังเกตได้ต้องผ่าน behavioral-change gate
และ compatibility/rollout rule ก่อนลงมือ.
