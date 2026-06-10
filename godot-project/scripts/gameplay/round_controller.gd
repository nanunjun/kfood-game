## RoundController — W1 라면 수직 슬라이스 라운드 오케스트레이터.
##
## FoodDefinition(.tres) 1개를 받아 Stage 2A(prep) → 2B(method) → 2C(timing) → 결과를 순차 실행.
## 가중 평균(prep 0.20 / method 0.30 / timing 0.50)으로 1~3 별 산출.
## UI는 각 Stage가 절차적 생성 (Godot Editor 없이 검증 가능). Scene 1/3는 본 슬라이스에서 간략화.
##
## 사용: 본 스크립트를 Node2D 루트에 attach + main scene 지정. food_path로 음식 교체.
## 참조: docs/systems/cooking-mechanics.md, docs/ui/scene-2-kitchen-layout.md, docs/balance-config.md
class_name RoundController
extends Node2D

## 음식 선택 메뉴 → 라운드 전달용 (씬 전환 시 인자 전달 대체).
static var pending_food_path: String = ""

## 순차(Easy→Hard) 플레이 큐 (food .tres 경로 순서). 단일 플레이 시 빈 배열.
static var sequence: Array = []

## 라운드 음식 resource (기본 = 라면 t1_002). pending_food_path가 있으면 우선.
@export var food_path: String = "res://resources/foods/t1_002.tres"

## 스테이지 클래스를 class_name 전역 해석 대신 preload로 직접 로드 (전역 클래스 캐시 desync 회피).
const StageIntroScene := preload("res://scripts/gameplay/stage_intro.gd")
const StageShopScene := preload("res://scripts/gameplay/stage_shop.gd")
const StagePrepScene := preload("res://scripts/gameplay/stage_prep.gd")
const StageMethodScene := preload("res://scripts/gameplay/stage_method.gd")
const StageTimingScene := preload("res://scripts/gameplay/stage_timing.gd")
const ResultScreenScene := preload("res://scripts/gameplay/result_screen.gd")

# 스프라이트 경로는 ArtRegistry(자동 생성) 사용 — W2에서 12음식 일반화.

# 가중치 (cooking-mechanics §5)
const W_PREP := 0.20
const W_METHOD := 0.30
const W_TIMING := 0.50

# 장보기 디스트랙터 풀 (name = 영어, food = 스프라이트 출처 food_id). W1 간이.
const DISTRACTOR_POOL := [
	{"name": "Carrot", "food": "t2_008"},
	{"name": "Tofu", "food": "t2_013"},
	{"name": "Garlic", "food": "t2_012"},
	{"name": "Fish Cake", "food": "t1_003"},
	{"name": "Green Onion", "food": "t1_002"},
]

var _food: FoodDefinition
var _layer: CanvasLayer
var _bg: TextureRect
var _acc_prep: float = 0.0
var _acc_method: float = 0.0
var _acc_timing: float = 0.0


func _ready() -> void:
	randomize()
	if pending_food_path != "":
		food_path = pending_food_path
	_food = _load_food(food_path)
	if _food == null:
		push_error("[RoundController] FoodDefinition 로드 실패: %s" % food_path)
		return
	_layer = CanvasLayer.new()
	add_child(_layer)
	var grad := Gradient.new()
	grad.set_color(0, UITheme.CREAM_TOP)
	grad.set_color(1, UITheme.CREAM_BOT)
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.width = 256
	gt.height = 512
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	_bg = TextureRect.new()
	_bg.texture = gt
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.size = Vector2(1080, 1920)
	_bg.stretch_mode = TextureRect.STRETCH_SCALE
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE  # 배경이 탭 가로채지 않도록
	_layer.add_child(_bg)
	_start_round()


func _start_round() -> void:
	_acc_prep = 0.0
	_acc_method = 0.0
	_acc_timing = 0.0
	AudioManager.play(&"sting_start")
	_run_stages()


