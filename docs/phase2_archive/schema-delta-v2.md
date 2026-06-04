# Schema Delta v2 — 데이터 스키마 변경 (코드 변경 0, 설계만)

> 메타 개편 v2.0이 요구하는 `.tres`/CSV 스키마 변경을 **필드 단위**로 명세. **기존 12음식 데이터·아트 보존 전제** — 추가는 옵셔널 필드(기본값 있음)로, 변경은 비파괴적으로.
> 현 단계 코드 변경 0. 본 문서는 후속 구현 sprint의 청사진.

## 0. 변경 요약
| 대상 | 변경 | 파괴적? |
|---|---|---|
| FoodDefinition (.tres) | 필드 **추가**: seasoning_slots, recommended_dishware | 비파괴(기본값) |
| IngredientDefinition (.tres) | 필드 추가: tier, price_krw, uses_per_purchase, axis, quality_bonus | 비파괴 |
| **CharacterDefinition** (.tres) | **신규** 리소스 | 신규 |
| **ToolDefinition** (.tres) | **신규** (기존 도구는 art만 있었음) | 신규 |
| **DishwareDefinition** (.tres) | **신규** | 신규 |
| **SeasoningDefinition** (.tres) | **신규**(선택; 슬롯 inline도 가능) | 신규 |
| LevelDefinition (.tres) 또는 levels.csv | **신규** 12레벨 | 신규 |
| SaveManager 저장 스키마 | 필드 추가(money, inventory, unlock, friend_score, owned tools/dishware) | 비파괴(마이그레이션) |
| foods-database.csv | 컬럼 추가(seasoning_slots, recommended_dishware) | 비파괴 |

---

## 1. FoodDefinition — 필드 추가 (기존 보존)
기존 필드(food_id, name_ko/en, tier, cook_time_sec, prep_*, correct_method_id, method_options, notes…) **전부 유지**. 추가:
| 필드 | 타입 | 기본값 | 설명 |
|---|---|---|---|
| `seasoning_slots` | Array[Dictionary] | `[]` | 양념 슬롯. 각: `{id:StringName, axis:StringName(sweet/salty/spicy/sour/umami), u_min:int, u_max:int, weight:float}` |
| `recommended_dishware` | Array[StringName] | `[]` | 권장 그릇 id (매칭 보너스). 예: `[&"onggi"]` |
| `mismatch_dishware` | Array[StringName] | `[]` | 어색한 그릇 id (감점) |
> `seasoning_slots`가 비면 레거시 점수 모델 사용(scoring §7). 데이터는 `scoring-v2 §1.1` 표대로 채움. 기존 12 .tres는 필드 미존재 시 기본값으로 로드(Godot Resource는 누락 필드 기본값 허용).

## 2. IngredientDefinition — 필드 추가
| 필드 | 타입 | 기본값 | 설명 |
|---|---|---|---|
| `tier` | enum(basic/specialty/luxury) | basic | 재료 티어 |
| `price_krw` | int | 0 | 구매가 |
| `uses_per_purchase` | int | 10 | 1구매당 사용 횟수(횟수제 소모) |
| `axis` | StringName | &"" | 주 미각축(양념재료일 때) |
| `quality_bonus` | float | 0.0 | 점수 부스트(특산품 0.05/명품 0.10) |
| `is_premium_gate` | bool | false | 미식가 통과 게이트 재료 여부 |
> `current_uses`(잔여 횟수)는 **재료 정의가 아니라 세이브/인벤토리 상태**(§7). 정의에는 `uses_per_purchase`만.

## 3. CharacterDefinition — 신규 (`resources/characters/{id}.tres`)
| 필드 | 타입 | 설명 |
|---|---|---|
| `char_id` | StringName | C1~C15 |
| `name_ko` / `name_en` | String | 표시명 |
| `archetype` | String | 아키타입 |
| `level` | int | 등장 레벨 1~12 |
| `taste_vector` | PackedFloat32Array(5) | [단,짠,매,신,감칠] 0~1 |
| `tolerance` | float | 편차(정규화) 0.40~0.05 |
| `requires_tier` | enum(none/specialty/luxury) | 명품 필수 게이트 |
| `pass_threshold` | float | θ_pass (레벨 기본값 override 가능) |
| `partners` | Array[StringName] | 다인 짝꿍 char_id |
| `backstory` | String(multiline) | 백스토리 |
| `art_keys` | Dictionary | 표정별 스프라이트 경로(star1/2/3) |
> 데이터는 `characters-v2 §2.1` 표대로.

