## shot_premium_cooking.gd — Premium V1 cooking screen (slice module mid-action).
##
## Scenario: Tteokbokki (t1_003) at step 2/5 — slice module active showing
## NowCookingBanner (CP-40) + step dots (CP-41) + bottom-left guest mini + module UI.
## Output: user://premium_v1_03_cooking.png
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const MarketBG := preload("res://scripts/ui/market_bg.gd")
const NowCookingBannerScript := preload("res://scripts/ui/premium/now_cooking_banner.gd")
const SparkleScript := preload("res://scripts/ui/premium/sparkle_particle.gd")
const HeroNumberScript := preload("res://scripts/ui/premium/hero_number_bounce.gd")
const IdleScript := preload("res://scripts/ui/premium/character_idle_animator.gd")
const DropShadowScript := preload("res://scripts/ui/premium/drop_shadow_panel.gd")
const SliceScene := preload("res://scenes/cooking/slice_module.tscn")


func _ready() -> void:
	# Background (light market backdrop)
	var bg := MarketBG.new()
	bg.light = true
	get_tree().root.add_child(bg)
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	await get_tree().process_frame

	# Build chrome that mirrors the runner's premium chrome
	var layer := CanvasLayer.new()
	get_tree().root.add_child(layer)

	# Level pill
	var pill := Panel.new()
	pill.position = Vector2(24, 8)
	pill.size = Vector2(180, 56)
	DropShadowScript.apply_to(pill, Color(0.30, 0.20, 0.12, 0.95), 28, 8, Color(0.95, 0.70, 0.18), 3)
	layer.add_child(pill)
	var pl := Label.new()
	pl.text = "Lv 3"
	pl.set_anchors_preset(Control.PRESET_FULL_RECT)
	pl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pl.add_theme_font_size_override("font_size", 28)
	pl.add_theme_color_override("font_color", Color(0.99, 0.92, 0.78))
	pill.add_child(pl)

	# NowCookingBanner (CP-40) — Tteokbokki step 2/5
	var menu: Dictionary = MenuDB.get_menu("t1_003")
	var banner = NowCookingBannerScript.new()
	banner.position = Vector2(40, 80)
	banner.size = Vector2(1000, 96)
	banner.custom_minimum_size = Vector2(1000, 96)
	layer.add_child(banner)
	banner.setup(String(menu.get("name_en", "Tteokbokki")),
		String(menu.get("name_kr", "떡볶이")),
		String(menu.get("food_img", "")) if bool(menu.get("ready", false)) else "",
		2, 5)

	# Instantiate slice module
	var module = SliceScene.instantiate()
	layer.add_child(module)
	if module.has_method("start"):
		module.start({
			"food_id": "t1_003",
			"guest_id": "junho",
			"level": MenuDB.get_level(3),
			"menu": menu,
			"step_no": 2,
			"step_total": 5,
			"module_id": "slice",
			"bpm": 102.0,
			"tap_count": 4,
		})

	# Bottom-left guest mini (matches the runner's _build_guest_mini)
	_build_guest_mini(layer, "junho", "Junho")

	# Wait for layout, then overlay a PERFECT! 80pt gold burst at center
	for i in range(20):
		await get_tree().process_frame
	await get_tree().create_timer(0.6).timeout

	_overlay_perfect_burst(layer)

	# Let the burst tween play out (0.4s peak)
	await get_tree().create_timer(0.45).timeout

	var img := get_viewport().get_texture().get_image()
	var out_path: String = "user://premium_v1_03_cooking.png"
	var err := img.save_png(out_path)
	print("[shot_premium_cooking] err=%d -> %s (%dx%d)" % [err,
		ProjectSettings.globalize_path(out_path), img.get_width(), img.get_height()])
	get_tree().quit()


func _overlay_perfect_burst(layer: CanvasLayer) -> void:
	# Big gold "PERFECT!" text + sparkle ring at screen center.
	var hero = HeroNumberScript.new()
	hero.position = Vector2(100, 700)
	hero.size = Vector2(880, 200)
	layer.add_child(hero)
	# Re-use HeroNumberBounce as a label container — but we want text "PERFECT!" not a number.
	# Workaround: hijack the label after setup.
	hero.setup(0, "", 130)
	hero.call_deferred("play_bounce", 0.0, -1)
	# Replace label text
	await get_tree().process_frame
	for c in hero.get_children():
		if c is Label:
			c.text = "PERFECT!"
			break
	# Sparkle burst behind it
	var spark = SparkleScript.new()
	layer.add_child(spark)
	spark.burst(Vector2(540, 800), 16, 220.0, Color(1.0, 0.92, 0.45), 0.7)


const _GUEST_TINT := {
	"junho": Color(0.86, 0.45, 0.40), "mina": Color(0.95, 0.78, 0.45),
}

func _build_guest_mini(layer: CanvasLayer, gid: String, name_str: String) -> void:
	var holder := Control.new()
	holder.position = Vector2(24, 1780)
	holder.size = Vector2(240, 120)
	layer.add_child(holder)
	var av := Panel.new()
	av.position = Vector2(0, 0)
	av.size = Vector2(100, 100)
	var avsb := StyleBoxFlat.new()
	avsb.bg_color = _GUEST_TINT.get(gid, Color(0.82, 0.72, 0.60))
	avsb.set_corner_radius_all(50)
	avsb.set_border_width_all(4)
	avsb.border_color = Color.WHITE
	avsb.shadow_size = 8
	avsb.shadow_color = Color(0, 0, 0, 0.40)
	avsb.shadow_offset = Vector2(0, 4)
	av.add_theme_stylebox_override("panel", avsb)
	holder.add_child(av)
	# Phase B+C: real sprite (neutral) if available, fallback to initial letter.
	var avatar_path := "res://art/sprites/character/%s_neutral.png" % gid
	if ResourceLoader.exists(avatar_path):
		var avatar_tex := TextureRect.new()
		avatar_tex.texture = load(avatar_path)
		avatar_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
		avatar_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		avatar_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		avatar_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		av.add_child(avatar_tex)
	else:
		var initial := Label.new()
		initial.text = name_str.substr(0, 1)
		initial.set_anchors_preset(Control.PRESET_FULL_RECT)
		initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		initial.add_theme_font_size_override("font_size", 56)
		initial.add_theme_color_override("font_color", Color.WHITE)
		av.add_child(initial)
	# bubble
	var bubble := Panel.new()
	bubble.position = Vector2(108, 12)
	bubble.size = Vector2(120, 44)
	var bsb := StyleBoxFlat.new()
	bsb.bg_color = Color(1.0, 0.99, 0.93)
	bsb.set_corner_radius_all(20)
	bsb.set_border_width_all(2)
	bsb.border_color = Color(0.70, 0.50, 0.20)
	bsb.shadow_size = 4
	bsb.shadow_color = Color(0, 0, 0, 0.20)
	bubble.add_theme_stylebox_override("panel", bsb)
	holder.add_child(bubble)
	var bl := Label.new()
	bl.text = "Hungry!"
	bl.set_anchors_preset(Control.PRESET_FULL_RECT)
	bl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bl.add_theme_font_size_override("font_size", 20)
	bl.add_theme_color_override("font_color", Color(0.40, 0.20, 0.08))
	bubble.add_child(bl)
	IdleScript.attach(av, 1.04, 2.0)
