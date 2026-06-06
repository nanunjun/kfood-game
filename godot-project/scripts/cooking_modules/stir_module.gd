## StirModule — ACTION-FIRST continuous circular swipe stirring (ADR-012).
##
## "I stirred the wok" — NOT "I tapped a beat". The player drags a finger in a CONTINUOUS
## circle over the wok/bowl; the recognizer feeds raw drag updates and we integrate the
## angular sweep around the stir center. Ingredients churn (rotate/orbit), the seasoning
## color spreads, and the surface gains sheen as the player keeps stirring.
##
## ADR-012 input redesign (2026-06-05): ActionPuck STIR rhythm-tap 폐기 → continuous circular
## swipe (각속도 적분).
##   - input: 손가락이 끊김 없이 원을 그림 → stir 중심 기준 누적 각도(라디안) 적분 = 회전 수.
##   - visual: 재료 sprite가 회전/궤도 churn + 양념색 spread + 윤기(sheen) 증가.
##   - 3 states: 안 섞임 (원 부족/느림) / 균일 (적정 회전 수 + 속도) / 뭉개짐 (너무 빠름·과다).
##   - variant: wok(빠른 작은 원 — 김치볶음밥) / bibim(느린 큰 원 — 비빔밥) / toss(좌우 swipe).
##
## SCORING 무변경 (§6.1): 회전 수 × 속도 일관성 → accuracy(cook factor) ∈ [0,1]. 기존 stir
## rhythm-tap 평균이 만들던 도메인과 동일한 [0,100] score를 그대로 `module_completed(score)`
## 로 emit — runner contract / MODULE_TO_FACTOR("stir"->cook) 동일.
extends "res://scripts/cooking_modules/base_module.gd"

const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")
const TouchGesture := preload("res://scripts/cooking_modules/touch_gesture.gd")

const TWO_PI: float = TAU

# 회전 목표(바퀴 수). 적정 stir = TARGET_TURNS 바퀴를 안정적 속도로.
const TARGET_TURNS_DEFAULT: float = 3.0

# stir 중심 (웍/그릇 중앙) — 화면 1080x1920 기준.
const STIR_CENTER := Vector2(540, 1000)

# variant → 목표 반경/각속도 band/원 모양 힌트.
#   wok   : 빠른 작은 원 (김치볶음밥) — 작은 반경, 빠른 각속도.
#   bibim : 느린 큰 원 (비빔밥) — 큰 반경, 느린 각속도.
#   toss  : 좌우 swipe (잡채 당면) — 원이 아닌 좌우 왕복도 회전으로 인정 (관대).
const STIR_VARIANTS := {
	"wok":   {"radius": 150.0, "rad_lo": 6.0,  "rad_hi": 16.0, "label": "Quick small circles", "shape": "circle"},
	"bibim": {"radius": 260.0, "rad_lo": 3.0,  "rad_hi": 9.0,  "label": "Slow big circles",    "shape": "circle"},
	"toss":  {"radius": 220.0, "rad_lo": 4.0,  "rad_hi": 13.0, "label": "Sweep side to side",  "shape": "sweep"},
	"default": {"radius": 200.0, "rad_lo": 4.0, "rad_hi": 13.0, "label": "Stir in circles",    "shape": "circle"},
}

var _variant: Dictionary = STIR_VARIANTS["default"]
var _target_turns: float = TARGET_TURNS_DEFAULT

# 누적 각도 적분 (rad). 부호 있는 누적 → 한 방향으로 꾸준히 돌수록 |total| 커짐.
var _accum_angle: float = 0.0
var _abs_turns: float = 0.0           # 누적 회전 수 (|accum_angle| / 2π)
var _prev_angle: float = 0.0
var _has_prev: bool = false
var _stirring: bool = false

# 각속도 샘플(rad/s) — 일관성 평가용.
var _ang_speed_samples: Array = []
var _last_sample_ms: float = 0.0
var _too_fast_frames: int = 0         # 과다(뭉개짐) risk 누적

# 시각 churn 상태.
var _ingredients: Array = []          # {node, base_offset, orbit_phase}
var _sheen: float = 0.0               # 윤기 [0,1]
var _spread: float = 0.0             # 양념색 spread [0,1]
var _food_hero: TextureRect = null
var _spoon: Node2D = null
var _gesture = null   # TouchGestureRecognizer (preloaded TouchGesture)
var _count_lbl: Label = null
var _season_col: Color = Color(0.86, 0.30, 0.20)


