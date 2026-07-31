# test/metrics — วัดพฤติกรรม agent จาก session corpus (`~/.claude/projects`)

มีสอง pipeline ที่มีหน้าที่ต่างกัน:

- **Trend metrics** ใช้ sample/aggregate เพื่อดู SCC cutover ตามเวลา
- **Evidence-grade retro index** สำรวจ source ครบ, เก็บ provenance และสร้าง audit unit ต่อ human turn;
  ใช้เมื่อ coverage และการเปิดกลับไปดูหลักฐานสำคัญ

| script | ทำอะไร | คำสั่ง |
|---|---|---|
| `lookback.py` | regex + tool_use ground truth: corrective-"ไม่", continue-cmd, ACV compliance ต่อ period | `python lookback.py --cuts <ts1> <ts2>` |
| `extract_turns.py` | ดึง user turns → `data/turns.jsonl` | `python extract_turns.py --since 2026-07-01` |
| `semantic_classify.py` | haiku fan-out classify 7 หมวด → `data/merged.jsonl` + `data/daily.csv` | `python semantic_classify.py [--sample 600]` |
| `eval_groundtruth.py` | สร้าง/ประเมิน ground-truth set (precision/recall) | `--make` แล้ว label มือ แล้วรันเปล่า |
| `index_transcripts.py` | สร้าง SQLite index, reconcile source/line/turn coverage และ export objective-audit queue | ดูคำสั่งด้านล่าง |
| `test_index_transcripts.py` | synthetic regression ของ schema/branch/tool-result/coverage | `python test_index_transcripts.py` |
| `prepare_audit.py` | สร้าง deterministic pilot manifest และ payload budget โดยไม่เรียก model | ดูคำสั่งด้านล่าง |
| `test_prepare_audit.py` | regression ของ sampling, edge coverage และ budget | `python test_prepare_audit.py` |
| `discover_events.py` | สร้าง event candidate manifest และ branch-aware evidence packets | ดูคำสั่งด้านล่าง |
| `test_discover_events.py` | regression ว่า packet ตาม lineage และไม่ปน sibling branch | `python test_discover_events.py` |

## Evidence-grade retro index

```bash
cd test/metrics
python index_transcripts.py index
python index_transcripts.py status
python index_transcripts.py search 'ผมหมายถึง'
python index_transcripts.py context <session-uuid> <turn-ordinal>
python index_transcripts.py export --session <session-uuid>
python index_transcripts.py import data/reviewed.jsonl --reviewer <name> --prompt-version <version>
```

`index` catalog ทุก `*.jsonl` แบบ recursive แต่ default audit เฉพาะ main interactive sessions;
subagent, Temp/harness และ `sdk-cli`/print sessions ถูกนับเป็น explicit exclusion ไม่ได้หายเงียบ.
session ที่ `Edit`/`Write`/`NotebookEdit` ไฟล์ใน dotfiles repo นี้ (รวม path ผ่าน symlink
`~/.claude/rules`, `skills`, `agents`) ถูก exclude ทั้ง session เป็น `dotfiles_self_modification`
เพื่อไม่ใช้ข้อมูลที่ปรับตัว evaluator เองเป็นหลักฐานอิสระ. การอ่านหรือ invoke config ตามปกติไม่ถูกตัด.
ฐานข้อมูลเก็บ full normalized conversation พร้อม `source file + line + UUID + raw hash`; raw JSONL
ยังเป็นหลักฐานต้นฉบับและไม่ได้ copy ลงฐานข้อมูล.

หน่วย semantic coverage คือ auditable human input ไม่ใช่ session. `export` ใช้ session เป็น envelope
เพื่อรักษาลำดับ แต่ reviewer ต้องแยกทุก objective/episode ภายในนั้นและจำแนกแต่ละ turn เป็น
`CONTINUE | REFINE | QUESTION | PREREQUISITE | NEW | REPLACE | DEFER | RESUME | CANCEL |
CORRECT | AMBIGUOUS`; topic change อย่างเดียวไม่พิสูจน์ว่า objective ถูก replace.

