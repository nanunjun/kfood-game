## result_cta_bug_test.gd — reproduces & verifies the Result Screen CTA navigation bug.
##
## Bug: cooking_module_runner / rhythm_proto mount ResultScreenV2 inside a CanvasLayer
## (top.layer = 10). ResultScreenV2 builds its OWN sticky-CTA CanvasLayer (_sticky.layer
## = 5). Because CanvasLayer.layer is a GLOBAL z-order (not nested under the parent layer),
## the sticky CTA at global layer 5 ends up BELOW the result screen's full-rect content
## (ScrollContainer + background) which live at global layer 10. The ScrollContainer then
## eats every click over the CTA band, so the 3 CTA buttons never fire.
##
## This test mounts ResultScreenV2 the SAME way the runner does, then does a viewport-level
## hit-test at each CTA button center to confirm the button (not the scroll) receives input.
##
## Run:
##   godot --headless --quit-after 6 res://scenes/result_cta_bug_test.tscn
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const ResultV2Scene := preload("res://scenes/ui/result_screen_v2.tscn")

var _pass: int = 0
var _fail: int = 0


func _ready() -> void:
	print("=== Result CTA navigation bug test ===")
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		sm.reset_progress()

	# Mount EXACTLY like cooking_module_runner._launch_result_v2 / rhythm_proto:
	#   a fresh CanvasLayer at layer 10, with the result screen inside it.
	var screen := ResultV2Scene.instantiate()
	screen.setup(_make_payload())
	var top := CanvasLayer.new()
	top.layer = 10
	add_child(top)
	top.add_child(screen)

	# Let the tree settle + buttons build (GlossyButton wires its inner button deferred).
	for i in range(8):
		await get_tree().process_frame

	# Force CTA visible immediately (kick reveal fades it in at t=3.5).
	var cta_root: Control = screen.get("_cta_root")
	if cta_root != null:
		cta_root.modulate.a = 1.0

	await get_tree().process_frame

	# Collect the 3 GlossyButton inner buttons from the sticky CTA root.
	var btns: Array = _collect_cta_buttons(cta_root)
	_assert_bool("found 3 CTA buttons", btns.size() == 3)

	# --- Hit-test: at each CTA center, which Control does the viewport route input to? ---
	# We compute the global rect of each inner button, then ask the viewport for the
	# top-most control that would receive a click at that point.
	var sticky: CanvasLayer = screen.get("_sticky")
	print("[diag] top.layer=%d  _sticky.layer=%d" % [top.layer, (sticky.layer if sticky else -999)])

	for b in btns:
		var btn: Button = b as Button
		var center: Vector2 = btn.get_global_rect().get_center()
		var hit: Control = _topmost_control_at(center)
		var hit_name: String = (hit.name if hit else "<none>") + " (" + (hit.get_class() if hit else "") + ")"
		var routes_to_button: bool = (hit == btn)
		print("[diag] CTA '%s' center=%s  topmost-hit=%s  -> %s" % [
			btn.text, str(center), hit_name, ("BUTTON OK" if routes_to_button else "BLOCKED")])
		_assert_bool("CTA '%s' receives input (not blocked)" % btn.text, routes_to_button)

	# --- Behavioural: confirm each inner button's `pressed` is actually connected to a
	#     ResultScreenV2 handler (we don't emit() — that would fire change_scene_to_file
	#     and free the tree mid-test). We inspect the signal connection list instead. ---
	for b in btns:
		var btn: Button = b as Button
		var conns: Array = btn.get_signal_connection_list("pressed")
		# Each GlossyButton wires 2 pressed handlers: its own _on_pressed bounce, plus the
		# ResultScreenV2 CTA callback (_on_cook_again / _on_choose_other / _on_back_menu).
		var has_result_handler: bool = false
		for c in conns:
			var cb: Callable = c.get("callable")
			var obj = cb.get_object()
			if obj == screen:
				has_result_handler = true
		_assert_bool("CTA '%s' pressed -> ResultScreenV2 handler connected" % btn.text, has_result_handler)

	print("=== summary: %d PASS / %d FAIL ===" % [_pass, _fail])
	get_tree().quit(0 if _fail == 0 else 1)


# Walk the sticky CTA root and gather the GlossyButton inner Button nodes.
func _collect_cta_buttons(root: Control) -> Array:
	var out: Array = []
	if root == null:
		return out
	var stack: Array = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		for c in n.get_children():
			if c is Button:
				out.append(c)
			stack.append(c)
	return out


# Returns the top-most visible Control at a global point that would receive mouse input,
# honouring CanvasLayer ordering (higher layer wins) and mouse_filter.
func _topmost_control_at(global_pt: Vector2) -> Control:
	var acc := {"ctrl": null, "layer": -2147483648, "depth": -1}
	_scan(get_tree().root, global_pt, 0, 0, acc)
	return acc["ctrl"]


func _scan(node: Node, pt: Vector2, cur_layer: int, depth: int, acc: Dictionary) -> void:
	var layer_here: int = cur_layer
	if node is CanvasLayer:
		layer_here = (node as CanvasLayer).layer
	if node is Control:
		var ctrl := node as Control
		if ctrl.visible and ctrl.mouse_filter != Control.MOUSE_FILTER_IGNORE \
				and ctrl.get_global_rect().has_point(pt):
			# Higher layer wins; within same layer, deeper-in-tree (drawn later) wins.
			if layer_here > acc["layer"] or (layer_here == acc["layer"] and depth >= acc["depth"]):
				acc["ctrl"] = ctrl
				acc["layer"] = layer_here
				acc["depth"] = depth
	for c in node.get_children():
		_scan(c, pt, layer_here, depth + 1, acc)


func _make_payload() -> Dictionary:
	var menu: Dictionary = MenuDB.get_menu("m_kimchi_jjigae")
	var guest: Dictionary = MenuDB.get_guest("junho")
	var rc := get_node_or_null("/root/RewardCalc")
	var breakdown: Array = []
	if rc != null:
		breakdown = rc.score_breakdown_rows(0.85, 0.78, 0.89, 0.95, 93, "happy", guest)
	return {
		"food": menu, "guest": guest, "mood": "happy", "compat": 93,
		"stars": 3, "score": 8800, "score_norm": 0.88, "breakdown_rows": breakdown,
		"emotion_level": "excellent", "reaction_text": "Junho loved the spicy kick!",
		"record_broken": true, "record_prev_score": 8000,
		"xp_gained": 59, "xp_total_after": 59,
		"friendship_delta": 3, "friendship_after": 3, "milestone_just_hit": 3,
		"final_coin": 9100, "passed": true,
	}


func _assert_bool(label: String, got: bool) -> void:
	if got: _pass += 1
	else:   _fail += 1
	print("  [%s] %s" % [("PASS" if got else "FAIL"), label])
