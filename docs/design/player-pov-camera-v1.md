# Player-POV Camera Rule v1 — "내가 요리한다" 시점 LOCK

> 버전: **v1.0 (2026-06-10)** · 작성자: art-director
> Status: **ART/ORIENTATION LOCK (구현 가이드).** 모든 cooking module의 화면 구성 시점 규칙.
> 사용자 mandate (verbatim 요지): *"화면 하단 = 플레이어/손, 상단 = far side. '내가 요리한다'
> 느낌이어야 한다 (남이 요리하는 것을 관전하는 게 아니라). chef가 테이블 건너편에 있는 느낌이면
> 안 된다 — 그러면 flip/reposition."*
>
> 상위/관련:
> - [`../art/style-bible-v1.md`](../art/style-bible-v1.md) — warm cozy, cocoa outline, soft volumetric, top-left light (톤은 본 문서가 변경 안 함)
> - [`gimbap-vertical-slice-v1.md`](gimbap-vertical-slice-v1.md) — 김밥 5-stage (roll state 정합)
> - [`core-loop-minigame-framework-v1.md`](core-loop-minigame-framework-v1.md) — 5-stage module orientation
> - 코드 정합: [`roll_module.gd`](../../godot-project/scripts/cooking_modules/roll_module.gd) (two-finger, 하단 target) / [`slice_module.gd`](../../godot-project/scripts/cooking_modules/slice_module.gd) / 8 module 전부
> - asset driver: [`../../tools/gen_roll_stages.py`](../../tools/gen_roll_stages.py) (staged roll PHYSICAL curl + player-POV)

---

## 0. 한 줄 정의

> **모든 조리 화면은 "내가 직접 요리하는 1인칭 약간-위 3/4 시점"이다. 화면 하단 = 내 손·도구가
> 들어오는 곳(near), 화면 상단 = 도마/식탁/스토브의 far edge. 남이 요리하는 걸 관전하는 정면
> 마주보기 시점은 금지.**

이미 [`roll_module.gd`](../../godot-project/scripts/cooking_modules/roll_module.gd)의 two-finger
target이 화면 하단(`TOUCH_TARGET_Y = 1230.0`, 음식은 위쪽 `ROLL_HERO_Y = 760.0`)에 있어 본 규칙과
정합한다. 본 문서는 이 암묵 규칙을 **전 module 공통 LOCK**으로 명문화하고, gimbap roll의 물리적 curl
state를 추가한다.

---

## 1. Global Cooking Camera Rule (전 module 공통)

| 축 | 규칙 |
|----|------|
| **시점** | 1인칭 cook의 **약간 위에서 내려다보는 3/4** (gentle high-angle, 손이 닿는 거리). 정면 elevation 금지, 순수 top-down flat-lay 금지, "across the table 관전" 금지. |
| **near (하단)** | 화면 **하단 = 플레이어/손/도구 entry**. 손·칼 handle·양념병·spoon handle·팬 handle이 하단에서 진입. drag 시작점도 하단. |
| **far (상단)** | 화면 **상단 = far edge** of board/table/stove/tray. 손님 mini는 상단(멀리). |
| **action 방향** | 동작은 일반적으로 **near→far(하단→상단)** 또는 near edge에서 시작. (roll = 하단 edge가 위로 말려 올라감.) |
| **single hero** | asset은 standalone transparent. 손/UI는 Godot layer 합성 (art에 손 baked 금지). |

> **금지 시그널 (위반 = flip/reposition)**: chef가 화면 위쪽에서 이쪽을 마주보며 요리, 음식의 far
> edge가 화면 하단(뒤집힘), 도구 handle이 화면 상단에서 진입(남의 손처럼 보임), 정면 side-on
> elevation으로 깊이 없음.

---

## 2. Coordinate Rule (1080×1920 base, Y bottom→top 의미)

