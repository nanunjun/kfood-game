## CP-37 HeroNumberBounce — large number entrance anim with gold gradient + halo.
##
## Visual-only. A Control containing:
##   - Polygon2D halo (radial gold glow behind)
##   - Label with big font-size, GOLD font_color + dark outline (mimics gradient)
##   - Optional "%" or "/100" suffix label
##
## Usage:
##   var hnb := HeroNumberBounce.new()
##   container.add_child(hnb)
##   hnb.size = Vector2(540, 140)
##   hnb.setup(93, "%", 120)            # 80pt → 120pt fontsize, "%" suffix
##   hnb.play_bounce(0.0)               # scale 0.5 → 1.2 → 1.0 + tween count-up
class_name HeroNumberBounce
extends Control

const GOLD_TOP := Color(1.0, 0.92, 0.40)
const GOLD_BOT := Color(0.95, 0.62, 0.10)
const GOLD_OUTLINE := Color(0.42, 0.20, 0.02)

var _value: int = 0
var _suffix: String = ""
var _font_size: int = 110
var _label: Label = null
var _suffix_label: Label = null
var _halo: TextureRect = null


func setup(value: int, suffix: String = "", font_size: int = 110) -> void:
	_value = value
	_suffix = suffix
	_font_size = font_size
	_rebuild()


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	# Gold radial halo behind
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 0.88, 0.30, 0.55))
	grad.set_color(1, Color(1.0, 0.88, 0.30, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(1.0, 0.5)
	gt.width = 256
	gt.height = 256
	_halo = TextureRect.new()
	_halo.texture = gt
	_halo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_halo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_halo.stretch_mode = TextureRect.STRETCH_SCALE
	_halo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_halo)
	# Main number
	_label = Label.new()
	_label.text = "%d" % _value
	_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", _font_size)
	_label.add_theme_color_override("font_color", GOLD_TOP)
	_label.add_theme_color_override("font_outline_color", GOLD_OUTLINE)
	_label.add_theme_constant_override("outline_size", 8)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)
	# Optional suffix (smaller, right side)
	if _suffix != "":
		_suffix_label = Label.new()
		_suffix_label.text = _suffix
		_suffix_label.anchor_left = 1.0
		_suffix_label.anchor_top = 0.0
		_suffix_label.anchor_right = 1.0
		_suffix_label.anchor_bottom = 1.0
		_suffix_label.offset_left = -100
		_suffix_label.offset_right = 0
		_suffix_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_suffix_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_suffix_label.add_theme_font_size_override("font_size", int(_font_size * 0.45))
		_suffix_label.add_theme_color_override("font_color", GOLD_TOP)
		_suffix_label.add_theme_color_override("font_outline_color", GOLD_OUTLINE)
		_suffix_label.add_theme_constant_override("outline_size", 6)
		_suffix_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_suffix_label)


## Entrance: scale 0.5 → 1.2 (overshoot) → 1.0, halo fade-in, optional count-up.
## count_up_from: if >= 0, tween the number label from this value to `_value` over 0.8s.
func play_bounce(delay: float = 0.0, count_up_from: int = -1) -> void:
	pivot_offset = size * 0.5
	scale = Vector2(0.5, 0.5)
	modulate.a = 0.0
	if _halo != null:
		_halo.modulate.a = 0.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, 0.25).set_delay(delay)
	tw.tween_property(self, "scale", Vector2(1.2, 1.2), 0.32)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(delay)
	tw.tween_property(self, "scale", Vector2.ONE, 0.20)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(delay + 0.32)
	if _halo != null:
		tw.tween_property(_halo, "modulate:a", 1.0, 0.30).set_delay(delay + 0.10)
	if count_up_from >= 0 and is_instance_valid(_label):
		var start_v: int = count_up_from
		var end_v: int = _value
		var tw2 := create_tween()
		tw2.tween_interval(delay + 0.32)
		tw2.tween_method(func(v: int) -> void:
			if is_instance_valid(_label):
				_label.text = "%d" % v,
			start_v, end_v, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func set_value_instant(v: int) -> void:
	_value = v
	if is_instance_valid(_label):
		_label.text = "%d" % v
