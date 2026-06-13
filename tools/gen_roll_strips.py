"""
K-Food Master — Roll (김밥) LONG-STRIP standalone assets.

사용자 LOCK (2026-06-07):
  "For Roll, chopped ingredient assets are the wrong visual form. Gimbap fillings must be
   LONG STRIPS that run almost the full width of the rice sheet."
  - 현 roll asset(gimbap_filling_strip_carrot 등)은 julienned matchstick 'bundle'이라 짧고
    작음 → 김밥 속처럼 안 보임. chopped/diced 더미는 절대 금지.
  - 김밥 속 = 김 폭을 가로지르는 left-to-right 긴 단일 띠(continuous band, full width 70-85%).
  - 김/밥 = 가로 우세 wide 직사각. 김발 = 김을 받칠 큰 가로 mat.

성격: **standalone transparent, baked X** (Asset Architecture Lock NEVER-merge mandate).
  - 김발/김/밥/strip 각각 분리 — 함께 굽지 않는다. 합성(김발↓김↓밥↓strip 가로 band)은
    Godot runtime 책임. gameplay X / baked X — standalone asset only.
  - Style Bible v1 톤: warm cozy, Cocoa #3A2A1E outline 3-4px, soft volumetric shading,
    top-left key light. cool sage/mint 금지, flat/UI-icon 금지.
  - 카메라 (2026-06-10 교정): **straight-on OVERHEAD top-down 사용자 시점** — 위에서 똑바로 내려다본
    평평한 수평 직사각 (edge가 frame과 평행). 비스듬 oblique 3/4 / 회전 diamond·parallelogram 금지.

핵심 형태 규칙 (gen_roll_assets.py 의 'bundle of matchsticks'와의 결정적 차이):
  - 각 strip = 가로로 긴 단일 띠 (aspect ratio 가로:세로 >= 5:1, 거의 막대).
  - "single LONG horizontal strip, NOT chopped pieces, NOT a pile, continuous band,
     gimbap filling strip form" 을 prompt 에 강제.
  - 김/밥 = wide 직사각 (가로 우세). 김발 = wide mat.
  - landscape canvas(1536x1024)로 가로 긴 형태 유도.

세트 (사용자 명시 7 asset):
  bamboo_mat_large      — 큰 김발 (가로 wide)
  seaweed_sheet_rect    — 김 한 장 (직사각, 검정-진녹, matte, 가로 wide)
  rice_layer_flat_rect  — 밥 layer (직사각, 흰밥 얇게 펴진, 가로 wide)
  carrot_strip_long     — 당근 긴 가로 strip 한 줄 (주황)
  egg_strip_long        — 계란 지단 긴 가로 strip (노랑)
  green_strip_long      — 시금치/오이 긴 가로 strip (녹색)
  beef_strip_long       — 소고기 긴 가로 strip (갈색)   [kimchi_strip_long alias 가능]

출력:
  assets-raw/roll_assets_m2/{id}.png   → 검수 후 res://art/sprites/roll/{id}.png

Usage:
    py tools/gen_roll_strips.py --background transparent                 # 7장 (default)
    py tools/gen_roll_strips.py --only carrot_strip_long --background transparent
    py tools/gen_roll_strips.py --variant kimchi --background transparent  # beef→kimchi strip

Default:
    model=gpt-image-1 / quality=medium ($0.063/img @1536x1024) / size=1536x1024(landscape) /
    out=roll_assets_m2/ / background=opaque(검수) — production 은 transparent 권장
"""

import argparse
import sys
import time
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT / "tools"))

from gen_image import generate_image, load_api_key  # noqa: E402

if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")

from openai import OpenAI  # noqa: E402


# ─────────────────────────────────────────────────────────────────────────────
# LONG_STRIP_FORM — 모든 filling strip body 에 부착하는 형태 강제 절 (chopped 차단 핵심).
# 이것이 gen_roll_assets.py 와의 결정적 차이: 'bundle of matchsticks' 가 아니라
# 'ONE single continuous LONG horizontal band' 이라고 못박는다.
# ─────────────────────────────────────────────────────────────────────────────
LONG_STRIP_FORM = """
SHAPE — CRITICAL (this is a gimbap FILLING STRIP, NOT chopped food):
ONE single LONG horizontal strip — a single continuous band laid flat and running LEFT-TO-RIGHT
almost the full width of the frame (the band spans ~78-88% of the frame width, lying horizontally
like a filling laid across a sheet of rice). The strip is long and slender (aspect ratio roughly
6:1 to 9:1 — much wider than it is tall, nearly a bar), with softly rounded ends and a gentle
hand-rolled taper. It reads as ONE continuous piece, not many separate pieces.
ABSOLUTELY NOT: chopped pieces, diced cubes, a pile / heap / mound, a scattered bundle of loose
matchsticks, a short stub, a tiny clump, multiple disconnected segments, julienne scattered apart,
a circle, a square, a vertical orientation. It is a SINGLE long horizontal gimbap filling band."""

