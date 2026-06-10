# Cooking Modes v1 — Casual (default) / Immersive (opt-in)

> 버전: **v1.0 (2026-06-05)** · 작성자: game-designer
> Status: **Accepted** · [ADR-013](../decisions.md#adr-013) §3 (사안 #1 resolution) · [ADR-012](../decisions.md#adr-012) input-layer amendment
> 상위 문서: [`decisions.md` ADR-013 / ADR-012 / ADR-011 / ADR-005](../decisions.md), [`product-brief-locked.md`](../product-brief-locked.md), [`action-first-cooking-v1.md` v1.0](action-first-cooking-v1.md), [`cooking-modules-v1.md` v1.1](cooking-modules-v1.md), [`balance-config.md` v0.7 §15](../balance-config.md)
>
> **목표 (브리프 verbatim, ADR-013 §3)**:
> - **Casual Mode (default)**: 간단 tap/drag/one-handed.
> - **Immersive Mode (optional)**: ADR-012 gesture (knife drag / tilt / circular / flick).
> - "Retention > realism."
>
> ⚠️ **본 문서는 신규 system이 아니다** — ADR-012 8-module의 **input-layer variant** (amendment). scoring(4-factor 25/20/20/35) / ★ 임계(30/60/90) / `module_completed(score)` signal contract / dish_modules.csv sequence / progression **전부 무변경**. **입력 난이도만 완화**. 코드는 godot-dev 후속.

---

## 0. 헌법 (5-line constitution)

1. **Casual = default** — 신규 플레이어는 Casual로 시작. one-handed / 최소 정밀도 / 누구나 ★ 도달 가능. retention 우선.
2. **Immersive = opt-in** — ADR-012 action-first gesture (drag-cut / tilt / continuous swipe / flick / heat dial). 깊이를 원하는 플레이어 선택. **코드 재작성 X** (이미 만든 gesture 자산 보존, 재라벨링).
3. **Scoring 무변경** — 두 mode 모두 동일한 output signal 도메인으로 매핑. Casual이라고 점수 상한 낮지 않음 (입력만 쉬움, 평가 기준 동일).
4. **Input-layer variant only** — TouchGestureRecognizer 재활용. mode = 같은 module의 입력 처리 분기. 신규 module/scene/scoring 0.
5. **Mode toggle = settings + onboarding** — 기본 Casual, settings에서 Immersive 전환. onboarding 1회 opt-in 안내 가능.

---

## 1. Casual vs Immersive — 8 Module Variant 표 (LOCK)

> Immersive = ADR-012 action-first (action-first-cooking-v1.md §2). Casual = one-handed 단순화 variant.
> 두 mode 모두 동일 output signal (`accuracy_prep` / `accuracy_arrange` / `accuracy_cook` / `flip_score` / `accuracy_timing` / `accuracy_season` / `accuracy_roll` / `plate_bonus`).

| # | module | **Casual (default)** | **Immersive (opt-in, ADR-012)** | output signal (무변경) |
|:-:|--------|----------------------|----------------------------------|------------------------|
| 1 | **slice** | **tap-and-hold** — 재료 위 hold하면 자동으로 cut anim 진행, 놓으면 정지. tap 타이밍 = cut 완료 | **vertical drag** — 손가락이 재료 통과, 조각 split. cut style 6종 = 6 drag 방향 | `accuracy_prep ∈ [0,1]` |
| 2 | **arrange** | **tap-to-place** — 재료 tap → 다음 빈 슬롯에 자동 배치 (순서 자동) | **press-drag-release** — 색·자리·간격 정밀 배치 (오방색) | `accuracy_arrange ∈ [0,1]` |
| 3 | **stir** | **짧은 swipe N회** — 좌우 짧은 swipe N번 (박자 무관, 횟수만) | **continuous circular swipe** — 끊김 없는 원형 연속 drag, 각속도 | `accuracy_cook ∈ [0,1]` |
| 4 | **flip** | **single tap** — perfect zone에서 1 tap (ADR-011 원안 fallback) | **directional flick** — flick 방향+속도 | `flip_score ∈ {1.0,0.6,0.0}` |
| 5 | **timing** | **single tap at zone** — 게이지가 perfect zone 통과 시 1 tap (정지 meter stop) | **heat dial drag** — 불 다이얼 지속 조절, zone 유지율, overflow 관리 | `accuracy_timing ∈ {1.0,0.6,0.2,0.0}` |
| 6 | **season** | **1-tap auto-pour** — 양념 1 tap → 자동 적정량 dispense (ADR-007 복귀) | **tilt + hold** — 통 기울임 각도+유지로 양 조절. marinade tilt-massage | default `accuracy_season=1.0` / marinade `accuracy_prep` 가산 |
| 7 | **roll** | **tap-and-hold** — 김발 hold하면 자동 progressive roll, 끝에서 놓기 (release 타이밍만) | **forward drag + release** — 김발 앞으로 밀기 속도+압력+release 타이밍 | `accuracy_roll ∈ [0,1]` |
| 8 | **arrange→plate** / **plate** | **tap select** — 그릇 후보 중 tap 선택 + 고명 tap 배치 | **drag + place** — 음식 drag→그릇, 고명 placement | `plate_bonus ∈ {1.0,0.6,0.2}` |

> **핵심**: Casual은 **tap/hold 위주 one-handed**, Immersive는 **drag/tilt/swipe/flick 양손·정밀**. 출력 signal 컬럼은 두 mode 공통 (scoring 무변경).

---

## 2. Casual variant 설계 원칙 (per module)

### 2.1 slice — tap-and-hold

- 재료 위를 **hold** → 칼이 자동으로 cut 동작 (ADR-005 원안 Knife indicator 회귀 변형). hold 유지 = cut 진행, **타이밍 좋게 놓으면** perfect.
- cut style 6종은 Casual에서 **시각 anim만 차이** (drag 방향 학습 부담 제거). 다지기=빠른 anim / 통썰기=느린 anim. 입력은 hold 단일.
- score: hold 놓는 타이밍의 perfect/good/miss (기존 ±80/±200ms window 재활용). one-handed.

### 2.2 arrange — tap-to-place

- 재료를 **tap** → 시스템이 다음 올바른 슬롯에 자동 배치 (순서·위치 자동 결정). 색 맞추기 부담 제거.
- score: 올바른 재료를 tap한 비율 (잘못된 재료 tap = 감점). drag 정밀도 불필요.

### 2.3 stir — 짧은 swipe N회

- 화면 아무 곳이나 **좌우 짧은 swipe N번** (목표 횟수 채우기). 박자·각속도·연속성 무관 = one-handed flick.
- score: N회 완료율 (속도 band 완화). Immersive 연속 원형의 부담 제거.

### 2.4 flip — single tap

- ADR-011 원안 "single perfect-window tap" 그대로 = Casual의 자연스러운 fallback. perfect zone에서 1 tap.
- C-3 lock 정합: MVP 해물파전은 어차피 single 처리 → Casual에서 가장 단순.

### 2.5 timing — single tap at zone

- 게이지가 좌→우 이동, **perfect zone 통과 순간 1 tap** (ADR-005/cooking-mechanics §4 원안). heat dial 지속 조절 부담 제거.
- score: perfect_width(음식별 12 row, §3.2 balance-config) **그대로 적용** — zone 폭 무변경. 갈비 0.04 좁음도 Casual 동일 (단 입력이 1 tap이라 쉬움).
- **가장 중요한 정합**: perfect_width 음식별 값(C-4 lock 0.10/0.45/0.45) 두 mode 공통. Casual은 "정지 게이지 1 tap", Immersive는 "heat zone 유지율" → **동등 매핑** (action-first §3.5 명시).

### 2.6 season — 1-tap auto-pour

- ADR-007 basic_pantry 원안 "1-tap auto-pour" 그대로 = Casual default. 양념 1 tap → 자동 적정량.
- default 음식: `accuracy_season = 1.0` 자동 (시각 ambience만, 점수 영향 0 — ADR-007 정합).
- marinade(불고기): Casual = tap N회 (60 BPM 박자 tap, tilt 없이). Immersive = tilt-and-massage.

### 2.7 roll — tap-and-hold

- 김발 **hold** → 자동 progressive roll, **끝에서 놓기**(release 타이밍만 판정). forward drag 속도 부담 제거.
- score: release 타이밍 band (기존 500~1000ms 재해석 → hold 종료 시점). one-handed.

### 2.8 plate — tap select

- 그릇 후보 1~3개 중 **tap 선택** + 고명 **tap 배치**. drag 불필요.
- score: 그릇 매칭 + 고명 완비 (`plate_bonus {1.0,0.6,0.2}` 무변경).

---

## 3. Mode Toggle (settings)

| 항목 | 사양 |
|------|------|
| **default** | **Casual** (신규 플레이어, retention 우선) |
| **toggle 위치** | Settings → "Cooking Style" (Casual / Immersive). onboarding 1회 opt-in 안내 가능 (선택). |
| **전환 시점** | 라운드 외(메뉴/settings)에서만 전환. 라운드 중 전환 불가 (입력 일관성). |
| **per-module 강제 없음** | mode는 전역 toggle (8 module 일괄). per-module mix 안 함 (혼란 회피). |
| **Remote Config** | `cooking.mode.default = "casual"` / `cooking.mode.allow_immersive = true`. A/B 후보 (Casual vs Immersive retention 비교). |
| **저장** | SaveManager `settings.cooking_mode` (string "casual"/"immersive"). schema bump 불필요 (기존 settings dict). |

---

## 4. Scoring 무변경 명시 (audit)

> **두 mode 모두 동일 output signal → 동일 4-factor → 동일 ★**. Casual이 점수 페널티/상한 없음. 입력 난이도만 다름.

| 항목 | Casual | Immersive | 상태 |
|------|--------|-----------|:----:|
| output signal 도메인 (`accuracy_prep ∈ [0,1]` 등) | 동일 | 동일 | **무변경** |
| 4-factor 가중치 (25/20/20/35) | 동일 | 동일 | **무변경** |
| ★ 임계 (30/60/90) | 동일 | 동일 | **무변경** |
| perfect_width 음식별 12 row | 동일 | 동일 (heat zone 재해석) | **무변경** |
| BPM/cut style 매핑 (§7.1) | anim 속도로만 사용 | drag 속도 band | **무변경** (값 동일) |
| `module_completed(score)` signal | 동일 | 동일 | **무변경** |
| dish_modules.csv sequence (12 음식) | 동일 | 동일 | **무변경** |
| Skip(Rewarded) auto-perfect 0.9 | 동일 | 동일 | **무변경** |

**유일 차이**: 입력 gesture (Casual tap/hold/단순 vs Immersive drag/tilt/swipe/flick) + 그 gesture → output signal 변환 함수. **출력 signal 값과 이후 모든 계산은 양 mode 동일**.

> "Retention > realism" 정합: Casual의 쉬운 입력이 ★ 도달을 막지 않음 (입력 실패율 ↓ = retention ↑). Immersive는 "cooking 느낌" 깊이를 원하는 유저의 opt-in 가치.

---

## 5. godot-dev 후속 impl spec

### 5.1 input-layer 분기 (신규 system 아님)

- **TouchGestureRecognizer 재활용** (ADR-012 §8.1 공통 유틸) — mode flag로 입력 처리 분기:
  - `casual`: tap / hold timer / 짧은 swipe count / single-tap zone.
  - `immersive`: drag path / tilt 각도 / continuous 각속도 / flick velocity / heat dial drag (ADR-012 구현 그대로).
- **각 module scene**: `cooking_mode` 전역 읽어 입력 핸들러 분기. **output signal emit은 양 mode 동일 변환** (§4 audit).
- **module별 Casual 핸들러** (8개):
  - slice: hold timer → release 타이밍 → perfect/good/miss (기존 window).
  - arrange: tap → 다음 슬롯 auto-place → 정답 비율.
  - stir: 좌우 swipe counter → N회 완료율.
  - flip: single tap perfect zone → flip_score.
  - timing: single tap zone 통과 → accuracy_timing (perfect_width 무변경).
  - season: 1-tap auto-pour → accuracy_season 1.0 (marinade: tap N회).
  - roll: hold → release 타이밍 band → accuracy_roll.
  - plate: tap select → plate_bonus.

### 5.2 toggle wire

- SaveManager `settings.cooking_mode` (default "casual"). Settings UI toggle.
- Remote Config `cooking.mode.default` / `cooking.mode.allow_immersive`.
- onboarding 1회 mode 안내 (ui-designer).

### 5.3 우선순위

- **Casual 먼저** (default = 신규 플레이어 첫 경험). Immersive는 ADR-012 구현 자산 그대로 재라벨 (추가 작업 최소).
- module 우선순위: slice(10/12) → timing(11/12) → plate(12/12) → 나머지 (ADR-012 §9 동일 순서).

### 5.4 ui-designer 후속

- Settings "Cooking Style" toggle UI (Casual/Immersive + 짧은 설명 "Simple taps" / "Real cooking gestures").
- onboarding 1회 opt-in 안내 (default Casual, "더 깊은 조리를 원하면 Immersive" 1-line).
- Casual FTUE = tap/hold 학습 (Immersive drag-cut FTUE보다 단순 — ADR-012 FTUE 부담 완화).

### 5.5 content (game-designer, 본 sprint resolved)

- [x] 8 module Casual variant 정의 (vs Immersive 표)
- [x] one-handed 친화 입력 원칙 (tap/hold/짧은 swipe/single tap)
- [x] scoring 무변경 audit (output signal 양 mode 동일)
- [x] mode toggle (settings + Remote Config)

---

## 6. 정합성 (ADR 무변경 audit)

| ADR | 영향 |
|-----|------|
| **ADR-005** (4-stage scoring) | **무변경** — 4-factor / ★ 임계 / Skip auto-perfect 양 mode 동일 |
| **ADR-007** (basic_pantry) | **정합** — Casual season = 1-tap auto-pour 복귀 (ADR-007 원안). 양념 "고르기" X 유지 |
| **ADR-011** (8-module) | **무변경** — 8 module 구성 / sequence / reuse 동일. mode = 입력 분기 |
| **ADR-012** (action-first) | **재라벨링** — gesture = Immersive(opt-in). Casual default variant 추가. 코드 재작성 X (자산 보존) |
| **ADR-013** (Polish, 사안 #1) | **충족** — Casual default / Immersive opt-in / Retention > realism / input-layer variant only / 신규 system 0 |

**유일 신규**: module별 Casual 입력 핸들러 (godot-dev) + settings toggle. scoring/sequence/progression/currency 신규 0.

---

## 7. 관련 문서

- [ADR-013 §3](../decisions.md#adr-013) — Casual/Immersive 정합 (사안 #1, 본 문서의 정식 ADR)
- [ADR-012](../decisions.md#adr-012) — action-first gesture (= Immersive Mode)
- [`action-first-cooking-v1.md` v1.0](action-first-cooking-v1.md) — Immersive gesture 상세 (8 module)
- [`cooking-modules-v1.md` v1.1](cooking-modules-v1.md) — 8 module 구성·sequence·reuse
- [`balance-config.md` v0.7 §15](../balance-config.md) — module BPM/window/threshold (양 mode 공통)
- [`cooking-mechanics.md` v0.7](cooking-mechanics.md) — 4-stage 룰 (scoring 무변경)
- ADR-005 (4-stage) / ADR-007 (basic_pantry) / ADR-011 (8-module) — 전부 무변경
