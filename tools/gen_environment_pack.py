"""
K-Food Master — Art Production Sprint 1 / Priority 2: Environment Pack (L1~L5).

5 cooking environments = 5 PNG. Style Bible v1 §6 (warm wood / soft depth / Korean
texture as warmth, NOT noise — Travel Town layering + warm wood). These are the
PROGRESSION cooking environments (player growth L1 → L5 = environment upgrade), and
are DIFFERENT from the existing BG-01~05 market storefronts (those are ingredient
shops). These are the backdrops the player cooks in.

  L1 Home Kitchen      — 집 부엌: cream wall + oak countertop, rice cooker, kimchi
                         fridge, small dolsot shelf. shallow 1-step depth.
  L2 Snack Shop (분식집) — 동네 분식집: warm tile + melamine tone, tteokbokki griddle,
                         eomuk broth pot, hand-written menu (text = Godot overlay).
                         counter front/back 2-step depth.
  L3 Market (재래시장)   — 재래시장 가판: wood stall + curved tile-roof neighbor
                         silhouettes, onggi, sacks, Namdaemun warm tone. 3-step depth.
  L4 Food Alley (먹자골목)— 먹자골목 밤: warm lantern + wood, pojangmacha tent, charcoal
                         brazier glow, hangul sign (overlay). alley depth + lantern bokeh.
  L5 Prestige (한정식)    — 고급 한정식: dark walnut + brass + hanji tone, brass bowl
                         display, hanji lighting, soban tray. full depth + brass sheen.

Parallax: each environment is generated as a SINGLE warm composite that is already
LAYER-READABLE (clear foreground counter band / mid-ground signature props / muted
warm-gray background silhouettes with명도 separation) so the godot-dev can slice it
into parallax layers, OR re-run a specific layer pass later. Recommendation captured
in docs/art/asset-production-sprint1.md: single composite first (cheaper, faster to
validate the L1→L5 warm-tone progression), then layer-split in Godot via region
crops; a full per-layer generation pass is only worth it for L4/L5 if真 parallax depth
is needed for store screenshots.

BG에 캐릭터 비포함 (Style Bible §6.2) — empty environment, character is composited as
a Godot layer.

Usage:
    py tools/gen_environment_pack.py                          # 5장 전체
    py tools/gen_environment_pack.py --only L1                # L1만 (test 먼저)
    py tools/gen_environment_pack.py --only L1,L5             # 일부
    py tools/gen_environment_pack.py --quality high           # 고품질

Default:
    model    = gpt-image-1
    quality  = medium ($0.042/img × 5 = ~$0.21 total)
    size     = 1536x1024 (wide landscape — cooking backdrop)
    out_dir  = assets-raw/environment_pack_m2/
    version  = v1
    파일명   = {level_id}_{name}_{version}.png  (예: L1_home_kitchen_v1.png)
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
# STYLE_SUFFIX_ENV — L1~L5 5장 공통 suffix. Style Bible v1 §6 (warm wood / soft
# depth layering / Korean texture as warmth) + §1 4-lock (Cocoa outline, warm
# palette, soft shading, BG Cream). parallax-ready layer separation 강조.
# ─────────────────────────────────────────────────────────────────────────────
STYLE_SUFFIX_ENV = """Format: wide landscape (cooking backdrop, 1536x1024).
View: slight three-quarter angle (a touch of perspective for a cozy game
environment — NOT strict isometric, NOT a flat front elevation). This is an EMPTY
cooking environment: NO people, NO customers, NO cook in the scene (the character
is composited later as a separate Godot layer).

Style: warm cozy premium-casual mobile game environment, Cooking Diary warm kitchen
+ Travel Town warm wood and soft depth + Animal Restaurant muted cozy storybook
warmth. Clean 2D hand-drawn illustration, soft volumetric shading. NOT Royal Match
over-saturated glossy, NOT hyper-casual flat, NOT photorealistic.

PARALLAX-READY LAYERING (Style Bible §6.2 Travel Town depth — IMPORTANT):
- Compose in 3 readable depth bands so this can be sliced into parallax layers later:
  (1) FOREGROUND = the cooking counter / cooktop band along the lower third, the most
  detailed and warmly lit, where the food and tools sit. (2) MID-GROUND = the
  signature Korean props (shelves, pots, displays) at mid height. (3) BACKGROUND =
  muted warm-gray silhouettes / wall, lower contrast, pushed back by value (명도)
  difference — NOT blur, just flatter muted shapes.
