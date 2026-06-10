## JulienneModule — Gimbap Vertical Slice Stage 2 (Preparation: 채썰기).
##
## 김밥 vertical slice 전용 Prep stage. 기존 SliceModule(drag-knife cutting engine)을 *상속*해
## 재사용하고, 그 위에 **rhythm consistency + spacing consistency + thickness consistency** 3축을
## 더한다. 신규 module 0 정책(ADR-011) 정합 — Julienne은 "Slice 확장"이지 신규 module이 아니다.
##
## 핵심 mechanic (design §3.1): music rhythm game 아님 — **knife consistency.**
##   긴 얇은 strip을 angle + rhythm(cut 간 시간 일관) + spacing(cut 간 x 위치 일관)으로 반복.
##   prep_quality = weighted_avg(angle 25% + rhythm 25% + spacing 25% + thickness 25%) ∈ [0,1].
##
## SCORING contract 정합: base_module의 `module_completed(0~100)` 그대로 emit. 부모 SliceModule이
## `_score_cut()`로 per-cut angle/speed를 채점하므로, 여기서는 cut 시각(timestamp)·x위치 배열을
## 누적해 표준편차(consistency)를 산출하고 최종 4축 가중평균을 0~100으로 변환해 _finalize override.
## runner는 이 점수를 prep_quality로 받아 4-factor 준비 20%에 매핑한다(신규 4-factor 축 0).
##
## visual (design §3.3, Success Criteria #2 핵심 — 반드시 변함):
##   perfect → carrot_julienne(긴 고른 얇은 strip) + sparkle / "Even!"
##   bad     → carrot_julienne_bad(두껍고 uneven chunky strip, 미존재 시 ArtRegistry fallback +
##             procedural chunky pile) / "Uneven"
extends "res://scripts/cooking_modules/slice_module.gd"

# 4축 consistency 가중치 (design §3.2 — 각 25%).
const W_ANGLE: float = 0.25
const W_RHYTHM: float = 0.25
const W_SPACING: float = 0.25
const W_THICKNESS: float = 0.25

# bad/perfect grade 임계 (prep_quality 0~1 기준). 시각 분기 + live label.
const GRADE_PERFECT: float = 0.80
const GRADE_GOOD: float = 0.55

# cut 시각/위치 누적 (consistency 산출용 — 부모는 cut score만 누적).
var _cut_times_ms: Array = []        # 각 cut release 시각 (ms)
var _cut_x: Array = []               # 각 cut 의 x 위치 (board 좌표)
var _live_lbl: Label = null          # live "Even/Uneven" feedback

# 산출된 4축 (0~1). _finalize에서 채운다 — runner/shot이 조회 가능.
var prep_angle: float = 0.0
var prep_rhythm: float = 0.0
var prep_spacing: float = 0.0
var prep_thickness: float = 0.0
var prep_quality: float = 0.0        # 최종 4축 가중평균 [0,1] (runner가 읽음)


func _module_start(params: Dictionary) -> void:
	# 부모(SliceModule)가 board/knife/gesture/indicator 전부 구성. julienne style 고정 +
	# cut 수를 늘려(채썰기는 여러 번 반복) rhythm/spacing 표본을 확보한다.
	var p: Dictionary = params.duplicate()
	p["cut_style"] = "julienne"                       # angle 90° parallel straight (CUT_STYLES)
	p["tap_count"] = int(params.get("tap_count", 6))  # 채썰기 = 반복 절단(표본 ↑)
	super._module_start(p)
	# 헤더/instruction을 julienne 전용 카피로 덮어쓴다 (부모 "Slice" → "Julienne").
	_relabel_header("Julienne", "Keep a steady rhythm — even, thin strips")
	_build_live_feedback()


# 부모 헤더 카드의 텍스트만 교체 (재구축 없이 — 노드 재사용).
func _relabel_header(title: String, howto: String) -> void:
	var head := _find_label_by_name(self, "ModuleHeader")
	if head != null:
		var step_no: int = int(_params.get("step_no", 1))
		var step_total: int = int(_params.get("step_total", 1))
		var dish_en: String = String((_params.get("menu", {}) as Dictionary).get("name_en", ""))
		if dish_en != "":
			head.text = "Step %d/%d  ·  %s  —  %s" % [step_no, step_total, title, dish_en]
		else:
			head.text = "Step %d/%d  ·  %s" % [step_no, step_total, title]
	var sub := _find_label_by_name(self, "ModuleHowto")
	if sub != null:
		sub.text = howto
	_set_instruction("Drag down through the carrot — keep an even beat ↓")


func _find_label_by_name(root: Node, target: String) -> Label:
	for c in root.get_children():
		if c.name == target and c is Label:
			return c
		var found := _find_label_by_name(c, target)
		if found != null:
			return found
	return null


