"""
K-Food Master — Art Production Sprint 1 / Priority 1: Character Production Pack.

9 character × 4 emotion (neutral / happy / excited / disappointed) = 36 PNG.
  (7 original + 2 foreign guests Sofia / Kenji — Korean Food Discovery 정합:
   외국인이 한국 음식을 처음 먹고 반응. 따뜻·정중·diverse, 캐리커처 회피.)
Style Bible v1 (docs/art/style-bible-v1.md) WARM tone — supersedes the OLD Cool
Sage / Royal Match tone of gen_guest_avatars.py. This is a PRODUCTION RESKIN: the
2-pass driver structure (Phase B neutral generation → Phase C emotion image edit,
family IP lock) is reused, but the entire visual language is migrated:

  OLD (gen_guest_avatars.py)            NEW (this driver — Style Bible v1)
  ──────────────────────────────────    ──────────────────────────────────────────
  Cool Sage #C8D5C0 solid bg            BG Cream #FBF3E4 warm bg
  slim outline 2-3px warm dark #2D1D14  Cocoa outline 3-4px #3A2A1E
  Royal Match saturated 80-90%          muted warm 55-78% (Animal Restaurant)
  flat single-fill / 1-layer cel        soft volumetric 2-tone (base + base×0.85)
  chibi 1:1.7 (hyper-casual)            storybook chibi 1:1.3~1.6 (Style Bible §4.2)
  light pink #FFCFCF blush              warm peach blush #E89A7A @40% (cozy, NOT cool pink)
  Subway Surfers mascot energy          Cooking Diary + Animal Restaurant storybook warmth

7 character (guests.csv + Style Bible §4.1 silhouette/color anchors):
  - junho     호방 매콤 (red/orange hoodie + chili icon, short messy dark hair)
  - mina      단맛 발랄 (soft yellow/cream top + strawberry, chestnut side ponytail)
  - riley     외국인 산뜻 (blue/lemon top + freckles, honey-blonde wavy — ONLY non-Korean)
  - mrs_lee   멘토 (mauve+beige cardigan + reading glasses, permed wavy salt-pepper)
  - seoyeon   집밥 따뜻 (cream/plum turtleneck, long straight dark hair)
  - mother    담백 (warm coral jeogori silhouette + apron, round-bun w/ white strands)
  - father    호방 (single-color cardigan + tan, salt-and-pepper short hair)

  NOTE: mother / father are NEW characters in the avatar pack (previously only
  reaction R-01~06 existed, no bust avatar). Their Style Bible §4.1 anchors:
  Mother = round-bun + warm coral jeogori silhouette (자수 X) + apron / Father =
  salt-and-pepper short hair + single-color tan cardigan. Mrs Lee must stay CLEARLY
  DIFFERENT from Mother (permed wavy NOT round-bun + glasses + mauve NOT coral).

4 emotion (Style Bible §4.5 emotion sheet — bad / okay / good / excellent mapping):
  - neutral      (okay/★2~3) — dot eyes + small highlight + subtle arc smile
  - happy        (good/★4)   — eye-crescent + arc/O smile + 1-2 sparkle
  - excited      (excellent/★5) — O-shape + sparkle eyes-adjacent + 2 hands + sparkle 2-3
  - disappointed (bad/★1)    — lowered eyebrows + small ㅡ mouth (subtle, NOT crying)

2-pass (gen_guest_avatars.py proven pattern):
  Phase B = client.images.generate() prompt-only neutral (identity anchor seed).
  Phase C = client.images.edit(model="gpt-image-1", image=open(neutral, "rb"), ...)
            emotion change only, family IP lock (hair/outfit/proportions unchanged).

ART PIPELINE CORRECTION (2026-06-06, docs/art/art-pipeline-correction.md D2/D9):
  - 색 LOCK 강화 — Phase C common_frame 에 8개 LOCK 속성(skin/hair color/eye color/
    clothing color/accent color/silhouette/line weight/shading)을 픽셀-동일 톤으로 박제.
    emotion 간 색 drift 차단 (§6 Character Consistency Checklist).
  - clean transparent — --background transparent 로 native alpha cutout (Phase B generate +
    Phase C edit 양쪽 background 전달). cream-bg→rembg(u2net) 의 arm/hand dark-halo artifact
    원천 차단 (옵션 A). edit API 가 background 미지원 SDK 면 fallback 후 rembg isnet+
    alpha-matting 권장 (u2net 금지).
  - --background transparent 권장 (production), opaque = 검수용.

Usage:
    # Phase B test (1 character neutral first — visual check before batch)
    py tools/gen_character_pack.py --phase B --only junho --quality medium

    # Phase B all 7 neutral
    py tools/gen_character_pack.py --phase B --quality medium

    # Phase C 21 emotion variants (needs Phase B neutral as prerequisite)
    py tools/gen_character_pack.py --phase C --quality medium
    py tools/gen_character_pack.py --phase C --only junho            # junho 3 emotion
    py tools/gen_character_pack.py --phase C --emotion happy         # 7 char happy

    # Full batch (7 neutral + 21 emotion = 28)
    py tools/gen_character_pack.py --phase ALL --quality medium

Default:
    model    = gpt-image-1 (medium quality)
    quality  = medium ($0.042/img × 28 = ~$1.18 total)
    size     = 1024x1024 (square 1:1)
    out_dir  = assets-raw/character_pack_m2/
    version  = v1
    파일명   = {guest_id}_{emotion}_{version}.png  (예: junho_neutral_v1.png)
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
# STYLE_SUFFIX_CHARACTER — 7 character × 4 emotion = 28장 공통 suffix.
# Style Bible v1 §1 (4 lock) + §2 (warm palette) + §4 (character-first chibi
# storybook). OLD Cool Sage / Royal Match / slim outline 2-3px → WARM Cream bg /
# Cocoa outline 3-4px / soft volumetric storybook (Cooking Diary + Animal
# Restaurant). 텍스트 생성 금지 (§3.2 — Godot overlay).
# ─────────────────────────────────────────────────────────────────────────────
STYLE_SUFFIX_CHARACTER = """Format: square 1:1.
View: bust-up portrait (head and shoulders only, NOT full body — framed from chest
up, avatar usage). Single subject per image.

