# Food Critic System v1 — Golden Spoon Inspector (P6)

> 버전: **v1.0 (2026-06-05)** · 작성자: game-designer
> Status: **Accepted** · [ADR-013](../decisions.md#adr-013) P6 (사안 #3 resolution, Polish Phase)
> 상위 문서: [`decisions.md` ADR-013 / ADR-009 / ADR-010](../decisions.md), [`product-brief-locked.md`](../product-brief-locked.md), [`guest-system-v2.md` v2.0](guest-system-v2.md), [`result-screen-v2.md` v2.0](result-screen-v2.md), [`learning-layer-v1.md` v1.0](learning-layer-v1.md)
> 데이터: [`data/guests.csv`](../../godot-project/data/guests.csv) (goldspoon 기존 row 활용), [`data/recipe_xp.csv`](../../data/recipe_xp.csv) (mastery 조건), [`data/critic_badges.csv`](../../data/critic_badges.csv) (신설)
>
> **목표 (브리프 verbatim)**:
> - flow: **Dish Mastery → Critic Appears → Special Evaluation → Critic Badge → One-Time Reward**.
> - fictional brand only (**Michelin 금지** — ADR-013 §5).
> - **No repeat farming** — one-time per dish mastery.
> - 신규 system 최소화 — 기존 goldspoon guest + Recipe XP (ADR-010) 재활용.

---

## 0. 헌법 (5-line constitution)

1. **Fictional brand only** — Michelin/실명 critic 금지. **Golden Spoon Inspector** (기존 `goldspoon` guest) 단독. 정체성은 "한식 장인 평가관", 권위 있지만 따뜻한 멘토.
2. **No new system** — mastery 조건 = 기존 Recipe XP(ADR-010, recipe_xp.csv) Lv 도달. critic = 기존 goldspoon guest flow 재활용. reward = friendship/reputation/encyclopedia/fact/badge (전부 기존 자산). 신규 currency/mechanic 0.
3. **One-time per (dish)** — 음식별 critic 평가는 **1회만**. badge unlock 후 farming 불가. 반복 reward 차단.
4. **Higher standard** — critic special evaluation은 일반 guest compat보다 **엄격**. mastery 도달 음식에만 등장하므로 "졸업 시험" 정서.
5. **Emotion > numbers** — badge/encyclopedia/fact unlock이 핵심 보상 (presentation). 코인은 부차. "한식 장인에게 인정받았다" 정서가 retention.

---

## 1. Golden Spoon Inspector 정체성

> ADR-013 §5 fictional brand. 기존 `data/guests.csv` goldspoon row 그대로 활용 (asset 0 추가).

| 항목 | 값 |
|------|-----|
| guest_id | `goldspoon` (기존 row, ADR-009 evaluator 풀) |
| name | **Golden Spoon Inspector** |
| 정체성 | 한식 명인을 익명으로 찾아다니는 평가관. 말수 적고 기준 높지만, 인정하면 진심. "Michelin 아님 — Golden Spoon" fictional 브랜드. |
| role | `evaluator` (auto-pick, `MenuDB.selectable_guest_ids()` 제외 = 플레이어가 직접 선택 불가) |
| reward_bonus | **2.00** (전 guest 최고 — 기존 값 활용) |
| favorite_flavors | umami / hearty / fermented / mild (정통 한식 depth 선호) |
| disliked_flavors | oily / sweet (자극·가벼움 회피) |
| tol | 0.16 (가장 까다로움 — 기존 값) |
| line_enter | "The Golden Spoon Inspector observes in silence." |
| line_ok | "A slow nod of approval. You have earned it." |
| line_bad | "Not yet at our standard. Keep refining." |

> **정체성 톤 lock**: 권위 + 멘토. Mrs. Lee(mentor)와 톤 페어. 실명 critic 회피 → "심사관/명인" 추상 권위. badge·reaction text가 "한식 장인 인정" 정서 transfer.

---

## 2. Dish Mastery 조건 (LOCK)

> **신규 system 최소화 원칙**: 기존 Recipe XP(ADR-010, `data/recipe_xp.csv`) Lv 도달을 mastery trigger로 재활용. ★3 N회 카운트 같은 신규 storage 불필요.

### 2.1 Mastery = Recipe XP **Lv 7 도달**

| 후보 | 평가 | 결정 |
|------|------|------|
| ★3 N회 누적 | 신규 카운터 storage 필요 (schema bump) | Reject |
| Recipe XP **Lv 7** 도달 | recipe_xp.csv 기존 milestone (Lv 7 = signature dish unlock + compat +5% perm) | **Accept** |
| Recipe XP Lv 10 (max) | mastery가 max와 동일 = critic 등장이 너무 늦음 (콘텐츠 소진 후) | Reject |

**LOCK: Dish Mastery = `recipe_xp[food_id]` 레벨이 7 도달 시점.**

- 근거: recipe_xp.csv에서 **Lv 7 = `signature_dish_glow` + banner reveal** (ADR-010 §R-4 milestone). 이미 "이 음식을 잘 한다"는 의미적 milestone. critic이 Lv 7 banner 직후 등장하면 "장인이 소문 듣고 찾아옴" 서사 자연.
- Lv 7 누적 XP: T1 1400 / T1-mid 1540 / T2 1660~1780 (recipe_xp.csv 기존 값). 평균 ~25~35 round 플레이 (음식별).
- Lv 10(max)을 mastery로 하면 critic이 progression 끝에만 등장 → 동기 부족. Lv 7이 "중후반 보상"으로 적절.

### 2.2 Mastery trigger 정합 (Recipe XP milestone과 충돌 회피)

```
[Round 종료 → Result Screen 2.0]
   │
   ▼ Recipe XP 가산 (xp = 10×stars + compat/10 + new_record?+20)
   │
   ▼ recipe_xp[food_id] 레벨 Lv 6 → Lv 7 도달?
   │       YES
   ▼
[Lv 7 milestone banner (기존 ADR-010 §R-4) "signature dish unlocked"]
   │
   ▼ critic_unlocked[food_id] == false?  (1회 guard)
   │       YES
   ▼
[Golden Spoon Inspector flag SET — 다음 이 음식 cook 시 critic 등장 예약]
```

- Lv 7 banner와 critic 등장을 **같은 round에 겹치지 않음** — Lv 7 도달 round는 기존 banner만, critic은 **다음 번 이 음식을 cook할 때** 등장 (서사: "소문 듣고 찾아옴" + UI 과부하 회피).
- `critic_unlocked[food_id]` boolean (SaveManager) = farming guard (§5).

---

## 3. Critic Flow (5-step)

> 브리프 flow: Dish Mastery → Critic Appears → Special Evaluation → Critic Badge → One-Time Reward.

### 3.1 Step 1 — Dish Mastery (§2)

`recipe_xp[food_id]` Lv 7 도달 → `critic_pending[food_id] = true`.

### 3.2 Step 2 — Critic Appears

- mastery 도달 음식을 **다음에 cook하려고 선택**하면, guest selection 단계에서 **goldspoon이 special guest로 자동 등장** (auto-override).
  - 일반 guest 선택을 막지 않되, "🥄 The Golden Spoon Inspector has heard of your {dish}. Cook for them?" 1회 prompt.
  - 플레이어가 수락 → 이 round guest = goldspoon (compat은 §3.3 special). 거절 → 일반 guest 진행, critic은 다음 기회로 보류 (pending 유지).
- goldspoon은 evaluator라 평소 selectable 아님 → 이 mastery override가 유일한 등장 경로 (희소성 = 이벤트감).

### 3.3 Step 3 — Special Evaluation (일반 compat보다 엄격)

> 기존 ADR-009 compat 공식 재활용 + critic 전용 **higher standard** 보정. 신규 공식 아님 — 기존 공식의 parameter 강화.

```
# 기존 compat (ADR-009) 그대로 계산
compat = clamp(50 + fav_score − dis_score, 0, 100)

# critic 전용 임계 상향 (일반 guest보다 엄격)
critic_pass = (stars >= 3) AND (compat >= 80)
```

| 평가 dimension | 일반 guest | Golden Spoon (critic) |
|----------------|-----------|------------------------|
| compat 공식 | 기존 ADR-009 | **동일** (재활용) |
| reward_bonus | 1.15~1.35 | **2.00** (기존 goldspoon 값) |
| pass 기준 | compat curve (보상만 차등, 항상 진행) | **★3 AND compat ≥ 80** (badge 획득 게이트) |
| reaction text | guest persona | goldspoon line_ok/line_bad (§reaction templates) |

- **pass (★3 + compat ≥ 80)**: badge 획득 + One-Time Reward (§3.5).
- **fail (미달)**: badge 미획득, critic은 **pending 유지** (farming 아님 — 같은 음식 재도전 가능하나 reward는 pass 1회만). line_bad "Not yet at our standard. Keep refining." → 재도전 동기.
- **점수(★) 자체는 ADR-005 4-factor 그대로** — critic이 ★ 임계를 바꾸지 않음. critic_pass는 **badge unlock 게이트일 뿐** scoring 무영향 (ADR-013 "scoring 무변경" 정합).

### 3.4 Step 4 — Critic Badge

- pass 시 음식별 **Golden Spoon Badge** unlock (`data/critic_badges.csv`).
- badge = Encyclopedia/도감에 표시 (P5 learning-layer §3.4 Encyclopedia entry와 연결).
- badge art: art-director 후속 (12 음식 × 1 badge, 또는 공용 Golden Spoon 아이콘 + 음식 라벨로 asset 절감).

### 3.5 Step 5 — One-Time Reward (반복 farming X)

pass 1회만 지급 (이후 같은 음식 critic 재등장 X):

| reward | 값 | 출처 (기존 자산) |
|--------|-----|------------------|
| **Friendship boost** | goldspoon friendship +3 (1회) | ADR-009 friendship 0~10 시스템 |
| **Reputation** | goldspoon reward_bonus 2.00 × compat multiplier 적용 코인 (이 round 보상) | ADR-009 reward 공식 |
| **Encyclopedia unlock** | 해당 음식 4 fact 도감 영구 등록 | P5 learning_facts.csv |
| **Korean food fact** | 해당 음식 "Master fact" 1개 reveal (learning_facts culture_fact 강조 표시) | P5 learning-layer |
| **Critic Badge** | Golden Spoon Badge (음식별) | critic_badges.csv (신설) |

- **추가 currency/system 0** — 전부 기존 friendship / coin / encyclopedia / fact / badge 재활용 (ADR-013 §5 "신규 system 0" 정합).
- one-time = `critic_unlocked[food_id] = true` set 후 critic 재등장 차단 (§5 guard).

---

## 4. critic_badges.csv 신설

`data/critic_badges.csv` — 12 음식 × Golden Spoon Badge 메타.

| 컬럼 | 설명 |
|------|------|
| food_id | foods-database.csv / recipe_xp.csv 정합 |
| name_en / name_ko | 음식명 |
| badge_id | `goldspoon_{food}` |
| badge_title | "Golden Spoon: {Dish} Master" |
| mastery_level | mastery trigger Recipe XP 레벨 (= 7, 전 음식 공통) |
| master_fact_ref | reveal할 fact (learning_facts.csv culture_fact 참조) |

> 12 row. badge_title = "Golden Spoon: Ramyeon Master" 식. master_fact = P5 culture_fact 재활용 (신규 콘텐츠 작성 최소).

---

## 5. No-Farming Guard (LOCK)

> 브리프 "No repeat farming — one-time per dish mastery" 보장.

| guard | 메커니즘 |
|-------|---------|
| **1회 unlock flag** | SaveManager `critic_unlocked: Dictionary` (food_id → bool). pass 시 true set. true면 critic 재등장 X. |
| **pending vs unlocked 분리** | `critic_pending[food_id]` = mastery 도달했으나 아직 pass 못함 (재도전 가능). `critic_unlocked[food_id]` = pass 완료 (재등장 차단). |
| **reward 1회** | One-Time Reward(§3.5)는 `critic_unlocked` false→true 전환 시 1회만. badge·friendship+3·encyclopedia 중복 지급 X. |
| **fail 시 무한 재도전 허용 (reward 없음)** | fail은 pending 유지 → 같은 음식 재cook 시 critic 재등장 가능. 단 pass 전까지 reward 0 = farming 무의미. |
| **SaveManager schema** | `critic_pending: Dictionary` + `critic_unlocked: Dictionary` 2 dict 추가. ADR-010 records/recipe_xp dict 패턴 동일 (version bump 불필요 권장, godot-dev 결정). |

**farming 차단 시나리오 검증**:
- 같은 음식 ★3 반복 → critic_unlocked=true 이후 critic 미등장 → reward 0. (farming 불가 ✅)
- 12 음식 각 1회 = 최대 12 badge. 콘텐츠 양 = 12 × (mastery ~30 round) = LiveOps 깊이. (no scope creep ✅)

---

## 6. Reaction Templates (goldspoon, ADR-010 정합)

> `data/reaction_templates.csv`에 goldspoon row 이미 존재 (4 emotion level). critic special evaluation은 동일 row 재활용 + critic_pass 분기만.

| emotion | goldspoon template (기존 reaction_templates.csv) | critic 맥락 |
|---------|--------------------------------------------------|-------------|
| excellent | (goldspoon excellent row) | critic_pass + ★3 + compat ≥ 90 → "장인 인정" 최상 |
| good | (goldspoon good row) | ★3 + compat 80~89 → pass, 약한 인정 |
| okay | (goldspoon okay row) | 미달 → "Not yet at our standard" 톤 |
| bad | (goldspoon bad row) | 미달 → 재도전 유도 |

- critic_pass(★3 + compat ≥ 80) = excellent/good emotion level과 자연 정합 (ADR-010 emotion = max(compat, stars) 기반).
- 신규 reaction 콘텐츠 0 — 기존 goldspoon 4 template 재활용. (필요 시 art-director/writer가 critic 전용 line 4개 추가 가능, 선택.)

---

## 7. godot-dev / ui-designer 후속 impl spec

### 7.1 godot-dev (P6 wire)

- **mastery 감지**: `round_result.gd` (또는 RecipeXP service)에서 Lv 7 도달 시 `critic_pending[food_id] = true` set. 기존 ADR-010 Lv 7 milestone hook 재활용.
- **critic appears**: guest selection 단계에서 `critic_pending[food_id] && !critic_unlocked[food_id]` 면 goldspoon auto-override prompt. `MenuDB.selectable_guest_ids()` 제외 유지 (수락 시에만 등장).
- **critic_pass 판정**: `critic_pass = (stars >= 3) && (compat >= 80)`. compat은 기존 `Compatibility.compute()` 재활용. pass 시 §3.5 reward dispatch.
- **no-farming guard**: SaveManager `critic_pending` + `critic_unlocked` 2 dict. pass 시 unlocked=true + reward 1회.
- **badge unlock**: `data/critic_badges.csv` loader (`CriticDB.get_badge(food_id)`). Encyclopedia 등록.
- **신규 currency/mechanic 0** — friendship(`SaveManager.add_friendship`) / coin(기존 reward) / encyclopedia(P5) / fact(P5) / badge(critic_badges.csv) 재활용.

### 7.2 ui-designer (P6 layout)

- **critic appears prompt**: "🥄 The Golden Spoon Inspector has heard of your {dish}." 등장 연출 (희소 이벤트감, line_enter 활용).
- **special evaluation 연출**: goldspoon silence/nod 톤 (line_enter "observes in silence" → line_ok "slow nod"). 일반 guest reaction보다 무게감.
- **Critic Badge reveal**: pass 시 badge unlock 풀스크린/배너 (ADR-010 Lv 10 overlay 스타일 재활용 가능). One-Time 강조.
- **Encyclopedia entry**: badge + 4 fact 표시 (P5 §3.4와 통합).
- **haptic**: ADR-013 §6 allowlist "Critic success" 1회 trigger (pass 순간).

### 7.3 art-director (art-style lock 후)

- Golden Spoon Badge art (12 음식 × 1, 또는 공용 Golden Spoon 아이콘 + 음식 라벨로 asset 절감).
- goldspoon portrait (기존 guest asset 활용, 별도 critic 연출 선택).

### 7.4 content (game-designer, 본 sprint resolved)

- [x] mastery 조건 lock (Recipe XP Lv 7)
- [x] critic 5-step flow spec
- [x] special evaluation 기준 (★3 + compat ≥ 80, 기존 공식 재활용)
- [x] One-Time Reward 5종 (전부 기존 자산)
- [x] no-farming guard (critic_pending / critic_unlocked)
- [x] `data/critic_badges.csv` 신설

---

## 8. 정합성 (ADR 무변경 audit)

| ADR | 영향 |
|-----|------|
| **ADR-005** (4-stage scoring) | **무변경** — critic_pass는 badge 게이트일 뿐 ★ 임계/4-factor 무영향 |
| **ADR-009** (Guest 2.0) | **재활용** — goldspoon row + compat 공식 + friendship 시스템. 신규 guest 0 |
| **ADR-010** (Result/Recipe XP) | **재활용** — Lv 7 milestone = mastery trigger. recipe_xp.csv 무변경 |
| **ADR-013** (Polish, 사안 #3) | **충족** — fictional brand only / no new system / no farming / 기존 자산 재활용 |

**유일 신규**: `data/critic_badges.csv` (badge 메타) + SaveManager 2 dict (critic_pending/unlocked). gameplay system/currency/mechanic 신규 0.

---

## 9. 관련 문서

- [ADR-013](../decisions.md#adr-013) — Polish Phase, P6 Food Critic (사안 #3, 본 문서의 정식 ADR)
- [ADR-009](../decisions.md#adr-009) — Guest 2.0 (goldspoon + compat 재활용)
- [ADR-010](../decisions.md#adr-010) — Result/Recipe XP (Lv 7 mastery trigger)
- [`guest-system-v2.md` v2.0](guest-system-v2.md) — goldspoon evaluator 풀
- [`learning-layer-v1.md` v1.0](learning-layer-v1.md) — Encyclopedia / Korean food fact reward 연결
- [`data/guests.csv`](../../godot-project/data/guests.csv) — goldspoon row (reward_bonus 2.00)
- [`data/recipe_xp.csv`](../../data/recipe_xp.csv) — Lv 7 mastery milestone
- [`data/critic_badges.csv`](../../data/critic_badges.csv) — 12 음식 badge (본 sprint 신설)
- [`data/reaction_templates.csv`](../../data/reaction_templates.csv) — goldspoon 4 emotion (재활용)
