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
const SCHEMA_VERSION: int = 2
const SEED_MONEY: int = 50000
const START_STOCK: int = 3
const RESTOCK_QTY: int = 3
const RESTOCK_COST: int = 2000
const MAX_LEVEL: int = 8

# clears needed to advance FROM level L to L+1 (~41 rounds L1->L8)
const CLEARS_REQ := {1: 4, 2: 5, 3: 5, 4: 6, 5: 6, 6: 7, 7: 8}

# Guest System 2.0 (v2 schema): friendship 0~10 milestones.
const FRIENDSHIP_MAX: int = 10
const FRIENDSHIP_MILESTONES := [3, 7, 10]

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")

var data: Dictionary = {}
var _pending_levelup: int = 0   # 0 = none; consumed by menu grid for toast
# Guest System 2.0: pending milestone toast — Dictionary {guest_id: milestone_value(3/7/10)}.
var _pending_milestones: Dictionary = {}


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
		# Guest System 2.0 (v2): integer 0~10 friendship per guest_id. Legacy "intimacy"
		# is kept for the existing 5-heart UI display path; "friendship" is the new
		# canonical progression.
		"friendship": {},
		# Result Screen 2.0: per (food_id, guest_id) high-score record (int 0~10000).
		# Layout: data["records"][food_id][guest_id] = score_final_int.
		"records": {},
		# Result Screen 2.0: per food_id cumulative recipe XP (int). Level curve in
		# data/recipe_xp.csv; level is derived (not stored).
		"recipe_xp": {},
		"player_char": "",
		# Player-Chef Integration (2026-06-08): 플레이어가 선택한 본인 셰프 아바타 성별.
		# "" = 미선택(최초 진입 시 gender select 화면), "f" = 여 셰프, "m" = 남 셰프.
		# 신규 1필드 — 기존 save는 _merge()로 backward-compatible(필드 없으면 default "" 유지).
		# scoring/economy/progression 무관 — 순수 visual 선택.
		"player_chef_gender": "",
		# Player-Name Personalization (2026-06-08): 플레이어가 직접 입력한 본인 셰프 이름.
		# "" = 미입력(gender select 직후 name entry 화면). guest 7명 이름과 분리된 순수 visual 필드.
		# 신규 1필드 — 기존 save는 _merge()로 backward-compatible(필드 없으면 default "" 유지 → name entry 1회).
		# scoring/CSV/economy/progression 무관 — host 라벨 표시에만 사용.
		"player_name": "",
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


# --- guest intimacy (legacy 0~5 float — kept for old 5-heart UI display) ---
func intimacy_of(guest_id: String) -> float:
	return float((data.get("intimacy", {}) as Dictionary).get(guest_id, 0.0))


func add_intimacy(guest_id: String, delta: float) -> void:
	var im: Dictionary = data["intimacy"]
	im[guest_id] = clampf(intimacy_of(guest_id) + delta, 0.0, 5.0)
	_save()


# --- Guest System 2.0: friendship 0~10 (v2 schema) ---
## Current friendship level (0~10) for a guest.
func friendship_of(guest_id: String) -> int:
	return int((data.get("friendship", {}) as Dictionary).get(guest_id, 0))


## Adds delta to friendship, clamps 0~10, queues a milestone toast if 3/7/10 was just
## reached. Returns the new friendship value.
func add_friendship(guest_id: String, delta: int) -> int:
	var fr: Dictionary = data["friendship"]
	var prev: int = friendship_of(guest_id)
	var nv: int = clampi(prev + delta, 0, FRIENDSHIP_MAX)
	fr[guest_id] = nv
	for ms in FRIENDSHIP_MILESTONES:
		if prev < int(ms) and nv >= int(ms):
			_pending_milestones[guest_id] = int(ms)
			break
	# also bump legacy intimacy so existing star display stays in sync (0~10 -> 0~5)
	var im: Dictionary = data["intimacy"]
	im[guest_id] = clampf(float(nv) * 0.5, 0.0, 5.0)
	_save()
	return nv


## Returns the milestone (3/7/10) just reached for this guest (and consumes it), 0 = none.
func friendship_milestone_pending(guest_id: String) -> int:
	if not _pending_milestones.has(guest_id):
		return 0
	var v: int = int(_pending_milestones[guest_id])
	_pending_milestones.erase(guest_id)
	return v


# --- Result Screen 2.0: per (food_id, guest_id) score records ---
## Returns the previously stored high-score for (food, guest), or 0 if none.
func record_of(food_id: String, guest_id: String) -> int:
	var recs: Dictionary = data.get("records", {}) as Dictionary
	if not recs.has(food_id):
		return 0
	var by_guest: Dictionary = recs[food_id] as Dictionary
	return int(by_guest.get(guest_id, 0))


