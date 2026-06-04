# Image Prompts — Phase 1 (필요 슬롯 전체, 카피페이스트)

> Phase 1 빌드에 필요한 모든 프롬프트. gpt-image-1, quality high. 캐릭터=흰 배경 컷아웃 / 음식=검정 컷아웃 / 시장 BG=풀 16:9(컷아웃 X) / UI=흰·투명. 톤 = premium v2(Royal Match/Cooking Madness), 글로벌·세련. 브랜딩 = **황금 숟가락**(별 X).
> 공통 캐릭터 STYLE: `premium mobile game character (Royal Match / Cooking Madness), chibi mascot 1:1.8, soft volumetric shading, key light top-left, rim light, glossy highlights, warm palette, stylized 2D (NOT photo, NOT 3D).`
> 공통 NEG: `avoid background scene, flat fill, vector clipart, sticker, MS paint, amateurish, hard black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark, extra fingers, sexualized.`

## 0. 재사용 (이미 작성됨 — 재생성 불필요)
- **플레이어 5종**(Mia·Alex·Jin·Sora·Pat) 풀바디+표정+부엌포즈 → `docs/phase2_archive/image_prompts_v2_characters.md §C`.
- **메뉴 재사용 9종**(라면·김밥·떡볶이·잔치국수·비빔밥·잡채·불고기·해물파전·순두부찌개) → 이미 `art/sprites/food`에 premium 반영.
- 기본 도구 9·기본 재료·특산품 일부 → `art-prompts-premium-assets.md` / `image_prompts_v2_assets.md`.

---

# A. 친구 5 (흰 배경 컷아웃)
## F1 Mina (옆집 이웃) — 풀바디
```
premium mobile game character (Royal Match / Cooking Madness), chibi 1:1.8, soft volumetric shading, key light top-left, rim light, warm palette, stylized 2D (NOT photo, NOT 3D).
Subject: a friendly 20s next-door neighbor, casual cozy outfit, curious cheerful expression, often holding her phone, full body.
Composition: full body, isolated centered on plain solid white background, soft contact shadow.
Important: avoid background scene, flat fill, clipart, sticker, amateurish, hard black outline, neon, texture noise, photo, 3D render, anime, text, watermark.
```
## F1 Mina — 표정 3종 시트
```
[STYLE] Subject: SAME 20s neighbor Mina — three bust-ups: (1) NEUTRAL curious, (2) DELIGHTED "telling everyone!", (3) DISAPPOINTED polite "a little off". Composition: three head-and-shoulders in a row, plain white background, soft shadow. [NEG]
```
## F2 Junho (직장 동료) — 풀바디
```
premium mobile game character (Royal Match / Cooking Madness), chibi 1:1.8, soft shading, key light top-left, rim light, warm palette, stylized 2D (NOT photo, NOT 3D).
Subject: a chatty 30s coworker, dress shirt with rolled sleeves and loosened tie, animated confident gesture, full body.
Composition: full body, isolated on plain solid white background, soft contact shadow.
Important: avoid background scene, flat fill, clipart, sticker, amateurish, hard black outline, neon, texture noise, photo, 3D render, anime, text, watermark.
```
## F2 Junho — 표정 3종 시트
```
[STYLE] Subject: SAME coworker Junho — (1) NEUTRAL talkative, (2) SATISFIED fiery "that's a kick!", (3) DISAPPOINTED "too mild". three bust-ups in a row, plain white bg, soft shadow. [NEG]
```
## F3 Riley (외국인 룸메) — 풀바디
```
premium mobile game character (Royal Match / Cooking Madness), chibi 1:1.8, soft shading, key light top-left, rim light, warm palette, stylized 2D (NOT photo, NOT 3D).
Subject: a friendly 20s international roommate (non-Korean), casual streetwear, eager curious look, full body.
Composition: full body, isolated on plain solid white background, soft contact shadow.
Important: avoid background scene, flat fill, clipart, sticker, amateurish, hard black outline, neon, texture noise, photo, 3D render, anime, text, watermark.
```
## F3 Riley — 표정 3종 시트
```
[STYLE] Subject: SAME roommate Riley — (1) NEUTRAL curious, (2) SATISFIED amazed grin, (3) DISAPPOINTED "still adjusting". three bust-ups in a row, plain white bg, soft shadow. [NEG]
```
## F4 Mrs. Lee (집주인 멘토) — 풀바디
```
premium mobile game character (Royal Match / Cooking Madness), chibi 1:1.8, soft shading, key light top-left, rim light, warm palette, stylized 2D (NOT photo, NOT 3D).
Subject: a kind 60s landlady, tidy modern-traditional outfit, gentle discerning expression, holding a small side-dish container, full body.
Composition: full body, isolated on plain solid white background, soft contact shadow.
Important: avoid background scene, flat fill, clipart, sticker, amateurish, hard black outline, neon, texture noise, photo, 3D render, anime, text, watermark.
```
## F4 Mrs. Lee — 표정 3종 시트
```
[STYLE] Subject: SAME landlady Mrs. Lee — (1) NEUTRAL composed, (2) SATISFIED gentle pleased nod, (3) DISAPPOINTED "a touch strong". three bust-ups in a row, plain white bg, soft shadow. [NEG]
```
## F5 Sora (향수 친구) — 풀바디
```
premium mobile game character (Royal Match / Cooking Madness), chibi 1:1.8, soft shading, key light top-left, rim light, warm palette, stylized 2D (NOT photo, NOT 3D).
Subject: a well-traveled 30s friend, relaxed traveler style (scarf, light jacket), wistful warm expression, full body.
Composition: full body, isolated on plain solid white background, soft contact shadow.
Important: avoid background scene, flat fill, clipart, sticker, amateurish, hard black outline, neon, texture noise, photo, 3D render, anime, text, watermark.
```
## F5 Sora — 표정 3종 시트
```
[STYLE] Subject: SAME friend Sora — (1) NEUTRAL wistful, (2) SATISFIED comforted teary-happy, (3) DISAPPOINTED "missing depth". three bust-ups in a row, plain white bg, soft shadow. [NEG]
```

