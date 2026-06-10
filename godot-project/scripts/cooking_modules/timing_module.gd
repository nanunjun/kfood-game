## TimingModule — ACTION-FIRST heat-dial simmering (ADR-012).
##
## "I controlled the heat" — NOT "I stopped a meter". The player drags a heat dial up/down
## to set the flame; the flame, boil and overflow-risk react live. The goal is to KEEP the
## heat inside the ideal simmer zone for the cook window — not to tap STOP once.
##
## ADR-012 input redesign (2026-06-05): STOP-meter perfect-window tap 폐기 → vertical drag
## heat dial (지속 조절).
##   - input: vertical drag on heat dial → 불꽃 세기 실시간 조절.
##   - visual: 불꽃 intensity + bubble 강도 + overflow 게이지(불 세면 국물 차오름).
##   - 3 states: undercooked (불 약) / ideal simmer (적정 유지) / overflow·burnt (불 셈).
##
## SCORING 무변경 (§6.1 / §3.5): cook window 동안 적정 heat zone 유지 비율(zone-hold ratio)
## 로 4-tier(1.0/0.6/0.2/0.0)를 emerge. 기존 "perfect window 명중"의 동등 매핑 — 출력 score
## 도메인 [0,100] 동일, `module_completed(score)` contract 동일.
##   perfect_at  → ideal heat zone 중심 (다이얼 0~1 위치).
##   perfect_width → ideal heat zone 폭 (갈비 0.10 좁음 등 음식별 12 row 무변경).
## 5-Layer Composition (2026-06-06): base vessel(L2) + food raw→cooked(L3 progressive swap)
## + flame/bubbles/steam/heat-glow(L5). pot/dolsot/noodle_bowl/grill_pan + noodle_raw→
## noodle_cooked / tofu_cubed / beef_raw→beef_cooked. standalone sprite runtime 합성.
extends "res://scripts/cooking_modules/base_module.gd"

const TouchGesture := preload("res://scripts/cooking_modules/touch_gesture.gd")

const DURATION_DEFAULT_MS: float = 3500.0
const PERFECT_AT_DEFAULT: float = 0.85
const PERFECT_WIDTH_DEFAULT: float = 0.18

# P0 #4 — stew dish: broth 안에 재료가 잠겨 끓는다. dish_id → 잠긴 submerged 재료(들).
# 순두부찌개(t2_013): 순두부(tofu) base + 김치(kimchi) 부분 잠김 (dry pile 금지).
const STEW_SUBMERGED := {
	"t2_013": [["kimchi", "chopped"], ["tofu", "cubed"]],
}

# vessel = action zone 중앙 (≤65%W/42%H). food은 이 안에만.
const VESSEL_RECT := Rect2(280, 540, 520, 480)
# heat dial 화면 geometry (세로 슬라이더) — vessel 왼쪽, CONTROL/action 경계까지.
const DIAL_X: float = 130.0
const DIAL_TOP: float = 600.0
const DIAL_H: float = 480.0          # 위(0)=강불 ... 아래(1)=약불? → heat 매핑은 아래 참고
const KNOB_R: float = 52.0

var _start_ms: float = 0.0
var _duration_ms: float = DURATION_DEFAULT_MS
var _perfect_at: float = PERFECT_AT_DEFAULT
var _perfect_w: float = PERFECT_WIDTH_DEFAULT
var _finished_timing: bool = false

# heat ∈ [0,1] (0=약불 ... 1=강불). ideal zone = [perfect_at±perfect_w/2].
var _heat: float = 0.35
var _zone_hold_ms: float = 0.0       # 적정 zone 안에 머문 누적 시간
var _good_hold_ms: float = 0.0       # good band 안에 머문 누적 시간
var _overflow: float = 0.0           # 넘침 risk 게이지 [0,1]

# nodes (gif stager가 _fill / _pct_lbl 호환 이름으로 hook)
var _flame: Polygon2D = null
var _flame_core: Polygon2D = null
var _dial_track: Panel = null
var _dial_zone: ColorRect = null
var _knob: Panel = null
var _pct_lbl: Label = null           # gif stager hooks this name (heat % 표시)
var _fill: ColorRect = null          # gif stager hooks this name (zone-hold progress)
var _overflow_bar: ColorRect = null
var _bubbles: Array = []
var _gesture = null   # TouchGestureRecognizer (preloaded TouchGesture)
var _knob_drag: bool = false
# L3 food raw→cooked cross-fade (heat zone-hold이 쌓일수록 cooked로 변함).
var _food_raw: TextureRect = null
var _food_cooked: TextureRect = null


