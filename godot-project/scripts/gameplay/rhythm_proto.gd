## RhythmRound — data-driven round with phase variations + level scaling (M1+).
##
## Flow: guest request -> [phase sequence from menu.phases] -> plating -> reveal -> result.
## Phases: chop / boil / season / stirfry / panfry / roll / knead (data-defined per menu).
## Difficulty (windows, tol, weights, stars, reward) comes from Level data (= menu unlock_level).
## Evaluators (Mystery Diner L3 / Daniel Kim L5 / Golden Spoon L8) replace the guest on those levels.
## Every beat routes through FeedbackBus.hit -> popup + flash + sfx + haptic (5-stimulus juice).
## English-first UI; Korean kept as cultural subtitle. Ref: docs/phase1/phase-variations-v1.md, levels-v1.md
extends Node2D

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const MarketBG := preload("res://scripts/ui/market_bg.gd")

## Set by menu_select before scene change.
static var pending_menu_id: String = "t1_002"
## Set by guest_select (empty = use menu default / evaluator).
static var pending_guest_id: String = ""

@export var tap_count: int = 4
@export var tap_spacing_ms: float = 650.0
@export var lead_in_ms: float = 1100.0

const JUDGE_Y := 1180.0
const SPAWN_Y := 250.0
const NOTE_R := 64.0
const STIR_Y := 980.0

const PHASE_NAMES := {
	"chop": "Chop", "boil": "Boil", "season": "Season",
	"stirfry": "Stir-fry", "panfry": "Pan-fry", "roll": "Roll", "knead": "Mix",
}
const PHASE_CAT := {
	"chop": "prep", "roll": "prep", "knead": "prep",
	"boil": "cook", "stirfry": "cook", "panfry": "cook",
	"season": "season",
}

# --- loaded per-round data ---
var _menu: Dictionary = {}
var _guest: Dictionary = {}
var _level: Dictionary = {}
var _is_evaluator: bool = false
var _slots: Array = []
var _dish_options: Array = []

var _layer: CanvasLayer
var _info: Label
var _howto: Label              # one-line "how to play this phase" under the title
var _phase: String = "init"
var _stage_nodes: Array = []

# intuitive affordances (created per phase)
var _stir_pads: Dictionary = {}   # "left"/"right" -> Button
var _pan_pad: Button = null
var _knead_pad: Button = null
var _knead_ring: Label = null
var _target_ring: Node2D = null   # chop: glowing "tap here" ring
var _now_cooking: Control = null  # persistent "what am I making" banner
# boiling pot (boil minigame: food IS the gauge)
var _boil_root: Node2D = null
var _boil_broth: Polygon2D = null
var _boil_ring: Line2D = null
var _boil_acc: float = 0.0

# phase queue / scoring buckets
var _phase_queue: Array = []
var _step_no: int = 0
var _step_total: int = 0
var _cat_acc: Dictionary = {"prep": [], "cook": [], "season": []}

# beat phases (chop, stirfry)
var _notes: Array = []
var _beat_kind: String = "chop"
var _beat_cat: String = "prep"
var _beat_sum: float = 0.0

# hold phases (boil, roll)
var _hold_kind: String = "boil"
var _hold_cat: String = "cook"
var _hold_target_ms: float = 1200.0
var _hold_tol: float = 0.35
var _hold_fill: ColorRect
var _hold_horizontal: bool = false
var _hold_pressing: bool = false
var _hold_start_ms: float = 0.0

# season
var _gauge: SeasoningGauge
var _season_counts: Array = []
var _season_end_ms: float = 0.0
var _count_label: Label = null

# panfry
var _pan_start_ms: float = 0.0
var _pan_dur_ms: float = 4500.0
var _pan_flips: Array = []      # [{at, open, done, score}]
var _pan_cake: Polygon2D = null

# knead
var _knead_end_ms: float = 0.0
var _knead_taps: int = 0
var _knead_target: int = 12
var _knead_bowl: Node2D = null

var _dish_choice: String = ""


func _ready() -> void:
	randomize()
	_menu = MenuDB.get_menu(pending_menu_id)
	if _menu.is_empty():
		_menu = MenuDB.get_menu("t1_002")
	var lv: int = int(_menu.get("unlock_level", 1))
	_level = MenuDB.get_level(lv)
	# evaluator on L3/L5/L8 replaces the guest (Phase 1 simplification)
	var eval_id: String = String(_level.get("evaluator", ""))
	if eval_id != "":
		_guest = MenuDB.get_guest(eval_id)
		_is_evaluator = true
	elif pending_guest_id != "":
		_guest = MenuDB.get_guest(pending_guest_id)
		pending_guest_id = ""  # consume the selection
	else:
		_guest = MenuDB.get_guest(String(_menu.get("guest_id", "junho")))
	# consume one serving of this menu's stock (economy)
	var sm0 := get_node_or_null("/root/SaveManager")
	if sm0 and sm0.has_method("consume_stock"):
		sm0.consume_stock(String(_menu.get("id", "")))
	_slots = _menu.get("seasonings", [])
	_dish_options = [String(_menu.get("dish_best", "")), String(_menu.get("dish_2nd", "")), String(_menu.get("dish_bad", ""))]
	_dish_options.shuffle()

	_layer = CanvasLayer.new()
	add_child(_layer)
	var bg := MarketBG.new()
	bg.light = true  # bright themed backdrop; keeps gameplay + dark text readable
	_layer.add_child(bg)
	_info = Label.new()
	_info.position = Vector2(40, 60)
	_info.size = Vector2(1000, 260)
	_info.add_theme_font_size_override("font_size", 40)
	_info.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_layer.add_child(_info)
	_howto = Label.new()
	_howto.position = Vector2(40, 132)
	_howto.size = Vector2(1000, 60)
	_howto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_howto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_howto.add_theme_font_size_override("font_size", 32)
	_howto.add_theme_color_override("font_color", Color(0.45, 0.32, 0.18))
	_layer.add_child(_howto)
	_level_banner()
	_now_cooking = _build_now_cooking()
	_layer.add_child(_now_cooking)
	if not _menu.get("ready", true):
		_coming_soon_toast()
	get_node("/root/BeatClock").start()
	_start_request()


# Persistent "what am I making" banner — so the dish is ALWAYS visible.
func _build_now_cooking() -> Control:
	var pill := Panel.new()
	pill.position = Vector2(200, 196)
	pill.size = Vector2(680, 56)
	pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.30, 0.20, 0.12, 0.92)
	sb.set_corner_radius_all(28)
	pill.add_theme_stylebox_override("panel", sb)
	# small food thumbnail
	if bool(_menu.get("ready", false)):
		var tex: Texture2D = load(String(_menu.get("food_img", "")))
		if tex != null:
			var t := TextureRect.new()
			t.texture = tex
			t.position = Vector2(6, 2)
			t.size = Vector2(52, 52)
			t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			t.mouse_filter = Control.MOUSE_FILTER_IGNORE
			pill.add_child(t)
	var l := Label.new()
	l.text = "Cooking · %s (%s)" % [_menu.get("name_en", "?"), _menu.get("name_kr", "")]
	l.position = Vector2(66, 0)
	l.size = Vector2(600, 56)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 30)
	l.add_theme_color_override("font_color", Color(0.99, 0.92, 0.78))
	pill.add_child(l)
	return pill


