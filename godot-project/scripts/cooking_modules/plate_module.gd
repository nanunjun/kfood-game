## PlateModule — vessel + garnish selection (ADR-011).
##
## Player picks one of 3 vessels (best / 2nd / bad — shuffled). Tier maps directly to
## score: best=100, 2nd=70, bad=20. This preserves the old "dish choice" tier-bonus
## logic from rhythm_proto.gd while folding it into the module pipeline.
##
## 5-Layer Composition (2026-06-06): plate vessel(L2) + finished dish hero(L3) +
## serving sparkle/steam(L5). wide_plate/wooden_tray/brass_bowl/earthenware_bowl/
## noodle_bowl/dolsot 중 음식별 vessel sprite를 받침으로 합성.
extends "res://scripts/cooking_modules/base_module.gd"

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const TouchGesture := preload("res://scripts/cooking_modules/touch_gesture.gd")
# CookingFX / ArtRegistry 는 base_module(CookingModule)에서 상속.

var _options: Array = []   # [{dish_id, tier, info}]
var _menu: Dictionary = {}
var _chosen_dish: String = ""
var _chosen_tier: String = ""

# === Gimbap Vertical Slice — drag-arrange plating (design §5.3 / §8.5, Success #6) ===
# vs_quality_state가 들어오면 기존 3지선다 vessel tap 대신 김밥 조각을 wooden_tray에 drag로
# target row에 배치하는 plating으로 격상한다. spacing/orientation 중요 → plate_quality.
# slice_quality가 조각 단면 wobble visual에 영향(§8.5). 일반 dish는 이 경로를 안 탄다(무변경).
var _vs_plate: bool = false
var _vs_slice_quality: float = 1.0
var _vs_gesture = null
var _vs_pieces: Array = []          # [{node, target(Vector2), placed(bool), idx}]
var _vs_targets: Array = []         # tray row target 좌표
var _vs_drag_idx: int = -1
var _vs_drag_off: Vector2 = Vector2.ZERO
var _vs_placed_count: int = 0
var _vs_hint: Label = null
var _vs_quality: float = 0.0


