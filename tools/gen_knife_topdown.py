"""
K-Food Master — TOP-DOWN (overhead) chef knife standalone HERO asset (NOT baked).

목적 (2026-06-11, art-director): Gimbap Julienne / Slice 액션은 도마를 위에서 내려다보는
top-down 시점에서 진행된다. 기존 chef_knife.png 는 3/4 hero(제품 각도, 칼날이
foreshorten 된 cleaver) 라 top-down 도마 위에 올리면 시점이 어긋난다.
→ "도마 위에 놓인 칼을 머리 위에서 내려다본" overhead plan-view 칼 1종을
STANDALONE single transparent hero 로 생성한다. gameplay/CSV/scoring 미변경 — 순수 art only.

대상 1종 (단독 transparent hero — 도마/그릇/scene/baked 0개):
  1. knife_topdown — 위에서 직각으로 내려다본 식칼:
     - blade 가 화면에서 평평하게 누워 보임 (overhead 에서 본 칼날 면 — 위 표면이 보임).
     - wooden handle 이 한쪽 끝, blade(은색 직사각에 가까운 날)가 반대쪽.
     - 3/4 hero 아님, side elevation 아님 — DIRECTLY ABOVE overhead plan view.
     - chef_knife(3/4 cleaver hero)와 명확히 구별 — 이건 top-down 도마용 칼.

핵심 시점 대비 (chef_knife → knife_topdown):
  - chef_knife = 3/4 product angle, 칼날이 비스듬히 foreshorten, 두께/입체가 hero 로 보임.
  - knife_topdown = DIRECTLY ABOVE (overhead). 칼 전체가 도마 위에 납작 누운 평면도.
    blade 의 윗면(spine→edge 폭)이 그대로 보이고, handle 도 위에서 본 윤곽. 두께는 거의
    안 보이고 그림자로만 grounded. (top-down 게임 board 와 시점 일치 — 이게 핵심.)

규칙 (Style Bible v1 §5 + ingredient-tool-art-lock.md Hero Asset Mandate):
  - STANDALONE single hero — NO cutting board / NO ingredient / NO bowl / NO hand / NO scene /
    NO other co-asset baked (suffix 가 강제).
  - STYLE_SUFFIX_HERO 재사용으로 warm/cocoa outline/soft volumetric/top-left light/palette 통일
    → chef_knife 와 같은 "세계관" 형제 자산. 단 suffix 가 LOCK 한 "3/4 slight-overhead camera"
    는 이 자산에서만 무효 — CAMERA_OVERRIDE 가 suffix 뒤에 붙어 DIRECTLY-ABOVE 로 덮어쓴다
    (suffix 의 camera 문장이 prompt 에서 가장 마지막에 나오는 override 에 의해 상쇄됨).
  - recognizable alone, no text — 보자마자 "위에서 본 식칼" 로 식별.

출력 (default = Godot import 폴더로 직접):
  assets-raw/ingredient_tool_hero_m2/knife_topdown.png

Usage:
    py tools/gen_knife_topdown.py                         # knife_topdown 1장 transparent (권장)
    py tools/gen_knife_topdown.py --quality high          # high quality ($0.167/img)
    py tools/gen_knife_topdown.py --background opaque      # Cream bg 검수용

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
# STYLE_SUFFIX_HERO 재사용 — chef_knife 와 100% 동일 톤/outline/palette/standalone 규약 강제.
from gen_ingredient_tool_hero import STYLE_SUFFIX_HERO  # noqa: E402

if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")

from openai import OpenAI  # noqa: E402


# ─────────────────────────────────────────────────────────────────────────────
# CAMERA_OVERRIDE — suffix 가 LOCK 한 "3/4 slight-overhead camera" 를 이 자산에서만 무효화.
# prompt 의 가장 마지막에 위치해 앞의 camera 지시를 덮어쓴다 (top-down 게임 board 시점 일치).
# 매우 명시적으로 DIRECTLY-ABOVE 를 반복 — 3/4 / side / hero angle 을 한 번 더 명시 배제.
# ─────────────────────────────────────────────────────────────────────────────
CAMERA_OVERRIDE = """

