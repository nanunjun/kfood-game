## MoodSystem — deterministic daily mood per guest (autoload).
##
## Hashes today's date (YYYY-MM-DD) with the guest_id and picks an entry from the
## guest's mood_pool (CSV column). Same hash all day -> stable across screens;
## changes naturally at midnight. Falls back to "easy" if guest has no pool.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")

const DEFAULT_MOOD: String = "easy"

# Optional dev override — when non-empty, today() returns this for ANY guest.
# Useful for verification screenshots (e.g. force Junho=happy + Mina=easy to
# reproduce the spec examples 93% / 62%).
var dev_override: String = ""


## Mood for the given guest "today". Deterministic per (date, guest_id).
func today(guest_id: String) -> String:
	if dev_override != "":
		return dev_override
	var guest: Dictionary = MenuDB.get_guest(guest_id)
	if guest.is_empty():
		return DEFAULT_MOOD
	var pool: Array = guest.get("mood_pool", []) as Array
	if pool.is_empty():
		return DEFAULT_MOOD
	var date: String = Time.get_date_string_from_system()
	var key: String = "%s_%s" % [date, guest_id]
	var idx: int = absi(key.hash()) % pool.size()
	return String(pool[idx])


## Human-friendly label for UI badges.
func label(mood: String) -> String:
	match mood:
		"hungry": return "Hungry"
		"happy":  return "Happy"
		"easy":   return "Easy"
		"picky":  return "Picky"
		"grumpy": return "Grumpy"
	return mood.capitalize()


## Color hint per mood (used by mood_badge bg).
func color(mood: String) -> Color:
	match mood:
		"hungry": return Color(0.92, 0.55, 0.20)
		"happy":  return Color(0.98, 0.78, 0.30)
		"easy":   return Color(0.55, 0.78, 0.55)
		"picky":  return Color(0.55, 0.55, 0.85)
		"grumpy": return Color(0.70, 0.40, 0.40)
	return Color(0.7, 0.7, 0.7)


## Emoji-style icon (single-char placeholder until art-director ships sprites).
func icon(mood: String) -> String:
	match mood:
		"hungry": return "H"
		"happy":  return ":)"
		"easy":   return "~"
		"picky":  return "?"
		"grumpy": return ">("
	return "?"
