## TimingDefinition — Stage 3 채점 band(PERFECT/good/miss/no-tap) 정의 Resource.
##
## C-4 lock (2026-05-24): perfect 10 / good 45 / miss 45 (no-tap은 별도 band).
## balance-config.md v0.2 §3.1 공식 → Remote Config 키 `cooking.stage3.band_distribution` 로 export.
## 등록 위치: godot-project/resources/timing/{band_id}.tres
##
## 참조:
##   - docs/balance-config.md v0.2 §3.1 (C-4 lock 공식)
##   - docs/systems/cooking-mechanics.md §4 (Stage 3 룰)
class_name TimingDefinition
extends Resource

## Band 고유 ID — &"perfect", &"good", &"miss", &"no_tap".
@export var band_id: StringName = &""

## 가중치 (분포 비율, 0.0~1.0). C-4 lock default: perfect 0.10 / good 0.45 / miss 0.45 / no_tap 0.0.
@export_range(0.0, 1.0, 0.01) var weight: float = 0.0

## accuracy_timing 값 — PERFECT=1.0 / good=0.6 / miss=0.2 / no_tap=0.0.
## balance-config §3.1 공식과 sync.
@export_range(0.0, 1.0, 0.05) var accuracy_value: float = 0.0

## Remote Config 키 (override 우선). 본 sprint는 단일 키 `cooking.stage3.band_distribution` 사용,
## 미래에 band별 분리 가능성 대비 string 보존.
@export var remote_config_key: String = "cooking.stage3.band_distribution"

## 디자이너 메모.
@export_multiline var notes: String = ""
