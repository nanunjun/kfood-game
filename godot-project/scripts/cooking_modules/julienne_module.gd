## JulienneModule — Gimbap Vertical Slice Stage 2 (Preparation: 채썰기). RHYTHM SLICING rebuild.
##
## 김밥 vertical slice 전용 Prep stage. **사용자 승인 mechanic 전환(2026-06-12)**: 기존 free-drag
## 채썰기를 *리듬 슬라이싱 미니게임*으로 완전 재구축한다. 화면을 보자마자 "당근 채썰기"가 읽혀야 한다.
##
## RHYTHM SLICING REBUILD (Priority 1-6):
##   P1 ingredient grid 완전 숨김 — 중앙엔 도마/당근/칼/cut guide/rhythm UI/strip pile/progress만.
##   P2 strict top-down 도마(procedural flat, 사선 0) + 수평 당근 + 세로날 칼(beat마다 위→아래).
##   P3 6 vertical cut guide + beat marker가 target zone으로 이동 → 도착 시 tap/short-swipe-down →
##      성공 시 칼 내려와 당근 얇게 잘림 + carrot strip 1개. 판정 Perfect/Good/Miss.
##   P4 캐릭터 1개(runner mini) / basket overlap 회피(runner 영역).
##   P5 얇은 주황 matchstick strip 결과(round slice/whole carrot 금지).
##   P6 header 행동 중심 — "채썰기 / Julienne Carrot" + progress 작게 보조.
##
## SCORING CONTRACT 보존(무변경 의무):
##   - get_prep_quality() : prep_quality ∈ [0,1] (runner가 §8.2 prep→roll consequence + 준비20%에 사용).
##   - get_prep_dimensions() : 4축 [angle, rhythm, spacing, thickness] ∈ [0,1].
##   - _finish(prep_quality * 100.0) : base_module._finish → module_completed(score) emit.
##   - 부모 _consume_vs_consequence(params) : roll→slice는 julienne 미적용(통썰기만) — 그대로 호출.
##   내부 mechanic만 drag→rhythm-tap으로 변경. 출력 contract / 4축 / consequence hook 100% 동일.
##
## RHYTHM → prep_quality 매핑 (design §3.2 4축 보존, 입력 의미만 재해석):
##   beat 정확도(타이밍 offset) → rhythm/thickness/spacing/angle 4축으로 환산.
##   - rhythm    : tap 타이밍 offset 일관성(고른 박자) — _consistency_from_intervals(offsets).
##   - thickness : per-cut 타이밍 정확도 평균(정확할수록 얇고 균일한 strip).
##   - spacing   : Perfect/Good 비율(빗나간 cut 없이 등간격으로 썰림).
##   - angle     : 평균 cut 품질(칼이 곧게 내려옴 — rhythm tap이라 곧음은 정확도로 대표).
##   prep_quality = weighted_avg(angle 25% + rhythm 25% + spacing 25% + thickness 25%) ∈ [0,1].
extends "res://scripts/cooking_modules/slice_module.gd"

# F5 before/after 검증 전용 (gameplay 무관) — true면 Issue 2 수정 *전* 동작(carrot_strip_long
# sausage cylinder)을 재현해 before 스크린샷을 같은 코드 경로로 캡처한다. 기본 false(실제 게임).
static var shot_legacy_carrot: bool = false

# 4축 consistency 가중치 (design §3.2 — 각 25%). [SCORING CONTRACT — 무변경]
const W_ANGLE: float = 0.25
const W_RHYTHM: float = 0.25
const W_SPACING: float = 0.25
const W_THICKNESS: float = 0.25

# grade 임계 (prep_quality 0~1 기준). 시각 분기 + live label.
const GRADE_PERFECT: float = 0.80
const GRADE_GOOD: float = 0.55

# --- rhythm timing (per-cut judgement) ---
# beat marker가 target zone 중심에 도착하는 순간을 기준으로 tap offset(px)을 판정한다.
# target zone 폭 = GOOD 허용. zone 중심 ±PERFECT_HALF = Perfect.
const BEAT_PERIOD: float = 1.05            # 한 beat 주기(초) — marker가 왼→오 1회 통과.
const PERFECT_HALF_PX: float = 34.0        # target 중심 ±34px = Perfect(매우 얇은 균일 strip).
const GOOD_HALF_PX: float = 92.0           # target 중심 ±92px = Good. 그 밖 = Miss.

# --- top-down layout (화면 1080x1920) — strict top-down (사선 0) ---
# 도마(L2): action zone 중앙에 *수평 평면* 직사각(procedural — 3/4 sprite 금지). 화면 중앙 크게.
const TD_BOARD_RECT := Rect2(90, 640, 900, 540)
# 당근(L3): 도마 중앙에 가로로 길게 *수평* 눕힌다. 6 cut guide가 이 폭 안에 균등 배치.
# painterly carrot(carrot_on_board)을 더 크게 읽히게 height 확대(2026-06-13). guide x/scoring 무관(시각).
const TD_CARROT_RECT := Rect2(180, 786, 720, 330)
# 6개 cut guide(세로선) — 당근을 가로질러 등간격. 각 = 1 beat.
const TD_GUIDE_COUNT: int = 6
# 완료(채) 영역: 도마 아래 가로 row — 분리된 얇은 채가 왼→오로 깔끔히 쌓인다.
const TD_STRIP_ZONE := Rect2(150, 1210, 780, 100)
# rhythm track: 도마 위(헤더 아래) 가로 띠 — beat marker가 왼→오로 이동, target zone에 도착 시 tap.
const TD_TRACK_Y: float = 560.0
const TD_TRACK_X0: float = 250.0
const TD_TRACK_X1: float = 830.0
const TD_TARGET_X: float = 720.0           # target zone 중심 x (track 우측 — 진입→도착 read).
const TD_TARGET_HALF: float = 50.0         # target zone 반폭(시각). 판정은 PERFECT/GOOD_HALF_PX.

# --- per-cut 표본 (4축 산출용) — [SCORING] ---
var _cut_offsets: Array = []   # 각 성공 cut의 타이밍 offset(px, target 중심 기준 절대값).
var _cut_times_ms: Array = []  # 각 성공 cut release 시각(ms) — rhythm 일관성.
var _cut_grades: Array = []    # 각 cut grade(0=Miss 미기록, 100/60) — thickness 정확도.

# 산출된 4축 (0~1). _finalize에서 채운다. [SCORING CONTRACT — 무변경]
var prep_angle: float = 0.0
var prep_rhythm: float = 0.0
var prep_spacing: float = 0.0
var prep_thickness: float = 0.0
var prep_quality: float = 0.0

