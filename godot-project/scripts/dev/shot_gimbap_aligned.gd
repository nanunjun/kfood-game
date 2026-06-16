## shot_gimbap_aligned.gd — Build 김밥 setup 축정렬(axis-aligned) 합성 F5 검증 (2026-06-14).
##
## 사용자 핵심: "옆으로 돌리지 말라는데 왜 자꾸 돌려?" — AI base 이미지가 매번 옆으로 회전.
## 교정 = Godot에서 김발/김/밥을 axis-aligned 직사각으로 쌓아 rotation 0 보장 + recline squash.
##
## 캡처:
##   1) build_aligned : mat + 김 + 밥 (재료 놓기 전). 옆 회전 0(near edge 하단 평행) / 앞으로
##      살짝 recline / 꽉 찬 밥 bed / 밥알 작게 / 가로 wide — 자체 확인.
##   2) build_filled  : 4 재료를 **실제 drag**(TouchGesture press-drag-release)로 밥 lower-third에
##      안착 → Build 완성 = Roll setup.
##
## scoring/4-factor/arrange/consequence 무변경 — 시각/배치 layer만. 풀 1080x1920 viewport.
## opengl3, NOT headless (실제 F5 증명).
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const BuildScript := preload("res://scripts/cooking_modules/gimbap_build_module.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")

var _out_dir: String = "user://gimbap_aligned"


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_out_dir))

	await _shot_build_aligned()
	await _shot_build_filled()

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
		print("[aligned-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[aligned-shot] %s — NO IMAGE (dummy renderer)" % name)


# 1) build_aligned — mat + 김 + 밥 (재료 놓기 전). 축정렬 + recline + 꽉 찬 밥 검증.
func _shot_build_aligned() -> void:
	var bg := _bg()
	var build: Control = BuildScript.new()
	build.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(build)
	var p := _params("t1_004", 3)
	p["vs_available_slots"] = 4
	build.start(p)
	await get_tree().create_timer(0.7).timeout
	# 자체 확인 로그 — stage_group이 rotation 0 / scale.x 1 / squash 적용인지.
	var sg = build.get("_stage_group")
	var mh = build.get("_mat_holder")
	if sg != null:
		print("[aligned-shot] stage_group rot=%.4f scale=(%.3f,%.3f)" % [
			sg.rotation, sg.scale.x, sg.scale.y])
	if mh != null:
		print("[aligned-shot] mat_holder  rot=%.4f scale=(%.3f,%.3f)" % [
			mh.rotation, mh.scale.x, mh.scale.y])
	await _capture("build_aligned")
	build.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# 2) build_filled — 4 재료를 실제 drag로 밥 lower-third에 안착 (= Roll setup).
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
		# 밥 lower-third 근접 — group squash 반영(local 64 → screen 64*scale.y).
		var guide_y: float = sg.position.y + 64.0 * sg.scale.y
		for i in range(strips.size()):
			if bool(strips[i]["placed"]):
				continue
			var node: Control = strips[i]["node"]
			if not is_instance_valid(node):
				continue
			var home: Vector2 = strips[i]["home"]
			await _stroke(gesture, home, Vector2(540.0, guide_y))
			await get_tree().create_timer(0.25).timeout
	await get_tree().create_timer(0.6).timeout
	print("[aligned-shot] build_filled placed=%d balance=%.2f" % [
		int(build.get("_placed")),
		build.get_arrange_balance() if build.has_method("get_arrange_balance") else -1.0])
	await _capture("build_filled")
	build.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
