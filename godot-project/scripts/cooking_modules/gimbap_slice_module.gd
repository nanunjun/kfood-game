## GimbapSliceModule — REAL gimbap 통썰기 (generic carrot-chopping Slice 대체, 2026-06-12).
##
## 사용자 거부 교정: 김밥 Slice가 generic slice_module(도마 위 당근 채썰기, 3/4 perspective)을
## 재사용해 "당근 써는 화면"으로 보였다. 실제 김밥 통썰기 = **완성 roll을 위에서 내려다본 가로
## cylinder**를 cut guide mark를 따라 **아래로 swipe → 한 조각씩 균일하게 분리 → 단면(cut-side)
## 노출**. 색-도마-당근이 아니라 "김밥을 일정 조각으로 자르는 중"이 즉시 읽혀야 한다.
##
## ── 시점 / 레이어 (strict top-down, 사선 0) ──────────────────────────────────────────
##   1. 완성 roll = top-down 가로 cylinder (gimbap_roll_finished_cylinder, near top-down)
##   2. roll 위 6개 cut guide mark (등간격 세로 점선 — 어디를 자를지 명확)
##   3. 각 guide를 따라 downward swipe → 한 조각씩 분리 → cut-side(단면) 이미지로
##      (단면 노출은 여기서 OK — slice가 단면을 만드는 단계).
##   4. 분리된 조각은 균일 크기로 아래 plate row에 가지런히 정렬.
##
## ── 입력 (downward swipe per guide) ─────────────────────────────────────────────────
## 가장 가까운 미절단 guide 위로 아래 방향 swipe = 그 자리 절단. guide 순서(왼→오) 무관하게
## 가장 가까운 guide를 자른다. 6 guide 전부 자르면 완료(6 조각).
##
## ── SCORING / CONSEQUENCE 보존 (slice_quality 출력 + §8.4 / §8.5 hook) ───────────────
## slice_quality ∈ [0,1] = 절단 위치 정확도(guide 근접) 0.5 + 조각 균일도(간격 일관) 0.35 +
##   swipe 직선도 0.15 → [0,100]로 module_completed(score) emit. runner가 이 score를
##   quality_state["slice_quality"]에 기록(§8.4 roll→slice 소비, §8.5 slice→plate 전달).
## §8.4 roll→slice: vs_quality_state.roll_quality를 읽어 cut window(guide 허용폭)를 보정한다.
##   loose/crooked roll(roll_q 낮음) → window 좁아짐 + 조각 wobble(제각각). tight roll → 넉넉.
extends "res://scripts/cooking_modules/base_module.gd"

const TouchGesture := preload("res://scripts/cooking_modules/touch_gesture.gd")

# --- top-down layout (화면 1080x1920) — strict top-down 가로 cylinder ---
# 완성 roll(가로 cylinder)을 action zone 중앙에 **크게** 눕힌다. 6 cut guide가 이 폭 안 등간격.
#
# OPEN-END PROMINENT (2026-06-13): gimbap_roll_for_slice 자산은 **왼쪽 끝이 열려 단면(밥 ring+속)
# 노출** 가로 통(1536x1024, aspect 1.5). 이전 ROLL_RECT(800x380, aspect 2.1)는 KEEP_ASPECT_CENTERED
# 라 height-limit → 통이 690px로 작게 letterbox되고 좌측 단면이 작고 어두워 잘 안 보였다.
# → ROLL_RECT를 자산 1.5 aspect에 맞춘 **큰 박스**로 키워 통이 action zone 가로를 가득 채우고
#    **양끝(특히 좌측 open 단면)이 화면에 크게 + crop 없이** 보이게 한다.
const ROLL_RECT := Rect2(60, 700, 960, 470)          # 가로 cylinder box (크게, action zone 가로 채움)
const CUT_COUNT: int = 6                              # 6개 cut guide → 6 조각.
# 분리된 조각(cut-side)이 가지런히 쌓이는 아래 plate row.
const PIECE_ZONE := Rect2(120, 1290, 840, 210)
const CROSS_MARGIN: float = 60.0                     # swipe 통과 판정 여유.

# guide 허용폭(px) — swipe x가 guide 중심에서 이 안이면 그 guide 절단. roll_quality로 보정.
const GUIDE_SNAP_PX: float = 90.0
const GUIDE_PERFECT_PX: float = 36.0                 # 이 안이면 위치 perfect.

