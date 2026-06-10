## shot_wi_cooking_walk.gd — walk the real cooking runner and capture several module
## steps to prove EVERY module sits inside the kitchen world (no beige void / skip_bg gaps).
## Output: user://world_integration/cooking_step_<n>_after.png
extends Node

const Runner := preload("res://scripts/gameplay/cooking_module_runner.gd")

const OUT_DIR := "user://world_integration"


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		if sm.has_method("reset_progress"):
			sm.reset_progress()
		sm.data["level"] = 8  # gwangjang → L5 prestige env, exercise the top mapping too
		sm.data["stock"]["t2_008"] = 9
		sm._save()
	await get_tree().process_frame
	# 비빔밥: slice → arrange → season → stir → plate (모든 gesture 유형 커버)
	Runner.pending_menu_id = "t2_008"
	Runner.pending_guest_id = "junho"
	var packed := load("res://scenes/cooking_module_runner.tscn") as PackedScene
	var inst: Node = packed.instantiate()
	get_tree().root.add_child(inst)
	# request ~1.4s, then modules flow. Capture at a few timestamps spanning the sequence.
	var stamps: Array = [2.6, 5.0, 7.4, 9.8, 12.2]
	var n: int = 0
	for s in stamps:
		await get_tree().create_timer(s - (0.0 if n == 0 else float(stamps[n - 1]))).timeout
		var img := get_viewport().get_texture().get_image()
		var out_path: String = "%s/cooking_step_%d_after.png" % [OUT_DIR, n + 1]
		img.save_png(out_path)
		print("[wi-walk] saved %s" % ProjectSettings.globalize_path(out_path))
		n += 1
	inst.queue_free()
	await get_tree().process_frame
	get_tree().quit()
