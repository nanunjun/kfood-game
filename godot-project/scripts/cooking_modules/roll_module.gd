## RollModule — TWO-FINGER bottom-to-top gimbap rolling (STRICT TOP-DOWN rebuild 2026-06-12).
##
## "I am rolling the gimbap from the bottom upward." 플레이어는 도마를 **똑바로 위에서 내려다본다**
## (strict top-down, 사선 0). 김발(bamboo mat)이 화면 **아래쪽 near edge에서 위쪽으로 접히며**
## 김+밥+속을 단단한 **수평 원통**으로 만다. roll axis = **left-to-right 고정**(항상 수평).
## 핵심 skill = balance(좌우 sync), even pressure(일관된 누름), full roll(끝까지 말기), smooth.
##
## ── 사용자 거부 교정 (2026-06-12 strict top-down rebuild) ────────────────────────────
## 반복 불만: 김밥이 사선/3-4/floating, 김발 twist, "말리는 느낌" 약함. 원인 = AI staged curl
## sprite(gimbap_roll_*)가 oblique 3/4 + end-cap 단면을 baked → Godot transform으로 못 편다.
## 교정 = gimbap_slice_module과 동일 철학으로 **procedural 강제 top-down**(custom _draw).
##   - 김발 mat = 화면과 평행한 수평 직사각 (oblique parallelogram sprite 폐기).
##   - rolling = mat이 **bottom edge → top**으로 접히는 fold (mat twist 0, 가로 stretch 0).
##   - 완성 cylinder = **수평**(rotation 0, axis L→R 고정), end-cap 단면 노출 0(slice 단계에서만).
##   - floating roll icon 0 — 모든 오브젝트가 동일 top-down plane, shadow 정하향.
##
## ── 입력 (two-finger multi-touch — 무변경) ───────────────────────────────────────────
## InputEventScreenTouch / InputEventScreenDrag의 index로 좌·우 손가락을 **독립 추적**한다.
##   - 화면 좌측 절반에서 시작한 터치 = LEFT 손가락, 우측 = RIGHT 손가락.
##   - 두 손가락이 mat **bottom edge를 위로 drag** = 각 side의 fold 진행(bottom→top).
##   - 좌우 진행 차이 = tilt(균형, 균일=tight / 다름=crooked). 평균 진행 = roll distance.
## DESKTOP fallback (테스트/screenshot): 마우스 좌클릭 = 시작점이 속한 side를 드래그, 동시에
##   다른 side는 keyboard(A/D 또는 ←/→)로 시뮬레이션. 키보드 단독 sim도 지원(테스트 결정성).
##
## ── SCORING (무변경) ─────────────────────────────────────────────────────────────────
## §6.1 — 40% 좌우 balance / 25% pressure consistency / 20% roll completion distance /
##   15% smooth motion. 0~100 → `module_completed(score)` 로 emit (contract 무변경).
## CONTRACT 보존: module_completed(0~100) signal / MODULE_TO_FACTOR("roll"→prep) / 4-factor /
##   progression / save / economy / consequence(§8.2 prep→roll, §8.3 arrange→roll) 전부 동일.
##
## ── 레이어 (strict top-down, z bottom→top) ───────────────────────────────────────────
##   1. _TopDownRollStage   — procedural mat + 김 + 밥 + 속 + 말리는 cylinder (한 custom-draw 노드)
##   2. two-finger UI       — 좌·우 원형 target + ghost finger + 위 화살표 2개 + balance meter
## 시각은 전부 _stage가 담당(fold progress + tilt만 전달). 가로 stretch / rotation(cylinder) 0.
extends "res://scripts/cooking_modules/base_module.gd"

# --- top-down composition geometry (strict top-down, 사선 0) ---
# 도마(작업면)를 화면 1080x1920 중앙 action zone에 수평으로 눕힌다. mat box = 화면과 평행한
# 직사각(oblique 0). near edge = box 하단(화면 앞쪽), far edge = box 상단(화면 뒤쪽).
const ROLL_X: float = 540.0              # roll 중심 X (좌우 대칭축).
# mat 작업면 box — 가로로 넓게(roll axis = 가로). top-down 직사각.
const MAT_RECT := Rect2(120, 660, 840, 560)   # (x, y, w, h) — 화면과 평행한 수평 작업면.
const ROLL_HERO_Y: float = 760.0         # dish shadow / feedback anchor 참고용(기존 호환).

# two-finger 입력 / target — mat **bottom edge(near)** 양쪽을 위로 drag.
const TOUCH_TARGET_OFFSET_X: float = 250.0   # 좌·우 target X 오프셋(중심 기준).
const TOUCH_TARGET_Y: float = 1300.0         # 두 target Y (mat 하단 near edge 아래 — drag 시작점).
const TOUCH_TARGET_R: float = 62.0           # 원형 target 반지름.
const PUSH_DISTANCE: float = 440.0           # 완전한 roll까지 필요한 위로 push 거리(px).

# balance / pressure 판정 임계.
const TILT_WARN: float = 0.12            # 좌우 진행 차 — 이 이상 = tilt 경고.
const TILT_BAD: float = 0.28             # 이 이상 = crooked(심한 비뚤).
const SMOOTH_JITTER_REF: float = 1800.0  # 속도 변동(px/s) 기준 — 이 이상이면 smooth 감점.

# === Gimbap Vertical Slice — consequence hook (design §8.2 / §8.3) ===
# Pass B: prep_quality(julienne strip 품질) → roll sweet zone 폭 보정 / arrange balance →
#   tilt 기준점 offset. roll input(two-finger)·scoring 공식(40/25/20/15)은 무변경. 오직
#   sweet zone 너비와 tilt 기준만 quality-state로 보정한다(같은 입력 → 다른 결과 = 인과 증명).
#   기본값(1.0 / 0.0)은 vertical slice가 아닌 일반 runner에서 기존 난이도를 100% 보존한다.
var _vs_sweet_scale: float = 1.0     # 1.0 = 기존 sweet zone. <1.0 = 좁아짐(prep 나쁨 → 말기 어려움).
var _vs_tilt_offset: float = 0.0     # 좌우 진행 bias(arrange 불균형 → cylinder가 비뚤어지는 쪽).
var _vs_active: bool = false         # vertical slice consequence가 켜졌는지(로그/visual 분기용).

# --- roll 진행 상태 (two-finger) ---
var _left_progress: float = 0.0          # LEFT 손가락 forward 진행 0~1.2.
var _right_progress: float = 0.0         # RIGHT 손가락 forward 진행 0~1.2.
var _rolling: bool = false               # 한 쪽이라도 누르고 있으면 true.

# 손가락별 추적 (multi-touch index → 상태).
var _left_id: int = -1                   # LEFT 손가락 touch index (-1 = 없음).
var _right_id: int = -1                  # RIGHT 손가락 touch index.
var _left_start_y: float = 0.0
var _right_start_y: float = 0.0
var _left_last_y: float = 0.0
var _right_last_y: float = 0.0
var _left_last_ms: float = 0.0
var _right_last_ms: float = 0.0

