---
name: docs:setup
description: Set up or refactor a repo's documentation system (CLAUDE.md + docs/ + memory/ linked into the harness) using the user's docs-setup kit. Use when asked to setup/refactor project docs, CLAUDE.md, or project memory.
---

# Docs Setup — ระบบเอกสารมาตรฐานของ user

User ใช้ระบบเอกสารแบบเดียวกันทุก repo — **kit ตัวจริงอยู่ที่ `${CLAUDE_SKILL_DIR}/kit/`**

อ่าน `kit/README.md` ก่อนเสมอ (กลไก + วิธี adopt + วิธี refactor) — นั่นคือ source of truth
ของ*กลไก*; ส่วน*หลักการ*อยู่ที่ rule `documentation-discipline` (โหลดทุก session อยู่แล้ว)
ไฟล์นี้เป็นแค่ตัวนำทาง

## ระบบโดยย่อ (เพื่อให้เข้าใจบริบทว่ากำลังทำอะไร)

- `CLAUDE.md` = **สถานะปัจจุบัน** ไม่ใช่ changelog; ทุก decision มีวันที่ + เหตุผล
- `docs/<topic>.md` = เจาะลึกรายเรื่อง (section ใน CLAUDE.md โตเกิน ~15 บรรทัด → แยกออกมา)
- **monorepo/submodule**: setup แล้วเอกสาร module อยู่ในตัว module, root = pointer +
  short info (ดู template §เส้นแบ่ง) — submodule ต้องพกเอกสารตัวเองไปทุก super-repo
- **เกณฑ์เลือกบ้านของทุกเนื้อหา = กลไกที่ถูกอ่าน (push/pull/recall)** — ตารางเต็ม +
  คำถามทดสอบอยู่ใน `kit/CLAUDE.template.md` §เส้นแบ่ง — **ทุกขั้นที่จัด/ย้ายเนื้อหา
  (setup ใหม่ ข้อ 2-3, re-apply ข้อ 3) ต้องตัดสินด้วยเกณฑ์นี้** ไม่ใช่ตามหัวข้อ/ความยาวอย่างเดียว
- `memory/` ใน repo = memory ตัวจริงชุดเดียว (version-controlled); ฝั่ง harness
  `~/.claude/projects/<id>/memory` เป็น **link** (junction บน Windows / symlink บน unix)
  ชี้เข้า repo — harness auto-load `MEMORY.md`; leaf เปิดเมื่อ index/task ชี้ ไม่ต้อง sync มือ
- shared memory lifecycle: create/move/rename/delete leaf ต้อง sync pointer + recall hook ใน
  `memory/MEMORY.md` commit เดียวกัน; edit leaf ให้ตรวจ hook และแก้เฉพาะเมื่อความหมาย/relevance เปลี่ยน
- **private/sensitive ห้ามลงไฟล์ที่ track ด้วย git** — ใช้ `docs/private/` และ
  `memory/private/` ของ repo นั้น ๆ (relative จาก Git root): โน้ต ops sensitive
  (secret/IP/server path) → `docs/private/`; fact ส่วนตัว/เฉพาะเครื่อง → `memory/private/`
  (gitignored ทั้งคู่,
  init สร้างให้; ห้าม index ลง `MEMORY.md`). ไม่พบใน index ต้องยังไม่สรุปว่าไม่มี private
- เมื่อ mutation ที่ได้รับอนุญาตถึง cohesive verified checkpoint ให้สร้าง local commit เป็น default
  และให้เอกสารที่เปลี่ยนพร้อมงานอยู่ใน commit เดียวกัน; stage เฉพาะ paths/hunks ใน scope
  และห้าม push หากไม่ได้สั่ง;
  internal docs ภาษาไทยได้, โค้ด/commit เป็นอังกฤษ
- **lifecycle hooks** (`.claude/hooks/` + `.claude/settings.json`, init ติดตั้งให้) ตรวจ baseline/link
  ที่ SessionStart, shared-memory index ที่ Stop และ continuity ที่ PreCompact โดยไม่บังคับ
  comment placement, docs disposition หรือ local commit ของ source edit ปกติ

## Context gathering (ทำก่อนเติม/refactor CLAUDE.md เสมอ)

รวบรวมจากแหล่งจริง ห้ามเดา — เรียงตามลำดับ:

1. **ของเดิมที่มีอยู่**: CLAUDE.md เดิม, `docs/`, `memory/`, README, ADR — อะไรจดไว้แล้วบ้าง
   (จะได้ไม่เขียนทับ/ซ้ำ และเห็นว่า drift ตรงไหน)
