## CP-31 NewRecordBadge — gold ribbon "NEW RECORD" slide-in (400x80).
##
## Used by ResultScreenV2 right under the score header when SaveManager.check_record
## returned true for this round.
class_name NewRecordBadge
extends Panel

var _prev_score: int = 0
var _new_score: int = 0


func setup(new_score: int, prev_score: int = 0) -> void:
	_new_score = new_score
	_prev_score = prev_score
	_rebuild()


## Slide-in from the right + 1.06x pulse.
func play_reveal(delay: float = 0.0) -> void:
	modulate.a = 0.0
	var orig_x: float = position.x
	position.x += 120.0
	var tw := create_tween().set_parallel(true)
	tw.tween_interval(delay)
	tw.chain().tween_property(self, "modulate:a", 1.0, 0.30)
	tw.parallel().tween_property(self, "position:x", orig_x, 0.30).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# pulse
	pivot_offset = size * 0.5
	tw.chain().tween_property(self, "scale", Vector2(1.08, 1.08), 0.18).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_SINE)


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	custom_minimum_size = Vector2(400, 80)
	size = custom_minimum_size
	pivot_offset = size * 0.5
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.96, 0.74, 0.22)
	sb.set_corner_radius_all(18)
	sb.set_border_width_all(3)
	sb.border_color = Color(0.55, 0.35, 0.10)
	sb.shadow_size = 6
	sb.shadow_color = Color(0, 0, 0, 0.28)
	add_theme_stylebox_override("panel", sb)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var l := Label.new()
	l.text = "* NEW RECORD *"
	l.position = Vector2(0, 4)
	l.size = Vector2(400, 36)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 28)
	l.add_theme_color_override("font_color", Color(0.20, 0.10, 0.04))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	var sub := Label.new()
	if _prev_score > 0:
		sub.text = "%d beats previous %d" % [_new_score, _prev_score]
	else:
		sub.text = "Score %d (first time!)" % _new_score
	sub.position = Vector2(0, 42)
	sub.size = Vector2(400, 30)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 18)
	sub.add_theme_color_override("font_color", Color(0.30, 0.16, 0.04))
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sub)
