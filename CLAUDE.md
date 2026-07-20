# dotfiles (personal Claude Code config — cross-machine)

> สถานะ: **ACTIVE** — remote: github.com/saranyoo-mk/dotfiles (private, push 2026-07-18)
> linked แล้ว (junction → repo นี้): `~/.claude/rules`, `~/.claude/agents` (ทั้ง dir) ·
> `~/.claude/skills/<name>` (**รายตัว** — ตัว dir skills เป็นของ harness อย่า junction ทั้งก้อน)

## Inventory
- **claude/skills/docs/setup/** — skill `/docs:setup` + `kit/` (ระบบเอกสารต่อ repo:
  CLAUDE.template, memory starter, init.sh, lifecycle hooks) — กลไกอธิบายใน `claude/skills/docs/setup/kit/README.md`
- **claude/rules/** — engineering standards โหลดทุก session ทุก repo (`ls claude/rules`);
  วิธีตีความอยู่ `00-how-to-read-these-rules.md` (หลักการไม่ใช่ข้อห้าม + กติกาหด)
- **claude/skills/** — skills รายตัว (`ls claude/skills`); domain detail เชิงลึกที่ผูกกับ
  *ประเภทงาน* ทำเป็น skill (on-demand: description บาง ๆ always-loaded = routing signal,
  body โหลดตอน invoke). กลไก on-demand rule = **skill** (native, load-once, no pointer)
  ไม่ใช่ playbooks/paths — ดู decision + ผลเทสใน docs/dogfood-audit
  - **taxonomy (ตัดสิน 2026-07-16)**: rule → skill เมื่อ **(ก) work type ประกาศตัวชัด (ข) miss แล้วกู้ได้
    (ค) ลึก/จะลึกจริง** ครบทั้งสาม (ย้ายแล้ว: `ui-ux-baseline`, `data-design`). ที่คง **always-on**:
    money/authz/time (ฝังในงานอื่น + miss เจ็บถาวร) · `webhook-integration` (แนวทาง/bounded ไม่ลึกพอ —
    revert แล้ว) · 7 cross-cutting (ใช้เกือบทุกงาน). **ห้ามย้ายเพราะ ceiling อย่างเดียว** — depth คือเหตุผลจริง
  - **grouping = growth path (⚠️ nested dir ไม่ทำงานจริง — ใช้ junction แบน + frontmatter name มี colon แทน, ดู docs/claude-code-mechanisms.md §grouping)**:
    skill **เดี่ยวจน SKILL.md เกิน ~200 บรรทัด + มี sub-concern ต่างกันชัด** แล้วค่อยแตกเป็น group
    (แต่ละ sub มี description = routing signal ของตัวเอง, โหลด body เฉพาะ sub ที่ invoke).
    ต่ำกว่านั้น = skill เดี่ยว (group = โครงเผื่ออนาคต ห้ามทำก่อนถึง — ดู 00 ข้อ 5 / SCC)
  - regression: `test/routing/run.sh` (ground-truth tool_use, parallel, `claude -p`) — รันหลังแก้ skill
- **references/** — เปิดดูตามต้องการ ไม่โหลดเข้า session (list = `ls references/` — อย่า enumerate ที่นี่)
- **claude/agents/** — agent definitions (SCC = agent หลัก, ACV = ผู้ตรวจรับ) —
  เครื่องนี้: `~/.claude/agents` เป็น junction มาที่นี่ (ตัวจริงชุดเดียว);
  **เครื่องอื่น: owner จัดการ junction เอง — install script ไม่ทำให้** (ตัดสินใจ 2026-07-12)
- **install.sh** — link `~/.claude/{skills,rules}` เข้า repo (idempotent, merge+backup)
- **test/metrics/** — วัดพฤติกรรม agent จาก session corpus (lookback regex/tool_use, semantic
  classify ผ่าน haiku fan-out `--sample`, ground-truth eval) — ดู README ในโฟลเดอร์; `data/` gitignored
- **docs/** — `dogfood-audit-2026-07-15.md` = ผลขุด pain point จาก `~/.claude` (snapshot;
  enforcement gap, ACV/SCC compliance, ตัวเลขที่ถอนแล้ว, กับดักการขุด corpus) ·
  `claude-code-mechanisms.md` = กลไก `.claude/` (on-demand loading, skill grouping,
  path resolution, `claude -p` test bed) — reference กันขุดซ้ำ

## Conventions / decisions
- **agent spec + rules = generic เท่านั้น (ทักครั้งที่ 2 แล้ว: 07-11 rules, 07-17 SCC)** —
  เก็บได้แค่รูปแบบ/มาตรฐาน/แนวทาง **ห้ามมีชื่อ project/repo/ระบบจริง** แม้ในตัวอย่าง
  (ตัวอย่างใช้ placeholder generic); ก่อน commit ไฟล์ใน claude/agents|rules:
  `grep -riE "ชื่อ project ที่รู้จัก" claude/agents claude/rules` ต้อง clean
- **rules = principle-level เท่านั้น** — tech choice/pattern หนักอยู่ CLAUDE.md ของแต่ละ repo;
  rule ใหม่เกิดจาก "แผลซ้ำครั้งที่สอง" เท่านั้น (freeze 2026-07-08) และต้องถาม merge ก่อนเปิดไฟล์ใหม่
- **เพดาน rules ~400 บรรทัดรวม** — เพิ่ม = zero-sum; นับด้วย
  `cat claude/rules/*.md | wc -l` (bash เดียว ตาม decision ข้างล่าง)
- **single home**: หลักการเอกสาร = `claude/rules/documentation-discipline.md`; kit README = กลไกล้วน
  (consolidated 2026-07-08 — เดิมซ้ำ 3 ที่แล้ว drift จริง)
- **script ที่ deploy/hook = bash เดียว** (scope ชัด 2026-07-17: เหตุผลเดิมคือ script
  ที่ไปรันทุกเครื่อง/ทุก OS — kit init/hooks; **เครื่องมือวิเคราะห์บนเครื่อง dev**
  เช่น test/metrics/, skill scripts = python ได้ เพราะความแม่นของ text/path processing
  คือหน้าที่หลักและไม่ถูก deploy) (แก้ 2026-07-12: เดิมมี .ps1 คู่ .sh — รวมเป็น bash
  เพื่อ maintain ที่เดียว/ทุก OS; Windows รันผ่าน Git Bash ซึ่ง: มองเห็น junction เป็น
  symlink (`-L` ใช้ได้), สร้าง junction ผ่าน `cmd //c mklink /J`, id คำนวณจาก path
  แบบ native ผ่าน `cygpath -w` — ทดสอบแล้วทั้งสามข้อ) — ฆ่า quirk ตระกูล PS 5.1
  (BOM, here-string) ทิ้งทั้งหมด
- commit message ผ่าน harness PowerShell tool: อย่าใส่เครื่องหมายคำพูดใน here-string (parse พัง — ใช้ ASCII เรียบ ๆ)
- **hook-spawn bug (เช่น path resolution ใน `.claude/hooks/`) ห้าม verify ด้วย agent's
  Bash tool เพียงอย่างเดียว** — Bash tool ของ agent รันบน Git Bash/MSYS แต่ hook
  execution subsystem จริงรันผ่าน WSL bash (คนละ process/env กันสิ้นเชิง แม้เรียก
  "bash" เหมือนกัน) — Bash tool simulation ผ่าน 100% ไม่ได้แปลว่า hook จริงจะผ่าน
  (เจอจริง 2026-07-13, ดู Quirks ข้อ 10 ด้านล่าง) **ต้องขอให้ user restart session จริง
  แล้ว report อาการกลับมา** ก่อนเชื่อว่า fix สำเร็จ — ห้ามสรุปว่า "แก้แล้ว" จากผลทดสอบ
  ของ agent เองล้วน ๆ

## Enforcement gap (วัดจริง 2026-07-15 — ดู `docs/dogfood-audit-2026-07-15.md`)
กลไกทุกชิ้น (SCC / ACV / rules) **ทำงานถูกต้องเมื่อถูกใช้** — ปัญหาคือถูกใช้จริงแค่บางส่วน
เพราะทุกอย่างพึ่งความจำของโมเดล ไม่ใช่ระบบบังคับ:
- **ACV ถูกเรียกแค่ 21%** ของ session ที่แก้โค้ด (20/95) — และ **SCC เรียกมันแค่ 39%**
  ทั้งที่ constitution สั่งว่าต้องส่งตรวจทุก feature/fix (ACV เกิดนอก SCC แทบไม่ได้เลย: 2%)
- **ACV ไม่ใช่ rubber stamp** — 51% ไม่ใช่ clean pass, จับ SSRF/index/concurrency จริง
  **อย่ารื้อทิ้ง**; ราคา ~6 นาที + ~213k fresh token/ครั้ง → trigger ควรผูกกับ*ความเสี่ยงของงาน*
  (**สถานะ: ยังเป็นข้อเสนอ — SCC ปัจจุบันบังคับทุกการเปลี่ยนแปลงตามเดิมจนกว่า ACV-light
  จะ deploy**; อย่าอ่านบรรทัดนี้เป็นใบอนุญาตข้าม)
  ไม่ใช่ "มี Edit = ต้องตรวจ"
- **SCC adoption: ปิดรูรั่วแล้ว** — เคยรั่ว 3-5 session/วันที่ไม่มี `agentSetting` แต่**หยุดสนิท
  ตั้งแต่ 2026-07-12** (ช่วงจัด cross-platform/settings) — 07-12→14 = **35 SCC : 1 NONE (97%)**
  ⚠️ ตัวเลข "รั่ว 25%" ที่เคยสรุป = artifact จากการเฉลี่ยทั้งเดือน (รวมช่วงก่อนแก้เข้าไปด้วย)
  → **บทเรียน: ดู time trend ก่อนเขียนอะไรเป็น "สถานะปัจจุบัน" เสมอ**
- **agent หยุดถามทั้งที่รู้คำตอบเอง 80%** ของเคส "ต่อเลยครับ" (ติดจริงแค่ 7%)

## 🔬 SCC behavior change — cutover marker (2026-07-15)

**เส้นแบ่ง before/after สำหรับวัดผล** — session ที่ปิด**ก่อน**เวลานี้ = "before", **หลัง** = "after"
(session ที่คร่อมเส้น: ตัดทิ้ง — SCC ตัวใหม่โหลดตอน session start เท่านั้น ต้อง restart ถึงมีผล)

```
cutover-1: 2026-07-15T02:44+07:00  · SCC 539 → 580 (ทำแผนให้จบ + ประกาศชั้นหลักฐาน)
cutover-2: 2026-07-16T16:10+07:00  · SCC 580 → 617 (calibrated-action + record-before-done)
cutover-3: 2026-07-17T20:55+07:00  · SCC 617 → 626 (form-ambiguity + assumption-declare)
```
**cutover-2 (จาก "ไม่" pain audit, 345 corrective turn)**: (ก) *calibrated action* — จับผิดเป้า(70)/
ตกหล่น(64)/ทำเกิน(28) = ลงมือก่อนเช็คถูก/ครบ/พอ → ยืนยันเป้าเมื่อกำกวม, เสนอไม่ใช่ทำเมื่อเกิน,
account ของเก่าเมื่อแทนที่ (แต่เป้าชัด+สั่งแล้ว = ทำเลย ไม่ over-ask) · (ข) *record-before-done* —
งานเสร็จ=จดทันที, status stale="โกหก session หน้า" (แก้ pain: เปิดมาคิดว่ายังไม่เสร็จ)
วัด: อัตรา "ไม่ใช่/ไม่ได้/ไม่ต้อง" + docs drift ควรลด (แก้ก่อน วัดทีหลัง)

**cutover-3 (แก้ก่อนกำหนด — owner สั่ง 2026-07-17 "มีผลกระทบกับการทำงานจริง")**: สมมติฐาน
owner = การเลิกถาม (cutover-1) ตัด function "ถามเพื่อเข้าใจ intent" ทิ้งไปด้วย → ไม่ตรง intent
มากขึ้น; หลักฐานสนับสนุน (ไม่ใช่ proof): corr_target 07-17 = 6.5/100t สูงสุดของเดือน (median
~3.4) วันเดียวกับ approve ต่ำสุด + concession ขึ้น 1.3-1.7 + เคสจริง report-miss วันเดียวกัน.
แก้ 2 จุดใน calibrated-action: (ก) ขยายตัวอย่างกำกวมจาก target → รวม *form ของ deliverable*
(ข) **ไม่ถาม ≠ เดาเงียบ**: ไม่ถามได้ แต่ต้องประกาศความเข้าใจหนึ่งบรรทัดก่อนลงมือ (ทำต่อเลย
ไม่รอคำตอบ — คืน function ของการถามที่ต้นทุน ~ศูนย์). การวัด: แยกช่วงที่เส้นนี้ ไม่ปนกับ cutover-2
— metric ที่ควรขยับ: corr_target ลง โดย approve ไม่เด้งกลับขึ้น

**สิ่งที่เปลี่ยน** (2 section, เขียนแบบ trigger→action ไม่ใช่หลักการลอย ๆ):
1. *ทำแผนของตัวเองให้จบ* — ห้ามถามคำถามที่รู้คำตอบเอง, ห้ามเสนอ "หรือพักก่อน", ห้ามยื่นเมนู A/B/C
2. *ประกาศชั้นของหลักฐาน* — "เสร็จ/พร้อมใช้" ใช้ได้เฉพาะมีหลักฐาน runtime; ตาราง ✅/emoji ไม่ใช่ citation

**สมมติฐานที่กำลังทดสอบ**: กฎแบบ trigger→action ได้ผลกว่ากฎแบบหลักการลอย ๆ
→ ถ้าจริง อัตรา "ต่อเลยครับ" (baseline: **24/30 = 80%** ของเคส) ควรลดลงชัดใน session หลัง cutover
→ **ถ้าไม่ลดเลย = รูปแบบกฎไม่ใช่ตัวแปร → อย่าเสียเวลารื้อ SCC ทั้งไฟล์** (`wc -l` = ขนาดจริง) (ตัดสินใจนี้รออยู่)

**ผลวัดจริง 3 วันหลัง cutover (2026-07-15, main-only, n=20 session / 206 turn):**
| metric | before | after |
|---|---|---|
| "ต่อเลยครับ"-type | ~1.8/100 turn | **0 / 206 turn** |
| ACV compliance (SCC session) | 39% | **64%** (9/14) |
→ สัญญาณแรงทั้งสองตัว ไปทางเดียวกัน **แต่ยังไม่ใช่ proof of causation**: n เล็ก, 3 วันนี้
คือช่วง observer effect (user จ้องวัดอยู่), ACV 64% = SCC prompt เรียกเอง **ไม่ใช่ acv-gate**
(gate ยังไม่ deploy) → prompt-level ก็ขยับได้จริงไม่ต้องรอ hook; ต้องดูต่อ 2-3 สัปดาห์
ให้ n โต + ผ่านช่วงที่ user ไม่ได้จ้อง ก่อนสรุป causation

**Lookback 2026-07-17 (ground-truth tool_use, main only, กรอง Temp/`-p`/session<2 turn, ตัด straddle):**
| metric | P0 ก่อน cut1 (61s/1614t) | P1 cut1→cut2 (64s/247t) | P2 หลัง cut2 (12s/125t) |
|---|---|---|---|
| "ต่อเลย/ทำต่อ"-cmd /100t | 1.9 | 0.0 | 0.8 (1 เหตุการณ์) |
| corrective "ไม่ใช่/ไม่ได้/ไม่ต้อง" /100t | 1.9 | 0.4 | 0.8 (1 เหตุการณ์) |
| ACV ใน edit-session | 31% (15/48) | 57% (4/7) | 🔴 **11% (1/9)** |
→ พฤติกรรม "ถามทั้งที่รู้" ลดจริงและ**คงอยู่** (cutover-1 = ได้ผล, n พอเชื่อ trend);
cutover-2 ยังตัดสินไม่ได้ (1 วัน, เหตุการณ์เดียว) **แต่ ACV compliance ร่วงแรง**:
5 session แก้หนัก (สูงสุด 176 edits, gateway) ไม่ส่ง ACV เลย → **ชน tripwire ใน TODO
"ถ้า compliance ตก → revisit ACV เวอร์ชันเบา"** — นี่คือ action item ถัดไป ไม่ใช่รอ 08-01
(หมายเหตุ: 64% เดิมวัดหน้าต่าง 3 วันช่วง observer effect; 11% คือช่วง user ไม่ได้จ้อง —
สอดคล้อง insight ข้อ 4: ราคา ACV ~6นาที/213k คือตัวขับการเลี่ยง ไม่ใช่ถ้อยคำ prompt)

**Semantic classify (canonical 2026-07-17 หลัง dedup, haiku 7-cat, n=3,123 ตั้งแต่ 07-01):**
⚠️ corpus ต้อง dedup ก่อนเสมอ — rewind/message-edit สร้าง sibling branch ผี ~9% (304 turns)
และ bias ไม่สุ่ม (กระจุกใน corrective) — extract_turns.py ตัดให้แล้ว (เก็บ sibling สุดท้าย/parentUuid).
approve/continue: ~19-20/100t ต้นเดือน → **8.3 (07-16) → 6.5 (07-17)** — ลดชัดหลัง cutover;
ระดับสัมบูรณ์สูงกว่า regex เพราะจับ "ครับ/เลือก C" ที่ตอบคำถามจริงปน; corrective แกว่ง
2-14/100t ไม่เห็น step ที่ cutover-2 (07-17 corr_target เด้ง 6.5 = ปน meta-session ที่ audit ตัวเอง).
**Classifier quality (ground-truth n=100, labeler=Fable-judge ไม่ใช่ human):** accuracy 0.84;
approve/new_task P≈0.95 · corrective P=0.73-0.80 → ตัวเลข corrective มี noise ~20-25%
ใช้ดู trend ได้ อย่าอ่าน absolute เป๊ะ. เครื่องมือถาวร: `test/metrics/` (README ในนั้น)

⚠️ วัดด้วย main session เท่านั้น (กรอง `/subagents/` ออก) และดู time trend ไม่ใช่ค่าเฉลี่ยรวม
— ดู `docs/dogfood-audit-2026-07-15.md` §กับดัก ก่อนนับ

## Quirks
- แก้ rules/kit ที่นี่มีผลทันทีทุก repo (junction) — แต่ repo ที่ setup แล้วรับของใหม่ใน
  CLAUDE.md/settings ของมันผ่าน `/docs:setup` re-apply เท่านั้น (ดู SKILL.md)
- hooks settings: **ปัจจุบัน = ข้อ 12 ด้านล่าง** (direct argv, `git rev-parse` ล้วน, ไม่มี
  env var — verified ด้วย real restart 2026-07-13); รายการ 1-11 คือ chain ของเวอร์ชันที่
  **ตายแล้วทั้งหมด** เก็บไว้กันคนย้อนกลับไปใช้ — ห้ามหยิบ config จากข้อใดนอกจาก 12:
  1. relative (`.claude/hooks/...`) → พังถ้า launch จาก subdir (resolve จาก launch cwd)
  2. `"${CLAUDE_PROJECT_DIR}/..."` ใน args ตรง ๆ → harness กิน backslash ทิ้งตอน
     substitute string บน Windows (undocumented) → path ไม่มี separator เลย
  3. `args: ["-c", "...$CLAUDE_PROJECT_DIR...cygpath -u..."]` (bash expand เอง) →
     ดูเหมือนแก้แล้ว แต่ยังพังเป็นครั้งคราว: **root cause ตัวจริงคือเครื่องมี bash
     3 ตัวชน PATH กัน** (Git Bash, WSL launcher ที่ `System32\bash.exe`, Windows Store
     alias) — `"command": "bash"` เฉย ๆ โดน PATH lookup พา ไปเจอ WSL bash เป็นครั้งคราว
     ซึ่งไม่เห็น Windows env var เลยและไม่มี `cygpath` (error: "cygpath: command not
     found" + path ว่างเปล่า — เจอจริงบน Mek.ai)
  4. `env.CLAUDE_CODE_GIT_BASH_PATH` (documented env var) — **ไม่ได้ผล**: deploy จริง
     แล้ว SessionStart:resume ยัง `cygpath: command not found` ซ้ำ — แปลว่า hook
     command resolution ไม่อ่าน var นี้ (documented แต่ scope ไม่ครอบ hook spawn จริง —
     gap ที่ guide เตือนไว้แล้วว่า undocumented ตรงจุดนี้)
  5. absolute Git Bash path ต่อเครื่อง (`init.sh` เขียน path จริงทับ `"command"`) —
     **ใช้ได้แต่ทำลาย cross-platform**: settings.json ที่ commit เข้า git ผูกกับ
     เครื่อง/OS ที่ init รันครั้งล่าสุด — push ไป unix หรือเครื่อง Windows ที่ install
     Git คนละที่ = พังทันที (เห็นจากคำถาม user เอง "แปลว่า cross-platform ไม่ได้จริง
     ใช่ไหม" — ถูกต้อง ยอมรับตรง ๆ) → **supersede**
  6. **ปัจจุบัน (static template, cross-platform จริง, ทดสอบผ่าน `JSON.parse` จริง)**:
     args เป็น `bash -c` script เดียว — **`tr '\\' '/'` normalize `$CLAUDE_PROJECT_DIR`
     เป็น forward-slash ก่อน exec ตัว docs-drift.sh** แทนที่จะพึ่ง cygpath/perl/
     absolute-path ใด ๆ: `P=$(printf '%s' "$CLAUDE_PROJECT_DIR" | tr '\\' '/'); "$P/.claude/hooks/docs-drift.sh" <Event>`
     — `tr` เป็น POSIX utility พื้นฐานมีทุก bash (รวม WSL), เป็น no-op บน unix
     (ไม่มี backslash ให้แปลงอยู่แล้ว) ไม่ต้อง localize ต่อเครื่องอีกเลย
     (`init.sh` กลับไปเป็น `cp` ธรรมดา) — **เครดิต: user เป็นคนเจอทิศทางนี้เอง**
     (ทดลองหลายรอบ; เวอร์ชันแรกที่ส่งมาเป็น debug step ที่ `echo` path เฉย ๆ
     ไม่ได้ exec จริง — พบและแก้เป็นเวอร์ชัน exec จริงก่อน deploy)
     ทดสอบ: JSON.parse จริงผ่าน node (จำลอง harness parser) + รัน args string
     ที่ extract ออกมาตรง ๆ ผ่านของจริงบน Mek.ai ได้ JSON ถูกต้อง ไม่มี warning
  7. **macOS: "Permission denied"** — `docs-drift.sh` ถูก `chmod +x` ตอน init บน
     Windows แต่ NTFS ไม่มี POSIX execute bit ให้ track จริง → commit เข้า git จาก
     Windows แล้ว mode ที่ติดไปเป็น non-executable → macOS (POSIX filesystem จริง)
     enforce แล้วปฏิเสธ exec (จุดที่ Windows/Git Bash ไม่เคยจับได้ทั้งวัน เพราะ
     NTFS ไม่ enforce execute bit เข้มงวดเท่า — reproduce ยืนยันแล้วว่า `chmod -x`
     บนเครื่องนี้ก็ยัง exec ผ่านปกติ) → **แก้**: เรียกผ่าน `bash "$P/.../docs-drift.sh"`
     แทนที่จะ exec path ตรง ๆ — ไม่ต้องพึ่ง execute bit เลยไม่ว่า git track mode ไว้ยังไง
  - **✅ ยืนยันผ่านจริงบน macOS แล้ว** (2026-07-12, cross-platform session): SessionStart/
    TaskCompleted/PreCompact/Stop รันผ่านหมด — ปิด gap cross-platform ของวันนี้
  8. `FileChanged` ถูกตัดออกจาก wiring (dead config — ทดสอบยิงจริง 3 ช่องทางบน macOS
    เงียบทุกครั้ง แม้ documented ว่าเป็น event จริง) เหลือ 4 hooks ที่ verified:
    SessionStart/Stop/TaskCompleted/PreCompact — logic เก่ายังอยู่ใน docs-drift.sh
    เป็น dead code ที่ comment ชัดเจน (ห้ามใส่กลับ settings.json จนพิสูจน์ว่าทำงาน)
  - **⚠️ deploy checklist**: แก้ `docs-drift.sh` แล้วต้อง deploy **ทั้งสองไฟล์คู่กัน**
    (`docs-drift.sh` + `settings.json`) — เคยพลาด deploy แค่ settings.json รอบเดียว
    ตอนตัด FileChanged ทำให้ comment ใน docs-drift.sh ค้างเวอร์ชันเก่าที่ Mek.ai/FiveM
    (macOS session จับได้) แก้แล้ว 2026-07-12
  9. **`$CLAUDE_PROJECT_DIR` ว่างเปล่าในบาง session** — เจอจาก user โดยตรง (ไม่ใช่จาก
     agent): บาง session harness ไม่ set env var นี้เลย → `P` ว่างเปล่า → path ผิด
     ที่รากไดรฟ์ ("No such file or directory") ทั้งที่ `docs-drift.sh` เองมี fallback
     เป็น git root อยู่แล้ว (บรรทัด 6) แต่ **args string ใน settings.json ที่คำนวณ
     path ของตัว docs-drift.sh เอง (ก่อนจะเรียกมันได้) ไม่มี fallback นี้** — แก้ด้วย
     `${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}` ในทุก event
     ทดสอบยืนยันทั้งสองเคส (env var มีค่าปกติ / ว่างเปล่า+cwd อยู่ใน git repo) ผ่าน
     ทั้งคู่ — deploy ไปยัง Mek.ai + FiveM คู่กันทั้ง settings.json + docs-drift.sh แล้ว
  10. **root cause ตัวจริงของข้อ 9 (พบทีหลัง, agent เอง): hook execution subsystem
      ของ Claude Code รันผ่าน WSL bash (`System32\bash.exe`) เสมอ แยกจาก interactive
      Bash tool ที่ agent ใช้ (ซึ่งเป็น Git Bash/MSYS จริง — `uname -a` ยืนยัน
      `MINGW64_NT`)** — นี่คือเหตุผลที่ agent จำลอง/ทดสอบ fix ด้วย Bash tool ของตัวเอง
      ผ่านตลอด (100% pass ทุกรอบ) แต่ hook จริงยังพังซ้ำอยู่: **Bash tool ไม่ใช่
      test bed ที่แทนพฤติกรรม hook runner จริงได้** — ต้องยืนยันด้วยการ restart
      session จริงเท่านั้น ห้ามเชื่อผลจาก Bash tool simulation ว่า "fix แล้ว"
      แม้ agent เอง `env` เห็น `WSL_DISTRO_NAME` ว่างเปล่า (เพราะนั่นคือ env ของ
      Bash tool ไม่ใช่ของ hook subsystem) — จุดสับสนที่ทำให้ debug วนหลายรอบ
      (2026-07-13, เครดิต: user ชี้ต้นตอ "คุณอยู่ใน wsl ครับ" ตรงเป้า)
  11. `env.CLAUDE_CODE_GIT_BASH_PATH` ใน `settings.local.json` (ต่อเครื่อง,
      gitignored) — **ก็ไม่ได้ผลเช่นกัน**: deploy แล้ว Stop hook ยัง "No such file
      or directory" ซ้ำ ยืนยันว่า var นี้ไม่ถูกอ่านโดย hook-spawn path เลย (ไม่ว่า
      จะตั้งที่ settings.json ระดับ repo หรือ settings.local.json ระดับเครื่อง)
      → เลิกใช้แนวทาง env var pin ทั้งหมด
  12. **fix จริงที่ user ทดสอบผ่านการ restart session จริงแล้ว (2026-07-13,
      "สเถียรสุดครับ")** — โครงสุดท้ายที่ deploy อยู่ตอนนี้ (kit + ทุก repo):
      `args: ["-c", "bash $(git rev-parse --show-toplevel 2>/dev/null | sed 's/\\\\/\\//g')/.claude/hooks/docs-drift.sh <Event>"]`
      — ยังผ่าน `-c` แต่ **event name ถูก bake เข้า string เดียวกับ `bash <path>`**
      (ไม่แยกเป็น `args[1]` ต่างหากแบบที่เคยลองก่อนหน้า) และเรียก `bash` explicit
      ซ้ำอีกชั้นข้างใน `-c` (ไม่ exec path ตรง ๆ) — ตัด `${CLAUDE_PROJECT_DIR}` ทิ้ง
      ทั้งระบบแล้ว (ทั้ง args string และ `docs-drift.sh` เองบรรทัด 9 ใช้
      `git rev-parse --show-toplevel` ล้วน ๆ, ไม่มี env var คั่นกลางอีกต่อไป)
      — ยังไม่มีคำอธิบายกลไกแน่ชัดว่าทำไมรูปแบบนี้ทำให้ WSL bash subsystem resolve
      ได้ต่างจากที่เคยลอง (ตั้งสมมติฐานไว้: hook runner ของ WSL bash อาจ evaluate
      `$(...)` ต่างกันขึ้นกับว่าอยู่ใน args เดี่ยว ๆ หรือฝังใน `-c` string) —
      **ไม่ต้องรู้กลไกก็ deploy ได้เพราะยืนยันผลจริงแล้ว** แต่ควรพิสูจน์เพิ่มถ้ามีเวลา
      — ⚠️ ถ้าเจอ args แบบอื่นในเอกสารเก่า (เช่น draft ก่อนหน้าที่ไม่มี `-c`) =
      ล้าสมัยแล้ว ให้ยึดตามนี้/ยึดตามไฟล์ settings.json จริงเป็นหลัก

## TODO
- **`claude -p` = fresh-session test bed** (พิสูจน์แล้ว 2026-07-16): verify การเปลี่ยน
      rule/agent/behavior ได้โดยไม่ต้อง restart — subagent ใช้ไม่ได้ (สืบทอด context ค้าง).
      on-demand (skill) + SCC ใหม่ ยืนยันผ่าน -p แล้ว.
      **`claude -p` รันเป็น agent จาก settings.json** (`--agent` override ได้) · **ยิงขนานได้**
      (scenario อิสระ → ยิงพร้อมกัน parse ทีหลัง, 87s vs 15-18min) · วัด ground truth ด้วย
      `--output-format stream-json` ดู `tool_use` จริง ไม่ใช่ self-report+grep. ⚠️ **ห้ามแก้ script
      ที่ process กำลังรัน** (bash อ่าน incremental → ปนเวอร์ชัน crash — เจอจริง 2026-07-16).
      🔴 **`claude -p` ไม่ยิง Stop hook** (verified 2026-07-16 ด้วย debug marker — ยิง -p แล้ว
      hook ไม่ถูกเรียก) → -p เป็น test bed ของ **rules/skills/agent เท่านั้น ไม่ใช่ hook**;
      hook ต้อง real interactive session
- **acv-gate: ยกเลิกทั้งโครงการ (2026-07-17, คำสั่ง owner)** — ถอดออกจาก kit template แล้ว
      (`acv-gate.sh` + `settings.local.json` + wiring ใน `init.sh` + section ใน `claude/skills/docs/setup/kit/README.md`);
      เหตุผล + วิธีกู้จาก git อยู่ใน `claude/skills/docs/setup/kit/README.md` §acv-gate. TODO เดิม 2 ข้อ (live-fire
      ด้วย session จริง / deploy ไปรีโปที่ setup แล้ว) = **ตายไปกับ decision นี้ ไม่ใช่ค้าง**.
      ⚠️ **known gap ที่เหลือ**: ACV protocol พึ่ง SCC prompt ล้วน ไม่มีระบบบังคับ —
      ถ้า compliance ตกจาก 64% ให้ revisit ด้วย "ACV เวอร์ชันเบา" ก่อน hard gate (ดู TODO insight ข้อ 4)
- **verify-nudge (2026-07-17, ทดสอบสมมติฐาน salience)**: วิเคราะห์แล้ว agent ไม่มีกลไก
      รับรู้ราคา + repo อื่นไม่โหลด CLAUDE.md นี้ → การเลี่ยง ACV 89% น่าจะเกิดจาก mandate
      จมใน context (อ่านครั้งเดียวตอน start) ไม่ใช่ "เลือกข้ามเพราะแพง" → เพิ่ม **generic
      verify reminder** ใน kit `docs-drift.sh` Stop hook (เตือนเมื่อมี source change ค้าง,
      dedup ต่อ hash; **ไม่ mention กลไกตรวจตัวใดตัวหนึ่ง** — คำสั่ง owner) + TaskCompleted
      ข้อ (4). deploy แล้ว 9 repos (script เท่านั้น settings.json ไม่เปลี่ยน). **วัดผล**:
      ACV/self-verify rate ใน edit-session ควรขึ้นจาก 11% ใน lookback รอบหน้า —
      ถ้าขึ้น = salience คือตัวขับ, ถ้าไม่ขึ้น = ต้องดู enforcement
- **rules เพดาน ~400: แก้แล้ว 2026-07-16** — ย้าย ui-ux/data-design เป็น skill (webhook
      ทดลองย้ายแล้ว **revert กลับ always-on** — ดู taxonomy ใน Inventory) →
      `cat claude/rules/*.md | wc -l` ใต้ 400 โดยไม่หด content. candidate ค้าง: webhook↔data-design
      เนื้อทับ (queue/retry/idempotent) — dedup ไว้ที่เดียวแล้ว reference? (รอเจอปัญหาจริงก่อน)
- [ ] **insight ที่ยัง surface ไม่ครบ (จาก session 2026-07-15 — รอ recap):**
      (1) ops คือภาระจริง (ssh 1,154·docker exec 83) → skill remote-ops อาจคุ้มกว่า enforcement
      (2) `find-skills` ถูกเรียก 54 ครั้งแต่ไม่มีจริง — บั๊กแก้ง่าย
      (3) Windows path tax: MSYS_NO_PATHCONV 622·cd prepend 7,722
      (4) **ACV แพง 6นาที/213k → 79% เลี่ยงอาจเป็นสัญญาณราคา ไม่ใช่วินัยหย่อน → ควรมี ACV เวอร์ชันเบา?**
      (5) ระบบ (2 agent+15 rule+kit+hooks) โตเข้าใกล้จุดดูแลเองไม่ไหว — over-engineer ระดับทั้งระบบ?
      (6) user ต้องคอยจับ confound เอง 6 ครั้ง = verification ยังถูกผลักมาที่ user —
      หลักฐานเพิ่ม (ขุด 07-17): hook saga 07-13 user เป็นคน (ก) จับ claim เท็จ "cross-platform
      ได้จริงหรอ→ไม่ได้จริงใช่ไหม" (ข) แก้เองสำเร็จ 06:37 (ค) เจอทิศ root cause เอง 08:49
      (ง) สั่งเปลี่ยนกติกา verify เอง 09:20 "debug รอบหน้า แนะนำให้ใช้ feedback จริงจากผมนะครับ"
      → กติกา verify-via-restart (809d32e) มาจาก user หมดอดทน ไม่ใช่ agent เรียนรู้เอง;
      **signal metric ใหม่: "user takeover"** (ผมขอตัดสินใจ/ผมลองแก้เอง/ผมรู้แล้ว) = ตัววัด
      ความเชื่อถือพังที่แรงกว่า corrective rate — **วัดแล้ว (07-17, 2-pass: 8-cat classifier
      ชี้ 55 candidates → Fable-judge ยืนยัน): trust-loss จริง ~13 เคส/เดือน, 7 เคส (>50%)
      อยู่วัน hook saga 07-13 เพียงวันเดียว** = metric ยิงตรงเหตุการณ์ที่รู้ว่า trust พังจริง;
      ที่เหลือเป็น cooperation (login/bypass/token ที่ user เท่านั้นทำได้) อย่านับปน.
      สัญญาณคู่กัน: agent-concession ("คุณถูก/ผมผิด") WORK-only 0.64/100 asst-turn,
      เพิ่มเป็น 1.3-1.7 หลัง cutover ขณะ corrective ฝั่ง user ลด = สารภาพบ่อยขึ้น ไม่ใช่ผิดบ่อยขึ้น
- [ ] **SCC รอบสาม (candidate — แผลซ้ำครบ 2 แล้ว, รอหน้าต่างวัด cutover-2 จบ ~2026-08-01)**:
      **testable-claim discipline** — claim ที่ทดสอบ/ค้นได้ ต้องมีการทดสอบ/ค้นเบื้องหลังก่อนพูด
      ไม่งั้นพูดว่า "ยังไม่ได้ตรวจ":
      - แผล 1: tenant-type enum — "ครบทุก/path หลักครอบแล้ว" ไม่มี search เบื้องหลัง (ดู docs/dogfood-audit)
      - แผล 2 (2026-07-17, client backend session ace13c86, self-audit ท้าย session): ประกาศ
        "ต่อแล้วพังทันที/ต้องแก้โค้ด" ทั้งที่หักล้างได้ด้วย curl 5 วิ (ได้ SC-0000 ตอน user เบรก);
        root cause ร่วม: (ก) เชื่อ*ชื่อ* (`a Guid-suffixed field`) มากกว่า*ชนิด+การใช้จริง* (string+concat)
        (ข) เชื่อ docs ที่ตัวเองเขียนเมื่อวานเป็น fact — precedent amplification เวอร์ชันเอกสาร
        (ค) ไม่ถาม "config/env/data แก้ได้ไหม" ก่อนออกแบบโค้ด (bias toward building)
      - ร่างถ้อยคำ (trigger→action): ① ก่อนพูด claim เชิง "จะพัง/ต้องแก้/ครบแล้ว/ไม่มีที่อื่น" →
        รันการทดสอบ/ค้นที่ถูกที่สุดที่หักล้างได้ หรือประกาศว่ายังไม่ได้ตรวจ ② ก่อนเสนอแก้โค้ด →
        ตอบก่อนว่า "config/env/data ที่มีอยู่พอไหม" ③ docs ที่ agent เขียนเอง = ข้อสังเกต
        ไม่ใช่ fact ชั้น runtime (ผูกกับลำดับหลักฐาน §4) ④ loop-breaker: แก้อาการเดิม
        รอบที่ 3 โดยการวัดยัง "ผ่านแต่ใช้จริงพัง" → หยุดแก้ ตั้งคำถามกับ*ช่องทางวัด*ก่อน
        (หลักฐาน: hook saga 07-13 — settings.json 9 fixes/4 ชม., commit msg ไต่ระดับความมั่นใจ
        "for real this time"→"root cause"→"saga closed" แล้วพังต่อ; loop จบทันทีที่เปลี่ยน
        กติกา verify เป็น real restart ไม่ใช่ตอน fix เก่งขึ้น) ⑤ claim เชิงสาเหตุจาก aggregate →
        ต้องเปิด raw case ดูก่อน (แผล 3: ctx-sweep 07-17 เล่าเรื่องผิดจนถูก user ทัก)
      - **หลักฐานเชิงกลไกของสมมติฐาน trigger→action (จาก "report" miss 07-17):** calibrated-action
        list ตัวอย่างกำกวมเฉพาะ class "target" (repo/branch/ไฟล์) → เจอกำกวม class "form ของ
        deliverable" (กราฟ vs เรียงความ) trigger ไม่ยิง เดาโดยไม่รู้ตัวว่าเดา → ตอนยิงรอบสาม
        เพิ่ม "รูปแบบ deliverable" เข้า list ตัวอย่างของ calibrated-action ด้วย (หนึ่งวลี)
        + บทเรียน: trigger rule แม่นเฉพาะ class ที่ enumerate — tail ที่ไม่ list = จุดบอดโดยดีไซน์
      **อย่าแก้จนรอบ1-2 เห็นผลเต็ม** ไม่งั้นแยกไม่ออกว่าอันไหนได้ผล
- **a11y/focus baseline (F1): แก้แล้ว 2026-07-16** — ใส่ใน skill `ui-ux-baseline`
      (focus-visible/keyboard/button-not-div/ARIA) ตอน migrate เป็น skill
- [ ] **"หมายถึง" = scope/target misread signal** (~1% ของ user turn, 60% เป็นการแก้
      เจตนา) — failure mode: assistant ขยายเป็น action plan กว้าง/จับผิดเป้า ก่อนยืนยัน scope;
      candidate: SCC ยืนยันเป้าหนึ่งประโยคก่อนเสนอแผน (เมื่อ scope กำกวม/หลายเป้า) — รอบสามเช่นกัน
- [ ] เข้าใจกลไกจริงว่าทำไม args แบบ direct-path (ข้อ 12) แก้ปัญหา WSL hook spawn
      ได้ ในเมื่อ `bash -c` wrapper (ข้อ 6) ก็ใช้ syntax เดียวกันแต่พังต่างกัน —
      ยังเป็นการแก้แบบ empirical ไม่ใช่ root-cause fix ที่เข้าใจครบ
- [ ] เครื่องอื่น: clone + install + `/docs:setup` ต่อ repo
