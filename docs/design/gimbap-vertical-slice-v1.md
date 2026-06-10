# Gimbap Vertical Slice v1 — 5-Stage Loop Proven on One Dish

> 버전: **v1.0 (2026-06-09)** · 작성자: game-designer
> Status: **PROPOSAL — DESIGN ONLY. NO CODE. 구현 보류 (승인 대기).**
> 사용자 mandate (verbatim): *"Do not implement immediately. First produce the Gimbap Vertical Slice design document. Wait for approval."*
>
> **목적**: [`core-loop-minigame-framework-v1.md`](core-loop-minigame-framework-v1.md)의 5-stage 비전을 **김밥 1종(t1_004)으로만 vertical slice 검증**한다. content volume이 아니라 **gameplay quality + cross-stage consequence chain** 검증. 12 dish 전부 구현은 MVP 붕괴 위험([ADR-003](../decisions.md#adr-003)) → **김밥 1개만**.
>
> 상위/관련 (전부 read 후 reconcile):
> - [`core-loop-minigame-framework-v1.md` v1.0](core-loop-minigame-framework-v1.md) — 5-stage 프레이밍 + Cutting angle+rhythm addendum
> - [`dish-recipe-visual-matrix-v1.md` v1 §2.3 / §3](dish-recipe-visual-matrix-v1.md) — 김밥 correct/banned/vessel
> - [`../systems/cooking-mechanics.md` v0.7](../systems/cooking-mechanics.md) — 4-factor 가중평균 + accuracy 공식
> - [`../systems/cooking-modules-v1.md`](../systems/cooking-modules-v1.md) — 8 module, `module_completed(0~100)` contract
> - [`../systems/guest-system-v2.md`](../systems/guest-system-v2.md) — compat/mood/friendship
> - [`../balance-config.md` v0.7.1](../balance-config.md) — prep window, BPM, 4-factor weights
> - 코드 reconcile: [`roll_module.gd`](../../godot-project/scripts/cooking_modules/roll_module.gd) (two-finger redesign 완료), [`slice_module.gd`](../../godot-project/scripts/cooking_modules/slice_module.gd) (angle+speed cutting base), [`arrange_module.gd`](../../godot-project/scripts/cooking_modules/arrange_module.gd), [`plate_module.gd`](../../godot-project/scripts/cooking_modules/plate_module.gd), [`base_module.gd`](../../godot-project/scripts/cooking_modules/base_module.gd)

---

## 0. TL;DR + Scope LOCK (먼저 솔직하게)

김밥은 5-stage full loop를 **자연스럽게** 지원하는 유일한 dish다 (Shopping 5가게 풀 순회 / Julienne cutting / Arrange 5색 band / Roll pressure / Slice 8조각 / Plating tray layout). 그래서 vertical slice 대상으로 최적이다. **단, 이번 sprint는 김밥 1개에만 모든 stage를 깊게 만든다.**

### 0.1 Scope 룰 — 하지 말 것 (LOCK)

| 금지 항목 | 사유 |
|---|---|
| **12 dish 전부 구현** | MVP 붕괴. 이번 sprint = 김밥 1개 vertical slice |
| **Shopping freshness 비교 / budget 시스템** | framework §10 보류 항목. Lv4+ 게이팅이라 MVP 무영향 |
| **Wash / Rinse module** | [ADR-011](../decisions.md#adr-011) 신규 module 금지. 김밥에 wash 없음 |
| **모든 cutting style 구현** | 김밥은 **Julienne(채썰기)만** vertical slice. mince/diagonal/dice/round는 다른 dish용 |
| **모든 plating system** | 김밥 1종 tray layout만 |
| **full cooking-fun-redesign 재구현** | 이 문서는 cooking-fun을 *흡수*하지 *재설계 안 함* |

> **brutal honesty (0)**: 김밥은 5-stage를 자연 지원하지만 **그래서 함정이기도 하다** — 김밥에 잘 맞춰 만든 mini-game이 다른 11 dish에 일반화될지는 이 slice로 검증 못 한다. 이 slice의 목적은 "5-stage loop가 *재미있는가 + 인과가 체감되는가*"이지 "이 구현이 12 dish에 scale하는가"가 아니다. 후자는 별도 generalization sprint 필요. (§9 brutal honesty에서 상세.)

### 0.2 Vertical Slice가 검증해야 하는 7가지 (Success Criteria)

1. 재료 선택이 **미니게임**이 될 수 있다 (단순 선택 아님)
2. cutting이 **angle + rhythm** skill을 쓸 수 있다 (generic swipe 아님)
3. prep 결과가 **후속 cooking 난이도**에 영향
4. roll pressure가 **의미있다** (good/bad 시각 분기)
5. slice 결과가 **plating에 영향**
6. plating이 **static이 아니다** (presentation을 바꾼다)
7. guest reaction이 **플레이어 실제 행동**을 반영

---

## 1. 김밥 5-Stage 전체 흐름 (한눈에)

```
┌─ STAGE 1: SHOPPING 🏪 ───────────────────────────────────────────────┐
│  재래시장 5가게 순회 — 김밥 재료 고르기 (선택 = 미니게임)            │
│  정답: 김·밥·단무지·당근·계란·시금치·햄 / 함정: 라면면·고추장·두부…  │
│  → shopping_quality [0,1]  → accuracy_ingredients (재료 25%)         │
└──────────────────────────────────────────────────────────────────────┘
                  ↓  (누락 재료 → STAGE 3 available filling 감소)
┌─ STAGE 2: PREPARATION 🔪 (Julienne only) ────────────────────────────┐
│  당근 채썰기 — angle + rhythm + spacing 일관 (knife consistency)     │
│  → prep_quality [0,1]  → accuracy_prep (준비 20%)                    │
└──────────────────────────────────────────────────────────────────────┘
                  ↓  (prep_quality 낮음 → STAGE 3 Roll 난이도 ↑)
┌─ STAGE 3: ARRANGE + ROLL 🍙 ─────────────────────────────────────────┐
│  Arrange: 긴 strip을 rice lower-third에 배치 (filling balance)       │
│  Roll: two-finger pressure target zone 유지하며 위로 말기            │
│  → roll_quality [0,1]  → accuracy_method (방법 20%)                  │
└──────────────────────────────────────────────────────────────────────┘
                  ↓  (roll_quality 낮음 → STAGE 4 Slice 난이도 ↑)
┌─ STAGE 4: SLICE + PLATING 🔪🍽 ──────────────────────────────────────┐
│  Slice: angle+rhythm 재사용(단순) — 고른 8조각                       │
│  Plating: 조각을 wooden_tray에 drag 배치 (spacing/orientation)       │
│  → slice_quality [0,1] → accuracy_timing (시간 35%)                  │
│  → plate_quality [0,1] → display bonus (★ 무영향)                    │
└──────────────────────────────────────────────────────────────────────┘
                  ↓  서빙 (slice/plate 결과가 완성 비주얼에 반영)
┌─ STAGE 5: GUEST REACTION 👤 ─────────────────────────────────────────┐
│  손님이 5 quality 종합을 실제 반응 — 짧은 reaction bubble            │
│  + Guest 2.0 compat/mood/friendship + ★ + Recipe XP + 학습 카드      │
└──────────────────────────────────────────────────────────────────────┘
```

> **김밥 module sequence (matrix §2.3 정합)**: `Arrange → Roll → Slice → Plate`. 본 slice는 그 앞에 Shopping(Stage 1, 기존 재래시장) + 당근 Julienne Slice(prep)를 더하고 뒤에 Guest(Stage 5)를 붙여 5-stage full loop를 만든다. **신규 module 0건** — 기존 Slice/Arrange/Roll/Plate 재사용 + 입력→점수 변환·연출만 심화.

---

## 2. STAGE 1 — Shopping MVP

### 2.1 Gameplay
- **기존 재래시장 다점포 5가게** (청과/정육/어물/곡물/잡화 — cooking-mechanics §2) 재사용. e-commerce UI 금지 (시장 좌판/선반 메타포).
- 김밥은 **5가게 풀 순회** dish (matrix: 김·밥·단무지·당근·시금치·계란·햄 = 곡물/청과/정육/잡화 분산) → 5-stage shopping의 가장 풍부한 검증 케이스.
- 플레이어는 시장 선반에서 **올바른 재료를 탭해 장바구니에 담고 함정 재료를 회피**. 공통 타이머가 흐른다.
- **MVP 제외 (LOCK)**: freshness 비교 X / budget X / 복잡 inventory X (framework §10 보류).

### 2.2 정답 / 함정 (matrix §2.3 banned ground truth)

| | 재료 |
|---|---|
| **정답 (O)** | 김(seaweed), 밥(rice), 단무지(danmuji), 당근(carrot), 시금치(spinach), 계란(egg) · 햄/소시지(optional) |
| **함정 (X)** | 라면사리(ramyeon noodle), 고추장(gochujang bottle), 두부(tofu), 떡(tteokbokki rice cake), 육수(soup broth), 콘도그 반죽(corndog batter) |
| **basic_pantry (진열대 미표시)** | 김밥은 basic_pantry 거의 무관(참기름 optional만) → [ADR-007](../decisions.md#adr-007) 정합. kitchen rack 자동 |

> 함정은 matrix 김밥 banned("고추장/김치 매운 재료 / 면류 / 두부")를 그대로 사용 — **신규 데이터 0**. 김밥은 mild dish라 매운 재료가 명확한 함정.

### 2.3 "선택이 미니게임이 된다" — 무엇이 generic tap을 넘는가
> Success Criteria #1. 단순 "정답 N개 탭"이면 generic. 김밥 shopping이 skill이 되는 축:

| 축 | 메커닉 | skill |
|---|---|---|
| **공간 기억** | 정답 가게가 어디인지 표시 안 함 (cooking-mechanics §2.4) — 김밥 = 5가게라 mental map 가치 최대 | 반복 플레이로 "김밥은 곡물상+청과+정육+잡화" 효율 순회 학습 |
| **변별 (함정 회피)** | 같은 가게 안 distractor(곡물상: 밥 ✅ vs 라면면 ❌ / 잡화: 단무지 ✅ vs 고추장 ❌) | banned 재료를 매운맛/면류로 변별 — 김밥 정체성 학습 |
| **타이머 압력** | 공통 타이머(25s, balance-config §2.2.2) — 효율 순회 = early-finish 여유 | 빠르고 정확 |

### 2.4 Scoring → shopping_quality [0,1]
```
shopping_quality = clamp01( correct_picks / N_effective  -  0.15 × wrong_picks )
   (cooking-mechanics §2.5 / balance-config §5.1 그대로 — N_effective = basic_pantry 차감 후)
→ accuracy_ingredients (4-factor 재료 25%)
```
- **correct count**: 정답 재료 수집 비율.
- **wrong penalty**: 함정 선택 시 -0.15/개.
- **missing key penalty**: 핵심 재료(김/밥/단무지) 누락 = 큰 감점 + **STAGE 3 consequence** (§8.1).

### 2.5 Visual states
| 상태 | 시각 |
|---|---|
| **Perfect shop** | 모든 정답 + 함정 0 → 장바구니 가득 + 윤기 glow |
| **Good** | 정답 대부분, 함정 0~1 | 장바구니 정상 |
| **Bad (missing key)** | 김/밥/단무지 중 누락 → 장바구니 빈 슬롯 visible + STAGE 3에서 그 재료 부재 |

### 2.6 Failure states
- **타임아웃**: 미수집 재료 = 누락 처리 (STAGE 3 available filling 감소).
- **함정 선택**: 빨간 shake + 시간 -1s (cooking-mechanics §2.3) + shopping_quality 감점.

---

## 3. STAGE 2 — Preparation MVP (Julienne 채썰기 only)

> **핵심 검증 stage** — Success Criteria #2. framework §4 Cutting angle+rhythm addendum를 김밥 당근 julienne **1 style만**으로 vertical slice. 기존 [`slice_module.gd`](../../godot-project/scripts/cooking_modules/slice_module.gd) `CUT_STYLES["julienne"]` (angle 90°, speed 900~1800) base 위에 **rhythm/spacing consistency** 심화.

### 3.1 Gameplay — knife consistency (NOT music rhythm)
- 대상: **당근 strip** (egg/green은 적용 가능 시 부 hero — MVP는 당근 단독으로 충분).
- **핵심: 긴 얇은 strip을 angle + rhythm + spacing 일관으로 반복 절단.** music rhythm game 아님 (framework §4.4 LOCK: *"너무 musical 금지 — knife consistency지 dancing 아님"*).
- **Casual input (default, [ADR-013](../decisions.md#adr-013))**: parallel guide(반투명 평행선)를 따라 repeated vertical drag/tap-slice. angle 자동 보정, rhythm+spacing 판정.
- **Immersive input (opt-in)**: 각 cut마다 위치 이동하며 repeated swipe — angle 직접.

### 3.2 Scoring → prep_quality [0,1] (4 dimension, framework §4.2)
> 기존 `slice_module._score_cut()`는 (방향 정확도 + 속도 band) 2축. vertical slice는 여기에 **cut 간 rhythm/spacing consistency**를 더해 4 dimension. **합산은 기존 accuracy_prep [0,1] 단일 도메인으로 emit** (4-factor 무변경, `module_completed(0~100)` contract 동일).

| dimension | 측정 | 가중(권고) |
|---|---|---|
| **Angle accuracy** | drag 각도 vs julienne target(90° parallel straight) | 25% |
| **Rhythm consistency** | cut 간 시간 간격의 표준편차 (steady vs uneven) — *신규 축* | 25% |
| **Spacing consistency** | cut 간 공간 간격의 표준편차 (thickness 유도) — *신규 축* | 25% |
| **Thickness consistency** | rhythm+spacing이 유도 (얇고 고른가) | 25% |

```
prep_quality = weighted_avg(angle, rhythm, spacing, thickness) ∈ [0,1]
→ accuracy_prep (4-factor 준비 20%)
```
> godot-dev 주: 기존 `_score_cut`에 cut timestamp/x-position 배열을 누적해 표준편차를 산출하는 **변환 함수만 추가**. signal contract / MODULE_TO_FACTOR("slice"→prep) 무변경.

### 3.3 Visual states (반드시 변함 — Success Criteria #2 핵심)
| grade | strip 시각 |
|---|---|
| **Perfect** | 긴·고른·얇은 strip 다수 + sparkle + chop sound + guest mini 반응(👀😋) |
| **Good** | 대체로 균일, minor 두께 편차 |
| **Bad** | **두껍고 uneven / broken chunky strip** (rhythm 들쭉날쭉 = 크기 제각각) — 시각이 명확히 다름 |

> 기존 asset: `carrot_julienne.png`(perfect)는 보유. **Bad용 chunky/uneven 변형 sprite는 신규**(§6 asset needs) — *bad prep이 시각으로 보여야* Success Criteria #2 충족.

### 3.4 Failure states
- **Too fast**: messy pile + missed cuts + 부스러기(crushed).
- **Too slow / uneven rhythm**: oversized chunky 조각 + 약한 rhythm.
- **Wrong angle**: julienne이 chunky 덩어리(parallel 안 됨).
- **무입력만 retry** (cooking-fun Fix 1: 빗나간 입력도 저점 박힘).

### 3.5 ⭐ Consequence — prep_quality가 Roll 난이도에 영향 (§8.2)
> Success Criteria #3. **고른 얇은 strip → roll이 쉽다 / 두껍고 uneven → roll pressure target이 좁아지고 filling shift 쉬움.** 상세는 §8.2.

---

## 4. STAGE 3 — Arrange + Roll MVP

### 4.1 Arrange (긴 filling strip을 rice에 배치)
- 기존 [`arrange_module.gd`](../../godot-project/scripts/cooking_modules/arrange_module.gd) press-drag-release 재사용 (band shape, 5색).
- 긴 filling strip을 rice **lower-third에 수평 배치** (matrix: 5색 가로 band).
- **메커닉 핵심**: filling **balance**.
  - 과다 filling(한 슬롯에 몰림) → roll 어려움.
  - uneven 배치(좌우 비대칭) → roll pressure target이 비뚤어짐.
- prepared filling = STAGE 2 prep_quality 반영(두꺼운 strip이면 band가 울퉁불퉁).
- → **arrange는 roll_quality에 흡수** (별도 4-factor 축 만들지 않음 — 신규 system 최소화). arrange balance가 §8.3 consequence로 roll에 전달.

### 4.2 Roll (two-finger pressure 미니게임) — ⚠️ 기존 redesign 정합
> Success Criteria #4. **방금 완료된 [`roll_module.gd`](../../godot-project/scripts/cooking_modules/roll_module.gd) two-finger 완전재설계와 정합.** 사용자 vertical slice 명세("pressure target zone 유지하며 위로 말기")는 two-finger redesign과 **이미 정합** — pressure가 이미 scoring 축(25%)이다.

**기존 two-finger roll scoring (roll_module.gd §6.1, 무변경)**:
```
roll_score = balance 40% + pressure 25% + distance 20% + smooth 15%  → [0,100]
   balance  = 1 - |left-right| (좌우 sync)
   pressure = 동시성 × push 적정도 (loose/burst 감점)  ← "pressure target zone"
   distance = sweet zone(0.82~1.02) 도달 = full roll
   smooth   = 속도 변동 작을수록
→ roll_quality [0,1] → accuracy_method (4-factor 방법 20%)
```

**vertical slice 명세 ↔ two-finger 정합 매핑**:
| 명세 ("pressure target zone 유지하며 위로 말기") | two-finger 구현 |
|---|---|
| pressure target zone 유지 | `pressure` 축 (avg_p 0.5~1.02 sweet) — 이미 있음 |
| 위로 말기 | 두 손가락 forward push (`PUSH_DISTANCE`) = `distance` 축 |
| (좌우 균형 — two-finger 고유) | `balance` 축 (vertical slice는 명시 안 했으나 더 풍부) |

### 4.3 Roll 결과 분기 (tear/loose/tight visual 정합 — 사용자 명시)
| 결과 | 조건 (roll_module.gd) | 시각 (정합) |
|---|---|---|
| **too weak (loose)** | `avg_p < 0.5` (loose) | 헐거운 roll / filling shift / 후속 **slice 어려움 ↑** |
| **too strong (tear)** | `avg_p > 1.05` (burst) | 김 찢김 / rice 삐져나옴(squeeze out) / appearance penalty |
| **uneven (crooked)** | `diff > TILT_BAD` | 비뚤어진 cylinder / 후속 slice 단면 wobble |
| **perfect (tight)** | `score≥60 && !burst && !crooked` | tight clean cylinder → `gimbap_roll_finished_content_only` swap → **slice 쉬움 + plating 좋음** |

> 기존 roll_module이 이미 loose/burst/crooked/well_rolled를 `_finalize_roll`에서 분기 + visual(찢김=옆 부풀음, loose=낮은 roundness)을 표현한다 → **vertical slice의 tear/loose/tight 요구를 기존 코드가 충족**. 신규 작업 = §8 consequence 전달 hook (roll_quality를 다음 stage로 넘기는 변수)만.

### 4.4 Failure states
- 두 손가락 미사용(한 손) → "Push both sides together" hint (기존).
- 끝까지 안 말기(distance 부족) → loose.

---

## 5. STAGE 4 — Slice + Plating MVP

### 5.1 Slice (cutting angle+rhythm 재사용, 더 단순)
- 기존 [`slice_module.gd`](../../godot-project/scripts/cooking_modules/slice_module.gd) `round`(통썰기) 재사용 — 완성 roll을 **8조각 통썰기**(matrix §2.3: 단무지 통썰기 + 완성 roll 통썰기).
- STAGE 2 julienne보다 단순(angle 90° full slice, 느린 speed band) — 같은 cutting engine 재사용.

### 5.2 ⭐ roll_quality가 slice 난이도에 영향 (§8.4) — Success Criteria #5
| roll_quality | slice 체감 |
|---|---|
| **낮음 (loose/burst/crooked)** | 조각 wobble / filling 빠짐 / **rhythm window 좁아짐**(자르기 판정 빡빡) |
| **높음 (tight)** | clean 8조각 단면 / **timing window 넉넉**(자르기 쉬움) |

```
slice_quality = cut 평균 [0,1] × (roll_quality 기반 window 보정)
→ accuracy_timing (4-factor 시간 35%) — 김밥은 no-cook이라 timing 축을 slice가 대표
```
> 정합 주: 김밥은 cook timing이 없는 dish다. matrix sequence `Arrange→Roll→Slice→Plate`에서 **Slice가 timing 축(35%)을 대표**한다 (balance-config §3.2: 김밥 perfect_width 0.19 = "짧은 cook_time → 폭 넓게"의 자리를 slice clean-cut 판정이 대신). 이로써 4-factor 합 = 1.0 유지.

### 5.3 Plating (조각을 tray에 arrange) — Success Criteria #6
- 기존 [`plate_module.gd`](../../godot-project/scripts/cooking_modules/plate_module.gd) 격상 (framework §6). 현행 "3지선다 vessel tap"(2.5/10)을 **drag 배치**로.
- **wooden_tray**(matrix vessel) 위에 8조각을 drag로 target arc/row에 배치.
  - **spacing 중요** (고른 간격), **orientation 중요** (단면이 위로), messy → visual score ↓.
- 기존 `gimbap_roll_finished_content_only.png`(content_only 보유 — 김밥은 plate 격상 가능한 2 dish 중 하나) + wooden_tray 합성 → **선택 그릇에 실제로 담기는 체감**(matrix #4 해결).

```
plate_quality = spacing 균일 + orientation 정렬 + 중앙 안착 [0,1]
→ plate_bonus (display layer, ★ 무영향 — cooking-modules §1.8 정합)
```

### 5.4 Visual / Failure states
| stage | success | failure |
|---|---|---|
| **Slice** | 고른 8조각 clean 단면 | wobble 조각 / filling 빠짐 / 두께 제각각 |
| **Plating** | tray 정갈 정렬 + 단면 보임 + 윤기 | messy(몰림) / 뒤집힘(단면 안 보임) / off-center |

> **Success Criteria #6 핵심**: plating이 static이 아니다 — 조각 배치/간격/방향이 **완성 비주얼에 실제 반영**(tray에 실제 담김, 정렬이 화면에 보임). 점수는 display bonus지만 **시각적으로 dish가 달라진다.**

---

## 6. (위에서 §5.4로 통합 — 별도 번호 없음)

---

## 7. STAGE 5 — Guest Reaction MVP

> Success Criteria #7. 기존 **Guest 2.0**(compat/mood/friendship) + Result Screen 2.0 재사용. guest가 **5 quality 종합을 실제 반응**한다.

### 7.1 종합 — 5 quality → guest reaction
- guest는 shopping/prep/roll/slice/plate quality 종합(= 4-factor total + plate_bonus)을 본다.
- **짧은 reaction bubble** (긴 text 금지 — i18n icon-first 정책):

| 조건 (어느 quality가 낮/높은가) | reaction bubble |
|---|---|
| roll_quality 높음 | "Wow, the roll is so clean!" |
| roll_quality 낮음(loose/tear) | "The filling is falling out a bit." |
| slice_quality 낮음(두께 제각각) | "Some pieces are thicker than others." |
| plate_quality 높음 | "This looks like a real lunchbox!" |
| plate_quality 낮음(messy) | "Looks a little messy." |

> **행동 반영 명시**: bubble이 *어느 stage를 잘/못했는지*를 직접 가리킨다 → "내가 한 행동이 반응에 반영됐다" 체감. Guest 2.0 compat/mood는 기존대로 코인 layer(★ 무영향). reaction template은 기존 `data/reaction_templates.csv` 패턴에 김밥 5줄 추가(신규 데이터 최소).

---

## 8. ⭐ Cross-Stage Consequence Chain (가장 중요 — 별도 섹션)

> 사용자 핵심 요구: **"What I did earlier changed what happened later" 체감.** 각 chain의 구체 메커니즘 + 변수 전달을 명시한다. **이것이 vertical slice의 진짜 검증 대상.**

```
shopping_quality ──(누락 재료)──▶ STAGE 3 available filling
prep_quality     ──(strip 품질)──▶ STAGE 3 Roll 난이도 (pressure target 폭)
arrange balance  ──(filling 균형)─▶ STAGE 3 Roll pressure target 위치
roll_quality     ──(roll 품질)───▶ STAGE 4 Slice 난이도 (rhythm window 폭)
slice_quality    ──(조각 품질)───▶ STAGE 4 Plating visual (단면 정렬)
plate_quality    ──(담기 품질)───▶ STAGE 5 Guest reaction
```

### 8.1 Shopping → Arrange/Roll (누락 재료 → available filling)
- **메커니즘**: shopping에서 단무지/당근/계란/시금치 중 누락 → STAGE 3 Arrange에서 **그 strip 슬롯이 비어 있음**(휑한 김밥).
- **변수 전달**: `collected_fillings: Array[String]` (수집한 정답 재료 id). Arrange는 이 배열만큼만 strip 슬롯 생성.
- **체감**: "시장에서 당근 안 샀더니 김밥 속이 비었네" — 직접 인과.

### 8.2 Prep → Roll (strip 품질 → roll 난이도)
- **메커니즘**: prep_quality 낮음(두꺼운 chunky strip) → roll 시 filling이 고르게 안 깔려 **pressure sweet zone이 좁아진다 + filling shift 쉬움**.
- **변수 전달**: `prep_quality [0,1]` → roll_module의 sweet zone 폭 보정 계수(예: `sweet_zone_width *= lerp(0.7, 1.0, prep_quality)`). prep 나쁠수록 roll burst/loose 판정에 빠지기 쉬움.
- **체감**: "당근을 대충 썰었더니 말 때 속이 자꾸 삐져나오네."

### 8.3 Arrange → Roll (filling balance → pressure target 위치)
- **메커니즘**: arrange에서 filling을 한쪽으로 몰면(uneven) → roll의 two-finger **balance target이 비뚤어진다**(좌우 균등 push해도 crooked 판정 쪽으로 bias).
- **변수 전달**: `arrange_balance [0,1]` (좌우 strip 분포 대칭도) → roll_module의 tilt 기준점 offset.
- **체감**: "속을 한쪽에 몰아 넣었더니 김밥이 비뚤어졌네."

### 8.4 Roll → Slice (roll 품질 → slice 난이도)
- **메커니즘**: roll_quality 낮음(loose/burst/crooked) → slice 시 **조각이 wobble + rhythm window 좁아짐**(자르기 판정 빡빡). roll 높음(tight) → clean 단면 + window 넉넉.
- **변수 전달**: `roll_quality [0,1]` → slice_module의 cut 판정 window 폭 보정(예: `cut_window *= lerp(0.6, 1.0, roll_quality)`).
- **체감**: "헐겁게 말았더니 자를 때 속이 다 빠지네."

### 8.5 Slice → Plating (조각 품질 → plating visual)
- **메커니즘**: slice_quality 낮음(두께 제각각/filling 빠짐) → plating tray에 올린 조각이 **들쭉날쭉 + 단면 지저분**. 높음 → 고른 8조각 정렬 가능.
- **변수 전달**: `slice_quality [0,1]` + per-piece 품질 배열 → plating에 spawn되는 조각 sprite의 두께/단면 상태.
- **체감**: "조각이 제각각이라 도시락이 안 예쁘네."

### 8.6 Plating → Guest (담기 품질 → reaction)
- **메커니즘**: plate_quality + 누적 5 quality → guest reaction bubble이 *가장 약한/강한 stage*를 가리킨다(§7.1).
- **변수 전달**: 5 quality 전부 → Guest 2.0 reaction selector.
- **체감**: "정성껏 담았더니 손님이 '진짜 도시락 같다!'고 하네."

> **검증 포인트**: 이 6개 chain 중 **최소 3개(8.2 prep→roll / 8.4 roll→slice / 8.6 plate→guest)가 vertical slice의 코어**다. 나머지(8.1 shopping→arrange / 8.3 arrange→roll / 8.5 slice→plating)는 풍부하게 만들지만 우선순위 P1. **3개 chain이 체감되면 5-stage loop의 인과 검증 성공.**

---

## 9. Scoring Variables — 5 quality var + 4-factor 매핑

> 신규 4-factor 축 0건. 5 quality를 기존 4-factor(재료25/준비20/방법20/시간35) + display bonus에 매핑.

### 9.1 5 quality variable 정의 (모두 [0,1])
| var | 정의 | 산출 stage |
|---|---|---|
| `shopping_quality` | correct/N − penalty×wrong | STAGE 1 |
| `prep_quality` | angle+rhythm+spacing+thickness 가중평균 | STAGE 2 (Julienne) |
| `roll_quality` | balance40+pressure25+distance20+smooth15 (roll_module §6.1) | STAGE 3 (Roll) |
| `slice_quality` | cut 평균 × roll_quality window 보정 | STAGE 4 (Slice) |
| `plate_quality` | spacing+orientation+중앙안착 | STAGE 4 (Plating) |

### 9.2 4-factor 매핑 (cooking-mechanics §5.2 / balance-config §5 무변경)
```
total = (shopping_quality × 0.25)   ← accuracy_ingredients (재료 25%)
      + (prep_quality     × 0.20)   ← accuracy_prep        (준비 20%)
      + (roll_quality     × 0.20)   ← accuracy_method      (방법 20%)
      + (slice_quality    × 0.35)   ← accuracy_timing      (시간 35%, 김밥 no-cook → slice가 대표)

plate_quality → plate_bonus (Result Screen 2.0 display row, ★ 임계 무영향)
compat / mood / friendship → 코인 보상 layer (ADR-009, ★ 무영향)
★1 ≥ 30%, ★2 ≥ 60%, ★3 ≥ 90%
```

### 9.3 module_completed contract 정합 (★ 임계 정합)
- 각 module이 `module_completed(0~100)` emit ([`base_module.gd`](../../godot-project/scripts/cooking_modules/base_module.gd) signal contract 무변경).
- MODULE_TO_FACTOR 매핑(runner): `slice(prep)→accuracy_prep` / `roll→accuracy_method` / 두 번째 slice(통썰기)→accuracy_timing / `arrange→prep`(roll에 흡수) / `plate→display`.
- ★ 임계 30/60/90 무변경. **신규 system 0 / 신규 module 0 / 4-factor 무변경** — vertical slice는 기존 점수 골격 위에서 5 quality를 흐르게 할 뿐.

> ⚠️ **runner 매핑 정합 주의 (godot-dev)**: 김밥 sequence에 **Slice가 2번** 등장(prep용 당근 julienne + Stage 4 통썰기). 첫 Slice→prep(준비20%), 둘째 Slice→timing(시간35%). runner가 step index로 factor를 구분해야 함 (현 MODULE_TO_FACTOR가 module type 단일 매핑이면 김밥 한정 step-aware override 필요 — 신규 작업 flag).

---

## 10. Visual States 종합 (stage별 perfect/good/bad)

| stage | perfect | good | bad |
|---|---|---|---|
| **Shopping** | 장바구니 가득 + glow | 정상 | 빈 슬롯 (누락 재료) |
| **Prep(Julienne)** | 긴 얇은 고른 strip + sparkle | minor 두께 편차 | 두껍고 uneven/broken chunky strip |
| **Roll** | tight clean cylinder (finished swap) | 약간 loose/tilt | 찢김(burst)/헐거움(loose)/비뚤(crooked) |
| **Slice** | 고른 8조각 clean 단면 | minor 두께 차 | wobble 조각/filling 빠짐 |
| **Plating** | tray 정갈 정렬 + 단면 보임 | 약간 불균일 | messy 몰림/뒤집힘/off-center |

---

## 11. Failure States 종합 (stage별)

| stage | failure 조건 | 결과 |
|---|---|---|
| **Shopping** | 타임아웃 / 함정 선택 / key 누락 | 미수집=누락(→§8.1), 함정=shake+−1s, key누락=빈 김밥 |
| **Prep** | too fast(부스러기)/too slow(oversized)/wrong angle(chunky) | prep_quality 저점 → roll 어려움(§8.2). 무입력만 retry |
| **Arrange** | filling 몰림(uneven) | roll balance bias(§8.3) |
| **Roll** | loose/burst/crooked / 한 손만 push | filling shift·찢김·비뚤 → slice 어려움(§8.4) |
| **Slice** | roll 나쁨으로 window 좁음 → 빗나간 cut | wobble 조각 → plating 지저분(§8.5) |
| **Plating** | 몰림/뒤집힘/off-center | plate_bonus 저점 → guest "messy"(§8.6) |

---

## 12. Asset Needs (보유 vs 신규)

### 12.1 보유 (신규 불필요) ✅
| 영역 | asset (`godot-project/art/sprites/`) |
|---|---|
| **Roll** | `roll/bamboo_mat_large` · `seaweed_sheet_rect` · `rice_layer_flat_rect` · `carrot_strip_long` · `egg_strip_long` · `green_strip_long` · `beef_strip_long` · `gimbap_roll_halfway` · `gimbap_roll_finished_content_only` (전부 보유 — roll vertical slice 자산 충족) |
| **Prep(julienne perfect)** | `ingredient/carrot_whole` · `carrot_julienne` (perfect strip) |
| **Arrange** | `arrange_module` REAL_INGREDIENTS (carrot_julienne/egg_cooked/green_onion_julienne/rice_bowl 등 보유) |
| **Plating vessel** | `vessels/wooden_tray` (김밥 plate vessel) + `gimbap_roll_finished_content_only`(content_only 보유) |
| **Guest** | character 5인 × 4 emotion (junho/mina/mrs_lee/riley/seoyeon) + reaction star 1~3 — 보유 |
| **Food ref** | `food/t1_004.png` (김밥 target chip) |

### 12.2 신규 필요 (vertical slice ship 전 art-director 미니 sprint)
| asset | 용도 | 우선순위 | 사유 |
|---|---|---|---|
| **carrot julienne — bad/chunky 변형** | Prep bad visual (§3.3) | **P0** | Success Criteria #2 "bad prep→worse strip 시각" 충족 필수. perfect는 있으나 bad 없음 |
| **shopping shelf UI 좌판/선반** | Stage 1 재래시장 시각 | **P1** | 기존 재래시장 art 재평가(cooking-mechanics §10.2 아트 비용 follow-up). MVP는 placeholder 가능 |
| **danmuji(단무지) strip + 통썰기** | Shopping 정답 + Slice (matrix B-2 P1) | **P1** | 김밥 정답 재료인데 standalone 단무지 sprite 없음 (현재 substitute) |
| **함정 distractor sprite** (라면면/고추장병/두부 등) | Stage 1 함정 | **P1** | 대부분 보유(noodle/kimchi/tofu) — 신규 거의 없음 |
| **wobble/uneven gimbap 조각** | Slice bad visual (§5.4) | **P2** | roll 나쁨→slice wobble 시각. finished_content_only 변형으로 대체 가능 |

> **art 비용 정직**: vertical slice 필수 신규 = **P0 1종(carrot bad julienne)**. 나머지는 P1~P2(placeholder 또는 기존 변형 가능). 5-stage loop *gameplay* 검증에는 P0 1종이면 충분.

---

## 13. F5 Screenshot Target List (검증용)

> godot-dev 구현 시 각 상태를 F5(dev screenshot)로 캡처해 visual 검증. **gameplay quality + consequence 체감**을 스크린샷으로 증명.

| # | screenshot | 검증 |
|---|---|---|
| 1 | **Shopping** — 5가게 + 장바구니 + 함정/정답 선반 | SC#1 선택이 미니게임 (ecommerce X) |
| 2 | **Julienne perfect** — 긴 얇은 고른 strip + sparkle | SC#2 cutting angle+rhythm skill |
| 3 | **Julienne bad** — 두껍고 uneven chunky strip | SC#2/#3 bad prep 시각 |
| 4 | **Arrange** — rice lower-third 5색 strip band 배치 | filling balance |
| 5 | **Roll (mid)** — two-finger push + balance meter | SC#4 pressure 진행 |
| 6 | **Roll perfect (tight)** vs **Roll bad (tear/loose)** | SC#4 pressure good/bad 시각 분기 |
| 7 | **Slice** — 완성 roll 8조각 (clean vs wobble) | SC#5 slice가 roll 품질 반영 |
| 8 | **Plating** — wooden_tray 8조각 정렬 (정갈 vs messy) | SC#6 plating이 presentation 바꿈 |
| 9 | **Guest reaction** — bubble("Wow, the roll is so clean!") | SC#7 guest가 실제 행동 참조 |

---

## 14. ⚠️ 기존 자산 Reconcile (필수)

### 14.1 Roll two-finger redesign (방금 완료)
- **관계**: vertical slice의 roll 명세("pressure target zone 유지하며 위로 말기")는 [`roll_module.gd`](../../godot-project/scripts/cooking_modules/roll_module.gd) two-finger redesign과 **이미 정합** — pressure가 이미 scoring 축(25%). vertical slice는 two-finger를 *대체 안 함*, 그 위에 §8.2/§8.3 consequence 변수(prep_quality/arrange_balance → sweet zone 보정)만 hook. tear(burst)/loose/tight(well_rolled) visual은 기존 `_finalize_roll` 분기가 충족. **신규 roll 작업 = consequence 변수 전달 hook 1건.**

### 14.2 4-factor scoring (재료25/준비20/방법20/시간35)
- **관계**: **무변경.** 5 quality를 그대로 매핑(§9.2). 신규 4-factor 축 0. plate_quality=display bonus(★ 무영향), guest=코인 layer(★ 무영향). ★ 임계 30/60/90 무변경. **단 김밥 한정 Slice 2회 → step-aware factor 매핑이 신규**(§9.3 godot-dev flag).

### 14.3 Assets
- **관계**: roll 9종 + julienne perfect + arrange ingredient + wooden_tray + content_only + guest character 전부 **보유**(§12.1). vertical slice 필수 신규 = carrot bad julienne 1종(P0). **신규 module 0, 신규 asset 사실상 1종.**

### 14.4 Guest 2.0 + framework + cutting addendum
- **관계**: Guest 2.0 compat/mood/friendship 재사용(§7). framework v1.0 5-stage 프레이밍 + Cutting angle+rhythm addendum(§4)를 김밥 julienne 1 style로 vertical slice. matrix §2.3 김밥 banned/vessel을 ground truth로 사용(신규 데이터 0). **이 문서는 framework를 *김밥으로 검증*하지 *재설계 안 함*.**

---

## 15. brutal honesty — generic 우려 stage + 신규 구현 비용 추정

### 15.1 generic 우려 stage (redesign 후보)
| stage | generic 위험 | 처방 |
|---|---|---|
| **Shopping** | "정답 N개 탭"이면 generic tap | 공간 기억(가게 미표시) + 함정 변별 + 타이머로 skill화(§2.3). **단 freshness/budget 없으면 Lv1~2에선 여전히 얕다** — 정직히, MVP shopping은 "괜찮은 선택 게임"이지 "깊은 미니게임"은 아니다. 깊이는 freshness(post-launch §10) 필요 |
| **Arrange** | press-drag-release가 단조로울 수 있음 | filling balance consequence(§8.3)로 의미 부여. **단 balance가 roll에 안 흐르면 arrange는 그냥 drag 작업** — §8.3 chain이 arrange의 생사 |
| **Plating** | 현행 3지선다는 2.5/10 generic | drag 배치 + spacing/orientation으로 격상(§5.3). content_only 합성으로 "실제 담김" 체감. **이게 안 되면 plating은 여전히 generic** |

### 15.2 가장 강한 stage (vertical slice의 자랑)
- **Prep(Julienne)** + **Roll** + **Slice** 3개는 generic 우려가 낮다. julienne angle+rhythm은 skill 명확, roll two-finger는 이미 풍부(balance+pressure+distance+smooth), slice는 roll 품질 반영. **이 3개 + §8 chain이 vertical slice의 핵심 증명.**

### 15.3 신규 구현 비용 추정 (정직)
| 작업 | 비용 | 비고 |
|---|---|---|
| **Cutting rhythm/spacing consistency 2축 추가** | ~3~5일 | `slice_module._score_cut`에 cut timestamp/position 배열 + 표준편차. 변환 함수만, contract 무변경 |
| **carrot bad julienne sprite** | ~0.5일 (art) | P0 1종 |
| **Consequence 변수 전달 hook 3개** (prep→roll, roll→slice, plate→guest) | ~3~5일 | runner가 stage 간 quality 변수 carry. sweet zone/cut window 보정 계수 |
| **Shopping→Arrange filling carry** (§8.1) | ~2일 | collected_fillings 배열 → arrange 슬롯 |
| **Arrange→Roll balance carry** (§8.3) | ~2일 | arrange_balance → roll tilt offset |
| **Plating drag 격상** (§5.3) | ~3~5일 | 기존 plate 3지선다 → drag 배치 (framework §6 비용과 공유) |
| **Guest reaction 김밥 5줄** | ~1일 | reaction template 추가 + 5 quality selector |
| **김밥 한정 step-aware factor 매핑** (§9.3) | ~1~2일 | runner Slice 2회 구분 |
| **총 vertical slice** | **~3~4주 (1인)** | 12 dish 전부 대비 압도적으로 작음. 5-stage loop 정체성 검증에 충분 |

### 15.4 brutal 결론
> **김밥 vertical slice는 옳은 선택이다.** 5-stage loop를 ~3~4주에 *재미있는가 + 인과가 체감되는가*로 검증한다. **하지만 두 가지 정직한 경고**:
> 1. **김밥은 5-stage를 가장 잘 지원하는 dish다 — 즉 best case다.** 여기서 잘 돼도 라면(shopping 2가게/no arrange/no roll)·갈비(140 BPM mince/grill timing)에 그대로 일반화되진 않는다. vertical slice 성공 후 **별도 generalization 검증** 필요.
> 2. **MVP shopping의 깊이는 freshness/budget 없이는 얕다.** 이 slice의 shopping은 "선택 게임"으로 검증하되, "깊은 shopping 미니게임" 결론은 post-launch freshness까지 보류해야 정직하다.
>
> **권고: 이 vertical slice를 ship → alpha playtest로 §8 consequence chain 3개(prep→roll / roll→slice / plate→guest)가 체감되는지 측정 → 체감되면 5-stage 비전 GO, 안 되면 4-stage 유지.** 이것이 burnout 없이 5-stage를 검증하는 길이다.

---

## 16. 보고 요약 (parent agent 용)

1. **Stage flow**: Shopping(시장 5가게) → Prep(당근 julienne, angle+rhythm) → Arrange+Roll(two-finger pressure) → Slice+Plating(8조각 drag tray) → Guest(reaction bubble).
2. **Consequence chain (핵심)**: shopping→filling / prep→roll난이도 / arrange→roll balance / roll→slice난이도 / slice→plating visual / plate→guest. 코어 3개 = prep→roll, roll→slice, plate→guest.
3. **5 quality → 4-factor**: shopping(재료25)/prep(준비20)/roll(방법20)/slice(시간35) + plate(display)·guest(코인). 신규 축 0.
4. **Visual/failure**: 각 stage perfect/good/bad 시각 분기 명시. roll tear/loose/tight = 기존 roll_module 분기 정합.
5. **Asset**: roll 9종+julienne perfect+arrange+wooden_tray+content_only+guest 전부 보유. 필수 신규 = carrot bad julienne 1종(P0).
6. **F5 targets**: shopping/julienne perfect+bad/arrange/roll mid/roll perfect+bad/slice/plating/guest 9컷.
7. **Reconcile**: roll two-finger 정합(pressure 이미 축) / 4-factor 무변경 / asset 보유 / Guest 2.0 재사용 / 신규 module 0.
8. **brutal honesty**: 김밥=best case라 일반화 별도 검증 필요 / MVP shopping 깊이는 freshness 없이 얕음 / 비용 ~3~4주(1인).

---

## 17. 변경 이력
- **2026-06-09 v1.0** — 초안. 김밥 1종 5-stage vertical slice 설계: Shopping MVP(§2)/Julienne Prep(§3)/Arrange+Roll(§4)/Slice+Plating(§5)/Guest(§7) stage-by-stage(gameplay+scoring+visual+failure) + ⭐Cross-stage consequence chain 6개(§8) + 5 quality→4-factor 매핑(§9) + visual/failure 종합(§10·§11) + asset needs 보유 vs 신규(§12) + F5 screenshot 9 target(§13) + 기존 reconcile(§14: roll two-finger/4-factor/assets/Guest 2.0/framework) + brutal honesty generic 우려 + 비용 추정(§15). **DESIGN ONLY, NO CODE, 김밥 1 vertical slice, 구현 보류(승인 대기). 신규 system 0 / 신규 module 0 / 4-factor 무변경 / 필수 신규 asset 1종.**
```
