## shot_cooking_rebuild.gd — P1 Cooking Screen Rebuild verification capture.
##
## Renders the 6 target modules (slice / season / stir / timing / roll / plate) each over
## the FULL kitchen-world background (same as the real runner: KitchenBackground fill_screen
## + skip_bg param), then screenshots a mid-action state so the cooking SCENE is visible —
## not just the initial idle. Output PNGs land in user:// tagged before/after via KFOOD_CR_TAG.
##
## Run: godot --path godot-project --rendering-driver opengl3 --resolution 540x960
##        --quit-after <ms> res://scenes/shot_cooking_rebuild.tscn
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")

var _tag: String = "after"
var _userdir: String = "user://cooking_rebuild"


func _ready() -> void:
	var t := OS.get_environment("KFOOD_CR_TAG")
	if t != "":
		_tag = t
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_userdir))
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()

	# slice — green onion chopping on the board (mid-cut state)
	await _capture("slice", "res://scenes/cooking/slice_module.tscn",
		_params("t1_004", 3, {"tap_count": 4, "bpm": 110.0}), 1.4, "slice")
	# season — ramyeon broth seasoning (gochugaru bottle), mid-pour
	await _capture("season", "res://scenes/cooking/season_module.tscn",
		_params("t1_002", 1, {"mode": "simple", "seasoning": "gochugaru"}), 1.4, "season")
	# stir — kimchi fried rice wok stir
	await _capture("stir", "res://scenes/cooking/stir_module.tscn",
		_params("t1_005", 4, {"variant": "wok", "target_turns": 3.0}), 1.6, "stir")
	# timing — ramyeon simmer heat dial (let it fill toward gold)
	await _capture("timing", "res://scenes/cooking/timing_module.tscn",
		_params("t1_002", 1, {"duration_ms": 3500.0, "perfect_at": 0.85, "perfect_width": 0.18}),
		2.4, "timing")
	# roll — gimbap two-finger roll
	await _capture("roll", "res://scenes/cooking/roll_module.tscn",
		_params("t1_004", 3, {}), 1.4, "roll")
	# plate — tteokbokki vessel choice
	await _capture("plate", "res://scenes/cooking/plate_module.tscn",
		_params("t1_003", 2, {}), 1.2, "plate")

	print("=== cooking_rebuild shots done (tag=%s) ===" % _tag)
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _params(food_id: String, level_num: int, extra: Dictionary) -> Dictionary:
	var p: Dictionary = {
		"food_id": food_id,
		"guest_id": "junho",
		"level": MenuDB.get_level(level_num),
		"menu": MenuDB.get_menu(food_id),
		"step_no": 2,
		"step_total": 4,
		# Mirror the real runner: world BG is laid by the wrapper, module skips its own.
		"skip_bg": true,
	}
	for k in extra.keys():
		p[k] = extra[k]
	return p


func _capture(name: String, scene_path: String, params: Dictionary, wait_s: float,
		kind: String) -> void:
	# World background — same path the runner uses (fill_screen kitchen world).
	var layer := CanvasLayer.new()
	get_tree().root.add_child(layer)
	var bg = KitchenBackgroundScript.new()
	bg.fill_screen = true
	bg.dish_anchor_y = 900.0
	var lvl: Dictionary = params.get("level", {})
	bg.env_key = KitchenBackgroundScript.env_key_for_market(String(lvl.get("market", "home")))
	layer.add_child(bg)

	var packed := load(scene_path) as PackedScene
	if packed == null:
		push_warning("[cr] cannot load " + scene_path)
		layer.queue_free()
		return
	var inst: Control = packed.instantiate()
	layer.add_child(inst)
	if inst.has_method("start"):
		inst.start(params)
	await get_tree().process_frame
	await get_tree().process_frame

	# Drive a mid-action state so the SCENE reads as "cooking in progress".
	_simulate(kind, inst)

	await get_tree().create_timer(wait_s).timeout
	var img := get_viewport().get_texture().get_image()
	var out_path: String = "%s/%s_%s.png" % [_userdir, name, _tag]
	var err := img.save_png(out_path)
	print("[cr] saved %s (err=%d) -> %s (%dx%d)" % [out_path, err,
		ProjectSettings.globalize_path(out_path), img.get_width(), img.get_height()])
	inst.queue_free()
	layer.queue_free()
	await get_tree().create_timer(0.3).timeout


