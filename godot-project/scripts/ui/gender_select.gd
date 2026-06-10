## GenderSelect — 플레이어 셰프 성별 선택 (최초 1회).
##
## Player-Chef Integration (2026-06-08): 게임 최초 진입 시(저장된 성별이 없을 때) 한 번 노출되는
## "당신의 셰프를 고르세요" 화면. 여(f) / 남(m) 2개의 큰 카드(실제 chef 아바타 미리보기) 중
## 하나를 탭하면 SaveManager.set_player_chef_gender()로 저장하고 Recipe Board(menu_select)로 진입.
##
## 진입 게이트는 menu_select가 _ready에서 검사 — 미선택이면 이 화면으로 redirect(아래 main 흐름과
## 별개로 안전망). 이 화면은 직접 main_scene로 두지 않고, menu_select가 게이트로 라우팅한다.
##
## 제약: scoring/economy/progression 무관. 저장은 player_chef_gender 1필드만. world BG는 menu와
## 동일한 KitchenBackground(home kitchen) 위 layer — 손님 시스템 무변경.
extends Control

const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")
const DropShadowScript := preload("res://scripts/ui/premium/drop_shadow_panel.gd")
const GlossyButtonScript := preload("res://scripts/ui/premium/glossy_button.gd")

const W := 1080.0
const H := 1920.0

# 카드 정체성 설명 (north star 톤). 여/남.
# Player-Name Personalization (2026-06-08): 카드 라벨은 guest 이름(Mina/Junho)이 아닌 성별
# 설명으로 표기 — guest 7명과 충돌 방지. 주인공 이름은 다음 화면(name_entry)에서 직접 입력.
const CHEF_F := {
	"gender": "f", "title": "Female Chef", "kr": "여자 셰프",
	"desc": "Cream jacket · terracotta apron",
	"tint": Color(0.86, 0.52, 0.34),
}
const CHEF_M := {
	"gender": "m", "title": "Male Chef", "kr": "남자 셰프",
	"desc": "Navy jacket · sand apron",
	"tint": Color(0.34, 0.42, 0.58),
}


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	# world BG — 메뉴와 동일한 home kitchen 위에 host가 얹히는 정합(P0 world-integration).
	var bg = KitchenBackgroundScript.new()
	bg.fill_screen = true
	bg.dish_anchor_y = 1180.0
	bg.scrim_alpha = 0.20  # 카드/텍스트 가독성용 얇은 warm 막
	bg.env_key = "home"
	add_child(bg)

	# 헤더 — 따뜻한 나무 사인보드
	var sign := Panel.new()
	sign.position = Vector2(120, 120)
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

	# 2 카드 (여 / 남), 화면 중앙에 나란히
	_make_chef_card(CHEF_F, Vector2(70, 400))
	_make_chef_card(CHEF_M, Vector2(560, 400))

	# 하단 안내
	var note := Label.new()
	note.text = "You can change this later in Settings."
	note.position = Vector2(0, 1560)
	note.size = Vector2(W, 50)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_font_size_override("font_size", 26)
	note.add_theme_color_override("font_color", Color(0.55, 0.42, 0.28))
	add_child(note)


# 셰프 선택 카드: 큰 아바타 미리보기 + 정체성 라벨 + "Choose" CTA. 카드 전체가 탭 가능.
func _make_chef_card(info: Dictionary, pos: Vector2) -> void:
	var gender := String(info["gender"])
	var tint: Color = info["tint"]

	var card := Panel.new()
	card.position = pos
	card.size = Vector2(450, 1080)
	card.custom_minimum_size = Vector2(450, 1080)
	DropShadowScript.apply_to(card, Color(0.99, 0.97, 0.92), 36, 16, tint, 6)

	# 아바타 미리보기 plate (north star 톤 카드, warm glow)
	var plate := Panel.new()
	plate.position = Vector2(40, 56)
	plate.size = Vector2(370, 640)
	var psb := StyleBoxFlat.new()
	psb.bg_color = Color(0.96, 0.92, 0.84)
	psb.set_corner_radius_all(26)
	psb.set_border_width_all(3)
	psb.border_color = tint.lightened(0.15)
	psb.shadow_size = 6
	psb.shadow_color = Color(0, 0, 0, 0.15)
	plate.add_theme_stylebox_override("panel", psb)
	plate.clip_contents = true  # chef bust를 plate 안으로 crop (landscape 빈 여백 제거)
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
	gt.width = 340; gt.height = 600
	var glow := TextureRect.new()
	glow.texture = gt
	glow.position = Vector2(15, 20)
	glow.size = Vector2(340, 600)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(glow)

	# 실제 chef 아바타 (neutral) — 선택 미리보기. COVERED로 chef bust가 plate를 채운다(상체 집중).
	# FULL_RECT anchor + COVERED + plate.clip_contents (수동 size+COVERED는 미렌더 버그라 anchor 사용).
	var av := TextureRect.new()
	av.set_anchors_preset(Control.PRESET_FULL_RECT)
	av.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	av.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	av.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var av_path := ArtRegistry.get_protagonist(gender, "neutral")
	if av_path != "" and ResourceLoader.exists(av_path):
		av.texture = load(av_path)
	plate.add_child(av)

	# 이름 + 한국어 라벨
	var nm := Label.new()
	nm.text = String(info["title"])
	nm.position = Vector2(0, 720)
	nm.size = Vector2(450, 56)
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nm.add_theme_font_size_override("font_size", 44)
	nm.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	card.add_child(nm)
	var kr := Label.new()
	kr.text = String(info["kr"])
	kr.position = Vector2(0, 784)
	kr.size = Vector2(450, 44)
	kr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	kr.add_theme_font_size_override("font_size", 32)
	kr.add_theme_color_override("font_color", Color(0.45, 0.32, 0.20))
	card.add_child(kr)
	var desc := Label.new()
	desc.text = String(info["desc"])
	desc.position = Vector2(20, 840)
	desc.size = Vector2(410, 60)
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 26)
	desc.add_theme_color_override("font_color", Color(0.52, 0.45, 0.38))
	card.add_child(desc)

	# Choose CTA (glossy) — 카드 전체 탭과 별개로 명확한 버튼
	var cta = GlossyButtonScript.new()
	cta.position = Vector2(40, 936)
	cta.size = Vector2(370, 96)
	cta.custom_minimum_size = Vector2(370, 96)
	card.add_child(cta)
	cta.setup("Choose", tint, 36, 26)
	_wire_choose(cta, gender)

	add_child(card)


func _wire_choose(gb: Control, gender: String) -> void:
	if not is_inside_tree():
		return
	await get_tree().process_frame
	if gb == null or not is_instance_valid(gb):
		return
	if gb.get("button") == null:
		await get_tree().process_frame
	var btn: Button = gb.get("button")
	if btn != null:
		btn.pressed.connect(func() -> void: _on_choose(gender))


func _on_choose(gender: String) -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("set_player_chef_gender"):
		sm.set_player_chef_gender(gender)
	# Player-Name Personalization (2026-06-08): 성별 선택 후 이름 입력 화면으로.
	# 이름이 이미 있으면(설정에서 재진입) name_entry가 곧장 통과시켜도 무방하지만, 최초 1회
	# 흐름은 gender → name_entry → menu. name_entry가 menu로 진입시킨다.
	get_tree().change_scene_to_file("res://scenes/name_entry.tscn")
