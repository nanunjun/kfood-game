## ShoppingStage — Gimbap Vertical Slice Stage 1 (재래시장 재료 고르기).
##
## design §2. 한식 시장 좌판(시장 톤 — e-commerce UI 금지)에서 김밥 재료를 탭으로 장바구니에
## 담고 함정(틀린) 재료를 회피한다. 신규 module 아님(ADR-011) — Shopping은 *stage*다. 그래서
## CookingModule을 상속하지 않고 독립 Control로, `stage_completed(quality, collected_fillings)`
## 시그널로 runner에 결과를 넘긴다(quality-state backbone).
##
## scoring (design §2.4 — cooking-mechanics §2.5 공식 보존):
##   shopping_quality = clamp01( correct_picks / N_correct  -  0.15 × wrong_picks )
##   핵심 재료(seaweed/rice/danmuji) 누락 = 큰 감점 + STAGE 3 consequence(§8.1: collected_fillings).
##
## 정답/함정 (design §2.2 — matrix §2.3 banned ground truth, 신규 데이터 0):
##   정답: seaweed/rice/carrot/egg/spinach(green)/danmuji(+ ham optional)
##   함정: ramyeon noodle / gochujang / tofu / rice_cake(떡) / soup_broth / corndog_batter
##
## 신규 system 최소: freshness/budget/복잡 inventory 전부 제외(design §2.1 LOCK). 공통 타이머만.
extends Control

## 한 stage 완료 시 1회 emit. quality = shopping_quality [0,1].
## collected_fillings = 수집한 정답 재료 id 배열(§8.1 consequence — Pass B에서 available filling).
signal stage_completed(quality: float, collected_fillings: Array)

const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")
const CookingFX := preload("res://scripts/ui/cooking_fx.gd")
const MarketBG := preload("res://scripts/ui/market_bg.gd")

# F5 before/after 검증 전용 (gameplay 무관) — true면 Issue 1/5 수정 *전* 동작(빈 슬롯 "!" 마크,
# 카드 check/X badge 없음)을 재현해 before 스크린샷을 같은 코드 경로로 캡처한다. 기본 false.
static var shot_legacy_basket: bool = false

# 공통 타이머 (design §2.3 — balance-config §2.2.2 25s). vertical slice는 관대 band.
const SHOP_SECONDS: float = 25.0
const WRONG_PENALTY: float = 0.15      # 함정 선택 -0.15/개 (design §2.4)
const WRONG_TIME_HIT: float = 1.0      # 함정 선택 시 -1s (cooking-mechanics §2.3)

# 김밥 정답 재료 (id, label, ingredient sprite[name,state], 핵심 여부).
# 핵심(key)=seaweed/rice/danmuji — 누락 시 큰 감점 + consequence(§8.1).
const CORRECT_ITEMS := [
	{"id": "seaweed",  "label": "Seaweed",  "sprite": ["seaweed_sheet_rect", "roll"], "key": true},
	{"id": "rice",     "label": "Rice",     "sprite": ["rice_bowl", ""],              "key": true},
	{"id": "danmuji",  "label": "Danmuji",  "sprite": ["danmuji_strip", ""],          "key": true},
	{"id": "carrot",   "label": "Carrot",   "sprite": ["carrot_whole", ""],           "key": false},
	{"id": "egg",      "label": "Egg",      "sprite": ["egg_whole", ""],              "key": false},
	{"id": "spinach",  "label": "Spinach",  "sprite": ["spinach_cooked", ""],         "key": false},
]

# 함정(틀린) 재료 (id, label, sprite). matrix 김밥 banned — 매운 재료/면류/두부/떡.
const DISTRACTOR_ITEMS := [
	{"id": "ramyeon",   "label": "Ramyeon",   "sprite": ["noodle_raw", ""]},
	{"id": "gochujang", "label": "Gochujang", "sprite": ["gochujang_dollop", ""]},
	{"id": "tofu",      "label": "Tofu",      "sprite": ["tofu_block", ""]},
	{"id": "rice_cake", "label": "Tteok",     "sprite": ["rice_cake", ""]},
]

var _guest_id: String = ""
var _menu: Dictionary = {}
var _level: Dictionary = {}
var _step_no: int = 1
var _step_total: int = 1

