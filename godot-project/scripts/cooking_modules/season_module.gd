## SeasonModule — ACTION-FIRST tilt-bottle seasoning (ADR-012).
##
## "I added seasoning" — NOT "I pressed ADD". The player drags a seasoning bottle to tilt
## it over the food; particles fall and the food surface changes color/sheen. Tilt angle +
## hold time = amount.
##
## ADR-012 input redesign (2026-06-05): 1-tap ADD button 폐기 → tilt + hold.
##   Mode A (default, 11 dishes): 가벼운 tilt = 적정 양 자동 (ADR-007 정합, 시각 ambience).
##     양념별 입자(고춧가루 톡톡 / 간장 줄기 / 참기름 drizzle). score = 90 (auto-pour 대체,
##     balance 무변경 — 기존 _on_simple_add 90.0 그대로).
##   Mode B (marinade, 불고기 t2_014): tilt-and-massage 연속 동작 N회 (60 BPM 마사지를 tilt
##     drag로 표현). score = 평균 rhythm accuracy (기존 marinade 계산 무변경).
##
## SCORING 무변경 (§6.1 / §3.6): default=1.0(×90), marinade=tap 평균. 출력 score 도메인
## [0,100] 동일, `module_completed(score)` contract 동일.
extends "res://scripts/cooking_modules/base_module.gd"

const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")
const TouchGesture := preload("res://scripts/cooking_modules/touch_gesture.gd")

const MARINADE_BPM: float = 60.0
const MARINADE_TAPS: int = 3
const LEAD_IN_MS: float = 900.0

# 양념 종류 → 입자 색 + 낙하 스타일 (§5.2).
const SEASONING_STYLES := {
	"gochugaru":  {"col": Color(0.82, 0.18, 0.12), "style": "powder",  "label": "Chili flakes"},
	"soy":        {"col": Color(0.30, 0.18, 0.08), "style": "stream",  "label": "Soy sauce"},
	"sesame_oil": {"col": Color(0.92, 0.78, 0.28), "style": "drizzle", "label": "Sesame oil"},
	"gochujang":  {"col": Color(0.78, 0.20, 0.15), "style": "powder",  "label": "Gochujang"},
}

var _mode: String = "simple"
var _taps: Array = []
var _start_ms: float = 0.0

# bottle (procedural — 양념병 LOCK art 미발급, §11 fallback).
var _bottle: Node2D = null
var _bottle_home: Vector2 = Vector2.ZERO
var _food_hero: TextureRect = null
var _gesture = null   # TouchGestureRecognizer (preloaded TouchGesture)
var _style: Dictionary = SEASONING_STYLES["gochujang"]
var _particles_holder: Control = null

# simple-mode pour 누적 상태.
var _poured: float = 0.0             # tilt-hold로 부은 양 [0,1]
var _pouring: bool = false
var _hint: Label = null

# marinade-mode 진행.
var _massaging: bool = false
var _last_massage_idx: int = -1


func _module_start(params: Dictionary) -> void:
	_attach_cooking_bg(1000.0)
	_mode = String(params.get("mode", "simple"))
	# 양념 종류 (음식별 hint — 없으면 기본 고추장).
	var seas: String = String(params.get("seasoning", ""))
	if seas != "" and SEASONING_STYLES.has(seas):
		_style = SEASONING_STYLES[seas]
	_particles_holder = Control.new()
	_particles_holder.set_anchors_preset(Control.PRESET_FULL_RECT)
	_particles_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _mode == "marinade":
		_start_marinade(params)
	else:
		_start_simple()
	add_child(_particles_holder)

	# 입력 인식기 — 병 tilt drag.
	_gesture = TouchGesture.new()
	_gesture.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_gesture)
	_gesture.drag_started.connect(_on_drag_started)
	_gesture.drag_updated.connect(_on_drag_updated)
	_gesture.tilt_changed.connect(_on_tilt_changed)
	_gesture.drag_released.connect(_on_drag_released)


# --- simple mode (tilt + hold) ---

