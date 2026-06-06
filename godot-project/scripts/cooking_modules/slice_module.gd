## SliceModule — ACTION-FIRST drag-knife chopping (ADR-012).
##
## "I cut carrots" — NOT "I tapped a beat". The player drags a finger down across the
## ingredient; a knife follows the finger and the ingredient physically splits into pieces
## that accumulate on the board. N cuts (level config) complete the step.
##
## ADR-012 input redesign (2026-06-05): ActionPuck TAP rhythm 폐기 → vertical drag knife.
##   - input: vertical drag crossing the ingredient hitbox = 1 cut.
##   - visual: 칼이 손가락 따라 내려옴 → 재료가 whole→cut sprite로 갈라짐 + 조각 누적.
##   - 3 states: under-cut (덜 썰림) / perfect (균일) / over-minced (너무 잘게).
##   - cut style (다지기/채썰기/어슷썰기): 음식별 cut_style param → 목표 drag 방향·속도.
##
## SCORING 무변경 (§6.1): cut 위치 정확도 + drag 속도 band 일관성을 종합한 cut 평균이
## accuracy_prep ∈ [0,1]. 기존 perfect/good/miss 구간(100/60/0)과 1:1 매핑. 0~100 score를
## 그대로 `module_completed(score)` 로 emit — runner contract / 도메인 동일.
##
## params (runner 무변경): tap_count = 목표 cut 수, bpm = drag 속도 band 목표값(자동 칼
## BPM → 손가락 drag 목표 속도로 재해석, §6.3), cut_style(optional) = 한식 cut 어휘.
extends "res://scripts/cooking_modules/base_module.gd"

const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")
const TouchGesture := preload("res://scripts/cooking_modules/touch_gesture.gd")

const CUT_COUNT_DEFAULT: int = 4
const BPM_DEFAULT: float = 110.0

# 재료 hitbox (board container 내 local 좌표는 화면 좌표로 환산해 사용).
# 화면(1080x1920) 기준 재료가 놓인 영역.
const INGREDIENT_RECT := Rect2(330, 820, 420, 380)   # x,y,w,h (썰 영역)
const CROSS_MARGIN: float = 40.0                     # 위/아래 통과 판정 여유

# cut style → 목표 drag 방향(도, 0=오른쪽 90=아래) + 목표 speed(px/sec) band.
# ADR-012 §5.1 — BPM(자동 칼)을 손가락 drag 목표 속도로 재해석.
const CUT_STYLES := {
	"mince":     {"angle": 90.0, "speed_lo": 1600.0, "speed_hi": 3200.0, "label": "다지기"},
	"julienne":  {"angle": 90.0, "speed_lo": 900.0,  "speed_hi": 1800.0, "label": "채썰기"},
	"diagonal":  {"angle": 60.0, "speed_lo": 900.0,  "speed_hi": 1800.0, "label": "어슷썰기"},
	"round":     {"angle": 90.0, "speed_lo": 500.0,  "speed_hi": 1100.0, "label": "통썰기"},
	"fine":      {"angle": 90.0, "speed_lo": 1200.0, "speed_hi": 2400.0, "label": "송송썰기"},
	"default":   {"angle": 90.0, "speed_lo": 800.0,  "speed_hi": 2000.0, "label": "썰기"},
}

var _cut_target: int = CUT_COUNT_DEFAULT
var _cuts_done: int = 0
var _cut_scores: Array = []          # per-cut [0..100]
var _style: Dictionary = CUT_STYLES["default"]

var _board: Control = null           # gif stager hooks this name
var _whole_tex: TextureRect = null
var _cut_tex: TextureRect = null
var _knife: Node2D = null
var _indicator: Label = null         # gif stager hooks this name
var _gesture = null   # TouchGestureRecognizer (preloaded TouchGesture)
var _pieces_holder: Control = null
var _cut_path: String = ""


