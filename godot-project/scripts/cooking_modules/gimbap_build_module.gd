## GimbapBuildModule — REAL gimbap assembly (color-slot Arrange 폐기 교체, gimbap-vertical-slice-v2 §4).
##
## 사용자 거부 교정: 기존 arrange_module 의 generic color-slot 매칭 퍼즐(재료를 색 ring 슬롯에
## drag-snap, correct_count/slot_count 점수)을 폐기하고 **실제 김밥 조립**으로 재구축한다.
## "I built a gimbap" — 색을 맞추는 게 아니라 김밥을 쌓는다(color matching 아닌 gimbap assembly).
##
## ── SINGLE-IMAGE BASE (2026-06-15) — gimbap_mat.png 한 장, 타일 합성 폐기 ─────────────────
## 사용자 핵심: "옆으로 돌리지 말라는데 왜 자꾸 돌려?" — AI setup(매번 옆 회전)도, Godot 타일 합성
## (bamboo_mat_large + seaweed_sheet_rect + rice_bed_full 레이어 쌓기 + RICE_CROP/AtlasTexture)도
## 전부 폐기. 사용자가 직접 만든 **gimbap_mat.png(1151×716)** = 김발(얇은 테두리) + 김(dark) + 고운
## 밥알 full bed가 전부 한 장에 담긴 완벽한 setup. 이미 똑바로 정렬(near edge 수평, 옆 회전 0) +
## 살짝 recline이 baked. → 그냥 **이 한 장을 base TextureRect로 깐다**. rotation 0(이미 똑바름),
## scale (1,1)(recline은 이미지에 baked — 코드 squash 불필요). 김발/김/밥 합성·통제 전부 불필요.
##
## ── 조리 한 stage — base 한 장 + 재료 placement (rotation/skew/squash 0) ──────────────────
##   ① gimbap_mat base (김발+김+밥 full bed 한 장, KEEP_ASPECT) — 자동 (player POV 하단=near)
##   ② 긴 prepared strip (당근/계란/녹색/단무지)  — **플레이어가 press-drag-release로 base의 흰 밥
##       region(중앙) lower-third 가로에 올린다 (핵심 액션, 색 슬롯 매칭 X)**
## 밥 region 좌표 = gimbap_mat 안 흰 밥 영역(측정 frac, RICE_* 상수). recline/회전 없음(이미지에 baked).
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
const BUILD_X: float = 540.0                 # 김밥 조립 중심 X (roll_module ROLL_X=540 정합).
# mat/김/밥 group 중심 Y. roll_module MAT_RECT(120,660,840,560) center y = 660+560/2 = 940 정합.
# Build→Roll 연속성: 두 화면의 mat 작업면이 같은 위치·같은 크기에 놓이게 한다.
const BUILD_HERO_Y: float = 940.0

