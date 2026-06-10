## shot_runner_module.gd — 실제 F5 gameplay 경로(cooking_module_runner) 캡처.
##
## isolated module shot과 달리 runner chrome(now-cooking banner / guest mini / level pill /
## KitchenBackground)까지 포함한 진짜 게임 화면을 캡처한다. food_id를 지정하면 그 음식의
## module sequence가 흐르며, 지정 시점에 캡처.
##
## 사용: shot_runner_module.tscn을 main으로. CookingModuleRunner.pending_menu_id를 set.
extends Node

const Runner := preload("res://scripts/gameplay/cooking_module_runner.gd")

const OUT_DIR := "user://phase_a_art_swap/layout_fix"

# food_id → out_name → capture delay(s) (request 1.4s 후 첫 module 시작).
const SHOTS := [
	{"food": "t1_002", "out": "f5_ramyeon_slice.png", "delay": 2.2},   # 라면 1st module
	{"food": "t1_004", "out": "f5_gimbap_arrange.png", "delay": 2.2},  # 김밥
	{"food": "t1_005", "out": "f5_kfried_stir.png", "delay": 2.2},     # 김치볶음밥
	{"food": "t2_008", "out": "f5_bibim_arrange.png", "delay": 2.2},   # 비빔밥
]

var _idx: int = 0


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	await get_tree().process_frame
	for shot in SHOTS:
		await _run_shot(shot)
	print("=== F5 runner shots done ===")
	get_tree().quit()


func _run_shot(shot: Dictionary) -> void:
	Runner.pending_menu_id = String(shot["food"])
	Runner.pending_guest_id = ""
	var packed := load("res://scenes/cooking_module_runner.tscn") as PackedScene
	if packed == null:
		push_warning("[f5] cannot load runner")
		return
	var inst: Node = packed.instantiate()
	get_tree().root.add_child(inst)
	await get_tree().create_timer(float(shot["delay"])).timeout
	var img := get_viewport().get_texture().get_image()
	var out_path: String = OUT_DIR + "/" + String(shot["out"])
	img.save_png(out_path)
	print("[f5] saved %s (food=%s)" % [shot["out"], shot["food"]])
	inst.queue_free()
	await get_tree().create_timer(0.3).timeout
