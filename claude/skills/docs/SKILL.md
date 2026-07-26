---
name: docs
description: "ตระกูล skill งานเอกสารทั้งหมด — setup (วางระบบเอกสาร repo), workspace (แยกเจ้าของความรู้ใน workspace หลาย independent repos), placement (เกณฑ์ว่าความรู้อยู่บ้านไหน comment/docstring/docs/memory/CLAUDE.md), link (ตรวจ broken reference), stale (ตรวจเนื้อหาเอกสารขัดกับโค้ด live) ใช้เมื่องานเกี่ยวกับเอกสาร/ความรู้แต่ยังไม่ชัดว่าเป็นด้านไหน — ถ้าชัดแล้วเรียก sub ตรง: /docs:setup /docs:workspace /docs:placement /docs:link /docs:stale"
---

# Docs — ตระกูลงานเอกสาร

เลือก sub ตามงาน:

| sub | ใช้เมื่อ |
|---|---|
| **/docs:setup** | วางระบบเอกสารให้ repo (CLAUDE.md + docs/ + memory/ + hooks) หรือ re-apply/refactor ของเดิม |
| **/docs:workspace** | จัดเอกสารระดับ workspace ที่มีหลาย independent Git repos: owner ของ fact, inventory/pointer, cross-repo convention/contract/rollout/handoff และ standalone-clone boundary |
| **/docs:placement** | ตัดสินว่าความรู้ชิ้นหนึ่งอยู่ไหน (comment/docstring/codetag/docs/memory/CLAUDE.md) + วินัย comment/docstring |
| **/docs:link** | ตรวจ broken reference (md↔md, md→code, code→docs) — script deterministic |
| **/docs:stale** | ตรวจ*เนื้อหา*เอกสารขัดกับโค้ด live จริงไหม — live code ชนะเสมอ; LLM-judgment ยึดหลักฐาน |

งานเดียวแตะหลายด้าน = ระบุ scope ก่อนว่า repo เดียวหรือ workspace → setup (ต่อ repo) →
workspace (เฉพาะหลาย independent repos) → placement (จัดเนื้อหา) → link (reference) →
stale (เนื้อหา — รอบตรวจ ไม่ใช่ทุก commit)
