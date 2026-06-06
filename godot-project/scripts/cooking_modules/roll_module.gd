## RollModule — ACTION-FIRST forward-drag bamboo-mat rolling (ADR-012). ★
##
## "I rolled the gimbap" — NOT "I held a button". The player drags the bamboo mat (김발)
## FORWARD (away from them, up the screen); the seaweed + rice + fillings progressively
## curl into a tight cylinder as the drag advances. Where the player RELEASES decides the
## shape quality — release in the sweet zone = a firm, round roll.
##
## ADR-012 input redesign (2026-06-05): ActionPuck HOLD timer 폐기 → forward drag + release.
##   - input: 김발을 앞으로 미는 forward drag (drag distance = roll progress) + release timing.
##   - visual: 김+밥+재료 visible → drag로 김밥이 점진적으로 말림(roll 형성) → release가 shape 결정.
##   - 3 states: 덜 말림 (drag 짧음) / 단단한 원통 (적정 drag + release) / 터짐 (drag 과다·너무 빠름).
##
## SCORING 무변경 (§6.1): roll 완성도(drag로 도달한 말림 정도) + release timing(sweet zone 근접)
## → accuracy(cook factor) ∈ [0,1]. 기존 hold-score가 만들던 도메인과 동일한 [0,100] score를
## 그대로 `module_completed(score)` 로 emit — runner contract / MODULE_TO_FACTOR("roll"->prep) 동일.
extends "res://scripts/cooking_modules/base_module.gd"

const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")
const TouchGesture := preload("res://scripts/cooking_modules/touch_gesture.gd")

# 김발 시작/끝 화면 Y (forward = 위로 = 작은 Y). drag로 mat을 START_Y → 위로 민다.
const MAT_START_Y: float = 1160.0
const MAT_TRAVEL: float = 560.0          # 완전한 roll까지 필요한 forward drag 거리(px).
const ROLL_X: float = 540.0              # roll 중심 X.

# release sweet zone — roll progress(0~1)에서 적정 완성 구간.
const SWEET_LO_DEFAULT: float = 0.82
const SWEET_HI_DEFAULT: float = 1.02

# 너무 빠른 forward drag = 터짐 risk (avg_speed 상한, px/sec).
const BURST_SPEED: float = 4200.0

var _sweet_lo: float = SWEET_LO_DEFAULT
var _sweet_hi: float = SWEET_HI_DEFAULT

# roll 진행 상태.
var _roll_progress: float = 0.0          # 0(평평) ~ 1.2(과다·터짐) — forward drag로 증가.
var _drag_start_y: float = 0.0
var _rolling: bool = false
var _peak_speed: float = 0.0             # drag 중 최고 속도 (터짐 판정).

# 시각 nodes.
var _mat: Control = null                 # 김발 (LOCK roll.png 또는 procedural strip)
var _mat_node2d: Node2D = null           # 회전 적용용 wrapper (procedural fallback)
var _roll_hero: TextureRect = null       # 김밥 음식 sprite (말리며 scale/round)
var _fillings: Array = []                # 재료 토큰 (말리며 안으로 빨려듦)
var _gesture = null   # TouchGestureRecognizer (preloaded TouchGesture)
var _hint: Label = null
var _track: ColorRect = null
var _sweet_band: ColorRect = null
var _fill_marker: ColorRect = null


