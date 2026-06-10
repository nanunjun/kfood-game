## RollModule — TWO-FINGER balanced gimbap rolling (full redesign 2026-06-08).
##
## "I rolled the gimbap with both hands." 플레이어는 김발 하단 **양쪽(좌·우)을 두 손가락으로
## 잡고 함께 위로 밀어** 김+밥+속을 단단한 원통으로 만다. 핵심 skill = balance(좌우 sync),
## even pressure(일관된 누름), full roll(끝까지 말기), smooth motion(매끄러운 동작).
##
## ── 입력 (two-finger multi-touch) ────────────────────────────────────────────────
## InputEventScreenTouch / InputEventScreenDrag의 index로 좌·우 손가락을 **독립 추적**한다.
##   - 화면 좌측 절반에서 시작한 터치 = LEFT 손가락, 우측 = RIGHT 손가락.
##   - 두 손가락의 forward(위로) 이동량 = 각 side의 roll 진행.
##   - 좌우 진행 차이 = tilt(균형). 누름 일관성(속도 변동) = pressure. 평균 진행 = roll distance.
## DESKTOP fallback (테스트/screenshot): 마우스 좌클릭 = 시작점이 속한 side를 드래그, 동시에
##   다른 side는 keyboard(A/D 또는 ←/→)로 시뮬레이션. 키보드 단독 sim도 지원(테스트 결정성).
##
## ── 새 SCORING (사용자 승인, roll 한정 내부 변경) ────────────────────────────────────
## §6.1 재정의 — 40% 좌우 balance / 25% pressure consistency / 20% roll completion distance /
##   15% smooth motion. 0~100 → `module_completed(score)` 로 emit (contract 무변경).
## CONTRACT 보존: module_completed(0~100) signal / MODULE_TO_FACTOR("roll"→prep) / 4-factor /
##   progression / save / economy / 게임 flow(Step 2/4 Roll, Gimbap, progress, result) 전부 동일.
##
## ── 레이어 (실제 김밥 구조, z bottom→top) ────────────────────────────────────────────
##   1. bamboo_mat_large      — 받침/말이 도구 (base, 음식 자체 아님)
##   2. seaweed_sheet_rect    — 김 (mat 위 직사각, mat이 받침으로 둘레 보임)
##   3. rice_layer_flat_rect  — 밥 (김 70~80% 얇게 균등, 위쪽 far edge 김 노출 = seal)
##   4. filling strips         — 밥 lower-middle 가로 평행 band (egg/carrot/green/beef, embedded)
##   5. two-finger UI          — 좌·우 원형 target + ghost finger + 위 화살표 2개 + balance meter
##   6. 완성 김밥(content_only) — SUCCESS 후에만.
## 김/밥/strip은 _stage_group에 담아 두 손가락 push로 함께 말린다(curl→cylinder). mat은 가이드.
extends "res://scripts/cooking_modules/base_module.gd"

# --- composition geometry ---
const ROLL_X: float = 540.0              # roll 중심 X.
const ROLL_HERO_Y: float = 760.0         # setup group 기준 Y (화면 중앙 상단, food area 크게).

# 정면 first-person 평면 원근 — setup을 세로로 살짝 압축해 평면이 화면 안쪽(위)으로 receding.
const FRONTAL_SQUASH_Y: float = 0.82     # 1.0=압축 없음.

# 김발 / 김 / 밥 / strip 박스 (3:2, 1536x1024 자산. KEEP_ASPECT_CENTERED가 letterbox 방지).
const MAT_BOX_W: float = 860.0           # 김발 base 가로 (food area 크게 — empty space 줄임)
const MAT_BOX_H: float = 573.0           # 3:2 유지 (860 * 1024/1536)
const SEAWEED_BOX_W: float = 740.0       # 김 — mat보다 작게 (mat이 받침 frame)
const SEAWEED_BOX_H: float = 493.0       # 3:2 유지
const RICE_BOX_W: float = 632.0          # 밥 — 김 visible 폭 ~80% 얇게 균등 spread
const RICE_BOX_H: float = 421.0          # 3:2 유지
const RICE_SQUASH_Y: float = 0.62        # 밥 세로 압축 — 두꺼운 block을 얇은 layer로
const RICE_CENTER_Y: float = 46.0        # 밥 중심 Y(stage 로컬) — 아래로 내려 far edge(위) 김 노출(seal)

# 속재료 strip — visible bar 폭을 동일하게(김 visible 폭의 비율) + 세로 압축 = 얇은 평행 band.
const STRIP_BAR_RATIO: float = 0.66      # 모든 strip visible bar = 김 visible 폭의 66% (rice 안)
const STRIP_SQUASH_Y: float = 0.52       # strip 세로 압축 — 얇은 김밥 속
const STRIP_OVERLAP: float = 32.0        # strip 간 겹침 (평행·가까이 — 붙은 band)
const STRIP_BAND_CENTER_Y: float = 92.0  # 4-strip band 중심 Y(stage 로컬) — 밥 lower-middle

# two-finger 입력 / target.
const TOUCH_TARGET_OFFSET_X: float = 250.0   # 좌·우 target X 오프셋(중심 기준).
const TOUCH_TARGET_Y: float = 1230.0         # 두 target Y (mat 하단 near edge 쪽).
const TOUCH_TARGET_R: float = 64.0           # 원형 target 반지름.
const PUSH_DISTANCE: float = 460.0           # 완전한 roll까지 필요한 forward(위로) push 거리(px).

# balance / pressure 판정 임계.
const TILT_WARN: float = 0.12            # 좌우 진행 차 / PUSH_DISTANCE 비율 — 이 이상 = tilt 경고.
const TILT_BAD: float = 0.28             # 이 이상 = crooked(심한 비뚤).
const SMOOTH_JITTER_REF: float = 1800.0  # 속도 변동(px/s) 기준 — 이 이상이면 smooth 감점.

# halfway swap — 이 progress 이상에서 평평 layer를 "반쯤 말린" sprite로 교체.
const HALFWAY_SWAP_P: float = 0.55

