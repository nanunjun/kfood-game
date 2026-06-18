## ScoreUtil — 점수 계산 유틸리티 (static helper 모음).
##
## 게임 전반에서 점수 가산/콤보 배수/범위 클램프를 일관되게 처리하기 위한
## 순수 함수 모음. 상태를 갖지 않으므로 모두 static으로 노출한다.
class_name ScoreUtil
extends RefCounted


## 현재 점수에 delta를 더하되, 결과가 0 미만이면 0으로 클램프해 반환한다.
static func add_score(current: int, delta: int) -> int:
	return max(0, current + delta)


## 콤보 배수(1 + combo * 0.1)를 base에 적용해 floor한 int를 반환한다. combo가 0 이하이면 base 그대로(페널티 없음).
static func apply_combo(base: int, combo: int) -> int:
	if combo <= 0:
		return base
	return int(floor(base * (1.0 + combo * 0.1)))


## score를 0 ~ max_score 범위로 클램프해 반환한다. (음수는 0, 초과는 max_score)
static func clamp_score(score: int, max_score: int) -> int:
	return clamp(score, 0, max_score)
