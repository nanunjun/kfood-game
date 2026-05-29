"""
K-Food Master — BG-01~05 v4 image edit (v1.2 base + 지붕만 교체, frontal view, 5가게 구조 일관성).

ADR-006 (ChatGPT/DALL-E) 기반. art-director docs/prompts-library.md v1.13
§4 BG-01~05 5장 v4 edit prompt를 그대로 inline 임베드.

v1.13 v4 image edit patch (2026-05-28): 사용자가 v1.12 v3 (5장 batch generation, slight 7/8
perspective, structurally inconsistent across 5 shops) 폐기 + verbatim
"각 가겍의 디자인이 조금씩 다름...지붕, 기둥, 이런것들은 똑같아야 하지 않나....
원래 버젼에서 지붕만 바꾸는게 어떨까...그리고 정면이 더 낫지 않나..." 명시.

main thread 해석 (3건 fix):
1. **5가게 구조적 일관성** — 지붕/기둥/카운터/frame 5가게 모두 정확히 동일. 카테고리별
   display goods + signage icon만 다름. v3는 slight 7/8 angle batch generation으로
   carpenter 작업도 5가게마다 다르게 생성되어 inconsistent.
2. **v1.2 base 정확 유지 + 지붕만 교체** — prompt-only generation은 v1.2 정확 재현 어려움.
   gpt-image-1 image edit API로 base image의 천막 부분만 교체 (다른 모든 요소 유지).
3. **정면 view (frontal elevation)** — slight 7/8 perspective 폐기. v1.2 base가 frontal이었음.

**도구**: gpt-image-1 image edit API (`client.images.edit(model="gpt-image-1", image=...)`)
prompt-only generation 대신 base image를 직접 입력으로 사용 → v1.2 base 시각 시그니처 정확 보존.

**Base image 5장**: `assets-raw/week1-anchors/BG-XX_<name>_v2.png` (Week 1 commit 7a6cffb,
v1.2 modern + icon+English i18n lock candidate). 이전 v3 batch generation 결과는 폐기.

Usage:
    py tools/edit_bg_anchors_v4.py --only BG-01     # 권장 (test 먼저)
    py tools/edit_bg_anchors_v4.py                  # 5장 batch
    py tools/edit_bg_anchors_v4.py --quality high   # 더 높은 품질 (~5x cost)

Default:
    model    = gpt-image-1 (image edit API)
    quality  = medium ($0.042/img × 5 = ~$0.21 total)
    base_dir = assets-raw/week1-anchors/
    out_dir  = assets-raw/bg_anchors_m1/
    version  = v4
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
# 공통 fix prompt — 5가게 모두 동일 (지붕 단일 교체 + 모든 다른 요소 동일 유지 + frontal view).
# ─────────────────────────────────────────────────────────────────────────────
COMMON_EDIT_PROMPT = """Replace ONLY the striped awning at the top of the shop with a curved black ceramic tile roof
in the Korean traditional hanok 기와 style. The new roof should be a SHORT SIMPLE SINGLE-LAYER
curved tile pattern (only ONE tier / ONE level, NOT double-tier, NOT two-layer, NOT multi-level,
NOT stacked), dark slate gray to black single fill, with the signature gently upward-curving eave
silhouette at the corners (Korean hanok 처마 곡선). Optional: 2-3 small white circular eave-end
tile caps (와당) along the eave tips as subtle accent.

Keep ABSOLUTELY ALL other elements of the shop IDENTICAL to the base image:
- The wooden shop frame (warm brown wood color, two vertical posts on left and right, exact same
  width and proportions)
