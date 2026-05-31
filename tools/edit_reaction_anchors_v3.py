"""
K-Food Master — M1 후반 양친 reaction 6컷 v3 image edit (CH-02/CH-03 base + 표정만 변경, **코믹 amplification**).

ADR-006 (ChatGPT/DALL-E) 기반. art-director docs/prompts-library.md v1.21
§5.7 R-01~R-06 6컷 v3 image edit prompt를 그대로 inline 임베드.

v1.21 v3 patch (2026-05-31): 사용자가 v2 (image edit, family IP consistency LOCK)
결과 시각 확인 후 verbatim 피드백 raise:
  "reaction을 코믹하게 만드는게 어때? 지금 reaction 이미지는 너무 심심해"

main thread 해석: v2는 family IP consistency 우수 + LOCK 됐으나, 표정 amplification 부족.
v2 subtle smile / big smile / single-double thumb-up gradient는 **너무 점잖음** —
"Korean variety show / K-drama reaction" 톤 부재로 player가 ★1/★2/★3 차이를 즉시
체감 못함. **cartoon-style exaggeration 3축 (눈/입/body+icons) 강화**로 코믹 amplification.

**v2 LOCK 유지 사항**:
  - family IP consistency (어머니 round-bun simple / 아버지 darker salt-and-pepper + darker teal-green) — v2 결과 PASS, image edit API 패턴 유지
  - bust-up portrait crop / Cool Sage `#C8D5C0` bg / chibi mascot proportions / slim outline 2-3px / modern saturated 80-90%
  - sad/sleeping/crying/Japanese kimono/anime girl big sparkly eyes 회피 negative

**v3 추가 변경 (코믹 amplification 3축)**:
  1. **눈 exaggeration** (★1 정상 dot → ★2 closed crescent ^_^ → ★3 별 sparkle eyes 또는 거대 closed-arc + 다중 sparkle)
  2. **입 exaggeration** (★1 wave/ㅁ-shape → ★2 O-mouth 또는 open smile → ★3 GIANT wide open with teeth/tongue)
  3. **body + emotion icons** (★1 정상 + optional small icon → ★2 한 손 + small sparkle → ★3 양손 raised + 다중 hearts/sparkles/star burst + motion lines)

**도구**: gpt-image-1 image edit API (`client.images.edit(model="gpt-image-1",
image=open(base, "rb"), prompt=COMMON_FRAME + expression, size="1024x1024",
quality="medium", n=1)`) — v2와 동일 패턴

**Base image 2장** (v2와 동일):
  - `assets-raw/week1-anchors/CH-02_mother.png`   = R-01/R-02/R-03 base (어머니)
  - `assets-raw/week1-anchors/CH-03_father.png`   = R-04/R-05/R-06 base (아버지)

각 reaction edit:
  - base = CH-02_mother (R-01~R-03) or CH-03_father (R-04~R-06)
  - prompt = COMMON_FRAME (family IP 유지 v2 그대로 + bust-up + Cool Sage bg + **코믹 amplification 명시 추가**)
             + expression_prompt (★1/★2/★3 specific + 코믹 amplification 3축 explicit)
  - output = `assets-raw/reaction_anchors_m1/R-XX_<character>_star<N>_v3.png`

이전 v1/v2 output (R-XX_<character>_star<N>_v1.png / _v2.png 12장)은 보존 (v3와 공존,
사용자 비교 가능).

Usage:
    py tools/edit_reaction_anchors_v3.py                    # 6장 batch
    py tools/edit_reaction_anchors_v3.py --only R-03        # ★3 mother test
    py tools/edit_reaction_anchors_v3.py --only R-03,R-06   # ★3 peak 둘만 test
    py tools/edit_reaction_anchors_v3.py --quality high     # 더 높은 품질 (~5x cost)

Default:
    model    = gpt-image-1 (image edit API)
    quality  = medium ($0.042/img × 6 = ~$0.25 total)
    base_dir = assets-raw/week1-anchors/
    out_dir  = assets-raw/reaction_anchors_m1/
    version  = v3
"""

import argparse
import base64
import sys
import time
from pathlib import Path

# project root sys.path 추가 — gen_image import
PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT / "tools"))

from gen_image import load_api_key  # noqa: E402

# Windows cp949 회피
if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")

from openai import OpenAI  # noqa: E402