# B. 평가자 3
## EV1 Mystery Diner — 풀바디 + 표정 (얼굴 반쯤 가림)
```
premium mobile game character (Royal Match / Cooking Madness), chibi 1:1.8, soft shading, key light top-left, rim light, mysterious cool palette, stylized 2D (NOT photo, NOT 3D).
Subject: a mysterious anonymous diner, face half-hidden under a fedora and high coat collar, a small golden-spoon lapel pin, holding a tiny notebook, secretive calm posture, full body.
Composition: full body, isolated on plain solid white background, soft contact shadow.
Important: avoid background scene, flat fill, clipart, sticker, amateurish, hard black outline, neon, texture noise, photo, 3D render, anime, text, watermark.
```
## EV2 Food Blogger (Daniel Kim) — 풀바디
```
premium mobile game character (Royal Match / Cooking Madness), chibi 1:1.8, soft shading, key light top-left, rim light, warm palette, stylized 2D (NOT photo, NOT 3D).
Subject: a charismatic bilingual food blogger/vlogger in his late 20s, camera around neck, trendy international look, presenting to camera, full body.
Composition: full body, isolated on plain solid white background, soft contact shadow.
Important: avoid background scene, flat fill, clipart, sticker, amateurish, hard black outline, neon, texture noise, photo, 3D render, anime, text, watermark.
```
## EV3 Golden Spoon Inspector (L8 보스) — 풀바디 + 표정 3종
```
premium mobile game character (Royal Match / Cooking Madness), chibi 1:1.8, soft shading, key light top-left, rim light, refined palette, stylized 2D (NOT photo, NOT 3D).
Subject: a dignified 40s-50s Golden Spoon inspector, dark tailored suit, rimless glasses, a visible golden-spoon lapel pin, leather notebook, neutral poker face, full body.
Composition: full body, isolated on plain solid white background, soft contact shadow.
Important: avoid background scene, flat fill, clipart, sticker, amateurish, hard black outline, neon, texture noise, photo, 3D render, anime, text, watermark.
```
```
[STYLE] Subject: SAME inspector (suit, glasses, golden-spoon pin) — three bust-ups: (1) NEUTRAL impassive, (2) SATISFIED rare subtle approving smile, (3) DISAPPOINTED cold dismissive frown. three in a row, plain white bg, soft shadow. [NEG]
```