- The wooden shop counter / display structure (exact same shape, color, signage board position)
- The signboard text and icon (exact same English text and icon)
- All displayed products in the wooden crates / counter
- All hanging items on the side
- All ground-level props (jars, etc.)
- The frontal elevation view (no perspective change)
- The Cool Sage #C8D5C0 solid background (or change background to Cool Sage if currently different)
- The slim bold dark outline (warm dark #2D1D14, 2-3px)
- The modern saturated colors (80-90% saturation, NOT muted, NOT washed out)

DO NOT add any new elements (NO additional lanterns, NO additional onggi jars beyond what's already
there, NO wooden vertical posts beyond the existing frame, NO bunting, NO deeper eaves).

DO NOT change the frontal elevation view, the shop structure, the counter, the products, the
signage text, or any other element. ONLY the awning is replaced with the tile roof.

NOT a Chinese pagoda multi-tier sharp upturned corner roof, NOT a Japanese irimoya hip-and-gable.
NOT a striped awning, NOT a tarp canopy.
NOT a double-tier roof, NOT a two-layer roof, NOT a stacked roof, NOT a multi-level roof —
the roof is a SINGLE LAYER only (one tile band)."""


# ─────────────────────────────────────────────────────────────────────────────
# Shop 별 base image + 카테고리 명시 (공통 prompt 끝에 추가).
# ─────────────────────────────────────────────────────────────────────────────
SHOPS = [
    {
        "id": "BG-01",
        "name": "greengrocer",
        "base": "BG-01_produce_v2.png",
        "category": "Korean greengrocer / produce shop (PRODUCE signage with cabbage icon)",
    },
    {
        "id": "BG-02",
        "name": "butcher",
        "base": "BG-02_butcher_v2.png",
        "category": "Korean butcher shop (BUTCHER signage with meat icon)",
    },
    {
        "id": "BG-03",
        "name": "fishmonger",
        "base": "BG-03_seafood_v2.png",
        "category": "Korean seafood shop (SEAFOOD signage with fish icon)",
    },
    {
        "id": "BG-04",
        "name": "grain_shop",
        "base": "BG-04_grain_v2.png",
        "category": "Korean grain shop (GRAIN signage with grain sack icon)",
    },
    {
        "id": "BG-05",
        "name": "sauces",
        "base": "BG-05_sundry_v2.png",
        "category": "Korean sauces/seasoning shop (SAUCES signage with bottle/jar icon)",
    },
]

BASE_DIR = PROJECT_ROOT / "assets-raw" / "week1-anchors"
OUT_DIR = PROJECT_ROOT / "assets-raw" / "bg_anchors_m1"


# ─────────────────────────────────────────────────────────────────────────────
# Base image 사이즈 검증 + (필요 시) gpt-image-1 edit API 호환 사이즈로 resize.
# gpt-image-1 image edit API supported sizes: 1024x1024, 1536x1024, 1024x1536, auto.
# ─────────────────────────────────────────────────────────────────────────────
SUPPORTED_EDIT_SIZES = {(1024, 1024), (1536, 1024), (1024, 1536)}


def inspect_base_image(base_path: Path) -> tuple[int, int]:
    """PIL로 base image 사이즈 측정. PIL 없으면 단순 헤더 파싱 fallback."""
    try:
        from PIL import Image  # noqa: WPS433

        with Image.open(base_path) as img:
            return img.size  # (width, height)
    except ImportError:
        # PIL 미설치 시 PNG IHDR 헤더 파싱
        with open(base_path, "rb") as f:
            data = f.read(24)
        if data[:8] != b"\x89PNG\r\n\x1a\n":
            return (-1, -1)
        # IHDR width @ byte 16, height @ byte 20 (big-endian)
        width = int.from_bytes(data[16:20], "big")
        height = int.from_bytes(data[20:24], "big")
        return (width, height)


def ensure_edit_compatible_size(base_path: Path) -> tuple[Path, str]:
    """base image가 gpt-image-1 edit API supported size면 그대로 사용. 아니면 가장 가까운 size로
    resize한 임시 파일을 만들어 그 경로 + size string 반환."""
    w, h = inspect_base_image(base_path)
    if (w, h) in SUPPORTED_EDIT_SIZES:
        return base_path, f"{w}x{h}"

    # 가장 가까운 supported size 선택 (aspect ratio 기준)
    if w == h:
        target = (1024, 1024)
    elif w > h:
        target = (1536, 1024)
    else:
        target = (1024, 1536)

    try:
        from PIL import Image  # noqa: WPS433
    except ImportError:
        # PIL 없으면 원본 그대로 시도 (API가 자체 처리 또는 에러)
        return base_path, "auto"

    print(f"   📐 resize {w}x{h} → {target[0]}x{target[1]} (gpt-image-1 edit supported)")
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
        raise RuntimeError("gpt-image-1 edit 응답에 이미지 데이터 없음")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_bytes(image_bytes)
    size_kb = len(image_bytes) / 1024
    print(f"   ✅ {output_path.name} ({size_kb:.1f} KB)")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="BG-01~05 v4 image edit (v1.2 base + 지붕만 교체, frontal view, 5가게 구조 일관성)"
    )
    parser.add_argument(
        "--only", type=str, default="",
        help="콤마구분 BG-ID만 (예: BG-01,BG-02). 빈 값=전체 5장.",
    )
    parser.add_argument(
        "--version", type=str, default="v4",
        help="파일명 suffix (기본 v4 → BG-01_greengrocer_v4.png)",
    )
    parser.add_argument(
        "--quality", type=str, default="medium",
        choices=["low", "medium", "high", "auto"],
        help="gpt-image-1 edit quality. low/medium/high/auto.",
    )
    parser.add_argument(
        "--out-dir", type=Path, default=OUT_DIR,
        help="출력 디렉터리 (기본: assets-raw/bg_anchors_m1/)",
    )
    args = parser.parse_args()

    only_set = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    selected = [s for s in SHOPS if (only_set is None or s["id"] in only_set)]
    if not selected:
        sys.exit(f"❌ --only 매칭 shop 없음. 유효 ID: {[s['id'] for s in SHOPS]}")

    # base image 5장 dimensions 사전 검증
    print("=" * 70)
    print("🔍 Base image dimensions 사전 검증 (assets-raw/week1-anchors/)")
    print("=" * 70)
    missing = []
    for s in selected:
        bp = BASE_DIR / s["base"]
        if not bp.exists():
            missing.append(s["base"])
            print(f"   ❌ MISSING: {bp}")
            continue
        w, h = inspect_base_image(bp)
        compat = "OK (supported)" if (w, h) in SUPPORTED_EDIT_SIZES else "→ will resize"
        print(f"   {s['id']} {s['base']}: {w}x{h} {compat}")
    if missing:
        sys.exit(f"❌ base image 누락 {len(missing)}장: {missing}. Week 1 commit 7a6cffb anchor 확인 필요.")

    # cost estimate
    unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
    unit = unit_map.get(args.quality, 0.042)
    est_total = unit * len(selected)

    print()
    print("=" * 70)
    print(f"🏯 BG v4 image edit — v1.2 base + 지붕만 교체 (frontal view, 5가게 구조 일관성)")
    print(f"   API: gpt-image-1 image edit")
    print(f"   품질: {args.quality} (${unit:.3f}/img)")
    print(f"   대상: {len(selected)}장 ({[s['id'] for s in selected]})")
    print(f"   비용 예상: ${unit:.3f} × {len(selected)} = ${est_total:.2f}")
    print(f"   출력: {args.out_dir}")
    print("=" * 70)

    api_key = load_api_key()
    client = OpenAI(api_key=api_key)

    successes: list[str] = []
    failures: list[tuple[str, str]] = []
    t0 = time.time()

    for i, shop in enumerate(selected, 1):
        bid = shop["id"]
        prompt = COMMON_EDIT_PROMPT + f"\n\nShop category: {shop['category']}."
        base = BASE_DIR / shop["base"]
        out = args.out_dir / f"{bid}_{shop['name']}_{args.version}.png"

        print(f"\n[{i}/{len(selected)}] {bid} {shop['name']} — base: {shop['base']}")
        t_start = time.time()
        try:
            edit_image(client, base, prompt, out, quality=args.quality)
            print(f"   ⏱️  {time.time() - t_start:.1f}s")
            successes.append(bid)
        except Exception as exc:
            print(f"   ❌ FAIL ({time.time() - t_start:.1f}s): {exc!r}")
            failures.append((bid, repr(exc)))

    total_elapsed = time.time() - t0
    print("\n" + "=" * 70)
    print(f"✅ 완료: {len(successes)}/{len(selected)} 장 — 총 {total_elapsed / 60:.1f}분")
    if successes:
        print(f"   성공: {', '.join(successes)}")
    if failures:
        print(f"   실패 {len(failures)}장:")
        for bid, err in failures:
            print(f"     - {bid}: {err}")
    print(f"   비용 예상: ${unit * len(successes):.2f}")
    print(f"   저장 경로: {args.out_dir}")
    print("=" * 70)


if __name__ == "__main__":
    main()
