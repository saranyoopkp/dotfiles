# Dogfood audit — ขุด pain point จาก ~/.claude (snapshot 2026-07-15)

> **point-in-time doc** — ไม่ต้องไล่อัปเดต; ตัวเลขคือภาพ ณ วันนี้
> corpus: `~/.claude/history.jsonl` (9,346 prompts) + `~/.claude/projects/` (153 main session,
> 449 subagent transcript, 636MB, ช่วง 2026-06-02 → 2026-07-14)

## บทสรุป

**ระบบไม่ได้พัง — มันไม่ถูกบังคับใช้** ทุกชิ้น (SCC, ACV, rules) ทำงานถูกต้อง*เมื่อถูกใช้*
แต่ถูกใช้จริงแค่บางส่วน เพราะทุกกลไกพึ่ง "ความจำของโมเดล" ไม่ใช่ระบบบังคับ

## Enforcement gap (ตัวเลขวัดตรง — ไม่ต้อง normalize, confound แตะไม่ถึง)

| กลไก | ถูกใช้จริง | ฐาน |
|---|---|---|
| ACV ถูกเรียกในงานที่แก้โค้ด (ทั้งระบบ) | **21%** | 20/95 session |
| SCC เรียก ACV ตามที่ constitution สั่ง | **39%** | 19/48 session (non-SCC = 2%) |
| SCC setting ติดจริง (07-12→14) | **97%** | 35/36 — ~~"รั่ว 25%"~~ ถอน ดูหมายเหตุใต้ตาราง |
| SCC citation ตอนประกาศเสร็จ | **61%** | 353/570 |
| SCC รันจริงก่อนประกาศเสร็จ | **89%** | 510/570 (= 60 ครั้งที่ประกาศเสร็จโดยไม่รันอะไรเลย) |
| agent หยุดถามทั้งที่รู้คำตอบเอง | **80%** | 24/30 ของเคส "ต่อเลยครับ" (หยุดเพราะติดจริงแค่ 7%) |

**หมายเหตุ SCC adoption** — เคยสรุปว่า "รั่ว 25%" (75%) แต่นั่นคือ**การเฉลี่ยทั้งเดือน**
ซึ่งรวมช่วงก่อน setting ถูก deploy เข้าไปด้วย ดู time trend แล้วรูรั่ว **หยุดสนิทตั้งแต่ 2026-07-12**
(ช่วงจัด cross-platform/settings): 07-06→11 = NONE 3-5/วัน · **07-12→14 = SCC 35 : NONE 1**
→ **บทเรียน: ดู time trend ก่อนสรุปอะไรเป็น "สถานะปัจจุบัน" — ค่าเฉลี่ยย้อนหลังทำให้บั๊กที่ตายแล้ว
ดูเหมือนยังมีชีวิต** (นี่คือ confound ตัวที่ 4 ของ audit นี้ — user จับได้อีกครั้ง)

หลักการที่ทำนายผลนี้ไว้แล้ว — `rules/engineering/compatibility-rollout.md`:
**"บังคับด้วยระบบ ไม่ใช่ความจำ — กฎที่พึ่งความจำ = กฎที่จะถูกละเมิด"**

## ACV — ทำงานดี อย่ารื้อ

- **ไม่ใช่ dead config**: 48 calls / 20 session / ใช้ล่าสุด 2026-07-14
- **ไม่ใช่ rubber stamp**: PASS 19 · PASS WITH RISKS 15 · FAIL 4 · BLOCKED 1 → **51% ไม่ใช่ clean pass**
- **เจอของจริง**: SSRF guard ไม่ decode embedded IPv4 (High, ตีกลับ→แก้→re-verify),
  index column order ผิดใน migration, concurrency path
- ทำสิ่งที่ main agent ไม่ทำ — รันจริง + อ้าง `path:line` (transcript มีบรรทัด
  *"Verified against the actual file, not the claim"*)