# ─────────────────────────────────────────────────────────────────────────────
# COMMON_FRAME — 6 reaction 모두 공통 (family IP 유지 v2 + bust-up + Cool Sage bg +
# 표정만 변경 명시 + 코믹 amplification 톤 명시 추가 + sad/sleeping/crying 회피 +
# cross-cultural 회피 + anime girl big sparkly eyes over-exaggeration 회피).
# ─────────────────────────────────────────────────────────────────────────────
COMMON_FRAME = """Keep the EXACT SAME family IP as the base image — preserve hair shape
(round-bun simple short black hair for the mother / short salt-and-pepper hair as a darker
gray-and-black solid shape for the father), hair color tone, face proportions, outfit color
and shape (vivid persimmon red V-collar jeogori top + soft white apron for the mother / solid
teal-green button-up shirt for the father — keep the exact same color saturation and shade
as the base image), chibi mascot 1 to 1.7 head-to-body proportions, slim bold dark outline
2-3px (warm dark #2D1D14, not pure black), modern saturated 80-90 percent colors. The hair
shape for the mother MUST be a SIMPLE round-bun without any side-puff or side-bangs additions
beyond what the base image shows. The hair tone and shirt tone for the father MUST exactly
match the base image (NOT lighter, NOT darker — same shade and saturation).

Crop to BUST-UP PORTRAIT (head and shoulders only, framed from chest up — NO full body,
NO lower body, NO legs, NO feet visible). The character is seated at the family dinner table
(Scene 3 식탁 reaction context). Hands/arms can extend slightly into the bust frame for the
★2/★3 raised-hand gestures (one or both mitten hands visible near cheeks/over head),
but the LOWER BODY remains cropped out.

BACKGROUND:
- Replace any existing background with SOLID Cool Sage #C8D5C0 (cross-asset consistency with
  food + cut + ingredient + tool anchor clusters — the 49-asset Scene 3 cluster shares Cool Sage bg).
- Single subtle ambient ellipse shadow under the character bust (#000 ~25% alpha).

ONLY change the FACIAL EXPRESSION and add small simple flat geometric emotion icons (heart /
sparkle / star burst / motion lines / question mark / sweat drop) per the specified star level
(see expression block below). Keep ABSOLUTELY EVERYTHING ELSE IDENTICAL to the base image —
hair shape / hair color / outfit color / outfit shape / face proportions / chibi proportions /
outline thickness / color saturation / cheek blush light pink #FFCFCF tone — all UNCHANGED.

TONE TARGET (v3 코믹 amplification, NEW vs v2): the expressions should read as cartoon-style
EXAGGERATED reaction faces in the spirit of Korean variety show or K-drama exaggerated reactions
— clearly more COMIC and EXPRESSIVE than a subtle polite smile. The ★1/★2/★3 gradient is a
clearly readable EMOTION ESCALATION (mild thinking → clearly happy → EXPLOSIVE excitement),
NOT a subtle progression. Use cartoon-style facial exaggeration (eyes / mouth) plus simple
flat geometric emotion icons floating near the head for amplification at ★2 and ★3.

CRITICAL BOUNDARIES (don't cross into these failure modes):
- Avoid sad teardrop, crying tears, downturned mouth frown, sleepy closed peaceful eyes,
  disappointed cold expression. The ★3 closed-arc eyes (if applicable) are HAPPY upward
  crescent smile-strokes, NOT sad closed eyes, NOT sleeping peaceful eyes.
- Avoid anime girl big SPARKLY pupils filling the entire eye socket (Sailor Moon style is
  OUT — sparkle accents are SEPARATE floating geometric icons OUTSIDE the eye, NOT inside
  the pupil. Eye shape stays chibi mascot small dot/crescent/closed-arc, NOT enlarged anime
  shoujo pupils with multiple highlight stars inside).
- Avoid over-exaggerated goofy cartoon (eyes bulging out of head, tongue lolling like a
  cartoon dog, comic stink lines, x-eyes, swirl-eyes, tongue stretched 5x normal length).
  The amplification stays within a polished modern mobile casual frame (Royal Match aesthetic
  + Korean K-drama reaction tone), NOT slapstick Looney Tunes / Tom-and-Jerry style.
- Avoid Japanese kimono / Japanese geisha, Chinese qipao, school uniform, deep dark
  Cookie Run frosting pink cheek, Cookie Run Kingdom frosting style, realistic or
  photorealistic rendering, 3D render, octane or unreal engine, heavy texture, hand-painted
  feel, watercolor, gradient mesh, multi-layer complex shading, hyperdetailed, beige
  background, cream paper background, scrapbook, storybook, kraft paper, vintage texture,
  golden hour, sunset warm lighting, atmospheric haze.
- Avoid full body, lower body, legs, feet (this is a bust-up portrait, head and shoulders only —
  arms/hands can extend into frame for ★2/★3 gestures).
- Avoid multiple characters in one image (single subject per reaction anchor — mother and
  father are separate anchors, NOT combined).
- Avoid any English or Korean text legibly readable (NO speech bubbles, NO captions — the
  emotion icons are PURELY VISUAL geometric symbols: heart shape, 4-point sparkle, 5-point
  star, simple "?" mark, simple sweat drop, simple curved motion line. NO words)."""


