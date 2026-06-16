# Gimbap Rolling Technique v1 — 실제 김밥집 영상 기반 LOCK (ground truth)

> 버전: **v1 (2026-06-13)** · 작성자: art-director
> Status: **GROUND TRUTH LOCK.** 사용자가 김밥집 사장 영상 프레임을 직접 확인하고 잡아낸 실제 기법.
> 모든 Gimbap art asset(roll/build/slice)·Godot 구현(Build/Roll/Slice)이 이 문서를 따른다.
>
> 관련:
> - [`gimbap-vertical-slice-v2.md`](gimbap-vertical-slice-v2.md) — 5-stage UX 설계 (이 문서가 §4 Build / §5 Roll / §7 Slice 의 *물리적 ground truth* 를 보강)
> - [`gimbap-visual-quality-rebuild-v1.md`](gimbap-visual-quality-rebuild-v1.md) — painterly 재생성 계획 (단면금지 원리)
> - 생성 driver: [`tools/gen_gimbap_painterly.py`](../../tools/gen_gimbap_painterly.py) — `slot_mode="open_log"` 가 이 문서를 강제

---

## 0. 왜 이 문서가 생겼나 (정직 — 내가 두 번 틀린 것)

**1차 오류:** 완성 김밥을 oblique 3/4 + 단면 baked 로 그림 → 거부.
**과교정 2차 오류:** 1차를 고치다가 완성 통을 **양끝까지 김으로 막힌 "닫힌 캡슐"** 로 그림. 이것도 틀림.
사용자 교정: **"김밥 양쪽 끝은 틔어있어야지, 왜 김으로 막혀있나."**

> **완성된 김밥 통(도마 위 안 썬 한 줄)의 실제 모습:**
> - **김은 둘레(긴 곡면)만 감싼다** — 매끈 반들 검은 glossy 김 + 봉합 seam 한 줄.
> - **양쪽 끝(end faces)은 열려서 단면이 보인다** — 흰 밥 ring + 가운데 색색 속재료 cluster.
> - 즉 완성 통은 **양끝 OPEN 원통(open-ended log)** 이지, 김으로 양끝까지 막힌 캡슐이 아니다.

**구분이 핵심:**
- **완성 통**(roll_finished/loose/burst/roll_for_slice) = 양끝 OPEN 단면 보임. **둘레만 김.**
- **말리는 *중간* state**(roll s1~s5: flat/edge_lift/first_fold/curling/compression) = 아직 통이 안 됐으니 단면 없음. **김 바깥면만**(NO_CROSS_SECTION 유지). 무변경.
- **썰린 조각**(piece_good/collapse) = spiral 단면 노출. 무변경.

**LOCK.**

---

## 1. 영상 기반 7-step 기법 순서 (non-negotiable)

> 김밥집 사장 영상 프레임에서 확인한 실제 손동작. 임의 변경 금지.

```
1. 김 세로 놓기      김(nori)을 세로(portrait)로 김발 위에 — 긴 변이 near→far 로 섬
2. 밥 꼭꼭 압착       밥을 꼭꼭 눌러 압착, 김 대부분 덮되 far쪽 끝 = 맨 김(margin, 봉합용)
3. 재료 한 다발       여러 재료(계란/햄/당근/단무지/오이/우엉)를 딱 붙여 한 다발로,
                     밥 위 가로(좌→우) 한 줄에 몰아 놓음
4. far 맨김 봉합 준비  far쪽 끝은 밥 없는 맨 김 margin — 다 말았을 때 풀처럼 붙는 봉합 자리
5. near 덮기(envelope) near edge 를 재료 위로 덮어 감싸기 (재료가 덮여 사라짐)
6. 굴리기 + 다지기     굴려 통을 만든 뒤 김발로 꼭꼭 눌러 다져 단단히 압착
7. 양끝 OPEN 통        완성 = 둘레는 매끈 반들 검은 김, 양쪽 끝은 열려 단면(밥 ring+속) 보임
                     (도마 위 안 썬 통김밥) → 썰면 각 조각 단면으로 분리
```

