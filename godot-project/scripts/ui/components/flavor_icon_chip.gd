## FlavorIconChip — compact emoji/icon-only flavor chip (Critical #6 noise reduction).
##
## Unlike FlavorTagBadge (which renders icon + full word "Spicy"), this is an
## icon-ONLY circular chip: colored disc + the flavor's short icon glyph. Used in
## guest_select cards where 10 simultaneous elements created visual noise — the
## full flavor word text is dropped, leaving only the recognizable colored icon.
##
## like    -> solid colored disc (the guest's favorite flavor)
## dislike -> muted grey disc + small red X corner (the guest avoids it)
##
## Size default 52x52. setup() flavor contract matches FlavorTagBadge.
class_name FlavorIconChip
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
	if custom_minimum_size == Vector2.ZERO:
		custom_minimum_size = Vector2(52, 52)
	var sz: Vector2 = custom_minimum_size if custom_minimum_size != Vector2.ZERO else size
	var info: Dictionary = MenuDB.get_flavor(_flavor_id)
	var col: Color = info.get("color", Color(0.7, 0.7, 0.7))
	var sb := StyleBoxFlat.new()
	if _mode == "dislike":
		sb.bg_color = col.lerp(Color(0.55, 0.55, 0.58), 0.62)
		sb.border_color = Color(0.85, 0.25, 0.20)
		sb.set_border_width_all(3)
	else:
		sb.bg_color = col
		sb.border_color = Color(1, 1, 1, 0.92)
		sb.set_border_width_all(3)
	sb.set_corner_radius_all(int(sz.x / 2.0))
	sb.shadow_size = 4
	sb.shadow_color = Color(0, 0, 0, 0.22)
	sb.shadow_offset = Vector2(0, 2)
	add_theme_stylebox_override("panel", sb)

	# centered icon glyph
	var icon_lbl := Label.new()
	icon_lbl.text = String(info.get("icon", "?"))
	icon_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_lbl.add_theme_font_size_override("font_size", int(sz.x * 0.42))
	icon_lbl.add_theme_color_override("font_color", Color.WHITE if _mode == "like" else Color(0.92, 0.90, 0.88))
	icon_lbl.add_theme_color_override("font_outline_color", col.darkened(0.45) if _mode == "like" else Color(0.30, 0.30, 0.32))
	icon_lbl.add_theme_constant_override("outline_size", 2)
	icon_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(icon_lbl)

	# dislike: small red X badge top-right
	if _mode == "dislike":
		var x := Label.new()
		x.text = "x"
		x.position = Vector2(sz.x - 20.0, -8.0)
		x.size = Vector2(24, 24)
		x.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		x.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		x.add_theme_font_size_override("font_size", 24)
		x.add_theme_color_override("font_color", Color(0.92, 0.22, 0.18))
		x.add_theme_color_override("font_outline_color", Color.WHITE)
		x.add_theme_constant_override("outline_size", 3)
		x.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(x)
