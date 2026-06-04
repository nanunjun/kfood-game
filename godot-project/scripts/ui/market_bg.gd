## MarketBG — procedural Korean traditional-market backdrop (M1+).
##
## Drawn with _draw() (no art assets needed yet): warm dusk sky gradient, hanok tiled
## rooflines with upturned eaves, a red/cream striped awning valance, hanging red paper
## lanterns (cheongsachorong), warm bokeh market lights, a wooden stall counter, soft vignette.
## Gives every screen a "browsing a Korean market" feel instead of a flat slide.
## Use: add an instance as the FIRST child of a Control screen (sits behind everything).
## `dim=true` tones decoration down for gameplay readability.
extends Control

const W := 1080.0
const H := 1920.0

@export var dim: bool = false
@export var light: bool = false   # gameplay: bright cream, minimal clutter (keeps dark text readable)

var _bokeh: Array = []      # [{pos, r, col}]
var _lanterns: Array = []   # x positions of hanging lanterns


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	# warm market bokeh lights up high
	var n := 10 if dim else 16
	for i in range(n):
		_bokeh.append({
			"pos": Vector2(rng.randf_range(40, W - 40), rng.randf_range(120, 560)),
			"r": rng.randf_range(8, 26),
			"a": rng.randf_range(0.05, 0.18),
		})
	_lanterns = [120.0, W - 120.0]
	queue_redraw()


func _sky() -> Gradient:
	var g := Gradient.new()
	g.set_offset(0, 0.0)
	if light:
		g.set_color(0, Color(0.99, 0.91, 0.78))   # warm cream top
		g.add_point(0.5, Color(0.99, 0.94, 0.85))
		g.set_color(1, Color(0.99, 0.96, 0.90))    # bright bottom
	else:
		g.set_color(0, Color(0.30, 0.20, 0.32))    # plum dusk top
		g.add_point(0.32, Color(0.86, 0.50, 0.34)) # warm sunset band
		g.add_point(0.60, Color(0.97, 0.80, 0.58)) # amber
		g.set_color(1, Color(0.99, 0.95, 0.89))    # cream bottom (cards read here)
	return g


func _draw() -> void:
	var sky := _sky()
	# 1. sky gradient (banded)
	var bands := 64
	for i in range(bands):
		var t := float(i) / float(bands)
		draw_rect(Rect2(0, t * H, W, H / float(bands) + 1.0), sky.sample(t))

	# light/gameplay mode: just a slim awning top + counter bottom, keep middle clean
	if light:
		_draw_awning(0.0, 46.0)
		var cy := H - 90.0
		draw_rect(Rect2(0, cy, W, 90.0), Color(0.40, 0.27, 0.17, 0.85))
		draw_rect(Rect2(0, cy, W, 8.0), Color(0.52, 0.36, 0.22))
		return

	# 2. far hanok rooftop silhouette (two tiers), muted blue-grey tile
	_draw_hanok_roof(0.0, 150.0, 540.0, Color(0.28, 0.30, 0.40, 0.85))
	_draw_hanok_roof(540.0, 150.0, 540.0, Color(0.24, 0.26, 0.36, 0.85))

	# 3. bokeh market lights
	for b in _bokeh:
		draw_circle(b["pos"], b["r"], Color(1.0, 0.85, 0.55, b["a"]))

	# 4. striped awning valance across the top
	_draw_awning(196.0, 78.0)

	# 5. hanging red paper lanterns
	for lx in _lanterns:
		_draw_lantern(Vector2(lx, 300.0))

	# 6. wooden stall counter band at the very bottom
	var counter_y := H - 150.0
	draw_rect(Rect2(0, counter_y, W, 150.0), Color(0.40, 0.27, 0.17))
	draw_rect(Rect2(0, counter_y, W, 10.0), Color(0.52, 0.36, 0.22))  # lit top edge
	for px in range(0, int(W), 150):
		draw_line(Vector2(px, counter_y + 10), Vector2(px, H), Color(0.30, 0.20, 0.12, 0.6), 3.0)

	# 7. soft vignette (top + bottom darken)
	var vtop := Gradient.new()
	vtop.set_color(0, Color(0, 0, 0, 0.22))
	vtop.set_color(1, Color(0, 0, 0, 0.0))
	for i in range(24):
		var t := float(i) / 24.0
		draw_rect(Rect2(0, t * 160.0, W, 160.0 / 24.0 + 1.0), vtop.sample(t))


func _draw_hanok_roof(x: float, top: float, w: float, col: Color) -> void:
	# gently curved tiled roof with upturned eaves
	var pts := PackedVector2Array()
	var ridge := top
	var eave := top + 64.0
	pts.append(Vector2(x, eave + 26.0))             # left tip (upturned)
	pts.append(Vector2(x + 40, eave))
	pts.append(Vector2(x + w * 0.5, ridge))         # ridge center
	pts.append(Vector2(x + w - 40, eave))
	pts.append(Vector2(x + w, eave + 26.0))         # right tip
	pts.append(Vector2(x + w, eave + 70.0))
	pts.append(Vector2(x, eave + 70.0))
	draw_colored_polygon(pts, col)
	# ridge highlight
	draw_line(Vector2(x + 40, eave), Vector2(x + w * 0.5, ridge), col.lightened(0.18), 5.0)
	draw_line(Vector2(x + w * 0.5, ridge), Vector2(x + w - 40, eave), col.lightened(0.18), 5.0)
	# tile lines
	for i in range(1, 9):
		var tx := x + w * float(i) / 9.0
		draw_line(Vector2(tx, eave + 6), Vector2(tx, eave + 66), col.darkened(0.18), 2.0)


func _draw_awning(y: float, h: float) -> void:
	# alternating red / cream vertical stripes
	var stripe := 64.0
	var i := 0
	var x := 0.0
	while x < W:
		var c := Color(0.80, 0.22, 0.18) if i % 2 == 0 else Color(0.98, 0.95, 0.90)
		draw_rect(Rect2(x, y, stripe, h), c)
		# scalloped bottom edge
		draw_circle(Vector2(x + stripe * 0.5, y + h), stripe * 0.5, c)
		x += stripe
		i += 1
	# shadow under awning
	draw_rect(Rect2(0, y + h + 24.0, W, 18.0), Color(0, 0, 0, 0.10))


func _draw_lantern(top: Vector2) -> void:
	# string
	draw_line(Vector2(top.x, 274.0), top, Color(0.25, 0.18, 0.12), 3.0)
	# gold caps
	draw_rect(Rect2(top.x - 22, top.y, 44, 14), Color(0.85, 0.66, 0.28))
	# body (red oval as stacked circles)
	for dy in range(0, 70, 6):
		var f: float = 1.0 - abs(35.0 - float(dy)) / 60.0
		draw_circle(Vector2(top.x, top.y + 18 + dy), 40.0 * (0.6 + 0.4 * f), Color(0.82, 0.18, 0.16))
	draw_circle(Vector2(top.x - 12, top.y + 34), 10.0, Color(0.95, 0.45, 0.35, 0.5))  # sheen
	draw_rect(Rect2(top.x - 22, top.y + 84, 44, 12), Color(0.85, 0.66, 0.28))
	# tassel
	for tx in [-10.0, 0.0, 10.0]:
		draw_line(Vector2(top.x + tx, top.y + 96), Vector2(top.x + tx, top.y + 128), Color(0.90, 0.55, 0.20), 3.0)