# === Gimbap Vertical Slice — consequence hook (design §8.2 / §8.3) ===
# Pass B: prep_quality(julienne strip 품질) → roll sweet zone 폭 보정 / arrange balance →
#   tilt 기준점 offset. roll input(two-finger)·scoring 공식(40/25/20/15)은 무변경. 오직
#   sweet zone 너비와 tilt 기준만 quality-state로 보정한다(같은 입력 → 다른 결과 = 인과 증명).
#   기본값(1.0 / 0.0)은 vertical slice가 아닌 일반 runner에서 기존 난이도를 100% 보존한다.
var _vs_sweet_scale: float = 1.0     # 1.0 = 기존 sweet zone. <1.0 = 좁아짐(prep 나쁨 → 말기 어려움).
var _vs_tilt_offset: float = 0.0     # 좌우 진행 bias(arrange 불균형 → cylinder가 비뚤어지는 쪽).
var _vs_active: bool = false         # vertical slice consequence가 켜졌는지(로그/visual 분기용).

# --- roll 진행 상태 (two-finger) ---
var _left_progress: float = 0.0          # LEFT 손가락 forward 진행 0~1.2.
var _right_progress: float = 0.0         # RIGHT 손가락 forward 진행 0~1.2.
var _rolling: bool = false               # 한 쪽이라도 누르고 있으면 true.

# 손가락별 추적 (multi-touch index → 상태).
var _left_id: int = -1                   # LEFT 손가락 touch index (-1 = 없음).
var _right_id: int = -1                  # RIGHT 손가락 touch index.
var _left_start_y: float = 0.0
var _right_start_y: float = 0.0
var _left_last_y: float = 0.0
var _right_last_y: float = 0.0
var _left_last_ms: float = 0.0
var _right_last_ms: float = 0.0

# smooth / pressure 표본 — 양손 속도 변동(jitter)과 push 누락.
var _speed_samples: Array = []           # 각 update의 |Δspeed| (px/s) — 클수록 거칠다.
var _last_left_speed: float = 0.0
var _last_right_speed: float = 0.0
var _both_down_frames: int = 0           # 두 손가락 동시에 눌린 update 수.
var _any_down_frames: int = 0            # 한 쪽이라도 눌린 update 수 (동시성 비율 산출).

# desktop fallback (마우스 = 한 손, keyboard = 다른 손 sim).
var _mouse_side: int = 0                 # 0=없음, -1=좌, +1=우 (현재 마우스가 잡은 side).
var _kb_left_held: bool = false
var _kb_right_held: bool = false

# --- 시각 nodes ---
var _stage_group: Node2D = null          # 김+밥+속 wrapper (양손 push로 함께 말림)
var _stage_base_y: float = 0.0
var _mat_node2d: Node2D = null           # 김발 받침 wrapper
var _mat: Control = null
var _mat_base_y: float = 0.0
var _seaweed: TextureRect = null
var _rice: TextureRect = null
var _fillings: Array = []
var _halfway: TextureRect = null
var _finished_roll: TextureRect = null

# two-finger UI.
var _ui_left: _TouchTargetDraw = null
var _ui_right: _TouchTargetDraw = null
var _balance_meter: _BalanceMeterDraw = null
var _hint: Label = null                  # 실시간 feedback message.
var _track: ColorRect = null
var _fill_marker: ColorRect = null


func _module_start(params: Dictionary) -> void:
	_attach_cooking_bg(1000.0)
	# Step 2/4 Roll — game flow 보존. dish name = Gimbap (header title는 "Roll").
	_build_header("Roll", "Use two fingers to push both sides evenly")
	set_process_input(true)
	_consume_vs_consequence(params)

	var food_id: StringName = StringName(String(params.get("food_id", "")))
	_attach_dish_shadow(Vector2(ROLL_X, ROLL_HERO_Y + 180.0), 560.0)

	# Layer 1 — bamboo mat base (받침/말이 도구).
	_build_bamboo_mat_base()
	# Layer 2~3 — 김 + 밥 (실제 김밥 구조).
	_build_stage_layers(food_id)
	# Layer 4 — 속재료 평행 band (밥에 살짝 embedded).
	_build_fillings(food_id)
	# Layer 5 — two-finger UI (좌·우 target + ghost + arrow + balance meter).
	_build_two_finger_ui()
	# progress track.
	_build_progress_ui()

	# 실시간 feedback message.
	_hint = Label.new()
	_hint.position = Vector2(0, 1560)
	_hint.size = Vector2(1080, 70)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 44)
	_hint.add_theme_color_override("font_color", Color(0.30, 0.20, 0.12))
	_hint.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.85))
	_hint.add_theme_constant_override("outline_size", 8)
	_hint.text = "Roll evenly from both edges"
	add_child(_hint)


# Layer 1 — bamboo_mat_large 받침 (말이 도구, 음식 자체 아님). z=L2_BASE 최하단.
func _build_bamboo_mat_base() -> void:
	_mat_node2d = Node2D.new()
	_mat_node2d.z_index = L2_BASE
	_mat_node2d.position = Vector2(ROLL_X, ROLL_HERO_Y + 70.0)
	_mat_node2d.scale = Vector2(1.0, FRONTAL_SQUASH_Y)
	_mat_base_y = _mat_node2d.position.y
	add_child(_mat_node2d)
	var mat_path: String = ArtRegistry.get_roll_asset("bamboo_mat_large")
	if mat_path == "":
		mat_path = ArtRegistry.get_vessel("rolling_mat")   # graceful fallback
	if mat_path != "":
		var mat_tex := TextureRect.new()
		mat_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		mat_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		mat_tex.custom_minimum_size = Vector2.ZERO
		mat_tex.texture = load(mat_path)
		mat_tex.position = Vector2(-MAT_BOX_W * 0.5, -MAT_BOX_H * 0.5)
		mat_tex.size = Vector2(MAT_BOX_W, MAT_BOX_H)
		mat_tex.pivot_offset = Vector2(MAT_BOX_W * 0.5, MAT_BOX_H * 0.5)
		mat_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_mat_node2d.add_child(mat_tex)
		_mat = mat_tex
	else:
		var strip := ColorRect.new()
		strip.color = Color(0.78, 0.58, 0.30)
		strip.size = Vector2(MAT_BOX_W, MAT_BOX_H)
		strip.position = Vector2(-MAT_BOX_W * 0.5, -MAT_BOX_H * 0.5)
		strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var cols: int = 13
		for i in range(cols):
			var line := ColorRect.new()
			line.color = Color(0.62, 0.44, 0.22)
			line.size = Vector2(4, MAT_BOX_H)
			line.position = Vector2(float(i) * (MAT_BOX_W / float(cols)), 0)
			line.mouse_filter = Control.MOUSE_FILTER_IGNORE
			strip.add_child(line)
		_mat_node2d.add_child(strip)
		_mat = strip


