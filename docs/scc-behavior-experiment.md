# SCC behavior experiment — cutovers, ผลวัด, ร่างรอบถัดไป (living doc ของโปรแกรมวัดผล)

บ้านเดียวของทุกอย่างเกี่ยวกับการเปลี่ยน/วัดพฤติกรรม SCC — CLAUDE.md ถือแค่ timestamps
+ สถานะล่าสุด. เครื่องมือวัด: `test/metrics/` (วิธีใช้ใน README ที่นั่น). ตัวเลข
enforcement baseline ดั้งเดิม: `docs/dogfood-audit-2026-07-15.md` (snapshot)

## Cutover markers

```
cutover-1: 2026-07-15T02:44+07:00  · SCC 539 → 580 (ทำแผนให้จบ + ประกาศชั้นหลักฐาน)
cutover-2: 2026-07-16T16:10+07:00  · SCC 580 → 617 (calibrated-action + record-before-done)
cutover-3: 2026-07-17T20:55+07:00  · SCC 617 → 626 (form-ambiguity + assumption-declare)
cutover-4: 2026-07-26T00:53+07:00  · SCC 471 → 401 (responsibility boundary + trigger/action compact)
cutover-5: 2026-07-27T22:29+07:00  · SCC 401 → 422 (objective continuity + detour resume + deferred suppression)
cutover-6: 2026-07-31T23:47+07:00  · SCC 423 → 425 (parent deliverable + child prerequisite + load-test routing)
cutover-7: 2026-08-24T16:22+07:00  · lean-beta-0.0.1 · SCC 427 → 87, ACV 342 → 83
  (ยุบ incident/domain prose เป็น behavioral + acceptance kernel; decision regression 12/12 ทั้งก่อนและหลัง)
```
กติกาวัด: session ปิดก่อนเส้น = before, หลัง = after, คร่อมเส้น = ตัดทิ้ง (SCC โหลดตอน
session start เท่านั้น) · main session เท่านั้น (กรอง subagents/Temp/`-p`) · ดู time trend
ไม่ใช่ค่าเฉลี่ยรวม · **corpus ต้อง dedup ก่อนเสมอ** (rewind/edit สร้าง sibling ผี ~9%
bias เข้า corrective — extract_turns.py จัดการแล้ว)

## สมมติฐานหลักที่ทดสอบอยู่

**"กฎ trigger→action ได้ผลกว่าหลักการลอย ๆ"** — หลักฐานสนับสนุนสะสม:
- cutover-1 ("ต่อเลยครับ" 80% ของเคสถามทั้งที่รู้): ลด 1.9→0.0-0.8/100t และคงอยู่ ✅
- หลักฐานเชิงกลไกจาก report-miss 07-17: trigger list เฉพาะ class "target" → เจอกำกวม
  class "form" trigger ไม่ยิง = **trigger rule แม่นเฉพาะ class ที่ enumerate,
  tail ที่ไม่ list คือจุดบอดโดยดีไซน์** (จึงเกิด cutover-3)

## เนื้อหาแต่ละ cutover

**cutover-1**: *ทำแผนของตัวเองให้จบ* (ห้ามถามคำถามที่รู้คำตอบเอง / ห้ามเสนอ "หรือพักก่อน" /
ห้ามยื่นเมนู A/B/C ถ้าทำได้ทั้งหมด) + *ประกาศชั้นของหลักฐาน* ("เสร็จ/พร้อมใช้" เฉพาะมี
หลักฐาน runtime; ตาราง ✅/emoji ไม่ใช่ citation) — เขียนแบบ trigger→action

**cutover-2** (จาก "ไม่" pain audit, 345 corrective turns): calibrated-action
(จับผิดเป้า 70 / ตกหล่น 64 / ทำเกิน 28 = ลงมือก่อนเช็ค) + record-before-done
(status stale = โกหก session หน้า). วัด: corrective + docs drift ควรลด.

