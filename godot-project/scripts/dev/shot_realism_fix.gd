## shot_realism_fix.gd — Cooking Realism Composition Fix verification shots.
##
## Renders the 4 affected cooking modules into assets-raw/_screenshots/realism_fix/ to
## prove the HARD RULES:
##   HR1: roll shows STAGES (seaweed+rice+strips → halfway → finished), never the finished
##        gimbap up front.
##   HR2: plate never stacks a vessel under a baked dish_with_vessel ("그릇 위 그릇").
##   HR3: each step shows its own state (no early final-dish exposure).
##
## Output PNGs (1080x1920 viewport):
##   plate_bibimbap_content.png   — vessel(brass_bowl) + content_only mound (CASE A composite)
##   plate_ramyeon_dish_only.png  — dish hero alone, NO second vessel underneath (CASE B)
##   roll_stage_flat.png          — seaweed + rice + 3 filling strips (p≈0)  [NOT finished gimbap]
##   roll_stage_halfway.png       — half-rolled swap (p≈0.7)
##   roll_stage_finished.png      — finished content-only ONLY after a successful release
##   slice_clean.png              — clean board, knife on ingredient, neat pile
##   arrange.png                  — slots center, small target chip, tray bottom
##
## Run via shot_realism_fix.tscn (opengl3, NOT headless — needs real viewport image).
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")

const OUT_DIR := "res://_shot_realism_fix/"   # globalized then copied out by ps1


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("reset_progress"):
		sm.reset_progress()

	await _shot_plate("t2_008", "plate_bibimbap_content")   # has content_only → CASE A
	await _shot_plate("t1_002", "plate_ramyeon_dish_only")  # no content_only → CASE B
	await _shot_roll_stages()
	await _shot_module("res://scenes/cooking/slice_module.tscn", "t1_004", "slice_clean", 1.4)
	await _shot_module("res://scenes/cooking/arrange_module.tscn", "t2_008", "arrange", 1.4)

	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _mount_bg() -> Node:
	var bg = KitchenBackgroundScript.new()
	bg.env_key = "home"
	get_tree().root.add_child(bg)
	return bg


func _params(food_id: String, extra: Dictionary = {}) -> Dictionary:
	var p := {
		"food_id": food_id, "guest_id": "junho",
		"level": MenuDB.get_level(1), "menu": MenuDB.get_menu(food_id),
		"step_no": 1, "step_total": 4,
	}
	for k in extra:
		p[k] = extra[k]
	return p


func _capture(name: String) -> void:
	await get_tree().process_frame
	var vtex := get_viewport().get_texture()
	var img: Image = vtex.get_image() if vtex != null else null
	var out := "user://realism_%s.png" % name
	if img != null:
		img.save_png(out)
		print("[realism-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[realism-shot] %s — NO IMAGE (dummy renderer)" % name)


func _clear_root_extras(keep: Node) -> void:
	for c in get_tree().root.get_children():
		if c == keep or c == self or c is Window:
			continue
		if c.get_script() != null or c is Control or c is Node2D or c is CanvasLayer:
			# leave autoloads (they are direct children named after their class) — only free
			# nodes WE added (BG / module). Autoloads have no scene_file_path and are Node.
			if c.scene_file_path == "" and not (c is Control or c is Node2D or c is CanvasLayer):
				continue
			c.queue_free()


func _shot_module(scene: String, food_id: String, name: String, wait_s: float) -> void:
	var bg := _mount_bg()
	var packed := load(scene) as PackedScene
	var inst: Node = packed.instantiate()
	get_tree().root.add_child(inst)
	if inst.has_method("start"):
		inst.start(_params(food_id))
	await get_tree().create_timer(wait_s).timeout
	await _capture(name)
	inst.queue_free()
	bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


func _shot_plate(food_id: String, name: String) -> void:
	var bg := _mount_bg()
	var packed := load("res://scenes/cooking/plate_module.tscn") as PackedScene
	var inst: Node = packed.instantiate()
	get_tree().root.add_child(inst)
	if inst.has_method("start"):
		inst.start(_params(food_id))
	await get_tree().create_timer(1.2).timeout
	await _capture(name)
	inst.queue_free()
	bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# Drive the roll module to 3 distinct stages and shoot each.
func _shot_roll_stages() -> void:
	var bg := _mount_bg()
	var packed := load("res://scenes/cooking/roll_module.tscn") as PackedScene
	var roll: Node = packed.instantiate()
	get_tree().root.add_child(roll)
	if roll.has_method("start"):
		roll.start(_params("t1_004"))
	await get_tree().create_timer(0.8).timeout

	# Stage FLAT (p≈0) — seaweed + rice + strips visible, NOT a finished gimbap.
	await _capture("roll_stage_flat")

	# Drive two-finger progress to ~0.70 (halfway swap region) by setting left/right + applying visual.
	roll.set("_rolling", true)
	roll.set("_left_progress", 0.70)
	roll.set("_right_progress", 0.70)
	if roll.has_method("_apply_roll_visual"):
		roll.call("_apply_roll_visual")
	await get_tree().create_timer(0.5).timeout
	await _capture("roll_stage_halfway")

	# Finalize with a clean even roll at sweet-zone progress → finished_content_only swap.
	roll.set("_left_progress", 0.92)
	roll.set("_right_progress", 0.92)
	roll.set("_both_down_frames", 60)
	roll.set("_any_down_frames", 60)
	roll.set("_speed_samples", [200.0, 180.0, 220.0])
	if roll.has_method("_finalize_roll"):
		roll.call("_finalize_roll")
	await get_tree().create_timer(0.6).timeout
	await _capture("roll_stage_finished")

	roll.queue_free()
	bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