# ── SINGLE-IMAGE BASE — gimbap_mat.png (사용자 제작 완성 setup, 2026-06-15) ───────────────
# 사용자 거부 교정의 종착: gpt-image-1 setup 한 장(매번 옆 회전)도, Godot 타일 합성(bamboo_mat_large
# + seaweed_sheet_rect + rice_bed_full 레이어 쌓기)도, RICE_CROP/AtlasTexture core crop도 전부 폐기.
# 사용자가 직접 만든 **gimbap_mat.png(1151×716)** = 김발(얇은 테두리) + 김(dark) + 고운 밥알 full bed가
# 전부 한 장에 담긴 완벽한 setup. 이미 똑바로 정렬(near edge 수평, 옆 회전 0) + 살짝 recline이 baked.
# → 그냥 **이 한 장을 base TextureRect로 깐다**. rotation = 0 (이미 똑바름, 추가 회전 불필요),
#   scale = (1,1) (recline·perspective가 이미지에 baked — 코드 squash 불필요). 김발/김/밥을 코드가
#   합성/통제할 필요가 사라졌다(기하가 전부 이미지에 그려져 있음).
const MAT_IMG_W: float = 1151.0              # gimbap_mat.png 원본 가로.
const MAT_IMG_H: float = 716.0               # gimbap_mat.png 원본 세로 (aspect 1.607).
const MAT_BOX_W: float = 900.0               # base 표시 가로 (action zone wide, roll MAT_RECT 840 정합).
const MAT_BOX_H: float = MAT_BOX_W * MAT_IMG_H / MAT_IMG_W   # 비율 유지 KEEP_ASPECT = 900*716/1151 ≈ 560.
# ── 밥 region (gimbap_mat 안의 흰 밥 영역) — 재료 placement 좌표 산정용 ──────────────────────
# gimbap_mat 안에서 고운 밥알 full bed가 차지하는 영역(측정: 흰 밥 mask column/row profile).
# 김발/김 테두리 안쪽 = x[0.14..0.74](center 0.48) / y[0.205..0.704](center 0.455). 이 region 위에
# 재료 strip을 placement. box-local(box 중심 origin)으로 환산 → RICE_BOX/RICE_CENTER_Y 로 재사용
# (기존 scoring/_is_over_rice/_settle_strip 좌표계 그대로 — 좌표만 gimbap_mat 밥 region에 맞춤).
const RICE_FRAC_CX: float = 0.480            # 밥 region 가로 중심 (이미지 frac, 측정).
const RICE_FRAC_CY: float = 0.455            # 밥 region 세로 중심 (이미지 frac, 측정).
const RICE_FRAC_W: float = 0.600             # 밥 region 가로 폭 (frac, 측정 ~0.60).
const RICE_FRAC_H: float = 0.500             # 밥 region 세로 폭 (frac, 측정 ~0.50).
# box-local 밥 region(box 중심 origin). 재료가 안착하는 흰 밥 영역(strip placement zone).
const RICE_BOX_W: float = MAT_BOX_W * RICE_FRAC_W            # 밥 가로(placement 폭) = 900*0.60 = 540.
const RICE_BOX_H: float = MAT_BOX_H * RICE_FRAC_H            # 밥 세로 = 560*0.50 ≈ 280.
const RICE_CENTER_Y: float = (RICE_FRAC_CY - 0.5) * MAT_BOX_H  # 밥 region 세로 중심(box-local) ≈ -25.
const RICE_CENTER_X: float = (RICE_FRAC_CX - 0.5) * MAT_BOX_W  # 밥 region 가로 중심(box-local) ≈ -18.