WIDE_RECT_FORM = """
SHAPE — CRITICAL (this is a WIDE rectangular layer, gimbap base):
ONE single wide rectangular sheet lying flat and oriented HORIZONTALLY (landscape), clearly WIDER
than it is tall (the rectangle spans ~80-90% of the frame width), with softly rounded / gently
uneven corners. It reads as one flat wide sheet across the frame, ready for fillings to be laid
left-to-right on top of it later (in Godot).
ABSOLUTELY NOT: a tall/portrait shape, a square, a small patch, a pile, chopped pieces, a rolled
cylinder, a folded shape. It is a SINGLE flat WIDE horizontal sheet."""


# ─────────────────────────────────────────────────────────────────────────────
# STYLE_SUFFIX — Style Bible v1 일관성 LOCK (gen_roll_assets.py / gen_ingredient_tool_hero
# 와 동일 톤). standalone single hero, baked 금지. 끝 %s 1개 → 교체.
# ─────────────────────────────────────────────────────────────────────────────
STYLE_SUFFIX = """
STYLE (HERO ASSET — NOT a UI icon):
Premium cozy mobile game art in the style of Cooking Diary, Travel Town and Merge Mansion.
A single HERO illustrated object with real VOLUME, LIGHTING, TEXTURE and DEPTH — hand-drawn 2D
game illustration with soft volumetric shading: 2-3 step soft gradient (NEVER flat single-fill,
NEVER one solid color block). Rounded dimensional form, believable thickness, tactile surface
texture.

CONSISTENCY LOCK — every asset in this set MUST share the SAME look (Style Bible v1):
- LIGHTING: a single warm KEY LIGHT from the TOP-LEFT on EVERY asset (consistent direction),
  with a soft rim light and ONE or TWO small specular highlights (a gentle just-prepared sheen —
  NOT a glossy plastic coating). No second/opposite/flat lighting.
- OUTLINE: a warm dark COCOA outline (#3A2A1E) of consistent ~3-4px weight on EVERY asset, with
  slight hand-drawn weight variation (warm, not a cold uniform vector stroke).
- CAMERA — STRAIGHT-ON OVERHEAD TOP-DOWN (PLAYER POV, looking straight DOWN): a clean overhead
  top-down view, the camera directly ABOVE-and-slightly-toward the player looking STRAIGHT DOWN at
  the flat object lying on the table (a steep ~65-75 degree high-angle, very close to a plan view),
  so the LONG HORIZONTAL form reads clearly. The strip / sheet lies FLAT as a HORIZONTAL rectangle
  with its long axis running LEFT-TO-RIGHT and its edges PARALLEL to the frame edges (near edge at
  the bottom, far edge at the top). ABSOLUTELY NOT rotated into a diamond / rhombus / parallelogram,
  NOT a slanted or tilted layout, NOT an oblique 3/4 product/catalog angle, NOT a low hero angle,
  NOT a steep side perspective that hides the horizontal length. Edges square to the frame
  (horizontal and vertical). One consistent straight-on top-down camera across the entire set.
- PALETTE: warm cozy muted palette (mid saturation ~55-78%), appetizing and inviting.

COMPOSITION (STANDALONE — Asset Architecture Lock: never bake co-assets together):
- A SINGLE hero object centered, the long horizontal band/sheet spanning most of the frame width.
- NO bamboo rolling mat under it, NO cutting board, NO plate, NO bowl, NO tray, NO dish, NO knife,
  NO chopsticks, NO hands, NO characters, NO other fillings, NO rice (unless this asset IS the
  rice), NO seaweed (unless this asset IS the seaweed), NO other props, NO kitchen scene, NO text,
  NO labels. This is JUST the one standalone object itself — the layering (mat under seaweed under
  rice under filling strips, laid as horizontal bands) is composited later in Godot.
- A soft warm contact shadow directly beneath the object (cocoa #3A2A1E at ~18-22% alpha) for
  grounded depth — soft, not a hard black ellipse.

BACKGROUND:
- Warm cream background (Rice Cream #FBF3E4), uniform and clean (or a fully transparent cutout
  when transparent background is requested).
- ABSOLUTELY NO cool sage, NO mint, NO teal, NO cold background (deprecated by Style Bible v1).

IMPORTANT — avoid (this must read as a premium hero illustration, NEVER a UI icon, NEVER chopped):
flat vector, flat single-color fill, flat icon, vector clipart, sticker, emoji, pictogram, glyph,
color block, simple geometric shape, symbolic placeholder, silhouette, infographic, app icon,
simplified UI icon, MS paint, amateurish, single flat cel-shade with no volume, Cookie Run
frosting, Toca Boca, over-saturated neon, glossy plastic coating, mirror chrome, cool sage / mint
/ teal background, beige paper / kraft / scrapbook / vintage noise texture, golden hour
overexposed, photorealistic photo, 3D octane / unreal render, food photography, anime, manga,
watermark, any English or Korean text, Japanese sushi maki / nigiri leak, Japanese nori-with-raw
-fish, Chinese cuisine leak, the food sitting on a bamboo mat / board / plate / tray, any second
co-asset baked into the frame, chopped pieces, diced cubes, a pile / heap / mound, a scattered
bundle, a vertical / portrait orientation, a short stub, multiple disconnected segments."""


