## action_first_w2_smoke.gd — ADR-012 W2 verification (stir / arrange / roll / flip).
##
## W2의 4 module action-first 재설계가 scoring contract를 깨지 않았는지 검증:
##   1) 각 module이 정상 instantiate + start(params) (runner와 동일 params shape).
##   2) module_completed(score) 가 [0,100] 도메인 score로 정확히 1회 emit (+ re-entrancy guard).
##   3) 내부 score 함수가 다양한 gesture quality 입력에 대해 [0,100] 반환 + 단조성 sanity.
##        stir   : _compute_stir_score (회전 수 × 속도 일관성)
##        arrange: _finalize (correct/total × 100)
##        roll   : _compute_roll_score(left_p, right_p, pressure, smooth)  (two-finger balance)
##        flip   : _compute_flip_score(turns, dir_ok) + _speed_to_turns + _direction_accuracy
##   4) MODULE_TO_FACTOR 매핑 무변경 (stir→cook, arrange→prep, roll→prep, flip→cook).
##   5) gesture quality → output signal 변환 (속도/회전/방향이 점수 도메인으로 정상 사상).
##
## Usage:
##   <godot> --path godot-project res://scenes/action_first_w2_smoke.tscn  (또는 --headless --quit-after 8)
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const Runner := preload("res://scripts/gameplay/cooking_module_runner.gd")
const StirMod := preload("res://scripts/cooking_modules/stir_module.gd")
const ArrangeMod := preload("res://scripts/cooking_modules/arrange_module.gd")
const RollMod := preload("res://scripts/cooking_modules/roll_module.gd")
const FlipMod := preload("res://scripts/cooking_modules/flip_module.gd")

var _pass: int = 0
var _fail: int = 0


func _ready() -> void:
	print("=== Action-First W2 — smoke (stir / arrange / roll / flip) ===")
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()

	_test_factor_mapping_unchanged()
	await _test_module_instantiate("stir", StirMod, "t1_005", {"variant": "wok", "target_turns": 3.0})
	await _test_module_instantiate("arrange", ArrangeMod, "t1_004", {"slot_count": 5})
	await _test_module_instantiate("roll", RollMod, "t1_004", {})
	await _test_module_instantiate("flip", FlipMod, "t1_006", {"variant": "pajeon"})
	await _test_score_domain_stir()
	await _test_score_domain_arrange()
	await _test_score_domain_roll()
	await _test_score_domain_flip()
	await _test_gesture_quality_conversion()
	await _test_completion_contract()

	print("=== summary: %d PASS / %d FAIL ===" % [_pass, _fail])
	get_tree().quit()


# 1) MODULE_TO_FACTOR 무변경 — scoring 매핑 lock.
func _test_factor_mapping_unchanged() -> void:
	print("\n[1] MODULE_TO_FACTOR unchanged (ADR-011 lock)")
	var m := Runner.MODULE_TO_FACTOR
	_eq("stir -> cook", String(m["stir"]), "cook")
	_eq("arrange -> prep", String(m["arrange"]), "prep")
	_eq("roll -> prep", String(m["roll"]), "prep")
	_eq("flip -> cook", String(m["flip"]), "cook")


# 2) instantiate + start + module_completed [0,100] 도메인 + 단일 emit + re-entrancy.
func _test_module_instantiate(label: String, script: GDScript, food_id: String, extra: Dictionary) -> void:
	print("\n[2] instantiate + start: %s" % label)
	var inst: Node = script.new()
	get_tree().root.add_child(inst)
	var captured := {"score": -1.0, "count": 0}
	inst.module_completed.connect(func(s: float):
		captured["score"] = s
		captured["count"] += 1)
	inst.start(_params(food_id, extra))
	await get_tree().process_frame
	_ok("[%s] instantiated + started (no crash)" % label, is_instance_valid(inst))
	# 강제 완료 — base _finish 경로로 score domain + clamp 확인.
	inst._finish(72.5)
	await get_tree().process_frame
	_eq("[%s] module_completed emitted once" % label, captured["count"], 1)
	_ok("[%s] score in [0,100]" % label, captured["score"] >= 0.0 and captured["score"] <= 100.0)
	_eq("[%s] _finish clamps passthrough" % label, captured["score"], 72.5)
	# re-entrancy guard (double finish ignored).
	inst._finish(999.0)
	await get_tree().process_frame
	_eq("[%s] double-finish ignored" % label, captured["count"], 1)
	# clamp 상한 검증 (별도 인스턴스).
	var inst2: Node = script.new()
	get_tree().root.add_child(inst2)
	var cap2 := {"s": -1.0}
	inst2.module_completed.connect(func(s): cap2["s"] = s)
	inst2.start(_params(food_id, extra))
	await get_tree().process_frame
	inst2._finish(150.0)
	await get_tree().process_frame
	_eq("[%s] _finish clamps >100 to 100" % label, cap2["s"], 100.0)
	inst.queue_free()
	inst2.queue_free()


