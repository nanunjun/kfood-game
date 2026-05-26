# Balance Config — MVP

> 버전: **v0.2 (2026-05-24, supersedes v0.1)** · 작성자: game-designer
> Scope: **MVP (Tier 1~2, 음식 12개, 친구 1~2명)**.
> 상위 문서: [`systems/cooking-mechanics.md` §9](systems/cooking-mechanics.md), [`systems/mvp-food-selection.md` v2.1 §3.1](systems/mvp-food-selection.md), [`foods-database.csv`](foods-database.csv), [`friends-system.md` v0.2](friends-system.md)
>
> 본 문서는 **공식·범위·갯수**만 lock한다. 정확한 튜닝 수치는 alpha 빌드 이후 데이터 기반 조정. 본 문서의 모든 숫자는 **placeholder default**.

---

## 0. v0.2 변경 요약 (vs v0.1)

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

### 2.2.2 음식별 Stage 1 time_limit override (가게 수 가중) — v0.2

| food_id | 음식 | 가게 수 | 권고 time_limit (s) |
|---------|------|:------:|:------------------:|
| t1_001 | 호떡 | 2 | 18 |
| t1_002 | 라면 | 3 | 20 |
| t1_003 | 떡볶이 | 4 | 22 |
| t1_004 | 김밥 | 5 | 25 |
| t1_005 | 김치볶음밥 | 4 | 22 |
| t1_006 | 해물파전 | 4 | 24 |
| t1_007 | 한국식 콘도그 | 3 | 20 |
| t2_008 | 비빔밥 | 4 | 28 |
| t2_009 | 김치찌개 | 3 | 25 |
| t2_010 | 잡채 | 4 | 30 |
| t2_012 | 갈비구이 | 3 | 25 |
| **t2_013** | **순두부찌개** | **3** | **25** | (C-2 신규; 김치찌개와 동일 끓이기 ramp)

> "가게 수 × 4s + 음식별 조정" 휴리스틱. alpha 데이터로 fine-tune.

### 2.2.3 디스트랙터 수 by tier

`cooking.distractor_per_store_by_tier` (MVP relevant: index 0·1):

| Tier | 가게당 디스트랙터 | 음식별 평균 총 디스트랙터 |
|------|:---------------:|:----------------------:|
| 1 | 1 | ~3 (3가게 평균) |
| 2 | 1 | ~3.4 (3.4가게 평균; v0.1 3.5 → v0.2 3.4, 순두부찌개 3가게 영향) |

> [`cooking-mechanics.md`](systems/cooking-mechanics.md) §2.6 기준값과 동일.

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
| t1_001 | 호떡 | 8 | 1100 | 0.14 | FTUE 후보; 관대 |
| t1_002 | 라면 | 9 | 1000 | 0.11 | default + α |
| t1_003 | 떡볶이 | 13 | 950 | 0.10 | default |
| t1_004 | 김밥 | 4 | 1500 | 0.19 | 짧은 cook_time → 폭 넓게 (판정 공정) |
| t1_005 | 김치볶음밥 | 10 | 1000 | 0.10 | default |
| t1_006 | 해물파전 | 14 | 950 | 0.09 | **C-3: 단일 탭 (MVP)**. flip mechanic 미도입 |
| t1_007 | 콘도그 | 8 | 1000 | 0.13 | 튀기기 도입 → 약간 관대 |
| t2_008 | 비빔밥 | 5 | 1300 | 0.13 | no-cook 비비기 (짧음) |
| t2_009 | 김치찌개 | 15 | 950 | 0.06 | T2 진입 standard |
| t2_010 | 잡채 | 16 | 900 | 0.06 | T2 중반 |
| t2_012 | **갈비구이** | 18 | **650** | **0.04** | 사용자 명시 "타이밍 핵심" — T2 평균 대비 ~70% |
| **t2_013** | **순두부찌개** | **14** | **950** | **0.07** | **C-2 신규**; T2 끓이기 standard (김치찌개와 페어 — 같은 perfect_window_ms 유지하되 cook_time 14s로 폭은 살짝 더 좁음) |

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

## 5. 점수 공식 (cooking-mechanics §5.2 sync)

### 5.1 기본
```
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

## 6. Hint 시스템 (cooking-mechanics §6 sync)

| 키 | 기본값 | 설명 |
|----|--------|------|
| `cooking.hint.trigger_at_remaining_pct` | `0.50` | Stage 1 타이머 50% 이하 시 hint 버튼 활성 |
| `cooking.hint.usage_per_round` | `1` | Round당 hint 사용 1회 |
| `cooking.hint.glow_duration_sec` | `3.0` | 정답 재료 글로우 표시 시간 |
| `cooking.hint.requires_rewarded_ad` | `true` | rewarded ad 시청 필수 (GDD §5.2) |

---

## 7. Economy (코인 보상)

| tier | ★1 | ★2 | ★3 |
|:----:|:--:|:--:|:--:|
| 1 | 10 | 15 | 20 |
| 2 | 20 | 30 | 40 |

`economy.coin_per_star_by_tier = { "1": [10,15,20], "2": [20,30,40] }`.

음식별 multiplier (special case):
- `economy.coin_multiplier_by_food["t2_012"] = 1.5` (갈비구이 — 난이도 보상)

---

## 8. 다음 sprint reconciliation 항목 (v0.2 갱신)

| # | 항목 | 결정 책임 | v0.2 상태 |
|---|------|----------|----------|
| 1 | Stage 3 good/miss 분배 | game-designer | **C-4 lock 2026-05-24 (45/45)**. alpha 재조정 가능 |
| 2 | Flip mechanic 채택 | game-designer + 사용자 | **C-3 lock 2026-05-24 (미도입 MVP)**. post-launch 이월 |
| 3 | 친구 like/dislike 가산 % alpha 튜닝 | game-designer + data-analyst | open |
| 4 | 갈비구이 PERFECT 0.04 → 0.05~0.07 reconciliation | game-designer + qa-tester | open (alpha 후) |
| 5 | FTUE 첫 음식 final lock (호떡 vs 라면) | game-designer + ui-designer + pm | open |
| 6 | 인터스티셜 간격 3 round → A/B (2 vs 3 vs 4) | data-analyst | open |
| 7 | cooking-mechanics.md §4.4 30/60 → 45/45 sync 갱신 | game-designer (cooking-mechanics 차기 개정 시) | **v0.2 lock 완료, cooking-mechanics 본문 sync 대기** |
| 8 | 양념치킨 post-launch M1 부활 검토 (튀기기 다양성·KFC viral) | pm + game-designer | open (soft launch 데이터 후) |

---

## 9. 변경 이력
- **2026-05-24 v0.2** (supersedes v0.1) — C-2 lock 적용 (§2.2.2 / §3.2 양념치킨 → 순두부찌개 행 교체). **C-3 lock**: 해물파전 flip mechanic 미도입(MVP), `flip_required_foods = []` 폴백, post-launch 도입 시 사양은 §4.2 별도. **C-4 lock**: Stage 3 good/miss 45/45 (perfect 10) 분배 + Remote Config 키 `cooking.stage3.band_distribution` 신설. cooking-mechanics §4.4 30/60 supersede 명시. 갈비구이 perfect_width 변동 없음(0.04).
- **2026-05-23 v0.1 (superseded)** — 초안. Remote Config 키 catalog. Stage 1/3 음식별 12행. 갈비구이 0.04. 해물파전 flip mechanic 도입(v0.1 default). 친구 호불호 ±5% placeholder.
