## shot_cooking_batch.gd — captures all 6 cooking-framework verification screenshots
## in a single Godot launch. Each capture spins up the target module .tscn, waits a
## settle window, snaps the viewport, frees the module, and moves on.
##
## Usage:
##   godot --quit-after 30 res://scenes/shot_cooking_batch.tscn
##
## Output PNGs are written to user://  — copy them to
##   assets-raw/_screenshots/cooking_framework_v2/  via the main shell.
extends Node

const MarketBG := preload("res://scripts/ui/market_bg.gd")
const MenuDB := preload("res://scripts/gameplay/menu_db.gd")

var _bg: Node = null


func _ready() -> void:
	print("=== Cooking Framework 2.0 — batch screenshots ===")
	# Wait one frame so the SceneTree is ready to accept new root children.
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	_bg = MarketBG.new()
	_bg.light = true
	get_tree().root.add_child(_bg)
	# Order matters only for the wait-second budget; the captures are independent.
	await _capture(
		"res://scenes/cooking/slice_module.tscn",
		"user://01_module_slice_in_progress.png",
		_params("t1_002", 1, {"tap_count": 4, "bpm": 110.0}),
		1.4)
	await _capture(
		"res://scenes/cooking/arrange_module.tscn",
		"user://02_module_arrange.png",
		_params("t1_004", 1, {"slot_count": 5}),
		1.2)
	await _capture(
		"res://scenes/cooking/roll_module.tscn",
		"user://03_module_roll.png",
		_params("t1_004", 1, {"target_ms": 800.0, "tol": 0.40}),
		1.0)
	await _capture(
		"res://scenes/cooking/timing_module.tscn",
		"user://04_module_timing.png",
		_params("t1_002", 1, {"duration_ms": 3500.0, "perfect_at": 0.85, "perfect_width": 0.18}),
		2.6)  # let the bar fill into / near the gold zone
	await _capture(
		"res://scenes/cooking/plate_module.tscn",
		"user://05_module_plate.png",
		_params("t1_003", 2, {}),  # 떡볶이 — has real dish_best/2nd/bad in menus.csv
		1.0)
	await _capture(
		"res://scenes/cooking/flip_module.tscn",
		"user://06_module_flip.png",
		_params("t1_006", 1, {"window_open_ms": 2200.0, "window_width_ms": 700.0}),
		2.4)  # capture while "FLIP!" pad is active
	print("=== done ===")
	get_tree().quit()


func _params(food_id: String, level_num: int, extra: Dictionary) -> Dictionary:
	var p: Dictionary = {
		"food_id": food_id,
		"guest_id": "junho",
		"level": MenuDB.get_level(level_num),
		"menu": MenuDB.get_menu(food_id),
		"step_no": 1,
		"step_total": 4,
	}
	for k in extra.keys():
		p[k] = extra[k]
	return p


func _capture(scene_path: String, out_path: String, params: Dictionary, wait_s: float) -> void:
	print("[shot] %s -> %s" % [scene_path, out_path])
	var packed := load(scene_path) as PackedScene
	if packed == null:
		push_warning("[shot] cannot load " + scene_path)
		return
	var inst: Node = packed.instantiate()
	get_tree().root.add_child(inst)
	if inst.has_method("start"):
		inst.start(params)
	# Wait for layout + visual settle
	await get_tree().create_timer(wait_s).timeout
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(out_path)
	print("  saved (err=%d) -> %s  (%dx%d)" % [
		err, ProjectSettings.globalize_path(out_path), img.get_width(), img.get_height()])
	inst.queue_free()
	# small breath between captures so the next module's _ready can settle cleanly
	await get_tree().create_timer(0.3).timeout
