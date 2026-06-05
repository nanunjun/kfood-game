## CP-32 MilestoneToast — gold gradient banner (880x130) shown inside RewardBox
## when friendship Lv 3 / 7 / 10 was just hit.
##
## Lv 3: +500 coin one-time + line_ok unlock (toast)
## Lv 7: signature dish unlock + permanent +5% compat (banner)
## Lv 10: portrait skin unlock + permanent +0.10x reward (full-screen overlay)
##
## At RewardBox scale this is the inline form. ResultScreenV2 may also render a
## full-screen overlay for Lv 10 (additive — both use this script).
class_name MilestoneToast
extends Panel

var _milestone: int = 0


func setup(milestone: int) -> void:
	_milestone = milestone
	_rebuild()


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	custom_minimum_size = Vector2(880, 130)
	size = custom_minimum_size

	var sb := StyleBoxFlat.new()
	sb.bg_color = _gradient_color(_milestone)
	sb.set_corner_radius_all(22)
	sb.set_border_width_all(3)
	sb.border_color = Color(0.55, 0.35, 0.10)
	sb.shadow_size = 6
	sb.shadow_color = Color(0, 0, 0, 0.18)
	add_theme_stylebox_override("panel", sb)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# left icon (heart-with-number)
	var icon := Panel.new()
	icon.position = Vector2(18, 24)
	icon.size = Vector2(82, 82)
	var isb := StyleBoxFlat.new()
	isb.bg_color = Color(0.95, 0.40, 0.45)
	isb.set_corner_radius_all(41)
	isb.set_border_width_all(4)
	isb.border_color = Color(1, 1, 1, 0.95)
	icon.add_theme_stylebox_override("panel", isb)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(icon)
	var num := Label.new()
	num.text = str(_milestone)
	num.set_anchors_preset(Control.PRESET_FULL_RECT)
	num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	num.add_theme_font_size_override("font_size", 44)
	num.add_theme_color_override("font_color", Color.WHITE)
	num.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.add_child(num)

	# title + sub text
	var title := Label.new()
	title.text = _title_text(_milestone)
	title.position = Vector2(120, 18)
	title.size = Vector2(720, 36)
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(0.20, 0.10, 0.04))
	title.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.65))
	title.add_theme_constant_override("outline_size", 3)
	add_child(title)
	var sub := Label.new()
	sub.text = _sub_text(_milestone)
	sub.position = Vector2(120, 56)
	sub.size = Vector2(720, 60)
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.add_theme_font_size_override("font_size", 20)
	sub.add_theme_color_override("font_color", Color(0.30, 0.16, 0.04))
	add_child(sub)

	# sparkle accents (top-right)
	for i in range(3):
		var sp := Polygon2D.new()
		sp.polygon = _star_pts(8.0, 4.0, 5)
		sp.color = Color(1.0, 0.95, 0.60, 0.95)
		sp.position = Vector2(820.0 - float(i) * 26.0, 18.0 + float(i) * 14.0)
		add_child(sp)


func _title_text(ms: int) -> String:
	match ms:
		3:  return "Lv 3 Friendship Unlocked!"
		7:  return "Lv 7 Friendship Mastered!"
		10: return "Lv 10 Maxed!"
		_:  return "Milestone Unlocked"


func _sub_text(ms: int) -> String:
	match ms:
		3:  return "+500 coin bonus  •  line_ok unlocked"
		7:  return "Signature dish unlocked  •  permanent +5% compat"
		10: return "Portrait skin unlocked  •  permanent +0.10x reward"
		_:  return ""


func _gradient_color(ms: int) -> Color:
	# 단순 단색 (gradient texture 대신 색조만 변화)
	match ms:
		3:  return Color(0.99, 0.85, 0.40)
		7:  return Color(0.96, 0.74, 0.22)
		10: return Color(0.95, 0.55, 0.18)
		_:  return Color(0.92, 0.84, 0.50)


func _star_pts(outer_r: float, inner_r: float, points: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(points * 2):
		var r: float = outer_r if i % 2 == 0 else inner_r
		var a: float = -PI / 2.0 + TAU * float(i) / float(points * 2)
		pts.append(Vector2(cos(a) * r, sin(a) * r))
	return pts