# smooth / pressure 표본 — 양손 속도 변동(jitter)과 push 누락.
var _speed_samples: Array = []           # 각 update의 |Δspeed| (px/s) — 클수록 거칠다.
var _last_left_speed: float = 0.0
var _last_right_speed: float = 0.0
var _both_down_frames: int = 0           # 두 손가락 동시에 눌린 update 수.
var _any_down_frames: int = 0            # 한 쪽이라도 눌린 update 수 (동시성 비율 산출).

# desktop fallback (마우스 = 한 손, keyboard = 다른 손 sim).
var _mouse_side: int = 0                 # 0=없음, -1=좌, +1=우 (현재 마우스가 잡은 side).
var _kb_left_held: bool = false
var _kb_right_held: bool = false

# --- 시각 nodes (strict top-down procedural) ---
var _stage: _TopDownRollStage = null      # mat + 김 + 밥 + 속 + 말리는 cylinder (custom-draw 단일 노드)

# two-finger UI.
var _ui_left: _TouchTargetDraw = null
var _ui_right: _TouchTargetDraw = null
var _balance_meter: _BalanceMeterDraw = null
var _hint: Label = null                  # 실시간 feedback message.
var _track: ColorRect = null
var _fill_marker: ColorRect = null


func _module_start(params: Dictionary) -> void:
	_attach_cooking_bg(1000.0)
	# Step 2/4 Roll — game flow 보존. dish name = Gimbap (header title는 "Roll").
	_build_header("Roll", "Drag both sides upward evenly")
	set_process_input(true)
	_consume_vs_consequence(params)

	# soft contact shadow — mat 작업면 아래 정하향(top-down 통일, 사선 0).
	_attach_dish_shadow(Vector2(ROLL_X, MAT_RECT.position.y + MAT_RECT.size.y + 8.0), 700.0)

	# Layer 1 — strict top-down procedural stage (mat + 김 + 밥 + 속 + 말리는 cylinder).
	_build_top_down_stage()
	# Layer 2 — two-finger UI (좌·우 target + ghost + arrow + balance meter).
	_build_two_finger_ui()
	# progress track.
	_build_progress_ui()

	# 실시간 feedback message.
	_hint = Label.new()
	_hint.position = Vector2(0, 1560)
	_hint.size = Vector2(1080, 70)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 44)
	_hint.add_theme_color_override("font_color", Color(0.30, 0.20, 0.12))
	_hint.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.85))
	_hint.add_theme_constant_override("outline_size", 8)
	_hint.text = "Drag both sides upward evenly to roll the gimbap tight."
	add_child(_hint)


# Layer 1 — strict top-down procedural stage (사선/twist/floating 0).
#
# 사용자 거부 교정: AI staged curl sprite(oblique + end-cap baked)를 폐기하고 gimbap_slice_module과
# 동일하게 custom-draw 노드로 강제 top-down을 보장한다. mat은 화면과 평행한 수평 직사각, fold는
# bottom→top, 완성 cylinder는 항상 수평(rotation 0). 단면(end-cap)은 절대 안 보인다(slice 단계 OK).
func _build_top_down_stage() -> void:
	_stage = _TopDownRollStage.new()
	_stage.name = "TopDownRollStage"
	_stage.position = MAT_RECT.position
	_stage.setup(MAT_RECT.size)
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.z_index = L3_INGREDIENT
	add_child(_stage)


# Layer 5 — two-finger UI: 좌·우 원형 target + ghost finger + 위 화살표 2개 + balance meter.5
func _build_two_finger_ui() -> void:
	# 좌 target.
	_ui_left = _TouchTargetDraw.new()
	_ui_left.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ui_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_left.center = Vector2(ROLL_X - TOUCH_TARGET_OFFSET_X, TOUCH_TARGET_Y)
	_ui_left.radius = TOUCH_TARGET_R
	_ui_left.z_index = L5_VFX
	add_child(_ui_left)
	# 우 target.
	_ui_right = _TouchTargetDraw.new()
	_ui_right.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ui_right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_right.center = Vector2(ROLL_X + TOUCH_TARGET_OFFSET_X, TOUCH_TARGET_Y)
	_ui_right.radius = TOUCH_TARGET_R
	_ui_right.z_index = L5_VFX
	add_child(_ui_right)
	# 좌·우 balance meter (균등 push 여부).
	_balance_meter = _BalanceMeterDraw.new()
	_balance_meter.set_anchors_preset(Control.PRESET_FULL_RECT)
	_balance_meter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_balance_meter.bar_rect = Rect2(ROLL_X - 320.0, 1400.0, 640.0, 44.0)
	_balance_meter.z_index = L5_VFX
	add_child(_balance_meter)


func _build_progress_ui() -> void:
	_track = ColorRect.new()
	_track.color = Color(0, 0, 0, 0.12)
	_track.size = Vector2(640, 18)
	_track.position = Vector2(ROLL_X - 320.0, 1466.0)
	_track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_track)
	_fill_marker = ColorRect.new()
	_fill_marker.color = Color(0.30, 0.55, 0.30)
	_fill_marker.size = Vector2(8, 26)
	_fill_marker.position = Vector2(ROLL_X - 320.0 - 4.0, 1462.0)
	_fill_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fill_marker)


# =====================================================================================
# Two-finger multi-touch input — 좌·우 손가락 독립 추적 + desktop fallback.
# =====================================================================================

func _input(event: InputEvent) -> void:
	if _finished:
		return
	if event is InputEventScreenTouch:
		_handle_touch(event.index, event.position, event.pressed)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		_handle_drag(event.index, event.position)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		# DESKTOP fallback — 마우스 좌클릭 = 시작점이 속한 side를 잡고 드래그.
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_mouse_side = -1 if event.position.x < ROLL_X else 1
				_finger_down(_mouse_side, 900 + _mouse_side, event.position)
			elif _mouse_side != 0:
				_finger_up(900 + _mouse_side)
				_mouse_side = 0
	elif event is InputEventMouseMotion:
		if _mouse_side != 0:
			_finger_move(900 + _mouse_side, event.position)
	elif event is InputEventKey:
		# DESKTOP/test fallback — A/← = 좌손, D/→ = 우손 sim. push 진행을 매 hold로 누적.
		var pressed: bool = event.pressed and not event.echo
		var released: bool = not event.pressed
		if event.keycode == KEY_A or event.keycode == KEY_LEFT:
			if pressed: _kb_left_held = true
			elif released: _kb_left_held = false
		elif event.keycode == KEY_D or event.keycode == KEY_RIGHT:
			if pressed: _kb_right_held = true
			elif released: _kb_right_held = false