# C. 상인 2 (흰 배경)
## Mr. Jeong (동네 만물상)
```
premium mobile game character (Royal Match / Cooking Madness), chibi 1:1.8, soft shading, key light top-left, rim light, warm palette, stylized 2D (NOT photo, NOT 3D).
Subject: a warm 60s general-store uncle, work apron and sleeve covers, generous welcoming smile, gesturing, full body.
Composition: full body, isolated on plain solid white background, soft contact shadow.
Important: avoid background scene, flat fill, clipart, sticker, amateurish, hard black outline, neon, texture noise, photo, 3D render, anime, text, watermark.
```
## Captain Lee (노량진 활어)
```
premium mobile game character (Royal Match / Cooking Madness), chibi 1:1.8, soft shading, key light top-left, rim light, cool-warm palette, stylized 2D (NOT photo, NOT 3D).
Subject: a hardy 50s fish-market auctioneer, rubber apron and boots, holding a fresh flatfish, confident hearty look, full body.
Composition: full body, isolated on plain solid white background, soft contact shadow.
Important: avoid background scene, flat fill, clipart, sticker, amateurish, hard black outline, neon, texture noise, photo, 3D render, anime, text, watermark.
```

# D. 신규 메뉴 완성샷 3 (검정 컷아웃, reveal 키프레임 의도)
> reveal 연출(production-priorities §2) 대비 — steam/glow/윤기 입자가 살아나도록 묘사하되, 컷아웃 정지 이미지엔 **김 없이**(김은 인게임 VFX) 윤기·글로우 위주.
## 김치찌개 m_kimchi_jjigae
```
premium mobile game asset, polished casual food illustration (Royal Match / Cooking Madness), soft volumetric shading, key light top-left, rim light, glossy specular highlights, warm appetizing palette, golden rim-light glow, stylized 2D (NOT photo, NOT 3D).
Subject: Korean kimchi stew (kimchi-jjigae), bubbling glossy red broth with aged kimchi, pork chunks and tofu, in a dark earthenware onggi pot, appetizing sheen.
Composition: ISOLATED centered on plain solid black background, NO steam, soft contact shadow, clean cutout.
Important: avoid background scene, props, steam, flat fill, clipart, sticker, amateurish, hard black outline, neon, muddy colors, texture noise, photo, 3D render, anime, text, watermark.
```
## 된장찌개 m_doenjang_jjigae
```
premium mobile game asset, polished casual food illustration (Royal Match / Cooking Madness), soft volumetric shading, key light top-left, rim light, glossy highlights, warm palette, golden rim-light glow, stylized 2D (NOT photo, NOT 3D).
Subject: Korean soybean-paste stew (doenjang-jjigae), rustic glossy brown broth with zucchini, tofu and mushrooms, in an earthenware pot, hearty appetizing sheen.
Composition: ISOLATED centered on plain solid black background, NO steam, soft contact shadow, clean cutout.
Important: avoid background scene, props, steam, flat fill, clipart, sticker, amateurish, hard black outline, neon, muddy colors, texture noise, photo, 3D render, anime, text, watermark; not Japanese miso soup.
```
## 매운탕 m_maeuntang (노량진 해산물)
```
premium mobile game asset, polished casual food illustration (Royal Match / Cooking Madness), soft volumetric shading, key light top-left, rim light, glossy highlights, warm palette, golden rim-light glow, stylized 2D (NOT photo, NOT 3D).
Subject: Korean spicy fish stew (maeuntang), fiery glossy red broth with fish pieces, radish, tofu and crown daisy, in an earthenware pot, fresh-from-the-sea appetizing look.
Composition: ISOLATED centered on plain solid black background, NO steam, soft contact shadow, clean cutout.
Important: avoid background scene, props, steam, flat fill, clipart, sticker, amateurish, hard black outline, neon, muddy colors, texture noise, photo, 3D render, anime, text, watermark.
```

