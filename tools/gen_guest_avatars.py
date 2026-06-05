"""
K-Food Master — Phase B + C guest avatar 5 + 15 = 20 PNG 생성 driver.

art-director docs/prompts-library.md v1.24 §5.15 Guest avatar prompt set 기반.
Phase B (2026-06-04) = 5 guest neutral bust-up portrait 자동 생성 (prompt-only,
gpt-image-1 medium). Phase C = 각 guest의 happy / excited / disappointed 3 emotion
variant를 Phase B neutral output을 base로 image edit API로 생성 (family IP lock).

5 guest (guests.csv v3.0 + game-designer notes 매핑):
  - junho      (호방 매콤 매니아, male 20s-30s, energetic, "Make it nice and spicy
                today!", fav=spicy/salty/hearty)
  - mina       (단맛 발랄, female 20s, cheerful, "I've got a serious sweet tooth!",
                fav=sweet/savory/oily)
  - riley      (외국인 산뜻함, foreign / non-Korean exchange resident, "Give me
                something tangy!", fav=sour/fresh/umami)
  - mrs_lee    (멘토 따뜻한 집밥파, female 50s-60s, warm motherly mentor, "Keep it
                clean with it.", fav=mild/umami/fermented/hearty)
  - seoyeon    (집밥파 따뜻, female 30s, friendly homebody, "Give me something
                cozy!", fav=hearty/salty/umami/sweet)

4 emotion (neutral overlap, Phase C는 happy/excited/disappointed 3개만 신규):
  - neutral      (정상 dot eyes + 살짝 arc smile, R-02/R-05 톤 — anchor seed default)
  - happy        (closed crescent ^_^ + 살짝 open mouth — R-02 base intensification)
  - excited      (BIG wide open smile + sparkle eyes + 양손 raised — R-03/R-06 코믹 톤)
  - disappointed (subtle frown 또는 lowered eyebrows + closed mouth, sad/crying X —
                  Result Screen "bad" emotion 정의)

각 emotion 공통 (CH-01~03 family + R-01~06 reaction과 cross-asset cluster 합류):
  - bust-up portrait (어깨까지, NOT full body)
  - chibi mascot proportions 1:1.7 (Week 1 CH-01~03와 일관)
  - Cool Sage `#C8D5C0` solid bg + slim outline 2-3px (warm dark #2D1D14)
  - modern saturated 80-90% (Royal Match aesthetic)
  - cross-cultural negative (Japanese / Chinese / Western 누수 회피)

ChatGPT (gpt-image-1) — ADR-006 lock 채택. Phase B = `client.images.generate()`,
Phase C = `client.images.edit(model="gpt-image-1", image=open(neutral, "rb"), ...)`
(edit_reaction_anchors_v3.py와 동일 패턴 — base image dimensions 검증 + PIL resize
fallback + b64_json 응답 처리).

Usage:
    # Phase B (5 neutral 생성)
    py tools/gen_guest_avatars.py --phase B
    py tools/gen_guest_avatars.py --phase B --only junho        # 1장만
    py tools/gen_guest_avatars.py --phase B --only junho,mina   # 일부
    py tools/gen_guest_avatars.py --phase B --quality high      # 고품질 (~5x cost)

    # Phase C (15 emotion variants 생성 — Phase B neutral output 필수 prerequisite)
    py tools/gen_guest_avatars.py --phase C
    py tools/gen_guest_avatars.py --phase C --only junho        # junho 3 emotion
    py tools/gen_guest_avatars.py --phase C --emotion happy     # 5 guest happy
    py tools/gen_guest_avatars.py --phase C --only junho --emotion excited

    # 전체 batch (Phase B 5장 + Phase C 15장 = 20장 순차)
    py tools/gen_guest_avatars.py --phase ALL

Default:
    model    = gpt-image-1 (medium quality)
    quality  = medium ($0.042/img × 20 = ~$0.84 total)
    size     = 1024x1024 (square 1:1)
    out_dir  = assets-raw/guest_avatars_m1/
    version  = v1
    파일명   = {guest_id}_{emotion}_{version}.png
                (예: junho_neutral_v1.png / junho_happy_v1.png)
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
# STYLE_SUFFIX_GUEST_AVATAR — 5 guest × 4 emotion = 20장 공통 suffix.
# prompts-library.md v1.24 §5.15 STYLE_SUFFIX_GUEST_AVATAR.
# Week 1 CH-01~03 + R-01~06 reaction과 일관성 + bust-up portrait + cross-cultural
# negative (Japanese / Chinese / Western anime girl 회피).
# ─────────────────────────────────────────────────────────────────────────────
STYLE_SUFFIX_GUEST_AVATAR = """Format: square 1:1.
View: bust-up portrait (head and shoulders only, NOT full body — framed from chest
up, similar to Week 1 CH-01~03 character portraits + R-01~06 reaction portraits).
Style: modern mobile casual game character portrait, clean 2D illustration in Royal
Match (Dream Games 2021) modern saturated palette + Subway Surfers chibi mascot
energy. Chibi mascot proportions, head-to-body ratio approximately 1 to 1.7 (big
head, smaller visible shoulders/upper body), consistent with Week 1 CH-01 protagonist
+ CH-02 mother + CH-03 father anchor proportions for cross-asset family identity.

