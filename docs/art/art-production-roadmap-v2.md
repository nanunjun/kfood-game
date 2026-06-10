# Art Production Roadmap v2 — Style Bible Application

> 버전: v2.0 (2026-06-06) · 작성: art-director
> 상위: [`style-bible-v1.md`](style-bible-v1.md), [`cooking-hero-screen-spec.md`](cooking-hero-screen-spec.md)
> supersedes 방향: `asset-production-list-v1.md` (Royal Match/cool-mint 가정) → Style Bible v1 cozy premium-casual 톤으로 재정렬.
> 성격: **RESKIN** — gameplay/CSV/systems 무변경, presentation 만 Style Bible 적용.
> 원칙: **CHARACTER-FIRST** (브리프: character quality > environment quantity).

---

## 0. Phase 순서 한눈에

| Phase | 이름 | 핵심 산출 | 게이트 |
|-------|------|----------|--------|
| **P0** | Style Lock | Style Bible v1 (완료) | 본 문서들 = P0 산출 |
| **P0.5** | Hero Proof | Cooking Hero Screen mockup 1장 | **Hero Screenshot Test 6+/7** (benchmark lock) |
| **P1** | Character | 7 character silhouette/color/expression + 4 emotion each | character-first 게이트 (silhouette test) |
| **P2** | Hero Screen Art | Hero mockup → 실제 분해 asset (뚝배기/게이지/버튼/손님) | Cooking Screen 실 빌드 swap |
| **P3** | Environment L1~L5 | 5 환경 BG (warm wood/depth) | L1 먼저, 순차 |
| **P4** | Food Reskin | premium_v2 12 → Style Bible 톤 통일 | cool-sage→cream, cocoa outline |
| **P5** | UI / VFX Reskin | 버튼/카드/패널/배지 + steam/sparkle/perfect | warm matte + subtle VFX |

> P0.5 Hero 가 benchmark → P1 부터 모든 asset 은 Hero 톤과 side-by-side 비교 통과해야.

---

## 1. P0.5 — Hero Proof (즉시, 1순위)

- Cooking Hero Screen mockup 1장 생성 ([`cooking-hero-screen-spec.md`](cooking-hero-screen-spec.md) §3 prompt).
- **목표**: Style Bible 시각 언어가 실제로 "같은 게임" 으로 보이는지 1장으로 증명. Hero Screenshot Test 6+/7.
- 산출: `assets-raw/hero/cooking_hero_ramen_v1.png` → LOCK 시 모든 future art benchmark.
- 작업: ~1~2h (생성 + 2~3 iteration).

---

## 2. P1 — Character (CHARACTER-FIRST, 최우선 production)

> 브리프 최우선. 7 character 가 IP. Style Bible §4 규약 (chibi storybook bust + soft 2단 shading + warm peach blush + cocoa outline).

### 2.1 순서 (silhouette → color → expression)

1. **7 base avatar bust** (silhouette+color anchor 확정) — Junho, Mina, Riley, Mrs Lee, Seoyeon, Mother, Father.
   - **silhouette test 먼저**: 7명 흑백 실루엣으로 머리모양+상의색 block 1개로 구분 가능?
   - reference-lock: Junho 1장 LOCK 후, 같은 채팅 세션 follow-up 으로 나머지 6명 "같은 outline·shading·proportion".
2. **4 emotion per guest** (bad/okay/good/excellent) — base avatar reference 고정 follow-up. (Style Bible §4.5)
   - 5 guest(Junho/Mina/Riley/Mrs Lee/Seoyeon) × 4 = 20. Mother/Father 는 기존 LOCK reaction 재사용 가능분 import + 톤 보정.

### 2.2 산출 / 작업량

| 항목 | 신규 장수 | 작업 |
|------|----------|------|
| 7 base avatar | 7 | ~4h (Junho lock 후 follow-up) |
| 5 guest × 4 emotion | 20 | ~8h |
| Mother/Father 보정 import | (기존 + 보정 6) | ~2h |
| **P1 소계** | **~27 신규** | **~14h** |

> 기존 `assets-raw/week1-anchors/` Mother/Father, `transparent_m1/reaction_anchors_m1/` 재활용 — Style Bible cocoa outline/warm blush 로 톤 보정만.

---

## 3. P2 — Hero Screen Art (실 benchmark 분해)

