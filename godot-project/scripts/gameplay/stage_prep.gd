## StagePrep — Stage 2A 재료 준비 (rhythm tap + Knife).
##
## ADR-005 §2A. 칼이 BPM에 맞춰 도마로 내려올 때(비트) 탭 → perfect ±80ms.
## 절차적 칼 연출: 날+손잡이 형태 + 찹 모션(약간의 회전) + 탭 시 도마 흔들림·칩 파티클·
## 재료 점진 절단(whole→cut alpha 단계). prep_taps 회 판정 후 finished(accuracy_prep).
## (전용 칼 스프라이트는 art 후속 — 현재 폴리곤 placeholder)
class_name StagePrep
extends Control

signal finished(accuracy_prep: float)

const KNIFE_UP := 820.0      # 칼 rig 정점 Y
const KNIFE_DOWN := 1040.0   # 칼 rig 접촉 Y (tip = +40 → ~1080)
const ING_CENTER := Vector2(540, 1095)

var _bpm: int = 100
var _target_taps: int = 4
var _whole_path: String = ""
var _cut_path: String = ""
var _perfect_ms: float = 90.0
var _good_ms: float = 200.0

var _beat_period: float = 0.6
var _elapsed: float = 0.0
var _running: bool = false
var _judged: int = 0
var _accuracy_sum: float = 0.0
var _last_beat: int = -1

const FOOD_BASE := Vector2(340, 940)

var _knife: Node2D
var _board: Panel
var _ingredient: TextureRect
var _cut: TextureRect
var _feedback: Label


func setup(bpm: int, taps: int, whole_path: String, cut_path: String, difficulty: int = 3) -> void:
	_bpm = max(1, bpm)
	_target_taps = max(1, taps)
	_whole_path = whole_path
	_cut_path = cut_path
	var d := float(clampi(difficulty, 1, 5) - 1) / 4.0  # 0(쉬움)~1(어려움)
	_perfect_ms = lerpf(120.0, 55.0, d)   # 쉬울수록 넓게
	_good_ms = lerpf(280.0, 130.0, d)


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_beat_period = 60.0 / float(_bpm)

	var lbl := _make_label("Prep — tap when the knife hits! (x%d)" % _target_taps, 360)
	lbl.add_theme_font_size_override("font_size", 44)

	# 도마(양식화 나무 보드) — 재료 뒤에 항상 표시 (premium 컷아웃 재료엔 도마가 없으므로 별도로 그림).
	_board = _make_board()
	# 재료: whole(아래) + cut(위, 점진 reveal)
	_ingredient = _make_food(_whole_path)
	_cut = _make_food(_cut_path)
	_cut.modulate = Color(1, 1, 1, 0)

	_knife = _build_knife()
	_knife.position = Vector2(540, KNIFE_UP)
	add_child(_knife)

	_feedback = _make_label("", 1250)
	_feedback.add_theme_font_size_override("font_size", 72)

	var hint := _make_label("Tap anywhere", 1640)
	hint.add_theme_font_size_override("font_size", 36)
	hint.modulate = Color(1, 1, 1, 0.6)

	_running = true


func _build_knife() -> Node2D:
	var rig := Node2D.new()
	var blade := Polygon2D.new()
	blade.polygon = PackedVector2Array([
		Vector2(-16, -90), Vector2(16, -90), Vector2(16, 10), Vector2(0, 44), Vector2(-16, 10)])
	blade.color = Color(0.80, 0.83, 0.88)
	rig.add_child(blade)
	var edge := Polygon2D.new()  # 날 끝 밝은 하이라이트
	edge.polygon = PackedVector2Array([Vector2(-16, 2), Vector2(16, 2), Vector2(0, 44)])
	edge.color = Color(0.95, 0.96, 1.0)
	rig.add_child(edge)
	var handle := Polygon2D.new()
	handle.polygon = PackedVector2Array([
		Vector2(-13, -150), Vector2(13, -150), Vector2(12, -86), Vector2(-12, -86)])
	handle.color = Color(0.32, 0.20, 0.13)
	rig.add_child(handle)
	return rig


func _process(delta: float) -> void:
	if not _running:
		return
	_elapsed += delta
	var phase: float = fmod(_elapsed, _beat_period) / _beat_period  # 0 = contact
	var down: float = sin(PI * phase)  # 0(접촉)..1(정점)
	_knife.position.y = KNIFE_DOWN - (KNIFE_DOWN - KNIFE_UP) * down
	_knife.rotation = deg_to_rad(lerpf(-5.0, 4.0, down))  # 접촉 시 곧게, 들 때 살짝 젖힘
	var cur_beat := int(_elapsed / _beat_period)
	if cur_beat != _last_beat:
		_last_beat = cur_beat
		AudioManager.play(&"metro_strong" if cur_beat % 4 == 0 else &"metro_weak")


func _unhandled_input(event: InputEvent) -> void:
	if not _running:
		return
	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed):
		_judge_tap()


