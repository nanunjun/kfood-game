## GimbapBuildModule — REAL gimbap assembly (color-slot Arrange 폐기 교체, gimbap-vertical-slice-v2 §4).
##
## 사용자 거부 교정: 기존 arrange_module 의 generic color-slot 매칭 퍼즐(재료를 색 ring 슬롯에
## drag-snap, correct_count/slot_count 점수)을 폐기하고 **실제 김밥 조립**으로 재구축한다.
## "I built a gimbap" — 색을 맞추는 게 아니라 김밥을 쌓는다(color matching 아닌 gimbap assembly).
##
## ── 조리 순서 2~5 (김발 → 김 → 밥 → 속) 한 stage ─────────────────────────────────────
##   ① bamboo mat (받침, 평평 직사각, 김 밑)  — 자동으로 깔림 (player POV 하단=near)
##   ② 김 (seaweed) (mat 위 dark 직사각)        — 자동으로 깔림
##   ③ 밥 (rice) (김 most 얇게 + 상단 far margin = seal 자리) — 자동으로 펴짐
##   ④ 긴 prepared strip (당근/계란/녹색/단무지)  — **플레이어가 press-drag-release로 밥 lower-third
##       가로에 올린다 (핵심 액션, 색 슬롯 매칭 X)**
##
## ── 입력 (press-drag-release) ──────────────────────────────────────────────────────
## 하단 staging tray의 긴 가로 strip을 집어(press) → 밥 lower-third 가로로 drag → 놓으면(release)
## 그 자리에 안착. 정위치 = lower-third / centered / 평행. 너무 위=말기 어려움 / 너무 아래=흘러나옴 /
## 한쪽 몰림=비뚤. 색 ring 슬롯 / target card / 완성 김밥 미리보기 전부 금지.
##
## ── SCORING 보존 (arrange→prep bucket 그대로 승계, 신규 4-factor 축 0) ─────────────────
## build_quality ∈ [0,1] = strip 위치 정확도(lower-third centered) 0.5 + 평행/even 0.3 + 적정 양 0.2
##   → [0,100] 로 module_completed(score) emit. runner MODULE_TO_FACTOR 와 무관(runner 가 prep
##   bucket 으로 직접 기록). consequence 신호(§8.3): get_arrange_balance / get_arrange_bias_dir 를
##   strip 좌우 위치 기반으로 동일 시그니처 유지 → roll tilt offset 으로 carry (arrange 대체 투명).
##   §8.1: vs_available_slots 만큼만 strip 사용 가능 (시장 누락 = 빈 김밥).
extends "res://scripts/cooking_modules/base_module.gd"

const TouchGesture := preload("res://scripts/cooking_modules/touch_gesture.gd")

# --- player-POV layout (roll_module 과 동일 카메라: near=하단, far=상단, 평면 top-down) ---
const BUILD_X: float = 540.0                 # 김밥 조립 중심 X.
const BUILD_HERO_Y: float = 820.0            # mat/김/밥 group 중심 Y (MAIN zone).

# 평면 top-down — 세로 압축 없음(평평 직사각 mat, 거부 #5 twist 금지).
const MAT_BOX_W: float = 880.0               # 김발 base 가로.
const MAT_BOX_H: float = 587.0               # 3:2 (880 * 1024/1536).
const SEAWEED_BOX_W: float = 752.0           # 김 — mat 보다 작게 (mat 이 받침 frame).
const SEAWEED_BOX_H: float = 501.0
const RICE_BOX_W: float = 642.0              # 밥 — 김 visible 폭 ~80% 얇게.
const RICE_BOX_H: float = 428.0
const RICE_CENTER_Y: float = 40.0            # 밥 중심을 아래로 — 상단(far) 김 노출 = seal margin.

