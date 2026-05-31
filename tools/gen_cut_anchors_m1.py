"""
K-Food Master — M1 후반 sprint 칼/도마 + cut style 6종 anchor 자동 생성.

ADR-005 (4-stage rhythm tap) Stage 2A prerequisite — 재료 준비 = rhythm tap + Knife indicator.
art-director docs/prompts-library.md v1.14 §5.5 STYLE_SUFFIX_CUT + 칼/도마 base + cut style 6종
prompt를 그대로 inline 임베드.

칼/도마 base 1장 + cut style 6장 = 총 7장:
  - cutting_board (칼 + 도마 정적 baseline, no cut)
  - cut_style_mince (다지기 — 마늘)
  - cut_style_julienne (채썰기 — 당근)
  - cut_style_diagonal (어슷썰기 — 어묵/대파)
  - cut_style_whole (통썰기 — 호떡/김밥 cylinder 단면)
  - cut_style_sliced_rounds (송송썰기 — 대파)
  - cut_style_cube (깍둑썰기 — 두부)

각 cut style은 "cut된 결과 상태" (cutting result, NOT cutting action) — 도마 + cut된 재료 + 칼 옆에 놓임.
한식 anchor 일관성: Cool Sage #C8D5C0 bg + modern saturated + slim outline 2-3px + top-down view.

Usage:
    py tools/gen_cut_anchors_m1.py
    py tools/gen_cut_anchors_m1.py --only cutting_board                # 1장만
    py tools/gen_cut_anchors_m1.py --only cut_style_mince,cut_style_julienne  # 일부
    py tools/gen_cut_anchors_m1.py --model gpt-image-1 --quality medium
    py tools/gen_cut_anchors_m1.py --version v2                        # 파일명 suffix

Default:
    model    = gpt-image-1 (medium quality)
    quality  = medium ($0.042/img × 7 = ~$0.29 total)
    size     = 1024x1024 (square 1:1)
    out_dir  = assets-raw/cut_anchors_m1/
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
# STYLE_SUFFIX_CUT — 모든 cut anchor prompt 끝에 부착
# prompts-library.md v1.14 §5.5 STYLE_SUFFIX_CUT.
# 도마 + Cool Sage bg + modern saturated + slim outline + top-down 통일.
# ─────────────────────────────────────────────────────────────────────────────
STYLE_SUFFIX_CUT = """Format: square 1:1.
View: top-down (overhead view, looking straight down at the cutting board surface).
Style: modern mobile casual game asset, clean 2D illustration in Royal Match (Dream Games 2021)
aesthetic. Hero shot of a Korean kitchen cutting board with ingredients prepared for cooking.
Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), single color fill with optional
soft 1-layer cel shading and ONE small specular highlight per element (juicy/freshness appetite).
Vibrant saturated colors at 80-90 percent saturation, warm food + cool background balance.

CUTTING BOARD (consistent across all 7 cut anchors):
- A Korean kitchen wooden cutting board (도마) in warm brown wood color (#A67049 single fill,
  slim grain line accent 1-2 only, NOT heavy realistic wood texture), rectangular shape with
  rounded corners (approximately 16:9 horizontal proportion, filling most of the image).
