## shot_foreign_chars.gd — 외국인 캐릭터 4명 배선 검증 capture (2026-06-12).
##
## 한 번의 real opengl3 run으로 다음을 렌더:
##   chef_select.png          — "Choose Your Chef" 4 preset (Hana/Joon/Leo/Amara, 성별 라벨 없음)
##   guest_select_foreign.png — guest select에 외국인 손님 카드(Sofia/Kenji) 노출
##   result_sofia.png         — result 화면에 외국인 손님(Sofia) 리액션(excited 스프라이트)
##
## scoring/economy 무관 — 순수 visual 검증. Run via tools/run_foreign_chars_shots.ps1.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const ResultV2Scene := preload("res://scenes/ui/result_screen_v2.tscn")

var _userdir: String = "user://foreign_chars"


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_userdir))
	await get_tree().process_frame
	await _shot_chef_select()
	await _shot_guest_select_foreign()
	await _shot_result_sofia()
	print("=== foreign chars shots done ===")
	get_tree().quit()


func _save(name: String) -> void:
	var img := get_viewport().get_texture().get_image()
	var out_path: String = "%s/%s.png" % [_userdir, name]
	var err := img.save_png(out_path)
	print("[shot] saved %s (err=%d) -> %s" % [out_path, err,
		ProjectSettings.globalize_path(out_path)])


# --- 1) Choose Your Chef — 4 preset (unchosen state) ---
func _shot_chef_select() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		if sm.has_method("reset_progress"):
			sm.reset_progress()
		# 미선택 상태로 4-card chooser 렌더
		sm.data["player_chef_gender"] = ""
		sm._save()
	await get_tree().process_frame
	var packed: PackedScene = load("res://scenes/gender_select.tscn")
	var node: Node = packed.instantiate()
	get_tree().root.add_child(node)
	for _i in range(32):
		await get_tree().process_frame
	await get_tree().create_timer(0.6).timeout
	_save("chef_select")
	node.queue_free()
	await get_tree().create_timer(0.3).timeout


# --- 2) guest select with foreign guests (Sofia/Kenji) visible ---
func _shot_guest_select_foreign() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		if sm.has_method("reset_progress"):
			sm.reset_progress()
		sm.data["level"] = 5
		sm.data["player_chef_gender"] = "leo"  # chosen → no redirect
		if sm.has_method("set_player_name"):
			sm.set_player_name("Leo")
		for mid in MenuDB.all_menu_ids():
			sm.data["stock"][mid] = 3
		sm._save()
	await get_tree().process_frame
	# guest_select renders all selectable guests (CSV-driven; sofia/kenji are friend role).
	var GuestSelect := load("res://scripts/ui/guest_select.gd")
	GuestSelect.pending_menu_id = "t2_008"  # 비빔밥 (ready art)
	var packed: PackedScene = load("res://scenes/guest_select.tscn")
	var node: Node = packed.instantiate()
	get_tree().root.add_child(node)
	for _i in range(48):
		await get_tree().process_frame
	await get_tree().create_timer(0.8).timeout
	# scroll down so foreign cards (sorted by compat) are likely in frame — capture top first,
	# then a scrolled view to ensure Sofia/Kenji are visible somewhere.
	_save("guest_select_foreign")
	# scroll to show more cards (foreign guests may sit lower in the compat sort)
	var sc: ScrollContainer = null
	for child in node.get_children():
		if child is ScrollContainer:
			sc = child as ScrollContainer
			break
	if sc != null:
		sc.scroll_vertical = 900
		await get_tree().process_frame
		await get_tree().create_timer(0.4).timeout
		_save("guest_select_foreign_scrolled")
	node.queue_free()
	await get_tree().create_timer(0.3).timeout


# --- 3) result with foreign guest (Sofia) reaction ---
func _shot_result_sofia() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		if sm.has_method("reset_progress"):
			sm.reset_progress()
		sm.data["player_chef_gender"] = "amara"  # 외국인 셰프 host cheer
		sm._save()
	var menu: Dictionary = MenuDB.get_menu("t2_008")  # 비빔밥 (ready art)
	var guest: Dictionary = MenuDB.get_guest("sofia")
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
	_save("result_sofia")
	screen.queue_free()
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
		"reaction_text": "Wow — so fresh and delicious! I love it!",
		"record_broken": true, "record_prev_score": 0,
		"xp_gained": 60, "xp_total_after": 60,
		"friendship_delta": 3, "friendship_after": 3, "milestone_just_hit": 3,
		"final_coin": 9000, "passed": true,
	}
