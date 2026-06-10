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
## 5-Layer Composition (2026-06-06): cutting_board(L2) + raw ingredient(L3) + chef_knife(L4).
## 성공 시 ingredient를 prepared standalone sprite(L3 swap)로 교체 + slice_vfx(L5). baked
## 도마+칼+재료 PNG는 절대 사용하지 않는다 — 각 layer를 Godot가 runtime 합성.
extends "res://scripts/cooking_modules/base_module.gd"

const TouchGesture := preload("res://scripts/cooking_modules/touch_gesture.gd")
# ArtRegistry / CookingFX 는 base_module(CookingModule)에서 상속.

# 5-Layer 배치 — composition zone 기반 (화면 1080x1920, ACTION zone Y 288~1440, 60%).
# P1 Cooking Rebuild: 도마/재료/칼을 action zone(288~1440) 중앙에 맞춰 큰 빈 공간 제거.
# cutting_board = action zone 중심(864) 부근 안정 배치 (≤65% W / 42% H clamp).
const BOARD_RECT := Rect2(180, 800, 720, 480)        # L2 cutting_board (vessel clamp, zone 중앙)
# chef_knife scale fix (2026-06-08, 보존): board(720w) 대비 knife 폭이 50-65% (primary action tool).
# 이전 200px = 28% board → toy-sized. 신규 420px = 58% board width (Slice 비례 룰 준수).
# 높이 = aspect 보존(원본 200x360 비율 0.556) → 420 / 0.556 ≈ 756. blade가 재료(480w)를
# 명확히 가로지르되 도마(720w) 안에 들어가 off-screen crop 없음.
const KNIFE_RECT := Rect2(0, 0, 420, 756)            # L4 chef_knife (손가락 추적)

const CUT_COUNT_DEFAULT: int = 4
const BPM_DEFAULT: float = 110.0

# 재료(썰 영역) = board 위쪽 안, ingredient clamp(≤45% W / 35% H). 도마 안에 안정 배치.
const INGREDIENT_RECT := Rect2(300, 850, 480, 360)   # x,y,w,h (≤45%W=486 / 35%H=672)
# prepared pile = board 오른쪽 neat pile (raw보다 크지 않게).
const PILE_RECT := Rect2(660, 1240, 340, 200)
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

# === Gimbap Vertical Slice — consequence hook (design §8.4: roll→slice) ===
# Pass B: roll_quality(말기 품질) → slice cut 판정 window 폭 보정. loose/burst/crooked roll →
#   window 좁아짐(rhythm window 빡빡 + 조각 wobble). tight roll → 넉넉(clean 8조각). 입력·기본
#   scoring 무변경 — 기본값 1.0(window_scale)이면 일반 dish slice는 기존 난이도를 100% 보존한다.
var _vs_window_scale: float = 1.0    # 1.0 = 기존 angle/speed tolerance. <1.0 = 좁아짐(roll 나쁨).
var _vs_active: bool = false         # vertical slice consequence on/off (wobble visual 분기).

var _board: Control = null           # gif stager hooks this name
var _whole_tex: TextureRect = null
var _cut_tex: TextureRect = null
var _knife = null                    # L4 chef_knife (TextureRect) 또는 procedural Node2D
var _knife_is_sprite: bool = false
var _indicator: Label = null         # gif stager hooks this name
var _gesture = null   # TouchGestureRecognizer (preloaded TouchGesture)
var _pieces_holder: Control = null
var _cut_path: String = ""           # prepared(L3 swap) sprite 경로