func _track(n: Node) -> Node:
	_stage_nodes.append(n)
	return n


func _clear_stage() -> void:
	for n in _stage_nodes:
		if is_instance_valid(n):
			n.queue_free()
	_stage_nodes.clear()


func _menu_name() -> String:
	return String(_menu.get("name_en", "this dish"))


func _avg(arr: Array) -> float:
	if arr.is_empty():
		return 0.0
	var s: float = 0.0
	for v in arr:
		s += float(v)
	return s / float(arr.size())


func _level_banner() -> void:
	var txt := "Lv %d" % int(_level.get("level", 1))
	if _is_evaluator:
		txt += " · %s" % _guest.get("name", "Evaluator")
	var pill := Panel.new()
	pill.position = Vector2(24, 8)
	pill.size = Vector2(clampf(150.0 + float(txt.length()) * 16.0, 150.0, 520.0), 50.0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.30, 0.20, 0.12, 0.92)
	sb.set_corner_radius_all(25)
	pill.add_theme_stylebox_override("panel", sb)
	_layer.add_child(pill)
	var b := Label.new()
	b.text = txt
	b.set_anchors_preset(Control.PRESET_FULL_RECT)
	b.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	b.add_theme_font_size_override("font_size", 28)
	b.add_theme_color_override("font_color", Color(0.99, 0.92, 0.78))
	pill.add_child(b)


func _coming_soon_toast() -> void:
	var t := Label.new()
	t.text = "Final art coming soon"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.position = Vector2(0, 1860)
	t.size = Vector2(1080, 50)
	t.add_theme_font_size_override("font_size", 30)
	t.add_theme_color_override("font_color", Color(0.6, 0.5, 0.4))
	_layer.add_child(t)


func _windows() -> Array:
	var t := get_node("/root/Tuning")
	return [float(_level.get("perfect_ms", 90.0)) * t.perfect_window_scale,
			float(_level.get("good_ms", 200.0)) * t.good_window_scale]


# --- 0. guest request ---
func _start_request() -> void:
	_phase = "request"
	var face := Panel.new()
	face.position = Vector2(440, 360)
	face.size = Vector2(200, 200)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.86, 0.78, 0.95) if _is_evaluator else Color(0.95, 0.83, 0.62)
	sb.set_corner_radius_all(100)
	face.add_theme_stylebox_override("panel", sb)
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_track(face))
	_info.position = Vector2(40, 620)
	_info.text = "%s: \"%s\"\n\nLet's make %s (%s)." % [
		_guest.get("name", "Guest"), _guest.get("line_enter", "Surprise me!"),
		_menu_name(), _menu.get("intro_en", "")]
	await get_tree().create_timer(2.0).timeout
	_clear_stage()
	_info.position = Vector2(40, 60)
	_begin_phases()


# --- phase queue ---
func _begin_phases() -> void:
	_phase_queue = (_menu.get("phases", ["chop", "boil", "season"]) as Array).duplicate()
	_step_total = _phase_queue.size()
	_step_no = 0
	_cat_acc = {"prep": [], "cook": [], "season": []}
	_next_phase()


func _next_phase() -> void:
	if _phase_queue.is_empty():
		_start_plating()
		return
	_step_no += 1
	var p: String = String(_phase_queue.pop_front())
	match p:
		"chop": _start_beat("chop")
		"stirfry": _start_beat("stirfry")
		"boil": _start_hold("boil")
		"roll": _start_hold("roll")
		"season": _start_season()
		"panfry": _start_panfry()
		"knead": _start_knead()
		_: _next_phase()  # unknown token -> skip


func _record(cat: String, acc: float) -> void:
	if not _cat_acc.has(cat):
		_cat_acc[cat] = []
	_cat_acc[cat].append(clampf(acc, 0.0, 1.0))


func _step_label(extra: String) -> String:
	return "Step %d/%d · %s" % [_step_no, _step_total, extra]


# Big centered phase title + one-line how-to, so every minigame explains itself.
func _phase_header(title: String, howto: String) -> void:
	_info.position = Vector2(40, 56)
	_info.size = Vector2(1000, 70)
	_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_info.text = "Step %d/%d  ·  %s" % [_step_no, _step_total, title]
	if is_instance_valid(_howto):
		_howto.text = howto


func _clear_howto() -> void:
	if is_instance_valid(_howto):
		_howto.text = ""


# Glowing pulsing "tap here" ring (chop target at the judge line).
func _make_target_ring(pos: Vector2) -> Node2D:
	var root := Node2D.new()
	root.position = pos
	var ring := Line2D.new()
	ring.width = 8.0
	ring.default_color = Color(0.98, 0.78, 0.22, 0.95)
	ring.closed = true
	var pts := PackedVector2Array()
	for i in range(40):
		var a: float = TAU * float(i) / 40.0
		pts.append(Vector2(cos(a), sin(a)) * (NOTE_R + 22.0))
	ring.points = pts
	root.add_child(ring)
	var tw := create_tween().set_loops()
	tw.tween_property(root, "scale", Vector2(1.12, 1.12), 0.45).set_trans(Tween.TRANS_SINE)
	tw.tween_property(root, "scale", Vector2(0.96, 0.96), 0.45).set_trans(Tween.TRANS_SINE)
	return root


# Big labeled tap pad (stir-fry sides, flip, mix). Returns the Button.
func _make_big_pad(txt: String, rect: Rect2, col: Color, font_size: int = 56) -> Button:
	var b := Button.new()
	b.text = txt
	b.position = rect.position
	b.size = rect.size
	b.add_theme_font_size_override("font_size", font_size)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(32)
	sb.shadow_size = 8
	sb.shadow_color = Color(0, 0, 0, 0.22)
	b.add_theme_stylebox_override("normal", sb)
	var sbp := sb.duplicate()
	sbp.bg_color = col.lightened(0.18)
	b.add_theme_stylebox_override("pressed", sbp)
	b.add_theme_stylebox_override("hover", sbp)
	b.add_theme_color_override("font_color", Color.WHITE)
	_layer.add_child(b)
	return b


func _make_hold_caption(txt: String, pos: Vector2) -> Label:
	var l := Label.new()
	l.text = txt
	l.position = pos
	l.size = Vector2(520, 56)
	l.add_theme_font_size_override("font_size", 34)
	l.add_theme_color_override("font_color", Color(0.45, 0.32, 0.18))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(l)
	return l


func _set_pad_active(b: Button, col: Color, active: bool) -> void:
	if not is_instance_valid(b):
		return
	var sb := b.get_theme_stylebox("normal") as StyleBoxFlat
	if sb:
		sb.bg_color = col.lightened(0.28) if active else col
		sb.set_border_width_all(6 if active else 0)
		sb.border_color = Color(1.0, 0.95, 0.6)
	b.scale = Vector2(1.06, 1.06) if active else Vector2.ONE
	b.pivot_offset = b.size * 0.5


