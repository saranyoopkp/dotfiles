# Docs Setup — ระบบเอกสารสำหรับทุก repo

> ใช้ได้กับทุก project ที่ทำงานร่วมกับ Claude Code (solo dev, long-running)
> มี user-level skill `/docs:setup` (`~/.claude/skills/docs/setup/SKILL.md`) ชี้มาที่ kit นี้ —
> ใน repo ไหนก็พิมพ์ `/docs:setup` เพื่อให้ session เข้าใจระบบ + ลงมือ setup/refactor ได้ทันที

## หลักการ

**บ้านของหลักการเอกสารทั้งหมด = `claude/rules/documentation-discipline.md`** (repo เดียวกันนี้
— ถูกโหลดเข้าทุก session อยู่แล้ว) — ไฟล์นี้ว่าด้วย**กลไก**ล้วน ๆ: โครงสร้าง, init, hooks, junction

**Invariant: artifact ที่ถูก copy เข้า repo ปลายทางต้อง self-contained** — ได้แก่
`CLAUDE.md` (จาก `CLAUDE.template.md`), `memory/*`, `.claude/hooks/docs-drift.sh`,
`.claude/settings.json` — ห้ามอ้าง `claude/rules/*`, path ของ kit, หรือ init script
(repo ปลายทางอาจอยู่คนละเครื่อง/คนละคน ที่ไม่มีของพวกนั้นและหาไม่เจอ = pointer ตาย)
เขียน**คำถาม/คำสั่งที่ต้องทำ**ลงไปตรง ๆ แทนการชี้ไปหาแหล่ง — ส่วน `README.md`/`init.sh`
ของ kit ไม่ถูก copy จึงอ้างได้ตามสบาย

ส่วนที่เป็นกลไกเฉพาะระบบนี้ (ไม่อยู่ใน rule):
- **`*/private/` ไม่ sync ข้ามเครื่อง** (ไม่อยู่ใน git) และห้ามใส่บรรทัดของมันใน
  `memory/MEMORY.md` ที่ commit (index จะชี้ไฟล์ที่เครื่องอื่นไม่มี)
- ก่อน commit memory ใหม่: ลบ metadata ส่วนบุคคล (`originSessionId` ฯลฯ) ออกจาก frontmatter

## จดอะไรเมื่อทำ feature เสร็จ (กติกากัน drift)

drift risk แปรผันตามความเร็วที่ fact เปลี่ยน → จดเฉพาะชนิดที่ drift ช้าและโค้ดเล่าเองไม่ได้:

| ชนิด | ตัวอย่าง | drift | จด? |
|---|---|---|---|
| การมีอยู่ + จุดเข้า | "feature X อยู่ที่ `src/foo/`, endpoint `/api/x`" | ต่ำ | ✅ 1–3 บรรทัดใน inventory |
| ทำไม + ข้อจำกัด + quirk | "เลือก A ไม่ใช่ B เพราะ...", "ลืม flag Y แล้วพัง" | ~ศูนย์ | ✅ มีค่าสุด |
| ทำงานยังไงข้างใน | step-by-step, รูปร่าง params | สูงมาก | ❌ ให้โค้ด/type/test เล่า |

กติกาข้อเดียว: ก่อนเขียนแต่ละบรรทัดถามว่า **"โค้ดเล่าสิ่งนี้เองได้ไหม?"** — ได้ = อย่าเขียนซ้ำ
ต้นทุนต่อ feature ควรอยู่ที่ 1–2 นาที: inventory 1–3 บรรทัด + decision ถ้ามี + quirk ถ้าเจอ

## โครงสร้าง

