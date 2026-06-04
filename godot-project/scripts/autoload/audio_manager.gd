## AudioManager — SFX 재생 (autoload).
##
## SfxRegistry(자동 생성) 기반. AudioStreamPlayer 풀로 동시 재생/연타 대응. 스트림 캐시.
## 사용: AudioManager.play(&"judge_perfect")  /  AudioManager.muted = true 로 음소거.
##
## 참조: tools/gen_sfx.py (SFX 합성), scripts/audio/sfx_registry.gd (경로 레지스트리)
extends Node

const POOL_SIZE := 8

var muted: bool = false
var _players: Array[AudioStreamPlayer] = []
var _cache: Dictionary = {}
var _idx: int = 0


func _ready() -> void:
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)


## SFX 1회 재생 (round-robin 플레이어 풀).
func play(key: StringName, volume_db: float = 0.0) -> void:
	if muted:
		return
	var stream := _get_stream(key)
	if stream == null:
		return
	var p := _players[_idx]
	_idx = (_idx + 1) % POOL_SIZE
	p.stream = stream
	p.volume_db = volume_db
	p.play()


func _get_stream(key: StringName) -> AudioStream:
	var k := String(key)
	if _cache.has(k):
		return _cache[k]
	var path := SfxRegistry.path(key)
	var s: AudioStream = null
	if path != "" and ResourceLoader.exists(path):
		s = load(path) as AudioStream
	else:
		push_warning("[AudioManager] SFX 누락: %s (%s)" % [k, path])
	_cache[k] = s
	return s
