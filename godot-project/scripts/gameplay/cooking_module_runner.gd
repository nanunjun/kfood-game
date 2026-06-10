## CookingModuleRunner — ADR-011 Cooking Framework 2.0 sequence runner.
##
## Replaces the hard-coded 7-phase rhythm flow with a data-driven module pipeline:
##   1. load_sequence(food_id) reads dish_modules.csv via MenuDB.module_sequence
##   2. _run_next_module() instantiates the matching .tscn from scenes/cooking/, calls
##      module.start(params), then waits on module_completed(score)
##   3. _on_module_completed buckets each per-module score into 4 score-factors
##      (prep / cook / timing / season / plating) per the ADR-011 mapping:
##        slice/arrange/roll -> prep
##        stir/flip          -> cook
##        timing             -> timing (own factor — fed back into "cook" 4-factor)
##        season             -> season
##        plate              -> plating (separate vessel bonus)
##   4. _finish() blends the buckets, computes stars + compat + rewards + records +
##      friendship + recipe XP, then hands a payload to result_screen_v2.tscn — fully
##      preserving the rhythm_proto.gd Result Screen 2.0 contract.
##
## Adding a new dish = 1 row in data/dish_modules.csv + 1 row in data/menus.csv + an
## (optional) food art PNG. Zero code changes required.
extends Node2D

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")
const MarketBG := preload("res://scripts/ui/market_bg.gd")
const CookingBackgroundScript := preload("res://scripts/ui/cooking_background.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")
const PlateModuleScript := preload("res://scripts/cooking_modules/plate_module.gd")
# Premium V1
const NowCookingBannerScript := preload("res://scripts/ui/premium/now_cooking_banner.gd")
const DropShadowScript := preload("res://scripts/ui/premium/drop_shadow_panel.gd")

## Set by menu_select / guest_select before scene change.
static var pending_menu_id: String = "t1_002"
static var pending_guest_id: String = ""

# Module id -> scene resource. New modules = add a row here + a .tscn.
const MODULE_SCENES := {
	"slice":   "res://scenes/cooking/slice_module.tscn",
	"arrange": "res://scenes/cooking/arrange_module.tscn",
	"stir":    "res://scenes/cooking/stir_module.tscn",
	"flip":    "res://scenes/cooking/flip_module.tscn",
	"timing":  "res://scenes/cooking/timing_module.tscn",
	"season":  "res://scenes/cooking/season_module.tscn",
	"roll":    "res://scenes/cooking/roll_module.tscn",
	"plate":   "res://scenes/cooking/plate_module.tscn",
}

# ADR-011 score-mapping table (lock):
#   slice/arrange/roll -> prep
#   stir/flip          -> cook
#   timing             -> timing (folded back into "cook" 4-factor weight)
#   season             -> season
#   plate              -> plating (vessel bonus — separate)
const MODULE_TO_FACTOR := {
	"slice":   "prep",
	"arrange": "prep",
	"roll":    "prep",
	"stir":    "cook",
	"flip":    "cook",
	"timing":  "timing",
	"season":  "season",
	"plate":   "plating",
}

# --- loaded per-round data ---
var _menu: Dictionary = {}
var _guest: Dictionary = {}
var _level: Dictionary = {}
var _is_evaluator: bool = false
var _sequence: Array = []
var _step_no: int = 0
var _step_total: int = 0

# per-factor accumulator (each entry 0~1 to mirror rhythm_proto._cat_acc shape)
var _factor_acc: Dictionary = {"prep": [], "cook": [], "timing": [], "season": [], "plating": []}

# Plate module exposes its chosen dish via getters (used by dish_bonus + reveal).
var _dish_choice: String = ""
var _dish_tier: String = "neutral"

# --- runtime nodes ---
var _layer: CanvasLayer
var _info: Label
var _howto: Label
var _now_cooking: Control = null
var _current_module: Node = null
var _module_host: Control = null


func _ready() -> void:
	randomize()
	_load_round()
	_build_chrome()
	get_node("/root/BeatClock").start()
	# consume one serving (economy) — same as rhythm_proto.gd
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("consume_stock"):
		sm.consume_stock(String(_menu.get("id", "")))
	_start_request()


