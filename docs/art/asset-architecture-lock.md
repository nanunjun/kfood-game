# Asset Architecture LOCK — 7-Layer Separation & NEVER-Merge Mandate

> 버전: **v2.0 (2026-06-06) — ASSET ARCHITECTURE LOCK (5→7 layer 확장)**
> 작성: art-director
> 상위 지시 (사용자 LOCK, verbatim §1): *"Ingredients and tools must NEVER be merged into a single production asset." / "If an asset cannot be reused independently, reject it."*
> 성격: **production architecture 규약** — gameplay/CSV/systems 미변경. 본 LOCK 은 art 산출물의 **레이어 분리 규칙**과 Godot **runtime composition** 계약을 박제한다.
> v2 변경: **Vessel/Cookware 를 Tool 에서 분리** (pot/dolsot/pan/bowl = 음식을 담는 용기 ≠ 손에 쥐는 도구), **Character 를 명시 layer 로 추가** → 총 **7 layer**. (Art Pipeline Correction `docs/art/art-pipeline-correction.md` D1/D2 정합.)
> 정합 reference: Style Bible v1 §1·§2·§5, `docs/art/ingredient-tool-art-lock.md` (Hero Asset Mandate — volumetric quality 규약), `docs/art/art-pipeline-correction.md` (8 deliverable), `tools/gen_ingredient_tool_hero.py` (compliant standalone driver).
> Supersede: `gen_cut_anchors_m1.py` / `gen_ingredient_anchors_m1.py` / `gen_ingredient_cut_anchors_m1.py` 의 **"도마+칼+재료 한 PNG에 baked" 방향** — 본 LOCK 으로 무효화 (= 위반 산출물, standalone 재생성 대상). `gen_tool_anchors_m1.py` 의 flat UI-icon tool = rework 대상.

---

## 1. 사용자 LOCKED Mandate (verbatim — 절대 규칙)

> **"Ingredients and tools must NEVER be merged into a single production asset.**
> **Bad: knife+onion PNG / cutting board+carrot PNG / pot+soup PNG / grill+galbi PNG.**
> **Correct: Ingredient Layer / Tool Layer / Environment Layer / Effect Layer / UI Layer — All separate.**
> **Ingredients generated independently (green_onion_whole / green_onion_chopped / carrot_whole / carrot_julienne / kimchi_whole / kimchi_chopped).**
> **Tools generated independently (knife / cutting_board / ladle / spatula / pot / dolsot / grill / tongs).**
> **Composition: Godot assembles at runtime. Never bake ingredients into tools. Never bake tools into ingredients.**
> **Hero Asset Rule: Ingredients are hero assets. Tools are hero assets. Generate standalone premium illustrations first. Composition comes later.**
> **Benefits: max reuse / easier animation / smaller workload / brand integrations / future expansion."**

---

## 2. 7-Layer Architecture (LOCKED)

모든 art 산출물은 **정확히 하나의 레이어**에 속한다. 레이어 간 베이킹 금지. Godot 가 런타임에 z-order 로 합성.

| # | Layer | 정의 | 산출물 (standalone PNG, transparent) | NEVER 포함 |
|---|-------|------|--------------------------------------|------------|
| 1 | **L-ING — Ingredient Layer** | 재료 standalone **hero**. whole / prepared(cut) / cooked variant 각각 독립 PNG | `green_onion_whole`, `green_onion_chopped`, `carrot_whole`, `carrot_julienne`, `carrot_diced`, `kimchi_whole`, `kimchi_cooked`, `garlic_minced`, `beef_sliced` … | 도마/칼/냄비/그릇/scene/손/캐릭터/다른 재료/baked shadow |
| 2 | **L-TOOL — Tool Layer** | **손에 쥐는** 도구 standalone **hero**. 각 도구 1개 독립 PNG | `chef_knife`, `cutting_board`, `ladle`, `spatula`, `tongs`, `rolling_mat` … | 재료/음식/scene/손/캐릭터/다른 도구 |
| 3 | **L-VES — Vessel/Cookware Layer** (v2 신규 분리) | 음식을 **담는/끓이는 용기** standalone **hero**. 빈 용기. | `pot`, `dolsot`, `frying_pan`, `grill_pan`, `mixing_bowl` … | 재료/국물/음식 baked (용기는 **빈 상태**, 내용물은 L-ING 별도 노드) |
| 4 | **L-ENV — Environment Layer** | 배경 L1~L5 (주방/식당/시장/푸드트럭 등 무대) | `env_l1_home_kitchen`, `env_l2_…` … (배경 plate only) | 전경 재료/도구/용기 baked (전경은 런타임 합성) |
| 5 | **L-FX — Effect Layer** | VFX. 재료/도구와 분리된 투명 오버레이 | `fx_steam`, `fx_sparkle`, `fx_glow_heat`, `fx_sizzle`, `fx_splash`, `fx_perfect_burst` … | 어떤 재료·도구·용기·음식도 baked 금지 (순수 alpha VFX) |
| 6 | **L-UI — UI Layer** | 카드/버튼/아이콘/패널/게이지 | `ui_card_frame`, `ui_btn_primary`, `ui_icon_timer`, `ui_gauge_doneness`, `ui_panel_result` … | hero 재료·도구 일러스트 baked 금지 (UI 안에 들어가는 재료 썸네일도 L-ING 원본을 런타임 배치) |
| 7 | **L-CHAR — Character Layer** | 캐릭터 bust/reaction. emotion variant 각각 독립 PNG | `junho_neutral`, `junho_excited`, `mina_happy` … | 음식/도구/scene baked, 다른 캐릭터, arm/hand 주변 dark artifact |

