## ResultScreenV2 — Guest System 2.0 result screen.
##
## P3 RESULT REBUILD (2026-06-08) — COMPACT EMOTIONAL PAYOFF.
## The screen reads as "my guest reacted to my cooking", NOT "I am reading a score
## report". Compact 25/35/25 band layout (no big empty vertical space):
##   ① TOP 25%   Guest reaction HERO: big mood word (EXCELLENT/GOOD/OKAY/BAD) +
##               dominant avatar + speech bubble + dish hero thumbnail, all tight.
##   ②③ MID 35%  Reward: friendship bar fill + coin count-up + Recipe XP + milestone.
##   ④ BOT 25%   Learning card (static fact from learning_facts.csv) ABOVE a
##               collapsed Score-Details strip (numbers secondary, default folded).
##   CTA (sticky): Cook Again / Choose Other Guest / Back to Menu.
##
## setup(payload) API + score/friendship/reward DATA are UNCHANGED — this is a pure
## display reorder + compaction. Numbers (score breakdown) stay collapsed at the
## very bottom so they never out-rank the guest's reaction. Learning card reads the
## existing learning_facts.csv presentation-only (no new Learning Layer system).
##
## Wire: runner calls setup(payload), then reveal sequence runs:
##   t=0.0 scene fade-in
##   t=0.4 GUEST REACTION hero pop (mood word + avatar + speech typewriter) ← biggest
##   t=1.3 friendship bar fill + milestone (if any)
##   t=2.0 coin count-up + Recipe XP
##   t=2.8 learning card fade-in (calm, non-blocking)
##   t=3.2 sticky CTA slide-in
## Score breakdown defaults collapsed; tap header to expand the 6 rows.
extends Control

const MarketBG := preload("res://scripts/ui/market_bg.gd")
const CookingBackgroundScript := preload("res://scripts/ui/cooking_background.gd")
const KitchenBackgroundScript := preload("res://scripts/ui/kitchen_background.gd")
const ArtRegistry := preload("res://scripts/gameplay/art_registry.gd")
const MenuDB := preload("res://scripts/gameplay/menu_db.gd")
const CompatBarScript := preload("res://scripts/ui/components/compat_bar.gd")
const ScoreBreakdownRowScript := preload("res://scripts/ui/components/score_breakdown_row.gd")
const RewardBoxScript := preload("res://scripts/ui/components/reward_box.gd")
const EmotionReactionScript := preload("res://scripts/ui/components/emotion_reaction.gd")
const NewRecordBadgeScript := preload("res://scripts/ui/components/new_record_badge.gd")
const MilestoneToastScript := preload("res://scripts/ui/components/milestone_toast.gd")
# Premium V1 components
const HeroNumberScript := preload("res://scripts/ui/premium/hero_number_bounce.gd")
const GoldRibbonScript := preload("res://scripts/ui/premium/gold_ribbon_banner.gd")
const SparkleScript := preload("res://scripts/ui/premium/sparkle_particle.gd")
const CoinSprayScript := preload("res://scripts/ui/premium/coin_spray_particle.gd")
const GlossyButtonScript := preload("res://scripts/ui/premium/glossy_button.gd")
const IdleScript := preload("res://scripts/ui/premium/character_idle_animator.gd")
const DropShadowScript := preload("res://scripts/ui/premium/drop_shadow_panel.gd")

signal cook_again_pressed
signal choose_other_guest_pressed
signal back_to_menu_pressed

const W := 1080.0
const H := 1920.0

var _payload: Dictionary = {}

var _scroll: ScrollContainer = null
var _content: Control = null
var _sticky: CanvasLayer = null
var _dish: Control = null
var _compat_bar: Control = null
var _emotion: Control = null
var _stars_lbl: Label = null
var _score_lbl: Label = null
var _new_record: Control = null
var _reward_box: Control = null
var _breakdown_rows: Array = []
var _cta_root: Control = null
var _learning_card: Control = null   # P3 ④ static learning card (above score strip)
var _verdict: Label = null           # P3 ① big result-mood word ("EXCELLENT!")

# Premium V1 new nodes
var _score_hero: Control = null         # HeroNumberBounce wrapping the big score
var _gold_ribbon: Control = null        # NEW RECORD banner (CP-38) replaces NewRecordBadge
var _wallet_pill: Label = null          # HUD coin pill at top-right (coin spray dest)
var _coin_spray_origin: Vector2 = Vector2(540, 2500)

# P4 collapsible score section
var _score_section: Control = null      # whole ④ score-breakdown collapsible root
var _score_body: Control = null         # the part hidden when collapsed (stars+score+rows)
var _score_toggle: Button = null        # tap-to-expand header button
var _score_collapsed: bool = true       # numbers de-emphasised → collapsed by default
var _score_section_y: float = 0.0       # content-space top of the score section
var _score_body_h: float = 0.0          # body height when expanded
var _stars_y_in_content: float = 0.0    # for sparkle burst placement

# stickyCTA Y-anchor recompute on scroll.
var _cta_root_base_y: float = 1700.0
var _breakdown_played: bool = false
var _reward_played: bool = false


func setup(payload: Dictionary) -> void:
	_payload = payload


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	# World-integration (2026-06-08): flat 베이지 procedural CookingBackground → 실제 한식 주방
	# 환경 art. result 화면이 beige void가 아니라 "방금 요리한 그 주방" world 위에서 손님 반응을
	# 보여주게 한다 (beige void 박멸). 음식의 unlock level → market → L1/L3/L5 BG 매핑.
	# scrim 0.22 = 손님 avatar/말풍선/보상 텍스트 가독성용 얇은 warm 막.
	var food_dict: Dictionary = _payload.get("food", {}) as Dictionary
	var dish_lvl: int = int(food_dict.get("unlock_level", 1))
	var lv_data: Dictionary = MenuDB.get_level(dish_lvl)
	var bg = KitchenBackgroundScript.new()
	bg.fill_screen = true
	bg.dish_anchor_y = 300.0  # spotlight centered under the guest-reaction HERO (top 25%)
	bg.scrim_alpha = 0.18  # 가벼운 막 — 보상/말풍선은 자체 불투명 패널이라 world가 또렷이 보임
	bg.env_key = KitchenBackgroundScript.env_key_for_market(String(lv_data.get("market", "home")))
	add_child(bg)
	_build_scroll()
	_build_sticky_cta()
	_kick_reveal()


# Returns the `layer` of the nearest ancestor CanvasLayer (0 if mounted directly under a
# Window/root with no CanvasLayer). Used so the sticky CTA always sits above the page.
func _enclosing_canvas_layer() -> int:
	var n: Node = get_parent()
	while n != null:
		if n is CanvasLayer:
			return (n as CanvasLayer).layer
		n = n.get_parent()
	return 0