# Layer 2~3 — 김(seaweed) → 밥(rice). 밥은 김 70~80% 얇게 균등, far edge(위) 김 노출(seal).
func _build_stage_layers(_food_id: StringName) -> void:
	_stage_group = Node2D.new()
	_stage_group.position = Vector2(ROLL_X, ROLL_HERO_Y + 70.0)
	_stage_group.scale = Vector2(1.0, FRONTAL_SQUASH_Y)
	_stage_group.z_index = L3_INGREDIENT
	_stage_base_y = _stage_group.position.y
	add_child(_stage_group)

	# 김 한 장.
	var sheet_w: float = SEAWEED_BOX_W
	var sheet_h: float = SEAWEED_BOX_H
	var seaweed_path: String = ArtRegistry.get_roll_asset("seaweed_sheet_rect")
	if seaweed_path == "":
		seaweed_path = ArtRegistry.get_roll_asset("seaweed_sheet")
	if seaweed_path != "":
		_seaweed = TextureRect.new()
		_seaweed.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_seaweed.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_seaweed.custom_minimum_size = Vector2.ZERO
		_seaweed.texture = load(seaweed_path)
		_seaweed.size = Vector2(sheet_w, sheet_h)
		_seaweed.position = Vector2(-sheet_w * 0.5, -sheet_h * 0.5)
		_seaweed.pivot_offset = Vector2(sheet_w * 0.5, sheet_h * 0.5)
		_seaweed.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_stage_group.add_child(_seaweed)
	else:
		var fb := ColorRect.new()
		fb.color = Color(0.16, 0.20, 0.14)
		fb.size = Vector2(sheet_w, sheet_h)
		fb.position = Vector2(-sheet_w * 0.5, -sheet_h * 0.5)
		fb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_stage_group.add_child(fb)
		_seaweed = null

	# 밥 — 김 70~80% 얇게 균등 spread, 중심 RICE_CENTER_Y로 내려 far edge(위) 김 노출(seal).
	var rice_w: float = RICE_BOX_W
	var rice_h: float = RICE_BOX_H
	var rice_path: String = ArtRegistry.get_roll_asset("rice_layer_flat_rect")
	if rice_path == "":
		rice_path = ArtRegistry.get_roll_asset("rice_layer_flat")
	if rice_path != "":
		_rice = TextureRect.new()
		_rice.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_rice.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_rice.custom_minimum_size = Vector2.ZERO
		_rice.texture = load(rice_path)
		_rice.size = Vector2(rice_w, rice_h)
		_rice.pivot_offset = Vector2(rice_w * 0.5, rice_h * 0.5)
		_rice.scale = Vector2(1.0, RICE_SQUASH_Y)
		_rice.position = Vector2(-rice_w * 0.5, RICE_CENTER_Y - rice_h * 0.5)
		_rice.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_stage_group.add_child(_rice)

	# swap 대상 — halfway / finished (처음엔 숨김).
	var swap_box: float = 470.0
	var halfway_path: String = ArtRegistry.get_roll_asset("gimbap_roll_halfway")
	if halfway_path != "":
		_halfway = TextureRect.new()
		_halfway.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_halfway.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_halfway.custom_minimum_size = Vector2.ZERO
		_halfway.texture = load(halfway_path)
		_halfway.size = Vector2(swap_box, swap_box)
		_halfway.position = Vector2(-swap_box * 0.5, -swap_box * 0.5)
		_halfway.pivot_offset = Vector2(swap_box * 0.5, swap_box * 0.5)
		_halfway.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_halfway.modulate = Color(1, 1, 1, 0.0)
		_halfway.z_index = 6
		_stage_group.add_child(_halfway)

	var finished_path: String = ArtRegistry.get_roll_asset("gimbap_roll_finished_content_only")
	if finished_path != "":
		_finished_roll = TextureRect.new()
		_finished_roll.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_finished_roll.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_finished_roll.custom_minimum_size = Vector2.ZERO
		_finished_roll.texture = load(finished_path)
		_finished_roll.size = Vector2(swap_box, swap_box)
		_finished_roll.position = Vector2(-swap_box * 0.5, -swap_box * 0.5)
		_finished_roll.pivot_offset = Vector2(swap_box * 0.5, swap_box * 0.5)
		_finished_roll.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_finished_roll.modulate = Color(1, 1, 1, 0.0)
		_finished_roll.visible = false
		_finished_roll.z_index = 8
		_stage_group.add_child(_finished_roll)