# --- round bootstrap ---
func _load_round() -> void:
	_menu = MenuDB.get_menu(pending_menu_id)
	if _menu.is_empty():
		_menu = MenuDB.get_menu("t1_002")
	var lv: int = int(_menu.get("unlock_level", 1))
	_level = MenuDB.get_level(lv)
	# evaluator on certain levels replaces the guest
	var eval_id: String = String(_level.get("evaluator", ""))
	if eval_id != "":
		_guest = MenuDB.get_guest(eval_id)
		_is_evaluator = true
	elif pending_guest_id != "":
		_guest = MenuDB.get_guest(pending_guest_id)
		pending_guest_id = ""  # consume selection
	else:
		_guest = MenuDB.get_guest(String(_menu.get("guest_id", "junho")))
	_sequence = load_sequence(String(_menu.get("id", "")))
	_step_total = _sequence.size()
	_step_no = 0
	_factor_acc = {"prep": [], "cook": [], "timing": [], "season": [], "plating": []}


## Loads + validates the module sequence for a food. Pure helper — used by smoke tests.
func load_sequence(food_id: String) -> Array:
	return MenuDB.module_sequence(food_id)


func _build_chrome() -> void:
	_layer = CanvasLayer.new()
	add_child(_layer)
	# World-integration (2026-06-08): 환경 art가 화면 전체를 채우도록 fill_screen=true.
	# 기존(width-cover 하단정렬)은 상단 절반이 beige wall-연장 void였다 → action이 빈 공간에 떴다.
	# 이제 한식 주방 world가 화면을 가득 채우고 그 위에 cooking action이 얹힌다 (beige void 박멸).
	# level market(home/noryangjin/market/gwangjang) → 환경 art는 공유 helper로 매핑.
	var bg = KitchenBackgroundScript.new()
	bg.fill_screen = true
	bg.dish_anchor_y = 900.0
	bg.env_key = _env_key_for_market(String(_level.get("market", "home")))
	_layer.add_child(bg)
	_info = Label.new()
	_info.position = Vector2(40, 60)
	_info.size = Vector2(1000, 260)
	_info.add_theme_font_size_override("font_size", 40)
	_info.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_layer.add_child(_info)
	_howto = Label.new()
	_howto.position = Vector2(40, 132)
	_howto.size = Vector2(1000, 60)
	_howto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_howto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_howto.add_theme_font_size_override("font_size", 32)
	_howto.add_theme_color_override("font_color", Color(0.45, 0.32, 0.18))
	_layer.add_child(_howto)
	_level_banner()
	_now_cooking = _build_now_cooking()
	_layer.add_child(_now_cooking)
	# Module host: a top-level Control inside the canvas layer that we re-fill per step.
	_module_host = Control.new()
	_module_host.set_anchors_preset(Control.PRESET_FULL_RECT)
	_module_host.mouse_filter = Control.MOUSE_FILTER_PASS
	_layer.add_child(_module_host)
	# Premium: small guest mini-avatar at bottom-left of the cooking surface (peeking watcher)
	_build_guest_mini()
	# Player-Chef host (2026-06-08): "요리하는 나" 셰프(cook)를 화면 우하단에 작게 — 손님 mini가
	# 좌하단(먹는 쪽)에 있으니 역할 분리로 우하단(요리하는 쪽)에 배치. world BG 위 layer.
	# mouse_filter IGNORE라 활성 모듈 입력과 충돌하지 않는다. visual only.
	_build_chef_cook_host()


## level market → KitchenBackground env art key (공유 매핑 사용 — home/noryangjin/market/gwangjang 지원).
func _env_key_for_market(market: String) -> String:
	return KitchenBackgroundScript.env_key_for_market(market)


# Bottom-left guest mini-avatar (CH-01~05 placeholder = colored circle + initial).
# Shows "who's waiting" without stealing space from the active module.
const _GUEST_TINT_CR := {
	"junho": Color(0.86, 0.45, 0.40), "mina": Color(0.95, 0.78, 0.45),
	"riley": Color(0.55, 0.72, 0.85), "mrs_lee": Color(0.70, 0.80, 0.62),
	"seoyeon": Color(0.80, 0.62, 0.85),
	"mother_01": Color(0.85, 0.60, 0.70), "father_01": Color(0.55, 0.45, 0.40),
}