> **레이어 분류 1-rule**: "이 PNG 안에 **두 종류 이상의 layer 주체**(재료+도구, 도구+배경, 재료+용기, 재료+VFX 등)가 한 번에 그려져 있는가?" → YES 면 **위반**. 각각 쪼개서 standalone 재생성.
> **재사용 1-rule (사용자 verbatim)**: *"If an asset cannot be reused independently, reject it."* — 도마+칼에 baked 된 재료는 Mix/Stir/Roll 에서 board/tool 이 함께 회전 = 독립 재사용 불가 = reject.
> **Tool vs Vessel 구분 (v2)**: 손에 쥐고 재료를 다루는 것 = Tool (knife/ladle/spatula/tongs/board/mat). 음식을 담거나 끓이는 용기 = Vessel (pot/dolsot/pan/bowl). pot 에 soup 를 baked 하면 끓이기 module 에서 재료 raw→cooked swap 불가 → Vessel 은 **빈 용기 standalone**, 내용물은 L-ING 별도 노드.

---

## 3. NEVER-Merge 규칙 — 금지 베이킹 리스트 (= 즉시 REJECT)

> 아래 **co-asset 베이킹**이 한 PNG 안에 보이면 **production asset 부적합**. reroll/reskin 이 아니라 **레이어 분해 후 각각 standalone 재생성**.

### 3.1 Bad → Correct (사용자 명시)

| Bad (한 PNG에 baked — REJECT) | Correct (분리 standalone) |
|-------------------------------|---------------------------|
| `knife + onion` PNG | `chef_knife` (L-TOOL) + `green_onion_whole` (L-ING) 따로 |
| `cutting_board + carrot` PNG | `cutting_board` (L-TOOL) + `carrot_whole`/`carrot_julienne` (L-ING) 따로 |
| `pot + soup` PNG | `pot` (**L-VES**, 빈 용기) + 국물/건더기(L-ING) + `fx_steam`(L-FX) 따로 |
| `grill + galbi` PNG | `grill_pan` (**L-VES**) + `beef_cooked`(L-ING) + `fx_glow_heat`(L-FX) 따로 |
| `pan + kimchi` PNG | `frying_pan` (**L-VES**, 빈 팬) + `kimchi_cooked`(L-ING) + `fx_sizzle`(L-FX) 따로 |
| `bowl + bibimbap` PNG | `mixing_bowl` (**L-VES**, 빈 그릇) + 밥·나물·고명(L-ING) 따로 |

### 3.2 확장 금지 패턴 (위 4개의 일반화)

- 재료 PNG 안에 **도마/칼** 등장 (예: legacy `cut_anchors_m1` = 도마+칼+cut재료) → 금지.
- 도구 PNG 안에 **재료/음식** 등장 (예: pot 안에 국물·건더기 baked) → 금지.
- 환경 PNG 안에 **전경 도구/재료** baked (배경은 무대만) → 금지.
- VFX PNG 안에 **재료/도구** 일부라도 baked → 금지 (VFX 는 순수 투명 오버레이).
- UI 프레임 PNG 안에 **hero 재료/도구 일러스트** baked → 금지 (UI 칩/썸네일은 L-ING/L-TOOL 원본을 런타임 삽입).

