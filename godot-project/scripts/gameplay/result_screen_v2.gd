## ResultScreenV2 — Guest System 2.0 result screen (ui-designer Option A).
##
## Single ScrollContainer (0~2700) + Sticky CTA bar (1700~1860 on CanvasLayer).
## Above-the-fold (0~1300): Summary + Emotional Reaction.
## Scroll: Stars+Score header (1280~1480) → Breakdown 6 rows (1480~2200) → Rewards (2210~2700).
##
## Wire: rhythm_proto.gd calls setup(payload), then reveal sequence runs:
##   t=0.0 scene fade-in
##   t=0.5 dish scale-in
##   t=1.0 compat bar
##   t=1.6 reaction typewriter
##   t=2.4 avatar mood swap
##   t=3.0 stars
##   t=3.6 total score count-up
##   t=4.2 NEW RECORD slide-in (if applicable)
##   t=4.5 sticky CTA fade-in
## On scroll: each breakdown row plays its own bar fill; reward box stagger.
extends Control

const MarketBG := preload("res://scripts/ui/market_bg.gd")
const CookingBackgroundScript := preload("res://scripts/ui/cooking_background.gd")
const CompatBarScript := preload("res://scripts/ui/components/compat_bar.gd")
const ScoreBreakdownRowScript := preload("res://scripts/ui/components/score_breakdown_row.gd")
const RewardBoxScript := preload("res://scripts/ui/components/reward_box.gd")
const EmotionReactionScript := preload("res://scripts/ui/components/emotion_reaction.gd")
const NewRecordBadgeScript := preload("res://scripts/ui/components/new_record_badge.gd")
const MilestoneToastScript := preload("res://scripts/ui/components/milestone_toast.gd")
# Premium V1 components
const HeroNumberScript := preload("res://scripts/ui/premium/hero_number_bounce.gd")
const GoldRibbonScript := preload("res://scripts/ui/premium/gold_ribbon_banner.gd")
const SparkleScript := preload("res://scripts/ui/premium/sparkle_particle.gd")
const CoinSprayScript := preload("res://scripts/ui/premium/coin_spray_particle.gd")
const GlossyButtonScript := preload("res://scripts/ui/premium/glossy_button.gd")
const IdleScript := preload("res://scripts/ui/premium/character_idle_animator.gd")
const DropShadowScript := preload("res://scripts/ui/premium/drop_shadow_panel.gd")

signal cook_again_pressed
signal choose_other_guest_pressed
signal back_to_menu_pressed

const W := 1080.0
const H := 1920.0

var _payload: Dictionary = {}

var _scroll: ScrollContainer = null
var _content: Control = null
var _sticky: CanvasLayer = null
var _dish: Control = null
var _compat_bar: Control = null
var _emotion: Control = null
var _stars_lbl: Label = null
var _score_lbl: Label = null
var _new_record: Control = null
var _reward_box: Control = null
var _breakdown_rows: Array = []
var _cta_root: Control = null

# Premium V1 new nodes
var _score_hero: Control = null         # HeroNumberBounce wrapping the big score
var _gold_ribbon: Control = null        # NEW RECORD banner (CP-38) replaces NewRecordBadge
var _wallet_pill: Label = null          # HUD coin pill at top-right (coin spray dest)
var _coin_spray_origin: Vector2 = Vector2(540, 2500)

# stickyCTA Y-anchor recompute on scroll.
var _cta_root_base_y: float = 1700.0
var _breakdown_played: bool = false
var _reward_played: bool = false


func setup(payload: Dictionary) -> void:
	_payload = payload


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	# D3 (Critical Issue #8): use shared CookingBackground (no awning bleed) instead of
	# MarketBG.light. The market awning belongs to menu/guest screens, not result.
	var bg = CookingBackgroundScript.new()
	bg.dish_anchor_y = 320.0  # spotlight under the dish hero, not center-screen
	add_child(bg)
	_build_scroll()
	_build_sticky_cta()
	_kick_reveal()


