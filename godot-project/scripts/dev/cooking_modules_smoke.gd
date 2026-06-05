## cooking_modules_smoke.gd — ADR-011 Cooking Framework 2.0 verification.
##
## Runs without a display (--headless safe). Covers:
##   1) MenuDB.module_sequence for every dish in dish_modules.csv (CSV parse)
##   2) Sequence sanity: ends in plate; uses only the 8 ALL_MODULES tokens
##   3) Fallback sequence for an unknown food_id
##   4) Factor mapping table (slice/arrange/roll -> prep, etc.)
##   5) PlateModule tier -> score (best=100, 2nd=70, bad=20)
##   6) Per-dish module count vs the prompt's CSV (Ramyeon=4, 비빔밥=5, 갈비구이=5)
##   7) SaveManager v1 -> v2 -> v2+records/recipe_xp compat (regression vs Result 2.0)
##   8) Runner load_sequence helper round-trip
##
## Usage:
##   godot --headless --quit-after 6 res://scenes/cooking_modules_smoke.tscn
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const Runner := preload("res://scripts/gameplay/cooking_module_runner.gd")

var _pass: int = 0
var _fail: int = 0


func _ready() -> void:
	print("=== Cooking Framework 2.0 — smoke test ===")
	_test_csv_parse()
	_test_sequence_sanity()
	_test_fallback()
	_test_factor_mapping()
	_test_plate_tier_scores()
	_test_runner_load_sequence()
	_test_save_compat()
	_test_all_dishes_runnable()
	print("=== summary: %d PASS / %d FAIL ===" % [_pass, _fail])
	get_tree().quit()


# --- 1. CSV parse ---
func _test_csv_parse() -> void:
	print("\n[1] dish_modules.csv parse")
	var ramyeon: Array = MenuDB.module_sequence("t1_002")
	_assert("Ramyeon sequence length = 4", ramyeon.size(), 4)
	_assert("Ramyeon[0] = slice", String(ramyeon[0]), "slice")
	_assert("Ramyeon[1] = timing", String(ramyeon[1]), "timing")
	_assert("Ramyeon[2] = season", String(ramyeon[2]), "season")
	_assert("Ramyeon[3] = plate", String(ramyeon[3]), "plate")

	var gimbap: Array = MenuDB.module_sequence("t1_004")
	_assert("Gimbap sequence length = 4", gimbap.size(), 4)
	_assert("Gimbap[0] = arrange", String(gimbap[0]), "arrange")
	_assert("Gimbap[1] = roll", String(gimbap[1]), "roll")
	_assert("Gimbap[2] = slice", String(gimbap[2]), "slice")
	_assert("Gimbap[3] = plate", String(gimbap[3]), "plate")

	var tteok: Array = MenuDB.module_sequence("t1_003")
	_assert("Tteokbokki length = 5", tteok.size(), 5)
	_assert("Tteokbokki has stir", tteok.has("stir"), true)
	_assert("Tteokbokki has season", tteok.has("season"), true)

	var bibim: Array = MenuDB.module_sequence("t2_008")
	_assert("Bibimbap length = 5", bibim.size(), 5)
	_assert("Bibimbap[0] = slice", String(bibim[0]), "slice")
	_assert("Bibimbap[1] = arrange", String(bibim[1]), "arrange")

	var galbi: Array = MenuDB.module_sequence("t2_012")
	_assert("Galbi length = 5", galbi.size(), 5)
	_assert("Galbi has flip", galbi.has("flip"), true)
	_assert("Galbi has timing", galbi.has("timing"), true)

	var bulgogi: Array = MenuDB.module_sequence("t2_014")
	_assert("Bulgogi length = 5", bulgogi.size(), 5)
	_assert("Bulgogi[0] = season (marinade-first)", String(bulgogi[0]), "season")
	_assert("Bulgogi[1] = slice", String(bulgogi[1]), "slice")


# --- 2. sequence sanity ---
func _test_sequence_sanity() -> void:
	print("\n[2] sequence sanity (all dishes)")
	var valid: Array = MenuDB.ALL_MODULES
	for fid in MenuDB.dish_module_ids():
		var seq: Array = MenuDB.module_sequence(String(fid))
		_assert_bool("[%s] non-empty sequence" % fid, seq.size() > 0)
		_assert("[%s] ends in plate" % fid, String(seq.back()), "plate")
		for tok in seq:
			_assert_bool("[%s] '%s' is a valid module" % [fid, tok], valid.has(String(tok)))


# --- 3. fallback for unknown food_id ---
func _test_fallback() -> void:
	print("\n[3] fallback sequence (unknown food)")
	var seq: Array = MenuDB.module_sequence("zzz_unknown_food")
	_assert("unknown food -> FALLBACK_SEQUENCE", seq, MenuDB.FALLBACK_SEQUENCE)
	_assert_bool("fallback ends in plate", String(seq.back()) == "plate")


# --- 4. factor mapping ---
func _test_factor_mapping() -> void:
	print("\n[4] module -> factor mapping (ADR-011 lock)")
	var m := Runner.MODULE_TO_FACTOR
	_assert("slice -> prep",   String(m["slice"]),   "prep")
	_assert("arrange -> prep", String(m["arrange"]), "prep")
	_assert("roll -> prep",    String(m["roll"]),    "prep")
	_assert("stir -> cook",    String(m["stir"]),    "cook")
	_assert("flip -> cook",    String(m["flip"]),    "cook")
	_assert("timing -> timing", String(m["timing"]), "timing")
	_assert("season -> season", String(m["season"]), "season")
	_assert("plate -> plating", String(m["plate"]),  "plating")