### 3.3 예외 — variant 는 "단일 재료의 상태 변화"라 merge 가 아님

- `green_onion_whole` → `green_onion_chopped` 는 **동일 재료 1종의 두 상태** = 각각 독립 L-ING PNG (merge 아님, OK).
- cut variant 도 **결과물 단독**으로 생성 — 도마 없이 cut 된 재료 그 자체가 hero (`carrot_julienne` = 채 썬 당근 더미만, 도마/칼 없음).

---

## 4. Standalone Hero 생성 원칙 (L-ING / L-TOOL)

> `docs/art/ingredient-tool-art-lock.md` Hero Asset Mandate 와 합산 적용. 본 절은 **분리(architecture)** 측면, ingredient-tool-art-lock 은 **품질(volume/lighting/texture/depth)** 측면.

1. **single subject per image** — 재료 1종(또는 그 1종의 cut 더미) / 도구 1개만. co-asset 0개.
2. **no co-asset, no scene** — 도마/칼/냄비/그릴/손/캐릭터/배경 무대/다른 도구·재료 일절 없음.
3. **transparent 우선** — production 합성을 위해 `--background transparent` (alpha PNG) 가 default 권장. Cream bg opaque 는 카탈로그/anchor 검수용.
4. **cut variant = 결과물 단독** — `green_onion_chopped` 는 송송 썬 파 더미만, 도마 없음. `carrot_julienne` 는 채 썬 당근 더미만, 칼 없음.
5. **hero first, composition later** — 재료·도구는 모두 premium standalone 일러스트로 먼저 생성. 합성은 Godot 런타임 책임 (§5).

---

## 5. Runtime Composition Map — 8 module × layer 조합 (godot-dev 후속 참고)

> Godot 가 각 모듈 화면에서 **독립 PNG 레이어들을 z-order 로 조립**한다. art 는 각 레이어를 **따로** 납품. 합성은 코드(Scene/AnimationPlayer)가 담당. **art 가 미리 합성한 PNG 를 납품하지 않는다.**

### 5.1 Z-order 규약 (낮음 → 높음)

```
L-ENV (배경) → L-VES (용기 base: pot/pan/bowl) → L-TOOL (도구 base: cutting_board) → L-ING (재료) → L-TOOL (전경 도구: 칼/집게/주걱) → L-FX (steam/glow/sparkle) → L-UI (카드/게이지/버튼) → L-CHAR (반응 캐릭터)
```

### 5.2 8 module 조립표

| # | Module | L-ENV | L-VES (용기 base) | L-TOOL (도구) | L-ING (state swap) | L-FX | L-UI / L-CHAR |
|---|--------|-------|-------------------|---------------|--------------------|------|---------------|
| 1 | **slice (재료 손질)** | kitchen plate | — | `cutting_board`(base) + `chef_knife`(전경) | `*_whole` → **swap** `*_chopped`/`*_julienne`/`*_minced`/`*_diced` | `fx_sparkle`(perfect cut) | knife rhythm indicator, BPM 게이지 |
| 2 | **timing (끓이기/조리)** | stove plate | `pot` 또는 `dolsot` (빈 용기) | — | 국물 base + 건더기 재료(L-ING, 용기 위 별도 노드) | `fx_steam` + `fx_glow_heat` | doneness 게이지, timer |
| 3 | **season (양념)** | counter plate | (담는 그릇 = L-VES) | (양념 통/숟갈 = L-TOOL) | food(L-ING cooked) | `fx_particle`(양념 흩뿌림) + `fx_sparkle` | 양념 양 게이지 |
| 4 | **roll (말기 — 김밥)** | counter plate | — | `rolling_mat`(김발, base) | 김+밥+속재료 layers (각 L-ING) | `fx_sparkle`(완성) | 말기 진행 게이지 |
| 5 | **fry/grill (굽기/튀기기)** | stove plate | `grill_pan`(석쇠) 또는 `frying_pan` (빈 용기) | `tongs`(전경) | 고기/전 재료(L-ING) raw → **swap** cooked | `fx_glow_heat` + `fx_sizzle` + `fx_steam` | flip timing indicator |
| 6 | **mix (비비기 — 비빔밥)** | counter plate | `mixing_bowl` (빈 그릇) | `spatula`(전경) | 밥+나물+고명 layers (각 L-ING) | `fx_sparkle`(완성) | mix 진행 게이지 |
| 7 | **scoop/serve (담기)** | stove/counter plate | (담는 그릇 = L-VES) | `ladle` 또는 `spatula`(전경) | 완성 food(L-ING cooked) | `fx_steam` | 서빙 타이밍 게이지 |
| 8 | **plate/result (완성·반응)** | dining plate | (그릇 = L-VES) | — | 완성 음식(L-ING/food hero) | `fx_perfect_burst` + `fx_sparkle` | 별점/카드(L-UI) + **캐릭터 반응(L-CHAR)** |

