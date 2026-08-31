---
name: docs:placement
description: Decide where repository knowledge belongs among comments, docstrings, docs, memory, and CLAUDE.md; organize an established docs tree/index; or audit comment/docstring debt. Use when placement, topology, or comment audit is the task; not for kit setup, ordinary comments, or incidental documentation updates with an obvious owner.
---

# Doc Placement — ความรู้ทุกชิ้นมีบ้านเดียว เลือกบ้านจาก "กลไกที่ถูกอ่าน"

<!-- ตาราง/วินัยนี้ mirror กับ kit/CLAUDE.template.md §เส้นแบ่ง (ฉบับแชร์ต่อ repo) —
     แก้ฝั่งเดียว = drift; แก้ต้องแก้คู่. ฝั่ง template ไม่มีป้ายนี้ (จงใจ — ไฟล์แชร์
     ต้องสะอาดจาก internal ref) → ไฟล์นี้คือฝั่งเดียวที่ถือหน้าที่เตือน -->

## ตารางตัดสิน (ไล่จากใกล้โค้ดสุด → ไกลสุด)

| ชั้น | ถูกอ่านเมื่อ | ใส่ได้เฉพาะ | เพดาน |
|---|---|---|---|
| **codetag** `TODO(scope):` | grep/ตารางสถานะ | เครื่องหมายงานค้าง (PEP 350) — ไม่ใช่คำอธิบาย | **ต้องตาย**ใน commit ที่ปิดงาน; แช่นาน = ย้ายขึ้น CLAUDE.md TODO |
| **inline comment** | ตาแตะบรรทัดนั้นตอนแก้ | constraint/why ที่ code, type, test หรือชื่อที่ดีแสดงเองไม่ได้ + guard ณ จุดแก้ | ไม่เขียนเป็นค่าเริ่มต้น; ถ้าจำเป็นให้สั้นพออ่านกับโค้ด; ใช้ pointer เมื่อ rationale กว้างกว่า local context |
| **docstring** | จะเรียกใช้/แก้ function-module นั้น | interface contract: ทำอะไร, param/return, invariant, side effect | สั้น ครบ contract |
| **docs/<topic>.md** | *รู้ตัว*ว่าทำเรื่องนั้น (pull) | เจาะลึกรายเรื่อง: design, runbook, ประวัติ, ผลทดลอง | ยาวได้ |
| **memory/<fact>.md** | ถูก surface *ก่อนรู้ว่าต้องหา* (recall) | fact เม็ดเดียว: quirk, กับดัก, preference, decision สั้น | 1 fact/ไฟล์ |
| **CLAUDE.md** | ทุก session (push — ทุกบรรทัดคือภาษี) | ภาพรวม + operational ที่ไม่เห็นแล้วงานพัง | section ≤~15 บรรทัด |

คำถามลัด: *ใครจะเจอสิ่งนี้ตอนไหน?* — งานค้าง→codetag · ตอนแก้บรรทัดถ้ามี why ที่จำเป็น→comment ·
ตอนเรียกใช้→docstring · ตอนทำเรื่องนั้น→docs · ต้องนึกออกเอง→memory · ทุก session→CLAUDE.md

## วินัย comment (มาตรฐาน: code = how, comment = why)

- เก็บเฉพาะ local constraint และเหตุผลที่จำเป็นต่อการแก้ code และ code, type, test หรือชื่อที่ดีแสดงเองไม่ได้
  ไว้ใกล้ code; ถ้า code อธิบายได้แล้วให้ไม่เขียน comment. ย้ายไป docs เมื่อเนื้อหาเป็น rationale, history,
  experiment หรือ procedure ที่มี scope กว้างกว่า local context—not merely because the comment spans a
  particular number of lines.
- **สร้างปลายทางก่อนเขียน pointer — ทั้งไฟล์และหัวข้อ** (`docs/x.md#heading` = heading
  นั้นต้องมีจริงแล้ว); pointer ผี = แย่กว่าไม่มี pointer (`/docs:link` ตรวจทั้งสองระดับ)
- pointer ที่ commit ต้อง resolve จาก clone ของ repo; ห้ามชี้ `~/.claude/` หรือ path เฉพาะเครื่อง
- ห้าม: เล่าว่าบรรทัดถัดไปทำอะไร · justify งานให้คนรีวิว · changelog ("เดิมเคยเป็น...") ·
  commented-out code (ลบ — git จำให้)

## วินัย docstring

