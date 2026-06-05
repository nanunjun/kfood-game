## CookingFX — D3 shared helpers for dish shadow + steam swirl loop.
##
## Static helpers (no class_name to avoid global namespace pressure) — modules call:
##   CookingFX.attach_dish_shadow(parent, center_pos, width)
##   CookingFX.attach_steam_loop(parent, center_pos)
##
## Reuses LOCK art res://art/vfx/steam_swirl.png. Pure visual; no signals, no gameplay.
extends RefCounted

const STEAM_PATH := "res://art/vfx/steam_swirl.png"


## Drop a soft black ellipse shadow under a dish/tool. Returns the node so caller can
## reposition or queue_free as needed.
static func attach_dish_shadow(parent: Node, center_pos: Vector2,
		w: float = 380.0, h: float = 60.0,
		alpha: float = 0.32) -> ColorRect:
	if parent == null or not is_instance_valid(parent):
		return null
	# Simple ellipse via a Panel with full-radius corners — softer than a hard rect.
	var shadow := ColorRect.new()
	shadow.color = Color(0.05, 0.04, 0.03, alpha)
	shadow.size = Vector2(w, h)
	shadow.position = center_pos - Vector2(w * 0.5, h * 0.5)
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Use a clipped texture via material? cheap path = ColorRect + radial fade.
	# Instead of writing a shader, layer 3 progressively narrower ColorRects with falling
	# alpha to simulate the soft edge blur cheaply.
	parent.add_child(shadow)
	# Soft inner core (darker, narrower)
	var core := ColorRect.new()
	core.color = Color(0.04, 0.03, 0.02, alpha * 1.25)
	core.size = Vector2(w * 0.78, h * 0.65)
	core.position = center_pos - Vector2(core.size.x * 0.5, core.size.y * 0.5)
	core.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(core)
	return shadow


## Attach 3 looping steam swirl puffs above an anchor point. They rise + fade in stagger.
## Returns the container Control so caller can queue_free / reposition.
static func attach_steam_loop(parent: Node, anchor_pos: Vector2,
		count: int = 3, tint: Color = Color(1, 1, 1, 0.55)) -> Control:
	if parent == null or not is_instance_valid(parent):
		return null
	if not ResourceLoader.exists(STEAM_PATH):
		return null
	var holder := Control.new()
	holder.position = anchor_pos
	holder.size = Vector2.ZERO
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(holder)
	var tex: Texture2D = load(STEAM_PATH)
	if tex == null:
		return holder
	for i in range(count):
		var puff := TextureRect.new()
		puff.texture = tex
		puff.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		puff.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		puff.size = Vector2(180, 180)
		puff.position = Vector2(-90 + float(i - 1) * 60.0, 0)
		puff.modulate = Color(tint.r, tint.g, tint.b, 0.0)
		puff.pivot_offset = puff.size * 0.5
		puff.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(puff)
		# Loop tween: rise 180 px, fade in then out, scale 0.6 -> 1.0
		var stagger: float = float(i) * 0.7
		var tw := create_loop_tween(puff, stagger)
	return holder


static func create_loop_tween(puff: TextureRect, stagger: float) -> Tween:
	var tw := puff.create_tween().set_loops()
	tw.tween_interval(stagger)
	# rise + fade in
	tw.parallel().tween_property(puff, "position:y", -180.0, 2.2).from(0.0).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(puff, "modulate:a", 0.55, 0.6).from(0.0)
	tw.parallel().tween_property(puff, "scale", Vector2(1.0, 1.0), 1.8).from(Vector2(0.6, 0.6)).set_trans(Tween.TRANS_SINE)
	# fade out near top
	tw.parallel().tween_property(puff, "modulate:a", 0.0, 1.0).set_delay(1.2)
	return tw
