"""
K-Food Master — M1 sprint 환경 5장 anchor 자동 생성 (BG-01~05, v1.12 v3 minimal patch).

ADR-006 (ChatGPT/DALL-E) 기반. art-director docs/prompts-library.md v1.12
§4 BG-01~05 5장 prompt를 그대로 inline 임베드.

v1.12 v3 minimal patch (2026-05-28): 사용자가 v1.11 v2 (한옥 양식 풀세트 — 옹기/lantern/
목조 한옥 frame/처마 풀) 폐기 + verbatim "기존버젼에서 다른거는 다 그대로 하고 기와 지붕
으로만 바꾸자 천막 없애고" 명시. v1.2 base (commit 7a6cffb) 시각 시그니처를 회복하고
**천막 (red/green striped awning) → 검정 기와 곡선 지붕** 단일 fix만 적용. 다른 모든 요소
(채소/meat/fish/곡식/sauce 카테고리 시그니처 + 작은 가게 카운터 + Cool Sage bg +
icon+영어 minimal signage + modern saturated 톤) **무변경 유지**.

v1.12 v3 패치 핵심 (BG-01~05 5장 모두):
- 단일 fix: 천막 (striped awning) → 검정 기와 곡선 지붕 (curved black ceramic tile roof,
  Korean hanok 기와 eave 곡선, dark slate gray/black, 와당 옵션)
- v2의 한옥 frame 풀세트 (목조 기둥 양쪽 + 처마 깊이 + 옹기 + lantern) **모두 폐기**
- v1.2 LOCK 유지: Cool Sage `#C8D5C0` bg / icon+영어 minimal signage / 카테고리 시그니처
  (BG-01 채소/사과/옹기 좌측 / BG-02 meat hanging/도마 / BG-03 fish/얼음 / BG-04 곡식
  자루 3종 / BG-05 sauce 항아리 4개 + 고추 hanging) / modern saturated / slim outline 2-3px

가게별 카테고리 시그니처 (v1.2 base 그대로 회복):
- BG-01 청과상: 양배추/배추/사과/오이/대파 stack on wooden crates + 옹기 항아리 2개 좌측
  + 양파 hanging 우측, "PRODUCE" signage, cabbage icon, Cabbage Green `#52C160`
- BG-02 정육점: meat slab hanging 2-3개 + 도마 + 가게 카운터, "BUTCHER" signage, meat icon,
  Gochu Red `#F23E3E`
- BG-03 어물전: fish hanging 2개 + 얼음 block + 가게 카운터, "SEAFOOD" signage, fish icon,
  Accent Sea `#2E8AC4`
- BG-04 곡물상: 곡식 자루 3종 + 나무 박스 + 가게 카운터, "GRAIN" signage, grain icon,
  Grain Tan `#D8A86A`
- BG-05 잡화점: sauce 항아리 4개 진열 + 고추 hanging + 가게 카운터, "SAUCES" signage,
  bottle/jar icon, Jang Brown `#7A5238`

Usage:
    py tools/gen_bg_anchors_m1.py --version v3                 # 권장
    py tools/gen_bg_anchors_m1.py --only BG-01 --version v3    # 일부만
    py tools/gen_bg_anchors_m1.py --model gpt-image-1 --quality medium

Default:
    model    = gpt-image-1
    quality  = medium ($0.042/img × 5 = ~$0.21 total)
    size     = 1536x1024 (wide 16:9 landscape)
    out_dir  = assets-raw/bg_anchors_m1/
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
# §2.2 STYLE_SUFFIX_BG_V3 — 모든 환경 prompt 끝에 부착 (v1.12 v3 minimal).
# prompts-library.md v1.12 §2.2 그대로 (placeholder [STYLE_SUFFIX_BG] 헤더 제거).
# v1.2 base 회복 + 천막→기와 지붕 단일 fix. 한옥 frame 풀세트는 포함하지 않음.
# ─────────────────────────────────────────────────────────────────────────────
STYLE_SUFFIX_BG_V3 = """Format: wide 16:9 landscape.
View: slight three-quarter angle (just a touch of perspective for a game environment feel,
NOT strict isometric, NOT a flat front elevation — keep the storefront friendly and approachable).
Style: modern mobile casual game art, clean 2D illustration in Royal Match (Dream Games 2021)
aesthetic applied to a friendly Korean traditional market shop interpreted with modern flat clean tone.

