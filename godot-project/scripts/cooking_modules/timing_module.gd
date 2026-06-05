## TimingModule — gauge fill with a Perfect window (ADR-011).
##
## A fill bar climbs from 0 → 100 over `duration_ms`. A "Perfect" zone occupies
## `perfect_width` (default 0.18 = ±9% of the bar around `perfect_at` (default 0.85).
## Player taps STOP once — distance from perfect-center = score.
##
## Phase A art-swap (2026-06-04): bar 위에 음식별 도구 표시 (라면=양은냄비 / 갈비=그릴
## / 콘도그=튀김기). gauge bar 자체는 gameplay 핵심이라 그대로 유지.
extends "res://scripts/cooking_modules/base_module.gd"

const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")

const DURATION_DEFAULT_MS: float = 3500.0
const PERFECT_AT_DEFAULT: float = 0.85
const PERFECT_WIDTH_DEFAULT: float = 0.18

var _start_ms: float = 0.0
var _duration_ms: float = DURATION_DEFAULT_MS
var _perfect_at: float = PERFECT_AT_DEFAULT
var _perfect_w: float = PERFECT_WIDTH_DEFAULT
var _stopped: bool = false
var _fill: ColorRect = null
var _track: ColorRect = null
var _zone: ColorRect = null
var _puck: ActionPuck = null
var _pct_lbl: Label = null


func _module_start(params: Dictionary) -> void:
	# D3: shared cooking BG + steam (boil/grill/deepfry feel)
	_attach_cooking_bg(700.0)
	_build_header("Timing", "Wait until the bar fills the GOLD zone — then tap STOP.")
	_start_ms = _now_ms()
	_duration_ms = float(params.get("duration_ms", DURATION_DEFAULT_MS))
	_perfect_at = float(params.get("perfect_at", PERFECT_AT_DEFAULT))
	_perfect_w = float(params.get("perfect_width", PERFECT_WIDTH_DEFAULT))

	# Phase A: 음식별 조리 도구 (pot / grill / deepfry) — bar 위쪽 (Y=300~900)
	# 도구만 표시 — food hero는 plate 단계에서 등장. 도구가 곧 "어떤 조리 기법인지" 메시지.
	var food_id: StringName = StringName(String(params.get("food_id", "")))
	var tool_path: String = ArtRegistry.timing_tool_for(food_id)
	if ArtRegistry.file_exists(tool_path):
		# D3: dish shadow + steam under cooking tool
		_attach_dish_shadow(Vector2(540, 880), 540.0)
		var tool_tex := TextureRect.new()
		tool_tex.texture = load(tool_path)
		tool_tex.position = Vector2(240, 300)
		tool_tex.size = Vector2(600, 600)
		tool_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tool_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tool_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(tool_tex)
		# Steam rising from the pot/grill (timing module is primarily boil/grill/fry)
		_attach_steam(Vector2(540, 380), 3)

	# Track bar (horizontal)
	_track = ColorRect.new()
	_track.color = Color(0, 0, 0, 0.18)
	_track.size = Vector2(900, 90)
	_track.position = Vector2(90, 1000)
	_track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_track)
	# Perfect zone (gold band)
	_zone = ColorRect.new()
	_zone.color = Color(0.98, 0.78, 0.22, 0.55)
	var zw: float = clampf(_perfect_w, 0.04, 0.4) * 900.0
	var zx: float = clampf(_perfect_at - _perfect_w * 0.5, 0.0, 1.0 - _perfect_w) * 900.0
	_zone.size = Vector2(zw, 90)
	_zone.position = Vector2(90 + zx, 1000)
	_zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_zone)
	# Fill (climbs)
	_fill = ColorRect.new()
	_fill.color = Color(0.86, 0.45, 0.22)
	_fill.size = Vector2(0, 90)
	_fill.position = Vector2(90, 1000)
	_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fill)

	# % readout
	_pct_lbl = Label.new()
	_pct_lbl.position = Vector2(0, 1140)
	_pct_lbl.size = Vector2(1080, 60)
	_pct_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pct_lbl.add_theme_font_size_override("font_size", 40)
	_pct_lbl.add_theme_color_override("font_color", Color(0.45, 0.32, 0.18))
	add_child(_pct_lbl)

	# D2: STOP action puck
	_puck = _make_action_puck(Vector2(540, 1560), "STOP", 320.0, 64)
	_puck.set_face_color(Color(0.78, 0.30, 0.18))
	_puck.pressed.connect(_on_stop)


func _process(_dt: float) -> void:
	if _finished or _stopped:
		return
	var f: float = clampf((_now_ms() - _start_ms) / _duration_ms, 0.0, 1.0)
	if is_instance_valid(_fill):
		_fill.size.x = f * 900.0
	if is_instance_valid(_pct_lbl):
		_pct_lbl.text = "%d%%" % int(round(f * 100.0))
	if f >= 1.0:
		# Auto-stop at 100% with low score (overcooked)
		_on_stop()


func _on_stop() -> void:
	if _finished or _stopped:
		return
	_stopped = true
	var f: float = clampf((_now_ms() - _start_ms) / _duration_ms, 0.0, 1.0)
	var dist: float = absf(f - _perfect_at)
	var half: float = maxf(_perfect_w * 0.5, 0.02)
	var score: float = 0.0
	if dist <= half:
		# inside gold zone: 100 at center, 65 at edge
		score = 100.0 - (dist / half) * 35.0
	else:
		# outside: linear falloff to 0 over 0.30 distance
		var over: float = clampf((dist - half) / 0.30, 0.0, 1.0)
		score = maxf(0.0, 65.0 * (1.0 - over))
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