# --- BEAT phases: chop + stirfry ---
func _start_beat(kind: String) -> void:
	_clear_stage()
	_phase = "beat"
	_beat_kind = kind
	_beat_cat = PHASE_CAT[kind]
	_beat_sum = 0.0
	_stir_pads = {}
	if kind == "chop":
		_phase_header("Chop", "Tap anywhere the moment a piece drops into the glowing ring.")
		_track(_make_board())
		var knife := _build_knife()
		knife.position = Vector2(540, SPAWN_Y)
		_layer.add_child(_track(knife))
		# guide line + pulsing target ring at the judge point
		var line := ColorRect.new()
		line.color = Color(0.96, 0.66, 0.12, 0.55)
		line.size = Vector2(1080, 5)
		line.position = Vector2(0, JUDGE_Y - 2)
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_layer.add_child(_track(line))
		_target_ring = _make_target_ring(Vector2(540, JUDGE_Y))
		_layer.add_child(_track(_target_ring))
	else:  # stirfry
		_phase_header("Stir-fry", "An arrow slides in — tap the LEFT or RIGHT pad that lights up.")
		_track(_make_wok())
		# two big tap pads = obvious targets
		_stir_pads["left"] = _make_big_pad("◀ LEFT", Rect2(60, 1380, 440, 320), Color(0.86, 0.45, 0.22))
		_stir_pads["left"].pressed.connect(_beat_side_tap.bind("left"))
		_track(_stir_pads["left"])
		_stir_pads["right"] = _make_big_pad("RIGHT ▶", Rect2(580, 1380, 440, 320), Color(0.86, 0.45, 0.22))
		_stir_pads["right"].pressed.connect(_beat_side_tap.bind("right"))
		_track(_stir_pads["right"])
	_spawn_beat_notes(kind)


func _spawn_beat_notes(kind: String) -> void:
	_notes.clear()
	var count: int = tap_count if kind == "chop" else 8
	var spacing: float = tap_spacing_ms if kind == "chop" else 520.0
	var t0: float = get_node("/root/BeatClock").now_ms() + lead_in_ms
	for i in range(count):
		var side := "center"
		if kind == "stirfry":
			side = "left" if i % 2 == 0 else "right"
		var node := _make_beat_note(side)
		var sp := _beat_spawn(side)
		var tp := _beat_target(side)
		node.position = sp
		_layer.add_child(_track(node))
		_notes.append({"target_ms": t0 + float(i) * spacing, "node": node, "judged": false, "side": side, "sp": sp, "tp": tp})


func _beat_spawn(side: String) -> Vector2:
	match side:
		"left": return Vector2(80, STIR_Y)
		"right": return Vector2(1000, STIR_Y)
		_: return Vector2(540, SPAWN_Y)


func _beat_target(side: String) -> Vector2:
	match side:
		"left", "right": return Vector2(540, STIR_Y)
		_: return Vector2(540, JUDGE_Y)


func _make_beat_note(side: String) -> Node2D:
	var n := Node2D.new()
	if side == "center":
		# a recognizable round "ingredient" (carrot/radish slice) instead of a box
		var disc := Polygon2D.new()
		disc.polygon = _ellipse(NOTE_R, NOTE_R)
		disc.color = Color(0.93, 0.55, 0.22)
		n.add_child(disc)
		var inner := Polygon2D.new()
		inner.polygon = _ellipse(NOTE_R * 0.62, NOTE_R * 0.62)
		inner.color = Color(0.98, 0.72, 0.40)
		n.add_child(inner)
		var glint := Polygon2D.new()
		glint.polygon = _ellipse(NOTE_R * 0.22, NOTE_R * 0.16)
		glint.position = Vector2(-NOTE_R * 0.32, -NOTE_R * 0.34)
		glint.color = Color(1, 1, 1, 0.7)
		n.add_child(glint)
	else:
		var arrow := Polygon2D.new()
		# arrow points toward center: left-side note points right, right-side points left
		if side == "left":
			arrow.polygon = PackedVector2Array([Vector2(-50, -40), Vector2(30, -40), Vector2(30, -70), Vector2(70, 0), Vector2(30, 70), Vector2(30, 40), Vector2(-50, 40)])
		else:
			arrow.polygon = PackedVector2Array([Vector2(50, -40), Vector2(-30, -40), Vector2(-30, -70), Vector2(-70, 0), Vector2(-30, 70), Vector2(-30, 40), Vector2(50, 40)])
		arrow.color = Color(0.92, 0.55, 0.20)
		n.add_child(arrow)
	return n


func _make_wok() -> Node2D:
	var w := Node2D.new()
	w.position = Vector2(540, STIR_Y + 40)
	var pan := Polygon2D.new()
	pan.polygon = _ellipse(300, 120)
	pan.color = Color(0.22, 0.20, 0.21)
	w.add_child(pan)
	for p in [Vector2(-150, -10), Vector2(0, 14), Vector2(140, -6), Vector2(70, 30)]:
		var bit := Polygon2D.new()
		bit.polygon = _ellipse(34, 22)
		bit.position = p
		bit.color = Color(0.80, 0.45, 0.22)
		w.add_child(bit)
	_layer.add_child(w)
	return w


func _build_knife() -> Node2D:
	var rig := Node2D.new()
	var blade := Polygon2D.new()
	blade.polygon = PackedVector2Array([Vector2(-16, -90), Vector2(16, -90), Vector2(16, 10), Vector2(0, 44), Vector2(-16, 10)])
	blade.color = Color(0.80, 0.83, 0.88)
	rig.add_child(blade)
	var handle := Polygon2D.new()
	handle.polygon = PackedVector2Array([Vector2(-13, -150), Vector2(13, -150), Vector2(12, -86), Vector2(-12, -86)])
	handle.color = Color(0.32, 0.20, 0.13)
	rig.add_child(handle)
	return rig


func _make_board() -> Panel:
	var p := Panel.new()
	p.position = Vector2(300, JUDGE_Y - 40)
	p.size = Vector2(480, 220)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.792, 0.612, 0.392)
	sb.set_corner_radius_all(36)
	sb.set_border_width_all(6)
	sb.border_color = Color(0.40, 0.27, 0.16)
	p.add_theme_stylebox_override("panel", sb)
	_layer.add_child(p)
	return p


func _process(_dt: float) -> void:
	var now: float = get_node("/root/BeatClock").now_ms()
	match _phase:
		"beat":
			var approach: float = get_node("/root/Tuning").approach_time_ms
			var good_half: float = _windows()[1]
			for nd in _notes:
				if nd["judged"]:
					continue
				var node: Node2D = nd["node"]
				var frac: float = clampf((now - (float(nd["target_ms"]) - approach)) / approach, 0.0, 1.3)
				var sp: Vector2 = nd["sp"]
				var tp: Vector2 = nd["tp"]
				node.position = sp.lerp(tp, frac)
				if now - float(nd["target_ms"]) > good_half:
					_beat_resolve(nd, RhythmJudge.MISS)
			if _beat_kind == "stirfry":
				_update_stir_pads(now, good_half)
			if _all_judged():
				_finish_beat()
		"hold":
			if _hold_pressing:
				var held: float = now - _hold_start_ms
				var f: float = clampf(held / _hold_target_ms, 0.0, 1.2)
				if _hold_kind == "boil":
					_update_boil(f, _dt)
				elif is_instance_valid(_hold_fill):
					var fc: float = clampf(f, 0.0, 1.0)
					if _hold_horizontal:
						_hold_fill.size.x = fc * 360.0
					else:
						_hold_fill.size.y = fc * 300.0
						_hold_fill.position.y = 300.0 - _hold_fill.size.y
		"season":
			var remain: float = (_season_end_ms - now) / 1000.0
			if is_instance_valid(_count_label):
				_count_label.text = "Time left %.1fs — then pick a vessel" % maxf(remain, 0.0)
			if remain <= 0.0:
				_finish_season()
		"panfry":
			_process_panfry(now)
		"knead":
			var kr: float = (_knead_end_ms - now) / 1000.0
			if is_instance_valid(_count_label):
				_count_label.text = "Mix! %.1fs left" % maxf(kr, 0.0)
			if kr <= 0.0:
				_finish_knead()


