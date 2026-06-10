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
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")
const CookingFX := preload("res://scripts/ui/cooking_fx.gd")
const ActionPuckScript := preload("res://scripts/ui/action_puck.gd")
const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")
const Composition := preload("res://scripts/cooking_modules/composition.gd")

# --- 5-Layer Runtime Composition (2026-06-06) ---
## 8 module이 standalone asset를 runtime 조립하는 layer 순서. baked composite 폐기.
##   L1 environment  : CookingBackground (countertop/wall) — _attach_cooking_bg()
##   L2 vessel/base  : cutting_board / frying_pan / dolsot / pot / rolling_mat ...
##   L3 ingredient   : green_onion_whole / carrot_julienne / beef_raw (swap 대상)
##   L4 active tool  : chef_knife / ladle / spatula / tongs / seasoning_bottle ...
##   L5 vfx          : steam / slice spark / oil splash / sparkle (z 최상단)
enum { L1_ENV = 0, L2_BASE = 10, L3_INGREDIENT = 20, L4_TOOL = 30, L5_VFX = 40 }

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

## Debug zone overlay toggle (default OFF). Set true before start() to visualize zones.
static var debug_zone_overlay: bool = false


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


## P1 Cooking Rebuild (2026-06-08) — compact step header CARD in the top 15% zone.
## 이전: 텍스트가 textured wall 위에 그냥 떠서 가독성↓ + 큰 빈 header 영역. 이제:
##   - rounded card backing(warm cream + gold border)으로 text를 어떤 배경에서도 읽히게.
##   - dish name(EN) + step title 한 줄 + progress dots(현재 step 강조)로 즉시 인지.
##   - howto는 카드 아래 한 줄(작게) — 길면 bottom instruction band(_build_instruction_band)가 주역.
## 큰 빈 header 금지: 카드는 zone 상단에 compact하게(높이 ~190px) 앉는다.
func _build_header(title: String, howto: String) -> void:
	var step_no: int = int(_params.get("step_no", 1))
	var step_total: int = int(_params.get("step_total", 1))
	var menu: Dictionary = _params.get("menu", {})
	var dish_en: String = String(menu.get("name_en", ""))

	# compact header card — top 15% zone(0~288) 안쪽. safe margin 고려.
	var card := Panel.new()
	card.name = "HeaderCard"
	card.position = Vector2(48, 40)
	card.size = Vector2(984, 188)
	var csb := StyleBoxFlat.new()
	csb.bg_color = Color(1.0, 0.985, 0.945, 0.93)
	csb.set_corner_radius_all(30)
	csb.set_border_width_all(3)
	csb.border_color = Color(0.93, 0.74, 0.32)
	csb.shadow_size = 10
	csb.shadow_color = Color(0.30, 0.20, 0.10, 0.32)
	csb.shadow_offset = Vector2(0, 5)
	card.add_theme_stylebox_override("panel", csb)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.z_index = L5_VFX  # chrome는 cooking scene 위(가림 방지)
	add_child(card)

	# step title 라인 — "Step 2/4 · Slice" + dish 이름.
	var head := Label.new()
	head.name = "ModuleHeader"
	if dish_en != "":
		head.text = "Step %d/%d  ·  %s  —  %s" % [step_no, step_total, title, dish_en]
	else:
		head.text = "Step %d/%d  ·  %s" % [step_no, step_total, title]
	head.position = Vector2(28, 18)
	head.size = Vector2(928, 60)
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_theme_font_size_override("font_size", 38)
	head.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(head)

	# progress dots — step 진행 시각화 (현재 step gold, 완료 step amber, 남은 step grey).
	_build_progress_dots(card, step_no, step_total)

	# howto 한 줄 (작게) — 자세한 gesture instruction은 bottom band가 담당.
	var sub := Label.new()
	sub.name = "ModuleHowto"
	sub.text = howto
	sub.position = Vector2(28, 126)
	sub.size = Vector2(928, 50)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.add_theme_font_size_override("font_size", 26)
	sub.add_theme_color_override("font_color", Color(0.45, 0.32, 0.18))
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(sub)

	# guest reaction mini — bottom-left feedback zone (누가 기다리는지 + 표정).
	_build_guest_reaction_mini()