func _build_guest_mini() -> void:
	if _guest.is_empty():
		return
	var gid := String(_guest.get("id", ""))
	var holder := Control.new()
	holder.position = Vector2(24, 1780)
	holder.size = Vector2(180, 120)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(holder)
	# avatar circle. Phase B+C: real sprite (neutral) if available.
	var av := Panel.new()
	av.position = Vector2(0, 0)
	av.size = Vector2(100, 100)
	var avsb := StyleBoxFlat.new()
	avsb.bg_color = _GUEST_TINT_CR.get(gid, Color(0.82, 0.72, 0.60))
	avsb.set_corner_radius_all(50)
	avsb.set_border_width_all(4)
	avsb.border_color = Color.WHITE
	avsb.shadow_size = 8
	avsb.shadow_color = Color(0, 0, 0, 0.40)
	avsb.shadow_offset = Vector2(0, 4)
	av.add_theme_stylebox_override("panel", avsb)
	holder.add_child(av)
	var avatar_path := "res://art/sprites/character/%s_neutral.png" % gid
	if ResourceLoader.exists(avatar_path):
		var avatar_tex := TextureRect.new()
		avatar_tex.texture = load(avatar_path)
		avatar_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
		avatar_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		avatar_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		avatar_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		av.add_child(avatar_tex)
	else:
		var initial := Label.new()
		initial.text = String(_guest.get("name", "?")).substr(0, 1)
		initial.set_anchors_preset(Control.PRESET_FULL_RECT)
		initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		initial.add_theme_font_size_override("font_size", 56)
		initial.add_theme_color_override("font_color", Color.WHITE)
		initial.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.32))
		initial.add_theme_constant_override("outline_size", 3)
		av.add_child(initial)
	# "Waiting" speech bubble
	var bubble := Panel.new()
	bubble.position = Vector2(108, 12)
	bubble.size = Vector2(120, 44)
	var bsb := StyleBoxFlat.new()
	bsb.bg_color = Color(1.0, 0.99, 0.93)
	bsb.set_corner_radius_all(20)
	bsb.set_border_width_all(2)
	bsb.border_color = Color(0.70, 0.50, 0.20)
	bsb.shadow_size = 4
	bsb.shadow_color = Color(0, 0, 0, 0.20)
	bubble.add_theme_stylebox_override("panel", bsb)
	holder.add_child(bubble)
	var bl := Label.new()
	bl.text = "Hungry!"
	bl.set_anchors_preset(Control.PRESET_FULL_RECT)
	bl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bl.add_theme_font_size_override("font_size", 20)
	bl.add_theme_color_override("font_color", Color(0.40, 0.20, 0.08))
	bubble.add_child(bl)
	# Idle breath
	var IdleHelper := preload("res://scripts/ui/premium/character_idle_animator.gd")
	IdleHelper.attach(av, 1.04, 2.0)


# Player-Chef cook host: 화면 우하단에 선택한 셰프(cook)를 작게 표시 (요리하는 쪽).
# SaveManager 성별을 읽어 ArtRegistry.get_protagonist로 해석. 미선택/미존재 시 silent skip.
func _build_chef_cook_host() -> void:
	var path := _chef_host_path("cook")
	if path == "":
		return
	var holder := Control.new()
	holder.position = Vector2(896, 1772)
	holder.size = Vector2(160, 140)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(holder)
	var frame := Panel.new()
	frame.position = Vector2(0, 0)
	frame.size = Vector2(120, 120)
	var fsb := StyleBoxFlat.new()
	fsb.bg_color = Color(0.99, 0.96, 0.89)
	fsb.set_corner_radius_all(60)
	fsb.set_border_width_all(4)
	fsb.border_color = Color(0.93, 0.72, 0.30)
	fsb.shadow_size = 8
	fsb.shadow_color = Color(0, 0, 0, 0.40)
	fsb.shadow_offset = Vector2(0, 4)
	frame.add_theme_stylebox_override("panel", fsb)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.clip_contents = true  # 원형 프레임 안으로 chef bust crop
	holder.add_child(frame)
	var host := TextureRect.new()
	host.texture = load(path)
	host.set_anchors_preset(Control.PRESET_FULL_RECT)
	host.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	host.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(host)
	# 캡션 — Player-Name Personalization (2026-06-08): 입력명("Chef" 고정 라벨 제거).
	var cap := Label.new()
	cap.text = _chef_display_name()
	cap.position = Vector2(-32, 122)
	cap.size = Vector2(184, 28)
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cap.add_theme_font_size_override("font_size", 20)
	cap.add_theme_color_override("font_color", Color(0.99, 0.92, 0.78))
	cap.add_theme_color_override("font_outline_color", Color(0.20, 0.10, 0.04))
	cap.add_theme_constant_override("outline_size", 3)
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(cap)
	var IdleHelper := preload("res://scripts/ui/premium/character_idle_animator.gd")
	IdleHelper.attach(frame, 1.04, 2.2)


