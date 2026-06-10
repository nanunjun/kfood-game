## shot_one_module.gd — 단일 module을 debug zone overlay와 함께 캡처 (진단용).
##
## 사용: shot_one_module.tscn을 main으로 돌리되 static 변수로 module/food 지정.
##   godot --path godot-project --rendering-driver opengl3 --quit-after 200 \
##     res://scenes/shot_one_module.tscn
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const BaseModule := preload("res://scripts/cooking_modules/base_module.gd")

const OUT_DIR := "user://phase_a_art_swap/layout_fix"

# 진단할 module + food (편집해서 사용).
static var module_scene: String = "res://scenes/cooking/stir_module.tscn"
static var food_id: String = "t1_005"
static var out_name: String = "stir_debug.png"
static var extra: Dictionary = {"variant": "wok", "target_turns": 3.0}
static var debug_zones: bool = true


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	BaseModule.debug_zone_overlay = debug_zones
	var p: Dictionary = {
		"food_id": food_id, "guest_id": "junho",
		"level": MenuDB.get_level(1), "menu": MenuDB.get_menu(food_id),
		"step_no": 1, "step_total": 4,
	}
	for k in extra.keys():
		p[k] = extra[k]
	var packed := load(module_scene) as PackedScene
	var inst: Node = packed.instantiate()
	get_tree().root.add_child(inst)
	if inst.has_method("start"):
		inst.start(p)
	await get_tree().create_timer(1.4).timeout
	var img := get_viewport().get_texture().get_image()
	img.save_png(OUT_DIR + "/" + out_name)
	print("[shot_one] saved %s" % out_name)
	get_tree().quit()
