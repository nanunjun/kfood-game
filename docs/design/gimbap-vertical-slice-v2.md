# Gimbap Vertical Slice v2 — Real Cooking-Sequence Rebuild (김밥 1종)

> 버전: **v2.1 (2026-06-10, REVISED — 거부 반영 재구축)** · 작성자: game-designer
> Status: **DESIGN ONLY — NO CODE. 구현 보류 (사용자 명시: "First update the design doc. Then implement only after approval"). 문서만, 승인 대기.**
> 사용자 mandate (verbatim 요지): *"Do NOT patch the current Roll screen with small tweaks. Rebuild Gimbap flow around the real cooking sequence."* · 범위 = **김밥 1종만** (12 dish 확장 X).
>
> **⚠️ 정직 정정 (v2.0 → v2.1)**: v2.0은 현 Gimbap flow를 *"구현 완료 + 결정판"* 으로 lock했다. **그 lock이 거부됐다.** 코드는 돌지만(F5 12컷 + smoke 14 PASS) **UX가 진짜 김밥 만들기가 아니다** — 조리 순서가 틀렸고, Step 1 Arrange가 generic color-slot 매칭 퍼즐이며, Roll이 완성 김밥 cylinder를 너무 일찍 노출하고, bamboo mat이 뒤틀려 있다. v2.1은 **"이미 만든 것을 기록"하는 문서가 아니라, 실제 김밥 조리 순서로 재구축하는 설계**다. (v2.0 본문 전체를 superseded.)
>
> 상위/관련 (전부 read 후 reconcile):
> - [`gimbap-vertical-slice-v1.md`](gimbap-vertical-slice-v1.md) — v1 5-stage 설계 (참고)
> - [`player-pov-camera-v1.md`](player-pov-camera-v1.md) — Player POV LOCK + roll state (v2.1이 §3·§5에서 강화 흡수)
> - [`dish-recipe-visual-matrix-v1.md`](dish-recipe-visual-matrix-v1.md) — 김밥 correct/banned ground truth
> - **현 코드 (rebuild 대상 식별용 — ground truth 아님, 일부 거부됨)**:
>   - [`gimbap_slice_runner.gd`](../../godot-project/scripts/gameplay/gimbap_slice_runner.gd) — step orchestration (재사용 가능, STEP_PLAN 재구성 필요)
>   - [`shopping_stage.gd`](../../godot-project/scripts/gameplay/shopping_stage.gd) — Market stage (재사용)
>   - [`julienne_module.gd`](../../godot-project/scripts/cooking_modules/julienne_module.gd) — Prep angle+rhythm (재사용)
>   - [`arrange_module.gd`](../../godot-project/scripts/cooking_modules/arrange_module.gd) — **⛔ color-slot 매칭 = 거부됨. Build Gimbap로 대체**
>   - [`roll_module.gd`](../../godot-project/scripts/cooking_modules/roll_module.gd) — two-finger 입력·점수 재사용 / **시각(staged curl)은 거부됨, real 6-state로 rebuild**
>   - [`slice_module.gd`](../../godot-project/scripts/cooking_modules/slice_module.gd) — 통썰기 (재사용)
>   - [`plate_module.gd`](../../godot-project/scripts/cooking_modules/plate_module.gd) — tray drag-arrange (재사용)

---

## 0. TL;DR + 무엇이 거부됐나

현 Gimbap 화면은 **시각은 개선됐으나 조리 시퀀스로 부정확**해서 거부됐다. 핵심은 두 가지다:
1. **Step 1 "Arrange"가 generic color-slot 매칭 퍼즐** — 재료를 색 슬롯에 끼우는 추상 퍼즐이지 김밥 조립이 아니다. (가장 강한 거부 사유)
2. **Roll이 완성 김밥 cylinder를 너무 일찍 표시** — bamboo mat이 뒤틀린 다이아몬드로 깔리고, 첫 push에 이미 완성된 spiral 단면 원통이 나타난다. "물리적으로 말리는 과정"이 아니다.

v2.1은 **실제 김밥 조리 순서(준비 → 김발 → 김 → 밥 → 속 → 말기 → 썰기 → 담기)** 를 stage 구조로 재구축하고, generic Arrange를 **Build Gimbap(drag-assembly)** 으로 대체하며, Roll을 **real 6-state physical curl(완성은 마지막에만)** 로 다시 설계한다. **점수/4-factor/save/economy contract는 보존**한다(시각·stage 구조만 rebuild).

### 0.1 Scope 룰 — 하지 말 것 (LOCK 유지)

| 금지 항목 | 사유 |
|---|---|
| **12 dish 전부 확장** | 김밥 1개 complete vertical slice로 먼저 검증 |
| **generic color-slot Arrange** | ⛔ **거부됨** — 김밥 조립이 아닌 추상 매칭 퍼즐. Build Gimbap로 대체 |
| **완성 김밥 조기 노출** | ⛔ Roll/Build에서 완성 cylinder를 시작부터 보이면 안 됨. 단면은 Slice에서만 |
| **bamboo mat twist/대각 왜곡** | ⛔ mat은 김 밑에 평평히 깔린 직사각. 뒤틀림 금지 |
| **full Market system** (freshness/budget/복잡 inventory) | Shopping = 좌판 1단계 tap으로 충분 |
| **모든 cutting style / plating variation / learning·critic** | scope 밖 |
| **신규 4-factor 축 / 점수 contract 변경** | 0건. 시각·stage 재구축이지 scoring rebuild 아님 |

