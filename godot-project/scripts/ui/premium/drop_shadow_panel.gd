## CP-34 DropShadowPanel — premium card panel with 12~16px Y soft shadow + inner highlight.
##
## Visual-only. Drop-in replacement for `Panel` whenever a "card" feel is wanted.
## Use `setup(bg_color, corner_radius, shadow_y)` or call `apply_to(panel)` static.
class_name DropShadowPanel
extends Panel

const DEFAULT_BG := Color(1.0, 0.99, 0.96)
const DEFAULT_CORNER := 28
const DEFAULT_SHADOW_Y := 14


func _ready() -> void:
	if get_theme_stylebox("panel") == null:
		setup(DEFAULT_BG, DEFAULT_CORNER, DEFAULT_SHADOW_Y)


func setup(bg: Color = DEFAULT_BG, corner: int = DEFAULT_CORNER, shadow_y: int = DEFAULT_SHADOW_Y,
		border_col: Color = Color(0, 0, 0, 0), border_w: int = 0) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(corner)
	sb.shadow_size = shadow_y
	sb.shadow_color = Color(0, 0, 0, 0.22)
	sb.shadow_offset = Vector2(0, shadow_y)
	if border_w > 0:
		sb.set_border_width_all(border_w)
		sb.border_color = border_col
	add_theme_stylebox_override("panel", sb)
	# Optional inner top highlight as a child
	_add_top_highlight()


func _add_top_highlight() -> void:
	# Strip any prior highlight so re-setup doesn't stack
	for c in get_children():
		if c.name == "PremiumTopHighlight":
			c.queue_free()
	var grad := Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 0.30))
	grad.set_color(1, Color(1, 1, 1, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_LINEAR
	gt.fill_from = Vector2(0.5, 0.0)
	gt.fill_to = Vector2(0.5, 1.0)
	gt.width = 256
	gt.height = 256
	var tr := TextureRect.new()
	tr.name = "PremiumTopHighlight"
	tr.texture = gt
	tr.set_anchors_preset(Control.PRESET_TOP_WIDE)
	tr.offset_top = 4.0
	tr.offset_left = 8.0
	tr.offset_right = -8.0
	tr.offset_bottom = 96.0
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tr)


## Apply premium drop-shadow stylebox to ANY existing Panel without subclassing.
static func apply_to(panel: Panel, bg: Color = DEFAULT_BG, corner: int = DEFAULT_CORNER,
		shadow_y: int = DEFAULT_SHADOW_Y, border_col: Color = Color(0, 0, 0, 0), border_w: int = 0) -> void:
	if panel == null:
		return
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(corner)
	sb.shadow_size = shadow_y
	sb.shadow_color = Color(0, 0, 0, 0.22)
	sb.shadow_offset = Vector2(0, shadow_y)
	if border_w > 0:
		sb.set_border_width_all(border_w)
		sb.border_color = border_col
	panel.add_theme_stylebox_override("panel", sb)
