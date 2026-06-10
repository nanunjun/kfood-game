"""
K-Food Master — Player Protagonist (Chef Avatar) Pack — Gender Select.

플레이어 셰프 주인공 아바타 2종 (여자 + 남자) — 성별 선택 (gender select).
2 chef × N emotion = 6 (or 8) PNG. transparent-native.

═══════════════════════════════════════════════════════════════════════════════
사용자 LOCK (이 driver 의 헌법):
  - assets-raw/style/north_star_hanhana_v1.png 의 "한하나" = STYLE 예시일 뿐.
    그대로 주인공으로 쓰면 안 됨. north star 는 톤/렌더 품질/주방 세계감 기준
    (warm storybook, cocoa outline, soft volumetric, 한식 주방 정체성)으로만 활용.
  - 주인공 = 플레이어 아바타, 성별 선택 → 여자 셰프 1종 + 남자 셰프 1종 (둘 다 필요).
    한하나 복제 X — 신규 정체성 (헤어/얼굴/복장 색 차별화).
  - 두 캐릭터는 같은 시각 언어 (성별만 다르고 톤/렌더/outline 일관 — 나란히 놔도 한 게임).
  - name tag / 자수 텍스트 art 회피 (i18n icon-first lock — 텍스트 생성 금지).
    → 한하나의 "꽃가마 한식 셰프" 자수, 태극기 patch 텍스트류는 신규 주인공에 넣지 않음.
  - transparent-native 생성 (검은 smudge / dark-halo / cutout artifact 회피).
═══════════════════════════════════════════════════════════════════════════════

NORTH STAR = STYLE SEED ONLY (NOT 캐릭터 복제):
  north_star_hanhana_v1.png 를 reference image 로 upload(--style-seed) 하면 Phase B
  neutral 을 client.images.edit() 로 생성 — north star 의 톤/렌더/outline/주방 세계감을
  style anchor 로 흡수하되, prompt 가 신규 캐릭터 정체성(헤어/얼굴/복장 색)을 강제.
  --style-seed 미지정 시 prompt-only generate (북극성 톤을 텍스트로만 재현).
  ⚠ 캐릭터 복제 방지: identity_prompt 가 한하나와 명백히 다른 헤어/복장/색을 강제하고,
    STYLE_SUFFIX 에 "한하나(분홍 꽃핀/세이지 앞치마/태극기 모자/자수 텍스트) 복제 금지"를 박음.

스타일 정합 (north star = Style Bible v2, style-north-star-v1.md):
  warm storybook 한식 주방 정체성, soft volumetric 2-tone cel shading, cocoa #3A2A1E
  outline 3-4px (순흑 X), top-left soft volumetric light, warm 팔레트(55-78% sat),
  warm peach blush. NOT flat vector, NOT photoreal, NOT 3D, NOT cool-mint, NOT
  over-saturated. style-bible-v1 §1-§4 + style-north-star-v1 §1-§3 정합.

2-pass (gen_character_pack.py 패턴 계승):
  Phase B = neutral 2종 (identity anchor seed). --style-seed 면 edit(north_star),
            아니면 generate(prompt-only). transparent-native.
  Phase C = emotion image-edit (client.images.edit, base = Phase B neutral),
            8-attribute IDENTITY LOCK (skin/hair/eye/clothing/accent/silhouette/
            line weight/shading 픽셀-동일 톤) + transparent. 표정/포즈만 변경.

Emotion set (gameplay 매핑):
  base/neutral   — 호스트 정면 (메뉴/타이틀)            [Phase B]
  cheer/happy    — 성공/결과 호스트                      [Phase C]
  think/focused  — tutorial / 조리 가이드                [Phase C]
  cook/present   — 조리 동작 또는 음식 들고 present (선택) [Phase C, --with-cook]
  → 여 4 + 남 4 = 8 (cook 생략 시 여 3 + 남 3 = 6).

Usage:
    # Phase B test — 1 chef neutral 먼저 (visual check before batch)
    py tools/gen_protagonist_pack.py --phase B --only chef_f --quality medium ^
        --background transparent --style-seed assets-raw/style/north_star_hanhana_v1.png

    # Phase B both neutral (north star style seed)
    py tools/gen_protagonist_pack.py --phase B --quality medium ^
        --background transparent --style-seed assets-raw/style/north_star_hanhana_v1.png

    # Phase C emotion variants (needs Phase B neutral; 기본 cheer+think = 4)
    py tools/gen_protagonist_pack.py --phase C --quality medium --background transparent

    # Phase C + cook/present (6 → 8)
    py tools/gen_protagonist_pack.py --phase C --with-cook --quality medium ^
        --background transparent

    # Full batch (2 neutral + emotion) — neutral 검수 후 권장
    py tools/gen_protagonist_pack.py --phase ALL --with-cook --quality medium ^
        --background transparent --style-seed assets-raw/style/north_star_hanhana_v1.png

Default:
    model    = gpt-image-1
    quality  = medium ($0.042/img)
    size     = 1024x1024 (square 1:1, avatar bust)
    out_dir  = assets-raw/protagonist_pack_m2/
    version  = v1
    파일명   = {chef_id}_{emotion}_{version}.png  (예: chef_f_neutral_v1.png)
"""

