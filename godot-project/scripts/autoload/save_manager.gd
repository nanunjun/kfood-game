## SaveManager — player progression + economy (autoload).
##
## JSON save (user://kfood_save.json, schema version 1): level, money, per-menu stock,
## unlocks, stats, reputation, guest intimacy, player char, settings.
## Auto-saves on round end / menu entry. English-first game; this is data only.
## Back-compat: keeps the old A2 methods (record_result/best_of/is_cleared/...) backed by stats.
## Ref: docs/phase1/economy-save-v1.md
extends Node

signal level_up(new_level)
signal money_changed(amount)

const SAVE_PATH: String = "user://kfood_save.json"
const SCHEMA_VERSION: int = 1
const SEED_MONEY: int = 50000
const START_STOCK: int = 3
const RESTOCK_QTY: int = 3
const RESTOCK_COST: int = 2000
const MAX_LEVEL: int = 8

# clears needed to advance FROM level L to L+1 (~41 rounds L1->L8)
const CLEARS_REQ := {1: 4, 2: 5, 3: 5, 4: 6, 5: 6, 6: 7, 7: 8}

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")

var data: Dictionary = {}
var _pending_levelup: int = 0   # 0 = none; consumed by menu grid for toast


func _ready() -> void:
	_load()


func _default_data() -> Dictionary:
	return {
		"version": SCHEMA_VERSION,
		"level": 1,
		"money": SEED_MONEY,
		"clears_at_level": 0,
		"reputation": {"home": 0, "noryangjin": 0, "gwangjang": 0},
		"stock": {},
		"unlocks": {"markets": ["home"]},
		"stats": {"plays": 0, "passes": 0, "best_stars": {}, "total_stars": 0},
		"intimacy": {},
		"player_char": "",
		"settings": {"haptics": true, "volume": 1.0, "subtitle_kr": false},
	}


# --- core accessors ---
func level() -> int:
	return int(data.get("level", 1))


func money() -> int:
	return int(data.get("money", 0))


func add_money(amount: int) -> void:
	data["money"] = money() + amount
	money_changed.emit(money())
	_save()


func spend_money(amount: int) -> bool:
	if money() < amount:
		return false
	data["money"] = money() - amount
	money_changed.emit(money())
	_save()
	return true


# --- per-menu stock (consumable servings) ---
func stock_of(menu_id: String) -> int:
	var s: Dictionary = data.get("stock", {})
	return int(s.get(menu_id, START_STOCK))


func consume_stock(menu_id: String) -> bool:
	var cur: int = stock_of(menu_id)
	if cur <= 0:
		return false
	data["stock"][menu_id] = cur - 1
	_save()
	return true


func restock(menu_id: String) -> bool:
	if not spend_money(RESTOCK_COST):
		return false
	data["stock"][menu_id] = stock_of(menu_id) + RESTOCK_QTY
	_save()
	return true


# --- round recording + level-up ---
## Records a round. Returns true if a level-up happened.
func record_round(menu_id: String, stars: int, passed: bool, market: String = "home") -> bool:
	var stats: Dictionary = data["stats"]
	stats["plays"] = int(stats.get("plays", 0)) + 1
	var best: Dictionary = stats["best_stars"]
	var prev: int = int(best.get(menu_id, 0))
	if stars > prev:
		stats["total_stars"] = int(stats.get("total_stars", 0)) + (stars - prev)
		best[menu_id] = stars
	var leveled := false
	if passed:
		stats["passes"] = int(stats.get("passes", 0)) + 1
		var rep: Dictionary = data["reputation"]
		rep[market] = int(rep.get(market, 0)) + 1
		leveled = _try_level_up()
	_save()
	return leveled


func _try_level_up() -> bool:
	var lv: int = level()
	if lv >= MAX_LEVEL:
		return false
	data["clears_at_level"] = int(data.get("clears_at_level", 0)) + 1
	var req: int = int(CLEARS_REQ.get(lv, 6))
	if int(data["clears_at_level"]) >= req:
		var nl: int = lv + 1
		data["level"] = nl
		data["clears_at_level"] = 0
		# unlock market for the new level
		var mk: String = String(MenuDB.get_level(nl).get("market", "home"))
		var mks: Array = data["unlocks"]["markets"]
		if not mks.has(mk):
			mks.append(mk)
		_pending_levelup = nl
		level_up.emit(nl)
		return true
	return false


## Returns the level a level-up just reached (for a toast), then clears it. 0 = none.
func consume_levelup_notice() -> int:
	var v: int = _pending_levelup
	_pending_levelup = 0
	return v


# --- guest intimacy ---
func intimacy_of(guest_id: String) -> float:
	return float((data.get("intimacy", {}) as Dictionary).get(guest_id, 0.0))


func add_intimacy(guest_id: String, delta: float) -> void:
	var im: Dictionary = data["intimacy"]
	im[guest_id] = clampf(intimacy_of(guest_id) + delta, 0.0, 5.0)
	_save()


# --- settings ---
func get_setting(key: String, fallback):
	return (data.get("settings", {}) as Dictionary).get(key, fallback)


func set_setting(key: String, value) -> void:
	data["settings"][key] = value
	_save()


# --- back-compat (old A2 API) ---
func record_result(food_id: StringName, stars: int) -> bool:
	var key := String(food_id)
	var best: Dictionary = data["stats"]["best_stars"]
	var prev: int = int(best.get(key, 0))
	if stars > prev:
		data["stats"]["total_stars"] = int(data["stats"].get("total_stars", 0)) + (stars - prev)
		best[key] = stars
		_save()
		return true
	return false


func best_of(food_id: StringName) -> int:
	return int((data["stats"]["best_stars"] as Dictionary).get(String(food_id), 0))


func is_cleared(food_id: StringName) -> bool:
	return best_of(food_id) >= 1


func cleared_count() -> int:
	var n := 0
	for k in (data["stats"]["best_stars"] as Dictionary).keys():
		if int(data["stats"]["best_stars"][k]) >= 1:
			n += 1
	return n


func three_star_count() -> int:
	var n := 0
	for k in (data["stats"]["best_stars"] as Dictionary).keys():
		if int(data["stats"]["best_stars"][k]) >= 3:
			n += 1
	return n


var total_stars: int:
	get:
		return int(data.get("stats", {}).get("total_stars", 0))


# --- persistence ---
func _load() -> void:
	data = _default_data()
	if not FileAccess.file_exists(SAVE_PATH):
		_save()
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var txt := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(txt)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("SaveManager: corrupt save, starting fresh")
		_save()
		return
	# shallow-merge into defaults so new fields appear after updates
	_merge(data, parsed as Dictionary)
	# future: migrate by data["version"] here


func _merge(base: Dictionary, over: Dictionary) -> void:
	for k in over.keys():
		if base.has(k) and typeof(base[k]) == TYPE_DICTIONARY and typeof(over[k]) == TYPE_DICTIONARY:
			_merge(base[k], over[k])
		else:
			base[k] = over[k]


func _save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_error("SaveManager: cannot write " + SAVE_PATH)
		return
	f.store_string(JSON.stringify(data, "\t"))
	f.close()


## (dev) wipe progress.
func reset_progress() -> void:
	data = _default_data()
	_pending_levelup = 0
	_save()
