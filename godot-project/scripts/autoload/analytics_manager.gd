## AnalyticsManager — Godotx Firebase Analytics wrapper (autoload).
##
## ADR-004: Godotx Firebase (`godot-x/firebase`, MIT). Analytics + Crashlytics 모듈.
## Firebase Console에서 K-Food Master 프로젝트 생성 → google-services.json 다운로드 →
## godot-project/google-services.json 배치 (NEVER commit, .gitignore에 명시).
##
## 본 sprint는 빈 skeleton + 이벤트 enum placeholder.
##
## 참조:
##   - docs/godot-setup-guide.md Step 6 (Firebase 설치)
##   - docs/GDD.md (analytics 이벤트 카탈로그는 data-analyst sprint에서 정의)
extends Node

## 이벤트 enum placeholder — data-analyst sprint에서 본격 정의.
## Firebase Analytics 표준 이벤트(`level_start`, `level_end`)와 커스텀 이벤트 혼용.
enum EventType {
	SESSION_START,       ## 세션 시작 (앱 foreground).
	ROUND_START,         ## Round 시작 (음식별).
	ROUND_END,           ## Round 종료 (★ 결과 포함).
	HINT_USED,           ## Hint 버튼 사용 (rewarded ad 후).
	IAP_PURCHASED,       ## IAP 구매 완료 (SKU + 가격).
}

func _ready() -> void:
	# TODO: M2 sprint 구현
	# - if Engine.has_singleton("Firebase"):
	#       Firebase.Analytics.set_enabled(true)
	#       Firebase.Crashlytics.set_enabled(true)
	# - else: push_warning("[AnalyticsManager] Godotx Firebase plugin not installed")
	pass

## 이벤트 로그 — Firebase Analytics + 로컬 DB(M3) dual-write 추후 검토.
func log_event(event: EventType, params: Dictionary = {}) -> void:
	# TODO: M2 sprint 구현
	# - var event_name = EventType.keys()[event].to_lower()
	# - Firebase.Analytics.log_event(event_name, params)
	pass

## Crashlytics 커스텀 키 — debug 용 (예: 현재 음식 ID, Tier).
func set_custom_key(key: String, value: Variant) -> void:
	# TODO: M2 sprint 구현 — Firebase.Crashlytics.set_custom_key(key, value)
	pass