# strip 정위치 — 밥 lower-third 가로 centered. (group 로컬 y, 양수 = 아래/near 쪽)
const STRIP_TARGET_Y: float = 96.0           # 정답 strip band 중심 (lower-third).
const STRIP_TARGET_TOL_GOOD: float = 70.0    # 이 안이면 위치 perfect.
const STRIP_TARGET_TOL_OK: float = 150.0     # 이 밖이면 위치 감점 (너무 위/아래).
const STRIP_W: float = 560.0                 # 긴 strip 가로 길이 (밥 폭 대부분).
const STRIP_ROW_PITCH: float = 46.0          # 안착된 strip 간 세로 pitch (얇은 평행 band 간격).
const STRIP_ROW_GAP: float = 8.0             # (호환) 안착된 strip 간 세로 간격.

# staging tray (하단 near zone) — 준비된 긴 strip 들이 대기.
const TRAY_Y: float = 1470.0
const TRAY_GAP: float = 22.0

# 사용할 수 있는 긴 strip 종류 — Gimbap 정답 속(2026-06-12 sprite 배선, 당근/파 혼동 제거).
# ArtRegistry.gimbap_filling_specs()가 dish-correct sprite를 해석한다:
#   danmuji(밝은 노랑) / spinach(진녹) / carrot(주황 strip) / egg(노랑 지단).
# 더 이상 beef/green_onion 등 wrong-ingredient 대체가 없다 — 김밥 속이 정확 sprite로.
var _strip_specs: Array = []

var _need_strips: int = 4                     # 올려야 할 strip 수 (vs_available_slots 로 보정).
var _placed: int = 0
var _stage_group: Node2D = null               # mat 빼고 김+밥(평면). strip 도 여기에 안착.
var _stage_base_y: float = 0.0
var _rice: TextureRect = null

# strip 데이터: {node, home(tray Vector2), placed, target_y, local_off(group 로컬 안착 위치)}.
var _strips: Array = []
# 안착된 strip 의 group-로컬 위치(좌우 균형 / 정위치 / 평행 산정용).
var _placed_local: Array = []

var _gesture = null
var _dragging_idx: int = -1
var _drag_offset: Vector2 = Vector2.ZERO
var _hint: Label = null


func _module_start(params: Dictionary) -> void:
	_attach_cooking_bg(900.0)
	# Gimbap 정답 속 spec(danmuji/spinach/carrot/egg)을 ArtRegistry SSOT에서 해석(sprite 배선).
	_strip_specs = ArtRegistry.gimbap_filling_specs(4)
	# §8.1 shopping→build: vs_available_slots 만큼만 strip 사용 (시장 누락 = 빈 김밥).
	if params.has("vs_available_slots"):
		_need_strips = clampi(int(params.get("vs_available_slots", 4)), 2, _strip_specs.size())
	else:
		_need_strips = clampi(int(params.get("slot_count", 4)), 2, _strip_specs.size())
	_build_header("Build Gimbap", "Place each filling strip along the lower third of the rice.")

	_attach_dish_shadow(Vector2(BUILD_X, BUILD_HERO_Y + 200.0), 580.0)

	# Layer 1 — bamboo mat (평면 직사각 받침, 김 밑). 자동 배치.
	_build_mat()
	# Layer 2~3 — 김 + 밥 (far margin = seal, 밥은 얇게). 자동 배치.
	_build_seaweed_rice(StringName(String(params.get("food_id", ""))))
	# Layer 4 — lower-third filling guide line (밥 중앙 아님 — lower third). snap 대상.
	_build_guide_line()
	# Layer 5 — staging tray 의 긴 strip (플레이어가 drag 로 올림 → guide에 snap).
	_build_staging_strips()

	_hint = Label.new()
	_hint.position = Vector2(0, 1610)
	_hint.size = Vector2(1080, 64)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 40)
	_hint.add_theme_color_override("font_color", Color(0.30, 0.20, 0.12))
	_hint.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.85))
	_hint.add_theme_constant_override("outline_size", 8)
	_hint.text = "Lay each filling along the lower-third guide line"
	add_child(_hint)

	# 입력 인식기 — press-drag-release (색 슬롯 매칭 아님).
	_gesture = TouchGesture.new()
	_gesture.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_gesture)
	_gesture.drag_started.connect(_on_drag_started)
	_gesture.drag_updated.connect(_on_drag_updated)
	_gesture.drag_released.connect(_on_drag_released)


