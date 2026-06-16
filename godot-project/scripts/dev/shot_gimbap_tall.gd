## shot_gimbap_tall.gd — Gimbap Build "김발/김 위아래로 길게 + 밥 클린 spread" F5 검증 (2026-06-14).
##
## F5 불만 교정 증명 (시각/배치/scale만, scoring/contract 무변경):
##   build_tall : mat/김이 **세로(portrait)로 길게**(이전 납작 landscape → portrait), 밥이 김 **대부분
##                (아래~중앙)을 덮는 클린 흰 spread**(작은 사각 + 어두운 테두리 X), far(위) 맨 김 seal
##                margin, 가로 strip 4종 다발 유지. 실제 _gesture drag로 4개 모두 올려 완성 setup 캡처.
##
## 실제 게임 입력 경로(TouchGesture press-drag-release)로 snap을 만든다 — 직접 state 주입 아님.
## opengl3, NOT headless — 실제 viewport image. assets-raw/_screenshots/gimbap_tall/ 저장.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const BuildScript := preload("res://scripts/cooking_modules/gimbap_build_module.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")

const OUT_DIR_ABS := "C:/Projects/kfood-game/assets-raw/_screenshots/gimbap_tall"


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("reset_progress"):
		sm.reset_progress()
	DirAccess.make_dir_recursive_absolute(OUT_DIR_ABS)

	await _shot_build(4, "build_tall")        # 4 strip 모두 → 완성 tall setup.

	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _params() -> Dictionary:
	return {
		"food_id": "t1_004", "guest_id": "junho",
		"level": MenuDB.get_level(1), "menu": MenuDB.get_menu("t1_004"),
		"step_no": 3, "step_total": 7,
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
func _stroke(gesture: Node, from: Vector2, to: Vector2, steps: int = 8) -> void:
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
	var out := "%s/%s.png" % [OUT_DIR_ABS, name]
	if img != null:
		img.save_png(out)
		print("[tall-shot] %s -> %s (%dx%d)" % [name, out, img.get_width(), img.get_height()])
	else:
		print("[tall-shot] %s — NO IMAGE (dummy renderer)" % name)


# n_place개의 strip을 실제 drag로 밥 lower-middle guide에 올려 쌓은 뒤 캡처.
func _shot_build(n_place: int, name: String) -> void:
	var bg := _bg()
	var build: Control = BuildScript.new()
	build.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(build)
	build.start(_params())
	await get_tree().create_timer(0.6).timeout
	var gesture = build.get("_gesture")
	var strips: Array = build.get("_strips")
	var sg = build.get("_stage_group")
	# guide global = stage.position + (0, BUNDLE_TARGET_Y). BUNDLE_TARGET_Y는 모듈 const(150).
	if gesture != null and strips != null and sg != null:
		var guide_y: float = sg.position.y + build.BUNDLE_TARGET_Y
		var done: int = 0
		for i in range(strips.size()):
			if done >= n_place:
				break
			if bool(strips[i]["placed"]):
				continue
			var node: Control = strips[i]["node"]
			if not is_instance_valid(node):
				continue
			var home: Vector2 = strips[i]["home"]
			await _stroke(gesture, home, Vector2(540.0, guide_y))
			await get_tree().create_timer(0.22).timeout
			done += 1
	await get_tree().create_timer(0.5).timeout
	print("[tall-shot] %s placed=%d need=%d balance=%.2f" % [
		name, int(build.get("_placed")), int(build.get("_need_strips")),
		build.get_arrange_balance() if build.has_method("get_arrange_balance") else -1.0])
	await _capture(name)
	build.queue_free()
	bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