## progress dots — header card 중앙 하단에 step 개수만큼 점. 현재 step 강조.
func _build_progress_dots(card: Control, step_no: int, step_total: int) -> void:
	step_total = maxi(step_total, 1)
	var dots := Control.new()
	dots.name = "ProgressDots"
	var dot_r: float = 11.0
	var gap: float = 30.0
	var total_w: float = float(step_total) * (dot_r * 2.0) + float(step_total - 1) * (gap - dot_r * 2.0)
	var span: float = float(step_total - 1) * gap
	dots.position = Vector2(card.size.x * 0.5 - span * 0.5, 92.0)
	dots.size = Vector2(span + dot_r * 2.0, dot_r * 2.0)
	dots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(dots)
	for i in range(step_total):
		var d := Panel.new()
		d.position = Vector2(float(i) * gap - dot_r, -dot_r)
		d.size = Vector2(dot_r * 2.0, dot_r * 2.0)
		var dsb := StyleBoxFlat.new()
		var step_idx: int = i + 1
		if step_idx == step_no:
			dsb.bg_color = Color(0.96, 0.62, 0.18)       # 현재 step — gold
			dsb.set_border_width_all(3)
			dsb.border_color = Color(0.55, 0.32, 0.08)
		elif step_idx < step_no:
			dsb.bg_color = Color(0.86, 0.66, 0.36)       # 완료 — amber
		else:
			dsb.bg_color = Color(0.78, 0.72, 0.62, 0.55) # 남음 — grey
		dsb.set_corner_radius_all(int(dot_r))
		d.add_theme_stylebox_override("panel", dsb)
		d.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dots.add_child(d)


func _safe_feedback(judgement: int, pos: Vector2) -> void:
	var fb := get_node_or_null("/root/FeedbackBus")
	if fb and fb.has_method("hit"):
		fb.hit(judgement, pos)


# --- P1 Cooking Rebuild — shared bottom-25% chrome (instruction band + feedback) ---

## 손가락이 무엇을 해야 하는지 알려주는 gesture instruction 밴드 (bottom 25% zone 상단).
## rounded pill 카드 위에 큰 글씨로 띄워 어떤 배경에서도 읽힌다. 반환 Label로 module이
## 실시간 message를 갱신(set_instruction). 이전: 각 module이 y=1500~1700에 raw 텍스트를
## textured wall 위에 흩뿌려 가독성↓ + 일관성 없음. 이제 전 module 동일 위치/스타일.
##   icon_hint : 앞에 붙는 작은 아이콘/이모지 hint (예: "↓", "⟳", "↑↑"). "" 가능.
var _instruction_lbl: Label = null

func _build_instruction_band(text: String, icon_hint: String = "") -> Label:
	# feedback zone 상단(1440~)에 instruction pill. guest mini(좌하단)와 안 겹치게 우측 정렬 폭.
	var band := Panel.new()
	band.name = "InstructionBand"
	band.position = Vector2(220, 1466)
	band.size = Vector2(640, 96)
	var bsb := StyleBoxFlat.new()
	bsb.bg_color = Color(0.20, 0.13, 0.08, 0.80)
	bsb.set_corner_radius_all(48)
	bsb.set_border_width_all(3)
	bsb.border_color = Color(0.95, 0.72, 0.28, 0.85)
	bsb.shadow_size = 8
	bsb.shadow_color = Color(0, 0, 0, 0.30)
	band.add_theme_stylebox_override("panel", bsb)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	band.z_index = L5_VFX
	add_child(band)
	_instruction_lbl = Label.new()
	_instruction_lbl.name = "InstructionText"
	_instruction_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	_instruction_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_instruction_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_instruction_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_instruction_lbl.text = (icon_hint + "  " + text) if icon_hint != "" else text
	_instruction_lbl.add_theme_font_size_override("font_size", 36)
	_instruction_lbl.add_theme_color_override("font_color", Color(1.0, 0.97, 0.90))
	_instruction_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	band.add_child(_instruction_lbl)
	return _instruction_lbl


## instruction 밴드 텍스트 갱신 (실시간 feedback). _build_instruction_band 후 호출.
func _set_instruction(text: String) -> void:
	if is_instance_valid(_instruction_lbl):
		_instruction_lbl.text = text


