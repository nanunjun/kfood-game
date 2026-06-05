## MoodBadge — circular 70x70 mood indicator overlay (corner of guest avatar).
##
## Shows the deterministic mood-of-the-day from MoodSystem. Color + icon + label
## come from MoodSystem helpers.
class_name MoodBadge
extends Panel

var _mood: String = "easy"


func setup(mood: String) -> void:
	_mood = mood
	_rebuild()


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	custom_minimum_size = Vector2(80, 80)
	var mood_sys := get_node_or_null("/root/MoodSystem")
	var col: Color = mood_sys.color(_mood) if mood_sys else Color(0.7, 0.7, 0.7)
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(40)
	sb.set_border_width_all(4)
	sb.border_color = Color.WHITE
	sb.shadow_size = 5
	sb.shadow_color = Color(0, 0, 0, 0.32)
	add_theme_stylebox_override("panel", sb)

	# icon (top)
	var icon := Label.new()
	icon.text = mood_sys.icon(_mood) if mood_sys else "?"
	icon.position = Vector2(0, 4)
	icon.size = Vector2(80, 38)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon.add_theme_font_size_override("font_size", 26)
	icon.add_theme_color_override("font_color", Color.WHITE)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(icon)

	# label (bottom)
	var lbl := Label.new()
	lbl.text = mood_sys.label(_mood) if mood_sys else _mood
	lbl.position = Vector2(0, 42)
	lbl.size = Vector2(80, 32)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.4))
	lbl.add_theme_constant_override("outline_size", 2)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(lbl)