- The board has a slight darker rim outline (warm dark #2D1D14, 2-3px), clean modern flat appearance.

KNIFE (consistent silhouette across all 7 cut anchors):
- A modern Korean kitchen knife (식칼) — warm brown wood handle (#A67049 matching the board) +
  silver-gray steel blade (#C8C8C8 single fill with subtle slim cel shading), slim simple geometric
  shape, slightly elongated rectangular blade with a subtle pointed tip.
- The knife sits on or beside the cutting board (placement varies per anchor — see body prompt).

BACKGROUND:
- Solid Cool Sage #C8D5C0 background (consistent across all 7 cut anchors, matches food + environment
  anchor base for cross-asset one-game-world identity).
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
mortar and pestle (절구), traditional Korean stone tools (replaced by knife + cutting board as the
direct gameplay mechanic mapping for ADR-005 Stage 2A rhythm tap),
human characters, hands holding the knife, cooking action mid-motion, kitchen environment background,
multiple cutting boards, multiple knives, any English or Korean text legibly readable on the board."""


# ─────────────────────────────────────────────────────────────────────────────
# CUTS — 7개 항목 (도마 base 1 + cut style 6)
# prompts-library.md v1.14 §5.5.1~§5.5.7 본문 inline.
# 각 항목: id / name / body. STYLE_SUFFIX_CUT는 자동 append.
# ─────────────────────────────────────────────────────────────────────────────
CUTS = [
    {
        "id": "cutting_board",
        "name": "cutting_board",
        # §5.5.1 칼/도마 base anchor (cut style 추가 X, 정적 baseline)
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with a kitchen knife resting on top, top-down view, static baseline state (NO food on the board, NO
cut ingredients, NO cutting action in progress — this is the empty cutting board + knife baseline
used as the Scene 2 (Kitchen) background asset in the K-Food Master mobile game).

The wooden cutting board fills most of the image (approximately 16:9 horizontal proportion within
the square frame), centered with a small margin around it. The board is warm brown wood (#A67049
single fill) with 1-2 subtle slim grain lines as accent (NOT heavy realistic wood grain texture).
The board has a slim bold dark outline (warm dark #2D1D14, 2-3px) and rounded corners (modern
friendly mobile game shape).

The Korean kitchen knife sits on the cutting board surface, placed diagonally at approximately
a 45-degree angle (handle in the lower-left or lower-right corner of the board, blade pointing
toward the opposite upper corner — a natural relaxed placement, NOT mid-swing motion). The knife
has a warm brown wood handle (#A67049 matching the board) and a silver-gray steel blade (#C8C8C8
single fill with subtle slim cel shading), simple geometric slim silhouette.

%s

Important also: this is the EMPTY cutting board + knife baseline state — NO food ingredients on
the board, NO cut pieces, NO vegetables, NO meat, NO fish, NO garlic, NO scallions, NO tofu, NO
sauce, NO mortar and pestle, NO traditional Korean stone tools (this is the modern direct-mechanic
mapping per ADR-005 Stage 2A rhythm tap requirement). The knife is at a relaxed diagonal placement
(not raised mid-swing, not chopping in motion). This is the static baseline cutting board scene
used as the foundation for all 6 cut style variants.""",
    },
    {
        "id": "cut_style_mince",
        "name": "cut_style_mince",
        # §5.5.2 다지기 (mince) — 마늘 (가장 빠른 BPM 140, F-12 갈비 / F-09 김치찌개)
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with MINCED GARLIC (다진 마늘) scattered on top, top-down view, cutting RESULT state (the garlic
has just been finely minced — many tiny irregular fine bits scattered across the board surface,
NOT cutting in progress). The signature ingredient mapping = 마늘 (Korean garlic, the fastest BPM
~140 cut style, used in F-12 galbi marinade and F-09 kimchi jjigae).

On the cutting board surface: a generous pile of FINELY MINCED GARLIC bits — many small irregular
yellowish-white granules (each tiny bit approximately 1-3mm, irregular angular shapes since they
are finely chopped, NOT round perfect discs, NOT large chunks). The minced garlic is scattered in
a loose cluster covering roughly the center-right portion of the board, with a few bits scattered
slightly wider to give a natural "just been minced" appearance. Optional: 1-2 unminced whole garlic
cloves (small rounded teardrop shape, off-white color) sit on the board as visual anchors for
"before mince" context — these are partial reference shapes, NOT the hero element.

The kitchen knife rests on the LEFT side of the cutting board, blade flat against the board
surface, handle pointing toward the lower-left corner, slightly angled (the knife is set down
after mincing, NOT in motion mid-chop). The knife blade has subtle hints of garlic juice sheen on
its edge (very minimal accent).

%s

Important also: this is the MINCE (다지기) cut style result — the garlic must read as MANY TINY
FINE IRREGULAR BITS (1-3mm each, finely chopped texture), NOT round disc-shaped slices, NOT large
chunks, NOT julienne strips, NOT cube dice. The signature ingredient is Korean garlic (마늘) —
small yellowish-white minced granules scattered across the board as the hero element. This is the
cutting RESULT state (just finished mincing), NOT cutting action mid-chop. The mapping is mince
(다지기) = fastest BPM ~140 for ADR-005 Stage 2A rhythm tap — visually identifiable as the most
granular/fine cut texture among the 6 cut styles.""",
    },
    {
        "id": "cut_style_julienne",
        "name": "cut_style_julienne",
        # §5.5.3 채썰기 (julienne) — 당근 (F-08 비빔밥 / F-11 잡채)
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with JULIENNED CARROT (채썬 당근) on top, top-down view, cutting RESULT state. The signature
ingredient mapping = 당근 (Korean julienned carrot, used in F-08 bibimbap and F-11 japchae as the
classic julienne signature vegetable).

On the cutting board surface: a generous pile of JULIENNED CARROT STRIPS — many thin elongated
orange (#FF9933 single fill, bright vibrant saturated) strips, each strip approximately 4-6cm long
× 2-3mm wide × 2-3mm thick (thin matchstick-like elongated strips, all parallel-ish aligned and
slightly overlapping in a relaxed natural pile, NOT perfectly stacked geometric, NOT cube cubes,
NOT round discs). The julienne strips are arranged in the center-right portion of the board,
suggesting a "just been julienned" pile. Approximately 15-20 visible strips. Optional: 1-2 unsliced
whole carrots (cylindrical orange shape with a green leafy top) sit on the LEFT side of the board
as visual reference for "before julienne" — these are partial anchors, NOT the hero element.

The kitchen knife rests on the LEFT side of the cutting board next to the whole carrots, blade
flat against the board surface, handle pointing toward the lower-left corner (the knife is set
down after julienning, NOT in motion).

%s

Important also: this is the JULIENNE (채썰기) cut style result — the carrots must read as MANY
THIN ELONGATED MATCHSTICK STRIPS (4-6cm long × 2-3mm wide × 2-3mm thick, thin elongated parallel
shapes), NOT mince bits, NOT round disc slices, NOT cube dice, NOT large chunks. The signature
ingredient is Korean julienned carrot (당근 채) — bright orange elongated thin strips as the hero
element. This is the cutting RESULT state, NOT cutting action mid-slice. The mapping is julienne
(채썰기) for ADR-005 Stage 2A rhythm tap — visually identifiable as the thinnest elongated strip
shape among the 6 cut styles (NOT short oval like diagonal slice, NOT thin round like sliced
rounds).""",
    },
    {
        "id": "cut_style_diagonal",
        "name": "cut_style_diagonal",
        # §5.5.4 어슷썰기 (diagonal slice) — 어묵/대파 (F-04 떡볶이 / 모든 국물)
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with DIAGONAL-SLICED FISHCAKE AND SCALLION (어슷썬 어묵 + 대파) on top, top-down view, cutting
RESULT state. The signature ingredient mapping = 어묵 + 대파 (Korean diagonal-sliced fish cake and
scallion, used in F-04 tteokbokki and all Korean soup/stew dishes).

On the cutting board surface: a mix of DIAGONAL OVAL FISH CAKE SLICES and DIAGONAL OVAL SCALLION
SLICES. The fish cake (어묵) slices are flat oval-elongated shapes (each approximately 5-7cm long
diagonal × 2-3cm wide, light golden-brown #C8923C single fill, slightly translucent appearance,
4-5 slices arranged in a relaxed overlapping pile in the center-right of the board). The scallion
(대파) diagonal slices are smaller oval shapes (each approximately 3-4cm long diagonal × 1-1.5cm
wide, white base fading to bright green tip, 6-8 slices scattered around the fish cake slices).

Both ingredient types are cut at a clear diagonal angle (어슷썰기 = the knife cuts the cylindrical
ingredient at a slanted angle, producing elongated OVAL slices that are visibly longer in one
dimension than the cross-section would be — the elongated oval shape IS the diagonal slice
signature, NOT round perfect circles which would be 통썰기). Optional: 1 unsliced whole fish cake
stick (cylindrical light golden shape, ~10cm long) and 1 unsliced whole scallion (cylindrical
white-to-green shape, ~12cm long) sit on the LEFT side of the board as visual reference for
"before diagonal slice".

The kitchen knife rests on the LEFT side of the cutting board, blade flat against the board
surface, handle pointing toward the lower-left corner (the knife is set down after slicing, NOT
in motion).

%s

Important also: this is the DIAGONAL SLICE (어슷썰기) cut style result — the slices must read as
ELONGATED OVAL SHAPES (longer in one dimension than the natural cross-section diameter, the
diagonal cut signature), NOT round perfect circles (those would be 통썰기), NOT thin strips (those
would be 채썰기), NOT cube dice. The signature ingredients are Korean fish cake (어묵) AND Korean
scallion (대파) — both diagonal-sliced as the hero elements. The elongated oval shape is the
critical visual identifier — the more elongated the oval, the steeper the diagonal angle. This is
the cutting RESULT state, NOT cutting action mid-slice. The mapping is diagonal slice (어슷썰기)
for ADR-005 Stage 2A rhythm tap — visually distinct from whole slice (round) and sliced rounds
(thin round).""",
    },
    {
        "id": "cut_style_whole",
        "name": "cut_style_whole",
        # §5.5.5 통썰기 (whole slice / round disc) — 호떡/김밥 cylinder 단면 (F-02 / F-03, BPM 70)
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with WHOLE-SLICED KIMBAP DISCS (통썬 김밥) on top, top-down view, cutting RESULT state. The
signature ingredient mapping = 김밥 cylinder 단면 (Korean kimbap whole slices, used in F-03 kimbap
service form, the slowest BPM ~70 cut style — the most stable round disc shape).

On the cutting board surface: 4-5 ROUND DISC KIMBAP SLICES arranged in a relaxed row across the
center-right portion of the board. Each slice is a perfect round disc (approximately 3cm diameter
× 1.5-2cm thick, the classic Korean kimbap cylindrical cross-section). Each disc shows the kimbap
signature cross-section: a black seaweed (gim) outer ring + white rice with FINE small grains
underneath + a colorful cross-section center showing distinct ingredient blocks: yellow pickled
radish (danmuji), orange carrot, green spinach or cucumber, red ham or beef strips, and yellow
egg strips. The slices are slightly overlapping in the relaxed row, all oriented round-face-up to
show the cross-section. A few sesame seed dots are sprinkled on top.

Optional: 1 unsliced whole kimbap cylinder (uncut roll, ~12-15cm long cylinder with black gim
exterior) sits on the LEFT side of the board as visual reference for "before whole slice" — this
is a partial anchor, NOT the hero element.

The kitchen knife rests on the LEFT side of the cutting board next to the unsliced kimbap roll,
blade flat against the board surface, handle pointing toward the lower-left corner (the knife is
set down after slicing, NOT in motion).

%s

Important also: this is the WHOLE SLICE (통썰기) cut style result — the kimbap slices must read
as PERFECT ROUND DISCS (cylindrical cross-sections, the round-face-up disc shape, ~3cm diameter ×
1.5-2cm thick), NOT elongated oval (those would be 어슷썰기 diagonal slice), NOT thin matchstick
strips (those would be 채썰기), NOT mince bits, NOT cube dice. The signature ingredient is Korean
kimbap (김밥) whole slices — the round disc shape with visible colorful cross-section is the hero.
The whole slice (통썰기) maps to the slowest BPM ~70 cut style for ADR-005 Stage 2A rhythm tap —
the most stable easiest cut shape, visually identifiable as the largest most regular round disc
among the 6 cut styles. NOT Japanese maki sushi (those use raw fish + tight compressed rice + thin
seaweed) — this is Korean kimbap (thicker disc, cooked vegetables, matte gim).""",
    },
    {
        "id": "cut_style_sliced_rounds",
        "name": "cut_style_sliced_rounds",
        # §5.5.6 송송썰기 (sliced thin rounds) — 대파 (F-12 갈비 / 모든 가니쉬)
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with SLICED THIN ROUND SCALLIONS (송송 썬 대파) scattered on top, top-down view, cutting RESULT
state. The signature ingredient mapping = 대파 (Korean scallion / spring onion thinly sliced into
small round discs, used in F-12 galbi-gui as the hero garnish and across all Korean dishes as the
finishing garnish).

On the cutting board surface: many SMALL THIN ROUND SCALLION SLICES — bright green small disc
shapes (each approximately 1-1.5cm diameter × 1-3mm thick, very thin round discs from cross-cutting
the cylindrical scallion stem). Each slice shows the characteristic scallion ring pattern: a small
white circle in the center (the hollow scallion stem cross-section interior) surrounded by a bright
green ring (the outer scallion stem wall). Approximately 20-30 visible thin round slices scattered
across the center-right portion of the board in a generous loose pile, suggesting a "just been
송송-sliced" abundant garnish ready for sprinkling.

Optional: 1-2 unsliced whole scallion stems (cylindrical white-base-to-green-tip shape, ~12cm
long) sit on the LEFT side of the board as visual reference for "before sliced rounds" — these
are partial anchors, NOT the hero element.

The kitchen knife rests on the LEFT side of the cutting board next to the unsliced scallions,
blade flat against the board surface, handle pointing toward the lower-left corner (the knife is
set down after slicing, NOT in motion).

%s

Important also: this is the SLICED THIN ROUNDS (송송썰기) cut style result — the scallion slices
must read as MANY SMALL THIN ROUND DISCS (1-1.5cm diameter × 1-3mm thick, very thin round shape
with the characteristic small white center ring + bright green outer ring), NOT elongated oval
(those would be 어슷썰기 diagonal slice), NOT thicker large round disc (those would be 통썰기
whole slice — 송송 is distinctly thinner and smaller), NOT thin matchstick strips (those would be
채썰기), NOT mince bits, NOT cube dice. The signature ingredient is Korean scallion (대파) 송송
sliced — the small thin bright green round discs scattered abundantly are the hero. Compared to
통썰기 (large stable round disc), 송송썰기 is the SAME round shape but distinctly THINNER and
SMALLER (rapid repeated thin slicing). The mapping is sliced rounds (송송썰기) for ADR-005 Stage
2A rhythm tap.""",
    },
    {
        "id": "cut_style_cube",
        "name": "cut_style_cube",
        # §5.5.7 깍둑썰기 (cube dice) — 두부 (F-09 김치찌개 / F-10 순두부 squarish blocks)
        "body": """A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with CUBE-DICED TOFU (깍둑 썬 두부) on top, top-down view, cutting RESULT state. The signature
ingredient mapping = 두부 (Korean firm tofu cubed, used in F-09 kimchi jjigae as the signature
squarish white tofu blocks).

On the cutting board surface: 8-12 SMALL TOFU CUBES — each cube approximately 2-2.5cm × 2-2.5cm ×
2-2.5cm (roughly equal-sided cubes, clean white (#FAFAFA single fill with very slight cool sage
cel shading on one corner) with bold outline 2-3px and clean geometric square edges). The cubes
are arranged in a relaxed loose cluster (not perfect grid, slight natural overlap, suggesting
"just been cubed"). Approximately 8-12 visible cubes scattered across the center-right portion of
the board, all clearly readable as 3D cube shapes (slight top-face highlight + side-face slight
shadow indicates the cube volume even in top-down view).

Optional: 1 uncut tofu block (larger rectangular slab, ~10cm × 6cm × 3cm, same white color) sits
on the LEFT side of the board as visual reference for "before cube dice" — this is a partial
anchor, NOT the hero element.

The kitchen knife rests on the LEFT side of the cutting board next to the uncut tofu block, blade
flat against the board surface, handle pointing toward the lower-left corner (the knife is set
down after dicing, NOT in motion).

%s

Important also: this is the CUBE DICE (깍둑썰기) cut style result — the tofu must read as MANY
SMALL EQUAL-SIDED CUBES (2-2.5cm × 2-2.5cm × 2-2.5cm, clearly cubic 3D shapes with visible top
and side faces), NOT thin slices, NOT mince bits, NOT elongated strips, NOT round discs, NOT
oval diagonal slices. The signature ingredient is Korean firm tofu (두부) — white squarish cube
blocks as the hero. The cube shape with visible 3D volume (top face + side face shading hint) is
the critical visual identifier for 깍둑썰기. This is the cutting RESULT state, NOT cutting action.
The mapping is cube dice (깍둑썰기) for ADR-005 Stage 2A rhythm tap — visually identifiable as
the most volumetric cube shape among the 6 cut styles. NOT Chinese mapo tofu (uses firm tofu in
brown Sichuan sauce on a flat plate — different context), this is the raw cubed tofu prep state
on the cutting board.""",
    },
]


def build_prompt(body: str) -> str:
    """body의 %s 자리에 STYLE_SUFFIX_CUT를 끼워 넣어 최종 prompt 완성."""
    return body % STYLE_SUFFIX_CUT


def main() -> None:
    parser = argparse.ArgumentParser(description="M1 후반 칼/도마 + cut style 6종 anchor 자동 생성")
    parser.add_argument(
        "--only", type=str, default="",
        help="콤마구분 cut ID만 (예: cutting_board,cut_style_mince). 빈 값=전체 7장."
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
        default=PROJECT_ROOT / "assets-raw" / "cut_anchors_m1",
        help="출력 디렉터리"
    )
    parser.add_argument(
        "--version", type=str, default="v1",
        help="파일명 suffix (예: v1 → cutting_board_v1.png)"
    )
    args = parser.parse_args()

    only_set = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    selected = [c for c in CUTS if (only_set is None or c["id"] in only_set)]

    if not selected:
        sys.exit(f"❌ --only 매칭 cut anchor 없음. 유효 ID: {[c['id'] for c in CUTS]}")

    args.out_dir.mkdir(parents=True, exist_ok=True)

    # cost estimate
    if args.model == "dall-e-3":
        unit = 0.080 if args.quality == "hd" else 0.040
    else:
        unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
        unit = unit_map.get(args.quality, 0.042)
    est_total = unit * len(selected)
    print("=" * 70)
    print(f"🔪 M1 후반 cut anchor 생성 시작 (ADR-005 Stage 2A prerequisite)")
    print(f"   모델: {args.model} / 품질: {args.quality} / 사이즈: {args.size}")
    print(f"   대상: {len(selected)}장 ({[c['id'] for c in selected]})")
    print(f"   비용 예상: ${unit:.3f}/장 × {len(selected)} = ${est_total:.2f}")
    print(f"   출력: {args.out_dir}")
    print("=" * 70)

    api_key = load_api_key()
    client = OpenAI(api_key=api_key)

    successes: list[str] = []
    failures: list[tuple[str, str]] = []
    t0 = time.time()

    for i, cut in enumerate(selected, 1):
        cid = cut["id"]
        name = cut["name"]
        out_path = args.out_dir / f"{name}_{args.version}.png"
        prompt = build_prompt(cut["body"])

        print(f"\n[{i}/{len(selected)}] {cid} → {out_path.name}")
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
            successes.append(cid)
        except Exception as exc:
            elapsed = time.time() - t_start
            print(f"   ❌ FAIL ({elapsed:.1f}s): {exc!r}")
            failures.append((cid, repr(exc)))

    total_elapsed = time.time() - t0
    print("\n" + "=" * 70)
    print(f"✅ 완료: {len(successes)}/{len(selected)} 장 — 총 {total_elapsed/60:.1f}분")
    if successes:
        print(f"   성공: {', '.join(successes)}")
    if failures:
        print(f"   실패 {len(failures)}장:")
        for cid, err in failures:
            print(f"     - {cid}: {err}")
    print(f"   비용 예상: ${unit * len(successes):.2f}")
    print(f"   저장 경로: {args.out_dir}")
    print("=" * 70)


if __name__ == "__main__":
    main()