GUEST IDENTITY (Korean / global friend NPCs — NOT family members, NOT mother/father
character IP from CH-02/CH-03 — these are guest customer characters that the player
serves, see body for guest-specific identity).

EYES + FACE STRUCTURE (chibi consistency with Week 1 + reaction anchors):
- Two small black dot eyes (chibi mascot small dots, NOT enlarged anime shoujo
  pupils with multiple highlight stars inside — like Week 1 CH-01~03 + R-01~06
  reaction style). Eye shape modulates per emotion (see body for the specific
  emotion).
- No nose detail (chibi convention, like CH-01~03).
- Optional LIGHT pink (#FFCFCF) soft cheek blush (same tone as R-01~06 reactions,
  NOT deep dark Cookie Run frosting pink).

BACKGROUND:
- Solid Cool Sage #C8D5C0 background (cross-asset consistency with the 83+ M1
  anchor cluster: food 12 + env 5 + char 5 + cut 7 + ingredient whole 12 +
  ingredient cut 12 + reaction 6 + tool 12 + UI 7 + VFX 5 + guest 20 = 103-anchor
  cluster).
- Single subtle ambient ellipse shadow under the character bust (#000 ~25% alpha).

COLOR + OUTLINE:
- Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), single color
  fill on clothing (2-3 color blocks max) with optional soft 1-layer cel shading.
- Vibrant saturated colors at 80-90 percent saturation, warm/cool balance.

Important: avoid beige background, cream paper background, scrapbook, storybook,
kraft paper, vintage texture, golden hour, sunset warm lighting,
Cookie Run, Cookie Run Kingdom frosting style, Toca Boca, Toon Blast over-cartoony,
deep dark pink cheek, heavy blush,
anime girl, manga style, big sparkly anime-style eyes (sparkle accents stay
SEPARATE floating geometric icons OUTSIDE the eye, NOT enlarged shoujo pupils
inside), school uniform, fanservice or sexy elements,
realistic or photorealistic rendering, 3D render, octane or unreal engine,
any texture, noise, painterly or hand-painted feel, watercolor, gradient mesh,
multi-layer complex shading, hyperdetailed elements, individual finger detail
(mitten hands only), nose detail,
mother character IP CH-02 hair/outfit (round-bun + persimmon red jeogori + white
apron — that is the family mother, NOT a guest), father character IP CH-03
hair/outfit (salt-and-pepper hair + teal-green button-up — that is the family
father, NOT a guest), protagonist CH-01 IP (bowl-cut + orange hoodie — that is
the player avatar, NOT a guest),
Japanese (kimono, geisha, hashioki, yukata), Chinese (qipao, hanfu, cheongsam,
chinese knot), Western (cowboy hat, lederhosen — Western casual clothing is OK
only if the guest is the foreign 외국인 character Riley, see body),
mortar and pestle (절구), Korean hanbok traditional formal wear (these guests
are modern casual friends, NOT in traditional formal hanbok),
dark, gritty, cinematic, golden hour or dramatic lighting,
sleeping, eyes closed peaceful (happy emotion closed-arc eyes are upward HAPPY
smile-strokes, NOT sad sleeping closed eyes), crying tears, downturned mouth
with tear (disappointed emotion is a subtle frown / lowered eyebrows, NOT
crying / NOT teardrop / NOT sad sobbing — sad is reserved for family failure
context, NOT guest disappointment),
full body, lower body, legs, feet (this is a bust-up portrait, head and
shoulders only — arms/hands can extend into bust frame for excited emotion
raised-hand gestures),
multiple characters in one image (single subject per guest avatar — each guest
emotion is a separate anchor, NOT combined),
any English or Korean text legibly readable (NO speech bubbles, NO captions,
NO name labels on clothing — the chibi guest stands alone)."""


# ─────────────────────────────────────────────────────────────────────────────
# 5 GUESTS — id / display_name / personality / identity_prompt
# Each identity_prompt = guest 시각 시그니처 (hair / outfit / accessory / vibe).
# Korean casual modern friend identity (NOT family, NOT player avatar). Cross-
# cultural negative per-guest (Riley = foreign 외국인 explicit OK).
# ─────────────────────────────────────────────────────────────────────────────
GUESTS = [
    {
        "id": "junho",
        "display_name": "Junho",
        "personality": "호방 매콤 매니아 (bold spicy enthusiast)",
        "identity_prompt": """The guest character JUNHO, a Korean young adult male in