var _collected: Array = []             # 수집한 정답 id
var _wrong_count: int = 0
var _time_left: float = SHOP_SECONDS
var _running: bool = false
var _shelf_tiles: Dictionary = {}      # id -> tile Control (그레이아웃/shake)
var _timer_lbl: Label = null
var _basket_lbl: Label = null
var _basket_slots: Control = null
var _done_btn: Button = null


## runner entry — module과 같은 start(params) 시그니처로 호출 가능.
func start(params: Dictionary) -> void:
	_guest_id = String(params.get("guest_id", ""))
	_menu = params.get("menu", {})
	_level = params.get("level", {})
	_step_no = int(params.get("step_no", 1))
	_step_total = int(params.get("step_total", 1))
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_PASS
	_build_ui()
	_running = true


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_PASS


func _process(delta: float) -> void:
	if not _running:
		return
	_time_left -= delta
	if is_instance_valid(_timer_lbl):
		_timer_lbl.text = "%0.0fs" % maxf(_time_left, 0.0)
		_timer_lbl.add_theme_color_override("font_color",
			Color(0.92, 0.40, 0.30) if _time_left < 6.0 else Color(0.99, 0.92, 0.78))
	if _time_left <= 0.0:
		_finish()   # 타임아웃 — 미수집 재료는 누락 처리(§8.1)


func _build_ui() -> void:
	# 시장 톤 backdrop (procedural 한식 시장 좌판). e-commerce UI 금지.
	var bg = MarketBG.new()
	bg.light = true
	add_child(bg)

	# 헤더 카드 — "Step n/m · Shop · Gimbap" + 안내.
	var card := Panel.new()
	card.position = Vector2(48, 40)
	card.size = Vector2(984, 150)
	var csb := StyleBoxFlat.new()
	csb.bg_color = Color(1.0, 0.985, 0.945, 0.94)
	csb.set_corner_radius_all(28)
	csb.set_border_width_all(3)
	csb.border_color = Color(0.93, 0.74, 0.32)
	csb.shadow_size = 10
	csb.shadow_color = Color(0.30, 0.20, 0.10, 0.32)
	card.add_theme_stylebox_override("panel", csb)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(card)
	var head := Label.new()
	head.text = "Step %d/%d  ·  Market  —  Pick Gimbap ingredients" % [_step_no, _step_total]
	head.position = Vector2(28, 20)
	head.size = Vector2(928, 50)
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.add_theme_font_size_override("font_size", 34)
	head.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(head)
	var sub := Label.new()
	sub.text = "Tap the right ingredients · avoid the wrong ones"
	sub.position = Vector2(28, 84)
	sub.size = Vector2(928, 44)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 26)
	sub.add_theme_color_override("font_color", Color(0.45, 0.32, 0.18))
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(sub)

	# 타이머 pill (우상단).
	var tpill := Panel.new()
	tpill.position = Vector2(840, 200)
	tpill.size = Vector2(192, 64)
	var tsb := StyleBoxFlat.new()
	tsb.bg_color = Color(0.30, 0.20, 0.12, 0.92)
	tsb.set_corner_radius_all(30)
	tsb.set_border_width_all(3)
	tsb.border_color = Color(0.95, 0.70, 0.18)
	tpill.add_theme_stylebox_override("panel", tsb)
	tpill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tpill)
	_timer_lbl = Label.new()
	_timer_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	_timer_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_timer_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_timer_lbl.text = "%0.0fs" % SHOP_SECONDS
	_timer_lbl.add_theme_font_size_override("font_size", 36)
	_timer_lbl.add_theme_color_override("font_color", Color(0.99, 0.92, 0.78))
	_timer_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tpill.add_child(_timer_lbl)

	# 시장 선반(좌판) — 정답+함정 섞어 그리드 진열. design §2.5 "선반에 재료 진열, 탭으로 장바구니".
	_build_shelf()
	# 장바구니 (하단) — 담긴 재료 슬롯 + count. design §10 Perfect/Bad 시각.
	_build_basket()
	# 완료 버튼 (early-finish — 타이머 여유 활용).
	_build_done_button()


