## ArtRegistry — food_id / semantic key → 스프라이트 res:// 경로.
##
## 5-Layer Runtime Composition refactor (2026-06-06): 39 standalone asset를 runtime
## 조립한다. baked composite PNG(도마+칼+재료) 폐기. Godot가 시각 layer를 합성.
##   - ingredient (20): get_ingredient(name, state) → art/sprites/ingredient/{name}_{state}.png
##   - tool (9):        get_tool(name)              → art/sprites/tool/{name}.png
##   - vessel (10):     get_vessel(name)            → art/sprites/vessel/{name}.png
## graceful fallback: ResourceLoader.exists() == false면 빈 문자열 → module이 procedural.
##
## food_id → semantic 매핑(어떤 음식이 어떤 재료/도구/그릇을 쓰는지)도 여기 모은다.
## DEPRECATED baked anchor(ingredient_anchors_m1 / cut_anchors_m1 / tool_anchors_m1)는
## 더 이상 참조하지 않는다.
class_name ArtRegistry
extends RefCounted

# --- 완성 음식 hero (food_id → 완성샷) — 무변경 (plate/season hero용) ---
const FOOD := {
	"t1_002": "res://art/sprites/food/t1_002.png",
	"t1_003": "res://art/sprites/food/t1_003.png",
	"t1_004": "res://art/sprites/food/t1_004.png",
	"t1_005": "res://art/sprites/food/t1_005.png",
	"t1_006": "res://art/sprites/food/t1_006.png",
	"t1_007": "res://art/sprites/food/t1_007.png",
	"t1_008": "res://art/sprites/food/t1_008.png",
	"t2_008": "res://art/sprites/food/t2_008.png",
	"t2_010": "res://art/sprites/food/t2_010.png",
	"t2_012": "res://art/sprites/food/t2_012.png",
	"t2_013": "res://art/sprites/food/t2_013.png",
	"t2_014": "res://art/sprites/food/t2_014.png",
}

static func food(fid: StringName) -> String:
	return FOOD.get(String(fid), "")


# --- content-only food (그릇 없는 음식 내용물 — Plate vessel+content 합성용) ---
# Cooking Realism Fix (2026-06-07): premium_v2 완성 dish는 그릇 baked(dish_with_vessel) →
# Plate에서 vessel(L2) 위에 또 올리면 "그릇 위 그릇"(HR2 위반). content_only는 그릇 없는
# 음식 mound만 — vessel sprite 위에 자연스럽게 담긴다. 미존재 음식은 "" → Plate가
# Option B fallback(vessel 생략, dish_with_vessel 단독 hero)로 동작.
const _FOOD_CONTENT_DIR := "res://art/sprites/food_content/"
const FOOD_CONTENT_ONLY := {
	"t2_008": "res://art/sprites/food_content/bibimbap_content_only.png",   # 비빔밥 — brass_bowl 합성
}

## food_id → content-only 음식 sprite(그릇 없음). 미존재 시 "" (Plate가 dish 단독 fallback).
static func food_content_only(fid: StringName) -> String:
	var path: String = FOOD_CONTENT_ONLY.get(String(fid), "")
	if path != "" and ResourceLoader.exists(path):
		return path
	# 명시 매핑이 없어도 관례 경로(food_content/{id}_content_only.png)가 있으면 사용.
	var conv: String = _FOOD_CONTENT_DIR + String(fid) + "_content_only.png"
	if ResourceLoader.exists(conv):
		return conv
	return ""


