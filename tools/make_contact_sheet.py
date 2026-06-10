"""
K-Food Master — standalone asset contact sheet (39-spec).
transparent PNG → 흰 배경 합성 + grid montage + label.

Usage: py tools/make_contact_sheet.py
"""
import os, sys
from PIL import Image, ImageDraw, ImageFont

if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "assets-raw", "ingredient_tool_hero_m2")
OUT = os.path.join(ROOT, "assets-raw", "_contact_sheets")
os.makedirs(OUT, exist_ok=True)

SPEC = {
    "ingredient": ["green_onion_whole","green_onion_chopped","green_onion_julienne",
        "carrot_whole","carrot_sliced","carrot_julienne","carrot_diced",
        "kimchi_whole","kimchi_chopped","kimchi_cooked","tofu_block","tofu_cubed",
        "beef_raw","beef_marinated","beef_cooked","egg_whole","egg_cooked",
        "rice_bowl","noodle_raw","noodle_cooked"],
    "tool": ["chef_knife","cutting_board","ladle","spatula","tongs","rolling_mat",
        "seasoning_bottle","spoon","chopsticks"],
    "vessel": ["pot","dolsot","frying_pan","grill_pan","mixing_bowl","noodle_bowl",
        "brass_bowl","wooden_tray","wide_plate","earthenware_bowl"],
}

CELL = 220
PAD = 12
LABEL_H = 24
COLS = 5

def find(name):
    for cand in (f"{name}.png", f"ing_{name}.png", f"tool_{name}.png"):
        p = os.path.join(SRC, cand)
        if os.path.exists(p):
            return p
    return None

def build(group, names):
    rows = (len(names) + COLS - 1) // COLS
    W = COLS * (CELL + PAD) + PAD
    H = rows * (CELL + LABEL_H + PAD) + PAD + 40
    sheet = Image.new("RGB", (W, H), (250, 244, 230))
    d = ImageDraw.Draw(sheet)
    try:
        font = ImageFont.truetype("arial.ttf", 16)
        title = ImageFont.truetype("arialbd.ttf", 24)
    except Exception:
        font = ImageFont.load_default(); title = font
    d.text((PAD, 8), f"{group.upper()}  ({len(names)})", fill=(60, 40, 30), font=title)
    miss = []
    for i, name in enumerate(names):
        r, c = divmod(i, COLS)
        x = PAD + c * (CELL + PAD)
        y = 40 + PAD + r * (CELL + LABEL_H + PAD)
        d.rectangle([x, y, x + CELL, y + CELL], fill=(255, 255, 255), outline=(210, 195, 170))
        p = find(name)
        if p:
            im = Image.open(p).convert("RGBA")
            im.thumbnail((CELL - 16, CELL - 16), Image.LANCZOS)
            bg = Image.new("RGBA", (CELL, CELL), (255, 255, 255, 0))
            bg.paste(im, ((CELL - im.width)//2, (CELL - im.height)//2), im)
            sheet.paste(bg.convert("RGB"), (x, y), bg)
        else:
            miss.append(name)
            d.text((x+8, y+CELL//2), "MISSING", fill=(200,50,50), font=font)
        d.text((x + 4, y + CELL + 4), name, fill=(60, 40, 30), font=font)
    out = os.path.join(OUT, f"contact_{group}.png")
    sheet.save(out)
    print(f"  ✅ contact_{group}.png  ({len(names)-len(miss)}/{len(names)})" + (f"  MISSING={miss}" if miss else ""))
    return miss

print("=" * 50)
print("📋 Standalone asset contact sheet")
print("=" * 50)
all_miss = {}
for g, names in SPEC.items():
    m = build(g, names)
    if m: all_miss[g] = m
print("=" * 50)
print(f"완료 → {OUT}")
if all_miss: print(f"⚠️ MISSING: {all_miss}")
else: print("✅ 39/39 모두 present")