# ─────────────────────────────────────────────────────────────────────────────
# REACTIONS — 6개 항목 (어머니 ★1/★2/★3 + 아버지 ★1/★2/★3) v3 코믹 amplification
# 각 항목: id (R-XX) / name (slug) / character (mother|father) / star (1|2|3) /
#         base (CH-02_mother.png or CH-03_father.png) / expression_prompt (★N specific
#         + 코믹 amplification 3축: 눈 / 입 / body+icons)
# ─────────────────────────────────────────────────────────────────────────────
REACTIONS = [
    {
        "id": "R-01",
        "name": "mother_star1",
        "character": "mother",
        "star": 1,
        "base": "CH-02_mother.png",
        "expression_prompt": """EXPRESSION CHANGE — mother ★1 v3 (MILD POSITIVE thinking, score 30-59 percent,
"음, 괜찮네!" / "Hmm, this is okay!" cartoon thinking pose, lighter version of the gradient):

EYES (cartoon thinking style):
- Two small black dot eyes, OPEN in a normal alert state, ONE eye slightly looking UP-LEFT in
  a thoughtful "let me think about this" cartoon gaze direction (the slight off-center look
  amplifies the "evaluating" comic tone vs a flat forward gaze).
- Eyebrows slightly raised / one eyebrow slightly higher than the other in a small "hmm?"
  thoughtful asymmetric tilt (small simple cartoon eyebrow strokes, NOT exaggerated).

MOUTH (cartoon thinking style):
- A small wavy line mouth or a SMALL closed wave-curve (like a "~" tilde shape) suggesting
  "considering, not bad" thinking — NOT a flat polite arc, NOT a frown, NOT a big smile.
  A clearly cartoon-style "thinking" mouth shape that reads as MILD evaluation.

BODY LANGUAGE + EMOTION ICONS:
- One mitten hand raised near the chin in a clear cartoon "hand-on-chin thinking pose"
  (index finger or whole mitten touching the chin area, classic "thinking..." gesture).
- Slight head tilt to one side (~10-15 degree tilt, a bit more pronounced than v2's subtle
  5-10 degree to amplify the "considering" tone).
- ONE small simple flat geometric QUESTION MARK icon "?" (single color warm gray, NOT
  detailed, ~1/10 of the head size) floating near the upper-right of the head as a comic
  "wondering" amplifier icon.
- Optional very small wave-curve thinking motion lines (1-2 short curved strokes) near the
  head as additional comic ambient detail.

The reaction reads as CARTOON-STYLE MILD POSITIVE EVALUATION — the mother is in a clearly
readable "hmm, this is actually okay, let me think about it" thinking pose, comic enough that
players immediately recognize this as the LOW END of the satisfaction gradient (between 0-29%
penalty zone and ★2 60% clearly happy zone). The motherly warmth is preserved through the
gentle thinking pose (NOT cold, NOT sad, NOT disappointed).

CRITICAL: This is the MILD POSITIVE acceptance reaction in cartoon thinking pose form. NOT
sad teardrop, NOT crying, NOT disappointed. The question mark icon is a comic amplifier, NOT
literal confusion (the mother is mildly pleased while thoughtfully evaluating). The Week 1
CH-04_mother_star1 sad teardrop variant is deprecated — this v3 ★1 is a comic warm thinking
pose, the lowest positive gradient step with clear cartoon amplification."""
    },
    {
        "id": "R-02",
        "name": "mother_star2",
        "character": "mother",
        "star": 2,
        "base": "CH-02_mother.png",
        "expression_prompt": """EXPRESSION CHANGE — mother ★2 v3 (CLEARLY HAPPY, score 60-89 percent,
"오~ 맛있다!" / "Oh, this is good!" cartoon clearly-happy face, middle of the gradient):

EYES (cartoon happy crescent):
- Both eyes CLOSED into clear UPWARD CRESCENT ARC SHAPES (^_^ shape) — clearly happy smiling
  eye crinkles, slightly more pronounced and more curved than v2's "slight upward crescent",
  classic cartoon happy-eyes shape that reads "yes, this makes me happy" at a glance.

MOUTH (cartoon clearly happy):
- Mouth clearly OPEN in a small-to-medium OPEN smile or a soft O-shape "oh!" smile (clearly
  larger and more open than v2's "small open-arc smile"), suggesting a clear cartoon "오~
  맛있다!" / "oh this is really good!" reaction. The mouth interior shows a small clean flat
  fill (NOT detailed teeth/tongue at this level — that's reserved for ★3 peak).
- Cheek blush slightly more pronounced in tone (still the base #FFCFCF light pink, slightly
  amplified area to suggest happy warmth on the cheeks).

BODY LANGUAGE + EMOTION ICONS:
- ONE mitten hand raised near the cheek or near the chin in a happy "oh this is good!"
  gesture (clearly raised, more expressive than v2's "happily eating" gesture — the hand is
  near the face as part of the expression, NOT just holding a bowl).
- Head naturally upright, shoulders slightly raised in a happy posture.
- 1-2 small simple flat geometric SPARKLE icons "✨" (4-point sparkle, single color yellow/
  gold, NOT detailed anime sparkles with multiple rays, ~1/12 head size each) floating near
  the upper area of the head/face as comic happy amplifier.
- Optional: 1 small simple flat geometric HEART icon "❤" (single color red, ~1/14 head size)
  near one shoulder/upper area as a subtle motherly warmth accent (lighter than ★3 heart
  cluster).

The reaction reads as CARTOON-STYLE CLEARLY HAPPY — the mother is solidly pleased in a clear
visible happy state, comic enough that players immediately recognize this as the MIDDLE of
the gradient (clearly above ★1 thinking pose, but not yet the ★3 explosive peak). The motherly
warmth is amplified into clearly visible happy warmth.

CRITICAL: This is the IN-BETWEEN gradient step (★1 dot eyes ↔ ★3 fully closed happy arcs +
explosive peak). The eyes are CLEARLY closed in happy crescent ^_^ (NOT dot eyes like ★1,
NOT yet the wide ★3 peak with multiple sparkle eyes). The mouth is OPEN in clear O-or-arc
shape (BIGGER than ★1 wave-thinking, SMALLER than ★3 GIANT wide open). The sparkle/heart icons
are MODEST (1-2 each, NOT the ★3 cluster of 3-5 each)."""
    },
    {
        "id": "R-03",
        "name": "mother_star3",
        "character": "mother",
        "star": 3,
        "base": "CH-02_mother.png",
        "expression_prompt": """EXPRESSION CHANGE — mother ★3 v3 (EXPLOSIVE PEAK EXCITEMENT, score 90-100
percent, "와아!! 최고야!!" / "Waaa!! This is the BEST!!" cartoon explosive peak reaction,
heroically maxed gradient):

EYES (cartoon explosive peak):
- Both eyes CLOSED into GIANT pronounced HAPPY UPWARD CRESCENT ARCS (^___^ shape, the arcs
  noticeably LARGER and more dramatic than ★2's regular happy crescent — these are the peak
  "delighted closed-arc happy eyes" with clear bold smile-stroke curves).
- ALTERNATIVE (pick one or combine subtly): the eyes can also show a 4-point STAR SPARKLE
  ✨ accent ADJACENT to the closed arc (the sparkle is a SEPARATE small flat geometric icon
  floating just outside the eye area, NOT enlarged anime sparkly pupils inside the eye —
  the eye itself stays in the chibi happy closed-arc shape).

MOUTH (cartoon explosive peak):
- Mouth WIDE OPEN in a GIANT delighted smile (clearly larger and more open than ★2's small-
  to-medium O-shape) — the open mouth shape should be a clear comic "와아!!" / "wow!!" big
  open smile with a small hint of teeth (simple flat white fill across the top edge of the
  mouth opening) and optionally a small hint of tongue (simple flat pink fill inside the
  mouth opening). This is the cartoon peak open-mouth grin.
- Cheek blush clearly more pronounced (same #FFCFCF light pink, larger blush area suggesting
  peak happy warmth).

BODY LANGUAGE + EMOTION ICONS (the EXPLOSIVE peak amplification — the v3 key change):
- BOTH mitten hands raised near the cheeks OR raised above the head in a cartoon "와아!!"
  delighted gesture (both hands clearly visible in the bust-up frame, fingers slightly spread
  in joy, classic "delighted reaction" body language).
- Body posture slightly raised / leaning forward as if mid-jump (small upward motion implied,
  NOT actually full jumping out of frame — just amplified upward energy posture).
- 3-5 small simple flat geometric HEART icons "❤" (single color red, varied sizes ~1/14 to
  1/10 of head size) floating around the head/upper area as a clear heart-burst cluster
  (motherly warmth EXPLOSION amplifier).
- 3-5 small simple flat geometric SPARKLE icons "✨" (4-point sparkle, single color yellow/
  gold, varied sizes ~1/14 to 1/10 head size) interspersed with the hearts as a sparkle-burst
  cluster.
- 2-3 short curved MOTION LINES (small simple thin warm dark strokes) radiating outward from
  the head/body suggesting energetic upward burst motion.
- Optional: 1-2 small simple flat geometric 5-point STAR icons "⭐" (single color yellow, same
  size range) included in the burst cluster for extra peak amplification.

The reaction reads as CARTOON-STYLE EXPLOSIVE PEAK DELIGHT — the mother is in full "와아!!
최고야!!" / "wow this is the BEST!!" cartoon comic peak happiness, with multiple emotion
icons bursting around her like a Korean variety show / K-drama exaggerated peak reaction.
Players immediately recognize this as the PEAK of the gradient (clearly far above ★2 clearly-
happy, the explosive max amplification).

CRITICAL:
- The eyes MUST be in HAPPY closed-arc shapes (giant upward crescent smile-strokes, NOT sad
  closed eyes, NOT sleeping peaceful eyes, NOT crying tears). If sparkle accent is added near
  eyes, it's a SEPARATE floating geometric icon OUTSIDE the eye, NOT enlarged anime shoujo
  sparkly pupils filling the eye.
- The heart / sparkle / star icons MUST be SIMPLE FLAT GEOMETRIC (single color each, NO
  internal shading, NO 3D depth, NO detailed anime ray effects — just clean cartoon vector-
  style icons).
- The amplification stays within polished modern mobile casual (Royal Match aesthetic + K-
  drama reaction tone), NOT slapstick Looney Tunes goofy (no x-eyes, no tongue lolling, no
  comic stink lines, no character bouncing literally out of frame).
- The motherly warmth tone is preserved (NOT replaced with father's masculine excited tone —
  the hearts dominate vs the father's stars/fists)."""
    },
    {
        "id": "R-04",
        "name": "father_star1",
        "character": "father",
        "star": 1,
        "base": "CH-03_father.png",
        "expression_prompt": """EXPRESSION CHANGE — father ★1 v3 (RESERVED THINKING, score 30-59 percent,
"흠, 괜찮군" / "Hmm, not bad" cartoon reserved-thinking pose, lighter version of the gradient
with masculine stoic tone):

EYES (cartoon reserved thinking style):
- Two small black dot eyes, OPEN in a normal alert state, BOTH eyes slightly narrowed in a
  classic "흠..." / "hmm..." cartoon evaluating gaze (a subtle narrowing that reads "I'm
  judging this", more reserved/stoic than mother's open thoughtful gaze).
- ONE eyebrow slightly raised higher than the other in a small comic "skeptically considering"
  asymmetric lift (more pronounced than v2's flat dots — this is the masculine version of
  mother's "hmm?" thinking eyebrow).

MOUTH (cartoon reserved thinking style):
- A small narrow tight-lipped mouth with one corner slightly raised (a cartoon "흠..."
  evaluating smirk, mouth closed, more reserved than mother's wavy thinking line — the
  masculine reserved version of "considering" mouth shape).

BODY LANGUAGE + EMOTION ICONS:
- One mitten hand raised near the chin in a clear cartoon "stroking chin / hand-on-chin
  thinking pose" (the classic masculine "흠..." evaluating gesture — index/thumb touching
  the chin area, possibly with the hand slightly cupped under the chin).
- **NO thumb-up gesture** (★1 is reserved thinking — thumb-up is for ★2 single small thumb-up
  and ★3 double enthusiastic gestures only).
- Head slightly tilted to one side (~5-10 degree tilt, more subtle than mother to maintain
  masculine reserved tone).
- ONE small simple flat geometric SWEAT DROP icon (light blue, teardrop shape, ~1/14 head
  size) floating near the temple as a comic "considering / mildly weighing it" amplifier
  (the classic anime/manga "hmm, well..." sweat drop, NOT actual sweat — just the comic
  symbol).
- Optional: ONE small "..." (three small dot icons) near the head as additional comic
  thinking ambient detail (NOT readable text, just three small dots as a thinking symbol).

The reaction reads as CARTOON-STYLE RESERVED MASCULINE EVALUATION — the father is in a
clearly readable "흠, this is acceptable" reserved thinking pose, comic enough that players
immediately recognize this as the LOW END of the satisfaction gradient (between 0-29% penalty
zone and ★2 60% relaxed happy zone). The masculine stoic tone is preserved (NOT cold
disapproval, NOT angry, NOT disappointed — just reserved calmly evaluating with a hint of
comic amplification).

CRITICAL:
- NO thumb-up gesture (the Week 1 CH-03_father base shows a thumb-up which is closer to ★2
  — this ★1 v3 variant trims that to a thinking pose WITHOUT the thumb-up).
- Hair tone (salt-and-pepper darker shade) and shirt tone (teal-green darker shade) MUST
  EXACTLY match the CH-03_father base image (same saturation, same shade — must be visually
  consistent with R-05/R-06 as the same father family IP, NO lighter tone).
- The sweat drop icon is a COMIC THINKING amplifier, NOT literal sweat / NOT distress / NOT
  embarrassment — it's the standard anime/manga "evaluating, considering" symbol. Single
  simple flat geometric teardrop shape, NOT detailed water droplet."""
    },
    {
        "id": "R-05",
        "name": "father_star2",
        "character": "father",
        "star": 2,
        "base": "CH-03_father.png",
        "expression_prompt": """EXPRESSION CHANGE — father ★2 v3 (CLEARLY HAPPY RELAXED, score 60-89 percent,
"오, 잘했네!" / "Oh, nicely done!" cartoon clearly-happy approval, middle of the gradient with
double thumb-up gesture amplification):

EYES (cartoon happy crescent, slightly less pronounced than mother to match masculine tone):
- Both eyes CLOSED into clear UPWARD CRESCENT ARC SHAPES (^_^ shape) — clearly happy smiling
  eye crinkles, slightly more pronounced than v2's "slight upward crescent". Fathers crinkle
  eyes slightly less dramatically than mothers but the gradient direction is the same — clearly
  cartoon happy-eyes shape that reads "yes, I'm pleased" at a glance.

MOUTH (cartoon clearly happy):
- Mouth clearly OPEN in a medium-sized OPEN smile (clearly larger and more open than v2's
  "small open-arc smile"), suggesting a clear cartoon "오, 잘했네!" / "oh, nice work!"
  contented father's reaction. Small hint of teeth visible (simple flat white fill).
- The reserved posture has clearly DROPPED into relaxed enjoyment (no more tight-lipped
  thinking mouth from ★1).

BODY LANGUAGE + EMOTION ICONS (v3 KEY CHANGE vs v2 — DOUBLE thumb-up at ★2):
- **DOUBLE THUMB-UP gesture (BOTH mitten hands)** giving an upward thumb-up gesture (both
  hands clearly visible in the bust-up frame, both giving a casual approving thumb-up
  position near chest/shoulder level — clearly more expressive than v2's "single casual
  thumb-up").
  - Note vs ★3: at ★2 the thumb-ups are at chest/shoulder level (relaxed approval posture),
    at ★3 the thumb-ups/fists are raised over the head (explosive peak).
- Shoulders slightly raised in a happy posture (no longer reserved tight posture from ★1).
- 1-2 small simple flat geometric SPARKLE icons "✨" (4-point sparkle, single color yellow/
  gold, NOT detailed anime sparkles, ~1/12 head size each) floating near the head/shoulders
  as comic clearly-happy amplifier.

The reaction reads as CARTOON-STYLE CLEARLY HAPPY FATHERLY APPROVAL — the father's reserved
posture has clearly dropped into expressive double thumb-up enjoyment, comic enough that
players immediately recognize this as the MIDDLE of the gradient (clearly above ★1 reserved
thinking, but not yet the ★3 explosive peak). The masculine warmth is amplified into clearly
visible happy approval.

CRITICAL:
- The thumb-up at ★2 is DOUBLE (both hands) at CHEST/SHOULDER level (relaxed approval posture).
  NOT raised over the head (that's ★3 explosive peak position). v3 upgraded ★2 from single
  thumb-up to double thumb-up to amplify the comic gradient.
- The eyes are CLEARLY closed in happy crescent ^_^ (NOT dot eyes like ★1, NOT yet the ★3
  peak amplification).
- The mouth is OPEN in medium smile (BIGGER than ★1 tight-lipped, SMALLER than ★3 GIANT wide
  open with teeth/tongue).
- The sparkle icons are MODEST (1-2, NOT the ★3 cluster of 4-6).
- Hair tone (salt-and-pepper darker shade) and shirt tone (teal-green darker shade) MUST
  EXACTLY match the CH-03_father base image (same saturation, same shade — must be visually
  consistent with R-04/R-06 as the same father family IP, NO lighter tone)."""
    },
    {
        "id": "R-06",
        "name": "father_star3",
        "character": "father",
        "star": 3,
        "base": "CH-03_father.png",
        "expression_prompt": """EXPRESSION CHANGE — father ★3 v3 (EXPLOSIVE PEAK EXCITEMENT, score 90-100
percent, "최고다아아!!" / "This is the BEST!!" cartoon explosive peak reaction with raised
fists, heroically maxed gradient with masculine tone):

EYES (cartoon explosive peak):
- Both eyes CLOSED into GIANT pronounced HAPPY UPWARD CRESCENT ARCS (^___^ shape, the arcs
  noticeably LARGER and more dramatic than ★2's regular happy crescent — these are the peak
  "delighted closed-arc happy eyes" with clear bold smile-stroke curves, similar to Week 1
  CH-05_father_star3 variant but amplified further).
- ALTERNATIVE (pick one or combine subtly): the eyes can also show a 4-point STAR SPARKLE
  ✨ accent ADJACENT to the closed arc (the sparkle is a SEPARATE small flat geometric icon
  floating just outside the eye area, NOT enlarged anime sparkly pupils inside the eye —
  the eye itself stays in the chibi happy closed-arc shape).

MOUTH (cartoon explosive peak):
- Mouth WIDE OPEN in a GIANT delighted smile (clearly larger and more open than ★2's medium
  open smile) — the open mouth shape should be a clear comic "최고다아아!!" / "this is the
  BEST!!" big open smile with a clear hint of teeth (simple flat white fill across the top
  edge of the mouth opening) and optionally a small hint of tongue (simple flat pink fill
  inside the mouth opening). This is the cartoon peak open-mouth grin.

BODY LANGUAGE + EMOTION ICONS (the EXPLOSIVE peak amplification — masculine variant):
- BOTH mitten hands raised in clenched FISTS OVER THE HEAD (or one fist over head + one
  thumb-up raised high), classic masculine "최고!!" / "YES!!" Korean K-drama male peak
  reaction posture. Clearly higher and more energetic than ★2's chest-level double thumb-up.
- Body posture slightly raised / leaning forward as if mid-jump (small upward motion implied,
  amplified energetic posture, NOT actually full jumping out of frame).
- 3-5 small simple flat geometric 5-point STAR icons "⭐" (single color yellow, varied sizes
  ~1/14 to 1/10 of head size) floating around the head/upper area as a clear star-burst
  cluster (masculine peak amplifier — stars dominate vs mother's hearts).
- 4-6 small simple flat geometric SPARKLE icons "✨" (4-point sparkle, single color yellow/
  gold, varied sizes ~1/14 to 1/10 head size) interspersed with the stars as a sparkle-burst
  cluster (slightly more numerous than mother's ★3 sparkle cluster to amplify the masculine
  "powerful peak" tone).
- 3-4 short curved MOTION LINES (small simple thin warm dark strokes) radiating outward from
  the head/raised fists suggesting energetic upward burst motion (more pronounced than
  mother ★3's 2-3 motion lines).

The reaction reads as CARTOON-STYLE EXPLOSIVE PEAK MASCULINE APPROVAL — the father is in
full "최고다아아!!" / "this is the BEST!!" cartoon comic peak excitement, with raised fists
and a burst of stars/sparkles around him like a Korean variety show / K-drama exaggerated
male peak reaction (think of a sports victory celebration tone). Players immediately recognize
this as the PEAK of the gradient (clearly far above ★2 double-thumb-up happy, the explosive
max amplification).

CRITICAL:
- The eyes MUST be in HAPPY closed-arc shapes (giant upward crescent smile-strokes, NOT sad
  closed eyes, NOT sleeping peaceful eyes, NOT crying tears). If sparkle accent is added near
  eyes, it's a SEPARATE floating geometric icon OUTSIDE the eye, NOT enlarged anime shoujo
  sparkly pupils filling the eye.
- The star / sparkle icons MUST be SIMPLE FLAT GEOMETRIC (single color each, NO internal
  shading, NO 3D depth, NO detailed anime ray effects — just clean cartoon vector-style
  icons). v3 ★3 father uses STARS as the dominant burst icon (vs mother ★3 hearts) to
  differentiate the masculine peak tone from the motherly peak tone.
- The raised fists/thumb-up combo is OVER THE HEAD (clearly higher than ★2's chest-level
  double thumb-up — this is the explosive peak position).
- The amplification stays within polished modern mobile casual (Royal Match aesthetic + K-
  drama male peak reaction tone), NOT slapstick goofy (no x-eyes, no tongue lolling beyond
  small hint, no comic stink lines, no character bouncing literally out of frame).
- Hair tone (salt-and-pepper darker shade) and shirt tone (teal-green darker shade) MUST
  EXACTLY match the CH-03_father base image (same saturation, same shade — must be visually
  consistent with R-04/R-05 as the same father family IP, NO lighter tone)."""
    },
]