func _module_start(params: Dictionary) -> void:
	_attach_cooking_bg(1000.0)
	# variant 결정 (명시 param 우선).
	var v_id: String = String(params.get("variant", ""))
	if v_id == "" or not STIR_VARIANTS.has(v_id):
		v_id = _infer_variant(String(params.get("food_id", "")))
	_variant = STIR_VARIANTS[v_id]
	_target_turns = float(params.get("target_turns", TARGET_TURNS_DEFAULT))

	_build_header("Stir", "%s — keep the finger moving without lifting." % _variant["label"])

	var food_id: StringName = StringName(String(params.get("food_id", "")))
	_attach_dish_shadow(Vector2(540, 1060), 560.0)

	# 웍/팬 LOCK art (stirfry.png) — stir 중심 아래.
	var tool_path: String = ArtRegistry.TOOL_STIRFRY
	if ArtRegistry.file_exists(tool_path):
		var wok_tex := TextureRect.new()
		wok_tex.texture = load(tool_path)
		wok_tex.position = Vector2(140, 720)
		wok_tex.size = Vector2(800, 600)
		wok_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		wok_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		wok_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(wok_tex)
	else:
		var wok := Panel.new()
		wok.position = Vector2(240, 880)
		wok.size = Vector2(600, 360)
		var wsb := StyleBoxFlat.new()
		wsb.bg_color = Color(0.22, 0.20, 0.21)
		wsb.set_corner_radius_all(180)
		wok.add_theme_stylebox_override("panel", wsb)
		wok.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(wok)

	# 음식 완성 hero (food_img) — 웍 안 중앙. stir 진행에 따라 churn(회전)·sheen.
	var food_img: String = ArtRegistry.food(food_id)
	if ArtRegistry.file_exists(food_img):
		_food_hero = TextureRect.new()
		_food_hero.texture = load(food_img)
		_food_hero.position = Vector2(STIR_CENTER.x - 230, STIR_CENTER.y - 160)
		_food_hero.size = Vector2(460, 320)
		_food_hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_food_hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_food_hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_food_hero.pivot_offset = Vector2(230, 160)
		_food_hero.modulate = Color(0.96, 0.96, 0.96, 0.95)
		add_child(_food_hero)

	# churn 재료 토큰 (orbit하는 작은 ingredient cut sprites 또는 색 토큰).
	_build_ingredient_tokens(food_id)

	# 주걱/뒤집개 (procedural) — 손가락 따라 원을 그림.
	_spoon = _build_spoon()
	_spoon.position = STIR_CENTER + Vector2(0, -float(_variant["radius"]))
	_spoon.visible = false
	add_child(_spoon)

	# 진행 표시 (회전 수 + 상태).
	_count_lbl = Label.new()
	_count_lbl.position = Vector2(0, 1500)
	_count_lbl.size = Vector2(1080, 70)
	_count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_count_lbl.add_theme_font_size_override("font_size", 44)
	_count_lbl.add_theme_color_override("font_color", Color(0.45, 0.32, 0.18))
	add_child(_count_lbl)
	_update_count_lbl()

	_attach_steam(Vector2(540, 900), 3)

	# 입력 인식기 — 화면 전체 continuous drag.
	_gesture = TouchGesture.new()
	_gesture.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_gesture)
	_gesture.drag_started.connect(_on_drag_started)
	_gesture.drag_updated.connect(_on_drag_updated)
	_gesture.drag_released.connect(_on_drag_released)


# 음식 → stir variant 추정 (명시 param 없을 때만). §5 variant 매핑.
func _infer_variant(food_id: String) -> String:
	match food_id:
		"t1_005":            # 김치볶음밥 — 빠른 작은 원
			return "wok"
		"t2_008":            # 비빔밥 — 느린 큰 원
			return "bibim"
		"t2_010":            # 잡채 당면 — 좌우 toss
			return "toss"
		_:
			return "default"


# --- 재료 churn 토큰 ---

func _build_ingredient_tokens(food_id: StringName) -> void:
	# cut sprite 있으면 mini 복제, 없으면 색 토큰. orbit 반경 안에 흩뿌림.
	var cut_path: String = ArtRegistry.prep_cut(food_id)
	var has_cut: bool = ArtRegistry.file_exists(cut_path)
	var token_cols := [
		Color(0.92, 0.32, 0.22), Color(0.96, 0.84, 0.32), Color(0.46, 0.78, 0.34),
		Color(0.94, 0.92, 0.86), Color(0.36, 0.22, 0.16), Color(0.85, 0.40, 0.55),
	]
	var n: int = 7
	for i in range(n):
		var token: Control
		if has_cut:
			var t := TextureRect.new()
			t.texture = load(cut_path)
			t.size = Vector2(96, 96)
			t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			token = t
		else:
			var c := ColorRect.new()
			c.color = token_cols[i % token_cols.size()]
			c.size = Vector2(72, 72)
			token = c
		token.mouse_filter = Control.MOUSE_FILTER_IGNORE
		token.z_index = 6
		# orbit 초기 위치 — 중심 둘레 흩뿌림.
		var phase: float = float(i) / float(n) * TWO_PI
		var r: float = float(_variant["radius"]) * randf_range(0.35, 0.85)
		var off := Vector2(cos(phase), sin(phase)) * r
		token.position = STIR_CENTER + off - token.size * 0.5
		add_child(token)
		_ingredients.append({
			"node": token, "phase": phase, "radius": r, "size": token.size,
		})


