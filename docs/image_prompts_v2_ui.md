# Image Prompts v2 — UI · 배경(BG)

> 출처: `art-needs-v2.md §5/§6`, `GDD-v2.md`. gpt-image-1, quality high. **UI = 투명/흰 배경 isolated 요소**(1024²), **BG = 풀 장면 16:9 1536×1024(컷아웃 안 함)**.
> UI 톤은 기존 UITheme(테라코타 `#E07A4E`·크림 `#FBF3E4`·소이다크 `#2D1D14`·골드 `#E0A82E`)와 정합. 글자는 가독 텍스트 회피(자리표시만).
> 공통 UI STYLE: `premium mobile casual game UI, polished glossy rounded panels, soft bevel, subtle drop shadow, terracotta + cream + gold palette, clean modern Korean homestyle, stylized 2D (NOT photo, NOT 3D).`
> 공통 NEG: `avoid readable text/letters, photorealistic photo, 3D render, harsh neon, clutter, watermark, anime.`

---

# A. UI 요소 (투명/흰 배경 isolated)

## UI-01 인벤토리 슬롯 카드 (재료 잔여 횟수) — `ui_inventory_slot.png`
```
premium mobile casual game UI, polished glossy rounded card, soft bevel, drop shadow, terracotta + cream + gold palette, Korean homestyle, stylized 2D (NOT photo, NOT 3D).
Subject: an inventory item slot card — a rounded cream panel with a circular ingredient icon area top, a small segmented "uses remaining" gauge (like 3 of 5 pips filled) bottom, a subtle price corner badge. Empty/zero state variant shown greyed out beside it.
Composition: the UI card ISOLATED on plain white background, soft shadow, no readable text (placeholder blocks only).
Important: avoid readable text/letters, photo, 3D render, harsh neon, clutter, watermark, anime.
```

## UI-02 트로피 룸 진열장 — `ui_trophy_room.png`
```
premium mobile casual game UI panel, glossy wood-and-glass display cabinet, warm gold accents, terracotta + cream palette, Korean homestyle, stylized 2D (NOT photo, NOT 3D).
Subject: a trophy-room display cabinet UI with rows of pedestal slots for collected master cooking tools and award dishware; some slots hold gleaming gold-accented items, empty slots show soft silhouettes; a central trophy plinth on top.
Composition: the cabinet panel centered on plain white background, soft shadow, no readable text.
Important: avoid readable text/letters, photo, 3D render, harsh neon, clutter, watermark, anime.
```

## UI-03 그릇 선택 그리드 (플레이팅 페이즈) — `ui_dishware_select_grid.png`
```
premium mobile casual game UI, glossy rounded selection grid, soft bevel, terracotta + cream + gold palette, stylized 2D (NOT photo, NOT 3D).
Subject: a plating-phase dishware selection grid — a row/grid of rounded tiles each framing a serving vessel icon, one tile highlighted with a gold glow (selected), a small circular countdown timer ring in the corner.
Composition: the grid UI centered on plain white background, soft shadow, no readable text.
Important: avoid readable text/letters, photo, 3D render, harsh neon, clutter, watermark, anime.
```

## UI-04 미각 힌트 카드 (친구) — `ui_taste_hint_card.png`
```
premium mobile casual game UI, glossy rounded character card, soft bevel, terracotta + cream palette, stylized 2D (NOT photo, NOT 3D).
Subject: a friend "taste hint" card — a rounded panel with a circular character portrait area top, and below, small qualitative taste icons (a chili for spicy, a sugar cube for sweet, a salt shaker, a lemon, an umami swirl) with simple fill levels indicating preference; soft cream background.
Composition: the card ISOLATED on plain white background, soft shadow, no readable text.
Important: avoid readable text/letters, photo, 3D render, harsh neon, clutter, watermark, anime.
```

## UI-05 디너 초대 화면 일러스트 — `ui_dinner_invite.png`
```
premium mobile casual game UI illustration, warm glossy, terracotta + cream + gold palette, cozy Korean homestyle, stylized 2D (NOT photo, NOT 3D).
Subject: a friendly "dinner invitation" splash illustration — a warm set Korean dining table with empty place settings for 2-4 guests, soft golden glow, an inviting envelope/bell motif, welcoming mood (no characters).
Composition: centered framed illustration on a soft vignette, no readable text, room for UI overlay.
Important: avoid readable text/letters, photo, 3D render, harsh neon, clutter, watermark, anime.
```