Style: warm cozy premium-casual mobile game character portrait, Cooking Diary warm
kitchen friendliness + Animal Restaurant hand-drawn storybook warmth. Clean 2D
hand-drawn casual illustration, soft volumetric shading. NOT Royal Match
over-saturated glossy, NOT hyper-casual flat single-fill.

PROPORTIONS (Style Bible §4.2 storybook chibi — slightly less exaggerated than
hyper-casual):
- Head-to-body ratio approximately 1 to 1.3 to 1.6 (big friendly head, smaller
  visible shoulders/chest in the bust frame). Head width about 1.1 to 1.25 times
  shoulder width.
- Hands (if visible in bust frame) are simple rounded mitten / nub shapes — NO
  individual finger detail (avoid gpt-image-1 finger artifacts).

EYES + FACE (Style Bible §4.3 storybook warmth — one step richer than flat):
- Small rounded black dot eyes with a SINGLE tiny white highlight point inside each
  (storybook warmth — NOT plain flat dots, NOT enlarged anime shoujo pupils with
  multiple sparkle stars inside). Eye shape modulates per emotion (see body).
- A very small nose cue allowed (a tiny dot or short single arc — storybook is
  warmer with a small nose than with none).
- Soft warm PEACH cheek blush (#E89A7A at about 40% — warm peach, NOT cool pink,
  NOT deep dark Cookie Run frosting pink) lightly on almost every character.
- Mouth: simple arc (smile) / O (joy) / small straight line (neutral) per emotion.

OUTLINE + SHADING (Style Bible §1 4-lock + §4.4 — shared across food/UI/env):
- Outer outline 3 to 4px in Cocoa #3A2A1E (warm dark, NOT pure black). Slightly
  hand-drawn feel allowed — the outline thickness can vary a touch (Animal
  Restaurant warmth), NOT a perfectly uniform cold vector outline.
- Soft 2-tone cel shading: base color + a soft shadow at base color × 0.85 with a
  gentle gradient boundary, applied to hair / clothing / face. NOT hyper-casual
  single-fill, NOT Royal Match multi-layer glossy — the middle.
- One subtle soft highlight on the hair and one on the shoulder of the clothing
  (subtle, much less glossy than food).

BACKGROUND (Style Bible §2.2 — OLD Cool Sage is DEPRECATED):
- Solid BG Cream #FBF3E4 warm background (warm rice-cream tone — this is the
  unified Style Bible v1 background, replacing the old Cool Sage #C8D5C0).
- One soft warm ambient ellipse shadow under the character bust (Cocoa #3A2A1E at
  about 18 to 25% alpha — warm shadow, NOT pure black).

COLOR (Style Bible §2.4 muted warm restraint — Animal Restaurant tone):
- Mid-saturation warm palette, about 55 to 78% saturation (muted cozy, NOT Royal
  Match 80-90% over-saturated punch). 2 to 3 color blocks max on clothing.

