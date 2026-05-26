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

## 디스트랙터 가중치 (1=가끔 ~ 3=자주). 1=레어, 3=한식 base.
@export_range(1, 3, 1) var distractor_weight: int = 1

## 디자이너 메모 (페어, 디스트랙터 hint 등).
@export_multiline var notes: String = ""
