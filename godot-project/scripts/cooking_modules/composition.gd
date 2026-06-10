## Composition — shared 7-zone layout + scale-clamp system for the 8 cooking modules.
##
## URGENT layout fix (2026-06-06): asset architecture(standalone layered)는 정답이므로
## 유지하되 runtime layout/scaling/framing만 통제한다. 이전에는 각 module이 1080x1920
## 좌표에 rect를 손으로 박아 넣어 (1) asset이 화면 밖으로 잘리고 (2) tool/ingredient이
## 거대하며 (3) vessel 경계를 넘고 (4) 큰 beige void가 생겼다. 이 helper가:
##   - 화면을 7개 zone으로 분할 (Instruction / Action / Feedback / Safe / GuestMini ...)
##   - asset을 zone + max W/H ratio로 clamp (no ingredient/tool fills 80% screen)
##   - aspect를 유지하며 rect 안에 fit (랜덤 crop 금지)
##
## 좌표계: project viewport = 1080x1920 (window override 540x960, 동일 9:16 비율이므로
## % 매핑이 1:1). 모든 zone은 1080x1920 기준 절대좌표 Rect2.
##
## gameplay/scoring 무변경 — 순수 시각 배치 유틸. module은 입력 hitbox를 zone center 기준
## 으로 잡으므로 drag 판정 도메인도 보존된다(rect를 helper가 돌려주면 그 rect로 hitbox 구성).
class_name CookingComposition
extends RefCounted

# --- 화면 기준 (project viewport) ---
const SCREEN_W: float = 1080.0
const SCREEN_H: float = 1920.0

# --- 3 zone (1080x1920 절대좌표) — P1 Cooking Rebuild 15 / 60 / 25 lock ---
# Top 15% (Y 0~288) — compact step header card (dish + step title + progress dots).
const ZONE_INSTRUCTION := Rect2(0, 0, 1080, 288)
# Middle 60% (Y 288~1440) — 실제 조리 scene: tool + ingredient + vessel + action + food state.
#   (이전 55%/288~1344 → 60%/288~1440 로 확장. cooking hero가 큰 빈 공간 없이 zone을 채운다.)
const ZONE_ACTION := Rect2(0, 288, 1080, 1152)
# Bottom 25% (Y 1440~1920) — gesture instruction + guest reaction mini + feedback meter/control.
const ZONE_FEEDBACK := Rect2(0, 1440, 1080, 480)
# CONTROL = feedback zone 상단 밴드 (gauges / progress bars / count labels). FEEDBACK과 겹쳐 사용.
const ZONE_CONTROL := Rect2(0, 1440, 1080, 192)
# Safe area margin (화면 가장자리). edge 안쪽으로 이 만큼 비운다.
const SAFE_MARGIN: float = 48.0
const SAFE_AREA := Rect2(48, 48, 984, 1824)
# Guest mini zone — bottom-left 고정 56~72px(설계 비율) → 1080 기준 132px diameter.
# feedback zone(1440~) 좌하단 모서리. 손님 reaction mini가 instruction/meter와 겹치지 않게.
const GUEST_MINI_DIAM: float = 132.0
const GUEST_MINI_POS := Vector2(40, 1620)   # bottom-left, feedback zone 안쪽

# Action zone 중앙 — 대부분 module의 cooking hero가 앉는 곳.
const ACTION_CENTER := Vector2(540, 864)     # ZONE_ACTION 중앙(288 + 1152/2 = 864)

# --- per-layer max scale clamp (% screen) — 사용자 LOCKED ---
# (max_w_ratio, max_h_ratio) — fit 후 이 비율을 넘지 않게 추가 clamp.
const CLAMP_INGREDIENT := Vector2(0.45, 0.35)         # raw ingredient
const CLAMP_PREPARED := Vector2(0.50, 0.35)           # prepared pile (raw보다 크지 않게)
const CLAMP_TOOL := Vector2(0.40, 0.28)               # 조리도구
const CLAMP_VESSEL := Vector2(0.65, 0.42)             # 그릇/팬/도마
const CLAMP_DISH_HERO := Vector2(0.70, 0.45)          # finished dish hero
const CLAMP_TOKEN := Vector2(0.12, 0.10)              # mini orbit token / tray ingredient


# =====================================================================================
# rect 계산 — zone + clamp → 화면 절대좌표 Rect2
# =====================================================================================

## zone 안에 max_w/max_h ratio(화면 대비)로 제한된 rect를 zone 중앙(또는 anchor)에 배치.
##   zone    : ZONE_ACTION 등
##   clamp   : CLAMP_* (Vector2 max_w_ratio, max_h_ratio)
##   anchor  : zone 내 0~1 정렬 (0.5,0.5 = 중앙, 0.5,0.0 = 상단중앙).
## 반환 Rect2는 module이 TextureRect.position/size로 그대로 사용.
static func rect_in_zone(zone: Rect2, clamp: Vector2,
		anchor: Vector2 = Vector2(0.5, 0.5)) -> Rect2:
	var w: float = minf(SCREEN_W * clamp.x, zone.size.x)
	var h: float = minf(SCREEN_H * clamp.y, zone.size.y)
	var x: float = zone.position.x + (zone.size.x - w) * anchor.x
	var y: float = zone.position.y + (zone.size.y - h) * anchor.y
	return Rect2(x, y, w, h)


