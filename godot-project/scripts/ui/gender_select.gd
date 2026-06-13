## ChefSelect ("Choose Your Chef") — 플레이어 셰프 preset 선택 (최초 1회).
##
## Choose-Your-Chef 재설계 (2026-06-12): 성별 이분법(Female/Male) 폐기 → 이름·성격 preset 4종.
## 사용자 결정 "Female/Male 이분법 폐기 → 이름·성격 preset 4+". 게임 최초 진입 시(선택값 없을 때)
## 한 번 노출. 각 카드 = 셰프 아바타 미리보기 + 이름 + 성격 한 줄 + Choose CTA. 탭 시
## SaveManager.set_player_chef_preset()로 저장하고 name_entry로 진입.
##
##   Hana  (f)     — Calm & careful      (기존 chef_f 자산)
##   Joon  (m)     — Fast & bold         (기존 chef_m 자산)
##   Leo   (leo)   — Eager & humble      (외국인, leo_* 자산)
##   Amara (amara) — Confident & graceful(외국인, amara_* 자산)
##   Min   (min)   — Creative & balanced (신규, min_* 자산)
##   Ari   (ari)   — Cheerful & curious  (신규, ari_* 자산)
## (Choose-Your-Chef 6 preset — gimbap-visual-quality-rebuild 작업 2, 2026-06-13.)
##
## 진입 게이트는 menu_select가 _ready에서 검사 — 미선택이면 이 화면으로 redirect(안전망). scene
## 파일명은 gender_select.tscn 유지(라우팅 호환). 제약: scoring/economy/progression 무관. 저장은
## player_chef_gender 슬롯 1필드(backward-compat) — 기존 "f"/"m" save 그대로 보존. world BG는
## menu와 동일한 KitchenBackground(home kitchen) 위 layer — 손님 시스템 무변경.
extends Control

const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")
const DropShadowScript := preload("res://scripts/ui/premium/drop_shadow_panel.gd")
const GlossyButtonScript := preload("res://scripts/ui/premium/glossy_button.gd")

const W := 1080.0
const H := 1920.0

# 6 preset (이름 + 성격). 성별 카테고리 라벨 없음 — 이름·성격으로만 표현(i18n: 영어 minimal).
# preset = SaveManager 저장값(f/m/leo/amara/min/ari). tint = north star warm 톤 카드 액센트.
const PRESETS := [
	{"preset": "f", "name": "Hana", "trait": "Calm & careful",
		"tint": Color(0.86, 0.52, 0.34)},
	{"preset": "m", "name": "Joon", "trait": "Fast & bold",
		"tint": Color(0.34, 0.42, 0.58)},
	{"preset": "leo", "name": "Leo", "trait": "Eager & humble",
		"tint": Color(0.82, 0.55, 0.34)},
	{"preset": "amara", "name": "Amara", "trait": "Confident & graceful",
		"tint": Color(0.55, 0.40, 0.62)},
	{"preset": "min", "name": "Min", "trait": "Creative & balanced",
		"tint": Color(0.42, 0.58, 0.46)},
	{"preset": "ari", "name": "Ari", "trait": "Cheerful & curious",
		"tint": Color(0.90, 0.66, 0.30)},
]

# 3행 x 2열 카드 그리드 레이아웃 (1080x1920 세로 화면) — 6 preset.
const CARD_W := 460.0
const CARD_H := 484.0
const COL_X := [62.0, 558.0]              # 좌/우 열 x
const ROW_Y := [320.0, 832.0, 1344.0]     # 상/중/하 행 y


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	# world BG — 메뉴와 동일한 home kitchen 위에 host가 얹히는 정합(P0 world-integration).
	var bg = KitchenBackgroundScript.new()
	bg.fill_screen = true
	bg.dish_anchor_y = 1180.0
	bg.scrim_alpha = 0.22  # 카드/텍스트 가독성용 얇은 warm 막
	bg.env_key = "home"
	add_child(bg)

	# 헤더 — 따뜻한 나무 사인보드
	var sign := Panel.new()
	sign.position = Vector2(120, 96)
	sign.size = Vector2(840, 188)
	var ssb := StyleBoxFlat.new()
	ssb.bg_color = Color(0.36, 0.24, 0.15)
	ssb.set_corner_radius_all(28)
	ssb.set_border_width_all(5)
	ssb.border_color = Color(0.85, 0.66, 0.28)
	ssb.shadow_size = 16
	ssb.shadow_color = Color(0, 0, 0, 0.36)
	ssb.shadow_offset = Vector2(0, 8)
	sign.add_theme_stylebox_override("panel", ssb)
	add_child(sign)
	var title := Label.new()
	title.text = "Choose Your Chef"
	title.position = Vector2(0, 26)
	title.size = Vector2(840, 70)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 58)
	title.add_theme_color_override("font_color", Color(0.99, 0.92, 0.78))
	title.add_theme_color_override("font_outline_color", Color(0.20, 0.10, 0.04))
	title.add_theme_constant_override("outline_size", 3)
	sign.add_child(title)
	var sub := Label.new()
	sub.text = "This is you — the cook behind the counter."
	sub.position = Vector2(0, 108)
	sub.size = Vector2(840, 50)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 30)
	sub.add_theme_color_override("font_color", Color(0.92, 0.78, 0.50))
	sign.add_child(sub)

	# 6 preset 카드 (2열 x 3행 그리드).
	for i in range(PRESETS.size()):
		var col: int = i % 2
		var row: int = i / 2
		_make_chef_card(PRESETS[i], Vector2(COL_X[col], ROW_Y[row]))

	# 하단 안내
	var note := Label.new()
	note.text = "You can change this later in Settings."
	note.position = Vector2(0, 1850)
	note.size = Vector2(W, 50)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_font_size_override("font_size", 26)
	note.add_theme_color_override("font_color", Color(0.62, 0.50, 0.36))
	note.add_theme_color_override("font_outline_color", Color(0.20, 0.12, 0.06, 0.6))
	note.add_theme_constant_override("outline_size", 3)
	add_child(note)