# 3a) stir _compute_stir_score 도메인 — 다양한 회전/속도 일관성.
func _test_score_domain_stir() -> void:
	print("\n[3a] stir _compute_stir_score domain [0,100]")
	# (a) 회전 부족 (under-mixed) — turns 적음.
	var s_under: float = _stir_score("wok", 0.5, 3.0, _speeds(8.0, 6), 0)
	# (b) 적정 — 목표 turns 도달 + band 안 일관 속도.
	var s_ideal: float = _stir_score("wok", 3.2, 3.0, _speeds(10.0, 14), 0)
	# (c) 과다 (뭉개짐) — 너무 빠른 속도 frame 다수.
	var s_over: float = _stir_score("wok", 3.5, 3.0, _speeds(30.0, 14), 12)
	for pair in [["under", s_under], ["ideal", s_ideal], ["over-fast", s_over]]:
		_ok("stir '%s' in [0,100] (=%.1f)" % [pair[0], pair[1]], float(pair[1]) >= 0.0 and float(pair[1]) <= 100.0)
	_ok("stir ideal > under (more turns scores higher)", s_ideal > s_under)
	_ok("stir over-fast penalized vs ideal", s_over < s_ideal)


# 3b) arrange _finalize 도메인 — placement 정확도.
func _test_score_domain_arrange() -> void:
	print("\n[3b] arrange placement score = correct/total*100")
	for pair in [[5, 5, 100.0], [5, 3, 60.0], [5, 0, 0.0], [6, 6, 100.0]]:
		var inst = ArrangeMod.new()
		get_tree().root.add_child(inst)
		inst.start(_params("t1_004", {"slot_count": int(pair[0])}))
		await get_tree().process_frame
		var cap := {"s": -1.0}
		inst.module_completed.connect(func(s): cap["s"] = s)
		inst.set("_slot_count", int(pair[0]))
		inst.set("_correct_count", int(pair[1]))
		inst.set("_placed_total", int(pair[0]))
		inst._finalize()
		await get_tree().process_frame
		_ok("arrange %d/%d -> %.0f (=%.1f)" % [int(pair[1]), int(pair[0]), float(pair[2]), cap["s"]],
			absf(float(cap["s"]) - float(pair[2])) < 0.01)
		inst.queue_free()