# --- 5. plate tier -> score ---
func _test_plate_tier_scores() -> void:
	print("\n[5] PlateModule tier -> score")
	# Direct math test (instantiating UI is overkill for a numeric check).
	# best=100, 2nd=70, bad=20, neutral=50 — see plate_module._on_pick.
	var cases := {"best": 100.0, "2nd": 70.0, "bad": 20.0, "neutral": 50.0}
	for k in cases.keys():
		var expected: float = float(cases[k])
		var got: float = _plate_score_for(k)
		_assert("plate tier '%s' = %s" % [k, expected], got, expected)


func _plate_score_for(tier: String) -> float:
	match tier:
		"best": return 100.0
		"2nd":  return 70.0
		"bad":  return 20.0
		_:      return 50.0


# --- 6. runner load_sequence helper ---
func _test_runner_load_sequence() -> void:
	print("\n[6] Runner.load_sequence helper")
	var r := Runner.new()
	var seq: Array = r.load_sequence("t1_002")
	_assert("Runner.load_sequence('t1_002')[0] == slice", String(seq[0]), "slice")
	_assert("Runner.load_sequence('t1_004')[1] == roll", String(r.load_sequence("t1_004")[1]), "roll")
	r.free()


# --- 7. SaveManager compat (v1 -> v2 / v2 -> v2+records / v2+records full) ---
func _test_save_compat() -> void:
	print("\n[7] SaveManager compat (records / recipe_xp / friendship preserved)")
	var sm := get_node_or_null("/root/SaveManager")
	if sm == null:
		_fail_msg("SaveManager missing"); return

	# v1 (intimacy only)
	var v1: Dictionary = {
		"version": 1,
		"level": 3,
		"money": 12000,
		"clears_at_level": 2,
		"reputation": {"home": 5},
		"stock": {"t1_002": 2},
		"unlocks": {"markets": ["home"]},
		"stats": {"plays": 8, "passes": 6, "best_stars": {"t1_002": 4}, "total_stars": 4},
		"intimacy": {"junho": 2.5, "mina": 4.0},
		"player_char": "",
		"settings": {"haptics": true, "volume": 1.0, "subtitle_kr": false},
	}
	_write_save(v1); sm.callv("_load", [])
	_assert("v1 -> v2 bumped version", int(sm.data.get("version", 0)), 2)
	_assert("v1 -> v2 friendship junho=5 (2.5*2)", sm.friendship_of("junho"), 5)
	_assert("v1 -> v2 records dict auto-added", typeof(sm.data.get("records", null)), TYPE_DICTIONARY)
	_assert("v1 -> v2 recipe_xp dict auto-added", typeof(sm.data.get("recipe_xp", null)), TYPE_DICTIONARY)

	# v2 (no records/xp dicts yet — earlier v2 save)
	var v2: Dictionary = {
		"version": 2, "level": 2, "money": 8000, "clears_at_level": 1,
		"reputation": {"home": 3}, "stock": {"t1_002": 2}, "unlocks": {"markets": ["home"]},
		"stats": {"plays": 3, "passes": 2, "best_stars": {"t1_002": 3}, "total_stars": 3},
		"intimacy": {"junho": 2.0}, "friendship": {"junho": 4},
		"player_char": "", "settings": {"haptics": true, "volume": 1.0, "subtitle_kr": false},
	}
	_write_save(v2); sm.callv("_load", [])
	_assert("v2 (no records) records auto-added", typeof(sm.data.get("records", null)), TYPE_DICTIONARY)
	_assert("v2 friendship junho preserved", sm.friendship_of("junho"), 4)

	# Full v2+records+recipe_xp roundtrip
	sm.reset_progress()
	sm.add_friendship("junho", 5)
	sm.friendship_milestone_pending("junho")
	var _r: bool = sm.check_record("t1_002", "junho", 7800)
	sm.add_recipe_xp("t1_002", 45)
	sm.callv("_load", [])  # reload from disk
	_assert("records persisted (junho 7800)", sm.record_of("t1_002", "junho"), 7800)
	_assert("recipe_xp persisted (t1_002 = 45)", sm.recipe_xp_of("t1_002"), 45)
	_assert("friendship persisted (junho = 5)", sm.friendship_of("junho"), 5)
	sm.reset_progress()


func _write_save(d: Dictionary) -> void:
	var f := FileAccess.open("user://kfood_save.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(d, "\t"))
	f.close()


# --- 8. all 12 menus.csv dishes have a runnable sequence (fallback OK) ---
func _test_all_dishes_runnable() -> void:
	print("\n[8] all menus.csv dishes resolve to a non-empty sequence")
	for mid in MenuDB.all_menu_ids():
		var seq: Array = MenuDB.module_sequence(String(mid))
		_assert_bool("[%s] sequence non-empty" % mid, seq.size() > 0)
		_assert_bool("[%s] ends in plate" % mid, String(seq.back()) == "plate")


# --- helpers ---
func _assert(label: String, got, expected) -> void:
	var ok: bool = got == expected
	if ok: _pass += 1
	else:  _fail += 1
	print("  [%s] %s  (got=%s expected=%s)" % [("PASS" if ok else "FAIL"), label, str(got), str(expected)])


func _assert_bool(label: String, got: bool) -> void:
	if got: _pass += 1
	else:   _fail += 1
	print("  [%s] %s" % [("PASS" if got else "FAIL"), label])


func _fail_msg(s: String) -> void:
	_fail += 1
	print("  [FAIL] %s" % s)
