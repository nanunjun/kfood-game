## MenuSelect — data-driven menu grid (M1+). Procedural UI, Control root. PREMIUM REDESIGN.
##
## Visual-only premium pass:
##   - DropShadowPanel (CP-34) on every card (12~16px Y soft shadow + top highlight)
##   - GlossyButton (CP-33) for Cook CTA (gradient persimmon)
##   - GoldRibbonBanner (CP-38) "TODAY'S PICK" hero ribbon on best-compat card
##   - HeroNumberBounce (CP-37) on the TODAY'S PICK compat % chip
##   - SparkleParticle (CP-35) halo around best mini-badge
##   - Coin wallet pill upgraded to gold gradient
##   - Locked overlay = dim + lock pill
##   - Row v-separation 30 (preserved larger to keep TODAY'S PICK ribbon clearance)
##
## GAMEPLAY-CRITICAL: data flow, _on_pick, _on_restock, SaveManager calls UNCHANGED.
## Ref: round-system-v3.md, economy-save-v1.md, guest-select-ui.md
extends Control

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")

const MarketBG := preload("res://scripts/ui/market_bg.gd")
const DropShadowScript := preload("res://scripts/ui/premium/drop_shadow_panel.gd")
const GlossyButtonScript := preload("res://scripts/ui/premium/glossy_button.gd")
const GoldRibbonScript := preload("res://scripts/ui/premium/gold_ribbon_banner.gd")
const HeroNumberScript := preload("res://scripts/ui/premium/hero_number_bounce.gd")
const SparkleScript := preload("res://scripts/ui/premium/sparkle_particle.gd")

var _money_label: Label = null
var _best_pick_id: String = ""
var _best_pick_compat: int = 0


func _ready() -> void:
	add_child(MarketBG.new())  # Korean traditional-market backdrop (behind everything)

	var sm := get_node_or_null("/root/SaveManager")
	var lvl: int = sm.level() if sm else 8
	var lv_data: Dictionary = MenuDB.get_level(lvl)

	# Pre-compute today's best pick (highest compat among unlocked + ready menus)
	_compute_today_pick(lvl)

	# hanging wooden signboard
	for rope_x in [320.0, 760.0]:
		var rope := ColorRect.new()
		rope.color = Color(0.25, 0.18, 0.12)
		rope.size = Vector2(6, 40)
		rope.position = Vector2(rope_x, 0)
		rope.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(rope)
	var sign := Panel.new()
	sign.position = Vector2(150, 38)
	sign.size = Vector2(780, 132)
	var ssb := StyleBoxFlat.new()
	ssb.bg_color = Color(0.36, 0.24, 0.15)
	ssb.set_corner_radius_all(26)
	ssb.set_border_width_all(5)
	ssb.border_color = Color(0.85, 0.66, 0.28)
	ssb.shadow_size = 14
	ssb.shadow_color = Color(0, 0, 0, 0.35)
	ssb.shadow_offset = Vector2(0, 8)
	sign.add_theme_stylebox_override("panel", ssb)
	add_child(sign)
	var title := Label.new()
	title.text = "K-Food Master"
	title.position = Vector2(0, 18)
	title.size = Vector2(780, 64)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", Color(0.99, 0.92, 0.78))
	title.add_theme_color_override("font_outline_color", Color(0.20, 0.10, 0.04))
	title.add_theme_constant_override("outline_size", 3)
	sign.add_child(title)
	var tsub := Label.new()
	tsub.text = "— choose a dish —"
	tsub.position = Vector2(0, 84)
	tsub.size = Vector2(780, 36)
	tsub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tsub.add_theme_font_size_override("font_size", 28)
	tsub.add_theme_color_override("font_color", Color(0.92, 0.78, 0.50))
	sign.add_child(tsub)

	# level + money pills (premium gold for money)
	_pill("Lv %d · %s" % [lvl, String(lv_data.get("market", "home")).capitalize()],
		Vector2(40, 192), 470, Color(0.55, 0.36, 0.20))
	_money_label = _pill_gold("₩%s" % _commas(sm.money() if sm else 0),
		Vector2(570, 192), 470)
	_money_label.name = "WalletMoneyLabel"  # discoverable for coin spray HUD link

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(40, 280)
	scroll.size = Vector2(1000, 1470)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 30)
	grid.add_theme_constant_override("v_separation", 44)  # bumped 30 -> 44 for ribbon clearance
	scroll.add_child(grid)

	for id in MenuDB.all_menu_ids():
		var menu: Dictionary = MenuDB.get_menu(id)
		var locked: bool = int(menu.get("unlock_level", 1)) > lvl
		grid.add_child(_make_card(menu, locked, sm))

	# level-up toast
	if sm and sm.has_method("consume_levelup_notice"):
		var nl: int = sm.consume_levelup_notice()
		if nl > 0:
			_levelup_toast(nl)


