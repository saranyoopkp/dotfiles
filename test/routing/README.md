# test/routing — skill auto-invocation regression

domain rule ที่ลึก (`ui-ux-baseline`, `data-design`, `risk-review`, ...) ทำเป็น **skill** (on-demand):
description บาง ๆ always-loaded เป็น routing signal, body โหลด**ครั้งเดียวตอน invoke**
(ไม่มี pointer, ไม่โหลดทุก turn แบบ path-scoped). ความเสี่ยงคือ **โมเดลไม่ auto-invoke เมื่อควร**
หรือ **invoke ตอนไม่เกี่ยว** suite นี้ยิงงานหลาย domain พร้อม simple-task negative-routing cases ผ่าน fresh `claude -p` แล้วเช็คว่า
skill *หลัก* fire (miss=FAIL), NONE ไม่ fire อะไร. **related skill co-fire เพิ่มได้** —
webhook↔data-design เนื้อทับกัน (queue/retry) → co-fire แบบ non-deterministic เป็นเรื่องปกติ
ไม่นับ over-invoke. รายการ on-demand skills derive จาก frontmatter registry โดยอัตโนมัติ และ parser
ใช้ exact skill name หลัง normalize `:` เป็น `-` จึงไม่ถือว่า parent ถูก invoke เพียงเพราะชื่อเป็น prefix
ของ child

## รัน
```
bash test/routing/run.sh
```
- แต่ละ scenario = fresh session (โหลด rules/skills สด — subagent ทำแทนไม่ได้ สืบทอด context ค้าง)
- default รันพร้อมกันสูงสุด 4 session เพื่อลด CLI startup race; ปรับด้วย
  `ROUTING_MAX_PARALLEL` และเลือกไฟล์ด้วย `ROUTING_SCENARIO_FILES` (คั่นด้วย `:`)
- รันใน sandbox นอก repo เพื่อไม่ให้ `dotfiles/CLAUDE.md` ปนเปื้อน
  (ตั้งผ่าน `ROUTING_SANDBOX` หรือ `.local.sh`; environment ที่ระบุขณะรันมี precedence)
- **กิน API tokens** — รันหลังแก้ skill description/scenarios ไม่ใช่ทุก commit
- verdict อ่าน `Skill` tool use จาก raw stream-json และต้องมี CLI exit status `0`;
  startup failure/timeout เป็น FAIL ของ harness แยกจากการสรุป routing
- ตรวจ registry โดยไม่ยิง model ได้ด้วย `ROUTING_LIST_SKILLS=1 bash test/routing/run.sh`;
  คำสั่งจะ fail หาก frontmatter ขาด/กำกวม/ชื่อซ้ำ และ normalize CRLF ก่อนเทียบชื่อ

## ตรวจ child routes แบบ targeted

default suite ตรวจ surface-level routing และ negative cases. child routes ทั้ง registry มี scenario
แยกไว้ที่ `scenarios-routing-children.tsv` เพื่อรันเมื่อแก้ parent router, child description หรือ
routing harness:

```
ROUTING_SCENARIO_FILES=test/routing/scenarios-routing-children.tsv ROUTING_MAX_PARALLEL=4 bash test/routing/run.sh
```

ไม่บังคับ cross-domain co-fire เป็น success criterion เพราะ edge เหล่านั้นเป็น related routing
ที่อาจโหลดร่วมกันแบบ non-deterministic; ให้ตรวจโครงสร้างด้วย graph validator และใช้ scenario
ที่มีหลักฐานของ surface/decision จริงแทน

regression ของ silent miss และ registry parser อยู่ใน `scenarios-routing-defects.tsv` และรันแยกได้ด้วย:

```
ROUTING_SCENARIO_FILES=test/routing/scenarios-routing-defects.tsv ROUTING_MAX_PARALLEL=1 bash test/routing/run.sh
```

## เพิ่มเคส

รูปแบบใหม่: `require<TAB>forbid<TAB>label<TAB>task`

- `require`/`forbid` ใส่ชื่อ skill คั่นด้วย space; `-` = ไม่กำหนด
- ใช้ `forbid` ทดสอบ over-trigger โดยยังอนุญาตให้ skill อื่น fire
- รูปแบบเดิม `expect<TAB>label<TAB>task` ยังรองรับ; `NONE` = ห้ามทุก on-demand skill

## artifacts / trace back
แต่ละ run เซฟ **raw stream-json + stderr ต่อ scenario** ลง
`$ROUTING_SANDBOX/runs/<timestamp>/<label>.{stream.jsonl,stderr.log,exit}` + `summary.txt` —
เปิดดู `tool_use`/CLI failure ของเคสนั้นได้ (เคส FAIL → summary ชี้ไฟล์ให้)
(harness เองก็เซฟ session ที่ `~/.claude/projects/<cwd-hash>/<session-id>.jsonl` แต่ไม่ label
scenario + กองรวมกัน — ใช้ artifact ที่ label แล้วใน runs/ แทน). playground อยู่นอก repo =
ไม่ track; ลบ `runs/` เก่าทิ้งได้

## baseline (2026-07-16)
skill `ui-ux-baseline` validated: fresh frontend→invoke · backend→NONE · long-session
(turn 6)→ยัง invoke (จุดที่ pointer hack เดิมตาย). recognition นิ่งใน n ที่ทดสอบ (เก็บเพิ่มระหว่างใช้จริง)
