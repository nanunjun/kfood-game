## shot_roll_layout_fix.gd — Gimbap Roll Layout Fix verification shots (VISUAL ONLY).
##
## Renders the long-strip roll setup into assets-raw/_screenshots/roll_layout_fix/ to prove the
## LOCKED layer order + composition (gameplay/scoring 무변경):
##   state1_setup    : bamboo_mat_large base + 김(seaweed_rect) stacked + 밥(rice_rect) +
##                     4 long filling strips as full-width horizontal bands + roll guide arrow.
##                     NOT a finished gimbap (HR1).
##   state3_rolling  : 김이 fillings 위로 curl (p≈0.7 halfway swap region).
##   state4_finished : finished content-only ONLY after a successful (non-burst) release.
##
## Run via shot_roll_layout_fix.tscn (opengl3, NOT headless — needs real viewport image).
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("reset_progress"):
		sm.reset_progress()

	await _shot_roll_stages()

	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _mount_bg() -> Node:
	var bg = KitchenBackgroundScript.new()
	bg.env_key = "home"
	get_tree().root.add_child(bg)
	return bg


func _params(food_id: String) -> Dictionary:
	return {
		"food_id": food_id, "guest_id": "junho",
		"level": MenuDB.get_level(1), "menu": MenuDB.get_menu(food_id),
		"step_no": 2, "step_total": 4,
	}


func _capture(name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var vtex := get_viewport().get_texture()
	var img: Image = vtex.get_image() if vtex != null else null
	var out := "user://roll_layout_%s.png" % name
	if img != null:
		img.save_png(out)
		print("[roll-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[roll-shot] %s — NO IMAGE (dummy renderer)" % name)


# Drive the roll module to 3 distinct stages and shoot each (t1_004 = 김밥).
func _shot_roll_stages() -> void:
	var bg := _mount_bg()
	var packed := load("res://scenes/cooking/roll_module.tscn") as PackedScene
	var roll: Node = packed.instantiate()
	get_tree().root.add_child(roll)
	if roll.has_method("start"):
		roll.start(_params("t1_004"))
	await get_tree().create_timer(0.9).timeout

	# State 1 Setup (p≈0) — mat + 김 + 밥 + 긴 strip 가로 band + roll arrow. NOT finished gimbap.
	await _capture("state1_setup")

	# State 3 Rolling (p≈0.7) — 두 손가락 균등 push → 김이 fillings 위로 curl (halfway swap region).
	roll.set("_rolling", true)
	roll.set("_left_progress", 0.70)
	roll.set("_right_progress", 0.70)
	if roll.has_method("_apply_roll_visual"):
		roll.call("_apply_roll_visual")
	await get_tree().create_timer(0.5).timeout
	await _capture("state3_rolling")

	# State 4 Finished — finalize with a clean even sweet-zone roll → finished swap.
	roll.set("_left_progress", 0.92)
	roll.set("_right_progress", 0.92)
	roll.set("_both_down_frames", 60)
	roll.set("_any_down_frames", 60)
	roll.set("_speed_samples", [200.0, 180.0, 220.0])
	if roll.has_method("_finalize_roll"):
		roll.call("_finalize_roll")
	await get_tree().create_timer(0.7).timeout
	await _capture("state4_finished")

	roll.queue_free()
	bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
