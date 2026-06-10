## KitchenBackground — L1 환경 art 기반 cooking 배경 (beige void 제거).
##
## URGENT layout fix (2026-06-06): 기존 procedural CookingBackground는 상단 절반이
## 단색 cream(beige void)이라 cooking hero가 빈 공간에 떠 보였다. 이 배경은
## assets-raw/environment_pack_m2 의 L1 home kitchen art(warm counter + 뒷벽 + 선반 props)
## 를 화면에 깔아 "실제 부엌에서 요리하는" 맥락을 준다.
##
## 구성:
##   - L1 art를 width-cover로 화면 하단~중앙에 배치 (counter가 ZONE_ACTION 하단/CONTROL과 정렬)
##   - art 위쪽 빈 영역은 art 상단 wall 색을 sample한 gradient로 자연스럽게 연장
##   - dish anchor 아래 soft radial spotlight로 cooking hero를 시각적으로 고정
##   - cooking 화면 전용 — red awning 없음 (menu/guest는 별도 MarketBG 유지)
##
## level → 환경 매핑(선택): level_env로 L1~L5 중 선택 (game state). 기본 L1.
## gameplay/scoring 무영향 — 순수 시각 배경.
extends Control

const W := 1080.0
const H := 1920.0

# level_env → bg art 경로 (L1 home → L5 prestige). 기본 home kitchen.
const ENV_ART := {
	"home":    "res://art/bg/l1_home_kitchen.png",
	"snack":   "res://art/bg/l2_snack_shop.png",
	"market":  "res://art/bg/l3_traditional_market.png",
	"alley":   "res://art/bg/l4_food_alley.png",
	"prestige":"res://art/bg/l5_prestige_restaurant.png",
}

## levels.csv 의 market 값(home/noryangjin/market/gwangjang) → 환경 art env_key 매핑.
## 모든 화면(menu/result/cooking)이 같은 source of truth를 공유하도록 static helper로 둔다.
## gameplay/scoring 무영향 — 순수 시각.
const MARKET_TO_ENV := {
	"home":       "home",      # L1 home kitchen
	"snack":      "snack",     # L2 분식집
	"noryangjin": "market",    # 노량진 수산시장 → L3 traditional market (warm 시장)
	"market":     "market",    # L3 traditional market
	"alley":      "alley",     # L4 food alley
	"gwangjang":  "prestige",  # 광장시장 = premium 목적지 → L5 prestige
	"prestige":   "prestige",  # L5 prestige restaurant
}


## market 문자열 → env_key. 알 수 없는 값은 home으로 안전 폴백.
static func env_key_for_market(market: String) -> String:
	return String(MARKET_TO_ENV.get(market, "home"))


## fill_screen: art를 화면 전체에 cover (요리/메뉴/결과 = world가 화면을 채움).
## false(기본): art 하단을 화면 하단에 정렬 (counter가 하단 1/3에 오는 cooking 모드).
@export var dish_anchor_y: float = 1000.0
@export var env_key: String = "home"
@export var fill_screen: bool = false
## scrim_alpha: art 위에 깔리는 warm scrim(가독성용). 0 = scrim 없음.
@export var scrim_alpha: float = 0.0

var _tex: Texture2D = null
var _wall_color: Color = Color(0.96, 0.90, 0.82)
# art가 그려지는 화면상 rect (counter 정렬 기준 계산).
var _art_rect: Rect2 = Rect2()


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var path: String = ENV_ART.get(env_key, ENV_ART["home"])
	if ResourceLoader.exists(path):
		_tex = load(path)
		_wall_color = _sample_wall_color()
	_compute_art_rect()
	queue_redraw()


# art 배치. 두 모드:
#   fill_screen=true  : 화면 전체를 cover (menu/result — world가 화면을 가득 채움, 위쪽 wall 연장 불필요).
#   fill_screen=false : width-cover + 하단 정렬 (cooking — counter가 화면 하단 1/3에 정렬, 위는 wall 연장).
func _compute_art_rect() -> void:
	if _tex == null:
		return
	var ts: Vector2 = _tex.get_size()
	if ts.x <= 0.0 or ts.y <= 0.0:
		return
	if fill_screen:
		# cover: 화면을 완전히 덮도록 큰 축척을 선택, 중앙 정렬(상단 우선 약간 위로).
		var s: float = maxf(W / ts.x, H / ts.y)
		var draw_w2: float = ts.x * s
		var draw_h2: float = ts.y * s
		var x2: float = (W - draw_w2) * 0.5
		# 세로가 남으면 약간 위쪽(0.35)에 정렬 — counter/props가 하단에서 잘리지 않게.
		var y2: float = (H - draw_h2) * 0.35
		_art_rect = Rect2(x2, y2, draw_w2, draw_h2)
		return
	# width cover: art 폭을 화면 폭에 맞춘다.
	var scale: float = W / ts.x
	var draw_w: float = W
	var draw_h: float = ts.y * scale
	# counter가 화면 하단에 닿도록 art 하단을 화면 하단에 정렬.
	var y: float = H - draw_h
	# 단, art가 너무 짧아 상단이 화면 중앙보다 위로 못 가면 그대로 — 위쪽은 wall 연장이 채움.
	_art_rect = Rect2(0, y, draw_w, draw_h)


