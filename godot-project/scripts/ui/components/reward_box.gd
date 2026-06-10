## CP-29 RewardBox — Result Screen 2.0 reward panel (960x520, expands +130).
##
## P4 (2026-06-05) emotion-first reorder: Friendship is rendered FIRST (emotion ②),
## THEN coin + Recipe XP (reward ③). setup()/play_reveal() API + data UNCHANGED —
## only the visual section order + y-positions shifted to satisfy the LOCKED brief
## "Emotion > Numbers". Layout top→bottom now:
##   1) Friendship delta (+N, fill animation toward next milestone) — emotion ②
##   2) Milestone unlock toast (inline, only when milestone_just_hit != 0)
##   3) Coin earned (large, count-up animation) — reward ③
##   4) Recipe XP gained + level progress bar (Lv X -> Lv Y if leveled) — reward ③
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


## P4 emotion-first stagger: friendship bar fill -> milestone slide-in -> coin
## count-up -> XP bar. (Was coin-first; now friendship leads since it is emotion ②.)
func play_reveal(delay: float = 0.0) -> void:
	# friendship bar fill (target = _friendship_after / 10) — FIRST (emotion ②)
	if _fr_bar_fill != null:
		var fr_pct: float = clampf(float(_friendship_after) / 10.0, 0.0, 1.0)
		var track_w2: float = 880.0
		_fr_bar_fill.size.x = 0.0
		var tw3 := create_tween()
		tw3.tween_interval(delay)
		tw3.tween_property(_fr_bar_fill, "size:x", track_w2 * fr_pct, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# milestone slide-in (right after friendship fills)
	if _milestone_root != null and _milestone > 0:
		_milestone_root.modulate.a = 0.0
		_milestone_root.position.x -= 60.0
		var tw4 := create_tween().set_parallel(true)
		tw4.tween_interval(delay + 0.5)
		tw4.chain().tween_property(_milestone_root, "modulate:a", 1.0, 0.35)
		tw4.parallel().tween_property(_milestone_root, "position:x", _milestone_root.position.x + 60.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# coin count-up (reward ③ — after the emotional friendship beat)
	if _coin_lbl != null:
		var start_val := 0
		var end_val := _coin
		var tw := create_tween()
		tw.tween_interval(delay + 0.8)
		tw.tween_method(func(v: int) -> void:
			if is_instance_valid(_coin_lbl):
				_coin_lbl.text = "+%s coin" % _commas(v),
			start_val, end_val, 0.85).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# XP bar fill (reward ③ tail)
	if _xp_bar_fill != null and _xp_bar_track != null:
		var recipe_xp := get_node_or_null("/root/RecipeXP")
		if recipe_xp != null:
			var prog: Dictionary = recipe_xp.progress(_xp_total_after)
			var pct_target: float = clampf(float(prog.get("progress_pct", 0)) / 100.0, 0.0, 1.0)
			var track_w: float = _xp_bar_track.size.x
			_xp_bar_fill.size.x = 0.0
			var tw2 := create_tween()
			tw2.tween_interval(delay + 1.2)
			tw2.tween_property(_xp_bar_fill, "size:x", track_w * pct_target, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	# P3 COMPACT (2026-06-08): friendship-first layout tightened to remove empty bands.
	# Base height holds friendship (top) + reward (bottom) snugly; milestone toast (when
	# present) is inserted between them, pushing reward down +130. (Was 520/+150.)
	var h_base: float = 396.0
	if _milestone > 0:
		h_base += 130.0
	custom_minimum_size = Vector2(960, h_base)
	size = custom_minimum_size

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.99, 0.96, 0.88)
	sb.set_corner_radius_all(28)
	sb.set_border_width_all(3)
	sb.border_color = Color(0.85, 0.66, 0.28)
	sb.shadow_size = 10
	sb.shadow_color = Color(0, 0, 0, 0.20)
	sb.shadow_offset = Vector2(0, 5)
	add_theme_stylebox_override("panel", sb)

	# ====================================================================
	# ② FRIENDSHIP (emotion-first: rendered FIRST, before coins/XP)
	# ====================================================================
	var fr_heading := Label.new()
	fr_heading.text = "Friendship"
	fr_heading.position = Vector2(32, 14)
	fr_heading.size = Vector2(600, 38)
	fr_heading.add_theme_font_size_override("font_size", 28)
	fr_heading.add_theme_color_override("font_color", Color(0.85, 0.30, 0.38))
	add_child(fr_heading)

	# +N / (x/10) sits on the heading row, right-aligned (the big emotional number)
	var fr_title := Label.new()
	var dsign := "+" if _friendship_delta > 0 else ""
	fr_title.text = "%s%d   (%d/10)" % [dsign, _friendship_delta, _friendship_after]
	fr_title.position = Vector2(40, 16)
	fr_title.size = Vector2(880, 36)
	fr_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	fr_title.add_theme_font_size_override("font_size", 30)
	fr_title.add_theme_color_override("font_color", Color(0.85, 0.30, 0.38))
	add_child(fr_title)

	var fr_track := Panel.new()
	fr_track.position = Vector2(40, 60)
	fr_track.size = Vector2(880, 28)
	var fsb_t := StyleBoxFlat.new()
	fsb_t.bg_color = Color(0.92, 0.88, 0.80)
	fsb_t.set_corner_radius_all(14)
	fr_track.add_theme_stylebox_override("panel", fsb_t)
	add_child(fr_track)
	_fr_bar_fill = Panel.new()
	_fr_bar_fill.position = Vector2(0, 0)
	_fr_bar_fill.size = Vector2(880.0 * (float(_friendship_after) / 10.0), 28)
	var ffsb := StyleBoxFlat.new()
	ffsb.bg_color = Color(0.95, 0.40, 0.45)
	ffsb.set_corner_radius_all(14)
	_fr_bar_fill.add_theme_stylebox_override("panel", ffsb)
	fr_track.add_child(_fr_bar_fill)
	# milestone tick marks at 3/7/10
	for ms_x in [3, 7, 10]:
		var tick := ColorRect.new()
		tick.color = Color(0.55, 0.35, 0.10, 0.6)
		tick.size = Vector2(3, 28)
		tick.position = Vector2(880.0 * (float(ms_x) / 10.0) - 1.5, 0)
		tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fr_track.add_child(tick)

	# --- milestone toast (inline, directly under friendship bar) ---
	var reward_y: float = 116.0
	if _milestone > 0:
		_milestone_root = MilestoneToastScript.new()
		_milestone_root.position = Vector2(40, 100)
		add_child(_milestone_root)
		_milestone_root.setup(_milestone)
		reward_y = 100.0 + 130.0  # push reward block below the toast

	# --- thin divider between emotion ② (friendship) and reward ③ ---
	var divider := ColorRect.new()
	divider.color = Color(0.85, 0.66, 0.28, 0.45)
	divider.size = Vector2(880, 2)
	divider.position = Vector2(40, reward_y - 12.0)
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(divider)

	# ====================================================================
	# ③ REWARD — coin (large) + Recipe XP, on one tight row each.
	# ====================================================================
	# coin (large) shares the row with the "Reward" heading to save vertical space.
	var rw_heading := Label.new()
	rw_heading.text = "Reward"
	rw_heading.position = Vector2(32, reward_y)
	rw_heading.size = Vector2(400, 36)
	rw_heading.add_theme_font_size_override("font_size", 26)
	rw_heading.add_theme_color_override("font_color", Color(0.40, 0.27, 0.17))
	add_child(rw_heading)

	# --- coin (large) ---
	var coin_y: float = reward_y + 40.0
	var coin_icon := _coin_icon(Vector2(40, coin_y), Vector2(64, 64))
	add_child(coin_icon)
	_coin_lbl = Label.new()
	_coin_lbl.text = "+0 coin"
	_coin_lbl.position = Vector2(118, coin_y - 6.0)
	_coin_lbl.size = Vector2(800, 76)
	_coin_lbl.add_theme_font_size_override("font_size", 52)
	_coin_lbl.add_theme_color_override("font_color", Color(0.85, 0.55, 0.10))
	_coin_lbl.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.7))
	_coin_lbl.add_theme_constant_override("outline_size", 4)
	add_child(_coin_lbl)

	# --- recipe XP block ---
	var xp_y: float = coin_y + 80.0
	var xp_title := Label.new()
	xp_title.text = "Recipe XP  +%d" % _xp_gained
	xp_title.position = Vector2(40, xp_y)
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
	xp_level_lbl.position = Vector2(820, xp_y)
	xp_level_lbl.size = Vector2(100, 30)
	xp_level_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	xp_level_lbl.add_theme_font_size_override("font_size", 24)
	xp_level_lbl.add_theme_color_override("font_color", Color(0.85, 0.55, 0.10))
	add_child(xp_level_lbl)
	_xp_bar_track = Panel.new()
	_xp_bar_track.position = Vector2(40, xp_y + 34.0)
	_xp_bar_track.size = Vector2(880, 22)
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
	_xp_bar_fill.size = Vector2(880.0 * prog_pct, 22)
	var xfsb := StyleBoxFlat.new()
	xfsb.bg_color = Color(0.96, 0.74, 0.22)
	xfsb.set_corner_radius_all(12)
	_xp_bar_fill.add_theme_stylebox_override("panel", xfsb)
	_xp_bar_track.add_child(_xp_bar_fill)


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