# --- roll-stage standalone assets (김밥 마는 단계 layer) ---
# Cooking Realism Fix (2026-06-07): Roll module이 완성 김밥 hero를 처음부터 표시(HR1 위반).
# 실제 마는 과정 = 김(seaweed) → 밥(rice) → 속(filling strips) → 말기 → halfway → finished.
# 각 단계 standalone sprite. 미존재 시 "" → roll module이 procedural placeholder(완성 hero 금지).
#
# Gimbap Roll Layout Fix (2026-06-07, visual only): 실제 김밥 마는 setup으로 교정.
# 기존 short/square 자산 대신 long-strip wide 자산으로 — bamboo mat(받침) → 김 → 밥 →
# 속재료를 김 폭 가로질러 긴 band로. 신규 wide 자산 추가(기존 key 호환 유지):
#   bamboo_mat_large    : 큰 김발 (action zone base)
#   seaweed_sheet_rect  : 김 (wide 직사각)
#   rice_layer_flat_rect: 밥 (wide 직사각, 얇게)
#   carrot/egg/green/beef_strip_long : 속재료 긴 가로 strip (continuous full-width band)
const _ROLL_DIR := "res://art/sprites/roll/"
const ROLL_KEYS := [
	"seaweed_sheet", "rice_layer_flat",
	"gimbap_filling_strip_carrot", "gimbap_filling_strip_egg", "gimbap_filling_strip_green",
	"gimbap_roll_halfway", "gimbap_roll_finished_content_only",
	# long-strip wide layout (2026-06-07) — 실제 김밥 마는 composition.
	"bamboo_mat_large", "seaweed_sheet_rect", "rice_layer_flat_rect",
	"carrot_strip_long", "egg_strip_long", "green_strip_long", "beef_strip_long",
	# STAGED physical-curl roll — 4-state REBUILD (2026-06-10, gimbap-vertical-slice-v2 §5).
	# 사용자 거부 교정: first_fold/cylinder_forming 은 spiral 단면(end-cap)을 조기노출 → DROP.
	# 신 4-state(단면 중간 절대 금지, player-POV bottom→top, 평면 mat):
	#   flat_setup(s1, 평면 김+밥+가로 strip) → edge_lift(s2, near edge 들림) →
	#   half_roll(s3, 절반 log + 상단 평평 김) → 끝/압축:
	#     finished_cylinder(s4 success, 완성 통 log — end-cap은 끝 상태만 OK) /
	#     compressed_loose(약압) / compressed_tight(강압).
	# 중간 state(flat/edge_lift/half_roll)는 단면 0 — 완성 김밥 조기노출 해소.
	# 미존재 시 get_roll_asset()이 "" → roll module이 procedural/기존 자산 fallback(무해).
	"gimbap_roll_flat_setup", "gimbap_roll_edge_lift", "gimbap_roll_half_roll",
	"gimbap_roll_finished_cylinder",
	"gimbap_roll_compressed_loose", "gimbap_roll_compressed_tight",
	# DEPRECATED (단면 조기노출 — 신 roll 경로 미사용, graceful fallback만 유지):
	#   first_fold / cylinder_forming / halfway_pov 는 더 이상 swap 대상이 아니다.
	"gimbap_roll_first_fold", "gimbap_roll_cylinder_forming", "gimbap_roll_halfway_pov",
]

## get_roll_asset("seaweed_sheet") → res://art/sprites/roll/seaweed_sheet.png
## 파일 미존재 시 "" (roll module이 procedural placeholder layer로 fallback — 완성 hero 금지).
static func get_roll_asset(key: String) -> String:
	var path: String = _ROLL_DIR + key + ".png"
	return path if ResourceLoader.exists(path) else ""


# =====================================================================================
# Gimbap painterly swap (2026-06-13, gimbap-visual-quality-rebuild-v1 §5) — high-angle
# painterly sprite로 procedural geometry를 교체한다. food/tool/surface 시각 layer만 교체
# (입력/scoring/4-factor/save/consequence contract 무변경). UI HUD(target/meter/marker)는
# vector 유지. 미존재 시 "" → 각 module이 기존 procedural _draw로 graceful fallback(무해).
#
# painterly 25장 (assets-raw/gimbap_painterly_m2 → art/sprites/painterly):
#   roll 6 state  : roll_flat_setup / roll_edge_lift / roll_first_fold / roll_curling /
#                   roll_compression / roll_finished (+ result variant loose/burst)
#   build 7       : mat_painterly / seaweed_painterly / rice_painterly /
#                   filling_{carrot,egg,spinach,danmuji}_painterly
#   carrot 4      : carrot_whole / carrot_on_board / carrot_strips_good / carrot_strips_bad
#   slice 3       : gimbap_roll_for_slice / gimbap_piece_good / gimbap_piece_collapse
#   plate 1       : wooden_tray_topdown
#   tool 2        : board_topdown_painterly / knife_topdown_painterly
# =====================================================================================
const _PAINTERLY_DIR := "res://art/sprites/painterly/"
const PAINTERLY_KEYS := [
	# roll 6 state (single-shot cross-fade swap).
	"roll_flat_setup", "roll_edge_lift", "roll_first_fold",
	"roll_curling", "roll_compression", "roll_finished",
	"roll_finished_loose", "roll_finished_burst",
	# build layers (mat/김/밥/filling 4).
	"mat_painterly", "seaweed_painterly", "rice_painterly",
	"filling_carrot_painterly", "filling_egg_painterly",
	"filling_spinach_painterly", "filling_danmuji_painterly",
	# julienne carrot 4 state.
	"carrot_whole", "carrot_on_board", "carrot_strips_good", "carrot_strips_bad",
	# slice / plate / tool.
	"gimbap_roll_for_slice", "gimbap_piece_good", "gimbap_piece_collapse",
	"wooden_tray_topdown", "board_topdown_painterly", "knife_topdown_painterly",
]

