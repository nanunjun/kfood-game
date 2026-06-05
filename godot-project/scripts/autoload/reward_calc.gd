## RewardCalc — final reward shaping for Guest System 2.0 (autoload).
##
## Combines:
##   1) compat -> multiplier (>=90:1.30 / 70~89:1.15 / 50~69:1.00 / 30~49:0.85 / <30:0.70)
##   2) guest.reward_bonus (CSV column, e.g. 1.20 for friends, 2.00 for goldspoon evaluator)
##
## Use: RewardCalc.final(base_reward, compat, guest) -> int
##      RewardCalc.bonus_multiplier(compat) -> float (display the "1.30x" pill)
##      RewardCalc.compat_color(compat) -> Color (UI band tint)
extends Node


## Pure multiplier from compat 0~100. See spec for thresholds.
func bonus_multiplier(compat: int) -> float:
	if compat >= 90: return 1.30
	elif compat >= 70: return 1.15
	elif compat >= 50: return 1.00
	elif compat >= 30: return 0.85
	return 0.70


## Final integer reward = base * guest.reward_bonus * bonus_multiplier(compat).
func final(base: int, compat: int, guest: Dictionary) -> int:
	var gb: float = float(guest.get("reward_bonus", 1.0))
	var mult: float = bonus_multiplier(compat)
	return int(round(float(base) * gb * mult))


## Band color for the compat reward bar (red -> amber -> green gradient).
func compat_color(compat: int) -> Color:
	if compat >= 90: return Color(0.30, 0.78, 0.40)   # vibrant green
	elif compat >= 70: return Color(0.55, 0.78, 0.40)  # lime
	elif compat >= 50: return Color(0.95, 0.82, 0.30)  # amber
	elif compat >= 30: return Color(0.92, 0.55, 0.25)  # orange
	return Color(0.82, 0.30, 0.25)                     # red


## Tier label used by the recommended-card pulse.
func tier(compat: int) -> String:
	if compat >= 90: return "perfect"
	elif compat >= 70: return "great"
	elif compat >= 50: return "ok"
	elif compat >= 30: return "weak"
	return "bad"


# --- Result Screen 2.0 helpers ---

## Emotion bucket used by ReactionDB + emotion_reaction component.
## Rule (game-designer lock):
##   excellent = (stars >= 3 AND compat >= 70) OR compat >= 90
##   good      = stars >= 3 OR (compat in 70~89)
##   okay      = stars >= 2 OR (compat in 50~69)
##   bad       = otherwise
func emotion_level(stars: int, compat: int) -> String:
	if (stars >= 3 and compat >= 70) or compat >= 90:
		return "excellent"
	if stars >= 3 or (compat >= 70 and compat < 90):
		return "good"
	if stars >= 2 or (compat >= 50 and compat < 70):
		return "okay"
	return "bad"


## Result Screen 2.0 — 6-row breakdown for the score panel. Each entry is:
##   {key, label, value_pct(0~100), tone("+"/"-"/"=") }
## Rows: 1) Prep  2) Cook  3) Season  4) Plating  5) Compat Bonus  6) Mood Modifier
## Inputs are 0~1 floats from the round (prep/cook/season/plating accuracy),
## an integer compat, the mood string, and the guest dict (for reward_bonus pill).
func score_breakdown_rows(prep: float, cook: float, season: float, plating: float,
		compat: int, mood: String, guest: Dictionary) -> Array:
	var rows: Array = []
	rows.append({
		"key": "prep", "label": "Prep",
		"value_pct": int(round(clampf(prep, 0.0, 1.0) * 100.0)),
		"tone": _tone_from_pct(int(round(prep * 100.0))),
		"note": "Chop / roll / knead accuracy",
	})
	rows.append({
		"key": "cook", "label": "Cook",
		"value_pct": int(round(clampf(cook, 0.0, 1.0) * 100.0)),
		"tone": _tone_from_pct(int(round(cook * 100.0))),
		"note": "Boil / fry / stir timing",
	})
	rows.append({
		"key": "season", "label": "Season",
		"value_pct": int(round(clampf(season, 0.0, 1.0) * 100.0)),
		"tone": _tone_from_pct(int(round(season * 100.0))),
		"note": "Flavor balance vs guest taste",
	})
	rows.append({
		"key": "plating", "label": "Plating",
		"value_pct": int(round(clampf(plating, 0.0, 1.0) * 100.0)),
		"tone": _tone_from_pct(int(round(plating * 100.0))),
		"note": "Vessel match",
	})
	# Compat bonus row — multiplier as %  (1.30x -> +30, 0.70x -> -30)
	var mult: float = bonus_multiplier(compat)
	var compat_pct: int = int(round((mult - 1.0) * 100.0))
	rows.append({
		"key": "compat_bonus", "label": "Compat Bonus",
		"value_pct": compat_pct,
		"tone": ("+" if compat_pct > 0 else ("-" if compat_pct < 0 else "=")),
		"note": "%d%% compat -> %.2fx" % [compat, mult],
	})
	# Mood modifier — qualitative descriptor (no flat %).
	var mood_lbl: String = mood_modifier_label(mood, compat >= 70, compat <= 40)
	rows.append({
		"key": "mood_modifier", "label": "Mood",
		"value_pct": 0,
		"tone": ("+" if compat >= 70 else ("-" if compat <= 40 else "=")),
		"note": mood_lbl,
	})
	return rows


## Short qualitative phrase for the mood row. `has_fav_hit` = compat indicates
## favorite-flavor match. `has_dis_hit` = compat is low / dislike-driven.
func mood_modifier_label(mood: String, has_fav_hit: bool, has_dis_hit: bool) -> String:
	match mood:
		"hungry":
			return "Hungry — flavors hit harder" if has_fav_hit else (
				"Hungry — but the dislikes still landed" if has_dis_hit else "Hungry mood")
		"happy":
			return "Happy — extra forgiving"
		"easy":
			return "Easy mood — neutral baseline"
		"picky":
			return "Picky — dislikes weigh heavier" if has_dis_hit else (
				"Picky — but you matched the favorites" if has_fav_hit else "Picky mood")
		"grumpy":
			return "Grumpy — dislikes really sting" if has_dis_hit else "Grumpy mood"
		_:
			return mood.capitalize() + " mood"


func _tone_from_pct(pct: int) -> String:
	if pct >= 70:
		return "+"
	if pct >= 45:
		return "="
	return "-"


## Result Screen 2.0 — final coin formula (game-designer lock):
##   final = base * compat_mult * guest.reward_bonus + (new_record ? 500 : 0) + milestone_payout
## milestone_payout: 3 -> 500, 7 -> 0 (compat perm reward instead), 10 -> 0 (skin instead).
## Spec keeps a small cash sweetener on Lv 3 milestone.
func final_with_bonuses(base: int, compat: int, guest: Dictionary,
		new_record: bool, milestone: int) -> int:
	var core: int = final(base, compat, guest)
	var record_bonus: int = 500 if new_record else 0
	var ms_pay: int = 0
	match milestone:
		3: ms_pay = 500
		_: ms_pay = 0
	return core + record_bonus + ms_pay


## Milestone label for the inline toast/banner copy.
func milestone_label(milestone: int) -> String:
	match milestone:
		3:  return "Lv 3 — line_ok unlocked & +500 coin bonus"
		7:  return "Lv 7 — Signature Dish unlocked + permanent +5% compat"
		10: return "Lv 10 — Portrait Skin unlocked + permanent +0.10x reward"
		_:  return ""
