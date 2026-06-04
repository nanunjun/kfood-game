## Tuning — 런타임 튜닝 다이얼 (autoload, M0).
##
## rhythm-prototype-spec §10 / reveal-plating-spec §D 의 파라미터. DebugPanel에서 조정, user://tuning.cfg 저장.
## autoload 이름(Tuning)과 class_name 충돌 금지 → class_name 미사용.
extends Node

const CFG_PATH := "user://tuning.cfg"

# 리듬 손맛
var approach_time_ms: float = 1100.0
var perfect_window_scale: float = 1.0
var good_window_scale: float = 1.0
var feedback_particle_intensity: float = 1.0
var glow_intensity: float = 1.0
var screen_shake_miss_px: float = 2.0
var haptic_strength: float = 0.8
var seasoning_increment: float = 1.0
var audio_offset_ms: float = 0.0
var visual_offset_ms: float = 0.0
# 볼륨(dB)
var sfx_db: float = 0.0
var judge_db: float = -3.0
var ambient_db: float = -12.0
# reveal·plating
var plating_time_ms: float = 5000.0
var reveal_zoom: float = 1.12
var reveal_tilt_deg: float = -2.0
var reveal_hold_ms: float = 150.0


func _ready() -> void:
	load_cfg()


func load_cfg() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CFG_PATH) != OK:
		return
	for key in _keys():
		if cfg.has_section_key("tuning", key):
			set(key, cfg.get_value("tuning", key))


func save_cfg() -> void:
	var cfg := ConfigFile.new()
	for key in _keys():
		cfg.set_value("tuning", key, get(key))
	cfg.save(CFG_PATH)


func _keys() -> PackedStringArray:
	return PackedStringArray([
		"approach_time_ms", "perfect_window_scale", "good_window_scale",
		"feedback_particle_intensity", "glow_intensity", "screen_shake_miss_px",
		"haptic_strength", "seasoning_increment", "audio_offset_ms", "visual_offset_ms",
		"sfx_db", "judge_db", "ambient_db",
		"plating_time_ms", "reveal_zoom", "reveal_tilt_deg", "reveal_hold_ms",
	])
