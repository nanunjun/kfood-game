# Art Style Guide v2.0 — Premium Upgrade (K-Food Master)

> 버전: **v2.0 (2026-06-01, premium upgrade)** · 작성자: art-director
> 상위: `art-style-guide.md` v1.2(modern casual reset) supersede 후보, ADR-006(ChatGPT/gpt-image 생성), `art-anchor-rubric.md`, `tools/import_art_to_godot.py`
> 트리거: 사용자 "그림이 단순 만화처럼 아마추어로 보임 / 시중 모바일게임은 고급스러움". 목표 = **flat → 렌더된 프리미엄 캐주얼**.

## 1. 왜 지금이 아마추어로 보이나 (진단)
v1.2가 의도적으로 **flat single-color fill + 디테일 최소화 + slim outline**을 지시 → 결과가 "벡터 클립아트/스티커"처럼 납작하고 저렴해 보임. 시중 1군 캐주얼(Royal Match, Gardenscapes, Homescapes, Cooking Madness, Project Makeover)은 같은 "캐주얼"이어도 **부피감·광원·재질·깊이**가 있어 고급스러움. 차이는 디테일 양이 아니라 **렌더링(빛·면·재질)** 과 **일관성(전 자산 동일 광원·팔레트)**.

## 2. 새 north star (한 줄)
> **"Royal Match / Cooking Madness 급의 폴리시드 캐주얼 — 깔끔하고 읽기 쉬운 실루엣에 부피감 있는 소프트 음영·림라이트·글로시 하이라이트·접지 그림자를 입힌, 식욕 도는 한식."**
정체성: ① 둥글고 입체적인 형태(rounded volumetric) ② 단일 키라이트(좌상단) + 림라이트 ③ 음식 글로시·juicy ④ 일관 팔레트 ⑤ 부드러운 깊이(배경 blur/그라데이션). 캐주얼 가독성은 유지하되 **flat fill 금지**.

### 2.1 레퍼런스 좌표 (v2.0)
| 레퍼런스 | 차용 |
|---|---|
| **Royal Match / Gardenscapes / Homescapes (Playrix·Dream Games)** [PRIMARY] | 폴리시드 소프트 렌더, 부피감, 일관 광원, juicy 하이라이트, 깊이 있는 배경 |
| **Cooking Madness / Cooking Diary** | 식욕 도는 음식 렌더, 주방 질감, 따뜻한 톤 |
| **Project Makeover** | 깔끔한 UI·아이콘 폴리시, 카드/패널 머티리얼 |
| 회피 | flat vector clipart, sticker, MS-paint, 하이퍼캐주얼 평면, anime, 사실적 3D(octane/unreal), 베이지 scrapbook |

## 3. 렌더링 규칙 (핵심 — 전 자산 공통)
1. **광원 일관**: 단일 키라이트 **좌상단(10시 방향)**. 모든 자산 동일 → 합쳐도 한 세트로 보임.
2. **음영**: flat 1단 금지 → **소프트 2~3단 그라데이션 셰이딩**(셀+소프트 혼합). 형태의 둥근 면을 살림.
3. **림라이트**: 우하단 가장자리에 얇은 밝은 림 → 배경에서 분리·고급감.
4. **하이라이트**: 음식·금속 도구·유리에 **글로시 스페큘러 1~2점**(juicy). 채소엔 촉촉한 작은 highlight.
5. **접지 그림자(AO)**: 물체 바닥에 **소프트 타원 contact shadow** + 면 사이 옅은 ambient occlusion → 떠 보이지 않게.
6. **형태**: rounded, 약간의 두께감(2.5D). 날카로운 평면 회피.
7. **아웃라인**: 순수 검정 hard line 대신 **어두운 같은 계열 색(soy dark `#2D1D14`) 가변 두께** 또는 **외곽 소프트 다크림**. 굵고 균일한 만화 라인 회피.
8. **재질 암시**: 면=윤기, 채소=촉촉, 고기=marbling, 도자기=매끈 반사, 나무도마=은은한 결(과하지 않게). texture noise 범벅 금지.
9. **배경 깊이**: 피사체는 선명, 배경은 **소프트 블러 + 그라데이션**(피사계심도). 평면 단색 배경 탈피.
10. **팔레트 하모니**: 네온 과채도 금지. **약간 절제된 채도 + 따뜻한 K-food 베이스 + 통일된 보조색**. 자산 간 동일 팔레트 공유.

## 4. 팔레트 (v2.0 premium)
- 베이스 따뜻함: Cream `#FBF3E4`, Warm Tan `#EAD7B7`, Soy Dark(아웃라인/글자) `#2D1D14`.
- 포인트: Terracotta `#E07A4E`(버튼/CTA), Gochujang Red `#D34836`, Cabbage Green `#5FB868`, Brass Gold `#E0A82E`(별·보상).
- Cool 보조: Soft Mint `#CFE8DA`, Pastel Teal `#8FCFC6`(배경 깊이).
- 규칙: 한 자산에 베이스 1 + 포인트 1~2 + 그림자/하이라이트는 베이스의 명도 변주. 채도 75~85%(네온 회피).