- **ฝั่งเขียน**: public function/class/module + script entry ทุกตัวได้ docstring ระบุ contract
  (ทำอะไร, input/output, invariant, side effect) — ตามธรรมเนียมภาษานั้น (PEP 257, JSDoc, ฯลฯ);
  helper ภายในที่ชื่อเล่าเองได้ = ไม่ต้อง
- **ฝั่งอ่าน**: ก่อนเรียกใช้/แก้/ทำซ้ำ function ของเดิม — **อ่าน docstring ก่อน** ไม่ใช่เดาจากชื่อ
  (เชื่อชื่อมากกว่า contract = แผลที่เคยเกิดจริง); docstring ขัดกับพฤติกรรมจริง = บั๊กเอกสาร
  ต้องแก้ในงานเดียวกัน ไม่ใช่เมินผ่าน
- docstring คือบ้านของ interface-why; inline comment คือบ้านของ implementation-why —
  อย่าสลับ อย่ายุบรวม
- **docstring ก็บวมได้**: เกิน contract (tutorial ยาว, ประวัติ, justify ดีไซน์) = ผิดบ้าน
  เหมือน comment ยาว → docs/; usage ที่ argparse/help มีแล้ว อย่าเขียนซ้ำใน docstring (drift)

## เมื่อจะจดความรู้หลังปิดงาน (ใช้คู่ task-close checklist ของ docs-setup)

1. เกิด quirk/กับดัก/บทเรียน → **memory** (1 fact) — ไม่ใช่ comment ยาว ไม่ใช่ CLAUDE.md
2. เกิด decision + เหตุผล → CLAUDE.md ถ้า operational สั้น, docs/decisions ถ้ายาว
3. เกิดผลทดลอง/การวัด → docs/ (point-in-time ระบุวันที่); ตัวเลข reproduce ได้จาก
   script → ไม่จดเลย ชี้ไป source
4. เผลอเขียนเนื้อเดียวกันสองที่ → เลือกบ้านเดียวตามตาราง อีกที่เหลือ pointer
5. shared memory ที่ create/move/rename/delete → sync pointer + recall hook ใน
   `memory/MEMORY.md`; edit → ตรวจ hook และแก้เมื่อความหมาย/relevance เปลี่ยน

## ระดับ workspace (monorepo / git submodule)

- **เอกสารของ module อยู่ในตัว module** (`packages/<pkg>/docs/`, submodule มี docs ของตัวเอง) —
  root เก็บแค่ **pointer + short info (1-3 บรรทัด/module)**; เหตุผล: root CLAUDE.md = push
  ของทั้ง workspace, เนื้อราย module = pull; submodule ที่เอกสารไม่ติดตัว = เอกสารหาย
  เมื่อไปอยู่ super-repo อื่น (โบนัส: nested CLAUDE.md ใน subdir ถูกโหลด on-demand เอง)
- ของ **cross-cutting** (deploy ทั้ง workspace, contract ระหว่าง module) ยังอยู่ root —
  เส้นแบ่ง: "เรื่องของ module เดียว vs เรื่องระหว่าง module"
- ถ้าเป็น workspace ที่มีหลาย **independent Git repos** ไม่ใช่ monorepo/submodule ให้ใช้
  `/docs:workspace` เพื่อ map Git roots, กำหนด fact owner และตรวจ standalone-clone boundary
  ก่อนย้ายเอกสาร

## Docs topology

- ตั้งชื่อไฟล์ตามโดเมน/หน้าที่ ไม่ใช่ตามเวลาที่สร้าง
- เมื่อ `docs/` กองแบนเกิน ~7 ไฟล์ ให้เสนอ subfolder ตามโดเมนและย้ายเมื่ออยู่ใน scope;
  threshold เป็นสัญญาณจัดระเบียบ ไม่ใช่เหตุผลให้ cleanup นอกงาน
- index ใน CLAUDE.md ต้อง grouped, หนึ่งบรรทัดต่อไฟล์พร้อมชื่อ + hook ว่าทำไมต้องเปิด
  และตรงกับไฟล์จริง; เพิ่ม/ย้าย/ลบไฟล์ให้แก้ index ใน commit เดียวกัน

## โหมดจัดระเบียบ (remediation — เก็บหนี้ comment/docstring เดิม)

**Scope discipline ก่อนเริ่ม**: ทำเฉพาะไฟล์ที่ถูกสั่ง/ไฟล์ที่งานปัจจุบันแตะ — จะกวาดทั้ง repo
ต้องถูกสั่งชัด (ตาม calibrated-action: เกินสั่ง = เสนอ ไม่ใช่ลงมือ)

