"""
K-Food Master — M1 후반 sprint 양친 reaction 6컷 anchor 자동 생성.

ADR-005 Scene 3 식탁 reaction — 음식 완성 후 양친(어머니/아버지)이 식탁에서 먹으며
사용자 score에 따른 ★1/★2/★3 expression variant를 표현.

친구 가족 단위 (project_adr003 2026-05-23 lock): 어머니 + 아버지 L11 동시 unlock
(0.6s 시차 fade-in). 각 reaction = single character portrait (bust-up / 어깨까지),
Week 1 commit 7a6cffb base (`assets-raw/week1-anchors/`):
  - CH-02_mother.png   = 어머니 base (red top + apron + warm motherly smile, 음식 그릇 들고)
  - CH-03_father.png   = 아버지 base (green shirt + dark pants + thumb-up + slim smile)
  - CH-04_mother_star1.png = 어머니 ★1 reaction Week 1 variant (sad/teardrop — 본 sprint
    재해석 시 mild satisfaction subtle smile로 교체. 사용자 silent ACK 후 final lock 결정)
  - CH-05_father_star3.png = 아버지 ★3 reaction Week 1 variant (excited eyes-closed-arc
    + sparkle + double thumb-up + wide open smile — 본 sprint settle 형태에 가장 가까움)

ADR-005 Total Score 가중 평균 (재료 25% × 준비 20% × 방법 20% × 시간 35%):
  - ★1: 30%+ (mild satisfaction, 받아들일 만함)
  - ★2: 60%+ (happy, 만족)
  - ★3: 90%+ (very happy / excited, 황홀)

friends-system 호불호 axis (project_adr003 v0.2): 어머니/아버지 음식별 호불호
(spicy/sweet/oily/salty/mild) → Total Score + 호불호 보너스 = 최종 reaction.

reaction 6컷 = 어머니 × {★1, ★2, ★3} + 아버지 × {★1, ★2, ★3}:
  R-01 mother_star1   subtle warm smile, eyes normal, 입꼬리 살짝 up (motherly nurturing)
  R-02 mother_star2   bigger warm smile, eyes 부드러운 호, 입 살짝 open (pleased)
  R-03 mother_star3   big smile, eyes closed-arc happy + soft sparkle, 입 wide open
  R-04 father_star1   reserved slim smile, eyes normal, 약간의 끄덕임 가능 (남성적 reserved)
  R-05 father_star2   relaxed enjoyment smile, eyes 부드러운 호, 입 살짝 open
  R-06 father_star3   excited big smile, eyes closed-arc + sparkle, 입 wide open + thumb-up

각 reaction은:
  - single character portrait (bust-up 어깨까지, no full body)
  - Week 1 base와 동일 캐릭터 (얼굴/머리/옷/family IP)
  - 표정만 ★1/★2/★3 gradient에 따라 다름
  - background: Cool Sage `#C8D5C0` solid (음식 카드/cut/ingredient anchor와 cross-asset
    일관성). 단 캐릭터 5장 CH-01~05의 soft mint `#9BE0D2`와는 다른 톤 — 이는 reaction
    이 Scene 3 식탁(가족 식탁 tier 2) context에 속하므로 음식/cut/ingredient의 Cool Sage
    cross-asset cluster에 합류시키는 결정. 향후 reaction이 어색하다면 V2에서 soft mint
    `#9BE0D2`로 revert 가능.
  - modern saturated + slim outline 2-3px + chibi mascot proportions (Royal Match aesthetic)
  - optional Scene 3 context cue (젓가락 하나, 입가 음식 한 조각) — minor accent only

art-director docs/prompts-library.md v1.16 §5.7 STYLE_SUFFIX_REACTION + 6 reaction
prompt를 그대로 inline 임베드.

Usage:
    py tools/gen_reaction_anchors_m1.py
    py tools/gen_reaction_anchors_m1.py --only R-01                  # 1장만
    py tools/gen_reaction_anchors_m1.py --only R-01,R-04             # 일부 (어머니/아버지 ★1)
    py tools/gen_reaction_anchors_m1.py --model gpt-image-1 --quality medium
    py tools/gen_reaction_anchors_m1.py --version v2                  # 파일명 suffix

Default:
    model    = gpt-image-1 (medium quality)
    quality  = medium ($0.042/img × 6 = ~$0.25 total)
    size     = 1024x1024 (square 1:1)
    out_dir  = assets-raw/reaction_anchors_m1/
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
# STYLE_SUFFIX_REACTION — 모든 양친 reaction anchor prompt 끝에 부착
# prompts-library.md v1.16 §5.7 STYLE_SUFFIX_REACTION.
# 캐릭터 anchor 톤 (chibi mascot + slim outline + modern saturated) 통일
# + Cool Sage bg (음식/cut/ingredient cross-asset)
# + bust-up portrait (Scene 3 식탁 reaction)
# + Korean family IP 일관성 (Week 1 CH-02/CH-03 base 유지)
# ─────────────────────────────────────────────────────────────────────────────
STYLE_SUFFIX_REACTION = """Format: square 1:1.
View: bust-up portrait (head and shoulders only, NOT full body — Scene 3 식탁 reaction
context where the character is seated at the family dinner table, framed from chest up).
Style: modern mobile casual game character portrait, clean 2D illustration in Royal Match
(Dream Games 2021) modern saturated palette + Subway Surfers chibi mascot energy.
Chibi mascot proportions, head-to-body ratio approximately 1 to 1.7 (big head, smaller
visible shoulders/upper body), reaction portrait pose (NOT static blank standing —
the body language reflects the eating/tasting reaction).

