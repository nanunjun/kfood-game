## FlipModule — ACTION-FIRST directional flick flipping (ADR-012).
##
## "I flipped the pancake" — NOT "I tapped a beat". The player FLICKS the food with a fast
## directional swipe; the food launches into the air, spins along an arc, and lands on the
## other face. The flick's velocity vector (direction + speed) drives the spin — too weak =
## a half-flip flop, ideal = a clean one-rotation landing, too hard = it over-rotates.
##
## ADR-012 input redesign (2026-06-05): ActionPuck FLIP single-window tap 폐기 → directional flick.
##   - input: 빠른 directional swipe (속도 벡터). swipe-up / 회전 / 좌우 — variant별 목표 방향.
##   - visual: 음식이 flick 방향으로 공중 회전(arc anim) → 반대면 착지 (texture flip).
##   - 3 states: 반뒤집 (flick 약함) / 한 바퀴 (적정 velocity) / 과회전 (flick 과다).
##   - variant: 해물파전 swipe-up / 콘도그 회전 / 갈비 좌우.
##
## SCORING 무변경 (§6.1): flip 성공도(공중 회전 수가 목표 1바퀴에 근접) → accuracy(cook factor)
## ∈ [0,1]. 기존 single-tap window 점수(100 center → 50 edge → 0 late)가 만들던 도메인과 동일한
## [0,100] score를 그대로 `module_completed(score)` 로 emit — runner contract / MODULE_TO_FACTOR
## ("flip"->cook) 동일.
extends "res://scripts/cooking_modules/base_module.gd"

const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")
const TouchGesture := preload("res://scripts/cooking_modules/touch_gesture.gd")

# flick 속도(px/sec) → 공중 회전 수 매핑. IDEAL_SPEED 부근이 깔끔한 1바퀴.
const SPEED_MIN: float = 1400.0          # 이하 = 반뒤집(flop).
const SPEED_IDEAL: float = 3200.0        # 적정 = 한 바퀴.
const SPEED_MAX: float = 5400.0          # 이상 = 과회전.

# 음식 hero 화면 위치.
const FOOD_CENTER := Vector2(540, 1040)

# variant → 목표 flick 방향(도, 0=오른쪽 90=아래 -90=위) + 허용 방향 오차(도).
#   pajeon : swipe-up (위로 뒤집기) → -90도.
#   corndog: 회전 flick (좌상향 대각) → -45도 (방향 관대).
#   galbi  : 좌우 flick → 수평(0 or 180) — 좌우 모두 허용.
const FLIP_VARIANTS := {
	"pajeon":  {"target_deg": -90.0, "tol_deg": 55.0, "label": "Flick up to flip", "axis": "vertical"},
	"corndog": {"target_deg": -45.0, "tol_deg": 80.0, "label": "Spin-flick the corn dog", "axis": "spin"},
	"galbi":   {"target_deg": 0.0,   "tol_deg": 50.0, "label": "Flick sideways to turn", "axis": "horizontal"},
	"default": {"target_deg": -90.0, "tol_deg": 60.0, "label": "Flick to flip", "axis": "vertical"},
}

var _variant: Dictionary = FLIP_VARIANTS["default"]
var _flipped: bool = false

# 시각 nodes.
var _cake_tex: TextureRect = null
var _cake_panel: Panel = null
var _cake: Control = null
var _gesture = null   # TouchGestureRecognizer (preloaded TouchGesture)
var _state_lbl: Label = null
var _face_up: bool = false               # 착지 후 뒤집힘 상태(texture flip).