# 3c) roll _compute_roll_score 도메인 — TWO-FINGER 새 공식 (40 balance / 25 pressure /
#     20 distance / 15 smooth). 신규 signature: (left_p, right_p, pressure_metric, smooth_metric).
func _test_score_domain_roll() -> void:
	print("\n[3c] roll _compute_roll_score(left_p, right_p, pressure, smooth) domain [0,100]")
	var inst = RollMod.new()
	get_tree().root.add_child(inst)
	inst.start(_params("t1_004", {}))
	await get_tree().process_frame
	# perfect = 균등 두 손가락(sweet zone) + 동시 pressure + smooth.
	# crooked = 좌우 차 큼. loose = push 낮음. burst = push 과다. rough = smooth 낮음.
	var cases := [
		{"name": "perfect (0.92/0.92, p1, s1)", "l": 0.92, "r": 0.92, "pr": 1.0, "sm": 1.0},
		{"name": "crooked (0.95/0.45)",          "l": 0.95, "r": 0.45, "pr": 0.9, "sm": 0.8},
		{"name": "loose (0.30/0.30)",            "l": 0.30, "r": 0.30, "pr": 0.6, "sm": 0.8},
		{"name": "burst (1.18/1.18)",            "l": 1.18, "r": 1.18, "pr": 0.9, "sm": 0.7},
		{"name": "rough (0.90/0.90, s0.1)",      "l": 0.90, "r": 0.90, "pr": 0.9, "sm": 0.1},
	]
	var s_perfect: float = -1.0
	var s_crooked: float = -1.0
	var s_loose: float = -1.0
	var s_burst: float = -1.0
	var s_rough: float = -1.0
	for c in cases:
		var sc: float = inst._compute_roll_score(float(c["l"]), float(c["r"]),
				float(c["pr"]), float(c["sm"]))
		_ok("roll '%s' in [0,100] (=%.1f)" % [c["name"], sc], sc >= 0.0 and sc <= 100.0)
		if c["name"].begins_with("perfect"): s_perfect = sc
		elif c["name"].begins_with("crooked"): s_crooked = sc
		elif c["name"].begins_with("loose"): s_loose = sc
		elif c["name"].begins_with("burst"): s_burst = sc
		elif c["name"].begins_with("rough"): s_rough = sc
	# 새 공식 sanity — perfect가 모든 failure mode보다 높아야 한다 (contract 도메인 유지).
	_ok("roll perfect high (>=90)", s_perfect >= 90.0)
	_ok("roll perfect > crooked (좌우 balance 40%)", s_perfect > s_crooked)
	_ok("roll perfect > loose (distance/pressure)", s_perfect > s_loose)
	_ok("roll perfect > burst (over-pressure)", s_perfect > s_burst)
	_ok("roll perfect > rough (smooth 15%)", s_perfect > s_rough)
	inst.queue_free()


# 3d) flip _compute_flip_score 도메인 — 공중 회전 수 + 방향.
func _test_score_domain_flip() -> void:
	print("\n[3d] flip _compute_flip_score(turns, dir_ok) domain [0,100]")
	var inst = FlipMod.new()
	get_tree().root.add_child(inst)
	inst.start(_params("t1_006", {"variant": "pajeon"}))
	await get_tree().process_frame
	var cases := [
		{"name": "half-flop (0.5t)", "t": 0.5, "dir": 1.0},
		{"name": "clean one-turn (1.0t)", "t": 1.0, "dir": 1.0},
		{"name": "over-spin (1.9t)", "t": 1.9, "dir": 1.0},
		{"name": "wrong direction", "t": 1.0, "dir": 0.0},
	]
	var s_half: float = -1.0
	var s_clean: float = -1.0
	var s_over: float = -1.0
	var s_wrongdir: float = -1.0
	for c in cases:
		var sc: float = inst._compute_flip_score(float(c["t"]), float(c["dir"]))
		_ok("flip '%s' in [0,100] (=%.1f)" % [c["name"], sc], sc >= 0.0 and sc <= 100.0)
		match String(c["name"]).substr(0, 4):
			"half": s_half = sc
			"clea": s_clean = sc
			"over": s_over = sc
			"wron": s_wrongdir = sc
	_ok("flip clean one-turn > half-flop", s_clean > s_half)
	_ok("flip clean one-turn > over-spin", s_clean > s_over)
	_ok("flip correct dir > wrong dir", s_clean > s_wrongdir)
	inst.queue_free()


# 5) gesture quality → output 변환 — 속도 벡터/회전이 점수 도메인으로 정상 사상.
func _test_gesture_quality_conversion() -> void:
	print("\n[5] gesture quality -> score conversion")
	# flip: flick 속도 → 공중 회전 수 (단조 증가, ideal speed ~ 1.0바퀴).
	var inst = FlipMod.new()
	get_tree().root.add_child(inst)
	inst.start(_params("t1_006", {"variant": "pajeon"}))
	await get_tree().process_frame
	var t_slow: float = inst._speed_to_turns(1500.0)
	var t_ideal: float = inst._speed_to_turns(3200.0)
	var t_fast: float = inst._speed_to_turns(5200.0)
	_ok("flip speed->turns monotonic (slow<ideal<fast)", t_slow < t_ideal and t_ideal < t_fast)
	_ok("flip ideal speed ~ 1.0 turn (=%.2f)" % t_ideal, absf(t_ideal - 1.0) < 0.15)
	# flip: 방향 정확도 — swipe-up이 pajeon 목표에 가깝게 사상.
	var dir_up := _flick_info(Vector2(540, 1200), Vector2(540, 700), 0.12)   # 위로 (angle ~ -90)
	var dir_down := _flick_info(Vector2(540, 700), Vector2(540, 1200), 0.12) # 아래로 (angle ~ +90)
	var acc_up: float = inst._direction_accuracy(dir_up)
	var acc_down: float = inst._direction_accuracy(dir_down)
	_ok("flip pajeon swipe-up dir_acc in [0,1] (=%.2f)" % acc_up, acc_up >= 0.0 and acc_up <= 1.0)
	_ok("flip swipe-up better than swipe-down for pajeon", acc_up > acc_down)
	inst.queue_free()

	# stir: variant param이 score band를 결정 (wok/bibim 모두 [0,100]).
	for v in ["wok", "bibim", "toss"]:
		var sc: float = _stir_score(v, 3.0, 3.0, _speeds(8.0, 12), 0)
		_ok("stir variant '%s' score in [0,100] (=%.1f)" % [v, sc], sc >= 0.0 and sc <= 100.0)


