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
