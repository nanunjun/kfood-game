## TouchGestureRecognizer — ADR-012 공통 입력 유틸 (action-first cooking).
##
## 8 module이 공유하는 gesture primitive. 추상 button/puck tap을 폐기하고 "실제 조리
## 동작"(drag/tilt)을 인식하기 위한 단일 진입점. 이 노드는 화면 위 투명 Control로 깔려
## InputEventScreenDrag / InputEventMouseMotion / button down·up을 추적한다.
##
## 제공 primitive:
##   - drag tracking (start / move / release + velocity + direction + distance)
##   - vertical drag (slice down-stroke / heat dial 위↕아래)
##   - tilt angle (season 통 기울임 — drag 벡터의 각도)
##   - continuous path sampling (stir circular 등 차후 module)
##
## scoring 무관 — 순수 입력 인식기. 각 module이 emit된 gesture quality를 §6.1 변환
## (action 품질 → output signal) 후 자체 `module_completed(score)` 로 내보낸다. 즉 이
## 유틸은 점수를 만들지 않고 "동작의 raw 품질 지표"만 제공한다.
##
## 사용 (slice 예):
##   var rec := TouchGestureRecognizer.new()
##   rec.set_anchors_preset(Control.PRESET_FULL_RECT)
##   add_child(rec)
##   rec.drag_started.connect(_on_drag_started)
##   rec.drag_updated.connect(_on_drag_updated)   # (pos, velocity)
##   rec.drag_released.connect(_on_drag_released) # (info: Dictionary)
class_name TouchGestureRecognizer
extends Control

## 드래그 한 획이 시작될 때 (press down + 최소 이동 전이라도 down 즉시).
signal drag_started(pos: Vector2)
## 드래그 진행 중 매 입력 이벤트마다. velocity = px/sec (smoothed).
signal drag_updated(pos: Vector2, velocity: Vector2)
## 드래그 한 획이 끝날 때 (release). info Dictionary:
##   start / end : Vector2
##   distance    : float (start→end 직선 거리)
##   path_len    : float (실제 이동한 누적 경로 길이)
##   duration_ms : float
##   avg_speed   : float (path_len / duration_s, px/sec)
##   direction   : Vector2 (정규화된 start→end 방향)
##   angle_deg   : float (direction 각도, 0=오른쪽, 90=아래)
##   straightness: float [0,1] (distance / path_len — 직선일수록 1)
signal drag_released(info: Dictionary)

## tilt 각도 변화 (season 통 기울임). angle_deg = 수직(아래) 기준 기울임 각, 0~90.
signal tilt_changed(angle_deg: float, hold_ms: float)

const _VEL_SMOOTH: float = 0.5          # velocity EMA 계수
const _MIN_SAMPLE_DT_MS: float = 8.0    # path sampling 최소 간격

var _dragging: bool = false
var _start_pos: Vector2 = Vector2.ZERO
var _last_pos: Vector2 = Vector2.ZERO
var _cur_pos: Vector2 = Vector2.ZERO
var _start_ms: float = 0.0
var _last_ms: float = 0.0
var _path_len: float = 0.0
var _velocity: Vector2 = Vector2.ZERO
var _path: PackedVector2Array = PackedVector2Array()


func _ready() -> void:
	# 입력을 받되 아래 art/puck가 가리지 않도록 PASS (자식 버튼이 있으면 그쪽 우선).
	mouse_filter = Control.MOUSE_FILTER_STOP


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_begin(event.position)
		else:
			_end(event.position)
		accept_event()
	elif event is InputEventScreenDrag:
		_move(event.position)
		accept_event()
	elif event is InputEventMouseButton:
		# 데스크톱/에디터 테스트 경로 — 마우스 좌클릭을 터치로 매핑.
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_begin(event.position)
			else:
				_end(event.position)
			accept_event()
	elif event is InputEventMouseMotion:
		if _dragging:
			_move(event.position)
			accept_event()


# --- lifecycle of one drag stroke ---

func _begin(pos: Vector2) -> void:
	_dragging = true
	_start_pos = pos
	_last_pos = pos
	_cur_pos = pos
	_start_ms = _now_ms()
	_last_ms = _start_ms
	_path_len = 0.0
	_velocity = Vector2.ZERO
	_path = PackedVector2Array([pos])
	drag_started.emit(pos)


func _move(pos: Vector2) -> void:
	if not _dragging:
		return
	var now := _now_ms()
	var dt_ms: float = maxf(now - _last_ms, 1.0)
	var delta: Vector2 = pos - _last_pos
	_path_len += delta.length()
	# velocity = px/sec, EMA smoothed
	var inst_vel: Vector2 = delta / (dt_ms / 1000.0)
	_velocity = _velocity.lerp(inst_vel, _VEL_SMOOTH)
	_cur_pos = pos
	# path sampling (각속도 적분 등 차후 stir module 용)
	if dt_ms >= _MIN_SAMPLE_DT_MS:
		_path.append(pos)
	_last_pos = pos
	_last_ms = now
	drag_updated.emit(pos, _velocity)
	# tilt: 수직(아래=+Y) 기준으로 start→cur 벡터가 얼마나 기울었는지.
	var v: Vector2 = pos - _start_pos
	if v.length() > 4.0:
		var ang: float = rad_to_deg(v.angle_to(Vector2(0, 1)))
		tilt_changed.emit(clampf(absf(ang), 0.0, 90.0), now - _start_ms)


func _end(pos: Vector2) -> void:
	if not _dragging:
		return
	_dragging = false
	_cur_pos = pos
	if pos != _last_pos:
		_path_len += (pos - _last_pos).length()
		_path.append(pos)
	var info := _build_info(pos)
	drag_released.emit(info)


func _build_info(end_pos: Vector2) -> Dictionary:
	var dur_ms: float = maxf(_now_ms() - _start_ms, 1.0)
	var v: Vector2 = end_pos - _start_pos
	var dist: float = v.length()
	var path_len: float = maxf(_path_len, 0.001)
	var dir: Vector2 = v.normalized() if dist > 0.001 else Vector2.ZERO
	return {
		"start": _start_pos,
		"end": end_pos,
		"distance": dist,
		"path_len": path_len,
		"duration_ms": dur_ms,
		"avg_speed": path_len / (dur_ms / 1000.0),
		"direction": dir,
		"angle_deg": rad_to_deg(dir.angle()) if dist > 0.001 else 0.0,
		"straightness": clampf(dist / path_len, 0.0, 1.0),
		"path": _path,
	}


# --- public query helpers (module들이 raw 상태 조회) ---

func is_dragging() -> bool:
	return _dragging


func current_pos() -> Vector2:
	return _cur_pos


func start_pos() -> Vector2:
	return _start_pos


func velocity() -> Vector2:
	return _velocity


## 현재까지 수직 이동량 (아래로 +). slice down-stroke / heat dial drag 용.
func vertical_travel() -> float:
	return _cur_pos.y - _start_pos.y


func _now_ms() -> float:
	return float(Time.get_ticks_msec())
