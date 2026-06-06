## shot_action_first_w1.gd — ADR-012 W1 GIF frame capture (slice / timing / season).
##
## 3 hero module의 action-first 동작을 보여주는 PNG sequence를 캡처한다 (main thread가
## PIL로 GIF 조립). 실제 module .tscn을 instantiate → 진짜 CookingBackground + LOCK art +
## procedural knife/flame/bottle 비주얼을 사용. module의 자체 _process 루프를 동결한 뒤
## stager가 frame 단계별로 동작 상태를 직접 세팅한다 (gameplay 코드 무수정).
##
##   slice : 칼 내려옴(손가락 따라) → 재료 갈라짐(whole fade / cut overlay) → 조각 누적.
##   timing: heat dial (불 약 → ideal simmer → overflow·burnt) + 불꽃/bubble/overflow.
##   season: 통 기울임(tilt) → 입자 낙하 → 음식 표면 양념 코팅 변화.
##
## 실행 (windowed — 뷰포트 렌더 필요, headless 금지):
##   <godot> --path godot-project res://scenes/shot_action_first_w1.tscn
## 출력 → user://gif/{module}/ ; main shell이 assets-raw/_screenshots/action_first_w1/ 로 복사.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const SparkleScript := preload("res://scripts/ui/premium/sparkle_particle.gd")

const COL_GOLD := Color(0.980, 0.780, 0.220)
const OUT_ROOT := "user://gif"
const FRAME_PAUSE := 0.16

var _inst: CookingModule = null
var _frame_idx: int = 0
var _module_id: String = ""


func _ready() -> void:
	print("=== Action-First W1 GIF capture (slice / timing / season) ===")
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_ROOT))

	await _run("slice",  "res://scenes/cooking/slice_module.tscn",  "t1_002", {"tap_count": 4, "bpm": 110.0}, _stage_slice)
	await _run("timing", "res://scenes/cooking/timing_module.tscn", "t1_002", {"duration_ms": 3500.0, "perfect_at": 0.85, "perfect_width": 0.18}, _stage_timing)
	await _run("season", "res://scenes/cooking/season_module.tscn", "t1_003", {"mode": "simple", "seasoning": "gochujang"}, _stage_season)

	print("=== Action-First W1 GIF capture done ===")
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _params(food_id: String, extra: Dictionary) -> Dictionary:
	var p: Dictionary = {
		"food_id": food_id, "guest_id": "junho",
		"level": MenuDB.get_level(1), "menu": MenuDB.get_menu(food_id),
		"step_no": 1, "step_total": 4,
	}
	for k in extra.keys():
		p[k] = extra[k]
	return p


func _run(module_id: String, scene_path: String, food_id: String, extra: Dictionary, stager: Callable) -> void:
	print("[gif] === %s (%s) ===" % [module_id, food_id])
	_module_id = module_id
	_frame_idx = 0
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("%s/%s" % [OUT_ROOT, module_id]))
	var packed := load(scene_path) as PackedScene
	if packed == null:
		push_warning("[gif] cannot load " + scene_path); return
	var inst := packed.instantiate() as CookingModule
	get_tree().root.add_child(inst)
	inst.start(_params(food_id, extra))
	_inst = inst
	await get_tree().create_timer(0.3).timeout
	# FREEZE gameplay loop — slice/season early-return on _finished, timing on _finished_timing.
	inst.set("_finished", true)
	if inst.get("_finished_timing") != null:
		inst.set("_finished_timing", true)
	await stager.call()
	inst.queue_free()
	_inst = null
	await get_tree().create_timer(0.2).timeout


func _snap() -> void:
	await get_tree().process_frame
	await get_tree().create_timer(FRAME_PAUSE).timeout
	var img := get_viewport().get_texture().get_image()
	var out_path := "%s/%s/%s_frame_%02d.png" % [OUT_ROOT, _module_id, _module_id, _frame_idx]
	var err := img.save_png(out_path)
	print("  frame %02d (err=%d) %dx%d -> %s" % [_frame_idx, err, img.get_width(), img.get_height(), out_path])
	_frame_idx += 1


func _sparkle_at(center: Vector2, diam: float = 220.0) -> void:
	var sp = SparkleScript.new()
	_inst.add_child(sp)
	sp.burst(center, 16, diam, Color(1.0, 0.92, 0.50), 0.7)


