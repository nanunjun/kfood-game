# Screen Flow — 전체 화면 전이도

> 버전: **v0.3** · 갱신일: 2026-05-31 · 작성자: ui-designer
> 상위 문서: [`../GDD.md`](../GDD.md) §2 Core Loop, [`../systems/cooking-mechanics.md` v0.6](../systems/cooking-mechanics.md), [`../decisions.md` ADR-003](../decisions.md#adr-003-mvp-first-전환--34개월-출시--점진-확대-supersedes-adr-002), [`../decisions.md` ADR-005](../decisions.md#adr-005), [`../decisions.md` ADR-007](../decisions.md#adr-007), [`../art-style-guide.md`](../art-style-guide.md), [`../systems/mvp-food-selection.md`](../systems/mvp-food-selection.md)
> 관련 문서: [`scene-2-kitchen-layout.md` v0.1](scene-2-kitchen-layout.md), [`components.md` v0.3](components.md), [`tier-1-2-flow.md`](tier-1-2-flow.md), [`ftue.md`](ftue.md)
> **MVP scope**: Tier 1~2, 친구 1~2명, 다점포 5가게, Scene 3 식탁 2종, **ADR-005 4-stage** (Stage 2A 재료 준비 / Stage 2B 조리 방법 / Stage 2C 조리 시간).
> **Out of scope (post-launch placeholder만)**: Tier 3~5 친구 초대 / 파티 모드 / 다중 요리.

> **v0.3 변경 (2026-05-31)**: ADR-005 4-stage 정합. 기존 v0.1 = 3-stage (Stage 1 / 2 / 3) → v0.3 = **4-stage** (Stage 1 → Scene 2 안의 Sub-flow Stage 2A / 2B / 2C). §2 ROUND 다이어그램 4-stage 재작성 + §4 Scene 2 sub-flow 전면 재작성 (구 §4.1 Stage 2 → §4.1 Stage 2A 재료 준비 신설 + §4.2 Stage 2B 조리 방법 + §4.3 Stage 2C 조리 시간으로 분리). §2.1 광고 트리거 표 Stage 2C 표기 sync. §7 전이 매트릭스 Stage 2A→2B→2C 행 신규. ADR-007 Kitchen rack 시각 cue (basic_pantry 5종) §4.0 신규 + §6 공통 UI에 Kitchen rack 행 추가. Decisions SF-07~10 신설. 상세 layout은 `scene-2-kitchen-layout.md` v0.1 위임.

---

## 0. 다이어그램 컨벤션

- **ASCII 박스 다이어그램** 통일 (Mermaid는 GitHub 외부 환경 호환성 떨어짐).
- 화살표 `──▶` = scene/screen 트랜지션, `┄┄▶` = optional/conditional.
- `📺 [Rewarded]` / `🟦 [Interstitial]` / `🟩 [Banner]` = 광고 트리거 위치.
- `🔊` = 사운드 hook 위치(M2~M3 deferred, 위치만 mark).
- `⚙️` = pm/game-designer confirm 필요 항목.

---

## 1. 앱 부트 흐름

```
┌──────────────┐
│   📱 App     │
│   Launch     │
└──────┬───────┘
       │ 자동 (≤2s)
       ▼
┌──────────────────────────────┐
│   Splash Screen              │
│   - Studio logo (1.5s)       │
│   - K-Food Master 마스코트   │  🔊 startup chime
│   - "터치하여 시작" 안내     │  (FTUE 첫 부트만)
└──────┬───────────────────────┘
       │ 탭 또는 자동 (3s)
       ▼
┌──────────────────────────────┐
│   Main Menu                  │  🟦 Interstitial (NOT here — FTUE 5분 이내 차단)
│   ┌──────────────────────┐   │  🟩 Banner (하단 고정, IAP Remove Ads 시 숨김)
│   │ ▶ 플레이 (CTA 大)    │   │
│   │ 📔 도감 (post-launch │   │
│   │      placeholder)    │   │
│   │ ⚙️ 설정              │   │
│   │ 🛒 상점 (Coin/Ads)   │   │
│   └──────────────────────┘   │
│   상단 HUD: 코인·라이프·★    │
└──────┬───────────────────────┘
       │ "플레이" 탭
       ▼
┌──────────────────────────────┐
│   Level Select               │  (MVP는 단순 progression — 가로 스와이프 25레벨)
│   - 현재 레벨 강조           │  ⚙️ FTUE 직후엔 자동 Level 1 진입(스킵)
│   - 잠긴 레벨은 회색          │
│   - Tier 경계 L10→L11에       │
│     "가족 식사 unlock" 배너   │
└──────┬───────────────────────┘
       │ 레벨 탭 → Round 시작
       ▼
   (§2 Round 3-scene 흐름)
```

### 1.1 부트 분기

- **첫 부트** → FTUE 4-step 강제 진입 (Level 1 자동 시작). 상세 [`ftue.md`](ftue.md).
- **2번째+ 부트** → Main Menu 표시, 마지막 플레이 레벨 자동 강조.
- **Tier 2 첫 진입** (L11) → Level Select에서 "어머니 unlock" 컷씬 1회 (스킵 가능). FTUE 일부 **아님**.

---

## 2. Round 내 3-Scene 전이도

Round 1개 = Scene 1 → Scene 2 → Scene 3 (총 30~60초). cooking-mechanics §1 다이어그램에 UI/광고/사운드 hook overlay.

```
┌─────────────────────────────────────────────────────────────────┐
│   ROUND START (요리 배정 카드 1.0s overlay)                     │
│   - 요리 이름·인분·필요 재료 N개 노출                            │  🔊 round_start_jingle
└────────────────────────────────┬────────────────────────────────┘
                                 │ 0.8s 페이드+zoom (cooking-mech §10.1 #8)
                                 ▼
╔═════════════════════════════════════════════════════════════════╗
║  Scene 1 — 🏪 재래시장 (다점포 순회)                            ║
║  Stage 1: 재료 선택 (15~30s 공통 타이머)                        ║
║  ┌─────────────────────────────────────────────────────────┐    ║
║  │  §3 sub-flow 참조 (가게 5종 순회)                       │    ║
║  └─────────────────────────────────────────────────────────┘    ║
║  IN: 페이드+zoom 0.8s    OUT: "귀가 트랜지션" ≤1.5s             ║
║  스킵: ❌ (게임플레이 자체)                                     ║
║  광고: ┄┄▶ 📺 [Rewarded "힌트"] (타이머 50% 이하 활성)           ║
╚════════════════════════════════╤════════════════════════════════╝
                                 │ 모든 정답 픽업 OR 타이머 만료
                                 │ 1.5s 서빙 트랜지션
                                 ▼
╔═════════════════════════════════════════════════════════════════╗
║  Scene 2 — 🍳 키친 (ADR-005 4-stage sub-flow)                   ║
║  Stage 2A: 재료 준비 (rhythm tap, 도마+칼)   → §4.1 sub-flow    ║
║  Stage 2B: 조리 방법 선택 (5~10s, 가스레인지+도구) → §4.2       ║
║  Stage 2C: 조리 시간 (요리별 cook_time, timing bar) → §4.3      ║
║  Kitchen rack (basic_pantry 5종 시각 cue, ADR-007) 항상 표시    ║
║  IN: 도마 zoom-in 1.5s   OUT: 접시 담기 → 식탁 이동 1.5s        ║
║  스킵: Stage 2A만 📺 Rewarded auto-perfect 가능 (cooking-mech §2A)║
║  광고: ┄┄▶ 📺 [Rewarded "재료 준비 Skip"] (Stage 2A 시작 직후)  ║
║        ┄┄▶ 📺 [Rewarded "PERFECT 폭 확대"] (Stage 2C 시작 직전) ║
║  상세 layout: `scene-2-kitchen-layout.md` v0.1                  ║
╚════════════════════════════════╤════════════════════════════════╝
                                 │ 1.5s 서빙 모션 (cooking-mech §10.1 #8)
                                 ▼
╔═════════════════════════════════════════════════════════════════╗
║  Scene 3 — 🍽 식탁 (시식 + 채점)                                ║
║  §5 sub-flow 참조 (Tier 1 혼밥 / Tier 2 가족)                   ║
║  IN: 서빙 모션 1.5s      OUT: CTA 탭 (다음/메뉴)                ║
║  스킵: ⚠️ Settings "빠른 트랜지션"이면 0.3s (cooking-mech §10.1) ║
║  광고: ┄┄▶ 📺 [Rewarded "한 번 더"] (실패 시), 🟦 [Interstitial] ║
║         (Round 종료 후 3 레벨마다 1회 — GDD §5.2)               ║
╚════════════════════════════════╤════════════════════════════════╝
                                 │ "다음 요리" 탭 → 다음 Round (같은 레벨 내)
                                 │ "메뉴로" 탭 → Main Menu
                                 ▼
                            (Round 종료)
```

### 2.1 광고 트리거 요약 (Round 1회 기준, v0.3 4-stage sync)

| 위치 | 종류 | 트리거 | 빈도 |
|------|------|--------|------|
| Scene 1 Stage 1 (타이머 50% 이하) | 📺 Rewarded "힌트" | 자발적 탭 | Round당 1회 |
| **Scene 2 Stage 2A 시작 직후** | 📺 Rewarded **"재료 준비 Skip"** (auto-perfect) | 자발적 탭 | Round당 1회 |
| **Scene 2 Stage 2C 직전** | 📺 Rewarded "PERFECT 폭 확대" (10→20%) | 자발적 탭 | Round당 1회 |
| Scene 3 채점 실패 후 | 📺 Rewarded "한 번 더" | 자발적 탭 | Round당 1회 |
| Scene 3 Round 종료 | 🟦 Interstitial | 자동 | **3 레벨마다 1회** (FTUE 5분 이내 차단) |
| 메인 메뉴 / 상점 | 🟩 Banner | 자동 | 항상 (IAP Remove 시 숨김) |

> Tier별 빈도 차이는 [`tier-1-2-flow.md`](tier-1-2-flow.md) §4 참조.

### 2.2 일시정지 메뉴 (Pause)

- 트리거: 우측 상단 `⏸` 버튼 (모든 Scene 공통 HUD).
- 옵션: `▶ 계속` / `↻ 다시` (Round 재시작, 광고 없음) / `🏠 메뉴` / `⚙️ 설정`.
- **타이머는 일시정지 중에도 정지** (cooking-mech §10.1 #1: 5분 초과 시 Round 폐기).
- **앱 백그라운드 진입 = 자동 Pause** 동일 처리.

---

## 3. Scene 1 다점포 상세 sub-flow

### 3.1 화면 구조

```
┌────────────────────────────────────────┐
│ 상단 HUD: 💰코인 ❤️라이프 ⏸           │
├────────────────────────────────────────┤
│  📝 요리 카드 (상단 floating)          │
│  "라면 — 필요 재료: 3개"               │
├────────────────────────────────────────┤
│                                        │
│     🏪 재래시장 입구 BG (골든아워)     │
│                                        │
│   ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐         │
│   │🥬│  │🥩│  │🐟│  │🌾│  │🫙│         │
│   │청│  │정│  │어│  │곡│  │잡│  ← 간판  │
│   │과│  │육│  │물│  │물│  │화│   (2×3   │
│   └──┘  └──┘  └──┘  └──┘  └──┘   부채꼴 │
│                                  권장)  │
├────────────────────────────────────────┤
│ ⏱ ▓▓▓▓▓▓▓░░░ 18s  🛒 [재료 0/3]       │
│ (공통 타이머 — 가게 진입에도 흐름)     │
└────────────────────────────────────────┘
```

### 3.2 가게 5종 layout 결정 (cooking-mech §10.2 follow-up)

**채택: 부채꼴 2×3 그리드 (5개 + 빈 칸 1).**

| 옵션 | Pros | Cons | 판정 |
|------|------|------|------|
| 가로 스크롤 | 폰 포트레이트 친화 | 5번째 가게가 1-thumb 도달 어려움, 시인성 ↓ | ❌ |
| **2×3 부채꼴** | 5개 모두 1-thumb 도달, 입구 BG 살림 | 빈칸 처리 필요(post-launch 6번째 가게로 채움) | ✅ |
| 5각형 방사형 | 시각적 임팩트 | 탭 영역 작음, 마스코트 톤과 충돌 | ❌ |

**간판 시인성**:
- 간판 크기: 화면 폭의 **20% 정사각** (1-thumb 안전영역).
- 간판 = §art-style §2.2 시그니처 컬러 + 한글 후처리 + 이모지 1개.
- **정답 가게 강조 표시 없음** (cooking-mech §2.3 권장 — 탐색 가치 보존). FTUE 한정 예외(`ftue.md` §3).

### 3.3 가게 내부 sub-flow

```
[입구]
   │ 가게 간판 탭
   │ 🔊 가게 진입 종소리 (cooking-mech §10.2)
   │ 0.4s zoom-in 트랜지션
   ▼
┌────────────────────────────────────────┐
│ ← 입구로 (좌상단)   🛒 0/3   ⏱ 17s    │
├────────────────────────────────────────┤
│  📝 요리 카드 (축소 floating, 우상단)   │
├────────────────────────────────────────┤
│                                        │
│     가게 내부 BG (시그니처 컬러)        │
│                                        │
│   ┌────┐ ┌────┐ ┌────┐                 │
│   │ 🥕 │ │ 🧅 │ │ 🥬 │  ← 진열대        │
│   │당근│ │양파│ │파  │  (정답 1~3개    │
│   └────┘ └────┘ └────┘   + 디스트랙터)  │
│                                        │
├────────────────────────────────────────┤
│ ⏱ ▓▓▓▓▓▓▓░░░ 17s  📺 [힌트]            │
└────────────────────────────────────────┘
```

**상호작용**:
- 정답 탭 → 카드가 🛒 장바구니로 슬라이드 인 (0.3s) 🔊 `pickup_chime`.
- 오답 탭 → 빨간 shake 0.2s + 시간 -1s + 카드 `200ms` 쿨다운 (cooking-mech §10.1 #2).
- **이 가게의 모든 정답 픽업 완료** → 자동 입구 복귀 (1.0s 토스트 "이 가게 다 골랐어요!" 후 zoom-out).
- 수동 나가기: `← 입구로` 탭 (언제든 가능).

### 3.4 빈 가게 페널티 (cooking-mech §10.2 follow-up)

**채택: 빈 진열대 + 자동 1.5s 후 복귀.**

```
[빈 가게 진입]
   │ 0.4s zoom-in
   ▼
┌────────────────────────────────────────┐
│ ← 입구로           🛒 1/3   ⏱ 15s     │
├────────────────────────────────────────┤
│                                        │
│   (빈 진열대 BG — 같은 가게 BG이나     │
│    진열대 위 텅 빔, 먼지 한 줌 VFX)    │
│                                        │
│   💬 "이 가게에는 없어요"               │
│   (1.5s 토스트, 자동 페이드아웃)       │
│                                        │
└────────────────────────────────────────┘
   │ 1.5s 자동
   │ (시간은 계속 흐름 → 자연 페널티)
   ▼
[입구로 자동 복귀]
```

- 시간 페널티 = 진입 0.4s + 1.5s 대기 + 복귀 0.4s = **~2.3s 자연 손실**.
- 추가 점수 페널티 없음 (cooking-mech §2.3).
- 수동 `← 입구로` 탭으로 1.5s 대기 스킵 가능.

### 3.5 자동 시장 복귀 옵션 (cooking-mech §10.1 #5)

**채택: ON (default).** Settings에 토글 노출.

- 마지막 정답 픽업 시 → 토스트 "장보기 완료!" → 1.0s 후 자동 키친 진입.
- OFF인 경우: 수동 `← 입구로` 후 입구 화면에 `🍳 키친으로` CTA 표시.

### 3.6 5가게 풀 순회 음식 UX (김밥, 떡국 — `mvp-food-selection.md` §3.2)

5가게 모두 방문해야 하는 음식은 신규 플레이어에게 부담. 다음 가이드 layer:

- **요리 카드에 가게 미니 인디케이터**: `🥬🥩🐟🌾🫙 5/5` 형태로 방문 진행도 표시 (입구 화면 요리 카드 하단). 정답 가게가 어디인지는 노출 X, **방문 진행 카운트만**.
- **🛒 장바구니 미리보기**: 입구·가게 내부 양쪽 항상 표시 (cooking-mech §10.2 follow-up). 탭 시 확장 모달.
- ⚙️ **가게 진행 인디케이터 5/5 표기 방식** = pm 확정 필요 (방문 카운트만 vs 픽업 카운트만 vs 둘 다).

---

## 4. Scene 2 키친 sub-flow (v0.3 ADR-005 4-stage 재작성)

> Scene 2 안에 **3개 sub-stage** (Stage 2A / 2B / 2C) — Scene 전환 없이 sub-flow로 연속 진행.
> Stage 사이 transition은 짧은 슬라이드/페이드 모션만 (0.3~1.0s).
> 상세 layout (좌표·픽셀·anchor)은 **`scene-2-kitchen-layout.md` v0.1** 위임 — 본 문서는 sub-flow 흐름만.

### 4.0 Scene 2 공통 (모든 sub-stage)

- **Kitchen rack (CP-22, basic_pantry 5종 시각 cue, ADR-007)**: 우측 상단 항상 표시 (Stage 2A fade-in / 2B·2C dim 50%).
- **HUD** (CP-9 코인 / CP-8 타이머 / Pause): 상단 stationary, Stage 전환에도 재 build 없음.
- **CH-01 주인공 chibi** (선택사항, M2 alpha test 결정): 우측 하단 idle, interactive X.
- Scene 2 진입 시 IN transition = "귀가" 1.5s (Scene 1 장바구니 → 도마 zoom-in).
- Scene 2 종료 시 OUT transition = "서빙" 1.5s (가스레인지 zoom-out + plated dish swap + Scene 3 식탁 slide-in).

```
[Scene 1 → Scene 2 트랜지션 1.5s "귀가"]
   │ HUD + Kitchen rack fade-in
   │ 도마 + 칼 + ING-XX whole 등장
   ▼
[Stage 2A 재료 준비 (도마+칼 rhythm tap)]
   │ 마지막 tap → ING-XX → ICUT-XX cross-fade
   │ 도마 LEFT slide-out + 가스레인지 RIGHT slide-in (1.0s parallel)
   ▼
[Stage 2B 조리 방법 선택 (가스레인지+도구 카드)]
   │ 카드 tap → 도구 dock motion (0.5s arc)
   │ 카드 fade-out, timing bar fade-in (0.3s, Scene 유지)
   ▼
[Stage 2C 조리 시간 (timing bar + tap)]
   │ tap → 판정 0.5s
   │ 가스레인지 zoom-out + plated dish swap (1.5s "서빙")
   ▼
[Scene 3 식탁]
```

### 4.1 Stage 2A — 재료 준비 (rhythm tap + Knife indicator)

> cooking-mechanics §2A + scene-2-kitchen-layout §1 + components.md CP-18/19 정합.

```
[Scene 1 → Scene 2 트랜지션 1.5s "귀가"]
   │ HUD + Kitchen rack fade-in 0.3s
   │ 도마 (CUT-00) 중앙 fade-in
   │ ING-XX whole hero ingredient 도마 위 배치
   │ Knife indicator (CP-19) 칼 sprite Y 900 idle 위치
   ▼
┌────────────────────────────────────────┐
│ 상단 HUD: 💰 ❤️ ⏸           🫙🫙🫙🫙🫙 │  ← Kitchen rack (ADR-007)
├────────────────────────────────────────┤
│  📝 요리 카드 + "Stage 2A 재료 준비"   │
│  "잔치국수 — 멸치 다지기 ♪ x4"          │
├────────────────────────────────────────┤
│                                        │
│              [ ING-XX whole ]           │   ← visual focus zone
│                                        │
│   ┌───── 칼 (위↕아래 motion) ─────┐    │   ← Knife indicator (CP-19)
│   │           🔪                  │    │     Y 900~1150 translation
│   │   ↕ AnimationPlayer            │    │     BPM speed_scale 조정
│   │     "knife_loop"               │    │
│   └────── [ CUT-00 도마 ] ────────┘    │   ← 도마 (CP-18) = tap target
│            tap anywhere                 │     Y 1100~1450 X 240~840
│                                  CH-01  │     one-thumb zone
├────────────────────────────────────────┤
│ ⏱ Tap 2/4 (BPM 90)    📺 Skip          │  ← Rewarded Video auto-perfect
└────────────────────────────────────────┘
```

**상호작용**:
- 칼 sprite가 도마 닿는 순간 ±80ms = **Perfect** (accuracy 100%), ±200ms = **Good** (60%), 그 외 = **Miss** (0%).
- 정답 tap 시 🔊 `cut_perfect` / `cut_good` + 도마 shake 0.2s + 칼 flash + chunk particle 1회.
- 마지막 tap (예: 4/4) 완료 시 → ING-XX whole → ICUT-XX cut **cross-fade 0.3s**.
- **양념재우기 variant** (불고기 t2_014 / 갈비구이 t2_012): Kitchen rack 양념 3종 (간장+설탕+참기름) Gold highlight → marinade bowl로 arc 1.0s → 60 BPM × 3 taps 진행 (cooking-mech §2A.X 정합).
- **📺 Skip 옵션** (Rewarded Video): 즉시 ICUT-XX 변환 + `accuracy_prep = 1.0` (cooking-mech §2A).
- 시간 만료 = 현재 상태로 Stage 종료 (남은 taps = miss 처리).

**transition (2A → 2B)**:
- 마지막 tap 또는 Skip 직후 t=0.0s:
  - t=0.3s: 도마 + ICUT-XX LEFT slide-out (X -1080, 0.5s)
  - t=0.5s: 가스레인지 + 도구 카드 3장 RIGHT slide-in (X +1080 → 0, 0.5s)
  - **총 1.0s**

### 4.2 Stage 2B — 조리 방법 선택 (가스레인지 + 도구 카드)

> cooking-mechanics §3 + scene-2-kitchen-layout §2 + components.md CP-20 정합.

```
[Stage 2A → 2B transition 1.0s]
   │ 도마 LEFT slide-out + 가스레인지/카드 RIGHT slide-in
   ▼
┌────────────────────────────────────────┐
│ 상단 HUD: 💰 ❤️ ⏸           🫙🫙🫙🫙🫙 │  ← Kitchen rack dim 50%
├────────────────────────────────────────┤
│  📝 요리 카드 + "Stage 2B 조리 방법은?"│
├────────────────────────────────────────┤
│                                        │
│       [ TOOL-01 가스레인지 ]            │  ← base substrate (항상 표시)
│       (4-burner stovetop idle)          │
│                                        │
│   ┌──────┐ ┌──────┐ ┌──────┐           │
│   │TOOL  │ │TOOL  │ │TOOL  │           │  ← cooking_tool_slot x 3~4
│   │ -02  │ │ -03  │ │ -05  │           │    (CP-04 + CP-20)
│   │냄비  │ │후라이│ │그릴  │           │    Y 1100~1500 one-thumb
│   │끓이기│ │볶기  │ │굽기  │           │
│   └──────┘ └──────┘ └──────┘  CH-01    │
├────────────────────────────────────────┤
│ ⏱ ▓▓▓░░░░ 6s                          │
└────────────────────────────────────────┘
```

**상호작용**:
- 카드 한 번 탭 → 즉시 결정 (취소 없음, cooking-mech §3.2).
- 정답 시 🔊 `method_correct` + 카드 0.95x flash 0.1s + 도구가 가스레인지 위로 dock (0.4s arc Tween, scale 240→400).
- 오답 시 🔊 `method_wrong` + 빨간 shake 0.2s + **정답 도구가 자동으로 같은 모션으로 dock** (시각 일관성, 점수만 0 처리).
- 시간 만료 = 오답 자동 처리 + 정답 도구 자동 dock.

**transition (2B → 2C)**:
- 도구 dock 완료 (t=0.5s) → 즉시 Stage 2C 진입 (Scene 유지).
- 도구 카드 fade-out 0.3s + Timing bar fade-in 0.3s (parallel).
- 가스레인지 + 도구 + 음식 sprite는 그대로 유지.

### 4.3 Stage 2C — 조리 시간 (timing bar)

> cooking-mechanics §4 + scene-2-kitchen-layout §3 + components.md CP-21 정합.

```
[Stage 2B → 2C transition 0.3s]
   │ 카드 fade-out + Timing bar fade-in
   │ 가스레인지 burner 🔥 glow + 도구 위 음식 VFX 시작
   ▼
┌────────────────────────────────────────┐
│ 상단 HUD: 💰 ❤️ ⏸           🫙🫙🫙🫙🫙 │  ← Kitchen rack dim 50%
├────────────────────────────────────────┤
│  📝 요리 카드 + "Stage 2C 끓는 타이밍!"│
├────────────────────────────────────────┤
│                                        │
│       [ TOOL-01 가스레인지 ]            │
│       + [ TOOL-02 냄비 dock ]           │  ← Stage 2B에서 dock된 도구
│       🔥 burner glow + 💨 steam VFX     │
│       + [ ICUT-XX cooking ]             │
│                                        │
│   ┌────────────────────────────────┐    │
│   │ │miss│good│ PERFECT │good│miss│ │   │  ← Timing bar (CP-21)
│   │           ▼ ↔                  │    │    Y 1150~1280 full width
│   └────────────────────────────────┘    │    Perfect ±80ms (Gold halo)
│                                        │
│       [   탭!   any tap area   ]       │  ← Y 1380~1620 tap area
│                                  CH-01  │
├────────────────────────────────────────┤
│ ⏱ cook_time progress (별도 bar)        │
└────────────────────────────────────────┘
```

**상호작용**:
- 인디케이터 ▼ 좌→우 왕복 (Tween linear, 1 cycle = `food.cook_time_sec`).
- tap 즉시 인디케이터 X 좌표 → 구간 판정 (PERFECT 10%, 또는 Rewarded ad 시 20%):
  - PERFECT (Gold + 빗금) → `accuracy_timing = 1.0` 🔊 `tap_perfect`
  - good → 0.6 🔊 `tap_good`
  - miss → 0.2 🔊 `tap_miss`
- 결과 텍스트 ("PERFECT!" / "GOOD" / "MISS") 0.5s fade-in/out.
- 탭 안함 → 인디케이터 1 왕복 완료 시점 강제 종료 (accuracy_timing = 0.0).

**transition (2C → Scene 3)**:
- tap 후 t=0.0s 판정 fade 0.5s
- t=0.5s 가스레인지 zoom-out (1.0x → 0.6x) + 접시 sprite zoom-in (0.6x → 1.0x) cross-fade 0.5s
- t=1.0s plated dish hero shot (F-XX) sprite로 변환 + Scene 3 식탁 BG RIGHT slide-in
- t=1.5s Scene 3 fully visible
- **총 1.5s "서빙"**

---

## 5. Scene 3 식탁 sub-flow

### 5.1 화면 구조 — Tier 1 (혼밥)

```
┌────────────────────────────────────────┐
│ 상단 HUD: 💰 ❤️ ⏸                      │
├────────────────────────────────────────┤
│  점수 / ★ 등급 (식탁 BG 위 오버레이)   │
│  ┌──────────────────────────────┐       │
│  │ ★ ★ ★   84점                 │       │
│  └──────────────────────────────┘       │
├────────────────────────────────────────┤
│                                        │
│   🍽 1인 식탁 BG (혼밥, 작은 상)        │
│                                        │
│        ┌────────┐                      │
│        │  주인공 │  ← 캐릭터 시식 area   │
│        │  (3/4) │   art-style §3.5    │
│        └────────┘                      │
│         🍜 라면 (접시)                  │
│                                        │
│   💬 "와!" (★3) / 끄덕 (★1·★2)         │
│                                        │
├────────────────────────────────────────┤
│   ┌──────────┐  ┌──────────┐           │
│   │ 다음 요리│  │ 메뉴로   │           │
│   └──────────┘  └──────────┘           │
│   ┄┄▶ 📺 한 번 더 (실패 시)            │
└────────────────────────────────────────┘
```

### 5.2 화면 구조 — Tier 2 (가족)

```
┌────────────────────────────────────────┐
│ 점수 / ★ (동일)                         │
├────────────────────────────────────────┤
│                                        │
│   🍽 2~3인 식탁 BG (가족, 큰 찌개 중앙) │
│                                        │
│   ┌──────┐  ┌──────┐  ┌──────┐         │
│   │주인공│  │어머니│  │아버지│         │  ⚙️ 아버지는 어느 시점 unlock?
│   │      │  │      │  │ (?)  │         │   (`tier-1-2-flow.md` §3 참조)
│   └──────┘  └──────┘  └──────┘         │
│            🍲 김치찌개                  │
│                                        │
│   💬 캐릭터 reaction (★3만 차별)        │
│      ★3 = "와!" 동시 입 벌림           │
│      ★1·★2 = 공통 끄덕                 │
│                                        │
├────────────────────────────────────────┤
│   [ 다음 요리 ]  [ 메뉴로 ]            │
└────────────────────────────────────────┘
```

### 5.3 시식 연출 timeline

| 시점 | 이벤트 |
|------|--------|
| t=0 | Scene 2 → Scene 3 서빙 모션 종료, 식탁 BG 노출 |
| t=0.5s | 캐릭터(들) 음식 한 입 먹는 모션 (0.8s) 🔊 `eat_chomp` |
| t=1.3s | reaction 표정 트리거 (★3 = Happy / ★1·★2 = Subtle) 🔊 `reaction_star3` / `reaction_subtle` |
| t=1.8s | 점수·★ 오버레이 fade-in (0.4s) 🔊 `score_tally` |
| t=2.2s | ★3에 한해 particle burst 🔊 `star3_chime` |
| t=2.6s | CTA 버튼 fade-in |
| t≥3.0s | 사용자 탭 대기 |

### 5.4 CTA 분기

- `다음 요리` → 같은 레벨 내 다음 Round (Scene 1로 복귀, 광고 없음).
- `메뉴로` → Main Menu 복귀 (광고 트리거 체크 — 3 레벨 마다 🟦).
- `한 번 더 (📺)` (Round 실패 시만 노출) → Rewarded 시청 후 Round 전체 재시작 (cooking-mech §6.3).
- 레벨 마지막 Round 종료 → "레벨 클리어" 모달 → Level Select 복귀 + 🟦 Interstitial 가능.

---

## 6. 공통 UI 영역

### 6.1 상단 HUD (모든 Scene 공통)

```
┌────────────────────────────────────────┐
│ 💰 1,240   ❤️ ❤️ ❤️   Lv.7   ⏸        │
└────────────────────────────────────────┘
```

| 요소 | 표시 | 비고 |
|------|------|------|
| 💰 코인 | 보유 코인 수 | 탭 → 상점 |
| ❤️ 라이프 | 0~5 (회복 시간 30분/1) | ⚙️ pm 확정 — 라이프 시스템 사용 여부 |
| Lv.N | 현재 레벨 | Scene 1·2·3 모두 표시 |
| ⏸ Pause | 우측 상단 | §2.2 참조 |

### 6.1A Kitchen rack (Scene 2 only, v0.3 신규 ADR-007)

| 요소 | 표시 | 비고 |
|------|------|------|
| 🫙🫙🫙🫙🫙 | basic_pantry 5종 (간장/고추장/설탕/참기름/소금) | 우측 상단 Y 130~340 X 820~1060 |
| state | Stage 2A fade-in / 2B·2C dim 50% / 양념재우기 highlight + arc | interactive X (시각 cue only) |
| 정합 | ADR-007 + cooking-mech §2.2.7 + CP-22 | 옹기 5종 sprite는 Post-M1 art-director |

### 6.2 하단 액션 바 (v0.3 4-stage sync)

- Scene 1 입구: 타이머 + 장바구니 미리보기
- Scene 1 가게 내부: 타이머 + `← 입구로` + 📺 힌트
- **Scene 2 Stage 2A: tap count (예: 2/4) + BPM 표기 + 📺 Skip (Rewarded auto-perfect)**
- **Scene 2 Stage 2B: 타이머만**
- **Scene 2 Stage 2C: tap area (Y 1380~1620 full width) + cook_time progress bar**
- Scene 3: CTA 2~3개

### 6.3 배너 광고 영역 (🟩)

- 위치: **메인 메뉴 / Level Select / 상점 / 설정** 하단 고정.
- 게임플레이 Scene 1·2·3 중 노출 금지 (GDD §5.2).
- IAP Remove Ads 구매 시 모든 위치에서 숨김.

---

## 7. 화면 전이 전체 매트릭스

| FROM → TO | 트랜지션 | 시간 | 스킵 |
|-----------|---------|------|------|
| Splash → Main Menu | fade | 0.5s | 탭 |
| Main Menu → Level Select | slide-up | 0.4s | ❌ |
| Level Select → Round Start | zoom-in | 0.6s | ❌ |
| Round Start → Scene 1 | fade+zoom | 0.8s | ❌ |
| Scene 1 입구 ↔ 가게 내부 | zoom-in/out | 0.4s | ❌ |
| Scene 1 → Scene 2 (Stage 2A 진입) | "귀가" 트랜지션 (장바구니 → 도마) | 1.5s | ⚙️ "빠른" 0.3s |
| **Scene 2 Stage 2A → Stage 2B** | **도마 LEFT slide-out + 가스레인지 RIGHT slide-in (parallel)** | **1.0s** | ❌ |
| **Scene 2 Stage 2B → Stage 2C** | **카드 fade-out + Timing bar fade-in (Scene 유지)** | **0.3s** | ❌ |
| Scene 2 → Scene 3 (Stage 2C 종료) | "서빙" 모션 (가스레인지 zoom-out + plated dish swap) | 1.5s | ⚙️ "빠른" 0.3s |
| Scene 3 → 다음 Round | fade | 0.4s | ❌ |
| Scene 3 → Main Menu | fade-out | 0.6s | ❌ |
| 광고(Interstitial) ↔ 게임 | 광고 SDK 기본 | 가변 | ❌ |

---

## 8. Decisions Log (이번 sprint)

| # | 결정 | 근거 |
|---|------|------|
| SF-01 | Scene 1 가게 layout = **2×3 부채꼴 그리드** | 1-thumb 도달, 5개 + 빈칸 1(post-launch 6번째 가게 슬롯) |
| SF-02 | 빈 가게 페널티 = **빈 진열대 + 1.5s 자동 복귀** | cooking-mech §10.2 권장 그대로 |
| SF-03 | 자동 시장 복귀 옵션 default **ON**, Settings 토글 | 탭 절약 + 숙련 유저 OFF 선택권 |
| SF-04 | 5가게 풀 순회 음식(김밥/떡국)에 **가게 방문 인디케이터** 추가 | 신규 플레이어 가이드 |
| SF-05 | Scene 3 CTA = **"다음 요리" / "메뉴로"** 2개 default + 실패 시 📺 추가 | cooking-mech §6.3 준수 |
| SF-06 | 일시정지 = 5분 cap, 백그라운드 = 자동 Pause | cooking-mech §10.1 #1 |
| **SF-07 (v0.3)** | **Scene 2 = Stage 2A/2B/2C sub-flow (별도 Scene 전환 X)** | ADR-005 4-stage, HUD/Kitchen rack/CH-01 stationary 유지로 transition cost ↓ |
| **SF-08 (v0.3)** | **Stage 2A에 📺 Rewarded "재료 준비 Skip" 신규 위치 추가** | cooking-mech §2A Rewarded auto-perfect 정합, Round당 광고 1회 추가 (총 3 Rewarded slot) |
| **SF-09 (v0.3)** | **Stage 2A → 2B transition = 1.0s slide (LEFT/RIGHT parallel), Stage 2B → 2C = 0.3s fade (Scene 유지)** | 시각 일관성 + 빠른 흐름, 가스레인지/도구 sprite Stage 2B↔2C 공유 |
| **SF-10 (v0.3)** | **Kitchen rack (CP-22, basic_pantry 5종) Scene 2 전체에서 항상 표시** | ADR-007 정합, 옹기 5종 시각 cue (interactive X), Stage 2A fade-in / 2B·2C dim 50% / 양념재우기 highlight |

---

## 9. 변경 이력
- **2026-05-31 v0.3** — ADR-005 4-stage 정합 + ADR-007 basic_pantry Kitchen rack 통합. 기존 v0.1 Stage 2 / 3 → **Stage 2A 재료 준비 (rhythm tap + Knife indicator) / 2B 조리 방법 / 2C 조리 시간**으로 분리. §2 Round 다이어그램 4-stage 재작성 + §4 Scene 2 sub-flow 전면 재작성 (§4.0 공통 + §4.1 Stage 2A + §4.2 Stage 2B + §4.3 Stage 2C). §2.1 광고 트리거 표 Stage 2A "Skip" 신규 행 + Stage 2C 표기 sync. §6.1A Kitchen rack 신규 + §6.2 하단 액션 바 4-stage sync. §7 전이 매트릭스 Stage 2A→2B (1.0s) + 2B→2C (0.3s) 행 신규. Decisions SF-07~10 신설. 상세 layout은 신규 문서 `scene-2-kitchen-layout.md` v0.1 위임 (1080×1920 portrait, one-thumb zone, Y 좌표, transition timeline). 의존 art lock: CUT-00 + CUT-01~06 + TOOL-01~12 + ING-01~12 whole + ICUT-01~12 cut + CH-01 (모두 2026-05-31 LOCK 완료). components.md v0.3 (CP-18~22 신설) sync.
- **2026-05-23 v0.1** — 초안. 부트 → Round 3-scene → Scene 1 다점포 sub-flow(2×3 부채꼴, 빈 가게 처리, 자동 복귀) / Scene 2 키친 / Scene 3 식탁(Tier 1·2 구분) 전이도. 광고·사운드 hook overlay. Decisions 6항.
