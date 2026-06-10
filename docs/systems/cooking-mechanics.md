# Cooking Mechanics

> 버전: **v0.7 (2026-05-31, supersedes v0.6)** — [ADR-005](../decisions.md#adr-005) 4-stage + **§X Motion Spec cross-ref 신설** (M2 prerequisite D1)
> 작성일: 2026-05-23 · 최종 개정: 2026-05-31
> 상위 문서: [`../GDD.md`](../GDD.md) §2 Core Loop / §3 Scoring System
> 본 문서는 GDD §2의 **4단계** cooking matching 루프를 **구현 가능한 수준**으로 상세화한다.
>
> ⚠️ **Polish Phase cross-ref (2026-06-05, [ADR-013](../decisions.md#adr-013))**: 본 문서의 4-stage scoring/sequence/progression은 **무변경**. 폴리시 단계에서 다음 presentation/input layer 문서가 본 메커닉 위에 얹힌다:
> - [`cooking-modes-v1.md` v1.0](cooking-modes-v1.md) — **Casual(default) / Immersive(opt-in)** 8 module 입력 variant (사안 #1). 입력 난이도만 완화, scoring 무변경.
> - [`learning-layer-v1.md` v1.0](learning-layer-v1.md) — **P5 Korean Food Learning** (12 음식 × 4 fact, Result Screen flavor card, non-blocking).
> - [`food-critic-v1.md` v1.0](food-critic-v1.md) — **P6 Golden Spoon Inspector** (Recipe XP Lv 7 mastery → critic → badge, no-farming, 기존 자산 재활용).
>
> ⚠️ **v0.7 갱신**: **§X Motion Spec cross-ref 신설** — 12 음식 × Stage × 도구 × motion + BPM 매핑 본격 정의는 [`motion-spec.md` v0.1](motion-spec.md)로 분리. 본 문서는 mechanic 룰 + motion 참조만 유지. Option 1 motion lock 명시 (Godot AnimationPlayer Transform-only, frame art 추가 0건).
>
> ⚠️ **v0.6 갱신 (보존)**: **§2.2 basic_pantry 자동 제외 룰 신설** + **§2.2.7 Kitchen rack 자동 제공 신설** + **§2.5 accuracy_ingredients 공식 분모 N에서 basic_pantry 차감** + **§X 양념재우기 메커닉 정합 명시** (양념 "고르기" 행위 X) + **§8 store_type mapping에 `pantry` 카테고리 추가**.

---

## 0. 용어
- **Round**: 요리 1개를 완성하는 1 cycle (= GDD §2의 30~60초 루프).
- **Stage**: Round 안의 3단계 (Ingredients / Method / Timing).
- **Accuracy**: 각 Stage에서 0.0 ~ 1.0으로 정규화된 정확도 점수.
- **Star**: Round 종료 시 부여되는 ★0~3 등급 (GDD §3 임계값 적용).

> ⚠️ **명명 정정**: 본 게임은 "merge 게임"이 아니라 **cooking matching 게임**. 동명 tier 아이템을 합치는 메커닉은 사용하지 않는다. (이전 문서에 남은 "merge" 표현은 정정 대상.)

### MVP Scope ([ADR-003](../decisions.md#adr-003-mvp-first-전환--34개월-출시--점진-확대-supersedes-adr-002))

본 문서의 **5-tier progression / 다점포 5가게 / 3-scene 구조는 디자인 비전으로 유지**되나, **MVP 구현 범위는 다음으로 한정**된다:

| 영역 | MVP | Post-launch |
|------|-----|-------------|
| Tier | **1~2만** | 3~5는 Month 3~6 |
| 다점포 5가게 | **5가게 모두 유지** (핵심 차별점) | — |
| 친구 캐릭터 | **1~2명** (가족 단위, Tier 2 등장) | +3~5명 (Tier 3), +10명 (12개월) |
| Scene 3 식탁 | **2종** (Tier 1 혼밥 / Tier 2 가족) | +3종 (Tier 3·4·5) |
| 음식 | **10~15개** (game-designer 권고) | +5~10 (M1~M2), +Korean Food Pack DLC |
| Stage 2 조리 방법 | MVP는 단일 선택 | 복합 조리 (§3.4) |
| 멀티 요리 (Tier 4+) | — | Month 5~6 |

> 본 문서의 메커닉 정의 자체는 변경 없음. **불러올 데이터·콘텐츠 양만 MVP scope에 맞춰 줄어든다.**

---

## 1. Round 구조

**3-scene / 4-stage 구조** ([ADR-005](../decisions.md#adr-005) 2026-05-26 갱신) — Scene 3종은 유지, Stage가 3 → 4로 확장 (Scene 2 키친 내 sub-flow로 Stage 2A 재료 준비 신설).

**4-stage 흐름 요약**:
- Scene 1 🏪 시장 → Stage 1 재료 선택
- Scene 2 🍳 키친 → **Stage 2A 재료 준비 (rhythm tap, 1~2 hero ingredient)** / Stage 2B 조리 방법 / Stage 2C 조리 시간 (기존 Stage 3)
- Scene 3 🍽 식탁 → 채점 + ★

> 아래 다이어그램은 v0.4 3-stage 기준 그대로 보존 (history). 4-stage 흐름은 §X 재료 준비(아래)에서 별도 정리 — game-designer v0.5 본격 sprint에서 다이어그램 자체 재작성 예정.

```
[요리 배정]
    │
    ▼
┌── Scene 1: 🏪 재래시장 (다점포 순회) ───────┐
│   [Stage 1: 재료 선택]    15~30s            │
│           → accuracy_ingredients ∈ [0,1]     │
│   가게 5종: 청과/정육/어물/곡물/잡화         │
│   필요한 가게만 방문 → 재료 픽업 → 입구 복귀 │
└──────────────────────────────────────────────┘
    │   (귀가 트랜지션, ≤1.5s)
    ▼
┌── Scene 2: 🍳 키친 ──────────────────────────┐
│   [Stage 2: 조리 방법]    5~10s              │
│           → accuracy_method     ∈ [0,1]      │
│            │                                  │
│            ▼                                  │
│   [Stage 3: 조리 시간]    요리별              │
│           → accuracy_timing     ∈ [0,1]      │
└──────────────────────────────────────────────┘
    │   (서빙 트랜지션, ≤1.5s)
    ▼
┌── Scene 3: 🍽 식탁 ──────────────────────────┐
│   [캐릭터 시식 → 채점 → ★ 등급 → 보상]      │
│   ※ tier에 따라 식탁 인원 변화                │
│   (혼밥 → 가족 → 친구 → 파티)                 │
└──────────────────────────────────────────────┘
    │
    └─► 다음 요리 / 레벨 종료
```

- Stage 사이 전환은 **연속 (no loading)**, 짧은 transition 애니메이션만 (Scene 변경은 1.5s 이하).
- 한 Stage 실패해도 Round는 진행 (점수 곱셈으로 자연 페널티). **Round 중단 옵션 없음** (이탈 방지).
- **Scene-tier 연결**: Scene 3(식탁)은 GDD §4 progression과 직접 연동 — tier 1 혼자 식탁 / tier 2 가족 식탁 / tier 3 친구 1~3명 / tier 4 친목 모임 / tier 5 잔칫상. (Scene 1·2는 tier별 일러스트 변화는 후순위.)

---

## 2. Stage 1 — 재료 선택 (Ingredient Selection)

### 2.1 목표
주어진 요리에 들어가는 **정답 재료**를 제한 시간 안에 모두 선택. **재래시장의 여러 가게를 순회**하며 재료를 모은다.

### 2.2 Scene 구성 — 재래시장 다점포

**가게 5종 (MVP)** — `Ingredient.category` → `store_type` 매핑:

| Store | 이모지 | 취급 카테고리 (GDD §6.2) |
|-------|--------|--------------------------|
| 청과상 | 🥬 | 채소, (과일) |
| 정육점 | 🥩 | 육류 |
| 어물전 | 🐟 | 해산물 |
| 곡물상 | 🌾 | 곡물 |
| 잡화점 | 🫙 | 장류 (basic_pantry 제외), 양념 (basic_pantry 제외), 유제품, 기타 |

> Post-launch 확장 후보: 잡화점 → 양념가게 + 잡화점 분리 (장류 비중 ↑ 시), 떡집/방앗간 신설.

### 2.2.1 basic_pantry 자동 제외 룰 (v0.6 C-2 LOCK 2026-05-31)

> [`store-distribution.md` v1.3 §X](../store-distribution.md) + [`balance-config.md` v0.3.3 §4A](../balance-config.md) sync.

**basic_pantry 5종** = 한국 가정 부엌 상시 비치 base seasoning. Stage 1 재래시장 진열대에 **표시하지 않는다**.

| ingredient_id | name_ko | name_en |
|--------------|---------|---------|
| ing_x_003 | 간장 | Soy Sauce |
| ing_x_004 | 고추장 | Gochujang |
| ing_x_005 | 설탕 | Sugar |
| ing_x_006 | 참기름 | Sesame Oil |
| ing_x_007 | 소금 | Salt |

**룰**:
- Stage 1 가게 진열대 build 시, `is_basic_pantry == true` 재료는 `correct_set`에서 자동 차감 (사용자 픽업 대상 X).
- Stage 1 distractor pool에서도 basic_pantry 5종 제외 (`is_distractor_friendly = false` + `distractor_weight = 0` 정합).
- foods-database CSV의 `ingredients[]`에 basic_pantry가 포함되어 있어도 Stage 1 인지 부담 없음 (kitchen rack에 자동 표시 — §2.2.7).
- Remote Config `cooking.stage1.exclude_basic_pantry = true` (default lock).
- 정당화: 한국 가정 모든 요리에 base로 들어가는 양념을 매 음식마다 잡화점에서 픽업하는 반복 노동 제거 → 음식별 unique signature 재료(어물 멸치 / 정육 얇은소고기 / 곡물 소면 등)에 집중.

### 2.3 UI 흐름

```
[재래시장 입구 화면]
   ├─ 상단: 요리 카드 (이름, 메모, 필요 재료 N개)
   ├─ 중앙: 5개 가게 간판 (가로 스크롤 or 1-thumb 그리드)
   │       정답 재료가 있는 가게는 살짝 강조 (※ 권장: 없음 — 탐색 가치 보존)
   └─ 하단: 공통 타이머 바 (15~30s) + 장바구니 미리보기
        │
        ▼ (가게 탭)
[가게 내부 화면]
   ├─ 상단: 가게 이름, 장바구니
   ├─ 중앙: 진열대 그리드 — 카테고리 내 정답 + 디스트랙터
   ├─ 하단: 공통 타이머 (계속 흐름) + "← 입구로" 버튼
   │
   └─ 픽업 완료 또는 "← 입구로" → 재래시장 입구로 복귀
```

- 가게 진입 자체에 페널티 없음 (정답 없는 가게도 방문 가능 — 시간만 소비).
- 정답 재료 선택 → 장바구니로 슬라이드 인, **취소 가능** (가게 내부 한정).
- 오답 재료 선택 → 빨간 shake + 시간 페널티 -1s.
- 모든 정답 재료 수집 완료 → **자동으로 "귀가" 트랜지션** → Scene 2.
- 타이머 만료 → 현재 상태로 Stage 종료.

### 2.4 룰
- **가게 순서 자유**. 가게 재진입 가능 (실수로 나왔을 때 복귀 허용).
- 공통 타이머는 가게 이동·입장 트랜지션 동안에도 **계속 흐름** (가게 선택도 의사결정 압력).
- 정답 재료의 가게가 무엇인지는 **표시하지 않음** (탐색·기억이 메커닉의 일부).
  - 단, 튜토리얼 단계(FTUE)에서는 첫 1~2 round 안내 표시.
- 한 가게에서 모든 정답 재료 픽업 시 자동 입구 복귀 가능 여부: **권장 ON** (탭 절약).

### 2.5 Accuracy 계산 (v0.6 C-2 sync)

```
# v0.6 C-2 LOCK 2026-05-31: 분모 N에서 basic_pantry 자동 차감
required_effective = food.ingredients.filter(id NOT IN basic_pantry_ingredient_ids)
N_effective        = required_effective.count  // basic_pantry 5종 차감 후

correct_picks_effective = correct_picks.filter(id NOT IN basic_pantry_ingredient_ids).count
wrong_picks             = 선택한 재료 중 오답 개수

accuracy_ingredients =
    clamp01( correct_picks_effective / N_effective  -  PENALTY_PER_WRONG * wrong_picks )

PENALTY_PER_WRONG = 0.15   // 튜닝 대상
```

> 다점포 도입은 accuracy 공식 자체에는 영향 없음. 오답 가게 진입은 accuracy에 무관 (시간만 손해).
> **v0.6 C-2 효과**: foods CSV ingredients 배열에 간장·고추장·설탕·참기름·소금이 포함되어 있어도 사용자가 픽업할 필요 없으며, 분모 N에서 자동 차감되므로 미픽업 페널티 없음. 예: 갈비구이 ingredients = 9개(LA갈비/꽃갈비/마늘/배/대파/간장/설탕/참기름/깨) → N_effective = 6개(간장·설탕·참기름 -3). Remote Config `cooking.accuracy.exclude_basic_pantry = true`.

### 2.6 디스트랙터 정책 (재작성 — 다점포 영향 반영)

다점포에서는 같은 가게 안의 디스트랙터가 **모두 같은 카테고리** → 변별 난이도 자연 상승. 보정 필요.

- **가게당 디스트랙터 수** (정답 재료가 있는 가게 한정):
  - tier 1: **0~1개** (이전 단일 그리드의 1~2개에서 하향)
  - tier 2: 1개
  - tier 3: 1~2개
  - tier 4: 2개
  - tier 5: 2~3개
- **정답 재료가 없는 가게**: 디스트랙터 표시하지 않음 (정답 0개 = 빈 가게 인상 → 이탈 유도, 시간 낭비 페널티가 충분)
- 무관 카테고리 디스트랙터는 다점포 메커닉 자체가 대체 (다른 가게의 모든 재료가 자연스러운 distractor 역할).

### 2.7 다점포 메커닉이 주는 게임 디자인 함의
- **공간 기억 학습**: 반복 플레이로 "김치찌개는 정육점+청과+잡화" 같은 멘탈 맵 형성 → 후반 tier에서 효율적 의사결정 = 숙련도 보상.
- **요리별 가게 조합이 fingerprint**: 라면 = 곡물상+잡화점 (2 store), 한정식 = 5 store 모두 = tier difficulty의 자연 표현.
- **재방문 가치**: 같은 요리도 디스트랙터 랜덤화로 매 round 변주.

### 2.2.7 Kitchen Rack 자동 표시 (v0.6 C-2 LOCK 2026-05-31)

> ui-designer 별도 sprint로 위치/스타일 결정 (open follow-up).

**룰**:
- Scene 1 → Scene 2 transition (Stage 1 종료 → kitchen 진입) 시점에 **kitchen rack UI에 basic_pantry 5종 자동 표시**.
- 표시는 **시각 cue만** — 사용자 선택/탭 행위 X (수동 인터랙션 없음).
- art-director sprint 권고: 옹기 5종 일러스트로 표현 (간장 옹기 / 고추장 옹기 / 설탕 단지 / 참기름 호리병 / 소금 항아리). Stage 1 잡화점 옹기 시각 디스트랙터 손실(간장↔고추장 페어) 회복 차원.
- Stage 2A 양념재우기 메커닉 (불고기·갈비구이) 진입 시 kitchen rack의 해당 양념이 highlight + Stage 2A rhythm tap area로 자동 이동 (양념 자동 제공 정합 — §X 참조).
- Stage 2A rhythm tap 중에는 kitchen rack 옹기가 dimmed (포커스 전환).
- Scene 3 식탁 transition 시 kitchen rack hidden.

**구현 의존**:
- godot-dev: `is_basic_pantry == true` Resource 자동 fetch + Scene 2 kitchen rack 노드에 instantiate. AnimationPlayer로 fade-in 0.3s.
- ui-designer: kitchen rack 위치 (좌측 상단 vs 우측 상단 vs 가스레인지 옆 선반 vs 도마 뒤 배경) — 별도 sprint.
- art-director: 옹기 5종 anchor (Post-M1 sprint, kitchen rack 시각 identity).

---

## 2A. Stage 2A — 재료 준비 (Ingredient Prep, rhythm tap) — ADR-005 신설 (v0.5 placeholder)

> ⚠️ **High-level placeholder만** (v0.5 2026-05-26 ADR-005). 상세 룰은 **game-designer v0.5 본격 sprint**.

**핵심 사양 요약**:
- 음식당 **1~2개 "hero ingredient"** 만 prep (전체 재료 prep 부담 회피).
- **Knife indicator visual cue**: 칼이 자동 위아래 움직임 → 도마 닿기 직전 = perfect tap 타이밍. 별도 rhythm UI 없이 게임 비주얼 통합.
- **Cut Styles 6종 (한식)**: 다지기 / 채썰기 / 어슷썰기 / 통썰기 / 송송썰기 / 깍둑썰기.
- **Per-Food BPM** (high-level, balance-config v0.3 §7 참조): Tier 1 BPM 70~110 (3~6 taps), Tier 2 BPM 90~140 (5~8 taps). 다지기 가장 빠름(140), 통썰기 가장 느림(70), 양념 재우기 60 BPM.
- **판정** (balance-config v0.3 §6 참조): Perfect ±80ms(pm 권고) / ±100ms(사용자) → 100%, Good ±200ms → 60%, Miss → 0%. 전체 평균 = `accuracy_prep`.
- **Skip 옵션**: 📺 Rewarded Video 시청 시 `accuracy_prep = 1.0` (auto-perfect). Stream A 자연 트리거.
- **Mobile latency**: MVP는 visual cue 우선 + perfect window 넓게. post-launch에서 audio offset calibration UI.
- **FTUE**: Round 1 BPM 60 + 2 taps + 시각 가이드 full → Round 2~3 BPM 80 점진 가이드 제거 → Round 4+ 정상 BPM.

**상세 위임 항목 (game-designer 후속)**:
- 음식 12 × hero ingredient 매핑 (foods-database.csv `prep_ingredient` 컬럼)
- 음식별 cut_style 매핑 (`prep_cut_style`)
- 음식별 BPM 정확 수치 (`prep_bpm`)
- 음식별 tap count (`prep_tap_count`)
- ingredients-database.csv `cut_variations` 컬럼 (각 재료 적용 가능 cut style)
- Perfect/Good window 정확 수치 lock (alpha 후)
- Skip 시 점수 100% vs 90% (auto-perfect 강도) — balance-config v0.3 lock 후 alpha 검증

### 2A.X 양념재우기 정합 명시 — C-2 basic_pantry × Stage 2A 통합 룰 (v0.6 LOCK 2026-05-31)

> 불고기 t2_014 / 갈비구이 t2_012 marinade rhythm 메커닉이 C-2 basic_pantry 정책과 충돌 가능성 점검 결과 = **정합 OK**.

**룰**:
- **양념 "고르기" 행위 X**: 사용자는 Stage 1에서 간장·설탕·참기름을 픽업하지 않는다 (basic_pantry 정책으로 kitchen rack에 자동 제공).
- **Stage 2A 진입 시 양념 자동 제공**: 불고기·갈비구이 Stage 2A 진입 시 kitchen rack의 간장+설탕+참기름이 자동으로 marinade bowl로 이동 + 사용자는 marinade rhythm tap만 수행 (60 BPM·3 taps).
- **Stage 2A rhythm tap 메커닉 = "재우기" 행위 단독**: 양념 종류 선택 / 양념 분량 조절 / 양념 순서 결정 같은 sub-mechanic 없음. 마사지 식 60 BPM tap 단독.
- **hero ingredient = 얇은 소고기 (불고기) / LA갈비 (갈비구이)**: marinade rhythm tap의 대상 = thin-slice beef + 양념 마사지 통합 행위. 양념 5종은 backdrop visual (옹기에서 marinade bowl로 자동 흘러 들어가는 cue만).
- **부 hero (선택사항)**: 양파 채썰기 CUT-02 (115 BPM·4 taps) — Stage 2A multi-cut sub-sequence 후보 (open question, balance-config v0.3.3 §11 #9 본격 sprint 결정 대기).
- **accuracy_prep 계산**: 양념재우기 60 BPM 단독 tap 시 = 평균(tap1, tap2, tap3). 양념 종류 픽업/선택 행위 없으므로 accuracy_prep는 marinade rhythm 정확도 단일 dimension.

**정합 검증**:
- C-2 basic_pantry "양념 자동 제공" ↔ Stage 2A "양념재우기 60 BPM rhythm tap" = **메커닉 카테고리 다름** (재료 픽업 vs marinade 마사지). 충돌 없음.
- basic_pantry 정책이 양념재우기 메커닉을 약화시키지 않음 — 오히려 강화: 사용자가 "양념을 고르는 인지 부하" 없이 "양념 마사지 rhythm"에 집중 가능.

---

## 3. Stage 2 — 조리 방법 선택 (Cooking Method Selection)

### 3.1 목표
**3~4개 조리 방법 카드** 중 정답 선택.

### 3.2 UI
- **Scene: 🍳 키친** — 가스레인지/도마/조리대 메타포. 재료가 도마 위에 놓인 상태에서 시작.
- 상단: 요리 + 모인 재료 미리보기 (도마 위)
- 중앙: 조리 방법 카드 3~4장 (예: `끓이기 / 볶기 / 찌기 / 굽기`) — 가스레인지/오븐/찜기 등 조리도구 아이콘으로 표현
- 카드 한 장 = 한 번의 탭으로 결정 (취소 없음)
- 제한 시간 **5~10s** (요리별)
- 결정 시: 선택된 조리도구로 재료가 옮겨가는 짧은 모션 → Stage 3로 즉시 진행 (Scene 유지)

### 3.3 룰
- 정답 = `accuracy_method = 1.0`
- 오답 = `accuracy_method = 0.0` (이진)
- 시간 만료 = 오답 처리
- **부분 정답 없음** — 단순/명료한 단계로 설계

### 3.4 룰 변형 (post-launch 후보)
- 복합 조리 (예: 갈비찜 = 끓이기 + 찌기) → 순서 매칭으로 확장 가능
- MVP 시점에는 단일 선택만

---

## 4. Stage 3 — 조리 시간 (Timing Game)

### 4.1 목표
움직이는 인디케이터를 **Perfect 구간**에 맞춰 탭.

### 4.2 UI
- **Scene: 🍳 키친 (Stage 2 연속)** — 조리도구에서 끓는/볶는/구워지는 효과음·VFX 백그라운드.
- 가로로 긴 게이지 바 (조리도구 위에 오버레이)
- 좌→우로 왕복 이동하는 인디케이터 (속도는 요리 `cook_time_sec`에 반비례하여 결정)
- 게이지 위에 3개 구간:

```
│  miss  │ good │  PERFECT  │ good │  miss  │
```

- 화면 하단: "탭!" 버튼 (또는 화면 전체 탭)

### 4.3 Accuracy 계산
```
인디케이터 위치 → 구간 판정
  PERFECT 구간: accuracy_timing = 1.0
  good   구간: accuracy_timing = 0.6
  miss   구간: accuracy_timing = 0.2
  탭 안함     : accuracy_timing = 0.0
```

### 4.4 구간 너비
- 기본 PERFECT 너비: 전체의 **10%**
- 기본 good 너비: 전체의 **30%** (양쪽 합)
- 기본 miss 너비: 전체의 **60%** (양쪽 합)
- **Rewarded ad 트리거 시**: PERFECT 폭 → 20%로 확장 (GDD §5.2 "시간 perfect 구간 확대")

### 4.5 변형 (post-launch)
- 멀티탭 (예: "3번 탭")
- 길게 누르기 (boil 시간)
- Tier 4+ 멀티 요리에서 동시 타이밍 (병렬)

---

## 5. 점수 / ★ 등급

**Scene: 🍽 식탁** — Stage 3 완료 후 서빙 트랜지션(≤1.5s, 완성된 요리가 접시에 담겨 식탁으로 이동) → 식탁 화면.

### 5.1 식탁 화면 구성
- **배경**: tier별 식탁 (혼밥/가족/친구/모임/잔칫상) — GDD §4 progression과 1:1 매핑
- **캐릭터 시식 연출**: 식탁에 앉은 캐릭터(들)가 음식을 한 입 먹고 반응
  - 반응 강도가 ★ 등급의 시각적 표현 역할 (★3 = "와!", ★1 = "음...")
  - 캐릭터별 선호도(GDD §6.3 `Friend.preferences`)와 일치하면 반응 가중치 ↑ (Round 점수는 영향 X, 정서적 피드백)
- **수치 UI**: 점수 / ★ / 보상은 식탁 상단 오버레이 (캐릭터 연출 위에)
- **CTA**: "다음 요리" / "메뉴" / (실패 시) "한 번 더 도전 📺"

### 5.2 채점 공식

> ⚠️ **[ADR-005](../decisions.md#adr-005) 2026-05-26: 곱셈 모델 → 가중 평균으로 SUPERSEDE**. 4-stage 추가에 따라 Stage 2A(재료 준비) 가중치 포함.

**v0.5 가중 평균 공식 (현행)**:

```
total = (accuracy_ingredients × 0.25)
      + (accuracy_prep        × 0.20)   // Stage 2A 재료 준비 (rhythm tap)
      + (accuracy_method      × 0.20)
      + (accuracy_timing      × 0.35)

★1 ≥ 30%, ★2 ≥ 60%, ★3 ≥ 90%
```

- Skip 옵션 (📺 Rewarded Video) 사용 시: `accuracy_prep = 1.0` (auto-perfect).
- early_finish_bonus는 v0.5 본격 sprint에서 재검토 (가중 평균과 별도 가산 vs 가중치 안에 흡수).
- ★ 임계 30/60/90은 ADR-005 사용자 명시 → balance-config v0.3 lock. v0.4의 50/75/90과 충돌하지만 ADR-005가 ground truth (가중 평균 모델로 점수 분포가 더 부드러워 임계도 완화).

> **가중 평균 모델의 함의 (v0.5)**: 한 Stage가 0이어도 round 전체 0 아님 → 가족 정서 부드러움 + 캐주얼 진입장벽 유지 (C-4 lock 정신 ↔ 정합). Skip auto-perfect로 어려운 Stage 회피 가능 → Stream A Rewarded CTR ↑.

---

**v0.4 곱셈 모델 (보존 — superseded, 참고용)**:

```
score_raw    = accuracy_ingredients × accuracy_method × accuracy_timing
score_100    = round(score_raw × 100)

early_finish_bonus = max(0, remaining_time_s1 / time_limit_s1) × 0.10
score_final  = clamp01(score_raw + early_finish_bonus) × 100
```

별 등급 (v0.4):
| 별 | 임계 | 보상 |
|----|------|------|
| ★☆☆ | ≥ 50 | 기본 보상 |
| ★★☆ | ≥ 75 | 기본 ×1.5 |
| ★★★ | ≥ 90 | 기본 ×2.0 |

> v0.4 곱셈 모델의 함의: 어느 한 Stage가 0이면 Round 전체 점수가 0 → 한 Stage라도 "포기"하지 않게 만드는 압력. **ADR-005 채택으로 이 압력은 가중 평균 + Skip 옵션으로 대체됨.**

---

## 6. 실패 / 재시도 흐름

### 6.1 자연 실패
- Round 점수 0 = ★0 처리, 보상 없음, 다음 요리로 진행 (레벨은 계속)

### 6.2 레벨 실패 조건
- 레벨 = 여러 Round 묶음 (예: 3 Round)
- 레벨 클리어 = ★ 누적 N개 이상
- 실패 시 **Rewarded Ad → "오답 무료 1회"** 트리거 (GDD §5.2)

### 6.3 재시도 UX
- 실패 화면: "한 번 더 도전? (📺 광고 시청)" / "다음 요리로" / "메뉴로"
- 최근 실패 Stage만 재플레이하는 게 아니라 **Round 전체 재시작** (의사결정 명료성 + 광고 가치 보장)

---

## 7. Hint 시스템 (Rewarded Ad 통합)

GDD §5.2 "재료 힌트" 매핑.

- 트리거 위치: **Stage 1** 진행 중, 타이머가 50% 이하로 떨어졌을 때 활성화
- 효과: 정답 재료 1개를 글로우 + 화살표 표시
- 사용 제한: **Round당 1회**
- UI: 화면 우측 하단 보상형 광고 아이콘 (`🎁 힌트`)

---

## 8. 데이터 의존성

GDD §6 스키마 기반. 본 메커닉이 요구하는 필드:

| 필드 | 용도 | Stage |
|------|------|-------|
| `Food.ingredients[]` | 정답 재료 셋 | 1 |
| `Food.cooking_methods[]` | 정답 조리 방법 (MVP: 1개) | 2 |
| `Food.cook_time_sec` | Stage 3 인디케이터 속도 결정 | 3 |
| `Food.difficulty` | Stage 1 타이머 길이, 디스트랙터 수 결정 | 1 |
| `Food.tier` | Round 보상 배수 | 채점 |
| `Ingredient.category` | **`store_type` 결정** (가게 매핑) | 1 |

### Ingredient.category → store_type 매핑 (다점포)
| category | store_type | 비고 |
|----------|-----------|------|
| 채소 | `vegetable_shop` (🥬 청과상) | |
| 육류 | `butcher` (🥩 정육점) | |
| 해산물 | `seafood_shop` (🐟 어물전) | |
| 곡물 | `grain_shop` (🌾 곡물상) | |
| 장류·양념·유제품·기타 (basic_pantry 제외) | `general_store` (🫙 잡화점) | basic_pantry 5종은 별도 `pantry`로 분리 (v0.6 C-2 lock) |
| **basic_pantry 5종 전용 (간장/고추장/설탕/참기름/소금)** | **`pantry` (🏺 kitchen rack 자동)** | **v0.6 신규 C-2 LOCK 2026-05-31**. ingredients-database.csv `store_type = pantry` field 5종 한정. Stage 1 진열대 미표시 + Scene 2 kitchen rack 자동 표시. Remote Config `cooking.basic_pantry_ingredient_ids` 운영. |

> GDD §6.2 신규 파생 필드. 매핑은 런타임 enum 또는 Remote Config로 노출하여 post-launch 가게 분할 시 유연성 확보.
> **v0.6 신규 `pantry` 카테고리**: 5가게 진열대 schema와 별도. godot-dev Resource(.tres) 스키마에 `store_type: StringName = &"pantry"` enum value 추가 필요. UI 측에서는 5가게 그리드에 표시되지 않고 Scene 2 kitchen rack 노드로 직접 instantiate.

### 디스트랙터 선정 알고리즘 (의사코드, 다점포 버전)
```csharp
// MVP — 가게별 디스트랙터 선정
Dictionary<StoreType, List<Ingredient>> BuildStoreShelves(
    Food food, int distractorPerStore)
{
    var correctSet = food.ingredients.ToHashSet();
    var shelves = new Dictionary<StoreType, List<Ingredient>>();

    // 1) 정답 재료를 store_type별로 분배
    foreach (var ing in food.ingredients)
    {
        var store = StoreMapping.For(ing.category);
        shelves.GetOrAdd(store).Add(ing);
    }

    // 2) 정답 있는 가게에만 같은 카테고리 디스트랙터 추가
    foreach (var (store, correctsInStore) in shelves.ToList())
    {
        var sameStorePool = ingredientDb
            .Where(i => !correctSet.Contains(i)
                     && StoreMapping.For(i.category) == store)
            .ToList();

        var picks = Shuffle(sameStorePool).Take(distractorPerStore);
        shelves[store].AddRange(picks);
        shelves[store] = Shuffle(shelves[store]).ToList();
    }

    // 3) 정답 없는 가게는 shelves에서 빠짐 (빈 가게 표시)
    return shelves;
}
```

---

## 9. 튜닝 파라미터 (Remote Config 후보)

런타임 튜닝을 위해 **Firebase Remote Config**로 노출:

| 키 | 기본값 | 설명 |
|----|--------|------|
| `cooking.stage1.penalty_per_wrong` | 0.15 | 오답당 정확도 감점 |
| `cooking.stage1.time_penalty_sec` | 1.0 | 오답당 시간 감점 |
| `cooking.stage3.perfect_width` | 0.10 | PERFECT 구간 너비 비율 |
| `cooking.stage3.perfect_width_ad` | 0.20 | 광고 적용 시 PERFECT 너비 |
| `cooking.early_finish_bonus_max` | 0.10 | early-finish 최대 가산 |
| `cooking.distractor_per_store_by_tier` | `[1,1,2,2,3]` | tier별 **가게당** 디스트랙터 수 (다점포 적용) |
| `scoring.star_thresholds` | `[50, 75, 90]` | ★1/★2/★3 임계 |

---

## 10. Decisions & Active Questions

### 10.1 Resolved Decisions (2026-05-23, game-designer)

| # | 질문 | 결정 |
|---|------|------|
| 1 | 앱 백그라운드 진입 처리 | Stage 1/2/3 모두 일시정지, 5분 초과 시 Round 폐기 |
| 2 | 연속 오답 spam 방지 | 탭 쿨다운 **200ms** + 동일 카드 페널티 누적 최대 3회 cap |
| 3 | 재료 많은 요리 UI | 8개 이하 단일 그리드, 9개 이상 **좌우 스와이프 페이지네이션 max 2p** (스크롤 회피). ※ 다점포 도입으로 가게당 표시량 분산되어 압력 ↓ |
| 4 | 저성능 단말 timing 왜곡 | `FixedUpdate` 인디케이터 + 렌더 보간. **60fps 미달 자동 감지 시 PERFECT 폭 +20% 보정** |
| 5 | 튜토리얼 구조 | **Stage 1만 풀 onboarding (3-step → 다점포 도입으로 4-step 확장)**, Stage 2/3은 1회성 hint(skip 가능). 상세는 `docs/systems/ftue.md` 분리 → ui-designer |
| 6 | 색각이상 접근성 | PERFECT 구간 **빗금 + 색상 이중**, Settings에 "고대비 모드" 토글 |
| 7 | 사운드 디자인 | 본 문서 범위 외 → **`docs/systems/sound-guide.md` 별도 신설** (art-director). MVP는 무료 라이브러리 placeholder |
| 8 | Scene 트랜지션 | 수퍼→키친 **0.8s 페이드+zoom**, 키친→식탁 **1.5s 서빙 모션**. Settings "빠른 트랜지션" 토글(0.3s) |
| 9 | 수퍼마켓 톤 (모던 vs 재래시장) | **재래시장 + 다점포 순회** 확정. 가게 5종(청과/정육/어물/곡물/잡화) — §2.2 참조 |
| 10 | 키친 meta-progression | **MVP 배제, Month 4+ 검토**. MVP는 단일 키친 |
| 11 | 식탁 캐릭터 시식 reaction | MVP는 **★3만 차별 reaction(와!), ★1/★2는 공통 nod**. 친구 5명 × 1 = 5컷 |
| 12 | Scene 1·2 tier별 변화 | **MVP는 단일** (재래시장 1세트, 키친 1세트). post-launch tier 3+ 키친에 손님 등장 확장. ※ #9 결정으로 Scene 1 자체가 5컷(가게 종류) + 입구 1컷 = **6컷 베이스** |

### 10.2 Active Follow-ups (재래시장 다점포 결정에서 파생)

- [ ] **가게 간판 시인성**: 입구 화면에서 5개 가게가 1-thumb portrait에 다 보여야 함. 가로 스크롤 vs 2×3 그리드 vs 부채꼴 → ui-designer 결정.
- [ ] **장바구니 미리보기 동작**: 입구·가게 내부 양쪽에서 항상 표시? 탭으로 확장 보기? 다점포 메커닉에서 진행 상황 가독성 중요.
- [ ] **빈 가게 페널티**: 정답 없는 가게 진입 시 — 빈 진열대만 보여주고 즉시 "이 가게에는 없어요" 토스트 후 자동 입구 복귀? 또는 수동 나가기? **권장: 빈 진열대 + 자동 1.5s 후 복귀** (시간 페널티는 충분).
- [ ] **튜토리얼 안내 표시 횟수**: 첫 1~2 round 정답 재료의 가게를 강조 표시 (`§2.4` 룰에 노트만 박음). 정확히 몇 round? → ftue 문서에서 확정.
- [ ] **post-launch 가게 분할 시 마이그레이션**: 잡화점 → 양념가게+잡화점 분리할 때 `Ingredient.store_type`을 Remote Config로 재맵핑 가능해야 함 (DB 수정 없이 라이브 전환).
- [ ] **아트 비용 재계산** (#12 영향): Scene 1 = 가게 5컷 + 재래시장 입구 1컷 = **최소 6컷** (이전 단일 수퍼마켓 1컷 대비 6배). art-director Phase 2 우선순위 재평가 필요.
- [ ] **사운드 다점포 hook 추가**: 가게 진입 종소리, 가게별 ambient (정육점 칼질, 어물전 얼음, 청과상 인사 등) → sound-guide.md에 반영.

---

## X. Motion Spec — Tool Animation Cross-Reference (v0.7 신설, M2 prerequisite D1)

> 본격 spec은 [`motion-spec.md` v0.1](motion-spec.md) 참조. 본 §X는 cooking-mechanics 본문 흐름에 motion 영역 위치만 명시.

### X.1 Stage 2A — 칼/도마 Knife indicator (11/12 음식) + 손바닥/marinade bowl (1/12 불고기)

- **시각 cue 통합 lock** (ADR-005): 별도 rhythm UI 없이 칼이 BPM-driven으로 자동 위↕아래 translate. 도마 닿기 직전 = perfect tap.
- **AnimationPlayer Transform animation only** (Option 1, 사용자 명시 2026-05-31). 추가 frame art 0건. 재료 변화 = whole sprite fade-out → cut sprite fade-in.
- 12 음식 × Stage 2A 도구·BPM·tap 수 매핑: [`motion-spec.md §2`](motion-spec.md#2-12-음식--stage--도구--motion-매핑-d1-main-표).
- AnimationPlayer keyframe spec: [`motion-spec.md §3.1`](motion-spec.md#31-칼-down-stroke-stage-2a-primary-1112-음식) (칼 down-stroke) + [`§3.3`](motion-spec.md#33-손바닥-marinade-press-stage-2a-불고기-only) (손바닥 marinade press).

### X.2 Stage 2B — 조리 방법 카드 (정적 도구 thumbnail)

- 카드 3~4장에 표시되는 도구 thumbnail은 정적 (motion 없음). M1 TOOL-01~12 sprite 직접 사용.
- 카드 선택 시 짧은 hover scale animation (1.0 → 1.05) 정도만, 별도 spec 불필요.

### X.3 Stage 2C — 도구 motion + timing bar

- timing bar 인디케이터 (cooking-mechanics §4) + 도구 motion이 병행. timing bar는 cooking-mechanics §4.4 perfect_width 정합. 도구 motion은 시각 ambient + 일부 음식(갈비·비빔밥·잡채)은 보조 rhythm 메커닉 후보 (M2 alpha 후 결정).
- 도구별 motion: [`motion-spec.md §3.2`](motion-spec.md#32-주걱-stir-stage-2c-5음식) 주걱 stir / [`§3.6`](motion-spec.md#36-국자-scoop-stage-2c-마무리-cue-3음식) 국자 scoop / [`§3.7`](motion-spec.md#37-집게-grip-and-lift-stage-2c-갈비구이) 집게 grip-and-lift / [`§3.8`](motion-spec.md#38-김발-roll-stage-2c-김밥-single-shot) 김발 roll / [`§3.9`](motion-spec.md#39-그릇주걱-bibim-orbit-stage-2c-비빔밥) bibim orbit / [`§3.10`](motion-spec.md#310-콘도그-반죽-dip-stage-2a-콘도그-substitute-칼-메커닉-대체) 콘도그 dip.

### X.4 Asset path 의존성

| Path | M1 출처 |
|------|--------|
| `assets-processed/tools/tool_01_stove.png` ~ `tool_12_scissors.png` | M1 TOOL-01~12 LOCK |
| `assets-processed/cuts/cut_00_marinade_board.png` ~ `cut_06_cube.png` | M1 CUT-00~06 LOCK (CUT-00 marinade anchor 신규 작성은 art-director open) |
| `assets-processed/ingredients/ing_*_whole.png` / `ing_*_cut.png` | M1 ingredient whole 12 + ingredient cut 12 LOCK |
| `assets-processed/hand_marinade.png` (TBD) | **art-director 미니 sprint 필요** (~$0.04 single sprite) |
| `assets-processed/corndog_batter_bowl.png` (TBD) | **art-director 미니 sprint 필요** OR M1 ingredient 흡수 |

### X.5 godot-dev 단계적 sprint plan (M2)

[`motion-spec.md §5.3`](motion-spec.md#53-단계적-구현-추천-순서-m2-sprint-plan) 참조. W1 라면 single end-to-end → W2 cut style 11종 확장 → W3 불고기 marinade → W4 Stage 2C 도구 6종 → W5+ 콘도그 dip + 김발 roll + alpha 검증.

---

## 11. 변경 이력
- **2026-05-31 v0.7** (supersedes v0.6): M2 prerequisite design sprint D1. **§X Motion Spec cross-ref 신설** — 12 음식 × Stage × 도구 × motion + BPM 매핑 본격 정의는 `motion-spec.md` v0.1로 분리, 본 문서는 mechanic 룰 유지 + motion 영역 참조만. Option 1 motion lock 명시 (Godot AnimationPlayer Transform animation only, frame art 추가 0건, single sprite 회전/이동/스케일 keyframe만). Asset path 의존성 표 (M1 LOCK 출처 명시 + art-director 미니 sprint 2건 권고: hand_marinade + corndog_batter_bowl). godot-dev 단계적 sprint plan cross-ref (W1~W5+).
- **2026-05-31 v0.6** (supersedes v0.5): **C-2 basic_pantry 정책 lock** ([`store-distribution.md` v1.3](../store-distribution.md) + [`balance-config.md` v0.3.3](../balance-config.md) sync). **§2.2.1 basic_pantry 자동 제외 룰 신설** (간장·고추장·설탕·참기름·소금 5종 Stage 1 진열대 미표시 + distractor pool 제외). **§2.2.7 Kitchen rack 자동 표시 신설** (Scene 1→2 transition 시 basic_pantry 5종 자동 표시, 시각 cue만, art-director 옹기 5종 anchor 후속). **§2.5 accuracy_ingredients 공식 갱신** (분모 N_effective = required.filter(NOT IN basic_pantry)). **§2A.X 양념재우기 정합 명시 신설** (양념 자동 제공 상태에서 marinade rhythm tap만, 양념 "고르기" 행위 X — 불고기/갈비구이 메커닉 정합 lock). **§8 store_type mapping에 `pantry` 카테고리 추가** (basic_pantry 5종 전용 enum, Resource(.tres) 스키마 sync 필요).
- **2026-05-26 v0.5** (supersedes v0.4): [ADR-005](../decisions.md#adr-005) 반영. **3-stage → 4-stage** (Stage 2A 재료 준비 신설, rhythm tap + Knife indicator). §1 Round 구조에 4-stage 흐름 요약 추가. **§5.2 채점 공식 곱셈 모델 → 가중 평균 공식 supersede** (재료 25% × 준비 20% × 방법 20% × 시간 35%, ★1 30/★2 60/★3 90). **§2A 신설** (placeholder, rhythm tap / Knife indicator / Cut Styles 6종 / Per-Food BPM / Skip 옵션 / FTUE 흐름 high-level 요약). 상세 룰은 game-designer v0.5 본격 sprint 이월.
- **2026-05-23 v0.4**: ADR-003 (MVP-first) 반영. §0에 MVP Scope callout 추가 — 5-tier 디자인 비전 유지, MVP 구현은 Tier 1~2 / 음식 10~15 / 친구 1~2 / 식탁 2종 / 다점포 5가게 유지. 메커닉 정의 자체는 변경 없음.
- **2026-05-23 v0.3**: §10 12개 open question 일괄 resolve (game-designer). Scene 1을 **재래시장 다점포(가게 5종: 청과/정육/어물/곡물/잡화)** 메커닉으로 재작성 — §2 전면 개정(가게 매핑, UI 흐름, 룰, 디스트랙터 정책, 메커닉 함의). §8 데이터 의존성에 `store_type` 매핑 추가, §9 Remote Config 키 변경(`distractor_per_store_by_tier`). §10.2 다점포 follow-up 7항 신설.
- **2026-05-23 v0.2**: 3-scene 구조 명시 (수퍼마켓 → 키친 → 식탁). 각 Stage UI에 scene 라벨, Section 5에 식탁 화면 구성(캐릭터 시식 연출, tier별 식탁) 신설. open questions에 트랜지션·아트 비용·meta-progression 5항 추가.
- **2026-05-23 v0.1**: 초안 — Stage 1/2/3 룰, 채점 공식, 디스트랙터 알고리즘, Remote Config 키.
