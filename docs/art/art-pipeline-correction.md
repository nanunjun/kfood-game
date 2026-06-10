# Art Pipeline Correction — Baked-Composite Purge + 7-Layer Re-architecture

> 버전: **v1.0 (2026-06-06) — ART PIPELINE CORRECTION (URGENT)**
> 작성: art-director
> 트리거 (사용자 발견, verbatim): *"If an asset cannot be reused independently, reject it."*
> 성격: **art production correction only** — gameplay code / new systems / CSV 미변경. 본 문서는 8개 deliverable 을 통합하고, `asset-architecture-lock.md` (5→7 layer 확장) 와 두 driver 패치의 상위 spec 이다.
> 짝 문서: `docs/art/asset-architecture-lock.md` (7-layer LOCK), `docs/art/ingredient-tool-art-lock.md` (hero quality).
> 패치 driver: `tools/gen_ingredient_tool_hero.py` (naming + Vessel/Tool gap), `tools/gen_character_pack.py` (색 lock + clean transparent).

---

## 0. 사용자가 발견한 2개 결함 (mandatory fix)

| # | 결함 | 증거 (visual audit 확인) | 근본 원인 |
|---|------|--------------------------|-----------|
| **D1** | **Baked composite** — 재료가 도마+칼과 한 PNG에 baked. Mix/Stir/Roll 재사용 시 board/tool 이 재료와 함께 회전 = broken/prototype. | `cut_anchors_m1/cut_style_julienne_v1.png` = 당근+칼 baked. `ingredient_cut_anchors_m1/F-07_daepa_cut_v1.png` = 도마+칼+썬재료 baked, opaque sage bg. | legacy 3 driver 가 "도마+칼+재료 한 PNG" 방향. Phase A 가 이 baked art 를 cooking module 에 사용. |
| **D2** | **Character 불일치/artifact** — emotion variant 마다 색 drift 가능, arm/body 주변 black smudge / cutout artifact 우려. | base gen 자체(`junho_neutral/excited/disappointed`)는 색 일관 OK (opaque cream bg). 위험은 cream-bg → rembg cutout 단계 = `mina_excited` 의 raised-hand 영역 = rembg dark-halo 다발 구역. | Phase C `edit_image()` 가 `background` 미전달 → opaque cream 상속 → 후처리 rembg(u2net)가 arm/hand 경계에서 dark halo. |

> **핵심**: D1 = baked architecture (이미 31장 reject 대상). D2 = base gen 은 OK 지만 **transparent 파이프라인이 깨져 있음** (edit API 가 opaque 강제 + rembg artifact). 둘 다 본 correction 으로 교정.

---

## DELIVERABLE 1 — Baked / Composite Asset REJECT List

> 판정: **mockup-only, NOT production.** reroll/reskin 이 아니라 **layer 분해 후 standalone 재생성**. 코드/import 제외는 godot-dev·main thread 영역 — 본 문서는 판정·대체 경로만 박제.

### 1.1 REJECT — baked composite (RULE 1 위반, 31장)

| 산출물 디렉터리 | 장수 | baked 위반 | 등급 | 대체 (standalone) |
|-----------------|------|------------|------|-------------------|
| `assets-raw/ingredient_anchors_m1/` | 15 (F-01~F-12 + v3/v4 변형 3) | 도마(Vessel/Tool) + 칼(Tool) + whole재료(Ingredient) 한 PNG baked + opaque sage/cream bg | **REJECT (mockup-only)** | `gen_ingredient_tool_hero.py` `*_whole` (transparent standalone) |
| `assets-raw/cut_anchors_m1/` | 7 (`cutting_board` + cut_style_* 6) | `cut_style_*` = 칼 + cut재료 baked (당근+칼). `cutting_board` 단독은 board만이나 opaque + UI-icon 톤 | **REJECT (mockup-only)** | cut 결과 = `*_chopped/_julienne/_diced` standalone. `cutting_board` = Tool layer standalone 신규(§5) |
| `assets-raw/ingredient_cut_anchors_m1/` | 12 (F-01~F-12 cut) | 도마 + 칼 + 썬재료 한 PNG baked + opaque sage bg | **REJECT (mockup-only)** | `*_chopped/_julienne/_diced/_minced` standalone |