func _module_start(params: Dictionary) -> void:
	_attach_cooking_bg(1000.0)
	# cut style 결정 — 명시 param 우선, 없으면 BPM으로 추정 fallback.
	var style_id: String = String(params.get("cut_style", ""))
	if style_id == "" or not CUT_STYLES.has(style_id):
		style_id = _infer_style(float(params.get("bpm", BPM_DEFAULT)))
	_style = CUT_STYLES[style_id]

	_build_header("Slice", "Chop the ingredient on the board")
	# 자세한 gesture instruction = bottom 25% band (전 module 일관 위치).
	_build_instruction_band("Drag the knife down through the %s" % _style["label"], "↓")
	_cut_target = int(params.get("tap_count", CUT_COUNT_DEFAULT))
	_cuts_done = 0
	_cut_scores.clear()
	_consume_vs_consequence(params)

	var food_id: StringName = StringName(String(params.get("food_id", "")))
	# 5-layer: 음식별 semantic ingredient — whole(L3) → prepared(L3 swap).
	# 예: green_onion whole→chopped / carrot whole→julienne / kimchi whole→chopped.
	var sem: Array = ArtRegistry.slice_ingredient_for(food_id)   # [name, prepared_state]
	var ing_name: String = String(sem[0])
	var prep_state: String = String(sem[1])
	_cut_path = ArtRegistry.get_ingredient(ing_name, prep_state)

	# D3: soft dish shadow under the cutting board (action zone center).
	_attach_dish_shadow(Vector2(540, BOARD_RECT.position.y + BOARD_RECT.size.y * 0.6), 520.0)
	# L2 cutting_board + L3 raw ingredient.
	_board = _build_board_with_art(ing_name)
	add_child(_board)

	# 누적된 조각이 쌓일 holder (prepared sprite 작은 복제본 — board 오른쪽 neat pile).
	_pieces_holder = Control.new()
	_pieces_holder.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pieces_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_pieces_holder)

	# L4 chef_knife (standalone sprite, 미존재 시 procedural). 손가락 따라 이동.
	# 시작부터 visible — 재료 위 대각선에 대기(무엇으로 무슨 action인지 즉시 인지).
	_knife = _build_knife()
	add_child(_knife)
	_knife.position = Vector2(INGREDIENT_RECT.position.x + INGREDIENT_RECT.size.x * 0.5,
		INGREDIENT_RECT.position.y - 40.0)
	_knife.rotation = deg_to_rad(20.0)   # 대각선 대기 (썰기 hint).
	_knife.visible = true

	# 진행 표시 (몇 번 썰었는지) — CONTROL band (action zone 하단, instruction band 위).
	_indicator = Label.new()
	_indicator.position = Vector2(40, 1376)
	_indicator.size = Vector2(1000, 70)
	_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_indicator.add_theme_font_size_override("font_size", 46)
	_indicator.add_theme_color_override("font_color", Color(0.92, 0.62, 0.20))
	_indicator.add_theme_color_override("font_outline_color", Color(0.25, 0.14, 0.05))
	_indicator.add_theme_constant_override("outline_size", 6)
	_indicator.z_index = L5_VFX
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


## §8.4 roll→slice — runner가 넘긴 vs_quality_state.roll_quality를 읽어 cut window 폭을 보정한다.
## 일반 dish slice(params에 vs_quality_state 없음)는 _vs_window_scale=1.0 유지 → 기존 난이도 보존.
##   loose/burst/crooked roll(roll_quality 낮음) → window 좁아짐(0.6배): 같은 cut 입력이라도
##     판정이 빡빡해져 점수 ↓ + wobble 조각 visual. tight roll → 1.0배(clean).
func _consume_vs_consequence(params: Dictionary) -> void:
	if not params.has("vs_quality_state"):
		return
	var qs: Dictionary = params.get("vs_quality_state", {})
	if qs.is_empty():
		return
	# vertical slice의 통썰기(Stage 4)에서만 roll_quality consequence를 적용. prep julienne은
	# JulienneModule(별도)이라 이 경로를 안 탄다 → roll_quality는 통썰기 cut window에만 영향.
	var roll_q: float = clampf(float(qs.get("roll_quality", 1.0)), 0.0, 1.0)
	_vs_window_scale = lerpf(0.6, 1.0, roll_q)
	_vs_active = true
	print("[slice-vs] roll_q=%.2f window_scale=%.2f" % [roll_q, _vs_window_scale])


# --- art / visual build ---

## L2 cutting_board(standalone) + L3 raw ingredient(standalone). drag로 갈라질 대상.
func _build_board_with_art(ing_name: String) -> Control:
	var container := Control.new()
	container.position = Vector2(0, 0)
	container.size = Vector2(1080, 1920)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# L2 — cutting_board standalone (vessel/tool base, aspect-fit, ≤65%W/42%H). fallback 나무판.
	var board_path: String = ArtRegistry.get_vessel("cutting_board")
	if board_path != "":
		var board_tex := TextureRect.new()
		board_tex.texture = load(board_path)
		Composition.fit_texture_rect(board_tex, BOARD_RECT)
		board_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		board_tex.z_index = L2_BASE
		container.add_child(board_tex)
	else:
		var board_fb := Panel.new()
		board_fb.position = BOARD_RECT.position
		board_fb.size = BOARD_RECT.size
		var fbsb := StyleBoxFlat.new()
		fbsb.bg_color = Color(0.792, 0.612, 0.392)
		fbsb.set_corner_radius_all(36)
		fbsb.set_border_width_all(6)
		fbsb.border_color = Color(0.40, 0.27, 0.16)
		board_fb.add_theme_stylebox_override("panel", fbsb)
		board_fb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		board_fb.z_index = L2_BASE
		container.add_child(board_fb)

	# L3 — raw whole ingredient (썰리기 전). drag로 split될 hero. INGREDIENT_RECT(≤45%W/35%H).
	var whole_path: String = ArtRegistry.get_ingredient(ing_name, "whole")
	if whole_path == "":
		whole_path = ArtRegistry.get_ingredient(ing_name, "raw")
	if whole_path != "":
		_whole_tex = TextureRect.new()
		_whole_tex.texture = load(whole_path)
		Composition.fit_texture_rect(_whole_tex, INGREDIENT_RECT)
		_whole_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_whole_tex.z_index = L3_INGREDIENT
		container.add_child(_whole_tex)
	else:
		# 폴백: 색 블록 (재료 art 미존재 음식).
		var fb := ColorRect.new()
		fb.color = Color(0.92, 0.62, 0.30)
		fb.position = INGREDIENT_RECT.position
		fb.size = INGREDIENT_RECT.size
		fb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fb.z_index = L3_INGREDIENT
		container.add_child(fb)
		_whole_tex = null

	# L3 swap target — prepared(chopped/julienne) standalone, 마지막에 fade-in (같은 자리).
	if ArtRegistry.file_exists(_cut_path):
		_cut_tex = TextureRect.new()
		_cut_tex.texture = load(_cut_path)
		Composition.fit_texture_rect(_cut_tex, INGREDIENT_RECT)
		_cut_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_cut_tex.modulate = Color(1, 1, 1, 0.0)
		_cut_tex.z_index = L3_INGREDIENT
		container.add_child(_cut_tex)

	return container