> **brutal honesty**: v2.0이 "완성·lock"이라 단언한 것을 정정한다. 김밥은 best-case dish다 — 여기서 진짜 "내가 김밥을 만들었다"가 안 나오면 다른 dish로 일반화할 수 없다. 이 slice의 목표는 *"실제 조리 순서가 손맛으로 체감되는가"* 이지 *"코드가 도는가"* 가 아니다(코드는 이미 돌았고, 그걸로 부족했다).

---

## 1. 정확한 김밥 조리 순서 (non-negotiable ground truth)

> 모든 stage 설계는 이 순서를 따른다. 임의 변경 금지.

```
1. 재료 준비    julienne 당근 / 계란 strip / 녹색 strip / 단무지·소고기·햄 strip 썰기
2. 김발 놓기    bamboo mat을 도마에 평평히 (near edge = 플레이어 쪽)
3. 김 놓기      김발 위에 김 한 장 (mat보다 살짝 작게, mat이 둘레 받침)
4. 밥 펴기      김 위에 밥을 얇게 균등하게 (위쪽 far edge에 margin = seal 자리)
5. 속 배치      밥 위에 긴 prepared strip들을 가로로 평행 배치 (lower-third)
6. 말기         near(하단) edge부터 위(far)로 말아 단단한 cylinder
7. 썰기         완성 roll을 균등한 조각으로 통썰기
8. 담기         조각을 tray/도시락에 정렬
```

### 1.1 교정 Stage 구조 (5-stage 권장 / 4-step MVP 허용)

> generic Arrange 폐기. 조리 순서 step별 1:1 대응.

**권장 5-step cooking 구조** (Shopping/Guest 메타 stage 별도):
- **Prep Fillings** (순서 1) — Julienne/strip 준비 (angle + rhythm)
- **Build Gimbap** (순서 2~5) — mat·김·밥·긴 strip 올바르게 배치 (**generic color-slot Arrange 대체**)
- **Roll Gimbap** (순서 6) — bottom edge에서 위로, pressure
- **Slice Gimbap** (순서 7) — rhythm + spacing 고른 조각
- **Plate Gimbap** (순서 8) — 조각 tray 정렬

**MVP 4-step 허용** (단 generic color-slot Arrange 금지):
- Step 1 = **Prep & Build 합침** (썰기 + mat·김·밥·strip 올리기 한 step)
- Step 2 = **Roll** / Step 3 = **Slice** / Step 4 = **Plate**

### 1.2 전체 player-facing flow (메타 stage 포함)