## 4. ToolDefinition — 신규 (`resources/tools/{method}.tres`)
| 필드 | 타입 | 설명 |
|---|---|---|
| `tool_id` | StringName | knife/board/pot/pan/ladle/mixbowl/wok/roll/deepfry |
| `tier` | enum(basic/pro/master) | 티어 |
| `acquire_method` | enum(start/purchase/award) | 획득 방식 |
| `price_krw` | int | 구매가(pro), 0이면 비구매 |
| `award_level` | int | 어워드 레벨(master), 0이면 해당없음 |
| `effect_type` | StringName | perfect_window/combo_mult/miss_penalty/seasoning_absorb |
| `effect_params` | Dictionary | 티어별 수치(예: `{basic:100, pro:130, master:160}`) |
> 효과 매핑 `scoring-v2 §9`, 가격/어워드 `economy §6`.

## 5. DishwareDefinition — 신규 (`resources/dishware/{id}.tres`)
| 필드 | 타입 | 설명 |
|---|---|---|
| `dishware_id` | StringName | sagi/namban/modern_plate/onggi/baekja/dolsot/glass/yugi/luxury_ceramic |
| `tier` | enum(basic/pro/master) | 티어(match 배수 ×1.0/1.1/1.25) |
| `acquire_method` | enum(start/purchase/award) | 획득 |
| `price_krw` | int | 구매가(pro) |
| `award_level` | int | 어워드 레벨(master) |
| `match_bonus_dishes` | Array[StringName] | 매칭 보너스 food_id |
| `mismatch_dishes` | Array[StringName] | 미스매치 food_id |
| `art_empty` / `art_filled` | String | 빈 그릇 / 음식 담긴 스프라이트 |
> 효과 `scoring-v2 §11`, 가격/어워드 `economy §7`.

## 6. SeasoningDefinition (선택) / LevelDefinition
- **SeasoningDefinition**: 슬롯 id↔축↔표시명·아이콘. FoodDefinition.seasoning_slots에 inline해도 되나, 공유 양념(설탕·간장)은 별도 리소스 권장. 필드: `seasoning_id, axis, name_ko/en, icon`.
- **LevelDefinition / levels.csv** (신규): `level(1~12), stage(분식/가정식/한정식), tolerance, theta_pass, required_tier, dinner_guests(int), guest_ids[], menu_unlocks[], material_unlock, tool_award, dishware_award`. 12행. `unlock-tree §3` 표 = 데이터 소스.

## 7. SaveManager 저장 스키마 — 필드 추가 (마이그레이션)
기존: `total_stars`, `_best{food_id:stars}`. 추가(ConfigFile 섹션):
| 섹션/키 | 타입 | 설명 |
|---|---|---|
| `economy/money` | int | 보유 자금(초기 50,000) |
| `inventory/{ingredient_id}` | int | 잔여 사용 횟수(current_uses) |
| `progress/level` | int | 현재 최고 도달 레벨 |
| `progress/menu_mastered[]` | Array | 마스터한 food_id |
| `friends/{char_id}_cum` | float | 친구 누적 만족 점수 |
| `owned/tools[]` | Array | 보유 도구 id(+tier) |
| `owned/dishware[]` | Array | 보유 그릇 id |
| `meta/master_collected[]` | Array | 수집한 마스터 도구·그릇(트로피 룸) |
| `meta/title_master` | bool | "한식 명인" 칭호 획득 |
> **마이그레이션**: 기존 세이브는 추가 키 부재 → 로드 시 기본값(money=50000, inventory empty=첫 구매 유도, level=1). `_best`/`total_stars`는 그대로 사용(별점 임계 불변, scoring §7).

## 8. foods-database.csv — 컬럼 추가
기존 컬럼 전부 유지. 추가: `seasoning_slots`(직렬화 문자열 또는 별도 시트), `recommended_dishware`, `mismatch_dishware`. 임포터(`tools/gen_resources_from_csv.py`) 확장으로 .tres에 반영.

## 9. 마이그레이션 영향 평가
| 영역 | 영향 | 리스크 |
|---|---|---|
| 기존 12음식 .tres | 추가 필드만, 기존 로드 정상 | 낮음 |
| 기존 세이브 | 기본값 주입, 별점 호환 | 낮음 |
| 점수 로직 | 슬롯 있으면 v2, 없으면 레거시(블렌딩) | 중간(구현 시 검증) |
| 아트 | 신규 슬롯(캐릭터·그릇·도구 티어) 필요, 기존 음식 아트 재사용 | art-needs-v2 |
| 신규 리소스 4종 | Character/Tool/Dishware/Level | 구현 비용(후속 sprint) |
> 코드 변경 0(현 단계). 본 스키마는 후속 구현의 계약(contract).
