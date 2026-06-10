## shot_layer5_composition.gd — 5-Layer Runtime Composition 검증 screenshot batch (8 module).
##
## 각 cooking module을 음식별 semantic param과 함께 instantiate → 5-layer 합성 결과 capture.
## standalone asset(ingredient/tool/vessel)가 runtime 조립되는지 시각 검증.
##
## 사용법 (PowerShell):
##   godot --path godot-project --quit-after 120 res://scenes/shot_layer5_composition.tscn
## 산출물: user://phase_a_art_swap/layer5_composition/{slice,arrange,...}.png
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")

const OUT_DIR := "user://phase_a_art_swap/layout_fix"


func _ready() -> void:
	print("=== Layer-5 Composition — batch screenshots ===")
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))

	# slice — cutting_board + green_onion_whole + chef_knife (라면 대파).
	await _capture("res://scenes/cooking/slice_module.tscn", "slice.png",
		_params("t1_002", 1, {"tap_count": 4, "bpm": 110.0}), 1.4)
	# slice (김치) — cutting_board + kimchi_whole + chef_knife.
	await _capture("res://scenes/cooking/slice_module.tscn", "slice_kimchi.png",
		_params("t1_005", 1, {"tap_count": 4, "bpm": 90.0}), 1.4)
	# arrange — real ingredients only (김밥 5색), 색블록 없음.
	await _capture("res://scenes/cooking/arrange_module.tscn", "arrange.png",
		_params("t1_004", 1, {"slot_count": 5}), 1.4)
	# stir — frying_pan + kimchi_cooked + spatula + steam (김치볶음밥).
	await _capture("res://scenes/cooking/stir_module.tscn", "stir.png",
		_params("t1_005", 1, {"variant": "wok", "target_turns": 3.0}), 1.4)
	# flip — frying_pan + beef_raw + spatula + arc (해물파전).
	await _capture("res://scenes/cooking/flip_module.tscn", "flip.png",
		_params("t1_006", 1, {"variant": "pajeon"}), 2.0)
	# timing — noodle_bowl + noodle_raw→cooked + steam + bubbles (라면).
	await _capture("res://scenes/cooking/timing_module.tscn", "timing.png",
		_params("t1_002", 1, {"duration_ms": 3500.0, "perfect_at": 0.85, "perfect_width": 0.18}), 2.6)
	# season — earthenware_bowl + dish + seasoning_bottle + particles (순두부).
	await _capture("res://scenes/cooking/season_module.tscn", "season.png",
		_params("t2_013", 1, {"mode": "simple", "seasoning": "gochugaru"}), 1.6)
	# roll — rolling_mat + rice + ingredients (김밥).
	await _capture("res://scenes/cooking/roll_module.tscn", "roll.png",
		_params("t1_004", 1, {"sweet_lo": 0.82, "sweet_hi": 1.02}), 1.4)
	# plate — brass_bowl + dish hero + sparkle (비빔밥).
	await _capture("res://scenes/cooking/plate_module.tscn", "plate.png",
		_params("t2_008", 4, {}), 1.4)

	print("=== Layer-5 Composition done ===")
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


func _capture(scene_path: String, out_name: String, params: Dictionary, wait_s: float) -> void:
	var out_path: String = OUT_DIR + "/" + out_name
	print("[shot] %s -> %s" % [scene_path, out_path])
	# 각 module이 _attach_cooking_bg()로 KitchenBackground를 내부에서 깐다 — 별도 root bg 불요.
	var packed := load(scene_path) as PackedScene
	if packed == null:
		push_warning("[shot] cannot load " + scene_path)
		return
	var inst: Node = packed.instantiate()
	get_tree().root.add_child(inst)
	if inst.has_method("start"):
		inst.start(params)
	await get_tree().create_timer(wait_s).timeout
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(out_path)
	print("  saved (err=%d) -> %s  (%dx%d)" % [
		err, ProjectSettings.globalize_path(out_path), img.get_width(), img.get_height()])
	inst.queue_free()
	await get_tree().create_timer(0.3).timeout
