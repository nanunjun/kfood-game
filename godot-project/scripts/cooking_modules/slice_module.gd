## SliceModule — rhythm-tap chopping (ADR-011).
##
## Tools: knife + cutting_board. Player taps to the beat (BPM 70~140); each tap is
## judged ±perfect/good window from the target time. Final score = average tap accuracy
## scaled 0~100. Routes through FeedbackBus for the 5-stimulus juice.
##
## Phase A art-swap (2026-06-04): procedural cutting board → LOCK cutting_board.png +
## food-specific ingredient sprite (whole on top of board, cut overlay 강조). Gameplay
## (tap pad, score 계산) 무변경.
extends "res://scripts/cooking_modules/base_module.gd"

const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")

const TAP_COUNT_DEFAULT: int = 4
const BPM_DEFAULT: float = 110.0
const LEAD_IN_MS: float = 900.0

var _taps: Array = []          # [{target_ms, judged, score}]
var _idx_next: int = 0
var _start_ms: float = 0.0
var _board: Control = null
var _indicator: Label = null
var _puck: ActionPuck = null


func _module_start(params: Dictionary) -> void:
	# D3: shared cooking BG behind everything (dish anchor ~Y=1000 for cutting board area).
	_attach_cooking_bg(1000.0)
	_build_header("Slice", "Tap on each beat as the knife drops.")
	var tap_count: int = int(params.get("tap_count", TAP_COUNT_DEFAULT))
	var bpm: float = float(params.get("bpm", BPM_DEFAULT))
	var spacing_ms: float = 60000.0 / maxf(bpm, 1.0)
	_start_ms = _now_ms() + LEAD_IN_MS
	_taps.clear()
	for i in range(tap_count):
		_taps.append({"target_ms": _start_ms + float(i) * spacing_ms, "judged": false, "score": 0.0})
	_idx_next = 0

	# Cutting board — LOCK art if available, else procedural fallback.
	var food_id: StringName = StringName(String(params.get("food_id", "")))
	# D3: soft dish shadow under the board hero area.
	_attach_dish_shadow(Vector2(540, 1240), 460.0)
	_board = _build_board_with_art(food_id)
	add_child(_board)

	# Beat indicator label (counts down to next tap)
	_indicator = Label.new()
	_indicator.position = Vector2(40, 580)
	_indicator.size = Vector2(1000, 80)
	_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_indicator.add_theme_font_size_override("font_size", 56)
	_indicator.add_theme_color_override("font_color", Color(0.85, 0.55, 0.15))
	add_child(_indicator)

	# D2: unified circular ActionPuck (replaces rectangular TAP).
	_puck = _make_action_puck(Vector2(540, 1560), "TAP", 320.0, 64)
	_puck.pressed.connect(_on_tap)


# --- Phase A art helpers ---

## 음식별 hero whole sprite (LOCK art는 이미 도마+칼+재료 composite) 우선 표시.
## hero whole 없으면 cutting_board + cut_sliced_rounds 폴백, 둘 다 없으면 procedural Panel.
## 항상 TAP pad 위쪽 영역 (Y=880~1280)에 정확히 배치 — gameplay 좌표 무영향.
func _build_board_with_art(food_id: StringName) -> Control:
	var container := Control.new()
	container.position = Vector2(40, 720)
	container.size = Vector2(1000, 560)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var hero_path: String = ArtRegistry.prep_whole(food_id)
	if ArtRegistry.file_exists(hero_path):
		# Hero whole = 도마+칼+재료 composite (anchor art)
		var hero_tex := TextureRect.new()
		hero_tex.texture = load(hero_path)
		hero_tex.position = Vector2(200, 40)
		hero_tex.size = Vector2(600, 520)
		hero_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		hero_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hero_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		container.add_child(hero_tex)
	elif ArtRegistry.file_exists(ArtRegistry.slice_board()):
		# 폴백: 빈 도마 (재료 art 미존재 음식)
		var board_tex := TextureRect.new()
		board_tex.texture = load(ArtRegistry.slice_board())
		board_tex.position = Vector2(200, 40)
		board_tex.size = Vector2(600, 520)
		board_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		board_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		board_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		container.add_child(board_tex)
	else:
		# 최후 폴백: 기존 procedural board (legacy 시각 보장)
		var board_fb := Panel.new()
		board_fb.position = Vector2(250, 340)
		board_fb.size = Vector2(500, 220)
		var fbsb := StyleBoxFlat.new()
		fbsb.bg_color = Color(0.792, 0.612, 0.392)
		fbsb.set_corner_radius_all(36)
		fbsb.set_border_width_all(6)
		fbsb.border_color = Color(0.40, 0.27, 0.16)
		board_fb.add_theme_stylebox_override("panel", fbsb)
		board_fb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		container.add_child(board_fb)

	return container


func _process(_dt: float) -> void:
	if _finished:
		return
	var now := _now_ms()
	# Update indicator countdown
	if _idx_next < _taps.size() and is_instance_valid(_indicator):
		var dt: float = float(_taps[_idx_next]["target_ms"]) - now
		_indicator.text = "Beat %d/%d  ·  %.2fs" % [_idx_next + 1, _taps.size(), maxf(dt / 1000.0, 0.0)]
	# Auto-miss any tap whose good window expired
	var good: float = float(_level_get("good_ms", 200.0))
	for i in range(_taps.size()):
		var t: Dictionary = _taps[i]
		if not t["judged"] and now - float(t["target_ms"]) > good:
			t["judged"] = true
			t["score"] = 0.0
			_safe_feedback(RhythmJudge.MISS, Vector2(540, 1560))
			if is_instance_valid(_puck):
				_puck.flash_miss()
			if i == _idx_next:
				_idx_next += 1
	# All judged -> finalize
	if _all_judged():
		_finalize()


func _on_tap() -> void:
	if _finished:
		return
	var now := _now_ms()
	# Pick the unjudged tap with the smallest |dt|
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
	if best == _idx_next:
		_idx_next += 1
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
	var avg: float = total / float(maxi(1, _taps.size()))
	_finish(avg)


func _now_ms() -> float:
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("now_ms"):
		return float(bc.now_ms())
	return float(Time.get_ticks_msec())
