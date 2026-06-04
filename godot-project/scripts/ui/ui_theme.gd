## UITheme — 공용 UI 디자인 시스템 (버튼/라벨/패널 테마 + 그라데이션 배경).
##
## "프로페셔널 모바일" 톤: 따뜻한 K-food 팔레트(크림 배경 + 테라코타 버튼) + 둥근 모서리 + 소프트 섀도.
## 화면 루트 Control에 `theme = UITheme.make_theme()` 지정 → 자식 Button/Label 자동 스타일.
## 배경은 `UITheme.add_background(self)`.
## 참조: docs/art-style-guide.md (warm modern casual), docs/design/progression-and-variety-v0.1.md
class_name UITheme
extends RefCounted

const CREAM_TOP := Color(0.988, 0.957, 0.898)
const CREAM_BOT := Color(0.929, 0.859, 0.741)
const DARK := Color(0.17, 0.11, 0.08)
const CORAL := Color(0.88, 0.45, 0.30)
const CORAL_HI := Color(0.93, 0.55, 0.40)
const CORAL_LO := Color(0.74, 0.36, 0.24)
const MUTE := Color(0.80, 0.74, 0.66)
const GOLD := Color(0.96, 0.66, 0.12)
const CARD := Color(1.0, 0.99, 0.96)

static var _theme: Theme = null


static func _box(bg: Color, radius: int = 26, shadow: int = 8, border: Color = Color(0, 0, 0, 0)) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	s.shadow_color = Color(0.15, 0.09, 0.05, 0.28)
	s.shadow_size = shadow
	s.shadow_offset = Vector2(0, 4)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	if border.a > 0:
		s.set_border_width_all(3)
		s.border_color = border
	return s


## 화면 공용 테마 (캐시).
static func make_theme() -> Theme:
	if _theme != null:
		return _theme
	var t := Theme.new()
	# Button — 테라코타 라운드 + 섀도, 상태별
	t.set_stylebox("normal", "Button", _box(CORAL))
	t.set_stylebox("hover", "Button", _box(CORAL_HI))
	t.set_stylebox("pressed", "Button", _box(CORAL_LO, 26, 4))
	t.set_stylebox("focus", "Button", _box(CORAL, 26, 0, Color(1, 1, 1, 0.5)))
	var dis := _box(MUTE, 26, 3)
	t.set_stylebox("disabled", "Button", dis)
	t.set_color("font_color", "Button", Color(1, 1, 1))
	t.set_color("font_hover_color", "Button", Color(1, 1, 1))
	t.set_color("font_pressed_color", "Button", Color(1, 1, 1))
	t.set_color("font_disabled_color", "Button", Color(1, 1, 1, 0.7))
	t.set_font_size("font_size", "Button", 40)
	# Label 기본 — 다크
	t.set_color("font_color", "Label", DARK)
	t.set_font_size("font_size", "Label", 40)
	# Panel — 카드
	t.set_stylebox("panel", "Panel", _box(CARD, 28, 10))
	_theme = t
	return t


## 그라데이션 배경(크림 세로) + 살짝의 비네트. parent 맨 뒤에 추가.
static func add_background(parent: Control) -> void:
	var g := Gradient.new()
	g.set_color(0, CREAM_TOP)
	g.set_color(1, CREAM_BOT)
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.width = 256
	gt.height = 512
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	var bg := TextureRect.new()
	bg.texture = gt
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(bg)
	parent.move_child(bg, 0)


## 카드 패널 생성 헬퍼.
static func make_card(pos: Vector2, size: Vector2) -> Panel:
	var p := Panel.new()
	p.position = pos
	p.size = size
	p.add_theme_stylebox_override("panel", _box(CARD, 28, 10))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return p