# --- top-down 전용 runtime 노드 ---
var _td_carrot: Control = null       # 당근 clip 컨테이너(썰릴수록 우측부터 짧아짐).
var _td_guides: Array = []           # 6 cut guide(절단되면 dim).
var _td_strip_holder: Control = null # 분리된 채가 쌓이는 아래 영역.
var _td_knife: Node2D = null         # 세로날 top-down 칼(beat마다 위→아래 내려옴).
var _knife_rest_y: float = 0.0       # 칼 대기 y(당근 위).
var _knife_busy: bool = false        # 칼 내려오는 애니 중(중복 입력 무시).

# --- rhythm marker ---
var _marker: Panel = null            # 이동하는 beat marker.
var _target_panel: Panel = null      # target zone(고정).
var _beat_t: float = 0.0             # marker 위상 시간 누적.
var _next_guide: int = 0             # 다음에 자를 guide index(왼→오).
var _live_lbl: Label = null          # live 판정 label("Perfect"/"Good"/"Miss").

# --- Done 버튼 ---
var _done_btn: Button = null


func _module_start(params: Dictionary) -> void:
	# 부모 SliceModule._module_start(사선 도마/대각 칼)을 *호출하지 않는다*. rhythm top-down view를
	# 직접 구성하고, scoring에 필요한 상태(_style/_cut_target/_consume_vs_consequence)만 세팅한다.
	_params = params
	_attach_cooking_bg(900.0)
	# 채썰기 = julienne style 고정 + cut 수 6(rhythm 표본). [SCORING — 무변경 상태]
	_style = CUT_STYLES["julienne"]
	_cut_target = int(params.get("tap_count", 6))
	_cuts_done = 0
	_cut_scores.clear()
	_consume_vs_consequence(params)   # [SCORING — 무변경] roll→slice는 julienne 미적용(통썰기만)

	# Issue 6 header (English-first) — "Step 2 of 7 — Julienne Carrot" + small subtitle.
	#   부모 _build_header(title, howto)는 "Step N/M · title — dish"로 표기. 한글 instruction 제거.
	_build_header("Julienne Carrot",
		"Cut thin strips with steady rhythm.")
	# Issue 3 instruction band — English-first 박자 안내 (한글 제거).
	_build_instruction_band(
		"Cut downward in a steady rhythm to make thin carrot strips.", "↓")

	# P1/P2 top-down 합성: 도마(procedural 평면) → 당근(수평) → 6 cut guide → strip 영역 →
	#   rhythm track(marker+target) → 세로날 칼.
	_build_topdown_board()
	_build_carrot()
	_build_guides()
	_build_strip_zone()
	_build_rhythm_track()
	_build_topdown_knife()

	# progress "채썰기 0/6" — Perfect/Good만 카운트. CONTROL band.
	_indicator = Label.new()
	_indicator.position = Vector2(40, 1330)
	_indicator.size = Vector2(1000, 56)
	_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_indicator.add_theme_font_size_override("font_size", 46)
	_indicator.add_theme_color_override("font_color", Color(0.97, 0.66, 0.24))
	_indicator.add_theme_color_override("font_outline_color", Color(0.25, 0.14, 0.05))
	_indicator.add_theme_constant_override("outline_size", 6)
	_indicator.z_index = L5_VFX
	add_child(_indicator)
	_update_indicator()

	# live 판정 label (Perfect/Good/Miss).
	_build_live_feedback()

	# 입력 인식기 — tap/short-swipe-down on beat. drag_released로 한 cut을 판정.
	# Issue 4 FIX (2026-06-12): _gesture(full-rect, MOUSE_FILTER_STOP + accept_event)를 Done 버튼보다
	#   *먼저* add_child 해 tree 순서상 아래(=GUI input 후순위)에 둔다. 이전엔 gesture가 Done 버튼
	#   *뒤에* 추가돼 full-screen STOP overlay가 버튼 탭을 가로채(_on_beat_input만 호출, button.pressed
	#   미발생) → 채썰기 6/6 후 Done을 눌러도 다음 step(Build)로 못 넘어가는 플레이어 trap이었다.
	#   이제 Done 버튼이 마지막 sibling이라 겹친 영역 탭은 버튼이 먼저 받는다.
	_gesture = TouchGesture.new()
	_gesture.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_gesture)
	_gesture.drag_released.connect(_on_beat_input)

	# Done 버튼 — 초기 disabled, 6/6에 enabled. gesture 위(마지막 child)라 탭을 직접 받는다.
	_build_done_button()


func _process(delta: float) -> void:
	if _finished:
		return
	# 모든 cut 완료 시 marker 정지(더 칠 게 없음).
	if _cuts_done >= _cut_target:
		if is_instance_valid(_marker):
			_marker.visible = false
		return
	# beat marker — 왼→오로 이동, target zone 통과 후 wrap. 차분한 한 박자.
	_beat_t += delta
	var phase: float = fmod(_beat_t, BEAT_PERIOD) / BEAT_PERIOD   # [0,1)
	if is_instance_valid(_marker):
		var mx: float = lerpf(TD_TRACK_X0, TD_TRACK_X1, phase)
		_marker.position.x = mx - _marker.size.x * 0.5
		# target zone 근처에서 marker 강조(approach pulse).
		var near: float = 1.0 - clampf(absf(mx - TD_TARGET_X) / 160.0, 0.0, 1.0)
		_marker.scale = Vector2(1.0 + near * 0.5, 1.0 + near * 0.5)
		_marker.pivot_offset = _marker.size * 0.5
	# target zone pulse(marker 도착 시점 강조).
	if is_instance_valid(_target_panel):
		var mx2: float = lerpf(TD_TRACK_X0, TD_TRACK_X1, phase)
		var hit_near: bool = absf(mx2 - TD_TARGET_X) <= GOOD_HALF_PX
		_target_panel.modulate = Color(1, 1, 1, 1.0) if hit_near else Color(1, 1, 1, 0.7)


# === 입력 → 한 cut 판정 (rhythm tap/short-swipe-down) ===

## tap 또는 short downward swipe = 한 박자 입력. marker가 target zone에 얼마나 가까웠는지로 판정.
## long drag/random drag 요구 안 함 — 손가락을 내리는 즉시 release 시 판정.
func _on_beat_input(info: Dictionary) -> void:
	if _finished or _knife_busy or _cuts_done >= _cut_target:
		return
	# down-swipe면 아래 방향이어야(위로 긋는 건 무시) — 순수 tap(거의 정지)도 허용.
	var start: Vector2 = info.get("start", Vector2.ZERO)
	var end: Vector2 = info.get("end", Vector2.ZERO)
	var dy: float = end.y - start.y
	var dist: float = float(info.get("distance", 0.0))
	# 위로 크게 그은 경우만 무시(아래 swipe 또는 tap만 유효).
	if dist > 70.0 and dy < -40.0:
		return
	# 현재 marker x — beat 위상으로 즉시 계산(노드 위치 의존 아님, 정밀).
	var phase: float = fmod(_beat_t, BEAT_PERIOD) / BEAT_PERIOD
	var marker_x: float = lerpf(TD_TRACK_X0, TD_TRACK_X1, phase)
	var offset: float = absf(marker_x - TD_TARGET_X)   # target 중심 기준 px 오차.

	if offset <= GOOD_HALF_PX:
		# Perfect 또는 Good — 유효 cut. 칼 내려오며 당근 한 칸 잘림 + strip 생성.
		var grade: int = RhythmJudge.PERFECT if offset <= PERFECT_HALF_PX else RhythmJudge.GOOD
		_register_cut(grade, offset)
	else:
		# Miss — progress 없음, strip 미생성, 흔들림.
		_register_miss()