# =============================================================================
# SLICE — drag knife: 칼 내려옴 → 재료 갈라짐 → 조각 누적.
# =============================================================================
func _stage_slice() -> void:
	var knife := _inst.get("_knife") as Node2D
	var whole := _inst.get("_whole_tex") as TextureRect
	var cut := _inst.get("_cut_tex") as TextureRect
	var ind := _inst.get("_indicator") as Label
	var rect: Rect2 = _inst.get("INGREDIENT_RECT") if _inst.get("INGREDIENT_RECT") != null else Rect2(330, 820, 420, 380)
	var cx: float = rect.position.x + rect.size.x * 0.5

	# f00 idle — 칼 위, 재료 whole.
	if is_instance_valid(knife):
		knife.visible = true
		knife.position = Vector2(cx, rect.position.y - 80.0)
	if is_instance_valid(ind): ind.text = "다지기  0 / 4"
	await _snap()
	# f01 칼 손가락 따라 내려오기 시작 (재료 상단 접근).
	if is_instance_valid(knife): knife.position = Vector2(cx, rect.position.y + 40.0)
	await _snap()
	# f02 칼이 재료 가로지름 (cut 순간).
	if is_instance_valid(knife): knife.position = Vector2(cx, rect.position.y + rect.size.y * 0.7)
	_sparkle_at(Vector2(cx, rect.position.y + rect.size.y * 0.5), 200.0)
	await _snap()
	# f03 첫 조각 — whole 살짝 fade, cut overlay 시작, 조각 1 spawn.
	_set_cut_progress(whole, cut, 0.3)
	_spawn_piece_visual(0, rect)
	if is_instance_valid(ind): ind.text = "다지기  1 / 4"
	if is_instance_valid(knife): knife.position = Vector2(cx, rect.position.y - 60.0)
	await _snap()
	# f04 두 번째 cut.
	if is_instance_valid(knife):
		knife.visible = true
		knife.position = Vector2(cx - 30, rect.position.y + rect.size.y * 0.6)
	_set_cut_progress(whole, cut, 0.55)
	_spawn_piece_visual(1, rect)
	if is_instance_valid(ind): ind.text = "다지기  2 / 4"
	await _snap()
	# f05 세 번째 cut + 누적.
	_set_cut_progress(whole, cut, 0.78)
	_spawn_piece_visual(2, rect)
	if is_instance_valid(ind): ind.text = "다지기  3 / 4"
	if is_instance_valid(knife): knife.position = Vector2(cx + 20, rect.position.y - 50.0)
	await _snap()
	# f06 마지막 cut — 재료 완전히 갈라짐.
	_set_cut_progress(whole, cut, 1.0)
	_spawn_piece_visual(3, rect)
	if is_instance_valid(knife): knife.visible = false
	_sparkle_at(Vector2(cx, rect.position.y + rect.size.y * 0.5), 240.0)
	if is_instance_valid(ind): ind.text = "Sliced!"
	await _snap()
	# f07 완료 settle.
	await _snap()


func _set_cut_progress(whole: TextureRect, cut: TextureRect, prog: float) -> void:
	if is_instance_valid(whole):
		whole.modulate = Color(1, 1, 1, maxf(1.0 - prog, 0.0))
	if is_instance_valid(cut):
		cut.modulate = Color(1, 1, 1, clampf(prog + 0.1, 0.0, 1.0))


func _spawn_piece_visual(idx: int, rect: Rect2) -> void:
	var holder := _inst.get("_pieces_holder") as Control
	var cut_path: String = String(_inst.get("_cut_path")) if _inst.get("_cut_path") != null else ""
	if not is_instance_valid(holder):
		return
	var piece: Control
	if cut_path != "" and ResourceLoader.exists(cut_path):
		var t := TextureRect.new()
		t.texture = load(cut_path)
		t.size = Vector2(96, 96)
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		piece = t
	else:
		var c := ColorRect.new()
		c.color = Color(0.95, 0.66, 0.34)
		c.size = Vector2(72, 36)
		piece = c
	piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
	piece.position = Vector2(330.0 + float(idx % 4) * 110.0, 1280.0 + float(idx / 4) * 60.0)
	holder.add_child(piece)