BASE_DIR = PROJECT_ROOT / "assets-raw" / "week1-anchors"
OUT_DIR = PROJECT_ROOT / "assets-raw" / "reaction_anchors_m1"


# ─────────────────────────────────────────────────────────────────────────────
# Base image 사이즈 검증 + (필요 시) gpt-image-1 edit API 호환 사이즈로 resize.
# gpt-image-1 image edit API supported sizes: 1024x1024, 1536x1024, 1024x1536, auto.
# (edit_bg_anchors_v4.py / edit_reaction_anchors_v2.py와 동일 패턴)
# ─────────────────────────────────────────────────────────────────────────────
SUPPORTED_EDIT_SIZES = {(1024, 1024), (1536, 1024), (1024, 1536)}


def inspect_base_image(base_path: Path) -> tuple[int, int]:
    """PIL로 base image 사이즈 측정. PIL 없으면 PNG IHDR 헤더 파싱 fallback."""
    try:
        from PIL import Image  # noqa: WPS433

        with Image.open(base_path) as img:
            return img.size  # (width, height)
    except ImportError:
        with open(base_path, "rb") as f:
            data = f.read(24)
        if data[:8] != b"\x89PNG\r\n\x1a\n":
            return (-1, -1)
        width = int.from_bytes(data[16:20], "big")
        height = int.from_bytes(data[20:24], "big")
        return (width, height)


