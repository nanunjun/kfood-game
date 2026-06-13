## shot_gimbap_vs_a.gd — Gimbap Vertical Slice Pass A F5 verification shots.
##
## Renders to user://gvsa_*.png (copied to assets-raw/_screenshots/gimbap_vs_a/ by ps1):
##   shopping          : 시장 shelf + 재료(정답/distractor) + 장바구니 (일부 담긴 상태).
##   julienne_perfect  : 고른 얇은 strip + "Even, thin strips!" + sparkle.
##   julienne_bad      : chunky uneven strip + "Uneven, chunky strips".
##   runner_flow       : runner stage 전환 — shopping → julienne (banner step dots).
##
## opengl3, NOT headless — 실제 viewport image 필요.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const ShoppingStage := preload("res://scripts/gameplay/shopping_stage.gd")
const JulienneScript := preload("res://scripts/cooking_modules/julienne_module.gd")
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
	await _shot_shopping()
	await _shot_julienne(true)
	await _shot_julienne(false)
	await _shot_runner_flow()
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
	var out := "user://gvsa_%s.png" % name
	if img != null:
		img.save_png(out)
		print("[gvsa-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[gvsa-shot] %s — NO IMAGE (dummy renderer)" % name)


# --- shopping ---
func _shot_shopping() -> void:
	var stage := ShoppingStage.new()
	get_tree().root.add_child(stage)
	stage.start(_params("t1_004"))
	await get_tree().create_timer(0.6).timeout
	# 일부 정답을 담아 장바구니/슬롯 채움 시각을 보이게 한다(결정적 — 직접 collected 주입).
	stage.set("_collected", ["seaweed", "rice", "carrot"])
	if stage.has_method("_update_basket"):
		stage.call("_update_basket")
	# 담긴 shelf 타일을 그레이아웃 처리(시각 일치 — 타일은 Panel card).
	var tiles: Dictionary = stage.get("_shelf_tiles")
	for id in ["seaweed", "rice", "carrot"]:
		if tiles.has(id):
			var t = tiles[id]
			t.modulate = Color(0.6, 1.0, 0.6, 0.55)
	await get_tree().create_timer(0.4).timeout
	await _capture("shopping")
	stage.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- julienne perfect / bad ---
func _shot_julienne(perfect: bool) -> void:
	var bg = KitchenBackgroundScript.new()
	bg.env_key = "home"
	get_tree().root.add_child(bg)
	var jul: Control = JulienneScript.new()
	jul.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(jul)
	jul.start(_params("t1_004"))
	await get_tree().create_timer(0.5).timeout
	# RHYTHM REBUILD (2026-06-12): cut 표본을 새 rhythm 변수로 직접 주입해 결정적 grade를 만든다.
	#   perfect = 고른 박자(times) + 작고 일관된 offset + 높은 grade → 얇은 균일 strip.
	#   bad     = 들쭉날쭉 박자 + 큰/제각각 offset + 낮은 grade → chunky/uneven.
	#   변수 매핑: _cut_times_ms(rhythm) / _cut_offsets(spacing) / _cut_grades(thickness/angle).
	var times: Array = []
	var offsets: Array = []
	var grades: Array = []
	var base_t: float = float(Time.get_ticks_msec())
	if perfect:
		for i in range(6):
			times.append(base_t + float(i) * 320.0)            # 고른 320ms 간격(rhythm).
			offsets.append(8.0 + float(i % 2) * 4.0)           # 작고 고른 offset(spacing).
			grades.append(100.0)                                # Perfect(얇은 균일).
	else:
		var jitter_t: Array = [0.0, 180.0, 760.0, 900.0, 1700.0, 1760.0]   # 들쭉날쭉(rhythm).
		var jitter_o: Array = [12.0, 80.0, 40.0, 90.0, 20.0, 88.0]         # 제각각 offset(spacing).
		for i in range(6):
			times.append(base_t + float(jitter_t[i]))
			offsets.append(float(jitter_o[i]))
			grades.append(60.0)                                 # Good 위주(chunky).
	jul.set("_cut_times_ms", times)
	jul.set("_cut_offsets", offsets)
	jul.set("_cut_grades", grades)
	jul.set("_cut_scores", grades.duplicate())   # 부모 _cut_scores 호환(angle 축 원천).
	jul.set("_cuts_done", 6)
	if jul.has_method("_finalize"):
		jul.call("_finalize")
	await get_tree().create_timer(0.6).timeout
	var dims: Dictionary = jul.get_prep_dimensions() if jul.has_method("get_prep_dimensions") else {}
	print("[gvsa-shot] julienne %s prep_quality=%.2f dims=%s" % [
		("perfect" if perfect else "bad"), jul.get_prep_quality(), str(dims)])
	await _capture("julienne_perfect" if perfect else "julienne_bad")
	jul.queue_free()
	bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- runner flow (stage 전환: shopping → julienne) ---
func _shot_runner_flow() -> void:
	Runner.pending_menu_id = "t1_004"
	Runner.pending_guest_id = "junho"
	var runner: Node = Runner.new()
	get_tree().root.add_child(runner)
	# 부모 _start_request의 1.4s request banner 후 shopping stage가 dispatch된다.
	await get_tree().create_timer(2.2).timeout
	await _capture("runner_flow")
	runner.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