## get_painterly("roll_finished") → res://art/sprites/painterly/roll_finished.png
## 파일 미존재 시 "" → caller가 기존 procedural _draw로 fallback(시각만 영향, scoring 무관).
static func get_painterly(key: String) -> String:
	var path: String = _PAINTERLY_DIR + key + ".png"
	return path if ResourceLoader.exists(path) else ""


## Gimbap filling id(danmuji/spinach/carrot/egg) → painterly filling band sprite. 미존재 시 "".
static func gimbap_painterly_filling(filling_id: String) -> String:
	return get_painterly("filling_%s_painterly" % filling_id)


# =====================================================================================
# 5-Layer standalone resolution — semantic key → res:// 경로
# =====================================================================================

const _ING_DIR := "res://art/sprites/ingredient/"
const _TOOL_DIR := "res://art/sprites/tool/"
const _VESSEL_DIR := "res://art/sprites/vessel/"

## 사용 가능한 standalone ingredient 키(name + state). 누락 state는 fallback 처리.
const INGREDIENT_KEYS := [
	"green_onion_whole", "green_onion_chopped", "green_onion_julienne",
	"carrot_whole", "carrot_sliced", "carrot_julienne", "carrot_julienne_bad", "carrot_diced",
	"kimchi_whole", "kimchi_chopped", "kimchi_cooked",
	"tofu_block", "tofu_cubed",
	"beef_raw", "beef_marinated", "beef_cooked",
	"egg_whole", "egg_cooked",
	"rice_bowl",
	"noodle_raw", "noodle_cooked",
	# P0 Recipe Correctness (2026-06-07) — dish-correct single-state ingredient sprites.
	# 단일 state(이름 자체가 키 — state 인자 없이 get_ingredient(name)). transparent hero.
	#   rice_cake       : 떡(가래떡 흰 cylinder)    — 떡볶이 stir/slice 정답 재료.
	#   fish_cake       : 어묵(어슷 갈색 slice)      — 떡볶이 slice 정답(대파 대체 제거).
	#   gochujang_dollop: 고추장 paste 한 덩이       — 비빔밥 season 정답(고춧가루병 아님).
	"rice_cake", "fish_cake", "gochujang_dollop",
	# Gimbap Build/Slice sprite 배선 (2026-06-12, 당근/파 혼동 제거) — dish-correct 김밥 속.
	#   danmuji_strip : 단무지(밝은 노랑 strip) — 당근/계란 노랑과 구분되는 단무지 정체성.
	#   spinach_cooked: 시금치 나물(진녹 잎채소) — 대파(green_onion) 대체 제거(파 아님).
	# (당근=carrot_julienne / 계란=egg_strip(egg_strip_long whole-egg 아님)는 기존 키 사용.)
	"danmuji_strip", "spinach_cooked",
]
const TOOL_KEYS := [
	"chef_knife", "cutting_board", "ladle", "spatula", "tongs",
	"rolling_mat", "seasoning_bottle", "spoon", "chopsticks",
]
const VESSEL_KEYS := [
	"pot", "dolsot", "frying_pan", "grill_pan", "mixing_bowl",
	"noodle_bowl", "brass_bowl", "wooden_tray", "wide_plate", "earthenware_bowl",
]


