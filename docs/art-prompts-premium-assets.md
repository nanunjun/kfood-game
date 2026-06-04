# Premium Asset Prompts — 도구·리액션·재료 (game-asset cutout, copy-paste)

> 음식 12종(`art-prompts-premium-foods.md`)에 이어 **나머지 자산**을 동일 프리미엄 톤(라면 레퍼런스 LOCK)으로 재생성.
> ChatGPT **gpt-image-1, quality high, 1024×1024 square**.
> **게임 자산 규칙**: 피사체만 **단색 배경에 분리(isolated)** + 장면/소품 없음 → 컷아웃 → 투명 PNG.
> **배경색 주의**: 검정 요소가 많은 도구/캐릭터는 **흰 배경**, 색이 다양한 재료는 **검정 배경**. (피사체와 같은 색 배경은 금지 — 따낼 때 같이 지워짐.)
> 파이프라인: 생성 → 인테이크 폴더에 **지정 파일명**으로 저장 → `tools/cutout_bg.py`(흑/백 자동) → `art/sprites/{category}/`에 반영(코드 변경 0).

공통 프리미엄 프리픽스(STYLE) — 모든 프롬프트 첫 줄:
```
premium mobile game asset, polished casual illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
```
공통 부정(NEG):
```
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark.
```

---

# A. 조리 도구 9종 — 흰 배경
인테이크: `assets-raw/premium_v2_tools/` · 파일명 = `{method}.png` · 반영: `art/sprites/tool/`
공통 구도: `the tool ISOLATED and centered on a plain solid white studio background (uniform, for clean cutout), slight 3/4 top-down angle, no scene, no food inside (empty and ready), only a soft contact shadow beneath — clean cutout.`

## boil.png — 끓이기 냄비
```
[STYLE]
Subject: a polished stainless-steel Korean cooking pot (yangun-style) with a little clear water inside, shiny metal body with soft reflections, two side handles.
[구도 공통] [NEG]; NOT a deep fryer, NOT a frying pan.
```
## deepfry.png — 튀기기 기름솥
```
[STYLE]
Subject: a deep metal frying pot filled with golden clear hot oil, polished steel, ready for deep-frying.
[구도 공통] [NEG]; NOT a shallow pan, NOT a pot of water.
```
## grill.png — 그릴
```
[STYLE]
Subject: a round Korean barbecue grill plate with dark metal grates and a domed ridged surface, glossy seasoned cast iron.
[구도 공통] [NEG]; NOT a flat frying pan, NOT an outdoor charcoal BBQ scene.
```
## panfry.png — 부치기 팬
```
[STYLE]
Subject: a clean non-stick frying pan with a black cooking surface and a sleek handle, light sheen.
[구도 공통] [NEG]; NOT a wok, NOT a pot.
```
## stirfry.png — 볶기 웍
```
[STYLE]
Subject: a deep black stir-fry wok with a long handle, glossy well-seasoned curved surface.
[구도 공통] [NEG]; NOT a flat pan, NOT a pot of water.
```
## roll.png — 말기 김발
```
[STYLE]
Subject: a natural bamboo gimbap/sushi rolling mat (gimbal), thin wooden slats tied with string, slightly rolled at one edge.
[구도 공통] [NEG]; NOT a place mat, NOT noodles.
```
## mix.png — 비비기 볼
```
[STYLE]
Subject: a large glossy ceramic mixing bowl, empty and clean, warm cream glaze with soft interior reflection.
[구도 공통] [NEG]; NOT a plate, NOT a pot with handle.
```
## toss.png — 무치기/버무리기 볼
```
[STYLE]
Subject: a wide shallow ceramic tossing bowl with a pair of wooden chopsticks resting on the rim, glossy glaze, empty and ready.
[구도 공통] [NEG]; NOT a frying pan, NOT a deep pot.
```
## marinate.png — 양념재우기 볼
```
[STYLE]
Subject: a ceramic bowl holding glossy dark soy-based marinade sauce with a sheen, a few sesame seeds, ready for marinating.
[구도 공통] [NEG]; NOT a bowl of soup, NOT a frying pan.
```

---