# 재료 "한 다발" 정위치 — 밥 위 가로 색색 다발(당근/계란/시금치/단무지 가로 띠 나란히), 틈 없이 맞닿게
# (roll flat_setup 정합 — 영상 §2 LOCK). (group 로컬 y, 양수 = 아래/near 쪽). 다발 중심 = gimbap_mat
# 흰 밥 region의 lower-middle(밥 region 중심 RICE_CENTER_Y보다 살짝 아래)에 얹어 far쪽 김 노출 = seal로.
# gimbap_mat 밥 region(center RICE_CENTER_Y≈-25, 높이 RICE_BOX_H≈280)에 맞춤 — lower-third ≈ center+50.
const BUNDLE_TARGET_Y: float = RICE_CENTER_Y + RICE_BOX_H * 0.10  # 다발 중심 y (밥 region lower-middle, 두꺼워진 다발이 밥 안에) ≈ +3.
const STRIP_TARGET_Y: float = BUNDLE_TARGET_Y  # (호환) 기존 scoring/consequence 코드 alias.
const STRIP_TARGET_TOL_GOOD: float = 48.0    # 이 안이면 위치 perfect (좁아진 밥 region에 맞춰 축소).
const STRIP_TARGET_TOL_OK: float = 92.0      # 이 밖이면 위치 감점 (너무 위/아래).
# ── 재료를 밥보다 좌우로 길게 (F5 fix, 2026-06-15): 실제 김밥 속은 밥/김 폭보다 양끝으로 살짝
# 삐져나온다. gimbap_mat 실측: 흰 밥 가로 = frac 0.132..0.844(box 픽셀 ~641), 김(seaweed) 안쪽
# = frac 0.102..0.876(box 픽셀 ~697). strip 가로폭을 **밥(641)보다 길고 김 안쪽(697)**인 660으로
# 잡아 양끝이 밥/김 위로 살짝 삐져나오되 김 밖으론 안 나간다. RICE_CENTER_X(밥 가로 중심)에 정렬.
const RICE_PIX_W: float = (0.844 - 0.132) * MAT_BOX_W     # 흰 밥 실측 가로(box 픽셀) ≈ 641.
const SEAWEED_PIX_W: float = (0.876 - 0.102) * MAT_BOX_W  # 김 안쪽 실측 가로(box 픽셀) ≈ 697.
const STRIP_W: float = (RICE_PIX_W + SEAWEED_PIX_W) * 0.5 # 밥보다 길고 김 안쪽 = 660(양끝 ~10px 삐져나옴).
# ── 가로 strip full-width 나란히 쌓기 (F5 fix: 거대 슬랩 → 얇은 가로 strip 다발) ─────────────
# 핵심 교정: 새 자산 filling_{id}_painterly = 1536×1024(3:2)에 **가로로 누운 strip 본체**가 세로
# 중앙 band(높이 ~26~36%)에 있고 위아래는 투명. 이전 build는 box 560×150 + KEEP_ASPECT_COVERED로
# 이 wide 자산을 box에 cover-fill → 세로로 거대하게 확대·crop돼 "거대 슬랩이 김 전체 덮고 비스듬"
# F5 불만이 됐다 (COVERED 거대 scale 로직 = 근본 원인).
# 이제: 각 자산의 painted band를 **AtlasTexture region으로 가로 full-width crop** → STRETCH_SCALE로
# 고정 가로폭(STRIP_W = 밥 폭) × 얇은 세로 STRIP_VIS_H 박스에 펼친다. 회전 0(가로로 누운 채),
# 비율 왜곡 최소(band가 이미 가로 우세). 거대 scale/COVERED crop 전부 제거.
const STRIP_BOX_W: float = STRIP_W           # strip sprite box 가로 = 밥 폭(full-width 고정).
# ── strip 두께 키워 음식 텍스처가 읽히게 (F5 fix, 2026-06-15) ───────────────────────────────
# 이전 50px = painterly band(carrot 채/egg 지단/spinach 잎/danmuji)가 얇은 한 줄로 짜부라져
# "솔리드 색 바(나무 통나무)"로 보였다. 두께를 70px로 키워 각 자산의 음식 텍스처(당근채 결/계란
# 지단 질감/시금치 잎/단무지)가 또렷이 읽히게 한다(거대 슬랩 아님 — 가로 strip 형태 유지).
const STRIP_VIS_H: float = 70.0              # strip 한 줄 세로 두께(가로 fat 색 띠 — 텍스처 읽힘).
const STRIP_BOX_H: float = STRIP_VIS_H       # box 세로 = 보이는 strip 두께(SCALE라 1:1).
const BUNDLE_BOX_W: float = STRIP_BOX_W       # (호환) 기존 alias.
const BUNDLE_BOX_H: float = STRIP_BOX_H       # (호환)
const BUNDLE_VIS_H: float = STRIP_VIS_H       # (호환)
const BUNDLE_STRIP_H: float = STRIP_VIS_H     # (호환)
# 4 strip을 y-offset만 다르게 **서로 겹쳐** 쌓아 한 다발(틈 0). stride(46) < 두께(70) = 강한 overlap
# → roll flat_setup처럼 색색 fat 띠가 빈틈없이 맞닿은 ONE bundle로 읽힌다(분리된 얇은 strip 금지).
# 총 두께 ≈ box_h + 3*stride ≈ 70+138 = 208px (gimbap_mat 밥 region ~280 lower-middle에 들어맞음).
const STRIP_STRIDE: float = 46.0             # strip 간 세로 stride(< 두께 → overlap, 빈틈 0 solid 다발).
const BUNDLE_PITCH: float = STRIP_STRIDE      # (호환) 기존 호출부 alias.
const STRIP_ROW_PITCH: float = STRIP_STRIDE   # (호환)
const STRIP_ROW_GAP: float = 0.0             # (호환) 다발 = 틈 0.
# 각 자산 painted-band region (가로 full-width, 세로 = 본체 band). 가로 strip crop용 AtlasTexture.
# 측정값(y band) → 약간 여유(±6) 둬 본체만 깔끔히 crop. 1536×1024 source 기준.
const FILLING_BAND: Dictionary = {
	"carrot":  {"y0": 360.0, "y1": 698.0},   # 측정 366~692
	"egg":     {"y0": 398.0, "y1": 680.0},   # 측정 404~674
	"spinach": {"y0": 326.0, "y1": 710.0},   # 측정 332~704
	"danmuji": {"y0": 410.0, "y1": 694.0},   # 측정 416~688
}
const FILLING_SRC_W: float = 1536.0          # source canvas 가로(band region full-width).