## get_ingredient("green_onion", "whole") → res://art/sprites/ingredient/green_onion_whole.png
## state 생략 시 name 자체를 키로(rice_bowl 등). 파일 미존재 시 "" (procedural fallback).
static func get_ingredient(name: String, state: String = "") -> String:
	var key: String = name if state == "" else "%s_%s" % [name, state]
	var path: String = _ING_DIR + key + ".png"
	if ResourceLoader.exists(path):
		return path
	# state 미존재 시 같은 name의 다른 state로 graceful fallback(우선순위: whole→raw→block→name).
	for alt in [name + "_whole", name + "_raw", name + "_block", name]:
		var p: String = _ING_DIR + alt + ".png"
		if ResourceLoader.exists(p):
			return p
	return ""


## get_tool("chef_knife") → res://art/sprites/tool/chef_knife.png
static func get_tool(name: String) -> String:
	var path: String = _TOOL_DIR + name + ".png"
	return path if ResourceLoader.exists(path) else ""


# MenuDB vessel catalog id(pot_metal / bowl_brass / board_wood ...) → vessel sprite 이름.
# Plate 선택 card에서 실제 그릇 sprite를 보여주기 위함 (점수 도메인 무관, 순수 시각).
const _VESSEL_CATALOG_SPRITE := {
	"pot_metal": "pot", "bowl_ceramic": "noodle_bowl", "pot_stone": "dolsot",
	"pot_clay": "earthenware_bowl", "bowl_glass": "mixing_bowl", "bowl_brass": "brass_bowl",
	"board_wood": "wooden_tray", "plate_wide": "wide_plate",
}

## MenuDB vessel catalog id → vessel sprite 경로 (Plate 선택 card용). 미존재 시 "".
static func vessel_sprite_for_catalog(catalog_id: String) -> String:
	var sprite_name: String = _VESSEL_CATALOG_SPRITE.get(catalog_id, "")
	if sprite_name == "":
		return ""
	return get_vessel(sprite_name)


## get_vessel("cutting_board") → vessel 또는 tool 폴더에서 해석.
## cutting_board/rolling_mat은 Tool layer 자산이지만 base 역할(L2)이라 vessel 호출 허용.
static func get_vessel(name: String) -> String:
	var vpath: String = _VESSEL_DIR + name + ".png"
	if ResourceLoader.exists(vpath):
		return vpath
	# cutting_board / rolling_mat 등은 tool/ 폴더에 있다.
	var tpath: String = _TOOL_DIR + name + ".png"
	return tpath if ResourceLoader.exists(tpath) else ""


# =====================================================================================
# food_id → semantic 매핑 (어떤 음식이 어떤 재료/도구/그릇을 쓰는지)
#   gameplay/scoring 무관 — 순수 시각 자산 선택. 미정의 음식은 default fallback.
# =====================================================================================

## slice module이 쓰는 재료 (whole→prepared swap). [name, prepared_state].
## 예: 라면=대파(whole→chopped), 김치볶음밥=김치(whole→chopped), 비빔밥=당근(whole→julienne).
const SLICE_INGREDIENT := {
	"t1_002": ["green_onion", "chopped"],   # 라면 — 대파 송송 (정답)
	"t1_003": ["fish_cake", ""],            # 떡볶이 — 어묵 어슷썰기 (P0: 대파 substitute 제거)
	"t1_004": ["danmuji_strip", ""],        # 김밥 — 단무지(밝은 노랑, sprite 배선 2026-06-12). 통썰기는 GimbapSliceModule이 담당.
	"t1_005": ["kimchi", "chopped"],        # 김치볶음밥 — 김치 깍둑 (정답)
	"t1_006": ["green_onion", "chopped"],   # 해물파전 — 쪽파 송송 (정답)
	"t1_007": ["green_onion", "chopped"],   # 콘도그 — batter dip 정답이나 cut placeholder
	"t1_008": ["green_onion", "chopped"],   # 잔치국수 — 대파 송송 (정답)
	"t2_008": ["carrot", "julienne"],       # 비빔밥 — 당근 채썰기 (정답)
	"t2_010": ["carrot", "julienne"],       # 잡채 — 당근 채썰기 (정답)
	"t2_012": ["green_onion", "chopped"],   # 갈비 — 마늘 다지기 정답 (마늘 sprite 미존재 → placeholder)
	"t2_013": ["green_onion", "chopped"],   # 순두부 — 호박 통썰기 정답 (호박 sprite 미존재 → placeholder)
	"t2_014": ["green_onion", "julienne"],  # 불고기 — 양파 채썰기 정답 (양파 sprite 미존재 → placeholder)
}