# live "Even / Uneven" 밴드 — control zone(indicator 위)에 작게. cut 마다 갱신.
func _build_live_feedback() -> void:
	_live_lbl = Label.new()
	_live_lbl.name = "JulienneLive"
	_live_lbl.position = Vector2(40, 1320)
	_live_lbl.size = Vector2(1000, 52)
	_live_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_live_lbl.add_theme_font_size_override("font_size", 34)
	_live_lbl.add_theme_color_override("font_color", Color(0.55, 0.78, 0.45))
	_live_lbl.add_theme_color_override("font_outline_color", Color(0.15, 0.10, 0.04))
	_live_lbl.add_theme_constant_override("outline_size", 4)
	_live_lbl.z_index = L5_VFX
	_live_lbl.text = ""
	add_child(_live_lbl)


# 각 cut release 시 부모 핸들러를 호출하되, consistency 표본(시각/x)을 추가 누적한다.
func _on_drag_released(info: Dictionary) -> void:
	if _finished:
		return
	var before: int = _cuts_done
	super._on_drag_released(info)
	# 부모가 cut을 유효 처리(=_cuts_done 증가)했을 때만 표본을 기록.
	if _cuts_done > before:
		_cut_times_ms.append(float(Time.get_ticks_msec()))
		_cut_x.append(float((info.get("end", Vector2.ZERO) as Vector2).x))
		_update_live_feedback()


# 진행 중 일관성 추정 — 직전 cut 간격들의 변동으로 Even/Uneven을 실시간 표시.
func _update_live_feedback() -> void:
	if not is_instance_valid(_live_lbl):
		return
	if _cut_times_ms.size() < 2:
		_live_lbl.text = "..."
		return
	var rhythm: float = _consistency_from_intervals(_cut_times_ms)
	var spacing: float = _consistency_from_intervals(_cut_x)
	var live: float = (rhythm + spacing) * 0.5
	if live >= GRADE_PERFECT:
		_live_lbl.text = "Even!"
		_live_lbl.add_theme_color_override("font_color", Color(0.45, 0.85, 0.45))
	elif live >= GRADE_GOOD:
		_live_lbl.text = "Mostly even"
		_live_lbl.add_theme_color_override("font_color", Color(0.92, 0.78, 0.32))
	else:
		_live_lbl.text = "Uneven"
		_live_lbl.add_theme_color_override("font_color", Color(0.90, 0.45, 0.32))


## 인접 표본 간격의 변동계수(CV)를 [0,1] 일관성으로 변환. 간격이 고를수록 1.0.
## design §3.2: rhythm = cut 간 시간 간격 표준편차 / spacing = cut 간 x 간격 표준편차.
func _consistency_from_intervals(samples: Array) -> float:
	if samples.size() < 3:
		# cut 표본 부족 — 중립 점수(consistency를 단정할 수 없음).
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
	var cv: float = sd / mean        # 변동계수 (0 = 완벽히 고름)
	# CV 0 → 1.0, CV 0.6+ → 0.0 (선형 감소). casual 관대 band.
	return clampf(1.0 - cv / 0.6, 0.0, 1.0)


## 부모 _finalize override — angle/speed(부모 cut 점수) + rhythm/spacing/thickness 종합.
## prep_quality 4축 가중평균을 0~100으로 변환해 base_module._finish로 emit (contract 무변경).
func _finalize() -> void:
	# (1) angle accuracy — 부모의 per-cut 점수 평균(angle+speed 종합)을 angle 축으로 사용.
	var cut_avg: float = 0.0
	for s in _cut_scores:
		cut_avg += float(s)
	cut_avg = cut_avg / float(maxi(1, _cut_scores.size())) / 100.0   # → [0,1]
	prep_angle = clampf(cut_avg, 0.0, 1.0)
	# (2) rhythm consistency — cut 간 시간 간격 일관성.
	prep_rhythm = _consistency_from_intervals(_cut_times_ms)
	# (3) spacing consistency — cut 간 x 위치 간격 일관성.
	prep_spacing = _consistency_from_intervals(_cut_x)
	# (4) thickness consistency — rhythm+spacing이 유도(얇고 고른가). 두 축의 곱-평균.
	prep_thickness = clampf((prep_rhythm * 0.5 + prep_spacing * 0.5), 0.0, 1.0)
	# 4축 가중평균 → prep_quality [0,1].
	prep_quality = clampf(
		prep_angle * W_ANGLE + prep_rhythm * W_RHYTHM
		+ prep_spacing * W_SPACING + prep_thickness * W_THICKNESS, 0.0, 1.0)
	# 시각 분기 — perfect = 고른 얇은 strip / bad = chunky uneven (반드시 변함).
	_apply_grade_visual(prep_quality)
	# base_module._finish(0~100) — runner contract 동일.
	_finish(prep_quality * 100.0)


