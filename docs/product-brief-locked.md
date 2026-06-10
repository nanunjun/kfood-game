# Master Product Brief — LOCKED (Polish Phase Direction)

> Status: **LOCKED** · Codified: 2026-06-05 · Owner: **pm**
> Source: 사용자 제시 Master Product Brief (verbatim mandate). 본 문서는 canonical 박제본.
> 정합: [ADR-013](decisions.md#adr-013) (Polish Phase Direction) / [GDD §Vision §Roadmap](GDD.md) / [roadmap-polish-phase.md](roadmap-polish-phase.md)
> 이 문서가 polish 단계의 product source of truth. 충돌 시 본 문서 우선 (ADR-013에 의해 lock).

---

## 0. Why this document exists

직전까지 sprint는 **feature/system 확장** 모드였다 (ADR-009 Guest 2.0 / ADR-010 Result 2.0 / ADR-011 8-module / ADR-012 action-first). 사용자가 방향을 **전환**:

> **Presentation > Features. Emotion > Numbers. Polish > Complexity.**
> "Do not add new systems until production quality is achieved."

본 brief는 이 mandate를 박제하고, 현 프로젝트 상태와 정합한다. **no new gameplay systems** — 방향 codify + 정합만.

---

## 1. Core Mandate (LOCKED)

### 1.1 우선순위 공식
- **Presentation > Features**
- **Emotion > Numbers**
- **Polish > Complexity**
- "Do not add new systems until production quality is achieved."

### 1.2 NOT prioritize (명시적 stop list)
지금 단계에서 **하지 않는다**:
- new game modes
- new currencies
- ads
- IAP
- analytics
- remote config
- monetization
- feature expansion

> 위 항목은 GDD에 설계가 이미 존재하나(§5 Monetization, §11 KPI 등) **polish 단계에서는 동결**. post-polish 재개.

### 1.3 Product Vision
**"Korean Food Discovery Game"** — NOT a Cooking Fever clone.

### 1.4 Player가 느껴야 하는 4가지
1. **I cooked Korean food** (내가 한식을 요리했다)
2. **I learned about Korean food** (한식을 배웠다)
3. **My guest enjoyed it** (내 손님이 즐겼다)
4. **I want to cook for this guest again** (이 손님을 위해 또 요리하고 싶다)

---

## 2. Five Core Pillars (LOCKED)

### Pillar 1 — Korean Food Authenticity
- 8 dishes 각자 다르게 표현, gameplay만으로 어떤 dish인지 인식 가능해야.
- 8 dish: **Ramyeon / Gimbap / Bibimbap / Kimchi Stew / Galbi / Japchae / Tteokbokki / Sundubu Jjigae**.
- 현 정합: 우리 codebase는 음식 12개(ADR-003). brief의 8 dish는 **hero 우선순위 셋** — 8 dish를 production-quality 최우선, 나머지 4는 그 다음. 음식 수 축소 X.

### Pillar 2 — Cooking Action Authenticity
- 기존 **8 module 유지** (추가 X). 폰 자체가 cooking tool.
- **Casual Mode (default)**: 간단 tap / drag / one-handed.
- **Immersive Mode (optional)**: slice→knife swipe / season→shake / stir→circular / flip→pan flick / timing→pour+stop / roll→mat gesture.
- "**Retention > realism**".
- 현 정합: ADR-012 action-first gesture = **Immersive Mode**에 해당. Casual Mode default는 **신규 정합 사안 #1** (§5.1).

### Pillar 3 — Guest Relationships
- guests = **characters**, not stat dispensers.
- "Junho loves spicy food" NOT "Junho gives +15% coins".
- avatars / emotions / reactions / friendship 우선.
- 현 정합: ADR-009 Guest 2.0 데이터(compat/reward_bonus)는 백엔드 유지하되, **표시·체감은 character 언어로** (friendship/mood/flavor preference 자연어). compat % UI 비표시 정책(ADR-009 §7)과 이미 정합.

### Pillar 4 — Emotional Reward
- **Result Screen이 가장 중요**.
- 표시 순서 (LOCKED): ① **Guest reaction** → ② **Friendship gain** → ③ **Reward** → ④ **Score breakdown**.
- 현 정합: 현 Result 2.0(ADR-010)은 dish summary → emotion → score → breakdown → rewards = **역순**. **신규 정합 사안 #2** (§5.2) → P4 Result Screen Rebuild.

### Pillar 5 — Korean Food Learning
- optional / never interrupt / **<5s**.
- 4 fact 유형: **Food Fact / Ingredient Fact / Cooking Tip / Culture Fact**.
- 현 정합: 미구현. **신규 todo** (P5 Learning Layer V1).

---

## 3. Sub-systems (LOCKED spec)

### 3.1 Food Critic System
- **Michelin 사용 금지** → fictional brand only: **Golden Spoon Inspector / Master Food Critic / Heritage Food Reviewer**.
- Unlock flow: **Dish Mastery → Critic Appears → Special Evaluation → Critic Badge → One-Time Reward**.
- Rewards: Friendship boost / Reputation / Encyclopedia unlock / Korean food fact / Badge.
- **No repeat farming** (one-time per mastery).
- 현 정합: `goldspoon` = **"Golden Spoon Inspector"** 이미 `guests.csv`에 evaluator로 존재 (fictional brand 준수). unlock flow wiring만 todo. **정합 사안 #3** (§5.3).

### 3.2 Haptic Design
- ONLY 다음 6 이벤트에만 haptic:
  1. Perfect action
  2. Excellent dish
  3. Friendship level up
  4. New recipe unlock
  5. Critic success
  6. New record
- Never every tap. No spam. Android-friendly.
- 현 정합: `HapticManager` autoload 존재. trigger allowlist 정비만 필요 (P4/P6 wiring 시).

### 3.3 Art Direction LOCK
- 현 visual = **prototype level** — biggest weakness = **presentation quality**.
- Focus 순서: ① **Environment** ② **Character** ③ **Food presentation** ④ **VFX** ⑤ **Animation**.
- Target references: **Cooking Diary / Animal Restaurant / Travel Town**.
- **NOT Royal Match** (outside scope — Royal Match-tier match-3 polish는 본 게임 범위 밖).
- Screenshot 하나로 "Korean food game" 인식 가능해야.

### 3.4 Environment Roadmap (빈 배경 교체)
| Level | Environment |
|-------|-------------|
| L1 | Home Kitchen |
| L2 | Neighborhood Snack Shop |
| L3 | Traditional Korean Market |
| L4 | Famous Food Alley |
| L5 | Prestige Korean Restaurant |

- 현 정합: 현 BG-01~05 = **storefront(가게)** art (procedural MarketBG, 미통합). brief의 L1~L5 = **요리 환경 진화** → **신규 art 5종 필요**. **정합 사안 #5** (§5.5).

---

## 4. Six Immediate Priorities (LOCKED order)

| # | Priority | 한 줄 |
|---|----------|-------|
| **P1** | D1+D2+D3 Visual Package | placeholder dish / orange buttons / beige void / result hierarchy 제거 |
| **P2** | Avatar + Emotion Polish | guest avatar + 4 emotion production quality |
| **P3** | Cooking Background System | level별 cooking 환경 (빈 배경 교체) |
| **P4** | Result Screen Rebuild | emotion-first 순서 (① reaction ② friendship ③ reward ④ score) |
| **P5** | Learning Layer V1 | optional / <5s / 4 fact 유형 |
| **P6** | Food Critic System | mastery → critic → badge → one-time reward (no farming) |

> done/todo audit는 §6 + [roadmap-polish-phase.md](roadmap-polish-phase.md).

---

## 5. 정합 사안 5건 (현 상태 reconciliation)

### 5.1 [사안 #1] Casual / Immersive Mode 정합
- **현황**: ADR-012로 8 module 전부 gesture 기반(slice drag / timing heat dial / season tilt / stir circular / arrange drag-slot / roll bamboo mat / flip flick / plate drag) 구현 완료 = brief 정의상 **Immersive Mode**.
- **brief**: **Casual Mode (간단 tap/drag/one-handed)가 default**, Immersive는 optional.
- **해소 방향 (권고, ADR-013에서 lock)**:
  - 현 gesture 구현을 **Immersive Mode로 재라벨링** (코드 재작성 X — 이미 만든 자산 보존).
  - **Casual Mode = 각 gesture의 단순화 variant** (예: slice = 한 번 tap-and-hold drag / season = 1-tap auto-pour 복귀 / stir = 짧은 swipe 1회 / timing = single tap zone). 4-factor scoring·signal contract·sequence 무변경, **입력 난이도만 완화**.
  - **default = Casual**, settings/onboarding에서 Immersive opt-in. "Retention > realism" 준수.
  - scope: **input-layer variant only**. ADR-012의 input 인프라(TouchGestureRecognizer) 재활용. 신규 system 아님.
- **owner**: game-designer (casual variant spec) → godot-dev (impl) → ui-designer (mode toggle UX). art-director 무관.

### 5.2 [사안 #2] Result Screen 순서
- **현황 (ADR-010)**: dish summary → emotion → score breakdown(6 row) → rewards.
- **brief**: ① Guest reaction → ② Friendship gain → ③ Reward → ④ Score breakdown.
- **해소 방향**: **P4 Result Screen Rebuild** — display 순서 재배치 (emotion-first). 데이터·scoring·SaveManager schema 무변경 = pure reorder + emphasis 재조정. score breakdown은 마지막 + collapsible(접힘) default.
- **owner**: ui-designer (reorder layout spec) → godot-dev (result_screen_v2.gd 재배치). game-designer는 friendship gain 강조 룰만.

### 5.3 [사안 #3] Food Critic = Golden Spoon
- **현황**: `goldspoon` = "Golden Spoon Inspector" evaluator guest 이미 존재 (`guests.csv` row 11, fictional brand 준수 = Michelin 회피 충족). 현재는 특정 level에서 일반 guest 대신 등장하는 정도.
- **brief**: unlock flow = Dish Mastery → Critic Appears → Special Evaluation → Critic Badge → One-Time Reward. No repeat farming.
- **해소 방향**: **P6 Food Critic System** — 기존 goldspoon 활용 + Recipe XP(ADR-010, 음식별 Lv 1~10 누적) 를 **Dish Mastery 트리거**로 wire. Mastery(예: 특정 음식 Recipe Lv ≥ 7) 도달 → critic appears → special eval → badge + one-time reward(friendship boost / encyclopedia unlock / Korean food fact). farming 방지 = (food, critic) badge 1회만.
- **owner**: game-designer (unlock flow + mastery threshold + reward 매핑) → godot-dev (wiring). art-director (critic badge art, 선택).

### 5.4 [사안 #5] 환경 roadmap
- **현황**: BG-01~05 = storefront(가게) art, procedural MarketBG로 placeholder 상태. P3 Cooking Background System은 generic warm-tone CookingBackground로 일부 완료(아래 §6 참조).
- **brief**: L1 Home Kitchen / L2 Snack Shop / L3 Market / L4 Food Alley / L5 Prestige Restaurant — **level별 cooking 환경 진화**.
- **해소 방향**: 현 storefront BG는 menu/guest select 화면에서 유지. **cooking 화면의 환경 5종(L1~L5)은 신규 art** → art-director (art-style lock 후 또는 polish anchor 우선). godot-dev는 level → environment 매핑 hook.
- **owner**: art-director (환경 5종 art) → godot-dev (level별 environment swap).

### 5.5 [사안 #4] done audit
- P1/P2/P3는 최근 sprint에서 **상당 부분 완료** (§6). P4/P5/P6가 실질 신규 todo. 정합 audit 결과 = 방향만 재정렬, 재작업 최소.

---

## 6. 6 Priority Done/Todo Audit (현 상태 기준 2026-06-05)

| Priority | 완료% | Done | Todo | Primary owner |
|----------|------|------|------|---------------|
| **P1 D1+D2+D3 Visual Package** | **~85%** | dish hero card / sprite stars / NEW RECORD ribbon 재배치 / ActionPuck→action-first / CookingBackground / steam VFX / dish shadow (commit 08fe489 외) | placeholder dish thumbnail crop(#7) / sticky CTA wallet pill(#9) / milestone toast position(#10) / guest_select avatar quality(#6) 잔여 4건 | godot-dev (+art-director assets) |
| **P2 Avatar + Emotion Polish** | **~70%** | 5 guest avatar + 4 emotion(neutral/happy/excited/disappointed) 데이터·구조 / emotion_reaction.gd hero mode | guest avatar **production-quality art** (현 placeholder/일부 LOCK), mother/father import, critic avatar | art-director (art) → godot-dev (import) |
| **P3 Cooking Background System** | **~50%** | generic CookingBackground (3-band procedural) + steam + shadow | **level별 L1~L5 환경 art 5종** (현 generic warm-tone) + level→env 매핑 | art-director (5종) → godot-dev (swap) |
| **P4 Result Screen Rebuild** | **~30%** | Result 2.0 구조·데이터(6 row / emotion / Recipe XP / NEW RECORD / milestone) 존재 | **emotion-first 순서 재배치** (① reaction ② friendship ③ reward ④ score) + score collapsible | ui-designer (reorder) → godot-dev |
| **P5 Learning Layer V1** | **~0%** | (없음) | Food/Ingredient/Cooking Tip/Culture Fact 4종 콘텐츠 + <5s non-blocking 노출 UI | game-designer (content) → ui-designer (UX) → godot-dev |
| **P6 Food Critic System** | **~20%** | goldspoon="Golden Spoon Inspector" evaluator 존재 + Recipe XP(mastery 후보 메트릭) | mastery→critic→badge→one-time reward flow wire + no-farming guard + 2 추가 critic(Master Food Critic / Heritage Food Reviewer) | game-designer (flow) → godot-dev |

---

## 7. Success Criteria (LOCKED)

10분 플레이 후 **US player**가 기억해야:
- one Korean **dish**
- one Korean **ingredient**
- one **guest character**
- 그리고 "**I want to cook Korean food again**".

이 기준이 polish 단계 ship 게이트. KPI(retention/ARPDAU 등 GDD §11)는 polish 단계에서 동결 — 위 4 기억 기준이 우선.

---

## 8. 정합 결론

- 음식 12 / Tier 1~2 / 8 module / 4-factor scoring / Guest 2.0 데이터 / Result 2.0 구조 = **전부 유지**. 본 brief는 이 위에 **presentation·emotion·polish layer**만 얹는다.
- **신규 gameplay system 0건**. P4=reorder / P5=content+UX / P6=기존 evaluator wiring / 환경=art. 전부 polish/presentation.
- ADR-013에서 본 방향 + Casual/Immersive 정합 + 6 priority lock 공식화.

## 변경 이력
- **v1.0 (2026-06-05)** — Master Product Brief 박제 + 현 상태 정합 (5 pillars / 6 priorities / 정합 사안 5건 / done audit / success criteria). pm.
