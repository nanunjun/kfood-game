# Gimbap Visual Quality Rebuild v1 — Plan (PLAN ONLY, NO CODE / NO GEN)

> 버전: **v1.0 (2026-06-12)** · 작성: art-director
> Status: **PLAN ONLY — NO IMPLEMENTATION, NO ASSET GENERATION. 사용자 명시: "Do not implement until this plan is approved."**
> 범위: **김밥(t1_004) 1종만.** 다른 dish / feature / system 0.
> 상위 정합: [`docs/art/style-north-star-v1.md`](../art/style-north-star-v1.md) (warm 한식 / soft painterly casual / volumetric / NOT flat vector)
> 관련 (read 후 reconcile): [`gimbap-vertical-slice-v2.md`](gimbap-vertical-slice-v2.md) (stage 구조 — 무변경), `player-pov-camera-v1.md` (하단=near LOCK)

---

## 0. TL;DR — 무엇을 결정하나

현 Gimbap **flow(조리 순서: Shopping → Prep → Build → Roll → Slice → Plate → Guest)는 맞다.** 거부된 것은 **gameplay 화면의 시각 품질** — 모든 조리 stage가 **procedural vector geometry**(직사각/캡슐/원/점선)로 그려져 "polished cooking game"이 아니라 "vector placeholder prototype"으로 보인다.

이 계획서의 한 줄 결정:
> **각 조리 state를 `high-angle painterly game-art`(위에서 ~70-80°로 내려다본 부드러운 채색 sprite)로 재생성한다.** procedural vector도 아니고, 거부된 3/4 oblique도 아닌 **제3의 길**. (§3 해소안 참조)

**구현/생성은 본 계획 승인 후 별도 실행.** 본 문서는 거부 사유 + asset list + prompt 방향까지만.

---

## 1. 섹션 1 — 거부 사유 (왜 현 화면이 거부됐나)

> 사용자 평가: "flow는 맞는 방향이나 gameplay 화면이 **vector placeholder**처럼 보임, polished cooking game 아님."

직전 단계에서 godot-dev가 "strict top-down"을 달성하려고 **AI painterly sprite를 procedural geometry로 교체**했다(roll/slice/julienne/plate). 그 결과 top-down은 맞았지만 **시각이 flat vector placeholder**가 됐다. stage별 구체:

| Stage | 현재 시각 (거부 대상) | 왜 placeholder로 보이나 |
|-------|----------------------|------------------------|
| **Julienne** (`julienne_module.gd`) | `Panel`(StyleBoxFlat) 평면 도마 + clip된 `carrot_whole` texture + `Polygon2D` 칼 + 점선 dash `Panel` guide + `ColorRect`/scale된 strip | 도마=단색 둥근 사각, 칼=flat 다각형, strip=얇은 색 막대. volume·texture·contact shadow 없음. "당근 채썰기"는 읽히나 손맛 없는 도식 |
| **Build** (`gimbap_build_module.gd`) | `Panel` mat + `TextureRect` 김/밥 + 긴 strip sprite를 lower-third에 drag | 김=어두운 직사각, 밥=흰 직사각(rice로 안 읽힘), filling=얇은 vector line band. 두께·재료 인식 약함 |
| **Roll** (`roll_module.gd` `_TopDownRollStage`) | custom `_draw`: `draw_rect` mat + `draw_colored_polygon`/`draw_circle` capsule cylinder + `draw_line` strip 4줄 | mat=색칠한 사각 + 가로 선, cylinder=2색 캡슐, 속=4개 색 띠. "김밥"이 아니라 "도형으로 흉내낸 원통" |
| **Slice** (`gimbap_slice_module.gd`) | procedural 가로 capsule roll(`_GimbapTopDownRoll`) + `Polygon2D` 칼 + 점선 guide + 분리 조각 | roll에 volume/texture/shadow 부족. cut guide=점선 vector. bad roll 실패가 텍스트 hint로만 ("filling falling out") — 시각으로 안 쏟아짐 |
| **Plating** (`plate_module.gd` `_start_vs_plating`) | procedural tray(box corner) + 조각을 row target에 drag | tray=둥근 사각 box. 조각이 rice+seaweed+colorful filling로 appetizing하게 안 읽힘. broken piece가 filling 안 쏟음 |
| **Chef Select** (`gender_select.gd`) | 2 카드 "Female Chef / Male Chef" 이분법 | 성별 이분법 label, preset 다양성 0 (§9 별도) |

