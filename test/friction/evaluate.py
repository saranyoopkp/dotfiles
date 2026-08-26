#!/usr/bin/env python3
"""Evaluate one deterministic simple-task transcript without judging open-ended prose."""

import json
import sys
from pathlib import Path


stream_path = Path(sys.argv[1])
expected = sys.argv[2]
max_chars = int(sys.argv[3])
tool_calls = 0
result = ""

for raw in stream_path.read_text(encoding="utf-8").splitlines():
    try:
        event = json.loads(raw)
    except json.JSONDecodeError:
        continue
    if event.get("type") == "result" and isinstance(event.get("result"), str):
        result = event["result"].strip()
    content = (event.get("message") or {}).get("content")
    if isinstance(content, list):
        tool_calls += sum(
            1 for block in content if isinstance(block, dict) and block.get("type") == "tool_use"
        )

failures = []
if not result:
    failures.append("missing final result")
if expected not in result:
    failures.append(f"expected fragment not found: {expected!r}")
if len(result) > max_chars:
    failures.append(f"output length {len(result)} exceeds {max_chars}")
if tool_calls:
    failures.append(f"unexpected tool calls: {tool_calls}")
if "?" in result or "？" in result:
    failures.append("unexpected question in final result")

if failures:
    print("; ".join(failures))
    raise SystemExit(1)

print(f"chars={len(result)} tools={tool_calls}")
