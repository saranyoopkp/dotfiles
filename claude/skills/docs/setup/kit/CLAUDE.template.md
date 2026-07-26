<!-- 🔴 STANDARD บังคับ: CLAUDE.md ห้ามถือ "fact ที่นับ/ลิสต์เองได้" เป็นค่า hardcode —
     จำนวนไฟล์/บรรทัด/table/migration, รายชื่อไฟล์, shape ของ schema/DTO
     = ชี้คำสั่ง (`ls`, `wc -l`, `grep -c`) หรือชี้ source file แทนการพิมพ์เลข/ชื่อลงไป
     เหตุผล: fact ที่ copy มาแปะ = fact ที่จะ stale แล้วถูกเชื่อ (CLAUDE.md โหลดทุก session
     = ดูเป็นความจริงแต่ไม่มีใคร re-verify) เช่น เขียน "12 tables" ไว้ แล้วเพิ่ม table ที่ 13
     โดยลืมแก้ → doc โกหกเงียบ ๆ. ถ้าจำเป็นต้องมีเลข → เขียนคำสั่งที่คำนวณมันกำกับข้าง ๆ -->

# <ProjectName> (<domain/one-liner>)

> สถานะ: **<LIVE / WIP / phase>** — <deploy target / สภาพปัจจุบันแบบย่อ>
> <status ที่เป็น point-in-time จริง เช่น image tag/phase — **ไม่ใช่** จำนวนที่นับเองได้ (ดู STANDARD บน)>
> **<quirk/การแก้ล่าสุดที่ต้องรู้ก่อนทำงาน — ใส่วันที่ + เหตุผล + วิธีแก้ เช่น:
> "⚡ Edge cache (แก้ 2026-07-01): เดิม X เพราะ Y → แก้ด้วย Z. ยืนยัน: ...">**

## Inventory / Modules
<!-- สถานะปัจจุบันต่อ module: 1–3 บรรทัด/ตัว ถ้าโตกว่านั้น → แยกไป docs/<module>.md แล้วเหลือ pointer -->
- **<module>** — <สรุป + ไฟล์หลัก + quirk สั้น ๆ>

## Deploy / Redeploy
<!-- คำสั่ง copy-paste ได้จริง เรียงเป็นขั้น + เงื่อนไข "ถ้า X เปลี่ยน ทำแค่ Y" -->
1. `<command>`
2. `<command>`

<!-- สามข้อล่างนี้เป็น *คุณสมบัติของระบบ* (เปลี่ยนนาน ๆ ครั้ง) ไม่ใช่ของ release รอบนี้ —
     ห้ามกรอกชื่อ migration/ticket ของรอบปัจจุบัน (นั่นคือหน้าที่ของ PR/commit ไม่ใช่ที่นี่)
     repo ที่ไม่ได้ deploy (library/CLI) → ลบ section นี้ทิ้งทั้งก้อน -->
- **pipeline ไม่ทำให้เอง**: <ของที่ต้องทำมือทุกครั้งที่มีของใหม่ เช่น migration ไม่ auto-run,
  table ใหม่ต้อง grant เอง, env ใหม่ต้องไปตั้งที่ <ที่ไหน> — หรือ "pipeline ทำครบ ไม่มีของทำมือ">
- **Rollback**: <ย้อนยังไง (tag/image เดิม) + อะไรที่ย้อนไม่ได้ (data migration ฯลฯ)>
- **Verify หลัง deploy**: <flow จริงที่ต้องยิงหนึ่งรอบถึงเรียกว่าขึ้นสำเร็จ — rollout เขียว ≠ ระบบทำงาน>

