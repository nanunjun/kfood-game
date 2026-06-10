## MenuSelect — Korean Recipe Board (presentation redesign v2).
##
## RECIPE BOARD REBUILD v2 (presentation-only — P2 Menu Select Rebuild):
##   The first pass used recipe-board *words* but kept a product-catalog *layout*
##   (uniform tile grid + full-width filled CTA bar = "Add to Cart"). Players still
##   read it as online shopping. v2 changes the VISUAL GRAMMAR to a Korean cooking
##   journal / hand-pinned recipe board, NOT a store:
##     - Cards are warm cream "recipe-card / index-card" entries taped to a board
##       (washi-tape corners + gentle tilt + torn paper feel), not glossy product tiles.
##     - The filled CTA button bar is GONE. The WHOLE card is the tappable recipe; the
##       footer is a quiet "Start Cooking →" recipe-action cue (ink on paper), not a
##       buy button. Out-of-stock shows "Ingredients Needed" + a small "Visit Market"
##       link; locked shows a "Discover at Lv N" recipe stamp on a faded card.
##     - Module sequence reads as NUMBERED RECIPE STEPS "① Slice → ② Roll → ③ Plate".
##     - "Today's Special" is a warm chalkboard menu plaque (not a dark deal banner).
##     - Wallet is a tiny muted coin chip in the corner (money never dominates).
##   Each recipe card shows: dish image, EN + KR name, numbered cooking-step row
##   (dish_modules.csv), difficulty (Lv chip), best-guest mini avatar, and a "Learn: …"
##   discovery tag (learning_facts.csv — static display, NO new learning system).
##
## GAMEPLAY-CRITICAL (UNCHANGED): data flow, _on_pick, _on_restock, _compute_today_pick,
##   _wire_* buttons, and every SaveManager call (level/money/stock_of/restock/
##   consume_levelup_notice). economy / inventory / save / dish-unlock / scoring untouched.
## Ref: round-system-v3.md, economy-save-v1.md, guest-select-ui.md, learning-layer-v1.md
extends Control

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")

const MarketBG := preload("res://scripts/ui/market_bg.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")
const DropShadowScript := preload("res://scripts/ui/premium/drop_shadow_panel.gd")
const GlossyButtonScript := preload("res://scripts/ui/premium/glossy_button.gd")
const SparkleScript := preload("res://scripts/ui/premium/sparkle_particle.gd")

var _money_label: Label = null
var _best_pick_id: String = ""
var _best_pick_compat: int = 0

# learning_facts.csv -> food_id -> {food_fact, ingredient_fact, cooking_tip, culture_fact}
var _learning: Dictionary = {}

# Short, memorable "Learn:" skill tags per dish (signature skill the player practices).
# Falls back to a trimmed cooking_tip from learning_facts.csv when a dish isn't curated.
const LEARN_TAGS := {
	"t1_002": "Learn: broth timing",
	"t1_003": "Learn: sauce glaze",
	"t1_004": "Learn: rolling pressure",
	"t1_008": "Learn: clean broth",
	"m_kimchi_jjigae": "Learn: deep simmer",
	"t2_008": "Learn: color balance",
	"m_doenjang_jjigae": "Learn: paste balance",
	"t2_010": "Learn: noodle toss",
	"t2_014": "Learn: marinade press",
	"t1_006": "Learn: crisp-edge flip",
	"m_maeuntang": "Learn: spicy broth",
	"t2_013": "Learn: silky-tofu heat",
}

# Friendly short labels for the 8 cooking modules (recipe-step row).
# Rendered as numbered recipe steps "① Slice → ② Roll → ③ Plate" (icon-first, English minimal).
const MODULE_LABEL := {
	"slice": "Slice", "arrange": "Arrange", "stir": "Stir", "flip": "Flip",
	"timing": "Cook", "season": "Season", "roll": "Roll", "plate": "Plate",
}

# Circled step numerals for the recipe-step row (recipe identity signal — "follow the steps").
const STEP_NUMERALS := ["①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧"]