## 손님 reaction mini — bottom-left feedback zone. "누가 기다리는지" + idle 표정.
## runner의 큰 guest mini와 별개로, 격리된 module shot에서도 한식 정체성+손님 맥락을 보장.
## guest sprite(neutral)가 있으면 사용, 없으면 색 원 + 이니셜. 작아서 action을 안 가린다.
func _build_guest_reaction_mini() -> void:
	var guest_id: String = String(_params.get("guest_id", ""))
	if guest_id == "":
		return
	var rect: Rect2 = Composition.guest_mini_rect()
	var holder := Control.new()
	holder.name = "GuestReactionMini"
	holder.position = rect.position
	holder.size = rect.size
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.z_index = L5_VFX
	add_child(holder)
	var ring := Panel.new()
	ring.set_anchors_preset(Control.PRESET_FULL_RECT)
	var rsb := StyleBoxFlat.new()
	rsb.bg_color = _guest_tint(guest_id)
	rsb.set_corner_radius_all(int(rect.size.x * 0.5))
	rsb.set_border_width_all(4)
	rsb.border_color = Color(1, 1, 1, 0.9)
	rsb.shadow_size = 8
	rsb.shadow_color = Color(0, 0, 0, 0.35)
	rsb.shadow_offset = Vector2(0, 4)
	ring.add_theme_stylebox_override("panel", rsb)
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.clip_contents = true
	holder.add_child(ring)
	var avatar_path := "res://art/sprites/character/%s_neutral.png" % guest_id
	if ResourceLoader.exists(avatar_path):
		var av := TextureRect.new()
		av.texture = load(avatar_path)
		av.set_anchors_preset(Control.PRESET_FULL_RECT)
		av.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		av.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		av.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ring.add_child(av)
	else:
		var initial := Label.new()
		initial.text = guest_id.substr(0, 1).to_upper()
		initial.set_anchors_preset(Control.PRESET_FULL_RECT)
		initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		initial.add_theme_font_size_override("font_size", 56)
		initial.add_theme_color_override("font_color", Color.WHITE)
		ring.add_child(initial)
	# "Hungry!" 미니 말풍선 (손님이 기다리는 맥락).
	var bubble := Panel.new()
	bubble.position = Vector2(rect.size.x + 8.0, 6.0)
	bubble.size = Vector2(150, 50)
	var blsb := StyleBoxFlat.new()
	blsb.bg_color = Color(1.0, 0.99, 0.93, 0.95)
	blsb.set_corner_radius_all(22)
	blsb.set_border_width_all(2)
	blsb.border_color = Color(0.70, 0.50, 0.20)
	bubble.add_theme_stylebox_override("panel", blsb)
	bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(bubble)
	var bl := Label.new()
	bl.text = "Hungry!"
	bl.set_anchors_preset(Control.PRESET_FULL_RECT)
	bl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bl.add_theme_font_size_override("font_size", 24)
	bl.add_theme_color_override("font_color", Color(0.40, 0.20, 0.08))
	bl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bubble.add_child(bl)


const _GUEST_MINI_TINT := {
	"junho": Color(0.86, 0.45, 0.40), "mina": Color(0.95, 0.78, 0.45),
	"riley": Color(0.55, 0.72, 0.85), "mrs_lee": Color(0.70, 0.80, 0.62),
	"seoyeon": Color(0.80, 0.62, 0.85),
	"mother_01": Color(0.85, 0.60, 0.70), "father_01": Color(0.55, 0.45, 0.40),
}

func _guest_tint(guest_id: String) -> Color:
	return _GUEST_MINI_TINT.get(guest_id, Color(0.82, 0.72, 0.60))


# --- D3 polish helpers (shared by all 8 cooking modules) ---

## Attach a shared kitchen background BEHIND everything in this module. Call FIRST in
## _module_start before adding tool/dish/puck nodes.  dish_anchor_y tunes where the
## warm spotlight pool lands (defaults to where most modules sit their food).
func _attach_cooking_bg(dish_anchor_y: float = 1000.0) -> void:
	# runner가 이미 KitchenBackground를 깔았으면 module은 자체 bg를 생략 (chrome 가림 방지).
	# 단, debug overlay는 여전히 붙인다.
	if bool(_params.get("skip_bg", false)):
		if debug_zone_overlay:
			Composition.attach_debug_overlay(self, true)
		return
	# 환경 art 배경 (warm kitchen counter + 뒷벽 + props). beige void 제거.
	# World-integration(2026-06-08): fill_screen=true로 화면 전체를 한식 주방 world로 채운다
	# (상단 절반 beige wall-연장 제거). level → 환경 매핑은 KitchenBackground 공유 helper 사용.
	var bg = KitchenBackgroundScript.new()
	bg.fill_screen = true
	bg.dish_anchor_y = dish_anchor_y
	bg.env_key = _env_key_for_level()
	# Insert at index 0 so module art renders on top.
	add_child(bg)
	move_child(bg, 0)
	# Debug zone overlay (default OFF) — 개발 시 zone 경계 시각화.
	if debug_zone_overlay:
		Composition.attach_debug_overlay(self, true)


## level market → 환경 art key (공유 매핑 — home/noryangjin/market/gwangjang 지원).
func _env_key_for_level() -> String:
	var lvl: Dictionary = _params.get("level", {})
	return KitchenBackgroundScript.env_key_for_market(String(lvl.get("market", "home")))


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


# --- 5-Layer composition mount helpers (shared by all 8 cooking modules) ---