# touch index 라우팅 — 좌/우 slot에 배정 (multi-touch 독립 추적).
func _handle_touch(index: int, pos: Vector2, pressed: bool) -> void:
	if pressed:
		var side: int = -1 if pos.x < ROLL_X else 1
		_finger_down(side, index, pos)
	else:
		_finger_up(index)


func _handle_drag(index: int, pos: Vector2) -> void:
	_finger_move(index, pos)


# side(-1 좌 / +1 우)에 손가락을 등록. 이미 해당 side가 점유면 무시(같은 손가락 갱신).
func _finger_down(side: int, index: int, pos: Vector2) -> void:
	var now: float = float(Time.get_ticks_msec())
	if side < 0:
		_left_id = index
		_left_start_y = pos.y
		_left_last_y = pos.y
		_left_last_ms = now
		if is_instance_valid(_ui_left):
			_ui_left.touched = true
			_ui_left.finger_pos = pos
			_ui_left.queue_redraw()
	else:
		_right_id = index
		_right_start_y = pos.y
		_right_last_y = pos.y
		_right_last_ms = now
		if is_instance_valid(_ui_right):
			_ui_right.touched = true
			_ui_right.finger_pos = pos
			_ui_right.queue_redraw()
	_rolling = true


func _finger_up(index: int) -> void:
	var was_left: bool = index == _left_id
	var was_right: bool = index == _right_id
	if was_left:
		_left_id = -1
		if is_instance_valid(_ui_left):
			_ui_left.touched = false
			_ui_left.queue_redraw()
	if was_right:
		_right_id = -1
		if is_instance_valid(_ui_right):
			_ui_right.touched = false
			_ui_right.queue_redraw()
	# 두 손가락 모두 release되면 roll 마감(완성 판정).
	if _left_id == -1 and _right_id == -1 and _rolling:
		_rolling = false
		_finalize_roll()


func _finger_move(index: int, pos: Vector2) -> void:
	var now: float = float(Time.get_ticks_msec())
	if index == _left_id:
		var dt: float = maxf(now - _left_last_ms, 1.0) / 1000.0
		var dy: float = _left_last_y - pos.y          # 위로 이동 = 양수.
		_left_progress = clampf((_left_start_y - pos.y) / PUSH_DISTANCE, 0.0, 1.2)
		_last_left_speed = dy / dt
		_left_last_y = pos.y
		_left_last_ms = now
		if is_instance_valid(_ui_left):
			_ui_left.finger_pos = pos
			_ui_left.queue_redraw()
	elif index == _right_id:
		var dt2: float = maxf(now - _right_last_ms, 1.0) / 1000.0
		var dy2: float = _right_last_y - pos.y
		_right_progress = clampf((_right_start_y - pos.y) / PUSH_DISTANCE, 0.0, 1.2)
		_last_right_speed = dy2 / dt2
		_right_last_y = pos.y
		_right_last_ms = now
		if is_instance_valid(_ui_right):
			_ui_right.finger_pos = pos
			_ui_right.queue_redraw()
	else:
		return
	_sample_motion()
	_apply_roll_visual()
	_update_hint()


# keyboard hold sim (desktop/test) — A/D를 누르고 있으면 매 프레임 push 누적.
func _process(delta: float) -> void:
	if _finished:
		return
	var changed: bool = false
	if _kb_left_held:
		_left_progress = clampf(_left_progress + delta * 0.85, 0.0, 1.2)
		_rolling = true
		changed = true
		if is_instance_valid(_ui_left):
			_ui_left.touched = true
			_ui_left.queue_redraw()
	if _kb_right_held:
		_right_progress = clampf(_right_progress + delta * 0.85, 0.0, 1.2)
		_rolling = true
		changed = true
		if is_instance_valid(_ui_right):
			_ui_right.touched = true
			_ui_right.queue_redraw()
	if changed:
		_apply_roll_visual()
		_update_hint()


# smooth motion / pressure / 동시성 표본 누적.
func _sample_motion() -> void:
	_any_down_frames += 1
	if _left_id != -1 and _right_id != -1:
		_both_down_frames += 1
	# jitter = 양손 속도의 프레임 간 변동(절대값 합). 클수록 거친 동작.
	var jitter: float = absf(_last_left_speed - _last_right_speed)
	_speed_samples.append(jitter)
	if _speed_samples.size() > 240:
		_speed_samples.pop_front()


# =====================================================================================
# Roll visual — bottom-to-top fold → 수평 cylinder. uneven=crooked / weak=loose / strong=tight.
# 시각은 전부 _stage(custom-draw)가 담당. roll axis = 가로 고정, cylinder rotation 0 (수평 유지).
# =====================================================================================

func _apply_roll_visual() -> void:
	var avg_p: float = (_left_progress + _right_progress) * 0.5
	var roundness: float = clampf(avg_p, 0.0, 1.0)
	# tilt = 좌우 진행 차 (양수 = 좌가 빠름 → 왼쪽이 더 말림 = crooked).
	# §8.3 arrange→roll: arrange 불균형이면 균등 push여도 tilt가 offset만큼 bias된다(비뚤어 보임).
	var tilt: float = (_left_progress - _right_progress) + _vs_tilt_offset * roundness
	# _stage가 fold 진행(bottom→top) + 좌우 비대칭(tilt)을 custom-draw로 그린다. cylinder는 항상 수평.
	if is_instance_valid(_stage):
		_stage.set_roll(roundness, tilt)
	# balance meter / target UI 갱신.
	if is_instance_valid(_balance_meter):
		_balance_meter.left_p = _left_progress
		_balance_meter.right_p = _right_progress
		_balance_meter.queue_redraw()
	# target push 진행을 ghost ring으로 표시.
	if is_instance_valid(_ui_left):
		_ui_left.progress = clampf(_left_progress, 0.0, 1.0)
		_ui_left.queue_redraw()
	if is_instance_valid(_ui_right):
		_ui_right.progress = clampf(_right_progress, 0.0, 1.0)
		_ui_right.queue_redraw()
	# 진행 마커.
	if is_instance_valid(_fill_marker):
		_fill_marker.position.x = ROLL_X - 320.0 + roundness * 640.0 - 4.0


# 실시간 feedback message (요구 §6).
func _update_hint() -> void:
	if not is_instance_valid(_hint):
		return
	var avg_p: float = (_left_progress + _right_progress) * 0.5
	var diff: float = absf(_left_progress - _right_progress)
	var tilt_ratio: float = diff
	var both_down: bool = (_left_id != -1 or _kb_left_held) and (_right_id != -1 or _kb_right_held)
	var msg: String
	if not both_down and _rolling:
		msg = "Drag both sides upward together"
	elif tilt_ratio > TILT_BAD:
		msg = "Left side too far ahead" if _left_progress > _right_progress else "Right side too far ahead"
	elif avg_p > 1.05:
		msg = "Too much pressure!" if diff < TILT_WARN else "Fillings squeezed out"
	elif tilt_ratio > TILT_WARN:
		msg = "Keep both sides even"
	elif avg_p < 0.35:
		msg = "Keep rolling upward"
	elif avg_p >= 0.78 and diff <= TILT_WARN:
		msg = "Tight roll!"
	elif diff <= TILT_WARN * 0.6 and avg_p >= 0.45:
		msg = "Perfect Balance!"
	else:
		msg = "Drag both sides upward evenly"
	_hint.text = msg