func _module_start(params: Dictionary) -> void:
	_attach_cooking_bg(1000.0)
	# cut style 결정 — 명시 param 우선, 없으면 BPM으로 추정 fallback.
	var style_id: String = String(params.get("cut_style", ""))
	if style_id == "" or not CUT_STYLES.has(style_id):
		style_id = _infer_style(float(params.get("bpm", BPM_DEFAULT)))
	_style = CUT_STYLES[style_id]

	_build_header("Slice", "Drag the knife down through the %s." % _style["label"])
	_cut_target = int(params.get("tap_count", CUT_COUNT_DEFAULT))
	_cuts_done = 0
	_cut_scores.clear()

	var food_id: StringName = StringName(String(params.get("food_id", "")))
	_cut_path = ArtRegistry.prep_cut(food_id)

	# D3: soft dish shadow under the board hero area.
	_attach_dish_shadow(Vector2(540, 1240), 460.0)
	_board = _build_board_with_art(food_id)
	add_child(_board)

	# 누적된 조각이 쌓일 holder (cut sprite 작은 복제본).
	_pieces_holder = Control.new()
	_pieces_holder.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pieces_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_pieces_holder)

	# 칼 (procedural — knife.png LOCK 미발급, §11-2 fallback). 손가락 따라 이동.
	_knife = _build_knife()
	add_child(_knife)
	_knife.position = Vector2(540, 760)
	_knife.visible = false

	# 진행 표시 (몇 번 썰었는지 + how-to).
	_indicator = Label.new()
	_indicator.position = Vector2(40, 1320)
	_indicator.size = Vector2(1000, 80)
	_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_indicator.add_theme_font_size_override("font_size", 48)
	_indicator.add_theme_color_override("font_color", Color(0.85, 0.55, 0.15))
	add_child(_indicator)
	_update_indicator()

	# 입력 인식기 — 화면 전체 drag 추적.
	_gesture = TouchGesture.new()
	_gesture.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_gesture)
	_gesture.drag_started.connect(_on_drag_started)
	_gesture.drag_updated.connect(_on_drag_updated)
	_gesture.drag_released.connect(_on_drag_released)


# 자동 칼 BPM → cut style 추정 (명시 param 없을 때만). §6.3 수치 보존용.
func _infer_style(bpm: float) -> String:
	if bpm >= 130.0:
		return "mince"
	elif bpm >= 108.0:
		return "fine"
	elif bpm >= 95.0:
		return "diagonal"
	elif bpm >= 85.0:
		return "julienne"
	return "round"


# --- art / visual build ---

## 재료 whole sprite (위에 cut overlay 숨김) — drag로 갈라질 대상.
func _build_board_with_art(food_id: StringName) -> Control:
	var container := Control.new()
	container.position = Vector2(0, 0)
	container.size = Vector2(1080, 1920)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 도마 (LOCK art if available).
	if ArtRegistry.file_exists(ArtRegistry.slice_board()):
		var board_tex := TextureRect.new()
		board_tex.texture = load(ArtRegistry.slice_board())
		board_tex.position = Vector2(240, 820)
		board_tex.size = Vector2(600, 420)
		board_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		board_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		board_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		container.add_child(board_tex)
	else:
		var board_fb := Panel.new()
		board_fb.position = Vector2(280, 900)
		board_fb.size = Vector2(520, 260)
		var fbsb := StyleBoxFlat.new()
		fbsb.bg_color = Color(0.792, 0.612, 0.392)
		fbsb.set_corner_radius_all(36)
		fbsb.set_border_width_all(6)
		fbsb.border_color = Color(0.40, 0.27, 0.16)
		board_fb.add_theme_stylebox_override("panel", fbsb)
		board_fb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		container.add_child(board_fb)

	# whole ingredient (썰리기 전) — drag로 split될 hero.
	var whole_path: String = ArtRegistry.prep_whole(food_id)
	if ArtRegistry.file_exists(whole_path):
		_whole_tex = TextureRect.new()
		_whole_tex.texture = load(whole_path)
		_whole_tex.position = INGREDIENT_RECT.position
		_whole_tex.size = INGREDIENT_RECT.size
		_whole_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_whole_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_whole_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_whole_tex.pivot_offset = INGREDIENT_RECT.size * 0.5
		container.add_child(_whole_tex)
	else:
		# 폴백: 색 블록 (재료 art 미존재 음식).
		var fb := ColorRect.new()
		fb.color = Color(0.92, 0.62, 0.30)
		fb.position = INGREDIENT_RECT.position
		fb.size = INGREDIENT_RECT.size
		fb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		container.add_child(fb)
		_whole_tex = null

	# cut overlay (완전히 썰린 결과) — 마지막에 fade-in.
	if ArtRegistry.file_exists(_cut_path):
		_cut_tex = TextureRect.new()
		_cut_tex.texture = load(_cut_path)
		_cut_tex.position = INGREDIENT_RECT.position
		_cut_tex.size = INGREDIENT_RECT.size
		_cut_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_cut_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_cut_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_cut_tex.modulate = Color(1, 1, 1, 0.0)
		container.add_child(_cut_tex)

	return container