Important: avoid Cool Sage background, cool mint background, teal dominant
background (these are the OLD deprecated tone — use warm BG Cream #FBF3E4 instead),
Royal Match style, glossy plastic, over-saturated neon, hyper-casual flat single
color fill, scrapbook noise texture, grunge, kraft paper, vintage texture,
golden hour overexposed, sunset dramatic lighting,
Cookie Run frosting style, Toca Boca, Toon Blast over-cartoony, deep dark pink
cheek, heavy blush, cool pink blush,
anime girl, manga style, big sparkly anime-style eyes (any sparkle accent stays a
SEPARATE small floating geometric icon OUTSIDE the eye, NOT enlarged shoujo pupils
inside), school uniform, fanservice or sexy elements,
photorealistic rendering, 3D render, octane or unreal engine, painterly watercolor,
gradient mesh, multi-layer complex glossy shading, hyperdetailed elements,
individual finger detail (mitten/nub hands only),
Japanese (kimono, geisha, yukata, sushi), Chinese (qipao, hanfu, cheongsam,
chinese knot), Western cowboy hat or lederhosen (Western casual clothing is OK ONLY
for the foreign 외국인 character Riley, see body),
Korean hanbok formal traditional wear on the modern friends (junho/mina/riley/
seoyeon are modern casual; mother wears a soft simple jeogori-silhouette top WITHOUT
elaborate embroidery; mrs_lee and father wear modern casual),
sleeping, eyes closed peaceful (happy closed-arc eyes are upward HAPPY smile-strokes,
NOT sad sleeping closed eyes), crying tears, teardrop falling, sad sobbing
(disappointed emotion is a subtle lowered-eyebrow frown, NOT crying),
full body, lower body, legs, feet (bust-up portrait only — arms/hands can extend
into the bust frame for excited raised-hand gestures),
multiple characters in one image,
any English or Korean text legibly readable (NO speech bubbles, NO captions, NO name
labels — chibi character stands alone, all text is added later as Godot UI overlay)."""


# ─────────────────────────────────────────────────────────────────────────────
# 7 CHARACTERS — id / display_name / personality / silhouette / color / identity.
# Style Bible §4.1 silhouette identity + color identity (흑백 실루엣 + 상의 컬러
# block 1개로 7명 구분 가능 = silhouette test PASS). 5 friend/mentor (guests.csv)
# + mother_01 + father_01 (신규 avatar — 기존 R-01~06 reaction만 존재).
# ─────────────────────────────────────────────────────────────────────────────
CHARACTERS = [
    {
        "id": "junho",
        "display_name": "Junho",
        "personality": "호방 매콤 (bold spicy enthusiast)",
        "silhouette": "short messy spiky front dark hair, rounded face",
        "color": "Persimmon/Gochu red hoodie",
        "identity_prompt": """The character JUNHO, a Korean young adult male in his 20s,
an energetic bold friend who loves spicy / salty / hearty food. SILHOUETTE ANCHOR:
short messy modern dark brown hair with a slightly spiky / tousled front (NOT
bowl-cut, NOT salt-and-pepper) and a round friendly face — his silhouette reads as
the spiky-front young guy. COLOR ANCHOR: a warm RED-ORANGE hoodie or crewneck — fill
with Persimmon #E8732C to Gochu Red #D84338 warm red (single warm-red block, the
clear color identity that distinguishes Junho), with a small soft flat chili-pepper
or flame motif on the chest (single accent, small and subtle, NOT dominating). The
vibe is energetic, friendly, bold — a guy who shows up saying "make it nice and
spicy today!" with a confident warm posture.""",
    },
    {
        "id": "mina",
        "display_name": "Mina",
        "personality": "단맛 발랄 (cheerful sweet-tooth)",
        "silhouette": "side ponytail / side-swept layers with a small hair clip",
        "color": "soft warm yellow / cream top",
        "identity_prompt": """The character MINA, a Korean young adult female in her 20s,
a cheerful bubbly friend who loves sweet / savory food. SILHOUETTE ANCHOR:
medium-length warm chestnut brown hair in a soft side ponytail or side-swept layers
with a small soft hair clip at one side — her silhouette reads as the side-ponytail
girl. COLOR ANCHOR: a soft warm YELLOW / cream pullover sweater (fill with a warm
Sesame Gold tint #F2B33D softened toward cream, a cozy mid-saturation warm yellow —
clearly different from Junho's red and Seoyeon's oat), with a small soft flat
strawberry or heart motif at the chest (single accent, small subtle). The vibe is
cheerful, sweet, bright — a girl who shows up saying "I've got a serious sweet
tooth!" with a bright open posture.""",
    },
    {
        "id": "riley",
        "display_name": "Riley",
        "personality": "외국인 산뜻 (foreign fresh-tangy)",
        "silhouette": "short wavy hair + freckles, soft androgynous face",
        "color": "blue-tone top (lemon accent)",
        "identity_prompt": """The character RILEY, a non-Korean foreign 외국인 young
adult in their 20s living in Korea (foreign exchange resident / global friend —
explicitly NOT a Korean ethnic identity, lighter skin tone and warmer hair color, a
cosmopolitan friend who loves sour / fresh / umami food). Riley is gender-neutral /
androgynous (soft casual facial structure). SILHOUETTE ANCHOR: short modern wavy
warm honey-blonde / strawberry-blonde hair (this is the ONE character who breaks the
Korean dark-hair convention — the foreign identity is the design point) with a few
small soft freckle dots on the cheeks. COLOR ANCHOR: a fresh BLUE-tone casual hoodie
or pullover (fill with a soft warm-leaning blue / dusty periwinkle — the clear cool
color identity that distinguishes Riley in the warm cast), with a small soft flat
lemon-slice or leaf motif at the chest (single accent, small subtle, a lemon-yellow
pop). The vibe is bright, fresh, globally inclusive — a friend who shows up saying
"give me something bright and tangy!" with a relaxed open posture. NOT a cowboy, NOT
a Western caricature — just a warm cosmopolitan young friend.""",
    },
    {
        "id": "guest_foreign_1",
        "display_name": "Sofia",
        "personality": "외국인 따뜻 호기심 (warm curious K-food explorer)",
        "silhouette": "dark curly shoulder-length hair pulled half-up, hoop earring",
        "color": "warm marigold / saffron top (leaf accent)",
        "identity_prompt": """The character SOFIA, a non-Korean foreign 외국인 young adult
woman in her late 20s visiting / studying in Korea (a warm cosmopolitan traveler
discovering Korean food for the first time, full of delighted curiosity — explicitly
NOT a Korean ethnic identity). Sofia reads as Latina / Mediterranean with a warm
medium-brown / tan skin tone (a richer warm skin shade clearly distinct from the
Korean cast and from Riley's lighter tone — diverse, drawn with the SAME warm
respectful storybook treatment, NOT a caricature, NOT exaggerated features).
SILHOUETTE ANCHOR: dark brown softly CURLY shoulder-length hair pulled half-up (a few
loose curls framing the face — clearly different from Riley's short straight-wavy
blonde and from the Korean characters' styles), plus one small simple gold hoop
earring as her gentle signature accent. A round friendly open face. COLOR ANCHOR: a
warm MARIGOLD / saffron-gold blouse or knit top (fill with a warm marigold #E8A33D
softened, a sunny mid-saturation warm gold that distinguishes Sofia and is clearly
different from Mina's pale cream-yellow and from Riley's blue), with a small soft flat
leaf / sprout motif at the collar (single small accent — her curious "what's this
ingredient?" cue). The vibe is warm, curious, open, delighted — a traveler who shows
up saying "I've always wanted to try real Korean food!" with an eager friendly
posture. Drawn warmly and respectfully, dignified and inclusive — NOT a stereotype.""",
    },
    {
        "id": "guest_foreign_2",
        "display_name": "Kenji",
        "personality": "외국인 정중 미식 (polite foreign food-lover, gentle gourmet)",
        "silhouette": "short tidy black hair, slim modern glasses",
        "color": "soft sage-green button shirt (chopstick/spoon accent)",
        "identity_prompt": """The character KENJI, a non-Korean foreign 외국인 young adult
man in his early 30s — a Southeast-Asian / Filipino-leaning expat working in Korea who
has fallen in love with Korean cuisine (a polite, appreciative, gentle gourmet
discovering each dish thoughtfully — explicitly NOT a Korean ethnic identity, and
explicitly NOT a Japanese identity despite the name; he is simply a warm individual
with his own name). Kenji has a warm tan / golden-brown skin tone (a diverse warm
shade distinct from the Korean cast, from Riley, and from Sofia — drawn with the SAME
respectful storybook treatment, dignified, NOT a caricature). SILHOUETTE ANCHOR: short
tidy neat black hair (a clean modern side-part, NOT spiky, NOT bowl-cut) plus slim
modern rectangular glasses with a thin warm-brown frame as his clear signature
accessory (clearly different from Mrs Lee's round reading glasses — Kenji's are slim
rectangular and he is a young man). A gentle, kind, attentive face. COLOR ANCHOR: a
soft SAGE-GREEN / muted olive button-up shirt (fill with a warm-leaning muted sage
#7E9B6B, a calm earthy green that distinguishes Kenji — clearly different from every
other character's top, the one green in the cast), with a small soft flat
spoon-and-chopstick or rice-bowl motif at the chest pocket (single small accent — his
thoughtful "let me taste this properly" gourmet cue). The vibe is polite, warm,
appreciative, gently enthusiastic — an expat who shows up saying "I'd love to learn
how this is made" with a courteous attentive posture. Drawn warmly and respectfully —
NOT a stereotype.""",
    },
    {
        "id": "mrs_lee",
        "display_name": "Mrs Lee",
        "personality": "멘토 따뜻한 집밥파 (warm mentor, homestyle)",
        "silhouette": "permed wavy medium hair + round reading glasses",
        "color": "mauve top + beige cardigan",
        "identity_prompt": """The character MRS LEE (이씨 아주머니), a Korean
middle-aged woman in her 50s, a warm motherly mentor (neighbor 아주머니) who loves
mild / umami / fermented / hearty homestyle food. CRITICAL: Mrs Lee must look CLEARLY
DIFFERENT from the family MOTHER character — Mrs Lee is the neighborhood mentor, NOT
the player's mother. SILHOUETTE ANCHOR: short modern PERMED WAVY salt-and-pepper
gray-and-black hair in a soft loose medium-length cut (clearly NOT a round-bun — Mrs
Lee has visible wavy permed texture and is grayer/older) PLUS small simple round
reading glasses (warm brown thin frame over the eyes — her unique signature
accessory). COLOR ANCHOR: a soft warm BEIGE knit cardigan over a dusty MAUVE / rose
collar shirt (fill with Walnut-softened beige cardigan + dusty mauve top — an earthy
warm-neutral palette, clearly NOT the warm coral of the family mother, NOT a bright
block). The vibe is warm, kindly, mentoring — an 아주머니 who shows up saying "keep
it clean with deep savory flavor" with a patient encouraging posture.""",
    },
    {
        "id": "seoyeon",
        "display_name": "Seoyeon",
        "personality": "집밥파 따뜻 (cozy homebody)",
        "silhouette": "long straight hair to the shoulders",
        "color": "cream / oat turtleneck (plum accent)",
        "identity_prompt": """The character SEOYEON (서연), a Korean adult female in her
early 30s, a friendly cozy homebody who loves hearty / salty / umami comfort food.
SILHOUETTE ANCHOR: medium-to-long straight dark brown hair falling to the shoulders
with a simple natural straight cut and soft front bangs (clearly NOT Mina's side
ponytail, NOT Mrs Lee's permed wavy — Seoyeon's silhouette reads as the long-straight
hair woman). COLOR ANCHOR: a soft warm CREAM / oat-beige turtleneck sweater (fill with
a cozy oat-cream, with an optional muted PLUM / dusty purple subtle tone on a scarf or
collar accent — clearly different from Mrs Lee's mauve+beige combo and Mina's yellow),
with a small soft gold stud earring accent. The vibe is friendly, cozy, homebody — a
30s friend who shows up saying "I want hearty home-style seasoning" with a relaxed
kind posture.""",
    },
    {
        "id": "mother_01",
        "display_name": "Mother",
        "personality": "담백 집밥 (warm home-style mother)",
        "silhouette": "round-bun with white strands + apron strap",
        "color": "warm coral jeogori-silhouette top",
        "identity_prompt": """The character MOTHER (어머니), a Korean family mother in
her 50s, warm and nurturing, who loves mild / sweet / hearty home-style food. This is
a NEW bust avatar for the family mother (previously only result-screen reactions
existed). SILHOUETTE ANCHOR: hair tied back in a soft ROUND BUN with a few white/gray
strands mixed in (a tidy mother's bun — clearly different from Mrs Lee's loose permed
wavy cut), and a thin apron strap visible over the shoulder. COLOR ANCHOR: a soft
WARM CORAL jeogori-silhouette top (a simple Korean jeogori SHAPE — soft rounded collar
overlap — filled with warm coral, WITHOUT elaborate embroidery or formal hanbok
detail; this is a gentle everyday home top hinting at the jeogori silhouette, NOT a
formal ceremonial hanbok), with a simple cream apron. The warm coral clearly
distinguishes Mother from Mrs Lee's mauve+beige. The vibe is gentle, loving,
home-style — a mother who shows up saying "let's have something warm and home-style"
with a soft caring smile.""",
    },
    {
        "id": "father_01",
        "display_name": "Father",
        "personality": "호방 (hearty bold father)",
        "silhouette": "salt-and-pepper short hair, broad shoulders",
        "color": "single-color tan / warm cardigan",
        "identity_prompt": """The character FATHER (아버지), a Korean family father in
his 50s, hearty and dependable, who loves spicy / salty / savory bold food. This is a
NEW bust avatar for the family father (previously only result-screen reactions
existed). SILHOUETTE ANCHOR: short, neat SALT-AND-PEPPER gray-and-black hair (slightly
receding, mature) with slightly broad steady shoulders — a reliable dependable
silhouette. COLOR ANCHOR: a single-color warm TAN / camel cardigan or button-up over a
simple cream collar (fill with warm tan / Walnut-leaning camel — a calm warm-neutral
block, clearly different from the cool tones; this warm tan distinguishes Father). A
hint of a friendly mature face, optional small soft laugh-lines. The vibe is hearty,
warm, dependable — a father who shows up saying "make it bold — bring the heat!" with
a steady reassuring smile.""",
    },
]


