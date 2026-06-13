## shot_roll_topdown.gd — FLAT top-down setup 증명 shots (2026-06-10).
##
## 사용자 불만 "어째 비스듬하게 하나" 해소 검증: roll setup이 평평한 사용자-시점 top-down인가
## (diamond/parallelogram 아님, near edge 화면 하단)? FRONTAL_SQUASH/RICE/STRIP squash 제거 후
## 단계별 캡처:
##   setup            : avg_p=0   — mat → 김 → 밥 → 4 strips 평평 top-down (state 1, 비스듬 아님).
##   edge_lift        : avg_p≈0.10 — 하단 edge 살짝 들림 (state 2).
##   first_fold       : avg_p≈0.32 — 김/밥이 filling 위로 wrap 시작 (state 3).
##   cylinder_forming : avg_p≈0.62 — 절반 이상 말린 cylinder (state 4).
##   finished         : perfect even 완성 → tight round cylinder (state 5b).
##
## scoring/two-finger 입력 무변경 — _left_progress/_right_progress 직접 주입 후 _apply_roll_visual().
## Run via shot_roll_topdown.tscn (opengl3, NOT headless — needs real viewport image).
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")

var _out_dir: String = "user://roll_topdown"


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
		print("[roll-topdown-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[roll-topdown-shot] %s — NO IMAGE (dummy renderer)" % name)


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
	# --- setup (avg_p=0): 평평 top-down (비스듬 아님, near edge 하단) ---
	var r1 := _new_roll()
	await get_tree().create_timer(0.8).timeout
	await _capture("setup")
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

	# --- cylinder_forming (avg_p≈0.62): cylinder_forming (state 4) ---
	var r4 := _new_roll()
	await get_tree().create_timer(0.5).timeout
	_set_progress(r4, 0.62, 0.62)
	await get_tree().create_timer(0.3).timeout
	await _capture("cylinder_forming")
	await _free_roll(r4)

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