import argparse
import base64
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
# STYLE_SUFFIX_PROTAGONIST — 2 chef × N emotion 공통 suffix.
# north star (style-north-star-v1.md = Style Bible v2) 톤/렌더 정합 + 한하나 복제
# 금지 + 텍스트 art 금지 (i18n icon-first lock). style-bible-v1 §1-§4 계승.
# ─────────────────────────────────────────────────────────────────────────────
STYLE_SUFFIX_PROTAGONIST = """Format: square 1:1.
View: bust-up portrait (head and shoulders / upper chest only, NOT full body —
framed from chest up, player avatar usage). Single subject per image, centered.

Style: warm cozy premium-casual mobile game character portrait — a young Korean
restaurant chef inside a warm Korean home-kitchen world (the K-Food Master north
star tone). Cooking Diary warm kitchen friendliness + Animal Restaurant hand-drawn
storybook warmth + soft volumetric shading. Clean 2D hand-drawn casual illustration.
NOT Royal Match over-saturated glossy, NOT hyper-casual flat single-fill, NOT flat
vector, NOT photorealistic, NOT 3D render.

PROPORTIONS (storybook chibi, friendly but not childish — north star P3
"cute but not childish"):
- Head-to-body ratio approximately 1 to 1.4 to 1.7 (friendly slightly-large head,
  visible shoulders/chest in the bust frame). Adult young chef, NOT a toddler.
- Hands (if visible in the bust frame) are simple rounded mitten / nub shapes — NO
  individual finger detail (avoid gpt-image-1 finger artifacts).

EYES + FACE (storybook warmth — soft, expressive, clean):
- Soft round friendly eyes — warm brown irises with a SINGLE tiny white highlight
  point inside each (storybook warmth — NOT plain flat dots, NOT enlarged anime
  shoujo pupils with multiple sparkle stars inside). Eye shape modulates per emotion.
- A very small nose cue (a tiny dot or short single arc — storybook warmth).
- Soft warm PEACH cheek blush (#E89A7A at about 35-45% — warm peach, NOT cool pink,
  NOT deep dark frosting pink) lightly on the cheeks.
- Mouth: simple arc (smile) / O (joy) / soft pressed line (focused) per emotion.

OUTLINE + SHADING (north star LOCK — shared across the whole game's art):
- Outer outline 3 to 4px in Cocoa #3A2A1E (warm dark, NOT pure black). Slightly
  hand-drawn feel allowed (Animal Restaurant warmth), NOT a cold uniform vector line.
- Soft 2-tone cel shading: base color + a soft shadow at base color × 0.85 with a
  gentle gradient boundary, on hair / chef jacket / apron / face. NOT hyper-casual
  single-fill, NOT Royal Match multi-layer glossy — the warm middle.
- Soft VOLUMETRIC light from the TOP-LEFT: one subtle soft highlight on the hair and
  one on the shoulder of the chef jacket (subtle, warm, much less glossy than food).

CHEF COSTUME (the shared profession identity for BOTH chefs):
- A chef jacket (cook's coat) plus an apron — this is the player-chef look. Keep the
  jacket and apron CLEAN, soft, simple — NO embroidery text, NO name tag, NO printed
  logo, NO flag patch, NO badge with letters.

COLOR (north star warm restraint — 55 to 78% saturation, muted cozy, NOT Royal
Match 80-90% over-saturated punch). 2 to 3 color blocks max on the costume.

BACKGROUND:
- (When transparent override is appended below) render on a FULLY TRANSPARENT
  background (alpha PNG). Otherwise a SOLID warm Rice Cream #FBF3E4 background with
  one soft warm Cocoa #3A2A1E ellipse shadow (18-25% alpha) under the bust.

DO NOT COPY THE NORTH STAR MASCOT "한하나" (Hanhana). The north star reference is a
STYLE SEED ONLY (tone / render quality / cocoa outline / kitchen world feel). This is
a NEW, DIFFERENT player-chef character. Specifically DO NOT reproduce: the pink flower
hairpin, the sage-mint apron with embroidered text, the chef hat with a taegukgi flag
patch, or any "꽃가마"/"한하나" lettering. The new chef's hair, face, and costume
colors are defined in the identity block and MUST be visibly different from Hanhana.

Important: avoid cool-mint / teal / cool-sage dominant background, beige void (empty
beige), Royal Match style, glossy plastic, over-saturated neon, hyper-casual flat
single-color fill, scrapbook noise / grunge / kraft paper / vintage texture,
golden-hour overexposed, sunset dramatic lighting, Cookie Run frosting style, Toca
Boca, Toon Blast over-cartoony, deep dark pink cheek, heavy blush, cool pink blush,
anime girl / manga style, big sparkly anime-style eyes (any sparkle accent stays a
SEPARATE small floating geometric icon OUTSIDE the eye, NOT enlarged shoujo pupils
inside), school uniform, fanservice or sexy elements, photorealistic rendering, 3D
render, octane / unreal engine, painterly watercolor, gradient mesh, multi-layer
complex glossy shading, individual finger detail (mitten / nub hands only), Japanese
(kimono, geisha, yukata, sushi) / Chinese (qipao, hanfu, cheongsam, chinese knot) /
Western cowboy hat, Korean formal ceremonial hanbok (this is a modern chef in a chef
jacket + apron), sleeping / eyes-closed-peaceful (happy closed-arc eyes are upward
HAPPY smile-strokes, NOT sad sleeping closed eyes), crying tears / teardrop falling /
sad sobbing, full body / lower body / legs / feet (bust-up only — arms/hands may
extend into the bust frame for raised-hand or food-holding gestures), multiple
characters in one image, ANY English or Korean text legibly readable (NO speech
bubbles, NO captions, NO name labels, NO embroidered text, NO flag/badge lettering —
the chef stands alone, all text is added later as Godot UI overlay)."""


