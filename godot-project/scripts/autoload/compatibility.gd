## CompatCalc — Guest System 2.0 compatibility scoring (autoload).
##
## Pure data function: given a menu dictionary and a guest dictionary (both with
## flavor_tags / favorite_flavors / disliked_flavors) plus today's mood, produces a
## clamped 0~100 integer compat percentage. Also exposes best_guest(menu_id) which
## scans selectable guests to recommend the best match for the menu-select badge.
##
## Formula (locked, see CHANGELOG / game-designer spec):
##   hit_fav = |food.flavor_tags ∩ guest.favorite_flavors|
##   hit_dis = |food.flavor_tags ∩ guest.disliked_flavors|
##   fav_score = hit_fav * 12 * mood_mult_fav[mood]
##   dis_score = hit_dis * 18 * mood_mult_dis[mood]
##   compat = clamp(50 + fav_score - dis_score, 0, 100)
##
## Verified: 김치찌개 + Junho (happy) = 93%, 김밥 + Mina (easy) = 62%.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")

# mood multipliers (favorite hits)
const MOOD_MULT_FAV := {
	"hungry": 1.3, "happy": 1.2, "easy": 1.0, "picky": 1.1, "grumpy": 0.8,
}
# mood multipliers (dislike hits — picky/grumpy amplify negative reaction)
const MOOD_MULT_DIS := {
	"hungry": 0.9, "happy": 1.0, "easy": 0.7, "picky": 1.5, "grumpy": 1.6,
}

const FAV_WEIGHT := 12.0
const DIS_WEIGHT := 18.0
const BASE := 50.0


## Core compat formula. menu/guest are MenuDB dictionaries; mood is one of
## hungry/happy/easy/picky/grumpy. Returns clamped integer 0~100.
func score(menu: Dictionary, guest: Dictionary, mood: String) -> int:
	if menu.is_empty() or guest.is_empty():
		return 50
	var food_tags: Array = menu.get("flavor_tags", []) as Array
	var fav: Array = guest.get("favorite_flavors", []) as Array
	var dis: Array = guest.get("disliked_flavors", []) as Array
	var hit_fav: int = _count_intersection(food_tags, fav)
	var hit_dis: int = _count_intersection(food_tags, dis)
	var mf: float = float(MOOD_MULT_FAV.get(mood, 1.0))
	var md: float = float(MOOD_MULT_DIS.get(mood, 1.0))
	var fav_score: float = float(hit_fav) * FAV_WEIGHT * mf
	var dis_score: float = float(hit_dis) * DIS_WEIGHT * md
	var raw: float = BASE + fav_score - dis_score
	return int(clamp(round(raw), 0.0, 100.0))


## Scans all selectable guests for the menu and returns {guest_id, compat}.
## Uses MoodSystem.today(guest_id) for the mood input. Returns {} on empty.
func best_guest(menu_id: String) -> Dictionary:
	var menu: Dictionary = MenuDB.get_menu(menu_id)
	if menu.is_empty():
		return {}
	var mood_sys := get_node_or_null("/root/MoodSystem")
	var best_id: String = ""
	var best_score: int = -1
	for gid in MenuDB.selectable_guest_ids():
		var guest: Dictionary = MenuDB.get_guest(gid)
		var mood: String = mood_sys.today(gid) if mood_sys else "easy"
		var s: int = score(menu, guest, mood)
		if s > best_score:
			best_score = s
			best_id = gid
	return {"guest_id": best_id, "compat": best_score}


## Returns the count of items appearing in both arrays (string-level match).
func _count_intersection(a: Array, b: Array) -> int:
	if a.is_empty() or b.is_empty():
		return 0
	var n: int = 0
	for x in a:
		for y in b:
			if String(x) == String(y):
				n += 1
				break
	return n
