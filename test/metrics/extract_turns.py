#!/usr/bin/env python3
"""Extract user turns from ~/.claude/projects main-session transcripts.

Output: data/turns.jsonl  ({id, ts, sid, proj, text})
Usage:  python extract_turns.py [--since 2026-07-01]
Filters: subagents, Temp projects, system/tool/caveat messages,
abandoned sibling branches (rewind/message-edit สร้างลูกหลายตัวใต้ parentUuid เดียว —
เก็บเฉพาะตัวสุดท้าย = ตัวที่ถูกตอบจริง; วัด 07-17: ~9% ของ corpus เป็น branch ผี)
"""
import argparse, glob, json, os

HOME = os.path.expanduser("~").replace("\\", "/")
HERE = os.path.dirname(os.path.abspath(__file__))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--since", default="2026-07-01")
    args = ap.parse_args()

    files = [f for f in glob.glob(f"{HOME}/.claude/projects/*/*.jsonl")
             if "subagent" not in f.lower() and "Temp" not in f]
    os.makedirs(f"{HERE}/data", exist_ok=True)
    n = dropped = 0
    with open(f"{HERE}/data/turns.jsonl", "w", encoding="utf-8") as out:
        for f in files:
            sid = os.path.basename(f)[:8]
            proj = f.replace("\\", "/").split("projects/")[1].split("/")[0][:40]
            prev = ""  # ข้อความ assistant ล่าสุดก่อน user turn (context สำหรับ classify)
            cand = {}  # parentUuid -> record (ตัวสุดท้ายชนะ = branch ที่ถูกตอบจริง)
            seq = 0
            try:
                for line in open(f, encoding="utf-8", errors="replace"):
                    try:
                        d = json.loads(line)
                    except Exception:
                        continue
                    c = (d.get("message") or {}).get("content")
                    if d.get("type") == "assistant" and isinstance(c, list):
                        t = " ".join(x.get("text", "") for x in c
                                     if isinstance(x, dict) and x.get("type") == "text").strip()
                        if t:
                            prev = t[-300:]
                        continue
                    if d.get("type") != "user" or d.get("isSidechain"):
                        continue
                    ts = (d.get("timestamp") or "")[:19]
                    if not ts or ts < args.since:
                        continue
                    txt = c if isinstance(c, str) else " ".join(
                        x.get("text", "") for x in (c or [])
                        if isinstance(x, dict) and x.get("type") == "text")
                    txt = (txt or "").strip()
                    if not txt or txt.startswith(("<", "Caveat", "[Request")):
                        continue
                    key = d.get("parentUuid") or f"_seq{seq}"
                    if key in cand:
                        dropped += 1  # sibling เก่าถูกแทน (rewind/edit)
                    cand[key] = {"ts": ts, "sid": sid, "proj": proj,
                                 "text": txt[:400], "prev": prev}
                    seq += 1
            except Exception:
                pass
            for r in sorted(cand.values(), key=lambda r: r["ts"]):
                r["id"] = n
                out.write(json.dumps(r, ensure_ascii=False) + "\n")
                n += 1
    print(f"extracted {n} turns (dropped {dropped} abandoned branches) -> data/turns.jsonl")


if __name__ == "__main__":
    main()
