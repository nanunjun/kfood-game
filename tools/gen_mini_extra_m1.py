"""
K-Food Master — M1 후반 sprint 마지막 mini extra asset 자동 생성 (game-designer motion-spec 후속 gap 2건).

ADR-005 (4-stage rhythm tap) Stage 2A 양념재우기 / dip substitute 매핑 game-designer 후속 motion-spec
follow-up. 기존 TOOL/CUT/INGREDIENT/UI/VFX/FOOD anchor 6 cluster (49+) 외 누락된 mini extra 2장:

  hand_marinade          — 손바닥 marinade press anchor (불고기 F-09 Stage 2A 양념재우기)
  corndog_batter_bowl    — 콘도그 batter dip 그릇 anchor (콘도그 F-06 Stage 2A dip substitute)

이후 추가 mini asset (small one-off prop / hand pose / specialty container 등)이 발생하면 본 driver의
EXTRAS list에 항목 추가하는 방식으로 확장 (게임 진행 중 game-designer/godot-dev가 motion-spec
implementation에서 누락 발견 시 raise → art-director가 본 driver에 append).

art-director docs/prompts-library.md v1.23 §5.14 STYLE_SUFFIX_MINI + 2 항목 prompt
를 그대로 inline 임베드.

각 mini extra prompt 공통:
  - 단독 sprite (다른 도구/character 없이, single hero element on Cool Sage bg)
  - chibi friendly tone + slim outline 2-3px (TOOL / CUT cluster 일관성)
  - modern saturated 80-90% + Cookingo-inspired simple geometric flat
  - Cool Sage `#C8D5C0` bg + ambient ellipse shadow under (diegetic prop이라 shadow 유지 —
    UI/VFX와 차별점)

Usage:
    py tools/gen_mini_extra_m1.py
    py tools/gen_mini_extra_m1.py --only hand_marinade               # 1장만
    py tools/gen_mini_extra_m1.py --only corndog_batter_bowl         # 1장만
    py tools/gen_mini_extra_m1.py --model gpt-image-1 --quality medium
    py tools/gen_mini_extra_m1.py --version v2                       # 파일명 suffix

Default:
    model    = gpt-image-1 (medium quality)
    quality  = medium ($0.042/img × 2 = ~$0.08 total)
    size     = 1024x1024 (square 1:1)
    out_dir  = assets-raw/mini_extra_m1/
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
# STYLE_SUFFIX_MINI — 모든 mini extra anchor prompt 끝에 부착
# prompts-library.md v1.23 §5.14 STYLE_SUFFIX_MINI.
# 단독 sprite + Cool Sage bg + slim outline + modern saturated + chibi friendly tone
# + TOOL/CUT/INGREDIENT cluster 일관성 유지 + ambient shadow 유지 (diegetic prop).
# ─────────────────────────────────────────────────────────────────────────────
STYLE_SUFFIX_MINI = """Format: square 1:1.
View: 7/8 perspective view (slight side angle ~15-20 degrees) for the prop / hand element,
showing form + depth while remaining read-friendly. NOT strict top-down, NOT pure front
elevation, NOT 3D photoreal depth.
Style: modern mobile casual game asset, clean 2D illustration in Royal Match (Dream Games
2021) + Cookingo: Perfect Meal (Asian mobile 2025-2026) aesthetic. Hero shot of a SINGLE
mini extra element (hand pose or specialty container) as a standalone sprite for in-game
motion-spec animation use (godot-dev will animate this sprite independently with
AnimationPlayer for press / dip / squeeze etc).
Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black, consistent with all 49+
asset cluster — TOOL / CUT / INGREDIENT / FOOD / UI / VFX). Single color fill with optional
soft 1-layer cel shading and ONE small specular highlight per element. Vibrant saturated
colors at 80-90 percent saturation, warm/cool palette balance. Simple geometric flat fill
shapes (Cookingo-inspired — bold simple shapes, soft rounded edges, no excessive realism).

SPRITE ISOLATION (consistent across all mini extra anchors):
- The single hero mini extra element sits at the CENTER of the frame, occupying ~55-70% of
  the image area with comfortable margins around it. NO other tools, NO other characters,
  NO additional props beyond the body prompt explicit element.
