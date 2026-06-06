"""
K-Food Master — 8 cooking module explanatory GIF assembler.

assets-raw/_gif_frames/{module}/{module}_frame_NN.png (godot-dev 캡처)
→ assets-raw/_gif_frames/_out/{module}.gif

각 GIF = 미니게임 한 판 핵심 흐름 (~1.3s loop). 마지막 DONE frame hold.

Usage:
    py tools/make_module_gifs.py
"""

import glob
import os
import sys
from PIL import Image

if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8")

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(PROJECT_ROOT, "assets-raw", "_gif_frames")
OUT = os.path.join(SRC, "_out")
os.makedirs(OUT, exist_ok=True)

MODULES = ["slice", "arrange", "stir", "flip", "timing", "season", "roll", "plate"]

# 다운스케일 (용량 절감) — 540x960 → 360x640
TARGET_SIZE = (360, 640)
FRAME_MS = 140          # frame당 기본 duration
DONE_HOLD_MS = 650      # 마지막 DONE frame hold (loop pause)


def main() -> None:
    print("=" * 60)
    print("🎬 미니게임 GIF 조립 (8 module)")
    print("=" * 60)
    total_bytes = 0
    for m in MODULES:
        files = sorted(glob.glob(os.path.join(SRC, m, f"{m}_frame_*.png")))
        if not files:
            print(f"  ⚠️ {m}: frame 없음 — skip")
            continue
        frames = [Image.open(f).convert("RGBA").resize(TARGET_SIZE, Image.LANCZOS) for f in files]
        durations = [FRAME_MS] * len(frames)
        durations[-1] = DONE_HOLD_MS
        out_path = os.path.join(OUT, f"{m}.gif")
        frames[0].save(
            out_path,
            save_all=True,
            append_images=frames[1:],
            duration=durations,
            loop=0,
            disposal=2,
            optimize=True,
        )
        size_kb = os.path.getsize(out_path) / 1024
        total_bytes += os.path.getsize(out_path)
        print(f"  ✅ {m}.gif — {len(frames)} frames, {size_kb:.0f} KB")
    print("=" * 60)
    print(f"완료: {len(MODULES)} GIF → {OUT}  (총 {total_bytes/1024/1024:.1f} MB)")
    print("=" * 60)


if __name__ == "__main__":
    main()
