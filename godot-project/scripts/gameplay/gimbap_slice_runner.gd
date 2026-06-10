## GimbapSliceRunner — Gimbap Vertical Slice (Pass A) orchestration runner skeleton.
##
## design: docs/design/gimbap-vertical-slice-v1.md. 김밥 1종(t1_004)으로 5-stage full loop를
## vertical slice 검증한다. **content volume 아님 — gameplay quality + cross-stage consequence.**
##
## 이 runner는 기존 CookingModuleRunner를 *상속*해 scoring/save/economy/result contract를 100%
## 보존하고, 그 앞뒤로 vertical-slice 전용 stage(Shopping / Julienne prep / Guest reaction)를
## 끼운다. 신규 system 최소 — quality-state는 transient runtime dict(save 무관).
##
## 5-stage chain (design §1):
##   STAGE 1 Shopping  → shopping_quality  (재료 25%)   [Pass A 구현 — shopping_stage.gd]
##   STAGE 2 Prep      → prep_quality      (준비 20%)   [Pass A 구현 — julienne_module.gd]
##   STAGE 3 Arrange+Roll → roll_quality   (방법 20%)   [Pass A = 기존 roll module 호출 stub]
##   STAGE 4 Slice+Plate → slice/plate     (시간 35% + display) [Pass A = 기존 module stub]
##   STAGE 5 Guest     → reaction bubble                [Pass A = stub, Pass B reaction 심화]
##
## shared quality-state dict (consequence chain backbone, design §8):
##   {shopping_quality, prep_quality, roll_quality, slice_quality, plate_quality} 각 [0,1].
##   Pass A는 각 stage가 자기 quality를 기록 + stage 간 통과(carry). Pass B가 이 변수를 소비해
##   consequence(prep→roll 난이도, roll→slice 난이도, plate→guest reaction)를 구현한다.
##
## 4-factor 매핑 scaffold (design §9.2, 신규 4-factor 축 0):
##   shopping→prep(ingredients 25%) / prep(julienne)→prep / roll→method / slice(통썰기)→timing /
##   plate→plating(display). 첫 Slice(prep julienne)와 둘째 Slice(통썰기 timing)를 step-aware로
##   구분(design §9.3 godot-dev flag) — STEP_PLAN의 factor_override가 처리.
extends "res://scripts/gameplay/cooking_module_runner.gd"

const ShoppingStage := preload("res://scripts/gameplay/shopping_stage.gd")
const JulienneScene := "res://scenes/cooking/julienne_module.tscn"

# vertical slice는 김밥(t1_004) 전용. runner 진입 시 강제.
const GIMBAP_ID := "t1_004"

# === shared quality-state (consequence chain backbone, design §8) ===
# 각 [0,1]. transient runtime — save 무관. Pass B가 carry된 값을 소비해 consequence 구현.
#   arrange_balance / arrange_bias_dir = §8.3 arrange→roll consequence (좌우 filling 균형).
var quality_state: Dictionary = {
	"shopping_quality": 0.0,
	"prep_quality": 0.0,
	"roll_quality": 0.0,
	"slice_quality": 0.0,
	"plate_quality": 0.0,
	"arrange_balance": 1.0,
	"arrange_bias_dir": 1.0,
}

# §8.1 consequence hook — Shopping에서 수집한 정답 재료 id. Pass B available filling.
var collected_fillings: Array = []

# vertical-slice step plan — 각 step: stage 종류 + 4-factor override(step-aware, design §9.3).
# kind: "shopping" | "julienne" | "module"(기존 module 호출) | "guest"
#   module step은 mod_id로 기존 MODULE_SCENES를 호출(roll/slice/plate stub).
#   factor: 이 step 결과가 들어갈 4-factor bucket(MODULE_TO_FACTOR override).
const STEP_PLAN := [
	{"kind": "shopping",  "factor": "prep",    "quality_key": "shopping_quality", "title": "Market"},
	{"kind": "julienne",  "factor": "prep",    "quality_key": "prep_quality",     "title": "Julienne"},
	{"kind": "module", "mod": "arrange", "factor": "prep",    "quality_key": "",               "title": "Arrange"},
	{"kind": "module", "mod": "roll",    "factor": "cook",    "quality_key": "roll_quality",   "title": "Roll"},
	{"kind": "module", "mod": "slice",   "factor": "timing",  "quality_key": "slice_quality",  "title": "Slice"},
	{"kind": "module", "mod": "plate",   "factor": "plating", "quality_key": "plate_quality",  "title": "Plating"},
	{"kind": "guest",     "factor": "",        "quality_key": "",               "title": "Serve"},
]

