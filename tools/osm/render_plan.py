import json, math, pathlib, sys
from PIL import Image, ImageDraw, ImageFont

ROOT = pathlib.Path(__file__).resolve().parents[2]
D = json.load(open(ROOT / "data/osm/linia_raw.json"))["elements"]
FONT = "/usr/share/fonts/abattis-cantarell-fonts/Cantarell-Regular.otf"
FONTB = "/usr/share/fonts/abattis-cantarell-fonts/Cantarell-Bold.otf"
def font(sz, bold=False): return ImageFont.truetype(FONTB if bold else FONT, sz)

def col_name(i): return chr(65 + i) if i < 26 else chr(64 + i // 26) + chr(65 + i % 26)

def tags(e): return e.get("tags", {})
def pts_of(g): return [(p["lat"], p["lon"]) for p in g]

"""Renders two labelled 2D plans of Zakrzewo-Linia-Morzyc from OSM data.

Input:  data/osm/linia_raw.json (see fetch_linia.py)
Output: docs/map/plan_overview.png, docs/map/plan_village.png
OSM names printed on the plans are for planning only, not for the game (bestiary V-09).
"""

# ---------- origin: the church in Linia
def center_of(e):
    if e["type"] == "node": return (e["lat"], e["lon"])
    g = e.get("geometry") or []
    if not g: return None
    la = [p["lat"] for p in g]; lo = [p["lon"] for p in g]
    return ((min(la) + max(la)) / 2, (min(lo) + max(lo)) / 2)

church = next(e for e in D if tags(e).get("amenity") == "place_of_worship" and "Serca" in tags(e).get("name", ""))
LAT0, LON0 = center_of(church)
KX = 111320.0 * math.cos(math.radians(LAT0)); KY = 110540.0
def xy(lat, lon): return ((lon - LON0) * KX, (lat - LAT0) * KY)

# ---------- collect geometry in local metres
def ring_xy(g): return [xy(p["lat"], p["lon"]) for p in g]
def closed(r): return len(r) > 3 and r[0] == r[-1]

def stitch(ways):
    ways = [list(w) for w in ways if len(w) > 1]; rings = []
    while ways:
        cur = ways.pop(0)
        grew = True
        while grew and cur[0] != cur[-1]:
            grew = False
            for i, w in enumerate(ways):
                if w[0] == cur[-1]: cur += w[1:]; ways.pop(i); grew = True; break
                if w[-1] == cur[-1]: cur += w[::-1][1:]; ways.pop(i); grew = True; break
                if w[-1] == cur[0]: cur = w[:-1] + cur; ways.pop(i); grew = True; break
                if w[0] == cur[0]: cur = w[::-1][:-1] + cur; ways.pop(i); grew = True; break
        if cur[0] == cur[-1] and len(cur) > 3: rings.append(cur)
    return rings

polys = []     # (kind, outer_ring, [holes], tags)
lines = []     # (kind, pts, tags)
nodes = []     # (tags, x, y)
for e in D:
    t = tags(e)
    if e["type"] == "node":
        nodes.append((t,) + xy(e["lat"], e["lon"])); continue
    if e["type"] == "way":
        r = ring_xy(e.get("geometry", []))
        if "building" in t and closed(r): polys.append(("building", r, [], t))
        elif t.get("natural") in ("water", "wood", "scrub", "wetland", "heath") and closed(r): polys.append((t["natural"], r, [], t))
        elif "landuse" in t and closed(r): polys.append((t["landuse"], r, [], t))
        elif "leisure" in t and closed(r): polys.append(("leisure", r, [], t))
        if "highway" in t: lines.append(("highway:" + t["highway"], r, t))
        elif "railway" in t: lines.append(("railway", r, t))
        elif "waterway" in t: lines.append(("waterway", r, t))
        if "amenity" in t and "building" not in t and closed(r): polys.append(("amenity", r, [], t))
    elif e["type"] == "relation":
        outers = [ring_xy(m["geometry"]) for m in e.get("members", []) if m.get("role") == "outer" and m.get("geometry")]
        inners = [ring_xy(m["geometry"]) for m in e.get("members", []) if m.get("role") == "inner" and m.get("geometry")]
        kind = t.get("natural") if t.get("natural") in ("water", "wood") else t.get("landuse")
        for ring in stitch(outers):
            polys.append((kind, ring, stitch(inners), t))

def area(r): return abs(sum(r[i][0] * r[i + 1][1] - r[i + 1][0] * r[i][1] for i in range(len(r) - 1))) / 2
def cen(r): return (sum(p[0] for p in r) / len(r), sum(p[1] for p in r) / len(r))

BG = (236, 233, 224)
FILL = {"farmland": (232, 226, 184), "meadow": (214, 228, 181), "grass": (214, 228, 181), "orchard": (205, 222, 170),
        "residential": (228, 219, 210), "farmyard": (225, 214, 196), "industrial": (214, 210, 214), "commercial": (226, 205, 205),
        "retail": (226, 205, 205), "forest": (159, 192, 138), "wood": (159, 192, 138), "scrub": (185, 201, 154),
        "heath": (200, 205, 160), "wetland": (168, 196, 176), "water": (143, 184, 224), "quarry": (201, 167, 122),
        "cemetery": (185, 163, 201), "leisure": (200, 222, 190), "amenity": (222, 215, 190)}
ORDER = ["farmland", "meadow", "grass", "orchard", "residential", "farmyard", "industrial", "commercial", "retail", "leisure",
         "amenity", "scrub", "heath", "wetland", "forest", "wood", "quarry", "cemetery", "water"]
ROAD_W = {"motorway": 7, "trunk": 7, "primary": 6, "secondary": 5, "tertiary": 4, "unclassified": 3.5, "residential": 3.5,
          "living_street": 3, "service": 2.5, "track": 2.2, "path": 1.2, "footway": 1.2, "cycleway": 1.5, "bridleway": 1.2}
ROAD_C = {"track": (176, 138, 90), "path": (140, 130, 120), "footway": (140, 130, 120), "bridleway": (140, 130, 120),
          "cycleway": (110, 140, 190)}

# ---------- POIs (real OSM names: planning only, not for the game)
POI = []   # (num, kind, name, (x,y))
def add_poi(kind, name, c):
    POI.append((len(POI) + 1, kind, name, c))
def find(pred):
    for e in D:
        if pred(tags(e)):
            c = center_of(e)
            if c: return xy(*c)
for label, kind, pred in (
    ("Kościół", "kościół", lambda t: t.get("amenity") == "place_of_worship" and "Serca" in t.get("name", "")),
    ("Szkoła", "szkoła", lambda t: t.get("amenity") == "school"),
    ("Urząd gminy", "urząd", lambda t: t.get("amenity") == "townhall"),
    ("OSP", "straż", lambda t: t.get("amenity") == "fire_station")):
    c = find(pred)
    if c: add_poi(kind, label, c)
cem = [p for p in polys if p[0] == "cemetery"]
if cem: add_poi("cmentarz", "Cmentarz", cen(max(cem, key=lambda p: area(p[1]))[1]))
for p in sorted([p for p in polys if p[0] == "quarry"], key=lambda p: -area(p[1])):
    add_poi("żwirownia", "Żwirownia/kamieniołom", cen(p[1]))
lake = None
for p in polys:
    if p[0] == "water" and "Morzyc" in p[3].get("name", ""): lake = p; break
if lake: add_poi("jezioro", "Jezioro Morzyc", cen(lake[1]))
shops = [(x, y) for t, x, y in nodes if "shop" in t]
rail = [l for l in lines if l[0] == "railway"]

# ---------- drawing
def render(path, xmin, xmax, ymin, ymax, scale, grid_step, grid_labels, legend_title, label_roads,
           overlay=None, show_pois=True, legend_lines=(), SS=2):
    W = int((xmax - xmin) * scale); H = int((ymax - ymin) * scale)
    LEG = 440; M = 36
    need = 40 + 24 * 10 + 34 + ((len(POI) * 28 + 100) if show_pois else 0) + len(legend_lines) * 22 + 120
    Hc = max(H, need)
    img = Image.new("RGB", ((W + LEG + 2 * M) * SS, (Hc + 2 * M) * SS), (250, 249, 245))
    d = ImageDraw.Draw(img)
    def P(x, y): return ((M + (x - xmin) * scale) * SS, (M + (ymax - y) * scale) * SS)
    d.rectangle([M * SS, M * SS, (M + W) * SS, (M + H) * SS], fill=BG)
    # clip by drawing everything then pasting border over the margins later
    for kind in ORDER:
        for k, ring, holes, t in sorted([p for p in polys if p[0] == kind], key=lambda p: -area(p[1])):
            d.polygon([P(*q) for q in ring], fill=FILL.get(kind, BG))
            for h in holes: d.polygon([P(*q) for q in h], fill=BG)
    for k, r, t in lines:
        if k == "waterway": d.line([P(*q) for q in r], fill=(110, 160, 210), width=max(1, int(2 * scale * SS)))
    for k, r, t in sorted([l for l in lines if l[0].startswith("highway")], key=lambda l: ROAD_W.get(l[0][8:], 2)):
        hw = k[8:]; w = max(1, int(ROAD_W.get(hw, 2) * scale * SS))
        if hw in ("track", "path", "footway", "bridleway"):
            d.line([P(*q) for q in r], fill=ROAD_C.get(hw, (150, 140, 130)), width=w)
        else:
            d.line([P(*q) for q in r], fill=(120, 116, 106), width=w + 2 * SS)
            d.line([P(*q) for q in r], fill=(255, 253, 244), width=w)
    for k, r, t in rail:   # disused/abandoned railway: dashed red line
        pts = [P(*q) for q in r]
        on = True; acc = 0.0
        for a, b in zip(pts, pts[1:]):
            seg = math.dist(a, b)
            if seg == 0: continue
            pos = 0.0
            while pos < seg:
                step = min((16 if on else 10) * SS - acc, seg - pos)
                if on:
                    p1 = (a[0] + (b[0] - a[0]) * pos / seg, a[1] + (b[1] - a[1]) * pos / seg)
                    p2 = (a[0] + (b[0] - a[0]) * (pos + step) / seg, a[1] + (b[1] - a[1]) * (pos + step) / seg)
                    d.line([p1, p2], fill=(170, 40, 40), width=3 * SS)
                pos += step; acc += step
                if acc >= (16 if on else 10) * SS: on = not on; acc = 0.0
    special = {"kościół": (192, 57, 43), "szkoła": (46, 134, 222), "urząd": (230, 150, 20), "straż": (231, 76, 60)}
    for k, ring, holes, t in polys:
        if k == "building":
            d.polygon([P(*q) for q in ring], fill=(92, 92, 99), outline=(48, 48, 52))
    # the buildings nearest to the main POIs get their own colour
    for kind, name, c in [(p[1], p[2], p[3]) for p in POI]:
        if kind in special:
            best = min((bld for bld in polys if bld[0] == "building"), key=lambda bld: math.dist(cen(bld[1]), c), default=None)
            if best: d.polygon([P(*q) for q in best[1]], fill=special[kind], outline=(20, 20, 20))
    sch = next((q for q in POI if q[1] == "szkoła"), None)
    if sch:
        gym = max((b for b in polys if b[0] == "building" and math.dist(cen(b[1]), sch[3]) < 120),
                  key=lambda b: area(b[1]), default=None)
        if gym:
            d.polygon([P(*q) for q in gym[1]], fill=(110, 175, 240), outline=(20, 20, 20))
            gx, gy = P(*cen(gym[1]))
            d.text((gx + 20 * SS, gy), "sala gimn.", font=font(11 * SS), fill=(20, 20, 20), anchor="lm",
                   stroke_width=2 * SS, stroke_fill=(255, 255, 255))
    for x, y in shops:
        px, py = P(x, y); r = 4 * SS
        d.ellipse([px - r, py - r, px + r, py + r], fill=(245, 200, 40), outline=(60, 50, 10))
    # grid
    f = font(13 * SS)
    if grid_step:
        gx = math.floor(xmin / grid_step) * grid_step; gy = math.ceil(ymax / grid_step) * grid_step
        x = gx; col = 0
        while x <= xmax + 1:
            if x >= xmin:
                d.line([P(x, ymin), P(x, ymax)], fill=(120, 120, 140), width=1 * SS)
            x += grid_step
        y = gy; row = 0
        while y >= ymin - 1:
            if ymin <= y <= ymax:
                d.line([P(xmin, y), P(xmax, y)], fill=(120, 120, 140), width=1 * SS)
            y -= grid_step
    # labels
    for t, x, y in nodes:
        if t.get("place") and t.get("name") and xmin <= x <= xmax and ymin <= y <= ymax:
            big = t["place"] in ("village", "town")
            d.text(P(x, y), t["name"], font=font((22 if big else 16) * SS, big), fill=(20, 20, 20), anchor="mm",
                   stroke_width=3 * SS, stroke_fill=(255, 255, 255))
    for k, ring, holes, t in polys:
        if k == "water" and t.get("name"):
            c = cen(ring)
            if xmin <= c[0] <= xmax and ymin <= c[1] <= ymax and area(ring) > 20000:
                d.text(P(*c), t["name"], font=font(18 * SS, True), fill=(20, 60, 120), anchor="mm", stroke_width=3 * SS, stroke_fill=(255, 255, 255))
    if label_roads:
        seen = set(); cand = []
        for k, r, t in lines:
            n = t.get("name")
            if k.startswith("highway") and n and n not in seen:
                L = sum(math.dist(a, b) for a, b in zip(r, r[1:]))
                if L > 150: cand.append((L, n, r[len(r) // 2]))
        for L, n, c in sorted(cand, reverse=True)[:label_roads]:
            if xmin < c[0] < xmax and ymin < c[1] < ymax and n not in seen:
                seen.add(n)
                d.text(P(*c), n, font=font(11 * SS), fill=(60, 60, 60), anchor="mm", stroke_width=2 * SS, stroke_fill=(255, 255, 255))
    if overlay: overlay(d, P, SS, scale)
    # POI markers (numbered)
    for num, kind, name, c in (POI if show_pois else []):
        if xmin <= c[0] <= xmax and ymin <= c[1] <= ymax:
            px, py = P(*c); r = 13 * SS
            d.ellipse([px - r, py - r, px + r, py + r], fill=(255, 255, 255), outline=(20, 20, 20), width=2 * SS)
            d.text((px, py), str(num), font=font(15 * SS, True), fill=(20, 20, 20), anchor="mm")
    # cover overflow outside map frame, then frame
    d.rectangle([0, 0, img.width, M * SS - 1], fill=(250, 249, 245)); d.rectangle([0, (M + H) * SS + 1, img.width, img.height], fill=(250, 249, 245))
    d.rectangle([0, 0, M * SS - 1, img.height], fill=(250, 249, 245)); d.rectangle([(M + W) * SS + 1, 0, img.width, img.height], fill=(250, 249, 245))
    d.rectangle([M * SS, M * SS, (M + W) * SS, (M + H) * SS], outline=(40, 40, 40), width=2 * SS)
    # grid labels again on top (they live in the margin)
    if grid_step and grid_labels:
        cols = int(math.ceil((xmax - xmin) / grid_step)); x0 = math.floor(xmin / grid_step) * grid_step
        for i in range(cols):
            cx = x0 + (i + 0.5) * grid_step
            if xmin <= cx <= xmax:
                d.text((P(cx, 0)[0], (M - 16) * SS), col_name(i), font=font(15 * SS, True), fill=(40, 40, 90), anchor="mm")
        rows = int(math.ceil((ymax - ymin) / grid_step)); y0 = math.ceil(ymax / grid_step) * grid_step
        for j in range(rows):
            cy = y0 - (j + 0.5) * grid_step
            if ymin <= cy <= ymax:
                d.text(((M - 16) * SS, P(0, cy)[1]), str(j + 1), font=font(15 * SS, True), fill=(40, 40, 90), anchor="mm")
    # legend panel
    lx = (M + W + 24) * SS; ly = M * SS
    d.text((lx, ly), legend_title, font=font(20 * SS, True), fill=(20, 20, 20))
    yy = ly + 40 * SS
    def row(color, text, outline=None):
        nonlocal yy
        d.rectangle([lx, yy, lx + 26 * SS, yy + 16 * SS], fill=color, outline=outline or (60, 60, 60))
        d.text((lx + 36 * SS, yy + 8 * SS), text, font=font(14 * SS), fill=(20, 20, 20), anchor="lm"); yy += 24 * SS
    for col, txt in (((92, 92, 99), "budynek"), (FILL["forest"], "las"), (FILL["farmland"], "pole uprawne"), (FILL["meadow"], "łąka / trawa"),
                     (FILL["residential"], "zabudowa mieszkalna"), (FILL["water"], "woda"), (FILL["quarry"], "żwirownia / kamieniołom"),
                     (FILL["cemetery"], "cmentarz")): row(col, txt)
    d.line([lx, yy + 8 * SS, lx + 26 * SS, yy + 8 * SS], fill=(170, 40, 40), width=3 * SS)
    d.text((lx + 36 * SS, yy + 8 * SS), "tory (nieczynne)", font=font(14 * SS), fill=(20, 20, 20), anchor="lm"); yy += 24 * SS
    d.ellipse([lx + 8 * SS, yy + 1 * SS, lx + 20 * SS, yy + 13 * SS], fill=(245, 200, 40), outline=(60, 50, 10))
    d.text((lx + 36 * SS, yy + 8 * SS), "sklep", font=font(14 * SS), fill=(20, 20, 20), anchor="lm"); yy += 34 * SS
    if show_pois:
        d.text((lx, yy), "Miejsca (nazwy OSM, tylko robocze):", font=font(15 * SS, True), fill=(20, 20, 20)); yy += 26 * SS
        for num, kind, name, c in POI:
            d.ellipse([lx, yy, lx + 22 * SS, yy + 22 * SS], fill=(255, 255, 255), outline=(20, 20, 20), width=2 * SS)
            d.text((lx + 11 * SS, yy + 11 * SS), str(num), font=font(13 * SS, True), fill=(20, 20, 20), anchor="mm")
            dist = math.hypot(c[0], c[1])
            d.text((lx + 32 * SS, yy + 11 * SS), f"{name}  ({dist:,.0f} m od kościoła)".replace(",", " "), font=font(14 * SS), fill=(20, 20, 20), anchor="lm")
            yy += 28 * SS
        yy += 14 * SS
    for line in legend_lines:
        d.text((lx, yy), line, font=font(14 * SS), fill=(20, 20, 20)); yy += 22 * SS
    d.text((lx, yy), f"Początek układu: kościół (1).", font=font(13 * SS), fill=(60, 60, 60)); yy += 20 * SS
    if grid_step:
        d.text((lx, yy), f"Kratka = {grid_step} m. Kolumny A, B, C… od lewej,", font=font(13 * SS), fill=(60, 60, 60)); yy += 18 * SS
        d.text((lx, yy), "wiersze 1, 2, 3… od góry. Północ jest u góry.", font=font(13 * SS), fill=(60, 60, 60)); yy += 24 * SS
    # scale bar
    bar = 500 if scale < 0.5 else 100
    bx = lx; by = ly + (Hc - 40) * SS
    d.rectangle([bx, by, bx + int(bar * scale * SS), by + 8 * SS], fill=(20, 20, 20))
    d.text((bx, by + 14 * SS), f"{bar} m", font=font(14 * SS), fill=(20, 20, 20))
    d.text((lx, by + 40 * SS), "© OpenStreetMap contributors (ODbL)", font=font(12 * SS), fill=(80, 80, 80))
    img = img.resize((img.width // SS, img.height // SS), Image.LANCZOS)
    img.save(path, optimize=True)
    return img.size

def main():
    # frame the overview by the downloaded bbox, not by data that spills outside it
    x1, y1 = xy(54.435, 17.835); x2, y2 = xy(54.480, 17.965)
    print("bbox m: x", round(x1), round(x2), "y", round(y1), round(y2))
    s1 = render(str(ROOT / "docs/map/plan_overview.png"), x1, x2, y1, y2, 0.22, 500, True, "Zakrzewo – Linia – jezioro (przegląd)", 0)
    s2 = render(str(ROOT / "docs/map/plan_village.png"), -900, 900, -650, 650, 1.0, 100, True, "Linia – centrum (szczegół)", 24)
    print("sizes:", s1, s2)
    for n, k, nm, c in POI: print(n, k, nm, [round(v) for v in c], "dist", round(math.hypot(*c)))


if __name__ == "__main__":
    main()
