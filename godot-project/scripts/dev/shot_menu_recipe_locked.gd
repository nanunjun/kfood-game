## shot_menu_recipe_locked.gd — Recipe Board at Lv 1 so most dishes are LOCKED
## (recipe-discovery state). Verifies the faded card + "Discover at Lv N" stamp.
extends Node


func _ready() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		if sm.has_method("reset_progress"):
			sm.reset_progress()
		if sm.has_method("set_player_chef_gender"):
			sm.set_player_chef_gender("f")
		if sm.has_method("set_player_name"):
			sm.set_player_name("Jisoo")
		sm.data["level"] = 1
		if sm.has_method("add_friendship"):
			sm.add_friendship("junho", 7)
			sm.add_friendship("mrs_lee", 9)
			sm.add_friendship("mina", 4)
			for gid in ["junho", "mrs_lee", "mina"]:
				if sm.has_method("friendship_milestone_pending"):
					sm.friendship_milestone_pending(gid)
		for mid in ["t1_002", "t1_004"]:
			sm.data["stock"][mid] = 3
		if sm.has_method("consume_levelup_notice"):
			sm.consume_levelup_notice()
		sm._save()
	await get_tree().process_frame
	var packed: PackedScene = load("res://scenes/menu_select.tscn")
	var node: Node = packed.instantiate()
	get_tree().root.add_child(node)
	for i in range(48):
		await get_tree().process_frame
	await get_tree().create_timer(0.8).timeout
	var img := get_viewport().get_texture().get_image()
	var out_name := OS.get_environment("KFOOD_SHOT_OUT")
	if out_name == "":
		out_name = "menu_recipe_locked.png"
	var out_path: String = "user://" + out_name
	var err := img.save_png(out_path)
	print("[shot_menu_recipe_locked] err=%d (%dx%d)" % [err, img.get_width(), img.get_height()])
	get_tree().quit()
