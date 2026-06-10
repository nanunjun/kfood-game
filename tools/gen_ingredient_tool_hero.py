"""
K-Food Master — Ingredient & Tool HERO art generation (volumetric hero reskin).

사용자 LOCK (2026-06-06): "Ingredients and tools are NOT UI icons. They are hero art
assets." → docs/art/ingredient-tool-art-lock.md 의 Hero Asset Mandate 구현.

ASSET ARCHITECTURE LOCK 준수 (docs/art/asset-architecture-lock.md §6 — compliant reference driver):
이 드라이버는 각 재료/도구를 STANDALONE single hero 로 생성한다 (도마/칼/냄비/scene/다른
재료·도구 co-asset 0개 = NEVER-merge mandate 준수). cut variant 도 도마 없이 "결과물 단독".
합성(cutting_board+knife+ingredient 등)은 Godot runtime 책임 (art 가 미리 bake 하지 않음).
→ legacy gen_cut_anchors_m1 / gen_ingredient_anchors_m1 / gen_ingredient_cut_anchors_m1 의
  "도마+칼 baked" 위반을 대체하는 정식 standalone 드라이버.

기존 ingredient_anchors_m1 / cut_anchors_m1 / tool_anchors_m1 = Cool Sage bg + flat
single-fill + slim outline + "simple geometric flat fill / Cookingo flat clean"
(= UI-icon 느낌, REJECT). 본 driver = Style Bible v1 volumetric 톤으로 hero reskin:
  - soft volumetric shading (1~2단 gradient + top-left key + soft rim + specular 1~2점)
  - warm Cocoa #3A2A1E outline 3~4px (hand-drawn 온기)
  - warm cozy palette (Cooking Diary / Travel Town / Merge Mansion item quality)
  - single hero item 단독 (도마/손/scene 없음 — cut variant 도 결과 그 자체가 hero)
  - 한식 정체성 (뚝배기 Dolsot Charcoal earthenware / 석쇠 wire grate / 놋 brass)
  - BG Cream #FBF3E4 (또는 --background transparent), Cool Sage/mint 금지

flat vector / color block / geometric / infographic / UI icon / app-icon = avoid 절 강제
(ChatGPT flat-vector + UI-icon 누수 회피 — STYLE_SUFFIX_HERO 양쪽 강제).

ART PIPELINE CORRECTION (2026-06-06, docs/art/art-pipeline-correction.md):
  - Naming convention 정렬 — variant key = state 어휘 (whole/chopped/julienne/sliced/
    diced/minced/cubed/marinated/cooked). 출력 파일명도 사용자 naming(green_onion_whole)
    으로 정렬 (--naming clean = prefix 제거, default).
  - Vessel/Tool gap 추가 — cutting_board / rolling_mat (L-TOOL) + frying_pan /
    mixing_bowl (L-VES). legacy 에서 재료와 baked 또는 flat mockup 이라 standalone 필요.
  - Tool 재분류/rename — knife→chef_knife (L-TOOL), korean_grill→grill_pan (L-VES),
    pot/dolsot = L-VES (빈 용기). Vessel 은 "EMPTY vessel, no food inside" suffix.
  - --background transparent 권장 (production 합성용).

출력 (--naming clean, default):
  ingredient: assets-raw/ingredient_tool_hero_m2/{ingredient}_{state}.png  (예: green_onion_whole.png)
  tool:       assets-raw/ingredient_tool_hero_m2/{tool}.png                (예: chef_knife.png)
  vessel:     assets-raw/ingredient_tool_hero_m2/{vessel}.png              (예: mixing_bowl.png)
출력 (--naming legacy):
  ingredient: ing_{item}_{variant}.png / tool: tool_{item}.png (구 prefix 호환)

ART-DRIVER 확장 (2026-06-06, 39-spec full coverage):
  사용자 LOCKED 정확 39 standalone asset = 20 ingredient + 9 tool + 10 vessel.
  누락 11 추가: egg_whole / egg_cooked / rice_bowl / noodle_raw / noodle_cooked
    + seasoning_bottle / spoon / chopsticks
    + noodle_bowl / brass_bowl / wooden_tray / wide_plate / earthenware_bowl.
  tofu naming 정렬: firm_tofu → tofu (tofu_block / tofu_cubed).
  --spec39 = 정확히 이 39장만 (driver 의 음식 12-매핑 extra 변형 제외).
  STYLE_SUFFIX_HERO 일관성 LOCK 강화: top-left key / Cocoa #3A2A1E 3-4px / 3-4 view
    slight-overhead camera 를 every-asset 명시 통일.

Usage:
    py tools/gen_ingredient_tool_hero.py --spec39 --background transparent  # 사용자 정확 39장
    py tools/gen_ingredient_tool_hero.py --spec39 --set ingredient          # 39-spec ingredient 20장
    py tools/gen_ingredient_tool_hero.py --spec39 --set tool                # 39-spec tool 9장
    py tools/gen_ingredient_tool_hero.py --spec39 --set vessel              # 39-spec vessel 10장
    py tools/gen_ingredient_tool_hero.py                                    # 전체 (음식 매핑 변형 포함, 39 초과)
    py tools/gen_ingredient_tool_hero.py --set ingredient                   # ingredient hero만
    py tools/gen_ingredient_tool_hero.py --set tool                         # tool layer (손도구)
    py tools/gen_ingredient_tool_hero.py --set vessel                       # vessel/cookware layer (용기)
    py tools/gen_ingredient_tool_hero.py --only green_onion,chef_knife      # 일부 (item id)
    py tools/gen_ingredient_tool_hero.py --priority                         # MVP 우선
    py tools/gen_ingredient_tool_hero.py --background transparent           # 투명 PNG (production 권장)
    py tools/gen_ingredient_tool_hero.py --naming legacy                    # 구 prefix 파일명

Default:
    model=gpt-image-1 / quality=medium ($0.042/img) / size=1024x1024 / out=ingredient_tool_hero_m2/
    naming=clean (green_onion_whole.png) / background=opaque (검수) — production 은 transparent 권장
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
# STYLE_SUFFIX_HERO — 모든 ingredient/tool hero prompt 끝에 부착 (%s 1개로 교체).
# Style Bible v1 §1·§2·§5 정합 + Hero Asset Mandate (ingredient-tool-art-lock.md).
# 핵심: volumetric hero (NOT flat / NOT UI icon) + warm cozy + cocoa outline + 한식 정체성.
# ─────────────────────────────────────────────────────────────────────────────
STYLE_SUFFIX_HERO = """
STYLE (HERO ASSET — NOT a UI icon):
Premium cozy mobile game art in the style of Cooking Diary, Travel Town and Merge Mansion
ITEM QUALITY — a single HERO illustrated object with real VOLUME, LIGHTING, TEXTURE and DEPTH.
This is hand-drawn 2D game illustration with soft volumetric shading: 2-3 step soft gradient
(NEVER flat single-fill, NEVER one solid color block). Rounded dimensional form, believable
thickness and depth, tactile surface texture (the natural grain of the ingredient, the wood grain
/ metal sheen / earthenware grit of a tool).