## UI-06 골든스푼급 게스트 등장 컷씬 — `ui_golden_spoon_entrance_cutscene.png`
```
premium mobile casual game cutscene illustration, dramatic glossy, rim-lit, gold + deep warm palette, stylized 2D (NOT photo, NOT 3D).
Subject: a dramatic "VIP gourmet arrives" cutscene frame — a grand doorway with golden light spilling, a silhouette/elegant entrance moment, sparkles and a red-carpet hint, high-stakes premium mood (no readable text, no specific face — leave center for character composite).
Composition: cinematic framed illustration, soft dramatic lighting, space for character overlay, no readable text.
Important: avoid readable text/letters, photo, 3D render, harsh neon, clutter, watermark, anime.
```

## UI-07 잠금해제 트리 노드 아이콘 세트 — `ui_unlock_node_icons.png`
```
premium mobile casual game UI icon set, glossy rounded badges, gold rims, terracotta + cream palette, stylized 2D (NOT photo, NOT 3D).
Subject: a set of unlock-tree node icons on one sheet — a menu/dish node, an ingredient node (with small tier stars), a tool node, a dishware node, a character/friend node, plus locked (padlock) and completed (checkmark) state variants; rounded medallion style with connecting line motifs.
Composition: icon set arranged on plain white background, evenly spaced, no readable text.
Important: avoid readable text/letters, photo, 3D render, harsh neon, clutter, watermark, anime.
```

## UI-08 경제 HUD (자금·보상 팝업) — `ui_economy_hud.png`
```
premium mobile casual game UI, glossy rounded HUD, gold coins motif, terracotta + cream palette, stylized 2D (NOT photo, NOT 3D).
Subject: an economy HUD set — a top money counter pill with a Korean won coin-purse motif, and a reward popup banner with a gold burst and coin icons; clean and celebratory.
Composition: HUD elements on plain white background, soft shadow, no readable text (number placeholders only).
Important: avoid readable text/letters, photo, 3D render, harsh neon, clutter, watermark, anime.
```

## UI-09 코스 진행 바 (한정식 다중 메뉴) — `ui_course_progress.png`
```
premium mobile casual game UI, glossy rounded progress bar, gold accents, terracotta + cream palette, stylized 2D (NOT photo, NOT 3D).
Subject: a multi-course progress bar — a horizontal track with 3-4 dish node markers (filled vs upcoming), each a small plate icon, current step glowing gold.
Composition: the bar ISOLATED on plain white background, soft shadow, no readable text.
Important: avoid readable text/letters, photo, 3D render, harsh neon, clutter, watermark, anime.
```

## UI-10 "한식 명인" 칭호/엔딩 배지 — `ui_master_title_badge.png`
```
premium mobile casual game UI, ornate glossy medallion, gold + deep red + cream palette, Korean traditional motif, stylized 2D (NOT photo, NOT 3D).
Subject: a prestigious "Korean Culinary Master" award medallion/badge — a golden circular emblem with a traditional Korean ribbon (norigae-inspired) and a chef/trophy motif at center, radiant, celebratory.
Composition: the badge centered on plain white background, soft glow, no readable text.
Important: avoid readable text/letters, photo, 3D render, harsh neon, clutter, watermark, anime.
```

## UI-11 다인 디너 상판 (좌석·만족 표시) — `ui_dinner_table_layout.png`
```
premium mobile casual game UI, glossy top-down table layout, warm wood + cream palette, stylized 2D (NOT photo, NOT 3D).
Subject: a top-down dinner table UI layout for 2-4 guests — rounded seat slots around a wooden table, each seat with a small satisfaction meter ring (empty placeholders), center plate area; clean game-board feel.
Composition: top-down layout centered on plain white background, soft shadow, no readable text.
Important: avoid readable text/letters, photo, 3D render, harsh neon, clutter, watermark, anime.
```

## UI-12 양념 게이지 + 양념 노트 (직관성) — `ui_seasoning_gauge.png`
```
premium mobile casual game UI, glossy rounded gauges and note icons, terracotta + cream palette, stylized 2D (NOT photo, NOT 3D).
Subject: a seasoning-input UI set — color-coded vertical fill gauges (red for chili, brown for soy, white for salt, ivory for sugar) each with a pip count, plus seasoning-pot note icons (a chili shaker, a soy bottle) shown as rhythm notes distinct from plain notes; a small "+1" pop animation hint.
Composition: UI elements on plain white background, soft shadow, no readable text (number placeholders only).
Important: avoid readable text/letters, photo, 3D render, harsh neon, clutter, watermark, anime.
```

