## BaseModule — common base for the 8 ADR-011 cooking modules.
##
## Each concrete module extends this and implements `_module_start(params)` to set up its
## UI / timers. When the player finishes (or the timer expires), the module calls
## `_finish(score_pct)` with a 0~100 score; the runner listens for `module_completed`.
##
## D3 폴리시 (2026-06-04): base helper `_attach_cooking_bg()` + ActionPuck + dish shadow
## helpers — 8 module 모두 동일한 kitchen surface 위에 작업 (no more "floating in beige void").
class_name CookingModule
extends Control

const CookingBackgroundScript := preload("res://scripts/ui/cooking_background.gd")
const CookingFX := preload("res://scripts/ui/cooking_fx.gd")
const ActionPuckScript := preload("res://scripts/ui/action_puck.gd")

## Emitted exactly once when the player's interaction window closes for this module.
## score = 0~100 (clamped). Runner converts it to the 4-factor breakdown (prep / cook /
## timing / season / plating) per the ADR-011 score-mapping table.
signal module_completed(score: float)

## Standard input keys (Dictionary `params`):
##   food_id : String           — current dish (for asset lookups)
##   guest_id : String          — selected guest
##   level : Dictionary         — MenuDB.get_level(...) (perfect_ms, good_ms, tol, ...)
##   step_no / step_total : int — banner text "Step 2/5"
##   menu : Dictionary          — MenuDB.get_menu(food_id) (food_img, seasonings, ...)
##
## Modules MAY ignore any field they don't need; defaults are safe.
var _params: Dictionary = {}
var _finished: bool = false


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_PASS


## Runner entry-point. Subclasses override `_module_start(params)` instead.
func start(params: Dictionary) -> void:
	_params = params
	_finished = false
	_module_start(params)


## Override in subclass.
func _module_start(_params: Dictionary) -> void:
	pass


## Subclass calls this once. Re-entrant calls are ignored to avoid double-scoring.
func _finish(score_pct: float) -> void:
	if _finished:
		return
	_finished = true
	module_completed.emit(clampf(score_pct, 0.0, 100.0))


# --- helpers shared by every module ---

func _level_get(key: String, fallback) -> Variant:
	var lvl: Dictionary = _params.get("level", {})
	return lvl.get(key, fallback)


func _build_header(title: String, howto: String) -> void:
	var step_no: int = int(_params.get("step_no", 1))
	var step_total: int = int(_params.get("step_total", 1))
	var head := Label.new()
	head.name = "ModuleHeader"
	head.text = "Step %d/%d  ·  %s" % [step_no, step_total, title]
	head.position = Vector2(40, 56)
	head.size = Vector2(1000, 70)
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.add_theme_font_size_override("font_size", 40)
	head.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	add_child(head)
	var sub := Label.new()
	sub.name = "ModuleHowto"
	sub.text = howto
	sub.position = Vector2(40, 132)
	sub.size = Vector2(1000, 60)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.add_theme_font_size_override("font_size", 28)
	sub.add_theme_color_override("font_color", Color(0.45, 0.32, 0.18))
	add_child(sub)


func _safe_feedback(judgement: int, pos: Vector2) -> void:
	var fb := get_node_or_null("/root/FeedbackBus")
	if fb and fb.has_method("hit"):
		fb.hit(judgement, pos)


# --- D3 polish helpers (shared by all 8 cooking modules) ---

## Attach a shared kitchen background BEHIND everything in this module. Call FIRST in
## _module_start before adding tool/dish/puck nodes.  dish_anchor_y tunes where the
## warm spotlight pool lands (defaults to where most modules sit their food).
func _attach_cooking_bg(dish_anchor_y: float = 1000.0) -> void:
	var bg = CookingBackgroundScript.new()
	bg.dish_anchor_y = dish_anchor_y
	# Insert at index 0 so any header label / module art already added (header is added
	# after this call though, so order is naturally correct).
	add_child(bg)
	move_child(bg, 0)


## Drop an ActionPuck centered at `center` with the given label. Caller wires `pressed`.
## Returns the puck so caller can call flash_perfect / flash_miss / set_label later.
func _make_action_puck(center: Vector2, label: String, diam: float = 320.0,
		fsize: int = 64) -> ActionPuck:
	var puck = ActionPuckScript.new()
	puck.setup(label, center, diam, fsize)
	add_child(puck)
	return puck


## Add a soft dish shadow under `center` then return it. Pure visual.
func _attach_dish_shadow(center: Vector2, w: float = 360.0) -> Node:
	return CookingFX.attach_dish_shadow(self, center, w, w * 0.18, 0.32)


## Loop steam swirls above `anchor`. count=3 default.
func _attach_steam(anchor: Vector2, count: int = 3) -> Node:
	return CookingFX.attach_steam_loop(self, anchor, count)
