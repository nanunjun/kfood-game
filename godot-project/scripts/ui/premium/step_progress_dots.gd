## CP-41 StepProgressDots — ●○○○ progress indicator for M-step display.
##
## Visual-only. Renders `total` circles in a row; first `current` are gold-filled,
## the rest are dim outlines. Optional caption "Step 2 of 4" below.
##
## Usage:
##   var d := StepProgressDots.new()
##   parent.add_child(d)
##   d.size = Vector2(260, 44)
##   d.setup(4, 2)                 # 4 total, current = 2
##   d.set_step(3)                 # update on advance
class_name StepProgressDots
extends Control

const DOT_RADIUS := 11.0
const DOT_SPACING := 30.0

const GOLD_FILLED := Color(0.95, 0.70, 0.18)
const GOLD_RING := Color(0.92, 0.78, 0.50, 0.55)

var _total: int = 4
var _current: int = 1
var _dots_layer: Control = null
var _caption: Label = null


func setup(total: int, current: int) -> void:
	_total = maxi(1, total)
	_current = clampi(current, 0, _total)
	_rebuild()


func set_step(current: int) -> void:
	var prev := _current
	_current = clampi(current, 0, _total)
	if _current != prev:
		_rebuild_dots_only()


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	_dots_layer = Control.new()
	_dots_layer.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_dots_layer.offset_bottom = 24.0
	_dots_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dots_layer)
	_rebuild_dots_only()
	# Caption
	_caption = Label.new()
	_caption.text = "Step %d of %d" % [maxi(1, _current), _total]
	_caption.position = Vector2(0, 24)
	_caption.size = Vector2(size.x, 22)
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.add_theme_font_size_override("font_size", 16)
	_caption.add_theme_color_override("font_color", Color(0.42, 0.28, 0.10))
	_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_caption)


func _rebuild_dots_only() -> void:
	if _dots_layer == null:
		return
	for c in _dots_layer.get_children():
		c.queue_free()
	var total_w: float = float(_total - 1) * DOT_SPACING
	var start_x: float = (size.x - total_w) * 0.5
	for i in range(_total):
		var dot := Polygon2D.new()
		var pts := PackedVector2Array()
		for j in range(20):
			var ang: float = float(j) / 20.0 * TAU
			pts.append(Vector2(cos(ang), sin(ang)) * DOT_RADIUS)
		dot.polygon = pts
		dot.position = Vector2(start_x + float(i) * DOT_SPACING, 12)
		var filled: bool = i < _current
		dot.color = GOLD_FILLED if filled else Color(0.88, 0.82, 0.70, 0.45)
		_dots_layer.add_child(dot)
		# ring for unfilled
		if not filled:
			var ring := Line2D.new()
			var ring_pts := PackedVector2Array()
			for j in range(21):
				var ang: float = float(j) / 20.0 * TAU
				ring_pts.append(Vector2(cos(ang), sin(ang)) * DOT_RADIUS)
			ring.points = ring_pts
			ring.width = 2.0
			ring.default_color = GOLD_RING
			dot.add_child(ring)
		# bounce on the "current" dot (just-completed indicator)
		if i == _current - 1 and _current > 0:
			dot.scale = Vector2(0.3, 0.3)
			var tw := dot.create_tween()
			tw.tween_property(dot, "scale", Vector2(1.3, 1.3), 0.18)\
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw.tween_property(dot, "scale", Vector2.ONE, 0.14)\
				.set_trans(Tween.TRANS_SINE)
	if _caption != null:
		_caption.text = "Step %d of %d" % [maxi(1, _current), _total]