> 소계 = 15 + 7 + 12 = **34장 baked-reject** (사용자 추정 "31+" 와 정합 — v3/v4 변형 포함 시 34).

### 1.2 REWORK — standalone 이나 mockup 등급 (RULE 1 위반 아님, hero 품질 미달)

| 산출물 디렉터리 | 장수 | 상태 | 등급 | 대체 |
|-----------------|------|------|------|------|
| `assets-raw/tool_anchors_m1/` | 12 (TOOL-01~12) | 재료 bake **없음** (architecture OK) — 단 flat single-fill + UI-icon 톤 + opaque bg (예: `TOOL-11_mixing_bowl` = 매끈 단색 clip-art bowl) | **REWORK (mockup, NOT production)** | `gen_ingredient_tool_hero.py` Tool/Vessel hero (volumetric, transparent). `mixing_bowl`/`bamboo_mat`/`cutting_board` = §5 신규 추가 |

### 1.3 PASS — 이미 올바른 reference (변경 없음)

| 산출물 | 상태 | 등급 |
|--------|------|------|
| `assets-raw/ingredient_tool_hero_m2/` (17장) | single hero, co-asset 0, transparent 지원, `ing_green_onion_prepared` = 도마 없는 chopped pile | **PASS (production reference)** |

> **결론**: D1 정정 = 34 baked + 12 mockup-tool = **46장 reject/rework**, 모두 standalone hero (`ingredient_tool_hero_m2/` 방식)로 전환. 이미 PASS 인 17장이 올바른 reference.

---

## DELIVERABLE 2 — Correct Asset Taxonomy (7-Layer)

> 5-layer 에서 **Vessel/Cookware 를 Tool 에서 분리** (pot/dolsot/pan/bowl = 음식을 담는 용기 ≠ 손에 쥐는 도구). 상세 표/Godot 합성 규약은 `asset-architecture-lock.md` v2 §2~§5 로 확장. 요약:

| # | Layer | 정의 | 예시 standalone PNG | NEVER 포함 | Godot 합성 역할 |
|---|-------|------|---------------------|------------|-----------------|
| 1 | **Ingredient** | 재료 standalone hero, state variant 각각 | `green_onion_whole`, `carrot_julienne`, `kimchi_cooked` | board/knife/pan/hand/bg/캐릭터/다른재료/baked shadow | z 중단 — state swap 노드 (texture만 교체) |
| 2 | **Tool** | 손에 쥐는 도구 standalone hero | `chef_knife`, `cutting_board`, `ladle`, `spatula`, `tongs` | 재료/음식/scene | z 하단(board) + z 상단(knife/tongs 전경) |
| 3 | **Vessel/Cookware** (신규 분리) | 음식을 담는/끓이는 용기 standalone hero | `pot`, `dolsot`, `frying_pan`, `grill_pan`, `mixing_bowl` | 재료/국물/음식 baked | z 하단 base 용기 (재료는 별도 노드로 그 위) |
| 4 | **Environment** | 배경 무대 (주방/식당/시장) | `env_l1_home_kitchen` | 전경 재료/도구/용기 baked | z 최하단 배경 plate |
| 5 | **VFX** | 순수 alpha 오버레이 | `fx_steam`, `fx_sparkle`, `fx_glow_heat` | 재료/도구/용기 baked | z 상단 오버레이 |
| 6 | **UI** | 카드/버튼/아이콘/게이지 | `ui_card_frame`, `ui_gauge_doneness` | hero 재료/도구 일러스트 baked | z 최상단 HUD |
| 7 | **Character** | 캐릭터 bust/reaction | `junho_neutral`, `junho_excited` | 음식/scene baked, 다른 캐릭터 | result/dialog 노드 |

