# test/metrics — วัดพฤติกรรม agent จาก session corpus (`~/.claude/projects`)

ใช้วัดผล SCC cutover (ดู CLAUDE.md §cutover marker) — main session เท่านั้น, ดู time trend

| script | ทำอะไร | คำสั่ง |
|---|---|---|
| `lookback.py` | regex + tool_use ground truth: corrective-"ไม่", continue-cmd, ACV compliance ต่อ period | `python lookback.py --cuts <ts1> <ts2>` |
| `extract_turns.py` | ดึง user turns → `data/turns.jsonl` | `python extract_turns.py --since 2026-07-01` |
| `semantic_classify.py` | haiku fan-out classify 7 หมวด → `data/merged.jsonl` + `data/daily.csv` | `python semantic_classify.py [--sample 600]` |
| `eval_groundtruth.py` | สร้าง/ประเมิน ground-truth set (precision/recall) | `--make` แล้ว label มือ แล้วรันเปล่า |

## กติกา
- `data/` = **gitignored** (มีข้อความ conversation จริง อาจมี secret ปน — ห้าม commit)
- เปลี่ยน `--sample`/`--since` = **ลบ `data/out/` ก่อน** (batch cache keyed ด้วย index จะปนชุดเก่า)
- `--sample 600` แม่นพอสำหรับ trend, ถูกกว่า ~5x; full corpus ใช้เมื่อจะจดตัวเลขเป็น baseline
- ห้ามแก้ script ระหว่าง batch รัน (bash/subprocess อ่าน incremental — CLAUDE.md quirk)
- baseline ที่วัดแล้ว: CLAUDE.md §cutover marker (lookback 07-17 + semantic 07-17)
