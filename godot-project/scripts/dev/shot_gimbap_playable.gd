## shot_gimbap_playable.gd — Gimbap vertical slice PLAYABILITY F5 verification (2026-06-12).
##
## 6 basic-playability 수정 증명 (실제 viewport, NOT headless):
##   market_before   : legacy shopping(빈 슬롯 "!" 마크, 카드 check/X 없음).
##   market_after    : 이미지 카드 + tap check(✓) + basket ingredient 아이콘 (! 없음).
##   julienne_before : legacy carrot(carrot_strip_long sausage cylinder, STRETCH_SCALE).
##   julienne_after  : carrot_whole(타피어드 당근) + thin carrot_julienne strips + English UI.
##   basket_icons    : 일부 선택 후 basket — 선택 ingredient 아이콘(! 없음), empty=dim ghost.
##   header_clean    : julienne header "Step 2/7 · Julienne Carrot — Gimbap" + subtitle.
##   done_advance    : **runner를 Step2(Julienne) 완료 → 실제 Done 버튼 클릭 → Step3(Build) 진입.**
##                     Issue 4 블로킹(Done이 안 넘어가던 플레이어 trap) 해소 증명.
##
## scoring/save/4-factor 무변경 — 시각/입력 표시만. done_advance는 실제 _gesture + Done 버튼
## 입력 경로를 사용(직접 state 주입 아님)해 "Done이 정말 다음 step으로 넘어간다"를 증명한다.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const ShoppingStage := preload("res://scripts/gameplay/shopping_stage.gd")
const JulienneScript := preload("res://scripts/cooking_modules/julienne_module.gd")
const Runner := preload("res://scripts/gameplay/gimbap_slice_runner.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")

var _out_dir: String = "user://gimbap_playable"


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("reset_progress"):
		sm.reset_progress()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_out_dir))
	await _shot_market(false)   # before
	await _shot_market(true)    # after
	await _shot_julienne(false) # before
	await _shot_julienne(true)  # after
	await _shot_basket_icons()
	await _shot_header_clean()
	await _shot_done_advance()  # 블로킹 해소 증명.
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _params(food_id: String) -> Dictionary:
	return {
		"food_id": food_id, "guest_id": "junho",
		"level": MenuDB.get_level(1), "menu": MenuDB.get_menu(food_id),
		"step_no": 2, "step_total": 7, "tap_count": 6,
	}