2. **โครงจริงของ repo**: manifest (package.json / pyproject / go.mod ฯลฯ), workspace
   layout, docker-compose / k8s / CI config → stack + services + จุด entry จริง
3. **git history**: `git log --oneline -30` → งานล่าสุดคืออะไร, commit style เดิม,
   สัญญาณ drift (fix ซ้ำที่เดิม = quirk ที่ควรจด)
4. **หนี้ที่ประกาศไว้**: scan `TODO(\|FIXME(\|HACK(` → ของค้างระดับจุด
5. **ถาม user เฉพาะที่หาไม่ได้จากโค้ด**: mission/boundary, stage (MVP/production),
   decision ที่ยังไม่ถูกจด — คำถามสั้น รวบเป็นชุดเดียว

จากนั้นค่อยเติม template: Inventory จากข้อ 2, quirks จากข้อ 3, TODO จากข้อ 4,
Mission/Constraints จากข้อ 5 — **ทุกบรรทัดใน CLAUDE.md ต้องชี้กลับไปหาหลักฐานข้อใดข้อหนึ่งได้**

**Coverage gap (ทำก่อนสรุปว่า context gathering เสร็จ)**: ข้อ 1 กับข้อ 2 เก็บมาแยกกัน
ต้อง **cross-reference** ว่าตรงกันไหม — list module/service/route ที่เจอจากโครงสร้างจริง
(ข้อ 2) แล้วเทียบกับที่ถูก mention ในเอกสารเดิม (ข้อ 1) ทีละตัว: อะไรมีในโค้ดแต่ **ไม่ถูก
พูดถึงเลย** ในเอกสารเดิม = documentation gap ที่ต้องเติม ไม่ใช่ปล่อยผ่านเพราะ "ของเดิมไม่ได้
พูดถึงก็แปลว่าไม่สำคัญ" — เอกสารเดิมอาจแค่ตกหล่น (module เกิดทีหลัง, คนเขียนลืม) ไม่ใช่
สัญญาณว่าไม่ต้องจด

**gap ที่ใหญ่ = ยกระดับข้อ 5**: ถ้า gap ครอบหลาย/ทุก module (ข้อ 1 ว่างเปล่าเกือบสนิท —
ไม่มี README/ADR/comment อธิบายเจตนาเลย) แปลว่าข้อ 2-4 ให้ได้แค่ fact (มีอะไร) ไม่มีทาง
ได้ intent (ทำไมถึงออกแบบแบบนี้) มาจากที่ไหนนอกจากถาม — คำถามในข้อ 5 ต้องลึกกว่าปกติ
(เจตนา/design rationale ของ module สำคัญ ไม่ใช่แค่ mission/stage สั้น ๆ) ก่อนเขียน
CLAUDE.md ฉบับแรก

## วิธีใช้

**Repo ใหม่:**
1. รัน init: `bash ${CLAUDE_SKILL_DIR}/kit/init.sh <repo>` (ทุก OS — Windows ผ่าน Git Bash)
   (idempotent — สร้าง CLAUDE.md, memory/, docs/, docs/private/, memory/private/ ที่ Git root
   + .gitignore, link ฝั่ง harness;
   ของเดิม backup เป็น `.bak-*`; **repo เดิมบนเครื่องใหม่ก็รันแบบเดียวกัน** เพื่อสร้าง link ของเครื่องนั้น)
2. เติม CLAUDE.md ตาม placeholder จากสิ่งที่เห็นใน codebase
3. เขียน fact แรก ๆ ลง `memory/` (mission, stack decision, quirks) + อัปเดต `memory/MEMORY.md`

**Repo เดิมที่มี CLAUDE.md แล้ว:**
1. รัน init (จะข้าม CLAUDE.md เดิม แต่สร้าง link + merge harness memory เข้า repo ให้)
2. merge section "Memory policy" จาก `kit/CLAUDE.template.md` เข้า CLAUDE.md เดิม
3. refactor ตาม playbook ใน `kit/README.md`: แยกความรู้ถาวรออกจากประวัติ →
   ก้อนใหญ่ไป `docs/`, fact สั้นไป `memory/` → ย่อ Status เหลือ 1 บรรทัด/module + ลิงก์
4. **กวาด sensitive data** (IP, server path, credential, procedure ที่แลกกับความปลอดภัย)
   ออกจาก CLAUDE.md/docs → ย้ายไป `docs/private/` ของ repo นั้นแล้วแทนที่ด้วย pointer