> 좌표 자체는 Godot Y-down(상단=0)이지만, **시각적 의미는 bottom→top**으로 읽는다. 화면을 세로 zone
> 으로 나눠 역할을 고정한다.

| zone | 화면 영역 (1920 height 기준) | 역할 |
|------|------------------------------|------|
| **NEAR (하단)** | 하단 **20~30%** (y ≈ 1340~1920) | action start / 손·도구 entry / drag start / two-finger target. 플레이어가 닿는 곳. |
| **MAIN (중앙)** | 중앙 **40~60%** (y ≈ 580~1340) | main food action — 음식 hero가 여기. 써는/말리는/끓는 대상. |
| **FAR (상단)** | 상단 **10~20%** (y ≈ 0~580) | far edge of board/table / tray / 손님 mini-reaction / 진행 메타 cue. 멀리. |

- **roll_module 정합**: 음식(`ROLL_HERO_Y 760`) = MAIN, two-finger target(`TOUCH_TARGET_Y 1230`) =
  NEAR, balance meter / progress(`1400~1466`) = NEAR 경계. ✔ 본 규칙과 일치.
- **권고**: 신규/리뷰 module은 손·도구 진입을 NEAR zone에, 음식 hero를 MAIN zone에 배치. 손님·tray는
  FAR zone.

---

## 3. Module Orientation 룰 (module별 near/far 배치)

> 각 module이 본 카메라 룰을 어떻게 구현하는가. **handle/도구는 하단(near), 동작 대상은 중앙(main),
> 멀리 있는 것(tray/far edge/손님)은 상단.**

| module | near (하단) | main (중앙) | far (상단) |
|--------|-------------|-------------|------------|
| **slice (칼질)** | 칼 **handle 하단/우**에서 진입, 도마 **근접 edge 하단**, drag 시작 하단 | blade가 중앙을 가로질러 재료를 가름, 재료 hero 중앙 | 도마 far edge / 잘린 조각 staging |
| **season (양념)** | 양념병 **하단-우에서 진입** (손이 든 듯) | particle이 **중앙으로 낙하**, 그릇/음식 중앙 | 그릇 far rim |
| **stir (젓기)** | spoon/spatula **handle 하단**에서 진입 | 원 motion이 **bowl 안 중앙** | bowl far rim |
| **flip (뒤집기)** | 팬 **handle 하단**에서 진입 | food가 **중앙에서 위로 flip** (near→far arc) | flip 정점 / 팬 far edge |
| **timing/heat (끓이기)** | 불 control(하단) / 손잡이 하단, **flame 아래** | pot/뚝배기 **중앙 stove**, 끓는 국물·거품·steam | stove far edge / steam가 위로 |
| **plate (담기)** | 조각이 **하단 staging에서 출발**, drag 하단 시작 | vessel(tray/접시) **중앙**, 조각을 중앙으로 옮김 | 완성 dish far / 손님 mini |
| **arrange (배치)** | strip을 **하단 tray에서 집어** drag | rice **중앙 lower-third에 수평 band** 배치 | 김 far edge(seal) |
| **roll (말기)** | **bottom edge = 플레이어 근접**, two-finger target 하단, 손이 미는 곳 | 김+밥+속 **중앙**, 말기 **bottom→top** 진행 | far edge(seal 부분) / 완성 cylinder가 위로 드러남 |

---

## 4. Gimbap Roll Visual State (state 1~7) — 물리적 curl LOCK

> 사용자 핵심: **현 roll 애니가 가짜다 — 이미지 stretch/scale만 한다. 물리적으로 말려야 한다.**
> 김/밥이 **bottom edge부터 cylinder로 curl**. staged sprite + Godot position/rotation 전환으로
> 구현 (mesh deform 대신). 각 state = curl 진행이 명확히 다른 sprite (단순 scale 금지).

### 4.1 7 state 정의 (asset id ↔ 시각 ↔ scoring)