## stir module이 churn할 standalone 재료. [name, cooked_state].
const STIR_FOOD := {
	"t1_003": ["rice_cake", ""],            # 떡볶이 — 떡을 빨간 고추장 양념에 졸이기 (P0: 김치 pile 제거)
	"t1_005": ["kimchi", "cooked"],         # 김치볶음밥 — 김치 churn (정답: 김치볶음밥은 김치 맞음)
	"t2_008": ["rice_bowl", ""],            # 비빔밥 — 밥+나물 bowl mix (P0: noodle 아님, beef churn에서 rice base로)
	"t2_010": ["noodle", "cooked"],         # 잡채 당면 toss (정답: 잡채는 당면 맞음)
	"t2_014": ["beef", "cooked"],           # 불고기 — 얇은 고기 양념 코팅 볶기 (P0: noodle 절대 금지)
}

## flip module: raw→cooked swap. [name, before_state, after_state].
const FLIP_FOOD := {
	"t1_006": ["beef", "raw", "cooked"],    # 해물파전 (전 placeholder → beef raw→cooked)
	"t1_007": ["beef", "raw", "cooked"],    # 콘도그
	"t2_012": ["beef", "raw", "cooked"],    # 갈비 raw→cooked
}

## timing module: raw→cooked swap. [name, before_state, after_state].
const TIMING_FOOD := {
	"t1_002": ["noodle", "raw", "cooked"],  # 라면 — 면 끓이기
	"t1_008": ["noodle", "raw", "cooked"],  # 잔치국수
	"t1_005": ["kimchi", "whole", "cooked"],# 김치볶음밥 볶기
	"t2_010": ["noodle", "raw", "cooked"],  # 잡채 볶기
	"t2_012": ["beef", "raw", "cooked"],    # 갈비 grill
	"t2_013": ["tofu", "block", "cubed"],   # 순두부 — 뚝배기 stew (broth/김치 submerged + 거품은 timing module이 stew variant로 합성)
	# m_kimchi_jjigae / m_doenjang_jjigae / m_maeuntang dead 매핑 제거 (P0 #5):
	# 해당 dish는 dish_modules.csv stale 행 — 정본 12 dish에 없음. 매핑 없으면 default fallback.
}

## roll module 재료(김밥 속). standalone ingredient 이름 배열.
const ROLL_INGREDIENTS := ["rice_bowl", "carrot_julienne", "green_onion_julienne", "egg_cooked"]


# =====================================================================================
# Gimbap filling 배선 (2026-06-12, 당근/파 혼동 제거) — Build/Roll/Slice/Plate 공유 SSOT.
#   "단무지=당근, 시금치=파" 오매핑을 제거하고 dish-correct 정체성을 한 곳에서 해석한다:
#     danmuji  → danmuji_strip(밝은 노랑)         — 당근/계란 노랑과 구분.
#     spinach  → spinach_cooked(진녹 잎채소)       — 대파(green_onion) 아님.
#     carrot   → carrot_strip_long(긴 주황 strip)  — carrot_julienne fallback.
#     egg      → egg_strip_long(긴 노랑 지단)       — whole egg icon 아님.
# 각 spec: {id, label, roll_key(긴 strip 우선), ing(state ingredient fallback), col(폴백색), bh(시각 두께비)}.
# Build/Slice 가 이 배열을 slice(0, n)로 잘라 정답 김밥 속을 순서대로 사용한다(랜덤 아이콘 금지).
const GIMBAP_FILLINGS := [
	{"id": "danmuji", "label": "단무지 Danmuji", "roll_key": "",
		"ing": "danmuji_strip", "col": Color(0.98, 0.82, 0.20), "bh": 0.30},
	{"id": "spinach", "label": "시금치 Spinach", "roll_key": "",
		"ing": "spinach_cooked", "col": Color(0.24, 0.46, 0.18), "bh": 0.32},
	{"id": "carrot",  "label": "당근 Carrot",   "roll_key": "carrot_strip_long",
		"ing": "carrot_julienne", "col": Color(0.93, 0.52, 0.18), "bh": 0.31},
	{"id": "egg",     "label": "계란 Egg",      "roll_key": "egg_strip_long",
		"ing": "egg_cooked", "col": Color(0.97, 0.80, 0.26), "bh": 0.24},
]