# ─────────────────────────────────────────────────────────────────────────────
# 4 EMOTIONS — Style Bible §4.5 emotion sheet (bad/okay/good/excellent mapping).
# Phase B = neutral (okay) 1개 / Phase C = happy(good) / excited(excellent) /
# disappointed(bad) 3개 (image edit, base = Phase B neutral). Warm tone consistent.
# ─────────────────────────────────────────────────────────────────────────────
EMOTIONS_PHASE_B = [
    {
        "id": "neutral",
        "expression_prompt": """EXPRESSION (neutral — default attentive friendly state,
Style Bible §4.5 "okay / ★2-3" baseline, anchor seed for all 4 emotions of this
character):

EYES:
- Small rounded black dot eyes (each with the single tiny white highlight point),
  OPEN and looking forward in a normal alert friendly state (NOT closed, NOT wide
  cartoon, NOT off-center). Eyebrows relaxed neutral.

MOUTH:
- A SUBTLE small arc smile (gentle upward curve, mouth closed, corners softly lifted
  just a touch — a polite friendly default "hello" smile, NOT a big grin, NOT a
  frown, NOT an open smile).

BODY LANGUAGE + ICONS:
- Head upright, posture relaxed and friendly.
- NO emotion icons (heart / sparkle / star / motion lines) — neutral is the
  zero-icon baseline.

This reads as DEFAULT FRIENDLY ATTENTION — the character is greeting / ready, a
clearly readable "hi, I'm here" state. This is the anchor seed for the other 3
emotions (they modulate from this warm storybook baseline).""",
    },
]

