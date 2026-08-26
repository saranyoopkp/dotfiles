# Hook path-resolution saga (point-in-time: ปิดคดี 2026-07-13, จดครบ 2026-07-18)

ประวัติ 12 เวอร์ชันของ `.claude/settings.json` hook wiring — **เก็บไว้กันคนย้อนกลับไปใช้
เวอร์ชันที่ตายแล้ว** สถานะปัจจุบัน = **ข้อ 12 เท่านั้น** (สรุปสั้นอยู่ CLAUDE.md §Quirks)

## บทเรียนใหญ่ที่คลุมทั้ง saga

**Bash tool ของ agent ≠ hook runner จริง** — hook execution subsystem ของ Claude Code
บน Windows รันผ่าน **WSL bash** (`System32\bash.exe`) เสมอ แยกสิ้นเชิงจาก interactive
Bash tool ที่ agent ใช้ (Git Bash/MSYS — `uname` = `MINGW64_NT`) → agent จำลอง fix
ด้วย Bash tool ผ่าน 100% ทุกรอบ แต่ hook จริงพังต่อ; แม้ `env` ของ agent เห็น
`WSL_DISTRO_NAME` ว่าง ก็เพราะนั่นคือ env ของ Bash tool ไม่ใช่ของ hook subsystem
(2026-07-13, เครดิต: user ชี้ต้นตอ "คุณอยู่ใน wsl ครับ") → กติกาที่ตามมา:
**hook fix ยืนยันด้วย real session restart + feedback จาก user เท่านั้น** (กติกานี้มาจาก
user สั่งเอง 09:20 "debug รอบหน้า แนะนำให้ใช้ feedback จริงจากผมนะครับ" — commit 809d32e)

loop 9 fixes / 4 ชม. ของวันนั้นจบ**ทันทีที่เปลี่ยนช่องทางวัด** ไม่ใช่ตอน fix เก่งขึ้น —
หลักฐานหลักของ loop-breaker ในร่าง SCC รอบสาม (docs/scc-behavior-experiment.md)

## Chain เวอร์ชัน 1-12 (ตายแล้วทั้งหมด ยกเว้น 12)

1. relative (`.claude/hooks/...`) → พังถ้า launch จาก subdir (resolve จาก launch cwd)
2. `"${CLAUDE_PROJECT_DIR}/..."` ใน args ตรง ๆ → harness กิน backslash ทิ้งตอน substitute
   string บน Windows (undocumented) → path ไม่มี separator เลย
3. `args: ["-c", "...$CLAUDE_PROJECT_DIR...cygpath -u..."]` (bash expand เอง) → ดูเหมือนแก้แล้ว
   แต่พังเป็นครั้งคราว: **root cause คือเครื่องมี bash 3 ตัวชน PATH** (Git Bash, WSL launcher
   ที่ `System32\bash.exe`, Windows Store alias) — `"command": "bash"` โดน PATH lookup พาไป
   เจอ WSL bash ซึ่งไม่เห็น Windows env var และไม่มี `cygpath` ("cygpath: command not found")
4. `env.CLAUDE_CODE_GIT_BASH_PATH` (documented env var) → **ไม่ได้ผล** — hook command
   resolution ไม่อ่าน var นี้ (documented แต่ scope ไม่ครอบ hook spawn)
5. absolute Git Bash path ต่อเครื่อง (init เขียนทับ `"command"`) → ใช้ได้แต่**ทำลาย
   cross-platform** (settings.json ผูกกับเครื่องที่ init ล่าสุด) → supersede
6. `bash -c` + `tr '\\' '/'` normalize `$CLAUDE_PROJECT_DIR` → cross-platform จริง
   ทดสอบ JSON.parse ผ่าน — เครดิต: user เจอทิศทางนี้เอง (เวอร์ชันแรกที่ส่งมาเป็น debug
   `echo` ไม่ได้ exec — จับได้และแก้ก่อน deploy)
7. **macOS "Permission denied"** — execute bit ไม่ถูก track จริงบน NTFS → commit จาก
   Windows ได้ mode non-executable → macOS enforce → แก้ด้วยเรียกผ่าน `bash <path>`
   แทน exec ตรง (ไม่พึ่ง execute bit) — ✅ ยืนยันบน macOS 2026-07-12 ทั้ง 4 events
8. `FileChanged` ถูกตัดออกจาก wiring — **documented แต่ harness ไม่เคย fire จริง**
   (ทดสอบ 3 ช่องทางบน macOS เงียบหมด) เหลือ 4 hooks verified: SessionStart/Stop/
   TaskCompleted/PreCompact; logic เก่าเคยเก็บเป็น dead code ก่อนถอดออก 2026-08-02
   (ห้ามใส่กลับจนพิสูจน์ว่า fire)
9. `$CLAUDE_PROJECT_DIR` **ว่างเปล่าในบาง session** (user เจอเอง) → args string ที่คำนวณ
   path ของ docs-drift.sh ไม่มี fallback → เพิ่ม `${CLAUDE_PROJECT_DIR:-$(git rev-parse
   --show-toplevel)}`
10. root cause ตัวจริงของ 9 = ข้อ "Bash tool ≠ hook runner" ด้านบน
11. `env.CLAUDE_CODE_GIT_BASH_PATH` ใน settings.local.json (ต่อเครื่อง) → ก็ไม่ได้ผล —
    ยืนยันว่า hook-spawn ไม่อ่าน var นี้ทุกระดับ → เลิกแนวทาง env var pin ทั้งหมด
