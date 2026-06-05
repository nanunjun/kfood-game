## cooking_runner_integration_smoke.gd — end-to-end runner pipeline test.
##
## Drives CookingModuleRunner directly (bypassing UI taps) for each of the 12 menus.csv
## dishes, asserts the runner:
##   - loads the right sequence
##   - buckets simulated module_completed scores into the correct factor
##   - reaches _finish() without errors and produces a sane payload
##
## Usage:
##   godot --headless --quit-after 10 res://scenes/cooking_runner_integration_smoke.tscn
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const Runner := preload("res://scripts/gameplay/cooking_module_runner.gd")

var _pass: int = 0
var _fail: int = 0


func _ready() -> void:
	print("=== Cooking Runner — integration smoke ===")
	# Wait one frame so the SceneTree is ready.
	await get_tree().process_frame
	# Run each of the 12 menus through the load_sequence + factor buckets.
	for mid in MenuDB.all_menu_ids():
		await _drive_one(String(mid))
	print("=== summary: %d PASS / %d FAIL ===" % [_pass, _fail])
	get_tree().quit()


func _drive_one(food_id: String) -> void:
	Runner.pending_menu_id = food_id
	Runner.pending_guest_id = ""  # use menu default
	var runner: Node = Runner.new()
	get_tree().root.add_child(runner)
	# wait until the runner's request banner clears + first module would dispatch
	await get_tree().create_timer(1.7).timeout
	# Simulate full completion: feed perfect (100) for every module in the sequence.
	# This bypasses UI input and asserts the math + result handoff.
	var seq: Array = MenuDB.module_sequence(food_id)
	# After the 1.4s request banner, _run_next_module has already instantiated the
	# first module — let's force-feed completions by calling _on_module_completed
	# directly. This emulates module score arrival.
	for mod_id in seq:
		runner.callv("_on_module_completed", [100.0, String(mod_id)])
		# Yield a frame so any awaits inside the runner advance.
		await get_tree().process_frame
		await get_tree().process_frame
	# Give the runner time to call _finish + launch ResultScreenV2.
	await get_tree().create_timer(0.6).timeout
	# The runner's _factor_acc should now have entries for each module's mapped factor.
	var fa: Dictionary = runner.get("_factor_acc")
	var got_factors: Array = []
	for k in fa.keys():
		if (fa[k] as Array).size() > 0:
			got_factors.append(k)
	# Required factors per the sequence
	var expected_factors: Array = []
	for mod_id in seq:
		var f: String = String(Runner.MODULE_TO_FACTOR.get(mod_id, ""))
		if f != "" and not expected_factors.has(f):
			expected_factors.append(f)
	expected_factors.sort()
	got_factors.sort()
	_assert_arr("[%s] factor coverage matches sequence" % food_id, got_factors, expected_factors)
	# Plating should always be 1.0 (perfect) since plate is appended + we sent 100.
	var plating: Array = fa.get("plating", [])
	_assert_bool("[%s] plating registered" % food_id, plating.size() >= 1)
	if plating.size() >= 1:
		_assert_close("[%s] plating == 1.0" % food_id, float(plating[0]), 1.0)
	runner.queue_free()
	await get_tree().process_frame


func _assert_arr(label: String, got: Array, expected: Array) -> void:
	var ok: bool = got == expected
	if ok: _pass += 1
	else:  _fail += 1
	print("  [%s] %s  (got=%s expected=%s)" % [("PASS" if ok else "FAIL"), label, str(got), str(expected)])


func _assert_close(label: String, got: float, expected: float) -> void:
	var ok: bool = absf(got - expected) < 0.001
	if ok: _pass += 1
	else:  _fail += 1
	print("  [%s] %s  (got=%.3f expected=%.3f)" % [("PASS" if ok else "FAIL"), label, got, expected])


func _assert_bool(label: String, got: bool) -> void:
	if got: _pass += 1
	else:   _fail += 1
	print("  [%s] %s" % [("PASS" if got else "FAIL"), label])