**cutover-3** (แก้ก่อนกำหนด — owner สั่ง 07-17 "มีผลกระทบกับการทำงานจริง"): สมมติฐาน
owner = เลิกถามแล้วตัด function "ถามเพื่อเข้าใจ intent" ไปด้วย. หลักฐานสนับสนุน (ไม่ใช่
proof): corr_target 07-17 = 6.5/100t สูงสุดของเดือน (median ~3.4) + approve ต่ำสุด
วันเดียวกัน + concession ขึ้น + เคส report-miss จริง. แก้: (ก) ตัวอย่างกำกวมรวม form
ของ deliverable (ข) ไม่ถาม ≠ เดาเงียบ → ประกาศความเข้าใจหนึ่งบรรทัดแล้วทำต่อ.
วัด: corr_target ลงโดย approve ไม่เด้งกลับขึ้น.

**cutover-5** (owner สั่งหลัง retro Claude sessions 4 ตัว: `f1d10083`, `caf674d7`,
`a3fffd4a`, `de808299`): พบวงจร agent เสนอ adjacent work ทุก turn → user ถามตาม →
agent ถือว่า objective เปลี่ยน → งานเดิมต้องถูกดึงกลับ. แก้สามชั้น:

- rule: คำถาม/ข้อสังเกตเป็น detour โดย default; explicit ordering จึง switch; known/deferred
  ห้าม reopen; incident interrupt ได้แต่ต้องเก็บ resume point
- SCC: trigger/action สำหรับ detour, resume, dependency classification และ current-slice-first
- proposal/docs: ถอด footer บังคับ, adjacent park หลังส่งมอบ, pre-existing doc debt ไม่กลายเป็น
 คำถามก่อนปิดงาน

**ต้องรักษา:** การขุด root cause/dependency ที่จำเป็นต่อ outcome เดิม เช่น Cognito flow,
MythicArmors offline CLI และ incident recovery ไม่ถูกนับเป็น drift.

**สัญญาณวัดหลัง cutover-5:** แยก WORK session แล้วตรวจ (1) user ต้องพูด “กลับมาที่…”,
“scope แค่…” หรือ “ไว้ก่อน/รอบหน้า” เพื่อดึงงานกลับกี่ครั้ง (2) agent reopen เรื่องเดิมหลัง
explicit defer หรือไม่ (3) หลัง detour มี resume point/current objective ถูกส่งมอบหรือหาย
(4) blocking dependency ยังถูก surface. Regex เป็น candidate finder เท่านั้น ต้องเปิด raw turn
ตัดสิน เพราะข้อความเดียวกันอาจเป็น user-led switch ที่ถูกต้อง.

**Immediate smoke 2026-07-27 (fresh process):**
- targeted retro routing ผ่าน 3/3: session feedback, owner mapping และ objective-drift transcript
- detour scenario ผ่านด้วย SCC default model (CLI exit 0): ตอบคำถามแทรก, คง current objective,
  ระบุ resume point และไม่ยื่นเมนูให้ผู้ใช้เลือกลำดับซ้ำ
- deferred scenario สร้างคำตอบที่ mark `known/deferred` และกลับ deploy objective ถูกต้อง แต่
  CLI จบ `budget_exhausted` จาก test cap จึงเป็น behavioral observation ไม่ใช่ clean test pass

**cutover-6** (จาก session `f40c4fd7`): objective คือ load-test script ที่ครอบ matrix และสร้าง
metric แต่ prerequisite tracing ถูกยกเป็นงานหลัก, readiness ถูกนับเป็น coverage progress และ report
เข้ามาแทน executable deliverable. แก้ parent/child objective ใน rule+SCC และให้
`testing-strategy` เป็น owner ของ load-test harness; `performance` รับช่วงเมื่อวิเคราะห์ metric หรือ
เลือก optimization. สัญญาณวัด: ผู้ใช้ต้องทัก “ทำ loadtest ให้ครบ/อยากได้ script” เพื่อดึงกลับหรือไม่,
planned/runnable/measured ถูกแยกหรือไม่ และ report ยังเข้ามาแทน artifact ที่ขอหรือไม่.
Immediate smoke (fresh process): คง script เป็น primary deliverable, รายงาน deliverable 0% แยกจาก
tracing readiness ที่เสร็จ และ resume ไป enumerate matrix/สร้าง script; targeted routing ผ่าน 7/7
รวม load-test harness ที่ invoke `testing-strategy` โดยไม่ invoke `performance`.