# staging tray (하단 near zone) — 준비된 다발(filling)들이 대기.
const TRAY_Y: float = 1500.0
const TRAY_GAP: float = 22.0
# tray에서는 strip을 약간 줄여 표시(개별 식별/집기 용이). settle 시 scale 1.0으로 복귀.
# (strip box는 full-width 얇은 띠 — tray에서 색별로 식별 가능하게 늘어놓는다.)
const TRAY_SCALE: float = 0.62

# 사용할 수 있는 긴 strip 종류 — Gimbap 정답 속(2026-06-12 sprite 배선, 당근/파 혼동 제거).
# ArtRegistry.gimbap_filling_specs()가 dish-correct sprite를 해석한다:
#   danmuji(밝은 노랑) / spinach(진녹) / carrot(주황 strip) / egg(노랑 지단).
# 더 이상 beef/green_onion 등 wrong-ingredient 대체가 없다 — 김밥 속이 정확 sprite로.
var _strip_specs: Array = []

var _need_strips: int = 4                     # 올려야 할 strip 수 (vs_available_slots 로 보정).
var _placed: int = 0
var _mat_holder: Node2D = null                # 김발 group (recline squash 대상 — stage_group과 동일 squash).
var _stage_group: Node2D = null               # mat 빼고 김+밥(평면). strip 도 여기에 안착. recline squash 대상.
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
	_build_header("Build Gimbap", "Place the fillings across the lower third of the rice.")

	_attach_dish_shadow(Vector2(BUILD_X, BUILD_HERO_Y + 200.0), 580.0)

	# BASE — gimbap_mat.png 한 장(김발+김+밥 full bed, 사용자 제작 완성 setup). 타일 합성 폐기.
	# 자동 배치. rotation 0 / scale (1,1) (이미 똑바름 + recline baked). _stage_group(밥 region 위에
	# 재료가 안착·carry되는 좌표계)를 여기서 만든다.
	_build_base()
	# Layer 4 — lower-third filling guide line (밥 region lower-third). snap 대상.
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
	_hint.text = "Place the fillings across the lower third of the rice"
	add_child(_hint)

	# 입력 인식기 — press-drag-release (색 슬롯 매칭 아님).
	_gesture = TouchGesture.new()
	_gesture.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_gesture)
	_gesture.drag_started.connect(_on_drag_started)
	_gesture.drag_updated.connect(_on_drag_updated)
	_gesture.drag_released.connect(_on_drag_released)


# BASE — gimbap_mat.png 한 장(김발+김+밥 full bed). 타일 합성(mat+seaweed+rice 레이어) 폐기 교체.
# 사용자 제작 완성 setup: 이미 똑바로 정렬(near edge 수평, 옆 회전 0) + 살짝 recline이 baked.
# rotation = 0 (추가 회전 불필요 — 이미 똑바름), scale = (1,1) (recline은 이미지에 baked, 코드 squash 0).
# KEEP_ASPECT_CENTERED로 MAT_BOX(900×560, 1151:716 비율)에 맞춰 깐다(가로 wide, 비율 유지).
func _build_base() -> void:
	# 받침 holder — base 한 장과 재료 stage_group을 같은 중심(BUILD_X, BUILD_HERO_Y)에 둔다.
	var holder := Node2D.new()
	holder.z_index = L2_BASE
	holder.position = Vector2(BUILD_X, BUILD_HERO_Y)
	holder.rotation = 0.0          # 이미 똑바름 — 회전 0.
	holder.scale = Vector2(1.0, 1.0)   # recline baked → 코드 squash 불필요.
	_mat_holder = holder
	add_child(holder)

	var base_path: String = ArtRegistry.get_painterly("gimbap_mat")
	if base_path != "":
		var base := TextureRect.new()
		base.name = "GimbapMatBase"
		base.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		# KEEP_ASPECT_CENTERED — 1151:716 비율 유지(가로 wide), MAT_BOX 안에 똑바로. 회전/skew 0.
		base.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		base.custom_minimum_size = Vector2.ZERO
		base.texture = load(base_path)
		base.size = Vector2(MAT_BOX_W, MAT_BOX_H)
		base.position = Vector2(-MAT_BOX_W * 0.5, -MAT_BOX_H * 0.5)
		base.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(base)
	else:
		# fallback — gimbap_mat 미존재 시 단순 bamboo 색 rect(graceful, 시각만).
		var rect := ColorRect.new()
		rect.color = Color(0.80, 0.62, 0.34)
		rect.size = Vector2(MAT_BOX_W, MAT_BOX_H)
		rect.position = Vector2(-MAT_BOX_W * 0.5, -MAT_BOX_H * 0.5)
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(rect)

	# stage_group — 재료(strip)가 안착·carry되는 좌표계. base와 동일 중심·rotation 0·scale (1,1)이라
	# box-local 좌표가 곧 base 픽셀 좌표와 정렬된다(squash 보정 불필요 — _to_stage_local이 그대로 동작).
	# 김+밥은 base 한 장에 이미 그려져 있으니 여기엔 그리지 않는다(타일 합성 폐기).
	_stage_group = Node2D.new()
	_stage_group.position = Vector2(BUILD_X, BUILD_HERO_Y)
	_stage_group.z_index = L3_INGREDIENT
	_stage_group.rotation = 0.0
	_stage_group.scale = Vector2(1.0, 1.0)
	_stage_base_y = _stage_group.position.y
	add_child(_stage_group)
	# _rice는 base 한 장이 대체 — 별도 rice 노드 없음(밥 region 좌표는 RICE_* 상수로 산정).
	_rice = null


