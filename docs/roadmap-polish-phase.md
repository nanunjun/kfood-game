# Roadmap — Polish Phase (6 Priorities)

> Status: **Active** · 작성: 2026-06-05 · Owner: **pm**
> 근거: [product-brief-locked.md](product-brief-locked.md) §4 §6 / [ADR-013](decisions.md#adr-013)
> mandate: **Presentation > Features. Emotion > Numbers. Polish > Complexity. No new gameplay systems.**

본 로드맵은 polish 단계 6 priority의 done/todo + owner + 의존성 + sequencing. MVP feature는 동결, presentation/emotion/polish만 진행.

---

## 0. Phase 정의

- **이전 단계 (완료)**: feature/system 구축 — ADR-009 Guest 2.0 / ADR-010 Result 2.0 / ADR-011 8-module / ADR-012 action-first.
- **현 단계 (Polish)**: 위 system을 **production-quality presentation**으로 끌어올림. 신규 system 추가 X.
- **ship 게이트**: [product-brief-locked.md §7](product-brief-locked.md) success criteria (10분 후 US player가 dish/ingredient/guest 1개씩 + "cook again" 욕구).

---

## 1. Six Priorities — Detail

### P1 — D1+D2+D3 Visual Package · 완료 ~85%
**목표**: placeholder dish / orange buttons / beige void / result hierarchy 결함 제거.

- **Done**: dish hero card / 5-point sprite stars / NEW RECORD ribbon 재배치 / 8 module ActionPuck→action-first / CookingBackground 3-band / steam VFX / dish shadow. Critical Issue 10 중 #1·#2·#3·#4·#5·#8 해결.
- **Todo (잔여 4건)**: #6 guest_select avatar quality / #7 menu_select dish thumbnail crop / #9 sticky CTA wallet pill formatting / #10 milestone toast position.
- **Owner**: godot-dev (impl) + art-director (sparkle/steam particle PNG, 선택).
- **의존성**: 없음 (독립). P2 art와 #6 공유.

### P2 — Avatar + Emotion Polish · 완료 ~70%
**목표**: guest를 character로 느끼게 — avatar + 4 emotion production quality.

- **Done**: 5 guest avatar + 4 emotion(neutral/happy/excited/disappointed) 데이터·구조 / `emotion_reaction.gd` hero mode (avatar 320px + speech bubble enlarge).
- **Todo**: guest avatar **production-quality art** (현 placeholder/일부 LOCK) / mother·father LOCK import / critic avatar(P6 공유) / emotion 전용 일러스트로 mood_badge 재활용분 교체(선택).
- **Owner**: art-director (avatar+emotion art) → godot-dev (import + wiring).
- **의존성**: art-style lock 권고(R-A14). P4 Result Screen이 emotion을 primary focal로 쓰므로 **P4보다 art 선행 권고**.

### P3 — Cooking Background System · 완료 ~50%
**목표**: 빈/generic 배경 → level별 한식 cooking 환경 (screenshot으로 "Korean food game" 인식).

- **Done**: generic CookingBackground (3-band procedural: warm wall / spotlight working area / countertop) + steam + dish shadow. Awning bleed(#8) 해결.
- **Todo**: **L1 Home Kitchen / L2 Neighborhood Snack Shop / L3 Traditional Korean Market / L4 Famous Food Alley / L5 Prestige Korean Restaurant** 5종 환경 art (현 generic warm-tone 대체) + level→environment 매핑 hook.
- **Owner**: art-director (환경 5종) → godot-dev (level별 swap).
- **의존성**: art-style lock(R-A14). Art Direction LOCK refs = Cooking Diary / Animal Restaurant / Travel Town (NOT Royal Match).

### P4 — Result Screen Rebuild · 완료 ~30%
**목표**: emotion-first 순서 — Result Screen이 가장 중요(Pillar 4).

- **순서 (LOCKED)**: ① **Guest reaction** → ② **Friendship gain** → ③ **Reward** → ④ **Score breakdown**(collapsible default).
- **현황**: 현 Result 2.0(ADR-010) = dish summary → emotion → score → breakdown → rewards (역순).
- **Done**: Result 2.0 구조·데이터(6 row breakdown / 4 emotion / Recipe XP / NEW RECORD / milestone) 전부 존재.
- **Todo**: **display 순서 재배치** (emotion 최상단 hero / friendship gain 강조 / reward / score breakdown 마지막+접힘). 데이터·scoring·SaveManager schema **무변경** = pure reorder + emphasis.
- **Owner**: ui-designer (reorder layout spec) → godot-dev (`result_screen_v2.gd` 재배치) → game-designer (friendship gain 강조 룰).
- **의존성**: P2 emotion art(emotion이 primary focal) 선행 권고. 단 reorder 자체는 art 없이도 placeholder로 진행 가능.

### P5 — Learning Layer V1 · 완료 ~0%
**목표**: 한식 학습 — optional / never interrupt / **<5s**.

- **4 fact 유형**: Food Fact / Ingredient Fact / Cooking Tip / Culture Fact.
- **Todo**: 4종 fact 콘텐츠(음식 12 + 핵심 재료 기준) + non-blocking 노출 UI(<5s, dismissable, gameplay 중단 X — 예: loading / result idle / encyclopedia entry).
- **Owner**: game-designer (fact content + 노출 지점 룰) → ui-designer (non-blocking UX) → godot-dev (impl).
- **의존성**: 없음 (독립). content-heavy, parallel 가능.

### P6 — Food Critic System · 완료 ~20%
**목표**: Dish Mastery 보상 — fictional critic + one-time reward (no farming).

- **Critics (fictional, Michelin 금지)**: Golden Spoon Inspector(=기존 goldspoon) / Master Food Critic / Heritage Food Reviewer.
- **flow (LOCKED)**: Dish Mastery → Critic Appears → Special Evaluation → Critic Badge → One-Time Reward.
- **rewards**: Friendship boost / Reputation / Encyclopedia unlock / Korean food fact / Badge.
- **Done**: goldspoon="Golden Spoon Inspector" evaluator 존재 + Recipe XP(mastery 후보 메트릭).
- **Todo**: mastery 트리거(예: Recipe Lv ≥ 7) wire → critic appears → special eval → badge → one-time reward. **no-farming guard** ((food, critic) badge 1회). +2 critic 추가.
- **Owner**: game-designer (mastery threshold + flow + reward 매핑) → godot-dev (wiring) → art-director (critic badge/avatar, 선택).
- **의존성**: ADR-010 Recipe XP(mastery 메트릭) + P5 encyclopedia/food fact(reward 종류 일부 공유).

---

## 2. Owner Fan-out Summary

| Owner | Priorities | 작업 성격 |
|-------|-----------|-----------|
| **art-director** | P2 avatar+emotion, P3 환경 5종, P1/P6 보조 art | art-style lock 후 production art (R-A14) |
| **ui-designer** | P4 result reorder, P5 learning UX, P1 잔여 layout | layout/flow spec only |
| **game-designer** | P5 fact content, P6 critic flow, 사안#1 casual variant spec | content/balance/flow, 코드 X |
| **godot-dev** | 전 priority impl (P4 reorder / P5·P6 wire / casual mode input / env swap / P1 잔여) | `godot-project/scripts/**` |

---

## 3. Sequencing & Dependencies

```
art-style lock (R-A14) ──┬─→ P2 avatar+emotion art ──┐
                         └─→ P3 환경 5종 art          │
                                                       ▼
P1 잔여 (독립, 즉시) ─────────────────────────→ [godot-dev impl stream]
                                                       ▲
P4 result reorder spec (ui) ──── emotion art 선행 권고 ─┤  (placeholder로 선행 가능)
P5 learning content (game-designer, 독립) ────────────┤
P6 critic flow (game-designer) ── Recipe XP 의존 ──────┘
사안#1 casual variant spec (game-designer) ───────────→ godot-dev input variant
```

### 권고 실행 순서 (ROI 기준)
1. **P4 Result Screen reorder** — **최우선**. ROI 최고: Pillar 4("가장 중요") 직결 + 데이터/코드 무변경 reorder라 비용 최소, emotion-first가 success criteria("guest enjoyed it") 직접 충족. art 없이 placeholder로 즉시 착수 가능.
2. **P5 Learning Layer V1** — 차순위. 독립 + content-heavy라 game-designer 병렬 fan-out 가능. success criteria("I learned about Korean food") 직접 충족. UX는 non-blocking이라 코드 surface 작음.
3. **P6 Food Critic System** — 3순위. 기존 goldspoon + Recipe XP wiring이라 신규 system 0. 단 mastery 도달 = 후반 콘텐츠라 즉시 체감 ROI는 P4/P5보다 낮음 (long-tail).
4. **사안#1 Casual Mode** — P4와 병렬. default 난이도 완화는 retention 직결("Retention > realism").
5. **P2/P3 art** — art-style lock(R-A14) 게이트 통과 후. presentation quality의 근본이나 art-style 결정 선행 필요.

> R-A14(art-style reset 의존)가 P2/P3 art의 게이트. art-style lock 전까지 P4(reorder)/P5(content)/P6(flow)/사안#1(casual spec) = **art 무관 트랙**으로 먼저 소화.

---

## 4. Scope Guard (동결 항목)

polish 단계에서 **추가하지 않음** (brief §1.2): new game modes / currencies / ads / IAP / analytics / remote config / monetization / feature expansion. 6 priority 전부 presentation·emotion·polish·content layer — 신규 gameplay system 0.

## 변경 이력
- **v1.0 (2026-06-05)** — 6 priority done/todo + owner + 의존성 + sequencing + ROI 권고. pm.