### Compatibility (N / N-1 compatibility) — ระบบที่รันอยู่ มีของเก่ากับของใหม่อยู่ด้วยกันเสมอชั่วขณะ (ต้องเช็คทุกการเปลี่ยนแปลง)
<!-- checklist นี้ใช้ได้ทุก repo — เก็บไว้แม้ยังไม่มีอะไรกรอก; เพิ่มข้อเฉพาะของระบบนี้ต่อท้ายได้ -->
**ของใหม่ต้องทำงานกับของเก่าได้ และของเก่าต้องไม่พังเพราะของใหม่** (backward + forward compatible)
→ ทำได้ = **ลำดับการปล่อยไม่สำคัญ** ใครขึ้นก่อน/ทีหลัง/ย้อนกลับ ก็ยังทำงาน
"ของเก่ากับของใหม่" = อะไรก็ตามที่ถูกเปลี่ยนคนละเวลา ไม่ใช่แค่ตอน deploy: โค้ด↔schema ·
server ใหม่↔tab/mobile app ที่ยังไม่รีเฟรช · producer ใหม่↔message เก่าที่ค้างในคิว↔consumer ที่ยังไม่ขึ้น
(instance เก่า-ใหม่รันคู่กันระหว่าง rolling deploy อยู่แล้วโดยธรรมชาติ)

- **ลบ / rename / เปลี่ยนความหมาย / บังคับ required = แบ่ง 2 รอบเสมอ** (expand → contract)
  (รอบ 1 `expand`: เพิ่มของใหม่ + เขียนทั้งเก่าใหม่ + อ่านจากใหม่ · รอบ 2 `contract`: ลบของเก่าเมื่อไม่มีใครใช้แล้ว)
  — เพิ่มของใหม่อย่างเดียว = ปลอดภัย ทำรอบเดียวได้
- **โค้ดใหม่พึ่งอะไรที่ยังไม่ถูกสร้าง?** (migration, grant/สิทธิ์, env, ไฟล์, table, event type)
  → นั่นคือ dependency ไม่ใช่ "แค่ยังไม่ได้ทำ" — ไม่ครบ = ยังไม่ deploy
- **rollback = ย้อนโค้ดอย่างเดียวพอไหม?** ถ้าต้องย้อน state ด้วย = การเปลี่ยนแปลงนี้ไม่ปลอดภัย ออกแบบใหม่
- **precondition ไม่ครบ ต้อง fail loud ไม่ใช่ข้ามเงียบ** — พังเงียบบน production แย่กว่าหยุด deploy เสมอ
- **สร้างของใหม่แล้วทดสอบ "การใช้งานจริง" ของมัน** — สร้างสำเร็จ ≠ ใช้งานได้ (เช่น สร้าง role แล้ว
  ต้องลองเขียนจริงด้วย ไม่ใช่แค่เช็คว่ามี)
- feature flag/dual-read/dual-write ต้องมี owner, default, telemetry และเงื่อนไข rollback/ลบ;
  ใช้แทน compatibility ของ state/contract ไม่ได้

## Research escalation — เริ่มที่ repo แต่ห้ามจมอยู่ใน repo

- ก่อนสรุปหรือสร้าง workaround จากพฤติกรรมของ platform/framework/runtime/browser/OS/protocol/third-party dependency ให้แยกว่าเป็น `repo-specific` หรือ `external constraint`
- อ่าน code/config/runtime เพื่อรู้ integration และ version ก่อน; หากข้อสรุปขึ้นกับข้อจำกัดภายนอก ขัดกับมาตรฐานที่คาดไว้ หรือ workaround มีนัยสำคัญ ให้ค้น official documentation/specification/release note ที่ตรง version/context ก่อนตัดสินใจ
- source ภายนอกพิสูจน์ข้อจำกัดทั่วไปเท่านั้น; ต้องใช้ code/config/runtime ยืนยันแยกว่ากระทบ repo นี้อย่างไร
- หา source ไม่ได้หรือหลักฐานขัดกัน = ระบุสิ่งที่ยังไม่ยืนยันและทางเลือก; ห้ามเดาข้อจำกัดเพื่อปิดงาน
- research ที่มีผลต่อ decision ต้องกำหนด question, context/version/segment, source hierarchy,
  freshness, appetite และ stopping criteria; ถึงขอบเขตแล้วยังไม่พอให้รายงาน unknown/next probe
- advisory/CVE ต้อง map exact component/version/config/reachability; dependency/vendor ต้องตรวจ
  maintenance, security, license, compatibility, total cost, lock-in/exit; user/market claim ต้องมี
  provenance + segment + methodology — persona, anecdote หรือ model opinion ไม่ใช่ user evidence