EMOTIONS_PHASE_C = [
    {
        "id": "happy",
        "expression_prompt": """EXPRESSION CHANGE — happy (clearly pleased state, Style
Bible §4.5 "good / ★4", "oh, this is good!" friendly happy reaction):

EYES (happy crescent):
- Both eyes softly CLOSED into clear UPWARD CRESCENT ARC SHAPES (^_^ happy eye
  crinkles) — a warm storybook smile-eyes shape that reads "yes, this makes me
  happy" at a glance.

MOUTH (clearly happy):
- Mouth slightly OPEN in a small-to-medium open smile or soft O-shape "oh!" smile
  (clearly larger than the neutral closed arc), a clear "oh, this is really good!"
  reaction. The mouth interior is a small clean flat fill (NOT detailed teeth/tongue
  — reserved for excited peak).

BODY LANGUAGE + ICONS:
- Head upright, shoulders slightly raised in a happy posture.
- 1 to 2 small simple flat geometric SPARKLE icons (4-point sparkle, single color
  Sesame Gold #F2B33D, about 1/12 head size each) floating near the upper head/face
  as a modest happy amplifier.

ONLY change the FACIAL EXPRESSION and add the small sparkle icons. Keep ABSOLUTELY
EVERYTHING ELSE IDENTICAL to the base image — hair shape / hair color / outfit
color / outfit shape / face proportions / chibi proportions / Cocoa outline
thickness / muted warm saturation / warm peach blush #E89A7A tone / BG Cream
#FBF3E4 background — all UNCHANGED.

CRITICAL: This is the CLEARLY HAPPY state (between neutral and excited). Eyes are
CLEARLY closed in happy crescent ^_^ (NOT dot eyes, NOT yet the excited peak). Mouth
is OPEN in a clear O-or-arc (bigger than neutral, smaller than excited GIANT wide
open). Sparkles are MODEST (1-2, NOT the excited cluster). NO crying tears, NO sad
downturned mouth.""",
    },
    {
        "id": "excited",
        "expression_prompt": """EXPRESSION CHANGE — excited (peak joy state, Style Bible
§4.5 "excellent / ★5", "waa!! this is the best!!" delighted peak reaction — but kept
within Style Bible §8 SUBTLE premium VFX restraint, NOT Royal Match explosion):

EYES (peak happy):
- Both eyes CLOSED into pronounced HAPPY UPWARD CRESCENT ARCS (^___^, noticeably
  larger and more delighted than the happy emotion's regular crescent — bold peak
  smile-stroke curves). OPTIONAL: a 4-point STAR SPARKLE accent ADJACENT to the
  closed arc (a SEPARATE small flat geometric icon floating just outside the eye,
  NOT enlarged anime sparkly pupils inside the eye — the eye stays a chibi happy
  closed arc).

MOUTH (peak):
- Mouth OPEN in a GIANT delighted smile (clearly larger and more open than the happy
  emotion's O-shape) — a clear "wow!!" big open smile with a small hint of teeth
  (simple flat off-white fill across the top edge of the mouth opening). This is the
  peak open-mouth grin.

BODY LANGUAGE + ICONS (subtle premium amplification — NOT explosion):
- BOTH mitten hands raised near the cheeks or just above the shoulders in a delighted
  "wow!!" gesture (both clearly visible in the bust frame, rounded mitten shapes).
- Body posture slightly raised / leaning forward (subtle upward energy, NOT jumping
  out of frame).
- 2 to 3 small simple flat geometric SPARKLE icons (4-point sparkle, single color
  Sesame Gold #F2B33D, varied sizes about 1/14 to 1/10 head size) floating around the
  upper head as a modest sparkle accent. Keep it SUBTLE — Style Bible §8 forbids a
  big confetti burst / screen explosion. (At most 1 small 5-point star may join the
  sparkles, but keep the total count restrained — NO 5+ particle storm.)

ONLY change the FACIAL EXPRESSION + add the raised hands + add the modest sparkle
accent. Keep ABSOLUTELY EVERYTHING ELSE IDENTICAL to the base image — hair shape /
hair color / outfit color / outfit shape / face proportions / chibi proportions /
Cocoa outline thickness / muted warm saturation / warm peach blush #E89A7A tone /
BG Cream #FBF3E4 background — all UNCHANGED.

CRITICAL:
- Eyes MUST be HAPPY closed-arc shapes (giant upward crescent smile-strokes, NOT sad
  closed eyes, NOT sleeping, NOT crying). Any sparkle near the eyes is a SEPARATE
  floating geometric icon OUTSIDE the eye, NOT anime shoujo sparkly pupils inside.
- Sparkle / star icons MUST be SIMPLE FLAT GEOMETRIC (single color each, NO internal
  shading, NO 3D, NO detailed anime rays).
- Amplification stays within warm cozy premium-casual (Cooking Diary / Animal
  Restaurant tone), NOT slapstick Looney Tunes (no x-eyes, no tongue lolling, no
  comic stink lines), and NOT Royal Match screen-explosion (Style Bible §8 subtle
  VFX — restrained sparkle count, NO confetti storm).""",
    },
    {
        "id": "disappointed",
        "expression_prompt": """EXPRESSION CHANGE — disappointed (subtle negative
reaction, Style Bible §4.5 "bad / ★1", "hmm... this isn't quite what I wanted"
subdued disappointment — explicitly subtle / mature, NOT sad sobbing crying, and
explicitly NOT eyes-closed sleeping):

EYES (subtle disappointment):
- Small black dot eyes (with the tiny highlight), OPEN but with a slight droop / a
  look slightly downward-or-aside (gaze slightly off the center-forward axis). NOT
  closed, NOT crying, NOT teary, NOT the peaceful sleeping closed-eye look.
- LOWERED EYEBROWS (one or both brows tilted slightly inward-and-down toward the
  nose center) — this is the HERO cue of disappointment. Make it clearly visible as
  small simple flat brow strokes angled inward-down.

MOUTH (subtle frown):
- A small CLOSED downturned arc / small straight ㅡ mouth (corners tilt slightly DOWN
  instead of up) — a subtle clear "not pleased" cue. NOT a big sad wail, NOT an
  extreme upside-down U, NOT an open mouth. Closed mouth, no teeth, no tongue.

BODY LANGUAGE + ICONS:
- Head slightly TILTED DOWN-AND-AWAY (subtle ~10-15 degree tilt). Shoulders slightly
  DROPPED (subtle slump vs neutral's upright posture).
- Optional: ONE small simple flat geometric SWEAT DROP icon (light blue teardrop
  shape, about 1/14 head size) near the temple as a comic "well... this is awkward"
  symbol (the standard manga awkward symbol, NOT actual sweat, NOT distress), OR a
  single small "..." (three small dots) near the head. ONE icon max.
- NO sparkle / NO heart / NO star (those are positive amplifiers).

ONLY change the FACIAL EXPRESSION + add the optional single sweat drop or "..." icon.
Keep ABSOLUTELY EVERYTHING ELSE IDENTICAL to the base image — hair shape / hair
color / outfit color / outfit shape / face proportions / chibi proportions / Cocoa
outline thickness / muted warm saturation / warm peach blush #E89A7A tone / BG Cream
#FBF3E4 background — all UNCHANGED.

CRITICAL — subtle disappointment, NOT sad crying:
- NO crying tears, NO teardrop falling from the eye, NO sad sobbing open mouth, NO
  downturned pout, NO eyes-closed-sad-peaceful position. Guest/family disappointment
  is a SUBTLE MATURE "this isn't what I wanted" reaction, NOT child-like crying.
- Cue hierarchy = (1) LOWERED EYEBROWS angled inward-down (HERO — MUST be clearly
  visible) / (2) SUBTLE DOWNTURNED CLOSED MOUTH (small but clearly downward) /
  (3) optional single sweat drop or "..." icon.
- The warm peach blush #E89A7A stays the same (NOT removed — the character is still
  warm/friendly, just disappointed in this one dish). Posture is subtly slumped, NOT
  dramatically collapsed.""",
    },
]