# Layer 4 — lower-third filling guide line (밥 중앙 아님 — lower third). strip이 여기에 snap.
# 점선 가로 라인 + "lay fillings here" 캡션. STRIP_TARGET_Y(stage 로컬, lower third)에 위치.
var _guide_line: Control = null

func _build_guide_line() -> void:
	if _stage_group == null:
		return
	var line := Control.new()
	line.name = "FillingGuideLine"
	# stage_group 로컬 좌표 — gimbap_mat 밥 region(center RICE_CENTER_X) 위 lower-third 가로 점선.
	line.position = Vector2(RICE_CENTER_X - RICE_BOX_W * 0.5, STRIP_TARGET_Y)
	line.size = Vector2(RICE_BOX_W, 6.0)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.z_index = L3_INGREDIENT + 1
	_stage_group.add_child(line)
	# 가로 점선(dash) — 밥 lower-third를 가로질러 "여기에 한 줄로" 안내. SUBTLE (F5 fix): 점선이
	# 다발 사이로 비쳐 "prototype" 같던 불만 → 옅은 반투명으로 낮추고, 첫 재료 안착 시 fade out
	# (안내 역할 끝나면 음식만 남는다). Roll flat_setup엔 이런 라인이 없음.
	var dash_w: float = 26.0
	var gap: float = 22.0
	var x: float = 16.0
	while x < RICE_BOX_W - 16.0:
		var dash := Panel.new()
		dash.position = Vector2(x, -2.0)
		dash.size = Vector2(dash_w, 4.0)
		var dsb := StyleBoxFlat.new()
		dsb.bg_color = Color(1.0, 0.97, 0.80, 0.45)   # 옅게(0.92→0.45) — 다발 사이로 덜 비침.
		dsb.set_corner_radius_all(2)
		dash.add_theme_stylebox_override("panel", dsb)
		dash.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.add_child(dash)
		x += dash_w + gap
	_guide_line = line


# Layer 5 — staging tray 의 가로 strip(filling) (플레이어가 drag). 각 = full-width 얇은 색 띠.
func _build_staging_strips() -> void:
	var specs: Array = _strip_specs.slice(0, _need_strips)
	var n: int = specs.size()
	# tray 배치 — 각 strip은 **full-width 얇은 가로 띠**(거대 슬랩 아님). 집어서 밥 guide로 끌어올림.
	# node 본체 box는 STRIP_BOX_W × STRIP_VIS_H(얇은 띠). tray에서만 TRAY_SCALE로 줄여 색별 식별해
	# 집기 좋게 하고, settle 시 scale 1.0으로 복귀시켜 밥 위에 제 두께로 쌓는다.
	var strip_w: float = STRIP_W
	# tray pitch — 줄인 strip(visual ~STRIP_VIS_H*TRAY_SCALE ≈ 30px)이 색별로 분리돼 식별·집기 쉽게.
	var stack_pitch: float = 64.0
	var y0: float = TRAY_Y - float(n - 1) * stack_pitch * 0.5
	for i in range(n):
		var spec: Dictionary = specs[i]
		var home := Vector2(BUILD_X, y0 + float(i) * stack_pitch)
		var node := _make_strip_node(spec, strip_w)
		node.scale = Vector2(TRAY_SCALE, TRAY_SCALE)
		node.position = home - node.size * 0.5
		node.z_index = L3_INGREDIENT + 4 + i
		add_child(node)
		_strips.append({"node": node, "home": home, "placed": false, "spec": spec, "base_size": node.size})