func _start_simple() -> void:
	_build_header("Season", "Tilt the bottle over the food until it's just right.")

	# 음식 hero (양념 받을 대상).
	var food_id_s: StringName = StringName(String(_params.get("food_id", "")))
	var food_img: String = ArtRegistry.food(food_id_s)
	if ArtRegistry.file_exists(food_img):
		_food_hero = TextureRect.new()
		_food_hero.texture = load(food_img)
		_food_hero.position = Vector2(300, 980)
		_food_hero.size = Vector2(480, 480)
		_food_hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_food_hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_food_hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_food_hero.pivot_offset = Vector2(240, 240)
		add_child(_food_hero)
		_attach_dish_shadow(Vector2(540, 1440), 420.0)

	# 양념병 (procedural) — 위쪽, drag로 기울여 음식 위에서 뿌림.
	_bottle = _build_bottle()
	_bottle_home = Vector2(540, 760)
	_bottle.position = _bottle_home
	add_child(_bottle)

	_hint = Label.new()
	_hint.position = Vector2(40, 1560)
	_hint.size = Vector2(1000, 70)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 40)
	_hint.add_theme_color_override("font_color", Color(0.45, 0.32, 0.18))
	_hint.text = "%s — tilt to pour" % _style["label"]
	add_child(_hint)


func _build_bottle() -> Node2D:
	var bottle := Node2D.new()
	bottle.z_index = 40
	# Node2D는 origin(0,0) 기준 회전 — pivot_offset 불필요 (Control 전용 속성).
	# body
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-70, -10), Vector2(70, -10), Vector2(70, 200),
		Vector2(40, 260), Vector2(-40, 260), Vector2(-70, 200),
	])
	body.color = Color(0.86, 0.30, 0.20, 0.92)
	bottle.add_child(body)
	# neck
	var neck := Polygon2D.new()
	neck.polygon = PackedVector2Array([
		Vector2(-30, -70), Vector2(30, -70), Vector2(30, -10), Vector2(-30, -10),
	])
	neck.color = Color(0.78, 0.24, 0.16, 0.92)
	bottle.add_child(neck)
	# cap
	var cap := Polygon2D.new()
	cap.polygon = PackedVector2Array([
		Vector2(-36, -110), Vector2(36, -110), Vector2(36, -70), Vector2(-36, -70),
	])
	cap.color = Color(0.30, 0.20, 0.12)
	bottle.add_child(cap)
	# label patch
	var lbl := Polygon2D.new()
	lbl.polygon = PackedVector2Array([
		Vector2(-50, 40), Vector2(50, 40), Vector2(50, 160), Vector2(-50, 160),
	])
	lbl.color = Color(0.98, 0.94, 0.86, 0.9)
	bottle.add_child(lbl)
	return bottle


# --- gesture: tilt + hold pour (simple) / tilt-massage (marinade) ---

func _on_drag_started(pos: Vector2) -> void:
	if _finished:
		return
	if _mode == "marinade":
		_massaging = true
		return
	# 병 근처를 잡으면 pour 시작.
	_pouring = is_instance_valid(_bottle) and pos.distance_to(_bottle.position) < 360.0


func _on_drag_updated(pos: Vector2, _vel: Vector2) -> void:
	if _finished:
		return
	if _mode == "marinade":
		_massage_at(pos)
		return
	if _pouring and is_instance_valid(_bottle):
		# 병이 손가락 X를 따라감 (음식 위에서 좌우 이동하며 뿌림).
		_bottle.position.x = clampf(pos.x, 300.0, 780.0)


func _on_tilt_changed(angle_deg: float, _hold_ms: float) -> void:
	if _finished:
		return
	if _mode == "marinade":
		return
	if not _pouring or not is_instance_valid(_bottle):
		return
	# 병 기울임 = drag 각도. 더 기울일수록(아래로 향할수록) 더 많이 쏟아짐.
	_bottle.rotation = deg_to_rad(clampf(angle_deg, 0.0, 75.0))
	if angle_deg > 18.0:
		# 입자 낙하 + 양 누적.
		_emit_particles(_bottle.position + Vector2(0, 220), 2)
		_poured = clampf(_poured + 0.018, 0.0, 1.3)
		_apply_food_tint()
		_update_simple_hint()


