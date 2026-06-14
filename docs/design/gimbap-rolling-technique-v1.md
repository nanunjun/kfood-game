# Gimbap Rolling Technique v1 — 실제 김밥집 영상 기반 LOCK (ground truth)

> 버전: **v1 (2026-06-13)** · 작성자: art-director
> Status: **GROUND TRUTH LOCK.** 사용자가 김밥집 사장 영상 프레임을 직접 확인하고 잡아낸 실제 기법.
> 모든 Gimbap art asset(roll/build/slice)·Godot 구현(Build/Roll/Slice)이 이 문서를 따른다.
>
> 관련:
> - [`gimbap-vertical-slice-v2.md`](gimbap-vertical-slice-v2.md) — 5-stage UX 설계 (이 문서가 §4 Build / §5 Roll / §7 Slice 의 *물리적 ground truth* 를 보강)
> - [`gimbap-visual-quality-rebuild-v1.md`](gimbap-visual-quality-rebuild-v1.md) — painterly 재생성 계획 (단면금지 원리)
> - 생성 driver: [`tools/gen_gimbap_painterly.py`](../../tools/gen_gimbap_painterly.py) — `slot_mode="closed"` 가 이 문서를 강제

---

## 0. 왜 이 문서가 생겼나 (정직 — 내가 계속 틀린 것)

art-director 가 **완성 김밥(roll_finished / slice 직전 roll)을 단면(spiral end-cap)이 보이게** 반복해서 그렸다.
**이것은 틀렸다.** 사용자가 실제 김밥집 사장 영상을 프레임 단위로 확인한 결과:

> **완성된 김밥의 겉모습 = 매끈하고 반들반들한 검은 김 원통(닫힌 통).**
> 겉에 보이는 것은 **김 표면 하나 + 봉합 seam 한 줄**뿐.
> **단면(spiral / 밥 ring / 속 ring)은 "썰었을 때"의 조각(piece)에만 노출된다.**

완성 roll 을 단면 보이게 그리면 그건 "이미 썰린 김밥을 정면에서 본 것"이지 완성 통이 아니다. **LOCK.**

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
7. 매끈 검은 통        완성 = 매끈한 반들반들 검은 김 원통 (단면 안 보임)
                     → 썰 때만 단면(spiral) 노출
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
| **7. 매끈 통** | — | **매끈 반들 검은 통, seam 1줄, 단면 0** |

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
매끈한 검은 통 완성 (단면 0)
```

- 마는 방향 = **near(하단) → far(상단)**, 즉 bottom→top (좌→우 side-roll 아님 — player-POV LOCK).
- **다지기(press) = 별도 동작.** 굴리기만으로 끝 아님 — 김발로 눌러 다져야 단단한 통. (게임 beat 후보)
- 너무 약하게 다짐 = loose(헐거운 통, seam 살짝 뜸). 너무 세게 = burst(김 갈라지고 밥 삐져나옴).

---

## 4. 완성 시각 룰 (가장 중요한 교정) — LOCK

> **완성 김밥 겉모습 = 매끈한 반들반들 검은 김 원통. 단면 금지. 단면은 썰기만.**

| 상태 | 겉모습 | 단면 노출? |
|---|---|---|
| **완성 통 (roll_finished)** | 매끈 반들 검은 김 원통, **seam 1줄**, sesame-oil sheen | **금지** |
| **헐거운 통 (loose)** | 약간 우는(slumped) 검은 통, seam 살짝 뜸 | **금지** |
| **터진 통 (burst)** | 김 top 갈라지고 밥 삐져나옴, 납작 변형 | **금지** (단면 노출 아님 — top split) |
| **썰기 전 통 (roll_for_slice)** | 가로로 누운 매끈 검은 통, seam 1줄 | **금지** |
| **썰린 조각 (piece_good/collapse)** | **여기서만** spiral 단면(김 ring + 밥 ring + 속) | **노출 OK** (썰기 결과라 맞음) |

### 4.1 prompt 강제절 (driver `slot_mode="closed"` = SMOOTH_CLOSED_LOG)

> 완성 4-asset 에 부착. (`tools/gen_gimbap_painterly.py` 의 `SMOOTH_CLOSED_LOG` 상수와 동일)

```
smooth glossy dark seaweed (nori) cylinder, a CLOSED log,
ONLY the outer seaweed skin + a single faint seam visible,
the round CUT END is NOT facing the camera,
NO spiral cross-section, NO ring of rice, NO ring of filling, NO pinwheel —
that appears ONLY when the roll is sliced.
the ends point left/right (off to the sides), not toward the viewer.
```

### 4.2 단면 OK 유지 (무변경)

- `gimbap_piece_good` / `gimbap_piece_collapse` = **썰린 조각**이므로 spiral 단면 노출이 **맞다. 무변경.**

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
- **S6 완성 = 매끈 검은 통(SMOOTH_CLOSED_LOG asset)**. 단면 swap 금지 — 완성도 닫힌 통.
- S1~S6 어디서도 단면(spiral) sprite 쓰지 않음. 단면은 Slice piece 에만.

### 5.3 Slice (조리순서 7) — 매끈 통 → 조각

- Slice 진입 시 표시 = **`gimbap_roll_for_slice` (매끈 검은 누운 통, 단면 0)**.
- 칼이 통을 자르는 순간부터 **조각(piece) sprite 에서 단면(spiral) 노출** — 그 전까진 닫힌 통.
- roll_quality 나쁨 → piece_collapse(속 쏟아짐) / loose(filling 흘림). v2 §6.4 정합.

---

## 6. 재생성 대상 (art) + 무변경

| asset | 처리 | slot_mode |
|---|---|---|
| `roll_finished` | **매끈 검은 통 재생성** (단면 0, seam 1줄) | `closed` |
| `roll_finished_loose` | **헐거운 매끈 통 재생성** (살짝 우는 표면, seam 살짝 뜸, 단면 0) | `closed` |
| `roll_finished_burst` | **과압축 갈라진 통 재생성** (김 split + 밥 삐져나옴, 단면 아님) | `closed` |
| `gimbap_roll_for_slice` | **썰기 전 누운 매끈 통 재생성** (단면 0) | `closed` |
| `gimbap_piece_good` / `gimbap_piece_collapse` | **무변경** (썰린 조각 = 단면 OK) | `ha` |
| roll s1~s5 (flat/edge/fold/curling/compression) | **무변경** (말리는 중, NO_CROSS_SECTION 유지) | `roll` |

---

## 7. 변경 이력
- **2026-06-13 v1** — 김밥집 사장 영상 ground truth LOCK. 7-step 기법(세로김/밥압착/재료한다발/far맨김봉합/near덮기/굴려다지기/매끈검은통/썰때만단면), 재료 한 다발+margin 배치, near덮기→굴리기→다지기 마는법, **완성=매끈 검은 통(단면 금지)·단면은 썰기만** lock. driver `slot_mode="closed"` (SMOOTH_CLOSED_LOG) 신설로 roll_finished/loose/burst/roll_for_slice 4-asset 강제. piece/roll-s1~s5 무변경. Godot Build(다발+margin)/Roll(덮기+다지기 beat)/Slice(매끈통→조각) 가이드.
