## SeasonModule — ACTION-FIRST tilt-bottle seasoning (ADR-012).
##
## "I added seasoning" — NOT "I pressed ADD". The player drags a seasoning bottle to tilt
## it over the food; particles fall and the food surface changes color/sheen. Tilt angle +
## hold time = amount.
##
## ADR-012 input redesign (2026-06-05): 1-tap ADD button 폐기 → tilt + hold.
##   Mode A (default, 11 dishes): 가벼운 tilt = 적정 양 자동 (ADR-007 정합, 시각 ambience).
##     양념별 입자(고춧가루 톡톡 / 간장 줄기 / 참기름 drizzle). score = 90 (auto-pour 대체,
##     balance 무변경 — 기존 _on_simple_add 90.0 그대로).
##   Mode B (marinade, 불고기 t2_014): tilt-and-massage 연속 동작 N회 (60 BPM 마사지를 tilt
##     drag로 표현). score = 평균 rhythm accuracy (기존 marinade 계산 무변경).
##
## SCORING 무변경 (§6.1 / §3.6): default=1.0(×90), marinade=tap 평균. 출력 score 도메인
## [0,100] 동일, `module_completed(score)` contract 동일.
## 5-Layer Composition (2026-06-06): base vessel(L2) + dish food(L3) + seasoning_bottle(L4)
## + seasoning particles(L5). abstract color block 제거 — 실제 seasoning_bottle sprite로
## 기울여 양념을 뿌린다. standalone sprite runtime 합성.
extends "res://scripts/cooking_modules/base_module.gd"

const TouchGesture := preload("res://scripts/cooking_modules/touch_gesture.gd")


## _BrothMask — bowl 안쪽 broth surface에만 깔리는 soft 타원 mask (그릇 rim 절대 안 덮음).
## 사각 ColorRect는 그릇 rim 위로 하드 모서리가 보여 sticker처럼 됐다. 이 Control은 rect 안에
## radial-faded 타원을 _draw로 그려 broth 표면처럼 자연스럽게 붉어진다. vessel/rim/배경 보존.
class _BrothMask extends Control:
	var broth_color: Color = Color(0.82, 0.18, 0.12, 0.0):
		set(v):
			broth_color = v
			queue_redraw()

	func _draw() -> void:
		if broth_color.a <= 0.001:
			return
		var c := Vector2(size.x * 0.5, size.y * 0.5)
		var rx: float = size.x * 0.47
		var ry: float = size.y * 0.43
		# 단일 타원 polygon — 균일 alpha (겹침 알파 누적 없음 = 음식 위 solid red lid 방지).
		# broth만 semi-transparent하게 redder, 면·계란은 broth 너머로 그대로 read. 그릇 rim은
		# 타원이 안쪽이라 안 덮음(vessel 보존). 가장자리는 한 단계 옅은 ring으로 soft fade.
		var segs: int = 48
		# 가장자리 soft halo 먼저(살짝 큰 타원, 더 옅게) → 그 위에 메인 pool. 이 순서라야
		# 중앙은 메인 균일 alpha만, rim 쪽은 halo 옅은 띠만 보여 알파 누적/solid red lid가 없다.
		var halo := PackedVector2Array()
		for i in range(segs):
			var ang2: float = TAU * float(i) / float(segs)
			halo.append(c + Vector2(cos(ang2) * rx * 1.07, sin(ang2) * ry * 1.07))
		draw_colored_polygon(halo, Color(broth_color.r, broth_color.g, broth_color.b, broth_color.a * 0.45))
		# 메인 broth pool (균일 alpha — 면·계란이 broth 너머로 그대로 보임).
		var pts := PackedVector2Array()
		for i in range(segs):
			var ang: float = TAU * float(i) / float(segs)
			pts.append(c + Vector2(cos(ang) * rx, sin(ang) * ry))
		draw_colored_polygon(pts, Color(broth_color.r, broth_color.g, broth_color.b, broth_color.a))

