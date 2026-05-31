"""
K-Food Master — M1 후반 sprint 조리도구 12종 anchor 자동 생성.

ADR-005 (4-stage rhythm tap) Stage 2B/2C 조리 mechanic prerequisite — 각 도구는
별도 sprite로 생성되며, 이후 godot-dev가 AnimationPlayer로 움직임 (도구 위치 이동,
flip, scoop, mix 등)을 구현. Cookingo: Perfect Meal (Asian mobile, 2025-2026) reference
— 도구별 specific action + 정확도 매칭 게임 메커니즘과 정합.

art-director docs/prompts-library.md v1.20 §5.11 STYLE_SUFFIX_TOOL + 조리도구 12종
prompt를 그대로 inline 임베드.

조리도구 12종 list (각각 별도 sprite, 다른 도구 없이 단독):
  TOOL-01 가스레인지 (Stovetop / Gas burner)   — base for cooking, flame on
  TOOL-02 냄비 (Pot)                            — 끓이기 (boil)
  TOOL-03 후라이팬 (Frying pan)                  — 볶기/부치기 (stir-fry / pan-fry)
  TOOL-04 깊은 튀김냄비 (Deep fryer pot)         — 튀기기 (deep-fry)
  TOOL-05 그릴/석쇠 (Grill / wire grate)         — 굽기 (grill)
  TOOL-06 국자 (Ladle)                           — 떠내기 (scoop broth)
  TOOL-07 주걱 (Wok spatula / 주방주걱)          — 볶기 (stir-fry stirring)
  TOOL-08 뒤집개 (Turner / spatula flip)         — 부치기 (flip pancake)
  TOOL-09 집게 (Tongs)                           — 굽기/튀기기 (grip)
  TOOL-10 김발 (Bamboo rolling mat)              — 말기 (roll kimbap)
  TOOL-11 mixing 큰 그릇 (Mixing bowl)           — 비비기 (mix bibimbap)
  TOOL-12 한식 가위 (Korean BBQ scissors)        — 자르기 (cut grilled meat)

각 도구 prompt:
  - 단독 sprite (다른 도구 없이, single hero element on Cool Sage bg)
  - 도구 형태 정확 + 한식 정통
  - 일본/중국/서구 도구 누수 회피 (Japanese tetsunabe / Chinese wok / Western teflon flat)
  - 사용 hint visual (flame on for stove / steam for pot / motion line for spatula)
  - 7/8 perspective view (top-down 일부 도구 — 김발/그릴 등 평면)
  - Cool Sage `#C8D5C0` bg + modern saturated + slim outline 2-3px + chibi-friendly

Usage:
    py tools/gen_tool_anchors_m1.py
    py tools/gen_tool_anchors_m1.py --only TOOL-01                  # 1장만
    py tools/gen_tool_anchors_m1.py --only TOOL-01,TOOL-02          # 일부
    py tools/gen_tool_anchors_m1.py --model gpt-image-1 --quality medium
    py tools/gen_tool_anchors_m1.py --version v2                    # 파일명 suffix

Default:
    model    = gpt-image-1 (medium quality)
    quality  = medium ($0.042/img × 12 = ~$0.50 total)
    size     = 1024x1024 (square 1:1)
    out_dir  = assets-raw/tool_anchors_m1/
"""

import argparse
import sys
import time
from pathlib import Path

# project root sys.path 추가 — gen_image import
PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT / "tools"))

from gen_image import generate_image, load_api_key  # noqa: E402

# Windows cp949 회피
if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")

from openai import OpenAI  # noqa: E402


# ─────────────────────────────────────────────────────────────────────────────
# STYLE_SUFFIX_TOOL — 모든 tool anchor prompt 끝에 부착
# prompts-library.md v1.20 §5.11 STYLE_SUFFIX_TOOL.
# 단독 sprite + Cool Sage bg + modern saturated + slim outline + Cookingo-inspired
# flat clean + 한식 정통 도구 + 일본/중국/서구 cross-cultural negative.
# ─────────────────────────────────────────────────────────────────────────────
STYLE_SUFFIX_TOOL = """Format: square 1:1.
View: 7/8 perspective view (slight side angle, mostly front but tilted ~15-20 degrees to show
form + depth + functional surface). Some flat tools (bamboo rolling mat, grill grate) may use
near top-down view for clearer functional silhouette readability.
Style: modern mobile casual game asset, clean 2D illustration in Royal Match (Dream Games 2021)
+ Cookingo: Perfect Meal (Asian mobile 2025-2026) aesthetic. Hero shot of a SINGLE Korean kitchen
cooking tool as a standalone sprite (this is an isolated tool icon for cooking gameplay
animation — the tool will later be animated independently by AnimationPlayer for actions like
scoop/flip/mix/cut/grill motion).
Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), single color fill with
optional soft 1-layer cel shading and ONE small specular highlight per element (clean modern
appliance/utensil sheen). Vibrant saturated colors at 80-90 percent saturation, warm metallic
+ cool background balance. Simple geometric flat fill shapes (Cookingo-inspired — simple shapes,
soft rounded edges, no excessive realism).

TOOL ISOLATION (consistent across all 12 tool anchors):
- The single hero tool sits at the CENTER of the frame, occupying ~60-70% of the image area
  with comfortable margins around it. NO other tools visible (each tool is its own separate
  sprite for later animation — no clutter, no kitchen scene environment, no other utensils).
- NO food, NO ingredients, NO characters, NO hands holding the tool — just the standalone
  tool element on the clean background.
- Optional minimal use-hint accent (1-2 elements only — see body prompt for tool-specific hint
  like flame on for stove / steam swirl for pot / motion line for spatula). These hints are
  SUBTLE accents and MUST NOT obscure the tool shape itself.

BACKGROUND:
- Solid Cool Sage #C8D5C0 background (consistent across all 12 tool anchors, matches food +
  environment + cut + ingredient + ingredient_cut + reaction anchor clusters for cross-asset
  one-game-world identity — cumulative 43+ anchor cluster).
- Single subtle ambient ellipse shadow directly under the tool (#000 ~25% alpha, soft and
  natural).

KOREAN HOMESTYLE TONE (consistent across all 12 tool anchors):
- These are Korean HOMESTYLE kitchen cooking tools (가정용), NOT industrial restaurant gear,
  NOT professional chef equipment, NOT traditional museum stone tools. Modern Korean home
  kitchen aesthetic — silver-gray stainless / 양은 aluminum-tin / cast iron black accents
  natural for Korean home cooking.
- Avoid Japanese, Chinese, Western cooking tool silhouettes (see per-tool body for specific
  cross-cultural negatives — Japanese tetsunabe / Chinese wok deep round-bottom / Western
  Teflon non-stick flat pan are common ChatGPT default leaks for Korean cooking tools).

Important: avoid beige background, cream paper background, scrapbook, storybook, kraft paper,
vintage texture, golden hour, sunset warm lighting,
Cookie Run, Cookie Run Kingdom frosting style, Toca Boca, Toon Blast over-cartoony,
realistic or photorealistic rendering, 3D render, octane or unreal engine, food photography,
heavy metallic reflection, mirror polish, any texture, noise, grain,
painterly or hand-painted feel, watercolor, gradient mesh, multi-layer complex shading,
hyperdetailed elements, cinematic, gritty, blood, gore,
multiple tools in one image (each tool is a separate sprite — NO companion tools, NO kitchen
scene with multiple utensils on a counter, NO tool sets stacked together),
food on or in the tool (the tool is empty/clean ready-to-use state — NO ingredients, NO cooked
food, NO sauce, NO oil pooling),
human characters, hands holding the tool, cooking action mid-motion with someone using it,
kitchen environment background (BG-01~05 environment anchors are separate),
Japanese kitchen tools (tetsunabe deep iron pot with hammered texture, donabe clay pot with
lid, takoyaki maker, yakitori grill, sushi-related tools),
Chinese wok (large round-bottom deep wok, distinctly Chinese cleaver, bamboo steamer baskets
stacked),
Western cooking tools (Teflon non-stick pan with prominent black-coated flat surface, Le
Creuset enameled cast iron Dutch oven, Western chef knife, KitchenAid stand mixer, electric
kettle, slow cooker, instant pot),
traditional Korean stone tools (절구 mortar and pestle stone bowl, 옹기 large ceramic jar
storage — those belong to ingredient prep tradition, not the modern cooking gameplay mechanic
mapping),
any English or Korean text legibly readable on the tool surface (brand labels, model numbers,
maker engravings, all text obscured or absent)."""