func _build_scroll() -> void:
	_scroll = ScrollContainer.new()
	_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	add_child(_scroll)
	_content = Control.new()
	# P3 compact content height: hero + reward + learning + collapsed-score strip all
	# fit above the sticky CTA with no big empty bands. Grows on score-expand only.
	_content.custom_minimum_size = Vector2(W, 1680.0)
	_scroll.add_child(_content)

	# P3 compact emotion-first 25/35/25 bands (2026-06-08):
	#   ① TOP 25%  (24~500)    Guest reaction HERO: mood word + avatar + bubble + dish
	#   ②③ MID 35% (520~1190)  Reward: friendship → coin → XP (compact RewardBox)
	#   ④ BOT 25%  (1210~)     Learning card + collapsed Score-Details strip
	_build_emotion_hero()
	_build_rewards()
	_build_learning_card()
	_build_score_section()
	_scroll.get_v_scroll_bar().value_changed.connect(_on_scroll)


# P3 ① GUEST REACTION HERO — compact, visually DOMINANT top 25% band (y 24~500).
# A big result-mood word banner ("EXCELLENT!") crowns a tight reaction cluster:
# dominant guest avatar + speech bubble (EmotionReaction hero mode) with the dish
# hero thumbnail nestled into the cluster (the food the guest is reacting to) and a
# slim compat bar. No floating dish + no empty bands — the reaction fills the band.
func _build_emotion_hero() -> void:
	var food: Dictionary = _payload.get("food", {}) as Dictionary
	var compat: int = int(_payload.get("compat", 50))
	var guest: Dictionary = _payload.get("guest", {}) as Dictionary
	var emotion_str: String = String(_payload.get("emotion_level", "okay"))
	var reaction_text: String = String(_payload.get("reaction_text", ""))

	# --- big RESULT-MOOD word banner: the dominant emotional verdict at the very top.
	# It is the loudest text on the page (Excellent/Good/Okay/Bad), color-keyed to mood.
	var mood_word: String = _mood_word(emotion_str)
	var mood_col: Color = _mood_word_color(emotion_str)
	var verdict := Label.new()
	verdict.text = mood_word
	verdict.position = Vector2(0, 26)
	verdict.size = Vector2(W, 86)
	verdict.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	verdict.add_theme_font_size_override("font_size", 78)
	verdict.add_theme_color_override("font_color", mood_col)
	verdict.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.85))
	verdict.add_theme_constant_override("outline_size", 8)
	verdict.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(verdict)
	_verdict = verdict
	# small "[Name] reacted to your [Dish]" subline — frames the screen as a reaction,
	# not a score report. (food + guest names, no numbers.)
	var subline := Label.new()
	subline.text = "%s reacted to your %s" % [guest.get("name", "Guest"), food.get("name_en", "dish")]
	subline.position = Vector2(0, 116)
	subline.size = Vector2(W, 32)
	subline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subline.add_theme_font_size_override("font_size", 24)
	subline.add_theme_color_override("font_color", Color(0.45, 0.32, 0.18))
	subline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(subline)

	# Player-Chef host (top-left corner) — the cook who served this. Secondary.
	var passed: bool = bool(_payload.get("passed", false))
	var stars_n: int = int(_payload.get("stars", 0))
	var host_emotion: String = "cheer" if (passed or stars_n >= 2) else "neutral"
	_add_chef_host(host_emotion, Vector2(28, 30), 150.0)

	# EMOTION REACTION — the HERO. avatar 320 + speech bubble, pulled up tight under the
	# verdict so the guest dominates the band (no gap between verdict and reaction).
	_emotion = EmotionReactionScript.new()
	_emotion.set_hero_mode(true)  # 1020×620
	_emotion.position = Vector2((W - 1020.0) * 0.5, 150)
	_emotion.size = Vector2(1020, 620)
	_content.add_child(_emotion)
	_emotion.setup(guest, emotion_str, reaction_text)

	# Dish HERO thumbnail nestled at the bottom-right of the bubble cluster — the food
	# the guest just reacted to (appetizing + adjacent to the reaction, not floating up
	# top). Sits over the lower reaction band so dish↔reaction read as one moment.
	# A soft floating-shadow plate disc gives the food a grounded "served" feel.
	var plate := _build_dish_plate(Vector2(W - 264.0, 462), 220.0)
	_content.add_child(plate)
	_dish = _build_dish_thumb(food)
	_dish.position = Vector2(W - 240.0, 446)
	_content.add_child(_dish)
	# dish name caption under the thumbnail (no vessel duplication — thumb is the vessel)
	var name_lbl := Label.new()
	name_lbl.text = "%s · %s" % [food.get("name_en", "?"), food.get("name_kr", "")]
	name_lbl.position = Vector2(W - 380.0, 642)
	name_lbl.size = Vector2(360, 30)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 22)
	name_lbl.add_theme_color_override("font_color", Color(0.30, 0.20, 0.12))
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(name_lbl)

	# slim compat bar UNDER the reaction cluster (emotion context, secondary).
	var compat_holder := Control.new()
	compat_holder.position = Vector2(0, 690)
	compat_holder.size = Vector2(W, 50)
	_content.add_child(compat_holder)
	var compat_w: float = 460.0
	_compat_bar = CompatBarScript.new()
	_compat_bar.position = Vector2((W - compat_w) * 0.5, 0)
	_compat_bar.size = Vector2(compat_w, 30)
	_compat_bar.custom_minimum_size = Vector2(compat_w, 30)
	compat_holder.add_child(_compat_bar)
	_compat_bar.setup(compat)
	var compat_caption := Label.new()
	compat_caption.text = "compatibility with %s" % guest.get("name", "guest")
	compat_caption.position = Vector2(0, 32)
	compat_caption.size = Vector2(W, 20)
	compat_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	compat_caption.add_theme_font_size_override("font_size", 17)
	compat_caption.add_theme_color_override("font_color", Color(0.50, 0.40, 0.30))
	compat_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	compat_holder.add_child(compat_caption)


# Result-mood verdict word from emotion_level (display-only; scoring unchanged).
func _mood_word(emo: String) -> String:
	match emo:
		"excellent": return "EXCELLENT!"
		"good":      return "GOOD!"
		"okay":      return "OKAY"
		"bad":       return "NOT QUITE"
		_:           return "OKAY"


# Warm mood-keyed color for the verdict banner.
func _mood_word_color(emo: String) -> Color:
	match emo:
		"excellent": return Color(0.93, 0.45, 0.18)   # vivid persimmon
		"good":      return Color(0.36, 0.62, 0.30)   # fresh green
		"okay":      return Color(0.78, 0.58, 0.18)   # amber
		"bad":       return Color(0.74, 0.36, 0.32)   # muted red
		_:           return Color(0.78, 0.58, 0.18)


