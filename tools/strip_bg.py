"""
K-Food Master — Background removal batch tool (rembg AI).

47장 M1 anchor (food 12 + bg 5 + cut 7 + ingredient 12 + ingredient_cut 12 + reaction 6 - cut_00 base + ...)
를 transparent PNG로 변환. Original solid bg (Cool Sage 등) → transparent alpha channel.

게임 asset 표준 — Godot/Unity에서 sprite로 사용 시 transparent PNG 필요.
원본은 보존 (output suffix `_transparent.png` 또는 별도 디렉터리).

Usage:
    py tools/strip_bg.py                              # 모든 anchor 디렉터리 batch (default)
    py tools/strip_bg.py --dir assets-raw/food_anchors_m1
    py tools/strip_bg.py --file path/to/image.png
    py tools/strip_bg.py --out-dir assets-raw/transparent_m1
"""

import argparse
import sys
import time
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent

if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")

try:
    from rembg import remove, new_session
except ImportError:
    sys.exit("❌ rembg 미설치. `py -m pip install rembg` 실행 후 재시도.")


# Default: M1 anchor 디렉터리 6개
DEFAULT_DIRS = [
    "food_anchors_m1",
    "bg_anchors_m1",
    "cut_anchors_m1",
    "ingredient_anchors_m1",
    "ingredient_cut_anchors_m1",
    "reaction_anchors_m1",
]


def collect_inputs(dirs: list[str], single_file: Path | None) -> list[Path]:
    """대상 PNG 파일 수집. v2/v3/v4 등 latest version만 필터링."""
    if single_file:
        return [single_file]

    inputs: list[Path] = []
    for d in dirs:
        base = PROJECT_ROOT / "assets-raw" / d
        if not base.exists():
            print(f"⚠️  skip (not found): {base}")
            continue
        # PNG 모두 수집 (latest version 필터링은 추후 enhance)
        pngs = sorted(base.glob("*.png"))
        if pngs:
            print(f"📁 {d}: {len(pngs)} files")
            inputs.extend(pngs)
    return inputs


def process_one(session, src: Path, out_dir: Path) -> tuple[bool, int]:
    """단일 파일 처리. 반환 = (success, output bytes)."""
    out_path = out_dir / src.name
    try:
        with open(src, "rb") as f:
            input_bytes = f.read()
        result = remove(input_bytes, session=session)
        out_dir.mkdir(parents=True, exist_ok=True)
        out_path.write_bytes(result)
        return True, len(result)
    except Exception as e:
        print(f"  ❌ {src.name}: {e!r}")
        return False, 0


def main() -> None:
    parser = argparse.ArgumentParser(description="rembg AI background removal — M1 anchor batch")
    parser.add_argument(
        "--dir",
        type=str,
        action="append",
        default=None,
        help="처리할 assets-raw/ 하위 디렉터리 (반복 가능). 빈 값=default 6개 디렉터리 전체.",
    )
    parser.add_argument("--file", type=Path, help="단일 파일 처리 (--dir 무시)")
    parser.add_argument(
        "--out-dir",
        type=Path,
        default=PROJECT_ROOT / "assets-raw" / "transparent_m1",
        help="출력 root 디렉터리 (각 anchor 디렉터리 구조 보존)",
    )
    parser.add_argument(
        "--model",
        type=str,
        default="u2net",
        help="rembg model (u2net=일반/u2netp=light/isnet-general-use=detail. default=u2net)",
    )
    args = parser.parse_args()

    dirs = args.dir if args.dir else DEFAULT_DIRS

    print("=" * 70)
    print("🪄  rembg AI background removal — M1 anchor batch")
    print(f"    model: {args.model}")
    print(f"    out-dir: {args.out_dir}")
    print("=" * 70)

    inputs = collect_inputs(dirs, args.file)
    if not inputs:
        sys.exit("❌ 처리할 파일 없음.")

    print(f"\n총 {len(inputs)}장 처리 시작...\n")

    print("📦 rembg session 로드 중 (첫 실행 시 ONNX model 다운로드, ~수십 MB)...")
    session = new_session(args.model)
    print("✅ session 준비 완료\n")

    success_n = 0
    fail_n = 0
    total_bytes = 0
    t0 = time.time()

    for i, src in enumerate(inputs, 1):
        # 원 상대 경로 기준 out-dir 구조 보존
        rel = src.parent.name  # 부모 디렉터리명 (food_anchors_m1 등)
        out_subdir = args.out_dir / rel
        print(f"[{i}/{len(inputs)}] {rel}/{src.name}")
        t_start = time.time()
        ok, n_bytes = process_one(session, src, out_subdir)
        elapsed = time.time() - t_start
        if ok:
            success_n += 1
            total_bytes += n_bytes
            print(f"   ✅ {n_bytes/1024:.1f} KB | {elapsed:.1f}s")
        else:
            fail_n += 1

    total_elapsed = time.time() - t0
    print("\n" + "=" * 70)
    print(f"✅ 완료: {success_n}/{len(inputs)} (실패 {fail_n}) — 총 {total_elapsed/60:.1f}분")
    print(f"    총 {total_bytes/1024/1024:.1f} MB 출력")
    print(f"    경로: {args.out_dir}")
    print("=" * 70)


if __name__ == "__main__":
    main()