func _ready() -> void:
	var sm := get_node_or_null("/root/SaveManager")

	# Player-Chef Integration (2026-06-08): 최초 1회 gender select 게이트. 저장된 셰프 성별이
	# 없으면(미선택) 메뉴 대신 gender select 화면으로 redirect. 선택 후 다시 메뉴로 진입한다.
	# scoring/economy 무관 — visual 진입 게이트. 기존 save는 _merge로 backward-compatible.
	if sm and sm.has_method("has_chosen_chef") and not sm.has_chosen_chef():
		call_deferred("_redirect_to_gender_select")
		return
	# Player-Name Personalization (2026-06-08): 성별은 골랐지만 이름 미입력이면 name entry로.
	# legacy save(player_name 없음 → "")는 _merge로 default "" 로드되어 여기서 name entry 1회 진입.
	if sm and sm.has_method("has_player_name") and not sm.has_player_name():
		call_deferred("_redirect_to_name_entry")
		return

	_load_learning_facts()

	var lvl: int = sm.level() if sm else 8
	var lv_data: Dictionary = MenuDB.get_level(lvl)

	# World-integration (2026-06-08): flat 베이지 procedural MarketBG → 실제 한식 주방 환경 art.
	# 플레이어 level의 market(home/noryangjin/market/gwangjang)에 맞는 L1/L3/L5 BG를 화면 전체에
	# 깔아 카드가 "따뜻한 한식 주방 world" 위에 얹히게 한다 (product-catalog beige void 박멸).
	var bg = KitchenBackgroundScript.new()
	bg.fill_screen = true
	bg.dish_anchor_y = 700.0
	bg.scrim_alpha = 0.14  # 가벼운 막 — 카드는 불투명이라 world가 또렷이, 텍스트 가독성도 유지
	bg.env_key = KitchenBackgroundScript.env_key_for_market(String(lv_data.get("market", "home")))
	add_child(bg)

	# Recipe-board surface: a warm wood "corkboard / menu board" panel that the recipe
	# cards are pinned onto. This is the single biggest anti-shopping cue — cards no
	# longer float on a void grid, they live on a tactile Korean kitchen board.
	_build_board_surface()

	# Pre-compute today's best pick (highest compat among unlocked + ready menus)
	_compute_today_pick(lvl)

	# hanging wooden signboard — reads as a hand-burned recipe-board header (한식 간판)
	for rope_x in [296.0, 784.0]:
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
	# 작은 솥/숟가락 글리프로 "요리" 정체성 (한식 signal) — 제목 양옆
	var glyph_l := Label.new()
	glyph_l.text = "🍲"
	glyph_l.position = Vector2(40, 30)
	glyph_l.size = Vector2(60, 60)
	glyph_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_l.add_theme_font_size_override("font_size", 44)
	glyph_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sign.add_child(glyph_l)
	var glyph_r := Label.new()
	glyph_r.text = "🥢"
	glyph_r.position = Vector2(680, 30)
	glyph_r.size = Vector2(60, 60)
	glyph_r.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_r.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_r.add_theme_font_size_override("font_size", 44)
	glyph_r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sign.add_child(glyph_r)
	var title := Label.new()
	title.text = "Today's Cooking"
	title.position = Vector2(0, 14)
	title.size = Vector2(780, 60)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 50)
	title.add_theme_color_override("font_color", Color(0.99, 0.92, 0.78))
	title.add_theme_color_override("font_outline_color", Color(0.20, 0.10, 0.04))
	title.add_theme_constant_override("outline_size", 3)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sign.add_child(title)
	var tsub := Label.new()
	tsub.text = "Which Korean dish will you make?"
	tsub.position = Vector2(0, 82)
	tsub.size = Vector2(780, 38)
	tsub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tsub.add_theme_font_size_override("font_size", 27)
	tsub.add_theme_color_override("font_color", Color(0.92, 0.78, 0.50))
	tsub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sign.add_child(tsub)

	# Player-Chef host (2026-06-08): 선택한 셰프(neutral)를 헤더 우측에 작게 배치 — "요리하는 나".
	# 손님(먹는 쪽, character/) avatar와 역할 분리. world BG 위 layer. visual only.
	var chef_caption: String = "Your Chef"
	if sm and sm.has_method("player_name_display"):
		chef_caption = sm.player_name_display()
	_add_chef_host_badge(sm, "neutral", Vector2(896, 24), 156.0,
		chef_caption, Color(0.85, 0.66, 0.28))

	# level pill (kitchen / market context) + de-emphasized wallet (small, corner).
	_pill("Lv %d · %s Kitchen" % [lvl, String(lv_data.get("market", "home")).capitalize()],
		Vector2(40, 192), 560, Color(0.55, 0.36, 0.20))
	# Wallet is a small muted coin chip in the top-right — not a dominant element.
	_money_label = _wallet_chip("₩%s" % _commas(sm.money() if sm else 0),
		Vector2(820, 196), 220)
	_money_label.name = "WalletMoneyLabel"  # discoverable for coin spray HUD link

	# Today's Special — a warm chalkboard menu plaque above the grid (no card overlap).
	var grid_top: float = 280.0
	if _best_pick_id != "":
		_add_today_feature_card(Vector2(40, 268), sm)
		grid_top = 268.0 + 190.0 + 26.0

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(40, grid_top)
	scroll.size = Vector2(1000, 1920 - grid_top - 30)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 34)
	grid.add_theme_constant_override("v_separation", 40)
	scroll.add_child(grid)

	# Alternate the card tilt (left cards lean left, right cards lean right) so the board
	# reads as hand-pinned recipe cards, not a rigid product grid.
	var col_idx := 0
	for id in MenuDB.all_menu_ids():
		var menu: Dictionary = MenuDB.get_menu(id)
		var locked: bool = int(menu.get("unlock_level", 1)) > lvl
		var tilt: float = -1.4 if (col_idx % 2 == 0) else 1.4
		grid.add_child(_make_card(menu, locked, sm, tilt))
		col_idx += 1

	# level-up toast
	if sm and sm.has_method("consume_levelup_notice"):
		var nl: int = sm.consume_levelup_notice()
		if nl > 0:
			_levelup_toast(nl)


# Warm wood "menu board" surface behind the cards. Cards are pinned onto this rather
# than floating on a beige void — the core anti-ecommerce cue.
func _build_board_surface() -> void:
	var board := Panel.new()
	board.position = Vector2(20, 250)
	board.size = Vector2(1040, 1640)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.30, 0.21, 0.13, 0.80)  # warm wood, semi so kitchen world shows through edges
	sb.set_corner_radius_all(30)
	sb.set_border_width_all(8)
	sb.border_color = Color(0.46, 0.31, 0.18, 0.92)  # darker frame = wooden board frame
	sb.shadow_size = 16
	sb.shadow_color = Color(0, 0, 0, 0.30)
	sb.shadow_offset = Vector2(0, 8)
	board.add_theme_stylebox_override("panel", sb)
	board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(board)
	# subtle inner lighter panel (paper-lining the board, warm)
	var liner := Panel.new()
	liner.position = Vector2(14, 14)
	liner.size = Vector2(1012, 1612)
	var lsb := StyleBoxFlat.new()
	lsb.bg_color = Color(0.40, 0.29, 0.18, 0.35)
	lsb.set_corner_radius_all(22)
	liner.add_theme_stylebox_override("panel", lsb)
	liner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board.add_child(liner)