func _module_start(params: Dictionary) -> void:
	_attach_cooking_bg(700.0)
	_build_header("Heat", "Drag the dial to hold the flame in the GOLD simmer zone.")
	_start_ms = _now_ms()
	_duration_ms = float(params.get("duration_ms", DURATION_DEFAULT_MS))
	_perfect_at = float(params.get("perfect_at", PERFECT_AT_DEFAULT))
	_perfect_w = float(params.get("perfect_width", PERFECT_WIDTH_DEFAULT))

	# L2 — 음식별 base vessel (pot / dolsot / noodle_bowl / grill_pan). action zone 중앙.
	var food_id: StringName = StringName(String(params.get("food_id", "")))
	var vessel_path: String = ArtRegistry.cooking_vessel_for(food_id)
	if vessel_path != "":
		_attach_dish_shadow(Vector2(VESSEL_RECT.position.x + VESSEL_RECT.size.x * 0.5,
			VESSEL_RECT.position.y + VESSEL_RECT.size.y * 0.66), 460.0)
		var tool_tex := TextureRect.new()
		tool_tex.texture = load(vessel_path)
		Composition.fit_texture_rect(tool_tex, VESSEL_RECT)
		tool_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tool_tex.z_index = L2_BASE
		add_child(tool_tex)

	# L3 — food raw→cooked cross-fade. 냄비 안. zone-hold가 쌓일수록 cooked 드러남.
	_build_food_sprites(food_id)

	# P0 #4 (2026-06-07): stew dish(순두부 t2_013)는 broth + 김치/두부 잠김 연출.
	# "stew = 재료가 국물 안에 잠겨 끓는다 (위에 dry로 올리는 게 아님)".
	_build_stew_extras(food_id)

	# 불꽃 (procedural Polygon2D — 냄비 아래). heat에 따라 scale.
	_build_flame()
	# 부글부글 bubble (heat에 따라 강도 변화).
	_build_bubbles()
	# overflow 게이지 (국물 차오름 — 불 셀수록 ↑).
	_build_overflow_bar()
	# 세로 heat dial + ideal zone band.
	_build_dial()
	# L5 — 끓는 김 (steam). 냄비 입구 위.
	_attach_steam(Vector2(VESSEL_RECT.position.x + VESSEL_RECT.size.x * 0.5,
		VESSEL_RECT.position.y + 30.0), 3)

	# heat % readout.
	_pct_lbl = Label.new()
	_pct_lbl.position = Vector2(0, 1640)
	_pct_lbl.size = Vector2(1080, 60)
	_pct_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pct_lbl.add_theme_font_size_override("font_size", 40)
	_pct_lbl.add_theme_color_override("font_color", Color(0.45, 0.32, 0.18))
	add_child(_pct_lbl)

	# zone-hold progress 막대 (얼마나 잘 유지 중인지 — gif _fill hook).
	var hold_track := ColorRect.new()
	hold_track.color = Color(0, 0, 0, 0.18)
	hold_track.size = Vector2(840, 40)
	hold_track.position = Vector2(120, 1720)
	hold_track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hold_track)
	_fill = ColorRect.new()
	_fill.color = Color(0.98, 0.78, 0.22)
	_fill.size = Vector2(0, 40)
	_fill.position = Vector2(120, 1720)
	_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fill)

	# 입력 인식기 — 다이얼 손잡이 vertical drag.
	_gesture = TouchGesture.new()
	_gesture.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_gesture)
	_gesture.drag_started.connect(_on_drag_started)
	_gesture.drag_updated.connect(_on_drag_updated)
	_gesture.drag_released.connect(_on_drag_released)

	_apply_heat_visual()


# --- visual build ---