- NO food being processed (the sprite is the EMPTY ready-to-use state — for hand_marinade
  the palm is empty descending toward where meat would be / for corndog_batter_bowl the
  batter is in the bowl but NO corn dog stick dipping yet — gameplay food layer is
  composited by Godot at runtime).
- NO character body, NO face, NO arm beyond minimal wrist hint for hand sprites (hand
  sprites show only the hand/palm/short wrist, character body is implied off-frame).

BACKGROUND:
- Solid Cool Sage #C8D5C0 background (consistent across all 49+ anchor cluster — food /
  environment / cut / ingredient / ingredient_cut / reaction / tool / UI / VFX — matches
  cross-asset one-game-world identity).
- Single subtle ambient ellipse shadow directly under the prop / hand (#000 ~25% alpha,
  soft and natural). UNLIKE UI/VFX anchors (which are HUD overlay layer with no diegetic
  ground), mini extra anchors ARE diegetic in-scene props so the shadow is appropriate.

KOREAN HOMESTYLE CHIBI TONE (consistent across all mini extra anchors):
- Friendly chibi cartoon proportions (simplified / cute / approachable), modern Korean
  home kitchen context, consistent with the CH-01~05 character cluster + TOOL-01~12
  cooking tool cluster.
- Avoid realistic anatomical detail (NO detailed knuckles, NO veins, NO realistic skin
  texture, NO photoreal cookware reflection) — keep simple geometric flat fill matching
  the cluster aesthetic.

Important: avoid beige background, cream paper background, scrapbook, storybook, kraft
paper, vintage texture, golden hour, sunset warm lighting,
Cookie Run, Cookie Run Kingdom frosting style, Toca Boca, Toon Blast over-cartoony,
realistic or photorealistic rendering, 3D render, octane or unreal engine, food
photography, heavy metallic reflection, mirror polish, any texture, noise, grain,
painterly or hand-painted feel, watercolor, gradient mesh, multi-layer complex shading,
hyperdetailed elements, cinematic, gritty, blood, gore,
multiple elements in one image (each mini extra sprite is standalone — NO companion props,
NO kitchen scene with multiple items, NO food being processed inside the sprite),
characters / faces / full bodies / arms beyond minimal wrist hint, kitchen environment
background (BG-01~05 environment anchors are separate),
realistic detailed human hand anatomy (detailed knuckles, prominent veins, fingernails
with cuticles, palm crease lines, fingerprint detail, age spots, hair on hand, jewelry
rings, watch — keep hand simple chibi style with mitten-friendly soft silhouette),
Japanese / Chinese / Western cultural cookware leak per item-specific body prompt,
any English or Korean text legibly readable on the prop surface (brand labels, model
numbers all obscured or absent)."""


# ─────────────────────────────────────────────────────────────────────────────
# EXTRAS — 2개 항목 (mini extra anchor 2장)
# prompts-library.md v1.23 §5.14.1 ~ §5.14.2 본문 inline.
# 각 항목: id (slug) / name (slug) / usage (game-designer motion-spec mapping) / body.
# STYLE_SUFFIX_MINI는 자동 append via .replace("%s", STYLE_SUFFIX_MINI, 1).
# ─────────────────────────────────────────────────────────────────────────────
EXTRAS = [
    {
        "id": "hand_marinade",
        "name": "hand_marinade",
        "usage": "불고기 F-09 Stage 2A 양념재우기 (palm press motion anchor)",
        # §5.14.1 손바닥 marinade press anchor — single open palm sprite for 위→아래 press motion
        "body": """A modern mobile casual game asset illustration of a single OPEN HUMAN PALM
hand sprite for the 양념재우기 (marinade press) motion-spec animation in K-Food Master
(used in F-09 불고기 Stage 2A where the player taps to press the seasoned beef into the
marinade with a downward palm press motion). Standalone hand sprite centered on the
canvas, 7/8 perspective view (slight angled view showing the palm face + minor side
profile of the hand thickness + short wrist stub).

Element form: a SINGLE FRIENDLY CHIBI-STYLE HUMAN PALM hand, palm-down orientation as if
about to press downward. The hand is shown from above-side angle so the BACK OF THE HAND
is dominantly visible with a hint of finger curl underneath. Hand dimensions: approximately
55-65% of image width × 50-60% of image height (occupying generous center area with
comfortable padding).