- Use a soft warm drop shadow under each foreground object (Cocoa #3A2A1E at ~18-25%
  alpha) to separate it from the layer behind. Depth comes from value separation +
  soft shadow, NOT from photographic depth-of-field blur.
- Leave the central cooking area uncluttered (empty counter space ready for the food
  and the composited character).

WARM WOOD (Style Bible §6.2 / §2.2):
- Wood surfaces (countertop, stall, furniture) use Oak #D6A56B for the lit top and
  Walnut #A6753F for the side/shadow. Wood grain is just 2-3 subtle line accents, NOT
  a heavy realistic wood texture, NOT scrapbook noise.

KOREAN TEXTURE = WARMTH BY FORM (Style Bible §6.2 / §6.3 — NOT noise):
- Korean identity comes from FORMS: 뚝배기 dolsot stone pots, 놋그릇 brass bowls, onggi
  pottery, 소반 low tray, hanji paper lamps, 기와 curved tile roof silhouettes,
  pojangmacha tent shape. Render these as clean warm shapes, NOT via gritty paper
  noise. Any tent/awning is a single color + 1 accent (NO red-green-white Italian
  flag stripes — LOCK).

OUTLINE + PALETTE (Style Bible §1 4-lock + §2):
- Cocoa #3A2A1E outline 3-4px on foreground objects (warm dark, NOT pure black,
  slightly hand-drawn). Background silhouettes can use a softer/thinner outline.
- Warm palette: BG Cream #FBF3E4 / Steamed #FFFCF6 walls and light, Oak #D6A56B +
  Walnut #A6753F wood, Persimmon #E8732C and Sesame Gold #F2B33D warm accents,
  Brass #B98A3E for prestige metal. Mid-saturation 55-78% (Animal Restaurant muted),
  NOT Royal Match 80-90% punch.

Important: avoid Cool Sage background, cool mint walls, teal dominant (these are the
OLD deprecated tone — use warm cream/wood instead), Royal Match over-saturated
glossy, hyper-casual flat single fill, scrapbook noise texture, grunge, kraft paper,
heavy realistic wood grain texture, heavy clay tile texture, gradient mesh,
multi-layer complex glossy shading, photographic depth-of-field blur,
photorealistic, 3D render, octane or unreal engine, painterly watercolor,
golden hour overexposed, sunset dramatic over-saturated lighting, atmospheric haze,
people, customers, cook, shop owner, any human figure in the scene,
red-green-white striped awning, Italian flag awning, tent of italian colors,
Chinese pagoda multi-tier roof, Chinese red lantern with characters, chinatown gate,
Japanese noren curtain, kanji signage, izakaya, ramen-ya, Tokyo, Tsukiji,
mortar and pestle (절구),
any English or Korean text legibly readable (signage shows an icon-first block or a
placeholder block; all real text is added later as Godot UI overlay)."""


# ─────────────────────────────────────────────────────────────────────────────
# L1~L5 ENVIRONMENT PROMPTS — Style Bible §6.1 진화 규약 (L1 소박 → L5 brass 고급).
# 각 항목: id / name / body. STYLE_SUFFIX_ENV는 %s 위치에 자동 삽입.
# ─────────────────────────────────────────────────────────────────────────────
ENVIRONMENTS = [
    {
        "id": "L1",
        "name": "home_kitchen",
        "body": """A warm cozy mobile game COOKING ENVIRONMENT backdrop: a Korean HOME
KITCHEN (집 부엌), slight three-quarter view, empty and ready for cooking. This is the
starter environment (Level 1) — modest, warm, homey.

FOREGROUND (cooking counter band, lower third): a warm OAK #D6A56B wooden kitchen
countertop with a Walnut #A6753F shadowed front edge, holding a simple modern cooktop
/ gas burner area in the center, left empty and uncluttered (ready for the food and
the composited cook character). A small wooden cutting board rests to one side.

