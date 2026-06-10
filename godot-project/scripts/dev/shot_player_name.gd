## shot_player_name.gd — Player-Name Personalization verification capture (2026-06-08).
##
## Renders, in one real opengl3 run, the screens proving 주인공 이름 직접 입력 personalization:
##   gender_select.png      — 카드 라벨이 guest명(Mina/Junho)이 아닌 성별 설명(Female/Male Chef)
##   name_entry.png         — 이름 입력 화면 (셰프 미리보기 + LineEdit + Confirm CTA)
##   name_entry_typed.png   — 입력값이 채워진 상태 (가상 키보드 입력 시뮬레이션)
##   menu_with_name.png     — Recipe Board, host 헤더 캡션 = 입력명
##   result_with_name.png   — Result, host 캡션 = "{입력명} cooked this!"
##
## Run via tools/run_player_name_shots.ps1 (opengl3, 1080x1920).
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const ResultV2Scene := preload("res://scenes/ui/result_screen_v2.tscn")

const TEST_NAME := "Suji"

var _userdir: String = "user://player_name"


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_userdir))
	await get_tree().process_frame
	await _shot_gender_select()
	await _shot_name_entry()
	await _shot_menu_with_name()
	await _shot_result_with_name()
	print("=== player_name shots done ===")
	get_tree().quit()


func _save(name: String) -> void:
	var img := get_viewport().get_texture().get_image()
	var out_path: String = "%s/%s.png" % [_userdir, name]
	var err := img.save_png(out_path)
	print("[shot] saved %s (err=%d) -> %s" % [out_path, err,
		ProjectSettings.globalize_path(out_path)])


# --- 1) gender select — new gender-description labels (no guest names) ---
func _shot_gender_select() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		if sm.has_method("reset_progress"):
			sm.reset_progress()
		sm.data["player_chef_gender"] = ""
		sm.data["player_name"] = ""
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


# --- 2) name entry — chef preview + LineEdit + Confirm; empty then typed ---
func _shot_name_entry() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		if sm.has_method("reset_progress"):
			sm.reset_progress()
		sm.data["player_chef_gender"] = "f"  # gender chosen so name_entry renders (no redirect)
		sm.data["player_name"] = ""
		sm._save()
	await get_tree().process_frame
	var packed: PackedScene = load("res://scenes/name_entry.tscn")
	var node: Node = packed.instantiate()
	get_tree().root.add_child(node)
	for _i in range(36):
		await get_tree().process_frame
	await get_tree().create_timer(0.6).timeout
	_save("name_entry")
	# now type into the LineEdit to prove input flow (virtual keyboard target).
	var le := _find_line_edit(node)
	if le != null:
		le.grab_focus()
		le.text = TEST_NAME
		le.caret_column = le.text.length()
		for _i in range(6):
			await get_tree().process_frame
		await get_tree().create_timer(0.4).timeout
		_save("name_entry_typed")
	node.queue_free()
	await get_tree().create_timer(0.3).timeout


# --- 3) menu with the player's typed name in the host header caption ---
func _shot_menu_with_name() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		if sm.has_method("reset_progress"):
			sm.reset_progress()
		sm.data["level"] = 5
		sm.data["player_chef_gender"] = "f"
		sm.data["player_name"] = TEST_NAME  # both set → menu renders (no redirect)
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
	_save("menu_with_name")
	node.queue_free()
	await get_tree().create_timer(0.3).timeout


# --- 4) result with the player's typed name in the chef host caption ---
func _shot_result_with_name() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		if sm.has_method("reset_progress"):
			sm.reset_progress()
		sm.data["player_chef_gender"] = "f"
		sm.data["player_name"] = TEST_NAME
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
	_save("result_with_name")
	screen.queue_free()
	await get_tree().create_timer(0.3).timeout


func _find_line_edit(node: Node) -> LineEdit:
	for c in node.get_children():
		if c is LineEdit:
			return c as LineEdit
		var found := _find_line_edit(c)
		if found != null:
			return found
	return null


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