func _compute_today_pick(player_lvl: int) -> void:
	# Pick the unlocked + ready menu with the highest CompatCalc.best_guest compat.
	var compat_sys := get_node_or_null("/root/CompatCalc")
	if compat_sys == null:
		return
	_best_pick_id = ""
	_best_pick_compat = 0
	for id in MenuDB.all_menu_ids():
		var menu: Dictionary = MenuDB.get_menu(id)
		if int(menu.get("unlock_level", 1)) > player_lvl:
			continue
		# skip evaluator levels (no best-guest chip on those)
		var lv: Dictionary = MenuDB.get_level(int(menu.get("unlock_level", 1)))
		if String(lv.get("evaluator", "")) != "":
			continue
		var best: Dictionary = compat_sys.best_guest(String(menu.get("id", "")))
		if best.is_empty():
			continue
		var c: int = int(best.get("compat", 0))
		if c > _best_pick_compat:
			_best_pick_compat = c
			_best_pick_id = String(menu.get("id", ""))


# guest avatar tints (match guest_select)
const GUEST_TINT := {
	"junho": Color(0.86, 0.45, 0.40), "mina": Color(0.95, 0.78, 0.45),
	"riley": Color(0.55, 0.72, 0.85), "mrs_lee": Color(0.70, 0.80, 0.62),
	"seoyeon": Color(0.80, 0.62, 0.85), "mystery_diner": Color(0.55, 0.55, 0.62),
	"blogger_daniel": Color(0.62, 0.72, 0.55), "goldspoon": Color(0.85, 0.72, 0.35),
	"mother_01": Color(0.85, 0.60, 0.70), "father_01": Color(0.55, 0.45, 0.40),
}

# palette
const C_CREAM := Color(0.99, 0.97, 0.92)
const C_PLATE := Color(0.96, 0.92, 0.84)
const C_GOCHU := Color(0.78, 0.20, 0.15)
const C_WOOD := Color(0.40, 0.27, 0.16)

func _rarity_color(lvl: int) -> Color:
	if lvl >= 6: return Color(0.92, 0.72, 0.28)   # gold
	elif lvl >= 3: return Color(0.74, 0.78, 0.84)  # silver
	return Color(0.80, 0.55, 0.32)                 # bronze


func _axis_color(axis: String) -> Color:
	match axis:
		"spicy": return Color(0.82, 0.24, 0.18)
		"sweet": return Color(0.93, 0.55, 0.72)
		"sour": return Color(0.78, 0.80, 0.30)
		"umami": return Color(0.55, 0.38, 0.22)
		_: return Color(0.45, 0.60, 0.78)            # salty
	return Color(0.45, 0.60, 0.78)


func _dominant_axis(guest: Dictionary) -> String:
	var vec: Dictionary = guest.get("vec", {})
	var top := "salty"
	var tv := -1.0
	for a in vec.keys():
		if float(vec[a]) > tv:
			tv = float(vec[a])
			top = a
	return top