## center 점에 max W/H ratio로 제한된 rect (중앙 기준). 특정 위치(vessel 안 등)에 둘 때.
static func rect_at_center(center: Vector2, clamp: Vector2) -> Rect2:
	var w: float = SCREEN_W * clamp.x
	var h: float = SCREEN_H * clamp.y
	return Rect2(center.x - w * 0.5, center.y - h * 0.5, w, h)


## rect를 다른 rect(container) 안쪽으로 ratio만큼 inset (vessel 안 food 배치용).
##   outer    : vessel/pan rect
##   inset    : 0~1 (0.7 = vessel의 70% 안쪽 영역에 food)
##   lift     : food를 살짝 위로(음수) 또는 아래로(양수) 이동(px) — vessel 입구 표현.
static func rect_inside(outer: Rect2, inset: float, lift: float = 0.0) -> Rect2:
	var w: float = outer.size.x * inset
	var h: float = outer.size.y * inset
	var cx: float = outer.position.x + outer.size.x * 0.5
	var cy: float = outer.position.y + outer.size.y * 0.5 + lift
	return Rect2(cx - w * 0.5, cy - h * 0.5, w, h)


# =====================================================================================
# TextureRect mount + clamp — aspect 유지 fit + zone clamp
# =====================================================================================

## TextureRect의 size를 rect에 맞추되, texture aspect를 유지하며 rect 안에 fit(contain).
## STRETCH_KEEP_ASPECT_CENTERED로 텍스처가 rect를 넘지 않게 하고, 추가로 실제 그려지는
## 영역이 rect보다 작을 수 있으므로 pivot/center는 rect 중심.
## 랜덤 crop 방지: EXPAND_IGNORE_SIZE + KEEP_ASPECT_CENTERED 조합 (절대 외부로 안 넘침).
static func fit_texture_rect(tr: TextureRect, rect: Rect2) -> void:
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.position = rect.position
	tr.size = rect.size
	tr.pivot_offset = rect.size * 0.5


## fit_asset_to_rect — 사용자 명시 helper. node(TextureRect 또는 Control)를 rect에 fit.
## TextureRect면 aspect 유지 fit, 그 외 Control이면 position/size 직접 적용.
static func fit_asset_to_rect(node: Control, rect: Rect2) -> void:
	if node is TextureRect:
		fit_texture_rect(node as TextureRect, rect)
	else:
		node.position = rect.position
		node.size = rect.size
		node.pivot_offset = rect.size * 0.5


## clamp_scale_to_zone — 사용자 명시 helper. node를 zone 안 + max ratio로 fit한다.
## (이미 만들어진 node를 사후 보정할 때. 신규 mount는 rect_in_zone + fit_asset_to_rect 권장.)
##   node          : 보정 대상 (TextureRect 권장)
##   zone_rect     : 가둘 zone
##   max_w_ratio   : 화면 대비 최대 폭
##   max_h_ratio   : 화면 대비 최대 높이
##   anchor        : zone 내 정렬 (기본 중앙)
static func clamp_scale_to_zone(node: Control, zone_rect: Rect2,
		max_w_ratio: float, max_h_ratio: float,
		anchor: Vector2 = Vector2(0.5, 0.5)) -> void:
	var rect: Rect2 = rect_in_zone(zone_rect, Vector2(max_w_ratio, max_h_ratio), anchor)
	fit_asset_to_rect(node, rect)


# =====================================================================================
# Guest mini — bottom-left 고정 circle (56~72px → 1080 기준 132px)
# =====================================================================================

static func guest_mini_rect() -> Rect2:
	return Rect2(GUEST_MINI_POS.x, GUEST_MINI_POS.y, GUEST_MINI_DIAM, GUEST_MINI_DIAM)


# =====================================================================================
# Debug zone overlay (default OFF) — zone 경계 시각화 (개발용)
# =====================================================================================

## parent에 zone 경계를 그리는 디버그 오버레이를 붙인다. default OFF — module이 명시 호출.
## 반환 Node(Control)를 .visible 토글로 on/off.
static func attach_debug_overlay(parent: Control, enabled: bool = false) -> Control:
	var ov := _DebugZoneOverlay.new()
	ov.visible = enabled
	parent.add_child(ov)
	ov.z_index = 4096   # 항상 최상단
	return ov


# zone 경계 + 라벨을 _draw로 그리는 내부 Control.
class _DebugZoneOverlay extends Control:
	func _ready() -> void:
		set_anchors_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		queue_redraw()

	func _draw() -> void:
		var zones := {
			"INSTRUCTION 15%": [CookingComposition.ZONE_INSTRUCTION, Color(0.2, 0.5, 1.0, 0.9)],
			"ACTION 60%":      [CookingComposition.ZONE_ACTION, Color(0.2, 0.9, 0.4, 0.9)],
			"FEEDBACK 25%":    [CookingComposition.ZONE_FEEDBACK, Color(1.0, 0.4, 0.4, 0.9)],
		}
		for name in zones:
			var z: Rect2 = zones[name][0]
			var c: Color = zones[name][1]
			draw_rect(z, Color(c.r, c.g, c.b, 0.06), true)
			draw_rect(z, c, false, 3.0)
			var f := ThemeDB.fallback_font
			draw_string(f, z.position + Vector2(16, 40), name, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, c)
		# safe area
		draw_rect(CookingComposition.SAFE_AREA, Color(1, 1, 1, 0.5), false, 2.0)
		# guest mini
		var gm := CookingComposition.guest_mini_rect()
		draw_rect(gm, Color(0.8, 0.4, 1.0, 0.9), false, 3.0)