### 1.1 step 핵심 디테일

| step | 손동작 | 시각 결과 (asset에 반영) |
|---|---|---|
| **1. 세로 김** | 김 portrait 로 김발 위 | 김발 평평, 김이 그 위 (mat 회전/twist 금지) |
| **2. 밥 압착** | 밥 꼭꼭 눌러 펴기 | 밥이 김 대부분 덮음, **far쪽 끝 맨 김 margin** 남김 |
| **3. 재료 한 다발** | 여러 재료 딱 붙여 한 줄 | **한 다발**(틈 없이 붙음) 가로 한 줄, 색 슬롯 따로따로 X |
| **4. far 맨김** | far margin = 봉합 자리 | far쪽 김 노출(밥 없음) |
| **5. near 덮기** | near edge 재료 위로 덮음 | envelope — 재료가 김 안으로 사라짐 |
| **6. 굴리기·다지기** | 굴린 뒤 김발로 압착 | 둥근 통 → 단단히 다져짐 (pressure beat) |
| **7. 양끝 OPEN 통** | — | **둘레만 매끈 검은 김(seam 1줄), 양쪽 끝은 열려 단면(밥 ring+속) 보임** |

---

## 2. 재료 배치 룰 (한 다발 + margin) — LOCK

> v2 설계의 §4 Build 가 "긴 strip 평행 배치"라고 했지만, 영상 ground truth 는 더 구체적이다.

| 룰 | 내용 |
|---|---|
| **한 다발** | 재료(계란/햄/당근/단무지/오이/우엉)를 **틈 없이 딱 붙여 한 다발**로 묶어 가로 한 줄. 색별로 흩뿌리지 않음 |
| **가로 한 줄** | 다발은 밥 위 가로(좌→우) 한 줄. near쪽으로 약간 치우쳐 놓아 덮어 말기 좋게 |
| **near쪽 짧은 밥** | near edge 쪽은 밥을 약간 짧게(덮어 굴릴 여유) |
| **far쪽 긴 밥 + 맨김** | far쪽은 밥을 끝까지 펴되, **맨 끝은 밥 없는 맨 김 margin**(봉합) |
| **다발 두께** | 적정 다발 = 깔끔히 말림. 과다 다발 = 두꺼워 말기 burst 위험 |

```
 far (상단) ┌─────────────────────────────┐  ← 맨 김 margin (밥 없음, 봉합 자리)
            │░░░░░░ 밥(긴 쪽) ░░░░░░░░░░░░░│
            │▓▓▓▓▓▓ 재료 한 다발 ▓▓▓▓▓▓▓▓▓│  ← 한 줄, 틈 없이 붙은 다발
            │░░░ 밥(near쪽 짧음) ░░░░░░░░░░│
 near (하단)└─────────────────────────────┘  ← near edge (여기서 덮어 말기 시작)
```

---

## 3. 마는 법 (near 덮기 → 굴리기 → 다지기) — LOCK

```
near edge 를 재료 다발 위로 덮어(envelope) 감싼다
        ↓
앞으로 굴려 통(cylinder)을 만든다 (near→far 방향, bottom→top)
        ↓
far 맨김 margin 으로 봉합(seam 한 줄)
        ↓
김발로 통을 꼭꼭 눌러 다져(press) 단단히 압착
        ↓
완성 통 — 둘레는 매끈한 검은 김, 양쪽 끝은 OPEN 단면(밥 ring+속) 보임
```

- 마는 방향 = **near(하단) → far(상단)**, 즉 bottom→top (좌→우 side-roll 아님 — player-POV LOCK).
- **다지기(press) = 별도 동작.** 굴리기만으로 끝 아님 — 김발로 눌러 다져야 단단한 통. (게임 beat 후보)
- 너무 약하게 다짐 = loose(헐거운 통, seam 살짝 뜸). 너무 세게 = burst(김 갈라지고 밥 삐져나옴).

---

## 4. 완성 시각 룰 (가장 중요한 교정) — LOCK