# =====================================================================================
# NEW SCORING (40 balance / 25 pressure / 20 distance / 15 smooth) → [0,100].
# CONTRACT 보존: 0~100 → module_completed → prep factor.
# =====================================================================================

# _legacy_ignored: 구 dev shot 스크립트가 _finalize_roll(false)로 호출하던 잔재 호환(무시).
func _finalize_roll(_legacy_ignored: bool = false) -> void:
	var score: float = _compute_roll_score(_left_progress, _right_progress,
			_collect_pressure_metric(), _collect_smooth_metric())
	var j := RhythmJudge.PERFECT if score >= 80.0 else (RhythmJudge.GOOD if score >= 40.0 else RhythmJudge.MISS)
	_safe_feedback(j, Vector2(ROLL_X, 1000.0))

	var avg_p: float = (_left_progress + _right_progress) * 0.5
	# §8.3 arrange→roll: effective tilt = 좌우 차 + arrange bias offset.
	var diff: float = absf((_left_progress - _right_progress) + _vs_tilt_offset)
	# §8.2 prep→roll: sweet zone 좁아지면(_vs_sweet_scale<1) burst 임계가 내려오고 loose 임계가
	#   올라가 같은 push여도 더 쉽게 찢김/헐거움 판정 → "대충 썬 당근으로는 깔끔히 못 만다".
	var burst_thresh: float = lerpf(0.98, 1.05, _vs_sweet_scale)   # default 1.05
	var loose_thresh2: float = lerpf(0.62, 0.5, _vs_sweet_scale)   # default 0.5
	var burst: bool = avg_p > burst_thresh
	var crooked: bool = (diff / 1.0) > TILT_BAD
	var loose: bool = avg_p < loose_thresh2
	if is_instance_valid(_hint):
		if score >= 80.0:
			_hint.text = "Perfect, tight roll!"
		elif crooked:
			_hint.text = "Crooked roll - uneven push"
		elif burst:
			_hint.text = "Fillings squeezed out"
		elif loose:
			_hint.text = "Roll is a bit loose"
		else:
			_hint.text = "Rolled!"

	# 완성 김밥은 SUCCESS에서만 둥근 tight cylinder (score≥60, 안 터짐, 안 비뚤).
	var well_rolled: bool = score >= 60.0 and not burst and not crooked

	# ── 끝 상태 확정 (procedural _stage가 result shape를 그린다 — 가짜 sprite 없음) ──────────
	# 기존 burst/loose/well_rolled 플래그 1:1 매핑 (scoring 무변경). cylinder는 항상 **수평**
	# (well_rolled면 tilt 0으로 settle, crooked면 기운 채 유지). 단면(end-cap) 노출 0 — 완성
	# log는 위에서 본 수평 원통일 뿐(spiral 단면은 다음 Slice 단계에서만).
	#   well_rolled → finished(둥근 tight, tilt 0) / burst → tight(rice 삐져나옴) / loose → loose(느슨).
	var result_state: int = _TopDownRollStage.RESULT_FINISHED
	if burst:
		result_state = _TopDownRollStage.RESULT_TIGHT
	elif loose:
		result_state = _TopDownRollStage.RESULT_LOOSE
	elif not well_rolled:
		result_state = _TopDownRollStage.RESULT_LOOSE
	if is_instance_valid(_stage):
		# 완성 = roundness 1.0 고정. well_rolled면 tilt 0(똑바른 수평 원통)으로 settle.
		var settle_tilt: float = 0.0 if well_rolled else diff * signf((_left_progress - _right_progress) + _vs_tilt_offset)
		_stage.finalize_roll(result_state, settle_tilt)
	# two-finger UI 페이드 (역할 종료).
	for ui in [_ui_left, _ui_right, _balance_meter]:
		if is_instance_valid(ui):
			ui.create_tween().tween_property(ui, "modulate:a", 0.0, 0.22)
	_finish(score)


# pressure consistency metric ∈ [0,1] — 양손 push가 얼마나 동시·꾸준했는지.
# 두 손가락이 동시에 눌린 비율(both/any)이 높을수록 일관(=1). pressure 부족/과다 보정은 score에서.
func _collect_pressure_metric() -> float:
	if _any_down_frames <= 0:
		return 0.0
	return clampf(float(_both_down_frames) / float(_any_down_frames), 0.0, 1.0)


# smooth motion metric ∈ [0,1] — 양손 속도 변동(jitter) 평균이 작을수록 매끄럽다(=1).
func _collect_smooth_metric() -> float:
	if _speed_samples.is_empty():
		return 0.5
	var s: float = 0.0
	for v in _speed_samples:
		s += float(v)
	var avg_jitter: float = s / float(_speed_samples.size())
	return clampf(1.0 - avg_jitter / SMOOTH_JITTER_REF, 0.0, 1.0)


# =====================================================================================
# Gimbap Vertical Slice consequence — prep_quality / arrange balance carry (design §8.2/§8.3).
# =====================================================================================

## runner가 넘긴 vs_quality_state를 읽어 sweet zone 폭(prep→roll) + tilt 기준(arrange→roll)을
## 보정한다. 일반 runner 호출(params에 vs_quality_state 없음)은 _vs_sweet_scale=1.0 유지 → 무영향.
##   §8.2 prep→roll: prep_quality 낮음(두꺼운 chunky strip) → 속이 고르게 안 깔려 sweet zone이
##     좁아짐(burst/loose 판정에 빠지기 쉬움). sweet_scale = lerp(0.62, 1.0, prep_quality).
##   §8.3 arrange→roll: arrange balance 낮음(filling 한쪽 몰림) → two-finger가 균등해도
##     cylinder가 비뚤어지는 쪽으로 bias. tilt_offset = (1 - balance) × sign.
func _consume_vs_consequence(params: Dictionary) -> void:
	if not params.has("vs_quality_state"):
		return
	var qs: Dictionary = params.get("vs_quality_state", {})
	if qs.is_empty():
		return
	_vs_active = true
	var prep_q: float = clampf(float(qs.get("prep_quality", 1.0)), 0.0, 1.0)
	# prep 나쁨 → sweet zone 좁아짐(0.62배). prep 좋음 → 기존(1.0배). casual 관대 band.
	_vs_sweet_scale = lerpf(0.62, 1.0, prep_q)
	# arrange balance(좌우 filling 대칭도) → tilt 기준점 offset. 없으면 0(영향 없음).
	var balance: float = clampf(float(qs.get("arrange_balance", 1.0)), 0.0, 1.0)
	var bias_dir: float = float(qs.get("arrange_bias_dir", 1.0))   # +1 = 좌측 쏠림 / -1 = 우측.
	_vs_tilt_offset = (1.0 - balance) * 0.34 * signf(bias_dir if bias_dir != 0.0 else 1.0)
	if is_instance_valid(_hint):
		if prep_q < 0.45:
			_hint.text = "Chunky filling - roll carefully"
	print("[roll-vs] prep_q=%.2f sweet_scale=%.2f arrange_bal=%.2f tilt_off=%.3f" % [
		prep_q, _vs_sweet_scale, balance, _vs_tilt_offset])


