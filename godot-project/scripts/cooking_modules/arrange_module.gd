## ArrangeModule — drag/drop ingredient placement (ADR-011).
##
## MVP: N ingredient buttons + N target slots. Tap an ingredient, then tap a slot —
## correct slot = +1. Final score = correct_count / total * 100.
## (Full drag-and-drop is a polish pass for the art sprint; the placement % math is the
## same so swapping to gesture input later is non-breaking.)
##
## Phase A art-swap (2026-06-04): ingredient buttons → LOCK ingredient cut sprites
## (재료별 cut 그림이 도구 없이 자체 표시) — 김밥/비빔밥 등 arrange-driven 음식의
## ingredient identification 강화. 색상 swatch은 fallback으로만 유지.
extends "res://scripts/cooking_modules/base_module.gd"

const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")

const DEFAULT_SLOT_COUNT: int = 5
const COLORS: Array[Color] = [
	Color(0.92, 0.32, 0.22),  # red — carrot/kimchi
	Color(0.96, 0.84, 0.32),  # yellow — egg
	Color(0.46, 0.78, 0.34),  # green — spinach/scallion
	Color(0.94, 0.94, 0.92),  # white — rice/radish
	Color(0.36, 0.22, 0.16),  # brown — beef/seaweed
	Color(0.85, 0.40, 0.70),  # pink — pickled
]
# Phase A: arrange-driven 음식의 hero ingredient cut sprite을 ingredient[0]에 표시.
# 슬롯이 5~6개라 모두를 다른 음식 sprite으로 채우긴 부족하지만, 최소 hero ingredient는
# LOCK art로 표시되어 "무엇을 정렬 중인가" 즉시 인지.

var _slot_count: int = DEFAULT_SLOT_COUNT
var _selected_idx: int = -1
var _placed: Array = []           # idx of ingredient placed in slot (-1 if empty)
var _ing_btns: Array[Button] = []
var _slot_btns: Array[Button] = []
var _correct_count: int = 0


func _module_start(params: Dictionary) -> void:
	# D3: shared cooking BG behind everything.
	_attach_cooking_bg(700.0)
	_build_header("Arrange", "Tap an ingredient, then tap its matching slot.")
	_slot_count = clampi(int(params.get("slot_count", DEFAULT_SLOT_COUNT)), 2, 6)
	_placed.resize(_slot_count)
	for i in range(_slot_count):
		_placed[i] = -1

	# Phase A: 음식 hero 그림 — 상단 중앙 (어떤 음식을 arrange하는지 즉시 인지)
	var food_id_hdr: StringName = StringName(String(params.get("food_id", "")))
	var food_img: String = ArtRegistry.food(food_id_hdr)
	if ArtRegistry.file_exists(food_img):
		var hero := TextureRect.new()
		hero.texture = load(food_img)
		hero.position = Vector2(380, 280)
		hero.size = Vector2(320, 320)
		hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hero.modulate = Color(1, 1, 1, 0.85)
		add_child(hero)

	# Slot row (targets) — top half
	var slot_y := 700.0
	var slot_w := 160.0
	var gap := 24.0
	var total_w: float = float(_slot_count) * slot_w + float(_slot_count - 1) * gap
	var slot_x0 := (1080.0 - total_w) * 0.5
	for i in range(_slot_count):
		var slot := Button.new()
		slot.text = "%d" % (i + 1)
		slot.position = Vector2(slot_x0 + float(i) * (slot_w + gap), slot_y)
		slot.size = Vector2(slot_w, slot_w)
		slot.add_theme_font_size_override("font_size", 56)
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.86, 0.78, 0.66)
		sb.set_corner_radius_all(20)
		sb.set_border_width_all(4)
		sb.border_color = Color(0.55, 0.40, 0.22)
		slot.add_theme_stylebox_override("normal", sb)
		slot.add_theme_color_override("font_color", Color(0.40, 0.30, 0.20))
		slot.pressed.connect(_on_slot.bind(i))
		add_child(slot)
		_slot_btns.append(slot)

	# Shuffle the ingredient order so the player has to think
	var ing_order: Array = range(_slot_count)
	ing_order.shuffle()

	# Ingredient row — bottom half (Phase A: hero ingredient sprite on first slot)
	var food_id: StringName = StringName(String(params.get("food_id", "")))
	var hero_cut_path: String = ArtRegistry.prep_cut(food_id)
	var hero_whole_path: String = ArtRegistry.prep_whole(food_id)
	var ing_y := 1400.0
	var ing_w := 150.0
	var igap := 20.0
	var itotal: float = float(_slot_count) * ing_w + float(_slot_count - 1) * igap
	var ing_x0 := (1080.0 - itotal) * 0.5
	for i in range(_slot_count):
		var actual_id: int = int(ing_order[i])
		var b := Button.new()
		b.text = ""
		b.position = Vector2(ing_x0 + float(i) * (ing_w + igap), ing_y)
		b.size = Vector2(ing_w, ing_w)
		var sb := StyleBoxFlat.new()
		sb.bg_color = COLORS[actual_id % COLORS.size()]
		sb.set_corner_radius_all(20)
		sb.shadow_size = 4
		sb.shadow_color = Color(0, 0, 0, 0.25)
		b.add_theme_stylebox_override("normal", sb)
		b.set_meta("correct_slot", actual_id)
		b.pressed.connect(_on_ingredient.bind(i, actual_id))
		add_child(b)
		_ing_btns.append(b)

		# Phase A overlay — hero ingredient art icon on top of color swatch.
		# 모든 slot에 동일한 hero art 표시는 색-구분 단서를 망가뜨리므로,
		# 음식의 hero ingredient는 i==0 (또는 actual_id==0) slot 1곳만 art icon으로 표시.
		# 나머지는 색 swatch만 유지 (current arrange 메커닉의 distractor 신호 보존).
		if actual_id == 0:
			var path: String = hero_cut_path if ArtRegistry.file_exists(hero_cut_path) else hero_whole_path
			if ArtRegistry.file_exists(path):
				var icon := TextureRect.new()
				icon.texture = load(path)
				icon.position = Vector2(ing_x0 + float(i) * (ing_w + igap) + 10, ing_y + 10)
				icon.size = Vector2(ing_w - 20, ing_w - 20)
				icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
				add_child(icon)

	# D2: small ActionPuck for "Auto-arrange" skip (replaces grey rectangular skip button)
	var skip_puck = _make_action_puck(Vector2(540, 1810), "AUTO", 160.0, 30)
	skip_puck.set_face_color(Color(0.55, 0.55, 0.55))
	skip_puck.pressed.connect(_on_auto)


