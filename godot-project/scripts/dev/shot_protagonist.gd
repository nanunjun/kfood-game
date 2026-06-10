## shot_protagonist.gd — Player-Chef Integration verification capture (2026-06-08).
##
## Renders, in one real opengl3 run, the screens that show the player-chef host:
##   gender_select.png        — 여/남 2 카드 (선택 화면)
##   menu_host_f.png          — Recipe Board, 여 셰프(f) neutral host in header
##   menu_host_m.png          — Recipe Board, 남 셰프(m) neutral host in header
##   result_host_cheer.png    — Result screen, chef cheer host (성공)
##
## Run via tools/run_protagonist_shots.ps1 (opengl3, 1080x1920).
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const ResultV2Scene := preload("res://scenes/ui/result_screen_v2.tscn")

var _userdir: String = "user://protagonist"


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_userdir))
	await get_tree().process_frame
	await _shot_gender_select()
	await _shot_menu_with_host("f", "menu_host_f")
	await _shot_menu_with_host("m", "menu_host_m")
	await _shot_result_with_host()
	await _shot_cooking_request_think()
	await _shot_cooking_cook_host()
	print("=== protagonist shots done ===")
	get_tree().quit()


func _save(name: String) -> void:
	var img := get_viewport().get_texture().get_image()
	var out_path: String = "%s/%s.png" % [_userdir, name]
	var err := img.save_png(out_path)
	print("[shot] saved %s (err=%d) -> %s" % [out_path, err,
		ProjectSettings.globalize_path(out_path)])


# --- 1) gender select (unchosen state) ---
func _shot_gender_select() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		if sm.has_method("reset_progress"):
			sm.reset_progress()
		# ensure unchosen so the screen renders the 2-card chooser
		sm.data["player_chef_gender"] = ""
		sm._save()
	await get_tree().process_frame
	var packed: PackedScene = load("res://scenes/gender_select.tscn")
	var node: Node = packed.instantiate()
	get_tree().root.add_child(node)
	for _i in range(32):
		await get_tree().process_frame
	await get_tree().create_timer(0.6).timeout
	_save("gender_select")
	node.queue_free()
	await get_tree().create_timer(0.3).timeout


# --- 2) menu with selected chef host (f / m) ---
func _shot_menu_with_host(gender: String, out_name: String) -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		if sm.has_method("reset_progress"):
			sm.reset_progress()
		sm.data["level"] = 5
		sm.data["player_chef_gender"] = gender  # already chosen → menu renders (no redirect)
		if sm.has_method("add_friendship"):
			sm.add_friendship("junho", 7)
			sm.add_friendship("mina", 4)
			sm.add_friendship("mrs_lee", 9)
			for gid in ["junho", "mina", "mrs_lee"]:
				if sm.has_method("friendship_milestone_pending"):
					sm.friendship_milestone_pending(gid)
		for mid in MenuDB.all_menu_ids():
			sm.data["stock"][mid] = 3
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
	_save(out_name)
	node.queue_free()
	await get_tree().create_timer(0.3).timeout


# --- 3) result with chef cheer host (success) ---
func _shot_result_with_host() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		if sm.has_method("reset_progress"):
			sm.reset_progress()
		sm.data["player_chef_gender"] = "f"  # 여 셰프 cheer host
		sm._save()
	var menu: Dictionary = MenuDB.get_menu("t2_008")  # 비빔밥 (ready art)
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
	_save("result_host_cheer")
	screen.queue_free()
	await get_tree().create_timer(0.3).timeout


# --- 4) cooking request screen — chef THINK host (tutorial/guide tone) ---
func _shot_cooking_request_think() -> void:
	var Runner := load("res://scripts/gameplay/cooking_module_runner.gd")
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		if sm.has_method("reset_progress"):
			sm.reset_progress()
		sm.data["level"] = 5
		sm.data["player_chef_gender"] = "m"  # 남 셰프 think
		sm.data["stock"]["t2_008"] = 3
		sm._save()
	await get_tree().process_frame
	Runner.pending_menu_id = "t2_008"
	Runner.pending_guest_id = "mina"
	var packed := load("res://scenes/cooking_module_runner.tscn") as PackedScene
	var inst: Node = packed.instantiate()
	get_tree().root.add_child(inst)
	# request screen shows ~1.4s before the first module — capture mid-request (think host visible).
	await get_tree().create_timer(0.7).timeout
	_save("cooking_request_think")
	inst.queue_free()
	await get_tree().create_timer(0.3).timeout


# --- 5) cooking surface — chef COOK host (bottom-right, during a module) ---
func _shot_cooking_cook_host() -> void:
	var Runner := load("res://scripts/gameplay/cooking_module_runner.gd")
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		if sm.has_method("reset_progress"):
			sm.reset_progress()
		sm.data["level"] = 5
		sm.data["player_chef_gender"] = "f"  # 여 셰프 cook
		sm.data["stock"]["t2_008"] = 3
		sm._save()
	await get_tree().process_frame
	Runner.pending_menu_id = "t2_008"
	Runner.pending_guest_id = "junho"
	var packed := load("res://scenes/cooking_module_runner.tscn") as PackedScene
	var inst: Node = packed.instantiate()
	get_tree().root.add_child(inst)
	# request (~1.4s) then first module begins — capture mid-first-module (cook host bottom-right).
	await get_tree().create_timer(2.6).timeout
	_save("cooking_cook_host")
	inst.queue_free()
	await get_tree().create_timer(0.3).timeout


func _result_payload(menu: Dictionary, guest: Dictionary) -> Dictionary:
	var rc := get_node_or_null("/root/RewardCalc")
	var breakdown: Array = []
	var prep := 0.90
	if rc != null:
		breakdown = rc.score_breakdown_rows(prep, prep - 0.05, prep + 0.03, prep + 0.06,
			93, "happy", guest)
	return {
		"food": menu, "guest": guest, "mood": "happy", "compat": 93,
		"stars": 3, "score": 9000, "score_norm": 0.90, "breakdown_rows": breakdown,
		"emotion_level": "excellent",
		"reaction_text": "Junho loved it — beautiful color balance!",
		"record_broken": true, "record_prev_score": 0,
		"xp_gained": 60, "xp_total_after": 60,
		"friendship_delta": 3, "friendship_after": 3, "milestone_just_hit": 3,
		"final_coin": 9000, "passed": true,
	}
