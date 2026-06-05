## save_migration_test.gd — explicit v1->v2 migration verification.
##
## Writes a fake v1 save file (intimacy only, no friendship, version=1) directly to
## user://kfood_save.json, then triggers SaveManager._load() to confirm:
##   - version is bumped to 2
##   - friendship dict is populated (projected from intimacy *2)
##   - intimacy values are preserved
extends Node

func _ready() -> void:
	print("=== SaveManager v1 -> v2 migration test ===")
	_seed_v1_save()
	# force a reload by reinstantiating data through autoload's _load()
	var sm := get_node_or_null("/root/SaveManager")
	if sm == null:
		push_error("SaveManager missing"); get_tree().quit(); return
	# call _load() (private — accessible via callv since same script)
	sm.callv("_load", [])
	_assert("post-load version == 2", int(sm.data.get("version", 0)), 2)
	_assert_f("intimacy[junho] preserved", float(sm.data["intimacy"].get("junho", -1)), 2.5)
	# 2.5 * 2 = 5 friendship
	_assert("friendship[junho] = 5 (projected from intimacy 2.5)", sm.friendship_of("junho"), 5)
	_assert("friendship[mina] = 8 (projected from intimacy 4.0)", sm.friendship_of("mina"), 8)
	# clean up
	sm.reset_progress()
	print("=== done ===")
	get_tree().quit()


func _seed_v1_save() -> void:
	var v1: Dictionary = {
		"version": 1,
		"level": 3,
		"money": 12000,
		"clears_at_level": 2,
		"reputation": {"home": 5, "noryangjin": 0, "gwangjang": 0},
		"stock": {"t1_002": 2, "t1_004": 3},
		"unlocks": {"markets": ["home", "noryangjin"]},
		"stats": {"plays": 8, "passes": 6, "best_stars": {"t1_002": 4, "t1_004": 3}, "total_stars": 7},
		"intimacy": {"junho": 2.5, "mina": 4.0, "riley": 0.5},
		"player_char": "",
		"settings": {"haptics": true, "volume": 1.0, "subtitle_kr": false},
	}
	var f := FileAccess.open("user://kfood_save.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(v1, "\t"))
	f.close()
	print("[seed] wrote v1 save (intimacy junho=2.5, mina=4.0, riley=0.5)")


func _assert(label: String, got, expected) -> void:
	var ok: bool = got == expected
	var tag: String = "PASS" if ok else "FAIL"
	print("  [%s] %s  (got=%s expected=%s)" % [tag, label, str(got), str(expected)])


func _assert_f(label: String, got: float, expected: float) -> void:
	var ok: bool = absf(got - expected) < 0.01
	var tag: String = "PASS" if ok else "FAIL"
	print("  [%s] %s  (got=%.4f expected=%.4f)" % [tag, label, got, expected])
