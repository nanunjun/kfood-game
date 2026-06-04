## SeasoningGauge — 양념 게이지 UI (M0).
##
## rhythm-prototype-spec §4. 색깔별 세로 칸 게이지, 탭마다 "딸깍" 채움. 숫자 대신 칸(pip).
## 결과 자연어용 카운트(count)를 보관.
class_name SeasoningGauge
extends Control

const CELL_H := 40.0
const CELL_W := 110.0
const GAP := 28.0

# 양념 색 (spec §4)
const COLORS := {
	&"gochugaru": Color(0.827, 0.282, 0.212),
	&"ganjang": Color(0.420, 0.239, 0.122),
	&"sogeum": Color(0.961, 0.961, 0.941),
	&"seoltang": Color(0.984, 0.918, 0.824),
	&"maneul": Color(0.788, 0.839, 0.494),
	&"yuksu": Color(0.878, 0.659, 0.180),
	&"soup": Color(0.74, 0.36, 0.20),       # 라면 스프(분말) — 간·감칠
	&"gochujang": Color(0.78, 0.20, 0.13),  # 고추장
	&"chamgireum": Color(0.80, 0.58, 0.20), # 참기름
	&"gukganjang": Color(0.36, 0.20, 0.10), # 국간장
	&"doenjang": Color(0.62, 0.47, 0.24),   # 된장
	&"chojanga": Color(0.72, 0.55, 0.18),   # 초간장
	&"saeujeot": Color(0.90, 0.85, 0.78),   # 새우젓
}

var _slots: Array = []           # [{id, max, count, cells:[ColorRect], label}]


## slots_def: [{id:StringName, max:int}]
func setup(slots_def: Array) -> void:
	_slots = []
	for child in get_children():
		child.queue_free()
	var n: int = slots_def.size()
	var total_w: float = n * CELL_W + (n - 1) * GAP
	var start_x: float = -total_w * 0.5
	for i in range(n):
		var sd: Dictionary = slots_def[i]
		var col_x: float = start_x + i * (CELL_W + GAP)
		var maxn: int = int(sd.get("max", 6))
		var cells: Array = []
		for c in range(maxn):
			var rect := ColorRect.new()
			rect.size = Vector2(CELL_W, CELL_H - 6.0)
			rect.position = Vector2(col_x, -float(c + 1) * CELL_H)
			rect.color = Color(0, 0, 0, 0.12)
			rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(rect)
			cells.append(rect)
		_slots.append({"id": sd["id"], "max": maxn, "count": 0, "cells": cells})


## 탭 1회 → 해당 슬롯 +1단위(증분=Tuning.seasoning_increment 반올림, 최소 1). "딸깍" 연출.
func add_tap(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= _slots.size():
		return
	var s: Dictionary = _slots[slot_index]
	if s["count"] >= s["max"]:
		return  # MAX (차분히 무시)
	var step: int = maxi(1, int(round(get_node("/root/Tuning").seasoning_increment)))
	for _i in range(step):
		if s["count"] >= s["max"]:
			break
		var cell: ColorRect = s["cells"][s["count"]]
		cell.color = COLORS.get(s["id"], Color.WHITE)
		cell.scale = Vector2(1.0, 0.0)
		cell.pivot_offset = Vector2(0, cell.size.y)
		var tw := create_tween()
		tw.tween_property(cell, "scale", Vector2.ONE, 0.09).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		s["count"] = int(s["count"]) + 1
	var am := get_node_or_null("/root/AudioManager")
	if am and am.has_method("play"):
		am.play(&"ui_select")
	var hm := get_node_or_null("/root/HapticManager")
	if hm:
		hm.play(hm.SEASONING)


func count_of(slot_index: int) -> int:
	if slot_index < 0 or slot_index >= _slots.size():
		return 0
	return int(_slots[slot_index]["count"])


# 슬롯 id → 영어 표기(romanized). UI는 영어 1차.
const NAMES := {
	&"gochugaru": "Gochugaru", &"ganjang": "Soy Sauce", &"sogeum": "Salt",
	&"seoltang": "Sugar", &"maneul": "Garlic", &"yuksu": "Anchovy Broth",
	&"soup": "Soup Base", &"gochujang": "Gochujang", &"chamgireum": "Sesame Oil",
	&"gukganjang": "Soup Soy Sauce", &"doenjang": "Doenjang",
	&"chojanga": "Vinegar Soy", &"saeujeot": "Salted Shrimp",
}


static func display_name(id) -> String:
	return NAMES.get(id, String(id))


## Result natural-language summary: "Gochugaru x4 · Soy Sauce x6"
func summary_en() -> String:
	var parts: Array = []
	for s in _slots:
		parts.append("%s x%d" % [NAMES.get(s["id"], String(s["id"])), int(s["count"])])
	return " · ".join(parts)
