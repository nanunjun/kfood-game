## MenuDB — data-driven menu/guest catalog (M1).
##
## Loads res://data/menus.csv + guests.csv once and exposes lookups so the round
## (rhythm_proto.gd) and the menu grid (menu_select.gd) are fully data-driven:
## add a CSV row -> the menu appears. English-first; Korean kept as cultural flavor.
##
## NOTE: intentionally NO class_name — consumers preload this script
##   const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
## to avoid the global-class-name resolution desync we hit earlier (see CHANGELOG).
extends RefCounted

const MENUS_CSV := "res://data/menus.csv"
const GUESTS_CSV := "res://data/guests.csv"
const LEVELS_CSV := "res://data/levels.csv"
const FLAVORS_CSV := "res://data/flavors.csv"
## Cooking Framework 2.0 (ADR-011): per-dish 8-module sequence.
##   food_id -> Array[String] of module ids from ALL_MODULES.
const DISH_MODULES_CSV := "res://data/dish_modules.csv"
## 8 universal cooking modules (ADR-011 lock). New dishes pick from this set in CSV.
const ALL_MODULES: Array = ["slice", "arrange", "stir", "flip", "timing", "season", "roll", "plate"]
## Fallback sequence used when a menu has no row in dish_modules.csv (keeps the round
## playable even before designers fill in a new dish). Mirrors the legacy 4-step flow.
const FALLBACK_SEQUENCE: Array = ["slice", "timing", "season", "plate"]

# Vessel catalog — id -> {name_en, color, kind}. kind drives reveal shape.
#   metal=손잡이 냄비 / ceramic=사기 / stone=돌솥 / clay=뚝배기(옹기)
#   glass=유리 / brass=유기 / wood=나무 소반 / plate=넓은 접시
const VESSELS := {
	"pot_metal":    {"name_en": "Aluminum Pot",  "name_kr": "양은냄비", "color": Color(0.80, 0.82, 0.86), "kind": "metal"},
	"bowl_ceramic": {"name_en": "Porcelain Bowl", "name_kr": "사기 대접", "color": Color(0.94, 0.94, 0.91), "kind": "ceramic"},
	"pot_stone":    {"name_en": "Stone Pot",      "name_kr": "돌솥",    "color": Color(0.28, 0.26, 0.27), "kind": "stone"},
	"pot_clay":     {"name_en": "Earthenware",    "name_kr": "뚝배기",  "color": Color(0.42, 0.29, 0.22), "kind": "clay"},
	"bowl_glass":   {"name_en": "Glass Bowl",     "name_kr": "유리 그릇", "color": Color(0.80, 0.88, 0.93), "kind": "glass"},
	"bowl_brass":   {"name_en": "Brassware",      "name_kr": "유기",    "color": Color(0.82, 0.66, 0.30), "kind": "brass"},
	"board_wood":   {"name_en": "Wooden Tray",    "name_kr": "나무 소반", "color": Color(0.79, 0.61, 0.39), "kind": "wood"},
	"plate_wide":   {"name_en": "Wide Plate",     "name_kr": "넓은 접시", "color": Color(0.96, 0.96, 0.93), "kind": "plate"},
}

# Dishware match bonus tiers (recipes-balance-phase1 §b)
const BONUS_BEST := 0.12
const BONUS_SECOND := 0.05
const BONUS_BAD := -0.08

static var _menus: Dictionary = {}     # menu_id -> Dictionary
static var _guests: Dictionary = {}    # guest_id -> Dictionary
static var _levels: Dictionary = {}    # level:int -> Dictionary
static var _flavors: Dictionary = {}   # flavor_id -> {name_en, icon, color, category}
static var _dish_modules: Dictionary = {}  # food_id -> {sequence: Array[String], signature: String, notes: String}
static var _order: Array = []          # menu ids in file order
static var _loaded: bool = false


static func _ensure() -> void:
	if _loaded:
		return
	_loaded = true
	_load_menus()
	_load_guests()
	_load_levels()
	_load_flavors()
	_load_dish_modules()


