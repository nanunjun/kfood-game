## result_v2_smoke.gd — Result Screen 2.0 unit + integration verification.
##
## Runs:
##   1) Regression of Guest 2.0 compat cases (kimchi+Junho, gimbap+Mina)
##   2) SaveManager records + recipe_xp API (incl. backward compat with v1 save)
##   3) RewardCalc.emotion_level matrix
##   4) RewardCalc.score_breakdown_rows shape
##   5) ReactionDB.generate_text examples (Mina spicy / Junho savory)
##
## Designed to be used with:
##   godot --headless --quit-after 4 res://scenes/result_v2_smoke.tscn
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")

var _pass: int = 0
var _fail: int = 0


func _ready() -> void:
	print("=== Result Screen 2.0 — smoke test ===")
	_compat_regression()
	_save_records_and_xp()
	_emotion_levels()
	_breakdown_shape()
	_reaction_examples()
	_recipe_xp_curve()
	print("=== summary: %d PASS / %d FAIL ===" % [_pass, _fail])
	get_tree().quit()


# --- 1. Compat regression (existing Guest 2.0 cases — should still be 19+ pass) ---
func _compat_regression() -> void:
	print("\n[1] Compat regression")
	var cc := get_node_or_null("/root/CompatCalc")
	if cc == null:
		_fail_msg("CompatCalc missing"); return
	var menu_kj: Dictionary = MenuDB.get_menu("m_kimchi_jjigae")
	var junho: Dictionary = MenuDB.get_guest("junho")
	_assert("kimchi_jjigae + Junho (happy) == 93", cc.score(menu_kj, junho, "happy"), 93)
	var menu_gb: Dictionary = MenuDB.get_menu("t1_004")
	var mina: Dictionary = MenuDB.get_guest("mina")
	_assert("gimbap + Mina (easy) == 62", cc.score(menu_gb, mina, "easy"), 62)
	var menu_tb: Dictionary = MenuDB.get_menu("t1_003")
	_assert("tteokbokki + Junho (hungry) == 49", cc.score(menu_tb, junho, "hungry"), 49)


# --- 2. SaveManager records + recipe_xp + backward compat ---
func _save_records_and_xp() -> void:
	print("\n[2] SaveManager: records + recipe_xp")
	var sm := get_node_or_null("/root/SaveManager")
	if sm == null:
		_fail_msg("SaveManager missing"); return
	sm.reset_progress()
	# fresh save should have empty records + recipe_xp dicts
	_assert("records dict exists", typeof(sm.data.get("records", null)), TYPE_DICTIONARY)
	_assert("recipe_xp dict exists", typeof(sm.data.get("recipe_xp", null)), TYPE_DICTIONARY)
	# record_of returns 0 for unknown pair
	_assert("record_of unknown == 0", sm.record_of("t1_002", "junho"), 0)
	# first round always breaks (prev = -1 internal)
	_assert_bool("first round sets record (check_record true)",
		sm.check_record("t1_002", "junho", 7500))
	_assert("record_of after set == 7500", sm.record_of("t1_002", "junho"), 7500)
	# lower score does NOT break
	_assert_bool_false("lower score does not break (check_record false)",
		sm.check_record("t1_002", "junho", 6000))
	_assert("record unchanged at 7500", sm.record_of("t1_002", "junho"), 7500)
	# higher score does break
	_assert_bool("higher score breaks (8800)",
		sm.check_record("t1_002", "junho", 8800))
	_assert("record bumped to 8800", sm.record_of("t1_002", "junho"), 8800)
	# different guest -> independent record
	_assert("record_of different guest = 0", sm.record_of("t1_002", "mina"), 0)
	# recipe_xp accumulation
	_assert("recipe_xp_of new menu = 0", sm.recipe_xp_of("t1_002"), 0)
	var v1: int = sm.add_recipe_xp("t1_002", 26)
	_assert("add_recipe_xp 26 -> 26", v1, 26)
	var v2: int = sm.add_recipe_xp("t1_002", 30)
	_assert("add_recipe_xp +30 -> 56", v2, 56)
	# backward compat: simulate v2 save with no records/recipe_xp
	_seed_v2_without_new_dicts()
	sm.callv("_load", [])
	_assert("backward compat: records dict auto-added", typeof(sm.data.get("records", null)), TYPE_DICTIONARY)
	_assert("backward compat: recipe_xp dict auto-added", typeof(sm.data.get("recipe_xp", null)), TYPE_DICTIONARY)
	_assert("backward compat: friendship preserved (junho=4)", sm.friendship_of("junho"), 4)
	sm.reset_progress()