> **완성 김밥 통 = 둘레만 매끈 검은 김 + 양쪽 끝은 OPEN 단면(밥 ring+속) 보임.**
> **양끝까지 김으로 막힌 "닫힌 캡슐" 금지. 단, 말리는 *중간* state 는 단면 없음.**

| 상태 | 겉모습 | 양끝 단면? |
|---|---|---|
| **완성 통 (roll_finished)** | 둘레 매끈 반들 검은 김(seam 1줄, sheen) + 양끝 OPEN 단면(밥 ring+속 cluster) | **OPEN(보임)** |
| **헐거운 통 (loose)** | 둘레 약간 우는 검은 김, seam 살짝 뜸 + 양끝 OPEN 단면 살짝 벌어짐(slack) | **OPEN(보임)** |
| **터진 통 (burst)** | 둘레 김 top 갈라지고 밥 삐져나옴, 납작 변형 + 양끝 OPEN 으깨진 단면 | **OPEN(보임)** |
| **썰기 전 통 (roll_for_slice)** | 가로로 누운 통, 둘레 매끈 검은 김(seam 1줄) + 양끝 OPEN 단면 | **OPEN(보임)** |
| **썰린 조각 (piece_good/collapse)** | 개별 조각 정면 단면(김 ring + 밥 ring + 속) | **노출 OK** (썰기 결과) |
| **말리는 중 (roll s1~s5)** | 김 바깥면만(아직 통 아님) — flat/edge/fold/curling/compression | **없음(단면 금지)** |

핵심: 완성 통은 **김이 둘레(긴 곡면)만 감싸고 양끝은 열린 open-ended log**. 김으로 양끝까지 막힌 캡슐이 아니다.
말리는 중간 state 는 아직 통이 안 됐으므로 단면이 생기지 않는다 — 거긴 김 바깥면만 (무변경).

### 4.1 prompt 강제절 (driver `slot_mode="open_log"` = OPEN_END_LOG)

> 완성 4-asset 에 부착. (`tools/gen_gimbap_painterly.py` 의 `OPEN_END_LOG` 상수와 동일)

```
finished gimbap roll lying horizontal, long axis left-to-right;
long curved SURFACE (tube circumference) = smooth glossy dark seaweed (nori) + single faint seam;
BOTH ROUND END FACES ARE OPEN, showing the cross-section
  (outer ring of white rice + center cluster of colorful fillings);
the seaweed wraps ONLY the long circumference — the ends are OPEN, NOT capped by seaweed.
NOT a closed capsule, NOT a sealed pill, NOT sliced into pieces —
ONE long uncut log on a board with OPEN ends, seen at a slight angle so both ends show.
```

### 4.2 단면 규칙 (무변경 / 구분)

- `gimbap_piece_good` / `gimbap_piece_collapse` = **썰린 개별 조각**이므로 정면 spiral 단면 노출 **맞다. 무변경.**
- roll s1~s5 (flat/edge_lift/first_fold/curling/compression) = **말리는 중**이라 단면 없음. **무변경**(NO_CROSS_SECTION 유지).
- 완성 통의 "OPEN 단면"과 썰린 조각의 "정면 단면"은 다름: 완성 통은 **긴 통 + 양끝**, 조각은 **짧은 disc 하나**.

---

## 5. Godot 구현 가이드 (godot-dev 후속)

> 점수/입력 contract 보존(v2 §5.4 / §11). 이 문서는 **시각·물리 ground truth** 만 lock.

### 5.1 Build (조리순서 2~5) — 다발 + margin

- 재료를 **한 다발**(여러 재료 붙여)로 밥 위 가로 한 줄에 배치 (색 슬롯 따로 X — v2 §4 Build 정합).
- 밥 layer 는 far쪽 끝에 **맨 김 margin** 표시 (밥 없는 김 = 봉합 자리). near쪽 밥 약간 짧게.
- Build 결과(다발 + margin + near 짧은 밥)가 Roll S1 flat_setup 과 **동일 배치로 이어짐**.

### 5.2 Roll (조리순서 6) — 덮기 + 다지기 beat

