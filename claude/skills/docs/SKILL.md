---
name: docs
description: Route documentation-system work: repository setup, cross-repo ownership, knowledge placement, broken links, or stale-content audits. Use when documentation is the task and the relevant child is unclear; invoke a specific docs:* child directly when clear.
---

# Docs — ตระกูลงานเอกสาร

เลือก sub ตามงาน:

| sub | ใช้เมื่อ |
|---|---|
| **/docs:setup** | install/adopt/re-apply kit หรือ refactor CLAUDE.md + docs + linked memory + hooks เป็นระบบเดียว |
| **/docs:workspace** | จัดเอกสารระดับ workspace ที่มีหลาย independent Git repos: owner ของ fact, inventory/pointer, cross-repo convention/contract/rollout/handoff และ standalone-clone boundary |
| **/docs:placement** | ตัดสินบ้านของความรู้/วินัย comment-docstring หรือจัด topology, subfolder และ index ของ docs tree เดิม |
| **/docs:link** | ตรวจ broken reference (md↔md, md→code, code→docs) — script deterministic |
| **/docs:stale** | ตรวจ*เนื้อหา*เอกสารขัดกับโค้ด live จริงไหม — live code ชนะเสมอ; LLM-judgment ยึดหลักฐาน |

งานเดียวแตะหลายด้านให้ invoke เฉพาะ child ที่ concern นั้นต้องใช้; ลำดับ setup → workspace →
placement → link → stale เป็น dependency ที่อาจเกิด ไม่ใช่ checklist บังคับทุกงาน.