`status` ต้องผ่าน reconciliation ทั้งสามชั้น:

```text
discovered files = indexed + explicitly excluded + failed
indexed lines = parsed + malformed + blank
auditable inputs = pending + classified + ambiguous + failed + input-only audit units
```

`fallback_human_prompts` คือข้อความรุ่นเก่าที่ไม่มี `promptSource` แต่ผ่าน structural exclusion;
`ambiguous_user_inputs` ยังไม่ถูกนับเป็น human input และต้อง review ก่อน claim ว่า human-input
coverage สมบูรณ์. SQLite search ใช้ exact substring (`instr`) เพื่อไม่อ้าง Thai word segmentation
จาก FTS5 เกินหลักฐาน. หาก ambiguous ไม่เป็นศูนย์ ให้ตรวจ shape, เพิ่ม deterministic disposition
พร้อม fixture แล้ว re-index; ห้ามกดให้เป็น human/non-human เฉพาะ record เพื่อทำตัวเลขให้ครบ.

shared-parent input ทุกอันยังอยู่ใน input coverage. รายการที่มี response เป็น
`executed_branch` และต้อง audit แยกตาม lineage; รายการที่ไม่มี response เป็น `unanswered_edit`
สถานะ `input_only` จึงไม่ถูกนำไปวัด agent alignment หรือปนเข้า objective ledger เส้นหลัก.
ห้ามอ่าน shared-parent candidates ต่อกันเป็น timeline เดียวแม้อยู่ใน session envelope เดียวกัน.

ผล review ที่ import ต้องมีหนึ่งรายการต่อ alignment-auditable turn ของ session นั้น ห้าม partial และต้องส่ง
`turn_id`, `input_sha256`, `relation`, `objective_before[]`, `objective_after[]`, `alignment`,
`confidence`, `rationale`, `evidence[]`. Import จะ reject turn ที่ขาด/ซ้ำ, input stale, relation นอก
taxonomy หรือ finding ที่ไม่มี source evidence; จึงเปลี่ยนสถานะ coverage จาก pending ได้โดยไม่กลบ gap.

## Semantic pilot planning (ไม่ใช้ model)

```bash
python prepare_audit.py \
  --known-session <session-uuid> \
  --random-size 100 \
  --context-turns 6
```

planner เก็บ known sessions เป็น benchmark แยกจาก random holdout, เพิ่ม legacy fallback ทั้งหมด และ
เลือก edge representatives จาก project/branch/confidence/session-size/risk strata. Signal และ strata
ใช้เลือกตัวอย่างเพิ่มเท่านั้น ห้ามตัด interaction ออกจาก corpus หรือใช้คำนวณ prevalence แทน random
holdout. Report แสดงจำนวน strata ที่มีตัวแทนและรายการที่ยังไม่ถูก represent; ห้ามเรียก edge coverage
ว่า 100% หากยังมีรายการเหลือ. Default เลือกอย่างน้อยหนึ่งตัวแทนจากทุก stratum; ใช้ `--edge-size`
เฉพาะเมื่อต้องการ cap และยอมรับ partial stratum coverage. Output อยู่ `data/audit-plan.json` และมีเฉพาะ
manifest/provenance/ขนาด ไม่มี conversation text. Random holdout เป็น deterministic
interaction-weighted sample จึงใช้ประมาณ prevalence ต่อ interaction ไม่ใช่ prevalence ต่อ session.
selection reason อาจซ้อนกันได้; report จะแสดงทั้งจำนวนหลายเหตุผลและ pairwise intersections.

