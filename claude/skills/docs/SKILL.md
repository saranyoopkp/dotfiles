---
name: docs
description: Router งานเอกสารและความรู้. ใช้เมื่อยังไม่ชัดว่าต้อง setup ระบบ docs, จัด owner ข้าม repo, เลือกบ้านของ fact, ตรวจ link หรือหา stale content; ถ้าชนิดงานชัดให้เรียก `/docs:*` child ที่ตรง
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