# 정답+함정을 셔플해 좌판 그리드에 진열 (정답 위치를 표시하지 않음 — 변별 skill, design §2.3).
func _build_shelf() -> void:
	var items: Array = []
	for it in CORRECT_ITEMS:
		items.append({"data": it, "correct": true})
	for it in DISTRACTOR_ITEMS:
		items.append({"data": it, "correct": false})
	items.shuffle()
	var cols: int = 4
	var tile_w: float = 220.0
	var tile_h: float = 240.0
	var gap_x: float = 16.0
	var gap_y: float = 20.0
	var grid_w: float = float(cols) * tile_w + float(cols - 1) * gap_x
	var ox: float = (1080.0 - grid_w) * 0.5
	var oy: float = 300.0
	var shelf_holder := Control.new()
	shelf_holder.name = "ShelfHolder"
	add_child(shelf_holder)
	for i in range(items.size()):
		var entry: Dictionary = items[i]
		var col: int = i % cols
		var row: int = i / cols
		var pos := Vector2(ox + float(col) * (tile_w + gap_x), oy + float(row) * (tile_h + gap_y))
		var tile := _build_shelf_tile(entry["data"], bool(entry["correct"]), Rect2(pos, Vector2(tile_w, tile_h)))
		shelf_holder.add_child(tile)


func _build_shelf_tile(data: Dictionary, is_correct: bool, rect: Rect2) -> Control:
	# Panel backing(좌판 나무 트레이 card) — Button은 위에 투명 hitbox로 얹는다.
	var tile := Panel.new()
	tile.position = rect.position
	tile.size = rect.size
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.clip_contents = true   # sprite가 카드 밖으로 안 넘치게 clip.
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.99, 0.96, 0.90, 0.97)
	sb.set_corner_radius_all(24)
	sb.set_border_width_all(3)
	sb.border_color = Color(0.78, 0.58, 0.34)
	sb.shadow_size = 6
	sb.shadow_color = Color(0.30, 0.20, 0.10, 0.28)
	tile.add_theme_stylebox_override("panel", sb)
	# Issue 1 FIX (2026-06-12): 재료 sprite가 카드에 *또렷이* 보이도록 한다. 이전엔 expand_mode/
	#   custom_minimum_size를 texture 할당 *후*에 설정해, 1024px 원본이 custom_minimum_size를 박아
	#   sprite가 카드(clip_contents) 밖으로 넘쳐 거의 안 보였다 → 카드가 "텍스트만"으로 보이던 근본
	#   원인(vocabulary quiz 느낌). 이제 expand_mode/custom_minimum_size를 texture *전에* 설정해
	#   카드 안에 aspect-fit 한다(basket 아이콘과 동일 패턴).
	var sprite_spec: Array = data["sprite"]
	var path: String = _resolve_sprite(sprite_spec)
	if path != "":
		var tex := TextureRect.new()
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.custom_minimum_size = Vector2.ZERO
		tex.texture = load(path)
		tex.position = Vector2(20, 14)
		tex.size = Vector2(rect.size.x - 40, rect.size.y - 84)
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.add_child(tex)
	else:
		var dot := Panel.new()
		dot.position = Vector2(60, 30)
		dot.size = Vector2(rect.size.x - 120, rect.size.y - 110)
		var dsb := StyleBoxFlat.new()
		dsb.bg_color = Color(0.80, 0.62, 0.40)
		dsb.set_corner_radius_all(60)
		dot.add_theme_stylebox_override("panel", dsb)
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.add_child(dot)
	# 라벨 (icon-first + 영어 minimal — i18n 정책). 카드 하단 cream 밴드 위.
	var lbl := Label.new()
	lbl.text = String(data["label"])
	lbl.position = Vector2(0, rect.size.y - 56)
	lbl.size = Vector2(rect.size.x, 48)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 26)
	lbl.add_theme_color_override("font_color", Color(0.30, 0.20, 0.12))
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(lbl)
	# 투명 hitbox Button (카드 위 전체) — flat이라 자체 시각 없음, tap만 받음.
	var hit := Button.new()
	hit.flat = true
	hit.set_anchors_preset(Control.PRESET_FULL_RECT)
	hit.mouse_filter = Control.MOUSE_FILTER_STOP
	tile.add_child(hit)
	hit.pressed.connect(_on_tile_tapped.bind(data, is_correct, tile, hit))
	_shelf_tiles[String(data["id"])] = tile
	return tile


