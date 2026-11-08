"""Downloads OSM data for Zakrzewo - Linia - Jezioro Morzyc into data/osm/linia_raw.json.

Data (c) OpenStreetMap contributors, ODbL: credit it in the game and keep this attribution.
Usage: python3 tools/osm/fetch_linia.py
"""
import json, pathlib, sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import overpass

ROOT = pathlib.Path(__file__).resolve().parents[2]
BBOX = "54.435,17.835,54.480,17.965"   # south,west,north,east
QUERY = f"""[out:json][timeout:240];
(
 way["building"]({BBOX});
 way["highway"]({BBOX});
 way["railway"]({BBOX});
 way["waterway"]({BBOX});
 way["natural"~"water|wood|scrub|wetland|heath"]({BBOX});
 way["landuse"~"forest|farmland|meadow|quarry|cemetery|residential|grass|orchard|farmyard|industrial|commercial|retail"]({BBOX});
 way["leisure"~"pitch|sports_centre|park|playground"]({BBOX});
 way["amenity"]({BBOX});
 relation["natural"~"water|wood"]({BBOX});
 relation["landuse"~"forest|quarry|cemetery|farmland"]({BBOX});
 node["amenity"]({BBOX});
 node["shop"]({BBOX});
 node["place"]({BBOX});
);
out geom;"""

if __name__ == "__main__":
    data, used = overpass.query(QUERY)
    out = ROOT / "data/osm/linia_raw.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(data), encoding="utf-8")
    print("mirror:", used, "| elements:", len(data["elements"]), "| saved:", out)