## 5. 카테고리별 재생성 프롬프트 템플릿 (ChatGPT / gpt-image-1, ADR-006)
공통 접두(STYLE_PREMIUM):
```
premium mobile game art, polished casual illustration in the style of Royal Match and Cooking Madness,
soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light,
glossy specular highlights, soft ambient occlusion contact shadow, rounded dimensional forms,
clean readable silhouette, warm appetizing palette, cohesive lighting, high production value,
2D illustration (not 3D render), centered, on transparent or soft blurred background
```
공통 부정(NEG_PREMIUM):
```
Important: avoid flat single-color fill, vector clipart, sticker, MS paint, amateurish, low-effort,
hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic, 3D octane/unreal render,
anime, manga, text, watermark, extra fingers, beige scrapbook background
```

| 카테고리 | 프롬프트 본문(접두+아래+부정) |
|---|---|
| **음식 완성샷** | `appetizing finished {dish_en}, glossy juicy rendering, on a clean dish, ISOLATED centered on plain soft-cream background, no scene/table/props, NO steam(인게임 VFX), soft contact shadow only — game-asset cutout` |
| **재료(whole)** | `single fresh {ingredient_en}, premium glossy produce rendering, soft studio light, no cutting board, isolated` |
| **재료(cut)** | `neatly cut {ingredient_en} ({cut_style}) pieces grouped, fresh glossy, soft shadow, isolated, no board no knife` |
| **조리도구** | `{tool_en} (pot/pan/grill...), polished metal/ceramic material with reflections, slight 3/4 angle, isolated` |
| **캐릭터/리액션** | `chibi Korean {mother/father} character, head-heavy 1:1.8, expressive {emotion} face, soft cel+gradient shading, rim light, mascot quality (Royal Match character polish)` |
| **가게/배경** | `Korean traditional market {store} stall, warm inviting, soft depth blur, cohesive palette, premium casual game background` |
| **UI 요소** | `glossy rounded game UI {button/icon}, soft bevel, drop shadow, premium mobile casual, terracotta/cream palette` |

워크드 예시 (라면):
```
premium mobile game art, polished casual illustration in the style of Royal Match and Cooking Madness,
soft volumetric shading..., (공통 접두)
appetizing finished Korean ramyeon, hero bowl shot, glossy broth with sheen, curly yellow noodles,
soft-boiled egg, green onion, red soup, gentle steam, clean ceramic bowl, soft blurred warm kitchen bokeh background.
Important: avoid flat single-color fill, vector clipart... (공통 부정)
```

## 6. 일관성 규칙 (세트로 보이게)
- 전 자산 **동일 키라이트(좌상단)** + 동일 림라이트 방향.
- 동일 팔레트(§4) 공유, 음식별 포인트색만 교체.
- 동일 아웃라인 처리(soy-dark 소프트림), 동일 contact-shadow 스타일.
- 음식 12·재료·도구는 **같은 카메라 각(정면 살짝 3/4)** + 같은 여백/크기 규칙.

## 7. 재생성 파이프라인
1. 본 템플릿으로 ChatGPT(gpt-image-1, quality high)에서 카테고리별 재생성 — 음식 12 우선(가장 눈에 띔) → 도구 → 캐릭터/리액션 → 재료 → 가게/배경.
2. `tools/strip_bg.py`(rembg)로 투명화 → `assets-raw/transparent_*`.
3. `tools/import_art_to_godot.py`로 godot art 반입(파일명 규칙 유지 → 코드 변경 0).
4. 인게임 확인.

## 8. 수용 기준 (Premium Gate G_premium, 자산별 5요소)
- G_p1 **부피감**: flat fill 아님, 소프트 음영으로 둥근 면 보임.
- G_p2 **광원 일관**: 좌상단 키라이트 + 림라이트, 세트 내 동일.
- G_p3 **머티리얼/juicy**: 음식 글로시·식욕, 도구 재질 반사.
- G_p4 **깊이**: contact shadow + 배경 블러/그라데이션(떠 있지 않음).
- G_p5 **팔레트 하모니 + K-food 인지**: 네온 아님, 0.5초 식별 유지.
> LOCK = 카테고리 대표 1장 5/5 통과 후 batch 재생성.
> **음식 카테고리 LOCK (2026-06-02)**: 사용자 승인 **라면 레퍼런스** = G_premium 5/5 통과. 이 톤(반사실적·글로시·부피감·재료 인지, 단색 검정 배경)을 음식·재료 전 자산 기준으로 고정. 배경색 무관(컷아웃으로 제거), 검정 권장. 김(steam)은 그림에 넣지 않고 인게임 steam VFX 사용.

## 9. 코드측(이미 반영)
UITheme(버튼·배경 그라데이션·카드) v0.1 적용됨 → 아트 교체 시 UI와 톤 정합. 폰트도 추후 프리미엄 무료 폰트(예: 둥근 sans, Korean Noto/Gmarket Sans CC) 적용 검토(§후속).

## 10. 변경 이력
- 2026-06-01 v2.0 — premium 진단 + 렌더링 10규칙 + 카테고리 프롬프트 템플릿 + premium gate. (실 그림은 외부 생성 후 import)