# Layer 1 — bamboo mat 평면 직사각 (받침, 김 밑, 대각 twist 금지).
func _build_mat() -> void:
	var holder := Node2D.new()
	holder.z_index = L2_BASE
	holder.position = Vector2(BUILD_X, BUILD_HERO_Y)
	add_child(holder)
	# PAINTERLY SWAP (2026-06-13): mat_painterly (warm 김발, high-angle painterly) 우선 →
	# 기존 bamboo_mat_large → rolling_mat vessel. layer order/snap/scoring 무변경.
	var mat_path: String = ArtRegistry.get_painterly("mat_painterly")
	if mat_path == "":
		mat_path = ArtRegistry.get_roll_asset("bamboo_mat_large")
	if mat_path == "":
		mat_path = ArtRegistry.get_vessel("rolling_mat")
	if mat_path != "":
		var mat := TextureRect.new()
		mat.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		mat.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		mat.custom_minimum_size = Vector2.ZERO
		mat.texture = load(mat_path)
		mat.size = Vector2(MAT_BOX_W, MAT_BOX_H)
		mat.position = Vector2(-MAT_BOX_W * 0.5, -MAT_BOX_H * 0.5)
		mat.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(mat)
	else:
		var rect := ColorRect.new()
		rect.color = Color(0.78, 0.58, 0.30)
		rect.size = Vector2(MAT_BOX_W, MAT_BOX_H)
		rect.position = Vector2(-MAT_BOX_W * 0.5, -MAT_BOX_H * 0.5)
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(rect)


# Layer 2~3 — 김 (mat 위 dark 직사각) + 밥 (most 얇게, 상단 far margin = seal).
func _build_seaweed_rice(_food_id: StringName) -> void:
	_stage_group = Node2D.new()
	_stage_group.position = Vector2(BUILD_X, BUILD_HERO_Y)
	_stage_group.z_index = L3_INGREDIENT
	_stage_base_y = _stage_group.position.y
	add_child(_stage_group)

	# 김 한 장 (mat 보다 작게 — mat 이 둘레 받침). PAINTERLY SWAP: seaweed_painterly 우선.
	var seaweed_path: String = ArtRegistry.get_painterly("seaweed_painterly")
	if seaweed_path == "":
		seaweed_path = ArtRegistry.get_roll_asset("seaweed_sheet_rect")
	if seaweed_path == "":
		seaweed_path = ArtRegistry.get_roll_asset("seaweed_sheet")
	if seaweed_path != "":
		var sw := TextureRect.new()
		sw.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sw.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		sw.custom_minimum_size = Vector2.ZERO
		sw.texture = load(seaweed_path)
		sw.size = Vector2(SEAWEED_BOX_W, SEAWEED_BOX_H)
		sw.position = Vector2(-SEAWEED_BOX_W * 0.5, -SEAWEED_BOX_H * 0.5)
		sw.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_stage_group.add_child(sw)
	else:
		var fb := ColorRect.new()
		fb.color = Color(0.16, 0.20, 0.14)
		fb.size = Vector2(SEAWEED_BOX_W, SEAWEED_BOX_H)
		fb.position = Vector2(-SEAWEED_BOX_W * 0.5, -SEAWEED_BOX_H * 0.5)
		fb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_stage_group.add_child(fb)

	# 밥 — 김 most 얇게, 중심을 RICE_CENTER_Y 로 내려 상단(far) 김 노출 = seal margin.
	# PAINTERLY SWAP: rice_painterly (낟알 질감 밥) 우선.
	var rice_path: String = ArtRegistry.get_painterly("rice_painterly")
	if rice_path == "":
		rice_path = ArtRegistry.get_roll_asset("rice_layer_flat_rect")
	if rice_path == "":
		rice_path = ArtRegistry.get_roll_asset("rice_layer_flat")
	if rice_path != "":
		_rice = TextureRect.new()
		_rice.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_rice.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_rice.custom_minimum_size = Vector2.ZERO
		_rice.texture = load(rice_path)
		_rice.size = Vector2(RICE_BOX_W, RICE_BOX_H)
		_rice.position = Vector2(-RICE_BOX_W * 0.5, RICE_CENTER_Y - RICE_BOX_H * 0.5)
		_rice.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_stage_group.add_child(_rice)


