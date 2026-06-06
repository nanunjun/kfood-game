# Balance Config — MVP

> 버전: **v0.7.1 (2026-06-05, ADR-012 input-layer amend)** · 작성자: game-designer
> Scope: **MVP (Tier 1~2, 음식 12개, 친구 1~2명) + ADR-005 4-stage 메커닉 + C-2 basic_pantry 정책 + M2 prerequisite D3 본격 BPM lock + Guest System 2.0 (ADR-009) + Result Screen 2.0 (ADR-010) + 8-Module Cooking Pipeline (ADR-011)**.
> 상위 문서: [`systems/cooking-mechanics.md` v0.7](systems/cooking-mechanics.md), [`systems/cooking-modules-v1.md` v1.0](systems/cooking-modules-v1.md), [`systems/motion-spec.md` v0.1](systems/motion-spec.md), [`systems/mvp-food-selection.md` v2.2 §3.1](systems/mvp-food-selection.md), [`systems/guest-system-v2.md` v2.0](systems/guest-system-v2.md), [`systems/result-screen-v2.md` v2.0](systems/result-screen-v2.md), [`foods-database.csv`](foods-database.csv), [`data/dish_modules.csv`](../data/dish_modules.csv), [`store-distribution.md` v1.3](store-distribution.md), [`friends-system.md` v0.3 (deprecated by ADR-009)](friends-system.md), [`decisions.md` ADR-005 + ADR-007 + ADR-009 + ADR-010 + ADR-011](decisions.md#adr-005)
>
> 본 문서는 **공식·범위·갯수**만 lock한다. 정확한 튜닝 수치는 alpha 빌드 이후 데이터 기반 조정. 본 문서의 모든 숫자는 **placeholder default**.
>
> ⚠️ **v0.7 신설**: §15 8-Module Cooking Pipeline wire (Slice/Arrange/Stir/Flip/Timing/Season/Roll/Plate 8 module × BPM/window/threshold lock + dish-to-module sequence matrix + Remote Config 키 6종). ADR-011 동시 lock. ADR-005 4-stage meta 무변경 (8 module = low-level primitive). `data/dish_modules.csv` 신설 (12 음식 × sequence).
>
> ⚠️ **v0.6 보존**: §14 Result Screen 2.0 wire (Recipe XP 12 음식 × Lv 1~10 + New Record (food, guest) pair best + ₩500 bonus + Milestone reveal toast/banner/overlay + Emotion reaction 4 levels). pure display layer, mechanic 무영향.
>
> ⚠️ **v0.5 보존**: §13 Guest System 2.0 wire (12 flavor × 7 selectable × mood rotation × friendship 0~10). friends-system v0.3 ±5% axis 모델 supersede. compat 0~100% × reward_multiplier curve × guest reward_bonus 1.15~2.00x.
>
> ⚠️ **v0.4 본격**: §7.1 음식별 prep_bpm 12 음식 모두 lock (v0.3.2 placeholder 2개 + v0.4 신규 10개 = 12/12). foods-database.csv `prep_*` 4 컬럼 sync 완료 (M2-D2). motion-spec.md v0.1 sync (M2-D1). ADR-005 §7 BPM 음식별 본격 spec.

---

## 0. v0.7 변경 요약 (vs v0.6)

| # | 항목 | 변경 내용 |
|---|------|----------|
| **M-1** | **§15 신설 — 8-Module Cooking Pipeline wire** | 8 module (Slice/Arrange/Stir/Flip/Timing/Season/Roll/Plate) × BPM·window·threshold lock. cooking-modules-v1.md §1 spec와 1:1 sync. Stir = tap rhythm MVP / Flip = single perfect-window tap MVP (해물파전 full mechanic post-launch C-3 lock 유지) / Roll = swipe motion 0.5~1.0s 윈도 / Plate = drag/drop bonus {1.0, 0.6, 0.2}. |
| **M-2** | **§15.2 dish-to-module sequence matrix** | 12 음식 × 3~5 module sequence lock. 평균 4.4 step/음식. Plate 12 / Timing 11 / Slice 10 / Stir 5 / Season 5 / Arrange 4 / Flip 3 / Roll 1 reuse 분포 (ADR-011 정합). `data/dish_modules.csv` 신설 (12 row, pipe-separated module_sequence). |
| **M-3** | **§15.3 Remote Config 키 6종 신설** | `cooking.modules.enabled_set` / `cooking.modules.stir_interaction_mode` / `cooking.modules.flip_required_foods` (C-3 lock alias) / `cooking.modules.roll_swipe_speed_band_ms` / `cooking.modules.plate_bonus_levels` / `cooking.modules.arrange_correct_glow_ms`. |
| **M-4** | **§15.4 module별 polish 우선순위** | P0 (Plate / Timing / Slice — 10~12 음식 reuse) / P1 (Stir / Season — 5 음식) / P2 (Arrange / Flip — 3~4 음식) / P3 (Roll — 김밥 단독). godot-dev Sprint M3 implementation 우선순위 lock. |
| **M-5** | **§7.1 prep_bpm 12 음식 표 ↔ §15 sequence 정합 검증** | 모든 음식의 §7.1 prep_bpm + cut_style이 §15.2 sequence Slice step과 1:1 sync. 콘도그 dip / 불고기 marinade는 sequence에서 Flip / Season(marinade) 매핑. 충돌 0. |
| **M-6** | **§11 #16 신규 — rhythm_proto.gd → cooking_module_runner.gd migration** | godot-dev Sprint M3 권고. knead 토큰 제거 + Arrange/Plate enum 추가 + 8 module dispatch. 본 sprint = design only, code 변경 별도 sprint. |

---

## 0. v0.6 변경 요약 (vs v0.5)

| # | 항목 | 변경 내용 |
|---|------|----------|
| **R-1** | **§14 신설 — Result Screen 2.0 wire** | 6 row breakdown (prep/cook/season/plating + compat/mood/guest_bonus) + 4-level emotion reaction (excellent/good/okay/bad) + 44 reaction templates (`data/reaction_templates.csv` 신설). compat ≥ 90 / 70 / 50 / star ≥ ★3·★2·★1 임계. mood_badge 재활용 (asset 0 추가). |
| **R-2** | **§14.2 Recipe XP system 신설** | 음식별 누적 XP (Lv 1~10), `data/recipe_xp.csv` 신설. XP 산식: `10 × stars + (compat/10) + (new_record ? +20 : 0)`. T1/T1-mid/T2 3종 curve (T1 lv10=3200 / T1-mid=3360 / T2=3600~3780). Level up 보상 9종 (signature line / perfect_window +5ms / signature dish glow / reward_bonus_perm +0.05 / Master title 등). |
| **R-3** | **§14.3 New Record logic** | storage key `(food_id, guest_id)` pair. value = score_final integer (0~100). 갱신 시 +₩500 one-time. 첫 라운드는 항상 NEW RECORD (기준선). SaveManager v2 schema 유지, `records: Dictionary` + `recipe_xp: Dictionary` 2 dict 추가 (v3 bump 불필요). |
| **R-4** | **§14.4 Milestone reveal styles** | Lv 3 → toast (우상단 슬라이드 +₩500) / Lv 7 → banner (중앙 풀, signature dish unlock + compat +5% perm) / Lv 10 → full-screen overlay (portrait skin + reward_bonus +0.10x perm). milestone payout은 NEW RECORD bonus와 additive. |
| **R-5** | **§14.5 Remote Config 키 10종 신설** | `result.score_breakdown.show_modifier_rows` / `result.reaction.compat_thresholds` / `result.reaction.star_overrides` / `result.recipe_xp.formula` / `result.recipe_xp.max_level` / `result.record.new_record_bonus_coin` / `result.record.first_record_counts` / `result.milestone.reveal_styles` / `result.milestone.overlay_duration_sec` / `result.reaction.emotion_levels`. |
| **R-6** | **검증 3종** | Mrs.Lee × 잔치국수 (happy) ★3 93% excellent → "Just right. Deep savory touch." + NEW RECORD + Lv 4 / Father × 떡볶이 (grumpy) ★2 69% okay → "Not bad. Needs more punch." / Mother × 김치찌개 (picky) ★1 49% bad → "A little heavy for me today, dear." + 첫 라운드 NEW RECORD. |

---

## 0. v0.5 변경 요약 (vs v0.4)

| # | 항목 | 변경 내용 |
|---|------|----------|
| **G-1** | **§13 신설 — Guest System 2.0 wire** | 12 flavor 카테고리 × 7 selectable guests × 5 mood rotation × friendship 0~10. compat 공식 lock (W_BASE=50 + W_FAV=12 + W_DIS=18 × mood multiplier). compat → reward_multiplier curve (90+/70/50/30/<30 → 1.30x/1.15x/1.00x/0.85x/0.70x). guest별 reward_bonus 1.15x~2.00x. |
| **G-2** | **§13.4 신설 — friendship curve + milestone** | 0~10 누적, milestone 3/7/10 (gift ₩500 / compat +5% perm / reward_bonus +0.10x perm). round 평균 +2 → 5 round로 milestone 1. |
| **G-3** | **§13.5 신설 — mood rotation algorithm** | daily seed `hash(today_iso + guest_id)`, 5 mood pool 후보 중 선택. 7 guest 각자 독립 mood. |
| **G-4** | **friends-system.md v0.3 ±5% axis 모델 deprecated** | `friends.like_bonus_pct` / `friends.dislike_penalty_pct` / `friends.preference_affect_stars` 3 키 deprecated (§2.2 표 markdown 유지하나 ADR-009 supersede 명시). v2.0 compat가 신규 source of truth. |
| **G-5** | **검증 (대표 케이스 3종)** | Junho × 김치찌개 (happy) = 93% ✅ (사용자 verbatim 92% 예시 일치) / Mina × 김밥 (easy) = 62% ✅ (목표 63% 일치) / Mrs.Lee × 잔치국수 (happy) = 93% ★ (mentor signature). compat 분포 30~95 range로 의미있는 분산 검증. |

---

## 0.0 v0.4 변경 요약 (vs v0.3.3)

| # | 항목 | 변경 내용 |
|---|------|----------|
| **D2** | **foods CSV prep_* 4 컬럼 sync 완료** | foods-database.csv 헤더에 `prep_ingredient_id` / `prep_cut_style` / `prep_bpm` / `prep_taps` 4 컬럼 신설 + 12 음식 모두 row 값 lock. 본 문서 §7.1 12 음식 본격 매핑 표와 1:1 sync. |
| **D3** | **§7.1 음식별 prep_bpm 12음식 전체 lock** | v0.3.2 placeholder 2개 (잔치국수·불고기) → v0.4 본격 12/12. 라면 100 / 떡볶이 100 / 김밥 70 / 김치볶음밥 90 / 해물파전 110 / 콘도그 80 (dip substitute) / 잔치국수 110 / 비빔밥 115 / 잡채 120 / 갈비구이 140 / 순두부찌개 80 / 불고기 60 (marinade). |
| **D1** | **motion-spec.md v0.1 cross-ref** | motion-spec §2 12 음식 × Stage × 도구 × motion 매핑 표 sync. AnimationPlayer keyframe spec 9종. Option 1 motion lock (Transform-only). |
| **분포 검증** | BPM 분포 7 buckets PASS | T1 평균 BPM = (100+100+70+90+110+80+110)/7 = 94.3 (T1 범위 70~110 약간 outlier 콘도그 80 dip은 cut 외 substitute라 enforce X) / T2 평균 = (115+120+140+80+60)/5 = 103 (T2 범위 90~140; 순두부 80은 통썰기 T1 fall-back, 불고기 60은 marinade 별도 카테고리 = 정합). |

## 0.1 v0.3.3 변경 요약 (vs v0.3.2, 보존)

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
| ~~`friends.like_bonus_pct`~~ | ~~`0.05`~~ | float | ~~친구가 음식 좋아함 → Round 점수 가산 (5%)~~ **DEPRECATED v0.5 (ADR-009) — §13 Guest System 2.0 compat 공식이 supersede** |
| ~~`friends.dislike_penalty_pct`~~ | ~~`0.05`~~ | float | ~~친구가 음식 싫어함 → Round 점수 감산 (5%)~~ **DEPRECATED v0.5 (ADR-009)** |
| ~~`friends.preference_affect_stars`~~ | ~~`false`~~ | bool | ~~친구 호불호가 ★ 임계에도 영향 주는지 (기본 false = 점수만)~~ **DEPRECATED v0.5 (ADR-009)** |
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

### 7.1 음식별 prep_bpm / prep_taps 본격 매핑 (v0.4 D3 lock — 12음식 전체)

> v0.4 M2-D3 본격 sprint lock. foods-database.csv `prep_*` 4 컬럼 1:1 sync. motion-spec.md v0.1 §2 매핑 표와 동일.

| food_id | 음식 | prep_cut_style | prep_ingredient_id | prep_ingredient (한글) | prep_bpm | prep_taps | cook_time | perfect_window | 비고 |
|---------|------|---------------|-------------------|----------------------|:--------:|:---------:|:---------:|:--------------:|------|
| t1_002 | 라면 | CUT-05 송송 | ing_p_001 | 대파 | **100** | **4** | 9s | 0.11 | T1 standard. 송송썰기 100 BPM (`cooking.prep.bpm_by_cut_style.송송썰기` 100~120 mid). FTUE 1순위 — 학습 곡선 부드러움 |
| t1_003 | 떡볶이 | CUT-03 어슷 | ing_s_002 | 어묵 | **100** | **5** | 13s | 0.10 | T1 mid. 어슷썰기 100 BPM (`bpm_by_cut_style.어슷썰기` 90~110 mid). 어묵 5조각으로 떡볶이 양 표현 |
| t1_004 | 김밥 | CUT-04 통썰기 | ing_x_008 | 단무지 | **70** | **3** | 4s | 0.19 | T1 가장 느린 BPM. 통썰기 70 BPM (`bpm_by_cut_style.통썰기` lowest). 김밥 5가게 풀 순회 부담 보상 — 입문 부드러움 |
| t1_005 | 김치볶음밥 | CUT-06 깍둑썰기 | ing_x_010 | 김치 | **90** | **4** | 10s | 0.10 | T1 mid. 깍둑썰기 90 BPM (`bpm_by_cut_style.깍둑썰기` 80~100 mid). 김치 cube cut 변별 |
| t1_006 | 해물파전 | CUT-05 송송 | ing_p_002 | 쪽파 | **110** | **5** | 14s | 0.09 | T1 상한 BPM. 송송썰기 110 BPM (`bpm_by_cut_style.송송썰기` upper). 쪽파 fine slice 5회 = 해물파전 양 표현. 파(ing_p_001) vs 쪽파(ing_p_002) 디스트랙터 학습 |
| t1_007 | 한국식 콘도그 | CUT-00 dip substitute | ing_g_005 | 부침가루 (batter) | **80** | **3** | 8s | 0.13 | **dip substitute** (칼 cut 메커닉 비적용 — 콘도그는 소시지를 batter에 dip 3회 chain). motion-spec §3.10. T1 mid BPM 80 (batter dip ceremony 속도). corndog_batter_bowl sprite art-director 미니 sprint 필요 |
| t1_008 | 잔치국수 | CUT-05 송송 | ing_p_001 | 대파 | **110** | **4** | 12s | 0.10 | T1 상한 BPM. N-1 신규 placeholder 유지. 부 hero "애호박 통썰기 CUT-04 70 BPM·3 taps" 대안 사용자 confirm 대기. 시그니처 마무리 fresh garnish 임팩트 vs 정통 잔치국수 정서 trade-off |
| t2_008 | 비빔밥 | CUT-02 채썰기 | ing_p_009 | 당근 | **115** | **5** | 5s | 0.13 | T2 mid BPM. 채썰기 115 BPM (`bpm_by_cut_style.채썰기` 110~120 mid). 당근 julienne 5회 = 6색 채소 비주얼 representative |
| t2_010 | 잡채 | CUT-02 채썰기 | ing_p_009 | 당근 | **120** | **6** | 16s | 0.06 | T2 채썰기 upper BPM. 잡채는 비빔밥보다 채썰기 더 빠른 속도 (당근 strip가 더 가늘게) + 6 taps로 6색 채소 비주얼 강조. PERFECT 0.06 좁음 (T2 중반 난이도) |
| t2_012 | 갈비구이 | CUT-01 다지기 | ing_p_005 | 마늘 | **140** | **6** | 18s | 0.04 | **T2 최고 BPM**. 다지기 140 BPM (`bpm_by_cut_style.다지기` 가장 빠름). 마늘 minced 6회 rapid down-stroke = "타이밍 핵심" 사용자 명시 정합. Stage 2C perfect_width 0.04 좁음 + Stage 2A 140 BPM = 갈비구이가 MVP 최고 난도 음식 위치 확정 |
| t2_013 | 순두부찌개 | CUT-04 통썰기 | ing_p_011 | 호박 | **80** | **4** | 14s | 0.07 | T2 lower BPM. 통썰기 80 BPM (`bpm_by_cut_style.통썰기` 70 + 10 보정 — T2 음식은 통썰기 70도 약간 상향). 호박 round slice 4회. T2 끓이기 단독 |
| t2_014 | 불고기 | **CUT-00 marinade rhythm** | ing_m_007 | 얇은 소고기 + 양념 | **60** | **3** | 16s | 0.09 | **T2 marinade 별도 카테고리**. 양념재우기 60 BPM (`bpm_by_cut_style.양념재우기` slow marinade pace). 얇은 소고기에 양념 마사지 3 press. ADR-005 §7 양념재우기 시그니처 음식. motion-spec §3.3 손바닥 + marinade bowl. 부 hero "양파 채썰기 CUT-02 115 BPM·4 taps" multi-cut sub-sequence 후보 (alpha 후 결정) |

**12음식 BPM 분포 검증** (D3):

| BPM | 음식 수 | 음식 | Cut style |
|:---:|:------:|------|-----------|
| 60 | 1 | 불고기 | 양념재우기 (marinade 별도 카테고리) |
| 70 | 1 | 김밥 | 통썰기 (T1 lowest) |
| 80 | 2 | 콘도그(dip)·순두부찌개 | dip / 통썰기 |
| 90 | 1 | 김치볶음밥 | 깍둑썰기 |
| 100 | 2 | 라면·떡볶이 | 송송 / 어슷 |
| 110 | 2 | 해물파전·잔치국수 | 송송 / 송송 |
| 115 | 1 | 비빔밥 | 채썰기 |
| 120 | 1 | 잡채 | 채썰기 (T2 fast) |
| 140 | 1 | 갈비구이 | 다지기 (T2 maximum) |

- **T1 평균 BPM**: (100+100+70+90+110+80+110) / 7 = **94.3** — T1 범위 70~110 정합 (콘도그 80은 dip substitute 별도 cap 외)
- **T2 평균 BPM**: (115+120+140+80+60) / 5 = **103** — T2 범위 90~140 (순두부 80은 통썰기 T1 fall-back 정합 / 불고기 60은 marinade 별도 카테고리)
- **Cut style 분포**: 송송 3 / 채썰기 2 / 통썰기 2 / 어슷 1 / 깍둑 1 / 다지기 1 / 양념재우기 1 / dip 1 — 7 cut style category + 1 dip substitute 모두 노출 (cut anim 12 LOCK 활용 최대화)
- **Tap 수 분포**: 3 taps(2 — 김밥·콘도그·불고기 3) / 4 taps(3 — 라면·김치볶음밥·잔치국수·순두부 4) / 5 taps(3 — 떡볶이·해물파전·비빔밥) / 6 taps(2 — 잡채·갈비구이) — 점진 ramp T1 3~5 / T2 5~6 정합 (cooking-mechanics §7 `tap_range_by_tier` lock)

**Stage 2C 보조 cook 행위 BPM** (`cooking.cook.bpm_by_action`, 신규 Remote Config 후보):

| Cook 행위 | BPM | 적용 음식 | 도구 motion |
|----------|:---:|----------|------------|
| 끓이기 stir slow | 60 | 라면 / 잔치국수 / 순두부찌개 | TOOL-06 국자 scoop oneshot |
| 볶기 stir medium-fast | 100 | 김치볶음밥 / 잡채 / 불고기 / 떡볶이 | TOOL-07 주걱 stir loop |
| 부치기 flip | 80 | 해물파전 (MVP 정적, flip post-launch) | TOOL-08 뒤집개 정적 |
| 굽기 grip | 70 | 갈비구이 | TOOL-09 집게 grip-and-lift |
| 튀기기 dip | 90 | 콘도그 | TOOL-04 튀김기 정적 + dip oneshot |
| 비비기 bibim | 90 | 비빔밥 | TOOL-11 + TOOL-07 orbit |
| 말기 roll | 60 | 김밥 | TOOL-10 김발 roll oneshot |

> Stage 2C cook 행위 BPM은 본격 보조 rhythm 메커닉 후보 (단일 탭 timing game 위주의 cooking-mechanics §4와 별도, alpha 후 도입 결정). 본 v0.4는 시각 ambient 용도 lock + motion-spec §4 sync.

### 7.2 사용자 confirm 필요 사안 (D3)

| # | 항목 | 권고 | 결정 |
|---|------|------|------|
| 1 | 잔치국수 hero ingredient final lock (대파 송송 110 BPM vs 애호박 통썰기 70 BPM) | 대파 110 BPM 유지 (placeholder lock 그대로 활성화) | 사용자 결정 대기 |
| 2 | 불고기 multi-cut sub-sequence (양념재우기 단독 vs + 양파 채썰기 sequential) | 단독 유지 (alpha 후 재검토) | open |
| 3 | 콘도그 Stage 2A dip substitute (칼 cut 메커닉 비적용) | 80 BPM × 3 taps batter dip lock | 사용자 confirm |
| 4 | Stage 2C 보조 rhythm 메커닉 도입 시점 (cook BPM stir/grip/orbit) | 시각 ambient만 lock, 보조 rhythm은 alpha 후 결정 | open |

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
| ~~9~~ | ~~ADR-005 음식별 prep_bpm / prep_tap_count / prep_cut_style / prep_ingredient lock~~ | game-designer | **✅ resolved 2026-05-31 v0.4 D3 — 12음식 전체 본격 lock (§7.1 표). foods-database.csv `prep_*` 4 컬럼 sync 완료** |
| ~~10~~ | ~~ADR-005 perfect_window 80ms vs 100ms lock~~ | pm | **✅ resolved 2026-05-26 → ±80ms** |
| ~~11~~ | ~~ADR-005 Skip auto_perfect_score 1.0 vs 0.9 lock~~ | pm | **✅ resolved 2026-05-26 → 0.9** |
| **12** | **ADR-005 ★ 임계 (30/60/90) sync — `scoring.star_thresholds` (v0.2 50/75/90) vs `scoring.star_thresholds_v05` (30/60/90) 이중 운영 정리** | game-designer + godot-dev | **open** |
| **13** | **C-2 basic_pantry 정책 alpha 검증** — Stage 1 자동 제외 학습률 / kitchen rack 인지 / 옹기 시각 디스트랙터 손실 회복 | game-designer + ui-designer + qa-tester | **open (alpha 후)** |
| **14** | **ADR-007 신설** — basic_pantry 정책 정식 ADR 격상 (Stage 1 진열대 자동 제외 + kitchen rack 자동 제공 + accuracy 분모 차감의 의사결정 기록) | pm | **open (별도 sprint 위임)** |
| **15** | **소금 ing_x_007 ID 재매핑 ripple** — 기존 ing_x_007 (깨) → ing_x_019 이동 시 Resource(.tres) 정합성 + foods CSV 명시 X 정합성 | godot-dev | **open (Resource sync sprint)** |
| **16** | **ADR-011 rhythm_proto.gd → cooking_module_runner.gd migration** — 8 module dispatch refactor + knead 제거 + Arrange/Plate enum 신규. dish recipe data load (data/dish_modules.csv) | godot-dev | **open (Sprint M3 권고)** |
| **17** | **ADR-011 Stir interaction MVP lock** — tap_rhythm vs swipe_circular 중 alpha 후 확정. MVP는 tap_rhythm 권고 (latency 부담 ↓) | game-designer + godot-dev | **open (alpha 후)** |
| **18** | **ADR-011 Plate module 그릇/garnish art workload** — 12 음식 × 평균 2 garnish = ~36 art assets. art-style lock 후 산정 | art-director | **open (art-style lock 후)** |

---

## 13. Guest System 2.0 wire (v0.5 신설 — ADR-009)

> Full spec: [`systems/guest-system-v2.md` v2.0](systems/guest-system-v2.md). 본 §13은 balance-config 관점 핵심 공식·키·튜닝 수치만 lock.

### 13.1 Compatibility 공식 (lock)

```
hit_fav = |food.flavor_tags ∩ guest.favorite_flavors|
hit_dis = |food.flavor_tags ∩ guest.disliked_flavors|

fav_score = hit_fav × W_FAV × mood_mult_fav[mood_of_the_day]
dis_score = hit_dis × W_DIS × mood_mult_dis[mood_of_the_day]
raw       = W_BASE + fav_score − dis_score
compat    = clamp(raw, 0, 100)    // 0~100% integer
```

**lock 값** (alpha 후 fine-tune):
- `W_BASE = 50`
- `W_FAV = 12`
- `W_DIS = 18`

### 13.2 Mood multipliers (5 mood)

| mood | mood_mult_fav | mood_mult_dis | 페르소나 |
|------|:-------------:|:-------------:|---------|
| hungry | 1.3 | 0.9 | "I'll eat anything good." 선호 강조 |
| happy | 1.2 | 1.0 | 관대한 톤 |
| easy | 1.0 | 0.7 | 호불호 다 약화 |
| picky | 1.1 | 1.5 | 까다로움 (dislike 가중) |
| grumpy | 0.8 | 1.6 | 매우 까다로움 (high risk, high reward) |

### 13.3 Compat → Reward Multiplier curve

| compat | reward_multiplier | UI tag |
|:------:|:-----------------:|--------|
| ≥ 90 | **1.30x** | "Perfect match! 💯" |
| 70~89 | 1.15x | "Great match ✨" |
| 50~69 | 1.00x | (neutral) |
| 30~49 | 0.85x | "Mediocre 😐" |
| < 30 | 0.70x | "Bad match 😔" |

```
final_reward = base_reward × guest.reward_bonus × compat_multiplier(compat)
```

`base_reward` = `levels.csv` reward × stars multiplier (§10). guest.reward_bonus = 1.15~2.00x (guest별 CSV 정의).

### 13.4 Friendship Curve + Milestone

**누적 공식 (라운드 결과 후)**:
```
base_delta = stars                       # ★1=+1, ★2=+2, ★3=+3
compat_bonus = +1 if compat >= 80 else 0
friendship[guest_id] = clamp(friendship[guest_id] + base_delta + compat_bonus, 0, 10)
```

**Milestone**:
| friendship_lv | 보상 | 게임플레이 가치 |
|:-:|------|----------------|
| **3** | one-time gift ₩500 + special line_ok unlock | 초기 친밀도 동기 |
| **7** | "signature dish" reveal + compat +5% permanent (해당 guest 한정) | 같은 guest 반복 선택 강화 정서 |
| **10** | portrait skin unlock + reward_bonus +0.10x permanent | end-game progression |

**도달 곡선** (round 평균 +2 가정 = ★2 × compat 60):
- Milestone 1 (Lv 3) ≈ 2 round
- Milestone 2 (Lv 7) ≈ 4 round
- Milestone 3 (Lv 10) ≈ 5~7 round (★3 dominant 시)
- 7 guest × MAX = ~50 round 콘텐츠 (LiveOps 풀)

### 13.5 Mood Rotation Algorithm

```
mood_of_the_day(guest_id):
    seed_str = ISO8601_date_today + "_" + guest_id   // "2026-06-04_junho"
    seed_hash = hash(seed_str)
    pool = GuestDB[guest_id].mood_pool                // Array[mood_id], 3~5 entries
    return pool[abs(seed_hash) % pool.size()]
```

**특성**:
- Deterministic per (date, guest) — 같은 날 같은 guest = 같은 mood
- 7 guest 각자 독립 — 오늘 Junho=hungry, Mina=picky, Mrs.Lee=easy (동시 가능)
- pool에 중복 entry 허용 = 가중치 효과 (예: `hungry|hungry|happy|easy|picky` → hungry 40%)

### 13.6 Remote Config 키 (G-1 ~ G-3 신설)

| 키 | 기본값 | 타입 | 설명 |
|----|--------|------|------|
| `guest.compat.weights` | `{base:50, fav:12, dis:18}` | object | compat 공식 가중치 |
| `guest.compat.mood_multipliers` | `{hungry:[1.3,0.9], happy:[1.2,1.0], easy:[1.0,0.7], picky:[1.1,1.5], grumpy:[0.8,1.6]}` | object | mood_id → [fav_mult, dis_mult] |
| `guest.compat.reward_multiplier_curve` | `[[90,1.30],[70,1.15],[50,1.00],[30,0.85],[0,0.70]]` | array | compat 임계 → multiplier (descending) |
| `guest.friendship.milestones` | `[3,7,10]` | int[] | milestone level |
| `guest.friendship.milestone_rewards` | `{"3":{"coin":500}, "7":{"compat_bonus_perm":0.05}, "10":{"reward_bonus_perm":0.10}}` | object | milestone 보상 |
| `guest.friendship.delta_per_round` | `{"base":"stars","compat_bonus_threshold":80,"compat_bonus":1}` | object | friendship 증가 공식 |
| `guest.friendship.max` | `10` | int | friendship cap |
| `guest.mood.daily_seed_pattern` | `"%date_iso%_%guest_id%"` | string | daily seed input format |
| `guest.compat.show_score_in_ui` | `false` | bool | UI에 compat % 노출 여부 (false = 전략적 모호함) |

### 13.7 점수 vs 보상 분리 정책

- compat은 **보상(코인)** 에 영향. **★ 임계 score_final**에는 영향 X (Stage 2A/2B/2C 4-factor 그대로).
- 사유: ★는 플레이어 스킬 평가, compat은 guest fit 평가 → 정합성 분리. 친구를 잘 골랐다고 ★이 늘어나는 것은 직관 위반.
- friends-system v0.3 §5.1의 `score_pre + preference_modifier × 100` 모델은 deprecated. 신규 모델:

```
score_final = clamp01(score_pre) × 100              # ★ 결정 (변동 없음, 4-factor)
coin_reward = (★ multiplier) × base_coin × guest.reward_bonus × compat_multiplier(compat)
              + friendship_milestone_payout(if hit)
```

### 13.8 검증 예시 (3종)

| guest | food | mood | hit_fav | hit_dis | fav_score | dis_score | raw | compat | reward_mult |
|-------|------|------|:-------:|:-------:|:---------:|:---------:|:---:|:------:|:-----------:|
| Junho | Kimchi Stew | happy | 3 | 0 | 3×12×1.2=43.2 | 0 | 93.2 | **93%** ★★★ | 1.30x |
| Mina | Gimbap | easy | 1 | 0 | 1×12×1.0=12 | 0 | 62 | **62%** | 1.00x |
| Mrs.Lee | Janchi Guksu | happy | 3 | 0 | 3×12×1.2=43.2 | 0 | 93.2 | **93%** ★★★ | 1.30x |
| Father | Tteokbokki | grumpy | 2 | 0 | 2×12×0.8=19.2 | 0 | 69.2 | 69% | 1.00x (high risk) |
| Mother | Kimchi Stew | picky | 2 | 1 | 2×12×1.1=26.4 | 1×18×1.5=27.0 | 49.4 | **49%** | 0.85x |

> compat 분포 49~93% → guest selection이 의미있는 결정 (Auto Select dominant 회피 검증).

---

## 14. Result Screen 2.0 wire (v0.6 신설 — ADR-010)

> Full spec: [`systems/result-screen-v2.md` v2.0](systems/result-screen-v2.md). 본 §14는 balance-config 관점 핵심 공식·키·튜닝 수치만 lock.

### 14.1 6 row breakdown 데이터 모델

| # | row_id | source (rhythm_proto / Save / Guest) | 시각 표시 | 코인 기여 (display) |
|---|--------|---|----|---|
| 1 | prep_score | `_cat_acc.prep` 평균 | progress bar (blue) + % + ★1~3 | base × 0.20 × score |
| 2 | cook_score | `_cat_acc.cook` 평균 | progress bar (orange) + % + ★1~3 | base × 0.20 × score |
| 3 | seasoning_score | `_cat_acc.season` 평균 | progress bar (red) + % + ★1~3 | base × 0.20 × score |
| 4 | plating_score | `dish_bonus` (best/2nd/bad = 1.0/0.6/0.2) | dish thumb + label | base × 0.20 × score |
| 5 | compatibility_bonus | `RewardCalc.bonus_multiplier(compat)` | compat % bar (compat_color) + pill | × compat_mult (전체 곱) |
| 6 | mood_bonus_or_penalty | `mood_mult_fav` 또는 `mood_mult_dis` 영향분 | mood_badge 재활용 + label "+20%" / "-50%" | (compat에 이미 반영, explanation 전용) |
| 7 | reward_bonus | `guest.reward_bonus` (CSV) | guest portrait + "× guest_bonus" pill | × guest.reward_bonus (전체 곱) |

`final_coin = base × compat_mult × guest_bonus + (new_record ? 500 : 0) + milestone_payout`

### 14.2 Emotion Reaction — 4 levels (lock)

```
level_from_compat = excellent(≥90) / good(70~89) / okay(50~69) / bad(<50)
level_from_stars  = excellent(★3 + compat≥70) / good(★3 alone) / okay(★2) / bad(★1)
final_level       = max(level_from_compat, level_from_stars)
```

| level | mood_badge mood 매핑 | tween | sfx |
|-------|---------------------|-------|-----|
| excellent | happy (smile) | scale 1.0 → 1.20 punch | sting_perfect |
| good | easy (~) | scale 1.0 → 1.10 | sting_good |
| okay | picky (?) | scale 1.0 → 1.05 small | sting_ok |
| bad | grumpy (>(:) | scale 1.0 → 0.95 sag | sting_bad |

**Template lock**: `data/reaction_templates.csv` 44 row (8 selectable guests + 3 evaluators × 4 levels). placeholder `{top_matched_flavor}` / `{top_disliked_flavor}` / `{missing_favorite}` 치환.

### 14.3 Recipe XP curve (lock)

**XP 산식**:
```
xp_per_round = 10 × stars + (compat / 10) + (new_record ? +20 : 0)
recipe_xp[food_id] += xp_per_round   (cap = lv10_cumxp)
```

> 평균 round = ★2 + compat 60 = 26 XP/round. T1 lv10 도달 = ~120 round (3200/26).

**Tier별 curve** (`data/recipe_xp.csv` 12 음식 sync):

| level | T1 (3 음식) | T1-mid (5 음식) | T2 (4 음식) |
|:-:|:-:|:-:|:-:|
| 1 | 0 | 0 | 0 |
| 2 | 100 | 120 | 140~160 |
| 3 | 250 | 280 | 320~360 |
| 4 | 450 | 500 | 560~620 |
| 5 | 700 | 780 | 860~940 |
| 6 | 1000 | 1120 | 1220~1320 |
| 7 | 1400 | 1540 | 1660~1780 |
| 8 | 1900 | 2040 | 2200~2340 |
| 9 | 2500 | 2640 | 2840~3000 |
| 10 | 3200 | 3360 | 3600~3780 |

**Level up 보상**:

| recipe_lv | T1/T1-mid | T2 | 가치 |
|:-:|---|---|---|
| 2 | +₩300 | +₩400 | 초기 동기 |
| 3 | signature_line unlock | same | persona depth |
| 4 | +₩500 | +₩650 | mid 부스트 |
| 5 | perfect_window +5ms (this food only) | same | skill aid |
| 6 | +₩800 | +₩1000 | |
| 7 | signature dish glow effect | same | 시각 보상 |
| 8 | +₩1200 | +₩1500 | |
| 9 | reward_bonus_perm +0.05 (this food only) | same | end-game compounding |
| 10 | "Master of X" title + max badge | same | bragging right |

### 14.4 New Record + Milestone

- **storage key**: `data.records[food_id][guest_id] = score_final_int` (0~100)
- **bonus**: 갱신 시 `+₩500` (`economy.new_record_bonus_coin`)
- **첫 라운드도 NEW RECORD** (기준선 설정)
- **milestone payout과 additive** (둘 다 add, exclusive 아님)

Milestone reveal styles (UI 강도 ramp):

| level | reveal | hold | confetti |
|:-:|---|:-:|:-:|
| 3 | toast (corner slide) | 1.5s | X |
| 7 | banner (center pool) | 2.0s | small |
| 10 | full-screen overlay | 2.5s | big + portrait reveal |

### 14.5 Remote Config 키 (R-5 신설)

| 키 | 기본값 | 타입 | 설명 |
|----|--------|------|------|
| `result.score_breakdown.show_modifier_rows` | `true` | bool | compat/mood/bonus 3 modifier row 표시 |
| `result.reaction.emotion_levels` | `["excellent","good","okay","bad"]` | string[] | 4 emotion level id |
| `result.reaction.compat_thresholds` | `[90,70,50]` | int[] | compat → emotion level 임계 (≥90/≥70/≥50 → excellent/good/okay) |
| `result.reaction.star_overrides` | `{"3":"good","2":"okay","1":"bad"}` | object | ★ → min emotion level (compat과 max로 결합) |
| `result.recipe_xp.formula` | `{"per_star":10,"per_compat_div":10,"new_record_bonus":20}` | object | XP 산식 변수 |
| `result.recipe_xp.max_level` | `10` | int | 최대 recipe level |
| `result.record.new_record_bonus_coin` | `500` | int | NEW RECORD 갱신 1회 보상 |
| `result.record.first_record_counts` | `true` | bool | 첫 라운드도 NEW RECORD 처리 |
| `result.milestone.reveal_styles` | `{"3":"toast","7":"banner","10":"overlay"}` | object | level별 reveal 시각 스타일 |
| `result.milestone.overlay_duration_sec` | `2.5` | float | Lv 10 portrait overlay 노출 시간 |

### 14.6 점수 vs 보상 분리 정책 (재확인 — v0.5 §13.7 정합)

- **★ 임계 (4-factor)**는 cooking 메커닉만 평가 — compat/mood/recipe_xp 무영향
- **Coin reward**는 ★ × compat × guest_bonus × (new_record + milestone) 곱 + 가산
- **Recipe XP**는 ★ + compat만 영향 (guest_bonus 무관 — guest 누가 와도 같은 음식 lv up은 동일 속도)
- **Friendship**은 ★ + compat (≥80 +1)만 영향 (이미 §13.4 lock)

---

## 15. 8-Module Cooking Pipeline wire (v0.7 신설 — ADR-011, v0.7.1 ADR-012 input amend)

> Full spec: [`systems/cooking-modules-v1.md` v1.1](systems/cooking-modules-v1.md) + [`systems/action-first-cooking-v1.md` v1.0](systems/action-first-cooking-v1.md). 본 §15는 balance-config 관점 핵심 공식·키·sequence 매트릭스만 lock.
>
> ⚠️ **ADR-012 input-layer amend (2026-06-05)**: §15.1 interaction 컬럼이 button/tap → action gesture(drag/tilt/swipe/flick)로 갱신. **output·핵심 수치·sequence·scoring 전부 무변경** — gesture만 변경. `stir_interaction_mode` default "tap_rhythm" → **"continuous_swipe"** 갱신 (§15.3).

### 15.1 8 modules — interaction (action-first) · output · 핵심 수치

| # | module | interaction (ADR-012 action) | output | 핵심 수치 (Remote Config wire) |
|:-:|--------|-------------|--------|-------------------------------|
| 1 | **slice** | **vertical drag** knife through ingredient (pieces split) | `accuracy_prep ∈ [0,1]` | §6 perfect_window_ms=100 (LOCKED ±80) / good=200 → drag 위치 편차·속도 band 매핑 / §7 BPM by cut style = drag 속도 목표 (다지기 140 / 채썰기 115 / 어슷 100 / 통썰기 70 / 송송 110 / 깍둑 90) |
| 2 | **arrange** | **press-drag-release** place ingredients into pattern | `accuracy_arrange ∈ [0,1]` | `cooking.modules.arrange_correct_glow_ms = 250` (settle glow), wrong → bounce 350ms. 분모 = total_slots (2~5) |
| 3 | **stir** | **continuous circular swipe** (웍/그릇 churn) | `accuracy_cook ∈ [0,1]` | `cooking.modules.stir_interaction_mode = "continuous_swipe"` (ADR-012). 각속도 band = §7.1 footer `cook.bpm_by_action`(stir 100, slow 60, fast 110) |
| 4 | **flip** | **directional flick** (swipe-up / rotation) | `flip_score ∈ {1.0, 0.6, 0.0}` | C-3 lock: `cooking.modules.flip_required_foods = []` (post-launch `["t1_006"]`). flick 방향+속도 band → 3-tier. perfect_width = §3.2 음식별 |
| 5 | **timing** | **vertical drag on heat dial** (불 세기 지속 조절, overflow 관리) | `accuracy_timing ∈ {1.0, 0.6, 0.2, 0.0}` | §3.1 C-4 lock band distribution 0.10/0.45/0.45 → heat zone 유지율, §3.2 음식별 perfect_width 12 row → heat zone 폭 (값 무변경) |
| 6 | **season** | **tilt seasoning bottle** (각도+유지 양 조절) | default: `accuracy_season = 1.0` (시각 only) / marinade: `accuracy_prep` 가산 | ADR-007 정합 (default = 가벼운 tilt = auto-pour 대체). marinade variant = tilt-and-massage, `prep_bpm=60` (불고기 MAR-00) |
| 7 | **roll** | **forward drag bamboo mat + release timing** | `accuracy_roll ∈ [0,1]` | `cooking.modules.roll_swipe_speed_band_ms = [500, 1000]`. band 밖 → retry (점수 영향 0, FTUE 학습) |
| 8 | **plate** | **drag food onto plate + garnish** (ADR-012 input 변경 없음 — 이미 action) | `plate_bonus ∈ {1.0, 0.6, 0.2}` | `cooking.modules.plate_bonus_levels = [1.0, 0.6, 0.2]` (적절 그릇+garnish / 적절 그릇만 / 잘못된 그릇). Result Screen 2.0 §14.1 row 4 wire (dish_bonus) |

### 15.2 Dish-to-Module Sequence Matrix (12 음식)

| food_id | 음식 | sequence | 시그니처 step | step count |
|---------|------|----------|---------------|:----------:|
| t1_002 | 라면 | slice → timing → season → plate | timing (끓이기 9s) | 4 |
| t1_003 | 떡볶이 | slice → season → stir → timing → plate | stir + season(고추장) | 5 |
| t1_004 | 김밥 | arrange → roll → slice → plate | roll + slice | 4 |
| t1_005 | 김치볶음밥 | slice → stir → timing → plate | stir (wok) | 4 |
| t1_006 | 해물파전 | slice → flip → timing → plate | flip (MVP single) | 4 |
| t1_007 | 콘도그 | slice → flip → timing → plate | flip (dip+rotation) | 4 |
| t1_008 | 잔치국수 | slice → timing → arrange → plate | timing + arrange(고명) | 4 |
| t2_008 | 비빔밥 | slice → arrange → season → stir → plate | arrange(6색) + stir | 5 |
| t2_010 | 잡채 | slice → arrange → stir → timing → plate | stir(toss) + arrange | 5 |
| t2_012 | 갈비구이 | slice → season → timing → flip → plate | timing(0.04 좁음) | 5 |
| t2_013 | 순두부찌개 | slice → timing → season → plate | timing(뚝배기) | 4 |
| t2_014 | 불고기 | season(marinade) → slice → stir → timing → plate | season(MAR-00 60 BPM) | 5 |

**Module reuse 분포**:

| module | 사용 음식 수 | polish 우선순위 |
|--------|:----:|:-----:|
| plate | 12 | **P0** |
| timing | 11 | **P0** |
| slice | 10 | **P0** |
| stir | 5 | P1 |
| season | 5 | P1 |
| arrange | 4 | P2 |
| flip | 3 | P2 |
| roll | 1 | P3 |

**sequence 길이**: 4 step (7 음식) / 5 step (5 음식). 평균 4.4 step.

> Single source of truth: `data/dish_modules.csv` (12 row, pipe-separated `module_sequence` 컬럼). 본 §15.2 표는 docs 가독성용 미러.

### 15.3 Remote Config 키 (M-3 신설)

| 키 | 기본값 | 타입 | 설명 |
|----|--------|------|------|
| `cooking.modules.enabled_set` | `["slice","arrange","stir","flip","timing","season","roll","plate"]` | string[] | 8 module id lock (no add, no remove per ADR-011) |
| `cooking.modules.stir_interaction_mode` | `"continuous_swipe"` | string enum | ADR-012: MVP = "continuous_swipe" (연속 원형 churn) / 폐기 "tap_rhythm" (박자 tap, 사용자 원칙 위배) / post-launch alt = "swipe_circular_segmented" |
| `cooking.modules.flip_required_foods` | `[]` | string[] | C-3 lock alias. MVP 빈 배열 (해물파전 single tap fallback). post-launch `["t1_006"]` 활성화 |
| `cooking.modules.roll_swipe_speed_band_ms` | `[500, 1000]` | int[] | Roll module swipe 속도 [min, max] ms. band 밖 → retry |
| `cooking.modules.plate_bonus_levels` | `[1.0, 0.6, 0.2]` | float[] | Plate module 보너스 3-tier (적절 그릇+garnish / 그릇만 / 잘못 그릇) |
| `cooking.modules.arrange_correct_glow_ms` | `250` | int | Arrange module correct slot snap glow 지속 ms. wrong → 350ms bounce |

### 15.4 Polish 우선순위 (godot-dev Sprint M3 wire)

| 순위 | module | 사유 |
|:---:|---|---|
| **P0** | plate, timing, slice | 10~12 음식 reuse — polish 1주가 12 음식 체감 multiply |
| **P1** | stir, season | 5 음식 — mid feel polish |
| **P2** | arrange, flip | 3~4 음식 — MVP fallback 활용 |
| **P3** | roll | 김밥 1개 — signature single, 간소 polish 충분 |

### 15.5 ADR-005 / ADR-007 / ADR-012 정합 (재확인)

- **ADR-005 4-stage meta**: **무변경**. 8 module = Stage 2A (Slice / Season marinade) / Stage 2B (Stir / Flip / 부분적 Method) / Stage 2C (Timing) / 추가 (Arrange / Roll / Plate)의 low-level primitive.
- **ADR-007 basic_pantry**: **무변경**. Season module default = "basic_pantry 가벼운 tilt = auto-pour 대체" (Scene 2 진입 시 자동 rack, 시각 only). 양념 "고르기" 행위 X 정합.
- **ADR-012 action-first**: **input-layer amend only**. §15.1 interaction gesture만 button/tap → action(drag/tilt/swipe/flick). output·핵심 수치·sequence(§15.2)·scoring 전부 무변경. `stir_interaction_mode` "continuous_swipe" 갱신.
- **rhythm_proto.gd 7-phase**: 본 ADR-011로 supersede. migration map은 `cooking-modules-v1.md` §5. knead dead code 제거. ADR-012 action input은 cooking_module_runner.gd에 TouchGestureRecognizer 공통 유틸로 통합 (godot-dev Sprint M3).

### 15.6 사용자 verbatim 검증

| 사용자 verbatim | 보장 메커니즘 |
|----------------|---------------|
| "Players should feel they are cooking a specific Korean dish." | sequence permutation (§15.2) + signature step (음식별 1~2 hero module) + visual variation per module (Slice 8가지 한식 cutting) + Plate signature (12 그릇 art) |
| "Avoid creating unique minigames per dish." | 12 음식 sequence는 모두 8 module 풀에서만 조합. 신규 module 0건. MVP code surface = 8 module scene + 12 recipe data row |
| "Reuse modules." | 평균 module reuse = 6.4 음식/module (Plate 12 / Timing 11 / Slice 10 highest). 5/8 module이 5+ 음식에서 reuse |

---

## 12. 변경 이력
- **2026-06-05 v0.7.1** (ADR-012 input-layer amend, supersede 아님) — **§15.1 interaction 컬럼 action-first 갱신** (slice vertical drag / arrange press-drag-release / stir continuous swipe / flip directional flick / timing heat dial / season tilt / roll forward drag + release / plate 무변경). `cooking.modules.stir_interaction_mode` default `"tap_rhythm"` → **`"continuous_swipe"`** (§15.3). §15.5 ADR-012 정합 항 추가. **output signal·핵심 수치·sequence(§15.2)·scoring·4-factor·★ 임계 전부 무변경** — input gesture만 교체. 상세 = `systems/action-first-cooking-v1.md` v1.0. ADR-012 동시 lock.
- **2026-06-04 v0.7** (supersedes v0.6) — **8-Module Cooking Pipeline wire (M-1 ~ M-6)**. §15 신설 (8 module × BPM/window/threshold lock + dish-to-module sequence matrix 12 row + Remote Config 키 6종 + polish 우선순위 P0~P3). `data/dish_modules.csv` 신설 (12 row, pipe-separated module_sequence). ADR-011 동시 lock. ADR-005 4-stage meta 무변경 (8 module = low-level primitive). ADR-007 basic_pantry 정합 (Season default 1-tap auto-pour). rhythm_proto.gd 7-phase token supersede (knead 제거 + Arrange/Plate enum 추가, godot-dev Sprint M3 권고). 사용자 verbatim 검증 3건 (specific Korean dish 느낌 / avoid per-dish minigame / reuse modules).
- **2026-06-04 v0.6** (supersedes v0.5) — **Result Screen 2.0 wire (R-1 ~ R-6)**. §14 신설 (6 row breakdown + 4-level emotion reaction + Recipe XP 12 음식 × Lv 1~10 + New Record (food, guest) pair + Milestone reveal toast/banner/overlay + Remote Config 키 10종 신설). `data/recipe_xp.csv` 신설 (12 row T1/T1-mid/T2 3종 curve). `data/reaction_templates.csv` 신설 (44 row = 8 selectable + 3 evaluators × 4 emotion levels). mood_badge 재활용 (asset 0 추가). 사용자 verbatim 검증 ("Mina loved the spicy kick" persona 불일치 → Junho × 김치찌개 happy로 재해석 / "Junho liked it but wanted more savory" → Junho × 김밥 easy 62% okay band 일치, placeholder `{missing_favorite}` 으로 흡수). pure display layer — cooking mechanic 무영향. ADR-010 동시 lock.
- **2026-06-04 v0.5** (supersedes v0.4) — **Guest System 2.0 wire (G-1 ~ G-5)**. §13 신설 (compat 공식 W_BASE=50 + W_FAV=12 + W_DIS=18 lock + 5 mood × 2 multiplier 매트릭스 + reward_multiplier curve 5 tier + friendship 0~10 + milestone 3/7/10 + daily mood rotation algorithm + Remote Config 키 9종 신설). `friends.like_bonus_pct` / `friends.dislike_penalty_pct` / `friends.preference_affect_stars` 3 키 deprecated (ADR-009 supersede). 점수 vs 보상 분리 정책 lock (compat는 코인에만 영향, ★ 4-factor 무변경). 검증 예시 5종 (Junho×김치찌개 93% / Mina×김밥 62% / Mrs.Lee×잔치국수 93% — 사용자 verbatim 목표 92%·63% 일치).
- **2026-05-31 v0.4** (supersedes v0.3.3) — **M2 prerequisite design sprint D3 본격 lock**. §7.1 음식별 prep_bpm 12음식 전체 매핑 본격 lock (v0.3.2 placeholder 2개 → v0.4 본격 12/12). foods-database.csv `prep_*` 4 컬럼 sync (M2-D2). motion-spec.md v0.1 cross-ref (M2-D1). BPM 분포 검증 표 신설 (T1 평균 94.3 / T2 평균 103, T1·T2 범위 정합 검증). Cut style 분포 8 카테고리 모두 노출 검증 (송송 3 / 채썰기 2 / 통썰기 2 / 어슷 1 / 깍둑 1 / 다지기 1 / 양념재우기 1 / dip substitute 1). Tap 수 분포 점진 ramp 검증 (T1 3~5 / T2 5~6). Stage 2C 보조 cook 행위 BPM 표 신설 (시각 ambient 용도, 보조 rhythm 메커닉 도입은 alpha 후 결정). §7.2 사용자 confirm 4건 정리. §11 #9 ADR-005 음식별 prep lock open 해소 (v0.4 D3 본격 lock).
- **2026-05-31 v0.3.3** (supersedes v0.3.2) — **C-2 lock 적용 (basic_pantry 5종 정책)**. §4A "Basic Pantry 정책" 신설 (간장/고추장/설탕/참기름/소금 5종 정의 + Remote Config 키 3종 신설 `cooking.basic_pantry_ingredient_ids` / `cooking.stage1.exclude_basic_pantry` / `cooking.accuracy.exclude_basic_pantry`). §2.2.2 음식별 time_limit 재산정 (떡볶이 22→18s / 잡채 30→25s / 그 외 변동 없음). §2.2.3 디스트랙터 평균 재산정 (T1 3.86→3.43 / T2 3.4→2.8, 잡화 SKU pool 17→12 검증 PASS). §5.1 accuracy_ingredients 공식 갱신 (분모 N에서 basic_pantry 자동 차감). §11 #13·#14·#15 신규 (alpha 검증 / ADR-007 격상 / ing_x_007 ID 재매핑 ripple).
- **2026-05-30 v0.3.2** (supersedes v0.3.1) — N-1·N-2 lock 적용 (F-02 호떡 → 잔치국수 / F-09 김치찌개 → 불고기). §2.2.2 Stage 1 time_limit 행 교체 (호떡 t1_001 18s → 잔치국수 t1_008 22s / 김치찌개 t2_009 25s → 불고기 t2_014 28s). §3.2 perfect_width 행 교체 (호떡 8s·1100ms·0.14 → 잔치국수 12s·1000ms·0.10 / 김치찌개 15s·950ms·0.06 → 불고기 16s·900ms·0.09). §2.2.3 디스트랙터 평균 재산정 (T1 3 → 3.7, 잔치국수 4가게 영향). **§7.1 음식별 prep_bpm placeholder 신설** (잔치국수=대파 송송 110 BPM·4 taps / 불고기=양념재우기 60 BPM·3 taps — ADR-005 §7 양념재우기 시그니처 음식 lock). §11 #5 FTUE 첫 음식 lock 해소 (라면 자동 결정).
- **2026-05-26 v0.3.1** — Perfect window **±80ms LOCKED** (사용자 confirm, pm 권고 채택). Skip `accuracy_prep = 0.9` **LOCKED** (사용자 원안 1.0 → 0.9, skill bonus 명분 유지). §6 표 dual-column 단일화, §8 Skip default 1.0→0.9, §11 open question #10·#11 resolved.
- **2026-05-26 v0.3** (supersedes v0.2) — [ADR-005](decisions.md#adr-005) 반영. **§5 4-Factor Scoring Weights** 신설 (25/20/20/35 가중 평균 + `scoring.factor_weights` Remote Config 키 + ★ 임계 30/60/90으로 supersede). **§6 Prep Rhythm — Perfect/Good Window** 신설 (Perfect ±80ms pm권고/±100ms 사용자, Good ±200ms, Miss 그 외; `cooking.prep.perfect_window_ms` 등 3 키). **§7 BPM/Tap Range by Tier** 신설 (Tier 1: 70~110 BPM·3~6 taps / Tier 2: 90~140 BPM·5~8 taps; Cut Style별 BPM 가이드 7종). **§8 Skip Bonus** 신설 (Rewarded Video → `accuracy_prep=1.0`). §10 §11 §12 renumbered. 음식별 정확 prep 수치는 game-designer 본격 sprint 이월.
- **2026-05-24 v0.2** (supersedes v0.1) — C-2 lock 적용 (§2.2.2 / §3.2 양념치킨 → 순두부찌개 행 교체). **C-3 lock**: 해물파전 flip mechanic 미도입(MVP), `flip_required_foods = []` 폴백, post-launch 도입 시 사양은 §4.2 별도. **C-4 lock**: Stage 3 good/miss 45/45 (perfect 10) 분배 + Remote Config 키 `cooking.stage3.band_distribution` 신설. cooking-mechanics §4.4 30/60 supersede 명시. 갈비구이 perfect_width 변동 없음(0.04).
- **2026-05-23 v0.1 (superseded)** — 초안. Remote Config 키 catalog. Stage 1/3 음식별 12행. 갈비구이 0.04. 해물파전 flip mechanic 도입(v0.1 default). 친구 호불호 ±5% placeholder.
