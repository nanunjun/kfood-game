## shot_gimbap_build_slice.gd — Gimbap Step 3 Build + Step 5 Slice F5 verification (2026-06-12).
##
## 사용자 거부 교정 증명:
##   build_topdown  : 레이어 mat→김→밥(얇게)→lower-third guide line→긴 strip(danmuji/spinach/
##                    carrot/egg). top-down, ingredient grid 잔존 0.
##   build_snap     : 실제 _gesture drag로 strip을 guide에 올림 → lower-third guide에 snap 한 줄.
##   slice_topdown  : 완성 roll = top-down 가로 cylinder + 6 cut guide mark. grid 0.
##   slice_cut      : 실제 _gesture downward swipe → cut-side 조각 균일 분리(단면 노출).
##   sprite_check   : danmuji(노랑)/spinach(녹)/carrot(주황)/egg(노랑 지단) — 당근·파 혼동 0.
##
## scoring/save/4-factor/consequence 무변경 — 시각/조작 표시만. 입력은 실제 TouchGesture에
## press-drag-release / swipe-down을 주입해 *실제 게임 입력 경로*로 snap/cut을 만든다(직접 state
## 주입 아님 — _on_drag_released가 위치 판정).
##
## opengl3, NOT headless — 실제 viewport image 필요.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")
const BuildScript := preload("res://scripts/cooking_modules/gimbap_build_module.gd")
const GimbapSliceScript := preload("res://scripts/cooking_modules/gimbap_slice_module.gd")
const Runner := preload("res://scripts/gameplay/gimbap_slice_runner.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")

var _out_dir: String = "user://gimbap_build_slice"


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("reset_progress"):
		sm.reset_progress()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_out_dir))

	await _shot_build_topdown()
	await _shot_build_snap()
	await _shot_slice_topdown()
	await _shot_slice_cut()
	await _shot_sprite_check()
	await _shot_runner_routing()

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
		print("[gbs-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[gbs-shot] %s — NO IMAGE (dummy renderer)" % name)


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


# press-drag-release 한 stroke를 _gesture에 주입(실제 입력 경로). from→to를 N step으로 swipe.
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


# --- build_topdown: setup 직후 — 레이어 mat→김→밥(얇게)→guide line→tray strips. grid 0 ---
func _shot_build_topdown() -> void:
	var bg := _bg()
	var build: Control = BuildScript.new()
	build.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(build)
	var p := _params("t1_004", 3)
	p["vs_available_slots"] = 4
	build.start(p)
	await get_tree().create_timer(0.8).timeout
	await _capture("build_topdown")
	build.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- build_snap: 실제 drag로 strip을 lower-third guide에 올림 → snap 한 줄 정렬 ---
func _shot_build_snap() -> void:
	var bg := _bg()
	var build: Control = BuildScript.new()
	build.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(build)
	var p := _params("t1_004", 3)
	p["vs_available_slots"] = 4
	build.start(p)
	await get_tree().create_timer(0.6).timeout
	var gesture = build.get("_gesture")
	var strips: Array = build.get("_strips")
	var sg = build.get("_stage_group")
	# 각 tray strip을 집어 밥 lower-third guide line(STRIP_TARGET_Y=96, stage 로컬) 위로 drag→release.
	# guide global y = stage.position.y + 96. x는 중앙(BUILD_X=540).
	if gesture != null and strips != null and sg != null:
		var guide_y: float = sg.position.y + 96.0
		for i in range(strips.size()):
			# 매 stroke 전에 현재 미배치 strip의 home을 다시 읽는다(이미 배치된 건 skip).
			if bool(strips[i]["placed"]):
				continue
			var node: Control = strips[i]["node"]
			if not is_instance_valid(node):
				continue
			var home: Vector2 = strips[i]["home"]
			await _stroke(gesture, home, Vector2(540.0, guide_y))
			await get_tree().create_timer(0.22).timeout
	await get_tree().create_timer(0.5).timeout
	print("[gbs-shot] build_snap placed=%d build_q-ish balance=%.2f" % [
		int(build.get("_placed")),
		build.get_arrange_balance() if build.has_method("get_arrange_balance") else -1.0])
	await _capture("build_snap")
	build.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- slice_topdown: setup 직후 — 완성 가로 cylinder + 6 cut guide. grid 0 ---
func _shot_slice_topdown() -> void:
	var bg := _bg()
	var slice: Control = GimbapSliceScript.new()
	slice.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(slice)
	var p := _params("t1_004", 5)
	p["vs_quality_state"] = {"roll_quality": 0.9}
	slice.start(p)
	await get_tree().create_timer(0.8).timeout
	await _capture("slice_topdown")
	slice.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- slice_cut: 실제 downward swipe per guide → cut-side 조각 균일 분리 ---