## UI-13 다인 분할 플레이팅 그리드 (개인 양념·고명) — `ui_multi_plating_grid.png`
```
premium mobile casual game UI, glossy rounded split grid, terracotta + cream + gold palette, stylized 2D (NOT photo, NOT 3D).
Subject: a multi-guest plating grid — 2 to 4 seat panels side by side, each panel has a dishware pick slot plus three small garnish/seasoning topping buttons (extra chili / sweet / sour / aromatic icons); one guest panel highlighted.
Composition: split grid UI on plain white background, soft shadow, no readable text.
Important: avoid readable text/letters, photo, 3D render, harsh neon, clutter, watermark, anime.
```

---

# B. 배경 (BG) — 풀 장면, 16:9, 컷아웃 안 함
> premium 톤이되 **장면 배경**(캐릭터·음식은 게임에서 합성). 인물 없음. 따뜻한 모바일 캐주얼 환경.
> BG 공통: `premium mobile casual game background, warm inviting Korean setting, soft depth-of-field, cohesive cream-terracotta palette, polished 2D illustration (NOT photo, NOT 3D), no people, no readable text, wide 16:9.`

## BG-V2-01 가족 거실 (입문) — `bg_living_room.png`
```
premium mobile casual game background, warm cozy Korean family living room, low wooden table (소반/거실 테이블), soft cushions, warm afternoon light, plants, cohesive cream-terracotta palette, soft depth blur, polished 2D illustration (NOT photo, NOT 3D), no people, no readable text, wide 16:9.
```

## BG-V2-02 디너 테이블 (친구 초대) — `bg_dinner_table.png`
```
premium mobile casual game background, an inviting Korean dinner table set for guests, warm pendant light glow, neat place settings, cozy modern-traditional dining room, cream-terracotta palette, soft depth blur, polished 2D illustration (NOT photo, NOT 3D), no people, no food yet, no readable text, wide 16:9.
```

## BG-V2-03 정원/마당 (캐주얼 모임) — `bg_garden.png`
```
premium mobile casual game background, a charming Korean home garden/courtyard (마당) with a low table, lush greenery, stone path, warm sunny daytime, cohesive fresh-warm palette, soft depth blur, polished 2D illustration (NOT photo, NOT 3D), no people, no readable text, wide 16:9.
```

## BG-V2-04 옥상 (모던 모임) — `bg_rooftop.png`
```
premium mobile casual game background, a cozy Korean rooftop dining spot at golden hour, string lights, city skyline soft in the distance, small table, modern-casual mood, warm palette, soft depth blur, polished 2D illustration (NOT photo, NOT 3D), no people, no readable text, wide 16:9.
```

## BG-V2-05 고급 한정식 다이닝 (골든스푼 엔드게임) — `bg_fine_dining.png`
```
premium mobile casual game background, an elegant high-end Korean fine-dining room (한정식 다이닝), refined wood and hanji-paper accents, warm focused lighting, sophisticated calm ambiance, gold-cream palette, soft depth blur, polished 2D illustration (NOT photo, NOT 3D), no people, no readable text, wide 16:9.
```

## BG-V2-06 특산품 가게 (시장 업그레이드) — `bg_market_specialty.png`
```
premium mobile casual game background, an upgraded Korean traditional market specialty shop stall, premium produce and regional goods nicely displayed, curved black tile roof, warm inviting, cool-sage + warm wood palette, soft depth blur, polished 2D illustration (NOT photo, NOT 3D), no people, no readable text, wide 16:9.
```

## BG-V2-07 명품관 (시장 최상위) — `bg_market_luxury.png`
```
premium mobile casual game background, an upscale Korean gourmet luxury hall, elegant displays of premium branded goods (onggi jars, fine cuts) with gold accents, refined warm lighting, prestige market mood, gold-cream palette, soft depth blur, polished 2D illustration (NOT photo, NOT 3D), no people, no readable text, wide 16:9.
```

---
> 인덱스: `image_prompts_v2_all.md` · 캐릭터: `image_prompts_v2_characters.md` · 자산: `image_prompts_v2_assets.md`