**เกณฑ์หลักตอนย้าย: "กฎ" อยู่ในโค้ด — "เรื่องเล่าว่าได้กฎมายังไง" ไป docs** (guard ที่คน
แก้จุดนั้นต้องเห็น เก็บไว้หนึ่งบรรทัด; บั๊กเก่า/ผลวัด/ประวัติเวอร์ชัน → docs + pointer —
ความรู้ไม่หายเพราะขาอ่านบังคับเปิดตาม pointer อยู่แล้ว ตาม rule §ในโค้ด)

**วัดก่อนด้วยตา deterministic**: `python <skill-dir>/scripts/scan.py <repo> [--max N]` —
นับ block เกินเกณฑ์ + จับ duplicate verbatim ข้ามไฟล์ (ตัวเลข reproducible ใช้เทียบ
ก่อน/หลังได้); ผลคือ *lead ให้ judge* ไม่ใช่รายการ auto-fix ([head] = docstring หัวไฟล์
มักเป็น contract ที่ถูกต้อง · triple-quoted data string ก็ติดมาด้วย)

### Comment audit mode (read-only ก่อน remediation)

ใช้เมื่อผู้ใช้ขอ audit/review comment หรือ docstring โดยยังไม่ได้ขอแก้. กำหนด scope เป็น diff,
directory หรือทั้ง repo ก่อน; repo-wide audit ที่ผลกว้างอาจแบ่งเป็น bounded batches แบบ read-only ได้
และผู้ขอต้องตรวจ primary evidence ก่อนสรุป.

```bash
python <skill-dir>/scripts/scan.py <repo> --diff HEAD --format json
python <skill-dir>/scripts/scan.py <repo> --max 2
```

Scanner ให้ candidate จาก block length, duplicate และ changed-line intersection เท่านั้น ไม่พิสูจน์ว่า
comment ผิด. Diff mode ตรวจทุก block ที่เปลี่ยนโดย default; full scan ใช้ threshold `>2` บรรทัด
เพื่อลด noise (`--max` override ได้). อ่าน code/test/requirement รอบจุดนั้นแล้วรายงาน
`file:line | severity | category |
evidence | recommendation` โดยใช้ category เท่าที่ตรงจริง: `KEEP`, `STALE`, `NARRATION`, `MOVE`,
`DUPLICATE`, `CODETAG`, `DOCSTRING`, `AUTHORITY-RISK`. ห้าม auto-fix จากความยาวหรือ category;
แก้เฉพาะเมื่อผู้ใช้อนุญาต remediation ต่อ.

ไล่ต่อไฟล์:
1. **comment ที่มี scope เกิน local code context** — จำแนกเนื้อทีละก้อน:
   - why/constraint จริง → บีบเหลือหนึ่งบรรทัด + pointer
   - รายละเอียด/ประวัติ/ผลทดลอง → ย้ายเข้า `docs/<topic>.md` (สร้างไฟล์ก่อนเขียน pointer)
   - **comment เดียวกัน copy verbatim หลายไฟล์** → doc เดียว + pointer ทุกจุด (หนี้ถูกสุด
     ได้เยอะสุด — เริ่มจากตรงนี้)
   - **เนื้อที่แท้จริงคืองานค้าง → แปลงเป็น `TODO(scope):`** — เฉพาะที่เป็นงานจริงเท่านั้น
     ห้ามหว่าน codetag ระหว่าง cleanup (codetag ไร้เจ้าของ = แช่จนโกหกตารางสถานะ)
   - เล่า how ซ้ำโค้ด / changelog / commented-out code → ลบ
2. **docstring ที่ขาด** — เติมเฉพาะตามเกณฑ์ฝั่งเขียนข้างบน (public/contract ไม่ชัดจากชื่อ);
   ห้าม blanket ทุก function — จะกลายเป็น noise รูปแบบใหม่
3. **ปิดท้ายด้วย `/docs:link` เสมอ** — การย้ายคือโอกาส pointer พังสูงสุด; แก้จนสะอาด
4. commit การย้ายเอกสาร**พร้อมงาน** ระบุใน message ว่าย้ายอะไรไปไหน

อิงหลักสากล: Clean Code / Ousterhout (comment=why) · PEP 257/JSDoc (docstring=contract) ·
ADR (decision) · Diátaxis + SSOT (แยกเอกสารตามหน้าที่การอ่าน) — หลักการเต็ม:
`~/.claude/rules/engineering/documentation-discipline.md`
