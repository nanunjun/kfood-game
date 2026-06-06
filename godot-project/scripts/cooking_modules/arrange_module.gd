## ArrangeModule — ACTION-FIRST press-drag-release ingredient placement (ADR-012).
##
## "I arranged the ingredients" — NOT "I auto-placed them". The player PRESSES an ingredient,
## DRAGS it to its matching color slot, and RELEASES; the ingredient follows the finger, the
## nearest slot magnet-glows, and on release it snaps & settles into place. Building the food
## structure (5-color kimbap band / 6-color bibimbap radial) by hand.
##
## ADR-012 input redesign (2026-06-05): tap-ingredient/tap-slot (+AUTO skip) 폐기 → press-drag-release.
##   - input: 재료를 집어(press) 정확한 슬롯으로 drag → 놓으면(release) 안착(snap settle).
##   - visual: 재료가 손가락 따라옴 → 슬롯 근처 magnet glow → release 시 snap settle.
##   - 3 states: 누락·비뚤 (틀린 슬롯/대충) / 오방색 균일 (정확 배치) / (과잉 없음).
##   - plate와 차별: arrange = raw 재료를 음식 구조로 입력 / plate = 완성 음식을 그릇에 sealing.
##
## SCORING 무변경 (§6.1 / §3.4): placement 정확도 = correct_count / slot_count → accuracy_prep
## ∈ [0,1]. 기존 tap-match placement 점수와 1:1 동일한 [0,100] score를 그대로
## `module_completed(score)` 로 emit — runner contract / MODULE_TO_FACTOR("arrange"->prep) 동일.
extends "res://scripts/cooking_modules/base_module.gd"

const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")
const TouchGesture := preload("res://scripts/cooking_modules/touch_gesture.gd")

const DEFAULT_SLOT_COUNT: int = 5
const COLORS: Array[Color] = [
	Color(0.92, 0.32, 0.22),  # red — carrot/kimchi
	Color(0.96, 0.84, 0.32),  # yellow — egg
	Color(0.46, 0.78, 0.34),  # green — spinach/scallion
	Color(0.94, 0.94, 0.92),  # white — rice/radish
	Color(0.36, 0.22, 0.16),  # brown — beef/seaweed
	Color(0.85, 0.40, 0.70),  # pink — pickled
]

const ING_SIZE: float = 150.0
const SLOT_SIZE: float = 160.0
const MAGNET_RADIUS: float = 130.0       # release 시 이 거리 안의 슬롯에 snap.

var _slot_count: int = DEFAULT_SLOT_COUNT
var _shape: String = "band"             # band(김밥 5색 띠) / radial(비빔밥 6색 방사형).
var _correct_count: int = 0
var _placed_total: int = 0

# 슬롯 데이터: {node(Panel), center(Vector2), color_id(int), filled(bool), glow}.
var _slots: Array = []
# 재료 데이터: {node(Control), color_id(int), home(Vector2), size, placed(bool)}.
var _ingredients: Array = []

var _gesture = null   # TouchGestureRecognizer (preloaded TouchGesture)
var _dragging_idx: int = -1
var _drag_offset: Vector2 = Vector2.ZERO
var _hint: Label = null
var _glow_slot_idx: int = -1


func _module_start(params: Dictionary) -> void:
	_attach_cooking_bg(700.0)
	_slot_count = clampi(int(params.get("slot_count", DEFAULT_SLOT_COUNT)), 2, 6)
	# 6색이면 방사형(비빔밥), 그 외 띠(김밥/국수 고명).
	_shape = "radial" if _slot_count >= 6 else "band"
	_build_header("Arrange", "Drag each ingredient into its matching slot.")

	# 음식 hero — 상단 (무엇을 arrange하는지 인지).
	var food_id: StringName = StringName(String(params.get("food_id", "")))
	var food_img: String = ArtRegistry.food(food_id)
	if ArtRegistry.file_exists(food_img):
		var hero := TextureRect.new()
		hero.texture = load(food_img)
		hero.position = Vector2(390, 250)
		hero.size = Vector2(300, 300)
		hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hero.modulate = Color(1, 1, 1, 0.82)
		add_child(hero)

	_build_slots()
	_build_ingredients(food_id)

	_hint = Label.new()
	_hint.position = Vector2(0, 1640)
	_hint.size = Vector2(1080, 70)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 40)
	_hint.add_theme_color_override("font_color", Color(0.45, 0.32, 0.18))
	_hint.text = "Pick up an ingredient and drag it to its color"
	add_child(_hint)

	# 입력 인식기 — press-drag-release.
	_gesture = TouchGesture.new()
	_gesture.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_gesture)
	_gesture.drag_started.connect(_on_drag_started)
	_gesture.drag_updated.connect(_on_drag_updated)
	_gesture.drag_released.connect(_on_drag_released)