## Tests whether the new score breaks the record for (food, guest). Updates and
## persists on success. Returns true if a new record was set (including the very
## first round for this pair).
func check_record(food_id: String, guest_id: String, score_int: int) -> bool:
	var recs: Dictionary = data.get("records", {}) as Dictionary
	if not recs.has(food_id):
		recs[food_id] = {}
	var by_guest: Dictionary = recs[food_id] as Dictionary
	var prev: int = int(by_guest.get(guest_id, -1))  # -1 = never played
	if score_int > prev:
		by_guest[guest_id] = score_int
		data["records"] = recs
		_save()
		return true
	return false


# --- Result Screen 2.0: per food_id recipe XP (cumulative int) ---
## Cumulative XP earned on this menu. 0 if never cooked.
func recipe_xp_of(food_id: String) -> int:
	var xp: Dictionary = data.get("recipe_xp", {}) as Dictionary
	return int(xp.get(food_id, 0))


## Adds XP to a menu's cumulative pool and persists. Returns the post-add total.
## Level computation (RecipeXP autoload) is intentionally external — this stays a
## dumb counter so the curve can be re-tuned without touching saves.
func add_recipe_xp(food_id: String, xp_delta: int) -> int:
	var xp: Dictionary = data.get("recipe_xp", {}) as Dictionary
	var nv: int = maxi(0, recipe_xp_of(food_id) + xp_delta)
	xp[food_id] = nv
	data["recipe_xp"] = xp
	_save()
	return nv


# --- player chef avatar (성별 선택, visual only) ---
## 선택된 플레이어 셰프 성별: "f"/"m", 미선택 시 "". scoring/economy 무관.
func player_chef_gender() -> String:
	return String(data.get("player_chef_gender", ""))


## 플레이어가 gender select에서 셰프 성별을 골랐는지(최초 1회 게이트용).
func has_chosen_chef() -> bool:
	var g: String = player_chef_gender()
	return g == "f" or g == "m"


## 셰프 성별 저장 ("f"/"m"). 잘못된 값은 무시. 재선택(설정)도 이 경로로.
func set_player_chef_gender(gender: String) -> void:
	if gender != "f" and gender != "m":
		return
	data["player_chef_gender"] = gender
	_save()


# --- player name (입력 개인화, visual only) ---
const PLAYER_NAME_MAX: int = 12
const PLAYER_NAME_FALLBACK: String = "My Chef"

## 입력값을 표시용 셰프 이름으로 정규화: trim + 내부 공백 squash + 최대 길이 clamp.
## 빈/공백뿐인 값은 ""을 반환(저장 측에서 fallback 처리). scoring/CSV 무관 — 순수 표시.
static func sanitize_player_name(raw: String) -> String:
	var s: String = raw.strip_edges()
	if s == "":
		return ""
	# 내부 연속 공백을 단일 공백으로 squash (탭/개행도 공백 취급).
	s = s.replace("\t", " ").replace("\n", " ").replace("\r", " ")
	while s.find("  ") != -1:
		s = s.replace("  ", " ")
	s = s.strip_edges()
	if s.length() > PLAYER_NAME_MAX:
		s = s.substr(0, PLAYER_NAME_MAX).strip_edges()
	return s


## 저장된 플레이어 셰프 이름. 미입력 시 "". host 라벨 표시에만 사용.
func player_name() -> String:
	return String(data.get("player_name", ""))


## 표시용 이름: 입력값 있으면 그대로, 없으면 fallback("My Chef"). UI host 라벨용.
func player_name_display() -> String:
	var n: String = player_name()
	return n if n != "" else PLAYER_NAME_FALLBACK


## 플레이어가 셰프 이름을 입력했는지(최초 1회 게이트용). trim 후 비어있지 않아야 true.
func has_player_name() -> bool:
	return player_name() != ""


## 셰프 이름 저장. trim/길이 정규화 후 저장. 정규화 결과가 빈 값이면 저장하지 않음(false).
## 재입력(설정)도 이 경로로. 반환: 저장 성공 여부.
func set_player_name(raw: String) -> bool:
	var clean: String = sanitize_player_name(raw)
	if clean == "":
		return false
	data["player_name"] = clean
	_save()
	return true


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
	# Guest System 2.0: v1 -> v2 migration. v1 had only "intimacy" (0~5 float). v2 adds
	# "friendship" (0~10 int) as the canonical progression. Project legacy intimacy onto
	# friendship by rounding (0~5) * 2.
	var ver: int = int(data.get("version", 1))
	if ver < 2:
		_migrate_v1_to_v2()
	data["version"] = SCHEMA_VERSION
	_save()


func _migrate_v1_to_v2() -> void:
	if not data.has("friendship") or typeof(data["friendship"]) != TYPE_DICTIONARY:
		data["friendship"] = {}
	var fr: Dictionary = data["friendship"]
	var im: Dictionary = data.get("intimacy", {}) as Dictionary
	for gid in im.keys():
		# legacy intimacy stored as float 0~5; project to integer 0~10
		var legacy_val: float = float(im[gid])
		var projected: int = clampi(int(round(legacy_val * 2.0)), 0, FRIENDSHIP_MAX)
		# never overwrite an already-present v2 value
		if not fr.has(gid):
			fr[gid] = projected
	print("[SaveManager] migrated v1 -> v2: friendship=", fr)


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
