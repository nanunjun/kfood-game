# Cooking Realism — Asset Audit + Roll Stage Standalone Assets

> 버전: **v1.0 (2026-06-07)** — art-director
> 상위 발견 (사용자): cooking step에서 (1) Plate가 "그릇 위에 그릇" broken, (2) Roll이 완성 김밥 hero를 처음부터 표시 → 실제 마는 과정 아님.
> 성격: **standalone asset 생성 + audit only** (gameplay 수정 X / baked composite X). 합성은 Godot runtime 책임.
> 참조: [`style-bible-v1.md`](style-bible-v1.md), [`asset-architecture-lock.md`](asset-architecture-lock.md), [`ingredient-tool-art-lock.md`](ingredient-tool-art-lock.md).

---

## 0. HARD RULE (LOCK)

| # | Rule | 이유 |
|---|------|------|
| **HR1** | **finished dish hero (premium_v2)는 cooking 초반 step(slice/roll/stir/flip/timing 등)에 사용 금지.** Plate module의 final preview 와 result/menu thumbnail 에만 허용. | 완성 그릇샷을 조리 중에 보여주면 "이미 다 됨" → action이 거짓이 됨. Roll bug 의 근본 원인. |
| **HR2** | **음식 content 와 vessel(그릇)을 분리한다.** finished dish hero는 그릇 포함(dish_with_vessel)인 경우가 많음 → 그릇 위에 vessel을 또 깔면 "그릇 위에 그릇". content-only asset 또는 fallback(vessel 생략)으로 처리. | Plate bug 의 근본 원인. 5-Layer Composition은 vessel(L2) + content(L3) 분리를 전제로 하는데 premium_v2가 둘을 baked함. |
| **HR3** | **모든 신규 asset은 standalone transparent (baked X).** 도마/쟁반/그릇/손/다른 재료와 함께 굽지 않음. | Asset Architecture Lock NEVER-merge mandate. |

---

## 1. Asset Audit Table — 6 dish (사용자 지정)