func _load_learning_facts() -> void:
	# Presentation-only: read learning_facts.csv for the "Learn:" discovery tags.
	# Does NOT touch MenuDB/scoring — failure is silently tolerated (fallback tags exist).
	var path := "res://data/learning_facts.csv"
	if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return
	var header := f.get_csv_line(",")
	var idx: Dictionary = {}
	for i in range(header.size()):
		idx[String(header[i]).strip_edges()] = i
	while not f.eof_reached():
		var row := f.get_csv_line(",")
		if not idx.has("food_id"):
			break
		var fid_i: int = int(idx["food_id"])
		if fid_i >= row.size():
			continue
		var fid := String(row[fid_i]).strip_edges()
		if fid == "":
			continue
		var rec: Dictionary = {}
		for key in ["food_fact", "ingredient_fact", "cooking_tip", "culture_fact"]:
			if idx.has(key):
				var ci: int = int(idx[key])
				rec[key] = String(row[ci]).strip_edges() if ci < row.size() else ""
		_learning[fid] = rec
	f.close()


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
const C_PAPER := Color(0.98, 0.95, 0.87)  # recipe-card paper (warm off-white)
const C_PLATE := Color(0.96, 0.92, 0.84)
const C_WOOD := Color(0.40, 0.27, 0.16)
const C_INK := Color(0.30, 0.20, 0.12)   # hand-written ink tone for recipe text
# "Start Cooking" CTA — warm wood/persimmon, reads as a recipe action (not a buy button)
const C_COOK := Color(0.86, 0.46, 0.20)

func _rarity_color(lvl: int) -> Color:
	if lvl >= 6: return Color(0.92, 0.72, 0.28)   # gold
	elif lvl >= 3: return Color(0.74, 0.78, 0.84)  # silver
	return Color(0.80, 0.55, 0.32)                 # bronze


func _learn_tag(menu: Dictionary) -> String:
	var fid := String(menu.get("id", ""))
	if LEARN_TAGS.has(fid):
		return LEARN_TAGS[fid]
	# fallback: shorten the cooking_tip from learning_facts.csv into a Learn: phrase
	var rec: Dictionary = _learning.get(fid, {})
	var tip := String(rec.get("cooking_tip", ""))
	if tip != "":
		var words: PackedStringArray = tip.split(" ", false)
		var short_tip := ""
		for w in words:
			if short_tip.length() + w.length() + 1 > 22:
				break
			short_tip += (" " if short_tip != "" else "") + w
		return "Learn: " + short_tip.to_lower()
	return ""


# Numbered recipe-step row: "① Slice → ② Roll → ③ Slice → ④ Plate".
# Reads as a recipe to FOLLOW (cooking journal), not product attributes.
func _make_module_row(menu: Dictionary, locked: bool) -> Control:
	var seq: Array = MenuDB.module_sequence(String(menu.get("id", "")))
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var parts: Array = []
	for i in range(seq.size()):
		var num: String = STEP_NUMERALS[i] if i < STEP_NUMERALS.size() else str(i + 1)
		parts.append("%s %s" % [num, String(MODULE_LABEL.get(String(seq[i]), String(seq[i]).capitalize()))])
	var txt := Label.new()
	txt.text = "  →  ".join(parts)
	txt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	txt.add_theme_font_size_override("font_size", 18)
	txt.add_theme_color_override("font_color",
		Color(0.48, 0.36, 0.24) if not locked else Color(0.55, 0.50, 0.44))
	txt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(txt)
	return box