# ─────────────────────────────────────────────────────────────────────────────
# ROLL LONG-STRIP ASSETS — 사용자 명시 7장. 각 body 끝 %s 2개:
#   첫 %s → 형태 강제(LONG_STRIP_FORM 또는 WIDE_RECT_FORM), 둘째 %s → STYLE_SUFFIX.
# bamboo_mat_large 는 형태 절 없이 STYLE_SUFFIX 만(%s 1개) — mat 자체 형태는 본문에 기술.
# ─────────────────────────────────────────────────────────────────────────────
ROLL_STRIPS = [
    {
        "id": "bamboo_mat_large", "name": "큰 김발 (Large Bamboo Rolling Mat)",
        "form": None,
        "body": """A HERO illustration of a large Korean bamboo rolling mat for gimbap (김발),
laid flat and seen from a STRAIGHT-ON OVERHEAD top-down view (camera directly above looking straight
DOWN, the mat a horizontal rectangle with edges PARALLEL to the frame — NOT rotated to a diamond,
NOT an oblique 3/4 angle): a WIDE landscape rectangular
mat made of many thin pale-golden bamboo slats running PARALLEL across the width (left-to-right),
bound together by
two or three rows of cotton string, oriented HORIZONTALLY and clearly wider than it is tall (spans
~85-90% of the frame width). Warm light-oak bamboo tone (#D6A56B to #C49256) with soft top-left
key light giving each rounded slat a gentle cylindrical highlight and a soft groove shadow between
slats, the far edge softly rolling up. This is JUST the empty bamboo mat — NO seaweed on it, NO
rice, NO filling, NO food of any kind resting on it. A clean wide empty mat ready to receive layers
in Godot. Dimensional and tactile (NOT a flat woven texture swatch, NOT a UI icon).
%s""",
    },
    {
        "id": "seaweed_sheet_rect", "name": "김 한 장 직사각 (Seaweed Sheet, wide rect)",
        "form": WIDE_RECT_FORM,
        "body": """A HERO illustration of a single sheet of Korean roasted seaweed for gimbap
(김 한 장), seen from a STRAIGHT-ON OVERHEAD top-down view (camera directly above looking straight
DOWN, the sheet a horizontal rectangle with edges PARALLEL to the frame — NOT rotated to a diamond,
NOT an oblique 3/4 angle): a flat WIDE rectangular sheet of
dried laver in deep dark green-black (a very dark forest-green fading toward warm near-black, NOT
pure flat black), with a MATTE non-glossy surface and a subtle fine pebbled texture, the edges
gently uneven and softly curling. Soft top-left key light gives the sheet faint volume and a
barely-there satin sheen along the ridges (matte, NOT shiny plastic). This is JUST the empty
seaweed sheet — NO rice on it, NO filling, NO bamboo mat under it.
%s
%s""",
    },
    {
        "id": "rice_layer_flat_rect", "name": "밥 layer 직사각 (Flat Rice Layer, wide rect)",
        "form": WIDE_RECT_FORM,
        "body": """A HERO illustration of a FLAT thin spread LAYER of steamed Korean short-grain
white rice for gimbap (김밥용으로 펴 놓은 평평한 밥 한 겹), seen from a STRAIGHT-ON OVERHEAD top-down
view (camera directly above looking straight DOWN, the rice layer a horizontal rectangle with edges
PARALLEL to the frame — NOT rotated to a diamond, NOT an oblique 3/4 angle): an even WIDE rectangular
slab of glistening sticky white rice pressed flat and
smooth, the many individual plump grains clearly visible across the surface with a gentle moist
steamed sheen, warm cream-white (Rice Cream #FAF4E6) with soft top-left key light and a tender low
thickness (a thin even bed of rice, NOT a heaped mound). This is JUST the flat wide rice layer
itself — NO seaweed under it, NO filling on it, NO mat, NO board.
%s
%s""",
    },
    {
        "id": "carrot_strip_long", "name": "당근 긴 strip (Carrot Long Strip)",
        "form": LONG_STRIP_FORM,
        "body": """A HERO illustration of a SINGLE long carrot strip for gimbap filling
(김밥 속 당근 한 줄), one continuous slender band of cooked seasoned carrot laid flat and running
left-to-right across the frame: warm vivid orange (#E8732C toward #F2A03D), with soft rounded
volume, a subtle moist sheen and tiny freshness highlights, the surface gently faceted like a
hand-cut long batonnet. This is JUST the one carrot filling strip — NO rice, NO seaweed, NO other
filling, NO mat, NO board.
%s
%s""",
    },
    {
        "id": "egg_strip_long", "name": "계란 지단 긴 strip (Egg Long Strip)",
        "form": LONG_STRIP_FORM,
        "body": """A HERO illustration of a SINGLE long Korean fried egg-sheet strip for gimbap
filling (김밥 속 계란 지단 한 줄), one continuous slender band of thin cooked egg sheet (지단) laid flat
and running left-to-right across the frame: warm egg-yolk yellow (#F5B731), a soft springy body
with a faint warm sheen, a gently layered/folded long edge showing its thin pliable thickness, soft
dimensional volume. This is JUST the one egg filling strip — NO rice, NO seaweed, NO other filling,
NO mat, NO board.
%s
%s""",
    },
    {
        "id": "green_strip_long", "name": "초록 채소 긴 strip (Green Veg Long Strip)",
        "form": LONG_STRIP_FORM,
        "body": """A HERO illustration of a SINGLE long green-vegetable strip for gimbap filling
(김밥 속 초록 채소 한 줄 — 시금치나 오이), one continuous slender band of fresh green vegetable (lightly
seasoned spinach gathered into a long band, or a long batonnet of cucumber) laid flat and running
left-to-right across the frame: vivid fresh scallion-green (#7FB04A toward #6FA94B), with soft
rounded volume, a subtle moist sheen and tiny freshness highlights. This is JUST the one green
filling strip — NO rice, NO seaweed, NO other filling, NO mat, NO board.
%s
%s""",
    },
    {
        "id": "beef_strip_long", "name": "소고기 긴 strip (Beef Long Strip)",
        "form": LONG_STRIP_FORM,
        "body": """A HERO illustration of a SINGLE long savory bulgogi-style beef strip for gimbap
filling (김밥 속 소고기 한 줄), one continuous slender band of cooked seasoned beef laid flat and
running left-to-right across the frame: warm browned grill tone (#8A5A32 toward #A6753F) with a
glossy soy-marinade sheen and a couple of small specular highlights, soft rounded volume and a
tender grain along the length. This is JUST the one beef filling strip — NO rice, NO seaweed, NO
other filling, NO mat, NO board.
%s
%s""",
    },
]

