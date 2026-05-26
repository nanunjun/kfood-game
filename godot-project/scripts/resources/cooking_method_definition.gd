## CookingMethodDefinition — 조리 방법 1종 Resource.
##
## MVP 조리법: boil(끓이기), grill(굽기), stirfry(볶기), panfry(부치기), deepfry(튀기기),
##              roll(말기), mix(비비기), toss(섞기 — 2차).
## Stage 2 조리 방법 선택 게임의 옵션 단위.
## 등록 위치: godot-project/resources/cooking_methods/{method_id}.tres
##
## 참조:
##   - docs/systems/cooking-mechanics.md §3 (Stage 2 메커닉)
##   - docs/foods-database.csv primary_cooking_method 컬럼 (12음식 × 7+ methods)
class_name CookingMethodDefinition
extends Resource

## 조리법 고유 ID (예: &"boil", &"grill", &"stirfry").
@export var method_id: StringName = &""

## 한국어 표기 (예: "끓이기", "굽기").
@export var name_ko: String = ""

## 영어 표기 (분석 이벤트용).
@export var name_en: String = ""

## 도구 sprite 경로 (예: 냄비/팬/석쇠). 예: "res://art/sprites/tool_pot.png". M1 art sprint deferred.
@export_file("*.png", "*.svg", "*.webp") var tool_sprite_path: String = ""

## 이 조리법 default PERFECT window (ms). 음식별 override는 FoodDefinition.perfect_window_ms 우선.
@export_range(400.0, 2000.0, 50.0) var default_perfect_window_ms: float = 1000.0

## 이 조리법 default cook_time (초). 음식별 override는 FoodDefinition.cook_time_sec 우선.
@export_range(2.0, 30.0, 0.5) var default_cook_time_sec: float = 10.0