# 셰프 선택 카드: 아바타 미리보기 + 이름 + 성격 한 줄 + "Choose" CTA. 성별 라벨 없음.
func _make_chef_card(info: Dictionary, pos: Vector2) -> void:
	var preset := String(info["preset"])
	var tint: Color = info["tint"]

	var card := Panel.new()
	card.position = pos
	card.size = Vector2(CARD_W, CARD_H)
	card.custom_minimum_size = Vector2(CARD_W, CARD_H)
	DropShadowScript.apply_to(card, Color(0.99, 0.97, 0.92), 32, 14, tint, 6)

	# 아바타 미리보기 plate (north star 톤 카드, warm glow)
	var plate := Panel.new()
	plate.position = Vector2(30, 28)
	plate.size = Vector2(CARD_W - 60.0, 280.0)
	var psb := StyleBoxFlat.new()
	psb.bg_color = Color(0.96, 0.92, 0.84)
	psb.set_corner_radius_all(24)
	psb.set_border_width_all(3)
	psb.border_color = tint.lightened(0.15)
	psb.shadow_size = 6
	psb.shadow_color = Color(0, 0, 0, 0.15)
	plate.add_theme_stylebox_override("panel", psb)
	plate.clip_contents = true  # chef bust를 plate 안으로 crop
	card.add_child(plate)
	# warm radial glow behind the chef
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 0.86, 0.55, 0.5))
	grad.set_color(1, Color(1.0, 0.86, 0.55, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(1.0, 0.5)
	gt.width = int(CARD_W - 88.0); gt.height = 256
	var glow := TextureRect.new()
	glow.texture = gt
	glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(glow)

	# 실제 chef 아바타 (neutral) — 선택 미리보기. COVERED + clip_contents로 bust가 plate를 채운다.
	var av := TextureRect.new()
	av.set_anchors_preset(Control.PRESET_FULL_RECT)
	av.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	av.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	av.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var av_path := ArtRegistry.get_protagonist(preset, "neutral")
	if av_path != "" and ResourceLoader.exists(av_path):
		av.texture = load(av_path)
	plate.add_child(av)

	# 이름 (성별 라벨 폐기 — 이름이 정체성)
	var nm := Label.new()
	nm.text = String(info["name"])
	nm.position = Vector2(0, 318)
	nm.size = Vector2(CARD_W, 50)
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nm.add_theme_font_size_override("font_size", 42)
	nm.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	card.add_child(nm)
	# 성격 한 줄
	var trait_lbl := Label.new()
	trait_lbl.text = String(info["trait"])
	trait_lbl.position = Vector2(16, 372)
	trait_lbl.size = Vector2(CARD_W - 32, 36)
	trait_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	trait_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	trait_lbl.add_theme_font_size_override("font_size", 26)
	trait_lbl.add_theme_color_override("font_color", Color(0.52, 0.42, 0.32))
	card.add_child(trait_lbl)

	# Choose CTA (glossy)
	var cta = GlossyButtonScript.new()
	cta.position = Vector2(30, 414)
	cta.size = Vector2(CARD_W - 60.0, 56)
	cta.custom_minimum_size = Vector2(CARD_W - 60.0, 56)
	card.add_child(cta)
	cta.setup("Choose", tint, 30, 20)
	_wire_choose(cta, preset)

	add_child(card)


func _wire_choose(gb: Control, preset: String) -> void:
	if not is_inside_tree():
		return
	await get_tree().process_frame
	if gb == null or not is_instance_valid(gb):
		return
	if gb.get("button") == null:
		await get_tree().process_frame
	var btn: Button = gb.get("button")
	if btn != null:
		btn.pressed.connect(func() -> void: _on_choose(preset))


func _on_choose(preset: String) -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("set_player_chef_preset"):
		sm.set_player_chef_preset(preset)
	elif sm and sm.has_method("set_player_chef_gender"):
		sm.set_player_chef_gender(preset)  # backward-compat alias
	# 선택 후 이름 입력 화면으로(name_entry가 menu로 진입시킨다).
	get_tree().change_scene_to_file("res://scenes/name_entry.tscn")