> **분류 1-rule**: "이 PNG 안에 2종 이상의 layer 주체가 함께 그려졌는가?" → YES = 위반 → 분해 후 standalone 재생성.
> **Vessel 분리 근거**: pot/pan/bowl 은 재료를 그 안에 담는 용기다. 만약 `pot+soup` 처럼 baked 하면 끓이기 module 에서 재료 state swap(raw→cooked) 불가. Vessel 은 빈 용기 standalone, 내용물(국물·건더기)은 Ingredient layer 별도 노드.

---

## DELIVERABLE 3 — File Naming Convention

> 기존 `ing_{id}_{variant}` / `tool_{id}` prefix → 사용자 naming(`green_onion_whole` 등)으로 정렬. driver 도 동일 출력으로 패치.

| Layer | 패턴 | 예시 |
|-------|------|------|
| **Ingredient** | `{ingredient}_{state}.png` | `green_onion_whole`, `green_onion_chopped`, `carrot_julienne`, `carrot_diced`, `kimchi_cooked`, `beef_sliced`, `garlic_minced` |
| **Tool** | `{tool}.png` | `chef_knife`, `cutting_board`, `ladle`, `spatula`, `tongs`, `rolling_mat` |
| **Vessel/Cookware** | `{vessel}.png` | `pot`, `dolsot`, `frying_pan`, `grill_pan`, `mixing_bowl` |
| **Character** | `{character}_{emotion}.png` | `junho_neutral`, `junho_excited`, `mina_happy` |
| **VFX** | `fx_{name}.png` | `fx_steam`, `fx_sparkle`, `fx_glow_heat`, `fx_perfect_burst` |
| **UI** | `ui_{name}.png` | `ui_card_frame`, `ui_gauge_doneness`, `ui_btn_primary` |
| **Environment** | `env_{name}.png` | `env_l1_home_kitchen`, `env_l3_market` |

### 3.1 State vocabulary (Ingredient — 통일 어휘)

| state | 의미 | 사용 |
|-------|------|------|
| `whole` | 손질 전 원물 | 모든 재료 시작 상태 |
| `chopped` | 송송/막 썰기 | green_onion, kimchi, garlic(거침) |
| `julienne` | 채썰기 | carrot, danmuji, zucchini(채) |
| `sliced` | 어슷/통썰기 | fish_cake, zucchini, beef |
| `diced` | 깍둑썰기 | carrot, tofu |
| `minced` | 다지기 | garlic |
| `cubed` | 큐브 | tofu |
| `marinated` | 양념 입힘 | beef |
| `cooked` | 조리 완료 | beef, kimchi, mozzarella, somyeon |

> migration 매핑: 기존 `*_raw` → `*_whole`, `*_prepared` → 재료별 cut 어휘(`chopped`/`julienne`/`sliced`/`minced`), `*_cooked` 유지. driver 가 variant key 를 이 어휘로 출력하도록 §DELIVERABLE 8 에서 패치.

---

## DELIVERABLE 4 — Ingredient Raw / Prepared / Cooked Asset List (전체)

> 12 음식 hero + 사용자 예시 = standalone variant 전체. 각 **standalone transparent**, naming convention 준수. (driver `INGREDIENTS` 와 1:1.)

| Ingredient | whole | prepared (cut) | cooked | 비고 |
|------------|-------|----------------|--------|------|
| green_onion (대파) | `green_onion_whole` | `green_onion_chopped`, `green_onion_julienne` | — | julienne 신규(국수 고명) |
| carrot (당근) | `carrot_whole` | `carrot_sliced`, `carrot_julienne`, `carrot_diced` | — | sliced 신규 |
| kimchi (김치) | `kimchi_whole` | `kimchi_chopped` | `kimchi_cooked` | 볶은김치 |
| firm_tofu (두부) | `tofu_block` (=`firm_tofu_whole`) | `tofu_cubed` | — | block/cubed |
| soft_tofu (순두부) | `soft_tofu_whole` | — | — | 깨진 커드 자체가 hero |
| beef (소고기) | `beef_raw` (=`beef_whole`) | `beef_sliced`, `beef_marinated` | `beef_cooked` | 불고기 |
| garlic (마늘) | `garlic_whole` | `garlic_minced` | — | |
| danmuji (단무지) | `danmuji_whole` | `danmuji_julienne` | — | 김밥 |
| fish_cake (어묵) | `fish_cake_whole` | `fish_cake_sliced` | — | 떡볶이 어슷 |
| zucchini (애호박) | `zucchini_whole` | `zucchini_sliced` | — | 국수 통썰기 |
| somyeon (소면) | `somyeon_whole` | — | `somyeon_cooked` | 삶은 면 |
| mozzarella (모짜렐라) | `mozzarella_whole` | — | `mozzarella_cooked` | 녹은 치즈 |

