---
name: data-design:schema-migrations
description: ออกแบบหรือแก้ DB schema, relation, enum, JSON field, ID, constraint, index, migration หรือ backfill ใช้ทุกครั้งที่เพิ่ม/เปลี่ยน table หรือ column และเมื่อ data shape ที่ code เดิมพึ่งพาอาจเปลี่ยน
---

# Schema & Migrations

- normalize by default; denormalize เมื่อมีหลักฐานด้าน performance พร้อม owner และวิธี keep-in-sync ไม่ใช่เพราะไม่อยาก join
- ใช้ enum type หรือ lookup table สำหรับ state/type ที่ถูกควบคุม; ใช้ JSON เฉพาะข้อมูลที่ variable จริง และย้าย field ที่ filter/join/aggregate บ่อยเป็น column
- ให้ DB บังคับ invariant ที่เป็นจริงเสมอด้วย FK, unique, check หรือ constraint ที่เหมาะสม; ทุก table มี created/updated timestamp และ FK ที่ join/cascade ต้องมี index
- เลือก ID ตั้งแต่แรก และให้ external reference ที่ import มี unique constraint; ระบุ on-delete behavior ของ relation เสมอ
- ตรวจ index จาก query/filter/sort ที่มีจริง ไม่สร้าง index หรือ materialized shape จากการเดา

ก่อน migration ให้ระบุ consumer และ schema/code ที่อยู่ร่วมกันได้. การ remove/rename, เปลี่ยน meaning,
บังคับ required หรือ rewrite data ใช้ expand → migrate/backfill → switch consumer → contract ตาม
`compatibility-and-rollout`; backfill ต้องทำเป็น batch ที่ monitor/หยุด/รันซ้ำได้ และ migration ต้องรู้ lock
กับผลต่อ deploy/rollback หรือ forward-fix ก่อน apply.

ตรวจ migration กับ schema เดิมและข้อมูล representative รวมทั้ง constraint/index ที่เพิ่ม; ถ้าตรวจ lock
หรือ backfill จริงไม่ได้ ให้ระบุความเสี่ยงและแผน verify แทนการอ้างว่าปลอดภัย.
