## AdsManager — AppLovin MAX Godot plugin wrapper (autoload).
##
## ADR-004 (2026-05-23): AppLovin MAX 공식 Godot plugin (`AppLovin/AppLovin-MAX-Godot` v1.2.0+).
## plugin 설치 시 `AppLovinMAX` 글로벌 singleton 노출됨 (project.godot autoload 별도 등록 불필요,
## addon enable 시 자동). 본 wrapper는 게임 로직에서 호출하는 layer만 제공.
##
## 본 sprint는 빈 skeleton — 실 wiring은 M2 sprint.
##
## 참조:
##   - docs/godot-setup-guide.md Step 6 (plugin 설치 절차)
##   - docs/GDD.md §5.2 (광고 정책: rewarded/interstitial/banner)
##   - docs/balance-config.md v0.2 §2.2 (ads.interstitial_round_interval, ads.ftue_block_minutes)
extends Node

## SDK Key — AppLovin developer console에서 발급. NEVER commit 실 값. plugin 설정 또는 ENV로 주입.
const APPLOVIN_SDK_KEY_PLACEHOLDER: String = "REPLACE_WITH_APPLOVIN_SDK_KEY"

## Ad Unit IDs — AppLovin Mediation Manager에서 생성 (Android 기준 ca-app-pub-... 형식 placeholder).
const AD_UNIT_REWARDED: String = "REPLACE_WITH_REWARDED_AD_UNIT_ID"
const AD_UNIT_INTERSTITIAL: String = "REPLACE_WITH_INTERSTITIAL_AD_UNIT_ID"
const AD_UNIT_BANNER: String = "REPLACE_WITH_BANNER_AD_UNIT_ID"

## interstitial gating 카운터 — `ads.interstitial_round_interval` (default 3 round) 마다 노출.
var _rounds_since_last_interstitial: int = 0

func _ready() -> void:
	# TODO: M2 sprint 구현
	# - if Engine.has_singleton("AppLovinMAX"):
	#       AppLovinMAX.set_sdk_key(load_sdk_key_from_secret())
	#       AppLovinMAX.initialize()
	#       AppLovinMAX.create_banner(AD_UNIT_BANNER, AppLovinMAX.BannerPosition.BOTTOM_CENTER)
	#       AppLovinMAX.load_rewarded_ad(AD_UNIT_REWARDED)
	# - else: push_warning("[AdsManager] AppLovin MAX plugin not installed — ads disabled")
	pass

## Rewarded 광고 노출 — Hint 버튼 wiring (M2). 보상 콜백 awaiter 반환.
func show_rewarded_ad() -> bool:
	# TODO: M2 sprint 구현 — Hint 버튼 wiring
	return false

## interstitial 광고 노출 시도 (라운드 종료 시 호출). gating에 따라 skip 가능.
func maybe_show_interstitial() -> void:
	# TODO: M2 sprint 구현 — round_interval gating
	_rounds_since_last_interstitial += 1

## banner 표시/숨김 토글 (Remove Ads IAP 구매 시 hide).
func set_banner_visible(visible: bool) -> void:
	# TODO: M2 sprint 구현
	pass
