## shot_menu_recipe_board.gd — Recipe Board menu_select screenshot (before/after).
##
## Scenario: Lv 5 player so some dishes are still LOCKED (discovery state) and
## some are stocked / some out of stock. Captures the full menu_select scene.
## Output: user://menu_recipe_board.png (then copied to assets-raw by the .ps1).
extends Node

static var out_name: String = "menu_recipe_board_after.png"


func _ready() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		if sm.has_method("reset_progress"):
			sm.reset_progress()
		# Chef + name so menu_select doesn't redirect to the first-run gender/name gates
		# (deterministic capture of the real recipe board a returning player sees).
		if sm.has_method("set_player_chef_gender"):
			sm.set_player_chef_gender("f")
		if sm.has_method("set_player_name"):
			sm.set_player_name("Jisoo")
		sm.data["level"] = 5
		# friendships so best-guest avatars have flavor
		if sm.has_method("add_friendship"):
			sm.add_friendship("junho", 7)
			sm.add_friendship("mina", 4)
			sm.add_friendship("riley", 2)
			sm.add_friendship("mrs_lee", 9)
			sm.add_friendship("seoyeon", 5)
			for gid in ["junho", "mina", "riley", "mrs_lee", "seoyeon"]:
				if sm.has_method("friendship_milestone_pending"):
					sm.friendship_milestone_pending(gid)
		# stock most dishes; leave one OUT OF STOCK to show "Ingredients Needed" state
		for mid in ["t1_002", "t1_003", "t1_004", "t1_008", "m_kimchi_jjigae", "t2_008",
				"m_doenjang_jjigae", "t2_010", "t2_014", "t1_006", "m_maeuntang", "t2_013"]:
			sm.data["stock"][mid] = 3
		sm.data["stock"]["t1_003"] = 0  # Tteokbokki out of stock -> "Ingredients Needed"
		# clear any levelup notice so the toast doesn't fire over the screenshot
		if sm.has_method("consume_levelup_notice"):
			sm.consume_levelup_notice()
		sm._save()
	await get_tree().process_frame
	var packed: PackedScene = load("res://scenes/menu_select.tscn")
	var node: Node = packed.instantiate()
	get_tree().root.add_child(node)
	# let cards instantiate + textures load + any reveal tween finish
	for i in range(48):
		await get_tree().process_frame
	await get_tree().create_timer(0.8).timeout
	var img := get_viewport().get_texture().get_image()
	var name_override := OS.get_environment("KFOOD_SHOT_OUT")
	if name_override != "":
		out_name = name_override
	var out_path: String = "user://" + out_name
	var err := img.save_png(out_path)
	var path := ProjectSettings.globalize_path(out_path)
	print("[shot_menu_recipe_board] err=%d -> %s (%dx%d)" % [err, path, img.get_width(), img.get_height()])
	get_tree().quit()