var _plan_idx: int = 0
var _vs_step: Dictionary = {}


# 기존 _load_round를 호출하되, 김밥 전용 plan으로 sequence를 재구성한다.
func _load_round() -> void:
	pending_menu_id = GIMBAP_ID   # vertical slice 강제 (김밥 1종)
	super._load_round()
	# 기존 _sequence(arrange|roll|slice|plate)는 STEP_PLAN이 대체한다. step_total = plan 길이
	# 중 player-facing stage 수(shopping/julienne/3 module/guest = 7, banner는 7로 표기).
	_plan_idx = 0
	_step_total = STEP_PLAN.size()


# 부모 _start_request 후 _run_next_module 대신 vertical-slice plan을 진행한다.
# (부모 _run_next_module을 override해 plan 기반 dispatch로 바꾼다.)
func _run_next_module() -> void:
	if _plan_idx >= STEP_PLAN.size():
		_finish()
		return
	_vs_step = STEP_PLAN[_plan_idx]
	_plan_idx += 1
	_step_no = _plan_idx
	_update_banner_step()
	var kind: String = String(_vs_step.get("kind", "module"))
	match kind:
		"shopping": _run_shopping_stage()
		"julienne": _run_julienne_stage()
		"guest":    _run_guest_stage()
		_:          _run_module_step()


# --- STAGE 1: Shopping ---
func _run_shopping_stage() -> void:
	var stage := ShoppingStage.new()
	_current_module = stage
	_module_host.add_child(stage)
	stage.stage_completed.connect(_on_shopping_done)
	stage.start(_build_module_params("shopping"))


func _on_shopping_done(quality: float, fillings: Array) -> void:
	quality_state["shopping_quality"] = clampf(quality, 0.0, 1.0)
	collected_fillings = fillings
	# 4-factor: shopping → 재료(prep bucket의 ingredients 대표). 0~1 → 0~100 contract 정합.
	_record_vs_factor(quality * 100.0)
	_advance_after_step()


# --- STAGE 2: Preparation (Julienne 채썰기) ---
func _run_julienne_stage() -> void:
	if not ResourceLoader.exists(JulienneScene):
		push_warning("[gimbap-vs] julienne scene missing — skipping prep")
		_advance_after_step()
		return
	var packed: PackedScene = load(JulienneScene) as PackedScene
	_current_module = packed.instantiate()
	_module_host.add_child(_current_module)
	if _current_module.has_signal("module_completed"):
		_current_module.module_completed.connect(_on_julienne_done)
	var params: Dictionary = _build_module_params("julienne")
	params["tap_count"] = 6   # 채썰기 = 반복 절단(rhythm/spacing 표본 확보).
	if _current_module.has_method("start"):
		_current_module.start(params)


func _on_julienne_done(score_pct: float) -> void:
	var q: float = clampf(score_pct / 100.0, 0.0, 1.0)
	# 모듈이 산출한 prep_quality(4축 가중평균)을 직접 읽어 quality-state에 기록 (consequence §8.2).
	if is_instance_valid(_current_module) and _current_module.has_method("get_prep_quality"):
		q = clampf(_current_module.get_prep_quality(), 0.0, 1.0)
	quality_state["prep_quality"] = q
	_record_vs_factor(q * 100.0)
	if is_instance_valid(_current_module):
		_current_module.queue_free()
	_current_module = null
	_advance_after_step()


# --- STAGE 3/4: 기존 module 호출 (arrange/roll/slice/plate stub) ---
# Pass A는 기존 module을 그대로 호출하고 결과 score만 quality-state에 carry(consequence hook 예약).
func _run_module_step() -> void:
	var mod_id: String = String(_vs_step.get("mod", ""))
	var scene_path: String = String(MODULE_SCENES.get(mod_id, ""))
	if scene_path == "" or not ResourceLoader.exists(scene_path):
		push_warning("[gimbap-vs] module '%s' missing — skipping" % mod_id)
		_advance_after_step()
		return
	var packed: PackedScene = load(scene_path) as PackedScene
	if packed == null:
		_advance_after_step()
		return
	_current_module = packed.instantiate()
	_module_host.add_child(_current_module)
	if _current_module.has_signal("module_completed"):
		_current_module.module_completed.connect(_on_vs_module_done.bind(mod_id))
	# Pass B consequence — quality-state 스냅샷을 module이 소비해 cross-stage 인과를 구현한다.
	#   roll  : vs_quality_state.prep_quality(§8.2) + arrange_balance(§8.3) 소비.
	#   slice : vs_quality_state.roll_quality(§8.4) 소비 → cut window 보정.
	#   plate : vs_quality_state.slice_quality(§8.5) 소비 → 조각 단면 visual.
	#   arrange: vs_collected_fillings(§8.1) 소비 → 누락 재료만큼 filling 슬롯 제한.
	var params: Dictionary = _build_module_params(mod_id)
	params["vs_quality_state"] = quality_state.duplicate()
	params["vs_collected_fillings"] = collected_fillings.duplicate()
	# §8.1 shopping→arrange: 수집한 정답 재료 수만큼만 filling 슬롯 생성(누락 재료 = 빈 김밥).
	if mod_id == "arrange":
		params["vs_available_slots"] = _available_filling_slots()
	if _current_module.has_method("start"):
		_current_module.start(params)