# ─────────────────────────────────────────────────────────────────────────────
# 2 PROTAGONIST CHEFS — 여자 셰프 + 남자 셰프. 신규 정체성 (한하나 복제 X).
# 같은 시각 언어 (cocoa outline / soft volumetric / warm palette / storybook 얼굴)
# — 성별 + 헤어 + 복장 색만 다르게. 나란히 놔도 한 게임 = gender select 2종.
#
# 한하나 (north star) 와의 차별화:
#   한하나 = 단발/묶음 진갈색 + 분홍 꽃핀 + 세이지 앞치마 + 태극기 chef hat + 자수.
#   → 신규 여 셰프 = 다른 헤어(낮은 포니테일)·다른 복장 색(테라코타/감 톤 앞치마)·
#     꽃핀 없음·자수 없음·flag 없음(또는 plain bandana).
#   → 신규 남 셰프 = 짧은 단정 헤어·딥블루/네이비 셰프 자켓·plain 앞치마.
# ─────────────────────────────────────────────────────────────────────────────
PROTAGONISTS = [
    {
        "id": "chef_f",
        "display_name": "Female Player Chef",
        "gender": "female",
        "silhouette": "low side ponytail, plain headband (no flower pin)",
        "color": "warm persimmon / terracotta apron over a warm cream chef jacket",
        "identity_prompt": """The character is the FEMALE PLAYER CHEF — a young Korean
woman chef in her 20s, the player's own avatar (gender-select option 1). She is warm,
friendly, capable and welcoming. SILHOUETTE ANCHOR: shoulder-length dark brown hair
tied in a soft LOW SIDE PONYTAIL (a few loose front strands), with a simple plain
fabric HEADBAND or chef bandana across the forehead (NO flower hairpin — she must read
clearly DIFFERENT from the north-star mascot Hanhana). Round soft friendly face, warm
brown eyes, warm peach cheeks, an open warm smile. COSTUME / COLOR ANCHOR: a warm
CREAM / off-white chef jacket (cook's coat, soft, no embroidery, no name tag) under a
warm PERSIMMON-to-TERRACOTTA apron (fill the apron with Persimmon #E8732C softened
toward terracotta #A0552E — a warm appetizing red-orange apron block, the clear color
identity that distinguishes the female chef; clearly NOT Hanhana's sage-mint apron).
A simple plain apron with at most one small clean pocket — NO printed text, NO logo,
NO flag patch. The vibe is a friendly capable home-kitchen chef ready to cook with
the player.""",
    },
    {
        "id": "chef_m",
        "display_name": "Male Player Chef",
        "gender": "male",
        "silhouette": "short neat dark hair, optional small chef bandana",
        "color": "deep navy / teal-blue chef jacket over a warm sand apron",
        "identity_prompt": """The character is the MALE PLAYER CHEF — a young Korean man
chef in his 20s, the player's own avatar (gender-select option 2). He is warm,
friendly, dependable and welcoming. He shares the EXACT SAME storybook visual language
as the female chef (same cocoa outline, same soft volumetric shading, same warm
palette restraint, same storybook face tone) — only gender, hair, and costume color
differ, so the two read as one matching set. SILHOUETTE ANCHOR: short, neat modern
dark brown hair (slightly tousled front, NOT spiky-punk, NOT bowl-cut), a rounded
friendly young-adult face, warm brown eyes, warm peach cheeks, an easy warm smile.
Optional simple plain chef bandana. COSTUME / COLOR ANCHOR: a deep NAVY / muted
TEAL-BLUE chef jacket (cook's coat, soft, no embroidery, no name tag — fill with a
muted warm-leaning navy/teal blue, a calm cool-warm block that distinguishes the male
chef and contrasts the female chef's warm-red apron while staying in the same muted
55-78% saturation family) over a warm SAND / oat-beige plain apron (warm neutral, no
text, no logo, no flag). The vibe is a friendly dependable home-kitchen chef ready to
cook with the player.""",
    },
]


# ─────────────────────────────────────────────────────────────────────────────
# EMOTIONS — Phase B neutral (호스트 정면) / Phase C cheer + think (+ cook optional).
# gameplay 매핑: neutral=메뉴/타이틀, cheer=결과/성공, think=tutorial/조리가이드,
# cook=조리 동작/음식 present.
# ─────────────────────────────────────────────────────────────────────────────
EMOTIONS_PHASE_B = [
    {
        "id": "neutral",
        "expression_prompt": """EXPRESSION (base / neutral — welcoming host facing
forward, for menu / title screens; this is the IDENTITY ANCHOR SEED for all emotions
of this chef):

EYES:
- Soft round warm-brown eyes (each with the single tiny white highlight), OPEN and
  looking forward in a friendly attentive state (NOT closed, NOT wide cartoon, NOT
  off-center). Eyebrows relaxed neutral.

MOUTH:
- A warm, gentle CLOSED arc smile (corners softly lifted — a welcoming "hi, ready to
  cook" host smile, NOT a big open grin, NOT a frown).

BODY LANGUAGE + ICONS:
- Head upright, posture relaxed, friendly, facing the player. Shoulders square,
  welcoming.
- NO emotion icons (no heart / sparkle / star / motion lines) — neutral is the
  zero-icon baseline.

This reads as the DEFAULT WELCOMING HOST — the player's chef greeting them, ready to
start. This is the anchor seed; the other emotions modulate from this warm baseline.""",
    },
]

