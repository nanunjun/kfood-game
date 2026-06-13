## shot_gimbap_rebuild.gd — Gimbap REBUILD F5 verification shots (2026-06-10).
##
## 사용자 거부 교정 증명 (gimbap-vertical-slice-v2): generic color-slot arrange 폐기 →
## Build Gimbap drag-assembly / Roll 4-state staged(단면 중간 금지, 평면 mat, bottom→top).
## user://gbr_*.png 로 8컷 캡처 → assets-raw/_screenshots/gimbap_rebuild/ 복사.
##   build            : 평면 mat + 김 + 밥(far margin) + 긴 strip lower-third (color-slot 아님).
##   roll_s1_flat     : flat setup (mat·김·밥·가로 strip 평평, 완성 cylinder 없음).
##   roll_s2_edge_lift: near edge 들림 (filling 보임, 완성/단면 없음).
##   roll_s3_half_roll: 절반 말림 (하단 log + 상단 평평 김, 단면 없음).
##   roll_finished    : 완성 round log (success finalize 후에만).
##   slice            : 완성 roll + cut guide (단면은 여기서 처음).
##   plate            : 조각 tray 정렬.
##
## opengl3, NOT headless — 실제 viewport image 필요.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const BuildScript := preload("res://scripts/cooking_modules/gimbap_build_module.gd")
const RollScript := preload("res://scripts/cooking_modules/roll_module.gd")
const SliceScript := preload("res://scripts/cooking_modules/slice_module.gd")
const PlateScript := preload("res://scripts/cooking_modules/plate_module.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("reset_progress"):
		sm.reset_progress()

	await _shot_build()
	await _shot_roll("s1_flat", 0.0, 0.0, false)
	await _shot_roll("s2_edge_lift", 0.20, 0.20, false)
	await _shot_roll("s3_half_roll", 0.55, 0.55, false)
	await _shot_roll("finished", 0.92, 0.92, true)    # success finalize → 완성 round log.
	await _shot_slice()
	await _shot_plate()

	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _params(food_id: String, step_no: int) -> Dictionary:
	return {
		"food_id": food_id, "guest_id": "junho",
		"level": MenuDB.get_level(1), "menu": MenuDB.get_menu(food_id),
		"step_no": step_no, "step_total": 7,
	}


func _capture(name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var vtex := get_viewport().get_texture()
	var img: Image = vtex.get_image() if vtex != null else null
	var out := "user://gbr_%s.png" % name
	if img != null:
		img.save_png(out)
		print("[gbr-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[gbr-shot] %s — NO IMAGE (dummy renderer)" % name)


func _bg() -> Node:
	var bg = KitchenBackgroundScript.new()
	bg.env_key = "home"
	get_tree().root.add_child(bg)
	return bg


# --- Build Gimbap (drag-assembly, color-slot 아님) ---
func _shot_build() -> void:
	var bg := _bg()
	var build: Control = BuildScript.new()
	build.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(build)
	var p := _params("t1_004", 3)
	p["vs_available_slots"] = 4
	build.start(p)
	await get_tree().create_timer(0.5).timeout
	# strip 3개를 밥 lower-third 에 안착시켜 "조립 중" 시각(결정적). _settle_strip 직접 호출.
	# 가로 centered 평행으로 — 단면이 예쁜 김밥(긴 strip 평행 배치, color-slot 아님).
	var strips: Array = build.get("_strips")
	var sg = build.get("_stage_group")
	if sg != null:
		var base: Vector2 = sg.position
		# lower-third centered 가로 — strip 3개를 STRIP_TARGET_Y(96) 근처에 평행 배치.
		var place := [Vector2(base.x, base.y + 110.0), Vector2(base.x, base.y + 78.0),
			Vector2(base.x, base.y + 46.0)]
		for i in range(mini(strips.size(), place.size())):
			if build.has_method("_settle_strip"):
				build.call("_settle_strip", i, place[i])
	# 안착 bounce tween + GOOD feedback 가 사라지도록 충분히 대기 후 캡처.
	await get_tree().create_timer(1.1).timeout
	await _capture("build")
	build.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- Roll 4-state staged — progress 주입 후 시각 (단면 중간 없음 증명) ---
func _shot_roll(tag: String, lp: float, rp: float, do_finalize: bool) -> void:
	var bg := _bg()
	var roll: Control = RollScript.new()
	roll.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(roll)
	var p := _params("t1_004", 4)
	p["vs_quality_state"] = {"prep_quality": 0.9, "arrange_balance": 1.0, "arrange_bias_dir": 1.0}
	roll.start(p)
	await get_tree().create_timer(0.4).timeout
	roll.set("_left_progress", lp)
	roll.set("_right_progress", rp)
	roll.set("_rolling", true)
	roll.set("_left_id", 10)
	roll.set("_right_id", 11)
	roll.set("_both_down_frames", 60)
	roll.set("_any_down_frames", 60)
	roll.set("_speed_samples", [200.0, 180.0, 220.0])
	if roll.has_method("_apply_roll_visual"):
		roll.call("_apply_roll_visual")
	if roll.has_method("_update_hint"):
		roll.call("_update_hint")
	if do_finalize:
		roll.set("_rolling", false)
		if roll.has_method("_finalize_roll"):
			roll.call("_finalize_roll")
	await get_tree().create_timer(0.6).timeout
	await _capture("roll_%s" % tag)
	roll.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- Slice (완성 roll + cut guide, 단면은 여기서 처음) ---
func _shot_slice() -> void:
	var bg := _bg()
	var slice: Control = SliceScript.new()
	slice.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(slice)
	var p := _params("t1_004", 5)
	p["cut_style"] = "round"
	p["tap_count"] = 6
	p["vs_quality_state"] = {"roll_quality": 0.9}
	slice.start(p)
	await get_tree().create_timer(0.7).timeout
	await _capture("slice")
	slice.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- Plate (조각 tray 정렬) ---
func _shot_plate() -> void:
	var bg := _bg()
	var plate: Control = PlateScript.new()
	plate.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(plate)
	var p := _params("t1_004", 6)
	p["vs_quality_state"] = {"slice_quality": 0.85}
	plate.start(p)
	await get_tree().create_timer(0.5).timeout
	var pieces: Array = plate.get("_vs_pieces")
	var targets: Array = plate.get("_vs_targets")
	if pieces != null and targets != null:
		for i in range(mini(pieces.size(), targets.size())):
			var node: Control = pieces[i]["node"]
			if i < 5 and is_instance_valid(node):
				node.position = (targets[i] as Vector2) - node.size * 0.5
				pieces[i]["placed"] = true
				pieces[i]["target_idx"] = i
				pieces[i]["err"] = 8.0
	await get_tree().create_timer(0.3).timeout
	await _capture("plate")
	plate.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
