## shot_gimbap_painterly.gd — Gimbap procedural→painterly swap F5 verification shots.
##
## gimbap-visual-quality-rebuild-v1 §9. 각 조리 stage의 procedural geometry를 high-angle
## painterly sprite로 교체한 결과를 실제 opengl3 viewport로 캡처한다. 입력/scoring/4-factor/
## save/consequence contract 무변경 — 순수 시각 layer swap 검증.
##
## Renders to user://gpaint_*.png (copied to assets-raw/_screenshots/gimbap_painterly/ by ps1):
##   julienne_painterly : 당근 painterly(carrot_on_board) + 채 strips(carrot_strips_good) + board.
##   build_painterly    : mat/김/밥/filling painterly volume (real food).
##   roll_flat          : roll 진행 state 1 (roll_flat_setup painterly, 단면 0).
##   roll_curling       : roll 진행 state 4 (roll_curling painterly, 단면 0).
##   roll_finished      : 완성 (roll_finished painterly, 단면 finished만).
##   slice_painterly    : roll 좋음 → gimbap_piece_good painterly 조각 (clean).
##   slice_collapse     : roll 나쁨 → gimbap_piece_collapse (filling 쏟아짐 시각).
##   plate_painterly    : real 나무 tray (wooden_tray_topdown) + 조각 정렬.
##   chef_select_6      : Choose Your Chef 6 preset (Hana/Joon/Leo/Amara/Min/Ari).
##
## opengl3, NOT headless — 실제 viewport image 필요.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const JulienneScript := preload("res://scripts/cooking_modules/julienne_module.gd")
const GimbapBuildScript := preload("res://scripts/cooking_modules/gimbap_build_module.gd")
const RollScript := preload("res://scripts/cooking_modules/roll_module.gd")
const GimbapSliceScript := preload("res://scripts/cooking_modules/gimbap_slice_module.gd")
const PlateScript := preload("res://scripts/cooking_modules/plate_module.gd")
const ChefSelectScript := preload("res://scripts/ui/gender_select.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("reset_progress"):
		sm.reset_progress()

	await _shot_julienne()
	await _shot_build()
	await _shot_roll("flat", 0.10)
	await _shot_roll("curling", 0.62)
	await _shot_roll("finished", 1.0)
	await _shot_slice("painterly", 0.95)       # roll 좋음 → clean piece_good.
	await _shot_slice("collapse", 0.10)        # roll 나쁨 → piece_collapse (filling 쏟아짐).
	await _shot_plate()
	await _shot_chef_select()

	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _params(food_id: String) -> Dictionary:
	return {
		"food_id": food_id, "guest_id": "junho",
		"level": MenuDB.get_level(1), "menu": MenuDB.get_menu(food_id),
		"step_no": 2, "step_total": 7,
	}


func _capture(name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var vtex := get_viewport().get_texture()
	var img: Image = vtex.get_image() if vtex != null else null
	var out := "user://gpaint_%s.png" % name
	if img != null:
		img.save_png(out)
		print("[gpaint-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[gpaint-shot] %s — NO IMAGE (dummy renderer)" % name)


func _bg() -> Node:
	var bg = KitchenBackgroundScript.new()
	bg.env_key = "home"
	get_tree().root.add_child(bg)
	return bg


# --- julienne (carrot_on_board painterly + 채 strips, 진행 중 — 당근 + 잘린 채 동시에 보임) ---
func _shot_julienne() -> void:
	var bg := _bg()
	var jul: Control = JulienneScript.new()
	jul.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(jul)
	jul.start(_params("t1_004"))
	await get_tree().create_timer(0.5).timeout
	# 진행 중 — 당근(carrot_on_board painterly)이 보이는 채로 일부 채 strip을 생성한다(당근+채 동시).
	# _finalize는 호출하지 않아 당근이 fade되지 않고, painterly carrot + 잘린 strip을 함께 검증.
	# _register_cut(grade, offset)는 _next_guide/_cuts_done를 자체 관리 — 사전 set 금지.
	var perfect_grade: int = RhythmJudge.PERFECT
	for i in range(2):
		if jul.has_method("_register_cut"):
			jul.call("_register_cut", perfect_grade, 10.0)
		await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	await _capture("julienne_painterly")
	jul.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- build (mat/seaweed/rice/filling painterly) ---
func _shot_build() -> void:
	var bg := _bg()
	var build: Control = GimbapBuildScript.new()
	build.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(build)
	var p := _params("t1_004")
	p["vs_available_slots"] = 4
	build.start(p)
	await get_tree().create_timer(0.5).timeout
	# strip들을 밥 위 lower-third에 결정적으로 안착시켜 "완성 조립" 시각을 보인다.
	var strips: Array = build.get("_strips")
	var group: Node2D = build.get("_stage_group")
	if group != null:
		for i in range(strips.size()):
			var node: Control = strips[i]["node"]
			if not is_instance_valid(node):
				continue
			# group 로컬 lower-third에 평행 band로 직접 안착(snap 동작 대신 결정적 배치).
			var row_y: float = 96.0 + (float(i) - float(strips.size() - 1) * 0.5) * 46.0
			var keep_parent := node.get_parent()
			if keep_parent != null:
				keep_parent.remove_child(node)
			group.add_child(node)
			node.position = Vector2(0.0, row_y) - node.size * 0.5
	await get_tree().create_timer(0.4).timeout
	await _capture("build_painterly")
	build.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- roll (painterly state cross-fade swap) ---
func _shot_roll(tag: String, roundness: float) -> void:
	var bg := _bg()
	var roll: Control = RollScript.new()
	roll.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(roll)
	roll.start(_params("t1_004"))
	await get_tree().create_timer(0.4).timeout
	if tag == "finished":
		# 완성 — well_rolled finished variant.
		roll.set("_left_progress", 1.0)
		roll.set("_right_progress", 1.0)
		roll.set("_both_down_frames", 60)
		roll.set("_any_down_frames", 60)
		roll.set("_rolling", false)
		if roll.has_method("_finalize_roll"):
			roll.call("_finalize_roll")
	else:
		# 진행 중 state — set_roll(roundness, 0)로 painterly state swap.
		var p: float = roundness
		roll.set("_left_progress", p)
		roll.set("_right_progress", p)
		if roll.has_method("_apply_roll_visual"):
			roll.call("_apply_roll_visual")
		if roll.has_method("_update_hint"):
			roll.call("_update_hint")
	await get_tree().create_timer(0.6).timeout
	await _capture("roll_%s" % tag)
	roll.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- slice (painterly roll + piece_good vs piece_collapse) ---
func _shot_slice(tag: String, roll_q: float) -> void:
	var bg := _bg()
	var slice: Control = GimbapSliceScript.new()
	slice.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(slice)
	var p := _params("t1_004")
	p["vs_quality_state"] = {"roll_quality": roll_q}
	slice.start(p)
	await get_tree().create_timer(0.4).timeout
	# 조각 6개를 결정적으로 spawn → roll_q 낮으면 collapse(filling 쏟아짐), 높으면 good.
	for i in range(6):
		slice.set("_cuts_done", i + 1)
		slice.set("_guide_cut", _cut_mask(i + 1))
		if slice.has_method("_spawn_piece"):
			slice.call("_spawn_piece", 20.0 if roll_q > 0.5 else 80.0)
	await get_tree().create_timer(0.6).timeout
	await _capture("slice_%s" % tag)
	slice.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# guide_cut 마스크(앞 n개 true) — _spawn_piece가 참조하는 _cuts_done과 일관.
func _cut_mask(n: int) -> Array:
	var out: Array = []
	for i in range(6):
		out.append(i < n)
	return out


# --- plate (real wooden tray painterly) ---
func _shot_plate() -> void:
	var bg := _bg()
	var plate: Control = PlateScript.new()
	plate.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(plate)
	var p := _params("t1_004")
	p["vs_quality_state"] = {"slice_quality": 0.85}
	plate.start(p)
	await get_tree().create_timer(0.5).timeout
	# 조각 일부를 slot에 안착 → "real tray에 정렬되는 중" 시각.
	var pieces: Array = plate.get("_vs_pieces")
	var targets: Array = plate.get("_vs_targets")
	for i in range(mini(pieces.size(), targets.size())):
		var node: Control = pieces[i]["node"]
		if i < 5 and is_instance_valid(node):
			node.position = (targets[i] as Vector2) - node.size * 0.5
			pieces[i]["placed"] = true
			pieces[i]["target_idx"] = i
			pieces[i]["err"] = 8.0
	await get_tree().create_timer(0.3).timeout
	await _capture("plate_painterly")
	plate.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- chef select 6 preset ---
func _shot_chef_select() -> void:
	var chef: Control = ChefSelectScript.new()
	chef.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(chef)
	await get_tree().create_timer(0.8).timeout
	await _capture("chef_select_6")
	chef.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
