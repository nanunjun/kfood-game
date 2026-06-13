## protagonist_smoke.gd — Player-Chef Integration verification (2026-06-08).
## Choose-Your-Chef 재설계 (2026-06-12): 4 preset (f/m/leo/amara) × 4 emotion = 16.
##
## Runs headless. Covers:
##   1) ArtRegistry.get_protagonist resolves all 16 (preset × emotion) to existing res:// paths
##   2) Helper fallbacks: unknown preset → "f", unknown emotion → neutral (graceful)
##   3) PROTAGONIST_EMOTIONS / PROTAGONIST_PRESETS constants intact
##   4) SaveManager player_chef_preset field: default "", set/get (all 4), validation, has_chosen_chef
##   5) Backward-compat: a default save (no field) yields "" + has_chosen_chef()=false; legacy
##      "f"/"m" still valid; gender alias delegates to preset.
##
## Pure visual+save field — scoring/economy/CSV untouched. This locks the helper into regression.
extends Node

const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")

var _pass: int = 0
var _fail: int = 0


func _ready() -> void:
	print("=== Player-Chef Integration — smoke test ===")
	_test_helper_resolves_all_16()
	_test_helper_fallbacks()
	_test_constants()
	_test_save_field()
	_test_player_name_field()
	print("=== summary: %d PASS / %d FAIL ===" % [_pass, _fail])
	get_tree().quit()


func _test_helper_resolves_all_16() -> void:
	print("\n[1] get_protagonist resolves all 24 (6 preset × 4 emotion)")
	# preset → 파일 prefix (f/m = chef_f/chef_m 호환, leo/amara/min/ari = bare id).
	# Choose-Your-Chef 6 preset (2026-06-13): min/ari 추가.
	var prefix := {"f": "chef_f", "m": "chef_m", "leo": "leo", "amara": "amara", "min": "min", "ari": "ari"}
	for pset in ["f", "m", "leo", "amara", "min", "ari"]:
		for e in ["neutral", "cheer", "think", "cook"]:
			var p := ArtRegistry.get_protagonist(pset, e)
			var expected := "res://art/sprites/protagonist/%s_%s.png" % [prefix[pset], e]
			_assert("%s_%s path" % [prefix[pset], e], p, expected)
			_assert_true("%s_%s file exists" % [prefix[pset], e], ResourceLoader.exists(p))


func _test_helper_fallbacks() -> void:
	print("\n[2] helper graceful fallbacks")
	# unknown preset → "f"
	var p1 := ArtRegistry.get_protagonist("zzz", "neutral")
	_assert("unknown preset → f neutral", p1, "res://art/sprites/protagonist/chef_f_neutral.png")
	# unknown emotion → neutral (same preset)
	var p2 := ArtRegistry.get_protagonist("m", "zzz")
	_assert("unknown emotion → m neutral", p2, "res://art/sprites/protagonist/chef_m_neutral.png")
	var p2b := ArtRegistry.get_protagonist("leo", "zzz")
	_assert("unknown emotion → leo neutral", p2b, "res://art/sprites/protagonist/leo_neutral.png")
	# default emotion arg = neutral
	var p3 := ArtRegistry.get_protagonist("amara")
	_assert("default emotion = neutral (amara)", p3, "res://art/sprites/protagonist/amara_neutral.png")


func _test_constants() -> void:
	print("\n[3] PROTAGONIST constants")
	_assert("PROTAGONIST_EMOTIONS count", ArtRegistry.PROTAGONIST_EMOTIONS.size(), 4)
	_assert("PROTAGONIST_PRESETS count", ArtRegistry.PROTAGONIST_PRESETS.size(), 6)
	_assert_true("presets has leo", ArtRegistry.PROTAGONIST_PRESETS.has("leo"))
	_assert_true("presets has amara", ArtRegistry.PROTAGONIST_PRESETS.has("amara"))
	_assert_true("presets has min (new)", ArtRegistry.PROTAGONIST_PRESETS.has("min"))
	_assert_true("presets has ari (new)", ArtRegistry.PROTAGONIST_PRESETS.has("ari"))
	_assert_true("presets keeps f (backward-compat)", ArtRegistry.PROTAGONIST_PRESETS.has("f"))
	_assert_true("presets keeps m (backward-compat)", ArtRegistry.PROTAGONIST_PRESETS.has("m"))
	_assert_true("emotions has cheer", ArtRegistry.PROTAGONIST_EMOTIONS.has("cheer"))
	_assert_true("emotions has cook", ArtRegistry.PROTAGONIST_EMOTIONS.has("cook"))


