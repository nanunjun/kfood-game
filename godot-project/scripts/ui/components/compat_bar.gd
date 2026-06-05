## CompatBar — horizontal % progress bar with gradient color from RewardCalc.
##
## Shows current compat (0~100). Use setup(compat) to draw.
class_name CompatBar
extends Control

var _compat: int = 50


func setup(compat: int) -> void:
	_compat = clampi(compat, 0, 100)
	_rebuild()


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	custom_minimum_size = Vector2(420, 36)
	# track (bg)
	var bg := Panel.new()
	bg.size = custom_minimum_size
	var bsb := StyleBoxFlat.new()
	bsb.bg_color = Color(0.92, 0.88, 0.80)
	bsb.set_corner_radius_all(18)
	bsb.set_border_width_all(2)
	bsb.border_color = Color(0.65, 0.55, 0.42)
	bg.add_theme_stylebox_override("panel", bsb)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	# fill
	var reward_calc := get_node_or_null("/root/RewardCalc")
	var col: Color = reward_calc.compat_color(_compat) if reward_calc else Color(0.7, 0.7, 0.7)
	var fill := Panel.new()
	fill.position = Vector2(4, 4)
	fill.size = Vector2(maxf(28.0, (custom_minimum_size.x - 8.0) * float(_compat) / 100.0), 28)
	var fsb := StyleBoxFlat.new()
	fsb.bg_color = col
	fsb.set_corner_radius_all(14)
	fill.add_theme_stylebox_override("panel", fsb)
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fill)
	# label
	var lbl := Label.new()
	lbl.text = "%d%%" % _compat
	lbl.size = custom_minimum_size
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.add_theme_color_override("font_color", Color(0.15, 0.10, 0.06))
	lbl.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.7))
	lbl.add_theme_constant_override("outline_size", 3)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(lbl)
