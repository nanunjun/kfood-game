# Premium Food Prompts — 12 dishes (game-asset cutout, copy-paste)

> art-style-guide-v2-premium.md §5 기반. ChatGPT **gpt-image-1, quality high, 1024×1024 square**.
> **게임 자산 규칙(중요)**: 음식만 **단색 배경에 분리(isolated)** + **장면/식탁/소품 없음** + **김(steam) 없음**(김은 게임에서 steam VFX로 추가) → `strip_bg.py`(rembg)로 깨끗이 컷아웃 → `import_art_to_godot.py`로 `art/sprites/food/{food_id}.png` 교체(코드 변경 0).
> 배경 사진처럼 나오면 안 됨: 반드시 "isolated on plain background, no scene, no steam" 유지.
> **레퍼런스 LOCK (2026-06-02)**: 사용자 승인 라면샷 = 목표 퀄리티. 단색 **검정 배경**에 음식만(부피감·글로시·림라이트·재료 인지). 검정이 대비·림라이트가 잘 떠 컷아웃도 깔끔 → 검정 권장(크림도 무방, 어차피 제거).

공통 프리미엄 렌더는 유지하되 **plain 단색 배경(검정 권장) + 컷아웃**이 핵심. 권장: 승인된 라면을 레퍼런스로 나머지 11개 톤 통일.

---

## t1_002 — Ramyeon (라면)
```
premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean ramyeon — a ceramic bowl of curly springy yellow noodles in glossy spicy red broth, a soft-boiled egg half, sliced green onion.
Composition: the bowl ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no kitchen scene, no table, no utensils, no props, NO steam, only a subtle soft contact shadow directly beneath the bowl — clean silhouette for transparent cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D octane/unreal render, anime, text, watermark; NOT Japanese ramen with chashu/nori slab, NOT Chinese noodles.
```

## t1_003 — Tteokbokki (떡볶이)
```
premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean tteokbokki — plump white cylindrical rice cakes coated in thick glossy red-orange gochujang sauce with fish cake slices and green onion, in a shallow ceramic dish.
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no props, NO steam, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT spaghetti, NOT generic tomato stew.
```

## t1_004 — Kimbap (김밥)
```
premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean kimbap — black seaweed rice rolls cut into rounds showing colorful cross-section (white rice, yellow pickled radish, orange carrot, green spinach, egg, ham), neatly arranged on a small plate.
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no props, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT Japanese sushi maki or nigiri, NO wasabi, NO raw fish.
```

## t1_005 — Kimchi Fried Rice (김치볶음밥)
```
premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean kimchi fried rice — reddish stir-fried rice with chopped kimchi topped by a glossy sunny-side-up fried egg, green onion and sesame, in a ceramic bowl.
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no props, NO steam, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT plain Chinese fried rice, NOT jambalaya.
```

## t1_006 — Haemul Pajeon (해물파전)
```
premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean haemul pajeon (seafood scallion pancake) — golden crispy pan-fried pancake packed with green onions and visible shrimp and squid pieces, cut into a few wedges.
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no props, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT pizza, NOT a stack of breakfast pancakes, NOT omelette.
```

## t1_007 — Korean Corn Dog (한국식 콘도그)
```
premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean street corn dog on a wooden stick — a juicy sausage inside a crispy golden panko-crumb battered coating with sugar sprinkle, one bite taken from the top revealing the sausage cross-section and a melting mozzarella cheese stretch, zigzag of ketchup and mustard.
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no props, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT smooth American cornmeal corn dog, must show the sausage inside (not an empty cheese-only stick).
```

## t1_008 — Janchi Guksu (잔치국수)
```
premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean janchi guksu — a modest neat nest of thin white wheat noodles sitting in plenty of clear light anchovy broth (broth clearly visible, noodles NOT overflowing or filling the whole bowl), topped with a delicate garnish of julienned zucchini, egg strips, toasted seaweed and green onion, in a ceramic bowl.
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no props, NO steam, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT Japanese cold somen with pink-white band, NOT Vietnamese pho, NOT spicy red ramen, NOT a bowl overpacked/overflowing with noodles.
```

## t2_008 — Bibimbap (비빔밥)
```
premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean bibimbap — a ceramic bowl of rice topped with neatly arranged colorful sections of sauteed spinach, orange carrot strips, bean sprouts, sliced beef, and a glossy fried egg in the center. NO gochujang at all (gochujang is served separately and is NOT in this bowl).
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no props, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT a plain poke bowl, NOT a salad bowl, NO red gochujang paste in the bowl, NO separate side dish.
```

## t2_010 — Japchae (잡채)
```
premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean japchae — glossy translucent brown-amber sweet potato glass noodles stir-fried with colorful julienned vegetables (carrot, spinach, onion, shiitake) and thin beef, sprinkled with sesame, on a plate.
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no props, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT yellow Chinese lo mein or chow mein, NOT spaghetti.
```

## t2_012 — Galbi-gui (갈비구이)
```
premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean galbi-gui — grilled marinated beef short rib pieces with a glossy caramelized soy glaze, a VISIBLE WHITE RIB BONE in the meat, light char, sesame seeds and green onion, on a plate.
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no grill, no props, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, grill, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT thin boneless bulgogi, NOT long LA-cut strips on a wire mesh grill, NOT Japanese yakiniku.
```

## t2_013 — Sundubu Jjigae (순두부찌개)
```
premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean sundubu jjigae — spicy red stew in a black earthenware ttukbaegi pot, made with SILKEN UNCURDLED soft tofu in soft cloud-like broken curds and large irregular scoops (like very soft custard/pudding, NOT firm cubes), a cracked egg, green onion.
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no props, NO steam, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT Japanese miso soup, NOT Sichuan mapo tofu, NO firm/block tofu cubes, NO neat diced tofu squares.
```

## t2_014 — Bulgogi (불고기)
```
premium mobile game asset, polished casual food illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
Subject: appetizing Korean bulgogi — thin marbled beef slices glistening in a sweet-savory soy marinade glaze with sliced onion, green onion and sesame, on a plate (boneless).
Composition: ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no table, no props, only a soft contact shadow beneath — clean cutout.
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark; NOT bone-in galbi, NOT Japanese sukiyaki with raw egg, NOT bacon strips.
```

---

## 컷아웃 워크플로 (중요)
1. 위 프롬프트로 생성 → **단색 검정 배경 + 음식만** 나와야 함(장면/김 없음). 배경 장면이 섞여 나오면 follow-up: "배경 장면·식탁·소품·김 모두 제거하고 단색 검정 배경에 음식만 isolated로 다시."
2. `py tools/strip_bg.py` (rembg) → 단색 배경 깨끗이 제거 → 투명 PNG.
3. `py tools/import_art_to_godot.py` → `art/sprites/food/{food_id}.png` 교체.
4. **김/스팀은 게임에서 VFX(steam_swirl)로 이미 추가됨** → 그림에 넣지 말 것(따낼 때 지저분).
5. 톤 통일: 라면을 레퍼런스로 "같은 화풍·광원·배경·그릇 톤" 이어 요청.
- 사진처럼(photoreal) 나오면 "stylized 2D illustration, not a photo" 강조.
