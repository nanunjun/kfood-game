## SfxRegistry — sfx key → res:// 경로 (자동 생성, tools/gen_sfx.py).
## 수정 금지 — 사운드 추가/변경은 gen_sfx.py에서.
class_name SfxRegistry
extends RefCounted

const PATHS := {
	"act_boil": "res://audio/sfx/act_boil.wav",
	"act_chop": "res://audio/sfx/act_chop.wav",
	"act_done": "res://audio/sfx/act_done.wav",
	"act_stir": "res://audio/sfx/act_stir.wav",
	"judge_good": "res://audio/sfx/judge_good.wav",
	"judge_miss": "res://audio/sfx/judge_miss.wav",
	"judge_perfect": "res://audio/sfx/judge_perfect.wav",
	"metro_strong": "res://audio/sfx/metro_strong.wav",
	"metro_weak": "res://audio/sfx/metro_weak.wav",
	"sting_finish": "res://audio/sfx/sting_finish.wav",
	"sting_start": "res://audio/sfx/sting_start.wav",
	"ui_select": "res://audio/sfx/ui_select.wav",
}

static func path(key: StringName) -> String:
	return PATHS.get(String(key), "")
