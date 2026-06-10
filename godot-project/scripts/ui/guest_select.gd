## GuestSelect v2 — Guest System 2.0 strategic selection screen.
##
## Shown after picking a menu (skipped on evaluator levels). Renders each selectable
## guest as a GuestCardV2 with:
##   - compat % (computed by CompatCalc against today's mood)
##   - mood-of-the-day badge (MoodSystem deterministic per date+id)
##   - flavor like/avoid badges
##   - reward bonus band (RewardCalc)
##   - friendship stars (SaveManager v2 friendship_of)
##
## The best card auto-pulses a "RECOMMENDED" ribbon. Picking sets
## RhythmRound.pending_guest_id and routes to the round.
extends Control

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const MarketBG := preload("res://scripts/ui/market_bg.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")
const GuestCardV2Script := preload("res://scripts/ui/components/guest_card_v2.gd")

## Set by menu_select before scene change.
static var pending_menu_id: String = "m_kimchi_jjigae"


func _ready() -> void:
	var menu: Dictionary = MenuDB.get_menu(pending_menu_id)
	if menu.is_empty():
		menu = MenuDB.get_menu("t1_002")

	# World-integration (2026-06-08): flat 베이지 procedural MarketBG → 실제 한식 주방 환경 art.
	# menu→cooking 흐름 전체가 같은 따뜻한 world를 공유 (이 화면만 beige void면 일관성 깨짐).
	# 음식의 unlock level→market→L1/L3/L5 BG. scrim 0.16 = 카드 가독성용 얇은 막.
	var gs_lvl: int = int(menu.get("unlock_level", 1))
	var gs_lv_data: Dictionary = MenuDB.get_level(gs_lvl)
	var bg = KitchenBackgroundScript.new()
	bg.fill_screen = true
	bg.dish_anchor_y = 700.0
	bg.scrim_alpha = 0.16
	bg.env_key = KitchenBackgroundScript.env_key_for_market(String(gs_lv_data.get("market", "home")))
	add_child(bg)

	# --- title ---
	var title := Label.new()
	title.text = "Who will love your %s?" % menu.get("name_en", "dish")
	title.position = Vector2(40, 36)
	title.size = Vector2(1000, 72)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	add_child(title)
	var sub := Label.new()
	sub.text = "Compatibility = food flavor tags vs guest preferences (mood matters today)."
	sub.position = Vector2(40, 110)
	sub.size = Vector2(1000, 36)
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.add_theme_font_size_override("font_size", 22)
	sub.add_theme_color_override("font_color", Color(0.45, 0.35, 0.25))
	add_child(sub)

	# --- compute compat + mood for all selectable guests ---
	var rows: Array = []  # [{guest, compat, mood}]
	var best_idx: int = -1
	var best_score: int = -1
	var compat_sys := get_node_or_null("/root/CompatCalc")
	var mood_sys := get_node_or_null("/root/MoodSystem")
	for gid in MenuDB.selectable_guest_ids():
		var guest: Dictionary = MenuDB.get_guest(gid)
		var mood: String = mood_sys.today(gid) if mood_sys else "easy"
		var c: int = compat_sys.score(menu, guest, mood) if compat_sys else 50
		rows.append({"guest": guest, "compat": c, "mood": mood})
		if c > best_score:
			best_score = c
			best_idx = rows.size() - 1

	# sort by compat desc so best stays near top
	rows.sort_custom(func(a, b): return int(a["compat"]) > int(b["compat"]))
	# recompute best_idx after sort
	best_idx = -1
	for i in range(rows.size()):
		if int(rows[i]["compat"]) == best_score:
			best_idx = i
			break

	# --- top action bar ---
	var auto_btn := _bar_button("Auto: %s" % MenuDB.get_guest(String(menu.get("guest_id", ""))).get("name", "default"), 40)
	auto_btn.pressed.connect(_on_pick.bind(String(menu.get("guest_id", "junho"))))
	add_child(auto_btn)
	var back_btn := _bar_button("<  Back", 820, true)
	back_btn.size = Vector2(220, 64)
	back_btn.pressed.connect(_on_back)
	add_child(back_btn)

	# --- scrollable grid (2 columns of 510x680 cards) ---
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(20, 240)
	scroll.size = Vector2(1040, 1620)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 50)
	scroll.add_child(grid)

	for i in range(rows.size()):
		var entry: Dictionary = rows[i]
		var card: GuestCardV2 = GuestCardV2Script.new()
		grid.add_child(card)
		card.setup(entry["guest"], menu, int(entry["compat"]), String(entry["mood"]))
		card.picked.connect(_on_pick)
		if i == best_idx:
			card.set_recommended(true)


func _bar_button(txt: String, x: float, neutral: bool = false) -> Button:
	var b := Button.new()
	b.text = txt
	b.position = Vector2(x, 160)
	b.size = Vector2(760 if not neutral else 220, 64)
	b.add_theme_font_size_override("font_size", 26)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.5, 0.5, 0.5) if neutral else Color(0.55, 0.42, 0.20)
	sb.set_corner_radius_all(18)
	b.add_theme_stylebox_override("normal", sb)
	b.add_theme_color_override("font_color", Color.WHITE)
	return b


func _on_pick(guest_id: String) -> void:
	# Cooking Framework 2.0 — route to the new module runner scene.
	var RunnerScript := preload("res://scripts/gameplay/cooking_module_runner.gd")
	RunnerScript.pending_menu_id = pending_menu_id
	RunnerScript.pending_guest_id = guest_id
	get_tree().change_scene_to_file("res://scenes/cooking_module_runner.tscn")


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/menu_select.tscn")
