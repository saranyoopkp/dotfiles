#!/usr/bin/env python3
"""Regex/tool_use lookback metrics per period (cutover before/after).

Metrics per period: sessions, user turns, corrective-"ไม่" rate, continue-cmd rate,
edit-sessions, ACV usage (ground truth = Agent tool_use with subagent_type ~ ACV).

Usage: python lookback.py [--cuts 2026-07-14T19:44 2026-07-16T09:10]  (UTC)
Filters: subagents, Temp projects, sessions with <2 user turns; straddlers dropped.
"""
import argparse, glob, json, os, re

HOME = os.path.expanduser("~").replace("\\", "/")


def parse(f):
    first = last = None
    turns = corrective = cont = edits = acv = 0
    try:
        for line in open(f, encoding="utf-8", errors="replace"):
            try:
                d = json.loads(line)
            except Exception:
                continue
            ts = d.get("timestamp")
            if ts:
                first = first or ts[:19]
                last = ts[:19]
            c = (d.get("message") or {}).get("content")
            if d.get("type") == "user":
                txt = c if isinstance(c, str) else " ".join(
                    x.get("text", "") for x in (c or [])
                    if isinstance(x, dict) and x.get("type") == "text")
                txt = (txt or "").strip()
                if txt and not txt.startswith(("<", "Caveat")):
                    turns += 1
                    # กว้างโดยเจตนา (ตรง baseline CLAUDE.md 07-17) — จับ "ไม่..." ทุกแบบ
                    # รวม noise (bug report "ไม่มีเสียง") — ตัวแม่นคือ semantic_classify
                    if txt.startswith("ไม่"):
                        corrective += 1
                    if re.match(r"^(ต่อเลย|ทำต่อ|ต่อได้เลย|ทำเลย|จัดการเลย|ต่อครับ)", txt):
                        cont += 1
            elif d.get("type") == "assistant" and isinstance(c, list):
                for x in c:
                    if isinstance(x, dict) and x.get("type") == "tool_use":
                        if x.get("name") in ("Edit", "Write", "NotebookEdit"):
                            edits += 1
                        elif x.get("name") == "Agent" and "ACV" in str(
                                (x.get("input") or {}).get("subagent_type", "")):
                            acv += 1
    except Exception:
        return None
    return dict(first=first, last=last, turns=turns, corrective=corrective,
                cont=cont, edits=edits, acv=acv)


def agg(rows, label):
    T = sum(r["turns"] for r in rows) or 1
    C = sum(r["corrective"] for r in rows)
    K = sum(r["cont"] for r in rows)
    ed = [r for r in rows if r["edits"] > 0]
    a = [r for r in ed if r["acv"] > 0]
    pct = f"{100*len(a)/len(ed):.0f}%" if ed else "n/a"
    print(f"{label}: sessions={len(rows)} turns={T} corrective={C} "
          f"({100*C/T:.1f}/100t) cont={K} ({100*K/T:.1f}/100t) "
          f"edit-sess={len(ed)} ACV={len(a)} ({pct})")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cuts", nargs="*", default=["2026-07-14T19:44", "2026-07-16T09:10"])
    ap.add_argument("--since", default="2026-07-01")
    args = ap.parse_args()

    files = [f for f in glob.glob(f"{HOME}/.claude/projects/*/*.jsonl")
             if "subagent" not in f.lower() and "Temp" not in f]
    rows = [r for r in (parse(f) for f in files)
            if r and r["first"] and r["turns"] >= 2 and r["first"] >= args.since]
    bounds = [args.since] + sorted(args.cuts) + ["9999"]
    for i in range(len(bounds) - 1):
        lo, hi = bounds[i], bounds[i + 1]
        agg([r for r in rows if r["first"] > lo and r["last"] < hi],
            f"P{i} ({lo[:16]} -> {hi[:16]})")


if __name__ == "__main__":
    main()
