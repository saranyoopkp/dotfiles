#!/usr/bin/env python3
"""Classify user turns semantically via `claude -p --model haiku` fan-out.

Usage:
  python extract_turns.py                    # first: build data/turns.jsonl
  python semantic_classify.py                # full corpus (~3k turns ≈ 2-3 min)
  python semantic_classify.py --sample 600   # stratified-by-day random sample (~5x cheaper)
  python semantic_classify.py --merge-only   # re-merge existing batch outputs

Output: data/merged.jsonl (turns + cat), data/daily.csv (rates /100 turns per day)
Categories: corr_target corr_omit corr_over approve_continue new_task question other

⚠️ อย่าแก้ไฟล์นี้ระหว่างที่ batch กำลังรัน (CLAUDE.md: bash อ่าน script incremental)
"""
import argparse, collections, json, os, random, re, subprocess, sys
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = f"{HERE}/data"
BATCH = 80
PARALLEL = 8
USE_CTX = False  # ดู warning เหนือ PROMPT_HEAD

# ⚠️ อย่าแก้ prompt นี้โดยไม่รัน eval_groundtruth ซ้ำ — นี่คือเครื่องมือวัด ต้อง stable
# Sweep 2026-07-17 (vs GT n=100): baseline haiku no-ctx acc 0.84 ชนะหมด
#   haiku+ctx 0.76 · haiku+ctx+กติกาแก้ 0.59 · sonnet 0.69 · sonnet+ctx 0.70
# สาเหตุจริง (ตรวจ raw case แล้ว ไม่ใช่อนุมานจาก aggregate):
#   - ctx ที่ป้อน = หางข้อความ assistant ล่าสุด 150 ตัวอักษร → มัก stale (คั่นด้วย tool calls)
#     และขาดกลางประโยค → โมเดลเจอ ctx ไม่เกี่ยวจึงเทคำตอบไป new_task (13/16 เคสที่พัง)
#     ยังไม่ได้พิสูจน์ว่า "ctx คุณภาพดี" จะช่วยหรือไม่ — พิสูจน์แค่ ctx แบบนี้ทำร้าย
#   - sonnet "แพ้" ส่วนใหญ่คือ taxonomy disagreement (คำสั่งสั้น → new_task ซึ่งตีความได้)
#     ไม่ใช่ comprehension — ตัวเลข acc วัด agreement กับ Fable-judge labels ไม่ใช่ความจริงสัมบูรณ์
# → default ไม่ใช้ ctx; เปิดได้ด้วย --ctx
# ทดลองเพิ่มหมวดที่ 8 (user_takeover) ใน prompt เดียว → accuracy รวมร่วง 0.84→0.69
# (หมวดใหม่รบกวนหมวดเดิม) → วัด takeover ด้วย 2-pass แทน: รอบ 8-cat ชี้ candidate
# แล้ว judge ยืนยัน (ผล 07-17: 55 candidates → 13 trust-loss จริง, 7 อยู่วัน hook saga)
PROMPT_HEAD = """Classify each user message from a coding-assistant conversation into exactly one category:
- corr_target: user corrects WRONG TARGET/intent (assistant misread what/where, e.g. "ไม่ใช่อันนั้น", "หมายถึง...", wrong repo/file/scope)
- corr_omit: user points out something MISSED/forgotten/incomplete
- corr_over: user says assistant did/proposed TOO MUCH or unnecessary ("ไม่ต้อง...", revert extra work)
- approve_continue: user merely approves/tells assistant to continue its own stated plan ("ต่อเลย","ทำต่อ","ok","ใช่ ทำเลย")
- new_task: new instruction/task/information
- question: user asks a question
- other: anything else (slash commands, noise)
Output ONLY JSON lines, one per item: {"id":<id>,"cat":"<category>"} — no prose.

Messages:
"""


def run_batch(i, batch):
    def item(t):
        d = {"id": t["id"], "text": t["text"][:300]}
        if USE_CTX:
            d["ctx"] = t.get("prev", "")[-150:]
        return d
    prompt = PROMPT_HEAD + "".join(
        json.dumps(item(t), ensure_ascii=False) + "\n" for t in batch)
    out = f"{DATA}/out/{i:03d}.jsonl"
    if os.path.exists(out) and os.path.getsize(out) > 0:
        return
    r = subprocess.run(["claude", "-p", prompt, "--model", "haiku"],
                       capture_output=True, text=True, encoding="utf-8")
    open(out, "w", encoding="utf-8").write(r.stdout or "")
    if r.returncode != 0:
        print(f"batch {i} rc={r.returncode}: {r.stderr[:200]}", file=sys.stderr)


def merge(turns):
    cats, bad = {}, 0
    import glob
    for f in glob.glob(f"{DATA}/out/*.jsonl"):
        for line in open(f, encoding="utf-8", errors="replace"):
            m = re.search(r'\{.*"id"\s*:\s*(\d+).*?"cat"\s*:\s*"([a-z_]+)"', line)
            if m:
                cats[int(m.group(1))] = m.group(2)
            elif line.strip():
                bad += 1
    with open(f"{DATA}/merged.jsonl", "w", encoding="utf-8") as out:
        for t in turns:
            t["cat"] = cats.get(t["id"], "unclassified")
            out.write(json.dumps(t, ensure_ascii=False) + "\n")
    print(f"classified {len(cats)}/{len(turns)}, unparsed lines: {bad}")
    print(collections.Counter(cats.values()).most_common())

    days = collections.defaultdict(collections.Counter)
    for t in turns:
        days[t["ts"][:10]]["total"] += 1
        days[t["ts"][:10]][t["cat"]] += 1
    with open(f"{DATA}/daily.csv", "w", encoding="utf-8") as f:
        f.write("day,total,approve_continue,corr_target,corr_omit,corr_over\n")
        for d in sorted(days):
            c = days[d]
            if c["total"] < 5:
                continue
            f.write(f"{d},{c['total']}," + ",".join(
                f"{100*c[k]/c['total']:.1f}" for k in
                ("approve_continue", "corr_target", "corr_omit", "corr_over")) + "\n")
    print(f"-> {DATA}/merged.jsonl , {DATA}/daily.csv")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--sample", type=int, help="stratified-by-day random sample size")
    ap.add_argument("--merge-only", action="store_true")
    ap.add_argument("--ctx", action="store_true", help="แนบ prev-assistant context (วัดแล้วแย่กว่า — ดู comment)")
    ap.add_argument("--seed", type=int, default=42)
    args = ap.parse_args()
    global USE_CTX
    USE_CTX = args.ctx

    turns = [json.loads(l) for l in open(f"{DATA}/turns.jsonl", encoding="utf-8")]
    if args.sample and args.sample < len(turns):
        rng = random.Random(args.seed)
        by_day = collections.defaultdict(list)
        for t in turns:
            by_day[t["ts"][:10]].append(t)
        frac = args.sample / len(turns)
        turns = sorted((t for day in by_day.values()
                        for t in rng.sample(day, max(1, round(len(day) * frac)))),
                       key=lambda t: t["id"])
        print(f"sampled {len(turns)} turns (stratified by day, seed={args.seed})")

    os.makedirs(f"{DATA}/out", exist_ok=True)
    if not args.merge_only:
        batches = [turns[i:i + BATCH] for i in range(0, len(turns), BATCH)]
        print(f"{len(batches)} batches x {BATCH}, parallel={PARALLEL}")
        with ThreadPoolExecutor(PARALLEL) as ex:
            list(ex.map(lambda p: run_batch(*p), enumerate(batches)))
    merge(turns)


if __name__ == "__main__":
    main()