func _module_start(params: Dictionary) -> void:
	# §5.3 gimbap VS plating — vs_quality_state가 있으면 drag-arrange plating으로 분기.
	if params.has("vs_quality_state") and not (params.get("vs_quality_state", {}) as Dictionary).is_empty():
		_menu = params.get("menu", {})
		var qs: Dictionary = params.get("vs_quality_state", {})
		_vs_slice_quality = clampf(float(qs.get("slice_quality", 1.0)), 0.0, 1.0)
		_start_vs_plating(params)
		return
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

	# dish preview = action zone 중앙 (≤60%W). vessel choice = bottom equal cards.
	var food_id: StringName = StringName(String(_menu.get("id", "")))
	# Cooking Realism Fix (2026-06-07, HR2): "그릇 위 그릇" 금지.
	# premium_v2 완성 dish(food_img)는 이미 그릇이 baked(dish_with_vessel)되어 있다.
	# 따라서 vessel(L2)을 그 아래에 또 깔면 그릇이 2개가 된다.
	#   - content_only(그릇 없는 음식)가 있으면  → vessel(L2) + content(L3) 합성 (진짜 받침).
	#   - content_only가 없으면 (현재 6 dish 전부) → vessel 생략, dish_with_vessel 단독 hero (Option B).
	var content_path: String = ArtRegistry.food_content_only(food_id)
	var has_content_only: bool = content_path != ""

	if has_content_only:
		# CASE A — vessel(L2) 받침 + content(L3) 합성. 진짜 "그릇에 담긴 음식".
		var vessel_path: String = ArtRegistry.plate_vessel_for(food_id)
		if vessel_path != "":
			var vessel_rect: Rect2 = Composition.rect_in_zone(
				Composition.ZONE_ACTION, Composition.CLAMP_VESSEL, Vector2(0.5, 0.46))
			var vessel_tex := TextureRect.new()
			vessel_tex.texture = load(vessel_path)
			Composition.fit_texture_rect(vessel_tex, vessel_rect)
			vessel_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
			vessel_tex.z_index = L2_BASE
			add_child(vessel_tex)
			_attach_dish_shadow(Vector2(540, vessel_rect.position.y + vessel_rect.size.y * 0.9), 500.0)
		# L3 — content-only 음식 mound (그릇 안에 자연스럽게 담김, vessel보다 약간 작게).
		var content_rect: Rect2 = Composition.rect_in_zone(
			Composition.ZONE_ACTION, Vector2(0.52, 0.36), Vector2(0.5, 0.42))
		var content_tex := TextureRect.new()
		content_tex.texture = load(content_path)
		Composition.fit_texture_rect(content_tex, content_rect)
		content_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content_tex.z_index = L3_INGREDIENT
		add_child(content_tex)
		_attach_steam(Vector2(540, content_rect.position.y + 30.0), 3)
	elif bool(_menu.get("ready", false)):
		# CASE B (Option B fallback) — content_only 미존재. dish_with_vessel(food_img)이 이미
		# 그릇을 포함하므로 vessel을 따로 깔지 않고 dish hero 단독으로 보여 준다 (그릇 1개).
		var tex: Texture2D = load(String(_menu.get("food_img", "")))
		if tex != null:
			var dish_rect: Rect2 = Composition.rect_in_zone(
				Composition.ZONE_ACTION, Composition.CLAMP_DISH_HERO, Vector2(0.5, 0.44))
			_attach_dish_shadow(Vector2(540, dish_rect.position.y + dish_rect.size.y * 0.9), 500.0)
			var thumb := TextureRect.new()
			thumb.texture = tex
			Composition.fit_texture_rect(thumb, dish_rect)
			thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
			thumb.z_index = L3_INGREDIENT
			add_child(thumb)
			# L5 — serving steam over the dish.
			_attach_steam(Vector2(540, dish_rect.position.y + 30.0), 3)

	# Vessel choice cards — bottom equal cards (CONTROL+FEEDBACK zone). 짧게 해서 화면 안.
	var btn_w := 300.0
	var gap := 36.0
	var total := 3.0 * btn_w + 2.0 * gap
	var x0: float = (1080.0 - total) * 0.5
	var card_y: float = 1420.0
	var card_h: float = 360.0
	# "Pick a vessel" 안내.
	var pick_lbl := Label.new()
	pick_lbl.position = Vector2(0, 1356)
	pick_lbl.size = Vector2(1080, 56)
	pick_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pick_lbl.add_theme_font_size_override("font_size", 36)
	pick_lbl.add_theme_color_override("font_color", Color(0.45, 0.32, 0.18))
	pick_lbl.text = "Pick a serving vessel"
	add_child(pick_lbl)
	for i in range(_options.size()):
		var opt: Dictionary = _options[i]
		var dish_id: String = String(opt["dish_id"])
		var info: Dictionary = MenuDB.vessel(dish_id)
		var card_x: float = x0 + float(i) * (btn_w + gap)
		# Button = 카드 전체 클릭 타깃 (텍스트는 비워 두고 별도 Label을 하단에 둔다 —
		# vessel sprite(상단)와 이름표(하단)를 깔끔히 분리).
		var b := Button.new()
		b.text = ""
		b.position = Vector2(card_x, card_y)
		b.size = Vector2(btn_w, card_h)
		var psb := StyleBoxFlat.new()
		psb.bg_color = Color(info.get("color", Color(0.85, 0.85, 0.85)))
		psb.set_corner_radius_all(28)
		psb.set_border_width_all(4)
		psb.border_color = psb.bg_color.darkened(0.25)
		psb.shadow_size = 6
		psb.shadow_color = Color(0, 0, 0, 0.20)
		b.add_theme_stylebox_override("normal", psb)
		var psbh := psb.duplicate()
		psbh.bg_color = psb.bg_color.lightened(0.10)
		b.add_theme_stylebox_override("hover", psbh)
		b.add_theme_stylebox_override("pressed", psbh)
		b.pressed.connect(_on_pick.bind(dish_id, String(opt["tier"])))
		add_child(b)
		# Cooking Realism Fix (2026-06-07): vessel choice는 선택 card에서만 그릇을 보여 준다
		# (action zone의 dish hero는 vessel을 깔지 않음 — HR2). 각 card에 실제 vessel sprite.
		var vsprite: String = ArtRegistry.vessel_sprite_for_catalog(dish_id)
		if vsprite != "":
			var vrect := TextureRect.new()
			vrect.texture = load(vsprite)
			vrect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			vrect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			vrect.position = Vector2(card_x + btn_w * 0.13, card_y + 18.0)
			vrect.size = Vector2(btn_w * 0.74, card_h * 0.56)
			vrect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			vrect.z_index = L3_INGREDIENT
			add_child(vrect)
		# 이름표 — 카드 하단(클릭은 Button이 받으므로 IGNORE).
		var name_lbl := Label.new()
		name_lbl.text = "%s\n(%s)" % [info.get("name_en", dish_id), info.get("name_kr", "")]
		name_lbl.position = Vector2(card_x + 8.0, card_y + card_h * 0.62)
		name_lbl.size = Vector2(btn_w - 16.0, card_h * 0.34)
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_lbl.add_theme_font_size_override("font_size", 26)
		name_lbl.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
		name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name_lbl.z_index = L4_TOOL
		add_child(name_lbl)


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
	# L5 — serving sparkle over the plated dish (best일수록 화려, 항상 표시).
	CookingFX.serving_sparkle(self, Vector2(540, 1040), 12 if tier == "best" else 8)
	_finish(score)