## 절차적 칼 — 날(은색 삼각) + 손잡이(갈색). 손가락 위치로 따라옴.
func _build_knife() -> Node2D:
	var knife := Node2D.new()
	knife.z_index = 50
	# blade (Polygon2D, 칼끝이 아래를 향함)
	var blade := Polygon2D.new()
	blade.polygon = PackedVector2Array([
		Vector2(-14, -120), Vector2(14, -120), Vector2(14, 40),
		Vector2(-2, 96), Vector2(-14, 40),
	])
	blade.color = Color(0.82, 0.84, 0.88)
	knife.add_child(blade)
	# blade edge highlight
	var edge := Polygon2D.new()
	edge.polygon = PackedVector2Array([
		Vector2(8, -120), Vector2(14, -120), Vector2(14, 40), Vector2(-2, 96),
	])
	edge.color = Color(0.95, 0.96, 0.98)
	knife.add_child(edge)
	# handle
	var handle := Polygon2D.new()
	handle.polygon = PackedVector2Array([
		Vector2(-18, -188), Vector2(18, -188), Vector2(16, -122), Vector2(-16, -122),
	])
	handle.color = Color(0.36, 0.22, 0.14)
	knife.add_child(handle)
	return knife


# --- gesture handlers ---

func _on_drag_started(pos: Vector2) -> void:
	if _finished:
		return
	if is_instance_valid(_knife):
		_knife.visible = true
		_knife.position = Vector2(pos.x, pos.y - 60.0)


func _on_drag_updated(pos: Vector2, _vel: Vector2) -> void:
	if _finished:
		return
	# 칼이 손가락을 따라옴 (칼끝이 손가락 살짝 아래).
	if is_instance_valid(_knife):
		_knife.position = Vector2(pos.x, pos.y - 60.0)


func _on_drag_released(info: Dictionary) -> void:
	if _finished:
		return
	if is_instance_valid(_knife):
		_knife.visible = false
	# 재료를 가로질러 통과했는가? — drag가 재료 hitbox의 위→아래(또는 cut 방향)를 지났는지.
	if not _crossed_ingredient(info):
		# 빗나간 drag = cut 미성립 (점수 미반영, retry 가능 — FTUE 학습).
		_indicator.text = "Drag through the ingredient ↓"
		return
	var score: float = _score_cut(info)
	_cut_scores.append(score)
	_cuts_done += 1
	_apply_cut_visual(score)
	_update_indicator()
	# juice
	var j := RhythmJudge.PERFECT if score >= 80.0 else (RhythmJudge.GOOD if score >= 40.0 else RhythmJudge.MISS)
	_safe_feedback(j, Vector2(info["end"].x, info["end"].y))
	if _cuts_done >= _cut_target:
		_finalize()


## drag가 재료를 실제로 가로질렀는지 — start와 end의 Y가 재료 띠를 위→아래로 통과.
func _crossed_ingredient(info: Dictionary) -> bool:
	var start: Vector2 = info["start"]
	var end: Vector2 = info["end"]
	var rx0: float = INGREDIENT_RECT.position.x - CROSS_MARGIN
	var rx1: float = INGREDIENT_RECT.position.x + INGREDIENT_RECT.size.x + CROSS_MARGIN
	var ry0: float = INGREDIENT_RECT.position.y - CROSS_MARGIN
	var ry1: float = INGREDIENT_RECT.position.y + INGREDIENT_RECT.size.y + CROSS_MARGIN
	# 위에서 시작해 아래로 끝나며(또는 그 반대), 수평 위치가 재료 폭 안.
	var mid_x: float = (start.x + end.x) * 0.5
	if mid_x < rx0 or mid_x > rx1:
		return false
	var vert_span: float = absf(end.y - start.y)
	if vert_span < INGREDIENT_RECT.size.y * 0.4:
		return false
	# 한쪽 끝이 재료 위, 다른쪽이 아래여야 통과 성립.
	var top_y: float = minf(start.y, end.y)
	var bot_y: float = maxf(start.y, end.y)
	return top_y <= ry0 + INGREDIENT_RECT.size.y * 0.6 and bot_y >= ry1 - INGREDIENT_RECT.size.y * 0.6