EMOTIONS_PHASE_C = [
    {
        "id": "cheer",
        "with_cook": False,
        "expression_prompt": """EXPRESSION CHANGE — cheer / happy (success & result host —
"yes! great dish!" delighted celebration, kept within warm premium-casual restraint,
NOT a Royal Match explosion):

EYES (happy crescent):
- Both eyes softly CLOSED into clear UPWARD CRESCENT ARC SHAPES (^_^ happy eye
  crinkles), a warm storybook smile-eyes shape reading "yes, we did great!".

MOUTH (clearly happy):
- Mouth OPEN in a clear happy smile (clearly larger than the neutral closed arc), a
  bright "great job!" reaction. Mouth interior is a small clean flat fill (a small hint
  of teeth as a simple flat off-white edge is OK — NOT detailed teeth/tongue).

BODY LANGUAGE + ICONS:
- ONE or BOTH mitten hands raised in a cheerful celebratory gesture (a thumbs-up nub
  or a raised "yay" hand near the shoulder), clearly visible in the bust frame, rounded
  mitten shapes.
- Body posture slightly raised / leaning forward (subtle upward energy, NOT jumping
  out of frame).
- 2 to 3 small simple flat geometric SPARKLE icons (4-point sparkle, single color
  Sesame Gold #F2B33D, varied sizes ~1/14 to 1/10 head size) floating near the upper
  head as a modest celebration accent. SUBTLE — NO confetti storm, NO 5+ particle burst.

ONLY change the FACIAL EXPRESSION + add the raised cheering hand(s) + add the modest
sparkle accent. Keep ABSOLUTELY EVERYTHING ELSE IDENTICAL to the base image — hair
shape / hair color / chef jacket color / apron color / face proportions / chibi
proportions / Cocoa #3A2A1E outline thickness / muted warm saturation / warm peach
blush tone / background mode — all UNCHANGED.

CRITICAL: Eyes MUST be HAPPY closed-arc shapes (upward crescent smile-strokes, NOT sad
closed eyes, NOT sleeping, NOT crying). Any sparkle near the eyes is a SEPARATE floating
geometric icon OUTSIDE the eye, NOT anime shoujo sparkly pupils inside. Sparkles are
SIMPLE FLAT GEOMETRIC (single color, no internal shading). NO crying tears.""",
    },
    {
        "id": "think",
        "with_cook": False,
        "expression_prompt": """EXPRESSION CHANGE — think / focused (tutorial & cooking
guide — "let's see... here's how" thoughtful, attentive, teaching pose — mature focus,
NOT a confused frown, NOT distress):

EYES (focused):
- Soft round warm-brown eyes (with the tiny highlight), OPEN, gaze directed slightly
  UP-AND-TO-ONE-SIDE in a thoughtful "thinking / explaining" look (NOT center-blank, NOT
  crying, NOT sleeping). Eyebrows gently raised in attentive curiosity (NOT the angry
  inward-down frown of disappointment).

MOUTH (focused):
- A soft small slightly-pursed or gently-open "explaining" mouth — a small soft pressed
  line or a tiny open "let's see" shape (NOT a big grin, NOT a frown). Calm, attentive.

BODY LANGUAGE + ICONS:
- ONE mitten hand raised near the chin or pointing a gentle "here's the tip" gesture (a
  rounded index-nub pointing up, or a hand resting thoughtfully near the cheek/chin),
  clearly visible in the bust frame, rounded mitten shape.
- Head very slightly tilted (subtle ~5-10 degree thoughtful tilt).
- Optional: ONE small simple flat geometric icon — a tiny lightbulb or a small "idea"
  sparkle (single color Sesame Gold #F2B33D, ~1/14 head size) floating near the head as
  a gentle "got it / here's a tip" cue. ONE icon max, OR none.

ONLY change the FACIAL EXPRESSION + add the thoughtful hand gesture + the optional single
idea icon. Keep ABSOLUTELY EVERYTHING ELSE IDENTICAL to the base image — hair shape /
hair color / chef jacket color / apron color / face proportions / chibi proportions /
Cocoa #3A2A1E outline thickness / muted warm saturation / warm peach blush tone /
background mode — all UNCHANGED.

CRITICAL: This is a WARM ATTENTIVE TEACHING/FOCUS look — friendly and competent, NOT
confused, NOT worried, NOT the angry/sad inward-down eyebrow frown. The chef is calmly
guiding the player. NO crying, NO distress sweat-drop of dismay (the idea-spark is
positive). Keep it warm and approachable.""",
    },
    {
        "id": "cook",
        "with_cook": True,
        "expression_prompt": """EXPRESSION CHANGE — cook / present (cooking-action or
food-presenting pose — "here's the dish!" warm presenting host, OR mid-cook stirring
gesture; an engaged confident cooking moment):

EYES (engaged warm):
- Soft round warm-brown eyes (with the tiny highlight), OPEN, looking forward or gently
  down toward the food being presented, in a warm engaged "here you go / look at this"
  state. Eyebrows relaxed-friendly.

MOUTH (warm present):
- A warm confident smile (open or closed arc), the satisfied "ta-da, here's the dish"
  presenting smile (between neutral and cheer — warm and proud, NOT the giant cheer
  grin).

BODY LANGUAGE + POSE (this is a POSE change, the key of this emotion):
- BOTH mitten hands brought forward into the bust frame in a PRESENTING / COOKING
  gesture: EITHER both hands gently holding up a simple warm round dish / bowl of food
  (a small steaming Korean dish — a simple rounded bowl with a soft food mound and 1-2
  small steam curls, drawn in the same cocoa-outline soft-volumetric style), OR one hand
  holding a wooden spoon/ladle in a mid-stir cooking gesture toward a small pot edge at
  the bottom of the frame. Hands are rounded mitten/nub shapes (NO finger detail). Keep
  the presented food / tool SIMPLE and small — the CHEF stays the main subject.
- Body posture leaning slightly forward in an offering / engaged-cooking stance.
- Optional: 1-2 small soft steam curls and at most ONE small Sesame Gold #F2B33D sparkle
  near the dish. SUBTLE.

ONLY change the FACIAL EXPRESSION + add the presenting/cooking hands + the small simple
dish-or-spoon prop + optional steam. Keep ABSOLUTELY EVERYTHING ELSE IDENTICAL to the
base image — hair shape / hair color / chef jacket color / apron color / face
proportions / chibi proportions / Cocoa #3A2A1E outline thickness / muted warm
saturation / warm peach blush tone / background mode — all UNCHANGED.

CRITICAL: Bust-up framing stays (the dish/pot prop sits in the LOWER part of the bust
frame, the chef is NOT shown full-body). The prop is SIMPLE and in the SAME art style
(cocoa outline, soft volumetric). The chef remains the dominant subject. NO photoreal
food, NO over-detailed dish, NO finger detail on the hands.""",
    },
]


