"""
K-Food Master — M1 후반 sprint 음식 12 × hero ingredient whole anchor 12장 자동 생성.

⚠️ DEPRECATED — ASSET ARCHITECTURE LOCK 위반 (docs/art/asset-architecture-lock.md §3.1, §6).
    이 드라이버는 whole 재료(L-ING) 를 도마(L-TOOL) + 칼(L-TOOL) 위에 BAKED 한다
    (= 사용자 NEVER-merge mandate 의 "Bad: cutting_board + carrot PNG" 정확한 위반).
    production 사용 금지. 대체: tools/gen_ingredient_tool_hero.py 의 *_raw variant (standalone,
    도마/칼 없는 재료 단독 hero) → Godot 가 cutting_board/knife L-TOOL 과 runtime 합성.
    (코드 삭제는 main thread 영역 — 본 배너는 위반 표시 및 전환 경로 안내.)

ADR-005 (4-stage rhythm tap) Stage 2A prerequisite — 재료 준비 = rhythm tap + Knife indicator.
각 음식의 hero ingredient (자르기 전 whole state)를 도마 위에 placement.

`tools/gen_cut_anchors_m1.py` template 기반 (STYLE_SUFFIX_CUT 동일 도마/칼 silhouette
+ Cool Sage `#C8D5C0` bg + slim outline 2-3px + top-down). cut된 결과(CUT-01~06)는
재사용 — 본 스크립트는 **whole ingredient 12장만** 생성.

art-director docs/prompts-library.md v1.17 §5.6 STYLE_SUFFIX_INGREDIENT (STYLE_SUFFIX_CUT
재활용 + ingredient body 12종) prompt를 그대로 inline 임베드.

v1.17 sync (2026-05-30, mvp-food-selection v2.2 trigger — game-designer 2026-05-28 완료):
- ING-02 흑설탕 → 소면 (somen white wheat noodles bundled whole). F-02 잔치국수 hero.
  cut 없음 (noodle prep mechanic = sprinkle/serve into boiling broth).
- ING-09 두부 firm → 얇은 소고기 (raw thin-sliced marbled beef stack/fan). F-09 불고기 hero.
  cut 없음 (already pre-sliced at butcher; prep mechanic = 양념재우기 marinade application).
- F-12 갈비 차별화 CRITICAL (ING-09): NO bone visible, RAW (NOT cooked grilled).
- 흑설탕 (R2 deprecated) / 두부 firm (R1 deprecated) 본문은 archive.

음식 12 × hero ingredient × cut style 매핑 (v1.17 mvp v2.2 sync):
  F-01 라면         → 대파 (spring onion)          | CUT-05 송송썰기
  F-02 잔치국수     → 소면 (somen white wheat)     | (no cut, sprinkle/serve)        ← v1.17
  F-03 김밥         → 단무지 (pickled radish)      | CUT-02 채썰기
  F-04 떡볶이       → 어묵 (fish cake)             | CUT-03 어슷썰기
  F-05 김치볶음밥   → 김치 (napa cabbage kimchi)   | CUT-01 다지기
  F-06 콘도그       → 모짜렐라 (cheese stick)      | (no cut, whole)
  F-07 해물파전     → 대파 daepa (large scallion)  | CUT-03 어슷썰기
  F-08 비빔밥       → 당근 (carrot)                | CUT-02 채썰기
  F-09 불고기       → 얇은 소고기 (thin marbled)   | (no cut, marinade prep state)   ← v1.17
  F-10 순두부찌개   → 두부 soft (soft tofu)        | (no cut, broken curds)
  F-11 잡채         → 당근 (carrot)                | CUT-02 채썰기 (F-08 재사용)
  F-12 갈비구이     → 마늘 (garlic cloves)         | CUT-01 다지기

→ 12장 전부 whole 상태 (자르기 전 또는 prep 전), cut된 상태는 CUT-01~06 anchor 재사용.
→ F-02 소면 / F-06 cheese / F-09 얇은 소고기 / F-10 soft tofu는 cut 없는 형태.

Usage:
    py tools/gen_ingredient_anchors_m1.py
    py tools/gen_ingredient_anchors_m1.py --only F-01                       # 1장만
    py tools/gen_ingredient_anchors_m1.py --only F-01,F-02                  # 일부
    py tools/gen_ingredient_anchors_m1.py --model gpt-image-1 --quality medium
    py tools/gen_ingredient_anchors_m1.py --version v2                       # 파일명 suffix

Default:
    model    = gpt-image-1 (medium quality)
    quality  = medium ($0.042/img × 12 = ~$0.50 total)
    size     = 1024x1024 (square 1:1)
    out_dir  = assets-raw/ingredient_anchors_m1/
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
# STYLE_SUFFIX_INGREDIENT — 모든 ingredient whole anchor prompt 끝에 부착
# prompts-library.md v1.15 §5.6 STYLE_SUFFIX_INGREDIENT (= STYLE_SUFFIX_CUT 재활용).
# 도마/칼/bg/outline/top-down 정확 통일.
# ─────────────────────────────────────────────────────────────────────────────
STYLE_SUFFIX_INGREDIENT = """Format: square 1:1.
View: top-down (overhead view, looking straight down at the cutting board surface).
Style: modern mobile casual game asset, clean 2D illustration in Royal Match (Dream Games 2021)
aesthetic. Hero shot of a Korean kitchen cutting board with the WHOLE (uncut) hero ingredient
placed on it, ready to be cut. Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black),
single color fill with optional soft 1-layer cel shading and ONE small specular highlight per
element (juicy/freshness appetite). Vibrant saturated colors at 80-90 percent saturation, warm
food + cool background balance.

CUTTING BOARD (consistent with CUT-00 ~ CUT-06 cut anchors):
- A Korean kitchen wooden cutting board (도마) in warm brown wood color (#A67049 single fill,
  slim grain line accent 1-2 only, NOT heavy realistic wood texture), rectangular shape with
  rounded corners (approximately 16:9 horizontal proportion, filling most of the image).
