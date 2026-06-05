## shot_result_v2.gd — instantiates ResultScreenV2 with a synthesized payload and
## screenshots it. Scenario selected by `scenario` static var.
##
## Use:
##   godot --headless? NO — we need rendering for screenshot.
##   godot --quit-after 6 res://scenes/shot_result_v2.tscn  (after setting scenario)
##
## Or rely on the wrapper scenes shot_result_v2_01...04 that set scenario then load this.
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const ResultV2Scene := preload("res://scenes/ui/result_screen_v2.tscn")

static var scenario: String = "01_excellent_with_new_record"
static var out_path: String = "user://shot_result_v2_01.png"


func _ready() -> void:
	print("[shot_result_v2] scenario=%s out=%s" % [scenario, out_path])
	# Wipe saves so each scenario starts from a clean state.
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		sm.reset_progress()
	var payload: Dictionary = _make_payload(scenario)
	var screen := ResultV2Scene.instantiate()
	screen.setup(payload)
	get_tree().root.add_child(screen)
	# wait for scene tree + initial reveal start
	for i in range(6):
		await get_tree().process_frame
	# Force the reveal sequence to complete so all elements are visible.
	if screen.has_method("force_play_all_reveals"):
		screen.force_play_all_reveals()
	# Tween chain runs up to ~5s — wait that long for it to settle.
	await get_tree().create_timer(5.6).timeout
	# Scroll up half-way to capture both above-fold + breakdown
	var sc: ScrollContainer = screen.get_node_or_null("ScrollContainer")
	if sc == null:
		# fall back to manual lookup
		for child in screen.get_children():
			if child is ScrollContainer:
				sc = child as ScrollContainer
				break
	if sc != null:
		sc.scroll_vertical = 0
	# Two captures: one from top (above-the-fold) — we keep this single full-screen pass.
	await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(out_path)
	var global_out: String = ProjectSettings.globalize_path(out_path)
	print("[shot_result_v2] saved (err=%d) -> %s  (%dx%d)" % [err, global_out, img.get_width(), img.get_height()])
	# Second capture: scrolled to bottom for breakdown + rewards.
	if sc != null:
		sc.scroll_vertical = 9999  # clamps to max
		await get_tree().process_frame
		await get_tree().process_frame
		var img2 := get_viewport().get_texture().get_image()
		var out2: String = out_path.replace(".png", "_bottom.png")
		var err2 := img2.save_png(out2)
		print("[shot_result_v2] bottom saved (err=%d) -> %s" % [err2, ProjectSettings.globalize_path(out2)])
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


# Construct a payload for each scenario.
func _make_payload(s: String) -> Dictionary:
	match s:
		"01_excellent_with_new_record":
			# kimchi_jjigae + Junho (happy) -> compat 93, ★3, milestone 3 unlock.
			var menu: Dictionary = MenuDB.get_menu("m_kimchi_jjigae")
			var guest: Dictionary = MenuDB.get_guest("junho")
			# pre-add friendship to land exactly at lv 3 milestone (no rounding)
			var sm := get_node_or_null("/root/SaveManager")
			if sm:
				sm.add_friendship("junho", 2)  # 0 -> 2 (no milestone yet)
				sm.friendship_milestone_pending("junho")  # consume any
			return _compose(menu, guest, "happy", 93, 3, 8800, 9100,
				true, 0, 3, 3, 59, 59, "excellent",
				"Junho loved the spicy kick! Now THAT'S a kick — love it!")
		"02_okay_no_record":
			var menu: Dictionary = MenuDB.get_menu("t1_004")  # gimbap
			var guest: Dictionary = MenuDB.get_guest("mina")
			return _compose(menu, guest, "easy", 62, 2, 6800, 7100,
				false, 6500, 0, 2, 26, 60, "okay",
				"Mina shrugged. Could use a touch more sweet.")
		"03_bad_grumpy":
			var menu: Dictionary = MenuDB.get_menu("t1_004")  # gimbap (mild)
			var guest: Dictionary = MenuDB.get_guest("junho")  # wants spicy
			return _compose(menu, guest, "grumpy", 30, 1, 4800, 5200,
				false, 0, 0, 0, 13, 13, "bad",
				"Junho frowned — way too mild for him.")
		"04_milestone_lv7_banner":
			var menu: Dictionary = MenuDB.get_menu("m_kimchi_jjigae")
			var guest: Dictionary = MenuDB.get_guest("junho")
			# pre-add friendship to 6 so the +N round crosses Lv 7
			var sm2 := get_node_or_null("/root/SaveManager")
			if sm2:
				sm2.add_friendship("junho", 6)
				sm2.friendship_milestone_pending("junho")  # consume Lv 3 toast triggered above
			return _compose(menu, guest, "happy", 93, 4, 9100, 9400,
				true, 8900, 7, 7, 200, 300, "excellent",
				"Junho beamed — that spicy depth is exactly his style!")
		_:
			return {}


func _compose(menu: Dictionary, guest: Dictionary, mood: String, compat: int,
		stars: int, score: int, final_coin: int, record_broken: bool,
		record_prev_score: int, milestone: int, friendship_after: int,
		xp_gained: int, xp_total_after: int,
		emotion: String, reaction_text: String) -> Dictionary:
	var rc := get_node_or_null("/root/RewardCalc")
	var breakdown: Array = []
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
		"emotion_level": emotion,
		"reaction_text": reaction_text,
		"record_broken": record_broken,
		"record_prev_score": record_prev_score,
		"xp_gained": xp_gained,
		"xp_total_after": xp_total_after,
		"friendship_delta": maxi(0, friendship_after - 0),
		"friendship_after": friendship_after,
		"milestone_just_hit": milestone,
		"final_coin": final_coin,
		"passed": stars >= 2,
	}
