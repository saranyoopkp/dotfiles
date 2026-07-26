---
name: docs:workspace
description: จัด วาง หรือ audit ระบบเอกสารของ workspace ที่มีหลาย independent Git repositories โดยแยกเจ้าของ fact ระหว่าง workspace กับแต่ละ repo, ทำ inventory/pointer, shared convention, cross-repo contract/rollout/handoff และตรวจว่า repo ยัง clone เดี่ยวได้ ใช้เมื่อโฟลเดอร์เดียวรวมหลาย repo, เอกสารอ้างข้าม repo, ต้องวาง CLAUDE.md/docs ระดับ workspace, หรือกำลังย้ายความรู้ระหว่าง workspace root กับ sub-repo; ไม่ใช้กับ monorepo ที่มี Git root เดียว
---

# Docs Workspace — เอกสารหลาย repo โดยไม่สร้างบ้านซ้ำ

เป้าหมายคือให้ fact แต่ละชิ้นมี owner เดียว: repo ถือความจริงที่มันเปลี่ยนและตรวจเองได้;
workspace ถือเฉพาะความจริงที่ต้องเห็นหลาย repo พร้อมกัน

## Scope gate

1. หา Git root จริงก่อน:
   ```bash
   find <workspace> -name .git -prune -print
   ```
   รองรับทั้ง `.git` directory และ file (worktree/submodule); ปรับ depth/exclude ให้ตรง tree จริง
   และอย่าสรุป inventory จาก `find` query เดียวถ้ายังมี path ที่ prune หรือเข้าถึงไม่ได้
2. มี Git root เดียวและ packages อยู่ใต้ root นั้น = **monorepo** ใช้ `/docs:setup` +
   `/docs:placement`; ไม่สร้าง workspace layer
3. มีหลาย independent Git roots = ใช้ skill นี้ แม้ workspace root จะไม่มี Git หรือมี repo
   เล็กของตัวเองไว้ track เอกสารระดับบน
4. ระบุ repo ที่ active/in-scope จากหลักฐานก่อน; การมี directory อย่างเดียวไม่พิสูจน์ว่า active
   และห้ามย้าย/ลบเอกสารเพียงเพราะ repo ไม่อยู่ใน inventory ปัจจุบัน

## Owner test

ถามตามลำดับ:

1. Repo เดียวเปลี่ยนและ verify fact นี้ได้ครบหรือไม่?
   - ได้ → อยู่ใน repo นั้น
   - ไม่ได้ ต้องประสานตั้งแต่สอง independent repos ขึ้นไป → อยู่ workspace
2. เมื่อ clone repo เดี่ยว เอกสารยังเข้าใจและทำงานได้โดยไม่มี sibling checkout หรือไม่?
   - ไม่ได้ → ย้าย cross-repo part ไป workspace; repo เหลือ local interface/constraint ของตน
3. เนื้อหาเป็น source of truth หรือ snapshot?
   - living truth → owner doc
   - audit/report/measurement ณ เวลาใดเวลาหนึ่ง → แยกเป็น point-in-time พร้อมวันที่,
     scope, command/source และสถานะ Verified/Unverified/Contradicted

ชื่อระบบภายนอกที่เป็นส่วนหนึ่งของ interface ของ repo กล่าวได้ แต่ห้ามใช้ workspace-relative
path, branch/commit, implementation detail หรือ decision ภายในของ sibling เป็น dependency
ของเอกสารใน repo นั้น

## บ้านของเอกสาร

| บ้าน | ถืออะไร | ห้ามถือ |
|---|---|---|
| workspace `CLAUDE.md` | workspace boundary, pointer inventory สั้น, cross-repo risk/decision/TODO ที่ต้องเห็นทุก session | stack/status/decision ฉบับเต็มของแต่ละ repo, จำนวนหรือรายชื่อที่คำนวณจาก tree ได้แต่ไม่มีคำสั่งกำกับ |
| workspace `docs/conventions/` | vocabulary หรือ delivery convention ที่ใช้ข้ามหลาย repo จริง | convention ของ repo เดียวหรือมาตรฐานเผื่ออนาคต |
| workspace `docs/contracts/` | contract ที่ correctness ต้องอาศัยหลาย repo และไม่มี repo เดียวเป็น owner | API/schema ที่ provider repo เป็นเจ้าของได้ครบ |
| workspace `docs/plans/` | rollout, migration, compatibility และ rollback ที่ต้องเรียงหลาย repo | implementation plan ภายใน repo เดียว |
| workspace `docs/handoff/` | ช่องประสานชั่วคราว: owner section, pending decision, evidence, next action | transcript, activity log หรือ fact ถาวรที่ควร promote กลับบ้านจริง |
| workspace `docs/audits/` | point-in-time cross-repo finding พร้อม provenance | living truth ที่ไม่มีวันตรวจ |
| sub-repo `CLAUDE.md`/`docs/`/`memory/` | mission, stack, interface, decision, runbook, quirk และหลักฐานของ repo นั้น | path หรือ internal fact ของ sibling repo |