- HAND SHAPE: simplified chibi-friendly hand silhouette — soft rounded palm shape (slightly
  squarish-round outline, NOT perfectly anatomical), 4 fingers visible with subtle finger
  separation lines (slim hint of finger grooves, fingers held close together palm-down
  ready to press, NOT spread wide), thumb tucked along the side. The fingers appear
  slightly visible as soft small finger tips peeking under/around the palm edge (NOT
  fully extended outward, NOT clenched fist — relaxed open palm ready to press).
- FINGERTIPS: each finger ends with a soft rounded tip (NO sharp fingernail detail, NO
  cuticle, NO realistic nail bed — just soft rounded chibi finger ends, optional very
  subtle slim arc hint per fingertip suggesting nail outline if needed).
- WRIST: short wrist stub at the upper edge of the frame (~10-15% of hand height), cut
  off cleanly at the frame edge (suggesting the arm extends off-frame — character body
  is implied but NOT visible).
- SKIN COLOR: warm peachy SKIN TONE #F5C9A2 (single fill, friendly chibi neutral skin
  tone, consistent with CH-01~05 character cluster skin tones, NOT pale white NOT deep
  tan — neutral approachable). Optional very subtle slim cel shading on the bottom-right
  side of the palm using a slightly deeper warm peach #E8B189 (~20-25% area) suggesting
  the 3D volume of the palm + ONE small specular highlight on the upper-left knuckle
  area (~5% area, soft white #FFFFFF) suggesting the soft palm sheen.
- OUTLINE: slim bold WARM DARK #2D1D14 outline 2-3px wrapping the full hand silhouette
  for clean readability + slim hint lines for finger separation (3 grooves between 4
  fingers, very minimal 1-2px hairline).

USE-HINT ACCENT: 1-2 small SHORT DOWNWARD MOTION LINES near the upper edge of the hand
(slim warm dark hairline arcs ~10-15px each, suggesting the downward press motion). The
motion lines are SUBTLE accents — they signal "this hand is descending in a press motion"
without obscuring the hand silhouette. Optional: very subtle pinky-finger curl hint (a
small finger curve at the side) suggesting the hand is in active press preparation, NOT
a static greeting wave.

%s

Important also: this is a SINGLE OPEN PALM HAND sprite for marinade press motion-spec.
The hand MUST read as a friendly chibi-style open palm in palm-down 7/8 view with short
wrist stub at the top edge + 1-2 subtle downward motion lines. NOT a REALISTIC HAND
(no detailed knuckle wrinkles, no prominent veins, no fingerprint detail, no realistic
fingernails, no palm crease lines, no hair on hand, no age spots, no jewelry rings, no
watch — keep chibi simple geometric flat fill). NOT a FULL ARM (no elbow, no upper arm,
no shoulder, no character body — only hand + minimal wrist stub). NOT a CLENCHED FIST
(palm is OPEN ready to press flat, NOT punching), NOT a THUMBS-UP (not gesturing
approval), NOT a HIGH-FIVE WAVING HAND (fingers held close NOT spread wide), NOT a
POINTING FINGER (no single extended index), NOT a PINCH GRIP (not picking up small
object), NOT a HANDSHAKE (not gripping another hand). NOT a HAND HOLDING UTENSILS (no
spoon, no fork, no chopsticks — those are TOOL anchor territory). NOT a GLOVE (no
kitchen glove, no oven mitt, no rubber glove — bare chibi-friendly skin). NOT a
CHARACTER PORTRAIT (no face visible, no body visible — hand only). The single
standalone friendly chibi open palm hand with subtle downward motion lines on the Cool
Sage background is the hero — the godot-dev will animate this sprite with downward
press tween (위→아래 motion) on top of the marinade bowl asset at runtime."""
    },
    {
        "id": "corndog_batter_bowl",
        "name": "corndog_batter_bowl",
        "usage": "콘도그 F-06 Stage 2A dip substitute (batter mixing bowl anchor)",
        # §5.14.2 콘도그 batter dip 그릇 — round mixing bowl with viscous cornmeal/wheat batter inside
        "body": """A modern mobile casual game asset illustration of a CORNDOG BATTER MIXING BOWL
as a standalone tool/prop sprite for the corndog batter dip substitute motion-spec in
K-Food Master (used in F-06 콘도그 Stage 2A where the player dips the corndog stick into
the batter bowl). Standalone bowl sprite centered on the canvas, 7/8 perspective view
(slight angled view showing the rounded bowl shape + the wide open top + the viscous
batter pool surface inside).

Element form: a CLEAN MATTE WHITE OR LIGHT CREAM CERAMIC MIXING BOWL filled with
VISCOUS LIGHT TAN/GOLDEN CORNMEAL-WHEAT BATTER. Bowl dimensions: approximately 65-70%
of image width × 50-60% of image height (occupying generous center area with
comfortable padding around).

- BOWL SHAPE: a wide round mixing bowl with a flared slightly-curved upper rim opening
  and a slightly narrower flat round base (classic mixing bowl proportion, ~26-30cm
  diameter at top × 11-13cm deep, slightly smaller than the TOOL-11 bibimbap mixing
  bowl which is 28-32cm). The bowl is a SINGLE WIDE ROUND vessel with NO handles
  (intentional difference from TOOL-02 yangun pot which has 2 ear handles, and
  intentional difference from TOOL-11 mixing bowl which is silver-gray stainless —
  this corndog batter bowl is CLEAN MATTE WHITE OR LIGHT CREAM CERAMIC for clear
  visual distinction).
- BOWL COLOR: CLEAN MATTE WHITE #FAFAFA single fill (or alternatively very light cream
  #F5F0E8 for warmth — choose matte white for cleanest cluster fit) with subtle slim
  cel shading on the outer lower curve suggesting the rounded 3D bowl volume in 7/8
  view + ONE small specular highlight strip along the upper outer rim suggesting the
  polished ceramic sheen.
- BATTER FILL: the bowl is filled with VISCOUS CORNMEAL-WHEAT BATTER to approximately
  65-75% of the bowl interior depth, the batter surface visible as an ELLIPTICAL POOL
  due to 7/8 perspective. The batter is a LIGHT TAN/GOLDEN color (#E8C58A single fill,
  warm golden cornmeal tone with slight wheat-yellow hint — distinctly viscous-thick
  appearance NOT a clear liquid NOT a soup, this is a sticky pancake-batter consistency)
  with subtle slim cel shading hint suggesting the slightly thicker viscous texture +
  ONE small specular highlight on the batter surface suggesting the smooth glossy wet
  batter sheen. Optional: 1-2 very small bubbles or surface dimples (small circular
  hints ~3-5mm on the batter surface) suggesting the freshly-mixed viscous state.
- BATTER MENISCUS: the batter surface clings slightly to the inner bowl rim (a slim
  curved meniscus hint at the bowl interior edge), suggesting the sticky thick
  consistency. The batter does NOT overflow the bowl (well below the rim).
- OUTLINE: slim bold WARM DARK #2D1D14 outline 2-3px wrapping the full bowl silhouette
  + slim hairline for the batter surface ellipse edge for clean readability.

USE-HINT ACCENT: NO corn dog stick dipping into the batter (the corn dog is the
gameplay food layer composited by Godot at runtime — this anchor is the EMPTY bowl
ready-to-dip state). NO motion line, NO splash. Optional: very subtle hint of one
small batter drip on the outer bowl rim (~3-5mm small drip accent suggesting recent
mixing activity, very minimal — single small drop only, NOT a messy splash).

%s

Important also: this is a SINGLE CORNDOG BATTER MIXING BOWL sprite — the bowl MUST
read as a clean matte white round ceramic mixing bowl filled with viscous light
tan/golden cornmeal-wheat batter at ~65-75% depth, visible elliptical batter pool
surface in 7/8 view. NOT a CORN DOG itself (no corn dog on top, no corn dog visible
inside — the corn dog gameplay food layer is composited at runtime by Godot, this
sprite is the bowl + batter ONLY). NOT a TOOL-11 bibimbap mixing bowl (TOOL-11 is
silver-gray STAINLESS STEEL larger 28-32cm + empty — this is MATTE WHITE CERAMIC +
filled with viscous batter). NOT a TOOL-02 yangun pot (yangun pot has 2 ear handles
+ silver-gray + open top + empty — this bowl has NO HANDLES + matte white + filled
with batter). NOT a TOOL-04 deep fryer pot (deep fryer is silver-gray cylindrical
DEEPER + 2 ear handles + golden COOKING OIL pool — this is matte white ceramic +
NO handles + viscous BATTER not clear oil). NOT a SOUP BOWL (no soup, no liquid
broth — this is a thick sticky batter). NOT a PANCAKE BATTER BOWL with VERY THIN
RUNNY pourable batter (corndog batter is THICKER more viscous — pancake batter is
thinner and more liquid). NOT a CAKE BATTER MIXING BOWL with whisk inside (no
whisk, no spatula, no spoon — empty utensils). NOT a DOUGH KNEADING BOWL with thick
solid dough (corndog batter is wet viscous liquid-batter NOT solid dough). NOT a
JAPANESE DONBURI bowl (donburi is smaller ceramic for rice). NOT a CHINESE SOUP BOWL
with decorative patterns (this is plain matte white modern). The single standalone
clean matte white round ceramic bowl with viscous light tan cornmeal batter pool inside
on the Cool Sage background is the hero — the godot-dev will animate the corn dog
stick dipping sprite into this bowl at runtime."""
    },
]


def build_prompt(body: str) -> str:
    """body의 첫 %s를 STYLE_SUFFIX_MINI로 교체. body의 다른 % 문자(예: 65%, ~25% 등)는
    .format / f-string과 달리 .replace로 안전 보존 (gen_food/gen_ingredient/gen_reaction/
    gen_tool/gen_ui_vfx에서 동일 패턴 fix).
    """
    return body.replace("%s", STYLE_SUFFIX_MINI, 1)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="M1 후반 mini extra anchor 2장 자동 생성 (game-designer motion-spec 후속 gap fix)"
    )
    parser.add_argument(
        "--only", type=str, default="",
        help="콤마구분 extra ID만 (예: hand_marinade,corndog_batter_bowl). 빈 값=전체 2장."
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
        default=PROJECT_ROOT / "assets-raw" / "mini_extra_m1",
        help="출력 디렉터리"
    )
    parser.add_argument(
        "--version", type=str, default="v1",
        help="파일명 suffix (예: v1 → hand_marinade_v1.png)"
    )
    args = parser.parse_args()

    only_set = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    selected = [e for e in EXTRAS if (only_set is None or e["id"] in only_set)]

    if not selected:
        sys.exit(f"❌ --only 매칭 mini extra 없음. 유효 ID: {[e['id'] for e in EXTRAS]}")

    args.out_dir.mkdir(parents=True, exist_ok=True)

    # cost estimate
    if args.model == "dall-e-3":
        unit = 0.080 if args.quality == "hd" else 0.040
    else:
        unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
        unit = unit_map.get(args.quality, 0.042)
    est_total = unit * len(selected)
    print("=" * 70)
    print("✋ M1 후반 mini extra anchor 생성 시작 (game-designer motion-spec 후속 gap)")
    print(f"   모델: {args.model} / 품질: {args.quality} / 사이즈: {args.size}")
    print(f"   대상: {len(selected)}장 ({[e['id'] for e in selected]})")
    print(f"   비용 예상: ${unit:.3f}/장 × {len(selected)} = ${est_total:.2f}")
    print(f"   출력: {args.out_dir}")
    print("=" * 70)

    api_key = load_api_key()
    client = OpenAI(api_key=api_key)

    successes: list[str] = []
    failures: list[tuple[str, str]] = []
    t0 = time.time()

    for i, extra in enumerate(selected, 1):
        eid = extra["id"]
        name = extra["name"]
        usage = extra["usage"]
        out_path = args.out_dir / f"{name}_{args.version}.png"
        prompt = build_prompt(extra["body"])

        print(f"\n[{i}/{len(selected)}] {eid} ({usage})")
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
            successes.append(eid)
        except Exception as exc:
            elapsed = time.time() - t_start
            print(f"   ❌ FAIL ({elapsed:.1f}s): {exc!r}")
            failures.append((eid, repr(exc)))

    total_elapsed = time.time() - t0
    print("\n" + "=" * 70)
    print(f"✅ 완료: {len(successes)}/{len(selected)} 장 — 총 {total_elapsed/60:.1f}분")
    if successes:
        print(f"   성공: {', '.join(successes)}")
    if failures:
        print(f"   실패 {len(failures)}장:")
        for eid, err in failures:
            print(f"     - {eid}: {err}")
    print(f"   비용 예상: ${unit * len(successes):.2f}")
    print(f"   저장 경로: {args.out_dir}")
    print("=" * 70)


if __name__ == "__main__":
    main()
