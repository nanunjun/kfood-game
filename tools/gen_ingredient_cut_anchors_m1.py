"""
K-Food Master — M1 후반 sprint 음식 12 × hero ingredient CUT (손질된) anchor 12장 자동 생성.

⚠️ DEPRECATED — ASSET ARCHITECTURE LOCK 위반 (docs/art/asset-architecture-lock.md §3.1, §6).
    이 드라이버는 cut 결과 재료(L-ING) 를 도마(L-TOOL) + 칼(L-TOOL) 위에 BAKED 한다
    (= 사용자 NEVER-merge mandate 의 "Bad: cutting_board + carrot PNG" 정확한 위반).
    cut variant 는 도마 없이 "결과물 단독" 이어야 한다 (§3.3, §4-4). production 사용 금지.
    대체: tools/gen_ingredient_tool_hero.py 의 *_prepared/*_cooked variant (standalone) →
    Godot 가 cutting_board/knife L-TOOL 과 runtime 합성.
    (코드 삭제는 main thread 영역 — 본 배너는 위반 표시 및 전환 경로 안내.)

ADR-005 (4-stage rhythm tap) Stage 2B/2C prerequisite — 재료 준비 결과 (whole의 "after" pair).
각 음식의 hero ingredient를 음식 시그니처 cut 형태로 결과 placement.

`tools/gen_ingredient_anchors_m1.py` template 기반 (STYLE_SUFFIX 도마/칼/bg/outline/top-down 통일).
cut anchor 7장 (CUT-00~06)은 generic cut style 시연 (예: julienne carrot generic).
본 sprint는 각 음식의 hero ingredient를 그 음식 특유 cut 결과로 specific 생성 (예: F-02 애호박은
잔치국수용 thin disc / F-04 어묵은 떡볶이용 medium oval slice).

art-director docs/prompts-library.md v1.19 §5.10 STYLE_SUFFIX_INGREDIENT_CUT (STYLE_SUFFIX_INGREDIENT
재활용 + cut된 결과 cluster placement 절 변경) prompt를 그대로 inline 임베드.

v1.19 신설 (2026-05-30, 사용자 verbatim "손질하고 나서의 ingredient 이미지가 있어야 할 거 같고"
trigger — ingredient whole 12장의 "after" cut pair sprint):
음식별 hero ingredient의 cut된 결과는 generic CUT-01~06 anchor와 미세 차이 있음 (음식 시그니처
강화 가치). 옵션 C = 12장 모두 specific 생성 채택.

음식 12 × hero ingredient × cut style 매핑 (v1.18 mvp v2.2 + 사용자 fix sync):
  F-01 라면         → 대파 (spring onion)          | CUT-05 송송썰기 small green disc rounds 20-30개
  F-02 잔치국수     → 애호박 (Korean zucchini)     | CUT-04 통썰기 round whole-slice discs 5-8개   ← v1.18 user fix
  F-03 김밥         → 단무지 (pickled radish)      | CUT-02 채썰기 thin yellow matchstick strips ~15-20
  F-04 떡볶이       → 어묵 (fish cake)             | CUT-03 어슷썰기 elongated golden-brown oval 5-7
  F-05 김치볶음밥   → 김치 (napa cabbage kimchi)   | CUT-01 다지기 fine minced red bits scattered
  F-06 콘도그       → 모짜렐라 (cheese stick)      | (no cut, whole, same as ING-06)              ← cheese는 whole
  F-07 해물파전     → 대파 daepa (large scallion)  | CUT-03 어슷썰기 elongated bright green diagonal 5-7 (dominant green)
  F-08 비빔밥       → 당근 (carrot)                | CUT-02 채썰기 thin orange matchstick strips ~15-20
  F-09 불고기       → 얇은 소고기 (thin marbled)   | (no cut, marinade prep — 양념 coated brown glaze)  ← v1.17
  F-10 순두부찌개   → 두부 soft (soft tofu)        | (no cut, broken curds — irregular fluffy white)
  F-11 잡채         → 당근 (carrot)                | CUT-02 채썰기 (F-08과 동일 결과, slight variation)
  F-12 갈비구이     → 마늘 (garlic cloves)         | CUT-01 다지기 fine minced garlic granules scattered

→ 12장 모두 cut된/prep된 결과 상태 (whole 자르기 후 또는 prep 적용 후).
→ F-06 cheese는 "no cut" 그대로 whole (ING-06과 동일, prep mechanic 없음) — 옵션 C에서도 동일 결과.
→ F-09 beef는 marinade coated state / F-10 tofu는 broken curds / 나머지 9장은 실제 cut 결과.

Usage:
    py tools/gen_ingredient_cut_anchors_m1.py
    py tools/gen_ingredient_cut_anchors_m1.py --only F-01                       # 1장만
    py tools/gen_ingredient_cut_anchors_m1.py --only F-01,F-02                  # 일부
    py tools/gen_ingredient_cut_anchors_m1.py --model gpt-image-1 --quality medium
    py tools/gen_ingredient_cut_anchors_m1.py --version v2                       # 파일명 suffix

Default:
    model    = gpt-image-1 (medium quality)
    quality  = medium ($0.042/img × 12 = ~$0.50 total)
    size     = 1024x1024 (square 1:1)
    out_dir  = assets-raw/ingredient_cut_anchors_m1/
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
# STYLE_SUFFIX_INGREDIENT_CUT — 모든 ingredient cut anchor prompt 끝에 부착
# prompts-library.md v1.19 §5.10 STYLE_SUFFIX_INGREDIENT_CUT.
# STYLE_SUFFIX_INGREDIENT 기반 + INGREDIENT PLACEMENT 절 변경 (whole → cut된 결과 cluster).
# 도마/칼/bg/outline/top-down 정확 통일 (cross-asset 31+ anchor: cut 7 + whole 12 + cut 12).
# ─────────────────────────────────────────────────────────────────────────────
STYLE_SUFFIX_INGREDIENT_CUT = """Format: square 1:1.
View: top-down (overhead view, looking straight down at the cutting board surface).
Style: modern mobile casual game asset, clean 2D illustration in Royal Match (Dream Games 2021)
aesthetic. Hero shot of a Korean kitchen cutting board with the CUT/PREPARED hero ingredient
result placed on it (just finished cutting / just finished prep, READY-TO-COOK state). Slim bold
dark outline 2-3px (warm dark #2D1D14, not pure black), single color fill with optional soft
1-layer cel shading and ONE small specular highlight per element (juicy/freshness appetite).
Vibrant saturated colors at 80-90 percent saturation, warm food + cool background balance.

CUTTING BOARD (consistent with CUT-00 ~ CUT-06 cut anchors + ING-01 ~ ING-12 whole anchors):
- A Korean kitchen wooden cutting board (도마) in warm brown wood color (#A67049 single fill,
  slim grain line accent 1-2 only, NOT heavy realistic wood texture), rectangular shape with
  rounded corners (approximately 16:9 horizontal proportion, filling most of the image).
- The board has a slight darker rim outline (warm dark #2D1D14, 2-3px), clean modern flat
  appearance — identical to the CUT-00 cutting_board base anchor silhouette.

KNIFE (consistent silhouette with CUT-00 ~ CUT-06 + ING-01 ~ ING-12):
- A modern Korean kitchen knife (식칼) — warm brown wood handle (#A67049 matching the board) +
  silver-gray steel blade (#C8C8C8 single fill with subtle slim cel shading), slim simple
  geometric shape, slightly elongated rectangular blade with a subtle pointed tip.
- The knife rests on the LEFT side of the cutting board, blade flat against the board surface,
  handle pointing toward the lower-left corner (a relaxed static placement, NOT raised
  mid-swing, NOT chopping in motion — the cutting has just FINISHED, this is the cut RESULT
  state ready to be transferred to the cooking pan).

CUT INGREDIENT PLACEMENT:
- The CUT/PREPARED hero ingredient result sits on the CENTER-RIGHT portion of the cutting board
  (to balance the knife on the left side).
- This is the CUT/PREPARED RESULT state (the ingredient AFTER cutting/prep has been done — the
  visual "after" pair of the corresponding ING-XX whole anchor's "before" state). The cut pieces
  are arranged as a natural relaxed cluster (just-finished-cutting appearance), NOT a strictly
  geometric grid, slight natural overlap or scatter, suggesting "ready to go into the pot/pan".
- NO whole uncut intact ingredient on the board (this is the "after" state — whole/uncut belongs
  to ING-XX whole anchors, NOT this ingredient cut anchor). Optional: ONE small partial unsliced
  remnant (e.g., a small leftover tip) as visual "before" reference is OK but very minor accent.

BACKGROUND:
- Solid Cool Sage #C8D5C0 background (consistent across all 12 ingredient cut anchors + 12
  ingredient whole anchors + 7 cut anchors + 12 food anchors + 5 environment anchors for
  cross-asset one-game-world identity).
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
WHOLE UNCUT INTACT ingredient on the board (this is the CUT/PREPARED RESULT "after" state —
whole/uncut belongs to ING-XX whole anchor, NOT this ingredient cut anchor),
cutting action mid-motion (knife raised mid-swing, hands chopping), human characters,
hands holding the knife, kitchen environment background, multiple cutting boards,
multiple knives, any English or Korean text legibly readable on the board."""


# ─────────────────────────────────────────────────────────────────────────────
# INGREDIENT_CUTS — 12개 항목 (음식 12 × hero ingredient CUT 결과)
# prompts-library.md v1.19 §5.10.1 ~ §5.10.12 본문 inline.
# 각 항목: id (food_id) / name / food_name_en / cut_style_id / body.
# STYLE_SUFFIX_INGREDIENT_CUT는 자동 append via build_prompt(.replace("%s", ...))
# ─────────────────────────────────────────────────────────────────────────────
INGREDIENT_CUTS = [
    {
        "id": "F-01",
        "name": "spring_onion_cut",
        "food": "Ramyeon",
        "cut_style": "CUT-05 송송썰기 (small thin green discs)",
        # §5.10.1 라면 hero = 대파 송송 sliced thin rounds (ING-01 whole의 "after")
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with SLICED THIN ROUND SCALLION DISCS (송송 썬 대파, cut result for F-01 Ramyeon) scattered on top,
top-down view, cutting RESULT state (the spring onion has just been 송송 sliced into many thin
small rounds — this is the visual "after" pair of the ING-01 spring onion whole anchor's "before"
state). The hero ingredient mapping = 대파 (Korean spring onion) sliced into 송송 thin rounds for
F-01 ramyeon as the signature garnish sprinkled on top of the spicy broth.

On the cutting board (center-right placement): a generous cluster of 20-30 SMALL THIN ROUND
SPRING ONION SLICES scattered as a relaxed pile (just-finished-cutting appearance, natural slight
scatter, NOT perfectly aligned). Each slice is a small thin round disc — approximately 1-1.5cm
diameter × 1-3mm thick. Each slice shows the characteristic scallion ring pattern:
- A small WHITE circle in the center (the hollow scallion stem cross-section interior, off-white
  #F5F5E8 single fill, ~3-5mm diameter inner ring).
- Surrounded by a BRIGHT VIVID GREEN ring (the outer scallion stem wall, bright green #52C160
  single fill, ~1.5-2.5mm ring thickness).
- A subtle slim cel shading hint suggesting the round disc volume (very minimal accent).
The cluster of slices is generously scattered across the center-right of the board, suggesting
abundance "ready to sprinkle into the ramyeon broth". A few slices slightly overlap each other.
Optional: ONE small partial unsliced spring onion remnant (1-2cm leftover root tip section, white
end) on the LEFT side of the cluster as visual "before" reference (very minor accent, OK to omit).

%s

Important also: this is the CUT RESULT of SPRING ONION 송송썰기 (sliced thin rounds) — the
scallion slices MUST be MANY SMALL THIN ROUND DISCS (1-1.5cm diameter × 1-3mm thick, ~20-30
slices scattered) with the characteristic small white center ring + bright green outer ring
pattern. This pairs with the ING-01 spring onion whole anchor as the "after" state for F-01
ramyeon garnish prep.
NOT elongated oval slices (those would be 어슷썰기 diagonal slice for F-04/F-07 — different
cut style).
NOT thicker large round disc (those would be 통썰기 — 송송 is distinctly thinner and smaller).
NOT julienne matchstick strips (different cut style).
NOT minced bits (different cut style).
NOT the WHOLE intact spring onion stalk (that's ING-01 whole anchor "before" state).
The generous cluster of 20-30 small thin bright green round scallion slices with white center
rings on the board is the hero — knife on the LEFT static reference (송송 cut prep mechanic =
fastest BPM 130 rhythm tap, rapid repeated thin slicing of the cylindrical scallion stem into
small round discs for the F-01 ramyeon broth surface garnish).""",
    },
    {
        "id": "F-02",
        "name": "zucchini_cut",
        "food": "Janchi-guksu",
        "cut_style": "CUT-04 통썰기 (round whole-slice discs)",
        # §5.10.2 잔치국수 hero = 애호박 통썰기 (ING-02 whole의 "after", 사용자 v1.18 fix mapping)
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with WHOLE-SLICED KOREAN ZUCCHINI DISCS (통썬 애호박, cut result for F-02 Janchi-guksu) arranged
on top, top-down view, cutting RESULT state (the Korean zucchini has just been 통썰기 sliced into
several thin round discs — this is the visual "after" pair of the ING-02 zucchini whole anchor's
"before" state). The hero ingredient mapping = 애호박 (Korean zucchini squash) sliced into 통썰기
thin round discs for F-02 janchi-guksu as the signature garnish floated on top of the clear
anchovy broth.

On the cutting board (center-right placement): a row of 5-8 ROUND ZUCCHINI DISCS arranged in a
slightly fanned line or relaxed natural overlap (just-finished-cutting appearance, NOT perfectly
geometric grid). Each disc is a clean round circle — approximately 4-5cm diameter × 3-5mm thick
(thin whole-slice for the broth garnish). Each disc shows the characteristic Korean zucchini
cross-section:
- BRIGHT MEDIUM GREEN OUTER RIM (#5FA060 to #6AB066 single fill, ~3-4mm ring thickness, the
  zucchini skin from the round cut).
- PALE GREEN-WHITE INNER FLESH (#D8E8B8 to #E5EDC0 single fill, the soft inner zucchini flesh
  filling the disc center).
- Optional: a SUBTLE INNER SEED PATTERN — 3-5 tiny pale seed dots clustered at the very center
  (very minimal accent, ~1-2mm each, NOT prominent seed cavity, NOT scooped out hollow).
- ONE small specular highlight on the top surface of each disc suggesting the fresh moist cut
  surface.
The 5-8 discs are arranged in a relaxed row across the center-right of the board, with a slight
fan or natural overlap (like a deck of cards slightly spread). Optional: ONE small partial
unsliced zucchini end tip (~1-2cm leftover end with the dark green tip) on the LEFT side of the
row as visual "before" reference (very minor accent, OK to omit).

%s

Important also: this is the CUT RESULT of KOREAN ZUCCHINI 통썰기 (whole-slice round discs) —
the zucchini slices MUST be 5-8 PERFECT ROUND DISCS (4-5cm diameter × 3-5mm thick) showing the
classic medium green outer rim + pale green-white inner flesh cross-section. This pairs with
the ING-02 zucchini whole anchor as the "after" state for F-02 janchi-guksu broth garnish prep.
NOT cucumber slices (cucumbers are darker green with more prominent bumpy skin texture and
larger seed cavity — Korean zucchini is bright medium green with subtle smooth skin and minimal
seed dots).
NOT Italian zucchini darker forest green slices (Korean 애호박 is brighter medium green).
NOT yellow summer squash slices (this is GREEN zucchini, not yellow).
NOT diagonal oval slices (those would be 어슷썰기 — 통썰기 is round perfect circles).
NOT julienne strips, NOT cube dice, NOT mince bits.
NOT the WHOLE intact zucchini cylinder (that's ING-02 whole anchor "before" state).
The 5-8 bright medium green round zucchini discs with pale green-white inner flesh on the board
is the hero — knife on the LEFT static reference (통썰기 cut prep mechanic = slow steady BPM 70
rhythm tap, slow steady slicing of the whole zucchini into round discs for the F-02 janchi-guksu
broth garnish).""",
    },
    {
        "id": "F-03",
        "name": "danmuji_cut",
        "food": "Kimbap",
        "cut_style": "CUT-02 채썰기 (thin yellow matchstick strips)",
        # §5.10.3 김밥 hero = 단무지 채썰기 (ING-03 whole의 "after")
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with JULIENNED DANMUJI STRIPS (채썬 단무지, cut result for F-03 Kimbap) arranged on top, top-down
view, cutting RESULT state (the yellow pickled radish has just been 채썰기 julienned into many
thin elongated matchstick strips — this is the visual "after" pair of the ING-03 danmuji whole
anchor's "before" state). The hero ingredient mapping = 단무지 (Korean yellow pickled radish)
julienned into 채썰기 matchstick strips for F-03 kimbap as the signature long yellow strip running
through the kimbap cross-section.

On the cutting board (center-right placement): a pile of 15-20 THIN ELONGATED YELLOW MATCHSTICK
STRIPS arranged in a slightly fanned parallel cluster (just-finished-julienning appearance, all
strips roughly aligned in the same direction with slight natural overlap, NOT perfectly geometric
stack). Each strip is a thin elongated matchstick — approximately 8-10cm long × 4-5mm wide ×
4-5mm thick (long matchstick-like shape, the classic kimbap-cut danmuji length). Color: VIBRANT
YELLOW (#F5D43E single fill, the signature bright pickled radish yellow — NOT pale beige, NOT
dull mustard yellow). Each strip has:
- A smooth glossy slightly translucent surface (subtle slim cel shading on one long edge for 3D
  thickness hint).
- ONE small specular highlight along the top length suggesting the pickled glossy wet surface.
- End cuts slightly paler (#F5E58A) suggesting the cross-section.
The 15-20 strips are arranged in a slightly fanned parallel cluster across the center-right of
the board, suggesting "just been julienned ready to lay inside the kimbap roll". Optional: ONE
small partial unsliced danmuji end remnant (~2-3cm leftover cylinder end) on the LEFT side of
the cluster as visual "before" reference (very minor accent, OK to omit).

%s

Important also: this is the CUT RESULT of DANMUJI 채썰기 (julienne matchstick strips) — the
danmuji strips MUST be 15-20 THIN ELONGATED YELLOW MATCHSTICK STRIPS (8-10cm long × 4-5mm wide
× 4-5mm thick, parallel-aligned cluster). This pairs with the ING-03 danmuji whole anchor as
the "after" state for F-03 kimbap roll prep.
NOT fresh white daikon julienne (this is the PICKLED yellow form, not raw white).
NOT short matchsticks (kimbap-length is longer ~8-10cm, NOT short 3-4cm julienne).
NOT thicker chunky strips (julienne is THIN 4-5mm, NOT thick 1cm+ strip).
NOT diagonal oval slices, NOT round discs, NOT cube dice, NOT mince bits.
NOT the WHOLE intact danmuji cylinder (that's ING-03 whole anchor "before" state).
The pile of 15-20 thin bright yellow matchstick strips parallel-aligned on the board is the
hero — knife on the LEFT static reference (채썰기 cut prep mechanic = BPM 110 rhythm tap,
multiple repeated thin slicing of the cylindrical pickled radish into long matchstick strips
for the F-03 kimbap signature filling).""",
    },
    {
        "id": "F-04",
        "name": "fish_cake_cut",
        "food": "Tteokbokki",
        "cut_style": "CUT-03 어슷썰기 (elongated golden-brown oval slices)",
        # §5.10.4 떡볶이 hero = 어묵 어슷썰기 (ING-04 whole의 "after")
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with DIAGONAL-SLICED FISH CAKE PIECES (어슷썬 어묵, cut result for F-04 Tteokbokki) arranged on
top, top-down view, cutting RESULT state (the fish cake sheet has just been 어슷썰기 diagonally
sliced into several elongated oval pieces — this is the visual "after" pair of the ING-04 fish
cake whole anchor's "before" state). The hero ingredient mapping = 어묵 (Korean flat fish cake
sheet) diagonally sliced into 어슷썰기 elongated oval pieces for F-04 tteokbokki as the signature
golden-brown oval pieces nestled among the red rice cakes.

On the cutting board (center-right placement): a relaxed pile of 5-7 ELONGATED OVAL FISH CAKE
PIECES arranged in a natural overlapping cluster (just-finished-diagonal-slicing appearance, the
pieces slightly fan or overlap, NOT perfectly stacked geometric). Each piece is a flat elongated
oval — approximately 6-8cm long diagonal × 3-4cm wide × 1-1.5cm thick (medium oval slice for the
tteokbokki pot). The elongated oval shape IS the diagonal slice signature (longer in one dimension
than the natural cross-section diameter, the 어슷썰기 characteristic). Color: LIGHT GOLDEN-BROWN
(#C8923C single fill with slight slim cel shading edge, slightly translucent appearance
suggesting the steamed/fried fish cake texture). Each piece has:
- A smooth surface with a very subtle hint of fish paste grain texture (rendered as 1-2 subtle
  slim shading lines, NOT heavy noise texture).
- Rounded oval corners (the diagonal cut from the rectangular fish cake sheet results in
  smooth elongated ovals).
- ONE small specular highlight on the top surface of each piece suggesting the slightly glossy
  steamed/fried fish cake.
The 5-7 oval pieces are arranged in a relaxed overlapping cluster across the center-right of
the board, suggesting "just been diagonally sliced ready to add to the tteokbokki pot".
Optional: ONE small partial unsliced fish cake sheet end remnant (~2-3cm leftover flat sheet
piece) on the LEFT side of the cluster as visual "before" reference (very minor accent, OK to
omit).

%s

Important also: this is the CUT RESULT of FISH CAKE 어슷썰기 (diagonal elongated oval slices) —
the fish cake slices MUST be 5-7 ELONGATED OVAL SHAPES (6-8cm long × 3-4cm wide × 1-1.5cm
thick, the diagonal cut signature — longer in one dimension than the natural rectangular
cross-section). This pairs with the ING-04 fish cake whole anchor as the "after" state for F-04
tteokbokki pot prep.
NOT round perfect circles (those would be 통썰기 whole slice — 어슷썰기 is ELONGATED OVAL).
NOT square/rectangular cubes (those would be 깍둑썰기).
NOT thin matchstick strips (those would be 채썰기).
NOT mince bits, NOT round discs.
NOT Japanese naruto (narutomaki has pink spiral cross-section, this is plain Korean 어묵 oval
slices).
NOT Japanese chikuwa (chikuwa is a hollow tube cylinder, this is FLAT elongated oval pieces).
NOT the WHOLE intact fish cake sheet (that's ING-04 whole anchor "before" state).
The relaxed cluster of 5-7 elongated light golden-brown oval fish cake pieces on the board is
the hero — knife on the LEFT static reference (어슷썰기 cut prep mechanic = BPM 100 rhythm tap,
medium diagonal slicing of the flat fish cake sheet into elongated ovals for the F-04 tteokbokki
pot).""",
    },
    {
        "id": "F-05",
        "name": "kimchi_cut",
        "food": "Kimchi Fried Rice",
        "cut_style": "CUT-01 다지기 (fine minced red bits scattered)",
        # §5.10.5 김치볶음밥 hero = 김치 다지기 (ING-05 whole의 "after")
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with FINELY MINCED KIMCHI BITS (다진 김치, cut result for F-05 Kimchi Fried Rice) scattered on
top, top-down view, cutting RESULT state (the kimchi leaf has just been 다지기 finely minced into
many small red-coated bits — this is the visual "after" pair of the ING-05 kimchi whole anchor's
"before" state). The hero ingredient mapping = 김치 (Korean napa cabbage kimchi) finely minced
into 다지기 small bits for F-05 kimchi fried rice as the signature red-coated chopped base
mixed throughout the fried rice.

On the cutting board (center-right placement): a generous scatter of FINELY MINCED KIMCHI BITS
covering a roughly oval area in the center-right of the board (just-finished-mincing appearance,
natural loose pile with slight scattered bits at the edges). Each bit is a small irregular
finely-chopped piece — approximately 5-10mm irregular angular shapes (NOT round perfect discs,
NOT large chunks, finely chopped texture). The minced kimchi shows the classic Korean kimchi
look:
- Each bit is a piece of napa cabbage leaf COATED with VIBRANT GOCHU RED kimchi seasoning paste
  (#E84540 dominant single fill, the red gochugaru-and-garlic paste smearing each bit).
- Some bits show a hint of the original PALE GREEN-WHITE cabbage leaf base underneath the red
  coating (~10-20% pale base visible per bit, the red coating is dominant).
- A few tiny RED CHILI FLAKE specks scattered as additional accent (very minimal).
- ONE small specular highlight on the top of the cluster suggesting the wet kimchi sheen.
The cluster of finely minced kimchi bits is generously scattered across the center-right of the
board, suggesting "just been finely minced ready to add to the fried rice pan". Optional: ONE
small partial unminced kimchi leaf remnant (~2-3cm leftover folded leaf piece with visible white
rib) on the LEFT side of the cluster as visual "before" reference (very minor accent, OK to
omit).

%s

Important also: this is the CUT RESULT of KIMCHI 다지기 (fine mince) — the kimchi bits MUST be
MANY SMALL FINELY-CHOPPED IRREGULAR BITS (5-10mm each, RED-COATED napa cabbage pieces with the
gochu red kimchi seasoning paste dominant). This pairs with the ING-05 kimchi whole anchor as
the "after" state for F-05 kimchi fried rice prep.
NOT large chunks (mince is FINE 5-10mm, NOT 2-3cm chunks).
NOT julienne strips (those would be 채썰기).
NOT diagonal oval slices, NOT round discs, NOT cube dice.
NOT Chinese pickled cabbage (different red-paste profile + different seasoning — Korean kimchi
gochu paste is dominant red).
NOT Japanese tsukemono (different color/texture — pickled in salt or vinegar, not red gochu).
NOT the WHOLE intact folded kimchi leaf (that's ING-05 whole anchor "before" state).
The generous scatter of finely minced red-coated kimchi bits on the board is the hero — knife
on the LEFT static reference (다지기 cut prep mechanic = fastest BPM 140 rhythm tap, rapid
repeated fine chopping of the folded kimchi leaf into small bits for the F-05 kimchi fried rice
pan).""",
    },
    {
        "id": "F-06",
        "name": "mozzarella_whole_no_cut",
        "food": "Korean Corn Dog",
        "cut_style": "(no cut, whole — same as ING-06)",
        # §5.10.6 콘도그 hero = 모짜렐라 cheese stick (no cut, ING-06과 동일 결과)
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with a WHOLE MOZZARELLA CHEESE STICK (모짜렐라 스틱, F-06 Korean Corn Dog hero ingredient — NO
CUT PREP REQUIRED, the cheese stick is inserted whole into the corn dog batter so this anchor
shows the cheese stick in its ready-to-use whole state) placed on top, top-down view, ready-to-
use state (the cheese stick goes directly into the corn dog batter whole, NO cutting prep step
in the game mechanic — this anchor is visually identical to the ING-06 mozzarella whole anchor).

On the cutting board (center-right placement): a SINGLE WHOLE MOZZARELLA CHEESE STICK lying
flat horizontally — approximately 10-12cm long × 2-2.5cm diameter, a clean cylindrical stick
shape with flat end caps (like a fat finger or fat sausage shape). The cheese stick is a CLEAN
MILKY WHITE color (#FAFAFA single fill with very subtle cool sage slim cel shading on the
underside for cylindrical 3D volume in top-down view). The surface is smooth and slightly
glossy (ONE small specular highlight along the top length suggesting the fresh cheese surface).
The end caps are slightly creamier (#F5F0E8) suggesting the cut end of the cheese stick. The
overall appearance is clean, fresh, and clearly identifiable as mozzarella (NOT colored with
any other tint).

%s

Important also: this is the WHOLE MOZZARELLA CHEESE STICK (모짜렐라 스틱) ready-to-use state for
F-06 Korean Corn Dog — the cheese MUST be a SINGLE INTACT CYLINDRICAL STICK (uncut, NO sliced
rounds, NO cut pieces, NO grated shreds scattered). For F-06 Korean corn dog the cheese is
inserted whole inside the corn dog batter, so there is NO corresponding cut prep state — this
"whole ready" state IS the prep result (visually identical to the ING-06 whole anchor; the F-06
ingredient cut anchor exists for catalog completeness but is the same image).
NOT a chunk of cheddar (cheddar is yellow/orange, mozzarella is milky white).
NOT a brick of feta (feta is crumbly, mozzarella is smooth solid).
NOT a hot dog sausage (sausages are pink/red, this is clean white).
NOT a piece of tofu (tofu is matte white with sharper square edges, mozzarella is glossy
cylindrical).
NOT cut into slices or cubes (this is the WHOLE ready state — there is no cut prep for cheese).
The single intact milky-white cylindrical cheese stick on the board is the hero — knife on the
LEFT static reference (static placement, NO cut prep mechanic used for cheese — the cheese goes
whole into the corn dog batter).""",
    },
    {
        "id": "F-07",
        "name": "daepa_cut",
        "food": "Haemul Pajeon",
        "cut_style": "CUT-03 어슷썰기 (elongated bright green diagonal slices)",
        # §5.10.7 해물파전 hero = 대파 daepa 어슷썰기 (ING-07 whole의 "after", F-04와 구분: large daepa)
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with DIAGONAL-SLICED LARGE DAEPA SCALLION PIECES (어슷썬 대파, cut result for F-07 Haemul Pajeon)
arranged on top, top-down view, cutting RESULT state (the large daepa scallion stalks have just
been 어슷썰기 diagonally sliced into several elongated bright green oval pieces — this is the
visual "after" pair of the ING-07 daepa whole anchor's "before" state). The hero ingredient
mapping = 대파 daepa (Korean large/thick scallion stalks, THICKER and LONGER than the F-01
spring onion variety) diagonally sliced into 어슷썰기 elongated bright green oval pieces for
F-07 haemul pajeon as the SIGNATURE DOMINANT green ingredient baked into the savory pancake.

On the cutting board (center-right placement): a relaxed pile of 5-7 ELONGATED BRIGHT GREEN
DAEPA OVAL PIECES arranged in a natural overlapping cluster (just-finished-diagonal-slicing
appearance, the pieces slightly fan or overlap, NOT perfectly stacked geometric). Each piece is
an elongated diagonal oval — approximately 5-7cm long diagonal × 1.5-2.5cm wide × 1-1.5cm thick
(LARGE oval slice from the thick daepa stalk — DISTINCTLY LARGER than F-04 fish cake oval, this
is the dominant green vegetable for the pancake). Color: BRIGHT VIVID GREEN dominant (#52C160
single fill for the green leaf portion, with a small WHITE-PALE base accent at the root-end
slices) — the dominant green color is the F-07 pajeon signature (more green than white).
Each piece has:
- The characteristic hollow cylindrical cross-section showing a small WHITE-PALE CENTER (the
  scallion stem hollow interior, ~3-5mm) surrounded by a BRIGHT GREEN ring (the outer stem
  wall, ~5-8mm ring thickness for the thick daepa variety).
- The elongated oval shape (longer in one dimension than the natural cross-section diameter,
  the 어슷썰기 diagonal cut signature) — the daepa cylindrical stalk cut at an angle produces
  visibly elongated ovals.
- ONE small specular highlight on the top surface of each piece suggesting the fresh moist cut
  surface.
The 5-7 oval pieces are arranged in a relaxed overlapping cluster across the center-right of
the board, with the dominant bright green color filling the cluster (NOT mostly white). Optional:
ONE small partial unsliced daepa stalk end remnant (~2-3cm leftover cylinder end with white root)
on the LEFT side of the cluster as visual "before" reference (very minor accent, OK to omit).

%s

Important also: this is the CUT RESULT of LARGE DAEPA SCALLION 어슷썰기 (diagonal elongated
oval slices for F-07 haemul pajeon) — the daepa slices MUST be 5-7 ELONGATED BRIGHT GREEN OVAL
SHAPES (5-7cm long × 1.5-2.5cm wide × 1-1.5cm thick, the diagonal cut signature with dominant
green color from the thick daepa stalk). This pairs with the ING-07 daepa whole anchor as the
"after" state for F-07 haemul pajeon batter prep.
NOT F-04 fish cake oval slices (those are golden-brown solid ovals; daepa ovals are bright
green with hollow center ring pattern).
NOT F-01 spring onion thin round slices (those are SMALL THIN 1-1.5cm rounds from the thin
spring onion variety; daepa ovals are LARGER 5-7cm × 1.5-2.5cm from the THICK daepa variety).
NOT round perfect circles (those would be 통썰기 whole slice — 어슷썰기 is ELONGATED OVAL).
NOT julienne strips, NOT cube dice, NOT mince bits.
NOT Japanese negi diagonal slices (negi is thinner variety; this is THICK Korean daepa for
pajeon).
NOT the WHOLE intact daepa stalks (that's ING-07 whole anchor "before" state).
The relaxed cluster of 5-7 large elongated bright green daepa oval pieces with hollow center
ring pattern on the board is the hero — knife on the LEFT static reference (어슷썰기 cut prep
mechanic = BPM 100 rhythm tap, medium diagonal slicing of the thick daepa stalks into elongated
bright green ovals for the F-07 haemul pajeon batter).""",
    },
    {
        "id": "F-08",
        "name": "carrot_cut_bibimbap",
        "food": "Bibimbap",
        "cut_style": "CUT-02 채썰기 (thin orange matchstick strips)",
        # §5.10.8 비빔밥 hero = 당근 채썰기 (ING-08 whole의 "after")
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with JULIENNED CARROT STRIPS (채썬 당근, cut result for F-08 Bibimbap) arranged on top, top-down
view, cutting RESULT state (the carrot has just been 채썰기 julienned into many thin elongated
orange matchstick strips — this is the visual "after" pair of the ING-08 carrot whole anchor's
"before" state). The hero ingredient mapping = 당근 (Korean fresh carrot) julienned into 채썰기
matchstick strips for F-08 bibimbap as the signature bright orange section in the bibimbap
6-color radial composition.

On the cutting board (center-right placement): a generous pile of 15-20 THIN ELONGATED ORANGE
MATCHSTICK STRIPS arranged in a slightly fanned parallel cluster (just-finished-julienning
appearance, all strips roughly aligned in the same direction with slight natural overlap, NOT
perfectly geometric stack). Each strip is a thin elongated matchstick — approximately 5-7cm long
× 2-3mm wide × 2-3mm thick (the classic bibimbap-cut carrot julienne size, slightly shorter than
F-03 danmuji kimbap julienne). Color: VIBRANT ORANGE (#FF9933 single fill, the signature bright
fresh carrot orange — NOT pale beige, NOT dull dark orange). Each strip has:
- A smooth surface with very subtle slim cel shading on one long edge for 3D thickness hint.
- ONE small specular highlight along the top length suggesting the fresh waxy carrot surface.
- End cuts slightly paler (#FFB060) suggesting the cross-section.
The 15-20 strips are arranged in a slightly fanned parallel cluster across the center-right of
the board, suggesting "just been julienned ready to lay in the bibimbap bowl as the orange
section". Optional: ONE small partial unsliced carrot end remnant (~2-3cm leftover tapered tip,
small green leafy stub at one end) on the LEFT side of the cluster as visual "before" reference
(very minor accent, OK to omit).

%s

Important also: this is the CUT RESULT of CARROT 채썰기 (julienne matchstick strips for F-08
bibimbap) — the carrot strips MUST be 15-20 THIN ELONGATED ORANGE MATCHSTICK STRIPS (5-7cm
long × 2-3mm wide × 2-3mm thick, parallel-aligned cluster). This pairs with the ING-08 carrot
whole anchor as the "after" state for F-08 bibimbap radial section prep.
NOT longer matchsticks (bibimbap-length is shorter ~5-7cm, NOT F-03 kimbap-length 8-10cm).
NOT thicker chunky strips (julienne is THIN 2-3mm, NOT thick 5mm+ strip).
NOT diagonal oval slices, NOT round discs, NOT cube dice, NOT mince bits.
NOT baby carrot pieces (those are tiny round, this is julienne matchstick).
NOT the WHOLE intact carrot (that's ING-08 whole anchor "before" state).
The pile of 15-20 thin bright vibrant orange matchstick strips parallel-aligned on the board is
the hero — knife on the LEFT static reference (채썰기 cut prep mechanic = BPM 110 rhythm tap,
multiple repeated thin slicing of the tapered carrot cone into long matchstick strips for the
F-08 bibimbap orange radial section).""",
    },
    {
        "id": "F-09",
        "name": "thin_beef_marinade",
        "food": "Bulgogi",
        "cut_style": "(no cut, 양념재우기 marinade prep — coated brown glaze state)",
        # §5.10.9 불고기 hero = 얇은 소고기 marinade coated (ING-09 raw whole의 "after"
        # = 양념재우기 후 marinated state, F-12 갈비 차별화 CRITICAL 유지)
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with MARINATED THIN-SLICED MARBLED BEEF (양념재운 얇은 소고기, prep result for F-09 Bulgogi) placed
on top, top-down view, prep RESULT state (the raw thin-sliced beef has just been MARINATED with
soy-pear-garlic-sesame marinade — this is the visual "after" pair of the ING-09 raw thin beef
whole anchor's "before" state. F-09 prep mechanic is NOT cutting [beef is already pre-sliced at
butcher] but rather APPLYING THE MARINADE 양념재우기). The hero ingredient mapping = 얇게 썬
marinated beef / soy-pear-garlic marinated thin-sliced bulgogi-cut beef (the essential prep step
of Korean bulgogi — applying the signature soy-pear-garlic marinade and letting it coat each
beef slice).

On the cutting board (center-right placement): a STACK or FANNED ARRANGEMENT of 5-7 THIN
MARINATED MARBLED BEEF SHEETS (각 slice approximately 8-12cm long × 5-7cm wide × 2-3mm THIN
paper-thin slice, same dimensions as ING-09 raw whole). The slices are arranged in a slight
diagonal FAN or STACK at slight overlap (top 2-3 slices slightly offset from underneath ones,
showing both the top slice surface + the cross-section edges of the slices underneath — like a
deck of cards slightly fanned, same arrangement pattern as ING-09 raw whole). Color: WARM
SOY-PEAR-GARLIC GLAZE COATED appearance — the original pink-red raw beef base (#C44545) is now
covered with a GLOSSY DARK BROWN soy-pear-garlic marinade layer (#5A3015 to #6B3A1A dominant
sticky brown glaze coating each slice surface), with the marbled WHITE FAT VEINS still subtly
visible underneath the marinade (~30-40% of the original pink-red and white marbling shows
through the glossy brown glaze coating). A small POOL of EXTRA MARINADE collects at the bottom
of the stack (a small puddle of glossy dark brown sauce ~2-3cm wide spreading around the base
of the stack on the cutting board). Optional: A few finely chopped GREEN SCALLION ROUNDS (송송
1-2mm thick) sprinkled on top as marinade additional flavor (very minimal accent, 5-8 dots),
plus 2-3 tiny SESAME SEED dots (white) scattered on top. The slice edges show the THIN cross-
section (~2-3mm) on the slightly-visible side. Subtle slim cel shading on the slice edges
suggesting the 3D layered stack + ONE small specular highlight along the top slice surface
suggesting the glossy wet marinade sheen.

%s

Important also: this is the MARINATED THIN-SLICED MARBLED BEEF (양념재운 얇은 소고기) AFTER-
MARINADE prep result state for F-09 Bulgogi — the beef MUST be COATED with GLOSSY DARK BROWN
soy-pear-garlic marinade (the prep mechanic = applying marinade, NOT cutting; the beef was
already pre-sliced at butcher). The hero ingredient is a stack or fan of 5-7 thin marinated
beef slices with sticky brown glaze coating + small marinade pool at base.

CRITICAL — F-12 갈비구이 (Galbi-gui) 차별화 (ING-09 whole과 동일 강제 — F-09 cut anchor도 적용):
- NO BONE-IN LA CUT — bulgogi beef is BONELESS thin-sliced sirloin, ABSOLUTELY NO visible
  white rib bone, NO bone cross-section discs along strips, NO single long bone alongside.
  Any rib bone visible = immediate FAIL (that's F-12 ING-12 Galbi-gui hero, this is F-09
  Bulgogi prep — completely separate ingredient).
- NOT GRILLED OR COOKED WITH CHAR MARKS — bulgogi marinade prep is uncooked marinated state
  (raw beef + brown marinade glaze coating), NOT grilled with char marks (cooked grilled with
  char marks = F-12 plated state). The brown color comes from the MARINADE coating, NOT from
  grilling.
- NOT THICK STEAK SLAB — bulgogi beef is THIN paper-thin slices ~2-3mm, NOT a thick 1cm+ slab.

NOT raw uncooked plain beef (that's ING-09 whole anchor "before" state — pink-red without
marinade. This F-09 cut anchor IS the after-marinade state).
NOT Japanese WAGYU A5 with premium plating (this is casual home cooking prep on a kitchen
cutting board).
NOT Japanese SUKIYAKI BEEF (sukiyaki uses similar thin slices but plated on a decorative
platter with raw egg dipping bowl + 다른 vegetable garnish + tablecloth context, this is on a
simple kitchen cutting board for marinade prep).
NOT bacon strips (bacon is striped pink-red with parallel white fat bands).
NOT salami / pepperoni / ham slices (those are cured processed meats).
NOT pork belly 삼겹살 (alternating thick white-pink layered stripes — this is marbled sirloin
with scattered fine marbling under brown marinade).
NOT cooked bulgogi finished dish in a pan with vegetables (that's the F-09 plated state, not
the prep state).
NOT the RAW pink-red unmarinated beef stack (that's ING-09 whole anchor "before" state — this
F-09 cut anchor IS the AFTER-marinade brown-glazed state).

The single stack/fan of 5-7 thin glossy dark-brown marinated marbled beef slices + small
marinade pool at base on the cutting board is the hero — knife on the LEFT static reference
(beef is already pre-sliced at butcher, knife position per cross-asset 31+ anchor consistency
convention, prep mechanic for the game = APPLY MARINADE 양념재우기 not cutting; rhythm tap may
represent the marinade application/mixing motion or just static prep step).""",
    },
    {
        "id": "F-10",
        "name": "soft_tofu_broken",
        "food": "Sundubu Jjigae",
        "cut_style": "(no cut, broken curds — irregular fluffy white)",
        # §5.10.10 순두부 hero = 두부 soft broken curds (ING-10 whole tube의 "after"
        # = squeezed/scooped 후 broken cloud-like curds state)
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with BROKEN SOFT TOFU CURDS (스푼으로 푼 순두부, prep result for F-10 Sundubu Jjigae) placed on
top, top-down view, prep RESULT state (the soft tofu has just been SQUEEZED OUT of its plastic
tube and BROKEN into irregular fluffy cloud-like curds — this is the visual "after" pair of the
ING-10 soft tofu whole tube anchor's "before" state. F-10 prep mechanic is NOT cutting but rather
SQUEEZING/SCOOPING the soft tofu out of the tube into broken curds ready to add to the spicy
stew). The hero ingredient mapping = 순두부 (Korean silken soft tofu) broken into fluffy cloud-
like curds for F-10 sundubu jjigae as the signature white cloud-like soft tofu in the spicy
gochugaru stew.

On the cutting board (center-right placement): a GENEROUS MOUND of BROKEN SOFT TOFU CURDS
arranged as a loose pile of irregular fluffy white clumps (just-finished-scooping appearance,
natural organic uneven shapes with random soft edges and crevices, multiple small irregular
white tofu fragments clumping together). The mound occupies roughly the center-right of the
board, ~10-12cm wide × 5-7cm deep:
- Many small IRREGULAR CLOUD-LIKE WHITE TOFU FRAGMENTS clustered together (each fragment
  approximately 2-4cm irregular shape, NOT round perfect spheres, NOT geometric squares —
  organic uneven cloud-like shapes like torn soft clouds or soft cottage cheese clumps).
- Color: CLEAN MATTE WHITE (#FAFAFA single fill, the signature silken soft tofu white — NOT
  yellowish, NOT cream, pure clean white).
- Subtle slim cel shading on the underside of the mound and between fragments suggesting the
  soft fragile cloud-like texture (NOT firm sharp-edged like F-09 firm tofu, NOT smooth
  uniform like ricotta puree).
- A few SOFTER CREVICES visible between fragments (small dark recessed lines suggesting the
  organic separation between curds, very minimal).
- ONE small specular highlight on the top of the mound suggesting the moist fresh tofu surface.
The mound has a slightly DOMED shape (slightly raised at the center, gradually tapering to the
edges) — like a soft pile of cottage cheese or soft cloud heap. Optional: a SMALL EMPTY OPEN
SOFT TOFU TUBE remnant (the squeezed-out plastic packaging, ~10cm long flat clear plastic with
visible empty cavity) on the LEFT side of the mound as visual "before" reference (very minor
accent, OK to omit).

%s

Important also: this is the BROKEN SOFT TOFU CURDS (스푼으로 푼 순두부) prep result state for
F-10 Sundubu Jjigae — the soft tofu MUST be BROKEN into IRREGULAR CLOUD-LIKE FLUFFY WHITE
FRAGMENTS (organic uneven shapes, NOT smooth puree, NOT firm cubes, NOT a single solid block,
NOT geometric pieces, multiple small irregular curds clumped together like soft cottage cheese
or torn soft clouds). The fluffy cloud-like soft tofu mound is the hero (NO whole tube intact).
NOT firm tofu cubes (F-09 firm tofu would be sharp-edged white rectangular cube — this is
SOFT tofu BROKEN INTO IRREGULAR CLOUD CURDS).
NOT smooth puree (NOT mashed paste, NOT blended smooth — broken into RECOGNIZABLE IRREGULAR
FRAGMENTS).
NOT a single solid white block (broken into MULTIPLE FRAGMENTS).
NOT geometric square pieces (organic uneven irregular shapes).
NOT mozzarella cheese chunks (F-06 mozzarella would be cylindrical solid — this is soft tofu
in irregular cloud fragments).
NOT scrambled egg whites (different texture, this is solid white tofu fragments).
NOT the WHOLE intact soft tofu tube (that's ING-10 whole anchor "before" state — this F-10 cut
anchor IS the AFTER-scooping broken curds state).
The generous mound of irregular fluffy cloud-like broken soft tofu curds on the board is the
hero — knife on the LEFT static reference (NO cutting mechanic for soft tofu — the prep is
SCOOPING/SQUEEZING the tube into broken curds, knife position per cross-asset 31+ anchor
consistency convention).""",
    },
    {
        "id": "F-11",
        "name": "carrot_cut_japchae",
        "food": "Japchae",
        "cut_style": "CUT-02 채썰기 (F-08과 동일 결과, slight variation)",
        # §5.10.11 잡채 hero = 당근 채썰기 (F-08과 동일 ingredient + cut, slight visual variation)
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with JULIENNED CARROT STRIPS (채썬 당근, cut result for F-11 Japchae) arranged on top, top-down
view, cutting RESULT state (the carrot has just been 채썰기 julienned into many thin elongated
orange matchstick strips for japchae — this is the visual "after" pair of the ING-11 carrot
whole anchor's "before" state, slight visual variation from F-08 carrot cut for asset diversity).
The hero ingredient mapping = 당근 (Korean fresh carrot) julienned into 채썰기 matchstick strips
for F-11 japchae as the signature bright orange color in the colorful glass-noodle stir-fry —
same ingredient species + cut style as F-08 bibimbap, generated as a separate anchor with slight
visual variation.

On the cutting board (center-right placement): a generous pile of 15-20 THIN ELONGATED ORANGE
MATCHSTICK STRIPS arranged in a SLIGHTLY DIAGONAL fanned cluster (distinct from F-08 perfectly
horizontal parallel cluster for visual variation across the 2 carrot cut anchors — the pile sits
at a ~15 degree angle diagonal to the board's long edge). Each strip is a thin elongated
matchstick — approximately 6-8cm long × 2-3mm wide × 2-3mm thick (SLIGHTLY LONGER than F-08
bibimbap julienne 5-7cm for japchae longer noodle-like presentation). Color: VIBRANT ORANGE
(#FF9933 single fill, same as F-08 carrot). Each strip has:
- Same smooth surface + slim cel shading + specular highlight as F-08.
- The DIAGONAL ANGLE of the pile is the visual distinction from F-08 (F-08 perfectly horizontal,
  F-11 slight ~15 degree diagonal angle).
- The slightly LONGER strip length is the second visual distinction (F-08 5-7cm, F-11 6-8cm).
The 15-20 strips are arranged in a slightly fanned diagonal cluster across the center-right of
the board, suggesting "just been julienned ready to stir-fry with the dangmyeon glass noodles".
Optional: ONE small partial unsliced carrot end remnant (~2-3cm leftover tapered tip, slightly
larger leafy green stub for variation from F-08) on the LEFT side of the cluster as visual
"before" reference (very minor accent, OK to omit).

%s

Important also: this is the CUT RESULT of CARROT 채썰기 (julienne matchstick strips for F-11
japchae) — the carrot strips MUST be 15-20 THIN ELONGATED ORANGE MATCHSTICK STRIPS (6-8cm
long × 2-3mm wide × 2-3mm thick, slightly diagonal pile angle ~15 degrees for visual variation
from F-08). This pairs with the ING-11 carrot whole anchor as the "after" state for F-11
japchae stir-fry prep.
Same ingredient species as F-08 bibimbap carrot — game-designer foods CSV `prep_*` 후속 확정
시 F-11 separate anchor 생성 안 하고 F-08 cut anchor를 재사용 가능 (이 경우 본 F-11 cut anchor
는 archive).
NOT longer than 8cm (japchae julienne is medium 6-8cm, NOT extra-long like noodles).
NOT thicker chunky strips, NOT diagonal oval slices, NOT round discs, NOT cube dice.
NOT baby carrot pieces.
NOT the WHOLE intact carrot (that's ING-11 whole anchor "before" state).
The pile of 15-20 thin bright vibrant orange matchstick strips (slightly diagonal pile angle ~15
degrees for variation from F-08) on the board is the hero — knife on the LEFT static reference
(채썰기 cut prep mechanic = BPM 110 rhythm tap, multiple repeated thin slicing of the tapered
carrot cone into long matchstick strips for the F-11 japchae stir-fry with dangmyeon).""",
    },
    {
        "id": "F-12",
        "name": "garlic_cut",
        "food": "Galbi-gui",
        "cut_style": "CUT-01 다지기 (fine minced garlic granules)",
        # §5.10.12 갈비구이 hero = 마늘 다지기 (ING-12 whole의 "after")
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with FINELY MINCED GARLIC (다진 마늘, cut result for F-12 Galbi-gui) scattered on top, top-down
view, cutting RESULT state (the peeled garlic cloves have just been 다지기 finely minced into
many small yellowish-white granular bits — this is the visual "after" pair of the ING-12 garlic
whole anchor's "before" state). The hero ingredient mapping = 마늘 (Korean garlic cloves) finely
minced into 다지기 small granules for F-12 galbi-gui as the signature minced garlic base for the
marinade AND as the chopped garnish sprinkled on the finished grilled meat.

On the cutting board (center-right placement): a generous scatter of FINELY MINCED GARLIC
GRANULES covering a roughly oval area in the center-right of the board (just-finished-mincing
appearance, natural loose pile with slight scattered bits at the edges). Each granule is a small
irregular finely-chopped piece — approximately 1-3mm irregular angular shapes (NOT round perfect
discs, NOT large chunks, very fine granular texture from rapid mincing). The minced garlic shows
the classic Korean minced garlic look:
- Many small YELLOWISH-WHITE granules clustered together (off-white to pale cream #F5F0E0 to
  #F8F2D8 single fill, the classic peeled garlic color, NOT pure white, NOT yellow).
- The cluster forms a loose pile roughly ~6-8cm wide oval shape in the center-right portion of
  the board.
- A few isolated granules scattered slightly wider at the edges (natural mincing scatter).
- Subtle slim cel shading on the cluster underside suggesting the 3D pile volume.
- ONE small specular highlight on the top of the pile suggesting the moist fresh garlic surface.
- The granules show a faint mix of more substantial bits (~2-3mm) and finer particles (~1mm)
  suggesting natural mincing variation.
Optional: ONE small partial unminced garlic clove remnant (~1.5-2cm leftover teardrop clove with
visible pointed root tip) on the LEFT side of the cluster as visual "before" reference (very
minor accent, OK to omit). The knife blade may show very minor sheen hints of garlic juice on
its edge (extremely minimal, OK to omit).

%s

Important also: this is the CUT RESULT of GARLIC 다지기 (fine mince) — the garlic granules MUST
be MANY SMALL FINELY-CHOPPED IRREGULAR YELLOWISH-WHITE BITS (1-3mm each, granular texture, NOT
round discs, NOT large chunks, NOT thin slices). This pairs with the ING-12 garlic whole anchor
as the "after" state for F-12 galbi-gui marinade base prep AND finished grilled meat garnish.
NOT thin garlic slices (slices are flat round discs ~5mm, mince is fine 1-3mm granules).
NOT whole garlic cloves (that's ING-12 whole anchor "before" state — peeled teardrop cloves).
NOT julienne strips, NOT diagonal oval slices, NOT cube dice.
NOT onion mince (onion mince is larger irregular pieces with visible layered structure; garlic
mince is fine uniform yellowish-white granules).
NOT ginger mince (ginger mince is light tan with fiber strands; garlic mince is off-white
without fiber).
NOT the WHOLE intact garlic cloves (that's ING-12 whole anchor "before" state).
The generous scatter of finely minced yellowish-white garlic granules on the board is the
hero — knife on the LEFT static reference (다지기 cut prep mechanic = fastest BPM 140 rhythm
tap, rapid repeated fine chopping of the peeled garlic cloves into small granules for the F-12
galbi-gui marinade base and finished meat garnish).""",
    },
]


def build_prompt(body: str) -> str:
    """body의 첫 %s를 STYLE_SUFFIX_INGREDIENT_CUT으로 교체. body의 다른 %는 보존.

    NOTE: `body % SUFFIX` Python old-style formatting을 회피 (body의 다른 %가 ValueError 유발).
    `.replace("%s", SUFFIX, 1)` 패턴을 사용 — gen_ingredient_anchors_m1.py와 동일 fix 적용.
    """
    return body.replace("%s", STYLE_SUFFIX_INGREDIENT_CUT, 1)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="M1 후반 음식 12 × hero ingredient CUT anchor 12장 자동 생성"
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
        default=PROJECT_ROOT / "assets-raw" / "ingredient_cut_anchors_m1",
        help="출력 디렉터리"
    )
    parser.add_argument(
        "--version", type=str, default="v1",
        help="파일명 suffix (예: v1 → F-01_spring_onion_cut_v1.png)"
    )
    args = parser.parse_args()

    only_set = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    selected = [ic for ic in INGREDIENT_CUTS if (only_set is None or ic["id"] in only_set)]

    if not selected:
        sys.exit(f"❌ --only 매칭 ingredient cut 없음. 유효 ID: {[ic['id'] for ic in INGREDIENT_CUTS]}")

    args.out_dir.mkdir(parents=True, exist_ok=True)

    # cost estimate
    if args.model == "dall-e-3":
        unit = 0.080 if args.quality == "hd" else 0.040
    else:
        unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
        unit = unit_map.get(args.quality, 0.042)
    est_total = unit * len(selected)
    print("=" * 70)
    print("🔪 M1 후반 ingredient CUT anchor 생성 시작 (ADR-005 Stage 2B/2C, whole의 'after' pair)")
    print(f"   모델: {args.model} / 품질: {args.quality} / 사이즈: {args.size}")
    print(f"   대상: {len(selected)}장 ({[ic['id'] for ic in selected]})")
    print(f"   비용 예상: ${unit:.3f}/장 × {len(selected)} = ${est_total:.2f}")
    print(f"   출력: {args.out_dir}")
    print("=" * 70)

    api_key = load_api_key()
    client = OpenAI(api_key=api_key)

    successes: list[str] = []
    failures: list[tuple[str, str]] = []
    t0 = time.time()

    for i, ic in enumerate(selected, 1):
        fid = ic["id"]
        name = ic["name"]
        food = ic["food"]
        cut_style = ic["cut_style"]
        out_path = args.out_dir / f"{fid}_{name}_{args.version}.png"
        prompt = build_prompt(ic["body"])

        print(f"\n[{i}/{len(selected)}] {fid} ({food}) cut={name} style={cut_style}")
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