# ─────────────────────────────────────────────────────────────────────────────
# Path / Constants
# ─────────────────────────────────────────────────────────────────────────────
OUT_DIR = PROJECT_ROOT / "assets-raw" / "protagonist_pack_m2"
DEFAULT_STYLE_SEED = PROJECT_ROOT / "assets-raw" / "style" / "north_star_hanhana_v1.png"
SUPPORTED_EDIT_SIZES = {(1024, 1024), (1536, 1024), (1024, 1536)}


TRANSPARENT_BG_OVERRIDE = """
BACKGROUND OVERRIDE — FULLY TRANSPARENT (alpha cutout):
Render the chef on a FULLY TRANSPARENT background (alpha PNG) instead of any kitchen
scene or cream plate. The cutout around the whole character (head, shoulders, and any
raised arms/hands or presented dish) must be a CLEAN crisp silhouette — NO black smudge,
NO dark halo, NO grey fringe, NO cutout artifact, NO leftover background patch around the
arm / hand / shoulder / dish edges. The Cocoa #3A2A1E 3-4px outline stays consistent all
the way around."""


STYLE_SEED_PREAMBLE = """STYLE SEED REFERENCE: the attached reference image
(north_star_hanhana_v1.png) is provided as a STYLE SEED ONLY — match its warm storybook
tone, soft volumetric shading, warm Korean-kitchen color world, Cocoa warm-dark outline,
and overall render QUALITY and friendliness. DO NOT copy the reference character herself:
do NOT reproduce her face, her pink flower hairpin, her sage-mint apron, her chef hat
with the flag patch, or any embroidered/printed text. Generate the NEW, DIFFERENT chef
defined below, in the SAME art style as the reference.

"""


def build_prompt_phase_b(character: dict, emotion: dict, background: str = "opaque",
                         with_style_seed: bool = False) -> str:
    """Phase B = chef identity + neutral expression + STYLE_SUFFIX_PROTAGONIST.

    background='transparent' → TRANSPARENT_BG_OVERRIDE 부착 (native alpha cutout).
    with_style_seed=True → STYLE_SEED_PREAMBLE 부착 (reference 는 style 만, 캐릭터 복제 X).
    """
    bg_override = TRANSPARENT_BG_OVERRIDE if background == "transparent" else ""
    seed_pre = STYLE_SEED_PREAMBLE if with_style_seed else ""
    return (
        f"{seed_pre}"
        f"A warm cozy premium-casual mobile game player-chef bust-up portrait. "
        f"{character['identity_prompt']}\n\n"
        f"{emotion['expression_prompt']}\n\n"
        f"{STYLE_SUFFIX_PROTAGONIST}"
        f"{bg_override}"
    )


