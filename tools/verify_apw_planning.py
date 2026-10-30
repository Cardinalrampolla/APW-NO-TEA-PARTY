#!/usr/bin/env python3
"""Validate APW planning artifacts without claiming game runtime coverage."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
WAVES = [
    ("docs/APW_50_CHECKPOINT_ROADMAP_G11_G60.md", 11, 60),
    ("docs/APW_50_CHECKPOINT_ROADMAP_G61_G110.md", 61, 110),
]
errors = []
seen = set()
for filename, start, end in WAVES:
    path = ROOT / filename
    if not path.is_file():
        errors.append(f"Missing {filename}")
        continue
    text = path.read_text(encoding="utf-8")
    found = [int(n) for n in re.findall(r"(?m)^- \[ \] \*\*G(\d+)\*\*", text)]
    expected = list(range(start, end + 1))
    if found != expected:
        errors.append(f"{filename}: expected G{start}..G{end} in order, got {found}")
    for n in found:
        if n in seen:
            errors.append(f"Duplicate checkpoint G{n}")
        seen.add(n)
for filename in ["docs/A1_QUALITY_GATE.md", "docs/CROSS_AGENT_PEER_REVIEW.md", "docs/BIRDMAN_DDT_ACCEPTANCE.md"]:
    if not (ROOT / filename).is_file():
        errors.append(f"Missing quality artifact: {filename}")
if errors:
    for error in errors:
        print("FAIL:", error, file=sys.stderr)
    sys.exit(1)
print(f"PASS: {len(seen)} uniquely numbered planning checkpoints and quality docs present.")
print("NOTE: This validates planning documents only; it does not run Godot or gameplay tests.")
