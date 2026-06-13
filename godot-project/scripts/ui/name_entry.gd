## NameEntry — 플레이어가 본인 셰프 이름을 직접 입력 (최초 1회).
##
## Player-Name Personalization (2026-06-08): gender select 직후 한 번 노출되는 "당신의 셰프
## 이름을 정하세요" 화면. 선택한 셰프(neutral) 미리보기 + LineEdit 이름 입력 + Confirm CTA.
##
## 흐름: gender_select → (name 미입력) → name_entry → menu. menu_select가 _ready 게이트에서
## has_chosen_chef() && has_player_name() 둘 다 충족해야 메뉴 렌더 — 성별만 있고 이름이 없으면
## 이 화면으로 redirect(안전망). 이 화면은 gender 선택 후에만 의미가 있으므로, gender 미선택이면
## gender_select로 되돌린다.
##
## 입력 검증: 빈 값/공백 → 기본명 fallback("My Chef"). 최대 12자. trim + 내부 공백 squash만(과한
## 욕설 필터 없음 — SaveManager.sanitize_player_name). 모바일 가상 키보드는 LineEdit 포커스 시
## OS가 자동 노출(Godot 4.6 Android virtual_keyboard_enabled 기본 true).
##
## 제약: scoring/CSV/economy/progression 무관. 저장은 player_name 1필드만. guest 7명 무변경.
extends Control

const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")
const DropShadowScript := preload("res://scripts/ui/premium/drop_shadow_panel.gd")
const GlossyButtonScript := preload("res://scripts/ui/premium/glossy_button.gd")

const W := 1080.0
const H := 1920.0
const NAME_MAX := 12

var _name_edit: LineEdit = null
var _hint: Label = null

# Choose-Your-Chef 재설계 (2026-06-12): preset id → warm tint (gender 이분법 폐기).
const PRESET_TINT := {
	"f": Color(0.86, 0.52, 0.34), "m": Color(0.34, 0.42, 0.58),
	"leo": Color(0.82, 0.55, 0.34), "amara": Color(0.55, 0.40, 0.62),
}

static func _tint_for(preset: String) -> Color:
	return PRESET_TINT.get(preset, Color(0.86, 0.52, 0.34))


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var sm := get_node_or_null("/root/SaveManager")
	# gender 미선택이면 이 화면은 의미 없음 — gender select로 되돌린다(흐름 안전망).
	if sm and sm.has_method("has_chosen_chef") and not sm.has_chosen_chef():
		call_deferred("_redirect_to_gender_select")
		return

	# world BG — gender select / menu와 동일한 home kitchen 위 layer(P0 world-integration).
	var bg = KitchenBackgroundScript.new()
	bg.fill_screen = true
	bg.dish_anchor_y = 1180.0
	bg.scrim_alpha = 0.22  # 카드/입력 가독성용 얇은 warm 막
	bg.env_key = "home"
	add_child(bg)

	# 헤더 — gender select와 동일 톤의 나무 사인보드
	var sign := Panel.new()
	sign.position = Vector2(120, 110)
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
	title.text = "Name Your Chef"
	title.position = Vector2(0, 26)
	title.size = Vector2(840, 70)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 58)
	title.add_theme_color_override("font_color", Color(0.99, 0.92, 0.78))
	title.add_theme_color_override("font_outline_color", Color(0.20, 0.10, 0.04))
	title.add_theme_constant_override("outline_size", 3)
	sign.add_child(title)
	var sub := Label.new()
	sub.text = "What should we call you in the kitchen?"
	sub.position = Vector2(0, 108)
	sub.size = Vector2(840, 50)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 30)
	sub.add_theme_color_override("font_color", Color(0.92, 0.78, 0.50))
	sign.add_child(sub)

	# 선택한 셰프 미리보기 카드 (chef select 톤과 정합)
	var preset: String = sm.player_chef_preset() if (sm and sm.has_method("player_chef_preset")) else "f"
	_build_chef_preview(preset, Vector2(315, 360))

	# 이름 입력 필드 (LineEdit) — 모바일 가상 키보드 자동 노출
	_build_name_input(Vector2(140, 1110))

	# Confirm CTA (glossy)
	var tint: Color = _tint_for(preset)
	var cta = GlossyButtonScript.new()
	cta.position = Vector2(290, 1320)
	cta.size = Vector2(500, 110)
	cta.custom_minimum_size = Vector2(500, 110)
	add_child(cta)
	cta.setup("Start Cooking", Color(0.86, 0.46, 0.20), 40, 30)
	_wire_confirm(cta)

	# 하단 안내 — gender select와 동일 톤
	var note := Label.new()
	note.text = "You can change this later in Settings."
	note.position = Vector2(0, 1560)
	note.size = Vector2(W, 50)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_font_size_override("font_size", 26)
	note.add_theme_color_override("font_color", Color(0.55, 0.42, 0.28))
	add_child(note)


