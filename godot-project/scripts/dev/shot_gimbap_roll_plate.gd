## shot_gimbap_roll_plate.gd — Gimbap Step 4 Roll + Step 6 Plating F5 verification (2026-06-12).
##
## 사용자 거부 교정 증명 (strict top-down rebuild):
##   roll_flat      : 수평 setup — 김발 mat 수평 직사각 + 김+밥+가로 strip. 사선/floating 0.
##   roll_mid       : mat 아래→위 접힘 + two-finger drag(양쪽 위로) + 수평 유지. twist 0.
##   roll_finished  : 수평 완성 cylinder (rotation 0, 단면 노출 0).
##   plate_topdown  : top-down 직사각 도시락 tray + 6 circular slot + faint gimbap silhouette.
##   plate_placed   : 조각 cut-side-up이 slot에 snap, 정렬(가지런).
##
## scoring/save/4-factor/consequence 무변경 — 시각/조작 표시만. 입력은 실제 입력 경로로 주입:
##   roll  = InputEventScreenTouch/Drag (좌·우 손가락 독립) → 실제 _input 경로.
##   plate = TouchGesture press-drag-release stroke → 실제 _on_vs_drag_released 위치 판정.
##
## opengl3, NOT headless — 실제 viewport image 필요.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const RollScript := preload("res://scripts/cooking_modules/roll_module.gd")
const PlateScript := preload("res://scripts/cooking_modules/plate_module.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")

var _out_dir: String = "user://gimbap_roll_plate"


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("reset_progress"):
		sm.reset_progress()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_out_dir))

	await _shot_roll_flat()
	await _shot_roll_mid()
	await _shot_roll_finished()
	await _shot_plate_topdown()
	await _shot_plate_placed()

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
		print("[grp-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[grp-shot] %s — NO IMAGE (dummy renderer)" % name)


func _bg() -> Node:
	var bg = KitchenBackgroundScript.new()
	bg.env_key = "home"
	get_tree().root.add_child(bg)
	return bg


# 좌·우 손가락(index 0/1)을 mat bottom edge에서 위로 drag (실제 _input 경로).
# left_to / right_to = 각 손가락이 최종 도달할 Y(작을수록 더 위로 = 더 말림). steps로 분할.
func _two_finger_drag(roll: Node, left_from: Vector2, left_to: Vector2,
		right_from: Vector2, right_to: Vector2, steps: int) -> void:
	# 두 손가락 동시 press.
	_send_touch(roll, 0, left_from, true)
	_send_touch(roll, 1, right_from, true)
	await get_tree().process_frame
	for i in range(1, steps + 1):
		var t: float = float(i) / float(steps)
		_send_drag(roll, 0, left_from.lerp(left_to, t))
		_send_drag(roll, 1, right_from.lerp(right_to, t))
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


# --- roll_flat: setup 직후 — 수평 mat + 김+밥+가로 strip. 사선/floating 0 ---
func _shot_roll_flat() -> void:
	var bg := _bg()
	var roll: Control = RollScript.new()
	roll.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(roll)
	roll.start(_params("t1_004", 4))
	await get_tree().create_timer(0.8).timeout
	await _capture("roll_flat")
	roll.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- roll_mid: 양쪽 손가락을 절반(0.5 진행)까지 위로 drag (안 떼고 멈춤) — fold 진행 + 수평 ---
func _shot_roll_mid() -> void:
	var bg := _bg()
	var roll: Control = RollScript.new()
	roll.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(roll)
	roll.start(_params("t1_004", 4))
	await get_tree().create_timer(0.5).timeout
	# TOUCH_TARGET_Y=1300, OFFSET_X=250, PUSH_DISTANCE=440. 0.55 진행 = 위로 ~242px drag.
	var lx: float = 540.0 - 250.0
	var rx: float = 540.0 + 250.0
	var y0: float = 1300.0
	var up: float = 440.0 * 0.55
	await _two_finger_drag(roll,
		Vector2(lx, y0), Vector2(lx, y0 - up),
		Vector2(rx, y0), Vector2(rx, y0 - up), 14)
	# 손가락을 떼지 않고 mid 상태 유지 → fold 진행 + two-finger 추적 visible.
	await get_tree().create_timer(0.4).timeout
	await _capture("roll_mid")
	roll.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- roll_finished: 양쪽 균등 full drag → release → 수평 완성 cylinder (rotation 0) ---