# === §8.4 roll→slice consequence ===
# roll_quality(말기 품질) → cut window(guide 허용폭) + 조각 wobble. default 1.0 = 기존 난이도.
var _vs_window_scale: float = 1.0
var _vs_active: bool = false

# --- runtime ---
var _cuts_done: int = 0
var _cut_offsets: Array = []          # 각 절단의 guide 중심 기준 px 오차(위치 정확도).
var _cut_xs: Array = []               # 각 절단 x(조각 균일도 산정).
var _cut_straight: Array = []         # 각 swipe 직선도.
var _guides: Array = []               # 6 cut guide(절단되면 dim).
var _guide_cut: Array = []            # 각 guide 절단 여부.
var _roll_node: Control = null        # 완성 strict top-down 가로 cylinder (procedural).
var _pieces_holder: Control = null
var _knife = null                     # 손가락 따라오는 칼(top-down 세로날).
var _gesture = null
var _indicator: Label = null
var _hint: Label = null


func _module_start(params: Dictionary) -> void:
	_attach_cooking_bg(1000.0)
	_consume_vs_consequence(params)
	_cuts_done = 0
	_cut_offsets.clear()
	_cut_xs.clear()
	_cut_straight.clear()
	_guide_cut.clear()
	for i in range(CUT_COUNT):
		_guide_cut.append(false)

	_build_header("Slice", "Slice along the guide marks to make even pieces.")
	_build_instruction_band("Swipe down along each guide mark to cut a piece", "↓")

	# soft dish shadow (가로 cylinder 아래, 정하향).
	_attach_dish_shadow(Vector2(540, ROLL_RECT.position.y + ROLL_RECT.size.y + 6.0), 720.0)

	# Layer 1 — 완성 roll = top-down 가로 cylinder.
	_build_roll()
	# Layer 2 — 6 cut guide mark (등간격 세로 점선).
	_build_guides()
	# 분리된 조각 holder.
	_pieces_holder = Control.new()
	_pieces_holder.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pieces_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pieces_holder.z_index = L3_INGREDIENT + 2
	add_child(_pieces_holder)
	# plate row 캡션(어디로 조각이 모이는지).
	_build_piece_zone()
	# Layer 3 — top-down 세로날 칼(손가락 추적).
	_build_knife()

	# 진행 표시.
	_indicator = Label.new()
	_indicator.position = Vector2(40, 1166)
	_indicator.size = Vector2(1000, 60)
	_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_indicator.add_theme_font_size_override("font_size", 44)
	_indicator.add_theme_color_override("font_color", Color(0.95, 0.66, 0.22))
	_indicator.add_theme_color_override("font_outline_color", Color(0.25, 0.14, 0.05))
	_indicator.add_theme_constant_override("outline_size", 6)
	_indicator.z_index = L5_VFX
	add_child(_indicator)
	_update_indicator()

	# 실시간 hint.
	_hint = Label.new()
	_hint.position = Vector2(0, 1500)
	_hint.size = Vector2(1080, 60)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 36)
	_hint.add_theme_color_override("font_color", Color(0.30, 0.20, 0.12))
	_hint.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.85))
	_hint.add_theme_constant_override("outline_size", 6)
	_hint.text = "Cut along each guide for even pieces"
	add_child(_hint)

	# 입력 — downward swipe.
	_gesture = TouchGesture.new()
	_gesture.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_gesture)
	_gesture.drag_started.connect(_on_drag_started)
	_gesture.drag_updated.connect(_on_drag_updated)
	_gesture.drag_released.connect(_on_drag_released)


## §8.4 roll→slice — roll_quality를 읽어 cut window(guide 허용폭)를 보정. default 1.0 = 기존 난이도.
##   loose/crooked roll → window 좁아짐(0.6배): 같은 swipe라도 빡빡 + 조각 wobble.
func _consume_vs_consequence(params: Dictionary) -> void:
	if not params.has("vs_quality_state"):
		return
	var qs: Dictionary = params.get("vs_quality_state", {})
	if qs.is_empty():
		return
	var roll_q: float = clampf(float(qs.get("roll_quality", 1.0)), 0.0, 1.0)
	_vs_window_scale = lerpf(0.6, 1.0, roll_q)
	_vs_active = true
	print("[gimbap-slice-vs] roll_q=%.2f window_scale=%.2f" % [roll_q, _vs_window_scale])


# --- build ---