ไม่ต้องสร้างทุก directory: สร้างเมื่อมีเนื้อหาจริงเท่านั้น ใช้ชื่อโดเมนแทนวันที่สำหรับ living
docs; ใช้วันที่กับ snapshot/audit ได้

## Workflow

### 1. Inventory แบบ evidence-first

- อ่าน workspace `CLAUDE.md`, `docs/`, README และ config เดิมก่อน
- map Git roots, remote, worktree/submodule state และไฟล์ entry ของแต่ละ repo
- อ่าน `CLAUDE.md`/docs index ของ repo ที่ in-scope; อย่าเดา mission จากชื่อ directory
- เทียบ inventory เดิมกับ tree จริง แล้วแยก `active`, `archived`, `unknown`; ถ้าหา intent
  จาก repository/history ไม่ได้ ค่อยถาม user หลังรวบคำถามเป็นชุดเดียว

### 2. ร่าง owner map ก่อน mutation

รายงานตาราง `fact/topic | current home | evidence | proposed owner | reason | action`
ก่อนย้ายหรือสร้างเอกสารจำนวนมาก จุดที่เปลี่ยน ownership หรือทำให้ standalone clone contract
เปลี่ยนต้องบอก user ก่อน mutation; finding ไม่ใช่ authorization

### 3. จัด root เป็น router ไม่ใช่ mirror

- inventory ต่อ repo ใช้ pointer + short info 1–3 บรรทัด
- local detail ชี้เข้า owner repo; ห้าม copy มาไว้ root
- cross-repo decision ระบุเหตุผล, ทางที่ไม่เลือก และวันที่; โตแล้วแยกไป workspace docs
- index ต้องพาไปถึงเอกสารสำคัญ แต่ห้าม hardcode fact ที่หาได้จาก source โดยไม่บอกวิธี reproduce

### 4. แยกและย้ายทีละ fact

- local fact ที่รั่วขึ้น root → ย้ายกลับ owner repo แล้ว root เหลือ pointer
- cross-repo fact ที่กระจายในหลาย repo → สร้าง workspace source หนึ่งบ้าน แล้วลบ assertion
  ซ้ำจาก sub-repo; เก็บ local constraint ที่จำเป็นต่อ standalone clone
- handoff ที่จบแล้ว → promote durable result ไป owner docs, ปิด pending item แล้วลบ log/noise
- ห้าม big-bang rewrite; รักษา history ด้วย `git mv` ภายใน repo เดียวเมื่อเหมาะสม

### 5. Validate ตาม boundary จริง

รัน deterministic audit:

```bash
python "${CLAUDE_SKILL_DIR}/scripts/audit.py" <workspace>
```

จากนั้น:

- รัน `/docs:link` แยกใน workspace docs repo และทุก sub-repo ที่แตะ
- clone/inspect ในมุม repo เดี่ยว: link, command และ instruction ต้องไม่ต้องพึ่ง sibling checkout
- เปิด source ที่เป็นเจ้าของทุก durable finding โดยตรง; report จาก agent/audit เป็น lead ไม่ใช่ proof
- ตรวจ `git diff` แยกต่อ Git root และรายงาน repo ที่เปลี่ยนพร้อม validation ของ repo นั้น

script ตรวจ link escape, missing target และ absolute user-home path ที่ผูกกับเครื่องใดเครื่องหนึ่ง
ใน Markdown ที่ Git track (`~` แบบ portable ไม่นับ);
มันไม่ตัดสิน semantic ownership และไม่พิสูจน์ว่า mention ชื่อ repo อื่นผิด

## Report

สรุป:

- Git roots ที่ตรวจและข้อจำกัดของ inventory
- owner map ที่เปลี่ยน พร้อมไฟล์ต้นทาง/ปลายทาง
- cross-repo contracts/risks/pending decisions
- validation ต่อ repo พร้อมคำสั่งและผลจริง
- `Unverified`/`Contradicted` และสิ่งที่ยังต้องถาม

ห้ามรวม working tree ของหลาย repo เป็นก้อนเดียวหรือรายงาน workspace ว่าสะอาดจากการตรวจ
เฉพาะ root repo