# --- slot layout: band(가로 띠) 또는 radial(방사형) ---

func _build_slots() -> void:
	var centers: Array = _slot_centers()
	for i in range(_slot_count):
		var c: Vector2 = centers[i]
		var slot := Panel.new()
		slot.position = c - Vector2(SLOT_SIZE, SLOT_SIZE) * 0.5
		slot.size = Vector2(SLOT_SIZE, SLOT_SIZE)
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.86, 0.78, 0.66, 0.55)
		sb.set_corner_radius_all(24 if _shape == "band" else 80)
		sb.set_border_width_all(4)
		sb.border_color = COLORS[i % COLORS.size()].darkened(0.1)
		slot.add_theme_stylebox_override("panel", sb)
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(slot)
		# 색 힌트 dot (이 슬롯에 어떤 색이 와야 하는지).
		var dot := ColorRect.new()
		dot.color = Color(COLORS[i % COLORS.size()], 0.35)
		dot.size = Vector2(SLOT_SIZE * 0.5, SLOT_SIZE * 0.5)
		dot.position = (Vector2(SLOT_SIZE, SLOT_SIZE) - dot.size) * 0.5
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(dot)
		# magnet glow (평소 숨김, drag로 근접 시 표시).
		var glow := Panel.new()
		glow.position = Vector2(-14, -14)
		glow.size = Vector2(SLOT_SIZE + 28, SLOT_SIZE + 28)
		var gsb := StyleBoxFlat.new()
		gsb.bg_color = Color(1.0, 0.92, 0.4, 0.0)
		gsb.set_corner_radius_all(30 if _shape == "band" else 90)
		gsb.set_border_width_all(6)
		gsb.border_color = Color(1.0, 0.85, 0.30, 0.0)
		glow.add_theme_stylebox_override("panel", gsb)
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(glow)
		_slots.append({"node": slot, "center": c, "color_id": i, "filled": false, "glow": glow, "dot": dot})


func _slot_centers() -> Array:
	var centers: Array = []
	if _shape == "radial":
		# 6색 방사형 — 비빔밥 그릇 둘레.
		var cx: float = 540.0
		var cy: float = 860.0
		var r: float = 250.0
		for i in range(_slot_count):
			var a: float = -PI * 0.5 + float(i) / float(_slot_count) * TAU
			centers.append(Vector2(cx + cos(a) * r, cy + sin(a) * r))
	else:
		# 5색 가로 띠 — 김밥/고명.
		var gap: float = 30.0
		var total: float = float(_slot_count) * SLOT_SIZE + float(_slot_count - 1) * gap
		var x0: float = (1080.0 - total) * 0.5 + SLOT_SIZE * 0.5
		var y: float = 760.0
		for i in range(_slot_count):
			centers.append(Vector2(x0 + float(i) * (SLOT_SIZE + gap), y))
	return centers


