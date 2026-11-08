#!/usr/bin/env python3
"""Static sanity checks for the Ink story files in story/.

Not a full Ink compiler: it catches broken braces, dangling diverts,
duplicate knots and unfinished markers early, so agents and CI fail fast.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
STORY_DIR = REPO_ROOT / "story"

KNOT_RE = re.compile(r"^\s*={2,}\s*([A-Za-z_][A-Za-z0-9_]*)\s*=+\s*$")
STITCH_RE = re.compile(r"^\s*=\s*([A-Za-z_][A-Za-z0-9_]*)\s*$")
DIVERT_RE = re.compile(r"->\s*([A-Za-z_][A-Za-z0-9_]*)")
TUNNEL_RE = re.compile(r"->\s*([A-Za-z_][A-Za-z0-9_]*)\s*->")
MARKER_RE = re.compile(r"\b(TODO|FIXME|XXX)\b")


def check_file(path: Path, known: set[str]) -> list[str]:
    errors: list[str] = []
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()

    depth = 0
    for number, line in enumerate(lines, start=1):
        if MARKER_RE.search(line):
            errors.append(f"{path}:{number}: unfinished marker: {line.strip()}")
        stripped = re.sub(r"//.*$", "", line)
        depth += stripped.count("{") - stripped.count("}")
        if depth < 0:
            errors.append(f"{path}:{number}: closing brace without opening brace")
            depth = 0
        if re.match(r"^\s*=+\s*$", stripped):
            errors.append(f"{path}:{number}: empty knot header")
    if depth != 0:
        errors.append(f"{path}: unbalanced braces (depth {depth} at EOF)")

    seen: set[str] = set()
    local_knots: set[str] = set()
    for number, line in enumerate(lines, start=1):
        knot = KNOT_RE.match(line)
        if knot:
            name = knot.group(1)
            if name in seen:
                errors.append(f"{path}:{number}: duplicate knot '{name}'")
            seen.add(name)
            local_knots.add(name)
        if STITCH_RE.match(line):
            stitch = STITCH_RE.match(line).group(1)  # type: ignore[union-attr]
            local_knots.add(stitch)

    all_known = known | local_knots
    for number, line in enumerate(lines, start=1):
        code = re.sub(r"//.*$", "", line)
        for match in TUNNEL_RE.finditer(code):
            target = match.group(1)
            if target not in all_known:
                errors.append(f"{path}:{number}: tunnel to unknown knot '{target}'")
        for match in DIVERT_RE.finditer(code):
            target = match.group(1)
            if target not in all_known:
                errors.append(f"{path}:{number}: divert to unknown knot '{target}'")

    return errors


def main() -> int:
    files = sorted(STORY_DIR.rglob("*.ink")) if STORY_DIR.exists() else []
    if not files:
        print("ink_check: no .ink files yet (ok for phase 0)")
        return 0

    known: set[str] = set()
    for path in files:
        for line in path.read_text(encoding="utf-8").splitlines():
            knot = KNOT_RE.match(line)
            if knot:
                known.add(knot.group(1))

    errors: list[str] = []
    for path in files:
        errors.extend(check_file(path, known))

    if errors:
        for error in errors:
            print(error)
        print(f"ink_check: FAIL ({len(errors)} problems in {len(files)} files)")
        return 1

    print(f"ink_check: PASS ({len(files)} files)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