## 유효 cut 기록 — 표본 누적 + 칼 swing + strip 생성 + guide dim + 진행 갱신.
func _register_cut(grade: int, offset_px: float) -> void:
	# 표본 (4축 산출). [SCORING]
	_cut_offsets.append(offset_px)
	_cut_times_ms.append(float(Time.get_ticks_msec()))
	var grade_val: float = 100.0 if grade == RhythmJudge.PERFECT else 60.0
	_cut_grades.append(grade_val)
	_cut_scores.append(grade_val)   # 부모 _cut_scores(angle 축 원천) 호환.
	_cuts_done += 1

	# 어느 guide를 자르는지(왼→오) — 칼 x를 그 guide에 맞춰 내려보낸다.
	var guide_x: float = _guide_x(_next_guide)
	_swing_knife(guide_x, grade)
	_dim_guide(_next_guide)
	_next_guide += 1
	# 당근을 한 칸 짧게(우측부터 잘려나감) — 시각적으로 strip이 떨어져 나간다.
	_shrink_carrot()
	# 얇은 채 1개 분리 → 아래 strip 영역에 누적.
	_spawn_strip(grade)
	# L5 VFX — cut spark at guide.
	CookingFX.slice_spark(self, Vector2(guide_x, TD_CARROT_RECT.position.y + TD_CARROT_RECT.size.y * 0.5), 90.0)
	# juice + live label.
	_safe_feedback(grade, Vector2(guide_x, TD_CARROT_RECT.position.y))
	_set_live(grade, offset_px)
	_update_indicator()
	if _cuts_done >= _cut_target:
		_on_all_cuts_done()


## Miss — progress 없음. 빗나간 cut 시각(칼 살짝 흔들림 + uneven hint) + Miss label.
func _register_miss() -> void:
	if is_instance_valid(_td_knife):
		var tw := _td_knife.create_tween()
		var ox: float = _td_knife.position.x
		tw.tween_property(_td_knife, "position:x", ox - 14.0, 0.05)
		tw.tween_property(_td_knife, "position:x", ox + 14.0, 0.06)
		tw.tween_property(_td_knife, "position:x", ox, 0.05)
	_set_live(RhythmJudge.MISS, 999.0)
	_safe_feedback(RhythmJudge.MISS, Vector2(TD_TARGET_X, TD_TRACK_Y))


# --- top-down 합성 build ---

## P2 도마 — strict top-down 평면 직사각(procedural). 3/4 sprite(handle/원근) 금지.
## 화면 중앙 크게, 수평. 부드러운 나무결 느낌 + soft drop shadow.
func _build_topdown_board() -> void:
	# soft dish shadow 먼저 (도마 아래 부드러운 타원, 모든 그림자 동일 방향=정하향).
	_attach_dish_shadow(Vector2(540, TD_BOARD_RECT.position.y + TD_BOARD_RECT.size.y + 12.0), 760.0)
	# PAINTERLY SWAP (2026-06-13): procedural Panel 도마 → board_topdown_painterly (나무 도마,
	# high-angle painterly). 미존재 시 기존 procedural Panel로 fallback. rhythm/scoring 무변경.
	var board_path: String = ArtRegistry.get_painterly("board_topdown_painterly")
	if board_path != "":
		var bimg := TextureRect.new()
		bimg.name = "TopdownBoardPainterly"
		bimg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bimg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		bimg.texture = load(board_path)
		# painterly 도마를 board rect보다 살짝 키워 화면 중앙을 따뜻하게 채운다.
		bimg.position = TD_BOARD_RECT.position - Vector2(40, 30)
		bimg.size = TD_BOARD_RECT.size + Vector2(80, 60)
		bimg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bimg.z_index = L2_BASE
		add_child(bimg)
		return
	var board := Panel.new()
	board.name = "TopdownBoard"
	board.position = TD_BOARD_RECT.position
	board.size = TD_BOARD_RECT.size
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.80, 0.62, 0.40)            # 따뜻한 나무판(평면).
	sb.set_corner_radius_all(46)
	sb.set_border_width_all(10)
	sb.border_color = Color(0.55, 0.38, 0.22)
	sb.shadow_size = 16
	sb.shadow_color = Color(0, 0, 0, 0.26)
	sb.shadow_offset = Vector2(0, 8)                 # 그림자 정하향(top-down 일관).
	board.add_theme_stylebox_override("panel", sb)
	board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board.z_index = L2_BASE
	add_child(board)
	# 가벼운 나무결 — 가로 줄 몇 개(평면 read 보강, 원근 0).
	for i in range(5):
		var grain := ColorRect.new()
		grain.color = Color(0.70, 0.52, 0.32, 0.35)
		grain.size = Vector2(TD_BOARD_RECT.size.x - 120.0, 4.0)
		grain.position = Vector2(60.0, 70.0 + float(i) * ((TD_BOARD_RECT.size.y - 140.0) / 4.0))
		grain.mouse_filter = Control.MOUSE_FILTER_IGNORE
		board.add_child(grain)