func _make_card(menu: Dictionary, locked: bool, sm, tilt: float = 0.0) -> Control:
	var lvl := int(menu.get("unlock_level", 1))
	var lv_data: Dictionary = MenuDB.get_level(lvl)
	var stock: int = sm.stock_of(String(menu.get("id", ""))) if sm else 3
	var guest: Dictionary = MenuDB.get_guest(String(menu.get("guest_id", "")))
	var rarity := _rarity_color(lvl)
	var is_today_pick: bool = (String(menu.get("id", "")) == _best_pick_id) and not locked

	# --- recipe-card holder (gives room for tilt + washi tape without clipping siblings) ---
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(470, 540)

	# --- warm paper recipe card (pinned to the board) ---
	var card := Panel.new()
	card.position = Vector2(0, 16)  # leave headroom for the washi tape at the very top
	card.size = Vector2(470, 516)
	card.pivot_offset = Vector2(235, 258)
	card.rotation_degrees = tilt
	var card_bg: Color = Color(0.93, 0.90, 0.84) if locked else C_PAPER
	if is_today_pick:
		card_bg = Color(1.0, 0.98, 0.90)  # gentle warm tint for the recommended recipe
	var csb := StyleBoxFlat.new()
	csb.bg_color = card_bg
	csb.set_corner_radius_all(20)  # softer corners = paper card, not sharp product tile
	csb.set_border_width_all(2)
	csb.border_color = Color(0.80, 0.68, 0.50, 0.75) if not locked else Color(0.70, 0.64, 0.56, 0.6)
	csb.shadow_size = 12  # floating shadow (global rule #2)
	csb.shadow_color = Color(0, 0, 0, 0.26)
	csb.shadow_offset = Vector2(0, 7)
	card.add_theme_stylebox_override("panel", csb)
	holder.add_child(card)

	# washi tape strips at top corners — "pinned recipe note" cue (anti product-tile).
	if not locked:
		_add_washi_tape(card, Vector2(40, -14), -14.0, Color(0.92, 0.78, 0.42, 0.85))
		_add_washi_tape(card, Vector2(360, -14), 12.0, Color(0.82, 0.86, 0.62, 0.85))
	else:
		_add_washi_tape(card, Vector2(200, -14), 4.0, Color(0.74, 0.70, 0.62, 0.7))

	# food "plate" frame (illustration ~45% of card)
	var plate := Panel.new()
	plate.position = Vector2(36, 60)
	plate.size = Vector2(398, 224)
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
		gt.height = 214
		var glow := TextureRect.new()
		glow.texture = gt
		glow.position = Vector2(19, 5)
		glow.size = Vector2(360, 214)
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		plate.add_child(glow)
	# the dish
	var thumb := TextureRect.new()
	thumb.position = Vector2(24, 10)
	thumb.size = Vector2(350, 204)
	thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if bool(menu.get("ready", false)):
		var tex: Texture2D = load(String(menu.get("food_img", "")))
		if tex != null:
			thumb.texture = tex
	if locked:
		thumb.modulate = Color(0.62, 0.60, 0.56, 0.55)  # faded recipe (discovery), not greyed product
	plate.add_child(thumb)
	if thumb.texture == null:
		# warm 한식 그릇 placeholder (베이지 void/raw 텍스트 회피) — "곧 나올 따뜻한 요리".
		_build_warm_dish_placeholder(plate, String(menu.get("name_en", "?")), locked)

	# difficulty chip (top-left) — reads as recipe difficulty, not a price/rarity tag
	var tag := Panel.new()
	tag.position = Vector2(16, 14)
	tag.size = Vector2(118, 44)
	var tsb := StyleBoxFlat.new()
	tsb.bg_color = rarity
	tsb.set_corner_radius_all(14)
	tsb.shadow_size = 6
	tsb.shadow_color = Color(0, 0, 0, 0.22)
	tag.add_theme_stylebox_override("panel", tsb)
	card.add_child(tag)
	var tagl := Label.new()
	tagl.text = "Lv %d" % lvl
	tagl.set_anchors_preset(Control.PRESET_FULL_RECT)
	tagl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tagl.add_theme_font_size_override("font_size", 24)
	tagl.add_theme_color_override("font_color", Color(0.2, 0.13, 0.07))
	tag.add_child(tagl)

	# tiny servings dot (top-left, under difficulty) — secondary, recipe-y ("makes ×N").
	if not locked:
		_add_stock_dot(card, stock)

	# top-right mini-badge: evaluator OR Guest System 2.0 "best match" chip
	var eval_id := String(lv_data.get("evaluator", ""))
	if eval_id != "":
		# evaluator levels: keep the original purple-ring chip
		var chip_guest: Dictionary = MenuDB.get_guest(eval_id)
		var chip := Panel.new()
		chip.position = Vector2(372, 12)
		chip.size = Vector2(84, 84)
		var csb2 := StyleBoxFlat.new()
		csb2.bg_color = GUEST_TINT.get(eval_id, Color(0.8, 0.7, 0.6))
		csb2.set_corner_radius_all(42)
		csb2.set_border_width_all(5)
		csb2.border_color = Color(0.62, 0.30, 0.66)
		csb2.shadow_size = 8
		csb2.shadow_color = Color(0, 0, 0, 0.30)
		chip.add_theme_stylebox_override("panel", csb2)
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

	# name (EN + KR subtitle) — hand-written recipe title feel
	var name_lbl := Label.new()
	name_lbl.text = "%s  (%s)" % [menu.get("name_en", "?"), menu.get("name_kr", "")]
	name_lbl.position = Vector2(16, 298)
	name_lbl.size = Vector2(438, 40)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 32)
	name_lbl.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	card.add_child(name_lbl)

	# thin ink rule under the title (recipe-card divider)
	var rule := ColorRect.new()
	rule.color = Color(0.62, 0.48, 0.32, 0.45)
	rule.position = Vector2(60, 342)
	rule.size = Vector2(350, 2)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(rule)

	# numbered recipe-step row (① Slice → ② Roll → ③ Plate)
	var mod_row := _make_module_row(menu, locked)
	var mod_wrap := CenterContainer.new()
	mod_wrap.position = Vector2(16, 352)
	mod_wrap.size = Vector2(438, 28)
	mod_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mod_wrap.add_child(mod_row)
	mod_row.position = Vector2.ZERO
	card.add_child(mod_wrap)

	# learning discovery tag ("Learn: rolling pressure") OR evaluator hint line
	var hint := Label.new()
	if eval_id != "":
		var eval_guest: Dictionary = MenuDB.get_guest(eval_id)
		hint.text = "★ %s is watching" % eval_guest.get("name", "Evaluator")
		hint.add_theme_color_override("font_color", Color(0.55, 0.30, 0.65))
	else:
		var lt := _learn_tag(menu)
		hint.text = lt if lt != "" else "%s: \"%s\"" % [guest.get("name", "Guest"), guest.get("line_enter", "")]
		hint.add_theme_color_override("font_color", Color(0.42, 0.52, 0.38))  # learning green
	hint.position = Vector2(20, 388)
	hint.size = Vector2(430, 36)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 22)
	card.add_child(hint)

	# footer recipe-action cue — NOT a filled buy-button bar. Quiet ink-on-paper line,
	# the WHOLE card is the press target (recipe-journal "begin" feel).
	var out_of_stock := stock <= 0
	_add_recipe_footer(card, locked, out_of_stock, lvl)

	# Whole-card press target (transparent overlay button) — cook routes to runner.
	# Disabled when locked/out so the gameplay/economy gating is byte-identical.
	var hit := Button.new()
	hit.position = Vector2(0, 0)
	hit.size = card.size
	hit.flat = true
	hit.focus_mode = Control.FOCUS_NONE
	hit.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	hit.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	hit.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	hit.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	hit.add_theme_stylebox_override("disabled", StyleBoxEmpty.new())
	card.add_child(hit)
	_wire_card_button(hit, card, String(menu.get("id", "t1_002")), locked or out_of_stock)

	# Out of stock (not locked): small "Visit Market" link in the footer-right corner.
	if out_of_stock and not locked:
		var market := Button.new()
		market.position = Vector2(266, 452)
		market.size = Vector2(186, 52)
		market.flat = true
		market.text = "Visit Market →"
		market.focus_mode = Control.FOCUS_NONE
		market.add_theme_font_size_override("font_size", 21)
		market.add_theme_color_override("font_color", Color(0.40, 0.52, 0.34))
		market.add_theme_color_override("font_color_hover", Color(0.32, 0.46, 0.28))
		market.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		market.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
		market.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
		market.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		card.add_child(market)
		_wire_restock_button_btn(market, String(menu.get("id", "")))

	# Locked = recipe DISCOVERY: faded card + lock stamp ("Discover at Lv N").
	if locked:
		_add_discovery_stamp(card, lvl)

	# TODAY'S PICK: the recommendation lives ONLY in the top "Today's Special" chalkboard
	# plaque (spec: pick ONE — featured panel OR in-card stamp). We avoid an in-card stamp
	# here to keep zero card overlap; the card just gets a subtle warm border/tint above.
	if is_today_pick:
		_mark_today_pick_corner(card)

	return holder