# ─────────────────────────────────────────────────────────────────────────────
# Path / Constants
# ─────────────────────────────────────────────────────────────────────────────
OUT_DIR = PROJECT_ROOT / "assets-raw" / "character_pack_m2"
SUPPORTED_EDIT_SIZES = {(1024, 1024), (1536, 1024), (1024, 1536)}


TRANSPARENT_BG_OVERRIDE = """
BACKGROUND OVERRIDE — FULLY TRANSPARENT (alpha cutout):
Render the character on a FULLY TRANSPARENT background (alpha PNG) instead of the cream
background. The cutout around the whole character (head, shoulders, and any raised
arms/hands) must be a CLEAN crisp silhouette — NO black smudge, NO dark halo, NO grey
fringe, NO cutout artifact, NO leftover background patch around the arm/hand/shoulder
edges. The Cocoa #3A2A1E 3-4px outline stays consistent all the way around."""


def build_prompt_phase_b(character: dict, emotion: dict, background: str = "opaque") -> str:
    """Phase B = character identity + neutral expression + STYLE_SUFFIX_CHARACTER.

    background='transparent' 면 TRANSPARENT_BG_OVERRIDE 를 suffix 뒤에 부착해
    Cream bg 지시를 덮고 native alpha cutout 으로 생성 (clean arm/hand edges)."""
    bg_override = TRANSPARENT_BG_OVERRIDE if background == "transparent" else ""
    return (
        f"A warm cozy premium-casual mobile game character bust-up portrait. "
        f"{character['identity_prompt']}\n\n"
        f"{emotion['expression_prompt']}\n\n"
        f"{STYLE_SUFFIX_CHARACTER}"
        f"{bg_override}"
    )