def build_prompt_phase_c(character: dict, emotion: dict) -> str:
    """Phase C = image edit COMMON_FRAME (identity lock) + emotion/pose change.

    8-attribute IDENTITY LOCK (gen_character_pack.py 패턴): skin/hair color/eye color/
    clothing color/accent color/silhouette/line weight/shading 을 emotion 간 픽셀-동일
    톤으로 박제 + clean-transparent (arm/hand/dish dark-halo·smudge·cutout artifact 금지).
    """
    common_frame = f"""Keep the EXACT SAME character identity as the base image. This is
the {character['display_name']} ({character['gender']} player-chef avatar) — maintain the
EXACT identity from the base image.

IDENTITY LOCK — these 8 attributes MUST stay PIXEL-IDENTICAL in tone to the base image
(do NOT recolor, do NOT shift shade or saturation, do NOT drift between emotions):
1. SKIN TONE — the exact same warm skin shade (not lighter, not darker).
2. HAIR COLOR + SHAPE — the exact same hair color, shade, and hairstyle (same ponytail/
   short cut, same headband/bandana if present).
3. EYE COLOR — the same warm-brown eyes with the single white highlight.
4. CHEF JACKET COLOR — the exact same jacket fill color and saturation.
5. APRON COLOR — the exact same apron fill color and saturation (and the same plain
   no-text styling).
6. SILHOUETTE — the same hair shape, same costume shape, same storybook chibi
   1 to 1.4-1.7 head-to-body proportions.
7. LINE WEIGHT — the same Cocoa #3A2A1E outline at 3-4px (warm dark, NOT pure black),
   identical thickness.
8. SHADING STYLE — the same soft 2-tone cel shading, the same top-left volumetric light,
   and the same warm peach blush.
CHANGE ONLY: facial expression, eyebrow, eye shape, mouth, hand gesture / pose, and the
small emotion fx / prop (per the emotion block below). Everything in the 8-attribute LOCK
stays UNCHANGED. No name tag, no embroidered text, no flag patch may appear.

Crop to BUST-UP PORTRAIT (head and shoulders / upper chest only — NO full body, NO legs,
NO feet). Hands/arms (and any presented dish or spoon) may extend into the LOWER bust
frame for raised-hand / cooking / presenting gestures, but the LOWER BODY stays cropped.

BACKGROUND — FULLY TRANSPARENT (alpha cutout), CLEAN silhouette:
- Render on a FULLY TRANSPARENT background (alpha PNG) — NO kitchen scene, NO cream plate.
- The cutout around the WHOLE character (head, shoulders, AND any raised arms / hands /
  presented dish) must be a CLEAN crisp silhouette: NO black smudge, NO dark halo, NO grey
  fringe, NO cutout artifact, NO leftover background patch around the arm / hand / dish /
  shoulder edges.
- The outer outline stays the consistent soft Cocoa #3A2A1E 3-4px all the way around
  (including around raised hands and any dish) — no broken or dark-clumped edges.
- (If a background must be drawn instead of transparent, use SOLID Rice Cream #FBF3E4 with
  one soft warm ellipse shadow — but transparent alpha is preferred for clean edges.)

{emotion['expression_prompt']}

{STYLE_SUFFIX_PROTAGONIST}"""
    return common_frame


def inspect_base_image(base_path: Path) -> tuple[int, int]:
    """PIL로 base image 사이즈 측정. PIL 없으면 PNG IHDR header parse fallback."""
    try:
        from PIL import Image  # noqa: WPS433

        with Image.open(base_path) as img:
            return img.size
    except ImportError:
        with open(base_path, "rb") as f:
            data = f.read(24)
        if data[:8] != b"\x89PNG\r\n\x1a\n":
            return (-1, -1)
        width = int.from_bytes(data[16:20], "big")
        height = int.from_bytes(data[20:24], "big")
        return (width, height)


def ensure_edit_compatible_size(base_path: Path) -> tuple[Path, str]:
    """base image가 gpt-image-1 edit API supported size면 그대로. 아니면 resize."""
    w, h = inspect_base_image(base_path)
    if (w, h) in SUPPORTED_EDIT_SIZES:
        return base_path, f"{w}x{h}"

    if w == h:
        target = (1024, 1024)
    elif w > h:
        target = (1536, 1024)
    else:
        target = (1024, 1536)

    try:
        from PIL import Image  # noqa: WPS433
    except ImportError:
        return base_path, "auto"

    print(f"   resize {w}x{h} -> {target[0]}x{target[1]} (gpt-image-1 edit supported)")
    resized_path = base_path.parent / f"{base_path.stem}_edit_resized.png"
    with Image.open(base_path) as img:
        img.convert("RGBA").resize(target, Image.LANCZOS).save(resized_path, "PNG")
    return resized_path, f"{target[0]}x{target[1]}"