func _module_start(params: Dictionary) -> void:
	_attach_cooking_bg(1050.0)
	# variant 결정.
	var v_id: String = String(params.get("variant", ""))
	if v_id == "" or not FLIP_VARIANTS.has(v_id):
		v_id = _infer_variant(String(params.get("food_id", "")))
	_variant = FLIP_VARIANTS[v_id]

	_build_header("Flip", "%s — give it a quick flick." % _variant["label"])

	var food_id: StringName = StringName(String(params.get("food_id", "")))
	_attach_dish_shadow(Vector2(540, 1280), 540.0)

	# 팬 LOCK art (panfry.png) — 음식 아래.
	var pan_path: String = ArtRegistry.TOOL_PANFRY
	if ArtRegistry.file_exists(pan_path):
		var pan_tex := TextureRect.new()
		pan_tex.texture = load(pan_path)
		pan_tex.position = Vector2(240, 880)
		pan_tex.size = Vector2(600, 400)
		pan_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pan_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pan_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(pan_tex)
	else:
		var pan := Panel.new()
		pan.position = Vector2(240, 900)
		pan.size = Vector2(600, 360)
		var psb := StyleBoxFlat.new()
		psb.bg_color = Color(0.20, 0.18, 0.19)
		psb.set_corner_radius_all(180)
		pan.add_theme_stylebox_override("panel", psb)
		pan.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(pan)

	# 음식 hero — 팬 위. flick으로 공중 회전.
	var food_img: String = ArtRegistry.food(food_id)
	if ArtRegistry.file_exists(food_img):
		_cake_tex = TextureRect.new()
		_cake_tex.texture = load(food_img)
		_cake_tex.position = Vector2(FOOD_CENTER.x - 210, FOOD_CENTER.y - 140)
		_cake_tex.size = Vector2(420, 280)
		_cake_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_cake_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_cake_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_cake_tex.pivot_offset = Vector2(210, 140)
		_cake_tex.modulate = Color(1.02, 1.0, 0.94, 1)
		add_child(_cake_tex)
		_cake = _cake_tex
	else:
		_cake_panel = Panel.new()
		_cake_panel.position = Vector2(FOOD_CENTER.x - 210, FOOD_CENTER.y - 120)
		_cake_panel.size = Vector2(420, 240)
		_cake_panel.pivot_offset = Vector2(210, 120)
		var csb := StyleBoxFlat.new()
		csb.bg_color = Color(0.86, 0.62, 0.30)
		csb.set_corner_radius_all(120)
		_cake_panel.add_theme_stylebox_override("panel", csb)
		_cake_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_cake_panel)
		_cake = _cake_panel

	_attach_steam(Vector2(540, 940), 2)

	_state_lbl = Label.new()
	_state_lbl.position = Vector2(0, 1520)
	_state_lbl.size = Vector2(1080, 70)
	_state_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_state_lbl.add_theme_font_size_override("font_size", 42)
	_state_lbl.add_theme_color_override("font_color", Color(0.45, 0.32, 0.18))
	_state_lbl.text = "Flick the food to flip it!"
	add_child(_state_lbl)

	# 입력 인식기 — flick (drag release의 velocity vector).
	_gesture = TouchGesture.new()
	_gesture.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_gesture)
	_gesture.drag_released.connect(_on_flick)


# 음식 → flip variant 추정 (명시 param 없을 때만). §5 variant 매핑.
func _infer_variant(food_id: String) -> String:
	match food_id:
		"t1_006":            # 해물파전 — swipe-up
			return "pajeon"
		"t1_007":            # 콘도그 — 회전 flick
			return "corndog"
		"t2_012":            # 갈비 — 좌우 flick
			return "galbi"
		_:
			return "default"


# --- gesture: flick (velocity vector) ---

func _on_flick(info: Dictionary) -> void:
	if _finished or _flipped:
		return
	# flick = 빠른 drag. avg_speed가 너무 작으면 flick 미성립 (살짝 nudge — retry 허용).
	var avg_speed: float = float(info.get("avg_speed", 0.0))
	var flick_dir: Vector2 = info.get("direction", Vector2.ZERO)
	if avg_speed < SPEED_MIN * 0.45:
		# 너무 약함 — flick 안 됨. 살짝 흔들리고 retry (점수 미반영).
		_nudge_food(flick_dir)
		if is_instance_valid(_state_lbl):
			_state_lbl.text = "Flick faster!"
		return
	_flipped = true
	# 공중 회전 수 = flick 속도 → spin turns. IDEAL_SPEED 부근 = ~1바퀴.
	var turns: float = _speed_to_turns(avg_speed)
	# 방향 정확도 — variant 목표 방향 대비 편차.
	var dir_ok: float = _direction_accuracy(info)
	var score: float = _compute_flip_score(turns, dir_ok)
	# 공중 arc anim (Tween): position arc + rotation(turns) + 착지 후 texture flip.
	_play_flip_arc(turns, flick_dir, score)
	var j := RhythmJudge.PERFECT if score >= 80.0 else (RhythmJudge.GOOD if score >= 40.0 else RhythmJudge.MISS)
	_safe_feedback(j, FOOD_CENTER)
	if is_instance_valid(_state_lbl):
		if score >= 80.0:
			_state_lbl.text = "Perfect one-turn flip!"
		elif turns < 0.65:
			_state_lbl.text = "Half-flip flop…"
		elif turns > 1.5:
			_state_lbl.text = "Over-spun!"
		else:
			_state_lbl.text = "Flipped"
	_finish(score)


## flick 속도(px/sec) → 공중 회전 수. SPEED_IDEAL = 1.0바퀴, 선형 보간.
func _speed_to_turns(speed: float) -> float:
	var s: float = clampf(speed, 0.0, SPEED_MAX * 1.4)
	if s <= SPEED_IDEAL:
		# SPEED_MIN(=0.5바퀴) ~ SPEED_IDEAL(=1.0바퀴).
		var t: float = clampf((s - SPEED_MIN) / maxf(SPEED_IDEAL - SPEED_MIN, 1.0), -0.5, 1.0)
		return clampf(0.5 + t * 0.5, 0.0, 1.0)
	else:
		# SPEED_IDEAL(=1.0) ~ SPEED_MAX(=~2.0바퀴 과회전).
		var t2: float = clampf((s - SPEED_IDEAL) / maxf(SPEED_MAX - SPEED_IDEAL, 1.0), 0.0, 1.4)
		return 1.0 + t2 * 1.0


