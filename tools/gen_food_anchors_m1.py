"""
K-Food Master — M1 sprint 음식 12장 anchor 자동 생성.

ADR-006 (ChatGPT/DALL-E) 기반. art-director docs/prompts-library.md v1.17
§2.4 STYLE_SUFFIX_FOOD + §5.2 F-01~F-12 12장 prompt를 그대로 inline 임베드.

v1.17 sync (2026-05-30, mvp-food-selection v2.2 trigger — game-designer 2026-05-28 완료):
- F-02 호떡 → 잔치국수 (Janchi-guksu) 전면 교체. T1, 소면 hero (white wheat thin noodles),
  멸치 dashi clear broth + 계란 지단 + 김 strips + 애호박 garnish. 호떡 본문 deprecated.
- F-09 김치찌개 → 불고기 (Bulgogi) 전면 교체. T2, 얇은 marbled 소고기 hero (thin-sliced beef
  fanned in soy-pear-garlic marinade pool), 양파+대파+당근+표고 mixed in same cast-iron pan.
  김치찌개 본문 deprecated. CRITICAL F-12 갈비 차별화: NO bone-in LA cut, NO wire mesh grate.

v1.9 sync (2026-05-28): F-12 R7 reroll LA-cut long strip form + multiple cross-section bone
discs along length + green scallion rounds + wire mesh grill grate + 7/8 perspective 5건 fix.
F-01/F-03/F-05/F-06 4건은 v1.5 R3 본문 유지 (R3 LOCK candidate).
F-07/F-08/F-10/F-11 4장은 R2 v2 LOCK candidate 유지 (본문 무변경).
F-04 떡볶이는 R1 LOCK 유지 (본문 무변경).
F-02 / F-09는 v1.17 mvp v2.2로 전면 교체 (위 참조).

v1.9 패치 핵심 (F-12 only, v6 → v7, 사용자 또 다른 reference image 기준 5건 fix):
- Fix 1 form 전면 교체 (small square pieces grid → LA-cut long strips):
  v6 multiple small square-shaped meat pieces (12-16 pieces, each 3-4cm × 3-4cm × 0.5-0.8cm)
  in grid pattern (3-4 rows × 4 columns) 폐기 → v7 4-6 large rectangular LA-style meat strips
  (each ~18-25cm long × 8-12cm wide × 0.5-0.8cm thick) arranged side by side parallel on the
  grill grate (slight natural overlap or aligned, NOT perfectly geometric grid). 정통 LA갈비
  cross-cut form 회귀.
- Fix 2 bone form 완전 재정의 (single long bone at short edge → 3-4 cross-section discs along
  each strip's length, CRITICAL signature):
  v6 SINGLE LONG WHITE RIB BONE (12-15cm) laid alongside meat grid on ONE SHORT EDGE 폐기 →
  v7 각 meat strip이 3-4 small ROUND WHITE BONE CROSS-SECTION DISCS (each ~1.5-2cm diameter,
  cream-white color) visible along its LENGTH — LA-style cross-cut bones (ribs cut perpendicular
  to original direction), evenly spaced along length (~3-5cm apart). LA-Galbi 정통 cut signature.
- Fix 3 garnish 변경 (chopped minced garlic → chopped green scallion rounds):
  v6 finely CHOPPED MINCED GARLIC bits (yellowish-white granules) 폐기 → v7 CHOPPED GREEN
  SCALLION ROUNDS (송송 sliced spring onion / 대파, 1-3mm thick disc, bright green color)
  scattered as hero garnish + 깨 minor accent.
- Fix 4 plate/grill context 변경 (cast iron plate → round metallic wire mesh grill grate):
  v6 black cast iron grill plate / copper grate / 흰 plate 폐기 → v7 ROUND METALLIC WIRE MESH
  GRILL GRATE (silver-gray wire pattern visible) + optional hot coals red-orange glow underneath.
  정통 한식 BBQ tabletop grill context.
- Fix 5 view angle 변경 (top-down → slight 7/8 perspective):
  v6 top-down view 폐기 → v7 slight 7/8 perspective view (mostly top-down but slightly angled
  to show meat thickness side profile + grill grate depth). side profile에서 paper-thin
  (0.5-0.8cm) 확인 가능.
- v6 유지 요소 4건 (LOCK 무변경): well-grilled caramelized dark brown + glossy glaze sheen /
  char marks visible on surface from grill (LA-cut form에서 char marks dominant) / thin slice
  0.5-0.8cm thickness / cross-cultural negative (yakiniku/American BBQ/char siu/steak/raw) +
  추가 NOT v6 small square pieces grid form (deprecated for this LA-galbi reference)
- 부분 폐기 — 칼집 (knife score marks) optional로 격하: v3~v6 핵심 LOCK 시그니처였으나 R7
  reference에서는 cross-cut bones이 dominant signature이고 score marks는 명확히 보이지 않음.
  LA-cut form에서 score marks는 필수 시그니처 아님 (visible면 OK, 없어도 PASS).

v1.8 패치 (이전 R6, F-12 form 전면 교체 + thickness + bone short edge + 마늘 dots 4건 fix, archived)

v1.7 패치 (이전 R5, F-12 thickness + bone TOP LONG EDGE 2건 fix, archived):
- thickness 더 얇게: 1-1.5cm thick → 0.7-1cm thick (very thin slice, 6-8mm)
- bone 위치 재정의: "nestled between the strips at the plate edges" 폐기 →
  "along the TOP LONG EDGE of each meat strip, partially embedded into the upper long edge"
- v4 유지 요소 6건 (LOCK 무변경): 칼집 / strictly parallel / well-grilled brown / 길이 12-15cm /
  garnish / plate context

v1.6 패치 (이전 R4, F-12 전면 재작성, archived):
- 칼집 (knife score marks) — 가장 중요한 시그니처, 각 strip 3-5 deep horizontal cuts
- thin elongated parallel meat strips (4 strips × 12-15cm × 3cm × 1-1.5cm, strictly parallel NOT overlapping)
- small white bone cross-section discs nestled between strips at plate edges
- well-grilled caramelized brown + soy-pear-garlic glaze sheen (NOT raw red-pink)
- grill marks along score lines + edges
- R3 "single bone at one end" 묘사 완전 폐기

v1.5 패치 (이전 R3, F-01~F-06):
- F-01: v1 base 회복 + 면 THIN delicate (v2의 보수적 수식 제거)
- F-02: v2 contained filling + 표면 topping syrup drizzle 추가
- F-03: v1 base 회복 + 밥알 FINE small fix
- F-05: v1 base 회복 + 밥알 FINE small fix
- F-06: v2 base + cross-section 4요소 명확 (sausage core + cheese stretch + panko + ketchup/mustard zigzag)

Usage:
    py tools/gen_food_anchors_m1.py
    py tools/gen_food_anchors_m1.py --only F-01,F-03         # 일부만
    py tools/gen_food_anchors_m1.py --model gpt-image-1      # 모델 override
    py tools/gen_food_anchors_m1.py --quality hd             # dall-e-3 HD ($0.08/img)
    py tools/gen_food_anchors_m1.py --version v2             # 파일명 suffix (R1 v1과 공존)

Default:
    model    = dall-e-3 (prompt가 DALL-E 3 약점 회피로 튜닝됨)
    quality  = standard ($0.04/img × 12 = ~$0.48 total)
    size     = 1024x1024 (square 1:1, prompts-library §2.4 명시)
    out_dir  = assets-raw/food_anchors_m1/
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
# §2.4 STYLE_SUFFIX_FOOD — 모든 음식 prompt 끝에 부착
# prompts-library.md v1.3 §2.4 그대로 (단 placeholder [STYLE_SUFFIX_FOOD] 헤더 제거).
# ─────────────────────────────────────────────────────────────────────────────
STYLE_SUFFIX_FOOD = """Format: square 1:1.
View: top-down (overhead) or slight 7/8 top-down (Royal Match food card aesthetic).
Style: modern mobile casual game food card, clean 2D illustration in Royal Match (Dream Games 2021)
plated dish aesthetic. Hero shot of a finished plated Korean dish, ready to serve.
Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), single color fill
with optional soft 1-layer cel shading and ONE small specular highlight per food element (juicy appetite).
Vibrant saturated colors at 80-90 percent saturation, warm food + cool plate/bowl balance.
Background is solid Cool Sage (#C8D5C0) OR Cream-white (#FAFAFA) — choose one consistently.
Single subtle ambient ellipse shadow directly under the bowl/plate (#000 ~25% alpha).
Bowls/plates are clean white or pale celadon with bold outline, NO ornamental pattern, NO text on rim.

Important: avoid beige background, cream paper background, scrapbook, storybook, kraft paper,
vintage texture, golden hour, sunset warm lighting,
Cookie Run, Cookie Run Kingdom frosting style, Toca Boca, Toon Blast over-cartoony,
realistic or photorealistic rendering, 3D render, octane or unreal engine, food photography,
any texture, noise, grain, painterly or hand-painted feel, watercolor, gradient mesh,
multi-layer complex shading, hyperdetailed elements, cinematic, gritty,
Japanese (sushi maki tightly compressed, nori shiny seaweed style, ramen Japanese bowl with bamboo,
miso ramen, tonkotsu, narutomaki pink spiral fish cake, Japanese ceramic decoration, hashioki chopstick rest),
Chinese (hot pot, Sichuan, mapo tofu, lo mein noodles, fried rice with peas/carrots Western style,
red Chinese lantern as garnish, chinese soup spoon flat-bottom, blue-and-white porcelain),
Western (American corn dog with stick handle as deep-fried hot dog, hamburger, BBQ skewer Western style,
Italian pasta swirl, ratatouille, French plating with sauce drizzle),
human characters, hands holding the food, cooking action, kitchen environment background,
any English or Korean text legibly readable on the dish (use solid block placeholders only if labels needed)."""


# ─────────────────────────────────────────────────────────────────────────────
# §5.2 음식 12 anchor prompt (F-01~F-12) — prompts-library.md v1.3 그대로 inline.
# 각 항목: id / filename / body. STYLE_SUFFIX_FOOD는 자동 append.
# ─────────────────────────────────────────────────────────────────────────────
FOODS = [
    {
        "id": "F-01",
        "name": "ramyeon",
        # v1.5 = v1 base 회복 + 면만 THIN delicate (v2 보수적 수식 제거)
        "body": """A modern mobile casual game food card illustration of Korean Ramyeon (spicy noodle soup), top-down view.
A white round porcelain bowl (Korean baekja style, clean white, NOT black Japanese ramen bowl) is filled
with vibrant orange-red spicy gochugaru broth. THIN delicate yellow wavy curly egg noodles
emerge from the broth in a soft swirl (Korean instant ramyeon style,
NOT straight Japanese ramen noodles).
A single sunny-side-up egg with a bright yellow yolk sits in the center.
3-5 small green spring onion (pa) chopped dots float on the surface as garnish.
One small red chili pepper slice as accent (optional).
Single subtle ambient ellipse shadow under the bowl.

%s

Important also: this is Korean Ramyeon (spicy instant noodle soup), NOT Japanese ramen,
NOT miso ramen, NOT tonkotsu, NOT shoyu. The broth is bright vibrant orange-red (gochugaru spicy),
NOT brown miso, NOT pale white tonkotsu. The noodles are visibly curly wavy yellow,
NOT straight thin Japanese ramen noodles, NOT thick chunky udon-style strands.
The bowl is clean white Korean baekja, NOT a black Japanese donburi bowl with bamboo accents.
NO narutomaki pink spiral fish cake, NO nori seaweed sheet on top, NO chashu pork slices.""",
    },
    {
        "id": "F-02",
        "name": "janchi_guksu",
        # v1.17 mvp v2.2 = 호떡 → 잔치국수 전면 교체 (game-designer 2026-05-28 mvp-food-selection v2.2)
        # hero ingredient = 소면 (white wheat thin noodles). 부 hero = 멸치 dashi broth / 계란 지단 / 김 strips / 애호박.
        # 호떡 본문은 archive (deprecated 2026-05-30, mvp v2.2 trigger).
        "body": """A modern mobile casual game food card illustration of Korean Janchi-guksu (잔치국수,
Korean celebration noodle soup with anchovy broth), top-down view.
A wide clean white round shallow bowl (Korean baekja porcelain, gently sloped wide rim, large enough
for noodles + clear broth + garnish, NOT a deep narrow Japanese ramen donburi, NOT a Vietnamese pho
deep wide soup plate) is filled with light golden-amber clear anchovy dashi broth (멸치 육수,
warm pale brown-yellow gentle tone — the gentle clear broth made from dried anchovies + dried kelp,
NOT a thick brown miso, NOT a pale white tonkotsu, NOT a vibrant spicy red gochugaru, NOT a
dark soy-based broth, NOT a vivid Vietnamese pho cinnamon-clove tinted broth).
THIN delicate white wheat noodles (소면 somen-style Korean white thin wheat noodles, fine slim strands)
emerge in a soft swirled nest at the center of the bowl, the noodles forming a gentle rounded mound
that rises just above the broth surface (the noodles are clearly visible as the hero element, the
broth pools around the noodle mound).
GARNISH on top of the noodle mound (Korean janchi-guksu signature, arranged in clean separated
strips fanning out from the center):
(1) bright YELLOW EGG RIBBON strips (지단 julienned egg crepe, thin yellow rectangular strips
~3-5cm long × ~3mm wide, 5-7 strips fanning across one side of the noodle mound, a hero garnish),
(2) dark green-black GIM SEAWEED STRIPS (얇게 자른 김, thin rectangular black-green seaweed strips
~3-5cm long × ~3mm wide, 5-7 strips on the opposite side of the egg ribbon, matte NOT glossy),
(3) thin GREEN ZUCCHINI ROUNDS or julienned light-green zucchini (애호박, 3-4 thin pale green
diagonal slices ~2cm long × ~1cm wide × very thin, scattered as accent),
(4) optional 1-2 small DRIED ANCHOVY (멸치) garnish on the rim or beside the bowl as a hint of the
broth ingredient (small slim silver-gray fish ~2-3cm long, OPTIONAL minor accent),
(5) optional 1 RED CHILI PEPPER SLICE (small thin red diagonal slice as color accent, OPTIONAL).
Single subtle ambient ellipse shadow under the bowl.

%s

Important also: this is Korean Janchi-guksu (잔치국수, celebration noodle soup with clear anchovy
dashi broth), NOT Japanese somen (Japanese somen is served cold with tsuyu dipping sauce in a
separate cup + ice cubes + green onion garnish, NOT in a hot anchovy broth bowl with egg ribbon +
gim + zucchini), NOT Japanese udon (udon noodles are THICK chunky white strands, janchi-guksu is
THIN delicate strands), NOT Japanese ramen (ramen has curly yellow egg noodles + miso/tonkotsu/shoyu
broth + narutomaki/chashu/nori sheet, NOT clear anchovy broth + egg ribbon/gim/zucchini garnish),
NOT Japanese soba (soba is buckwheat brown-gray noodles, janchi-guksu is white wheat noodles).
NOT Vietnamese pho (pho has clear cinnamon-clove beef broth + raw beef slices + lime wedge + bean
sprouts + Thai basil + cilantro + hoisin/sriracha side, janchi-guksu has anchovy broth + egg ribbon
+ gim + zucchini, NO lime, NO bean sprouts, NO basil/cilantro herbs, NO sliced beef).
NOT Chinese egg noodle soup or wonton soup (those use yellow egg noodles + char siu pork / wontons,
NOT thin white wheat noodles + Korean garnish set).
NOT Korean instant Ramyeon (F-01 with vibrant orange-red gochugaru spicy broth + curly yellow
noodles + sunny-side-up egg + spring onion — janchi-guksu is the OPPOSITE: clear gentle anchovy
broth + thin white wheat noodles + egg ribbon strips + gim strips, gentle vs spicy, white vs yellow,
clear vs red).
The ESSENTIAL signature features are: (a) wide clean white Korean baekja shallow bowl + (b) LIGHT
GOLDEN-AMBER clear anchovy broth + (c) THIN delicate WHITE wheat noodles swirled mound + (d) bright
YELLOW EGG RIBBON STRIPS as hero garnish + (e) dark GIM SEAWEED STRIPS contrast garnish + (f) thin
green zucchini accent. The combination of clear anchovy broth + thin white wheat noodles + yellow
egg ribbon + dark gim strips is the unmistakable Korean janchi-guksu signature.
NO Japanese ceramic pink spiral narutomaki, NO chashu pork, NO seaweed sheet on top (gim is in
JULIENNED STRIPS, not a sheet), NO wasabi, NO gari, NO bonito flakes, NO mayo, NO lime wedge,
NO bean sprouts, NO herbs (basil/cilantro), NO sliced raw beef.""",
    },
    {
        "id": "F-03",
        "name": "kimbap",
        # v1.5 = v1 base 회복 + 밥알 FINE small fix
        "body": """A modern mobile casual game food card illustration of Korean Kimbap (seaweed rice roll), top-down view.
4-5 thick round slices of Kimbap arranged in a single row on a white plate or wooden board.
Each slice has a black seaweed (gim) outer ring with white rice with FINE small grains underneath
(Korean short-grain rice, tight uniform white field, individual grains barely visible,
NOT chunky oversized beads),
and a colorful cross-section center showing distinct ingredient blocks: yellow pickled radish (danmuji), orange carrot,
green spinach or cucumber, red ham or beef strips, and yellow egg strips.
The slices are THICK and ROUND (Korean Kimbap style, approximately 3cm diameter,
NOT thin compact Japanese maki sushi). A few sesame seed dots are sprinkled on top.
The plate or wooden board is clean and simple.

%s

Important also: this is Korean Kimbap (street market style with cooked vegetables and ham/beef),
NOT Japanese maki sushi (which uses raw fish and tightly compressed rice), NOT futomaki, NOT California roll.
Kimbap is THICKER and has more colorful vegetable cross-sections.
The rice grains are FINE and small (Korean short-grain, tight uniform field),
NOT chunky oversized rice grains, NOT lumpy clumpy rice, NOT visible giant rice beads.
The seaweed (gim) is matte dark green-black, NOT glossy shiny nori. NO raw salmon, NO raw tuna,
NO wasabi green paste, NO pink pickled ginger (gari), NO Japanese soy sauce dish with hashioki chopstick rest.
The rice is white short-grain Korean style, lightly seasoned with sesame oil (NOT vinegar sushi rice).""",
    },
    {
        "id": "F-04",
        "name": "tteokbokki",
        "body": """A modern mobile casual game food card illustration of Korean Tteokbokki (spicy rice cakes), 7/8 top-down view.
On a clean white or pale celadon plate, 6-10 thick cylindrical white rice cakes (garaetteok, finger-thickness,
2-3cm long each) are coated generously in vibrant spicy red gochujang sauce.
The red sauce is thick and glossy, pooling around the rice cakes.
2-3 brown fish cake (eomuk) flat triangular slices are mixed in.
A few green spring onion chopped dots scattered as garnish.
Optional: one halved boiled egg as accent on the side.
Single subtle ambient ellipse shadow under the plate.

%s

Important also: this is Korean Tteokbokki (street market spicy rice cake stew),
NOT Chinese rice cake stir-fry (nian gao), NOT Japanese mochi.
The rice cakes are WHITE, THICK CYLINDRICAL (finger-shape, NOT flat oval Chinese nian gao,
NOT round mochi balls). The sauce is bright vibrant red gochujang (Korean chili paste),
glossy and thick (NOT brown soy-based, NOT clear broth).
NO Chinese chopsticks on a plate-side, NO Japanese bento box compartments.""",
    },
    {
        "id": "F-05",
        "name": "kimchi_fried_rice",
        # v1.5 = v1 base 회복 + 밥알 FINE small fix
        "body": """A modern mobile casual game food card illustration of Korean Kimchi Fried Rice (Kimchi Bokkeumbap),
7/8 top-down view. A rounded mound of white rice with FINE small grains
(Korean short-grain rice, tight uniform field, individual grains barely visible,
NOT chunky oversized beads)
stained slightly orange-red from kimchi sauce sits on a white plate or in a small black cast iron pan.
Visible chopped red kimchi pieces (4-6 small segments) are mixed throughout the rice.
A bright sunny-side-up egg with a vivid yellow yolk sits on top of the rice as the hero element.
A scattering of green chopped spring onion dots and a light sprinkle of black gim (Korean seaweed) flakes as garnish.
Single subtle ambient ellipse shadow under the plate.

%s

Important also: this is Korean Kimchi Bokkeumbap (Kimchi Fried Rice),
NOT Chinese egg fried rice (which has green peas, diced carrots, tiny shrimp Western style),
NOT Japanese chahan, NOT Spanish paella.
The dominant flavor color is red-orange from kimchi (NOT brown soy fried rice).
The rice grains are FINE and small (Korean short-grain, tight uniform field),
NOT chunky oversized rice grains, NOT lumpy clumpy rice, NOT visible giant rice beads.
NO green peas, NO diced carrots in Western mirepoix style, NO Chinese soup spoon on the side,
NO bamboo plate, NO wok char-marks on the rice. The egg is sunny-side-up whole egg on top
(NOT scrambled mixed-in Chinese style).""",
    },
    {
        "id": "F-06",
        "name": "corn_dog",
        # v1.5 = v2 base + cross-section 4요소 명확 (sausage core + cheese + panko + ketchup/mustard)
        "body": """A modern mobile casual game food card illustration of Korean Corn Dog (Hot Dog), 7/8 view with stick visible.
A golden-brown deep-fried corn dog on a wooden stick is held cleanly by the stick with no paper wrapper,
displayed in a clean composition against the background (the stick handle is the only support, NO paper cup,
NO paper holder, NO awkward paper plate underneath).
The coating has visible crispy panko crumb texture (Korean corn dog style, NOT smooth American cornmeal batter).
A bite has been taken from the top, revealing a clear CROSS-SECTION showing all four signature elements:
(1) a brown cooked sausage (hot dog) at the core/center of the corn dog (the sausage body is clearly visible
as a distinct cylindrical brown shape in the middle),
(2) bright yellow mozzarella cheese filling surrounding the sausage with 2-3 stretchy cheese strands
pulling visibly upward from the bite mark (the signature Korean corn dog cheese pull),
(3) a golden-brown crispy panko crumb coating wrapping the outside (slightly bumpy texture, clearly distinct
from the cheese layer underneath),
(4) red ketchup zigzag drizzle and yellow mustard zigzag drizzle on top of the crispy outer surface.
Optional: a light sprinkle of sugar grains or sesame seeds as accent.

%s

Important also: this is KOREAN Corn Dog (street market style with sausage core + mozzarella cheese pull
+ crispy panko coating + ketchup/mustard zigzag), NOT American corn dog (which is smooth yellow cornmeal
batter wrapped around a plain hot dog, no cheese stretch). The visible cross-section showing distinct
sausage + cheese + panko coating layers is the ESSENTIAL identifying feature of Korean Corn Dog —
NO missing sausage core, NO cheese-only filling without sausage, NO ambiguous interior where
the layers blend together. The sausage must read as a clearly cooked brown hot dog cylinder at the center,
the mozzarella as a yellow stretchy layer around it, the panko as a bumpy golden-brown crust outside.
The coating is golden-brown panko crumb texture (slightly bumpy), NOT smooth yellow cornmeal.
NO awkward paper plate or paper holder underneath, NO weird paper wrapping at the base of the stick,
NO American county fair fairground basket, NO yellow batter dripping, NO Japanese kushiyaki skewer.
The composition is clean — only the corn dog and its wooden stick are visible against the solid background.""",
    },
    {
        "id": "F-07",
        "name": "haemul_pajeon",
        "body": """A modern mobile casual game food card illustration of Korean Haemul Pajeon (seafood scallion pancake),
top-down view. A large round golden-brown pan-fried pancake fills a clean white round plate.
Long thick green scallions (대파 daepa, Korean scallions, finger-length, multiple strips) AND red-pink shrimp
are MIXED INTO AND PARTIALLY SUBMERGED WITHIN the golden batter — the batter is the body of the pancake,
and the scallions and shrimp are integrated ingredients BAKED INTO the pancake itself (NOT laid on top after cooking).
The scallions and shrimp are partially visible above the surface but mostly embedded in the batter,
with batter visibly surrounding and covering parts of each ingredient (fully integrated as one cohesive pancake,
NOT a flat batter disc with separate toppings sitting on top).
1-2 white squid ring slices are also embedded similarly in the pancake.
The pancake edges are slightly crispy golden-brown (pan-fried texture, not deep-fried).
Optional: a small side dipping sauce dish (soy sauce with chili) on the corner.
Single subtle ambient ellipse shadow under the plate.

%s

Important also: this is Korean Haemul Pajeon (scallion-dominant savory pancake with seafood),
NOT Japanese okonomiyaki (which has shredded cabbage as dominant filling, mayo + bonito flakes + brown sauce on top),
NOT Chinese cong you bing (which is a layered flatbread with no seafood).
The scallions and shrimp are BAKED INTO the pancake batter (partially visible above the surface
but mostly embedded), NOT laid on top of a finished batter disc as separate toppings.
The visible green scallions integrated within the batter are the ESSENTIAL identifying feature.
NO mayo squiggle drizzle, NO bonito katsuobushi flakes dancing on top, NO brown okonomiyaki sauce,
NO Japanese aonori green seaweed powder, NO ingredients sitting on top of the pancake as separate toppings.
The pancake batter is light golden-brown, NOT dark brown American buttermilk pancake.""",
    },
    {
        "id": "F-08",
        "name": "bibimbap",
        "body": """A modern mobile casual game food card illustration of Korean Bibimbap (mixed rice bowl), top-down view.
A large clean white ceramic bowl (Korean baekja or pale celadon style) is filled with FINE small rice grains
in the center base (Korean short-grain rice, individual grains barely visible as a tight uniform white field,
NOT chunky oversized grains).
On top, 5-6 colorful vegetable sections are arranged in a beautiful radial pattern around the rice:
yellow soybean sprouts (kongnamul), bright green spinach (sigeumchi),
orange julienned carrot, brown braised fernbrake (gosari) or shiitake mushroom strips,
bright red kimchi or seasoned beef bulgogi, white pickled radish (musaengchae).
A single bright orange-yellow egg yolk (raw or sunny-side-up style) sits in the EXACT CENTER as the hero element.
A small dollop of bright red gochujang (Korean chili paste) on the side of the bowl rim.
A light sprinkle of sesame seeds. Single subtle ambient ellipse shadow under the bowl.
Tier 2 abundance: the 6 vegetable sections are generously portioned, bowl looks full and festive.

%s

Important also: this is Korean Bibimbap (mixed rice bowl with radial vegetable arrangement + center egg yolk),
NOT a Buddha bowl (Western health food), NOT a Chinese rice bowl (which has fewer vegetable sections),
NOT a Japanese donburi (which is a single topping on rice).
The rice grains are FINE and small (Korean short-grain, individual grains barely visible),
NOT chunky oversized rice grains, NOT lumpy clumpy rice, NOT visible giant rice beads.
The 6 colorful vegetable sections in radial arrangement + center egg yolk + gochujang dollop are the
ESSENTIAL identifying features of Bibimbap.
NO avocado slices, NO quinoa, NO Buddha bowl Western superfoods,
NO Japanese pickled umeboshi plum, NO bamboo chopsticks placed on top.""",
    },
    {
        "id": "F-09",
        "name": "bulgogi",
        # v1.17 mvp v2.2 = 김치찌개 → 불고기 전면 교체 (game-designer 2026-05-28 mvp-food-selection v2.2)
        # hero ingredient = 얇은 marbled 소고기 (thin-sliced sirloin, soy-pear-garlic marinade glaze).
        # 부 hero = 양파/대파/당근/표고. 김치찌개 본문은 archive (deprecated 2026-05-30, mvp v2.2 trigger).
        # F-12 갈비구이와 차별화 CRITICAL: NO bone-in LA cut, NO visible white rib bone, NOT grilled on grate.
        # 불고기 = thin sliced beef + marinade pool + mixed vegetables in SAME PAN/DISH.
        "body": """A modern mobile casual game food card illustration of Korean Bulgogi (불고기, marinated
thin-sliced beef stir-cooked with onions, served on a plate), top-down view (overhead).

The dish is served on a GRAY-CHARCOAL CERAMIC ROUND SERVING PLATE (dark gray modern ceramic plate
with subtle slim rim, ~22-26cm diameter, matte gray finish #6B6B70 — NOT a cast-iron pan, NOT a
white plate, NOT a wooden tray, NOT a hot pot bowl — this is a finished plated dish, ready to eat).

HERO — CRUMBLED / TORN BEEF CHUNKS (the signature plated bulgogi appearance):
- The plate is generously filled (~80% area) with MANY SMALL CRUMBLED / TORN BEEF PIECES scattered
  messy and natural — each piece is a small irregular torn chunk ~2-4cm long, irregular organic
  shapes (NOT clean rectangular slices, NOT perfectly fanned strips, NOT large intact slices —
  the beef has been cooked + naturally torn into bite-size pieces by stirring in the marinade).
- Dark cooked brown beef color (#5C3A26 to #4A2C1A range, deeper brown from soy-marinade caramelization).
- Each beef chunk is GLAZED with a glossy sticky brown soy-pear-garlic marinade coating (간장+배+
  마늘+설탕+참기름 양념 glaze), thin coating sheen on each piece — NOT a pool of liquid marinade
  underneath, NOT a broth bath, NOT a flowing sauce. The marinade is REDUCED to a sticky glaze.
- Some beef chunks show subtle marbled fat hints (slim pale white veins on edges) where natural,
  but mostly the beef appears as a unified caramelized brown crumbled-mess.

VEGETABLES — onion only (simple, mixed in with beef):
- 5-8 THIN WHITE ONION SLICES (양파, thin half-moon strips ~3-5cm long × ~0.5-1cm wide, slightly
  translucent pale white-gold caramelized, scattered AND mixed in among the crumbled beef pieces —
  some visible at the top of the pile, some half-buried in beef).
- NO carrot, NO mushroom, NO scallion segments, NO dangmyeon glass noodles, NO bell pepper — just
  onion as the only mixed-in vegetable (simple home-style bulgogi).

GARNISH on top (signature):
- DOMINANT CHOPPED GREEN SCALLION ROUNDS (송송 sliced 대파, MANY small bright green disc-shaped
  rounds ~1-2mm thick × 5-8mm diameter, heavily scattered all over the top of the beef pile — at
  least 15-20 scallion rounds clearly visible, the HERO garnish that pops bright green against the
  dark brown beef).
- a few WHITE SESAME SEEDS (깨) sprinkled lightly as MINOR accent (5-10 visible, NOT dominant —
  scallion rounds are the hero garnish, sesame is just a small accent).

Single subtle ambient ellipse shadow under the gray ceramic plate.

%s

Important also: this is Korean Bulgogi (불고기, plated home-style — thin marinated beef stir-cooked
with onions and served plated, garnished with chopped scallion). The ESSENTIAL signature features
are: (a) GRAY-CHARCOAL CERAMIC ROUND PLATE (NOT cast-iron pan, NOT bowl, NOT hot pot, NOT grill
grate) + (b) CRUMBLED/TORN small beef chunks scattered messy (NOT fanned thin slices, NOT large
intact slices) + (c) GLOSSY STICKY BROWN soy-pear-garlic marinade GLAZE coating each beef chunk
(NOT a pooling liquid marinade, NOT a broth) + (d) ONION ONLY as mixed vegetable (translucent
half-moon slices) + (e) DOMINANT chopped scallion rounds garnish (15-20+ bright green rounds, hero
garnish) + a few sesame seeds (minor accent).

CRITICAL — F-12 갈비구이 차별화 (이 요리는 갈비 NOT 갈비):
- NO BONE-IN LA CUT — bulgogi uses BONELESS thin-sliced beef, ABSOLUTELY NO visible white rib bone,
  NO bone cross-section discs, NO single long bone. Any rib bone = immediate FAIL.
- NOT GRILLED ON METAL GRATE — bulgogi is stir-cooked and plated, NOT on a wire mesh grill grate.
- NOT FANNED STRIPS — bulgogi has CRUMBLED/TORN small chunks, NOT large thin slices arranged
  parallel or fanned. This is the home-style stir-cooked plated bulgogi, NOT a presentation cut.

NOT a CAST-IRON PAN COOKING SCENE — this is the FINISHED PLATED DISH ready to eat on a serving
plate, NOT cooking-in-progress in a pan.
NOT Japanese SUKIYAKI (deeper broth bath + raw egg dipping bowl + tofu cubes + napa cabbage).
NOT Japanese SHABU-SHABU (clear simmering broth pot + dipping sauce setup).
NOT Japanese YAKINIKU (grilled boneless thin beef on tabletop grill grate with dipping sauce).
NOT Chinese BEEF STIR-FRY (wok hei char + thick cornstarch sauce + Chinese cabbage / bok choy /
bean sprouts vegetable set + chopsticks).
NOT American BBQ RIBS (red BBQ sauce + thick slab + bone).
NOT Korean Kimchi Jjigae F-09 deprecated (red broth + ttukbaegi + 두부 cubes).

The combination of GRAY ceramic plate + CRUMBLED brown beef chunks (messy scattered) + STICKY
brown soy-pear-garlic GLAZE coating + ONION ONLY translucent slices mixed in + DOMINANT chopped
scallion rounds garnish (bright green hero, 15-20+ visible) + a few sesame seeds is the
unmistakable Korean plated home-style bulgogi signature.""",
    },
    {
        "id": "F-10",
        "name": "sundubu_jjigae",
        "body": """A modern mobile casual game food card illustration of Korean Sundubu Jjigae (soft tofu stew),
7/8 top-down view. A black Korean stone pot (ttukbaegi 뚝배기, same vessel style as Kimchi Jjigae,
rounded thick rim, individual portion) is filled with bubbling vibrant red-orange spicy gochugaru broth.
A generous mound of soft tofu broken into irregular cloud-like fluffy white curds
(sundubu signature appearance — like soft cottage cheese clumps or torn fluffy clouds,
organic uneven shapes with random soft edges and crevices, multiple small irregular white tofu fragments
floating and clumping together at the broth surface, NOT smooth puree, NOT firm cubes,
NOT mashed paste, NOT a single solid white block) dominates the center.
A bright orange-yellow raw egg yolk cracked on top (the signature sundubu jjigae feature).
1-2 small seafood pieces (a clam or shrimp) visible on the surface.
Green spring onion chopped dots scattered. 1-2 subtle steam swirl lines rising.
Tier 2 abundance: tofu mound is generously filled, egg yolk hero + seafood visible.

%s

Important also: this is Korean Sundubu Jjigae (soft tofu stew in ttukbaegi),
paired with Kimchi Jjigae as Korean stew family (use the same black ttukbaegi vessel style).
NOT Chinese mapo tofu (which uses firm tofu cubes in brown Sichuan sauce on a flat plate),
NOT Japanese yudofu (clear broth boiled tofu).
The tofu must appear as fluffy cloud-like irregular broken curds (like torn soft clouds or soft cottage cheese
clumps, organic uneven shapes), NOT smooth puree, NOT firm cubes, NOT mashed paste, NOT a single solid white block,
NOT geometric tofu pieces. The fluffy SOFT cloud-like tofu and the cracked raw egg yolk on top
are the ESSENTIAL identifying features.
The broth is bright vibrant red-orange (Korean gochugaru), NOT brown Sichuan mapo sauce.
NO Sichuan mala peppercorns, NO thick brown bean paste sauce, NO Chinese chili oil layer.""",
    },
    {
        "id": "F-11",
        "name": "japchae",
        "body": """A modern mobile casual game food card illustration of Korean Japchae (sweet potato glass noodles),
top-down view. A large clean white or pale celadon plate is generously filled with THIN delicate translucent
brown-amber sweet potato glass noodles (dangmyeon 당면, slim shiny translucent strands like delicate threads,
NOT thick chunky strands, NOT thin yellow Chinese egg noodles, NOT white Italian pasta).
The noodles are mixed with vibrant colorful vegetable strips:
bright green spinach, orange julienned carrot, red bell pepper strips,
white onion strips, dark brown shiitake or wood ear mushroom slices.
2-3 brown seasoned beef bulgogi strips mixed in. A generous sprinkle of white sesame seeds on top
(Korean garnish signature). Single subtle ambient ellipse shadow under the plate.
Tier 2 abundance: plate is generously full, 6+ vegetable colors visible, festive holiday dish appearance.

%s

Important also: this is Korean Japchae (sweet potato glass noodles, holiday/festive Korean dish),
NOT Chinese lo mein (which uses yellow egg wheat noodles, brown soy sauce dominant),
NOT chow mein (crispy fried noodles), NOT Italian pasta (white wheat), NOT Pad Thai (orange-pink Thai sauce).
The translucent brown-amber GLASS NOODLES (dangmyeon, made from sweet potato starch) are the
ESSENTIAL identifying feature — they are THIN delicate, shiny, and see-through, unlike opaque wheat noodles.
The dangmyeon strands are slim and delicate (Korean japchae signature thickness),
NOT thick chunky strands, NOT rope-like noodles, NOT udon-style fat noodles.
The seasoning is light sesame oil + soy sauce (NOT thick brown Chinese sauce, NOT Thai tamarind).
NO Chinese chopsticks resting in the noodles, NO wok hei char marks, NO sriracha drizzle.""",
    },
    {
        "id": "F-12",
        "name": "galbi_gui",
        # v1.9 R7 = v6 base + form 전면 교체 (square pieces grid → LA-cut long strips) +
        # bone form 재정의 (single long bone at short edge → 3-4 cross-section discs along
        # each strip's length, CRITICAL LA cross-cut signature) +
        # garnish 변경 (minced garlic → green scallion rounds) +
        # plate 변경 (cast iron plate → round wire mesh grill grate) +
        # view angle 변경 (top-down → slight 7/8 perspective) 5건 fix
        # (사용자 v6 시각 확인 후 또 다른 reference image 제시: 정통 LA갈비 — round wire mesh
        # grill grate 위에서 굽고 있는 large rectangular strips with cross-section bone discs
        # along length, verbatim "이걸로 해줘")
        "body": """A modern mobile casual game food card illustration of Korean LA-style Galbi-gui (traditional LA-cut
grilled short ribs, plated for serving), slight 7/8 perspective view (mostly top-down but slightly
angled to show meat thickness side profile — the slight 7/8 angle reveals the THIN slice thickness
(0.5-0.8cm) from the side, confirming the paper-thin slice appearance).

Sitting on a clean white round ceramic plate (Korean baekja or pale celadon style, plain, no
ornamental pattern, no text on rim) — the dish has been transferred from the grill to a plate for
serving (this is a plated hero shot for a food card, NOT a cooking-in-progress scene). NO wire
mesh grill grate, NO hot coals glow, NO grill marks from grate underneath — the meat is plated
and ready to eat.

4-6 large rectangular LA-style meat strips are arranged side by side parallel on the plate.
Each strip dimensions: approximately 18-25cm long × 8-12cm wide × 0.5-0.8cm thick (paper-thin
appearance). The strips slightly overlap or sit side by side (natural BBQ arrangement, NOT
perfectly geometric grid — some strips lay lengthwise, some may sit slightly turned, just like
how meat sits on a real BBQ grate).

CRITICAL signature feature — LA CROSS-CUT BONE DISCS along each strip's LENGTH:
Each meat strip has 3-4 small ROUND WHITE BONE CROSS-SECTION DISCS visible along its LENGTH
(each disc approximately 1.5-2cm diameter, cream-white color). These are LA-style cross-cut bones
— the rib bones have been cut PERPENDICULAR to their original direction (cross-cut butchery), so
each bone cross-section appears as a small round white disc along the strip's length. The bones
are EVENLY SPACED along the length of each strip (approximately 3-5cm apart between discs). This
is the LA-Galbi traditional cut signature — multiple small round white bone discs appearing
across each strip's length, evenly spaced.

Each meat piece thickness: 0.5-0.8cm thick (5-8mm, very thin slice, paper-thin appearance — the
characteristic LA-galbi properly butchered cut, much thinner than a typical steak cut). The
slight 7/8 perspective angle reveals this thin thickness from the side profile.

COLOR — well-grilled appearance (cooked, NOT raw):
- Each meat strip surface is a rich caramelized dark brown with a glossy soy-pear-garlic marinade
  glaze (Korean galbi marinade — soy sauce + pear + garlic + sugar + sesame oil).
- Visible dark char marks / burned lines on the surface from prior grilling (the char marks are
  the dominant surface feature in LA-galbi, where the cross-cut bones are the signature rather
  than knife score marks).
- The meat appears well-cooked and glazed, NOT raw red-pink, NOT pale uncooked.
- A subtle sheen on the surface from the glaze (juicy appetite, single specular highlight per strip).

Garnish (v7 — chopped green scallion rounds as hero garnish):
- Generous scattering of CHOPPED GREEN SCALLION ROUNDS (송송 sliced spring onion / 대파, each
  round approximately 1-3mm thick disc, bright green color) scattered across the meat strips as
  the hero garnish (small bright green disc-shaped slices, the signature Korean LA-galbi finishing
  garnish).
- Plus a light sprinkle of white sesame seeds as additional accent (minor garnish).

%s

Important also: this is Korean LA-style Galbi-gui (정통 LA갈비, the LA-cut cross-cut style of
Korean BBQ short ribs) plated on a clean white ceramic plate, served and ready to eat.

NOT Japanese yakiniku (which uses thin bone-less slices with salt-only sear, no cross-cut bone discs).
NOT American BBQ ribs (which uses a single thick slab with bone on the side, red tomato BBQ sauce).
NOT Chinese char siu (which is pork shoulder with red coloring, no bones).
NOT a steak (which is a single thick boneless meat slab).
NOT v6 small square pieces grid form (deprecated for this LA-galbi reference — the R6 grid of
3-4cm square pieces is replaced by 4-6 large rectangular LA-style strips, the proper LA-galbi form).
NOT a single long bone alongside the meat (R6 deprecated pattern).
NOT bone discs partially embedded along TOP LONG EDGE only (R5 deprecated pattern).
NOT one big bone at one end of a strip (R3 deprecated pattern).
The bones are MULTIPLE SMALL ROUND DISCS appearing across each strip's length, evenly spaced —
the LA cross-cut signature where the ribs have been cut perpendicular to their original direction.

NOT a wire mesh grill grate (v7 deprecated — game asset context requires plated serving form, not
cooking-in-progress on a grill). NOT a black cast iron flat pan. NOT hot coals or fire — the
clean white ceramic plate (한식 백자) is the proper game context for LA-galbi as a finished
plated dish.

NOT chopped minced garlic dots (R6 deprecated garnish). NOT thin garlic slices on top. NOT whole
garlic cloves. NOT only sesame seeds — the chopped green scallion rounds (송송 sliced 대파,
bright green round discs) are the hero garnish.

NOT a top-down view (R6 deprecated). The slight 7/8 perspective is needed to show the meat
thickness side profile.

Form is CRITICAL — the meat is 4-6 large rectangular LA-style strips (each 18-25cm long × 8-12cm
wide × 0.5-0.8cm thick) arranged side by side parallel on the plate, NOT small square pieces
in grid pattern. This is the classic LA-galbi cross-cut form, plated for serving.

Bone form is CRITICAL — each strip has 3-4 small round white bone cross-section discs visible
along its length (evenly spaced ~3-5cm apart), NOT a single long bone alongside the meat, NOT
bones at the strip edge only, NOT bones at the tips. This is the LA-Galbi cross-cut signature
where the ribs are cut perpendicular to their original direction.

Plate context is CRITICAL — clean white round ceramic plate (Korean baekja/pale celadon, plain,
no pattern), the meat strips are plated as a finished serving (game asset context — NOT
cooking-in-progress on a grill, NOT a wire mesh grate, NOT hot coals).

The LA-cut form (large strips) + cross-section bone discs along each strip's length (LA signature)
+ thin slice 0.5-0.8cm + caramelized brown + char marks + chopped green scallion rounds garnish
+ clean white ceramic plate context + slight 7/8 perspective view are the ESSENTIAL identifying
features. NO raw red-pink uncooked meat, NO thick slab, NO bone-less yakiniku slices, NO red BBQ
sauce, NO small square pieces grid form, NO single long bone alongside, NO minced garlic dots,
NO wire mesh grill grate, NO hot coals, NO top-down view.

(Optional: knife score marks (칼집) on the meat surface are OK if naturally visible, but they are
NOT a required signature for the LA-cut form — the cross-cut bone discs are the LA-galbi signature,
not the score marks. Score marks are deprioritized to optional for R7 v7.)""",
    },
]


def build_prompt(body: str) -> str:
    """body의 첫 %s를 STYLE_SUFFIX_FOOD로 교체. body의 다른 %는 보존."""
    return body.replace("%s", STYLE_SUFFIX_FOOD, 1)


def main() -> None:
    parser = argparse.ArgumentParser(description="M1 음식 12장 anchor 자동 생성")
    parser.add_argument(
        "--only", type=str, default="",
        help="콤마구분 F-ID만 (예: F-01,F-03). 빈 값=전체 12장."
    )
    parser.add_argument("--model", default="dall-e-3", choices=["dall-e-3", "gpt-image-1"])
    parser.add_argument(
        "--size", default="1024x1024",
        help="dall-e-3: 1024x1024 권장. gpt-image-1: 1024x1024 / 1536x1024 / 1024x1536."
    )
    parser.add_argument(
        "--quality", default="standard",
        help="dall-e-3: standard ($0.04) / hd ($0.08). gpt-image-1: low/medium/high/auto."
    )
    parser.add_argument(
        "--out-dir", type=Path,
        default=PROJECT_ROOT / "assets-raw" / "food_anchors_m1",
        help="출력 디렉터리"
    )
    parser.add_argument(
        "--version", type=str, default="v1",
        help="파일명 suffix (예: v1 → F-01_ramyeon_v1.png)"
    )
    args = parser.parse_args()

    only_set = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    selected = [f for f in FOODS if (only_set is None or f["id"] in only_set)]

    if not selected:
        sys.exit(f"❌ --only 매칭 음식 없음. 유효 ID: {[f['id'] for f in FOODS]}")

    args.out_dir.mkdir(parents=True, exist_ok=True)

    # cost estimate
    if args.model == "dall-e-3":
        unit = 0.080 if args.quality == "hd" else 0.040
    else:
        unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
        unit = unit_map.get(args.quality, 0.042)
    est_total = unit * len(selected)
    print("=" * 70)
    print(f"🍳 M1 음식 anchor 생성 시작")
    print(f"   모델: {args.model} / 품질: {args.quality} / 사이즈: {args.size}")
    print(f"   대상: {len(selected)}장 ({[f['id'] for f in selected]})")
    print(f"   비용 예상: ${unit:.3f}/장 × {len(selected)} = ${est_total:.2f}")
    print(f"   출력: {args.out_dir}")
    print("=" * 70)

    api_key = load_api_key()
    client = OpenAI(api_key=api_key)

    successes: list[str] = []
    failures: list[tuple[str, str]] = []
    t0 = time.time()

    for i, food in enumerate(selected, 1):
        fid = food["id"]
        name = food["name"]
        out_path = args.out_dir / f"{fid}_{name}_{args.version}.png"
        prompt = build_prompt(food["body"])

        print(f"\n[{i}/{len(selected)}] {fid} {name} → {out_path.name}")
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
            successes.append(fid)
        except Exception as exc:
            elapsed = time.time() - t_start
            print(f"   ❌ FAIL ({elapsed:.1f}s): {exc!r}")
            failures.append((fid, repr(exc)))

    total_elapsed = time.time() - t0
    print("\n" + "=" * 70)
    print(f"✅ 완료: {len(successes)}/{len(selected)} 장 — 총 {total_elapsed/60:.1f}분")
    if successes:
        print(f"   성공: {', '.join(successes)}")
    if failures:
        print(f"   실패 {len(failures)}장:")
        for fid, err in failures:
            print(f"     - {fid}: {err}")
    print(f"   비용 예상: ${unit * len(successes):.2f}")
    print(f"   저장 경로: {args.out_dir}")
    print("=" * 70)


if __name__ == "__main__":
    main()