**Re-apply / upgrade (repo ที่ setup ไปแล้ว — รัน `/docs:setup` ซ้ำเพื่อรับของใหม่จาก kit):**

มีสองชั้นที่**ความเร็วต่างกันจริง** อย่าคาดหวังว่าทั้งคู่เร็วเท่ากัน:

1. **ชั้น mechanical** (ไฟล์ที่ kit เป็นเจ้าของทั้งไฟล์ — `docs-drift.sh`, `settings.json`)
   — รัน init ซ้ำ ทำให้อัตโนมัติจริง: อัปเดต hooks script (atomic write), migrate
   settings.json เวอร์ชันเก่า (ps1→bash, path resolution รุ่นก่อน — init เตือน
   MIGRATION NEEDED ถ้าต้องทำมือ), ซ่อม memory link — ปลอดภัยเพราะไม่มี customization
   ของ repo ปนอยู่ในไฟล์พวกนี้ (ที่มาของแต่ละ fix ดู `dotfiles/CLAUDE.md` decision log)
2. **ชั้นเนื้อหาใน CLAUDE.md** (Memory policy, checklist, Architecture Decisions ที่
   repo อาจ customize ปนอยู่) — **ไม่มีทางลัด ต้องทำ Context gathering เต็มรูปแบบ
   เหมือน setup ใหม่** (อ่าน CLAUDE.md เดิมทั้งไฟล์ + `kit/CLAUDE.template.md` ปัจจุบัน
   เทียบด้วยตาจริง ไม่ใช่ diff อัตโนมัติ) — นี่ไม่ใช่ข้อจำกัดของเครื่องมือ แต่เป็น
   ทางเลือกที่ตั้งใจ: auto-merge เนื้อหาที่ repo customize ไปแล้วเสี่ยงทับของจริงเกินกว่า
   จะไว้ใจ ให้เวลาทำเต็มที่ อย่ารีบสรุปว่า merge ครบ

ขั้นตอน:
1. รัน init ซ้ำ (จัดการชั้น mechanical ให้)
2. Context gathering ตามหัวข้อด้านบน แล้ว merge เนื้อหาที่ template มีใหม่เข้า CLAUDE.md
   ของ repo (รักษา customization ไว้ อย่าทับทั้ง section)
3. ไล่ convention ใหม่ใน `kit/README.md` ที่ repo ยังไม่ conform (เช่น docs/ กองแบน
   → จัด subfolder + grouped index) → เสนอ/ลงมือจัดตามนั้น
3.5 ปิดท้ายด้วยรอบตรวจ: `/docs:link` (reference) แล้วถ้าเอกสารเก่ามีอายุ/สงสัย drift
   → `/docs:stale` (เนื้อหา vs โค้ด live — scope ตามที่ตกลงกับ user)
4. สรุปให้ user ว่า upgrade อะไรไปบ้าง

## ข้อควรระวัง

- 🔴 **CLAUDE.md ห้ามถือ fact ที่นับ/ลิสต์เองได้เป็นค่า hardcode** — จำนวนไฟล์/บรรทัด/rule/
  table/migration, รายชื่อไฟล์, shape ของ schema/DTO → **ชี้คำสั่ง (`ls`/`wc -l`/`grep -c`)
  หรือชี้ source แทน** ไม่ใช่พิมพ์เลข/ชื่อลงไป (fact ที่ copy = จะ stale แล้วถูกเชื่อ เพราะ
  CLAUDE.md โหลดทุก session = ดูเป็นความจริงแต่ไม่มีใคร re-verify). **ตอน setup/refactor/audit
  ทุกครั้ง**: ไล่หา number/filename ที่ hardcode ไว้ → แปลงเป็นคำสั่ง หรือถ้าจำเป็นต้องมีเลข
  ให้เขียนคำสั่งที่คำนวณมันกำกับข้าง ๆ (นี่คือ single-source ตาม
  `rules/engineering/documentation-discipline.md`)
- ห้ามลบ section "Memory policy" ออกจาก CLAUDE.md — เป็นช่องทางเดียวที่ session อื่นรู้กติกา memory
- memory ใหม่ที่บันทึกระหว่างทำงาน = untracked file ใน repo → คัดกรองก่อน commit:
  **ลบ metadata ส่วนบุคคล** (`originSessionId` ฯลฯ) ออกจาก frontmatter และเช็คว่าไม่มี secret
- ถ้าเจอ harness memory dir ที่ไม่ใช่ link (repo ย้ายเครื่อง/เครื่องใหม่) → รัน init ซ้ำ