## Runner reads these after `module_completed` to feed dish_bonus into the result payload.
func get_chosen_dish() -> String:
	return _chosen_dish


func get_chosen_tier() -> String:
	return _chosen_tier


# =====================================================================================
# Gimbap Vertical Slice — STRICT TOP-DOWN tray plating (design §5.3 / §8.5, Success #6).
#
# 사용자 거부 교정 (2026-06-12 top-down rebuild): 기존 plating이 불명확(wooden_tray sprite +
# 가로 1줄 ghost). 교정 = "잘린 김밥을 도시락 접시에 예쁘게 담는다"가 즉시 읽히게:
#   - tray = strict top-down **직사각 도시락**(procedural, 사선 0).
#   - tray 안 **6개 명확한 circular placement slot** + 각 slot에 **faint gimbap silhouette**
#     (어디에 무엇을 놓을지 명확).
#   - bottom basket = **cut-side-up 김밥 조각만**(단면 위로 — _GimbapCutPiece procedural).
#   - 조각을 하나씩 slot에 drag → 올바른 slot 근처 **snap** / 잘못 놓으면 **살짝 튕김(bounce)**.
# 점수: center accuracy(snap 오차) + spacing(slot 등간격) + angle + cut-side-up 여부 → plate_quality.
# "plating이 static이 아니다 — 조각 배치/정렬이 완성 비주얼을 바꾼다." (scoring 무변경 — §9.2)
# =====================================================================================

const VS_PIECE_COUNT: int = 6        # 김밥 조각 수 = slot 수 (2x3 grid).
const VS_SNAP_RADIUS: float = 110.0  # 빈 slot에 이 거리 안이면 snap.
const VS_PIECE_D: float = 132.0      # cut-side-up 조각 지름.
# top-down 도시락 tray box (화면 1080x1920 중앙 action zone, 사선 0).
const VS_TRAY_RECT := Rect2(150, 720, 780, 560)
# slot grid = 2 row x 3 col.
const VS_SLOT_COLS: int = 3
const VS_SLOT_ROWS: int = 2