# Washi-tape strip — a small tilted translucent rectangle that reads as tape pinning a
# recipe note to the board. Pure decoration (anti product-tile cue).
func _add_washi_tape(card: Panel, pos: Vector2, deg: float, col: Color) -> void:
	var tape := Panel.new()
	tape.size = Vector2(96, 34)
	tape.pivot_offset = Vector2(48, 17)
	tape.position = pos
	tape.rotation_degrees = deg
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(3)
	tape.add_theme_stylebox_override("panel", sb)
	tape.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(tape)
	# faint diagonal sheen on the tape
	var sheen := ColorRect.new()
	sheen.color = Color(1, 1, 1, 0.18)
	sheen.position = Vector2(0, 6)
	sheen.size = Vector2(96, 8)
	sheen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tape.add_child(sheen)


# Footer recipe-action cue (replaces the filled CTA button bar). Ink-on-paper line that
# tells the player what tapping the card does — never an "Add to Cart" bar.
func _add_recipe_footer(card: Panel, locked: bool, out_of_stock: bool, lvl: int) -> void:
	# thin ink rule above the footer
	var rule := ColorRect.new()
	rule.color = Color(0.62, 0.48, 0.32, 0.40)
	rule.position = Vector2(36, 440)
	rule.size = Vector2(398, 2)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(rule)

	var label := Label.new()
	var col: Color
	if locked:
		label.text = "Discover at Lv %d" % lvl
		col = Color(0.55, 0.42, 0.28)
	elif out_of_stock:
		label.text = "Ingredients Needed"
		col = Color(0.68, 0.42, 0.30)
	else:
		label.text = "Start Cooking  →"
		col = C_COOK
	# when stocked, left-aligned cooking cue (Visit-Market link sits on the right when OOS)
	label.position = Vector2(36, 452)
	label.size = Vector2(398 if not out_of_stock else 220, 52)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if not out_of_stock else HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 27)
	label.add_theme_color_override("font_color", col)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if out_of_stock:
		label.position = Vector2(36, 452)
		label.size = Vector2(220, 52)
		label.add_theme_font_size_override("font_size", 23)
	card.add_child(label)


# Warm "dish-on-the-way" placeholder (food art 미존재 시). 베이지 void/raw 텍스트 대신
# 따뜻한 한식 그릇(받침 + 솥 몸통 + 뚜껑 + 김) 일러스트 자리. plate(398x224) 기준 좌표.
func _build_warm_dish_placeholder(plate: Panel, name_en: String, locked: bool) -> void:
	var cx: float = 199.0   # plate width 398 / 2
	var cy: float = 124.0   # 살짝 아래로 (위에 김 공간)
	var tint: float = 0.55 if locked else 1.0
	# 받침 그림자
	var saucer := Polygon2D.new()
	saucer.polygon = PackedVector2Array([
		Vector2(cx - 110, cy + 50), Vector2(cx + 110, cy + 50),
		Vector2(cx + 86, cy + 70), Vector2(cx - 86, cy + 70)])
	saucer.color = Color(0.86, 0.74, 0.54, 0.9 * tint)
	plate.add_child(saucer)
	# 솥 몸통 (둥근 검정 무쇠솥)
	var body := Panel.new()
	body.position = Vector2(cx - 92, cy - 16)
	body.size = Vector2(184, 76)
	var bsb := StyleBoxFlat.new()
	bsb.bg_color = Color(0.28, 0.22, 0.20, tint)
	bsb.set_corner_radius_all(38)
	bsb.set_border_width_all(4)
	bsb.border_color = Color(0.18, 0.14, 0.12, tint)
	body.add_theme_stylebox_override("panel", bsb)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(body)
	# 뚜껑 (warm 나무 톤 돔)
	var lid := Panel.new()
	lid.position = Vector2(cx - 100, cy - 40)
	lid.size = Vector2(200, 40)
	var lsb := StyleBoxFlat.new()
	lsb.bg_color = Color(0.80, 0.55, 0.32, tint)
	lsb.set_corner_radius_all(20)
	lsb.set_border_width_all(3)
	lsb.border_color = Color(0.55, 0.35, 0.18, tint)
	lid.add_theme_stylebox_override("panel", lsb)
	lid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(lid)
	# 뚜껑 손잡이
	var knob := Panel.new()
	knob.position = Vector2(cx - 12, cy - 56)
	knob.size = Vector2(24, 20)
	var ksb := StyleBoxFlat.new()
	ksb.bg_color = Color(0.62, 0.40, 0.22, tint)
	ksb.set_corner_radius_all(10)
	knob.add_theme_stylebox_override("panel", ksb)
	knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(knob)
	# 김 (steam) — 곧 나올 따뜻한 요리 hint
	if not locked:
		for sx in [cx - 36.0, cx, cx + 36.0]:
			var steam := Label.new()
			steam.text = "≀"
			steam.position = Vector2(sx - 12, cy - 96)
			steam.size = Vector2(24, 44)
			steam.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			steam.add_theme_font_size_override("font_size", 34)
			steam.add_theme_color_override("font_color", Color(0.80, 0.66, 0.46, 0.55))
			steam.mouse_filter = Control.MOUSE_FILTER_IGNORE
			plate.add_child(steam)
	# 작은 캡션 (이름 + 따뜻한 안내)
	var cap := Label.new()
	cap.text = "%s\nsimmering soon" % name_en
	cap.position = Vector2(0, 170)
	cap.size = Vector2(398, 50)
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cap.add_theme_font_size_override("font_size", 19)
	cap.add_theme_color_override("font_color", Color(0.50, 0.38, 0.26, 0.95 * tint))
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(cap)