his 20s-to-early-30s, an energetic and bold friend who loves spicy / salty / hearty
food. Visual identity: short messy modern dark brown hair (slightly spiky / tousled
front, NOT bowl-cut like CH-01 protagonist, NOT salt-and-pepper like CH-03 father
— younger and more energetic). Solid bold red graphic t-shirt (#E04848 single fill,
modern crew neck casual streetwear) with a small flat geometric flame icon or
chili pepper icon graphic on the chest (single color accent, optional — small and
subtle, NOT dominating). Optional thin gray hoodie cord visible at the neckline
suggesting layered modern Korean street fashion. The vibe is energetic, friendly,
bold — a guy who shows up saying "Make it nice and spicy today!" with confident
posture.""",
    },
    {
        "id": "mina",
        "display_name": "Mina",
        "personality": "단맛 발랄 (cheerful sweet-tooth)",
        "identity_prompt": """The guest character MINA, a Korean young adult female
in her 20s, a cheerful bubbly friend who loves sweet / savory / oily food. Visual
identity: medium-length warm chestnut brown hair styled in a soft side ponytail
or two small side-swept layers with a small flat geometric pastel pink hair clip
or hair band accent at one side (single color #F4B4C9 light pink, simple shape).
Soft pastel pink pullover sweater or oversized cardigan (#F8C4D0 single fill,
modern casual cozy) with optional small flat geometric heart icon or strawberry
icon graphic at the chest (single color accent, subtle small). The vibe is
cheerful, sweet, bubbly — a girl who shows up saying "I've got a serious sweet
tooth!" with bright open posture.""",
    },
    {
        "id": "riley",
        "display_name": "Riley",
        "personality": "외국인 산뜻함 (foreign fresh-tangy)",
        "identity_prompt": """The guest character RILEY, a non-Korean foreign 외국인
young adult in their 20s living in Korea (foreign exchange resident / global
friend — explicitly NOT a Korean ethnic identity, may have lighter skin tone,
lighter or warmer hair color like warm honey blonde / strawberry blonde / soft
light brown, or freckles, a global cosmopolitan friend who loves sour / fresh /
umami / tangy food). Riley is gender-neutral / androgynous (could be perceived as
male or female — keep facial structure soft and casual). Visual identity: short
modern wavy warm honey-blonde or soft light brown hair (NOT Asian black hair —
this is the ONE guest who breaks the Korean dark-hair convention, the foreign
identity is the design point). Optional small flat geometric round freckle
accents (3-5 small dots) on the cheeks as a subtle foreign-identity cue. Solid
fresh mint-green or light yellow casual hoodie or pullover (#B4E4C4 mint green or
#F4E48C light yellow single fill, modern casual streetwear with a slightly
oversized cozy fit). Optional small flat geometric lemon slice icon or leaf icon
graphic at the chest (single color accent, subtle small). The vibe is bright,
fresh, globally-inclusive — a friend who shows up saying "Give me something
tangy!" with relaxed open posture.""",
    },
    {
        "id": "mrs_lee",
        "display_name": "Mrs Lee",
        "personality": "멘토 따뜻한 집밥파 (warm motherly mentor, homestyle)",
        "identity_prompt": """The guest character MRS LEE (Mrs. Lee 이씨 아주머니), a
Korean middle-aged woman in her 50s-to-early-60s, a warm motherly mentor figure
who loves mild / umami / fermented / hearty Korean homestyle food. CRITICAL:
Mrs Lee must look CLEARLY DIFFERENT from CH-02 family mother — Mrs Lee is the
neighborhood mentor 아주머니, NOT the player's mother. Visual identity: short
modern permed wavy gray-and-black salt-and-pepper hair styled in a soft loose
medium-length cut (NOT the round-bun of CH-02 mother — Mrs Lee has VISIBLE wavy
permed texture and is LONGER than CH-02's tight round-bun, AND grayer to reflect
her slightly older age). Soft warm beige or cream knit cardigan over a simple
mauve / dusty rose collar shirt (#D8B4A4 dusty mauve top + #E4D4B8 beige cardigan
single fills — cool warm earthy palette, NOT the persimmon red of CH-02 mother
jeogori, NOT the cool teal-green of CH-03 father shirt — clearly different
clothing family). Optional small simple flat geometric round glasses (warm
brown frame, subtle thin circles over the eyes — Mrs Lee wears reading glasses
as a mentor signature, this is her unique identity accessory). The vibe is
warm, kindly, mentoring — a 아주머니 who shows up saying "Keep it clean with
it." with patient encouraging posture.""",
    },
    {
        "id": "seoyeon",
        "display_name": "Seoyeon",
        "personality": "집밥파 따뜻 (friendly homestyle homebody)",
        "identity_prompt": """The guest character SEOYEON (서연), a Korean adult
female in her early 30s, a friendly cozy homebody who loves hearty / salty /
umami / sweet comfort food. Visual identity: medium-length straight dark brown
hair (slightly longer than chin-length, falling to the shoulders, simple natural
straight cut — NOT the short side-ponytail of Mina, NOT the permed wavy hair of
Mrs Lee). Soft warm cream or oat-beige turtleneck sweater or pullover (#E8D8C4
oat single fill, cozy modern homebody clothing — clearly different from Mrs
Lee's mauve+beige cardigan combo and CH-02 mother's red jeogori). Optional very
small flat geometric warm gold stud earring accent (single small dot per ear,
subtle minimal jewelry). The vibe is friendly, cozy, homebody — a 30s friend who
shows up saying "Give me something cozy!" with relaxed kind posture.""",
    },
]