- The board has a slight darker rim outline (warm dark #2D1D14, 2-3px), clean modern flat
  appearance — identical to the CUT-00 cutting_board base anchor silhouette.

KNIFE (consistent silhouette with CUT-00 ~ CUT-06):
- A modern Korean kitchen knife (식칼) — warm brown wood handle (#A67049 matching the board) +
  silver-gray steel blade (#C8C8C8 single fill with subtle slim cel shading), slim simple
  geometric shape, slightly elongated rectangular blade with a subtle pointed tip.
- The knife rests on the LEFT side of the cutting board, blade flat against the board surface,
  handle pointing toward the lower-left corner (a relaxed static placement, NOT raised
  mid-swing, NOT chopping in motion — the cooking has NOT started yet, this is the whole
  ingredient ready-to-cut state).

INGREDIENT PLACEMENT:
- The whole (uncut) hero ingredient sits on the CENTER-RIGHT portion of the cutting board
  (to balance the knife on the left side).
- This is the WHOLE / UNCUT state (the ingredient before any cutting has been done — the visual
  "before" pair of the corresponding CUT-XX anchor's "after" state). NO cut pieces, NO chopped
  bits, NO sliced rounds, NO julienne strips, NO cube dice scattered around the whole ingredient.

BACKGROUND:
- Solid Cool Sage #C8D5C0 background (consistent across all 12 ingredient anchors + 7 cut
  anchors + 12 food anchors + 5 environment anchors for cross-asset one-game-world identity).
- Single subtle ambient ellipse shadow directly under the cutting board (#000 ~25% alpha).

Important: avoid beige background, cream paper background, scrapbook, storybook, kraft paper,
vintage texture, golden hour, sunset warm lighting,
Cookie Run, Cookie Run Kingdom frosting style, Toca Boca, Toon Blast over-cartoony,
realistic or photorealistic rendering, 3D render, octane or unreal engine, food photography,
heavy wood grain texture, heavy steel reflection, any texture, noise, grain,
painterly or hand-painted feel, watercolor, gradient mesh, multi-layer complex shading,
hyperdetailed elements, cinematic, gritty, blood, gore,
Japanese kitchen knife (santoku/deba/yanagiba with distinct single-bevel asymmetric blade,
black resin or octagonal magnolia wood handle, kanji engraving on blade),
Chinese cleaver (rectangular tall blade much wider than Korean knife),
Western chef knife (large triangular blade with bolster, German/French style),
mortar and pestle (절구), traditional Korean stone tools (replaced by knife + cutting board as
the direct gameplay mechanic mapping for ADR-005 Stage 2A rhythm tap),
ANY CUT PIECES scattered on the board (this is the WHOLE/UNCUT ready-to-cut state — cut
results belong to CUT-01~06 anchors, NOT this ingredient whole anchor),
human characters, hands holding the knife, cooking action mid-motion, kitchen environment
background, multiple cutting boards, multiple knives, any English or Korean text legibly
readable on the board."""


# ─────────────────────────────────────────────────────────────────────────────
# INGREDIENTS — 12개 항목 (음식 12 × hero ingredient whole)
# prompts-library.md v1.15 §5.6.1 ~ §5.6.12 본문 inline.
# 각 항목: id (food_id) / name / food_name_en / cut_style_id / body.
# STYLE_SUFFIX_INGREDIENT는 자동 append.
# ─────────────────────────────────────────────────────────────────────────────
INGREDIENTS = [
    {
        "id": "F-01",
        "name": "spring_onion_whole",
        "food": "Ramyeon",
        "cut_style": "CUT-05 송송썰기",
        # §5.6.1 라면 hero = 대파 (spring onion) — CUT-05 송송썰기와 페어
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with a WHOLE SPRING ONION (대파, uncut Korean scallion stalk) placed on top, top-down view,
ready-to-cut state (NO cut pieces, NO sliced rounds — this is the whole ingredient BEFORE any
cutting, the visual "before" pair of the CUT-05 송송썰기 sliced-rounds anchor). The hero
ingredient mapping = 대파 (Korean spring onion, used in F-01 ramyeon as the signature garnish
when 송송 sliced into thin rounds).

On the cutting board (center-right placement): a SINGLE WHOLE GREEN SPRING ONION stalk lying
flat horizontally — approximately 18-22cm long × 1-1.5cm thick at the white root end,
tapering to a thinner bright green leaf end. The stalk is cylindrical and intact:
- WHITE-PALE root end on one side (~6-8cm length, off-white #F5F5E8 single fill), with 2-3
  thin wispy white root strands at the very tip.
- A clear transition zone from white to pale yellow-green in the middle (~3-4cm).
- BRIGHT GREEN leaf end on the other side (~8-10cm length, bright vivid green #52C160 single
  fill, the elongated tubular green leaves slightly fanning out at the very tip).
The whole stalk has a subtle slim cel shading on the underside (lower contour darker by ~15%)
to suggest the cylindrical 3D volume in top-down view. ONE small specular highlight along the
top length to suggest the fresh waxy surface.

%s

Important also: this is the WHOLE SPRING ONION (대파) ready-to-cut state — the stalk MUST be
INTACT (uncut, NO sliced rounds, NO chopped bits, NO julienne strips, NO mince granules on the
board). The hero ingredient is a SINGLE long cylindrical scallion with white root end + bright
green leaf end. This pairs with the CUT-05 송송썰기 (sliced thin rounds) cut anchor as the
"before" state. NOT a thin Japanese negi (the spring onion type is fine, just the placement +
Korean cutting board context). NOT garlic chives (부추, those are thin flat leaves NOT a thick
cylindrical stalk). NOT a leek (leeks are much thicker with overlapping flat layers). The
single intact cylindrical stalk on the board is the hero — knife on the left, no cut pieces.""",
    },
    {
        "id": "F-02",
        "name": "zucchini_whole",
        "food": "Janchi-guksu",
        "cut_style": "CUT-04 통썰기",
        # §5.6.2 v1.18 사용자 mapping fix (2026-05-30): 소면 hero는 칼 mechanic 불일치 (면 자르기 ADR-005
        # Stage 2A rhythm tap 부적합). 잔치국수 시그니처 garnish 중 cut style fit = 애호박 통썰기.
        # CUT-04 통썰기 매핑 이전 0건 → 활성화. 페어 = 통썰기 (whole disc) cut anchor.
        # 진화 timeline: peanut (R1 deprecated) → 흑설탕 (R2 deprecated) → 소면 (v1.17 deprecated)
        # → 애호박 (v1.18 user fix). 모든 prior body는 archive.
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with a WHOLE ZUCCHINI (애호박, Korean zucchini squash — the signature garnish vegetable of
F-02 Janchi-guksu celebration noodle soup, paired with CUT-04 통썰기 round disc cut style)
placed on top, top-down view, ready-to-cut state (NO sliced discs, NO cut rounds — this is the
whole uncut zucchini BEFORE any cutting, the visual "before" pair of the CUT-04 통썰기 whole-slice
anchor). The hero ingredient mapping = 애호박 / Korean zucchini (the essential prep ingredient
that is sliced into thin round discs and added to the janchi-guksu broth as garnish).

On the cutting board (center-right placement): a SINGLE WHOLE ZUCCHINI (애호박) lying flat
on the board. Zucchini dimensions: approximately 16-20cm long × 4-5cm diameter elongated
cylinder, slightly tapered at both ends (natural zucchini shape with gentle rounded ends).
Color: BRIGHT MEDIUM GREEN body (#5FA060 to #6AB066 single fill — Korean zucchini is brighter
medium green, NOT dark forest green Italian zucchini, NOT pale white-green summer squash),
with very subtle vertical ridge lines suggested by 2-3 slim cel shading strokes along the length
(the natural slight ridges of zucchini skin, rendered minimal flat — NOT heavy realistic texture).
Both ends have a slightly darker green tip (~1cm at each end, slightly darker tone #4D8050).
ONE small specular highlight along the top length suggesting the smooth waxy zucchini skin.
Subtle slim cel shading on the underside for cylindrical 3D volume. Optional: a small green
leafy crown (or short stem stub ~0.5cm) at one end as freshness accent (very small accent,
NOT a leafy bouquet — single small stub).

%s

Important also: this is a WHOLE UNCUT KOREAN ZUCCHINI (애호박) ready-to-slice state — the
zucchini MUST be a SINGLE INTACT WHOLE CYLINDER (uncut, NO disc slices, NO chopped pieces,
NO julienne strips, NO cubes scattered around). The hero ingredient is a single whole
bright green Korean zucchini lying on the board, ready to be sliced into round discs (CUT-04
통썰기 mechanic) for the janchi-guksu broth garnish.
NOT a CUCUMBER (cucumbers are darker green with more pronounced bumpy/spiky skin texture
and longer thinner shape — Korean zucchini is bright medium green and chubby cylindrical).
NOT an ITALIAN ZUCCHINI (Italian zucchini is darker forest green with more pronounced ridges,
Korean 애호박 is brighter medium green with subtle ridges).
NOT a YELLOW SUMMER SQUASH (this is GREEN zucchini, not yellow).
NOT a PALE WHITE-GREEN BOTTLE GOURD or chayote (these are paler and differently shaped).
NOT a EGGPLANT (eggplant is purple-black, totally different).
NOT a BUNCH of vegetables — single intact whole zucchini only.
NOT cut into discs (discs are CUT-04 통썰기 anchor "after" state — this is the "before").
The hero is the SINGLE WHOLE BRIGHT MEDIUM GREEN KOREAN ZUCCHINI lying flat on the board,
paired with the CUT-04 통썰기 cut anchor as the prep mechanic. Knife on the LEFT static
reference (whole-slice prep mechanic = slow steady BPM 70 rhythm tap, slicing the whole
zucchini into round discs for the broth garnish).""",
    },
    {
        "id": "F-03",
        "name": "danmuji_whole",
        "food": "Kimbap",
        "cut_style": "CUT-02 채썰기",
        # §5.6.3 김밥 hero = 단무지 (yellow pickled radish) — CUT-02 채썰기와 페어
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with a WHOLE DANMUJI (단무지, uncut Korean yellow pickled radish cylinder) placed on top,
top-down view, ready-to-cut state (NO cut strips, NO julienne, NO slices — this is the whole
ingredient BEFORE any cutting, the visual "before" pair of the CUT-02 채썰기 julienne anchor).
The hero ingredient mapping = 단무지 (Korean yellow pickled daikon radish, used in F-03 kimbap
as the signature julienned yellow strip in the kimbap cross-section).

On the cutting board (center-right placement): a SINGLE WHOLE DANMUJI cylinder lying flat
horizontally — approximately 12-15cm long × 3-3.5cm diameter, a clean cylindrical shape with
slightly rounded end caps (like a fat sausage shape). The whole danmuji is a VIBRANT YELLOW
color (#F5D43E single fill, the signature bright pickled radish yellow — NOT pale beige, NOT
dull mustard yellow). The cylinder has a smooth glossy slightly translucent surface (subtle
slim cel shading on the underside for cylindrical 3D volume in top-down view + ONE small
specular highlight along the top length suggesting the pickled glossy wet surface). The end
caps are slightly more pale (#F5E58A) suggesting the cut end of the radish.

%s

Important also: this is the WHOLE DANMUJI (단무지) ready-to-cut state — the radish MUST be a
SINGLE INTACT CYLINDER (uncut, NO julienne strips, NO thin slices, NO chopped bits scattered).
The hero ingredient is a single fat bright yellow cylindrical danmuji. This pairs with the
CUT-02 채썰기 (julienne) cut anchor as the "before" state. NOT a fresh white daikon radish
(this is the PICKLED yellow form, not raw white). NOT a thin carrot shape (danmuji is fatter
and more squat). NOT a banana (similar elongated yellow shape but danmuji is a fatter cylinder
with flat end caps, NOT banana with curved-tapered end and stem). NOT a pickle gherkin
(gherkins are bumpy green, danmuji is smooth bright yellow). The single fat bright yellow
cylindrical pickled radish on the board is the hero — knife on the left, no cut strips.""",
    },
    {
        "id": "F-04",
        "name": "fish_cake_whole",
        "food": "Tteokbokki",
        "cut_style": "CUT-03 어슷썰기",
        # §5.6.4 떡볶이 hero = 어묵 (fish cake) — CUT-03 어슷썰기와 페어
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with a WHOLE FISH CAKE SHEET (어묵, uncut Korean flat fish cake) placed on top, top-down view,
ready-to-cut state (NO cut pieces, NO diagonal oval slices — this is the whole ingredient
BEFORE any cutting, the visual "before" pair of the CUT-03 어슷썰기 diagonal-slice anchor).
The hero ingredient mapping = 어묵 (Korean flat fish cake sheet, used in F-04 tteokbokki as
the signature diagonal-sliced oval pieces).

On the cutting board (center-right placement): a SINGLE WHOLE FISH CAKE SHEET lying flat —
approximately 14-18cm long × 6-8cm wide × 1-1.5cm thick (a flat rectangular sheet, like a thin
flat slab, NOT cylindrical, NOT a stick). The fish cake sheet is a LIGHT GOLDEN-BROWN color
(#C8923C single fill with slight slim cel shading edge, slightly translucent appearance
suggesting the steamed/fried texture). The surface has the classic Korean 어묵 sheet character
— mostly smooth with a very subtle hint of texture (rendered as 1-2 subtle slim shading lines
suggesting the fish paste grain, NOT heavy noise texture). The corners are slightly rounded
(not perfect sharp rectangle) suggesting the natural manufactured fish cake sheet shape.

%s

Important also: this is the WHOLE FISH CAKE SHEET (어묵) ready-to-cut state — the sheet MUST
be a SINGLE INTACT FLAT RECTANGULAR SLAB (uncut, NO diagonal oval slices, NO cubes, NO strips
scattered). The hero ingredient is a single flat light-golden-brown rectangular fish cake
sheet. This pairs with the CUT-03 어슷썰기 (diagonal slice) cut anchor as the "before" state.
NOT a Japanese naruto (narutomaki has a pink spiral cross-section, this is plain Korean 어묵
sheet). NOT a Japanese chikuwa (chikuwa is a hollow tube cylinder, this is a FLAT SHEET). NOT
a hot dog sausage (sausages are cylindrical pink/red, this is flat golden-brown). NOT a piece
of toasted bread (similar color but different shape). The single flat rectangular light-golden-
brown fish cake sheet on the board is the hero — knife on the left, no cut pieces.""",
    },
    {
        "id": "F-05",
        "name": "kimchi_whole",
        "food": "Kimchi Fried Rice",
        "cut_style": "CUT-01 다지기",
        # §5.6.5 김치볶음밥 hero = 김치 (napa cabbage kimchi) — CUT-01 다지기와 페어
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with a WHOLE KIMCHI LEAF (배추김치 한 잎, uncut Korean napa cabbage kimchi piece) placed on
top, top-down view, ready-to-cut state (NO chopped bits, NO minced kimchi — this is the whole
ingredient BEFORE any cutting, the visual "before" pair of the CUT-01 다지기 mince anchor for
김치볶음밥 use). The hero ingredient mapping = 김치 (Korean napa cabbage kimchi, used in F-05
kimchi fried rice as the chopped/minced base ingredient).

On the cutting board (center-right placement): a SINGLE WHOLE NAPA CABBAGE KIMCHI LEAF folded
loosely on itself — approximately 12-15cm long × 7-9cm wide when slightly folded (the leaf
itself when unfolded would be ~20cm long). The kimchi leaf is the classic Korean baechu kimchi
look:
- The thick WHITE-PALE RIB at one end (the stem/base of the napa cabbage leaf, ~3-4cm wide,
  off-white #F0EBD8 single fill).
- The leafy green-and-red WRINKLED CABBAGE LEAF portion fanning out (the upper leaf section,
  light green base #C8D88A heavily coated with VIBRANT GOCHU RED kimchi seasoning paste
  #E84540 single fill smeared across most of the leaf surface).
- A few subtle slim cel shading lines suggesting the natural cabbage leaf wrinkles/folds.
- ONE small specular highlight on the red-coated upper surface suggesting the wet kimchi sheen.
- Optional: 1-2 tiny chili flake red specks visible on the surface (very minimal accent).

%s

Important also: this is the WHOLE KIMCHI LEAF (배추김치 한 잎) ready-to-chop state — the leaf
MUST be a SINGLE INTACT FOLDED LEAF (uncut, NO chopped bits, NO mince granules, NO sliced
pieces scattered on the board). The hero ingredient is a single folded napa cabbage kimchi
leaf with white rib + red-coated green leaf. This pairs with the CUT-01 다지기 (mince) cut
anchor as the "before" state for the kimchi fried rice prep. NOT a whole jar of kimchi (this
is a single leaf ready for cutting, not bulk). NOT a Chinese pickled cabbage (different
red-paste profile + different seasoning). NOT a Japanese tsukemono (different color/texture).
The single folded red-coated kimchi leaf with visible white rib on the board is the hero —
knife on the left, no cut pieces.""",
    },
    {
        "id": "F-06",
        "name": "mozzarella_whole",
        "food": "Korean Corn Dog",
        "cut_style": "(no cut, whole)",
        # §5.6.6 콘도그 hero = 모짜렐라 (cheese stick) — cut 없음 (whole 그대로)
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with a WHOLE MOZZARELLA CHEESE STICK (모짜렐라 스틱, uncut Korean-style stretchy cheese stick)
placed on top, top-down view, ready-to-use state (NO cut pieces — this hero ingredient does
NOT pair with any cut style; for F-06 Korean corn dog, the cheese stick is inserted whole
inside the corn dog, NOT cut). The hero ingredient mapping = 모짜렐라 (Korean-style mozzarella
cheese stick, used in F-06 Korean corn dog as the signature stretchy cheese filling).

On the cutting board (center-right placement): a SINGLE WHOLE MOZZARELLA CHEESE STICK lying
flat horizontally — approximately 10-12cm long × 2-2.5cm diameter, a clean cylindrical stick
shape with flat end caps (like a fat finger or fat sausage shape). The cheese stick is a
CLEAN MILKY WHITE color (#FAFAFA single fill with very subtle cool sage slim cel shading on
the underside for cylindrical 3D volume in top-down view). The surface is smooth and slightly
glossy (ONE small specular highlight along the top length suggesting the fresh cheese surface).
The end caps are slightly creamier (#F5F0E8) suggesting the cut end of the cheese stick. The
overall appearance is clean, fresh, and clearly identifiable as mozzarella (NOT colored with
any other tint).

%s

Important also: this is the WHOLE MOZZARELLA CHEESE STICK (모짜렐라 스틱) ready-to-use state —
the cheese MUST be a SINGLE INTACT CYLINDRICAL STICK (uncut, NO sliced rounds, NO cut pieces,
NO grated shreds scattered). For F-06 Korean corn dog the cheese is inserted whole inside the
corn dog batter, so there is NO corresponding cut style anchor — this is the "whole ready" state
that goes directly into the corn dog. The hero ingredient is a single clean milky-white cheese
stick. NOT a chunk of cheddar (cheddar is yellow/orange, mozzarella is milky white). NOT a
brick of feta (feta is crumbly, mozzarella is smooth solid). NOT a hot dog sausage (sausages
are pink/red, this is clean white). NOT a piece of tofu (tofu is matte white with sharper
square edges, mozzarella is glossy cylindrical). The single intact milky-white cylindrical
cheese stick on the board is the hero — knife on the left (static placement, not used here).""",
    },
    {
        "id": "F-07",
        "name": "daepa_whole",
        "food": "Haemul Pajeon",
        "cut_style": "CUT-03 어슷썰기",
        # §5.6.7 해물파전 hero = 대파 daepa (large scallion) — CUT-03 어슷썰기와 페어
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with WHOLE LARGE KOREAN SCALLIONS (대파, uncut thick scallions for haemul pajeon) placed on
top, top-down view, ready-to-cut state (NO cut pieces, NO diagonal slices — this is the whole
ingredient BEFORE any cutting, the visual "before" pair of the CUT-03 어슷썰기 diagonal-slice
anchor for haemul pajeon use). The hero ingredient mapping = 대파 (Korean large/thick scallion
stalks, used in F-07 haemul pajeon as the signature diagonal-sliced pancake hero — these are
THICKER and LONGER than the F-01 ramyeon spring onion variety).

On the cutting board (center-right placement): TWO WHOLE LARGE KOREAN DAEPA SCALLION STALKS
lying flat side by side — each stalk approximately 22-26cm long × 2-2.5cm thick at the white
root end, tapering to a thinner bright green leaf end (THICKER and LONGER than the F-01
spring onion). The stalks have the classic large Korean daepa look:
- WHITE-PALE root end on one side (~8-10cm length, off-white #F5F5E8 single fill), with 2-3
  thin wispy white root strands at the very tip of each stalk.
- A clear transition zone from white to pale yellow-green in the middle (~4-5cm).
- BRIGHT GREEN leaf end on the other side (~10-12cm length, bright vivid green #52C160
  single fill, the elongated tubular green leaves slightly fanning out at the very tip).
The two stalks are aligned parallel side by side on the board, slightly overlapping at the
center. Subtle slim cel shading on the undersides for cylindrical 3D volume + ONE small
specular highlight along the top length of each stalk suggesting the fresh waxy surface.

%s

Important also: this is the WHOLE LARGE DAEPA SCALLION (대파) ready-to-cut state — the stalks
MUST be INTACT (uncut, NO diagonal slices, NO chopped bits, NO sliced rounds scattered). The
hero ingredient is TWO long thick cylindrical scallion stalks with white root end + bright
green leaf end. This pairs with the CUT-03 어슷썰기 (diagonal slice) cut anchor as the
"before" state for haemul pajeon. NOT a thin Japanese negi (negi is thinner/shorter). NOT
garlic chives (부추, those are thin flat leaves NOT thick cylindrical stalks). NOT a leek
(leeks have overlapping flat layers, daepa is a single cylindrical stalk). NOT the F-01
ramyeon thin spring onion variety (daepa is the THICKER LARGER variety used for pajeon).
The two intact thick cylindrical daepa stalks on the board are the hero — knife on the left,
no cut pieces.""",
    },
    {
        "id": "F-08",
        "name": "carrot_whole_bibimbap",
        "food": "Bibimbap",
        "cut_style": "CUT-02 채썰기",
        # §5.6.8 비빔밥 hero = 당근 (carrot) — CUT-02 채썰기와 페어
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with a WHOLE CARROT (당근, uncut fresh carrot) placed on top, top-down view, ready-to-cut
state (NO cut pieces, NO julienne strips — this is the whole ingredient BEFORE any cutting,
the visual "before" pair of the CUT-02 채썰기 julienne anchor for bibimbap use). The hero
ingredient mapping = 당근 (Korean fresh carrot, used in F-08 bibimbap as the signature
julienned bright orange strip in the bibimbap 6-color section composition).

On the cutting board (center-right placement): a SINGLE WHOLE FRESH CARROT lying flat
horizontally — approximately 15-18cm long, tapering from ~3-3.5cm diameter at the wide top
end (where the leaves attach) to a thin pointed tip at the bottom end (~0.5cm at the tip).
The carrot is a VIBRANT ORANGE color (#FF9933 single fill, the signature bright fresh carrot
orange — NOT pale beige, NOT dull dark orange). The surface has the classic carrot character:
- The wide top end has a small green leafy crown (3-5 short bright green leaf stubs, fanning
  out, total ~2-3cm long, vivid green #52C160).
- The body of the carrot is a smooth elongated tapered cone shape with 2-3 subtle slim cel
  shading horizontal ridge lines suggesting the natural carrot ring texture (NOT heavy noise
  texture).
- ONE small specular highlight along the top length suggesting the fresh waxy surface.
- The tapered pointed tip at the bottom end is the natural narrow carrot end.

%s

Important also: this is the WHOLE CARROT (당근) ready-to-cut state — the carrot MUST be a
SINGLE INTACT TAPERED CONE (uncut, NO julienne strips, NO sliced rounds, NO cube dice
scattered). The hero ingredient is a single bright vibrant orange carrot with a small green
leafy crown on top. This pairs with the CUT-02 채썰기 (julienne) cut anchor as the "before"
state for bibimbap. NOT a baby carrot (those are tiny round-ended, this is a full-size
tapered carrot with green leafy top). NOT a sweet potato (those are fatter and dark
red-purple skin). NOT a parsnip (parsnip is cream-white, this is vibrant orange). The single
bright vibrant orange tapered carrot with green leafy top on the board is the hero — knife
on the left, no cut strips.""",
    },
    {
        "id": "F-09",
        "name": "thin_beef_whole",
        "food": "Bulgogi",
        "cut_style": "(no cut, 양념재우기 marinade prep mechanic — raw before marinade state)",
        # §5.6.9 v1.17 mvp v2.2 = 불고기 hero = 얇은 marbled 소고기 (thin-sliced raw sirloin).
        # cut 없음 (already pre-sliced thin at butcher; prep mechanic = marinade application, 양념재우기).
        # 두부 firm → 얇은 소고기 전면 교체. 김치찌개 deprecated 2026-05-30.
        # F-12 갈비구이 차별화 CRITICAL: NO bone-in LA cut, NO bone visible, RAW (NOT grilled/cooked).
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with WHOLE RAW THIN-SLICED MARBLED BEEF (얇게 썬 소고기, uncut pre-sliced beef for F-09 Bulgogi
marinade prep) placed on top, top-down view, ready-to-marinade state (the beef is ALREADY
pre-sliced thin at the butcher to the bulgogi standard thickness — this is the RAW state BEFORE
the soy-pear-garlic marinade is applied, the visual "before" pair of the F-09 Bulgogi cooking
mechanic which is marinade application + pan cooking, NOT chopping). The hero ingredient mapping
= 얇게 썬 marbled beef / thin-sliced bulgogi-cut beef (the essential hero of Korean bulgogi —
already pre-sliced thin at the butcher counter, brought home to be marinated).

On the cutting board (center-right placement): a STACK or FANNED ARRANGEMENT of 5-7 THIN
SLICED RAW MARBLED BEEF SHEETS (각 slice approximately 8-12cm long × 5-7cm wide × 2-3mm THIN
paper-thin slice — the classic Korean bulgogi-cut beef thickness, much thinner than steak).
The slices are arranged in a slight diagonal FAN or STACK at slight overlap (top 2-3 slices
slightly offset from underneath ones, showing both the top slice surface + the cross-section
edges of the slices underneath — like a deck of cards slightly fanned). Color: PINK-RED RAW
BEEF base color (#C44545 to #B82F2F deep pink-red raw meat tone, NOT brown cooked, NOT bright
red fresh blood, NOT pale pink) with VISIBLE WHITE MARBLED FAT VEINS scattered as thin
irregular pale cream-white (#F0E8D8) marbling lines/dots across each slice's surface (~3-5
subtle marbling lines per slice, organic irregular pattern — this is the signature marbled
sirloin appearance). The slice edges show the THIN cross-section (~2-3mm) on the slightly-
visible side. Subtle slim cel shading on the slice edges suggesting the 3D layered stack +
ONE small specular highlight along the top slice surface suggesting the fresh moist raw beef
sheen.

%s

Important also: this is RAW THIN-SLICED MARBLED BEEF (얇게 썬 소고기) the BEFORE-MARINADE
ready-to-cook state for F-09 Bulgogi — the beef MUST be RAW (NOT cooked brown, NOT grilled
char marks, NOT marinade-coated yet, NOT plated finished dish). The hero ingredient is a stack
or fan of 5-7 thin pink-red marbled beef slices on the board.

CRITICAL — F-12 갈비구이 (Galbi-gui) 차별화:
- NO BONE-IN LA CUT — bulgogi beef is BONELESS thin-sliced sirloin, ABSOLUTELY NO visible
  white rib bone, NO bone cross-section discs along strips, NO single long bone alongside.
  Any rib bone visible = immediate FAIL (that's F-12 ING-12 Galbi-gui hero, this is F-09
  Bulgogi hero — completely separate ingredient).
- NOT GRILLED OR COOKED — bulgogi ingredient is RAW before marinade state, NOT grilled with
  char marks (cooked grilled = F-12 plated state), NOT marinade-coated brown (that's after
  양념재우기 application).
- NOT THICK STEAK SLAB — bulgogi beef is THIN paper-thin slices ~2-3mm, NOT a thick 1cm+ slab,
  NOT a butcher's whole roast.

NOT Japanese WAGYU A5 (wagyu has extreme intricate marbling pattern + premium Japanese plating
on a leaf or stone plate + extreme price-tag aesthetic — bulgogi beef has subtle natural
marbling on a kitchen cutting board, casual home cooking context).
NOT Japanese SUKIYAKI BEEF (sukiyaki uses similar thin beef slices but plated on a large
decorative platter with raw egg dipping bowl + 다른 vegetable garnish + tablecloth context, this
is on a simple kitchen cutting board for marinade prep).
NOT bacon strips (bacon is striped pink-red with white fat in CLEAR PARALLEL BANDS, crispy when
cooked, this is marbled raw sirloin with scattered marbling, not banded).
NOT salami / pepperoni / ham slices (those are cured processed meats with smooth uniform texture,
this is fresh raw marbled beef with visible fat marbling).
NOT pork belly (삼겹살 has very distinct alternating thick white-pink layered stripes, this is
marbled sirloin with scattered fine marbling).
NOT firm tofu (F-09 deprecated firm_tofu_whole was a clean matte white rectangular block —
this is the NEW F-09 ING-09: pink-red marbled raw beef slices, completely different visual:
beef NOT tofu, pink-red NOT white, fanned slices NOT block, marbled NOT smooth).

The single stack/fan of 5-7 thin pink-red marbled raw beef slices on the cutting board is the
hero — knife on the LEFT as static reference (beef is already pre-sliced at butcher, knife
position per cross-asset 19+ anchor consistency convention, prep mechanic for the game = apply
marinade not cutting).""",
    },
    {
        "id": "F-10",
        "name": "soft_tofu_whole",
        "food": "Sundubu Jjigae",
        "cut_style": "(no cut, broken curds)",
        # §5.6.10 순두부 hero = 두부 soft (soft tofu) — cut 없음 (broken curds 형태)
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with a WHOLE SOFT TOFU TUBE/CONTAINER (순두부, uncut Korean silken soft tofu in its plastic
tube packaging) placed on top, top-down view, ready-to-use state (NO cut cubes — soft tofu
is NOT cut; instead it's squeezed/scooped into the stew in soft cloud-like curds. This hero
ingredient does NOT pair with any cut style; for F-10 sundubu jjigae the soft tofu is broken
into fluffy curds, NOT cut). The hero ingredient mapping = 순두부 (Korean silken soft tofu,
used in F-10 sundubu jjigae as the signature soft cloud-like white curds in the spicy stew).

On the cutting board (center-right placement): a SINGLE WHOLE SOFT TOFU TUBE in its classic
Korean plastic packaging — approximately 18-20cm long × 5-6cm diameter, a clear cylindrical
plastic tube/sausage shape (like a large clear sausage casing). The tube CONTENTS visible
through the clear packaging show the soft CLOUD-LIKE WHITE TOFU inside (clean matte white
#FAFAFA single fill, with subtle slim cel shading suggesting the soft fragile cloud-like
texture — NOT firm sharp-edged like F-09 firm tofu). The plastic tube ends are sealed (small
flat tabs at both ends, light cream/clear color). Optional: A small simple label band on the
tube (solid color block placeholder, NO readable text). The tube has a subtle slim cel
shading on the underside for cylindrical 3D volume + ONE small specular highlight along the
top length suggesting the glossy plastic packaging.

%s

Important also: this is the WHOLE SOFT TOFU TUBE (순두부) ready-to-use state — the tofu MUST
be INTACT in its plastic packaging tube (NO scooped curds, NO broken pieces, NO cubes
scattered). For F-10 sundubu jjigae the soft tofu is squeezed/scooped directly into the stew
in soft cloud-like curds, so there is NO corresponding cut style anchor — this is the "whole
ready" state in its classic Korean tube packaging. The hero ingredient is a single intact
clear plastic soft tofu tube with visible cloud-like white tofu inside. NOT firm tofu (F-09
firm tofu is a sharp-edged rectangular block, this is a cylindrical tube package). NOT a
hot dog sausage (sausages are pink/red, this is clear tube with white contents). NOT a
mozzarella cheese stick (F-06 cheese is fully white solid cylindrical, this is clear plastic
tube wrapping). The single intact clear soft tofu tube with cloud-like white contents on the
board is the hero — knife on the left (static placement, not used here).""",
    },
    {
        "id": "F-11",
        "name": "carrot_whole_japchae",
        "food": "Japchae",
        "cut_style": "CUT-02 채썰기 (F-08 재사용)",
        # §5.6.11 잡채 hero = 당근 (carrot) — F-08과 동일 ingredient, 시각 variation 위해 별도 생성
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with a WHOLE CARROT (당근, uncut fresh carrot for japchae) placed on top, top-down view,
ready-to-cut state (NO cut pieces, NO julienne strips — this is the whole ingredient BEFORE
any cutting, the visual "before" pair of the CUT-02 채썰기 julienne anchor for japchae use).
The hero ingredient mapping = 당근 (Korean fresh carrot, used in F-11 japchae as the signature
julienned bright orange strip in the colorful glass-noodle stir-fry — same ingredient as F-08
bibimbap, but generated as a separate anchor with slight visual variation for asset diversity).

On the cutting board (center-right placement): a SINGLE WHOLE FRESH CARROT lying flat at a
SLIGHT DIAGONAL ANGLE (~15 degrees, distinct from the F-08 perfectly horizontal placement
for visual variation across the 2 carrot anchors) — approximately 16-19cm long (slightly
longer than the F-08 carrot for asset variation), tapering from ~3-3.5cm diameter at the wide
top end to a thin pointed tip at the bottom end. The carrot is the same VIBRANT ORANGE color
(#FF9933 single fill). The classic carrot character:
- The wide top end has a slightly LARGER green leafy crown (4-6 short bright green leaf stubs
  fanning out wider, total ~3-4cm long, vivid green #52C160 — slightly more leafy than F-08
  for visual variation).
- The body of the carrot is a smooth elongated tapered cone shape with 2-3 subtle slim cel
  shading horizontal ridge lines suggesting the natural carrot ring texture.
- ONE small specular highlight along the top length suggesting the fresh waxy surface.
- The tapered pointed tip at the bottom end.

%s

Important also: this is the WHOLE CARROT (당근) ready-to-cut state for japchae — the carrot
MUST be a SINGLE INTACT TAPERED CONE (uncut, NO julienne strips, NO sliced rounds, NO cube
dice scattered). The hero ingredient is a single bright vibrant orange carrot with a slightly
larger green leafy crown on top (visual variation from F-08). This pairs with the CUT-02
채썰기 (julienne) cut anchor as the "before" state for japchae. Same ingredient species as
F-08 bibimbap carrot — game-designer foods CSV prep_* 후속 확정 시 F-11 carrot 추가 안 하고
F-08 anchor를 재사용 가능 (이 경우 본 F-11 carrot anchor는 archive). NOT a baby carrot. NOT
a sweet potato. NOT a parsnip. The single bright vibrant orange tapered carrot with green
leafy top on the board (slightly diagonal angled placement for asset variation) is the hero
— knife on the left, no cut strips.""",
    },
    {
        "id": "F-12",
        "name": "garlic_whole",
        "food": "Galbi-gui",
        "cut_style": "CUT-01 다지기",
        # §5.6.12 갈비구이 hero = 마늘 (garlic cloves) — CUT-01 다지기와 페어
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with WHOLE GARLIC CLOVES (마늘, uncut individual Korean garlic cloves) placed on top, top-down
view, ready-to-cut state (NO mince bits, NO chopped garlic — this is the whole ingredient
BEFORE any cutting/chopping, the visual "before" pair of the CUT-01 다지기 mince anchor for
galbi-gui marinade use). The hero ingredient mapping = 마늘 (Korean garlic cloves, used in
F-12 galbi-gui marinade as the signature finely-minced base + as the chopped garnish on the
finished grilled meat).

On the cutting board (center-right placement): a loose cluster of 5-7 WHOLE INDIVIDUAL GARLIC
CLOVES (Korean 통마늘 — peeled individual cloves, NOT the whole garlic bulb with all cloves
attached). Each clove is the classic peeled garlic clove shape (a small elongated teardrop /
small almond-like oval shape, approximately 2-3cm long × 1.5-2cm wide, off-white to pale cream
#F5F0E0 single fill with bold outline). The cloves are scattered naturally on the board in a
loose pile (not perfect grid, slight natural overlap, suggesting "ready to be minced"). Each
clove has the characteristic gentle teardrop shape with a slightly pointed root end (the small
tan-colored stem tip) and a rounded broad end. Subtle slim cel shading on the undersides for
3D volume + ONE small specular highlight on each clove's top suggesting the fresh garlic
surface sheen.

%s

Important also: this is the WHOLE GARLIC CLOVES (마늘) ready-to-mince state — the cloves MUST
be WHOLE INDIVIDUAL PEELED CLOVES (uncut, NO mince granules, NO chopped bits, NO whole garlic
bulb still attached). The hero ingredient is a loose cluster of 5-7 individual peeled
off-white teardrop-shaped garlic cloves. This pairs with the CUT-01 다지기 (mince) cut
anchor as the "before" state for galbi-gui marinade. NOT a whole garlic bulb with all cloves
attached and the papery skin still on (those would be a single larger round bulb shape — this
is the PEELED INDIVIDUAL CLOVE state ready for chopping). NOT onion pieces (onions are
larger, more rounded, with visible layered structure — garlic cloves are small teardrop
shape). NOT ginger (ginger is light tan with knobbly irregular shape). NOT shallots (shallots
are reddish-purple). The loose cluster of 5-7 off-white teardrop-shaped peeled garlic cloves
on the board is the hero — knife on the left, no chopped bits.""",
    },
]


def build_prompt(body: str) -> str:
    """body의 첫 %s를 STYLE_SUFFIX_INGREDIENT로 교체. body의 다른 %는 보존."""
    return body.replace("%s", STYLE_SUFFIX_INGREDIENT, 1)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="M1 후반 음식 12 × hero ingredient whole anchor 12장 자동 생성"
    )
    parser.add_argument(
        "--only", type=str, default="",
        help="콤마구분 food ID만 (예: F-01,F-02). 빈 값=전체 12장."
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
        default=PROJECT_ROOT / "assets-raw" / "ingredient_anchors_m1",
        help="출력 디렉터리"
    )
    parser.add_argument(
        "--version", type=str, default="v1",
        help="파일명 suffix (예: v1 → F-01_spring_onion_whole_v1.png)"
    )
    args = parser.parse_args()

    only_set = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    selected = [ing for ing in INGREDIENTS if (only_set is None or ing["id"] in only_set)]

    if not selected:
        sys.exit(f"❌ --only 매칭 ingredient 없음. 유효 ID: {[ing['id'] for ing in INGREDIENTS]}")

    args.out_dir.mkdir(parents=True, exist_ok=True)

    # cost estimate
    if args.model == "dall-e-3":
        unit = 0.080 if args.quality == "hd" else 0.040
    else:
        unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
        unit = unit_map.get(args.quality, 0.042)
    est_total = unit * len(selected)
    print("=" * 70)
    print("🥬 M1 후반 ingredient whole anchor 생성 시작 (ADR-005 Stage 2A prerequisite)")
    print(f"   모델: {args.model} / 품질: {args.quality} / 사이즈: {args.size}")
    print(f"   대상: {len(selected)}장 ({[ing['id'] for ing in selected]})")
    print(f"   비용 예상: ${unit:.3f}/장 × {len(selected)} = ${est_total:.2f}")
    print(f"   출력: {args.out_dir}")
    print("=" * 70)

    api_key = load_api_key()
    client = OpenAI(api_key=api_key)

    successes: list[str] = []
    failures: list[tuple[str, str]] = []
    t0 = time.time()

    for i, ing in enumerate(selected, 1):
        fid = ing["id"]
        name = ing["name"]
        food = ing["food"]
        cut_style = ing["cut_style"]
        out_path = args.out_dir / f"{fid}_{name}_{args.version}.png"
        prompt = build_prompt(ing["body"])

        print(f"\n[{i}/{len(selected)}] {fid} ({food}) hero={name} cut={cut_style}")
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
