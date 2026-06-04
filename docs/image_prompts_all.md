# Image Prompts — All (통합 카탈로그)

> K-Food Master의 **모든 이미지 생성 프롬프트**를 목적별로 한 곳에 모은 마스터 인덱스. 작성 2026-06-02.
> 흩어진 출처: `docs/prompts-library.md`(레거시 v1.x M1 anchor 마스터, 3289줄), `docs/art-style-guide.md`(v1.2 글로벌), `docs/art-style-guide-v2-premium.md`(v2 글로벌), `docs/art-prompts-premium-foods.md`(현재 음식), `docs/art-prompts-premium-assets.md`(현재 도구·리액션·재료), driver scripts(`tools/gen_*_anchors_m1.py`).

## 상태 범례
- **생성됨·반영**: 이미지 생성 완료 + 게임(`art/sprites/`)에 적용됨.
- **생성됨(레거시)**: v1.x anchor가 `assets-raw/*_m1/`에 존재하나 premium v2로 superseded(또는 음식은 이미 교체됨).
- **대기**: 프롬프트는 확정, 이미지 미생성(인테이크 폴더 비어있음).
- **deprecated**: 더 이상 쓰지 않음(아카이브로 보존).
- **미사용**: 자산은 있으나 현재 게임 빌드에서 호출 안 함.

## 현재 진행 방향 (요약)
프로젝트는 **Premium v2**(라면 레퍼런스 LOCK, 반사실적·글로시·단색 배경 컷아웃)로 전 아트를 업그레이드 중.
- 음식 12: **생성됨·반영** (premium v2)
- 도구 9 / 가족 리액션 3 / 재료 whole+cut 24: **대기** (premium 프롬프트 확정, 생성 대기)
- 레거시 v1.x(flat modern casual)는 음식 외 카테고리에서 아직 in-game이지만 premium으로 교체 예정.

---

# 0. 글로벌 스타일 토큰

## 0.1 Premium v2 — 현재 활성 (출처: art-prompts-premium-foods.md / -assets.md)
**STYLE 프리픽스** (모든 premium 프롬프트 첫 줄):
```
premium mobile game asset, polished casual illustration in the style of Royal Match and Cooking Madness, soft volumetric shading with smooth gradients, single key light from top-left, subtle rim light, glossy specular highlights, rounded dimensional form, clean readable silhouette, warm appetizing palette, high production value, hand-painted stylized 2D game illustration, semi-realistic yet clearly an illustration (NOT a photograph, NOT a photo, NOT a 3D render).
```
**NEG 부정**:
```
Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark.
```
**배경 규칙(컷아웃)**: 음식·재료 = **검정 단색 배경**, 도구·캐릭터(검정 요소 많음) = **흰 단색 배경**. 김(steam)은 그림에 금지(인게임 VFX). `tools/cutout_bg.py`로 흑/백 자동 컷아웃.
**구도 블록**:
- 음식: `the dish ISOLATED and centered on a plain solid black studio background (uniform), no scene/table/props, NO steam, soft contact shadow only — clean cutout.`
- 재료: `ISOLATED and centered on a plain solid black studio background (uniform), no scene, no cutting board, no knife, no props, soft contact shadow beneath — clean cutout.`
- 도구: `the tool ISOLATED and centered on a plain solid white studio background (uniform), slight 3/4 top-down angle, no scene, empty/ready, soft contact shadow — clean cutout.`
- 리액션: `the SAME character ISOLATED and centered on a plain solid white studio background (uniform), no scene/props, soft contact shadow — clean cutout.`

## 0.2 Legacy v1.x — STYLE_SUFFIX (deprecated, 출처: prompts-library.md §2.2–2.5)
> 상태: **deprecated** (premium v2로 대체 중). 전체 verbatim은 prompts-library.md 해당 절 참조.