MID-GROUND (signature Korean home props): a cream / Steamed #FFFCF6 kitchen wall behind
the counter. On the wall or a small shelf: a Korean RICE COOKER (밥솥, friendly rounded
white-and-warm shape), a small KIMCHI FRIDGE (김치냉장고) as a compact warm appliance, and
a small shelf holding 1-2 little 뚝배기 dolsot stone pots (Dolsot Charcoal #4A3B30 warm
质감, NOT black) and a brass-toned bowl. A small window with warm cream light, simple
curtain.

BACKGROUND (shallow 1-step depth): the cream wall as a soft muted backdrop, a hint of a
warm-gray silhouette of an upper cabinet pushed back by value.

Warm afternoon home lighting (cozy but NOT golden-hour overexposed). The whole scene
reads "small warm home kitchen, just starting out." cream + oak dominant.

%s

Important also: this is the MODEST starter level — keep it simple and homey, NOT
luxurious yet (the brass/prestige tone is reserved for L5). NO market roof, NO shop
signage (this is a private home kitchen, not a shop). NO people. Korean identity from
the rice cooker + dolsot pot + kimchi fridge forms.""",
    },
    {
        "id": "L2",
        "name": "snack_shop",
        "body": """A warm cozy mobile game COOKING ENVIRONMENT backdrop: a Korean
neighborhood SNACK SHOP (분식집 / bunsikjip), slight three-quarter view, empty and ready
for cooking. This is Level 2 — a friendly casual street snack spot, a step up from the
home kitchen.

