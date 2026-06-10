# Core Loop Mini-Game Framework v1 — Market-to-Plate 5-Stage Design

> 버전: **v1.0 (2026-06-09)** · 작성자: game-designer
> Status: **PROPOSAL — design only. NO code. 구현 보류 (승인 대기).**
> 사용자 mandate (verbatim): *"The experience must begin BEFORE cooking. Ingredient shopping is part of the game. Ingredient preparation is part of the game. Cooking is not just one stage. Design first. Be brutally honest. If a mini-game idea feels too childish or too easy, reject it."*
>
> 상위/관련 문서 (전부 read 후 reconcile):
> - [`cooking-mechanics.md` v0.7](../systems/cooking-mechanics.md) — 4-stage + accuracy 공식
> - [`cooking-modules-v1.md` v1.2](../systems/cooking-modules-v1.md) — 8 module ([ADR-011](../decisions.md#adr-011))
> - [`cooking-fun-redesign-v1.md` v1.0](../systems/cooking-fun-redesign-v1.md) — 3 Fixes (stakes/perfect/guest)
> - [`dish-recipe-visual-matrix-v1.md` v1](dish-recipe-visual-matrix-v1.md) — recipe correctness + banned ingredients
> - [`decisions.md`](../decisions.md) — ADR-005 (4-stage) / ADR-007 (basic_pantry) / ADR-009 (Guest 2.0) / ADR-011 (8-module) / ADR-012 (action-first) / ADR-013 (polish)
> - [`foods-database.csv`](../foods-database.csv) / [`ingredients-database.csv`](../ingredients-database.csv) / [`balance-config.md`](../balance-config.md)

---

## 0. TL;DR (먼저 솔직한 결론)

이 문서는 사용자가 요청한 **"market-to-plate 5-stage" 비전을 full design**한다. 하지만 먼저 솔직하게:

> **이 5-stage는 비전으로는 옳고, MVP scope으로는 위험하다.** 현재 게임은 이미 **4-stage(시장→prep→method→timing) + 8-module**을 가지고 있다. 사용자가 원하는 5-stage(Shopping / Preparation / Cooking / Plating / Guest)는 **기존을 버리는 게 아니라 재배열 + 2개를 게임으로 격상**하는 것이다:
> - **Shopping**: 이미 존재(Stage 1 재래시장 다점포). "선택만 하던 것"을 **mini-game으로 격상**.
> - **Preparation**: 이미 존재(Stage 2A prep + Slice/Arrange module). "한 generic step"을 **기법별 분화**.
> - **Cooking**: 이미 존재(Stir/Flip/Timing/Season). 변경 없음 — 기존 6 module 재사용.
> - **Plating**: 이미 존재(Plate module)지만 **"3지선다 tap = 거의 게임 아님"**(cooking-fun-redesign 진단 2.5/10). 격상 필요.
> - **Guest Reaction/Learning**: 이미 존재(Guest 2.0 + Result Screen 2.0 + learning-layer). 변경 없음.

**핵심 reconcile 결정**: **신규 5번째 stage를 "추가"하는 게 아니라, 기존 4-stage를 5-stage *프레이밍*으로 re-label + Cutting을 angle+rhythm으로 심화 + Plating을 게임으로 격상한다.** 신규 system 최소화. 신규 module 0건(8 module 풀 유지). 신규 stage 코드 1개(Shopping은 이미 Stage 1).

**brutal honesty 한 줄**: *Shopping과 Prep을 "새 게임"으로 풀로 만들면 MVP가 +6~10주 늘어나고 burnout 리스크([ADR-003](../decisions.md#adr-003))가 재발한다. 그래서 이 문서는 Shopping/Prep을 "이미 있는 것의 격상"으로 설계하고, 진짜 신규 작업(Cutting angle+rhythm, Plating 격상)만 비용으로 인정한다.*

---

## 1. 5-Stage Core Loop 정의

### 1.1 전체 흐름 (market-to-plate)

```
┌─ STAGE 1: SHOPPING 🏪 ──────────────────────────────────┐
│  재래시장 다점포 순회 (기존 Stage 1 격상)               │
│  올바른 재료 선택 + 틀린 재료 회피 + freshness + budget │
│  → score_shop ∈ [0,1]  (= 기존 accuracy_ingredients)    │
└─────────────────────────────────────────────────────────┘
                         ↓ 귀가
┌─ STAGE 2: PREPARATION 🔪 ───────────────────────────────┐
│  기법별 분화 (기존 Stage 2A + Slice/Arrange module 격상)│
│  Cutting(angle+rhythm) / Marinate / Wash / Arrange Raw  │
│  → score_prep ∈ [0,1]  (= 기존 accuracy_prep)           │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─ STAGE 3: COOKING 🍳 ───────────────────────────────────┐
│  dish별 signature skill (기존 Stir/Flip/Timing/Season)  │
│  → score_method + score_cook  (= 기존 method+timing)    │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─ STAGE 4: PLATING 🍽 ───────────────────────────────────┐
│  dish별 그릇 + 담기 + 고명 (기존 Plate module 격상)     │
│  → plate_bonus (display layer, cooking-fun §2.8 강화)   │
└─────────────────────────────────────────────────────────┘
                         ↓ 서빙
┌─ STAGE 5: GUEST REACTION / LEARNING 👤 ─────────────────┐
│  손님 시식 + compat + friendship + Result + flavor card │
│  (기존 Guest 2.0 + Result Screen 2.0 + learning-layer)  │
│  → ★ 등급 + 코인 + Recipe XP + 학습 카드                │
└─────────────────────────────────────────────────────────┘
```

### 1.2 4-stage → 5-stage 매핑 (reconcile 핵심 표)

| 신규 5-stage | 기존 자산 | 변경 |
|---|---|---|
| **1 Shopping** | cooking-mechanics §2 Stage 1 재래시장 다점포 | **격상** (freshness/budget mini-layer 추가) |
| **2 Preparation** | Stage 2A prep + Slice(10/12)·Arrange(4/12) module | **분화** (Cutting angle+rhythm 심화 + Marinate/Wash/Arrange Raw) |
| **3 Cooking** | Stage 2B method + Stage 2C timing + Stir/Flip/Timing/Season module | **무변경** (재사용) |
| **4 Plating** | Plate module | **격상** (cooking-fun §2.8 drag+garnish) |
| **5 Guest/Learning** | Guest 2.0 + Result Screen 2.0 + learning-layer | **무변경** (재사용) |

> **결론**: 5-stage는 4-stage의 *재프레이밍*이다. 시장(1)·키친 내 prep(2)·키친 내 cook(3)·plating(4)·식탁(5). [ADR-005](../decisions.md#adr-005)의 3-scene(시장/키친/식탁)은 유지된다 — Plating은 키친→식탁 transition 안의 sub-step.

### 1.3 점수 정합 — 신규 system 0건 (4-factor 그대로)

5-stage가 기존 4-factor 가중 평균([ADR-005](../decisions.md#adr-005), balance-config)에 **그대로** 매핑된다. **신규 점수 축 없음**:

```
total = (score_shop × 0.25)   ← Stage 1 Shopping  (= 기존 재료 25%)
      + (score_prep × 0.20)   ← Stage 2 Prep      (= 기존 준비 20%)
      + (score_method × 0.20) ← Stage 3 Cooking-method (= 기존 방법 20%)
      + (score_cook × 0.35)   ← Stage 3 Cooking-timing  (= 기존 시간 35%)

plate_bonus → display layer (Result Screen 2.0 row, ★ 임계 무영향 — cooking-modules §1.8 정합)
compat / mood / friendship → 코인 보상 layer only (ADR-009 정합, ★ 무영향)
★1 ≥ 30%, ★2 ≥ 60%, ★3 ≥ 90%
```

> **신규 system 최소화 권고 준수**: Plating은 점수 축이 아니라 display bonus(기존 Plate module과 동일). Guest/Learning은 ★ 무영향(기존 정책). 신규 4-factor 축 0건. 이것이 사용자 제약 "신규 system 최소화(기존 4-factor/Guest 2.0 재활용)"의 핵심.

---

## 2. STAGE 1 — Shopping Mini-Game 디자인

### 2.1 Core fantasy
"**좋은 재료를 빠르고 정확하게 고른다.** 정답을 찾고, 함정을 피하고, 신선한 걸 집고, 예산 안에서." — e-commerce 쇼핑이 아니라 **재래시장에서 장 보는 정서**.

### 2.2 기존 자산 + 신규 layer
- **기존 (무변경)**: 재래시장 다점포 5가게(청과/정육/어물/곡물/잡화), 가게 순회, 공통 타이머, distractor, accuracy 공식(cooking-mechanics §2).
- **신규 mini-layer 3종 (격상)**:

| layer | 메커닉 | success | failure | Lv 게이팅 |
|---|---|---|---|---|
| **Freshness compare** | 같은 재료가 2~3개 진열 — **더 신선한 것 선택** (시각 cue: 윤기/색/시듦). 같은 어묵 2개 중 fresh 고르기 | fresh 선택 → score_shop 가중 + 손님 반응 ↑ | 시든 것 선택 → 감점 (틀린 재료 아님, "질 낮음") | Lv1 비활성 → Lv4+ 활성 (visual quality 중요) |
| **Budget vs quality** | 상단 예산 바. premium 재료(꽃갈비 vs LA갈비)는 비싸지만 quality↑. over-budget이면 강제 cheaper | 예산 내 + 적정 quality | over-budget → 일부 재료 못 삼(key 누락 risk) | Lv2+ 등장, Lv5 tight |
| **Timed challenge** | 기존 공통 타이머 (15~30s). 효율적 순회 = early-finish 여유 | 빠르고 정확 | 타임아웃 → 미수집 재료 = 누락 | 전 Lv (기존) |

### 2.3 success / failure states (사용자 명시)

| 결과 | 조건 | 시각·점수 |
|---|---|---|
| **Perfect shop** | 모든 key 재료 + fresh + 예산 내 + 빠름 | score_shop 1.0, 장바구니 윤기 glow |
| **Missing key** | key 재료 1+ 누락 (타임아웃 or 못 찾음) | score_shop 큰 감점 + Cooking에서 그 재료 부재 시각 (예: 라면에 대파 없음) |
| **Wrong substitute** | banned 재료 선택 (dish-recipe-matrix banned 활용) | 감점 + 손님 "이게 왜 들어가?" 반응 (Lv3+ failure visual) |
| **Over budget** | 예산 초과로 cheaper 강제 | quality 하락 → Cooking/Plating 비주얼 dull |
| **Low freshness** | 시든 재료 선택 (Lv4+) | score_shop minor 감점 + 완성 dish 색 dull |

### 2.4 dish 예시 (사용자 제공 + matrix banned 정합)

> banned 재료는 **dish-recipe-visual-matrix §3** 그대로 활용 (신규 데이터 0).

| dish | 정답(O) | 함정 distractor(X) | freshness 비교 페어 |
|---|---|---|---|
| **순두부찌개** ("Kimchi Stew" reconcile) | 순두부·김치·멸치·고춧가루·호박·계란 | 면류·고추장dollop·**콘도그 반죽·랜덤 과일** | 호박 fresh vs 시든 호박 |
| **라면** | 라면사리·대파·계란·스프 | **김치·당근·두부·밥** | 대파 fresh vs 누런 대파 |
| **비빔밥** | 밥·당근·시금치·콩나물·소고기·계란·고추장 | **고춧가루병·면·김치** | 시금치 fresh vs 시든 시금치 |
| **불고기** | 얇은소고기·간장·배·마늘·설탕·양파·표고 | **면·고추장·두부** | 소고기 fresh vs 변색 소고기 |

### 2.5 ⚠️ ADR-007 basic_pantry 정합 (필수 — 사용자 명시 reconcile)

> **사용자 우려: "Shopping이 core stage로 재추가되면 ADR-007(기본 양념 자동 제공, shopping 제외)과 충돌?"**

**정합안 (superseded 아님 — 강화)**:

- **ADR-007 유지**: 간장·고추장·설탕·참기름·소금 5종(basic_pantry)은 **여전히 Stage 1 Shopping 진열대에 표시하지 않는다**. kitchen rack 자동 제공.
- **Shopping = dish-defining 재료 중심**: Shopping mini-game의 대상은 **음식 정체성을 결정하는 재료**(어묵/순두부/소고기/대파/김치/고춧가루 등). base 양념을 매 음식마다 줍는 반복 노동은 ADR-007대로 제거 유지.
- **왜 충돌 아닌가**: ADR-007이 빼는 것은 "base 양념 줍기 반복". Shopping mini-game이 *추가*하는 것은 "dish 재료를 *잘* 고르기(freshness/budget)". **카테고리가 다르다** — 줍기 제거 vs 잘 고르기 추가. ADR-007의 "음식별 unique signature 재료에 집중" 정신과 정확히 일치.
- **고춧가루(ing_x_017)는 basic_pantry 아님** — 순두부 hero 매운 재료라 Shopping 대상. 고추장(basic_pantry)과 구분 (matrix §F-3 "김치/고추장/고춧가루 3종 분리").
- **정합 결론**: **ADR-007 not superseded. Shopping mini-game은 ADR-007 위에 올라간다.** 진열대 = dish 재료 only, 양념 = rack 자동.

### 2.6 brutal honesty — Shopping freshness/budget는 MVP에서 보류 권고
> Shopping의 기본(재료 선택 + distractor + 타이머)은 이미 있다. **freshness 비교 + budget 시스템은 신규 작업**(art: fresh/시든 재료 페어 sprite ×N, UI: 예산 바, balance: quality→비주얼 연동). 이건 cooking-fun-redesign §9 "NO new systems" 제약과 충돌한다. → **MVP = 기존 Shopping 유지. freshness/budget는 §10 보류 항목.** Lv4~5 게이팅이라 MVP(Lv1~2) 영향 없음.

---

## 3. STAGE 2 — Preparation Mini-Game 디자인

### 3.1 Core fantasy
"**조리 전 손질.** 자르고, 씻고, 재우고, 다듬고, 날재료를 배치한다. 한 동작이 아니라 기법마다 다른 손맛." — 사용자 명시: *"NOT one generic step. Different technique = different mechanic."*

### 3.2 4 기법 분화 (기존 module 매핑)

| Prep 기법 | 기존 module | dish | 메커닉 핵심 |
|---|---|---|---|
| **Cutting (angle+rhythm)** | Slice (10/12) | 라면·떡볶이·김밥·볶음밥·파전·잔치국수·비빔밥·잡채·갈비·순두부 | §4 (이 문서 핵심) |
| **Marinate** | Season marinade variant (MAR-00) | 불고기·갈비 | §3.3 |
| **Wash/Rinse** | (신규 prep micro — 보류 후보) | 쌀·면·채소 | §3.4 |
| **Arrange Raw** | Arrange (4/12) | 김밥·비빔밥·파전·잡채·잔치국수 | §3.5 |

### 3.3 Marinate (불고기·갈비) — Season marinade variant 재사용

> 기존 Season module의 marinade rhythm(MAR-00 60 BPM × 3) 위에 cooking-fun §2.6 강화.

| dim | 설계 |
|---|---|
| Core fantasy | "양념을 **고르게 입히고**, 너무 주무르지 않고, 흡수될 시간을 준다." |
| 메커닉 | 손바닥으로 marinade bowl 위 **고르게 coat** (전체 영역 커버) → overwork 금지(같은 곳 반복 = 망침) → **rest/absorption zone**(잠깐 멈춰 흡수) |
| success | 고른 색 + 윤기 (beef_marinated sprite 고르게 코팅) |
| failure | uneven(얼룩) / too much(양념 흥건) / under-absorb(흡수 부족, 색 옅음) |
| 기존 정합 | MAR-00 60 BPM rhythm 유지 + "고르게 coat" 판정 추가(현행 marinade 채점 도메인 무변경) |

### 3.4 Wash/Rinse (쌀·면·채소) — 신규 micro, 보류 권고

| dim | 설계 |
|---|---|
| Core fantasy | "**물이 맑아질 때까지** 헹군다. 덜 헹구면 텁텁, 너무 헹구면 영양 손실." |
| 메커닉 | 물 색이 탁함→맑음으로 변할 때까지 swipe/탭. **over-rinse 금지**(맑아진 뒤 계속하면 감점) |
| success | 적정에서 멈춤 → 깨끗 + 식감 ↑ | failure | under(탁함 남음) / over(맑은데 계속) |
| **brutal honesty** | **이건 진짜 신규 module이다.** 8 module 풀에 없음 → [ADR-011](../decisions.md#adr-011) "신규 module 금지" 위반. **→ §10 보류.** MVP는 Wash 없이도 12 dish 성립(현 dish_modules에 wash 없음). post-launch 쌀/면 dish 확장 시 검토. |

### 3.5 Arrange Raw (김밥·비빔밥·파전·잡채·잔치국수) — Arrange module 재사용

> 기존 Arrange module + cooking-fun §2.7 강화 + matrix correctness.

| dim | 설계 |
|---|---|
| Core fantasy | "**색과 양의 균형.** 오방색이 조화롭게, 한쪽에 안 쏠리게 배치." |
| 메커닉 | 재료 strip/topping을 김/그릇에 **위치 배치**. Lv↑ → ghost 힌트 약화(cooking-fun §2.7) → 색 대비/대칭 직접 판단 |
| success | 색 균형 + 대칭 (비빔밥 6색 radial, 김밥 5색 band) | failure | 색 몰림(lopsided) / 빈 슬롯(휑함) |
| matrix 정합 | 비빔밥 = rice base + radial 색 toppings(NO noodle), 김밥 = 5색 가로 band, 잔치국수 = 고명 radial. banned 재료 배치 시 fail visual |
| brutal honesty | cooking-fun §6: **Arrange 4 음식은 과용**(재미 4.5/10). 비빔밥(6색 시그니처)·김밥만 Arrange 유지, 잡채/잔치국수는 Stir/Timing으로 흡수 검토(dish_modules 1~2행 조정). → §10. |

### 3.6 Prep success/failure 종합 (사용자 명시)

| 기법 | success | failure |
|---|---|---|
| Cutting | 고른 두께 + 일정 간격 + 정확 각도 | 들쭉날쭉 / 잘못된 각도 / 너무 빠름·느림 (§4 상세) |
| Marinate | 고른 색·윤기 | uneven / too much / under-absorb |
| Wash | 맑은 물 + 식감 | under-rinse / over-rinse |
| Arrange Raw | 색·양 균형 | 색 몰림 / 빈 자리 |

---

## 4. STAGE 2 핵심 — Cutting Technique Mini-Game (angle + rhythm 심화) ⭐ ADDENDUM LOCK

> **사용자 LOCK**: *핵심 skill = angle accuracy + rhythm consistency + even thickness. 단순 swipe/tap 아님.*
> 이 §4는 [ADR-012](../decisions.md#adr-012) Slice action(vertical drag) + [ADR-005](../decisions.md#adr-005) cut style 6종 + cooking-fun §2.1(균일성+콤보)을 **angle+rhythm 층으로 심화**한다. **scoring 도메인(accuracy_prep [0,1]) 무변경.**

### 4.1 4 Cutting Style (사용자 명시 — 기존 CUT-0x 토큰 매핑)

| style | 한식 | 기존 토큰 | angle | rhythm | gesture | prepared visual |
|---|---|---|---|---|---|---|
| **Fine Chop** | 송송썰기 | CUT-05 | **수직 (90°)** | fast, 작은 spacing | 짧고 빠른 반복 vertical drag | 얇은 링 다수 (대파·쪽파) |
| **Diagonal** | 어슷썰기 | CUT-03 | **45~60° 대각** | slower, 대각 spacing | 대각 방향 drag | 타원 대각 단면 (어묵·호박) |
| **Julienne** | 채썰기 | CUT-02 | straight long, **parallel** | mid, spacing 중요 | 길고 균일 parallel drag | 긴 strip (당근·양파) |
| **Dice** | 깍둑썰기 | CUT-06 | **2-direction grid** | h/v then cross | 가로 일괄 → 세로 cross | 정육면체 cube (김치·햄) |

> 추가 매핑: **다지기(CUT-01 mince)** = Fine Chop의 극단(수직 90°, 가장 빠름 140 BPM, 마늘) / **통썰기(CUT-04 round)** = Diagonal 없는 수직 full slice(느림 70 BPM, 단무지·떡). 4 style + 2 = 6 cut 어휘 전부 커버(기존 CUT-01~06 토큰 유지, 신규 토큰 0).

### 4.2 Cutting Score 분해 (사용자 명시 — 4 dimension)

> **핵심 변경**: 기존 Slice는 "통과 여부"만 판정(cooking-fun §2.1 진단: "관대해서 아무렇게나 그어도 통과"). 이를 **4 dimension**으로 심화. **단, 합산 결과는 기존 accuracy_prep [0,1] 단일 도메인으로 emit** (4-factor 무변경).

```
Cutting Score = Angle Accuracy
              + Rhythm Consistency
              + Thickness Consistency   (rhythm + spacing이 유도)
              + Technique Match         (style별 target과 일치)

→ 4 dimension의 가중 평균 → accuracy_prep ∈ [0,1]
   (godot-dev: 입력→점수 변환 함수만 재정의. output signal contract 동일.)
```

| dimension | 측정 | 영향 |
|---|---|---|
| **Angle Accuracy** | drag 각도 vs style target angle (fine=90° / diagonal=45~60° / julienne=parallel / dice=2-dir) | 틀린 각도 → 어슷이 flat, julienne이 chunky |
| **Rhythm Consistency** | cut 간 시간 간격의 표준편차 (steady vs uneven) | steady → 고른 크기 / uneven → 크기 제각각 |
| **Thickness Consistency** | cut 간 공간 spacing의 표준편차 (rhythm+spacing 유도) | 일정 spacing → 균일 / 들쭉날쭉 → 일부 over/undercook |
| **Technique Match** | 위 3개가 style target에 맞는가 | match → 올바른 prepared visual |

### 4.3 점수 등급 (사용자 명시 — angle·rhythm·spacing 기준)

| grade | 조건 | 결과 |
|---|---|---|
| **Perfect** | angle ±tolerance + rhythm steady + spacing 일정 | 고른 조각 + sparkle + chop sound + guest mini 반응 (👀😋) |
| **Good** | 3개 중 2개 충족 | 대체로 균일, minor 편차 |
| **Okay** | 1개 충족 | 눈에 띄는 편차, 일부 over/undercook |
| **Bad** | 전부 빗나감 | 크기 제각각 messy board (단, 무입력만 retry — cooking-fun Fix 1 정합: 빗나간 입력도 저점 박힘) |

### 4.4 Rhythm mechanic (사용자 명시 — 핵심 원리)
> *"Consistent rhythm creates consistent thickness."*

- **steady rhythm** → 고른 크기 → 좋은 texture → 후속 Cooking에서 고르게 익음 → guest 긍정.
- **uneven rhythm** → 크기 제각각 → 일부 over/undercook → texture 하락 → guest 갸웃.
- **⚠️ 너무 musical 금지 (사용자 LOCK)**: rhythm = **knife consistency**지 dancing 아님. cooking precision. beat marker는 보조 cue지 음악 게임 박자가 아니다. ([ADR-005](../decisions.md#adr-005) Knife indicator visual cue 정신 + cooking-fun "rhythm game 아님" 정합.)

### 4.5 Angle mechanic (사용자 명시)
- style별 **target angle**: fine=수직(90°) / diagonal=45~60° / julienne=parallel straight / dice=2-direction(가로 후 세로 cross).
- 틀린 각도 = wrong technique 시각: 어슷이 flat하게 잘림 / julienne이 chunky 덩어리.

### 4.6 Visual feedback (사용자 명시)

| 상태 | 시각 |
|---|---|
| **Perfect** | 고른 조각 + sparkle + chop sound + guest mini 반응 |
| **Uneven rhythm** | 크기 제각각 조각 + messy board |
| **Wrong angle** | 어슷이 flat / julienne이 chunky |
| **Too fast** | messy pile + missed cuts + crushed(부스러기) |
| **Too slow** | oversized 조각 + 약한 rhythm |

### 4.7 UI feedback (사용자 명시 — musical 금지)

- **target angle guide**: style별 각도 가이드선 (반투명).
- **rhythm beat marker**: knife consistency 보조 cue (음악 박자 아님 — 칼 위치 indicator).
- **cut spacing preview**: 다음 cut 예상 위치 (반투명 가이드).
- **live "Even/Uneven"**: 실시간 균일도 피드백.
- **최종 grade**: Perfect/Good/Okay/Bad.
- ⚠️ **너무 musical 금지** — rhythm은 knife consistency 표현이지 dancing 아님.

### 4.8 Casual / Immersive 양 모드 ([ADR-013](../decisions.md#adr-013) 정합)

| 모드 | Cutting 입력 |
|---|---|
| **Casual (default)** | rhythm에 맞춰 **tap** / guide선 따라 짧은 **swipe**. angle은 자동 보정, rhythm만 판정. |
| **Immersive (opt-in)** | repeated swipe (각 cut마다 위치 이동) / **tilt+swipe로 angle 직접 조절** (diagonal=대각 tilt). |

### 4.9 Dish impact (사용자 명시 — cutting 결과가 후속 stage 영향)

> cutting 결과(score_prep)가 후속 Cooking/Plating 비주얼에 인과적으로 연동 (cooking-fun "인과 가시화" 정신).

| dish | cutting 결과 → 후속 영향 |
|---|---|
| 라면 | 대파 송송 균일 → garnish 예쁘게 흩뿌림 |
| 떡볶이 | 어묵/떡 어슷 균일 → sauce coating 고르게 |
| 김밥 | 단무지/재료 통썰기·julienne 균일 → roll balance ↑ → 단면 예쁨(roll→slice 연동) |
| 비빔밥 | 당근 julienne 균일 → radial plating 정갈 |
| 순두부 | 호박 dice gentle → stew 안 고르게 |
| 불고기 | 고기 두께 균일 → grill timing 일관 |
| 갈비 | 마늘 다지기 고름 → garnish + 양념 흡수 |

### 4.10 핵심 원리 (사용자 LOCK — 학습)
> **Cutting은 speed가 아니라 controlled repetition.** "Consistent rhythm creates consistent thickness." 플레이어는 *빨리 긋기*가 아니라 *일정하게 긋기*를 학습한다. 이것이 채썰기 vs 다지기 vs 어슷썰기의 한식 cutting 어휘 학습으로 이어진다(learning-layer 정합).

---

## 5. STAGE 3 — Cooking Mini-Game 디자인

> **무변경 — 기존 6 module 재사용** (Stir/Flip/Timing/Season + method 선택). dish별 signature skill은 cooking-modules §4.2 + cooking-fun §2 강화 그대로. **신규 작업 0** (cooking-fun redesign 범위와 중복 회피).

| dish | signature cooking skill | 기존 module |
|---|---|---|
| 라면 | 물량 + 면 timing (끓이기 9s) | Timing |
| 떡볶이 | sauce thickness + stir (졸이기) | Stir+Timing+Season |
| 김밥 | rolling pressure (squeeze 2박자, cooking-fun §2.3) | Roll |
| 김치볶음밥 | rice-kimchi 고른 mixing (wok) | Stir+Timing |
| 해물파전 | flip timing + crisp | Flip+Timing |
| 콘도그 | batter coat + fry | Flip(dip)+Timing |
| 잔치국수 | noodle timing + garnish | Timing+Arrange |
| 비빔밥 | gochujang量 + mixing (bowl churn) | Season+Stir |
| 잡채 | noodle texture + gentle mix (toss) | Stir+Timing |
| 순두부 | gentle tofu + simmer (보글보글) | Timing+Season |
| 불고기 | marinade(Stage2) + quick grill | Stir+Timing |
| 갈비 | grill flip + caramelize (perfect 0.04 좁음) | Timing+Flip |

> **brutal honesty**: Cooking 단계의 fun 개선은 이미 cooking-fun-redesign-v1 §2.2~2.8에 상세 spec(이동 zone / 눌어붙음 게이지 / 연속 flip 등)이 있다. **이 문서는 그것을 중복 재설계하지 않는다.** Stage 3 = cooking-fun redesign을 그대로 흡수.

---

## 6. STAGE 4 — Plating Mini-Game 디자인

> **격상 — cooking-fun §2.8 + matrix §A-5 reconcile.** 현행 진단: "3지선다 tap = 거의 게임 아님(2.5/10)". 사용자 명시: *"plating이 food를 안 바꾸면 안 됨."*

### 6.1 Core fantasy
"**완성한 요리를 알맞은 그릇에 담아 손님에게 낸다.** 마지막 정성. 담는 위치 + 고명 마무리."

### 6.2 메커닉 (vessel 선택만 아님 — dish별)
- **그릇 선택** (기존 유지) + **담는 행위 추가** (cooking-fun §2.8): 음식을 그릇으로 **drag해서 담기**(off-center 감점) + **garnish 뿌리기 swipe**(한쪽 몰림 감점).
- ⚠️ **matrix §A-5 reconcile**: 현행은 선택 vessel에 음식이 **실제로 안 담김**. → content_only sprite + correct vessel 합성으로 **선택 그릇에 실제 담기는 체감** (matrix C-6).

### 6.3 dish별 Plating (사용자 명시 + matrix vessel)

| dish | plating |
|---|---|
| 김밥 | slice 8조각 wooden_tray 정렬 (cut layout) |
| 비빔밥 | brass_bowl(놋그릇) + topping symmetry + egg center |
| 잔치국수 | noodle_bowl 흰 사발 + noodle nest + 고명 radial |
| 갈비 | grill plate + garnish + dipping 종지 |
| 순두부 | earthenware 뚝배기 + steam 연출 |
| 라면 | noodle_bowl 양은냄비/사발 + 계란/김 |
| 떡볶이 | wide_plate 빨간 분식 접시 |

### 6.4 success / failure (사용자 명시)
- **success**: appealing + dish-appropriate 그릇 + 중앙 안착 + garnish 고름.
- **failure**: messy(garnish 몰림) / wrong bowl / poor balance(off-center).

### 6.5 plating이 food를 바꾼다 (사용자 LOCK)
- 담은 위치·고명이 **완성 비주얼에 실제 반영** (선택 그릇 안에 음식 담김, garnish가 화면에 뿌려짐). 점수는 plate_bonus(display layer, ★ 무영향 — cooking-modules §1.8 정합)이지만 **시각적으로 dish가 달라진다.**

### 6.6 brutal honesty — Plating은 진짜 신규 작업
> cooking-fun §4 ROI 분석: **Plating이 #1 prototype 우선순위**(가장 boring + 12/12 영향 + 마지막 인상). drag+garnish + content_only 합성은 art(content_only 4종 신규, matrix B-1) + godot(drag/swipe) 비용 실재. 하지만 12 dish 모두 개선 + 마지막 인상이라 ROI 최고. **MVP에 포함 권고.**

---

## 7. Dish-by-Dish Matrix (12 dish)

> 각 dish: Shopping / Preparation / Cooking / Plating mini-game + Signature skill + Main failure + Learning. (banned/vessel = dish-recipe-matrix §2 정합.)

| dish | Shopping (정답/banned) | Preparation | Cooking | Plating | Signature | Main failure | Learning |
|---|---|---|---|---|---|---|---|
| **라면** | 면·대파·계란·스프 / **김치·당근·두부** | 대파 Fine Chop(송송 90°) | 끓이기 Timing 9s | noodle_bowl+계란/김 | Timing(끓이기) | 면 불음/설익음 | "9초 타이밍이 전부" |
| **떡볶이** | 떡·어묵·고추장·대파 / **김치**·면 | 어묵 Diagonal(어슷 45~60°) | 졸이기 Stir+Season | wide_plate 빨강 | Stir+Season | 김치 오염/sauce 안 졸음 | "양념을 떡에 졸이기" |
| **김밥** | 김·밥·단무지·당근·계란·햄 / **고추장·면** | 5색 Arrange Raw + 단무지 Round(통썰기) | Roll(squeeze) | wooden_tray 8조각 | Roll | 헐거움/터짐 | "단단히 말기" |
| **김치볶음밥** | 김치·밥·계란·대파 / **고추장·면** | 김치 Dice(깍둑 2-dir) | wok Stir+Timing | wide_plate+계란프라이 | Stir(wok) | 죽처럼 뭉갬/탐 | "강불 wok 볶기" |
| **해물파전** | 쪽파·해물·부침가루 / **고추장·소고기** | 쪽파 Fine Chop(송송) | Flip+Timing(crisp) | wide_plate+간장 종지 | Flip | 반뒤집/안 바삭 | "한 번에 뒤집기" |
| **콘도그** | 소시지·모짜렐라·반죽·빵가루·설탕 / **채소cut·면** | batter dip(DIP-00, cut 아님) | Flip(회전)+Timing | wooden_tray 꼬치+설탕 | Flip(dip) | 코팅 벗겨짐/탐 | "굴려서 고루 튀김" |
| **잔치국수** | 소면·멸치·계란·김·대파·애호박 / **고추장·당면** | 대파 Fine Chop + 고명 Arrange Raw | 육수 Timing 12s + Arrange | noodle_bowl 흰 사발 | Timing+Arrange | 육수 탁함/고명 몰림 | "맑은 육수+정성 고명" |
| **비빔밥** | 밥·당근·시금치·콩나물·소고기·계란·고추장 / **고춧가루병·면·김치** | 당근 Julienne(채썰기) + 6색 Arrange Raw | gochujang量 Season + bowl Stir | brass_bowl+egg center | Arrange(6색)+Stir | 색 몰림/안 비벼짐 | "오방색 균형+바닥부터 비비기" |
| **잡채** | 당면·당근·시금치·표고·소고기·간장 / **소면·고추장** | 당근 Julienne | 당면 toss Stir+Timing | wide_plate 백자+참깨 | Stir(toss) | 당면 불음/뭉침 | "당면 toss(mild 간장)" |
| **갈비** | 갈비·마늘·배·대파·간장·설탕 / **면·고추장** | 마늘 Mince(다지기 140) | grill Timing(0.04)+Flip | 긴 plate+쌈채소 | Timing(좁음) | 타임아웃 탐/덜 익음 | "BBQ는 타이밍 핵심" |
| **순두부** | 순두부·김치·멸치·고춧가루·호박·계란 / **면·고추장dollop** | 호박 Round/Dice gentle | 뚝배기 Timing(보글)+Season(고춧가루) | earthenware+steam | Timing(끓이기) | 끓어 넘침/안 끓음 | "stew=국물 안에 잠겨 끓음" |
| **불고기** | 얇은소고기·간장·배·마늘·설탕·양파·표고 / **면·고추장·두부** | **Marinate(MAR-00 60)** + 양파 Julienne | 양념 코팅 Stir+Timing | brass_bowl+쪽파 | Season(marinade) | uneven 코팅/탐 | "양념재우기=손맛 마사지" |

---

## 8. Top 5 Prototype 추천 (+ 근거)

> 기준: (현재 boring 정도) × (잠재력) × (영향 dish 수) × (사용자 강조도). cooking-fun §4 Top 3와 정합.

### 🥇 1 — Cutting (angle+rhythm) — Stage 2
**근거**: 사용자가 가장 길게 명시한 addendum LOCK. 10/12 dish 영향. 현행 Slice는 "관대해서 아무렇게나 통과"(cooking-fun 6.5/10) — angle+rhythm+thickness 4-dimension이 이걸 *skill 게임*으로 격상. 한식 cut 어휘 학습 1등. **이게 5-stage의 진짜 신규 가치.**

### 🥈 2 — Plating (drag+garnish) — Stage 4
**근거**: cooking-fun §4 #1. 가장 boring(2.5/10)한데 12/12 영향 + 마지막 인상. "food를 안 바꾸면 안 됨"(사용자 LOCK) 직접 충족. content_only 합성으로 "선택 그릇에 담기는" 체감(matrix #4 해결).

### 🥉 3 — Season + guest 통합 (Cooking) — Stage 3
**근거**: cooking-fun §4 #3. default 90점 고정 = 죽은 메커닉. guest 입맛→양념 윈도 이동으로 **"손님 읽고 간 맞추기"** 새 축. Stage 5(Guest)를 조리에 끌어들이는 최적 진입점. 신규 데이터 0(기존 `_guest` dict 재활용).

### 4 — Shopping freshness compare — Stage 1
**근거**: Shopping을 "선택"에서 "*잘* 고르기"로 격상하는 최소 단위. budget보다 freshness가 시각적으로 명확 + ADR-007 정합 쉬움. **단 Lv4+ 게이팅이라 MVP 후순위** — prototype은 하되 ship은 post-launch.

### 5 — Roll squeeze 2박자 (Cooking) — Stage 3
**근거**: 김밥 단독 정체성. squeeze 추가 + roll→slice 단면 연동(인과 가시화)이 짧고 강한 손맛. 김밥은 Roll 단독 dish라 정체성 표현 ROI 높음.

> **Top 5 중 MVP 즉시 = 1,2,3.** 4,5는 prototype 후 alpha 검증. (1=Cutting, 2=Plating, 3=Season-guest가 5-stage 비전의 핵심 3축.)

---

## 9. 현 8 Module 수정/대체 매핑

> 사용자 명시: *어느 8 module을 유지/수정/대체, 새 stage와 매핑.* **결론: 8 module 풀 유지([ADR-011](../decisions.md#adr-011) 준수). 신규 module 0. Slice/Plate 수정, 나머지 무변경.**

| module | 5-stage 매핑 | 조치 | 사유 |
|---|---|---|---|
| **Slice** | Stage 2 Prep (Cutting) | **수정 (심화)** | angle+rhythm+thickness 4-dimension(§4). scoring 도메인 무변경, 입력→점수 변환만 |
| **Arrange** | Stage 2 Prep (Arrange Raw) | **수정 (음식 축소 검토)** | ghost 약화 + 4→2 음식(cooking-fun §6). dish_modules 1~2행 |
| **Stir** | Stage 3 Cooking | 무변경 | cooking-fun §2.5 흡수 |
| **Flip** | Stage 3 Cooking | 무변경 | cooking-fun §2.4 흡수 |
| **Timing** | Stage 3 Cooking | 무변경 | cooking-fun §2.2 흡수 |
| **Season** | Stage 2(marinade) + Stage 3(간) | **수정** | guest 윈도 + 90고정 폐기(cooking-fun §2.6) |
| **Roll** | Stage 3 Cooking | **수정 (강화)** | squeeze 2박자(cooking-fun §2.3) |
| **Plate** | Stage 4 Plating | **수정 (격상)** | drag+garnish+content_only 합성(§6) |
| **(신규 Shopping)** | Stage 1 | **기존 Stage 1 재사용** | 신규 module 아님 — cooking-mechanics §2 다점포 |
| **(Wash 신규)** | — | **대체 안 함 (보류)** | ADR-011 신규 module 금지 → §10 |

> **요약**: 8 module 전부 유지. 5개 수정(Slice/Arrange/Season/Roll/Plate — 전부 입력→점수 변환·연출만, scoring 무변경). 3개 무변경(Stir/Flip/Timing). Shopping은 신규 module이 아니라 기존 Stage 1. **신규 module 0건 = ADR-011 헌법 준수.**

---

## 10. 아직 구현 안 할 것 (보류 — scope 관리)

> 사용자 제약: *scope 정직 (Shopping+Prep 추가 = 큰 확장 — MVP 영향 flag).*

| 항목 | 사유 | 검토 시점 |
|---|---|---|
| **Shopping freshness compare** | 신규 art(fresh/시든 페어 ×N) + UI(quality cue). Lv4+ 게이팅이라 MVP(Lv1~2) 무영향 | post-launch Lv4 활성화 시 |
| **Shopping budget vs quality** | 예산 시스템 = 신규 system (cooking-fun "NO new systems" 충돌). 경제 ripple | post-launch (economy 안정 후) |
| **Wash/Rinse module** | **ADR-011 신규 module 금지 위반.** 현 12 dish에 wash 없음 | post-launch 쌀/면 dish 확장 시 |
| **Cutting Immersive tilt-angle** | tilt 입력 = 기기별 정밀도 편차(ADR-012 R). Casual tap/swipe 우선 | alpha 후 tilt 검증 |
| **Arrange 4→2 축소** | dish_modules 조정은 쉬우나 alpha playtest 필요(잡채/잔치국수 정체성) | alpha playtest 후 |
| **Plating content_only 12종** | matrix B-1: 비빔밥·김밥만 기존, 4종 신규(MVP), 나머지는 점진 | MVP 4종 → post-launch 확장 |
| **dish별 unique cooking 신규 mini-game** | 사용자 회피 명시 + ADR-011 8-module reuse 위반 | 영구 reject |

---

## 11. ⚠️ 기존 자산 Reconcile (필수 — 사용자 명시)

### 11.1 ADR-007 Basic Pantry
- **관계**: **not superseded — 강화.** Shopping 진열대 = dish-defining 재료 only. basic_pantry 5종(간장/고추장/설탕/참기름/소금)은 여전히 kitchen rack 자동(§2.5). Shopping mini-game은 "줍기 제거"(ADR-007) 위에 "잘 고르기"(freshness/budget)를 *추가* — 카테고리 다름, 충돌 없음. 고춧가루(non-pantry)는 Shopping 대상.

### 11.2 8 cooking module (cooking-modules-v1)
- **관계**: **8 module 풀 유지(ADR-011 헌법). 신규 module 0.** §9 매핑 표 — Slice/Arrange/Season/Roll/Plate 수정(전부 입력→점수 변환·연출만, scoring 도메인 무변경), Stir/Flip/Timing 무변경. Wash는 신규 module이라 보류(§10). Shopping은 module이 아니라 기존 Stage 1.

### 11.3 cooking-fun-redesign-v1 (3 Fixes)
- **관계**: **이 문서가 cooking-fun을 supersede하지 않고 *extend*한다.** cooking-fun = "기존 8 module의 feel 강화(stakes/perfect/guest)". 이 문서 = "그 위에 5-stage 프레이밍 + Cutting angle+rhythm 심화 + Shopping/Plating 격상". **3 Fixes(실패 점수 박힘 / perfect 터짐 / 손님 조리 관여)는 이 문서 전 stage에 그대로 깔린다.** Cutting Bad grade는 retry 아닌 저점 박힘(Fix 1), Perfect cut은 sparkle+guest 반응(Fix 2,3). Stage 3 Cooking은 cooking-fun §2를 *그대로 흡수*(중복 재설계 안 함).

### 11.4 dish-recipe-visual-matrix-v1 (recipe correctness)
- **관계**: **정합 — Shopping의 정답/banned + Plating vessel + Cutting prepared visual이 matrix를 ground truth로 사용.** Shopping distractor = matrix banned(떡볶이 김치 / 비빔밥 고춧가루병 / 불고기 면). Cutting prepared visual = matrix §2 prepared states. Plating vessel = matrix vessel. 신규 데이터 0 — matrix 재사용.

### 11.5 ADR-012 Action-First (gesture)
- **관계**: **Cutting angle+rhythm이 ADR-012 Slice(vertical drag)를 *확장*.** ADR-012 = "tap → drag로 재료 가름". 이 문서 = "그 drag의 *각도+리듬+간격*을 4-dimension으로 채점". ADR-012 input redesign 위에 skill depth 추가. Diagonal=대각 drag(ADR-012 정합), Dice=2-direction drag. scoring 무변경(ADR-012 §2 정합).

### 11.6 scoring / 4-factor
- **관계**: **신규 system 0건.** 5-stage가 기존 4-factor(재료25/준비20/방법20/시간35)에 1:1 매핑(§1.3). Shopping=재료, Prep(Cutting/Marinate/Arrange)=준비, Cooking=방법+시간, Plating=display bonus(★ 무영향), Guest=코인 layer(★ 무영향, ADR-009). Cutting 4-dimension은 합산 후 accuracy_prep [0,1] 단일 emit. **★ 임계(30/60/90) 무변경.**

---

## 12. Difficulty by Level (각 mini-game Lv1~5)

> 사용자 명시 progression. 기존 파라미터(perfect_window/prep_taps/distractor/Guest 선호/Golden Spoon)로 표현 — **신규 system 0** (matrix §E 정합).

| Lv | 공통 | Shopping | Cutting(§4) | Plating | Guest |
|---|---|---|---|---|---|
| **Lv1** | wide zone / few / forgiving | distractor 0~1, freshness 비활성 | angle 자동보정, rhythm만, wide tolerance | 그릇 select만(Casual tap) | 없음/light |
| **Lv2** | more / narrower | distractor 1, budget 등장 | rhythm + spacing 판정 추가 | + 중앙 안착 판정 | 1명 등장 |
| **Lv3** | guest 선호 target shift | banned distractor(틀리면 fail visual) | + angle 판정(틀린 각도=wrong visual) | + garnish 분산 | 선호 hit reaction |
| **Lv4** | visual quality 중요 | freshness compare 활성 | thickness consistency 엄격 | symmetry 평가 | guest별 선호 가중 |
| **Lv5** | Golden Spoon precision: angle+rhythm+thickness | budget tight + freshness 필수 | **angle+rhythm+thickness 전부 ±tightest = ★3 게이트** | plating symmetry = ★3 게이트 | critic/Golden Spoon |

---

## 13. brutal honesty — Reject한 아이디어 + Scope 경고

### 13.1 Reject한 mini-game 아이디어

| reject | 사유 |
|---|---|
| **Wash/Rinse를 정식 module로** | ADR-011 신규 module 금지. 현 12 dish에 wash 없음. "물 맑아질 때까지 swipe"는 단순 progress bar 위험(사용자 회피 명시) — 맑아짐 시각만 있으면 너무 easy. **reject → 보류.** |
| **Shopping을 떨어지는 재료 받기(catch) 게임으로** | progression-and-variety §3 후보였으나 — childish + 재래시장 정서 파괴. e-commerce도 아니고 액션 게임도 아닌 어중간. **reject.** |
| **dish별 unique cooking minigame** | 사용자 본인이 회피 명시 + ADR-011 위반. 12 unique = code 폭증. **reject (영구).** |
| **Cutting을 musical rhythm 게임으로** | 사용자 LOCK "너무 musical 금지". beat에 맞춰 칼질 = 리듬게임 되면 cooking precision 정체성 상실. knife consistency지 dancing 아님. **reject the musical framing.** |
| **plating을 그릇 3지선다 유지** | cooking-fun 2.5/10. "food 안 바꾸면 안 됨"(사용자) 위반. 12번 반복되는 가장 지루한 단계. **reject 현행 → 격상 필수.** |
| **freshness를 랜덤 우열로** | "random substitute" 회피(사용자). freshness는 *시각적으로 판별 가능*해야(윤기/색) — 랜덤이면 운빨. **reject 랜덤 → 시각 판별.** |
| **완성 dish 조기 노출** | 사용자 회피 명시. Plating/Guest 전까지 완성 비주얼 숨김. prepared state(cut/marinated)만 노출. **유지.** |

### 13.2 Scope 경고 (정직)

> **이 5-stage 비전을 "전부 신규로" 풀면 MVP가 죽는다.**

1. **Shopping freshness+budget를 풀로 = +3~5주** (art: fresh/시든 페어, UI: 예산 바, balance: quality 연동, economy ripple). [ADR-003](../decisions.md#adr-003) MVP-first + cooking-fun "NO new systems" 둘 다 위반. **→ §10 보류. MVP는 기존 Shopping 유지.**
2. **Cutting angle+rhythm 4-dimension = +2~3주** (godot: drag 각도/간격 sampling, 판정 함수, art: cut style별 prepared sprite, UI: angle guide/spacing preview). **이건 진짜 가치라 MVP 포함 권고하되 일정 flag.** R-A16(일정 +1~3주 out-of-bound) 재발 위험.
3. **Plating drag+garnish+content_only = +2~3주** (art: content_only 4종, godot: drag/swipe). ROI 최고라 포함 권고.
4. **총 MVP 신규 비용**: Cutting(2~3주) + Plating(2~3주) + Season-guest(1주, cooking-fun과 공유) = **+5~7주**. [ADR-003](../decisions.md#adr-003) 3~4개월 buffer를 초과한다. **pm reality check 게이트 필수.**
5. **brutal 결론**: *5-stage는 옳은 비전이다. 하지만 "Shopping과 Prep도 게임"을 풀로 받으면 MVP가 6~10주 늘어난다. 정직하게 — MVP는 Cutting 심화 + Plating 격상 + Season-guest 3개만. Shopping freshness/budget과 Wash는 post-launch. 이게 burnout 안 만들고 5-stage 정체성을 검증하는 길이다.*

---

## 14. 변경 이력
- **2026-06-09 v1.0** — 초안. 5-stage market-to-plate loop 정의(§1) + Shopping(§2)/Prep(§3)/Cutting angle+rhythm 심화(§4)/Cooking(§5)/Plating 격상(§6) mini-game + 12-dish matrix(§7) + Top 5 prototype(§8) + 8 module 수정/대체 매핑(§9) + 보류 항목(§10) + 기존 reconcile(§11: ADR-007/8-module/cooking-fun/recipe-matrix/ADR-012/4-factor) + Lv1~5 difficulty(§12) + brutal honesty reject + scope 경고(§13). **design only, NO code, 구현 보류(승인 대기). 신규 system 0 / 신규 module 0 / 4-factor 무변경.**
```
</invoke>