# ─────────────────────────────────────────────────────────────────────────────
# TOOLS — 12개 항목 (조리도구 12종, 각각 별도 sprite)
# prompts-library.md v1.20 §5.11.1 ~ §5.11.12 본문 inline.
# 각 항목: id (TOOL-XX) / name (slug) / action (액션) / mapping (음식 매핑) / body.
# STYLE_SUFFIX_TOOL은 자동 append via .replace("%s", STYLE_SUFFIX_TOOL, 1).
# ─────────────────────────────────────────────────────────────────────────────
TOOLS = [
    {
        "id": "TOOL-01",
        "name": "stovetop_gas_burner",
        "action": "base for cooking (flame on)",
        "mapping": "all hot dishes (base substrate)",
        # §5.11.1 가스레인지 — 한식 가정 4구 가스레인지 + flame on (blue ring)
        "body": """A modern mobile casual game asset illustration of a Korean home kitchen GAS
STOVETOP (가스레인지) as a standalone tool sprite, 7/8 perspective view (slight angled view
to show the top surface + side profile), the base substrate for all hot cooking actions in
the game (used as the foundation tool where pots, pans, deep fryers, grills, kettles are
placed on top — but for this anchor, the stovetop is shown alone without any cookware on top).

Tool form: a SILVER-GRAY 4-BURNER KOREAN HOME GAS STOVETOP — a rectangular flat top surface
(approximately 50cm × 35cm proportion, simple geometric flat with slightly rounded corners,
silver-gray stainless steel #B8BCC0 single fill with subtle slim cel shading and ONE specular
highlight strip across the top suggesting the polished surface). On the top surface: 4 round
BLACK GAS BURNER GRATES (cast iron grates in a 2×2 grid layout, each ~10cm diameter, black
#2A2A2A single fill with slim cel shading, the classic cross-pattern cast iron grate shape).
At the front of the stovetop: 4 small BLACK KNOBS (round dial knobs in a row, each ~2cm
diameter, glossy black with a small silver-gray indicator line on top).

USE-HINT ACCENT: The FRONT-LEFT burner is ACTIVE with a SMALL BLUE FLAME RING (the gas burner
flame visible as a clean blue circular flame pattern, ~6-8 small blue flame tips around the
burner center, vibrant clean blue #4D9DE0 single fill with optional very slight light cyan
inner accent, simple flat flame shape — NOT a wild fire blaze, NOT a realistic flame). The
other 3 burners are OFF (no flame). This active flame is the signal that the stove is hot
and ready for cooking.

%s

Important also: this is a Korean HOME 4-burner gas stovetop with flame on the front-left
burner — the stovetop MUST be a clean silver-gray rectangular slab with 4 black round burner
grates + 4 front knobs + 1 active blue flame ring. NOT a Japanese induction cooktop (induction
is flat glass-ceramic surface with no grates and no flame — Korean home kitchens primarily
use GAS stovetops with visible grates and blue flame). NOT a Western electric coil range
(electric coils are spiral red-hot heating elements, not blue gas flame — Korean home
stovetops are GAS with blue flame). NOT a Chinese restaurant wok burner (single high-power
burner with massive flame for wok hei stir-fry, this is a quiet home 4-burner). NOT a built-in
oven range (this is just the cooktop, not an oven combo). NOT an outdoor camping stove or
portable butane burner (this is a fixed home kitchen stovetop). The single standalone
silver-gray 4-burner Korean home gas stovetop with one active front-left blue flame on the
Cool Sage background is the hero — no pot, no pan, no other cookware on the burners (those
are separate tool anchors)."""
    },
    {
        "id": "TOOL-02",
        "name": "pot_yangun",
        "action": "boil (끓이기)",
        "mapping": "F-01 라면 / F-02 잔치국수 / F-10 순두부",
        # §5.11.2 냄비 — 한식 양은냄비 (silver-gray rounded pot, 2 ear handles)
        "body": """A modern mobile casual game asset illustration of a Korean home kitchen POT
(냄비) as a standalone tool sprite, 7/8 perspective view (slight angled view to show the
rounded body + 2 ear handles + open top opening), the boiling vessel for Korean noodle soups,
stews, and broths (used in F-01 ramyeon, F-02 janchi-guksu, F-10 sundubu jjigae). The pot
is shown CLEAN AND EMPTY ready-to-use state with no ingredients inside.

Tool form: a SILVER-GRAY KOREAN YANGUN (양은) ALUMINUM-TIN POT — a rounded cylindrical pot
shape with two small protruding EAR HANDLES on opposite sides (each handle ~5cm wide, simple
loop or solid tab shape, silver-gray matching the pot). Pot dimensions: approximately 22-25cm
diameter × 12-15cm tall (a medium-sized home cooking pot proportion, fitting a Korean
2-person family meal scale). Color: SILVER-GRAY metallic stainless or 양은 aluminum-tin
#B8BCC0 single fill with subtle slim cel shading on the lower curved side (suggesting
cylindrical 3D volume in 7/8 view) + ONE small specular highlight strip along the upper rim
suggesting the polished metallic surface. The top has an OPEN ROUND OPENING (the pot rim
visible as an elliptical opening shape due to 7/8 perspective, showing the inside as a
slightly darker tone #A0A4A8 to suggest the inner cavity). The pot rests on its flat round
bottom (slightly visible curve at the base).

USE-HINT ACCENT: 1-2 small WHITE STEAM SWIRL LINES rising gently from the open top opening
(simple flat curving line shapes, off-white #FAFAFA, suggesting the pot is hot and ready for
boiling, NOT a heavy steam cloud). Optional: NO lid (the lid is omitted to show the open top
ready-to-add-ingredients state).

%s

Important also: this is a Korean home YANGUN aluminum-tin pot with 2 ear handles + open top
+ subtle steam — the pot MUST be a CLEAN ROUNDED CYLINDRICAL silver-gray pot, NOT empty
deep cavity. NOT a Japanese tetsunabe (tetsunabe is a deep BLACK CAST IRON pot with hammered
texture and often a wooden lid, Korean yangun is silver-gray smooth metallic). NOT a Japanese
donabe clay pot (donabe is matte tan/brown ceramic with a tight-fit lid, Korean yangun is
shiny metallic). NOT a Chinese wok (wok is a wide round-bottom shallow cooking vessel with
a single long handle, Korean pot has 2 ear handles + deeper cylindrical shape). NOT a Western
Dutch oven (Dutch oven is enameled cast iron with heavy lid + colored exterior like Le
Creuset orange/blue, this is bare metallic silver-gray). NOT a Western saucepan with a long
single side handle (Korean pot has 2 ear handles on opposite sides, NOT one long pan handle).
NOT a deep fryer pot (deep fryer is taller + wider opening for oil immersion, this is medium
boil pot — TOOL-04 deep fryer is a separate anchor). NOT a kettle (kettles have a spout +
top handle, this is open-top pot with side ear handles). The single standalone silver-gray
cylindrical Korean yangun pot with 2 ear handles + open top + 1-2 steam swirls on the Cool
Sage background is the hero — no food inside, no lid, no stovetop underneath (those are
separate)."""
    },
    {
        "id": "TOOL-03",
        "name": "frying_pan",
        "action": "stir-fry / pan-fry (볶기 / 부치기)",
        "mapping": "F-05 김치볶음밥 / F-07 해물파전 / F-09 불고기",
        # §5.11.3 후라이팬 — 일반 한식 가정 후라이팬 (silver-gray, single long handle, shallow)
        "body": """A modern mobile casual game asset illustration of a Korean home kitchen FRYING
PAN (후라이팬) as a standalone tool sprite, 7/8 perspective view (slight angled view to show
the shallow flat cooking surface + single long side handle + slight side wall depth), the
stir-fry and pan-fry vessel for Korean fried rice, savory pancakes, and meat (used in F-05
김치볶음밥, F-07 해물파전, F-09 bulgogi). The pan is shown CLEAN AND EMPTY ready-to-use state.

Tool form: a SILVER-GRAY KOREAN HOME FRYING PAN — a wide round shallow cooking surface with
a single long straight side handle extending outward. Pan dimensions: approximately 26-28cm
diameter cooking surface × 4-5cm shallow side wall depth (a standard medium-sized home frying
pan proportion). Color: SILVER-GRAY metallic stainless #B8BCC0 single fill with subtle slim
cel shading on the inner cooking surface (a slightly darker inner ring near the side walls
suggesting depth in 7/8 view) + ONE small specular highlight crescent on the inner pan
surface suggesting the polished cooking surface. The HANDLE is a single straight rectangular
piece extending from one side of the pan (~12-14cm long × 2-3cm wide, with a slightly rounded
end), made of a darker matte heat-resistant material — solid dark brown #4A3826 single fill
or matte black #2A2A2A single fill (Korean home pans typically use a heat-resistant handle
that contrasts with the silver-gray pan body). The handle attaches to the pan with a small
visible riveted connection point. The pan rests on its flat round bottom (slightly visible
curve where pan meets the surface).

USE-HINT ACCENT: NO active oil, NO active flame, NO motion lines (the pan is shown in clean
ready state). Optional: a very subtle hint of slight curved warm light on the inner pan
surface (single soft slim cel shading stroke suggesting "ready to receive ingredients").

%s

Important also: this is a Korean home stainless frying pan with single long side handle —
the pan MUST be a CLEAN SHALLOW ROUND silver-gray cooking surface with one straight handle.
NOT a Western Teflon non-stick pan (Teflon pans have a dominant BLACK NON-STICK COATED FLAT
INTERIOR with often colorful exterior — Korean home pans are typically bare silver-gray
stainless). NOT a Chinese wok (wok is a wide ROUND-BOTTOM DEEP vessel with curved sloped
sides, NOT a shallow flat-bottom pan; wok often has a long wooden handle + opposite small
helper handle). NOT a Japanese tamagoyaki rectangular pan (tamagoyaki is a small RECTANGULAR
copper or non-stick pan for rolling Japanese omelet — Korean pan is ROUND). NOT a cast iron
skillet (cast iron is HEAVY BLACK with rougher textured cooking surface and often shorter
thicker handle — Korean home pan is light smooth silver-gray). NOT a paella pan (paella is
very wide + very shallow + 2 small ear handles — Korean pan has 1 long side handle). NOT a
crepe pan (crepe pan is extremely flat with no side walls). The single standalone silver-gray
Korean home round frying pan with one straight side handle on the Cool Sage background is
the hero — no food inside, no oil pool, no flame underneath (those are separate)."""
    },
    {
        "id": "TOOL-04",
        "name": "deep_fryer_pot",
        "action": "deep-fry (튀기기)",
        "mapping": "F-06 콘도그",
        # §5.11.4 깊은 튀김냄비 — 한식 가정 깊은 frying pot (silver-gray, deeper than TOOL-02)
        "body": """A modern mobile casual game asset illustration of a Korean home kitchen DEEP
FRYER POT (깊은 튀김냄비) as a standalone tool sprite, 7/8 perspective view (slight angled
view to show the tall deep body + 2 ear handles + open top + visible oil pool inside), the
deep-frying vessel for Korean corn dogs, fried chicken, and tempura-style fries (used in F-06
콘도그). The pot is shown with PALE GOLDEN COOKING OIL filled to about 60-70% depth, ready
for deep-frying.

Tool form: a SILVER-GRAY KOREAN HOME DEEP FRYER POT — a tall rounded cylindrical pot shape
with two small protruding EAR HANDLES on opposite sides (each handle ~5cm wide, simple loop
or solid tab shape, silver-gray matching the pot — visually similar to TOOL-02 yangun pot
handle but the pot body is significantly deeper). Pot dimensions: approximately 24-26cm
diameter × 18-22cm tall (NOTICEABLY DEEPER than TOOL-02 boil pot which is 12-15cm tall —
this depth is critical for deep-frying as it allows ingredients to fully submerge in hot oil
without splashing over). Color: SILVER-GRAY metallic stainless or heavy-duty #B8BCC0 single
fill with subtle slim cel shading on the lower curved side (suggesting cylindrical 3D volume
in 7/8 view) + ONE small specular highlight strip along the upper rim suggesting the polished
metallic surface. The top has an OPEN ROUND OPENING (the pot rim visible as an elliptical
opening shape due to 7/8 perspective).

USE-HINT ACCENT: INSIDE the pot, a POOL OF PALE GOLDEN COOKING OIL fills about 60-70% of the
pot's interior depth (the oil surface visible as an elliptical ellipse due to 7/8 perspective,
pale golden #F5D88E single fill with subtle slim cel shading suggesting the slightly viscous
oil + ONE small specular highlight on the oil surface suggesting the smooth liquid sheen).
Optional: 1-2 very subtle small heat wave wavy lines rising from the oil surface (warm
amber-light #F5C266 thin wavy line, suggesting the oil is hot and ready for frying — much
subtler than steam, just minimal heat shimmer accent).

%s

Important also: this is a Korean home DEEP-FRY pot — DEEPER and TALLER than the TOOL-02
yangun boil pot, with golden oil pool inside ready for frying. The pot MUST be a tall
silver-gray cylindrical vessel with visible golden oil pool. NOT a TOOL-02 boil pot (boil
pot is shorter ~12-15cm tall and shown empty without oil — deep fryer is 18-22cm tall and
shown with oil pool, MORE DEPTH visible). NOT a Japanese tetsunabe deep iron pot (tetsunabe
is hammered black cast iron, this is smooth silver-gray stainless). NOT a Chinese wok used
for deep-frying (wok has round-bottom curved sides; Korean deep fry pot is straight-walled
cylindrical). NOT a Western Dutch oven (Dutch oven is enameled colored cast iron with heavy
lid). NOT a tabletop electric deep fryer with control panel + electric cord (this is a stovetop
pot, NOT an electric appliance — no buttons, no display, no cord). NOT a kettle (kettles
have a spout + top handle). NOT a stock pot (stock pot is wider opening + sometimes shorter
proportion — deep fryer is specifically tall cylinder optimized for oil depth). The single
standalone silver-gray deep cylindrical Korean home deep fryer pot with 2 ear handles + open
top + golden oil pool inside on the Cool Sage background is the hero — no food being fried
yet, no flame underneath."""
    },
    {
        "id": "TOOL-05",
        "name": "grill_wire_grate",
        "action": "grill (굽기)",
        "mapping": "F-12 갈비구이",
        # §5.11.5 그릴/석쇠 — round metallic wire mesh grill grate (한식 BBQ tabletop)
        "body": """A modern mobile casual game asset illustration of a Korean home BBQ GRILL
WIRE GRATE (석쇠) as a standalone tool sprite, near top-down view tilted slightly (~15
degrees) to show the flat circular wire mesh surface + minimal side profile depth, the
grilling surface for Korean BBQ meat (used in F-12 갈비구이 — visual consistency with the
F-12 galbi-gui anchor's wire mesh grate). The grate is shown CLEAN AND EMPTY ready-to-use
state with no meat on it.

Tool form: a ROUND METALLIC WIRE MESH GRILL GRATE — a circular flat grilling surface made
of thin silver-gray metal wires arranged in a grid pattern (cross-hatched wires forming a
mesh of ~8×8 to 10×10 wire crossings visible across the round grate face). Grate dimensions:
approximately 28-30cm diameter × ~1cm thin profile (a flat round disc with very minimal
depth). Color: SILVER-GRAY metallic wire #B8BCC0 single fill with slim cel shading on each
wire suggesting the cylindrical wire 3D form + ONE small specular highlight strip across a
few wires suggesting the polished metal sheen. The outer rim is a slightly thicker continuous
RING (~0.5cm wider than the wires, the structural rim that holds the wire mesh together,
same silver-gray color but slightly more solid). The grate sits flat on its round face in
the image.

USE-HINT ACCENT: Optional subtle hint of RED-ORANGE HOT COAL GLOW underneath the grate
(visible through the wire mesh gaps as a soft warm red-orange wash #FF6B3D ~30% alpha, the
warm fire atmosphere of Korean BBQ — subtle ambient glow only, NOT visible flames, NOT a
charcoal bed detail). This hint suggests the grill is HOT and ready for grilling meat. The
glow is centered under the grate and fades softly toward the edges.

%s

Important also: this is a Korean BBQ tabletop round wire mesh grill grate (석쇠) — the grate
MUST be a CIRCULAR FLAT WIRE MESH (silver-gray crossed wires forming a grid pattern) with a
thicker outer rim ring. Consistent with the wire mesh grate visible in the F-12 galbi-gui
food anchor (cross-asset consistency). NOT a flat solid plate (solid plates have no visible
wire pattern — this is a wire MESH where you can see through the wires). NOT a Japanese
yakitori grill (yakitori grills are RECTANGULAR narrow charcoal boxes for skewered chicken,
this is a ROUND wire mesh). NOT a Western American BBQ grill grate (American BBQ grates are
typically RECTANGULAR with parallel-only wire bars + larger gas/charcoal grill housing,
Korean is small round tabletop). NOT a cast iron grill pan (cast iron grill pans are solid
plates with raised parallel ridges — this is open wire mesh). NOT a hibachi (hibachi is a
Japanese small grill type, different cultural context). NOT a fish basket grill or a folding
grill basket (those have a hinged top mesh that closes over food). NOT a microwave turntable
(microwave plates are solid round disks, not wire mesh). NOT an oven rack (oven racks are
typically rectangular with parallel widely-spaced bars). The single standalone silver-gray
round wire mesh Korean BBQ grill grate with optional soft red-orange coal glow underneath
on the Cool Sage background is the hero — no meat on the grate, no skewers, no flames
visible above (those are separate)."""
    },
    {
        "id": "TOOL-06",
        "name": "ladle",
        "action": "scoop broth (떠내기)",
        "mapping": "F-01 라면 / F-02 잔치국수 / F-10 순두부 (all broth-based)",
        # §5.11.6 국자 — 한식 가정 국자 (silver-gray deep round bowl + long straight handle)
        "body": """A modern mobile casual game asset illustration of a Korean home kitchen LADLE
(국자) as a standalone tool sprite, 7/8 perspective view (slight angled view to show the
deep round bowl + long straight handle + the bowl's inner cavity), the broth-scooping utensil
for Korean noodle soups and stews (used in F-01 ramyeon, F-02 janchi-guksu, F-10 sundubu).
The ladle is shown CLEAN AND EMPTY ready-to-use state with no broth inside the bowl.

Tool form: a SILVER-GRAY KOREAN HOME LADLE — a deep round half-sphere bowl at one end +
a long straight slim handle extending from the bowl edge. Ladle dimensions: bowl ~8-10cm
diameter × ~5-6cm deep (the round half-sphere bowl), handle ~25-28cm long × ~1.5cm wide
straight slim rod with a slightly curved top end (like an upward-tilted finger grip). Color:
SILVER-GRAY metallic stainless #B8BCC0 single fill for both the bowl and the handle (one
continuous metal piece, the classic stainless ladle look) with subtle slim cel shading on
the bowl underside suggesting the rounded half-sphere 3D form + ONE small specular highlight
on the bowl rim suggesting the polished metallic surface. The handle has a small SLIM hole
or hanging loop at the very top end (~0.5cm round hole for hanging on a kitchen hook). The
handle extends UPWARD AND OUTWARD from the bowl at approximately a 30-degree angle from the
bowl (natural ladle ergonomic angle, NOT perfectly perpendicular, NOT flat horizontal). The
ladle is shown laying flat on a horizontal surface (bowl resting cup-down on the bowl edge,
handle extending upward at the angle).

USE-HINT ACCENT: NO broth inside the bowl, NO motion line (the ladle is shown in clean ready
state). Optional: very subtle hint of inner bowl cavity slightly darker (#A0A4A8 inside the
bowl interior suggesting the empty inner cavity vs the brighter outer surface).

%s

Important also: this is a Korean home stainless ladle — the ladle MUST be a SINGLE METAL
PIECE (silver-gray) with a DEEP ROUND HALF-SPHERE BOWL + LONG STRAIGHT SLIM HANDLE. NOT a
Western soup ladle with a wooden handle (wooden handles attach with rivets — Korean home
ladles are typically all-metal single piece for dishwasher convenience). NOT a Japanese
otama (otama is similar but often has a wooden handle and shallower bowl). NOT a Chinese
soup spoon (Chinese soup spoons are flat short-handled handheld scoops — ladle has a long
handle for reaching into pots). NOT a serving spoon (serving spoons have a SHALLOW OVAL bowl
— ladle has a DEEP ROUND HALF-SPHERE bowl optimized for liquid scooping). NOT a measuring
cup (measuring cups have markings and a pour spout). NOT a slotted ladle (slotted ladles
have holes for draining — this is a SOLID bowl for broth). NOT a strainer spoon. NOT a
hand-blender. The single standalone silver-gray Korean home ladle with deep round bowl +
long straight handle on the Cool Sage background is the hero — no broth, no liquid, no pot
to scoop from (those are separate)."""
    },
    {
        "id": "TOOL-07",
        "name": "wok_spatula",
        "action": "stir-fry stirring (볶기)",
        "mapping": "F-05 김치볶음밥 / F-09 불고기 / F-11 잡채",
        # §5.11.7 주걱 (wok spatula) — 한식 주방주걱 (silver-gray angled paddle + long wood handle)
        "body": """A modern mobile casual game asset illustration of a Korean home kitchen WOK
SPATULA / KITCHEN STIRRING PADDLE (주걱 / 주방주걱) as a standalone tool sprite, 7/8
perspective view (slight angled view to show the flat angled paddle face + long handle), the
stir-fry stirring utensil for Korean fried rice, beef stir-fry, and glass noodle stir-fry
(used in F-05 김치볶음밥, F-09 bulgogi, F-11 japchae). The spatula is shown CLEAN AND EMPTY
ready-to-use state.

Tool form: a KOREAN HOME WOK SPATULA — a wide flat ANGLED PADDLE at one end + a long straight
WOODEN HANDLE attached to the paddle. Spatula dimensions: paddle ~8-10cm wide × ~10-12cm long
× ~0.3cm thin (a wide flat angled paddle, like a slightly curved shovel head with a slight
front-edge curve for scraping pan surfaces), handle ~25-30cm long × ~2-2.5cm thick straight
cylindrical wooden rod with a slightly rounded grip end. Paddle color: SILVER-GRAY metallic
stainless steel #B8BCC0 single fill with subtle slim cel shading along the paddle length +
ONE small specular highlight strip suggesting the polished metal sheen. Handle color: WARM
BROWN WOOD #A67049 single fill (matching the cutting board warm wood tone used across cut
anchors, cross-asset wood consistency) with 1-2 subtle slim grain accent lines (NOT heavy
wood grain texture). The paddle connects to the wooden handle at an attachment point with
a small visible metal collar or riveted joint (~1cm). The paddle is at a slight ANGLE (~20
degrees) relative to the handle axis (not perpendicular flat — the angled paddle is the
signature of a stir-fry spatula for scraping pan surfaces effectively).

USE-HINT ACCENT: NO food on the paddle, NO motion line (the spatula is shown in clean ready
state). Optional: very subtle hint of a tiny food stain or seasoning rest mark on the paddle
edge (1 small slim accent only, suggesting it's a working kitchen tool — but mostly clean).

%s

Important also: this is a Korean home WOK SPATULA / STIRRING PADDLE — the spatula MUST be
a wide flat ANGLED SILVER-GRAY METAL PADDLE + LONG WARM BROWN WOOD HANDLE. NOT a TURNER /
PANCAKE FLIPPER (TOOL-08 turner is a separate anchor — turner has a NARROWER paddle with
SHARPER FRONT EDGE for flipping; stir-fry spatula is WIDER + slightly angled for stirring,
NOT for flipping). NOT a Japanese rice paddle (shamoji is a wooden flat paddle for serving
rice, no metal blade — this is metal paddle for stir-frying). NOT a Chinese wok spatula
specifically (Chinese wok chuan has a LONGER curved deeper paddle for high-heat wok work —
Korean version is shallower and flatter for home cooking). NOT a slotted spatula (slotted
spatulas have holes for draining — this is a SOLID flat paddle). NOT a fish spatula (fish
spatulas have very narrow flexible thin blade). NOT a silicone scraper (silicone scrapers
are colored rubber flexible — this is metal). NOT a wooden spoon (wooden spoons are oval
rounded bowl shape — this is flat angular paddle). NOT a slotted ladle. NOT a kitchen tong
(tongs are 2-piece gripping tool — TOOL-09). The single standalone silver-gray metal paddle
+ warm brown wood handle Korean home wok spatula on the Cool Sage background is the hero —
no food being stirred, no pan, no motion."""
    },
    {
        "id": "TOOL-08",
        "name": "turner_flipper",
        "action": "flip pancake (부치기)",
        "mapping": "F-07 해물파전",
        # §5.11.8 뒤집개 — 한식 가정 뒤집개 (silver-gray narrow thin paddle, sharp front edge)
        "body": """A modern mobile casual game asset illustration of a Korean home kitchen TURNER
/ PANCAKE FLIPPER (뒤집개) as a standalone tool sprite, 7/8 perspective view (slight angled
view to show the narrow flat thin paddle face + long handle + the sharp front edge that
slides under pancakes), the pancake-flipping utensil for Korean savory pancakes (used in
F-07 해물파전). The turner is shown CLEAN AND EMPTY ready-to-use state.

Tool form: a KOREAN HOME TURNER / PANCAKE FLIPPER — a NARROWER LONGER FLAT THIN PADDLE at
one end + a long straight handle attached. Turner dimensions: paddle ~6-8cm wide × ~12-14cm
long × ~0.2cm VERY THIN (the thin profile is critical for sliding under pancakes), the FRONT
EDGE of the paddle is SHARP AND SLIGHTLY BEVELED (suggesting it slides easily under food).
Handle ~22-25cm long × ~2cm thick straight cylindrical rod with a slightly rounded grip end.
Paddle color: SILVER-GRAY metallic stainless steel #B8BCC0 single fill with subtle slim cel
shading along the paddle length + ONE small specular highlight strip suggesting the polished
metal sheen. The paddle MAY have a few subtle SLOTS or VENT HOLES (2-3 narrow parallel slots
near the paddle middle, ~1cm × 0.3cm each, allowing oil/grease to drain when flipping pancakes
— a common Korean home turner feature; if slots are added they are slim and parallel to the
paddle length). Handle color: MATTE BLACK heat-resistant material #2A2A2A single fill OR WARM
BROWN WOOD #A67049 (either is acceptable — choose matte black for visual contrast with the
silver-gray paddle). The paddle connects to the handle at an attachment point with a small
metal collar or riveted joint (~1cm). The paddle is at a slight ANGLE (~10-15 degrees) relative
to the handle axis (less angled than TOOL-07 stir-fry spatula, the turner is closer to
parallel for easier sliding under pancakes).

USE-HINT ACCENT: NO food on the paddle, NO active motion line. Optional: a small MOTION LINE
ACCENT (1-2 slim curved white-cyan motion line arcs near the paddle indicating an upward
flip motion suggestion — very subtle, just a visual hint that this is a FLIPPING tool, NOT
heavy action lines that obscure the paddle shape).

%s

Important also: this is a Korean home TURNER / PANCAKE FLIPPER — the turner MUST be a
NARROWER LONGER VERY THIN flat paddle with a SHARP FRONT EDGE (for sliding under pancakes),
contrasted with TOOL-07 wok spatula which is WIDER + slightly more angled. NOT a TOOL-07
stir-fry wok spatula (wok spatula is WIDER 8-10cm + more angled 20deg for stirring; turner
is NARROWER 6-8cm + thinner profile + slightly angled 10deg for flipping). NOT a fish
spatula (fish spatulas have a SLOTTED THIN FLEXIBLE blade often with curved slots — turner
may have parallel slots but is a more rigid paddle). NOT a pizza peel (pizza peels are very
wide flat paddles for sliding into ovens — turner is narrower for hand-flipping at the pan).
NOT a Japanese tamagoyaki flipper (those are very specific to Japanese omelet rolling).
NOT a silicone spatula (silicone is flexible rubber colored — this is rigid metal). NOT a
spider strainer (spider strainers are wire mesh basket shape — turner is solid flat paddle).
NOT a slotted ladle. NOT a serving spoon. The single standalone silver-gray narrow thin
metal paddle + handle Korean home turner / pancake flipper with subtle flip motion line
accent on the Cool Sage background is the hero — no pancake on the paddle, no pan, no
active flipping action."""
    },
    {
        "id": "TOOL-09",
        "name": "tongs",
        "action": "grip (굽기/튀기기)",
        "mapping": "F-06 콘도그 / F-12 갈비구이",
        # §5.11.9 집게 — 한식 가정 부엌집게 (silver-gray spring-loaded grip tongs)
        "body": """A modern mobile casual game asset illustration of a Korean home kitchen TONGS
(집게) as a standalone tool sprite, 7/8 perspective view (slight angled view to show the
two-piece scissor-like silhouette + the gripping ends + the spring-loaded hinge at the top),
the gripping utensil for Korean BBQ meat and deep-fried foods (used in F-12 갈비구이 for
gripping grilled meat on the BBQ + F-06 콘도그 for safely handling deep-fried corn dogs out
of hot oil). The tongs are shown CLEAN AND EMPTY ready-to-use state with the tips slightly
open (not closed-gripping).

Tool form: a KOREAN HOME KITCHEN SCISSOR-STYLE TONGS — a TWO-PIECE silver-gray metal tool
with a SPRING-LOADED HINGE at the top end + 2 LONG STRAIGHT ARMS extending downward + 2
SLIGHTLY-FLARED GRIPPING ENDS at the bottom. Tongs dimensions: total length ~25-28cm from
hinge to tips, the 2 arms are slim cylindrical rods ~1-1.5cm wide each, the gripping ends
are slightly flared and slightly indented (like 2 small claw-shaped flat ends that face each
other when closed). The tips are slightly OPEN (the 2 ends visible separated by a small gap
~2-3cm, suggesting the spring naturally holds them slightly apart when not gripping). Color:
SILVER-GRAY metallic stainless #B8BCC0 single fill with subtle slim cel shading along the
arm lengths + ONE small specular highlight strip on each arm suggesting the polished metal
sheen. The HINGE at the top is a small simple connection point (a small bump/joint where the
2 arms meet and pivot, suggesting the spring mechanism — but the spring itself is internal
and not visible). Optional: a soft RUBBER GRIP COATING on the upper portion of the arms
(near where hands would hold, ~6-8cm down from the hinge, simple matte black or warm color
single fill ring around each arm — adds visual interest and signals "kitchen tool" function).

USE-HINT ACCENT: NO food being gripped, NO motion line (the tongs are shown in clean ready
state with naturally slightly-open tips).

%s

Important also: this is a Korean home kitchen TONGS — the tongs MUST be a TWO-PIECE
SCISSOR-STYLE TOOL with spring-loaded hinge + 2 arms + 2 gripping ends. NOT a single tool
(this is distinctly a 2-arm tool, NOT a one-piece spoon or paddle). NOT chopsticks (chopsticks
are 2 separate UNCONNECTED slim sticks — tongs are CONNECTED at the top hinge). NOT salad
servers (salad servers are 2 separate spoons + paddle, not connected). NOT pliers (pliers
have specific gripping jaws with sharp gear teeth — kitchen tongs have smooth flared flat
ends). NOT a clothing pin or paper clip. NOT a tweezer (tweezers are short small precision
tools — kitchen tongs are LONG kitchen tool for handling hot food). NOT spaghetti tongs
specifically (spaghetti tongs have FORKED PRONGS at the tips — Korean kitchen tongs have
SMOOTH FLARED FLAT tips). NOT BBQ branding tongs with logos. NOT scissors (TOOL-12 Korean
BBQ scissors is a separate anchor — scissors have CUTTING BLADES with sharp edges; tongs
have FLAT GRIPPING ENDS for holding, not cutting). The single standalone silver-gray
two-piece Korean home kitchen tongs with slightly-open tips on the Cool Sage background is
the hero — no food being gripped, no grill, no fryer."""
    },
    {
        "id": "TOOL-10",
        "name": "bamboo_rolling_mat",
        "action": "roll kimbap (말기)",
        "mapping": "F-03 김밥",
        # §5.11.10 김발 — 한식 가정 김발 (bamboo rolling mat, top-down view, parallel bamboo strips)
        "body": """A modern mobile casual game asset illustration of a Korean home kitchen BAMBOO
ROLLING MAT (김발) as a standalone tool sprite, near top-down view (looking straight down at
the flat mat surface to show the parallel bamboo strips clearly), the rolling utensil for
Korean kimbap (used in F-03 김밥). The mat is shown CLEAN AND EMPTY ready-to-use state laid
flat on the background.

Tool form: a KOREAN BAMBOO ROLLING MAT (김발) — a flat rectangular mat made of MANY THIN
PARALLEL BAMBOO STRIPS bound together with cotton string. Mat dimensions: approximately
24-26cm wide × 22-24cm tall (a roughly square home-size rolling mat). The bamboo strips are
arranged with their long edges PARALLEL HORIZONTALLY (running side-to-side across the mat,
approximately 20-25 individual thin bamboo strips visible, each strip ~1-1.2cm wide × 24-26cm
long × 0.3cm thick). Color: LIGHT NATURAL BAMBOO TAN #E0CFA4 single fill for the bamboo
strips with very subtle slim cel shading lines along each strip suggesting the cylindrical
3D form of each strip + tiny darker accents at strip ends suggesting the cut bamboo ends.
The strips are bound by 2 visible WHITE COTTON STRING WEAVING LINES running PERPENDICULAR
(vertically along left and right edges of the mat, weaving over and under each bamboo strip
— like 2 small parallel string seams holding the mat structure together). Optional: 1-2
small subtle "fray" accents at the corners where the cotton string ties off (very minimal,
showing it's a natural woven kitchen tool).

USE-HINT ACCENT: The mat is laid flat (NOT rolled, NOT mid-rolling action), shown completely
flat ready for kimbap construction. Optional: very subtle hint of slight curl at the top
edge of the mat (1-2 strips slightly lifting suggesting the mat is flexible and ready to
roll, but mostly the mat is flat).

%s

Important also: this is a Korean BAMBOO ROLLING MAT for kimbap rolling — the mat MUST be a
FLAT RECTANGULAR ARRAY OF PARALLEL HORIZONTAL BAMBOO STRIPS bound by cotton string. NOT a
Japanese makisu (Japanese makisu is essentially the same tool but for sushi rolling — visually
identical functionally; the Korean version may be slightly larger and has the same parallel
bamboo strip structure; if absolutely necessary to differentiate, the cotton string color
should be PLAIN WHITE / CREAM (Korean) rather than colored Japanese decorative thread). NOT
a placemat (placemats are decorative fabric or vinyl mats — this is functional bamboo
rolling). NOT a Chinese bamboo steamer basket (steamer baskets are 3D round basket shapes
with lids — this is a FLAT 2D mat). NOT a yoga mat or exercise mat (those are rolled rubber
foam — this is bamboo). NOT a bamboo placemat with decorative weave patterns (the rolling
mat has FUNCTIONAL parallel strips, NOT decorative cross-weave). NOT chopsticks lined up
(chopsticks are separate sticks at random spacing — bamboo mat strips are TIGHTLY BOUND
together with no gaps between strips). NOT a wooden cutting board (wooden cutting boards are
SOLID single slab — mat is FLEXIBLE collection of strips). NOT bamboo wind chimes. The single
standalone light natural bamboo Korean rolling mat with parallel strips + cotton string
binding on the Cool Sage background is the hero — no rice, no nori, no fillings, no kimbap
being rolled."""
    },
    {
        "id": "TOOL-11",
        "name": "mixing_bowl",
        "action": "mix bibimbap (비비기)",
        "mapping": "F-08 비빔밥",
        # §5.11.11 mixing 큰 그릇 — 한식 가정 large mixing bowl (silver-gray or white, deep wide)
        "body": """A modern mobile casual game asset illustration of a Korean home kitchen LARGE
MIXING BOWL (비빔 큰 그릇) as a standalone tool sprite, 7/8 perspective view (slight angled
view to show the deep round bowl shape + the wide open top + the inner cavity), the mixing
vessel for Korean bibimbap stirring (used in F-08 비빔밥 — the bowl where all 6 colored
sections of bibimbap are combined and mixed with chili paste and sesame oil). The bowl is
shown CLEAN AND EMPTY ready-to-use state.

Tool form: a KOREAN HOME LARGE MIXING BOWL — a wide deep round bowl shape with a flared
slightly-curved upper rim opening. Bowl dimensions: approximately 28-32cm diameter at the
top opening × 12-14cm deep (a large generous proportion suitable for mixing a hearty
bibimbap meal for the family; noticeably WIDER + DEEPER than typical small serving bowls).
Color choice — use SILVER-GRAY STAINLESS STEEL #B8BCC0 single fill (the classic Korean home
mixing bowl material, durable and slightly heavy) OR alternatively CLEAN MATTE WHITE #FAFAFA
single fill (a ceramic mixing bowl variant common in modern Korean homes). For this anchor
use SILVER-GRAY STAINLESS for consistency with the metallic tool aesthetic of TOOL-02/03/04
pots/pans. Subtle slim cel shading on the outer lower curve suggesting the rounded 3D bowl
volume in 7/8 view + ONE small specular highlight strip along the upper outer rim suggesting
the polished metal surface. The top has a WIDE OPEN ROUND OPENING (visible as an elliptical
opening shape due to 7/8 perspective, showing the inside as a slightly darker tone #A0A4A8
to suggest the inner cavity depth). The bowl rests on its flat round bottom (slightly visible
curve at the base, the bottom is slightly narrower than the top opening — a classic flared
bowl shape, NOT a perfect cylinder).

USE-HINT ACCENT: NO ingredients inside, NO motion line, NO mixing chopsticks/spoon (the bowl
is shown in clean ready state, awaiting the bibimbap ingredients).

%s

Important also: this is a Korean home LARGE MIXING BOWL for bibimbap mixing — the bowl MUST
be a WIDE DEEP ROUND silver-gray stainless steel bowl with FLARED TOP OPENING. NOT a small
serving rice bowl (rice bowls are small ~10-12cm diameter; mixing bowl is LARGER 28-32cm).
NOT a Korean dolsot stone bowl (dolsot is HEAVY BLACK STONE bowl for sizzling stone-pot
bibimbap — this is the lighter STAINLESS STEEL mixing bowl variant used for cold/regular
bibimbap that is mixed and eaten, NOT the sizzling stone variant). NOT a Japanese donburi
bowl (donburi is a smaller ceramic bowl for Japanese rice bowls). NOT a Chinese soup bowl
(small ceramic bowls with often decorative patterns). NOT a Western salad bowl with wood
trim (Western salad bowls are typically wooden or ceramic, this is metallic stainless).
NOT a TOOL-02 yangun cooking pot (cooking pot has 2 EAR HANDLES on the sides — mixing bowl
has NO HANDLES, just the bowl shape). NOT a deep fryer pot (deep fryer has 2 ear handles +
tall straight cylindrical sides — mixing bowl has flared open top + no handles + wider
shallower proportion). NOT a colander (colanders have drainage holes — this is solid bowl).
NOT a measuring cup (measuring cups have markings + spout + small handle). NOT a punch bowl
or party serving bowl (decorative party bowls are often ceramic with patterns). The single
standalone silver-gray stainless steel Korean home large mixing bowl with flared top opening
on the Cool Sage background is the hero — no food inside, no handles, no spoon for mixing
(those are separate)."""
    },
    {
        "id": "TOOL-12",
        "name": "korean_bbq_scissors",
        "action": "cut grilled meat (자르기)",
        "mapping": "F-12 갈비구이 (가위로 자른 후 eating-style)",
        # §5.11.12 한식 가위 — 한식 BBQ 갈비 자르기 전용 (large silver blade + warm handle)
        "body": """A modern mobile casual game asset illustration of a Korean KITCHEN BBQ SCISSORS
(주방 가위 / 갈비 가위) as a standalone tool sprite, 7/8 perspective view (slight angled view
to show the scissor silhouette + the 2 long sharp blades + the 2 looped finger handles + the
pivot screw at the center), the meat-cutting utensil for Korean BBQ table service (used in
F-12 갈비구이 — the iconic kitchen scissors that Korean BBQ servers use to cut grilled meat
into bite-sized pieces directly at the table). The scissors are shown CLEAN AND EMPTY
ready-to-use state with the blades slightly closed (NOT fully open, NOT mid-cutting action).

Tool form: a KOREAN KITCHEN BBQ SCISSORS — a robust LARGE scissor tool with 2 LONG SHARP
METAL BLADES + 2 LOOPED FINGER HANDLES + PIVOT SCREW at the center connecting them. Scissors
dimensions: total length ~22-25cm from finger loop tips to blade tips, the 2 blades are
~10-12cm long × ~2cm wide each with sharp pointed tips, the 2 finger handles are looped rings
~5-6cm diameter each. Blade color: SILVER-GRAY metallic stainless steel #B8BCC0 single fill
with subtle slim cel shading on the inner edge bevel of each blade + ONE small specular
highlight strip along the blade length suggesting the polished sharp metal sheen. Handle
color: WARM BROWN WOOD-LOOK or WARM BROWN PLASTIC #A67049 single fill (matching the cutting
board / spatula wood tone for cross-asset consistency, classic Korean kitchen scissor handle
look) for the 2 looped finger handles — OR alternatively MATTE BLACK #2A2A2A heat-resistant
plastic (modern variant). For this anchor use WARM BROWN HANDLES for visual warmth and
consistency with the cross-asset wood tone. The PIVOT SCREW at the center is a small visible
metal disc (~1cm diameter, slightly darker metallic accent) where the 2 blades cross and
pivot. The blades are slightly CLOSED (the 2 tips visible nearly touching or with a small
~1cm gap, the scissor in a relaxed natural closed-ish state).

USE-HINT ACCENT: NO meat being cut, NO motion line. Optional: very subtle hint of slight
gleam on the blade edge (single small slim specular highlight already part of the slim cel
shading, suggesting the sharpness).

%s

Important also: this is a Korean KITCHEN BBQ SCISSORS (specifically for cutting grilled meat
at the table, the iconic Korean BBQ tool). The scissors MUST be a LARGE ROBUST SCISSOR with
2 LONG SHARP METAL BLADES + 2 LOOPED FINGER HANDLES + WARM BROWN WOOD/PLASTIC HANDLE LOOPS.
NOT generic Western OFFICE SCISSORS (office scissors are smaller + thinner blades + often
plastic-only handles with no wood tone, often colorful — Korean BBQ scissors are LARGER +
ROBUST + warm brown handles). NOT FABRIC SCISSORS / SEWING SHEARS (fabric scissors have very
long thin blades + smaller loop handles for cutting fabric, not the robust kitchen
proportions). NOT POULTRY SHEARS specifically (poultry shears are similar but have a notch
in one blade for bone cutting + curved blades — Korean BBQ scissors are STRAIGHT BLADES).
NOT HAIR CUTTING SCISSORS (hair scissors have very thin sharp slim blades + small finger
loop with finger rest — distinctly different proportion). NOT MEDICAL SCISSORS / SURGICAL
SCISSORS (medical scissors have specific tip shapes for medical use). NOT KIDS CRAFT SCISSORS
(kids scissors have ROUNDED safety tips — Korean BBQ scissors have SHARP POINTED tips for
cutting meat efficiently). NOT GARDEN SHEARS (garden shears have THICK CURVED BLADES for
pruning branches — kitchen scissors have straighter thinner blades for food). NOT a TOOL-09
tongs (tongs are 2-arm gripping tool with no cutting edges — scissors have SHARP CUTTING
BLADES that cross at the pivot). The single standalone silver-gray sharp metal blades + warm
brown wood handle Korean BBQ kitchen scissors with slightly-closed blades on the Cool Sage
background is the hero — no meat being cut, no plate, no grill nearby."""
    },
]


