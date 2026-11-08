"""Draws docs/map/plan_station.png: the old station, the confirmed street loop and the route to Jezioro Morzyc,
with the terrain sequence along the route.

Input: data/osm/route_station_lake.json (route_to_lake.py), data/osm/route_profile.json (route_profile.py).
Confirmed by the author on 2026-11-07: loop B (Okrężna), station building S1 (id 939993183).
"""
import json, math, pathlib, sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import render_plan as R

R_ = json.load(open(R.ROOT / "data/osm/route_station_lake.json"))
PROF = json.load(open(R.ROOT / "data/osm/route_profile.json"))
LOOP = next(l for l in R_["loops"] if "Okrężna" in l["streets"])
STATION = next(c for c in R_["station_building_candidates"] if c["id"] == 939993183)
LAKE_HOUSE = PROF["lake_buildings"][0]
route = [tuple(p) for p in R_["route_xy"]]
halt, bus = tuple(R_["halt_xy"]), tuple(R_["busstop_xy"])
xs = [p[0] for p in route] + [halt[0], bus[0]]; ys = [p[1] for p in route] + [halt[1], bus[1]]
xmin, xmax = math.floor((min(xs) - 250) / 100) * 100, math.ceil((max(xs) + 250) / 100) * 100
ymin, ymax = math.floor((min(ys) - 250) / 100) * 100, math.ceil((max(ys) + 250) / 100) * 100
SCALE = 0.5
TERRAIN = {"las": ((60, 120, 50), "las"), "pole": ((230, 180, 40), "pole"),
           "brak danych": ((150, 150, 150), "pola? (brak w OSM)"), "zabudowa": ((120, 100, 90), "zabudowa")}

def subpath(d0, d1):
    out, acc = [], 0.0
    for a, b in zip(route, route[1:]):
        seg = math.dist(a, b)
        if acc + seg >= d0 and acc <= d1:
            lo, hi = max(d0 - acc, 0.0) / seg, min(d1 - acc, seg) / seg
            out += [(a[0] + (b[0] - a[0]) * lo, a[1] + (b[1] - a[1]) * lo), (a[0] + (b[0] - a[0]) * hi, a[1] + (b[1] - a[1]) * hi)]
        acc += seg
    return out

def overlay(d, P, SS, scale):
    f = R.font
    # terrain bands under the route
    for seg in PROF["segments"]:
        col, name = TERRAIN.get(seg["class"], ((150, 150, 150), seg["class"]))
        pts = subpath(seg["from_m"], seg["to_m"])
        if len(pts) >= 2:
            d.line([P(*q) for q in pts], fill=col, width=int(13 * scale * SS * 2))
            mid = pts[len(pts) // 2]
            if seg["to_m"] - seg["from_m"] > 150 and seg["from_m"] >= 700:   # no clutter in the station area
                d.text(P(mid[0], mid[1] - 70), f"{name} {seg['to_m'] - seg['from_m']} m", font=f(14 * SS, True), fill=col,
                       anchor="mm", stroke_width=3 * SS, stroke_fill=(255, 255, 255))
    # confirmed loop "krzywy kwadrat" (Okrężna)
    pts = [P(*q) for q in LOOP["xy"]] + [P(*LOOP["xy"][0])]
    d.line(pts, fill=(235, 130, 0), width=int(5 * scale * SS * 2))
    top = min(LOOP["xy"], key=lambda q: -q[1]); cx, cy = P(top[0], top[1] + 40)
    d.text((cx, cy), "krzywy kwadrat (Okrężna)", font=f(14 * SS, True), fill=(200, 100, 0), anchor="mm", stroke_width=3 * SS, stroke_fill=(255, 255, 255))
    # confirmed station building
    d.polygon([P(*q) for q in STATION["ring"]], fill=(210, 30, 30), outline=(20, 20, 20))
    d.text(P(STATION["xy"][0] + 35, STATION["xy"][1] - 40), "dworzec (ruina)", font=f(14 * SS, True), fill=(160, 20, 20), anchor="lm", stroke_width=3 * SS, stroke_fill=(255, 255, 255))
    # the single house at the lake
    lx, ly = P(*LAKE_HOUSE["xy"]); r = 7 * SS
    d.rectangle([lx - r, ly - r, lx + r, ly + r], fill=(240, 240, 240), outline=(20, 20, 20), width=2 * SS)
    d.text((lx + 14 * SS, ly - 14 * SS), "domek nad jeziorem", font=f(13 * SS, True), fill=(20, 20, 20), anchor="lm", stroke_width=3 * SS, stroke_fill=(255, 255, 255))
    # route and distance marks
    rpts = [P(*q) for q in route]
    d.line(rpts, fill=(200, 0, 120), width=max(3, int(3 * scale * SS * 2)))
    acc, mark = 0.0, 500.0
    for a, b in zip(route, route[1:]):
        acc += math.dist(a, b)
        if acc >= mark:
            px, py = P(*b); r = 11 * SS
            d.ellipse([px - r, py - r, px + r, py + r], fill=(255, 255, 255), outline=(200, 0, 120), width=2 * SS)
            d.text((px, py), f"{mark / 1000:g}", font=f(12 * SS, True), fill=(200, 0, 120), anchor="mm")
            mark += 500.0
    hx, hy = P(*halt); s = 9 * SS
    d.polygon([(hx, hy - s), (hx + s, hy), (hx, hy + s), (hx - s, hy)], fill=(210, 30, 30), outline=(20, 20, 20))
    d.text((hx, hy + 24 * SS), "nieczynny przystanek Linia Zakrzewo", font=f(13 * SS, True), fill=(160, 20, 20), anchor="mm", stroke_width=3 * SS, stroke_fill=(255, 255, 255))
    bx, by = P(*bus); r = 8 * SS
    d.ellipse([bx - r, by - r, bx + r, by + r], fill=(50, 120, 220), outline=(20, 20, 20))
    d.text((bx, by - 22 * SS), "start trasy", font=f(13 * SS, True), fill=(20, 70, 160), anchor="mm", stroke_width=3 * SS, stroke_fill=(255, 255, 255))

legend = ["POTWIERDZONE przez Mariusza:",
          "  • krzywy kwadrat = pętla Okrężna (pomarańcz.)",
          "  • budynek stacji = czerwony (dziś ruina)",
          "  • droga: żwirowo-gruntowa przez pola, las,",
          "    znów pola, las z jeziorem i jednym domkiem",
          "Różowa linia: trasa po drogach OSM,",
          f"  {R_['route_len_m']} m, w linii prostej {R_['straight_m']} m.",
          "Liczby w kółkach: kilometry od początku trasy.",
          "Kolor pod linią: teren wg OSM. Szary =",
          "  brak danych w OSM; „pola?” to wniosek z",
          "  opisu Mariusza, nie dane."]
size = R.render(str(R.ROOT / "docs/map/plan_station.png"), xmin, xmax, ymin, ymax, SCALE, 100, True,
                "Stacja → Jezioro Morzyc", 0, overlay=overlay, show_pois=False, legend_lines=legend)
print("plan_station.png", size, "frame x", xmin, xmax, "y", ymin, ymax)