# Tiny secondary servings indicator: "makes ×N" dot, easily ignored (no ecommerce feel).
func _add_stock_dot(card: Panel, stock: int) -> void:
	var dot := Panel.new()
	dot.position = Vector2(16, 64)
	dot.size = Vector2(118, 26)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.0, 0.0, 0.0, 0.16)
	sb.set_corner_radius_all(13)
	dot.add_theme_stylebox_override("panel", sb)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(dot)
	var l := Label.new()
	l.text = "makes ×%d" % stock
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 16)
	l.add_theme_color_override("font_color", Color(1, 1, 1, 0.80))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dot.add_child(l)


# Tiny non-overlapping "today's pick" corner marker. A small folded-corner star ribbon
# pinned to the card's bottom-right, clear of the title / steps / footer text. The full
# recommendation copy lives in the top "Today's Special" chalkboard plaque (single source).
func _mark_today_pick_corner(card: Panel) -> void:
	var ribbon := Panel.new()
	ribbon.size = Vector2(150, 34)
	ribbon.position = Vector2(card.size.x - 168.0, card.size.y - 130.0)
	ribbon.pivot_offset = Vector2(75, 17)
	ribbon.rotation_degrees = -4.0  # hand-pinned little flag
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.86, 0.30, 0.22, 0.95)  # persimmon ink flag
	sb.set_corner_radius_all(6)
	sb.shadow_size = 5
	sb.shadow_color = Color(0, 0, 0, 0.22)
	ribbon.add_theme_stylebox_override("panel", sb)
	ribbon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(ribbon)
	var l := Label.new()
	l.text = "★ Today's pick"
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 18)
	l.add_theme_color_override("font_color", Color(0.99, 0.95, 0.86))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ribbon.add_child(l)


# Recipe discovery stamp (replaces grey-disabled product lock). Faded card + warm
# "Discover at Lv N" stamp over the plate.
func _add_discovery_stamp(card: Panel, lvl: int) -> void:
	var stamp := Panel.new()
	stamp.position = Vector2((card.size.x - 300.0) * 0.5, 150)
	stamp.size = Vector2(300, 84)
	stamp.pivot_offset = Vector2(150, 42)
	stamp.rotation_degrees = -4.0  # hand-stamped on the recipe note
	var psb := StyleBoxFlat.new()
	psb.bg_color = Color(0.20, 0.14, 0.08, 0.80)
	psb.set_corner_radius_all(18)
	psb.set_border_width_all(3)
	psb.border_color = Color(0.92, 0.74, 0.34, 0.85)
	psb.shadow_size = 8
	psb.shadow_color = Color(0, 0, 0, 0.30)
	stamp.add_theme_stylebox_override("panel", psb)
	stamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(stamp)
	var lock := Label.new()
	lock.text = "🔒 Discover at Lv %d" % lvl
	lock.position = Vector2(0, 12)
	lock.size = Vector2(300, 34)
	lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lock.add_theme_font_size_override("font_size", 26)
	lock.add_theme_color_override("font_color", Color(0.97, 0.88, 0.52))
	lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stamp.add_child(lock)
	var sub := Label.new()
	sub.text = "Recipe unlocks soon"
	sub.position = Vector2(0, 46)
	sub.size = Vector2(300, 28)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 19)
	sub.add_theme_color_override("font_color", Color(0.88, 0.80, 0.66, 0.9))
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stamp.add_child(sub)


