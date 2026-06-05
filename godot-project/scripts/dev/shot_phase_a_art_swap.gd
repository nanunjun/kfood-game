## shot_phase_a_art_swap.gd — Phase A art-swap 검증용 8장 screenshot batch.
##
## 사용법 (PowerShell):
##   godot --path godot-project --quit-after 60 res://scenes/shot_phase_a_art_swap.tscn
## 산출물: user://phase_a_art_swap/01_slice_ramen.png ... 08_plate_tteokbokki.png
##
## 각 cooking module을 음식별 hero ingredient/tool과 함께 instantiate하여 capture.
extends Node

const MarketBG := preload("res://scripts/ui/market_bg.gd")
const MenuDB := preload("res://scripts/gameplay/menu_db.gd")

const OUT_DIR := "user://phase_a_art_swap"

var _bg: Node = null


func _ready() -> void:
	print("=== Phase A art-swap — batch screenshots ===")
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	# 출력 디렉터리 보장
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	_bg = MarketBG.new()
	_bg.light = true
	get_tree().root.add_child(_bg)

	# 01 — slice / 라면 / 대파 + 칼+도마
	await _capture(
		"res://scenes/cooking/slice_module.tscn",
		OUT_DIR + "/01_slice_ramen.png",
		_params("t1_002", 1, {"tap_count": 4, "bpm": 110.0}),
		1.2)
	# 02 — slice / 김치볶음밥 / 김치 + 도마+칼 (다지기)
	await _capture(
		"res://scenes/cooking/slice_module.tscn",
		OUT_DIR + "/02_slice_kimchi_fried_rice.png",
		_params("t1_005", 1, {"tap_count": 4, "bpm": 90.0}),
		1.2)
	# 03 — arrange / 김밥 / 5재료
	await _capture(
		"res://scenes/cooking/arrange_module.tscn",
		OUT_DIR + "/03_arrange_kimbap.png",
		_params("t1_004", 1, {"slot_count": 5}),
		1.2)
	# 04 — stir / 비빔밥 / 웍+뒤집개
	await _capture(
		"res://scenes/cooking/stir_module.tscn",
		OUT_DIR + "/04_stir_bibimbap.png",
		_params("t2_008", 1, {"tap_count": 6, "bpm": 105.0}),
		1.2)
	# 05 — flip / 해물파전 / 팬+뒤집개
	await _capture(
		"res://scenes/cooking/flip_module.tscn",
		OUT_DIR + "/05_flip_pajeon.png",
		_params("t1_006", 1, {"window_open_ms": 2200.0, "window_width_ms": 700.0}),
		2.4)
	# 06 — timing / 라면 / 양은냄비
	await _capture(
		"res://scenes/cooking/timing_module.tscn",
		OUT_DIR + "/06_timing_ramyeon.png",
		_params("t1_002", 1, {"duration_ms": 3500.0, "perfect_at": 0.85, "perfect_width": 0.18}),
		2.6)
	# 07 — roll / 김밥 / 김발
	await _capture(
		"res://scenes/cooking/roll_module.tscn",
		OUT_DIR + "/07_roll_kimbap.png",
		_params("t1_004", 1, {"target_ms": 800.0, "tol": 0.40}),
		1.0)
	# 08 — plate / 떡볶이 / 3 vessel pick
	await _capture(
		"res://scenes/cooking/plate_module.tscn",
		OUT_DIR + "/08_plate_tteokbokki.png",
		_params("t1_003", 2, {}),
		1.0)

	print("=== Phase A art-swap done ===")
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
	await get_tree().create_timer(wait_s).timeout
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(out_path)
	print("  saved (err=%d) -> %s  (%dx%d)" % [
		err, ProjectSettings.globalize_path(out_path), img.get_width(), img.get_height()])
	inst.queue_free()
	await get_tree().create_timer(0.3).timeout