## 김밥 속 spec n개(정답 순서 danmuji→spinach→carrot→egg). 각 spec에 해석된 sprite 경로(tex) 부착.
## roll_key(긴 strip) 우선, 미존재 시 ing(state ingredient)로 fallback. 둘 다 없으면 "" (procedural col).
static func gimbap_filling_specs(count: int = 4) -> Array:
	var n: int = clampi(count, 1, GIMBAP_FILLINGS.size())
	var out: Array = []
	for i in range(n):
		var base: Dictionary = (GIMBAP_FILLINGS[i] as Dictionary).duplicate()
		base["tex"] = gimbap_filling_tex(base)
		out.append(base)
	return out


## 한 filling spec → sprite 경로. roll long-strip 우선 → ingredient fallback → "".
static func gimbap_filling_tex(spec: Dictionary) -> String:
	var rk: String = String(spec.get("roll_key", ""))
	if rk != "":
		var rp: String = get_roll_asset(rk)
		if rp != "":
			return rp
	var ing: String = String(spec.get("ing", ""))
	if ing != "":
		var ip: String = get_ingredient(ing)
		if ip != "":
			return ip
	return ""


## food_id → 조리 vessel/tool base (L2). primary_cooking_method 매핑.
## boil → pot / 끓이기 → dolsot / 볶음 → frying_pan / 구이 → grill_pan.
const FOOD_VESSEL := {
	"t1_002": "noodle_bowl",     # 라면 — 양은냄비 ≈ noodle_bowl
	"t1_003": "frying_pan",      # 떡볶이 — 졸이기 팬
	"t1_004": "rolling_mat",     # 김밥 — 김발
	"t1_005": "frying_pan",      # 김치볶음밥 — 웍/팬
	"t1_006": "frying_pan",      # 해물파전 — 팬
	"t1_007": "frying_pan",      # 콘도그 — 튀김(팬 대체)
	"t1_008": "noodle_bowl",     # 잔치국수
	"t2_008": "dolsot",          # 비빔밥 — 돌솥
	"t2_010": "frying_pan",      # 잡채 — 볶음
	"t2_012": "grill_pan",       # 갈비 — 그릴
	"t2_013": "earthenware_bowl",# 순두부 — 뚝배기 (stew boil)
	"t2_014": "frying_pan",      # 불고기 — 볶음/구이
	# m_* stale dish 매핑 제거 (P0 #5) — 정본 12 dish에 없음. default("pot") fallback.
}

## food_id → plate vessel (L2, plate module). 완성 dish를 담는 그릇.
const PLATE_VESSEL := {
	"t1_002": "noodle_bowl", "t1_003": "wide_plate", "t1_004": "wooden_tray",
	"t1_005": "wide_plate", "t1_006": "wide_plate", "t1_007": "wooden_tray",
	"t1_008": "noodle_bowl", "t2_008": "brass_bowl", "t2_010": "wide_plate",
	"t2_012": "wide_plate", "t2_013": "earthenware_bowl", "t2_014": "brass_bowl",
	# m_* stale dish 매핑 제거 (P0 #5) — 정본 12 dish에 없음. default("wide_plate") fallback.
}

## food_id → 활성 active tool (L4, stir/season module). 조리 동작 도구.
const FOOD_ACTIVE_TOOL := {
	"t1_003": "spatula", "t1_005": "spatula", "t2_008": "spoon",
	"t2_010": "chopsticks", "t2_014": "spatula",
}


# --- food_id → semantic lookup helpers (graceful default) ---

