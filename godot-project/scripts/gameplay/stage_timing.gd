## StageTiming — Stage 2C 조리 (재료 투입 → 타이밍 → 완성). 도마 미사용.
##
## ① 추상 재료 칩이 조리도구(냄비/팬)에 차례로 투입되며 쌓임 →
## ② 좌↔우 왕복 타이밍 바 탭(난도별) → ③ 칩 → 완성 요리 cross-fade.
## 조리 표면 = 조리도구 1개(도마 아님). prep_cut(도마 baked) 미사용.
## 참조: docs/systems/cooking-mechanics.md §4, balance-config §3
class_name StageTiming
extends Control

signal finished(accuracy_timing: float)

const BAR_X := 60.0
const BAR_W := 960.0
const BAR_Y := 1180.0
const BAR_H := 130.0
const DARK := Color(0.17, 0.11, 0.08)
const NO_COOK := ["roll", "mix", "toss"]
const PILE_CENTER := Vector2(540, 835)
const CHIP_COLORS := [
	Color(0.92, 0.36, 0.28), Color(0.45, 0.72, 0.34), Color(0.96, 0.78, 0.30),
	Color(0.95, 0.62, 0.28), Color(0.85, 0.85, 0.78),
]

var _food_path: String = ""
var _tool_path: String = ""
var _method: String = ""
var _difficulty: int = 3
var _ingredient_count: int = 3
var _perfect_frac: float = 0.10
var _good_frac: float = 0.20
var _sweep: float = 1.4
var _elapsed: float = 0.0
var _frac: float = 0.0
var _running: bool = false
var _heat: bool = true

var _indicator: ColorRect
var _bar_nodes: Array = []
var _feedback: Label
var _chips: Array = []
var _done: TextureRect


func setup(cook_time_sec: float, food_sprite_path: String, tool_sprite_path: String = "", difficulty: int = 3, method_id: String = "", raw_sprite_path: String = "", ingredient_count: int = 3) -> void:
	_food_path = food_sprite_path
	_tool_path = tool_sprite_path
	_method = method_id
	_difficulty = clampi(difficulty, 1, 5)
	_ingredient_count = clampi(ingredient_count, 1, 4)
	var d := float(_difficulty - 1) / 4.0
	_sweep = lerpf(2.4, 0.70, d)            # 난이도 스프레드 확대(쉬움 느림 ~ 어려움 빠름)
	_perfect_frac = lerpf(0.14, 0.035, d)   # 쉬움 넓음 ~ 어려움 매우 좁음
	_good_frac = _perfect_frac * 1.8


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_heat = not NO_COOK.has(_method)
	var title := _label("Cooking…", 380, 52)

	# 조리 표면 = 조리도구(냄비/팬/그릴/김발/그릇). 도마 미사용.
	var surface := TextureRect.new()
	surface.texture = _load_tex(_tool_path if _tool_path != "" else "res://art/sprites/tool/boil.png")
	surface.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	surface.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	surface.position = Vector2(300, 640)
	surface.size = Vector2(480, 420)
	surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(surface)

	# 완성 요리(처음 숨김 → 마지막 cross-fade)
	_done = TextureRect.new()
	_done.texture = _load_tex(_food_path)
	_done.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_done.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_done.position = Vector2(370, 660)
	_done.size = Vector2(340, 300)
	_done.modulate = Color(1, 1, 1, 0)
	_done.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_done)

	if _heat:
		var steam := TextureRect.new()
		steam.texture = _load_tex("res://art/vfx/steam_swirl.png")
		steam.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		steam.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		steam.position = Vector2(410, 520)
		steam.size = Vector2(260, 240)
		steam.modulate = Color(1, 1, 1, 0.0)
		steam.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(steam)
		var st := create_tween().set_loops()
		st.tween_property(steam, "modulate:a", 0.7, 1.1).set_trans(Tween.TRANS_SINE)
		st.tween_property(steam, "modulate:a", 0.3, 1.1).set_trans(Tween.TRANS_SINE)

	_build_bar()
	_set_bar_visible(false)
	_feedback = _label("", 1380, 80)
	var hint := _label("", 1560, 36)
	hint.modulate = Color(1, 1, 1, 0.65)

	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_run_assembly(title, hint)


