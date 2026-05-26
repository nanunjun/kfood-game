## SaveManager — 플레이어 진행도 / 설정 저장 (autoload).
##
## Godot ConfigFile 기반 (간단·가독성). 진행도 schema는 M2 sprint에서 결정.
## mid-game 캐릭터 swap (어머니/아버지 동시 등장 후 한 명 hide) 시 데이터 보존 hook 포함.
## (ui-designer 직전 sprint에서 결정된 동시 unlock + 표시 토글)
##
## 본 sprint는 빈 skeleton.
##
## 참조:
##   - docs/systems/friends-system.md §1 (양친 동시 unlock + 데이터 보존)
class_name SaveManager
extends Node

## save file 경로 (Godot user:// = Android internal storage).
const SAVE_PATH: String = "user://kfood_save.cfg"

## 메모리 캐시 (write-through).
var _player_data: ConfigFile = null

func _ready() -> void:
	# TODO: M2 sprint 구현
	# - _player_data = ConfigFile.new()
	# - load_player_data() 호출 (없으면 default 생성)
	_player_data = ConfigFile.new()

## 플레이어 데이터 로드.
func load_player_data() -> Error:
	# TODO: M2 sprint 구현
	return OK

## 플레이어 데이터 저장 (즉시 flush).
func flush_player_data() -> Error:
	# TODO: M2 sprint 구현
	return OK

## 캐릭터 swap 시 호출 — 양친 동시 등장 후 한 명만 표시되는 경우 데이터 보존 hook.
## (ui-designer 결정: 한 명 hide 해도 호불호 매트릭스/anchor 데이터 메모리 유지)
func preserve_character_state(character_id: StringName) -> void:
	# TODO: M2 sprint 구현
	pass
