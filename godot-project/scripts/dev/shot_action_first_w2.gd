## shot_action_first_w2.gd — ADR-012 W2 GIF frame capture (stir / arrange / roll / flip).
##
## W2의 4 module action-first 동작을 보여주는 PNG sequence 캡처 (main thread가 PIL로 GIF 조립).
## 실제 module .tscn instantiate → 진짜 CookingBackground + LOCK art + procedural churn/mat/flip
## 비주얼 사용. module 자체 _process/gesture를 동결(_finished=true)한 뒤 stager가 frame 단계별로
## 동작 상태를 직접 세팅 (gameplay 코드 무수정 — W1 shot_action_first_w1.gd 패턴 응용).
##
##   stir   : 주걱이 원을 그림 → 재료 churn(orbit) + 양념색 spread + 윤기 증가.
##   arrange: 재료를 집어 슬롯으로 drag → magnet glow → snap settle (5색 띠).
##   roll   : 김발 forward drag → 김밥 점진 말림(round) + 재료 빨려듦 → release 단단한 원통.
##   flip   : 음식 flick → 공중 arc 회전 → 반대면 착지(texture flip).
##
## 실행 (windowed — 뷰포트 렌더 필요, headless 금지):
##   <godot> --path godot-project res://scenes/shot_action_first_w2.tscn
## 출력 → user://gif/{module}/ ; main shell이 assets-raw/_screenshots/action_first_w2/ 로 복사.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const SparkleScript := preload("res://scripts/ui/premium/sparkle_particle.gd")

const OUT_ROOT := "user://gif"
const FRAME_PAUSE := 0.16
const TWO_PI: float = TAU

var _inst: CookingModule = null
var _frame_idx: int = 0
var _module_id: String = ""


func _ready() -> void:
	print("=== Action-First W2 GIF capture (stir / arrange / roll / flip) ===")
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_ROOT))

	await _run("stir",    "res://scenes/cooking/stir_module.tscn",    "t1_005", {"variant": "wok", "target_turns": 3.0}, _stage_stir)
	await _run("arrange", "res://scenes/cooking/arrange_module.tscn", "t1_004", {"slot_count": 5}, _stage_arrange)
	await _run("roll",    "res://scenes/cooking/roll_module.tscn",    "t1_004", {}, _stage_roll)
	await _run("flip",    "res://scenes/cooking/flip_module.tscn",    "t1_006", {"variant": "pajeon"}, _stage_flip)

	print("=== Action-First W2 GIF capture done ===")
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
	# FREEZE gameplay loop — gesture handlers early-return on _finished.
	inst.set("_finished", true)
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
# STIR — circular swipe: 주걱이 원을 그림 → 재료 churn + 양념 spread + 윤기.
# =============================================================================
func _stage_stir() -> void:
	var center: Vector2 = _inst.get("STIR_CENTER") if _inst.get("STIR_CENTER") != null else Vector2(540, 1000)
	var variant: Dictionary = _inst.get("_variant")
	var radius: float = float(variant.get("radius", 180.0)) if variant != null else 180.0
	var spoon := _inst.get("_spoon") as Node2D
	var lbl := _inst.get("_count_lbl") as Label

	# 누적 각도/회전 수를 강제 세팅하고 module의 _apply_churn을 직접 호출.
	var set_stir := func(turns: float, angle: float) -> void:
		_inst.set("_abs_turns", turns)
		_inst.set("_accum_angle", angle)
		_inst.call("_apply_churn", 8.0)
		if is_instance_valid(spoon):
			spoon.visible = true
			spoon.position = center + Vector2(cos(angle - PI * 0.5), sin(angle - PI * 0.5)) * radius

	# f00 idle — 안 섞임 (not mixed yet).
	set_stir.call(0.0, 0.0)
	if is_instance_valid(lbl): lbl.text = "0.0 / 3 turns  ·  not mixed yet"
	await _snap()
	# f01 첫 1/4 바퀴.
	set_stir.call(0.4, TWO_PI * 0.4)
	if is_instance_valid(lbl): lbl.text = "0.4 / 3 turns  ·  not mixed yet"
	await _snap()
	# f02 약 1바퀴 — churn 시작.
	set_stir.call(1.0, TWO_PI * 1.0)
	if is_instance_valid(lbl): lbl.text = "1.0 / 3 turns  ·  mixing nicely"
	await _snap()
	# f03 2바퀴 — 재료 잘 섞임 + 양념색 spread.
	set_stir.call(2.0, TWO_PI * 2.0)
	_sparkle_at(center, 200.0)
	if is_instance_valid(lbl): lbl.text = "2.0 / 3 turns  ·  mixing nicely"
	await _snap()
	# f04 2.6바퀴 — 윤기 오름.
	set_stir.call(2.6, TWO_PI * 2.6)
	if is_instance_valid(lbl): lbl.text = "2.6 / 3 turns  ·  mixing nicely"
	await _snap()
	# f05 3바퀴 도달 — 균일하게 섞임.
	set_stir.call(3.0, TWO_PI * 3.0)
	_sparkle_at(center, 240.0)
	if is_instance_valid(lbl): lbl.text = "Evenly stirred!"
	await _snap()
	# f06 완료 settle (주걱 복귀).
	if is_instance_valid(spoon):
		spoon.position = center + Vector2(0, -radius)
	await _snap()