# §8.1 — shopping에서 모은 filling 재료(단무지/당근/계란/시금치) 수 → arrange filling 슬롯 수.
# 핵심 재료(seaweed/rice)는 wrapper라 filling 슬롯이 아니다. 최소 2(빈 김밥 방지) ~ 최대 5.
func _available_filling_slots() -> int:
	var filling_ids: Array = ["danmuji", "carrot", "egg", "spinach", "ham"]
	var have: int = 0
	for fid in filling_ids:
		if collected_fillings.has(fid):
			have += 1
	# collected가 비어(테스트/타임아웃) 있으면 기본 5(기존 동작 보존).
	if collected_fillings.is_empty():
		return 5
	return clampi(have, 2, 5)


func _on_vs_module_done(score_pct: float, mod_id: String) -> void:
	# plate choice 캡처(기존 부모 로직과 동일 — dish bonus + reveal).
	if mod_id == "plate" and _current_module is PlateModuleScript:
		var pm: Node = _current_module
		if pm.has_method("get_chosen_dish"):
			_dish_choice = String(pm.get_chosen_dish())
		if pm.has_method("get_chosen_tier"):
			_dish_tier = String(pm.get_chosen_tier())
	# §8.3 arrange→roll: arrange가 산출한 좌우 balance/bias를 quality-state에 기록 → 다음 roll
	#   step의 vs_quality_state 스냅샷에 포함되어 roll tilt offset으로 소비된다.
	if mod_id == "arrange" and is_instance_valid(_current_module):
		if _current_module.has_method("get_arrange_balance"):
			quality_state["arrange_balance"] = clampf(_current_module.get_arrange_balance(), 0.0, 1.0)
		if _current_module.has_method("get_arrange_bias_dir"):
			quality_state["arrange_bias_dir"] = float(_current_module.get_arrange_bias_dir())
	var q: float = clampf(score_pct / 100.0, 0.0, 1.0)
	var qkey: String = String(_vs_step.get("quality_key", ""))
	if qkey != "":
		quality_state[qkey] = q
	_record_vs_factor(score_pct)
	if is_instance_valid(_current_module):
		_current_module.queue_free()
	_current_module = null
	_advance_after_step()


# --- STAGE 5: Guest reaction (Pass B — guest avatar + 5-quality reaction bubble, design §7) ---
func _run_guest_stage() -> void:
	# guest avatar(neutral) + 5 quality 종합을 가리키는 짧은 reaction bubble. design §7.1.
	var line: String = _pick_reaction_line()
	print("[gimbap-vs] guest reaction qs=%s -> \"%s\"" % [str(quality_state), line])
	var avatar := _build_guest_avatar()
	if avatar != null:
		_module_host.add_child(avatar)
	var bubble := _build_reaction_bubble(line)
	_module_host.add_child(bubble)
	await get_tree().create_timer(1.6).timeout
	if is_instance_valid(bubble):
		bubble.queue_free()
	if avatar != null and is_instance_valid(avatar):
		avatar.queue_free()
	_finish()


# guest neutral sprite(있으면) 또는 색 원 + 이니셜 — reaction bubble 옆 손님 얼굴.
func _build_guest_avatar() -> Control:
	if _guest.is_empty():
		return null
	var gid := String(_guest.get("id", ""))
	var holder := Control.new()
	holder.position = Vector2(120, 420)
	holder.size = Vector2(320, 320)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ring := Panel.new()
	ring.set_anchors_preset(Control.PRESET_FULL_RECT)
	var rsb := StyleBoxFlat.new()
	rsb.bg_color = Color(0.99, 0.96, 0.89)
	rsb.set_corner_radius_all(160)
	rsb.set_border_width_all(6)
	rsb.border_color = Color(0.93, 0.72, 0.30)
	rsb.shadow_size = 12
	rsb.shadow_color = Color(0, 0, 0, 0.32)
	ring.add_theme_stylebox_override("panel", rsb)
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.clip_contents = true
	holder.add_child(ring)
	var avatar_path := "res://art/sprites/character/%s_neutral.png" % gid
	if ResourceLoader.exists(avatar_path):
		var av := TextureRect.new()
		av.texture = load(avatar_path)
		av.set_anchors_preset(Control.PRESET_FULL_RECT)
		av.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		av.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		av.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ring.add_child(av)
	else:
		var initial := Label.new()
		initial.text = String(_guest.get("name", "?")).substr(0, 1)
		initial.set_anchors_preset(Control.PRESET_FULL_RECT)
		initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		initial.add_theme_font_size_override("font_size", 120)
		initial.add_theme_color_override("font_color", Color(0.55, 0.40, 0.24))
		initial.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ring.add_child(initial)
	return holder