# Layer 4 — lower-third filling guide line (밥 중앙 아님 — lower third). strip이 여기에 snap.
# 점선 가로 라인 + "lay fillings here" 캡션. STRIP_TARGET_Y(stage 로컬, lower third)에 위치.
var _guide_line: Control = null

func _build_guide_line() -> void:
	if _stage_group == null:
		return
	var line := Control.new()
	line.name = "FillingGuideLine"
	# stage_group 로컬 좌표 — STRIP_TARGET_Y(lower third) 가로 점선.
	line.position = Vector2(-RICE_BOX_W * 0.5, STRIP_TARGET_Y)
	line.size = Vector2(RICE_BOX_W, 6.0)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.z_index = L3_INGREDIENT + 1
	_stage_group.add_child(line)
	# 가로 점선(dash) — 밥 lower-third를 가로질러 "여기에 한 줄로" 안내.
	var dash_w: float = 30.0
	var gap: float = 18.0
	var x: float = 16.0
	while x < RICE_BOX_W - 16.0:
		var dash := Panel.new()
		dash.position = Vector2(x, -3.0)
		dash.size = Vector2(dash_w, 6.0)
		var dsb := StyleBoxFlat.new()
		dsb.bg_color = Color(1.0, 0.97, 0.80, 0.92)
		dsb.set_corner_radius_all(3)
		dsb.set_border_width_all(2)
		dsb.border_color = Color(0.55, 0.36, 0.12, 0.85)
		dash.add_theme_stylebox_override("panel", dsb)
		dash.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.add_child(dash)
		x += dash_w + gap
	_guide_line = line


# Layer 5 — staging tray 의 긴 strip (플레이어가 drag). 색 토큰 아님 — 실제 긴 가로 strip.
func _build_staging_strips() -> void:
	var specs: Array = _strip_specs.slice(0, _need_strips)
	var n: int = specs.size()
	# tray 가로 배치 — 각 strip 은 **긴 가로 band**(작은 아이콘 아님). 집어서 밥 guide로 끌어올림.
	# 긴 strip은 밥 폭 대부분을 가로질러야 하므로 처음부터 길게 만든다(STRIP_W). tray에서는
	# 가로로 길어 서로 살짝 세로로 겹쳐 대기(stack), drag로 한 줄씩 guide에 올린다.
	var strip_w: float = STRIP_W
	var stack_pitch: float = 86.0
	var y0: float = TRAY_Y - float(n - 1) * stack_pitch * 0.5
	for i in range(n):
		var spec: Dictionary = specs[i]
		var home := Vector2(BUILD_X, y0 + float(i) * stack_pitch)
		var node := _make_strip_node(spec, strip_w)
		node.position = home - node.size * 0.5
		node.z_index = L3_INGREDIENT + 4 + i
		add_child(node)
		_strips.append({"node": node, "home": home, "placed": false, "spec": spec, "base_size": node.size})