func _start_vs_plating(params: Dictionary) -> void:
	_vs_plate = true
	_attach_cooking_bg(1030.0)
	_build_header("Plating", "Arrange the pieces on the tray, cut-side up")
	_build_instruction_band("Arrange the pieces evenly on the tray, cut-side up.", "↓")

	# top-down 도시락 tray (procedural 직사각 — 사선 0). 정하향 shadow.
	_attach_dish_shadow(Vector2(540, VS_TRAY_RECT.position.y + VS_TRAY_RECT.size.y + 6.0), 720.0)
	_build_vs_tray()

	# 6 circular placement slot (2x3 grid) + 각 slot faint gimbap silhouette.
	_build_vs_slots()

	# bottom basket — cut-side-up 김밥 조각만 (단면 위로). drag로 slot에 배치.
	_build_vs_pieces()

	_vs_hint = Label.new()
	_vs_hint.position = Vector2(0, 1660)
	_vs_hint.size = Vector2(1080, 60)
	_vs_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_vs_hint.add_theme_font_size_override("font_size", 38)
	_vs_hint.add_theme_color_override("font_color", Color(0.45, 0.32, 0.18))
	_vs_hint.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.85))
	_vs_hint.add_theme_constant_override("outline_size", 6)
	_vs_hint.text = "Drag each piece onto a silhouette slot"
	add_child(_vs_hint)

	_vs_gesture = TouchGesture.new()
	_vs_gesture.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_vs_gesture)
	_vs_gesture.drag_started.connect(_on_vs_drag_started)
	_vs_gesture.drag_updated.connect(_on_vs_drag_updated)
	_vs_gesture.drag_released.connect(_on_vs_drag_released)


## strict top-down 직사각 도시락 tray. PAINTERLY SWAP (2026-06-13): procedural box(box corner) 폐기
## → wooden_tray_topdown (real 나무 tray, high-angle painterly). 6 slot silhouette는 위에 유지(painterly).
## 미존재 시 기존 procedural Panel box로 fallback. drag/snap/plate_quality 무변경.
func _build_vs_tray() -> void:
	var tray_path: String = ArtRegistry.get_painterly("wooden_tray_topdown")
	if tray_path != "":
		var timg := TextureRect.new()
		timg.name = "VsTrayPainterly"
		timg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		timg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		timg.texture = load(tray_path)
		timg.position = VS_TRAY_RECT.position - Vector2(40, 40)
		timg.size = VS_TRAY_RECT.size + Vector2(80, 80)
		timg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		timg.z_index = L2_BASE
		add_child(timg)
		return
	var tray := Panel.new()
	tray.name = "VsTray"
	tray.position = VS_TRAY_RECT.position
	tray.size = VS_TRAY_RECT.size
	var tsb := StyleBoxFlat.new()
	tsb.bg_color = Color(0.80, 0.62, 0.36)           # 밝은 나무 도시락.
	tsb.set_corner_radius_all(40)
	tsb.set_border_width_all(14)
	tsb.border_color = Color(0.58, 0.40, 0.20)        # 진한 테두리(도시락 벽).
	tsb.shadow_size = 10
	tsb.shadow_color = Color(0, 0, 0, 0.22)
	tray.add_theme_stylebox_override("panel", tsb)
	tray.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tray.z_index = L2_BASE
	add_child(tray)
	# 안쪽 바닥(살짝 진한 inset — 담는 공간 깊이감, top-down 평면 유지).
	var inner := Panel.new()
	inner.position = Vector2(22, 22)
	inner.size = VS_TRAY_RECT.size - Vector2(44, 44)
	var isb := StyleBoxFlat.new()
	isb.bg_color = Color(0.73, 0.55, 0.31)
	isb.set_corner_radius_all(28)
	inner.add_theme_stylebox_override("panel", isb)
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# 자식 z는 부모 기준 상대 — 0으로 두어 tray와 같은 plane(슬롯/조각 위에 안 올라오게).
	inner.z_index = 0
	tray.add_child(inner)