> 추가 권장(현재 미생성, gap): `green_onion_julienne` (국수 채), `carrot_sliced` (편), `tofu_block`/`tofu_cubed` naming 정렬. **모두 standalone transparent, 도마/칼/그릇 없음.**

### 4.1 39-SPEC FULL LIST (2026-06-06 art-driver 확장 — 사용자 LOCKED 정확 39)

> 사용자 정확 spec = **20 ingredient + 9 tool + 10 vessel = 39 standalone transparent asset.** driver `--spec39` 가 정확히 이 39장만 생성 (음식 12-매핑 extra hero 변형은 catalog 용이며 39 외). naming = 사용자 spec 그대로 출력 (`{id}_{state}.png` / `{tool}.png` / `{vessel}.png`).

#### Ingredient (20) — `{ingredient}_{state}.png`
| # | 파일 | driver (id, variant) | 신규? |
|---|------|----------------------|-------|
| 1 | `green_onion_whole` | green_onion / whole | 기존 |
| 2 | `green_onion_chopped` | green_onion / chopped | 기존 |
| 3 | `green_onion_julienne` | green_onion / julienne | 기존 |
| 4 | `carrot_whole` | carrot / whole | 기존 |
| 5 | `carrot_sliced` | carrot / sliced | 기존 |
| 6 | `carrot_julienne` | carrot / julienne | 기존 |
| 7 | `carrot_diced` | carrot / diced | 기존 |
| 8 | `kimchi_whole` | kimchi / whole | 기존 |
| 9 | `kimchi_chopped` | kimchi / chopped | 기존 |
| 10 | `kimchi_cooked` | kimchi / cooked | 기존 |
| 11 | `tofu_block` | tofu / block | naming 정렬 (firm_tofu→tofu) |
| 12 | `tofu_cubed` | tofu / cubed | naming 정렬 |
| 13 | `beef_raw` | beef / raw | 기존 |
| 14 | `beef_marinated` | beef / marinated | 기존 |
| 15 | `beef_cooked` | beef / cooked | 기존 |
| 16 | `egg_whole` | egg / whole | **신규** (날달걀) |
| 17 | `egg_cooked` | egg / cooked | **신규** (계란후라이 sunny) |
| 18 | `rice_bowl` | rice / bowl | **신규** (흰밥 mound 자체, 그릇 X) |
| 19 | `noodle_raw` | noodle / raw | **신규** (마른 면 bundle) |
| 20 | `noodle_cooked` | noodle / cooked | **신규** (삶은 면 nest) |

> `rice_bowl` 주의: 사용자가 **ingredient** 로 분류 → 밥 자체(흰밥 mound) 만 렌더 (그릇 NO). 그릇은 별도 Vessel asset. id=`rice`+variant=`bowl` → `rice_bowl.png` (사용자 naming 보존).
> `noodle_raw/cooked` = somyeon(소면 전용 hero) 와 병존하는 범용 면. 사용자 spec naming 우선.

#### Tool (9) — `{tool}.png`
| # | 파일 | driver id | 신규? |
|---|------|-----------|-------|
| 1 | `chef_knife` | chef_knife | 기존 |
| 2 | `cutting_board` | cutting_board | 기존 |
| 3 | `ladle` | ladle | 기존 |
| 4 | `spatula` | spatula | 기존 |
| 5 | `tongs` | tongs | 기존 |
| 6 | `rolling_mat` | rolling_mat | 기존 |
| 7 | `seasoning_bottle` | seasoning_bottle | **신규** (양념 통/병) |
| 8 | `spoon` | spoon | **신규** (숟가락) |
| 9 | `chopsticks` | chopsticks | **신규** (젓가락) |

