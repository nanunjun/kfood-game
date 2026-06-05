## GuestCardV2 — Guest System 2.0 selection card (510 x 680). PREMIUM VISUAL REDESIGN.
##
## Visual-only redesign (premium_v1):
##   - DropShadowPanel base (CP-34) + larger 14px Y shadow
##   - Compat % rendered via HeroNumberBounce (CP-37) — 80pt gold + halo
##   - Avatar gets CharacterIdleAnimator (CP-36) breathing
##   - Mood badge enlarged 80 → 100, sits with stronger ring + outline
##   - RECOMMENDED ribbon repainted gold + sparkle halo (CP-35) + Z-order 150
##   - CTA replaced with GlossyButton (CP-33)
##   - "+50% ₩ BONUS" reward band enlarged 24pt + glossy treatment
##
## GAMEPLAY-CRITICAL: setup() / picked signal contract UNCHANGED. Only visual layer.
class_name GuestCardV2
extends Panel

signal picked(guest_id: String)

const FlavorTagBadgeScript := preload("res://scripts/ui/components/flavor_tag_badge.gd")
const MoodBadgeScript := preload("res://scripts/ui/components/mood_badge.gd")
const RewardBonusBadgeScript := preload("res://scripts/ui/components/reward_bonus_badge.gd")
const GlossyButtonScript := preload("res://scripts/ui/premium/glossy_button.gd")
const HeroNumberScript := preload("res://scripts/ui/premium/hero_number_bounce.gd")
const SparkleScript := preload("res://scripts/ui/premium/sparkle_particle.gd")
const IdleScript := preload("res://scripts/ui/premium/character_idle_animator.gd")
const DropShadowScript := preload("res://scripts/ui/premium/drop_shadow_panel.gd")

const AVATAR_TINT := {
	"junho": Color(0.86, 0.45, 0.40), "mina": Color(0.95, 0.78, 0.45),
	"riley": Color(0.55, 0.72, 0.85), "mrs_lee": Color(0.70, 0.80, 0.62),
	"seoyeon": Color(0.80, 0.62, 0.85),
	"mother_01": Color(0.85, 0.60, 0.70), "father_01": Color(0.55, 0.45, 0.40),
}

var _guest: Dictionary = {}
var _menu: Dictionary = {}
var _compat: int = 50
var _mood: String = "easy"
var _is_recommended: bool = false
var _ribbon: Control = null
var _avatar_panel: Panel = null


func setup(guest: Dictionary, menu: Dictionary, compat: int, mood: String) -> void:
	_guest = guest
	_menu = menu
	_compat = compat
	_mood = mood
	_rebuild()


