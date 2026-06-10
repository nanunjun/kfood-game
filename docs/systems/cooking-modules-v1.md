# Cooking Modules v1 — 8 Reusable Modules + Dish-to-Module Matrix

> 버전: **v1.2 (2026-06-05, supersedes v1.1)** · 작성자: game-designer
> Status: **Accepted** · ADR-011 lock + **ADR-012 action-first input-layer amendment** + **ADR-013 Casual/Immersive mode 정합**
> 상위 문서: [`decisions.md` ADR-005 / ADR-007 / ADR-011 / ADR-012 / ADR-013](../decisions.md), [`action-first-cooking-v1.md` v1.0](action-first-cooking-v1.md), [`cooking-modes-v1.md` v1.0](cooking-modes-v1.md), [`cooking-mechanics.md` v0.7](cooking-mechanics.md), [`motion-spec.md` v0.1](motion-spec.md), [`balance-config.md` v0.7](../balance-config.md)
>
> ⚠️ **v1.2 갱신 ([ADR-013](../decisions.md#adr-013) §3, 사안 #1)**: ADR-012 action-first gesture = **Immersive Mode (opt-in)** 로 재라벨. **Casual Mode (default)** = 각 module 단순화 variant (slice tap-hold / season 1-tap auto-pour / stir 짧은 swipe / timing single tap zone 등). 두 mode 모두 동일 output signal — scoring 무변경. variant 표 = [`cooking-modes-v1.md` §1`](cooking-modes-v1.md). 본 문서 module 구성/sequence/reuse/scoring 전부 무변경.
>
> ⚠️ **v1.1 갱신 ([ADR-012](../decisions.md#adr-012))**: 각 module §1.x interaction에 **action-first cross-ref** 추가 (button/tap → drag/tilt/swipe/flick). 본 문서의 module 구성(8개) / sequence / reuse 분포 / output state / scoring 전부 **무변경** — interaction "어떻게 입력하는가"만 action-first로 amend. 상세 action 설계는 [`action-first-cooking-v1.md`](action-first-cooking-v1.md). ⚠️ ADR-013으로 이 action-first interaction은 **Immersive Mode** 입력이 되었고, **Casual default**는 단순 tap/hold variant ([`cooking-modes-v1.md`](cooking-modes-v1.md)).
>
> **목표 (사용자 verbatim)**:
> - "Players should feel they are cooking a specific Korean dish."
> - "Avoid creating unique minigames per dish."
> - "Reuse modules."
> - **(ADR-012)** "The player should perform a cooking action. The cooking action itself becomes the gameplay."

---

## 0. 헌법 (3-line constitution)

1. **8 modules only** — Slice / Arrange / Stir / Flip / Timing / Season / Roll / Plate. 음식 추가 시 신규 module 생성 금지.
2. **Identity via sequence + visual variation, not mechanic** — Korean dish identity는 module **순서 + 어떤 재료/도구/연출**의 차이로 표현. mechanic 자체는 재사용.
3. **Plate = universal terminal step** — 12 음식 모두 Plate로 끝난다. 음식별 그릇·고명·plating 연출이 dish identity 마지막 sealing layer.

---

## 1. 8 Module Spec

각 module은 다음 6 필드로 정의:
- **id** / **interaction primitive** / **input asset** / **output state** / **success metric** / **Korean feel**

### 1.1 Slice — 자르기 (칼+도마 rhythm tap)

| 필드 | 값 |
|------|-----|
| id | `slice` |
| interaction | **rhythm tap** — 화면 중앙 칼이 자동 위아래 (BPM driven). 도마 닿기 직전 = tap 윈도. ±80ms Perfect / ±200ms Good / Miss |
| input asset | TOOL-01 식칼 + TOOL-02 도마 + 1 hero ingredient (raw sprite) |
| output state | `accuracy_prep ∈ [0, 1]` (모든 tap 평균), hero ingredient sprite swap (raw → cut variation) |
| success metric | tap accuracy %, Perfect 비율 |
| Korean feel | **CUT-01 다지기 / CUT-02 채썰기 / CUT-03 어슷썰기 / CUT-04 통썰기 / CUT-05 송송썰기 / CUT-06 깍둑썰기** — 한식 cutting 6종 명명 표면. 다지기(마늘 minced) vs 어슷썰기(파 diagonal) 같은 한식 고유 표현이 visual variation으로 노출 |

> 🔪 **action-first ([ADR-012](../decisions.md#adr-012))**: rhythm tap → **vertical drag knife through ingredient** — 손가락이 재료를 통과하면 조각이 물리적으로 갈라짐. cut style 6종 = 6가지 다른 drag 동작. [상세 §3.1](action-first-cooking-v1.md#31-slice--자르기-drag-knife-through-ingredient).

**적용**: 라면 송송 / 떡볶이 어슷 / 김밥 통썰기 / 김치볶음밥 깍둑 / 해물파전 송송 / 잔치국수 송송 / 비빔밥 채썰기 / 잡채 채썰기 / 갈비 다지기 / 순두부 통썰기 (총 **10/12**)

**Korean variation layer** (mechanic 동일, 시각만 변주):
- 마늘 다지기 = down-stroke 짧고 빠름 (140 BPM)
- 파 송송 = thin slice mid-tempo (100~110 BPM)
- 호박 통썰기 = round full slice slow (70~80 BPM)

### 1.2 Arrange — 정렬 (drag/drop placement)

| 필드 | 값 |
|------|-----|
| id | `arrange` |
| interaction | **drag/drop** — 화면 하단 재료 트레이 → 상단 슬롯에 배치. correct slot에 놓으면 snap + glow. wrong slot = bounce-back |
| input asset | 그릇/판 sprite + 2~5 재료 sprite + slot grid overlay |
| output state | `accuracy_arrange ∈ [0, 1]` = correct_placement / total_slots |
| success metric | placement accuracy %, 시간 (선택) |
| Korean feel | **김밥 5색 정렬 (단무지·당근·시금치·계란·소시지)** / **비빔밥 6색 hue 배치** — 한식 색감 정렬 미학 (오방색) 직접 표면 |

> 🍱 **action-first ([ADR-012](../decisions.md#adr-012))**: snap-to-slot → **press-drag-release place ingredients into pattern** — raw 재료를 집어 김/그릇 안에 색·순서 맞춰 안착 (자석처럼 settle). plate와 차별: arrange=조리 전 재료를 음식 구조에, plate=조리 후 완성품을 그릇에. [상세 §3.2 / §4.1](action-first-cooking-v1.md#32-arrange--정렬-place-ingredients-into-pattern).

**적용**: 김밥 / 비빔밥 / 잡채 (toss 전 채소 정렬) / 잔치국수 (고명 정렬) — 총 **4/12**

### 1.3 Stir — 휘젓기 (swipe loop or tap rhythm)

| 필드 | 값 |
|------|-----|
| id | `stir` |
| interaction | **swipe circular** (option A: 원형 drag 횟수) **또는 tap rhythm** (option B: 박자 맞춰 좌/우 tap). MVP는 tap rhythm 채택 (latency 부담 ↓) |
| input asset | TOOL-07 주걱 또는 TOOL-11 비빔 그릇 + cooking pot (Scene 2) |
| output state | `accuracy_cook ∈ [0, 1]` (tap accuracy 평균) |
| success metric | tap accuracy %, 횟수 완료율 |
| Korean feel | **김치볶음밥 wok stir** (medium-fast 100 BPM) / **비빔밥 bibim** (90 BPM circular feel, 고추장 색 spread) / **잡채 toss** (당면+채소 entangle) |

> 🥘 **action-first ([ADR-012](../decisions.md#adr-012))**: tap rhythm(박자 좌/우 tap) **폐기** → **continuous circular swipe** — 손가락으로 웍/그릇 위를 끊김 없이 원을 그리며 churn. 박자 tap 아닌 연속 동작 = "휘젓는 손맛". wok(빠른 작은 원)/bibim(느린 큰 원)/toss(좌우 swipe). [상세 §3.3 / §4.2](action-first-cooking-v1.md#33-stir--휘젓기-continuous-wokbowl-motion).

**적용**: 김치볶음밥 / 비빔밥 / 잡채 / 떡볶이 (졸이기 stir) / 불고기 (양념 코팅 stir) — 총 **5/12**

### 1.4 Flip — 뒤집기 (single perfect-window tap)

| 필드 | 값 |
|------|-----|
| id | `flip` |
| interaction | **single tap in perfect window** — 진행 게이지 또는 burn meter가 차오르고 perfect zone 에서 tap. miss 시 burn level ↑ (시각 페널티만, MVP는 점수 영향 0) |
| input asset | TOOL-08 뒤집개 또는 TOOL-09 집게 + cooking surface (frying pan / grill) |
| output state | `flip_score ∈ {1.0, 0.6, 0.0}` (Perfect / Good / Miss). Stage 2C `accuracy_timing` 입력 |
| success metric | perfect tap rate |
| Korean feel | **해물파전 뒤집기** (post-launch full mechanic — MVP 단일 탭 fallback per C-3 lock) / **콘도그 회전** (dip + flip rotation) / **갈비구이 양면 grill** |

> 🍳 **action-first ([ADR-012](../decisions.md#adr-012))**: single tap → **directional flick** — swipe-up flick(전 뒤집기) / 회전 swipe(콘도그). flick **방향+속도**가 결과 결정, 단일 tap 아님. 음식이 공중 회전 → 반대면 착지. C-3 lock 유지 (MVP 해물파전 flick 단일 수행 fallback). [상세 §3.4 / §4.3](action-first-cooking-v1.md#34-flip--뒤집기-directional-flick).

**적용**: 해물파전 (post-launch full / MVP single) / 콘도그 (dip+flip sub-step) / 갈비구이 (양면 grill) — 총 **3/12** (MVP는 사실상 1/12 full; 2/12 sub-fold)

> **C-3 lock 준수**: MVP는 해물파전 flip mechanic 단일 탭 fallback. Module은 정의만 lock, 실 구현은 post-launch 활성화 (Remote Config `cooking.stage3.flip_required_foods`).

### 1.5 Timing — 조리 시간 (게이지 fill + perfect window tap)

| 필드 | 값 |
|------|-----|
| id | `timing` |
| interaction | **gauge fill + perfect tap** — cook_time_sec 동안 게이지가 차오름. perfect_width 윈도에서 tap. PERFECT (0.10 default) / good (0.45) / miss (0.45) |
| input asset | cooking pot/pan + 음식 sprite + 진행 게이지 UI |
| output state | `accuracy_timing ∈ {1.0, 0.6, 0.2, 0.0}` (PERFECT/good/miss/no-tap) |
| success metric | PERFECT 비율 |
| Korean feel | **끓이기 (라면 9s / 떡볶이 13s / 잔치국수 12s / 순두부 14s)** / **볶기 (김치볶음밥 10s / 잡채 16s / 불고기 16s)** / **굽기 (갈비 18s perfect 0.04 좁음 = "타이밍 핵심")** / **튀기기 (콘도그 8s)** |

> 🔥 **action-first ([ADR-012](../decisions.md#adr-012))**: 정지 meter stop-tap → **control stove heat (heat dial 지속 조절)** — 불 다이얼을 위↕아래 drag하여 불 세기 실시간 조절, cook_time 동안 적정 heat zone 유지. 너무 세면 넘침(overflow)/탐. perfect_width = heat zone 폭(값 무변경). [상세 §3.5](action-first-cooking-v1.md#35-timing--조리-시간-control-stove-heat).

**적용**: 12/12 (전 음식 — 끓이기 4 / 볶기 4 / 굽기 1 / 튀기기 1 / 부치기 1 / 비비기 1 — 비비기는 Stir 후 brief timing snap)

### 1.6 Season — 양념 (1-tap auto-pour or marinade rhythm)

| 필드 | 값 |
|------|-----|
| id | `season` |
| interaction | **1-tap auto-pour** (default: basic_pantry rack에서 양념 1-tap dispense, 시각만, accuracy 영향 0) **또는 marinade rhythm** (MAR-00 양념재우기: 손바닥 + marinade bowl 60 BPM × 3 press tap) |
| input asset | basic_pantry rack (간장·고추장·참기름·설탕·소금 5종 항아리/병) + cooking pot/bowl |
| output state | default: 시각 only, `accuracy_season = 1.0` 자동 / marinade variant: `accuracy_prep` 가산 (Slice와 동일 채점) |
| success metric | tap accuracy (marinade variant), 시각 ambience (default) |
| Korean feel | **basic_pantry 5종 자동 제공** (ADR-007 lock — "한국 가정 부엌 상시 비치" 정서) / **양념재우기 = 불고기 마사지 정서** (한국 가정 "양념 손맛" 표현) |

> 🧂 **action-first ([ADR-012](../decisions.md#adr-012))**: 1-tap ADD button → **tilt seasoning bottle** — 양념 통을 기울여(tilt 각도) 유지 시간으로 양 조절, 입자/액체가 떨어짐. default 음식 = 가벼운 tilt(auto-pour 대체, 시각 only, accuracy 무영향, ADR-007 정합). marinade(불고기) = tilt-and-massage 정밀. 양념별 다른 tilt (고춧가루 톡톡 / 간장 줄기 / 참기름 drizzle). [상세 §3.6 / §5.2](action-first-cooking-v1.md#36-season--양념-tilt-seasoning-bottle).

**적용**: 12/12 시각 ambience (전 음식 — basic_pantry rack은 Scene 2 진입 시 자동 표시) + **marinade variant 1/12 (불고기)** + 추가 "양념 hero" 음식 5 (떡볶이 고추장 / 비빔밥 고추장 / 갈비 양념 / 잡채 간장 / 해물파전 간장 — 시각 강조만, mechanic 동일)

> ADR-007 정합: 양념 "고르기" 행위 없음. Season module = 시각 ambience layer (5종 항아리 idle pulse) + marinade rhythm sub-variant.

### 1.7 Roll — 말기 (김발 swipe motion)

| 필드 | 값 |
|------|-----|
| id | `roll` |
| interaction | **swipe motion (drag 왼→오)** — 김발 sprite을 화면 좌→우 swipe 1회로 roll up. swipe 속도 일정 범위 (예: 0.5~1.0 초)면 success, 너무 빠르거나 느리면 retry |
| input asset | TOOL-10 김발 + 김 base sprite + arranged 재료 sprite (Arrange 출력 받음) |
| output state | `accuracy_roll ∈ [0, 1]` (swipe speed band 매칭) |
| success metric | swipe speed accuracy, retry 횟수 |
| Korean feel | **김밥 말기** — 한식 visual signature ("롤이 잘 말리는 만족감"). 동작 = 손목 회전 + 압력의 짧은 ceremony |

> 🍙 **action-first ([ADR-012](../decisions.md#adr-012))**: simple swipe → **forward drag bamboo mat + release timing** — 김발을 앞으로 밀어 올려 김밥이 점진적으로 말림, drag 속도+놓는(release) 타이밍이 모양 품질 결정. 너무 빠르면 터짐/헐거움. 속도 band 무변경(500~1000ms). [상세 §3.7](action-first-cooking-v1.md#37-roll--말기-roll-bamboo-mat-forward).

**적용**: 김밥 (단독) — 총 **1/12** (가장 specialized module)

> 향후 만두 / 호떡 등 추가 시 reuse 가능 — 본 sprint는 김밥 1개로 specialized 유지.

### 1.8 Plate — 담기 (drag/drop + garnish placement)

| 필드 | 값 |
|------|-----|
| id | `plate` |
| interaction | **drag/drop** — cooked dish sprite → 그릇 (선택 1~3 그릇 중 적합한 것), 이후 garnish 1~2개 placement (선택). 1~3초 짧은 ceremony |
| input asset | 음식별 그릇 sprite (1~3종 — 사발/접시/뚝배기/플레이트) + garnish sprite (참깨/김가루/계란지단/쪽파 등) |
| output state | `plate_bonus ∈ {1.0, 0.6, 0.2}` (적절 그릇 + 모든 garnish / 적절 그릇만 / 잘못된 그릇) — display layer only (Result Screen 2.0 §14.1 row 4 wire) |
| success metric | grcid match + garnish placement |
| Korean feel | **음식별 시그니처 그릇** — 떡볶이=빨간 분식 접시 / 잔치국수=흰 사발 / 순두부=검은 뚝배기 / 비빔밥=놋그릇 / 갈비=긴 grill 플레이트 / 김밥=원형 도마 cut layout. 한식 plating identity 마지막 sealing |

> 🍽 **action-first ([ADR-012](../decisions.md#adr-012))**: **이미 action 기반 — input 변경 없음**. drag food onto plate + 고명 placement. 8 module 중 유일하게 ADR-012 input redesign 비대상. [상세 §3.8](action-first-cooking-v1.md#38-plate--담기-drag-food-onto-plate-arrange).

**적용**: 12/12 (전 음식 — universal terminal step)

> Plate는 mechanic 1종이지만 **음식별 그릇·garnish art variation이 12개**라 art workload가 가장 무거운 module. 가장 reuse 많은 만큼 polish 우선순위 #1.

---

## 2. 12-Dish Module Sequence Matrix

각 음식의 module sequence (자연스러운 cooking flow 반영). 3~5 module 사용 (단조 회피 / 지겨움 회피).

| food_id | 음식 | sequence | 시그니처 step | step count | Korean feel summary |
|---------|------|----------|---------------|:----------:|---------------------|
| t1_002 | 라면 | **Slice → Timing → Season → Plate** | Timing (끓이기 9s) | 4 | 대파 송송 → 면+스프 끓이기 → 계란/김 garnish → 노란 양은냄비/사발 |
| t1_003 | 떡볶이 | **Slice → Season → Stir → Timing → Plate** | Stir (양념 졸이기) + Season (고추장) | 5 | 어묵 어슷 → 고추장 1-tap → 졸이기 stir → 빨간 윤기 timing → 분식 접시 |
| t1_004 | 김밥 | **Arrange → Roll → Slice → Plate** | Roll (김발) + Slice (cut) | 4 | 5색 재료 정렬 → 김발 swipe roll → 통썰기 cut → 도마 layout plate |
| t1_005 | 김치볶음밥 | **Slice → Stir → Timing → Plate** | Stir (wok stirfry) | 4 | 김치 깍둑 → wok stir → 볶기 timing → 둥근 접시 + 계란프라이 |
| t1_006 | 해물파전 | **Slice → Flip → Timing → Plate** | Flip (뒤집기) + Timing (panfry) | 4 | 쪽파 송송 → flip (MVP single tap) → panfry timing → 부침개 도마 + 간장 dip |
| t1_007 | 콘도그 | **Slice → Flip → Timing → Plate** | Flip (dip+rotation) + Timing (deepfry) | 4 | batter dip "DIP-00" → 회전 dip flip → 튀김 timing → 꼬치 stand + 설탕/케첩 |
| t1_008 | 잔치국수 | **Slice → Timing → Arrange → Plate** | Timing (육수 boil) + Arrange (고명) | 4 | 대파 송송 → 육수 끓이기 → 고명 정렬 (계란지단·김·쪽파) → 흰 사발 |
| t2_008 | 비빔밥 | **Slice → Arrange → Season → Stir → Plate** | Arrange (6색) + Stir (비비기) | 5 | 당근 채썰기 → 6색 정렬 → 고추장 1-tap → 비비기 stir → 놋그릇 + 참깨 |
| t2_010 | 잡채 | **Slice → Arrange → Stir → Timing → Plate** | Stir (toss) + Arrange (6색) | 5 | 당근 채썰기 → 6색 정렬 → 당면 toss stir → 볶기 timing → 백자 접시 |
| t2_012 | 갈비구이 | **Slice → Season → Timing → Flip → Plate** | Season (양념) + Timing (perfect 0.04) | 5 | 마늘 다지기 140 BPM → 양념 1-tap (간장+설탕+참기름) → grill timing 좁음 → 양면 flip → 긴 grill 플레이트 |
| t2_013 | 순두부찌개 | **Slice → Timing → Season → Plate** | Timing (찌개 끓이기) | 4 | 호박 통썰기 → 뚝배기 끓이기 → 양념 1-tap → 검은 뚝배기 + 계란 |
| t2_014 | 불고기 | **Season (marinade) → Slice → Stir → Timing → Plate** | Season (MAR-00 marinade) | 5 | 양념재우기 60 BPM × 3 press → (양파 채썰기 alpha 후) → 양념 코팅 stir → 볶기 timing → 무쇠 그릇 + 쪽파 |

**Sequence 길이 분포**:
- 4 step: 7 음식 (라면·김밥·김치볶음밥·해물파전·콘도그·잔치국수·순두부)
- 5 step: 5 음식 (떡볶이·비빔밥·잡채·갈비·불고기)

**평균 step**: 4.4 — "단조 회피 (3 step 음식 0) + 지겨움 회피 (6+ 음식 0)" 정합.

---

## 3. Module Reusability 분석

### 3.1 Module 사용 분포

| module | 사용 음식 수 | 음식 리스트 | reuse 등급 |
|--------|:----:|---|------|
| **Plate** | **12** | 전 음식 | ★★★ universal (polish #1) |
| **Timing** | **11** | 비빔밥 외 전 음식 (비빔밥은 Stir로 cook 종료) | ★★★ universal (polish #2) |
| **Slice** | **10** | 라면·떡볶이·김밥·김치볶음밥·해물파전·잔치국수·비빔밥·잡채·갈비·순두부 (콘도그·불고기 제외) | ★★★ high reuse |
| **Stir** | **5** | 떡볶이·김치볶음밥·비빔밥·잡채·불고기 | ★★ mid reuse |
| **Season** | **5** | 라면·떡볶이·비빔밥·갈비·불고기·순두부 (시각 ambience 12/12 + 메커닉 변별 5) | ★★ mid reuse (sub: marinade 1) |
| **Arrange** | **4** | 김밥·비빔밥·잡채·잔치국수 | ★ specialized (oriented to 정렬 미학 음식) |
| **Flip** | **3** | 해물파전·콘도그·갈비 (MVP single tap 1 + sub 2) | ★ specialized |
| **Roll** | **1** | 김밥 단독 | ☆ unique-feel (post-launch 만두·호떡 reuse 후보) |

### 3.2 분포 시각 (텍스트 히트맵)

```
Plate    ████████████ 12
Timing   ███████████  11
Slice    ██████████   10
Stir     █████         5
Season   █████         5
Arrange  ████          4
Flip     ███           3
Roll     █             1
─────────────────────────
total module instances: 51 (12 음식 평균 4.25 module/음식)
```

### 3.3 Polish 우선순위 (개발 시 art/anim 투자 분배)

| 우선순위 | module | 사유 |
|:---:|---|---|
| **P0** | Plate, Timing, Slice | 10~12 음식 reuse, polish 1주가 12 음식 체감으로 multiply |
| **P1** | Stir, Season | 5 음식, mid feel |
| **P2** | Arrange, Flip | 3~4 음식, MVP single tap fallback 활용 |
| **P3** | Roll | 김밥 1개, "signature single" 음식 정체성 강화 (간소 1주 polish로 충분) |

---

## 4. Korean Identity Preservation Strategy

> "Avoid unique minigame per dish"를 지키면서 "Korean dish identity"를 보존하는 4-layer.

### 4.1 Layer 1 — Sequence permutation

같은 module도 **순서가 다르면 다른 음식 정체성**:
- 라면 (Slice→Timing→Season→Plate) = 면 위에 양념 toss
- 떡볶이 (Slice→Season→Stir→Timing→Plate) = 양념 먼저, 졸이기 stir 중심
- 비빔밥 (Slice→Arrange→Season→Stir→Plate) = 정렬 → 비비기 ceremony

### 4.2 Layer 2 — Signature step (각 음식 1~2 hero module)

| 음식 | 시그니처 step | 시그니처 이유 |
|------|--------------|---------------|
| 라면 | Timing | 9s 끓이기 = "라면 끓이는 그 짧은 순간" |
| 떡볶이 | Stir + Season (고추장) | 양념 졸이는 wok stir의 빨간 윤기 |
| 김밥 | Roll | 김발 swipe = 김밥 유일 정체성 |
| 김치볶음밥 | Stir (wok) | 강불 wok stir의 김치 향 burst |
| 해물파전 | Flip | post-launch full flip mechanic (MVP fallback) |
| 콘도그 | Flip (rotation) | dip + 회전 = 콘도그 코팅 |
| 잔치국수 | Timing (육수) + Arrange (고명) | 잔잔한 면 + 정성스러운 고명 |
| 비빔밥 | Arrange (6색) + Stir (비비기) | 6색 정렬 → 비비기 ceremony |
| 잡채 | Stir (toss) | 당면 + 채소 toss entangle |
| 갈비구이 | Timing (0.04 perfect) | "BBQ는 타이밍이 핵심" 사용자 verbatim |
| 순두부찌개 | Timing (뚝배기 끓이기) | 보글보글 시각 + 매콤 정서 |
| 불고기 | Season (MAR-00 marinade) | 양념재우기 60 BPM 마사지 = 한국 가정 손맛 |

### 4.3 Layer 3 — Visual variation per module (mechanic 동일, 시각 변주)

같은 Slice module도 음식별 **visual context**가 완전히 다름:

| Slice 변주 | 음식 | 시각·sound·BPM |
|------------|------|---------------|
| 마늘 다지기 (CUT-01) | 갈비 | 140 BPM, 짧고 빠른 down-stroke, 다진 마늘 山 |
| 당근 채썰기 (CUT-02) | 비빔밥·잡채 | 115~120 BPM, julienne strip |
| 어묵 어슷썰기 (CUT-03) | 떡볶이 | 100 BPM, diagonal slice, 어묵 5조각 |
| 단무지 통썰기 (CUT-04) | 김밥 | 70 BPM, round full slice |
| 호박 통썰기 (CUT-04) | 순두부 | 80 BPM (T2 보정) |
| 대파 송송썰기 (CUT-05) | 라면·잔치국수 | 100~110 BPM, fine slice |
| 쪽파 송송썰기 (CUT-05) | 해물파전 | 110 BPM upper |
| 김치 깍둑썰기 (CUT-06) | 김치볶음밥 | 90 BPM, cube cut |

→ **mechanic = 1 module (Slice). 시각 variation = 8가지**. 플레이어는 "다지기 vs 채썰기"를 한식 cutting 어휘로 학습.

### 4.4 Layer 4 — Plate signature (terminal sealing)

Plate module은 mechanic 1종이지만 **음식별 그릇·garnish가 dish identity 마지막 ID card**:

| Plate 변주 | 음식 | 그릇 + garnish |
|------------|------|----------------|
| 양은냄비/사발 | 라면 | 노란 양은냄비 + 계란/김 |
| 분식 접시 | 떡볶이 | 빨간 윤기 + 어묵 5조각 정렬 |
| 도마 cut layout | 김밥 | 원형 도마 + 김밥 cut 8조각 + 단무지 사이드 |
| 둥근 접시 + 계란프라이 | 김치볶음밥 | 계란프라이 위 |
| 부침개 도마 + 간장 dip | 해물파전 | 둥근 부침개 + 간장+식초 종지 |
| 꼬치 stand | 콘도그 | 설탕/케첩 stripe |
| 흰 사발 | 잔치국수 | 고명 정렬 (계란지단·김·쪽파) |
| 놋그릇 | 비빔밥 | 6색 위 참깨 + 계란 |
| 백자 접시 | 잡채 | 당면 toss 위 참깨 |
| 긴 grill 플레이트 | 갈비 | 양면 grill + 쌈채소 사이드 |
| 검은 뚝배기 | 순두부 | 보글보글 + 계란 |
| 무쇠 그릇 | 불고기 | 양념 코팅 + 쪽파 |

→ **mechanic = 1 module. 그릇·garnish art variation = 12**. 음식 정체성의 마지막 sealing.

---

## 5. Current 7-phase → 8-module Migration Map

> 현 `godot-project/scripts/gameplay/rhythm_proto.gd` 7-phase token (chop / boil / season / stirfry / panfry / roll / knead) → 8-module 변환.

### 5.1 변환표

| 현 7-phase | 8-module | 매핑 정합도 | 비고 |
|-----------|----------|:----------:|------|
| chop | **Slice** | 1:1 ✅ | 명명만 변경 (chop → slice, 더 generic) |
| boil | **Timing** (cook variant: boil) | 1:1 ✅ | Timing module의 cook 변주 |
| season | **Season** | 1:1 ✅ | 동일. basic_pantry 1-tap default + marinade sub-variant |
| stirfry | **Stir** + **Timing** | 1:2 ↗ | Stir (interaction) + Timing (cook 종료 판정) 분리 |
| panfry | **Flip** + **Timing** | 1:2 ↗ | Flip (interaction, MVP single tap) + Timing (cook 종료) 분리 |
| roll | **Roll** | 1:1 ✅ | 동일. 김밥 단독 |
| knead | **(제거)** | 0:0 ❌ | 8 module에 없음. 현 MVP 12 음식에 knead 사용 음식 없음 (호떡 t1_001 superseded — N-1) — **제거 안전** |
| (없음) | **Arrange** | 0:1 ➕ | 신규 — 김밥/비빔밥/잡채/잔치국수 (4 음식) drag/drop placement |
| (없음) | **Plate** | 0:1 ➕ | 신규 — 12/12 universal terminal step |

### 5.2 영향 음식 (migration ripple)

**unchanged (현 7-phase → 8-module mapping 1:1)**:
- 라면 (chop→Slice, boil→Timing, season→Season + Plate 추가)
- 김치볶음밥 (chop→Slice, stirfry→Stir+Timing + Plate 추가)
- 떡볶이 / 잔치국수 / 순두부찌개 / 갈비구이 (cook 변주만)

**affected (Arrange 또는 Roll 신규 추가)**:
- 김밥: Arrange(신규) → Roll(기존) → Slice(기존) → Plate(신규)
- 비빔밥: Slice → **Arrange(신규)** → Season → Stir → **Plate(신규)**
- 잡채: Slice → **Arrange(신규)** → Stir → Timing → **Plate(신규)**
- 잔치국수: Slice → Timing → **Arrange(신규 고명)** → **Plate(신규)**

**post-launch deferred (Flip full mechanic)**:
- 해물파전: MVP single tap (C-3 lock) → post-launch Flip full (Remote Config 활성화)

### 5.3 Migration scope (godot-dev 후속 sprint spec)

- **rhythm_proto.gd** → **cooking_module_runner.gd** rename + module-based dispatch
- **module 1개당 scene file** (8 modules × 1 .tscn = 8 reusable Scene)
- **dish recipe data** = sequence 정의 (예: `t1_004_kimbap_recipe.tres` = `[arrange, roll, slice, plate]`)
- **현 rhythm_proto.gd 7-phase token enum** → 8-module enum migration (코드 변경 spec은 godot-dev 별도 sprint)

> 본 sprint = design only. 코드 구현은 godot-dev 별도 sprint (Sprint M3 권고).

---

## 6. 사용자 verbatim 검증

### 6.1 "Players should feel they are cooking a specific Korean dish"

**보장 메커니즘 4종**:
1. **Sequence permutation** (§4.1) — 같은 module도 순서가 다르면 다른 음식 (라면 vs 떡볶이 vs 비빔밥은 module 구성·순서 모두 다름)
2. **Signature step** (§4.2) — 음식별 1~2 hero module로 identity anchor (김밥 = Roll, 갈비 = Timing 좁음, 불고기 = Season marinade)
3. **Visual variation per module** (§4.3) — Slice 1 module = 8가지 한식 cutting 어휘 노출 (다지기/채썰기/어슷썰기/통썰기/송송썰기/깍둑썰기)
4. **Plate signature** (§4.4) — 12 음식 = 12 그릇 art, 마지막 sealing layer

### 6.2 "Avoid creating unique minigames per dish"

**보장 메커니즘**:
- 12 음식 sequence는 모두 **8 module 풀에서만 조합**. 신규 module 0건 추가.
- "knead" 같은 현재 사용 안 되는 token 제거 (호떡 superseded, 만두/호떡은 post-launch에서 Roll/추후 module reuse).
- **MVP code surface**: 8 module scene + dish recipe data 12 row = 12 minigame 코드 0건 (12 recipe data row만).

### 6.3 "Reuse modules"

**보장 지표** (§3.1 분포):
- 평균 module reuse = 12 음식 × 4.25 step / 8 module = **6.4 음식 per module** (Plate 12 / Timing 11 / Slice 10이 highest)
- 5/8 module이 5+ 음식에서 reuse (Plate·Timing·Slice·Stir·Season)
- 가장 specialized = Roll (1/12) — 김밥 정체성 유지 + post-launch reuse 후보

---

## 7. Open / Follow-up

| # | 항목 | 책임 | 상태 |
|---|------|------|------|
| 1 | Stir module interaction 최종 (swipe circular vs tap rhythm) — MVP는 tap rhythm 권고, alpha 후 확정 | game-designer + godot-dev | open |
| 2 | Arrange module FTUE — 김밥 5색 정렬 첫 노출 시 가이드 패턴 | ui-designer | open |
| 3 | Plate module 그릇 art workload (12 그릇 × 평균 2 garnish = ~36 art assets) | art-director | open |
| 4 | Flip module post-launch 활성화 시점 (해물파전 full mechanic) | pm + game-designer | post-launch M1+ |
| 5 | Roll module 만두/호떡 reuse 시점 (post-launch 음식 추가 시) | pm + game-designer | post-launch deferred |
| 6 | Season marinade variant 부 hero (불고기 양파 채썰기 multi-cut) | game-designer + alpha | open |
| 7 | rhythm_proto.gd → cooking_module_runner.gd 코드 migration spec | godot-dev | Sprint M3 권고 |
| 8 | 8 module × Korean variation art workload 재산정 | art-director | open (art-style lock 후) |

---

## 8. 관련 문서

- [ADR-013](../decisions.md#adr-013) — Polish Phase, Casual/Immersive mode 정합 (본 문서 v1.2 Casual variant cross-ref)
- [cooking-modes-v1.md v1.0](cooking-modes-v1.md) — Casual(default) / Immersive(opt-in) 8 module variant 표 (scoring 무변경)
- [ADR-012](../decisions.md#adr-012) — Action-First Cooking Interaction (= Immersive Mode 입력, 본 문서 v1.1 input-layer amend)
- [action-first-cooking-v1.md v1.0](action-first-cooking-v1.md) — 8 module action-first 상세 설계 = Immersive (gesture / visual sim / 3 states / score emergence)
- [ADR-005](../decisions.md#adr-005) — 4-stage 메커닉 (high-level meta)
- [ADR-007](../decisions.md#adr-007) — basic_pantry (Season default 정합)
- [ADR-011](../decisions.md#adr-011) — 8-Module Cooking Pipeline (본 spec의 정식 ADR)
- [cooking-mechanics.md v0.7](cooking-mechanics.md) — Stage 1~3 룰 + accuracy 공식
- [motion-spec.md v0.1](motion-spec.md) — 12 음식 × 도구 × motion 본격 spec
- [balance-config.md v0.7](../balance-config.md) — module별 BPM/window/threshold lock (§15 신설)
- [foods-database.csv](../foods-database.csv) — 음식 12 row + prep_cut_style + module_sequence (CSV 신설)
- [data/dish_modules.csv](../../data/dish_modules.csv) — 12 음식 × module sequence (본 sprint 신설)