| state | asset id (`res://art/sprites/roll/`) | 물리적 curl 시각 | scoring 대응 |
|-------|--------------------------------------|------------------|--------------|
| **1. flat_setup** | (composited) `seaweed_sheet_rect` + `rice_layer_flat_rect` + `*_strip_long` | 평평 layer (김↓밥↓속 가로 band). 아직 안 말림. | roll 시작 전 setup |
| **2. edge_lift** | `gimbap_roll_edge_lift` ⭐신규 | **하단(near) edge 살짝 들림** + 김 하단 edge 위로 굽음, fillings 여전히 다 보임 | `avg_p ≈ 0.0~0.2` |
| **3. first_fold** | `gimbap_roll_first_fold` ⭐신규 | 김/밥이 **filling 위로 wrap 시작**, strip 일부가 fold 아래로 사라짐, 접힌 edge가 **curved(flat 아님)** | `avg_p ≈ 0.2~0.45` |
| **4. cylinder_forming** | `gimbap_roll_cylinder_forming` ⭐신규 | **절반 이상 말린 열린 cylinder** — 둥근 seaweed 원통 + spiral 단면 보임, far edge 짧은 flap 남음 | `avg_p ≈ 0.45~0.8` (halfway 대체/보완) |
| **5a. compression — loose** | `gimbap_roll_compressed_loose` ⭐신규 | **느슨한 roll** — oval/열린 cylinder, 헐겁고 filling 살짝 보임 (약한 pressure) | `avg_p < loose_thresh` (loose) |
| **5b. compression — perfect** | `gimbap_roll_finished_content_only` (기존 재사용) | **tight clean cylinder** — 단단한 원통 + 깔끔한 spiral 단면 | `well_rolled` (score≥60, !burst, !crooked) |
| **5c. compression — tight(over)** | `gimbap_roll_compressed_tight` ⭐신규 | **강압 — rice 삐져나옴 / seaweed 갈라짐 / 납작** (과한 pressure) | `avg_p > burst_thresh` (burst) |
| **6. finished** | `gimbap_roll_finished_content_only` (5b와 동일) | 완성 cylinder (= perfect) | SUCCESS swap |
| **7. slice_preview** | `gimbap_roll_finished_content_only` + 옆 slice 조각 | 완성 cylinder + 잘린 단면 1조각 (cross-section) | Stage 4 slice 진입 |

> **perfect compressed = 기존 `gimbap_roll_finished_content_only` 재사용** (신규 생성 X). state 5는
> pressure(`avg_p`)에 따라 loose / perfect / tight 3분기 — roll_module의 burst/loose 임계와 정합.

### 4.2 신규 생성 asset (player-POV, bottom→top, 물리적 curl)

[`gen_roll_stages.py`](../../tools/gen_roll_stages.py)로 생성. **5장 신규** (+ base 보강 2장 옵션):

1. `gimbap_roll_edge_lift` (state 2)
2. `gimbap_roll_first_fold` (state 3)
3. `gimbap_roll_cylinder_forming` (state 4)
4. `gimbap_roll_compressed_loose` (state 5a)
5. `gimbap_roll_compressed_tight` (state 5c)

각 sprite 규칙:
- **물리적 curl 형태가 명확** — bottom edge가 위로 굽어 올라가며 점점 더 단단한 cylinder. 단순
  scale/stretch 절대 금지 (`PHYSICAL_CURL` 절로 강제).
- **player-POV**: 단면/seam이 보이는 3/4 약간 위 시점, bottom edge가 화면 앞쪽(`PLAYER_POV` 절).
- **standalone transparent**, Style Bible v1 (warm, cocoa #3A2A1E outline, soft volumetric,
  top-left light), 기존 roll 세트와 한 톤.

### 4.3 base 보강 (선택 — player-POV 부적합 시)

