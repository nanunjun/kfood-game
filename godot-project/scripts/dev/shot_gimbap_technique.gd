## shot_gimbap_technique.gd — 실제 김밥집 영상 기법 F5 증명 (2026-06-13).
##
## docs/design/gimbap-rolling-technique-v1.md ground truth 대로 Build/Roll/Slice 재구현을 캡처한다.
## 6컷:
##   build_bundle         : 재료 한 다발(틈 없이 맞닿음) + far쪽 맨 김 margin(밥 없는 봉합 strip).
##   roll_envelope        : near edge가 재료 위로 덮음(first_fold envelope).
##   roll_press           : 김발로 통을 눌러 다지는 beat(press mat band).
##   roll_finished_smooth : 완성 = 매끈 검은 통(roll_finished, 단면 0).
##   slice_smooth         : Slice 진입 = 매끈 통(gimbap_roll_for_slice, 단면 0).
##   slice_cut            : 자를 때만 단면 조각(gimbap_piece) 분리.
##
## opengl3, NOT headless — 실제 viewport image 필요. 출력 user://gtech_*.png.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const BuildScript := preload("res://scripts/cooking_modules/gimbap_build_module.gd")
const RollScript := preload("res://scripts/cooking_modules/roll_module.gd")
const GimbapSliceScript := preload("res://scripts/cooking_modules/gimbap_slice_module.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("reset_progress"):
		sm.reset_progress()

	await _shot_build_bundle()
	await _shot_roll("envelope", 0.42, 0.42, false)        # first_fold — near가 재료 위로 덮음.
	await _shot_roll("press", 0.82, 0.82, false)           # compression — 눌러 다지기 beat.
	await _shot_roll("finished_smooth", 0.92, 0.92, true)  # 완성 매끈 검은 통(단면 0).
	await _shot_slice_smooth()                             # 매끈 통 진입(단면 0).
	await _shot_slice_cut()                                # 자를 때만 단면 조각.

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
	var out := "user://gtech_%s.png" % name
	if img != null:
		img.save_png(out)
		print("[gtech-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[gtech-shot] %s — NO IMAGE (dummy renderer)" % name)


func _bg() -> Node:
	var bg = KitchenBackgroundScript.new()
	bg.env_key = "home"
	get_tree().root.add_child(bg)
	return bg


# --- Build: 재료 한 다발 + far 맨김 margin ---
func _shot_build_bundle() -> void:
	var bg := _bg()
	var build: Control = BuildScript.new()
	build.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(build)
	var p := _params("t1_004", 3)
	p["vs_available_slots"] = 4
	build.start(p)
	await get_tree().create_timer(0.5).timeout
	# 재료 4개를 한 다발로(BUNDLE_TARGET_Y 근처 packed) 안착 — _settle_strip이 다발 packing.
	var strips: Array = build.get("_strips")
	var sg = build.get("_stage_group")
	if sg != null and strips != null:
		var base: Vector2 = sg.position
		for i in range(strips.size()):
			if build.has_method("_settle_strip"):
				# 다발 중심으로 모이게 — drop_y를 BUNDLE_TARGET_Y 근처로(packing은 settle이 처리).
				build.call("_settle_strip", i, Vector2(base.x, base.y + 70.0))
	await get_tree().create_timer(1.1).timeout
	await _capture("build_bundle")
	build.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- Roll: envelope / press / finished smooth ---
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
	if tag == "press":
		# press beat는 set_roll(roundness>=0.72)에서 자동 트리거(pulse ~0.36s). band가 보이는
		# 절정(0.16s)에 직접 캡처 — pulse가 사라지기 전 "김발이 통을 누르는" 순간을 잡는다.
		var stage = roll.get("_stage")
		if stage != null and stage.has_method("_play_press_beat"):
			stage.call("_play_press_beat", 0.0)   # 결정적으로 press band를 다시 켠다.
		await get_tree().create_timer(0.16).timeout
		await _capture("roll_%s" % tag)
	else:
		await get_tree().create_timer(0.6).timeout
		await _capture("roll_%s" % tag)
	roll.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- Slice 진입: 매끈 통(단면 0) ---
func _shot_slice_smooth() -> void:
	var bg := _bg()
	var slice: Control = GimbapSliceScript.new()
	slice.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(slice)
	var p := _params("t1_004", 5)
	p["vs_quality_state"] = {"roll_quality": 0.9}
	slice.start(p)
	await get_tree().create_timer(0.7).timeout
	await _capture("slice_smooth")
	slice.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- Slice 자를 때: 단면 조각 분리 ---
func _shot_slice_cut() -> void:
	var bg := _bg()
	var slice: Control = GimbapSliceScript.new()
	slice.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(slice)
	var p := _params("t1_004", 5)
	p["vs_quality_state"] = {"roll_quality": 0.9}
	slice.start(p)
	await get_tree().create_timer(0.6).timeout
	# 3개 guide를 정확히 잘라 단면 조각 분리(자를 때만 단면) — _register_cut 직접 호출.
	if slice.has_method("_register_cut"):
		for gi in range(3):
			var gx: float = 0.0
			if slice.has_method("_guide_x"):
				gx = float(slice.call("_guide_x", gi))
			slice.call("_register_cut", gi, 10.0, 1.0, Vector2(gx, 950.0))
			await get_tree().create_timer(0.15).timeout
	await get_tree().create_timer(0.4).timeout
	await _capture("slice_cut")
	slice.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