**STYLE_SUFFIX_FOOD** (§2.4): `square 1:1, top-down/7-8 view, Royal Match plated dish, slim bold dark outline 2-3px (#2D1D14), single color fill + 1-layer cel + ONE specular per element, saturated 80-90%, solid Cool Sage #C8D5C0 OR cream-white #FAFAFA bg, ambient ellipse shadow, white/celadon bowl no pattern. avoid: 사진/3D/일본(스시·라멘 그릇)·중국·서양식 누수, 텍스처, 캐릭터/손/주방배경.`
**STYLE_SUFFIX_CHAR** (§2.3): `square 1:1, Royal Match + Subway Surfers chibi mascot 1:1.7, dynamic pose + 1-2 motion lines, 2-3 color blocks + 1-layer cel, slim outline 2-3px, dot eyes + arc smile + light pink blush, mitten hands, 3/4 full body, soft mint #9BE0D2 bg. avoid: 베이지/Cookie Run/anime/3D/realistic/sad-crying.`
**STYLE_SUFFIX_BG** (§2.2): `wide 16:9, slight 3/4, modern Royal Match Korean market stall, 곡선 검정 기와 지붕(천막 금지), 목조 카운터 #A67049, icon-first 영어 signage(한글 금지), Cool Sage #C8D5C0 bg, slim outline 2-3px, no people. avoid: 베이지/한옥 풀세트/lantern/awning/중·일 건축/텍스처.`
**STYLE_SUFFIX_CUT** (§2.5): `square 1:1, top-down, 한식 도마(#A67049)+한식 식칼(silver #C8C8C8) 통일 silhouette, cut RESULT state, Cool Sage #C8D5C0 bg, slim outline. avoid: 일/중/서 칼, 절구, 손/액션, 사진/3D/텍스처.`
**STYLE_SUFFIX_INGREDIENT / _CUT / _REACTION / _TOOL / _MINI**: STYLE_SUFFIX_CUT/CHAR 파생 — 각 driver script(`tools/gen_*_anchors_m1.py`)가 single source of truth.

---

# 1. 음식별 (12) — 완성샷 / Stage 2A prep(재료 whole·cut) / M1 anchor

> 각 음식: **완성샷**(현재 게임에 보이는 hero), **Stage 2A prep 재료**(whole=손질 전, cut=썬 결과), **M1 anchor**(레거시 출처).
> 완성샷 premium 프롬프트 전문 = `art-prompts-premium-foods.md`(또는 위젯), 재료 premium 전문 = `art-prompts-premium-assets.md §C`. 아래는 슬롯·재료·cut스타일·출처·상태 요약.

| food_id | 음식 | 완성샷 (premium) | Stage 2A 재료(whole→cut) | cut style | M1 anchor (legacy) |
|---|---|---|---|---|---|
| t1_002 | 라면 Ramyeon | **생성됨·반영** · foods.md | 대파 green onion · **대기** · assets.md§C | CUT-05 송송 | F-01 / ING-01 / ICUT-01 · prompts-library §5.2/§5.6/§5.10 · 생성됨(레거시) |
| t1_003 | 떡볶이 Tteokbokki | **생성됨·반영** | 어묵 fish cake · **대기** | CUT-03 어슷 | F-04 / ING-04 / ICUT-04 · 생성됨(레거시) |
| t1_004 | 김밥 Kimbap | **생성됨·반영**(김 보존 재컷) | 단무지 danmuji · **대기** | CUT-04 통썰기 | F-03 / ING-03 / ICUT-03 · 생성됨(레거시) |
| t1_005 | 김치볶음밥 Kimchi Fried Rice | **생성됨·반영** | 김치 kimchi · **대기** | CUT-06 깍둑 | F-05 / ING-05 / ICUT-05 · 생성됨(레거시) |
| t1_006 | 해물파전 Haemul Pajeon | **생성됨·반영** | 쪽파 chives · **대기** | CUT-05 송송 | F-07 / ING-07 / ICUT-07 · 생성됨(레거시) |
| t1_007 | 콘도그 Korean Corn Dog | **생성됨·반영** | 소시지→반죽(DIP-00) · **대기** | DIP-00 | F-06 / ING-06 / EX-02 batter bowl · 생성됨(레거시) |
| t1_008 | 잔치국수 Janchi Guksu | **생성됨·반영** | 대파 green onion · **대기** | CUT-05 송송 | F-02(잔치국수 v1.17, 호떡 deprecated) / ING-02 소면 / ICUT-02 · 생성됨(레거시) |
| t2_008 | 비빔밥 Bibimbap | **생성됨·반영** | 당근 carrot · **대기** | CUT-02 채썰기 | F-08 / ING-08 / ICUT-08 · 생성됨(레거시) |
| t2_010 | 잡채 Japchae | **생성됨·반영** | 당근 carrot · **대기** | CUT-02 채썰기 | F-11 / ING-11 / ICUT-11 · 생성됨(레거시) |
| t2_012 | 갈비구이 Galbi-gui | **생성됨·반영** | 마늘 garlic · **대기** | CUT-01 다지기 | F-12 / ING-12 / ICUT-12 · 생성됨(레거시) |
| t2_013 | 순두부찌개 Sundubu Jjigae | **생성됨·반영**(몽글 순두부) | 애호박 zucchini · **대기** | CUT-04 통썰기 | F-10 / ING-10 / ICUT-10 · 생성됨(레거시) |
| t2_014 | 불고기 Bulgogi | **생성됨·반영** | 소고기 beef(MAR-00) · **대기** | MAR-00 양념 | F-09(불고기 v1.17, 김치찌개 deprecated) / ING-09 / ICUT-09 · 생성됨(레거시) |