## Layer 1 — 완성 roll = STRICT top-down 가로 cylinder (procedural, 사선 0 보장).
##
## 사용자 거부 재교정 (2026-06-12): 기존엔 gimbap_roll_finished_cylinder sprite를 썼으나 그 AI 자산이
## oblique 3/4(통나무가 비스듬히 누워 end-cap 비침) 라서 "strict top-down + 사선 금지" 위반.
## → 완성 roll을 **procedural 가로 cylinder**(GimbapTopDownRoll Node2D)로 직접 그린다. 화면과 평행한
##    수평 직사각 + 둥근 양끝 + 위에서 본 김 표면(세로 light band)만 → 단면(end-cap) 절대 안 보임.
##    단면(spiral)은 자를 때 분리되는 조각(cut-side)에서만 노출(§slice 단계 OK).
func _build_roll() -> void:
	# PAINTERLY SWAP (2026-06-13): procedural 가로 capsule → gimbap_roll_for_slice (완성 roll,
	# high-angle painterly, **왼쪽 끝 open 단면(밥 ring+속) 노출** — slice가 더 자른다). 미존재 시 procedural.
	#
	# OPEN-END PROMINENT: 자산(1536x1024, aspect 1.5) 전체를 **크게 + crop 0**으로 보이게 한다.
	# display box = 자산 aspect(1.5)에 맞춰 ROLL_RECT보다 살짝 크게 잡아(가로 1020 → 세로 680) 통이
	# 화면 가로를 가득 채우고, ROLL_RECT 중심에 정렬해 **좌측 open 단면이 화면 안쪽에서 크게** 보인다.
	# KEEP_ASPECT_CENTERED라 어떤 박스에서도 좌우 끝은 절대 crop되지 않는다(letterbox만).
	var roll_path: String = ArtRegistry.get_painterly("gimbap_roll_for_slice")
	if roll_path != "":
		var rimg := TextureRect.new()
		rimg.name = "GimbapRollPainterly"
		rimg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rimg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rimg.texture = load(roll_path)
		# 자산 1.5 aspect에 맞춘 큰 display box (가로 1020). ROLL_RECT 중심에 정렬 → 통 크게, 양끝 full.
		var disp_w: float = 1020.0
		var disp_h: float = disp_w / 1.5            # = 680, aspect 정확히 일치 → 통이 박스를 가득 채움.
		var center: Vector2 = ROLL_RECT.position + ROLL_RECT.size * 0.5
		rimg.size = Vector2(disp_w, disp_h)
		rimg.position = center - Vector2(disp_w, disp_h) * 0.5
		rimg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rimg.z_index = L3_INGREDIENT
		add_child(rimg)
		_roll_node = rimg
		return
	var roll := _GimbapTopDownRoll.new()
	roll.name = "GimbapRoll"
	roll.setup(ROLL_RECT.size)
	roll.position = ROLL_RECT.position
	roll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	roll.z_index = L3_INGREDIENT
	add_child(roll)
	_roll_node = roll


# ── 강제 strict top-down 가로 cylinder (custom-draw, 사선/end-cap 0) ──────────────────────
# 화면 X축에 평행하게 누운 통김밥 — 위에서 똑바로 내려다본 모습. 둥근 양끝(반원) + 수평 본체.
# 김(dark) 표면 + 세로 길게 흐르는 sesame-oil sheen band(원기둥감 — 단면 아님). end-cap 0.
class _GimbapTopDownRoll extends Control:
	var _box: Vector2 = Vector2(800, 380)

	func setup(box: Vector2) -> void:
		_box = box
		size = box
		queue_redraw()

	func _draw() -> void:
		var w: float = _box.x
		var h: float = _box.y
		var r: float = h * 0.5
		var seaweed := Color(0.13, 0.17, 0.11)
		var seaweed_lo := Color(0.07, 0.10, 0.06)
		# contact shadow (정하향 — soft).
		draw_set_transform(Vector2(0, h * 0.5 + 14.0), 0.0, Vector2.ONE)
		_draw_capsule(w, h * 0.92, Color(0, 0, 0, 0.18))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		# body capsule (수평 직사각 + 둥근 양끝). 아래쪽 그림자 톤.
		_draw_capsule_at(Vector2(0, 0), w, h, seaweed_lo)
		_draw_capsule_at(Vector2(0, -4), w, h - 8.0, seaweed)
		# top-left key light — 위쪽 절반에 밝은 김 sheen (volumetric, 가로로 길게).
		var sheen := Color(0.26, 0.32, 0.22, 0.55)
		_draw_capsule_at(Vector2(0, -h * 0.22), w - 40.0, h * 0.34, sheen)
		# sesame-oil 가로 highlight 라인 (원기둥 위쪽 — 단면 아님, 길이 방향).
		var hi := Color(0.50, 0.56, 0.42, 0.42)
		draw_line(Vector2(r * 0.6, -h * 0.30), Vector2(w - r * 0.6, -h * 0.30), hi, 5.0, true)

	# (0,0)이 capsule 중심이 되도록 캡슐을 그린다 (rect는 좌상단 기준이라 중심 보정).
	func _draw_capsule_at(off: Vector2, cw: float, ch: float, col: Color) -> void:
		var cx: float = _box.x * 0.5 + off.x
		var cy: float = _box.y * 0.5 + off.y
		var r: float = ch * 0.5
		# 가운데 직사각.
		draw_rect(Rect2(cx - cw * 0.5 + r, cy - r, cw - 2.0 * r, ch), col)
		# 양끝 반원(둥근 끝 — 위에서 본 둥근 외피, end-cap 단면 아님).
		draw_circle(Vector2(cx - cw * 0.5 + r, cy), r, col)
		draw_circle(Vector2(cx + cw * 0.5 - r, cy), r, col)

	func _draw_capsule(cw: float, ch: float, col: Color) -> void:
		var cx: float = _box.x * 0.5
		var cy: float = 0.0
		var r: float = ch * 0.5
		draw_rect(Rect2(cx - cw * 0.5 + r, cy - r, cw - 2.0 * r, ch), col)
		draw_circle(Vector2(cx - cw * 0.5 + r, cy), r, col)
		draw_circle(Vector2(cx + cw * 0.5 - r, cy), r, col)


