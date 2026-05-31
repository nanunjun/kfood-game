"""
K-Food Master — M1 후반 양친 reaction 6컷 v2 image edit (CH-02/CH-03 base + 표정만 변경).

ADR-006 (ChatGPT/DALL-E) 기반. art-director docs/prompts-library.md v1.18
§5.7 R-01~R-06 6컷 v2 image edit prompt를 그대로 inline 임베드.

v1.18 v2 image edit patch (2026-05-30): 사용자가 v1 (prompt-only generation, 6장 batch,
gpt-image-1 medium 1024×1024) 결과 시각 확인 후 2건 피드백 raise:
1. **R-01/R-03 어머니 hair shape mismatch**: v1에서 round-bun **+ side-puff** variant로
   생성되어 CH-02 base의 round-bun **simple**과 다름. 사용자 verbatim
   "reaction 에서 R-01, R-03가 원래 이미지와 좀 다름"
2. **R-04 vs R-05/R-06 아버지 family IP inconsistency**: R-04는 CH-03 base의 darker
   salt-and-pepper hair + darker teal-green shirt에 가까우나, R-05/R-06는 lighter
   tone으로 생성되어 셋 사이 inconsistency. 사용자 verbatim "R-04, R-05, R-06가
   이미지가 좀 일관성이 없음"

main thread 해석: prompt-only generation은 CH-02/CH-03 base의 family IP를 정확히
재현하지 못함. **gpt-image-1 image edit API** (BG sprint v4에서 효과 입증)로 base
PNG를 직접 입력하고 표정만 변경하는 접근 도입.

**도구**: gpt-image-1 image edit API (`client.images.edit(model="gpt-image-1",
image=open(base, "rb"), prompt=COMMON_FRAME + expression, size="1024x1024",
quality="medium", n=1)`)

**Base image 2장**:
  - `assets-raw/week1-anchors/CH-02_mother.png`   = R-01/R-02/R-03 base (어머니)
  - `assets-raw/week1-anchors/CH-03_father.png`   = R-04/R-05/R-06 base (아버지)

각 reaction edit:
  - base = CH-02_mother (R-01~R-03) or CH-03_father (R-04~R-06)
  - prompt = COMMON_FRAME (family IP 유지 + bust-up + Cool Sage bg + 표정만 변경)
             + expression_prompt (★1/★2/★3 specific)
  - output = `assets-raw/reaction_anchors_m1/R-XX_<character>_star<N>_v2.png`

이전 v1 prompt-only output (R-XX_<character>_star<N>_v1.png 6장)은 보존 (v2와 공존).

Usage:
    py tools/edit_reaction_anchors_v2.py                    # 6장 batch
    py tools/edit_reaction_anchors_v2.py --only R-01        # test 1장
    py tools/edit_reaction_anchors_v2.py --only R-01,R-03   # 어머니 mismatch 2장
    py tools/edit_reaction_anchors_v2.py --quality high     # 더 높은 품질 (~5x cost)

Default:
    model    = gpt-image-1 (image edit API)
    quality  = medium ($0.042/img × 6 = ~$0.25 total)
    base_dir = assets-raw/week1-anchors/
    out_dir  = assets-raw/reaction_anchors_m1/
    version  = v2
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
# COMMON_FRAME — 6 reaction 모두 공통 (family IP 유지 + bust-up + Cool Sage bg +
# 표정만 변경 명시 + sad/sleeping/crying 회피 + cross-cultural 회피).
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
(Scene 3 식탁 reaction context). Optional: one mitten hand visible holding chopsticks or a
small bowl near the chest level as minor accent (do not dominate the portrait — the facial
expression is the hero).

BACKGROUND:
- Replace any existing background with SOLID Cool Sage #C8D5C0 (cross-asset consistency with
  food + cut + ingredient anchor clusters — the 37-asset Scene 3 cluster shares Cool Sage bg).
- Single subtle ambient ellipse shadow under the character bust (#000 ~25% alpha).

ONLY change the FACIAL EXPRESSION to the specified star level (see expression block below).
Keep ABSOLUTELY EVERYTHING ELSE IDENTICAL to the base image — hair shape / hair color / outfit
color / outfit shape / face proportions / chibi proportions / outline thickness / color
saturation / cheek blush light pink #FFCFCF tone — all UNCHANGED.

Important: avoid sad teardrop, crying tears, downturned mouth frown, sleepy closed peaceful
eyes, disappointed cold expression. The ★3 closed-arc eyes (if applicable) are HAPPY upward
crescent smile-strokes, NOT sad closed eyes, NOT sleeping peaceful eyes.
Avoid full body, lower body, legs, feet (this is a bust-up portrait, head and shoulders only).
Avoid multiple characters in one image (single subject per reaction anchor — mother and
father are separate anchors, NOT combined).
Avoid Japanese kimono / Japanese geisha, Chinese qipao, anime girl big sparkly eyes,
school uniform, deep dark Cookie Run frosting pink cheek, Cookie Run Kingdom frosting style,
realistic or photorealistic rendering, 3D render, octane or unreal engine, heavy texture,
hand-painted feel, watercolor, gradient mesh, multi-layer complex shading, hyperdetailed,
beige background, cream paper background, scrapbook, storybook, kraft paper, vintage texture,
golden hour, sunset warm lighting, atmospheric haze,
any English or Korean text legibly readable (NO speech bubbles, NO captions)."""