static func _split_pipe(s: String) -> Array:
	# CSV pipe-separated list (e.g. "spicy|salty|umami") -> Array[String], trimmed.
	if s.is_empty():
		return []
	var out: Array = []
	for chunk in s.split("|", false):
		var v: String = chunk.strip_edges()
		if v != "":
			out.append(v)
	return out


static func _header_index(header: PackedStringArray) -> Dictionary:
	var idx: Dictionary = {}
	for i in range(header.size()):
		idx[String(header[i]).strip_edges()] = i
	return idx


static func _cell(row: PackedStringArray, idx: Dictionary, key: String) -> String:
	if not idx.has(key):
		return ""
	var i: int = int(idx[key])
	if i < 0 or i >= row.size():
		return ""
	return String(row[i]).strip_edges()


static func _load_menus() -> void:
	var f := FileAccess.open(MENUS_CSV, FileAccess.READ)
	if f == null:
		push_error("MenuDB: cannot open " + MENUS_CSV)
		return
	var header := f.get_csv_line(",")
	var idx := _header_index(header)
	while not f.eof_reached():
		var row := f.get_csv_line(",")
		var id := _cell(row, idx, "menu_id")
		if id == "":
			continue
		var seasonings: Array = []
		for chunk in _cell(row, idx, "seasonings").split("|", false):
			var parts: PackedStringArray = chunk.split(":")
			if parts.size() >= 3:
				seasonings.append({
					"id": StringName(parts[0].strip_edges()),
					"axis": parts[1].strip_edges(),
					"umax": int(parts[2]),
				})
		var phases: Array = []
		for ph in _cell(row, idx, "phases").split("|", false):
			phases.append(ph.strip_edges())
		if phases.is_empty():
			phases = ["chop", "boil", "season"]  # default flow
		# ready = the final art actually exists (auto-swap when a PNG is dropped in),
		# falling back to the CSV hint flag if the resource can't be probed.
		var food_img := _cell(row, idx, "food_img")
		var has_art: bool = (food_img != "" and ResourceLoader.exists(food_img)) or _cell(row, idx, "ready") == "1"
		_menus[id] = {
			"id": id,
			"name_en": _cell(row, idx, "name_en"),
			"name_kr": _cell(row, idx, "name_kr"),
			"intro_en": _cell(row, idx, "intro_en"),
			"seasonings": seasonings,
			"dish_best": _cell(row, idx, "dish_best"),
			"dish_2nd": _cell(row, idx, "dish_2nd"),
			"dish_bad": _cell(row, idx, "dish_bad"),
			"guest_id": _cell(row, idx, "guest_id"),
			"unlock_level": int(_cell(row, idx, "unlock_level")),
			"food_img": food_img,
			"ready": has_art,
			"phases": phases,
			# Guest System 2.0: pipe-separated flavor tags (e.g. spicy|salty|umami|fermented|hearty)
			"flavor_tags": _split_pipe(_cell(row, idx, "flavor_tags")),
		}
		_order.append(id)
	f.close()


static func _load_guests() -> void:
	var f := FileAccess.open(GUESTS_CSV, FileAccess.READ)
	if f == null:
		push_error("MenuDB: cannot open " + GUESTS_CSV)
		return
	var header := f.get_csv_line(",")
	var idx := _header_index(header)
	var axes := ["sweet", "salty", "spicy", "sour", "umami"]
	while not f.eof_reached():
		var row := f.get_csv_line(",")
		var id := _cell(row, idx, "guest_id")
		if id == "":
			continue
		var vec: Dictionary = {}
		var nums: PackedStringArray = _cell(row, idx, "vec").split("|")
		for i in range(min(axes.size(), nums.size())):
			vec[axes[i]] = float(nums[i])
		var rb_raw: String = _cell(row, idx, "reward_bonus")
		var reward_bonus: float = float(rb_raw) if rb_raw != "" else 1.0
		_guests[id] = {
			"id": id,
			"name": _cell(row, idx, "name"),
			"vec": vec,
			"tol": float(_cell(row, idx, "tol")),
			"line_enter": _cell(row, idx, "line_enter"),
			"line_ok": _cell(row, idx, "line_ok"),
			"line_bad": _cell(row, idx, "line_bad"),
			"role": _cell(row, idx, "role"),
			# --- Guest System 2.0 (CSV v3.0) ---
			"favorite_flavors": _split_pipe(_cell(row, idx, "favorite_flavors")),
			"disliked_flavors": _split_pipe(_cell(row, idx, "disliked_flavors")),
			"reward_bonus": reward_bonus,
			"friendship_level_initial": int(_cell(row, idx, "friendship_level_initial")),
			"mood_pool": _split_pipe(_cell(row, idx, "mood_pool")),
		}
	f.close()


