## ResultScreen — 라운드 결과 (세로 구도: 이름 → 요리 → 시식 리액션 → 별점·점수).
##
## 리액션(엄마 표정)과 별점·점수를 인접 배치(리액션 = 점수 반영). 평온한 얼굴 → 별점 표정 변화 + idle 호흡.
## 버튼: Retry / (순차 모드) Next / Menu.
class_name ResultScreen
extends Control

signal retry_pressed
signal next_pressed

const DARK := Color(0.17, 0.11, 0.08)

var _stars: int = 1
var _score: float = 0.0
var _breakdown: Dictionary = {}
var _food_name: String = ""
var _food_path: String = ""
var _has_next: bool = false
var _new_best: bool = false


func setup(stars: int, score: float, breakdown: Dictionary, food_name: String, food_path: String, has_next: bool = false, new_best: bool = false) -> void:
	_stars = stars
	_score = score
	_breakdown = breakdown
	_food_name = food_name
	_food_path = food_path
	_has_next = has_next
	_new_best = new_best


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	# 상단: 음식 이름 + Served
	_label(_food_name, 90, 64)
	var sub := _label("Served!", 195, 34)
	sub.modulate = Color(0.17, 0.11, 0.08, 0.65)

	# 중앙: 완성 요리 (부드러운 등장 + 안착 + idle 호흡)
	var dish := TextureRect.new()
	dish.texture = _load_tex(_food_path)
	dish.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dish.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	dish.position = Vector2(310, 290)
	dish.size = Vector2(460, 460)
	dish.pivot_offset = Vector2(230, 230)
	dish.scale = Vector2(0.94, 0.94)
	dish.modulate = Color(1, 1, 1, 0)
	add_child(dish)
	var dt := create_tween()
	dt.tween_property(dish, "modulate:a", 1.0, 0.35).set_trans(Tween.TRANS_SINE)
	dt.parallel().tween_property(dish, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_SINE)
	var dbob := create_tween().set_loops()
	dbob.tween_property(dish, "position:y", 298.0, 1.6).set_trans(Tween.TRANS_SINE).set_delay(0.6)
	dbob.tween_property(dish, "position:y", 290.0, 1.6).set_trans(Tween.TRANS_SINE)

	# 시식 리액션 (요리 아래) — 평온한 얼굴 → 별점 표정 변화 + idle 호흡
	var react := TextureRect.new()
	react.texture = _load_tex(ArtRegistry.reaction(1))
	react.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	react.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	react.position = Vector2(400, 758)
	react.size = Vector2(280, 280)
	react.pivot_offset = Vector2(140, 140)
	react.modulate = Color(1, 1, 1, 0)
	add_child(react)
	var rt := create_tween()
	rt.tween_property(react, "modulate:a", 1.0, 0.35).set_trans(Tween.TRANS_SINE)
	rt.tween_interval(0.6)
	rt.tween_callback(func() -> void:
		react.texture = _load_tex(ArtRegistry.reaction(_stars))
		AudioManager.play(&"act_done")
	)
	rt.tween_property(react, "scale", Vector2(1.14, 1.14), 0.18).set_trans(Tween.TRANS_SINE)
	rt.tween_property(react, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	rt.tween_callback(func() -> void: AudioManager.play(&"sting_finish"))
	var rbob := create_tween().set_loops()
	rbob.tween_property(react, "position:y", 750.0, 1.3).set_trans(Tween.TRANS_SINE).set_delay(1.5)
	rbob.tween_property(react, "position:y", 758.0, 1.3).set_trans(Tween.TRANS_SINE)

	# 리액션 아래: (신기록) → 별점 → 점수 → 분해 (겹치지 않게 간격)
	if _new_best:
		var nb := _label("★ New Best!", 1058, 34)
		nb.add_theme_color_override("font_color", Color(0.95, 0.55, 0.1))
	var star_lbl := _label("★".repeat(_stars) + "☆".repeat(3 - _stars), 1122, 92)
	star_lbl.add_theme_color_override("font_color", Color(1.0, 0.78, 0.1))
	_label("Score %d%%" % int(round(_score * 100.0)), 1240, 46)
	var bd := "Prep %d%%   Method %d%%   Timing %d%%" % [
		int(round(_breakdown.get("prep", 0.0) * 100.0)),
		int(round(_breakdown.get("method", 0.0) * 100.0)),
		int(round(_breakdown.get("timing", 0.0) * 100.0)),
	]
	_label(bd, 1330, 32).modulate = Color(0.17, 0.11, 0.08, 0.7)

	_build_buttons()


func _build_buttons() -> void:
	var labels: Array = ["Retry"]
	var acts: Array = ["retry"]
	if _has_next:
		labels.append("Next ▶"); acts.append("next")
	labels.append("Menu"); acts.append("menu")
	var n := labels.size()
	var gap := 24.0
	var w := (1080.0 - 100.0 - gap * (n - 1)) / float(n)
	for i in range(n):
		var b := Button.new()
		b.text = String(labels[i])
		b.position = Vector2(50.0 + i * (w + gap), 1560)
		b.size = Vector2(w, 120)
		b.add_theme_font_size_override("font_size", 40)
		var a: String = String(acts[i])
		b.pressed.connect(func() -> void:
			AudioManager.play(&"ui_select")
			match a:
				"retry": retry_pressed.emit()
				"next": next_pressed.emit()
				"menu": get_tree().change_scene_to_file("res://scenes/food_select.tscn")
		)
		add_child(b)


func _label(txt: String, y: float, fsize: int) -> Label:
	var l := Label.new()
	l.text = txt
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.position = Vector2(0, y)
	l.size = Vector2(1080, float(fsize) + 24.0)
	l.add_theme_font_size_override("font_size", fsize)
	l.add_theme_color_override("font_color", DARK)
	add_child(l)
	return l


func _load_tex(path: String) -> Texture2D:
	if path != "" and ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null
