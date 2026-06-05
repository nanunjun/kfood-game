## FlipModule — single perfect-window tap (ADR-011).
##
## Pan-fry "FLIP NOW" moment. Window opens at `window_open_ms`, closes at
## `window_open_ms + window_width_ms`. Player taps once — closer to center = higher score.
## Late = 0. The pan-fry from the legacy rhythm_proto.gd had 2 flips; modules keep it to
## 1 single flip for clearer feel (legacy chained 2 flips inside a "panfry" phase).
##
## Phase A art-swap (2026-06-04): procedural pan + cake → LOCK panfry.png (팬+뒤집개)
## + 음식 hero ingredient. browning은 modulate로 art 위에서 표현.
extends "res://scripts/cooking_modules/base_module.gd"

const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")

const WINDOW_OPEN_DEFAULT_MS: float = 2500.0
const WINDOW_WIDTH_DEFAULT_MS: float = 700.0

var _start_ms: float = 0.0
var _open_ms: float = WINDOW_OPEN_DEFAULT_MS
var _width_ms: float = WINDOW_WIDTH_DEFAULT_MS
var _puck: ActionPuck = null
var _cake: Control = null            # Phase A: Panel 또는 TextureRect
var _cake_panel: Panel = null        # 폴백용 procedural Panel (browning용)
var _cake_tex: TextureRect = null    # LOCK art용 (modulate browning)
var _state_lbl: Label = null
var _flipped: bool = false
var _last_puck_state: String = "wait"   # "wait" / "ready" / "burnt"


func _module_start(params: Dictionary) -> void:
	# D3: shared cooking BG + dish shadow
	_attach_cooking_bg(1050.0)
	_build_header("Flip", "Watch it sizzle — tap FLIP the moment it turns gold.")
	_start_ms = _now_ms()
	_open_ms = float(params.get("window_open_ms", WINDOW_OPEN_DEFAULT_MS))
	_width_ms = float(params.get("window_width_ms", WINDOW_WIDTH_DEFAULT_MS))

	# Phase A: 팬+뒤집개 LOCK art + 음식 hero (browning은 modulate)
	var food_id: StringName = StringName(String(params.get("food_id", "")))
	# D3: dish shadow under pan
	_attach_dish_shadow(Vector2(540, 1280), 540.0)
	var pan_path: String = ArtRegistry.TOOL_PANFRY
	if ArtRegistry.file_exists(pan_path):
		var pan_tex := TextureRect.new()
		pan_tex.texture = load(pan_path)
		pan_tex.position = Vector2(240, 860)
		pan_tex.size = Vector2(600, 400)
		pan_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pan_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pan_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(pan_tex)
	else:
		var pan := Panel.new()
		pan.position = Vector2(240, 880)
		pan.size = Vector2(600, 360)
		var psb := StyleBoxFlat.new()
		psb.bg_color = Color(0.20, 0.18, 0.19)
		psb.set_corner_radius_all(180)
		pan.add_theme_stylebox_override("panel", psb)
		pan.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(pan)

	# Cake/pancake — LOCK food hero overlay on pan (browning via modulate)
	var food_img: String = ArtRegistry.food(food_id)
	if ArtRegistry.file_exists(food_img):
		_cake_tex = TextureRect.new()
		_cake_tex.texture = load(food_img)
		_cake_tex.position = Vector2(330, 920)
		_cake_tex.size = Vector2(420, 280)
		_cake_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_cake_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_cake_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_cake_tex.modulate = Color(1.05, 1.05, 0.92, 1)  # raw-ish tint
		add_child(_cake_tex)
		_cake = _cake_tex
	else:
		_cake_panel = Panel.new()
		_cake_panel.position = Vector2(330, 940)
		_cake_panel.size = Vector2(420, 240)
		var csb := StyleBoxFlat.new()
		csb.bg_color = Color(0.93, 0.86, 0.62)  # raw -> browns over time
		csb.set_corner_radius_all(120)
		_cake_panel.add_theme_stylebox_override("panel", csb)
		_cake_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_cake_panel)
		_cake = _cake_panel

	# D3: steam from pan (light, panfry feels)
	_attach_steam(Vector2(540, 940), 2)

	# D2: FLIP action puck (face color updated on state in _process)
	_puck = _make_action_puck(Vector2(540, 1560), "WAIT", 320.0, 64)
	_puck.set_face_color(Color(0.55, 0.50, 0.45))
	_puck.pressed.connect(_on_flip)

	_state_lbl = Label.new()
	_state_lbl.position = Vector2(0, 1820)
	_state_lbl.size = Vector2(1080, 60)
	_state_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_state_lbl.add_theme_font_size_override("font_size", 32)
	_state_lbl.add_theme_color_override("font_color", Color(0.5, 0.35, 0.2))
	add_child(_state_lbl)