# Layer 4 — 속재료 평행 band (밥 lower-middle, 밥에 살짝 embedded, seaweed 하단 edge에 평행).
func _build_fillings(_food_id: StringName) -> void:
	var strips := [
		{"long": "egg_strip_long",    "old": "gimbap_filling_strip_egg",    "col": Color(0.97, 0.80, 0.26),
			"bw": 0.82, "bh": 0.24},
		{"long": "carrot_strip_long", "old": "gimbap_filling_strip_carrot", "col": Color(0.93, 0.52, 0.18),
			"bw": 0.76, "bh": 0.31},
		{"long": "green_strip_long",  "old": "gimbap_filling_strip_green",  "col": Color(0.36, 0.62, 0.24),
			"bw": 0.81, "bh": 0.25},
		{"long": "beef_strip_long",   "old": "",                            "col": Color(0.55, 0.32, 0.18),
			"bw": 0.89, "bh": 0.43},
	]
	var seaweed_vis_w: float = SEAWEED_BOX_W * 0.86
	var target_bar_w: float = STRIP_BAR_RATIO * seaweed_vis_w
	var aspect: float = 1024.0 / 1536.0
	var parent_node: Node = _stage_group if _stage_group != null else self

	var rows: Array = []
	for spec in strips:
		var bw_ratio: float = float(spec["bw"])
		var bh_ratio: float = float(spec["bh"])
		var box_w: float = target_bar_w / bw_ratio
		var box_h: float = box_w * aspect
		var bar_vis_h: float = box_h * bh_ratio * STRIP_SQUASH_Y
		rows.append({"spec": spec, "box_w": box_w, "box_h": box_h, "bar_h": bar_vis_h})

	var total_h: float = 0.0
	for r in rows:
		total_h += float(r["bar_h"])
	total_h -= STRIP_OVERLAP * float(rows.size() - 1)
	var cur_top: float = STRIP_BAND_CENTER_Y - total_h * 0.5

	for r in rows:
		var spec: Dictionary = r["spec"]
		var box_w: float = float(r["box_w"])
		var box_h: float = float(r["box_h"])
		var bar_h: float = float(r["bar_h"])
		var center_y: float = cur_top + bar_h * 0.5
		var node: Control
		var path: String = ArtRegistry.get_roll_asset(String(spec["long"]))
		if path == "" and String(spec["old"]) != "":
			path = ArtRegistry.get_roll_asset(String(spec["old"]))
		if path != "":
			var t := TextureRect.new()
			t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			t.custom_minimum_size = Vector2.ZERO
			t.texture = load(path)
			t.size = Vector2(box_w, box_h)
			t.pivot_offset = Vector2(box_w * 0.5, box_h * 0.5)
			t.scale = Vector2(1.0, STRIP_SQUASH_Y)
			node = t
			node.position = Vector2(-box_w * 0.5, center_y - box_h * 0.5)
		else:
			var c := ColorRect.new()
			c.color = spec["col"]
			c.size = Vector2(target_bar_w, maxf(bar_h, 30.0))
			node = c
			node.position = Vector2(-target_bar_w * 0.5, center_y - node.size.y * 0.5)
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		node.z_index = L3_INGREDIENT + 2   # 밥 위 (살짝 embedded — 밥이 둘레로 보임)
		parent_node.add_child(node)
		_fillings.append({"node": node, "base_y": center_y, "size": node.size})
		cur_top = center_y + bar_h * 0.5 - STRIP_OVERLAP


# Layer 5 — two-finger UI: 좌·우 원형 target + ghost finger + 위 화살표 2개 + balance meter.5
func _build_two_finger_ui() -> void:
	# 좌 target.
	_ui_left = _TouchTargetDraw.new()
	_ui_left.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ui_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_left.center = Vector2(ROLL_X - TOUCH_TARGET_OFFSET_X, TOUCH_TARGET_Y)
	_ui_left.radius = TOUCH_TARGET_R
	_ui_left.z_index = L5_VFX
	add_child(_ui_left)
	# 우 target.
	_ui_right = _TouchTargetDraw.new()
	_ui_right.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ui_right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_right.center = Vector2(ROLL_X + TOUCH_TARGET_OFFSET_X, TOUCH_TARGET_Y)
	_ui_right.radius = TOUCH_TARGET_R
	_ui_right.z_index = L5_VFX
	add_child(_ui_right)
	# 좌·우 balance meter (균등 push 여부).
	_balance_meter = _BalanceMeterDraw.new()
	_balance_meter.set_anchors_preset(Control.PRESET_FULL_RECT)
	_balance_meter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_balance_meter.bar_rect = Rect2(ROLL_X - 320.0, 1400.0, 640.0, 44.0)
	_balance_meter.z_index = L5_VFX
	add_child(_balance_meter)


func _build_progress_ui() -> void:
	_track = ColorRect.new()
	_track.color = Color(0, 0, 0, 0.12)
	_track.size = Vector2(640, 18)
	_track.position = Vector2(ROLL_X - 320.0, 1466.0)
	_track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_track)
	_fill_marker = ColorRect.new()
	_fill_marker.color = Color(0.30, 0.55, 0.30)
	_fill_marker.size = Vector2(8, 26)
	_fill_marker.position = Vector2(ROLL_X - 320.0 - 4.0, 1462.0)
	_fill_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fill_marker)


# =====================================================================================
# Two-finger multi-touch input — 좌·우 손가락 독립 추적 + desktop fallback.
# =====================================================================================

func _input(event: InputEvent) -> void:
	if _finished:
		return
	if event is InputEventScreenTouch:
		_handle_touch(event.index, event.position, event.pressed)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		_handle_drag(event.index, event.position)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		# DESKTOP fallback — 마우스 좌클릭 = 시작점이 속한 side를 잡고 드래그.
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_mouse_side = -1 if event.position.x < ROLL_X else 1
				_finger_down(_mouse_side, 900 + _mouse_side, event.position)
			elif _mouse_side != 0:
				_finger_up(900 + _mouse_side)
				_mouse_side = 0
	elif event is InputEventMouseMotion:
		if _mouse_side != 0:
			_finger_move(900 + _mouse_side, event.position)
	elif event is InputEventKey:
		# DESKTOP/test fallback — A/← = 좌손, D/→ = 우손 sim. push 진행을 매 hold로 누적.
		var pressed: bool = event.pressed and not event.echo
		var released: bool = not event.pressed
		if event.keycode == KEY_A or event.keycode == KEY_LEFT:
			if pressed: _kb_left_held = true
			elif released: _kb_left_held = false
		elif event.keycode == KEY_D or event.keycode == KEY_RIGHT:
			if pressed: _kb_right_held = true
			elif released: _kb_right_held = false


# touch index 라우팅 — 좌/우 slot에 배정 (multi-touch 독립 추적).
func _handle_touch(index: int, pos: Vector2, pressed: bool) -> void:
	if pressed:
		var side: int = -1 if pos.x < ROLL_X else 1
		_finger_down(side, index, pos)
	else:
		_finger_up(index)


func _handle_drag(index: int, pos: Vector2) -> void:
	_finger_move(index, pos)