# Push each module a little into its action so the screenshot is not a dead idle frame.
func _simulate(kind: String, inst: Control) -> void:
	match kind:
		"slice":
			# one drag down through the ingredient band -> a cut + a piece in the pile.
			_send_drag(inst, Vector2(540, 700), Vector2(540, 1200), 6)
		"season":
			# tilt-pour: grab near the bottle then sweep + tilt down a bit.
			_send_drag(inst, Vector2(740, 560), Vector2(560, 760), 8)
		"stir":
			# a circular swipe around the wok center.
			_send_circle(inst, Vector2(540, 816), 150.0, 1.0, 16)
		"timing":
			# drag the heat dial up toward the gold zone (heat ~0.85).
			_send_drag(inst, Vector2(130, 1000), Vector2(130, 660), 8)
		"roll":
			# two-finger push: left + right up together (partial roll).
			_send_two_finger(inst)
		"plate":
			pass  # plate shows the dish + 3 vessel cards on its own.


func _send_event(inst: Control, ev: InputEvent) -> void:
	# Route through the module's _input / _gui_input handlers.
	if inst.has_method("_input"):
		inst._input(ev)
	get_viewport().push_input(ev)


func _send_drag(inst: Control, from: Vector2, to: Vector2, steps: int) -> void:
	var touch_down := InputEventScreenTouch.new()
	touch_down.index = 0
	touch_down.position = from
	touch_down.pressed = true
	_send_event(inst, touch_down)
	var prev := from
	for i in range(1, steps + 1):
		var t: float = float(i) / float(steps)
		var p: Vector2 = from.lerp(to, t)
		var drag := InputEventScreenDrag.new()
		drag.index = 0
		drag.position = p
		drag.relative = p - prev
		_send_event(inst, drag)
		prev = p
	var touch_up := InputEventScreenTouch.new()
	touch_up.index = 0
	touch_up.position = to
	touch_up.pressed = false
	# NOTE: many modules finalize on release — for "in-progress" shots we hold (skip up)
	# for stir/timing; for slice/season a single cut/pour is fine to release.


func _send_circle(inst: Control, center: Vector2, radius: float, turns: float, steps: int) -> void:
	var start := center + Vector2(radius, 0)
	var td := InputEventScreenTouch.new()
	td.index = 0
	td.position = start
	td.pressed = true
	_send_event(inst, td)
	var prev := start
	for i in range(1, steps + 1):
		var a: float = float(i) / float(steps) * TAU * turns
		var p: Vector2 = center + Vector2(cos(a), sin(a)) * radius
		var dr := InputEventScreenDrag.new()
		dr.index = 0
		dr.position = p
		dr.relative = p - prev
		_send_event(inst, dr)
		prev = p
	# hold (no release) so the wok stays mid-stir for the shot.


func _send_two_finger(inst: Control) -> void:
	# Left finger (index 0) on left half, right finger (index 1) on right half, push up.
	var lx: float = 290.0
	var rx: float = 790.0
	var y0: float = 1230.0
	var ld := InputEventScreenTouch.new()
	ld.index = 0; ld.position = Vector2(lx, y0); ld.pressed = true
	_send_event(inst, ld)
	var rd := InputEventScreenTouch.new()
	rd.index = 1; rd.position = Vector2(rx, y0); rd.pressed = true
	_send_event(inst, rd)
	var steps := 8
	var prev_l := Vector2(lx, y0)
	var prev_r := Vector2(rx, y0)
	for i in range(1, steps + 1):
		var dy: float = float(i) / float(steps) * 300.0
		var pl := Vector2(lx, y0 - dy)
		var pr := Vector2(rx, y0 - dy * 0.92)  # slight imbalance for realistic meter
		var dl := InputEventScreenDrag.new()
		dl.index = 0; dl.position = pl; dl.relative = pl - prev_l
		_send_event(inst, dl)
		var dr := InputEventScreenDrag.new()
		dr.index = 1; dr.position = pr; dr.relative = pr - prev_r
		_send_event(inst, dr)
		prev_l = pl; prev_r = pr
	# hold (no release) so the half-rolled gimbap stays mid-action.