# ─────────────────────────────────────────────────────────────────────────────
# 4 EMOTIONS — id / expression_prompt
# Phase B = neutral 1개 / Phase C = happy / excited / disappointed 3개 (image edit
# base = Phase B neutral output, family IP lock).
# ─────────────────────────────────────────────────────────────────────────────
EMOTIONS_PHASE_B = [
    {
        "id": "neutral",
        "expression_prompt": """EXPRESSION (neutral — default attentive friendly state,
similar tone to R-02 mother ★2 base default or R-05 father ★2 base default, anchor
seed for all 4 emotions of this guest):

EYES:
- Two small black dot eyes, OPEN and looking forward in a normal alert friendly
  state (NOT closed, NOT wide cartoon-style, NOT narrowed / NOT off-center — just
  normal open dot eyes facing the viewer in a friendly default state).
- Eyebrows in a relaxed neutral position (NOT raised, NOT furrowed).

MOUTH:
- A SUBTLE small arc smile (gentle upward curve, mouth closed, the corners of the
  mouth softly lifted just a touch — a polite friendly default "hello" smile, NOT
  a big delighted grin, NOT a frown, NOT an open smile).

BODY LANGUAGE + EMOTION ICONS:
- Head naturally upright, body posture upright and relaxed friendly.
- Optional: one mitten hand at the side or in a small friendly small wave gesture
  near the shoulder (subtle, minimal — the neutral pose is mostly still default).
- NO emotion icons (heart / sparkle / star / motion lines) — neutral is the
  zero-icon baseline state.

The reaction reads as DEFAULT FRIENDLY ATTENTION — the guest is greeting / ready
to order, in a clearly readable "hi, I'm here" default state. This is the anchor
seed expression for all 4 emotions of this guest (the other 3 emotions modulate
from this baseline).""",
    },
]