- 마는 방향 near→far (bottom→top, player-POV). S2 near edge 덮기(envelope) → S3~S5 굴림.
- **다지기(press) beat 추가 고려**: 굴린 뒤 김발 압착 = pressure 입력(현 two-finger). 약/적정/강 → loose/perfect/burst.
- **S6 완성 = 양끝 OPEN 통(OPEN_END_LOG asset — 둘레만 김 + 양끝 단면)**. 둘레 김 + 양끝 open 단면 sprite.
- S1~S5 (말리는 중)는 단면(spiral) sprite 쓰지 않음 — 김 바깥면만(아직 통 아님). 양끝 단면은 S6 완성 통부터.

### 5.3 Slice (조리순서 7) — 매끈 통 → 조각

- Slice 진입 시 표시 = **`gimbap_roll_for_slice` (가로로 누운 통 — 둘레 매끈 검은 김 + 양끝 OPEN 단면)**.
- 통은 이미 양끝 단면이 보이지만(긴 통 양끝), 칼이 자르는 순간부터 **짧은 조각(piece) sprite 단면(spiral)으로 분리** — 통 양끝 단면 ≠ 조각 정면 단면(§4.2).
- roll_quality 나쁨 → piece_collapse(속 쏟아짐) / loose(filling 흘림). v2 §6.4 정합.

---

## 6. 재생성 대상 (art) + 무변경

| asset | 처리 | slot_mode |
|---|---|---|
| `roll_finished` | **양끝 OPEN 통 재생성** (둘레만 glossy 김 + 양끝 단면 보임, seam 1줄) | `open_log` |
| `roll_finished_loose` | **헐거운 양끝 OPEN 통 재생성** (우는 둘레 김, seam 살짝 뜸, 양끝 단면 살짝 벌어짐) | `open_log` |
| `roll_finished_burst` | **과압축 갈라진 통 재생성** (둘레 김 split + 밥 삐져나옴 + 양끝 OPEN 으깨진 단면) | `open_log` |
| `gimbap_roll_for_slice` | **썰기 전 누운 통 재생성** (둘레 glossy 김 + 양끝 OPEN 단면) | `open_log` |
| `rice_painterly` | **얇게 재생성** (thin ~5mm even spread, 밥알 보임, 두꺼운 slab 아님) | `ha` |
| `gimbap_piece_good` / `gimbap_piece_collapse` | **무변경** (썰린 조각 = 정면 단면 OK) | `ha` |
| roll s1~s5 (flat/edge/fold/curling/compression) | **무변경** (말리는 중 = 단면 없음, NO_CROSS_SECTION 유지) | `roll` |

---

## 7. 변경 이력
- **2026-06-13 v1** — 김밥집 사장 영상 ground truth LOCK. 7-step 기법(세로김/밥압착/재료한다발/far맨김봉합/near덮기/굴려다지기/완성통/썰기), 재료 한 다발+margin 배치, near덮기→굴리기→다지기 마는법. driver `slot_mode` 신설로 완성 4-asset(roll_finished/loose/burst/roll_for_slice) 강제. piece/roll-s1~s5 무변경. Godot Build(다발+margin)/Roll(덮기+다지기 beat)/Slice 가이드.
- **2026-06-13 v1.1 (양끝 OPEN 교정)** — 과교정 수정. 사용자 교정 "김밥 양쪽 끝은 틔어있어야지, 왜 김으로 막혀있나." 완성 통을 닫힌 캡슐로 그린 게 틀림. **완성 통 = 둘레(긴 곡면)만 매끈 검은 김 + 양쪽 끝 OPEN 단면(밥 ring + 색색 속 cluster) 보임 = open-ended log.** `slot_mode="closed"`(SMOOTH_CLOSED_LOG) → **`slot_mode="open_log"`(OPEN_END_LOG)** 로 교체, 완성 4-asset 전부. 말리는 *중간* state(roll s1~s5)는 아직 통 아니므로 단면 없음 — 무변경. 썰린 조각 정면 단면 — 무변경. `rice_painterly` = 두꺼운 slab → **얇게(~5mm even spread, 밥알 보임)** 강제절 추가.