const MARINADE_BPM: float = 60.0
const MARINADE_TAPS: int = 3
const LEAD_IN_MS: float = 900.0

# 양념 종류 → 입자 색 + 낙하 스타일 (§5.2).
# applicator: "bottle" = 양념병 tilt(가루·줄기·drizzle) / "dollop" = paste 한 덩이 spoon으로 얹기.
# P0 #3 (2026-06-07): gochujang은 paste dollop (병/가루 아님 — 비빔밥 정답). gochugaru는 가루 bottle.
const SEASONING_STYLES := {
	"gochugaru":  {"col": Color(0.82, 0.18, 0.12), "style": "powder",  "applicator": "bottle", "label": "Chili flakes", "sprite": ""},
	"soy":        {"col": Color(0.30, 0.18, 0.08), "style": "stream",  "applicator": "bottle", "label": "Soy sauce", "sprite": ""},
	"sesame_oil": {"col": Color(0.92, 0.78, 0.28), "style": "drizzle", "applicator": "bottle", "label": "Sesame oil", "sprite": ""},
	"gochujang":  {"col": Color(0.78, 0.20, 0.15), "style": "paste",   "applicator": "dollop", "label": "Gochujang", "sprite": "gochujang_dollop"},
}

var _mode: String = "simple"
var _taps: Array = []
var _start_ms: float = 0.0

# bottle (procedural — 양념병 LOCK art 미발급, §11 fallback).
var _bottle: Node2D = null
var _bottle_home: Vector2 = Vector2.ZERO
var _food_hero: TextureRect = null
var _gesture = null   # TouchGestureRecognizer (preloaded TouchGesture)

# Seasoning tint layer-bug fix (2026-06-08) — vessel/tool/bg는 절대 물들이지 않는다.
#   _food_hero (VesselSprite/dish-with-bowl 단일 이미지)는 그릇을 포함하므로 여기에
#   modulate를 걸면 bowl까지 빨갛게 = 버그. tint 대상을 명시적으로 분리:
#     _food_content : FoodContentSprite  — 그릇 없는 음식 내용물(content_only asset 있을 때만).
#                     tint 허용 node. 없으면 null → overlay/particle fallback.
#     _season_overlay: SeasoningOverlay  — dish-with-bowl 단일 이미지에서 bowl 안쪽에만
#                     깔리는 semi-transparent red broth mask (그릇 rim 제외). 단일 image
#                     modulate 금지의 안전한 대체. content_only가 없을 때 사용.
#   _tint_target = 실제로 색을 입힐 node(content sprite 또는 overlay). vessel(_food_hero)이
#   content_only를 가진 경우엔 _food_hero 전체 modulate를 절대 하지 않는다.
var _food_content: TextureRect = null   # FoodContentSprite (tint OK)
var _season_overlay: _BrothMask = null  # SeasoningOverlay (bowl 안 broth mask, tint OK)
var _vessel_only: bool = false          # _food_hero가 vessel(그릇 포함) 단일 이미지인가
var _food_center: Vector2 = Vector2(540, 816)   # particle 낙하 목표(음식 중앙) — player-POV pour.
# 기본 양념 style = bottle 가루(gochugaru). seasoning param 미지정 dish는 양념병 연출.
# gochujang dollop은 seasoning="gochujang"을 명시한 dish(비빔밥·떡볶이)에서만 (P0 #3: silent dollop 방지).
var _style: Dictionary = SEASONING_STYLES["gochugaru"]
var _particles_holder: Control = null

# simple-mode pour 누적 상태.
var _poured: float = 0.0             # tilt-hold로 부은 양 [0,1]
var _pouring: bool = false
var _hint: Label = null

# marinade-mode 진행.
var _massaging: bool = false
var _last_massage_idx: int = -1


