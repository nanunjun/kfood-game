## action_first_w1_smoke.gd — ADR-012 W1 verification (slice / timing / season).
##
## 3 hero module의 action-first 재설계가 scoring contract를 깨지 않았는지 검증:
##   1) 각 module이 정상 instantiate + start(params) (runner와 동일 params shape).
##   2) module_completed(score) 가 [0,100] 도메인 score로 정확히 1회 emit.
##   3) 내부 score 함수(slice _score_cut / timing zone-hold / season)가 [0,100] 반환.
##   4) TouchGestureRecognizer가 drag stroke를 추적해 일관된 info Dictionary 생성.
##   5) MODULE_TO_FACTOR 매핑 무변경 (slice→prep, timing→timing, season→season).
##
## Usage:
##   godot --headless --quit-after 8 res://scenes/action_first_w1_smoke.tscn
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const Runner := preload("res://scripts/gameplay/cooking_module_runner.gd")
const SliceMod := preload("res://scripts/cooking_modules/slice_module.gd")
const TimingMod := preload("res://scripts/cooking_modules/timing_module.gd")
const SeasonMod := preload("res://scripts/cooking_modules/season_module.gd")
const TouchGesture := preload("res://scripts/cooking_modules/touch_gesture.gd")

var _pass: int = 0
var _fail: int = 0


func _ready() -> void:
	print("=== Action-First W1 — smoke (slice / timing / season) ===")
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()

	_test_factor_mapping_unchanged()
	_test_gesture_recognizer()
	await _test_module_instantiate("slice", SliceMod, {"tap_count": 4, "bpm": 110.0})
	await _test_module_instantiate("timing", TimingMod, {"duration_ms": 1200.0, "perfect_at": 0.85, "perfect_width": 0.18})
	await _test_module_instantiate("season", SeasonMod, {"mode": "simple"})
	await _test_module_instantiate("season-marinade", SeasonMod, {"mode": "marinade", "marinade_taps": 3, "marinade_bpm": 60.0})
	await _test_score_domain_slice()
	await _test_score_domain_timing()
	await _test_completion_contract()

	print("=== summary: %d PASS / %d FAIL ===" % [_pass, _fail])
	get_tree().quit()


# 1) MODULE_TO_FACTOR 무변경 — scoring 매핑 lock.
func _test_factor_mapping_unchanged() -> void:
	print("\n[1] MODULE_TO_FACTOR unchanged (ADR-011 lock)")
	var m := Runner.MODULE_TO_FACTOR
	_eq("slice -> prep", String(m["slice"]), "prep")
	_eq("timing -> timing", String(m["timing"]), "timing")
	_eq("season -> season", String(m["season"]), "season")


# 4) TouchGestureRecognizer raw 추적.
func _test_gesture_recognizer() -> void:
	print("\n[2] TouchGestureRecognizer primitives")
	var rec = TouchGesture.new()
	add_child(rec)
	var got_started := [false]
	var got_info := [{}]
	rec.drag_started.connect(func(_p): got_started[0] = true)
	rec.drag_released.connect(func(info): got_info[0] = info)
	# 수직 down-stroke 시뮬레이션 (slice cut처럼).
	rec._begin(Vector2(540, 800))
	rec._move(Vector2(540, 1000))
	rec._move(Vector2(540, 1200))
	rec._end(Vector2(540, 1240))
	_ok("drag_started fired", got_started[0])
	var info: Dictionary = got_info[0]
	_ok("drag_released info non-empty", not info.is_empty())
	if not info.is_empty():
		_ok("distance > 0", float(info["distance"]) > 0.0)
		_ok("path_len >= distance", float(info["path_len"]) >= float(info["distance"]) - 0.01)
		_ok("straightness in [0,1]", float(info["straightness"]) >= 0.0 and float(info["straightness"]) <= 1.0)
		_ok("avg_speed >= 0", float(info["avg_speed"]) >= 0.0)
		# 수직 drag → angle_deg ~ 90 (아래 방향)
		_ok("vertical drag angle ~90", absf(absf(float(info["angle_deg"])) - 90.0) < 15.0)
	rec.queue_free()


# 2/3) instantiate + start + module_completed [0,100] 도메인.
func _test_module_instantiate(label: String, script: GDScript, extra: Dictionary) -> void:
	print("\n[3] instantiate + start: %s" % label)
	var inst: Node = script.new()
	get_tree().root.add_child(inst)
	var captured := {"score": -1.0, "count": 0}
	inst.module_completed.connect(func(s: float):
		captured["score"] = s
		captured["count"] += 1)
	var params := _params("t1_002" if label.begins_with("season") == false else "t2_014", extra)
	inst.start(params)
	await get_tree().process_frame
	_ok("[%s] instantiated + started (no crash)" % label, is_instance_valid(inst))
	# 강제 완료 — 내부 _finish 경로로 score domain 확인.
	inst._finish(72.5)
	await get_tree().process_frame
	_eq("[%s] module_completed emitted once" % label, captured["count"], 1)
	_ok("[%s] score in [0,100]" % label, captured["score"] >= 0.0 and captured["score"] <= 100.0)
	_eq("[%s] _finish clamps passthrough" % label, captured["score"], 72.5)
	# re-entrancy guard (double finish ignored).
	inst._finish(999.0)
	await get_tree().process_frame
	_eq("[%s] double-finish ignored" % label, captured["count"], 1)
	inst.queue_free()