func _build_spoon() -> Node2D:
	# 주걱 — 손잡이(갈색) + 둥근 머리(나무색). 손가락 위치로 따라옴.
	var spoon := Node2D.new()
	spoon.z_index = 50
	var handle := Polygon2D.new()
	handle.polygon = PackedVector2Array([
		Vector2(-12, -140), Vector2(12, -140), Vector2(14, 30), Vector2(-14, 30),
	])
	handle.color = Color(0.55, 0.36, 0.20)
	spoon.add_child(handle)
	var head := Polygon2D.new()
	head.polygon = PackedVector2Array([
		Vector2(-44, 20), Vector2(44, 20), Vector2(52, 70),
		Vector2(0, 110), Vector2(-52, 70),
	])
	head.color = Color(0.78, 0.58, 0.34)
	spoon.add_child(head)
	var head_hi := Polygon2D.new()
	head_hi.polygon = PackedVector2Array([
		Vector2(-30, 30), Vector2(30, 30), Vector2(24, 64), Vector2(-24, 64),
	])
	head_hi.color = Color(0.88, 0.70, 0.46)
	spoon.add_child(head_hi)
	return spoon


# --- gesture handlers: continuous circular swipe ---

func _on_drag_started(pos: Vector2) -> void:
	if _finished:
		return
	_stirring = true
	_prev_angle = (pos - STIR_CENTER).angle()
	_has_prev = (pos - STIR_CENTER).length() > 24.0
	_last_sample_ms = _now_ms()
	if is_instance_valid(_spoon):
		_spoon.visible = true
		_spoon.position = pos


func _on_drag_updated(pos: Vector2, _vel: Vector2) -> void:
	if _finished or not _stirring:
		return
	if is_instance_valid(_spoon):
		_spoon.position = pos
	var v: Vector2 = pos - STIR_CENTER
	if v.length() < 24.0:
		# 중심 너무 가까움 — 각도 불안정. 적분 skip (회전으로 안 침).
		return
	var ang: float = v.angle()
	if not _has_prev:
		_prev_angle = ang
		_has_prev = true
		return
	# 두 각도 사이 최소 부호 차이 (-π..π) — 한 방향 누적.
	var d_ang: float = wrapf(ang - _prev_angle, -PI, PI)
	_prev_angle = ang
	_accum_angle += d_ang
	_abs_turns = absf(_accum_angle) / TWO_PI
	# 각속도 샘플 (rad/s).
	var now := _now_ms()
	var dt_s: float = maxf((now - _last_sample_ms) / 1000.0, 0.001)
	_last_sample_ms = now
	var ang_speed: float = absf(d_ang) / dt_s
	if ang_speed > 0.01:
		_ang_speed_samples.append(ang_speed)
		# 과다(뭉개짐) — 목표 상한을 크게 초과한 각속도 누적.
		if ang_speed > float(_variant["rad_hi"]) * 1.6:
			_too_fast_frames += 1
	# 시각 churn 진행 — 회전 비율만큼 churn 강화.
	_apply_churn(ang_speed)
	_update_count_lbl()
	# 충분히 저었으면 완료.
	if _abs_turns >= _target_turns:
		_finalize_stir()


func _on_drag_released(_info: Dictionary) -> void:
	if _finished:
		return
	_stirring = false
	_has_prev = false
	if is_instance_valid(_spoon):
		# 주걱 중앙 위로 복귀.
		var tw := _spoon.create_tween()
		tw.tween_property(_spoon, "position", STIR_CENTER + Vector2(0, -float(_variant["radius"])), 0.2)
	# release 시점에 목표 도달했으면 finalize (continuous 적분이 못 따라잡은 경우 대비).
	if _abs_turns >= _target_turns:
		_finalize_stir()


# --- churn visual: 재료가 회전 따라 orbit + sheen + 양념 spread ---

