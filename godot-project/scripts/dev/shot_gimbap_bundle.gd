## shot_gimbap_bundle.gd — Gimbap Build "두툼한 색색 다발" F5 verification (2026-06-13).
##
## 사용자 F5 불만 교정 증명 ("이게 김밥집 김밥인가? 가는 실선 2-3개 + 두꺼운 흰 밥 슬랩 + 비스듬 mat"):
##   build_thick_bundle : 4 재료(carrot/egg/spinach/danmuji) painterly 다발을 **실제 drag 입력**으로
##                        밥 위에 packed tight 안착 → 하나의 **푸짐한 색색 다발**(주인공). 밥은 얇은
##                        spread(흰 슬랩 아님), mat은 평면 top-down(비스듬 X), far 봉합 margin 유지.
##
## scoring/4-factor/arrange_quality/consequence(§8.3) 무변경 — 시각/배치/scale layer만.
## 입력은 실제 TouchGesture press-drag-release(직접 state 주입 아님 — _on_drag_released가 위치 판정).
## 풀 1080x1920 viewport(half-scale 아님)로 다발 두께를 또렷이 증명한다. opengl3, NOT headless.
extends Node

const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")
const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const BuildScript := preload("res://scripts/cooking_modules/gimbap_build_module.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")

var _out_dir: String = "user://gimbap_bundle"


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_out_dir))

	await _shot_thick_bundle()

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


# press-drag-release 한 stroke를 _gesture에 주입(실제 입력 경로).
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
		print("[bundle-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[bundle-shot] %s — NO IMAGE (dummy renderer)" % name)


# 4 재료를 실제 drag로 밥 위에 packed tight 안착 → 푸짐한 색색 다발(주인공) + 얇은 밥 + 평면 mat.
func _shot_thick_bundle() -> void:
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
	# 각 tray 다발을 집어 밥 위 guide(STRIP_TARGET_Y, stage 로컬)로 drag→release.
	if gesture != null and strips != null and sg != null:
		var guide_y: float = sg.position.y + 96.0
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
	print("[bundle-shot] thick_bundle placed=%d balance=%.2f" % [
		int(build.get("_placed")),
		build.get_arrange_balance() if build.has_method("get_arrange_balance") else -1.0])
	await _capture("build_thick_bundle")
	build.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
