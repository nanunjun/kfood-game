## screenshot_helper.gd — instantiates a target scene, waits for layout, screenshots.
##
## Usage:
##   ScreenshotHelper.scene_path = "res://scenes/menu_select.tscn"
##   ScreenshotHelper.out_path = "user://screenshot_menu.png"
## Then load this scene; it will switch to the target, wait 2 frames, write PNG,
## then quit.
extends Node

# These are set by sibling launcher scripts before _ready runs.
static var scene_path: String = "res://scenes/menu_select.tscn"
static var out_path: String = "user://screenshot.png"
static var wait_frames: int = 8


func _ready() -> void:
	print("[screenshot] target=%s out=%s" % [scene_path, out_path])
	# pre-seed friendship so the UI has interesting numbers in the screenshot
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("add_friendship"):
		sm.reset_progress()
		sm.add_friendship("junho", 7)   # 3 stars
		sm.add_friendship("mina", 4)    # 2 stars
		sm.add_friendship("riley", 2)   # 1 star
		sm.add_friendship("mrs_lee", 9) # 4 stars
		sm.add_friendship("seoyeon", 5) # 2 stars
		sm.add_friendship("mother_01", 6)
		sm.add_friendship("father_01", 3)
		# consume any milestone toasts triggered by the above
		for gid in ["junho", "mina", "riley", "mrs_lee", "seoyeon", "mother_01", "father_01"]:
			sm.friendship_milestone_pending(gid)
	# load the target scene
	var packed := load(scene_path) as PackedScene
	if packed == null:
		push_error("[screenshot] can't load " + scene_path)
		get_tree().quit(); return
	var node := packed.instantiate()
	get_tree().root.add_child(node)
	# wait a few frames for layout to settle (cards instantiated, textures loaded)
	for i in range(wait_frames):
		await get_tree().process_frame
	# capture
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(out_path)
	var global_out: String = ProjectSettings.globalize_path(out_path)
	print("[screenshot] saved (err=%d) -> %s" % [err, global_out])
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()