# ─────────────────────────────────────────────────────────────────────────────
# REACTIONS — 6개 항목 (어머니 ★1/★2/★3 + 아버지 ★1/★2/★3)
# 각 항목: id (R-XX) / name (slug) / character (mother|father) / star (1|2|3) /
#         base (CH-02_mother.png or CH-03_father.png) / expression_prompt (★N specific)
# ─────────────────────────────────────────────────────────────────────────────
REACTIONS = [
    {
        "id": "R-01",
        "name": "mother_star1",
        "character": "mother",
        "star": 1,
        "base": "CH-02_mother.png",
        "expression_prompt": """EXPRESSION CHANGE — mother ★1 (mild satisfaction, score 30-59 percent,
acceptable but not exciting):
- Two small black dot eyes, OPEN and looking forward in a normal alert state (NOT closed,
  NOT crescent arc — just normal open dot eyes, same shape as base image).
- A SUBTLE small arc smile (small gentle upward curve, mouth closed, the corners of the
  mouth softly lifted just a touch — a polite warm motherly "this is okay, I appreciate it"
  smile, NOT a big delighted smile, NOT a frown).
- Slight head tilt to one side (a small ~5-10 degree tilt, suggesting gentle contemplative
  warmth — motherly nurturing acknowledgment of the food).
- Optional: one mitten hand visible near the chin in a small "thoughtful tasting" gesture,
  OR holding a single pair of wooden chopsticks near the lips (minor accent only).

The reaction reads as MILD WARM ACCEPTANCE — the mother appreciates the dish but it hasn't
truly wowed her. The warmth of the motherly nurturing tone is preserved (NOT cold, NOT
disappointed, NOT sad). This is the LOW END of the satisfaction gradient (between sad 0-29%
penalty zone and ★2 60% pleased zone).

Important also for ★1: this is the mother's MILD POSITIVE acceptance reaction. NOT sad
teardrop, NOT crying, NOT disappointed (the Week 1 CH-04_mother_star1 sad teardrop variant
is deprecated for this gradient — the new ★1 is a positive subtle warm smile, the lowest
positive gradient step)."""
    },
    {
        "id": "R-02",
        "name": "mother_star2",
        "character": "mother",
        "star": 2,
        "base": "CH-02_mother.png",
        "expression_prompt": """EXPRESSION CHANGE — mother ★2 (happy / pleased, score 60-89 percent,
solidly satisfied, nice work):
- Two small black dot eyes, slightly softened into GENTLE UPWARD CRESCENT ARCS (still small
  simple shapes, but starting to curve upward at the corners like a happy smiling-eye
  crinkle — a clear step up from ★1 normal-open dots toward ★3 fully closed happy arcs).
- A BIGGER warm smile compared to ★1 — the mouth is slightly OPEN in a small open-arc smile
  (showing a small hint of mouth interior, like a gentle "oh, this is really good!" smile,
  NOT just a closed-mouth polite smile).
- Head naturally upright, body language relaxed and pleased.
- Optional: one mitten hand visible holding a small white rice bowl OR wooden chopsticks in
  a "happily eating" gesture (minor accent only).

The reaction reads as GENUINE WARM HAPPINESS — the mother is solidly pleased with the dish,
the motherly nurturing tone amplifies into clear pleased warmth. A clear visual step up from
★1 (subtle) but not yet at the ★3 ecstatic level.

Important also for ★2: this is the IN-BETWEEN gradient step (★1 dot eyes ↔ ★3 fully closed
happy arcs). The eyes are at slight upward crescent SOFT ARCS (NOT fully open dots like ★1,
NOT fully closed-arc happy like ★3). The mouth is slightly OPEN (BIGGER than ★1 closed, but
SMALLER than ★3 wide open). Reference Week 1 CH-02_mother base default expression — this
★2 is closest to the base default (CH-02 base ≈ ★1-★2 boundary, ★2 is slightly more pleased
than the base)."""
    },
    {
        "id": "R-03",
        "name": "mother_star3",
        "character": "mother",
        "star": 3,
        "base": "CH-02_mother.png",
        "expression_prompt": """EXPRESSION CHANGE — mother ★3 (very happy / excited / delighted, score
90-100 percent, wow, delicious!):
- Eyes CLOSED into HAPPY UPWARD ARC SHAPES (smiling eyes, two upward crescent arcs like
  small smile-strokes — clearly HAPPY closed-arc shape, NOT sad closed eyes, NOT sleeping
  peaceful eyes).
- A BIG WIDE delighted smile — the mouth is WIDE OPEN in a clear delighted "wow, this is
  delicious!" open-mouth grin (clearly larger and more open than ★2 small open-arc smile).
  Optional: showing a small hint of teeth/tongue/mouth-interior (simple flat fill, NOT
  detailed anatomical interior).
- Body language joyful: both mitten hands raised near cheeks in delight, OR one hand
  holding chopsticks/bowl excitedly, OR clasped near the chest in motherly pride.
- Optional accent: 1-2 small simple flat geometric heart icons (single color red, NOT
  detailed) floating near the head as accent. Optional: 1-2 small simple flat geometric
  sparkle accents (single color yellow/orange) near the eyes/temples.

The reaction reads as PURE MOTHERLY DELIGHT — the mother is truly impressed and excited by
the dish, the warmest most amplified version of her motherly nurturing tone.

Important also for ★3: the eyes MUST be in HAPPY closed-arc shapes (upward crescent
smile-strokes, NOT sad closed eyes, NOT sleeping peaceful eyes, NOT crying tears). The heart
icons (if included) MUST be simple flat geometric (single color red, NOT detailed anime
hearts with shading/sparkle). The sparkle accents (if included) MUST be simple flat
geometric (NOT detailed anime sparkle effects)."""
    },
    {
        "id": "R-04",
        "name": "father_star1",
        "character": "father",
        "star": 1,
        "base": "CH-03_father.png",
        "expression_prompt": """EXPRESSION CHANGE — father ★1 (mild satisfaction, reserved, score 30-59
percent, acceptable but reserved):
- Two small black dot eyes, OPEN and looking forward in a normal alert state (NOT closed,
  NOT crescent arc — just normal open dot eyes, same shape as base image).
- A SLIM RESERVED small arc smile (small narrow arc, mouth closed, the corners of the mouth
  lifted just a slight touch — a polite reserved "this is okay" father's smile, more stoic
  and less expressive than the mother's subtle smile at the same ★1 level, reflecting the
  more reserved masculine fatherly tone, NOT a frown, NOT a big delighted smile).
- Head naturally upright, body posture upright and reserved (not slumped, not animated yet
  at this low gradient step).
- **NO thumb-up gesture** (★1 is reserved acceptance — thumb-up is for ★2 casual single
  thumb-up or ★3 enthusiastic double thumb-up only). Optional: one mitten hand visible near
  the chin in a small "thoughtful evaluation" gesture, OR holding wooden chopsticks/a small
  bowl reservedly (minor accent only).

The reaction reads as RESERVED ACCEPTANCE — the father quietly approves the dish but doesn't
outwardly express much, in line with the more stoic masculine fatherly tone at the low
gradient step. NOT cold disapproval, NOT angry, NOT disappointed — just calmly accepting.

Important also for ★1: NO thumb-up gesture (the Week 1 CH-03_father base shows a thumb-up
which is closer to ★2 — this ★1 variant trims that to a slimmer mouth-closed smile WITHOUT
the thumb-up). Reference CH-03_father.png base ONLY for the family IP (hair / outfit / face
features) — the expression is reduced to ★1 reserved level. CRITICAL: the hair tone
(salt-and-pepper darker shade) and shirt tone (teal-green darker shade) MUST EXACTLY match
the CH-03_father base image (same saturation, same shade — this anchor must be visually
consistent with R-05/R-06 as the same father family IP)."""
    },
    {
        "id": "R-05",
        "name": "father_star2",
        "character": "father",
        "star": 2,
        "base": "CH-03_father.png",
        "expression_prompt": """EXPRESSION CHANGE — father ★2 (happy / relaxed enjoyment, score 60-89
percent, genuinely satisfied, the father relaxes and smiles more openly):
- Two small black dot eyes, slightly softened into GENTLE UPWARD CRESCENT ARCS (still small
  simple shapes, but starting to curve upward at the corners like a happy smiling-eye
  crinkle — a clear step up from ★1 normal-open dots toward ★3 fully closed happy arcs).
  Slightly less pronounced crescent than the mother at the same level (fathers crinkle eyes
  a bit less openly than mothers, but the gradient direction is the same).
- A FULLER more open smile compared to ★1 — the mouth is slightly OPEN in a relaxed small
  open-arc smile (clearly larger than ★1's mouth-closed slim arc, suggesting the father has
  dropped his reserved posture into genuine relaxed enjoyment), like a contented "this is
  really good" father's smile.
- Head naturally upright, body language relaxed (one shoulder slightly relaxed, suggesting
  comfort).
- **SMALL CASUAL SINGLE THUMB-UP gesture**: one mitten hand visible giving a small subtle
  thumb-up gesture (like a toned-down version of the Week 1 CH-03_father base thumb-up — at
  ★2 the thumb-up is small and casual, at ★3 it can be more enthusiastic), OR holding
  wooden chopsticks/a bowl in relaxed enjoyment with the other hand.

The reaction reads as GENUINE RELAXED FATHERLY APPROVAL — the father's reserved posture has
dropped into clear relaxed enjoyment, the masculine warmth is amplified vs ★1 but still
restrained vs ★3. A clear visual step up from ★1 (slim reserved) but not yet at the ★3
ecstatic level.

Important also for ★2: the thumb-up is SINGLE and SMALL/CASUAL (NOT double thumb-up, NOT
enthusiastic raised fist — those are ★3). The eyes are at the IN-BETWEEN state (slight
upward crescent soft arcs, NOT fully open dots like ★1, NOT fully closed-arc happy like ★3).
The mouth is slightly OPEN (FULLER than ★1 closed, but SMALLER than ★3 wide open). CRITICAL:
the hair tone (salt-and-pepper darker shade) and shirt tone (teal-green darker shade) MUST
EXACTLY match the CH-03_father base image (same saturation, same shade — this anchor must
be visually consistent with R-04/R-06 as the same father family IP, NO lighter tone)."""
    },
    {
        "id": "R-06",
        "name": "father_star3",
        "character": "father",
        "star": 3,
        "base": "CH-03_father.png",
        "expression_prompt": """EXPRESSION CHANGE — father ★3 (very happy / excited / delighted, score
90-100 percent, wow, delicious! big fatherly approval):
- Eyes CLOSED into HAPPY UPWARD ARC SHAPES (smiling eyes, two upward crescent arcs like
  small smile-strokes — clearly HAPPY closed-arc shape, NOT sad closed eyes, NOT sleeping
  peaceful eyes). Like the Week 1 CH-05_father_star3 ★3 variant.
- A BIG WIDE delighted smile — the mouth is WIDE OPEN in a clear delighted "wow, son/
  daughter, this is GREAT!" open-mouth grin (clearly larger and more open than ★2 small
  open-arc smile). Optional: showing a small hint of teeth (simple flat fill, NOT detailed
  anatomical).
- Body language energetic and excited (clearly more animated than ★2): body tilted slightly
  forward in enthusiasm.
- **DOUBLE THUMB-UP gesture**: BOTH mitten hands giving an enthusiastic thumb-up gesture
  (both hands thumb-up raised near chest level, clearly more energetic than ★2's small
  casual single thumb-up).
- Optional accent: 2-4 small simple flat geometric sparkle accents (single color yellow/
  orange, NOT detailed anime sparkle effects, similar to Week 1 CH-05_father_star3 sparkle
  pattern) floating near the head/face/raised hands as accent — these communicate
  excitement.

The reaction reads as PEAK FATHERLY EXCITEMENT — the father is genuinely impressed and
proud, the warmest most amplified version of his masculine fatherly tone breaking through
his usual reserved posture into clear delight. This is the visual peak of the ★1 → ★2 → ★3
gradient for the father.

Important also for ★3: the thumb-up is DOUBLE (both hands), clearly more enthusiastic than
★2's single casual thumb-up. The eyes MUST be in HAPPY closed-arc shapes (upward crescent
smile-strokes, NOT sad closed eyes, NOT sleeping peaceful eyes, NOT crying tears). The
sparkle accents (if included) MUST be simple flat geometric (single color, NOT detailed
anime sparkle effects). CRITICAL: the hair tone (salt-and-pepper darker shade) and shirt
tone (teal-green darker shade) MUST EXACTLY match the CH-03_father base image (same
saturation, same shade — this anchor must be visually consistent with R-04/R-05 as the same
father family IP, NO lighter tone)."""
    },
]

BASE_DIR = PROJECT_ROOT / "assets-raw" / "week1-anchors"
OUT_DIR = PROJECT_ROOT / "assets-raw" / "reaction_anchors_m1"


# ─────────────────────────────────────────────────────────────────────────────
# Base image 사이즈 검증 + (필요 시) gpt-image-1 edit API 호환 사이즈로 resize.
# gpt-image-1 image edit API supported sizes: 1024x1024, 1536x1024, 1024x1536, auto.
# (edit_bg_anchors_v4.py와 동일 패턴)
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
        description="M1 후반 양친 reaction 6컷 v2 image edit "
        "(CH-02/CH-03 base + 표정만 변경, family IP consistency lock)"
    )
    parser.add_argument(
        "--only", type=str, default="",
        help="콤마구분 reaction ID만 (예: R-01,R-03). 빈 값=전체 6장.",
    )
    parser.add_argument(
        "--version", type=str, default="v2",
        help="파일명 suffix (기본 v2 → R-01_mother_star1_v2.png). v1 prompt-only output와 공존.",
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
    print("M1 reaction v2 image edit — CH-02/CH-03 base + 표정만 변경 (family IP lock)")
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
