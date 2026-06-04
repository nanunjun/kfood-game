## MenuSelect — data-driven menu grid (M1+). Procedural UI, Control root.
##
## Reads player level/money/stock from SaveManager. Lists all menus; locks those above
## the current level, greys out-of-stock with a Restock button. Picking a menu routes to
## guest select (or straight to the round on evaluator levels). English-first.
## Ref: round-system-v3.md, economy-save-v1.md, guest-select-ui.md
extends Control

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")

var _money_label: Label = null


const MarketBG := preload("res://scripts/ui/market_bg.gd")

func _ready() -> void:
	add_child(MarketBG.new())  # Korean traditional-market backdrop (behind everything)

	var sm := get_node_or_null("/root/SaveManager")
	var lvl: int = sm.level() if sm else 8
	var lv_data: Dictionary = MenuDB.get_level(lvl)

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
	ssb.shadow_size = 10
	ssb.shadow_color = Color(0, 0, 0, 0.28)
	sign.add_theme_stylebox_override("panel", ssb)
	add_child(sign)
	var title := Label.new()
	title.text = "K-Food Master"
	title.position = Vector2(0, 18)
	title.size = Vector2(780, 64)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", Color(0.99, 0.92, 0.78))
	sign.add_child(title)
	var tsub := Label.new()
	tsub.text = "— choose a dish —"
	tsub.position = Vector2(0, 84)
	tsub.size = Vector2(780, 36)
	tsub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tsub.add_theme_font_size_override("font_size", 28)
	tsub.add_theme_color_override("font_color", Color(0.92, 0.78, 0.50))
	sign.add_child(tsub)

	# level + money pills
	_pill("Lv %d · %s" % [lvl, String(lv_data.get("market", "home")).capitalize()],
		Vector2(40, 192), 470, Color(0.55, 0.36, 0.20))
	_money_label = _pill("₩%s" % _commas(sm.money() if sm else 0),
		Vector2(570, 192), 470, Color(0.22, 0.45, 0.24))

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(40, 280)
	scroll.size = Vector2(1000, 1470)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 30)
	grid.add_theme_constant_override("v_separation", 30)
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


