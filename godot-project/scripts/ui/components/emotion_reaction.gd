## CP-30 EmotionReaction — Result Screen 2.0 reaction strip (960x460).
##
## Layout:
##   [avatar 220x220 with mood_badge swap]
##   [speech bubble with typewriter reveal of reaction_text]
##
## Mood badge re-uses MoodBadge (autoload `MoodSystem` colors/labels) but with
## the emotion-derived mood instead of today's mood:
##   excellent -> "happy", good -> "hungry" (proxy for ":p" enthusiasm),
##   okay -> "easy", bad -> "grumpy"
class_name EmotionReaction
extends Panel

const MoodBadgeScript := preload("res://scripts/ui/components/mood_badge.gd")

const AVATAR_TINT := {
	"junho": Color(0.86, 0.45, 0.40), "mina": Color(0.95, 0.78, 0.45),
	"riley": Color(0.55, 0.72, 0.85), "mrs_lee": Color(0.70, 0.80, 0.62),
	"seoyeon": Color(0.80, 0.62, 0.85),
	"mother_01": Color(0.85, 0.60, 0.70), "father_01": Color(0.55, 0.45, 0.40),
	"mystery_diner": Color(0.65, 0.60, 0.70),
	"blogger_daniel": Color(0.70, 0.80, 0.55),
	"goldspoon": Color(0.85, 0.74, 0.36),
}

var _guest: Dictionary = {}
var _emotion: String = "okay"
var _text: String = ""
## D1 폴리시 (2026-06-04): hero mode enlarges avatar 220→320 + speech bubble wider
## so emotion reaction becomes the result-screen primary focal point.
var _hero_mode: bool = false

var _bubble_lbl: Label = null
var _avatar_panel: Panel = null


func setup(guest: Dictionary, emotion: String, text: String) -> void:
	_guest = guest
	_emotion = emotion
	_text = text
	_rebuild()


## D1 hero mode toggle — call BEFORE setup() (or before _rebuild()) for enlarged layout.
func set_hero_mode(on: bool) -> void:
	_hero_mode = on
	if get_child_count() > 0:
		_rebuild()


## Typewriter reveal of the reaction text (chars per 35ms).
func play_typewriter(delay: float = 0.0, total_seconds: float = 1.6) -> void:
	if _bubble_lbl == null:
		return
	var full: String = _text
	_bubble_lbl.text = ""
	if full == "":
		return
	var step: float = maxf(total_seconds / float(maxi(full.length(), 1)), 0.012)
	var tw := create_tween()
	tw.tween_interval(delay)
	for i in range(full.length()):
		var snippet: String = full.substr(0, i + 1)
		tw.tween_callback(func() -> void:
			if is_instance_valid(_bubble_lbl):
				_bubble_lbl.text = snippet)
		tw.tween_interval(step)


