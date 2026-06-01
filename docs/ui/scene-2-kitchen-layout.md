# Scene 2 (Kitchen) Layout — ADR-005 4-Stage Detail Spec

> 버전: **v0.1** · 작성일: 2026-05-31 · 작성자: ui-designer
> 상위 문서: [`screen-flow.md` v0.3](screen-flow.md), [`components.md` v0.3](components.md), [`../systems/cooking-mechanics.md` v0.6](../systems/cooking-mechanics.md), [`../decisions.md` ADR-005](../decisions.md#adr-005), [`../decisions.md` ADR-007](../decisions.md#adr-007), [`../art-anchor-rubric.md` v1.21](../art-anchor-rubric.md)
> 관련 art lock: CUT-00 도마 + CUT-01~06 cut style 6 + TOOL-01~12 조리도구 12 + ING-01~12 whole + ICUT-01~12 cut + CH-01 주인공
> **Scope**: Scene 2 안의 sub-flow 3종 (Stage 2A 재료 준비 / Stage 2B 조리 방법 / Stage 2C 조리 시간) — 1080×1920 portrait, one-thumb, 5-second rule.
> **Motion lock**: Option 1 = Godot Transform animation (단일 sprite 회전/이동), AnimationPlayer + Tween 조합.

---

## 0. 공통 design constraint

### 0.1 화면 기준 좌표계
- **해상도 기준**: 1080×1920 portrait (Android dp 360×640 × 3.0 density 환산 기준).
- **Y 좌표 명명**: top=0, bottom=1920 (Godot convention).
- **Safe area**:
  - top safe: 0~120px (HUD reserved, status bar 80px + 40px gap).
  - bottom safe: 1700~1920px (gesture nav 80px + 140px gap, 하단 CTA 또는 thumb action zone).
- **One-thumb action zone**: Y 1100~1700 (오른손 엄지 자연 도달 — 모든 player interactive element는 이 zone에 배치).
- **Visual focus zone (시각만, 비 인터랙티브)**: Y 200~1100 (food/tool/character display).

### 0.2 HUD overlay (Scene 2 공통, Z=100)
- 위치 `Y 0~120`, screen-flow §6.1과 동일.
- 좌측: 💰 코인 + ❤️ 라이프 (3 슬롯).
- 중앙: 요리 카드 mini (food_card.tscn 축소 버전, 이름만 / 인분 mini 배지).
- 우측: ⏸ Pause.
- **Stage 2A/2B/2C 모두 동일 HUD** — Scene 2 진입 시점에 HUD 한 번 build, sub-flow 전환 시 재 build 없음.

### 0.3 Kitchen rack (ADR-007 basic_pantry visual cue, Z=80)
- 위치: **우측 상단 Y 130~340, X 820~1060** (HUD 바로 아래, 가스레인지 영역과 시각 분리).
- 옹기 5종 (간장/고추장/설탕/참기름/소금) 가로 정렬 mini icon (각 40×40px, 간격 8px).
- **Stage 2A 진입 시점에 fade-in 0.3s** (Scene 1 → Scene 2 transition 마지막 0.3s overlap).
- **Stage 2A 양념재우기 round (불고기/갈비구이)** 진입 시 해당 양념 3종(간장+설탕+참기름)이 highlight glow → marinade bowl로 자동 이동 (1.0s Tween).
- Stage 2B/2C 동안 dim 50% opacity (포커스 전환).
- Scene 2 → Scene 3 transition 시 hidden.

### 0.4 캐릭터 placement (CH-01 주인공 chibi optional)
- 위치: **우측 하단 Y 1100~1450, X 750~1060** (one-thumb zone 우측, action zone 침범 X).
- chibi bust-up 3/4 시점, 표정 idle.
- **Stage 2A 진입 시 첫 0.5s에 fade-in 0.3s**, Stage 2C 끝까지 유지.
- **interactive 아님** — 분위기 보조 only. 표정 변화는 Stage 정답/오답 feedback (head nod / shake 0.2s).
- ⚙️ confirm 필요: CH-01 표시 ON/OFF default — Stage 2C 도구 VFX가 dominant라 캐릭터가 noisy할 가능성. M2 alpha test 결정.

---

## 1. Stage 2A — 재료 준비 (도마 + 칼 rhythm tap)

> Reference: cooking-mechanics §2A, ADR-005, art-anchor-rubric §5.7 G_cut + §5.8 G_ingredient_whole + §5.10 G_ingredient_cut.

### 1.1 화면 layout

```
┌──────────────────────────────────────────┐  Y=0
│  💰 1,240   ❤️❤️❤️   요리mini   ⏸       │  HUD Y 0~120, Z=100
├──────────────────────────────────────────┤  Y=120
│                            🫙🫙🫙🫙🫙     │  Kitchen rack Y 130~340 RIGHT
│                            (basic_pantry) │   X 820~1060, Z=80
│                                          │
│   📝 요리 카드 풀  + Stage 2A 라벨        │  Y 360~480, food_card 가로 long
│   "잔치국수 — 멸치 다지기 ♪ x4"          │   + sub-stage chip
│                                          │
│                                          │
│              [ ING-XX whole               │  Y 600~900, X 360~720
│                  hero ingredient ]        │  Visual focus zone (비 인터랙티브)
│                                          │
│       ╔═══════════════════════════╗      │  Y 900~1200
│       ║    🔪 칼 (위↕아래 motion)  ║      │   Knife indicator (CP-19)
│       ╠═══════════════════════════╣      │
│       ║       [ CUT-00 도마 ]      ║      │  Y 1100~1450, X 240~840
│       ║      (warm brown wood)     ║      │   도마 (CP-18) = tap target
│       ║                            ║      │   one-thumb zone
│       ╚═══════════════════════════╝      │
│                                          │
│                              [ CH-01 ]    │  Y 1100~1450, X 750~1060
│                              chibi idle   │   (도마와 시각 overlap 허용,
│                                          │    Z order: 도마 50 > 캐릭터 40)
├──────────────────────────────────────────┤  Y=1700
│  ⏱ ▓▓▓▓▓▓▓░░░ Tap 2/4  📺 Skip          │  bottom safe Y 1700~1920
└──────────────────────────────────────────┘  Y=1920
```

### 1.2 핵심 메커닉
- **칼 motion (Knife indicator, CP-19)**:
  - 칼 sprite 단독 (TOOL 12종에 포함되지 않은 dedicated cut knife, art-anchor §5.7 CUT-00 base의 LEFT side static knife와 동일 silver-gray slim silhouette).
  - **AnimationPlayer "knife_loop"** = 위↕아래 무한 loop, BPM 기반 cycle (per-food, balance-config §7).
    - 예: BPM 90 = 1 cycle 667ms = 위 → 정점 hold → 아래 → 도마 닿기(perfect 순간) → 위 복귀.
  - Y range: 위 정점 Y 900 → 도마 닿기 Y 1150 (250px translation).
  - 각도 회전 없음 (Option 1 단일 sprite Transform 만, art-anchor §5.7 도구 LEFT side static 정합).
- **도마 (CP-18)** = 전체 tap target. Y 1100~1450, X 240~840 영역 어디든 탭 인식.
  - **Perfect ±80ms** = 칼이 도마 닿는 순간 ±80ms 안에 tap → 100% (balance-config §6).
  - Good ±200ms → 60%, Miss → 0%.
- **재료 transition**:
  - Stage 2A 시작 t=0: ING-XX whole sprite 도마 위에 표시 (Y 900 위치, 시각 only).
  - 각 perfect/good tap 마다 cut feedback: 칼 flash 0.1s + 도마 shake 0.2s + chunk particle 1회.
  - 마지막 tap (예: 4/4) 완료 시 ING-XX whole sprite fade-out 0.3s + ICUT-XX cut sprite fade-in 0.3s (cross-fade, 같은 Y 위치).
- **Skip 옵션 (📺 Rewarded)**:
  - bottom right corner Y 1730 X 920, 라탄 바구니 + 📺 아이콘 (hint_button.tscn pattern 재사용).
  - 탭 → Rewarded Video → 즉시 ICUT-XX cut state로 transition + `accuracy_prep = 1.0`.

### 1.3 양념재우기 variant (불고기 t2_014 / 갈비구이 t2_012)

ADR-007 + cooking-mechanics §2A.X 정합.

- Stage 2A 시작 시점 t=0:
  - Kitchen rack의 간장(ing_x_003) + 설탕(ing_x_005) + 참기름(ing_x_006) 옹기 3개가 highlight glow 0.5s.
  - 3 옹기 → marinade bowl로 자동 이동 (Tween, 1.0s arc trajectory, 도마 위치 Y 1100~1450 에 marinade bowl sprite 배치).
- t=1.0s: marinade bowl + hero ingredient (얇은 소고기 / LA갈비) 결합 상태 표시.
- t=1.0s ~ end: **60 BPM marinade rhythm tap × 3 taps** (cooking-mech §2A 양념재우기).
  - 칼 motion 대신 **손 motion** (양념 마사지) — Knife indicator 대신 손 sprite가 marinade bowl 위에 위↕아래.
  - ⚠️ M2 deferred: 손 sprite anchor 미작성. M2 art-director sprint에 추가 위임 필요 (post-MVP 후보로 일단 칼 motion 재사용 + visual fallback OK 협의).

### 1.4 transition (Stage 2A → 2B)
- 마지막 tap 완료 시점 t_end:
  - t_end + 0.0s: 칼 motion stop (AnimationPlayer pause), 도마 위에 ICUT-XX cut sprite 정착.
  - t_end + 0.3s: 도마 + ICUT-XX 통째로 LEFT slide-out (X -1080) 0.5s.
  - t_end + 0.5s: Stage 2B 가스레인지 + 도구 RIGHT slide-in (X +1080 → 0) 0.5s 시작.
  - **총 transition 1.0s**.
- HUD / Kitchen rack / CH-01은 stationary (Stage 2A → 2B → 2C 내내 동일 위치).

---

## 2. Stage 2B — 조리 방법 (가스레인지 + 도구 + 음식 변화)

> Reference: cooking-mechanics §3, art-anchor-rubric §5.11 G_tool.

### 2.1 화면 layout

```
┌──────────────────────────────────────────┐  Y=0
│  💰 1,240   ❤️❤️❤️   요리mini   ⏸       │  HUD Y 0~120
├──────────────────────────────────────────┤
│                            🫙🫙🫙🫙🫙     │  Kitchen rack dim 50%
│                                          │
│   📝 요리 카드 + Stage 2B 라벨            │  Y 360~480
│   "잔치국수 — 조리 방법은?"               │
│                                          │
│         [ TOOL-01 가스레인지 ]            │  Y 600~1000, X 240~840
│         (4-burner stovetop)               │  base substrate, idle
│                                          │
│         🔥 active burner glow             │  (정답 선택 후 활성)
│                                          │
│       ┌──────┐ ┌──────┐ ┌──────┐         │  Y 1100~1500, X 100~980
│       │TOOL  │ │TOOL  │ │TOOL  │         │  cooking_tool_slot.tscn x3~4
│       │ -02  │ │ -03  │ │ -05  │         │   (one-thumb zone)
│       │냄비  │ │후라이│ │그릴  │         │   240×240 card, 간격 32px
│       │끓이기│ │볶기  │ │굽기  │         │
│       └──────┘ └──────┘ └──────┘         │
│                              [ CH-01 ]    │  Y 1100~1450 X 800~1060
│                              chibi idle   │   Z order: 카드 50 > 캐릭터 30
├──────────────────────────────────────────┤  Y=1700
│  ⏱ ▓▓▓▓▓░░░░░ 6s 남음                    │  타이머만 (CTA 없음 — tap = 결정)
└──────────────────────────────────────────┘  Y=1920
```

### 2.2 핵심 메커닉
- **TOOL-01 가스레인지 base**: Y 600~1000 정중앙, 항상 표시 (base substrate). Stage 2B 진입 시 fade-in 0.3s.
- **조리 방법 카드 3~4장**: cooking_tool_slot.tscn (components.md §4) 재사용. 각 카드 = TOOL-02~12 중 음식 타입에 해당하는 도구 sprite + 한글/icon 라벨.
  - 카드 수는 음식별 결정 (game-designer foods CSV `method_options` 컬럼, M2 lock).
  - tier 1 음식: 3 카드 (끓이기/볶기/굽기 또는 끓이기/찌기/볶기).
  - tier 2 음식: 4 카드 (끓이기/볶기/찌기/굽기).
- **결정 모션**: 카드 tap 즉시 → 0.5s 안에:
  - t=0.0s: 카드 0.95x flash + `method_correct`/`method_wrong` 효과음.
  - t=0.1s: 정답 카드 → 가스레인지 위로 zoom + dock (Y 600~1000 위치로 0.4s Tween).
  - t=0.5s: 가스레인지 burner 🔥 glow + 도구 위에 ING/ICUT sprite swap (Stage 2A에서 받은 ICUT-XX → cooking state 변형 sprite).
- **오답 처리**: 정답 도구가 강제로 같은 모션으로 자동 배치 (player 결정과 무관, 점수만 0 처리). 시각 일관성 우선.

### 2.3 transition (Stage 2B → 2C)
- 도구 dock 완료 (t=0.5s) → 즉시 Stage 2C 진입 (전환 모션 없음, Scene 유지).
- **Stage 2B/2C 시각 base가 동일** (가스레인지 + 도구 + 음식 sprite) → 같은 layer 위에서 게이지 바만 추가로 fade-in.
- Stage 2B의 cooking_tool_slot 카드 3개는 그대로 fade-out 0.3s (Y 1100~1500 영역 비움 → Stage 2C 게이지 바 + tap area 확보).

---

## 3. Stage 2C — 조리 시간 (timing bar + Perfect ±80ms)

> Reference: cooking-mechanics §4, ADR-005 §6, art-anchor-rubric §5.11.

### 3.1 화면 layout

```
┌──────────────────────────────────────────┐  Y=0
│  💰 1,240   ❤️❤️❤️   요리mini   ⏸       │  HUD Y 0~120
├──────────────────────────────────────────┤
│                            🫙🫙🫙🫙🫙     │  Kitchen rack dim 50%
│                                          │
│   📝 요리 카드 + Stage 2C 라벨            │  Y 360~480
│   "잔치국수 — 끓는 타이밍을 잡아라!"      │
│                                          │
│         [ TOOL-01 가스레인지 ]            │  Y 600~1000
│         + [ TOOL-02 냄비 dock ]           │   Stage 2B에서 dock된 도구 유지
│         🔥 active burner + 💨 steam VFX   │
│         + [ ICUT-XX in cooking ]          │
│                                          │
│       ╔══════════════════════════════╗    │  Y 1150~1280, X 60~1020
│       ║ │miss│good│PERFECT│good│miss│ ║    │  CP-21 Timing bar
│       ║          ▼ ↔ 인디케이터       ║    │  (full width, 130px height)
│       ╚══════════════════════════════╝    │
│                                          │
│       ┌────────────────────────────┐      │  Y 1380~1620
│       │       탭!  TAP!            │      │   tap area (가로 풀 폭,
│       │   (or screen anywhere)     │      │    one-thumb zone)
│       └────────────────────────────┘      │
│                              [ CH-01 ]    │  Y 1100~1450 X 800~1060
├──────────────────────────────────────────┤  Y=1700
│  ⏱ ▓▓▓▓▓░░░░░ cook_time progress         │  cook_time 게이지 (다른 bar)
└──────────────────────────────────────────┘  Y=1920
```

### 3.2 핵심 메커닉
- **CP-21 Timing bar** = Y 1150~1280, X 60~1020 (full width).
  - 5 구간 색상: miss(회색) / good(Gold 50%) / **PERFECT(Gold 100% + 빗금)** / good / miss.
  - PERFECT 너비 = 전체의 10% (Rewarded ad 시 20%).
  - 인디케이터 ▼ = 좌→우 왕복, Tween linear, 1 cycle = food.cook_time_sec (요리별).
- **Tap area** = Y 1380~1620 (full width), one-thumb zone 메인.
  - 탭 즉시 인디케이터 X 좌표 → 구간 판정 → 0.2s flash + 결과 텍스트 ("PERFECT!" / "GOOD" / "MISS").
- **cook_time progress bar** (별도, bottom Y 1700~1730):
  - 전체 cook_time 동안 채워지는 별도 bar (Stage 2C 진행 표시).
  - 0%에서 100%까지 cook_time_sec동안 채워짐. tap 시점은 자유 (early/late tap 모두 인디케이터 위치로 판정).
- **VFX**:
  - 가스레인지 burner 🔥 glow loop (idle, Stage 2B에서 이어짐).
  - 음식 위 💨 steam particle (끓이기) / 🔥 splash particle (볶기) / 💧 droplet (찌기) — 조리 방법별.

### 3.3 transition (Stage 2C → Scene 3)
- tap 또는 인디케이터 1 왕복 완료 시점 t_end:
  - t_end + 0.0s: 인디케이터 정지 + 판정 결과 텍스트 0.5s fade-in/out.
  - t_end + 0.5s: 가스레인지 + 도구 + 음식 통째로 zoom-out (1.0x → 0.6x) + 접시(plate sprite) zoom-in (0.6x → 1.0x) cross-fade 0.5s.
  - t_end + 1.0s: plated dish hero shot (art-anchor §5.5 F-XX) sprite로 변환 + Scene 3 식탁 BG RIGHT slide-in.
  - t_end + 1.5s: Scene 3 fully visible.
- **총 transition 1.5s** (cooking-mech §10.1 "서빙 모션" 동일).

---

## 4. Stage 2A → 2B → 2C 전체 transition 요약 timeline

| 시점 (Scene 2 진입 후) | 이벤트 |
|------------------------|--------|
| t=0.0s | Scene 1 → Scene 2 transition 종료, Stage 2A 화면 fade-in (도마 + 칼 + ING-XX) |
| t=0.3s | Kitchen rack (basic_pantry 5종) fade-in 완료 |
| t=0.5s | CH-01 chibi 우측 fade-in 완료 (선택사항) |
| t=0.5s | Knife indicator AnimationPlayer "knife_loop" 시작 |
| t=0.5s | 양념재우기 round 한정: marinade bowl 모션 시작 (1.0s arc) |
| **Stage 2A play** | BPM/tap count 기준 변동 (예: 90 BPM × 4 taps = ~2.7s) |
| t_2A_end | 마지막 perfect/good/miss tap → 칼 motion stop + ICUT-XX cross-fade in |
| t_2A_end + 0.3s | 도마 + ICUT-XX LEFT slide-out 시작 |
| t_2A_end + 0.5s | 가스레인지 + 도구 카드 3 RIGHT slide-in 시작, **Stage 2B 시작** |
| **Stage 2B play** | 5~10s (음식별), 사용자 카드 tap |
| t_2B_tap | 카드 tap 즉시 → 0.5s dock 모션 → **Stage 2C 시작** |
| **Stage 2C play** | cook_time_sec (음식별, 인디케이터 1 왕복) |
| t_2C_tap | tap → 판정 0.5s fade |
| t_2C_tap + 0.5s | 가스레인지 zoom-out + plated dish zoom-in cross-fade |
| t_2C_tap + 1.5s | Scene 3 식탁 fully visible, **Scene 2 종료** |

---

## 5. one-thumb / 5-second rule 검증

| Stage | interactive zone | 한 손 도달 | 5초 안에 액션? |
|-------|------------------|------------|-----------------|
| 2A | 도마 Y 1100~1450 + Skip Y 1730 | ✅ 우측 thumb 자연 | tap N회 (2~8, BPM 60~140) — 평균 2~5s |
| 2B | 카드 3장 Y 1100~1500 X 100~980 | ✅ 카드 폭 240px (Material spec 48dp 5배) | 5~10s 시간 제한, 평균 2~3s 의사결정 |
| 2C | tap area Y 1380~1620 (full width) | ✅ 어디든 OK | 인디케이터 1 왕복 = cook_time_sec (3~8s) |

- **5-second rule PASS** = 모든 Stage 평균 사용자 액션 시간 ≤ 5s.
- **One-thumb PASS** = 모든 interactive element가 Y 1100~1700 (오른손 엄지 zone) 안.

---

## 6. ⚙️ Confirm 필요 / 다음 sprint 이월

1. **CH-01 표시 ON/OFF default** — Stage 2C VFX 충돌 가능성, M2 alpha test 후 결정 (pm).
2. **양념재우기 손 sprite anchor 미작성** — M2 art-director sprint 위임. MVP는 칼 motion 재사용 fallback (game-designer/pm 협의).
3. **Stage 2B 카드 수 (3 vs 4)** — 음식별 `method_options` 컬럼 lock (game-designer foods CSV).
4. **Stage 2C `cook_time_sec` 음식 12 lock** — balance-config v0.3.3 §7 후속.
5. **Stage 2A tap miss 시 ING-XX whole 유지 vs ICUT-XX 변환** — game-designer 결정 (현재 가이드: miss여도 progress count, accuracy만 감소).
6. **Kitchen rack 옹기 5종 individual sprite** — art-director Post-M1 sprint (CHANGELOG 2026-05-31 §결과/다음 단계 참조).
7. **Scene 2 → Scene 3 transition zoom-out 음식 sprite swap timing** — godot-dev sync (현재 0.5s overlap 제안).
8. **Stage 2B 오답 시 정답 도구 강제 자동 배치 = visual UX** — pm 확정 (현재 가이드: 자동 배치 + 점수 0).

---

## 7. godot-dev 후속 구현 의존성

### 7.1 Scene 구조 (Godot scene tree)
```
Scene2Kitchen.tscn  (root: Node2D)
├── BgKitchen (TextureRect, art-anchor BG-02 kitchen base)
├── HUD (CanvasLayer, Z=100) — Autoload HudController 구독
│   ├── CoinHud / LifeHud / FoodCardMini / PauseButton
├── KitchenRack (Node2D, Z=80, X=940 Y=235) — CP-22 신규 (별도 sprint)
│   └── PantryJar x5 (Sprite2D + AnimationPlayer fade)
├── CharacterArea (Node2D, Z=40, X=900 Y=1275) — CH-01 optional
│   └── DinerCharacter (Sprite2D + AnimationPlayer idle)
├── Stage2A (Node2D, Z=50) — 활성 Stage만 visible
│   ├── CuttingBoard (cutting_board.tscn = CP-18)
│   ├── KnifeIndicator (knife_indicator.tscn = CP-19)
│   ├── IngredientSprite (Sprite2D, ING-XX → ICUT-XX swap)
│   └── SkipButton (rewarded_skip.tscn)
├── Stage2B (Node2D, Z=50) — visible=false default
│   ├── GasStove (Sprite2D, TOOL-01 base)
│   ├── ToolCards (HBoxContainer x3~4, cooking_tool_slot.tscn)
│   └── ToolDockTarget (Node2D, dock 위치)
├── Stage2C (Node2D, Z=50) — visible=false default
│   ├── GasStove (Stage 2B에서 reparent or 공유)
│   ├── DockedTool (Stage 2B 결과 sprite)
│   ├── FoodInCooking (Sprite2D + VFX)
│   ├── TimingBar (timing_bar.tscn = CP-21)
│   ├── TapArea (Button, full width)
│   └── CookTimeProgress (timer_bar.tscn)
└── TransitionController (Node, scripts/ui/scene2_transition.gd)
```

### 7.2 신규 Scene/Resource (godot-dev sprint M2)
- `scenes/ui/cutting_board.tscn` (CP-18)
- `scripts/ui/cutting_board.gd` (class_name `CuttingBoard`)
- `scenes/ui/knife_indicator.tscn` (CP-19)
- `scripts/ui/knife_indicator.gd` (class_name `KnifeIndicator`)
- `scenes/ui/tool_sprite.tscn` (CP-20 generic, TOOL-XX swap layer)
- `scenes/ui/timing_bar.tscn` (CP-21 신규 또는 기존 components.md §5 확장)
- `scripts/ui/scene2_transition.gd` (Stage 2A↔2B↔2C 전환 controller)
- `resources/cut_style/{cut_id}.tres` (CutStyleResource — `bpm` / `tap_count` / `cut_sprite_id` / `audio_id`)
- `resources/food/{food_id}.tres` 확장 — `prep_ingredient_id` / `prep_cut_style_id` / `prep_bpm` / `prep_tap_count` / `cook_time_sec` / `method_options` / `correct_method_id`

### 7.3 Animation/Tween 패턴
- **AnimationPlayer "knife_loop"** — Y position keyframe loop, BPM에 따라 speed_scale 조정.
- **Tween scene2_transition.gd**:
  - `transition_2a_to_2b()` = Stage2A LEFT slide-out + Stage2B RIGHT slide-in 0.5s parallel.
  - `transition_2b_to_2c()` = ToolCards fade-out + TimingBar fade-in 0.3s.
  - `transition_2c_to_scene3()` = zoom-out + plated dish swap + Scene3 slide-in 1.5s.
- **AnimationPlayer "marinade_arc"** — Pantry 옹기 3개 → marinade bowl arc trajectory (양념재우기 한정).

### 7.4 의존 Resource (M2 prerequisite art lock 확인)
- ✅ CUT-00 도마 + CUT-01~06 cut style 6 (LOCK 완료 2026-05-31)
- ✅ TOOL-01~12 조리도구 12 (LOCK 완료 2026-05-31)
- ✅ ING-01~12 whole 12 + ICUT-01~12 cut 12 (LOCK 완료 2026-05-31)
- ✅ CH-01 주인공 chibi (Week 1 LOCK)
- ⚠️ 옹기 5종 individual (Post-M1, art-director sprint)
- ⚠️ marinade bowl sprite (M2 art-director sprint, 양념재우기 한정)
- ⚠️ plated dish F-01~F-12 (M1 LOCK 완료)

---

## 8. Decisions Log (이번 sprint)

| # | 결정 | 근거 |
|---|------|------|
| K2-01 | Stage 2A/2B/2C는 Scene 2 안의 **sub-flow** (별도 Scene 전환 X) | screen-flow v0.3 sync, transition cost ↓, HUD/Kitchen rack/CH-01 stationary 유지 |
| K2-02 | Stage 2A 도마 = Y 1100~1450 X 240~840 one-thumb zone | 5-second rule + 우측 thumb 자연 도달 |
| K2-03 | Knife indicator = **Y 위↕아래 250px translation only** (Option 1 motion lock) | art-anchor §5.7 LEFT side static + Godot Transform animation 단일 sprite 회전/이동 |
| K2-04 | Kitchen rack = 우측 상단 Y 130~340 X 820~1060 | ADR-007 basic_pantry 시각 cue, HUD 바로 아래 자연 위치 |
| K2-05 | CH-01 = 우측 하단 Y 1100~1450 X 750~1060, **interactive 아님** | 분위기 보조, action zone 침범 회피 |
| K2-06 | Stage 2B 가스레인지 base = 항상 표시, 도구 카드만 swap | 시각 일관성, Stage 2C에서 그대로 이어짐 |
| K2-07 | Stage 2B → 2C transition = **Scene 유지** (게이지 바 fade-in만) | 가스레인지 + 도구 + 음식 sprite 재사용, 빠른 흐름 |
| K2-08 | Stage 2C tap area = Y 1380~1620 full width | one-thumb 어디든 OK, 5-second rule 압도적 PASS |
| K2-09 | 양념재우기 손 sprite 미작성 → MVP **칼 motion 재사용 fallback** | art-director M2 sprint 위임 전 임시 정합, 사용자 confirm 필요 |
| K2-10 | Stage 2A miss tap = ING/ICUT swap 진행 + accuracy만 감소 | game-designer 정합 (정답률 별도 dimension, visual progress는 일관) |

---

## 9. 변경 이력
- **2026-05-31 v0.1** — 초안. Scene 2 안의 Stage 2A/2B/2C sub-flow 3종 layout spec (1080×1920 portrait). 도마/칼 (CUT-00, CP-18/19) + 가스레인지/도구 (TOOL-01~12, CP-20) + timing bar (CP-21) layout 결정. 양념재우기 variant + Kitchen rack (basic_pantry, ADR-007) + CH-01 chibi optional + transition timeline 4종 (2A→2B / 2B→2C / 2C→Scene3). godot-dev Scene 구조 + Animation 패턴 + Resource prerequisite list. Decisions 10항. ⚙️ Confirm 8항.
