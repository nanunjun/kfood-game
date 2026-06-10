"""
K-Food Master — P0 recipe-correctness ingredient HERO art (standalone, NOT baked).

목적 (2026-06-07, art-director): recipe matrix P0 정답 재료 3종을 STANDALONE single hero
로 생성한다. 떡볶이(rice_cake + fish_cake)·비빔밥(gochujang_dollop) recipe correctness 용
재료 art 공백을 메운다. gameplay/CSV/scoring 미변경 — 순수 standalone asset only.

대상 3종 (모두 단독 transparent hero — 도마/그릇/scene/baked 0개):
  1. rice_cake       (떡 — 떡볶이 가래떡): 흰-크림 통통한 원통 rice cake 여러 개.
  2. fish_cake       (어묵 — 떡볶이): 갈색 어묵 어슷썰기 slice 몇 개.
  3. gochujang_dollop(고추장 — 비빔밥 양념): 진한 빨강 고추장 paste 한 덩이 (dollop, NOT 가루).

규칙 (Style Bible v1 §5 + ingredient-tool-art-lock.md Hero Asset Mandate):
  - STANDALONE single hero — NO board / NO bowl / NO scene / NO other co-asset baked.
  - Style Bible v1 톤 = soft volumetric (2-3단 gradient + top-left key + soft rim + specular
    1-2점), warm Cocoa #3A2A1E outline 3-4px, warm cozy muted palette, 3/4 slight-overhead view.
  - chopped/baked 금지(고추장은 dollop, 가루 gochugaru 아님; 어묵은 어슷 raw slice).
  - recognizable alone, no text — Hero Asset Test (HA1 식별 + HA6 NOT-UI-icon 필수).
  - 한식 정체성: 가래떡 통통 원통 / 어묵 어슷 단면 / 고추장 진한 빨강 윤기 paste mound.

STYLE_SUFFIX_HERO 는 gen_ingredient_tool_hero.py 의 LOCKED suffix 를 그대로 재사용
(consistency LOCK — 동일 lighting/outline/camera/palette + standalone NO-co-asset 강제).

출력 (--naming clean, default):
  assets-raw/p0_ingredients_m2/{id}.png   (rice_cake.png / fish_cake.png / gochujang_dollop.png)
  ※ --out-dir 로 ingredient_tool_hero_m2/ 에 직접 떨굴 수도 있음 (Godot import 폴더 통합 시).

Usage:
    py tools/gen_p0_ingredients.py --background transparent             # 3종 transparent hero (권장)
    py tools/gen_p0_ingredients.py --background transparent --only rice_cake
    py tools/gen_p0_ingredients.py --background transparent \
        --out-dir assets-raw/ingredient_tool_hero_m2                     # hero 폴더로 직접
    py tools/gen_p0_ingredients.py --quality high --background transparent

Default:
    model=gpt-image-1 / quality=medium ($0.042/img) / size=1024x1024 /
    background=transparent (standalone production 권장) / out=p0_ingredients_m2/
"""

import argparse
import sys
import time
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT / "tools"))

from gen_image import generate_image, load_api_key  # noqa: E402
# STYLE_SUFFIX_HERO 재사용 — hero driver 와 100% 동일 톤/standalone 규약 강제.
from gen_ingredient_tool_hero import STYLE_SUFFIX_HERO  # noqa: E402

if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")

from openai import OpenAI  # noqa: E402