# side(-1 좌 / +1 우)에 손가락을 등록. 이미 해당 side가 점유면 무시(같은 손가락 갱신).
func _finger_down(side: int, index: int, pos: Vector2) -> void:
	var now: float = float(Time.get_ticks_msec())
	if side < 0:
		_left_id = index
		_left_start_y = pos.y
		_left_last_y = pos.y
		_left_last_ms = now
		if is_instance_valid(_ui_left):
			_ui_left.touched = true
			_ui_left.finger_pos = pos
			_ui_left.queue_redraw()
	else:
		_right_id = index
		_right_start_y = pos.y
		_right_last_y = pos.y
		_right_last_ms = now
		if is_instance_valid(_ui_right):
			_ui_right.touched = true
			_ui_right.finger_pos = pos
			_ui_right.queue_redraw()
	_rolling = true


func _finger_up(index: int) -> void:
	var was_left: bool = index == _left_id
	var was_right: bool = index == _right_id
	if was_left:
		_left_id = -1
		if is_instance_valid(_ui_left):
			_ui_left.touched = false
			_ui_left.queue_redraw()
	if was_right:
		_right_id = -1
		if is_instance_valid(_ui_right):
			_ui_right.touched = false
			_ui_right.queue_redraw()
	# 두 손가락 모두 release되면 roll 마감(완성 판정).
	if _left_id == -1 and _right_id == -1 and _rolling:
		_rolling = false
		_finalize_roll()


func _finger_move(index: int, pos: Vector2) -> void:
	var now: float = float(Time.get_ticks_msec())
	if index == _left_id:
		var dt: float = maxf(now - _left_last_ms, 1.0) / 1000.0
		var dy: float = _left_last_y - pos.y          # 위로 이동 = 양수.
		_left_progress = clampf((_left_start_y - pos.y) / PUSH_DISTANCE, 0.0, 1.2)
		_last_left_speed = dy / dt
		_left_last_y = pos.y
		_left_last_ms = now
		if is_instance_valid(_ui_left):
			_ui_left.finger_pos = pos
			_ui_left.queue_redraw()
	elif index == _right_id:
		var dt2: float = maxf(now - _right_last_ms, 1.0) / 1000.0
		var dy2: float = _right_last_y - pos.y
		_right_progress = clampf((_right_start_y - pos.y) / PUSH_DISTANCE, 0.0, 1.2)
		_last_right_speed = dy2 / dt2
		_right_last_y = pos.y
		_right_last_ms = now
		if is_instance_valid(_ui_right):
			_ui_right.finger_pos = pos
			_ui_right.queue_redraw()
	else:
		return
	_sample_motion()
	_apply_roll_visual()
	_update_hint()


# keyboard hold sim (desktop/test) — A/D를 누르고 있으면 매 프레임 push 누적.
func _process(delta: float) -> void:
	if _finished:
		return
	var changed: bool = false
	if _kb_left_held:
		_left_progress = clampf(_left_progress + delta * 0.85, 0.0, 1.2)
		_rolling = true
		changed = true
		if is_instance_valid(_ui_left):
			_ui_left.touched = true
			_ui_left.queue_redraw()
	if _kb_right_held:
		_right_progress = clampf(_right_progress + delta * 0.85, 0.0, 1.2)
		_rolling = true
		changed = true
		if is_instance_valid(_ui_right):
			_ui_right.touched = true
			_ui_right.queue_redraw()
	if changed:
		_apply_roll_visual()
		_update_hint()


# smooth motion / pressure / 동시성 표본 누적.
func _sample_motion() -> void:
	_any_down_frames += 1
	if _left_id != -1 and _right_id != -1:
		_both_down_frames += 1
	# jitter = 양손 속도의 프레임 간 변동(절대값 합). 클수록 거친 동작.
	var jitter: float = absf(_last_left_speed - _last_right_speed)
	_speed_samples.append(jitter)
	if _speed_samples.size() > 240:
		_speed_samples.pop_front()


# =====================================================================================
# Roll visual — 두 손가락 push → curl → cylinder. uneven=crooked / weak=loose / strong=burst.
# =====================================================================================

func _apply_roll_visual() -> void:
	var avg_p: float = (_left_progress + _right_progress) * 0.5
	var roundness: float = clampf(avg_p, 0.0, 1.0)
	# tilt = 좌우 진행 차 (양수 = 좌가 빠름 → 왼쪽 기울기).
	# §8.3 arrange→roll: arrange 불균형이면 균등 push여도 tilt가 offset만큼 bias된다(비뚤어 보임).
	var tilt: float = (_left_progress - _right_progress) + _vs_tilt_offset * roundness
	# 김발 받침: near edge(하단)가 들리며 위로 말아 올림 + 균형에 따라 기울임.
	if is_instance_valid(_mat_node2d):
		_mat_node2d.position.y = _mat_base_y - roundness * 64.0
		_mat_node2d.rotation = -tilt * 0.34
	# stage group(김+밥+속): 말릴수록 가로폭 줄고(원통화) 위로 들림. tilt → 비뚤.
	if is_instance_valid(_stage_group):
		var base_sx: float = 1.0 - roundness * 0.42
		var base_sy: float = (1.0 + roundness * 0.10) * FRONTAL_SQUASH_Y
		_stage_group.scale = Vector2(base_sx, base_sy)
		_stage_group.rotation = -tilt * 0.40            # uneven → cylinder 비뚤/angled
		_stage_group.position.y = _stage_base_y - roundness * 44.0
		# pressure 과다(양손 모두 sweet 넘김) → 옆으로 부풀음(터짐 직전).
		if avg_p > 1.0:
			var over: float = clampf((avg_p - 1.0) / 0.2, 0.0, 1.0)
			_stage_group.scale = Vector2(base_sx + over * 0.16, base_sy + over * 0.12)
	# halfway swap — avg_p≥HALFWAY_SWAP_P이면 평평 layer를 반쯤 말린 sprite로 교체.
	if is_instance_valid(_halfway):
		var hf: float = clampf((avg_p - HALFWAY_SWAP_P) / maxf(1.0 - HALFWAY_SWAP_P, 0.01), 0.0, 1.0)
		_halfway.modulate.a = hf
		var flat_a: float = clampf(1.0 - hf, 0.0, 1.0)
		if is_instance_valid(_seaweed):
			_seaweed.modulate.a = clampf(flat_a + 0.15, 0.0, 1.0)
		if is_instance_valid(_rice):
			_rice.modulate.a = flat_a
	# 재료 strips — 말리며 안으로 빨려 들어감(투명화).
	for f in _fillings:
		var node: Control = f["node"]
		if not is_instance_valid(node):
			continue
		node.modulate.a = clampf(1.0 - roundness * 0.9, 0.05, 1.0)
	# balance meter / target UI 갱신.
	if is_instance_valid(_balance_meter):
		_balance_meter.left_p = _left_progress
		_balance_meter.right_p = _right_progress
		_balance_meter.queue_redraw()
	# target push 진행을 ghost ring으로 표시.
	if is_instance_valid(_ui_left):
		_ui_left.progress = clampf(_left_progress, 0.0, 1.0)
		_ui_left.queue_redraw()
	if is_instance_valid(_ui_right):
		_ui_right.progress = clampf(_right_progress, 0.0, 1.0)
		_ui_right.queue_redraw()
	# 진행 마커.
	if is_instance_valid(_fill_marker):
		_fill_marker.position.x = ROLL_X - 320.0 + roundness * 640.0 - 4.0