## §6.1 (새 공식) — roll 품질 → [0,100]. 인자로 받아 smoke test에서 직접 호출 가능.
##   left_p / right_p : 좌·우 손가락 forward 진행 (0~1.2).
##   pressure_metric  : 양손 동시성/일관성 [0,1] (= both/any down 비율).
##   smooth_metric    : 매끄러움 [0,1] (속도 변동 작을수록 1).
## 가중치: 40% balance / 25% pressure / 20% distance / 15% smooth.
##   - balance  = 1 - |left-right| 정규화 (좌우 movement difference 작을수록 1).
##   - pressure = pressure_metric을, sweet zone 누름이면 가산 (loose/burst 감점).
##   - distance = roll completion (sweet zone에 도달=1, under=비례 감소, over=감소).
##   - smooth   = smooth_metric.
## perfect = 균등 two-finger + 안정 pressure + full distance + no squeeze + clean cylinder.
func _compute_roll_score(left_p: float, right_p: float,
		pressure_metric: float, smooth_metric: float) -> float:
	var lp: float = clampf(left_p, 0.0, 1.2)
	var rp: float = clampf(right_p, 0.0, 1.2)
	var avg_p: float = (lp + rp) * 0.5

	# (1) balance 40% — 좌우 movement difference. diff를 PUSH 진행 스케일(1.0)로 정규화.
	#   §8.3 arrange→roll: arrange 불균형이면 균등 push여도 effective diff가 bias된다(비뚤어짐).
	var diff: float = absf(lp - rp) + absf(_vs_tilt_offset)
	var balance: float = clampf(1.0 - diff / 0.6, 0.0, 1.0)   # diff 0.6 이상이면 balance 0.

	# §8.2 prep→roll: sweet zone 폭 = _vs_sweet_scale 배(prep 나쁨 → 좁아짐). 중심(0.92)
	#   기준으로 lower/upper bound를 스케일. _vs_sweet_scale=1.0이면 기존(0.82~1.02) 동일.
	var sw_center: float = 0.92
	var sw_lo: float = sw_center - (sw_center - 0.82) * _vs_sweet_scale   # default 0.82
	var sw_hi: float = sw_center + (1.02 - sw_center) * _vs_sweet_scale   # default 1.02
	# pressure loose 임계(기본 0.5)도 prep 나쁨에 비례해 위로 당겨 약한 push가 더 쉽게 loose 처리.
	var loose_thresh: float = lerpf(0.62, 0.5, _vs_sweet_scale)

	# (3) roll completion distance 20% — sweet zone 도달=1, under 비례, over 감소.
	var distance: float
	if avg_p < sw_lo:
		distance = clampf(avg_p / maxf(sw_lo, 0.01), 0.0, 1.0)
	elif avg_p <= sw_hi:
		distance = 1.0
	else:
		distance = clampf(1.0 - (avg_p - sw_hi) / 0.18, 0.0, 1.0)

	# (2) pressure consistency 25% — 동시성(pressure_metric) × push 적정도.
	#   loose(avg_p 낮음) → 약한 pressure 감점, burst(avg_p>sw_hi) → 강한 pressure 감점.
	var push_quality: float
	if avg_p < loose_thresh:
		push_quality = clampf(avg_p / maxf(loose_thresh, 0.01), 0.0, 1.0)   # loose → 낮음.
	elif avg_p <= sw_hi:
		push_quality = 1.0
	else:
		push_quality = clampf(1.0 - (avg_p - sw_hi) / 0.15, 0.0, 1.0)       # burst → 낮음.
	var pressure: float = clampf(pressure_metric, 0.0, 1.0) * push_quality

	# (4) smooth motion 15%.
	var smooth: float = clampf(smooth_metric, 0.0, 1.0)

	var score: float = (balance * 40.0) + (pressure * 25.0) + (distance * 20.0) + (smooth * 15.0)
	return clampf(score, 0.0, 100.0)