EMOTIONS_PHASE_C = [
    {
        "id": "happy",
        "expression_prompt": """EXPRESSION CHANGE — happy (clearly pleased state,
score 60-89 percent satisfaction, "Oh, this is good!" friendly happy reaction,
similar tone to R-02 mother ★2 v3 happy expression):

EYES (happy crescent):
- Both eyes CLOSED into clear UPWARD CRESCENT ARC SHAPES (^_^ shape) — clearly
  happy smiling eye crinkles, classic cartoon happy-eyes shape that reads "yes,
  this makes me happy" at a glance.

MOUTH (clearly happy):
- Mouth slightly OPEN in a small-to-medium open smile or a soft O-shape "oh!"
  smile (clearly larger than the neutral closed arc), suggesting a clear "오~
  맛있다!" / "oh this is really good!" reaction. The mouth interior shows a small
  clean flat fill (NOT detailed teeth/tongue — those are reserved for excited
  peak).

BODY LANGUAGE + EMOTION ICONS:
- Head naturally upright, shoulders slightly raised in a happy posture.
- 1-2 small simple flat geometric SPARKLE icons "✨" (4-point sparkle, single
  color yellow/gold, NOT detailed anime sparkles with multiple rays, ~1/12 head
  size each) floating near the upper area of the head/face as comic happy
  amplifier.

ONLY change the FACIAL EXPRESSION and add the small sparkle icons per the above.
Keep ABSOLUTELY EVERYTHING ELSE IDENTICAL to the base image — hair shape / hair
color / outfit color / outfit shape / face proportions / chibi proportions /
outline thickness / color saturation / cheek blush light pink #FFCFCF tone / Cool
Sage bg — all UNCHANGED.

CRITICAL: This is the CLEARLY HAPPY state (between neutral default and excited
peak). The eyes are CLEARLY closed in happy crescent ^_^ (NOT dot eyes like
neutral, NOT yet the explosive peak with sparkle bursts). The mouth is OPEN in
clear O-or-arc shape (BIGGER than neutral closed arc, SMALLER than excited GIANT
wide open). The sparkle icons are MODEST (1-2, NOT the excited cluster of 3-6).
NO crying tears, NO sad downturned mouth.""",
    },
    {
        "id": "excited",
        "expression_prompt": """EXPRESSION CHANGE — excited (EXPLOSIVE peak joy state,
score 90-100 percent satisfaction, "Waa!! This is the BEST!!" cartoon explosive
peak reaction, similar tone to R-03 mother ★3 v3 or R-06 father ★3 v3 explosive
amplification):

EYES (cartoon explosive peak):
- Both eyes CLOSED into GIANT pronounced HAPPY UPWARD CRESCENT ARCS (^___^ shape,
  the arcs noticeably LARGER and more dramatic than the happy emotion's regular
  happy crescent — these are the peak "delighted closed-arc happy eyes" with clear
  bold smile-stroke curves).
- ALTERNATIVE (pick one or combine subtly): the eyes can also show a 4-point STAR
  SPARKLE ✨ accent ADJACENT to the closed arc (the sparkle is a SEPARATE small
  flat geometric icon floating just outside the eye area, NOT enlarged anime
  sparkly pupils inside the eye — the eye itself stays in the chibi happy
  closed-arc shape).

MOUTH (cartoon explosive peak):
- Mouth WIDE OPEN in a GIANT delighted smile (clearly larger and more open than
  the happy emotion's small-to-medium O-shape) — the open mouth shape should be a
  clear comic "와아!!" / "wow!!" big open smile with a small hint of teeth (simple
  flat white fill across the top edge of the mouth opening) and optionally a small
  hint of tongue (simple flat pink fill inside the mouth opening). This is the
  cartoon peak open-mouth grin.

BODY LANGUAGE + EMOTION ICONS (the EXPLOSIVE peak amplification):
- BOTH mitten hands raised near the cheeks OR raised above the head in a cartoon
  "와아!!" delighted gesture (both hands clearly visible in the bust-up frame,
  fingers slightly spread in joy, classic "delighted reaction" body language).
- Body posture slightly raised / leaning forward as if mid-jump (small upward
  motion implied, NOT actually full jumping out of frame — just amplified upward
  energy posture).
- 3-5 small simple flat geometric SPARKLE icons "✨" (4-point sparkle, single
  color yellow/gold, varied sizes ~1/14 to 1/10 head size each) floating around
  the head/upper area as a clear sparkle-burst cluster.
- 1-2 small simple flat geometric 5-point STAR icons "⭐" (single color yellow,
  same size range) included in the burst cluster for extra peak amplification.
- 2-3 short curved MOTION LINES (small simple thin warm dark strokes) radiating
  outward from the head/body suggesting energetic upward burst motion.

ONLY change the FACIAL EXPRESSION + add the raised hands + add the icon cluster.
Keep ABSOLUTELY EVERYTHING ELSE IDENTICAL to the base image — hair shape / hair
color / outfit color / outfit shape / face proportions / chibi proportions /
outline thickness / color saturation / cheek blush light pink #FFCFCF tone / Cool
Sage bg — all UNCHANGED.

CRITICAL:
- The eyes MUST be in HAPPY closed-arc shapes (giant upward crescent smile-
  strokes, NOT sad closed eyes, NOT sleeping peaceful eyes, NOT crying tears). If
  sparkle accent is added near eyes, it's a SEPARATE floating geometric icon
  OUTSIDE the eye, NOT enlarged anime shoujo sparkly pupils filling the eye.
- The sparkle / star icons MUST be SIMPLE FLAT GEOMETRIC (single color each, NO
  internal shading, NO 3D depth, NO detailed anime ray effects — just clean
  cartoon vector-style icons).
- The amplification stays within polished modern mobile casual (Royal Match
  aesthetic + K-drama reaction tone), NOT slapstick Looney Tunes goofy (no x-
  eyes, no tongue lolling, no comic stink lines, no character bouncing literally
  out of frame).""",
    },
    {
        "id": "disappointed",
        "expression_prompt": """EXPRESSION CHANGE — disappointed (subtle negative
reaction, score 0-29 percent satisfaction, "Hmm... this isn't quite what I
wanted" subdued disappointment, Result Screen "bad" emotion definition — explicitly
subtle / mature / NOT sad sobbing crying):

EYES (subtle disappointment):
- Two small black dot eyes, OPEN in a normal state but with a slight droop / look
  slightly downward-or-aside (the gaze is slightly off the center-forward neutral
  axis, suggesting "I don't really want to look at this"). NOT closed, NOT crying,
  NOT teary.
- LOWERED EYEBROWS (one or both eyebrows tilted slightly inward-downward toward
  the nose-center, suggesting a subtle frown / slight unhappy concentration, the
  signature visual cue of disappointment). The lowered eyebrow is the HERO cue
  for this emotion — make it clearly visible as small simple flat brow strokes
  angled inward-down.

MOUTH (subtle frown / closed-down):
- A small CLOSED FROWN or a slightly downturned closed-mouth small arc (the
  mouth corners tilt slightly DOWN instead of up like neutral's slight up-arc —
  a subtle clear "not pleased" cue). NOT a big sad open wail, NOT a downturned
  pout, NOT an extreme upside-down U — just a small subtle downward-tilted closed
  arc that reads "I'm not happy with this" at a glance.
- NO open mouth, NO visible teeth, NO tongue — disappointed is a CLOSED-mouth
  subdued state.

BODY LANGUAGE + EMOTION ICONS:
- Head slightly TILTED DOWN-AND-AWAY (subtle ~10-15 degree tilt down + slightly
  averted, suggesting "looking away from the disappointment"). NOT a dramatic
  bow-down head-on-table pose.
- Shoulders slightly DROPPED (subtle slumped posture vs neutral's upright relaxed
  posture).
- Optional: ONE small simple flat geometric SWEAT DROP icon (light blue, simple
  teardrop shape, ~1/14 head size) floating near the temple as a comic "awkward
  / not pleased" amplifier (this is the standard anime/manga "well... this is
  awkward" symbol, NOT actual sweat / NOT distress). Optional alternative: a
  single small "..." (three small dot icons) near the head as a comic "speechless
  disappointment" symbol. ONE icon max — disappointed is subdued, NOT explosive.
- NO sparkle / NO heart / NO star icons (those are positive amplifiers, reserved
  for happy / excited).

ONLY change the FACIAL EXPRESSION + add the optional single sweat drop or "..."
icon. Keep ABSOLUTELY EVERYTHING ELSE IDENTICAL to the base image — hair shape /
hair color / outfit color / outfit shape / face proportions / chibi proportions /
outline thickness / color saturation / cheek blush light pink #FFCFCF tone / Cool
Sage bg — all UNCHANGED.

CRITICAL — subtle disappointment, NOT sad crying:
- NO crying tears, NO teardrop falling from the eye, NO sad sobbing open mouth,
  NO downturned mouth pout, NO eyes-closed-sad-peaceful position. The R-01/R-04
  v1 deprecated "sad teardrop" approach is EXPLICITLY DEPRECATED for this guest
  disappointed emotion — guest disappointment is SUBTLE / MATURE adult "this
  isn't what I wanted" reaction, NOT child-like crying.
- The visual cue hierarchy = (1) LOWERED EYEBROWS angled inward-down (HERO cue
  — MUST be clearly visible) / (2) SUBTLE DOWNTURNED CLOSED MOUTH ARC (small but
  clearly downward) / (3) optional single sweat drop or "..." icon (subtle
  amplifier).
- The cheek blush stays the same LIGHT pink #FFCFCF tone (NOT removed — the
  guest is still warm/friendly, just disappointed in this specific dish).
- Body posture is subtly slumped, NOT collapsed dramatically.""",
    },
]


