"""Joins docs/look/arch/<archetype>.png (tools/archetypes_shot.gd) into one labelled sheet docs/look/archetypes.png."""
import json, pathlib
from PIL import Image, ImageDraw, ImageFont
ROOT = pathlib.Path(__file__).resolve().parents[2]
arch = json.loads((ROOT / "data/buildings/archetypes.json").read_text(encoding="utf-8"))
names = arch["order"]
cols, w, h = 4, 480, 360
rows = (len(names) + cols - 1) // cols
sheet = Image.new("RGB", (cols * w, rows * h), (20, 20, 20))
d = ImageDraw.Draw(sheet)
font = None
for f in ["/usr/share/fonts/dejavu-sans-fonts/DejaVuSans.ttf", "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"]:
    if pathlib.Path(f).exists():
        font = ImageFont.truetype(f, 15)
        break
for i, n in enumerate(names):
    x, y = (i % cols) * w, (i // cols) * h
    sheet.paste(Image.open(ROOT / f"docs/look/arch/{n}.png").convert("RGB"), (x, y))
    label = f"{i + 1}. {arch['types'][n]['label']}"
    d.rectangle([x, y, x + w, y + 22], fill=(0, 0, 0))
    d.text((x + 6, y + 5), label, fill=(255, 220, 120), font=font)
sheet.save(ROOT / "docs/look/archetypes.png")
print("sheet:", len(names))
