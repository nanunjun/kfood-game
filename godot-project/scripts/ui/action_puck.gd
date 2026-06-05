## ActionPuck — D2 unified circular action button (5 states).
##
## Replaces the orange/brown rectangular TAP/STIR/FLIP/STOP/PRESS buttons across the 8
## cooking modules with one consistent premium-feel circular puck. Drop-in: exposes the
## same `pressed` signal that the old `Button` exposed; downstream signal contracts
## (button_down / button_up for hold-modules like Roll) are also forwarded.
##
## Five visual states (CP-34 drop shadow + CP-35 sparkle reuse, no new art):
##   - idle    : base persimmon fill + soft outer glow + 12px Y drop shadow
##   - hover   : scale 1.05 + brighter fill
##   - active  : scale 0.95 + inner highlight (mouse held)
##   - perfect : gold flash + radial sparkle burst + bounce 1.0 -> 1.20 -> 1.0
##   - miss    : red flash + shake (±10 px) + dimmed alpha
##
## Wire (slice_module.gd etc.):
##   var puck := ActionPuckScript.new()
##   puck.setup("TAP", Vector2(540, 1570))   # center position, label
##   puck.pressed.connect(_on_tap)
##   add_child(puck)
##   # On judgement:
##   puck.flash_perfect() / puck.flash_miss()
##
## Gameplay 절대 무변경 — visual swap only. Signal timing identical to a Button.
class_name ActionPuck
extends Control

const SparkleScript := preload("res://scripts/ui/premium/sparkle_particle.gd")

signal pressed
signal button_down
signal button_up
signal state_changed(state: String)

enum State { IDLE, HOVER, ACTIVE, PERFECT, MISS }

const DEFAULT_DIAMETER: float = 280.0
const COLOR_IDLE := Color(0.878, 0.298, 0.141)      # premium persimmon #E04C24
const COLOR_IDLE_DEEP := Color(0.620, 0.180, 0.080) # darker rim
const COLOR_HOVER := Color(0.945, 0.380, 0.196)
const COLOR_PERFECT := Color(0.980, 0.780, 0.220)   # gold
const COLOR_MISS := Color(0.820, 0.220, 0.160)      # alarm red
const TEXT_COLOR := Color(1.0, 0.985, 0.950)

@export var diameter: float = DEFAULT_DIAMETER
@export var label_text: String = "TAP"
@export var font_size: int = 56

var _state: int = State.IDLE
var _btn: Button = null
var _ring_glow: Panel = null
var _inner_highlight: Panel = null
var _label_node: Label = null
var _origin_pos: Vector2 = Vector2.ZERO
var _origin_scale: Vector2 = Vector2.ONE
var _is_button_down: bool = false


func _ready() -> void:
	custom_minimum_size = Vector2(diameter, diameter)
	size = custom_minimum_size
	pivot_offset = size * 0.5
	mouse_filter = Control.MOUSE_FILTER_PASS
	_rebuild()


## One-call setup. `center` is the desired puck center (not top-left).
func setup(label: String, center: Vector2 = Vector2.ZERO, diam: float = DEFAULT_DIAMETER, fsize: int = 56) -> void:
	label_text = label
	diameter = diam
	font_size = fsize
	custom_minimum_size = Vector2(diameter, diameter)
	size = custom_minimum_size
	if center != Vector2.ZERO:
		position = center - size * 0.5
	pivot_offset = size * 0.5
	_origin_pos = position
	_rebuild()


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	# Outer soft glow ring (sits behind the puck) — gives the "puck floats" feel.
	_ring_glow = Panel.new()
	_ring_glow.position = Vector2(-12, -12)
	_ring_glow.size = size + Vector2(24, 24)
	_ring_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rgsb := StyleBoxFlat.new()
	rgsb.bg_color = Color(COLOR_IDLE.r, COLOR_IDLE.g, COLOR_IDLE.b, 0.22)
	rgsb.set_corner_radius_all(int(diameter * 0.6 + 24))
	rgsb.shadow_size = 18
	rgsb.shadow_color = Color(0.15, 0.05, 0.02, 0.45)
	rgsb.shadow_offset = Vector2(0, 12)
	_ring_glow.add_theme_stylebox_override("panel", rgsb)
	add_child(_ring_glow)

	# Main circular button (Button so pressed/button_down/button_up signals just work).
	_btn = Button.new()
	_btn.position = Vector2.ZERO
	_btn.size = size
	_btn.text = ""  # label drawn separately so we can tween color independently
	_btn.flat = false
	_btn.add_theme_stylebox_override("normal", _make_face_stylebox(COLOR_IDLE))
	_btn.add_theme_stylebox_override("hover", _make_face_stylebox(COLOR_HOVER))
	_btn.add_theme_stylebox_override("pressed", _make_face_stylebox(COLOR_IDLE_DEEP))
	_btn.add_theme_stylebox_override("focus", _make_face_stylebox(COLOR_HOVER, true))
	_btn.add_theme_stylebox_override("disabled", _make_face_stylebox(COLOR_IDLE.darkened(0.30)))
	add_child(_btn)
	# Forward signals
	_btn.pressed.connect(_on_btn_pressed)
	_btn.button_down.connect(_on_btn_down)
	_btn.button_up.connect(_on_btn_up)
	_btn.mouse_entered.connect(_on_btn_hover)
	_btn.mouse_exited.connect(_on_btn_unhover)

	# Inner highlight crescent (top half) — adds depth without art.
	_inner_highlight = Panel.new()
	_inner_highlight.position = Vector2(diameter * 0.10, diameter * 0.10)
	_inner_highlight.size = Vector2(diameter * 0.80, diameter * 0.45)
	_inner_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ihsb := StyleBoxFlat.new()
	ihsb.bg_color = Color(1.0, 1.0, 1.0, 0.22)
	ihsb.set_corner_radius_all(int(diameter * 0.40))
	_inner_highlight.add_theme_stylebox_override("panel", ihsb)
	add_child(_inner_highlight)

	# Label on top.
	_label_node = Label.new()
	_label_node.text = label_text
	_label_node.set_anchors_preset(Control.PRESET_FULL_RECT)
	_label_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label_node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label_node.add_theme_font_size_override("font_size", font_size)
	_label_node.add_theme_color_override("font_color", TEXT_COLOR)
	_label_node.add_theme_color_override("font_outline_color", Color(0.20, 0.08, 0.02, 0.85))
	_label_node.add_theme_constant_override("outline_size", 5)
	_label_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label_node)

	_origin_pos = position
	_origin_scale = scale