func _module_start(params: Dictionary) -> void:
	_attach_cooking_bg(1000.0)
	_mode = String(params.get("mode", "simple"))
	# 양념 종류 (음식별 hint — 없으면 기본 고추장).
	var seas: String = String(params.get("seasoning", ""))
	if seas != "" and SEASONING_STYLES.has(seas):
		_style = SEASONING_STYLES[seas]
	_particles_holder = Control.new()
	_particles_holder.name = "SeasoningParticles"   # L5 입자/aroma — vessel과 무관(tint 0).
	_particles_holder.set_anchors_preset(Control.PRESET_FULL_RECT)
	_particles_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_particles_holder.z_index = L5_VFX   # L5 — seasoning 입자는 항상 위
	if _mode == "marinade":
		_start_marinade(params)
	else:
		_start_simple()
	add_child(_particles_holder)

	# 입력 인식기 — 병 tilt drag.
	_gesture = TouchGesture.new()
	_gesture.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_gesture)
	_gesture.drag_started.connect(_on_drag_started)
	_gesture.drag_updated.connect(_on_drag_updated)
	_gesture.tilt_changed.connect(_on_tilt_changed)
	_gesture.drag_released.connect(_on_drag_released)


# --- simple mode (tilt + hold) ---

func _start_simple() -> void:
	# applicator에 맞춘 howto (dollop=spoon paste / bottle=tilt). 자세한 gesture = bottom band.
	if String(_style.get("applicator", "bottle")) == "dollop":
		_build_header("Season", "Add seasoning to the dish")
		_build_instruction_band("Spoon the %s paste onto the food" % String(_style.get("label", "sauce")), "↓")
	else:
		_build_header("Season", "Add seasoning to the dish")
		_build_instruction_band("Tilt the %s bottle over the food" % String(_style.get("label", "")), "↧")

	# 음식 hero (양념 받을 대상) — action zone 중앙 (dish hero clamp ≤70%W/45%H).
	var food_id_s: StringName = StringName(String(_params.get("food_id", "")))
	var food_img: String = ArtRegistry.food(food_id_s)
	var content_img: String = ArtRegistry.food_content_only(food_id_s)
	var food_rect: Rect2 = Composition.rect_in_zone(
		Composition.ZONE_ACTION, Composition.CLAMP_DISH_HERO, Vector2(0.5, 0.5))
	_food_center = food_rect.position + food_rect.size * 0.5   # particle 낙하 목표.
	if ArtRegistry.file_exists(food_img):
		# VesselSprite — dish-with-bowl 단일 이미지(그릇 포함). 절대 modulate하지 않는다.
		_food_hero = TextureRect.new()
		_food_hero.name = "VesselSprite"
		_food_hero.texture = load(food_img)
		Composition.fit_texture_rect(_food_hero, food_rect)
		_food_hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_food_hero.z_index = L3_INGREDIENT
		add_child(_food_hero)
		_attach_dish_shadow(Vector2(540, food_rect.position.y + food_rect.size.y * 0.85), 440.0)
		# tint 대상 분리 — content_only asset이 있으면 그릇 없는 내용물만 그 위에 올려 tint.
		if ArtRegistry.file_exists(content_img):
			# FoodContentSprite — 그릇 없는 음식 내용물. tint는 여기만 (vessel 보존).
			_food_content = TextureRect.new()
			_food_content.name = "FoodContentSprite"
			_food_content.texture = load(content_img)
			Composition.fit_texture_rect(_food_content, food_rect)
			_food_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_food_content.z_index = L3_INGREDIENT + 1
			add_child(_food_content)
			_vessel_only = false
		else:
			# dish-with-bowl 단일 이미지 — 전체 image tint 금지. bowl 안쪽에만 깔리는
			# SeasoningOverlay(semi-transparent red broth mask, 그릇 rim 제외)로 표현.
			_vessel_only = true
			_build_season_overlay(food_rect)

	# Player-POV (player-pov-camera-v1.md §3): 양념병은 화면 **하단-우(NEAR zone, 플레이어 손)**
	# 에서 진입해 음식(중앙)을 향해 기울인다. far side floating 금지 — 손이 든 듯 아래에서.
	# particle은 음식(중앙) 위로 낙하 (병 위치가 아래라도 food center를 향해 뿌림).
	_bottle = _build_bottle()
	_bottle_home = Vector2(820, 1190)     # 하단-우(NEAR) — 플레이어 손에 든 위치.
	_bottle.position = _bottle_home
	_bottle.rotation = deg_to_rad(-34.0)  # 음식(좌상)을 향해 기울임 — 입구가 food 쪽으로.
	add_child(_bottle)
	# simple mode 실시간 hint = instruction band (별도 _hint label 제거 — 일관 위치).
	_hint = null