**근본 원인 한 줄**: top-down을 procedural geometry로 강제 → flat vector. 반대로 기존 AI sprite(`gimbap_roll_*`)는 painterly지만 **3/4 oblique + 단면 baked**라 "비스듬/조기노출"로 거부됨. **둘 다 실패.** (§3이 이 긴장을 푼다.)

---

## 2. 섹션 2 — 단계별 required visual states

> 각 state = high-angle painterly로 재생성될 목표 화면. (생성은 승인 후.) 모든 state는 §3 해소안(top-down + painterly)을 따른다.

### 2.1 Julienne (당근 채썰기) — 6 state

| state | 내용 (당근 명확 — 소시지/rectangle/debris 금지) |
|-------|----------------------------------------------|
| `whole_carrot` | 통 당근 1개 (끝이 가늘어지는 taper + 녹색 꼭지), 위에서 본 painterly, volume + 주황 highlight |
| `carrot_section_on_board` | 도마 위에 가로로 눕힌 당근 (나무결 도마 painterly, 당근 그림자 정하향) |
| `guide_lines` | 당근 위 6개 cut guide (도식 점선 아님 — 부드러운 안내 mark, painterly board 위 light groove) |
| `slicing_in_progress` | 칼날이 당근을 막 자르는 순간 (윤기 있는 식칼 + 잘린 단면 살짝 벌어짐 + juice highlight) |
| `clean_julienne_good` | 얇고 균일한 당근 채 더미 (matchstick, 같은 두께, 가지런, 윤기) |
| `uneven_julienne_bad` | 두께 제각각 chunky 당근 채 (덩어리 섞임, 기울어진 더미 — bad 결과 시각) |

### 2.2 Build (김밥 조립) — 재료가 real food로 읽혀야

| 요소 | 사양 |
|------|------|
| **bamboo mat** | warm detailed 김발 (나무 bamboo 결, 끈 매듭, 따뜻한 oak/walnut 톤). twist/대각 금지 — 평평 직사각 |
| **seaweed (김)** | dark green-black textured 김 (단순 검정 직사각 아님 — 미세 김 질감 + 가장자리 광택) |
| **rice (밥)** | 얇지만 **rice로 보이는** 밥 (흰 rectangle 아님 — 낟알 texture, soft 광택, 김 위 균등 펴짐, far edge seal margin) |
| **filling** | 두껍게 인식되는 속 (mat width의 **70-85%**, painterly volume + highlight, **vector line 금지**). carrot/egg/spinach/danmuji가 each real food (당근=주황 채, 계란=노랑 지단, 시금치=진녹 나물, 단무지=밝은 노랑) |

### 2.3 Roll (말기) — 6 state (top-down + painterly, 물리적 curl)

> 이전 실패: 3/4 oblique sprite + 단면(end-cap) 조기노출. 교정: **high-angle painterly**, 단면은 finished/slice에서만, **bottom edge → top** curl. scale로 흉내내지 말고 실제 fold.