func set_recommended(on: bool) -> void:
	_is_recommended = on
	if not is_inside_tree():
		return
	_rebuild_ribbon()


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	_ribbon = null
	custom_minimum_size = Vector2(510, 680)
	var reward_calc := get_node_or_null("/root/RewardCalc")
	var compat_col: Color = reward_calc.compat_color(_compat) if reward_calc else Color(0.85, 0.80, 0.70)
	# Premium drop-shadow card base (CP-34)
	DropShadowScript.apply_to(self, Color(1.0, 0.99, 0.96), 32, 16, compat_col, 5)

	# --- compat % (top-left, HeroNumberBounce CP-37) ---
	var compat_hero = HeroNumberScript.new()
	compat_hero.position = Vector2(8, 6)
	compat_hero.size = Vector2(220, 110)
	add_child(compat_hero)
	compat_hero.setup(_compat, "%", 80)
	compat_hero.call_deferred("play_bounce", 0.10)
	var compat_sub := Label.new()
	compat_sub.text = "compat"
	compat_sub.position = Vector2(18, 110)
	compat_sub.size = Vector2(180, 24)
	compat_sub.add_theme_font_size_override("font_size", 18)
	compat_sub.add_theme_color_override("font_color", Color(0.55, 0.42, 0.30))
	compat_sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(compat_sub)

	# --- friendship stars (top-right) ---
	var sm := get_node_or_null("/root/SaveManager")
	var fr_level: int = sm.friendship_of(String(_guest.get("id", ""))) if sm else 0
	var stars: int = clampi(int(floor(float(fr_level) / 2.0)), 0, 5)
	var stars_lbl := Label.new()
	stars_lbl.text = "*".repeat(stars) + "-".repeat(5 - stars)
	stars_lbl.position = Vector2(custom_minimum_size.x - 220, 24)
	stars_lbl.size = Vector2(200, 36)
	stars_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stars_lbl.add_theme_font_size_override("font_size", 32)
	stars_lbl.add_theme_color_override("font_color", Color(0.96, 0.74, 0.22))
	stars_lbl.add_theme_color_override("font_outline_color", Color(0.50, 0.30, 0.05))
	stars_lbl.add_theme_constant_override("outline_size", 3)
	stars_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stars_lbl)
	var fr_lbl := Label.new()
	fr_lbl.text = "Friendship %d/10" % fr_level
	fr_lbl.position = Vector2(custom_minimum_size.x - 220, 60)
	fr_lbl.size = Vector2(200, 22)
	fr_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	fr_lbl.add_theme_font_size_override("font_size", 16)
	fr_lbl.add_theme_color_override("font_color", Color(0.55, 0.42, 0.30))
	fr_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fr_lbl)

	# --- avatar 240x240 (center) with CP-36 idle breathing ---
	var gid := String(_guest.get("id", ""))
	_avatar_panel = Panel.new()
	_avatar_panel.position = Vector2((custom_minimum_size.x - 240.0) * 0.5, 130)
	_avatar_panel.size = Vector2(240, 240)
	var avsb := StyleBoxFlat.new()
	avsb.bg_color = AVATAR_TINT.get(gid, Color(0.82, 0.72, 0.60))
	avsb.set_corner_radius_all(120)
	avsb.set_border_width_all(6)
	avsb.border_color = Color(1, 1, 1, 0.95)
	avsb.shadow_size = 10
	avsb.shadow_color = Color(0, 0, 0, 0.30)
	avsb.shadow_offset = Vector2(0, 6)
	_avatar_panel.add_theme_stylebox_override("panel", avsb)
	_avatar_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_avatar_panel)
	# Real avatar sprite (Phase B+C, neutral emotion for Guest Select).
	# Graceful fallback: if sprite missing, fall back to initial letter overlay.
	var nm := String(_guest.get("name", "?"))
	var avatar_path := "res://art/sprites/character/%s_neutral.png" % gid
	if ResourceLoader.exists(avatar_path):
		var avatar_tex := TextureRect.new()
		avatar_tex.texture = load(avatar_path)
		avatar_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
		avatar_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		avatar_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		avatar_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_avatar_panel.add_child(avatar_tex)
	else:
		# inner highlight gradient
		var grad := Gradient.new()
		grad.set_color(0, Color(1, 1, 1, 0.35))
		grad.set_color(1, Color(1, 1, 1, 0.0))
		var gt := GradientTexture2D.new()
		gt.gradient = grad
		gt.fill = GradientTexture2D.FILL_RADIAL
		gt.fill_from = Vector2(0.5, 0.3)
		gt.fill_to = Vector2(1.0, 1.0)
		gt.width = 256
		gt.height = 256
		var hl := TextureRect.new()
		hl.texture = gt
		hl.set_anchors_preset(Control.PRESET_FULL_RECT)
		hl.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		hl.stretch_mode = TextureRect.STRETCH_SCALE
		hl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_avatar_panel.add_child(hl)
		var initial := Label.new()
		initial.text = nm.substr(0, 1)
		initial.set_anchors_preset(Control.PRESET_FULL_RECT)
		initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		initial.add_theme_font_size_override("font_size", 120)
		initial.add_theme_color_override("font_color", Color.WHITE)
		initial.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.30))
		initial.add_theme_constant_override("outline_size", 4)
		initial.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_avatar_panel.add_child(initial)
	# idle breathing CP-36
	IdleScript.attach(_avatar_panel, 1.025, 2.2)

	# mood badge overlay (enlarged 100x100)
	var mood_badge: MoodBadge = MoodBadgeScript.new()
	var mb_size: float = 100.0
	mood_badge.position = Vector2(_avatar_panel.position.x + _avatar_panel.size.x - mb_size * 0.65,
		_avatar_panel.position.y + _avatar_panel.size.y - mb_size * 0.65)
	mood_badge.size = Vector2(mb_size, mb_size)
	mood_badge.custom_minimum_size = Vector2(mb_size, mb_size)
	add_child(mood_badge)
	mood_badge.setup(_mood)

	# --- guest name (under avatar) ---
	var name_lbl := Label.new()
	name_lbl.text = nm
	name_lbl.position = Vector2(0, 380)
	name_lbl.size = Vector2(custom_minimum_size.x, 48)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 40)
	name_lbl.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(name_lbl)
	var role_lbl := Label.new()
	role_lbl.text = String(_guest.get("role", "")).capitalize()
	role_lbl.position = Vector2(0, 428)
	role_lbl.size = Vector2(custom_minimum_size.x, 22)
	role_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	role_lbl.add_theme_font_size_override("font_size", 18)
	role_lbl.add_theme_color_override("font_color", Color(0.50, 0.40, 0.30))
	role_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(role_lbl)

	# --- Likes (1~3 tags) ---
	var likes: Array = (_guest.get("favorite_flavors", []) as Array).slice(0, 3)
	_add_flavor_row("Likes", likes, "like", 458)
	# --- Avoids (1~2 tags) ---
	var avoids: Array = (_guest.get("disliked_flavors", []) as Array).slice(0, 2)
	_add_flavor_row("Avoids", avoids, "dislike", 522)

	# --- reward bonus band (enlarged) ---
	var band: RewardBonusBadge = RewardBonusBadgeScript.new()
	band.position = Vector2(16, 588)
	band.size = Vector2(custom_minimum_size.x - 32, 44)
	band.custom_minimum_size = Vector2(custom_minimum_size.x - 32, 44)
	add_child(band)
	band.setup(_compat, _guest)

	# --- CTA button (Glossy CP-33) ---
	var cta_root = GlossyButtonScript.new()
	cta_root.size = Vector2(custom_minimum_size.x - 32, 40)
	cta_root.custom_minimum_size = Vector2(custom_minimum_size.x - 32, 40)
	cta_root.position = Vector2(16, 638)
	add_child(cta_root)
	cta_root.setup("Cook for %s  >" % nm, compat_col.darkened(0.05), 22, 18)
	# When the inner button fires, emit picked.
	cta_root.call_deferred("set", "_gid_for_callback", gid)
	# We can't easily connect deferred — instead use a small wrapper
	_wire_glossy_cta(cta_root, gid)

	# RECOMMENDED ribbon (if flagged)
	_rebuild_ribbon()