## SeasoningOverlay — dish-with-bowl 단일 이미지(라면 t1_002 등)에서 vessel 전체를 물들이지
## 않기 위한 안전 대체. food_rect 안쪽(bowl rim 제외) 중앙 타원 영역에만 semi-transparent
## red broth mask를 깔아 broth/내용물만 붉어 보이게 한다. 그릇 rim/배경은 건드리지 않는다.
## 처음엔 알파 0 (양념 전엔 색 변화 0) → pour 양에 따라 _apply_food_tint가 알파를 올림.
func _build_season_overlay(food_rect: Rect2) -> void:
	# bowl 안쪽 broth 영역 = food_rect의 ~52% 중앙(rim·테두리 제외). broth surface는 살짝 위.
	var inner: Rect2 = Composition.rect_inside(food_rect, 0.52, -food_rect.size.y * 0.06)
	_season_overlay = _BrothMask.new()
	_season_overlay.name = "SeasoningOverlay"
	_season_overlay.position = inner.position
	_season_overlay.size = inner.size
	_season_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# z = vessel 바로 위, particles(L5) 아래. broth 표면처럼 보이게.
	_season_overlay.z_index = L3_INGREDIENT + 1
	# 시작 알파 0 (양념 전엔 broth 색 변화 0). soft 타원 — 그릇 rim 절대 안 덮음.
	_season_overlay.broth_color = Color(_style["col"].r, _style["col"].g, _style["col"].b, 0.0)
	add_child(_season_overlay)


func _build_bottle() -> Node2D:
	# P0 #3: gochujang은 paste dollop applicator (양념병 아님). spoon + gochujang_dollop sprite.
	if String(_style.get("applicator", "bottle")) == "dollop":
		return _build_dollop_applicator()
	var bottle := Node2D.new()
	bottle.z_index = L4_TOOL
	# L4 — seasoning_bottle standalone sprite. 있으면 procedural 대신 사용.
	var path: String = ArtRegistry.get_tool("seasoning_bottle")
	if path != "":
		var tex := TextureRect.new()
		# expand_mode를 texture 할당 전에 — 1024px 최소크기 박힘 방지(거대 병 버그). ≤38%H.
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.custom_minimum_size = Vector2.ZERO
		tex.texture = load(path)
		tex.size = Vector2(220, 400)
		# origin이 병 입구(아래) 근처 오도록 — 기울이면 입구에서 쏟아짐.
		tex.position = Vector2(-110, -56)
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bottle.add_child(tex)
		return bottle
	# procedural fallback (sprite 미존재).
	# Node2D는 origin(0,0) 기준 회전 — pivot_offset 불필요 (Control 전용 속성).
	# body
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-70, -10), Vector2(70, -10), Vector2(70, 200),
		Vector2(40, 260), Vector2(-40, 260), Vector2(-70, 200),
	])
	body.color = Color(0.86, 0.30, 0.20, 0.92)
	bottle.add_child(body)
	# neck
	var neck := Polygon2D.new()
	neck.polygon = PackedVector2Array([
		Vector2(-30, -70), Vector2(30, -70), Vector2(30, -10), Vector2(-30, -10),
	])
	neck.color = Color(0.78, 0.24, 0.16, 0.92)
	bottle.add_child(neck)
	# cap
	var cap := Polygon2D.new()
	cap.polygon = PackedVector2Array([
		Vector2(-36, -110), Vector2(36, -110), Vector2(36, -70), Vector2(-36, -70),
	])
	cap.color = Color(0.30, 0.20, 0.12)
	bottle.add_child(cap)
	# label patch
	var lbl := Polygon2D.new()
	lbl.polygon = PackedVector2Array([
		Vector2(-50, 40), Vector2(50, 40), Vector2(50, 160), Vector2(-50, 160),
	])
	lbl.color = Color(0.98, 0.94, 0.86, 0.9)
	bottle.add_child(lbl)
	return bottle


