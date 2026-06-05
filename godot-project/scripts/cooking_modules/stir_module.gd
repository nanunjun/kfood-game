## StirModule — rhythm-tap stirring (ADR-011).
##
## Player taps a single big pad N times at a steady tempo (BPM 90~120). Score = average
## tap accuracy vs the metronome (perfect/good window per level).
##
## Phase A art-swap (2026-06-04): procedural dark circle "wok" → LOCK stirfry.png
## (웍+뒤집개) + 음식 hero ingredient art (예: 비빔밥 hero whole). Gameplay 무변경.
extends "res://scripts/cooking_modules/base_module.gd"

const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")

const TAP_COUNT_DEFAULT: int = 6
const BPM_DEFAULT: float = 105.0
const LEAD_IN_MS: float = 800.0

var _taps: Array = []
var _start_ms: float = 0.0
var _puck: ActionPuck = null
var _count_lbl: Label = null
var _hit_count: int = 0


func _module_start(params: Dictionary) -> void:
	# D3: shared cooking BG + steam (wok = boil/fry).
	_attach_cooking_bg(1000.0)
	_build_header("Stir", "Tap the STIR puck on every beat — keep the wok moving.")
	var tap_count: int = int(params.get("tap_count", TAP_COUNT_DEFAULT))
	var bpm: float = float(params.get("bpm", BPM_DEFAULT))
	var spacing := 60000.0 / maxf(bpm, 1.0)
	_start_ms = _now_ms() + LEAD_IN_MS
	_taps.clear()
	for i in range(tap_count):
		_taps.append({"target_ms": _start_ms + float(i) * spacing, "judged": false, "score": 0.0})

	# Phase A: 웍+뒤집개 LOCK art (stirfry.png) + 음식 완성 hero overlay (웍 안)
	# 좌표: art container Y=700~1280 (puck Y=1560 위쪽)
	var food_id: StringName = StringName(String(params.get("food_id", "")))
	# D3: dish shadow under wok area
	_attach_dish_shadow(Vector2(540, 1280), 540.0)
	var tool_path: String = ArtRegistry.TOOL_STIRFRY
	if ArtRegistry.file_exists(tool_path):
		var wok_tex := TextureRect.new()
		wok_tex.texture = load(tool_path)
		wok_tex.position = Vector2(140, 700)
		wok_tex.size = Vector2(800, 600)
		wok_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		wok_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		wok_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(wok_tex)
	else:
		var wok := Panel.new()
		wok.position = Vector2(240, 900)
		wok.size = Vector2(600, 360)
		var wsb := StyleBoxFlat.new()
		wsb.bg_color = Color(0.22, 0.20, 0.21)
		wsb.set_corner_radius_all(180)
		wok.add_theme_stylebox_override("panel", wsb)
		wok.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(wok)

	# 음식 완성 hero (food_img) overlay — 웍 위 중앙
	var food_img: String = ArtRegistry.food(food_id)
	if ArtRegistry.file_exists(food_img):
		var hero_tex := TextureRect.new()
		hero_tex.texture = load(food_img)
		hero_tex.position = Vector2(310, 850)
		hero_tex.size = Vector2(460, 320)
		hero_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		hero_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hero_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hero_tex.modulate = Color(1, 1, 1, 0.92)
		add_child(hero_tex)

	# D3: steam rising from wok center
	_attach_steam(Vector2(540, 960), 3)

	# D2: STIR action puck
	_puck = _make_action_puck(Vector2(540, 1560), "STIR", 340.0, 68)
	_puck.pressed.connect(_on_tap)

	_count_lbl = Label.new()
	_count_lbl.position = Vector2(0, 1820)
	_count_lbl.size = Vector2(1080, 60)
	_count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_count_lbl.add_theme_font_size_override("font_size", 36)
	_count_lbl.add_theme_color_override("font_color", Color(0.5, 0.35, 0.2))
	add_child(_count_lbl)


func _process(_dt: float) -> void:
	if _finished:
		return
	var now := _now_ms()
	if is_instance_valid(_count_lbl):
		_count_lbl.text = "Beat %d / %d" % [mini(_hit_count + 1, _taps.size()), _taps.size()]
	# Auto-miss past windows
	var good: float = float(_level_get("good_ms", 200.0))
	for t in _taps:
		if not t["judged"] and now - float(t["target_ms"]) > good:
			t["judged"] = true
			t["score"] = 0.0
			_hit_count += 1
			_safe_feedback(RhythmJudge.MISS, Vector2(540, 1560))
			if is_instance_valid(_puck):
				_puck.flash_miss()
	if _all_judged():
		_finalize()


func _on_tap() -> void:
	if _finished:
		return
	var now := _now_ms()
	var best: int = -1
	var best_d: float = 1e9
	for i in range(_taps.size()):
		if _taps[i]["judged"]:
			continue
		var d: float = absf(now - float(_taps[i]["target_ms"]))
		if d < best_d:
			best_d = d
			best = i
	if best < 0:
		return
	var perfect: float = float(_level_get("perfect_ms", 90.0))
	var good: float = float(_level_get("good_ms", 200.0))
	var j := RhythmJudge.judge(best_d, perfect, good)
	var score: float = 100.0 if j == RhythmJudge.PERFECT else (60.0 if j == RhythmJudge.GOOD else 0.0)
	_taps[best]["judged"] = true
	_taps[best]["score"] = score
	_hit_count += 1
	_safe_feedback(j, Vector2(540, 1560))
	if is_instance_valid(_puck):
		if j == RhythmJudge.PERFECT:
			_puck.flash_perfect()
		elif j == RhythmJudge.MISS:
			_puck.flash_miss()


func _all_judged() -> bool:
	for t in _taps:
		if not t["judged"]:
			return false
	return _taps.size() > 0


func _finalize() -> void:
	var total: float = 0.0
	for t in _taps:
		total += float(t["score"])
	_finish(total / float(maxi(1, _taps.size())))


func _now_ms() -> float:
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("now_ms"):
		return float(bc.now_ms())
	return float(Time.get_ticks_msec())