# guest avatar tints (match guest_select)
const GUEST_TINT := {
	"junho": Color(0.86, 0.45, 0.40), "mina": Color(0.95, 0.78, 0.45),
	"riley": Color(0.55, 0.72, 0.85), "mrs_lee": Color(0.70, 0.80, 0.62),
	"seoyeon": Color(0.80, 0.62, 0.85), "mystery_diner": Color(0.55, 0.55, 0.62),
	"blogger_daniel": Color(0.62, 0.72, 0.55), "goldspoon": Color(0.85, 0.72, 0.35),
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

	# --- collectible recipe card ---
	var card := Panel.new()
	card.custom_minimum_size = Vector2(470, 500)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.90, 0.88, 0.84) if locked else C_CREAM
	sb.set_corner_radius_all(34)
	sb.set_border_width_all(6)
	sb.border_color = rarity.darkened(0.15) if locked else rarity
	sb.shadow_size = 12
	sb.shadow_color = Color(0, 0, 0, 0.20)
	sb.shadow_offset = Vector2(0, 5)
	card.add_theme_stylebox_override("panel", sb)

	# food "plate" frame (illustration ~60% of card)
	var plate := Panel.new()
	plate.position = Vector2(36, 64)
	plate.size = Vector2(398, 250)
	var psb := StyleBoxFlat.new()
	psb.bg_color = Color(0.90, 0.87, 0.80) if locked else C_PLATE
	psb.set_corner_radius_all(24)
	psb.set_border_width_all(3)
	psb.border_color = Color(0.84, 0.72, 0.52)
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

	# guest portrait chip (top-right) with dominant-taste ring
	var eval_id := String(lv_data.get("evaluator", ""))
	var chip_guest: Dictionary = MenuDB.get_guest(eval_id) if eval_id != "" else guest
	var chip := Panel.new()
	chip.position = Vector2(372, 14)
	chip.size = Vector2(84, 84)
	var csb := StyleBoxFlat.new()
	csb.bg_color = GUEST_TINT.get(String(chip_guest.get("id", "")), Color(0.8, 0.7, 0.6))
	csb.set_corner_radius_all(42)
	csb.set_border_width_all(5)
	csb.border_color = Color(0.62, 0.30, 0.66) if eval_id != "" else _axis_color(_dominant_axis(chip_guest))
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

	# name (EN + KR subtitle)
	var name_lbl := Label.new()
	name_lbl.text = "%s  (%s)" % [menu.get("name_en", "?"), menu.get("name_kr", "")]
	name_lbl.position = Vector2(16, 326)
	name_lbl.size = Vector2(438, 42)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 34)
	name_lbl.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	card.add_child(name_lbl)

	# guest hint line
	var hint := Label.new()
	if eval_id != "":
		hint.text = "★ %s is watching" % chip_guest.get("name", "Evaluator")
		hint.add_theme_color_override("font_color", Color(0.55, 0.30, 0.65))
	else:
		hint.text = "%s: \"%s\"" % [guest.get("name", "Guest"), guest.get("line_enter", "")]
		hint.add_theme_color_override("font_color", Color(0.45, 0.35, 0.25))
	hint.position = Vector2(20, 372)
	hint.size = Vector2(430, 56)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 22)
	card.add_child(hint)

	# footer: Cook (gochujang red) + stock / restock
	var out_of_stock := stock <= 0
	var cook := Button.new()
	cook.text = "Locked" if locked else ("Out of stock" if out_of_stock else "Cook  ·  Stock %d" % stock)
	cook.position = Vector2(20, 434)
	cook.size = Vector2(430, 52)
	cook.add_theme_font_size_override("font_size", 28)
	var bsb := StyleBoxFlat.new()
	bsb.bg_color = Color(0.62, 0.58, 0.52) if (locked or out_of_stock) else C_GOCHU
	bsb.set_corner_radius_all(22)
	cook.add_theme_stylebox_override("normal", bsb)
	var bsbp := bsb.duplicate()
	bsbp.bg_color = bsb.bg_color.lightened(0.12)
	cook.add_theme_stylebox_override("hover", bsbp)
	cook.add_theme_stylebox_override("pressed", bsbp)
	cook.add_theme_stylebox_override("disabled", bsb)
	cook.disabled = locked or out_of_stock
	if not cook.disabled:
		cook.pressed.connect(_on_pick.bind(String(menu.get("id", "t1_002"))))
	card.add_child(cook)

	if out_of_stock and not locked:
		cook.size = Vector2(244, 52)
		var restock := Button.new()
		restock.text = "Restock ₩%s" % _commas(2000)
		restock.position = Vector2(272, 434)
		restock.size = Vector2(178, 52)
		restock.add_theme_font_size_override("font_size", 24)
		var rsb := StyleBoxFlat.new()
		rsb.bg_color = Color(0.30, 0.55, 0.35)  # jade green
		rsb.set_corner_radius_all(22)
		restock.add_theme_stylebox_override("normal", rsb)
		restock.pressed.connect(_on_restock.bind(String(menu.get("id", ""))))
		card.add_child(restock)

	return card


func _on_pick(menu_id: String) -> void:
	var RoundScript := preload("res://scripts/gameplay/rhythm_proto.gd")
	RoundScript.pending_menu_id = menu_id
	RoundScript.pending_guest_id = ""
	var menu: Dictionary = MenuDB.get_menu(menu_id)
	var lv_data: Dictionary = MenuDB.get_level(int(menu.get("unlock_level", 1)))
	# evaluator levels skip guest selection
	if String(lv_data.get("evaluator", "")) != "":
		get_tree().change_scene_to_file("res://scenes/rhythm_proto.tscn")
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
	sb.shadow_size = 5
	sb.shadow_color = Color(0, 0, 0, 0.2)
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