## 6 circular placement slot (2x3 grid). 각 slot = faint ring + faint gimbap silhouette
## (어디에 무엇을 놓을지 명확). slot 등간격 → spacing 점수와 시각 일치.
func _build_vs_slots() -> void:
	var ix0: float = VS_TRAY_RECT.position.x + 70.0
	var ix1: float = VS_TRAY_RECT.position.x + VS_TRAY_RECT.size.x - 70.0
	var iy0: float = VS_TRAY_RECT.position.y + 80.0
	var iy1: float = VS_TRAY_RECT.position.y + VS_TRAY_RECT.size.y - 80.0
	for r in range(VS_SLOT_ROWS):
		for c in range(VS_SLOT_COLS):
			var tx: float = lerpf(ix0, ix1, float(c) / float(VS_SLOT_COLS - 1))
			var ty: float = lerpf(iy0, iy1, float(r) / float(VS_SLOT_ROWS - 1))
			var tpos := Vector2(tx, ty)
			_vs_targets.append(tpos)
			# faint gimbap silhouette — 단면 윤곽(김 ring + 흰 밥 + 속 점)을 흐리게.
			# z = L4_TOOL(30) — tray subtree(L2_BASE~+) 위에 또렷이(자식 상대 z에 묻히지 않게).
			var sil := _VsSlotSilhouette.new()
			sil.setup(VS_PIECE_D)
			sil.position = tpos - Vector2(VS_PIECE_D, VS_PIECE_D) * 0.5
			sil.mouse_filter = Control.MOUSE_FILTER_IGNORE
			sil.z_index = L4_TOOL
			add_child(sil)


## bottom basket — cut-side-up 김밥 조각만 (단면 위로 = _GimbapCutPiece). 2 row pile에서 시작.
func _build_vs_pieces() -> void:
	# 하단 basket 라벨 (어디서 조각을 집는지).
	var basket := Panel.new()
	basket.name = "VsBasket"
	basket.position = Vector2(120, 1420)
	basket.size = Vector2(840, 200)
	var bsb := StyleBoxFlat.new()
	bsb.bg_color = Color(0.27, 0.18, 0.10, 0.40)
	bsb.set_corner_radius_all(24)
	bsb.set_border_width_all(3)
	bsb.border_color = Color(0.95, 0.72, 0.30, 0.50)
	basket.add_theme_stylebox_override("panel", bsb)
	basket.mouse_filter = Control.MOUSE_FILTER_IGNORE
	basket.z_index = L2_BASE
	add_child(basket)
	var cap := Label.new()
	cap.text = "조각 · Cut pieces"
	cap.position = Vector2(18, 6)
	cap.size = Vector2(360, 30)
	cap.add_theme_font_size_override("font_size", 24)
	cap.add_theme_color_override("font_color", Color(1.0, 0.95, 0.82, 0.88))
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	basket.add_child(cap)

	# §8.5 slice→plating: slice_quality 낮으면 조각이 처음부터 wobble(단면 제각각/기울).
	var wobble: float = clampf(1.0 - _vs_slice_quality, 0.0, 1.0)
	# PAINTERLY SWAP (2026-06-13): 조각 = gimbap_piece_good. broken(slice 나쁨 → wobble 큼) →
	# gimbap_piece_collapse (filling 쏟아짐 시각). §8.3 "잘 못 썰면 담을 때도 무너진다" 인과를 시각으로.
	var broken_count: int = 0
	if wobble >= 0.40:
		broken_count = clampi(int(round(wobble * float(VS_PIECE_COUNT) * 0.6)), 1, VS_PIECE_COUNT)
	# 6 조각을 basket 안 2x3로 정렬해 둔다(집기 쉽게).
	for i in range(VS_PIECE_COUNT):
		var col: int = i % 3
		var row: int = i / 3
		var home := Vector2(260.0 + float(col) * 280.0, 1490.0 + float(row) * 84.0)
		# painterly 조각(good/collapse) 우선 → 미존재 시 procedural _GimbapCutPiece fallback.
		var is_broken: bool = i < broken_count
		var piece: Control = _make_painterly_plate_piece(is_broken)
		if piece == null:
			var pp := _GimbapCutPiece.new()        # cut-side-up 단면 (단면 위로 보장).
			pp.setup(VS_PIECE_D)
			pp.size = Vector2(VS_PIECE_D, VS_PIECE_D)
			piece = pp
		piece.position = home - piece.size * 0.5
		piece.pivot_offset = piece.size * 0.5
		piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# z = L5_VFX(40) — silhouette/tray 위에 또렷이(조각이 가장 위 plane).
		piece.z_index = L5_VFX
		# slice 나쁨 → 조각이 처음부터 wobble(기울고 크기 제각각 = 단면 정렬 어려움).
		if wobble > 0.05:
			piece.rotation = deg_to_rad(randf_range(-22.0, 22.0) * wobble)
			var sj: float = 1.0 + randf_range(-0.18, 0.18) * wobble
			piece.scale = Vector2(sj, sj)
		add_child(piece)
		_vs_pieces.append({"node": piece, "home": home, "placed": false, "idx": i, "wobble": wobble})