## ผลวัดสะสม

**หน้าต่าง 3 วันหลัง cutover-1 (07-15, n=20s/206t — ช่วง observer effect):**
"ต่อเลยครับ" ~1.8/100t → 0 · ACV compliance 39% → 64%

**Lookback 07-17 (ground-truth tool_use, ตัด straddle):**
| metric | P0 ก่อน cut1 (61s/1614t) | P1 (64s/247t) | P2 หลัง cut2 (12s/125t) |
|---|---|---|---|
| "ต่อเลย/ทำต่อ"-cmd /100t | 1.9 | 0.0 | 0.8 |
| corrective regex /100t | 1.9 | 0.4 | 0.8 |
| ACV ใน edit-session | 31% | 57% | 🔴 **11%** |

**Semantic canonical (07-17, deduped, 7-cat acc 0.84):** approve ~19-20/100t ต้นเดือน
→ 8.3 (07-16) → 6.5 (07-17); corrective แกว่ง 2-14 ไม่มี step ที่ cutover-2 (07-17 ปน
meta-session). Classifier: approve/new_task P≈0.95, corrective P=0.73-0.80 (noise 20-25%
— ดู trend ได้ อย่าอ่าน absolute; GT n=100 label โดย Fable-judge ไม่ใช่ human).

**สรุปสถานะ:** cutover-1 ได้ผลและคงอยู่ (ข้าม observer window แล้ว) · cutover-2/3
รอ n โต (~08-01) · **ACV 11% = ชน tripwire** → intervention: verify-nudge (ด้านล่าง)

## Comment-discipline cutoff (2026-07-19 — วัดจาก owner report เท่านั้น)

```
comment-cutoff: 2026-07-19  · rule §ในโค้ด (71b9426→e2c6489: ≤2 บรรทัด+pointer,
docstring=contract, ขาอ่านบังคับ, ห้าม home-path)
  + SCC §ลงมือทำ "วินัยการเขียนในโค้ด" (owner สั่ง override freeze 07-19 หลังยืนยัน
    ว่า rule รอบแรกยังไม่เปลี่ยนพฤติกรรม — cutover-2/3 หลังเส้นนี้มีตัวแปรนี้ปน)
```
Baseline: owner ยืนยัน 07-19 ว่า deploy รอบแรกแล้ว "พฤติกรรม comment เยอะยังไม่เปลี่ยน"
(หนี้เดิม 499 blocks ใน repo งาน — สแกนโดย /docs:placement scan.py)
**ช่องวัด: owner ทักเรื่อง comment ใน session ใหม่หลังเส้นนี้** — ไม่ใช้ semantic classify
(เจ้าของ signal แม่นกว่าและถูกกว่า) · นับเฉพาะ session ที่เปิดหลัง cutoff (rules โหลดตอน start)
**Tripwire**: ถูกทัก ≥2 ครั้งหลัง cutoff = always-on rule ไม่พอสำหรับพฤติกรรมนี้ (สมมติฐาน
salience เดียวกับ ACV) → escalate: hook นับ comment block ใหม่ใน diff ด้วย scan.py
(deterministic, generic) หรือรอรวมกับ SCC รอบสาม — ห้ามแก้ rule ถ้อยคำวนอีกรอบ

## Verify-nudge (deploy 2026-07-17 — ทดสอบสมมติฐาน salience)

วิเคราะห์: agent ไม่มีกลไกรับรู้ราคา + repo งานไม่โหลด CLAUDE.md นี้ → การเลี่ยง ACV 89%
น่าจะเกิดจาก **mandate จมใน context** (อ่านครั้งเดียวตอน start, จุดปิดงานอยู่ไกล/หลัง
compact) ไม่ใช่ "เลือกข้ามเพราะแพง". Intervention: generic verify reminder ใน kit
docs-drift.sh Stop hook (เตือนเมื่อมี source change ค้าง, dedup ต่อ hash, **ไม่ mention
กลไกตรวจตัวใด** — คำสั่ง owner) + TaskCompleted ข้อ (4). deploy 9 repos.
**เกณฑ์ตัดสิน**: lookback รอบหน้า ACV/self-verify ใน edit-session ขึ้นจาก 11% =
salience คือตัวขับ / ไม่ขึ้น = ต้องดู enforcement.

