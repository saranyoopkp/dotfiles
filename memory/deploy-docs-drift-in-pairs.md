---
name: deploy-docs-drift-in-pairs
description: แก้ kit docs-drift.sh แล้ว deploy ต้องไปคู่ settings.json เสมอ (ยกเว้นแก้ script อย่างเดียวโดย settings ไม่เปลี่ยน) — เคย desync ที่ repo อื่นมาแล้ว
metadata:
  type: project
---

docs-drift.sh + settings.json = คู่ deploy — แก้ตัวใดตัวหนึ่งให้เช็คอีกตัวว่าต้องตามไหม
**Why:** เคย deploy แค่ settings.json ตอนตัด FileChanged → comment ค้างเวอร์ชันเก่าที่
repo อื่น (macOS จับได้ 2026-07-12) — ดู docs/hook-saga.md §deploy checklist
