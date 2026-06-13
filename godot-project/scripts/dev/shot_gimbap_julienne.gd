## shot_gimbap_julienne.gd — Gimbap Julienne RHYTHM SLICING F5 verification shots (2026-06-12).
##
## 사용자 승인 mechanic 전환 증명 — drag→rhythm tap 채썰기 재구축(Priority 1-6):
##   julienne_rhythm : setup 직후 — strict top-down 도마(평면, 사선 0) + 수평 당근 + 세로날 칼 +
##                     6 vertical cut guide + beat marker/target zone + progress 0/6. **grid 잔존 0.**
##   julienne_hit    : beat 성공 tap 3회 후 — 칼 내려옴 + 얇은 strip 누적 + 카운트↑ + Perfect/Good label.
##   julienne_done   : 6/6 — 모든 cut 성공 + Done 버튼 활성(gold).
##   runner_julienne : runner flow shopping→julienne 전환(grid 잔존 0 / 중복 손님 검증).
##
## scoring/save/4-factor 무변경 — 시각/조작 표시만. 입력은 실제 _gesture에 tap을 주입하되, beat
## 위상(_beat_t)을 target zone에 맞춰 정렬해 Perfect/Good 판정을 *실제 입력 경로*로 만든다(직접
## state 주입 아님 — _on_beat_input이 marker offset으로 판정).
##
## opengl3, NOT headless — 실제 viewport image 필요.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const JulienneScript := preload("res://scripts/cooking_modules/julienne_module.gd")
const Runner := preload("res://scripts/gameplay/gimbap_slice_runner.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")

var _out_dir: String = "user://gimbap_julienne2"


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("reset_progress"):
		sm.reset_progress()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_out_dir))
	await _shot_rhythm()
	await _shot_hit()
	await _shot_done()
	await _shot_runner_julienne()
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
		print("[julienne-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[julienne-shot] %s — NO IMAGE (dummy renderer)" % name)


func _new_julienne() -> Control:
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
	await get_tree().process_frame
	await get_tree().process_frame


# 한 박자 tap = marker를 target 중심으로 위상 정렬한 뒤 _gesture에 짧은 tap을 주입.
#   BEAT_PERIOD/TD_TRACK_X0/X1/TD_TARGET_X로 target에 marker가 오는 _beat_t를 역산해 세팅한다.
#   offset_px = 0 이면 Perfect, ~60이면 Good을 만든다(실제 판정 경로로 grade 산출).
func _tap_beat(jul: Control, offset_px: float) -> void:
	var gesture = jul.get("_gesture")
	if gesture == null:
		return
	# 직전 칼 swing이 끝날 때까지 대기(_knife_busy 중 tap은 모듈이 무시 — 실제 게임 동작).
	var guard: int = 0
	while bool(jul.get("_knife_busy")) and guard < 60:
		await get_tree().process_frame
		guard += 1
	# marker_x = lerp(X0, X1, phase) = TD_TARGET_X + offset → phase 역산 → _beat_t.
	var x0: float = 250.0    # TD_TRACK_X0
	var x1: float = 830.0    # TD_TRACK_X1
	var target_x: float = 720.0  # TD_TARGET_X
	var period: float = 1.05     # BEAT_PERIOD
	var want_x: float = target_x + offset_px
	var phase: float = clampf((want_x - x0) / (x1 - x0), 0.0, 1.0)
	jul.set("_beat_t", phase * period)   # _process가 다음 프레임에 marker를 여기로 그린다.
	# 같은 위상에서 즉시 tap(거의 정지 = pure tap). _on_beat_input이 현재 _beat_t로 offset 판정.
	var pt := Vector2(want_x, 880.0)
	gesture._gui_input(_touch(pt, true))
	gesture._gui_input(_touch(pt, false))
	await get_tree().process_frame


func _touch(pos: Vector2, pressed: bool) -> InputEventScreenTouch:
	var e := InputEventScreenTouch.new()
	e.position = pos
	e.pressed = pressed
	return e


# --- julienne_rhythm: setup 직후 (cut 0) — top-down 도마/당근/가이드/세로 칼/marker, grid 잔존 0 ---
func _shot_rhythm() -> void:
	var jul := _new_julienne()
	await get_tree().create_timer(0.7).timeout
	await _capture("julienne_rhythm")
	await _free_julienne(jul)


# --- julienne_hit: beat 성공 tap 3회 후 — 칼 내려옴 + 얇은 strip 누적 + 카운트↑ ---
func _shot_hit() -> void:
	var jul := _new_julienne()
	await get_tree().create_timer(0.5).timeout
	# 2 cut 먼저 완료(strip 누적 + 가이드 dim 보이게).
	await _tap_beat(jul, 0.0)     # Perfect
	await get_tree().create_timer(0.30).timeout
	await _tap_beat(jul, 45.0)    # Good
	await get_tree().create_timer(0.30).timeout
	# 3번째 tap — 칼이 내려오는 *중간*을 잡기 위해 swing in(0.09s) 직후 즉시 캡처(wait 없음).
	await _tap_beat(jul, 10.0)    # Perfect (knife 내려오는 중)
	await get_tree().create_timer(0.06).timeout   # swing down 진행 중.
	var holder = jul.get("_td_strip_holder")
	var strip_n: int = holder.get_child_count() if holder != null else -1
	print("[julienne-shot] hit cuts_done=%d strips=%d knife_busy=%s" % [
		int(jul.get("_cuts_done")), strip_n, str(jul.get("_knife_busy"))])
	await _capture("julienne_hit")
	await _free_julienne(jul)


# --- julienne_done: 6/6 모든 cut 성공 + Done 버튼 활성 ---
func _shot_done() -> void:
	var jul := _new_julienne()
	await get_tree().create_timer(0.5).timeout
	for i in range(6):
		await _tap_beat(jul, float(i % 2) * 18.0)   # 다양한 offset(Perfect/Good).
		await get_tree().create_timer(0.18).timeout
	await get_tree().create_timer(0.5).timeout
	var btn = jul.get("_done_btn")
	var enabled: bool = (not btn.disabled) if btn != null else false
	print("[julienne-shot] done cuts_done=%d done_enabled=%s prep_q=%.2f" % [
		int(jul.get("_cuts_done")), str(enabled),
		jul.get_prep_quality() if jul.has_method("get_prep_quality") else -1.0])
	await _capture("julienne_done")
	await _free_julienne(jul)


# --- runner_julienne: runner flow shopping→julienne 전환 (grid 잔존 0 / 중복 손님 0) ---
func _shot_runner_julienne() -> void:
	Runner.pending_menu_id = "t1_004"
	Runner.pending_guest_id = "junho"
	var runner: Node = Runner.new()
	get_tree().root.add_child(runner)
	await get_tree().create_timer(2.0).timeout
	var cur = runner.get("_current_module")
	if cur != null and cur.has_method("_finish"):
		cur.call("_finish")
	await get_tree().create_timer(1.4).timeout
	await _capture("runner_julienne")
	runner.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
