## shot_slice_season_fix.gd — verification shots for the two visual fixes (2026-06-08).
##
## FIX 1 (Slice knife scale): knife was toy-sized (200px ≈ 28% board width). Now 420px
##   (≈58% board width, within the 50-65% Slice 비례 룰). Renders before/after by resizing
##   the knife sprite to the OLD dims for `slice_before`, leaving the new dims for `slice_after`.
##
## FIX 2 (Season vessel tint bug): seasoning used to modulate the whole dish-with-bowl image
##   (_food_hero), turning the BOWL red. Now the vessel (VesselSprite) is NEVER modulated;
##   only FoodContentSprite or SeasoningOverlay (bowl-inner broth mask) changes color.
##   ramyeon (t1_002) has no content_only → SeasoningOverlay path. Renders:
##     ramyeon_season_before  — no pour yet (broth/vessel original color)
##     ramyeon_season_after   — balanced pour (broth warm red, BOWL untouched)
##     ramyeon_season_too_much— overdose (broth darker red, BOWL still untouched)
##   Each season shot ALSO asserts _food_hero.modulate == white (vessel tint == 0).
##
## Run via shot_slice_season_fix.tscn (opengl3, real viewport — needs an actual image).
extends Node

const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")

# OLD knife dims (for the before shot) — must match the pre-fix KNIFE_RECT.
const OLD_KNIFE_SIZE := Vector2(200, 360)
const NEW_KNIFE_SIZE := Vector2(420, 756)
const BOARD_W := 720.0   # SliceModule.BOARD_RECT width — for % reporting.


func _ready() -> void:
	await get_tree().process_frame
	var bc := get_node_or_null("/root/BeatClock")
	if bc and bc.has_method("start"):
		bc.start()
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("reset_progress"):
		sm.reset_progress()

	print("[fix-shot] === FIX 1: Slice knife scale ===")
	print("[fix-shot] board width = %.0f px" % BOARD_W)
	print("[fix-shot] OLD knife = %.0f px = %.1f%% board width" % [OLD_KNIFE_SIZE.x, OLD_KNIFE_SIZE.x / BOARD_W * 100.0])
	print("[fix-shot] NEW knife = %.0f px = %.1f%% board width" % [NEW_KNIFE_SIZE.x, NEW_KNIFE_SIZE.x / BOARD_W * 100.0])

	await _shot_slice("slice_before", true)    # force old knife size
	await _shot_slice("slice_after", false)     # new size (as-built)

	print("[fix-shot] === FIX 2: Ramyeon season vessel-tint ===")
	await _shot_season("ramyeon_season_before", 0.0)
	await _shot_season("ramyeon_season_after", 0.85)     # balanced
	await _shot_season("ramyeon_season_too_much", 1.28)  # overdose

	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _mount_bg() -> Node:
	var bg = KitchenBackgroundScript.new()
	bg.env_key = "home"
	get_tree().root.add_child(bg)
	return bg


func _params(food_id: String) -> Dictionary:
	return {
		"food_id": food_id, "guest_id": "junho",
		"level": MenuDB.get_level(1), "menu": MenuDB.get_menu(food_id),
		"step_no": 1, "step_total": 4,
	}


func _capture(name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var vtex := get_viewport().get_texture()
	var img: Image = vtex.get_image() if vtex != null else null
	var out := "user://fix_%s.png" % name
	if img != null:
		img.save_png(out)
		print("[fix-shot] %s -> %s (%dx%d)" % [name, ProjectSettings.globalize_path(out),
			img.get_width(), img.get_height()])
	else:
		print("[fix-shot] %s — NO IMAGE (dummy renderer)" % name)


# --- FIX 1: Slice ---
func _shot_slice(name: String, force_old_knife: bool) -> void:
	var bg := _mount_bg()
	var packed := load("res://scenes/cooking/slice_module.tscn") as PackedScene
	var inst: Node = packed.instantiate()
	get_tree().root.add_child(inst)
	if inst.has_method("start"):
		inst.start(_params("t1_002"))   # 라면 = green_onion whole→chopped (real sprites).
	await get_tree().create_timer(0.8).timeout
	# If reproducing the pre-fix bug, shrink the knife sprite back to the old dims.
	if force_old_knife:
		_resize_knife(inst, OLD_KNIFE_SIZE)
		await get_tree().process_frame
	await _capture(name)
	inst.queue_free()
	bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


## Resize the live knife wrapper's inner TextureRect to `size` (re-centres origin offset).
func _resize_knife(slice: Node, size: Vector2) -> void:
	var knife = slice.get("_knife")
	if knife == null or not is_instance_valid(knife):
		print("[fix-shot] WARN: _knife not found for resize")
		return
	for child in knife.get_children():
		if child is TextureRect:
			(child as TextureRect).size = size
			(child as TextureRect).position = -size * Vector2(0.30, 0.30) if size == NEW_KNIFE_SIZE else -size * Vector2(0.5, 0.18)
			break


# --- FIX 2: Season ---
func _shot_season(name: String, poured: float) -> void:
	var bg := _mount_bg()
	var packed := load("res://scenes/cooking/season_module.tscn") as PackedScene
	var inst: Node = packed.instantiate()
	get_tree().root.add_child(inst)
	if inst.has_method("start"):
		inst.start(_params("t1_002"))   # 라면 = dish-with-bowl 단일 이미지 → SeasoningOverlay path.
	await get_tree().create_timer(0.8).timeout
	# Drive the pour to the requested amount and apply the (fixed) tint.
	inst.set("_poured", poured)
	if inst.has_method("_apply_food_tint"):
		inst.call("_apply_food_tint")
	await get_tree().process_frame
	await get_tree().process_frame
	# ASSERT: the vessel-containing _food_hero must NEVER be modulated (stays white).
	_assert_vessel_untouched(inst, name)
	await _capture(name)
	inst.queue_free()
	bg.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


func _assert_vessel_untouched(season: Node, name: String) -> void:
	var hero = season.get("_food_hero")
	var overlay = season.get("_season_overlay")
	if hero != null and is_instance_valid(hero):
		var m: Color = (hero as CanvasItem).modulate
		var ok: bool = is_equal_approx(m.r, 1.0) and is_equal_approx(m.g, 1.0) and is_equal_approx(m.b, 1.0)
		print("[fix-shot][assert] %s: VesselSprite(_food_hero).modulate = (%.3f,%.3f,%.3f) -> vessel_tint=%s" % [
			name, m.r, m.g, m.b, ("ZERO (PASS)" if ok else "NONZERO (FAIL!)")])
	else:
		print("[fix-shot][assert] %s: _food_hero null" % name)
	if overlay != null and is_instance_valid(overlay):
		var oc: Color = overlay.get("broth_color")
		print("[fix-shot][assert] %s: SeasoningOverlay broth alpha = %.3f (col %.2f,%.2f,%.2f)" % [
			name, oc.a, oc.r, oc.g, oc.b])
