## CP-36 CharacterIdleAnimator — Tween scale 1.0 <-> 1.02 / 2s breathing loop.
##
## Visual-only. Attach to any Control to give it a subtle idle "breathing" pulse.
## Use as a static helper or instantiate per node.
##
## Use:
##   CharacterIdleAnimator.attach(my_avatar_control)              # 2s default
##   CharacterIdleAnimator.attach(node, 1.04, 1.8)                # bigger / faster
class_name CharacterIdleAnimator
extends Node

## Apply breathing tween to `target`. Sets target.pivot_offset to center automatically.
## Returns the tween (looping) so caller can kill if needed.
static func attach(target: Control, scale_max: float = 1.02, period_s: float = 2.0) -> Tween:
	if target == null or not is_instance_valid(target):
		return null
	# pivot_offset must be center for the scale to "breathe" not "drift"
	if target.size != Vector2.ZERO:
		target.pivot_offset = target.size * 0.5
	# Defer one frame in case size isn't computed yet — recapture pivot.
	target.call_deferred("set", "pivot_offset", target.size * 0.5)
	var tw: Tween = target.create_tween().set_loops()
	tw.tween_property(target, "scale", Vector2(scale_max, scale_max), period_s * 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(target, "scale", Vector2.ONE, period_s * 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tw


## Heavier "excited bounce" idle — useful on RECOMMENDED guest cards.
static func attach_excited(target: Control, scale_max: float = 1.05, period_s: float = 1.4) -> Tween:
	return attach(target, scale_max, period_s)