# =====================================================================================
# STRICT TOP-DOWN procedural roll stage (사선/twist/floating 0 보장 — gimbap_slice 철학과 동일).
#
# 한 custom-draw Control이 (1) 수평 김발 mat (2) 김+밥+가로 strip 속 (3) bottom→top fold 진행
# (4) 완성 수평 cylinder를 전부 그린다. roll axis = 가로 고정. cylinder rotation 0(항상 수평).
# 시각 입력은 set_roll(roundness, tilt) 1개 + finalize_roll(result_state, settle_tilt).
#   roundness 0~1 : fold 진행(0=평평 setup, 1=완전히 말린 수평 log).
#   tilt          : 좌우 비대칭(균등=0, 다르면 near edge가 한쪽이 더 올라와 비뚤 — 단 cylinder 자체는 수평).
# end-cap(spiral 단면) 절대 안 그림 — 완성도 위에서 본 둥근 외피 수평 원통일 뿐.
# =====================================================================================
class _TopDownRollStage extends Control:
	enum { RESULT_NONE, RESULT_FINISHED, RESULT_LOOSE, RESULT_TIGHT }

	var _box: Vector2 = Vector2(840, 560)
	var _round: float = 0.0          # fold 진행 0~1.
	var _tilt: float = 0.0           # 좌우 비대칭(균등=0).
	var _result: int = RESULT_NONE   # 끝 상태(완성/loose/tight). rolling 중 NONE.

	# === PAINTERLY SWAP (gimbap-visual-quality-rebuild §5/§6, 2026-06-13) ===
	# procedural capsule _draw를 high-angle painterly 6-state sprite cross-fade로 교체.
	# roundness 0~1 → flat_setup → edge_lift → first_fold → curling → compression → finished.
	# result 분기: well_rolled→roll_finished / loose→roll_finished_loose / burst→roll_finished_burst.
	# tilt(좌우 불균형)는 sprite 살짝 회전/offset만(mat twist 금지, high-angle 수평 유지).
	# 입력/scoring/consequence 무변경 — set_roll/finalize_roll 시그니처 동일, _draw는 fallback만.
	# painterly 미존재 시 _painterly=false → 기존 procedural _draw로 graceful fallback.
	var _painterly: bool = false
	var _stage_sprites: Array = []    # 6 진행 state TextureRect (cross-fade).
	var _result_sprites: Dictionary = {}   # result_state → 완성 variant TextureRect.
	const _STAGE_KEYS := [
		"roll_flat_setup", "roll_edge_lift", "roll_first_fold",
		"roll_curling", "roll_compression", "roll_finished",
	]

	# 김밥 속 색 — danmuji 노랑 / spinach 녹 / carrot 주황 / egg 노랑(GimbapSlice와 정합).
	const FILL_COLS := [
		Color(0.98, 0.82, 0.20),  # danmuji
		Color(0.24, 0.46, 0.18),  # spinach
		Color(0.93, 0.52, 0.18),  # carrot
		Color(0.97, 0.80, 0.26),  # egg
	]
	const SEAWEED := Color(0.13, 0.17, 0.11)
	const SEAWEED_LO := Color(0.08, 0.11, 0.07)
	const RICE := Color(0.97, 0.95, 0.88)
	const MAT_BAMBOO := Color(0.80, 0.62, 0.34)
	const MAT_BAMBOO_LO := Color(0.66, 0.48, 0.24)

	func setup(box: Vector2) -> void:
		_box = box
		size = box
		_build_painterly_sprites()
		queue_redraw()

	## 6 진행 state + 3 result variant painterly sprite를 한 번 깔고 alpha로 cross-fade한다.
	## 전 sprite는 box를 가득 채우는 high-angle painterly(KEEP_ASPECT_CENTERED, 수평 유지).
	func _build_painterly_sprites() -> void:
		var any: bool = false
		for key in _STAGE_KEYS:
			var path: String = ArtRegistry.get_painterly(key)
			var tr := TextureRect.new()
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr.size = _box
			tr.position = Vector2.ZERO
			tr.pivot_offset = _box * 0.5
			tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tr.modulate = Color(1, 1, 1, 0.0)
			if path != "":
				tr.texture = load(path)
				any = true
			add_child(tr)
			_stage_sprites.append(tr)
		# result variant — well_rolled/loose/burst (state 6 분기). 미존재 시 roll_finished로 fallback.
		for pair in [[RESULT_FINISHED, "roll_finished"], [RESULT_LOOSE, "roll_finished_loose"],
				[RESULT_TIGHT, "roll_finished_burst"]]:
			var rpath: String = ArtRegistry.get_painterly(String(pair[1]))
			if rpath == "":
				rpath = ArtRegistry.get_painterly("roll_finished")
			var rt := TextureRect.new()
			rt.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			rt.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			rt.size = _box
			rt.position = Vector2.ZERO
			rt.pivot_offset = _box * 0.5
			rt.mouse_filter = Control.MOUSE_FILTER_IGNORE
			rt.modulate = Color(1, 1, 1, 0.0)
			if rpath != "":
				rt.texture = load(rpath)
				any = true
			add_child(rt)
			_result_sprites[int(pair[0])] = rt
		_painterly = any
		if _painterly:
			_show_stage(0)

	## roundness 0~1 → 6 진행 state index. flat(0)→edge_lift→first_fold→curling→compression→finished.
	func _stage_index_for(r: float) -> int:
		if r < 0.16: return 0
		elif r < 0.34: return 1
		elif r < 0.52: return 2
		elif r < 0.72: return 3
		elif r < 0.90: return 4
		return 5

	## 한 진행 state만 보이게 cross-fade (alpha swap) + tilt를 sprite 회전/offset으로(mat twist 금지).
	func _show_stage(idx: int) -> void:
		for i in range(_stage_sprites.size()):
			var tr: TextureRect = _stage_sprites[i]
			if not is_instance_valid(tr):
				continue
			tr.modulate.a = 1.0 if i == idx else 0.0
		for k in _result_sprites:
			var rt: TextureRect = _result_sprites[k]
			if is_instance_valid(rt):
				rt.modulate.a = 0.0
		_apply_tilt_transform()

	## tilt(좌우 불균형) = sprite 살짝 회전 + x offset만 (수평 painterly 유지, mat 회전/twist 아님).
	func _apply_tilt_transform() -> void:
		var rot: float = clampf(_tilt, -1.0, 1.0) * 0.06   # 최대 ~3.4° (crooked 표현, 미세).
		var dx: float = clampf(_tilt, -1.0, 1.0) * 18.0
		for tr in _stage_sprites:
			if is_instance_valid(tr):
				(tr as Control).rotation = rot
				(tr as Control).position = Vector2(dx, 0.0)
		for k in _result_sprites:
			var rt: TextureRect = _result_sprites[k]
			if is_instance_valid(rt):
				rt.rotation = rot
				rt.position = Vector2(dx, 0.0)

	## roll 진행 갱신 — fold(bottom→top) + 좌우 비대칭. painterly면 state swap, 아니면 procedural _draw.
	func set_roll(roundness: float, tilt: float) -> void:
		_round = clampf(roundness, 0.0, 1.0)
		_tilt = clampf(tilt, -1.0, 1.0)
		if _painterly and _result == RESULT_NONE:
			_show_stage(_stage_index_for(_round))
		queue_redraw()

	## 끝 상태 확정 — result shape + settle tilt(well_rolled면 0=똑바른 수평 원통).
	func finalize_roll(result_state: int, settle_tilt: float) -> void:
		_result = result_state
		_round = 1.0
		_tilt = clampf(settle_tilt, -1.0, 1.0)
		if _painterly:
			# 진행 sprite 전부 숨기고 result variant 1개만 표시.
			for tr in _stage_sprites:
				if is_instance_valid(tr):
					(tr as TextureRect).modulate.a = 0.0
			for k in _result_sprites:
				var rt: TextureRect = _result_sprites[k]
				if is_instance_valid(rt):
					rt.modulate.a = 1.0 if int(k) == result_state else 0.0
			_apply_tilt_transform()
		queue_redraw()

	func _draw() -> void:
		# painterly가 있으면 sprite layer가 시각을 담당 → procedural draw 생략(중복 방지).
		if _painterly:
			return
		var w: float = _box.x
		var h: float = _box.y
		# ── 1. 김발 mat — 화면과 평행한 수평 직사각 (oblique 0). bamboo strip = 가로 line들.
		# fold 진행에 따라 near edge(하단)가 위로 접혀 올라가므로 mat의 "아직 안 접힌" 부분만 남는다.
		var mat_top: float = 0.0
		var mat_bot: float = h
		# near edge(하단)가 roll 진행만큼 위로 접힘 → mat 보이는 하단 경계가 위로 올라온다.
		var fold_y: float = lerpf(mat_bot, mat_top + h * 0.30, _round)
		_draw_mat(0.0, mat_top, w, fold_y)
		# ── 2. 말리는 김밥 — bottom→top fold. roundness가 낮으면 평평 layer(김+밥+가로 strip),
		# 높으면 위쪽에 수평 cylinder(log)가 형성된다. axis = 가로 고정.
		if _result != RESULT_NONE or _round >= 0.999:
			_draw_finished_log(w, h)
		elif _round < 0.42:
			_draw_flat_setup(w, h, _round)
		else:
			_draw_rolling(w, h, _round)

	# 수평 김발 — bamboo 가로결 (mat이 비스듬하지 않게 화면과 평행한 직사각).
	func _draw_mat(x0: float, y0: float, w: float, y1: float) -> void:
		if y1 <= y0:
			return
		draw_rect(Rect2(x0, y0, w, y1 - y0), MAT_BAMBOO)
		# 가로 bamboo strip line (top-down 결 — 세로결이면 oblique처럼 보임 방지, 가로 유지).
		var lines: int = 12
		var step: float = (y1 - y0) / float(lines)
		var yy: float = y0
		while yy < y1:
			draw_line(Vector2(x0 + 8.0, yy), Vector2(x0 + w - 8.0, yy), MAT_BAMBOO_LO, 3.0)
			yy += step
		# 접힌 near edge highlight (mat이 위로 말려 올라간 fold line).
		draw_line(Vector2(x0 + 6.0, y1), Vector2(x0 + w - 6.0, y1), Color(0.95, 0.84, 0.55, 0.9), 6.0, true)

	# 평평 setup — 김(직사각) 위 밥(얇게) 위 가로 평행 strip 4줄. near edge가 살짝 들림(tilt).
	func _draw_flat_setup(w: float, h: float, r: float) -> void:
		var pad: float = 60.0
		var sw_x0: float = pad
		var sw_x1: float = w - pad
		# 김이 fold 진행만큼 아래(near)에서 위로 말려 올라가므로 보이는 김 하단이 올라온다.
		var sw_top: float = h * 0.16
		var sw_bot: float = lerpf(h * 0.92, h * 0.50, r)
		# 김 (dark 직사각).
		draw_rect(Rect2(sw_x0, sw_top, sw_x1 - sw_x0, sw_bot - sw_top), SEAWEED)
		# 밥 (김 안 얇게 균등, far edge=위 김 노출 = seal).
		var ri_x0: float = sw_x0 + 36.0
		var ri_x1: float = sw_x1 - 36.0
		var ri_top: float = sw_top + (sw_bot - sw_top) * 0.22
		var ri_bot: float = sw_bot - 14.0
		draw_rect(Rect2(ri_x0, ri_top, ri_x1 - ri_x0, ri_bot - ri_top), RICE)
		# 가로 평행 strip 4줄 (밥 lower-middle, 가로 band = roll axis와 평행).
		var band_top: float = lerpf(ri_top, ri_bot, 0.42)
		var bar_h: float = (ri_bot - band_top) / 5.2
		for i in range(4):
			var by: float = band_top + float(i) * bar_h * 1.05
			draw_rect(Rect2(ri_x0 + 20.0, by, (ri_x1 - ri_x0) - 40.0, bar_h * 0.82), FILL_COLS[i])

	# 말리는 중 — 위쪽에 형성되는 수평 log(원통) + 아직 안 말린 평평 김+밥이 아래에 남음.
	# log는 화면 X축에 평행한 capsule (axis 가로 고정, rotation 0). 단면 노출 0.
	func _draw_rolling(w: float, h: float, r: float) -> void:
		var pad: float = 60.0
		# 아직 안 말린 평평 부분(아래) — 점점 줄어든다.
		var flat_top: float = lerpf(h * 0.40, h * 0.66, r)
		var flat_bot: float = h * 0.80
		if flat_bot > flat_top:
			draw_rect(Rect2(pad + 24.0, flat_top, w - 2.0 * (pad + 24.0), flat_bot - flat_top), SEAWEED)
			draw_rect(Rect2(pad + 56.0, flat_top + 10.0, w - 2.0 * (pad + 56.0), (flat_bot - flat_top) - 20.0), RICE)
		# 위쪽 수평 log — 말릴수록 두꺼워진다. capsule, 가로축 고정.
		var log_cy: float = lerpf(h * 0.42, h * 0.40, r)
		var log_w: float = w - 2.0 * pad
		var log_h: float = lerpf(h * 0.22, h * 0.40, r)
		# tilt = near edge 좌우 비대칭 → log를 살짝 위/아래로 기울임(단 본체는 수평 capsule).
		var tilt_dy: float = _tilt * h * 0.10
		_draw_log_capsule(Vector2(w * 0.5, log_cy), log_w, log_h, tilt_dy)

	# 완성 수평 원통 — 둥근 tight log(success) / 느슨(loose) / 갈라짐(tight burst).
	func _draw_finished_log(w: float, h: float) -> void:
		var pad: float = 60.0
		var log_cy: float = h * 0.46
		var log_w: float = w - 2.0 * pad
		var log_h: float = h * 0.46
		var tilt_dy: float = _tilt * h * 0.12   # crooked면 한쪽이 더 올라온 채 (수평 capsule + 기운 near edge).
		match _result:
			RESULT_LOOSE:
				log_h *= 0.88                     # 느슨 = 덜 단단(약간 납작).
			RESULT_TIGHT:
				log_h *= 1.06                     # 강압 = rice 삐져나옴(약간 부풀음).
		_draw_log_capsule(Vector2(w * 0.5, log_cy), log_w, log_h, tilt_dy, _result)

	# 수평 capsule log — 화면 X축에 평행(axis 가로 고정). 김 dark 외피 + 위쪽 sheen. end-cap 0.
	# result != NONE이면 상태별 디테일(loose=틈 / tight=rice 삐짐).
	func _draw_log_capsule(center: Vector2, lw: float, lh: float, tilt_dy: float, result: int = RESULT_NONE) -> void:
		var r: float = lh * 0.5
		var cx: float = center.x
		var cy: float = center.y
		# 정하향 soft contact shadow (top-down 통일).
		_capsule(Vector2(cx, cy + r * 0.5 + 12.0), lw, lh * 0.92, Color(0, 0, 0, 0.16), tilt_dy * 0.5)
		# 김 외피 (dark). tilt_dy = near edge 좌우 높이차(crooked) — capsule을 살짝 기운 평행사변형 느낌이
		# 아니라, 좌우 끝 y를 다르게 줘 "한쪽이 더 말려 올라간" 비대칭만 표현(본체 axis는 수평).
		_capsule(Vector2(cx, cy + 4.0), lw, lh, SEAWEED_LO, tilt_dy)
		_capsule(Vector2(cx, cy), lw, lh - 8.0, SEAWEED, tilt_dy)
		# 위쪽 절반 sheen (volumetric 원기둥감 — 단면 아님, 길이 방향 가로).
		_capsule(Vector2(cx, cy - r * 0.30), lw - 50.0, lh * 0.40, Color(0.30, 0.36, 0.24, 0.55), tilt_dy)
		# sesame-oil 가로 highlight 라인 (길이 방향).
		draw_line(Vector2(cx - lw * 0.5 + r, cy - r * 0.46),
				Vector2(cx + lw * 0.5 - r, cy - r * 0.46 + tilt_dy * 0.4),
				Color(0.52, 0.58, 0.44, 0.45), 5.0, true)
		# 상태 디테일.
		if result == RESULT_LOOSE:
			# 느슨 — 외피에 살짝 벌어진 틈(연한 밥색).
			draw_line(Vector2(cx - lw * 0.28, cy + r * 0.30), Vector2(cx + lw * 0.10, cy + r * 0.34),
					Color(0.90, 0.86, 0.74, 0.6), 6.0, true)
		elif result == RESULT_TIGHT:
			# 강압 — rice가 외피 밖으로 삐져나온 작은 흰 덩이.
			draw_circle(Vector2(cx + lw * 0.30, cy + r * 0.10), 14.0, Color(0.96, 0.93, 0.82, 0.9))
			draw_circle(Vector2(cx - lw * 0.34, cy - r * 0.04), 11.0, Color(0.96, 0.93, 0.82, 0.85))

	# (0,0) 중심 수평 capsule. tilt_dy = 우측 끝을 좌측보다 tilt_dy만큼 올림(좌우 비대칭만, 본체 수평).
	func _capsule(center: Vector2, cw: float, ch: float, col: Color, tilt_dy: float = 0.0) -> void:
		var r: float = ch * 0.5
		var cx: float = center.x
		var cyl: float = center.y - tilt_dy * 0.5    # 좌측 끝 y
		var cyr: float = center.y + tilt_dy * 0.5    # 우측 끝 y
		# 가운데 본체 — 좌우 끝 y가 다르면 살짝 기운 띠(quad)로 그려 비대칭 표현. 본체 길이축은 가로.
		var x_l: float = cx - cw * 0.5 + r
		var x_r: float = cx + cw * 0.5 - r
		draw_colored_polygon(PackedVector2Array([
			Vector2(x_l, cyl - r), Vector2(x_r, cyr - r),
			Vector2(x_r, cyr + r), Vector2(x_l, cyl + r)]), col)
		# 양끝 둥근 반원 (위에서 본 둥근 외피 — end-cap 단면 아님).
		draw_circle(Vector2(x_l, cyl), r, col)
		draw_circle(Vector2(x_r, cyr), r, col)


