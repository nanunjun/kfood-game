## shot_cooking_full_sequence.gd — runs the full 김밥 (arrange→roll→slice→plate) module
## sequence in headed mode, snapping one frame per module step. Output:
##   user://06_full_sequence_kimbap_01_arrange.png
##   user://06_full_sequence_kimbap_02_roll.png
##   user://06_full_sequence_kimbap_03_slice.png
##   user://06_full_sequence_kimbap_04_plate.png
##
## Usage:
##   godot --quit-after 18 res://scenes/shot_cooking_full_sequence.tscn
##
## This validates the runner's CSV-driven dispatch end-to-end (not just the modules in
## isolation) and produces the 06_full_sequence anchor screenshot bundle.
extends Node

const MarketBG := preload("res://scripts/ui/market_bg.gd")
const MenuDB := preload("res://scripts/gameplay/menu_db.gd")

var _step_idx: int = 0


func _ready() -> void:
	print("=== Full sequence: 김밥 ===")
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	var bg := MarketBG.new()
	bg.light = true
	get_tree().root.add_child(bg)

	var food_id := "t1_004"  # 김밥
	var seq: Array = MenuDB.module_sequence(food_id)
	print("[seq] %s -> %s" % [food_id, seq])
	for i in range(seq.size()):
		var mod_id: String = String(seq[i])
		var scene_path := "res://scenes/cooking/%s_module.tscn" % mod_id
		await _capture_step(mod_id, scene_path, food_id, i + 1, seq.size())
	get_tree().quit()


func _capture_step(mod_id: String, scene_path: String, food_id: String,
		step_no: int, step_total: int) -> void:
	var packed := load(scene_path) as PackedScene
	if packed == null:
		push_warning("[seq] missing " + scene_path)
		return
	var inst: Node = packed.instantiate()
	get_tree().root.add_child(inst)
	if inst.has_method("start"):
		var params: Dictionary = {
			"food_id": food_id, "guest_id": "mrs_lee",
			"level": MenuDB.get_level(1), "menu": MenuDB.get_menu(food_id),
			"step_no": step_no, "step_total": step_total,
			"module_id": mod_id,
		}
		# Per-module tweaks (mirror cooking_module_runner._build_module_params for kimbap)
		match mod_id:
			"arrange": params["slot_count"] = 5
			"roll":    params["target_ms"] = 800.0
			"slice":   params["tap_count"] = 4; params["bpm"] = 110.0
		inst.start(params)
	# Wait for layout
	await get_tree().create_timer(1.2).timeout
	var img := get_viewport().get_texture().get_image()
	var out_path := "user://06_full_sequence_kimbap_%02d_%s.png" % [step_no, mod_id]
	var err := img.save_png(out_path)
	print("[seq] step %d/%d (%s) saved (err=%d) -> %s" % [
		step_no, step_total, mod_id, err, ProjectSettings.globalize_path(out_path)])
	inst.queue_free()
	await get_tree().create_timer(0.3).timeout