- research/recommendation ไม่ใช่ approval ให้เปลี่ยน behavior, เพิ่ม dependency, เลือก vendor,
  upgrade, ติดต่อผู้ใช้ หรือเก็บข้อมูลใหม่

## Complexity proposal

- ก่อนเพิ่ม abstraction/dependency/infra/operational burden ให้หา driver จาก repo/runtime/source.
  ถ้าทาง minimum ตอบ outcome/correctness/safety/compatibility ครบ ให้เสนอพร้อม defer trigger;
  driver ยังไม่ชัดให้ถามเฉพาะเมื่อเปลี่ยน behavior/risk/cost หรือย้อนกลับแพง นอกนั้นเลือกทางขั้นต่ำ
  ที่ปลอดภัยพร้อม assumption. ห้ามตัด safety/compatibility ที่มี risk รองรับเพื่อให้ดูเรียบง่าย

## Local dev
<!-- คำสั่งรัน dev + quirks ของเครื่อง/toolchain ที่เคยเจ็บมาแล้ว (ระบุ symptom + fix) -->

## Structure & Run
<!-- โครง workspace, source of truth ของ schema/config, คำสั่งพื้นฐาน -->

## Conventions
<!-- ภาษา (เว็บ=EN, internal=TH ได้), naming, กติกาที่ตกลงแล้ว -->

## Mission / Boundary
<!-- ทำอะไร ไม่ทำอะไร ทำไม — กัน scope creep + กัน re-litigate -->

## Architecture Decisions (ตัดสินใจแล้ว)
<!-- ทุกข้อมีเหตุผล: "เลือก X (ไม่ใช่ Y) เพราะ ..." รวม "ทำไมไม่" ของทางที่ไม่เลือก
     รูปแบบ: **<หัวข้อสั้น> (YYYY-MM-DD)**: เลือก X เพราะ Y (ไม่ใช่ Z เพราะ W)
     section นี้คือสถานะปัจจุบัน ไม่ใช่ changelog — decision ที่ถูกแทนที่ ให้แก้ entry เดิม
     (ไม่ลบ) แล้วมาร์ค "superseded by <decision ใหม่, วันที่>"; โตเกิน ~15 บรรทัด/decision
     → แยกไป docs/decisions/<topic>.md เหลือสรุป+ลิงก์ -->

## Constraints
<!-- งบ / infra / เวลา — สิ่งที่กำหนดว่าอะไรทำได้-ไม่ได้ -->

## ข้อควรระวัง
<!-- กับดักเชิงกลยุทธ์/เทคนิคที่รู้แล้ว -->

## Future boundaries (จดเผื่อ ยังไม่ commit)
<!-- ไอเดียที่ "ยังไม่ตัดสินใจ" — จดกัน design ปัจจุบัน block อนาคต -->

## Execution tracking
<!-- เมื่อ harness มี Task tools: งานที่มีหลายขั้น, ข้ามหลาย turn, มี verification/handoff หรือ blocker/decision
     ต้องสร้าง task list ก่อน mutation และ update ตามหลักฐาน (in-progress / blocked / completed). งานตอบคำถาม,
     read-only inspection หรือแก้จุดเดียวจบใน turn เดียวไม่ต้องสร้าง checklist เพื่อพิธีกรรม. ไม่มี tool ให้สรุป
     แผน/สถานะแบบกระชับในคำตอบแทน; ห้ามอ้างว่าติดตามผ่าน tool ที่ไม่มี -->

## Report integrity
<!-- ก่อนรายงานผล/finding/handoff ให้แยก claim สำคัญเป็น Verified/Inferred/Assumption/Unverified/
     Contradicted. Verified ต้องมาจาก primary evidence ปัจจุบันที่ผู้รายงานตรวจโดยตรง พร้อม target,
     probe/result และ coverage; command/test claim ต้องมีวิธีตรวจและ exit status เมื่อมี. ห้ามรายงาน
     ผลค้าง คำบอกต่อ หรือการตรวจตัวอย่างเหมือนเป็นหลักฐานปัจจุบันของทั้งชุด -->

