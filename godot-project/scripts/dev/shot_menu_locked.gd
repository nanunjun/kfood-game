extends Node


func _ready() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		sm.data["level"] = 8
		for mid in ["t1_002", "t1_003", "t1_004", "t1_008", "m_kimchi_jjigae", "t2_008",
				"m_doenjang_jjigae", "t2_010", "t2_014", "t1_006", "m_maeuntang", "t2_013"]:
			sm.data["stock"][mid] = 3
		sm._save()
	var ms := get_node_or_null("/root/MoodSystem")
	if ms:
		ms.dev_override = "happy"  # neutral baseline
	await get_tree().process_frame
	var packed: PackedScene = load("res://scenes/menu_select.tscn")
	var node: Node = packed.instantiate()
	get_tree().root.add_child(node)
	for i in range(20):
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png("user://shot_menu_locked.png")
	print("[shot_menu_locked] err=%d" % err)
	get_tree().quit()
