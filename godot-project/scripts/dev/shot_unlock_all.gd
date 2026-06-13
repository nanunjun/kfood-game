## shot_unlock_all.gd — DEBUG_UNLOCK_ALL verification (real opengl3 viewport).
##
## Proves the test-unlock toggle: with the player at LEVEL 1 (where most dishes
## would normally be LOCKED), DEBUG_UNLOCK_ALL=true makes all 12 recipe cards
## active (no "Discover at Lv N" stamp, no faded card) and lets late-level dishes
## be picked and entered into the cooking runner without a crash.
##
## Captures (env KFOOD_SHOT_OUT selects which, default = menu):
##   menu  -> menu_select at Lv1, all 12 active
##   <dish>-> cooking_module_runner entered for that menu_id (late-level dish)
##
## save/scoring/economy untouched — this only reads the toggle + drives the UI.
extends Node

# "menu" or a menu_id (e.g. "t2_008" Bibimbap Lv4, "t2_013" Sundubu Lv8).
static var mode: String = "menu"
static var out_name: String = "menu_unlocked.png"


func _ready() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		if sm.has_method("reset_progress"):
			sm.reset_progress()
		# chef + name so menu_select doesn't redirect to the first-run gates
		if sm.has_method("set_player_chef_gender"):
			sm.set_player_chef_gender("f")
		if sm.has_method("set_player_name"):
			sm.set_player_name("Tester")
		# LEVEL 1 on purpose: without the toggle, dishes Lv2..Lv8 would all be LOCKED.
		# The toggle must override that so all 12 cards are active.
		sm.data["level"] = 1
		# stock every dish so the "active" state is purely the unlock-all proof
		# (and verify stock-gate bypass works even if a dish is 0).
		for mid in ["t1_002", "t1_003", "t1_004", "t1_008", "m_kimchi_jjigae", "t2_008",
				"m_doenjang_jjigae", "t2_010", "t2_014", "t1_006", "m_maeuntang", "t2_013"]:
			sm.data["stock"][mid] = 3
		sm.data["stock"]["t2_013"] = 0  # Sundubu (Lv8) OUT OF STOCK -> unlock_all must still allow entry
		if sm.has_method("consume_levelup_notice"):
			sm.consume_levelup_notice()
		sm._save()

	var name_override := OS.get_environment("KFOOD_SHOT_OUT")
	if name_override != "":
		out_name = name_override
	var mode_override := OS.get_environment("KFOOD_SHOT_MODE")
	if mode_override != "":
		mode = mode_override

	await get_tree().process_frame

	if mode == "menu":
		await _capture_menu()
	else:
		await _capture_dish(mode)

	get_tree().quit()


func _capture_menu() -> void:
	var packed: PackedScene = load("res://scenes/menu_select.tscn")
	var node: Node = packed.instantiate()
	get_tree().root.add_child(node)
	for i in range(48):
		await get_tree().process_frame
	await get_tree().create_timer(0.8).timeout
	_save_shot()


func _capture_dish(menu_id: String) -> void:
	# Drive the same path menu_select._on_pick uses for an evaluator-free dish:
	# set the runner's pending ids and enter the runner directly (proves no crash
	# for a late-level / ready=0 dish that the toggle made selectable).
	var RunnerScript := preload("res://scripts/gameplay/cooking_module_runner.gd")
	RunnerScript.pending_menu_id = menu_id
	RunnerScript.pending_guest_id = ""
	var packed: PackedScene = load("res://scenes/cooking_module_runner.tscn")
	var node: Node = packed.instantiate()
	get_tree().root.add_child(node)
	# let chrome + first module instantiate, textures load, intro tweens settle
	for i in range(60):
		await get_tree().process_frame
	await get_tree().create_timer(1.0).timeout
	_save_shot()


func _save_shot() -> void:
	var img := get_viewport().get_texture().get_image()
	var out_path: String = "user://" + out_name
	var err := img.save_png(out_path)
	var path := ProjectSettings.globalize_path(out_path)
	print("[shot_unlock_all] mode=%s err=%d -> %s (%dx%d)" % [mode, err, path, img.get_width(), img.get_height()])