# beef → kimchi 대체 variant (사용자 옵션: beef_strip_long 또는 kimchi_strip_long).
KIMCHI_STRIP = {
    "id": "kimchi_strip_long", "name": "김치 긴 strip (Kimchi Long Strip)",
    "form": LONG_STRIP_FORM,
    "body": """A HERO illustration of a SINGLE long kimchi strip for gimbap filling
(김밥 속 김치 한 줄), one continuous slender band of well-fermented napa-cabbage kimchi gathered into a
long band and laid flat running left-to-right across the frame: deep warm gochu red (#D84338 toward
#C9402F) coating soft pale-cream cabbage ribs, with a glossy seasoned sheen and a couple of small
specular highlights, soft rounded volume along the length. This is JUST the one kimchi filling
strip — NO rice, NO seaweed, NO other filling, NO mat, NO board.
%s
%s""",
}


def build_prompt(item: dict) -> str:
    """form 절 + STYLE_SUFFIX 를 body 의 %s 자리에 순서대로 교체."""
    body = item["body"]
    if item.get("form"):
        # 첫 %s → form, 둘째 %s → style
        body = body.replace("%s", item["form"], 1)
        body = body.replace("%s", STYLE_SUFFIX, 1)
    else:
        # bamboo_mat_large: %s 1개 → style
        body = body.replace("%s", STYLE_SUFFIX, 1)
    return body