# =====================================================================================
# Two-finger UI draw nodes — 원형 target + ghost finger marker + 위 화살표 + balance meter.
# =====================================================================================

## 좌/우 손가락 터치 target — 원형 target + ghost finger marker + 위 화살표 + push progress ring.
class _TouchTargetDraw extends Control:
	var center: Vector2 = Vector2.ZERO
	var radius: float = 64.0
	var touched: bool = false
	var finger_pos: Vector2 = Vector2.ZERO
	var progress: float = 0.0
	const COL_RING := Color(0.96, 0.62, 0.18, 0.95)     # 따뜻한 주황 (target)
	const COL_FILL := Color(0.98, 0.85, 0.55, 0.30)
	const COL_GHOST := Color(0.20, 0.14, 0.10, 0.55)    # ghost finger

	func _ready() -> void:
		queue_redraw()

	func _draw() -> void:
		# 원형 target (점선 느낌 = 흰 테두리 + 주황 ring).
		draw_circle(center, radius + 4.0, Color(1, 1, 1, 0.55))
		draw_circle(center, radius, COL_FILL)
		draw_arc(center, radius, 0.0, TAU, 48, COL_RING, 7.0, true)
		# push progress ring (진행만큼 위쪽으로 차오름).
		if progress > 0.0:
			draw_arc(center, radius - 2.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 48,
					Color(0.35, 0.62, 0.30, 0.95), 9.0, true)
		# 위 화살표 (각 side, "위로 밀어").
		var ax: float = center.x
		var ay0: float = center.y - radius - 18.0
		var ay1: float = center.y - radius - 96.0
		draw_line(Vector2(ax, ay0), Vector2(ax, ay1), Color(1, 1, 1, 0.85), 12.0, true)
		draw_line(Vector2(ax, ay0), Vector2(ax, ay1), COL_RING, 7.0, true)
		var tip := Vector2(ax, ay1)
		draw_colored_polygon(PackedVector2Array([
			tip + Vector2(0, -6), tip + Vector2(-24, 26), tip + Vector2(24, 26)]),
			Color(1, 1, 1, 0.9))
		draw_colored_polygon(PackedVector2Array([
			tip + Vector2(0, 2), tip + Vector2(-17, 24), tip + Vector2(17, 24)]),
			COL_RING)
		# ghost finger / hand marker — 두 손가락이 위로 미는 모습 (눌렸으면 실제 위치).
		var hand_c: Vector2 = finger_pos if touched else center
		draw_circle(hand_c, 30.0, COL_GHOST)
		draw_circle(hand_c, 30.0 if not touched else 34.0,
				Color(0.98, 0.80, 0.62, 0.45 if not touched else 0.85))
		draw_arc(hand_c, 30.0, 0.0, TAU, 32, Color(1, 1, 1, 0.7), 4.0, true)