func _make_card(menu: Dictionary, locked: bool, sm) -> Control:
	var lvl := int(menu.get("unlock_level", 1))
	var lv_data: Dictionary = MenuDB.get_level(lvl)
	var stock: int = sm.stock_of(String(menu.get("id", ""))) if sm else 3
	var guest: Dictionary = MenuDB.get_guest(String(menu.get("guest_id", "")))
	var rarity := _rarity_color(lvl)
	var is_today_pick: bool = (String(menu.get("id", "")) == _best_pick_id) and not locked

	# --- collectible recipe card (premium drop-shadow) ---
	var card := Panel.new()
	card.custom_minimum_size = Vector2(470, 500)
	# premium drop shadow + border in rarity tint
	var card_bg: Color = Color(0.90, 0.88, 0.84) if locked else C_CREAM
	if is_today_pick:
		card_bg = Color(1.0, 0.97, 0.82)  # soft gold tint
	DropShadowScript.apply_to(card, card_bg, 34, 14,
		rarity.darkened(0.15) if locked else (Color(0.95, 0.70, 0.18) if is_today_pick else rarity),
		7 if is_today_pick else 6)

	# food "plate" frame (illustration ~60% of card)
	var plate := Panel.new()
	plate.position = Vector2(36, 72)
	plate.size = Vector2(398, 250)
	var psb := StyleBoxFlat.new()
	psb.bg_color = Color(0.90, 0.87, 0.80) if locked else C_PLATE
	psb.set_corner_radius_all(24)
	psb.set_border_width_all(3)
	psb.border_color = Color(0.84, 0.72, 0.52)
	psb.shadow_size = 6
	psb.shadow_color = Color(0, 0, 0, 0.15)
	plate.add_theme_stylebox_override("panel", psb)
	card.add_child(plate)
	# warm glow behind the dish
	if not locked:
		var grad := Gradient.new()
		grad.set_color(0, Color(1.0, 0.86, 0.55, 0.55))
		grad.set_color(1, Color(1.0, 0.86, 0.55, 0.0))
		var gt := GradientTexture2D.new()
		gt.gradient = grad
		gt.fill = GradientTexture2D.FILL_RADIAL
		gt.fill_from = Vector2(0.5, 0.5)
		gt.fill_to = Vector2(1.0, 0.5)
		gt.width = 360
		gt.height = 240
		var glow := TextureRect.new()
		glow.texture = gt
		glow.position = Vector2(19, 5)
		glow.size = Vector2(360, 240)
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		plate.add_child(glow)
	# the dish
	var thumb := TextureRect.new()
	thumb.position = Vector2(24, 14)
	thumb.size = Vector2(350, 222)
	thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if bool(menu.get("ready", false)):
		var tex: Texture2D = load(String(menu.get("food_img", "")))
		if tex != null:
			thumb.texture = tex
	if locked:
		thumb.modulate = Color(0.5, 0.5, 0.5, 0.7)
	plate.add_child(thumb)
	if thumb.texture == null:
		var ph := Label.new()
		ph.text = "Art coming\nsoon"
		ph.set_anchors_preset(Control.PRESET_FULL_RECT)
		ph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ph.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		ph.add_theme_font_size_override("font_size", 28)
		ph.add_theme_color_override("font_color", Color(0.6, 0.5, 0.4))
		ph.mouse_filter = Control.MOUSE_FILTER_IGNORE
		plate.add_child(ph)

	# level rarity tag (top-left)
	var tag := Panel.new()
	tag.position = Vector2(18, 18)
	tag.size = Vector2(86, 50)
	var tsb := StyleBoxFlat.new()
	tsb.bg_color = rarity
	tsb.set_corner_radius_all(16)
	tsb.shadow_size = 6
	tsb.shadow_color = Color(0, 0, 0, 0.22)
	tag.add_theme_stylebox_override("panel", tsb)
	card.add_child(tag)
	var tagl := Label.new()
	tagl.text = "Lv %d" % lvl
	tagl.set_anchors_preset(Control.PRESET_FULL_RECT)
	tagl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tagl.add_theme_font_size_override("font_size", 26)
	tagl.add_theme_color_override("font_color", Color(0.2, 0.13, 0.07))
	tag.add_child(tagl)

	# top-right mini-badge: evaluator OR Guest System 2.0 "best match" chip
	var eval_id := String(lv_data.get("evaluator", ""))
	if eval_id != "":
		# evaluator levels: keep the original purple-ring chip
		var chip_guest: Dictionary = MenuDB.get_guest(eval_id)
		var chip := Panel.new()
		chip.position = Vector2(372, 14)
		chip.size = Vector2(84, 84)
		var csb := StyleBoxFlat.new()
		csb.bg_color = GUEST_TINT.get(eval_id, Color(0.8, 0.7, 0.6))
		csb.set_corner_radius_all(42)
		csb.set_border_width_all(5)
		csb.border_color = Color(0.62, 0.30, 0.66)
		csb.shadow_size = 8
		csb.shadow_color = Color(0, 0, 0, 0.30)
		chip.add_theme_stylebox_override("panel", csb)
		card.add_child(chip)
		var ci := Label.new()
		ci.text = String(chip_guest.get("name", "?")).substr(0, 1)
		ci.set_anchors_preset(Control.PRESET_FULL_RECT)
		ci.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ci.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		ci.add_theme_font_size_override("font_size", 44)
		ci.add_theme_color_override("font_color", Color.WHITE)
		chip.add_child(ci)
	else:
		_add_best_guest_badge(card, menu, is_today_pick)

	# name (EN + KR subtitle)
	var name_lbl := Label.new()
	name_lbl.text = "%s  (%s)" % [menu.get("name_en", "?"), menu.get("name_kr", "")]
	name_lbl.position = Vector2(16, 334)
	name_lbl.size = Vector2(438, 42)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 34)
	name_lbl.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	card.add_child(name_lbl)

	# guest hint line
	var hint := Label.new()
	if eval_id != "":
		var eval_guest: Dictionary = MenuDB.get_guest(eval_id)
		hint.text = "★ %s is watching" % eval_guest.get("name", "Evaluator")
		hint.add_theme_color_override("font_color", Color(0.55, 0.30, 0.65))
	else:
		hint.text = "%s: \"%s\"" % [guest.get("name", "Guest"), guest.get("line_enter", "")]
		hint.add_theme_color_override("font_color", Color(0.45, 0.35, 0.25))
	hint.position = Vector2(20, 378)
	hint.size = Vector2(430, 56)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 22)
	card.add_child(hint)

	# footer: GlossyButton Cook CTA + stock / restock + locked overlay
	var out_of_stock := stock <= 0
	var cta_label: String = "Locked" if locked else ("Out of stock" if out_of_stock else "Cook  ·  Stock %d" % stock)
	var cta_tint: Color = Color(0.62, 0.58, 0.52) if (locked or out_of_stock) else C_GOCHU
	var cook_root = GlossyButtonScript.new()
	cook_root.position = Vector2(20, 434)
	cook_root.size = Vector2(430, 52)
	cook_root.custom_minimum_size = Vector2(430, 52)
	if out_of_stock and not locked:
		cook_root.size = Vector2(244, 52)
		cook_root.custom_minimum_size = Vector2(244, 52)
	card.add_child(cook_root)
	cook_root.setup(cta_label, cta_tint, 26, 22)
	# Wire press
	_wire_cook_button(cook_root, String(menu.get("id", "t1_002")), locked or out_of_stock)

	if out_of_stock and not locked:
		var restock_root = GlossyButtonScript.new()
		restock_root.position = Vector2(272, 434)
		restock_root.size = Vector2(178, 52)
		restock_root.custom_minimum_size = Vector2(178, 52)
		card.add_child(restock_root)
		restock_root.setup("Restock ₩%s" % _commas(2000), Color(0.30, 0.55, 0.35), 22, 22)
		_wire_restock_button(restock_root, String(menu.get("id", "")))

	# Locked overlay pill (top-center of plate) for visual lock affordance
	if locked:
		_add_locked_overlay(card, lvl)

	# TODAY'S PICK gold ribbon (CP-38) at top of card
	if is_today_pick:
		_add_today_pick_ribbon(card)

	return card