func _build_scroll() -> void:
	_scroll = ScrollContainer.new()
	_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	add_child(_scroll)
	_content = Control.new()
	# D1: 3160 main content + 240 sticky-CTA breathing room (was 2900+240). Layout
	# expanded vertically: §1 hero dish + §4 enlarged emotion + new score block above.
	_content.custom_minimum_size = Vector2(W, 3400.0)
	_scroll.add_child(_content)

	# D1 layout (2026-06-04 polish):
	#   §1 Summary       (60~720)  — dish hero + name + compat bar
	#   §4 Emotion       (750~1370) — PRIMARY focal: avatar 320 + speech bubble wide
	#   §  Score header  (1430~1820) — NEW RECORD ribbon ABOVE stars+score
	#   §2 Breakdown     (1840~2560)
	#   §3 Rewards       (2570~3060)
	_build_summary()
	_build_emotion()
	_build_score_header()
	_build_breakdown()
	_build_rewards()
	_scroll.get_v_scroll_bar().value_changed.connect(_on_scroll)


func _build_summary() -> void:
	var food: Dictionary = _payload.get("food", {}) as Dictionary
	var compat: int = int(_payload.get("compat", 50))
	# D1 폴리시: dish hero — 460x460 with drop shadow + idle bob anim.
	_dish = Control.new()
	_dish.position = Vector2(0, 60)
	_dish.size = Vector2(W, 580)
	_content.add_child(_dish)
	# served label (top)
	var served := Label.new()
	served.text = "Served!"
	served.position = Vector2(0, 0)
	served.size = Vector2(W, 50)
	served.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	served.add_theme_font_size_override("font_size", 30)
	served.add_theme_color_override("font_color", Color(0.45, 0.32, 0.18))
	_dish.add_child(served)

	# D1: dish shadow ellipse beneath the hero — visually anchors the food so it
	# stops floating in beige void.
	var shadow := ColorRect.new()
	shadow.color = Color(0.05, 0.03, 0.02, 0.32)
	var shadow_w: float = 360.0
	shadow.size = Vector2(shadow_w, 56)
	shadow.position = Vector2((W - shadow_w) * 0.5, 460)
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dish.add_child(shadow)
	var shadow_core := ColorRect.new()
	shadow_core.color = Color(0.04, 0.03, 0.02, 0.42)
	shadow_core.size = Vector2(shadow_w * 0.72, 36)
	shadow_core.position = Vector2((W - shadow_core.size.x) * 0.5, 470)
	shadow_core.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dish.add_child(shadow_core)

	# Hero food image container — 460×460 (was 460×380 panel placeholder oval).
	var food_panel := Panel.new()
	food_panel.position = Vector2((W - 460.0) * 0.5, 40)
	food_panel.size = Vector2(460, 460)
	food_panel.pivot_offset = Vector2(230, 230)
	food_panel.scale = Vector2(0.85, 0.85)
	var fpsb := StyleBoxFlat.new()
	fpsb.bg_color = Color(1, 1, 1, 0)
	food_panel.add_theme_stylebox_override("panel", fpsb)
	food_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dish.add_child(food_panel)

	# Real food sprite (graceful fallback).
	var food_img: String = String(food.get("food_img", ""))
	var has_real_art: bool = food_img != "" and ResourceLoader.exists(food_img)
	if has_real_art:
		var spr := TextureRect.new()
		spr.texture = load(food_img) as Texture2D
		spr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		spr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		spr.set_anchors_preset(Control.PRESET_FULL_RECT)
		spr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		food_panel.add_child(spr)
	else:
		# D1 fallback: NOT a flat brown oval. Chef-hat-vibe placeholder card with
		# dish name — feels intentional rather than missing-asset.
		var card := Panel.new()
		card.set_anchors_preset(Control.PRESET_FULL_RECT)
		var bsb := StyleBoxFlat.new()
		bsb.bg_color = Color(0.99, 0.94, 0.84)  # warm cream (not muddy brown)
		bsb.set_corner_radius_all(48)
		bsb.set_border_width_all(6)
		bsb.border_color = Color(0.78, 0.55, 0.20)
		bsb.shadow_size = 10
		bsb.shadow_color = Color(0, 0, 0, 0.22)
		bsb.shadow_offset = Vector2(0, 8)
		card.add_theme_stylebox_override("panel", bsb)
		food_panel.add_child(card)
		# Chef hat icon (simple 4-arc polygon — cooking signifier without art)
		var hat := Polygon2D.new()
		hat.polygon = PackedVector2Array([
			Vector2(110, 230), Vector2(110, 180),
			Vector2(80, 160), Vector2(120, 130), Vector2(160, 110),
			Vector2(230, 90), Vector2(300, 110), Vector2(340, 130),
			Vector2(380, 160), Vector2(350, 180), Vector2(350, 230)])
		hat.color = Color(0.99, 0.99, 0.95)
		card.add_child(hat)
		var hat_brim := ColorRect.new()
		hat_brim.color = Color(0.85, 0.66, 0.30)
		hat_brim.size = Vector2(280, 24)
		hat_brim.position = Vector2(90, 226)
		card.add_child(hat_brim)
		var lbl := Label.new()
		lbl.text = String(food.get("name_en", "Dish"))
		lbl.position = Vector2(20, 280)
		lbl.size = Vector2(420, 60)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 44)
		lbl.add_theme_color_override("font_color", Color(0.30, 0.18, 0.08))
		card.add_child(lbl)
		var sub := Label.new()
		sub.text = String(food.get("name_kr", ""))
		sub.position = Vector2(20, 350)
		sub.size = Vector2(420, 36)
		sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sub.add_theme_font_size_override("font_size", 26)
		sub.add_theme_color_override("font_color", Color(0.55, 0.38, 0.18))
		card.add_child(sub)

	# dish name + Korean
	var name_lbl := Label.new()
	name_lbl.text = "%s  (%s)" % [food.get("name_en", "?"), food.get("name_kr", "")]
	name_lbl.position = Vector2(0, 520)
	name_lbl.size = Vector2(W, 56)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 36)
	name_lbl.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	_dish.add_child(name_lbl)
	# guest small + compat bar (pushed below the dish name) — kept slimmer to make
	# room for the larger emotion reaction.
	var compat_holder := Control.new()
	compat_holder.position = Vector2(0, 650)
	compat_holder.size = Vector2(W, 70)
	_content.add_child(compat_holder)
	var compat_w: float = 460.0
	_compat_bar = CompatBarScript.new()
	_compat_bar.position = Vector2((W - compat_w) * 0.5, 8)
	_compat_bar.size = Vector2(compat_w, 32)
	_compat_bar.custom_minimum_size = Vector2(compat_w, 32)
	compat_holder.add_child(_compat_bar)
	_compat_bar.setup(compat)
	var compat_caption := Label.new()
	compat_caption.text = "compatibility with %s" % (_payload.get("guest", {}) as Dictionary).get("name", "guest")
	compat_caption.position = Vector2(0, 44)
	compat_caption.size = Vector2(W, 22)
	compat_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	compat_caption.add_theme_font_size_override("font_size", 18)
	compat_caption.add_theme_color_override("font_color", Color(0.50, 0.40, 0.30))
	compat_holder.add_child(compat_caption)


