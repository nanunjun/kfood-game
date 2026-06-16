## shot_gimbap_filltex.gd — 재료 painterly 텍스처 + 밥보다 길게 F5 verification (2026-06-15).
##
## 사용자 F5 교정 증명:
##   1) build_filled  : 4 재료를 **실제 drag**로 밥 lower-third에 안착 — 재료가 painterly 음식
##                      텍스처(당근채/계란지단/시금치/단무지, 솔리드 색 바 아님) + 밥보다 좌우로 길게.
##   2) roll_initial  : Roll 초기 setup — Roll의 flat_fillings도 동일 painterly 텍스처(ColorRect 폐기)
##                      + 밥보다 길게. Build와 동일 재료.
##
## scoring/4-factor/arrange/consequence 무변경 — 시각/배치 layer만. 입력은 실제 TouchGesture
## press-drag-release(직접 state 주입 아님). 풀 1080x1920 viewport. opengl3, NOT headless.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const BuildScript := preload("res://scripts/cooking_modules/gimbap_build_module.gd")
const RollScript := preload("res://scripts/cooking_modules/roll_module.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")

var _out_dir: String = "user://gimbap_filltex"


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_out_dir))

	await _shot_build_filled()
	await _shot_roll("roll_initial", 0.06)     # 초기 setup(거의 평평) — Build 최종과 동일 재료.

	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _params(food_id: String, step_no: int) -> Dictionary:
	return {
		"food_id": food_id, "guest_id": "junho",
		"level": MenuDB.get_level(1), "menu": MenuDB.get_menu(food_id),
		"step_no": step_no, "step_total": 7,
	}


func _bg() -> Node:
	var bg = KitchenBackgroundScript.new()
	bg.env_key = "home"
	get_tree().root.add_child(bg)
	return bg


func _touch(pos: Vector2, pressed: bool) -> InputEventScreenTouch:
	var e := InputEventScreenTouch.new()
	e.position = pos
	e.pressed = pressed
	return e


func _drag(pos: Vector2) -> InputEventScreenDrag:
	var e := InputEventScreenDrag.new()
	e.position = pos
	return e


func _stroke(gesture: Node, from: Vector2, to: Vector2, steps: int = 10) -> void:
	if gesture == null:
		return
	gesture._gui_input(_touch(from, true))
	await get_tree().process_frame
	for i in range(1, steps + 1):
		var t: float = float(i) / float(steps)
		gesture._gui_input(_drag(from.lerp(to, t)))
		await get_tree().process_frame
	gesture._gui_input(_touch(to, false))
	await get_tree().process_frame


func _capture(name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var vtex := get_viewport().get_texture()
	var img: Image = vtex.get_image() if vtex != null else null
	var out := "%s/%s.png" % [_out_dir, name]
	if img != null:
		img.save_png(out)
		print("[filltex-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[filltex-shot] %s — NO IMAGE (dummy renderer)" % name)


# 1) build_filled — 4 재료를 실제 drag로 밥 lower-third에 안착. painterly 텍스처 + 밥보다 길게.
func _shot_build_filled() -> void:
	var bg := _bg()
	var build: Control = BuildScript.new()
	build.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(build)
	var p := _params("t1_004", 3)
	p["vs_available_slots"] = 4
	build.start(p)
	await get_tree().create_timer(0.7).timeout

	var gesture = build.get("_gesture")
	var strips: Array = build.get("_strips")
	var sg = build.get("_stage_group")
	if gesture != null and strips != null and sg != null:
		var rice_cx: float = float(BuildScript.BUILD_X) + float(BuildScript.RICE_CENTER_X)
		var guide_y: float = sg.position.y + float(BuildScript.BUNDLE_TARGET_Y)
		for i in range(strips.size()):
			if bool(strips[i]["placed"]):
				continue
			var node: Control = strips[i]["node"]
			if not is_instance_valid(node):
				continue
			var home: Vector2 = strips[i]["home"]
			await _stroke(gesture, home, Vector2(rice_cx, guide_y))
			await get_tree().create_timer(0.25).timeout
	await get_tree().create_timer(0.6).timeout
	print("[filltex-shot] build_filled placed=%d STRIP_W=%.1f STRIP_VIS_H=%.1f balance=%.2f" % [
		int(build.get("_placed")), float(BuildScript.STRIP_W), float(BuildScript.STRIP_VIS_H),
		build.get_arrange_balance() if build.has_method("get_arrange_balance") else -1.0])
	await _capture("build_filled")
	build.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# 2) roll_initial — Roll 초기 setup(roundness 작음). flat_fillings painterly + 밥보다 길게.
func _shot_roll(tag: String, roundness: float) -> void:
	var bg := _bg()
	var roll: Control = RollScript.new()
	roll.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(roll)
	roll.start(_params("t1_004", 4))
	await get_tree().create_timer(0.4).timeout
	roll.set("_left_progress", roundness)
	roll.set("_right_progress", roundness)
	if roll.has_method("_apply_roll_visual"):
		roll.call("_apply_roll_visual")
	if roll.has_method("_update_hint"):
		roll.call("_update_hint")
	await get_tree().create_timer(0.6).timeout
	await _capture(tag)
	roll.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
