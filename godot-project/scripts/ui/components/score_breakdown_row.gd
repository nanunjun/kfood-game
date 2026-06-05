## CP-28 ScoreBreakdownRow — single row in the 6-row score panel (960x100).
##
## Used by ResultScreenV2 to render each entry from
## RewardCalc.score_breakdown_rows(...). Layout:
##   [icon|label  ........  value_pct%   tone_chip]
##                (note line underneath the label, smaller font)
##
## On scroll-in, animate the value bar via play_reveal(delay).
class_name ScoreBreakdownRow
extends Panel

var _row_data: Dictionary = {}
var _bar_fill: Panel = null
var _value_label: Label = null


func setup(row: Dictionary) -> void:
	_row_data = row
	_rebuild()


## Tween value bar 0% -> target after delay (seconds).
func play_reveal(delay: float = 0.0) -> void:
	if _bar_fill == null or _value_label == null:
		return
	var pct: int = int(_row_data.get("value_pct", 0))
	var target_w: float = (custom_minimum_size.x - 360.0) * clampf(float(pct) / 100.0, 0.0, 1.0)
	_bar_fill.size.x = 0.0
	var tw := create_tween()
	tw.tween_interval(delay)
	tw.tween_property(_bar_fill, "size:x", target_w, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	custom_minimum_size = Vector2(960, 100)
	size = custom_minimum_size
	var tone: String = String(_row_data.get("tone", "="))
	var tone_col: Color = _tone_color(tone)
	# panel bg
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(1.0, 0.99, 0.96)
	sb.set_corner_radius_all(18)
	sb.set_border_width_all(2)
	sb.border_color = tone_col.lerp(Color(0.85, 0.78, 0.65), 0.6)
	add_theme_stylebox_override("panel", sb)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Label (left)
	var lbl := Label.new()
	lbl.text = String(_row_data.get("label", "?"))
	lbl.position = Vector2(28, 12)
	lbl.size = Vector2(280, 36)
	lbl.add_theme_font_size_override("font_size", 26)
	lbl.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	add_child(lbl)
	# note (under label, smaller)
	var note := Label.new()
	note.text = String(_row_data.get("note", ""))
	note.position = Vector2(28, 52)
	note.size = Vector2(560, 36)
	note.add_theme_font_size_override("font_size", 18)
	note.add_theme_color_override("font_color", Color(0.50, 0.40, 0.30))
	add_child(note)

	# Bar track (right side)
	var bar_x: float = 320.0
	var bar_w: float = custom_minimum_size.x - 360.0
	var track := Panel.new()
	track.position = Vector2(bar_x, 38)
	track.size = Vector2(bar_w, 24)
	var tsb := StyleBoxFlat.new()
	tsb.bg_color = Color(0.92, 0.88, 0.80)
	tsb.set_corner_radius_all(12)
	track.add_theme_stylebox_override("panel", tsb)
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(track)
	_bar_fill = Panel.new()
	_bar_fill.position = Vector2(0, 0)
	var pct: int = int(_row_data.get("value_pct", 0))
	var ratio: float = clampf(float(pct) / 100.0, 0.0, 1.0)
	_bar_fill.size = Vector2(bar_w * ratio, 24)
	var fsb := StyleBoxFlat.new()
	fsb.bg_color = tone_col
	fsb.set_corner_radius_all(12)
	_bar_fill.add_theme_stylebox_override("panel", fsb)
	_bar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track.add_child(_bar_fill)

	# Value % label (right of bar)
	_value_label = Label.new()
	var sign := ""
	if String(_row_data.get("key", "")) == "compat_bonus":
		sign = ("+" if pct > 0 else "")
		_value_label.text = "%s%d%%" % [sign, pct]
	elif String(_row_data.get("key", "")) == "mood_modifier":
		# mood: no numeric value, just chip
		_value_label.text = ""
	else:
		_value_label.text = "%d%%" % pct
	_value_label.position = Vector2(bar_x, 12)
	_value_label.size = Vector2(bar_w, 24)
	_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_value_label.add_theme_font_size_override("font_size", 22)
	_value_label.add_theme_color_override("font_color", tone_col.darkened(0.30))
	_value_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_value_label)


func _tone_color(tone: String) -> Color:
	match tone:
		"+": return Color(0.30, 0.78, 0.40)   # green
		"-": return Color(0.82, 0.40, 0.30)   # red
		_:   return Color(0.92, 0.78, 0.30)   # amber