func _build_emotion() -> void:
	# D1 폴리시: emotion reaction is now the PRIMARY focal point (avatar 320 + bubble
	# wider). Centered horizontally; positioned just below the compat bar.
	var guest: Dictionary = _payload.get("guest", {}) as Dictionary
	var emotion_str: String = String(_payload.get("emotion_level", "okay"))
	var reaction_text: String = String(_payload.get("reaction_text", ""))
	_emotion = EmotionReactionScript.new()
	# Hero mode resizes the component to 1020×620.
	_emotion.set_hero_mode(true)
	_emotion.position = Vector2((W - 1020.0) * 0.5, 750)
	_emotion.size = Vector2(1020, 620)
	_content.add_child(_emotion)
	_emotion.setup(guest, emotion_str, reaction_text)


func _build_score_header() -> void:
	var stars: int = int(_payload.get("stars", 0))
	var score: int = int(_payload.get("score", 0))
	# D1: header expanded to 1430~1820 to fit NEW RECORD ribbon ABOVE stars+score.
	var holder := Control.new()
	holder.position = Vector2(0, 1430)
	holder.size = Vector2(W, 390)
	_content.add_child(holder)

	# D1: NEW RECORD ribbon ABOVE score (was overlapping below at y=200). It now sits
	# in the 0~110 band before the stars start.
	if bool(_payload.get("record_broken", false)):
		_gold_ribbon = GoldRibbonScript.new()
		_gold_ribbon.position = Vector2((W - 540.0) * 0.5, 0)
		_gold_ribbon.size = Vector2(540, 100)
		_gold_ribbon.custom_minimum_size = Vector2(540, 100)
		holder.add_child(_gold_ribbon)
		var prev_score: int = int(_payload.get("record_prev_score", 0))
		_gold_ribbon.setup("NEW RECORD!", "+%d over your best %d" % [maxi(1, score - prev_score), prev_score])
		_gold_ribbon.modulate.a = 0.0

	# D1: Sprite-star row (5 polygon stars, gold fill + dark outline) replaces ASCII.
	# Container 100px tall, stars drawn 80 px each with 16 px gap, centered.
	var stars_row := Control.new()
	stars_row.position = Vector2(0, 120)
	stars_row.size = Vector2(W, 100)
	stars_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(stars_row)
	_build_sprite_stars(stars_row, stars, 80.0, 16.0)
	# Backwards-compat: keep _stars_lbl as a hidden marker for shot tests / existing
	# code that pokes at it. Modulate=0 + visible=false so it does not render.
	_stars_lbl = Label.new()
	_stars_lbl.text = "*".repeat(maxi(0, stars)) + "-".repeat(maxi(0, 5 - stars))
	_stars_lbl.position = Vector2(0, 0)
	_stars_lbl.size = Vector2(W, 100)
	_stars_lbl.modulate.a = 0.0
	_stars_lbl.visible = false
	stars_row.add_child(_stars_lbl)
	# Tiny hidden Label kept for backward compatibility (legacy tests/refs)
	_score_lbl = Label.new()
	_score_lbl.text = "Score 0"
	_score_lbl.position = Vector2(0, 230)
	_score_lbl.size = Vector2(W, 70)
	_score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_score_lbl.add_theme_font_size_override("font_size", 56)
	_score_lbl.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	_score_lbl.modulate.a = 0.0
	_score_lbl.visible = false
	holder.add_child(_score_lbl)
	# Premium HeroNumberBounce — big gold score with halo + bounce-in
	_score_hero = HeroNumberScript.new()
	_score_hero.position = Vector2((W - 540.0) * 0.5, 230)
	_score_hero.size = Vector2(540, 130)
	holder.add_child(_score_hero)
	_score_hero.setup(score, "", 110)
	_score_hero.modulate.a = 0.0  # invisible until reveal
	# Sub-caption under the hero score
	var sub := Label.new()
	sub.text = "TOTAL SCORE"
	sub.position = Vector2(0, 360)
	sub.size = Vector2(W, 28)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 22)
	sub.add_theme_color_override("font_color", Color(0.55, 0.40, 0.22))
	holder.add_child(sub)