## Durable findings
<!-- report/summary/transcript/finding เดิมเป็น lead ไม่ใช่ fact. ก่อนเขียน finding ลง debt, audit, TODO,
     decision, runbook, postmortem หรือเอกสารถาวร ให้ตรวจ primary evidence ปัจจุบันโดยตรงครบทุก atomic
     finding ที่จะเขียน; การยืนยันบางข้อไม่รับรองทั้งชุด. บันทึก status (Verified/Unverified/Contradicted),
     provenance (target + probe/evidence), checked date และ revision/worktree เมื่อ state อาจต่างกัน.
     ก่อนใช้ finding ตัดสินใจหลัง state เปลี่ยน ให้ตรวจส่วนที่อาจ stale ซ้ำ -->

## TODO ถัดไป
- [ ] <งานถัดไปแบบ actionable>

## เอกสารเพิ่มเติม
<!-- index ให้มองเห็นทุกชั้นจากไฟล์เดียว — ต้อง sync กับไฟล์จริงเสมอ (เพิ่ม/ย้าย/ลบ = อัปเดตที่นี่ใน commit เดียวกัน)
     ชื่อไฟล์ = โดเมนไม่ใช่เวลา; docs/ เกิน ~7 ไฟล์ → จัด subfolder ตามโดเมนแล้ว group index ตามนั้น -->
- `docs/<topic>.md` — <หนึ่งบรรทัดว่ามีอะไร + ทำไมต้องเปิด>
- `memory/MEMORY.md` — index ของ fact สั้น ๆ ทั้งหมด

## เส้นแบ่ง CLAUDE.md / docs/ / memory/ (มาตรฐาน — ใช้ตัดสินก่อนจดทุกครั้ง)

เส้นแบ่งคือ**กลไกที่มันถูกอ่าน** ไม่ใช่หัวข้อของเนื้อหา:

| ชั้น | ถูกอ่านแบบ | หน่วย | เขียนเมื่อตอบ "ใช่" กับคำถามนี้ |
|---|---|---|---|
| `CLAUDE.md` | **push** — โหลดเต็มทุก session (ทุกบรรทัด = ภาษีทุก session) | ภาพรวม + operational | "ถ้าไม่เห็นทุก session จะทำงานผิดไหม" |
| `docs/<topic>.md` | **pull** — เปิดเมื่อ*รู้ตัว*ว่าทำเรื่องนั้น | เรื่องละไฟล์ ยาวได้ | "จะถูกเปิดอ่านเมื่อลงมือทำเรื่องนั้นไหม" |
| `memory/MEMORY.md` | **recall router** — auto-load ทุก session | pointer + hook ของ shared fact | "session หน้าต้องรู้ว่ามี fact นี้ไหม" |
| `memory/<fact>.md` | **selective pull** — harness ไม่เปิดตาม pointer เอง | fact เม็ดเดียว/ไฟล์ สั้น | "index/task ชี้แล้วควรเปิดรายละเอียดไหม" |

- **shared memory index lifecycle:** create/move/rename/delete `memory/<fact>.md` ต้อง
  เพิ่ม/แก้/ลบ pointer + recall hook ใน `memory/MEMORY.md` commit เดียวกัน; edit leaf ให้
  ตรวจว่า hook ยังตรงและแก้เฉพาะเมื่อความหมาย/relevance เปลี่ยน. `MEMORY.md` เก็บ index
  เท่านั้น ห้ามคัดเนื้อ fact มาใส่
- เนื้อเรื่องเดียวกันแยกสองบ้านได้ตาม*หน้าที่*: ประวัติ/เหตุผลเต็ม → docs/, fact ที่ต้องนึกออกเอง
  (quirk, preference, กับดัก) → memory/, CLAUDE.md เหลือ 1-3 บรรทัด + pointer