# ── 잘린 조각의 단면(spiral cross-section) — 둥근 정면 단면 (procedural, 균일) ──────────────
# 김(dark ring) 안 흰 밥 + 색색 속재료(단무지/시금치/당근/계란). 단면은 slice 단계에서만 OK.
# top-down 정면 원형 → 비스듬/perspective 0, 균일 크기. ArtRegistry GIMBAP_FILLINGS 색과 정합.
class _GimbapCutPiece extends Control:
	var _d: float = 118.0

	func setup(diam: float) -> void:
		_d = diam
		size = Vector2(diam, diam)
		queue_redraw()

	func _draw() -> void:
		var c: Vector2 = Vector2(_d, _d) * 0.5
		var r: float = _d * 0.5
		# 김 바깥 ring (dark green-black).
		draw_circle(c, r, Color(0.10, 0.13, 0.09))
		draw_circle(c, r - 6.0, Color(0.16, 0.21, 0.13))
		# 흰 밥 (속을 감싸는 ring).
		draw_circle(c, r - 12.0, Color(0.97, 0.95, 0.88))
		# 속재료 — danmuji 노랑 / spinach 녹 / carrot 주황 / egg 노랑(중앙 십자 배치).
		var fr: float = r * 0.40
		var cols := [
			Color(0.98, 0.82, 0.20),  # danmuji
			Color(0.24, 0.46, 0.18),  # spinach
			Color(0.93, 0.52, 0.18),  # carrot
			Color(0.97, 0.80, 0.26),  # egg
		]
		var positions := [
			c + Vector2(-fr * 0.6, -fr * 0.6), c + Vector2(fr * 0.6, -fr * 0.6),
			c + Vector2(-fr * 0.6, fr * 0.6), c + Vector2(fr * 0.6, fr * 0.6),
		]
		for i in range(4):
			draw_circle(positions[i], r * 0.20, cols[i])
		# 중앙 작은 밥 코어 + top-left sheen.
		draw_circle(c, r * 0.14, Color(0.99, 0.97, 0.90))
		draw_circle(c + Vector2(-r * 0.32, -r * 0.34), r * 0.18, Color(1, 1, 1, 0.12))


## Layer 2 — 6 cut guide mark — cylinder를 가로질러 등간격 세로 점선. 자르면 dim.
func _build_guides() -> void:
	_guides.clear()
	var holder := Control.new()
	holder.name = "CutGuides"
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.z_index = L4_TOOL - 1   # 칼 아래, roll 위.
	add_child(holder)
	# guide 세로 span = 화면에 보이는 김 본체 위 (큰 통 display: 세로 ~640~1180). 통 밖으로 안 넘치게.
	var gy0: float = 660.0
	var gy1: float = 1180.0
	for i in range(CUT_COUNT):
		var gx: float = _guide_x(i)
		var line := _make_dashed_guide(Vector2(gx, gy0), gy1 - gy0)
		holder.add_child(line)
		_guides.append(line)