# E. 시장 BG 2 (풀 16:9, 정적 + ambient loop 전제)
## 동네 시장 — `bg_market_dongne.png`
```
premium mobile casual game background, an authentic cozy Korean neighborhood traditional market alley, red-and-white striped awnings, plastic crates of vegetables, foam boxes, red LED price tags, handwritten signs, warm afternoon light, homely lived-in feel, stylized but not glamorized, soft depth blur, polished 2D (NOT photo, NOT 3D), no people, no readable text, wide 16:9.
```
## 노량진 수산 — `bg_market_noryangjin.png`
```
premium mobile casual game background, a lively Korean fish market (Noryangjin), rows of tanks with water, ice beds with fish and shellfish, blue rubber hoses, foam boxes, wet glistening floor, fluorescent light, briny energetic mood, red price tags, stylized but not glamorized, soft depth blur, polished 2D (NOT photo, NOT 3D), no people, no readable text, wide 16:9.
```

# F. UI (Phase 1 핵심 — 손맛·플레이팅 폴리시 정합)
## 양념 게이지 + 양념 노트 — `ui_seasoning_gauge.png`
```
premium mobile casual game UI, glossy rounded gauges and note icons, terracotta + cream palette, stylized 2D (NOT photo, NOT 3D).
Subject: a seasoning-input UI set — color-coded vertical fill gauges (red chili, brown soy, white salt) each with a pip count, plus seasoning-pot note icons distinct from plain rhythm notes, a "+1" pop hint.
Composition: UI on plain white background, soft shadow, no readable text (number placeholders only).
Important: avoid readable text/letters, photo, 3D render, harsh neon, clutter, watermark, anime.
```
## 히트 피드백 키트 (Perfect/Good/Miss) — `ui_hit_feedback.png`
```
premium mobile casual game UI VFX sheet, glossy, stylized 2D (NOT photo, NOT 3D).
Subject: three rhythm-judgement feedback effects in a row — PERFECT (golden burst + central glow + sparkles), GOOD (soft warm pulse ring), MISS (grey muted ring with a small edge-shake motion hint); plus a small score-popup bubble.
Composition: effects arranged on plain white background, evenly spaced, no readable text.
Important: avoid readable text/letters, photo, 3D render, harsh neon, clutter, watermark, anime.
```
## 그릇 선택 + 매칭 보너스 — `ui_plating_select.png`
```
premium mobile casual game UI, glossy rounded carousel, terracotta + cream + gold palette, stylized 2D (NOT photo, NOT 3D).
Subject: a plating dishware carousel — rounded tiles framing serving-vessel icons, one tile lifted and glowing gold (selected), a "+15% Match!" burst badge and a small garnish-topping button; a soft chime/sparkle hint.
Composition: UI on plain white background, soft shadow, no readable text (placeholder only).
Important: avoid readable text/letters, photo, 3D render, harsh neon, clutter, watermark, anime.
```
## 음식 reveal 키프레임 (연출 레퍼런스) — `ui_food_reveal_keyframe.png`
```
premium mobile casual game key-art frame, cinematic warm, stylized 2D (NOT photo, NOT 3D).
Subject: a "food reveal" moment composition — a finished Korean dish centered with a golden rim-light glow, gentle gloss/shine particles, slight camera zoom-in and tilt framing, a celebratory one-beat pause feel (dish placeholder silhouette ok).
Composition: framed cinematic illustration, soft vignette, plain neutral background, space for dish composite, no readable text.
Important: avoid readable text/letters, photo, 3D render, harsh neon, clutter, watermark, anime.
```