# 선택한 셰프(neutral) bust 미리보기 — chef select 카드 plate 톤과 정합. 작게(가운데 위).
func _build_chef_preview(preset: String, pos: Vector2) -> void:
	var tint: Color = _tint_for(preset)
	var plate := Panel.new()
	plate.position = pos
	plate.size = Vector2(450, 560)
	var psb := StyleBoxFlat.new()
	psb.bg_color = Color(0.96, 0.92, 0.84)
	psb.set_corner_radius_all(28)
	psb.set_border_width_all(4)
	psb.border_color = tint.lightened(0.15)
	psb.shadow_size = 14
	psb.shadow_color = Color(0, 0, 0, 0.28)
	psb.shadow_offset = Vector2(0, 8)
	plate.add_theme_stylebox_override("panel", psb)
	plate.clip_contents = true
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(plate)
	# warm radial glow behind the chef
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 0.86, 0.55, 0.5))
	grad.set_color(1, Color(1.0, 0.86, 0.55, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(1.0, 0.5)
	gt.width = 420; gt.height = 520
	var glow := TextureRect.new()
	glow.texture = gt
	glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(glow)
	# chef avatar — FULL_RECT anchor + COVERED + plate.clip_contents (수동 size+COVERED는 미렌더 버그)
	var av := TextureRect.new()
	av.set_anchors_preset(Control.PRESET_FULL_RECT)
	av.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	av.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	av.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var av_path := ArtRegistry.get_protagonist(preset, "neutral")
	if av_path != "" and ResourceLoader.exists(av_path):
		av.texture = load(av_path)
	plate.add_child(av)
	# "This is you" 캡션 칩
	var chip := Label.new()
	chip.text = "This is you"
	chip.position = Vector2(0, 580)
	chip.size = Vector2(450, 42)
	chip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chip.add_theme_font_size_override("font_size", 30)
	chip.add_theme_color_override("font_color", Color(0.99, 0.92, 0.78))
	chip.add_theme_color_override("font_outline_color", Color(0.20, 0.10, 0.04))
	chip.add_theme_constant_override("outline_size", 3)
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(chip)


# 이름 입력 필드. LineEdit 포커스 시 모바일 가상 키보드 자동 노출(Godot 4.6 Android).
func _build_name_input(pos: Vector2) -> void:
	var le := LineEdit.new()
	le.position = pos
	le.size = Vector2(800, 96)
	le.placeholder_text = "Chef name (e.g. My Chef)"
	le.max_length = NAME_MAX
	le.alignment = HORIZONTAL_ALIGNMENT_CENTER
	le.virtual_keyboard_enabled = true  # Android 가상 키보드 명시
	le.clear_button_enabled = true
	le.add_theme_font_size_override("font_size", 40)
	# warm 입력 박스 스타일 (north star 톤)
	var nsb := StyleBoxFlat.new()
	nsb.bg_color = Color(0.99, 0.97, 0.92)
	nsb.set_corner_radius_all(22)
	nsb.set_border_width_all(4)
	nsb.border_color = Color(0.85, 0.66, 0.28)
	nsb.shadow_size = 10
	nsb.shadow_color = Color(0, 0, 0, 0.22)
	nsb.shadow_offset = Vector2(0, 5)
	nsb.content_margin_left = 24
	nsb.content_margin_right = 24
	le.add_theme_stylebox_override("normal", nsb)
	var fsb := nsb.duplicate()
	fsb.border_color = Color(0.86, 0.46, 0.20)
	le.add_theme_stylebox_override("focus", fsb)
	le.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	le.add_theme_color_override("font_placeholder_color", Color(0.55, 0.45, 0.36))
	le.add_theme_color_override("caret_color", Color(0.86, 0.46, 0.20))
	le.text_submitted.connect(func(_t: String) -> void: _on_confirm())
	add_child(le)
	_name_edit = le

	# 입력 가이드 (글자수/fallback 안내)
	var hint := Label.new()
	hint.text = "Up to %d characters. Leave blank to use \"My Chef\"." % NAME_MAX
	hint.position = Vector2(140, 1212)
	hint.size = Vector2(800, 44)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 24)
	hint.add_theme_color_override("font_color", Color(0.60, 0.48, 0.34))
	add_child(hint)
	_hint = hint


func _wire_confirm(gb: Control) -> void:
	if not is_inside_tree():
		return
	await get_tree().process_frame
	if gb == null or not is_instance_valid(gb):
		return
	if gb.get("button") == null:
		await get_tree().process_frame
	var btn: Button = gb.get("button")
	if btn != null:
		btn.pressed.connect(_on_confirm)


func _on_confirm() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	var raw: String = _name_edit.text if _name_edit != null else ""
	if sm and sm.has_method("set_player_name"):
		# 빈/공백 입력 → fallback 기본명("My Chef")으로 저장(name entry 재진입 방지).
		if not sm.set_player_name(raw):
			sm.set_player_name(sm.PLAYER_NAME_FALLBACK)
	get_tree().change_scene_to_file("res://scenes/menu_select.tscn")


func _redirect_to_gender_select() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_file("res://scenes/gender_select.tscn")
