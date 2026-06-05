extends Node


func _ready() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		sm.reset_progress()
		# preload some friendship so cards display variety
		sm.add_friendship("junho", 7)
		sm.add_friendship("mina", 4)
		sm.add_friendship("riley", 2)
		sm.add_friendship("mrs_lee", 9)
		sm.add_friendship("seoyeon", 5)
		sm.add_friendship("mother_01", 6)
		sm.add_friendship("father_01", 3)
		for gid in ["junho", "mina", "riley", "mrs_lee", "seoyeon", "mother_01", "father_01"]:
			sm.friendship_milestone_pending(gid)
	# Force a high-compat menu so the screenshot has interesting numbers
	# kimchi_jjigae -> Junho should be the best match
	var GuestSelectScript := preload("res://scripts/ui/guest_select.gd")
	GuestSelectScript.pending_menu_id = "m_kimchi_jjigae"
	await get_tree().process_frame
	var packed: PackedScene = load("res://scenes/guest_select.tscn")
	var node: Node = packed.instantiate()
	get_tree().root.add_child(node)
	for i in range(20):
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png("user://shot_guest.png")
	var path := ProjectSettings.globalize_path("user://shot_guest.png")
	print("[shot_guest] size=%sx%s err=%d -> %s" % [img.get_width(), img.get_height(), err, path])
	get_tree().quit()