# B. 가족 리액션 3종 — 흰 배경 · 동일 캐릭터 3표정
인테이크: `assets-raw/premium_v2_reactions/` · 파일명 = `star1.png` / `star2.png` / `star3.png` · 반영: `art/sprites/reaction/`
**중요**: 세 장 모두 **완전히 동일한 캐릭터**(같은 얼굴·머리·옷), 표정/포즈만 변화. star1 먼저 생성 → 그 이미지를 레퍼런스로 star2/star3 요청하면 일관성 ↑.
공통 캐릭터: `a cute chibi Korean mom mascot character, head-heavy proportions (big head ~1:1.8), warm friendly face, simple tied-back dark hair, soft apron, mascot-quality (Royal Match character polish), upper body visible.`
공통 구도: `the SAME character ISOLATED and centered on a plain solid white studio background (uniform, for clean cutout), no scene, no props, soft contact shadow beneath — clean cutout.`

## star1.png — 보통 (1★)
```
[STYLE]
Subject: [공통 캐릭터] with a mild, pleasant, slightly polite smile — a gentle "it's okay / not bad" expression, calm relaxed pose.
[구도 공통] [NEG]; keep it the same character as star2/star3, only expression changes.
```
## star2.png — 만족 (2★)
```
[STYLE]
Subject: [공통 캐릭터] with a bright happy smile, eyes lit up, one hand to her cheek — a delighted "delicious!" expression.
[구도 공통] [NEG]; keep it the SAME character as star1/star3, only expression changes.
```
## star3.png — 감동 (3★)
```
[STYLE]
Subject: [공통 캐릭터] overjoyed — big beaming smile, sparkling happy eyes, both hands raised with thumbs up — an amazed "amazing, the best!" expression.
[구도 공통] [NEG]; keep it the SAME character as star1/star2, only expression changes.
```

---

# C. 재료 whole + cut 24종 — 검정 배경
인테이크: `assets-raw/premium_v2_ingredients/` · 파일명 = `{food_id}_whole.png` / `{food_id}_cut.png` · 반영: `art/sprites/ingredient/`
공통 구도: `ISOLATED and centered on a plain solid black studio background (uniform, for clean cutout), no scene, no cutting board, no knife, no props, soft contact shadow beneath — clean cutout.`
> whole = 손질 전 재료, cut = 해당 음식 손질 스타일대로 썬 모습. (검정 재료는 거의 없어 검정 배경 OK; 김치 등 어두운 건 컷아웃 도구 opening으로 보존.)

## t1_002 — 라면: 대파 (green onion)
- `t1_002_whole.png` → `[STYLE] Subject: a few fresh long Korean green onions (daepa), crisp white stalks with vivid green tops, glossy fresh produce. [구도] [NEG]; NOT chives, NOT leeks.`
- `t1_002_cut.png` → `[STYLE] Subject: a small neat pile of finely chopped green onion rounds (thin scallion rings), fresh and glossy. [구도] [NEG]; NOT whole onions, NOT herbs.`

## t1_003 — 떡볶이: 어묵 (fish cake)
- `t1_003_whole.png` → `[STYLE] Subject: a couple of flat rectangular Korean fish cake sheets (eomuk), pale tan, slightly glossy and smooth. [구도] [NEG]; NOT tofu, NOT cheese slices.`
- `t1_003_cut.png` → `[STYLE] Subject: a small pile of diagonally sliced fish cake pieces (eomuk, thin angled slices), pale tan. [구도] [NEG]; NOT noodles, NOT meat.`

## t1_004 — 김밥: 단무지 (yellow pickled radish)
- `t1_004_whole.png` → `[STYLE] Subject: a long bright yellow Korean pickled radish (danmuji), smooth glossy cylinder. [구도] [NEG]; NOT a banana, NOT cheese.`
- `t1_004_cut.png` → `[STYLE] Subject: a small stack of bright yellow pickled radish rounds (danmuji slices), glossy. [구도] [NEG]; NOT lemon slices, NOT egg.`

## t1_005 — 김치볶음밥: 김치 (kimchi)
- `t1_005_whole.png` → `[STYLE] Subject: a portion of Korean napa cabbage kimchi, deep red-orange seasoned leaves, glossy and fresh. [구도] [NEG]; NOT lettuce, NOT plain cabbage.`
- `t1_005_cut.png` → `[STYLE] Subject: a small pile of bite-size diced kimchi pieces, deep red, glossy. [구도] [NEG]; NOT diced tomato, NOT peppers.`