func _shot_slice_cut() -> void:
	var bg := _bg()
	var slice: Control = GimbapSliceScript.new()
	slice.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(slice)
	var p := _params("t1_004", 5)
	p["vs_quality_state"] = {"roll_quality": 0.92}   # tight roll → 균일 조각.
	slice.start(p)
	await get_tree().create_timer(0.6).timeout
	var gesture = slice.get("_gesture")
	# ROLL_RECT = (140, 760, 800, 380). 6 guide를 각각 위→아래로 swipe.
	var roll_top: float = 760.0
	var roll_bot: float = 760.0 + 380.0
	if gesture != null:
		for i in range(6):
			# guide x = lerp(x0=210, x1=870, (i+0.5)/6).
			var gx: float = lerpf(140.0 + 70.0, 140.0 + 800.0 - 70.0, (float(i) + 0.5) / 6.0)
			await _stroke(gesture, Vector2(gx, roll_top - 50.0), Vector2(gx, roll_bot + 50.0))
			await get_tree().create_timer(0.20).timeout
	await get_tree().create_timer(0.5).timeout
	print("[gbs-shot] slice_cut cuts_done=%d slice_q=%.2f" % [
		int(slice.get("_cuts_done")),
		slice.get_slice_quality() if slice.has_method("get_slice_quality") else -1.0])
	await _capture("slice_cut")
	slice.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- sprite_check: danmuji/spinach/carrot/egg 정확 sprite (당근·파 혼동 0) ---
func _shot_sprite_check() -> void:
	var bg := _bg()
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(root)
	var title := Label.new()
	title.text = "Gimbap fillings — sprite wiring"
	title.position = Vector2(60, 120)
	title.size = Vector2(960, 60)
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color(0.20, 0.12, 0.06))
	title.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.85))
	title.add_theme_constant_override("outline_size", 6)
	root.add_child(title)
	var specs: Array = ArtRegistry.gimbap_filling_specs(4)
	for i in range(specs.size()):
		var sp: Dictionary = specs[i]
		var y: float = 260.0 + float(i) * 360.0
		var card := Panel.new()
		card.position = Vector2(80, y)
		card.size = Vector2(920, 320)
		var csb := StyleBoxFlat.new()
		csb.bg_color = Color(1.0, 0.98, 0.93, 0.95)
		csb.set_corner_radius_all(26)
		csb.set_border_width_all(3)
		csb.border_color = Color(0.93, 0.74, 0.32)
		card.add_theme_stylebox_override("panel", csb)
		root.add_child(card)
		var tpath: String = String(sp.get("tex", ""))
		if tpath != "" and ResourceLoader.exists(tpath):
			var tex := TextureRect.new()
			tex.texture = load(tpath)
			tex.position = Vector2(20, 20)
			tex.size = Vector2(280, 280)
			tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			card.add_child(tex)
		var lbl := Label.new()
		lbl.text = "%s\n%s" % [String(sp.get("label", "?")), tpath.replace("res://art/sprites/", "")]
		lbl.position = Vector2(330, 110)
		lbl.size = Vector2(560, 160)
		lbl.add_theme_font_size_override("font_size", 36)
		lbl.add_theme_color_override("font_color", Color(0.25, 0.16, 0.08))
		card.add_child(lbl)
	await get_tree().create_timer(0.6).timeout
	await _capture("sprite_check")
	root.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- runner_routing: GimbapSliceRunner를 slice step까지 진행 — 라우팅이 GimbapSliceModule을
#     실제로 인스턴스화하는지 증명(runner 통합, 단독 모듈 아님). build/slice가 runner를 통해 동작. ---
func _shot_runner_routing() -> void:
	Runner.pending_menu_id = "t1_004"
	Runner.pending_guest_id = "junho"
	var runner: Node = Runner.new()
	get_tree().root.add_child(runner)
	# shopping(1.4s 자동 진행 후) → julienne → build → roll → slice. 각 stage를 _finish로 빠르게 통과.
	var guard: int = 0
	var saw_slice: bool = false
	while guard < 80:
		await get_tree().create_timer(0.18).timeout
		guard += 1
		var cur = runner.get("_current_module")
		if cur != null and cur is GimbapSliceScript:
			saw_slice = true
			break
		# 활성 모듈을 즉시 완료시켜 다음 step으로(슬라이스 도달까지 빠르게). CookingModule(julienne/
		# build/roll/slice)는 _finalize(roll=_finalize_roll)로, shopping stage는 _finish()로 강제 완료한다
		# (shopping은 CookingModule이 아니라 25s 자체 타이머라 force-finish 없으면 routing이 멈춘다).
		if cur is CookingModule:
			if cur.has_method("_finalize_roll"):
				cur.set("_rolling", false)
				cur.call("_finalize_roll")
			elif cur.has_method("_finalize"):
				cur.call("_finalize")
		elif cur != null and cur.has_method("_finish") and cur.has_signal("stage_completed"):
			# shopping stage — 즉시 종료해 다음 step(julienne)으로 진행.
			cur.call("_finish")
	await get_tree().create_timer(0.8).timeout
	var cur2 = runner.get("_current_module")
	print("[gbs-shot] runner_routing saw_slice=%s cur_is_gimbap_slice=%s plan_idx=%d" % [
		str(saw_slice), str(cur2 != null and cur2 is GimbapSliceScript),
		int(runner.get("_plan_idx"))])
	await _capture("runner_routing")
	runner.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