# =============================================================================
# ARRANGE — press-drag-release: 재료 집기 → magnet glow → snap settle (5색).
# =============================================================================
func _stage_arrange() -> void:
	var ings: Array = _inst.get("_ingredients")
	var slots: Array = _inst.get("_slots")
	var hint := _inst.get("_hint") as Label
	if ings == null or slots == null:
		await _snap(); return

	# f00 idle — 재료 트레이 + 빈 슬롯.
	if is_instance_valid(hint): hint.text = "Pick up an ingredient and drag it to its color"
	await _snap()

	# 정답 매칭을 색으로 찾아 순서대로 배치 (settle visual 직접 호출).
	# 첫 재료 = 손가락 따라 슬롯으로 drag (magnet glow) 연출.
	if ings.size() > 0 and slots.size() > 0:
		var ing0: Dictionary = ings[0]
		var node0: Control = ing0["node"]
		var cid0: int = int(ing0["color_id"])
		var target_slot: int = _slot_for_color(slots, cid0)
		var slot_center: Vector2 = slots[target_slot]["center"] if target_slot >= 0 else Vector2(540, 760)
		# f01 집어올림 (확대).
		if is_instance_valid(node0):
			node0.scale = Vector2(1.12, 1.12)
			node0.z_index = 30
		if is_instance_valid(hint): hint.text = "Dragging…"
		await _snap()
		# f02 슬롯 근처로 drag — magnet glow.
		if is_instance_valid(node0):
			node0.position = slot_center - node0.size * 0.5 + Vector2(0, 120)
		_inst.call("_update_magnet_glow", slot_center + Vector2(0, 120))
		await _snap()
		# f03 release → snap settle (정확 배치).
		if target_slot >= 0:
			_inst.call("_settle_into_slot", 0, target_slot)
		await _snap()

	# f04~ 나머지 재료 빠르게 채움 (남은 정답 배치).
	for i in range(1, ings.size()):
		var ing: Dictionary = ings[i]
		if bool(ing.get("placed", false)):
			continue
		var cid: int = int(ing["color_id"])
		var ts: int = _slot_for_color(slots, cid)
		if ts >= 0:
			_inst.call("_settle_into_slot", i, ts)
	await _snap()
	# f05 완성 — 오방색 균일.
	_sparkle_at(Vector2(540, 760), 320.0)
	if is_instance_valid(hint): hint.text = "All colors placed!"
	await _snap()


