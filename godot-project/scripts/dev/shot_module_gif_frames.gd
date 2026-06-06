## shot_module_gif_frames.gd — DEV CAPTURE HARNESS (gameplay 무변경).
##
## 8 cooking module 각각에 대해 "미니게임 한 판의 핵심 흐름"을 보여주는 8~12 frame
## PNG sequence를 캡처한다. main thread가 PIL로 GIF로 조립한다.
##
## 방식 (Option B hybrid — staged composite on REAL module scenes):
##   1. 실제 module .tscn를 instantiate → 진짜 CookingBackground + LOCK art + ActionPuck
##      + dish shadow + steam 비주얼을 그대로 사용 (가짜 합성 X).
##   2. module의 `start(params)` 호출로 정상 레이아웃 구성.
##   3. 곧바로 module의 `_finished` 플래그를 set하여 자체 _process(real-time gameplay
##      판정/auto-miss/auto-finalize/fill)를 동결. 8 module 모두 _process 첫 줄이
##      `if _finished: return` 계열이라 _finished=true 한 번으로 gameplay 루프가 완전히
##      멈춘다 (process_mode는 건드리지 않음 → puck bounce/sparkle 등 visual tween은
##      계속 살아있어 juice가 캡처됨). gameplay 코드는 1줄도 수정하지 않음.
##   4. per-module "stager"가 frame 단계별로 puck label/face/flash, fill bar, browning,
##      slot fill, cut overlay, sprinkle, roll progress, plate highlight를 직접 세팅.
##   5. 각 frame마다 viewport texture를 user://gif/{module}/{module}_frame_NN.png 로 저장.
##
## 실행:
##   <godot> --path godot-project --headless=false res://scenes/shot_module_gif_frames.tscn
##   (headless 금지 — 뷰포트 렌더가 필요. windowed로 실행해 캡처)
##
## 출력 → user://gif/{module}/ ; main shell이 assets-raw/_gif_frames/{module}/ 로 복사.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")
const ActionPuckScript := preload("res://scripts/ui/action_puck.gd")
const SparkleScript := preload("res://scripts/ui/premium/sparkle_particle.gd")

# Persimmon / gold / red palette mirrored from ActionPuck for staged tints.
const COL_IDLE := Color(0.878, 0.298, 0.141)
const COL_GOLD := Color(0.980, 0.780, 0.220)
const COL_GREEN := Color(0.30, 0.65, 0.30)

const OUT_ROOT := "user://gif"
const FRAME_PAUSE := 0.14   # settle window per staged frame before snapping

var _module_inst: CookingModule = null
var _frame_idx: int = 0
var _module_id: String = ""


func _ready() -> void:
	print("=== GIF frame capture — 8 cooking modules ===")
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_ROOT))

	await _run_module("slice",   "res://scenes/cooking/slice_module.tscn",   "t1_004", 1, {"tap_count": 4, "bpm": 110.0}, _stage_slice)
	await _run_module("arrange", "res://scenes/cooking/arrange_module.tscn", "t2_008", 1, {"slot_count": 5}, _stage_arrange)
	await _run_module("stir",    "res://scenes/cooking/stir_module.tscn",    "t2_008", 1, {"tap_count": 6, "bpm": 105.0}, _stage_stir)
	await _run_module("flip",    "res://scenes/cooking/flip_module.tscn",    "t1_006", 1, {"window_open_ms": 2200.0, "window_width_ms": 700.0}, _stage_flip)
	await _run_module("timing",  "res://scenes/cooking/timing_module.tscn",  "t1_002", 1, {"duration_ms": 3500.0, "perfect_at": 0.85, "perfect_width": 0.18}, _stage_timing)
	await _run_module("season",  "res://scenes/cooking/season_module.tscn",  "t1_003", 1, {}, _stage_season)
	await _run_module("roll",    "res://scenes/cooking/roll_module.tscn",    "t1_004", 1, {"target_ms": 800.0, "tol": 0.40}, _stage_roll)
	await _run_module("plate",   "res://scenes/cooking/plate_module.tscn",   "t1_003", 2, {}, _stage_plate)

	print("=== GIF frame capture done ===")
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