- ตัวเลข/ข้อมูลที่ reproduce ได้จาก script/คำสั่ง → ไม่จดที่ไหนเลย ชี้ไป source
- **monorepo/submodule**: เอกสารของ module อยู่ในตัว module — root เก็บ pointer +
  short info (1-3 บรรทัด/module); เฉพาะเรื่อง cross-cutting (deploy รวม, contract
  ระหว่าง module) อยู่ root

**สองชั้นในโค้ด (อยู่ใต้ตารางเดียวกัน — ถูกอ่านใกล้โค้ดที่สุด):**
- **inline comment** = ถูกอ่านตอน*แก้บรรทัดนั้น* → ใส่ได้เฉพาะ why/constraint ที่โค้ดแสดง
  เองไม่ได้; comment ตั้งแต่ **2 บรรทัดขึ้นไป** ต้องสร้าง `docs/` ปลายทางก่อน ย้ายรายละเอียดไป แล้วเหลือหนึ่งบรรทัด + pointer — รายละเอียด/ประวัติ/ผลทดลอง inline = ผิดบ้าน;
  pointer ที่ commit ต้อง resolve จาก clone ของ repo ห้ามชี้ `~/.claude/` หรือ path เฉพาะเครื่อง;
  ห้าม commented-out code (git จำให้) และห้ามเล่าว่าบรรทัดถัดไปทำอะไร;
  **ขาอ่าน: เจอ comment ที่มี pointer ตอนแก้จุดนั้น = เปิด doc ตามก่อนแก้** ไม่ใช่ข้าม
- **docstring** = ถูกอ่านตอน*จะเรียกใช้/แก้* function-module นั้น → interface contract
  (ทำอะไร, input/output, invariant, side effect) ตามธรรมเนียมภาษา (PEP 257, JSDoc);
  public interface ต้องมี — และ**ขาอ่านสำคัญเท่าขาเขียน**: ก่อนใช้/แก้ของเดิม อ่าน docstring
  ก่อน ไม่เดาจากชื่อ; contract ขัดพฤติกรรมจริง = บั๊กที่ต้องแก้ในงานเดียวกัน;
  **เปิดด้วย contract ถูกต้องแล้วต่อด้วยเรียงความ/postmortem/changelog = ผิดบ้าน** →
  เนื้อนั้นไป docs/ (docstring บวมคือ comment ยาวที่ใส่เสื้อ JSDoc)
- **codetag** (`TODO(scope):` — PEP 350) = เครื่องหมายงานค้าง ไม่ใช่คำอธิบายโค้ด —
  **จุดต่างสำคัญคืออายุ**: comment/docstring อยู่ตราบที่โค้ดอยู่ แต่ codetag *ต้องตาย*
  (ลบใน commit เดียวกับงานที่ปิดมัน — ค้าง = โกหกตารางสถานะ; แช่นาน = หนี้ระดับ feature
  ต้องย้ายขึ้น TODO ของ CLAUDE.md ไม่ใช่ฝังในโค้ด)

(อิงหลักสากล: Clean Code/Ousterhout — comment=why · PEP 257/JSDoc — docstring=contract ·
ADR สำหรับ decision · Diátaxis + SSOT สำหรับแยกเอกสารตามหน้าที่การอ่าน)

## Memory policy (สำหรับ Claude — อ่านทุก session)

**`memory/` ของ tree ที่ session เปิดอยู่ คือ memory ตัวจริง** — ฝั่ง harness
(`~/.claude/projects/<project-id>/memory`) เป็น **link** ชี้มาที่นี่ (junction บน Windows /
symlink บน unix) เขียน/อ่าน memory ตามปกติได้เลย ไฟล์ลง repo อัตโนมัติ
**`docs-drift.sh` (SessionStart) สร้าง link ให้เองเมื่อยังไม่มี** — รวมถึงใน git worktree
ซึ่ง link จะชี้ `memory/` ของ **worktree เอง** (ไม่ใช่ของ tree หลัก) เพื่อให้ fact ที่เขียน
ระหว่างงานนั้น commit ไปกับ branch เดียวกับงานได้ ⇒ **ไม่ต้องรัน script อะไรก่อน**:

