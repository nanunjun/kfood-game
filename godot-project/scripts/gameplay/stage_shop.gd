## StageShop — Scene 1 재래시장 가게 방문 쇼핑.
##
## 시장 화면(가게 목록) → 가게 진입(재료 토글 선택) → 시장 복귀 → 모든 가게 방문 후 Checkout.
## 음식별 필요 가게 = ShoppingRegistry.correct_by_store(food_id). 가게별 정답+디스트랙터 토글.
## 채점: (정답 선택 - 오답 선택)/총 정답. finished(accuracy_shop).
class_name StageShop
extends Control

signal finished(accuracy_shop: float)

const DARK := Color(0.17, 0.11, 0.08)
const STORE_LABEL := {
	"produce": "Produce", "meat": "Butcher", "seafood": "Fishmonger",
	"grain": "Grain", "sundry": "Pantry",
}
const MAX_DISTRACT := 3

var _food_name: String = ""
var _by_store: Dictionary = {}      # store -> [correct names]
var _needed: Array = []             # 방문 필요 가게 순서
var _visited: Dictionary = {}       # store -> bool
var _picks: Dictionary = {}         # store -> [picked names]
var _dyn: Array = []                # 현재 뷰 동적 노드(전환 시 free)
var _store_btns: Dictionary = {}    # 현재 가게 토글 버튼


func setup(food_name: String, food_id: StringName) -> void:
	_food_name = food_name
	_by_store = ShoppingRegistry.correct_by_store(food_id).duplicate(true)
	_needed = _by_store.keys()
	for s in _needed:
		_visited[s] = false
		_picks[s] = []


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_show_market()


func _clear() -> void:
	for n in _dyn:
		if is_instance_valid(n):
			n.queue_free()
	_dyn.clear()
	_store_btns.clear()


func _add(n: Node) -> Node:
	_dyn.append(n)
	add_child(n)
	return n


# ---- 시장 화면 ----
func _show_market() -> void:
	_clear()
	_label("Market — shop for %s" % _food_name, 110, 50, 1000)
	var sub := _label("Visit each stall and pick the right ingredients", 200, 32, 1000)
	sub.modulate = Color(0.17, 0.11, 0.08, 0.7)

	var y := 320.0
	for s in _needed:
		var lab: String = STORE_LABEL.get(s, String(s))
		var state := "DONE" if _visited[s] else "tap to enter"
		var b := Button.new()
		b.text = "%s   (%s)" % [lab, state]
		b.position = Vector2(140, y)
		b.size = Vector2(800, 130)
		b.pressed.connect(_show_store.bind(s))
		_add(b)
		y += 152.0

	var basket: int = 0
	for s in _needed:
		basket += (_picks[s] as Array).size()
	var bl := _label("Basket: %d items" % basket, 1380, 36, 1000)
	bl.modulate = Color(0.17, 0.11, 0.08, 0.8)

	var all_visited := true
	for s in _needed:
		if not _visited[s]:
			all_visited = false
	var co := Button.new()
	co.text = "Checkout" if all_visited else "Visit all stalls first"
	co.position = Vector2(290, 1560)
	co.size = Vector2(500, 120)
	co.disabled = not all_visited
	co.pressed.connect(_checkout)
	_add(co)


# ---- 가게 화면 ----
func _show_store(store: String) -> void:
	_clear()
	var lab: String = STORE_LABEL.get(store, store)
	_label("%s" % lab, 110, 52, 1000)
	_label("Pick the ingredients for %s" % _food_name, 195, 32, 1000).modulate = Color(0.17, 0.11, 0.08, 0.7)

	var correct: Array = _by_store.get(store, [])
	var pool: Array = ShoppingRegistry.pool_by_store(store).duplicate()
	pool.shuffle()
	var opts: Array = correct.duplicate()
	for nm in pool:
		if not correct.has(nm) and opts.size() < correct.size() + MAX_DISTRACT:
			opts.append(nm)
	opts.shuffle()

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 30)
	grid.add_theme_constant_override("v_separation", 24)
	grid.position = Vector2(80, 300)
	grid.size = Vector2(920, 1000)
	_add(grid)
	var prev: Array = _picks.get(store, [])
	for nm_v in opts:
		var nm: String = String(nm_v)
		var b := Button.new()
		b.toggle_mode = true
		b.text = nm
		b.button_pressed = prev.has(nm)
		b.custom_minimum_size = Vector2(440, 140)
		b.add_theme_font_size_override("font_size", 34)
		b.toggled.connect(func(_on: bool) -> void: AudioManager.play(&"ui_select"))
		grid.add_child(b)
		_store_btns[nm] = b

	var done := Button.new()
	done.text = "Done"
	done.position = Vector2(290, 1560)
	done.size = Vector2(500, 120)
	done.pressed.connect(_leave_store.bind(store))
	_add(done)


func _leave_store(store: String) -> void:
	var picked: Array = []
	for nm in _store_btns.keys():
		if (_store_btns[nm] as Button).button_pressed:
			picked.append(nm)
	_picks[store] = picked
	_visited[store] = true
	AudioManager.play(&"judge_good")
	_show_market()


func _checkout() -> void:
	var total_correct := 0
	var hits := 0
	var wrong := 0
	for s in _needed:
		var correct: Array = _by_store[s]
		total_correct += correct.size()
		for nm in _picks[s]:
			if correct.has(nm):
				hits += 1
			else:
				wrong += 1
	var acc: float = clampf(float(hits - wrong) / float(max(1, total_correct)), 0.0, 1.0)
	AudioManager.play(&"sting_start")
	_clear()
	_label("Got everything! Let's cook.", 800, 44, 1000)
	var tw := create_tween()
	tw.tween_interval(0.7)
	tw.tween_callback(func() -> void: finished.emit(acc))


func _label(txt: String, y: float, fsize: int, w: float) -> Label:
	var l := Label.new()
	l.text = txt
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.position = Vector2((1080.0 - w) * 0.5, y)
	l.size = Vector2(w, 90)
	l.add_theme_font_size_override("font_size", fsize)
	l.add_theme_color_override("font_color", DARK)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_add(l)
	return l