- Hero mockup 을 실제 Cooking Screen swappable asset 으로 분해: 뚝배기/냄비/팬, 끓는 음식 layer, steam VFX, 타이밍 게이지 UI, persimmon STOP 버튼, 손님 watching slot, warm oak countertop BG.
- godot-dev 와 협업 (procedural placeholder → TextureRect swap).
- 작업: ~6~8h (asset 분해 + 톤 일관 검증).

---

## 4. P3 — Environment L1~L5 (순차)

> Style Bible §6. warm wood / soft depth / Korean texture. **L1 먼저, 한 단계씩** (밸런스/콘텐츠 unlock 순서와 동기).

| 순서 | 환경 | 작업 | 비고 |
|------|------|------|------|
| 1 | L1 Home Kitchen | ~2h | cream + oak, 가장 먼저(초반 화면) |
| 2 | L2 Snack Shop | ~2h | 분식집 철판 톤 |
| 3 | L3 Market | ~2.5h | 재래시장 가판 + 옹기 + 천막(이탈리아 X) |
| 4 | L4 Food Alley | ~2.5h | 밤 등불 + 포장마차 |
| 5 | L5 Prestige | ~3h | walnut + brass + 한지 (격상 절정) |

> 기존 BG-01~05 (청과/정육/어물/곡물/잡화) anchor 는 L3 Market 구성요소로 재배치 가능 — Style Bible warm 톤으로 cool-sage 제거 reskin.
> **P3 소계**: ~12h.

---

## 5. P4 — Food Reskin (premium_v2 → Style Bible 톤)

> Style Bible §5. premium_v2 12장은 톤 거의 일치(떡볶이=기준작). reskin = 부분 보정.

| 작업 | 대상 | 방법 |
|------|------|------|
| 배경 통일 | 12장 | cool-sage/mint → `BG Cream #FBF3E4` 또는 투명 |
| outline 통일 | 12장 | cocoa `#3A2A1E` 3~4px |
| glossy 절제 | 과한 1~2장만 | specular 1단 낮춤 |
| 한식 그릇 보강 | 찌개류 | 뚝배기 dolsot / 놋그릇 brass 명확화 |

> 대부분 재사용 + 부분 reskin → **신규 0~2장, 보정 12장**. ~4~6h.

---

## 6. P5 — UI / VFX Reskin

> Style Bible §7·§8. warm matte premium + subtle VFX.

| 항목 | 작업 |
|------|------|
| Button/Card/Panel/Chip | warm matte fill + round corner + cocoa soft shadow (godot-dev 와 theme 협업) |
| Premium frame | gold-brass, RECORD/★ 에만 절제 |
| VFX: steam | 뚝배기/냄비 soft wisp 2~3 |
| VFX: sparkle/perfect/star burst | subtle, 화면 폭발 금지 |

> ~6~8h (UI theme + VFX sheet).

---

## 7. 총 작업량 / 비용

| Phase | 신규 PNG | 작업 시간 | 비용 (Plus plan 한도 내 ~무료) |
|-------|---------|----------|------------------------------|
| P0.5 Hero | 1 | ~1~2h | ~$0.05 |
| P1 Character | ~27 | ~14h | ~$1.1 |
| P2 Hero Art | (분해) | ~6~8h | ~$0.2 |
| P3 Environment | ~5 신규 + 5 reskin | ~12h | ~$0.4 |
| P4 Food | ~0~2 + 12 보정 | ~4~6h | ~$0.1 |
| P5 UI/VFX | ~8~12 | ~6~8h | ~$0.4 |
| **합계** | **~50 신규** | **~43~50h** | **~$2.3** |

> godot-dev 코드측 placeholder swap 별도 (~6~10h). 본 roadmap = art generation 만.

---

## 8. Hero Screenshot Test 게이트 (전 phase 공통)

각 phase 산출은 **P0.5 Hero mockup 과 side-by-side** → "같은 게임으로 보이는가" 통과해야 진행. 불일치 = reroll. (Style Bible §9.2 HT1~HT7).

- **2026-06-06 v2.0**: Style Bible v1 적용 roadmap. character-first phase 순서 (P0.5 Hero → P1 Character → P2 Hero Art → P3 Env L1~L5 → P4 Food → P5 UI/VFX). asset-production-list-v1 의 Royal Match/cool-mint 가정 → cozy premium-casual 재정렬.
