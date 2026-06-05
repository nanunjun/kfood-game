## shot_phase_a_single.gd — Phase A art-swap single-shot screenshot helper.
##
## CLI argv passes:
##   --shot=slice_ramen | slice_kimchi | arrange_kimbap | stir_bibimbap |
##           flip_pajeon | timing_ramyeon | roll_kimbap | plate_tteokbokki
##
## 사용법:
##   godot --path godot-project --quit-after 8 res://scenes/shot_phase_a_single.tscn -- --shot=slice_ramen
extends Node

const MarketBG := preload("res://scripts/ui/market_bg.gd")
const MenuDB := preload("res://scripts/gameplay/menu_db.gd")

const OUT_DIR := "user://phase_a_art_swap"

# shot_key → (scene_path, out_filename, food_id, level_num, extra, wait_s)
const SHOTS := {
	"slice_ramen": [
		"res://scenes/cooking/slice_module.tscn",
		"01_slice_ramen.png", "t1_002", 1,
		{"tap_count": 4, "bpm": 110.0}, 1.4,
	],
	"slice_kimchi": [
		"res://scenes/cooking/slice_module.tscn",
		"02_slice_kimchi_fried_rice.png", "t1_005", 1,
		{"tap_count": 4, "bpm": 90.0}, 1.4,
	],
	"arrange_kimbap": [
		"res://scenes/cooking/arrange_module.tscn",
		"03_arrange_kimbap.png", "t1_004", 1,
		{"slot_count": 5}, 1.2,
	],
	"stir_bibimbap": [
		"res://scenes/cooking/stir_module.tscn",
		"04_stir_bibimbap.png", "t2_008", 1,
		{"tap_count": 6, "bpm": 105.0}, 1.4,
	],
	"flip_pajeon": [
		"res://scenes/cooking/flip_module.tscn",
		"05_flip_pajeon.png", "t1_006", 1,
		{"window_open_ms": 2200.0, "window_width_ms": 700.0}, 2.5,
	],
	"timing_ramyeon": [
		"res://scenes/cooking/timing_module.tscn",
		"06_timing_ramyeon.png", "t1_002", 1,
		{"duration_ms": 3500.0, "perfect_at": 0.85, "perfect_width": 0.18}, 2.6,
	],
	"roll_kimbap": [
		"res://scenes/cooking/roll_module.tscn",
		"07_roll_kimbap.png", "t1_004", 1,
		{"target_ms": 800.0, "tol": 0.40}, 1.2,
	],
	"plate_tteokbokki": [
		"res://scenes/cooking/plate_module.tscn",
		"08_plate_tteokbokki.png", "t1_003", 2,
		{}, 1.2,
	],
}


func _ready() -> void:
	var shot_key: String = _parse_shot_arg()
	if not SHOTS.has(shot_key):
		print("[shot_phase_a_single] missing or unknown --shot=%s; defaulting to slice_ramen" % shot_key)
		shot_key = "slice_ramen"

	var spec: Array = SHOTS[shot_key]
	var scene_path: String = String(spec[0])
	var out_name: String = String(spec[1])
	var food_id: String = String(spec[2])
	var level_num: int = int(spec[3])
	var extra: Dictionary = spec[4]
	var wait_s: float = float(spec[5])

	print("[shot_phase_a_single] key=%s scene=%s out=%s" % [shot_key, scene_path, out_name])
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var bg := MarketBG.new()
	bg.light = true
	get_tree().root.add_child(bg)

	var packed := load(scene_path) as PackedScene
	if packed == null:
		push_error("[shot_phase_a_single] cannot load " + scene_path)
		get_tree().quit(); return
	var inst: Node = packed.instantiate()
	get_tree().root.add_child(inst)
	if inst.has_method("start"):
		var p: Dictionary = {
			"food_id": food_id, "guest_id": "junho",
			"level": MenuDB.get_level(level_num),
			"menu": MenuDB.get_menu(food_id),
			"step_no": 1, "step_total": 4,
		}
		for k in extra.keys():
			p[k] = extra[k]
		inst.start(p)
	await get_tree().create_timer(wait_s).timeout
	var img := get_viewport().get_texture().get_image()
	var out_path: String = OUT_DIR + "/" + out_name
	var err := img.save_png(out_path)
	print("  saved (err=%d) -> %s  (%dx%d)" % [
		err, ProjectSettings.globalize_path(out_path), img.get_width(), img.get_height()])
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _parse_shot_arg() -> String:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	for a in args:
		if a.begins_with("--shot="):
			return a.substr("--shot=".length())
	return ""
