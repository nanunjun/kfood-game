## gimbap_vs_smoke.gd — Gimbap Vertical Slice Pass B consequence-chain unit smoke.
##
## Headless-safe (no display). Asserts the cross-stage consequence math WITHOUT UI input:
##   1) roll_module §8.2/§8.3 — prep_quality narrows sweet zone (same push → lower score);
##      arrange balance offsets tilt.
##   2) slice_module §8.4 — roll_quality narrows cut window (same cut → lower score).
##   3) arrange_module §8.3 — get_arrange_balance / bias_dir from filled-slot symmetry.
##   4) plate_module §8.5 — vs plating activates only with vs_quality_state; plate_quality math.
##   5) runner §8.1 — _available_filling_slots from collected_fillings.
##   6) CONTRACT preserved — base module score domain [0,100], default (no vs) == legacy.
##
## Usage: godot --headless --quit-after 6 res://scenes/gimbap_vs_smoke.tscn
extends Node

const RollScript := preload("res://scripts/cooking_modules/roll_module.gd")
const SliceScript := preload("res://scripts/cooking_modules/slice_module.gd")
const ArrangeScript := preload("res://scripts/cooking_modules/arrange_module.gd")
const PlateScript := preload("res://scripts/cooking_modules/plate_module.gd")
const Runner := preload("res://scripts/gameplay/gimbap_slice_runner.gd")
const MenuDB := preload("res://scripts/gameplay/menu_db.gd")

var _pass: int = 0
var _fail: int = 0


func _ready() -> void:
	print("=== Gimbap Vertical Slice — Pass B consequence smoke ===")
	await get_tree().process_frame
	_test_roll_prep_consequence()
	_test_roll_default_unchanged()
	_test_slice_roll_consequence()
	_test_slice_default_unchanged()
	_test_arrange_balance()
	_test_runner_filling_slots()
	_test_plate_vs_activation()
	print("=== summary: %d PASS / %d FAIL ===" % [_pass, _fail])
	get_tree().quit()


# §8.2 prep→roll — same push, lower prep → lower (or equal) roll score; bad prep strictly < good.
func _test_roll_prep_consequence() -> void:
	print("\n[1] §8.2 prep→roll sweet-zone narrowing")
	var push: float = 1.04   # sweet for good prep, over for narrowed bad-prep zone.
	var hi: float = _roll_score(push, push, 0.95)
	var lo: float = _roll_score(push, push, 0.15)
	_assert_bool("same push 1.04: prep0.95 score >= prep0.15 score", hi >= lo)
	_assert_bool("bad prep strictly lowers score (hi>lo)", hi > lo)
	print("    hi(prep0.95)=%.1f  lo(prep0.15)=%.1f" % [hi, lo])


# CONTRACT — no vs_quality_state → sweet_scale 1.0 → legacy score (push 0.92 = full sweet).
func _test_roll_default_unchanged() -> void:
	print("\n[2] roll default (no vs) preserves legacy sweet zone")
	var legacy: float = _roll_score_no_vs(0.92, 0.92)
	_assert_bool("legacy push 0.92 == perfect (100)", absf(legacy - 100.0) < 0.01)


# §8.4 roll→slice — same off-angle cut, lower roll → lower cut score.
func _test_slice_roll_consequence() -> void:
	print("\n[3] §8.4 roll→slice cut-window narrowing")
	var info := {"start": Vector2(540, 820), "end": Vector2(540, 1200),
		"angle_deg": 69.0, "avg_speed": 1050.0, "straightness": 1.0}
	var hi: float = _slice_score(info, 0.95)
	var lo: float = _slice_score(info, 0.15)
	_assert_bool("same cut: roll0.95 cut >= roll0.15 cut", hi >= lo)
	_assert_bool("bad roll strictly lowers cut (hi>lo)", hi > lo)
	print("    hi(roll0.95)=%.1f  lo(roll0.15)=%.1f" % [hi, lo])


# CONTRACT — no vs → window 1.0 → legacy perfect cut for centered input.
func _test_slice_default_unchanged() -> void:
	print("\n[4] slice default (no vs) preserves legacy cut window")
	var info := {"start": Vector2(540, 820), "end": Vector2(540, 1200),
		"angle_deg": 90.0, "avg_speed": 800.0, "straightness": 1.0}
	var legacy: float = _slice_score_no_vs(info)
	_assert_bool("legacy centered cut == perfect (100)", absf(legacy - 100.0) < 0.01)


