## CP-29 RewardBox — Result Screen 2.0 reward panel (960x480, expands +130).
##
## Sections:
##   1) Coin earned (large, count-up animation)
##   2) Recipe XP gained + level progress bar (Lv X -> Lv Y if leveled)
##   3) Friendship delta (+N, fill animation toward next milestone)
##   4) Milestone unlock toast (inline, only when milestone_just_hit != 0)
class_name RewardBox
extends Panel

const MilestoneToastScript := preload("res://scripts/ui/components/milestone_toast.gd")

var _coin: int = 0
var _xp_gained: int = 0
var _xp_total_after: int = 0
var _food_id: String = ""
var _friendship_after: int = 0
var _friendship_delta: int = 0
var _milestone: int = 0

var _coin_lbl: Label = null
var _xp_bar_fill: Panel = null
var _xp_bar_track: Panel = null
var _fr_bar_fill: Panel = null
var _milestone_root: Control = null


func setup(payload: Dictionary) -> void:
	_coin = int(payload.get("coin", 0))
	_xp_gained = int(payload.get("xp_gained", 0))
	_xp_total_after = int(payload.get("xp_total_after", 0))
	_food_id = String(payload.get("food_id", ""))
	_friendship_after = int(payload.get("friendship_after", 0))
	_friendship_delta = int(payload.get("friendship_delta", 0))
	_milestone = int(payload.get("milestone", 0))
	_rebuild()


