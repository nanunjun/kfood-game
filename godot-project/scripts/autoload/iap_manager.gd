## IapManager — Godot Foundation Google Play Billing plugin wrapper (autoload).
##
## ADR-004 / ADR-003: MVP IAP = Remove Ads ($2.99) + Coin Pack 3종.
## Korean Food Pack DLC는 post-launch.
##
## 본 sprint는 빈 skeleton — 실 plugin wiring은 M2 sprint.
##
## 참조:
##   - docs/godot-setup-guide.md Step 6 (Google Play Console SKU 생성)
##   - docs/GDD.md §5.3 (IAP 정책)
class_name IapManager
extends Node

## SKU ID placeholders — Google Play Console에서 생성 후 실 ID로 교체.
const SKU_REMOVE_ADS: String = "remove_ads"
const SKU_COIN_PACK_SMALL: String = "coin_pack_small"
const SKU_COIN_PACK_MEDIUM: String = "coin_pack_medium"
const SKU_COIN_PACK_LARGE: String = "coin_pack_large"

## 구매 상태 캐시 (SaveManager와 sync).
var _purchases_owned: Dictionary = {}

func _ready() -> void:
	# TODO: M2 sprint 구현
	# - if Engine.has_singleton("GodotGooglePlayBilling"):
	#       GodotGooglePlayBilling.connected.connect(_on_billing_connected)
	#       GodotGooglePlayBilling.startConnection()
	# - else: push_warning("[IapManager] Google Play Billing plugin not installed")
	pass

## Remove Ads 구매 — 클라이언트 trigger.
func purchase_remove_ads() -> void:
	# TODO: M2 sprint 구현 — billing.purchase(SKU_REMOVE_ADS)
	pass

## 구매 복원 (앱 재설치 후 사용자 요청 시).
func restore_purchases() -> void:
	# TODO: M2 sprint 구현 — billing.queryPurchases()
	pass

## Remove Ads 구매 여부 query (AdsManager.set_banner_visible의 입력).
func is_remove_ads_owned() -> bool:
	return _purchases_owned.get(SKU_REMOVE_ADS, false)