func _on_drag_released(_info: Dictionary) -> void:
	if _finished:
		return
	if _mode == "marinade":
		_massaging = false
		return
	_pouring = false
	if is_instance_valid(_bottle):
		# 병 똑바로 복귀.
		var tw := _bottle.create_tween()
		tw.tween_property(_bottle, "rotation", 0.0, 0.2)
	# 충분히 부었으면 완료. (ADR-007: default는 가벼운 tilt면 적정 — 관대한 임계)
	if _poured >= 0.45:
		_finalize_simple()


func _apply_food_tint() -> void:
	if not is_instance_valid(_food_hero):
		return
	# 부은 양에 따라 음식 표면이 양념색 쪽으로 + 윤기(살짝 밝게).
	var amt: float = clampf(_poured, 0.0, 1.0)
	var tint: Color = Color(1, 1, 1).lerp(_style["col"].lightened(0.35), amt * 0.5)
	_food_hero.modulate = Color(tint.r, tint.g, tint.b, 1.0)


func _update_simple_hint() -> void:
	if not is_instance_valid(_hint):
		return
	if _poured < 0.45:
		_hint.text = "%s — keep tilting…" % _style["label"]
	elif _poured <= 1.05:
		_hint.text = "Balanced! release"
	else:
		_hint.text = "That's plenty — release"


func _finalize_simple() -> void:
	if is_instance_valid(_hint):
		_hint.text = "Seasoned!"
	_safe_feedback(RhythmJudge.GOOD, Vector2(540, 1200))
	# §6.1 default: accuracy_season = 1.0 → 기존 auto-pour 90.0 그대로 (balance 무변경).
	_finish(90.0)


# --- marinade mode (tilt-and-massage 연속) ---
func _start_marinade(params: Dictionary) -> void:
	_build_header("Marinade", "Tilt and massage the sauce into the meat on every beat.")
	var taps: int = int(params.get("marinade_taps", MARINADE_TAPS))
	var bpm: float = float(params.get("marinade_bpm", MARINADE_BPM))
	var spacing := 60000.0 / maxf(bpm, 1.0)
	_start_ms = _now_ms() + LEAD_IN_MS
	for i in range(taps):
		_taps.append({"target_ms": _start_ms + float(i) * spacing, "judged": false, "score": 0.0})

	# marinade 보울 LOCK art.
	var food_id: StringName = StringName(String(params.get("food_id", "")))
	var bowl_path: String = ArtRegistry.TOOL_MARINATE
	if ArtRegistry.file_exists(bowl_path):
		var bowl_tex := TextureRect.new()
		bowl_tex.texture = load(bowl_path)
		bowl_tex.position = Vector2(240, 900)
		bowl_tex.size = Vector2(600, 420)
		bowl_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bowl_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		bowl_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(bowl_tex)
	else:
		var bowl := Panel.new()
		bowl.position = Vector2(290, 940)
		bowl.size = Vector2(500, 320)
		var bsb := StyleBoxFlat.new()
		bsb.bg_color = Color(0.30, 0.20, 0.12)
		bsb.set_corner_radius_all(160)
		bowl.add_theme_stylebox_override("panel", bsb)
		bowl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(bowl)

	# hero ingredient (얇은 소고기) — 보울 위.
	var ing_path: String = ArtRegistry.prep_whole(food_id)
	if ArtRegistry.file_exists(ing_path):
		_food_hero = TextureRect.new()
		_food_hero.texture = load(ing_path)
		_food_hero.position = Vector2(360, 980)
		_food_hero.size = Vector2(360, 260)
		_food_hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_food_hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_food_hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_food_hero)

	_attach_dish_shadow(Vector2(540, 1320), 480.0)

	_hint = Label.new()
	_hint.position = Vector2(40, 1560)
	_hint.size = Vector2(1000, 70)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 38)
	_hint.add_theme_color_override("font_color", Color(0.45, 0.32, 0.18))
	_hint.text = "Massage on the beat…"
	add_child(_hint)


