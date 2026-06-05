## CP-39 CoinSprayParticle — 20 coin spray from origin → wallet HUD + count-up.
##
## Visual-only. Each coin = small Polygon2D circle (gold) tweened parabolically toward a
## destination point. Optional `wallet_label` Label has its number tweened on coin arrival.
##
## Usage:
##   var c := CoinSprayParticle.new()
##   parent.add_child(c)
##   c.spray(from_pos, to_pos, count=20, total_coin=120, wallet_label=label)
##
## Auto-frees after final coin lands.
class_name CoinSprayParticle
extends Node2D

const GOLD := Color(1.0, 0.85, 0.18)
const GOLD_DARK := Color(0.72, 0.50, 0.06)
const COIN_RADIUS := 14.0
const DEFAULT_COUNT := 20


func _coin_polygon() -> PackedVector2Array:
	# 16-sided gold disc
	var pts := PackedVector2Array()
	for i in range(16):
		var a: float = float(i) / 16.0 * TAU
		pts.append(Vector2(cos(a), sin(a)) * COIN_RADIUS)
	return pts


func spray(from_pos: Vector2, to_pos: Vector2, count: int = DEFAULT_COUNT,
		total_coin: int = 0, wallet_label: Label = null, wallet_start: int = 0) -> void:
	count = maxi(4, count)
	for i in range(count):
		var coin := Polygon2D.new()
		coin.polygon = _coin_polygon()
		coin.color = GOLD
		coin.position = from_pos
		# inner shadow disc
		add_child(coin)
		var inner := Polygon2D.new()
		var inpts := PackedVector2Array()
		for j in range(12):
			var ang: float = float(j) / 12.0 * TAU
			inpts.append(Vector2(cos(ang), sin(ang)) * (COIN_RADIUS * 0.55))
		inner.polygon = inpts
		inner.color = GOLD_DARK
		coin.add_child(inner)
		# Parabolic flight via two-stage tween + per-coin random offset
		var rand_off := Vector2(randf_range(-90.0, 90.0), randf_range(-140.0, -60.0))
		var peak: Vector2 = (from_pos + to_pos) * 0.5 + rand_off
		var stagger: float = float(i) * 0.025
		var flight: float = 0.55
		var tw := create_tween().set_parallel(true)
		tw.tween_property(coin, "position", peak, flight * 0.40)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).set_delay(stagger)
		tw.tween_property(coin, "position", to_pos, flight * 0.60)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN).set_delay(stagger + flight * 0.40)
		tw.tween_property(coin, "rotation", TAU * 2.0, flight).set_delay(stagger)
		tw.tween_property(coin, "scale", Vector2(1.4, 1.4), flight * 0.4)\
			.set_trans(Tween.TRANS_BACK).set_delay(stagger)
		tw.tween_property(coin, "scale", Vector2(0.2, 0.2), flight * 0.4)\
			.set_trans(Tween.TRANS_SINE).set_delay(stagger + flight * 0.6)
		tw.tween_property(coin, "modulate:a", 0.0, flight * 0.25)\
			.set_delay(stagger + flight * 0.75)
		tw.tween_callback(coin.queue_free).set_delay(stagger + flight + 0.05)
	# Wallet count-up tween
	if wallet_label != null and is_instance_valid(wallet_label) and total_coin > 0:
		var tw2 := create_tween()
		tw2.tween_interval(0.30)  # let coins start arriving
		tw2.tween_method(func(v: int) -> void:
			if is_instance_valid(wallet_label):
				wallet_label.text = _format_wallet(v),
			wallet_start, wallet_start + total_coin, 0.55)\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# auto-cleanup
	var done := create_tween()
	done.tween_interval(1.2 + float(count) * 0.025)
	done.tween_callback(queue_free)


func _format_wallet(n: int) -> String:
	# Match menu_select.gd "₩12,345" style
	var s := str(n)
	var out := ""
	var c := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = "," + out
	return "₩" + out