## 좌·우 balance meter — 두 막대의 길이가 균등하면 초록(균형), 차이 크면 빨강(비뚤).
class _BalanceMeterDraw extends Control:
	var bar_rect: Rect2 = Rect2(0, 0, 640, 44)
	var left_p: float = 0.0
	var right_p: float = 0.0

	func _ready() -> void:
		queue_redraw()

	func _draw() -> void:
		# 중앙 분할 — 좌 막대는 중앙→왼쪽, 우 막대는 중앙→오른쪽으로 차오름.
		var cx: float = bar_rect.position.x + bar_rect.size.x * 0.5
		var top: float = bar_rect.position.y
		var h: float = bar_rect.size.y
		var half_w: float = bar_rect.size.x * 0.5
		# 배경 track.
		draw_rect(bar_rect, Color(0, 0, 0, 0.12), true)
		# balance 색 — 좌우 차가 작으면 초록, 크면 빨강.
		var diff: float = absf(left_p - right_p)
		var bad: float = clampf(diff / 0.4, 0.0, 1.0)
		var col := Color(0.35, 0.70, 0.34).lerp(Color(0.86, 0.28, 0.20), bad)
		# 좌 막대 (중앙에서 왼쪽으로).
		var lw: float = clampf(left_p, 0.0, 1.0) * half_w
		draw_rect(Rect2(cx - lw, top, lw, h), col, true)
		# 우 막대 (중앙에서 오른쪽으로).
		var rw: float = clampf(right_p, 0.0, 1.0) * half_w
		draw_rect(Rect2(cx, top, rw, h), col, true)
		# 중앙선.
		draw_line(Vector2(cx, top - 6), Vector2(cx, top + h + 6), Color(1, 1, 1, 0.85), 4.0)
		# 라벨 L / R.
		var font := ThemeDB.fallback_font
		draw_string(font, Vector2(bar_rect.position.x - 4, top + h + 36), "L",
				HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color(0.30, 0.20, 0.12))
		draw_string(font, Vector2(bar_rect.position.x + bar_rect.size.x - 18, top + h + 36), "R",
				HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color(0.30, 0.20, 0.12))
