## CP-40 NowCookingBanner — premium top banner for all 8 cooking modules.
##
## Visual-only. Replaces the flat "Cooking · Tteokbokki" pill in cooking_module_runner.gd
## with a richer layout:
##   [dish thumb 64x64]  [Dish name EN  +  (KR)]  [step indicator dots]
##
## Drop-shadow + gold border + warm cream bg. Sized 1000×88 by default.
##
## Usage:
##   var banner := NowCookingBanner.new()
##   parent.add_child(banner)
##   banner.position = Vector2(40, 188); banner.size = Vector2(1000, 88)
##   banner.setup("Tteokbokki", "떡볶이", "res://art/sprites/food/t1_003.png", 2, 4)
class_name NowCookingBanner
extends Control

const StepDotsScript := preload("res://scripts/ui/premium/step_progress_dots.gd")
const DropShadowScript := preload("res://scripts/ui/premium/drop_shadow_panel.gd")

const BG_CREAM := Color(1.0, 0.97, 0.88)
const GOLD := Color(0.95, 0.70, 0.18)

var _dish_en: String = "Cooking"
var _dish_kr: String = ""
var _thumb_path: String = ""
var _step: int = 1
var _total: int = 1
var _dots: Control = null


func setup(dish_en: String, dish_kr: String, thumb_path: String, step: int, total: int) -> void:
	_dish_en = dish_en
	_dish_kr = dish_kr
	_thumb_path = thumb_path
	_step = step
	_total = total
	_rebuild()


## Allows runner to update step indicator without rebuilding everything.
func update_step(step: int) -> void:
	_step = step
	if _dots != null and _dots.has_method("set_step"):
		_dots.set_step(step)


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	# Premium card background
	var bg := Panel.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	DropShadowScript.apply_to(bg, BG_CREAM, 30, 12, GOLD, 4)
	add_child(bg)
	# Dish thumbnail (left)
	var thumb_frame := Panel.new()
	thumb_frame.position = Vector2(14, 14)
	thumb_frame.size = Vector2(60, 60)
	var tsb := StyleBoxFlat.new()
	tsb.bg_color = Color(0.97, 0.88, 0.70)
	tsb.set_corner_radius_all(30)
	tsb.set_border_width_all(3)
	tsb.border_color = GOLD
	thumb_frame.add_theme_stylebox_override("panel", tsb)
	thumb_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(thumb_frame)
	if _thumb_path != "" and ResourceLoader.exists(_thumb_path):
		var tex: Texture2D = load(_thumb_path) as Texture2D
		if tex != null:
			var t := TextureRect.new()
			# expand_mode를 texture 할당 전에 — 1024px 최소크기 박힘 방지(거대 thumb가 화면 덮는 버그).
			t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			t.custom_minimum_size = Vector2.ZERO
			t.clip_contents = true
			t.texture = tex
			t.position = Vector2(4, 4)
			t.size = Vector2(52, 52)
			t.mouse_filter = Control.MOUSE_FILTER_IGNORE
			thumb_frame.add_child(t)
	# "NOW COOKING" label (tiny caption)
	var caption := Label.new()
	caption.text = "NOW COOKING"
	caption.position = Vector2(86, 8)
	caption.size = Vector2(360, 22)
	caption.add_theme_font_size_override("font_size", 16)
	caption.add_theme_color_override("font_color", Color(0.62, 0.42, 0.08))
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(caption)
	# Dish name (big)
	var name_lbl := Label.new()
	var name_text: String = _dish_en
	if _dish_kr != "":
		name_text = "%s · %s" % [_dish_en, _dish_kr]
	name_lbl.text = name_text
	name_lbl.position = Vector2(86, 30)
	name_lbl.size = Vector2(600, 52)
	name_lbl.add_theme_font_size_override("font_size", 32)
	name_lbl.add_theme_color_override("font_color", Color(0.20, 0.12, 0.04))
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(name_lbl)
	# Step progress dots (right)
	_dots = StepDotsScript.new()
	_dots.position = Vector2(size.x - 280.0, 24)
	_dots.size = Vector2(260, 44)
	add_child(_dots)
	if _dots.has_method("setup"):
		_dots.setup(_total, _step)