# =============================================================================
# TIMING — heat dial: 불 약 → ideal simmer → overflow·burnt.
# =============================================================================
func _stage_timing() -> void:
	var pct := _inst.get("_pct_lbl") as Label
	var fill := _inst.get("_fill") as ColorRect
	# heat를 강제 세팅하고 module의 _apply_heat_visual을 직접 호출해 불꽃/bubble/overflow 갱신.
	var set_heat := func(h: float, overflow: float, hold_ratio: float) -> void:
		_inst.set("_heat", h)
		_inst.set("_overflow", overflow)
		_inst.call("_position_knob")
		_inst.call("_apply_heat_visual")
		if is_instance_valid(fill):
			fill.size.x = clampf(hold_ratio, 0.0, 1.0) * 840.0

	# f00 불 약함 (undercooked) — heat 낮음.
	set_heat.call(0.30, 0.0, 0.0)
	if is_instance_valid(pct): pct.text = "Heat 30%  · too low"
	await _snap()
	# f01 불 올리는 중.
	set_heat.call(0.55, 0.0, 0.05)
	if is_instance_valid(pct): pct.text = "Heat 55%  · turning up"
	await _snap()
	# f02 ideal zone 진입 (gold).
	set_heat.call(0.82, 0.0, 0.25)
	if is_instance_valid(pct): pct.text = "Heat 82%  · ideal simmer"
	await _snap()
	# f03 ideal simmer 유지 — zone-hold 막대 차오름.
	set_heat.call(0.85, 0.0, 0.55)
	if is_instance_valid(pct): pct.text = "Heat 85%  · ideal simmer"
	_sparkle_at(Vector2(640, 800), 200.0)
	await _snap()
	# f04 계속 유지.
	set_heat.call(0.86, 0.0, 0.78)
	if is_instance_valid(pct): pct.text = "Heat 86%  · ideal simmer"
	await _snap()
	# f05 불 너무 셈 → overflow risk ↑.
	set_heat.call(1.0, 0.55, 0.78)
	if is_instance_valid(pct): pct.text = "Heat 100%  · too hot!"
	await _snap()
	# f06 넘침 (overflow·burnt).
	set_heat.call(1.0, 0.95, 0.78)
	if is_instance_valid(pct): pct.text = "It boiled over!"
	await _snap()
	# f07 다시 ideal로 복귀 (회복).
	set_heat.call(0.85, 0.4, 0.85)
	if is_instance_valid(pct): pct.text = "Perfect simmer!"
	await _snap()


# =============================================================================
# SEASON — tilt bottle: 통 기울임 → 입자 낙하 → 음식 양념 코팅.
# =============================================================================
func _stage_season() -> void:
	var bottle := _inst.get("_bottle") as Node2D
	var hero := _inst.get("_food_hero") as TextureRect
	var hint := _inst.get("_hint") as Label
	var bx: float = bottle.position.x if is_instance_valid(bottle) else 540.0

	# f00 idle — 병 똑바로, 음식 plain.
	if is_instance_valid(bottle): bottle.rotation = 0.0
	if is_instance_valid(hint): hint.text = "Gochujang — tilt to pour"
	await _snap()
	# f01 병 기울이기 시작 (tilt).
	if is_instance_valid(bottle): bottle.rotation = deg_to_rad(22.0)
	_season_particles(Vector2(bx + 60, 900), 3)
	if is_instance_valid(hint): hint.text = "Gochujang — keep tilting…"
	await _snap()
	# f02 입자 낙하 + 음식 코팅 시작.
	if is_instance_valid(bottle): bottle.rotation = deg_to_rad(38.0)
	_season_particles(Vector2(bx + 30, 920), 4)
	_tint_food(hero, 0.3)
	await _snap()
	# f03 더 기울임 — 입자 더 떨어짐.
	if is_instance_valid(bottle): bottle.rotation = deg_to_rad(48.0)
	_season_particles(Vector2(bx - 20, 940), 4)
	_tint_food(hero, 0.55)
	if is_instance_valid(hint): hint.text = "Balanced! release"
	await _snap()
	# f04 음식 윤기 + 색 충분.
	_season_particles(Vector2(bx, 960), 3)
	_tint_food(hero, 0.8)
	await _snap()
	# f05 병 복귀 (release).
	if is_instance_valid(bottle): bottle.rotation = 0.0
	_sparkle_at(Vector2(540, 1200), 220.0)
	if is_instance_valid(hint): hint.text = "Seasoned!"
	await _snap()
	# f06 완성 settle.
	await _snap()


func _season_particles(at: Vector2, n: int) -> void:
	var holder := _inst.get("_particles_holder") as Control
	if not is_instance_valid(holder):
		return
	for i in range(n):
		var p := ColorRect.new()
		p.color = Color(0.78, 0.20, 0.15)
		p.size = Vector2(12, 12)
		p.position = Vector2(at.x + randf_range(-70, 70), at.y + randf_range(0, 120))
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(p)


func _tint_food(hero: TextureRect, amt: float) -> void:
	if is_instance_valid(hero):
		var tint: Color = Color(1, 1, 1).lerp(Color(0.78, 0.20, 0.15).lightened(0.35), amt * 0.5)
		hero.modulate = Color(tint.r, tint.g, tint.b, 1.0)
