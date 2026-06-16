## shot_gimbap_match.gd — Build를 Roll flat_setup 가로(landscape) 레이아웃에 맞춤 F5 검증 (2026-06-14).
##
## 직전 portrait(세로) 교정이 과교정("너무 이상해짐")이라는 F5 피드백 → Build를 roll_module의
## flat_setup(가로/landscape, "훨씬 나음")과 **동일 가로 비례**로 되돌린 결과를 실제 viewport로 증명한다.
## (시각/배치/scale만 — scoring/4-factor/arrange/consequence 무변경.)
##
##   build_match  : Build 모듈 — mat/김 landscape(가로 우세) + 밥 wide spread + 가로 색색 다발 4종
##                  (당근/계란/시금치/단무지). 실제 _gesture press-drag-release로 4개 모두 올린 완성 setup.
##   build_vs_roll: Build(좌) | Roll flat_setup(우) 나란히 — 두 화면이 **동일 가로 레이아웃**으로
##                  보이는지(Build→Roll 자연스러운 연속성) 비교. 각 1080×1920을 가로로 stitch.
##
## 실제 게임 입력 경로(TouchGesture press-drag-release)로 strip을 올린다 — 직접 state 주입 아님.
## Roll은 무변경(setup 상태 그대로). opengl3, NOT headless — 실제 viewport image.
## assets-raw/_screenshots/gimbap_match/ 저장.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const BuildScript := preload("res://scripts/cooking_modules/gimbap_build_module.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")

const OUT_DIR_ABS := "C:/Projects/kfood-game/assets-raw/_screenshots/gimbap_match"

var _build_img: Image = null
var _roll_img: Image = null


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("reset_progress"):
		sm.reset_progress()
	DirAccess.make_dir_recursive_absolute(OUT_DIR_ABS)

	# 1) Build 완성 setup (landscape) — 실제 drag로 4 strip 올림.
	await _shot_build(4, "build_match")
	# 2) Roll flat_setup (무변경 reference).
	await _shot_roll_setup()
	# 3) Build | Roll 나란히 stitch.
	_stitch_vs("build_vs_roll")

	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _params() -> Dictionary:
	return {
		"food_id": "t1_004", "guest_id": "junho",
		"level": MenuDB.get_level(1), "menu": MenuDB.get_menu("t1_004"),
		"step_no": 3, "step_total": 7,
	}


func _roll_params() -> Dictionary:
	return {
		"food_id": "t1_004", "guest_id": "junho",
		"level": MenuDB.get_level(1), "menu": MenuDB.get_menu("t1_004"),
		"step_no": 2, "step_total": 7,
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


func _grab_image() -> Image:
	await get_tree().process_frame
	await get_tree().process_frame
	var vtex := get_viewport().get_texture()
	return vtex.get_image() if vtex != null else null


func _save_img(img: Image, name: String) -> void:
	var out := "%s/%s.png" % [OUT_DIR_ABS, name]
	if img != null:
		img.save_png(out)
		print("[match-shot] %s -> %s (%dx%d)" % [name, out, img.get_width(), img.get_height()])
	else:
		print("[match-shot] %s — NO IMAGE (dummy renderer)" % name)


# n_place개의 strip을 실제 drag로 밥 lower-middle guide에 올려 쌓은 뒤 캡처 + Build 이미지 보관.
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
	# guide global = stage.position + (0, BUNDLE_TARGET_Y). 모듈 const를 동적 참조(landscape 값 반영).
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
	print("[match-shot] %s placed=%d need=%d balance=%.2f" % [
		name, int(build.get("_placed")), int(build.get("_need_strips")),
		build.get_arrange_balance() if build.has_method("get_arrange_balance") else -1.0])
	_build_img = await _grab_image()
	_save_img(_build_img, name)
	build.queue_free()
	bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# Roll flat_setup (progress 0, 무변경 reference) 캡처 + Roll 이미지 보관.
func _shot_roll_setup() -> void:
	var bg := _bg()
	var packed := load("res://scenes/cooking/roll_module.tscn") as PackedScene
	var roll: Node = packed.instantiate()
	get_tree().root.add_child(roll)
	if roll.has_method("start"):
		roll.start(_roll_params())
	await get_tree().create_timer(0.8).timeout
	_roll_img = await _grab_image()
	_save_img(_roll_img, "roll_setup_ref")
	roll.queue_free()
	bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# Build(좌) | Roll(우) 두 1080×1920 이미지를 가로로 이어붙여 비교 이미지를 만든다.
func _stitch_vs(name: String) -> void:
	if _build_img == null or _roll_img == null:
		print("[match-shot] %s — stitch skipped (missing image)" % name)
		return
	var gap: int = 24
	var w: int = _build_img.get_width() + gap + _roll_img.get_width()
	var h: int = maxi(_build_img.get_height(), _roll_img.get_height())
	var combo := Image.create(w, h, false, _build_img.get_format())
	combo.fill(Color(0.10, 0.10, 0.12, 1.0))
	combo.blit_rect(_build_img, Rect2i(0, 0, _build_img.get_width(), _build_img.get_height()), Vector2i(0, 0))
	if _roll_img.get_format() != combo.get_format():
		_roll_img.convert(combo.get_format())
	combo.blit_rect(_roll_img, Rect2i(0, 0, _roll_img.get_width(), _roll_img.get_height()),
		Vector2i(_build_img.get_width() + gap, 0))
	_save_img(combo, name)