## flick 방향이 variant 목표 방향에 얼마나 맞는지 [0,1].
func _direction_accuracy(info: Dictionary) -> float:
	var dir: Vector2 = info.get("direction", Vector2.ZERO)
	if dir.length() < 0.1:
		return 0.0
	var ang: float = rad_to_deg(dir.angle())   # -180..180, 0=오른쪽 -90=위
	var target: float = float(_variant["target_deg"])
	var tol: float = float(_variant["tol_deg"])
	# galbi 좌우 — 0도/180도 양쪽 다 허용 (axis horizontal).
	if String(_variant["axis"]) == "horizontal":
		var err_r: float = absf(_ang_diff(ang, 0.0))
		var err_l: float = absf(_ang_diff(ang, 180.0))
		var err_h: float = minf(err_r, err_l)
		return clampf(1.0 - err_h / maxf(tol, 1.0), 0.0, 1.0)
	# corndog spin — 방향 관대 (위쪽 반구 전반 허용).
	var err: float = absf(_ang_diff(ang, target))
	return clampf(1.0 - err / maxf(tol, 1.0), 0.0, 1.0)


func _ang_diff(a: float, b: float) -> float:
	return wrapf(a - b, -180.0, 180.0)


# --- scoring (§6.1) — flip 성공도 → [0,100] ---

## §6.1 — flip 품질 → [0,100]. 두 축:
##   (1) 공중 회전 수가 목표 1바퀴에 근접 (반뒤집/과회전 감점).
##   (2) flick 방향 정확도 (variant 목표 방향).
## 도메인은 기존 single-tap window(100 center / 0 late)와 동일 [0,100].
## 외부(smoke)에서 turns/dir_ok를 직접 주입해 호출 가능하도록 인자로 받음.
func _compute_flip_score(turns: float, dir_ok: float) -> float:
	# (1) 회전 정확도 — 1.0바퀴 중심, 멀어질수록 감소.
	var turn_err: float = absf(turns - 1.0)
	var turn_score: float
	if turn_err <= 0.18:
		turn_score = 100.0
	elif turn_err <= 0.5:
		turn_score = 60.0 + (0.5 - turn_err) / 0.32 * 40.0
	else:
		turn_score = maxf(0.0, 60.0 * (1.0 - (turn_err - 0.5) / 0.6))
	# (2) 방향 — 목표 방향 정확도.
	var dir_score: float = clampf(dir_ok, 0.0, 1.0) * 100.0
	# 가중 평균 (회전이 주, 방향이 보조).
	return clampf(turn_score * 0.65 + dir_score * 0.35, 0.0, 100.0)


# --- visual: 공중 arc + 회전 + 착지 texture flip ---

func _play_flip_arc(turns: float, dir: Vector2, _score: float) -> void:
	if not is_instance_valid(_cake):
		return
	var node: Control = _cake
	var start_pos: Vector2 = node.position
	# arc 높이 — flick 방향이 위일수록 높이 솟음.
	var up_bias: float = clampf(-dir.y, 0.0, 1.0)
	var peak_h: float = 180.0 + up_bias * 160.0 + turns * 40.0
	var lateral: float = dir.x * 80.0
	var peak_pos: Vector2 = start_pos + Vector2(lateral * 0.5, -peak_h)
	var land_pos: Vector2 = start_pos + Vector2(lateral, 0)
	# 회전 방향 — vertical/spin은 회전(rotation), horizontal은 flip_h 느낌(scale.x 반전).
	var spin_rad: float = turns * TAU
	if String(_variant["axis"]) == "horizontal":
		spin_rad *= 0.5   # 좌우는 절반 시각(수평 뒤집기 느낌)
	var tw := node.create_tween()
	tw.set_parallel(true)
	# 솟구침 → 정점 → 착지 (2단 position).
	var tw_up := tw.tween_property(node, "position", peak_pos, 0.22)
	tw_up.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(node, "rotation", node.rotation + spin_rad, 0.44)
	# 착지 (chain은 별도 tween).
	var tw2 := node.create_tween()
	tw2.tween_interval(0.22)
	tw2.tween_property(node, "position", land_pos, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# 착지 후 texture flip — 반대면 노출 (modulate 살짝 진한 갈색 = 구워진 뒷면).
	tw2.tween_callback(func():
		_face_up = not _face_up
		if is_instance_valid(node):
			if node is TextureRect:
				(node as TextureRect).flip_v = _face_up
			node.modulate = Color(0.82, 0.58, 0.32) if _face_up else Color(1.02, 1.0, 0.94)
	)
	# 착지 바운스.
	tw2.tween_property(node, "scale", Vector2(1.06, 0.94), 0.06)
	tw2.tween_property(node, "scale", Vector2(1.0, 1.0), 0.10)


# flick 너무 약할 때 살짝 흔들기 (retry 시각 피드백, 점수 무관).
func _nudge_food(dir: Vector2) -> void:
	if not is_instance_valid(_cake):
		return
	var node: Control = _cake
	var base: Vector2 = node.position
	var tw := node.create_tween()
	tw.tween_property(node, "position", base + dir * 12.0, 0.06)
	tw.tween_property(node, "position", base, 0.10)


func _now_ms() -> float:
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("now_ms"):
		return float(bc.now_ms())
	return float(Time.get_ticks_msec())
