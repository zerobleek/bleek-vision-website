#!/usr/bin/env python3
"""Playtest landing heatmap.

Reads telemetry JSONL files (user://landings_*.jsonl — on Linux under
~/.local/share/godot/app_userdata/Jump Program/, on macOS under
~/Library/Application Support/Godot/app_userdata/Jump Program/) and the
block scene itself, then writes a top-down SVG heatmap and prints a
per-surface report. Dead surfaces get moved or deleted; hot accidental
routes get promoted — that's the M3 exit review.

Usage:
    python3 tools/heatmap.py [landings1.jsonl ...] [-o heatmap.svg]
    (no args: auto-discovers every landings_*.jsonl in the Godot user dir)
"""
import json
import re
import sys
import glob
import os

HERE = os.path.dirname(os.path.abspath(__file__))
SCENE = os.path.join(HERE, "..", "scenes", "world", "block.tscn")

USER_DIRS = [
    os.path.expanduser("~/.local/share/godot/app_userdata/Jump Program"),
    os.path.expanduser("~/Library/Application Support/Godot/app_userdata/Jump Program"),
]


def load_surfaces():
    """Parse block.tscn: surface_id -> (x, z, sx, sz, top_y)."""
    text = open(SCENE).read()
    surfaces = {}
    for block in text.split("[node ")[1:]:
        sid = re.search(r'surface_id = &"([^"]+)"', block)
        pos = re.search(r"position = Vector3\(([^)]+)\)", block)
        size = re.search(r"size = Vector3\(([^)]+)\)", block)
        if not (sid and pos and size):
            continue
        px, py, pz = [float(v) for v in pos.group(1).split(",")]
        sx, sy, sz = [float(v) for v in size.group(1).split(",")]
        surfaces[sid.group(1)] = (px, pz, sx, sz, py + sy / 2)
    return surfaces


def load_landings(paths):
    rows = []
    for p in paths:
        with open(p) as f:
            for line in f:
                line = line.strip()
                if line:
                    try:
                        rows.append(json.loads(line))
                    except json.JSONDecodeError:
                        pass
    return rows


def heat_color(frac):
    """0 → cool gray, 0.5 → amber, 1 → hot red."""
    stops = [(0.55, 0.55, 0.58), (0.95, 0.68, 0.25), (0.90, 0.20, 0.15)]
    t = frac * 2
    a, b = (stops[0], stops[1]) if t <= 1 else (stops[1], stops[2])
    t = t if t <= 1 else t - 1
    rgb = [a[i] + (b[i] - a[i]) * t for i in range(3)]
    return "#%02x%02x%02x" % tuple(int(c * 255) for c in rgb)


def main():
    out_svg = "heatmap.svg"
    paths = []
    argv = sys.argv[1:]
    i = 0
    while i < len(argv):
        if argv[i] == "-o":
            out_svg = argv[i + 1]
            i += 2
        else:
            paths.append(argv[i])
            i += 1
    if not paths:
        for d in USER_DIRS:
            paths.extend(sorted(glob.glob(os.path.join(d, "landings_*.jsonl"))))
    if not paths:
        sys.exit("no landings_*.jsonl found — pass paths or run a playtest first")

    surfaces = load_surfaces()
    rows = load_landings(paths)
    counts, kinds = {}, {}
    for r in rows:
        sid = r.get("surface", "?")
        counts[sid] = counts.get(sid, 0) + 1
        kinds.setdefault(sid, {}).setdefault(r.get("kind", "?"), 0)
        kinds[sid][r.get("kind", "?")] += 1

    peak = max((c for s, c in counts.items() if s != "srf_street_s"), default=1)

    # --- console report ---
    print(f"{len(rows)} landings across {len(paths)} session file(s)\n")
    print(f"{'surface':32} {'count':>6}  kinds")
    for sid in sorted(surfaces, key=lambda s: -counts.get(s, 0)):
        c = counts.get(sid, 0)
        kd = ", ".join(f"{k}:{n}" for k, n in sorted(kinds.get(sid, {}).items()))
        flag = "  ← DEAD" if c == 0 and sid not in ("srf_tower",) else ""
        print(f"{sid:32} {c:>6}  {kd}{flag}")

    # --- svg (map x → svg x, map -z → svg y; block is authored z<=0) ---
    scale = 12
    w, h = int(70 * scale), int(70 * scale)
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" '
        f'viewBox="0 0 {w} {h}" font-family="monospace" font-size="10">',
        f'<rect width="{w}" height="{h}" fill="#121418"/>',
    ]
    for sid, (px, pz, sx, sz, top) in sorted(surfaces.items(), key=lambda kv: kv[1][4]):
        c = counts.get(sid, 0)
        if sid.startswith("srf_street"):
            color = "#1c1f24"  # ground is always hot and never informative
        else:
            color = heat_color(min(c / peak, 1.0)) if c else "#2a2d33"
        x = (px - sx / 2 + 8) * scale
        y = (-pz - sz / 2 + 8) * scale
        parts.append(
            f'<rect x="{x:.0f}" y="{y:.0f}" width="{sx * scale:.0f}" '
            f'height="{sz * scale:.0f}" fill="{color}" stroke="#121418" '
            f'stroke-width="1"><title>{sid} · {c} landings · top {top:g} m</title></rect>'
        )
        if sx * scale > 40 and sz * scale > 14:
            parts.append(
                f'<text x="{x + 3:.0f}" y="{y + 11:.0f}" fill="#d6dbe3">'
                f"{sid.removeprefix('srf_')} ({c})</text>"
            )
    parts.append("</svg>")
    with open(out_svg, "w") as f:
        f.write("\n".join(parts))
    print(f"\nwrote {out_svg}")


if __name__ == "__main__":
    main()