func _test_save_field() -> void:
	print("\n[4] SaveManager player_chef_preset field (Choose-Your-Chef)")
	var sm := get_node_or_null("/root/SaveManager")
	if sm == null:
		_assert_true("SaveManager present", false)
		return
	sm.reset_progress()
	# default save → "" + not chosen (backward-compat shape)
	_assert("default player_chef_preset ''", sm.player_chef_preset(), "")
	_assert("default player_chef_gender alias ''", sm.player_chef_gender(), "")
	_assert_true("default has_chosen_chef false", not sm.has_chosen_chef())
	# set all 6 valid presets (f/m/leo/amara + new min/ari)
	for pset in ["f", "m", "leo", "amara", "min", "ari"]:
		sm.set_player_chef_preset(pset)
		_assert("set preset %s" % pset, sm.player_chef_preset(), pset)
		_assert("gender alias reads %s" % pset, sm.player_chef_gender(), pset)
		_assert_true("has_chosen_chef true after %s" % pset, sm.has_chosen_chef())
	# gender alias setter still works (backward-compat) and routes to preset slot
	sm.set_player_chef_gender("f")
	_assert("gender alias setter → f", sm.player_chef_preset(), "f")
	# invalid ignored
	sm.set_player_chef_preset("nope")
	_assert("invalid ignored (stays f)", sm.player_chef_preset(), "f")
	sm.set_player_chef_gender("xyz")
	_assert("invalid gender alias ignored (stays f)", sm.player_chef_preset(), "f")
	# scoring/economy untouched (seed money intact)
	_assert("economy untouched — seed money", sm.money(), sm.SEED_MONEY)
	sm.reset_progress()


func _test_player_name_field() -> void:
	print("\n[5] SaveManager player_name field (Player-Name Personalization)")
	var sm := get_node_or_null("/root/SaveManager")
	if sm == null:
		_assert_true("SaveManager present", false)
		return
	sm.reset_progress()
	# default → "" + not chosen + fallback display.
	_assert("default player_name ''", sm.player_name(), "")
	_assert_true("default has_player_name false", not sm.has_player_name())
	_assert("default display fallback 'My Chef'", sm.player_name_display(), "My Chef")
	# set valid (trim).
	_assert_true("set valid returns true", sm.set_player_name("  Suji  "))
	_assert("set trims to 'Suji'", sm.player_name(), "Suji")
	_assert_true("has_player_name true after set", sm.has_player_name())
	_assert("display returns input 'Suji'", sm.player_name_display(), "Suji")
	# blank/whitespace rejected, value unchanged.
	_assert_true("blank set returns false", not sm.set_player_name("   "))
	_assert("blank keeps 'Suji'", sm.player_name(), "Suji")
	# length clamp 12.
	sm.set_player_name("Abcdefghijklmnop")  # 16 chars
	_assert_true("name clamped <= 12", sm.player_name().length() <= 12)
	# internal whitespace squash.
	_assert_true("squash set returns true", sm.set_player_name("Big   Boss"))
	_assert("squash single space 'Big Boss'", sm.player_name(), "Big Boss")
	# sanitize static helper directly.
	_assert("sanitize empty -> ''", sm.sanitize_player_name("   "), "")
	# economy/scoring untouched.
	_assert("economy untouched after name ops", sm.money(), sm.SEED_MONEY)
	sm.reset_progress()


# --- assert helpers ---
func _assert(label: String, got, expected) -> void:
	var ok: bool = got == expected
	if ok:
		_pass += 1
	else:
		_fail += 1
	print("  [%s] %s  (got=%s expected=%s)" % ["PASS" if ok else "FAIL", label, str(got), str(expected)])


func _assert_true(label: String, cond: bool) -> void:
	if cond:
		_pass += 1
	else:
		_fail += 1
	print("  [%s] %s" % ["PASS" if cond else "FAIL", label])