## 플레이어 입력 셰프 이름(표시용). 미입력/legacy fallback은 "My Chef". guest 이름과 분리.
func _chef_display_name() -> String:
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("player_name_display"):
		return sm.player_name_display()
	return "Chef"


## 선택한 셰프 아바타 경로(emotion)를 SaveManager 성별로 해석. 미선택/미존재 시 "".
func _chef_host_path(emotion: String) -> String:
	var sm := get_node_or_null("/root/SaveManager")
	if sm == null or not sm.has_method("player_chef_gender"):
		return ""
	var gender: String = sm.player_chef_gender()
	if gender != "f" and gender != "m":
		return ""
	var path := ArtRegistry.get_protagonist(gender, emotion)
	return path if (path != "" and ResourceLoader.exists(path)) else ""


func _level_banner() -> void:
	var txt := "Lv %d" % int(_level.get("level", 1))
	if _is_evaluator:
		txt += " · %s" % _guest.get("name", "Evaluator")
	var pill := Panel.new()
	pill.position = Vector2(24, 8)
	pill.size = Vector2(clampf(150.0 + float(txt.length()) * 16.0, 150.0, 520.0), 56.0)
	# Premium drop-shadow + gold border
	DropShadowScript.apply_to(pill, Color(0.30, 0.20, 0.12, 0.95), 28, 8, Color(0.95, 0.70, 0.18), 3)
	_layer.add_child(pill)
	var b := Label.new()
	b.text = txt
	b.set_anchors_preset(Control.PRESET_FULL_RECT)
	b.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	b.add_theme_font_size_override("font_size", 28)
	b.add_theme_color_override("font_color", Color(0.99, 0.92, 0.78))
	b.add_theme_color_override("font_outline_color", Color(0.10, 0.05, 0.02))
	b.add_theme_constant_override("outline_size", 2)
	pill.add_child(b)


func _build_now_cooking() -> Control:
	# Premium NowCookingBanner (CP-40) — wraps the old flat pill with a card,
	# dish thumb, dish name (EN/KR), and step progress dots (CP-41).
	var banner = NowCookingBannerScript.new()
	banner.position = Vector2(40, 196)
	banner.size = Vector2(1000, 96)
	banner.custom_minimum_size = Vector2(1000, 96)
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Defer setup so the banner has _ready'd
	banner.call_deferred("setup",
		String(_menu.get("name_en", "Cooking")),
		String(_menu.get("name_kr", "")),
		String(_menu.get("food_img", "")) if bool(_menu.get("ready", false)) else "",
		maxi(1, _step_no),
		maxi(1, _step_total))
	return banner


# Called whenever runner advances a step — premium banner step dots update.
func _update_banner_step() -> void:
	if _now_cooking != null and _now_cooking.has_method("update_step"):
		_now_cooking.update_step(maxi(1, _step_no))


