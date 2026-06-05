## shot_puck_states.gd — captures ActionPuck in each of its 5 states for D2 verification.
## Outputs 5 PNGs:
##   user://puck_01_idle.png
##   user://puck_02_hover.png   (label "HOVER" + manually scaled puck)
##   user://puck_03_active.png  (label "ACTIVE" + manually scaled puck)
##   user://puck_04_perfect.png (flash_perfect mid-bounce)
##   user://puck_05_miss.png    (flash_miss mid-shake)
extends Node

const ActionPuckScript := preload("res://scripts/ui/action_puck.gd")
const CookingBackgroundScript := preload("res://scripts/ui/cooking_background.gd")

var _puck: ActionPuck = null


func _ready() -> void:
	print("[puck_states] start")
	await get_tree().process_frame
	# Background so screenshots look like in-game.
	var bg = CookingBackgroundScript.new()
	bg.dish_anchor_y = 960.0
	get_tree().root.add_child(bg)
	# Label saying which state we're in (top of screen).
	var label := Label.new()
	label.name = "StateLabel"
	label.position = Vector2(0, 80)
	label.size = Vector2(1080, 100)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 60)
	label.add_theme_color_override("font_color", Color(0.30, 0.20, 0.10))
	label.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.85))
	label.add_theme_constant_override("outline_size", 4)
	get_tree().root.add_child(label)
	await get_tree().process_frame

	# Capture each state in sequence (one screenshot per state, settled or in-flash).
	await _capture_state("idle", "01_idle", Vector2.ONE, 1.0)
	await _capture_state("hover", "02_hover", Vector2(1.05, 1.05), 1.0)
	await _capture_state("active", "03_active", Vector2(0.95, 0.95), 1.0)
	await _capture_perfect()
	await _capture_miss()
	print("[puck_states] done")
	get_tree().quit()


func _capture_state(state_name: String, out_suffix: String, scale_override: Vector2,
		alpha: float) -> void:
	if _puck != null and is_instance_valid(_puck):
		_puck.queue_free()
		await get_tree().process_frame
	get_tree().root.get_node("StateLabel").text = state_name.to_upper()
	_puck = ActionPuckScript.new()
	_puck.setup("TAP", Vector2(540, 1200), 360.0, 72)
	get_tree().root.add_child(_puck)
	await get_tree().process_frame
	await get_tree().process_frame
	_puck.scale = scale_override
	_puck.modulate.a = alpha
	# Wait a couple frames so layout/render lands.
	for i in range(6):
		await get_tree().process_frame
	var out_path: String = "user://puck_%s.png" % out_suffix
	var img := get_viewport().get_texture().get_image()
	img.save_png(out_path)
	print("  [puck_states] %s -> %s" % [state_name, ProjectSettings.globalize_path(out_path)])


func _capture_perfect() -> void:
	if _puck != null and is_instance_valid(_puck):
		_puck.queue_free()
		await get_tree().process_frame
	get_tree().root.get_node("StateLabel").text = "PERFECT (gold flash + sparkle)"
	_puck = ActionPuckScript.new()
	_puck.setup("TAP", Vector2(540, 1200), 360.0, 72)
	get_tree().root.add_child(_puck)
	await get_tree().process_frame
	_puck.flash_perfect()
	# Wait ~0.18s so the bounce peaks and sparkles are airborne.
	for i in range(12):
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	img.save_png("user://puck_04_perfect.png")
	print("  [puck_states] perfect captured")


func _capture_miss() -> void:
	if _puck != null and is_instance_valid(_puck):
		_puck.queue_free()
		await get_tree().process_frame
	get_tree().root.get_node("StateLabel").text = "MISS (red flash + shake + dim)"
	_puck = ActionPuckScript.new()
	_puck.setup("TAP", Vector2(540, 1200), 360.0, 72)
	get_tree().root.add_child(_puck)
	await get_tree().process_frame
	_puck.flash_miss()
	# Wait ~0.08s into the shake.
	for i in range(6):
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	img.save_png("user://puck_05_miss.png")
	print("  [puck_states] miss captured")
