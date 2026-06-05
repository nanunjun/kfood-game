## CookingBackground — D3 shared procedural kitchen backdrop.
##
## Replaces the "floating dish in beige void" feel for the 8 cooking modules with a
## 3-band layered composite:
##   - top 1/3       : warm cream/peach gradient (kitchen wall — pleasant, low-contrast)
##   - middle 1/3    : food working area (left clean for tools/dishes)
##   - bottom 1/3    : warm brown countertop strip with slim grain accent lines
##
## Drawn purely with `_draw()` (no art assets) — gameplay 무영향. Always added FIRST
## as a child of the module host so action puck + dish + tools render on top.
##
## Bonus: emits a soft warm radial highlight under where the dish sits (~Y=950) so the
## food anchors visually instead of floating.
extends Control

const W := 1080.0
const H := 1920.0

@export var dish_anchor_y: float = 1000.0  # vertical center of the "spotlight" pool


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	# --- Band 1 : kitchen wall (top, soft warm gradient) ---
	var wall := Gradient.new()
	wall.set_color(0, Color(0.985, 0.910, 0.830))   # warm cream-peach
	wall.add_point(0.55, Color(0.988, 0.938, 0.875))
	wall.set_color(1, Color(0.985, 0.952, 0.895))    # near-white meeting band
	var wall_h: float = H * 0.55
	var bands := 48
	for i in range(bands):
		var t: float = float(i) / float(bands)
		draw_rect(Rect2(0, t * wall_h, W, wall_h / float(bands) + 1.0), wall.sample(t))

	# --- Soft warm spotlight pool under the dish anchor ---
	_draw_spotlight(Vector2(W * 0.5, dish_anchor_y), 560.0, Color(1.0, 0.92, 0.78, 0.35))

	# --- Band 3 : countertop (bottom 1/3) ---
	var counter_y := H * 0.72
	var counter_h := H - counter_y
	var counter_grad := Gradient.new()
	counter_grad.set_color(0, Color(0.74, 0.55, 0.36))   # warm honey wood top edge
	counter_grad.add_point(0.18, Color(0.62, 0.42, 0.24))
	counter_grad.set_color(1, Color(0.42, 0.27, 0.16))    # deep walnut bottom
	var cbands := 32
	for i in range(cbands):
		var t: float = float(i) / float(cbands)
		draw_rect(Rect2(0, counter_y + t * counter_h, W, counter_h / float(cbands) + 1.0),
			counter_grad.sample(t))
	# Lit highlight edge along the very top of the countertop
	draw_rect(Rect2(0, counter_y - 4.0, W, 6.0), Color(0.94, 0.78, 0.50, 0.85))
	draw_rect(Rect2(0, counter_y, W, 3.0), Color(0.20, 0.12, 0.06, 0.45))
	# Slim wood-grain accent lines (4 evenly spaced, subtle)
	for grain_i in range(4):
		var gy: float = counter_y + counter_h * (0.18 + 0.20 * float(grain_i))
		draw_line(Vector2(0, gy), Vector2(W, gy), Color(0.30, 0.18, 0.10, 0.18), 2.0)

	# --- Subtle bottom vignette so the action puck pops ---
	for i in range(20):
		var t2: float = float(i) / 20.0
		var a: float = 0.12 * (1.0 - t2)
		draw_rect(Rect2(0, H - (1.0 - t2) * 60.0, W, 60.0 / 20.0 + 1.0),
			Color(0, 0, 0, a))


func _draw_spotlight(center: Vector2, radius: float, base_color: Color) -> void:
	# Cheap radial soft light: concentric circles with falling alpha.
	var rings: int = 16
	for i in range(rings):
		var t: float = float(i) / float(rings)
		var r: float = radius * (1.0 - t * 0.85)
		var a: float = base_color.a * (1.0 - t)
		draw_circle(center, r, Color(base_color.r, base_color.g, base_color.b, a))
