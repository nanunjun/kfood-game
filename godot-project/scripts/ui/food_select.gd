## FoodSelect — 음식 선택 + A2 진행도(누적 별 / 해금 / 도감).
##
## tier·difficulty 오름차순 정렬. 이전 음식 클리어(별 1+) 시 다음 해금. 음식별 최고 별점 표시(도감).
## 상단에 누적 별. "Play in Order"는 첫 미클리어 해금 음식부터.
## 참조: docs/design/progression-and-variety-v0.1.md (A2)
extends Control

const FOOD_IDS := [
	"t1_002", "t1_003", "t1_004", "t1_005", "t1_006", "t1_007",
	"t1_008", "t2_008", "t2_010", "t2_012", "t2_013", "t2_014",
]
const ROUND_SCENE := "res://scenes/round_demo.tscn"
const DARK := Color(0.17, 0.11, 0.08)

var _sorted_paths: Array = []


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = UITheme.make_theme()
	UITheme.add_background(self)

	var title := Label.new()
	title.text = "K-Food Master"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 80)
	title.size = Vector2(1080, 90)
	title.add_theme_font_size_override("font_size", 58)
	title.add_theme_color_override("font_color", DARK)
	add_child(title)

	var max_stars := FOOD_IDS.size() * 3
	var stars := Label.new()
	stars.text = "★ %d / %d" % [SaveManager.total_stars, max_stars]
	stars.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stars.position = Vector2(0, 158)
	stars.size = Vector2(1080, 52)
	stars.add_theme_font_size_override("font_size", 38)
	stars.add_theme_color_override("font_color", Color(0.85, 0.6, 0.1))
	add_child(stars)

	# 진행도 바 (누적 별)
	var track := ColorRect.new()
	track.color = Color(0.0, 0.0, 0.0, 0.12)
	track.position = Vector2(240, 218)
	track.size = Vector2(600, 22)
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(track)
	var fill := ColorRect.new()
	fill.color = Color(0.96, 0.66, 0.12)
	var frac: float = float(SaveManager.total_stars) / float(max(1, max_stars))
	fill.position = Vector2(240, 218)
	fill.size = Vector2(600.0 * frac, 22)
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fill)

	# 성과 통계
	var stat := Label.new()
	stat.text = "Dishes %d/%d   ·   3★ %d/%d" % [
		SaveManager.cleared_count(), FOOD_IDS.size(),
		SaveManager.three_star_count(), FOOD_IDS.size()]
	stat.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stat.position = Vector2(0, 248)
	stat.size = Vector2(1080, 44)
	stat.add_theme_font_size_override("font_size", 30)
	stat.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08, 0.8))
	add_child(stat)

	# 정렬 + 해금 판정
	var entries: Array = []
	for fid in FOOD_IDS:
		var path := "res://resources/foods/%s.tres" % fid
		if not ResourceLoader.exists(path):
			continue
		var fdef := load(path) as FoodDefinition
		if fdef != null:
			entries.append({"fid": fid, "path": path, "def": fdef})
	entries.sort_custom(func(a, b):
		var da: FoodDefinition = a["def"]
		var db: FoodDefinition = b["def"]
		if da.tier != db.tier:
			return da.tier < db.tier
		return da.difficulty_score < db.difficulty_score
	)
	_sorted_paths = []
	for e in entries:
		_sorted_paths.append(e["path"])

	# 첫 미클리어 해금 음식 인덱스 (Play in Order 시작점)
	var first_idx := 0
	var prev_cleared := true
	for i in range(entries.size()):
		var fid: StringName = entries[i]["fid"]
		var unlocked: bool = (i == 0) or prev_cleared
		entries[i]["unlocked"] = unlocked
		if unlocked and not SaveManager.is_cleared(fid):
			first_idx = i
			break
		prev_cleared = SaveManager.is_cleared(fid)
	# 해금 플래그 재계산(전체)
	prev_cleared = true
	for i in range(entries.size()):
		entries[i]["unlocked"] = (i == 0) or prev_cleared
		prev_cleared = SaveManager.is_cleared(entries[i]["fid"])

	var play := Button.new()
	play.text = "▶  Play in Order"
	play.position = Vector2(290, 312)
	play.size = Vector2(500, 84)
	play.add_theme_font_size_override("font_size", 36)
	play.pressed.connect(func() -> void:
		AudioManager.play(&"sting_start")
		RoundController.sequence = _sorted_paths
		RoundController.pending_food_path = String(_sorted_paths[first_idx])
		get_tree().change_scene_to_file(ROUND_SCENE)
	)
	add_child(play)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 40)
	grid.add_theme_constant_override("v_separation", 26)
	grid.position = Vector2(90, 420)
	grid.size = Vector2(900, 1400)
	add_child(grid)

	for e in entries:
		var fdef: FoodDefinition = e["def"]
		var fid: StringName = e["fid"]
		var unlocked: bool = e["unlocked"]
		var b := Button.new()
		b.custom_minimum_size = Vector2(420, 165)
		b.add_theme_font_size_override("font_size", 32)
		if unlocked:
			var bs := SaveManager.best_of(fid)
			var stars_str := "★".repeat(bs) + "☆".repeat(3 - bs)
			b.text = "%s\n%s" % [fdef.name_en, stars_str]
			b.pressed.connect(_on_food.bind(e["path"]))
		else:
			b.text = "%s\n[ Locked — clear previous ]" % fdef.name_en
			b.disabled = true
		grid.add_child(b)


func _on_food(path: String) -> void:
	AudioManager.play(&"ui_select")
	RoundController.sequence = _sorted_paths
	RoundController.pending_food_path = path
	get_tree().change_scene_to_file(ROUND_SCENE)