func _module_start(params: Dictionary) -> void:
	_attach_cooking_bg(1000.0)
	_build_header("Roll", "Push the bamboo mat forward to roll the gimbap — release when it's round.")
	_sweet_lo = float(params.get("sweet_lo", SWEET_LO_DEFAULT))
	_sweet_hi = float(params.get("sweet_hi", SWEET_HI_DEFAULT))

	var food_id: StringName = StringName(String(params.get("food_id", "")))
	_attach_dish_shadow(Vector2(ROLL_X, 1100.0), 560.0)

	# 김밥 음식 hero (food_img) — 김 + 밥 + 재료 visible. 말리며 round해짐.
	var food_img: String = ArtRegistry.food(food_id)
	if ArtRegistry.file_exists(food_img):
		_roll_hero = TextureRect.new()
		_roll_hero.texture = load(food_img)
		_roll_hero.position = Vector2(ROLL_X - 250, 900)
		_roll_hero.size = Vector2(500, 300)
		_roll_hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_roll_hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_roll_hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_roll_hero.pivot_offset = Vector2(250, 150)
		add_child(_roll_hero)

	# 재료 토큰 (김밥 속 — 김 위에 깔린 재료들). 말리면 안으로 빨려 들어감.
	_build_fillings(food_id)

	# 김발 (roll.png LOCK = bamboo_mat). procedural fallback = green strip.
	_mat_node2d = Node2D.new()
	_mat_node2d.z_index = 20
	_mat_node2d.position = Vector2(ROLL_X, MAT_START_Y)
	add_child(_mat_node2d)
	var mat_path: String = ArtRegistry.TOOL_ROLL
	if ArtRegistry.file_exists(mat_path):
		var mat_tex := TextureRect.new()
		mat_tex.texture = load(mat_path)
		mat_tex.position = Vector2(-400, -120)
		mat_tex.size = Vector2(800, 280)
		mat_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		mat_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		mat_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_mat_node2d.add_child(mat_tex)
		_mat = mat_tex
	else:
		var strip := ColorRect.new()
		strip.color = Color(0.42, 0.55, 0.30)
		strip.size = Vector2(700, 200)
		strip.position = Vector2(-350, -100)
		strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# bamboo 줄무늬.
		for i in range(9):
			var line := ColorRect.new()
			line.color = Color(0.30, 0.42, 0.22)
			line.size = Vector2(6, 200)
			line.position = Vector2(float(i) * 78.0, 0)
			line.mouse_filter = Control.MOUSE_FILTER_IGNORE
			strip.add_child(line)
		_mat_node2d.add_child(strip)
		_mat = strip

	# 진행 track + sweet band + 마커.
	_build_progress_ui()

	_hint = Label.new()
	_hint.position = Vector2(0, 1540)
	_hint.size = Vector2(1080, 70)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 42)
	_hint.add_theme_color_override("font_color", Color(0.45, 0.32, 0.18))
	_hint.text = "Push the mat forward ↑"
	add_child(_hint)

	# 입력 인식기 — forward drag.
	_gesture = TouchGesture.new()
	_gesture.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_gesture)
	_gesture.drag_started.connect(_on_drag_started)
	_gesture.drag_updated.connect(_on_drag_updated)
	_gesture.drag_released.connect(_on_drag_released)


func _build_fillings(food_id: StringName) -> void:
	var cut_path: String = ArtRegistry.prep_cut(food_id)
	var has_cut: bool = ArtRegistry.file_exists(cut_path)
	var cols := [
		Color(0.92, 0.38, 0.26), Color(0.96, 0.86, 0.34),
		Color(0.50, 0.78, 0.36), Color(0.94, 0.92, 0.86), Color(0.55, 0.40, 0.28),
	]
	var n: int = 5
	for i in range(n):
		var token: Control
		if has_cut:
			var t := TextureRect.new()
			t.texture = load(cut_path)
			t.size = Vector2(80, 80)
			t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			token = t
		else:
			var c := ColorRect.new()
			c.color = cols[i % cols.size()]
			c.size = Vector2(60, 60)
			token = c
		token.mouse_filter = Control.MOUSE_FILTER_IGNORE
		token.z_index = 8
		var base_x: float = ROLL_X - 180.0 + float(i) * 90.0
		token.position = Vector2(base_x - token.size.x * 0.5, 1000.0)
		add_child(token)
		_fillings.append({"node": token, "base_x": base_x, "size": token.size})


