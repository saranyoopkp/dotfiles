---
name: docs:link
description: ตรวจ broken reference และ anchor ทั้ง repo — md↔md links, path ที่อ้างในเอกสาร (`docs/x.md`, `src/y.py`), pointer ใน comment ของโค้ดที่ชี้เข้า docs/memory, และ [[wiki-link]] ของ memory ใช้เมื่อย้าย/rename/ลบไฟล์, refactor เอกสาร, ก่อน commit งานที่แตะโครงไฟล์ หรือถูกขอให้ตรวจว่า reference ชี้ถึงไฟล์จริง; ไม่ตรวจว่าเนื้อหาเอกสารยังตรงกับโค้ด
---

# Link Check — reference ต้องไม่ตาย

pointer คือกระดูกสันหลังของมาตรฐานเอกสาร (comment→docs, CLAUDE.md→docs, MEMORY.md→fact)
— pointer พัง = ความรู้หายเงียบ ๆ แย่กว่าไม่มี pointer

## วิธีใช้ (deterministic ก่อน — ห้าม LLM ไล่กวาดเอง)

```bash
python <skill-dir>/scripts/check.py [repo_root]   # default = git root ปัจจุบัน
```
ตรวจ 4 ชั้น: `[x](path.md)` ใน md · path ใน backtick ของ md (ข้าม code fence/placeholder) ·
pointer `docs/... .md` ใน comment ของโค้ด · `[[wiki-link]]` เทียบชื่อไฟล์ใน memory/ ·
**anchor**: `[x](file.md#heading)` → heading ต้องมีจริงในไฟล์ปลายทาง — ไม่มี = `bad-anchor` BROKEN

วิธีเขียน anchor (GitHub slug จาก heading): ตัวพิมพ์เล็กทั้งหมด · space → `-` (ตัวต่อตัว
ไม่ยุบ — `A / B` ได้ `a--b`) · ตัด ASCII punctuation (`.` `/` `(` `)` ฯลฯ — ยกเว้น `_`
คงไว้ตาม GitHub: `run_check` → `#run_check`) · ไทย/unicode
คงไว้ทั้งวรรณยุกต์ · heading ซ้ำตัวที่ 2 ได้ `-1` — เช่น
`## เส้นแบ่ง CLAUDE.md / docs/` → `#เส้นแบ่ง-claudemd--docs` (เดาไม่แน่ใจ = รัน script เช็คเลย)
Resolve อัตโนมัติ: relative จากไฟล์ · จาก repo root · unique-suffix shorthand
(`hooks/useX.ts` เจอไฟล์เดียว = ผ่าน, หลายไฟล์ = broken ต้องเขียนเต็ม) ·
path ที่ .gitignore ครอบ (docs/private ฯลฯ) = ไม่นับพัง แต่แยกระดับด้วย git blame: บรรทัดที่*คุณ*เขียนเอง → `[WARN] private-yours` (ของตัวเองไม่อยู่เครื่องนี้ = อาจหาย/ยังไม่ sync) · ของคนอื่น → `[INFO] private-local` (แยกได้แค่ของใคร ไม่รู้เครื่องไหน — email เดียวข้ามเครื่อง) ·
**pointer ชี้ home dir** (`~/.claude`, `$HOME`, `C:/Users`, `/home/`, `/Users/`) →
`[WARN] home-path` เสมอ — path ส่วนตัวห้ามลง repo (เครื่องอื่น/CI ไม่มี) แทนด้วยสาระ
1 บรรทัดหรือชี้ docs ใน repo; repo ที่อ้างได้ถูกต้อง (เช่น dotfiles เอง) = `.linkcheck-ignore` ·
ขึ้นต้น `/` = URL route ข้าม; ไฟล์ไหน shorthand เยอะ → ประกาศ
`<!-- linkcheck-base: path/base -->` ในไฟล์นั้นได้; doc ที่อ้างไฟล์บน branch ที่ยัง
ไม่ merge → `<!-- linkcheck-branch: feature/x -->` = รายงาน `[INFO] on-branch` ไม่นับพัง
(merge แล้ว decl หมดหน้าที่ — ลบทิ้ง)
— exit 1 เมื่อพบ BROKEN; `[INFO] wiki-pending` = wiki-link ที่ยังไม่มีไฟล์ (อนุญาตตาม
กติกา memory — เป็น marker ของที่ควรเขียน ไม่ใช่ความผิด)

## จังหวะที่ต้องรัน

- หลัง**ย้าย/rename/ลบ**ไฟล์ .md หรือไฟล์ที่ถูกเอกสารอ้าง — ทุกครั้ง ไม่มีข้อยกเว้น
- หลัง**แก้/rename heading** ในไฟล์ที่ถูกอ้างบ่อย (CLAUDE.md, docs หลัก) — anchor ตายเงียบ
  จากการแก้หัวข้อ ไม่ใช่แค่ย้ายไฟล์
- จบงาน docs-refactor / `/docs:setup` re-apply
- ก่อน commit ที่แตะ CLAUDE.md/docs/memory หลายไฟล์

## เมื่อเจอ BROKEN — ลำดับการแก้

1. **target ถูกย้าย** → แก้ pointer ให้ชี้ที่ใหม่ (ตรวจว่าเนื้อยังตรงกับที่ผู้อ้างคาดหวัง)
2. **target ถูกลบโดยตั้งใจ** → ลบ/แก้ประโยคฝั่งผู้อ้างด้วย — ห้ามลบแค่ลิงก์ทิ้งไว้เป็นข้อความกำพร้า
3. **target ไม่เคยมี (pointer เขียนล่วงหน้า)** → สร้างไฟล์ปลายทางทันที หรือถอน pointer —
   กติกา doc-placement: "สร้างไฟล์ปลายทางก่อนเขียน pointer"
4. แก้แล้ว**รัน script ซ้ำจนสะอาด** — การแก้ลิงก์ชอบพังลิงก์ข้างเคียง

## ข้อจำกัดที่ต้องรู้ (กัน false trust)

- script เช็ค*การมีอยู่ของไฟล์* ไม่เช็ค*ความ stale ของเนื้อหา* (ไฟล์อยู่แต่เนื้อล้าสมัย =
  ตรวจไม่เจอ) — ชั้นเนื้อหาเป็นหน้าที่ของ docs-drift hook + task-close checklist
- anchor verify ครอบเฉพาะ md-link (`file.md#h`) — "§ชื่อ" ใน prose/backtick ยังไม่เช็ค
  (fuzzy เกินกว่าจะ deterministic โดยไม่สร้าง FP)
- path ที่ประกอบขึ้น runtime (variable/f-string) มองไม่เห็น — อย่าอ้าง "clean" เกินขอบเขตนี้
