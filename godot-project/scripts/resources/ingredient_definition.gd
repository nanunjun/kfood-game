## IngredientDefinition — 한식 재료 1종의 데이터 정의 Resource.
##
## docs/ingredients-database.csv 컬럼 1:1 매핑.
## MVP 42종 (produce 11, meat 6, seafood 6, grain 7, sundry 17).
## 등록 위치: godot-project/resources/ingredients/{ingredient_id}.tres
##
## 참조:
##   - docs/ingredients-database.csv (source of truth)
##   - docs/systems/cooking-mechanics.md §2 (Stage 1 재료 선택 룰)
class_name IngredientDefinition
extends Resource

## 재료 고유 ID (예: "ing_p_001"=파, "ing_x_010"=김치). ingredients-database.csv의 ingredient_id와 1:1.
@export var ingredient_id: StringName = &""

## 한국어 표기.
@export var name_ko: String = ""

## 영어 표기.
@export var name_en: String = ""

## 가게 분류 — produce(농산), meat(정육), seafood(어물), grain(곡물), sundry(잡화).
## 5가게 메커닉의 store-routing 키.
@export var store_type: StringName = &"produce"

## 이 재료가 사용되는 음식 ID 리스트 (예: [&"t1_002", &"t1_003"]).
@export var used_in_foods: Array[StringName] = []

## 디스트랙터로 사용 가능한지 여부 (true면 다른 음식 Round에서 오답 후보로 등장).
@export var is_distractor_friendly: bool = false

## 디스트랙터 가중치 (0=비노출/basic_pantry ~ 3=자주). 0=basic_pantry(시장 미표시), 1=레어, 3=한식 base.
@export_range(0, 3, 1) var distractor_weight: int = 1

## 기본 양념 여부 (ADR-007). true면 Stage 1 시장 진열대 제외 + Scene 2 Kitchen rack 자동 표시 +
## accuracy_ingredients 분모에서 차감. basic_pantry 5종: 간장/고추장/설탕/참기름/소금.
@export var is_basic_pantry: bool = false

## 손질 variation 토큰 목록 (예: [&"CUT-05", &"CUT-03"]). 빈 배열이면 cut 메커닉 비적용(whole 사용).
@export var cut_variations: Array[StringName] = []

## 디자이너 메모 (페어, 디스트랙터 hint 등).
@export_multiline var notes: String = ""