## tilt-massage 동작 = drag로 보울 위를 문지름. 비트 근처에서 문지르면 그 tap을 판정.
func _massage_at(pos: Vector2) -> void:
	if _finished:
		return
	if pos.y < 900.0 or pos.y > 1320.0:
		return
	var now := _now_ms()
	# 가장 가까운 미판정 tap을 마사지로 판정.
	var best: int = -1
	var best_d: float = 1e9
	for i in range(_taps.size()):
		if _taps[i]["judged"]:
			continue
		var d: float = absf(now - float(_taps[i]["target_ms"]))
		if d < best_d:
			best_d = d
			best = i
	if best < 0 or best == _last_massage_idx:
		return
	# 마사지 한 번 = 그 tap 후보의 timing 판정 (단, 너무 이르면 무시 — 비트 -good 이전).
	var good: float = float(_level_get("good_ms", 200.0))
	if now < float(_taps[best]["target_ms"]) - good * 1.5:
		return
	_last_massage_idx = best
	var perfect: float = float(_level_get("perfect_ms", 90.0))
	var j := RhythmJudge.judge(best_d, perfect, good)
	var score: float = 100.0 if j == RhythmJudge.PERFECT else (60.0 if j == RhythmJudge.GOOD else 0.0)
	_taps[best]["judged"] = true
	_taps[best]["score"] = score
	_safe_feedback(j, pos)
	_emit_particles(pos, 3)
	# 양념 코팅 진해짐.
	if is_instance_valid(_food_hero):
		var done: int = _judged_count()
		var amt: float = float(done) / float(maxi(1, _taps.size()))
		_food_hero.modulate = Color(1, 1, 1).lerp(_style["col"].lightened(0.25), amt * 0.6)


func _process(_dt: float) -> void:
	if _mode != "marinade" or _finished:
		return
	var now := _now_ms()
	var good: float = float(_level_get("good_ms", 200.0))
	for t in _taps:
		if not t["judged"] and now - float(t["target_ms"]) > good:
			t["judged"] = true
			t["score"] = 0.0
			_safe_feedback(RhythmJudge.MISS, Vector2(540, 1100))
	if _all_judged():
		# §6.1 marinade: tap 평균 (기존 계산 무변경).
		var total: float = 0.0
		for t in _taps:
			total += float(t["score"])
		if is_instance_valid(_hint):
			_hint.text = "Marinated!"
		_finish(total / float(maxi(1, _taps.size())))


func _all_judged() -> bool:
	for t in _taps:
		if not t["judged"]:
			return false
	return _taps.size() > 0


func _judged_count() -> int:
	var c: int = 0
	for t in _taps:
		if t["judged"]:
			c += 1
	return c


# --- particles (입자 낙하) ---

## 양념 입자 낙하 — 양념 style에 따라 가루(점)/줄기(긴 사각)/drizzle.
func _emit_particles(at: Vector2, n: int) -> void:
	if not is_instance_valid(_particles_holder):
		return
	var style: String = String(_style["style"])
	for i in range(n):
		var p := ColorRect.new()
		p.color = _style["col"]
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		match style:
			"stream":
				p.size = Vector2(8, 34)
			"drizzle":
				p.size = Vector2(14, 14)
				p.color = _style["col"].lightened(0.2)
			_:  # powder
				p.size = Vector2(10, 10)
		var sx: float = at.x + randf_range(-60.0, 60.0)
		p.position = Vector2(sx, at.y)
		_particles_holder.add_child(p)
		var fall_y: float = at.y + randf_range(160.0, 280.0)
		var tw := p.create_tween()
		tw.parallel().tween_property(p, "position:y", fall_y, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.parallel().tween_property(p, "modulate:a", 0.0, 0.45).set_delay(0.15)
		tw.tween_callback(p.queue_free)


func _now_ms() -> float:
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("now_ms"):
		return float(bc.now_ms())
	return float(Time.get_ticks_msec())