## §6.1 — cut 품질 → [0,100]. 두 축: (1) drag 방향 정확도(cut style 목표 각),
## (2) drag 속도 band 일관성. 두 축 평균. 도메인은 기존 100/60/0과 동일 구간.
func _score_cut(info: Dictionary) -> float:
	# (1) 방향 정확도 — cut style 목표 각 대비 편차. (각은 절대값 비교 — 위/아래 무관)
	var ang: float = absf(float(info["angle_deg"]))
	if ang > 90.0:
		ang = 180.0 - ang   # 아래 방향(90~270)을 0~90으로 접기
	var target_ang: float = float(_style["angle"])
	var ang_err: float = absf(ang - target_ang)
	# ≤12° = perfect, ≤30° = good, 그 이상 비례 감소.
	var dir_score: float
	if ang_err <= 12.0:
		dir_score = 100.0
	elif ang_err <= 30.0:
		dir_score = 60.0 + (30.0 - ang_err) / 18.0 * 40.0
	else:
		dir_score = maxf(0.0, 60.0 * (1.0 - (ang_err - 30.0) / 45.0))
	# (2) 속도 band 일관성 — cut style 목표 속도 band 안이면 만점.
	var spd: float = float(info["avg_speed"])
	var lo: float = float(_style["speed_lo"])
	var hi: float = float(_style["speed_hi"])
	var spd_score: float
	if spd >= lo and spd <= hi:
		spd_score = 100.0
	elif spd < lo:
		spd_score = maxf(0.0, 100.0 * (spd / maxf(lo, 1.0)))           # 너무 느림 (under-cut)
	else:
		var over: float = (spd - hi) / maxf(hi, 1.0)
		spd_score = maxf(0.0, 100.0 - over * 60.0)                     # 너무 빠름 (over-minced)
	# straightness 작은 가산(들쭉날쭉 cut 감점).
	var straight: float = float(info.get("straightness", 1.0))
	var stable: float = clampf(straight, 0.6, 1.0)
	return clampf((dir_score * 0.5 + spd_score * 0.5) * stable, 0.0, 100.0)


## 누적 cut 진행 시각 — whole이 점점 사라지고 cut overlay가 드러나며 조각이 쌓임.
func _apply_cut_visual(score: float) -> void:
	var prog: float = float(_cuts_done) / float(maxi(1, _cut_target))
	# whole sprite 점점 fade (썰릴수록 원형 사라짐).
	if is_instance_valid(_whole_tex):
		var tw := _whole_tex.create_tween()
		tw.tween_property(_whole_tex, "modulate:a", maxf(1.0 - prog, 0.0), 0.18)
	# cut overlay 점점 드러남.
	if is_instance_valid(_cut_tex):
		var tw2 := _cut_tex.create_tween()
		tw2.tween_property(_cut_tex, "modulate:a", clampf(prog + 0.15, 0.0, 1.0), 0.22)
	# 떨어져 나간 조각 1개 spawn (cut sprite mini 복제 또는 색 블록).
	_spawn_piece(score)


func _spawn_piece(score: float) -> void:
	if not is_instance_valid(_pieces_holder):
		return
	var piece: Control
	if ArtRegistry.file_exists(_cut_path):
		var t := TextureRect.new()
		t.texture = load(_cut_path)
		t.size = Vector2(96, 96)
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		piece = t
	else:
		var c := ColorRect.new()
		c.color = Color(0.95, 0.66, 0.34)
		c.size = Vector2(72, 36)
		piece = c
	piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# 도마 아래쪽 더미 영역에 흩뿌리며 누적.
	var idx: int = _cuts_done - 1
	var px: float = 330.0 + float(idx % 4) * 110.0 + randf_range(-12.0, 12.0)
	var py: float = 1240.0 + float(idx / 4) * 60.0 + randf_range(-8.0, 8.0)
	piece.position = Vector2(px, py - 40.0)
	piece.modulate = Color(1, 1, 1, 0.0)
	_pieces_holder.add_child(piece)
	var tw := piece.create_tween()
	tw.parallel().tween_property(piece, "position:y", py, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(piece, "modulate:a", 1.0, 0.18)


func _update_indicator() -> void:
	if not is_instance_valid(_indicator):
		return
	if _cuts_done >= _cut_target:
		_indicator.text = "Sliced!"
	else:
		_indicator.text = "%s  %d / %d" % [_style["label"], _cuts_done, _cut_target]


func _finalize() -> void:
	# cut overlay 완전 노출 + whole 제거.
	if is_instance_valid(_cut_tex):
		var tw := _cut_tex.create_tween()
		tw.tween_property(_cut_tex, "modulate:a", 1.0, 0.2)
	if is_instance_valid(_whole_tex):
		var tw2 := _whole_tex.create_tween()
		tw2.tween_property(_whole_tex, "modulate:a", 0.0, 0.2)
	# §6.1 — cut 평균 = accuracy_prep × 100. 도메인/contract 무변경.
	var total: float = 0.0
	for s in _cut_scores:
		total += float(s)
	var avg: float = total / float(maxi(1, _cut_scores.size()))
	_finish(avg)
