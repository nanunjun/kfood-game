"""
K-Food Master — Roll-stage standalone assets + content-only food generation.

사용자 발견 (2026-06-07):
  - Roll module이 완성 김밥 hero(premium_v2, 접시 baked)를 처음부터 표시 → 실제 마는
    과정(김+밥+재료 → 말기 → 완성)이 아님 (HARD RULE HR1 위반).
  - Plate module이 vessel(L2) 위에 dish_with_vessel 완성샷(L3)을 올려 "그릇 위에 그릇"
    (HARD RULE HR2 위반).
docs/art/cooking-realism-audit.md 의 §2(roll 7 asset) + §3(content_only) 구현 driver.

성격: **standalone transparent, baked X** (Asset Architecture Lock NEVER-merge mandate).
  - 김발/도마/쟁반/그릇과 함께 굽지 않는다 (합성은 Godot runtime 책임).
  - Style Bible v1 톤: warm cozy, Cocoa #3A2A1E outline 3-4px, soft volumetric shading,
    top-left key light, 3/4 view slight overhead. cool sage/mint 금지, flat/UI-icon 금지.

세트:
  --set roll     : roll 7 asset (김 / 밥 layer / 3 filling strip / halfway / finished content-only)
  --set content  : content-only food (그릇 없는 음식 내용물 — bibimbap 등)
  --set all      : roll + content 전부

출력:
  roll:    assets-raw/roll_assets_m2/{id}.png       → res://art/sprites/roll/{id}.png
  content: assets-raw/roll_assets_m2/{id}.png       → res://art/sprites/food_content/{id}.png
  (검수 후 main thread/godot-dev가 assets-processed → res:// 배포)

Usage:
    py tools/gen_roll_assets.py --background transparent              # roll 7장 (default set=roll)
    py tools/gen_roll_assets.py --set all --background transparent    # roll 7 + content (bibimbap)
    py tools/gen_roll_assets.py --set content --background transparent # content-only만
    py tools/gen_roll_assets.py --only gimbap_roll_halfway --background transparent  # 일부 재생성
    py tools/gen_roll_assets.py --only bibimbap_content_only --background transparent

Default:
    model=gpt-image-1 / quality=medium ($0.042/img) / size=1024x1024 /
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
# STYLE_SUFFIX_HERO — gen_ingredient_tool_hero.py 와 동일 일관성 LOCK (Style Bible v1).
# 모든 roll/content asset prompt 끝에 %s 1개로 부착. standalone single hero, baked 금지.
# ─────────────────────────────────────────────────────────────────────────────
STYLE_SUFFIX_HERO = """
STYLE (HERO ASSET — NOT a UI icon):
Premium cozy mobile game art in the style of Cooking Diary, Travel Town and Merge Mansion
ITEM QUALITY — a single HERO illustrated object with real VOLUME, LIGHTING, TEXTURE and DEPTH.
This is hand-drawn 2D game illustration with soft volumetric shading: 2-3 step soft gradient
(NEVER flat single-fill, NEVER one solid color block). Rounded dimensional form, believable
thickness and depth, tactile surface texture (the grain of the rice, the matte sheen of the
seaweed, the soft body of each cut filling strip).

CONSISTENCY LOCK — every asset in this set MUST share the SAME look (Style Bible v1):
- LIGHTING: a single warm KEY LIGHT from the TOP-LEFT on EVERY asset (consistent direction),
  with a soft rim light and ONE or TWO small specular highlights (a gentle just-prepared sheen —
  NOT a glossy plastic coating). No second/opposite/flat lighting.
