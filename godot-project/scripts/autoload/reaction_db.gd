## ReactionDB — guest reaction line templates for Result Screen 2.0 (autoload).
##
## Loads data/reaction_templates.csv at boot. 11 guests * 4 emotion levels =
## 44 rows (game-designer locked). Each row has placeholders:
##   {top_matched_flavor}   - guest favorite ∩ menu flavor_tags (first match)
##   {top_disliked_flavor}  - guest dislike ∩ menu flavor_tags (first match)
##   {missing_favorite}     - first guest favorite NOT in menu flavor_tags
##
## Use:
##   ReactionDB.template(guest_id, emotion) -> raw template
##   ReactionDB.generate_text(guest, menu, stars, compat, mood) -> final line
extends Node

const REACTION_CSV: String = "res://data/reaction_templates.csv"
const EMOTIONS := ["excellent", "good", "okay", "bad"]
const DEFAULT_KEY := "default"

# {guest_id -> {emotion -> template_string}}
var _by_guest: Dictionary = {}
var _loaded: bool = false


func _ready() -> void:
	_load()


func _load() -> void:
	if _loaded:
		return
	_loaded = true
	var f := FileAccess.open(REACTION_CSV, FileAccess.READ)
	if f == null:
		push_warning("ReactionDB: cannot open " + REACTION_CSV + " (fallback only)")
		_install_default_only()
		return
	var header := f.get_csv_line(",")
	var idx: Dictionary = {}
	for i in range(header.size()):
		idx[String(header[i]).strip_edges()] = i
	while not f.eof_reached():
		var row := f.get_csv_line(",")
		if row.size() < 1:
			continue
		var gid: String = String(row[int(idx.get("guest_id", 0))]).strip_edges()
		if gid == "":
			continue
		var emo: String = String(row[int(idx.get("emotion", 1))]).strip_edges()
		var tpl: String = String(row[int(idx.get("template", 2))]).strip_edges()
		if not _by_guest.has(gid):
			_by_guest[gid] = {}
		(_by_guest[gid] as Dictionary)[emo] = tpl
	f.close()
	_install_default_only()  # safety net


func _install_default_only() -> void:
	if not _by_guest.has(DEFAULT_KEY):
		_by_guest[DEFAULT_KEY] = {
			"excellent": "The guest loved the {top_matched_flavor} — best meal in a while!",
			"good": "The guest enjoyed the {top_matched_flavor} touch.",
			"okay": "The guest ate it. A bit more {missing_favorite} next time.",
			"bad": "The guest barely ate — too much {top_disliked_flavor}.",
		}


## Returns the raw template string (with {placeholders}) for a (guest, emotion).
## Falls back to the default guest set if the guest_id is missing.
func template(guest_id: String, emotion: String) -> String:
	var by: Dictionary = _by_guest.get(guest_id, {}) as Dictionary
	if by.has(emotion):
		return String(by[emotion])
	var fallback: Dictionary = _by_guest.get(DEFAULT_KEY, {}) as Dictionary
	return String(fallback.get(emotion, "{name} reacted to your dish."))


## Fully-resolved reaction line for the result screen.
##   guest:   MenuDB.get_guest(...)
##   menu:    MenuDB.get_menu(...)
##   stars:   1..5
##   compat:  0..100
##   mood:    one of MOOD_POOL (unused in default templates, but kept for future flavor)
func generate_text(guest: Dictionary, menu: Dictionary, stars: int, compat: int, _mood: String) -> String:
	var emotion: String = "okay"
	var rc := get_node_or_null("/root/RewardCalc")
	if rc and rc.has_method("emotion_level"):
		emotion = rc.emotion_level(stars, compat)
	var gid: String = String(guest.get("id", ""))
	var tpl: String = template(gid, emotion)
	return _fill(tpl, guest, menu, emotion)


func _fill(tpl: String, guest: Dictionary, menu: Dictionary, _emotion: String) -> String:
	var out: String = tpl
	var menu_tags: Array = menu.get("flavor_tags", []) as Array
	var fav: Array = guest.get("favorite_flavors", []) as Array
	var dis: Array = guest.get("disliked_flavors", []) as Array
	var matched: String = _first_intersection(menu_tags, fav)
	var disliked: String = _first_intersection(menu_tags, dis)
	var missing: String = _first_only_in(fav, menu_tags)
	# safe defaults so the line never reads "... the  ..."
	if matched == "":
		matched = "flavor"
	if disliked == "":
		disliked = "flavor"
	if missing == "":
		missing = "flavor"
	out = out.replace("{top_matched_flavor}", _flavor_name(matched))
	out = out.replace("{top_disliked_flavor}", _flavor_name(disliked))
	out = out.replace("{missing_favorite}", _flavor_name(missing))
	out = out.replace("{name}", String(guest.get("name", "the guest")))
	return out


# Casualizing helper — "spicy" -> "spicy", "umami" -> "umami". We keep this thin
# but route through flavors.csv name_en if present so future renames stick.
func _flavor_name(flavor_id: String) -> String:
	var MenuDB := load("res://scripts/gameplay/menu_db.gd")
	if MenuDB != null and MenuDB.has_method("get_flavor"):
		var fl: Dictionary = MenuDB.get_flavor(flavor_id) as Dictionary
		var nm: String = String(fl.get("name_en", "")).to_lower()
		if nm != "":
			return nm
	return flavor_id.to_lower()


func _first_intersection(a: Array, b: Array) -> String:
	for x in a:
		for y in b:
			if String(x) == String(y):
				return String(x)
	return ""


func _first_only_in(a: Array, b: Array) -> String:
	for x in a:
		var found := false
		for y in b:
			if String(x) == String(y):
				found = true
				break
		if not found:
			return String(x)
	return ""