func _build_flame() -> void:
	# 불꽃 = 외곽(주황) + 코어(노랑) 2겹 Polygon2D. pivot은 바닥(불 밑동).
	# z_index를 양수로 — CookingBackground(Control) 위에 그려지게. 냄비 밑동에서 솟아오름.
	# 불꽃 = vessel 밑동에서 솟아오름 (heat glow). vessel 아래 중앙.
	var flame_holder := Node2D.new()
	flame_holder.name = "FlameHolder"
	flame_holder.position = Vector2(VESSEL_RECT.position.x + VESSEL_RECT.size.x * 0.5,
		VESSEL_RECT.position.y + VESSEL_RECT.size.y - 10.0)
	flame_holder.z_index = L2_BASE - 1   # vessel 뒤(밑동에서 핥는 느낌)
	add_child(flame_holder)
	_flame = Polygon2D.new()
	_flame.polygon = PackedVector2Array([
		Vector2(-80, 0), Vector2(-40, -120), Vector2(-10, -60),
		Vector2(0, -200), Vector2(20, -70), Vector2(48, -130), Vector2(80, 0),
	])
	_flame.color = Color(0.98, 0.45, 0.10, 0.92)
	flame_holder.add_child(_flame)
	_flame_core = Polygon2D.new()
	_flame_core.polygon = PackedVector2Array([
		Vector2(-40, 0), Vector2(-18, -70), Vector2(0, -130), Vector2(18, -66), Vector2(40, 0),
	])
	_flame_core.color = Color(1.0, 0.86, 0.30, 0.95)
	flame_holder.add_child(_flame_core)


## L3 — food raw + cooked standalone sprite를 같은 rect에 겹쳐 둠. cooked는 처음 투명,
## zone-hold가 쌓일수록 fade-in(끓어 익는 느낌). 냄비 안 중앙.
func _build_food_sprites(food_id: StringName) -> void:
	var sem: Array = ArtRegistry.timing_food_for(food_id)   # [name, before, after]
	var raw_path: String = ArtRegistry.get_ingredient(String(sem[0]), String(sem[1]))
	var cooked_path: String = ArtRegistry.get_ingredient(String(sem[0]), String(sem[2]))
	# food은 vessel 안쪽(58%)에만 — 냄비 위로 안 넘침. ingredient clamp.
	var food_rect: Rect2 = Composition.rect_inside(VESSEL_RECT, 0.58, -24.0)
	if raw_path != "":
		_food_raw = TextureRect.new()
		_food_raw.texture = load(raw_path)
		Composition.fit_texture_rect(_food_raw, food_rect)
		_food_raw.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_food_raw.z_index = L3_INGREDIENT
		add_child(_food_raw)
	if cooked_path != "":
		_food_cooked = TextureRect.new()
		_food_cooked.texture = load(cooked_path)
		Composition.fit_texture_rect(_food_cooked, food_rect)
		_food_cooked.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_food_cooked.modulate = Color(1, 1, 1, 0.0)
		_food_cooked.z_index = L3_INGREDIENT + 1
		add_child(_food_cooked)


func _build_bubbles() -> void:
	# 냄비 안 부글부글 — 작은 흰 원들이 heat에 따라 떠오름. vessel 안쪽에만 spawn.
	var inner: Rect2 = Composition.rect_inside(VESSEL_RECT, 0.55, -20.0)
	for i in range(6):
		var b := ColorRect.new()
		b.color = Color(1, 1, 1, 0.5)
		b.size = Vector2(24, 24)
		b.position = Vector2(inner.position.x + randf_range(0, inner.size.x),
			inner.position.y + randf_range(0, inner.size.y * 0.6))
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.z_index = L3_INGREDIENT + 2
		add_child(b)
		_bubbles.append(b)