func _add_today_pick_ribbon(card: Panel) -> void:
	var ribbon = GoldRibbonScript.new()
	ribbon.position = Vector2(20, -22)
	ribbon.size = Vector2(430, 60)
	ribbon.custom_minimum_size = Vector2(430, 60)
	ribbon.z_index = 50
	card.add_child(ribbon)
	ribbon.setup("TODAY'S PICK", "%d%% best match" % _best_pick_compat)
	ribbon.call_deferred("play_reveal", 0.0)


func _add_locked_overlay(card: Panel, lvl: int) -> void:
	var lock_pill := Panel.new()
	lock_pill.position = Vector2((card.custom_minimum_size.x - 220.0) * 0.5, 168)
	lock_pill.size = Vector2(220, 64)
	var psb := StyleBoxFlat.new()
	psb.bg_color = Color(0.10, 0.08, 0.05, 0.82)
	psb.set_corner_radius_all(32)
	psb.set_border_width_all(3)
	psb.border_color = Color(0.95, 0.70, 0.18, 0.65)
	lock_pill.add_theme_stylebox_override("panel", psb)
	lock_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(lock_pill)
	var l := Label.new()
	l.text = "UNLOCK Lv %d" % lvl
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 22)
	l.add_theme_color_override("font_color", Color(0.95, 0.85, 0.45))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lock_pill.add_child(l)


func _wire_cook_button(gb: Control, menu_id: String, disabled: bool) -> void:
	if not is_inside_tree():
		return
	await get_tree().process_frame
	if gb == null or not is_instance_valid(gb):
		return
	if gb.get("button") == null:
		await get_tree().process_frame
	var btn: Button = gb.get("button")
	if btn != null:
		btn.disabled = disabled
		if not disabled:
			btn.pressed.connect(func() -> void: _on_pick(menu_id))


