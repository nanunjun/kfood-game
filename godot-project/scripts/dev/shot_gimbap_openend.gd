## shot_gimbap_openend.gd — 김밥 통 양끝 OPEN 단면 prominent F5 검증 (2026-06-13).
##
## 사용자 핵심: "김밥 양쪽 끝은 틔어있어야지 — 왜 김으로 막혀있나". 신규 자산
## (gimbap_roll_for_slice / roll_finished* = 양끝 open 통, rice_painterly = 얇은 spread)을
## 재import 후, **인게임 slice/roll 화면에서 통이 크고 좌측 open 단면(밥 ring+속)이 또렷이**
## 보이는지 실제 viewport(opengl3, NOT headless)로 증명한다.
##
##   slice_openend       : GimbapSliceModule setup 직후 — 큰 통 + 좌측 open 단면(밥 ring+색색 속) 노출.
##   roll_finished_openend: RollModule 완성 통(well_rolled) — 큰 통 + 좌측 open 단면 노출.
##   build_thin_rice     : GimbapBuildModule setup 직후 — 얇은 밥 spread + 두꺼운 속 다발.
##
## scoring/4-factor/slice_quality/consequence 무변경 — 시각/scale/import만 검증. 전체 1080x1920.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const GimbapSliceScript := preload("res://scripts/cooking_modules/gimbap_slice_module.gd")
const BuildScript := preload("res://scripts/cooking_modules/gimbap_build_module.gd")
const RollScript := preload("res://scripts/cooking_modules/roll_module.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")

var _out_dir: String = "user://gimbap_openend"


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("reset_progress"):
		sm.reset_progress()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_out_dir))

	await _shot_slice_openend()
	await _shot_roll_finished_openend()
	await _shot_build_thin_rice()

	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _params(food_id: String, step_no: int) -> Dictionary:
	return {
		"food_id": food_id, "guest_id": "junho",
		"level": MenuDB.get_level(1), "menu": MenuDB.get_menu(food_id),
		"step_no": step_no, "step_total": 7,
	}


func _capture(name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var vtex := get_viewport().get_texture()
	var img: Image = vtex.get_image() if vtex != null else null
	var out := "%s/%s.png" % [_out_dir, name]
	if img != null:
		img.save_png(out)
		print("[openend-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[openend-shot] %s — NO IMAGE (dummy renderer)" % name)


func _bg() -> Node:
	var bg = KitchenBackgroundScript.new()
	bg.env_key = "home"
	get_tree().root.add_child(bg)
	return bg


# --- slice_openend: GimbapSliceModule setup 직후 — 큰 통 + 좌측 open 단면 prominent ---
func _shot_slice_openend() -> void:
	var bg := _bg()
	var slice: Control = GimbapSliceScript.new()
	slice.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(slice)
	var p := _params("t1_004", 5)
	p["vs_quality_state"] = {"roll_quality": 0.92}
	slice.start(p)
	await get_tree().create_timer(0.9).timeout
	await _capture("slice_openend")
	slice.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- roll_finished_openend: well_rolled 완성 통 — 큰 통 + 좌측 open 단면 prominent ---
func _shot_roll_finished_openend() -> void:
	var bg := _bg()
	var roll: Control = RollScript.new()
	roll.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(roll)
	roll.start(_params("t1_004", 4))
	await get_tree().create_timer(0.5).timeout
	# 양쪽 균등 full drag → release → well_rolled (perfect, tight) 완성 통.
	var lx: float = 540.0 - 250.0
	var rx: float = 540.0 + 250.0
	var y0: float = 1300.0
	var up: float = 440.0 * 0.93
	_send_touch(roll, 0, Vector2(lx, y0), true)
	_send_touch(roll, 1, Vector2(rx, y0), true)
	await get_tree().process_frame
	for i in range(1, 19):
		var t: float = float(i) / 18.0
		_send_drag(roll, 0, Vector2(lx, lerpf(y0, y0 - up, t)))
		_send_drag(roll, 1, Vector2(rx, lerpf(y0, y0 - up, t)))
		await get_tree().process_frame
	_send_touch(roll, 0, Vector2(lx, y0 - up), false)
	_send_touch(roll, 1, Vector2(rx, y0 - up), false)
	await get_tree().create_timer(0.8).timeout
	print("[openend-shot] roll_finished_openend left_p=%.2f right_p=%.2f" % [
		float(roll.get("_left_progress")), float(roll.get("_right_progress"))])
	await _capture("roll_finished_openend")
	roll.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- build_thin_rice: GimbapBuildModule setup 직후 — 얇은 밥 spread + 두꺼운 속 다발 ---
func _shot_build_thin_rice() -> void:
	var bg := _bg()
	var build: Control = BuildScript.new()
	build.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(build)
	var p := _params("t1_004", 3)
	p["vs_available_slots"] = 4
	build.start(p)
	await get_tree().create_timer(0.9).timeout
	await _capture("build_thin_rice")
	build.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


func _send_touch(node: Node, index: int, pos: Vector2, pressed: bool) -> void:
	var e := InputEventScreenTouch.new()
	e.index = index
	e.position = pos
	e.pressed = pressed
	node._input(e)


func _send_drag(node: Node, index: int, pos: Vector2) -> void:
	var e := InputEventScreenDrag.new()
	e.index = index
	e.position = pos
	node._input(e)