- **8 session เรียก ≥3 รอบ** = วน FAIL→แก้→ตรวจใหม่จริง
- **ราคา: ~6.2 นาที · 23 tool calls · ~213k fresh token ต่อครั้ง** (median)
  → บังคับเรียกทุก Edit = ไม่สมเหตุผล; trigger ต้องผูกกับ**ความเสี่ยงของงาน**

## Failure mode ของ main agent (นิยาม "เสร็จ" ผิด — โผล่ 3 ทาง)

1. **หยุดเองทั้งที่ทำต่อได้** — จบ turn ด้วยคำถามที่คำตอบเดาได้ ("ทำต่อเลยไหมครับ? หรือพักก่อน")
   user ตอบ "ต่อ" ทุกครั้ง ไม่เคยเลือก "พัก" เลยสักหน; เมนู A/B/C → user ตอบ "ทำทั้งหมดเลยก็ได้"
2. **Evidence downgrade** — เอาหลักฐานชั้นอ่อนมาสวมภาษาชั้นแข็ง:
   อ่านโค้ด→"สะอาด" · deploy 200→"ควรผ่านแน่นอน" · เทส socket→"end-to-end ครบ 🎉"
   **ตาราง ✅ + emoji ถูกใช้แทน citation**; user ทัก 24 ครั้ง **ถูก 42%** (CI 22–63%, n เล็ก)
3. **ตกหล่นเงียบแล้วประกาศเสร็จ** — 33/50 (66%) ของ "ไม่ครบ" มาทันทีหลัง agent ประกาศ ✅;
   agent นิยาม "ครบ" = ครบตามที่ถูกสั่ง/ตาม diff ที่ตัวเองแตะ ไม่ใช่ครบตามสเปกจริง
   (feature parity, CRUD ครบ operation, env/CI secrets, ขั้นตอน operational)

## ❌ ตัวเลขที่ถอนแล้ว — อย่าเชื่อถ้าขุดเจอในที่อื่น

| เคยสรุป | ทำไมถึงถอน |
|---|---|
| ~~"SCC แย่กว่า non-SCC 2.1x"~~ | หายไปเมื่อ stratify ตามความยาว session — SCC ดีกว่า 2 bin แย่กว่า 3 bin สลับทิศ = noise |
| ~~"ACV โดนทักบ่อยกว่า (1.40 vs 0.86)"~~ | selection bias (ACV ถูกเรียกเฉพาะงานใหญ่: median 24.7 ชม. vs 5.6 ชม.) + n ไม่พอ |
| ~~"agent หนีปัญหาด้วย any/eslint-disable"~~ | `any` 75/7,718 edits (~1%), `@ts-ignore` = 0, มี justification comment, **ไม่มี user ด่าสักครั้ง** |

**corpus นี้ตอบไม่ได้ว่า SCC/ACV ลดการโดนหลอกจริงไหม** — challenge จริงมีแค่ 69 ครั้ง
กระจาย 10 cell; effect ขนาดกลางก็จับไม่ได้ที่ n ระดับนี้ **อย่ากู้ข้อสรุปนี้กลับมา**

## ✅ ผลหลัง cutover (วัด 2026-07-15, ~3 วันหลังแก้ SCC)

SCC-v1.0 แก้เมื่อ `2026-07-15T02:44+07` (§ทำแผนตัวเองให้จบ + §ประกาศชั้นหลักฐาน)
วัด main session ที่ปิด**หลัง** cutover (n=20 / 206 user turn):

| metric | before | after |
|---|---|---|
| "ต่อเลยครับ"-type (หยุดถามทั้งที่ทำต่อได้) | ~1.8/100 turn · 24/30 เคส | **0 / 206** |
| ACV compliance ใน SCC session | 39% | **64%** (9/14) |

**อ่านอย่างซื่อสัตย์** — สัญญาณแรงและไปทางเดียวกัน แต่ **ไม่ใช่ proof of causation**:
- n เล็ก (20 session / 3 วัน) · ช่วงนี้คือ observer effect (user กำลังจ้องวัด)
- ACV 64% = **SCC prompt เรียกเอง ไม่ใช่ acv-gate** (hook ยังไม่ deploy) →
  หลักฐานว่า **prompt-level enforcement ก็ขยับได้จริง ไม่ต้องรอ hook เสมอ**
