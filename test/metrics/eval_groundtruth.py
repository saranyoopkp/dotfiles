#!/usr/bin/env python3
"""Evaluate classifier precision/recall against a hand-labeled ground-truth file.

Flow:
  1. python eval_groundtruth.py --make [--n 100]   # sample from data/merged.jsonl
     -> data/groundtruth.jsonl  (fields: id, ts, text, predicted, label="")
  2. Human fills "label" with the true category (same 7 values, or "" to skip)
  3. python eval_groundtruth.py                    # compute precision/recall

Stratified: oversamples rare corrective categories so P/R are measurable.
"""
import argparse, collections, json, os, random

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = f"{HERE}/data"
CATS = ["corr_target", "corr_omit", "corr_over", "approve_continue",
        "new_task", "question", "other"]
# per-predicted-category sample quota (rare cats oversampled)
QUOTA = {"corr_target": 15, "corr_omit": 15, "corr_over": 10,
         "approve_continue": 20, "new_task": 15, "question": 15, "other": 10}


def make(n, seed):
    rng = random.Random(seed)
    rows = [json.loads(l) for l in open(f"{DATA}/merged.jsonl", encoding="utf-8")]
    by_cat = collections.defaultdict(list)
    for r in rows:
        by_cat[r["cat"]].append(r)
    scale = n / sum(QUOTA.values())
    picked = []
    for cat, q in QUOTA.items():
        pool = by_cat.get(cat, [])
        picked += rng.sample(pool, min(len(pool), max(1, round(q * scale))))
    rng.shuffle(picked)
    with open(f"{DATA}/groundtruth.jsonl", "w", encoding="utf-8") as f:
        for r in picked:
            f.write(json.dumps({"id": r["id"], "ts": r["ts"], "text": r["text"],
                                "predicted": r["cat"], "label": ""},
                               ensure_ascii=False) + "\n")
    print(f"wrote {len(picked)} rows -> data/groundtruth.jsonl")
    print('fill "label" with one of:', ", ".join(CATS))


def evaluate():
    rows = [json.loads(l) for l in open(f"{DATA}/groundtruth.jsonl", encoding="utf-8")]
    rows = [r for r in rows if r.get("label")]
    if not rows:
        print("no labeled rows yet — fill the label field first")
        return
    print(f"labeled: {len(rows)}")
    for cat in CATS:
        tp = sum(1 for r in rows if r["predicted"] == cat and r["label"] == cat)
        fp = sum(1 for r in rows if r["predicted"] == cat and r["label"] != cat)
        fn = sum(1 for r in rows if r["predicted"] != cat and r["label"] == cat)
        if tp + fp + fn == 0:
            continue
        p = tp / (tp + fp) if tp + fp else float("nan")
        r_ = tp / (tp + fn) if tp + fn else float("nan")
        print(f"{cat:18s} P={p:.2f} R={r_:.2f} (tp={tp} fp={fp} fn={fn})")
    acc = sum(1 for r in rows if r["predicted"] == r["label"]) / len(rows)
    print(f"overall accuracy: {acc:.2f}")
    print("Warning: recall is measured within a stratified sample. "
          "Use it to compare categories, not as whole-corpus recall.")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--make", action="store_true")
    ap.add_argument("--n", type=int, default=100)
    ap.add_argument("--seed", type=int, default=42)
    args = ap.parse_args()
    if args.make:
        make(args.n, args.seed)
    else:
        evaluate()


if __name__ == "__main__":
    main()
