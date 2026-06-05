## CP-38 GoldRibbonBanner — "NEW RECORD" / "TODAY'S PICK" gold ribbon w/ 24 sparkle slide-in.
##
## Visual-only. NinePatch-style gold panel + sparkle burst on entry + slide-in from left.
## 540×100 default; configurable via size before setup().
##
## Usage:
##   var b := GoldRibbonBanner.new()
##   parent.add_child(b)
##   b.position = Vector2(...); b.size = Vector2(540, 100)
##   b.setup("TODAY'S PICK", "Tteokbokki — 92% match")
##   b.play_reveal(0.0)
class_name GoldRibbonBanner
extends Control

const SparkleScript := preload("res://scripts/ui/premium/sparkle_particle.gd")

const GOLD_LIGHT := Color(1.0, 0.92, 0.45)
const GOLD_DEEP := Color(0.94, 0.66, 0.12)
const GOLD_BORDER := Color(0.50, 0.30, 0.05)

var _title: String = "NEW RECORD"
var _sub: String = ""
var _title_lbl: Label = null
var _sub_lbl: Label = null
var _bg: Panel = null


func setup(title: String, sub: String = "") -> void:
	_title = title
	_sub = sub
	_rebuild()


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	# Gold gradient background
	_bg = Panel.new()
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = GOLD_DEEP
	sb.set_corner_radius_all(20)
	sb.set_border_width_all(5)
	sb.border_color = GOLD_BORDER
	sb.shadow_size = 14
	sb.shadow_color = Color(0, 0, 0, 0.32)
	sb.shadow_offset = Vector2(0, 8)
	_bg.add_theme_stylebox_override("panel", sb)
	add_child(_bg)
	# top-bright gradient highlight
	var grad := Gradient.new()
	grad.set_color(0, GOLD_LIGHT)
	grad.set_color(1, Color(GOLD_LIGHT.r, GOLD_LIGHT.g, GOLD_LIGHT.b, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_LINEAR
	gt.fill_from = Vector2(0.5, 0.0)
	gt.fill_to = Vector2(0.5, 1.0)
	gt.width = 256
	gt.height = 256
	var hl := TextureRect.new()
	hl.texture = gt
	hl.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hl.offset_top = 5.0
	hl.offset_left = 6.0
	hl.offset_right = -6.0
	hl.offset_bottom = size.y * 0.55
	hl.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hl.stretch_mode = TextureRect.STRETCH_SCALE
	hl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bg.add_child(hl)
	# Title label
	_title_lbl = Label.new()
	_title_lbl.text = _title
	_title_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER if _sub == "" else VERTICAL_ALIGNMENT_TOP
	_title_lbl.offset_top = 10
	_title_lbl.add_theme_font_size_override("font_size", 40)
	_title_lbl.add_theme_color_override("font_color", Color(0.22, 0.10, 0.02))
	_title_lbl.add_theme_color_override("font_outline_color", Color(1.0, 0.95, 0.70, 0.55))
	_title_lbl.add_theme_constant_override("outline_size", 3)
	_title_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_title_lbl)
	if _sub != "":
		_sub_lbl = Label.new()
		_sub_lbl.text = _sub
		_sub_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
		_sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_sub_lbl.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		_sub_lbl.offset_bottom = -8
		_sub_lbl.add_theme_font_size_override("font_size", 22)
		_sub_lbl.add_theme_color_override("font_color", Color(0.30, 0.15, 0.04))
		_sub_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_sub_lbl)


## Slide-in from off-screen left, then sparkle burst at top-right.
func play_reveal(delay: float = 0.0) -> void:
	pivot_offset = size * 0.5
	var target_x: float = position.x
	position.x -= 200.0
	modulate.a = 0.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, 0.35).set_delay(delay)
	tw.tween_property(self, "position:x", target_x, 0.45)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(delay)
	# Sparkle burst at center after slide-in
	var fire := create_tween()
	fire.tween_interval(delay + 0.40)
	fire.tween_callback(_fire_sparkles)
	# Subtle continuous wiggle to keep eye attention
	var wig := create_tween().set_loops()
	wig.tween_interval(delay + 0.8)
	wig.tween_property(self, "rotation", deg_to_rad(0.6), 0.7).set_trans(Tween.TRANS_SINE)
	wig.tween_property(self, "rotation", deg_to_rad(-0.6), 1.4).set_trans(Tween.TRANS_SINE)
	wig.tween_property(self, "rotation", 0.0, 0.7).set_trans(Tween.TRANS_SINE)


func _fire_sparkles() -> void:
	if not is_inside_tree():
		return
	SparkleScript.play_burst(self, size * 0.5, 24, 240.0, Color(1.0, 0.95, 0.55), 0.85)