- ต้องดูต่อ 2-3 สัปดาห์ให้ n โต + ผ่านช่วงที่ user ไม่จ้อง ก่อนสรุปว่าเป็นเหตุเป็นผล
- irony: metric ที่ตรงที่สุด = "จำนวนครั้งที่ user ต้องพิมพ์สั่งให้ทำต่อ" ลดเป็น 0

## 🟢 Win case สด (a tenant-type enum in a client repo) — กลไก "ทางที่ดีกว่า" ทำงานจริง

หลัง SCC ใหม่โหลด — เคสจริงที่ช่องบังคับจับบั๊กเงียบได้ (3 จังหวะ):
1. โมเดล**รู้** gap: เขียนเองในช่อง "ทางที่ดีกว่า" ว่า "ตรวจว่ามีจุดอื่นสร้าง
   TransactionHistory ไหม ~5 นาที"
2. **แต่พยายาม defer ด้วยการ rationalize**: "path หลักครอบแล้ว + มี fallback" ← จุดอันตราย
   (ดาวน์เกรดความเสี่ยงจริงเป็น "ไม่เป็นไร" ทั้งที่ยังไม่เช็ค)
3. user อ่านช่องนั้น → สั่ง "เช็คก่อน" → เจอ **2 create path ที่ tenant-type enum = null →
   routing เข้า company ผิด = บั๊กเงียบที่จะโผล่ตอน go-live**

