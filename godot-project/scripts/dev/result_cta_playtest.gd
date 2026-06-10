## result_cta_playtest.gd — FULL end-to-end playtest of the Result Screen CTA navigation.
##
## For each of the 3 CTAs it:
##   1. Drives a REAL CookingModuleRunner round to completion (feeds 100% per module),
##      so the runner mounts ResultScreenV2 inside its `top` (CanvasLayer layer=10) —
##      EXACTLY the production path that was broken.
##   2. Reveals the sticky CTA, then SYNTHESISES A REAL MOUSE CLICK (button-down + up)
##      at the CTA button's global center via Input event parsing — NOT a signal emit.
##   3. Asserts the click actually reaches the button (button fires) and that the
##      ResultScreenV2 handler runs (we intercept change_scene_to_file by checking the
##      next scene path the tree was asked to load).
##
## Each CTA navigates away, so we run them one at a time, re-bootstrapping the runner.
##
## Run:
##   godot --headless --quit-after 30 res://scenes/result_cta_playtest.tscn
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const Runner := preload("res://scripts/gameplay/cooking_module_runner.gd")

var _pass: int = 0
var _fail: int = 0


func _ready() -> void:
	# Re-parent ourselves to the SceneTree root as a NON-current-scene sibling, so the CTA's
	# change_scene_to_file (which frees root.current_scene) doesn't free this driver mid-run.
	if get_tree().current_scene == self:
		call_deferred("_relaunch_detached")
		return
	await _run()


func _relaunch_detached() -> void:
	var driver: Node = get_script().new()
	get_tree().root.add_child(driver)
	# Remove the original current-scene instance so it isn't double-running.
	queue_free()


func _run() -> void:
	print("=== Result CTA — full end-to-end playtest ===")
	await get_tree().process_frame
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		sm.reset_progress()
		# stock a serving so consume_stock doesn't matter; runner handles it gracefully.

	# Each entry: button label, expected destination scene file, expected pending state.
	#   pending: which static var(s) must carry the restart context after navigation.
	var cases := [
		{"label": "Cook Again", "expect": "res://scenes/cooking_module_runner.tscn",
			"pending": "runner_menu_guest"},
		{"label": "Choose Other Guest", "expect": "res://scenes/guest_select.tscn",
			"pending": "guest_select_menu"},
		{"label": "Back to Menu", "expect": "res://scenes/menu_select.tscn",
			"pending": "none"},
	]
	for c in cases:
		await _playtest_cta(String(c["label"]), String(c["expect"]), String(c["pending"]))

	print("=== summary: %d PASS / %d FAIL ===" % [_pass, _fail])
	get_tree().quit(0 if _fail == 0 else 1)