## P2/P5 당근 — 도마 중앙에 *수평*으로 길게. Issue 2 FIX (2026-06-12): carrot_strip_long(소시지/
## 오렌지 cylinder, 당근으로 안 읽힘) 대신 carrot_whole(타피어드 당근 + 녹색 꼭지)을 우선 사용해
## "당근"으로 즉시 인지되게 한다. carrot_whole 미존재 시에만 strip fallback. 썰릴수록 우측부터
## 짧아지도록 clip 컨테이너 안에 둔다.
func _build_carrot() -> void:
	# PAINTERLY SWAP (2026-06-13): carrot_on_board(도마 위 눕힌 당근, high-angle painterly) 우선 →
	# carrot_whole painterly → 기존 ingredient carrot_whole → strip fallback. rhythm/scoring 무변경.
	var carrot_path: String = ArtRegistry.get_painterly("carrot_on_board")
	if carrot_path == "":
		carrot_path = ArtRegistry.get_painterly("carrot_whole")
	if carrot_path == "":
		carrot_path = ArtRegistry.get_ingredient("carrot", "whole")
	if carrot_path == "":
		carrot_path = ArtRegistry.get_roll_asset("carrot_strip_long")
	# before 스크린샷 전용: legacy(carrot_strip_long + STRETCH_SCALE pill) 동작 재현.
	if shot_legacy_carrot:
		carrot_path = ArtRegistry.get_roll_asset("carrot_strip_long")
		_build_carrot_legacy(carrot_path)
		return
	# 당근 아래 soft 그림자(정하향).
	var sh := Panel.new()
	sh.name = "CarrotShadow"
	sh.position = Vector2(TD_CARROT_RECT.position.x + 10.0, TD_CARROT_RECT.position.y + TD_CARROT_RECT.size.y * 0.58)
	sh.size = Vector2(TD_CARROT_RECT.size.x - 20.0, TD_CARROT_RECT.size.y * 0.42)
	var shsb := StyleBoxFlat.new()
	shsb.bg_color = Color(0.10, 0.06, 0.03, 0.26)
	shsb.set_corner_radius_all(int(TD_CARROT_RECT.size.y * 0.21))
	shsb.shadow_size = 14
	shsb.shadow_color = Color(0.10, 0.06, 0.03, 0.18)
	sh.add_theme_stylebox_override("panel", shsb)
	sh.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sh.z_index = L3_INGREDIENT - 1
	add_child(sh)
	# clip 컨테이너 — _shrink_carrot이 size:x를 줄여 우측부터 잘려나가게.
	_td_carrot = Control.new()
	_td_carrot.name = "TopdownCarrotClip"
	_td_carrot.position = TD_CARROT_RECT.position
	_td_carrot.size = TD_CARROT_RECT.size
	_td_carrot.clip_contents = true
	_td_carrot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_td_carrot.z_index = L3_INGREDIENT
	add_child(_td_carrot)
	# Issue 2 FIX (2026-06-12): carrot_whole(타피어드 당근 + 녹색 꼭지)을 *aspect 보존*으로 깔아
	#   "당근"으로 또렷이 읽히게 한다. 이전엔 solid orange 둥근 막대(pill) 위에 texture를 STRETCH_SCALE로
	#   가득 덮어, 타피어드 당근이 균일한 주황 직사각/cylinder(=소시지)로 뭉개졌다. 이제 texture가 있으면
	#   pill body를 생략하고 carrot_whole을 KEEP_ASPECT_CENTERED로 표시 → 끝이 가늘어지는 당근 형태 유지.
	if carrot_path != "":
		var inner := TextureRect.new()
		inner.name = "CarrotTex"
		inner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		inner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED   # 타피어드 당근 형태 보존.
		inner.custom_minimum_size = Vector2.ZERO
		inner.texture = load(carrot_path)
		inner.position = Vector2(0, 0)
		inner.size = TD_CARROT_RECT.size
		inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_td_carrot.add_child(inner)
	else:
		# 폴백(당근 sprite 미존재) — 굵은 주황 둥근 막대 procedural body + 하이라이트.
		var body := Panel.new()
		body.name = "CarrotBody"
		body.position = Vector2(0, TD_CARROT_RECT.size.y * 0.12)
		body.size = Vector2(TD_CARROT_RECT.size.x, TD_CARROT_RECT.size.y * 0.76)
		var bsb := StyleBoxFlat.new()
		bsb.bg_color = Color(0.96, 0.50, 0.14)            # 진한 주황 당근.
		bsb.set_corner_radius_all(int(TD_CARROT_RECT.size.y * 0.38))
		bsb.set_border_width_all(5)
		bsb.border_color = Color(0.82, 0.38, 0.10)
		body.add_theme_stylebox_override("panel", bsb)
		body.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_td_carrot.add_child(body)
		var hl := ColorRect.new()
		hl.color = Color(1.0, 0.72, 0.36, 0.55)
		hl.position = Vector2(28, TD_CARROT_RECT.size.y * 0.22)
		hl.size = Vector2(TD_CARROT_RECT.size.x - 56.0, TD_CARROT_RECT.size.y * 0.16)
		hl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_td_carrot.add_child(hl)


## before 스크린샷 전용 — Issue 2 수정 *전* 동작(carrot_strip_long을 solid pill body 위에
## STRETCH_SCALE로 가득 덮어 균일 cylinder=소시지로 뭉개짐)을 재현한다. gameplay 무관(shot only).
func _build_carrot_legacy(carrot_path: String) -> void:
	var sh := Panel.new()
	sh.position = Vector2(TD_CARROT_RECT.position.x + 10.0, TD_CARROT_RECT.position.y + TD_CARROT_RECT.size.y * 0.58)
	sh.size = Vector2(TD_CARROT_RECT.size.x - 20.0, TD_CARROT_RECT.size.y * 0.42)
	var shsb := StyleBoxFlat.new()
	shsb.bg_color = Color(0.10, 0.06, 0.03, 0.26)
	shsb.set_corner_radius_all(int(TD_CARROT_RECT.size.y * 0.21))
	sh.add_theme_stylebox_override("panel", shsb)
	sh.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sh.z_index = L3_INGREDIENT - 1
	add_child(sh)
	_td_carrot = Control.new()
	_td_carrot.position = TD_CARROT_RECT.position
	_td_carrot.size = TD_CARROT_RECT.size
	_td_carrot.clip_contents = true
	_td_carrot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_td_carrot.z_index = L3_INGREDIENT
	add_child(_td_carrot)
	var body := Panel.new()
	body.position = Vector2(0, TD_CARROT_RECT.size.y * 0.12)
	body.size = Vector2(TD_CARROT_RECT.size.x, TD_CARROT_RECT.size.y * 0.76)
	var bsb := StyleBoxFlat.new()
	bsb.bg_color = Color(0.96, 0.50, 0.14)
	bsb.set_corner_radius_all(int(TD_CARROT_RECT.size.y * 0.38))
	bsb.set_border_width_all(5)
	bsb.border_color = Color(0.82, 0.38, 0.10)
	body.add_theme_stylebox_override("panel", bsb)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_td_carrot.add_child(body)
	if carrot_path != "":
		var inner := TextureRect.new()
		inner.texture = load(carrot_path)
		inner.position = Vector2(0, TD_CARROT_RECT.size.y * 0.06)
		inner.size = Vector2(TD_CARROT_RECT.size.x, TD_CARROT_RECT.size.y * 0.88)
		inner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		inner.stretch_mode = TextureRect.STRETCH_SCALE
		inner.modulate = Color(1.06, 1.0, 0.96, 0.92)
		inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_td_carrot.add_child(inner)


