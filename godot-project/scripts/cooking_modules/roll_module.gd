## RollModule — swipe / hold-and-drag motion (ADR-011).
##
## MVP: hold the PRESS pad for `target_ms` (~700ms default). Hold-score formula =
## RhythmJudge.hold_score scaled to 0~100. Future polish: full bamboo-mat swipe gesture.
##
## Phase A art-swap (2026-06-04): procedural green bamboo strip → LOCK roll.png (김발).
## 음식 hero (김밥) 김발 위 overlay. gameplay (track/fill/goal/hold) 무변경.
extends "res://scripts/cooking_modules/base_module.gd"

const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")

const TARGET_MS_DEFAULT: float = 700.0
const TOL_DEFAULT: float = 0.45

var _target_ms: float = TARGET_MS_DEFAULT
var _tol: float = TOL_DEFAULT
var _press_start_ms: float = 0.0
var _is_pressing: bool = false
var _puck: ActionPuck = null
var _fill: ColorRect = null
var _track: ColorRect = null
var _goal: ColorRect = null
var _hint: Label = null


func _module_start(params: Dictionary) -> void:
	# D3: shared cooking BG + dish shadow under mat
	_attach_cooking_bg(900.0)
	_build_header("Roll", "Press & HOLD — release in the GOAL zone.")
	_target_ms = float(params.get("target_ms", TARGET_MS_DEFAULT))
	_tol = float(params.get("tol", TOL_DEFAULT))

	# Phase A: 김발 LOCK art (roll.png) + 김밥 hero overlay
	var food_id: StringName = StringName(String(params.get("food_id", "")))
	_attach_dish_shadow(Vector2(540, 1080), 540.0)
	var mat_path: String = ArtRegistry.TOOL_ROLL
	if ArtRegistry.file_exists(mat_path):
		var mat_tex := TextureRect.new()
		mat_tex.texture = load(mat_path)
		mat_tex.position = Vector2(140, 800)
		mat_tex.size = Vector2(800, 320)
		mat_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		mat_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		mat_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(mat_tex)
	else:
		var mat := ColorRect.new()
		mat.color = Color(0.20, 0.32, 0.22)
		mat.size = Vector2(800, 220)
		mat.position = Vector2(140, 880)
		mat.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(mat)

	# 김밥(또는 음식) hero — 김발 위 중앙
	var food_img: String = ArtRegistry.food(food_id)
	if ArtRegistry.file_exists(food_img):
		var hero := TextureRect.new()
		hero.texture = load(food_img)
		hero.position = Vector2(380, 840)
		hero.size = Vector2(320, 240)
		hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(hero)

	# Track + fill + goal
	_track = ColorRect.new()
	_track.color = Color(0, 0, 0, 0.15)
	_track.size = Vector2(800, 80)
	_track.position = Vector2(140, 1140)
	_track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_track)
	_goal = ColorRect.new()
	_goal.color = Color(0.98, 0.78, 0.22, 0.55)
	_goal.size = Vector2(120, 80)
	_goal.position = Vector2(140 + 680 - 60, 1140)
	_goal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_goal)
	_fill = ColorRect.new()
	_fill.color = Color(0.55, 0.42, 0.22)
	_fill.size = Vector2(0, 80)
	_fill.position = Vector2(140, 1140)
	_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fill)

	_hint = Label.new()
	_hint.position = Vector2(0, 1260)
	_hint.size = Vector2(1080, 60)
	_hint.text = "Press and HOLD…"
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 36)
	_hint.add_theme_color_override("font_color", Color(0.45, 0.32, 0.18))
	add_child(_hint)

	# D2: HOLD action puck — button_down / button_up signals forwarded from puck
	_puck = _make_action_puck(Vector2(540, 1560), "HOLD", 320.0, 60)
	_puck.set_face_color(Color(0.55, 0.42, 0.22))
	_puck.button_down.connect(_on_press)
	_puck.button_up.connect(_on_release)


func _process(_dt: float) -> void:
	if _finished or not _is_pressing:
		return
	var held: float = _now_ms() - _press_start_ms
	var f: float = clampf(held / _target_ms, 0.0, 1.2)
	if is_instance_valid(_fill):
		_fill.size.x = clampf(f, 0.0, 1.0) * 800.0
	if is_instance_valid(_hint):
		if f < 0.6:
			_hint.text = "Keep holding…"
		elif f >= 0.85 and f <= 1.05:
			_hint.text = "★ Release NOW ★"
		elif f > 1.05:
			_hint.text = "Too far!"


func _on_press() -> void:
	if _finished:
		return
	_is_pressing = true
	_press_start_ms = _now_ms()


func _on_release() -> void:
	if _finished or not _is_pressing:
		return
	_is_pressing = false
	var held: float = _now_ms() - _press_start_ms
	var raw: float = RhythmJudge.hold_score(_target_ms, held, _tol)  # 0~1
	var score: float = raw * 100.0
	var j := RhythmJudge.PERFECT if score >= 80.0 else (RhythmJudge.GOOD if score >= 40.0 else RhythmJudge.MISS)
	_safe_feedback(j, Vector2(540, 1560))
	if is_instance_valid(_puck):
		if j == RhythmJudge.PERFECT:
			_puck.flash_perfect()
		elif j == RhythmJudge.MISS:
			_puck.flash_miss()
	_finish(score)


func _now_ms() -> float:
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("now_ms"):
		return float(bc.now_ms())
	return float(Time.get_ticks_msec())