# Player-Chef host on the result screen: framed avatar in the top-left corner reading as
# "the cook who served this". Success → cheer, otherwise neutral. SaveManager 성별을 읽어
# ArtRegistry.get_protagonist로 해석. 미선택/미존재 시 silent skip. world BG 위 layer.
func _add_chef_host(emotion: String, pos: Vector2, sz: float) -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm == null or not sm.has_method("player_chef_preset"):
		return
	var preset: String = sm.player_chef_preset()
	if not ArtRegistry.PROTAGONIST_PRESETS.has(preset):
		return
	var path := ArtRegistry.get_protagonist(preset, emotion)
	if path == "" or not ResourceLoader.exists(path):
		return
	# 원형 프레임 (north star warm 톤)
	var frame := Panel.new()
	frame.position = pos
	frame.size = Vector2(sz, sz)
	var fsb := StyleBoxFlat.new()
	fsb.bg_color = Color(0.99, 0.96, 0.89)
	fsb.set_corner_radius_all(int(sz * 0.5))
	fsb.set_border_width_all(5)
	fsb.border_color = Color(0.93, 0.72, 0.30)
	fsb.shadow_size = 10
	fsb.shadow_color = Color(0, 0, 0, 0.28)
	fsb.shadow_offset = Vector2(0, 5)
	frame.add_theme_stylebox_override("panel", fsb)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.clip_contents = true  # 원형 프레임 안으로 chef bust crop
	_content.add_child(frame)
	# warm glow (은은하게)
	var glow := TextureRect.new()
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 0.88, 0.58, 0.30))
	grad.set_color(1, Color(1.0, 0.88, 0.58, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(1.0, 0.5)
	gt.width = 96; gt.height = 96
	glow.texture = gt
	glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(glow)
	# avatar — FULL_RECT anchor + COVERED + frame.clip_contents (수동 size+COVERED는 미렌더 버그)
	var host := TextureRect.new()
	host.texture = load(path)
	host.set_anchors_preset(Control.PRESET_FULL_RECT)
	host.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	host.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(host)
	# caption — Player-Name Personalization (2026-06-08): 입력명(primary) + "cooked this!"(secondary).
	# 이름 미입력/legacy save fallback은 "My Chef". guest 7명 이름과 분리된 host 라벨.
	var chef_name: String = "My Chef"
	if sm.has_method("player_name_display"):
		chef_name = sm.player_name_display()
	var cap := Label.new()
	cap.text = "%s cooked this!" % chef_name
	cap.position = Vector2(pos.x - 24.0, pos.y + sz - 4.0)
	cap.size = Vector2(sz + 48.0, 28)
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cap.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cap.add_theme_font_size_override("font_size", 20)
	cap.add_theme_color_override("font_color", Color(0.45, 0.30, 0.16))
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(cap)


# Soft round "plate" disc with a floating drop shadow, sits BEHIND the dish thumbnail
# to ground the food (served-on-a-plate feel) without duplicating the dish vessel.
func _build_dish_plate(pos: Vector2, sz: float) -> Control:
	var plate := Panel.new()
	plate.position = pos
	plate.size = Vector2(sz, sz)
	var psb := StyleBoxFlat.new()
	psb.bg_color = Color(0.99, 0.97, 0.92, 0.92)
	psb.set_corner_radius_all(int(sz * 0.5))
	psb.set_border_width_all(4)
	psb.border_color = Color(0.90, 0.78, 0.52)
	psb.shadow_size = 16
	psb.shadow_color = Color(0, 0, 0, 0.26)
	psb.shadow_offset = Vector2(0, 8)
	plate.add_theme_stylebox_override("panel", psb)
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return plate


# Small 160×160 secondary dish thumbnail (real sprite or chef-hat fallback card).
func _build_dish_thumb(food: Dictionary) -> Control:
	var holder := Control.new()
	holder.size = Vector2(160, 160)
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.pivot_offset = Vector2(80, 80)
	panel.scale = Vector2(0.85, 0.85)
	var psb := StyleBoxFlat.new()
	psb.bg_color = Color(1, 1, 1, 0)
	panel.add_theme_stylebox_override("panel", psb)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(panel)
	var food_img: String = String(food.get("food_img", ""))
	if food_img != "" and ResourceLoader.exists(food_img):
		var spr := TextureRect.new()
		spr.texture = load(food_img) as Texture2D
		spr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		spr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		spr.set_anchors_preset(Control.PRESET_FULL_RECT)
		spr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(spr)
	else:
		# World-integration (2026-06-08): 베이지 chef-hat + 이니셜 placeholder = prototype 느낌.
		# 대신 warm 한식 그릇(받침 + 무쇠솥 + 나무 뚜껑 + 김) 일러스트로 "방금 차려낸 요리" 느낌.
		_build_warm_dish_card(panel, String(food.get("name_en", "?")))
	return holder


# 160x160 holder panel 안에 warm 한식 그릇 placeholder(food art 미존재 시). menu 카드와 motif 통일.
func _build_warm_dish_card(panel: Panel, _name_en: String) -> void:
	var card := Panel.new()
	card.set_anchors_preset(Control.PRESET_FULL_RECT)
	var bsb := StyleBoxFlat.new()
	bsb.bg_color = Color(0.99, 0.95, 0.86)
	bsb.set_corner_radius_all(28)
	bsb.set_border_width_all(4)
	bsb.border_color = Color(0.82, 0.60, 0.26)
	bsb.shadow_size = 8
	bsb.shadow_color = Color(0, 0, 0, 0.22)
	bsb.shadow_offset = Vector2(0, 4)
	card.add_theme_stylebox_override("panel", bsb)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(card)
	var cx := 80.0
	var cy := 96.0
	# 받침
	var saucer := Polygon2D.new()
	saucer.polygon = PackedVector2Array([
		Vector2(cx - 50, cy + 24), Vector2(cx + 50, cy + 24),
		Vector2(cx + 38, cy + 36), Vector2(cx - 38, cy + 36)])
	saucer.color = Color(0.86, 0.74, 0.54)
	card.add_child(saucer)
	# 솥 몸통
	var body := Panel.new()
	body.position = Vector2(cx - 44, cy - 8)
	body.size = Vector2(88, 34)
	var bb := StyleBoxFlat.new()
	bb.bg_color = Color(0.28, 0.22, 0.20)
	bb.set_corner_radius_all(17)
	bb.set_border_width_all(3)
	bb.border_color = Color(0.18, 0.14, 0.12)
	body.add_theme_stylebox_override("panel", bb)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(body)
	# 뚜껑
	var lid := Panel.new()
	lid.position = Vector2(cx - 48, cy - 22)
	lid.size = Vector2(96, 20)
	var lb := StyleBoxFlat.new()
	lb.bg_color = Color(0.80, 0.55, 0.32)
	lb.set_corner_radius_all(10)
	lb.set_border_width_all(2)
	lb.border_color = Color(0.55, 0.35, 0.18)
	lid.add_theme_stylebox_override("panel", lb)
	lid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(lid)
	# 손잡이
	var knob := Panel.new()
	knob.position = Vector2(cx - 7, cy - 32)
	knob.size = Vector2(14, 12)
	var kb := StyleBoxFlat.new()
	kb.bg_color = Color(0.62, 0.40, 0.22)
	kb.set_corner_radius_all(6)
	knob.add_theme_stylebox_override("panel", kb)
	knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(knob)
	# 김
	for sx in [cx - 18.0, cx, cx + 18.0]:
		var steam := Label.new()
		steam.text = "≀"
		steam.position = Vector2(sx - 8, cy - 60)
		steam.size = Vector2(16, 30)
		steam.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		steam.add_theme_font_size_override("font_size", 24)
		steam.add_theme_color_override("font_color", Color(0.78, 0.62, 0.42, 0.6))
		steam.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(steam)


# P3 ④ LEARNING CARD — bottom band, ABOVE the collapsed score strip. A single calm,
# static Korean-food fact for this dish (food_fact, with culture_fact subline) read
# straight from learning_facts.csv. Presentation-only: no new Learning Layer system,
# never blocks flow, silently skipped when the CSV/row is missing.
var _learning_card_bottom: float = 0.0
func _build_learning_card() -> void:
	var food: Dictionary = _payload.get("food", {}) as Dictionary
	var fid: String = String(food.get("id", ""))
	var facts: Dictionary = _load_learning_facts_for(fid)
	var reward_h: float = _reward_box.size.y if _reward_box != null else 400.0
	var card_y: float = REWARD_Y + reward_h + 28.0
	# fallback fact if CSV row missing — still show a friendly discovery line.
	var food_fact: String = String(facts.get("food_fact", ""))
	var culture_fact: String = String(facts.get("culture_fact", ""))
	if food_fact == "" and culture_fact == "":
		_learning_card_bottom = card_y
		return

	var card_w: float = 960.0
	var card := Panel.new()
	card.position = Vector2((W - card_w) * 0.5, card_y)
	card.size = Vector2(card_w, 188)
	var csb := StyleBoxFlat.new()
	csb.bg_color = Color(0.93, 0.97, 0.90)  # soft mint "did you know" tone
	csb.set_corner_radius_all(26)
	csb.set_border_width_all(3)
	csb.border_color = Color(0.55, 0.74, 0.46)
	csb.shadow_size = 8
	csb.shadow_color = Color(0, 0, 0, 0.16)
	csb.shadow_offset = Vector2(0, 4)
	card.add_theme_stylebox_override("panel", csb)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(card)
	_learning_card = card
	# header chip "Did you know?" (한식 identity signal #2: learning about Korean food)
	var chip := Label.new()
	chip.text = "Did you know?"
	chip.position = Vector2(36, 22)
	chip.size = Vector2(500, 34)
	chip.add_theme_font_size_override("font_size", 26)
	chip.add_theme_color_override("font_color", Color(0.26, 0.50, 0.22))
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(chip)
	# primary fact (the appetizing food fact)
	var primary: String = food_fact if food_fact != "" else culture_fact
	var fact_lbl := Label.new()
	fact_lbl.text = primary
	fact_lbl.position = Vector2(36, 66)
	fact_lbl.size = Vector2(card_w - 72.0, 56)
	fact_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fact_lbl.add_theme_font_size_override("font_size", 28)
	fact_lbl.add_theme_color_override("font_color", Color(0.18, 0.26, 0.14))
	fact_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(fact_lbl)
	# culture subline (secondary, only if distinct from the primary)
	if culture_fact != "" and culture_fact != primary:
		var sub := Label.new()
		sub.text = culture_fact
		sub.position = Vector2(36, 128)
		sub.size = Vector2(card_w - 72.0, 48)
		sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sub.add_theme_font_size_override("font_size", 22)
		sub.add_theme_color_override("font_color", Color(0.40, 0.50, 0.34))
		sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(sub)
	_learning_card_bottom = card_y + card.size.y


# Presentation-only reader for learning_facts.csv (mirrors menu_select.gd loader).
# Returns {} on any failure — the learning card silently skips. No MenuDB/scoring touch.
func _load_learning_facts_for(food_id: String) -> Dictionary:
	if food_id == "":
		return {}
	var path := "res://data/learning_facts.csv"
	if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var header := f.get_csv_line()
	var idx: Dictionary = {}
	for i in range(header.size()):
		idx[String(header[i]).strip_edges()] = i
	var result: Dictionary = {}
	while not f.eof_reached():
		var row := f.get_csv_line()
		if row.size() == 0:
			continue
		var fid_i: int = int(idx.get("food_id", -1))
		if fid_i < 0 or fid_i >= row.size():
			continue
		if String(row[fid_i]).strip_edges() != food_id:
			continue
		for key in ["food_fact", "ingredient_fact", "cooking_tip", "culture_fact"]:
			if idx.has(key):
				var ci: int = int(idx[key])
				result[key] = String(row[ci]).strip_edges() if ci < row.size() else ""
		break
	f.close()
	return result


# P3 ④ SCORE BREAKDOWN — COLLAPSIBLE, very bottom (below learning card). Numbers come
# LAST so they never out-rank the guest's reaction. A tap header expands the stars +
# total score + NEW RECORD ribbon + 6-row breakdown. Default = collapsed.
func _build_score_section() -> void:
	var stars: int = int(_payload.get("stars", 0))
	var score: int = int(_payload.get("score", 0))
	var rows: Array = _payload.get("breakdown_rows", []) as Array

	# Section root sits just below the learning card (which itself sits below the reward
	# box). Falls back to a reward-derived y if the learning card was skipped.
	var reward_h: float = _reward_box.size.y if _reward_box != null else 400.0
	var below: float = _learning_card_bottom if _learning_card_bottom > 0.0 else (REWARD_Y + reward_h)
	_score_section_y = below + 28.0
	_score_section = Control.new()
	_score_section.position = Vector2(0, _score_section_y)
	_score_section.size = Vector2(W, 80)
	_content.add_child(_score_section)

	# --- tap-to-expand header button ---
	_score_toggle = Button.new()
	_score_toggle.position = Vector2((W - 960.0) * 0.5, 0)
	_score_toggle.size = Vector2(960, 72)
	_score_toggle.text = "  Score Details   ★%d   •   %d pts        ▼ tap to expand" % [stars, score]
	_score_toggle.add_theme_font_size_override("font_size", 26)
	var tsb := StyleBoxFlat.new()
	tsb.bg_color = Color(0.96, 0.92, 0.84)
	tsb.set_corner_radius_all(20)
	tsb.set_border_width_all(2)
	tsb.border_color = Color(0.82, 0.66, 0.34)
	_score_toggle.add_theme_stylebox_override("normal", tsb)
	var tsbh := tsb.duplicate()
	tsbh.bg_color = Color(0.98, 0.95, 0.88)
	_score_toggle.add_theme_stylebox_override("hover", tsbh)
	_score_toggle.add_theme_stylebox_override("pressed", tsbh)
	_score_toggle.add_theme_color_override("font_color", Color(0.40, 0.27, 0.14))
	_score_toggle.pressed.connect(_toggle_score)
	_score_section.add_child(_score_toggle)

	# --- collapsible body (hidden when collapsed) ---
	_score_body = Control.new()
	_score_body.position = Vector2(0, 92)
	_score_body.size = Vector2(W, 1)
	_score_body.visible = false
	_score_section.add_child(_score_body)

	# NEW RECORD ribbon (kept near the score, inside the body band)
	if bool(_payload.get("record_broken", false)):
		_gold_ribbon = GoldRibbonScript.new()
		_gold_ribbon.position = Vector2((W - 540.0) * 0.5, 0)
		_gold_ribbon.size = Vector2(540, 100)
		_gold_ribbon.custom_minimum_size = Vector2(540, 100)
		_score_body.add_child(_gold_ribbon)
		var prev_score: int = int(_payload.get("record_prev_score", 0))
		_gold_ribbon.setup("NEW RECORD!", "+%d over your best %d" % [maxi(1, score - prev_score), prev_score])

	# Sprite-star row
	var stars_row := Control.new()
	stars_row.position = Vector2(0, 120)
	stars_row.size = Vector2(W, 100)
	stars_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_score_body.add_child(stars_row)
	_build_sprite_stars(stars_row, stars, 70.0, 14.0)
	# Backwards-compat hidden markers (shot tests / legacy refs)
	_stars_lbl = Label.new()
	_stars_lbl.text = "*".repeat(maxi(0, stars)) + "-".repeat(maxi(0, 5 - stars))
	_stars_lbl.position = Vector2(0, 0)
	_stars_lbl.size = Vector2(W, 100)
	_stars_lbl.modulate.a = 0.0
	_stars_lbl.visible = false
	stars_row.add_child(_stars_lbl)
	_score_lbl = Label.new()
	_score_lbl.text = "Score 0"
	_score_lbl.position = Vector2(0, 230)
	_score_lbl.size = Vector2(W, 70)
	_score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_score_lbl.add_theme_font_size_override("font_size", 56)
	_score_lbl.add_theme_color_override("font_color", Color(0.17, 0.11, 0.08))
	_score_lbl.modulate.a = 0.0
	_score_lbl.visible = false
	_score_body.add_child(_score_lbl)
	# Hero score number (smaller than before — de-emphasised vs. emotion)
	_score_hero = HeroNumberScript.new()
	_score_hero.position = Vector2((W - 460.0) * 0.5, 224)
	_score_hero.size = Vector2(460, 110)
	_score_body.add_child(_score_hero)
	_score_hero.setup(score, "", 84)
	# It's already inside a hidden body; show immediately (no separate fade needed)
	var sub := Label.new()
	sub.text = "TOTAL SCORE"
	sub.position = Vector2(0, 332)
	sub.size = Vector2(W, 28)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 22)
	sub.add_theme_color_override("font_color", Color(0.55, 0.40, 0.22))
	_score_body.add_child(sub)
	# remember stars y in content-space for the sparkle burst
	_stars_y_in_content = _score_section_y + 92.0 + 120.0 + 50.0

	# --- 6-row breakdown (inside the body, under the score) ---
	var rows_root := Control.new()
	rows_root.position = Vector2((W - 960.0) * 0.5, 392)
	rows_root.size = Vector2(960, 760)
	_score_body.add_child(rows_root)
	var bhdr := Label.new()
	bhdr.text = "Score Breakdown"
	bhdr.position = Vector2(0, 0)
	bhdr.size = Vector2(960, 40)
	bhdr.add_theme_font_size_override("font_size", 26)
	bhdr.add_theme_color_override("font_color", Color(0.30, 0.20, 0.10))
	rows_root.add_child(bhdr)
	var y: float = 52.0
	for r in rows:
		var row: Panel = ScoreBreakdownRowScript.new()
		row.position = Vector2(0, y)
		rows_root.add_child(row)
		row.setup(r as Dictionary)
		_breakdown_rows.append(row)
		y += 108.0

	# body height when fully expanded
	_score_body_h = 392.0 + 52.0 + float(rows.size()) * 108.0 + 40.0


# D1: 5-point sprite star helper. Polygon2D for full and empty states (no asset dep).
func _build_sprite_stars(parent: Control, filled: int, star_size: float, gap: float) -> void:
	var total_w: float = 5.0 * star_size + 4.0 * gap
	var x0: float = (W - total_w) * 0.5
	for i in range(5):
		var holder := Control.new()
		holder.position = Vector2(x0 + float(i) * (star_size + gap), 0)
		holder.size = Vector2(star_size, star_size)
		holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(holder)
		# outer dark outline star (drawn slightly larger)
		var outline := Polygon2D.new()
		outline.polygon = _star_5pt(star_size * 0.50 + 4.0, star_size * 0.20 + 2.0)
		outline.color = Color(0.30, 0.18, 0.05)
		outline.position = Vector2(star_size * 0.5, star_size * 0.5)
		holder.add_child(outline)
		# fill — gold if filled, muted grey if empty
		var fill := Polygon2D.new()
		fill.polygon = _star_5pt(star_size * 0.50, star_size * 0.20)
		fill.color = Color(0.98, 0.78, 0.22) if i < filled else Color(0.80, 0.75, 0.65)
		fill.position = Vector2(star_size * 0.5, star_size * 0.5)
		holder.add_child(fill)
		# inner highlight crescent (top-left)
		if i < filled:
			var hl := Polygon2D.new()
			hl.polygon = _star_5pt(star_size * 0.30, star_size * 0.13)
			hl.color = Color(1.0, 0.96, 0.62, 0.85)
			hl.position = Vector2(star_size * 0.42, star_size * 0.42)
			holder.add_child(hl)


# Produces 5-point star polygon centered at (0,0).
func _star_5pt(outer_r: float, inner_r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var rot: float = -PI / 2.0  # point up
	for i in range(10):
		var r: float = outer_r if i % 2 == 0 else inner_r
		var a: float = rot + float(i) * PI / 5.0
		pts.append(Vector2(cos(a) * r, sin(a) * r))
	return pts


# P4 collapse/expand toggle for the score-breakdown section (④).
func _toggle_score() -> void:
	if _score_body == null or _score_toggle == null:
		return
	_score_collapsed = not _score_collapsed
	var stars: int = int(_payload.get("stars", 0))
	var score: int = int(_payload.get("score", 0))
	if _score_collapsed:
		_score_body.visible = false
		_score_section.size.y = 80.0
		_content.custom_minimum_size.y = maxf(1680.0, _score_section_y + 120.0)
		_score_toggle.text = "  Score Details   ★%d   •   %d pts        ▼ tap to expand" % [stars, score]
	else:
		_score_body.visible = true
		_score_section.size.y = 92.0 + _score_body_h
		_content.custom_minimum_size.y = maxf(1680.0, _score_section_y + 92.0 + _score_body_h + 120.0)
		_score_toggle.text = "  Score Details   ★%d   •   %d pts        ▲ tap to collapse" % [stars, score]
		# Play breakdown row reveals on first expand
		if not _breakdown_played:
			_breakdown_played = true
			var d: float = 0.0
			for r in _breakdown_rows:
				if r != null and r.has_method("play_reveal"):
					r.play_reveal(d)
				d += 0.06


# P3 ②③ FRIENDSHIP + REWARD — compact RewardBox in the MID 35% band, right under the
# hero/compat cluster. RewardBox renders friendship FIRST (②) then coins + XP (③).
const REWARD_Y := 760.0
func _build_rewards() -> void:
	var section_root := Control.new()
	section_root.position = Vector2((W - 960.0) * 0.5, REWARD_Y)
	section_root.size = Vector2(960, 420)
	_content.add_child(section_root)
	_reward_box = RewardBoxScript.new()
	_reward_box.position = Vector2(0, 0)
	section_root.add_child(_reward_box)
	_reward_box.setup({
		"coin": int(_payload.get("final_coin", 0)),
		"xp_gained": int(_payload.get("xp_gained", 0)),
		"xp_total_after": int(_payload.get("xp_total_after", 0)),
		"food_id": String((_payload.get("food", {}) as Dictionary).get("id", "")),
		"friendship_after": int(_payload.get("friendship_after", 0)),
		"friendship_delta": int(_payload.get("friendship_delta", 0)),
		"milestone": int(_payload.get("milestone_just_hit", 0)),
	})


func _build_sticky_cta() -> void:
	_sticky = CanvasLayer.new()
	# BUGFIX (2026-06-06): CanvasLayer.layer is a GLOBAL z-order, not nested under a parent
	# CanvasLayer. The runner (cooking_module_runner / rhythm_proto) mounts this whole result
	# screen inside `top` (CanvasLayer, layer = 10). A hard-coded _sticky.layer = 5 then sat
	# BELOW that layer-10 content, so the full-rect ScrollContainer drawn on layer 10 ate
	# every click over the CTA band and the 3 nav buttons (Cook Again / Choose Other Guest /
	# Back to Menu) never fired. Fix: derive the sticky layer from the nearest ancestor
	# CanvasLayer so the CTA always renders + receives input ABOVE the page content,
	# whether the screen is mounted on root (shots → layer 0) or inside top (runner → 10).
	_sticky.layer = _enclosing_canvas_layer() + 5
	add_child(_sticky)
	_cta_root = Control.new()
	_cta_root.position = Vector2(0, _cta_root_base_y)
	_cta_root.size = Vector2(W, 200)
	_cta_root.modulate.a = 0.0
	_sticky.add_child(_cta_root)
	# bg band (premium drop shadow on top edge)
	var bg := Panel.new()
	bg.position = Vector2(0, 0)
	bg.size = Vector2(W, 200)
	var bsb := StyleBoxFlat.new()
	bsb.bg_color = Color(0.99, 0.94, 0.84, 0.98)
	bsb.shadow_size = 14
	bsb.shadow_color = Color(0, 0, 0, 0.30)
	bsb.shadow_offset = Vector2(0, -8)
	bg.add_theme_stylebox_override("panel", bsb)
	_cta_root.add_child(bg)
	# Wallet HUD pill (top-right of sticky CTA — coin spray destination)
	_build_wallet_pill()
	# 3-tier CTAs — Primary glossy persimmon / Secondary outlined gold / Tertiary text
	_add_glossy_cta("Cook Again", Vector2(30, 60), Vector2(330, 112),
		Color(0.93, 0.45, 0.25), Color.WHITE, _on_cook_again, true)
	_add_glossy_cta("Choose Other Guest", Vector2(380, 60), Vector2(320, 112),
		Color(0.96, 0.74, 0.22), Color(0.20, 0.10, 0.04), _on_choose_other, false)
	_add_glossy_cta("Back to Menu", Vector2(720, 60), Vector2(330, 112),
		Color(0.99, 0.94, 0.84), Color(0.40, 0.25, 0.10), _on_back_menu, false, true)


func _build_wallet_pill() -> void:
	# Coin destination pill (top of sticky band, right side)
	var sm := get_node_or_null("/root/SaveManager")
	var wallet_money: int = sm.money() if sm else 0
	# Final coin awarded was already added during runner _finish(); but for the spray
	# animation, we want to show the BEFORE value then count up. So display before.
	var coin_gain: int = int(_payload.get("final_coin", 0))
	var before: int = wallet_money - coin_gain
	var pill := Panel.new()
	pill.position = Vector2(W - 320.0, 6)
	pill.size = Vector2(300, 48)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.94, 0.66, 0.12)
	sb.set_corner_radius_all(24)
	sb.set_border_width_all(3)
	sb.border_color = Color(0.50, 0.30, 0.05)
	sb.shadow_size = 8
	sb.shadow_color = Color(0, 0, 0, 0.32)
	sb.shadow_offset = Vector2(0, 4)
	pill.add_theme_stylebox_override("panel", sb)
	_cta_root.add_child(pill)
	# inner highlight
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 0.96, 0.50, 0.5))
	grad.set_color(1, Color(1.0, 0.96, 0.50, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_LINEAR
	gt.fill_from = Vector2(0.5, 0.0)
	gt.fill_to = Vector2(0.5, 1.0)
	gt.width = 256; gt.height = 256
	var hl := TextureRect.new()
	hl.texture = gt
	hl.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hl.offset_top = 3.0; hl.offset_left = 4.0; hl.offset_right = -4.0; hl.offset_bottom = 22.0
	hl.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hl.stretch_mode = TextureRect.STRETCH_SCALE
	hl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill.add_child(hl)
	_wallet_pill = Label.new()
	_wallet_pill.text = _format_money(before)
	_wallet_pill.set_anchors_preset(Control.PRESET_FULL_RECT)
	_wallet_pill.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_wallet_pill.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_wallet_pill.add_theme_font_size_override("font_size", 26)
	_wallet_pill.add_theme_color_override("font_color", Color(0.20, 0.10, 0.04))
	_wallet_pill.add_theme_color_override("font_outline_color", Color(1.0, 0.95, 0.55, 0.55))
	_wallet_pill.add_theme_constant_override("outline_size", 2)
	_wallet_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill.add_child(_wallet_pill)


func _format_money(n: int) -> String:
	var s := str(n)
	var out := ""
	var c := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = "," + out
	return "₩" + out


# Premium GlossyButton (CP-33) version of the CTA builder.
func _add_glossy_cta(label: String, pos: Vector2, sz: Vector2, bg: Color, _fg: Color,
		cb: Callable, primary: bool, _outline: bool = false) -> Control:
	var gb = GlossyButtonScript.new()
	gb.position = pos
	gb.size = sz
	gb.custom_minimum_size = sz
	_cta_root.add_child(gb)
	gb.setup(label, bg, 28, 26)
	_wire_cta_button(gb, cb)
	if primary:
		# 1Hz pulse for primary
		gb.pivot_offset = sz * 0.5
		var tw := create_tween().set_loops()
		tw.tween_property(gb, "scale", Vector2(1.04, 1.04), 0.5).set_trans(Tween.TRANS_SINE)
		tw.tween_property(gb, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_SINE)
	return gb


func _wire_cta_button(gb: Control, cb: Callable) -> void:
	await get_tree().process_frame
	if not is_instance_valid(gb):
		return
	if gb.get("button") == null:
		await get_tree().process_frame
	var btn: Button = gb.get("button")
	if btn != null:
		btn.pressed.connect(cb)


func _add_cta(label: String, pos: Vector2, sz: Vector2, bg: Color, fg: Color,
		cb: Callable, primary: bool, outline: bool = false) -> Button:
	var b := Button.new()
	b.text = label
	b.position = pos
	b.size = sz
	b.add_theme_font_size_override("font_size", 30)
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(28)
	if outline:
		sb.set_border_width_all(3)
		sb.border_color = Color(0.55, 0.35, 0.10)
	sb.shadow_size = 5
	sb.shadow_color = Color(0, 0, 0, 0.18)
	b.add_theme_stylebox_override("normal", sb)
	var sbh := sb.duplicate()
	sbh.bg_color = bg.lightened(0.12)
	b.add_theme_stylebox_override("hover", sbh)
	b.add_theme_stylebox_override("pressed", sbh)
	b.add_theme_color_override("font_color", fg)
	b.pressed.connect(cb)
	_cta_root.add_child(b)
	if primary:
		# 1Hz pulse
		var tw := create_tween().set_loops()
		b.pivot_offset = b.size * 0.5
		tw.tween_property(b, "scale", Vector2(1.04, 1.04), 0.5).set_trans(Tween.TRANS_SINE)
		tw.tween_property(b, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_SINE)
	return b


# ---- P3 COMPACT EMOTION-FIRST reveal sequence ----
# Order: verdict word + guest reaction hero (t=0.3) → friendship (t=1.3) →
#        coins (t=2.0) → learning card (t=2.8) → score/stars (t=2.8, folded) → CTA (t=3.2).
func _kick_reveal() -> void:
	# t=0.0 scene fade-in
	modulate.a = 0.0
	var t := create_tween().set_parallel(true)
	t.tween_property(self, "modulate:a", 1.0, 0.30)

	# t=0.3 — ① big VERDICT word pop (the dominant emotional payoff lands first).
	if _verdict != null:
		_verdict.pivot_offset = Vector2(W * 0.5, 43.0)
		_verdict.scale = Vector2(0.6, 0.6)
		_verdict.modulate.a = 0.0
		t.tween_property(_verdict, "modulate:a", 1.0, 0.25).set_delay(0.3)
		t.tween_property(_verdict, "scale", Vector2.ONE, 0.45)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.3)

	# t=0.4 — ① GUEST REACTION HERO pop. Avatar + bubble scale-in from 0.9, then
	# typewriter + mood swap. This is the FIRST and BIGGEST beat (emotion-first).
	if _emotion != null:
		_emotion.pivot_offset = _emotion.size * 0.5
		_emotion.scale = Vector2(0.90, 0.90)
		_emotion.modulate.a = 0.0
		t.tween_property(_emotion, "modulate:a", 1.0, 0.30).set_delay(0.45)
		t.tween_property(_emotion, "scale", Vector2.ONE, 0.45)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.45)
		_emotion.play_typewriter(0.6, 1.3)
		_emotion.play_mood_swap(0.9)
		# idle breath on the avatar child Panel (hero avatar = 320px)
		var emo_avatar: Control = null
		for c in _emotion.get_children():
			if c is Panel and c.size.x >= 200.0 and c.size.x <= 340.0:
				emo_avatar = c
				break
		if emo_avatar != null:
			var idle_t := create_tween()
			idle_t.tween_interval(1.6)
			idle_t.tween_callback(func() -> void:
				if is_instance_valid(emo_avatar):
					IdleScript.attach(emo_avatar, 1.03, 2.0))

	# secondary dish thumb scale-in + idle (under the hero, not a focal point)
	var dish_inner_panel: Panel = null
	if _dish != null:
		for c in _dish.get_children():
			if c is Panel:
				dish_inner_panel = c
				break
		if dish_inner_panel != null:
			t.tween_property(dish_inner_panel, "scale", Vector2.ONE, 0.45)\
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.6)
			var idle_t2 := create_tween()
			idle_t2.tween_interval(1.1)
			idle_t2.tween_callback(func() -> void:
				if is_instance_valid(dish_inner_panel):
					IdleScript.attach(dish_inner_panel, 1.025, 2.4))

	# compat bar fade-in (context for the reaction)
	if _compat_bar != null:
		_compat_bar.modulate.a = 0.0
		t.tween_property(_compat_bar, "modulate:a", 1.0, 0.40).set_delay(1.0)

	# t=1.3 — ② FRIENDSHIP + ③ REWARD reveal (friendship bar fills first inside the
	# box, then coin count-up, then XP — see RewardBox.play_reveal P4 ordering).
	if _reward_box != null:
		_reward_played = true
		var rb_t := create_tween()
		rb_t.tween_interval(1.3)
		rb_t.tween_callback(func() -> void:
			if is_instance_valid(_reward_box) and _reward_box.has_method("play_reveal"):
				_reward_box.play_reveal(0.0))

	# t=2.0 — ③ coin spray to wallet pill (after friendship beat)
	var coin_gain: int = int(_payload.get("final_coin", 0))
	if coin_gain > 0 and _wallet_pill != null:
		var coin_t := create_tween()
		coin_t.tween_interval(2.0)
		coin_t.tween_callback(_fire_coin_spray)

	# t=2.8 — ④ learning card calm fade-up (non-blocking discovery beat).
	if _learning_card != null:
		_learning_card.modulate.a = 0.0
		_learning_card.position.y += 24.0
		var lc_t := create_tween().set_parallel(true)
		lc_t.tween_interval(2.8)
		lc_t.chain().tween_property(_learning_card, "modulate:a", 1.0, 0.40)
		lc_t.parallel().tween_property(_learning_card, "position:y", _learning_card.position.y - 24.0, 0.40)\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# t=2.8 — ④ score / stars settle in the COLLAPSED section header (de-emphasised).
	# Hero score lives inside the hidden body; a light sparkle just punctuates the
	# score header so numbers register without competing with the reaction.
	if _score_hero != null:
		var hero_t := create_tween()
		hero_t.tween_interval(2.8)
		hero_t.tween_callback(func() -> void:
			if is_instance_valid(_score_hero) and _score_hero.has_method("play_bounce"):
				_score_hero.play_bounce(0.0, 0))
	if _score_lbl != null:
		var target_score2: int = int(_payload.get("score", 0))
		var tw := create_tween()
		tw.tween_interval(2.8)
		tw.tween_method(func(v: int) -> void:
			if is_instance_valid(_score_lbl):
				_score_lbl.text = "Score %d" % v,
			0, target_score2, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# NEW RECORD ribbon (kept near score, inside collapsible body) reveal anim
	if _gold_ribbon != null:
		var gr_t := create_tween()
		gr_t.tween_interval(2.8)
		gr_t.tween_callback(func() -> void:
			if is_instance_valid(_gold_ribbon) and _gold_ribbon.has_method("play_reveal"):
				_gold_ribbon.play_reveal(0.0))

	# t=3.2 sticky CTA slide-in
	if _cta_root != null:
		t.tween_property(_cta_root, "modulate:a", 1.0, 0.35).set_delay(3.2)


func _fire_star_sparkle() -> void:
	if not is_inside_tree():
		return
	var spark = SparkleScript.new()
	_content.add_child(spark)
	# Sparkle on the star row inside the collapsible score body (content-space y).
	var sy: float = _stars_y_in_content if _stars_y_in_content > 0.0 else 1590.0
	var stars_pos: Vector2 = Vector2(W * 0.5, sy)
	spark.burst(stars_pos, 18, 220.0, Color(1.0, 0.92, 0.45), 0.85)


func _fire_coin_spray() -> void:
	if not is_inside_tree() or _wallet_pill == null:
		return
	# Sticky-CTA is on a CanvasLayer — convert wallet position to that layer's coords.
	var wallet_center_local: Vector2 = _wallet_pill.global_position + _wallet_pill.size * 0.5
	# Coin spray is a Node2D — add it to the canvas layer so it doesn't scroll.
	var spray = CoinSprayScript.new()
	_sticky.add_child(spray)
	# Spray origin near the reward box on screen (mid band) toward the wallet pill.
	var origin: Vector2 = Vector2(W * 0.5, 820)
	var coin_gain: int = int(_payload.get("final_coin", 0))
	# Compute wallet current displayed value for count-up start
	var before_text: String = _wallet_pill.text
	var wallet_start: int = _parse_money(before_text)
	spray.spray(origin, wallet_center_local, 20, coin_gain, _wallet_pill, wallet_start)


func _parse_money(s: String) -> int:
	var t := s.replace("₩", "").replace(",", "").strip_edges()
	return t.to_int()


# ---- scroll-triggered reveals ----
# P4: friendship+reward now reveal on the _kick_reveal timeline (t=1.5), and the
# score breakdown rows reveal when the user taps to expand (_toggle_score). Scroll
# is kept only as a safety net in case the kick reveal was skipped.
func _on_scroll(value: float) -> void:
	if _scroll == null:
		return
	# reward box safety reveal (normally fired by the kick timeline at t=1.5)
	if not _reward_played and value > 200.0:
		_reward_played = true
		if _reward_box != null and _reward_box.has_method("play_reveal"):
			_reward_box.play_reveal(0.0)


# ---- CTA handlers ----
func _on_cook_again() -> void:
	# BUGFIX (2026-06-06): Cook Again must restart the SAME dish+guest through the CURRENT
	# cooking pipeline — CookingModuleRunner (cooking_module_runner.tscn), the scene that
	# menu_select / guest_select actually launch. The old code routed to the DEPRECATED
	# rhythm_proto.tscn and set RhythmProto.pending_* (which the runner never reads), so a
	# Cook Again restart would either dead-end or run the legacy flow. Mirror exactly how
	# guest_select.gd launches a round: set Runner.pending_menu_id / pending_guest_id.
	cook_again_pressed.emit()
	var food: Dictionary = _payload.get("food", {}) as Dictionary
	var guest: Dictionary = _payload.get("guest", {}) as Dictionary
	var food_id: String = String(food.get("id", ""))
	# GimbapSliceRunner extends CookingModuleRunner and shares the same static pending slots,
	# so we only need to change which scene we reload. Gimbap (t1_004) → vertical slice runner.
	var RunnerScript := load("res://scripts/gameplay/cooking_module_runner.gd")
	RunnerScript.pending_menu_id = food_id
	RunnerScript.pending_guest_id = String(guest.get("id", ""))
	if food_id == "t1_004":
		get_tree().change_scene_to_file("res://scenes/gimbap_slice_runner.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/cooking_module_runner.tscn")


func _on_choose_other() -> void:
	choose_other_guest_pressed.emit()
	var food: Dictionary = _payload.get("food", {}) as Dictionary
	var GuestSelectScript := load("res://scripts/ui/guest_select.gd")
	if GuestSelectScript != null:
		GuestSelectScript.pending_menu_id = String(food.get("id", ""))
	get_tree().change_scene_to_file("res://scenes/guest_select.tscn")


func _on_back_menu() -> void:
	back_to_menu_pressed.emit()
	get_tree().change_scene_to_file("res://scenes/menu_select.tscn")


# Public reveal trigger if a caller wants to force-play all reveals (for shots).
# Also expands the collapsible score section so screenshots capture everything.
func force_play_all_reveals() -> void:
	if not _reward_played:
		_reward_played = true
		if _reward_box != null and _reward_box.has_method("play_reveal"):
			_reward_box.play_reveal(0.0)
	# Expand the score section (also fires the breakdown-row reveals once)
	if _score_collapsed:
		_toggle_score()
	elif not _breakdown_played:
		_breakdown_played = true
		var d: float = 0.0
		for r in _breakdown_rows:
			if r != null and r.has_method("play_reveal"):
				r.play_reveal(d)
			d += 0.06

# Public: allow a shot/test harness to keep the score section collapsed (default)
# or pre-expand it. Returns whether it ended expanded.
# BUGFIX (2026-06-08): the guard was inverted (`==` instead of `!=`), so requesting
# the CURRENT state spuriously toggled to the opposite. Toggle only when the desired
# collapsed-state differs from the actual one.
func set_score_expanded(expanded: bool) -> bool:
	if _score_collapsed != (not expanded):
		_toggle_score()
	return not _score_collapsed
