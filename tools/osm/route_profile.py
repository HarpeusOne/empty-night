"""Terrain profile along the station -> lake route (fields / forest / ...), plus buildings near the lake.

Input: data/osm/route_station_lake.json, data/osm/linia_raw.json
Output: data/osm/route_profile.json and a printed table. Classes come from OSM landuse/natural polygons;
areas without any polygon are reported as 'brak danych' (OSM does not map everything).
"""
import json, math, pathlib, sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import render_plan as R

ROOT = R.ROOT
route = [tuple(p) for p in json.load(open(ROOT / "data/osm/route_station_lake.json"))["route_xy"]]

def inside(pt, ring):
    x, y = pt; c = False
    for (x1, y1), (x2, y2) in zip(ring, ring[1:]):
        if (y1 > y) != (y2 > y) and x < (x2 - x1) * (y - y1) / (y2 - y1) + x1: c = not c
    return c

def classify(pt):
    kinds = {k for k, ring, holes, t in R.polys if k not in ("building", "amenity", "leisure") and inside(pt, ring)}
    if kinds & {"forest", "wood"}: return "las"
    if "water" in kinds: return "woda"
    if kinds & {"farmland", "meadow", "grass", "orchard"}: return "pole"
    if kinds & {"residential", "farmyard", "industrial", "commercial", "retail"}: return "zabudowa"
    if kinds & {"scrub", "heath", "wetland"}: return "zarośla/mokradło"
    return "brak danych"

samples = []; acc = 0.0
for a, b in zip(route, route[1:]):
    seg = math.dist(a, b); n = max(1, int(seg // 25))
    for i in range(n):
        t = i / n; p = (a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t)
        samples.append((acc + seg * t, classify(p), p))
    acc += seg
total = acc

segs = []
for d, c, p in samples:
    if segs and segs[-1][0] == c: segs[-1][2] = d + 25
    else: segs.append([c, d, d + 25])
segs[-1][2] = total
# merge very short segments into the previous one so the profile reads as the author described it
merged = []
for s in segs:
    if merged and (s[2] - s[1] < 80 or merged[-1][0] == s[0]): merged[-1][2] = s[2]
    else: merged.append(list(s))
print(f"trasa: {total:.0f} m")
for c, a, b in merged: print(f"  {a:6.0f} - {b:6.0f} m  ({b - a:5.0f} m)  {c}")

# buildings near the lake
lake = next(p for p in R.polys if p[0] == "water" and "Morzyc" in p[3].get("name", ""))
near = []
for k, ring, holes, t in R.polys:
    if k == "building":
        c = R.cen(ring); dist = min(math.dist(c, q) for q in lake[1])
        if dist < 400: near.append((dist, R.area(ring), c, t))
print("\nbudynki w promieniu 400 m od jeziora:")
for dist, ar, c, t in sorted(near): print(f"  {dist:5.0f} m od brzegu, {ar:5.0f} m², ({c[0]:.0f},{c[1]:.0f}), {({k: v for k, v in t.items() if k in ('building', 'name', 'building:levels')})}")
json.dump({"total_m": round(total), "segments": [{"class": c, "from_m": round(a), "to_m": round(b)} for c, a, b in merged],
           "lake_buildings": [{"dist_m": round(d), "area_m2": round(ar), "xy": [round(c[0]), round(c[1])], "tags": t} for d, ar, c, t in sorted(near)]},
          open(ROOT / "data/osm/route_profile.json", "w"), ensure_ascii=False)
