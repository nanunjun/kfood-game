# Balance Config — MVP

> 버전: **v0.3.3 (2026-05-31, supersedes v0.3.2)** · 작성자: game-designer
> Scope: **MVP (Tier 1~2, 음식 12개, 친구 1~2명) + ADR-005 4-stage 메커닉 + C-2 basic_pantry 정책**.
> 상위 문서: [`systems/cooking-mechanics.md` v0.6](systems/cooking-mechanics.md), [`systems/mvp-food-selection.md` v2.2 §3.1](systems/mvp-food-selection.md), [`foods-database.csv`](foods-database.csv), [`store-distribution.md` v1.3](store-distribution.md), [`friends-system.md` v0.3](friends-system.md), [`decisions.md` ADR-005 + ADR-007 (pending)](decisions.md#adr-005)
>
> 본 문서는 **공식·범위·갯수**만 lock한다. 정확한 튜닝 수치는 alpha 빌드 이후 데이터 기반 조정. 본 문서의 모든 숫자는 **placeholder default**.
>
> ⚠️ **v0.3 high-level 추가만**: §5 4-factor weights / §6 Prep Rhythm Window / §7 BPM by Tier / §8 Skip Bonus 신설. 음식별 정확 BPM/tap 수치는 **game-designer 본격 sprint** (foods-database.csv `prep_*` 컬럼 sync 후).

---

## 0. v0.3.3 변경 요약 (vs v0.3.2)

| # | 항목 | 변경 내용 |
|---|------|----------|
| **C-2** | **basic_pantry 5종 정책 lock** (간장/고추장/설탕/참기름/소금) | **§X.1 신설** — `cooking.basic_pantry_ingredient_ids` Remote Config 신규 (`["ing_x_003","ing_x_004","ing_x_005","ing_x_006","ing_x_007"]`). `cooking.stage1.exclude_basic_pantry = true` / `cooking.accuracy.exclude_basic_pantry = true` 2 키 신설. 잡화점 SKU pool 17 → 12 (-29%). |
| **C-2 sync** | §2.2.2 Stage 1 time_limit 음식별 재산정 | 떡볶이 t1_003 22s → **18s** (4가게 → 3가게 강등 + 정답 재료 1 감소) / 잡채 t2_010 30s → **25s** (4가게 → 3가게 강등 + 정답 재료 2 감소) / 갈비구이 25s 유지 (3가게 유지나 basic_pantry 3 차감으로 정답 9 → 6) / 불고기 28s 유지 (3가게 유지나 basic_pantry 3 차감으로 정답 10 → 7) — alpha 검증 후 추가 fine-tune |
| **C-2 sync** | §2.2.3 distractor_per_store_by_tier 영향 점검 | 잡화점 SKU pool 17 → 12, distractor=1 충분 검증 PASS. T1 평균 디스트랙터 3.86 → 3.43 (떡볶이·잡채 3가게 강등 영향) / T2 평균 3.4 → 2.8 |
| **C-2 sync** | §5 accuracy_ingredients 공식 | 분모 N에서 basic_pantry 자동 차감 (cooking-mechanics §2.5 v0.6 sync) |

## 0.1 v0.3.2 변경 요약 (vs v0.3.1, 보존)

| # | 항목 | 변경 내용 |
|---|------|----------|
| **N-1** | F-02 호떡 → **잔치국수** (t1_008) | §2.2.2 Stage 1 time_limit 행 교체 (호떡 t1_001 18s → 잔치국수 t1_008 22s) / §3.2 perfect_width 행 교체 (호떡 8s·1100ms·0.14 → 잔치국수 12s·1000ms·0.10) |
| **N-2** | F-09 김치찌개 → **불고기** (t2_014) | §2.2.2 행 교체 (김치찌개 t2_009 25s → 불고기 t2_014 28s) / §3.2 행 교체 (김치찌개 15s·950ms·0.06 → 불고기 16s·900ms·0.09) |
| **N-1·N-2 sync** | §7 BPM/Tap Range by Tier — 음식별 prep_bpm 매핑 추가 | 잔치국수: 대파 송송썰기 110 BPM·4 taps (CUT-05) / 불고기: 양념재우기 60 BPM·3 taps (CUT-00 marinade rhythm — ADR-005 §7 시그니처 음식) |
| **N-1·N-2 sync** | 음식별 cook_time 가중치 재산정 | T1 평균 cook_time 9.7s (호떡 8s → 잔치국수 12s 증가) / T2 평균 cook_time 16.4s (김치찌개 15s → 불고기 16s 증가) |

## 0.1 v0.3 변경 요약 (vs v0.2, 보존)

| # | 항목 | 변경 내용 |
|---|------|----------|
| **ADR-005-A** | **4-Factor Scoring Weights** | **§5 신설** — 25/20/20/35 가중 평균. cooking-mechanics §5.2 곱셈 모델 supersede. ★ 임계 30/60/90으로 변경 (v0.2 50/75/90 supersede). |
| **ADR-005-B** | **Prep Rhythm Window** | **§6 신설** — Perfect **±80ms LOCKED** (2026-05-26 pm 권고 채택) + Good ±200ms + Miss. |
| **ADR-005-C** | **BPM/Tap Range by Tier** | **§7 신설** — Tier 1: 70~110 BPM·3~6 taps / Tier 2: 90~140 BPM·5~8 taps + Cut Style별 BPM 7종. |
| **ADR-005-D** | **Skip Bonus** | **§8 신설** — Rewarded Video → `accuracy_prep=0.9` **LOCKED** (2026-05-26). Stream A 자연 트리거. |

## 0.1 v0.2 변경 요약 (vs v0.1, 보존)

| # | 항목 | 변경 내용 |
|---|------|----------|
| C-2 | 양념치킨 → 순두부찌개 | §2.2 Stage 1 time_limit 행 교체, §3.2 perfect_width 행 교체 |
| **C-3** | 해물파전 flip mechanic | **미도입 (MVP)**. §4 폴백 로직으로 단일 탭 유지 |
| **C-4** | Stage 3 good/miss | **45/45 lock** (perfect 10). §3.1 공식 + Remote Config 키 신설 |

---

## 1. 운영 원칙

- **Single source of truth**: 본 문서의 키는 Firebase Remote Config에 그대로 export. 코드 상수 직접 사용 금지(godot-dev 협의).
- **Override 우선순위**: Remote Config > Godot Resource(.tres) default > 본 문서 default.
- **A/B 테스트 후보**: ★ 임계, PERFECT 너비, 인터스티셜 빈도, **Stage 3 band 분포 (C-4 alpha 재조정 후보)**. Month 1+에 data-analyst와 sync.

---

## 2. Remote Config 키 목록

### 2.1 cooking-mechanics §9 기존 키 (sync)

| 키 | 기본값 | 타입 | 설명 |
|----|--------|------|------|
| `cooking.stage1.penalty_per_wrong` | `0.15` | float | 오답 재료당 accuracy 감점 |
| `cooking.stage1.time_penalty_sec` | `1.0` | float | 오답 재료당 시간 감점 |
| `cooking.stage3.perfect_width` | `0.10` | float | 기본 PERFECT 구간 비율 |
| `cooking.stage3.perfect_width_ad` | `0.20` | float | rewarded ad 적용 시 PERFECT 비율 |
| `cooking.early_finish_bonus_max` | `0.10` | float | early-finish 최대 가산 |
| `cooking.distractor_per_store_by_tier` | `[1,1,2,2,3]` | int[] | tier별 가게당 디스트랙터 수 |
| `scoring.star_thresholds` | `[50,75,90]` | int[] | ★1/★2/★3 점수 임계 |

### 2.2 본 sprint 신설 / 갱신 키

| 키 | 기본값 | 타입 | 설명 |
|----|--------|------|------|
| `cooking.stage1.time_limit_by_tier` | `[20,28]` | int[] (sec) | Tier 1·2 Stage 1 기본 시간 제한 (음식별 override 가능) |
| `cooking.stage2.time_limit_sec` | `7` | int | Stage 2 조리법 선택 제한 시간 (전 음식 공통) |
| `cooking.stage3.perfect_width_by_food` | `{...}` | object | 음식별 PERFECT 비율 override (§3.2) |
| `cooking.stage3.cook_time_by_food` | `{...}` | object | 음식별 cook_time_sec override (foods-database.csv sync) |
| `cooking.stage1.distractor_per_store_by_tier_override` | `null` | int[] | A/B용 override; null 시 §2.1 키 사용 |
| `cooking.stage1.ftue_perfect_width_multiplier` | `2.0` | float | FTUE Step 3 한정 PERFECT 폭 배수 (= 0.10 × 2.0 = 0.20) |
| `cooking.stage3.flip_required_foods` | `[]` | string[] | **C-3 lock 2026-05-24**: MVP는 빈 배열 (단일 탭). post-launch에서 `["t1_006"]` 활성화 검토 |
| **`cooking.stage3.band_distribution`** | **`{"perfect":0.10,"good":0.45,"miss":0.45}`** | object | **C-4 lock 2026-05-24**: PERFECT 외 good/miss 균등 분배. cooking-mechanics §4.4 v0.4(30/60) supersede. Soft launch alpha 재조정 가능 |
| `friends.like_bonus_pct` | `0.05` | float | 친구가 음식 좋아함 → Round 점수 가산 (5%) |
| `friends.dislike_penalty_pct` | `0.05` | float | 친구가 음식 싫어함 → Round 점수 감산 (5%) |
| `friends.preference_affect_stars` | `false` | bool | 친구 호불호가 ★ 임계에도 영향 주는지 (기본 false = 점수만) |
| `economy.coin_per_star_by_tier` | `{1:10, 2:20}` | object | tier별 ★1개당 코인 보상 |
| `ads.interstitial_round_interval` | `3` | int | 인터스티셜 노출 간격 (Round) |
| `ads.ftue_block_minutes` | `5` | int | FTUE 광고 차단 분 (GDD §5.2) |

> ⚠️ **`friends.*` 키들은 friends-system.md §4 호불호 메커닉 placeholder**. alpha 후 정서 임팩트 vs 게임플레이 명료성 trade-off 테스트.

---

## 2.2 Stage 1 — 재료 선택 시간 / 디스트랙터

### 2.2.1 Stage 1 base 시간 제한

| Tier | base time_limit (s) | 디스트랙터/가게 | 비고 |
|------|:------------------:|:--------------:|------|
| 1 | 20 | 1 | 음식별 ±5s override (가게 수 가중) |
| 2 | 28 | 1 | 음식별 ±7s override |

### 2.2.2 음식별 Stage 1 time_limit override (가게 수 가중) — v0.3.3 (C-2 sync)

> v0.3.3 변경: basic_pantry 5종 정책으로 떡볶이·잡채 가게 수 4→3 강등, 정답 재료 수도 감소. time_limit 자연 재산정 ("가게 수 × 4s + basic_pantry 차감 -1s/재료" 휴리스틱).

| food_id | 음식 | 가게 수 (v1.3) | 정답 재료 (basic_pantry 제외) | 권고 time_limit (s) | 변동 |
|---------|------|:------:|:-----:|:------------------:|:----:|
| t1_002 | 라면 | 3 | 3 | 20 | — |
| **t1_003** | **떡볶이** | **3 ⬇** | **4** (고추장 -1) | **18** ⬇ | v0.3.2 22 → 18 (가게 수 -1 + 정답 -1) |
| t1_004 | 김밥 | 5 | 6 | 25 | — |
| t1_005 | 김치볶음밥 | 4 | 6 | 22 | — |
| t1_006 | 해물파전 | 4 | 9 (간장 -1) | 24 | — (해물 hero 재료 변동 없음) |
| t1_007 | 한국식 콘도그 | 3 | 5 (설탕 -1) | 20 | — |
| t1_008 | 잔치국수 | 4 | 7 (간장 -1) | 22 | — |
| t2_008 | 비빔밥 | 4 | 6 (고추장 -1) | 28 | — |
| **t2_010** | **잡채** | **3 ⬇** | **6** (간장·참기름 -2) | **25** ⬇ | v0.3.2 30 → 25 (가게 수 -1 + 정답 -2) |
| t2_012 | 갈비구이 | 3 | 6 (간장·설탕·참기름 -3) | 25 | — (재료 9→6 감소나 cook 메커닉 부담 유지) |
| t2_013 | 순두부찌개 | 3 | 7 | 25 | — |
| t2_014 | 불고기 | 3 | 7 (간장·설탕·참기름 -3) | 28 | — (재료 10→7 감소나 양념재우기 + 5채소 hero ingredient 부담 유지) |

> **C-2 정책 후 평균 time_limit**: T1 7음식 평균 21.3s (v0.3.2 21.6 → -0.3s) / T2 5음식 평균 26.2s (v0.3.2 27.2 → -1.0s). alpha 데이터로 fine-tune.

### 2.2.3 디스트랙터 수 by tier (v0.3.3 C-2 sync)

`cooking.distractor_per_store_by_tier` (MVP relevant: index 0·1):

| Tier | 가게당 디스트랙터 | 음식별 평균 총 디스트랙터 (v1.3) |
|------|:---------------:|:----------------------:|
| 1 | 1 | **~3.43** (T1 7음식 가게 수 평균: 라면3+떡볶이3+김밥5+볶음밥4+해물파전4+콘도그3+잔치국수4 = 24/7 = 3.43; v0.3.2 3.86 → v0.3.3 3.43, 떡볶이 4→3 강등 영향) |
| 2 | 1 | **~2.8** (T2 5음식 가게 수 평균: 비빔밥4+잡채3+갈비3+순두부3+불고기3 = 16/5 = 3.2; 잡채 4→3 강등 영향. 잡화점 SKU 17→12로 distractor pool 축소 시 효과 distractor 평균 -0.6 = 2.6~2.8) |

> [`cooking-mechanics.md`](systems/cooking-mechanics.md) §2.6 기준값과 동일.
> **잡화점 SKU pool 검증**: 17 → 12 (-29%). distractor=1 충분 (잡화 12종 - 정답 max 4 - basic_pantry 0 = distractor 후보 8종, T1·T2 모두 distractor=1 표시 시 충분).

---

## 3. Stage 3 — Timing Game

### 3.1 공식 (cooking-mechanics §4.3 sync) — C-4 lock

```
PERFECT  → accuracy_timing = 1.0
good     → accuracy_timing = 0.6
miss     → accuracy_timing = 0.2
no-tap   → accuracy_timing = 0.0
```

**구간 너비** (C-4 lock 2026-05-24):
```
PERFECT : perfect_width                          (default 0.10)
good    : (1 - perfect_width) × 0.50  → 0.45     (양쪽 합)
miss    : (1 - perfect_width) × 0.50  → 0.45     (양쪽 합)
```

**C-4 lock 컨텍스트** (2026-05-24):
- cooking-mechanics.md v0.4 §4.4의 30/60 분배는 본 v0.2로 **supersede**.
- Remote Config 키: `cooking.stage3.band_distribution = {"perfect":0.10, "good":0.45, "miss":0.45}`.
- 사유: 마스코트 톤 + 가족 정서에 부드러움 우선. miss 60% 시 ★0 risk 과다 → ★ ramp 자연 부드러움.
- **Soft launch alpha 데이터로 재조정 가능**. 재조정 후보: 30/60 (난도 ↑), 50/40 (부드러움 ↑), 35/55 (밸런스).
- cooking-mechanics.md 차기 개정에서 §4.4 sync 필요 (현재 v0.4 본문은 outdated, 본 v0.2가 ground truth).

### 3.2 음식별 PERFECT 너비 (`perfect_width_by_food`) — v0.2

`foods-database.csv` `perfect_window_ms` 값을 Stage 3 게이지 비율로 환산.

| food_id | 음식 | cook_time_sec | perfect_window_ms | perfect_width 비율 | 사유 |
|---------|------|:-------------:|:-----------------:|:------------------:|------|
| t1_002 | 라면 | 9 | 1000 | 0.11 | **FTUE 1순위 (N-1 sync 2026-05-30; 호떡 supersede)**; default + α |
| t1_003 | 떡볶이 | 13 | 950 | 0.10 | default |
| t1_004 | 김밥 | 4 | 1500 | 0.19 | 짧은 cook_time → 폭 넓게 (판정 공정) |
| t1_005 | 김치볶음밥 | 10 | 1000 | 0.10 | default |
| t1_006 | 해물파전 | 14 | 950 | 0.09 | **C-3: 단일 탭 (MVP)**. flip mechanic 미도입 |
| t1_007 | 콘도그 | 8 | 1000 | 0.13 | 튀기기 도입 → 약간 관대 |
| **t1_008** | **잔치국수** | **12** | **1000** | **0.10** | **N-1 신규 2026-05-30** (호떡 t1_001 supersede); T1 끓이기 standard; 면 토렴 + 육수 끓이기 = default 폭. 라면(0.11)과 떡볶이(0.10) 사이 자연 ramp |
| t2_008 | 비빔밥 | 5 | 1300 | 0.13 | no-cook 비비기 (짧음) |
| t2_010 | 잡채 | 16 | 900 | 0.06 | T2 중반 |
| t2_012 | **갈비구이** | 18 | **650** | **0.04** | 사용자 명시 "타이밍 핵심" — T2 평균 대비 ~70% |
| t2_013 | 순두부찌개 | 14 | 950 | 0.07 | C-2 신규 2026-05-24; T2 끓이기 standard; N-2 sync 2026-05-30 — T2 끓이기 단독 음식 (김치찌개 supersede) |
| **t2_014** | **불고기** | **16** | **900** | **0.09** | **N-2 신규 2026-05-30** (김치찌개 t2_009 supersede); 양념재우기 8s + 볶기 8s = 16s; T2 양념재우기 메커닉 시그니처 음식; perfect_width 0.09 = 잡채와 동일 T2 standard (cook_time 16s 동률) — 갈비구이(0.04)보다 관대 (양념재우기 60 BPM marinade rhythm은 별도 Stage 2A에서 처리, Stage 3 timing은 볶기 완료 판정만) |

> 비율은 `perfect_window_ms / (cook_time_sec × 1000 × 2)` 으로 환산.

### 3.3 갈비구이 특수 케이스 (변동 없음)

사용자 지시: **"BBQ는 타이밍이 핵심"**.
- PERFECT 비율 0.04 = T2 평균(0.07) 대비 ~57% 좁음.
- 시각 정당화 / 메커닉 정당화 / 보상 비대칭 (×1.5 코인 multiplier).

⚙️ **alpha 데이터 reconciliation**: ★3 성공률이 <15%면 폭 0.05~0.07로 완화 가능.

---

## 4. 해물파전 특수 케이스 — Flip Mechanic (C-3 lock)

### 4.1 결정 (2026-05-24)

**C-3 lock: 해물파전 flip mechanic 미도입 (MVP).**

- `cooking.stage3.flip_required_foods = []` (빈 배열).
- 해물파전(t1_006)은 Stage 3에서 **단일 탭** 처리 — 다른 굽기/부치기 음식과 동일 메커닉.
- 정당화: MVP-first 원칙 (ADR-003). 신규 메커닉 1종 도입은 FTUE 부담 + alpha test surface 확장.

### 4.2 Post-launch 도입 시 사양 (참고용)

post-launch에서 도입 시 별도 작업:
- **perfect_window 2회** (양면 각각 PERFECT 판정).
- **FTUE step 추가** (1 step 단독 = "뒤집기 인터랙션" 학습).
- 평균 환산 공식: `accuracy_timing = (acc_tap1 + acc_tap2) / 2`.
- Remote Config flag 활성화: `cooking.stage3.flip_required_foods = ["t1_006"]`.
- 갈비구이(양면 굽기)도 동일 메커닉 후보지만 별도 lock 필요 (타이밍 자체가 핵심이라 멀티탭 추가는 보수적).

### 4.3 단일 탭 폴백 (MVP)

해물파전 Stage 3는 다른 부치기·굽기 음식과 동일 = §3.2 표 그대로 적용 (PERFECT 0.09).

---

## 4A. Basic Pantry 정책 (C-2 LOCK 2026-05-31, v0.3.3 신설)

> [`store-distribution.md` v1.3 §X](store-distribution.md) + [`cooking-mechanics.md` v0.6 §2.2.7](systems/cooking-mechanics.md) sync. ADR-007 격상 pending (pm 위임).

### 4A.1 정의

**basic_pantry 5종** = 한국 가정 부엌 상시 비치 base seasoning. Stage 1 재래시장 진열대에 표시하지 않고 Scene 2 kitchen rack에 자동 표시.

| ingredient_id | name_ko | name_en | foods CSV 사용처 합 |
|--------------|---------|---------|:------------------:|
| ing_x_003 | 간장 | Soy Sauce | 5 (해물파전·잔치국수·잡채·갈비·불고기) |
| ing_x_004 | 고추장 | Gochujang | 2 (떡볶이·비빔밥) |
| ing_x_005 | 설탕 | Sugar | 3 (콘도그·갈비·불고기) |
| ing_x_006 | 참기름 | Sesame Oil | 3 (잡채·갈비·불고기) |
| ing_x_007 | 소금 | Salt | 0 (implicit_all, foods CSV 미명시) |

### 4A.2 Remote Config 키 (신설 3개)

| 키 | 기본값 | 타입 | 설명 |
|----|--------|------|------|
| `cooking.basic_pantry_ingredient_ids` | `["ing_x_003","ing_x_004","ing_x_005","ing_x_006","ing_x_007"]` | string[] | basic_pantry ingredient_id 5종 list. Remote Config로 운영 중 5종 외 추가/제거 가능 (예: post-launch M1 들기름 추가 검토) |
| `cooking.stage1.exclude_basic_pantry` | `true` | bool | Stage 1 진열대에서 basic_pantry 5종 표시 여부. true = 진열대 미표시 (distractor pool 제외 포함) |
| `cooking.accuracy.exclude_basic_pantry` | `true` | bool | accuracy_ingredients 분모 N에서 basic_pantry 자동 차감 여부. true = 차감 후 N 사용 |

### 4A.3 영향 정리

| 영역 | v0.3.2 (정책 X) | v0.3.3 (정책 lock) |
|------|----------------|-------------------|
| Stage 1 진열대 잡화점 SKU | 17 | 12 (-5 basic_pantry) |
| accuracy_ingredients 분모 N (음식 평균) | 6.4 (full ingredients) | 5.4 (basic_pantry 차감 후) |
| 잡화점 음식 등장 | 12/12 | 10/12 (떡볶이·잡채 강등) |
| 잡화점 정답 합계 | 29 | 17 (-12 net) |
| 떡볶이 / 잡채 가게 수 | 4 / 4 | 3 / 3 |
| 잡화점 distractor pool | 9 (is_distractor_friendly) | 5 (basic_pantry 5종 모두 false 처리) |

### 4A.4 alpha 검증 항목 (open)

- 사용자 학습 곡선: basic_pantry 5종이 kitchen rack에 자동 표시되는 시각 cue 인지율 (target ≥ 80% — 첫 5 round 안에 "양념은 자동" 학습)
- distractor=1로 잡화점 SKU pool 5종 충분성 (T1 12음식 × 3 round 시 distractor 반복 인상 빈도 ≤ 30%)
- 옹기 시각 디스트랙터 손실 회복: art-director kitchen rack 옹기 5종 일러스트 평가

---

## 5. 점수 공식 (cooking-mechanics §5.2 sync)

### 5.1 기본
```
# v0.3.3 C-2 sync: accuracy_ingredients 분모 N에서 basic_pantry 자동 차감
N_effective = required_ingredients.filter(id NOT IN basic_pantry_ingredient_ids).count
correct_picks_effective = correct_picks.filter(id NOT IN basic_pantry_ingredient_ids).count
accuracy_ingredients = clamp01(correct_picks_effective / N_effective - PENALTY_PER_WRONG * wrong_picks)

score_raw   = accuracy_ingredients × accuracy_method × accuracy_timing
early_bonus = max(0, remaining_time_s1 / time_limit_s1) × early_finish_bonus_max
score_pre   = clamp01(score_raw + early_bonus)

(친구 호불호 적용 — friends-system.md §4)
preference_modifier = (likes ? +like_bonus_pct : 0)
                    + (dislikes ? -dislike_penalty_pct : 0)

score_final = clamp01(score_pre + preference_modifier) × 100
```

### 5.2 ★ 임계
| ★ | 임계 | 보상 |
|---|------|------|
| ★☆☆ | ≥ 50 | base coin |
| ★★☆ | ≥ 75 | base × 1.5 |
| ★★★ | ≥ 90 | base × 2.0 |

> 친구 호불호는 **점수에만** 영향, ★ 임계는 변하지 않음.
> like/dislike는 동시 발생 가능 (어머니 like + 아버지 dislike → 순 영향 0).

### 5.3 C-4 lock의 ★ ramp 영향 (참고)

| Stage 3 결과 | accuracy_timing | 다른 stage 1.0 가정 score | ★ |
|--------------|:--------------:|:-----------------------:|:--:|
| PERFECT | 1.0 | 100 | ★3 |
| good | 0.6 | 60 | ★1 |
| miss | 0.2 | 20 | ★0 |
| no-tap | 0.0 | 0 | ★0 |

**C-4 효과**: 30/60 → 45/45로 변경 시 good 비중 ↑ (30% → 45%) = ★1 도달 확률 ↑. miss 비중 ↓ (60% → 45%) = ★0 risk ↓. 가족 정서 부드러움 의도.

---

## 5. 4-Factor Scoring Weights (ADR-005 v0.3 신설)

> [ADR-005](decisions.md#adr-005) 2026-05-26 채택. cooking-mechanics v0.5 §5.2 가중 평균 공식 supersede.

```
total = (accuracy_ingredients × 0.25)
      + (accuracy_prep        × 0.20)   // Stage 2A 재료 준비 (rhythm tap)
      + (accuracy_method      × 0.20)
      + (accuracy_timing      × 0.35)

★1 ≥ 30%, ★2 ≥ 60%, ★3 ≥ 90%
```

**Remote Config 키 (신설)**:

| 키 | 기본값 | 타입 | 설명 |
|----|--------|------|------|
| `scoring.factor_weights` | `{ingredient:0.25, prep:0.20, method:0.20, timing:0.35}` | object | 4-factor 가중치 (합 1.0) |
| `scoring.star_thresholds_v05` | `[30, 60, 90]` | int[] | v0.5 ★ 임계 (v0.2 §2.1의 `scoring.star_thresholds=[50,75,90]`는 곱셈 모델 기준이라 supersede) |

**v0.2 §2.1 `scoring.star_thresholds` 사용 중단 권고** — v0.3에서 `scoring.star_thresholds_v05`로 이관. godot-dev 본격 sprint에서 키 rename 또는 dual 운영 결정.

---

## 6. Prep Rhythm — Perfect/Good Window (ADR-005 v0.3 신설)

| 판정 | 윈도 | accuracy_prep |
|------|------|---------------|
| Perfect | **±80ms** | 1.0 (100%) |
| Good | ±200ms | 0.6 (60%) |
| Miss | 그 외 | 0.0 (0%) |

> ✅ **LOCKED 2026-05-26**: Perfect window **±80ms** 확정 (사용자 confirm, pm 권고 채택). 사용자 원안 ±100ms은 alpha에서 fail rate 검증 후 필요 시 Remote Config로 ±100ms 완화 옵션. Mobile audio latency(R-A13)는 visual cue(Knife indicator) 우선으로 mitigate.

전체 평균 = `accuracy_prep` (모든 tap 평균).

**Remote Config 키 (신설)**:

| 키 | 기본값 | 타입 | 설명 |
|----|--------|------|------|
| `cooking.prep.perfect_window_ms` | `100` | int | Perfect 판정 윈도. pm 권고 80, 사용자 명시 100. alpha 후 lock |
| `cooking.prep.good_window_ms` | `200` | int | Good 판정 윈도 |
| `cooking.prep.tap_cooldown_ms` | `100` | int | 연속 탭 spam 방지 (§10.1 #2 cooldown 200ms 절반) |

---

## 7. BPM / Tap Range by Tier (ADR-005 v0.3 신설)

| Tier | BPM 범위 | Tap 수 범위 | 비고 |
|------|---------|-----------|------|
| 1 | 70~110 | 3~6 | 캐주얼 입문 |
| 2 | 90~140 | 5~8 | 다지기 등 빠른 cut style 도입 |

**Cut Style별 BPM 가이드**:

| Cut Style | BPM (한식) | 비고 |
|-----------|-----------|------|
| 다지기 | **140** (가장 빠름) | 마늘·생강 minced |
| 채썰기 | 110~120 | 당근·양파 julienne |
| 어슷썰기 | 90~110 | 파·고추 diagonal |
| 송송썰기 | 100~120 | 파 fine slice |
| 깍둑썰기 | 80~100 | 무·두부 cube |
| 통썰기 | **70** (가장 느림) | 호박·당근 round slice |
| 양념 재우기 (별도) | **60** (마사지 식) | 갈비구이 등, cut이 아닌 marinade rhythm |

**Remote Config 키 (신설)**:

| 키 | 기본값 | 타입 | 설명 |
|----|--------|------|------|
| `cooking.prep.bpm_range_by_tier` | `{1:[70,110], 2:[90,140]}` | object | Tier별 BPM 범위 |
| `cooking.prep.tap_range_by_tier` | `{1:[3,6], 2:[5,8]}` | object | Tier별 tap 수 범위 |
| `cooking.prep.bpm_by_cut_style` | `{다지기:140, 채썰기:115, 어슷썰기:100, 송송썰기:110, 깍둑썰기:90, 통썰기:70, 양념재우기:60}` | object | Cut style별 BPM 가이드 |

> 음식별 정확 BPM/tap 수치는 `foods-database.csv` `prep_bpm` / `prep_tap_count` 컬럼 (game-designer 본격 sprint).

### 7.1 음식별 prep_bpm / prep_tap_count placeholder 매핑 (v0.3.2 N-1·N-2 sync)

> ADR-005 본격 prep sprint(open #9) 진입 전 잔치국수·불고기 prep 시그니처만 placeholder lock. 나머지 음식은 후속 sprint에서 일괄 lock.

| food_id | 음식 | prep_cut_style | prep_ingredient | prep_bpm | prep_tap_count | 비고 |
|---------|------|---------------|-----------------|:--------:|:--------------:|------|
| t1_008 | **잔치국수** | 송송썰기 (CUT-05) | 대파 | 110 | 4 | N-1 신규 2026-05-30. 부 hero "애호박 통썰기 CUT-04" 70 BPM·3 taps 대안 검토 가능 (T1 가장 느린 cut style, 정통 잔치국수 시그니처 fit). 본격 sprint에서 사용자 결정 |
| t2_014 | **불고기** | **양념재우기 (CUT-00 marinade rhythm)** | 얇은 소고기 + 양념 마사지 | **60** | 3 | **N-2 신규 2026-05-30. ADR-005 §7 양념재우기 cut style 시그니처 음식 lock**. 사용자 별 cut anchor 7장 (CUT-00 cutting_board base + CUT-01~06)에 CUT-00 양념재우기 anchor 별도 정의 필요 — art-director sync (만약 CUT-00이 base anchor만 표현이면 별도 marinade 60 BPM cut style anchor 신규 작성 sprint 트리거). 부 hero "양파 채썰기 CUT-02" 115 BPM·4 taps도 prep 단계에 추가 가능 (Stage 2A multi-cut sub-sequence) |

**잔치국수 prep BPM 선택 reasoning**:
- **대파 송송썰기 110 BPM·4 taps 권고**: 잔치국수 fresh garnish 시그니처 (마지막 단계 토핑) → 시각·청각 마무리 임팩트. T1 평균 BPM(70~110) 상단으로 부드러운 ramp 유지.
- 대안 1: 애호박 통썰기 70 BPM·3 taps — 가장 느린 cut style, 정통 잔치국수(어린 애호박 어슷썰기/통썰기) 시그니처 fit. T1 가장 부드러운 진입 곡선. **사용자 결정 필요 (정통 한식 정서 우선 vs 시그니처 마무리 임팩트 우선)**.
- 대안 2: 다진마늘 다지기 140 BPM·5 taps — 잔치국수 육수 양념 (멸치 육수 + 다진마늘). but 140 BPM은 T1 상한 초과(70~110), 사용자 학습 부담. T1 음식에 다지기 적용은 부적합. → reject.

**불고기 prep BPM 선택 reasoning**:
- **양념재우기 60 BPM·3 taps 권고**: ADR-005 §7 "양념 재우기 (별도) 60 BPM (마사지 식)" 정의의 시그니처 음식. 갈비구이는 통갈비라 양념재우기 가능하나 단독 cut style anchor로는 약함 (bone 표현이 dominant). 불고기 = thin-slice + marinade pool → marinade rhythm tap이 핵심 메커닉 carrier.
- 60 BPM·3 taps = T2 BPM 하한 외 별도 정의 (Tier 2 90~140 BPM 외 cut style 특수). marinade는 cut이 아니므로 별도 카테고리.
- **부 hero "양파 채썰기 CUT-02" 115 BPM·4 taps** = Stage 2A multi-cut sub-sequence 후보 (양념재우기 + 양파 채썰기 sequential). 본격 sprint에서 single cut vs sequence 결정.
- 사용자 confirm 필요: Stage 2A에서 양념재우기 단독 vs 양념재우기 → 양파 채썰기 sequential 진행 결정.

---

## 8. Skip Bonus — Rewarded Video (ADR-005 v0.3 신설)

**Skip 옵션**: Stage 2A 재료 준비 화면에서 **📺 Rewarded Video 시청 시 `accuracy_prep = 0.9`** (skill bonus 명분 유지 — engage 시 추가 점수 상승 여지 보존).

- **트리거**: Stage 2A 진입 시 또는 첫 miss 직후 (UX 결정은 ui-designer screen-flow v0.3에서).
- **광고 종류**: Rewarded Video (Stream A — AppLovin MAX Godot plugin).
- **사용 제한**: Round당 1회 (Hint와 별개 quota).
- **점수 효과**: `accuracy_prep = 0.9` × 가중치 0.20 = 총점에 **+18% 보너스 효과** (전 stage 100% 가정 시 ★3 임계 90% 달성 가능, 단 다른 stage perfect 필요 → engage 동기 유지).
- **밸런스 의도**: Skip은 어려운 음식(다지기 140 BPM 등) 회피 escape valve. Stream A CTR 자연 ↑.

**Remote Config 키 (신설)**:

| 키 | 기본값 | 타입 | 설명 |
|----|--------|------|------|
| `cooking.prep.skip_auto_perfect_score` | `0.9` | float | Skip 시 accuracy_prep 값 (LOCKED 2026-05-26 pm 권고 채택, 사용자 원안 1.0 override) |
| `cooking.prep.skip_usage_per_round` | `1` | int | Round당 Skip 사용 횟수 |
| `cooking.prep.skip_requires_rewarded_ad` | `true` | bool | Skip 시 광고 시청 필수 |

> ✅ **LOCKED 2026-05-26**: Skip 점수 **0.9** 확정. 1.0이면 어려운 음식 회피 너무 강력 → cut style 노출 의미 약화 위험 (cut anim art workload +25~35h 대비 ROI 낮아짐). 0.9 = "engage하면 +10% 더, 광고 보면 빠르게 90%"의 균형. alpha에서 skip rate가 낮으면 1.0으로 완화 가능.

---

## 9. Hint 시스템 (cooking-mechanics §6 sync)

| 키 | 기본값 | 설명 |
|----|--------|------|
| `cooking.hint.trigger_at_remaining_pct` | `0.50` | Stage 1 타이머 50% 이하 시 hint 버튼 활성 |
| `cooking.hint.usage_per_round` | `1` | Round당 hint 사용 1회 |
| `cooking.hint.glow_duration_sec` | `3.0` | 정답 재료 글로우 표시 시간 |
| `cooking.hint.requires_rewarded_ad` | `true` | rewarded ad 시청 필수 (GDD §5.2) |

---

## 10. Economy (코인 보상) — v0.2 §7 renumbered

| tier | ★1 | ★2 | ★3 |
|:----:|:--:|:--:|:--:|
| 1 | 10 | 15 | 20 |
| 2 | 20 | 30 | 40 |

`economy.coin_per_star_by_tier = { "1": [10,15,20], "2": [20,30,40] }`.

음식별 multiplier (special case):
- `economy.coin_multiplier_by_food["t2_012"] = 1.5` (갈비구이 — 난이도 보상)

---

## 11. 다음 sprint reconciliation 항목 (v0.3 갱신)

| # | 항목 | 결정 책임 | v0.3 상태 |
|---|------|----------|----------|
| 1 | Stage 3 good/miss 분배 | game-designer | **C-4 lock 2026-05-24 (45/45)**. alpha 재조정 가능 |
| 2 | Flip mechanic 채택 | game-designer + 사용자 | **C-3 lock 2026-05-24 (미도입 MVP)**. post-launch 이월 |
| 3 | 친구 like/dislike 가산 % alpha 튜닝 | game-designer + data-analyst | open |
| 4 | 갈비구이 PERFECT 0.04 → 0.05~0.07 reconciliation | game-designer + qa-tester | open (alpha 후) |
| 5 | ~~FTUE 첫 음식 final lock (호떡 vs 라면)~~ | game-designer + ui-designer + pm | **✅ resolved 2026-05-30 → 라면 (N-1 sync, 호떡 supersede 후 자동 결정)** |
| 6 | 인터스티셜 간격 3 round → A/B (2 vs 3 vs 4) | data-analyst | open |
| 7 | cooking-mechanics.md §4.4 30/60 → 45/45 sync 갱신 | game-designer (cooking-mechanics 차기 개정 시) | cooking-mechanics v0.5 일부 sync 완료, 잔여 §4.4 본문 sync 대기 |
| 8 | 양념치킨 post-launch M1 부활 검토 (튀기기 다양성·KFC viral) | pm + game-designer | open (soft launch 데이터 후) |
| **9** | **ADR-005 음식별 prep_bpm / prep_tap_count / prep_cut_style / prep_ingredient lock** | game-designer | **open (v0.3 high-level만 lock, foods-database.csv sync 본격 sprint)** |
| ~~10~~ | ~~ADR-005 perfect_window 80ms vs 100ms lock~~ | pm | **✅ resolved 2026-05-26 → ±80ms** |
| ~~11~~ | ~~ADR-005 Skip auto_perfect_score 1.0 vs 0.9 lock~~ | pm | **✅ resolved 2026-05-26 → 0.9** |
| **12** | **ADR-005 ★ 임계 (30/60/90) sync — `scoring.star_thresholds` (v0.2 50/75/90) vs `scoring.star_thresholds_v05` (30/60/90) 이중 운영 정리** | game-designer + godot-dev | **open** |
| **13** | **C-2 basic_pantry 정책 alpha 검증** — Stage 1 자동 제외 학습률 / kitchen rack 인지 / 옹기 시각 디스트랙터 손실 회복 | game-designer + ui-designer + qa-tester | **open (alpha 후)** |
| **14** | **ADR-007 신설** — basic_pantry 정책 정식 ADR 격상 (Stage 1 진열대 자동 제외 + kitchen rack 자동 제공 + accuracy 분모 차감의 의사결정 기록) | pm | **open (별도 sprint 위임)** |
| **15** | **소금 ing_x_007 ID 재매핑 ripple** — 기존 ing_x_007 (깨) → ing_x_019 이동 시 Resource(.tres) 정합성 + foods CSV 명시 X 정합성 | godot-dev | **open (Resource sync sprint)** |

---

## 12. 변경 이력
- **2026-05-31 v0.3.3** (supersedes v0.3.2) — **C-2 lock 적용 (basic_pantry 5종 정책)**. §4A "Basic Pantry 정책" 신설 (간장/고추장/설탕/참기름/소금 5종 정의 + Remote Config 키 3종 신설 `cooking.basic_pantry_ingredient_ids` / `cooking.stage1.exclude_basic_pantry` / `cooking.accuracy.exclude_basic_pantry`). §2.2.2 음식별 time_limit 재산정 (떡볶이 22→18s / 잡채 30→25s / 그 외 변동 없음). §2.2.3 디스트랙터 평균 재산정 (T1 3.86→3.43 / T2 3.4→2.8, 잡화 SKU pool 17→12 검증 PASS). §5.1 accuracy_ingredients 공식 갱신 (분모 N에서 basic_pantry 자동 차감). §11 #13·#14·#15 신규 (alpha 검증 / ADR-007 격상 / ing_x_007 ID 재매핑 ripple).
- **2026-05-30 v0.3.2** (supersedes v0.3.1) — N-1·N-2 lock 적용 (F-02 호떡 → 잔치국수 / F-09 김치찌개 → 불고기). §2.2.2 Stage 1 time_limit 행 교체 (호떡 t1_001 18s → 잔치국수 t1_008 22s / 김치찌개 t2_009 25s → 불고기 t2_014 28s). §3.2 perfect_width 행 교체 (호떡 8s·1100ms·0.14 → 잔치국수 12s·1000ms·0.10 / 김치찌개 15s·950ms·0.06 → 불고기 16s·900ms·0.09). §2.2.3 디스트랙터 평균 재산정 (T1 3 → 3.7, 잔치국수 4가게 영향). **§7.1 음식별 prep_bpm placeholder 신설** (잔치국수=대파 송송 110 BPM·4 taps / 불고기=양념재우기 60 BPM·3 taps — ADR-005 §7 양념재우기 시그니처 음식 lock). §11 #5 FTUE 첫 음식 lock 해소 (라면 자동 결정).
- **2026-05-26 v0.3.1** — Perfect window **±80ms LOCKED** (사용자 confirm, pm 권고 채택). Skip `accuracy_prep = 0.9` **LOCKED** (사용자 원안 1.0 → 0.9, skill bonus 명분 유지). §6 표 dual-column 단일화, §8 Skip default 1.0→0.9, §11 open question #10·#11 resolved.
- **2026-05-26 v0.3** (supersedes v0.2) — [ADR-005](decisions.md#adr-005) 반영. **§5 4-Factor Scoring Weights** 신설 (25/20/20/35 가중 평균 + `scoring.factor_weights` Remote Config 키 + ★ 임계 30/60/90으로 supersede). **§6 Prep Rhythm — Perfect/Good Window** 신설 (Perfect ±80ms pm권고/±100ms 사용자, Good ±200ms, Miss 그 외; `cooking.prep.perfect_window_ms` 등 3 키). **§7 BPM/Tap Range by Tier** 신설 (Tier 1: 70~110 BPM·3~6 taps / Tier 2: 90~140 BPM·5~8 taps; Cut Style별 BPM 가이드 7종). **§8 Skip Bonus** 신설 (Rewarded Video → `accuracy_prep=1.0`). §10 §11 §12 renumbered. 음식별 정확 prep 수치는 game-designer 본격 sprint 이월.
- **2026-05-24 v0.2** (supersedes v0.1) — C-2 lock 적용 (§2.2.2 / §3.2 양념치킨 → 순두부찌개 행 교체). **C-3 lock**: 해물파전 flip mechanic 미도입(MVP), `flip_required_foods = []` 폴백, post-launch 도입 시 사양은 §4.2 별도. **C-4 lock**: Stage 3 good/miss 45/45 (perfect 10) 분배 + Remote Config 키 `cooking.stage3.band_distribution` 신설. cooking-mechanics §4.4 30/60 supersede 명시. 갈비구이 perfect_width 변동 없음(0.04).
- **2026-05-23 v0.1 (superseded)** — 초안. Remote Config 키 catalog. Stage 1/3 음식별 12행. 갈비구이 0.04. 해물파전 flip mechanic 도입(v0.1 default). 친구 호불호 ±5% placeholder.