func _apply_churn(ang_speed: float) -> void:
	# 회전량에 비례해 churn 진행도(0~1).
	var prog: float = clampf(_abs_turns / maxf(_target_turns, 0.5), 0.0, 1.0)
	_sheen = clampf(prog, 0.0, 1.0)
	_spread = clampf(prog, 0.0, 1.0)
	# 재료 토큰 orbit — 누적 각도에 비례해 중심 둘레를 돈다.
	var spin: float = _accum_angle * 0.6
	for ing in _ingredients:
		var node: Control = ing["node"]
		if not is_instance_valid(node):
			continue
		var ph: float = float(ing["phase"]) + spin
		var r: float = float(ing["radius"]) * (1.0 - prog * 0.18)   # 점점 가운데로 모임(섞임)
		var off := Vector2(cos(ph), sin(ph)) * r
		var sz: Vector2 = ing["size"]
		node.position = STIR_CENTER + off - sz * 0.5
	# 음식 hero 살짝 회전 + 양념색 spread + 윤기.
	if is_instance_valid(_food_hero):
		_food_hero.rotation = _accum_angle * 0.12
		var tint: Color = Color(1, 1, 1).lerp(_season_col.lightened(0.4), _spread * 0.45)
		var sheen_boost: float = 1.0 + _sheen * 0.12
		_food_hero.modulate = Color(tint.r * sheen_boost, tint.g * sheen_boost, tint.b * sheen_boost, 0.97)


func _update_count_lbl() -> void:
	if not is_instance_valid(_count_lbl):
		return
	var turns_done: float = _abs_turns
	var state: String = _state_label()
	_count_lbl.text = "%.1f / %.0f turns  ·  %s" % [turns_done, _target_turns, state]


# 현재 stir 상태 라벨 (3 states 시각 피드백).
func _state_label() -> String:
	if _abs_turns < _target_turns * 0.4:
		return "not mixed yet"
	if _too_fast_frames > _ang_speed_samples.size() * 0.5 and _ang_speed_samples.size() > 4:
		return "too fast — mushy!"
	return "mixing nicely"


# --- scoring (§6.1) — 회전 수 × 속도 일관성 → [0,100] ---

func _finalize_stir() -> void:
	var score: float = _compute_stir_score()
	var j := RhythmJudge.PERFECT if score >= 80.0 else (RhythmJudge.GOOD if score >= 40.0 else RhythmJudge.MISS)
	_safe_feedback(j, STIR_CENTER)
	if is_instance_valid(_count_lbl):
		if score >= 80.0:
			_count_lbl.text = "Evenly stirred!"
		elif _too_fast_frames > _ang_speed_samples.size() * 0.5:
			_count_lbl.text = "Stirred too hard — mushy"
		else:
			_count_lbl.text = "Done"
	_finish(score)


## §6.1 — stir 품질 → [0,100]. 두 축:
##   (1) 회전 수 완성도 — 목표 turns 도달 비율 (덜 저으면 under-mixed).
##   (2) 각속도 일관성 — 목표 band 안 비율 + 분산 (들쭉날쭉/과다 = 뭉개짐 감점).
## 두 축 가중 평균. 도메인은 기존 stir rhythm 평균과 동일 [0,100].
## 외부(smoke)에서 raw 상태를 주입해 호출 가능하도록 public 인자 없이 멤버 사용.
func _compute_stir_score() -> float:
	# (1) 회전 완성도.
	var turn_ratio: float = clampf(_abs_turns / maxf(_target_turns, 0.5), 0.0, 1.0)
	var turn_score: float = turn_ratio * 100.0
	# (2) 속도 일관성 — band 안 비율.
	var lo: float = float(_variant["rad_lo"])
	var hi: float = float(_variant["rad_hi"])
	var in_band: int = 0
	var mean: float = 0.0
	for s in _ang_speed_samples:
		var sp: float = float(s)
		mean += sp
		if sp >= lo and sp <= hi:
			in_band += 1
	var n: int = _ang_speed_samples.size()
	var band_score: float
	if n == 0:
		band_score = 0.0
	else:
		mean /= float(n)
		var band_ratio: float = float(in_band) / float(n)
		# 분산(일관성) — 평균 대비 표준편차가 작을수록 일관.
		var var_sum: float = 0.0
		for s in _ang_speed_samples:
			var_sum += pow(float(s) - mean, 2.0)
		var std: float = sqrt(var_sum / float(n))
		var consistency: float = clampf(1.0 - std / maxf(mean, 0.5), 0.0, 1.0)
		band_score = (band_ratio * 0.6 + consistency * 0.4) * 100.0
	# 과다(뭉개짐) 페널티 — 너무 빠른 frame이 많으면 감점.
	var over_pen: float = clampf(float(_too_fast_frames) / float(maxi(n, 1)), 0.0, 0.5)
	var raw: float = turn_score * 0.5 + band_score * 0.5
	return clampf(raw * (1.0 - over_pen * 0.5), 0.0, 100.0)


func _now_ms() -> float:
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("now_ms"):
		return float(bc.now_ms())
	return float(Time.get_ticks_msec())