## P3 6 cut guide — 당근을 가로질러 등간격 세로 점선. 각 = 1 beat. 자르면 dim.
func _build_guides() -> void:
	_td_guides.clear()
	var holder := Control.new()
	holder.name = "GuideHolder"
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.z_index = L4_TOOL - 1   # 칼 아래, 당근 위.
	add_child(holder)
	var gy0: float = TD_CARROT_RECT.position.y - 16.0
	var gy1: float = TD_CARROT_RECT.position.y + TD_CARROT_RECT.size.y + 16.0
	for i in range(TD_GUIDE_COUNT):
		var gx: float = _guide_x(i)
		var line := _make_dashed_guide(Vector2(gx, gy0), gy1 - gy0)
		holder.add_child(line)
		_td_guides.append(line)


## guide i 의 x 좌표 (당근 폭 안 등간격, 첫/끝 여백).
func _guide_x(i: int) -> float:
	var cx0: float = TD_CARROT_RECT.position.x + 56.0
	var cx1: float = TD_CARROT_RECT.position.x + TD_CARROT_RECT.size.x - 56.0
	var t: float = float(i) / float(TD_GUIDE_COUNT - 1)
	return lerpf(cx0, cx1, t)


## 얇은 세로 점선 가이드 1개.
func _make_dashed_guide(top: Vector2, height: float) -> Control:
	var line := Control.new()
	line.position = top
	line.size = Vector2(8, height)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var dash_h: float = 22.0
	var gap: float = 12.0
	var dash_w: float = 10.0
	var y: float = 0.0
	while y < height:
		var dash := Panel.new()
		dash.position = Vector2(-dash_w * 0.5, y)
		dash.size = Vector2(dash_w, dash_h)
		var dsb := StyleBoxFlat.new()
		# 흰 dash + 짙은 갈색 두꺼운 테두리 — 굵은 주황 당근 위에서도 고대비로 또렷이.
		dsb.bg_color = Color(1.0, 1.0, 0.96, 0.98)
		dsb.set_corner_radius_all(5)
		dsb.set_border_width_all(3)
		dsb.border_color = Color(0.22, 0.12, 0.05, 0.92)
		dash.add_theme_stylebox_override("panel", dsb)
		dash.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.add_child(dash)
		y += dash_h + gap
	return line


## 자른 guide를 dim.
func _dim_guide(idx: int) -> void:
	if idx < _td_guides.size():
		var g: Control = _td_guides[idx]
		if is_instance_valid(g):
			var tw := g.create_tween()
			tw.tween_property(g, "modulate:a", 0.20, 0.18)


## P5 아래 완료 영역 — 분리된 얇은 채가 왼→오로 쌓이는 trough.
func _build_strip_zone() -> void:
	var tray := Panel.new()
	tray.name = "StripTray"
	tray.position = TD_STRIP_ZONE.position
	tray.size = TD_STRIP_ZONE.size
	var tsb := StyleBoxFlat.new()
	tsb.bg_color = Color(0.27, 0.18, 0.10, 0.55)
	tsb.set_corner_radius_all(20)
	tsb.set_border_width_all(3)
	tsb.border_color = Color(0.95, 0.72, 0.30, 0.55)
	tray.add_theme_stylebox_override("panel", tsb)
	tray.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tray.z_index = L2_BASE + 1
	add_child(tray)
	var cap := Label.new()
	cap.text = "Strips"
	cap.position = Vector2(16, TD_STRIP_ZONE.size.y * 0.5 - 16.0)
	cap.size = Vector2(150, 32)
	cap.add_theme_font_size_override("font_size", 24)
	cap.add_theme_color_override("font_color", Color(1.0, 0.95, 0.82, 0.85))
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tray.add_child(cap)
	_td_strip_holder = Control.new()
	_td_strip_holder.name = "StripHolder"
	_td_strip_holder.set_anchors_preset(Control.PRESET_FULL_RECT)
	_td_strip_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_td_strip_holder.z_index = L3_INGREDIENT + 1
	add_child(_td_strip_holder)


## P3 rhythm track — 당근 위 가로 띠. beat marker(이동) + target zone(고정).
func _build_rhythm_track() -> void:
	var holder := Control.new()
	holder.name = "RhythmTrack"
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.z_index = L5_VFX - 1
	add_child(holder)
	# track 베이스 라인.
	var rail := Panel.new()
	rail.position = Vector2(TD_TRACK_X0 - 20.0, TD_TRACK_Y - 8.0)
	rail.size = Vector2(TD_TRACK_X1 - TD_TRACK_X0 + 40.0, 16.0)
	var rsb := StyleBoxFlat.new()
	rsb.bg_color = Color(0.30, 0.20, 0.12, 0.55)
	rsb.set_corner_radius_all(8)
	rail.add_theme_stylebox_override("panel", rsb)
	rail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(rail)
	# target zone(고정) — marker가 여기 도착할 때 tap.
	_target_panel = Panel.new()
	_target_panel.position = Vector2(TD_TARGET_X - TD_TARGET_HALF, TD_TRACK_Y - 34.0)
	_target_panel.size = Vector2(TD_TARGET_HALF * 2.0, 68.0)
	var gsb := StyleBoxFlat.new()
	gsb.bg_color = Color(0.45, 0.85, 0.45, 0.28)
	gsb.set_corner_radius_all(14)
	gsb.set_border_width_all(4)
	gsb.border_color = Color(0.50, 0.92, 0.50, 0.95)
	_target_panel.add_theme_stylebox_override("panel", gsb)
	_target_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(_target_panel)
	# "TAP" 힌트.
	var hint := Label.new()
	hint.text = "TAP"
	hint.position = Vector2(TD_TARGET_X - 40.0, TD_TRACK_Y - 78.0)
	hint.size = Vector2(80, 32)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 26)
	hint.add_theme_color_override("font_color", Color(0.55, 0.92, 0.55))
	hint.add_theme_color_override("font_outline_color", Color(0.10, 0.20, 0.08))
	hint.add_theme_constant_override("outline_size", 3)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(hint)
	# 이동 marker.
	_marker = Panel.new()
	_marker.size = Vector2(40, 52)
	_marker.position = Vector2(TD_TRACK_X0 - 20.0, TD_TRACK_Y - 26.0)
	var msb := StyleBoxFlat.new()
	msb.bg_color = Color(0.99, 0.78, 0.30)
	msb.set_corner_radius_all(10)
	msb.set_border_width_all(3)
	msb.border_color = Color(0.55, 0.32, 0.08)
	msb.shadow_size = 6
	msb.shadow_color = Color(0, 0, 0, 0.30)
	_marker.add_theme_stylebox_override("panel", msb)
	_marker.pivot_offset = _marker.size * 0.5
	_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(_marker)