# --- 0. guest request ---
func _start_request() -> void:
	var face := Panel.new()
	face.position = Vector2(440, 360)
	face.size = Vector2(200, 200)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.86, 0.78, 0.95) if _is_evaluator else Color(0.95, 0.83, 0.62)
	sb.set_corner_radius_all(100)
	face.add_theme_stylebox_override("panel", sb)
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_module_host.add_child(face)
	# Player-Chef host (think): 주문을 받고 "어떻게 만들까" 고민하는 셰프 — 가이드/튜토리얼 톤.
	# 요청 화면 좌측에 배치. _clear_module_host()로 모듈 시작 시 함께 정리된다(_module_host 자식).
	_build_chef_request_host()
	_info.position = Vector2(40, 620)
	_info.text = "%s: \"%s\"\n\nLet's make %s (%s)." % [
		_guest.get("name", "Guest"), _guest.get("line_enter", "Surprise me!"),
		_menu.get("name_en", "?"), _menu.get("intro_en", "")]
	await get_tree().create_timer(1.4).timeout
	_clear_module_host()
	_info.position = Vector2(40, 60)
	_info.text = ""
	_run_next_module()


# Player-Chef request host: 요청 화면에서 "think" 셰프를 좌측에 — 주문을 받고 레시피를
# 고민하는 톤(가이드/튜토리얼). _module_host 자식이라 모듈 시작 시 함께 정리된다.
func _build_chef_request_host() -> void:
	var path := _chef_host_path("think")
	if path == "":
		return
	var frame := Panel.new()
	frame.position = Vector2(70, 360)
	frame.size = Vector2(220, 220)
	var fsb := StyleBoxFlat.new()
	fsb.bg_color = Color(0.99, 0.96, 0.89)
	fsb.set_corner_radius_all(110)
	fsb.set_border_width_all(5)
	fsb.border_color = Color(0.93, 0.72, 0.30)
	fsb.shadow_size = 10
	fsb.shadow_color = Color(0, 0, 0, 0.32)
	fsb.shadow_offset = Vector2(0, 5)
	frame.add_theme_stylebox_override("panel", fsb)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.clip_contents = true  # 원형 프레임 안으로 chef bust crop
	_module_host.add_child(frame)
	var host := TextureRect.new()
	host.texture = load(path)
	host.set_anchors_preset(Control.PRESET_FULL_RECT)
	host.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	host.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(host)
	var cap := Label.new()
	cap.text = "Hmm, how to cook this..."
	cap.position = Vector2(-30, 224)
	cap.size = Vector2(280, 30)
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cap.add_theme_font_size_override("font_size", 22)
	cap.add_theme_color_override("font_color", Color(0.45, 0.30, 0.16))
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_module_host.add_child(cap)


# --- module dispatch ---
func _run_next_module() -> void:
	if _sequence.is_empty():
		_finish()
		return
	_step_no += 1
	_update_banner_step()
	var mod_id: String = String(_sequence.pop_front())
	var scene_path: String = String(MODULE_SCENES.get(mod_id, ""))
	if scene_path == "" or not ResourceLoader.exists(scene_path):
		push_warning("[runner] unknown module '%s' — skipping" % mod_id)
		_run_next_module()
		return
	var packed: PackedScene = load(scene_path) as PackedScene
	if packed == null:
		push_warning("[runner] failed to load %s — skipping" % scene_path)
		_run_next_module()
		return
	_current_module = packed.instantiate()
	_module_host.add_child(_current_module)
	# Wire signal once with the module id baked in.
	if _current_module.has_signal("module_completed"):
		_current_module.module_completed.connect(_on_module_completed.bind(mod_id))
	# Compose params for this module instance.
	var params: Dictionary = _build_module_params(mod_id)
	if _current_module.has_method("start"):
		_current_module.start(params)


