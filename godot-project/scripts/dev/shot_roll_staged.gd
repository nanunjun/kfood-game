## shot_roll_staged.gd — STAGED physical-curl roll verification shots (2026-06-10).
##
## 가짜 scale 제거 + 4-state staged sprite swap이 실제로 cylinder 말림을 보이는지 증명한다.
## (2026-06-10 rebuild: first_fold/cylinder_forming 단면 조기노출 DROP → flat/edge_lift/half_roll
##  4-state 단면 중간 금지.) assets-raw/_screenshots/roll_staged/ 로 단계별 캡처:
##   flat_setup      : avg_p=0    — flat_setup sprite 평면 (state 1, 단면/cylinder 없음).
##   edge_lift       : avg_p≈0.10 — 하단 edge 살짝 들림 (state 2, 단면 없음).
##   first_fold      : avg_p≈0.32 — edge_lift→half_roll 전이 (단면 없음).
##   half_roll       : avg_p≈0.62 — 절반 말림 (state 3, 하단 log + 상단 평평 김, 단면 없음).
##   compressed_loose: 약한 pressure 완성 → 느슨 log (끝 상태).
##   finished        : perfect even 완성 → tight round log (finished_cylinder, 끝 상태).
##   compressed_tight: 과한 pressure 완성 → rice 삐져나옴/갈라짐 (끝 상태).
##
## scoring/two-finger 입력 무변경 — _left_progress/_right_progress 직접 주입 후 _apply_roll_visual().
## Run via shot_roll_staged.tscn (opengl3, NOT headless — needs real viewport image).
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")

var _out_dir: String = "user://roll_staged"


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("reset_progress"):
		sm.reset_progress()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_out_dir))
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
	var out := "%s/%s.png" % [_out_dir, name]
	if img != null:
		img.save_png(out)
		print("[roll-staged-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[roll-staged-shot] %s — NO IMAGE (dummy renderer)" % name)


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


# 두 손가락 진행을 직접 주입 (입력 sim 없이 결정적 state). scoring/입력 contract 무변경.
func _set_progress(roll: Node, lp: float, rp: float) -> void:
	roll.set("_left_progress", lp)
	roll.set("_right_progress", rp)
	roll.set("_rolling", true)
	roll.set("_left_id", 10)
	roll.set("_right_id", 11)
	if roll.has_method("_apply_roll_visual"):
		roll.call("_apply_roll_visual")
	if roll.has_method("_update_hint"):
		roll.call("_update_hint")


func _shot_states() -> void:
	# --- flat_setup (avg_p=0): 평평 layer (아직 안 말림) ---
	var r1 := _new_roll()
	await get_tree().create_timer(0.8).timeout
	await _capture("flat_setup")
	await _free_roll(r1)

	# --- edge_lift (avg_p≈0.10): 하단 edge 살짝 들림 (state 2) ---
	var r2 := _new_roll()
	await get_tree().create_timer(0.5).timeout
	_set_progress(r2, 0.10, 0.10)
	await get_tree().create_timer(0.3).timeout
	await _capture("edge_lift")
	await _free_roll(r2)

	# --- first_fold (avg_p≈0.32): wrap 시작 (state 3) ---
	var r3 := _new_roll()
	await get_tree().create_timer(0.5).timeout
	_set_progress(r3, 0.32, 0.32)
	await get_tree().create_timer(0.3).timeout
	await _capture("first_fold")
	await _free_roll(r3)

	# --- half_roll (avg_p≈0.62): cylinder_forming (state 4) ---
	var r4 := _new_roll()
	await get_tree().create_timer(0.5).timeout
	_set_progress(r4, 0.62, 0.62)
	await get_tree().create_timer(0.3).timeout
	await _capture("half_roll")
	await _free_roll(r4)

	# --- compressed_loose: 약한 pressure 완성 → 느슨 oval (state 5a) ---
	var r5 := _new_roll()
	await get_tree().create_timer(0.5).timeout
	_set_progress(r5, 0.40, 0.40)
	# weak pressure metrics → loose 판정.
	r5.set("_both_down_frames", 40)
	r5.set("_any_down_frames", 60)
	r5.set("_speed_samples", [300.0, 280.0])
	if r5.has_method("_finalize_roll"):
		r5.call("_finalize_roll")
	await get_tree().create_timer(0.7).timeout
	await _capture("compressed_loose")
	await _free_roll(r5)

	# --- finished: perfect even 완성 → tight round cylinder (state 5b) ---
	var r6 := _new_roll()
	await get_tree().create_timer(0.5).timeout
	_set_progress(r6, 0.92, 0.92)
	r6.set("_both_down_frames", 60)
	r6.set("_any_down_frames", 60)
	r6.set("_speed_samples", [200.0, 180.0, 220.0])
	if r6.has_method("_finalize_roll"):
		r6.call("_finalize_roll")
	await get_tree().create_timer(0.7).timeout
	await _capture("finished")
	await _free_roll(r6)

	# --- compressed_tight: 과한 pressure 완성 → 삐져나옴/갈라짐 (state 5c, burst) ---
	var r7 := _new_roll()
	await get_tree().create_timer(0.5).timeout
	_set_progress(r7, 1.18, 1.18)   # avg_p > burst_thresh(1.05) → burst.
	r7.set("_both_down_frames", 55)
	r7.set("_any_down_frames", 60)
	r7.set("_speed_samples", [250.0, 230.0])
	if r7.has_method("_finalize_roll"):
		r7.call("_finalize_roll")
	await get_tree().create_timer(0.7).timeout
	await _capture("compressed_tight")
	await _free_roll(r7)