# end-to-end completion contract via Runner._on_module_completed bucket.
func _test_completion_contract() -> void:
	print("\n[6] Runner buckets stir/arrange/roll/flip into correct factor")
	Runner.pending_menu_id = "t1_004"  # 김밥 = arrange|roll|slice|plate
	Runner.pending_guest_id = ""
	var runner: Node = Runner.new()
	get_tree().root.add_child(runner)
	await get_tree().create_timer(1.7).timeout
	# 4 module을 직접 bucket에 흘려보냄 (factor 매핑 검증).
	for pair in [["arrange", 80.0], ["roll", 90.0], ["stir", 70.0], ["flip", 60.0]]:
		runner.callv("_on_module_completed", [float(pair[1]), String(pair[0])])
		await get_tree().process_frame
		await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	var fa: Dictionary = runner.get("_factor_acc")
	_ok("prep bucket got arrange", (fa.get("prep", []) as Array).size() >= 1)
	_ok("prep bucket got roll (also prep)", (fa.get("prep", []) as Array).size() >= 2)
	_ok("cook bucket got stir+flip", (fa.get("cook", []) as Array).size() >= 2)
	# 정규화 [0,1] 확인.
	if (fa.get("cook", []) as Array).size() > 0:
		var v: float = float((fa["cook"] as Array)[0])
		_ok("cook normalized [0,1] (=%.2f)" % v, v >= 0.0 and v <= 1.0)
		_ok("cook == 0.70 (70/100)", absf(v - 0.70) < 0.005)


# --- helpers ---

func _params(food_id: String, extra: Dictionary) -> Dictionary:
	var p: Dictionary = {
		"food_id": food_id, "guest_id": "junho",
		"level": MenuDB.get_level(1), "menu": MenuDB.get_menu(food_id),
		"step_no": 1, "step_total": 4,
	}
	for k in extra.keys():
		p[k] = extra[k]
	return p


## stir score 계산 — raw 상태를 instance에 주입 후 _compute_stir_score 호출.
func _stir_score(variant: String, abs_turns: float, target_turns: float,
		speeds: Array, too_fast: int) -> float:
	var inst = StirMod.new()
	get_tree().root.add_child(inst)
	inst.start(_params("t1_005", {"variant": variant, "target_turns": target_turns}))
	# start가 _target_turns/_variant을 세팅했으니 raw 상태만 덮어씀.
	inst.set("_abs_turns", abs_turns)
	inst.set("_target_turns", target_turns)
	inst.set("_ang_speed_samples", speeds)
	inst.set("_too_fast_frames", too_fast)
	var sc: float = inst._compute_stir_score()
	inst.queue_free()
	return sc


## 균일 각속도 샘플 n개 (rad/s).
func _speeds(val: float, n: int) -> Array:
	var a: Array = []
	for i in range(n):
		a.append(val)
	return a


## flick info Dictionary 합성 (특정 duration 강제 → avg_speed 도출).
func _flick_info(start: Vector2, end: Vector2, dur_s: float) -> Dictionary:
	var v: Vector2 = end - start
	var dist: float = v.length()
	var dir: Vector2 = v.normalized()
	var dur_ms: float = dur_s * 1000.0
	return {
		"start": start, "end": end, "distance": dist, "path_len": dist,
		"duration_ms": dur_ms, "avg_speed": dist / maxf(dur_s, 0.001),
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
