"""
K-Food Master — 검정 단색 배경 컷아웃 (premium_v2 음식 12종).

rembg 없이 동작. 핵심:
  1) 테두리에서 연결된 검정 영역만 배경으로 판정(flood fill) → 음식 내부의
     검정(김밥 김, 순두부 뚝배기 등)은 보존.
  2) 경계 페더 + 검정 배경 합성 역연산(unmultiply)으로 가장자리 검정 번짐 제거.
  3) 내용 bounding box로 크롭 + 여백 패딩 → 중앙 정렬 스프라이트.

Usage:
    python3 tools/cutout_black_bg.py
    python3 tools/cutout_black_bg.py --in assets-raw/premium_v2 --out assets-raw/premium_v2_cut
"""
import argparse
import glob
import os
import numpy as np
from PIL import Image
from scipy import ndimage

BLACK_THRESH = 14       # max(R,G,B) 이하면 "검정 후보" (김밥 김 등 어두운 식재료 보존 위해 낮게)
OPEN_ITER = 2           # 배경 마스크 opening — 김↔배경 얇은 연결 끊기 (어두운 식재료 침식 방지)
EDGE_PAD_FRAC = 0.04    # 크롭 후 여백 비율


def cut_one(path: str, out_path: str) -> str:
    im = Image.open(path).convert("RGBA")
    arr = np.asarray(im).astype(np.float32)
    rgb = arr[..., :3]
    maxc = rgb.max(axis=2)

    # 1) 검정 후보 마스크
    black = maxc <= BLACK_THRESH

    # 2) 얇은 연결(어두운 식재료↔배경) 끊기 후, 테두리에서 전파된 검정만 배경
    #    (내부 검정 + 어두운 김/뚝배기 보존)
    black_open = ndimage.binary_opening(black, iterations=OPEN_ITER)
    seed = np.zeros_like(black_open)
    seed[0, :] = seed[-1, :] = seed[:, 0] = seed[:, -1] = True
    seed &= black_open
    bg = ndimage.binary_propagation(seed, mask=black_open)

    # 작은 구멍(배경 안의 잡티) 메우기 + 전경 매끈하게
    fg = ~bg
    fg = ndimage.binary_fill_holes(fg)
    # 1px 침식으로 검정 테두리 한 겹 제거
    fg_er = ndimage.binary_erosion(fg, iterations=1)

    # 3) 알파 페더 (부드러운 경계)
    alpha = ndimage.gaussian_filter(fg_er.astype(np.float32), sigma=1.0)
    alpha = np.clip(alpha, 0.0, 1.0)

    # 4) 검정 배경 합성 역연산: observed = color*coverage → color = observed/coverage
    af = np.clip(alpha, 1e-3, 1.0)[..., None]
    edge = (alpha > 0.08) & (alpha < 0.96)
    corrected = np.minimum(255.0, rgb / np.clip(af, 0.35, 1.0))
    out_rgb = np.where(edge[..., None], corrected, rgb)

    out = np.dstack([out_rgb, alpha * 255.0]).astype(np.uint8)
    res = Image.fromarray(out, "RGBA")

    # 5) 내용 bbox 크롭 + 패딩
    ys, xs = np.where(alpha > 0.5)
    if len(xs) and len(ys):
        x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()
        bw, bh = x1 - x0, y1 - y0
        pad = int(round(max(bw, bh) * EDGE_PAD_FRAC))
        x0 = max(0, x0 - pad); y0 = max(0, y0 - pad)
        x1 = min(res.width - 1, x1 + pad); y1 = min(res.height - 1, y1 + pad)
        res = res.crop((x0, y0, x1 + 1, y1 + 1))

    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    res.save(out_path)
    return f"{os.path.basename(path)} -> {os.path.basename(out_path)}  {res.size}"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="indir", default="assets-raw/premium_v2")
    ap.add_argument("--out", dest="outdir", default="assets-raw/premium_v2_cut")
    a = ap.parse_args()
    files = sorted(glob.glob(os.path.join(a.indir, "*.png")))
    for f in files:
        name = os.path.basename(f)
        print(cut_one(f, os.path.join(a.outdir, name)))
    print(f"[cutout] {len(files)}장 완료")


if __name__ == "__main__":
    main()