## guide i 의 x — cylinder **세로 본체** 위 등간격. 6 guide = 6 균일 조각.
##
## OPEN-END (2026-06-13): gimbap_roll_for_slice 좌측 끝은 open 단면(밥 ring) — 자르는 대상이 아니라
## "이미 잘린 면" 참조다. guide는 **단면 오른쪽 김 본체** 위에만 둔다(단면 위에 점선 X). 자산 좌표로
## 단면 우측 끝(~asset x590) → display x≈420부터 김 본체(~display x960). x0를 이 본체 시작에 맞춘다.
func _guide_x(i: int) -> float:
	# display box(가로 1020, 자산 1.5 aspect, ROLL_RECT 중심 정렬) 기준 김 본체 가로 범위.
	var x0: float = 470.0    # 좌측 open 단면 바로 오른쪽 = 김 본체 시작.
	var x1: float = 950.0    # 통 우측 끝 살짝 안쪽.
	var t: float = (float(i) + 0.5) / float(CUT_COUNT)
	return lerpf(x0, x1, t)


## 얇은 세로 점선 guide 1개 — 고대비(흰 dash + 갈색 테두리)로 roll 위에서 또렷이.
func _make_dashed_guide(top: Vector2, height: float) -> Control:
	var line := Control.new()
	line.position = top
	line.size = Vector2(8, height)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var dash_h: float = 24.0
	var gap: float = 14.0
	var dash_w: float = 11.0
	var y: float = 0.0
	while y < height:
		var dash := Panel.new()
		dash.position = Vector2(-dash_w * 0.5, y)
		dash.size = Vector2(dash_w, dash_h)
		var dsb := StyleBoxFlat.new()
		dsb.bg_color = Color(1.0, 1.0, 0.94, 0.98)
		dsb.set_corner_radius_all(5)
		dsb.set_border_width_all(3)
		dsb.border_color = Color(0.20, 0.11, 0.04, 0.92)
		dash.add_theme_stylebox_override("panel", dsb)
		dash.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.add_child(dash)
		y += dash_h + gap
	return line


## 분리된 조각이 모이는 아래 plate row 캡션.
func _build_piece_zone() -> void:
	var tray := Panel.new()
	tray.name = "PieceTray"
	tray.position = PIECE_ZONE.position
	tray.size = PIECE_ZONE.size
	var tsb := StyleBoxFlat.new()
	tsb.bg_color = Color(0.27, 0.18, 0.10, 0.45)
	tsb.set_corner_radius_all(22)
	tsb.set_border_width_all(3)
	tsb.border_color = Color(0.95, 0.72, 0.30, 0.50)
	tray.add_theme_stylebox_override("panel", tsb)
	tray.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tray.z_index = L2_BASE + 1
	add_child(tray)
	var cap := Label.new()
	cap.text = "조각 · Pieces"
	cap.position = Vector2(18, 8)
	cap.size = Vector2(220, 30)
	cap.add_theme_font_size_override("font_size", 24)
	cap.add_theme_color_override("font_color", Color(1.0, 0.95, 0.82, 0.85))
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tray.add_child(cap)


## Layer 3 — top-down 세로날 칼(손가락 추적, blade 아래 = cutting edge).
func _build_knife() -> void:
	_knife = Node2D.new()
	_knife.name = "SliceKnife"
	_knife.z_index = L4_TOOL
	# PAINTERLY SWAP (2026-06-13): procedural Polygon2D 칼 → knife_topdown_painterly. blade 아래 향함.
	# swing(position:y tween)·손가락 추적 무변경. 미존재 시 아래 procedural 다각형 fallback.
	var knife_path: String = ArtRegistry.get_painterly("knife_topdown_painterly")
	if knife_path != "":
		var ksp := Sprite2D.new()
		ksp.texture = load(knife_path)
		var tex: Texture2D = ksp.texture
		var target_h: float = 430.0
		var sc: float = target_h / maxf(float(tex.get_height()), 1.0)
		ksp.scale = Vector2(sc, sc)
		ksp.centered = true
		ksp.offset = Vector2(0, -float(tex.get_height()) * 0.5 + 30.0)
		_knife.add_child(ksp)
		_knife.position = Vector2(_guide_x(0), ROLL_RECT.position.y - 120.0)
		add_child(_knife)
		return
	var handle := Polygon2D.new()
	handle.polygon = PackedVector2Array([
		Vector2(-28, -170), Vector2(28, -170), Vector2(26, -64), Vector2(-26, -64),
	])
	handle.color = Color(0.40, 0.24, 0.14)
	_knife.add_child(handle)
	var bolster := Polygon2D.new()
	bolster.polygon = PackedVector2Array([
		Vector2(-28, -68), Vector2(28, -68), Vector2(26, -46), Vector2(-26, -46),
	])
	bolster.color = Color(0.58, 0.60, 0.64)
	_knife.add_child(bolster)
	var blade := Polygon2D.new()
	blade.polygon = PackedVector2Array([
		Vector2(-24, -48), Vector2(24, -48), Vector2(24, 156),
		Vector2(0, 220), Vector2(-24, 156),
	])
	blade.color = Color(0.84, 0.87, 0.92)
	_knife.add_child(blade)
	var shine := Polygon2D.new()
	shine.polygon = PackedVector2Array([
		Vector2(8, -46), Vector2(22, -46), Vector2(22, 154), Vector2(2, 214),
	])
	shine.color = Color(0.97, 0.98, 1.0)
	_knife.add_child(shine)
	# 대기 위치 — cylinder 위(첫 guide). 시작부터 visible(무엇으로 무슨 action인지 즉시 인지).
	_knife.position = Vector2(_guide_x(0), ROLL_RECT.position.y - 120.0)
	add_child(_knife)