# P0 #6 (2026-06-07): generic substitute 제거.
# 이전: 미매핑 dish를 silent하게 green_onion/kimchi/beef/noodle로 대체 → wrong ingredient.
# (특히 stir default = kimchi가 떡볶이류에 김치를 silent 주입하던 근본 원인.)
# 이제 dish-specific 매핑이 정본 12 dish 전부에 존재하므로 default는 닿지 않는다. default가
# 닿는 경우(미정의 신규 dish)는 "잘못된 특정 음식 정체성"을 암시하지 않는 중립 placeholder를
# 쓰고 _warn_unmapped로 로그를 남긴다 (silent wrong-ingredient 금지).
const _PLACEHOLDER_SLICE: Array = ["green_onion", "chopped"]   # 중립(대파) — 정체성 약함
const _PLACEHOLDER_STIR: Array = ["rice_bowl", ""]            # 중립(밥) — 김치 silent 주입 제거
const _PLACEHOLDER_FLIP: Array = ["egg", "whole", "cooked"]   # 중립(계란) — 소고기 silent 대체 제거
const _PLACEHOLDER_TIMING: Array = ["noodle", "raw", "cooked"]# 중립(면) — 끓이기 generic

static func slice_ingredient_for(food_id: StringName) -> Array:
	if SLICE_INGREDIENT.has(String(food_id)):
		return SLICE_INGREDIENT[String(food_id)]
	_warn_unmapped("slice", food_id)
	return _PLACEHOLDER_SLICE.duplicate()

static func stir_food_for(food_id: StringName) -> Array:
	if STIR_FOOD.has(String(food_id)):
		return STIR_FOOD[String(food_id)]
	_warn_unmapped("stir", food_id)
	return _PLACEHOLDER_STIR.duplicate()

static func flip_food_for(food_id: StringName) -> Array:
	if FLIP_FOOD.has(String(food_id)):
		return FLIP_FOOD[String(food_id)]
	_warn_unmapped("flip", food_id)
	return _PLACEHOLDER_FLIP.duplicate()

static func timing_food_for(food_id: StringName) -> Array:
	if TIMING_FOOD.has(String(food_id)):
		return TIMING_FOOD[String(food_id)]
	_warn_unmapped("timing", food_id)
	return _PLACEHOLDER_TIMING.duplicate()


## 미매핑 dish가 placeholder로 떨어질 때 명확히 로그 (wrong-ingredient silent 금지 — P0 #6).
static func _warn_unmapped(module: String, food_id: StringName) -> void:
	push_warning("[ArtRegistry] '%s' module has NO dish-specific ingredient for '%s' — using neutral placeholder (NOT a wrong dish ingredient). Add a mapping for recipe correctness." % [module, String(food_id)])

static func cooking_vessel_for(food_id: StringName) -> String:
	return get_vessel(FOOD_VESSEL.get(String(food_id), "pot"))

static func plate_vessel_for(food_id: StringName) -> String:
	return get_vessel(PLATE_VESSEL.get(String(food_id), "wide_plate"))

static func active_tool_for(food_id: StringName, fallback: String = "spatula") -> String:
	return get_tool(FOOD_ACTIVE_TOOL.get(String(food_id), fallback))


# --- protagonist (플레이어 셰프 아바타) — "Choose Your Chef" preset × 4 감정 ---
# Player-Chef Integration (2026-06-08): 플레이어가 선택한 본인 아바타. 손님(먹는 쪽, character/)과
# 역할 분리 — 주인공은 "요리하는 나". north star 톤(cocoa outline / soft volumetric / warm).
#
# Choose-Your-Chef 재설계 (2026-06-12): 성별 이분법(Female/Male) 폐기 → 이름·성격 preset 4종.
# preset id(저장값, backward-compat):
#   "f"     → Hana  (Calm & careful, 크림 자켓+테라코타 앞치마)    파일: chef_f_*
#   "m"     → Joon  (Fast & bold, navy 자켓+sand 앞치마)           파일: chef_m_*
#   "leo"   → Leo   (Eager & humble, 외국인)                       파일: leo_*
#   "amara" → Amara (Confident & graceful, 외국인)                 파일: amara_*
# 기존 save의 "f"/"m" 값은 그대로 Hana/Joon으로 해석(backward-compat). 신규 leo/amara 추가.
#   emotion : "neutral"(메뉴/타이틀 host) / "cheer"(result 성공) / "think"(tutorial/가이드) /
#             "cook"(now cooking/present)
# 16장 transparent: chef_{f|m}_{emotion}.png + {leo|amara}_{emotion}.png
const PROTAGONIST_EMOTIONS := ["neutral", "cheer", "think", "cook"]
# 유효 preset id (저장값). f/m는 기존 chef_f/chef_m 파일 prefix, leo/amara/min/ari는 bare id prefix.
# Choose-Your-Chef 6 preset (2026-06-13): min/ari 추가 (gimbap-visual-quality-rebuild 작업 2).
#   "min" → Min  (Creative & balanced)  파일: min_*
#   "ari" → Ari  (Cheerful & curious)   파일: ari_*
const PROTAGONIST_PRESETS := ["f", "m", "leo", "amara", "min", "ari"]
# Backward-compat alias — 기존 코드(protagonist_smoke 등)가 참조하던 성별 상수. 의미는 preset.
const PROTAGONIST_GENDERS := ["f", "m", "leo", "amara", "min", "ari"]
const _PROTAGONIST_DIR := "res://art/sprites/protagonist/"
# preset id → 파일 prefix. f/m는 "chef_f"/"chef_m"(기존 자산 호환), leo/amara/min/ari는 bare id.
const _PROTAGONIST_PREFIX := {
	"f": "chef_f", "m": "chef_m", "leo": "leo", "amara": "amara",
	"min": "min", "ari": "ari",
}


