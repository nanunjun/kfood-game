## shot_premium_menu.gd — Premium V1 menu_select screenshot.
##
## Scenario: Lv 8 player, all 12 menus stocked, Tteokbokki = TODAY'S PICK (highest compat).
## Output: assets-raw/_screenshots/premium_v1/01_menu_select.png (via user:// then move).
extends Node


func _ready() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		sm.data["level"] = 8
		# stock all 12 menus
		for mid in ["t1_002", "t1_003", "t1_004", "t1_008", "m_kimchi_jjigae", "t2_008",
				"m_doenjang_jjigae", "t2_010", "t2_014", "t1_006", "m_maeuntang", "t2_013"]:
			sm.data["stock"][mid] = 3
		sm._save()
	await get_tree().process_frame
	var packed: PackedScene = load("res://scenes/menu_select.tscn")
	var node: Node = packed.instantiate()
	get_tree().root.add_child(node)
	# Let cards instantiate + textures load + TODAY'S PICK ribbon slide-in finish
	for i in range(40):
		await get_tree().process_frame
	await get_tree().create_timer(0.8).timeout
	var img := get_viewport().get_texture().get_image()
	var out_path: String = "user://premium_v1_01_menu_select.png"
	var err := img.save_png(out_path)
	var path := ProjectSettings.globalize_path(out_path)
	print("[shot_premium_menu] err=%d -> %s (%dx%d)" % [err, path, img.get_width(), img.get_height()])
	get_tree().quit()