# 실시간 feedback message (요구 §6).
func _update_hint() -> void:
	if not is_instance_valid(_hint):
		return
	var avg_p: float = (_left_progress + _right_progress) * 0.5
	var diff: float = absf(_left_progress - _right_progress)
	var tilt_ratio: float = diff
	var both_down: bool = (_left_id != -1 or _kb_left_held) and (_right_id != -1 or _kb_right_held)
	var msg: String
	if not both_down and _rolling:
		msg = "Push both sides together"
	elif tilt_ratio > TILT_BAD:
		msg = "Too much left pressure" if _left_progress > _right_progress else "Too much right pressure"
	elif avg_p > 1.05:
		msg = "Too much pressure!" if diff < TILT_WARN else "Fillings squeezed out"
	elif tilt_ratio > TILT_WARN:
		msg = "Too much left pressure" if _left_progress > _right_progress else "Too much right pressure"
	elif avg_p < 0.35:
		msg = "Roll is loose"
	elif avg_p >= 0.78 and diff <= TILT_WARN:
		msg = "Tight roll!"
	elif diff <= TILT_WARN * 0.6 and avg_p >= 0.45:
		msg = "Perfect Balance!"
	else:
		msg = "Roll evenly from both edges"
	_hint.text = msg


# =====================================================================================
# NEW SCORING (40 balance / 25 pressure / 20 distance / 15 smooth) → [0,100].
# CONTRACT 보존: 0~100 → module_completed → prep factor.
# =====================================================================================

# _legacy_ignored: 구 dev shot 스크립트가 _finalize_roll(false)로 호출하던 잔재 호환(무시).
func _finalize_roll(_legacy_ignored: bool = false) -> void:
	var score: float = _compute_roll_score(_left_progress, _right_progress,
			_collect_pressure_metric(), _collect_smooth_metric())
	var j := RhythmJudge.PERFECT if score >= 80.0 else (RhythmJudge.GOOD if score >= 40.0 else RhythmJudge.MISS)
	_safe_feedback(j, Vector2(ROLL_X, 1000.0))

	var avg_p: float = (_left_progress + _right_progress) * 0.5
	# §8.3 arrange→roll: effective tilt = 좌우 차 + arrange bias offset.
	var diff: float = absf((_left_progress - _right_progress) + _vs_tilt_offset)
	# §8.2 prep→roll: sweet zone 좁아지면(_vs_sweet_scale<1) burst 임계가 내려오고 loose 임계가
	#   올라가 같은 push여도 더 쉽게 찢김/헐거움 판정 → "대충 썬 당근으로는 깔끔히 못 만다".
	var burst_thresh: float = lerpf(0.98, 1.05, _vs_sweet_scale)   # default 1.05
	var loose_thresh2: float = lerpf(0.62, 0.5, _vs_sweet_scale)   # default 0.5
	var burst: bool = avg_p > burst_thresh
	var crooked: bool = (diff / 1.0) > TILT_BAD
	var loose: bool = avg_p < loose_thresh2
	if is_instance_valid(_hint):
		if score >= 80.0:
			_hint.text = "Perfect Balance!"
		elif crooked:
			_hint.text = "Crooked roll - uneven push"
		elif burst:
			_hint.text = "Fillings squeezed out"
		elif loose:
			_hint.text = "Roll is loose"
		else:
			_hint.text = "Done"

	# 완성 김밥(content_only)은 SUCCESS에서만 (score≥60, 안 터짐, 안 비뚤).
	var well_rolled: bool = score >= 60.0 and not burst and not crooked
	if well_rolled and is_instance_valid(_finished_roll):
		_finished_roll.visible = true
		var fr_tw := _finished_roll.create_tween()
		fr_tw.tween_property(_finished_roll, "modulate:a", 1.0, 0.22)
		if is_instance_valid(_halfway):
			_halfway.create_tween().tween_property(_halfway, "modulate:a", 0.0, 0.18)
		if is_instance_valid(_seaweed):
			_seaweed.create_tween().tween_property(_seaweed, "modulate:a", 0.0, 0.18)
		if is_instance_valid(_rice):
			_rice.create_tween().tween_property(_rice, "modulate:a", 0.0, 0.18)
		for f in _fillings:
			var fn: Control = f["node"]
			if is_instance_valid(fn):
				fn.create_tween().tween_property(fn, "modulate:a", 0.0, 0.18)
	# stage group settle — 잘 말렸으면 똑바른 원통, 비뚤면 기울어진 채.
	if is_instance_valid(_stage_group):
		var tw := _stage_group.create_tween()
		tw.set_parallel(true)
		tw.tween_property(_stage_group, "scale", Vector2(0.92, 0.92 * FRONTAL_SQUASH_Y), 0.18)
		if well_rolled:
			tw.tween_property(_stage_group, "rotation", 0.0, 0.18)
	# 김발 받침 살짝 내리며 페이드 — 완성 roll이 위로 드러남.
	if is_instance_valid(_mat_node2d):
		var mat_tw := _mat_node2d.create_tween()
		mat_tw.set_parallel(true)
		mat_tw.tween_property(_mat_node2d, "position:y", _mat_base_y + 92.0, 0.32)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		if well_rolled:
			mat_tw.tween_property(_mat_node2d, "rotation", 0.0, 0.28)
		if is_instance_valid(_mat):
			mat_tw.tween_property(_mat, "modulate:a", 0.35, 0.30)
	# two-finger UI 페이드 (역할 종료).
	for ui in [_ui_left, _ui_right, _balance_meter]:
		if is_instance_valid(ui):
			ui.create_tween().tween_property(ui, "modulate:a", 0.0, 0.22)
	_finish(score)