# "Today's Special" feature plaque above the grid — a warm chalkboard menu board (한식
# 식당 칠판 메뉴), NOT a dark product/deal banner.
func _add_today_feature_card(pos: Vector2, sm) -> void:
	var menu: Dictionary = MenuDB.get_menu(_best_pick_id)
	if menu.is_empty():
		return
	var card := Panel.new()
	card.position = pos
	card.size = Vector2(1000, 190)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.17, 0.22, 0.18)  # chalkboard green-black (식당 칠판)
	sb.set_corner_radius_all(20)
	sb.set_border_width_all(8)
	sb.border_color = Color(0.52, 0.36, 0.20)  # wooden chalkboard frame
	sb.shadow_size = 14
	sb.shadow_color = Color(0, 0, 0, 0.32)
	sb.shadow_offset = Vector2(0, 8)
	card.add_theme_stylebox_override("panel", sb)
	add_child(card)

	# chalk header line
	var head := Label.new()
	head.text = "✎ Today's Special"
	head.position = Vector2(28, 14)
	head.size = Vector2(640, 36)
	head.add_theme_font_size_override("font_size", 30)
	head.add_theme_color_override("font_color", Color(0.96, 0.93, 0.80))  # chalk white
	card.add_child(head)
	# thin chalk underline
	var chalk_rule := ColorRect.new()
	chalk_rule.color = Color(0.85, 0.84, 0.74, 0.55)
	chalk_rule.position = Vector2(28, 50)
	chalk_rule.size = Vector2(300, 2)
	chalk_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(chalk_rule)

	# dish thumbnail (on a small plate)
	var plate := Panel.new()
	plate.position = Vector2(24, 58)
	plate.size = Vector2(120, 116)
	var psb := StyleBoxFlat.new()
	psb.bg_color = C_PLATE
	psb.set_corner_radius_all(18)
	psb.set_border_width_all(2)
	psb.border_color = Color(0.84, 0.72, 0.52)
	plate.add_theme_stylebox_override("panel", psb)
	card.add_child(plate)
	if bool(menu.get("ready", false)):
		var tex: Texture2D = load(String(menu.get("food_img", "")))
		if tex != null:
			var tr := TextureRect.new()
			tr.texture = tex
			tr.position = Vector2(6, 6)
			tr.size = Vector2(108, 104)
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
			plate.add_child(tr)

	# name + numbered steps + learn (chalk text)
	var nm := Label.new()
	nm.text = "%s  (%s)" % [menu.get("name_en", "?"), menu.get("name_kr", "")]
	nm.position = Vector2(160, 56)
	nm.size = Vector2(560, 38)
	nm.add_theme_font_size_override("font_size", 32)
	nm.add_theme_color_override("font_color", Color(0.98, 0.95, 0.84))
	card.add_child(nm)
	var seq: Array = MenuDB.module_sequence(_best_pick_id)
	var parts: Array = []
	for i in range(seq.size()):
		var num: String = STEP_NUMERALS[i] if i < STEP_NUMERALS.size() else str(i + 1)
		parts.append("%s %s" % [num, String(MODULE_LABEL.get(String(seq[i]), String(seq[i]).capitalize()))])
	var ml := Label.new()
	ml.text = "  →  ".join(parts)
	ml.position = Vector2(160, 100)
	ml.size = Vector2(560, 30)
	ml.add_theme_font_size_override("font_size", 21)
	ml.add_theme_color_override("font_color", Color(0.80, 0.84, 0.70))
	card.add_child(ml)
	var lt := _learn_tag(menu)
	if lt != "":
		var ll := Label.new()
		ll.text = lt
		ll.position = Vector2(160, 134)
		ll.size = Vector2(560, 28)
		ll.add_theme_font_size_override("font_size", 20)
		ll.add_theme_color_override("font_color", Color(0.72, 0.85, 0.66))
		card.add_child(ll)

	# best match chip (right) — chalk-circled "% best match"
	var match_chip := Panel.new()
	match_chip.position = Vector2(744, 54)
	match_chip.size = Vector2(140, 116)
	var msb := StyleBoxFlat.new()
	msb.bg_color = Color(0.95, 0.74, 0.22)
	msb.set_corner_radius_all(18)
	msb.shadow_size = 6
	msb.shadow_color = Color(0, 0, 0, 0.25)
	match_chip.add_theme_stylebox_override("panel", msb)
	card.add_child(match_chip)
	var pct := Label.new()
	pct.text = "%d%%" % _best_pick_compat
	pct.position = Vector2(0, 18)
	pct.size = Vector2(140, 46)
	pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pct.add_theme_font_size_override("font_size", 42)
	pct.add_theme_color_override("font_color", Color(0.22, 0.12, 0.02))
	match_chip.add_child(pct)
	var mt := Label.new()
	mt.text = "best match"
	mt.position = Vector2(0, 70)
	mt.size = Vector2(140, 28)
	mt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mt.add_theme_font_size_override("font_size", 20)
	mt.add_theme_color_override("font_color", Color(0.30, 0.18, 0.05))
	match_chip.add_child(mt)

	# guest avatar dot next to the match chip (best_guest for the recommended dish).
	var compat_sys := get_node_or_null("/root/CompatCalc")
	if compat_sys != null:
		var bg: Dictionary = compat_sys.best_guest(_best_pick_id)
		var gid := String(bg.get("guest_id", ""))
		if gid != "":
			var av := Panel.new()
			av.position = Vector2(680, 86)
			av.size = Vector2(52, 52)
			var avsb := StyleBoxFlat.new()
			avsb.bg_color = GUEST_TINT.get(gid, Color(0.8, 0.7, 0.6))
			avsb.set_corner_radius_all(26)
			avsb.set_border_width_all(2)
			avsb.border_color = Color.WHITE
			av.add_theme_stylebox_override("panel", avsb)
			av.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card.add_child(av)
			var avatar_path := "res://art/sprites/character/%s_neutral.png" % gid
			if ResourceLoader.exists(avatar_path):
				var atr := TextureRect.new()
				atr.texture = load(avatar_path)
				atr.set_anchors_preset(Control.PRESET_FULL_RECT)
				atr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				atr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				atr.mouse_filter = Control.MOUSE_FILTER_IGNORE
				av.add_child(atr)
			else:
				var g: Dictionary = MenuDB.get_guest(gid)
				var gi := Label.new()
				gi.text = String(g.get("name", "?")).substr(0, 1)
				gi.set_anchors_preset(Control.PRESET_FULL_RECT)
				gi.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				gi.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				gi.add_theme_font_size_override("font_size", 28)
				gi.add_theme_color_override("font_color", Color.WHITE)
				gi.mouse_filter = Control.MOUSE_FILTER_IGNORE
				av.add_child(gi)


