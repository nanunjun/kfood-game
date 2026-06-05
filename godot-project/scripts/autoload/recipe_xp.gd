## RecipeXP — per-menu mastery curve (autoload).
##
## Loads data/recipe_xp.csv (Lv 1~10 cumulative XP curve) at boot and exposes:
##   - level_of(cum_xp) -> int                   # 1..10
##   - xp_for_next_level(cum_xp) -> int          # 0 at max level
##   - level_up_reward(level) -> int             # coin payout on hitting that level
##   - xp_to_reach(level) -> int                 # cumulative XP threshold for that level
##
## Spec (game-designer lock):
##   xp_gain = 10 * stars + (compat / 10) + (new_record ? 20 : 0)   (~26 avg/round)
##   T1 lv10 ~= 120 rounds.
extends Node

const RECIPE_CSV: String = "res://data/recipe_xp.csv"
const MAX_LEVEL: int = 10

# Loaded curve: level -> {xp_required, cum_xp, level_up_reward}.
var _curve: Dictionary = {}
var _loaded: bool = false


func _ready() -> void:
	_load()


func _load() -> void:
	if _loaded:
		return
	_loaded = true
	var f := FileAccess.open(RECIPE_CSV, FileAccess.READ)
	if f == null:
		push_warning("RecipeXP: cannot open " + RECIPE_CSV + " (using fallback curve)")
		_load_fallback()
		return
	var header := f.get_csv_line(",")
	var idx: Dictionary = {}
	for i in range(header.size()):
		idx[String(header[i]).strip_edges()] = i
	while not f.eof_reached():
		var row := f.get_csv_line(",")
		if row.size() < 1 or String(row[0]).strip_edges() == "":
			continue
		var lv: int = int(String(row[int(idx.get("level", 0))]).strip_edges())
		if lv <= 0:
			continue
		_curve[lv] = {
			"xp_required": int(String(row[int(idx.get("xp_required", 1))]).strip_edges()),
			"cum_xp": int(String(row[int(idx.get("cum_xp", 2))]).strip_edges()),
			"level_up_reward": int(String(row[int(idx.get("level_up_reward", 3))]).strip_edges()),
		}
	f.close()
	if _curve.is_empty():
		_load_fallback()


func _load_fallback() -> void:
	# 합리적인 fallback (CSV가 없을 때만 사용).
	var cum: int = 0
	var reqs: Array = [0, 30, 60, 90, 120, 150, 180, 210, 240, 280]
	var rewards: Array = [0, 200, 300, 400, 500, 700, 900, 1200, 1500, 2000]
	for i in range(MAX_LEVEL):
		cum += int(reqs[i])
		_curve[i + 1] = {
			"xp_required": int(reqs[i]),
			"cum_xp": cum,
			"level_up_reward": int(rewards[i]),
		}


## Returns the menu's current level given its cumulative XP.
func level_of(cum_xp: int) -> int:
	var lvl: int = 1
	for k in _curve.keys():
		if int(k) > MAX_LEVEL:
			continue
		if cum_xp >= int(_curve[k].get("cum_xp", 0)):
			lvl = int(k)
	return clampi(lvl, 1, MAX_LEVEL)


## XP remaining to reach the next level. 0 at MAX_LEVEL.
func xp_for_next_level(cum_xp: int) -> int:
	var cur: int = level_of(cum_xp)
	if cur >= MAX_LEVEL:
		return 0
	var next_threshold: int = int(_curve.get(cur + 1, {}).get("cum_xp", 0))
	return maxi(0, next_threshold - cum_xp)


## Reward coin payout for hitting `level` (game-designer curve).
func level_up_reward(level: int) -> int:
	return int(_curve.get(level, {}).get("level_up_reward", 0))


## Cumulative XP threshold for `level` (Lv1 = 0).
func xp_to_reach(level: int) -> int:
	return int(_curve.get(level, {}).get("cum_xp", 0))


## Helper: returns {level, xp_in_level, xp_for_next, progress_pct} for UI.
func progress(cum_xp: int) -> Dictionary:
	var lvl: int = level_of(cum_xp)
	if lvl >= MAX_LEVEL:
		return {
			"level": MAX_LEVEL,
			"xp_in_level": 0,
			"xp_for_next": 0,
			"progress_pct": 100,
			"is_max": true,
		}
	var floor_xp: int = xp_to_reach(lvl)
	var next_xp: int = xp_to_reach(lvl + 1)
	var span: int = maxi(1, next_xp - floor_xp)
	var into: int = maxi(0, cum_xp - floor_xp)
	return {
		"level": lvl,
		"xp_in_level": into,
		"xp_for_next": maxi(0, next_xp - cum_xp),
		"progress_pct": clampi(int(round(float(into) * 100.0 / float(span))), 0, 100),
		"is_max": false,
	}


## Spec-locked XP earn for a round.
func xp_gain(stars: int, compat: int, new_record: bool) -> int:
	return 10 * stars + int(compat / 10) + (20 if new_record else 0)