```
CLAUDE.md          ← เริ่มจาก CLAUDE.template.md
docs/              ← ไฟล์ละเรื่อง เกิดเมื่อ section ใน CLAUDE.md โตเกิน ~15 บรรทัด
docs/private/      ← sensitive ops notes (gitignored — init เพิ่มให้ใน .gitignore)
memory/            ← เริ่มจาก memory/ ใน template นี้
memory/private/    ← fact ส่วนตัว/เฉพาะเครื่อง (gitignored)
  README.md
  MEMORY.md        ← index หนึ่งบรรทัดต่อไฟล์
  <fact>.md        ← ตาม _fact.template.md
```

ฝั่ง harness (`~/.claude/projects/<id>/memory`) เป็น **link** (junction/symlink) ชี้มาที่ `memory/` ใน repo
— ไฟล์ชุดเดียวกันจริง ๆ (harness recall/auto-load ทำงานบนไฟล์ใน repo โดยตรง ไม่ต้อง sync)

## การจัดระเบียบ docs/

กติกา (ชื่อไฟล์ตามโดเมน, >~7 ไฟล์ → subfolder, index sync) อยู่ที่ rule
`documentation-discipline` — ฝั่งกลไกของ kit: ทำ subfolder ตอน promote ไฟล์ที่ 8
เลย (อย่ารอถึง 20) และ index ใน CLAUDE.md ใช้ format เดียวกับ `memory/MEMORY.md`
(หนึ่งบรรทัด/ไฟล์: ชื่อ + hook ว่าทำไมต้องเปิด)

## วิธี adopt กับ repo ใหม่

```bash
bash <path-to-kit>/init.sh /path/to/repo   # ทุก OS — Windows รันผ่าน Git Bash (มากับ Git อยู่แล้ว)
```

สคริปต์จะ: สร้าง `CLAUDE.md` จาก template + copy `memory/` + สร้าง `docs/` +
สร้าง **link** `~/.claude/projects/<id>/memory` → `<repo>/memory` (junction บน Windows,
symlink บน unix — memory ตัวจริงชุดเดียวอยู่ใน repo, harness อ่าน/เขียนไฟล์เดียวกัน
ไม่ต้อง sync มือ; ถ้ามี harness memory เดิมจะ merge เข้า repo แล้ว backup เป็น `.bak-*` ให้)
จากนั้นเติม CLAUDE.md ตาม placeholder แล้วเขียน fact แรก ๆ (mission, stack decision, quirks)

ข้อแลกเปลี่ยนของ link: memory ใหม่ที่ harness บันทึกจะโผล่ใน repo เป็น untracked file
→ ต้องคัดกรอง+commit เป็นระยะ และถ้าย้าย repo ไปเครื่องอื่น ให้รัน init อีกครั้ง (idempotent)
(section "Memory policy" ใน `CLAUDE.template.md` สอน Claude ให้ตรวจ+ซ่อมเองแล้ว — อย่าลบ section นั้น)

## Lifecycle hooks (กัน docs drift — ต้น/กลาง/ปลาย session)

init ติดตั้ง `.claude/hooks/docs-drift.sh` + `.claude/settings.json` ให้ (ติด git → ทุกเครื่อง ทุก OS):

| Event | หน้าที่ |
|---|---|
| `SessionStart` | sweep ของค้างจาก session ก่อน (uncommitted docs/memory) + ตรวจว่า link ยังดี + register watchPaths |
| `TaskCompleted` | checkpoint ณ จุดปิดงาน: เอกสารตามทันไหม / มี memory ควรจดไหม / commit พร้อมงาน |
| `Stop` | โหมดนุ่ม: เตือนเมื่อมี docs/memory ค้างไม่ commit, source change ที่ยังไม่มี runtime evidence และ line-comment ใหม่ตั้งแต่ 2 บรรทัด (throttle — เตือนครั้งเดียวต่อสถานะ ไม่สแปมทุก turn) |
| `PreCompact` | ก่อน context ถูกบีบ: จดของสำคัญลง memory/docs ก่อนหายไปกับ summary |