# Wire the whole-card press target — UNCHANGED logic (cook routes to runner; disabled
# when locked/out). Mirrors the previous _wire_cook_button contract exactly.
func _wire_card_button(btn: Button, card: Panel, menu_id: String, disabled: bool) -> void:
	if btn == null:
		return
	btn.disabled = disabled
	if disabled:
		return
	btn.pressed.connect(func() -> void:
		# tiny press bounce on the card (visual only)
		if is_instance_valid(card):
			var tw := create_tween()
			tw.tween_property(card, "scale", Vector2(0.97, 0.97), 0.06).set_trans(Tween.TRANS_SINE)
			tw.tween_property(card, "scale", Vector2.ONE, 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_on_pick(menu_id))


func _wire_restock_button_btn(btn: Button, menu_id: String) -> void:
	if btn == null:
		return
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

	# outer pill bg
	var mini := Panel.new()
	mini.position = Vector2(342, 10)
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

	# avatar (small circle 50x50). real sprite (neutral) if available.
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

	# "Best for: Mina" caption at bottom (recipe-board phrasing)
	var cap := Label.new()
	cap.text = "Best for: %s" % best_guest.get("name", "?")
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
	t.text = "Level Up! ▲ Level %d — %s kitchen unlocked!" % [new_level, String(lv_data.get("market", "home")).capitalize()]
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


func _redirect_to_gender_select() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_file("res://scenes/gender_select.tscn")


func _redirect_to_name_entry() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_file("res://scenes/name_entry.tscn")


# Player-Chef host badge: 선택한 셰프 아바타를 원형 프레임 + 캡션으로 헤더 코너에 배치.
# sm에서 성별을 읽어 ArtRegistry.get_protagonist(gender, emotion)로 해석. 미선택/미존재 시
# silent skip(폴백 없음). world BG 위 layer — 손님(먹는 쪽) 시스템과 역할 분리. visual only.
func _add_chef_host_badge(sm, emotion: String, pos: Vector2, sz: float,
		caption: String, ring: Color) -> void:
	if sm == null or not sm.has_method("player_chef_gender"):
		return
	var gender: String = sm.player_chef_gender()
	if gender != "f" and gender != "m":
		return
	var path := ArtRegistry.get_protagonist(gender, emotion)
	if path == "" or not ResourceLoader.exists(path):
		return
	# 원형 프레임 (north star warm 톤 + ring)
	var frame := Panel.new()
	frame.position = pos
	frame.size = Vector2(sz, sz)
	var fsb := StyleBoxFlat.new()
	fsb.bg_color = Color(0.99, 0.96, 0.89)
	fsb.set_corner_radius_all(int(sz * 0.5))
	fsb.set_border_width_all(5)
	fsb.border_color = ring
	fsb.shadow_size = 10
	fsb.shadow_color = Color(0, 0, 0, 0.30)
	fsb.shadow_offset = Vector2(0, 5)
	frame.add_theme_stylebox_override("panel", fsb)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.clip_contents = true  # 원형 프레임 안으로 chef bust를 crop (landscape 빈 여백 제거)
	add_child(frame)
	# warm radial glow behind the chef (은은하게 — 아바타를 가리지 않게 낮은 alpha)
	var glow := TextureRect.new()
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 0.88, 0.58, 0.30))
	grad.set_color(1, Color(1.0, 0.88, 0.58, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(1.0, 0.5)
	gt.width = 96; gt.height = 96
	glow.texture = gt
	glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(glow)
	# the host avatar — COVERED로 chef bust가 원형 프레임을 채운다(landscape 1536×1024 → head+shoulders).
	# FULL_RECT anchor + COVERED + frame.clip_contents 조합이어야 한다(수동 size+COVERED는 미렌더 버그).
	var host := TextureRect.new()
	host.texture = load(path)
	host.set_anchors_preset(Control.PRESET_FULL_RECT)
	host.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	host.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(host)
	# 캡션 (플레이어 이름)
	if caption != "":
		var cap := Label.new()
		cap.text = caption
		cap.position = Vector2(pos.x - 14.0, pos.y + sz - 6.0)
		cap.size = Vector2(sz + 28.0, 30)
		cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cap.add_theme_font_size_override("font_size", 20)
		cap.add_theme_color_override("font_color", Color(0.99, 0.92, 0.78))
		cap.add_theme_color_override("font_outline_color", Color(0.20, 0.10, 0.04))
		cap.add_theme_constant_override("outline_size", 3)
		cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(cap)


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


# De-emphasized wallet — small muted coin chip in the corner. Money never dominates.
func _wallet_chip(txt: String, pos: Vector2, w: float) -> Label:
	var p := Panel.new()
	p.position = pos
	p.size = Vector2(w, 44)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.40, 0.32, 0.22, 0.55)  # muted, semi-transparent
	sb.set_corner_radius_all(22)
	sb.set_border_width_all(1)
	sb.border_color = Color(0.70, 0.58, 0.34, 0.5)
	p.add_theme_stylebox_override("panel", sb)
	add_child(p)
	# small coin glyph
	var coin := Label.new()
	coin.text = "🪙"
	coin.position = Vector2(12, 0)
	coin.size = Vector2(30, 44)
	coin.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	coin.add_theme_font_size_override("font_size", 22)
	coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(coin)
	var l := Label.new()
	l.text = txt
	l.position = Vector2(40, 0)
	l.size = Vector2(w - 50, 44)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 24)
	l.add_theme_color_override("font_color", Color(0.96, 0.90, 0.78, 0.92))
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
