## StageMethod — Stage 2B 조리 방법 선택.
##
## ADR-005 §2B. method_options 카드(셔플) 중 correct_method_id 선택 → accuracy_method 1.0/0.0.
## 오답 시 정답 카드 0.3s highlight 후 자동 진행 (decisions A3 = C안: 자동배치 + 정답 cue).
## finished(accuracy_method) emit.
##
## 참조: docs/ui/scene-2-kitchen-layout.md §2, docs/systems/cooking-mechanics.md §3
class_name StageMethod
extends Control

signal finished(accuracy_method: float)

const METHOD_LABEL := {
	"boil": "Boil", "grill": "Grill", "stirfry": "Stir-fry", "panfry": "Pan-fry",
	"deepfry": "Deep-fry", "roll": "Roll", "mix": "Mix", "toss": "Toss", "marinate": "Marinate",
}

var _options: Array = []
var _correct: String = ""
var _buttons: Dictionary = {}
var _answered: bool = false


func setup(options: Array, correct_id: String) -> void:
	_options = options.duplicate()
	_correct = correct_id


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var title := Label.new()
	title.text = "How do you cook it?"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.position = Vector2(0, 380)
	title.size = Vector2(1080, 80)
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	add_child(title)

	var shuffled: Array = _options.duplicate()
	shuffled.shuffle()
	var n: int = shuffled.size()
	# 반응형 카드 폭: 화면(1080) 안에 항상 들어오도록 (4카드도 OK)
	var margin := 50.0
	var gap := 24.0
	var avail := 1080.0 - 2.0 * margin - gap * float(n - 1)
	var card_w: float = min(280.0, avail / float(n))
	var total := n * card_w + (n - 1) * gap
	var start_x := (1080.0 - total) * 0.5
	for i in range(n):
		var mid: String = String(shuffled[i])
		var b := Button.new()
		b.text = METHOD_LABEL.get(mid, mid)
		b.position = Vector2(start_x + i * (card_w + gap), 1150)
		b.size = Vector2(card_w, 320)
		b.add_theme_font_size_override("font_size", 40)
		b.pressed.connect(_on_pick.bind(mid))
		add_child(b)
		_buttons[mid] = b


func _on_pick(method_id: String) -> void:
	if _answered:
		return
	_answered = true
	var correct := method_id == _correct
	var acc := 1.0 if correct else 0.0
	AudioManager.play(&"judge_perfect" if correct else &"judge_miss")
	# 정답 카드 highlight (오답이어도 정답 cue)
	if _buttons.has(_correct):
		(_buttons[_correct] as Button).modulate = Color(0.4, 1.0, 0.4)
	if not correct and _buttons.has(method_id):
		(_buttons[method_id] as Button).modulate = Color(1.0, 0.4, 0.4)
	var tw := create_tween()
	tw.tween_interval(0.4)
	tw.tween_callback(func() -> void: finished.emit(acc))
