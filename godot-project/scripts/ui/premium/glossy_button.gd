## CP-33 GlossyButton — premium CTA with inner highlight + gradient + 12px Y drop shadow.
##
## Visual-only enhancement. No gameplay logic — wraps a Button + overlay glow.
## Use anywhere a flat Button used to live for premium feel. Tints via `set_tint(Color)`.
##
## Layered nodes:
##   - Panel (gradient bg + shadow)
##   - TextureRect (subtle top inner highlight)
##   - Button (label + click target) — exposed via `button` for signal wiring
class_name GlossyButton
extends Control

## Optional small icon (TextureRect) on the LEFT of the label. Set via `set_icon(Texture2D)`.
var button: Button = null

var _bg: Panel = null
var _highlight: TextureRect = null
var _icon_rect: TextureRect = null
var _tint: Color = Color(0.93, 0.45, 0.25)  # persimmon default
var _label_text: String = "Cook"
var _font_size: int = 30
var _corner: int = 28


func _ready() -> void:
	custom_minimum_size = Vector2(maxf(180.0, size.x), maxf(72.0, size.y))
	_rebuild()


func setup(label: String, tint: Color, font_size: int = 30, corner: int = 28) -> void:
	_label_text = label
	_tint = tint
	_font_size = font_size
	_corner = corner
	if is_inside_tree():
		_rebuild()


func set_tint(tint: Color) -> void:
	_tint = tint
	if is_inside_tree():
		_rebuild()


func set_label(label: String) -> void:
	_label_text = label
	if is_instance_valid(button):
		button.text = label


func set_icon(tex: Texture2D) -> void:
	if is_instance_valid(_icon_rect):
		_icon_rect.texture = tex
		_icon_rect.visible = tex != null


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	# Drop-shadow bg panel (12px Y shadow)
	_bg = Panel.new()
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = _tint
	sb.set_corner_radius_all(_corner)
	sb.shadow_size = 12
	sb.shadow_color = Color(0, 0, 0, 0.32)
	sb.shadow_offset = Vector2(0, 12)
	_bg.add_theme_stylebox_override("panel", sb)
	add_child(_bg)

	# Inner top highlight (gradient overlay)
	var grad := Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 0.35))
	grad.set_color(1, Color(1, 1, 1, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_LINEAR
	gt.fill_from = Vector2(0.5, 0.0)
	gt.fill_to = Vector2(0.5, 1.0)
	gt.width = 256
	gt.height = 256
	_highlight = TextureRect.new()
	_highlight.texture = gt
	_highlight.set_anchors_preset(Control.PRESET_FULL_RECT)
	_highlight.offset_top = 4.0
	_highlight.offset_left = 6.0
	_highlight.offset_right = -6.0
	_highlight.offset_bottom = -size.y * 0.45
	_highlight.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_highlight.stretch_mode = TextureRect.STRETCH_SCALE
	_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bg.add_child(_highlight)

	# Optional icon
	_icon_rect = TextureRect.new()
	_icon_rect.position = Vector2(16, (size.y - 40.0) * 0.5)
	_icon_rect.size = Vector2(40, 40)
	_icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon_rect.visible = false
	_icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_icon_rect)

	# The clickable button
	button = Button.new()
	button.text = _label_text
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.flat = true
	button.add_theme_font_size_override("font_size", _font_size)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_color_hover", Color.WHITE)
	button.add_theme_color_override("font_color_pressed", Color(1, 1, 1, 0.9))
	# Tiny press scale via Tween
	button.pressed.connect(_on_pressed)
	add_child(button)


func _on_pressed() -> void:
	# Bounce-press feedback (visual only).
	pivot_offset = size * 0.5
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2(0.96, 0.96), 0.06).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "scale", Vector2.ONE, 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
