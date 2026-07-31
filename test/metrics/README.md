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

## กติกา
- `data/` = **gitignored** (มีข้อความ conversation จริง อาจมี secret ปน — ห้าม commit)
- เปลี่ยน `--sample`/`--since` = **ลบ `data/out/` ก่อน** (batch cache keyed ด้วย index จะปนชุดเก่า)
- `--sample 600` แม่นพอสำหรับ trend, ถูกกว่า ~5x; full corpus ใช้เมื่อจะจดตัวเลขเป็น baseline
- ห้ามแก้ script ระหว่าง batch รัน (bash/subprocess อ่าน incremental — CLAUDE.md quirk)
- baseline ที่วัดแล้ว: CLAUDE.md §cutover marker (lookback 07-17 + semantic 07-17)
- ห้ามใช้ trend extractor เป็นหลักฐาน exhaustive: มัน truncate text, ย่อ session ID และทิ้ง branch ผี
  โดยออกแบบ; ใช้ retro index เมื่อต้อง audit ย้อนกลับ