## get_protagonist("f", "cheer") → res://art/sprites/protagonist/chef_f_cheer.png
## get_protagonist("leo", "cook") → res://art/sprites/protagonist/leo_cook.png
## preset: "f"/"m"/"leo"/"amara" (그 외 값은 "f"로 폴백 — backward-compat). 인자명은 호환 위해
## gender 유지(의미는 preset id). emotion: neutral/cheer/think/cook (미존재 시 neutral 폴백).
## 파일 미존재 시 ResourceLoader.exists() == false면 "" (caller가 procedural/이니셜 폴백).
static func get_protagonist(gender: String, emotion: String = "neutral") -> String:
	var p: String = gender if gender in PROTAGONIST_PRESETS else "f"
	var e: String = emotion if emotion in PROTAGONIST_EMOTIONS else "neutral"
	var prefix: String = _PROTAGONIST_PREFIX.get(p, "chef_f")
	var path: String = "%s%s_%s.png" % [_PROTAGONIST_DIR, prefix, e]
	if ResourceLoader.exists(path):
		return path
	# emotion 미존재 시 같은 preset의 neutral로 graceful fallback.
	var fallback: String = "%s%s_neutral.png" % [_PROTAGONIST_DIR, prefix]
	return fallback if ResourceLoader.exists(fallback) else ""


# --- reaction (별점 → 가족 리액션) — 무변경 ---
const REACTION := {
	"1": "res://art/sprites/reaction/star1.png",
	"2": "res://art/sprites/reaction/star2.png",
	"3": "res://art/sprites/reaction/star3.png",
}

static func reaction(stars: int) -> String:
	return REACTION.get(str(stars), "")


static func file_exists(path: String) -> bool:
	if path == "":
		return false
	return ResourceLoader.exists(path)


# =====================================================================================
# LEGACY shim — ADR-005 rhythm flow(round_controller.gd / stage_prep / stage_timing)
#   호환용. 5-layer cooking module은 이 API를 쓰지 않는다(get_ingredient/get_vessel 사용).
#   기존 t1_*/t2_* per-food prep 자산을 그대로 해석 — 레거시 데모 무변경.
# =====================================================================================

static func prep_whole(fid: StringName) -> String:
	var p := "res://art/sprites/ingredient/%s_whole.png" % String(fid)
	return p if ResourceLoader.exists(p) else ""

static func prep_cut(fid: StringName) -> String:
	var p := "res://art/sprites/ingredient/%s_cut.png" % String(fid)
	return p if ResourceLoader.exists(p) else ""

const _LEGACY_METHOD_TOOL := {
	"boil": "res://art/sprites/tool/boil.png",
	"deepfry": "res://art/sprites/tool/deepfry.png",
	"grill": "res://art/sprites/tool/grill.png",
	"marinate": "res://art/sprites/tool/marinate.png",
	"mix": "res://art/sprites/tool/mix.png",
	"panfry": "res://art/sprites/tool/panfry.png",
	"roll": "res://art/sprites/tool/roll.png",
	"stirfry": "res://art/sprites/tool/stirfry.png",
	"toss": "res://art/sprites/tool/toss.png",
}

static func method_tool(mid: StringName) -> String:
	return _LEGACY_METHOD_TOOL.get(String(mid), "")