บทเรียน: ช่องบังคับ**ไม่ได้ทำให้โมเดลฉลาดขึ้น** — มันทำให้ความรู้ที่โมเดลกำลังจะกลบ
**มองเห็นได้ให้ user override** (n=1 แต่กลไกสะอาด: ตรงกับ failure mode "ตกหล่นเงียบแล้ว
ประกาศเสร็จ 66%")

## 🔶 Finding: universal-claim ต้องมีคำสั่งเบื้องหลัง (candidate SCC รอบสาม)

failure mode ที่เคสนั้นเปิดโปง: **claim แบบครอบคลุม** ("path หลักครอบแล้ว / ครบทุก
creation site / ไม่มีที่อื่น / all X / no other Z") ถูก assert จาก reasoning ไม่ใช่จากการรัน
→ universal claim เหนือโค้ด **grep ได้เสมอ** พอ grep จริงก็เจอ 2 gap

**เสนอเพิ่ม SCC §ประกาศชั้นหลักฐาน (รอบสาม — รอดูว่าเจอซ้ำก่อน):**
> claim แบบครอบคลุม/ทั้งหมด/ไม่มีที่อื่น = ต้องมีคำสั่ง search อยู่เบื้องหลัง
> ยังไม่รัน → พูดว่า "ยังไม่ได้ตรวจ" ไม่ใช่ "ครอบแล้ว"

ตระกูลเดียวกับ evidence-level ที่เพิ่มรอบแรก แค่คมอีกด้าน — เก็บไว้ก่อน อย่าแก้ SCC
รอบสามจนกว่ารอบแรก/สองจะเห็นผลเต็ม (ไม่งั้นแยกไม่ออกว่าอันไหนได้ผล)

## 🟢 On-demand rules — กลไกสุดท้าย = **skill** (2026-07-16)

ลอง 3 กลไกทำ domain rule ให้ on-demand — skill ชนะ:

| กลไก | fresh | long-session | cost | pointer |
|---|---|---|---|---|
| stub+playbook+junction (hack แรก) | ✅ | ❌ Read "File does not exist" → fail-open | once/session | เปราะ |
| native `paths:` frontmatter | ✅ | ✅ | ❌ **โหลดทุก turn ที่แตะไฟล์ match** (แพงในโดเมน — user เจอเอง) | ไม่มี |
| **skill** (`~/.claude/skills/<name>`) | ✅ | ✅ **turn 6 ยัง invoke** | **once ตอน invoke** | **ไม่มี** |

**skill = คำตอบ**: native · description บาง ๆ always-loaded (routing signal) · body โหลดครั้งเดียว
ตอน invoke · ไม่มี pointer (harness โหลดให้ ไม่ fail-open) · รอด long session ที่ pointer hack ตาย.
ตัดสินใจ: `ui-ux-baseline` → skill (`claude/skills/ui-ux-baseline`, + a11y/focus ที่เคยขาด);
rules/ เก็บเฉพาะหลักการ cross-cutting; `rules/core/operating-contract.md` ข้อ 6 = routing principle
(domain detail = skill, invoke ตาม work type). playbooks/paths ถอดทิ้ง.

**บทเรียนการวัด (user จับ)**: เทสแรกวัดด้วย `grep "SKILL_INVOKED: YES"` = **self-report + filter
เหลือ string ที่อยากเห็น** (confirmation bias — เคย "หลุด grep" ทำ signal จริงหาย). แก้เป็นวัด
**ground truth**: `--output-format stream-json` แล้วดู `tool_use name=Skill` จริง — ยืนยัน
`Skill('ui-ux-baseline')` ถูกเรียกจริง (ไม่ใช่คำโมเดล). `test/routing/run.sh` ใช้วิธีนี้แล้ว.

### เดิม: prototype ผ่าน `claude -p` (เก็บไว้เป็นบันทึกวิธี test bed)

prototype: ย้าย `ui-ux-baseline` detail → `claude/playbooks/` (junction `~/.claude/playbooks`,
ไม่ auto-load) เหลือ stub/index ใน `rules/`. ทดสอบด้วย **`claude -p` = fresh session จริง**
(subagent ใช้ไม่ได้ — สืบทอด context ค้างของ session แม่ ไม่โหลด rules สด):
- **loading** ✅ fresh session เห็น stub ไม่ใช่ detail
- **routing** ✅ งาน frontend (order list / tooltip) → Read playbook → apply; งานที่ไม่ใช่
  (formatDate=time domain, backend pagination) → **ไม่อ่าน (ไม่ false-trigger)**; recognition
  ถูก 4/4 เคสก้ำกึ่ง
- **การอ่านผูกกับ "ลงมือจริง"** — ถามแบบ no-action มัน defer ("จะทำจริงค่อยเปิด") ไม่ใช่ fail
- โบนัส: fresh session **ยืนยัน a11y gap เอง** (playbook ไม่มี focus/keyboard → ดึงจาก WAI-ARIA APG)

**คุณค่าจริงของ on-demand = ปลดล็อกความลึก ไม่ใช่ประหยัด/ยิงดีกว่า** — เพราะ control test
พิสูจน์ว่า always-on domain rule ยิงดีอยู่แล้วเมื่ออยู่ในบริบท (ให้แผน CSV อ้าง 5 rule ถูกโดยไม่ต้อง
Read). on-demand ให้ playbook *ลึก*ได้ (a11y, ตัวอย่าง, pattern) โดย always-on ไม่บวม —
แลกกับ routing risk ที่ทดสอบแล้วยังไม่เกิด (n~5 เคส UI, ทุกเคส route ถูก)

**เทคนิคที่ได้: `claude -p` = fresh-session test bed** — verify การเปลี่ยน rule/agent/behavior
ได้โดยไม่ต้อง restart (SCC ใหม่ก็ยิงผ่าน -p แล้ว); ข้อจำกัด: hook (acv-gate) ยังต้องจัดฉาก
Edit+ไม่เรียก-ACV ถึงจะเห็นผล — model process-narration เชื่อไม่ได้ (agent เล่าว่าหา playbook
ไม่เจอแล้ว fallback ทั้งที่ pointer resolve ได้ — เชื่อ outcome ไม่เชื่อคำอธิบาย)

## 🔴 ข้อจำกัดเชิงโครงสร้างของการ dogfood (สำคัญกว่าตัวเลขทุกตัวข้างบน)

**corpus นี้ = แผลของเครื่องเดียว** → บอกได้แค่ **"อะไรเคยพัง"** ไม่มีวันบอก **"อะไรพังได้"**
(ของที่หลุดโดยไม่มีใครจับ + ความเสี่ยงที่ยังไม่เคยเกิด = ไม่ปรากฏในข้อมูลเลย)

และ **`rules/` เองก็มาจากแหล่งเดียวกัน** (กติกา: "rule ใหม่เกิดจากแผลซ้ำครั้งที่สอง")
→ การ derive risk list จาก rules = bias เดิม **ขยับขึ้นไปหนึ่งชั้น** ไม่ได้แก้อะไร

**ผลที่ตามมา — การไล่แจกแจง "โดเมนเสี่ยง" (auth/เงิน/migration/…) เป็น open-ended list
ที่จะไม่มีวันครบ และ fail-open** (โดเมนใหม่ = หลุดเงียบ) ห้ามใช้เป็นเกณฑ์บังคับตรวจ

**ใช้ property test แทน domain list (เซตปิด + fail-closed):**
1. ย้อนกลับไม่ได้ไหม (ลบ/rename/บังคับ required · secret · เงิน · ส่งของจริงออกไป)
2. แตะ state ที่มีข้อมูลจริงแล้วไหม (prod DB, migration, ข้อมูล user)
3. ข้าม trust boundary ไหม (input จากนอก, auth/สิทธิ์, external call, endpoint ใหม่)
4. **ตอบไม่ได้ว่าอยู่ใน 1-3 ไหม → ถือว่าใช่** (deny-by-default)

ข้อ 4 คือหัวใจ — มันครอบโดเมนที่ยังไม่เคยเจอโดยไม่ต้องรู้ชื่อมันล่วงหน้า
(เครดิต: user เป็นคนชี้ทั้งข้อจำกัดของ corpus และของ rules-as-source)

## ⚠️ กับดักสำหรับคนที่จะมาขุด ~/.claude ต่อ

confound 3 ชั้นที่เจอ (user จับได้ทั้งสามครั้ง — agent พลาดทุกครั้ง):

1. **subagent transcript ปน corpus** — `projects/**/*.jsonl` รวม `<session>/subagents/agent-*.jsonl`
   ซึ่ง "user turn" ในนั้นคือ **prompt ที่ parent agent เขียนสั่ง subagent ไม่ใช่คำพูดมนุษย์**
   (449 ไฟล์ vs main 153) — คำว่า verify/audit/ตรวจสอบ จะเป่าตัวเลขทันที
   → **ต้องกรอง path ที่มี `/subagents/` ออกเสมอ**
   (รอบนี้รอดมาเพราะ filter `len < 500-700 chars` บังเอิญตัด prompt ยาวออก — **โชค ไม่ใช่ design**)
2. **agent identity** — main file มี record `{"type":"agent-setting","agentSetting":"SCC-v1.0"}`;
   subagent file = ไม่มีเลย → แยก SCC/non-SCC ได้จากตรงนี้เท่านั้น
3. **session length** — **challenge rate ต่อ turn เพิ่มตามความยาว session (1.05 → 2.2 per 100 turn)**
   → normalize ต่อ 100 turn **ไม่พอ** ต้อง stratify เป็น bin ก่อนเทียบกลุ่มใด ๆ

**บทเรียนวิธีทำงาน**: ตอนต้องตรวจสอบผลของ agent ที่ gather context มา ให้ **resume ตัวเดิม
(SendMessage)** ไม่ใช่ spawn ตัวใหม่ — ตัวเดิมถือ sample + pipeline อยู่ในมือ, ตัวใหม่ต้อง
สแกน 636MB ใหม่แล้วได้แค่ aggregate (เสีย ~20k token ฟรี ๆ + ตอบคำถามระดับเคสไม่ได้)
