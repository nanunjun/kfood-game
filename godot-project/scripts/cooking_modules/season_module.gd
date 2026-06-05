## SeasonModule — 1-tap auto-pour seasoning, or marinade rhythm (불고기) (ADR-011).
##
## Mode A (default, all 12 dishes except 불고기): single "Add Seasoning" button =
## auto-pours the recommended amount, score = 90 (designed to feel like a one-tap
## convenience action).
## Mode B (marinade rhythm — params.mode=="marinade"): N tap rhythm @ 60 BPM, score =
## average rhythm accuracy. Used by 불고기 (t2_014) to make seasoning feel earned.
##
## Phase A art-swap (2026-06-04): marinade 모드 bowl → LOCK marinate.png (양념 보울).
## Simple 모드는 procedural 양념 bottle 유지 (양념병 LOCK art 미발급).
extends "res://scripts/cooking_modules/base_module.gd"

const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")

const MARINADE_BPM: float = 60.0
const MARINADE_TAPS: int = 3
const LEAD_IN_MS: float = 900.0

var _mode: String = "simple"
var _taps: Array = []
var _start_ms: float = 0.0
var _puck: ActionPuck = null


func _module_start(params: Dictionary) -> void:
	# D3: shared cooking BG
	_attach_cooking_bg(1000.0)
	_mode = String(params.get("mode", "simple"))
	if _mode == "marinade":
		_start_marinade(params)
	else:
		_start_simple()


func _start_simple() -> void:
	_build_header("Season", "Tap the puck to add the recommended seasoning.")

	# Phase A: 어떤 음식에 양념을 더하는지 — 음식 hero (양념 placeholder 옆)
	var food_id_s: StringName = StringName(String(_params.get("food_id", "")))
	var food_img: String = ArtRegistry.food(food_id_s)
	if ArtRegistry.file_exists(food_img):
		var hero := TextureRect.new()
		hero.texture = load(food_img)
		hero.position = Vector2(140, 880)
		hero.size = Vector2(280, 280)
		hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(hero)

	# Big bottle illustration (placeholder shape)
	var bottle := Panel.new()
	bottle.position = Vector2(440, 900)
	bottle.size = Vector2(200, 340)
	var bsb := StyleBoxFlat.new()
	bsb.bg_color = Color(0.78, 0.20, 0.15)  # 고추장 red as the default
	bsb.set_corner_radius_all(40)
	bottle.add_theme_stylebox_override("panel", bsb)
	bottle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bottle)
	var cap := Panel.new()
	cap.position = Vector2(478, 860)
	cap.size = Vector2(124, 50)
	var csb := StyleBoxFlat.new()
	csb.bg_color = Color(0.30, 0.20, 0.12)
	csb.set_corner_radius_all(8)
	cap.add_theme_stylebox_override("panel", csb)
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cap)

	# D2: ADD action puck
	_puck = _make_action_puck(Vector2(540, 1560), "ADD", 320.0, 64)
	_puck.pressed.connect(_on_simple_add)


func _on_simple_add() -> void:
	if _finished:
		return
	_safe_feedback(RhythmJudge.GOOD, Vector2(540, 1560))
	if is_instance_valid(_puck):
		_puck.flash_perfect()
	_finish(90.0)


# --- Marinade mode (불고기) ---
func _start_marinade(params: Dictionary) -> void:
	_build_header("Marinade", "Tap the press pad on every beat — let the flavor soak in.")
	var taps: int = int(params.get("marinade_taps", MARINADE_TAPS))
	var bpm: float = float(params.get("marinade_bpm", MARINADE_BPM))
	var spacing := 60000.0 / maxf(bpm, 1.0)
	_start_ms = _now_ms() + LEAD_IN_MS
	for i in range(taps):
		_taps.append({"target_ms": _start_ms + float(i) * spacing, "judged": false, "score": 0.0})

	# Phase A: marinade 보울 LOCK art + 음식 hero ingredient (얇은 소고기 등)
	var food_id: StringName = StringName(String(params.get("food_id", "")))
	var bowl_path: String = ArtRegistry.TOOL_MARINATE
	if ArtRegistry.file_exists(bowl_path):
		var bowl_tex := TextureRect.new()
		bowl_tex.texture = load(bowl_path)
		bowl_tex.position = Vector2(240, 860)
		bowl_tex.size = Vector2(600, 400)
		bowl_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bowl_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		bowl_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(bowl_tex)
	else:
		var bowl := Panel.new()
		bowl.position = Vector2(290, 900)
		bowl.size = Vector2(500, 320)
		var bsb := StyleBoxFlat.new()
		bsb.bg_color = Color(0.30, 0.20, 0.12)
		bsb.set_corner_radius_all(160)
		bowl.add_theme_stylebox_override("panel", bsb)
		bowl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(bowl)

	# hero ingredient (얇은 소고기 등) — 보울 위
	var ing_path: String = ArtRegistry.prep_whole(food_id)
	if ArtRegistry.file_exists(ing_path):
		var ing_tex := TextureRect.new()
		ing_tex.texture = load(ing_path)
		ing_tex.position = Vector2(360, 940)
		ing_tex.size = Vector2(360, 240)
		ing_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ing_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ing_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(ing_tex)

	# D3: dish shadow under bowl
	_attach_dish_shadow(Vector2(540, 1280), 480.0)

	# D2: PRESS action puck
	_puck = _make_action_puck(Vector2(540, 1560), "PRESS", 320.0, 64)
	_puck.set_face_color(Color(0.55, 0.32, 0.20))
	_puck.pressed.connect(_on_marinade_tap)


func _process(_dt: float) -> void:
	if _mode != "marinade" or _finished:
		return
	var now := _now_ms()
	var good: float = float(_level_get("good_ms", 200.0))
	for t in _taps:
		if not t["judged"] and now - float(t["target_ms"]) > good:
			t["judged"] = true
			t["score"] = 0.0
			_safe_feedback(RhythmJudge.MISS, Vector2(540, 1560))
			if is_instance_valid(_puck):
				_puck.flash_miss()
	if _all_judged():
		var total: float = 0.0
		for t in _taps:
			total += float(t["score"])
		_finish(total / float(maxi(1, _taps.size())))


func _on_marinade_tap() -> void:
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


func _now_ms() -> float:
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("now_ms"):
		return float(bc.now_ms())
	return float(Time.get_ticks_msec())
