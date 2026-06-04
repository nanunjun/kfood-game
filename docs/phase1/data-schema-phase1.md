# Data Schema — Phase 1 (.tres / CSV 확정)

> Phase 1 빌드용 데이터 계약. **기존 리소스 스크립트 위에 필드 추가**(비파괴, 기본값). 풀 스키마 = `docs/phase2_archive/schema-delta-v2.md`. 기존 12 food .tres·art_registry·shopping_registry·save_manager 보존.
> 기존 스크립트: `godot-project/scripts/resources/` — FoodDefinition·CharacterDefinition·IngredientDefinition·StoreDefinition·CookingMethodDefinition·TimingDefinition (모두 존재).

## 0. 변경 요약 (Phase 1)
| 리소스 | 상태 | Phase 1 작업 |
|---|---|---|
| FoodDefinition | 존재 | **필드 추가**: seasoning_slots, recommended_dishware, mismatch_dishware, seasoning_input_mode, market_id, unlock_level |
| CharacterDefinition | 존재(character_id·display_name·role·sprite·reaction_anchor) | **필드 추가**: taste_vector(5), tolerance, pass_threshold, requires_tier, unlock_level, dialogue(enter/satisfied/disappointed), partners(미사용 Phase1), is_evaluator |
| IngredientDefinition | 존재(store_type·used_in_foods·is_basic_pantry·cut_variations) | **필드 추가**: tier(basic/specialty), price_krw, uses_per_purchase, axis, quality_bonus, market_id |
| StoreDefinition | 존재(store_id·signature_color·icon·ambient) | **재사용** = MarketDefinition로 확장: open_level, reputation_tiers, category |
| CookingMethodDefinition | 존재 | 재사용(도구 sprite·기본 윈도우) |
| TimingDefinition | 존재(band_id…) | 재사용/판정 밴드 |
| **ToolDefinition** | 신규 | tier(basic/pro)·acquire(start/purchase)·price·effect_type·effect_params |
| **DishwareDefinition** | 신규 | tier(basic/pro/award)·acquire·price·award_level·match/mismatch_menus·art(empty/filled) |
| **SeasoningDefinition** | 신규 | seasoning_id·axis·color·icon·sfx·input_default |
| **LevelDefinition** 또는 levels_phase1.csv | 신규 | 8행 |
| **NoteData / JudgmentWindow / FeedbackProfile** | 신규(rhythm) | `rhythm-prototype-spec` 값 |
| SaveManager(autoload) | 존재 | **필드 추가**(아래 §8) |

## 1. FoodDefinition 추가 필드 (Phase 1 메뉴 12)
| 필드 | 타입 | 기본 | 설명 |
|---|---|---|---|
| `seasoning_slots` | Array[Dictionary] | [] | `{id:StringName, axis:StringName, u_min:int, u_max:int, weight:float}` (scoring §1.1) |
| `recommended_dishware` | Array[StringName] | [] | 매칭 보너스 그릇 id |
| `mismatch_dishware` | Array[StringName] | [] | 감점 그릇 id |
| `seasoning_input_mode` | enum(tap/hold) | tap | 양 입력 방식(분식=tap, 정밀=hold; scoring §1.5) |
| `market_id` | StringName | &"dongne" | 주 구매 시장(dongne/noryangjin) |
| `unlock_level` | int | 1 | 해금 레벨(menu-roster-phase1) |
| `reveal_profile` | StringName | &"" | 완성 연출 프로파일 키(steam/gloss/glow 조합; reveal 스펙 후속) |
> 기존 12 .tres 중 **9 재사용**(라면·김밥·떡볶이·잔치국수·비빔밥·잡채·불고기·해물파전·순두부). **신규 3 .tres 작성**: `m_kimchi_jjigae`·`m_doenjang_jjigae`·`m_maeuntang`(`data/menus-v2.csv` 값). 미사용 3(콘도그·김치볶음밥·갈비구이) = 리포 잔존하되 Phase1 레벨/시장 wiring 제외.

## 2. CharacterDefinition 추가 필드 (손님·평가자·상인)
| 필드 | 타입 | 설명 |
|---|---|---|
| `taste_vector` | PackedFloat32Array(5) | [단,짠,매,신,감칠] 0~1 (백엔드, UI 비노출) |
| `tolerance` | float | 편차 0.40~0.10 |
| `pass_threshold` | float | θ_pass(레벨 기본 override) |
| `requires_tier` | enum(none/specialty) | 통과 게이트(Phase1은 특산품까지) |
| `unlock_level` | int | 등장 레벨 |
| `is_evaluator` | bool | 평가자 여부(연출 분기) |
| `dialogue` | Dictionary | `{enter, satisfied, disappointed}` (EN/KR, [PLAYER_NAME]/[PLAYER_TYPE] 토큰) |
> role 필드(기존)에 guest/evaluator/merchant/player 구분. Phase1 인스턴스: 플레이어 5 + 친구 5(F1~F5) + 평가자 3(EV1~EV3) + 상인 2 = 15 .tres. (`characters-phase1`)