func _build_progress_ui() -> void:
	_track = ColorRect.new()
	_track.color = Color(0, 0, 0, 0.15)
	_track.size = Vector2(800, 60)
	_track.position = Vector2(140, 1420)
	_track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_track)
	# sweet zone band (적정 release 구간).
	_sweet_band = ColorRect.new()
	_sweet_band.color = Color(0.98, 0.78, 0.22, 0.55)
	var bx0: float = 140.0 + clampf(_sweet_lo, 0.0, 1.0) * 800.0
	var bx1: float = 140.0 + clampf(_sweet_hi, 0.0, 1.0) * 800.0
	_sweet_band.position = Vector2(bx0, 1420)
	_sweet_band.size = Vector2(maxf(bx1 - bx0, 20.0), 60.0)
	_sweet_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_sweet_band)
	# 진행 마커.
	_fill_marker = ColorRect.new()
	_fill_marker.color = Color(0.30, 0.20, 0.12)
	_fill_marker.size = Vector2(12, 76)
	_fill_marker.position = Vector2(140 - 6, 1412)
	_fill_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fill_marker)


# --- gesture handlers: forward drag ---

func _on_drag_started(pos: Vector2) -> void:
	if _finished:
		return
	_rolling = true
	_drag_start_y = pos.y
	_peak_speed = 0.0


func _on_drag_updated(pos: Vector2, vel: Vector2) -> void:
	if _finished or not _rolling:
		return
	# forward = 위로 = 손가락이 위로 이동(Δy 음수). roll progress = forward 이동량 / MAT_TRAVEL.
	var forward: float = maxf(_drag_start_y - pos.y, 0.0)
	_roll_progress = clampf(forward / MAT_TRAVEL, 0.0, 1.2)
	_peak_speed = maxf(_peak_speed, vel.length())
	_apply_roll_visual()
	_update_hint()


func _on_drag_released(info: Dictionary) -> void:
	if _finished or not _rolling:
		return
	_rolling = false
	# 터짐 판정: drag가 너무 빠르면 (avg_speed 또는 peak) shape 망가짐.
	var avg_speed: float = float(info.get("avg_speed", 0.0))
	var burst: bool = avg_speed > BURST_SPEED or _peak_speed > BURST_SPEED * 1.3
	_finalize_roll(burst)


# --- roll visual: 김밥이 점진적으로 말림 ---

func _apply_roll_visual() -> void:
	var p: float = _roll_progress
	# 김발이 앞으로(위로) 이동하며 살짝 회전 (말리는 손동작).
	if is_instance_valid(_mat_node2d):
		_mat_node2d.position.y = MAT_START_Y - clampf(p, 0.0, 1.0) * MAT_TRAVEL
		_mat_node2d.rotation = -clampf(p, 0.0, 1.0) * 0.35
	# 김밥 hero: 말릴수록 가로폭 줄고(원통화) 살짝 회전 + 들어올려짐.
	if is_instance_valid(_roll_hero):
		var roundness: float = clampf(p, 0.0, 1.0)
		_roll_hero.scale = Vector2(1.0 - roundness * 0.42, 1.0 + roundness * 0.10)
		_roll_hero.rotation = roundness * 0.18
		_roll_hero.position.y = 900.0 - roundness * 40.0
		# 과다(터짐 직전) — 살짝 빨개지며 부풀음 경고.
		if p > 1.0:
			var over: float = clampf((p - 1.0) / 0.2, 0.0, 1.0)
			_roll_hero.modulate = Color(1, 1, 1).lerp(Color(1.0, 0.7, 0.6), over)
			_roll_hero.scale = Vector2(0.58 + over * 0.12, 1.10 + over * 0.10)
		else:
			_roll_hero.modulate = Color(1, 1, 1)
	# 재료 토큰 — 말리며 중앙으로 빨려 들어감.
	for f in _fillings:
		var node: Control = f["node"]
		if not is_instance_valid(node):
			continue
		var base_x: float = float(f["base_x"])
		var sz: Vector2 = f["size"]
		var pull: float = clampf(p, 0.0, 1.0)
		var x: float = lerpf(base_x, ROLL_X, pull)
		node.position.x = x - sz.x * 0.5
		node.modulate = Color(1, 1, 1, clampf(1.0 - pull * 0.85, 0.1, 1.0))   # 김 속으로 사라짐
	# 진행 마커.
	if is_instance_valid(_fill_marker):
		_fill_marker.position.x = 140.0 + clampf(p, 0.0, 1.0) * 800.0 - 6.0