## L4 chef_knife standalone sprite (미존재 시 procedural). 손가락 위치로 따라옴.
func _build_knife() -> Node:
	var knife_path: String = ArtRegistry.get_tool("chef_knife")
	if knife_path != "":
		# Node2D wrapper로 감싸 손가락 추적 + 회전을 일관 처리.
		var wrap := Node2D.new()
		wrap.z_index = L4_TOOL
		var tex := TextureRect.new()
		# expand_mode를 texture 할당 전에 — 1024px 최소크기 박힘 방지(거대 칼 버그).
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.custom_minimum_size = Vector2.ZERO
		tex.texture = load(knife_path)
		tex.size = KNIFE_RECT.size
		# blade가 손가락(=wrapper origin) 아래로 내려와 재료 cutting line을 덮도록 origin을
		# 칼 상단부에 둔다. 큰 칼(420x756)에서도 blade가 재료 위에 명확히 위치.
		tex.position = -KNIFE_RECT.size * Vector2(0.5, 0.30)   # 칼끝이 아래로 오도록
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wrap.add_child(tex)
		_knife_is_sprite = true
		return wrap
	# procedural fallback.
	_knife_is_sprite = false
	var knife := Node2D.new()
	knife.z_index = L4_TOOL
	var blade := Polygon2D.new()
	blade.polygon = PackedVector2Array([
		Vector2(-14, -120), Vector2(14, -120), Vector2(14, 40),
		Vector2(-2, 96), Vector2(-14, 40),
	])
	blade.color = Color(0.82, 0.84, 0.88)
	knife.add_child(blade)
	var edge := Polygon2D.new()
	edge.polygon = PackedVector2Array([
		Vector2(8, -120), Vector2(14, -120), Vector2(14, 40), Vector2(-2, 96),
	])
	edge.color = Color(0.95, 0.96, 0.98)
	knife.add_child(edge)
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
		_set_instruction("Drag straight through the ingredient ↓")
		return
	var score: float = _score_cut(info)
	_cut_scores.append(score)
	_cuts_done += 1
	_apply_cut_visual(score)
	_update_indicator()
	# L5 VFX — slice spark at the cut point (knife crossing the ingredient).
	var cut_pt := Vector2(info["end"].x, INGREDIENT_RECT.position.y + INGREDIENT_RECT.size.y * 0.45)
	CookingFX.slice_spark(self, cut_pt, float(_style["angle"]))
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
	# §8.4 roll→slice: window_scale<1.0이면 perfect/good 각도 허용폭이 좁아진다(빡빡한 판정).
	var perfect_ang: float = 12.0 * _vs_window_scale
	var good_ang: float = 30.0 * _vs_window_scale
	var dir_score: float
	if ang_err <= perfect_ang:
		dir_score = 100.0
	elif ang_err <= good_ang:
		dir_score = 60.0 + (good_ang - ang_err) / maxf(good_ang - perfect_ang, 1.0) * 40.0
	else:
		dir_score = maxf(0.0, 60.0 * (1.0 - (ang_err - good_ang) / 45.0))
	# (2) 속도 band 일관성 — cut style 목표 속도 band 안이면 만점.
	#   §8.4: window_scale<1.0이면 속도 band를 중심 기준으로 좁힌다(loose roll → 자르기 빡빡).
	var spd: float = float(info["avg_speed"])
	var spd_center: float = (float(_style["speed_lo"]) + float(_style["speed_hi"])) * 0.5
	var spd_half: float = (float(_style["speed_hi"]) - float(_style["speed_lo"])) * 0.5 * _vs_window_scale
	var lo: float = spd_center - spd_half
	var hi: float = spd_center + spd_half
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
## Cooking Realism Fix (2026-06-07): whole/cut 동시 표시 시 double-exposure ghost가 생긴다.
## whole을 끝까지 주연으로 두고 cut overlay는 거의 숨겨 둔 뒤 _finalize에서만 깔끔히 swap.
func _apply_cut_visual(score: float) -> void:
	var prog: float = float(_cuts_done) / float(maxi(1, _cut_target))
	# whole sprite 점점 fade (썰릴수록 원형 사라짐) — 마지막 cut 전까지 0.6 이상 유지.
	if is_instance_valid(_whole_tex):
		var tw := _whole_tex.create_tween()
		tw.tween_property(_whole_tex, "modulate:a", maxf(1.0 - prog * 0.6, 0.0), 0.18)
	# cut overlay는 거의 숨겨 둠 (mid-progress ghost 방지) — 최종 swap은 _finalize에서.
	if is_instance_valid(_cut_tex):
		var tw2 := _cut_tex.create_tween()
		tw2.tween_property(_cut_tex, "modulate:a", clampf(prog * 0.25, 0.0, 0.25), 0.22)
	# 떨어져 나간 조각 1개 spawn (cut sprite mini 복제 또는 색 블록).
	_spawn_piece(score)