| # | state | 내용 |
|---|-------|------|
| 1 | `flat_setup` | 평평한 김+밥+속 (위에서 본 painterly, 속 가로 평행, near edge=하단) |
| 2 | `bottom_edge_lift` | 하단(near) edge가 막 들려 올라가기 시작 (mat이 손에 들려 fold 개시) |
| 3 | `first_fold` | near edge가 속 위로 한 번 접힘 (말리기 시작, 단면 아직 안 보임) |
| 4 | `curling_half` | 절반쯤 말린 상태 (위쪽에 두꺼워지는 roll body + 아래 아직 안 말린 평평 부분, **단면 노출 0**) |
| 5 | `compression` | 거의 다 말고 양손으로 단단히 누르는 중 (tight cylinder 형성, 표면 김 광택) |
| 6 | `finished` | 완성 — **어두운 김 바깥 + seam(이음선) + round 수평 log**. 검은 단색 log 금지(김 질감+oil sheen), 완성 조기노출 금지(1~5에선 안 나옴) |

### 2.4 Slice (통썰기)

| 요소 | 사양 |
|------|------|
| knife | polished 식칼 (날 광택 + 나무 손잡이, vector 다각형 아님) |
| roll | volume + texture + shadow 있는 완성 roll (top-down 수평 log, 김 sheen, 정하향 그림자) |
| cut guide | subtle cut guide (도식 점선 아님 — 부드러운 절단 안내) |
| cut result | 조각 분리 — 잘린 단면(spiral 김+밥+컬러 속 5종 보이는 cross-section), 균일 조각 |
| **bad roll fail** | bad roll 시 **filling이 실제로 쏟아짐(시각)** — 헐겁게 말린 조각이 무너지며 당근/계란/시금치 속이 단면 밖으로 흘러나옴. **텍스트 아님** |

### 2.5 Plating (담기)

| 요소 | 사양 |
|------|------|
| tray/plate | real tray 또는 plate (box corner 금지 — 나무 도시락/접시 painterly, warm) |
| 조각 | rice+seaweed+colorful filling이 보이는 appetizing 조각 (단면 컬러풀, 윤기) |
| arrangement | tray에 정렬 (row / arc / 도시락 칸) |
| broken fail | broken piece가 **filling 쏟음(시각)** — 무너진 조각에서 속 흘러나옴 |

---

## 3. 섹션 3 (핵심) — top-down ↔ painterly 긴장 해소안

> **이게 본 계획서가 반드시 풀어야 할 핵심.** 정직하게.

### 3.1 긴장의 정체

| 접근 | 장점 | 거부 사유 |
|------|------|----------|
| **A. procedural vector geometry** (현재) | strict top-down 보장 (Godot transform으로 완전 제어) | **flat vector placeholder** = 지금 거부 |
| **B. AI painterly sprite (3/4 oblique baked)** (이전) | painterly, appetizing | **비스듬(oblique)** + 완성 단면 baked = 이전 거부 |

→ A는 top-down이지만 안 예쁘고, B는 예쁘지만 비스듬. **둘 다 실패.**

### 3.2 해소안 — high-angle painterly 재생성 (제3의 길)

> **각 state를 `high-angle (~70-80°) painterly game-art`로 재생성.** 진짜 직각 top-down(90°)도 아니고 3/4 oblique(45-55°)도 아닌, **위에서 거의 내려다본 부드러운 채색**.

핵심 원리 5가지:

1. **카메라 각도 = 70-80° (near top-down)**: 도마/김밥을 거의 위에서 본다. 살짝의 각도로 volume(두께·둥근맛)이 살되, oblique처럼 "옆에서 비스듬히"는 아님. → "위에서 본" + "납작한 도형 아님" 동시 충족.
2. **단면(end-cap) 노출 통제**: Roll의 state 1~5는 단면 0 (말리는 중엔 spiral 안 보임). 단면은 **finished + Slice + Plate에서만**. baked 단면 조기노출이 거부 원인이었으므로 state별로 분리 생성.
3. **player-POV LOCK 유지**: 하단=near(플레이어), 상단=far. Roll은 하단 edge부터 위로 fold. mat 회전/twist 금지. high-angle이어도 이 POV 규칙은 동일.
4. **painterly 품질**: soft volumetric shading (2-3단 gradient), subtle highlight 1-2점, contact shadow(정하향), warm 팔레트(north star). flat fill / vector line / box corner 금지.
5. **state = sprite sequence**: 각 stage의 진행을 **여러 장의 painterly state sprite**로 만들고, Godot가 cross-fade/swap으로 전환 (procedural _draw 대체). 입력·scoring 로직은 그대로, 시각 layer만 sprite로 교체.