> `FileChanged` เคย wire ไว้แต่**ตัดออกแล้ว** (2026-07-12) — ทดสอบยิงจริงพบว่า harness
> ไม่ fire event นี้เลยแม้ documented ไว้ (dead config); logic ยังอยู่ใน `docs-drift.sh`
> เผื่ออนาคต แต่ไม่ได้ wire ใน `settings.json` — งานที่มันควรทำ (เตือนไฟล์ถูกแก้นอก
> session) ถูกครอบด้วย reminder ของ harness เองอยู่แล้ว (system-reminder "modified by
> the user or a linter") จึงไม่มี gap จริง

ทุกตัว **แจ้งผ่าน additionalContext ไม่ block** — Claude เห็นข้อความ `[docs]` แล้วจัดการเอง
hook เป็น self-contained: ใช้เฉพาะ git, bash, `CLAUDE.md`, `docs/` และ `memory/`; ห้ามอ้าง rule
หรือ skill ของ dotfiles เพราะ repo ปลายทางอาจไม่มีสิ่งเหล่านั้น. การตรวจ comment เป็นเพียง
deterministic audit lead (line-comment ติดต่อกันตั้งแต่ 2 บรรทัดใน diff) ไม่ตัดสิน docstring หรือ
แก้ไฟล์ให้อัตโนมัติ.

### ~~`acv-gate.sh`~~ — **ถอดออกจาก kit แล้ว (2026-07-17)**

เคยมี Stop hook ที่ **block** เมื่อ session แก้ไฟล์ source แต่ไม่เคยเรียก agent `ACV-v1.0`
(wire ผ่าน `settings.local.json` + patch ด้วย node) — **ถอดออกทั้งชุดตามคำสั่ง owner**
กู้ของเดิมได้จาก git: `git log --diff-filter=D -- '*acv-gate.sh'`

ทำไมถึงถอด (ไว้กันคนย้อนมาทำใหม่โดยไม่รู้ที่มา):
- มันคือ **enforcement ที่ยังพิสูจน์ไม่ได้** — logic ผ่านทุกเคสบน Bash tool แต่ **ไม่เคย
  live-fire ผ่าน hook runner จริง** (Bash tool ≠ hook subsystem, `claude -p` ไม่ยิง Stop hook)
- ข้อมูลที่มีชี้ว่า **prompt-level ก็ขยับได้จริงโดยไม่ต้องมี gate**: ACV compliance ขึ้น
  39% → 64% จาก SCC prompt รอบ cutover-1 ล้วน ๆ (gate ยังไม่เคย deploy ตอนวัด)
- ราคา ACV (~6 นาที / ~213k token ต่อครั้ง) แปลว่า gate ที่บังคับแบบ "มี Edit = ต้องตรวจ"
  ตีกว้างเกินความเสี่ยงจริงของงาน

**สิ่งที่ยังไม่ถูกแก้ (known gap)**: Acceptance Validation Protocol ตอนนี้พึ่ง SCC prompt
อย่างเดียว = พึ่งความจำของโมเดล ไม่มีระบบบังคับ — ถ้า compliance ตกกลับ ให้ revisit
โดยเริ่มจาก "ACV เวอร์ชันเบา" ก่อนกลับมาที่ hard gate
`settings.json` เป็น template เดียวใช้ได้ทุก OS จริง — args เป็น `["-c", "bash $(git
rev-parse --show-toplevel ...)/.claude/hooks/docs-drift.sh <Event>"]`: คำนวณ repo root
ด้วย `git rev-parse --show-toplevel` ตรง ๆ (ไม่พึ่ง `$CLAUDE_PROJECT_DIR` เลย — เคยพบว่า
harness ทำให้ตัวแปรนี้ว่างเปล่า/backslash หายไปในบาง launch context), normalize ด้วย
`sed`, แล้วเรียก `bash` explicit ซ้ำอีกชั้นข้างใน `-c` (ไม่ exec path ตรง ๆ — ไม่ต้อง
พึ่ง execute bit ที่อาจหายข้าม git/OS boundary) — `docs-drift.sh` เองก็คำนวณ root ด้วย
วิธีเดียวกันทุกประการ (สองชั้น sync กัน ไม่มี env var แทรกกลาง) — ดู decision log ใน
dotfiles CLAUDE.md
ถ้าอยากรู้ที่มา

## Inline work-notes (TODO ในโค้ด → ตารางสถานะ)

รูปแบบนี้คือ **codetag** (PEP 350; รูปวงเล็บดัดแปลงจาก Google convention `TODO(username)` —
เราใช้ scope/โดเมนแทน username เพราะ agent ไม่มีชื่อและ scope ใช้ join ตารางได้)

- **format ตายตัว greppable**: `TODO(scope): ข้อความ` / `FIXME(scope):` / `HACK(scope): เหตุผล`
  — ห้าม TODO เปล่าไร้ scope/บริบท (โน้ตที่ grep ไม่เจอ = โน้ตที่ไม่มีอยู่)
- **จุดต่างจาก comment/docstring คือ*อายุ***: comment/docstring อยู่ตราบที่โค้ดอยู่ —
  codetag **ต้องตาย**: ลบใน commit เดียวกับงานที่ปิดมัน (ค้าง = โกหกตารางสถานะ);
  codetag ที่อายุเกิน ~2 สัปดาห์ = สัญญาณว่ามันคือหนี้ระดับ feature ที่ควรย้ายขึ้น
  CLAUDE.md TODO/Future boundaries ไม่ใช่แช่ในโค้ด
- **ตารางสถานะ = ผลของคำสั่ง ไม่ใช่ไฟล์** — ห้ามทำ docs/status.md เขียนมือ (drift แน่นอน);
  จดคำสั่ง scan ไว้ใน CLAUDE.md ของ repo เช่น `grep -rn "TODO(\|FIXME(\|HACK(" src/`
- **เส้นแบ่งระดับ**: โน้ตในโค้ด = หนี้ระดับจุด (บรรทัด/function) · CLAUDE.md TODO +
  Future boundaries = หนี้ระดับ feature — อย่าเอา feature ทั้งตัวไปฝังเป็น TODO ในไฟล์เดียว
- คำถาม "ระบบมีอะไร/ค้างอะไร" ตอบจาก: Inventory (มี+ทำแล้ว) + grep (ค้างระดับจุด) +
  Future boundaries (เลื่อนระดับ feature)

## Re-apply / upgrade repo ที่ setup แล้ว

รัน `/docs:setup` ซ้ำได้เสมอ — init จะอัปเดต hooks script + ซ่อม link ให้ แต่ **CLAUDE.md
และ settings.json เดิมจะไม่ถูกทับ** (repo เป็นเจ้าของ) ส่วนที่เป็นเนื้อหา (Memory policy,
checklist, convention ใหม่) ตัว skill จะ merge ให้แบบรักษา customization ของ repo —
ดูขั้นตอนใน SKILL.md section "Re-apply / upgrade"

## วิธี refactor repo เดิมที่เป็น changelog ยักษ์

1. ไล่ Status bullets: แยก "ความรู้ถาวร" (config, formula, quirk, การตัดสินใจ) ออกจาก
   "ประวัติ" (ลำดับ debug, ตัวเลขชั่วคราว) — อย่างหลังทิ้งได้ (อยู่ใน git แล้ว)
2. ความรู้ถาวรก้อนใหญ่ → `docs/<topic>.md`; fact สั้น → `memory/<fact>.md`
3. ย่อ Status ใน CLAUDE.md เหลือ 1 บรรทัด/module + ลิงก์ไปไฟล์ที่แยกออก
4. เพิ่ม index ของ docs/ + memory/ ไว้ท้าย CLAUDE.md ให้มองเห็นตั้งแต่เปิดไฟล์
