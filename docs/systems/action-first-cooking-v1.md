# Action-First Cooking v1 — 8 Module Interaction Redesign

> 버전: **v1.0 (2026-06-05)** · 작성자: game-designer
> Status: **Accepted** · [ADR-012](../decisions.md#adr-012) lock
> 상위 문서: [`decisions.md` ADR-011 / ADR-012](../decisions.md), [`cooking-modules-v1.md` v1.1](cooking-modules-v1.md), [`cooking-mechanics.md` v0.7](cooking-mechanics.md), [`balance-config.md` v0.7 §15](../balance-config.md), [`motion-spec.md` v0.1](motion-spec.md), [`data/dish_modules.csv`](../../data/dish_modules.csv)
>
> **목표 (사용자 verbatim)**:
> - "Do not design minigames. Design cooking actions. The player should perform a cooking action. The cooking action itself becomes the gameplay."
> - "Every cooking module should mimic a real cooking action. The mechanic should emerge from the cooking process itself."
> - "Never start with 'What button mechanic should we use?' Start with 'What is the real cooking action?' Then build gameplay around that action."

---

## 0. 헌법 (5-line constitution)

1. **Action, not button** — 모든 module은 실제 한식 조리 동작을 모방한다. 플레이어는 "버튼을 눌렀다"가 아니라 "썰었다 / 양념했다 / 말았다"를 느껴야 한다.
2. **Mechanic emerges from process** — gameplay는 조리 과정 자체에서 나온다. "어떤 버튼 메커닉?"이 아니라 "실제 조리 동작은 무엇?"에서 출발한다.
3. **Input-layer amendment only** — 본 문서는 [ADR-011](../decisions.md#adr-011) 8-module의 **입력 레이어만** 재설계한다. module 구성(8개) / 4-factor scoring / dish_modules.csv sequence / progression 전부 **무변경**.
4. **Score emerges from action** — 점수는 동작 품질에서 자연스럽게 emerge. action 결과(under / perfect / over) → 기존 output signal(`accuracy_prep` 등)으로 매핑. `module_completed(score)` signal contract 무변경.
5. **Korean technique = identity** — 동작 자체가 한식 정체성을 전달한다. 다지기와 채썰기는 다른 칼 동작, 고춧가루 뿌리기와 간장 따르기는 다른 양념 동작.

---

## 1. WRONG → CORRECT 전환 원칙 (codify)

| module | WRONG (button) | CORRECT (action) | player feeling |
|--------|----------------|-------------------|----------------|
| **slice** | beat tap (박자 탭) | move knife through ingredient, pieces split | "I cut carrots" NOT "I tapped a beat" |
| **season** | tap ADD button | tilt seasoning bottle, control amount, particles fall | "I added seasoning" NOT "I pressed ADD" |
| **roll** | hold button | roll bamboo mat forward, control pressure/timing | "I rolled gimbap" NOT "I held a button" |
| **timing** | stop a meter | control stove heat, prevent overflow | "I controlled the heat" NOT "I stopped a meter" |
| **plate** | (n/a — 이미 drag) | drag food onto plate, arrange presentation | "I plated the dish" |
| **arrange** | drag-to-slot (snap) | place ingredients into the roll/bowl, order matters | "I laid out the colors" |
| **stir** | beat tap (좌/우 탭) | continuous wok/bowl motion, ingredients churn | "I stir-fried" NOT "I tapped a rhythm" |
| **flip** | single window tap | flick/swipe to flip pancake or rotate corndog | "I flipped the jeon" NOT "I tapped once" |

**General rule (verbatim)**: "Never start with 'What button mechanic should we use?' Start with 'What is the real cooking action?' Then build gameplay around that action."

---

## 2. 8 Module Action-First 설계 (master 표)

각 module = 6 항목: **real cooking action / input gesture / visual simulation / 3 states / score emergence / Korean technique**.

| # | module | real cooking action | input gesture | visual simulation | output signal (무변경) |
|:-:|--------|---------------------|---------------|-------------------|------------------------|
| 1 | **slice** | 칼로 재료를 내리눌러 썬다 | **vertical drag** (재료 가로지르는 down-stroke drag) — 손가락이 재료를 통과 | drag 경로 따라 재료가 물리적으로 갈라짐 → 조각 분리 + 누적 | `accuracy_prep ∈ [0,1]` |
| 2 | **arrange** | 김/그릇에 재료를 색·자리 맞춰 깐다 | **press-drag-release** (재료 집어 슬롯/방사형 위치로 이동) | 재료가 자리에 안착 → 5색/6색 패턴 채워짐, 잘못된 위치는 안 붙음 | `accuracy_arrange ∈ [0,1]` |
| 3 | **stir** | 웍/그릇을 휘저어 볶거나 비빈다 | **continuous circular swipe** (원형 연속 drag) | 재료가 도는 손가락 따라 churn, 양념색 spread, 윤기 ↑ | `accuracy_cook ∈ [0,1]` |
| 4 | **flip** | 전/콘도그를 뒤집는다 | **directional flick** (위 또는 회전 방향 swipe-up) | 음식이 flick 방향으로 공중 회전 → 반대면 착지 | `flip_score ∈ {1.0,0.6,0.0}` |
| 5 | **timing** | 불 세기를 조절해 끓인다 | **vertical drag on heat dial** (불 다이얼 위↕아래) | 불꽃 세기 + 끓는 강도 실시간 변화, 넘침 risk | `accuracy_timing ∈ {1.0,0.6,0.2,0.0}` |
| 6 | **season** | 양념 통을 기울여 뿌린다/두른다 | **tilt + hold** (통 기울임 각도 + 유지 시간) | 입자/액체가 떨어짐, 음식 표면 색·윤기 변화 | default `accuracy_season=1.0` / marinade `accuracy_prep` 가산 |
| 7 | **roll** | 김발을 앞으로 말아 압력을 준다 | **forward drag + release** (김발 앞으로 밀기, 놓는 타이밍) | 김밥이 점진적으로 말려 올라감, 압력에 따라 단단함 | `accuracy_roll ∈ [0,1]` |
| 8 | **plate** | 음식을 그릇에 담고 고명을 얹는다 | **drag + place** (음식→그릇, 고명 1~2개 placement) | 음식이 그릇에 담김, 고명 안착, presentation 완성 | `plate_bonus ∈ {1.0,0.6,0.2}` |

> **핵심**: input gesture 컬럼이 ADR-011 대비 유일하게 바뀐 것. output signal 컬럼은 [`cooking-modules-v1.md`](cooking-modules-v1.md) / [`balance-config.md §15.1`](../balance-config.md) 와 **bit-identical**.

---

## 3. Module별 상세 (6 항목 full)

### 3.1 Slice — 자르기 (drag knife through ingredient)

| 항목 | 내용 |
|------|------|
| **real action** | 칼날을 재료 위에 올리고 내리눌러 통과시켜 조각을 만든다 |
| **input gesture** | **vertical drag** — 손가락을 재료 위에서 아래로 (또는 cut style별 방향으로) drag. 한 번의 drag = 한 조각. 손가락이 재료 hitbox를 통과해야 cut 성립 |
| **visual simulation** | drag 경로를 따라 재료가 **물리적으로 갈라짐** (sprite split: whole → 2 piece slide-apart). 조각이 도마 위에 **누적** (stack/spread). 칼날이 손가락 위치를 따라옴 (knife follows finger) |
| **score emergence** | 동작 품질 3축에서 `accuracy_prep` emerge: ① **각 cut의 위치 정확도** (목표 cut line 대비 편차) ② **drag 속도 일관성** (cut style별 목표 속도 band) ③ **cut 개수 정확도** (목표 조각 수 ±). 모든 cut 평균 = `accuracy_prep` (기존 perfect/good/miss 구간과 1:1 매핑 — §6.1) |
| **3 states** | **under-cut**: 조각 수 부족 / 큰 덩어리 남음 → 재료 "덜 손질됨" 시각. **perfect**: 균일 조각 + cut style 정확 → 깔끔한 더미. **over-minced**: 너무 잘게 / 과다 cut → "다 부서짐" 시각 (다지기 외 음식에서 페널티) |
| **Korean technique** | **cut style 6종이 서로 다른 drag 동작** (§5.1). 다지기 = 짧고 빠른 반복 drag / 채썰기 = 길고 균일한 평행 drag / 어슷썰기 = 비스듬한 대각 drag |

> Drag = "썰었다" 직접 체감. ADR-005 Knife indicator(자동 위아래 + tap)는 **deprecated** → 손가락이 칼을 직접 움직임.

### 3.2 Arrange — 정렬 (place ingredients into pattern)

| 항목 | 내용 |
|------|------|
| **real action** | 김/그릇 위에 재료를 색·순서·자리를 맞춰 가지런히 깐다 |
| **input gesture** | **press-drag-release** — 하단 트레이에서 재료를 집어(press) 목표 위치로 끌어(drag) 놓는다(release). 김밥 = 가로 5색 띠 / 비빔밥 = 방사형 6색 부채꼴 |
| **visual simulation** | 재료가 손가락 따라옴 → 올바른 위치 근처에서 **자석처럼 안착** (settle, not snap-glow). 색 패턴이 점진적으로 완성됨. 잘못된 위치 = 안 붙고 미끄러져 돌아감 (재료가 "안 놓인다") |
| **score emergence** | `accuracy_arrange = 올바르게 놓인 재료 / 전체 재료`. + **배치 정렬도 보정** (간격 균일 / 색 순서 정확). 분모 = total_slots (2~5). 기존 공식 무변경 |
| **3 states** | **under**: 일부 재료 누락 / 자리 비뚤 → "엉성한 정렬". **perfect**: 5색/6색 균일 안착 → 오방색 미학. **over**: (해당 없음 — arrange는 과잉 상태 없음, under~perfect 연속) |
| **Korean technique** | **오방색 정렬 미학** — 김밥 5색(단무지 노랑·당근 주황·시금치 초록·계란 노랑·소시지 분홍) / 비빔밥 6색 방사형. plate와 차별: arrange = **조리 전 재료를 음식 안에 배치** (roll/stir의 입력), plate = **조리 후 완성 음식을 그릇에 담기** |

### 3.3 Stir — 휘젓기 (continuous wok/bowl motion)

| 항목 | 내용 |
|------|------|
| **real action** | 웍이나 비빔 그릇을 주걱으로 연속 휘저어 볶거나 비빈다 |
| **input gesture** | **continuous circular swipe** — 손가락으로 그릇/웍 위를 **원을 그리며 연속 drag** (박자 tap 아님). 목표 회전 수만큼 끊김 없이 도는 연속 동작. 좌우 toss(잡채)는 좌↔우 연속 swipe 변주 |
| **visual simulation** | 재료가 손가락 회전을 따라 **churn** (돌며 섞임). 양념색이 spread (고추장 빨강 번짐 / 간장 갈색 코팅). 볶을수록 윤기 ↑, 비빔밥은 6색이 섞여 단일 톤으로 |
| **score emergence** | `accuracy_cook` emerge: ① **회전 연속성** (끊김 없이 목표 회전 수 완료) ② **속도 일관성** (cook.bpm_by_action band — stir 100 / slow 60 / fast 110 대응 속도) ③ **coverage** (그릇 전체를 고르게 저었는가). 평균 = `accuracy_cook` |
| **3 states** | **under-stirred**: 회전 부족 → 양념 안 섞임 / 색 얼룩. **perfect**: 균일 churn → 윤기 + 색 고름. **over-stirred**: 과도 회전 → (떡볶이 등) "뭉개짐 / 눌어붙음" 시각 (페널티 약) |
| **Korean technique** | **wok stir**(김치볶음밥 강불 빠른 원 100) / **bibim**(비빔밥 부드러운 원 60, 6색 spread) / **toss**(잡채 좌우 swipe 110, 당면 entangle). 같은 circular지만 **속도·반경·재료 churn 시각이 음식 정체성** |

### 3.4 Flip — 뒤집기 (directional flick)

| 항목 | 내용 |
|------|------|
| **real action** | 전을 뒤집개로 들어 뒤집거나, 콘도그를 회전시켜 튀긴다 |
| **input gesture** | **directional flick** — 음식 위를 **위로 swipe-up flick** (전 뒤집기) 또는 **회전 방향 swipe**(콘도그 rotation). 단일 tap 아님 — flick **방향**과 **속도**가 결과 결정 |
| **visual simulation** | 음식이 flick 방향·속도에 따라 **공중 회전** → 반대면이 위로 와서 착지. 적정 flick = 깔끔한 한 바퀴. 약한 flick = 반만 뒤집힘. 강한 flick = 과회전 / 떨어짐 |
| **score emergence** | `flip_score ∈ {1.0, 0.6, 0.0}` (기존 3-tier 무변경). **flick 방향 정확도 + 속도 band**로 판정: 적정 방향+속도 = 1.0 / 방향 OK·속도 빗나감 = 0.6 / 방향 틀림 또는 미수행 = 0.0 |
| **3 states** | **under (반뒤집)**: 약한 flick → 0.6, 음식 비스듬. **perfect**: 한 바퀴 깔끔 → 1.0, 양면 고름. **over (과회전)**: 강한 flick → 0.0, 음식 흐트러짐 / burn meter ↑ (MVP 시각만) |
| **Korean technique** | **해물파전 뒤집기**(swipe-up, post-launch full / MVP single flick fallback C-3) / **콘도그 회전**(dip 후 rotation swipe) / **갈비 양면 grill**(좌우 flick 양면). C-3 lock 유지 — `flip_required_foods=[]` MVP |

> **C-3 lock 준수**: MVP 해물파전은 flick **단일 수행** fallback (점수 영향 0, FTUE 학습용). post-launch에서 정밀 flick 방향+속도 판정 활성화 (`cooking.modules.flip_required_foods = ["t1_006"]`).

### 3.5 Timing — 조리 시간 (control stove heat)

| 항목 | 내용 |
|------|------|
| **real action** | 가스 불 세기를 조절해 끓이거나 굽는다 (넘치지 않게, 타지 않게) |
| **input gesture** | **vertical drag on heat dial** — 불 다이얼(또는 화구 노브)을 위↕아래로 drag하여 **불 세기를 실시간 조절**. cook_time 동안 적정 heat zone을 **유지**해야 함 (정지된 meter를 한 번 tap하는 게 아니라 **지속 조절**) |
| **visual simulation** | drag에 따라 **불꽃 크기 + 끓는 강도 실시간 변화**. 너무 세면 국물이 **넘침(overflow) risk** 게이지 ↑ + 부글부글 격해짐. 적정이면 안정적 보글보글. 약하면 김 안 남 (덜 익음) |
| **score emergence** | `accuracy_timing ∈ {1.0, 0.6, 0.2, 0.0}` (기존 4-tier 무변경). cook_time 동안 **적정 heat zone 유지 비율**로 판정: zone 유지율 ≥ perfect_width → 1.0 / good band → 0.6 / 벗어남 → 0.2 / 방치(no input) → 0.0. 갈비(perfect_width 0.04 좁음) = heat zone 매우 narrow = "타이밍 핵심" |
| **3 states** | **undercooked**: 불 약하게 유지 → 덜 익음 (게이지 미달). **ideal simmer**: 적정 zone 유지 → 완벽 끓임. **overflow/burnt**: 불 세게 → 넘침(찌개) / 탐(구이) |
| **Korean technique** | **끓이기**(라면 9s / 잔치국수 12s / 순두부 14s — 넘침 관리) / **볶기**(김치볶음밥 / 잡채 16s) / **굽기**(갈비 18s, heat zone 좁음) / **튀기기**(콘도그 8s, 기름 온도). 음식별 cook_time + perfect_width(§3.2)로 heat zone 폭 결정 |

> **scoring 무변경 확인**: 입력만 "정지 meter tap" → "heat dial 지속 조절"로 변경. `accuracy_timing` 4-tier 출력값·perfect_width(C-4 lock 0.10/0.45/0.45)·음식별 perfect_width 12 row 전부 무변경. heat zone 유지율이 기존 "perfect window 명중"을 대체하는 **동등 매핑**.

### 3.6 Season — 양념 (tilt seasoning bottle)

| 항목 | 내용 |
|------|------|
| **real action** | 양념 통/병을 기울여 고춧가루를 뿌리거나, 간장을 따르거나, 참기름을 두른다 |
| **input gesture** | **tilt + hold** — 양념 용기를 집어 음식 위로 기울인다(tilt 각도). 기울인 채 **유지 시간**으로 양을 조절. 손 떼면 멈춤. (기본 음식은 1회 가벼운 tilt = 시각 ambience, marinade 음식은 정밀 조절) |
| **visual simulation** | tilt 각도·시간에 따라 **양념 입자/액체가 떨어짐** (고춧가루 = 가루 낙하 / 간장 = 액체 줄기 / 참기름 = 윤기 드리즐). 음식 표면 색·윤기 변화 (양 누적 시각화). 과다 = 음식이 빨갛게/짜게 보임 |
| **score emergence** | **default**(basic_pantry 1-tap auto-pour 대체): 가벼운 tilt = `accuracy_season = 1.0` 자동 (ADR-007 정합, 시각 ambience only). **marinade variant**(불고기): tilt 정밀 조절 → 양념 양 적정도가 `accuracy_prep` 가산 (60 BPM 마사지 press를 tilt-and-massage 연속 동작으로 표현) |
| **3 states** | **under-seasoned**: 약한 tilt → 양념 적음, 색 옅음. **balanced**: 적정 tilt/유지 → 고른 코팅, 윤기. **over-seasoned**: 과다 tilt → 양념 과잉, 색 짙음 (marinade variant만 페널티) |
| **Korean technique** | **고춧가루 뿌리기**(tilt + 톡톡, 가루 흩날림) / **간장 따르기**(긴 tilt, 액체 줄기) / **참기름 두르기**(원을 그리며 drizzle) / **고추장 풀기**(떡볶이 — 숟갈로 떠 넣는 동작). basic_pantry 5종 자동 제공 정서 유지 (ADR-007) |

> **ADR-007 정합**: 양념 "고르기" 행위는 여전히 없음. 사용자는 Stage 1에서 양념 픽업 X. Season action = **이미 제공된 양념을 뿌리는 동작**. default 음식은 가벼운 tilt(=auto-pour 대체, 점수 영향 0), marinade 음식만 정밀 동작.

### 3.7 Roll — 말기 (roll bamboo mat forward)

| 항목 | 내용 |
|------|------|
| **real action** | 김발을 앞으로 말아 올리며 압력을 줘 김밥을 단단히 만다 |
| **input gesture** | **forward drag + release** — 김발 하단을 잡고 **앞으로(아래→위 또는 가까이→멀리) 밀어 올린다**. drag 속도·거리로 말리는 정도, **놓는 타이밍**(release)이 모양 품질 결정 |
| **visual simulation** | drag에 따라 **김밥이 점진적으로 말려 올라감** (seaweed wraps progressively, 재료가 안으로 감싸짐). 적정 속도 = 단단한 원통. 너무 빠름 = 헐겁게 말림 / 터짐. 너무 느림 = 안 말림. release 시 완성 형태 확정 |
| **score emergence** | `accuracy_roll ∈ [0,1]` (기존 무변경). **drag 속도 band**(`roll_swipe_speed_band_ms = [500,1000]`) 매칭 + **release 타이밍**(끝까지 말렸을 때 놓았는가)으로 판정. band 안 + 적정 release = 높은 점수. band 밖 = retry (FTUE 학습, 점수 영향 0) |
| **3 states** | **under (덜 말림)**: 느린/짧은 drag → 헐거운 김밥, 재료 삐져나옴. **perfect**: 적정 속도+끝 release → 단단한 원통. **over (터짐)**: 너무 빠른/강한 drag → 김 터짐, 재료 튀어나옴 |
| **Korean technique** | **김밥 말기** — 한식 visual signature. forward drag = 손목 회전 + 압력의 짧은 ceremony ("롤이 잘 말리는 만족감"). 김밥 단독 module (post-launch 만두/호떡 reuse 후보) |

### 3.8 Plate — 담기 (drag food onto plate, arrange)

| 항목 | 내용 |
|------|------|
| **real action** | 완성된 음식을 알맞은 그릇에 담고 고명을 얹어 모양을 낸다 |
| **input gesture** | **drag + place** — 완성 음식을 적합한 그릇으로 drag (1~3 후보 중 선택). 이후 고명 1~2개를 집어 음식 위 적정 위치에 place. 1~3초 짧은 presentation ceremony |
| **visual simulation** | 음식이 그릇에 **담김** (settle into bowl). 고명이 안착 (참깨 흩뿌림 / 계란지단 얹기 / 쪽파 올리기). 적합한 그릇 + 고명 = "완성된 한 상" 시각 sealing |
| **score emergence** | `plate_bonus ∈ {1.0, 0.6, 0.2}` (기존 무변경). 적절 그릇 + 모든 고명 = 1.0 / 적절 그릇만 = 0.6 / 잘못된 그릇 = 0.2. Result Screen 2.0 §14.1 row 4 (dish_bonus) wire. display layer |
| **3 states** | **under (잘못된 그릇)**: 부적합 그릇 → 0.2. **perfect**: 시그니처 그릇 + 고명 완비 → 1.0. **over**: (해당 없음 — plate는 과잉 없음) |
| **Korean technique** | **음식별 시그니처 그릇** — 떡볶이 빨간 분식 접시 / 잔치국수 흰 사발 / 순두부 검은 뚝배기 / 비빔밥 놋그릇 / 갈비 긴 grill 플레이트 / 김밥 원형 도마. 한식 plating identity 마지막 sealing (12 그릇 art) |

---

## 4. 신규 설계 3개 상세 (arrange / stir / flip)

> ADR-011에서 interaction이 button/tap-rhythm으로 임시 정의됐던 3개 module을 action-first로 재설계. 사용자 제공 5개 예시(slice/season/roll/timing/plate)와 동급 정합성.

### 4.1 Arrange — drag-to-place vs plate 차별화 (신규)

**문제**: arrange와 plate 둘 다 "drag/drop"이라 동작이 겹칠 위험.

**해결 — 2축 차별화**:

| 축 | arrange | plate |
|----|---------|-------|
| **대상** | **조리 전 raw 재료** (단무지·당근·시금치 strip) | **조리 후 완성 음식** (말린 김밥, 끓인 국수) |
| **목적** | 재료를 **음식 구조 안에** 배치 (roll/stir의 **입력**을 만듦) | 완성품을 **그릇에** 담기 (terminal sealing) |
| **공간** | 음식 내부 구조 (김 위 가로 5색 띠 / 비빔밥 방사형 6색) | 외부 그릇 + 고명 |
| **연속성** | 정밀 색·순서·간격 정렬 (오방색 미학) | 그릇 선택 + 고명 1~2 placement |
| **gesture** | press-drag-release (재료가 자석처럼 settle, 잘못된 자리 = 미끄러짐) | drag + place (그릇 매칭 + 고명) |

**Arrange 구체 동작** (김밥 예):
1. 하단 트레이에 5색 재료 (각 색 strip).
2. 김(seaweed) 위에 **가로 5개 영역** (placement guide, FTUE만 표시).
3. 재료를 집어(press) 해당 색 띠 위치로 drag → release 시 **재료가 김 위에 가지런히 누움**.
4. 5색 모두 배치 완료 → roll module로 자동 전환 (arrange 출력 = roll 입력).

**비빔밥 변주**: 방사형 6색 — 중앙 밥 둘레로 6개 부채꼴 슬롯. 색 순서(오방색 배치)가 정렬도에 가산.

**score**: `accuracy_arrange = 올바른 위치 재료 / 전체` + 간격·순서 정렬 보정. `arrange_correct_glow_ms = 250`(안착 glow), wrong = 350ms bounce-back.

### 4.2 Stir — continuous circular swipe (박자 tap 폐기, 신규)

**문제**: ADR-011 MVP는 "tap rhythm"(박자 좌/우 tap)으로 임시 lock. → 사용자 원칙 위배 ("I stir-fried" NOT "I tapped a rhythm").

**해결 — 연속 원형 swipe**:
- 손가락으로 웍/그릇 위를 **원을 그리며 연속 drag** (끊김 없이). 목표 회전 수(예: 3~5바퀴)를 채운다.
- **박자 tap 완전 폐기** — 연속 동작이 곧 "휘젓는 손맛".

**3 음식 변주** (같은 circular, 다른 feel):

| 음식 | stir 변주 | gesture 디테일 | visual |
|------|----------|----------------|--------|
| 김치볶음밥 | **wok stir** | 빠른 작은 원 (속도 100 대응) | 강불 churn, 김치 향 burst, 재료 튐 |
| 비빔밥 | **bibim** | 느린 큰 원 (속도 60) | 6색 → 단일 톤 spread, 고추장 빨강 번짐 |
| 잡채 | **toss** | 좌↔우 연속 swipe (속도 110) | 당면+채소 entangle, 들어올렸다 떨어뜨리는 toss 시각 |
| 떡볶이 | **졸이기 stir** | 중속 원 | 양념 졸아 빨간 윤기, 떡 코팅 |
| 불고기 | **양념 코팅 stir** | 중속 원 | 양념 고기 표면 코팅, 윤기 |

**score**: `accuracy_cook` = 회전 연속성 + 속도 band(`cook.bpm_by_action`) + coverage. 끊기면(손 뗌) 연속성 감점.

**Remote Config**: `cooking.modules.stir_interaction_mode = "continuous_swipe"` (기존 "tap_rhythm" → 변경. post-launch alt "swipe_circular_segmented" 후보).

### 4.3 Flip — directional flick (단일 tap 폐기, 신규)

**문제**: ADR-011은 "single perfect-window tap"으로 임시 lock. → 사용자 원칙 위배.

**해결 — 방향성 flick**:
- 음식 위를 **swipe-up flick** (전 뒤집기) 또는 **회전 방향 swipe** (콘도그). flick **방향 + 속도**가 결과 결정.
- 단일 tap 아님 — "뒤집는 손동작"을 flick gesture로 직접 표현.

**3 음식 변주**:

| 음식 | flip 변주 | gesture | visual |
|------|----------|---------|--------|
| 해물파전 | **뒤집기** | swipe-up flick (아래→위) | 전이 공중 한 바퀴 → 반대면 착지. MVP single flick fallback (C-3) |
| 콘도그 | **회전** | 원호 swipe (dip 후 rotation) | 콘도그가 batter 코팅하며 회전 |
| 갈비구이 | **양면 grill** | 좌우 flick (한 면씩) | 고기 양면 뒤집어 grill mark |

**score**: `flip_score ∈ {1.0, 0.6, 0.0}` — flick 방향 정확 + 속도 band = 1.0 / 방향 OK 속도 빗나감 = 0.6 / 방향 틀림·미수행 = 0.0.

**C-3 lock**: `cooking.modules.flip_required_foods = []` (MVP). 해물파전은 flick 단일 수행만 요구(점수 무영향), post-launch에서 정밀 방향+속도 판정 활성화.

---

## 5. Korean Technique Identity (per action)

> 동작 자체가 한식 정체성을 전달한다는 원칙의 구체 매핑.

### 5.1 Slice — cut style 6종 = 6가지 다른 drag 동작

| cut style | 한식 명 | drag 동작 | 적용 음식 | BPM(속도 band 대응) |
|-----------|---------|-----------|-----------|:---:|
| CUT-01 | **다지기** (mince) | **짧고 빠른 down-stroke 반복** drag (같은 자리 다타) | 갈비(마늘) | 140 |
| CUT-02 | **채썰기** (julienne) | **길고 균일한 평행** drag (일정 간격) | 비빔밥·잡채(당근) | 115 |
| CUT-03 | **어슷썰기** (diagonal) | **비스듬한 대각** drag | 떡볶이(어묵) | 100 |
| CUT-04 | **통썰기** (round) | **느린 full 수직** drag (재료 전체 통과) | 김밥(단무지)·순두부(호박) | 70~80 |
| CUT-05 | **송송썰기** (fine) | **얇고 빠른 연속** drag (촘촘) | 라면·잔치국수(대파)·해물파전(쪽파) | 110 |
| CUT-06 | **깍둑썰기** (cube) | **격자 cross** drag (가로 후 세로) | 김치볶음밥(김치) | 90 |

→ **mechanic = 1 module(Slice). drag 동작 = 6가지 한식 cutting 어휘**. 플레이어는 "다지기 vs 채썰기"를 손가락 동작으로 학습. BPM은 drag 속도 band의 목표값으로 재해석 (자동 칼 indicator BPM → 손가락 drag 목표 속도).

### 5.2 Season — 양념 종류별 다른 tilt 동작

| 양념 | tilt 동작 | visual | 적용 음식 |
|------|----------|--------|-----------|
| **고춧가루** | 톡톡 tilt (짧은 반복) | 가루 흩날림 | (양념 hero) |
| **간장** | 긴 tilt (액체 줄기) | 갈색 액체 흐름 | 갈비·잡채·해물파전 |
| **참기름** | 원 그리며 drizzle tilt | 윤기 동심원 | 비빔밥·갈비 |
| **고추장** | 떠 넣는 동작 (숟갈) | 빨간 덩이 풀림 | 떡볶이·비빔밥·갈비 |
| **양념재우기** | tilt-and-massage 연속 (marinade) | 양념 코팅 + 마사지 | 불고기(MAR-00 60 BPM) |

### 5.3 음식별 hero action (조리 정체성 전달)

각 음식의 signature step(§dish_modules.csv `signature_step`)이 그 음식 정체성을 전달하는 **hero action**:

| 음식 | hero action | 동작 정체성 |
|------|-------------|-------------|
| 라면 | timing (heat 조절) | 끓는 불 조절 — "라면 끓이는 그 순간" |
| 떡볶이 | stir + season | 고추장 풀어 졸이는 원형 stir의 빨간 윤기 |
| 김밥 | **roll** (김발 forward drag) | 김밥 유일 정체성 — 마는 손동작 |
| 김치볶음밥 | stir (wok) | 강불 빠른 원 churn, 김치 향 |
| 해물파전 | **flip** (swipe-up) | 전 뒤집는 손목 flick |
| 콘도그 | flip (rotation) | dip + 회전 코팅 |
| 잔치국수 | timing + arrange | 잔잔한 육수 불 + 정성스런 고명 placement |
| 비빔밥 | arrange + stir | 6색 정렬 → 비비는 원형 ceremony |
| 잡채 | stir (toss) | 당면 좌우 toss swipe |
| 갈비구이 | timing (heat zone 좁음) | 정밀 불 조절 — "BBQ는 타이밍이 핵심" |
| 순두부찌개 | timing (넘침 관리) | 뚝배기 보글보글 + 넘침 방지 heat |
| 불고기 | season (marinade tilt-massage) | 양념 마사지 — 한국 가정 손맛 |

---

## 6. 점수 매핑 (action 결과 → 0~100, 4-factor 무변경)

> **핵심 원칙**: action의 3 state(under/perfect/over)가 기존 output signal 값으로 **결정론적 매핑**. 4-factor 가중치·★ 임계·`module_completed(score)` signal contract **전부 무변경**. 입력→점수 변환 **함수만** 재정의.

### 6.1 module별 action → score 매핑 표

| module | action 품질 측정 | → output signal | perfect | good/mid | under/over | fail |
|--------|------------------|-----------------|:---:|:---:|:---:|:---:|
| **slice** | cut 위치 편차 + drag 속도 band + cut 개수 | `accuracy_prep ∈ [0,1]` (cut 평균) | 편차 ≤ perfect(±80ms 등가) → 1.0 | ≤ good(±200ms 등가) → 0.6 | 큰 편차 → 0.0 | no-cut → 0.0 |
| **arrange** | 올바른 위치 비율 + 정렬 보정 | `accuracy_arrange ∈ [0,1]` | 전부 정확 + 균일 → 1.0 | 위치는 맞고 간격 흐트러짐 → 0.6~0.9 | 일부 누락 → 비례 감소 | 전부 오배치 → 0.0 |
| **stir** | 회전 연속성 + 속도 band + coverage | `accuracy_cook ∈ [0,1]` (평균) | 연속+적정 속도+고른 coverage → 1.0 | 끊김/속도 일부 빗나감 → 0.6 | 회전 부족 → 비례 | no-stir → 0.0 |
| **flip** | flick 방향 + 속도 band | `flip_score ∈ {1.0,0.6,0.0}` | 방향+속도 적정 → 1.0 | 방향 OK 속도 빗나감 → 0.6 | — | 방향 틀림/미수행 → 0.0 |
| **timing** | heat zone 유지율 | `accuracy_timing ∈ {1.0,0.6,0.2,0.0}` | 유지율 ≥ perfect_width → 1.0 | good band → 0.6 | 벗어남 → 0.2 | 방치 → 0.0 |
| **season** (default) | (가벼운 tilt, 시각만) | `accuracy_season = 1.0` 자동 | 항상 1.0 | — | — | — |
| **season** (marinade) | tilt 양 적정 + massage 연속 | `accuracy_prep` 가산 | 적정 → 1.0 | 약간 과/소 → 0.6 | 과다/부족 → 비례 | 미수행 → 0.0 |
| **roll** | drag 속도 band + release 타이밍 | `accuracy_roll ∈ [0,1]` | band 안 + 끝 release → 1.0 | band 경계 → 0.6 | band 밖 → retry(점수 0 영향) | — |
| **plate** | 그릇 매칭 + 고명 완비 | `plate_bonus ∈ {1.0,0.6,0.2}` | 적절 그릇+고명 → 1.0 | 그릇만 → 0.6 | 잘못된 그릇 → 0.2 | — |

### 6.2 4-factor 합산 (cooking-mechanics §5.2 / balance §5 — 무변경)

```
# 무변경 (ADR-005 lock). 입력 signal 값은 §6.1 action 매핑에서 생성.
total = (accuracy_ingredients × 0.25)   # Stage 1 (action 무관, 재료 선택)
      + (accuracy_prep        × 0.20)   # slice / season(marinade) action 결과
      + (accuracy_method      × 0.20)   # stir / flip / timing 등 cook action
      + (accuracy_timing      × 0.35)   # timing action 결과

★1 ≥ 30%, ★2 ≥ 60%, ★3 ≥ 90%
```

> **Result Screen 2.0(§14.1) 4 cooking row 매핑**: prep_score(0.20) ← slice·season action / cook_score(0.20) ← stir·flip action / seasoning_score(0.20) ← season action / plating_score(0.20) ← plate `plate_bonus`. 전부 무변경.

### 6.3 무변경 보증 (audit)

| 항목 | 상태 |
|------|------|
| 4-factor 가중치 (25/20/20/35 또는 §14.1 20/20/20/20+modifier) | **무변경** |
| ★ 임계 (30/60/90) | **무변경** |
| output signal 값 도메인 (`accuracy_prep ∈ [0,1]` 등) | **무변경** |
| `module_completed(score)` signal contract | **무변경** |
| dish_modules.csv sequence (12 음식) | **무변경** |
| Skip(Rewarded) → auto-perfect 0.9 | **무변경** |
| perfect_width 음식별 12 row (§3.2) | **무변경** (heat zone 폭으로 재해석, 값 동일) |
| BPM/cut style 매핑 (§7.1) | **drag 속도 band 목표값으로 재해석** (수치 동일, 의미만 "자동 칼 BPM" → "손가락 drag 목표 속도") |

**유일 변경**: 입력 gesture (tap/hold/button → drag/tilt/swipe/flick) + 그 gesture의 **품질 → output signal 변환 함수**. 출력 signal 값과 그 이후 모든 계산은 동일.

---

## 7. button/puck → action 전환표 (before / after)

| module | ADR-011 (before, button/puck) | ADR-012 (after, action) | gesture 변경 |
|--------|-------------------------------|-------------------------|--------------|
| **slice** | rhythm tap (자동 칼 위아래 + 도마 닿기 직전 tap) | drag knife through ingredient | tap → **vertical drag** |
| **arrange** | drag/drop snap-to-slot | place into pattern (settle, 색·순서) | snap → **press-drag-release** (정렬 미학) |
| **stir** | tap rhythm (좌/우 박자 tap) | continuous circular swipe (웍/그릇 churn) | tap → **continuous swipe** |
| **flip** | single perfect-window tap | directional flick (swipe-up / rotation) | tap → **directional flick** |
| **timing** | gauge fill + perfect window tap (정지 meter stop) | control stove heat (heat dial 지속 조절) | stop-tap → **vertical drag (heat dial)** |
| **season** | 1-tap auto-pour | tilt seasoning bottle (각도+유지 양 조절) | tap → **tilt + hold** |
| **roll** | swipe motion (좌→우 1회) | roll bamboo mat forward + release timing | simple swipe → **forward drag + release** (압력/타이밍) |
| **plate** | drag/drop + garnish | drag food onto plate + arrange (유지) | **변경 없음** (이미 action 기반) |

> plate는 ADR-011에서 이미 drag-based action이라 input-layer 변경 없음. 나머지 7개가 input redesign 대상 (slice/stir/flip/timing/season은 본질 변경, arrange/roll은 정밀화).

---

## 8. 구현 난이도 estimate (per module, godot-dev)

> 기준: Godot 4.6 GDScript, 터치 input 처리 복잡도 + 물리/애니메이션 부담 + scoring 변환 함수 복잡도. M1 LOCK asset(TOOL 12 / CUT 6 / ingredient whole+cut) 재활용 전제.

| module | 난이도 | 사유 | 신규 input 처리 |
|--------|:------:|------|------------------|
| **slice** | **medium** | drag path → 재료 hitbox 교차 판정 + sprite split anim + cut 위치/속도/개수 3축 scoring. M1 cut sprite 재활용 | `InputEventScreenDrag` path tracking + 교차 판정 |
| **arrange** | **easy** | press-drag-release + slot 근접 settle + 위치 비율 scoring. 물리 없음 | drag + drop zone 근접도 |
| **stir** | **medium** | 연속 circular drag → 회전 누적 감지(각도 적분) + churn 파티클/sprite shuffle + 속도 band. 연속 동작 sampling | drag 각속도 적분 + 끊김 감지 |
| **flip** | **medium** | flick 방향+속도 벡터 추출 + 음식 회전 anim(Transform) + 3-tier 판정. C-3 fallback 분기 | flick velocity vector |
| **timing** | **medium** | heat dial drag → zone 유지율 누적 + 불꽃/끓음 강도 실시간 시각 + overflow 게이지. 지속 입력 sampling | drag value → zone 유지율 적분 |
| **season** | **easy** | tilt 각도(또는 drag 각도) + 유지 시간 → 입자 emit. default는 가벼운 tilt 1회. marinade만 정밀 | tilt 각도 + hold timer |
| **roll** | **medium** | forward drag → 김밥 progressive roll anim(Transform/shader) + 속도 band + release 타이밍. M1 김발 sprite | drag distance + release 시점 |
| **plate** | **easy** | drag + drop 그릇 매칭 + 고명 placement. 기존 ADR-011 그대로 (변경 0) | 기존 drag/drop 유지 |

**난이도 분포**: easy 3 (arrange/season/plate) / medium 5 (slice/stir/flip/timing/roll). hard 0 — 전부 Transform anim + drag sampling 수준, 물리 엔진 불필요.

### 8.1 공통 input 인프라 (godot-dev 선행)

- **TouchGestureRecognizer** 유틸 신설 권고: drag path / tilt 각도 / flick velocity / continuous swipe 각속도를 8 module이 공유. module별 중복 input 코드 회피.
- `module_completed(score: float)` signal은 ADR-011 그대로 유지 — 각 module scene이 action 품질을 §6.1 변환 후 emit.

---

## 9. godot-dev 구현 우선순위 권고

> highest-value 음식/module 우선. value = (음식 reuse 수) × (action 체감 임팩트) × (구현 ROI).

### 9.1 module 우선순위 (음식 reuse × action 임팩트)

| 순위 | module | reuse | 난이도 | 권고 사유 |
|:---:|--------|:---:|:---:|----------|
| **1** | **slice** | **10/12** | medium | 10 음식 사용 — drag-cut 1개 완성 = 10 음식 즉시 action 체감. cut style 6종 = 한식 정체성 핵심. ROI 최고 |
| **2** | **timing** | **11/12** | medium | 11 음식 — heat dial은 "정지 meter stop"보다 체감 차이 극적 ("불 조절했다"). slice 다음 multiply |
| **3** | **plate** | **12/12** | easy | 12 음식 universal + 이미 action 기반(변경 0) = 빠른 완성. terminal sealing |
| **4** | **stir** | 5/12 | medium | continuous swipe = "tap rhythm" 폐기로 사용자 원칙 위배 해소. 5 음식 |
| **5** | **season** | 5/12 | easy | tilt = 빠른 구현. default(시각 only)는 가벼움, marinade(불고기 hero)만 정밀 |
| **6** | **arrange** | 4/12 | easy | 김밥/비빔밥 정렬 미학. plate 차별화 검증 필요 |
| **7** | **flip** | 3/12 | medium | C-3 lock으로 MVP는 fallback. 우선순위 낮음 (post-launch full) |
| **8** | **roll** | 1/12 | medium | 김밥 단독. signature지만 1 음식 — 마지막 |

### 9.2 음식 우선순위 (end-to-end 검증 순서)

| 순위 | 음식 | sequence | 검증 가치 |
|:---:|------|----------|----------|
| **1** | **라면** (t1_002) | slice → timing → season → plate | 최소 4-module 조합, slice+timing+season+plate 4개 P0/P1 module 한 번에 검증. FTUE 첫 음식 |
| **2** | **김치볶음밥** (t1_005) | slice → stir → timing → plate | stir(continuous swipe) 신규 action 첫 검증 |
| **3** | **김밥** (t1_004) | arrange → roll → slice → plate | arrange + roll 신규 정밀 action, slice 재검증. arrange→roll 데이터 연결 |
| **4** | **갈비구이** (t2_012) | slice → season → timing → flip → plate | 5-module + flip + 좁은 heat zone(perfect_width 0.04). 난이도 상한 검증 |
| **5** | **불고기** (t2_014) | season(marinade) → slice → stir → timing → plate | season marinade variant (tilt-massage) hero action 검증 |
| **6+** | 나머지 7 음식 | (sequence reuse) | module 완성 후 sequence row만 추가 (코드 0건) |

**권고 sprint plan** (godot-dev Sprint M3):
- **W1**: 공통 TouchGestureRecognizer + slice(drag-cut) + 라면 end-to-end (slice/timing/season/plate)
- **W2**: timing(heat dial) 정밀 + cut style 6종 drag 변주 확장
- **W3**: stir(continuous swipe) + 김치볶음밥
- **W4**: arrange + roll + 김밥 (arrange→roll 데이터 연결)
- **W5**: season marinade(불고기) + flip(갈비) + alpha 검증

---

## 10. ADR-005 / ADR-007 / ADR-011 정합 (no supersede)

| ADR | 본 문서 영향 |
|-----|-------------|
| **ADR-005** (4-stage meta) | **무변경**. Stage 2A 재료 준비 = slice drag (Knife indicator 자동 tap만 deprecated → 손가락 drag). 가중 평균 공식 무변경. Skip auto-perfect 무변경 |
| **ADR-007** (basic_pantry) | **무변경**. Season default = 양념 자동 제공(가벼운 tilt = auto-pour 대체, 시각 ambience). 양념 "고르기" 행위 X 유지 |
| **ADR-011** (8-module) | **input-layer amendment** (no supersede). 8 module 구성 / sequence / reuse 분포 / scoring 전부 유지. interaction 컬럼만 action-first로 갱신 |

**deprecated (input only)**:
- ADR-005 Knife indicator (자동 칼 위아래 + tap) → slice drag.
- ADR-011 stir "tap rhythm" → continuous swipe.
- ADR-011 flip "single window tap" → directional flick.
- ADR-011 timing "정지 meter perfect tap" → heat dial 지속 조절.

> 이 4개는 **mechanic deprecation 아님 — input gesture만 교체**. output signal·scoring·점수 분포 전부 동일.

---

## 11. Open / Follow-up

| # | 항목 | 책임 | 상태 |
|---|------|------|------|
| 1 | TouchGestureRecognizer 공통 유틸 spec (drag path / tilt / flick / 각속도) | godot-dev | Sprint M3 |
| 2 | slice drag-cut sprite split anim 방식 (shader mask vs 2-piece sprite) | godot-dev + art-director | open |
| 3 | timing heat dial UI 컴포넌트 (다이얼 vs 슬라이더 vs 노브) + overflow 게이지 | ui-designer | open |
| 4 | stir continuous swipe 각속도 → 회전 수 변환 sampling rate (mobile 60fps) | godot-dev | open |
| 5 | flip flick velocity threshold 음식별 band (해물파전 vs 콘도그 vs 갈비) | game-designer + alpha | open |
| 6 | season tilt 각도 입력 — gyro(기기 기울임) vs touch drag 각도? mobile 호환 | godot-dev + ui-designer | open (권고: touch drag 각도, gyro 의존 회피) |
| 7 | roll forward drag 방향 (아래→위 vs 가까이→멀리) FTUE 학습성 | ui-designer | open |
| 8 | arrange vs plate gesture 혼동 방지 FTUE (raw 재료 vs 완성 음식 cue) | ui-designer | open |
| 9 | Remote Config `stir_interaction_mode` 기본값 "tap_rhythm" → "continuous_swipe" 갱신 | game-designer (balance §15.3) | resolved 본 sprint |
| 10 | action-first FTUE 6-step → gesture 학습 step 재설계 | ui-designer | open |

---

## 12. 사용자 verbatim 검증

| 사용자 verbatim | 보장 |
|----------------|------|
| "The player should perform a cooking action. The cooking action itself becomes the gameplay." | 8 module 전부 실제 조리 동작(drag-cut / tilt-pour / circular-stir / flick-flip / heat-control / mat-roll)으로 재설계 (§2~§4) |
| "I added seasoning NOT I pressed ADD" | season = tilt seasoning bottle, 입자 낙하 (§3.6) |
| "I rolled gimbap NOT I held a button" | roll = forward drag bamboo mat + release timing (§3.7) |
| "I cut carrots NOT I tapped a beat" | slice = vertical drag through ingredient, pieces split (§3.1) |
| "I controlled the heat NOT I stopped a meter" | timing = heat dial 지속 조절, overflow 관리 (§3.5) |
| "The mechanic should emerge from the cooking process itself." | score가 action 품질에서 emerge — cut 편차 / heat zone 유지율 / flick 방향 등 (§6) |
| "Never start with What button mechanic. Start with What is the real cooking action." | 8 module 전부 "real action" 컬럼에서 출발 → gesture 도출 (§2 master 표) |

---

## 13. 관련 문서

- [ADR-011](../decisions.md#adr-011) — 8-Module Cooking Pipeline (본 문서가 input-layer amend)
- [ADR-012](../decisions.md#adr-012) — Action-First Cooking Interaction (본 문서의 정식 ADR)
- [cooking-modules-v1.md v1.1](cooking-modules-v1.md) — 8 module 구성·sequence·reuse (interaction 컬럼 action-first cross-ref)
- [cooking-mechanics.md v0.7](cooking-mechanics.md) — 4-stage 룰 + §5.2 가중 평균 공식 (scoring 무변경)
- [balance-config.md v0.7 §15](../balance-config.md) — module BPM/window/threshold + Remote Config 키
- [motion-spec.md v0.1](motion-spec.md) — AnimationPlayer Transform anim (drag follow 통합 참조)
- [data/dish_modules.csv](../../data/dish_modules.csv) — 12 음식 × sequence (무변경)
- ADR-005 (4-stage) — Knife indicator input만 deprecated, meta 무변경
- ADR-007 (basic_pantry) — Season default 정합