### 3.3 왜 이게 작동하나

- **top-down 만족**: 70-80° = 위에서 본 화면. "비스듬히 누운 김밥" 거부와 다름 (oblique는 45-55°).
- **painterly 만족**: AI가 채색한 volume/texture/highlight → vector placeholder 탈출.
- **단면 조기노출 해소**: state를 쪼개 생성하므로 finished 전엔 단면이 baked되지 않음.
- **Godot 제어 유지**: 진행은 state sprite swap + 약간의 transform(위치/alpha). strict geometry 강제가 아니라 **미리 그린 painterly state를 순서대로 보여줌** → flat 안 됨 + top-down 유지.

> 한 줄: **"procedural을 high-angle painterly state sprite로 교체한다. 70-80° 각도가 top-down(위에서 봄)과 painterly(두께·질감 있음)를 동시에 만족시키고, state를 쪼개 생성하므로 단면 조기노출도 없다."**

---

## 4. 섹션 4 — 현 vector placeholder audit (어느 게 procedural)

> godot-dev가 procedural로 만든 정확한 지점. 재생성 대상 식별용.

| 모듈 / 노드 | 코드 위치 | procedural 형태 |
|------------|----------|----------------|
| Julienne 도마 | `julienne_module.gd` `_build_topdown_board` | `Panel`+`StyleBoxFlat`(둥근 사각) + `ColorRect` 나무결 |
| Julienne 칼 | `julienne_module.gd` `_build_topdown_knife` | `Node2D` + 5개 `Polygon2D`(handle/bolster/blade/shine/shadow) |
| Julienne guide | `julienne_module.gd` `_make_dashed_guide` | `Panel` dash 반복 (점선) |
| Julienne strip | `julienne_module.gd` `_spawn_strip` | `ColorRect` 또는 scale된 strip texture |
| Build mat/김/밥 | `gimbap_build_module.gd` `_build_mat`/`_build_seaweed_rice` | `Panel`/`TextureRect`(직사각) |
| Build filling | `gimbap_build_module.gd` strip = 긴 sprite | 얇은 band (vector line처럼 읽힘) |
| **Roll 전체** | `roll_module.gd` class `_TopDownRollStage._draw` | custom `_draw`: `draw_rect` mat / `draw_colored_polygon`+`draw_circle` capsule cylinder / `draw_line` strip / `_capsule()` 헬퍼 |
| Roll two-finger UI | `roll_module.gd` `_TouchTargetDraw`/`_BalanceMeterDraw` | custom `_draw` 원/화살표/막대 (UI라 유지 가능) |
| **Slice roll** | `gimbap_slice_module.gd` `_build_roll` (`_GimbapTopDownRoll` procedural capsule) | custom `_draw` 가로 capsule |
| Slice 칼 | `gimbap_slice_module.gd` `_build_knife` | `Node2D`+`Polygon2D` |
| Slice guide | `gimbap_slice_module.gd` `_build_guides` | 점선 vector |
| **Plate tray** | `plate_module.gd` `_start_vs_plating` | procedural `Panel` tray (box corner) + 조각 drag |

**유지 가능 (UI 성격 — 재생성 불요)**: two-finger target 원/화살표, balance meter, rhythm track marker, progress bar, hint label, Done 버튼. 이들은 게임 UI(HUD)지 음식 비주얼이 아니라 vector여도 무방.

**재생성 대상 = 음식·도구·표면 비주얼** (위 표의 굵은 항목 + 도마/mat/김/밥/filling/당근/칼).

---

## 5. 섹션 5 — game-art 재생성 대상 (procedural → painterly sprite)

> §4 procedural 중 **음식/도구/표면**을 high-angle painterly sprite로 교체. 입력·scoring·node lifecycle 무변경, 시각 layer만 swap.

