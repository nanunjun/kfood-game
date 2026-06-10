## shot_roll_two_finger.gd — TWO-FINGER roll redesign verification shots.
##
## Renders the redesigned two-finger gimbap roll into assets-raw/_screenshots/roll_two_finger/:
##   setup           : layered (mat → 김 → 밥 → 4 strips) + two-finger targets(2) + arrows +
##                     balance meter + "Use two fingers to push both sides evenly".
##   rolling_even    : both progress ≈ 0.7 equal → tight straight cylinder.
##   rolling_crooked : left 0.95 / right 0.40 → tilted/angled crooked cylinder.
##   finished        : clean even release → finished gimbap roll.
##   feedback        : mid-roll balanced → "Perfect Balance!" hint visible.
##
## Run via shot_roll_two_finger.tscn (opengl3, NOT headless — needs real viewport image).
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("reset_progress"):
		sm.reset_progress()
	await _shot_states()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _params(food_id: String) -> Dictionary:
	return {
		"food_id": food_id, "guest_id": "junho",
		"level": MenuDB.get_level(1), "menu": MenuDB.get_menu(food_id),
		"step_no": 2, "step_total": 4,
	}


func _capture(name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var vtex := get_viewport().get_texture()
	var img: Image = vtex.get_image() if vtex != null else null
	var out := "user://roll2f_%s.png" % name
	if img != null:
		img.save_png(out)
		print("[roll2f-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[roll2f-shot] %s — NO IMAGE (dummy renderer)" % name)


func _new_roll() -> Node:
	var bg = KitchenBackgroundScript.new()
	bg.env_key = "home"
	get_tree().root.add_child(bg)
	var packed := load("res://scenes/cooking/roll_module.tscn") as PackedScene
	var roll: Node = packed.instantiate()
	roll.set_meta("bg", bg)
	get_tree().root.add_child(roll)
	if roll.has_method("start"):
		roll.start(_params("t1_004"))
	return roll


func _free_roll(roll: Node) -> void:
	var bg = roll.get_meta("bg") if roll.has_meta("bg") else null
	roll.queue_free()
	if bg != null:
		bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# 두 손가락 진행을 직접 주입해 visual을 합성한다 (입력 sim 없이 결정적 state).
func _set_progress(roll: Node, lp: float, rp: float, rolling: bool = true) -> void:
	roll.set("_left_progress", lp)
	roll.set("_right_progress", rp)
	roll.set("_rolling", rolling)
	if roll.has_method("_apply_roll_visual"):
		roll.call("_apply_roll_visual")
	if roll.has_method("_update_hint"):
		roll.call("_update_hint")


func _shot_states() -> void:
	# --- setup (p=0): layered + two-finger targets + arrows + balance meter + instruction ---
	var r1 := _new_roll()
	await get_tree().create_timer(0.8).timeout
	await _capture("setup")
	await _free_roll(r1)

	# --- rolling_even: both ≈ 0.7 equal → tight straight cylinder ---
	var r2 := _new_roll()
	await get_tree().create_timer(0.6).timeout
	_set_progress(r2, 0.70, 0.70)
	await get_tree().create_timer(0.4).timeout
	await _capture("rolling_even")
	await _free_roll(r2)

	# --- rolling_crooked: left 0.95 / right 0.40 → tilted crooked cylinder ---
	var r3 := _new_roll()
	await get_tree().create_timer(0.6).timeout
	_set_progress(r3, 0.95, 0.40)
	await get_tree().create_timer(0.4).timeout
	await _capture("rolling_crooked")
	await _free_roll(r3)

	# --- feedback: mid even → "Perfect Balance!" hint ---
	var r4 := _new_roll()
	await get_tree().create_timer(0.6).timeout
	# both fingers "down" so the hint logic shows balance message.
	r4.set("_left_id", 10)
	r4.set("_right_id", 11)
	_set_progress(r4, 0.55, 0.55)
	await get_tree().create_timer(0.4).timeout
	await _capture("feedback")
	await _free_roll(r4)

	# --- finished: clean even release → finished gimbap roll ---
	var r5 := _new_roll()
	await get_tree().create_timer(0.6).timeout
	_set_progress(r5, 0.92, 0.92)
	# inject good pressure/smooth metrics so finalize scores well_rolled.
	r5.set("_both_down_frames", 60)
	r5.set("_any_down_frames", 60)
	r5.set("_speed_samples", [200.0, 180.0, 220.0])
	if r5.has_method("_finalize_roll"):
		r5.call("_finalize_roll")
	await get_tree().create_timer(0.7).timeout
	await _capture("finished")
	await _free_roll(r5)