func _shot_roll_finished() -> void:
	var bg := _bg()
	var roll: Control = RollScript.new()
	roll.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(roll)
	roll.start(_params("t1_004", 4))
	await get_tree().create_timer(0.5).timeout
	var lx: float = 540.0 - 250.0
	var rx: float = 540.0 + 250.0
	var y0: float = 1300.0
	var up: float = 440.0 * 0.93   # sweet zone (perfect, tight).
	await _two_finger_drag(roll,
		Vector2(lx, y0), Vector2(lx, y0 - up),
		Vector2(rx, y0), Vector2(rx, y0 - up), 18)
	# 두 손가락 release → _finalize_roll → 완성 수평 cylinder.
	_send_touch(roll, 0, Vector2(lx, y0 - up), false)
	_send_touch(roll, 1, Vector2(rx, y0 - up), false)
	await get_tree().create_timer(0.7).timeout
	print("[grp-shot] roll_finished left_p=%.2f right_p=%.2f" % [
		float(roll.get("_left_progress")), float(roll.get("_right_progress"))])
	await _capture("roll_finished")
	roll.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- plate_topdown: setup 직후 — top-down 도시락 tray + 6 slot + faint silhouette ---
func _shot_plate_topdown() -> void:
	var bg := _bg()
	var plate: Control = PlateScript.new()
	plate.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(plate)
	var p := _params("t1_004", 6)
	p["vs_quality_state"] = {"slice_quality": 0.9}   # VS plating 분기.
	plate.start(p)
	await get_tree().create_timer(0.8).timeout
	await _capture("plate_topdown")
	plate.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- plate_placed: 실제 drag stroke로 각 조각을 slot에 snap → cut-side-up 정렬 ---
func _shot_plate_placed() -> void:
	var bg := _bg()
	var plate: Control = PlateScript.new()
	plate.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(plate)
	var p := _params("t1_004", 6)
	p["vs_quality_state"] = {"slice_quality": 0.95}   # tight slice → 균일 조각.
	plate.start(p)
	await get_tree().create_timer(0.6).timeout
	var gesture = plate.get("_vs_gesture")
	var pieces: Array = plate.get("_vs_pieces")
	var targets: Array = plate.get("_vs_targets")
	# 각 조각을 home에서 대응 slot으로 press-drag-release (실제 _on_vs_drag_released 위치 판정).
	if gesture != null and pieces != null and targets != null:
		for i in range(pieces.size()):
			# 미배치 조각을 집어 i번째 빈 slot 근처로.
			var node: Control = pieces[i]["node"]
			if not is_instance_valid(node):
				continue
			var home: Vector2 = node.position + node.size * 0.5
			var slot: Vector2 = targets[i] if i < targets.size() else home
			await _stroke(gesture, home, slot)
			await get_tree().create_timer(0.18).timeout
	await get_tree().create_timer(0.6).timeout
	print("[grp-shot] plate_placed placed=%d plate_quality=%.2f" % [
		int(plate.get("_vs_placed_count")),
		plate.get_vs_plate_quality() if plate.has_method("get_vs_plate_quality") else -1.0])
	await _capture("plate_placed")
	plate.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# press-drag-release 한 stroke를 _gesture에 주입(실제 입력 경로). from→to를 N step으로 swipe.
func _stroke(gesture: Node, from: Vector2, to: Vector2, steps: int = 10) -> void:
	if gesture == null:
		return
	gesture._gui_input(_touch_ev(from, true))
	await get_tree().process_frame
	for i in range(1, steps + 1):
		var t: float = float(i) / float(steps)
		gesture._gui_input(_drag_ev(from.lerp(to, t)))
		await get_tree().process_frame
	gesture._gui_input(_touch_ev(to, false))
	await get_tree().process_frame


func _touch_ev(pos: Vector2, pressed: bool) -> InputEventScreenTouch:
	var e := InputEventScreenTouch.new()
	e.position = pos
	e.pressed = pressed
	return e


func _drag_ev(pos: Vector2) -> InputEventScreenDrag:
	var e := InputEventScreenDrag.new()
	e.position = pos
	return e