func _build_module_params(mod_id: String) -> Dictionary:
	var params: Dictionary = {
		"food_id": String(_menu.get("id", "")),
		"guest_id": String(_guest.get("id", "")),
		"level": _level,
		"step_no": _step_no,
		"step_total": _step_total,
		"menu": _menu,
		"module_id": mod_id,
		# runner가 이미 KitchenBackground를 깔았으므로 module 자체 bg 생략 (chrome 가림 방지).
		"skip_bg": true,
	}
	# Per-module tweaks (CSV-driven would land in a v2 dish_modules.csv schema column).
	match mod_id:
		"season":
			# 불고기 — marinade rhythm; everyone else = simple 1-tap.
			if String(_menu.get("id", "")) == "t2_014":
				params["mode"] = "marinade"
				params["marinade_taps"] = 3
				params["marinade_bpm"] = 60.0
			else:
				params["mode"] = "simple"
			# P0 #3 (2026-06-07): seasoning param dish-explicit -- gochujang(paste dollop) vs
			# gochugaru(powder). bibimbap=dollop, sundubu=powder, tteokbokki=gochujang.
			match String(_menu.get("id", "")):
				"t2_008":   params["seasoning"] = "gochujang"
				"t1_003":   params["seasoning"] = "gochujang"
				"t2_013":   params["seasoning"] = "gochugaru"
				_:          pass
		"timing":
			# 갈비구이 (t2_012) is a tight grill window per the matrix notes.
			if String(_menu.get("id", "")) == "t2_012":
				params["perfect_width"] = 0.10
			else:
				params["perfect_width"] = 0.18
		"slice":
			# Higher BPM for advanced dishes (galbi / japchae) — comes from level data.
			params["bpm"] = clampf(80.0 + float(_level.get("level", 1)) * 6.0, 80.0, 140.0)
			params["tap_count"] = 4
		"arrange":
			if String(_menu.get("id", "")) == "t1_004":
				params["slot_count"] = 5  # 김밥 5색 재료
			elif String(_menu.get("id", "")) in ["t2_008", "t2_010"]:
				params["slot_count"] = 6  # 비빔밥 / 잡채 6색
			else:
				params["slot_count"] = 4
		"stir":
			# ADR-012: continuous circular swipe. variant = 음식별 stir 동작
			# (wok=빠른 작은 원 / bibim=느린 큰 원 / toss=좌우 swipe). 회전 목표 turns.
			# (legacy tap_count/bpm는 모듈이 무시 — 무변경 안전.)
			match String(_menu.get("id", "")):
				"t1_005":            params["variant"] = "wok"     # 김치볶음밥
				"t2_008":            params["variant"] = "bibim"   # 비빔밥
				"t2_010":            params["variant"] = "toss"    # 잡채 당면
				_:                   params["variant"] = "default"
			params["target_turns"] = 3.0
		"flip":
			# ADR-012: directional flick. variant = 음식별 flip 방향
			# (pajeon=swipe-up / corndog=회전 / galbi=좌우).
			match String(_menu.get("id", "")):
				"t1_006":            params["variant"] = "pajeon"  # 해물파전 swipe-up
				"t1_007":            params["variant"] = "corndog" # 콘도그 회전
				"t2_012":            params["variant"] = "galbi"   # 갈비 좌우
				_:                   params["variant"] = "default"
	return params


func _on_module_completed(score_pct: float, mod_id: String) -> void:
	# Capture plate choice for downstream dish bonus + reveal.
	if mod_id == "plate" and _current_module is PlateModuleScript:
		var pm: Node = _current_module
		if pm.has_method("get_chosen_dish"):
			_dish_choice = String(pm.get_chosen_dish())
		if pm.has_method("get_chosen_tier"):
			_dish_tier = String(pm.get_chosen_tier())
	# Bucket into the 4-factor accumulator (normalized 0~1 to keep parity with the old
	# _cat_acc structure used by score_breakdown_rows downstream).
	var factor: String = String(MODULE_TO_FACTOR.get(mod_id, "cook"))
	if not _factor_acc.has(factor):
		_factor_acc[factor] = []
	(_factor_acc[factor] as Array).append(clampf(score_pct / 100.0, 0.0, 1.0))
	# Clean up this module and advance.
	if is_instance_valid(_current_module):
		_current_module.queue_free()
	_current_module = null
	# small inter-step breath for juice settle
	await get_tree().create_timer(0.25).timeout
	_run_next_module()


func _clear_module_host() -> void:
	if _module_host == null:
		return
	for c in _module_host.get_children():
		c.queue_free()