## Avatar mood-swap pulse (at delay + 0.8 typically).
func play_mood_swap(delay: float = 0.0) -> void:
	if _avatar_panel == null:
		return
	_avatar_panel.scale = Vector2.ONE
	_avatar_panel.pivot_offset = _avatar_panel.size * 0.5
	var tw := create_tween()
	tw.tween_interval(delay)
	tw.tween_property(_avatar_panel, "scale", Vector2(1.12, 1.12), 0.15).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_avatar_panel, "scale", Vector2.ONE, 0.20).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	# D1 hero mode: enlarge from 960×460 → 1020×620 (avatar 320, bubble taller).
	var avatar_size: float = 320.0 if _hero_mode else 220.0
	var card_w: float = 1020.0 if _hero_mode else 960.0
	var card_h: float = 620.0 if _hero_mode else 460.0
	custom_minimum_size = Vector2(card_w, card_h)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(1, 1, 1, 0)  # transparent — speech bubble owns its style
	add_theme_stylebox_override("panel", sb)

	# avatar panel — hero mode: 320, default: 220
	var gid := String(_guest.get("id", ""))
	_avatar_panel = Panel.new()
	_avatar_panel.position = Vector2(40, 40) if _hero_mode else Vector2(20, 60)
	_avatar_panel.size = Vector2(avatar_size, avatar_size)
	var avsb := StyleBoxFlat.new()
	avsb.bg_color = AVATAR_TINT.get(gid, Color(0.82, 0.72, 0.60))
	avsb.set_corner_radius_all(int(avatar_size * 0.5))
	avsb.set_border_width_all(8 if _hero_mode else 6)
	avsb.border_color = Color(1, 1, 1, 0.95)
	avsb.shadow_size = 14 if _hero_mode else 8
	avsb.shadow_color = Color(0, 0, 0, 0.34)
	avsb.shadow_offset = Vector2(0, 6)
	_avatar_panel.add_theme_stylebox_override("panel", avsb)
	_avatar_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_avatar_panel)
	var nm: String = String(_guest.get("name", "?"))
	# Real avatar sprite (Phase B+C). emotion_level → variant:
	#   excellent → excited / good → happy / okay → neutral / bad → disappointed
	var variant := _emotion_to_variant(_emotion)
	var avatar_path := "res://art/sprites/character/%s_%s.png" % [gid, variant]
	if ResourceLoader.exists(avatar_path):
		var avatar_tex := TextureRect.new()
		avatar_tex.texture = load(avatar_path)
		avatar_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
		avatar_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		avatar_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		avatar_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_avatar_panel.add_child(avatar_tex)
	else:
		var initial := Label.new()
		initial.text = nm.substr(0, 1)
		initial.set_anchors_preset(Control.PRESET_FULL_RECT)
		initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		initial.add_theme_font_size_override("font_size", 110)
		initial.add_theme_color_override("font_color", Color.WHITE)
		initial.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_avatar_panel.add_child(initial)

	# mood badge overlay (lower-right of avatar) — emotion-derived
	var badge_size: float = 100.0 if _hero_mode else 80.0
	var mb := MoodBadgeScript.new()
	mb.position = Vector2(_avatar_panel.position.x + _avatar_panel.size.x - badge_size * 0.7,
		_avatar_panel.position.y + _avatar_panel.size.y - badge_size * 0.7)
	mb.size = Vector2(badge_size, badge_size)
	add_child(mb)
	mb.setup(_emotion_to_mood(_emotion))

	# guest name (under avatar) — hero mode: larger + repositioned
	var name_y: float = _avatar_panel.position.y + _avatar_panel.size.y + 18.0
	var name_lbl := Label.new()
	name_lbl.text = nm
	name_lbl.position = Vector2(_avatar_panel.position.x - 30.0, name_y)
	name_lbl.size = Vector2(avatar_size + 60.0, 44 if _hero_mode else 36)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 36 if _hero_mode else 28)
	name_lbl.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(name_lbl)
	var role := Label.new()
	role.text = String(_guest.get("role", "")).capitalize()
	role.position = Vector2(name_lbl.position.x, name_y + name_lbl.size.y + 2.0)
	role.size = Vector2(name_lbl.size.x, 26)
	role.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	role.add_theme_font_size_override("font_size", 22 if _hero_mode else 18)
	role.add_theme_color_override("font_color", Color(0.50, 0.40, 0.30))
	role.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(role)

	# speech bubble (right of avatar) — hero mode: wider + taller, font_size 30→40
	var bubble_x: float = _avatar_panel.position.x + _avatar_panel.size.x + 40.0
	var bubble_w: float = custom_minimum_size.x - bubble_x - 20.0
	var bubble_h: float = 420.0 if _hero_mode else 280.0
	var bubble := Panel.new()
	bubble.position = Vector2(bubble_x, _avatar_panel.position.y - 20.0)
	bubble.size = Vector2(bubble_w, bubble_h)
	var bsb := StyleBoxFlat.new()
	bsb.bg_color = _bubble_color(_emotion)
	bsb.set_corner_radius_all(34 if _hero_mode else 28)
	bsb.set_border_width_all(4 if _hero_mode else 3)
	bsb.border_color = _bubble_color(_emotion).darkened(0.20)
	bsb.shadow_size = 8 if _hero_mode else 5
	bsb.shadow_color = Color(0, 0, 0, 0.20)
	bsb.shadow_offset = Vector2(0, 4)
	bubble.add_theme_stylebox_override("panel", bsb)
	bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bubble)
	# small tail toward avatar (triangle)
	var tail := Polygon2D.new()
	var tail_h: float = 50.0 if _hero_mode else 40.0
	tail.polygon = PackedVector2Array([Vector2(0, tail_h * 0.4),
		Vector2(36.0 if _hero_mode else 28.0, 0),
		Vector2(36.0 if _hero_mode else 28.0, tail_h)])
	tail.color = _bubble_color(_emotion)
	tail.position = Vector2(bubble_x - (36.0 if _hero_mode else 28.0),
		_avatar_panel.position.y + avatar_size * 0.45)
	add_child(tail)
	# emotion label
	var emo_lbl := Label.new()
	emo_lbl.text = _emotion.to_upper()
	emo_lbl.position = Vector2(30, 20)
	emo_lbl.size = Vector2(280, 32)
	emo_lbl.add_theme_font_size_override("font_size", 28 if _hero_mode else 20)
	emo_lbl.add_theme_color_override("font_color", _bubble_color(_emotion).darkened(0.40))
	emo_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bubble.add_child(emo_lbl)
	# text — hero mode: bigger + wider with proper inset so text never clips.
	# clip_contents=true prevents text from rendering past the bubble while autowrap
	# does the actual line breaking; size set via anchors so width is final at paint.
	_bubble_lbl = Label.new()
	_bubble_lbl.text = _text
	_bubble_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bubble_lbl.offset_left = 30.0
	_bubble_lbl.offset_top = 64.0 if _hero_mode else 48.0
	_bubble_lbl.offset_right = -30.0
	_bubble_lbl.offset_bottom = -30.0
	_bubble_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble_lbl.clip_contents = true
	_bubble_lbl.add_theme_font_size_override("font_size", 34 if _hero_mode else 30)
	_bubble_lbl.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	_bubble_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bubble.add_child(_bubble_lbl)


func _emotion_to_mood(emo: String) -> String:
	match emo:
		"excellent": return "happy"
		"good":      return "hungry"
		"okay":      return "easy"
		"bad":       return "grumpy"
		_:           return "easy"


# Map result-screen emotion_level → guest avatar emotion variant filename suffix.
# excellent → excited (most expressive), good → happy, okay → neutral, bad → disappointed.
func _emotion_to_variant(emo: String) -> String:
	match emo:
		"excellent": return "excited"
		"good":      return "happy"
		"okay":      return "neutral"
		"bad":       return "disappointed"
		_:           return "neutral"


func _bubble_color(emo: String) -> Color:
	match emo:
		"excellent": return Color(0.99, 0.93, 0.66)   # warm cream-gold
		"good":      return Color(0.94, 0.97, 0.86)   # mint
		"okay":      return Color(0.95, 0.94, 0.88)   # neutral cream
		"bad":       return Color(0.96, 0.86, 0.82)   # muted red
		_:           return Color(0.95, 0.94, 0.88)