func _on_vs_drag_started(pos: Vector2) -> void:
	if _finished:
		return
	var best: int = -1
	var best_d: float = 100.0
	for i in range(_vs_pieces.size()):
		if bool(_vs_pieces[i]["placed"]):
			continue
		var node: Control = _vs_pieces[i]["node"]
		if not is_instance_valid(node):
			continue
		var center: Vector2 = node.position + node.size * 0.5
		var d: float = pos.distance_to(center)
		if d < best_d:
			best_d = d
			best = i
	_vs_drag_idx = best
	if _vs_drag_idx >= 0:
		var node: Control = _vs_pieces[_vs_drag_idx]["node"]
		node.z_index = 40
		_vs_drag_off = node.position + node.size * 0.5 - pos


func _on_vs_drag_updated(pos: Vector2, _vel: Vector2) -> void:
	if _finished or _vs_drag_idx < 0:
		return
	var node: Control = _vs_pieces[_vs_drag_idx]["node"]
	if not is_instance_valid(node):
		return
	node.position = (pos + _vs_drag_off) - node.size * 0.5


func _on_vs_drag_released(_info: Dictionary) -> void:
	if _finished or _vs_drag_idx < 0:
		return
	var idx: int = _vs_drag_idx
	_vs_drag_idx = -1
	var node: Control = _vs_pieces[idx]["node"]
	if not is_instance_valid(node):
		return
	var center: Vector2 = node.position + node.size * 0.5
	# 가장 가까운 빈 target 찾기.
	var best_t: int = -1
	var best_d: float = VS_SNAP_RADIUS
	for ti in range(_vs_targets.size()):
		if _target_taken(ti):
			continue
		var d: float = center.distance_to(_vs_targets[ti])
		if d < best_d:
			best_d = d
			best_t = ti
	if best_t < 0:
		# 빈 slot 근처 아님(잘못 놓음) — **살짝 튕김(bounce)** 후 basket home 복귀.
		# 사용자가 "여긴 아니야"를 즉시 느끼게 — 작게 뒤로 튕겼다가 home으로.
		node.z_index = L5_VFX     # 조각은 항상 tray/silhouette 위 plane 유지.
		var bounce_dir: Vector2 = (center - _nearest_slot_pos(center)).normalized()
		if bounce_dir == Vector2.ZERO:
			bounce_dir = Vector2(0, 1)
		var bounce_pos: Vector2 = node.position + bounce_dir * 46.0
		var home_pos: Vector2 = _vs_pieces[idx]["home"] - node.size * 0.5
		var tw := node.create_tween()
		tw.tween_property(node, "position", bounce_pos, 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(node, "position", home_pos, 0.20).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		_safe_feedback(RhythmJudge.MISS, center)
		if is_instance_valid(_vs_hint):
			_vs_hint.text = "Place it on a slot"
		return
	# snap settle — slot에 안착. placement 오차(snap 전 거리)를 plate_quality에 반영.
	_vs_pieces[idx]["placed"] = true
	_vs_pieces[idx]["target_idx"] = best_t
	_vs_pieces[idx]["err"] = best_d
	_vs_placed_count += 1
	node.z_index = L4_TOOL + 1    # 안착 조각 — silhouette(L4_TOOL) 위, tray 위.
	var target_pos: Vector2 = _vs_targets[best_t]
	var tw2 := node.create_tween()
	tw2.tween_property(node, "position", target_pos - node.size * 0.5, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# orientation 정렬 — slice 좋으면 단면 위로 똑바로(cut-side up), 나쁘면 wobble 잔존.
	if float(_vs_pieces[idx]["wobble"]) <= 0.15:
		tw2.parallel().tween_property(node, "rotation", 0.0, 0.16)
		tw2.parallel().tween_property(node, "scale", Vector2.ONE, 0.16)
	_safe_feedback(RhythmJudge.GOOD, target_pos)
	if is_instance_valid(_vs_hint):
		_vs_hint.text = "%d / %d placed" % [_vs_placed_count, VS_PIECE_COUNT]
	if _vs_placed_count >= VS_PIECE_COUNT:
		_finalize_vs_plating()


## center에서 가장 가까운 slot 좌표(bounce 방향 산정용 — 점유 무관).
func _nearest_slot_pos(center: Vector2) -> Vector2:
	var best: Vector2 = center
	var best_d: float = 1e9
	for t in _vs_targets:
		var d: float = center.distance_to(t)
		if d < best_d:
			best_d = d
			best = t
	return best


func _target_taken(ti: int) -> bool:
	for p in _vs_pieces:
		if bool(p.get("placed", false)) and int(p.get("target_idx", -1)) == ti:
			return true
	return false


func _finalize_vs_plating() -> void:
	# plate_quality = placement 정확도(spacing/중앙 안착) × orientation(slice 기반 wobble 패널티).
	var err_sum: float = 0.0
	for p in _vs_pieces:
		err_sum += float(p.get("err", VS_SNAP_RADIUS))
	var avg_err: float = err_sum / float(maxi(1, _vs_pieces.size()))
	# 평균 snap 오차 0 → 1.0, VS_SNAP_RADIUS → 0.4. 정렬이 고를수록 높음.
	var placement: float = clampf(1.0 - avg_err / VS_SNAP_RADIUS * 0.6, 0.0, 1.0)
	# orientation — slice_quality가 단면 정렬을 좌우(wobble 조각은 안 펴짐).
	var orientation: float = lerpf(0.55, 1.0, _vs_slice_quality)
	_vs_quality = clampf(placement * 0.6 + orientation * 0.4, 0.0, 1.0)
	# 최종 plating visual — serving sparkle(잘 담았을수록 화려).
	CookingFX.serving_sparkle(self, Vector2(540, 940), 14 if _vs_quality >= 0.75 else 8)
	if is_instance_valid(_vs_hint):
		if _vs_quality >= 0.75:
			_vs_hint.text = "Looks like a real lunchbox!"
		elif _vs_quality >= 0.45:
			_vs_hint.text = "Plated"
		else:
			_vs_hint.text = "A little messy"
	# wooden_tray = 김밥 best vessel — dish bonus는 tier로 best 고정(plating은 display layer).
	_chosen_dish = String(_menu.get("dish_best", ""))
	_chosen_tier = "best"
	print("[plate-vs] placement=%.2f orient=%.2f slice_q=%.2f plate_quality=%.2f" % [
		placement, orientation, _vs_slice_quality, _vs_quality])
	# §9.2: plate_quality는 display bonus(★ 무영향). module score는 plate_quality×100을 emit하나
	#   runner의 plate factor(plating)는 dish_bonus와 분리돼 ★ 임계에 영향 없음(기존 contract).
	await get_tree().create_timer(0.4).timeout
	_finish(_vs_quality * 100.0)


## gimbap VS plate_quality [0,1] — runner가 quality-state로 읽음(guest reaction §8.6).
func get_vs_plate_quality() -> float:
	return _vs_quality


## PAINTERLY 조각 1개 — broken=true면 gimbap_piece_collapse(filling 쏟아짐), false면 gimbap_piece_good.
## 미존재 시 null → caller가 procedural _GimbapCutPiece fallback. cut-side-up 단면 painterly.
func _make_painterly_plate_piece(broken: bool) -> Control:
	var key: String = "gimbap_piece_collapse" if broken else "gimbap_piece_good"
	var path: String = ArtRegistry.get_painterly(key)
	if path == "":
		return null
	var tr := TextureRect.new()
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.texture = load(path)
	tr.size = Vector2(VS_PIECE_D, VS_PIECE_D)
	return tr


# =====================================================================================
# STRICT TOP-DOWN procedural draw nodes — cut-side-up 조각 + slot silhouette (사선 0).
# gimbap_slice_module._GimbapCutPiece와 동일 철학(둥근 정면 단면). 여기 자체 정의로 중복 의존 0.
# =====================================================================================

## cut-side-up 김밥 조각 — 둥근 정면 단면(spiral cross-section). 김 ring + 흰 밥 + 색색 속.
## 항상 단면이 위로(cut-side up) 보이는 procedural draw → 비스듬/뒤집힘 0. 균일 크기.
class _GimbapCutPiece extends Control:
	var _d: float = 132.0

	func setup(diam: float) -> void:
		_d = diam
		size = Vector2(diam, diam)
		queue_redraw()

	func _draw() -> void:
		var c: Vector2 = Vector2(_d, _d) * 0.5
		var r: float = _d * 0.5
		# 정하향 soft shadow.
		draw_circle(c + Vector2(0, r * 0.16), r, Color(0, 0, 0, 0.14))
		# 김 바깥 ring (dark green-black).
		draw_circle(c, r, Color(0.10, 0.13, 0.09))
		draw_circle(c, r - 6.0, Color(0.16, 0.21, 0.13))
		# 흰 밥 ring.
		draw_circle(c, r - 12.0, Color(0.97, 0.95, 0.88))
		# 속재료 — danmuji 노랑 / spinach 녹 / carrot 주황 / egg 노랑(중앙 십자 배치).
		var fr: float = r * 0.42
		var cols := [
			Color(0.98, 0.82, 0.20), Color(0.24, 0.46, 0.18),
			Color(0.93, 0.52, 0.18), Color(0.97, 0.80, 0.26),
		]
		var positions := [
			c + Vector2(-fr * 0.6, -fr * 0.6), c + Vector2(fr * 0.6, -fr * 0.6),
			c + Vector2(-fr * 0.6, fr * 0.6), c + Vector2(fr * 0.6, fr * 0.6),
		]
		for i in range(4):
			draw_circle(positions[i], r * 0.21, cols[i])
		# 중앙 밥 코어 + top-left sheen (단면 윤기).
		draw_circle(c, r * 0.14, Color(0.99, 0.97, 0.90))
		draw_circle(c + Vector2(-r * 0.32, -r * 0.34), r * 0.18, Color(1, 1, 1, 0.12))


## slot faint gimbap silhouette — "여기 조각을 놓아라" 안내. 흐린 ring + 흐린 속 점.
## 단면 윤곽을 옅게 그려 어디에 무엇을 cut-side-up으로 놓을지 명확.
class _VsSlotSilhouette extends Control:
	var _d: float = 132.0

	func setup(diam: float) -> void:
		_d = diam
		size = Vector2(diam, diam)
		queue_redraw()

	func _draw() -> void:
		var c: Vector2 = Vector2(_d, _d) * 0.5
		var r: float = _d * 0.5
		# slot well (살짝 파인 자리 — 어디에 놓을지 명확).
		draw_circle(c, r, Color(0.0, 0.0, 0.0, 0.18))
		# 김 ring 윤곽 (faint silhouette — 또렷한 외곽 ring).
		draw_arc(c, r - 4.0, 0.0, TAU, 48, Color(1.0, 0.95, 0.66, 0.70), 5.0, true)
		draw_circle(c, r - 10.0, Color(0.18, 0.22, 0.15, 0.30))     # faint 김 silhouette
		draw_circle(c, r - 18.0, Color(0.96, 0.94, 0.86, 0.28))     # faint 흰 밥
		# 흐린 속 점(어떤 단면이 들어갈지 hint).
		var fr: float = r * 0.42
		var positions := [
			c + Vector2(-fr * 0.6, -fr * 0.6), c + Vector2(fr * 0.6, -fr * 0.6),
			c + Vector2(-fr * 0.6, fr * 0.6), c + Vector2(fr * 0.6, fr * 0.6),
		]
		for p in positions:
			draw_circle(p, r * 0.16, Color(1, 1, 1, 0.22))