## P0 #4 — stew broth + submerged 재료. stew dish에서만 (그 외 dish 무변경).
##   1) 국물(broth) — vessel 안쪽 빨간/주황 반투명 fill (boiling stew 표면).
##   2) submerged 재료(김치/두부) — broth 표면에 부분 잠김(아래쪽 broth로 가려짐).
## dry pile(위에 올림) 금지 — 재료가 국물 안에 있어야 한다.
func _build_stew_extras(food_id: StringName) -> void:
	var fid: String = String(food_id)
	if not STEW_SUBMERGED.has(fid):
		return
	# broth fill — vessel 안쪽(60%) rect, raw food 위(L3_INGREDIENT+0.5)로 살짝 덮어 "잠긴" 느낌.
	var broth_rect: Rect2 = Composition.rect_inside(VESSEL_RECT, 0.60, -16.0)
	var broth := ColorRect.new()
	broth.name = "StewBroth"
	broth.color = Color(0.74, 0.22, 0.12, 0.55)   # 매운 stew 국물 (gochugaru 베이스)
	broth.position = Vector2(broth_rect.position.x, broth_rect.position.y + broth_rect.size.y * 0.28)
	broth.size = Vector2(broth_rect.size.x, broth_rect.size.y * 0.72)
	broth.mouse_filter = Control.MOUSE_FILTER_IGNORE
	broth.z_index = L3_INGREDIENT + 1   # raw food(=tofu) 위로 — 국물에 잠긴 느낌
	add_child(broth)
	# submerged 재료 토큰 — broth 표면을 가로질러 흩뿌림. 아래 절반은 broth로 가려져 "잠김".
	var submerged: Array = STEW_SUBMERGED[fid]
	var idx: int = 0
	for entry in submerged:
		var ing_path: String = ArtRegistry.get_ingredient(String(entry[0]), String(entry[1]))
		if ing_path == "":
			idx += 1
			continue
		var n: int = 3
		for i in range(n):
			var tok := TextureRect.new()
			tok.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tok.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tok.custom_minimum_size = Vector2.ZERO
			tok.texture = load(ing_path)
			tok.size = Vector2(110, 110)
			var bx: float = broth_rect.position.x + broth_rect.size.x * (0.18 + 0.62 * float(i) / float(maxi(1, n - 1)))
			# 토큰 y: broth 표면 부근 — 일부만 위로 나오고 아래는 broth(z 위)로 가려짐.
			var by: float = broth.position.y + randf_range(-30.0, 20.0) + float(idx) * 40.0
			tok.position = Vector2(bx - 55.0, by - 70.0)
			tok.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tok.z_index = L3_INGREDIENT   # broth(z+1)가 아래쪽을 덮음 → 부분 잠김
			tok.rotation = deg_to_rad(randf_range(-18.0, 18.0))
			add_child(tok)
		idx += 1


# overflow 게이지 geometry (vessel 우측에 hug). _apply_heat_visual과 공유.
const OVERFLOW_X: float = 832.0      # VESSEL 오른쪽 가장자리 옆
const OVERFLOW_TOP: float = 600.0
const OVERFLOW_H: float = 420.0

func _build_overflow_bar() -> void:
	# 국물 차오름 게이지 (불 셀수록 risk ↑) — 냄비 우측 rounded 세로 바.
	var track := Panel.new()
	var tsb := StyleBoxFlat.new()
	tsb.bg_color = Color(0.20, 0.14, 0.10, 0.35)
	tsb.set_corner_radius_all(18)
	track.add_theme_stylebox_override("panel", tsb)
	track.size = Vector2(36, OVERFLOW_H)
	track.position = Vector2(OVERFLOW_X, OVERFLOW_TOP)
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(track)
	_overflow_bar = ColorRect.new()
	_overflow_bar.color = Color(0.85, 0.30, 0.18, 0.85)
	_overflow_bar.size = Vector2(36, 0)
	_overflow_bar.position = Vector2(OVERFLOW_X, OVERFLOW_TOP + OVERFLOW_H)  # 아래에서 위로
	_overflow_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overflow_bar)