func _beat_resolve(nd: Dictionary, j: int) -> void:
	if nd["judged"]:
		return
	nd["judged"] = true
	_beat_sum += (1.0 if j == RhythmJudge.PERFECT else (0.6 if j == RhythmJudge.GOOD else 0.0))
	get_node("/root/FeedbackBus").hit(j, (nd["node"] as Node2D).position)
	(nd["node"] as Node2D).queue_free()


func _all_judged() -> bool:
	for nd in _notes:
		if not nd["judged"]:
			return false
	return _notes.size() > 0


func _finish_beat() -> void:
	var acc: float = _beat_sum / float(max(1, _notes.size()))
	_record(_beat_cat, acc)
	_clear_stage()
	_next_phase()


# --- HOLD phases: boil + roll ---
func _start_hold(kind: String) -> void:
	_clear_stage()
	_phase = "hold"
	_hold_kind = kind
	_hold_cat = PHASE_CAT[kind]
	_hold_pressing = false
	if kind == "boil":
		_hold_target_ms = 1200.0
		_hold_horizontal = false
		_phase_header("Boil", "Press & HOLD to heat the pot — let go when it's bubbling just right!")
		_build_boil_pot()
		_track(_make_hold_caption("Press & HOLD anywhere", Vector2(300, 1180)))
	else:  # roll
		_hold_target_ms = 1500.0
		_hold_horizontal = true
		_phase_header("Roll", "Press & HOLD to roll it up. Let go when it reaches the goal zone.")
		_track(_make_hold_caption("PRESS & HOLD to roll →", Vector2(330, 800)))
		# gim mat
		var mat := ColorRect.new()
		mat.color = Color(0.18, 0.30, 0.20)
		mat.size = Vector2(420, 140)
		mat.position = Vector2(330, 860)
		mat.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_layer.add_child(_track(mat))
		var track := ColorRect.new()
		track.color = Color(0, 0, 0, 0.12)
		track.size = Vector2(360, 40)
		track.position = Vector2(360, 1040)
		track.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_layer.add_child(_track(track))
		_hold_fill = ColorRect.new()
		_hold_fill.color = Color(0.55, 0.42, 0.22)
		_hold_fill.size = Vector2(0, 40)
		_hold_fill.position = Vector2(0, 0)
		_hold_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		track.add_child(_hold_fill)
		var goal := ColorRect.new()
		goal.color = Color(0.96, 0.66, 0.12, 0.5)
		goal.size = Vector2(48, 40)
		goal.position = Vector2(360 - 48, 0)
		goal.mouse_filter = Control.MOUSE_FILTER_IGNORE
		track.add_child(goal)


func _judge_hold(held_ms: float) -> void:
	var score: float = RhythmJudge.hold_score(_hold_target_ms, held_ms, _hold_tol)
	var j := RhythmJudge.PERFECT if score >= 0.85 else (RhythmJudge.GOOD if score >= 0.4 else RhythmJudge.MISS)
	var fx_pos := Vector2(540, 700) if _hold_kind == "boil" else Vector2(540, 900)
	get_node("/root/FeedbackBus").hit(j, fx_pos)
	if j == RhythmJudge.PERFECT:
		_perfect_burst(fx_pos)
	_record(_hold_cat, score)
	_clear_stage()
	_next_phase()


# --- BOIL POT (the food IS the gauge) ---
func _build_boil_pot() -> void:
	_boil_acc = 0.0
	_boil_root = Node2D.new()
	_boil_root.position = Vector2(540, 720)
	_layer.add_child(_track(_boil_root))
	# perfect heat ring (glows gold when broth is bubbling just right)
	_boil_ring = Line2D.new()
	_boil_ring.width = 12.0
	_boil_ring.default_color = Color(0.55, 0.40, 0.25, 0.5)
	_boil_ring.closed = true
	_boil_ring.points = _ellipse(300, 300)
	_boil_root.add_child(_boil_ring)
	# pot body
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-250, -40), Vector2(250, -40), Vector2(210, 180), Vector2(-210, 180)])
	body.color = Color(0.80, 0.82, 0.86)
	_boil_root.add_child(body)
	# handles
	for sx in [-1.0, 1.0]:
		var h := Polygon2D.new()
		h.polygon = PackedVector2Array([
			Vector2(sx * 250, 0), Vector2(sx * 320, 12), Vector2(sx * 320, 48), Vector2(sx * 250, 40)])
		h.color = Color(0.66, 0.68, 0.72)
		_boil_root.add_child(h)
	# broth surface (color deepens as it heats)
	_boil_broth = Polygon2D.new()
	_boil_broth.polygon = _ellipse(238, 46)
	_boil_broth.position = Vector2(0, -40)
	_boil_broth.color = Color(0.92, 0.62, 0.34)  # cool -> will deepen to rich red
	_boil_root.add_child(_boil_broth)
	# a few noodles + egg so it reads as ramen-ish cooking
	for i in range(4):
		var ln := Line2D.new()
		ln.width = 10.0
		ln.default_color = Color(0.96, 0.83, 0.36)
		var ox: float = -120.0 + float(i) * 60.0
		ln.points = PackedVector2Array([Vector2(ox, -52), Vector2(ox + 30, -36), Vector2(ox - 4, -28)])
		_boil_root.add_child(ln)
	var rim := Line2D.new()
	rim.width = 8.0
	rim.default_color = Color(0.70, 0.72, 0.76)
	rim.closed = true
	rim.points = _ellipse(250, 48)
	rim.position = Vector2(0, -40)
	_boil_root.add_child(rim)


func _update_boil(f: float, dt: float) -> void:
	if not is_instance_valid(_boil_root):
		return
	var heat: float = clampf(f, 0.0, 1.0)
	# broth deepens + the ring fills and turns gold in the sweet spot
	if is_instance_valid(_boil_broth):
		_boil_broth.color = Color(0.92, 0.62, 0.34).lerp(Color(0.84, 0.20, 0.13), heat)
	var sweet := f >= 0.8 and f <= 1.05
	if is_instance_valid(_boil_ring):
		_boil_ring.points = _arc_points(300.0, clampf(f, 0.0, 1.0))
		_boil_ring.default_color = Color(1.0, 0.80, 0.25, 0.95) if sweet else Color(0.85, 0.45, 0.18, 0.8)
		_boil_ring.width = 18.0 if sweet else 12.0
	# bubbles rise faster as it heats
	_boil_acc += dt
	var rate: float = lerpf(0.30, 0.07, heat)
	if _boil_acc >= rate:
		_boil_acc = 0.0
		_spawn_bubble()
		if sweet:
			_spawn_steam()