# art 상단 행의 평균색을 wall 연장색으로 sample (없으면 기본 cream).
func _sample_wall_color() -> Color:
	if _tex == null:
		return Color(0.96, 0.90, 0.82)
	var img: Image = _tex.get_image()
	if img == null:
		return Color(0.96, 0.90, 0.82)
	if img.is_compressed():
		img.decompress()
	var w: int = img.get_width()
	var sample_y: int = clampi(int(img.get_height() * 0.08), 0, img.get_height() - 1)
	var acc := Color(0, 0, 0, 0)
	var n: int = 0
	var x: int = 0
	while x < w:
		acc += img.get_pixel(x, sample_y)
		n += 1
		x += maxi(1, int(w / 24))
	if n == 0:
		return Color(0.96, 0.90, 0.82)
	return Color(acc.r / n, acc.g / n, acc.b / n, 1.0)


func _draw() -> void:
	if _tex == null:
		# fallback: 기존 procedural 느낌 (cream wall + brown counter). beige void 최소화.
		_draw_fallback()
		return
	if not fill_screen:
		# 1) art 위쪽 빈 영역을 wall 색으로 채움 (art 상단보다 위 = vertical gradient).
		var top_fill_h: float = maxf(_art_rect.position.y + _art_rect.size.y * 0.18, 0.0)
		var top := Gradient.new()
		top.set_color(0, _wall_color.darkened(0.04))
		top.set_color(1, _wall_color.lightened(0.02))
		var bands := 40
		for i in range(bands):
			var t: float = float(i) / float(bands)
			draw_rect(Rect2(0, t * top_fill_h, W, top_fill_h / float(bands) + 1.0), top.sample(t))
	# 2) 환경 art (counter + wall + props). fill_screen이면 화면 전체 cover.
	draw_texture_rect(_tex, _art_rect, false)
	# 2.5) UI 가독성용 warm scrim (옵션) — 카드/텍스트가 위에 떠도 대비 확보.
	if scrim_alpha > 0.0:
		draw_rect(Rect2(0, 0, W, H), Color(0.99, 0.96, 0.90, scrim_alpha))
	# 3) dish anchor 아래 soft radial spotlight — cooking hero / 음식 고정.
	_draw_spotlight(Vector2(W * 0.5, dish_anchor_y), 540.0, Color(1.0, 0.94, 0.80, 0.28))
	# 4) 하단 살짝 vignette (control/feedback UI 가독성).
	for i in range(16):
		var t2: float = float(i) / 16.0
		var a: float = 0.10 * (1.0 - t2)
		draw_rect(Rect2(0, H - (1.0 - t2) * 70.0, W, 70.0 / 16.0 + 1.0), Color(0, 0, 0, a))


func _draw_fallback() -> void:
	var wall := Gradient.new()
	wall.set_color(0, Color(0.985, 0.910, 0.830))
	wall.set_color(1, Color(0.985, 0.952, 0.895))
	var wall_h: float = H * 0.62
	for i in range(48):
		var t: float = float(i) / 48.0
		draw_rect(Rect2(0, t * wall_h, W, wall_h / 48.0 + 1.0), wall.sample(t))
	_draw_spotlight(Vector2(W * 0.5, dish_anchor_y), 540.0, Color(1.0, 0.92, 0.78, 0.30))
	var counter_y := H * 0.66
	var counter_h := H - counter_y
	var cg := Gradient.new()
	cg.set_color(0, Color(0.74, 0.55, 0.36))
	cg.set_color(1, Color(0.42, 0.27, 0.16))
	for i in range(32):
		var t: float = float(i) / 32.0
		draw_rect(Rect2(0, counter_y + t * counter_h, W, counter_h / 32.0 + 1.0), cg.sample(t))
	draw_rect(Rect2(0, counter_y - 4.0, W, 6.0), Color(0.94, 0.78, 0.50, 0.85))


func _draw_spotlight(center: Vector2, radius: float, base_color: Color) -> void:
	var rings: int = 16
	for i in range(rings):
		var t: float = float(i) / float(rings)
		var r: float = radius * (1.0 - t * 0.85)
		var a: float = base_color.a * (1.0 - t)
		draw_circle(center, r, Color(base_color.r, base_color.g, base_color.b, a))