# --- input: downward swipe per guide ---

func _on_drag_started(pos: Vector2) -> void:
	if _finished:
		return
	if is_instance_valid(_knife):
		_knife.position = Vector2(pos.x, pos.y - 70.0)


func _on_drag_updated(pos: Vector2, _vel: Vector2) -> void:
	if _finished:
		return
	if is_instance_valid(_knife):
		_knife.position = Vector2(pos.x, pos.y - 70.0)


func _on_drag_released(info: Dictionary) -> void:
	if _finished:
		return
	# cylinder를 위→아래로 가로질렀는가?
	if not _crossed_roll(info):
		if is_instance_valid(_hint):
			_hint.text = "Swipe straight down through the roll ↓"
		return
	# 가장 가까운 미절단 guide를 찾는다.
	var mid_x: float = (float(info["start"].x) + float(info["end"].x)) * 0.5
	var best: int = _nearest_uncut_guide(mid_x)
	if best < 0:
		return
	var gx: float = _guide_x(best)
	var offset: float = absf(mid_x - gx)
	# window_scale<1(loose roll)이면 허용폭이 좁아진다(빡빡한 판정).
	var snap_px: float = GUIDE_SNAP_PX * _vs_window_scale
	if offset > snap_px:
		# guide에서 너무 벗어남 — 절단 미성립(retry 가능, 학습).
		if is_instance_valid(_hint):
			_hint.text = "Cut closer to a guide mark"
		_safe_feedback(RhythmJudge.MISS, info["end"])
		return
	_register_cut(best, offset, float(info.get("straightness", 1.0)), info["end"])


## cylinder를 위→아래로 가로질렀는지(swipe span이 roll 높이의 절반 이상 + x가 roll 폭 안).
func _crossed_roll(info: Dictionary) -> bool:
	var start: Vector2 = info["start"]
	var end: Vector2 = info["end"]
	var mid_x: float = (start.x + end.x) * 0.5
	var rx0: float = ROLL_RECT.position.x - CROSS_MARGIN
	var rx1: float = ROLL_RECT.position.x + ROLL_RECT.size.x + CROSS_MARGIN
	if mid_x < rx0 or mid_x > rx1:
		return false
	var vert_span: float = absf(end.y - start.y)
	return vert_span >= ROLL_RECT.size.y * 0.45


## 미절단 guide 중 mid_x에 가장 가까운 것. 전부 절단이면 -1.
func _nearest_uncut_guide(mid_x: float) -> int:
	var best: int = -1
	var best_d: float = 1e9
	for i in range(CUT_COUNT):
		if bool(_guide_cut[i]):
			continue
		var d: float = absf(mid_x - _guide_x(i))
		if d < best_d:
			best_d = d
			best = i
	return best