func _judge_tap() -> void:
	var nearest: float = round(_elapsed / _beat_period) * _beat_period
	var delta_ms: float = abs(_elapsed - nearest) * 1000.0
	var acc := 0.0
	var txt := "MISS"
	if delta_ms <= _perfect_ms:
		acc = 1.0
		txt = "PERFECT!"
	elif delta_ms <= _good_ms:
		acc = 0.6
		txt = "GOOD"
	_accuracy_sum += acc
	_judged += 1
	AudioManager.play(&"act_chop")
	AudioManager.play(&"judge_perfect" if acc >= 1.0 else (&"judge_good" if acc > 0.0 else &"judge_miss"))
	_feedback.text = "%s  (%d/%d)" % [txt, _judged, _target_taps]
	_chop_fx(acc > 0.0)
	# 점진 절단: judged/target 만큼 cut 노출
	var reveal: float = clampf(float(_judged) / float(_target_taps), 0.0, 1.0)
	var tw := create_tween()
	tw.tween_property(_cut, "modulate:a", reveal, 0.15)
	tw.parallel().tween_property(_ingredient, "modulate:a", 1.0 - reveal, 0.15)
	if _judged >= _target_taps:
		_finish()


func _chop_fx(hit: bool) -> void:
	# 재료 흔들림(칼질 충격)
	for node in [_ingredient, _cut]:
		var sh := create_tween()
		sh.tween_property(node, "position", FOOD_BASE + Vector2(0, 6), 0.05)
		sh.tween_property(node, "position", FOOD_BASE, 0.1).set_trans(Tween.TRANS_SINE)
	# 칼 번쩍(스케일 팝)
	var kp := create_tween()
	kp.tween_property(_knife, "scale", Vector2(1.12, 0.92), 0.04)
	kp.tween_property(_knife, "scale", Vector2.ONE, 0.10)
	if hit:
		_spawn_chunks()


func _spawn_chunks() -> void:
	for i in range(3):
		var c := Polygon2D.new()
		var s := randf_range(6.0, 12.0)
		c.polygon = PackedVector2Array([Vector2(-s, 0), Vector2(0, -s), Vector2(s, 0), Vector2(0, s)])
		c.color = Color(0.95, 0.82, 0.45)
		c.position = ING_CENTER + Vector2(randf_range(-40, 40), randf_range(-10, 10))
		add_child(c)
		var vel := Vector2(randf_range(-120, 120), randf_range(-160, -60))
		var tw := create_tween()
		tw.tween_property(c, "position", c.position + vel + Vector2(0, 120), 0.45).set_trans(Tween.TRANS_QUAD)
		tw.parallel().tween_property(c, "modulate:a", 0.0, 0.45)
		tw.tween_callback(c.queue_free)


func _finish() -> void:
	_running = false
	var accuracy: float = _accuracy_sum / float(_target_taps)
	var tw := create_tween()
	tw.tween_property(_cut, "modulate:a", 1.0, 0.2)
	tw.parallel().tween_property(_ingredient, "modulate:a", 0.0, 0.2)
	tw.parallel().tween_property(_cut, "scale", Vector2(1.08, 1.08), 0.2).set_trans(Tween.TRANS_BACK)
	tw.tween_interval(0.4)
	tw.tween_callback(func() -> void: finished.emit(accuracy))


## 양식화 나무 도마 (Panel + StyleBoxFlat). 재료 뒤(먼저 add_child)라 z-order 아래.
func _make_board() -> Panel:
	var p := Panel.new()
	p.position = Vector2(220, 985)
	p.size = Vector2(640, 320)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.792, 0.612, 0.392)        # 따뜻한 나무색
	sb.set_corner_radius_all(40)
	sb.set_border_width_all(6)
	sb.border_color = Color(0.40, 0.27, 0.16)        # 어두운 테두리
	sb.shadow_color = Color(0, 0, 0, 0.18)
	sb.shadow_size = 10
	sb.shadow_offset = Vector2(0, 8)
	p.add_theme_stylebox_override("panel", sb)
	add_child(p)
	# 결 한 줄(은은한 나뭇결 악센트)
	var grain := ColorRect.new()
	grain.color = Color(0.40, 0.27, 0.16, 0.18)
	grain.position = Vector2(40, 150)
	grain.size = Vector2(560, 3)
	grain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(grain)
	return p


func _make_food(path: String) -> TextureRect:
	var t := TextureRect.new()
	t.texture = _load_tex(path)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.position = Vector2(340, 940)
	t.size = Vector2(400, 300)
	t.pivot_offset = Vector2(200, 150)
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(t)
	return t


func _make_label(txt: String, y: float) -> Label:
	var l := Label.new()
	l.text = txt
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.position = Vector2(0, y)
	l.size = Vector2(1080, 80)
	l.add_theme_font_size_override("font_size", 40)
	l.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l


func _load_tex(path: String) -> Texture2D:
	if path != "" and ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null