# ─────────────────────────────────────────────────────────────────────────────
# P0 INGREDIENTS — recipe-correctness 정답 재료 3종. 각 body 끝 %s 1개 → STYLE_SUFFIX_HERO.
# 모두 STANDALONE single hero (도마/그릇/scene/baked 금지 — suffix 가 강제).
# ─────────────────────────────────────────────────────────────────────────────
P0_INGREDIENTS = [
    {
        "id": "rice_cake", "name": "떡 (Rice Cake / 가래떡)",
        "body": """A HERO illustration of Korean tteokbokki rice cakes (떡볶이 가래떡 / garaetteok):
a small relaxed group of 4-5 plump cylindrical rice cake sticks, each a short finger-thick log
(about 2-3 cm) with smoothly rounded ends, a soft chewy creamy-white surface (cream-white
#FAF4E6, NOT pure bright white) with a gentle glistening sheen that reads as soft springy
glutinous rice cake. Each cylinder shows real rounded 3D volume with a soft top-left key
highlight and a warm shaded underside; a couple of cylinders rest naturally overlapping the
others (a casual just-prepared cluster, NOT a rigid grid). Tender, bouncy and appetizing.
This is the hero ingredient of tteokbokki — the plump white rice cake cylinders themselves are
the standalone hero (NO sauce, NO bowl, NO board, NO other ingredient).
%s""",
    },
    {
        "id": "fish_cake", "name": "어묵 (Fish Cake — 어슷썰기)",
        "body": """A HERO illustration of SLICED Korean fish cake for tteokbokki (어묵 어슷썰기): a small
relaxed cluster of a few flat diagonally-cut fish cake slices, each an elongated oval/triangular
piece (어슷 단면) of fried fish paste sheet in warm light golden-brown (#C8923C) with a lightly
browned mottled surface, soft pliable springy edges, the cut cross-section showing the pale dense
fish-paste interior. Each slice has soft flat-but-dimensional volume with a faint oily sheen and a
soft top-left key highlight; a few slices overlap naturally (just-cut, NOT a grid). Springy, savory
and appetizing. The sliced fish cake pile itself is the standalone hero (NO broth, NO bowl, NO
board, NO rice cake, NO other ingredient).
%s""",
    },
    {
        "id": "gochujang_dollop", "name": "고추장 (Gochujang Paste Dollop)",
        "body": """A HERO illustration of a single dollop of Korean gochujang red chili paste
(고추장 한 덩이): one thick glossy mound / scoop of deep rich red fermented chili paste (deep red
#B5341F), a smooth dense spoon-scooped blob with soft rounded peaks and a gentle swirl, a thick
slow-pouring paste consistency (NOT a liquid puddle, NOT dry powder, NOT loose flakes). The
surface has a wet glistening sheen with one or two soft specular highlights from the top-left key
light and a deeper shaded base giving it real glossy dimensional volume; a soft warm contact shadow
grounds the mound. IMPORTANT: this is a smooth thick PASTE DOLLOP (gochujang paste), NOT gochugaru
red pepper powder, NOT loose chili flakes, NOT a sauce splatter. Deep warm appetizing red. The
single paste dollop itself is the standalone hero (NO spoon, NO bowl, NO board, NO food).
%s""",
    },
]


def build_prompt(body: str) -> str:
    """body의 첫 %s를 STYLE_SUFFIX_HERO로 교체 (.replace로 다른 % 안전 보존)."""
    return body.replace("%s", STYLE_SUFFIX_HERO, 1)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="P0 recipe-correctness ingredient HERO art 생성 (standalone, NOT baked)"
    )
    parser.add_argument("--only", type=str, default="",
                        help="콤마구분 item id만 (예: rice_cake,gochujang_dollop)")
    parser.add_argument("--model", default="gpt-image-1", choices=["dall-e-3", "gpt-image-1"])
    parser.add_argument("--size", default="1024x1024")
    parser.add_argument("--quality", default="medium",
                        help="gpt-image-1: low/medium/high/auto")
    parser.add_argument("--background", default="transparent",
                        choices=["transparent", "opaque", "auto"],
                        help="transparent=알파 PNG (standalone production 권장) / opaque=Cream bg")
    parser.add_argument("--out-dir", type=Path,
                        default=PROJECT_ROOT / "assets-raw" / "p0_ingredients_m2",
                        help="출력 폴더 (hero 폴더 통합 시 ingredient_tool_hero_m2 지정 가능)")
    args = parser.parse_args()

    only = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    jobs = [ing for ing in P0_INGREDIENTS if not only or ing["id"] in only]

    if not jobs:
        sys.exit("❌ 매칭 작업 없음 (--only 확인: rice_cake / fish_cake / gochujang_dollop)")

    args.out_dir.mkdir(parents=True, exist_ok=True)

    unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
    if args.model == "dall-e-3":
        unit = 0.080 if args.quality == "hd" else 0.040
    else:
        unit = unit_map.get(args.quality, 0.042)
    est_total = unit * len(jobs)

    print("=" * 72)
    print("🍳 P0 recipe-correctness ingredient HERO 생성 (standalone — NOT baked)")
    print(f"   대상: {[j['id'] for j in jobs]}")
    print(f"   모델={args.model} 품질={args.quality} 사이즈={args.size} 배경={args.background}")
    print(f"   {len(jobs)}장  비용예상: ${unit:.3f}/장 × {len(jobs)} = ${est_total:.2f}")
    print(f"   출력: {args.out_dir}")
    print("=" * 72)

    client = OpenAI(api_key=load_api_key())
    successes, failures = [], []
    t0 = time.time()

    for i, ing in enumerate(jobs, 1):
        fname = f"{ing['id']}.png"
        out_path = args.out_dir / fname
        prompt = build_prompt(ing["body"])

        print(f"\n[{i}/{len(jobs)}] {ing['name']} → {fname}")
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