## 3. IngredientDefinition 추가 필드 (2티어·횟수제)
| 필드 | 타입 | 기본 | 설명 |
|---|---|---|---|
| `tier` | enum(basic/specialty) | basic | Phase1은 2티어 |
| `price_krw` | int | 0 | 구매가 |
| `uses_per_purchase` | int | 10 | 횟수제 소모(0 되면 메뉴 잠금) |
| `axis` | StringName | &"" | 양념 재료의 주 축 |
| `quality_bonus` | float | 0.0 | 특산품 +0.05 |
| `market_id` | StringName | &"dongne" | 판매 시장(noryangjin=해산물·죽방멸치) |
> `current_uses`(잔여)는 정의 아닌 세이브 상태(§8).

## 4. ToolDefinition (신규) — `resources/tools/{id}.tres`
`tool_id` · `tier`(basic/pro) · `acquire`(start/purchase) · `price_krw` · `effect_type`(perfect_window/combo_mult/miss_penalty/seasoning_absorb) · `effect_params`(`{basic:.., pro:..}`). Phase1 = 칼·도마·냄비·팬·국자(주걱)·웍·김발·튀김솥·양념볼 각 basic+pro. Master는 L8 어워드 1종만(상징).

## 5. DishwareDefinition (신규) — `resources/dishware/{id}.tres`
`dishware_id` · `tier`(basic/pro/award) · `acquire` · `price_krw` · `award_level` · `match_bonus_menus[]` · `mismatch_menus[]` · `art_empty`/`art_filled`. Phase1 = 사기(basic)·나무소반·모던플레이트·옹기·돌솥·백자(pro 구매/일부 평판) + L8 어워드 1(상징).

## 6. SeasoningDefinition (신규) — `resources/seasonings/{id}.tres`
`seasoning_id` · `axis`(sweet/salty/spicy/sour/umami) · `color`(Color) · `icon`(path) · `sfx`(path) · `input_default`(tap/hold). Phase1 = 고춧가루·간장·소금·설탕·멸치육수·마늘(게이지 색·SFX, rhythm §4).

## 7. LevelDefinition / levels_phase1.csv (신규, 8행)
컬럼: `level, deviation, theta_pass, guest_ids(|구분), menu_unlocks(|), market_open, system_unlock, tool_award, dishware_award`. 값 = `unlock-tree-phase1 §2`. 예:
```
level,deviation,theta_pass,guest_ids,menu_unlocks,market_open,system_unlock,tool_award,dishware_award
1,0.40,0.55,merchant_jeong,t1_002|t1_004,dongne,core,,
2,0.36,0.60,F1_mina,t1_003,,,,
3,0.31,0.64,EV1_mystery,t1_008,,evaluator_hint,,
4,0.27,0.68,F2_junho,m_kimchi_jjigae|t2_008,noryangjin,inventory_uses,,
5,0.23,0.72,F3_riley|EV2_blogger,m_doenjang_jjigae|t2_010,,dishware_match,,baekja
6,0.19,0.76,F4_mrslee,t2_014,,tool_pro_shop,,
7,0.14,0.82,F5_sora,t1_006|m_maeuntang,,golden_spoon_hint,,
8,0.10,0.88,EV3_inspector,t2_013,,ending_boss,master_tool_x1,master_dishware_x1
```

## 8. SaveManager 추가 필드 (autoload, 마이그레이션)
기존 `total_stars`·`_best{}` 유지 + 추가(ConfigFile):
| 키 | 타입 | 설명 |
|---|---|---|
| `economy/money` | int | 초기 50,000 |
| `inventory/{ingredient_id}` | int | 잔여 횟수 |
| `progress/level` | int | 도달 레벨(1~8) |
| `progress/menu_cleared[]` | Array | 클리어 food_id |
| `friends/{char_id}_affinity` | float | 친밀도 |
| `market/{market_id}_reputation` | float | 시장 평판 |
| `owned/tools[]`·`owned/dishware[]` | Array | 보유 |
| `settings/audio_offset_ms`·`visual_offset_ms`·`haptic_strength` | float | 손맛 캘리브레이션(rhythm §6/§10) |
| `meta/phase1_cleared` | bool | L8 엔딩 |
> 마이그레이션: 키 부재 시 기본값(money=50000, inventory empty, level=1). 별점 임계 불변(scoring §7).

## 9. 데이터 위치·네이밍
- foods `resources/foods/{food_id}.tres` · characters `resources/characters/{char_id}.tres` · ingredients `resources/ingredients/{id}.tres` · tools `resources/tools/{id}.tres` · dishware `resources/dishware/{id}.tres` · seasonings `resources/seasonings/{id}.tres` · levels `resources/levels_phase1.csv` 또는 `resources/levels/L{n}.tres`.
- 마스터 데이터 시트: `data/menus-v2.csv`(메뉴 41 중 Phase1 12 행 사용), 신규 `data/characters-phase1.csv`·`data/ingredients-phase1.csv` 후보(임포터로 .tres 생성).

## 10. 임포터·검증
- `tools/gen_resources_from_csv.py` 확장 → 신규 필드·신규 리소스(Tool/Dishware/Seasoning/Level) 생성.
- `tools/preflight_check.py` 확장 → 신규 .tres uid·res:// 참조·레벨↔캐릭터↔메뉴 정합 검사.
- 코드 변경은 빌드 sprint(`build-plan-phase1`)에서. 본 문서 = 계약.