func _build_ingredients(food_id: StringName) -> void:
	# 재료를 하단 트레이에 색 섞어 배치 (색-슬롯 매칭을 플레이어가 판단).
	var order: Array = range(_slot_count)
	order.shuffle()
	var cut_path: String = ArtRegistry.prep_cut(food_id)
	var has_cut: bool = ArtRegistry.file_exists(cut_path)
	var gap: float = 24.0
	var total: float = float(_slot_count) * ING_SIZE + float(_slot_count - 1) * gap
	var x0: float = (1080.0 - total) * 0.5 + ING_SIZE * 0.5
	var y: float = 1440.0
	for i in range(_slot_count):
		var color_id: int = int(order[i])
		var home := Vector2(x0 + float(i) * (ING_SIZE + gap), y)
		var token := Control.new()
		token.size = Vector2(ING_SIZE, ING_SIZE)
		token.position = home - token.size * 0.5
		token.mouse_filter = Control.MOUSE_FILTER_IGNORE
		token.z_index = 10
		# 색 배경 (색-매칭 단서).
		var bg := Panel.new()
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		var bsb := StyleBoxFlat.new()
		bsb.bg_color = COLORS[color_id % COLORS.size()]
		bsb.set_corner_radius_all(24)
		bsb.shadow_size = 5
		bsb.shadow_color = Color(0, 0, 0, 0.28)
		bg.add_theme_stylebox_override("panel", bsb)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		token.add_child(bg)
		# cut sprite icon (있으면) — hero ingredient(color 0)에 우선, 나머진 색만.
		if has_cut and color_id == 0:
			var icon := TextureRect.new()
			icon.texture = load(cut_path)
			icon.position = Vector2(14, 14)
			icon.size = Vector2(ING_SIZE - 28, ING_SIZE - 28)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			token.add_child(icon)
		add_child(token)
		_ingredients.append({
			"node": token, "color_id": color_id, "home": home,
			"size": token.size, "placed": false,
		})


# --- gesture handlers: press-drag-release ---

func _on_drag_started(pos: Vector2) -> void:
	if _finished:
		return
	# 누른 위치에서 가장 가까운 미배치 재료를 집음.
	var best: int = -1
	var best_d: float = ING_SIZE * 0.9
	for i in range(_ingredients.size()):
		if bool(_ingredients[i]["placed"]):
			continue
		var node: Control = _ingredients[i]["node"]
		if not is_instance_valid(node):
			continue
		var center: Vector2 = node.position + node.size * 0.5
		var d: float = pos.distance_to(center)
		if d < best_d:
			best_d = d
			best = i
	_dragging_idx = best
	if _dragging_idx >= 0:
		var node: Control = _ingredients[_dragging_idx]["node"]
		node.z_index = 30
		_drag_offset = node.position + node.size * 0.5 - pos
		# 집어올림 — 살짝 확대.
		node.scale = Vector2(1.12, 1.12)


func _on_drag_updated(pos: Vector2, _vel: Vector2) -> void:
	if _finished or _dragging_idx < 0:
		return
	var node: Control = _ingredients[_dragging_idx]["node"]
	if not is_instance_valid(node):
		return
	var center: Vector2 = pos + _drag_offset
	node.position = center - node.size * 0.5
	# 가장 가까운 미충족 슬롯 magnet glow.
	_update_magnet_glow(center)


func _on_drag_released(_info: Dictionary) -> void:
	if _finished or _dragging_idx < 0:
		return
	var idx: int = _dragging_idx
	_dragging_idx = -1
	_clear_magnet_glow()
	var node: Control = _ingredients[idx]["node"]
	if not is_instance_valid(node):
		return
	node.scale = Vector2(1, 1)
	var center: Vector2 = node.position + node.size * 0.5
	# magnet 반경 안의 가장 가까운 빈 슬롯에 안착 시도.
	var slot_idx: int = _nearest_open_slot(center, MAGNET_RADIUS)
	if slot_idx < 0:
		# 슬롯 근처 아님 — 홈으로 복귀 (배치 미성립, retry).
		_return_home(idx)
		return
	_settle_into_slot(idx, slot_idx)


# --- magnet glow + snap settle ---

func _update_magnet_glow(center: Vector2) -> void:
	var slot_idx: int = _nearest_open_slot(center, MAGNET_RADIUS)
	if slot_idx == _glow_slot_idx:
		return
	_clear_magnet_glow()
	_glow_slot_idx = slot_idx
	if slot_idx >= 0:
		var glow: Panel = _slots[slot_idx]["glow"]
		if is_instance_valid(glow):
			var gsb := glow.get_theme_stylebox("panel") as StyleBoxFlat
			if gsb:
				gsb.bg_color = Color(1.0, 0.92, 0.4, 0.22)
				gsb.border_color = Color(1.0, 0.85, 0.30, 0.9)
			var tw := glow.create_tween()
			tw.tween_property(glow, "scale", Vector2(1.06, 1.06), 0.12)