func _update_hint() -> void:
	if not is_instance_valid(_hint):
		return
	var p: float = _roll_progress
	if p < _sweet_lo - 0.1:
		_hint.text = "Keep pushing forward…"
	elif p >= _sweet_lo and p <= _sweet_hi:
		_hint.text = "★ Round! Release NOW ★"
	elif p > _sweet_hi:
		_hint.text = "Careful — it'll burst!"
	else:
		_hint.text = "Almost there…"


# --- scoring (§6.1) — roll 완성도 + release timing → [0,100] ---

func _finalize_roll(burst: bool) -> void:
	var score: float = _compute_roll_score(_roll_progress, burst)
	var j := RhythmJudge.PERFECT if score >= 80.0 else (RhythmJudge.GOOD if score >= 40.0 else RhythmJudge.MISS)
	_safe_feedback(j, Vector2(ROLL_X, 1000.0))
	if is_instance_valid(_hint):
		if score >= 80.0:
			_hint.text = "Tight, round roll!"
		elif _roll_progress < _sweet_lo - 0.1:
			_hint.text = "Too loose — under-rolled"
		elif burst or _roll_progress > _sweet_hi:
			_hint.text = "It burst!"
		else:
			_hint.text = "Done"
	# 완성 시각: 단단한 roll이면 둥글게 settle.
	if is_instance_valid(_roll_hero) and score >= 60.0 and not burst:
		var tw := _roll_hero.create_tween()
		tw.tween_property(_roll_hero, "scale", Vector2(0.58, 1.12), 0.18)
	_finish(score)


## §6.1 — roll 품질 → [0,100]. 두 축:
##   (1) roll 완성도 = release 시점의 roll_progress가 sweet zone에 얼마나 근접한가
##       (덜 말림 = under, 과다 = 터짐).
##   (2) release timing = sweet zone 안 = 만점, 벗어날수록 비례 감소.
## burst(너무 빠른 drag)는 상한 cap. 도메인은 기존 hold-score(0~1 ×100)와 동일 [0,100].
## 외부(smoke)에서 progress/burst를 직접 주입해 호출 가능하도록 인자로 받음.
func _compute_roll_score(progress: float, burst: bool) -> float:
	var p: float = clampf(progress, 0.0, 1.2)
	var score: float
	if p < _sweet_lo:
		# 덜 말림 — sweet_lo에 가까울수록 점수 상승 (0 ~ 80).
		var t: float = clampf(p / maxf(_sweet_lo, 0.01), 0.0, 1.0)
		score = t * 80.0
	elif p <= _sweet_hi:
		# 적정 — sweet zone 중앙에 가까울수록 만점 (80 ~ 100).
		var mid: float = (_sweet_lo + _sweet_hi) * 0.5
		var half: float = maxf((_sweet_hi - _sweet_lo) * 0.5, 0.01)
		var closeness: float = clampf(1.0 - absf(p - mid) / half, 0.0, 1.0)
		score = 80.0 + closeness * 20.0
	else:
		# 과다 — sweet_hi 넘으면 터짐 쪽으로 감소 (80 → 0).
		var over: float = clampf((p - _sweet_hi) / 0.18, 0.0, 1.0)
		score = 80.0 * (1.0 - over)
	# 터짐 = drag 너무 빠름 → 추가 cap.
	if burst:
		score = minf(score, 35.0)
	return clampf(score, 0.0, 100.0)


func _now_ms() -> float:
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("now_ms"):
		return float(bc.now_ms())
	return float(Time.get_ticks_msec())