# 긴 strip TextureRect (또는 fallback ColorRect) — bar_w 가로 길이의 **긴 얇은 band**.
# spec.tex = ArtRegistry.gimbap_filling_specs()가 해석한 dish-correct sprite(danmuji/spinach/carrot/egg).
# 작은 아이콘 금지 — 긴 strip(밥 폭 가로질러). danmuji/spinach(정사각)도 STRETCH_SCALE로 band화.
func _make_strip_node(spec: Dictionary, bar_w: float) -> Control:
	# PAINTERLY SWAP (2026-06-13): filling_{id}_painterly (volume + highlight 속재료 band) 우선 →
	# 기존 spec.tex(long-strip/ingredient) fallback. id = danmuji/spinach/carrot/egg(SSOT 순서).
	var path: String = ArtRegistry.gimbap_painterly_filling(String(spec.get("id", "")))
	if path == "":
		path = String(spec.get("tex", ""))
	if path != "":
		var box_w: float = bar_w
		var box_h: float = STRIP_ROW_PITCH * 0.94    # 얇은 band 두께(평행 band, 작은 아이콘 아님).
		var t := TextureRect.new()
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		# STRETCH_SCALE — 긴 가로 band로 채운다(danmuji/spinach 정사각도 길게 펴짐). carrot/egg long은
		# 원래 가로 우세라 자연스럽다. letterbox 없이 box를 가득 채워 "긴 strip" 읽힘.
		t.stretch_mode = TextureRect.STRETCH_SCALE
		t.custom_minimum_size = Vector2.ZERO
		t.texture = load(path)
		t.size = Vector2(box_w, box_h)
		t.pivot_offset = Vector2(box_w * 0.5, box_h * 0.5)
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return t
	var c := ColorRect.new()
	c.color = spec.get("col", Color(0.9, 0.7, 0.3))
	c.size = Vector2(bar_w, 46.0)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


# --- gesture: press-drag-release (긴 strip 을 밥에 올림) ---

func _on_drag_started(pos: Vector2) -> void:
	if _finished:
		return
	var best: int = -1
	var best_d: float = 220.0
	for i in range(_strips.size()):
		if bool(_strips[i]["placed"]):
			continue
		var node: Control = _strips[i]["node"]
		if not is_instance_valid(node):
			continue
		var center: Vector2 = node.position + node.size * 0.5
		var d: float = pos.distance_to(center)
		if d < best_d:
			best_d = d
			best = i
	_dragging_idx = best
	if _dragging_idx >= 0:
		var node: Control = _strips[_dragging_idx]["node"]
		node.z_index = 40
		_drag_offset = node.position + node.size * 0.5 - pos
		node.scale = Vector2(1.12, 1.12)


func _on_drag_updated(pos: Vector2, _vel: Vector2) -> void:
	if _finished or _dragging_idx < 0:
		return
	var node: Control = _strips[_dragging_idx]["node"]
	if not is_instance_valid(node):
		return
	var center: Vector2 = pos + _drag_offset
	node.position = center - node.size * 0.5
	_update_drag_hint(center)


func _on_drag_released(_info: Dictionary) -> void:
	if _finished or _dragging_idx < 0:
		return
	var idx: int = _dragging_idx
	_dragging_idx = -1
	var node: Control = _strips[idx]["node"]
	if not is_instance_valid(node):
		return
	node.scale = Vector2(1, 1)
	var center: Vector2 = node.position + node.size * 0.5
	# 밥(rice) 영역 위에 놓였는가? (group-로컬 좌표로 변환해 lower-third 정위치 판정)
	var on_rice: bool = _is_over_rice(center)
	if not on_rice:
		_return_home(idx)
		return
	_settle_strip(idx, center)


# rice 영역 안(여유 포함)에 놓였는지 — group-로컬 변환.
func _is_over_rice(global_center: Vector2) -> bool:
	var local: Vector2 = global_center - _stage_group.position
	var half_w: float = RICE_BOX_W * 0.62
	var top: float = RICE_CENTER_Y - RICE_BOX_H * 0.5 - 40.0
	var bot: float = RICE_CENTER_Y + RICE_BOX_H * 0.5 + 90.0
	return absf(local.x) <= half_w and local.y >= top and local.y <= bot