func _resolve_sprite(spec: Array) -> String:
	if spec.size() == 2 and String(spec[1]) == "roll":
		return ArtRegistry.get_roll_asset(String(spec[0]))
	var name: String = String(spec[0])
	var state: String = String(spec[1]) if spec.size() > 1 else ""
	return ArtRegistry.get_ingredient(name, state)


func _on_tile_tapped(data: Dictionary, is_correct: bool, tile: Control, hit: Button) -> void:
	if not _running:
		return
	var id: String = String(data["id"])
	if is_correct:
		if _collected.has(id):
			return   # 이미 담음 — 중복 무시.
		_collected.append(id)
		hit.disabled = true                          # tap 재입력 차단.
		tile.modulate = Color(0.72, 1.0, 0.72, 0.85) # 담김 = 초록 selected state.
		_mark_tile(tile, true)                       # Issue 1 — check(✓) 피드백.
		CookingFX.serving_sparkle(self, tile.global_position + tile.size * 0.5, 6)
		_update_basket()
		_safe_feedback(true, tile.global_position + tile.size * 0.5)
		if _collected.size() >= CORRECT_ITEMS.size():
			_finish()   # 모든 정답 수집 — 자동 완료.
	else:
		# 함정 — 빨간 shake + X 마크 + 시간 -1s + 감점.
		_wrong_count += 1
		_time_left = maxf(0.0, _time_left - WRONG_TIME_HIT)
		_shake(tile)
		_mark_tile(tile, false)                      # Issue 1 — wrong(X) 피드백.
		_safe_feedback(false, tile.global_position + tile.size * 0.5)