### 1.1 완성샷 — Premium 전문 (현재 활성, 복사용)
> 12종 전문은 `art-prompts-premium-foods.md` 또는 위젯(premium_food_prompts_12)에 copy-paste 버튼으로 제공. 각 = `[STYLE]` + 음식 Subject + 음식 구도(검정) + `[NEG]` + 음식별 negative.
> 최근 수정: 콘도그(소시지 노출), 잔치국수(면 소량·맑은국물), 비빔밥(고추장 그릇 밖), 순두부(몽글 순두부).

### 1.2 Stage 2A 재료 — Premium 전문 (대기, 복사용)
> 24종(whole+cut) 전문은 `art-prompts-premium-assets.md §C` 또는 위젯(premium_asset_prompts…)에 제공. 각 = `[STYLE]` + 재료 Subject + 재료 구도(검정) + `[NEG]` + 재료별 negative.
> 재료 매핑: 대파(t1_002·t1_008), 어묵(t1_003), 단무지(t1_004), 김치(t1_005), 쪽파(t1_006), 소시지/반죽(t1_007), 당근(t2_008·t2_010), 마늘(t2_012), 애호박(t2_013), 소고기(t2_014).

---

# 2. 공통 조리 도구 (9, 메서드별)

| 파일 | 도구 | premium 상태 | legacy anchor |
|---|---|---|---|
| boil.png | 끓이기 냄비 | 대기 · assets.md§A | TOOL-02 냄비 · prompts-library §5.11 · 생성됨(레거시) |
| deepfry.png | 튀기기 기름솥 | 대기 | TOOL-04 깊은 튀김냄비 · 생성됨(레거시) |
| grill.png | 그릴/석쇠 | 대기 | TOOL-05 그릴 · 생성됨(레거시) |
| panfry.png | 부치기 팬 | 대기 | TOOL-03 후라이팬 · 생성됨(레거시) |
| stirfry.png | 볶기 웍 | 대기 | TOOL-03/07 · 생성됨(레거시) |
| roll.png | 말기 김발 | 대기 | TOOL-10 김발 · 생성됨(레거시) |
| mix.png | 비비기 볼 | 대기 | TOOL-11 mixing bowl · 생성됨(레거시) |
| toss.png | 무치기 볼 | 대기 | (legacy 매핑 없음) |
| marinate.png | 양념재우기 볼 | 대기 | EX-01 hand_marinade 연관 · 생성됨(레거시) |
> Premium 전문 = `art-prompts-premium-assets.md §A` / 위젯. 각 = `[STYLE]` + 도구 Subject + 도구 구도(흰) + `[NEG]`.
> 레거시 TOOL-01~12 추가분(가스레인지·국자·주걱·뒤집개·집게·가위 등)은 절차적 UI 또는 미사용 — prompts-library §5.11 참조.

---

# 3. 캐릭터 / 가족 리액션

| 파일 | 용도 | premium 상태 | legacy anchor |
|---|---|---|---|
| star1.png | 시식 리액션 1★(보통) | 대기 · assets.md§B | R-01/R-04 + CH-04/CH-05 · prompts-library §5.7 · 생성됨(레거시) |
| star2.png | 시식 리액션 2★(만족) | 대기 | R-02/R-05 · 생성됨(레거시) |
| star3.png | 시식 리액션 3★(감동) | 대기 | R-03/R-06 · 생성됨(레거시) |
| (미사용) | 주인공/양친 base | — | CH-01 주인공 / CH-02 어머니 / CH-03 아버지 / CH-04 happy / CH-05 subtle · prompts-library §3 · 생성됨(레거시), 현재 게임 미사용 |
> Premium 전문 = `art-prompts-premium-assets.md §B`. **3장 동일 캐릭터, 표정만 변화**(star1 먼저 → 레퍼런스로 star2/3). 각 = `[STYLE]` + 캐릭터+표정 Subject + 리액션 구도(흰) + `[NEG]`.
> 레거시 reaction은 어머니+아버지 6컷(R-01~06, 양친 분리). premium은 엄마 단일 3컷으로 단순화.

