## FlavorTagBadge — small pill that shows a flavor with icon + label.
##
## Two modes:
##   like    -> normal colored pill ("Likes: Spicy")
##   dislike -> grey pill with X overlay ("Avoids: Bitter")
##
## Placeholder visuals (single-letter icon). When art-director ships flavor icon
## sprites, swap the Label _icon child for a TextureRect.
class_name FlavorTagBadge
extends Panel

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")

var _flavor_id: String = ""
var _mode: String = "like"   # "like" / "dislike"


func setup(flavor_id: String, mode: String = "like") -> void:
	_flavor_id = flavor_id
	_mode = mode
	_rebuild()


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	custom_minimum_size = Vector2(150, 56)
	var info: Dictionary = MenuDB.get_flavor(_flavor_id)
	var col: Color = info.get("color", Color(0.7, 0.7, 0.7))
	var sb := StyleBoxFlat.new()
	if _mode == "dislike":
		sb.bg_color = Color(0.55, 0.55, 0.58)
		sb.border_color = Color(0.85, 0.25, 0.20)
		sb.set_border_width_all(3)
	else:
		sb.bg_color = col
		sb.border_color = col.darkened(0.25)
		sb.set_border_width_all(2)
	sb.set_corner_radius_all(26)
	sb.shadow_size = 3
	sb.shadow_color = Color(0, 0, 0, 0.18)
	add_theme_stylebox_override("panel", sb)

	# circular icon chip (left)
	var chip := Panel.new()
	chip.position = Vector2(6, 6)
	chip.size = Vector2(44, 44)
	var csb := StyleBoxFlat.new()
	csb.bg_color = Color(1, 1, 1, 0.85)
	csb.set_corner_radius_all(22)
	chip.add_theme_stylebox_override("panel", csb)
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(chip)
	var icon_lbl := Label.new()
	icon_lbl.text = String(info.get("icon", "?"))
	icon_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_lbl.add_theme_font_size_override("font_size", 22)
	icon_lbl.add_theme_color_override("font_color", col.darkened(0.35))
	chip.add_child(icon_lbl)

	# label
	var name_lbl := Label.new()
	name_lbl.text = String(info.get("name_en", _flavor_id))
	name_lbl.position = Vector2(56, 0)
	name_lbl.size = Vector2(custom_minimum_size.x - 60, 56)
	name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 22)
	name_lbl.add_theme_color_override("font_color", Color.WHITE if _mode == "like" else Color(0.95, 0.92, 0.88))
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(name_lbl)

	# X overlay for dislike
	if _mode == "dislike":
		var x := Label.new()
		x.text = "X"
		x.position = Vector2(custom_minimum_size.x - 30, -4)
		x.size = Vector2(28, 28)
		x.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		x.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		x.add_theme_font_size_override("font_size", 28)
		x.add_theme_color_override("font_color", Color(0.92, 0.25, 0.20))
		x.add_theme_color_override("font_outline_color", Color.WHITE)
		x.add_theme_constant_override("outline_size", 3)
		x.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(x)