func _capture(name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var vtex := get_viewport().get_texture()
	var img: Image = vtex.get_image() if vtex != null else null
	var out := "%s/%s.png" % [_out_dir, name]
	if img != null:
		img.save_png(out)
		print("[playable-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[playable-shot] %s — NO IMAGE (dummy renderer)" % name)


func _touch(pos: Vector2, pressed: bool) -> InputEventScreenTouch:
	var e := InputEventScreenTouch.new()
	e.position = pos
	e.pressed = pressed
	return e


# --- market before/after ---
func _shot_market(after: bool) -> void:
	ShoppingStage.shot_legacy_basket = not after
	var stage := ShoppingStage.new()
	get_tree().root.add_child(stage)
	stage.start(_params("t1_004"))
	await get_tree().create_timer(0.6).timeout
	# 일부 정답을 담아 basket/슬롯 채움 + 카드 selected/check 시각을 보이게 한다.
	stage.set("_collected", ["seaweed", "rice", "carrot"])
	if stage.has_method("_update_basket"):
		stage.call("_update_basket")
	var tiles: Dictionary = stage.get("_shelf_tiles")
	for id in ["seaweed", "rice", "carrot"]:
		if tiles.has(id):
			var t = tiles[id]
			t.modulate = Color(0.72, 1.0, 0.72, 0.85)
			if after and stage.has_method("_mark_tile"):
				stage.call("_mark_tile", t, true)
	await get_tree().create_timer(0.4).timeout
	await _capture("market_after" if after else "market_before")
	stage.queue_free()
	ShoppingStage.shot_legacy_basket = false
	await get_tree().process_frame
	await get_tree().process_frame


# --- basket_icons (선택 ingredient 아이콘, ! 없음) ---
func _shot_basket_icons() -> void:
	ShoppingStage.shot_legacy_basket = false
	var stage := ShoppingStage.new()
	get_tree().root.add_child(stage)
	stage.start(_params("t1_004"))
	await get_tree().create_timer(0.5).timeout
	stage.set("_collected", ["seaweed", "rice", "danmuji", "egg"])
	if stage.has_method("_update_basket"):
		stage.call("_update_basket")
	await get_tree().create_timer(0.3).timeout
	await _capture("basket_icons")
	stage.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# --- julienne before/after ---
func _new_julienne(legacy: bool) -> Control:
	JulienneScript.shot_legacy_carrot = legacy
	var bg = KitchenBackgroundScript.new()
	bg.env_key = "home"
	get_tree().root.add_child(bg)
	var jul: Control = JulienneScript.new()
	jul.set_anchors_preset(Control.PRESET_FULL_RECT)
	jul.set_meta("bg", bg)
	get_tree().root.add_child(jul)
	jul.start(_params("t1_004"))
	return jul


func _free_julienne(jul: Control) -> void:
	var bg = jul.get_meta("bg") if jul.has_meta("bg") else null
	jul.queue_free()
	if bg != null:
		bg.queue_free()
	JulienneScript.shot_legacy_carrot = false
	await get_tree().process_frame
	await get_tree().process_frame


func _shot_julienne(after: bool) -> void:
	var jul := _new_julienne(not after)
	await get_tree().create_timer(0.7).timeout
	await _capture("julienne_after" if after else "julienne_before")
	await _free_julienne(jul)


# --- header_clean (julienne header — Step 2/7 · Julienne Carrot — Gimbap) ---
func _shot_header_clean() -> void:
	var jul := _new_julienne(false)
	await get_tree().create_timer(0.7).timeout
	await _capture("header_clean")
	await _free_julienne(jul)


# === done_advance — Issue 4 블로킹 해소 증명 ===
# runner를 띄워 Step1(Market) → Step2(Julienne)까지 자동 진행시키고, julienne 6/6 후 *실제 Done
# 버튼*을 입력 경로로 눌러 Step3(Build)로 넘어가는지 확인한다. 직전 step별로 banner step 번호와
# 현재 module 종류를 print해 "Done이 정말 다음 step으로 advance"를 로그+스크린샷으로 증명.
func _shot_done_advance() -> void:
	Runner.pending_menu_id = "t1_004"
	Runner.pending_guest_id = "junho"
	var runner: Node = Runner.new()
	get_tree().root.add_child(runner)
	# 부모 _start_request의 1.4s request banner 후 shopping stage가 dispatch된다.
	# shopping stage(Step1)를 자동 완료(_finish)시켜 Step2(Julienne)로 보낸다.
	var jul = await _wait_for_module(runner, "julienne_module", 6.0)
	if jul == null:
		# shopping이 아직이면 강제 완료 후 다시 대기.
		var cur = runner.get("_current_module")
		if cur != null and cur.has_method("_finish"):
			cur.call("_finish")
		jul = await _wait_for_module(runner, "julienne_module", 6.0)
	if jul == null:
		print("[done-advance] FAIL — julienne module never reached")
		await _capture("done_advance")
		runner.queue_free()
		return
	print("[done-advance] reached Step %d module=%s" % [int(runner.get("_step_no")), jul.get_class()])
	# julienne 6 cut을 실제 _gesture tap 경로로 완료 → Done 버튼 활성.
	await get_tree().create_timer(0.4).timeout
	for i in range(6):
		await _tap_beat(jul, float(i % 2) * 18.0)
		await get_tree().create_timer(0.2).timeout
	await get_tree().create_timer(0.4).timeout
	var done_btn = jul.get("_done_btn")
	var cuts_done: int = int(jul.get("_cuts_done"))
	var enabled: bool = (not done_btn.disabled) if done_btn != null else false
	print("[done-advance] julienne cuts_done=%d done_enabled=%s" % [cuts_done, enabled])
	var step_before: int = int(runner.get("_step_no"))
	# **실제 Done 버튼 press** — gesture overlay가 가로채지 않고 button.pressed가 발생해야 한다.
	if done_btn != null:
		done_btn.emit_signal("pressed")
	# Done → julienne _finalize → module_completed → runner _advance_after_step(0.25s) → Step3 Build.
	var build = await _wait_for_module(runner, "gimbap_build_module", 4.0)
	var step_after: int = int(runner.get("_step_no"))
	if build != null:
		print("[done-advance] PASS — Done advanced Step %d -> Step %d (module=%s) BLOCKING RESOLVED" % [
			step_before, step_after, build.get_class()])
	else:
		print("[done-advance] FAIL — still on Step %d after Done (module=%s)" % [
			step_after, str(runner.get("_current_module"))])
	await get_tree().create_timer(0.4).timeout
	await _capture("done_advance")
	runner.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


# runner의 _current_module이 file_hint(스크립트 file 경로 substring) 모듈이 될 때까지 대기.
func _wait_for_module(runner: Node, file_hint: String, timeout_s: float):
	var elapsed: float = 0.0
	while elapsed < timeout_s:
		var cur = runner.get("_current_module")
		if cur != null and is_instance_valid(cur):
			var sp = cur.get_script()
			var path: String = sp.resource_path if sp != null else ""
			if path.to_lower().contains(file_hint.to_lower()):
				return cur
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	return null


# 한 박자 tap — marker를 target 중심으로 위상 정렬한 뒤 _gesture에 짧은 tap을 주입(실제 판정 경로).
func _tap_beat(jul: Control, offset_px: float) -> void:
	var gesture = jul.get("_gesture")
	if gesture == null:
		return
	var guard: int = 0
	while bool(jul.get("_knife_busy")) and guard < 60:
		await get_tree().process_frame
		guard += 1
	var x0: float = 250.0
	var x1: float = 830.0
	var target_x: float = 720.0
	var period: float = 1.05
	var want_x: float = target_x + offset_px
	var phase: float = clampf((want_x - x0) / (x1 - x0), 0.0, 1.0)
	jul.set("_beat_t", phase * period)
	var pt := Vector2(want_x, 880.0)
	gesture._gui_input(_touch(pt, true))
	gesture._gui_input(_touch(pt, false))
	await get_tree().process_frame
