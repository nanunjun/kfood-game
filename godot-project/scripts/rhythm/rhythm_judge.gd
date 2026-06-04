## RhythmJudge — 판정 로직 + 레벨별 윈도우 (M0 코어).
##
## rhythm-prototype-spec §2. 순수 함수 — 테스트·시뮬과 동일 로직.
class_name RhythmJudge
extends RefCounted

enum { PERFECT, GOOD, MISS }

# 레벨(1~8) → [perfect_half_ms, good_half_ms]  (spec §2 표)
const WINDOWS := {
	1: [90.0, 200.0], 2: [80.0, 175.0], 3: [70.0, 150.0], 4: [55.0, 120.0],
	5: [50.0, 110.0], 6: [45.0, 100.0], 7: [40.0, 90.0], 8: [36.0, 80.0],
}


## 레벨·도구·접근성 보정 후 (perfect, good) half-window(ms) 반환.
static func windows(level: int, tool_mult: float = 1.0, assist: float = 1.0,
		perfect_scale: float = 1.0, good_scale: float = 1.0) -> Array:
	var base: Array = WINDOWS.get(clampi(level, 1, 8), WINDOWS[1])
	var m: float = tool_mult * clampf(assist, 1.0, 1.6)
	var perfect: float = base[0] * m * perfect_scale
	var good: float = base[1] * m * good_scale
	return [perfect, good]


## 단일 탭 판정. dt_ms = 입력시각 − 노트시각(부호 무관 |.| 사용).
static func judge(dt_ms: float, perfect_half: float, good_half: float) -> int:
	var d: float = absf(dt_ms)
	if d <= perfect_half:
		return PERFECT
	elif d <= good_half:
		return GOOD
	return MISS


## Hold 길이 부분점수. target/actual ms, tol(0~1). spec §2.2
static func hold_score(target_ms: float, actual_ms: float, tol: float) -> float:
	if target_ms <= 0.0:
		return 0.0
	var e: float = absf(actual_ms - target_ms) / target_ms
	var t: float = maxf(tol, 0.0001)
	return clampf(1.0 - pow(e / t, 2.0), 0.0, 1.0)


static func judge_name(j: int) -> String:
	match j:
		PERFECT: return "PERFECT"
		GOOD: return "GOOD"
		_: return "MISS"