# G. 컷씬 3 (풀 16:9)
## Mystery Diner 등장 (L3) — `cutscene_mystery_diner.png`
```
premium mobile casual game cutscene, soft mysterious cool palette, stylized 2D (NOT photo, NOT 3D).
Subject: the mysterious diner quietly entering and taking a seat, only a small golden spoon mark glowing softly in a notebook, air of intrigue, no readable text.
Composition: cinematic framed scene, soft vignette, plain neutral background, space for UI overlay.
Important: avoid readable text, flat fill, clipart, amateurish, hard black outline, harsh neon, texture noise, photo, 3D render, anime, watermark.
```
## Golden Spoon Inspector 보스 등장 (L8) — `cutscene_golden_spoon_boss.png`
```
premium mobile casual game cutscene, dramatic glossy, gold + deep warm palette, rim-lit, stylized 2D (NOT photo, NOT 3D).
Subject: a high-stakes arrival — a grand doorway with golden light spilling, an elegant silhouette entering, a glinting golden spoon emblem, sparkles, tense premium mood (no specific face — space for inspector composite), no readable text.
Composition: cinematic framed scene, dramatic lighting, space for character overlay, no readable text.
Important: avoid readable text, flat fill, clipart, amateurish, hard black outline, harsh neon, texture noise, photo, 3D render, anime, watermark.
```
## 엔딩 + Phase 2 예고 — `cutscene_phase1_ending.png`
```
premium mobile casual game ending illustration, warm celebratory, gold + cream palette, stylized 2D (NOT photo, NOT 3D).
Subject: a triumphant cozy ending scene — a glowing golden spoon emblem awarded above a warm Korean kitchen, a master tool and a fine dish shimmering as keepsakes, hopeful "to be continued" mood with a faint horizon of new markets, no readable text.
Composition: framed celebratory illustration, soft golden glow, plain warm background, space for "Phase 2 Coming Soon" UI overlay, no readable text.
Important: avoid readable text, flat fill, clipart, amateurish, hard black outline, harsh neon, texture noise, photo, 3D render, anime, watermark.
```

# UI ART DIRECTION (LOCKED) — menu/card target look
> 사용자 확정 아트 디렉션. 절차적 UI(`menu_select.gd` 카드·`market_bg.gd` 배경)는 이 톤의 근사치이며, 실제 배경/카드 프레임 PNG를 만들 때 이 프롬프트를 사용한다.
```
Premium casual mobile cooking game UI inspired by Royal Match, Travel Town, Cooking Madness and Animal Crossing.
Theme: Korean traditional market. Warm cozy atmosphere with red awnings, wooden stalls, cream ceramic textures and brass decorative accents.
Food cards look like premium collectible recipe cards rather than menu buttons. Large vibrant Korean food illustrations occupy 60% of each card. Guest portrait shown in corner with personality icon.
Cards have rounded corners, soft shadows, layered depth, gold rarity borders and subtle paper texture. Background shows a blurred Korean traditional market with warm lantern lighting and hanging signs.
Color palette: cream porcelain, gochujang red, jade green, warm brass gold, wood brown.
UI should feel charming, premium, collectible and culturally authentic. Not flat. Not generic restaurant simulator. Not spreadsheet-like. Not corporate. Not minimalist. AAA mobile game quality.
```
> 적용 현황(절차적): 금/은/동 등급 테두리(레벨별), 음식 전용 접시 프레임+글로우(≈60%), 코너 손님 초상 칩(입맛축 링), gochujang-red Cook 버튼, 시장 배경. **후속**: 카드 프레임/배경을 위 프롬프트로 PNG 생성 → `art/ui/`·`art/bg/` 스왑.