## P0 #3 — gochujang dollop applicator: spoon(L4 tool) + gochujang_dollop paste blob.
## 양념병 tilt가 아니라 paste 한 덩이를 spoon으로 음식 위에 얹는다 (비빔밥 정답 연출).
func _build_dollop_applicator() -> Node2D:
	var holder := Node2D.new()
	holder.z_index = L4_TOOL
	# spoon (L4 tool standalone). 미존재 시 procedural 작은 숟가락.
	var spoon_path: String = ArtRegistry.get_tool("spoon")
	if spoon_path != "":
		var stex := TextureRect.new()
		stex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		stex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		stex.custom_minimum_size = Vector2.ZERO
		stex.texture = load(spoon_path)
		stex.size = Vector2(180, 300)
		stex.position = Vector2(-90, -150)
		stex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(stex)
	else:
		var handle := Polygon2D.new()
		handle.polygon = PackedVector2Array([
			Vector2(-12, -150), Vector2(12, -150), Vector2(14, 40), Vector2(-14, 40),
		])
		handle.color = Color(0.62, 0.42, 0.24)
		holder.add_child(handle)
	# gochujang dollop paste blob — spoon 머리(아래)에 얹힌 한 덩이. drag로 음식에 떨어뜨림.
	var dollop_sprite: String = String(_style.get("sprite", ""))
	var dollop_path: String = ArtRegistry.get_ingredient(dollop_sprite) if dollop_sprite != "" else ""
	if dollop_path != "":
		var dtex := TextureRect.new()
		dtex.name = "DollopBlob"
		dtex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		dtex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		dtex.custom_minimum_size = Vector2.ZERO
		dtex.texture = load(dollop_path)
		dtex.size = Vector2(140, 140)
		dtex.position = Vector2(-70, 30)
		dtex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(dtex)
	else:
		# procedural paste blob (sprite 미존재 placeholder).
		var blob := Polygon2D.new()
		blob.polygon = PackedVector2Array([
			Vector2(-50, 70), Vector2(0, 40), Vector2(50, 70), Vector2(56, 110),
			Vector2(0, 130), Vector2(-56, 110),
		])
		blob.color = _style.get("col", Color(0.78, 0.20, 0.15))
		holder.add_child(blob)
	return holder


# --- gesture: tilt + hold pour (simple) / tilt-massage (marinade) ---

func _on_drag_started(pos: Vector2) -> void:
	if _finished:
		return
	if _mode == "marinade":
		_massaging = true
		return
	# 병 근처를 잡으면 pour 시작.
	_pouring = is_instance_valid(_bottle) and pos.distance_to(_bottle.position) < 360.0


func _on_drag_updated(pos: Vector2, _vel: Vector2) -> void:
	if _finished:
		return
	if _mode == "marinade":
		_massage_at(pos)
		return
	if _pouring and is_instance_valid(_bottle):
		# 병이 손가락 X를 따라감 (NEAR zone에서 좌우 이동하며 음식 위로 뿌림). y는 하단 유지.
		_bottle.position.x = clampf(pos.x, 360.0, 880.0)