CAMERA OVERRIDE (this asset ONLY — ignore any earlier 3/4 instruction):
Render this knife from DIRECTLY ABOVE — a true top-down overhead plan view, as if a camera is
mounted on the ceiling looking straight down at a knife resting flat on a cutting board. The whole
knife lies FLAT in the picture plane: the broad top surface of the blade is fully visible (you see
the full width of the blade from spine to cutting edge), and the wooden handle is seen from above
at the opposite end. The blade looks like a long flat steel rectangle/leaf lying down, NOT
foreshortened, NOT tilted toward the viewer. There is almost no visible blade thickness — depth is
suggested ONLY by the soft contact shadow underneath, NOT by showing the side of the blade.
This is an overhead plan view (bird's-eye / top-down flat-lay of the knife), NOT a 3/4 product
angle, NOT a side elevation, NOT a low hero angle. The knife may sit at a relaxed diagonal within
the frame, but the viewing angle is strictly straight-down overhead."""


KNIFE_TOPDOWN = {
    "id": "knife_topdown", "name": "Chef Knife — TOP-DOWN overhead (위에서 본 식칼)",
    "body": """A HERO illustration of a single kitchen chef knife seen from DIRECTLY ABOVE
(top-down overhead view): a wide steel blade lying flat as seen from above, its broad upper face
showing a soft satin sheen and a clean tapered cutting edge along one long side and a straighter
spine along the other, narrowing to a pointed tip. A smooth warm-brown wood handle with a visible
riveted bolster sits at the opposite end, also seen from above. The flat blade catches a gentle
top-left key-light sheen across its face. This is the overhead plan view of a knife resting on a
board — NOT a 3/4 product angle, NOT a side view, NOT a hero angle. The knife itself is the
standalone hero (NO cutting board, NO ingredient, NO bowl, NO hand, NO other tool).
%s""",
}


def build_prompt(body: str) -> str:
    """body 의 첫 %s 를 STYLE_SUFFIX_HERO 로 교체 후, 끝에 CAMERA_OVERRIDE 부착.
    override 가 prompt 최후미라 suffix 의 3/4-camera LOCK 을 top-down 으로 덮어쓴다."""
    return body.replace("%s", STYLE_SUFFIX_HERO, 1) + CAMERA_OVERRIDE


def main() -> None:
    parser = argparse.ArgumentParser(
        description="TOP-DOWN overhead chef knife standalone HERO art 생성 (NOT baked, NOT 3/4)"
    )
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

    args.out_dir.mkdir(parents=True, exist_ok=True)

    unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
    if args.model == "dall-e-3":
        unit = 0.080 if args.quality == "hd" else 0.040
    else:
        unit = unit_map.get(args.quality, 0.042)

    asset = KNIFE_TOPDOWN
    fname = f"{asset['id']}.png"
    out_path = args.out_dir / fname
    prompt = build_prompt(asset["body"])

    print("=" * 72)
    print("🔪 TOP-DOWN overhead chef knife standalone HERO 생성 (NOT baked, NOT 3/4)")
    print(f"   대상: {asset['id']}")
    print(f"   모델={args.model} 품질={args.quality} 사이즈={args.size} 배경={args.background}")
    print(f"   1장  비용예상: ${unit:.3f}")
    print(f"   출력: {out_path}")
    print("=" * 72)

    client = OpenAI(api_key=load_api_key())
    t0 = time.time()

    print(f"\n[1/1] {asset['name']} → {fname}")
    try:
        generate_image(
            client=client, prompt=prompt, output_path=out_path,
            model=args.model, size=args.size, quality=args.quality,
            background=args.background,
        )
        print(f"   ⏱️  {time.time() - t0:.1f}s")
        print("\n" + "=" * 72)
        print(f"✅ 완료: 1/1 — {(time.time() - t0):.1f}s")
        print(f"   비용 예상: ${unit:.2f}")
        print(f"   경로: {out_path}")
        print("=" * 72)
    except Exception as exc:
        print(f"   ❌ FAIL ({time.time() - t0:.1f}s): {exc!r}")
        sys.exit(1)


if __name__ == "__main__":
    main()
