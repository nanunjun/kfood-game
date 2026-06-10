## protagonist_smoke.gd — Player-Chef Integration verification (2026-06-08).
##
## Runs headless. Covers:
##   1) ArtRegistry.get_protagonist resolves all 8 (gender × emotion) to existing res:// paths
##   2) Helper fallbacks: unknown gender → "f", unknown emotion → neutral (graceful)
##   3) PROTAGONIST_EMOTIONS / PROTAGONIST_GENDERS constants intact
##   4) SaveManager player_chef_gender field: default "", set/get, validation, has_chosen_chef
##   5) Backward-compat: a default save (no field) yields "" + has_chosen_chef()=false
##
## Pure visual+save field — scoring/economy/CSV untouched. This locks the helper into regression.
extends Node

const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")

var _pass: int = 0
var _fail: int = 0


func _ready() -> void:
	print("=== Player-Chef Integration — smoke test ===")
	_test_helper_resolves_all_8()
	_test_helper_fallbacks()
	_test_constants()
	_test_save_field()
	_test_player_name_field()
	print("=== summary: %d PASS / %d FAIL ===" % [_pass, _fail])
	get_tree().quit()


func _test_helper_resolves_all_8() -> void:
	print("\n[1] get_protagonist resolves all 8 (gender × emotion)")
	for g in ["f", "m"]:
		for e in ["neutral", "cheer", "think", "cook"]:
			var p := ArtRegistry.get_protagonist(g, e)
			var expected := "res://art/sprites/protagonist/chef_%s_%s.png" % [g, e]
			_assert("chef_%s_%s path" % [g, e], p, expected)
			_assert_true("chef_%s_%s file exists" % [g, e], ResourceLoader.exists(p))


func _test_helper_fallbacks() -> void:
	print("\n[2] helper graceful fallbacks")
	# unknown gender → "f"
	var p1 := ArtRegistry.get_protagonist("zzz", "neutral")
	_assert("unknown gender → f neutral", p1, "res://art/sprites/protagonist/chef_f_neutral.png")
	# unknown emotion → neutral (same gender)
	var p2 := ArtRegistry.get_protagonist("m", "zzz")
	_assert("unknown emotion → m neutral", p2, "res://art/sprites/protagonist/chef_m_neutral.png")
	# default emotion arg = neutral
	var p3 := ArtRegistry.get_protagonist("f")
	_assert("default emotion = neutral", p3, "res://art/sprites/protagonist/chef_f_neutral.png")


func _test_constants() -> void:
	print("\n[3] PROTAGONIST constants")
	_assert("PROTAGONIST_EMOTIONS count", ArtRegistry.PROTAGONIST_EMOTIONS.size(), 4)
	_assert("PROTAGONIST_GENDERS count", ArtRegistry.PROTAGONIST_GENDERS.size(), 2)
	_assert_true("emotions has cheer", ArtRegistry.PROTAGONIST_EMOTIONS.has("cheer"))
	_assert_true("emotions has cook", ArtRegistry.PROTAGONIST_EMOTIONS.has("cook"))


func _test_save_field() -> void:
	print("\n[4] SaveManager player_chef_gender field")
	var sm := get_node_or_null("/root/SaveManager")
	if sm == null:
		_assert_true("SaveManager present", false)
		return
	sm.reset_progress()
	# default save → "" + not chosen (backward-compat shape)
	_assert("default player_chef_gender ''", sm.player_chef_gender(), "")
	_assert_true("default has_chosen_chef false", not sm.has_chosen_chef())
	# set valid
	sm.set_player_chef_gender("f")
	_assert("set f", sm.player_chef_gender(), "f")
	_assert_true("has_chosen_chef true after f", sm.has_chosen_chef())
	sm.set_player_chef_gender("m")
	_assert("set m", sm.player_chef_gender(), "m")
	# invalid ignored
	sm.set_player_chef_gender("nope")
	_assert("invalid ignored (stays m)", sm.player_chef_gender(), "m")
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
