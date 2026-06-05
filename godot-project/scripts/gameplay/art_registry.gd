## ArtRegistry — food_id / method_id → 스프라이트 res:// 경로 (자동 생성).
##
## 생성: tools/import_art_to_godot.py (수정 금지 — 매핑 변경은 임포터에서).
## 일부 음식 완성샷은 미LOCK placeholder (art-anchor-rubric 참조).
class_name ArtRegistry
extends RefCounted

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

const PREP_WHOLE := {
	"t1_002": "res://art/sprites/ingredient/t1_002_whole.png",
	"t1_003": "res://art/sprites/ingredient/t1_003_whole.png",
	"t1_004": "res://art/sprites/ingredient/t1_004_whole.png",
	"t1_005": "res://art/sprites/ingredient/t1_005_whole.png",
	"t1_006": "res://art/sprites/ingredient/t1_006_whole.png",
	"t1_007": "res://art/sprites/ingredient/t1_007_whole.png",
	"t1_008": "res://art/sprites/ingredient/t1_008_whole.png",
	"t2_008": "res://art/sprites/ingredient/t2_008_whole.png",
	"t2_010": "res://art/sprites/ingredient/t2_010_whole.png",
	"t2_012": "res://art/sprites/ingredient/t2_012_whole.png",
	"t2_013": "res://art/sprites/ingredient/t2_013_whole.png",
	"t2_014": "res://art/sprites/ingredient/t2_014_whole.png",
}

const PREP_CUT := {
	"t1_002": "res://art/sprites/ingredient/t1_002_cut.png",
	"t1_003": "res://art/sprites/ingredient/t1_003_cut.png",
	"t1_004": "res://art/sprites/ingredient/t1_004_cut.png",
	"t1_005": "res://art/sprites/ingredient/t1_005_cut.png",
	"t1_006": "res://art/sprites/ingredient/t1_006_cut.png",
	"t1_007": "res://art/sprites/ingredient/t1_007_cut.png",
	"t1_008": "res://art/sprites/ingredient/t1_008_cut.png",
	"t2_008": "res://art/sprites/ingredient/t2_008_cut.png",
	"t2_010": "res://art/sprites/ingredient/t2_010_cut.png",
	"t2_012": "res://art/sprites/ingredient/t2_012_cut.png",
	"t2_013": "res://art/sprites/ingredient/t2_013_cut.png",
	"t2_014": "res://art/sprites/ingredient/t2_014_cut.png",
}

const METHOD_TOOL := {
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

static func food(fid: StringName) -> String:
	return FOOD.get(String(fid), "")

static func prep_whole(fid: StringName) -> String:
	return PREP_WHOLE.get(String(fid), "")

static func prep_cut(fid: StringName) -> String:
	return PREP_CUT.get(String(fid), "")

static func method_tool(mid: StringName) -> String:
	return METHOD_TOOL.get(String(mid), "")

const REACTION := {
	"1": "res://art/sprites/reaction/star1.png",
	"2": "res://art/sprites/reaction/star2.png",
	"3": "res://art/sprites/reaction/star3.png",
}

static func reaction(stars: int) -> String:
	return REACTION.get(str(stars), "")


# --- Phase A art-swap helpers ---
## 모듈별 LOCK art 경로 모음. 파일이 실제로 존재하지 않으면 module은
## graceful하게 procedural placeholder로 fallback (gameplay 무영향).

const CUTTING_BOARD := "res://art/sprites/cut/cutting_board.png"
const CUT_SLICED_ROUNDS := "res://art/sprites/cut/cut_sliced_rounds.png"

const TOOL_BOIL := "res://art/sprites/tool/boil.png"            # 솥 끓이기
const TOOL_DEEPFRY := "res://art/sprites/tool/deepfry.png"      # 튀김기
const TOOL_FRYING_PAN := "res://art/sprites/tool/frying_pan.png"# 후라이팬 (panfry/flip)
const TOOL_GRILL := "res://art/sprites/tool/grill.png"          # 그릴 (갈비)
const TOOL_GRILL_WIRE := "res://art/sprites/tool/grill_wire_grate.png"
const TOOL_MARINATE := "res://art/sprites/tool/marinate.png"    # 양념재우기 보울
const TOOL_MIX := "res://art/sprites/tool/mix.png"              # 비빔(plate-pick용 대안)
const TOOL_PANFRY := "res://art/sprites/tool/panfry.png"        # panfry (해물파전)
const TOOL_POT_YANGUN := "res://art/sprites/tool/pot_yangun.png"# 양은냄비 (라면)
const TOOL_ROLL := "res://art/sprites/tool/roll.png"            # 김발 (김밥)
const TOOL_STIRFRY := "res://art/sprites/tool/stirfry.png"      # 웍 + 뒤집개 (stir)
const TOOL_STOVETOP := "res://art/sprites/tool/stovetop_gas_burner.png"
const TOOL_TOSS := "res://art/sprites/tool/toss.png"            # 토스(불판 등)


## 한 음식의 timing module에 어떤 도구를 보일지 결정 — primary_cooking_method 우선.
## boil → pot_yangun, grill → grill, deepfry → deepfry, 기본 boil pot.
static func timing_tool_for(food_id: StringName) -> String:
	var fid := String(food_id)
	# 음식별 명시 override (라면 양은냄비 / 갈비 그릴 / 콘도그 튀김기 등)
	match fid:
		"t1_002", "t1_008", "m_kimchi_jjigae", "m_doenjang_jjigae", "m_maeuntang", "t2_013":
			return TOOL_POT_YANGUN  # 끓이기
		"t2_012":
			return TOOL_GRILL       # 갈비구이
		"t1_007":
			return TOOL_DEEPFRY     # 콘도그
		"t1_006":
			return TOOL_PANFRY      # 해물파전 (timing 단계라도 팬 그대로)
		_:
			return TOOL_POT_YANGUN


## slice module에 보일 칼+도마 보조 — 도마는 항상 같은 art.
static func slice_board() -> String:
	return CUTTING_BOARD


static func file_exists(path: String) -> bool:
	if path == "":
		return false
	return ResourceLoader.exists(path)