12. ✅ **ปัจจุบัน (user ทดสอบผ่าน real restart 2026-07-13 "สเถียรสุดครับ")**:
    `args: ["-c", "bash $(git rev-parse --show-toplevel 2>/dev/null | sed 's/\\\\/\\//g')/.claude/hooks/docs-drift.sh <Event>"]`
    — event name bake ใน string เดียว, เรียก `bash` explicit ใน `-c`, ไม่มี env var ทั้งระบบ
    (docs-drift.sh เองก็ใช้ `git rev-parse` ล้วน) — ยังไม่รู้กลไกแน่ชัดว่าทำไมรูปแบบนี้
    ต่างจากข้อ 6 ใน WSL bash subsystem (สมมติฐาน: การ evaluate `$(...)` ต่างกันตาม
    ตำแหน่งใน args) — deploy ได้เพราะยืนยันผลจริง; คำถามกลไกเปิดอยู่ (TODO ใน CLAUDE.md)

## Stop continuation loop (แก้ 2026-07-30)

Stop hook เดิมไม่อ่าน JSON stdin และ comment warning ไม่มี stamp ของตัวเอง. เมื่อ hook ส่ง
feedback เดิม Claude Code จึง continue แล้วเรียก Stop ซ้ำ; script ไม่เห็น
`stop_hook_active=true` และ block ต่อจน harness override หลัง 9 ครั้ง. แก้โดย:

1. อ่าน stdin ทุก event และ `exit 0` ทันทีเมื่อ Stop มี `stop_hook_active=true`
2. ใช้ `decision:block` + `reason` ตาม Stop contract แทนการอาศัย `additionalContext`
3. dedup comment warning ต่อ location state และ reset stamp เมื่อ comment หาย
4. เพิ่ม deterministic regression test: first Stop block, active Stop ผ่าน, state เดิมเงียบ,
   comment หายแล้วกลับมาเตือนใหม่

ห้ามแก้ด้วยการเพิ่ม `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`; นั่นเพิ่มจำนวนรอบของ loop แต่ไม่สร้าง
เงื่อนไข convergence. Contract ตรวจวันที่ 2026-07-30 จาก Claude Code hooks reference/guide;
ผลจริงยังต้องยืนยันใน session ที่ restart ตามกติกาหลักของเอกสารนี้.

## Deploy checklist (ยังบังคับ)

- แก้ `docs-drift.sh` → deploy **คู่กับ** `settings.json` เสมอ (เคยพลาดรอบเดียว —
  comment ค้างเวอร์ชันเก่าที่ repo อื่น, macOS session จับได้, แก้แล้ว 2026-07-12)
- repo ที่ setup แล้วรับของใหม่ผ่าน `/docs:setup` re-apply เท่านั้น (junction มีผลเฉพาะ
  rules/skills — hooks เป็น copy ต่อ repo)

## Scope-aware enforcement (แก้ใน template 2026-08-02)

Transcript audit พบว่า reminder ที่ตั้งใจป้องกัน docs stale/forgot commit กลายเป็น source ของ
objective drift: hook ใช้ dirty worktree ทั้งก้อนเป็น scope แล้วสั่งแก้ docs, runtime test และ
commit โดยไม่รู้ว่า path ใดมีอยู่ก่อน session หรือ user authorize อะไร. รุ่นใหม่จึง:

1. capture baseline ครั้งแรกต่อ repo + `session_id`; dirty path เดิมเป็น report-only และห้าม
   hook สั่ง edit/stage/commit
2. ตรวจ comment ทันทีที่ `PostToolUse(Edit|Write)` และ fallback ที่ Stop เฉพาะ path
   clean-at-start; ไฟล์ dirty เดิมถือ provenance คลุมเครือ
3. เปลี่ยน verify reminder เป็น `behavior claim / evidence / gap` และห้ามขยาย test matrix หรือ
   mutate shared/runtime state โดยไม่มี authorization
4. ให้ docs มี disposition (`updated`, `no durable docs impact`, `deferred`) แทนการบังคับสร้างไฟล์
5. ให้ SessionStart ตรวจ memory link แบบ read-only; `/docs:setup` ยังเป็น owner ของ merge/repair
6. คง Stop one-shot, state dedup และ `stop_hook_active` loop breaker; memory leaf/index mismatch
   ที่ session สร้างยังเป็น deterministic violation

Commit boundary ปรับตาม workflow ของ user วันที่ 2026-08-18: งาน mutation ที่ authorize แล้วและ
ถึง cohesive verified checkpoint ให้ local commit โดย default เพื่อรักษา provenance ของแต่ละงาน;
ยังห้ามรวม baseline dirty paths และการ push/deploy/history rewrite ต้อง explicit. ข้อนี้แทน wording
ชั่วคราวที่กำหนดให้ commit ต้อง explicit ซึ่งทำให้งานหลาย project ค้างปนกันจนระบุที่มายาก.

Cutover 2026-08-26: ถอน default นี้หลัง instruction-overload audit. Local commit กลับไปเป็น
user/repository workflow decision; hook ไม่บล็อก source edit เพื่อบังคับ commit, docs disposition หรือ
comment length แล้ว และ Stop คงเฉพาะ shared-memory leaf/index mismatch ที่ตรวจ deterministic ได้.

หลัง audit ผู้ใช้เลือกให้ local commit กลับเป็น default ที่ cohesive verified checkpoint เพื่อให้
track/revert ได้. Enforcement อยู่ใน core/SCC โดยตรง; hook ยังคง low-ceremony และไม่ block source edit
เพื่อบังคับ commit.

Regression shell test พิสูจน์ logic ระดับ script/settings เท่านั้น. ตามบทเรียนหลักด้านบน
behavior ใน hook runner จริงยังต้องยืนยันด้วย Claude Code session ใหม่หลัง deploy/restart;
ห้ามสรุปว่า live integration ผ่านจากการเรียก script ใน Bash tool.