### Follow-up guard update (2026-07-23)

เพิ่ม Intent gate และ failure-escalation ใน rule/SCC/ACV: คำถามหรือรายงานปัญหาไม่ใช่คำสั่ง
mutation; verification ที่ล้มเหลว/ถูก skip ต้องมี evidence, alternative หรือ blocker ก่อนสรุปผล.
เพิ่ม execution-tracking gate: เมื่อมี Task tools และงานหลายขั้น/หลาย turn/มี handoff หรือ blocker
ต้องสร้างและ update task จากหลักฐาน; งานคำถามหรือ read-only สั้น ๆ ไม่สร้าง checklist เพื่อพิธีกรรม.
ฝั่ง kit เพิ่ม Stop audit ที่จับ line-comment ใหม่ตั้งแต่ 2 บรรทัดใน diff แบบไม่ block เพื่อดัน
รายละเอียดไป project docs; hook ต้อง self-contained และห้ามอ้าง rule/skill ของ dotfiles.

## สัญญาณความเชื่อถือ 3 ชั้น (นิยาม + ค่าล่าสุด 07-17)

| ชั้น | นิยาม | ค่า | ทิศ |
|---|---|---|---|
| corrective (เบา) | user แก้เป้า/ทักตกหล่น/ทักทำเกิน | 2-14/100 user-turn | ทรง ๆ |
| concession (กลาง) | agent สารภาพ "คุณถูก/ผมผิด" (regex ฝั่ง asst, WORK-only) | 0.64/100 → 1.3-1.7 หลัง cutover | ขึ้น — สารภาพบ่อยขึ้นขณะ corrective ลง ไม่ใช่ผิดบ่อยขึ้น |
| **user takeover (หนัก)** | user เลิกมอบหมาย ลงมือแทน ("ผมลองแก้เอง/ผมรู้แล้ว") — วัด 2-pass: classifier ชี้ candidate → judge ยืนยัน | **13 จริง/เดือน — 7 อยู่วัน hook saga วันเดียว** | ใช้เป็น tripwire: >2/วัน = มี saga กำลังเกิด |

หมายเหตุ meta: META session (คุยเรื่อง agent เอง) เป่าตัวเลข concession 5 เท่า
(3.31 vs 0.64/100) — แยก WORK/META ก่อนอ่านเสมอ

## Insight ที่ยัง surface ไม่ครบ (จาก dogfood 07-15 + ขุดเพิ่ม 07-17)

1. ops คือภาระจริง (ssh 1,154 · docker exec 83) → skill remote-ops อาจคุ้มกว่า enforcement
2. `find-skills` ถูกเรียก 54 ครั้งแต่ไม่มีจริง — บั๊กแก้ง่าย
3. Windows path tax: MSYS_NO_PATHCONV 622 · cd prepend 7,722
4. ACV แพง 6นาที/213k → แก้ทาง verify-nudge/ACV-light (สถานะบนหัวข้อ verify-nudge)
5. ระบบ (2 agent + rules + kit + hooks + skills) โตเข้าใกล้จุดดูแลเองไม่ไหว —
   ทุก fix เพิ่มชิ้นส่วน; ถ้ารอบวัด 08-01 ไม่เห็นผลรวมดีขึ้นชัด ควรพิจารณา*ลด*กลไก
6. **verification ยังถูกผลักไปที่ user** — hook saga: user จับ claim เท็จ → แก้เองสำเร็จ →
   เจอ root cause เอง → เขียนกติกา verify ให้ (809d32e มาจาก user หมดอดทน);
   ใน session 07-17: user ทัก 6 ครั้ง = defect จริงของการวัด 6/6