# ─────────────────────────────────────────────────────────────────────────────
# Path / Constants
# ─────────────────────────────────────────────────────────────────────────────
OUT_DIR = PROJECT_ROOT / "assets-raw" / "guest_avatars_m1"
SUPPORTED_EDIT_SIZES = {(1024, 1024), (1536, 1024), (1024, 1536)}


def build_prompt_phase_b(guest: dict, emotion: dict) -> str:
    """Phase B = guest identity + neutral expression + STYLE_SUFFIX_GUEST_AVATAR."""
    return (
        f"A modern mobile casual game character bust-up portrait. {guest['identity_prompt']}\n\n"
        f"{emotion['expression_prompt']}\n\n"
        f"{STYLE_SUFFIX_GUEST_AVATAR}"
    )


def build_prompt_phase_c(guest: dict, emotion: dict) -> str:
    """Phase C = image edit COMMON_FRAME (family IP lock) + emotion expression change."""
    common_frame = f"""Keep the EXACT SAME guest identity as the base image — preserve hair
shape, hair color tone, face proportions, outfit color and shape, chibi mascot 1 to
1.7 head-to-body proportions, slim bold dark outline 2-3px (warm dark #2D1D14, not
pure black), modern saturated 80-90 percent colors. The hair tone and outfit tone
MUST exactly match the base image (NOT lighter, NOT darker — same shade and
saturation). This is the guest character {guest['display_name']} ({guest['personality']}) —
maintain the EXACT identity from the base image.

Crop to BUST-UP PORTRAIT (head and shoulders only, framed from chest up — NO full
body, NO lower body, NO legs, NO feet visible). Hands/arms can extend slightly into
the bust frame for the excited emotion raised-hand gestures, but the LOWER BODY
remains cropped out.

BACKGROUND:
- Keep SOLID Cool Sage #C8D5C0 background (same as base image, cross-asset
  consistency with the 103-anchor cluster).
- Single subtle ambient ellipse shadow under the character bust (#000 ~25% alpha).

{emotion['expression_prompt']}

{STYLE_SUFFIX_GUEST_AVATAR}"""
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
    """base image가 gpt-image-1 edit API supported size면 그대로 사용. 아니면 resize."""
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
) -> None:
    """gpt-image-1 image edit API → output_path 저장 (edit_reaction_anchors_v3 패턴)."""
    edit_path, size = ensure_edit_compatible_size(base_path)
    with open(edit_path, "rb") as f:
        result = client.images.edit(
            model="gpt-image-1",
            image=f,
            prompt=prompt,
            size=size,
            quality=quality,
            n=1,
        )
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
    guests: list[dict],
    args: argparse.Namespace,
) -> tuple[list[str], list[tuple[str, str]]]:
    """Phase B = 5 guest neutral generation (prompt-only `client.images.generate`)."""
    successes: list[str] = []
    failures: list[tuple[str, str]] = []
    neutral = EMOTIONS_PHASE_B[0]  # only "neutral" in Phase B

    for i, guest in enumerate(guests, 1):
        gid = guest["id"]
        out_path = args.out_dir / f"{gid}_{neutral['id']}_{args.version}.png"
        prompt = build_prompt_phase_b(guest, neutral)

        print(f"\n[Phase B {i}/{len(guests)}] {gid} neutral -> {out_path.name}")
        t_start = time.time()
        try:
            generate_image(
                client=client,
                prompt=prompt,
                output_path=out_path,
                model="gpt-image-1",
                size="1024x1024",
                quality=args.quality,
            )
            print(f"   elapsed {time.time() - t_start:.1f}s")
            successes.append(f"{gid}_neutral")
        except Exception as exc:
            print(f"   FAIL ({time.time() - t_start:.1f}s): {exc!r}")
            failures.append((f"{gid}_neutral", repr(exc)))

    return successes, failures


