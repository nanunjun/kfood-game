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
	# Player-Chef Integration (2026-06-08): 기존 save(player_chef_gender 필드 없음)가 backward-
	# compatible하게 로드되는지 — _merge로 default "" 유지 + has_chosen_chef()=false.
	_assert("player_chef_gender backward-compat default ''", sm.player_chef_gender(), "")
	_assert("has_chosen_chef() false on legacy save", sm.has_chosen_chef(), false)
	# Player-Name Personalization (2026-06-08): legacy save(player_name 필드 없음)가 backward-
	# compatible하게 로드 — _merge로 default "" 유지 → has_player_name()=false → name entry 1회 진입.
	_assert("player_name backward-compat default ''", sm.player_name(), "")
	_assert("has_player_name() false on legacy save", sm.has_player_name(), false)
	_assert("player_name_display fallback 'My Chef'", sm.player_name_display(), "My Chef")
	# 기존 progression 무변경 확인 (level/money/stock 보존).
	_assert("legacy level preserved (3)", int(sm.data.get("level", 0)), 3)
	_assert("legacy money preserved (12000)", int(sm.data.get("money", 0)), 12000)
	# set + reload round-trip: 선택 저장 후 has_chosen_chef true. (legacy gender alias path)
	sm.set_player_chef_gender("m")
	sm.callv("_load", [])
	_assert("player_chef_gender persists across reload ('m')", sm.player_chef_gender(), "m")
	_assert("has_chosen_chef() true after select", sm.has_chosen_chef(), true)
	# invalid gender ignored.
	sm.set_player_chef_gender("x")
	_assert("invalid gender ignored (stays 'm')", sm.player_chef_gender(), "m")
	# Choose-Your-Chef 재설계 (2026-06-12): 신규 preset(leo/amara)도 같은 슬롯에 저장·reload 유지.
	sm.set_player_chef_preset("leo")
	sm.callv("_load", [])
	_assert("preset 'leo' persists across reload", sm.player_chef_preset(), "leo")
	_assert("has_chosen_chef() true after leo", sm.has_chosen_chef(), true)
	sm.set_player_chef_preset("amara")
	sm.callv("_load", [])
	_assert("preset 'amara' persists across reload", sm.player_chef_preset(), "amara")
	# legacy "f"/"m" save 값이 신규 코드에서도 valid preset으로 그대로 해석되는지 (backward-compat).
	sm.data["player_chef_gender"] = "f"
	_assert("legacy 'f' save still valid preset", sm.has_chosen_chef(), true)
	_assert("legacy 'f' reads as preset 'f'", sm.player_chef_preset(), "f")
	# Player-Name: set + reload round-trip + trim/squash/length sanitization.
	sm.set_player_name("  Bob  ")
	sm.callv("_load", [])
	_assert("player_name trimmed + persists ('Bob')", sm.player_name(), "Bob")
	_assert("has_player_name() true after input", sm.has_player_name(), true)
	_assert("player_name_display returns input ('Bob')", sm.player_name_display(), "Bob")
	# blank/whitespace input rejected (returns false, value unchanged).
	var blank_ok = sm.set_player_name("   ")
	_assert("blank name rejected (returns false)", blank_ok, false)
	_assert("blank input keeps prior name ('Bob')", sm.player_name(), "Bob")
	# length clamp to 12 + internal whitespace squash.
	sm.set_player_name("Super  Long   Chef  Name  Here")
	_assert("name clamped to 12 chars", sm.player_name().length() <= 12, true)
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