func _arc_points(r: float, frac: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var n := maxi(2, int(48.0 * clampf(frac, 0.02, 1.0)))
	for i in range(n + 1):
		var a: float = -PI * 0.5 + TAU * (float(i) / 48.0)
		pts.append(Vector2(cos(a), sin(a)) * r)
	return pts


func _spawn_bubble() -> void:
	if not is_instance_valid(_boil_root):
		return
	var b := Polygon2D.new()
	var rr: float = randf_range(6.0, 16.0)
	b.polygon = _ellipse(rr, rr)
	b.position = Vector2(randf_range(-200, 200), -44)
	b.color = Color(1.0, 0.85, 0.6, 0.6)
	_boil_root.add_child(b)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(b, "position:y", -70.0, 0.4)
	tw.tween_property(b, "modulate:a", 0.0, 0.4)
	tw.chain().tween_callback(b.queue_free)


func _spawn_steam() -> void:
	if not is_instance_valid(_boil_root):
		return
	var s := Polygon2D.new()
	s.polygon = _ellipse(34, 24)
	s.position = Vector2(randf_range(-120, 120), -70)
	s.color = Color(1, 1, 1, 0.28)
	_boil_root.add_child(s)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(s, "position:y", -230.0, 0.9)
	tw.tween_property(s, "scale", Vector2(1.8, 1.8), 0.9)
	tw.tween_property(s, "modulate:a", 0.0, 0.9)
	tw.chain().tween_callback(s.queue_free)


# Big satisfying PERFECT moment: sparkles + steam puff + label.
func _perfect_burst(pos: Vector2) -> void:
	var lbl := Label.new()
	lbl.text = "PERFECT!"
	lbl.position = Vector2(pos.x - 250, pos.y - 220)
	lbl.size = Vector2(500, 80)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 70)
	lbl.add_theme_color_override("font_color", Color(0.98, 0.78, 0.18))
	lbl.pivot_offset = Vector2(250, 40)
	lbl.scale = Vector2(0.4, 0.4)
	_layer.add_child(_track(lbl))
	var tw := create_tween()
	tw.tween_property(lbl, "scale", Vector2(1.15, 1.15), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.5)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.3)
	# sparkles
	for i in range(10):
		var sp := Polygon2D.new()
		sp.polygon = _ellipse(8, 8)
		sp.position = pos
		sp.color = Color(1.0, 0.9, 0.4, 0.95)
		_layer.add_child(_track(sp))
		var ang: float = TAU * float(i) / 10.0
		var dest := pos + Vector2(cos(ang), sin(ang)) * randf_range(140, 230)
		var t2 := create_tween().set_parallel(true)
		t2.tween_property(sp, "position", dest, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		t2.tween_property(sp, "modulate:a", 0.0, 0.45)
		t2.chain().tween_callback(sp.queue_free)


# --- SEASON ---
func _start_season() -> void:
	_clear_stage()
	_phase = "season"
	_phase_header("Season", "Tap a seasoning to add it. %s" % _season_tip())
	_gauge = SeasoningGauge.new()
	_gauge.position = Vector2(540, 1000)
	_layer.add_child(_track(_gauge))
	var defs: Array = []
	for s in _slots:
		defs.append({"id": s["id"], "max": s["umax"]})
	_gauge.setup(defs)
	var n: int = _slots.size()
	var btn_w := 300.0
	var gap := 60.0
	var total := n * btn_w + (n - 1) * gap
	var start_x := (1080.0 - total) * 0.5
	for i in range(n):
		var sid = _slots[i]["id"]
		var label := "%s +" % SeasoningGauge.display_name(sid)
		var col: Color = SeasoningGauge.COLORS.get(sid, Color(0.6, 0.5, 0.4))
		_track(_make_season_btn(label, col, start_x + i * (btn_w + gap), btn_w, i))
	_count_label = _make_count_label()
	_season_end_ms = get_node("/root/BeatClock").now_ms() + 5000.0


func _make_count_label() -> Label:
	var l := Label.new()
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.position = Vector2(0, 1700)
	l.size = Vector2(1080, 60)
	l.add_theme_font_size_override("font_size", 40)
	l.add_theme_color_override("font_color", Color(0.5, 0.35, 0.2))
	_layer.add_child(_track(l))
	return l


func _season_tip() -> String:
	var vec: Dictionary = _guest.get("vec", {})
	var desc := {
		"sweet": "a touch of sweetness", "salty": "a clean savory seasoning",
		"spicy": "a spicy kick", "sour": "a tangy edge", "umami": "deep savory flavor",
	}
	var top_axis := "salty"
	var top_val := -1.0
	for a in vec.keys():
		if float(vec[a]) > top_val:
			top_val = float(vec[a])
			top_axis = a
	return "Tip: %s loves %s." % [_guest.get("name", "the guest"), desc.get(top_axis, "good seasoning")]


func _make_season_btn(txt: String, col: Color, x: float, w: float, slot: int) -> Button:
	var b := Button.new()
	b.text = txt
	b.position = Vector2(x, 1380)
	b.size = Vector2(w, 220)
	b.add_theme_font_size_override("font_size", 40)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(28)
	b.add_theme_stylebox_override("normal", sb)
	var sb2 := sb.duplicate()
	sb2.bg_color = col.lightened(0.15)
	b.add_theme_stylebox_override("pressed", sb2)
	b.add_theme_stylebox_override("hover", sb2)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.pressed.connect(func() -> void:
		if _phase == "season" and _gauge != null:
			_gauge.add_tap(slot))
	_layer.add_child(b)
	return b


func _finish_season() -> void:
	_season_counts = []
	if _gauge != null:
		for i in range(_slots.size()):
			_season_counts.append(_gauge.count_of(i))
	_record("season", _seasoning_score())
	_clear_stage()
	_next_phase()


# --- PAN-FRY ---
func _start_panfry() -> void:
	_clear_stage()
	_phase = "panfry"
	_phase_header("Pan-fry", "Watch it sizzle — tap the FLIP pad the moment it turns gold.")
	_pan_start_ms = get_node("/root/BeatClock").now_ms()
	_pan_dur_ms = 4500.0
	_pan_flips = [
		{"at": 1500.0, "open": 340.0, "done": false, "score": 0.0},
		{"at": 3000.0, "open": 340.0, "done": false, "score": 0.0},
	]
	# pancake
	var root := Node2D.new()
	root.position = Vector2(540, 940)
	var pan := Polygon2D.new()
	pan.polygon = _ellipse(290, 150)
	pan.color = Color(0.20, 0.18, 0.19)
	root.add_child(pan)
	_pan_cake = Polygon2D.new()
	_pan_cake.polygon = _ellipse(230, 120)
	_pan_cake.color = Color(0.93, 0.86, 0.62)  # raw -> will brown
	root.add_child(_pan_cake)
	_layer.add_child(_track(root))
	_pan_pad = _make_big_pad("WAIT…", Rect2(290, 1360, 500, 300), Color(0.55, 0.50, 0.45))
	_pan_pad.pressed.connect(_panfry_tap)
	_track(_pan_pad)
	_count_label = _make_count_label()


func _process_panfry(now: float) -> void:
	var prog: float = clampf((now - _pan_start_ms) / _pan_dur_ms, 0.0, 1.0)
	if is_instance_valid(_pan_cake):
		_pan_cake.color = Color(0.93, 0.86, 0.62).lerp(Color(0.74, 0.45, 0.16), prog)
	var open_now := false
	for fl in _pan_flips:
		if not fl["done"] and abs((now - _pan_start_ms) - float(fl["at"])) <= float(fl["open"]):
			open_now = true
	if is_instance_valid(_pan_pad):
		_pan_pad.text = "FLIP!" if open_now else "WAIT…"
		_set_pad_active(_pan_pad, Color(0.86, 0.45, 0.22) if open_now else Color(0.55, 0.50, 0.45), open_now)
	if is_instance_valid(_count_label):
		_count_label.text = "★ FLIP NOW! ★" if open_now else "watching it sizzle…"
	# auto-miss flips whose window passed
	for fl in _pan_flips:
		if not fl["done"] and (now - _pan_start_ms) > float(fl["at"]) + float(fl["open"]):
			fl["done"] = true
			fl["score"] = 0.0
			get_node("/root/FeedbackBus").hit(RhythmJudge.MISS, Vector2(540, 760))
	if prog >= 1.0:
		_finish_panfry()


func _panfry_tap() -> void:
	var now: float = get_node("/root/BeatClock").now_ms()
	for fl in _pan_flips:
		if fl["done"]:
			continue
		var dist: float = abs((now - _pan_start_ms) - float(fl["at"]))
		if dist <= float(fl["open"]):
			fl["done"] = true
			var sc: float = clampf(1.0 - dist / float(fl["open"]), 0.0, 1.0)
			fl["score"] = sc
			var j := RhythmJudge.PERFECT if sc >= 0.7 else RhythmJudge.GOOD
			get_node("/root/FeedbackBus").hit(j, Vector2(540, 760))
			if j == RhythmJudge.PERFECT:
				_perfect_burst(Vector2(540, 760))
			return


func _finish_panfry() -> void:
	if _phase != "panfry":
		return
	var scores: Array = []
	for fl in _pan_flips:
		scores.append(float(fl["score"]))
	_record(PHASE_CAT["panfry"], _avg(scores))
	_clear_stage()
	_next_phase()


# --- KNEAD / MIX ---
func _start_knead() -> void:
	_clear_stage()
	_phase = "knead"
	_knead_taps = 0
	_knead_target = 12
	_phase_header("Mix", "Tap the MIX pad as fast as you can before time runs out!")
	_knead_bowl = Node2D.new()
	_knead_bowl.position = Vector2(540, 960)
	var bowl := Polygon2D.new()
	bowl.polygon = _ellipse(260, 150)
	bowl.color = Color(0.30, 0.27, 0.26)
	_knead_bowl.add_child(bowl)
	for i in range(5):
		var bit := Polygon2D.new()
		bit.polygon = _ellipse(40, 28)
		var ang: float = TAU * float(i) / 5.0
		bit.position = Vector2(cos(ang) * 110.0, sin(ang) * 60.0)
		bit.color = [Color(0.85, 0.30, 0.20), Color(0.95, 0.80, 0.25), Color(0.40, 0.62, 0.30), Color(0.90, 0.90, 0.85), Color(0.70, 0.45, 0.25)][i]
		_knead_bowl.add_child(bit)
	_layer.add_child(_track(_knead_bowl))
	_knead_pad = _make_big_pad("TAP! 0 / %d" % _knead_target, Rect2(340, 1360, 400, 300), Color(0.80, 0.45, 0.55))
	_knead_pad.pressed.connect(_knead_tap)
	_track(_knead_pad)
	_count_label = _make_count_label()
	_knead_end_ms = get_node("/root/BeatClock").now_ms() + 3000.0


func _knead_tap() -> void:
	if _phase != "knead":
		return
	_knead_taps += 1
	if is_instance_valid(_knead_pad):
		_knead_pad.text = "TAP! %d / %d" % [mini(_knead_taps, _knead_target), _knead_target]
	if is_instance_valid(_knead_bowl):
		_knead_bowl.rotation += 0.35
		var tw := create_tween()
		tw.tween_property(_knead_bowl, "scale", Vector2(1.06, 1.06), 0.05)
		tw.tween_property(_knead_bowl, "scale", Vector2.ONE, 0.08)
	get_node("/root/FeedbackBus").hit(RhythmJudge.GOOD, Vector2(540, 760))


func _finish_knead() -> void:
	if _phase != "knead":
		return
	var acc: float = clampf(float(_knead_taps) / float(_knead_target), 0.0, 1.0)
	_record(PHASE_CAT["knead"], acc)
	_clear_stage()
	_next_phase()


# --- 4. plating ---
func _start_plating() -> void:
	_clear_stage()
	if is_instance_valid(_now_cooking):
		_now_cooking.visible = false  # reveal shows the finished dish instead
	_phase = "plating"
	_info.position = Vector2(40, 56)
	_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_info.text = "Plating — where to serve it?"
	if is_instance_valid(_howto):
		_howto.text = "Tap the dish that suits %s best." % _menu_name()
	var n: int = _dish_options.size()
	var btn_w := 280.0
	var gap := 30.0
	var total := n * btn_w + (n - 1) * gap
	var x := (1080.0 - total) * 0.5
	for d in _dish_options:
		var info: Dictionary = MenuDB.vessel(d)
		var b := Button.new()
		b.text = "%s\n(%s)" % [info.get("name_en", d), info.get("name_kr", "")]
		b.position = Vector2(x, 1380)
		b.size = Vector2(btn_w, 180)
		b.add_theme_font_size_override("font_size", 34)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.pressed.connect(_on_dish.bind(d))
		_layer.add_child(_track(b))
		x += btn_w + gap


func _on_dish(d: String) -> void:
	if _phase != "plating":
		return
	_dish_choice = d
	_clear_stage()
	_phase = "reveal"
	_start_reveal()


# --- 5. reveal ---
func _start_reveal() -> void:
	_info.text = ""
	_clear_howto()
	var tier: String = MenuDB.dish_tier(_menu, _dish_choice)
	var glow_a: float = 0.7 if tier == "best" else (0.12 if tier == "bad" else 0.4)
	var grad := Gradient.new()
	grad.set_color(0, Color(0.98, 0.78, 0.22, 0.6))
	grad.set_color(1, Color(0.98, 0.78, 0.22, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(1.0, 0.5)
	gt.width = 760
	gt.height = 760
	var glow := TextureRect.new()
	glow.texture = gt
	glow.size = Vector2(760, 760)
	glow.position = Vector2(540 - 380, 940 - 380)
	glow.modulate.a = 0.0
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_track(glow))
	var vessel := _build_vessel(_dish_choice)
	vessel.scale = Vector2(0.85, 0.85)
	vessel.modulate.a = 0.0
	_layer.add_child(_track(vessel))
	var tw := create_tween().set_parallel(true)
	tw.tween_property(vessel, "modulate:a", 1.0, 0.3)
	tw.tween_property(vessel, "scale", Vector2(1.05, 1.05), 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(glow, "modulate:a", glow_a, 0.4)
	var vname: String = MenuDB.vessel(_dish_choice).get("name_en", _dish_choice)
	var badge := Label.new()
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.position = Vector2(40, 1300)
	badge.size = Vector2(1000, 130)
	badge.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	badge.add_theme_font_size_override("font_size", 44)
	match tier:
		"best":
			badge.text = "%s — perfect match for %s! ▲▲" % [vname, _menu_name()]
			badge.add_theme_color_override("font_color", Color(0.85, 0.6, 0.1))
		"bad":
			badge.text = "%s — not quite right for %s ▼" % [vname, _menu_name()]
			badge.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
		_:
			badge.text = "%s — a decent pairing ▲" % vname
			badge.add_theme_color_override("font_color", Color(0.5, 0.4, 0.2))
	badge.modulate.a = 0.0
	badge.scale = Vector2(0.7, 0.7)
	badge.pivot_offset = Vector2(500, 65)
	_layer.add_child(_track(badge))
	var bt := create_tween().set_parallel(true)
	bt.tween_property(badge, "modulate:a", 1.0, 0.25).set_delay(0.45)
	bt.tween_property(badge, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.45)
	var am := get_node_or_null("/root/AudioManager")
	if am and am.has_method("play"):
		am.play(&"act_done")
		am.play(&"judge_perfect" if tier == "best" else (&"judge_miss" if tier == "bad" else &"judge_good"))
	await get_tree().create_timer(1.8).timeout
	_finish()


## Ellipse polygon.
func _ellipse(rx: float, ry: float, seg: int = 28) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(seg):
		var a: float = TAU * float(i) / float(seg)
		pts.append(Vector2(cos(a) * rx, sin(a) * ry))
	return pts


func _build_vessel(dish_id: String) -> Node2D:
	var info: Dictionary = MenuDB.vessel(dish_id)
	var kind: String = info.get("kind", "ceramic")
	var col: Color = info.get("color", Color(0.9, 0.9, 0.88))
	if kind == "glass":
		col.a = 0.85
	var root := Node2D.new()
	root.position = Vector2(540, 940)
	var tex: Texture2D = null
	if bool(_menu.get("ready", false)):
		tex = load(String(_menu.get("food_img", "")))
	if tex != null:
		# The food PNG already includes its own bowl, so we serve it on a STAND/TRAY
		# (styled by the chosen vessel) instead of wrapping another bowl around it.
		_draw_stand(root, kind, col)
		var spr := Sprite2D.new()
		spr.texture = tex
		var w: float = float(tex.get_width())
		var sc: float = 380.0 / maxf(w, 1.0)
		spr.scale = Vector2(sc, sc)
		spr.position = Vector2(0, -30)
		root.add_child(spr)
	else:
		# placeholder menu (no PNG): draw the vessel itself with a simple food mound inside
		_draw_bowl(root, kind, col)
		_draw_food_mound(root)
	return root


# A serving stand / tray under the dish (so a bowl-in-PNG doesn't get a second bowl).
func _draw_stand(root: Node2D, kind: String, col: Color) -> void:
	var cy := 150.0
	# soft shadow
	var sh := Polygon2D.new()
	sh.polygon = _ellipse(310, 60)
	sh.position = Vector2(0, cy + 18)
	sh.color = Color(0, 0, 0, 0.12)
	root.add_child(sh)
	# stand base
	var base := Polygon2D.new()
	base.polygon = _ellipse(300, 66)
	base.position = Vector2(0, cy)
	base.color = col
	root.add_child(base)
	var lip := Polygon2D.new()
	lip.polygon = _ellipse(300, 58)
	lip.position = Vector2(0, cy - 12)
	lip.color = col.lightened(0.14)
	root.add_child(lip)
	match kind:
		"metal":  # pot handles flanking the tray
			for sx in [-1.0, 1.0]:
				var h := Polygon2D.new()
				h.polygon = PackedVector2Array([
					Vector2(sx * 300, cy - 20), Vector2(sx * 366, cy - 10),
					Vector2(sx * 366, cy + 18), Vector2(sx * 300, cy + 12)])
				h.color = col.darkened(0.18)
				root.add_child(h)
		"wood":   # plank lines
			for dx in [-150.0, 0.0, 150.0]:
				var ln := Line2D.new()
				ln.width = 3.0
				ln.default_color = col.darkened(0.22)
				ln.points = PackedVector2Array([Vector2(dx, cy - 40), Vector2(dx, cy + 40)])
				root.add_child(ln)
		"brass":  # warm rim highlight
			var ring := Line2D.new()
			ring.width = 6.0
			ring.default_color = Color(0.95, 0.82, 0.45)
			ring.closed = true
			ring.points = _ellipse(300, 66)
			ring.position = Vector2(0, cy)
			root.add_child(ring)


# A simple bowl/pot drawn for placeholder menus (no food PNG -> safe to draw walls).
func _draw_bowl(root: Node2D, kind: String, col: Color) -> void:
	var shallow := kind == "plate" or kind == "wood"
	var top_rx := 245.0 if shallow else 235.0
	var depth := 95.0 if shallow else 230.0
	var bot_rx := top_rx * (0.9 if shallow else 0.78)
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-top_rx, -100), Vector2(top_rx, -100),
		Vector2(bot_rx, -100 + depth), Vector2(-bot_rx, -100 + depth)])
	body.color = col
	root.add_child(body)
	var rim := Polygon2D.new()
	rim.polygon = _ellipse(top_rx, 50)
	rim.position = Vector2(0, -100)
	rim.color = col.darkened(0.14)
	root.add_child(rim)
	var well := Polygon2D.new()
	well.polygon = _ellipse(top_rx - 18, 40)
	well.position = Vector2(0, -96)
	well.color = col.darkened(0.05)
	root.add_child(well)
	if kind == "metal":
		for sx in [-1.0, 1.0]:
			var h := Polygon2D.new()
			h.polygon = PackedVector2Array([
				Vector2(sx * top_rx, -56), Vector2(sx * (top_rx + 65), -44),
				Vector2(sx * (top_rx + 65), -8), Vector2(sx * top_rx, 0)])
			h.color = col.darkened(0.12)
			root.add_child(h)