func _build_dial() -> void:
	# 세로 track.
	_dial_track = Panel.new()
	_dial_track.position = Vector2(DIAL_X - 36, DIAL_TOP)
	_dial_track.size = Vector2(72, DIAL_H)
	var tsb := StyleBoxFlat.new()
	tsb.bg_color = Color(0.20, 0.14, 0.10, 0.85)
	tsb.set_corner_radius_all(36)
	_dial_track.add_theme_stylebox_override("panel", tsb)
	_dial_track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dial_track)
	# ideal zone band (gold) — heat 매핑: heat=1(강불)이 track 위쪽.
	var zw: float = clampf(_perfect_w, 0.04, 0.4)
	var zone_top_heat: float = clampf(_perfect_at + zw * 0.5, 0.0, 1.0)
	var zone_bot_heat: float = clampf(_perfect_at - zw * 0.5, 0.0, 1.0)
	_dial_zone = ColorRect.new()
	_dial_zone.color = Color(0.98, 0.78, 0.22, 0.55)
	var zy_top: float = DIAL_TOP + (1.0 - zone_top_heat) * DIAL_H
	var zy_bot: float = DIAL_TOP + (1.0 - zone_bot_heat) * DIAL_H
	_dial_zone.position = Vector2(DIAL_X - 36, zy_top)
	_dial_zone.size = Vector2(72, maxf(zy_bot - zy_top, 24.0))
	_dial_zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dial_zone)
	# knob (손잡이).
	_knob = Panel.new()
	var ksb := StyleBoxFlat.new()
	ksb.bg_color = Color(0.86, 0.45, 0.22)
	ksb.set_corner_radius_all(int(KNOB_R))
	ksb.set_border_width_all(5)
	ksb.border_color = Color(0.45, 0.22, 0.10)
	ksb.shadow_size = 8
	ksb.shadow_color = Color(0, 0, 0, 0.35)
	_knob.add_theme_stylebox_override("panel", ksb)
	_knob.size = Vector2(KNOB_R * 2, KNOB_R * 2)
	_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_knob)
	_position_knob()


func _position_knob() -> void:
	if is_instance_valid(_knob):
		var ky: float = DIAL_TOP + (1.0 - _heat) * DIAL_H - KNOB_R
		_knob.position = Vector2(DIAL_X - KNOB_R, ky)


# --- gesture handlers ---

func _on_drag_started(pos: Vector2) -> void:
	if _finished or _finished_timing:
		return
	# 다이얼 근처에서 잡았는지 — knob 또는 track 근처 X.
	_knob_drag = absf(pos.x - DIAL_X) < 180.0
	if _knob_drag:
		_set_heat_from_y(pos.y)


func _on_drag_updated(pos: Vector2, _vel: Vector2) -> void:
	if _finished or _finished_timing:
		return
	if _knob_drag:
		_set_heat_from_y(pos.y)


func _on_drag_released(_info: Dictionary) -> void:
	_knob_drag = false


func _set_heat_from_y(y: float) -> void:
	# track 위(작은 y)=강불(heat 1), 아래(큰 y)=약불(heat 0).
	var t: float = clampf((y - DIAL_TOP) / DIAL_H, 0.0, 1.0)
	_heat = 1.0 - t
	_position_knob()
	_apply_heat_visual()


# --- per-frame: zone-hold 누적 + 시각 갱신 + auto-finish ---

func _process(dt: float) -> void:
	if _finished or _finished_timing:
		return
	var elapsed: float = _now_ms() - _start_ms
	# zone-hold 누적.
	var half: float = maxf(_perfect_w * 0.5, 0.02)
	var dist: float = absf(_heat - _perfect_at)
	if dist <= half:
		_zone_hold_ms += dt * 1000.0
		_good_hold_ms += dt * 1000.0
	elif dist <= half + 0.12:
		_good_hold_ms += dt * 1000.0
	# overflow risk: 적정보다 불 세면 차오름, 약하면 가라앉음.
	var over_heat: float = _heat - (_perfect_at + half)
	if over_heat > 0.0:
		_overflow = clampf(_overflow + over_heat * dt * 1.6, 0.0, 1.0)
	else:
		_overflow = clampf(_overflow - dt * 0.5, 0.0, 1.0)
	_apply_heat_visual()
	_update_hold_fill(elapsed)
	if elapsed >= _duration_ms:
		_finalize_timing()