| 카테고리 | procedural (현재) | 재생성 → painterly sprite |
|---------|------------------|--------------------------|
| 도마 (Julienne/Slice 공용) | `Panel` 둥근 사각 + `ColorRect` 결 | `board_topdown` painterly 나무 도마 (high-angle, 결+contact shadow) |
| 식칼 (Julienne/Slice 공용) | `Polygon2D` 다각형 칼 | `knife_topdown` painterly 식칼 (날 광택 + 나무 handle) |
| 당근 (Julienne) | clip된 `carrot_whole` + scale strip | `carrot_whole_topdown` / `carrot_julienne_good` / `carrot_julienne_bad` |
| 김발 mat (Build/Roll) | `Panel`/`draw_rect` | `bamboo_mat_topdown` painterly (결+끈, warm) |
| 김 (Build/Roll) | 직사각 | `seaweed_topdown` painterly (질감+광택) |
| 밥 (Build/Roll) | 흰 직사각 | `rice_layer_topdown` painterly (낟알 질감) |
| filling 4종 (Build/Roll) | 색 band | `filling_carrot/egg/spinach/danmuji_topdown` painterly strip |
| Roll cylinder (Roll/Slice) | capsule `draw_*` | roll **6 state** painterly (§6) |
| Slice 단면 조각 | capsule 조각 | `gimbap_piece_cutside` painterly cross-section (good + collapsed) |
| Tray (Plate) | `Panel` box | `tray_topdown` painterly 도시락/접시 (§8) |

---

## 6. 섹션 6 — Roll staged sprite plan (top-down + painterly 6 state)

> 이전 실패: 3/4 oblique + 단면 조기노출. 교정: high-angle painterly, 단면은 finished/slice만, bottom→top curl.

### 6.1 6 state sprite (각각 별도 생성 — 단면 통제)

| # | sprite key | 시각 | 단면 |
|---|-----------|------|------|
| 1 | `roll_s1_flat_setup` | 평평 김+밥+속 (가로 평행), high-angle, near=하단 | 0 |
| 2 | `roll_s2_bottom_lift` | near edge 들림 시작 | 0 |
| 3 | `roll_s3_first_fold` | near edge 속 위로 1회 접힘 | 0 |
| 4 | `roll_s4_curling_half` | 절반 말림 (위 roll body + 아래 평평) | 0 |
| 5 | `roll_s5_compression` | 거의 완성, 양손 압축 tight | 0 |
| 6 | `roll_s6_finished` | 완성 수평 log (어두운 김 + seam + round) | 끝 상태만 (단면 아님 — 외피만) |

### 6.2 결과 분기 (state 6의 variant)

| 결과 | sprite |
|------|--------|
| well-rolled | `roll_s6_finished` (tight round) |
| loose | `roll_s6_finished_loose` (헐거운 외피, 살짝 벌어진 seam) |
| burst/tight | `roll_s6_finished_burst` (rice 삐져나옴) |

### 6.3 Godot 전환 (구현 시 — 승인 후)

- roll progress(roundness 0~1)를 6 state로 매핑 (0~0.2→s1, 0.2~0.4→s2, ...). cross-fade swap.
- tilt(좌우 비대칭)은 sprite를 살짝 회전/offset (crooked 표현) — 단 base sprite는 top-down 유지.
- `_TopDownRollStage._draw` procedural 제거, state sprite swap으로 교체. **입력(two-finger)·scoring(40/25/20/15)·consequence(§8.2/§8.3) 무변경.**

---

## 7. 섹션 7 — Slice failure 시각 plan (filling 쏟아짐을 시각으로)

> 현재: bad slice가 텍스트 hint("Some pieces are thicker")로만. 교정: **시각으로 쏟아짐**.

### 7.1 good vs bad slice 시각