# prep_quality grade → strip 시각. perfect/good/bad가 명확히 다르게(Success Criteria #2).
func _apply_grade_visual(q: float) -> void:
	# 부모 _finalize의 swap(whole→cut)을 먼저 수행하되, bad일 때는 chunky 변형으로 교체.
	if is_instance_valid(_whole_tex):
		var tw2 := _whole_tex.create_tween()
		tw2.tween_property(_whole_tex, "modulate:a", 0.0, 0.2)
	if q >= GRADE_PERFECT:
		# perfect — 고른 julienne strip 노출 + sparkle.
		if is_instance_valid(_cut_tex):
			var tw := _cut_tex.create_tween()
			tw.tween_property(_cut_tex, "modulate:a", 1.0, 0.2)
		CookingFX.serving_sparkle(self, Vector2(INGREDIENT_RECT.position.x + INGREDIENT_RECT.size.x * 0.5,
			INGREDIENT_RECT.position.y + INGREDIENT_RECT.size.y * 0.5), 12)
		if is_instance_valid(_live_lbl):
			_live_lbl.text = "Even, thin strips!"
			_live_lbl.add_theme_color_override("font_color", Color(0.45, 0.88, 0.45))
	else:
		# good/bad — chunky/uneven 변형 sprite로 swap(미존재 시 procedural chunky pile).
		_swap_to_bad_strip(q)
		if is_instance_valid(_live_lbl):
			if q >= GRADE_GOOD:
				_live_lbl.text = "Mostly even — minor uneven"
				_live_lbl.add_theme_color_override("font_color", Color(0.92, 0.78, 0.32))
			else:
				_live_lbl.text = "Uneven, chunky strips"
				_live_lbl.add_theme_color_override("font_color", Color(0.90, 0.45, 0.32))


# bad/uneven 변형 sprite로 교체. carrot_julienne_bad 미존재 시(생성 중) ArtRegistry fallback
# + procedural chunky overlay(두꺼운 제각각 조각)로 "bad prep이 시각으로 보인다"를 보장.
func _swap_to_bad_strip(q: float) -> void:
	var bad_path: String = ArtRegistry.get_ingredient("carrot", "julienne_bad")
	# fallback: julienne_bad 미존재 시 ArtRegistry가 carrot_whole/julienne로 graceful 반환 →
	# 그 위에 procedural chunky overlay로 "uneven chunky" 시각을 명시적으로 덧입힌다.
	var have_bad_asset: bool = bad_path.find("julienne_bad") != -1 and ArtRegistry.file_exists(bad_path)
	if have_bad_asset and is_instance_valid(_cut_tex):
		_cut_tex.texture = load(bad_path)
		var tw := _cut_tex.create_tween()
		tw.tween_property(_cut_tex, "modulate:a", 1.0, 0.2)
	else:
		# 기존 julienne sprite를 노출하되 procedural chunky overlay를 덧입힌다.
		if is_instance_valid(_cut_tex):
			var tw := _cut_tex.create_tween()
			tw.tween_property(_cut_tex, "modulate:a", clampf(0.5 + q * 0.5, 0.0, 1.0), 0.2)
		_build_chunky_overlay(q)


# procedural chunky pile — 두껍고 제각각 길이의 주황 조각을 ingredient rect에 흩뿌린다.
# carrot_julienne_bad asset이 ship되면 이 fallback은 닿지 않는다.
func _build_chunky_overlay(q: float) -> void:
	var holder := Control.new()
	holder.name = "ChunkyOverlay"
	holder.position = INGREDIENT_RECT.position
	holder.size = INGREDIENT_RECT.size
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.z_index = L3_INGREDIENT + 1
	add_child(holder)
	# q 낮을수록 더 chunky/uneven(폭/길이 편차 ↑). 6~8 조각.
	var n: int = 7
	var unevenness: float = clampf(1.0 - q, 0.3, 1.0)
	for i in range(n):
		var chunk := ColorRect.new()
		chunk.color = Color(0.92, 0.52, 0.20).lerp(Color(0.84, 0.42, 0.14), randf())
		var w: float = randf_range(26.0, 26.0 + 70.0 * unevenness)   # 두께 제각각
		var h: float = randf_range(70.0, 70.0 + 120.0 * unevenness)  # 길이 제각각
		chunk.size = Vector2(w, h)
		chunk.position = Vector2(
			randf_range(0.0, holder.size.x - w),
			randf_range(0.0, holder.size.y - h))
		chunk.rotation = deg_to_rad(randf_range(-18.0, 18.0) * unevenness)
		chunk.pivot_offset = chunk.size * 0.5
		chunk.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(chunk)


# --- runner / shot 조회용 getter (consequence chain 전달) ---

## prep_quality [0,1] — runner가 quality-state로 읽어 4-factor 준비 20% + roll consequence(§8.2)에 사용.
func get_prep_quality() -> float:
	return prep_quality


## 4축 분해 (debug / shot label). [angle, rhythm, spacing, thickness] 각 [0,1].
func get_prep_dimensions() -> Dictionary:
	return {"angle": prep_angle, "rhythm": prep_rhythm,
		"spacing": prep_spacing, "thickness": prep_thickness}