```
┌─ SHOPPING 🏪 (Market 좌판, 메타) ────────────────────────────────────┐
│  김·밥·단무지·당근·계란·시금치 tap 수집 / 함정 회피. 25s.            │
│  → shopping_quality → 4-factor 재료 25% / collected_fillings[] carry │
└──────────────────────────────────────────────────────────────────────┘
        ↓ §6.1 (수집 filling → Build에서 올릴 수 있는 strip 종류)
┌─ STEP 1: PREP FILLINGS 🔪 (조리순서 1) ─────────────────────────────┐
│  당근 julienne + strip 준비. angle + rhythm + spacing + thickness.   │
│  → prep_quality → 4-factor 준비 20% / 준비된 strip 품질 carry        │
└──────────────────────────────────────────────────────────────────────┘
        ↓ §6.2 (prep_quality → Build strip 깔끔함 + Roll sweet zone)
┌─ STEP 2: BUILD GIMBAP 🍙 (조리순서 2~5) ⭐ NEW (color-slot 대체) ────┐
│  ① mat 깔림(평평) → ② 김 mat 위 → ③ 밥 김 위 얇게 (far margin)      │
│  → ④ 긴 prepared strip을 밥 lower-third에 가로 drag (centered)       │
│  → build_quality → 4-factor 준비 20% 보조 / strip 위치 균형 carry    │
└──────────────────────────────────────────────────────────────────────┘
        ↓ §6.3 (strip 위치 균형 → Roll tilt / Build 완성도 → Roll 난이도)
┌─ STEP 3: ROLL GIMBAP 🍙 (조리순서 6) ⭐ REBUILT (real 6-state curl) ─┐
│  near(하단) edge부터 two-finger로 위(far)로 말기.                    │
│  S1 flat → S2 edge lift → S3 first fold → S4 half roll →            │
│  S5 compression(loose/perfect/tight) → S6 finished cylinder         │
│  완성 cylinder는 S6에서만. 단면은 여기 없음(Slice에서).             │
│  → roll_quality → 4-factor 방법 20%                                  │
└──────────────────────────────────────────────────────────────────────┘
        ↓ §6.4 (roll_quality → Slice cut window 폭 + 조각 단면 상태)
┌─ STEP 4: SLICE GIMBAP 🔪 (조리순서 7) ──────────────────────────────┐
│  완성 roll만 표시 → rhythm + spacing + 수직 cut accuracy로 통썰기.   │
│  roll 나쁨 → filling 흘림 / 납작 / window 좁음.                      │
│  → slice_quality → 4-factor 시간 35%                                 │
└──────────────────────────────────────────────────────────────────────┘
        ↓ §6.5 (slice_quality → 조각 단면 wobble/orientation)
┌─ STEP 5: PLATE GIMBAP 🍽 (조리순서 8) ──────────────────────────────┐
│  썰기 후 조각을 tray에 정렬 (straight row / arc / lunchbox).         │
│  spacing + orientation + neatness + broken penalty.                  │
│  → plate_quality → display bonus (★ 임계 무영향)                     │
└──────────────────────────────────────────────────────────────────────┘
        ↓ §6.6 (5 quality 종합 → reaction 지목)
┌─ GUEST 👤 (5-quality reaction bubble, 메타) ────────────────────────┐
│  약점 우선 지목 → 없으면 강점 칭찬 + plating 코멘트. → Result v2     │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 2. ⛔ 거부된 현 화면 + 사유 (정직 — 정정 포함)

> v2.0이 "구현 완료/lock"이라 한 것 중 **거부된 부분을 명확히 한다.** 코드는 돌지만 UX가 진짜 김밥이 아니다.

| # | 거부 항목 | 현 상태 (코드) | 사유 | 처리 |
|---|---|---|---|---|
| 1 | **조리 순서 부정확** | shopping→julienne→arrange→roll→slice→plate | 실제 김밥 순서(준비→김발→김→밥→속→말기→썰기→담기)와 매핑이 느슨, Build 단계 부재 | §1 순서로 stage 재구축 |
| 2 | **⭐ Step 1 Arrange = color-slot 매칭 퍼즐** | `arrange_module.gd` — 재료를 색 슬롯에 drag-snap. `_slot_centers()` band, `correct_count/slot_count` 점수 | **김밥 준비가 아니라 추상 색 매칭 퍼즐.** "Target" chip + 5색 ring 슬롯 + 매칭 슬롯 = 진짜 김밥 조립과 무관 | **폐기 → Build Gimbap drag-assembly (§4)** |
| 3 | **Roll 완성 cylinder 조기 노출** | `roll_module._apply_staged_curl` — 첫 push(avg_p≈0.10)에 이미 완성 spiral 단면 원통 표시 (F5 `edge_lift.png` 확인) | 말리는 과정이 아니라 "완성 김밥이 처음부터 거기 있음". 단면(spiral)은 Slice 전 노출 금지 | **real 6-state rebuild (§5), 단면은 Slice에서만** |
| 4 | **player-POV 부분 적용** | roll target은 하단(NEAR), 음식은 MAIN — 좌표는 정합. 그러나 staged sprite 자체가 side-roll(좌→우) 시점 | **roll sprite가 여전히 구 시점** — bottom→top player-POV로 curl 안 함 | **6-state sprite를 bottom→top POV로 재생성 (§5·§7)** |
| 5 | **bamboo mat 뒤틀림** | `flat_setup.png`/`edge_lift.png` — mat이 회전된 다이아몬드/마름모로 깔림 (FRONTAL_SQUASH 잔재) | mat이 김 밑에 평평히 안 깔림. mat처럼 안 보임 | **mat = 평평 직사각, 김 밑 유지, 대각 twist 금지 (§6 mat 룰)** |
| 6 | **재료 배치가 실제 조립과 무관** | arrange = 색 슬롯 매칭. 어느 재료가 어디 가는지 = 색 매칭일 뿐 | 실제 김밥은 긴 strip을 밥 위 가로로 평행 배치. 색 슬롯과 무관 | **Build = 긴 strip을 밥 lower-third에 가로 drag (§4)** |
| 7 | **generic module 재사용 느낌** | arrange/roll이 다른 dish와 공유되는 generic 모듈 톤 | "진짜 김밥 만들기"가 아니라 "generic 퍼즐에 김밥 스킨" | **Build·Roll을 김밥 전용 조립/curl로 재설계 (§4·§5)** |

> **금지 — Build/Roll에서 절대 나오면 안 되는 것**: color target card / generic ingredient icon / random 매칭 슬롯 / 완성 김밥 target image / 시작부터 완성 cylinder / top-down mat 위 side-view cylinder / scale·stretch 가짜 말기 / 뒤틀린 mat / 구 카메라(side-roll). "**color matching이 아니라 gimbap assembly**".

---

## 3. Player POV Layout 룰 (모든 stage 동일 카메라 — 강화)

> [`player-pov-camera-v1.md`](player-pov-camera-v1.md) 흡수 + 김밥 전용 강화. **모든 stage가 같은 카메라**여야 한다(Build·Roll만 예외 시점 금지).

| 축 | 룰 |
|---|---|
| **시점** | 1인칭 cook의 약간-위 3/4 (gentle high-angle). 정면 elevation / 순수 top-down / "across the table 관전" 금지 |
| **near (하단)** | 화면 **하단 = 플레이어/손/도구 entry**. drag 시작점·two-finger target·roll bottom edge가 여기 |
| **far (상단)** | 화면 **상단 = 도마/tray far edge / 손님**. seal margin(밥 위쪽 빈 김), 완성 cylinder가 위로 드러남 |
| **roll 방향** | **roll bottom(near) → top(far)**. near edge가 위로 말려 올라감. (좌→우 side-roll 금지) |
| **stage 일관** | **모든 stage 동일 카메라.** Build·Roll·Slice·Plate가 다른 시점이면 안 됨 — Build에서 깐 mat/김/밥/strip이 Roll에서 같은 배치로 이어져야 "이걸 내가 말고 있다" 체감 |

**좌표 zone (1080×1920)**:
| zone | y 범위 | 역할 |
|---|---|---|
| **NEAR (하단)** | y ≈ 1340~1920 (하단 20~30%) | drag start / two-finger target / roll near edge |
| **MAIN (중앙)** | y ≈ 580~1340 (중앙 40~60%) | 음식 hero — mat·김·밥·strip / 말리는 대상 |
| **FAR (상단)** | y ≈ 0~580 (상단 10~20%) | far edge / seal margin / tray / 손님 |

> **코드 정합 참고**: roll `TOUCH_TARGET_Y=1230`(NEAR) / `ROLL_HERO_Y=760`(MAIN)은 좌표상 정합. **rebuild 대상은 sprite 시점**(side-roll → bottom→top)과 **mat 평면성**(§5·§6).

---

## 4. ⭐ Build Gimbap Stage (generic color-slot Arrange 대체)

> **이것이 핵심 재설계다.** generic Arrange(색 슬롯 매칭)를 폐기하고, **실제 김밥 조립(mat→김→밥→긴 strip)** 으로 대체한다. 조리 순서 2~5(김발→김→밥→속)를 한 stage로 담는다.

### 4.1 Layer order (z bottom→top, 실제 조립 순서)

```
1. bamboo mat    (받침, 평평 직사각, 김 밑)
2. 김 (seaweed)  (mat 위, dark 직사각, mat이 둘레 받침)
3. 밥 (rice)     (김 most 덮되 얇게, 위쪽 far edge에 margin = seal 자리)
4. 긴 strip들    (밥 lower-third에 가로 평행, 플레이어가 drag로 올림)
```

### 4.2 Player POV layout (§3 정합)

- **하단(near) = 플레이어** — roll이 시작될 near edge가 하단
- mat **수평으로 평평** (대각 twist 금지, §6 mat 룰)
- 김 = mat 위 **dark 직사각**, mat보다 살짝 작음 (mat이 받침 frame)
- 밥 = 김을 most 덮되 **얇게 균등**, **상단(far)에 margin** (= 말 때 풀로 붙이는 seal 자리, 김 노출)
- strip = 밥 **lower-third에 가로** 평행 배치
- 김 폭 = 화면 폭의 **70~85%**
- strip은 밥에 **가까이 붙음** (floating icon 아님 — 실제로 밥 위에 놓인 듯)

### 4.3 Gameplay — drag-assembly (색 매칭 아님)

> **핵심 입력: 긴 prepared strip을 밥 위로 drag하여 배치.** (색 슬롯 매칭 X)

1. **mat → 김 → 밥**: 자동 또는 가벼운 tap-to-place로 깔린다 (조립 순서 보여주기 — 플레이어가 "이 위에 올린다" 인지). mat/김/밥은 위치가 고정(조리 순서상 항상 같은 자리).
2. **strip 배치 (핵심 액션)**: 하단 staging tray에 준비된 긴 strip들(당근/계란/녹색/단무지·소고기·햄)을 플레이어가 **press-drag-release**로 밥 lower-third 가로에 올린다.
   - **정위치** = lower-third, 가로 centered, strip끼리 평행하게 나란히
   - strip은 **긴 가로 막대** (Prep에서 썬 그 strip) — 색 토큰 아님
   - 여러 strip을 평행하게 = 단면이 예쁜 김밥

### 4.4 Failure states (실제 김밥 물리)

| 실패 | 결과 |
|---|---|
| strip을 **너무 위(far)** 에 배치 | 말기 시작점에서 멀어 말기 어려움 → Roll 난이도↑ |
| strip을 **너무 아래(near edge)** 에 | 말 때 끝에서 흘러나옴 (filling burst) |
| strip **과다** | 두꺼워서 말기 난이도↑ (burst 위험) |
| strip **uneven** (한쪽 몰림/비뚤) | 단면이 비뚤어진 김밥 → Roll tilt + Slice wobble |

### 4.5 ⛔ Build 금지 (LOCK)

- **color target card** (어떤 색을 어디 놓을지 알려주는 카드)
- **generic ingredient icon** (추상 토큰)
- **random 매칭 슬롯** (색 ring 슬롯)
- **완성 김밥 target image** ("이렇게 만드세요" 완성본 미리보기)

> "**color matching이 아니라 gimbap assembly.**" 플레이어는 *색을 맞추는 게 아니라 김밥을 쌓는다.*

### 4.6 점수 (contract 보존)

- `build_quality` ∈ [0,1] = strip 위치 정확도(lower-third centered) × 0.5 + 평행/even 0.3 + 적정 양 0.2
- 4-factor: **준비 20% 보조** (Prep과 함께 prep bucket). 기존 arrange가 차지하던 prep bucket을 그대로 승계 — **신규 4-factor 축 0**.
- carry: strip 위치 균형 → §6.3 Roll tilt (현 `get_arrange_balance/bias_dir`의 consequence 신호를 strip 위치 기반으로 재정의)

---

## 5. ⭐ Real Roll State Sequence (6-state, staged sprite — REBUILT)

> 현 roll은 첫 push에 완성 cylinder를 노출한다(거부 #3). **완성은 마지막(S6)에만.** scale/stretch 가짜 금지 — bottom edge부터 **눈에 보이게 curl**. 단면(spiral cross-section)은 **Slice에서만**.

### 5.1 6 state 정의

| state | 시각 (물리적 curl) | 완성 cylinder? | 단면? | scoring 대응 |
|---|---|---|---|---|
| **S1 Flat Setup** | mat·김·밥·filling 평평하게 다 보임. 아직 안 말림. **Build 결과 그대로 이어짐** | **없음** | 없음 | roll 시작 전 (avg_p≈0) |
| **S2 Edge Lift** | mat **하단(near) edge만** 들림, 김 하단 edge 위로 굽음, filling 여전히 다 보임 | 없음 | 없음 | avg_p ≈ 0.0~0.2 |
| **S3 First Fold** | 김/밥이 filling 위로 **fold 시작**, filling 부분 덮임 (일부 사라짐) | 없음 | 없음 | avg_p ≈ 0.2~0.45 |
| **S4 Half Roll** | curved 절반 말림, mat이 김을 wrap, **아직 단면 안 보임** (열린 말이) | 없음(forming) | **없음** | avg_p ≈ 0.45~0.8 |
| **S5 Compression** | pressure 분기: **약=loose/열림** / **perfect=round tight** / **강=crack·squeeze(rice 삐져나옴)** | forming→완성 직전 | 없음 | avg_p ≈ 0.8~ (분기) |
| **S6 Finished Cylinder** | **이때만 완성** round cylinder. 단면은 여전히 **Slice 때만** | **있음(여기서만)** | 없음 | SUCCESS swap |

### 5.2 ⛔ Roll 금지 (LOCK)

- **시작부터 완성 김밥** (S1~S4는 완성 cylinder 없음)
- **top-down mat 위 side-view cylinder** (mat은 평면인데 cylinder만 옆면 = 시점 충돌)
- **scale·stretch** 가짜 말기 (가로폭만 줄이는 것)
- **뒤틀린 mat** (대각 twist)
- **구 카메라** (side-roll 좌→우)

### 5.3 Staged sprite 전환 = curling (scaling 아님)

```
flat_setup → edge_lift → first_fold → half_roll → compressed{loose/perfect/tight} → finished_cylinder
```
- 전환 = **sprite swap (curl 진행)** + 미세 position.y(말리며 far로 상승) + rotation(tilt→비뚤). **가로 stretch 0.**
- 곡률은 **sprite에 baked** (Godot은 swap + 미세 position/rotation만). mesh deform 불필요.
- compression(S5)은 pressure(avg_p)로 loose/perfect/tight 3분기 — roll_module의 burst/loose 임계와 1:1.

### 5.4 입력·점수 (contract 보존)

- **two-finger 입력 무변경** (좌·우 하단에서 위로 함께 push). multi-touch index 추적.
- **scoring 공식 무변경**: balance40 + pressure25 + distance20 + smooth15 → roll_quality [0,1] → 방법 20%.
- rebuild 대상 = **시각 layer만** (가짜 staged → real 6-state bottom→top curl + mat 평면화). contract 무변경.

---

## 6. Bamboo Mat 룰 (LOCK — 거부 #5 교정)

> 현 mat은 뒤틀린 다이아몬드로 깔린다. mat은 **김 밑에 평평히 깔린 받침**이어야 한다.

| 룰 | 내용 |
|---|---|
| **김 밑 유지** | mat은 항상 김(seaweed) **밑**에 깔림. 김 위로 올라오지 않음 |
| **player POV 정렬** | §3 카메라와 정렬 (near edge 하단, 수평) |
| **대체로 직사각 평평** | 평평한 수평 직사각. **대각 twist / 마름모 / 다이아몬드 금지** |
| **김보다 살짝 큼** | mat이 김 둘레를 받침 frame처럼 살짝 감쌈 |
| **rolling 때 하단 edge만 lift** | S2에서 mat **하단(near) edge만** 들림. 전체 회전·twist 금지 |
| **충돌 시 mat을 고침** | mat이 roll과 시점 충돌하면(예: 평면 mat 위 옆면 cylinder) → **mat을 고친다**(roll에 mat을 억지로 맞추지 않음) |

> **현 코드 원인**: `FRONTAL_SQUASH_Y` / `RICE_SQUASH_Y` 잔재가 평평 top-down rect를 비스듬 parallelogram으로 왜곡. v2.0이 1.0/0.92로 완화했다고 기록했으나 F5 결과상 mat은 여전히 뒤틀려 보임 → **mat asset/배치를 평면 직사각으로 재정렬 필요**(godot-dev 구현 시).

---

## 7. Slice / Plate Consequence (조리 순서 7~8)

### 7.1 Slice Gimbap (조리순서 7)

- **roll 완료 후에만 완성 roll 표시** (S6 cylinder). 그 전엔 Slice 진입 금지.
- gameplay: **rhythm + spacing + 수직(vertical) cut accuracy** — 균등한 조각으로 통썰기.
- **roll 나쁨 → 결과**: filling 흘림(loose roll) / 납작(squeeze) / clean(perfect). roll_quality가 cut window 폭 결정(§6.4).
- 단면(spiral cross-section)은 **여기서 처음** 드러난다 (자른 면).
- 점수: `slice_quality` ∈ [0,1] → 4-factor 시간 35%.

### 7.2 Plate Gimbap (조리순서 8)

- 썰기 후 **조각을 tray에 정렬** (straight row / arc / lunchbox 중 1 layout).
- gameplay: 조각 drag → tray target에 snap.
- 점수: **spacing + orientation + neatness + broken penalty** → `plate_quality` → display bonus (★ 임계 무영향, ADR-009).
- guest plating 코멘트 (§8.6): "Looks like a real lunchbox!" / "A little messy".

---

## 6'. Cross-Stage Consequence Chain (점수 contract 보존, carry 재정의)

> "What I did earlier changed what happened later." chain 골격은 보존, **§8.3은 color-slot balance → strip 위치 balance로 carry 신호만 재정의**.

```
shopping_quality ─§6.1─▶ Build에서 올릴 수 있는 strip 종류  (누락 = 빈 김밥)
prep_quality     ─§6.2─▶ Build strip 깔끔함 + Roll sweet zone 폭 (나쁜 strip → 좁아짐)
build strip 균형  ─§6.3─▶ Roll tilt offset                  (strip 한쪽 몰림 → 비뚤)
roll_quality     ─§6.4─▶ Slice cut window 폭 + 조각 단면    (loose roll → 빡빡 + wobble)
slice_quality    ─§6.5─▶ Plate 조각 단면 wobble/orientation (제각각 단면 → messy)
5 quality 종합    ─§6.6─▶ Guest reaction                    (약점 우선 지목)
```

| # | chain | 메커니즘 | carry | 코어? |
|---|---|---|---|---|
| §6.1 | shopping→Build | 수집 filling 수만큼만 Build strip 사용 가능. 누락 = 빈 김밥 | `collected_fillings[]` | P1 |
| §6.2 | prep→roll | prep_quality → roll sweet zone 폭 lerp + Build strip 시각 깔끔함 | `prep_quality` | **코어** |
| §6.3 | Build→roll | **strip 위치 좌우 균형** → roll tilt offset (현 arrange balance getter를 strip 위치 기반으로 재정의) | strip balance/bias | P1 |
| §6.4 | roll→slice | roll_quality → slice cut window 폭 + 조각 wobble | `roll_quality` | **코어** |
| §6.5 | slice→plate | slice_quality → 조각 시작 wobble + orientation 패널티 | `slice_quality` | P1 |
| §6.6 | plate→guest | 5 quality 최저 약점(<0.45) 우선 지목, 없으면 강점 칭찬 | 5 quality | **코어** |

> **점수 보존**: §6.2/§6.4/§6.6 코어 chain의 입력→결과 인과 수치(roll Δ8.4 / slice Δ11.9 등)는 **scoring 공식이 그대로라 유지**된다. 재구축은 **시각·stage·carry 신호 정의**이지 점수 계산식 변경이 아니다.

---

## 8. Visual / Failure / Guest reaction (step별)

### 8.1 Visual states (perfect / good / bad)

| step | perfect | good | bad |
|---|---|---|---|
| **Prep** | 고른 얇은 strip + "Even, thin strips!" | minor uneven | chunky uneven + "Uneven, chunky" |
| **Build** | mat 평평 + 김 + 밥 얇게 + 긴 strip lower-third centered 평행 | strip 약간 off | strip 너무 위/아래/몰림/과다 → 비뚤 |
| **Roll** | S6 round clean cylinder + "Perfect Balance!" (완성은 여기만) | 약간 loose/tilt | loose(헐거움) / tight(burst, rice 삐져나옴) / crooked(tilt) |
| **Slice** | 고른 조각 clean 단면 (가로 row) | minor 두께 차 | wobble 조각 (위치/기울기/크기 제각각) |
| **Plate** | tray 정갈 정렬 + "real lunchbox!" | "Plated" | "A little messy" (조각 wobble, off-center) |

### 8.2 Failure states

| step | failure | 결과 |
|---|---|---|
| **Prep** | too fast / 들쭉날쭉 rhythm / wrong angle | prep_quality 저점 → roll 어려움(§6.2) |
| **Build** | strip 너무 위/아래/몰림/과다 | 말기 어려움 / burst / tilt(§6.3) |
| **Roll** | loose/burst/crooked / 한 손만 push | filling shift·찢김·비뚤 → slice 어려움(§6.4) |
| **Slice** | roll 나쁨으로 window 좁음 → 빗나간 cut | wobble 조각 → plating 지저분(§6.5) |
| **Plate** | snap 실패 / off-center / wobble 잔존 | plate_quality 저점 → guest "messy"(§6.6) |

### 8.3 Guest reaction (§6.6 지목)

- 약점 우선: "The filling is falling out…" (loose roll) / "thicker than others" (uneven slice) / "a little messy" (plating) / "chunky strips" (prep)
- 강점: "Wow, the roll is so clean!" / "Looks like a real lunchbox!"
- plating 코멘트 별도: tray 정렬 neatness 직접 언급.

---

## 9. Asset Requirements (보유 staged sprite reconcile + 신규 명시)

### 9.1 보유 staged roll sprite (import 완료) — naming reconcile

> 현재 `art/sprites/roll/`에 5장 staged sprite + 2 base가 있다. **6-state(§5)와 naming 정합 필요.**

| 보유 sprite (현) | §5 state 매핑 | 시점/평면 reconcile |
|---|---|---|
| `gimbap_roll_edge_lift` | **S2 Edge Lift** | ⚠️ 현재 완성 cylinder 노출 — **bottom→top, 완성 없음으로 재생성** |
| `gimbap_roll_first_fold` | **S3 First Fold** | ⚠️ 현재 완성 spiral 단면 노출 — **fold 시작(부분 덮임)으로 재생성** |
| `gimbap_roll_cylinder_forming` | **S4 Half Roll** | naming: `cylinder_forming` = "half_roll" 동일 단계. 단면 없는 forming으로 유지/재생성 |
| `gimbap_roll_compressed_loose` | **S5 loose** | bottom→top POV 정합 확인 |
| `gimbap_roll_compressed_tight` | **S5 tight** | bottom→top POV 정합 확인 |
| `gimbap_roll_finished_content_only` (base) | **S5 perfect / S6 finished** | 완성 cylinder. **단면 노출 여부 확인** (Slice 전엔 단면 금지) |
| `gimbap_roll_halfway` (base) | (S4 후보) | side-roll 시점 — `cylinder_forming`과 중복, **deprecate 또는 POV 재생성** |

### 9.2 신규 필요 (명시)

| asset | 용도 | 우선순위 |
|---|---|---|
| **roll 6-state 전부 bottom→top POV 재생성** | edge_lift / first_fold / half_roll = 현재 완성 cylinder 조기 노출 + side-roll 시점 → **재생성 P0** | **P0 (blocker)** |
| **flat_setup 합성 정합** | mat 평평 + 김 + 밥 + strip (S1, Build 결과와 동일 배치) — 뒤틀린 mat 교정 | **P0** |
| **bamboo mat 평면 직사각** | 현재 뒤틀린 다이아몬드 → 평평 수평 직사각 재생성/재배치 | **P0** |
| **half_roll naming 정합** | `cylinder_forming` vs `half_roll` 용어 통일 (둘 중 하나로 lock, art↔code) | P1 |
| **긴 prepared strip (Build용)** | 당근/계란/녹색/단무지·소고기·햄 긴 가로 strip — 보유 `*_strip_long` 재사용 + 단무지 신규 | P1 |
| **danmuji standalone strip** | dish-correct 단무지 (현 carrot substitute) | P1 |

> **art 비용 정직**: 거부 핵심(roll 시각·mat)이 **P0 blocker** — 기존 5 staged sprite는 완성 cylinder를 조기 노출하고 side-roll 시점이라 **그대로 못 쓴다. bottom→top POV + 완성 없는 중간 state로 재생성 필요.** Build strip은 기존 `*_strip_long` 재사용 가능.

### 9.3 보유 base/ingredient (재사용)

| 영역 | asset |
|---|---|
| **Build base** | `roll/bamboo_mat_large`(평면화 필요) · `seaweed_sheet_rect` · `rice_layer_flat_rect` · `carrot/egg/green/beef_strip_long` |
| **Prep** | `ingredient/carrot_whole` · `carrot_julienne` · `carrot_julienne_bad` |
| **Plate** | `vessels/wooden_tray` |
| **Shopping** | 정답/함정 tile sprite (ArtRegistry graceful fallback) |
| **Guest** | 5인 neutral avatar + reaction bubble (procedural) |

---

## 10. F5 Screenshot Target List (8 — 검증용)

> 재구축 후 이 8컷으로 거부 사유가 해소됐는지 증명. opengl3, NOT headless.

| # | shot | 검증 (거부 해소) |
|---|---|---|
| 1 | **Build** | 평평 mat + 김 + 밥(far margin) + 긴 strip lower-third centered. **color-slot 아님** (#2 해소) |
| 2 | **Roll S1** | flat — mat·김·밥·filling 평평. **완성 cylinder 없음** (#3 해소) |
| 3 | **Roll S2** | edge lift — 하단 edge만 들림, filling 보임, **완성 없음** (#3 해소) |
| 4 | **Roll S3** | first fold — fold 시작, filling 부분 덮임, **단면 없음** |
| 5 | **Roll S4** | half roll / forming — curved 절반, **단면 없음** (#3 해소) |
| 6 | **Finished** | round cylinder — **success 후에만** (S6) |
| 7 | **Slice** | 완성 roll + cut guide — **단면은 여기서 처음** |
| 8 | **Plate** | 조각 tray 정렬 (row/arc/lunchbox) |

> 모든 컷 동일 카메라(player POV 하단=near). mat 평면 직사각 확인 (#5 해소). side-roll 시점 부재 확인 (#4 해소).

---

## 11. 재사용 (keep) vs 재구축 (rebuild) — 정직 구분

### 11.1 재사용 가능 (점수/입력/메타 contract 보존)

| 시스템 | 파일 | 상태 |
|---|---|---|
| **gimbap_slice_runner** | `gimbap_slice_runner.gd` | step orchestration + quality-state carry. **STEP_PLAN을 Prep→Build→Roll→Slice→Plate로 재구성** (arrange→Build 교체) |
| **shopping_stage** | `shopping_stage.gd` | Market 좌판 tap. **재사용** |
| **Prep (julienne)** | `julienne_module.gd` | angle + rhythm + spacing + thickness. **재사용** |
| **two-finger pressure 입력** | `roll_module.gd` 입력부 | multi-touch index 추적 + scoring 공식. **재사용 (시각만 rebuild)** |
| **slice** | `slice_module.gd` | 통썰기 + §6.4 hook. **재사용** |
| **plate (tray drag-arrange)** | `plate_module.gd` | tray 정렬. **재사용** |
| **consequence chain hook** | runner + module hook | §6.1~§6.6 골격. **재사용 (§6.3 carry 신호만 strip 위치로 재정의)** |
| **Guest 2.0** | guest-system-v2 + runner reaction | 5-quality bubble. **재사용** |
| **Result v2** | `result_screen_v2.gd` | emotion-first. **재사용** |
| **4-factor / save / economy** | parent CookingModuleRunner | **무변경 (점수 contract 100% 보존)** |

### 11.2 재구축 (rebuild — 거부 반영)

| 항목 | 현 (거부) | rebuild |
|---|---|---|
| **Build Gimbap** | `arrange_module` color-slot 매칭 퍼즐 | **drag-assembly (mat→김→밥→긴 strip, §4). color-slot 폐기** |
| **Roll 시각** | 첫 push에 완성 cylinder + side-roll 시점 + 단면 조기 노출 | **real 6-state bottom→top curl (§5). 완성은 S6에만, 단면은 Slice에만** |
| **bamboo mat** | 뒤틀린 다이아몬드 | **평평 수평 직사각, 김 밑, 하단 edge만 lift (§6)** |
| **roll staged sprite** | 5장 완성 cylinder 조기 노출 + side-roll | **bottom→top POV + 중간 state 완성 없음으로 재생성 (§9.2 P0)** |

> **핵심**: 입력·점수·save·economy·메타 stage(shopping/guest/result)는 **재사용**. **거부된 것은 (1) Build 메커닉(color-slot→assembly) (2) Roll 시각(완성 조기/side-roll) (3) mat(twist)** 3개. 점수 contract는 시각·stage 재구축 동안 보존.

---

## 12. 제약 / LOCK

| LOCK | 내용 |
|---|---|
| **구현 X** | 문서만, 승인 대기. "First update the design doc. Then implement only after approval." |
| **김밥만** | 12 dish 확장 X |
| **generic color-slot Arrange 폐기** | Build Gimbap drag-assembly로 대체 (§4) |
| **roll real staged** | 6-state bottom→top curl, 완성 S6만, 단면 Slice만 (§5) |
| **bamboo mat 안 twist** | 평평 직사각, 김 밑 (§6) |
| **player POV 일관** | 모든 stage 동일 카메라 (§3) |
| **점수 contract 보존** | 4-factor/save/economy/scoring 공식 무변경. 시각·stage·carry만 재구축 |

---

## 13. 보고 요약 (parent agent 용)

1. **v2.1 개정 완료** — `docs/design/gimbap-vertical-slice-v2.md`. 핵심 변경: v2.0 "구현 완료 lock" 정정 → **실제 조리 순서로 재구축**(generic Arrange 폐기, Roll real 6-state, mat 평면화).
2. **거부 사유 (정직)**: ① 조리 순서 부정확 ② Step1 Arrange = color-slot 매칭 퍼즐(핵심) ③ Roll 완성 cylinder 조기 노출 ④ player-POV 부분 적용(roll sprite는 구 side-roll 시점) ⑤ bamboo mat 뒤틀림 ⑥ 재료 배치가 실제 조립과 무관 ⑦ generic module 재사용 느낌. **v2.0이 "완성"이라 한 것을 정정 — 코드는 돌지만 UX가 진짜 김밥 아님.**
3. **교정 stage order**: Prep Fillings → **Build Gimbap(color-slot 대체)** → Roll → Slice → Plate. Build = mat→김→밥→긴 strip drag-assembly (color matching 아닌 gimbap assembly).
4. **real Roll 6-state**: S1 Flat → S2 Edge Lift → S3 First Fold → S4 Half Roll → S5 Compression(loose/perfect/tight) → S6 Finished. **완성은 S6에만, 단면은 Slice에만, bottom→top curl, scale 가짜 금지.**
5. **asset reconcile**: 보유 5 staged sprite는 완성 cylinder 조기 노출 + side-roll 시점이라 **P0 재생성 필요**(bottom→top POV, 중간 state 완성 없음). mat 평면 직사각 재생성 P0. Build strip은 `*_strip_long` 재사용.
6. **F5 8 target**: Build / Roll S1 / S2 / S3 / S4 / Finished / Slice / Plate.
7. **재사용 vs rebuild**: 재사용 = runner(STEP_PLAN 재구성) / shopping / julienne / two-finger 입력·점수 / slice / plate / consequence hook / Guest 2.0 / Result v2 / 4-factor·save. **rebuild = Build 메커닉(color-slot→assembly) / Roll 시각 / mat / roll sprite 3개.** 점수 contract 보존.

---

## 14. 변경 이력
- **2026-06-10 v2.1 (REVISED)** — 거부 반영 재구축. v2.0 "구현 완료 lock"을 정정(코드는 돌지만 UX가 진짜 김밥 아님). 실제 조리 순서(준비→김발→김→밥→속→말기→썰기→담기)로 stage 재구축: generic color-slot Arrange 폐기 → **Build Gimbap drag-assembly(§4)** / Roll → **real 6-state bottom→top curl(§5, 완성 S6만·단면 Slice만)** / bamboo mat 평면 직사각 lock(§6) / player POV 모든 stage 일관(§3) / asset 보유 5 staged sprite P0 재생성 명시(§9) / F5 8 target(§10) / 재사용 vs rebuild 정직 구분(§11). **DESIGN ONLY, NO CODE, 김밥 1종, 점수 contract 보존, 승인 대기.**
- **2026-06-10 v2.0 (SUPERSEDED)** — 현 구현을 ground truth로 lock한 결정판. **거부됨** — color-slot Arrange / Roll 완성 조기 노출 / mat twist / side-roll 시점이 진짜 김밥 조리가 아니라는 이유. v2.1이 재구축으로 대체.