func _draw_food_mound(root: Node2D) -> void:
	var mound := Polygon2D.new()
	mound.polygon = _ellipse(180, 60)
	mound.position = Vector2(0, -104)
	mound.color = Color(0.86, 0.55, 0.30)
	root.add_child(mound)
	for p in [Vector2(-80, -110), Vector2(20, -118), Vector2(95, -104)]:
		var bit := Polygon2D.new()
		bit.polygon = _ellipse(22, 16)
		bit.position = p
		bit.color = Color(0.78, 0.30, 0.18)
		root.add_child(bit)


# --- 6. result ---
func _finish() -> void:
	_phase = "done"
	get_node("/root/BeatClock").stop()
	# weighted blend over present categories
	var weights := {"prep": float(_level.get("w_prep", 0.3)), "cook": float(_level.get("w_cook", 0.2)), "season": float(_level.get("w_season", 0.5))}
	var num: float = 0.0
	var den: float = 0.0
	for c in weights.keys():
		var arr: Array = _cat_acc.get(c, [])
		if arr.size() > 0:
			num += weights[c] * _avg(arr)
			den += weights[c]
	var base: float = num / den if den > 0.0 else 0.0
	var dish_bonus: float = MenuDB.dish_bonus_scaled(_menu, _dish_choice, float(_level.get("w_dish", 0.12)))
	var s: float = clampf(base + dish_bonus, 0.0, 1.0)
	var stars := _stars(s)
	var passed: bool = s >= float(_level.get("theta", 0.6))
	var vname: String = MenuDB.vessel(_dish_choice).get("name_en", _dish_choice)
	var tier: String = MenuDB.dish_tier(_menu, _dish_choice)
	var dish_word: String = ("best match ▲▲" if tier == "best" else ("poor match ▼" if tier == "bad" else ("decent ▲" if tier == "2nd" else "neutral")))
	var reward: int = 0
	if passed:
		reward = int(round(float(_level.get("reward", 0)) * (1.3 if s >= float(_level.get("star4", 0.85)) else 1.0)))
	var reward_line: String = ("Earned %s coins" % _commas(reward)) if passed else "Didn't pass — try again!"
	_info.position = Vector2(40, 1520)
	_info.text = "%s  %s\n%s\nVessel: %s — %s\n%s\n(tap to return to menu)" % [
		"★".repeat(stars) + "☆".repeat(5 - stars), _guest.get("name", "Guest"),
		_guest_line(s), vname, dish_word, reward_line]
	# persist economy + progression
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		if passed and reward > 0:
			sm.add_money(reward)
		sm.record_round(String(_menu.get("id", "")), stars, passed, String(_level.get("market", "home")))
		if not _is_evaluator:
			var d: float = 1.0 if s >= 0.80 else (0.0 if s >= 0.55 else -0.5)
			if d != 0.0:
				sm.add_intimacy(String(_guest.get("id", "")), d)
	var hm := get_node_or_null("/root/HapticManager")
	if hm:
		hm.play(hm.REVEAL)
	print("[M1+] %s L%d S=%.2f base=%.2f dish=%.2f pass=%s phases=%s" % [
		_menu.get("id", "?"), int(_level.get("level", 1)), s, base, dish_bonus, passed, _menu.get("phases", [])])


