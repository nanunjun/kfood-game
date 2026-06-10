"""
K-Food Master — Vertical Slice (VS) standalone HERO assets (NOT baked).

목적 (2026-06-09, art-director): Gimbap vertical slice 의 "bad prep 시각" 공백을 메운다.
기존 carrot_julienne(perfect — 고른 긴 얇은 주황 채)와 명확히 대비되는 BAD 버전 1종을
STANDALONE single transparent hero 로 생성한다. gameplay/CSV/scoring 미변경 — 순수 art only.

대상 1종 (단독 transparent hero — 도마/그릇/scene/baked 0개):
  1. carrot_julienne_bad  (당근 채 — 잘못 썬 버전): 두껍고 uneven, broken/stubby 조각 섞인
     chunky messy pile. perfect carrot_julienne(thin even matchsticks)와 명확 대비.

대비 핵심 (perfect → bad):
  - perfect = "thin even orange matchstick strips" (고른 긴 얇은 채), 일정 굵기, clean.
  - bad     = thick-and-thin IRREGULAR sticks, 굵기 제각각, 일부 짧고 굵은 stub/broken
              조각, NOT clean even strips — deliberately BADLY cut, messy chunky pile.
  - 같은 주황 톤(#E8732C 주황 — perfect 당근과 동일 색)이라 색이 아니라 FORM 으로만 bad 식별.

규칙 (Style Bible v1 §5 + ingredient-tool-art-lock.md Hero Asset Mandate):
  - STANDALONE single hero — NO board / NO bowl / NO scene / NO other co-asset baked.
  - STYLE_SUFFIX_HERO 재사용 (perfect carrot_julienne 와 100% 동일 lighting/outline/camera/
    palette + standalone NO-co-asset 강제) → perfect 와 같은 "세계관"의 형제 자산으로 보이되
    오직 cut FORM 만 bad. (톤이 달라지면 "다른 게임 자산"처럼 보임 — 대비는 form 으로만.)
  - recognizable alone, no text — 여전히 "당근 채" 로 식별 가능해야 함 (단지 잘못 썬).
  - bad 라는 게 명확 — 보자마자 "엉성하게 썰었다" 가 읽혀야 함 (perfect 옆에 두면 즉시 대비).

STYLE_SUFFIX_HERO 는 gen_ingredient_tool_hero.py 의 LOCKED suffix 를 그대로 재사용.

출력 (default = Godot import 폴더로 직접):
  assets-raw/ingredient_tool_hero_m2/carrot_julienne_bad.png

Usage:
    py tools/gen_vs_assets.py                                  # carrot_julienne_bad 1장 transparent (권장)
    py tools/gen_vs_assets.py --quality high                   # high quality ($0.167/img)
    py tools/gen_vs_assets.py --background opaque               # Cream bg 검수용
    py tools/gen_vs_assets.py --only carrot_julienne_bad

Default:
    model=gpt-image-1 / quality=medium ($0.042/img) / size=1024x1024 /
    background=transparent (standalone production) / out=ingredient_tool_hero_m2/
"""

import argparse
import sys
import time
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT / "tools"))

from gen_image import generate_image, load_api_key  # noqa: E402
# STYLE_SUFFIX_HERO 재사용 — perfect carrot_julienne 와 100% 동일 톤/standalone 규약 강제.
from gen_ingredient_tool_hero import STYLE_SUFFIX_HERO  # noqa: E402

if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")

from openai import OpenAI  # noqa: E402