def run_phase_c(
    client: OpenAI,
    guests: list[dict],
    emotions: list[dict],
    args: argparse.Namespace,
) -> tuple[list[str], list[tuple[str, str]]]:
    """Phase C = 15 emotion variants (image edit, base = Phase B neutral output)."""
    successes: list[str] = []
    failures: list[tuple[str, str]] = []

    total = len(guests) * len(emotions)
    counter = 0

    for guest in guests:
        gid = guest["id"]
        base_path = args.out_dir / f"{gid}_neutral_{args.version}.png"

        if not base_path.exists():
            print(f"\n[Phase C SKIP] {gid} base not found: {base_path}")
            print(f"   Run Phase B first: py tools/gen_guest_avatars.py --phase B --only {gid}")
            for emotion in emotions:
                counter += 1
                failures.append((f"{gid}_{emotion['id']}", f"base missing: {base_path.name}"))
            continue

        # check base dimensions
        w, h = inspect_base_image(base_path)
        compat = "OK (supported)" if (w, h) in SUPPORTED_EDIT_SIZES else "-> will resize"
        print(f"\n[Phase C base] {base_path.name}: {w}x{h} {compat}")

        for emotion in emotions:
            counter += 1
            eid = emotion["id"]
            out_path = args.out_dir / f"{gid}_{eid}_{args.version}.png"
            prompt = build_prompt_phase_c(guest, emotion)

            print(f"\n[Phase C {counter}/{total}] {gid} {eid} -- base: {base_path.name}")
            t_start = time.time()
            try:
                edit_image(client, base_path, prompt, out_path, quality=args.quality)
                print(f"   elapsed {time.time() - t_start:.1f}s")
                successes.append(f"{gid}_{eid}")
            except Exception as exc:
                print(f"   FAIL ({time.time() - t_start:.1f}s): {exc!r}")
                failures.append((f"{gid}_{eid}", repr(exc)))

    return successes, failures


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Phase B + C guest avatar 5 + 15 = 20 PNG 생성 driver "
        "(neutral generation + 3 emotion variants via image edit, family IP lock)"
    )
    parser.add_argument(
        "--phase", type=str, default="ALL",
        choices=["B", "C", "ALL"],
        help="B = neutral 5장 / C = emotion 15장 / ALL = B then C (총 20장)",
    )
    parser.add_argument(
        "--only", type=str, default="",
        help="콤마구분 guest ID만 (예: junho,mina). 빈 값 = 5 guest 전체.",
    )
    parser.add_argument(
        "--emotion", type=str, default="",
        choices=["", "happy", "excited", "disappointed"],
        help="Phase C 한정 — 특정 emotion만 (빈 값 = 3 emotion 전체).",
    )
    parser.add_argument(
        "--quality", type=str, default="medium",
        choices=["low", "medium", "high", "auto"],
        help="gpt-image-1 quality. low/medium/high/auto.",
    )
    parser.add_argument(
        "--version", type=str, default="v1",
        help="파일명 suffix (기본 v1 → junho_neutral_v1.png)",
    )
    parser.add_argument(
        "--out-dir", type=Path, default=OUT_DIR,
        help="출력 디렉터리 (기본: assets-raw/guest_avatars_m1/)",
    )
    args = parser.parse_args()

    # guest selection
    only_set = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    selected_guests = [g for g in GUESTS if (only_set is None or g["id"] in only_set)]
    if not selected_guests:
        sys.exit(f"--only mismatch. Valid guest IDs: {[g['id'] for g in GUESTS]}")

    # emotion selection (Phase C only)
    if args.emotion:
        selected_emotions = [e for e in EMOTIONS_PHASE_C if e["id"] == args.emotion]
    else:
        selected_emotions = EMOTIONS_PHASE_C

    args.out_dir.mkdir(parents=True, exist_ok=True)

    # cost estimate
    unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
    unit = unit_map.get(args.quality, 0.042)

    phase_b_count = len(selected_guests) if args.phase in ("B", "ALL") else 0
    phase_c_count = (
        len(selected_guests) * len(selected_emotions) if args.phase in ("C", "ALL") else 0
    )
    total_count = phase_b_count + phase_c_count
    est_total = unit * total_count

    print("=" * 70)
    print("Phase B + C guest avatar generation (gpt-image-1 medium)")
    print(f"   phase: {args.phase}")
    print(f"   guests: {len(selected_guests)} ({[g['id'] for g in selected_guests]})")
    if args.phase in ("C", "ALL"):
        print(f"   emotions (Phase C): {[e['id'] for e in selected_emotions]}")
    print(f"   quality: {args.quality} (${unit:.3f}/img)")
    print(f"   Phase B count: {phase_b_count} / Phase C count: {phase_c_count} / total: {total_count}")
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
        print("PHASE B — 5 guest neutral generation (prompt-only)")
        print("=" * 70)
        s, f = run_phase_b(client, selected_guests, args)
        all_successes.extend(s)
        all_failures.extend(f)

    if args.phase in ("C", "ALL"):
        print("\n" + "=" * 70)
        print(
            f"PHASE C — {len(selected_guests) * len(selected_emotions)} emotion variants "
            "(image edit, base = Phase B neutral)"
        )
        print("=" * 70)
        s, f = run_phase_c(client, selected_guests, selected_emotions, args)
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
