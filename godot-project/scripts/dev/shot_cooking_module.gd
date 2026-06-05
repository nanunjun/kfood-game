## shot_cooking_module.gd — instantiates a single cooking module .tscn with synthetic
## params and screenshots it. Used by the Cooking Framework 2.0 verification sprint to
## produce the 6 lock screenshots.
##
## Usage (per wrapper scene):
##   ShotScript.module_scene = "res://scenes/cooking/slice_module.tscn"
##   ShotScript.params = {"food_id": "t1_002", ...}
##   ShotScript.out_path = "user://shot_cooking_slice.png"
extends Node

const MarketBG := preload("res://scripts/ui/market_bg.gd")
const MenuDB := preload("res://scripts/gameplay/menu_db.gd")

static var module_scene: String = "res://scenes/cooking/slice_module.tscn"
static var params: Dictionary = {}
static var out_path: String = "user://shot_cooking.png"
static var wait_seconds: float = 1.6


func _ready() -> void:
	print("[shot_cooking] scene=%s out=%s" % [module_scene, out_path])
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	# Backdrop so the screenshot doesn't end up on the editor's default clear color.
	var bg := MarketBG.new()
	bg.light = true
	get_tree().root.add_child(bg)
	var packed := load(module_scene) as PackedScene
	if packed == null:
		push_error("[shot_cooking] cannot load " + module_scene)
		get_tree().quit(); return
	var inst: Node = packed.instantiate()
	get_tree().root.add_child(inst)
	if inst.has_method("start"):
		inst.start(_default_params())
	# Let layout settle + visuals warm up (cake browning, gauge fill, etc.)
	await get_tree().create_timer(wait_seconds).timeout
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(out_path)
	print("[shot_cooking] saved (err=%d) -> %s  (%dx%d)" % [
		err, ProjectSettings.globalize_path(out_path), img.get_width(), img.get_height()])
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _default_params() -> Dictionary:
	if params.is_empty():
		# Generic safe defaults — Ramyeon Lv1
		var menu: Dictionary = MenuDB.get_menu("t1_002")
		var level: Dictionary = MenuDB.get_level(1)
		return {
			"food_id": "t1_002", "guest_id": "junho",
			"level": level, "menu": menu,
			"step_no": 1, "step_total": 4,
		}
	# Caller-provided params — but always inject level + menu if missing.
	var p: Dictionary = params.duplicate()
	if not p.has("level"):
		p["level"] = MenuDB.get_level(int(p.get("level_num", 1)))
	if not p.has("menu") and p.has("food_id"):
		p["menu"] = MenuDB.get_menu(String(p["food_id"]))
	if not p.has("step_no"):
		p["step_no"] = 1
	if not p.has("step_total"):
		p["step_total"] = 4
	return p