func _make_face_stylebox(col: Color, focused: bool = false) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(int(diameter * 0.50))  # full circle
	sb.set_border_width_all(6)
	sb.border_color = col.darkened(0.35)
	sb.shadow_size = 10
	sb.shadow_color = Color(0, 0, 0, 0.32)
	sb.shadow_offset = Vector2(0, 6)
	if focused:
		sb.border_color = Color(1.0, 0.92, 0.55)
	return sb


# --- state API ---

func set_state(s: int) -> void:
	if _state == s:
		return
	_state = s
	state_changed.emit(_state_name(s))


func _state_name(s: int) -> String:
	match s:
		State.IDLE: return "idle"
		State.HOVER: return "hover"
		State.ACTIVE: return "active"
		State.PERFECT: return "perfect"
		State.MISS: return "miss"
	return "idle"


## Update the label without rebuilding (FLIP module switches WAIT… → FLIP! → BURNT).
func set_label(t: String) -> void:
	label_text = t
	if is_instance_valid(_label_node):
		_label_node.text = t


## Set the face tint without changing state — used by FLIP module for WAIT (grey)
## → READY (orange) → LATE (dark red) without firing a perfect/miss flash.
func set_face_color(col: Color) -> void:
	if not is_instance_valid(_btn):
		return
	_btn.add_theme_stylebox_override("normal", _make_face_stylebox(col))
	_btn.add_theme_stylebox_override("hover", _make_face_stylebox(col.lightened(0.10)))
	_btn.add_theme_stylebox_override("pressed", _make_face_stylebox(col.darkened(0.18)))


## Gold flash + sparkle + bounce. Returns to idle after ~0.7s.
func flash_perfect() -> void:
	set_state(State.PERFECT)
	set_face_color(COLOR_PERFECT)
	# Bounce 1.0 → 1.20 → 1.0
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2(1.20, 1.20), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", _origin_scale, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	# Sparkle burst around center (CP-35 reuse) — fire-and-forget; SparkleParticle
	# auto queue_frees itself.
	var sp = SparkleScript.new()
	add_child(sp)
	sp.burst(size * 0.5, 18, diameter * 0.55, Color(1.0, 0.92, 0.50), 0.75)
	# Return color to idle after a beat so the next interaction starts clean.
	var rc := create_tween()
	rc.tween_interval(0.70)
	rc.tween_callback(_reset_to_idle)


## Red flash + shake + dim. Returns to idle after ~0.7s.
func flash_miss() -> void:
	set_state(State.MISS)
	set_face_color(COLOR_MISS)
	modulate.a = 0.85
	# Shake ±10 px on X
	var ox: float = _origin_pos.x
	var tw := create_tween()
	for i in range(5):
		var off: float = 10.0 if i % 2 == 0 else -10.0
		tw.tween_property(self, "position:x", ox + off, 0.04)
	tw.tween_property(self, "position:x", ox, 0.04)
	var rc := create_tween()
	rc.tween_interval(0.70)
	rc.tween_callback(_reset_to_idle_miss)


# Tween callbacks — extracted to named methods to avoid closure capture issues.
func _reset_to_idle() -> void:
	if not is_inside_tree():
		return
	set_face_color(COLOR_IDLE)
	set_state(State.IDLE)


func _reset_to_idle_miss() -> void:
	if not is_inside_tree():
		return
	modulate.a = 1.0
	set_face_color(COLOR_IDLE)
	set_state(State.IDLE)


# --- input event passthrough -> state machine ---

func _on_btn_pressed() -> void:
	pressed.emit()


func _on_btn_down() -> void:
	_is_button_down = true
	set_state(State.ACTIVE)
	if _state != State.PERFECT and _state != State.MISS:
		var tw := create_tween()
		tw.tween_property(self, "scale", _origin_scale * 0.95, 0.08).set_trans(Tween.TRANS_SINE)
	button_down.emit()


func _on_btn_up() -> void:
	_is_button_down = false
	if _state == State.ACTIVE:
		set_state(State.IDLE)
		var tw := create_tween()
		tw.tween_property(self, "scale", _origin_scale, 0.10).set_trans(Tween.TRANS_BACK)
	button_up.emit()


func _on_btn_hover() -> void:
	if _state == State.IDLE:
		set_state(State.HOVER)
		var tw := create_tween()
		tw.tween_property(self, "scale", _origin_scale * 1.05, 0.10).set_trans(Tween.TRANS_SINE)


func _on_btn_unhover() -> void:
	if _state == State.HOVER and not _is_button_down:
		set_state(State.IDLE)
		var tw := create_tween()
		tw.tween_property(self, "scale", _origin_scale, 0.10).set_trans(Tween.TRANS_SINE)


# --- convenience ---

## Disable interactions (used by FLIP "BURNT" / "auto-finish" states).
func set_disabled(disabled: bool) -> void:
	if is_instance_valid(_btn):
		_btn.disabled = disabled