func _on_ingredient(button_idx: int, correct_slot: int) -> void:
	if _finished:
		return
	_selected_idx = button_idx
	# Highlight selected
	for i in range(_ing_btns.size()):
		_ing_btns[i].modulate = Color(1, 1, 1, 1) if i == button_idx else Color(0.7, 0.7, 0.7, 1)
	# Re-store target for the matching slot
	_ing_btns[button_idx].set_meta("correct_slot", correct_slot)


func _on_slot(slot_idx: int) -> void:
	if _finished or _selected_idx < 0:
		return
	if _placed[slot_idx] != -1:
		return  # slot already filled — ignore (avoids double-scoring)
	var ing_btn: Button = _ing_btns[_selected_idx]
	var correct: int = int(ing_btn.get_meta("correct_slot"))
	_placed[slot_idx] = _selected_idx
	var ok: bool = correct == slot_idx
	if ok:
		_correct_count += 1
	# Visually fill the slot with the ingredient color + checkmark / X
	var sb := _slot_btns[slot_idx].get_theme_stylebox("normal") as StyleBoxFlat
	if sb:
		sb.bg_color = ing_btn.get_theme_stylebox("normal").bg_color if ok else Color(0.55, 0.40, 0.36)
		sb.border_color = Color(0.30, 0.65, 0.30) if ok else Color(0.80, 0.30, 0.25)
	_slot_btns[slot_idx].text = "✓" if ok else "✕"
	# Disable the placed ingredient
	ing_btn.disabled = true
	ing_btn.modulate = Color(0.45, 0.45, 0.45, 0.6)
	_selected_idx = -1
	_safe_feedback(RhythmJudge.GOOD if ok else RhythmJudge.MISS, _slot_btns[slot_idx].position + _slot_btns[slot_idx].size * 0.5)
	# All slots filled? finalize
	var all_filled := true
	for p in _placed:
		if int(p) == -1:
			all_filled = false
			break
	if all_filled:
		var score: float = float(_correct_count) / float(_slot_count) * 100.0
		_finish(score)


func _on_auto() -> void:
	if _finished:
		return
	_finish(60.0)