- OUTLINE: a warm dark COCOA outline (#3A2A1E) of consistent ~3-4px weight on EVERY asset, with
  slight hand-drawn weight variation (warm, not a cold uniform vector stroke). Same thickness
  across all items.
- CAMERA: the SAME 3/4 view with a slight overhead tilt (gentle high angle looking slightly down)
  on EVERY asset — one consistent camera angle family across the whole set (never a flat front-on
  elevation, never a pure top-down flat-lay, never a low hero angle).
- PALETTE: warm cozy muted palette (mid saturation ~55-78%), appetizing and inviting, consistent
  warmth across the set.

COMPOSITION (STANDALONE — Asset Architecture Lock: never bake co-assets together):
- A SINGLE hero object centered, occupying ~60-72% of the frame with comfortable margins.
- NO bamboo rolling mat (김발), NO cutting board, NO plate, NO bowl, NO tray, NO dish, NO pot,
  NO knife, NO chopsticks, NO hands, NO characters, NO other props, NO kitchen scene, NO text,
  NO labels. This is JUST the standalone food content itself — composition with the mat / board /
  vessel is done later in Godot (the art must NEVER pre-bake the mat or any vessel under it).
- A soft warm contact shadow directly beneath the object (cocoa #3A2A1E at ~18-22% alpha)
  for grounded depth — soft, not a hard black ellipse.

BACKGROUND:
- Warm cream background (Rice Cream #FBF3E4), uniform and clean for a tidy hero presentation
  (or a fully transparent cutout when transparent background is requested).
- ABSOLUTELY NO cool sage, NO mint, NO teal, NO cold background (deprecated by Style Bible v1).

IMPORTANT — avoid (this asset must read as a premium hero illustration, NEVER as a UI icon):
flat vector, flat single-color fill, flat icon, vector clipart, sticker, emoji, pictogram, glyph,
color block, simple geometric shape, symbolic placeholder, silhouette, infographic style,
instructional diagram, recipe-card icon, app icon, simplified UI icon, MS paint, amateurish,
cold uniform thin outline used alone to fake a flat shape, single flat cel-shade with no volume,
Cookie Run frosting, Toca Boca, over-saturated neon, glossy plastic coating, mirror chrome,
cool sage / mint / teal background, beige paper / kraft / scrapbook / vintage noise texture,
golden hour overexposed, photorealistic photo, 3D octane / unreal render, food photography,
anime, manga, watermark, any English or Korean text, Japanese sushi maki / nigiri leak,
Japanese nori-with-raw-fish, Chinese cuisine leak, the food sitting on a bamboo mat / board /
plate / tray, any second co-asset baked into the frame (this MUST be a standalone single item)."""


# ─────────────────────────────────────────────────────────────────────────────
# ROLL ASSETS — 김밥 마는 과정 standalone (사용자 명시 7장).
# 각 항목: id / name / body (끝 %s 1개 → STYLE_SUFFIX_HERO 교체).
# 출력 → res://art/sprites/roll/{id}.png (godot-dev get_roll_asset 키).
# ─────────────────────────────────────────────────────────────────────────────
ROLL_ASSETS = [
    {
        "id": "seaweed_sheet", "name": "김 한 장 (Seaweed Sheet)",
        "body": """A HERO illustration of a single sheet of Korean roasted seaweed for gimbap (김 한 장),
tilted top-down 3/4 view: a flat rectangular sheet of dried laver in deep dark green-black
(very dark forest-green fading toward warm near-black, NOT pure flat black), with a MATTE
non-glossy surface and a subtle fine pebbled texture, the edges gently uneven and softly curling
up. Soft top-left key light gives the sheet faint volume and a barely-there satin sheen along the
ridges (matte, NOT shiny plastic). This is JUST the empty seaweed sheet — NO rice on it, NO
filling, NO bamboo mat, NO board under it. Dimensional and tactile (NOT a flat black rectangle
icon).
%s""",
    },
    {
        "id": "rice_layer_flat", "name": "밥 평평 layer (Flat Rice Layer)",
        "body": """A HERO illustration of a FLAT spread LAYER of steamed Korean short-grain white rice
(김밥용으로 펴 놓은 평평한 밥 한 겹), tilted top-down 3/4 view: an even rectangular slab of glistening
sticky white rice pressed flat and smooth, the many individual plump grains clearly visible across
the surface with a gentle moist steamed sheen, warm cream-white (Rice Cream #FAF4E6) with soft
top-left key light and a tender low dimensional thickness (a thin even bed of rice, NOT a heaped
mound). This is JUST the flat rice layer itself — NO seaweed under it, NO filling, NO mat, NO
board. Soft and appetizing (NOT a flat white rectangle icon).
%s""",
    },
    {
        "id": "gimbap_filling_strip_carrot", "name": "당근 채 strip (Carrot Filling Strip)",
        "body": """A HERO illustration of a SINGLE long neat STRIP / row of julienned cooked carrot for
gimbap filling (김밥 속 당근 채 한 줄), 3/4 view: many thin even bright-orange carrot matchsticks
lined up together into one long horizontal bundle-strip (the way a filling row is laid across a
gimbap), each matchstick with soft rounded volume and a subtle moist sheen, vivid warm orange,
tiny freshness highlights, the strip slightly tapering at the ends. This is JUST the single carrot
filling strip — NO rice, NO seaweed, NO other filling, NO mat, NO board. Dimensional and tactile
(NOT a flat orange bar icon).
%s""",
    },
    {
        "id": "gimbap_filling_strip_egg", "name": "계란 지단 strip (Egg Filling Strip)",
        "body": """A HERO illustration of a SINGLE long neat STRIP / row of Korean fried egg sheet
(지단) cut for gimbap filling (김밥 속 계란 지단 한 줄), 3/4 view: a long soft golden-yellow strip of
thin cooked egg sheet (warm egg-yolk yellow #F5B731), with a soft springy body, a gently folded
or layered edge showing its thin pliable thickness, a faint warm sheen and soft dimensional
volume, the strip slightly tapering at the ends. This is JUST the single egg filling strip — NO
rice, NO seaweed, NO other filling, NO mat, NO board. Dimensional and appetizing (NOT a flat
yellow bar icon).
%s""",
    },
    {
        "id": "gimbap_filling_strip_green", "name": "초록 채소 strip (Green Filling Strip)",
        "body": """A HERO illustration of a SINGLE long neat STRIP / row of green vegetable filling for
gimbap (김밥 속 초록 채소 한 줄 — 시금치나 오이 채), 3/4 view: a long bundle-strip of fresh green
vegetable (lightly seasoned spinach or julienned cucumber) laid into one horizontal row, vivid
fresh scallion-green (#7FB04A) with soft rounded volume on each strand and a subtle moist sheen,
tiny freshness highlights, the strip slightly tapering at the ends. This is JUST the single green
filling strip — NO rice, NO seaweed, NO other filling, NO mat, NO board. Dimensional and fresh
(NOT a flat green bar icon).
%s""",
    },
    {
        "id": "gimbap_roll_halfway", "name": "반쯤 말린 김밥 (Half-rolled Gimbap)",
        "body": """A HERO illustration of a HALF-ROLLED Korean gimbap caught mid-roll (반쯤 말린 김밥),
3/4 view: one side has already curled into a tight dark-seaweed cylinder showing a hint of the
spiraled rice-and-filling cross-section starting to form, while the OTHER side is still an
unrolled flat flap of seaweed with a bed of white rice and colorful filling strips (orange carrot,
yellow egg, green vegetable) still visible and not yet wrapped — clearly a roll IN PROGRESS, not
finished. Soft top-left key light, dark green-black matte seaweed (NOT pure black), warm
appetizing colors, soft volumetric depth on the forming cylinder. This is JUST the half-rolled
gimbap itself — NO bamboo rolling mat, NO board, NO plate, NO hands under or around it (the mat is
composited separately in Godot). Dimensional and appetizing (NOT a flat icon).
%s""",
    },
    {
        "id": "gimbap_roll_finished_content_only",
        "name": "완성 김밥 roll (content only)",
        "body": """A HERO illustration of ONE finished tightly-rolled Korean gimbap cylinder
(완성된 김밥 한 줄, content only), 3/4 view: a firm round log of gimbap wrapped in glossy-matte dark
green-black seaweed (NOT pure black), with one end showing the neat colorful spiral cross-section
(white rice ring around orange carrot, yellow egg, green vegetable, pink/tan fillings) and maybe
ONE freshly cut round slice resting just beside the cut end to show the cross-section. Soft
top-left key light, a gentle sesame-oil sheen along the seaweed, warm appetizing colors, soft
volumetric round form. IMPORTANT: this is the gimbap CONTENT ONLY — NO cutting board, NO bamboo
mat, NO plate, NO tray, NO dish, NO vessel of any kind under or around it (the serving board /
plate is composited separately in Godot). The gimbap roll alone is the standalone hero.
%s""",
    },
]


# ─────────────────────────────────────────────────────────────────────────────
# CONTENT-ONLY FOODS — 그릇 없는 음식 내용물 (audit §3, P1 bibimbap 이번 생성 / 나머지 list).
# premium_v2 finished dish는 그릇 baked(dish_with_vessel) → Plate에서 그릇 위 그릇.
# content_only = vessel(L2) 위에 자연스럽게 담기는 음식 mound 만.
# 출력 → res://art/sprites/food_content/{id}.png (godot-dev food_content_only 키).
# ─────────────────────────────────────────────────────────────────────────────
CONTENT_FOODS = [
    {
        "id": "bibimbap_content_only", "name": "비빔밥 content (Bibimbap, no bowl)",
        "priority": True,
        "body": """A HERO illustration of Korean bibimbap CONTENT WITHOUT ANY BOWL (비빔밥 내용물만 —
그릇 없이), 3/4 view: a rounded mound of steamed white rice topped with neatly arranged radial
sections of colorful namul — sauteed green spinach, vivid orange julienned carrot, pale bean
sprouts, savory browned sliced beef, and a single glossy sunny-side-up fried egg with a domed
golden-orange yolk resting in the center, a small sprinkle of sesame. The toppings fan out in a
tidy circular arrangement over the rice. NO red gochujang paste in it. Soft top-left key light,
warm appetizing colors, soft volumetric depth on every topping. IMPORTANT: render ONLY the food
mound itself shaped as a soft rounded dome — NO bowl, NO dish, NO plate, NO vessel of ANY kind
under or around it (the brass bowl is composited separately in Godot). The bibimbap food mound
alone is the standalone hero (the filename says content_only — render only the food).
%s""",
    },
    # ── 나머지 content_only는 audit §3 list (P2~). 필요 시 아래에 추가 후 --only 로 생성. ──
    # ramyeon_content_only (P2) / tteokbokki_content_only (P3) / janchi_guksu_content_only (P3)
    # / kimchi_stew_content_only (P3) — 현재는 vessel fallback로 충분하여 미정의.
]


def build_prompt(body: str) -> str:
    """body의 첫 %s를 STYLE_SUFFIX_HERO로 교체 (.replace로 다른 % 안전 보존)."""
    return body.replace("%s", STYLE_SUFFIX_HERO, 1)


def collect_jobs(which_set: str, only: set | None, priority_only: bool):
    """(kind, id, name, body) 작업 리스트. kind = 'roll' | 'content'."""
    jobs = []
    if which_set in ("roll", "all"):
        for a in ROLL_ASSETS:
            if only and a["id"] not in only:
                continue
            jobs.append(("roll", a["id"], a["name"], a["body"]))
    if which_set in ("content", "all"):
        for f in CONTENT_FOODS:
            if only and f["id"] not in only:
                continue
            if priority_only and not f.get("priority"):
                continue
            jobs.append(("content", f["id"], f["name"], f["body"]))
    return jobs


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Roll-stage standalone assets + content-only food 생성 (standalone, baked X)"
    )
    parser.add_argument("--set", default="roll", choices=["roll", "content", "all"],
                        help="roll=김밥 마는 과정 7장 / content=그릇 없는 음식 / all=둘 다")
    parser.add_argument("--only", type=str, default="",
                        help="콤마구분 asset id만 (예: gimbap_roll_halfway,bibimbap_content_only)")
    parser.add_argument("--priority", action="store_true",
                        help="content set에서 priority(bibimbap)만")
    parser.add_argument("--model", default="gpt-image-1", choices=["dall-e-3", "gpt-image-1"])
    parser.add_argument("--size", default="1024x1024")
    parser.add_argument("--quality", default="medium",
                        help="gpt-image-1: low/medium/high/auto")
    parser.add_argument("--background", default="opaque",
                        choices=["transparent", "opaque", "auto"],
                        help="transparent=알파 PNG(production 권장) / opaque=Cream bg(검수)")
    parser.add_argument("--out-dir", type=Path,
                        default=PROJECT_ROOT / "assets-raw" / "roll_assets_m2")
    args = parser.parse_args()

    only = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    jobs = collect_jobs(args.set, only, args.priority)

    if not jobs:
        sys.exit("❌ 매칭 작업 없음 (--set / --only / --priority 확인)")

    args.out_dir.mkdir(parents=True, exist_ok=True)

    unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
    if args.model == "dall-e-3":
        unit = 0.080 if args.quality == "hd" else 0.040
    else:
        unit = unit_map.get(args.quality, 0.042)
    est_total = unit * len(jobs)

    print("=" * 72)
    print("🍙 Roll-stage standalone + content-only 생성 (Style Bible v1, baked X)")
    print(f"   세트={args.set} priority={args.priority} "
          f"only={sorted(only) if only else '-'}")
    print(f"   모델={args.model} 품질={args.quality} 사이즈={args.size} 배경={args.background}")
    print(f"   대상: {len(jobs)}장  비용예상: ${unit:.3f}/장 × {len(jobs)} = ${est_total:.2f}")
    print(f"   출력: {args.out_dir}")
    print("=" * 72)

    client = OpenAI(api_key=load_api_key())
    successes, failures = [], []
    t0 = time.time()

    for i, (kind, item_id, name, body) in enumerate(jobs, 1):
        fname = f"{item_id}.png"
        out_path = args.out_dir / fname
        prompt = build_prompt(body)

        print(f"\n[{i}/{len(jobs)}] {name} ({kind}) → {fname}")
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
    print("   → 검수 후 roll: res://art/sprites/roll/ , content: res://art/sprites/food_content/ 배포")
    print("=" * 72)


if __name__ == "__main__":
    main()