# pressure consistency metric ∈ [0,1] — 양손 push가 얼마나 동시·꾸준했는지.
# 두 손가락이 동시에 눌린 비율(both/any)이 높을수록 일관(=1). pressure 부족/과다 보정은 score에서.
func _collect_pressure_metric() -> float:
	if _any_down_frames <= 0:
		return 0.0
	return clampf(float(_both_down_frames) / float(_any_down_frames), 0.0, 1.0)


# smooth motion metric ∈ [0,1] — 양손 속도 변동(jitter) 평균이 작을수록 매끄럽다(=1).
func _collect_smooth_metric() -> float:
	if _speed_samples.is_empty():
		return 0.5
	var s: float = 0.0
	for v in _speed_samples:
		s += float(v)
	var avg_jitter: float = s / float(_speed_samples.size())
	return clampf(1.0 - avg_jitter / SMOOTH_JITTER_REF, 0.0, 1.0)


# =====================================================================================
# Gimbap Vertical Slice consequence — prep_quality / arrange balance carry (design §8.2/§8.3).
# =====================================================================================

## runner가 넘긴 vs_quality_state를 읽어 sweet zone 폭(prep→roll) + tilt 기준(arrange→roll)을
## 보정한다. 일반 runner 호출(params에 vs_quality_state 없음)은 _vs_sweet_scale=1.0 유지 → 무영향.
##   §8.2 prep→roll: prep_quality 낮음(두꺼운 chunky strip) → 속이 고르게 안 깔려 sweet zone이
##     좁아짐(burst/loose 판정에 빠지기 쉬움). sweet_scale = lerp(0.62, 1.0, prep_quality).
##   §8.3 arrange→roll: arrange balance 낮음(filling 한쪽 몰림) → two-finger가 균등해도
##     cylinder가 비뚤어지는 쪽으로 bias. tilt_offset = (1 - balance) × sign.
func _consume_vs_consequence(params: Dictionary) -> void:
	if not params.has("vs_quality_state"):
		return
	var qs: Dictionary = params.get("vs_quality_state", {})
	if qs.is_empty():
		return
	_vs_active = true
	var prep_q: float = clampf(float(qs.get("prep_quality", 1.0)), 0.0, 1.0)
	# prep 나쁨 → sweet zone 좁아짐(0.62배). prep 좋음 → 기존(1.0배). casual 관대 band.
	_vs_sweet_scale = lerpf(0.62, 1.0, prep_q)
	# arrange balance(좌우 filling 대칭도) → tilt 기준점 offset. 없으면 0(영향 없음).
	var balance: float = clampf(float(qs.get("arrange_balance", 1.0)), 0.0, 1.0)
	var bias_dir: float = float(qs.get("arrange_bias_dir", 1.0))   # +1 = 좌측 쏠림 / -1 = 우측.
	_vs_tilt_offset = (1.0 - balance) * 0.34 * signf(bias_dir if bias_dir != 0.0 else 1.0)
	if is_instance_valid(_hint):
		if prep_q < 0.45:
			_hint.text = "Chunky filling - roll carefully"
	print("[roll-vs] prep_q=%.2f sweet_scale=%.2f arrange_bal=%.2f tilt_off=%.3f" % [
		prep_q, _vs_sweet_scale, balance, _vs_tilt_offset])


## §6.1 (새 공식) — roll 품질 → [0,100]. 인자로 받아 smoke test에서 직접 호출 가능.
##   left_p / right_p : 좌·우 손가락 forward 진행 (0~1.2).
##   pressure_metric  : 양손 동시성/일관성 [0,1] (= both/any down 비율).
##   smooth_metric    : 매끄러움 [0,1] (속도 변동 작을수록 1).
## 가중치: 40% balance / 25% pressure / 20% distance / 15% smooth.
##   - balance  = 1 - |left-right| 정규화 (좌우 movement difference 작을수록 1).
##   - pressure = pressure_metric을, sweet zone 누름이면 가산 (loose/burst 감점).
##   - distance = roll completion (sweet zone에 도달=1, under=비례 감소, over=감소).
##   - smooth   = smooth_metric.
## perfect = 균등 two-finger + 안정 pressure + full distance + no squeeze + clean cylinder.
func _compute_roll_score(left_p: float, right_p: float,
		pressure_metric: float, smooth_metric: float) -> float:
	var lp: float = clampf(left_p, 0.0, 1.2)
	var rp: float = clampf(right_p, 0.0, 1.2)
	var avg_p: float = (lp + rp) * 0.5

	# (1) balance 40% — 좌우 movement difference. diff를 PUSH 진행 스케일(1.0)로 정규화.
	#   §8.3 arrange→roll: arrange 불균형이면 균등 push여도 effective diff가 bias된다(비뚤어짐).
	var diff: float = absf(lp - rp) + absf(_vs_tilt_offset)
	var balance: float = clampf(1.0 - diff / 0.6, 0.0, 1.0)   # diff 0.6 이상이면 balance 0.

	# §8.2 prep→roll: sweet zone 폭 = _vs_sweet_scale 배(prep 나쁨 → 좁아짐). 중심(0.92)
	#   기준으로 lower/upper bound를 스케일. _vs_sweet_scale=1.0이면 기존(0.82~1.02) 동일.
	var sw_center: float = 0.92
	var sw_lo: float = sw_center - (sw_center - 0.82) * _vs_sweet_scale   # default 0.82
	var sw_hi: float = sw_center + (1.02 - sw_center) * _vs_sweet_scale   # default 1.02
	# pressure loose 임계(기본 0.5)도 prep 나쁨에 비례해 위로 당겨 약한 push가 더 쉽게 loose 처리.
	var loose_thresh: float = lerpf(0.62, 0.5, _vs_sweet_scale)

	# (3) roll completion distance 20% — sweet zone 도달=1, under 비례, over 감소.
	var distance: float
	if avg_p < sw_lo:
		distance = clampf(avg_p / maxf(sw_lo, 0.01), 0.0, 1.0)
	elif avg_p <= sw_hi:
		distance = 1.0
	else:
		distance = clampf(1.0 - (avg_p - sw_hi) / 0.18, 0.0, 1.0)

	# (2) pressure consistency 25% — 동시성(pressure_metric) × push 적정도.
	#   loose(avg_p 낮음) → 약한 pressure 감점, burst(avg_p>sw_hi) → 강한 pressure 감점.
	var push_quality: float
	if avg_p < loose_thresh:
		push_quality = clampf(avg_p / maxf(loose_thresh, 0.01), 0.0, 1.0)   # loose → 낮음.
	elif avg_p <= sw_hi:
		push_quality = 1.0
	else:
		push_quality = clampf(1.0 - (avg_p - sw_hi) / 0.15, 0.0, 1.0)       # burst → 낮음.
	var pressure: float = clampf(pressure_metric, 0.0, 1.0) * push_quality

	# (4) smooth motion 15%.
	var smooth: float = clampf(smooth_metric, 0.0, 1.0)

	var score: float = (balance * 40.0) + (pressure * 25.0) + (distance * 20.0) + (smooth * 15.0)
	return clampf(score, 0.0, 100.0)


