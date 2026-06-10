## shot_world_integration.gd — P0 Screen World-Integration verification capture.
##
## Captures the three core screens (menu / result / cooking) in one headless run so
## before/after comparison is direct. Output filenames are tagged with KFOOD_WI_TAG
## (e.g. "before" / "after"):
##   menu_<tag>.png      — Recipe Board (Lv 5, mixed stock/locked)
##   result_<tag>.png    — Result screen (kimchi jjigae + Junho, ★3)
##   cooking_<tag>.png   — first cooking module via the real runner (slice/arrange)
##
## Run via tools/run_world_integration_shots.ps1 (opengl3, 1080x1920).
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const ResultV2Scene := preload("res://scenes/ui/result_screen_v2.tscn")
const Runner := preload("res://scripts/gameplay/cooking_module_runner.gd")

var _tag: String = "after"
var _userdir: String = "user://world_integration"


func _ready() -> void:
	var t := OS.get_environment("KFOOD_WI_TAG")
	if t != "":
		_tag = t
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_userdir))
	await get_tree().process_frame
	await _shot_menu()
	await _shot_result()
	await _shot_cooking()
	print("=== world_integration shots done (tag=%s) ===" % _tag)
	get_tree().quit()


func _save(node_img_name: String) -> void:
	var img := get_viewport().get_texture().get_image()
	var out_path: String = "%s/%s_%s.png" % [_userdir, node_img_name, _tag]
	var err := img.save_png(out_path)
	print("[wi] saved %s (err=%d) -> %s" % [out_path, err,
		ProjectSettings.globalize_path(out_path)])


# --- 1) Menu / Recipe Board ---
func _shot_menu() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		if sm.has_method("reset_progress"):
			sm.reset_progress()
		sm.data["level"] = 5
		if sm.has_method("add_friendship"):
			sm.add_friendship("junho", 7)
			sm.add_friendship("mina", 4)
			sm.add_friendship("mrs_lee", 9)
			sm.add_friendship("seoyeon", 5)
			for gid in ["junho", "mina", "mrs_lee", "seoyeon"]:
				if sm.has_method("friendship_milestone_pending"):
					sm.friendship_milestone_pending(gid)
		for mid in ["t1_002", "t1_003", "t1_004", "t1_008", "m_kimchi_jjigae", "t2_008",
				"m_doenjang_jjigae", "t2_010", "t2_014", "t1_006", "m_maeuntang", "t2_013"]:
			sm.data["stock"][mid] = 3
		sm.data["stock"]["t1_003"] = 0
		if sm.has_method("consume_levelup_notice"):
			sm.consume_levelup_notice()
		sm._save()
	await get_tree().process_frame
	var packed: PackedScene = load("res://scenes/menu_select.tscn")
	var node: Node = packed.instantiate()
	get_tree().root.add_child(node)
	for _i in range(48):
		await get_tree().process_frame
	await get_tree().create_timer(0.8).timeout
	_save("menu")
	node.queue_free()
	await get_tree().create_timer(0.3).timeout


# --- 2) Result ---
func _shot_result() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("reset_progress"):
		sm.reset_progress()
	var menu: Dictionary = MenuDB.get_menu("m_kimchi_jjigae")
	var guest: Dictionary = MenuDB.get_guest("junho")
	var payload: Dictionary = _result_payload(menu, guest)
	var screen := ResultV2Scene.instantiate()
	screen.setup(payload)
	get_tree().root.add_child(screen)
	for _i in range(6):
		await get_tree().process_frame
	if screen.has_method("force_play_all_reveals"):
		screen.force_play_all_reveals()
	await get_tree().create_timer(5.2).timeout
	# capture top (emotion hero + dish) — collapse score so the hero band shows clean
	if screen.has_method("set_score_expanded"):
		screen.set_score_expanded(false)
	var sc: ScrollContainer = null
	for child in screen.get_children():
		if child is ScrollContainer:
			sc = child as ScrollContainer
			break
	if sc != null:
		sc.scroll_vertical = 0
	await get_tree().process_frame
	await get_tree().process_frame
	_save("result")
	screen.queue_free()
	await get_tree().create_timer(0.3).timeout


func _result_payload(menu: Dictionary, guest: Dictionary) -> Dictionary:
	var rc := get_node_or_null("/root/RewardCalc")
	var breakdown: Array = []
	var prep := 0.88
	if rc != null:
		breakdown = rc.score_breakdown_rows(prep, prep - 0.07, prep + 0.04, prep + 0.10,
			93, "happy", guest)
	return {
		"food": menu, "guest": guest, "mood": "happy", "compat": 93,
		"stars": 3, "score": 8800, "score_norm": 0.88, "breakdown_rows": breakdown,
		"emotion_level": "excellent",
		"reaction_text": "Junho loved the spicy kick! Now THAT'S a kick — love it!",
		"record_broken": true, "record_prev_score": 0,
		"xp_gained": 59, "xp_total_after": 59,
		"friendship_delta": 3, "friendship_after": 3, "milestone_just_hit": 3,
		"final_coin": 9100, "passed": true,
	}


# --- 3) Cooking module (real runner path) ---
func _shot_cooking() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		if sm.has_method("reset_progress"):
			sm.reset_progress()
		sm.data["level"] = 5
		sm.data["stock"]["t2_008"] = 3
		sm._save()
	await get_tree().process_frame
	# 비빔밥(t2_008): arrange-heavy + season — strong showcase of a packed kitchen surface.
	Runner.pending_menu_id = "t2_008"
	Runner.pending_guest_id = "junho"
	var packed := load("res://scenes/cooking_module_runner.tscn") as PackedScene
	var inst: Node = packed.instantiate()
	get_tree().root.add_child(inst)
	# request screen ~1.4s, then first module begins — capture mid-first-module.
	await get_tree().create_timer(2.6).timeout
	_save("cooking")
	inst.queue_free()
	await get_tree().create_timer(0.3).timeout