func _commas(n: int) -> String:
	var s := str(n)
	var out := ""
	var c := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = "," + out
	return out


func _seasoning_score() -> float:
	if _season_counts.is_empty():
		return 0.0
	var vec: Dictionary = _guest.get("vec", {})
	var tol: float = float(_level.get("tol", _guest.get("tol", 0.30)))
	var total: float = 0.0
	for i in range(_slots.size()):
		var slot: Dictionary = _slots[i]
		var umax: int = int(slot["umax"])
		var v: float = float(vec.get(slot["axis"], 0.5))
		var optimal: float = round(v * float(umax))
		var applied: float = float(_season_counts[i])
		var err: float = abs(applied - optimal) / float(umax)
		total += clampf(1.0 - pow(err / tol, 2.0), 0.0, 1.0)
	return total / float(_slots.size())


func _stars(s: float) -> int:
	if s >= float(_level.get("star5", 0.92)): return 5
	elif s >= float(_level.get("star4", 0.80)): return 4
	elif s >= float(_level.get("star3", 0.68)): return 3
	elif s >= float(_level.get("star2", 0.55)): return 2
	return 1


func _guest_line(s: float) -> String:
	var base: String
	if s >= 0.80:
		base = String(_guest.get("line_ok", "That was great!"))
	elif s >= 0.55:
		base = "Pretty good."
	else:
		base = String(_guest.get("line_bad", "Not quite my taste."))
	var hint := _off_axis_hint()
	return base + (("  (" + hint + ")") if hint != "" else "")


