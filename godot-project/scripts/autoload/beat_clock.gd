## BeatClock — 정확 시간 소스 (autoload, M0 리듬 프로토타입).
##
## 오디오 출력 지연 보정한 곡 위치(ms)를 제공. 판정·노트 강하의 단일 시간 기준.
## 참조: docs/phase1/rhythm-prototype-spec.md §6/§13
## 주의: autoload 이름(BeatClock)과 class_name 충돌 금지 → class_name 미사용.
extends Node

var _start_usec: int = 0
var _running: bool = false
var output_latency: float = 0.0


func start() -> void:
	output_latency = AudioServer.get_output_latency()
	_start_usec = Time.get_ticks_usec()
	_running = true


func stop() -> void:
	_running = false


func is_running() -> bool:
	return _running


## 현재 곡 위치(ms). 오디오 출력 지연 + 사용자 보정(Tuning.audio_offset_ms) 반영.
func now_ms() -> float:
	if not _running:
		return 0.0
	var t: float = float(Time.get_ticks_usec() - _start_usec) / 1000.0
	var off: float = 0.0
	if Engine.has_singleton("Tuning") or get_node_or_null("/root/Tuning") != null:
		off = get_node("/root/Tuning").audio_offset_ms
	return t - output_latency * 1000.0 + off