## ร่าง SCC รอบสาม (candidate — ยิงหลังหน้าต่าง cutover-2/3 จบ ~2026-08-01)

**testable-claim discipline** — แผลซ้ำครบแล้ว 3:
- แผล 1: tenant-type enum — "ครบทุก/ครอบแล้ว" ไม่มี search เบื้องหลัง (dogfood-audit)
- แผล 2: client backend env-vs-code (session ace13c86 07-17) — ประกาศ "ต่อแล้วพังทันที/ต้องแก้โค้ด"
  ทั้งที่ curl 5 วิหักล้าง (SC-0000); root cause: เชื่อชื่อ (`a Guid-suffixed field`) มากกว่า
  ชนิด+การใช้จริง · เชื่อ docs ตัวเองเป็น fact · ไม่ถาม "config พอไหม" ก่อนออกแบบโค้ด
- แผล 3: ctx-sweep 07-17 — เล่า causal story จาก aggregate โดยไม่เปิด raw case จนถูกทัก

ร่างถ้อยคำ (trigger→action):
① claim "จะพัง/ต้องแก้/ครบแล้ว/ไม่มีที่อื่น" → รันการทดสอบ/ค้นที่ถูกสุดที่หักล้างได้ก่อน
  หรือประกาศว่ายังไม่ได้ตรวจ
② ก่อนเสนอแก้โค้ด → ตอบก่อนว่า "config/env/data ที่มีอยู่พอไหม"
③ docs ที่ agent เขียนเอง = ข้อสังเกต ไม่ใช่ fact ชั้น runtime
④ loop-breaker: อาการเดิมรอบ 3 + วัดยัง "ผ่านแต่ใช้จริงพัง" → หยุดแก้ ตั้งคำถามกับช่องทางวัด
  (หลักฐาน: hook saga — 9 fixes/4 ชม., commit ไต่ความมั่นใจ "for real this time"→"saga
  closed" แล้วพังต่อ; จบเมื่อเปลี่ยนช่องทางวัด)
⑤ causal claim จาก aggregate → เปิด raw case ก่อน
⑥ (จาก "หมายถึง" signal ~1% ของ user turn, 60% แก้เจตนา): scope กำกวม/หลายเป้า →
  ยืนยันเป้าหนึ่งประโยคก่อนเสนอแผน
+ เพิ่ม "รูปแบบ deliverable" ที่ทำแล้วใน cutover-3 = ปิดข้อนี้ไปแล้วบางส่วน

เดิม freeze การเปลี่ยน SCC ถึงประมาณ 2026-08-01 เพื่อแยกผลรอบ 1–3; owner override เมื่อ
2026-07-26 ให้ลด textual duplication โดยคงสามชั้น
`rule invariant → agent trigger/action → skill domain procedure`. จึงต้องอ่านผลหลัง cutover-4
เป็นชุดใหม่ ห้ามนำไปรวมกับหน้าต่างก่อนหน้าโดยไม่แยก marker.

## Draft: `claude/agents-draft/SCC-v1.0.1.md` (2026-07-20, ยังไม่ promote)

candidate ยุบ checklist ซ้ำ 4 ชุดของ SCC-v1.0 (§Identity/§หลีกเลี่ยง/§Engineering
Awareness/§การตรวจสอบตัวเอง — พูดเรื่องเดียวกันโดยไม่มี trigger→action) และตัด
§"แนวคิดในการทำงาน" (poetry ไม่มี action) — เหลือ 634→~215 บรรทัด คงทุก section
ที่มี trigger→action วัดผลจริงแล้ว (วินัยเขียนโค้ด, ทำแผนของตัวเองให้จบ,
ปรับระดับการลงมือ, ประกาศชั้นหลักฐาน, Acceptance Validation Protocol + ตาราง
verdict คู่กับ ACV). แนวคิด responsibility boundary ถูกนำมาปรับใช้บางส่วนใน cutover-4 แล้ว;
ส่วนการยุบ checklist/poetry ที่เหลือยังเป็น candidate และยังไม่ได้ deploy.