ROOF (single fix from v1.2 base):
- The shop has a CURVED BLACK CERAMIC TILE ROOF above the shop front (Korean traditional hanok
  기와 eave roof) — a short, simple curved tile pattern roof, dark slate gray to black single fill
  (#2D2D33 or similar dark slate), with the signature gently upward-curving eave silhouette at the
  corners (classic Korean hanok 처마 곡선). Optional: 2-3 small white circular eave-end tile caps
  (와당) along the eave tips as subtle accent.
- The roof is a SINGLE simple layer sitting on top of the shop front (NOT a full hanok structure
  with vertical wooden posts on both sides, NOT a deep eave overhang, NOT a full traditional
  architectural frame — just the tile roof itself as the topmost band of the shop front).
- ABSOLUTELY NO striped awning, NO tarp canopy, NO red and green stripes, NO tent canopy,
  NO Italian flag stripes, NO market awning of any kind. The roof completely REPLACES any awning.
- NOT a Chinese pagoda multi-tier sharp upturned corner roof, NOT a Japanese irimoya hip-and-gable.

SHOP FRONT (v1.2 base, unchanged):
- A simple wooden shop counter / small storefront stall with warm brown wood (#A67049 single fill,
  slim grain line accent 1-2 only — NO heavy realistic wood texture). The shop front is small and
  approachable, like a friendly stall in a traditional Korean market.
- A small rectangular wooden signboard sits at the top of the shop front (below the tile roof,
  or integrated into the counter top). ICON-FIRST signage: a LARGE simple flat shop-category icon
  (~60-70% of signboard area, single color, flat geometric shape) + below the icon, a SHORT English
  minimal text label (1-2 words, ~20-25% area, simple sans-serif, all-caps, legible). Absolutely
  NO Korean text (한글), NO Chinese characters (한자), NO Japanese characters (kana/kanji),
  NO sub-text in any non-English language.

CATEGORY SIGNATURE (per shop, see body prompt for shop-specific detail):
- Each of the 5 shops keeps its v1.2 base category signature (1-2 large simple icons, signature
  color: Cabbage Green / Gochu Red / Sea Blue / Grain Tan / Jang Brown). Displayed at the counter
  or front display area, clearly identifying the shop category.

SHOP FRAMING:
- The shop is empty (NO people in foreground, NO customers, NO shop owner — game environment ready
  for character layer compositing in Godot).
- Composition: tile roof fills the upper ~20-25% of the image as a slim band, shop front + counter
  + category display fills the middle 50-60%, ground level baseline visible at the bottom edge.

LIGHTING + SHADING:
- Single ambient light from upper-left (modern flat interpretation, NOT directional realistic lighting).
- Single subtle ambient ellipse shadow under the shop base (#000 ~25% alpha).
- Optional soft 1-layer cel shading on the wooden counter + signboard (base color × 0.85 multiply,
  small area only — keep modern flat clean tone dominant).

BACKGROUND:
- Solid Cool Sage #C8D5C0 background (consistent across all 5 shops, for cross-shop one-market
  identity).
- NO beige background (#FAEFD8, #FFF1D6 warm-cream tones FAIL), NO cream paper, NO scrapbook,
  NO vintage texture, NO golden hour sunset warm lighting, NO atmospheric haze.

COLOR + OUTLINE:
- Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), single color fill with optional
  soft 1-layer cel shading.
- Vibrant saturated colors at 80-90 percent saturation, warm/cool palette balance.
- The black tile roof (dark) + warm brown counter (warm) + Cool Sage bg (cool) + per-shop signature
  color creates the warm/cool balance.

Important: avoid beige background, cream paper background, scrapbook, storybook, kraft paper,
vintage texture, golden hour, sunset warm lighting, atmospheric haze,
Cookie Run, Cookie Run Kingdom frosting style, Toca Boca, Toon Blast over-cartoony,
realistic or photorealistic rendering, 3D render, octane or unreal engine, heavy wood grain texture,
heavy clay tile texture, any texture, noise, grain, painterly or hand-painted feel, watercolor,
gradient mesh, multi-layer complex shading, hyperdetailed elements, cinematic, gritty,
striped awning, red and green stripes, red-green-white stripes, Italian flag awning, tarp canopy,
tent canopy, market awning, fabric canopy of any kind,
full hanok architectural frame with vertical wooden posts on both sides,
deep eave overhang creating heavy shadow band, traditional Korean lantern hanging from the eave,
extra onggi pottery jars added beyond what the v1.2 base shop already has,
Chinese pagoda multi-tier sharp upturned corner roof, Japanese irimoya hip-and-gable roof,
Chinese architecture (qipao, blue-and-white porcelain, red Chinese paper lantern, chinatown gate),
Japanese architecture (kanji signage, noren curtain, Tokyo, Tsukiji, kimono, sushi, Fuji,
Japanese paper lantern with kanji),
any Korean text (한글) legibly readable, any Chinese characters (한자) on signboard,
any Japanese characters (kana, kanji) on signboard,
sub-text under the English label in any non-English language,
traditional Korean mortar, mortar and pestle,
anime girl, manga, cluttered composition, people, customers, shop owner,
flat front elevation view (use slight three-quarter angle instead), photographic depth of field,
modern Western storefront (American shopfront with metal frame, European boutique with wrought iron)."""


# ─────────────────────────────────────────────────────────────────────────────
# §4 환경 5 anchor prompt (BG-01~BG-05) — prompts-library.md v1.12 v3 그대로 inline.
# 각 항목: id / filename / body. STYLE_SUFFIX_BG_V3는 자동 append (%s).
#
# v1.12 v3 minimal patch (2026-05-28): v1.2 base 회복 + 천막→기와 지붕 단일 fix.
# 다른 모든 요소 (채소/meat/fish/곡식/sauce 카테고리 시그니처 + 가게 카운터 + 옹기
# BG-01에만 좌측 2개 + Cool Sage bg + icon+영어 minimal signage) v1.2 그대로 유지.
# v2의 한옥 frame 풀세트 + 옹기 prominent 5가게 + lantern 5가게 + 깊은 처마 폐기.
# ─────────────────────────────────────────────────────────────────────────────
BGS = [
    {
        "id": "BG-01",
        "name": "greengrocer",
        "body": """A modern mobile casual game illustration of a small Korean traditional market vegetable shop
storefront (Korean greengrocer / 청과상), slight three-quarter view. The shop is a small friendly
stall with a simple wooden counter at the front.

Above the shop front, a CURVED BLACK CERAMIC TILE ROOF (Korean traditional hanok 기와 eave roof,
dark slate gray to black single fill, gently upward-curving eave silhouette at the corners with
2-3 small white circular eave-end tile caps 와당 along the tips) sits as a slim topmost band.
The roof is a SINGLE simple layer — NOT a full hanok structure with side posts, NOT a deep eave
overhang. ABSOLUTELY NO striped awning, NO red and green stripes, NO tarp canopy, NO tent canopy.

Just below the tile roof, a small rectangular wooden signboard (warm brown #A67049) is mounted
at the top of the shop front. The signboard shows a LARGE simple flat icon of a round green
cabbage (cabbage green vivid #52C160 single fill, ~60-70% of signboard area) + a SHORT English
minimal text label "PRODUCE" below the icon (simple sans-serif, all-caps, ~20-25% area, legible).

At the shop front display area: a stack of fresh vegetables and fruits arranged on simple wooden
display crates / open boxes (warm brown #A67049 single fill, slim grain line accent 1-2 only).
The vegetable stack includes: a round green cabbage (vivid cabbage green #52C160) as the hero,
a stack of napa cabbage leaves (배추, lighter green), a few red apples (#F23E3E), 1-2 cucumbers
(deeper green), and a small bundle of green onions / scallions (대파, bright green tops). The
signature category color is cabbage green (dominant), with red apple as warm accent.

On the LEFT side of the shop, 2 large brown traditional Korean onggi pottery jars (dark warm
brown #7A5238 single fill with bold outline, rounded earthen shape with narrow neck + wide round
body, classic Korean fermentation pot silhouette) stand on the ground — these are 장아찌 (pickled
vegetable) jars fitting the greengrocer context (v1.2 base signature retained).

On the RIGHT side, a small bundle of onions or garlic hangs from a simple hook (just a small
accent prop, optional).

A small price tag appears as a solid block placeholder (NO readable text). The shop is empty,
waiting for a customer (NO people, NO shop owner, NO customers, NO market lanterns hanging from
the roof).

Background is solid Cool Sage #C8D5C0 (cool tone solid bg, modern flat clean).

Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), single color fill with optional
soft 1-layer cel shading on the wooden counter + signboard. Vibrant saturated colors at 80-90
percent saturation, warm/cool palette balance (warm brown wood + warm category accent balanced by
cool sage bg + dark black tile roof).

%s

Important also: the only NEW element added from v1.2 base is the CURVED BLACK CERAMIC TILE ROOF
replacing the striped awning. All other v1.2 base elements (vegetable stack signature, wooden
crates, 2 onggi jars on left, onion/garlic hanging right, PRODUCE signage, Cool Sage bg) are
RETAINED EXACTLY as in v1.2. Do NOT add extra elements: NO hanging lanterns, NO full hanok side
posts, NO additional onggi beyond the existing 2 on the left side, NO deep eave overhang shadow
band, NO extra traditional Korean props. Just the v1.2 base + tile roof swap. The signboard text
is English only ("PRODUCE"), absolutely NO Korean text (한글), NO Chinese characters (한자),
NO Japanese kana/kanji. Background MUST be solid Cool Sage #C8D5C0, NO beige, NO cream,
NO scrapbook, NO vintage paper texture, NO golden hour.""",
    },
    {
        "id": "BG-02",
        "name": "butcher",
        "body": """A modern mobile casual game illustration of a small Korean traditional market butcher shop
storefront (Korean 정육점), slight three-quarter view. The shop is a small friendly stall with a
simple wooden counter at the front.

Above the shop front, a CURVED BLACK CERAMIC TILE ROOF (Korean traditional hanok 기와 eave roof,
dark slate gray to black single fill, gently upward-curving eave silhouette at the corners with
2-3 small white circular eave-end tile caps 와당 along the tips) sits as a slim topmost band.
The roof is a SINGLE simple layer — NOT a full hanok structure with side posts, NOT a deep eave
overhang. ABSOLUTELY NO striped awning, NO red and green stripes, NO tarp canopy, NO tent canopy.

Just below the tile roof, a small rectangular wooden signboard (warm brown #A67049) is mounted
at the top of the shop front. The signboard shows a LARGE simple flat icon of a meat slab
silhouette (gochu red vivid #F23E3E single fill, flat geometric shape, ~60-70% of signboard area)
+ a SHORT English minimal text label "BUTCHER" below the icon (simple sans-serif, all-caps,
~20-25% area, legible).

At the shop front: 2-3 simple meat slab silhouettes hang from a horizontal hook bar mounted at
the top of the shop opening (modern flat meat slab silhouette, gochu red #F23E3E single fill with
bold outline, family-friendly stylized — clearly identifiable as meat but NO blood, NO carcass,
NO raw meat closeup, NO gore). Below on the wooden shop counter, a modern clean wooden cutting
board sits (warm brown #A67049 single fill, slim grain line accent 1-2 only, slightly worn corner)
with a simple flat butcher's knife resting on it. The signature category color is gochu red.

A small price tag appears as a solid block placeholder (NO readable text). The shop is empty
(NO people, NO shop owner, NO customers, NO market lanterns hanging from the roof, NO onggi
pottery jars added).

Background is solid Cool Sage #C8D5C0 (cool tone solid bg, modern flat clean).

Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), single color fill with optional
soft 1-layer cel shading on the wooden counter + signboard. Vibrant saturated colors at 80-90
percent saturation (gochu red 80-90% saturated, NOT neon 100%), warm/cool palette balance.

%s

Important also: the only NEW element added from v1.2 base is the CURVED BLACK CERAMIC TILE ROOF
replacing the striped awning. All other v1.2 base elements (meat slab hanging signature, cutting
board on counter, BUTCHER signage, small shop counter, Cool Sage bg) are RETAINED EXACTLY as in
v1.2. Do NOT add extra elements: NO hanging lanterns, NO full hanok side posts, NO onggi pottery
jars (v1.2 butcher had none), NO deep eave overhang shadow band, NO extra traditional Korean
props. Just the v1.2 base + tile roof swap. This is a Korean 정육점 (butcher shop) interpreted
as a clean family-friendly modern mobile game art — NO blood, NO carcass, NO raw meat closeup,
NO gore, NO realistic butchering scene. The signboard text is English only ("BUTCHER"),
absolutely NO Korean text (한글), NO Chinese characters (한자), NO Japanese kana/kanji.
Background MUST be solid Cool Sage #C8D5C0, NO beige, NO cream, NO scrapbook, NO vintage texture.""",
    },
    {
        "id": "BG-03",
        "name": "fishmonger",
        "body": """A modern mobile casual game illustration of a small Korean traditional market seafood shop
storefront (Korean 어물전), slight three-quarter view. The shop is a small friendly stall with a
simple wooden counter at the front.

Above the shop front, a CURVED BLACK CERAMIC TILE ROOF (Korean traditional hanok 기와 eave roof,
dark slate gray to black single fill, gently upward-curving eave silhouette at the corners with
2-3 small white circular eave-end tile caps 와당 along the tips) sits as a slim topmost band.
The roof is a SINGLE simple layer — NOT a full hanok structure with side posts, NOT a deep eave
overhang. ABSOLUTELY NO striped awning, NO red and green stripes, NO tarp canopy, NO tent canopy.

Just below the tile roof, a small rectangular wooden signboard (warm brown #A67049) is mounted
at the top of the shop front. The signboard shows a LARGE simple flat icon of a stylized cute
fish silhouette (accent sea blue #2E8AC4 single fill, friendly geometric shape, ~60-70% of
signboard area) + a SHORT English minimal text label "SEAFOOD" below the icon (simple sans-serif,
all-caps, ~20-25% area, legible).

At the shop front: 2 simple stylized fish silhouettes hang from a horizontal hook bar at the top
of the shop opening (Korean traditional 어물전 style — fish hanging from hooks, modern flat
interpretation, NOT realistic dead-eye fish, NOT bloody — simplified cute geometric fish shape,
accent sea blue #2E8AC4 single fill with bold outline). Below on the wooden shop counter, a white
ice block (clean flat white #FAFAFA single fill with slight cool sage cel shading, simple
geometric block shape suggesting crushed ice display) sits with optional 1-2 smaller fish or
shells resting on top of the ice. The signature category color is accent sea blue + white ice
(cool tone dominant, balancing the warm wood counter).

A small price tag appears as a solid block placeholder (NO readable text). The shop is empty
(NO people, NO shop owner, NO customers, NO market lanterns hanging from the roof, NO onggi
pottery jars added).

Background is solid Cool Sage #C8D5C0 (cool tone solid bg, modern flat clean).

Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), single color fill with optional
soft 1-layer cel shading. Vibrant saturated colors at 80-90 percent saturation, warm/cool palette
balance (warm wood counter balanced by cool sage bg + cool sea blue category accent + white ice).

%s

Important also: the only NEW element added from v1.2 base is the CURVED BLACK CERAMIC TILE ROOF
replacing the striped awning. All other v1.2 base elements (fish hanging signature, ice block
display, SEAFOOD signage, small shop counter, Cool Sage bg) are RETAINED EXACTLY as in v1.2.
Do NOT add extra elements: NO hanging lanterns, NO full hanok side posts, NO onggi pottery jars
(v1.2 fishmonger had none), NO deep eave overhang shadow band, NO extra traditional Korean props.
Just the v1.2 base + tile roof swap. This is a Korean 어물전 (seafood market shop), NOT Japanese
sushi shop, NOT Tsukiji fish market, NOT Chinese seafood restaurant. The fish silhouettes are
friendly modern mobile casual game style (simplified cute geometric shape), NOT realistic
dead-eye fish, NOT bloody fish, NOT raw sashimi. The signboard text is English only ("SEAFOOD"),
absolutely NO Korean text (한글), NO Chinese characters (한자), NO Japanese kana/kanji.
Background MUST be solid Cool Sage #C8D5C0, NO beige, NO cream, NO scrapbook, NO vintage texture.""",
    },
    {
        "id": "BG-04",
        "name": "grain_shop",
        "body": """A modern mobile casual game illustration of a small Korean traditional market grain shop
storefront (Korean 곡물상), slight three-quarter view. The shop is a small friendly stall with a
simple wooden counter at the front.

Above the shop front, a CURVED BLACK CERAMIC TILE ROOF (Korean traditional hanok 기와 eave roof,
dark slate gray to black single fill, gently upward-curving eave silhouette at the corners with
2-3 small white circular eave-end tile caps 와당 along the tips) sits as a slim topmost band.
The roof is a SINGLE simple layer — NOT a full hanok structure with side posts, NOT a deep eave
overhang. ABSOLUTELY NO striped awning, NO red and green stripes, NO tarp canopy, NO tent canopy.

Just below the tile roof, a small rectangular wooden signboard (warm brown #A67049) is mounted
at the top of the shop front. The signboard shows a LARGE simple flat icon of a grain sack
silhouette (grain tan #D8A86A single fill, trapezoid shape, ~60-70% of signboard area) + a SHORT
English minimal text label "GRAIN" below the icon (simple sans-serif, all-caps, ~20-25% area,
legible).

At the shop front: 3 simple burlap-style grain sacks arranged on the wooden shop counter and in
a simple wooden display box at the front (trapezoid silhouette shapes, modern flat clean — NO
burlap weave texture, NO heavy detail). Vary the tones: one grain tan #D8A86A sack (rice / 쌀),
one warm brown #A67049 sack (mixed grain / 곡물), and a small accent red bean sack (#A8413A,
red bean / 팥). Optional: a wooden scoop or measure resting on top of one sack. The signature
category color is grain tan with warm brown + red bean accent for tonal variety.

A small price tag appears as a solid block placeholder (NO readable text). The shop is empty
(NO people, NO shop owner, NO customers, NO market lanterns hanging from the roof, NO onggi
pottery jars added).

Background is solid Cool Sage #C8D5C0 (cool tone solid bg, modern flat clean).

Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), single color fill with optional
soft 1-layer cel shading. Vibrant saturated colors at 80-90 percent saturation, warm/cool palette
balance (warm wood counter + warm grain tan balanced by cool sage bg + dark black tile roof).

%s

Important also: the only NEW element added from v1.2 base is the CURVED BLACK CERAMIC TILE ROOF
replacing the striped awning. All other v1.2 base elements (grain sacks signature in 3 tones,
wooden display box, GRAIN signage, small shop counter, Cool Sage bg) are RETAINED EXACTLY as in
v1.2. Do NOT add extra elements: NO hanging lanterns, NO full hanok side posts, NO onggi pottery
jars (v1.2 grain shop had none — do not add multiple onggi jars), NO deep eave overhang shadow
band, NO extra traditional Korean props. Just the v1.2 base + tile roof swap. Vary the grain
sack tones with tan, warm brown and a small red bean sack accent to avoid an all-tan flat look.
Burlap sacks are simple geometric trapezoid shapes with minimal detail (NO burlap weave texture,
NO vintage scrapbook). The signboard text is English only ("GRAIN"), absolutely NO Korean text
(한글), NO Chinese characters (한자), NO Japanese kana/kanji. Background MUST be solid Cool
Sage #C8D5C0, NO beige, NO cream, NO scrapbook, NO vintage paper texture, NO golden hour.""",
    },
    {
        "id": "BG-05",
        "name": "sauces",
        "body": """A modern mobile casual game illustration of a small Korean traditional market sauce / seasoning
shop storefront (Korean 잡화점 / 양념가게 — selling Korean fermented sauces and seasonings),
slight three-quarter view. The shop is a small friendly stall with a simple wooden counter at the
front.

Above the shop front, a CURVED BLACK CERAMIC TILE ROOF (Korean traditional hanok 기와 eave roof,
dark slate gray to black single fill, gently upward-curving eave silhouette at the corners with
2-3 small white circular eave-end tile caps 와당 along the tips) sits as a slim topmost band.
The roof is a SINGLE simple layer — NOT a full hanok structure with side posts, NOT a deep eave
overhang. ABSOLUTELY NO striped awning, NO red and green stripes, NO tarp canopy, NO tent canopy.

Just below the tile roof, a small rectangular wooden signboard (warm brown #A67049) is mounted
at the top of the shop front. The signboard shows a LARGE simple flat icon of an amber/brown
sauce jar or bottle silhouette (jang brown #7A5238 single fill, ~60-70% of signboard area) + a
SHORT English minimal text label "SAUCES" below the icon (simple sans-serif, all-caps, ~20-25%
area, legible).

At the shop front: 4 Korean sauce jars / pots displayed in a clean row on the wooden shop counter
or a small wooden display shelf (modern flat geometric jar/pot silhouettes, varying sizes,
representing 간장 soy sauce / 된장 fermented soybean paste / 고추장 red chili paste / 참기름
sesame oil). Color the jars with jang brown #7A5238 dominant + 1 accent gochu red #F23E3E pot
(고추장) + 1 amber/golden #C8923C pot (sesame oil) for tonal variety. Each jar has a bold outline
and a small lid silhouette on top.

On the right or above the counter, a small bundle of dried red chili peppers (고추) hangs as a
simple silhouette accent (gochu red #F23E3E, modern flat shape, slim string holding them
together — v1.2 base signature).

A small price tag appears as a solid block placeholder (NO readable text). The shop is empty
(NO people, NO shop owner, NO customers, NO market lanterns hanging from the roof).

Background is solid Cool Sage #C8D5C0 (cool tone solid bg, modern flat clean).

Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), single color fill with optional
soft 1-layer cel shading on the wooden counter + signboard + jars. Vibrant saturated colors at
80-90 percent saturation, warm/cool palette balance (warm wood counter + warm amber jars + warm
red chili balanced by cool sage bg + dark black tile roof). The jang brown signature category
color dominates with red accent.

%s

Important also: the only NEW element added from v1.2 base is the CURVED BLACK CERAMIC TILE ROOF
replacing the striped awning. All other v1.2 base elements (4 sauce jars row signature, dried
chili pepper bundle hanging accent, SAUCES signage, small shop counter, Cool Sage bg) are
RETAINED EXACTLY as in v1.2. Do NOT add extra elements: NO hanging lanterns, NO full hanok side
posts, NO additional huge onggi pottery jars on the ground beyond what v1.2 already had (v1.2
base sauces shop signature was the 4 small jars on the counter, NOT giant prominent ground onggi),
NO deep eave overhang shadow band, NO wooden stool prop, NO extra traditional Korean décor.
Just the v1.2 base + tile roof swap. The sauce jars are simple modern flat silhouettes, NOT
realistic glass bottle photography. The signboard text is English only ("SAUCES"), absolutely
NO Korean text (한글), NO Chinese characters (한자), NO Japanese kana/kanji. NO mortar and pestle
(절구) anywhere — this is LOCK from art-style-guide §5. Background MUST be solid Cool Sage
#C8D5C0 (cool tone), absolutely NO beige sky, NO cream warm sky, NO scrapbook, NO vintage paper
texture, NO storybook tone, NO golden hour sunset warm lighting.""",
    },
]


def build_prompt(body: str) -> str:
    """body의 첫 %s를 STYLE_SUFFIX_BG_V3로 교체. body의 다른 % (예: '60-70%')는 보존."""
    return body.replace("%s", STYLE_SUFFIX_BG_V3, 1)


def main() -> None:
    parser = argparse.ArgumentParser(description="M1 환경 5장 anchor 자동 생성 (BG-01~05, v1.12 v3 minimal: v1.2 base + 천막→기와 지붕 단일 fix)")
    parser.add_argument(
        "--only", type=str, default="",
        help="콤마구분 BG-ID만 (예: BG-01,BG-05). 빈 값=전체 5장."
    )
    parser.add_argument("--model", default="gpt-image-1", choices=["dall-e-3", "gpt-image-1"])
    parser.add_argument(
        "--size", default="1536x1024",
        help="wide 16:9 landscape 권장. gpt-image-1: 1536x1024 / 1024x1024 / 1024x1536. dall-e-3: 1792x1024."
    )
    parser.add_argument(
        "--quality", default="medium",
        help="dall-e-3: standard ($0.04) / hd ($0.08). gpt-image-1: low/medium/high/auto."
    )
    parser.add_argument(
        "--out-dir", type=Path,
        default=PROJECT_ROOT / "assets-raw" / "bg_anchors_m1",
        help="출력 디렉터리"
    )
    parser.add_argument(
        "--version", type=str, default="v3",
        help="파일명 suffix (기본 v3 → BG-01_greengrocer_v3.png)"
    )
    args = parser.parse_args()

    only_set = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    selected = [b for b in BGS if (only_set is None or b["id"] in only_set)]

    if not selected:
        sys.exit(f"❌ --only 매칭 환경 없음. 유효 ID: {[b['id'] for b in BGS]}")

    args.out_dir.mkdir(parents=True, exist_ok=True)

    # cost estimate
    if args.model == "dall-e-3":
        unit = 0.080 if args.quality == "hd" else 0.040
    else:
        unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
        unit = unit_map.get(args.quality, 0.042)
    est_total = unit * len(selected)
    print("=" * 70)
    print(f"🏯 M1 환경 anchor 생성 시작 (v1.12 v3 minimal: v1.2 base + 기와 지붕)")
    print(f"   모델: {args.model} / 품질: {args.quality} / 사이즈: {args.size}")
    print(f"   대상: {len(selected)}장 ({[b['id'] for b in selected]})")
    print(f"   비용 예상: ${unit:.3f}/장 × {len(selected)} = ${est_total:.2f}")
    print(f"   출력: {args.out_dir}")
    print("=" * 70)

    api_key = load_api_key()
    client = OpenAI(api_key=api_key)

    successes: list[str] = []
    failures: list[tuple[str, str]] = []
    t0 = time.time()

    for i, bg in enumerate(selected, 1):
        bid = bg["id"]
        name = bg["name"]
        out_path = args.out_dir / f"{bid}_{name}_{args.version}.png"
        prompt = build_prompt(bg["body"])

        print(f"\n[{i}/{len(selected)}] {bid} {name} → {out_path.name}")
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
            successes.append(bid)
        except Exception as exc:
            elapsed = time.time() - t_start
            print(f"   ❌ FAIL ({elapsed:.1f}s): {exc!r}")
            failures.append((bid, repr(exc)))

    total_elapsed = time.time() - t0
    print("\n" + "=" * 70)
    print(f"✅ 완료: {len(successes)}/{len(selected)} 장 — 총 {total_elapsed/60:.1f}분")
    if successes:
        print(f"   성공: {', '.join(successes)}")
    if failures:
        print(f"   실패 {len(failures)}장:")
        for bid, err in failures:
            print(f"     - {bid}: {err}")
    print(f"   비용 예상: ${unit * len(successes):.2f}")
    print(f"   저장 경로: {args.out_dir}")
    print("=" * 70)


if __name__ == "__main__":
    main()