> 각 셀의 PNG 는 **모두 독립 파일**. 예) module 1 `slice` 화면 1프레임 = `cutting_board.png` + `knife.png` + `green_onion_whole.png` 4개 노드가 런타임에 겹쳐짐. cut 발생 시 `green_onion_whole` 노드의 texture 만 `green_onion_chopped` 로 swap (도마/칼 노드는 그대로 유지). → 이것이 **max reuse / easier animation / smaller workload** 의 근거.

### 5.3 State swap 예시 (재료 1종, 여러 상태 = 같은 노드 texture 교체)

```
green_onion_whole.png  →(slice 완료)→  green_onion_chopped.png   # 같은 Sprite2D, texture만 swap
carrot_whole.png       →(채썰기)→       carrot_julienne.png
beef_raw.png           →(양념)→          beef_marinated.png       →(굽기)→  beef_cooked.png
```

---

## 6. 기존 art 영향 — legacy bake 위반 & 마이그레이션

> **핵심**: M1 anchor 3개 드라이버가 **도마+칼을 모든 재료 PNG에 baked** 했다. 이는 §3.1 `cutting_board + carrot` Bad 패턴의 정확한 위반. 본 LOCK 이전 산출물이므로 **standalone 재생성(reskin) 대상**.

| 드라이버 / 산출물 | 장수 (실측) | bake 위반 | LOCK 판정 | 마이그레이션 |
|-------------------|-------------|-----------|-----------|--------------|
| `gen_cut_anchors_m1.py` → `assets-raw/cut_anchors_m1/` | 7 | **칼(L-TOOL) + cut재료(L-ING)** 한 PNG에 baked (당근+칼) + opaque bg | **위반 (REJECT, mockup-only)** | cut 결과 재료는 `*_chopped`/`*_julienne`/`*_diced`(standalone)로 대체. `cutting_board`/`chef_knife` 는 L-TOOL standalone 신규 → Godot 합성 |
| `gen_ingredient_anchors_m1.py` → `assets-raw/ingredient_anchors_m1/` | 15 | **도마 + 칼 + whole재료** baked + opaque sage/cream bg | **위반 (REJECT, mockup-only)** | whole 재료는 `gen_ingredient_tool_hero.py` 의 `*_whole` variant(standalone)로 대체 |
| `gen_ingredient_cut_anchors_m1.py` → `assets-raw/ingredient_cut_anchors_m1/` | 12 | **도마 + 칼 + cut재료** baked + opaque sage bg (예: `F-07_daepa_cut`) | **위반 (REJECT, mockup-only)** | cut 결과는 `*_chopped`/`*_julienne`/`*_cooked` variant(standalone)로 대체 |
| `gen_tool_anchors_m1.py` → `assets-raw/tool_anchors_m1/` | 12 | 도구 **단독**(재료 없음)이나 opaque bg + "simple geometric flat fill"(= UI-icon 톤, 예: `TOOL-11_mixing_bowl` flat clip-art) | **REWORK (mockup, NOT production)** — architecture OK(재료 bake 없음) / hero 품질·bg 미달 | `gen_ingredient_tool_hero.py` 의 TOOLS/VESSEL 세트(standalone volumetric hero, transparent)로 대체 |
| `gen_ingredient_tool_hero.py` → `assets-raw/ingredient_tool_hero_m2/` | 17 | **없음** — single hero, no co-asset, transparent 지원, co-asset negative 포함 (`ing_green_onion_prepared` = 도마 없는 chopped pile) | **PASS (production reference)** | 본 LOCK 의 reference compliant driver. 신규 standalone 생성은 이 드라이버 사용 |
| `gen_character_pack.py` → `assets-raw/character_pack_m2/` | 28 (7×4) | base color 는 일관(OK) — 단 Phase C edit 가 `background` 미전달 = opaque cream 상속 → rembg cutout 시 arm/hand dark halo 위험 | **REWORK (transparent 파이프라인 깨짐)** | Phase B/C `background=transparent` 전달 + 6.1 색 LOCK 강화 + clean-transparent 문구 ([art-pipeline-correction.md](art-pipeline-correction.md) D2/D9) |