func _wire_restock_button(gb: Control, menu_id: String) -> void:
	if not is_inside_tree():
		return
	await get_tree().process_frame
	if gb == null or not is_instance_valid(gb):
		return
	if gb.get("button") == null:
		await get_tree().process_frame
	var btn: Button = gb.get("button")
	if btn != null:
		btn.pressed.connect(func() -> void: _on_restock(menu_id))


# Guest System 2.0 mini-badge: avatar 60x60 + compat % + "Best: X" caption in a
# 110x106 chip at top-right of the menu card. PREMIUM: sparkle halo when TODAY'S PICK.
func _add_best_guest_badge(card: Panel, menu: Dictionary, halo_on: bool) -> void:
	var compat_sys := get_node_or_null("/root/CompatCalc")
	var reward_calc := get_node_or_null("/root/RewardCalc")
	if compat_sys == null:
		return
	var best: Dictionary = compat_sys.best_guest(String(menu.get("id", "")))
	if best.is_empty() or String(best.get("guest_id", "")) == "":
		return
	var best_id: String = String(best["guest_id"])
	var best_compat: int = int(best["compat"])
	var best_guest: Dictionary = MenuDB.get_guest(best_id)
	var compat_col: Color = reward_calc.compat_color(best_compat) if reward_calc else Color(0.85, 0.80, 0.70)

	# outer 110x106 pill bg
	var mini := Panel.new()
	mini.position = Vector2(342, 12)
	mini.size = Vector2(116, 110)
	var msb := StyleBoxFlat.new()
	msb.bg_color = compat_col
	msb.set_corner_radius_all(20)
	msb.set_border_width_all(3)
	msb.border_color = compat_col.darkened(0.25)
	msb.shadow_size = 8
	msb.shadow_color = Color(0, 0, 0, 0.32)
	msb.shadow_offset = Vector2(0, 4)
	mini.add_theme_stylebox_override("panel", msb)
	card.add_child(mini)

	# sparkle halo if today's pick
	if halo_on:
		var sp = SparkleScript.new()
		mini.add_child(sp)
		sp.halo(mini.size * 0.5, 8, 76.0, Color(1.0, 0.92, 0.45))

	# avatar (small circle 50x50). Phase B+C: real sprite (neutral) if available.
	var av := Panel.new()
	av.position = Vector2(8, 6)
	av.size = Vector2(50, 50)
	var avsb := StyleBoxFlat.new()
	avsb.bg_color = GUEST_TINT.get(best_id, Color(0.8, 0.7, 0.6))
	avsb.set_corner_radius_all(25)
	avsb.set_border_width_all(2)
	avsb.border_color = Color.WHITE
	av.add_theme_stylebox_override("panel", avsb)
	av.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mini.add_child(av)
	var avatar_path := "res://art/sprites/character/%s_neutral.png" % best_id
	if ResourceLoader.exists(avatar_path):
		var avatar_tex := TextureRect.new()
		avatar_tex.texture = load(avatar_path)
		avatar_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
		avatar_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		avatar_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		avatar_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		av.add_child(avatar_tex)
	else:
		var ai := Label.new()
		ai.text = String(best_guest.get("name", "?")).substr(0, 1)
		ai.set_anchors_preset(Control.PRESET_FULL_RECT)
		ai.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ai.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		ai.add_theme_font_size_override("font_size", 26)
		ai.add_theme_color_override("font_color", Color.WHITE)
		av.add_child(ai)

	# compat % (right of avatar)
	var pct := Label.new()
	pct.text = "%d%%" % best_compat
	pct.position = Vector2(58, 4)
	pct.size = Vector2(56, 30)
	pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pct.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pct.add_theme_font_size_override("font_size", 24)
	pct.add_theme_color_override("font_color", Color.WHITE)
	pct.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.4))
	pct.add_theme_constant_override("outline_size", 2)
	pct.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mini.add_child(pct)
	var pct_sub := Label.new()
	pct_sub.text = "match"
	pct_sub.position = Vector2(58, 32)
	pct_sub.size = Vector2(56, 18)
	pct_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pct_sub.add_theme_font_size_override("font_size", 12)
	pct_sub.add_theme_color_override("font_color", Color.WHITE)
	pct_sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mini.add_child(pct_sub)

	# "Best: Mina" caption at bottom
	var cap := Label.new()
	cap.text = "Best: %s" % best_guest.get("name", "?")
	cap.position = Vector2(4, 64)
	cap.size = Vector2(108, 40)
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cap.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cap.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cap.add_theme_font_size_override("font_size", 16)
	cap.add_theme_color_override("font_color", Color.WHITE)
	cap.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.45))
	cap.add_theme_constant_override("outline_size", 2)
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mini.add_child(cap)


