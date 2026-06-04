"""
K-Food Master — Premium v2 food anchor generation (사용자 prompt set, 2026-05-31).

사용자가 premium polished volumetric shading + Royal Match / Cooking Madness 스타일 + ISOLATED
on plain solid black studio background (for clean transparent cutout) + 12 음식 prompt 인계.

파일명: assets-raw/premium_v2/{food_id}.png (사용자 명시).
food_id: t1_002~t1_008 (7 T1), t2_008/t2_010/t2_012/t2_013/t2_014 (5 T2) = 12 음식.

Usage:
    py tools/gen_premium_v2.py
    py tools/gen_premium_v2.py --only t1_002,t2_012
    py tools/gen_premium_v2.py --model gpt-image-1 --quality medium
"""

import argparse
import sys
import time
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT / "tools"))

from gen_image import generate_image, load_api_key  # noqa: E402

if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")

from openai import OpenAI  # noqa: E402


FOODS = [
    {
        "id": "t1_002",
        "name": "라면 (Ramyeon)",
        "body": """premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean ramyeon — a ceramic bowl of curly springy yellow noodles in glossy spicy red broth, a soft-boiled egg half, sliced green onion.
Composition: the bowl ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no kitchen scene, no table, no utensils, no props, NO steam, only a subtle soft contact shadow directly beneath the bowl — clean silhouette for transparent cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D octane/unreal render, anime, text, watermark; NOT Japanese ramen with chashu/nori slab, NOT Chinese noodles.""",
    },
    {
        "id": "t1_003",
        "name": "떡볶이 (Tteokbokki)",
        "body": """premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean tteokbokki — plump white cylindrical rice cakes coated in thick glossy red-orange gochujang sauce with fish cake slices and green onion, in a shallow ceramic dish.
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no props, NO steam, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT spaghetti, NOT generic tomato stew.""",
    },
    {
        "id": "t1_004",
        "name": "김밥 (Kimbap)",
        "body": """premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean kimbap — black seaweed rice rolls cut into rounds showing colorful cross-section (white rice, yellow pickled radish, orange carrot, green spinach, egg, ham), neatly arranged on a small plate.
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no props, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT Japanese sushi maki or nigiri, NO wasabi, NO raw fish.""",
    },
    {
        "id": "t1_005",
        "name": "김치볶음밥 (Kimchi Fried Rice)",
        "body": """premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean kimchi fried rice — reddish stir-fried rice with chopped kimchi topped by a glossy sunny-side-up fried egg, green onion and sesame, in a ceramic bowl.
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no props, NO steam, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT plain Chinese fried rice, NOT jambalaya.""",
    },
    {
        "id": "t1_006",
        "name": "해물파전 (Haemul Pajeon)",
        "body": """premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean haemul pajeon (seafood scallion pancake) — golden crispy pan-fried pancake packed with green onions and visible shrimp and squid pieces, cut into a few wedges.
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no props, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT pizza, NOT a stack of breakfast pancakes, NOT omelette.""",
    },
    {
        "id": "t1_007",
        "name": "콘도그 (Korean Corn Dog)",
        "body": """premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean street corn dog on a wooden stick — a juicy sausage inside a crispy golden panko-crumb battered coating with sugar sprinkle, one bite taken from the top revealing the sausage cross-section and a melting mozzarella cheese stretch, zigzag of ketchup and mustard.
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no props, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT smooth American cornmeal corn dog, must show the sausage inside (not an empty cheese-only stick).""",
    },
    {
        "id": "t1_008",
        "name": "잔치국수 (Janchi Guksu)",
        "body": """premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean janchi guksu — a modest neat nest of thin white wheat noodles sitting in plenty of clear light anchovy broth (broth clearly visible, noodles NOT overflowing or filling the whole bowl), topped with a delicate garnish of julienned zucchini, egg strips, toasted seaweed and green onion, in a ceramic bowl.
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no props, NO steam, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT Japanese cold somen with pink-white band, NOT Vietnamese pho, NOT spicy red ramen, NOT a bowl overpacked/overflowing with noodles.""",
    },
    {
        "id": "t2_008",
        "name": "비빔밥 (Bibimbap)",
        "body": """premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean bibimbap — a ceramic bowl of rice topped with neatly arranged colorful sections of sauteed spinach, orange carrot strips, bean sprouts, sliced beef, and a glossy fried egg in the center. NO gochujang at all (gochujang is served separately and is NOT in this bowl).
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no props, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT a plain poke bowl, NOT a salad bowl, NO red gochujang paste in the bowl, NO separate side dish.""",
    },
    {
        "id": "t2_010",
        "name": "잡채 (Japchae)",
        "body": """premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean japchae — glossy translucent brown-amber sweet potato glass noodles stir-fried with colorful julienned vegetables (carrot, spinach, onion, shiitake) and thin beef, sprinkled with sesame, on a plate.
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no props, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT yellow Chinese lo mein or chow mein, NOT spaghetti.""",
    },
    {
        "id": "t2_012",
        "name": "갈비구이 (Galbi-gui)",
        "body": """premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean galbi-gui — grilled marinated beef short rib pieces with a glossy caramelized soy glaze, a VISIBLE WHITE RIB BONE in the meat, light char, sesame seeds and green onion, on a plate.
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no grill, no props, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, grill, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT thin boneless bulgogi, NOT long LA-cut strips on a wire mesh grill, NOT Japanese yakiniku.""",
    },
    {
        "id": "t2_013",
        "name": "순두부찌개 (Sundubu Jjigae)",
        "body": """premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean sundubu jjigae — spicy red stew in a black earthenware ttukbaegi pot, made with SILKEN UNCURDLED soft tofu in soft cloud-like broken curds and large irregular scoops (like very soft custard/pudding, NOT firm cubes), a cracked egg, green onion.
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no props, NO steam, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT Japanese miso soup, NOT Sichuan mapo tofu, NO firm/block tofu cubes, NO neat diced tofu squares.""",
    },
    {
        "id": "t2_014",
        "name": "불고기 (Bulgogi)",
        "body": """premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean bulgogi — thin marbled beef slices glistening in a sweet-savory soy marinade glaze with sliced onion, green onion and sesame, on a plate (boneless).
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no props, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT bone-in galbi, NOT Japanese sukiyaki with raw egg, NOT bacon strips.""",
    },
]


