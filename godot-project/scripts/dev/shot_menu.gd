extends Node


func _ready() -> void:
	# pre-seed before screenshot helper runs (it does its own seeding too)
	var ScreenShotScript := preload("res://scripts/dev/screenshot_helper.gd")
	ScreenShotScript.scene_path = "res://scenes/menu_select.tscn"
	ScreenShotScript.out_path = "user://shot_menu.png"
	# inflate level so 12 menus render unlocked
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		sm.data["level"] = 8
		# guarantee at least 1 stock per menu so cards render the "Cook" button
		for mid in ["t1_002", "t1_003", "t1_004", "t1_008", "m_kimchi_jjigae", "t2_008",
				"m_doenjang_jjigae", "t2_010", "t2_014", "t1_006", "m_maeuntang", "t2_013"]:
			sm.data["stock"][mid] = 3
		sm._save()
	# wait one frame so root is no longer "setting up children"
	await get_tree().process_frame
	var packed: PackedScene = load("res://scenes/menu_select.tscn")
	var node: Node = packed.instantiate()
	get_tree().root.add_child(node)
	# let cards instantiate + textures load
	for i in range(20):
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png("user://shot_menu.png")
	var path := ProjectSettings.globalize_path("user://shot_menu.png")
	print("[shot_menu] size=%sx%s err=%d -> %s" % [img.get_width(), img.get_height(), err, path])
	get_tree().quit()
