"""
K-Food Master — Gimbap filling strip standalone HERO assets (NOT baked).

목적 (2026-06-12, art-director): 사용자 sprite 혼동 해결. 김밥(t1_004) filling이
전용 sprite 없이 대체되어 정체성이 틀림:
  - 단무지(danmuji)가 carrot_julienne(주황)로 대체 → "당근처럼 보임" (orange tone).
  - 시금치(spinach)가 green_onion(흰 bulb + 긴 파 줄기)로 대체 → "파처럼 보임".
전용 standalone hero 2종을 생성해 당근(주황)/파(흰 bulb)와 시각적으로 명확히 구별한다.

대상 2종 (단독 transparent hero — 도마/그릇/scene/baked 0개):
  1. danmuji_strip   (단무지 — 김밥용 노란 단무지 strip):
       BRIGHT YELLOW (#F5D547 계열) pickled radish strips, long rectangular gimbap filling.
       주황 절대 금지 — 당근(carrot)과 색으로 즉시 구별. clean yellow, NO orange gradient.
       살짝 반투명 윤기(단무지 질감), NOT carrot, NOT orange.
  2. spinach_cooked  (시금치 — 김밥용 무친 시금치나물 bundle):
       cooked/seasoned DARK GREEN wilted leafy spinach bundle (무친 시금치나물).
       white bulb 금지 / 파 줄기(scallion stem) 금지 / green onion look 금지 — 파와 즉시 구별.
       short wilted leafy greens 뭉치, NOT green onion.

대비 핵심 (혼동 해소):
  - danmuji  vs carrot  : danmuji = bright clean YELLOW(#F5D547), carrot = warm ORANGE(#E8732C).
       오직 색·form 으로 즉시 구별 — 주황 gradient/주황 tint 0, "당근 채"로 안 읽혀야 함.
  - spinach  vs green_onion : spinach = dark green WILTED LEAFY bundle(잎),
       green_onion = white BULB + long hollow green STEM(줄기). spinach 는 bulb/stem 0,
       오직 잎채소 뭉치 — "파"로 안 읽혀야 함.

규칙 (Style Bible v1 §5 + Hero Asset Mandate):
  - STANDALONE single hero — NO board / NO bowl / NO scene / NO other co-asset baked.
  - STYLE_SUFFIX_HERO 재사용 (carrot_julienne / green_onion 형제 자산과 100% 동일
    lighting / outline / camera / palette + standalone NO-co-asset 강제). → 같은 "세계관"의
    김밥 속재료 형제로 보이되 정체성(노랑 단무지 / 진녹 시금치)은 명확.
  - gimbap filling 형태: 긴 가로 strip(단무지) / wilted leafy bundle(시금치). single item, no text.

STYLE_SUFFIX_HERO 는 gen_ingredient_tool_hero.py 의 LOCKED suffix 를 그대로 재사용.

출력 (default = Godot import hero 폴더로 직접):
  assets-raw/ingredient_tool_hero_m2/danmuji_strip.png
  assets-raw/ingredient_tool_hero_m2/spinach_cooked.png

Usage:
    py tools/gen_gimbap_fillings_m2.py                              # 2장 transparent (권장)
    py tools/gen_gimbap_fillings_m2.py --quality high               # high quality ($0.167/img)
    py tools/gen_gimbap_fillings_m2.py --background opaque          # Cream bg 검수용
    py tools/gen_gimbap_fillings_m2.py --only danmuji_strip         # 단무지만
    py tools/gen_gimbap_fillings_m2.py --only spinach_cooked        # 시금치만

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
# STYLE_SUFFIX_HERO 재사용 — carrot_julienne / green_onion 형제와 100% 동일 톤/standalone 규약 강제.
from gen_ingredient_tool_hero import STYLE_SUFFIX_HERO  # noqa: E402

if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")

from openai import OpenAI  # noqa: E402


# ─────────────────────────────────────────────────────────────────────────────
# GIMBAP FILLINGS — 김밥 속재료 standalone hero. body 끝 %s 1개 → STYLE_SUFFIX_HERO.
# 둘 다 STANDALONE single hero (도마/그릇/scene/baked 금지 — suffix 가 강제).
# 정체성 LOCK: danmuji = bright yellow (주황 X, 당근 X) / spinach = dark green wilted
#   leafy bundle (흰 bulb X, 파 줄기 X, green onion X).
# ─────────────────────────────────────────────────────────────────────────────
GIMBAP_FILLINGS = [
    {
        "id": "danmuji_strip", "name": "단무지 strip — 김밥용 노란 단무지",
        "body": """A HERO illustration of BRIGHT YELLOW pickled radish strips for gimbap (단무지 —
yellow danmuji): several long, slender, straight rectangular sticks of pickled daikon radish lying
together as a neat little bundle of filling strips, the way danmuji is cut for kimbap. The color is a
clean BRIGHT LEMON-CANARY YELLOW (#F5D547 — sunny clear yellow), uniform and appetizing, with a
gentle translucent glossy pickled sheen along the moist cut faces (the slightly see-through wet
glistening quality of pickled radish). The strips have soft rounded edges and a believable juicy
thickness, with one or two small specular highlights catching the light.
CRITICAL COLOR + IDENTITY (this is the whole point): this MUST read as clean BRIGHT YELLOW pickled
radish — it must NOT look like carrot in any way. ABSOLUTELY NO orange, NO orange tint, NO
orange-to-yellow gradient, NO amber, NO carrot-orange (#E8732C), NO warm orange shading anywhere —
keep it a pure clean sunny yellow so it can never be mistaken for carrot. It is danmuji (단무지),
NOT carrot, NOT carrot julienne, NOT orange sticks. The bundle of yellow danmuji strips itself is
the standalone hero (NO cutting board, NO knife, NO bowl, NO rice, NO seaweed, NO other ingredient).
%s""",
    },
    {
        "id": "spinach_cooked", "name": "시금치나물 — 김밥용 무친 시금치",
        "body": """A HERO illustration of cooked seasoned spinach for gimbap (시금치나물 — sigeumchi
namul): a small soft mound / bundle of cooked, blanched and seasoned spinach — wilted dark-green
LEAFY greens, the tender cooked leaves clinging together in a glossy seasoned little heap the way
spinach namul is prepared as kimbap filling. The color is a deep rich DARK GREEN (cooked, wilted
spinach green — muted forest green, not bright raw green), with soft folds of wilted leaf, slender
limp dark-green stems among the leaves, and a light glossy sesame-oil sheen with one or two small
specular highlights.
CRITICAL IDENTITY (this is the whole point): this MUST read as a bundle of cooked LEAFY spinach
greens — it must NOT look like green onion / scallion in any way. ABSOLUTELY NO white bulb, NO white
root end, NO white-to-green gradient stem, NO long straight hollow tubular scallion stalks, NO
chopped green onion rings, NO firm upright stems — it is soft wilted leafy spinach, not a stalk
vegetable. It is seasoned cooked spinach namul (시금치나물), NOT green onion, NOT scallion, NOT
leek, NOT chives. The bundle of wilted dark-green seasoned spinach itself is the standalone hero
(NO cutting board, NO knife, NO bowl, NO rice, NO seaweed, NO other ingredient).
%s""",
    },
]


def build_prompt(body: str) -> str:
    """body의 첫 %s를 STYLE_SUFFIX_HERO로 교체 (.replace로 다른 % 안전 보존)."""
    return body.replace("%s", STYLE_SUFFIX_HERO, 1)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="김밥 filling strip standalone HERO art 생성 (danmuji_strip / spinach_cooked, NOT baked)"
    )
    parser.add_argument("--only", type=str, default="",
                        help="콤마구분 item id만 (예: danmuji_strip,spinach_cooked)")
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
    jobs = [a for a in GIMBAP_FILLINGS if not only or a["id"] in only]

    if not jobs:
        sys.exit("❌ 매칭 작업 없음 (--only 확인: danmuji_strip, spinach_cooked)")

    args.out_dir.mkdir(parents=True, exist_ok=True)

    unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
    if args.model == "dall-e-3":
        unit = 0.080 if args.quality == "hd" else 0.040
    else:
        unit = unit_map.get(args.quality, 0.042)
    est_total = unit * len(jobs)

    print("=" * 72)
    print("🍙 김밥 filling strip standalone HERO 생성 (NOT baked)")
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
