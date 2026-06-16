## shot_gimbap_rollmat.gd — 김발 유지 + 재료 가로 말기 F5 검증 shots (2026-06-16, F5 fix v2).
##
## 사용자 거부(F5, Roll Step 4/7):
##   (1) 말리는 중 재료 방향이 세로(roll 축에 수직). 속은 **가로**(roll 축과 평행)여야 함.
##   (2) roll 시작 시 gimbap_mat(김발)을 fade out → **김발이 사라짐**. 받침이라 계속 보여야 함.
## 원인: 진행 단계가 mismatch staged 통 sprite(roll_edge_lift~compression: 김발 없음 + 사선 + 재료
##   세로)로 swap. 교정: procedural _RollGrowth가 김발 위에서 near→far로 어두운 통을 키우며 가로 재료를
##   감싼다. 김발 base는 fade 안 함(받침 유지).
##
## 검증 shots → assets-raw/_screenshots/gimbap_rollmat/:
##   roll_flat     : roundness 0.06 (말기 전 — 김발 + 김 + 밥 + 가로 재료 flat. 통 없음).
##   roll_mid      : roundness 0.45 (드래그 중 — **김발 보임** + **재료 가로 유지** + near→far 통 자람.
##                   별도 위치 통/세로 재료 0 = 이중 이미지 0). **핵심 검증 frame**.
##   roll_mid2     : roundness 0.70 (더 말림 — 통이 더 자람, 김발 여전히 보임, 재료 가로).
##   roll_finished : roundness 1.0 finalize (완성 open-end 통 — 김발 받침 위).
##
## scoring/two-finger/4-factor/consequence 무변경 — 순수 시각/전환만 검증.
## opengl3, NOT headless — 실제 viewport image 필요.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const RollScript := preload("res://scripts/cooking_modules/roll_module.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("reset_progress"):
		sm.reset_progress()

	await _shot_roll("flat", 0.06)
	await _shot_roll("mid", 0.45)
	await _shot_roll("mid2", 0.70)
	await _shot_roll("finished", 1.0)

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
	var out := "user://grollmat_%s.png" % name
	if img != null:
		img.save_png(out)
		print("[rollmat-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[rollmat-shot] %s — NO IMAGE (dummy renderer)" % name)


func _bg() -> Node:
	var bg = KitchenBackgroundScript.new()
	bg.env_key = "home"
	get_tree().root.add_child(bg)
	return bg


# --- roll (김발 유지 + 재료 가로 말기) ---
func _shot_roll(tag: String, roundness: float) -> void:
	var bg := _bg()
	var roll: Control = RollScript.new()
	roll.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(roll)
	roll.start(_params("t1_004"))
	await get_tree().create_timer(0.4).timeout
	if tag == "finished":
		# 완성 — well_rolled finished variant (양손 full + 균등).
		roll.set("_left_progress", 1.0)
		roll.set("_right_progress", 1.0)
		roll.set("_both_down_frames", 60)
		roll.set("_any_down_frames", 60)
		roll.set("_rolling", false)
		if roll.has_method("_finalize_roll"):
			roll.call("_finalize_roll")
	else:
		# 진행 중 — set_roll(roundness, 0)로 procedural 통 성장(김발/가로 재료 유지).
		var p: float = roundness
		roll.set("_left_progress", p)
		roll.set("_right_progress", p)
		if roll.has_method("_apply_roll_visual"):
			roll.call("_apply_roll_visual")
		if roll.has_method("_update_hint"):
			roll.call("_update_hint")
	# press beat / squash tween이 끝난 뒤 캡처.
	await get_tree().create_timer(0.7).timeout
	await _capture("roll_%s" % tag)
	roll.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