func _apply_heat_visual() -> void:
	# 불꽃 크기 = heat. 강불일수록 크고 밝음.
	if is_instance_valid(_flame):
		var s: float = 0.5 + _heat * 1.1
		_flame.get_parent().scale = Vector2(s, s)
		_flame.color = Color(0.98, 0.45 - _heat * 0.12, 0.10, 0.85 + _heat * 0.12)
	# bubble 강도 = heat (alpha + jitter).
	for b in _bubbles:
		if is_instance_valid(b):
			b.color.a = 0.2 + _heat * 0.6
			b.scale = Vector2.ONE * (0.6 + _heat * 0.9)
	# overflow bar (아래→위 차오름).
	if is_instance_valid(_overflow_bar):
		var oh: float = _overflow * OVERFLOW_H
		_overflow_bar.size.y = oh
		_overflow_bar.position.y = OVERFLOW_TOP + OVERFLOW_H - oh
		_overflow_bar.color = Color(0.85, 0.30, 0.18, 0.5 + _overflow * 0.45)
	# knob/flame tint when overflowing (위험 신호).
	if is_instance_valid(_pct_lbl):
		var tag: String = ""
		var half: float = maxf(_perfect_w * 0.5, 0.02)
		if absf(_heat - _perfect_at) <= half:
			tag = "  · ideal simmer"
		elif _heat > _perfect_at:
			tag = "  · too hot!" if _overflow > 0.5 else "  · turning up"
		else:
			tag = "  · too low"
		_pct_lbl.text = "Heat %d%%%s" % [int(round(_heat * 100.0)), tag]


func _update_hold_fill(elapsed: float) -> void:
	if not is_instance_valid(_fill):
		return
	# 진행 대비 zone 유지율 → 막대 폭.
	var ratio: float = _zone_hold_ms / maxf(elapsed, 1.0)
	_fill.size.x = clampf(ratio, 0.0, 1.0) * 840.0
	# L3 raw→cooked cross-fade — 시간(끓인 누적)에 비례해 cooked 드러남.
	if is_instance_valid(_food_cooked):
		var cook_prog: float = clampf(_zone_hold_ms / maxf(_duration_ms * 0.7, 1.0), 0.0, 1.0)
		_food_cooked.modulate.a = cook_prog
	if is_instance_valid(_food_raw):
		var cook_prog2: float = clampf(_zone_hold_ms / maxf(_duration_ms * 0.7, 1.0), 0.0, 1.0)
		_food_raw.modulate.a = 1.0 - cook_prog2 * 0.85


func _finalize_timing() -> void:
	if _finished_timing:
		return
	_finished_timing = true
	# §6.1 — zone-hold ratio → 4-tier. 기존 도메인 [0,100] 동일.
	var total: float = maxf(_now_ms() - _start_ms, 1.0)
	var perfect_ratio: float = _zone_hold_ms / total
	var good_ratio: float = _good_hold_ms / total
	# overflow 페널티 (넘쳐서 탔으면 감점) — 시각 risk를 점수로.
	var burn_pen: float = clampf(_overflow - 0.7, 0.0, 0.3) / 0.3   # overflow>0.7부터 페널티
	var score: float
	# 4-tier 매핑 (1.0/0.6/0.2/0.0 → 100/60/20/0) — perfect_width 기준 유지율.
	if perfect_ratio >= 0.55:
		score = 80.0 + clampf((perfect_ratio - 0.55) / 0.45, 0.0, 1.0) * 20.0   # ideal: 80~100
	elif good_ratio >= 0.45:
		score = 40.0 + clampf((good_ratio - 0.45) / 0.4, 0.0, 1.0) * 30.0       # good band: 40~70
	elif good_ratio > 0.0:
		score = 20.0 + good_ratio / 0.45 * 18.0                                  # under: 20~38
	else:
		score = 0.0                                                              # 방치: 0
	score = clampf(score * (1.0 - burn_pen * 0.4), 0.0, 100.0)
	var j := RhythmJudge.PERFECT if score >= 80.0 else (RhythmJudge.GOOD if score >= 40.0 else RhythmJudge.MISS)
	_safe_feedback(j, Vector2(VESSEL_RECT.position.x + VESSEL_RECT.size.x * 0.5,
		VESSEL_RECT.position.y + VESSEL_RECT.size.y * 0.5))
	if is_instance_valid(_pct_lbl):
		if score >= 80.0:
			_pct_lbl.text = "Perfect simmer!"
		elif _overflow > 0.7:
			_pct_lbl.text = "It boiled over!"
		else:
			_pct_lbl.text = "Done"
	_finish(score)


func _now_ms() -> float:
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("now_ms"):
		return float(bc.now_ms())
	return float(Time.get_ticks_msec())
