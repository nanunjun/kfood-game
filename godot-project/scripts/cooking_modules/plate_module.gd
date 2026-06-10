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
# Gimbap Vertical Slice — drag-arrange plating (design §5.3, Success Criteria #6).
# 김밥 8조각을 wooden_tray의 target row에 drag로 배치. spacing 균일 + 중앙 안착 + orientation
# (단면 위로)이 plate_quality를 결정한다. slice_quality 낮으면 조각이 wobble(제각각 단면).
# "plating이 static이 아니다 — 조각 배치/간격이 완성 비주얼을 바꾼다."
# =====================================================================================

const VS_PIECE_COUNT: int = 6        # 김밥 조각 수 (8조각이 이상이나 화면/난이도 균형 6).
const VS_SNAP_RADIUS: float = 120.0  # target에 이 거리 안이면 snap.

func _start_vs_plating(params: Dictionary) -> void:
	_vs_plate = true
	_attach_cooking_bg(1030.0)
	_build_header("Plating", "Drag each gimbap piece onto the tray")
	_build_instruction_band("Place pieces evenly, cut-side up", "↓")

	# wooden_tray vessel(L2) — 완성 dish를 담는 받침.
	var tray_rect := Rect2(150, 760, 780, 360)
	var tray_path: String = ArtRegistry.get_vessel("wooden_tray")
	if tray_path != "":
		var tray := TextureRect.new()
		tray.texture = load(tray_path)
		tray.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tray.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tray.position = tray_rect.position
		tray.size = tray_rect.size
		tray.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tray.z_index = L2_BASE
		add_child(tray)
	else:
		var tray_fb := Panel.new()
		tray_fb.position = tray_rect.position
		tray_fb.size = tray_rect.size
		var tsb := StyleBoxFlat.new()
		tsb.bg_color = Color(0.78, 0.58, 0.34)
		tsb.set_corner_radius_all(36)
		tsb.set_border_width_all(8)
		tsb.border_color = Color(0.55, 0.38, 0.20)
		tray_fb.add_theme_stylebox_override("panel", tsb)
		tray_fb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tray_fb.z_index = L2_BASE
		add_child(tray_fb)
	_attach_dish_shadow(Vector2(540, tray_rect.position.y + tray_rect.size.y * 0.95), 540.0)

	# target row — tray 안 고른 간격(spacing 정답). ghost ring으로 표시.
	var row_y: float = tray_rect.position.y + tray_rect.size.y * 0.46
	var span: float = tray_rect.size.x * 0.80
	var x0: float = 540.0 - span * 0.5
	for i in range(VS_PIECE_COUNT):
		var tx: float = x0 + span * (float(i) / float(VS_PIECE_COUNT - 1))
		var tpos := Vector2(tx, row_y)
		_vs_targets.append(tpos)
		var ghost := Panel.new()
		ghost.position = tpos - Vector2(56, 56)
		ghost.size = Vector2(112, 112)
		var gsb := StyleBoxFlat.new()
		gsb.bg_color = Color(1, 1, 1, 0.06)
		gsb.set_corner_radius_all(56)
		gsb.set_border_width_all(3)
		gsb.border_color = Color(1.0, 0.92, 0.55, 0.45)
		ghost.add_theme_stylebox_override("panel", gsb)
		ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ghost.z_index = L2_BASE + 1
		add_child(ghost)

	# 조각 sprite(content_only 완성 김밥의 단면) — 하단 tray 밖 pile에서 시작, drag로 배치.
	var piece_path: String = ArtRegistry.get_roll_asset("gimbap_roll_finished_content_only")
	var wobble: float = clampf(1.0 - _vs_slice_quality, 0.0, 1.0)   # slice 나쁨 → 단면 제각각.
	for i in range(VS_PIECE_COUNT):
		var home := Vector2(180.0 + float(i) * 130.0, 1480.0)
		var piece := Control.new()
		piece.size = Vector2(120, 120)
		piece.position = home - piece.size * 0.5
		piece.pivot_offset = piece.size * 0.5
		piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
		piece.z_index = L3_INGREDIENT
		if piece_path != "":
			var t := TextureRect.new()
			t.texture = load(piece_path)
			t.set_anchors_preset(Control.PRESET_FULL_RECT)
			t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			t.mouse_filter = Control.MOUSE_FILTER_IGNORE
			piece.add_child(t)
		else:
			var c := Panel.new()
			c.set_anchors_preset(Control.PRESET_FULL_RECT)
			var csb := StyleBoxFlat.new()
			csb.bg_color = Color(0.18, 0.20, 0.16)
			csb.set_corner_radius_all(60)
			csb.set_border_width_all(8)
			csb.border_color = Color(0.95, 0.95, 0.90)
			c.add_theme_stylebox_override("panel", csb)
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE
			piece.add_child(c)
		# §8.5 slice→plating: slice_quality 낮으면 조각이 처음부터 wobble(기울고 크기 제각각).
		if wobble > 0.05:
			piece.rotation = deg_to_rad(randf_range(-20.0, 20.0) * wobble)
			var sj: float = 1.0 + randf_range(-0.18, 0.18) * wobble
			piece.scale = Vector2(sj, sj)
		add_child(piece)
		_vs_pieces.append({"node": piece, "home": home, "placed": false, "idx": i, "wobble": wobble})

	_vs_hint = Label.new()
	_vs_hint.position = Vector2(0, 1640)
	_vs_hint.size = Vector2(1080, 60)
	_vs_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_vs_hint.add_theme_font_size_override("font_size", 38)
	_vs_hint.add_theme_color_override("font_color", Color(0.45, 0.32, 0.18))
	_vs_hint.text = "Drag the pieces onto the tray row"
	add_child(_vs_hint)

	_vs_gesture = TouchGesture.new()
	_vs_gesture.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_vs_gesture)
	_vs_gesture.drag_started.connect(_on_vs_drag_started)
	_vs_gesture.drag_updated.connect(_on_vs_drag_updated)
	_vs_gesture.drag_released.connect(_on_vs_drag_released)


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
		# target 근처 아님 — 홈 복귀.
		node.z_index = L3_INGREDIENT
		var tw := node.create_tween()
		tw.tween_property(node, "position", _vs_pieces[idx]["home"] - node.size * 0.5, 0.16)
		return
	# snap settle — target에 안착. placement 오차(snap 전 거리)를 plate_quality에 반영.
	_vs_pieces[idx]["placed"] = true
	_vs_pieces[idx]["target_idx"] = best_t
	_vs_pieces[idx]["err"] = best_d
	_vs_placed_count += 1
	node.z_index = 9
	var target_pos: Vector2 = _vs_targets[best_t]
	var tw2 := node.create_tween()
	tw2.tween_property(node, "position", target_pos - node.size * 0.5, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# orientation 정렬 — slice 좋으면 단면 위로 똑바로, 나쁘면 wobble 잔존.
	if float(_vs_pieces[idx]["wobble"]) <= 0.15:
		tw2.parallel().tween_property(node, "rotation", 0.0, 0.16)
	_safe_feedback(RhythmJudge.GOOD, target_pos)
	if is_instance_valid(_vs_hint):
		_vs_hint.text = "%d / %d placed" % [_vs_placed_count, VS_PIECE_COUNT]
	if _vs_placed_count >= VS_PIECE_COUNT:
		_finalize_vs_plating()


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