# Issue 1 — tap 후 카드에 check(✓, 정답) / X(오답) 피드백을 띄운다. 정답은 selected state로 남고,
# 오답은 잠깐 보였다 사라진다(basket 미추가). 텍스트를 못 읽어도 결과를 즉시 인지.
func _mark_tile(tile: Control, correct: bool) -> void:
	if shot_legacy_basket:
		return   # before 동작 — check/X badge 없음.
	var badge := Panel.new()
	badge.position = Vector2(tile.size.x - 64.0, 10.0)
	badge.size = Vector2(54, 54)
	var bsb := StyleBoxFlat.new()
	bsb.bg_color = Color(0.30, 0.72, 0.34) if correct else Color(0.86, 0.32, 0.26)
	bsb.set_corner_radius_all(27)
	bsb.set_border_width_all(3)
	bsb.border_color = Color(1, 1, 1, 0.92)
	bsb.shadow_size = 5
	bsb.shadow_color = Color(0, 0, 0, 0.30)
	badge.add_theme_stylebox_override("panel", bsb)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(badge)
	var mark := Label.new()
	mark.text = "✓" if correct else "✕"
	mark.set_anchors_preset(Control.PRESET_FULL_RECT)
	mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mark.add_theme_font_size_override("font_size", 36)
	mark.add_theme_color_override("font_color", Color.WHITE)
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_child(mark)
	badge.scale = Vector2(0.4, 0.4)
	badge.pivot_offset = badge.size * 0.5
	var tw := badge.create_tween()
	tw.tween_property(badge, "scale", Vector2(1.0, 1.0), 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if not correct:
		# 오답 X는 잠깐 보였다 사라진다(카드는 그대로 — 재시도 가능).
		tw.tween_interval(0.45)
		tw.tween_property(badge, "modulate:a", 0.0, 0.2)
		tw.tween_callback(badge.queue_free)


func _shake(node: Control) -> void:
	var orig: Vector2 = node.position
	node.modulate = Color(1.0, 0.55, 0.5)
	var tw := node.create_tween()
	tw.tween_property(node, "position:x", orig.x - 14.0, 0.05)
	tw.tween_property(node, "position:x", orig.x + 14.0, 0.05)
	tw.tween_property(node, "position:x", orig.x, 0.05)
	tw.tween_property(node, "modulate", Color.WHITE, 0.15)


func _build_basket() -> void:
	var basket := Panel.new()
	basket.position = Vector2(48, 1500)
	basket.size = Vector2(984, 320)
	var bsb := StyleBoxFlat.new()
	bsb.bg_color = Color(0.42, 0.28, 0.16, 0.92)
	bsb.set_corner_radius_all(28)
	bsb.set_border_width_all(4)
	bsb.border_color = Color(0.62, 0.42, 0.22)
	basket.add_theme_stylebox_override("panel", bsb)
	basket.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(basket)
	_basket_lbl = Label.new()
	_basket_lbl.position = Vector2(24, 12)
	_basket_lbl.size = Vector2(936, 44)
	_basket_lbl.add_theme_font_size_override("font_size", 30)
	_basket_lbl.add_theme_color_override("font_color", Color(0.99, 0.92, 0.78))
	_basket_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	basket.add_child(_basket_lbl)
	# 정답 슬롯(빈 칸 visible — 누락 재료를 design §2.5 Bad 시각으로 보여줌).
	_basket_slots = Control.new()
	_basket_slots.position = Vector2(24, 70)
	_basket_slots.size = Vector2(936, 230)
	_basket_slots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	basket.add_child(_basket_slots)
	_update_basket()


func _update_basket() -> void:
	if is_instance_valid(_basket_lbl):
		_basket_lbl.text = "Basket  %d / %d" % [_collected.size(), CORRECT_ITEMS.size()]
	# Issue 5 — Done enable는 필수 6 재료 전부 수집 시.
	if is_instance_valid(_done_btn):
		_style_done(_collected.size() >= CORRECT_ITEMS.size())
	if not is_instance_valid(_basket_slots):
		return
	for c in _basket_slots.get_children():
		c.queue_free()
	# CORRECT_ITEMS 순서대로 슬롯 — 담긴 것은 sprite, 누락은 빈 dashed 슬롯.
	var slot_w: float = 150.0
	var gap: float = 6.0
	for i in range(CORRECT_ITEMS.size()):
		var item: Dictionary = CORRECT_ITEMS[i]
		var id: String = String(item["id"])
		var sx: float = float(i) * (slot_w + gap)
		var slot := Panel.new()
		slot.position = Vector2(sx, 0)
		slot.size = Vector2(slot_w, 200)
		var ssb := StyleBoxFlat.new()
		var filled: bool = _collected.has(id)
		ssb.bg_color = Color(0.99, 0.96, 0.90, 0.16) if not filled else Color(0.99, 0.96, 0.90, 0.30)
		ssb.set_corner_radius_all(16)
		ssb.set_border_width_all(3)
		ssb.border_color = Color(0.62, 0.85, 0.50) if filled else Color(0.85, 0.70, 0.50, 0.55)
		slot.add_theme_stylebox_override("panel", ssb)
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_basket_slots.add_child(slot)
		# before 스크린샷 전용: legacy(빈 슬롯 "!"/"+" 마크 main 시각, filled만 sprite) 재현.
		if shot_legacy_basket:
			if filled:
				var p: String = _resolve_sprite(item["sprite"])
				if p != "":
					var tx := TextureRect.new()
					tx.texture = load(p)
					tx.set_anchors_preset(Control.PRESET_FULL_RECT)
					tx.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
					tx.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
					tx.mouse_filter = Control.MOUSE_FILTER_IGNORE
					slot.add_child(tx)
			else:
				var q0 := Label.new()
				q0.text = "!" if bool(item["key"]) else "+"
				q0.set_anchors_preset(Control.PRESET_FULL_RECT)
				q0.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				q0.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				q0.add_theme_font_size_override("font_size", 48)
				q0.add_theme_color_override("font_color",
					Color(0.92, 0.45, 0.30, 0.75) if bool(item["key"]) else Color(0.85, 0.72, 0.50, 0.55))
				q0.mouse_filter = Control.MOUSE_FILTER_IGNORE
				slot.add_child(q0)
			continue
		# Issue 5 — slot 안 ingredient 아이콘. filled = 또렷한 sprite(선택됨), empty = dim ghost
		#   sprite(아직 필요한 재료). ! 마크를 main 시각으로 쓰지 않는다 — 실제 ingredient 아이콘 표시.
		var path: String = _resolve_sprite(item["sprite"])
		if path != "":
			var tex := TextureRect.new()
			tex.texture = load(path)
			tex.set_anchors_preset(Control.PRESET_FULL_RECT)
			tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
			# empty slot = 흐릿한 회색 ghost(아직 안 담음). filled = full color(담김).
			tex.modulate = Color(1, 1, 1, 1.0) if filled else Color(0.45, 0.45, 0.45, 0.40)
			slot.add_child(tex)
		elif not filled:
			# sprite 미존재 fallback일 때만 작은 + 표시(핵심 재료 강조 ! 폐기).
			var q := Label.new()
			q.text = "+"
			q.set_anchors_preset(Control.PRESET_FULL_RECT)
			q.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			q.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			q.add_theme_font_size_override("font_size", 40)
			q.add_theme_color_override("font_color", Color(0.85, 0.72, 0.50, 0.45))
			q.mouse_filter = Control.MOUSE_FILTER_IGNORE
			slot.add_child(q)


func _build_done_button() -> void:
	_done_btn = Button.new()
	_done_btn.text = "Done"
	_done_btn.position = Vector2(440, 1840)
	_done_btn.size = Vector2(200, 64)
	_done_btn.add_theme_font_size_override("font_size", 32)
	_done_btn.focus_mode = Control.FOCUS_NONE
	_done_btn.pressed.connect(_on_done_pressed)
	add_child(_done_btn)
	_style_done(false)


# Issue 5 — Done은 6 필수 재료 전부 선택 전 disabled(gold↔grey), 6개 다 담으면 enabled.
func _style_done(enabled: bool) -> void:
	if not is_instance_valid(_done_btn):
		return
	_done_btn.disabled = not enabled
	var dsb := StyleBoxFlat.new()
	dsb.bg_color = Color(0.96, 0.62, 0.18) if enabled else Color(0.55, 0.50, 0.44, 0.85)
	dsb.set_corner_radius_all(32)
	_done_btn.add_theme_stylebox_override("normal", dsb)
	_done_btn.add_theme_stylebox_override("hover", dsb)
	_done_btn.add_theme_stylebox_override("pressed", dsb)
	_done_btn.add_theme_stylebox_override("disabled", dsb)
	_done_btn.add_theme_color_override("font_color",
		Color(0.20, 0.10, 0.04) if enabled else Color(0.85, 0.82, 0.78))
	_done_btn.add_theme_color_override("font_disabled_color", Color(0.85, 0.82, 0.78))


func _on_done_pressed() -> void:
	# 필수 6 재료 미수집이면 무시(버튼은 disabled라 정상 경로에선 닿지 않음).
	if _collected.size() < CORRECT_ITEMS.size():
		return
	_finish()


func _safe_feedback(good: bool, pos: Vector2) -> void:
	var fb := get_node_or_null("/root/FeedbackBus")
	if fb and fb.has_method("hit"):
		# FeedbackBus hit judgement: PERFECT/GOOD/MISS — good=PERFECT(0), wrong=MISS(2).
		fb.hit(0 if good else 2, pos)


# --- scoring + handoff ---

## design §2.4: shopping_quality = clamp01(correct/N - 0.15*wrong). 핵심 누락 추가 감점.
func _compute_quality() -> float:
	var n_correct: int = CORRECT_ITEMS.size()
	var ratio: float = float(_collected.size()) / float(maxi(1, n_correct))
	var q: float = ratio - WRONG_PENALTY * float(_wrong_count)
	# 핵심 재료(seaweed/rice/danmuji) 누락 = 큰 감점(§2.4 missing key penalty).
	for item in CORRECT_ITEMS:
		if bool(item["key"]) and not _collected.has(String(item["id"])):
			q -= 0.20
	return clampf(q, 0.0, 1.0)


func _finish() -> void:
	if not _running:
		return
	_running = false
	set_process(false)
	var q: float = _compute_quality()
	# §8.1 consequence hook — 수집한 정답 재료 id를 Pass B available filling으로 전달.
	var fillings: Array = _collected.duplicate()
	print("[shopping] collected=%s wrong=%d quality=%.2f fillings=%s" % [
		str(_collected), _wrong_count, q, str(fillings)])
	stage_completed.emit(q, fillings)