func _slot_for_color(slots: Array, color_id: int) -> int:
	for i in range(slots.size()):
		if not bool(slots[i].get("filled", false)) and int(slots[i]["color_id"]) == color_id:
			return i
	return -1


# =============================================================================
# ROLL — forward drag bamboo mat: 김밥 점진 말림 → 단단한 원통.
# =============================================================================
func _stage_roll() -> void:
	var hint := _inst.get("_hint") as Label
	# TWO-FINGER: 좌·우 진행을 균등 세팅하고 module의 _apply_roll_visual을 직접 호출.
	var set_roll := func(p: float) -> void:
		_inst.set("_left_progress", p)
		_inst.set("_right_progress", p)
		_inst.call("_apply_roll_visual")

	# f00 idle — 김 + 밥 + 재료 평평하게 펼쳐짐.
	set_roll.call(0.0)
	if is_instance_valid(hint): hint.text = "Use two fingers to push both sides evenly"
	await _snap()
	# f01 양손 밀기 시작 — 살짝 말림.
	set_roll.call(0.25)
	if is_instance_valid(hint): hint.text = "Roll evenly from both edges"
	await _snap()
	# f02 절반 말림 — 재료 빨려듦.
	set_roll.call(0.5)
	if is_instance_valid(hint): hint.text = "Perfect Balance!"
	await _snap()
	# f03 거의 다 말림.
	set_roll.call(0.72)
	if is_instance_valid(hint): hint.text = "Tight roll!"
	await _snap()
	# f04 sweet zone 진입 — round, balanced.
	set_roll.call(0.9)
	_sparkle_at(Vector2(540, 1000), 200.0)
	if is_instance_valid(hint): hint.text = "Perfect Balance!"
	await _snap()
	# f05 release → 단단한 원통 settle.
	set_roll.call(0.92)
	_sparkle_at(Vector2(540, 1000), 240.0)
	if is_instance_valid(hint): hint.text = "Tight roll!"
	await _snap()
	# f06 완성 settle.
	await _snap()


# =============================================================================
# FLIP — directional flick: 공중 arc 회전 → 반대면 착지.
# =============================================================================
func _stage_flip() -> void:
	var cake := _inst.get("_cake") as Control
	var lbl := _inst.get("_state_lbl") as Label
	var base: Vector2 = cake.position if is_instance_valid(cake) else Vector2(330, 900)

	# f00 idle — 음식 팬 위.
	if is_instance_valid(lbl): lbl.text = "Flick the food to flip it!"
	await _snap()
	# f01 flick 시작 — 음식 솟구침 (위로).
	if is_instance_valid(cake):
		cake.position = base + Vector2(0, -120)
		cake.rotation = 0.5
	if is_instance_valid(lbl): lbl.text = "Up it goes!"
	await _snap()
	# f02 공중 정점 — 회전 절반.
	if is_instance_valid(cake):
		cake.position = base + Vector2(0, -260)
		cake.rotation = PI
	_sparkle_at(base + Vector2(0, -260), 180.0)
	await _snap()
	# f03 내려오는 중 — 회전 3/4.
	if is_instance_valid(cake):
		cake.position = base + Vector2(0, -140)
		cake.rotation = PI * 1.5
	await _snap()
	# f04 착지 — 한 바퀴 완료, 반대면(구워진 뒷면).
	if is_instance_valid(cake):
		cake.position = base
		cake.rotation = TWO_PI
		if cake is TextureRect:
			(cake as TextureRect).flip_v = true
		cake.modulate = Color(0.82, 0.58, 0.32)
	_sparkle_at(base + Vector2(210, 140), 220.0)
	if is_instance_valid(lbl): lbl.text = "Perfect one-turn flip!"
	await _snap()
	# f05 착지 바운스 settle.
	if is_instance_valid(cake):
		cake.scale = Vector2(1.06, 0.94)
	await _snap()
	if is_instance_valid(cake):
		cake.scale = Vector2(1.0, 1.0)
	await _snap()