## 유효 절단 — 표본 누적 + 칼 swing + guide dim + 균일 조각(cut-side) 분리 + 진행 갱신.
func _register_cut(guide_idx: int, offset_px: float, straight: float, at: Vector2) -> void:
	_guide_cut[guide_idx] = true
	_cuts_done += 1
	var gx: float = _guide_x(guide_idx)
	_cut_offsets.append(offset_px)
	_cut_xs.append(gx)
	_cut_straight.append(clampf(straight, 0.0, 1.0))
	# guide dim.
	_dim_guide(guide_idx)
	# 칼 swing(위→아래) at guide.
	_swing_knife(gx)
	# 균일 조각(cut-side 단면) 1개 분리 → plate row에 가지런히.
	_spawn_piece(offset_px)
	# L5 VFX — cut spark at guide.
	CookingFX.slice_spark(self, Vector2(gx, ROLL_RECT.position.y + ROLL_RECT.size.y * 0.5), 90.0)
	var j := RhythmJudge.PERFECT if offset_px <= GUIDE_PERFECT_PX * _vs_window_scale else RhythmJudge.GOOD
	_safe_feedback(j, at)
	if is_instance_valid(_hint):
		_hint.text = "Even piece!" if j == RhythmJudge.PERFECT else "Good cut"
	_update_indicator()
	if _cuts_done >= CUT_COUNT:
		_finalize()


func _dim_guide(idx: int) -> void:
	if idx < _guides.size():
		var g: Control = _guides[idx]
		if is_instance_valid(g):
			var tw := g.create_tween()
			tw.tween_property(g, "modulate:a", 0.18, 0.16)