#### Vessel/Cookware (10) — `{vessel}.png` (모두 EMPTY 용기)
| # | 파일 | driver id | 신규? |
|---|------|-----------|-------|
| 1 | `pot` | pot | 기존 |
| 2 | `dolsot` | dolsot | 기존 |
| 3 | `frying_pan` | frying_pan | 기존 |
| 4 | `grill_pan` | grill_pan | 기존 |
| 5 | `mixing_bowl` | mixing_bowl | 기존 |
| 6 | `noodle_bowl` | noodle_bowl | **신규** (빈 면 그릇) |
| 7 | `brass_bowl` | brass_bowl | **신규** (빈 놋그릇) |
| 8 | `wooden_tray` | wooden_tray | **신규** (빈 나무 쟁반) |
| 9 | `wide_plate` | wide_plate | **신규** (빈 넓은 접시) |
| 10 | `earthenware_bowl` | earthenware_bowl | **신규** (빈 옹기/질그릇) |

> **신규 11종** = egg(2) + rice(1) + noodle(2) + seasoning_bottle/spoon/chopsticks(3) + noodle_bowl/brass_bowl/wooden_tray/wide_plate/earthenware_bowl(5) = 11. 모두 standalone transparent, baked co-asset 0.

### 4.2 일관성 LOCK 강화 (STYLE_SUFFIX_HERO — 39 전체 동일 look)
- **LIGHTING**: every asset 단일 KEY LIGHT **top-left** (방향 통일) + soft rim + 1~2 specular.
- **OUTLINE**: every asset Cocoa **#3A2A1E ~3-4px** (두께 통일, per-asset 변동 금지).
- **CAMERA**: every asset 동일 **3/4 view + slight overhead** (하나의 angle family — front-on elevation / pure top-down flat-lay / low hero angle 금지).
- **PALETTE**: warm muted mid-sat 55-78% 통일. flat single-fill 금지 (2-3 step gradient 강제).
- **Vessel**: `VESSEL_EMPTY` clause — 내부 비어있음 (국물/음식/재료 baked 금지, 내용물 = L-ING 별도 노드).
- **Ingredient**: standalone (도마/칼/그릇 없음). **Tool**: standalone (재료 없음). **Vessel**: standalone empty.

### 4.3 39-spec 생성 명령 (main thread)
```powershell
# 정확 39 한 번에 — standalone transparent, production naming
py tools/gen_ingredient_tool_hero.py --spec39 --background transparent --quality medium --version v1
#   → 20 ingredient + 9 tool + 10 vessel = 39장, ~$1.64 (gpt-image-1 medium)

# 세트별 분할 (검수 단위)
py tools/gen_ingredient_tool_hero.py --spec39 --set ingredient --background transparent --quality medium  # 20장 ~$0.84
py tools/gen_ingredient_tool_hero.py --spec39 --set tool       --background transparent --quality medium  # 9장  ~$0.38
py tools/gen_ingredient_tool_hero.py --spec39 --set vessel     --background transparent --quality medium  # 10장 ~$0.42

# 누락 11종만 (기존 28장 재생성 회피, 신규만)
py tools/gen_ingredient_tool_hero.py --only egg,rice,noodle --set ingredient --background transparent --quality medium       # 5장
py tools/gen_ingredient_tool_hero.py --only seasoning_bottle,spoon,chopsticks --set tool --background transparent --quality medium  # 3장
py tools/gen_ingredient_tool_hero.py --only noodle_bowl,brass_bowl,wooden_tray,wide_plate,earthenware_bowl --set vessel --background transparent --quality medium  # 5장
```

---

## DELIVERABLE 5 — Tool / Vessel Standalone Asset List

> Tool = 손에 쥐는 것. Vessel/Cookware = 음식을 담는/끓이는 용기. 모두 standalone transparent hero, 재료/음식 baked 0.

### 5.1 Tool Layer