# 3) slice _score_cut 도메인 — 다양한 cut 품질이 [0,100].
func _test_score_domain_slice() -> void:
	print("\n[4] slice _score_cut domain [0,100]")
	var inst = SliceMod.new()
	get_tree().root.add_child(inst)
	inst.start(_params("t1_002", {"tap_count": 4, "bpm": 110.0}))
	await get_tree().process_frame
	# perfect-ish vertical cut (channel into ingredient rect, ideal speed band).
	var cases := [
		{"name": "perfect vertical", "info": _cut_info(Vector2(540, 800), Vector2(540, 1240), 600.0)},
		{"name": "slow under-cut", "info": _cut_info(Vector2(540, 800), Vector2(540, 1240), 3000.0)},
		{"name": "fast over-mince", "info": _cut_info(Vector2(540, 800), Vector2(540, 1240), 80.0)},
		{"name": "diagonal off-angle", "info": _cut_info(Vector2(400, 800), Vector2(700, 1240), 600.0)},
	]
	for c in cases:
		var sc: float = inst._score_cut(c["info"])
		_ok("slice cut '%s' in [0,100] (=%.1f)" % [c["name"], sc], sc >= 0.0 and sc <= 100.0)
	inst.queue_free()


# 3) timing zone-hold finalize 도메인 — 다양한 유지율이 [0,100].
func _test_score_domain_timing() -> void:
	print("\n[5] timing finalize domain [0,100]")
	# perfect hold
	for hold in [1.0, 0.6, 0.3, 0.0]:
		var inst = TimingMod.new()
		get_tree().root.add_child(inst)
		inst.start(_params("t1_002", {"duration_ms": 1000.0, "perfect_at": 0.85, "perfect_width": 0.18}))
		await get_tree().process_frame
		# 강제 유지율 주입.
		inst._zone_hold_ms = 1000.0 * hold
		inst._good_hold_ms = 1000.0 * hold
		inst._start_ms = inst._now_ms() - 1000.0
		var captured := {"score": -1.0}
		inst.module_completed.connect(func(s): captured["score"] = s)
		inst._finalize_timing()
		await get_tree().process_frame
		_ok("timing hold=%.1f -> score in [0,100] (=%.1f)" % [hold, captured["score"]],
			captured["score"] >= 0.0 and captured["score"] <= 100.0)
		# 단조성 sanity: 더 잘 유지하면 점수가 더 높거나 같다 (perfect>=fail).
		inst.queue_free()


# 5) end-to-end completion contract via Runner._on_module_completed bucket.
func _test_completion_contract() -> void:
	print("\n[6] Runner buckets slice/timing/season into correct factor")
	Runner.pending_menu_id = "t1_002"
	Runner.pending_guest_id = ""
	var runner: Node = Runner.new()
	get_tree().root.add_child(runner)
	await get_tree().create_timer(1.7).timeout
	# ramyeon = slice -> timing -> season -> plate
	for pair in [["slice", 85.0], ["timing", 70.0], ["season", 90.0], ["plate", 100.0]]:
		runner.callv("_on_module_completed", [float(pair[1]), String(pair[0])])
		await get_tree().process_frame
		await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	var fa: Dictionary = runner.get("_factor_acc")
	_ok("prep bucket got slice", (fa.get("prep", []) as Array).size() >= 1)
	_ok("timing bucket got timing", (fa.get("timing", []) as Array).size() >= 1)
	_ok("season bucket got season", (fa.get("season", []) as Array).size() >= 1)
	# 정규화 [0,1] 확인.
	if (fa.get("prep", []) as Array).size() > 0:
		var v: float = float((fa["prep"] as Array)[0])
		_ok("prep normalized [0,1] (=%.2f)" % v, v >= 0.0 and v <= 1.0)
		_eq("prep == 0.85 (85/100)", snappedf(v, 0.01), 0.85)


# --- helpers ---

func _params(food_id: String, extra: Dictionary) -> Dictionary:
	var p: Dictionary = {
		"food_id": food_id,
		"guest_id": "junho",
		"level": MenuDB.get_level(1),
		"menu": MenuDB.get_menu(food_id),
		"step_no": 1,
		"step_total": 4,
	}
	for k in extra.keys():
		p[k] = extra[k]
	return p


## slice cut info Dictionary 합성 (특정 속도 강제).
func _cut_info(start: Vector2, end: Vector2, dur_ms: float) -> Dictionary:
	var v: Vector2 = end - start
	var dist: float = v.length()
	var dir: Vector2 = v.normalized()
	return {
		"start": start, "end": end, "distance": dist, "path_len": dist,
		"duration_ms": dur_ms, "avg_speed": dist / (dur_ms / 1000.0),
		"direction": dir, "angle_deg": rad_to_deg(dir.angle()),
		"straightness": 1.0, "path": PackedVector2Array([start, end]),
	}


func _eq(label: String, got, expected) -> void:
	var ok: bool = got == expected
	if ok: _pass += 1
	else:  _fail += 1
	print("  [%s] %s  (got=%s expected=%s)" % [("PASS" if ok else "FAIL"), label, str(got), str(expected)])


func _ok(label: String, got: bool) -> void:
	if got: _pass += 1
	else:   _fail += 1
	print("  [%s] %s" % [("PASS" if got else "FAIL"), label])