# D1: 5-point sprite star helper. Polygon2D for full and empty states (no asset dep).
func _build_sprite_stars(parent: Control, filled: int, star_size: float, gap: float) -> void:
	var total_w: float = 5.0 * star_size + 4.0 * gap
	var x0: float = (W - total_w) * 0.5
	for i in range(5):
		var holder := Control.new()
		holder.position = Vector2(x0 + float(i) * (star_size + gap), 0)
		holder.size = Vector2(star_size, star_size)
		holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(holder)
		# outer dark outline star (drawn slightly larger)
		var outline := Polygon2D.new()
		outline.polygon = _star_5pt(star_size * 0.50 + 4.0, star_size * 0.20 + 2.0)
		outline.color = Color(0.30, 0.18, 0.05)
		outline.position = Vector2(star_size * 0.5, star_size * 0.5)
		holder.add_child(outline)
		# fill — gold if filled, muted grey if empty
		var fill := Polygon2D.new()
		fill.polygon = _star_5pt(star_size * 0.50, star_size * 0.20)
		fill.color = Color(0.98, 0.78, 0.22) if i < filled else Color(0.80, 0.75, 0.65)
		fill.position = Vector2(star_size * 0.5, star_size * 0.5)
		holder.add_child(fill)
		# inner highlight crescent (top-left)
		if i < filled:
			var hl := Polygon2D.new()
			hl.polygon = _star_5pt(star_size * 0.30, star_size * 0.13)
			hl.color = Color(1.0, 0.96, 0.62, 0.85)
			hl.position = Vector2(star_size * 0.42, star_size * 0.42)
			holder.add_child(hl)