func _playtest_cta(label: String, expect_scene: String, pending_kind: String) -> void:
	print("\n[playtest] CTA '%s' (expect -> %s)" % [label, expect_scene])
	# 1. Boot a real runner round.
	Runner.pending_menu_id = "t1_002"  # ramyeon — short 4-step sequence
	Runner.pending_guest_id = "junho"
	var runner: Node = Runner.new()
	get_tree().root.add_child(runner)
	# Wait past the 1.4s request banner.
	await get_tree().create_timer(1.7).timeout
	# Feed perfect score for each module → runner reaches _finish() → mounts ResultScreenV2.
	var seq: Array = MenuDB.module_sequence("t1_002")
	for mod_id in seq:
		runner.callv("_on_module_completed", [100.0, String(mod_id)])
		await get_tree().process_frame
		await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout

	# 2. Locate the mounted ResultScreenV2 + its sticky CTA buttons.
	var screen: Node = _find_result_screen(runner)
	if screen == null:
		_assert_bool("[%s] ResultScreenV2 mounted by runner" % label, false)
		runner.queue_free()
		await get_tree().process_frame
		return
	_assert_bool("[%s] ResultScreenV2 mounted by runner" % label, true)
	# Confirm it's inside a layer-10 CanvasLayer (the production mount that broke clicks).
	var mount_layer: int = _enclosing_layer(screen)
	print("[playtest]   mount CanvasLayer.layer=%d" % mount_layer)
	var sticky: CanvasLayer = screen.get("_sticky")
	print("[playtest]   sticky CanvasLayer.layer=%d" % (sticky.layer if sticky else -999))
	_assert_bool("[%s] sticky layer (%d) > mount layer (%d)" % [label, (sticky.layer if sticky else -1), mount_layer],
		sticky != null and sticky.layer > mount_layer)

	# Reveal CTA immediately (skip the 3.5s fade).
	var cta_root: Control = screen.get("_cta_root")
	if cta_root != null:
		cta_root.modulate.a = 1.0
	# Wait extra frames so GlossyButton inner buttons are built + laid out.
	for i in range(6):
		await get_tree().process_frame

	# 3. Find the target button by label + synthesise a REAL click at its center.
	var btn: Button = _find_button(cta_root, label)
	if btn == null:
		_assert_bool("[%s] CTA button found" % label, false)
		runner.queue_free()
		await get_tree().process_frame
		return
	_assert_bool("[%s] CTA button found" % label, true)

	var pressed_seen := {"v": false}
	btn.pressed.connect(func() -> void: pressed_seen["v"] = true)

	# Visual proof: capture the result screen with the CTA band visible right before click.
	# Guard for the headless dummy renderer (viewport texture/image is null) so the REAL
	# click + navigation assertions below ALWAYS run, even when no GPU image is available.
	await get_tree().process_frame
	var vtex := get_viewport().get_texture()
	var img: Image = vtex.get_image() if vtex != null else null
	if img != null:
		var shot_path: String = "user://cta_playtest_%s.png" % label.to_lower().replace(" ", "_")
		img.save_png(shot_path)
		print("[playtest]   screenshot -> %s" % ProjectSettings.globalize_path(shot_path))
	else:
		print("[playtest]   (no viewport image — headless dummy renderer, skipping shot)")

	var center: Vector2 = btn.get_global_rect().get_center()

	# REGRESSION REPRO (2026-06-07): a module's final _safe_feedback() leaves a FeedbackBus
	# judgement popup on its layer-50 CanvasLayer (ABOVE the layer-15 sticky CTA). Before the
	# fix those pooled Labels were MOUSE_FILTER_STOP and ate clicks on the CTA. Fire a popup
	# RIGHT OVER this button's center so the test exercises the exact on-device condition.
	var fb := get_node_or_null("/root/FeedbackBus")
	if fb != null and fb.has_method("hit"):
		fb.hit(0, center)  # 0 = PERFECT — biggest popup, worst-case overlap
		await get_tree().process_frame

	_inject_click(center)
	# Let input + handler + change_scene_to_file process.
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout

	_assert_bool("[%s] real mouse click reached button (pressed fired)" % label, pressed_seen["v"])

	# 4. Verify navigation: change_scene_to_file is deferred → check the tree's current scene
	#    file after a frame. (change_scene_to_file replaces root.current_scene.)
	await get_tree().process_frame
	var cur: Node = get_tree().current_scene
	var cur_file: String = (cur.scene_file_path if cur else "")
	print("[playtest]   after click, current_scene=%s" % cur_file)
	_assert_bool("[%s] navigated to %s" % [label, expect_scene], cur_file == expect_scene)

	# --- Verify pending restart context handed to the destination ---
	match pending_kind:
		"runner_menu_guest":
			# Cook Again must restart the SAME menu (t1_002) + SAME guest (junho) via runner.
			# The destination runner's _load_round() CONSUMES pending_guest_id (sets it back
			# to "") after reading — so we assert against what the NEW runner actually loaded
			# (_menu.id + _guest.id), which is the real "did the restart carry context" proof.
			var rmid: String = String(Runner.pending_menu_id)
			print("[playtest]   Runner.pending_menu_id=%s (guest consumed by new runner)" % rmid)
			_assert_bool("[%s] Runner.pending_menu_id == t1_002" % label, rmid == "t1_002")
			var dest_menu: Dictionary = cur.get("_menu") if cur != null else {}
			var dest_guest: Dictionary = cur.get("_guest") if cur != null else {}
			var dmid: String = String(dest_menu.get("id", ""))
			var dgid: String = String(dest_guest.get("id", ""))
			print("[playtest]   restarted runner loaded menu=%s guest=%s" % [dmid, dgid])
			_assert_bool("[%s] restarted runner menu == t1_002" % label, dmid == "t1_002")
			_assert_bool("[%s] restarted runner guest == junho (same guest)" % label, dgid == "junho")
		"guest_select_menu":
			# Choose Other Guest must keep the menu (t1_002) so guest_select re-lists for it.
			var GuestSelectScript := load("res://scripts/ui/guest_select.gd")
			var gmid: String = String(GuestSelectScript.pending_menu_id)
			print("[playtest]   GuestSelect.pending_menu_id=%s" % gmid)
			_assert_bool("[%s] GuestSelect.pending_menu_id == t1_002 (menu preserved)" % label,
				gmid == "t1_002")
		_:
			pass

	# Clean up: the scene change frees the previous root.current_scene (our test node is a
	# sibling under root, not the current_scene, so we persist). Free any stray runner.
	if is_instance_valid(runner):
		runner.queue_free()
	# Also clear the freshly-loaded destination scene so the next case starts clean.
	if cur != null and is_instance_valid(cur):
		cur.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# Synthesise a left mouse button click (down then up) at a global screen point.
# Uses Viewport.push_input so it travels the real GUI input path (hover + click target
# resolution across CanvasLayers), which is what a finger tap exercises in production.
func _inject_click(pos: Vector2) -> void:
	var vp := get_viewport()
	# Move the GUI pointer over the target first so hover/under-mouse resolves.
	var motion := InputEventMouseMotion.new()
	motion.position = pos
	motion.global_position = pos
	vp.push_input(motion, true)
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.button_mask = MOUSE_BUTTON_MASK_LEFT
	down.pressed = true
	down.position = pos
	down.global_position = pos
	vp.push_input(down, true)
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = pos
	up.global_position = pos
	vp.push_input(up, true)


func _find_result_screen(runner: Node) -> Node:
	# Runner adds a child CanvasLayer (top) whose child is the ResultScreenV2 Control.
	for c in runner.get_children():
		if c is CanvasLayer:
			for cc in c.get_children():
				if cc.get_script() != null and String(cc.get_script().resource_path).ends_with("result_screen_v2.gd"):
					return cc
	return null


func _enclosing_layer(node: Node) -> int:
	var n: Node = node.get_parent()
	while n != null:
		if n is CanvasLayer:
			return (n as CanvasLayer).layer
		n = n.get_parent()
	return 0


func _find_button(root: Control, label: String) -> Button:
	if root == null:
		return null
	var stack: Array = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		for c in n.get_children():
			if c is Button and String((c as Button).text) == label:
				return c
			stack.append(c)
	return null


func _assert_bool(label: String, got: bool) -> void:
	if got: _pass += 1
	else:   _fail += 1
	print("  [%s] %s" % [("PASS" if got else "FAIL"), label])