def main() -> None:
    parser = argparse.ArgumentParser(description="Premium v2 12 음식 generation (사용자 prompt set)")
    parser.add_argument("--only", type=str, default="", help="food_id 콤마구분 (예: t1_002,t2_012)")
    parser.add_argument("--model", default="gpt-image-1", choices=["dall-e-3", "gpt-image-1"])
    parser.add_argument("--size", default="1024x1024")
    parser.add_argument("--quality", default="medium")
    parser.add_argument(
        "--out-dir",
        type=Path,
        default=PROJECT_ROOT / "assets-raw" / "premium_v2",
    )
    args = parser.parse_args()

    only = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    selected = [f for f in FOODS if (only is None or f["id"] in only)]

    if not selected:
        sys.exit("❌ --only 매칭 없음")

    args.out_dir.mkdir(parents=True, exist_ok=True)

    unit = 0.042 if args.model == "gpt-image-1" else (0.080 if args.quality == "hd" else 0.040)
    est_total = unit * len(selected)

    print("=" * 70)
    print(f"🍽️  Premium v2 food generation (사용자 prompt set)")
    print(f"    모델: {args.model} / 품질: {args.quality} / 사이즈: {args.size}")
    print(f"    대상: {len(selected)}장 — {[f['id'] for f in selected]}")
    print(f"    비용 예상: ${unit:.3f}/장 × {len(selected)} = ${est_total:.2f}")
    print(f"    출력: {args.out_dir}")
    print("=" * 70)

    client = OpenAI(api_key=load_api_key())

    success_n = 0
    fail_n = 0
    t0 = time.time()

    for i, food in enumerate(selected, 1):
        out_path = args.out_dir / f"{food['id']}.png"
        print(f"\n[{i}/{len(selected)}] {food['id']} {food['name']} → {out_path.name}")
        t_start = time.time()
        try:
            generate_image(
                client=client,
                prompt=food["body"],
                output_path=out_path,
                model=args.model,
                size=args.size,
                quality=args.quality,
            )
            elapsed = time.time() - t_start
            print(f"    ⏱️ {elapsed:.1f}s")
            success_n += 1
        except Exception as exc:
            elapsed = time.time() - t_start
            print(f"    ❌ FAIL ({elapsed:.1f}s): {exc!r}")
            fail_n += 1

    total_elapsed = time.time() - t0
    print("\n" + "=" * 70)
    print(f"✅ 완료: {success_n}/{len(selected)} (실패 {fail_n}) — 총 {total_elapsed/60:.1f}분")
    print(f"    비용 예상: ${unit * success_n:.2f}")
    print(f"    경로: {args.out_dir}")
    print("=" * 70)


if __name__ == "__main__":
    main()