# =====================================================================================
# Two-finger UI draw nodes — 원형 target + ghost finger marker + 위 화살표 + balance meter.
# =====================================================================================

## 좌/우 손가락 터치 target — 원형 target + ghost finger marker + 위 화살표 + push progress ring.
class _TouchTargetDraw extends Control:
	var center: Vector2 = Vector2.ZERO
	var radius: float = 64.0
	var touched: bool = false
	var finger_pos: Vector2 = Vector2.ZERO
	var progress: float = 0.0
	const COL_RING := Color(0.96, 0.62, 0.18, 0.95)     # 따뜻한 주황 (target)
	const COL_FILL := Color(0.98, 0.85, 0.55, 0.30)
	const COL_GHOST := Color(0.20, 0.14, 0.10, 0.55)    # ghost finger

	func _ready() -> void:
		queue_redraw()

	func _draw() -> void:
		# 원형 target (점선 느낌 = 흰 테두리 + 주황 ring).
		draw_circle(center, radius + 4.0, Color(1, 1, 1, 0.55))
		draw_circle(center, radius, COL_FILL)
		draw_arc(center, radius, 0.0, TAU, 48, COL_RING, 7.0, true)
		# push progress ring (진행만큼 위쪽으로 차오름).
		if progress > 0.0:
			draw_arc(center, radius - 2.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 48,
					Color(0.35, 0.62, 0.30, 0.95), 9.0, true)
		# 위 화살표 (각 side, "위로 밀어").
		var ax: float = center.x
		var ay0: float = center.y - radius - 18.0
		var ay1: float = center.y - radius - 96.0
		draw_line(Vector2(ax, ay0), Vector2(ax, ay1), Color(1, 1, 1, 0.85), 12.0, true)
		draw_line(Vector2(ax, ay0), Vector2(ax, ay1), COL_RING, 7.0, true)
		var tip := Vector2(ax, ay1)
		draw_colored_polygon(PackedVector2Array([
			tip + Vector2(0, -6), tip + Vector2(-24, 26), tip + Vector2(24, 26)]),
			Color(1, 1, 1, 0.9))
		draw_colored_polygon(PackedVector2Array([
			tip + Vector2(0, 2), tip + Vector2(-17, 24), tip + Vector2(17, 24)]),
			COL_RING)
		# ghost finger / hand marker — 두 손가락이 위로 미는 모습 (눌렸으면 실제 위치).
		var hand_c: Vector2 = finger_pos if touched else center
		draw_circle(hand_c, 30.0, COL_GHOST)
		draw_circle(hand_c, 30.0 if not touched else 34.0,
				Color(0.98, 0.80, 0.62, 0.45 if not touched else 0.85))
		draw_arc(hand_c, 30.0, 0.0, TAU, 32, Color(1, 1, 1, 0.7), 4.0, true)


## 좌·우 balance meter — 두 막대의 길이가 균등하면 초록(균형), 차이 크면 빨강(비뚤).
class _BalanceMeterDraw extends Control:
	var bar_rect: Rect2 = Rect2(0, 0, 640, 44)
	var left_p: float = 0.0
	var right_p: float = 0.0

	func _ready() -> void:
		queue_redraw()

	func _draw() -> void:
		# 중앙 분할 — 좌 막대는 중앙→왼쪽, 우 막대는 중앙→오른쪽으로 차오름.
		var cx: float = bar_rect.position.x + bar_rect.size.x * 0.5
		var top: float = bar_rect.position.y
		var h: float = bar_rect.size.y
		var half_w: float = bar_rect.size.x * 0.5
		# 배경 track.
		draw_rect(bar_rect, Color(0, 0, 0, 0.12), true)
		# balance 색 — 좌우 차가 작으면 초록, 크면 빨강.
		var diff: float = absf(left_p - right_p)
		var bad: float = clampf(diff / 0.4, 0.0, 1.0)
		var col := Color(0.35, 0.70, 0.34).lerp(Color(0.86, 0.28, 0.20), bad)
		# 좌 막대 (중앙에서 왼쪽으로).
		var lw: float = clampf(left_p, 0.0, 1.0) * half_w
		draw_rect(Rect2(cx - lw, top, lw, h), col, true)
		# 우 막대 (중앙에서 오른쪽으로).
		var rw: float = clampf(right_p, 0.0, 1.0) * half_w
		draw_rect(Rect2(cx, top, rw, h), col, true)
		# 중앙선.
		draw_line(Vector2(cx, top - 6), Vector2(cx, top + h + 6), Color(1, 1, 1, 0.85), 4.0)
		# 라벨 L / R.
		var font := ThemeDB.fallback_font
		draw_string(font, Vector2(bar_rect.position.x - 4, top + h + 36), "L",
				HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color(0.30, 0.20, 0.12))
		draw_string(font, Vector2(bar_rect.position.x + bar_rect.size.x - 18, top + h + 36), "R",
				HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color(0.30, 0.20, 0.12))
