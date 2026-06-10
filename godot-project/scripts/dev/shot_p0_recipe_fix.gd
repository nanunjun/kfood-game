## shot_p0_recipe_fix.gd — P0 Recipe Correctness 검증 screenshot batch.
##
## 4 dish × recipe-correct module을 dish별 semantic param과 함께 instantiate → 합성 결과 capture.
## 목적: dish identity 교정 증명 (떡볶이≠김치 / 불고기 noodle 없음 / 비빔밥 gochujang+놋그릇 / 순두부 broth).
##
## 사용법 (PowerShell):
##   godot --path godot-project --quit-after 60 res://scenes/shot_p0_recipe_fix.tscn
## 산출물: user://p0_recipe_fix/{tteokbokki_stir,bulgogi_cook,bibimbap_season,bibimbap_plate,sundubu_timing}.png
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")

const OUT_DIR := "user://p0_recipe_fix"


func _ready() -> void:
	print("=== P0 Recipe Correctness — batch screenshots ===")
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))

	# 1) 떡볶이 stir — frying_pan + rice_cake(떡) in red gochujang sauce + spatula. (김치 없음)
	await _capture("res://scenes/cooking/stir_module.tscn", "tteokbokki_stir.png",
		_params("t1_003", 1, {"variant": "default", "target_turns": 3.0}), 1.8)
	# 2) 불고기 stir/cook — frying_pan + beef_cooked 양념 코팅 볶기 + spatula. (noodle 없음)
	await _capture("res://scenes/cooking/stir_module.tscn", "bulgogi_cook.png",
		_params("t2_014", 2, {"variant": "default", "target_turns": 3.0}), 1.8)
	# 3) 비빔밥 season — gochujang dollop(paste) + spoon. (고춧가루병 아님)
	await _capture("res://scenes/cooking/season_module.tscn", "bibimbap_season.png",
		_params("t2_008", 2, {"mode": "simple", "seasoning": "gochujang"}), 1.6)
	# 4) 비빔밥 plate — brass_bowl(놋그릇) + bibimbap content_only 합성.
	await _capture("res://scenes/cooking/plate_module.tscn", "bibimbap_plate.png",
		_params("t2_008", 4, {}), 1.6)
	# 5) 순두부 timing — earthenware_bowl + broth + 김치/두부 잠김 + 거품/김 (stew).
	await _capture("res://scenes/cooking/timing_module.tscn", "sundubu_timing.png",
		_params("t2_013", 2, {"duration_ms": 4000.0, "perfect_at": 0.85, "perfect_width": 0.18}), 2.6)

	# 보너스: 떡볶이 slice — fish_cake 어슷 (대파 substitute 제거 증명).
	await _capture("res://scenes/cooking/slice_module.tscn", "tteokbokki_slice.png",
		_params("t1_003", 1, {"tap_count": 4, "bpm": 95.0, "cut_style": "diagonal"}), 1.4)

	print("=== P0 Recipe Correctness done -> %s ===" % ProjectSettings.globalize_path(OUT_DIR))
	get_tree().quit()


func _params(food_id: String, level_num: int, extra: Dictionary) -> Dictionary:
	var p: Dictionary = {
		"food_id": food_id,
		"guest_id": "junho",
		"level": MenuDB.get_level(level_num),
		"menu": MenuDB.get_menu(food_id),
		"step_no": 1,
		"step_total": 5,
	}
	for k in extra.keys():
		p[k] = extra[k]
	return p


func _capture(scene_path: String, out_name: String, params: Dictionary, wait_s: float) -> void:
	var out_path: String = OUT_DIR + "/" + out_name
	print("[shot] %s -> %s" % [scene_path, out_path])
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