# ─────────────────────────────────────────────────────────────────────────────
# VS ASSETS — vertical-slice 보충 standalone hero. 각 body 끝 %s 1개 → STYLE_SUFFIX_HERO.
# 모두 STANDALONE single hero (도마/그릇/scene/baked 금지 — suffix 가 강제).
# ─────────────────────────────────────────────────────────────────────────────
VS_ASSETS = [
    {
        "id": "carrot_julienne_bad", "name": "당근 채 — BAD (잘못 썬 채)",
        "body": """A HERO illustration of BADLY / UNEVENLY cut carrot julienne (잘못 썬 당근 채 —
deliberately poorly cut): a messy chunky pile of carrot sticks that were cut by an unskilled hand,
so the sticks are IRREGULAR and uneven — some thick and clumsy, some thin, all different widths,
none matching. Several pieces are short stubby chunks and broken stub fragments (not long clean
strips), some are wedge-shaped or lopsided, with a few ragged torn ends. The pile sits as a
careless messy heap with sticks pointing every which way (NOT a tidy aligned nest, NOT clean even
matchsticks). Vivid warm orange (#E8732C — the same carrot orange as a well-cut carrot, so the
ONLY thing that reads as "badly cut" is the chunky uneven irregular FORM, not the color), with the
same soft rounded volume and subtle moist cut-face sheen on each piece and tiny freshness
highlights. IMPORTANT: this must clearly read as carrot julienne that was cut WRONG — thick-and-
thin irregular sticks, broken stubby pieces, chunky and sloppy, NOT clean even strips. It is still
recognizably "당근 채" (carrot julienne), just sloppily / amateurishly cut. The messy chunky
mis-cut carrot pile itself is the standalone hero (NO cutting board, NO knife, NO bowl, NO other
ingredient).
%s""",
    },
]


def build_prompt(body: str) -> str:
    """body의 첫 %s를 STYLE_SUFFIX_HERO로 교체 (.replace로 다른 % 안전 보존)."""
    return body.replace("%s", STYLE_SUFFIX_HERO, 1)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Vertical-slice 보충 standalone HERO art 생성 (carrot_julienne_bad 등, NOT baked)"
    )
    parser.add_argument("--only", type=str, default="",
                        help="콤마구분 item id만 (예: carrot_julienne_bad)")
    parser.add_argument("--model", default="gpt-image-1", choices=["dall-e-3", "gpt-image-1"])
    parser.add_argument("--size", default="1024x1024")
    parser.add_argument("--quality", default="medium",
                        help="gpt-image-1: low/medium/high/auto")
    parser.add_argument("--background", default="transparent",
                        choices=["transparent", "opaque", "auto"],
                        help="transparent=알파 PNG (standalone production 권장) / opaque=Cream bg")
    parser.add_argument("--out-dir", type=Path,
                        default=PROJECT_ROOT / "assets-raw" / "ingredient_tool_hero_m2",
                        help="출력 폴더 (default = Godot import hero 폴더로 직접)")
    args = parser.parse_args()

    only = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    jobs = [a for a in VS_ASSETS if not only or a["id"] in only]

    if not jobs:
        sys.exit("❌ 매칭 작업 없음 (--only 확인: carrot_julienne_bad)")

    args.out_dir.mkdir(parents=True, exist_ok=True)

    unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
    if args.model == "dall-e-3":
        unit = 0.080 if args.quality == "hd" else 0.040
    else:
        unit = unit_map.get(args.quality, 0.042)
    est_total = unit * len(jobs)

    print("=" * 72)
    print("🥕 Vertical-slice 보충 standalone HERO 생성 (NOT baked)")
    print(f"   대상: {[j['id'] for j in jobs]}")
    print(f"   모델={args.model} 품질={args.quality} 사이즈={args.size} 배경={args.background}")
    print(f"   {len(jobs)}장  비용예상: ${unit:.3f}/장 × {len(jobs)} = ${est_total:.2f}")
    print(f"   출력: {args.out_dir}")
    print("=" * 72)

    client = OpenAI(api_key=load_api_key())
    successes, failures = [], []
    t0 = time.time()

    for i, asset in enumerate(jobs, 1):
        fname = f"{asset['id']}.png"
        out_path = args.out_dir / fname
        prompt = build_prompt(asset["body"])

        print(f"\n[{i}/{len(jobs)}] {asset['name']} → {fname}")
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