func _swing_knife(gx: float) -> void:
	if not is_instance_valid(_knife):
		return
	var rest_y: float = ROLL_RECT.position.y - 120.0
	var down_y: float = ROLL_RECT.position.y + ROLL_RECT.size.y * 0.5
	_knife.position.x = gx
	_knife.position.y = rest_y
	var tw: Tween = _knife.create_tween()
	tw.tween_property(_knife, "position:y", down_y, 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_interval(0.04)
	tw.tween_property(_knife, "position:y", rest_y, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


## 균일 조각(cut-side 단면) 1개를 plate row에 왼→오로 가지런히. loose roll이면 wobble(제각각).
##
## cut-side = 김밥 **단면(spiral cross-section)** — 자를 때 새로 생긴 절단면. 동그란 김 ring 안에
## 흰 밥 + 속재료(단무지 노랑/시금치 녹/당근 주황/계란 노랑)가 보인다. 단면 노출은 slice 단계 OK.
## 강제 strict top-down 일관 — 단면도 procedural(_GimbapCutPiece)로 그려 둥근 정면 단면을 보장한다
## (3/4 sprite로 조각이 비스듬해지는 것 방지). 균일 크기 → 균일도 점수와 시각이 일치.
func _spawn_piece(offset_px: float) -> void:
	if not is_instance_valid(_pieces_holder):
		return
	# wobble = loose roll(window_scale 낮음)일수록 조각이 제각각(위치/기울기/크기). tight이면 균일.
	var wobble: float = clampf(1.0 - _vs_window_scale, 0.0, 1.0) if _vs_active else 0.0
	# PAINTERLY SWAP (2026-06-13): cut 성공 조각 = gimbap_piece_good. **bad roll(roll_quality 낮음 →
	# wobble 큼) → gimbap_piece_collapse (filling 쏟아짐 — 텍스트 아닌 시각)**. 미존재 시 procedural.
	# §7.2: roll_quality가 낮으면 collapse variant → "loose하게 말아서 썰면 쏟아진다" 인과를 시각으로.
	# wobble = 1 - window_scale = 1 - lerp(0.6,1.0,roll_q). roll_q<=0.20이면 wobble>=0.32 → collapse.
	var collapse: bool = _vs_active and wobble >= 0.32
	var piece: Control = _make_painterly_piece(collapse)
	if piece == null:
		var pp := _GimbapCutPiece.new()
		pp.setup(118.0)
		pp.size = Vector2(118, 118)
		piece = pp
	piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var idx: int = _cuts_done - 1
	var slot_w: float = (PIECE_ZONE.size.x - 80.0) / float(CUT_COUNT)
	var px: float = PIECE_ZONE.position.x + 40.0 + float(idx) * slot_w + slot_w * 0.5 - piece.size.x * 0.5
	var py: float = PIECE_ZONE.position.y + PIECE_ZONE.size.y * 0.5 - piece.size.y * 0.5 + 16.0
	px += randf_range(-26.0, 26.0) * wobble
	py += randf_range(-18.0, 18.0) * wobble
	piece.position = Vector2(px, py - 36.0)
	if wobble > 0.05:
		piece.pivot_offset = piece.size * 0.5
		piece.rotation = deg_to_rad(randf_range(-20.0, 20.0) * wobble)
		var sj: float = 1.0 + randf_range(-0.20, 0.20) * wobble
		piece.scale = Vector2(sj, sj)
	piece.modulate = Color(1, 1, 1, 0.0)
	_pieces_holder.add_child(piece)
	var tw := piece.create_tween()
	tw.parallel().tween_property(piece, "position:y", py, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(piece, "modulate:a", 1.0, 0.18)


## PAINTERLY 조각 1개 — collapse=true면 gimbap_piece_collapse(filling 쏟아짐), false면 gimbap_piece_good.
## 미존재 시 null → caller가 procedural _GimbapCutPiece로 fallback. size = 118(균일도 점수와 정합).
func _make_painterly_piece(collapse: bool) -> Control:
	var key: String = "gimbap_piece_collapse" if collapse else "gimbap_piece_good"
	var path: String = ArtRegistry.get_painterly(key)
	if path == "":
		return null
	var tr := TextureRect.new()
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.texture = load(path)
	# collapse는 조금 더 크게(쏟아진 속이 단면 밖으로) — 시각 강조. good은 균일 118.
	var d: float = 150.0 if collapse else 118.0
	tr.size = Vector2(d, d)
	return tr


func _update_indicator() -> void:
	if not is_instance_valid(_indicator):
		return
	if _cuts_done >= CUT_COUNT:
		_indicator.text = "Sliced into even pieces!"
	else:
		_indicator.text = "통썰기  %d / %d" % [_cuts_done, CUT_COUNT]


# --- scoring: slice_quality [0,1] → [0,100] (CONTRACT 보존) ---
func _finalize() -> void:
	if is_instance_valid(_hint):
		_hint.text = "All sliced — even pieces!"
	# 남은 roll(잘린 본체)은 fade — 조각만 남는다.
	if is_instance_valid(_roll_node):
		var tw: Tween = _roll_node.create_tween()
		tw.tween_property(_roll_node, "modulate:a", 0.0, 0.25)
	# slice_quality = 위치 정확도 0.5 + 조각 균일도 0.35 + swipe 직선도 0.15.
	var pos_q: float = _position_quality()
	var even_q: float = _even_quality()
	var straight_q: float = _straight_quality()
	var slice_q: float = pos_q * 0.5 + even_q * 0.35 + straight_q * 0.15
	_finish(clampf(slice_q, 0.0, 1.0) * 100.0)


## 절단 위치 정확도 — 각 절단의 guide 근접도 평균(GUIDE_PERFECT 안=1, GUIDE_SNAP 밖=0).
func _position_quality() -> float:
	if _cut_offsets.is_empty():
		return 0.0
	var s: float = 0.0
	for off in _cut_offsets:
		var q: float = clampf(1.0 - (float(off) - GUIDE_PERFECT_PX) / maxf(GUIDE_SNAP_PX - GUIDE_PERFECT_PX, 1.0), 0.0, 1.0)
		s += q
	return s / float(_cut_offsets.size())


## 조각 균일도 — 절단 x의 등간격성(인접 절단 간격 변동이 작을수록 균일). guide 자체가 등간격이라
## 정확히 guide를 자르면 높고, 빗나가면 간격이 들쭉날쭉해 낮아진다.
func _even_quality() -> float:
	if _cut_xs.size() <= 1:
		return 1.0
	var xs: Array = _cut_xs.duplicate()
	xs.sort()
	var gaps: Array = []
	for i in range(1, xs.size()):
		gaps.append(float(xs[i]) - float(xs[i - 1]))
	var mean: float = 0.0
	for g in gaps:
		mean += float(g)
	mean /= float(gaps.size())
	if mean <= 0.001:
		return 0.5
	var var_sum: float = 0.0
	for g in gaps:
		var_sum += pow(float(g) - mean, 2.0)
	var sd: float = sqrt(var_sum / float(gaps.size()))
	var cv: float = sd / mean
	return clampf(1.0 - cv / 0.5, 0.0, 1.0)


## swipe 직선도 평균(곧게 내려그을수록 깔끔한 단면).
func _straight_quality() -> float:
	if _cut_straight.is_empty():
		return 1.0
	var s: float = 0.0
	for st in _cut_straight:
		s += float(st)
	return clampf(s / float(_cut_straight.size()), 0.0, 1.0)


# --- read-only getter (shot / test 검증용) ---
func get_slice_quality() -> float:
	return clampf(_position_quality() * 0.5 + _even_quality() * 0.35 + _straight_quality() * 0.15, 0.0, 1.0)