# --- module lifecycle --------------------------------------------------------

func _params(food_id: String, level_num: int, extra: Dictionary) -> Dictionary:
	var p: Dictionary = {
		"food_id": food_id,
		"guest_id": "junho",
		"level": MenuDB.get_level(level_num),
		"menu": MenuDB.get_menu(food_id),
		"step_no": 1,
		"step_total": 4,
	}
	for k in extra.keys():
		p[k] = extra[k]
	return p


## Instantiate the real module scene, start it, FREEZE its own process loop, then run a
## per-module stager callable that yields after each staged frame is captured.
func _run_module(module_id: String, scene_path: String, food_id: String,
		level_num: int, extra: Dictionary, stager: Callable) -> void:
	print("[gif] === %s (%s) ===" % [module_id, food_id])
	_module_id = module_id
	_frame_idx = 0
	DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path("%s/%s" % [OUT_ROOT, module_id]))

	var packed := load(scene_path) as PackedScene
	if packed == null:
		push_warning("[gif] cannot load " + scene_path)
		return
	var inst := packed.instantiate() as CookingModule
	get_tree().root.add_child(inst)
	inst.start(_params(food_id, level_num, extra))
	_module_inst = inst
	# Let the real _module_start layout + textures settle for one beat.
	await get_tree().create_timer(0.25).timeout
	# FREEZE the module's own gameplay loop so our staged state is authoritative.
	# Every module's _process early-returns on `_finished`, so this halts auto-miss /
	# auto-finalize / fill-climb without disabling the node (visual tweens keep running).
	inst.set("_finished", true)

	await stager.call()

	inst.queue_free()
	_module_inst = null
	await get_tree().create_timer(0.2).timeout


## Snap the current viewport into the next-numbered PNG for the active module.
func _snap() -> void:
	# Let staged state + visual tweens (puck bounce / sparkle) advance for a beat so the
	# captured frame shows the juice mid-flight, then snap.
	await get_tree().process_frame
	await get_tree().create_timer(FRAME_PAUSE).timeout
	var img := get_viewport().get_texture().get_image()
	var out_path := "%s/%s/%s_frame_%02d.png" % [OUT_ROOT, _module_id, _module_id, _frame_idx]
	var err := img.save_png(out_path)
	print("  frame %02d (err=%d) %dx%d -> %s" % [
		_frame_idx, err, img.get_width(), img.get_height(), out_path])
	_frame_idx += 1


# --- node lookup helpers (operate on the real module instance) ---------------

func _puck() -> ActionPuck:
	# Every module stores its puck in `_puck` (plate/arrange differ — handled inline).
	return _module_inst.get("_puck") as ActionPuck


func _find_first(type_name: String, root: Node = null) -> Node:
	var n: Node = root if root != null else _module_inst
	for c in n.get_children():
		if c.get_class() == type_name or c.is_class(type_name):
			return c
		var deep := _find_first(type_name, c)
		if deep != null:
			return deep
	return null


## Fire a one-shot sparkle burst at a viewport position (for the "perfect" beat) without
## relying on the module's frozen _process. Pure visual.
func _sparkle_at(center: Vector2, diam: float = 240.0) -> void:
	var sp = SparkleScript.new()
	sp.position = Vector2.ZERO
	_module_inst.add_child(sp)
	sp.burst(center, 18, diam, Color(1.0, 0.92, 0.50), 0.75)