static func _load_flavors() -> void:
	var f := FileAccess.open(FLAVORS_CSV, FileAccess.READ)
	if f == null:
		# flavors.csv is optional — UI badges will fall back to plain text
		return
	var header := f.get_csv_line(",")
	var idx := _header_index(header)
	while not f.eof_reached():
		var row := f.get_csv_line(",")
		var id := _cell(row, idx, "flavor_id")
		if id == "":
			continue
		_flavors[id] = {
			"id": id,
			"name_en": _cell(row, idx, "name_en"),
			"icon": _cell(row, idx, "icon"),
			"color": Color.html(_cell(row, idx, "color_hex")) if _cell(row, idx, "color_hex") != "" else Color(0.7, 0.7, 0.7),
			"category": _cell(row, idx, "category"),
		}
	f.close()


static func get_flavor(id: String) -> Dictionary:
	_ensure()
	return _flavors.get(id, {
		"id": id, "name_en": id.capitalize(),
		"icon": id.substr(0, 1).to_upper(), "color": Color(0.7, 0.7, 0.7),
		"category": "",
	})


static func _load_levels() -> void:
	var f := FileAccess.open(LEVELS_CSV, FileAccess.READ)
	if f == null:
		push_error("MenuDB: cannot open " + LEVELS_CSV)
		return
	var header := f.get_csv_line(",")
	var idx := _header_index(header)
	while not f.eof_reached():
		var row := f.get_csv_line(",")
		var lv_s := _cell(row, idx, "level")
		if lv_s == "":
			continue
		var lv := int(lv_s)
		_levels[lv] = {
			"level": lv,
			"perfect_ms": float(_cell(row, idx, "perfect_ms")),
			"good_ms": float(_cell(row, idx, "good_ms")),
			"tol": float(_cell(row, idx, "tol")),
			"w_prep": float(_cell(row, idx, "w_prep")),
			"w_cook": float(_cell(row, idx, "w_cook")),
			"w_season": float(_cell(row, idx, "w_season")),
			"w_dish": float(_cell(row, idx, "w_dish")),
			"theta": float(_cell(row, idx, "theta")),
			"star2": float(_cell(row, idx, "star2")),
			"star3": float(_cell(row, idx, "star3")),
			"star4": float(_cell(row, idx, "star4")),
			"star5": float(_cell(row, idx, "star5")),
			"reward": int(_cell(row, idx, "reward")),
			"market": _cell(row, idx, "market"),
			"evaluator": _cell(row, idx, "evaluator"),
		}
	f.close()


# --- public API ---

static func get_menu(id: String) -> Dictionary:
	_ensure()
	return _menus.get(id, {})


static func get_guest(id: String) -> Dictionary:
	_ensure()
	return _guests.get(id, {})


## Guest ids of a given role ("friend"/"mentor"/"evaluator"); empty role = all.
static func guest_ids(role: String = "") -> Array:
	_ensure()
	var out: Array = []
	for id in _guests.keys():
		if role == "" or String(_guests[id].get("role", "")) == role:
			out.append(id)
	return out


## Non-evaluator guests (friends + mentor + family) — selectable in guest select.
static func selectable_guest_ids() -> Array:
	_ensure()
	var out: Array = []
	for id in _guests.keys():
		if String(_guests[id].get("role", "")) != "evaluator":
			out.append(id)
	out.sort()
	return out


static func get_level(lv: int) -> Dictionary:
	_ensure()
	if _levels.has(lv):
		return _levels[lv]
	# clamp to available range
	var keys := _levels.keys()
	if keys.is_empty():
		return {}
	keys.sort()
	var clamped: int = clampi(lv, int(keys[0]), int(keys[keys.size() - 1]))
	return _levels.get(clamped, _levels[keys[0]])