## Stagger reveal: coin count-up -> XP bar -> friendship bar -> milestone slide-in.
func play_reveal(delay: float = 0.0) -> void:
	# coin count-up
	if _coin_lbl != null:
		var start_val := 0
		var end_val := _coin
		var tw := create_tween()
		tw.tween_interval(delay)
		tw.tween_method(func(v: int) -> void:
			if is_instance_valid(_coin_lbl):
				_coin_lbl.text = "+%s coin" % _commas(v),
			start_val, end_val, 0.85).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# XP bar fill
	if _xp_bar_fill != null and _xp_bar_track != null:
		var recipe_xp := get_node_or_null("/root/RecipeXP")
		if recipe_xp != null:
			var prog: Dictionary = recipe_xp.progress(_xp_total_after)
			var pct_target: float = clampf(float(prog.get("progress_pct", 0)) / 100.0, 0.0, 1.0)
			var track_w: float = _xp_bar_track.size.x
			_xp_bar_fill.size.x = 0.0
			var tw2 := create_tween()
			tw2.tween_interval(delay + 0.4)
			tw2.tween_property(_xp_bar_fill, "size:x", track_w * pct_target, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# friendship bar fill (target = _friendship_after / 10)
	if _fr_bar_fill != null:
		var fr_pct: float = clampf(float(_friendship_after) / 10.0, 0.0, 1.0)
		var track_w2: float = 600.0
		_fr_bar_fill.size.x = 0.0
		var tw3 := create_tween()
		tw3.tween_interval(delay + 0.8)
		tw3.tween_property(_fr_bar_fill, "size:x", track_w2 * fr_pct, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# milestone slide-in
	if _milestone_root != null and _milestone > 0:
		_milestone_root.modulate.a = 0.0
		_milestone_root.position.x -= 60.0
		var tw4 := create_tween().set_parallel(true)
		tw4.tween_interval(delay + 1.3)
		tw4.chain().tween_property(_milestone_root, "modulate:a", 1.0, 0.35)
		tw4.parallel().tween_property(_milestone_root, "position:x", _milestone_root.position.x + 60.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	var h_base: float = 480.0
	if _milestone > 0:
		h_base += 130.0
	custom_minimum_size = Vector2(960, h_base)
	size = custom_minimum_size

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.99, 0.96, 0.88)
	sb.set_corner_radius_all(28)
	sb.set_border_width_all(3)
	sb.border_color = Color(0.85, 0.66, 0.28)
	sb.shadow_size = 8
	sb.shadow_color = Color(0, 0, 0, 0.18)
	add_theme_stylebox_override("panel", sb)

	# --- title ---
	var title := Label.new()
	title.text = "Rewards"
	title.position = Vector2(32, 18)
	title.size = Vector2(900, 44)
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.40, 0.27, 0.17))
	add_child(title)

	# --- coin (large) ---
	var coin_icon := _coin_icon(Vector2(40, 80), Vector2(72, 72))
	add_child(coin_icon)
	_coin_lbl = Label.new()
	_coin_lbl.text = "+0 coin"
	_coin_lbl.position = Vector2(130, 76)
	_coin_lbl.size = Vector2(800, 80)
	_coin_lbl.add_theme_font_size_override("font_size", 56)
	_coin_lbl.add_theme_color_override("font_color", Color(0.85, 0.55, 0.10))
	_coin_lbl.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.7))
	_coin_lbl.add_theme_constant_override("outline_size", 4)
	add_child(_coin_lbl)

	# --- recipe XP block ---
	var xp_title := Label.new()
	xp_title.text = "Recipe XP  +%d" % _xp_gained
	xp_title.position = Vector2(40, 178)
	xp_title.size = Vector2(900, 30)
	xp_title.add_theme_font_size_override("font_size", 24)
	xp_title.add_theme_color_override("font_color", Color(0.30, 0.20, 0.10))
	add_child(xp_title)
	var xp_level_lbl := Label.new()
	var recipe_xp := get_node_or_null("/root/RecipeXP")
	var lvl_now: int = 1
	if recipe_xp:
		lvl_now = recipe_xp.level_of(_xp_total_after)
	xp_level_lbl.text = "Lv %d" % lvl_now
	xp_level_lbl.position = Vector2(820, 178)
	xp_level_lbl.size = Vector2(100, 30)
	xp_level_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	xp_level_lbl.add_theme_font_size_override("font_size", 24)
	xp_level_lbl.add_theme_color_override("font_color", Color(0.85, 0.55, 0.10))
	add_child(xp_level_lbl)
	_xp_bar_track = Panel.new()
	_xp_bar_track.position = Vector2(40, 214)
	_xp_bar_track.size = Vector2(880, 24)
	var xsb := StyleBoxFlat.new()
	xsb.bg_color = Color(0.92, 0.88, 0.80)
	xsb.set_corner_radius_all(12)
	_xp_bar_track.add_theme_stylebox_override("panel", xsb)
	add_child(_xp_bar_track)
	_xp_bar_fill = Panel.new()
	_xp_bar_fill.position = Vector2(0, 0)
	var prog_pct: float = 0.0
	if recipe_xp != null:
		prog_pct = float(recipe_xp.progress(_xp_total_after).get("progress_pct", 0)) / 100.0
	_xp_bar_fill.size = Vector2(880.0 * prog_pct, 24)
	var xfsb := StyleBoxFlat.new()
	xfsb.bg_color = Color(0.96, 0.74, 0.22)
	xfsb.set_corner_radius_all(12)
	_xp_bar_fill.add_theme_stylebox_override("panel", xfsb)
	_xp_bar_track.add_child(_xp_bar_fill)

	# --- friendship block ---
	var fr_title := Label.new()
	var dsign := "+" if _friendship_delta > 0 else ""
	fr_title.text = "Friendship  %s%d  (%d/10)" % [dsign, _friendship_delta, _friendship_after]
	fr_title.position = Vector2(40, 264)
	fr_title.size = Vector2(900, 30)
	fr_title.add_theme_font_size_override("font_size", 24)
	fr_title.add_theme_color_override("font_color", Color(0.30, 0.20, 0.10))
	add_child(fr_title)
	var fr_track := Panel.new()
	fr_track.position = Vector2(40, 300)
	fr_track.size = Vector2(880, 24)
	var fsb_t := StyleBoxFlat.new()
	fsb_t.bg_color = Color(0.92, 0.88, 0.80)
	fsb_t.set_corner_radius_all(12)
	fr_track.add_theme_stylebox_override("panel", fsb_t)
	add_child(fr_track)
	_fr_bar_fill = Panel.new()
	_fr_bar_fill.position = Vector2(0, 0)
	_fr_bar_fill.size = Vector2(880.0 * (float(_friendship_after) / 10.0), 24)
	var ffsb := StyleBoxFlat.new()
	ffsb.bg_color = Color(0.95, 0.40, 0.45)
	ffsb.set_corner_radius_all(12)
	_fr_bar_fill.add_theme_stylebox_override("panel", ffsb)
	fr_track.add_child(_fr_bar_fill)
	# milestone tick marks at 3/7/10
	for ms_x in [3, 7, 10]:
		var tick := ColorRect.new()
		tick.color = Color(0.55, 0.35, 0.10, 0.6)
		tick.size = Vector2(3, 24)
		tick.position = Vector2(880.0 * (float(ms_x) / 10.0) - 1.5, 0)
		tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fr_track.add_child(tick)

	# --- milestone toast (inline) ---
	if _milestone > 0:
		_milestone_root = MilestoneToastScript.new()
		_milestone_root.position = Vector2(40, 360)
		add_child(_milestone_root)
		_milestone_root.setup(_milestone)


func _coin_icon(pos: Vector2, sz: Vector2) -> Control:
	var p := Panel.new()
	p.position = pos
	p.size = sz
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.96, 0.74, 0.22)
	sb.set_corner_radius_all(int(sz.x / 2.0))
	sb.set_border_width_all(4)
	sb.border_color = Color(0.55, 0.35, 0.10)
	p.add_theme_stylebox_override("panel", sb)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var w := Label.new()
	w.text = "W"
	w.set_anchors_preset(Control.PRESET_FULL_RECT)
	w.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	w.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	w.add_theme_font_size_override("font_size", int(sz.x * 0.55))
	w.add_theme_color_override("font_color", Color(0.45, 0.25, 0.05))
	w.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(w)
	return p


func _commas(n: int) -> String:
	var s := str(n)
	var out := ""
	var c := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = "," + out
	return out