func _clear_magnet_glow() -> void:
	if _glow_slot_idx >= 0 and _glow_slot_idx < _slots.size():
		var glow: Panel = _slots[_glow_slot_idx]["glow"]
		if is_instance_valid(glow):
			var gsb := glow.get_theme_stylebox("panel") as StyleBoxFlat
			if gsb:
				gsb.bg_color = Color(1.0, 0.92, 0.4, 0.0)
				gsb.border_color = Color(1.0, 0.85, 0.30, 0.0)
			glow.scale = Vector2(1, 1)
	_glow_slot_idx = -1


func _nearest_open_slot(center: Vector2, max_d: float) -> int:
	var best: int = -1
	var best_d: float = max_d
	for i in range(_slots.size()):
		if bool(_slots[i]["filled"]):
			continue
		var d: float = center.distance_to(_slots[i]["center"])
		if d < best_d:
			best_d = d
			best = i
	return best


func _settle_into_slot(ing_idx: int, slot_idx: int) -> void:
	var node: Control = _ingredients[ing_idx]["node"]
	var slot_center: Vector2 = _slots[slot_idx]["center"]
	var color_id: int = int(_ingredients[ing_idx]["color_id"])
	var slot_color_id: int = int(_slots[slot_idx]["color_id"])
	var ok: bool = color_id == slot_color_id
	_ingredients[ing_idx]["placed"] = true
	_slots[slot_idx]["filled"] = true
	_placed_total += 1
	if ok:
		_correct_count += 1
	# snap settle — 슬롯 중앙으로 안착 + 바운스.
	node.z_index = 9
	var target: Vector2 = slot_center - node.size * 0.5
	var tw := node.create_tween()
	tw.tween_property(node, "position", target, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(node, "scale", Vector2(0.86, 0.86), 0.16)
	# 슬롯 시각 — 정확하면 색 채움 + 보더 녹색, 틀리면 비뚤(살짝 회전)+빨강.
	var slot: Panel = _slots[slot_idx]["node"]
	var ssb := slot.get_theme_stylebox("panel") as StyleBoxFlat
	if ssb:
		if ok:
			ssb.bg_color = COLORS[color_id % COLORS.size()].lightened(0.1)
			ssb.border_color = Color(0.30, 0.70, 0.32)
		else:
			ssb.bg_color = COLORS[color_id % COLORS.size()].darkened(0.15)
			ssb.border_color = Color(0.82, 0.30, 0.24)
	if not ok:
		# 비뚤어진 느낌 — 살짝 기울임.
		node.rotation = deg_to_rad(randf_range(-10.0, 10.0))
	# dot 숨김 (채워짐).
	var dot: ColorRect = _slots[slot_idx]["dot"]
	if is_instance_valid(dot):
		dot.visible = false
	_safe_feedback(RhythmJudge.GOOD if ok else RhythmJudge.MISS, slot_center)
	_update_hint()
	# 모든 재료 배치 완료?
	if _placed_total >= _slot_count:
		_finalize()


func _return_home(ing_idx: int) -> void:
	var node: Control = _ingredients[ing_idx]["node"]
	var home: Vector2 = _ingredients[ing_idx]["home"]
	node.z_index = 10
	var tw := node.create_tween()
	tw.tween_property(node, "position", home - node.size * 0.5, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if is_instance_valid(_hint):
		_hint.text = "Drop it onto a slot"


func _update_hint() -> void:
	if not is_instance_valid(_hint):
		return
	var left: int = _slot_count - _placed_total
	if left > 0:
		_hint.text = "%d placed · %d to go" % [_placed_total, left]


func _finalize() -> void:
	if is_instance_valid(_hint):
		if _correct_count == _slot_count:
			_hint.text = "All colors placed!"
		else:
			_hint.text = "Arranged"
	# §6.1 — placement 정확도 = correct / total × 100. 기존 tap-match 점수와 1:1 동일.
	var score: float = float(_correct_count) / float(maxi(1, _slot_count)) * 100.0
	_finish(score)