> 분류: `content_only` (그릇 없이 음식만) / `dish_with_vessel` (그릇·접시 포함) / `missing` / `placeholder`.
> 현 음식 art = `premium_v2/` 12장 (ArtRegistry.FOOD → res://art/sprites/food/{id}.png) + 백업 `food_anchors_m1/`.
> 판정 근거 = `tools/gen_premium_v2.py` 의 각 prompt Subject 절 ("in a ceramic bowl" / "on a plate" / "ttukbaegi pot" 등 = vessel baked).

| Dish | food_id | 현 분류 | 파일 경로 (현 art) | vessel(baked) | content_only 필요? |
|------|---------|--------|-------------------|--------------|--------------------|
| **Ramyeon (라면)** | `t1_002` | **dish_with_vessel** | `assets-raw/premium_v2/t1_002.png` → `res://art/sprites/food/t1_002.png` | ceramic bowl (양은냄비 톤) | **YES (P2)** — Plate vessel(noodle_bowl)과 중복 |
| **Gimbap (김밥)** | `t1_004` | **dish_with_vessel** | `assets-raw/premium_v2/t1_004.png` → `res://art/sprites/food/t1_004.png` | small plate (cut rounds arranged) | **YES (P0)** — Roll 과정엔 아예 부적합(완성 roll). content_only도 필요하지만 **roll 과정용 standalone(§2)이 더 시급** |
| **Tteokbokki (떡볶이)** | `t1_003` | **dish_with_vessel** | `assets-raw/premium_v2/t1_003.png` → `res://art/sprites/food/t1_003.png` | shallow ceramic dish | **YES (P3)** — Plate vessel(wide_plate)과 중복 |
| **Janchi Guksu (잔치국수)** | `t1_008` | **dish_with_vessel** | `assets-raw/premium_v2/t1_008.png` → `res://art/sprites/food/t1_008.png` | ceramic bowl + clear broth | **YES (P3)** — 국물 음식, content만 분리 까다로움(국물=그릇 의존). vessel fallback 우선 권장 |
| **Bibimbap (비빔밥)** | `t2_008` | **dish_with_vessel** | `assets-raw/premium_v2/t2_008.png` → `res://art/sprites/food/t2_008.png` | ceramic bowl (방사형 나물) | **YES (P1)** — Plate vessel(brass_bowl)과 가장 눈에 띄게 중복. **이번 생성 권고(plate fix 시연)** |
| **Kimchi Stew (김치찌개)** | (m1) | **missing / placeholder** | `assets-raw/food_anchors_m1/F-09_kimchi_jjigae_v1.png` (anchor only, premium_v2 미생성) | (anchor엔 뚝배기 포함 경향) | **YES (P3)** — premium_v2 정식 음식 12 목록에 김치찌개 없음(불고기 t2_014로 대체됨). m_kimchi_jjigae는 mode-extra. vessel(earthenware_bowl) fallback로 충분 |

### 1.1 판정 요약

- **6 dish 전부 `dish_with_vessel` 또는 `missing`** — content_only asset은 0개 보유.
- premium_v2 12장은 **모두 그릇/접시 baked** (prompt가 "in a ceramic bowl / on a plate / in a ttukbaegi pot" 명시). → 5-Layer Composition의 vessel(L2) + content(L3) 분리 전제와 충돌.
- **Kimchi Stew**: premium_v2 정식 12 목록에 없음(순두부 t2_013·불고기 t2_014가 그 슬롯). `food_anchors_m1`의 F-09가 유일한 anchor → placeholder.

### 1.2 5-Layer 결과 (왜 broken인가)

| Module | L2 vessel (ArtRegistry) | L3 content (현재) | 결과 |
|--------|------------------------|-------------------|------|
| **Plate** | `plate_vessel_for()` → brass_bowl/noodle_bowl/wide_plate 등 | `food(food_id)` = **dish_with_vessel** | **그릇(L2) 위에 그릇 포함 완성샷(L3)** = 그릇 2개 (HR2 위반) |
| **Roll** | `rolling_mat` (L2) | `food(food_id)` = **완성 김밥 roll** (L3) | 마는 과정 전부터 **완성 김밥**이 보임 → scale만 줄어듦 (HR1 위반) |

---

## 2. Roll Stage Standalone Assets (사용자 명시 7장)

> 실제 김밥 마는 과정용. **Style Bible v1 톤** (warm, cocoa #3A2A1E outline 3-4px, soft volumetric, top-left key light, 3/4 view), **transparent, baked X** (도마/김발/쟁반 함께 굽지 않음 — 합성은 Godot).
> 출력: `assets-raw/roll_assets_m2/{id}.png` → 배포 `res://art/sprites/roll/{id}.png`.
> driver: [`tools/gen_roll_assets.py`](../../tools/gen_roll_assets.py).

| # | asset id | 설명 | Style Bible note |
|---|----------|------|------------------|
| 1 | `seaweed_sheet` | 김 한 장 (검정-진녹 직사각, matte) | 광택 X (구운 김 matte 질감), 살짝 우글거리는 가장자리 |
| 2 | `rice_layer_flat` | 밥 평평 layer (흰밥 펴진 직사각) | 알알이 보이는 sticky rice, soft sheen, cream-white(#FAF4E6) |
| 3 | `gimbap_filling_strip_carrot` | 당근 채 strip 한 줄 (긴 줄) | 주황 julienne 한 줄로 정렬(roll 안에 깔리는 형태) |
| 4 | `gimbap_filling_strip_egg` | 계란 지단 strip 한 줄 | 노란 지단 한 줄(egg yolk #F5B731), 부드러운 두께 |
| 5 | `gimbap_filling_strip_green` | 시금치/오이 green strip 한 줄 | scallion green(#7FB04A), 한 줄 정렬 |
| 6 | `gimbap_roll_halfway` | 반쯤 말린 김밥 (말리는 중간) | 김이 한쪽은 말렸고 한쪽은 평평한 재료 노출 — 진행 중 형태 |
| 7 | `gimbap_roll_finished_content_only` | 완성 김밥 roll, 도마/쟁반 없이 content만 | **content_only** — 통 roll(아직 안 썬) 또는 살짝 썬 단면 1-2개, **그릇/도마/쟁반 없음** |

### 2.1 Roll 진행 매핑 (godot-dev 후속 참고)

```
drag progress 0.0 ──────────────────────────────────────── 1.0
[평평: seaweed_sheet + rice_layer_flat + 3 filling strips]
        ↓ (drag 진행)
   [gimbap_roll_halfway]  ← 0.4~0.7 구간 swap
        ↓
   [gimbap_roll_finished_content_only]  ← release 후 완성(score≥60)
```
- 초반(평평): `seaweed_sheet`(L2 깔개) 위에 `rice_layer_flat`(L3) + 3 strip(L3). → **HR1 준수** (완성 hero 아님).
- 진행 중: `gimbap_roll_halfway`로 swap (현 `_roll_hero` scale 트릭 대체 가능).
- 완성: `gimbap_roll_finished_content_only` (content_only이므로 도마/쟁반 위 합성 자유 — HR2 준수).
- 기존 `ArtRegistry.food("t1_004")`(완성+접시) 사용 **중단** → 위 standalone 시퀀스로 대체.

---

## 3. Needed content-only Asset List (우선순위)

> dish_with_vessel 음식 → content_only 필요. **이번엔 P0/P1만 생성**, 나머지는 list만 (Plate fix Option B = dish_with_vessel일 때 vessel 생략 fallback이 받쳐주므로 content_only는 점진).

| 우선 | asset id | dish | 이유 / 사용처 |
|------|----------|------|--------------|
| **P0** | (roll 7장 = §2) | Gimbap roll | Roll 과정 자체 — 즉시 필요. **이번 생성** |
| **P1** | `bibimbap_content_only` | 비빔밥 | Plate fix 시연 — 그릇 없는 나물+밥+계란 mound. brass_bowl(L2) 위에 자연스럽게 담김. **이번 생성** |
| P2 | `ramyeon_content_only` | 라면 | 면+국물+계란+파 (국물 음식이라 그릇 의존 큼 — 채택 시 broth는 약하게). list만 |
| P3 | `tteokbokki_content_only` | 떡볶이 | 떡+어묵+소스 mound (접시 없이). list만 |
| P3 | `janchi_guksu_content_only` | 잔치국수 | 면+고명 nest (국물 음식 — 그릇 의존). vessel fallback 우선. list만 |
| P3 | `kimchi_stew_content_only` | 김치찌개 | 미생성 placeholder — earthenware_bowl(L2) fallback로 충분. list만 |
| P4 | 나머지 8 dish content_only | (t1_005~t2_014) | Plate fix Option B fallback이 dish_with_vessel을 받침 → 점진 생성. list만 |

### 3.1 content_only 생성 규칙 (P2~ 생성 시 참고)

- **그릇/접시/뚝배기 절대 baked 금지** — 음식 내용물만 (rice mound / 나물 section / 면 nest / 떡 pile).
- 국물 음식(라면/잔치국수/찌개): 국물은 content에 약하게만, vessel(L2 dolsot/noodle_bowl)이 국물 그릇을 담당. content는 건더기(면/고명/두부) 위주.
- 비빔밥: 밥 mound 위 방사형 나물 + 중앙 계란 (그릇 형태 암시 X — 둥근 mound).

---

## 4. main thread 실행 명령

```powershell
# (A) Roll 7 asset — standalone transparent (P0, 이번 생성)
py tools/gen_roll_assets.py --background transparent

# (B) bibimbap content_only — Plate fix 시연용 (P1, 이번 생성)
py tools/gen_roll_assets.py --set content --only bibimbap_content_only --background transparent

# (A)+(B) 한 번에
py tools/gen_roll_assets.py --set all --background transparent

# 일부만 재생성 (예: halfway 마음에 안 들 때)
py tools/gen_roll_assets.py --only gimbap_roll_halfway --background transparent
```
- 비용: gpt-image-1 medium ($0.042/장). roll 7 + bibimbap 1 = 8장 ≈ **$0.34**.
- 출력: `assets-raw/roll_assets_m2/`. 검수 후 `assets-processed/` → `res://art/sprites/roll/` 배포(main thread / godot-dev).

---

## 5. godot-dev 후속 (이 audit 기준 구현)

> art-director 영역은 standalone asset + audit까지. 아래는 godot-dev 위임 사항 (gameplay 수정).

### 5.1 ArtRegistry — roll key + content_only fallback 추가

```gdscript
# (예시) roll 시퀀스 asset
const _ROLL_DIR := "res://art/sprites/roll/"
const ROLL_KEYS := [
    "seaweed_sheet", "rice_layer_flat",
    "gimbap_filling_strip_carrot", "gimbap_filling_strip_egg", "gimbap_filling_strip_green",
    "gimbap_roll_halfway", "gimbap_roll_finished_content_only",
]
static func get_roll_asset(name: String) -> String:
    var p := _ROLL_DIR + name + ".png"
    return p if ResourceLoader.exists(p) else ""

# content_only fallback (Plate/조리 step에서 finished hero 대신)
const _CONTENT_DIR := "res://art/sprites/food_content/"
static func food_content_only(food_id: StringName) -> String:
    var p := _CONTENT_DIR + String(food_id) + "_content.png"  # 또는 매핑 dict
    return p if ResourceLoader.exists(p) else ""  # 미존재 → "" (caller가 vessel-only fallback)
```

### 5.2 roll_module.gd — HR1 준수 (완성 hero swap 제거)

- `_roll_hero = ArtRegistry.food(food_id)` (완성 김밥) **제거**.
- 대체: `seaweed_sheet`(깔개) + `rice_layer_flat` + 3 `gimbap_filling_strip_*`를 평평하게 배치 → drag 진행 시 `gimbap_roll_halfway` swap → release 후 `gimbap_roll_finished_content_only`.
- `_build_fillings()`의 색블록/ingredient 토큰은 strip asset으로 교체 가능(있으면).

### 5.3 plate_module.gd — HR2 준수 (그릇 위 그릇 방지)

- L3 dish hero를 `food_content_only(food_id)` 우선 시도 → 있으면 vessel(L2) 위에 content만 (정상).
- **Option B fallback** (content_only 미존재 = dish_with_vessel만 있을 때): vessel(L2)를 **생략**하고 finished dish hero(이미 그릇 포함)만 단독 표시 → "그릇 위 그릇" 회피.
- 즉 `food_content_only()` 존재 ? (vessel + content) : (vessel 생략, dish_with_vessel 단독).

### 5.4 우선순위

1. **roll_module** (P0) — roll 7 asset 배포 후 즉시 (가장 broken).
2. **plate_module** Option B fallback (P1) — bibimbap_content_only 배포 후 비빔밥부터, 나머지는 vessel 생략 fallback.
3. content_only 점진 생성(P2~) 시 plate가 자동으로 content+vessel 경로 사용.

---

## 6. 변경 이력

- **2026-06-07 v1.0**: 6 dish audit (전부 dish_with_vessel/missing — content_only 0). Roll 7 standalone asset spec + driver(gen_roll_assets.py). content_only needed list(P0 roll / P1 bibimbap / P2~ list). HR1(완성 hero 초반 금지)·HR2(content·vessel 분리)·HR3(standalone) lock. godot-dev 후속(ArtRegistry get_roll_asset + food_content_only / roll·plate module fix) 명세.
</content>
</invoke>
