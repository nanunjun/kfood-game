## FeedbackBus — 5중 히트 피드백 통합 (autoload, M0).
##
## rhythm-prototype-spec §3. 파티클·글로우 flash·점수 팝업·SFX·햅틱을 한 호출로 동시 트리거.
## 자체 CanvasLayer를 만들어 그 위에 풀링된 노드로 그린다. 60fps 위해 queue_free 금지(풀 재사용).
## autoload 이름과 class_name 충돌 금지.
extends Node

const POOL := 12

var _layer: CanvasLayer
var _popups: Array[Label] = []
var _flashes: Array[ColorRect] = []
var _pi: int = 0
var _fi: int = 0

const COL_PERFECT := Color(0.95, 0.72, 0.02)
const COL_GOOD := Color(0.98, 0.85, 0.55)
const COL_MISS := Color(0.60, 0.58, 0.55)


func _ready() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 50
	add_child(_layer)
	for i in range(POOL):
		var l := Label.new()
		l.visible = false
		l.z_index = 2
		l.add_theme_font_size_override("font_size", 56)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_layer.add_child(l)
		_popups.append(l)
		var f := ColorRect.new()
		f.visible = false
		f.size = Vector2(160, 160)
		f.color = Color(1, 1, 1, 0)
		f.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_layer.add_child(f)
		_flashes.append(f)


## 5중 자극 동시 트리거. result = RhythmJudge.{PERFECT,GOOD,MISS}, pos = 화면 좌표.
func hit(result: int, pos: Vector2) -> void:
	_popup(result, pos)
	_flash(result, pos)
	_sfx(result)
	_haptic(result)
	# 파티클은 프로토타입에선 flash+popup으로 대체(엔진 실행 시 GPUParticles2D 풀로 확장).


func _popup(result: int, pos: Vector2) -> void:
	var l := _popups[_pi]
	_pi = (_pi + 1) % POOL
	match result:
		RhythmJudge.PERFECT: l.text = "PERFECT"; l.add_theme_font_size_override("font_size", 64); l.add_theme_color_override("font_color", COL_PERFECT)
		RhythmJudge.GOOD: l.text = "GOOD"; l.add_theme_font_size_override("font_size", 48); l.add_theme_color_override("font_color", COL_GOOD)
		_: l.text = "MISS"; l.add_theme_font_size_override("font_size", 40); l.add_theme_color_override("font_color", COL_MISS)
	l.reset_size()
	l.position = pos - l.size * 0.5
	l.scale = Vector2(0.75, 0.75)
	l.modulate.a = 1.0
	l.visible = true
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(l, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "position:y", l.position.y - 56.0, 0.6)
	tw.chain().tween_property(l, "modulate:a", 0.0, 0.2).set_delay(0.4)
	tw.chain().tween_callback(func() -> void: l.visible = false)


func _flash(result: int, pos: Vector2) -> void:
	if result == RhythmJudge.MISS:
		return
	var f := _flashes[_fi]
	_fi = (_fi + 1) % POOL
	var c: Color = COL_PERFECT if result == RhythmJudge.PERFECT else COL_GOOD
	var gi: float = get_node("/root/Tuning").glow_intensity
	c.a = (0.9 if result == RhythmJudge.PERFECT else 0.5) * gi
	f.color = c
	f.position = pos - f.size * 0.5
	f.visible = true
	var tw := create_tween()
	tw.tween_property(f, "color:a", 0.0, 0.18 if result == RhythmJudge.PERFECT else 0.2)
	tw.tween_callback(func() -> void: f.visible = false)


func _sfx(result: int) -> void:
	# AudioManager(기존 autoload) 슬롯 재사용. 없으면 무음.
	var am := get_node_or_null("/root/AudioManager")
	if am == null or not am.has_method("play"):
		return
	match result:
		RhythmJudge.PERFECT: am.play(&"judge_perfect")
		RhythmJudge.GOOD: am.play(&"judge_good")
		_: am.play(&"judge_miss")


func _haptic(result: int) -> void:
	var hm := get_node_or_null("/root/HapticManager")
	if hm == null:
		return
	match result:
		RhythmJudge.PERFECT: hm.play(hm.PERFECT)
		RhythmJudge.GOOD: hm.play(hm.GOOD)
		_: hm.play(hm.MISS)
