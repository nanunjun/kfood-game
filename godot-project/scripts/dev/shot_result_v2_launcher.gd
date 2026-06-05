## shot_result_v2_launcher.gd — picks scenario via command-line --scenario arg,
## then delegates to shot_result_v2.gd.
##
## Usage:
##   godot --quit-after 8 res://scenes/shot_result_v2_launch.tscn -- --scenario=01_excellent_with_new_record --out=user://shot_result_v2_01.png
##
## Falls back to scenario 01 if no args given.
extends Node


func _ready() -> void:
	var scenario: String = "01_excellent_with_new_record"
	var out_path: String = "user://shot_result_v2_01.png"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--scenario="):
			scenario = arg.substr("--scenario=".length())
		elif arg.begins_with("--out="):
			out_path = arg.substr("--out=".length())
	# Forward args to shot_result_v2 statics
	var ShotScript := preload("res://scripts/dev/shot_result_v2.gd")
	ShotScript.scenario = scenario
	ShotScript.out_path = out_path
	# Replace ourselves with a fresh helper node carrying that static state.
	var helper := ShotScript.new()
	get_tree().root.add_child.call_deferred(helper)
	queue_free()
