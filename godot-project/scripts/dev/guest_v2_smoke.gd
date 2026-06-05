## guest_v2_smoke.gd — headless verification for Guest System 2.0.
##
## Runs spec example cases and prints PASS/FAIL. Designed to be used with:
##   godot --headless --quit-after 3 res://scenes/guest_v2_smoke.tscn
##
## Verifies (game-designer locked):
##   - 김치찌개 + Junho (happy) -> compat 93
##   - 김밥 + Mina (easy) -> compat 62
##   - SaveManager v2 friendship API + milestone toast queue
##   - RewardCalc.bonus_multiplier thresholds
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")


func _ready() -> void:
	print("=== Guest System 2.0 — smoke test ===")
	_run_compat_cases()
	_run_save_migration()
	_run_reward_thresholds()
	_run_mood_determinism()
	print("=== done ===")
	get_tree().quit()


func _run_compat_cases() -> void:
	var cc := get_node_or_null("/root/CompatCalc")
	if cc == null:
		push_error("CompatCalc autoload missing"); return
	# spec case 1: kimchi jjigae (spicy|salty|umami|fermented|hearty) + Junho happy
	# fav={spicy,salty,hearty} -> hit_fav=3, dis={sweet,bitter} -> hit_dis=0
	# happy: mf=1.2, md=1.0
	# fav_score = 3 * 12 * 1.2 = 43.2 ; dis_score = 0
	# compat = 50 + 43 - 0 = 93
	var menu_kj: Dictionary = MenuDB.get_menu("m_kimchi_jjigae")
	var junho: Dictionary = MenuDB.get_guest("junho")
	var c1: int = cc.score(menu_kj, junho, "happy")
	_assert("kimchi_jjigae + Junho (happy) == 93", c1, 93)

	# spec case 2: gimbap (mild|salty|savory|fresh) + Mina easy
	# Mina fav={sweet,savory,oily} -> hit_fav=1(savory)
	# Mina dis={bitter,sour} -> hit_dis=0
	# easy: mf=1.0, md=0.7
	# fav_score = 1 * 12 * 1.0 = 12 ; dis_score = 0
	# compat = 50 + 12 - 0 = 62
	var menu_gb: Dictionary = MenuDB.get_menu("t1_004")
	var mina: Dictionary = MenuDB.get_guest("mina")
	var c2: int = cc.score(menu_gb, mina, "easy")
	_assert("gimbap + Mina (easy) == 62", c2, 62)

	# extra sanity: tteokbokki + Junho hungry (spicy|sweet|savory, fav=spicy/salty/hearty, dis=sweet/bitter)
	# hit_fav=1, hit_dis=1, hungry mf=1.3 md=0.9 -> 50 + 1*12*1.3 - 1*18*0.9 = 50+15.6-16.2 = 49.4 -> 49
	var menu_tb: Dictionary = MenuDB.get_menu("t1_003")
	var c3: int = cc.score(menu_tb, junho, "hungry")
	_assert("tteokbokki + Junho (hungry) == 49", c3, 49)


func _run_save_migration() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm == null:
		push_error("SaveManager autoload missing"); return
	# fresh wipe
	if sm.has_method("reset_progress"):
		sm.reset_progress()
	# version should now be 2
	_assert("SaveManager schema version == 2", int(sm.data.get("version", 0)), 2)
	# add_friendship API
	var v1: int = sm.add_friendship("junho", 3)
	_assert("add_friendship +3 from 0 -> 3", v1, 3)
	var ms: int = sm.friendship_milestone_pending("junho")
	_assert("milestone 3 pending after crossing 3", ms, 3)
	var ms2: int = sm.friendship_milestone_pending("junho")
	_assert("milestone consumed (now 0)", ms2, 0)
	# crossing 7
	sm.add_friendship("junho", 4)  # 3 -> 7
	_assert("milestone 7 pending", sm.friendship_milestone_pending("junho"), 7)
	# clamping
	sm.add_friendship("junho", 99)
	_assert("friendship clamped at 10", sm.friendship_of("junho"), 10)
	# milestone 10
	_assert("milestone 10 pending", sm.friendship_milestone_pending("junho"), 10)
	# legacy intimacy projection (friendship 10 -> intimacy 5.0)
	_assert_f("legacy intimacy synced (10 -> 5.0)", sm.intimacy_of("junho"), 5.0)


func _run_reward_thresholds() -> void:
	var rc := get_node_or_null("/root/RewardCalc")
	if rc == null:
		push_error("RewardCalc autoload missing"); return
	_assert_f("compat 95 mult 1.30", rc.bonus_multiplier(95), 1.30)
	_assert_f("compat 80 mult 1.15", rc.bonus_multiplier(80), 1.15)
	_assert_f("compat 60 mult 1.00", rc.bonus_multiplier(60), 1.00)
	_assert_f("compat 40 mult 0.85", rc.bonus_multiplier(40), 0.85)
	_assert_f("compat 10 mult 0.70", rc.bonus_multiplier(10), 0.70)
	# final reward example: base=10000, compat=93, Junho.reward_bonus=1.20
	# = 10000 * 1.20 * 1.30 = 15600
	var junho: Dictionary = MenuDB.get_guest("junho")
	var rew: int = rc.final(10000, 93, junho)
	_assert("reward final(10000, 93, Junho) == 15600", rew, 15600)


func _run_mood_determinism() -> void:
	var ms := get_node_or_null("/root/MoodSystem")
	if ms == null:
		push_error("MoodSystem autoload missing"); return
	# determinism: same call twice -> same mood
	var m1: String = ms.today("junho")
	var m2: String = ms.today("junho")
	_assert("mood deterministic for junho", m1, m2)
	# mood is in the guest's pool
	var pool: Array = MenuDB.get_guest("junho").get("mood_pool", []) as Array
	var ok: bool = pool.has(m1)
	_assert_bool("junho mood is in mood_pool", ok)
	print("[mood] junho=%s mina=%s riley=%s mrs_lee=%s seoyeon=%s mother_01=%s father_01=%s" % [
		ms.today("junho"), ms.today("mina"), ms.today("riley"),
		ms.today("mrs_lee"), ms.today("seoyeon"),
		ms.today("mother_01"), ms.today("father_01")])


func _assert(label: String, got, expected) -> void:
	var ok: bool = got == expected
	var tag: String = "PASS" if ok else "FAIL"
	print("  [%s] %s  (got=%s expected=%s)" % [tag, label, str(got), str(expected)])


func _assert_f(label: String, got: float, expected: float) -> void:
	var ok: bool = absf(got - expected) < 0.01
	var tag: String = "PASS" if ok else "FAIL"
	print("  [%s] %s  (got=%.4f expected=%.4f)" % [tag, label, got, expected])


func _assert_bool(label: String, got: bool) -> void:
	var tag: String = "PASS" if got else "FAIL"
	print("  [%s] %s" % [tag, label])
