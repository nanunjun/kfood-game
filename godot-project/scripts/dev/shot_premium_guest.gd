## shot_premium_guest.gd — Premium V1 guest_select screenshot.
##
## Scenario: Kimchi Stew selected, Junho 93% RECOMMENDED with sparkle halo (+50% bonus).
## Output: user://premium_v1_02_guest_select.png
extends Node


func _ready() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		sm.reset_progress()
		sm.add_friendship("junho", 7)
		sm.add_friendship("mina", 4)
		sm.add_friendship("riley", 2)
		sm.add_friendship("mrs_lee", 9)
		sm.add_friendship("seoyeon", 5)
		sm.add_friendship("mother_01", 6)
		sm.add_friendship("father_01", 3)
		for gid in ["junho", "mina", "riley", "mrs_lee", "seoyeon", "mother_01", "father_01"]:
			sm.friendship_milestone_pending(gid)
	# Kimchi Stew -> Junho 93% best match
	var GuestSelectScript := preload("res://scripts/ui/guest_select.gd")
	GuestSelectScript.pending_menu_id = "m_kimchi_jjigae"
	await get_tree().process_frame
	var packed: PackedScene = load("res://scenes/guest_select.tscn")
	var node: Node = packed.instantiate()
	get_tree().root.add_child(node)
	# Hero number bounce takes 0.5s + ribbon pulse — give it 1.2s
	for i in range(40):
		await get_tree().process_frame
	await get_tree().create_timer(1.4).timeout
	var img := get_viewport().get_texture().get_image()
	var out_path: String = "user://premium_v1_02_guest_select.png"
	var err := img.save_png(out_path)
	print("[shot_premium_guest] err=%d -> %s (%dx%d)" % [err,
		ProjectSettings.globalize_path(out_path), img.get_width(), img.get_height()])
	get_tree().quit()
