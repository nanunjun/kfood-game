# Cooking Mechanics

> 버전: **v0.5 (2026-05-26, supersedes v0.4)** — [ADR-005](../decisions.md#adr-005) 4-stage 추가
> 작성일: 2026-05-23 · 최종 개정: 2026-05-26
> 상위 문서: [`../GDD.md`](../GDD.md) §2 Core Loop / §3 Scoring System
> 본 문서는 GDD §2의 **4단계** cooking matching 루프를 **구현 가능한 수준**으로 상세화한다.
>
> ⚠️ **v0.5 high-level 갱신만**. §2 Core Loop / §3 Scoring 헤더 sync + §X 재료 준비 placeholder. 상세 룰(rhythm tap / Knife indicator / Perfect/Good/Miss 판정 / Skip 옵션 / FTUE rhythm 흐름 / 음식별 BPM·tap 매핑)은 **game-designer v0.5 본격 sprint**.

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
| 잡화점 | 🫙 | 장류, 양념, 유제품, 기타 |

> Post-launch 확장 후보: 잡화점 → 양념가게 + 잡화점 분리 (장류 비중 ↑ 시), 떡집/방앗간 신설.

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

### 2.5 Accuracy 계산
```
correct_picks    = 선택한 재료 중 정답 개수
wrong_picks      = 선택한 재료 중 오답 개수
required         = 정답 재료 총 개수 (N)

accuracy_ingredients =
    clamp01( correct_picks / required  -  PENALTY_PER_WRONG * wrong_picks )

PENALTY_PER_WRONG = 0.15   // 튜닝 대상
```
> 다점포 도입은 accuracy 공식 자체에는 영향 없음. 오답 가게 진입은 accuracy에 무관 (시간만 손해).

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
| category | store_type |
|----------|-----------|
| 채소 | `vegetable_shop` (🥬 청과상) |
| 육류 | `butcher` (🥩 정육점) |
| 해산물 | `seafood_shop` (🐟 어물전) |
| 곡물 | `grain_shop` (🌾 곡물상) |
| 장류, 양념, 유제품, 기타 | `general_store` (🫙 잡화점) |

> GDD §6.2 신규 파생 필드. 매핑은 런타임 enum 또는 Remote Config로 노출하여 post-launch 가게 분할 시 유연성 확보.

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

## 11. 변경 이력
- **2026-05-26 v0.5** (supersedes v0.4): [ADR-005](../decisions.md#adr-005) 반영. **3-stage → 4-stage** (Stage 2A 재료 준비 신설, rhythm tap + Knife indicator). §1 Round 구조에 4-stage 흐름 요약 추가. **§5.2 채점 공식 곱셈 모델 → 가중 평균 공식 supersede** (재료 25% × 준비 20% × 방법 20% × 시간 35%, ★1 30/★2 60/★3 90). **§2A 신설** (placeholder, rhythm tap / Knife indicator / Cut Styles 6종 / Per-Food BPM / Skip 옵션 / FTUE 흐름 high-level 요약). 상세 룰은 game-designer v0.5 본격 sprint 이월.
- **2026-05-23 v0.4**: ADR-003 (MVP-first) 반영. §0에 MVP Scope callout 추가 — 5-tier 디자인 비전 유지, MVP 구현은 Tier 1~2 / 음식 10~15 / 친구 1~2 / 식탁 2종 / 다점포 5가게 유지. 메커닉 정의 자체는 변경 없음.
- **2026-05-23 v0.3**: §10 12개 open question 일괄 resolve (game-designer). Scene 1을 **재래시장 다점포(가게 5종: 청과/정육/어물/곡물/잡화)** 메커닉으로 재작성 — §2 전면 개정(가게 매핑, UI 흐름, 룰, 디스트랙터 정책, 메커닉 함의). §8 데이터 의존성에 `store_type` 매핑 추가, §9 Remote Config 키 변경(`distractor_per_store_by_tier`). §10.2 다점포 follow-up 7항 신설.
- **2026-05-23 v0.2**: 3-scene 구조 명시 (수퍼마켓 → 키친 → 식탁). 각 Stage UI에 scene 라벨, Section 5에 식탁 화면 구성(캐릭터 시식 연출, tier별 식탁) 신설. open questions에 트랜지션·아트 비용·meta-progression 5항 추가.
- **2026-05-23 v0.1**: 초안 — Stage 1/2/3 룰, 채점 공식, 디스트랙터 알고리즘, Remote Config 키.