## L2/L3 standalone sprite를 화면 rect에 mount. path 없으면 null(caller가 procedural).
## TextureRect로 mount하며 z_index = layer로 합성 순서를 보장한다.
##   path   : res:// 경로 (get_vessel / get_ingredient / get_tool 결과)
##   rect   : 화면(1080x1920) 좌표 Rect2 (position + size)
##   layer  : L2_BASE / L3_INGREDIENT / L4_TOOL 중 하나
## 반환 TextureRect는 caller가 swap/tween(modulate/rotation 등)에 사용.
func _mount_sprite(path: String, rect: Rect2, layer: int,
		node_name: String = "") -> TextureRect:
	if path == "" or not ResourceLoader.exists(path):
		return null
	var tex := TextureRect.new()
	if node_name != "":
		tex.name = node_name
	tex.texture = load(path)
	tex.position = rect.position
	tex.size = rect.size
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex.pivot_offset = rect.size * 0.5
	tex.z_index = layer
	add_child(tex)
	return tex


## L2 base (vessel/tool base) mount. 미존재 시 procedural 그릇 패널 fallback.
func _mount_vessel(path: String, rect: Rect2, fallback_round: bool = true) -> TextureRect:
	var t := _mount_sprite(path, rect, L2_BASE, "L2_Vessel")
	if t != null:
		return t
	# procedural fallback — 둥근(냄비) 또는 사각(도마) 패널.
	var pan := Panel.new()
	pan.name = "L2_VesselFallback"
	pan.position = rect.position
	pan.size = rect.size
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.24, 0.20, 0.18) if fallback_round else Color(0.79, 0.61, 0.39)
	sb.set_corner_radius_all(int(minf(rect.size.x, rect.size.y) * 0.5) if fallback_round else 36)
	if not fallback_round:
		sb.set_border_width_all(6)
		sb.border_color = Color(0.40, 0.27, 0.16)
	pan.add_theme_stylebox_override("panel", sb)
	pan.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pan.z_index = L2_BASE
	add_child(pan)
	return null   # caller가 fallback 여부를 알 수 있게 null


## L3 ingredient mount. 미존재 시 null(caller가 색블록 등 procedural 처리 — arrange/season은 금지).
func _mount_ingredient(path: String, rect: Rect2, node_name: String = "L3_Ingredient") -> TextureRect:
	return _mount_sprite(path, rect, L3_INGREDIENT, node_name)


## L4 active tool mount (chef_knife / spatula / seasoning_bottle ...).
func _mount_tool(path: String, rect: Rect2, node_name: String = "L4_Tool") -> TextureRect:
	return _mount_sprite(path, rect, L4_TOOL, node_name)


# --- composition-aware mount helpers (zone + scale clamp, 2026-06-06) ---

## zone + clamp ratio로 계산한 rect에 sprite를 aspect-fit mount. 화면 밖 crop 금지.
## path 미존재 시 null. layer = L2_BASE / L3_INGREDIENT / L4_TOOL.
func _mount_clamped(path: String, zone: Rect2, clamp: Vector2, layer: int,
		anchor: Vector2 = Vector2(0.5, 0.5), node_name: String = "") -> TextureRect:
	if path == "" or not ResourceLoader.exists(path):
		return null
	var rect: Rect2 = Composition.rect_in_zone(zone, clamp, anchor)
	var tex := TextureRect.new()
	if node_name != "":
		tex.name = node_name
	tex.texture = load(path)
	Composition.fit_texture_rect(tex, rect)
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex.z_index = layer
	add_child(tex)
	return tex


## 특정 center 점에 clamp ratio로 sprite mount (vessel 안 food 등). path 미존재 시 null.
func _mount_at_center(path: String, center: Vector2, clamp: Vector2, layer: int,
		node_name: String = "") -> TextureRect:
	if path == "" or not ResourceLoader.exists(path):
		return null
	var rect: Rect2 = Composition.rect_at_center(center, clamp)
	var tex := TextureRect.new()
	if node_name != "":
		tex.name = node_name
	tex.texture = load(path)
	Composition.fit_texture_rect(tex, rect)
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex.z_index = layer
	add_child(tex)
	return tex


## 명시 rect에 sprite를 aspect-fit mount (rect_inside 등으로 계산한 rect용). path 미존재 시 null.
func _mount_in_rect(path: String, rect: Rect2, layer: int,
		node_name: String = "") -> TextureRect:
	if path == "" or not ResourceLoader.exists(path):
		return null
	var tex := TextureRect.new()
	if node_name != "":
		tex.name = node_name
	tex.texture = load(path)
	Composition.fit_texture_rect(tex, rect)
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex.z_index = layer
	add_child(tex)
	return tex
