## shot_gimbap_usermat.gd — gimbap_mat 한 장 base + 재료 placement + Build=Roll 연속성 F5 증명 (2026-06-15).
##
## 사용자 제작 gimbap_mat.png(김발+김+밥 full bed, 이미 똑바로 정렬 + recline baked)을 Build/Roll
## base 한 장으로 배선한 결과를 실제 opengl3 viewport로 캡처한다(타일 합성/RICE_CROP/setup_base 폐기).
##   build_base    : gimbap_mat base 한 장(김발+김+밥, 회전 0) — 재료 놓기 전.
##   build_filled  : 실제 drag로 4 재료 strip을 흰 밥 region lower-third에 안착 = 완성 setup.
##   roll_initial  : 동일 gimbap_mat base(Roll 초기) — Build 최종과 동일하게 보임(연속성).
##
## scoring/4-factor/arrange/consequence 무변경 — 시각/배치 layer만. 입력은 실제 TouchGesture
## press-drag-release(직접 state 주입 아님). 풀 1080x1920 viewport. opengl3, NOT headless.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const BuildScript := preload("res://scripts/cooking_modules/gimbap_build_module.gd")
const RollScript := preload("res://scripts/cooking_modules/roll_module.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")

var _out_dir: String = "user://gimbap_usermat"


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_out_dir))

	await _shot_build_base()
	await _shot_build_filled()
	await _shot_roll_initial()

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
		print("[usermat-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[usermat-shot] %s — NO IMAGE (dummy renderer)" % name)


# build_base — gimbap_mat base 한 장(김발+김+밥, 회전 0), 재료 놓기 전.
func _shot_build_base() -> void:
	var bg := _bg()
	var build: Control = BuildScript.new()
	build.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(build)
	var p := _params("t1_004", 3)
	p["vs_available_slots"] = 4
	build.start(p)
	await get_tree().create_timer(0.7).timeout
	print("[usermat-shot] build_base gimbap_mat=%s" % ArtRegistry.get_painterly("gimbap_mat"))
	await _capture("build_base")
	build.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# build_filled — 실제 drag로 4 재료 strip을 흰 밥 region lower-third에 안착 = 완성 setup.
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
	# 드롭 타깃 = 밥 region 중심(BUILD_X + RICE_CENTER_X) / lower-third(stage.y + BUNDLE_TARGET_Y).
	var rice_cx: float = float(BuildScript.BUILD_X) + float(BuildScript.RICE_CENTER_X)
	if gesture != null and strips != null and sg != null:
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
	print("[usermat-shot] build_filled placed=%d balance=%.2f rice_cx=%.0f guide_y=%.0f" % [
		int(build.get("_placed")),
		build.get_arrange_balance() if build.has_method("get_arrange_balance") else -1.0,
		rice_cx, sg.position.y + float(BuildScript.BUNDLE_TARGET_Y)])
	await _capture("build_filled")
	build.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# roll_initial — 동일 gimbap_mat base(Roll 초기), 거의 평평. Build 최종과 동일하게 보임(연속성).
func _shot_roll_initial() -> void:
	var bg := _bg()
	var roll: Control = RollScript.new()
	roll.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(roll)
	roll.start(_params("t1_004", 4))
	await get_tree().create_timer(0.5).timeout
	# 거의 평평(roundness 0) — 초기 flat state, gimbap_mat base + 재료 overlay가 그대로 보인다.
	roll.set("_left_progress", 0.0)
	roll.set("_right_progress", 0.0)
	if roll.has_method("_apply_roll_visual"):
		roll.call("_apply_roll_visual")
	await get_tree().create_timer(0.6).timeout
	await _capture("roll_initial")
	roll.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
