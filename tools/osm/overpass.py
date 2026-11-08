"""Tiny Overpass client with mirror fallback (the main server often returns 502)."""
import json, sys, urllib.parse, urllib.request

MIRRORS = ["https://overpass.private.coffee/api/interpreter",
           "https://overpass-api.de/api/interpreter",
           "https://overpass.kumi.systems/api/interpreter"]


def query(text, timeout=420):
    last = None
    for url in MIRRORS:
        try:
            req = urllib.request.Request(url, data=urllib.parse.urlencode({"data": text}).encode(),
                                         headers={"User-Agent": "empty-night-research"})
            return json.load(urllib.request.urlopen(req, timeout=timeout)), url
        except Exception as exc:  # network errors differ per mirror; try the next one
            last = f"{url}: {exc}"
            print("  mirror failed ->", last, file=sys.stderr)
    raise RuntimeError(last)
