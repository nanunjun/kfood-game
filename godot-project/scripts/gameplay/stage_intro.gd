## StageIntro — 요리 소개 화면 (라운드 시작 전).
##
## 외국 플레이어가 한식을 모를 수 있으므로, 만들 음식을 큰 이미지로 확실히 보여주고
## 이름(영어/한국어) + 한 줄 tagline + 설명을 제시한 뒤 "Start Cooking"으로 진행.
## UI는 절차적 생성 (Godot Editor 없이 검증). finished emit 시 라운드 본편 시작.
##
## 참조: DishInfoRegistry(설명), ArtRegistry(스프라이트)
class_name StageIntro
extends Control

signal finished

const DARK := Color(0.17, 0.11, 0.08)
const GOLD := Color(0.85, 0.6, 0.1)

var _food_id: StringName = &""
var _name_en: String = ""
var _name_ko: String = ""


func setup(food_id: StringName, name_en: String, name_ko: String) -> void:
	_food_id = food_id
	_name_en = name_en
	_name_ko = name_ko


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	# 상단 안내 라벨
	var hint := Label.new()
	hint.text = "Today's dish"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.position = Vector2(0, 120)
	hint.size = Vector2(1080, 50)
	hint.add_theme_font_size_override("font_size", 32)
	hint.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08, 0.65))
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hint)

	# 영어 이름 (큰)
	var title := Label.new()
	title.text = _name_en
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 178)
	title.size = Vector2(1080, 90)
	title.add_theme_font_size_override("font_size", 68)
	title.add_theme_color_override("font_color", DARK)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title)

	# 한국어 이름 (부)
	var subko := Label.new()
	subko.text = _name_ko
	subko.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subko.position = Vector2(0, 272)
	subko.size = Vector2(1080, 56)
	subko.add_theme_font_size_override("font_size", 38)
	subko.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08, 0.55))
	subko.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(subko)

	# 큰 음식 이미지
	var sprite := TextureRect.new()
	var food_path := ArtRegistry.food(_food_id)
	if food_path != "" and ResourceLoader.exists(food_path):
		sprite.texture = load(food_path)
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.position = Vector2(170, 380)
	sprite.size = Vector2(740, 740)
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sprite)
	# 부드러운 페이드+팝 인 (과하지 않게)
	sprite.modulate.a = 0.0
	sprite.scale = Vector2(0.94, 0.94)
	sprite.pivot_offset = sprite.size * 0.5
	var tw := create_tween().set_parallel(true)
	tw.tween_property(sprite, "modulate:a", 1.0, 0.35)
	tw.tween_property(sprite, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# 설명 패널 (반투명 카드)
	var panel := ColorRect.new()
	panel.color = Color(1, 1, 1, 0.55)
	panel.position = Vector2(90, 1170)
	panel.size = Vector2(900, 360)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	# tagline (한 줄)
	var tag := Label.new()
	tag.text = DishInfoRegistry.tagline(_food_id)
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.position = Vector2(130, 1200)
	tag.size = Vector2(820, 50)
	tag.add_theme_font_size_override("font_size", 32)
	tag.add_theme_color_override("font_color", Color(0.78, 0.34, 0.16))  # 테라코타
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tag)

	# 설명 (자동 줄바꿈)
	var desc := Label.new()
	desc.text = DishInfoRegistry.description(_food_id)
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.position = Vector2(140, 1268)
	desc.size = Vector2(800, 250)
	desc.add_theme_font_size_override("font_size", 34)
	desc.add_theme_color_override("font_color", DARK)
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(desc)

	# Start Cooking 버튼
	var start := Button.new()
	start.text = "Start Cooking  ▶"
	start.position = Vector2(290, 1610)
	start.size = Vector2(500, 110)
	start.add_theme_font_size_override("font_size", 42)
	start.pressed.connect(_on_start)
	add_child(start)


func _on_start() -> void:
	AudioManager.play(&"ui_select")
	finished.emit()
