## shot_player_pov_audit.gd — Player-POV orientation audit shots (2026-06-10).
##
## player-pov-camera-v1.md §3 정합 확인. 도구가 화면 하단(near, 플레이어 손)에서 진입하는지.
## assets-raw/_screenshots/roll_staged/ 와 함께 player_pov/ 로 캡처:
##   slice  : 칼 handle 하단/우, blade 중앙, board 근접 (기존 정합 — 확인용).
##   season : 양념병 하단-우 진입(NEAR), particle 음식(중앙) 위로 — far floating 수정 확인.
##   stir   : spoon/spatula handle 하단(near), 머리 bowl 안 — 손잡이 far→near 수정 확인.
##   flip   : pan handle 하단, food 위로 flip (기존 정합 — 확인용).
##
## scoring/입력 무변경 — 시각 배치만. Run via shot_player_pov_audit.tscn (opengl3).
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")

var _out_dir: String = "user://player_pov"


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("reset_progress"):
		sm.reset_progress()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_out_dir))

	await _shot_module("slice_pov", "res://scenes/cooking/slice_module.tscn", "t1_002")
	await _shot_module("season_pov", "res://scenes/cooking/season_module.tscn", "t1_005")
	await _shot_module("stir_pov", "res://scenes/cooking/stir_module.tscn", "t1_005")
	await _shot_module("flip_pov", "res://scenes/cooking/flip_module.tscn", "t1_006")

	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _params(food_id: String) -> Dictionary:
	return {
		"food_id": food_id, "guest_id": "junho",
		"level": MenuDB.get_level(1), "menu": MenuDB.get_menu(food_id),
		"step_no": 1, "step_total": 4,
	}


func _capture(name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var vtex := get_viewport().get_texture()
	var img: Image = vtex.get_image() if vtex != null else null
	var out := "%s/%s.png" % [_out_dir, name]
	if img != null:
		img.save_png(out)
		print("[pov-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[pov-shot] %s — NO IMAGE (dummy renderer)" % name)


func _shot_module(name: String, scene: String, food_id: String) -> void:
	var bg = KitchenBackgroundScript.new()
	bg.env_key = "home"
	get_tree().root.add_child(bg)
	var packed := load(scene) as PackedScene
	var inst: Node = packed.instantiate()
	get_tree().root.add_child(inst)
	if inst.has_method("start"):
		inst.start(_params(food_id))
	await get_tree().create_timer(0.9).timeout
	await _capture(name)
	inst.queue_free()
	bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
