## HapticManager — 판정별 진동 추상화 (autoload, M0).
##
## rhythm-prototype-spec §8. 모바일만 실제 진동, 데스크탑 no-op.
## Godot 기본은 세기 제어가 제한적(vibrate_handheld는 duration만) → 세기는 강도 스케일로 근사.
## 정밀 세기 필요 시 Android VibrationEffect / iOS Haptic Engine 플러그인으로 교체(브리지 지점 표시).
## autoload 이름과 class_name 충돌 금지.
extends Node

enum { PERFECT, GOOD, MISS, SEASONING, REVEAL }

# 판정 → (지속 ms)
const DUR := {
	PERFECT: 20,
	GOOD: 30,
	MISS: 50,
	SEASONING: 10,
	REVEAL: 40,
}


func play(kind: int) -> void:
	if not _enabled():
		return
	var ms: int = int(DUR.get(kind, 20))
	# 강도 근사: Tuning.haptic_strength 로 매우 짧은 진동 스케일(플랫폼 플러그인 연결 전 fallback)
	var scale: float = clampf(get_node("/root/Tuning").haptic_strength, 0.0, 1.0)
	if scale <= 0.0:
		return
	var dur: int = int(round(float(ms) * lerpf(0.5, 1.0, scale)))
	Input.vibrate_handheld(dur)
	# TODO(브리지): Android = VibrationEffect.createOneShot(dur, amplitude) / iOS = UIImpactFeedbackGenerator
	#   amplitude = PERFECT:255 sharp / GOOD:140 soft / MISS:90 / SEASONING:80 / REVEAL:120


func _enabled() -> bool:
	return DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")