func _process(_dt: float) -> void:
	if _finished or _flipped:
		return
	var elapsed: float = _now_ms() - _start_ms
	# Brown the cake gradually (procedural Panel: bg_color lerp / TextureRect: modulate lerp)
	var prog: float = clampf(elapsed / (_open_ms + _width_ms), 0.0, 1.0)
	if is_instance_valid(_cake_panel):
		var sb := _cake_panel.get_theme_stylebox("panel") as StyleBoxFlat
		if sb:
			sb.bg_color = Color(0.93, 0.86, 0.62).lerp(Color(0.74, 0.45, 0.16), prog)
	if is_instance_valid(_cake_tex):
		# 골든 갈색 tint으로 modulate — 진한 갈색으로 점진
		_cake_tex.modulate = Color(1.05, 1.05, 0.92).lerp(Color(0.78, 0.55, 0.30), prog)
	var open := elapsed >= _open_ms and elapsed <= _open_ms + _width_ms
	var post := elapsed > _open_ms + _width_ms
	if is_instance_valid(_puck):
		var new_state: String = "ready" if open else ("wait" if not post else "burnt")
		if new_state != _last_puck_state:
			_last_puck_state = new_state
			match new_state:
				"wait":
					_puck.set_label("WAIT")
					_puck.set_face_color(Color(0.55, 0.50, 0.45))
				"ready":
					_puck.set_label("FLIP!")
					_puck.set_face_color(Color(0.86, 0.45, 0.22))
				"burnt":
					_puck.set_label("BURNT")
					_puck.set_face_color(Color(0.40, 0.20, 0.18))
	if is_instance_valid(_state_lbl):
		_state_lbl.text = ("★ FLIP NOW ★" if open else
			("watching it sizzle…" if not post else "Too late! It burnt."))
	if post:
		# Auto-finish with 0
		_flipped = true
		_safe_feedback(RhythmJudge.MISS, Vector2(540, 1560))
		if is_instance_valid(_puck):
			_puck.flash_miss()
		_finish(0.0)


func _on_flip() -> void:
	if _finished or _flipped:
		return
	var elapsed: float = _now_ms() - _start_ms
	var center: float = _open_ms + _width_ms * 0.5
	var dist: float = absf(elapsed - center)
	var half: float = _width_ms * 0.5
	if dist > half:
		# Tapped before window OR after — early/late = 0
		_flipped = true
		_safe_feedback(RhythmJudge.MISS, Vector2(540, 1560))
		if is_instance_valid(_puck):
			_puck.flash_miss()
		_finish(0.0)
		return
	# Inside window: linear score 100 at center → 50 at edges
	var score: float = 100.0 - (dist / half) * 50.0
	var j := RhythmJudge.PERFECT if score >= 80.0 else RhythmJudge.GOOD
	_flipped = true
	_safe_feedback(j, Vector2(540, 1560))
	if is_instance_valid(_puck):
		if j == RhythmJudge.PERFECT:
			_puck.flash_perfect()
	_finish(score)


func _now_ms() -> float:
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("now_ms"):
		return float(bc.now_ms())
	return float(Time.get_ticks_msec())
