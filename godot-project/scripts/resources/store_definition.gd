## StoreDefinition — 재래시장 5가게 정의 Resource.
##
## MVP 5가게: produce(농산), meat(정육), seafood(어물), grain(곡물), sundry(잡화).
## Stage 1 다점포 순회 메커닉의 기본 단위.
## 등록 위치: godot-project/resources/stores/{store_id}.tres
##
## 참조:
##   - docs/systems/cooking-mechanics.md §2 (다점포 메커닉)
##   - docs/store-distribution.md (가게별 음식 분포)
class_name StoreDefinition
extends Resource

## 가게 고유 ID (StringName) — IngredientDefinition.store_type와 매치.
@export var store_id: StringName = &""

## 가게 한국어 표기 (예: "농산물 가게", "정육점", "어물전").
@export var name_ko: String = ""

## 가게 시그니처 컬러 (UI 강조, 가게 카드 배경 등).
@export var signature_color: Color = Color.WHITE

## 가게 아이콘 이미지 경로 (예: "res://art/ui/store_icon_produce.png"). M1 art sprint에서 실 asset 배치.
@export_file("*.png", "*.svg", "*.webp") var icon_path: String = ""

## 가게 ambient 사운드 경로 (예: "res://audio/sfx/ambient_produce.ogg"). M2~M3 sound sprint deferred.
@export_file("*.ogg", "*.wav") var ambient_sound_path: String = ""
