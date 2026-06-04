## GuestSelect — choose who you're cooking for (M1+). Procedural UI, Control root.
##
## Shown after picking a menu (skipped on evaluator levels). Lists selectable guests as
## cards with a placeholder avatar, dynamic taste hint, and friendship (★) from SaveManager.
## "Auto Select" uses the menu's default guest. Picking sets RhythmRound.pending_guest_id.
## English-first; Korean name as cultural subtitle. Ref: docs/phase1/guest-select-ui.md
extends Control

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")

## Set by menu_select before scene change.
static var pending_menu_id: String = "t1_002"

# stable avatar tint per guest
const AVATAR_TINT := {
	"junho": Color(0.86, 0.45, 0.40), "mina": Color(0.95, 0.78, 0.45),
	"riley": Color(0.55, 0.72, 0.85), "mrs_lee": Color(0.70, 0.80, 0.62),
	"seoyeon": Color(0.80, 0.62, 0.85),
}


const MarketBG := preload("res://scripts/ui/market_bg.gd")

func _ready() -> void:
	add_child(MarketBG.new())  # Korean traditional-market backdrop

	var menu: Dictionary = MenuDB.get_menu(pending_menu_id)
	var title := Label.new()
	title.text = "Who are you cooking %s for?" % menu.get("name_en", "this")
	title.position = Vector2(40, 44)
	title.size = Vector2(1000, 70)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 46)
	title.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	add_child(title)

	# Auto Select + Back
	var auto_btn := _bar_button("Auto Select (%s)" % MenuDB.get_guest(String(menu.get("guest_id", ""))).get("name", "default"), 40, Color(0.55, 0.42, 0.2))
	auto_btn.pressed.connect(_on_pick.bind(String(menu.get("guest_id", "junho"))))
	add_child(auto_btn)
	var back_btn := _bar_button("‹ Back", 600, Color(0.5, 0.5, 0.5))
	back_btn.size = Vector2(180, 70)
	back_btn.pressed.connect(_on_back)
	add_child(back_btn)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(40, 220)
	scroll.size = Vector2(1000, 1640)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 30)
	grid.add_theme_constant_override("v_separation", 30)
	scroll.add_child(grid)

	var sm := get_node_or_null("/root/SaveManager")
	for gid in MenuDB.selectable_guest_ids():
		grid.add_child(_make_card(MenuDB.get_guest(gid), sm))


func _bar_button(txt: String, x: float, col: Color) -> Button:
	var b := Button.new()
	b.text = txt
	b.position = Vector2(x, 135)
	b.size = Vector2(540, 70)
	b.add_theme_font_size_override("font_size", 32)
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(20)
	b.add_theme_stylebox_override("normal", sb)
	b.add_theme_color_override("font_color", Color.WHITE)
	return b


func _make_card(guest: Dictionary, sm) -> Control:
	var gid := String(guest.get("id", ""))
	var card := Panel.new()
	card.custom_minimum_size = Vector2(470, 360)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(1.0, 0.99, 0.96)
	sb.set_corner_radius_all(28)
	sb.set_border_width_all(3)
	sb.border_color = Color(0.86, 0.74, 0.55)
	sb.shadow_size = 6
	sb.shadow_color = Color(0, 0, 0, 0.12)
	card.add_theme_stylebox_override("panel", sb)

	# placeholder avatar: tinted circle with initial
	var av := Panel.new()
	av.position = Vector2(175, 24)
	av.size = Vector2(120, 120)
	var avsb := StyleBoxFlat.new()
	avsb.bg_color = AVATAR_TINT.get(gid, Color(0.8, 0.8, 0.8))
	avsb.set_corner_radius_all(60)
	av.add_theme_stylebox_override("panel", avsb)
	card.add_child(av)
	var initial := Label.new()
	var nm := String(guest.get("name", "?"))
	initial.text = nm.substr(0, 1)
	initial.set_anchors_preset(Control.PRESET_FULL_RECT)
	initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	initial.add_theme_font_size_override("font_size", 64)
	initial.add_theme_color_override("font_color", Color.WHITE)
	av.add_child(initial)

	var name_lbl := Label.new()
	name_lbl.text = nm
	name_lbl.position = Vector2(16, 152)
	name_lbl.size = Vector2(438, 40)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 34)
	name_lbl.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	card.add_child(name_lbl)

	var hint := Label.new()
	hint.text = _taste_hint(guest)
	hint.position = Vector2(16, 196)
	hint.size = Vector2(438, 56)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 24)
	hint.add_theme_color_override("font_color", Color(0.45, 0.35, 0.25))
	card.add_child(hint)

	# friendship stars (no numbers)
	var im: float = sm.intimacy_of(gid) if sm else 0.0
	var hearts := Label.new()
	var filled := int(floor(im))
	hearts.text = "Friendship  " + "★".repeat(filled) + "☆".repeat(5 - filled)
	hearts.position = Vector2(16, 250)
	hearts.size = Vector2(438, 36)
	hearts.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hearts.add_theme_font_size_override("font_size", 26)
	hearts.add_theme_color_override("font_color", Color(0.85, 0.55, 0.25))
	card.add_child(hearts)

	var pick := Button.new()
	pick.text = "Cook for %s" % nm
	pick.position = Vector2(16, 296)
	pick.size = Vector2(438, 48)
	pick.add_theme_font_size_override("font_size", 28)
	pick.pressed.connect(_on_pick.bind(gid))
	card.add_child(pick)
	return card


# Dynamic natural-language taste preference from the guest's dominant axis.
func _taste_hint(guest: Dictionary) -> String:
	var vec: Dictionary = guest.get("vec", {})
	var desc := {
		"sweet": "a hint of sweetness", "salty": "clean savory seasoning",
		"spicy": "bold spicy heat", "sour": "a tangy edge", "umami": "deep savory flavor",
	}
	var top_axis := "salty"
	var top_val := -1.0
	for a in vec.keys():
		if float(vec[a]) > top_val:
			top_val = float(vec[a])
			top_axis = a
	var subj := "They prefer"
	if String(guest.get("role", "")) == "mentor":
		subj = "She prefers"
	return "%s %s today." % [subj, desc.get(top_axis, "a balanced taste")]


func _on_pick(guest_id: String) -> void:
	var RoundScript := preload("res://scripts/gameplay/rhythm_proto.gd")
	RoundScript.pending_menu_id = pending_menu_id
	RoundScript.pending_guest_id = guest_id
	get_tree().change_scene_to_file("res://scenes/rhythm_proto.tscn")


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/menu_select.tscn")
