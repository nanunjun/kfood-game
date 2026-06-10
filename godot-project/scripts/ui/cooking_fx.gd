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
		alpha: float = 0.32) -> Panel:
	if parent == null or not is_instance_valid(parent):
		return null
	# 부드러운 타원 그림자 — 둥근 모서리 Panel + soft shadow (hard grey bar 방지).
	# (이전 ColorRect 구현은 직사각 grey bar로 보여 layout 문제를 일으켰다.)
	var shadow := Panel.new()
	shadow.size = Vector2(w, h)
	shadow.position = center_pos - Vector2(w * 0.5, h * 0.5)
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.04, 0.03, alpha)
	sb.set_corner_radius_all(int(h * 0.5))   # 완전 둥근 끝 → 타원 느낌
	sb.shadow_size = int(h * 0.45)           # soft blur edge
	sb.shadow_color = Color(0.06, 0.04, 0.03, alpha * 0.6)
	shadow.add_theme_stylebox_override("panel", sb)
	parent.add_child(shadow)
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


# =====================================================================================
# L5 VFX — 5-Layer Composition feedback (slice spark / oil splash / sparkle / particles)
#   z_index 40(L5_VFX) 위에 그려져 항상 ingredient/tool 위에 뜬다. 순수 시각, gameplay 무관.
# =====================================================================================

const _L5: int = 40


## slice spark — 칼이 재료를 가를 때 튀는 짧은 흰/노랑 선 burst (one-shot).
static func slice_spark(parent: Node, at: Vector2, dir_deg: float = 90.0) -> void:
	if parent == null or not is_instance_valid(parent):
		return
	var holder := Node2D.new()
	holder.position = at
	holder.rotation = deg_to_rad(dir_deg)
	holder.z_index = _L5
	parent.add_child(holder)
	for i in range(5):
		var line := Line2D.new()
		var spread: float = deg_to_rad(randf_range(-32.0, 32.0))
		var len: float = randf_range(38.0, 74.0)
		line.points = PackedVector2Array([Vector2.ZERO, Vector2(cos(spread), sin(spread)) * len])
		line.width = randf_range(3.0, 6.0)
		line.default_color = Color(1.0, 0.95, 0.7, 0.95) if i % 2 == 0 else Color(1.0, 1.0, 1.0, 0.9)
		holder.add_child(line)
	var tw := holder.create_tween()
	tw.tween_property(holder, "scale", Vector2(1.5, 1.5), 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(holder, "modulate:a", 0.0, 0.22)
	tw.tween_callback(holder.queue_free)


## oil splash — flip/panfry 시 팬에서 튀는 기름 방울 burst (one-shot).
static func oil_splash(parent: Node, at: Vector2, n: int = 8) -> void:
	if parent == null or not is_instance_valid(parent):
		return
	var holder := Control.new()
	holder.position = Vector2.ZERO
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.z_index = _L5
	parent.add_child(holder)
	for i in range(n):
		var drop := ColorRect.new()
		var sz: float = randf_range(8.0, 18.0)
		drop.color = Color(1.0, 0.86, 0.45, 0.85)
		drop.size = Vector2(sz, sz)
		drop.position = at - Vector2(sz, sz) * 0.5
		drop.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(drop)
		var ang: float = randf_range(-PI, 0.0)   # 위쪽 반구로 튐
		var dist: float = randf_range(80.0, 220.0)
		var dest: Vector2 = at + Vector2(cos(ang), sin(ang)) * dist
		var tw := drop.create_tween()
		tw.parallel().tween_property(drop, "position", dest - drop.size * 0.5, 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(drop, "modulate:a", 0.0, 0.34).set_delay(0.08)
	holder.create_tween().tween_callback(holder.queue_free).set_delay(0.5)


## serving sparkle / perfect ring — plate 완성 시 음식 둘레에 반짝 별 + 확장 ring (one-shot).
static func serving_sparkle(parent: Node, center: Vector2, n: int = 10) -> void:
	if parent == null or not is_instance_valid(parent):
		return
	var holder := Node2D.new()
	holder.position = center
	holder.z_index = _L5
	parent.add_child(holder)
	# expanding ring
	var ring := Line2D.new()
	var pts := PackedVector2Array()
	for a in range(33):
		var t: float = float(a) / 32.0 * TAU
		pts.append(Vector2(cos(t), sin(t)) * 120.0)
	ring.points = pts
	ring.width = 8.0
	ring.default_color = Color(1.0, 0.92, 0.55, 0.9)
	ring.closed = true
	holder.add_child(ring)
	var rtw := ring.create_tween()
	rtw.parallel().tween_property(ring, "scale", Vector2(2.4, 2.4), 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	rtw.parallel().tween_property(ring, "modulate:a", 0.0, 0.6)
	# sparkle stars (4-point diamonds)
	for i in range(n):
		var star := Polygon2D.new()
		star.polygon = PackedVector2Array([Vector2(0, -14), Vector2(5, 0), Vector2(0, 14), Vector2(-5, 0)])
		star.color = Color(1.0, 0.97, 0.78, 1.0)
		var a2: float = float(i) / float(n) * TAU + randf_range(-0.2, 0.2)
		var r: float = randf_range(90.0, 200.0)
		star.position = Vector2(cos(a2), sin(a2)) * r * 0.4
		holder.add_child(star)
		var dest := Vector2(cos(a2), sin(a2)) * r
		var stw := star.create_tween()
		stw.parallel().tween_property(star, "position", dest, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		stw.parallel().tween_property(star, "scale", Vector2(0.2, 0.2), 0.5)
		stw.parallel().tween_property(star, "modulate:a", 0.0, 0.5).set_delay(0.15)
	holder.create_tween().tween_callback(holder.queue_free).set_delay(0.75)


## stir motion trail — stir 시 주걱 자취(반투명 호) 한 획 (one-shot, 호출마다 누적 fade).
static func stir_trail(parent: Node, center: Vector2, radius: float, angle: float) -> void:
	if parent == null or not is_instance_valid(parent):
		return
	var dot := ColorRect.new()
	dot.color = Color(1.0, 0.95, 0.8, 0.4)
	dot.size = Vector2(26, 26)
	dot.position = center + Vector2(cos(angle), sin(angle)) * radius - dot.size * 0.5
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dot.z_index = _L5
	parent.add_child(dot)
	var tw := dot.create_tween()
	tw.tween_property(dot, "modulate:a", 0.0, 0.5)
	tw.tween_callback(dot.queue_free)