func _on_tilt_changed(angle_deg: float, _hold_ms: float) -> void:
	if _finished:
		return
	if _mode == "marinade":
		return
	if not _pouring or not is_instance_valid(_bottle):
		return
	# 병 기울임 = drag 각도. 더 기울일수록(아래로 향할수록) 더 많이 쏟아짐.
	_bottle.rotation = deg_to_rad(clampf(angle_deg, 0.0, 75.0))
	if angle_deg > 18.0:
		# 입자 낙하 + 양 누적. player-POV: 병이 하단에 있어도 양념은 음식(중앙) 위로 떨어진다
		# (병 입구에서 food center로 — far side floating 금지). 약간 위에서 낙하 시작.
		var pour_at := Vector2(_bottle.position.x * 0.35 + _food_center.x * 0.65, _food_center.y - 120.0)
		_emit_particles(pour_at, 2)
		_poured = clampf(_poured + 0.018, 0.0, 1.3)
		_apply_food_tint()
		_update_simple_hint()


func _on_drag_released(_info: Dictionary) -> void:
	if _finished:
		return
	if _mode == "marinade":
		_massaging = false
		return
	_pouring = false
	if is_instance_valid(_bottle):
		# 병 똑바로 복귀.
		var tw := _bottle.create_tween()
		tw.tween_property(_bottle, "rotation", 0.0, 0.2)
	# 충분히 부었으면 완료. (ADR-007: default는 가벼운 tilt면 적정 — 관대한 임계)
	if _poured >= 0.45:
		_finalize_simple()


## Seasoning tint — broth/food surface만 붉어지게. vessel/tool/bg는 절대 건드리지 않는다.
## (layer-bug fix 2026-06-08) 이전엔 _food_hero(dish-with-bowl 단일 이미지) 전체에 modulate를
## 걸어 bowl까지 빨갛게 됐다. 이제 tint 대상은 content-only sprite 또는 SeasoningOverlay뿐이며,
## vessel을 포함한 _food_hero에는 절대 modulate하지 않는다.
func _apply_food_tint() -> void:
	# 부은 양 [0,1]. perfect 구간에서 broth가 식욕 도는 warm red, 과다면 darker red.
	var amt: float = clampf(_poured, 0.0, 1.3)
	if is_instance_valid(_food_content):
		# FoodContentSprite (그릇 없는 내용물) — 여기만 modulate. vessel(_food_hero) 보존.
		var over: float = clampf(amt - 1.0, 0.0, 0.3)              # 과다분
		var target: Color = _style["col"].lightened(0.35)
		if over > 0.0:
			target = _style["col"].darkened(over * 0.8)           # 과다 → darker red
		var tint: Color = Color(1, 1, 1).lerp(target, clampf(amt, 0.0, 1.0) * 0.5)
		_food_content.modulate = Color(tint.r, tint.g, tint.b, 1.0)
	elif is_instance_valid(_season_overlay):
		# SeasoningOverlay — bowl 안쪽 soft broth mask 알파만 올림(그릇 rim/배경 보존).
		# 적정까지 깊어지는 warm red, 과다면 darker red. vessel은 원색 그대로.
		var a: float = clampf(amt, 0.0, 1.0) * 0.34               # max ~0.34 (broth semi-transp, 그릇 X)
		var over2: float = clampf(amt - 1.0, 0.0, 0.3)
		var col: Color = _style["col"]
		if over2 > 0.0:
			col = _style["col"].darkened(over2 * 0.9)             # 과다 → broth darker red
			a = minf(a + over2 * 0.55, 0.52)
		_season_overlay.broth_color = Color(col.r, col.g, col.b, a)
	# else: tint 대상 없음 → particle/steam VFX만 (vessel tint 0). 안전 fallback.


