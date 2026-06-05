## PlateModule — vessel + garnish selection (ADR-011).
##
## Player picks one of 3 vessels (best / 2nd / bad — shuffled). Tier maps directly to
## score: best=100, 2nd=70, bad=20. This preserves the old "dish choice" tier-bonus
## logic from rhythm_proto.gd while folding it into the module pipeline.
extends "res://scripts/cooking_modules/base_module.gd"

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")

var _options: Array = []   # [{dish_id, tier, info}]
var _menu: Dictionary = {}
var _chosen_dish: String = ""
var _chosen_tier: String = ""


func _module_start(params: Dictionary) -> void:
	# D3: shared cooking BG behind everything (plate "tasting" feel)
	_attach_cooking_bg(1030.0)
	_menu = params.get("menu", {})
	_build_header("Plate", "Pick the dish that suits %s best." % String(_menu.get("name_en", "this")))
	_options = [
		{"dish_id": String(_menu.get("dish_best", "")), "tier": "best"},
		{"dish_id": String(_menu.get("dish_2nd", "")),  "tier": "2nd"},
		{"dish_id": String(_menu.get("dish_bad", "")),  "tier": "bad"},
	]
	_options.shuffle()

	# Big food + 3 vessel buttons
	var card := Panel.new()
	card.position = Vector2(140, 800)
	card.size = Vector2(800, 460)
	var csb := StyleBoxFlat.new()
	csb.bg_color = Color(0.96, 0.92, 0.84)
	csb.set_corner_radius_all(28)
	csb.set_border_width_all(4)
	csb.border_color = Color(0.84, 0.72, 0.52)
	card.add_theme_stylebox_override("panel", csb)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(card)
	if bool(_menu.get("ready", false)):
		var tex: Texture2D = load(String(_menu.get("food_img", "")))
		if tex != null:
			# D3: dish shadow under the hero food (plate moment)
			_attach_dish_shadow(Vector2(540, 1230), 540.0)
			var thumb := TextureRect.new()
			thumb.texture = tex
			thumb.position = Vector2(180, 820)
			thumb.size = Vector2(720, 420)
			thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(thumb)

	# Vessel buttons
	var btn_w := 300.0
	var gap := 40.0
	var total := 3.0 * btn_w + 2.0 * gap
	var x0: float = (1080.0 - total) * 0.5
	for i in range(_options.size()):
		var opt: Dictionary = _options[i]
		var dish_id: String = String(opt["dish_id"])
		var info: Dictionary = MenuDB.vessel(dish_id)
		var b := Button.new()
		b.text = "%s\n(%s)" % [info.get("name_en", dish_id), info.get("name_kr", "")]
		b.position = Vector2(x0 + float(i) * (btn_w + gap), 1380)
		b.size = Vector2(btn_w, 320)
		b.add_theme_font_size_override("font_size", 32)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var psb := StyleBoxFlat.new()
		psb.bg_color = Color(info.get("color", Color(0.85, 0.85, 0.85)))
		psb.set_corner_radius_all(28)
		psb.set_border_width_all(4)
		psb.border_color = psb.bg_color.darkened(0.25)
		psb.shadow_size = 6
		psb.shadow_color = Color(0, 0, 0, 0.20)
		b.add_theme_stylebox_override("normal", psb)
		b.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
		b.pressed.connect(_on_pick.bind(dish_id, String(opt["tier"])))
		add_child(b)


func _on_pick(dish_id: String, tier: String) -> void:
	if _finished:
		return
	_chosen_dish = dish_id
	_chosen_tier = tier
	var score: float
	match tier:
		"best": score = 100.0
		"2nd":  score = 70.0
		"bad":  score = 20.0
		_:      score = 50.0
	var j := RhythmJudge.PERFECT if tier == "best" else (RhythmJudge.GOOD if tier == "2nd" else RhythmJudge.MISS)
	_safe_feedback(j, Vector2(540, 1100))
	_finish(score)


## Runner reads these after `module_completed` to feed dish_bonus into the result payload.
func get_chosen_dish() -> String:
	return _chosen_dish


func get_chosen_tier() -> String:
	return _chosen_tier