func _spawn_piece(score: float) -> void:
	if not is_instance_valid(_pieces_holder):
		return
	var piece: Control
	# §8.5 gimbap VS 통썰기 — 완성 roll의 단면(content_only)을 조각으로 spawn(carrot이 아닌 김밥
	#   조각). 큰 조각이라 wobble(roll 나쁨→제각각 단면)이 명확히 보인다.
	var vs_piece_path: String = ArtRegistry.get_roll_asset("gimbap_roll_finished_content_only") if _vs_active else ""
	if vs_piece_path != "":
		var vt := TextureRect.new()
		vt.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		vt.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		vt.custom_minimum_size = Vector2.ZERO
		vt.texture = load(vs_piece_path)
		vt.size = Vector2(118, 118)   # 김밥 조각 — wobble이 보이게 크게.
		piece = vt
	elif ArtRegistry.file_exists(_cut_path):
		var t := TextureRect.new()
		# expand_mode를 texture 할당 전에 — 1024px 최소크기 박힘 방지(거대 piece 버그).
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		t.custom_minimum_size = Vector2.ZERO
		t.texture = load(_cut_path)
		t.size = Vector2(72, 72)   # neat pile — raw보다 확실히 작게.
		piece = t
	else:
		var c := ColorRect.new()
		c.color = Color(0.95, 0.66, 0.34)
		c.size = Vector2(72, 36)
		piece = c
	piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# board 오른쪽 neat pile(PILE_RECT)에 정렬해 누적 — raw보다 크지 않게.
	# §8.4 roll→slice: window_scale 낮음(loose roll)이면 조각이 wobble(제각각 크기/기울기) — "조각이
	#   제각각이라 단면이 지저분". window_scale=1.0(tight)이면 깔끔히 정렬(기존 동작 보존).
	var wobble: float = clampf(1.0 - _vs_window_scale, 0.0, 1.0) if _vs_active else 0.0
	var idx: int = _cuts_done - 1
	var px: float
	var py: float
	if _vs_active:
		# 김밥 8조각 — board 아래 가로 row로 펼쳐 단면이 보이게(통썰기 결과). wobble = 위치/기울기 흔들림.
		var slot_w: float = 134.0
		var n: int = maxi(_cut_target, 1)
		var row_w: float = float(n) * slot_w
		var rx0: float = 540.0 - row_w * 0.5 + slot_w * 0.5
		px = rx0 + float(idx) * slot_w + randf_range(-6.0, 6.0) + randf_range(-30.0, 30.0) * wobble
		py = 1300.0 + randf_range(-4.0, 4.0) + randf_range(-22.0, 22.0) * wobble
	else:
		# board 오른쪽 neat pile(PILE_RECT)에 정렬해 누적 — raw보다 크지 않게(기존 동작 보존).
		var cols: int = 3
		var jx: float = randf_range(-8.0, 8.0)
		var jy: float = randf_range(-6.0, 6.0)
		px = PILE_RECT.position.x + float(idx % cols) * 100.0 + jx
		py = PILE_RECT.position.y + float(idx / cols) * 60.0 + jy
	piece.position = Vector2(px, py - 40.0)
	if wobble > 0.05:
		piece.pivot_offset = piece.size * 0.5
		piece.rotation = deg_to_rad(randf_range(-22.0, 22.0) * wobble)
		# 조각 크기도 제각각(두께 차이) — wobble 비례 scale 편차.
		var sj: float = 1.0 + randf_range(-0.22, 0.22) * wobble
		piece.scale = Vector2(sj, sj)
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