# --- final scoring + handoff to ResultScreenV2 ---
func _finish() -> void:
	get_node("/root/BeatClock").stop()
	# Weighted blend across the level's prep / cook / season weights. Timing folds into
	# cook (per the ADR-011 mapping note: stir/flip/timing all live in the "cook" 4-factor
	# bucket for the breakdown). Plating stays separate via dish_bonus_scaled.
	var prep_avg: float = _avg(_factor_acc.get("prep", []))
	var timing_avg: float = _avg(_factor_acc.get("timing", []))
	var cook_taps_avg: float = _avg(_factor_acc.get("cook", []))
	# Cook 4-factor = average of timing + tap-based cook (stir/flip). If only one is
	# present, use it alone — keeps small sequences (e.g. 4-step ramyeon) honest.
	var cook_components: Array = []
	if (_factor_acc.get("cook", []) as Array).size() > 0:
		cook_components.append(cook_taps_avg)
	if (_factor_acc.get("timing", []) as Array).size() > 0:
		cook_components.append(timing_avg)
	var cook_avg: float = _avg(cook_components)
	var season_avg: float = _avg(_factor_acc.get("season", []))
	var plating_acc: float = _avg(_factor_acc.get("plating", []))
	# If the dish has no plate module (shouldn't happen — we auto-append) we fall back to
	# tier-derived plating, matching the legacy default.
	if plating_acc <= 0.0 and _dish_tier == "":
		plating_acc = 0.5

	var weights := {
		"prep":   float(_level.get("w_prep", 0.3)),
		"cook":   float(_level.get("w_cook", 0.2)),
		"season": float(_level.get("w_season", 0.5)),
	}
	var num: float = 0.0
	var den: float = 0.0
	if (_factor_acc.get("prep", []) as Array).size() > 0:
		num += weights["prep"] * prep_avg; den += weights["prep"]
	if cook_components.size() > 0:
		num += weights["cook"] * cook_avg; den += weights["cook"]
	if (_factor_acc.get("season", []) as Array).size() > 0:
		num += weights["season"] * season_avg; den += weights["season"]
	var base: float = num / den if den > 0.0 else 0.0
	# Plate vessel bonus — uses MenuDB.dish_bonus_scaled with the level's w_dish weight,
	# exactly as rhythm_proto.gd did. This preserves the +12% / +5% / -8% match scaling.
	var dish_bonus: float = MenuDB.dish_bonus_scaled(_menu, _dish_choice, float(_level.get("w_dish", 0.12)))
	var s: float = clampf(base + dish_bonus, 0.0, 1.0)
	var stars: int = _stars(s)
	var passed: bool = s >= float(_level.get("theta", 0.6))

	# --- compat + mood (Guest 2.0) ---
	var compat: int = 50
	var mood: String = "easy"
	var compat_sys := get_node_or_null("/root/CompatCalc")
	var mood_sys := get_node_or_null("/root/MoodSystem")
	if not _is_evaluator and compat_sys != null and mood_sys != null:
		mood = mood_sys.today(String(_guest.get("id", "")))
		compat = compat_sys.score(_menu, _guest, mood)

	# --- records + friendship + reward + recipe XP ---
	var sm := get_node_or_null("/root/SaveManager")
	var food_id: String = String(_menu.get("id", ""))
	var guest_id: String = String(_guest.get("id", ""))
	var score_int: int = int(round(s * 10000.0))
	var record_broken: bool = false
	var record_prev_score: int = 0
	if sm and sm.has_method("record_of"):
		record_prev_score = sm.record_of(food_id, guest_id)
	if sm and sm.has_method("check_record"):
		record_broken = sm.check_record(food_id, guest_id, score_int)

	var friendship_delta: int = 0
	var friendship_after: int = 0
	var milestone: int = 0
	if not _is_evaluator and sm != null:
		if s >= 0.55:
			friendship_delta = stars + (1 if compat >= 80 else 0)
			if sm.has_method("add_friendship"):
				friendship_after = sm.add_friendship(guest_id, friendship_delta)
			else:
				sm.add_intimacy(guest_id, float(friendship_delta) * 0.5)
		else:
			friendship_delta = 0
			sm.add_intimacy(guest_id, -0.5)
			if sm.has_method("friendship_of"):
				friendship_after = sm.friendship_of(guest_id)
		if sm.has_method("friendship_milestone_pending"):
			milestone = sm.friendship_milestone_pending(guest_id)

	var reward: int = 0
	if passed:
		var base_reward: int = int(round(float(_level.get("reward", 0)) * (1.3 if s >= float(_level.get("star4", 0.85)) else 1.0)))
		var reward_calc := get_node_or_null("/root/RewardCalc")
		if not _is_evaluator and reward_calc != null:
			if reward_calc.has_method("final_with_bonuses"):
				reward = reward_calc.final_with_bonuses(base_reward, compat, _guest, record_broken, milestone)
			else:
				reward = reward_calc.final(base_reward, compat, _guest)
		else:
			reward = base_reward
	if sm:
		if passed and reward > 0:
			sm.add_money(reward)
		sm.record_round(food_id, stars, passed, String(_level.get("market", "home")))

	var xp_gained: int = 0
	var xp_total_after: int = 0
	var recipe_xp := get_node_or_null("/root/RecipeXP")
	if not _is_evaluator and sm != null and recipe_xp != null:
		xp_gained = recipe_xp.xp_gain(stars, compat, record_broken)
		xp_total_after = sm.add_recipe_xp(food_id, xp_gained)

	var reaction_text: String = ""
	var reaction_db := get_node_or_null("/root/ReactionDB")
	if reaction_db != null:
		reaction_text = reaction_db.generate_text(_guest, _menu, stars, compat, mood)

	var emotion_level: String = "okay"
	var breakdown_rows: Array = []
	var reward_calc := get_node_or_null("/root/RewardCalc")
	if reward_calc != null:
		emotion_level = reward_calc.emotion_level(stars, compat)
		# When plate module wasn't run (legacy fallback), derive plating_acc from tier.
		var tier_str: String = _dish_tier
		if tier_str == "" or tier_str == "neutral":
			tier_str = MenuDB.dish_tier(_menu, _dish_choice)
		var plating_for_rows: float = plating_acc
		if plating_for_rows <= 0.0:
			match tier_str:
				"best": plating_for_rows = 1.0
				"2nd":  plating_for_rows = 0.7
				"bad":  plating_for_rows = 0.2
				_:      plating_for_rows = 0.5
		breakdown_rows = reward_calc.score_breakdown_rows(prep_avg, cook_avg, season_avg,
			plating_for_rows, compat, mood, _guest)

	var hm := get_node_or_null("/root/HapticManager")
	if hm:
		hm.play(hm.REVEAL)
	print("[runner] %s L%d S=%.2f base=%.2f dish=%.2f pass=%s compat=%d mood=%s emo=%s rec=%s seq=%s" % [
		food_id, int(_level.get("level", 1)), s, base, dish_bonus, passed, compat, mood,
		emotion_level, record_broken, MenuDB.module_sequence(food_id)])

	_launch_result_v2({
		"food": _menu,
		"guest": _guest,
		"mood": mood,
		"compat": compat,
		"stars": stars,
		"score": score_int,
		"score_norm": s,
		"breakdown_rows": breakdown_rows,
		"emotion_level": emotion_level,
		"reaction_text": reaction_text,
		"record_broken": record_broken,
		"record_prev_score": record_prev_score,
		"xp_gained": xp_gained,
		"xp_total_after": xp_total_after,
		"friendship_delta": friendship_delta,
		"friendship_after": friendship_after,
		"milestone_just_hit": milestone,
		"final_coin": reward,
		"passed": passed,
	})


func _launch_result_v2(payload: Dictionary) -> void:
	_clear_module_host()
	if is_instance_valid(_now_cooking):
		_now_cooking.visible = false
	if is_instance_valid(_info):
		_info.visible = false
	if is_instance_valid(_howto):
		_howto.visible = false
	var scene: PackedScene = load("res://scenes/ui/result_screen_v2.tscn") as PackedScene
	if scene == null:
		push_error("[runner] result_screen_v2.tscn not found")
		return
	var rs := scene.instantiate()
	rs.setup(payload)
	var top := CanvasLayer.new()
	top.layer = 10
	add_child(top)
	top.add_child(rs)


# --- pure helpers ---
func _avg(arr: Array) -> float:
	if arr.is_empty():
		return 0.0
	var s: float = 0.0
	for v in arr:
		s += float(v)
	return s / float(arr.size())


func _stars(s: float) -> int:
	if s >= float(_level.get("star5", 0.92)): return 5
	elif s >= float(_level.get("star4", 0.80)): return 4
	elif s >= float(_level.get("star3", 0.68)): return 3
	elif s >= float(_level.get("star2", 0.55)): return 2
	return 1
