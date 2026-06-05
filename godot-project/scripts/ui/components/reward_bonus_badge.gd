## RewardBonusBadge — wide gradient band showing the compat reward multiplier.
##
## E.g. compat=93 -> "1.30x Reward". Color follows RewardCalc.compat_color.
class_name RewardBonusBadge
extends Panel

var _compat: int = 50
var _guest: Dictionary = {}


func setup(compat: int, guest: Dictionary = {}) -> void:
	_compat = clampi(compat, 0, 100)
	_guest = guest
	_rebuild()


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	custom_minimum_size = Vector2(478, 70)
	var reward_calc := get_node_or_null("/root/RewardCalc")
	var mult: float = reward_calc.bonus_multiplier(_compat) if reward_calc else 1.0
	var gb: float = float(_guest.get("reward_bonus", 1.0))
	var total: float = mult * gb
	var col: Color = reward_calc.compat_color(_compat) if reward_calc else Color(0.7, 0.7, 0.7)
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(20)
	sb.set_border_width_all(2)
	sb.border_color = col.darkened(0.22)
	sb.shadow_size = 4
	sb.shadow_color = Color(0, 0, 0, 0.18)
	add_theme_stylebox_override("panel", sb)
	# left text: "REWARD"
	var l := Label.new()
	l.text = "REWARD"
	l.position = Vector2(20, 0)
	l.size = Vector2(160, 70)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 24)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.4))
	l.add_theme_constant_override("outline_size", 2)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	# right text: "1.56x" (= guest_bonus * compat_mult)
	var r := Label.new()
	r.text = "%.2fx" % total
	r.position = Vector2(custom_minimum_size.x - 180, 0)
	r.size = Vector2(160, 70)
	r.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	r.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	r.add_theme_font_size_override("font_size", 36)
	r.add_theme_color_override("font_color", Color.WHITE)
	r.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.45))
	r.add_theme_constant_override("outline_size", 3)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(r)
	# breakdown chip
	var chip := Label.new()
	chip.text = "guest %.2f x compat %.2f" % [gb, mult]
	chip.position = Vector2(180, 0)
	chip.size = Vector2(custom_minimum_size.x - 360, 70)
	chip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chip.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	chip.add_theme_font_size_override("font_size", 16)
	chip.add_theme_color_override("font_color", Color(0.98, 0.96, 0.92, 0.92))
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(chip)
