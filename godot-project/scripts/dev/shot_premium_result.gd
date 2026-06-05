## shot_premium_result.gd — Premium V1 result_screen_v2 screenshot.
##
## Scenario: Kimchi Stew + Junho 93%, Score 8800, ★3, NEW RECORD broken,
## Milestone Lv 3, 59 XP, coin spray 20 → wallet.
## Output: user://premium_v1_04_result.png  (top-of-screen above-the-fold capture).
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const ResultV2Scene := preload("res://scenes/ui/result_screen_v2.tscn")


func _ready() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		sm.reset_progress()
		sm.add_friendship("junho", 2)  # 0 -> 2, then milestone Lv 3 lands on this round
		sm.friendship_milestone_pending("junho")  # consume any
	# Defer one frame so root finishes setting up
	await get_tree().process_frame
	var payload: Dictionary = _make_payload()
	var screen = ResultV2Scene.instantiate()
	screen.setup(payload)
	get_tree().root.add_child(screen)
	# Wait for setup
	for i in range(12):
		await get_tree().process_frame
	# Force-play all scroll reveals so breakdown/rewards are visible if we scroll
	if screen.has_method("force_play_all_reveals"):
		screen.force_play_all_reveals()
	# Wait for reveal sequence: t=4.8 coin spray + 0.8 settle = ~5.6s
	await get_tree().create_timer(5.8).timeout
	# Above-the-fold capture (scroll = 0)
	var sc: ScrollContainer = null
	for c in screen.get_children():
		if c is ScrollContainer:
			sc = c
			break
	if sc != null:
		sc.scroll_vertical = 0
	await get_tree().process_frame
	await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var out_path: String = "user://premium_v1_04_result_top.png"
	var err := img.save_png(out_path)
	print("[shot_premium_result] top err=%d -> %s (%dx%d)" % [err,
		ProjectSettings.globalize_path(out_path), img.get_width(), img.get_height()])
	# Bottom capture (scrolled)
	if sc != null:
		sc.scroll_vertical = 9999
		await get_tree().process_frame
		await get_tree().process_frame
		var img2 := get_viewport().get_texture().get_image()
		var out2: String = "user://premium_v1_04_result_bottom.png"
		var err2 := img2.save_png(out2)
		print("[shot_premium_result] bottom err=%d -> %s" % [err2,
			ProjectSettings.globalize_path(out2)])
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _make_payload() -> Dictionary:
	var menu: Dictionary = MenuDB.get_menu("m_kimchi_jjigae")
	var guest: Dictionary = MenuDB.get_guest("junho")
	var rc := get_node_or_null("/root/RewardCalc")
	var breakdown: Array = []
	var score: int = 8800
	var compat: int = 93
	var stars: int = 3
	var mood: String = "happy"
	if rc != null:
		var prep := float(score) / 10000.0
		var cook := clampf(prep - 0.07, 0.0, 1.0)
		var season := clampf(prep + 0.04, 0.0, 1.0)
		var plating := clampf(prep + 0.10, 0.0, 1.0)
		breakdown = rc.score_breakdown_rows(prep, cook, season, plating, compat, mood, guest)
	return {
		"food": menu,
		"guest": guest,
		"mood": mood,
		"compat": compat,
		"stars": stars,
		"score": score,
		"score_norm": float(score) / 10000.0,
		"breakdown_rows": breakdown,
		"emotion_level": "excellent",
		"reaction_text": "Junho loved the spicy kick! Now THAT'S a kick — love it!",
		"record_broken": true,
		"record_prev_score": 0,
		"xp_gained": 59,
		"xp_total_after": 59,
		"friendship_delta": 3,
		"friendship_after": 3,
		"milestone_just_hit": 3,
		"final_coin": 9100,
		"passed": true,
	}