## ① 재료(추상 칩) 차례로 투입
func _run_assembly(title: Label, hint: Label) -> void:
	title.text = "Adding ingredients…"
	for i in range(_ingredient_count):
		_drop_chip(i)
		await get_tree().create_timer(0.34).timeout
	await get_tree().create_timer(0.2).timeout
	title.text = "Catch the right moment!"
	hint.text = "Tap when the marker is centered!"
	_set_bar_visible(true)
	_running = true


func _drop_chip(idx: int) -> void:
	var chip := Polygon2D.new()
	var s := 34.0
	chip.polygon = PackedVector2Array([Vector2(-s, 0), Vector2(0, -s), Vector2(s, 0), Vector2(0, s)])
	chip.color = CHIP_COLORS[idx % CHIP_COLORS.size()]
	var landing := PILE_CENTER + Vector2(randf_range(-70, 70), randf_range(-22, 22))
	chip.position = Vector2(landing.x, 430.0)
	add_child(chip)
	_chips.append(chip)
	var fall := create_tween()
	fall.tween_property(chip, "position", landing, 0.30).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	fall.tween_callback(func() -> void: AudioManager.play(&"act_stir" if _heat else &"ui_select"))
	fall.tween_property(chip, "scale", Vector2(1.3, 0.7), 0.05)
	fall.tween_property(chip, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_SINE)


func _build_bar() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.30, 0.30, 0.30)
	bg.position = Vector2(BAR_X, BAR_Y)
	bg.size = Vector2(BAR_W, BAR_H)
	add_child(bg)
	_bar_nodes.append(bg)
	var good := ColorRect.new()
	good.color = Color(0.85, 0.70, 0.30)
	var good_w := BAR_W * (_perfect_frac + _good_frac)
	good.size = Vector2(good_w, BAR_H)
	good.position = Vector2(BAR_X + (BAR_W - good_w) * 0.5, BAR_Y)
	add_child(good)
	_bar_nodes.append(good)
	var perfect := ColorRect.new()
	perfect.color = Color(1.0, 0.85, 0.1)
	var pf_w := BAR_W * _perfect_frac
	perfect.size = Vector2(pf_w, BAR_H)
	perfect.position = Vector2(BAR_X + (BAR_W - pf_w) * 0.5, BAR_Y)
	add_child(perfect)
	_bar_nodes.append(perfect)
	_indicator = ColorRect.new()
	_indicator.color = Color(0.2, 0.2, 0.2)
	_indicator.size = Vector2(8, BAR_H + 24)
	_indicator.position = Vector2(BAR_X, BAR_Y - 12)
	add_child(_indicator)
	_bar_nodes.append(_indicator)
	for n in _bar_nodes:
		(n as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE


func _set_bar_visible(v: bool) -> void:
	for n in _bar_nodes:
		(n as CanvasItem).visible = v


func _process(delta: float) -> void:
	if not _running:
		return
	_elapsed += delta
	var phase: float = fmod(_elapsed / _sweep, 2.0)
	_frac = phase if phase <= 1.0 else 2.0 - phase
	_indicator.position.x = BAR_X + BAR_W * _frac - 4.0
	if _elapsed >= _sweep * 8.0:
		_judge()


func _unhandled_input(event: InputEvent) -> void:
	if not _running:
		return
	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed):
		_judge()


func _judge() -> void:
	_running = false
	var dist: float = abs(_frac - 0.5)
	var acc := 0.2
	var txt := "MISS"
	if dist <= _perfect_frac * 0.5:
		acc = 1.0
		txt = "PERFECT!"
	elif dist <= (_perfect_frac + _good_frac) * 0.5:
		acc = 0.6
		txt = "GOOD"
	_feedback.text = txt
	AudioManager.play(&"judge_perfect" if acc >= 1.0 else (&"judge_good" if acc > 0.4 else &"judge_miss"))
	# ③ 칩 → 완성 요리 cross-fade
	var dn := create_tween()
	for chip in _chips:
		dn.parallel().tween_property(chip, "modulate:a", 0.0, 0.35)
	dn.parallel().tween_property(_done, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)
	dn.tween_callback(func() -> void: finished.emit(acc))


func _label(txt: String, y: float, fsize: int) -> Label:
	var l := Label.new()
	l.text = txt
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.position = Vector2(40, y)
	l.size = Vector2(1000, 110)
	l.add_theme_font_size_override("font_size", fsize)
	l.add_theme_color_override("font_color", DARK)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l


func _load_tex(path: String) -> Texture2D:
	if path != "" and ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null
