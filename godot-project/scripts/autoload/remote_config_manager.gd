## RemoteConfigManager — Firebase Remote Config wrapper (autoload).
##
## ADR-004 + balance-config.md v0.2: Remote Config single source of truth.
## 우선순위: Remote Config > Godot Resource(.tres) default > 본 wrapper의 코드 default.
## Godotx Firebase Remote Config 모듈 사용 (ADR-004 follow-up 검증 항목).
##
## 본 sprint는 빈 skeleton + 키 상수 catalog (balance-config v0.2 §2).
##
## 참조:
##   - docs/balance-config.md v0.2 §2 (Remote Config 키 catalog)
##   - docs/GDD.md (A/B 테스트 정책)
class_name RemoteConfigManager
extends Node

## Remote Config 키 상수 — balance-config.md v0.2 §2 sync.
## 코드 내 직접 string 사용 금지 — 본 상수 경유 권장 (typo 방지).
const KEY_STAGE1_PENALTY_PER_WRONG: String = "cooking.stage1.penalty_per_wrong"
const KEY_STAGE1_TIME_PENALTY_SEC: String = "cooking.stage1.time_penalty_sec"
const KEY_STAGE1_TIME_LIMIT_BY_TIER: String = "cooking.stage1.time_limit_by_tier"
const KEY_STAGE2_TIME_LIMIT_SEC: String = "cooking.stage2.time_limit_sec"
const KEY_STAGE3_PERFECT_WIDTH: String = "cooking.stage3.perfect_width"
const KEY_STAGE3_PERFECT_WIDTH_AD: String = "cooking.stage3.perfect_width_ad"
const KEY_STAGE3_PERFECT_WIDTH_BY_FOOD: String = "cooking.stage3.perfect_width_by_food"
const KEY_STAGE3_BAND_DISTRIBUTION: String = "cooking.stage3.band_distribution"  ## C-4 lock
const KEY_STAGE3_FLIP_REQUIRED_FOODS: String = "cooking.stage3.flip_required_foods"  ## C-3 lock (MVP: [])
const KEY_DISTRACTOR_PER_STORE_BY_TIER: String = "cooking.distractor_per_store_by_tier"
const KEY_EARLY_FINISH_BONUS_MAX: String = "cooking.early_finish_bonus_max"
const KEY_HINT_TRIGGER_AT_REMAINING_PCT: String = "cooking.hint.trigger_at_remaining_pct"
const KEY_HINT_REQUIRES_REWARDED_AD: String = "cooking.hint.requires_rewarded_ad"
const KEY_SCORING_STAR_THRESHOLDS: String = "scoring.star_thresholds"
const KEY_FRIENDS_LIKE_BONUS_PCT: String = "friends.like_bonus_pct"
const KEY_FRIENDS_DISLIKE_PENALTY_PCT: String = "friends.dislike_penalty_pct"
const KEY_FRIENDS_PREFERENCE_AFFECT_STARS: String = "friends.preference_affect_stars"
const KEY_ADS_INTERSTITIAL_ROUND_INTERVAL: String = "ads.interstitial_round_interval"
const KEY_ADS_FTUE_BLOCK_MINUTES: String = "ads.ftue_block_minutes"
const KEY_ECONOMY_COIN_PER_STAR_BY_TIER: String = "economy.coin_per_star_by_tier"

## 로컬 캐시 (fetch 성공 시 fill).
var _cache: Dictionary = {}

## fetch 완료 여부 — false면 default 사용.
var _fetched: bool = false

func _ready() -> void:
	# TODO: M2 sprint 구현
	# - if Engine.has_singleton("Firebase"):
	#       Firebase.RemoteConfig.set_defaults(_get_default_dict())
	#       Firebase.RemoteConfig.fetch_and_activate()
	#       _cache = Firebase.RemoteConfig.get_all()
	#       _fetched = true
	# - else: push_warning("[RemoteConfigManager] Firebase plugin not installed — using defaults")
	pass

## 값 조회 — 캐시 우선, 미존재 시 default_value 반환.
func get_value(key: String, default_value: Variant) -> Variant:
	return _cache.get(key, default_value)

## 본 sprint default catalog — balance-config v0.2 §2 sync. M2에서 fetch payload와 reconcile.
func _get_default_dict() -> Dictionary:
	return {
		KEY_STAGE1_PENALTY_PER_WRONG: 0.15,
		KEY_STAGE1_TIME_PENALTY_SEC: 1.0,
		KEY_STAGE1_TIME_LIMIT_BY_TIER: [20, 28],
		KEY_STAGE2_TIME_LIMIT_SEC: 7,
		KEY_STAGE3_PERFECT_WIDTH: 0.10,
		KEY_STAGE3_PERFECT_WIDTH_AD: 0.20,
		KEY_STAGE3_BAND_DISTRIBUTION: {"perfect": 0.10, "good": 0.45, "miss": 0.45},
		KEY_STAGE3_FLIP_REQUIRED_FOODS: [],
		KEY_DISTRACTOR_PER_STORE_BY_TIER: [1, 1, 2, 2, 3],
		KEY_EARLY_FINISH_BONUS_MAX: 0.10,
		KEY_SCORING_STAR_THRESHOLDS: [50, 75, 90],
		KEY_FRIENDS_LIKE_BONUS_PCT: 0.05,
		KEY_FRIENDS_DISLIKE_PENALTY_PCT: 0.05,
		KEY_FRIENDS_PREFERENCE_AFFECT_STARS: false,
		KEY_ADS_INTERSTITIAL_ROUND_INTERVAL: 3,
		KEY_ADS_FTUE_BLOCK_MINUTES: 5,
	}