CHARACTER CONSISTENCY (Family IP from Week 1 anchors):
- The mother character (어머니, early 50s) has the same family IP as Week 1 CH-02_mother
  anchor (`assets-raw/week1-anchors/CH-02_mother.png`): round-bun short black hair as a
  simple dark shape, simple V-collar Korean jeogori-style top in vivid persimmon red
  (#F23E3E or #FF8A1F warm red-orange single fill), soft white apron over the top, two
  small black dot eyes, no nose, LIGHT pink (#FFCFCF) soft cheek blush, warm motherly
  vibe.
- The father character (아버지, early 50s) has the same family IP as Week 1 CH-03_father
  anchor (`assets-raw/week1-anchors/CH-03_father.png`): short salt-and-pepper hair as a
  simple gray-and-black solid shape, solid teal-green button-up shirt (#2A8A6C or similar
  cool teal-green single fill), two small black dot eyes, no nose, optional LIGHT pink
  (#FFCFCF) cheek blush, kind reserved fatherly vibe.

EXPRESSION GRADIENT (the only major variation across the 6 reaction anchors — see body):
- ★1 (mild satisfaction, score 30%+): subtle small arc smile + eyes normal open (two small
  black dots) + body language reserved. Mother = soft warm subtle smile (nurturing
  acceptable). Father = slim reserved smile (a bit stoic but acceptable).
- ★2 (happy / pleased, score 60%+): bigger smile + eyes start to soften into gentle upward
  arcs + mouth slightly open in pleasure. Mother = bigger warm smile with crinkled-eye
  warmth. Father = relaxed enjoyment smile, more open than ★1.
- ★3 (very happy / excited, score 90%+): big wide smile + eyes closed-arc happy (or
  sparkle) + mouth wide open ("delicious!" expression). Mother = big motherly delight,
  soft sparkle accent OK. Father = excited big smile, more animated than ★2, optional
  thumb-up gesture if shoulder visible.

OPTIONAL SCENE 3 CONTEXT CUE (minor accent, do NOT dominate):
- Optional: 1 pair of modern wooden chopsticks (젓가락) held in one mitten hand near the
  mouth OR a small bite-sized food morsel near the lips. This is a MINOR accent only —
  the reaction expression is the hero, NOT the eating prop. If unsure, omit the prop and
  focus on the facial expression.

BACKGROUND:
- Solid Cool Sage #C8D5C0 background (cross-asset consistency with food + environment +
  cut + ingredient anchor clusters — the M1 후반 19-asset cluster of cut 7 + ingredient
  whole 12 + this reaction sprint 6 = 25 assets share Cool Sage bg for one-game-world
  identity at the Scene 3 dinner table moment).
- Single subtle ambient ellipse shadow under the character bust (#000 ~25% alpha).

COLOR + OUTLINE:
- Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), single color fill on
  clothing (2-3 color blocks max) with optional soft 1-layer cel shading.
- Vibrant saturated colors at 80-90 percent saturation, warm/cool balance (warm
  red/orange/green clothing + warm pink cheek + cool sage bg).

Important: avoid beige background, cream paper background, scrapbook, storybook, kraft
paper, vintage texture, golden hour, sunset warm lighting,
Cookie Run, Cookie Run Kingdom frosting style, Toca Boca, Toon Blast over-cartoony,
deep dark pink cheek, heavy blush,
anime girl, manga style, big sparkly anime-style eyes (the optional ★3 sparkle is a small
simple flat geometric icon, NOT anime sparkle), school uniform, fanservice or sexy
elements,
realistic or photorealistic rendering, 3D render, octane or unreal engine,
any texture, noise, painterly or hand-painted feel, watercolor, gradient mesh,
multi-layer complex shading, hyperdetailed elements, individual finger detail (mitten
hands only), nose detail,
traditional Korean mortar, mortar and pestle, stirring with mortar,
Japanese (kimono, geisha, hashioki chopstick rest with kanji), Chinese (qipao,
chopsticks with chinese knot), Western (knife and fork Western table setting),
dark, gritty, cinematic, golden hour or dramatic lighting,
sleeping, eyes closed peaceful (the ★3 closed-arc is a HAPPY smiling arc, NOT a sad
sleeping closed eye), crying, tears,
full body, lower body, legs, feet (this is a bust-up portrait, head and shoulders only),
multiple characters in one image (single subject per reaction anchor — mother and father
are separate anchors, NOT combined),
any English or Korean text legibly readable (NO speech bubbles, NO captions)."""


# ─────────────────────────────────────────────────────────────────────────────
# REACTIONS — 6개 항목 (어머니 ★1/★2/★3 + 아버지 ★1/★2/★3)
# prompts-library.md v1.16 §5.7.1 ~ §5.7.6 본문 inline.
# 각 항목: id (R-XX) / name (slug) / character (mother/father) / star (1/2/3) / body.
# STYLE_SUFFIX_REACTION은 자동 append via build_prompt .replace().
# ─────────────────────────────────────────────────────────────────────────────
REACTIONS = [
    {
        "id": "R-01",
        "name": "mother_star1",
        "character": "mother",
        "star": 1,
        # §5.7.1 어머니 ★1 — mild satisfaction (subtle warm smile)
        "body": """A modern mobile casual game character portrait of the gentle Korean mother
character (어머니, early 50s, same family IP as Week 1 CH-02_mother anchor — round-bun
short black hair as a simple dark shape, simple V-collar Korean jeogori-style top in
vivid persimmon red, soft white apron over the top), showing a ★1 (mild satisfaction)
reaction expression at the Scene 3 family dinner table after tasting the player's
prepared dish.

EXPRESSION (★1 mild satisfaction, score 30-59 percent — acceptable but not exciting):
- Two small black dot eyes, OPEN and looking forward in a normal alert state (NOT closed,
  NOT wide cartoon-style — just normal open dot eyes).
- A SUBTLE small arc smile (small gentle upward curve, mouth closed, the corners of the
  mouth softly lifted just a touch — a polite warm motherly "this is okay, I appreciate
  it" smile, NOT a big delighted smile, NOT a frown).
- LIGHT pink (#FFCFCF) soft cheek blush, motherly warm.
- Head slightly tilted to one side (a small ~5-10 degree tilt, suggesting gentle
  contemplative warmth — a motherly nurturing acknowledgment of the food).
- Optional: one mitten hand visible near the chin in a small "thoughtful tasting"
  gesture, OR holding a single pair of wooden chopsticks near the lips (minor accent only,
  do not dominate the portrait).

The reaction reads as MILD WARM ACCEPTANCE — the mother appreciates the dish but it
hasn't truly wowed her. The warmth of the motherly nurturing tone is preserved (NOT cold,
NOT disappointed, NOT sad), just at the low end of the satisfaction gradient.

%s

Important also: this is the mother's ★1 (mild satisfaction) reaction — the smile MUST be
SUBTLE and SMALL (small arc, mouth closed, lifted just a touch). NOT a big wide ★3
delighted grin, NOT a sad/disappointed teardrop expression (the Week 1 CH-04_mother_star1
showed a sad teardrop variant — this v1 reroll replaces it with a positive subtle smile
to match the ★1 = "mild satisfaction acceptable" gradient definition). The eyes are
NORMAL OPEN dot eyes (NOT closed, NOT crying). The motherly warmth is preserved (NOT
stoic, NOT cold). Reference Week 1 CH-02_mother.png for the family IP base (hair / outfit
/ face features) — only the expression changes for the ★1 variant. Single character
bust-up portrait — NO father in this image (father is a separate anchor)."""
    },
    {
        "id": "R-02",
        "name": "mother_star2",
        "character": "mother",
        "star": 2,
        # §5.7.2 어머니 ★2 — happy / pleased (bigger warm smile)
        "body": """A modern mobile casual game character portrait of the gentle Korean mother
character (어머니, early 50s, same family IP as Week 1 CH-02_mother anchor — round-bun
short black hair as a simple dark shape, simple V-collar Korean jeogori-style top in
vivid persimmon red, soft white apron over the top), showing a ★2 (happy / pleased)
reaction expression at the Scene 3 family dinner table after tasting the player's
prepared dish.

EXPRESSION (★2 happy / pleased, score 60-89 percent — solidly satisfied, nice work):
- Two small black dot eyes, slightly softened into GENTLE UPWARD CRESCENT ARCS (still
  small simple shapes, but starting to curve upward at the corners like a happy
  smiling-eye crinkle — a clear step up from ★1 normal-open dots toward ★3 fully closed
  happy arcs).
- A BIGGER warm smile compared to ★1 — the mouth is slightly OPEN in a small open-arc
  smile (showing a small hint of mouth interior, like a gentle "oh, this is really
  good!" smile, NOT just a closed-mouth polite smile).
- LIGHT pink (#FFCFCF) soft cheek blush, slightly more visible than ★1 (motherly warm
  glow).
- Head naturally upright, body language relaxed and pleased.
- Optional: one mitten hand visible holding a small white rice bowl OR wooden chopsticks
  in a "happily eating" gesture (minor accent only, do not dominate the portrait).

The reaction reads as GENUINE WARM HAPPINESS — the mother is solidly pleased with the
dish, the motherly nurturing tone amplifies into clear pleased warmth. A clear visual
step up from ★1 (subtle) but not yet at the ★3 ecstatic level.

%s

Important also: this is the mother's ★2 (happy / pleased) reaction — the smile MUST be
clearly BIGGER than ★1 (open mouth, soft eye crescent arcs) but clearly SMALLER than ★3
(NOT a wide open "wow!" delighted grin, NOT closed-arc fully happy eyes yet — this is
the middle gradient step). The eyes are at the IN-BETWEEN state (slight upward crescent
soft arcs, NOT fully open dots like ★1, NOT fully closed-arc happy like ★3). The
motherly warmth is amplified vs ★1 but reserved vs ★3. Reference Week 1 CH-02_mother.png
for the family IP base — only the expression changes for the ★2 variant. Single
character bust-up portrait — NO father in this image (father is a separate anchor)."""
    },
    {
        "id": "R-03",
        "name": "mother_star3",
        "character": "mother",
        "star": 3,
        # §5.7.3 어머니 ★3 — very happy / excited (big delighted smile + closed-arc eyes)
        "body": """A modern mobile casual game character portrait of the gentle Korean mother
character (어머니, early 50s, same family IP as Week 1 CH-02_mother anchor — round-bun
short black hair as a simple dark shape, simple V-collar Korean jeogori-style top in
vivid persimmon red, soft white apron over the top), showing a ★3 (very happy / excited
/ delighted) reaction expression at the Scene 3 family dinner table after tasting the
player's prepared dish.

EXPRESSION (★3 very happy / excited, score 90-100 percent — wow, delicious!):
- Eyes CLOSED into HAPPY UPWARD ARC SHAPES (smiling eyes, two upward crescent arcs like
  small smile-strokes — clearly HAPPY closed-arc shape, NOT sad closed eyes, NOT
  sleeping eyes). Alternative: small simple flat geometric sparkle accents (single color,
  NOT detailed anime sparkle) near the eyes/temples if the closed-arc reads ambiguously.
- A BIG WIDE delighted smile — the mouth is WIDE OPEN in a clear delighted "wow, this
  is delicious!" open-mouth grin (clearly larger and more open than ★2 small open-arc
  smile). Optional: showing a small hint of teeth/tongue/mouth-interior (simple flat
  fill, NOT detailed anatomical interior).
- LIGHT pink (#FFCFCF) soft cheek blush, clearly visible glow (the deepest pink blush
  level across the 3 gradient steps, but still LIGHT pink — NOT deep dark Cookie Run
  frosting pink).
- Body language joyful: both mitten hands raised near cheeks in delight, OR one hand
  holding chopsticks/bowl excitedly, OR clasped near the chest in motherly pride.
  Optional: 1-2 small simple flat geometric heart icons (single color red, NOT detailed)
  floating near the head as accent.

The reaction reads as PURE MOTHERLY DELIGHT — the mother is truly impressed and excited
by the dish, the warmest most amplified version of her motherly nurturing tone.

%s

Important also: this is the mother's ★3 (very happy / excited) reaction — the smile MUST
be CLEARLY BIG WIDE OPEN (more open than ★2, the most expressive across the 3 gradient
steps). The eyes MUST be in HAPPY closed-arc shapes (upward crescent smile shapes, NOT
sad closed eyes, NOT sleeping eyes, NOT crying tears). Reference Week 1 CH-02_mother.png
for the family IP base + Week 1 CH-05_father_star3.png for the ★3 expression intensity
reference (similar level of excitement, motherly variant). The motherly warmth is at
peak amplification. If sparkle icons are included they MUST be small simple flat
geometric (single color, NOT detailed anime sparkle effects). Reference Week 1
CH-02_mother.png for the family IP base (hair / outfit / face features) — only the
expression changes for the ★3 variant. Single character bust-up portrait — NO father in
this image (father is a separate anchor)."""
    },
    {
        "id": "R-04",
        "name": "father_star1",
        "character": "father",
        "star": 1,
        # §5.7.4 아버지 ★1 — reserved slim smile (남성적 reserved)
        "body": """A modern mobile casual game character portrait of the kind Korean father
character (아버지, early 50s, same family IP as Week 1 CH-03_father anchor — short
salt-and-pepper hair as a simple gray-and-black solid shape, solid teal-green button-up
shirt, kind reserved fatherly vibe), showing a ★1 (mild satisfaction, reserved) reaction
expression at the Scene 3 family dinner table after tasting the player's prepared dish.

EXPRESSION (★1 mild satisfaction, score 30-59 percent — acceptable but reserved):
- Two small black dot eyes, OPEN and looking forward in a normal alert state (NOT
  closed, NOT wide cartoon-style — just normal open dot eyes, like Week 1 CH-03_father
  base default expression).
- A SLIM RESERVED small arc smile (small narrow arc, mouth closed, the corners of the
  mouth lifted just a slight touch — a polite reserved "this is okay" father's smile,
  more stoic and less expressive than the mother's subtle smile at the same ★1 level,
  reflecting the more reserved masculine fatherly tone, NOT a frown, NOT a big delighted
  smile).
- Optional VERY LIGHT pink (#FFCFCF) cheek blush, much lighter than the mother's blush
  at the same level (fathers tend to show less visible blush).
- Head naturally upright, body posture upright and reserved (not slumped, not animated
  yet at this low gradient step).
- Optional: one mitten hand visible near the chin in a small "thoughtful evaluation"
  gesture (like the Week 1 CH-03_father base), OR holding wooden chopsticks/a small
  bowl reservedly (minor accent only).

The reaction reads as RESERVED ACCEPTANCE — the father quietly approves the dish but
doesn't outwardly express much, in line with the more stoic masculine fatherly tone at
the low gradient step. NOT cold disapproval, NOT angry, NOT disappointed — just calmly
accepting.

%s

Important also: this is the father's ★1 (mild satisfaction, reserved) reaction — the
smile MUST be SLIM and RESERVED (small narrow arc, mouth closed, just a slight touch of
mouth corner lift). NOT a big wide ★3 excited grin, NOT a frown or disapproval
expression. The eyes are NORMAL OPEN dot eyes. The fatherly reserved masculine tone is
amplified at this low gradient step (less expressive than the mother's ★1 subtle smile
— fathers express reservedly at low gradients, but the gradient direction is still
POSITIVE acceptance). Reference Week 1 CH-03_father.png for the family IP base (hair /
outfit / face features) — only the expression changes for the ★1 variant (the
CH-03_father base default expression is roughly the ★1-★2 boundary slim smile +
thumb-up; this ★1 variant trims that to a slimmer mouth-closed smile without the
thumb-up). Single character bust-up portrait — NO mother in this image (mother is a
separate anchor)."""
    },
    {
        "id": "R-05",
        "name": "father_star2",
        "character": "father",
        "star": 2,
        # §5.7.5 아버지 ★2 — relaxed enjoyment smile (open arc, fuller)
        "body": """A modern mobile casual game character portrait of the kind Korean father
character (아버지, early 50s, same family IP as Week 1 CH-03_father anchor — short
salt-and-pepper hair as a simple gray-and-black solid shape, solid teal-green button-up
shirt, kind reserved fatherly vibe), showing a ★2 (happy / relaxed enjoyment) reaction
expression at the Scene 3 family dinner table after tasting the player's prepared dish.

EXPRESSION (★2 happy / relaxed enjoyment, score 60-89 percent — genuinely satisfied,
the father relaxes and smiles more openly):
- Two small black dot eyes, slightly softened into GENTLE UPWARD CRESCENT ARCS (still
  small simple shapes, but starting to curve upward at the corners like a happy
  smiling-eye crinkle — a clear step up from ★1 normal-open dots toward ★3 fully closed
  happy arcs). Slightly less pronounced crescent than the mother at the same level
  (fathers crinkle eyes a bit less openly than mothers, but the gradient direction is
  the same).
- A FULLER more open smile compared to ★1 — the mouth is slightly OPEN in a relaxed
  small open-arc smile (clearly larger than ★1's mouth-closed slim arc, suggesting the
  father has dropped his reserved posture into genuine relaxed enjoyment), like a
  contented "this is really good" father's smile.
- LIGHT pink (#FFCFCF) cheek blush, slightly more visible than ★1 (warmth glow).
- Head naturally upright, body language relaxed (one shoulder slightly relaxed,
  suggesting comfort).
- Optional: one mitten hand visible giving a small subtle thumb-up gesture (like a
  toned-down version of the Week 1 CH-03_father base thumb-up — at ★2 the thumb-up is
  small and casual, at ★3 it can be more enthusiastic), OR holding wooden chopsticks/a
  bowl in relaxed enjoyment.

The reaction reads as GENUINE RELAXED FATHERLY APPROVAL — the father's reserved
posture has dropped into clear relaxed enjoyment, the masculine warmth is amplified vs
★1 but still restrained vs ★3. A clear visual step up from ★1 (slim reserved) but not
yet at the ★3 ecstatic level.

%s

Important also: this is the father's ★2 (happy / relaxed enjoyment) reaction — the
smile MUST be clearly FULLER than ★1 (mouth slightly open, soft eye crescent arcs,
relaxed body) but clearly SMALLER than ★3 (NOT a wide open "wow!" delighted grin, NOT
double thumb-up energetic gesture yet, NOT closed-arc fully happy eyes yet — this is
the middle gradient step). The eyes are at the IN-BETWEEN state (slight upward
crescent soft arcs, NOT fully open dots like ★1, NOT fully closed-arc happy like ★3).
The fatherly reserved masculine tone is amplified vs ★1 (clearly relaxed) but reserved
vs ★3 (NOT yet at full excitement). Reference Week 1 CH-03_father.png for the family
IP base — the CH-03_father base default expression is very close to this ★2 level
(slim smile + small thumb-up), so this anchor stays close to base with slight
softening of the eyes into crescent arcs to differentiate from ★1. Single character
bust-up portrait — NO mother in this image (mother is a separate anchor)."""
    },
    {
        "id": "R-06",
        "name": "father_star3",
        "character": "father",
        "star": 3,
        # §5.7.6 아버지 ★3 — very happy / excited (big smile + closed-arc + thumb-up)
        "body": """A modern mobile casual game character portrait of the kind Korean father
character (아버지, early 50s, same family IP as Week 1 CH-03_father anchor — short
salt-and-pepper hair as a simple gray-and-black solid shape, solid teal-green button-up
shirt, kind reserved fatherly vibe), showing a ★3 (very happy / excited / delighted)
reaction expression at the Scene 3 family dinner table after tasting the player's
prepared dish. This anchor is very close to the Week 1 CH-05_father_star3 variant
(excited eyes-closed-arc + sparkle + thumb-up + wide smile) — the Week 1 variant is
roughly the settle form for the ★3 step.

EXPRESSION (★3 very happy / excited, score 90-100 percent — wow, delicious! big
fatherly approval):
- Eyes CLOSED into HAPPY UPWARD ARC SHAPES (smiling eyes, two upward crescent arcs like
  small smile-strokes — clearly HAPPY closed-arc shape, NOT sad closed eyes, NOT
  sleeping eyes). Like the Week 1 CH-05_father_star3 base reference.
- A BIG WIDE delighted smile — the mouth is WIDE OPEN in a clear delighted "wow, son/
  daughter, this is GREAT!" open-mouth grin (clearly larger and more open than ★2 small
  open-arc smile). Optional: showing a small hint of teeth (simple flat fill, NOT
  detailed anatomical).
- LIGHT pink (#FFCFCF) cheek blush, clearly visible warm glow (still LIGHT pink — NOT
  deep dark Cookie Run frosting pink).
- Body language energetic and excited (clearly more animated than ★2): one or BOTH
  mitten hands giving an enthusiastic thumb-up gesture (Week 1 CH-05_father_star3
  variant shows double thumb-up with one fist raised — this is the settle pose for ★3,
  clearly more energetic than ★2's small casual single thumb-up), with the body
  slightly tilted forward in excitement.
- Optional: 2-4 small simple flat geometric sparkle accents (single color yellow/orange,
  NOT detailed anime sparkle effects, similar to Week 1 CH-05_father_star3 sparkle
  pattern) floating near the head/face/raised fist as accent — these communicate
  excitement.

The reaction reads as PEAK FATHERLY EXCITEMENT — the father is genuinely impressed and
proud, the warmest most amplified version of his masculine fatherly tone breaking
through his usual reserved posture into clear delight. This is the visual peak of the
★1 → ★2 → ★3 gradient for the father.

%s

Important also: this is the father's ★3 (very happy / excited) reaction — the smile
MUST be CLEARLY BIG WIDE OPEN (more open than ★2, the most expressive across the 3
gradient steps for the father). The eyes MUST be in HAPPY closed-arc shapes (upward
crescent smile shapes, NOT sad closed eyes, NOT sleeping eyes, NOT crying tears). The
fatherly reserved masculine tone is at peak amplification breaking into clear
excitement. The thumb-up gesture (one or both hands) is the signature fatherly
masculine excitement pose. If sparkle icons are included they MUST be small simple flat
geometric (single color, NOT detailed anime sparkle effects) — Week 1 CH-05_father_star3
sparkle pattern is the visual reference. Reference Week 1 CH-03_father.png for the
family IP base (hair / outfit / face features) + Week 1 CH-05_father_star3.png for the
★3 expression settle form — this ★3 v1 anchor should look very similar to
CH-05_father_star3 (the Week 1 variant is already close to the settle form for ★3, only
re-rendering for consistency with the new bust-up format + Cool Sage bg cross-asset
alignment). Single character bust-up portrait — NO mother in this image (mother is a
separate anchor)."""
    },
]


def build_prompt(body: str) -> str:
    """body의 첫 %s를 STYLE_SUFFIX_REACTION으로 교체. body의 다른 % 문자(예: "30-59 percent")는
    .format / f-string과 달리 .replace로 안전 보존 (gen_food/gen_ingredient에서 동일 패턴 fix).
    """
    return body.replace("%s", STYLE_SUFFIX_REACTION, 1)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="M1 후반 양친 reaction 6컷 anchor 자동 생성 (어머니/아버지 × ★1/★2/★3)"
    )
    parser.add_argument(
        "--only", type=str, default="",
        help="콤마구분 reaction ID만 (예: R-01,R-04). 빈 값=전체 6장."
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
        default=PROJECT_ROOT / "assets-raw" / "reaction_anchors_m1",
        help="출력 디렉터리"
    )
    parser.add_argument(
        "--version", type=str, default="v1",
        help="파일명 suffix (예: v1 → R-01_mother_star1_v1.png)"
    )
    args = parser.parse_args()

    only_set = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    selected = [r for r in REACTIONS if (only_set is None or r["id"] in only_set)]

    if not selected:
        sys.exit(f"❌ --only 매칭 reaction 없음. 유효 ID: {[r['id'] for r in REACTIONS]}")

    args.out_dir.mkdir(parents=True, exist_ok=True)

    # cost estimate
    if args.model == "dall-e-3":
        unit = 0.080 if args.quality == "hd" else 0.040
    else:
        unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
        unit = unit_map.get(args.quality, 0.042)
    est_total = unit * len(selected)
    print("=" * 70)
    print("👨‍👩‍👧 M1 후반 양친 reaction 6컷 anchor 생성 시작 (Scene 3 식탁 ★1/★2/★3)")
    print(f"   모델: {args.model} / 품질: {args.quality} / 사이즈: {args.size}")
    print(f"   대상: {len(selected)}장 ({[r['id'] for r in selected]})")
    print(f"   비용 예상: ${unit:.3f}/장 × {len(selected)} = ${est_total:.2f}")
    print(f"   출력: {args.out_dir}")
    print("=" * 70)

    api_key = load_api_key()
    client = OpenAI(api_key=api_key)

    successes: list[str] = []
    failures: list[tuple[str, str]] = []
    t0 = time.time()

    for i, reaction in enumerate(selected, 1):
        rid = reaction["id"]
        name = reaction["name"]
        character = reaction["character"]
        star = reaction["star"]
        out_path = args.out_dir / f"{rid}_{name}_{args.version}.png"
        prompt = build_prompt(reaction["body"])

        print(f"\n[{i}/{len(selected)}] {rid} ({character} ★{star}) → {out_path.name}")
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
            successes.append(rid)
        except Exception as exc:
            elapsed = time.time() - t_start
            print(f"   ❌ FAIL ({elapsed:.1f}s): {exc!r}")
            failures.append((rid, repr(exc)))

    total_elapsed = time.time() - t0
    print("\n" + "=" * 70)
    print(f"✅ 완료: {len(successes)}/{len(selected)} 장 — 총 {total_elapsed/60:.1f}분")
    if successes:
        print(f"   성공: {', '.join(successes)}")
    if failures:
        print(f"   실패 {len(failures)}장:")
        for rid, err in failures:
            print(f"     - {rid}: {err}")
    print(f"   비용 예상: ${unit * len(successes):.2f}")
    print(f"   저장 경로: {args.out_dir}")
    print("=" * 70)


if __name__ == "__main__":
    main()