# strip 을 밥 위에 안착 — guide line(lower-third)에 **snap** + 가지런히 한 줄 정렬.
# group 의 자식으로 reparent 해서 말기/이후 단계로 carry.
func _settle_strip(idx: int, global_center: Vector2) -> void:
	var node: Control = _strips[idx]["node"]
	var local: Vector2 = global_center - _stage_group.position
	# 놓은 위치(정확도 산정용 — 너무 위/아래/한쪽 몰림 감점 보존). x는 가운데로 끌어당겨 평행.
	var drop_x: float = clampf(local.x, -RICE_BOX_W * 0.5, RICE_BOX_W * 0.5)
	var drop_y: float = local.y
	_strips[idx]["placed"] = true
	_placed += 1
	# scoring/consequence는 "놓은 정확도"를 보존: drop_y(guide 근접도) + drop_x(좌우 몰림) 기록.
	_placed_local.append(Vector2(drop_x, drop_y))
	# reparent 해서 stage_group 로컬에 — roll/slice 로 carry 되도록.
	var keep_global: Vector2 = node.global_position
	node.get_parent().remove_child(node)
	_stage_group.add_child(node)
	node.global_position = keep_global
	node.z_index = L3_INGREDIENT + 3
	# SNAP — strip을 guide line(lower-third, STRIP_TARGET_Y)에 정확히 가져다 붙이고 한 줄로 가지런히.
	# 가로는 centered(x=0), 세로는 안착 순서대로 STRIP_ROW_PITCH 간격의 얇은 평행 band로 정렬.
	# band 전체를 STRIP_TARGET_Y에 centered → lower-third에 가지런한 한 줄 (겹치지 않는 얇은 평행).
	var row_y: float = STRIP_TARGET_Y + (float(_placed - 1) - float(_need_strips - 1) * 0.5) * STRIP_ROW_PITCH
	var snap_local := Vector2(0.0, row_y)
	var target_pos: Vector2 = snap_local - node.size * 0.5
	var tw := node.create_tween()
	tw.tween_property(node, "position", target_pos, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(node, "scale", Vector2(1.0, 1.0), 0.18)
	# guide line pulse(snap 피드백).
	if is_instance_valid(_guide_line):
		var gtw := _guide_line.create_tween()
		gtw.tween_property(_guide_line, "modulate", Color(1.3, 1.3, 1.1, 1.0), 0.08)
		gtw.tween_property(_guide_line, "modulate", Color(1, 1, 1, 1.0), 0.16)
	# 정위치(lower-third centered)면 GOOD, 어긋나면 MISS feedback.
	var off: float = absf(drop_y - STRIP_TARGET_Y)
	_safe_feedback(RhythmJudge.GOOD if off <= STRIP_TARGET_TOL_OK else RhythmJudge.MISS, global_center)
	_update_placed_hint()
	if _placed >= _need_strips:
		_finalize()


func _return_home(idx: int) -> void:
	var node: Control = _strips[idx]["node"]
	var home: Vector2 = _strips[idx]["home"]
	node.z_index = L3_INGREDIENT + 4
	var tw := node.create_tween()
	tw.tween_property(node, "position", home - node.size * 0.5, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if is_instance_valid(_hint):
		_hint.text = "Drop it on the lower-third guide line"


func _update_drag_hint(global_center: Vector2) -> void:
	if not is_instance_valid(_hint):
		return
	var local: Vector2 = global_center - _stage_group.position
	if not _is_over_rice(global_center):
		_hint.text = "Place it onto the rice"
	elif local.y < STRIP_TARGET_Y - STRIP_TARGET_TOL_OK:
		_hint.text = "Too high — line it up with the guide"
	elif local.y > STRIP_TARGET_Y + STRIP_TARGET_TOL_OK:
		_hint.text = "Too low — line it up with the guide"
	else:
		_hint.text = "On the guide line — release to snap"


func _update_placed_hint() -> void:
	if not is_instance_valid(_hint):
		return
	var left: int = _need_strips - _placed
	if left > 0:
		_hint.text = "%d placed · %d to go" % [_placed, left]


func _finalize() -> void:
	if is_instance_valid(_hint):
		_hint.text = "Gimbap ready to roll!"
	# guide line은 채워졌으니 페이드 아웃(완성 김밥 속만 가지런히 남는다).
	if is_instance_valid(_guide_line):
		var gtw := _guide_line.create_tween()
		gtw.tween_property(_guide_line, "modulate:a", 0.0, 0.25)
	# build_quality = 위치 정확도 0.5 + 평행/even 0.3 + 적정 양 0.2.
	var pos_q: float = _position_quality()
	var even_q: float = _even_quality()
	var amount_q: float = clampf(float(_placed) / float(maxi(1, _need_strips)), 0.0, 1.0)
	var build_q: float = pos_q * 0.5 + even_q * 0.3 + amount_q * 0.2
	_finish(clampf(build_q, 0.0, 1.0) * 100.0)


# 위치 정확도 — 각 strip 의 lower-third(STRIP_TARGET_Y) 근접도 평균.
func _position_quality() -> float:
	if _placed_local.is_empty():
		return 0.0
	var s: float = 0.0
	for p in _placed_local:
		var off: float = absf((p as Vector2).y - STRIP_TARGET_Y)
		# TOL_GOOD 안=1, TOL_OK 밖=0 선형.
		var q: float = clampf(1.0 - (off - STRIP_TARGET_TOL_GOOD) / maxf(STRIP_TARGET_TOL_OK - STRIP_TARGET_TOL_GOOD, 1.0), 0.0, 1.0)
		s += q
	return s / float(_placed_local.size())


# 평행/even — strip 들의 좌우 x 편차가 작을수록(가로 centered 평행) 높음.
func _even_quality() -> float:
	if _placed_local.size() <= 1:
		return 1.0
	var max_off: float = 0.0
	for p in _placed_local:
		max_off = maxf(max_off, absf((p as Vector2).x))
	# x 편차 0 = even 1, RICE_BOX_W*0.5 이상 몰림 = 0.
	return clampf(1.0 - max_off / (RICE_BOX_W * 0.5), 0.0, 1.0)


# === consequence getters (arrange→roll §8.3 — 동일 시그니처, strip 위치 기반 재정의) ===
# runner 가 module_completed 후 읽어 roll tilt offset 으로 carry. arrange 교체가 투명하도록
# get_arrange_balance / get_arrange_bias_dir 이름을 유지(점수 도메인 무관, 순수 consequence 신호).

## strip 좌우 균형 [0,1] — 안착 strip 들이 가로 centered(평행)일수록 1. 한쪽 몰림 = 낮음 → roll 비뚤.
func get_arrange_balance() -> float:
	if _placed_local.size() <= 1:
		return 1.0
	var left: int = 0
	var right: int = 0
	for p in _placed_local:
		if (p as Vector2).x < -20.0:
			left += 1
		elif (p as Vector2).x > 20.0:
			right += 1
	var total: int = left + right
	if total <= 1:
		return 1.0
	return clampf(1.0 - absf(float(left - right)) / float(total), 0.0, 1.0)


## strip bias 방향 — +1(좌측 몰림 → roll 좌측 기울기) / -1(우측). balance 1 이면 무의미.
func get_arrange_bias_dir() -> float:
	var sum_x: float = 0.0
	for p in _placed_local:
		sum_x += (p as Vector2).x
	return 1.0 if sum_x <= 0.0 else -1.0