## P2 top-down 칼 — **blade 세로 방향**(blade 아래=cutting edge, handle 위). beat마다 위→아래로
## 내려와 자른다. 모든 cut에서 수직 유지(사선 금지). knife_topdown.png는 사선 측면도라 top-down
## read가 약함 → procedural 세로날 식칼을 그린다(blade가 곧게 아래를 향함, 한눈에 "위에서 본 칼").
func _build_topdown_knife() -> void:
	_td_knife = Node2D.new()
	_td_knife.name = "TopdownKnife"
	_td_knife.z_index = L4_TOOL
	# PAINTERLY SWAP (2026-06-13): procedural Polygon2D 칼 → knife_topdown_painterly (윤기 식칼).
	# blade tip이 아래(cutting edge)를 향하게 sprite를 배치. swing 로직(position:x/y tween)은 무변경.
	# 미존재 시 아래 procedural 다각형 칼로 fallback.
	var knife_path: String = ArtRegistry.get_painterly("knife_topdown_painterly")
	if knife_path != "":
		var ksp := Sprite2D.new()
		ksp.texture = load(knife_path)
		var tex: Texture2D = ksp.texture
		# blade 아래 향함 — sprite 높이 기준 위쪽 handle, 아래쪽 blade tip. 원점(0,0)이 blade tip 근처가
		# 되도록 위로 offset (Node2D position = blade가 닿는 지점). 적당 스케일로 식칼 크기 맞춤.
		var target_h: float = 420.0
		var sc: float = target_h / maxf(float(tex.get_height()), 1.0)
		ksp.scale = Vector2(sc, sc)
		ksp.offset = Vector2(0, -float(tex.get_height()) * 0.5 + 30.0)
		ksp.centered = true
		_td_knife.add_child(ksp)
		_knife_rest_y = TD_CARROT_RECT.position.y - 150.0
		_td_knife.position = Vector2(_guide_x(0), _knife_rest_y)
		add_child(_td_knife)
		return
	# handle(위) — 나무 손잡이.
	var handle := Polygon2D.new()
	handle.polygon = PackedVector2Array([
		Vector2(-30, -180), Vector2(30, -180), Vector2(28, -68), Vector2(-28, -68),
	])
	handle.color = Color(0.40, 0.24, 0.14)
	_td_knife.add_child(handle)
	# handle 리벳(디테일).
	for ry in [-150.0, -110.0]:
		var rivet := Polygon2D.new()
		var r: float = 7.0
		var pts := PackedVector2Array()
		for a in range(10):
			var t: float = float(a) / 10.0 * TAU
			pts.append(Vector2(cos(t), sin(t)) * r + Vector2(0, ry))
		rivet.polygon = pts
		rivet.color = Color(0.72, 0.62, 0.50)
		_td_knife.add_child(rivet)
	# bolster(손잡이↔날 연결).
	var bolster := Polygon2D.new()
	bolster.polygon = PackedVector2Array([
		Vector2(-30, -72), Vector2(30, -72), Vector2(28, -50), Vector2(-28, -50),
	])
	bolster.color = Color(0.58, 0.60, 0.64)
	_td_knife.add_child(bolster)
	# blade(아래로 곧게 — cutting edge 세로). 끝이 뾰족.
	var blade := Polygon2D.new()
	blade.polygon = PackedVector2Array([
		Vector2(-26, -52), Vector2(26, -52), Vector2(26, 150),
		Vector2(0, 214), Vector2(-26, 150),
	])
	blade.color = Color(0.84, 0.87, 0.92)
	_td_knife.add_child(blade)
	# blade 하이라이트(날 광택, 한쪽).
	var shine := Polygon2D.new()
	shine.polygon = PackedVector2Array([
		Vector2(10, -50), Vector2(24, -50), Vector2(24, 148), Vector2(2, 208),
	])
	shine.color = Color(0.97, 0.98, 1.0)
	_td_knife.add_child(shine)
	# 칼 그림자(정하향 — top-down 일관).
	var shadow := Polygon2D.new()
	shadow.polygon = PackedVector2Array([
		Vector2(-22, -48), Vector2(30, -48), Vector2(30, 154), Vector2(4, 218), Vector2(-18, 154),
	])
	shadow.color = Color(0, 0, 0, 0.18)
	shadow.position = Vector2(8, 8)
	_td_knife.add_child(shadow)
	_td_knife.move_child(shadow, 0)   # 맨 뒤로.
	# 대기 위치 — 당근 위, 도마 상단 안쪽(rhythm track 아래). beat마다 이 자리로 돌아온다.
	_knife_rest_y = TD_CARROT_RECT.position.y - 150.0
	_td_knife.position = Vector2(_guide_x(0), _knife_rest_y)
	add_child(_td_knife)