def ensure_edit_compatible_size(base_path: Path) -> tuple[Path, str]:
    """base image가 gpt-image-1 edit API supported size면 그대로 사용. 아니면 가장 가까운
    size로 resize한 임시 파일을 만들어 그 경로 + size string 반환."""
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
    """gpt-image-1 image edit API 호출 → output_path에 저장."""
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


def main() -> None:
    parser = argparse.ArgumentParser(
        description="M1 후반 양친 reaction 6컷 v3 image edit "
        "(CH-02/CH-03 base + 표정만 변경, 코믹 amplification — family IP consistency LOCK v2)"
    )
    parser.add_argument(
        "--only", type=str, default="",
        help="콤마구분 reaction ID만 (예: R-03,R-06). 빈 값=전체 6장.",
    )
    parser.add_argument(
        "--version", type=str, default="v3",
        help="파일명 suffix (기본 v3 → R-01_mother_star1_v3.png). v1/v2와 공존.",
    )
    parser.add_argument(
        "--quality", type=str, default="medium",
        choices=["low", "medium", "high", "auto"],
        help="gpt-image-1 edit quality. low/medium/high/auto.",
    )
    parser.add_argument(
        "--out-dir", type=Path, default=OUT_DIR,
        help="출력 디렉터리 (기본: assets-raw/reaction_anchors_m1/)",
    )
    args = parser.parse_args()

    only_set = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    selected = [r for r in REACTIONS if (only_set is None or r["id"] in only_set)]
    if not selected:
        sys.exit(f"--only mismatch. Valid IDs: {[r['id'] for r in REACTIONS]}")

    # base image 사전 검증
    print("=" * 70)
    print("Base image dimensions check (assets-raw/week1-anchors/)")
    print("=" * 70)
    missing = []
    base_files_seen = set()
    for r in selected:
        bp = BASE_DIR / r["base"]
        if r["base"] in base_files_seen:
            continue
        base_files_seen.add(r["base"])
        if not bp.exists():
            missing.append(r["base"])
            print(f"   MISSING: {bp}")
            continue
        w, h = inspect_base_image(bp)
        compat = "OK (supported)" if (w, h) in SUPPORTED_EDIT_SIZES else "-> will resize"
        print(f"   {r['base']}: {w}x{h} {compat}")
    if missing:
        sys.exit(
            f"Base image missing {len(missing)}: {missing}. Week 1 commit 7a6cffb check."
        )

    # cost estimate
    unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
    unit = unit_map.get(args.quality, 0.042)
    est_total = unit * len(selected)

    print()
    print("=" * 70)
    print("M1 reaction v3 image edit — CH-02/CH-03 base + 표정만 변경 (코믹 amplification)")
    print(f"   API: gpt-image-1 image edit")
    print(f"   quality: {args.quality} (${unit:.3f}/img)")
    print(f"   target: {len(selected)} imgs ({[r['id'] for r in selected]})")
    print(f"   est cost: ${unit:.3f} x {len(selected)} = ${est_total:.2f}")
    print(f"   output: {args.out_dir}")
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
        base = BASE_DIR / reaction["base"]
        out = args.out_dir / f"{rid}_{name}_{args.version}.png"
        prompt = COMMON_FRAME + "\n\n" + reaction["expression_prompt"]

        print(f"\n[{i}/{len(selected)}] {rid} ({character} star{star}) -- base: {reaction['base']}")
        t_start = time.time()
        try:
            edit_image(client, base, prompt, out, quality=args.quality)
            print(f"   elapsed {time.time() - t_start:.1f}s")
            successes.append(rid)
        except Exception as exc:
            print(f"   FAIL ({time.time() - t_start:.1f}s): {exc!r}")
            failures.append((rid, repr(exc)))

    total_elapsed = time.time() - t0
    print("\n" + "=" * 70)
    print(f"DONE: {len(successes)}/{len(selected)} imgs -- total {total_elapsed / 60:.1f} min")
    if successes:
        print(f"   success: {', '.join(successes)}")
    if failures:
        print(f"   fail {len(failures)}:")
        for rid, err in failures:
            print(f"     - {rid}: {err}")
    print(f"   est cost: ${unit * len(successes):.2f}")
    print(f"   output path: {args.out_dir}")
    print("=" * 70)


if __name__ == "__main__":
    main()
