## shot_result_rebuild.gd — P3 Result Rebuild verification shots.
##
## Captures the compact emotion-first result screen in BOTH states with the SAME
## payload (so collapsed vs expanded are directly comparable):
##   <out>.png            — DEFAULT collapsed (the emotional payoff view, score folded)
##   <out>_expanded.png   — score section expanded (numbers, secondary)
##
## Reveals are played WITHOUT force-expanding the score for the collapsed shot, so the
## first capture is exactly what a player sees when the screen settles.
##
## Usage:
##   godot --quit-after 900 res://scenes/shot_result_rebuild.tscn -- \
##     --scenario=01_excellent_with_new_record --out=user://result_after_excellent.png
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const ResultV2Scene := preload("res://scenes/ui/result_screen_v2.tscn")
const ShotPayload := preload("res://scripts/dev/shot_result_v2.gd")


func _ready() -> void:
	var scenario: String = "01_excellent_with_new_record"
	var out_path: String = "user://result_after.png"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--scenario="):
			scenario = arg.substr("--scenario=".length())
		elif arg.begins_with("--out="):
			out_path = arg.substr("--out=".length())
	print("[shot_result_rebuild] scenario=%s out=%s" % [scenario, out_path])

	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		sm.reset_progress()

	# Reuse shot_result_v2's payload builder for parity with the existing scenarios.
	# The helper must be in the tree so its get_node_or_null autoload lookups resolve;
	# add it deferred (parent is mid-_ready) and wait a frame before building.
	var payload_helper := ShotPayload.new()
	get_tree().root.add_child.call_deferred(payload_helper)
	await get_tree().process_frame
	await get_tree().process_frame
	var payload: Dictionary = payload_helper._make_payload(scenario)
	payload_helper.queue_free()

	var screen := ResultV2Scene.instantiate()
	screen.setup(payload)
	get_tree().root.add_child(screen)
	for i in range(6):
		await get_tree().process_frame

	# Play the reward + learning reveals but KEEP the score collapsed (default view).
	if screen.has_method("set_score_expanded"):
		screen.set_score_expanded(false)
	if screen.has_method("force_play_all_reveals"):
		# force_play_all_reveals also expands the score — instead drive only the reveals
		# we want by replaying the kick path indirectly: just wait for the kick tween.
		pass
	# Wait for the natural _kick_reveal tween chain to settle (~3.6s).
	await get_tree().create_timer(4.2).timeout
	# Make sure the score is still collapsed for the payoff shot.
	if screen.has_method("set_score_expanded"):
		screen.set_score_expanded(false)
	await get_tree().process_frame
	await get_tree().process_frame

	var sc := _find_scroll(screen)
	if sc != null:
		sc.scroll_vertical = 0
	await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(out_path)
	print("[shot_result_rebuild] collapsed saved (err=%d) -> %s (%dx%d)" % [
		err, ProjectSettings.globalize_path(out_path), img.get_width(), img.get_height()])

	# --- expanded capture (score open, scrolled to show the breakdown) ---
	if screen.has_method("set_score_expanded"):
		screen.set_score_expanded(true)
	await get_tree().create_timer(0.6).timeout
	if sc != null:
		sc.scroll_vertical = 9999
	await get_tree().process_frame
	await get_tree().process_frame
	var img2 := get_viewport().get_texture().get_image()
	var out2: String = out_path.replace(".png", "_expanded.png")
	var err2 := img2.save_png(out2)
	print("[shot_result_rebuild] expanded saved (err=%d) -> %s" % [
		err2, ProjectSettings.globalize_path(out2)])

	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _find_scroll(screen: Node) -> ScrollContainer:
	for child in screen.get_children():
		if child is ScrollContainer:
			return child as ScrollContainer
	return null