| 결과 | 조각 시각 |
|------|----------|
| good (tight roll + 정확 cut) | `gimbap_piece_good` — 균일 단면, rice+seaweed+컬러 속 5종 또렷, round, 윤기 |
| bad (loose roll) | `gimbap_piece_collapse` — 조각이 무너지며 **당근/계란/시금치 속이 단면 밖으로 흘러나옴**, uneven 두께, seam 벌어짐 |

### 7.2 시각 연출 (구현 시)

- 조각 분리 후 collapse variant면: 속 sprite(filling fall-out)가 조각 아래로 살짝 흘러내리는 위치 + 약한 tilt.
- roll_quality(§8.4)가 낮으면 collapse variant 사용 → "loose하게 말아서 썰 때 쏟아진다"는 인과를 **시각으로** 증명.
- 텍스트 hint는 보조로만 유지 (시각이 주).

---

## 8. 섹션 8 — Plating 재설계 plan (real tray, box corner 폐기)

> 현재: procedural `Panel` box tray. 교정: real tray painterly + appetizing 조각 + broken 시각.

### 8.1 tray painterly 생성

| sprite key | 시각 |
|-----------|------|
| `tray_wooden_topdown` | warm 나무 도시락/접시 (high-angle, box corner 아님 — 둥근 나무 결, 칸 또는 평면) |

### 8.2 배치 layout (택 1 — 구현 시 결정)

- **row**: 조각을 한 줄로 가지런히 (가장 단순)
- **arc**: 살짝 호 형태로 (appetizing display)
- **lunchbox**: 도시락 칸에 배치 (한식 정체성)

### 8.3 조각 + broken 시각

- 정렬 조각 = `gimbap_piece_good` (단면 컬러풀, 윤기).
- broken piece = `gimbap_piece_collapse` (filling 쏟음) — slice_quality(§8.5)가 낮으면 일부 조각이 broken variant로 tray에 놓임 → "잘 못 썰면 담을 때도 무너진다" 시각 인과.

---

## 9. 섹션 9 — F5 screenshot targets (11)

> 승인 후 구현 → F5로 이 11컷 캡처해 painterly 품질 검증.

| # | 컷 | 검증 |
|---|----|----|
| 1 | Chef select — preset 1 (Hana) | painterly avatar, 4 preset 중 1 |
| 2 | Chef select — preset 2 (Joon) | |
| 3 | Chef select — preset 3 (Min) | |
| 4 | Chef select — preset 4 (Ari) | 4 preset 다 보임 |
| 5 | Julienne — good (clean 채) | 얇고 균일 painterly 당근 채 |
| 6 | Julienne — bad (chunky) | uneven painterly 당근 채 |
| 7 | Build | painterly mat+김+밥+filling (real food) |
| 8 | Roll — 5 state | s1~s5 진행 (단면 0, painterly) |
| 9 | Slice — real | painterly roll + 단면 조각 |
| 10 | Bad slice — filling fall | 조각 collapse, 속 쏟아짐 (시각) |
| 11 | Plating — real tray | 나무 tray + appetizing 조각 |

> 컷 8(Roll 5 state)는 1장에 progression 합성 또는 5 sub-shot. 컷 1~4(chef 4 preset)는 chef select 한 화면에 4 카드.

---

## 10. 추가 — Chef Selection 재설계 (Issue 1)

> 현 `gender_select.gd` "Female Chef / Male Chef" 이분법 거부. → **"Choose Your Chef" + 4+ avatar preset (성별 카테고리 아닌 이름/성격)**.

### 10.1 4 preset (이름 + 성격)

| preset | 이름 | 성격 | base art (기존/신규) |
|--------|------|------|---------------------|
| 1 | **Chef Hana** | Calm & careful | 기존 `chef_f` (warm female-presenting) 재활용 |
| 2 | **Chef Joon** | Fast & bold | 기존 `chef_m` (warm male-presenting) 재활용 |
| 3 | **Chef Min** | Creative & balanced | **신규** androgynous neutral (생성 필요) |
| 4 | **Chef Ari** | Cheerful & curious | **신규** younger playful (생성 필요) |