# 한 재료 가로 strip TextureRect (또는 fallback ColorRect) — **full-width 얇은 가로 띠**(거대 슬랩 금지).
# spec.tex = ArtRegistry.gimbap_filling_specs()가 해석한 dish-correct sprite(danmuji/spinach/carrot/egg).
func _make_strip_node(spec: Dictionary, bar_w: float) -> Control:
	# HORIZONTAL STRIP (F5 fix, 2026-06-14): filling_{id}_painterly = 가로로 누운 strip 본체가
	# 세로 중앙 band(위아래 투명)에 있는 1536×1024 자산. 그 band를 AtlasTexture region으로 가로
	# full-width crop → STRETCH_SCALE로 고정폭(STRIP_BOX_W=밥 폭) × 얇은 세로(STRIP_VIS_H)에 펼친다.
	# COVERED 거대 scale/crop 로직 전부 제거 → 거대 슬랩/비스듬 없음, 가로로 누운 얇은 띠.
	var fid: String = String(spec.get("id", ""))
	var path: String = ArtRegistry.gimbap_painterly_filling(fid)
	if path != "" and FILLING_BAND.has(fid):
		var src: Texture2D = load(path)
		if src != null:
			var band: Dictionary = FILLING_BAND[fid]
			var y0: float = float(band["y0"])
			var y1: float = float(band["y1"])
			# AtlasTexture: source의 가로 full-width × painted band(세로)만 region으로 잘라낸다.
			var atlas := AtlasTexture.new()
			atlas.atlas = src
			atlas.region = Rect2(0.0, y0, FILLING_SRC_W, y1 - y0)
			atlas.filter_clip = true
			var t := TextureRect.new()
			t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			# STRETCH_SCALE: region(가로 full-width 얇은 strip)을 box에 그대로 펼침(거대 scale X).
			t.stretch_mode = TextureRect.STRETCH_SCALE
			t.custom_minimum_size = Vector2.ZERO
			t.texture = atlas
			t.size = Vector2(STRIP_BOX_W, STRIP_VIS_H)
			t.pivot_offset = Vector2(STRIP_BOX_W * 0.5, STRIP_VIS_H * 0.5)
			t.mouse_filter = Control.MOUSE_FILTER_IGNORE
			return t
	# painterly band 미존재 — full-width 얇은 색 band fallback(거대 슬랩 금지).
	var c := ColorRect.new()
	c.color = spec.get("col", Color(0.9, 0.7, 0.3))
	c.size = Vector2(STRIP_BOX_W, STRIP_VIS_H)
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


# 화면(global) 점 → stage_group 로컬 변환. group은 rotation 0 / scale (1,1)(recline은 base 이미지에
# baked, 코드 squash 없음)이라 단순 평행이동 환산(squash 보정 불필요).
func _to_stage_local(global_center: Vector2) -> Vector2:
	var d: Vector2 = global_center - _stage_group.position
	return Vector2(d.x / _stage_group.scale.x, d.y / _stage_group.scale.y)


# gimbap_mat 흰 밥 region 안(여유 포함)에 놓였는지 — group-로컬 변환. 밥 region은 box 중심에서
# RICE_CENTER_X 만큼 가로 offset 되어 있다(이미지 perspective). x 판정도 그 중심 기준.
func _is_over_rice(global_center: Vector2) -> bool:
	var local: Vector2 = _to_stage_local(global_center)
	var half_w: float = RICE_BOX_W * 0.62
	var top: float = RICE_CENTER_Y - RICE_BOX_H * 0.5 - 40.0
	var bot: float = RICE_CENTER_Y + RICE_BOX_H * 0.5 + 90.0
	return absf(local.x - RICE_CENTER_X) <= half_w and local.y >= top and local.y <= bot