func _off_axis_hint() -> String:
	if _season_counts.is_empty():
		return ""
	var vec: Dictionary = _guest.get("vec", {})
	var names := {"spicy": "spice", "salty": "salt", "sweet": "sweetness", "sour": "tang", "umami": "savory depth"}
	var worst := ""
	var worst_err := 0.15
	for i in range(_slots.size()):
		var slot: Dictionary = _slots[i]
		var umax: int = int(slot["umax"])
		var v: float = float(vec.get(slot["axis"], 0.5))
		var optimal: float = round(v * float(umax))
		var applied: float = float(_season_counts[i])
		var diff: float = (applied - optimal) / float(umax)
		if abs(diff) > worst_err:
			worst_err = abs(diff)
			var label: String = names.get(slot["axis"], slot["axis"])
			worst = ("a bit too much %s" % label) if diff > 0 else ("could use more %s" % label)
	return worst


# --- input routing ---
func _unhandled_input(event: InputEvent) -> void:
	var pressed := false
	var released := false
	var pos := Vector2.ZERO
	if event is InputEventScreenTouch:
		pos = event.position
		pressed = event.pressed
		released = not event.pressed
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		pos = event.position
		pressed = event.pressed
		released = not event.pressed

	match _phase:
		"beat":
			if pressed and _beat_kind == "chop":
				_judge_beat("center")  # chop: tap anywhere on the beat
		"hold":
			if pressed and not _hold_pressing:
				_hold_pressing = true
				_hold_start_ms = get_node("/root/BeatClock").now_ms()
			elif released and _hold_pressing:
				_hold_pressing = false
				_judge_hold(get_node("/root/BeatClock").now_ms() - _hold_start_ms)
		"panfry":
			if pressed:
				_panfry_tap()
		"knead":
			if pressed:
				_knead_tap()
		"season":
			pass  # buttons only
		"done":
			if pressed:
				get_tree().change_scene_to_file("res://scenes/menu_select.tscn")


func _beat_side_tap(side: String) -> void:
	if _phase == "beat":
		_judge_beat(side)


func _judge_beat(tapped_side: String) -> void:
	var now: float = get_node("/root/BeatClock").now_ms()
	var w := _windows()
	var best = null
	var best_d: float = 1e9
	for nd in _notes:
		if nd["judged"]:
			continue
		if _beat_kind == "stirfry" and String(nd["side"]) != tapped_side:
			continue
		var d: float = abs(now - float(nd["target_ms"]))
		if d < best_d:
			best_d = d
			best = nd
	if best == null:
		return
	if best_d <= w[1]:
		_beat_resolve(best, RhythmJudge.judge(now - float(best["target_ms"]), w[0], w[1]))


# Light up whichever stir pad has an arrow arriving now (so the player knows where to tap).
func _update_stir_pads(now: float, good_half: float) -> void:
	var win := maxf(good_half * 2.2, 260.0)
	for side in ["left", "right"]:
		var active := false
		for nd in _notes:
			if nd["judged"] or String(nd["side"]) != side:
				continue
			if abs(now - float(nd["target_ms"])) <= win:
				active = true
				break
		_set_pad_active(_stir_pads.get(side, null), Color(0.86, 0.45, 0.22), active)