static func all_menu_ids() -> Array:
	_ensure()
	return _order.duplicate()


## Menus unlocked at or below the given level, in file order.
static func unlocked(level: int) -> Array:
	_ensure()
	var out: Array = []
	for id in _order:
		if int(_menus[id]["unlock_level"]) <= level:
			out.append(id)
	return out


static func vessel(id: String) -> Dictionary:
	return VESSELS.get(id, {"name_en": id, "name_kr": "", "color": Color(0.85, 0.85, 0.85), "kind": "ceramic"})


## Dishware bonus for a chosen vessel within a menu (default magnitude).
static func dish_bonus(menu: Dictionary, dish_id: String) -> float:
	return dish_bonus_scaled(menu, dish_id, BONUS_BEST)


## Dishware bonus scaled by level weight w_dish (best=+w, 2nd=+0.42w, bad=-0.67w).
static func dish_bonus_scaled(menu: Dictionary, dish_id: String, w_dish: float) -> float:
	if dish_id == String(menu.get("dish_best", "")):
		return w_dish
	elif dish_id == String(menu.get("dish_2nd", "")):
		return w_dish * 0.42
	elif dish_id == String(menu.get("dish_bad", "")):
		return -w_dish * 0.67
	return 0.0


## Tier label for a chosen vessel: "best" / "2nd" / "bad" / "neutral".
static func dish_tier(menu: Dictionary, dish_id: String) -> String:
	if dish_id == String(menu.get("dish_best", "")):
		return "best"
	elif dish_id == String(menu.get("dish_2nd", "")):
		return "2nd"
	elif dish_id == String(menu.get("dish_bad", "")):
		return "bad"
	return "neutral"


# --- Cooking Framework 2.0 (ADR-011) — 8-module sequence per dish ---

static func _load_dish_modules() -> void:
	var f := FileAccess.open(DISH_MODULES_CSV, FileAccess.READ)
	if f == null:
		push_warning("MenuDB: dish_modules.csv missing — using fallback sequence for every dish")
		return
	var header := f.get_csv_line(",")
	var idx := _header_index(header)
	while not f.eof_reached():
		var row := f.get_csv_line(",")
		var fid := _cell(row, idx, "food_id")
		if fid == "":
			continue
		var seq_raw := _cell(row, idx, "module_sequence")
		var sequence: Array = []
		for tok in seq_raw.split("|", false):
			var t: String = tok.strip_edges()
			if t == "":
				continue
			# strict ADR-011: skip any unknown module id (data hygiene)
			if not ALL_MODULES.has(t):
				push_warning("MenuDB: unknown module '%s' in dish_modules.csv for %s — skipped" % [t, fid])
				continue
			sequence.append(t)
		# every dish ends in a plate-style finish; auto-append if author forgot
		if sequence.is_empty() or String(sequence.back()) != "plate":
			sequence.append("plate")
		_dish_modules[fid] = {
			"sequence": sequence,
			"signature": _cell(row, idx, "signature_step"),
			"notes": _cell(row, idx, "notes"),
		}
	f.close()


## Module sequence (Array[String]) for a food_id. Falls back to FALLBACK_SEQUENCE
## when the CSV has no row — keeps unknown / new dishes playable.
static func module_sequence(food_id: String) -> Array:
	_ensure()
	if _dish_modules.has(food_id):
		return (_dish_modules[food_id]["sequence"] as Array).duplicate()
	return FALLBACK_SEQUENCE.duplicate()


## Signature module id for a dish (e.g. "timing", "roll"). "" when none defined.
static func dish_signature(food_id: String) -> String:
	_ensure()
	return String(_dish_modules.get(food_id, {}).get("signature", ""))


## Raw entry (debug / smoke). Empty dict for unknown food_id.
static func dish_module_row(food_id: String) -> Dictionary:
	_ensure()
	return _dish_modules.get(food_id, {})


## All food_ids that have a module sequence row.
static func dish_module_ids() -> Array:
	_ensure()
	return _dish_modules.keys()