> **결론**: `cut_anchors_m1` / `ingredient_anchors_m1` / `ingredient_cut_anchors_m1` (소계 34장) = **baked = production 부적합 (mockup-only)**. `tool_anchors_m1` (12장) = standalone 이나 flat UI-icon = **rework**. Godot import 대상에서 제외하고, `gen_ingredient_tool_hero.py` standalone (L-ING/L-TOOL/**L-VES**) + `cutting_board`/`chef_knife`/`mixing_bowl`/`frying_pan`/`rolling_mat` standalone 신규로 전환. character 28장은 transparent 파이프라인 교정. (코드/import 삭제는 godot-dev/main thread 영역 — 본 LOCK 은 판정·전환 경로만 박제.)

---

## 7. Driver 신규 추가 권고 (Tool/Vessel gap)

`gen_ingredient_tool_hero.py` TOOLS 에 현재 7종(`knife / ladle / spatula / tongs / pot / dolsot / korean_grill`)이 있으나, v2 7-layer 합성에 필요한 다음이 누락 → **standalone 신규 추가** 권고:

| 신규 asset | layer | 용도 (module) | legacy 상태 |
|------------|-------|---------------|-------------|
| `cutting_board` | L-TOOL | slice base | 재료와 baked (`cut_anchors_m1`) |
| `rolling_mat` (김발) | L-TOOL | 김밥 말기 | mockup (`TOOL-10`) |
| `frying_pan` | L-VES | fry base | mockup (`TOOL-03`) |
| `mixing_bowl` | L-VES | 비빔밥 mix base | flat clip-art (`TOOL-11`) |

또한 기존 7종은 v2 에서 **재분류 + rename**: `knife→chef_knife`(L-TOOL), `pot`/`dolsot`/`korean_grill→grill_pan`(L-VES). 패치 spec 은 [art-pipeline-correction.md](art-pipeline-correction.md) §DELIVERABLE 8.A.

---

## 8. Lock 체크리스트 (production asset 통과 기준)

신규 art PNG 1장이 production 에 들어가기 전 전부 PASS:

| # | 항목 | PASS | FAIL = REJECT |
|---|------|------|---------------|
| AL1 | **single layer** | PNG 안에 1개 layer 주체만 (재료만 / 도구만 / 용기만 / 배경만 / VFX만 / UI만 / 캐릭터만) | 2종 이상 layer baked |
| AL2 | **no co-asset (재료)** | 재료 PNG에 도마/칼/냄비/팬/그릇/그릴/scene 없음 | co-asset baked |
| AL3 | **no co-asset (도구)** | 도구 PNG에 재료/음식/scene 없음 | 재료·음식 baked |
| AL4 | **no contents (용기)** | 용기(L-VES) PNG가 **빈 용기** (국물/음식/재료 없음) | 국물·음식 baked |
| AL5 | **cut variant standalone** | cut 결과 재료가 도마 없이 결과물 단독 | 도마 위 cut 결과 |
| AL6 | **independently reusable** | 이 asset 을 다른 module(mix/stir/roll)에서 단독으로 재사용 시 동반 회전·잔여물 없음 | co-asset 이 함께 따라옴 → 사용자 verbatim "reject it" |
| AL7 | **transparent / clean cutout** | alpha PNG, arm/hand/경계 dark halo·smudge 없음 | 합성 불가 bg baked / cutout artifact |
| AL8 | **hero 품질** | ingredient-tool-art-lock HA1~HA7 PASS (volume/lighting/texture/depth, NOT UI icon) | flat / UI icon |
| AL9 | **character consistency** (L-CHAR) | 같은 캐릭터 emotion 간 base color/identity 동일 (correction §6.5 CC1~CC5) | emotion 별 색 drift / artifact |

> AL1~AL7 = **architecture(분리·재사용·clean)**, AL8 = **quality(hero)**, AL9 = **character consistency**. 해당 layer 의 항목 모두 통과해야 LOCK.