func _wire_glossy_cta(cta: Control, gid: String) -> void:
	# `cta.button` may be null until _ready runs; defer.
	if not is_inside_tree():
		return
	await get_tree().process_frame
	if cta == null or not is_instance_valid(cta):
		return
	if cta.get("button") == null:
		await get_tree().process_frame
	var btn: Button = cta.get("button")
	if btn != null:
		btn.pressed.connect(func() -> void: picked.emit(gid))


func _add_flavor_row(prefix: String, flavors: Array, mode: String, y: float) -> void:
	var lbl := Label.new()
	lbl.text = prefix
	lbl.position = Vector2(20, y)
	lbl.size = Vector2(96, 56)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 20)
	lbl.add_theme_color_override("font_color", Color(0.45, 0.32, 0.20))
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(lbl)
	var x: float = 118.0
	for fid in flavors:
		var badge: FlavorTagBadge = FlavorTagBadgeScript.new()
		badge.position = Vector2(x, y)
		badge.size = Vector2(120, 56)
		badge.custom_minimum_size = Vector2(120, 56)
		add_child(badge)
		badge.setup(String(fid), mode)
		x += 124.0


func _rebuild_ribbon() -> void:
	if is_instance_valid(_ribbon):
		_ribbon.queue_free()
		_ribbon = null
	if not _is_recommended:
		return
	# Z-order 150 ribbon + sparkle halo
	_ribbon = Control.new()
	_ribbon.position = Vector2(60, -28)
	_ribbon.size = Vector2(custom_minimum_size.x - 120, 50)
	_ribbon.z_index = 150
	_ribbon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_ribbon)
	var bg := Panel.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rsb := StyleBoxFlat.new()
	rsb.bg_color = Color(0.96, 0.74, 0.22)
	rsb.set_corner_radius_all(14)
	rsb.set_border_width_all(3)
	rsb.border_color = Color(0.55, 0.35, 0.10)
	rsb.shadow_size = 10
	rsb.shadow_color = Color(0, 0, 0, 0.40)
	rsb.shadow_offset = Vector2(0, 4)
	bg.add_theme_stylebox_override("panel", rsb)
	_ribbon.add_child(bg)
	# top highlight
	var grad := Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 0.45))
	grad.set_color(1, Color(1, 1, 1, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_LINEAR
	gt.fill_from = Vector2(0.5, 0.0)
	gt.fill_to = Vector2(0.5, 1.0)
	gt.width = 256
	gt.height = 256
	var hl := TextureRect.new()
	hl.texture = gt
	hl.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hl.offset_top = 3.0
	hl.offset_left = 6.0
	hl.offset_right = -6.0
	hl.offset_bottom = 26.0
	hl.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hl.stretch_mode = TextureRect.STRETCH_SCALE
	hl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.add_child(hl)
	var rl := Label.new()
	rl.text = "* RECOMMENDED *"
	rl.set_anchors_preset(Control.PRESET_FULL_RECT)
	rl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rl.add_theme_font_size_override("font_size", 28)
	rl.add_theme_color_override("font_color", Color(0.20, 0.10, 0.04))
	rl.add_theme_color_override("font_outline_color", Color(1.0, 0.95, 0.65, 0.55))
	rl.add_theme_constant_override("outline_size", 3)
	rl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ribbon.add_child(rl)
	# sparkle halo over the ribbon
	var sparkle = SparkleScript.new()
	_ribbon.add_child(sparkle)
	sparkle.halo(_ribbon.size * 0.5, 8, 130.0, Color(1.0, 0.92, 0.45))
	# 1Hz pulse + small bounce
	var tw := create_tween().set_loops()
	_ribbon.pivot_offset = _ribbon.size * 0.5
	tw.tween_property(_ribbon, "scale", Vector2(1.06, 1.06), 0.55).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_ribbon, "scale", Vector2(1.0, 1.0), 0.55).set_trans(Tween.TRANS_SINE)