def edit_image(
    client: OpenAI,
    base_path: Path,
    prompt: str,
    output_path: Path,
    quality: str = "medium",
    background: str = "opaque",
    style_seed: Path | None = None,
) -> None:
    """gpt-image-1 image edit API → output_path 저장 (gen_character_pack 패턴).

    style_seed 가 주어지면 base + north_star 두 장을 함께 image list 로 전달해
    스타일 anchor 를 강화(SDK 가 multi-image edit 미지원이면 base 단독 fallback).
    background='transparent' 면 edit API 에 전달 (native alpha cutout)."""
    edit_path, size = ensure_edit_compatible_size(base_path)
    opened = []
    try:
        base_f = open(edit_path, "rb")
        opened.append(base_f)
        image_arg: object = base_f
        if style_seed and style_seed.exists():
            seed_f = open(style_seed, "rb")
            opened.append(seed_f)
            image_arg = [base_f, seed_f]  # multi-image: [base, style seed]

        edit_kwargs = dict(model="gpt-image-1", image=image_arg, prompt=prompt,
                           size=size, quality=quality, n=1)
        if background in {"transparent", "opaque", "auto"}:
            edit_kwargs["background"] = background
        try:
            result = client.images.edit(**edit_kwargs)
        except TypeError:
            edit_kwargs.pop("background", None)
            for f in opened:
                f.seek(0)
            print("   (note) edit API background 미지원 SDK — opaque 진행, "
                  "후처리 rembg isnet+alpha-matting 권장")
            result = client.images.edit(**edit_kwargs)
        except Exception:
            # multi-image edit 미지원 SDK → base 단독 재시도
            if isinstance(image_arg, list):
                base_f.seek(0)
                edit_kwargs["image"] = base_f
                print("   (note) multi-image edit 미지원 — base 단독 fallback")
                result = client.images.edit(**edit_kwargs)
            else:
                raise
    finally:
        for f in opened:
            f.close()

    data = result.data[0]
    if hasattr(data, "b64_json") and data.b64_json:
        image_bytes = base64.b64decode(data.b64_json)
    elif hasattr(data, "url") and data.url:
        import urllib.request

        with urllib.request.urlopen(data.url) as resp:
            image_bytes = resp.read()
    else:
        raise RuntimeError("gpt-image-1 edit response missing image data")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_bytes(image_bytes)
    size_kb = len(image_bytes) / 1024
    print(f"   OK {output_path.name} ({size_kb:.1f} KB)")


def generate_with_optional_seed(
    client: OpenAI,
    prompt: str,
    output_path: Path,
    quality: str,
    background: str,
    style_seed: Path | None,
) -> None:
    """Phase B neutral 생성. style_seed 있으면 edit(north_star) 로 스타일 anchor,
    없으면 prompt-only generate. 둘 다 transparent-native 지원."""
    if style_seed and style_seed.exists():
        print(f"   style-seed: {style_seed.name} (edit-mode style anchor)")
        # style seed 를 base image 로 전달하되 prompt 가 신규 캐릭터를 강제.
        edit_image(client, style_seed, prompt, output_path,
                   quality=quality, background=background, style_seed=None)
    else:
        generate_image(
            client=client,
            prompt=prompt,
            output_path=output_path,
            model="gpt-image-1",
            size="1024x1024",
            quality=quality,
            background=background,
        )


def run_phase_b(
    client: OpenAI,
    characters: list[dict],
    args: argparse.Namespace,
) -> tuple[list[str], list[tuple[str, str]]]:
    """Phase B = chef neutral 생성 (style-seed 면 edit, 아니면 prompt-only)."""
    successes: list[str] = []
    failures: list[tuple[str, str]] = []
    neutral = EMOTIONS_PHASE_B[0]
    style_seed = args.style_seed if args.style_seed else None

    for i, character in enumerate(characters, 1):
        cid = character["id"]
        out_path = args.out_dir / f"{cid}_{neutral['id']}_{args.version}.png"
        prompt = build_prompt_phase_b(
            character, neutral, args.background, with_style_seed=bool(style_seed)
        )

        print(f"\n[Phase B {i}/{len(characters)}] {cid} neutral -> {out_path.name}")
        t_start = time.time()
        try:
            generate_with_optional_seed(
                client, prompt, out_path, args.quality, args.background, style_seed
            )
            print(f"   elapsed {time.time() - t_start:.1f}s")
            successes.append(f"{cid}_neutral")
        except Exception as exc:
            print(f"   FAIL ({time.time() - t_start:.1f}s): {exc!r}")
            failures.append((f"{cid}_neutral", repr(exc)))

    return successes, failures