func _seed_v2_without_new_dicts() -> void:
	var v2: Dictionary = {
		"version": 2,
		"level": 2,
		"money": 8000,
		"clears_at_level": 1,
		"reputation": {"home": 3, "noryangjin": 0, "gwangjang": 0},
		"stock": {"t1_002": 2},
		"unlocks": {"markets": ["home"]},
		"stats": {"plays": 3, "passes": 2, "best_stars": {"t1_002": 3}, "total_stars": 3},
		"intimacy": {"junho": 2.0},
		"friendship": {"junho": 4},
		"player_char": "",
		"settings": {"haptics": true, "volume": 1.0, "subtitle_kr": false},
	}
	var f := FileAccess.open("user://kfood_save.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(v2, "\t"))
	f.close()


# --- 3. RewardCalc.emotion_level ---
func _emotion_levels() -> void:
	print("\n[3] RewardCalc.emotion_level")
	var rc := get_node_or_null("/root/RewardCalc")
	if rc == null:
		_fail_msg("RewardCalc missing"); return
	# game-designer rule:
	#   excellent = (stars>=3 AND compat>=70) OR compat>=90
	#   good      = stars>=3 OR (70~89)
	#   okay      = stars>=2 OR (50~69)
	#   bad       = else
	_assert("3*+93 -> excellent", rc.emotion_level(3, 93), "excellent")
	_assert("1*+95 -> excellent (compat>=90)", rc.emotion_level(1, 95), "excellent")
	_assert("4*+75 -> excellent (3*+70+)", rc.emotion_level(4, 75), "excellent")
	_assert("3*+50 -> good (stars>=3)", rc.emotion_level(3, 50), "good")
	_assert("2*+62 -> okay (stars>=2)", rc.emotion_level(2, 62), "okay")
	_assert("1*+30 -> bad", rc.emotion_level(1, 30), "bad")


# --- 4. RewardCalc.score_breakdown_rows shape ---
func _breakdown_shape() -> void:
	print("\n[4] RewardCalc.score_breakdown_rows")
	var rc := get_node_or_null("/root/RewardCalc")
	if rc == null:
		_fail_msg("RewardCalc missing"); return
	var junho: Dictionary = MenuDB.get_guest("junho")
	var rows: Array = rc.score_breakdown_rows(0.85, 0.72, 0.91, 1.0, 93, "happy", junho)
	_assert("6 rows", rows.size(), 6)
	_assert("row 0 key = prep", String(rows[0].get("key", "")), "prep")
	_assert("row 1 key = cook", String(rows[1].get("key", "")), "cook")
	_assert("row 2 key = season", String(rows[2].get("key", "")), "season")
	_assert("row 3 key = plating", String(rows[3].get("key", "")), "plating")
	_assert("row 4 key = compat_bonus", String(rows[4].get("key", "")), "compat_bonus")
	_assert("row 5 key = mood_modifier", String(rows[5].get("key", "")), "mood_modifier")
	# prep 0.85 -> 85
	_assert("row 0 value_pct = 85", int(rows[0].get("value_pct", 0)), 85)
	# compat 93 -> mult 1.30 -> +30
	_assert("compat_bonus value = +30", int(rows[4].get("value_pct", 0)), 30)


# --- 5. ReactionDB.generate_text ---
func _reaction_examples() -> void:
	print("\n[5] ReactionDB.generate_text")
	var db := get_node_or_null("/root/ReactionDB")
	if db == null:
		_fail_msg("ReactionDB missing"); return
	# Mina + tteokbokki — sweet+spicy+savory. Mina favs={sweet,savory,oily}.
	# stars=3, compat=80 (synthetic) -> excellent.
	var mina: Dictionary = MenuDB.get_guest("mina")
	var tteok: Dictionary = MenuDB.get_menu("t1_003")
	var line_mina: String = db.generate_text(mina, tteok, 3, 95, "happy")
	print("  [Mina/tteokbokki/3*/95] %s" % line_mina)
	_assert_bool("Mina line not empty", line_mina.length() > 0)
	_assert_bool("Mina line contains 'Mina'", line_mina.contains("Mina"))
	# Junho + kimchi_jjigae spicy match -> excellent
	var junho: Dictionary = MenuDB.get_guest("junho")
	var kj: Dictionary = MenuDB.get_menu("m_kimchi_jjigae")
	var line_junho: String = db.generate_text(junho, kj, 3, 93, "happy")
	print("  [Junho/kimchi_jjigae/3*/93] %s" % line_junho)
	_assert_bool("Junho line contains 'Junho'", line_junho.contains("Junho"))
	# Riley + gimbap mild — likely "okay" / "good"
	var riley: Dictionary = MenuDB.get_guest("riley")
	var gb: Dictionary = MenuDB.get_menu("t1_004")
	var line_riley: String = db.generate_text(riley, gb, 2, 60, "easy")
	print("  [Riley/gimbap/2*/60] %s" % line_riley)
	_assert_bool("Riley line non-empty", line_riley.length() > 0)
	# verify placeholders are gone
	for s in [line_mina, line_junho, line_riley]:
		_assert_bool_false("no leftover {placeholder} in [%s]" % s.left(30),
			s.contains("{"))


# --- 6. RecipeXP curve sanity ---
func _recipe_xp_curve() -> void:
	print("\n[6] RecipeXP curve")
	var rx := get_node_or_null("/root/RecipeXP")
	if rx == null:
		_fail_msg("RecipeXP missing"); return
	_assert("Lv 1 at 0 XP", rx.level_of(0), 1)
	_assert("Lv 1 at 29 XP", rx.level_of(29), 1)
	_assert("Lv 2 at 30 XP", rx.level_of(30), 2)
	_assert("Lv 2 at 89 XP", rx.level_of(89), 2)
	_assert("Lv 3 at 90 XP", rx.level_of(90), 3)
	_assert("Lv 10 at 1360 XP", rx.level_of(1360), 10)
	_assert("Lv 10 at 9999 XP (clamp)", rx.level_of(9999), 10)
	# xp_gain: stars=3, compat=93, new_record=true -> 10*3 + 9 + 20 = 59
	_assert("xp_gain(3, 93, true) == 59", rx.xp_gain(3, 93, true), 59)
	# stars=2, compat=62, no record -> 20 + 6 + 0 = 26
	_assert("xp_gain(2, 62, false) == 26", rx.xp_gain(2, 62, false), 26)


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


func _assert_bool_false(label: String, got: bool) -> void:
	if not got: _pass += 1
	else:       _fail += 1
	print("  [%s] %s" % [("PASS" if not got else "FAIL"), label])


func _fail_msg(s: String) -> void:
	_fail += 1
	print("  [FAIL] %s" % s)