# H. 페이즈 전용 아트 (phase-art-v1) — 흰/투명 배경, 인게임 합성용
> 신규 4페이즈(stir-fry/pan-fry/roll/mix) 시각 차별화. 현재 코드는 도형 placeholder → 아트 들어오면 `art/phases/`에 슬롯명으로 넣고 스왑. 손맛 우선순위 보강용.
## Stir-fry — `phase_stirfry.png` (팬+주걱+재료)
```
premium mobile casual game asset (Royal Match / Cooking Madness), soft volumetric shading, key light top-left, rim light, glossy highlights, warm palette, stylized 2D (NOT photo, NOT 3D).
Subject: a top-down stylized wok/frying pan with colorful stir-fry ingredients mid-toss and a wooden spatula, a few pieces lifting in the air, glossy appetizing sheen.
Composition: ISOLATED centered on plain solid white background, soft contact shadow, clean cutout, NO steam.
Important: avoid background scene, props, steam, flat fill, clipart, sticker, amateurish, hard black outline, neon, texture noise, photo, 3D render, anime, text, watermark.
```
## Pan-fry — `phase_panfry.png` (전+기름 튀김)
```
premium mobile casual game asset (Royal Match / Cooking Madness), soft volumetric shading, key light top-left, rim light, glossy highlights, warm golden palette, stylized 2D (NOT photo, NOT 3D).
Subject: a round flat pan with a golden-brown Korean savory pancake (pajeon), a spatula flipping it, tiny oil-splatter droplets, crispy glossy edges.
Composition: ISOLATED centered on plain solid white background, soft contact shadow, clean cutout, NO steam.
Important: avoid background scene, props, steam, flat fill, clipart, sticker, amateurish, hard black outline, neon, texture noise, photo, 3D render, anime, text, watermark.
```
## Roll — `phase_roll.png` (김+밥 깔린 말기)
```
premium mobile casual game asset (Royal Match / Cooking Madness), soft volumetric shading, key light top-left, rim light, glossy highlights, fresh palette, stylized 2D (NOT photo, NOT 3D).
Subject: a bamboo rolling mat with a sheet of seaweed (gim) covered in rice and colorful fillings being rolled up, a neat half-rolled gimbap log, fresh glossy look.
Composition: ISOLATED centered on plain solid white background, soft contact shadow, clean cutout.
Important: avoid background scene, props, flat fill, clipart, sticker, amateurish, hard black outline, neon, texture noise, photo, 3D render, anime, text, watermark.
```
## Mix — `phase_mix.png` (큰 그릇+비비는 손/주걱)
```
premium mobile casual game asset (Royal Match / Cooking Madness), soft volumetric shading, key light top-left, rim light, glossy highlights, vibrant palette, stylized 2D (NOT photo, NOT 3D).
Subject: a large bowl of colorful bibimbap ingredients being mixed with a spoon, a swirl of red gochujang blending into rice and vegetables, glossy fresh sheen.
Composition: ISOLATED centered on plain solid white background, soft contact shadow, clean cutout, NO steam.
Important: avoid background scene, props, steam, flat fill, clipart, sticker, amateurish, hard black outline, neon, texture noise, photo, 3D render, anime, text, watermark.
```
## 양념 아이콘 5종 시트 — `phase_seasoning_icons.png`
```
premium mobile casual game UI icon sheet, glossy rounded, stylized 2D (NOT photo, NOT 3D).
Subject: five distinct seasoning icons in a row — (1) gochujang red chili paste in a small dish, (2) gochugaru red chili powder spilling, (3) soy sauce in a tiny pourer, (4) white sugar mound, (5) sesame oil drop with a small bottle; each glossy and instantly readable.
Composition: five icons evenly spaced on plain white background, soft shadow, no readable text.
Important: avoid readable text/letters, photo, 3D render, harsh neon, clutter, watermark, anime.
```

---
## 인테이크 폴더
- 친구·평가자·상인 → `assets-raw/premium_v2_npc/` · 플레이어 → `assets-raw/premium_v2_players/`(재사용) · 신규 메뉴 → `assets-raw/premium_v2_menus/` · 시장 BG → `assets-raw/premium_v2_markets/` · UI/컷씬 → `assets-raw/premium_v2_ui/`.
> 컷아웃: 캐릭터·메뉴는 `tools/cutout_bg.py`(흑/백 자동). 시장 BG·컷씬·UI 키프레임은 컷아웃 제외.