## beat 성공 시 — 칼이 해당 guide x로 이동 후 위→아래로 내려와 자르고 다시 올라온다.
func _swing_knife(guide_x: float, grade: int) -> void:
	if not is_instance_valid(_td_knife):
		return
	_knife_busy = true
	var down_y: float = TD_CARROT_RECT.position.y + TD_CARROT_RECT.size.y * 0.5
	_td_knife.position.x = guide_x
	_td_knife.position.y = _knife_rest_y
	var tw := _td_knife.create_tween()
	# 내려옴(빠르게) → 살짝 멈춤 → 올라옴.
	tw.tween_property(_td_knife, "position:y", down_y, 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_interval(0.05)
	tw.tween_property(_td_knife, "position:y", _knife_rest_y, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func(): _knife_busy = false)


## 당근을 한 칸 짧게(우측부터) — strip이 떨어져 나간 read. 마지막까지 일부 남겨 "썰리는 중".
func _shrink_carrot() -> void:
	if not is_instance_valid(_td_carrot):
		return
	var prog: float = float(_cuts_done) / float(maxi(1, _cut_target))
	var remain: float = clampf(1.0 - prog * 0.62, 0.36, 1.0)
	var tw := _td_carrot.create_tween()
	tw.tween_property(_td_carrot, "size:x", TD_CARROT_RECT.size.x * remain, 0.16)


## P5 얇은 carrot strip(채) 1개를 아래 영역에 왼→오로 쌓는다. Issue 2 FIX (2026-06-12): 채썰기 결과는
## carrot_julienne(얇은 채)를 우선 사용 — carrot_strip_long(굵은 소시지형)은 "채"로 안 읽힌다.
func _spawn_strip(grade: int) -> void:
	if not is_instance_valid(_td_strip_holder):
		return
	# per-cut 얇은 채 strip은 ingredient carrot_julienne(thin) 우선 — painterly pile(carrot_strips_*)은
	# 통째 더미라 per-strip texture로는 부적합. 최종 painterly 결과 pile은 _apply_grade_visual에서 swap.
	var strip: Control
	var strip_path: String = ArtRegistry.get_ingredient("carrot", "julienne")
	if strip_path == "":
		strip_path = ArtRegistry.get_roll_asset("carrot_strip_long")
	# Perfect = 매우 얇은 균일 strip / Good = 약간 두꺼운 strip(시각 분기).
	var thin: float = 18.0 if grade == RhythmJudge.PERFECT else 26.0
	if strip_path != "":
		var t := TextureRect.new()
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_SCALE
		t.custom_minimum_size = Vector2.ZERO
		t.texture = load(strip_path)
		t.size = Vector2(108, thin)
		t.modulate = Color(1.12, 1.06, 1.0)
		strip = t
	else:
		var c := ColorRect.new()
		c.color = Color(0.95, 0.58, 0.22)
		c.size = Vector2(108, thin)
		strip = c
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# strip 영역(local 좌표)에 왼→오로 누적.
	var idx: int = _cuts_done - 1
	var slot_w: float = (TD_STRIP_ZONE.size.x - 180.0) / float(maxi(_cut_target, 1))
	var sx: float = TD_STRIP_ZONE.position.x + 160.0 + float(idx) * slot_w + randf_range(-3.0, 3.0)
	var sy: float = TD_STRIP_ZONE.position.y + TD_STRIP_ZONE.size.y * 0.5 - thin * 0.5 + randf_range(-3.0, 3.0)
	strip.position = Vector2(sx, sy - 24.0)
	strip.pivot_offset = strip.size * 0.5
	strip.rotation = deg_to_rad(randf_range(-3.0, 3.0))
	strip.modulate = Color(1, 1, 1, 0.0)
	_td_strip_holder.add_child(strip)
	var tw := strip.create_tween()
	tw.parallel().tween_property(strip, "position:y", sy, 0.20).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(strip, "modulate:a", 1.0, 0.16)


func _update_indicator() -> void:
	if not is_instance_valid(_indicator):
		return
	if _cuts_done >= _cut_target:
		_indicator.text = "Julienne complete"
	else:
		_indicator.text = "Cut thin strips  %d / %d" % [_cuts_done, _cut_target]


# live 판정 label.
func _build_live_feedback() -> void:
	_live_lbl = Label.new()
	_live_lbl.name = "JulienneLive"
	_live_lbl.position = Vector2(40, 1392)
	_live_lbl.size = Vector2(1000, 48)
	_live_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_live_lbl.add_theme_font_size_override("font_size", 34)
	_live_lbl.add_theme_color_override("font_color", Color(0.55, 0.78, 0.45))
	_live_lbl.add_theme_color_override("font_outline_color", Color(0.15, 0.10, 0.04))
	_live_lbl.add_theme_constant_override("outline_size", 4)
	_live_lbl.z_index = L5_VFX
	_live_lbl.text = ""
	add_child(_live_lbl)


## 판정 결과 label — Perfect / Good / Miss.
func _set_live(grade: int, _offset: float) -> void:
	if not is_instance_valid(_live_lbl):
		return
	match grade:
		RhythmJudge.PERFECT:
			_live_lbl.text = "Perfect!"
			_live_lbl.add_theme_color_override("font_color", Color(0.45, 0.88, 0.45))
		RhythmJudge.GOOD:
			_live_lbl.text = "Good"
			_live_lbl.add_theme_color_override("font_color", Color(0.92, 0.80, 0.34))
		_:
			_live_lbl.text = "Miss"
			_live_lbl.add_theme_color_override("font_color", Color(0.90, 0.45, 0.32))
	# pop.
	_live_lbl.scale = Vector2(1.25, 1.25)
	_live_lbl.pivot_offset = _live_lbl.size * 0.5
	var tw := _live_lbl.create_tween()
	tw.tween_property(_live_lbl, "scale", Vector2(1.0, 1.0), 0.16)


# --- Done 버튼 (초기 disabled, 6/6에 enabled) ---
func _build_done_button() -> void:
	_done_btn = Button.new()
	_done_btn.name = "JulienneDone"
	_done_btn.text = "Done"
	_done_btn.position = Vector2(330, 1600)
	_done_btn.size = Vector2(420, 104)
	_done_btn.add_theme_font_size_override("font_size", 40)
	_done_btn.disabled = true
	_done_btn.focus_mode = Control.FOCUS_NONE
	_style_done_button(false)
	_done_btn.z_index = L5_VFX + 1
	_done_btn.pressed.connect(_on_done_pressed)
	add_child(_done_btn)


## Done 버튼 스타일 — enabled 시 gold, disabled 시 grey.
func _style_done_button(enabled: bool) -> void:
	if not is_instance_valid(_done_btn):
		return
	var sb := StyleBoxFlat.new()
	if enabled:
		sb.bg_color = Color(0.96, 0.62, 0.18)
		sb.border_color = Color(0.55, 0.32, 0.08)
	else:
		sb.bg_color = Color(0.55, 0.50, 0.44, 0.85)
		sb.border_color = Color(0.40, 0.36, 0.30, 0.85)
	sb.set_corner_radius_all(48)
	sb.set_border_width_all(4)
	sb.shadow_size = 8
	sb.shadow_color = Color(0, 0, 0, 0.30)
	_done_btn.add_theme_stylebox_override("normal", sb)
	_done_btn.add_theme_stylebox_override("hover", sb)
	_done_btn.add_theme_stylebox_override("pressed", sb)
	_done_btn.add_theme_stylebox_override("disabled", sb)
	_done_btn.add_theme_color_override("font_color", Color(1.0, 0.97, 0.90) if enabled else Color(0.85, 0.82, 0.78))
	_done_btn.add_theme_color_override("font_disabled_color", Color(0.85, 0.82, 0.78))


## 6/6 도달 — marker/칼 정지, Done 활성 + 완료 애니, 우측 채 grade 시각.
func _on_all_cuts_done() -> void:
	if is_instance_valid(_marker):
		_marker.visible = false
	# Done 활성화 + pulse.
	if is_instance_valid(_done_btn):
		_done_btn.disabled = false
		_style_done_button(true)
		_done_btn.scale = Vector2(0.9, 0.9)
		_done_btn.pivot_offset = _done_btn.size * 0.5
		var tw := _done_btn.create_tween().set_loops()
		tw.tween_property(_done_btn, "scale", Vector2(1.05, 1.05), 0.45).set_trans(Tween.TRANS_SINE)
		tw.tween_property(_done_btn, "scale", Vector2(1.0, 1.0), 0.45).set_trans(Tween.TRANS_SINE)


func _on_done_pressed() -> void:
	if _cuts_done < _cut_target:
		return
	_finalize()


# === scoring — rhythm 정확도 → prep_quality 4축 [SCORING CONTRACT 보존] ===

## prep_quality 4축 산출 + base_module._finish(0~100) emit. 출력 contract 100% 동일.
## 입력 의미만 drag→rhythm으로 바뀌었을 뿐, 4축/가중치/getter/finish 경로는 보존.
func _finalize() -> void:
	# (1) thickness — per-cut 타이밍 정확도 평균(정확할수록 얇고 균일). grade 100/60 평균 → [0,1].
	var grade_avg: float = 0.0
	for g in _cut_grades:
		grade_avg += float(g)
	grade_avg = grade_avg / float(maxi(1, _cut_grades.size())) / 100.0
	prep_thickness = clampf(grade_avg, 0.0, 1.0)
	# (2) rhythm — tap 간 시간 간격 일관성(고른 박자). 부모 _consistency_from_intervals 재사용.
	prep_rhythm = _consistency_from_intervals(_cut_times_ms)
	# (3) spacing — 빗나간 cut 없이 등간격으로 썰림 = offset 일관성. offset이 고를수록 균등.
	prep_spacing = _consistency_from_intervals(_cut_offsets)
	# (4) angle — rhythm tap이라 칼은 항상 곧게 내려옴 → 평균 cut 정확도로 대표(grade_avg).
	prep_angle = clampf(grade_avg, 0.0, 1.0)
	# 4축 가중평균 → prep_quality [0,1].
	prep_quality = clampf(
		prep_angle * W_ANGLE + prep_rhythm * W_RHYTHM
		+ prep_spacing * W_SPACING + prep_thickness * W_THICKNESS, 0.0, 1.0)
	# 시각 분기 — perfect = 고른 얇은 strip / bad = chunky uneven.
	_apply_grade_visual(prep_quality)
	# base_module._finish(0~100) — runner contract 동일. [무변경]
	_finish(prep_quality * 100.0)


## prep_quality grade → 우측 채 시각 + live label.
func _apply_grade_visual(q: float) -> void:
	# 당근(남은 토막) fade — 다 썰린 상태.
	if is_instance_valid(_td_carrot):
		var tw := _td_carrot.create_tween()
		tw.tween_property(_td_carrot, "modulate:a", 0.0, 0.2)
	# PAINTERLY SWAP (2026-06-13): 완성 채 더미 = carrot_strips_good(고른 얇은 채) / carrot_strips_bad
	# (chunky uneven 더미). per-cut strip 위에 painterly pile을 덮어 결과를 한눈에 보이게 한다.
	# scoring(prep_quality 4축)은 이미 산출 — 순수 시각.
	_reveal_painterly_pile(q)
	if q >= GRADE_PERFECT:
		CookingFX.serving_sparkle(self, Vector2(TD_STRIP_ZONE.position.x + TD_STRIP_ZONE.size.x * 0.5,
			TD_STRIP_ZONE.position.y + TD_STRIP_ZONE.size.y * 0.5), 12)
		if is_instance_valid(_live_lbl):
			_live_lbl.text = "Even, thin strips!"
			_live_lbl.add_theme_color_override("font_color", Color(0.45, 0.88, 0.45))
	else:
		_apply_uneven_strips(q)
		if is_instance_valid(_live_lbl):
			if q >= GRADE_GOOD:
				_live_lbl.text = "Mostly even"
				_live_lbl.add_theme_color_override("font_color", Color(0.92, 0.80, 0.34))
			else:
				_live_lbl.text = "Uneven, chunky"
				_live_lbl.add_theme_color_override("font_color", Color(0.90, 0.45, 0.32))


## 완성 채 더미 painterly swap — good(고른 얇은 채) / bad(chunky uneven). per-cut strip을 fade하고
## strip zone 중앙에 painterly pile 1장을 띄운다. 미존재 시 per-cut strip(procedural) 유지.
func _reveal_painterly_pile(q: float) -> void:
	var key: String = "carrot_strips_good" if q >= GRADE_GOOD else "carrot_strips_bad"
	var path: String = ArtRegistry.get_painterly(key)
	if path == "":
		return   # painterly 미존재 → per-cut strip 그대로 (graceful fallback).
	# per-cut strip 더미를 살짝 fade(painterly pile이 결과를 대표).
	if is_instance_valid(_td_strip_holder):
		var stw := _td_strip_holder.create_tween()
		stw.tween_property(_td_strip_holder, "modulate:a", 0.0, 0.22)
	var pile := TextureRect.new()
	pile.name = "PainterlyStripPile"
	pile.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pile.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pile.texture = load(path)
	var pw: float = TD_STRIP_ZONE.size.x * 0.9
	var ph: float = TD_STRIP_ZONE.size.y * 2.4
	pile.size = Vector2(pw, ph)
	pile.position = Vector2(
		TD_STRIP_ZONE.position.x + (TD_STRIP_ZONE.size.x - pw) * 0.5,
		TD_STRIP_ZONE.position.y + TD_STRIP_ZONE.size.y * 0.5 - ph * 0.5)
	pile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pile.z_index = L3_INGREDIENT + 3
	pile.modulate = Color(1, 1, 1, 0.0)
	add_child(pile)
	var tw := pile.create_tween()
	tw.tween_property(pile, "modulate:a", 1.0, 0.25)


# bad/uneven 시각 — 쌓인 채를 제각각 두께/기울기로 흔든다.
func _apply_uneven_strips(q: float) -> void:
	if not is_instance_valid(_td_strip_holder):
		return
	var unevenness: float = clampf(1.0 - q, 0.3, 1.0)
	for child in _td_strip_holder.get_children():
		var n := child as Control
		if n == null:
			continue
		var tw := n.create_tween()
		var sy: float = 1.0 + randf_range(0.0, 1.4) * unevenness
		var sx: float = 1.0 + randf_range(-0.16, 0.16) * unevenness
		tw.parallel().tween_property(n, "scale", Vector2(sx, sy), 0.2)
		tw.parallel().tween_property(n, "rotation", deg_to_rad(randf_range(-18.0, 18.0) * unevenness), 0.2)


## 인접 표본 간격의 변동계수(CV)를 [0,1] 일관성으로 변환. [SCORING — 무변경, slice_module 호환]
func _consistency_from_intervals(samples: Array) -> float:
	if samples.size() < 3:
		return 0.6
	var intervals: Array = []
	for i in range(1, samples.size()):
		intervals.append(absf(float(samples[i]) - float(samples[i - 1])))
	var mean: float = 0.0
	for v in intervals:
		mean += float(v)
	mean /= float(intervals.size())
	if mean <= 0.001:
		return 0.5
	var var_sum: float = 0.0
	for v in intervals:
		var_sum += pow(float(v) - mean, 2.0)
	var sd: float = sqrt(var_sum / float(intervals.size()))
	var cv: float = sd / mean
	return clampf(1.0 - cv / 0.6, 0.0, 1.0)


# --- runner / shot 조회용 getter (consequence chain 전달) — [SCORING CONTRACT 보존] ---

## prep_quality [0,1] — runner가 quality-state로 읽어 4-factor 준비 20% + roll consequence(§8.2)에 사용.
func get_prep_quality() -> float:
	return prep_quality


## 4축 분해 (debug / shot label). [angle, rhythm, spacing, thickness] 각 [0,1].
func get_prep_dimensions() -> Dictionary:
	return {"angle": prep_angle, "rhythm": prep_rhythm,
		"spacing": prep_spacing, "thickness": prep_thickness}
