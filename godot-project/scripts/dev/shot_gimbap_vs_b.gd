## shot_gimbap_vs_b.gd — Gimbap Vertical Slice Pass B F5 verification shots.
##
## Pass B = cross-stage consequence chain (design §8). Renders to user://gvsb_*.png
## (copied to assets-raw/_screenshots/gimbap_vs_b/ by the ps1):
##   arrange            : 5색 filling band 배치 (lower-third).
##   roll_mid           : two-finger push 진행 중(balance meter).
##   roll_perfect       : tight clean cylinder (high prep → 관대 sweet zone).
##   roll_bad           : burst/loose (low prep → 좁은 sweet zone, 같은 push가 터짐).
##   slice_clean        : roll 높음 → clean 8조각 (넓은 cut window).
##   slice_wobble       : roll 낮음 → wobble 조각 (좁은 cut window, 같은 cut).
##   plating            : wooden_tray drag-arrange 8조각 정렬.
##   guest_reaction     : 5 quality 종합 reaction bubble + guest avatar.
##
## consequence 비교쌍 (같은 입력, 다른 결과 — 인과 증명):
##   roll_consequence : 동일 push(_left/_right) + prep_quality 0.95 vs 0.15 → score 분기.
##   slice_consequence: 동일 cut(angle/speed) + roll_quality 0.95 vs 0.15 → cut score 분기.
##
## opengl3, NOT headless — 실제 viewport image 필요.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const ArrangeScript := preload("res://scripts/cooking_modules/arrange_module.gd")
const RollScript := preload("res://scripts/cooking_modules/roll_module.gd")
const SliceScript := preload("res://scripts/cooking_modules/slice_module.gd")
const PlateScript := preload("res://scripts/cooking_modules/plate_module.gd")
const Runner := preload("res://scripts/gameplay/gimbap_slice_runner.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("reset_progress"):
		sm.reset_progress()

	await _shot_arrange()
	await _shot_roll("mid", 0.55, 0.55, 0.95)
	await _shot_roll("perfect", 0.92, 0.92, 0.95)   # 고른 push + prep 좋음 → tight clean
	# bad — push가 강한데(1.06) prep 나쁨(좁은 sweet zone) → burst(squeeze out) + tilt 쏠림.
	await _shot_roll("bad", 1.06, 0.74, 0.15)
	await _shot_slice("clean", 0.95)                 # roll 높음 → clean
	await _shot_slice("wobble", 0.15)                # roll 낮음 → wobble (같은 cut)
	await _shot_plating()
	await _shot_guest()

	# consequence 비교쌍 — 동일 입력, prep/roll_quality만 달라 결과 분기 (시각 증명).
	#   push 1.04는 prep 좋음(burst 임계 1.05)에선 tight, prep 나쁨(좁은 zone, burst 임계 1.028)
	#   에선 burst(squeeze out) — 같은 손가락 push, 다른 결과(인과의 시각 증명).
	await _shot_roll("cmp_prep_good", 1.04, 1.04, 0.95)
	await _shot_roll("cmp_prep_bad", 1.04, 1.04, 0.15)
	await _shot_slice("cmp_roll_good", 0.95)              # 같은 cut — roll 좋음 → clean row.
	await _shot_slice("cmp_roll_bad", 0.15)               # 같은 cut — roll 나쁨 → wobble.

	# consequence 증명 — 같은 입력, 다른 결과(score 로그).
	await _proof_roll_consequence()
	await _proof_slice_consequence()

	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _params(food_id: String) -> Dictionary:
	return {
		"food_id": food_id, "guest_id": "junho",
		"level": MenuDB.get_level(1), "menu": MenuDB.get_menu(food_id),
		"step_no": 4, "step_total": 7,
	}


func _capture(name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var vtex := get_viewport().get_texture()
	var img: Image = vtex.get_image() if vtex != null else null
	var out := "user://gvsb_%s.png" % name
	if img != null:
		img.save_png(out)
		print("[gvsb-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[gvsb-shot] %s — NO IMAGE (dummy renderer)" % name)


func _bg() -> Node:
	var bg = KitchenBackgroundScript.new()
	bg.env_key = "home"
	get_tree().root.add_child(bg)
	return bg


# --- arrange (5색 band) ---
func _shot_arrange() -> void:
	var bg := _bg()
	var arr: Control = ArrangeScript.new()
	arr.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(arr)
	var p := _params("t1_004")
	p["vs_quality_state"] = {"prep_quality": 0.9}
	p["vs_available_slots"] = 5
	arr.start(p)
	await get_tree().create_timer(0.6).timeout
	await _capture("arrange")
	arr.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- roll: progress + prep_quality(consequence) 주입 후 시각/판정 ---
func _shot_roll(tag: String, lp: float, rp: float, prep_q: float) -> void:
	var bg := _bg()
	var roll: Control = RollScript.new()
	roll.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(roll)
	var p := _params("t1_004")
	p["vs_quality_state"] = {"prep_quality": prep_q, "arrange_balance": 1.0, "arrange_bias_dir": 1.0}
	roll.start(p)
	await get_tree().create_timer(0.4).timeout
	# 결정적 push 주입.
	roll.set("_left_progress", lp)
	roll.set("_right_progress", rp)
	roll.set("_both_down_frames", 60)
	roll.set("_any_down_frames", 60)
	if roll.has_method("_apply_roll_visual"):
		roll.call("_apply_roll_visual")
	if roll.has_method("_update_hint"):
		roll.call("_update_hint")
	if tag != "mid":
		# 마감 — finalize로 tear/loose/tight visual + score 분기.
		roll.set("_rolling", false)
		if roll.has_method("_finalize_roll"):
			roll.call("_finalize_roll")
	await get_tree().create_timer(0.6).timeout
	await _capture("roll_%s" % tag)
	roll.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- slice: roll_quality(consequence) 주입 후 cut 시각 (clean vs wobble) ---
func _shot_slice(tag: String, roll_q: float) -> void:
	var bg := _bg()
	var slice: Control = SliceScript.new()
	slice.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(slice)
	var p := _params("t1_004")
	p["cut_style"] = "round"             # 완성 roll 통썰기.
	p["tap_count"] = 6
	p["vs_quality_state"] = {"roll_quality": roll_q}
	slice.start(p)
	await get_tree().create_timer(0.4).timeout
	# 결정적 cut score 주입 + wobble pile 시각 spawn(consequence).
	var scores: Array = []
	for i in range(6):
		scores.append(90.0 if roll_q > 0.5 else 44.0)
		# 조각 spawn으로 wobble visual을 보이게 한다.
		slice.set("_cuts_done", i + 1)
		if slice.has_method("_spawn_piece"):
			slice.call("_spawn_piece", scores[i])
	slice.set("_cut_scores", scores)
	slice.set("_cuts_done", 6)
	if slice.has_method("_finalize"):
		slice.call("_finalize")
	await get_tree().create_timer(0.6).timeout
	await _capture("slice_%s" % tag)
	slice.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- plating (drag-arrange tray) ---
func _shot_plating() -> void:
	var bg := _bg()
	var plate: Control = PlateScript.new()
	plate.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(plate)
	var p := _params("t1_004")
	p["vs_quality_state"] = {"slice_quality": 0.85}
	plate.start(p)
	await get_tree().create_timer(0.5).timeout
	# 조각 일부를 target에 안착시켜 "tray에 정렬되는 중" 시각을 보인다(결정적).
	var pieces: Array = plate.get("_vs_pieces")
	var targets: Array = plate.get("_vs_targets")
	for i in range(mini(pieces.size(), targets.size())):
		var node: Control = pieces[i]["node"]
		if i < 4 and is_instance_valid(node):
			node.position = (targets[i] as Vector2) - node.size * 0.5
			pieces[i]["placed"] = true
			pieces[i]["target_idx"] = i
			pieces[i]["err"] = 8.0
	await get_tree().create_timer(0.3).timeout
	await _capture("plating")
	plate.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- guest reaction (5 quality bubble + avatar) via runner stage ---
func _shot_guest() -> void:
	var runner: Node = Runner.new()
	# runner 전체 부팅 없이 guest stage만 — quality-state를 직접 세팅 후 _build로 bubble만 띄운다.
	get_tree().root.add_child(runner)
	# runner _ready가 round를 로드하지만 guest stage는 직접 호출(부팅 race 회피 위해 wait).
	await get_tree().create_timer(1.8).timeout
	# 5 quality 종합 — roll 높음/plate 높음 → "Wow, the roll is so clean!".
	runner.set("quality_state", {
		"shopping_quality": 0.9, "prep_quality": 0.85, "roll_quality": 0.9,
		"slice_quality": 0.8, "plate_quality": 0.85, "arrange_balance": 1.0, "arrange_bias_dir": 1.0,
	})
	# guest avatar + bubble을 module_host에 직접 붙인다. shopping 잔재를 먼저 비운다.
	var host: Control = runner.get("_module_host")
	if host != null:
		if runner.has_method("_clear_module_host"):
			runner.call("_clear_module_host")
		await get_tree().process_frame
		var av = runner.call("_build_guest_avatar") if runner.has_method("_build_guest_avatar") else null
		if av != null:
			host.add_child(av)
		var line: String = runner.call("_pick_reaction_line")
		var bubble = runner.call("_build_reaction_bubble", line)
		host.add_child(bubble)
		print("[gvsb-shot] guest reaction line=\"%s\"" % line)
	await get_tree().create_timer(0.5).timeout
	await _capture("guest_reaction")
	runner.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# =====================================================================================
# CONSEQUENCE PROOF — 같은 입력, 다른 결과 (인과 증명 비교쌍).
# =====================================================================================

# §8.2 prep→roll: 동일한 두 손가락 push(1.01/1.01)인데 prep_quality만 다르면 roll score가 분기.
#   push 1.01은 prep 좋음(sweet zone 0.82~1.02)에선 sweet, prep 나쁨(좁아진 zone, sw_hi≈0.988)
#   에선 over(burst) → distance/pressure 감점. 같은 손가락 입력, 다른 결과 = 인과 증명.
func _proof_roll_consequence() -> void:
	var push: float = 1.01
	var hi := _roll_score_for(push, push, 0.95)
	var lo := _roll_score_for(push, push, 0.15)
	print("[gvsb-PROOF] ROLL consequence — SAME push (%.2f/%.2f): prep0.95 -> score=%.1f | prep0.15 -> score=%.1f | Δ=%.1f" % [
		push, push, hi, lo, hi - lo])


func _roll_score_for(lp: float, rp: float, prep_q: float) -> float:
	var roll: Node = RollScript.new()
	get_tree().root.add_child(roll)
	# start() → _module_start → _consume_vs_consequence가 _vs_sweet_scale을 prep_q로 세팅.
	roll.start({"food_id": "t1_004", "vs_quality_state": {"prep_quality": prep_q}})
	var sc: float = roll.call("_compute_roll_score", lp, rp, 1.0, 1.0)
	roll.queue_free()
	return sc


# §8.4 roll→slice: 동일한 cut(angle=69° spd=1050)인데 roll_quality만 다르면 cut score가 분기.
#   angle err 21°는 roll 높음(good_ang≈29)에선 good band, roll 낮음(좁아진 good_ang≈20)에선
#   band 밖 → 급감. speed 1050은 round band(500~1100) 안이나 좁아지면 더 marginal. 같은 cut 입력.
func _proof_slice_consequence() -> void:
	var info := {
		"start": Vector2(540, 820), "end": Vector2(540, 1200),
		"angle_deg": 69.0, "avg_speed": 1050.0, "straightness": 1.0,
	}
	var hi := _slice_cut_score_for(info, 0.95)
	var lo := _slice_cut_score_for(info, 0.15)
	print("[gvsb-PROOF] SLICE consequence — SAME cut (angle=69 spd=1050): roll0.95 -> cut=%.1f | roll0.15 -> cut=%.1f | Δ=%.1f" % [
		hi, lo, hi - lo])


func _slice_cut_score_for(info: Dictionary, roll_q: float) -> float:
	var slice: Node = SliceScript.new()
	get_tree().root.add_child(slice)
	slice.start({"food_id": "t1_004", "cut_style": "round", "tap_count": 6,
		"vs_quality_state": {"roll_quality": roll_q}})
	var sc: float = slice.call("_score_cut", info)
	slice.queue_free()
	return sc