기존 `gimbap_roll_halfway` / `gimbap_roll_finished_content_only`는 **side-roll(좌→우)** 시점이라
bottom→top player-POV에 살짝 어긋난다. 검수 후 부적합 판단 시 `--regen-base`로:
- `gimbap_roll_halfway_pov` (halfway를 bottom→top player-POV로 — 신규 id, 안전)
- `gimbap_roll_finished_content_only` (player-POV 단면 정면 — **동일 id 덮어쓰기 주의**, 검수 후 결정)

> **검수 우선**: 먼저 staged 5장만 생성 → 기존 halfway/finished와 한 세트로 보이는지 확인 → 톤/시점
> 어긋나면 그때 `--regen-base`. 불필요한 재생성/비용 회피.

---

## 5. godot-dev 후속 (구현 가이드 — 본 문서는 art/orientation, 코드는 godot-dev)

> art-director 영역은 driver+prompt+docs까지. 아래는 godot-dev가 받을 구현 명세(참고).

### 5.1 ArtRegistry — roll stage key 추가
[`art_registry.gd`](../../godot-project/scripts/gameplay/art_registry.gd) `ROLL_KEYS`에 5 신규 staged
id 추가 (graceful fallback 유지 — 파일 미존재 시 `""` → procedural):
```
"gimbap_roll_edge_lift", "gimbap_roll_first_fold", "gimbap_roll_cylinder_forming",
"gimbap_roll_compressed_loose", "gimbap_roll_compressed_tight",
# (옵션) "gimbap_roll_halfway_pov"
```
`get_roll_asset(key)` 시그니처 무변경 (이미 `_ROLL_DIR + key + ".png"` 해석).

### 5.2 roll_module — staged swap (scale 가짜 → staged sprite 전환)
현 `_apply_roll_visual()`은 `_stage_group.scale`로 가로폭만 줄여 "말림"을 흉내(= 가짜). 이를
**staged sprite swap + position/rotation 전환**으로 교체:
- `avg_p` 구간별로 stage sprite를 cross-fade swap: `edge_lift(0~0.2) → first_fold(0.2~0.45) →
  cylinder_forming(0.45~0.8) → compression(0.8~)`.
- compression 단계에서 pressure 분기로 loose / finished(perfect) / tight 중 하나 표시 (기존
  `_finalize_roll` burst/loose/well_rolled 분기와 1:1 매핑).
- 각 sprite는 **near edge(하단)가 화면 앞쪽**이 되도록 배치. 말림 진행 시 sprite를 위(far)로 살짝
  올리고(`position.y -= roundness * …`), tilt는 회전으로 (crooked 표현). **mesh deform 불필요** —
  staged sprite가 곡률을 담당, Godot은 swap + 미세 position/rotation만.
- two-finger 입력·scoring 공식(40 balance / 25 pressure / 20 distance / 15 smooth) **무변경**. 본
  작업은 **시각 layer만** (가짜 scale → 진짜 staged curl). contract 무변경.

### 5.3 orientation 정합 (전 module)
§3 표대로 각 module의 도구 entry를 NEAR(하단), 음식 hero를 MAIN(중앙)에 배치. roll은 이미 정합
(target 하단, 음식 중앙). 신규/리뷰 시 §2 zone 표를 체크리스트로.

---

## 6. 변경 이력
- **2026-06-10 v1.0** — 초안. Global Cooking Camera Rule(§1) + Coordinate zone(§2: NEAR 하단
  20~30% / MAIN 중앙 40~60% / FAR 상단 10~20%) + 8 module orientation(§3) + Gimbap roll 7 state
  물리적 curl LOCK(§4: edge_lift/first_fold/cylinder_forming/compression loose·perfect·tight) +
  신규 staged asset 5장(+base 보강 2 옵션) + godot-dev 후속 staged-swap 가이드(§5). 핵심:
  **scale 가짜 금지 → 물리적 curl staged sprite, player-POV(하단=손/near, 상단=far), standalone
  transparent.** roll_module two-finger target 하단 배치와 이미 정합.