- memory ใหม่ที่บันทึก = untracked file ใน repo → คัดกรองแล้ว commit พร้อมงาน:
  **ลบ metadata ส่วนบุคคล** (`originSessionId` ฯลฯ) ออกจาก frontmatter และเช็คว่าไม่มี secret
- **private/sensitive ห้ามลงไฟล์ที่ track ด้วย git** — ใช้ `docs/private/` และ
  `memory/private/` ของ repo นั้น ๆ (relative จาก Git root): โน้ต ops sensitive
  (secret/IP/server path) → `docs/private/`; fact ส่วนตัว/เฉพาะเครื่อง → `memory/private/`
  (gitignored ทั้งคู่,
  ห้าม index ลง `memory/MEMORY.md` ที่ commit). ไม่พบใน index ไม่ได้แปลว่าไม่มี private
  memory; ถ้างานอาจพึ่งข้อมูลเฉพาะเครื่อง ให้ตรวจ `memory/private/` ก่อนสรุปหรือถาม
- **hook เตือนเมื่อไหร่ = ตอนที่มันสร้าง link ให้เองไม่ได้** (ไม่เตือน = เรียบร้อยแล้ว) —
  เจอข้อความ `[docs] Harness memory ...` ให้แก้ก่อนทำงาน ไม่งั้น fact ที่เขียน session นี้
  ไม่ถึง repo เลย:
  - **มี dir เดิมที่ไม่ใช่ link** (มี fact ค้างอยู่ข้างใน) → **ห้ามลบ** merge ไฟล์เข้า
    `memory/` ของ repo ก่อน แล้ว rename ของเดิมเป็น `.bak` ค่อยสร้าง link
  - สร้าง link เอง: unix `ln -s <tree>/memory ~/.claude/projects/<id>/memory` ·
    Windows `New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\projects\<id>\memory" -Target "<tree>\memory"`
  - `<id>` = absolute path ของ **tree ที่เปิด session อยู่** (worktree ก็ path ของ worktree)
    โดยแทนอักขระที่ไม่ใช่ a-z/0-9 ด้วย `-`
- fact ที่ผิด/หมดอายุ → ลบไฟล์ + ลบบรรทัดใน `memory/MEMORY.md`

**Task-close checklist (ทำทุกครั้งที่ปิดงานหนึ่งชิ้น ไม่ต้องรอจบ session):**
1. CLAUDE.md/docs ยังตรงกับความจริงหลังงานนี้ไหม — ถ้าไม่ อัปเดตทันที:
   feature ใหม่ = +1–3 บรรทัดใน Inventory (มีอะไร/ไฟล์หลัก/quirk) + decision พร้อมเหตุผลถ้ามี
   — จดเฉพาะสิ่งที่**โค้ดเล่าเองไม่ได้** (ทำไม/ข้อจำกัด/กับดัก) ห้ามเล่า implementation ซ้ำ
2. มี memory ใหม่ควรบันทึก/คัดกรองไหม (ลบ metadata ส่วนบุคคล, ไม่มี secret);
   ถ้า shared leaf เปลี่ยน lifecycle ให้ sync `memory/MEMORY.md` และตรวจ pointer/hook
3. commit เอกสารไป**พร้อมกับงาน** (commit เดียวกัน) — รวมถึงลบ `TODO(scope)` ในโค้ด
   ที่งานนี้ปิดแล้ว (TODO ที่จบแล้วแต่ยังอยู่ = โกหกตาราง)
4. **section ไหนใน CLAUDE.md โตเกิน ~15 บรรทัด → promote ทันที**: ย้ายเนื้อไป
   `docs/<topic>.md` (หรือ `memory/<fact>.md` ถ้าเป็น fact สั้น) แล้วเหลือสรุป 1–3 บรรทัด
   + ลิงก์ — ห้ามปล่อยให้ CLAUDE.md เป็นที่กองเนื้อหา (มันถูกโหลดเต็มทุก session)
_(มี lifecycle hooks ใน `.claude/settings.json` คอยเตือนที่ SessionStart / TaskCompleted /
Stop / PreCompact อยู่แล้ว — เจอข้อความ `[docs]` = ทำตามนั้นก่อนไปต่อ)_