# §8.3 arrange — balanced fills → balance≈1; one-sided fills → balance low.
func _test_arrange_balance() -> void:
	print("\n[5] §8.3 arrange balance / bias getters")
	var arr: Node = ArrangeScript.new()
	# Inject synthetic slot fills (no UI): 3 left + 3 right = balanced.
	var balanced: Array = [
		{"center": Vector2(200, 900), "filled": true},
		{"center": Vector2(300, 900), "filled": true},
		{"center": Vector2(400, 900), "filled": true},
		{"center": Vector2(700, 900), "filled": true},
		{"center": Vector2(800, 900), "filled": true},
		{"center": Vector2(900, 900), "filled": true},
	]
	arr.set("_slots", balanced)
	_assert_bool("balanced fills → balance >= 0.95", arr.get_arrange_balance() >= 0.95)
	# One-sided (all left).
	var lopsided: Array = [
		{"center": Vector2(200, 900), "filled": true},
		{"center": Vector2(300, 900), "filled": true},
		{"center": Vector2(400, 900), "filled": true},
		{"center": Vector2(480, 900), "filled": true},
		{"center": Vector2(700, 900), "filled": false},
		{"center": Vector2(900, 900), "filled": false},
	]
	arr.set("_slots", lopsided)
	_assert_bool("all-left fills → balance < 0.5", arr.get_arrange_balance() < 0.5)
	_assert_bool("all-left → bias_dir +1 (left lean)", arr.get_arrange_bias_dir() > 0.0)
	arr.free()


# §8.1 shopping→arrange — collected fillings → available slot count.
func _test_runner_filling_slots() -> void:
	print("\n[6] §8.1 runner _available_filling_slots from collected_fillings")
	var r: Node = Runner.new()
	r.set("collected_fillings", [])
	_assert_bool("empty collected → default 5", int(r.call("_available_filling_slots")) == 5)
	r.set("collected_fillings", ["seaweed", "rice", "carrot", "egg"])  # 2 fillings (carrot/egg)
	_assert_bool("2 fillings collected → 2 slots", int(r.call("_available_filling_slots")) == 2)
	r.set("collected_fillings", ["seaweed", "rice", "danmuji", "carrot", "egg", "spinach"])  # 4 fillings
	_assert_bool("4 fillings collected → 4 slots", int(r.call("_available_filling_slots")) == 4)
	r.free()


# §8.5/§5.3 — plate vs plating activates only with vs_quality_state; tier path otherwise.
func _test_plate_vs_activation() -> void:
	print("\n[7] §5.3 plate vs-plating activation gate")
	var p1: Node = PlateScript.new()
	get_tree().root.add_child(p1)
	p1.start({"food_id": "t1_004", "menu": MenuDB.get_menu("t1_004"),
		"vs_quality_state": {"slice_quality": 0.8}})
	_assert_bool("vs plating active when vs_quality_state present", bool(p1.get("_vs_plate")))
	p1.queue_free()
	var p2: Node = PlateScript.new()
	get_tree().root.add_child(p2)
	p2.start({"food_id": "t1_004", "menu": MenuDB.get_menu("t1_004")})
	_assert_bool("legacy tier path when no vs_quality_state", not bool(p2.get("_vs_plate")))
	p2.queue_free()


# --- helpers ---
func _roll_score(lp: float, rp: float, prep_q: float) -> float:
	var roll: Node = RollScript.new()
	add_child(roll)
	roll.start({"food_id": "t1_004", "vs_quality_state": {"prep_quality": prep_q}})
	var sc: float = roll.call("_compute_roll_score", lp, rp, 1.0, 1.0)
	roll.queue_free()
	return sc


func _roll_score_no_vs(lp: float, rp: float) -> float:
	var roll: Node = RollScript.new()
	add_child(roll)
	roll.start({"food_id": "t1_004"})
	var sc: float = roll.call("_compute_roll_score", lp, rp, 1.0, 1.0)
	roll.queue_free()
	return sc


func _slice_score(info: Dictionary, roll_q: float) -> float:
	var slice: Node = SliceScript.new()
	add_child(slice)
	slice.start({"food_id": "t1_004", "cut_style": "round", "tap_count": 6,
		"vs_quality_state": {"roll_quality": roll_q}})
	var sc: float = slice.call("_score_cut", info)
	slice.queue_free()
	return sc


func _slice_score_no_vs(info: Dictionary) -> float:
	var slice: Node = SliceScript.new()
	add_child(slice)
	slice.start({"food_id": "t1_004", "cut_style": "round", "tap_count": 6})
	var sc: float = slice.call("_score_cut", info)
	slice.queue_free()
	return sc


func _assert_bool(label: String, got: bool) -> void:
	if got: _pass += 1
	else:   _fail += 1
	print("  [%s] %s" % [("PASS" if got else "FAIL"), label])