CONSISTENCY LOCK — every asset in this set MUST share the SAME look (Style Bible v1):
- LIGHTING: a single warm KEY LIGHT from the TOP-LEFT on EVERY asset (consistent direction),
  with a soft rim light and ONE or TWO small specular highlights (a gentle just-prepared /
  just-cooked sheen — NOT a glossy plastic coating). No second/opposite/flat lighting.
- OUTLINE: a warm dark COCOA outline (#3A2A1E) of consistent ~3-4px weight on EVERY asset, with
  slight hand-drawn weight variation (warm, not a cold uniform vector stroke). Same thickness
  across all items — never thicker or thinner per asset.
- CAMERA: the SAME 3/4 view with a slight overhead tilt (gentle high angle looking slightly down)
  on EVERY asset — one consistent camera angle family across the whole set (never a flat front-on
  elevation, never a pure top-down flat-lay, never a low hero angle).
- PALETTE: warm cozy muted palette (mid saturation ~55-78%), appetizing and inviting, consistent
  warmth across the set.

COMPOSITION (STANDALONE — Asset Architecture Lock: never bake co-assets together):
- A SINGLE hero object centered, occupying ~60-72% of the frame with comfortable margins.
- NO cutting board, NO knife in frame, NO pot, NO pan, NO grill, NO bowl, NO plate,
  NO hands, NO characters, NO other tools or props, NO kitchen scene, NO text, NO labels.
- This is JUST the standalone ingredient (or JUST the standalone tool) — never an ingredient
  sitting on / inside a tool, never a tool holding food. (a cooked ingredient is the cooked
  food ITSELF alone, NOT food inside a pot or on a grill — composition is done later in Godot).
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
anime, manga, watermark, any English or Korean text, Japanese or Chinese cooking-tool leak,
ingredient resting on a cutting board, ingredient inside a pot / pan / bowl / plate,
food on a grill, any second co-asset baked into the frame (this MUST be a standalone single item)."""


# ─────────────────────────────────────────────────────────────────────────────
# INGREDIENTS — hero, Raw / Prepared / Cooked variant.
# 각 항목: id / name / priority(mvp 예시 3종 우선) / variants{variant: body}.
# body 끝 %s 1개 → STYLE_SUFFIX_HERO 교체. variant key = 파일 suffix.
# ─────────────────────────────────────────────────────────────────────────────
INGREDIENTS = [
    # ── 사용자 예시 3종 (MVP 우선) ──────────────────────────────────────────
    {
        "id": "green_onion", "name": "대파 (Green Onion)", "priority": True,
        "variants": {
            "whole": """A HERO illustration of a whole fresh Korean green onion / scallion (대파):
2-3 long stalks bundled, crisp white bulb roots at the bottom fading into vivid green hollow
tubular leaves at the top, fine root hairs at the base. Show the glossy waxy surface, the
subtle vertical fiber grain of the green leaves and the layered rings at the cut white base.
Plump, fresh, dimensional and appetizing.
%s""",
            "chopped": """A HERO illustration of CHOPPED Korean green onion (대파 송송썰기) — a small
relaxed pile of finely sliced fresh scallion rounds: bright green hollow rings with little
white centers, a few thin slivers, glistening with freshness. A natural just-chopped cluster
(slight overlap, NOT a geometric grid), dimensional with soft volume on each piece, tiny
specular freshness highlights. NO cutting board, the cut pile itself is the hero.
%s""",
            "julienne": """A HERO illustration of JULIENNE / fine long-shredded Korean green onion
(대파 채썰기 / 실파채) — a small relaxed nest of long thin green-and-white scallion shreds for a
noodle garnish, fine curled slivers glistening with freshness, soft rounded volume on each
sliver, a natural just-shredded tangle (NOT a grid). NO cutting board, the shredded nest itself
is the hero.
%s""",
        },
    },
    {
        "id": "carrot", "name": "당근 (Carrot)", "priority": True,
        "variants": {
            "whole": """A HERO illustration of a whole fresh carrot (당근): a plump tapered orange root
with a smooth slightly ridged skin, faint horizontal growth rings, a clean cut top with a few
short green stem nubs. Rich warm orange with soft gradient volume, a gentle sheen on the
rounded body, fresh and crisp.
%s""",
            "sliced": """A HERO illustration of SLICED carrot coins (당근 편썰기) — a small relaxed cluster
of round orange carrot disc slices, each disc with a faint concentric ring pattern and soft
rounded edge volume, a subtle moist sheen, a few overlapping naturally (just-cut, NOT a grid).
Vivid warm orange. The sliced pile itself is the hero.
%s""",
            "julienne": """A HERO illustration of JULIENNE carrot (당근 채썰기) — a small relaxed cluster
of thin even orange matchstick strips, fresh and crisp, each strip with soft rounded volume
and a subtle moist sheen, a few strips overlapping naturally (just-cut, NOT a grid). Vivid warm
orange, tiny freshness highlights. The cut pile itself is the hero.
%s""",
            "diced": """A HERO illustration of DICED carrot (당근 깍둑썰기) — a small relaxed cluster of
small even orange cubes, fresh and crisp, each cube showing soft 3D volume with lit top faces
and shadowed sides, a few cubes overlapping naturally. Vivid warm orange, subtle moist sheen.
The diced pile itself is the hero.
%s""",
        },
    },
    {
        "id": "kimchi", "name": "김치 (Kimchi)", "priority": True,
        "variants": {
            "whole": """A HERO illustration of a whole napa cabbage Korean kimchi (포기김치): a dense
quarter-head of fermented napa cabbage coated in deep red-orange gochugaru seasoning, the
layered leaves and white ribs visible, glistening with seasoning, plump and juicy. Deep warm
Gochu red, rich layered texture, dimensional and appetizing.
%s""",
            "chopped": """A HERO illustration of CHOPPED kimchi (김치 썰기) — a small relaxed pile of
bite-sized cut fermented napa cabbage kimchi pieces, deep red-orange seasoned leaves with
visible white ribs, juicy and glistening, a natural just-cut cluster with soft volume on each
piece. The cut pile itself is the hero.
%s""",
            "cooked": """A HERO illustration of COOKED / stir-fried kimchi (볶은 김치) — a small relaxed
pile of softened, deeper-red braised kimchi pieces with a glossy cooked sheen, slightly wilted
and caramelized edges, a faint oily shine, warm and savory. Deeper Broth Red tone, soft cooked
volume. The cooked pile itself is the hero.
%s""",
        },
    },
    {
        "id": "garlic", "name": "마늘 (Garlic)", "priority": True,
        "variants": {
            "whole": """A HERO illustration of fresh garlic (마늘): a small group of 2-3 whole peeled
ivory-white garlic cloves plus one cracked clove, plump teardrop shapes with a smooth pearly
skin, soft warm cream-white with subtle gradient volume and a gentle sheen. Fresh and firm.
%s""",
            "minced": """A HERO illustration of MINCED garlic (마늘 다지기) — a small relaxed mound of
finely minced fresh garlic granules, moist ivory-cream bits with tiny specular freshness
highlights, soft dimensional mound (NOT flat scatter), just-minced and aromatic. The minced
mound itself is the hero.
%s""",
        },
    },
    # ── 음식별 hero ingredient (음식 12 매핑) ─────────────────────────────────
    {
        "id": "danmuji", "name": "단무지 (Pickled Radish)", "priority": False,
        "variants": {
            "whole": """A HERO illustration of a whole danmuji (단무지) — a long cylinder of bright yellow
Korean pickled radish, smooth glossy crisp surface with a faint translucent sheen, rounded
ends, vivid warm yellow with soft gradient volume. Fresh, crunchy, dimensional.
%s""",
            "julienne": """A HERO illustration of JULIENNE danmuji (단무지 채썰기) — a small relaxed cluster
of thin bright yellow pickled radish matchstick strips for kimbap, crisp and glossy with a
translucent sheen, each strip with soft rounded volume, a few overlapping naturally. The cut
pile itself is the hero.
%s""",
        },
    },
    {
        "id": "fish_cake", "name": "어묵 (Fish Cake)", "priority": False,
        "variants": {
            "whole": """A HERO illustration of a whole Korean fish cake sheet (어묵): a flat rounded
golden-beige fried fish paste sheet with a lightly browned mottled surface and soft pliable
edges, warm beige-gold with soft volume and a faint oily sheen. Springy and appetizing.
%s""",
            "sliced": """A HERO illustration of SLICED fish cake (어묵 어슷썰기) — a small relaxed cluster
of elongated diagonal golden-brown fish cake oval slices for tteokbokki, springy soft pieces
with lightly browned edges and a faint sheen, soft volume, a few overlapping naturally. The
cut pile itself is the hero.
%s""",
        },
    },
    {
        # 사용자 spec naming = tofu_block / tofu_cubed (firm_tofu prefix → tofu 로 정렬).
        "id": "tofu", "name": "두부 (Firm Tofu)", "priority": False,
        "variants": {
            "block": """A HERO illustration of a whole block of firm Korean tofu (두부): a soft cream-white
rectangular block with smooth slightly matte surface, gently rounded edges, a faint moist sheen
and soft dimensional shading suggesting its delicate firm-jelly body. Fresh and clean.
%s""",
            "cubed": """A HERO illustration of CUBED firm tofu (두부 깍둑썰기) — a small relaxed cluster
of soft cream-white tofu cubes with gently rounded edges, each cube showing soft 3D volume with
a lit top and shadowed side and a faint moist sheen, a few overlapping naturally. The cubed
pile itself is the hero.
%s""",
        },
    },
    {
        "id": "soft_tofu", "name": "순두부 (Soft Tofu)", "priority": False,
        "variants": {
            "whole": """A HERO illustration of soft silken Korean tofu (순두부): irregular soft cloud-like
broken curds of very delicate uncurdled white tofu (like soft custard scoops, NOT firm cubes),
glossy and jiggly with soft moist highlights, cream-white with gentle blue-cool shadow in the
folds. Delicate, dimensional, appetizing.
%s""",
        },
    },
    {
        "id": "zucchini", "name": "애호박 (Korean Zucchini)", "priority": False,
        "variants": {
            "whole": """A HERO illustration of a whole Korean zucchini (애호박): a short plump pale-green
squash, smooth glossy skin with a subtle speckled sheen, a small stem nub at one end, soft
gradient volume on the rounded body. Fresh, firm, dimensional.
%s""",
            "sliced": """A HERO illustration of SLICED Korean zucchini (애호박 통썰기) — a small relaxed
cluster of round pale-green zucchini disc slices for janchi-guksu, pale flesh with a green rim
and a faint moist sheen, each disc with soft rounded volume, a few overlapping naturally. The
sliced pile itself is the hero.
%s""",
        },
    },
    {
        "id": "somyeon", "name": "소면 (Thin Noodles)", "priority": False,
        "variants": {
            "whole": """A HERO illustration of a bundle of dried Korean thin wheat noodles (소면): a neat
cylindrical bound bundle of fine pale-cream dry noodle strands, the parallel strand texture
clearly visible, a thin paper band around the middle, warm cream tone with soft volume.
%s""",
            "cooked": """A HERO illustration of a nest of COOKED thin Korean noodles (삶은 소면): a soft
glistening twirled nest of springy white wheat noodles, freshly boiled with a wet sheen and
soft strand texture, warm cream-white with soft dimensional folds. The noodle nest itself is
the hero (no bowl, no broth).
%s""",
        },
    },
    {
        "id": "beef", "name": "얇은 소고기 (Thin Beef)", "priority": False,
        "variants": {
            "raw": """A HERO illustration of thin sliced raw marbled Korean beef (얇은 소고기): a few
draped folds of thinly sliced red beef with fine white marbling, soft pliable folds with a
fresh moist sheen, rich warm red with cream marbling, soft dimensional drape. Fresh, appetizing.
%s""",
            "marinated": """A HERO illustration of MARINATED thin beef (양념 소고기): a small relaxed pile of
thin beef slices coated in a glossy sweet-savory soy bulgogi marinade glaze, deep glossy brown
with a rich sheen, soft pliable folds, a few thin onion slivers mixed in. The marinated pile
itself is the hero.
%s""",
            "cooked": """A HERO illustration of COOKED bulgogi beef (불고기): a small relaxed pile of
glistening cooked marinated beef slices with caramelized glossy soy glaze and light char,
sprinkled with sesame and a little green onion, deep savory brown with rich sheen and soft
cooked volume. The cooked pile itself is the hero.
%s""",
        },
    },
    {
        "id": "mozzarella", "name": "모짜렐라 (Mozzarella)", "priority": False,
        "variants": {
            "whole": """A HERO illustration of a Korean corn-dog mozzarella cheese stick (모짜렐라 스틱):
a short plump rectangular block / stick of soft cream-white mozzarella with a smooth slightly
matte surface, gently rounded edges, soft moist sheen and dimensional shading. Fresh and
appetizing.
%s""",
            "cooked": """A HERO illustration of MELTED stretchy mozzarella (녹은 모짜렐라): a glossy warm
cream-gold pull of melted mozzarella cheese stretching into soft strands with a rich gooey
sheen, soft dimensional volume and bubbly browned spots. Warm, gooey, appetizing. The cheese
pull itself is the hero.
%s""",
        },
    },
    # ── 39-spec 누락 ingredient 추가 (2026-06-06 art-driver 확장) ───────────────
    {
        # 사용자 spec naming = egg_whole / egg_cooked.
        "id": "egg", "name": "달걀 (Egg)", "priority": False,
        "variants": {
            "whole": """A HERO illustration of a whole raw chicken egg (날달걀): a single smooth ovoid
egg with a warm cream-beige shell, a soft satin sheen and a gentle 2-3 step gradient giving real
rounded volume, top-left key light with a small specular highlight and a soft warm shadow on the
underside. Clean, fresh, dimensional (NOT a flat oval icon). The whole egg itself is the hero.
%s""",
            "cooked": """A HERO illustration of a COOKED sunny-side-up fried egg (계란 후라이): a single
fried egg with a glossy domed golden-orange yolk and a soft glistening cooked white with lightly
crisped lacy browned edges, a warm wet sheen and soft dimensional volume on the puffed white.
Appetizing and just-cooked. NO pan, NO plate — the fried egg itself is the standalone hero.
%s""",
        },
    },
    {
        # 사용자 spec naming = rice_bowl (id=rice + state=bowl → rice_bowl.png).
        # 주의: ingredient 로 분류 — 밥 자체(흰밥 mound). 그릇은 별도 Vessel(noodle_bowl/brass_bowl 등).
        "id": "rice", "name": "밥 (Steamed Rice)", "priority": False,
        "variants": {
            "bowl": """A HERO illustration of a HEAPED MOUND of steamed Korean short-grain white rice
(흰쌀밥 한 공기 분량의 밥 자체) — a soft rounded dome of glistening sticky fluffy white rice, the many
individual plump grains visible with a gentle moist steamed sheen, warm cream-white with soft
top-left key light and tender dimensional volume. IMPORTANT: this is JUST the rice mound itself —
NO bowl, NO dish, NO plate, NO vessel under or around it (the bowl is a separate Vessel asset);
the rice pile alone is the standalone hero (the filename says bowl but render only the rice).
%s""",
        },
    },
    {
        # 사용자 spec naming = noodle_raw / noodle_cooked. somyeon 과 별도 (사용자 spec 우선).
        # noodle = 범용 면 (somyeon=소면 전용 hero 와 병존; 39-spec 은 noodle_raw/cooked 명칭 사용).
        "id": "noodle", "name": "면 (Noodles)", "priority": False,
        "variants": {
            "raw": """A HERO illustration of a bundle of RAW dried wheat noodles (생/마른 면): a neat
cylindrical bound bundle of fine straight pale-cream dry noodle strands, the parallel strand
texture clearly visible, a thin band around the middle, warm cream tone with soft top-left key
light and gentle rounded volume on the bundle. NO bowl, NO water — the dry noodle bundle itself
is the standalone hero. (Generic noodle bundle, slightly thicker/longer than 소면 somyeon.)
%s""",
            "cooked": """A HERO illustration of a nest of COOKED boiled noodles (삶은 면): a soft glistening
twirled nest of springy just-boiled wheat noodles with a wet sheen and soft strand texture, warm
cream-white with soft dimensional folds and top-left key light. NO bowl, NO broth, NO toppings —
the cooked noodle nest itself is the standalone hero.
%s""",
        },
    },
]


# ─────────────────────────────────────────────────────────────────────────────
# TOOLS (L-TOOL) — 손에 쥐는 도구 hero. 각 항목: id / name / body (끝 %s 1개).
# Style Bible 톤 (warm metal/wood + cocoa outline + soft volumetric) + 한식 정체성.
# v2 (art-pipeline-correction): knife→chef_knife rename, cutting_board / rolling_mat
# 신규 추가 (legacy 에서 재료와 baked 또는 mockup 이라 standalone 필요).
# ─────────────────────────────────────────────────────────────────────────────
TOOLS = [
    {
        "id": "chef_knife", "name": "Chef Knife (식칼)",
        "body": """A HERO illustration of a single Korean kitchen knife (식칼), 3/4 view: a wide
slightly tall steel blade with a soft satin sheen and a clean bevel edge, a smooth warm-brown
wood handle with a visible riveted bolster and gentle wood grain. The blade catches a soft
key-light specular along its spine; the handle has warm rounded volume. Resting at a relaxed
angle, dimensional and tactile (NOT a flat blade silhouette).
%s""",
    },
    {
        "id": "cutting_board", "name": "Cutting Board (도마)",
        "body": """A HERO illustration of a single empty wooden cutting board (도마), tilted top-down
3/4 view: a thick warm-oak rectangular board with rounded corners and a small hanging hole or
handle notch at one end, rich believable wood grain flowing along its length, a soft beveled
edge showing the board's real thickness. Top-left key light with a soft sheen on the surface and
a warm shadow along the near edge giving it weight and depth. This is JUST the empty board — NO
knife, NO ingredient, NO food, NO chopped pile on it. Dimensional and tactile (NOT a flat wood
rectangle icon).
%s""",
    },
    {
        "id": "rolling_mat", "name": "Rolling Mat (김발)",
        "body": """A HERO illustration of a single Korean bamboo rolling mat (김발 / 발), tilted top-down
3/4 view: a partially unrolled mat of many thin parallel round bamboo sticks tied with cotton
string, warm natural bamboo tone with each stick showing cylindrical volume and a soft sheen, a
gently curled end suggesting it rolls up. Top-left key light and a soft contact shadow for depth.
This is JUST the empty mat — NO rice, NO seaweed, NO kimbap, NO food on it. Dimensional and
tactile (NOT a flat striped pattern icon).
%s""",
    },
    {
        "id": "ladle", "name": "Ladle (국자)",
        "body": """A HERO illustration of a single Korean stainless ladle (국자), 3/4 view: a deep
round half-sphere bowl with a warm brushed-metal sheen and soft reflected light inside the
cavity, joined to a long slim handle with a small hanging loop at the tip. Believable metallic
volume and depth, a soft specular highlight along the bowl rim and handle. Dimensional and
tactile (NOT a flat metal icon).
%s""",
    },
    {
        "id": "spatula", "name": "Spatula (주걱)",
        "body": """A HERO illustration of a single Korean stir-fry spatula / turner (주걱), 3/4 view:
a wide slightly angled stainless paddle with a soft satin sheen and a couple of subtle vent
slots, joined to a long warm-brown wood handle with gentle grain and a rounded grip end. The
paddle has real thickness and a soft key-light highlight; the wood handle has warm rounded
volume. Dimensional and tactile (NOT a flat paddle icon).
%s""",
    },
    {
        "id": "tongs", "name": "Tongs (집게)",
        "body": """A HERO illustration of a single pair of Korean kitchen tongs (집게), 3/4 view: a
two-arm spring-loaded stainless tool with slightly open flared gripping tips, a small pivot
hinge at the top, and a soft warm grip band on the upper arms. Brushed-metal sheen with soft
key-light specular strips along the arms, believable round metal volume and depth between the
two arms. Dimensional and tactile (NOT a flat two-line icon).
%s""",
    },
    # ── 39-spec 누락 tool 추가 (2026-06-06 art-driver 확장) ────────────────────
    {
        "id": "seasoning_bottle", "name": "Seasoning Bottle (양념 통/병)",
        "body": """A HERO illustration of a single Korean kitchen seasoning bottle (양념 통 / 조미료 병),
3/4 view: a clear or warm-amber glass condiment bottle with a clean rounded shoulder, a darker
warm-toned pour cap or shaker lid on top, holding a warm reddish-amber sauce or seasoning inside
visible through the glass with a soft translucent sheen and a glassy specular highlight along the
body. Top-left key light, believable cylindrical volume and depth. This is JUST the standalone
bottle — NO food, NO ingredient, NO label text. Dimensional and tactile (NOT a flat bottle icon).
%s""",
    },
    {
        "id": "spoon", "name": "Spoon (숟가락)",
        "body": """A HERO illustration of a single Korean stainless spoon (숟가락), 3/4 view: a long
slim flat-ish handle joined to a shallow rounded oval bowl, warm brushed-silver metal with a soft
satin sheen and a gentle key-light specular running along the handle and across the bowl, a soft
reflected warm tone inside the shallow scoop. Believable metallic volume and thickness. This is
JUST the standalone spoon — NO food, NO other utensil. Dimensional and tactile (NOT a flat
metal-spoon icon).
%s""",
    },
    {
        "id": "chopsticks", "name": "Chopsticks (젓가락)",
        "body": """A HERO illustration of a single pair of Korean metal chopsticks (젓가락), 3/4 view:
two slim flattened stainless chopsticks lying together at a relaxed slight angle, slightly tapered
to rounded tips, a subtle decorative textured pattern near the thicker top ends, warm brushed-
silver metal with a soft satin sheen and crisp key-light specular strips along each stick, each
chopstick showing real rounded thickness and a soft contact shadow for depth. This is JUST the
standalone chopsticks pair — NO food, NO bowl, NO other utensil. Dimensional and tactile (NOT a
flat two-line icon).
%s""",
    },
]


# ─────────────────────────────────────────────────────────────────────────────
# VESSELS (L-VES — Vessel/Cookware) — 음식을 담는/끓이는 용기 hero.
# v2 신규 분리 (Tool 에서 분리): pot/dolsot/grill_pan = Vessel 재분류, frying_pan/
# mixing_bowl 신규. 모두 EMPTY 용기 (국물/음식/재료 baked 금지 — 내용물은 L-ING 별도 노드).
# ─────────────────────────────────────────────────────────────────────────────
VESSEL_EMPTY = ("This is an EMPTY vessel — the inner cavity is empty and clean, with NO soup, "
                "NO broth, NO food, NO ingredient inside (contents are composited later in "
                "Godot as a separate Ingredient layer). ")

VESSELS = [
    {
        "id": "pot", "name": "Pot (냄비)",
        "body": """A HERO illustration of a single EMPTY Korean home cooking pot (냄비), 3/4 view: a
rounded silver yangun aluminum-tin pot with two small ear handles on opposite sides and an open
round top showing the empty inner cavity. Warm brushed-metal body with a soft 2-3 step gradient
giving real cylindrical volume, a gentle key-light specular along the upper rim, and a soft
reflected warm tone inside. """ + VESSEL_EMPTY + """Believable depth and weight, warm and cozy
(NOT a flat clip-art pot icon, NOT a cold uniform gray fill).
%s""",
    },
    {
        "id": "dolsot", "name": "Dolsot (뚝배기)",
        "body": """A HERO illustration of a single EMPTY Korean dolsot / ttukbaegi earthenware pot
(뚝배기), 3/4 view: a rounded rustic Korean stone-clay pot in warm charcoal earthenware (Dolsot
Charcoal #4A3B30, warm dark — NOT pure black), with a gritty matte ceramic texture, a thick
rounded rim and two small side lugs, an open top showing the empty inner cavity. Real volumetric
clay form with top-left key light, soft warm rim light, gentle surface grit texture and a soft
warm reflection inside. """ + VESSEL_EMPTY + """This is the signature Korean stew pot — earthy,
weighty, cozy and dimensional (NOT a flat black icon, NOT a glossy ceramic).
%s""",
    },
    {
        "id": "frying_pan", "name": "Frying Pan (프라이팬)",
        "body": """A HERO illustration of a single EMPTY frying pan / stir-fry pan (프라이팬), tilted
top-down 3/4 view: a round shallow pan with a dark matte non-stick interior and a warm
brushed-steel outer rim, joined to a single long warm-brown wood or black handle. The pan shows
real bowl depth and cylindrical volume, a soft key-light sheen along the rim and a gentle warm
reflection across the empty interior. """ + VESSEL_EMPTY + """Dimensional and tactile (NOT a flat
circle-with-stick icon).
%s""",
    },
    {
        "id": "grill_pan", "name": "Grill Pan / Grate (석쇠)",
        "body": """A HERO illustration of a single Korean BBQ grill grate (석쇠), tilted top-down 3/4
view: a round wire-mesh grilling grate of crossed silver-steel wires with a thicker outer rim
ring, each wire showing cylindrical metal volume and a soft key-light sheen. A subtle warm
red-orange charcoal glow washes softly through the mesh gaps from underneath (warm ambient, no
visible flames), grounding it with depth. This is JUST the empty grate — NO meat, NO food on it.
The signature round Korean BBQ grate — metallic, dimensional and tactile (NOT a flat grid
pattern icon).
%s""",
    },
    {
        "id": "mixing_bowl", "name": "Mixing Bowl (양푼)",
        "body": """A HERO illustration of a single EMPTY large Korean mixing bowl (양푼 / 비빔 그릇),
3/4 view: a wide deep round metal yangpun bowl with a warm brushed-silver or soft enamel finish,
a gently flared rim and a rounded base, the open top showing the empty inner cavity with a soft
warm reflection inside. Real bowl depth and rounded volume, a soft key-light specular along the
rim. """ + VESSEL_EMPTY + """Dimensional and tactile (NOT a flat gray bowl clip-art icon).
%s""",
    },
    # ── 39-spec 누락 vessel 추가 (2026-06-06 art-driver 확장) ──────────────────
    {
        "id": "noodle_bowl", "name": "Noodle Bowl (면 그릇)",
        "body": """A HERO illustration of a single EMPTY Korean noodle bowl (면 그릇 / 국수 대접), 3/4 view:
a wide deep round ceramic noodle bowl with a gently flared rim and a small foot ring base, a warm
glazed off-white or soft celadon finish with a clean glossy sheen, the open top showing the empty
inner cavity with a soft warm reflection inside. Real generous bowl depth and rounded ceramic
volume, top-left key light with a soft specular along the rim. """ + VESSEL_EMPTY + """Dimensional
and tactile (NOT a flat bowl clip-art icon).
%s""",
    },
    {
        "id": "brass_bowl", "name": "Brass Bowl (놋그릇)",
        "body": """A HERO illustration of a single EMPTY traditional Korean brass bowl (놋그릇 / 유기),
3/4 view: a round footed bangjja brassware bowl in warm rich golden-bronze metal with a soft
hand-burnished satin sheen, gentle hammered surface texture catching the light, a slightly flared
rim and a small pedestal foot, the open top showing the empty inner cavity with a warm golden
reflection inside. Real metallic volume and depth, top-left key light with soft brass specular.
""" + VESSEL_EMPTY + """Premium, warm and weighty (NOT a flat gold clip-art bowl, NOT a mirror-
chrome reflection).
%s""",
    },
    {
        "id": "wooden_tray", "name": "Wooden Tray (나무 쟁반)",
        "body": """A HERO illustration of a single EMPTY Korean wooden serving tray (나무 쟁반 / 소반 상판),
tilted top-down 3/4 view: a rectangular or gently rounded warm-oak wooden tray with a low raised
lip rim, rich believable wood grain flowing along its surface, a soft beveled edge showing real
thickness, and small notched handle cutouts at the short ends. Top-left key light with a soft
sheen on the surface and a warm shadow along the near edge for weight and depth. """ + VESSEL_EMPTY + """
This is JUST the empty tray — NO food, NO bowl, NO dish on it. Dimensional and tactile
(NOT a flat wood rectangle icon).
%s""",
    },
    {
        "id": "wide_plate", "name": "Wide Plate (넓은 접시)",
        "body": """A HERO illustration of a single EMPTY wide round serving plate (넓은 접시), tilted
top-down 3/4 view: a broad shallow ceramic plate with a gently sloping well and a wide flat rim,
a clean warm glazed off-white finish with a soft glossy sheen and a subtle key-light reflection
across the surface, a small foot ring giving it lift. Real shallow dish depth and rounded ceramic
volume, top-left key light with a soft specular along the rim. """ + VESSEL_EMPTY + """This is JUST
the empty plate — NO food on it. Dimensional and tactile (NOT a flat disc icon).
%s""",
    },
    {
        "id": "earthenware_bowl", "name": "Earthenware Bowl (질그릇/옹기)",
        "body": """A HERO illustration of a single EMPTY Korean earthenware bowl (질그릇 / 옹기 대접),
3/4 view: a round rustic glazed-clay onggi-style bowl in warm earthy terracotta-brown with a
gritty matte ceramic texture and subtle glaze pooling, a thick rounded rim and a sturdy rounded
base, the open top showing the empty inner cavity with a soft warm reflection inside. Real
volumetric clay form, top-left key light, soft warm rim light and gentle surface grit. """ + VESSEL_EMPTY + """
Earthy, weighty, cozy and dimensional (NOT a flat brown bowl icon, NOT a glossy modern ceramic).
%s""",
    },
]


# ─────────────────────────────────────────────────────────────────────────────
# SPEC39 — 사용자 LOCKED 정확 39 standalone asset (20 ingredient + 9 tool + 10 vessel).
# --spec39 플래그로 정확히 이 39장만 생성 (driver 의 extra hero 음식 12-매핑 변형은 제외).
# 각 엔트리는 (kind, id, variant) — 출력 파일명은 build_filename(clean) 으로 사용자 spec naming.
# ─────────────────────────────────────────────────────────────────────────────
SPEC39_INGREDIENTS = [  # 20 → {id}_{state}.png
    ("green_onion", "whole"), ("green_onion", "chopped"), ("green_onion", "julienne"),
    ("carrot", "whole"), ("carrot", "sliced"), ("carrot", "julienne"), ("carrot", "diced"),
    ("kimchi", "whole"), ("kimchi", "chopped"), ("kimchi", "cooked"),
    ("tofu", "block"), ("tofu", "cubed"),
    ("beef", "raw"), ("beef", "marinated"), ("beef", "cooked"),
    ("egg", "whole"), ("egg", "cooked"),
    ("rice", "bowl"),
    ("noodle", "raw"), ("noodle", "cooked"),
]
SPEC39_TOOLS = [  # 9 → {tool}.png
    "chef_knife", "cutting_board", "ladle", "spatula", "tongs", "rolling_mat",
    "seasoning_bottle", "spoon", "chopsticks",
]
SPEC39_VESSELS = [  # 10 → {vessel}.png
    "pot", "dolsot", "frying_pan", "grill_pan", "mixing_bowl",
    "noodle_bowl", "brass_bowl", "wooden_tray", "wide_plate", "earthenware_bowl",
]


def build_prompt(body: str) -> str:
    """body의 첫 %s를 STYLE_SUFFIX_HERO로 교체 (.replace로 다른 % 안전 보존)."""
    return body.replace("%s", STYLE_SUFFIX_HERO, 1)


def collect_jobs(which_set: str, only: set | None, priority_only: bool,
                 spec39: bool = False):
    """(kind, item_id, variant_or_none, name, prompt_body) 작업 리스트 생성.
    spec39=True → 사용자 LOCKED 39 항목(20+9+10)만, spec 순서대로."""
    ing_index = {ing["id"]: ing for ing in INGREDIENTS}
    tool_index = {t["id"]: t for t in TOOLS}
    vessel_index = {v["id"]: v for v in VESSELS}

    if spec39:
        jobs = []
        if which_set in ("ingredient", "all"):
            for item_id, variant in SPEC39_INGREDIENTS:
                if only and item_id not in only:
                    continue
                ing = ing_index[item_id]
                jobs.append(("ing", item_id, variant, ing["name"],
                             ing["variants"][variant]))
        if which_set in ("tool", "all"):
            for item_id in SPEC39_TOOLS:
                if only and item_id not in only:
                    continue
                tool = tool_index[item_id]
                jobs.append(("tool", item_id, None, tool["name"], tool["body"]))
        if which_set in ("vessel", "all"):
            for item_id in SPEC39_VESSELS:
                if only and item_id not in only:
                    continue
                vessel = vessel_index[item_id]
                jobs.append(("vessel", item_id, None, vessel["name"], vessel["body"]))
        return jobs

    jobs = []
    if which_set in ("ingredient", "all"):
        for ing in INGREDIENTS:
            if only and ing["id"] not in only:
                continue
            if priority_only and not ing.get("priority"):
                continue
            for variant, body in ing["variants"].items():
                jobs.append(("ing", ing["id"], variant, ing["name"], body))
    if which_set in ("tool", "all"):
        for tool in TOOLS:
            if only and tool["id"] not in only:
                continue
            jobs.append(("tool", tool["id"], None, tool["name"], tool["body"]))
    if which_set in ("vessel", "all"):
        for vessel in VESSELS:
            if only and vessel["id"] not in only:
                continue
            jobs.append(("vessel", vessel["id"], None, vessel["name"], vessel["body"]))
    return jobs


def build_filename(kind: str, item_id: str, variant: str | None,
                   naming: str, version: str) -> str:
    """파일명 생성. naming=clean → {id}_{state}.png / {id}.png (사용자 convention).
    naming=legacy → ing_{id}_{variant}_{version}.png / tool_{id}_{version}.png."""
    if naming == "legacy":
        if kind == "ing":
            return f"ing_{item_id}_{variant}_{version}.png"
        prefix = "tool" if kind == "tool" else "vessel"
        return f"{prefix}_{item_id}_{version}.png"
    # clean (사용자 naming convention, art-pipeline-correction §DELIVERABLE 3)
    if kind == "ing":
        return f"{item_id}_{variant}.png"
    return f"{item_id}.png"


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Ingredient & Tool HERO art 생성 (volumetric hero reskin — NOT UI icon)"
    )
    parser.add_argument("--set", default="all",
                        choices=["all", "ingredient", "tool", "vessel"],
                        help="생성 세트: all / ingredient / tool(손도구) / vessel(용기)")
    parser.add_argument("--naming", default="clean", choices=["clean", "legacy"],
                        help="clean=green_onion_whole.png (사용자 convention) / "
                             "legacy=ing_green_onion_whole_v1.png (구 prefix)")
    parser.add_argument("--only", type=str, default="",
                        help="콤마구분 item id만 (예: green_onion,chef_knife,mixing_bowl)")
    parser.add_argument("--priority", action="store_true",
                        help="MVP 우선 (ingredient priority 3종 + tool 세트에 따름)")
    parser.add_argument("--spec39", action="store_true",
                        help="사용자 LOCKED 정확 39 항목만 (20 ingredient + 9 tool + 10 vessel). "
                             "--set 와 조합 가능 (--spec39 --set ingredient = ing 20장).")
    parser.add_argument("--model", default="gpt-image-1", choices=["dall-e-3", "gpt-image-1"])
    parser.add_argument("--size", default="1024x1024")
    parser.add_argument("--quality", default="medium",
                        help="gpt-image-1: low/medium/high/auto")
    parser.add_argument("--background", default="opaque",
                        choices=["transparent", "opaque", "auto"],
                        help="transparent=알파 PNG / opaque=Cream bg")
    parser.add_argument("--version", default="v1", help="파일명 suffix")
    parser.add_argument("--out-dir", type=Path,
                        default=PROJECT_ROOT / "assets-raw" / "ingredient_tool_hero_m2")
    args = parser.parse_args()

    only = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    jobs = collect_jobs(args.set, only, args.priority, spec39=args.spec39)

    if not jobs:
        sys.exit("❌ 매칭 작업 없음 (--set / --only / --priority / --spec39 확인)")

    args.out_dir.mkdir(parents=True, exist_ok=True)

    unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
    if args.model == "dall-e-3":
        unit = 0.080 if args.quality == "hd" else 0.040
    else:
        unit = unit_map.get(args.quality, 0.042)
    est_total = unit * len(jobs)

    print("=" * 72)
    print("🍳 Ingredient & Tool HERO art 생성 (volumetric hero — Cooking Diary/Merge item quality)")
    print(f"   세트={args.set} spec39={args.spec39} priority={args.priority} "
          f"only={sorted(only) if only else '-'}")
    print(f"   모델={args.model} 품질={args.quality} 사이즈={args.size} 배경={args.background}")
    print(f"   대상: {len(jobs)}장  비용예상: ${unit:.3f}/장 × {len(jobs)} = ${est_total:.2f}")
    print(f"   출력: {args.out_dir}")
    print("=" * 72)

    client = OpenAI(api_key=load_api_key())
    successes, failures = [], []
    t0 = time.time()

    for i, (kind, item_id, variant, name, body) in enumerate(jobs, 1):
        fname = build_filename(kind, item_id, variant, args.naming, args.version)
        label = f"{name} [{variant}]" if kind == "ing" else f"{name} ({kind})"
        out_path = args.out_dir / fname
        prompt = build_prompt(body)

        print(f"\n[{i}/{len(jobs)}] {label} → {fname}")
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
    print("=" * 72)


if __name__ == "__main__":
    main()