# design §7.1 / §8.6: bubble이 5 quality 종합 중 가장 약/강 stage를 직접 가리킨다(행동 반영).
# Pass B: 5 quality 전부를 보고, 먼저 가장 두드러진 약점(낮은 quality)을 지목하고, 약점이 없으면
# 가장 강한 stage를 칭찬한다 → "내가 한 행동(어느 stage)이 반응에 반영됐다" 체감.
func _pick_reaction_line() -> String:
	var prep_q: float = float(quality_state.get("prep_quality", 0.0))
	var roll_q: float = float(quality_state.get("roll_quality", 0.0))
	var slice_q: float = float(quality_state.get("slice_quality", 0.0))
	var plate_q: float = float(quality_state.get("plate_quality", 0.0))
	# 1) 가장 두드러진 약점 먼저 지목(design §7.1 표 — 낮은 quality가 행동 피드백).
	var weak_thresh: float = 0.45
	# 가장 낮은 약점 stage를 찾는다(여러 약점 중 최저 우선).
	var weakest_key: String = ""
	var weakest_val: float = weak_thresh
	for entry in [["roll", roll_q], ["slice", slice_q], ["plate", plate_q], ["prep", prep_q]]:
		var v: float = float(entry[1])
		if v < weakest_val:
			weakest_val = v
			weakest_key = String(entry[0])
	match weakest_key:
		"roll":  return "The filling is falling out a bit."
		"slice": return "Some pieces are thicker than others."
		"plate": return "It looks a little messy."
		"prep":  return "The strips are a bit chunky."
	# 2) 약점이 없으면 가장 강한 stage를 칭찬(design §7.1 — 높은 quality 행동 피드백).
	if roll_q >= 0.75 and roll_q >= plate_q:
		return "Wow, the roll is so clean!"
	if plate_q >= 0.75:
		return "This looks like a real lunchbox!"
	return "Mmm, looks tasty!"


func _build_reaction_bubble(text: String) -> Control:
	var holder := Control.new()
	holder.set_anchors_preset(Control.PRESET_FULL_RECT)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bubble := Panel.new()
	bubble.position = Vector2(160, 760)
	bubble.size = Vector2(760, 200)
	var bsb := StyleBoxFlat.new()
	bsb.bg_color = Color(1.0, 0.99, 0.93, 0.97)
	bsb.set_corner_radius_all(40)
	bsb.set_border_width_all(4)
	bsb.border_color = Color(0.93, 0.72, 0.30)
	bsb.shadow_size = 12
	bsb.shadow_color = Color(0, 0, 0, 0.30)
	bubble.add_theme_stylebox_override("panel", bsb)
	bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(bubble)
	var lbl := Label.new()
	lbl.text = "\"%s\"" % text
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 38)
	lbl.add_theme_color_override("font_color", Color(0.30, 0.18, 0.08))
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bubble.add_child(lbl)
	return holder


# --- shared step machinery ---

## 현재 vs_step의 4-factor bucket에 점수(0~100)를 기록 (step-aware override, design §9.3).
## 부모 _factor_acc 구조(0~1 배열)를 그대로 재사용 — 신규 scoring system 0.
func _record_vs_factor(score_pct: float) -> void:
	var factor: String = String(_vs_step.get("factor", ""))
	if factor == "":
		return
	if not _factor_acc.has(factor):
		_factor_acc[factor] = []
	(_factor_acc[factor] as Array).append(clampf(score_pct / 100.0, 0.0, 1.0))


func _advance_after_step() -> void:
	await get_tree().create_timer(0.25).timeout
	_run_next_module()


# --- read-only getters (shot / test 검증용) ---

func get_quality_state() -> Dictionary:
	return quality_state.duplicate()


func get_collected_fillings() -> Array:
	return collected_fillings.duplicate()