def build_prompt_phase_c(character: dict, emotion: dict) -> str:
    """Phase C = image edit COMMON_FRAME (family IP lock) + emotion change.

    art-pipeline-correction §6 (Character Consistency Checklist): 8개 LOCK 속성
    (skin/hair color/eye color/clothing color/accent color/silhouette/line weight/
    shading)을 emotion 간 픽셀-동일 톤으로 박제 + clean-transparent (arm/hand
    dark-halo·smudge·cutout artifact 금지) 강화."""
    common_frame = f"""Keep the EXACT SAME character identity as the base image. This is
the character {character['display_name']} ({character['personality']}) — maintain the
EXACT identity from the base image.

IDENTITY LOCK — these 8 attributes MUST stay PIXEL-IDENTICAL in tone to the base image
(do NOT recolor, do NOT shift shade or saturation, do NOT drift between emotions):
1. SKIN TONE — the exact same warm skin shade (not lighter, not darker).
2. HAIR COLOR — the exact same hair color and shade (e.g. the same dark brown, NOT
   drifting toward black or a different brown).
3. EYE COLOR — the same black dot eyes with the single white highlight.
4. CLOTHING COLOR — the exact same outfit fill color and saturation.
5. ACCENT / MOTIF COLOR — the same small chest motif (chili / strawberry / lemon /
   etc.) in the same color and same position.
6. SILHOUETTE — the same hair shape, same outfit shape, same storybook chibi
   1 to 1.3-1.6 head-to-body proportions.
7. LINE WEIGHT — the same Cocoa #3A2A1E outline at 3-4px (warm dark, NOT pure black),
   identical thickness.
8. SHADING STYLE — the same soft 2-tone cel shading and the same warm peach blush
   #E89A7A at ~40%.
CHANGE ONLY: facial expression, eyebrow, eye shape, mouth, hand gesture / pose, and a
small emotion fx (per the emotion block below). Everything in the 8-attribute LOCK
stays UNCHANGED.

Crop to BUST-UP PORTRAIT (head and shoulders only, framed from chest up — NO full
body, NO legs, NO feet). Hands/arms can extend slightly into the bust frame for the
excited raised-hand gesture, but the LOWER BODY stays cropped out.

BACKGROUND — FULLY TRANSPARENT (alpha cutout), CLEAN silhouette:
- Render on a FULLY TRANSPARENT background (alpha PNG) — NO cream plate, NO scene.
- The cutout around the WHOLE character (head, shoulders, AND any raised arms/hands)
  must be a CLEAN crisp silhouette: NO black smudge, NO dark halo, NO grey fringe, NO
  cutout artifact, NO leftover background patch around the arm / hand / shoulder edges.
- The outer outline stays the consistent soft Cocoa #3A2A1E 3-4px all the way around
  (including around raised hands) — no broken or dark-clumped edges.
- (If a background must be drawn instead of transparent, use SOLID BG Cream #FBF3E4
  with one soft warm ellipse shadow — but transparent alpha is preferred for clean
  arm/hand edges.)

{emotion['expression_prompt']}

{STYLE_SUFFIX_CHARACTER}"""
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
) -> None:
    """gpt-image-1 image edit API → output_path 저장 (gen_guest_avatars 패턴).

    art-pipeline-correction D2/D9: background='transparent' 를 edit API 에 전달해
    opaque cream 상속을 끊고 native alpha cutout 생성 (rembg u2net 의 arm/hand
    dark-halo artifact 원천 차단). edit API 가 background 를 미지원하는 SDK 버전이면
    TypeError fallback 으로 background 없이 재호출."""
    edit_path, size = ensure_edit_compatible_size(base_path)
    edit_kwargs = dict(model="gpt-image-1", image=None, prompt=prompt, size=size,
                       quality=quality, n=1)
    if background in {"transparent", "opaque", "auto"}:
        edit_kwargs["background"] = background
    with open(edit_path, "rb") as f:
        edit_kwargs["image"] = f
        try:
            result = client.images.edit(**edit_kwargs)
        except TypeError:
            # 구 openai SDK: edit() 가 background 미지원 → 제거 후 재시도
            edit_kwargs.pop("background", None)
            f.seek(0)
            edit_kwargs["image"] = f
            print("   (note) edit API background 미지원 SDK — opaque 로 진행, "
                  "후처리 rembg isnet+alpha-matting 권장")
            result = client.images.edit(**edit_kwargs)
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