def run_phase_c(
    client: OpenAI,
    characters: list[dict],
    emotions: list[dict],
    args: argparse.Namespace,
) -> tuple[list[str], list[tuple[str, str]]]:
    """Phase C = emotion variants (image edit, base = Phase B neutral output)."""
    successes: list[str] = []
    failures: list[tuple[str, str]] = []

    total = len(characters) * len(emotions)
    counter = 0

    for character in characters:
        cid = character["id"]
        base_path = args.out_dir / f"{cid}_neutral_{args.version}.png"

        if not base_path.exists():
            print(f"\n[Phase C SKIP] {cid} base not found: {base_path}")
            print(f"   Run Phase B first: py tools/gen_protagonist_pack.py --phase B --only {cid}")
            for emotion in emotions:
                counter += 1
                failures.append((f"{cid}_{emotion['id']}", f"base missing: {base_path.name}"))
            continue

        w, h = inspect_base_image(base_path)
        compat = "OK (supported)" if (w, h) in SUPPORTED_EDIT_SIZES else "-> will resize"
        print(f"\n[Phase C base] {base_path.name}: {w}x{h} {compat}")

        for emotion in emotions:
            counter += 1
            eid = emotion["id"]
            out_path = args.out_dir / f"{cid}_{eid}_{args.version}.png"
            prompt = build_prompt_phase_c(character, emotion)

            print(f"\n[Phase C {counter}/{total}] {cid} {eid} -- base: {base_path.name}")
            t_start = time.time()
            try:
                edit_image(client, base_path, prompt, out_path,
                           quality=args.quality, background=args.background)
                print(f"   elapsed {time.time() - t_start:.1f}s")
                successes.append(f"{cid}_{eid}")
            except Exception as exc:
                print(f"   FAIL ({time.time() - t_start:.1f}s): {exc!r}")
                failures.append((f"{cid}_{eid}", repr(exc)))

    return successes, failures


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Player Protagonist Chef Pack — 2 chef (female + male) × emotion, "
        "gender select. north star = STYLE SEED only, 신규 캐릭터, transparent-native."
    )
    parser.add_argument(
        "--phase", type=str, default="ALL", choices=["B", "C", "ALL"],
        help="B = neutral 2장 / C = emotion / ALL = B then C",
    )
    parser.add_argument(
        "--only", type=str, default="",
        help="콤마구분 chef ID만 (chef_f,chef_m). 빈 값 = 2 chef 전체.",
    )
    parser.add_argument(
        "--emotion", type=str, default="",
        choices=["", "cheer", "think", "cook"],
        help="Phase C 한정 — 특정 emotion만 (빈 값 = cheer+think, --with-cook 면 +cook).",
    )
    parser.add_argument(
        "--with-cook", action="store_true",
        help="Phase C 에 cook/present emotion 포함 (chef당 3 = cheer/think/cook).",
    )
    parser.add_argument(
        "--quality", type=str, default="medium",
        choices=["low", "medium", "high", "auto"], help="gpt-image-1 quality.",
    )
    parser.add_argument(
        "--background", type=str, default="transparent",
        choices=["transparent", "opaque", "auto"],
        help="transparent=native alpha cutout (production 권장) / opaque=Rice Cream bg(검수).",
    )
    parser.add_argument(
        "--style-seed", type=Path, default=None,
        help="north star reference (style seed only). 예: "
             "assets-raw/style/north_star_hanhana_v1.png. 미지정=prompt-only generate.",
    )
    parser.add_argument(
        "--version", type=str, default="v1",
        help="파일명 suffix (기본 v1 → chef_f_neutral_v1.png)",
    )
    parser.add_argument(
        "--out-dir", type=Path, default=OUT_DIR,
        help="출력 디렉터리 (기본: assets-raw/protagonist_pack_m2/)",
    )
    args = parser.parse_args()

    only_set = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    selected = [c for c in PROTAGONISTS if (only_set is None or c["id"] in only_set)]
    if not selected:
        sys.exit(f"--only mismatch. Valid IDs: {[c['id'] for c in PROTAGONISTS]}")

    if args.emotion:
        selected_emotions = [e for e in EMOTIONS_PHASE_C if e["id"] == args.emotion]
    else:
        selected_emotions = [
            e for e in EMOTIONS_PHASE_C if (not e["with_cook"]) or args.with_cook
        ]

    args.out_dir.mkdir(parents=True, exist_ok=True)

    if args.style_seed and not args.style_seed.exists():
        print(f"⚠ style-seed not found: {args.style_seed} — prompt-only 로 진행")
        args.style_seed = None

    unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
    unit = unit_map.get(args.quality, 0.042)

    phase_b_count = len(selected) if args.phase in ("B", "ALL") else 0
    phase_c_count = len(selected) * len(selected_emotions) if args.phase in ("C", "ALL") else 0
    total_count = phase_b_count + phase_c_count
    est_total = unit * total_count

    print("=" * 70)
    print("Player Protagonist Chef Pack (gpt-image-1, north star STYLE SEED only)")
    print(f"   phase: {args.phase}")
    print(f"   chefs: {len(selected)} ({[c['id'] for c in selected]})")
    if args.phase in ("C", "ALL"):
        print(f"   emotions (Phase C): {[e['id'] for e in selected_emotions]}")
    print(f"   quality: {args.quality} (${unit:.3f}/img)  background: {args.background}")
    print(f"   style-seed: {args.style_seed if args.style_seed else '(none — prompt-only)'}")
    print(f"   Phase B: {phase_b_count} / Phase C: {phase_c_count} / total: {total_count}")
    print(f"   est cost: ${unit:.3f} x {total_count} = ${est_total:.2f}")
    print(f"   output: {args.out_dir}")
    print("=" * 70)

    api_key = load_api_key()
    client = OpenAI(api_key=api_key)

    all_successes: list[str] = []
    all_failures: list[tuple[str, str]] = []
    t0 = time.time()

    if args.phase in ("B", "ALL"):
        print("\n" + "=" * 70)
        print("PHASE B — chef neutral generation (style-seed edit OR prompt-only)")
        print("=" * 70)
        s, f = run_phase_b(client, selected, args)
        all_successes.extend(s)
        all_failures.extend(f)

    if args.phase in ("C", "ALL"):
        print("\n" + "=" * 70)
        print(
            f"PHASE C — {len(selected) * len(selected_emotions)} emotion variants "
            "(image edit, base = Phase B neutral)"
        )
        print("=" * 70)
        s, f = run_phase_c(client, selected, selected_emotions, args)
        all_successes.extend(s)
        all_failures.extend(f)

    total_elapsed = time.time() - t0
    print("\n" + "=" * 70)
    print(f"DONE: {len(all_successes)}/{total_count} imgs -- total {total_elapsed / 60:.1f} min")
    if all_successes:
        print(f"   success: {', '.join(all_successes)}")
    if all_failures:
        print(f"   fail {len(all_failures)}:")
        for name, err in all_failures:
            print(f"     - {name}: {err}")
    print(f"   est cost: ${unit * len(all_successes):.2f}")
    print(f"   output path: {args.out_dir}")
    print("=" * 70)


if __name__ == "__main__":
    main()
