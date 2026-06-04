## GameManager — 세션 lifecycle 통합 조정자 (autoload).
##
## 역할: 게임 시작/씬 전환/종료 hook. 다른 manager(SaveManager, AdsManager 등)와의 조정.
## 본 sprint(M1)는 빈 skeleton — 실 로직은 M2 sprint에서 구현.
##
## 참조:
##   - docs/systems/cooking-mechanics.md (게임 루프 정의)
##   - project.godot [autoload] 등록 마지막 (의존 manager들이 먼저 init)
extends Node

## 현재 세션 시작 시각 (Unix ts, ms).
var session_started_at_ms: int = 0

## 현재 활성 씬 ID (placeholder).
var current_scene_id: StringName = &""

func _ready() -> void:
	# TODO: M2 sprint 구현
	# - session_started_at_ms 기록
	# - AnalyticsManager.log_session_start() 호출
	# - SaveManager.load_player_data() 호출
	session_started_at_ms = Time.get_ticks_msec()

## 씬 전환 hook — 모든 씬 전환은 본 메서드 경유 권장 (analytics + ad gating 통합).
func change_scene(scene_path: String) -> void:
	# TODO: M2 sprint 구현
	# - AdsManager.maybe_show_interstitial() (round_interval gating)
	# - AnalyticsManager.log_scene_change(scene_path)
	# - get_tree().change_scene_to_file(scene_path)
	pass

## 세션 종료 hook.
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		# TODO: M2 sprint 구현
		# - SaveManager.flush_player_data()
		# - AnalyticsManager.log_session_end()
		pass