def collect_jobs(only: set | None, variant: str):
    items = list(ROLL_STRIPS)
    if variant == "kimchi":
        # beef_strip_long 을 kimchi_strip_long 으로 교체
        items = [KIMCHI_STRIP if a["id"] == "beef_strip_long" else a for a in ROLL_STRIPS]
    elif variant == "both":
        items = list(ROLL_STRIPS) + [KIMCHI_STRIP]
    jobs = []
    for a in items:
        if only and a["id"] not in only:
            continue
        jobs.append((a["id"], a["name"], a))
    return jobs


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Roll (김밥) LONG-STRIP standalone assets 생성 (standalone, chopped 금지, baked X)"
    )
    parser.add_argument("--only", type=str, default="",
                        help="콤마구분 asset id만 (예: carrot_strip_long,egg_strip_long)")
    parser.add_argument("--variant", default="beef", choices=["beef", "kimchi", "both"],
                        help="filling 마지막 strip: beef(기본) / kimchi(대체) / both(8장)")
    parser.add_argument("--model", default="gpt-image-1", choices=["dall-e-3", "gpt-image-1"])
    parser.add_argument("--size", default="1536x1024",
                        help="landscape 권장 (긴 가로 strip 유도). gpt-image-1: 1536x1024")
    parser.add_argument("--quality", default="medium", help="gpt-image-1: low/medium/high/auto")
    parser.add_argument("--background", default="opaque",
                        choices=["transparent", "opaque", "auto"],
                        help="transparent=알파 PNG(production) / opaque=Cream bg(검수)")
    parser.add_argument("--out-dir", type=Path,
                        default=PROJECT_ROOT / "assets-raw" / "roll_assets_m2")
    args = parser.parse_args()

    only = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    jobs = collect_jobs(only, args.variant)

    if not jobs:
        sys.exit("❌ 매칭 작업 없음 (--only / --variant 확인)")

    args.out_dir.mkdir(parents=True, exist_ok=True)

    # 비용: gpt-image-1 1536x1024 medium ≈ $0.063/img (1024² medium $0.042 대비 가로 비례).
    is_landscape = args.size in ("1536x1024", "1024x1536")
    unit_map = {"low": 0.016, "medium": 0.063, "high": 0.25, "auto": 0.063}
    unit_sq = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
    if args.model == "dall-e-3":
        unit = 0.080 if args.quality == "hd" else 0.040
    else:
        unit = (unit_map if is_landscape else unit_sq).get(args.quality, 0.063 if is_landscape else 0.042)
    est_total = unit * len(jobs)

    print("=" * 72)
    print("🍙 Roll LONG-STRIP standalone 생성 (Style Bible v1, chopped 금지, baked X)")
    print(f"   variant={args.variant} only={sorted(only) if only else '-'}")
    print(f"   모델={args.model} 품질={args.quality} 사이즈={args.size}(landscape) 배경={args.background}")
    print(f"   대상: {len(jobs)}장  비용예상: ${unit:.3f}/장 × {len(jobs)} = ${est_total:.2f}")
    print(f"   출력: {args.out_dir}")
    print("=" * 72)

    client = OpenAI(api_key=load_api_key())
    successes, failures = [], []
    t0 = time.time()

    for i, (item_id, name, item) in enumerate(jobs, 1):
        fname = f"{item_id}.png"
        out_path = args.out_dir / fname
        prompt = build_prompt(item)

        print(f"\n[{i}/{len(jobs)}] {name} → {fname}")
        t_start = time.time()
        try:
            generate_image(
                client=client, prompt=prompt, output_path=out_path,
                model=args.model, size=args.size, quality=args.quality,
                background=args.background,
            )
            print(f"   ⏱️  {time.time() - t_start:.1f}s")
            successes.append(fname)
        except Exception as exc:
            print(f"   ❌ FAIL ({time.time() - t_start:.1f}s): {exc!r}")
            failures.append((fname, repr(exc)))

    print("\n" + "=" * 72)
    print(f"✅ 완료: {len(successes)}/{len(jobs)} — 총 {(time.time() - t0)/60:.1f}분")
    if failures:
        print(f"   실패 {len(failures)}장:")
        for fname, err in failures:
            print(f"     - {fname}: {err}")
    print(f"   비용 예상: ${unit * len(successes):.2f}")
    print(f"   경로: {args.out_dir}")
    print("   → 검수 후 res://art/sprites/roll/ 배포 (godot-dev: ArtRegistry roll long-strip key)")
    print("=" * 72)


if __name__ == "__main__":
    main()