func _update_simple_hint() -> void:
	if _poured < 0.45:
		_set_instruction("Keep tilting the %s…" % _style["label"])
	elif _poured <= 1.05:
		_set_instruction("Balanced! Release to finish")
	else:
		_set_instruction("That's plenty — release")


func _finalize_simple() -> void:
	_set_instruction("Seasoned!")
	_safe_feedback(RhythmJudge.GOOD, Vector2(540, 1100))
	# §6.1 default: accuracy_season = 1.0 → 기존 auto-pour 90.0 그대로 (balance 무변경).
	_finish(90.0)


# --- marinade mode (tilt-and-massage 연속) ---
func _start_marinade(params: Dictionary) -> void:
	_build_header("Marinade", "Work the sauce into the meat")
	_build_instruction_band("Massage on every beat", "⟳")
	var taps: int = int(params.get("marinade_taps", MARINADE_TAPS))
	var bpm: float = float(params.get("marinade_bpm", MARINADE_BPM))
	var spacing := 60000.0 / maxf(bpm, 1.0)
	_start_ms = _now_ms() + LEAD_IN_MS
	for i in range(taps):
		_taps.append({"target_ms": _start_ms + float(i) * spacing, "judged": false, "score": 0.0})

	# L2 — marinade base vessel (mixing_bowl). action zone 중앙 (vessel clamp).
	var food_id: StringName = StringName(String(params.get("food_id", "")))
	var bowl_rect: Rect2 = Composition.rect_in_zone(
		Composition.ZONE_ACTION, Composition.CLAMP_VESSEL, Vector2(0.5, 0.5))
	var bowl_path: String = ArtRegistry.get_vessel("mixing_bowl")
	if bowl_path != "":
		var bowl_tex := TextureRect.new()
		bowl_tex.name = "VesselSprite"   # marinade bowl — NEVER modulated (tint 금지).
		bowl_tex.texture = load(bowl_path)
		Composition.fit_texture_rect(bowl_tex, bowl_rect)
		bowl_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bowl_tex.z_index = L2_BASE
		add_child(bowl_tex)
	else:
		var bowl := Panel.new()
		bowl.position = bowl_rect.position
		bowl.size = bowl_rect.size
		var bsb := StyleBoxFlat.new()
		bsb.bg_color = Color(0.30, 0.20, 0.12)
		bsb.set_corner_radius_all(int(bowl_rect.size.y * 0.5))
		bowl.add_theme_stylebox_override("panel", bsb)
		bowl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bowl.z_index = L2_BASE
		add_child(bowl)

	# L3 — hero ingredient (양념 받을 고기) — bowl 안쪽에만.
	var ing_path: String = ArtRegistry.get_ingredient("beef", "marinated")
	if ing_path == "":
		ing_path = ArtRegistry.get_ingredient("beef", "raw")
	if ing_path != "":
		var meat_rect: Rect2 = Composition.rect_inside(bowl_rect, 0.62, -10.0)
		# FoodContentSprite — 고기 내용물(그릇 없음). marinade tint는 여기만 (bowl 보존).
		_food_hero = TextureRect.new()
		_food_hero.name = "FoodContentSprite"
		_food_hero.texture = load(ing_path)
		Composition.fit_texture_rect(_food_hero, meat_rect)
		_food_hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_food_hero.z_index = L3_INGREDIENT
		add_child(_food_hero)
		_food_content = _food_hero   # marinade에서 _food_hero == content (vessel 미포함).

	_attach_dish_shadow(Vector2(540, bowl_rect.position.y + bowl_rect.size.y * 0.78), 480.0)
	_hint = null   # marinade hint도 instruction band 사용 (일관 위치).


