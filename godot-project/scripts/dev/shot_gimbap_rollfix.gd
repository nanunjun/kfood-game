## shot_gimbap_rollfix.gd — Roll 이중 이미지 제거 + 재료 얇게 F5 검증 shots (2026-06-15).
##
## 사용자 핵심 불만(F5, Roll Step 4/7):
##   (1) 재료를 조금만 더 얇게.
##   (2) 드래그하면 flat 김/밥(gimbap_mat base)은 아래 그대로 남고 그 위에 별도 "말린 통"
##       그림이 따로 떠 보임(이중 이미지). → 김/밥/대나무발이 그 자체로 말리는 것으로.
##
## 교정 검증:
##   roll_flat     : roundness 0.08 (말기 전 flat setup — gimbap_mat base + **얇아진** 재료).
##   roll_mid      : roundness 0.45 (드래그 중 — gimbap_mat base가 fade out되어 자기완결적
##                   진행 sprite 1장만 보임 = flat bed 2겹/별도 통 0. **이중 이미지 제거 핵심**).
##   roll_finished : roundness 1.0 finalize (완성 통).
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

	await _shot_roll("flat", 0.08)
	await _shot_roll("mid", 0.45)
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
	var out := "user://grollfix_%s.png" % name
	if img != null:
		img.save_png(out)
		print("[rollfix-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[rollfix-shot] %s — NO IMAGE (dummy renderer)" % name)


func _bg() -> Node:
	var bg = KitchenBackgroundScript.new()
	bg.env_key = "home"
	get_tree().root.add_child(bg)
	return bg


# --- roll (이중 이미지 제거 + 재료 얇게) ---
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
		# 진행 중 state — set_roll(roundness, 0)로 painterly state swap + base fade(>=0.16).
		var p: float = roundness
		roll.set("_left_progress", p)
		roll.set("_right_progress", p)
		if roll.has_method("_apply_roll_visual"):
			roll.call("_apply_roll_visual")
		if roll.has_method("_update_hint"):
			roll.call("_update_hint")
	# base/fillings fade tween(0.18s)이 끝난 뒤 캡처 — mid에서 flat base가 완전히 사라졌는지 검증.
	await get_tree().create_timer(0.7).timeout
	await _capture("roll_%s" % tag)
	roll.queue_free(); bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
