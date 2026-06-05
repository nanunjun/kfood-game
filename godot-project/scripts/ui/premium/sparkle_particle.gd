## CP-35 SparkleParticle — radial star-burst particle effect.
##
## Placeholder = 4-point Polygon2D stars (no GPU particles dependency) spawned in a radial
## pattern, each tweened outward + faded out. Use:
##   var sp := SparkleParticle.new()
##   add_child(sp)
##   sp.burst(world_pos, count, radius, color, life_s)
##
## Pure visual — fires once then queue_free's itself after life_s + 0.2.
class_name SparkleParticle
extends Node2D

const DEFAULT_COUNT := 16
const DEFAULT_RADIUS := 140.0
const DEFAULT_LIFE := 0.65
const DEFAULT_COLOR := Color(1.0, 0.92, 0.55)


static func _star_4pt() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0, -10), Vector2(3, -3), Vector2(10, 0), Vector2(3, 3),
		Vector2(0, 10), Vector2(-3, 3), Vector2(-10, 0), Vector2(-3, -3)
	])


func burst(at: Vector2, count: int = DEFAULT_COUNT, radius: float = DEFAULT_RADIUS,
		color: Color = DEFAULT_COLOR, life_s: float = DEFAULT_LIFE) -> void:
	position = at
	count = maxi(4, count)
	for i in range(count):
		var angle: float = float(i) / float(count) * TAU
		var star := Polygon2D.new()
		star.polygon = _star_4pt()
		star.color = color
		star.position = Vector2.ZERO
		star.scale = Vector2(0.5, 0.5)
		add_child(star)
		var dest: Vector2 = Vector2(cos(angle), sin(angle)) * radius
		var tw := create_tween().set_parallel(true)
		tw.tween_property(star, "position", dest, life_s).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(star, "scale", Vector2(1.4, 1.4), life_s * 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(star, "scale", Vector2(0.0, 0.0), life_s * 0.5).set_trans(Tween.TRANS_SINE).set_delay(life_s * 0.4)
		tw.tween_property(star, "modulate:a", 0.0, life_s).set_delay(life_s * 0.2)
		tw.tween_property(star, "rotation", angle * 2.0, life_s).set_trans(Tween.TRANS_LINEAR)
	# auto cleanup
	var done := create_tween()
	done.tween_interval(life_s + 0.2)
	done.tween_callback(queue_free)


## Convenience: single-shot. Creates + adds + bursts in one call.
static func play_burst(parent: Node, at: Vector2, count: int = DEFAULT_COUNT,
		radius: float = DEFAULT_RADIUS, color: Color = DEFAULT_COLOR, life_s: float = DEFAULT_LIFE) -> SparkleParticle:
	if parent == null or not is_instance_valid(parent):
		return null
	var sp := SparkleParticle.new()
	parent.add_child(sp)
	sp.burst(at, count, radius, color, life_s)
	return sp


## Sparkle HALO — slow rotating ring of sparkles around an anchor (no auto-cleanup).
## Returns the node so caller can queue_free when needed.
func halo(at: Vector2, count: int = 8, radius: float = 90.0,
		color: Color = DEFAULT_COLOR) -> Node2D:
	position = at
	for i in range(count):
		var angle: float = float(i) / float(count) * TAU
		var star := Polygon2D.new()
		star.polygon = _star_4pt()
		star.color = color
		star.position = Vector2(cos(angle), sin(angle)) * radius
		star.scale = Vector2(0.7, 0.7)
		star.modulate.a = 0.75
		add_child(star)
		# breathing pulse
		var tw := create_tween().set_loops()
		tw.tween_property(star, "scale", Vector2(1.0, 1.0), 0.6 + float(i) * 0.05).set_trans(Tween.TRANS_SINE)
		tw.tween_property(star, "scale", Vector2(0.6, 0.6), 0.6 + float(i) * 0.05).set_trans(Tween.TRANS_SINE)
	# slow rotation
	var rot := create_tween().set_loops()
	rot.tween_property(self, "rotation", TAU, 6.0).set_trans(Tween.TRANS_LINEAR)
	return self