## Manually drive a puck through a "perfect" flash (gold face + bounce + sparkle) even
## though the module is frozen — replicates ActionPuck.flash_perfect visuals on demand.
func _puck_perfect(p: ActionPuck) -> void:
	if not is_instance_valid(p):
		return
	p.set_face_color(COL_GOLD)
	p.set_label("PERFECT")
	var tw := p.create_tween()
	tw.tween_property(p, "scale", Vector2(1.20, 1.20), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(p, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	_sparkle_at(p.position + p.size * 0.5, p.diameter * 0.55)


# =============================================================================
# PER-MODULE STAGERS — each yields a 8~12 frame story (frame_00 → frame_NN).
# =============================================================================

## SLICE: board+knife idle → knife drops (beat) → puck active(tap) → perfect flash+
##        sparkle → cut result overlay. (10 frames)
func _stage_slice() -> void:
	var p := _puck()
	var board := _module_inst.get("_board") as Control
	# Add a "cut overlay" sprite (hidden) we reveal at the climax to show the result.
	var cut_overlay := _make_cut_overlay("t1_004", board)

	# f00 idle
	p.set_label("TAP")
	p.set_face_color(COL_IDLE)
	await _snap()
	# f01 indicator counts down (beat approaching)
	_set_indicator("Beat 1/4  ·  0.40s")
	await _snap()
	# f02 knife about to drop — indicator near zero, puck hover scale
	_set_indicator("Beat 1/4  ·  0.05s")
	p.scale = Vector2(1.05, 1.05)
	await _snap()
	# f03 puck ACTIVE (tap)
	p.scale = Vector2(0.95, 0.95)
	await _snap()
	# f04+05 PERFECT flash + sparkle (hold 2 frames for the juice)
	_puck_perfect(p)
	await _snap()
	await _snap()
	# f06 cut result begins to appear
	if cut_overlay:
		cut_overlay.modulate = Color(1, 1, 1, 0.5)
	_set_indicator("Beat 2/4")
	p.set_label("TAP")
	p.scale = Vector2.ONE
	await _snap()
	# f07 cut result fully visible
	if cut_overlay:
		cut_overlay.modulate = Color(1, 1, 1, 1.0)
	await _snap()
	# f08 second perfect tick
	_puck_perfect(p)
	_set_indicator("Beat 3/4")
	await _snap()
	# f09 done — all sliced, gold puck settles
	p.set_label("DONE")
	p.set_face_color(COL_GOLD)
	_set_indicator("Sliced!")
	await _snap()


## ARRANGE: empty slots + scattered ingredients → 1 placed → progress → all aligned.
##          (9 frames)
func _stage_arrange() -> void:
	var slots: Array = _module_inst.get("_slot_btns")
	var ings: Array = _module_inst.get("_ing_btns")
	# f00 empty slots, ingredients scattered
	await _snap()
	# Place ingredients one by one into correct slots (visual only).
	var n: int = mini(slots.size(), ings.size())
	for i in range(n):
		_fill_slot(slots[i], ings[i], true)
		# dim the placed ingredient
		if i < ings.size() and is_instance_valid(ings[i]):
			ings[i].modulate = Color(0.45, 0.45, 0.45, 0.6)
		await _snap()   # one frame per placement -> ~5 frames
	# f06 small celebratory sparkle over the slot row
	if slots.size() > 0 and is_instance_valid(slots[slots.size() / 2]):
		var mid: Button = slots[slots.size() / 2]
		_sparkle_at(mid.position + mid.size * 0.5, 360.0)
	await _snap()
	# f07 hold the completed arrangement
	await _snap()
	# f08 final aligned state (steady)
	await _snap()


## STIR: pan+spatula idle → STIR puck active → repeated motion → finished dish.
##       (9 frames)
func _stage_stir() -> void:
	var p := _puck()
	var lbl := _module_inst.get("_count_lbl") as Label
	# f00 idle
	p.set_label("STIR")
	p.set_face_color(COL_IDLE)
	if is_instance_valid(lbl): lbl.text = "Beat 1 / 6"
	await _snap()
	# 3 stir cycles: active -> perfect, rocking the puck like a stirring motion
	for beat in range(1, 5):
		# active dip
		p.scale = Vector2(0.95, 0.95)
		p.position.x = _puck_origin_x(p) + (12.0 if beat % 2 == 0 else -12.0)
		if is_instance_valid(lbl): lbl.text = "Beat %d / 6" % beat
		await _snap()
		# perfect flash
		_puck_perfect(p)
		p.position.x = _puck_origin_x(p)
		await _snap()
		p.set_label("STIR")
		p.set_face_color(COL_IDLE)
		p.scale = Vector2.ONE
	# final: dish done, gold settle (the food hero is already on the wok)
	p.set_label("DONE")
	p.set_face_color(COL_GOLD)
	if is_instance_valid(lbl): lbl.text = "Cooked!"
	await _snap()


## FLIP: pan+food browning → "FLIP!" window → puck tap perfect → flipped food.
##       (9 frames)
func _stage_flip() -> void:
	var p := _puck()
	var cake_tex := _module_inst.get("_cake_tex") as TextureRect
	var state_lbl := _module_inst.get("_state_lbl") as Label
	# helper to set browning progress on the food hero
	var brown := func(prog: float) -> void:
		if is_instance_valid(cake_tex):
			cake_tex.modulate = Color(1.05, 1.05, 0.92).lerp(Color(0.78, 0.55, 0.30), prog)
	# f00 raw, WAIT (grey)
	p.set_label("WAIT")
	p.set_face_color(Color(0.55, 0.50, 0.45))
	brown.call(0.0)
	if is_instance_valid(state_lbl): state_lbl.text = "watching it sizzle…"
	await _snap()
	# f01 browning
	brown.call(0.35)
	await _snap()
	# f02 nearly golden
	brown.call(0.6)
	await _snap()
	# f03 FLIP! window opens (puck turns orange)
	p.set_label("FLIP!")
	p.set_face_color(Color(0.86, 0.45, 0.22))
	if is_instance_valid(state_lbl): state_lbl.text = "★ FLIP NOW ★"
	brown.call(0.72)
	await _snap()
	# f04 puck active (tap)
	p.scale = Vector2(0.95, 0.95)
	await _snap()
	# f05+06 PERFECT flash + sparkle (hold)
	_puck_perfect(p)
	p.scale = Vector2.ONE
	await _snap()
	await _snap()
	# f07 flipped — show the other (golden) side: flip the texture horizontally + golden
	if is_instance_valid(cake_tex):
		cake_tex.scale = Vector2(-1, 1)
		cake_tex.pivot_offset = cake_tex.size * 0.5
		brown.call(1.0)
	if is_instance_valid(state_lbl): state_lbl.text = "Golden!"
	await _snap()
	# f08 done settle
	p.set_label("DONE")
	p.set_face_color(COL_GOLD)
	await _snap()


## TIMING: pot+gauge start → fill climbs → enters gold zone → STOP tap perfect → done.
##         (10 frames)
func _stage_timing() -> void:
	var p := _puck()
	var fill := _module_inst.get("_fill") as ColorRect
	var pct := _module_inst.get("_pct_lbl") as Label
	# perfect_at=0.85 → gold zone center; fill bar full width = 900px.
	var set_fill := func(f: float) -> void:
		if is_instance_valid(fill):
			fill.size.x = f * 900.0
			# tint the fill gold once inside the zone (>=0.76)
			fill.color = COL_GOLD if f >= 0.76 else Color(0.86, 0.45, 0.22)
		if is_instance_valid(pct):
			pct.text = "%d%%" % int(round(f * 100.0))
	p.set_label("STOP")
	p.set_face_color(Color(0.78, 0.30, 0.18))
	# f00..f04 fill climbs 0 → 0.75 (before gold zone)
	for f in [0.0, 0.20, 0.42, 0.62, 0.75]:
		set_fill.call(f)
		await _snap()
	# f05 enters GOLD zone
	set_fill.call(0.82)
	await _snap()
	# f06 dead-center of gold zone — STOP active
	set_fill.call(0.85)
	p.scale = Vector2(0.95, 0.95)
	await _snap()
	# f07+08 PERFECT flash + sparkle (hold)
	_puck_perfect(p)
	p.scale = Vector2.ONE
	await _snap()
	await _snap()
	# f09 done
	p.set_label("DONE")
	p.set_face_color(COL_GOLD)
	if is_instance_valid(pct): pct.text = "Perfect!"
	await _snap()


## SEASON: food + bottle → ADD puck tap → seasoning sprinkles → done. (9 frames)
func _stage_season() -> void:
	var p := _puck()
	# We add transient "sprinkle" dots falling from the bottle onto the food to show the
	# pour. Bottle is at ~(440..640, 900); food hero at ~(140..420, 880..1160).
	var sprinkles: Array[ColorRect] = []
	var make_sprinkle := func(x: float, y: float, col: Color) -> ColorRect:
		var d := ColorRect.new()
		d.color = col
		d.size = Vector2(18, 18)
		d.position = Vector2(x, y)
		d.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_module_inst.add_child(d)
		return d
	# f00 idle — food + bottle
	p.set_label("ADD")
	p.set_face_color(COL_IDLE)
	await _snap()
	# f01 puck active (tap to add)
	p.scale = Vector2(0.95, 0.95)
	await _snap()
	# f02 PERFECT flash (ADD = satisfying one-tap)
	_puck_perfect(p)
	p.scale = Vector2.ONE
	await _snap()
	# f03..f06 seasoning sprinkles fall over the food, accumulating
	var cols := [Color(0.82, 0.18, 0.12), Color(0.86, 0.30, 0.10), Color(0.70, 0.12, 0.10)]
	for step in range(4):
		for i in range(4):
			var sx := 200.0 + randf() * 220.0
			var sy := 900.0 + float(step) * 50.0 + randf() * 40.0
			sprinkles.append(make_sprinkle.call(sx, sy, cols[i % cols.size()]))
		await _snap()
	# f07 seasoned — sprinkles settled
	await _snap()
	# f08 done
	p.set_label("DONE")
	p.set_face_color(COL_GOLD)
	await _snap()


## ROLL: bamboo mat+kimbap → PRESS&HOLD → roll progresses (fill climbs) → finished roll.
##       (10 frames)
func _stage_roll() -> void:
	var p := _puck()
	var fill := _module_inst.get("_fill") as ColorRect
	var goal := _module_inst.get("_goal") as ColorRect
	var hint := _module_inst.get("_hint") as Label
	# food hero is a TextureRect at ~(380,840) 320x240 — we shrink its width slightly per
	# frame to fake the "rolling tighter" motion.
	var hero := _find_food_hero()
	var set_progress := func(f: float) -> void:
		if is_instance_valid(fill):
			fill.size.x = clampf(f, 0.0, 1.0) * 800.0
		if is_instance_valid(hero):
			# roll tighter: width shrinks toward a compact log
			hero.size.x = 320.0 - 90.0 * clampf(f, 0.0, 1.0)
			hero.position.x = 380.0 + 45.0 * clampf(f, 0.0, 1.0)
	# f00 idle — mat + loose kimbap, HOLD prompt
	p.set_label("HOLD")
	p.set_face_color(Color(0.55, 0.42, 0.22))
	if is_instance_valid(hint): hint.text = "Press and HOLD…"
	set_progress.call(0.0)
	await _snap()
	# f01 press begins (puck active dip)
	p.scale = Vector2(0.95, 0.95)
	if is_instance_valid(hint): hint.text = "Keep holding…"
	await _snap()
	# f02..f05 roll progresses, fill climbs, hero tightens
	for f in [0.25, 0.5, 0.7, 0.85]:
		set_progress.call(f)
		if f >= 0.85 and is_instance_valid(hint):
			hint.text = "★ Release NOW ★"
		await _snap()
	# f06 in GOAL zone — release
	set_progress.call(0.97)
	if is_instance_valid(goal):
		goal.color = COL_GOLD
	await _snap()
	# f07+08 PERFECT release flash + sparkle (hold)
	p.scale = Vector2.ONE
	_puck_perfect(p)
	await _snap()
	await _snap()
	# f09 done — tight finished roll
	p.set_label("DONE")
	p.set_face_color(COL_GOLD)
	if is_instance_valid(hint): hint.text = "Rolled!"
	await _snap()


## PLATE: finished food + 3 vessel options → vessel selected → plating complete.
##        (8 frames)
func _stage_plate() -> void:
	# plate has no `_puck`; it has 3 vessel Buttons added directly as children.
	var vessels: Array[Button] = []
	for c in _module_inst.get_children():
		if c is Button:
			vessels.append(c)
	# f00 — food + 3 vessel candidates
	await _snap()
	# f01 — hover/consider first option (slight scale up)
	if vessels.size() >= 1:
		_pulse_button(vessels[0], 1.04)
	await _snap()
	# f02 — consider the best vessel (assume index — we just walk all)
	if vessels.size() >= 2:
		_pulse_button(vessels[0], 1.0)
		_pulse_button(vessels[1], 1.04)
	await _snap()
	# f03 — pick the chosen vessel: highlight green border + scale, dim others
	var chosen: Button = vessels[mini(1, vessels.size() - 1)] if vessels.size() > 0 else null
	if chosen:
		for v in vessels:
			if v == chosen:
				_highlight_button(v, COL_GREEN, 1.08)
			else:
				v.modulate = Color(0.6, 0.6, 0.6, 0.7)
	await _snap()
	# f04+05 — plating sparkle over the chosen vessel (hold)
	if chosen:
		_sparkle_at(chosen.position + chosen.size * 0.5, 380.0)
	await _snap()
	await _snap()
	# f06 — "Plated!" banner-ish: pulse the food hero
	var hero := _find_food_hero()
	if is_instance_valid(hero):
		var tw := hero.create_tween()
		hero.pivot_offset = hero.size * 0.5
		tw.tween_property(hero, "scale", Vector2(1.08, 1.08), 0.18).set_trans(Tween.TRANS_BACK)
		tw.tween_property(hero, "scale", Vector2.ONE, 0.18)
	await _snap()
	# f07 — final settled plating
	await _snap()


# --- small staged-visual helpers --------------------------------------------

func _set_indicator(text: String) -> void:
	var ind := _module_inst.get("_indicator") as Label
	if is_instance_valid(ind):
		ind.text = text


func _puck_origin_x(p: ActionPuck) -> float:
	# puck is centered at x=540 (1080 viewport), size = diameter.
	return 540.0 - p.size.x * 0.5


## Build a cut-overlay TextureRect on top of the slice board to reveal at the climax.
func _make_cut_overlay(food_id: String, board: Control) -> TextureRect:
	var cut_path := ArtRegistry.prep_cut(StringName(food_id))
	if not ArtRegistry.file_exists(cut_path):
		return null
	var tex := TextureRect.new()
	tex.texture = load(cut_path)
	tex.position = Vector2(300, 1080)
	tex.size = Vector2(480, 240)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex.modulate = Color(1, 1, 1, 0.0)
	_module_inst.add_child(tex)
	return tex


## Fill an arrange slot with the ingredient's color + a ✓ — mirrors _on_slot visuals.
func _fill_slot(slot: Button, ing: Button, ok: bool) -> void:
	if not is_instance_valid(slot):
		return
	var sb := slot.get_theme_stylebox("normal") as StyleBoxFlat
	if sb:
		if is_instance_valid(ing):
			var isb := ing.get_theme_stylebox("normal") as StyleBoxFlat
			if isb:
				sb.bg_color = isb.bg_color
		sb.border_color = COL_GREEN if ok else Color(0.80, 0.30, 0.25)
	slot.text = "✓" if ok else "✕"


## Find the largest food-hero TextureRect inside the module (the dish image).
func _find_food_hero() -> TextureRect:
	var best: TextureRect = null
	var best_area := 0.0
	_collect_texrects(_module_inst, func(t: TextureRect) -> void:
		var area := t.size.x * t.size.y
		if area > best_area:
			best_area = area
			best = t)
	return best


func _collect_texrects(node: Node, cb: Callable) -> void:
	for c in node.get_children():
		if c is TextureRect:
			cb.call(c)
		_collect_texrects(c, cb)


func _pulse_button(b: Button, s: float) -> void:
	if not is_instance_valid(b):
		return
	b.pivot_offset = b.size * 0.5
	b.scale = Vector2(s, s)


func _highlight_button(b: Button, border: Color, s: float) -> void:
	if not is_instance_valid(b):
		return
	var sb := b.get_theme_stylebox("normal") as StyleBoxFlat
	if sb:
		sb.border_color = border
		sb.set_border_width_all(10)
	b.pivot_offset = b.size * 0.5
	b.scale = Vector2(s, s)
	b.modulate = Color(1, 1, 1, 1)
