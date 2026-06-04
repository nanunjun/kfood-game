"""
K-Food Master — 단색 배경 컷아웃 (검정/흰 자동).

rembg 없이 동작. 핵심:
  1) 코너 색으로 배경(black/white) 자동 감지 (--bg 로 강제 가능).
  2) 테두리에서 연결된 배경만 제거(flood/propagation) → 피사체 내부의
     같은 색(김밥 김, 마늘 흰색 등)은 보존.
  3) opening 으로 피사체↔배경 얇은 연결 끊기.
  4) 경계 페더 + 배경 합성 역연산(unmultiply)으로 가장자리 번짐 제거.
  5) 내용 bbox 크롭 + 여백 패딩.

Usage:
    python3 tools/cutout_bg.py --in assets-raw/premium_v2_tools --out assets-raw/premium_v2_tools_cut
    python3 tools/cutout_bg.py --in <dir> --bg white
"""
import argparse
import glob
import os
import numpy as np
from PIL import Image
from scipy import ndimage

THRESH = 14            # 배경 판정 여유 (검정: max<=T, 흰: min>=255-T)
OPEN_ITER = 2
EDGE_PAD_FRAC = 0.04


def detect_bg(rgb: np.ndarray) -> str:
    h, w = rgb.shape[:2]
    pts = [rgb[2, 2], rgb[2, w - 3], rgb[h - 3, 2], rgb[h - 3, w - 3]]
    lum = np.mean([p.mean() for p in pts])
    return "white" if lum > 160 else "black"


def cut_one(path: str, out_path: str, bg_mode: str) -> str:
    im = Image.open(path).convert("RGBA")
    arr = np.asarray(im).astype(np.float32)
    rgb = arr[..., :3]
    mode = bg_mode if bg_mode != "auto" else detect_bg(rgb)

    if mode == "black":
        bgcand = rgb.max(axis=2) <= THRESH
        white_unmul = False
    else:  # white
        bgcand = rgb.min(axis=2) >= (255 - THRESH)
        white_unmul = True

    bg_open = ndimage.binary_opening(bgcand, iterations=OPEN_ITER)
    seed = np.zeros_like(bg_open)
    seed[0, :] = seed[-1, :] = seed[:, 0] = seed[:, -1] = True
    seed &= bg_open
    bg = ndimage.binary_propagation(seed, mask=bg_open)

    fg = ndimage.binary_fill_holes(~bg)
    fg_er = ndimage.binary_erosion(fg, iterations=1)
    alpha = np.clip(ndimage.gaussian_filter(fg_er.astype(np.float32), sigma=1.0), 0.0, 1.0)

    af = np.clip(alpha, 1e-3, 1.0)[..., None]
    edge = (alpha > 0.08) & (alpha < 0.96)
    if white_unmul:
        # observed = color*cov + 255*(1-cov) → color = (observed-255*(1-cov))/cov
        corrected = np.clip((rgb - 255.0 * (1.0 - af)) / np.clip(af, 0.35, 1.0), 0.0, 255.0)
    else:
        corrected = np.minimum(255.0, rgb / np.clip(af, 0.35, 1.0))
    out_rgb = np.where(edge[..., None], corrected, rgb)

    out = np.dstack([out_rgb, alpha * 255.0]).astype(np.uint8)
    res = Image.fromarray(out, "RGBA")

    ys, xs = np.where(alpha > 0.5)
    if len(xs) and len(ys):
        x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()
        pad = int(round(max(x1 - x0, y1 - y0) * EDGE_PAD_FRAC))
        x0 = max(0, x0 - pad); y0 = max(0, y0 - pad)
        x1 = min(res.width - 1, x1 + pad); y1 = min(res.height - 1, y1 + pad)
        res = res.crop((x0, y0, x1 + 1, y1 + 1))

    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    res.save(out_path)
    return f"{os.path.basename(path)} -> {os.path.basename(out_path)}  bg={mode}  {res.size}"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="indir", required=True)
    ap.add_argument("--out", dest="outdir", required=True)
    ap.add_argument("--bg", choices=["auto", "black", "white"], default="auto")
    a = ap.parse_args()
    files = sorted(glob.glob(os.path.join(a.indir, "*.png")))
    for f in files:
        print(cut_one(f, os.path.join(a.outdir, os.path.basename(f)), a.bg))
    print(f"[cutout] {len(files)}장 완료")


if __name__ == "__main__":
    main()