| tool | 상태 | 비고 |
|------|------|------|
| `chef_knife` | 기존 `tool_knife` → rename | slice module 전경 |
| `cutting_board` | **신규 (gap)** | slice module base. legacy 는 재료와 baked → standalone 필요 |
| `ladle` | 기존 `tool_ladle` | scoop/serve |
| `spatula` | 기존 `tool_spatula` | mix/fry 전경 |
| `tongs` | 기존 `tool_tongs` | grill 전경 |
| `rolling_mat` | **신규 (gap)** | 김밥 말기 (대나무 김발). legacy `bamboo_rolling_mat` 는 mockup |

### 5.2 Vessel/Cookware Layer (신규 분리)

| vessel | 상태 | 비고 |
|--------|------|------|
| `pot` | 기존 `tool_pot` → Vessel 재분류 | 끓이기 base (양은냄비) |
| `dolsot` | 기존 `tool_dolsot` → Vessel 재분류 | 순두부/돌솥 (뚝배기) |
| `frying_pan` | **신규 (gap)** | fry module base |
| `grill_pan` | 기존 `tool_korean_grill` → 명칭/재분류 | 석쇠/그릴판 |
| `mixing_bowl` | **신규 (gap)** | 비빔밥 mix base. legacy `TOOL-11` 은 flat mockup |

> **신규 4종 (cutting_board / rolling_mat / frying_pan / mixing_bowl)** = 이전 gap. legacy 에서 재료와 baked 되어 있었거나 mockup 등급이라 standalone 신규 필요. §DELIVERABLE 8 에서 driver 추가.

---

## DELIVERABLE 6 — Character Consistency Checklist (Junho Lock 포함)

> 같은 캐릭터는 **모든 emotion 에서 동일 base color/identity 유지**. emotion 은 표정/제스처만. artifact 금지.

### 6.1 LOCK — 모든 emotion 에서 불변 (변경 = REJECT)