# Produces 5-point star polygon centered at (0,0).
func _star_5pt(outer_r: float, inner_r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var rot: float = -PI / 2.0  # point up
	for i in range(10):
		var r: float = outer_r if i % 2 == 0 else inner_r
		var a: float = rot + float(i) * PI / 5.0
		pts.append(Vector2(cos(a) * r, sin(a) * r))
	return pts


func _build_breakdown() -> void:
	var rows: Array = _payload.get("breakdown_rows", []) as Array
	var section_root := Control.new()
	# D1: pushed to 1860 to follow the expanded score header (1430~1820).
	section_root.position = Vector2((W - 960.0) * 0.5, 1860)
	section_root.size = Vector2(960, 720)
	_content.add_child(section_root)
	var hdr := Label.new()
	hdr.text = "Score Breakdown"
	hdr.position = Vector2(0, 0)
	hdr.size = Vector2(960, 40)
	hdr.add_theme_font_size_override("font_size", 28)
	hdr.add_theme_color_override("font_color", Color(0.30, 0.20, 0.10))
	section_root.add_child(hdr)
	var y: float = 56.0
	for r in rows:
		var row: Panel = ScoreBreakdownRowScript.new()
		row.position = Vector2(0, y)
		section_root.add_child(row)
		row.setup(r as Dictionary)
		_breakdown_rows.append(row)
		y += 108.0


func _build_rewards() -> void:
	var section_root := Control.new()
	# D1: pushed to 2590 to follow the expanded breakdown.
	section_root.position = Vector2((W - 960.0) * 0.5, 2590)
	section_root.size = Vector2(960, 500)
	_content.add_child(section_root)
	_reward_box = RewardBoxScript.new()
	_reward_box.position = Vector2(0, 0)
	section_root.add_child(_reward_box)
	_reward_box.setup({
		"coin": int(_payload.get("final_coin", 0)),
		"xp_gained": int(_payload.get("xp_gained", 0)),
		"xp_total_after": int(_payload.get("xp_total_after", 0)),
		"food_id": String((_payload.get("food", {}) as Dictionary).get("id", "")),
		"friendship_after": int(_payload.get("friendship_after", 0)),
		"friendship_delta": int(_payload.get("friendship_delta", 0)),
		"milestone": int(_payload.get("milestone_just_hit", 0)),
	})


func _build_sticky_cta() -> void:
	_sticky = CanvasLayer.new()
	_sticky.layer = 5
	add_child(_sticky)
	_cta_root = Control.new()
	_cta_root.position = Vector2(0, _cta_root_base_y)
	_cta_root.size = Vector2(W, 200)
	_cta_root.modulate.a = 0.0
	_sticky.add_child(_cta_root)
	# bg band (premium drop shadow on top edge)
	var bg := Panel.new()
	bg.position = Vector2(0, 0)
	bg.size = Vector2(W, 200)
	var bsb := StyleBoxFlat.new()
	bsb.bg_color = Color(0.99, 0.94, 0.84, 0.98)
	bsb.shadow_size = 14
	bsb.shadow_color = Color(0, 0, 0, 0.30)
	bsb.shadow_offset = Vector2(0, -8)
	bg.add_theme_stylebox_override("panel", bsb)
	_cta_root.add_child(bg)
	# Wallet HUD pill (top-right of sticky CTA — coin spray destination)
	_build_wallet_pill()
	# 3-tier CTAs — Primary glossy persimmon / Secondary outlined gold / Tertiary text
	_add_glossy_cta("Cook Again", Vector2(30, 60), Vector2(330, 112),
		Color(0.93, 0.45, 0.25), Color.WHITE, _on_cook_again, true)
	_add_glossy_cta("Choose Other Guest", Vector2(380, 60), Vector2(320, 112),
		Color(0.96, 0.74, 0.22), Color(0.20, 0.10, 0.04), _on_choose_other, false)
	_add_glossy_cta("Back to Menu", Vector2(720, 60), Vector2(330, 112),
		Color(0.99, 0.94, 0.84), Color(0.40, 0.25, 0.10), _on_back_menu, false, true)


func _build_wallet_pill() -> void:
	# Coin destination pill (top of sticky band, right side)
	var sm := get_node_or_null("/root/SaveManager")
	var wallet_money: int = sm.money() if sm else 0
	# Final coin awarded was already added during runner _finish(); but for the spray
	# animation, we want to show the BEFORE value then count up. So display before.
	var coin_gain: int = int(_payload.get("final_coin", 0))
	var before: int = wallet_money - coin_gain
	var pill := Panel.new()
	pill.position = Vector2(W - 320.0, 6)
	pill.size = Vector2(300, 48)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.94, 0.66, 0.12)
	sb.set_corner_radius_all(24)
	sb.set_border_width_all(3)
	sb.border_color = Color(0.50, 0.30, 0.05)
	sb.shadow_size = 8
	sb.shadow_color = Color(0, 0, 0, 0.32)
	sb.shadow_offset = Vector2(0, 4)
	pill.add_theme_stylebox_override("panel", sb)
	_cta_root.add_child(pill)
	# inner highlight
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 0.96, 0.50, 0.5))
	grad.set_color(1, Color(1.0, 0.96, 0.50, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_LINEAR
	gt.fill_from = Vector2(0.5, 0.0)
	gt.fill_to = Vector2(0.5, 1.0)
	gt.width = 256; gt.height = 256
	var hl := TextureRect.new()
	hl.texture = gt
	hl.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hl.offset_top = 3.0; hl.offset_left = 4.0; hl.offset_right = -4.0; hl.offset_bottom = 22.0
	hl.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hl.stretch_mode = TextureRect.STRETCH_SCALE
	hl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill.add_child(hl)
	_wallet_pill = Label.new()
	_wallet_pill.text = _format_money(before)
	_wallet_pill.set_anchors_preset(Control.PRESET_FULL_RECT)
	_wallet_pill.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_wallet_pill.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_wallet_pill.add_theme_font_size_override("font_size", 26)
	_wallet_pill.add_theme_color_override("font_color", Color(0.20, 0.10, 0.04))
	_wallet_pill.add_theme_color_override("font_outline_color", Color(1.0, 0.95, 0.55, 0.55))
	_wallet_pill.add_theme_constant_override("outline_size", 2)
	_wallet_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill.add_child(_wallet_pill)


func _format_money(n: int) -> String:
	var s := str(n)
	var out := ""
	var c := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = "," + out
	return "₩" + out


# Premium GlossyButton (CP-33) version of the CTA builder.
func _add_glossy_cta(label: String, pos: Vector2, sz: Vector2, bg: Color, _fg: Color,
		cb: Callable, primary: bool, _outline: bool = false) -> Control:
	var gb = GlossyButtonScript.new()
	gb.position = pos
	gb.size = sz
	gb.custom_minimum_size = sz
	_cta_root.add_child(gb)
	gb.setup(label, bg, 28, 26)
	_wire_cta_button(gb, cb)
	if primary:
		# 1Hz pulse for primary
		gb.pivot_offset = sz * 0.5
		var tw := create_tween().set_loops()
		tw.tween_property(gb, "scale", Vector2(1.04, 1.04), 0.5).set_trans(Tween.TRANS_SINE)
		tw.tween_property(gb, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_SINE)
	return gb


func _wire_cta_button(gb: Control, cb: Callable) -> void:
	await get_tree().process_frame
	if not is_instance_valid(gb):
		return
	if gb.get("button") == null:
		await get_tree().process_frame
	var btn: Button = gb.get("button")
	if btn != null:
		btn.pressed.connect(cb)


func _add_cta(label: String, pos: Vector2, sz: Vector2, bg: Color, fg: Color,
		cb: Callable, primary: bool, outline: bool = false) -> Button:
	var b := Button.new()
	b.text = label
	b.position = pos
	b.size = sz
	b.add_theme_font_size_override("font_size", 30)
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(28)
	if outline:
		sb.set_border_width_all(3)
		sb.border_color = Color(0.55, 0.35, 0.10)
	sb.shadow_size = 5
	sb.shadow_color = Color(0, 0, 0, 0.18)
	b.add_theme_stylebox_override("normal", sb)
	var sbh := sb.duplicate()
	sbh.bg_color = bg.lightened(0.12)
	b.add_theme_stylebox_override("hover", sbh)
	b.add_theme_stylebox_override("pressed", sbh)
	b.add_theme_color_override("font_color", fg)
	b.pressed.connect(cb)
	_cta_root.add_child(b)
	if primary:
		# 1Hz pulse
		var tw := create_tween().set_loops()
		b.pivot_offset = b.size * 0.5
		tw.tween_property(b, "scale", Vector2(1.04, 1.04), 0.5).set_trans(Tween.TRANS_SINE)
		tw.tween_property(b, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_SINE)
	return b


# ---- reveal sequence (premium V1) ----
func _kick_reveal() -> void:
	# t=0.0 scene fade-in
	modulate.a = 0.0
	var t := create_tween().set_parallel(true)
	t.tween_property(self, "modulate:a", 1.0, 0.30)

	# t=0.5 dish scale-in + CP-36 idle breathing
	var dish_inner_panel: Panel = null
	if _dish != null:
		for c in _dish.get_children():
			if c is Panel:
				dish_inner_panel = c
				break
		if dish_inner_panel != null:
			t.tween_property(dish_inner_panel, "scale", Vector2.ONE, 0.45)\
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.5)
			# After scale-in settles, attach idle breathing
			var idle_t := create_tween()
			idle_t.tween_interval(1.0)
			idle_t.tween_callback(func() -> void:
				if is_instance_valid(dish_inner_panel):
					IdleScript.attach(dish_inner_panel, 1.025, 2.4))

	# t=1.0 compat bar fill — already drawn at full at setup; pulse it lightly
	if _compat_bar != null:
		_compat_bar.modulate.a = 0.0
		t.tween_property(_compat_bar, "modulate:a", 1.0, 0.40).set_delay(1.0)

	# t=1.6 reaction typewriter + t=2.4 mood swap
	if _emotion != null:
		_emotion.play_typewriter(1.6, 1.4)
		_emotion.play_mood_swap(2.4)
		# CP-36 idle breath on the emotion avatar (only the avatar child Panel).
		# D1 hero mode bumped avatar to 320; widen the size sniff range.
		var emo_avatar: Control = null
		for c in _emotion.get_children():
			if c is Panel and c.size.x >= 200.0 and c.size.x <= 340.0:
				emo_avatar = c
				break
		if emo_avatar != null:
			var idle_t := create_tween()
			idle_t.tween_interval(2.6)
			idle_t.tween_callback(func() -> void:
				if is_instance_valid(emo_avatar):
					IdleScript.attach(emo_avatar, 1.03, 2.0))

	# t=3.0 stars sparkle burst (sprite stars are already visible from build time;
	# legacy _stars_lbl tween kept for back-compat but invisible)
	if _stars_lbl != null:
		t.tween_property(_stars_lbl, "modulate:a", 0.0, 0.30).set_delay(3.0)
		var spark_t := create_tween()
		spark_t.tween_interval(3.1)
		spark_t.tween_callback(_fire_star_sparkle)

	# t=3.5 — Hero score bounce + count-up (CP-37 replaces flat label)
	if _score_hero != null:
		var target_score: int = int(_payload.get("score", 0))
		# Hero bounces in with count-up from 0
		_score_hero.modulate.a = 0.0
		t.tween_property(_score_hero, "modulate:a", 1.0, 0.20).set_delay(3.5)
		var hero_t := create_tween()
		hero_t.tween_interval(3.5)
		hero_t.tween_callback(func() -> void:
			if is_instance_valid(_score_hero) and _score_hero.has_method("play_bounce"):
				_score_hero.play_bounce(0.0, 0))
	# legacy _score_lbl stays hidden but tween for any back-compat readers
	if _score_lbl != null:
		var target_score2: int = int(_payload.get("score", 0))
		var tw := create_tween()
		tw.tween_interval(3.6)
		tw.tween_method(func(v: int) -> void:
			if is_instance_valid(_score_lbl):
				_score_lbl.text = "Score %d" % v,
			0, target_score2, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# t=4.2 NEW RECORD GoldRibbonBanner slide-in (CP-38)
	if _gold_ribbon != null:
		t.tween_property(_gold_ribbon, "modulate:a", 1.0, 0.20).set_delay(4.2)
		var gr_t := create_tween()
		gr_t.tween_interval(4.2)
		gr_t.tween_callback(func() -> void:
			if is_instance_valid(_gold_ribbon) and _gold_ribbon.has_method("play_reveal"):
				_gold_ribbon.play_reveal(0.0))

	# t=4.5 sticky CTA fade-in
	if _cta_root != null:
		t.tween_property(_cta_root, "modulate:a", 1.0, 0.35).set_delay(4.5)

	# t=4.8 — CP-39 CoinSprayParticle 20 coins → wallet pill
	var coin_gain: int = int(_payload.get("final_coin", 0))
	if coin_gain > 0 and _wallet_pill != null:
		var coin_t := create_tween()
		coin_t.tween_interval(4.8)
		coin_t.tween_callback(_fire_coin_spray)


func _fire_star_sparkle() -> void:
	if not is_inside_tree():
		return
	# D1: stars now live around content y=1430+120+40 = 1590 (sprite star row center).
	var spark = SparkleScript.new()
	_content.add_child(spark)
	var stars_pos: Vector2 = Vector2(W * 0.5, 1590)
	spark.burst(stars_pos, 18, 220.0, Color(1.0, 0.92, 0.45), 0.85)


func _fire_coin_spray() -> void:
	if not is_inside_tree() or _wallet_pill == null:
		return
	# Sticky-CTA is on a CanvasLayer — convert wallet position to that layer's coords.
	var wallet_center_local: Vector2 = _wallet_pill.global_position + _wallet_pill.size * 0.5
	# Coin spray is a Node2D — add it to the canvas layer so it doesn't scroll.
	var spray = CoinSprayScript.new()
	_sticky.add_child(spray)
	var origin: Vector2 = Vector2(W * 0.5, 1500)  # near the score area on screen
	var coin_gain: int = int(_payload.get("final_coin", 0))
	# Compute wallet current displayed value for count-up start
	var before_text: String = _wallet_pill.text
	var wallet_start: int = _parse_money(before_text)
	spray.spray(origin, wallet_center_local, 20, coin_gain, _wallet_pill, wallet_start)


func _parse_money(s: String) -> int:
	var t := s.replace("₩", "").replace(",", "").strip_edges()
	return t.to_int()


# ---- scroll-triggered reveals ----
func _on_scroll(value: float) -> void:
	if _scroll == null:
		return
	# breakdown rows appear once scroll passes 800px
	if not _breakdown_played and value > 460.0:
		_breakdown_played = true
		var d: float = 0.0
		for r in _breakdown_rows:
			if r != null and r.has_method("play_reveal"):
				r.play_reveal(d)
			d += 0.08
	# reward box reveal when scroll passes 1200
	if not _reward_played and value > 1100.0:
		_reward_played = true
		if _reward_box != null:
			_reward_box.play_reveal(0.0)


# ---- CTA handlers ----
func _on_cook_again() -> void:
	cook_again_pressed.emit()
	var food: Dictionary = _payload.get("food", {}) as Dictionary
	var guest: Dictionary = _payload.get("guest", {}) as Dictionary
	var RhythmProto := load("res://scripts/gameplay/rhythm_proto.gd")
	RhythmProto.pending_menu_id = String(food.get("id", ""))
	RhythmProto.pending_guest_id = String(guest.get("id", ""))
	get_tree().change_scene_to_file("res://scenes/rhythm_proto.tscn")


func _on_choose_other() -> void:
	choose_other_guest_pressed.emit()
	var food: Dictionary = _payload.get("food", {}) as Dictionary
	var GuestSelectScript := load("res://scripts/ui/guest_select.gd")
	if GuestSelectScript != null:
		GuestSelectScript.pending_menu_id = String(food.get("id", ""))
	get_tree().change_scene_to_file("res://scenes/guest_select.tscn")


func _on_back_menu() -> void:
	back_to_menu_pressed.emit()
	get_tree().change_scene_to_file("res://scenes/menu_select.tscn")


# Public reveal trigger if a caller wants to force-play scroll reveals (for shots).
func force_play_all_reveals() -> void:
	if not _breakdown_played:
		_breakdown_played = true
		var d: float = 0.0
		for r in _breakdown_rows:
			if r != null and r.has_method("play_reveal"):
				r.play_reveal(d)
			d += 0.08
	if not _reward_played:
		_reward_played = true
		if _reward_box != null:
			_reward_box.play_reveal(0.0)