# strip 을 밥 위에 안착 — guide line(lower-third)에 **snap** + 가지런히 한 줄 정렬.
# group 의 자식으로 reparent 해서 말기/이후 단계로 carry.
func _settle_strip(idx: int, global_center: Vector2) -> void:
	var node: Control = _strips[idx]["node"]
	# squash 보정 group-로컬 (recline scale 반영).
	var local: Vector2 = _to_stage_local(global_center)
	# 놓은 위치(정확도 산정용 — 너무 위/아래/한쪽 몰림 감점 보존). x는 밥 region 중심(RICE_CENTER_X)
	# 기준 상대값으로 기록 → 기존 scoring(_even_quality / get_arrange_*)이 0=centered 기준 그대로 동작
	# (좌표 도메인 무관, 순수 좌우 몰림 신호). drop_x 정의만 region-relative로(밥이 box 중심에서 offset).
	var drop_x: float = clampf(local.x - RICE_CENTER_X, -RICE_BOX_W * 0.5, RICE_BOX_W * 0.5)
	var drop_y: float = local.y
	_strips[idx]["placed"] = true
	_placed += 1
	# scoring/consequence는 "놓은 정확도"를 보존: drop_y(guide 근접도) + drop_x(좌우 몰림) 기록.
	_placed_local.append(Vector2(drop_x, drop_y))
	# reparent 해서 stage_group 로컬에 — roll/slice 로 carry + recline squash 함께 적용되도록.
	# drop 위치를 stage-local로 직접 배치(squash된 부모 안 → 밥 bed와 같은 recline으로 뉘인다).
	node.get_parent().remove_child(node)
	_stage_group.add_child(node)
	node.position = local - node.size * 0.5
	node.z_index = L3_INGREDIENT + 3 + _placed   # strip이 쌓이는 순서대로 위로(살짝 겹쳐 한 다발).
	# SNAP — full-width 가로 strip을 **y-offset만 다르게 tight stacking**(영상 §2 LOCK): 가로폭은
	# 고정(STRIP_BOX_W=밥 region 폭, 회전 0), 세로는 STRIP_STRIDE(≈ 두께) 간격으로 차곡차곡 쌓아 색색
	# 띠가 서로 붙은 한 다발로 BUNDLE_TARGET_Y(밥 region lower-middle) 중심에 모인다. 가로는 밥 region
	# 중심(RICE_CENTER_X)에 정렬 → "가로 strip 나란히 쌓인 색색 다발"이 흰 밥 위에 즉시 읽힌다.
	var row_y: float = BUNDLE_TARGET_Y + (float(_placed - 1) - float(_need_strips - 1) * 0.5) * STRIP_STRIDE
	var snap_local := Vector2(RICE_CENTER_X, row_y)
	var target_pos: Vector2 = snap_local - node.size * 0.5
	var tw := node.create_tween()
	tw.tween_property(node, "position", target_pos, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(node, "scale", Vector2(1.0, 1.0), 0.18)
	# guide line — 첫 재료가 안착하면 fade out(안내 끝, 음식만 남게). 다발 사이로 점선이 비치는
	# "prototype" 불만 제거. 이후 placement는 이미 쌓인 다발이 정렬 기준이 된다.
	if is_instance_valid(_guide_line):
		if _placed == 1:
			var gtw := _guide_line.create_tween()
			gtw.tween_property(_guide_line, "modulate:a", 0.0, 0.22)
		# (이후엔 이미 사라진 라인 — pulse 없음.)
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
	var local: Vector2 = _to_stage_local(global_center)
	if not _is_over_rice(global_center):
		_hint.text = "Place it onto the rice"
	elif local.y < STRIP_TARGET_Y - STRIP_TARGET_TOL_OK:
		_hint.text = "Too high — bring it down to the lower third"
	elif local.y > STRIP_TARGET_Y + STRIP_TARGET_TOL_OK:
		_hint.text = "Too low — line it up across the lower third"
	else:
		_hint.text = "On the lower third — release to place"


func _update_placed_hint() -> void:
	if not is_instance_valid(_hint):
		return
	var left: int = _need_strips - _placed
	if left > 0:
		_hint.text = "Fillings placed: %d · %d to go" % [_placed, left]


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