---

# 4. 배경 / 환경 (가게)

| anchor | 가게 | 상태 |
|---|---|---|
| BG-01 | 청과상 Produce | 생성됨(레거시) · **미사용**(현재 장보기 화면은 절차적 UI) · prompts-library §4/§4-LEGACY |
| BG-02 | 정육점 Butcher | 생성됨(레거시) · 미사용 |
| BG-03 | 어물전 Seafood | 생성됨(레거시) · 미사용 |
| BG-04 | 곡물상 Grain | 생성됨(레거시) · 미사용 |
| BG-05 | 잡화점 Pantry/Sauces | 생성됨(레거시) · 미사용 |
> 현재 빌드의 마켓/장보기 화면(stage_shop)은 코드 절차적 생성이라 배경 아트 미적용. premium 가게 배경은 미정(필요 시 신규 프롬프트 작성).

---

# 5. UI / VFX / sting

| 자산 | 상태 |
|---|---|
| UI-01~07 (tap ring, star rating, heart, coin, timer bar, settings gear, back arrow) | 생성됨(레거시) `assets-raw/ui_vfx_anchors_m1/` · 현재 UI는 코드(UITheme) 기반, 아트 부분 미사용 · prompts-library §5.8/§5.12 |
| VFX-01~05 (perfect glow ring, star burst, steam swirl, heart float, sparkle) | 생성됨(레거시) · **steam_swirl은 조리 화면에서 사용 중** · 나머지 부분 사용 |
| sting_start / sting_finish | 사운드(이미지 아님) — 합성 SFX, 게임 반영됨 |
> UI/VFX premium 업그레이드는 사용자 폴리시 순서의 #4 항목(별도). 프롬프트 미작성(대기).

---

# 6. Mini-extra (게임-디자이너 motion-spec 후속)

| anchor | 용도 | 상태 |
|---|---|---|
| EX-01 hand_marinade | 불고기 양념재우기 손바닥 press | 생성됨(레거시) `assets-raw/mini_extra_m1/` · prompts-library §5.14 |
| EX-02 corndog_batter_bowl | 콘도그 반죽 dip 그릇 | 생성됨(레거시) · 콘도그 cut(t1_007_cut) premium으로 대체 가능 |

---

# 7. 출처 파일 맵
- `docs/art-prompts-premium-foods.md` — 음식 12 완성샷 (현재 활성, 전문+복사용).
- `docs/art-prompts-premium-assets.md` — 도구 9 / 리액션 3 / 재료 24 (현재 활성, 전문+복사용).
- `docs/art-style-guide-v2-premium.md` — premium v2 글로벌 spec(렌더링 10규칙·팔레트·게이트·라면 LOCK).
- `docs/prompts-library.md` — **레거시 v1.x 마스터**(M1 anchor 전 슬롯 full body: F-01~12 §5.2 / CUT-00~06 §5.5 / ING-01~12 §5.6 / ICUT-01~12 §5.10 / CH-01~05 §3 / BG-01~05 §4 / TOOL-01~12 §5.11 / R-01~06 §5.7 / UI·VFX §5.12-13 / EX-01~02 §5.14). 전부 deprecated/superseded이나 보존.
- `docs/art-style-guide.md` — v1.2 글로벌(modern casual, deprecated).
- `tools/gen_*_anchors_m1.py` — 각 카테고리 레거시 driver(프롬프트 본문 single source).
- `tools/cutout_bg.py` — 현재 컷아웃(흑/백 자동).
- 인테이크 폴더(대기): `assets-raw/premium_v2_tools|reactions|ingredients/`.

# 8. 상태 요약
- **생성됨·반영(현재 게임)**: 음식 12(premium) + 레거시 도구/재료/리액션(in-game, 교체 예정) + steam VFX.
- **대기(premium 프롬프트 확정, 생성 전)**: 도구 9, 리액션 3, 재료 24.
- **미사용/deprecated**: 레거시 BG 5, CH 5, UI 7, 레거시 글로벌 suffix, 호떡/김치찌개 음식 anchor.