FOREGROUND (cooking counter band, lower third): a warm griddle-front counter. The hero
prop is a large flat TTEOKBOKKI GRIDDLE / 철판 (a wide shallow steel griddle pan with a
warm red tteokbokki-sauce tone hint along the edges, left mostly empty and ready) plus a
warm melamine-toned counter (warm tile / Oak #D6A56B counter front). Beside it, a round
EOMUK (fish-cake) BROTH POT (어묵 국물통) — a tall warm stainless pot with a few skewers,
gentle steam wisp implied.

MID-GROUND (분식집 signature): a warm tiled back wall (warm cream-and-terracotta tile
tone), a small hand-written-style MENU BOARD on the wall (show it as an ICON-FIRST block
or a placeholder block — NO real legible text; real menu text is a Godot overlay), and a
shelf with melamine bowls and squeeze bottles.

BACKGROUND (2-step depth): the tiled wall as the muted backdrop, a warm-gray silhouette
of the shop interior pushed back by value, a hint of a doorway with warm light.

Warm casual daytime lighting, friendly and a bit lively. terracotta-warm tile + steel
griddle + melamine. reads "cozy neighborhood 분식집."

%s

Important also: this is a casual Korean street snack shop (분식집) — warm, friendly,
slightly more equipped than the home kitchen but NOT fancy. The menu board is an
icon/placeholder block, NO legible Korean text in the image. NO people.""",
    },
    {
        "id": "L3",
        "name": "traditional_market",
        "body": """A warm cozy mobile game COOKING ENVIRONMENT backdrop: a Korean
TRADITIONAL MARKET cooking stall (재래시장 가판), slight three-quarter view, empty and
ready for cooking. This is Level 3 — an open-air market stall with neighbor shops behind,
busier identity than L2.

FOREGROUND (cooking counter band, lower third): a sturdy warm WOOD MARKET STALL counter
(Oak #D6A56B top, Walnut #A6753F shadowed front) with a cooking surface in the center,
left empty and ready. A couple of warm onggi pottery jars (Walnut #A6753F earthen tone)
and a stack of fresh ingredients sit to one side as the market signature.

MID-GROUND (재래시장 signature): a warm single-color stall cloth/canopy edge (single warm
color + 1 accent — NO red-green-white Italian stripes), market crates and produce baskets,
a hanging bundle prop. Korean market warmth (Namdaemun / Gwangjang tone).

BACKGROUND (3-step depth): muted warm-gray silhouettes of NEIGHBORING MARKET SHOPS with
curved 기와 tile-roof eave silhouettes receding into the distance (the bustling market
behind, pushed back by value separation — flatter muted shapes, NOT detailed). This is the
hero of L3's depth: a real sense of a market street behind the stall.

Warm bright market daytime, lively but cozy. warm wood + onggi + market depth. reads
"open Korean traditional market stall."

%s

Important also: depth is the upgrade at L3 — clearly show 2-3 receding layers (own stall
foreground → signature props mid → neighbor-shop 기와-roof silhouettes background). The
canopy is a single warm color + 1 accent, NO Italian flag stripes. NO people. Korean
identity from onggi + 기와 roof silhouettes + market crate forms.""",
    },
    {
        "id": "L4",
        "name": "food_alley",
        "body": """A warm cozy mobile game COOKING ENVIRONMENT backdrop: a Korean FOOD
ALLEY at night (먹자골목 밤 / pojangmacha alley), slight three-quarter view, empty and ready
for cooking. This is Level 4 — a warm evening street-food alley, the most atmospheric
level so far (warm lantern glow, NOT dark gloomy).

FOREGROUND (cooking counter band, lower third): a POJANGMACHA street-food cart counter
(포장마차) — a warm wood + steel cart counter with a cooktop and a CHARCOAL BRAZIER (연탄불 /
grill) giving a soft warm orange glow (Persimmon #E8732C glow, subtle — NOT a fire
explosion), center left empty and ready. A few skewers and a small pot beside it.

MID-GROUND (먹자골목 signature): the pojangmacha TENT canopy edge (a single warm
color tarp + warm string lights, NO Italian stripes), a HANGUL-style sign block shown as
an icon/placeholder block (NO legible text — real text is a Godot overlay), warm hanging
string lights.

BACKGROUND (alley depth + lantern bokeh): muted warm-gray silhouettes of alley shops
receding into a warm evening, with a few soft warm round LANTERN BOKEH light dots (soft
warm glow circles, Sesame Gold #F2B33D, low opacity) suggesting the lively night alley
behind. Pushed back by value.

Warm cozy NIGHT lighting — warm lantern/string-light glow against a soft deep-warm evening,
inviting and snug (NOT dark, NOT gloomy, NOT neon). reads "warm Korean night food alley."

%s

Important also: this is a NIGHT scene but kept WARM and inviting (warm lantern glow on a
soft deep-warm background — NOT a cold dark night, NOT neon cyberpunk). The charcoal
brazier glow is a subtle warm Persimmon glow, NOT a big fire VFX. The tent canopy + sign
are single warm colors / placeholder blocks, NO legible text, NO Italian stripes. NO
people. Korean identity from pojangmacha tent + 연탄 brazier + warm alley forms.""",
    },
    {
        "id": "L5",
        "name": "prestige_restaurant",
        "body": """A warm cozy mobile game COOKING ENVIRONMENT backdrop: a Korean PRESTIGE
HANJEONGSIK fine-dining restaurant kitchen/pass (고급 한정식), slight three-quarter view,
empty and ready for cooking. This is Level 5 — the top-tier prestige environment: refined,
warm, premium (dark walnut + brass + hanji), the visual payoff of full progression.

FOREGROUND (plating pass band, lower third): a refined DARK WALNUT #A6753F (deepened)
plating counter / pass with a polished surface and a subtle BRASS #B98A3E trim edge (one
restrained gold-brass accent — premium signal), center left empty and ready for a beautiful
plated dish. A 소반 (small Korean low tray) and a fine brass bowl sit to one side.

MID-GROUND (한정식 signature): a wall of HANJI (Korean paper) lattice with soft warm
backlight (warm Steamed #FFFCF6 glow through hanji), a refined display shelf of 놋그릇 BRASS
BOWLS (Brass #B98A3E, the prestige signature — a neat row of brass tableware), and an
elegant 소반 tray display.

BACKGROUND (full depth): muted warm-gray + dark-walnut silhouettes of the refined dining
room receding, with soft warm hanji-lamp glow points pushed back by value. The deepest,
most layered environment.

Warm refined premium lighting — soft warm hanji glow, restrained and elegant (the one
place where a subtle brass sheen / gentle highlight is allowed, Style Bible §7 premium
frame restraint). reads "premium Korean 한정식 fine dining."

%s

Important also: this is the PRESTIGE payoff level — refined and premium, but still WARM and
cozy (NOT cold corporate, NOT Royal Match glossy gold overload). Brass is the restrained
prestige accent (a neat brass-bowl row + one brass trim edge), NOT a gold explosion. Dark
walnut + brass + hanji warm glow. NO people. Korean identity from 놋그릇 brass bowls + 한지
hanji lattice + 소반 tray forms.""",
    },
]


def build_prompt(body: str) -> str:
    """body의 첫 %s를 STYLE_SUFFIX_ENV로 교체 (다른 % 보존)."""
    return body.replace("%s", STYLE_SUFFIX_ENV, 1)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Priority 2 Environment Pack — L1~L5 cooking environments = 5 PNG "
        "(Style Bible v1 warm wood + Travel Town depth, parallax-ready)"
    )
    parser.add_argument(
        "--only", type=str, default="",
        help="콤마구분 level ID만 (예: L1,L5). 빈 값 = 5장 전체.",
    )
    parser.add_argument("--model", default="gpt-image-1", choices=["dall-e-3", "gpt-image-1"])
    parser.add_argument(
        "--size", default="1536x1024",
        help="wide landscape 권장. gpt-image-1: 1536x1024 / 1024x1024 / 1024x1536.",
    )
    parser.add_argument(
        "--quality", default="medium",
        help="gpt-image-1: low/medium/high/auto.",
    )
    parser.add_argument(
        "--out-dir", type=Path,
        default=PROJECT_ROOT / "assets-raw" / "environment_pack_m2",
        help="출력 디렉터리",
    )
    parser.add_argument(
        "--version", type=str, default="v1",
        help="파일명 suffix (기본 v1 → L1_home_kitchen_v1.png)",
    )
    args = parser.parse_args()

    only_set = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    selected = [e for e in ENVIRONMENTS if (only_set is None or e["id"] in only_set)]
    if not selected:
        sys.exit(f"--only mismatch. Valid IDs: {[e['id'] for e in ENVIRONMENTS]}")

    args.out_dir.mkdir(parents=True, exist_ok=True)

    if args.model == "dall-e-3":
        unit = 0.080 if args.quality == "hd" else 0.040
    else:
        unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
        unit = unit_map.get(args.quality, 0.042)
    est_total = unit * len(selected)

    print("=" * 70)
    print("Priority 2 Environment Pack L1~L5 (gpt-image-1, Style Bible v1 warm)")
    print(f"   model: {args.model} / quality: {args.quality} / size: {args.size}")
    print(f"   targets: {len(selected)} ({[e['id'] for e in selected]})")
    print(f"   est cost: ${unit:.3f} x {len(selected)} = ${est_total:.2f}")
    print(f"   output: {args.out_dir}")
    print("=" * 70)

    api_key = load_api_key()
    client = OpenAI(api_key=api_key)

    successes: list[str] = []
    failures: list[tuple[str, str]] = []
    t0 = time.time()

    for i, env in enumerate(selected, 1):
        eid = env["id"]
        name = env["name"]
        out_path = args.out_dir / f"{eid}_{name}_{args.version}.png"
        prompt = build_prompt(env["body"])

        print(f"\n[{i}/{len(selected)}] {eid} {name} -> {out_path.name}")
        t_start = time.time()
        try:
            generate_image(
                client=client,
                prompt=prompt,
                output_path=out_path,
                model=args.model,
                size=args.size,
                quality=args.quality,
            )
            print(f"   elapsed {time.time() - t_start:.1f}s")
            successes.append(eid)
        except Exception as exc:
            print(f"   FAIL ({time.time() - t_start:.1f}s): {exc!r}")
            failures.append((eid, repr(exc)))

    total_elapsed = time.time() - t0
    print("\n" + "=" * 70)
    print(f"DONE: {len(successes)}/{len(selected)} imgs -- total {total_elapsed / 60:.1f} min")
    if successes:
        print(f"   success: {', '.join(successes)}")
    if failures:
        print(f"   fail {len(failures)}:")
        for eid, err in failures:
            print(f"     - {eid}: {err}")
    print(f"   est cost: ${unit * len(successes):.2f}")
    print(f"   output path: {args.out_dir}")
    print("=" * 70)


if __name__ == "__main__":
    main()
