"""Exports the centre of Linia from OSM into data/blockout/centrum.json for the Godot greybox.

Coordinates are local metres, origin = the church, x = east, y = north (the Godot builder maps y to -z).
Heights: OSM only has `building:levels` (no `height`), so heights are assumptions: levels * 3.0 m, with
fixed values for the church, school, gym, town hall and fire station (see HEIGHT_BY_KIND).

Input:  data/osm/linia_raw.json
Output: data/blockout/centrum.json
"""
import json, math, pathlib, sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import render_plan as R

ROOT = R.ROOT
BOUNDS = {"xmin": -450.0, "xmax": 450.0, "ymin": -350.0, "ymax": 350.0}
HEIGHT_BY_KIND = {"church": 14.0, "school": 7.5, "gym": 8.0, "townhall": 8.0, "fire": 6.0}
ROAD_WIDTH = {"primary": 7, "secondary": 6, "tertiary": 5, "unclassified": 4, "residential": 4, "living_street": 3.5,
              "service": 3, "track": 3, "path": 1.5, "footway": 1.5, "cycleway": 2, "bridleway": 1.5}
KIND_OF_POI = {"kościół": "church", "szkoła": "school", "urząd": "townhall", "straż": "fire"}

D = json.load(open(ROOT / "data/osm/linia_raw.json"))["elements"]
def inside_bounds(p, m=0.0):
    return BOUNDS["xmin"] - m <= p[0] <= BOUNDS["xmax"] + m and BOUNDS["ymin"] - m <= p[1] <= BOUNDS["ymax"] + m

def clean(ring):
    pts = []
    for p in ring:
        if not pts or math.dist(p, pts[-1]) > 0.05: pts.append(p)
    if len(pts) > 1 and math.dist(pts[0], pts[-1]) < 0.05: pts.pop()
    return pts

def area(r): return abs(sum(r[i][0] * r[(i + 1) % len(r)][1] - r[(i + 1) % len(r)][0] * r[i][1] for i in range(len(r)))) / 2
def centroid(r): return (sum(p[0] for p in r) / len(r), sum(p[1] for p in r) / len(r))

buildings = []
for e in D:
    t = e.get("tags", {})
    if e["type"] != "way" or "building" not in t or not e.get("geometry"): continue
    ring = clean([R.xy(p["lat"], p["lon"]) for p in e["geometry"]])
    if len(ring) < 3 or area(ring) < 4.0: continue
    c = centroid(ring)
    if not inside_bounds(c, 30): continue
    levels = int(t["building:levels"]) if str(t.get("building:levels", "")).isdigit() else 1
    buildings.append({"id": e["id"], "kind": "house", "levels": max(levels, 1), "ring": ring, "centroid": c})

def nearest_building(pt, pool=None):
    return min(pool or buildings, key=lambda b: math.dist(b["centroid"], pt))

for num, kind, name, c in R.POI:
    if kind in KIND_OF_POI:
        nearest_building(c)["kind"] = KIND_OF_POI[kind]
school = next((p for p in R.POI if p[1] == "szkoła"), None)
if school:
    cand = [b for b in buildings if math.dist(b["centroid"], school[3]) < 120 and b["kind"] == "house"]
    if cand: max(cand, key=lambda b: area(b["ring"]))["kind"] = "gym"
for b in buildings:
    b["height"] = HEIGHT_BY_KIND.get(b["kind"], max(b["levels"], 1) * 3.0)

roads = []
for e in D:
    t = e.get("tags", {})
    if e["type"] == "way" and t.get("highway") in ROAD_WIDTH and e.get("geometry"):
        pts = [R.xy(p["lat"], p["lon"]) for p in e["geometry"]]
        if any(inside_bounds(p, 20) for p in pts):
            roads.append({"highway": t["highway"], "name": t.get("name", ""), "width": ROAD_WIDTH[t["highway"]], "pts": pts})

# spawn: a road vertex near the church that keeps >= 3 m from every footprint
def clearance(p):
    best = 1e9
    for b in buildings:
        r = b["ring"]
        if math.dist(b["centroid"], p) > 60: continue
        for i in range(len(r)):
            a, c = r[i], r[(i + 1) % len(r)]
            ax, ay, bx, by = a[0], a[1], c[0], c[1]
            dx, dy = bx - ax, by - ay; L2 = dx * dx + dy * dy
            t = 0 if L2 == 0 else max(0, min(1, ((p[0] - ax) * dx + (p[1] - ay) * dy) / L2))
            best = min(best, math.dist(p, (ax + t * dx, ay + t * dy)))
    return best
def in_footprint(p, r):
    c = False
    for i in range(len(r)):
        (x1, y1), (x2, y2) = r[i], r[(i + 1) % len(r)]
        if (y1 > p[1]) != (y2 > p[1]) and p[0] < (x2 - x1) * (p[1] - y1) / (y2 - y1) + x1: c = not c
    return c
cands = [p for rd in roads if rd["highway"] in ("tertiary", "residential", "unclassified", "primary", "secondary") for p in rd["pts"]
         if math.dist(p, (0, 0)) < 90 and not any(in_footprint(p, b["ring"]) for b in buildings if math.dist(b["centroid"], p) < 80) and clearance(p) >= 3.0]
spawn = min(cands, key=lambda p: math.dist(p, (0, -35)))

out = {"origin_latlon": [R.LAT0, R.LON0], "bounds": BOUNDS, "spawn": spawn,
       "buildings": [{"id": b["id"], "kind": b["kind"], "levels": b["levels"], "height": b["height"], "ring": b["ring"]} for b in buildings],
       "roads": roads}
path = ROOT / "data/blockout/centrum.json"
path.write_text(json.dumps(out), encoding="utf-8")
from collections import Counter
print("buildings:", len(buildings), dict(Counter(b["kind"] for b in buildings)))
print("roads:", len(roads), "| spawn:", [round(v, 1) for v in spawn], "| size KB:", round(path.stat().st_size / 1024))