def build_prompt(body: str) -> str:
    """body의 첫 %s를 STYLE_SUFFIX_TOOL로 교체. body의 다른 % 문자(예: percent 등)는
    .format / f-string과 달리 .replace로 안전 보존 (gen_food/gen_ingredient/gen_reaction에서
    동일 패턴 fix).
    """
    return body.replace("%s", STYLE_SUFFIX_TOOL, 1)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="M1 후반 조리도구 12종 anchor 자동 생성 (각각 별도 sprite, 애니메이션 prerequisite)"
    )
    parser.add_argument(
        "--only", type=str, default="",
        help="콤마구분 tool ID만 (예: TOOL-01,TOOL-02). 빈 값=전체 12장."
    )
    parser.add_argument("--model", default="gpt-image-1", choices=["dall-e-3", "gpt-image-1"])
    parser.add_argument(
        "--size", default="1024x1024",
        help="dall-e-3: 1024x1024 권장. gpt-image-1: 1024x1024 / 1536x1024 / 1024x1536."
    )
    parser.add_argument(
        "--quality", default="medium",
        help="dall-e-3: standard ($0.04) / hd ($0.08). gpt-image-1: low/medium/high/auto."
    )
    parser.add_argument(
        "--out-dir", type=Path,
        default=PROJECT_ROOT / "assets-raw" / "tool_anchors_m1",
        help="출력 디렉터리"
    )
    parser.add_argument(
        "--version", type=str, default="v1",
        help="파일명 suffix (예: v1 → TOOL-01_stovetop_gas_burner_v1.png)"
    )
    args = parser.parse_args()

    only_set = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    selected = [t for t in TOOLS if (only_set is None or t["id"] in only_set)]

    if not selected:
        sys.exit(f"❌ --only 매칭 tool 없음. 유효 ID: {[t['id'] for t in TOOLS]}")

    args.out_dir.mkdir(parents=True, exist_ok=True)

    # cost estimate
    if args.model == "dall-e-3":
        unit = 0.080 if args.quality == "hd" else 0.040
    else:
        unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
        unit = unit_map.get(args.quality, 0.042)
    est_total = unit * len(selected)
    print("=" * 70)
    print("🍳 M1 후반 조리도구 12종 anchor 생성 시작 (각각 별도 sprite, 애니메이션 prerequisite)")
    print(f"   모델: {args.model} / 품질: {args.quality} / 사이즈: {args.size}")
    print(f"   대상: {len(selected)}장 ({[t['id'] for t in selected]})")
    print(f"   비용 예상: ${unit:.3f}/장 × {len(selected)} = ${est_total:.2f}")
    print(f"   출력: {args.out_dir}")
    print("=" * 70)

    api_key = load_api_key()
    client = OpenAI(api_key=api_key)

    successes: list[str] = []
    failures: list[tuple[str, str]] = []
    t0 = time.time()

    for i, tool in enumerate(selected, 1):
        tid = tool["id"]
        name = tool["name"]
        action = tool["action"]
        mapping = tool["mapping"]
        out_path = args.out_dir / f"{tid}_{name}_{args.version}.png"
        prompt = build_prompt(tool["body"])

        print(f"\n[{i}/{len(selected)}] {tid} ({action}) mapping={mapping}")
        print(f"   → {out_path.name}")
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
            elapsed = time.time() - t_start
            print(f"   ⏱️  {elapsed:.1f}s")
            successes.append(tid)
        except Exception as exc:
            elapsed = time.time() - t_start
            print(f"   ❌ FAIL ({elapsed:.1f}s): {exc!r}")
            failures.append((tid, repr(exc)))

    total_elapsed = time.time() - t0
    print("\n" + "=" * 70)
    print(f"✅ 완료: {len(successes)}/{len(selected)} 장 — 총 {total_elapsed/60:.1f}분")
    if successes:
        print(f"   성공: {', '.join(successes)}")
    if failures:
        print(f"   실패 {len(failures)}장:")
        for tid, err in failures:
            print(f"     - {tid}: {err}")
    print(f"   비용 예상: ${unit * len(successes):.2f}")
    print(f"   저장 경로: {args.out_dir}")
    print("=" * 70)


if __name__ == "__main__":
    main()