func _on_pick(menu_id: String) -> void:
	# Cooking Framework 2.0 — route to the data-driven module runner. The legacy
	# rhythm_proto.gd is kept in tree for git history but no longer entered from the UI.
	var RunnerScript := preload("res://scripts/gameplay/cooking_module_runner.gd")
	RunnerScript.pending_menu_id = menu_id
	RunnerScript.pending_guest_id = ""
	var menu: Dictionary = MenuDB.get_menu(menu_id)
	var lv_data: Dictionary = MenuDB.get_level(int(menu.get("unlock_level", 1)))
	# evaluator levels skip guest selection
	if String(lv_data.get("evaluator", "")) != "":
		get_tree().change_scene_to_file("res://scenes/cooking_module_runner.tscn")
	else:
		var GuestSelectScript := preload("res://scripts/ui/guest_select.gd")
		GuestSelectScript.pending_menu_id = menu_id
		get_tree().change_scene_to_file("res://scenes/guest_select.tscn")


func _on_restock(menu_id: String) -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.restock(menu_id):
		get_tree().reload_current_scene()


func _levelup_toast(new_level: int) -> void:
	var lv_data: Dictionary = MenuDB.get_level(new_level)
	var t := Label.new()
	t.text = "Level Up! ▲ Level %d — %s market unlocked!" % [new_level, String(lv_data.get("market", "home")).capitalize()]
	t.position = Vector2(40, 1700)
	t.size = Vector2(1000, 120)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t.add_theme_font_size_override("font_size", 40)
	t.add_theme_color_override("font_color", Color(0.85, 0.55, 0.1))
	var tsb := StyleBoxFlat.new()
	tsb.bg_color = Color(1.0, 0.97, 0.88)
	tsb.set_corner_radius_all(20)
	t.add_theme_stylebox_override("normal", tsb)
	add_child(t)
	var tw := create_tween()
	tw.tween_interval(2.6)
	tw.tween_property(t, "modulate:a", 0.0, 0.6)
	tw.tween_callback(t.queue_free)


func _pill(txt: String, pos: Vector2, w: float, col: Color) -> Label:
	var p := Panel.new()
	p.position = pos
	p.size = Vector2(w, 56)
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(28)
	sb.shadow_size = 8
	sb.shadow_color = Color(0, 0, 0, 0.28)
	sb.shadow_offset = Vector2(0, 4)
	p.add_theme_stylebox_override("panel", sb)
	add_child(p)
	var l := Label.new()
	l.text = txt
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 30)
	l.add_theme_color_override("font_color", Color(0.99, 0.95, 0.88))
	p.add_child(l)
	return l


# Premium gold gradient wallet pill
func _pill_gold(txt: String, pos: Vector2, w: float) -> Label:
	var p := Panel.new()
	p.position = pos
	p.size = Vector2(w, 56)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.94, 0.66, 0.12)
	sb.set_corner_radius_all(28)
	sb.set_border_width_all(3)
	sb.border_color = Color(0.50, 0.30, 0.05)
	sb.shadow_size = 10
	sb.shadow_color = Color(0, 0, 0, 0.32)
	sb.shadow_offset = Vector2(0, 5)
	p.add_theme_stylebox_override("panel", sb)
	add_child(p)
	# Top highlight gradient
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 0.96, 0.50, 0.55))
	grad.set_color(1, Color(1.0, 0.96, 0.50, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_LINEAR
	gt.fill_from = Vector2(0.5, 0.0)
	gt.fill_to = Vector2(0.5, 1.0)
	gt.width = 256
	gt.height = 256
	var hl := TextureRect.new()
	hl.texture = gt
	hl.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hl.offset_top = 4.0
	hl.offset_left = 6.0
	hl.offset_right = -6.0
	hl.offset_bottom = 28.0
	hl.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hl.stretch_mode = TextureRect.STRETCH_SCALE
	hl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(hl)
	var l := Label.new()
	l.text = txt
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 30)
	l.add_theme_color_override("font_color", Color(0.20, 0.10, 0.04))
	l.add_theme_color_override("font_outline_color", Color(1.0, 0.95, 0.55, 0.55))
	l.add_theme_constant_override("outline_size", 2)
	p.add_child(l)
	return l


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