def run_phase_b(
    client: OpenAI,
    characters: list[dict],
    args: argparse.Namespace,
) -> tuple[list[str], list[tuple[str, str]]]:
    """Phase B = N character neutral generation (prompt-only)."""
    successes: list[str] = []
    failures: list[tuple[str, str]] = []
    neutral = EMOTIONS_PHASE_B[0]

    for i, character in enumerate(characters, 1):
        cid = character["id"]
        out_path = args.out_dir / f"{cid}_{neutral['id']}_{args.version}.png"
        prompt = build_prompt_phase_b(character, neutral, args.background)

        print(f"\n[Phase B {i}/{len(characters)}] {cid} neutral -> {out_path.name}")
        t_start = time.time()
        try:
            generate_image(
                client=client,
                prompt=prompt,
                output_path=out_path,
                model="gpt-image-1",
                size="1024x1024",
                quality=args.quality,
                background=args.background,
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
            print(f"   Run Phase B first: py tools/gen_character_pack.py --phase B --only {cid}")
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
        description="Priority 1 Character Production Pack — 7 character × 4 emotion "
        "= 28 PNG (Style Bible v1 warm tone, 2-pass neutral gen + emotion image edit)"
    )
    parser.add_argument(
        "--phase", type=str, default="ALL",
        choices=["B", "C", "ALL"],
        help="B = neutral 7장 / C = emotion 21장 / ALL = B then C (총 28장)",
    )
    parser.add_argument(
        "--only", type=str, default="",
        help="콤마구분 character ID만 (예: junho,mina). 빈 값 = 7 character 전체.",
    )
    parser.add_argument(
        "--emotion", type=str, default="",
        choices=["", "happy", "excited", "disappointed"],
        help="Phase C 한정 — 특정 emotion만 (빈 값 = 3 emotion 전체).",
    )
    parser.add_argument(
        "--quality", type=str, default="medium",
        choices=["low", "medium", "high", "auto"],
        help="gpt-image-1 quality.",
    )
    parser.add_argument(
        "--background", type=str, default="opaque",
        choices=["transparent", "opaque", "auto"],
        help="transparent=native alpha cutout (production 권장 — arm/hand dark-halo "
             "artifact 차단, art-pipeline-correction D9 옵션 A) / opaque=Cream bg(검수).",
    )
    parser.add_argument(
        "--version", type=str, default="v1",
        help="파일명 suffix (기본 v1 → junho_neutral_v1.png)",
    )
    parser.add_argument(
        "--out-dir", type=Path, default=OUT_DIR,
        help="출력 디렉터리 (기본: assets-raw/character_pack_m2/)",
    )
    args = parser.parse_args()

    only_set = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    selected = [c for c in CHARACTERS if (only_set is None or c["id"] in only_set)]
    if not selected:
        sys.exit(f"--only mismatch. Valid IDs: {[c['id'] for c in CHARACTERS]}")

    if args.emotion:
        selected_emotions = [e for e in EMOTIONS_PHASE_C if e["id"] == args.emotion]
    else:
        selected_emotions = EMOTIONS_PHASE_C

    args.out_dir.mkdir(parents=True, exist_ok=True)

    unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
    unit = unit_map.get(args.quality, 0.042)

    phase_b_count = len(selected) if args.phase in ("B", "ALL") else 0
    phase_c_count = len(selected) * len(selected_emotions) if args.phase in ("C", "ALL") else 0
    total_count = phase_b_count + phase_c_count
    est_total = unit * total_count

    print("=" * 70)
    print("Priority 1 Character Production Pack (gpt-image-1, Style Bible v1 warm)")
    print(f"   phase: {args.phase}")
    print(f"   characters: {len(selected)} ({[c['id'] for c in selected]})")
    if args.phase in ("C", "ALL"):
        print(f"   emotions (Phase C): {[e['id'] for e in selected_emotions]}")
    print(f"   quality: {args.quality} (${unit:.3f}/img)")
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
        print("PHASE B — character neutral generation (prompt-only)")
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