budget รายงาน normalized text chars/UTF-8 bytes และ token heuristic ช่วงกว้างเพื่อวางแผนเท่านั้น;
ไม่ใช่ tokenizer หรือขอบเขตบนของ model และยังไม่รวม prompt, retry หรือ second reviewer. ห้ามเริ่ม
semantic batch จาก heuristic โดยไม่กำหนด model, packing strategy และ hard budget ก่อน. Planner แสดง
ทั้ง turn-only, bounded-context แบบ unique/repeated และ full-session envelope; bounded physical context
อาจข้าม alternate branch จึงเป็นเพียง budget surface ไม่ใช่ payload ที่พร้อมส่งให้ model. Surface
`objective-spine` เก็บ user inputs ทั้ง session แต่แนบ assistant response เฉพาะ target เพื่อรักษา
long-range intent ในราคาต่ำกว่า full envelope; branch-aware packer ยังต้องแยก lineage ก่อนใช้งานจริง.
Planner ทำงานแบบ fail-closed: `pilot_ready` ยังเป็น false จนกว่าจะมี branch-aware packer, ระบุ model/
per-call budget และกำหนด hard input budget ด้วย `--max-planned-input-chars`.

การเลือกเป้าหมายใช้เฉพาะ pending alignment turns แต่ context/envelope รักษา classified และ input-only
turns ที่อยู่รอบเป้าหมายไว้ ส่วน full-corpus denominator รวม alignment turns ทุกสถานะ. Sampling rank และ
plan identity ผูกกับ seed, input hash และ database snapshot เพื่อให้ตรวจจับ corpus drift ได้.

## Event discovery (ผลลัพธ์หลักของ retrospective)

```bash
python discover_events.py \
  --known-session <session-uuid> \
  --known-limit-per-session 10 \
  --discovery-limit 100 \
  --discovery-since 2026-07-27 \
  --before 6 \
  --after 2
```

`event-candidates.json` เก็บ provenance ของ pending alignment turns ทุกอันเพื่อให้รายการที่ยังไม่ได้เปิด
ไม่หายไปจาก coverage. Signal เช่น explicit correction, objective/boundary control หรือคำถามที่ตามด้วย
mutation ใช้จัดลำดับ review เท่านั้น ไม่ใช่คำตัดสินว่าเป็น incident. `event-packets.jsonl` เก็บข้อความ
เฉพาะจุดที่จัดลำดับสูงสุดของ known benchmarks (cap ต่อ session) และ discovery frontier ที่เลือก
โดย context เดินตาม UUID parent lineage;
alternate sibling branch จะไม่ถูกนำมาต่อเป็น timeline เดียวกัน.
`--discovery-since` จำกัดเฉพาะ discovery packets ที่เปิดอ่าน; candidate manifest และ backlog
ยังครบทั้ง corpus จึงใช้แยก residual หลัง cutover โดยไม่ทำหลักฐานเก่าหาย.

Reviewer ต้องตัดสินแต่ละ packet เป็น `incident | not_incident | insufficient_context`. Incident dossier
ต้องระบุ intent ก่อนเกิดเหตุ, divergence point, agent action, user correction/impact, recovery, source
evidence, dotfile mechanism hypothesis และ regression candidate. Trend/prevalence เป็น post-process หลัง
มีการปรับ behavior ไม่ใช่ deliverable หลักของ event discovery.

## กติกา
- `data/` = **gitignored** (มีข้อความ conversation จริง อาจมี secret ปน — ห้าม commit)
- แม้ `audit-plan.json` ไม่มี conversation text แต่มี local path, project และ UUID; ห้ามแชร์ออกนอกเครื่อง
  โดยไม่ sanitize
- เปลี่ยน `--sample`/`--since` = **ลบ `data/out/` ก่อน** (batch cache keyed ด้วย index จะปนชุดเก่า)
- `--sample 600` แม่นพอสำหรับ trend, ถูกกว่า ~5x; full corpus ใช้เมื่อจะจดตัวเลขเป็น baseline
- ห้ามแก้ script ระหว่าง batch รัน (bash/subprocess อ่าน incremental — CLAUDE.md quirk)
- baseline ที่วัดแล้ว: CLAUDE.md §cutover marker (lookback 07-17 + semantic 07-17)
- ห้ามใช้ trend extractor เป็นหลักฐาน exhaustive: มัน truncate text, ย่อ session ID และทิ้ง branch ผี
  โดยออกแบบ; ใช้ retro index เมื่อต้อง audit ย้อนกลับ