- 최소 4: warm female-presenting / warm male-presenting / androgynous neutral / younger playful.
- 어색한 third-option label 금지 — 자연스러운 이름·성격으로 표현.
- 기존 2종(chef_f/chef_m) → 4 preset 확장. **신규 2종(Min, Ari) emotion set(neutral/cheer/think/cook = 4장 each = 8장) 생성 필요** (생성은 승인 후).
- 코드 영향(구현 시): `gender_select.gd` → 4 카드, `art_registry.gd` `PROTAGONIST_GENDERS`/`get_protagonist` 확장, `save_manager` chef key 확장 (gender → preset id). **본 계획은 명시만, 구현 X.**

### 10.2 north star 정합

신규 2종도 동일 시각 언어: cocoa #3A2A1E outline 3-4px / soft volumetric top-left light / warm palette / storybook 얼굴 / 텍스트 art 없음(i18n icon-first). 한하나 시그니처(분홍 꽃핀/세이지 앞치마/태극기 patch/자수) 복제 금지.

---

## 11. 생성 필요 asset 수 + 예상 비용

> ChatGPT (GPT-4o image / DALL-E 3) — ADR-006. Plus $20/월 plan. master prompt 템플릿 + reference upload(north star + 김밥 anchor)로 일관성 lock. **승인 후 생성.**

### 11.1 asset count

| 그룹 | asset | 수 |
|------|-------|---|
| Julienne | board_topdown, knife_topdown, carrot_whole, carrot_julienne_good, carrot_julienne_bad | 5 |
| Build | bamboo_mat, seaweed, rice_layer, filling × 4 (carrot/egg/spinach/danmuji) | 7 |
| Roll | 6 state + 2 결과 variant(loose/burst) | 8 |
| Slice | roll_finished(공유 가능), knife(공유), piece_good, piece_collapse | 2 (신규) |
| Plate | tray_wooden_topdown | 1 |
| Chef | 신규 2종(Min/Ari) × 4 emotion | 8 |
| **소계** | | **31** |
| 예비 (재롤/iteration buffer ~40%) | | ~12 |
| **총계 (예상)** | | **~43** |

> board/knife/roll_finished은 stage 간 공유 가능 → 실 생성 ~31, iteration 포함 ~43장.

### 11.2 예상 비용

- **ChatGPT Plus 월 $20 구독 내 생성** (DALL-E 3 / GPT-4o image는 Plus plan 포함). 31~43장은 대화형 세션 수 회로 충분 — **추가 종량 비용 0** (구독 범위 내).
- API 종량 경로(`tools/gen_image.py`) 사용 시: DALL-E 3 standard 1024² ≈ $0.04/장 → 43장 ≈ **$1.7** + iteration. **상한 ~$5 미만.**
- 결론: **구독 내 $0 추가 또는 API 경로 ~$2-5.** 비용은 제약 아님. 병목 = iteration 품질 검증(side-by-side 게이트).

### 11.3 생성 순서 (승인 후 권장)

1. board + knife + bamboo_mat + seaweed + rice (공유 표면/도구) → 5
2. Roll 6 state + 2 variant (가장 중요 — 핵심 거부 stage) → 8
3. filling 4 + carrot 3 (Julienne/Build food) → 7
4. piece_good + piece_collapse + tray → 3
5. chef 신규 2종 × 4 → 8

---

## 12. 제약 재확인 (LOCK)

- **구현 X / 생성 X** — 본 문서는 계획·asset list·prompt 방향까지. 승인 대기.
- **김밥 1종만** — 다른 dish/feature/system 0.
- **top-down ↔ painterly 해소 = §3** (high-angle 70-80° painterly state 재생성).
- **player-POV LOCK** — 하단=near, roll 하단 edge부터 위로, mat 회전 금지.
- **scoring/4-factor/save/economy/consequence contract 무변경** — 시각 layer만 swap.
- **north star 정합** — warm / soft painterly / volumetric / NOT flat vector / NOT box placeholder.