func _run_stages() -> void:
	# --- Scene 0: 요리 소개 (외국 플레이어용 — 큰 이미지 + 설명) ---5
	var intro := StageIntroScene.new()
	intro.theme = UITheme.make_theme()
	intro.setup(_food.food_id, _food.name_en, _food.name_ko)
	_layer.add_child(intro)
	await intro.finished
	intro.queue_free()

	# --- Scene 1: 장보기 (다중 선택, ShoppingRegistry) ---
	var shop := StageShopScene.new()
	shop.theme = UITheme.make_theme()
	shop.setup(_food.name_en, _food.food_id)
	_layer.add_child(shop)
	await shop.finished  # W1: 게이트 (별점 미반영)
	shop.queue_free()

	# --- Stage 2A: 재료 준비 ---
	var prep := StagePrepScene.new()
	prep.theme = UITheme.make_theme()
	prep.setup(_food.prep_bpm, _food.prep_taps,
		ArtRegistry.prep_whole(_food.food_id), ArtRegistry.prep_cut(_food.food_id),
		_food.difficulty_score)
	_layer.add_child(prep)
	_acc_prep = await prep.finished
	prep.queue_free()

	# --- Stage 2B: 조리 방법 ---
	var method := StageMethodScene.new()
	method.theme = UITheme.make_theme()
	var opts: Array = []
	for m in _food.method_options:
		opts.append(String(m))
	if opts.is_empty():
		opts = [String(_food.correct_method_id)]
	method.setup(opts, String(_food.correct_method_id))
	_layer.add_child(method)
	_acc_method = await method.finished
	method.queue_free()

	# --- Stage 2C: 조리 시간 ---
	# 조리 ambient cue (조리법별): 끓이기 = 보글, 그 외 = 쓱(볶기/부치기 등)
	AudioManager.play(&"act_boil" if String(_food.correct_method_id) == "boil" else &"act_stir")
	var timing := StageTimingScene.new()
	timing.theme = UITheme.make_theme()
	timing.setup(_food.cook_time_sec, ArtRegistry.food(_food.food_id),
		ArtRegistry.method_tool(_food.correct_method_id), _food.difficulty_score,
		String(_food.correct_method_id), ArtRegistry.prep_cut(_food.food_id),
		ShoppingRegistry.correct(_food.food_id).size())
	_layer.add_child(timing)
	_acc_timing = await timing.finished
	timing.queue_free()

	AudioManager.play(&"act_done")  # 완성 종
	_show_result()


func _show_result() -> void:
	var score: float = _acc_prep * W_PREP + _acc_method * W_METHOD + _acc_timing * W_TIMING
	var stars := 1
	if score >= 0.92:
		stars = 3
	elif score >= 0.72:
		stars = 2
	var new_best := SaveManager.record_result(_food.food_id, stars)  # 누적·해금 저장
	var next_path := _next_food_path()
	var res := ResultScreenScene.new()
	res.theme = UITheme.make_theme()
	res.setup(stars, score, {
		"prep": _acc_prep, "method": _acc_method, "timing": _acc_timing,
	}, _food.name_en, ArtRegistry.food(_food.food_id), next_path != "", new_best)
	res.retry_pressed.connect(func() -> void:
		res.queue_free()
		_start_round()
	)
	res.next_pressed.connect(func() -> void:
		pending_food_path = next_path
		get_tree().change_scene_to_file("res://scenes/round_demo.tscn")
	)
	_layer.add_child(res)


## 순차 모드에서 현재 음식 다음 경로 (없으면 "").
func _next_food_path() -> String:
	var cur := food_path
	var i := sequence.find(cur)
	if i >= 0 and i + 1 < sequence.size():
		return String(sequence[i + 1])
	return ""


func _load_food(path: String) -> FoodDefinition:
	if path != "" and ResourceLoader.exists(path):
		return load(path) as FoodDefinition
	return null


func _ingredient_name(ing_id: String) -> String:
	var p := "res://resources/ingredients/%s.tres" % ing_id
	if ResourceLoader.exists(p):
		var ing := load(p) as IngredientDefinition
		if ing != null and ing.name_en != "":
			return ing.name_en
	return ing_id