| # | 고정 속성 | Junho lock 값 |
|---|-----------|---------------|
| L1 | **skin tone** | warm light-tan Korean skin (동일 shade, 밝아지거나 어두워지지 않음) |
| L2 | **hair color** | short dark brown, slightly spiky front (동일 brown, 검정으로 drift 금지) |
| L3 | **eye color** | black dot eyes + single white highlight (동일) |
| L4 | **clothing color** | RED-ORANGE hoodie (Persimmon #E8732C → Gochu Red #D84338 단일 warm-red block) |
| L5 | **accent color** | small chili/flame motif on chest (동일 위치·색, spicy cue) |
| L6 | **silhouette** | spiky-front young guy round face, bust 1:1.3~1.6 chibi |
| L7 | **line weight** | Cocoa #3A2A1E outline 3~4px (동일 두께) |
| L8 | **shading style** | soft 2-tone cel (base + base×0.85), peach blush #E89A7A @40% |

### 6.2 CHANGE only — emotion 별 허용 변경

facial expression / hand gesture / pose / small emotion fx(sparkle·sweat) / mouth / eyebrow / eye shape (dot↔crescent↔droop). **그 외 전부 6.1 고정.**

### 6.3 Artifact 금지 (clean transparent)

clean transparent cutout / NO black smudge / NO dark patch / NO cutout artifact around arm·body·hand / clean silhouette / consistent soft outline. (= D2 fix: arm/hand 주변 dark halo 불가.)

### 6.4 Junho example lock (verbatim anchor)

> young Korean male, 20s / short dark brown hair (spiky front) / warm tan skin / RED-ORANGE hoodie (Persimmon→Gochu Red) / small chili-pepper accent on chest (spicy cue) / Cocoa #3A2A1E outline 3~4px / peach blush #E89A7A. **이 8 LOCK 속성은 neutral·happy·excited·disappointed 4 emotion 에서 픽셀-동일 톤 유지.**

### 6.5 검수 rubric (emotion variant 1장 PASS 기준)

| # | 항목 | PASS | FAIL = REJECT |
|---|------|------|---------------|
| CC1 | base color 일치 | neutral 과 hair/skin/hoodie/accent 동일 shade | 색 drift (밝/어둡/채도 변화) |
| CC2 | identity 일치 | 같은 캐릭터로 즉시 식별 | 다른 사람처럼 보임 |
| CC3 | emotion 변화만 | 표정/제스처/fx 만 바뀜 | outfit shape/hair shape 변형 |
| CC4 | clean transparent | arm/hand/body 경계 깨끗 | black smudge / dark halo / cutout 잔여 |
| CC5 | outline 일관 | Cocoa 3~4px 동일 | outline 두께/색 변화 |

---

## DELIVERABLE 7 — Updated Prompt Templates (3 — 핵심)

### 7.1 Ingredient-only (standalone, transparent)

```
A HERO illustration of a single {ingredient} ({state}).
STANDALONE: this is JUST the ingredient itself — NO cutting board, NO knife, NO pan,
NO pot, NO bowl, NO plate, NO hand, NO character, NO background scene, NO other
ingredient, NO baked shadow cast onto another object. A cut/prepared state is the cut
pile ITSELF alone (e.g. chopped green onion is a small relaxed pile of sliced rounds,
NOT on a board). Hero volumetric quality (Cooking Diary item quality): real VOLUME,
soft top-left key light, ONE-TWO small specular freshness highlights, tactile surface
texture, rounded dimensional form. Recognizable alone without any text. Warm Cocoa
#3A2A1E outline 3-4px. Fully TRANSPARENT background (alpha cutout) — no cream plate,
no scene. AVOID: flat vector / UI icon / clip-art / color block / board-or-knife in
frame / food inside a pot-pan-bowl / any second co-asset baked in.
```

### 7.2 Tool-only (standalone, transparent)

```
A HERO illustration of a single {tool}, 3/4 view.
STANDALONE: this is JUST the tool itself — NO ingredient, NO food, NO chopped pile,
NO scene, NO hand, NO other tool. Reusable with ANY ingredient (the tool never holds
or touches food in this asset — composition is done later in Godot). Hero volumetric
quality: real VOLUME / soft top-left key light / metal sheen or wood grain or
earthenware grit texture / believable thickness and depth. Recognizable alone without
text. Warm Cocoa #3A2A1E outline 3-4px. Fully TRANSPARENT background (alpha cutout).
AVOID: flat vector / UI icon / clip-art / color block / any ingredient or food baked
into the frame / cold uniform thin outline faking a flat shape.
```

> **Vessel/Cookware** 은 tool 템플릿을 쓰되 "an EMPTY {vessel} — NO soup, NO broth, NO food, NO ingredient inside; the inner cavity is empty and clean (contents are added later in Godot as a separate layer)" 추가.

### 7.3 Character emotion (identity LOCK + clean transparent)

```
The SAME character {name} as the base image. LOCK (must stay pixel-identical tone):
skin tone, hair color, eye color, clothing color, accent/motif color and position,
silhouette, chibi proportions, Cocoa #3A2A1E outline 3-4px weight, soft 2-tone cel
shading, peach blush #E89A7A. The hair/skin/outfit shade and saturation MUST exactly
match the base (NOT lighter, NOT darker). CHANGE ONLY: facial expression, eyebrow,
eye shape, mouth, hand gesture/pose, and a small emotion fx ({emotion-specific}).
Everything else UNCHANGED.
CLEAN TRANSPARENT: fully transparent background (alpha cutout), with a CLEAN crisp
silhouette around the whole body including arms and raised hands — NO black smudge,
NO dark halo, NO grey fringe, NO cutout artifact around the arm/hand/shoulder edges,
NO leftover background patch. The outline stays the consistent soft Cocoa 3-4px.
AVOID: color drift, different palette per emotion, anime sparkly pupils, crying tears
on disappointed (subtle lowered-brow frown only), dark edge artifacts.
```

---

## DELIVERABLE 8 — 6 Corrected Example 생성 명령 (main thread 실행)

> driver 2개를 §8.A/§8.B 로 패치한 뒤, 아래 명령으로 6장 생성. 모두 **transparent**.

### 8.A `gen_ingredient_tool_hero.py` 패치 (naming + Vessel/Tool gap)

1. variant key 어휘 정렬: `raw→whole`, `prepared→{chopped|julienne|sliced|...}`, `cooked` 유지.
2. 출력 파일명 `ing_{id}_{variant}` → `{id 정렬}_{state}` (예: `green_onion_whole.png`).
3. Tool/Vessel gap 추가: `cutting_board`, `rolling_mat`, `frying_pan`, `mixing_bowl`. Vessel 템플릿(빈 용기) 적용.
4. `--background transparent` default 권장(production), `opaque` = 카탈로그 검수용.

### 8.B `gen_character_pack.py` 패치 (색 lock + clean transparent)

1. `edit_image()` 가 `background="transparent"` 를 `client.images.edit(...)` 에 전달 (현재 미전달 → opaque cream 상속 = artifact 원인).
2. Phase C common_frame 에 6.1 LOCK 8속성 + 6.3 clean-transparent(arm/hand no-dark-halo) 강화 문구 추가.
3. Phase B neutral 도 `--background transparent` 지원 (transparent-native gen).

### 8.C 6 corrected example 생성 명령 (main thread)

```powershell
# Ingredient (2) — standalone transparent, NO board
py tools/gen_ingredient_tool_hero.py --set ingredient --only green_onion `
   --background transparent --quality medium --version v2
#   → green_onion_whole.png + green_onion_chopped.png

# Tool (2) — standalone transparent, Tool layer
py tools/gen_ingredient_tool_hero.py --set tool --only chef_knife,cutting_board `
   --background transparent --quality medium --version v2
#   → chef_knife.png + cutting_board.png  (cutting_board = 신규 gap)

# Character (2) — consistency lock, expression only, clean transparent
py tools/gen_character_pack.py --phase B --only junho `
   --background transparent --quality medium --version v2
#   → junho_neutral.png  (transparent-native base)
py tools/gen_character_pack.py --phase C --only junho --emotion excited `
   --background transparent --quality medium --version v2
#   → junho_excited.png  (동일 base color, expression만, clean transparent)
```

> 예상 비용: gpt-image-1 medium $0.042 × 6 = **~$0.25**.

---

## DELIVERABLE 9 — Character Artifact 해결책 (transparent-native vs rembg-isnet)

| 옵션 | 방법 | 장점 | 단점 | 권고 |
|------|------|------|------|------|
| **A. transparent-native gen** | gpt-image-1 `background=transparent` 로 직접 alpha 생성 (gen + edit 양쪽) | 별도 후처리 0, arm/hand 경계 모델이 직접 alpha 처리 = dark-halo 원천 차단 | edit API 가 transparent 미지원 시 fallback 필요 | **1순위 권고** |
| **B. cream-bg + rembg(isnet)** | opaque cream 생성 후 rembg `isnet-general-use` 모델 + alpha-matting 후처리 | edit API 호환, 단색 bg cutout 안정 | u2net(기본)이 arm/hand 가는 영역에서 dark halo = **현 artifact 주범**. isnet + alpha-matting 으로 완화하나 여전히 후처리 의존 | A 불가 시에만 |

### 9.1 권고 (D2 fix 경로)

1. **transparent-native (A) 우선**: `gen_character_pack.py` Phase B(generate) + Phase C(edit) 모두 `background=transparent` 전달. arm/hand black smudge 는 rembg u2net 부산물이므로, native alpha 면 원천 제거.
2. **edit API 가 transparent 반영 안 하면**: Phase B 만 transparent-native 로 받고, Phase C 는 (a) transparent base 를 edit 입력으로 주거나, (b) opaque 로 edit 후 **rembg `isnet-general-use` + `--alpha-matting`** (u2net 금지) 으로 cutout — arm halo 가 isnet 에서 현저히 감소.
3. **검수**: 6.5 CC4 (arm/hand/body 경계 깨끗) 로 매 variant gate. dark halo 1px 라도 보이면 reject → isnet alpha-matting 재처리 또는 native 재생성.

> **요약 권고**: transparent-native (옵션 A) 를 default 로, rembg 는 isnet+alpha-matting 으로만(u2net 폐기). rembg u2net 이 character arm artifact 원인.