## tilt-massage 동작 = drag로 보울 위를 문지름. 비트 근처에서 문지르면 그 tap을 판정.
func _massage_at(pos: Vector2) -> void:
	if _finished:
		return
	# massage 유효 영역 = action zone (vessel 주변).
	if pos.y < 400.0 or pos.y > 1300.0:
		return
	var now := _now_ms()
	# 가장 가까운 미판정 tap을 마사지로 판정.
	var best: int = -1
	var best_d: float = 1e9
	for i in range(_taps.size()):
		if _taps[i]["judged"]:
			continue
		var d: float = absf(now - float(_taps[i]["target_ms"]))
		if d < best_d:
			best_d = d
			best = i
	if best < 0 or best == _last_massage_idx:
		return
	# 마사지 한 번 = 그 tap 후보의 timing 판정 (단, 너무 이르면 무시 — 비트 -good 이전).
	var good: float = float(_level_get("good_ms", 200.0))
	if now < float(_taps[best]["target_ms"]) - good * 1.5:
		return
	_last_massage_idx = best
	var perfect: float = float(_level_get("perfect_ms", 90.0))
	var j := RhythmJudge.judge(best_d, perfect, good)
	var score: float = 100.0 if j == RhythmJudge.PERFECT else (60.0 if j == RhythmJudge.GOOD else 0.0)
	_taps[best]["judged"] = true
	_taps[best]["score"] = score
	_safe_feedback(j, pos)
	_emit_particles(pos, 3)
	# 양념 코팅 진해짐.
	if is_instance_valid(_food_hero):
		var done: int = _judged_count()
		var amt: float = float(done) / float(maxi(1, _taps.size()))
		_food_hero.modulate = Color(1, 1, 1).lerp(_style["col"].lightened(0.25), amt * 0.6)


func _process(_dt: float) -> void:
	if _mode != "marinade" or _finished:
		return
	var now := _now_ms()
	var good: float = float(_level_get("good_ms", 200.0))
	for t in _taps:
		if not t["judged"] and now - float(t["target_ms"]) > good:
			t["judged"] = true
			t["score"] = 0.0
			_safe_feedback(RhythmJudge.MISS, Vector2(540, 1100))
	if _all_judged():
		# §6.1 marinade: tap 평균 (기존 계산 무변경).
		var total: float = 0.0
		for t in _taps:
			total += float(t["score"])
		if is_instance_valid(_hint):
			_hint.text = "Marinated!"
		_finish(total / float(maxi(1, _taps.size())))


func _all_judged() -> bool:
	for t in _taps:
		if not t["judged"]:
			return false
	return _taps.size() > 0


func _judged_count() -> int:
	var c: int = 0
	for t in _taps:
		if t["judged"]:
			c += 1
	return c


# --- particles (입자 낙하) ---

## 양념 입자 낙하 — 양념 style에 따라 가루(점)/줄기(긴 사각)/drizzle.
func _emit_particles(at: Vector2, n: int) -> void:
	if not is_instance_valid(_particles_holder):
		return
	var style: String = String(_style["style"])
	for i in range(n):
		var p := ColorRect.new()
		p.color = _style["col"]
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		match style:
			"stream":
				p.size = Vector2(8, 34)
			"drizzle":
				p.size = Vector2(14, 14)
				p.color = _style["col"].lightened(0.2)
			"paste":  # gochujang dollop — 큰 paste 덩이 (가루 아님)
				p.size = Vector2(26, 26)
				p.color = _style["col"]
			_:  # powder
				p.size = Vector2(10, 10)
		var sx: float = at.x + randf_range(-60.0, 60.0)
		p.position = Vector2(sx, at.y)
		_particles_holder.add_child(p)
		var fall_y: float = at.y + randf_range(160.0, 280.0)
		var tw := p.create_tween()
		tw.parallel().tween_property(p, "position:y", fall_y, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.parallel().tween_property(p, "modulate:a", 0.0, 0.45).set_delay(0.15)
		tw.tween_callback(p.queue_free)


func _now_ms() -> float:
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("now_ms"):
		return float(bc.now_ms())
	return float(Time.get_ticks_msec())