## t1_006 — 해물파전: 쪽파 (chives / baby scallion)
- `t1_006_whole.png` → `[STYLE] Subject: a small bundle of thin Korean baby scallions / chives (jjokpa), slender bright green stalks. [구도] [NEG]; NOT thick leeks, NOT grass.`
- `t1_006_cut.png` → `[STYLE] Subject: a small pile of finely chopped chive rounds, fresh green. [구도] [NEG]; NOT herbs paste, NOT whole onion.`

## t1_007 — 콘도그: 소시지 → 반죽 입힘 (DIP-00, 칼질 아님)
- `t1_007_whole.png` → `[STYLE] Subject: a plain pink sausage skewered on a clean wooden stick (uncoated hot dog on a skewer). [구도] [NEG]; NOT a finished corn dog, NOT battered yet.`
- `t1_007_cut.png` → `[STYLE] Subject: a sausage on a wooden stick fully coated in a thick smooth pale beige batter, uncooked and ready to deep-fry (no golden crust yet). [구도] [NEG]; NOT a golden fried corn dog, NOT bare sausage.`

## t1_008 — 잔치국수: 대파 (green onion)
- `t1_008_whole.png` → `[STYLE] Subject: a few fresh long Korean green onions (daepa), crisp white stalks with green tops, glossy. [구도] [NEG]; NOT chives, NOT leeks.`
- `t1_008_cut.png` → `[STYLE] Subject: a small neat pile of finely chopped green onion rounds, fresh and glossy. [구도] [NEG]; NOT whole onions, NOT herbs.`

## t2_008 — 비빔밥: 당근 (carrot)
- `t2_008_whole.png` → `[STYLE] Subject: a fresh whole orange carrot with a small green stem top, glossy. [구도] [NEG]; NOT a sweet potato, NOT a pepper.`
- `t2_008_cut.png` → `[STYLE] Subject: a small pile of thin julienned carrot matchsticks, vivid orange, glossy. [구도] [NEG]; NOT shredded cheese, NOT noodles.`

## t2_010 — 잡채: 당근 (carrot)
- `t2_010_whole.png` → `[STYLE] Subject: a fresh whole orange carrot with a small green stem top, glossy. [구도] [NEG]; NOT a sweet potato, NOT a pepper.`
- `t2_010_cut.png` → `[STYLE] Subject: a small pile of thin julienned carrot matchsticks, vivid orange, glossy. [구도] [NEG]; NOT shredded cheese, NOT noodles.`

## t2_012 — 갈비구이: 마늘 (garlic)
- `t2_012_whole.png` → `[STYLE] Subject: a few peeled white garlic cloves, plump and glossy. [구도] [NEG]; NOT onions, NOT ginger.`
- `t2_012_cut.png` → `[STYLE] Subject: a small moist mound of finely minced garlic, pale cream. [구도] [NEG]; NOT rice, NOT cheese.`

## t2_013 — 순두부찌개: 애호박 (zucchini)
- `t2_013_whole.png` → `[STYLE] Subject: a fresh Korean zucchini (aehobak), pale green smooth glossy cylinder. [구도] [NEG]; NOT a cucumber, NOT a melon.`
- `t2_013_cut.png` → `[STYLE] Subject: a small stack of round pale-green zucchini slices, glossy. [구도] [NEG]; NOT cucumber rounds, NOT lime.`

## t2_014 — 불고기: 소고기 (beef, MAR-00)
- `t2_014_whole.png` → `[STYLE] Subject: a few slices of raw thin marbled beef (bulgogi cut), fresh red with white marbling, loosely heaped. [구도] [NEG]; NOT cooked meat, NOT bacon.`
- `t2_014_cut.png` → `[STYLE] Subject: thin beef slices coated in a glossy dark soy bulgogi marinade, glistening, raw and marinated (not cooked). [구도] [NEG]; NOT grilled/charred meat, NOT stew.`

---

## 컷아웃 워크플로
1. 위 프롬프트로 생성 → 지정 배경(도구·리액션=흰, 재료=검정)에 피사체만.
2. 인테이크 폴더에 지정 파일명으로 저장.
3. `python3 tools/cutout_bg.py --in <폴더> --out <폴더>_cut` (배경 흑/백 자동 감지).
4. 알려주시면 제가 `art/sprites/tool|reaction|ingredient/`에 반영 + preflight.
5. 톤 통일: 음식 라면 레퍼런스와 같은 화풍·광원 유지.
