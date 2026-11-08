"""Finds the street loop near the old Linia station and the shortest road/track route to Jezioro Morzyc.

Input:  data/osm/linia_raw.json (fetch_linia.py)
Output: data/osm/route_station_lake.json  (local metres, origin = the church in Linia, +x east, +y north)

The "station" is the disused halt node 'Linia Zakrzewo' (OSM has no station building) plus the bus stop
'Linia, Dworzec Kolejowy'. Loops and the route are candidates for the author to confirm on the plan.
"""
import collections, heapq, json, math, pathlib, sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
D = json.load(open(ROOT / "data/osm/linia_raw.json"))["elements"]
HALT_LL = (54.4535532, 17.910254)      # node 2899076677, disused:railway=halt "Linia Zakrzewo"
BUSSTOP_LL = (54.4546424, 17.9131422)  # node 5181769688, bus_stop "Linia, Dworzec Kolejowy"
W_OK = {"residential", "unclassified", "service", "track", "path", "footway", "tertiary", "secondary",
        "primary", "living_street", "bridleway", "cycleway"}

def tags(e): return e.get("tags", {})
def center(e):
    if e["type"] == "node": return (e["lat"], e["lon"])
    g = e["geometry"]; la = [p["lat"] for p in g]; lo = [p["lon"] for p in g]
    return ((min(la) + max(la)) / 2, (min(lo) + max(lo)) / 2)

church = next(e for e in D if tags(e).get("amenity") == "place_of_worship" and "Serca" in tags(e).get("name", ""))
LAT0, LON0 = center(church)
KX = 111320 * math.cos(math.radians(LAT0)); KY = 110540
def xy(lat, lon): return ((lon - LON0) * KX, (lat - LAT0) * KY)
def area(r): return abs(sum(r[i][0] * r[i + 1][1] - r[i + 1][0] * r[i][1] for i in range(len(r) - 1))) / 2

halt, bus = xy(*HALT_LL), xy(*BUSSTOP_LL)
centre = ((halt[0] + bus[0]) / 2, (halt[1] + bus[1]) / 2)

G = collections.defaultdict(list); way_info = {}
def key(p): return (round(p["lat"], 6), round(p["lon"], 6))
for e in D:
    t = tags(e)
    if e["type"] == "way" and t.get("highway") in W_OK and e.get("geometry"):
        g = e["geometry"]
        for a, b in zip(g, g[1:]):
            ka, kb = key(a), key(b)
            if ka != kb:
                w = math.dist(xy(*ka), xy(*kb))
                G[ka].append((kb, w, e["id"])); G[kb].append((ka, w, e["id"]))
        way_info[e["id"]] = (t.get("highway"), t.get("name", ""))

# --- candidate street loops around the station
near = {k for k in G if math.dist(xy(*k), centre) <= 420}
found = {}
def dfs(start, cur, path, plen, seen):
    if plen > 1100 or len(path) > 14: return
    for nb, dl, _ in G[cur]:
        if nb not in near: continue
        if nb == start and len(path) >= 4:
            pts = [xy(*k) for k in path]; ar = area(pts + [pts[0]])
            if ar > 3000: found[frozenset(path)] = (plen + dl, ar, list(path))
            continue
        if nb in seen: continue
        seen.add(nb); path.append(nb); dfs(start, nb, path, plen + dl, seen); path.pop(); seen.discard(nb)
sys.setrecursionlimit(10000)
for s in sorted(near, key=lambda k: math.dist(xy(*k), centre))[:260]: dfs(s, s, [s], 0.0, {s})

loops = []
for per, ar, path in sorted(found.values(), key=lambda v: math.dist(
        (sum(xy(*k)[0] for k in v[2]) / len(v[2]), sum(xy(*k)[1] for k in v[2]) / len(v[2])), centre) + abs(v[0] - 500) / 5):
    pts = [xy(*k) for k in path]; c = (sum(p[0] for p in pts) / len(pts), sum(p[1] for p in pts) / len(pts))
    if any(math.dist(c, l["center"]) < 40 for l in loops): continue
    names = set()
    for k, kk in zip(path, path[1:] + path[:1]):
        for nb, _, wid in G[k]:
            if nb == kk and way_info[wid][1]: names.add(way_info[wid][1])
    loops.append({"center": c, "perimeter_m": round(per), "area_m2": round(ar), "streets": sorted(names), "xy": pts})
    if len(loops) >= 2: break

# --- route from the station bus stop to the lake shore
lake = next(e for e in D if e["type"] == "way" and tags(e).get("name", "").startswith("Jezioro Morzyc"))
lake_pts = [xy(p["lat"], p["lon"]) for p in lake["geometry"]]
goals = set(sorted(G, key=lambda k: min(math.dist(xy(*k), p) for p in lake_pts))[:5])
src = min(G, key=lambda k: math.dist(xy(*k), bus))
dist = {src: 0.0}; prev = {}; pq = [(0.0, src)]; end = None
while pq:
    d, u = heapq.heappop(pq)
    if u in goals: end = u; break
    if d > dist.get(u, 1e18): continue
    for v, w, wid in G[u]:
        if d + w < dist.get(v, 1e18): dist[v] = d + w; prev[v] = (u, wid); heapq.heappush(pq, (d + w, v))
route, ways = [end], []
while route[-1] in prev: u, wid = prev[route[-1]]; ways.append(wid); route.append(u)
route.reverse(); ways.reverse()
legs = []
for w in ways:
    if not legs or legs[-1][0] != w: legs.append([w, 0.0])
for (a, b), w in zip(zip(route, route[1:]), ways):
    legs[[i for i, l in enumerate(legs) if l[0] == w][-1]][1] += math.dist(xy(*a), xy(*b))

# --- buildings near the halt: candidates for the ruined station building
cands = []
for e in D:
    if e["type"] == "way" and "building" in tags(e) and e.get("geometry"):
        r = [xy(p["lat"], p["lon"]) for p in e["geometry"]]
        c = (sum(p[0] for p in r) / len(r), sum(p[1] for p in r) / len(r))
        if math.dist(c, halt) < 130 and area(r) > 300:
            cands.append({"id": e["id"], "xy": c, "area_m2": round(area(r)), "tags": {k: v for k, v in tags(e).items() if k.startswith("building")}, "ring": r})

straight = math.dist(xy(*route[0]), xy(*route[-1]))
out = {"origin_latlon": [LAT0, LON0], "halt_xy": halt, "busstop_xy": bus,
       "route_xy": [xy(*k) for k in route], "route_len_m": round(sum(l[1] for l in legs)), "straight_m": round(straight),
       "route_legs": [{"highway": way_info[w][0], "name": way_info[w][1], "len_m": round(l)} for w, l in legs],
       "lake_gap_m": round(min(math.dist(xy(*end), p) for p in lake_pts)),
       "loops": loops, "station_building_candidates": cands}
(ROOT / "data/osm/route_station_lake.json").write_text(json.dumps(out), encoding="utf-8")
print("route:", out["route_len_m"], "m (straight", out["straight_m"], "m), gap to lake", out["lake_gap_m"], "m")
for l in out["route_legs"]: print("  ", l)
for l in loops: print("loop", l["perimeter_m"], "m", l["area_m2"], "m2", l["streets"], [round(v) for v in l["center"]])
for c in cands: print("candidate", c["id"], c["area_m2"], "m2", [round(v) for v in c["xy"]], c["tags"])
