"""
K-Food Master — M1 후반 sprint UI 일러스트 7장 + VFX 5장 = 총 12장 anchor 자동 생성.

ADR-005 (4-stage rhythm tap) Stage 2A/B/C HUD + PASS feedback prerequisite — 각 UI/VFX는
별도 transparent-friendly sprite로 생성되며, godot-dev가 UI Node + AnimationPlayer/Particles로
배치/애니메이션. art-style v1.2 modern + Cool Sage bg + slim outline + 영어 minimal text lock 유지.
rembg transparent 표준 (ADR-007) 호환을 위해 처음부터 단순 형태 + outline + 충분한 bg padding.

art-director docs/prompts-library.md v1.22 §5.12 STYLE_SUFFIX_UI + UI 7장 + VFX 5장
prompt를 그대로 inline 임베드.

UI 7장 list (게임 HUD/메뉴/버튼/아이콘):
  UI-01 tap_target_ring         — Stage 2A rhythm tap perfect zone circular ring
  UI-02 star_rating             — Stage 3 ★1/★2/★3 result rating (golden star)
  UI-03 heart_life              — HUD life count (라이프 시스템)
  UI-04 coin_currency           — HUD coin currency
  UI-05 timer_bar               — Stage 2C 조리 시간 게이지 (horizontal progress bar)
  UI-06 settings_gear           — menu settings gear icon
  UI-07 back_arrow              — navigation back arrow

VFX 5장 list (rhythm tap PASS / 조리 PASS / star earn feedback):
  VFX-01 perfect_glow_ring      — Stage 2A perfect tap feedback (yellow burst ring)
  VFX-02 star_burst             — Stage 3 ★1/2/3 earn moment (radial star burst)
  VFX-03 steam_swirl            — Stage 2C 조리 active feedback (white steam wisp)
  VFX-04 heart_float            — Stage 3 family reaction ★3 (floating hearts)
  VFX-05 sparkle_multi          — general celebration bonus moment

각 UI/VFX prompt 공통:
  - 단독 sprite (다른 UI/VFX 없이, single hero element on Cool Sage bg)
  - 단순 기하 형태 + 명확한 outline (transparent 후처리 안전)
  - icon-first + 영어 minimal text (한글 0건)
  - modern saturated 80-90% + slim outline 2-3px + Cookingo-inspired clean flat
  - Cool Sage `#C8D5C0` bg (rembg로 후처리 후 transparent PNG)

Usage:
    py tools/gen_ui_vfx_anchors_m1.py
    py tools/gen_ui_vfx_anchors_m1.py --only UI-01                       # 1장만
    py tools/gen_ui_vfx_anchors_m1.py --only UI-01,VFX-01                # 일부
    py tools/gen_ui_vfx_anchors_m1.py --only UI-01,UI-02,UI-03           # UI만 3장
    py tools/gen_ui_vfx_anchors_m1.py --model gpt-image-1 --quality medium
    py tools/gen_ui_vfx_anchors_m1.py --version v2                       # 파일명 suffix

Default:
    model    = gpt-image-1 (medium quality)
    quality  = medium ($0.042/img × 12 = ~$0.50 total)
    size     = 1024x1024 (square 1:1)
    out_dir  = assets-raw/ui_vfx_anchors_m1/
"""

import argparse
import sys
import time
from pathlib import Path

# project root sys.path 추가 — gen_image import
PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT / "tools"))

from gen_image import generate_image, load_api_key  # noqa: E402

# Windows cp949 회피
if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")

from openai import OpenAI  # noqa: E402


# ─────────────────────────────────────────────────────────────────────────────
# STYLE_SUFFIX_UI — 모든 UI / VFX anchor prompt 끝에 부착
# prompts-library.md v1.22 §5.12/§5.13 STYLE_SUFFIX_UI.
# 단독 sprite + Cool Sage bg + transparent-friendly + slim outline + modern saturated
# + simple geometric flat + Cookingo-inspired clean + 영어 minimal + cross-asset cluster.
# ─────────────────────────────────────────────────────────────────────────────
STYLE_SUFFIX_UI = """Format: square 1:1.
View: flat front-facing (icon/UI element viewed straight-on, NOT 7/8 perspective, NOT top-down,
NOT 3D depth — this is a 2D UI sprite or VFX particle that lives on the HUD overlay layer).
Style: modern mobile casual game UI/VFX asset, clean 2D illustration in Royal Match (Dream
Games 2021) + Cookingo: Perfect Meal (Asian mobile 2025-2026) aesthetic. Hero shot of a SINGLE
HUD UI element or VFX feedback sprite as a standalone transparent-friendly sprite (this is an
isolated UI/VFX icon for in-game HUD overlay — the asset will be background-removed by rembg
post-processing and placed on Godot UI / Particles Node).
Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black, consistent with all 49+ asset
cluster) wrapping the entire element silhouette for clean edge readability after rembg cutout.
Single color fill with optional soft 1-layer cel shading and ONE small specular highlight per
element. Vibrant saturated colors at 80-90 percent saturation. Simple geometric flat fill
shapes (Cookingo-inspired — bold simple shapes, soft rounded corners, no excessive realism,
no gradient mesh, no painterly texture).

SPRITE ISOLATION (consistent across all 12 UI/VFX anchors):
- The single hero UI/VFX element sits at the CENTER of the frame, occupying ~50-70% of the
  image area with comfortable padding margins around it (the padding is CRITICAL for rembg
  alpha cutout — the element silhouette must have clean Cool Sage bg around all edges, NOT
  bleeding to frame edge).
- NO other UI elements, NO HUD frame, NO menu container, NO buttons, NO labels, NO score
  numbers, NO game scene background, NO food, NO ingredients, NO tools, NO characters, NO
  hands — just the standalone UI/VFX element on the clean background.
- Symmetric or near-symmetric composition preferred for clean Godot Node center pivot (rotation
  / scale tween-friendly).

BACKGROUND:
- Solid Cool Sage #C8D5C0 background (consistent across all 12 UI/VFX anchors, matches food
  + environment + cut + ingredient + ingredient_cut + reaction + tool anchor clusters for
  cross-asset one-game-world identity — cumulative 49+ anchor cluster).
- NO ambient shadow under the element (UI/VFX elements are HUD overlay layer with no
  diegetic ground — the shadow would render incorrectly on UI; this is DIFFERENT from food /
  tool anchors which DO have ambient shadow because they sit on a diegetic surface).

TEXT POLICY (icon+English minimal lock — feedback_i18n_icon_first.md, 2026-05-27):
- NO Korean (한글) text anywhere in the sprite (Korean characters render unreliably in
  DALL-E / GPT-image-1).
- English text minimal — only if explicitly specified in the body prompt (e.g., "PERFECT!"
  burst label, or a short numeric label). Otherwise the sprite is icon-only (no text).
- If any text is included, it must be in bold sans-serif English caps with high legibility,
  no decorative typography, no Korean hangul, no Japanese kana, no Chinese hanzi.

Important: avoid beige background, cream paper background, scrapbook, storybook, kraft paper,
vintage texture, golden hour, sunset warm lighting,
Cookie Run, Cookie Run Kingdom frosting style, Toca Boca, Toon Blast over-cartoony,
realistic or photorealistic rendering, 3D render, octane or unreal engine, photography,
heavy metallic reflection, mirror polish, any texture, noise, grain,
painterly or hand-painted feel, watercolor, gradient mesh, multi-layer complex shading,
hyperdetailed elements, cinematic, gritty, blood, gore,
multiple UI elements in one image (each UI/VFX sprite is standalone — NO companion icons,
NO HUD frame / dialog window / button row / menu strip surrounding the hero element, NO icon
sets stacked together),
food / ingredients / characters / hands / cooking tools / kitchen scene in the sprite (those
are separate anchor clusters — UI/VFX sprites are pure HUD overlay graphics),
Korean text (한글), Japanese kana (ひらがな・カタカナ), Chinese hanzi (汉字), Korean alphabet,
hangul block characters, decorative typography, calligraphy font, handwritten script,
any text leaking from background or surrounding the hero element (the hero element is purely
visual icon/VFX, optional English caps label only if body prompt specifies),
ambient ground shadow under the element (UI/VFX live on HUD overlay layer, NOT on a diegetic
surface — the ambient shadow under food/tool anchors does NOT apply here),
photorealistic light bloom, lens flare, chromatic aberration, motion blur, depth of field
(VFX sparkle/glow effects are flat geometric stylized shapes, NOT photoreal post-process
effects)."""


# ─────────────────────────────────────────────────────────────────────────────
# UIS — 12개 항목 (UI 7 + VFX 5)
# prompts-library.md v1.22 §5.12.1~§5.12.7 (UI) + §5.13.1~§5.13.5 (VFX) 본문 inline.
# 각 항목: id (UI-XX / VFX-XX) / name (slug) / kind (ui|vfx) / usage (게임 context) / body.
# STYLE_SUFFIX_UI는 자동 append via .replace("%s", STYLE_SUFFIX_UI, 1).
# ─────────────────────────────────────────────────────────────────────────────
UIS = [
    # ═══════════════════ UI 7장 ═══════════════════
    {
        "id": "UI-01",
        "name": "tap_target_ring",
        "kind": "ui",
        "usage": "Stage 2A rhythm tap perfect zone circular ring",
        # §5.12.1 tap target — concentric ring (outer guide + inner shrinking timing ring)
        "body": """A modern mobile casual game UI sprite of a RHYTHM TAP TARGET RING — a clean
concentric double-ring icon that marks the perfect-tap zone for the K-Food Master Stage 2A
rhythm tap mini-game (재료 준비 cut rhythm tap), single hero UI element centered on the canvas.

Element form: TWO CONCENTRIC RINGS forming a tap target.
- OUTER RING (the static guide ring): a clean thin circular ring outline approximately 75-80%
  of the image width in diameter, drawn as a slim crisp 5-8px stroke ring in WARM DARK
  #2D1D14 (matching the cluster outline color), with a subtle inner glow tint of soft white
  #FFFFFF at ~30% alpha on the inner edge to suggest a tap-receptive target.
- INNER RING (the shrinking timing ring that the player must tap when it aligns with the
  outer ring): a thicker bold circular ring outline approximately 55-60% of the image width in
  diameter, drawn as a 12-16px stroke ring in vibrant BRIGHT YELLOW #FFD23F single fill with
  slim warm dark outline 2-3px on both inner and outer edges of the stroke for clean
  readability. The inner ring is concentric with the outer ring (same center point).
- CENTER: a small bright yellow dot (~8% of image width, #FFD23F single fill with slim warm
  dark outline) at the absolute center of both rings, marking the tap point.

USE-HINT ACCENT: NO motion line, NO sparkle, NO label text. The icon is a clean static
snapshot of the tap target at its mid-shrink state (visually communicating "the inner ring
is shrinking toward the outer ring — tap when they align"). Optional very subtle 2-3 short
radial lines (~10-15px each, thin warm dark, evenly spaced at 12 / 3 / 6 / 9 o'clock
positions) connecting the outer and inner rings as visual cue for "alignment guide" — these
are SUBTLE accents and MUST NOT obscure the ring shapes.

%s

Important also: this is a RHYTHM TAP TARGET RING UI sprite — the icon MUST read as TWO
CONCENTRIC CIRCULAR RINGS (outer dark static + inner bright yellow shrinking) with a small
center dot. NOT a target reticle / crosshair (NO horizontal/vertical crosshair lines), NOT a
bullseye archery target (NO multi-color concentric color bands, NO red/white alternating
rings — this is a simple 2-ring tap zone), NOT a circular progress bar (NO arc-fill
progress, the timing ring is a FULL CLOSED ring not a partial arc), NOT a clock face (NO
hour/minute marks, NO numbers). The single standalone concentric ring tap target on the
Cool Sage background is the hero — clean, readable, instantly understandable as "tap when
rings align"."""
    },
    {
        "id": "UI-02",
        "name": "star_rating",
        "kind": "ui",
        "usage": "Stage 3 ★1/★2/★3 result rating golden star",
        # §5.12.2 star icon — 5-point golden star, single sprite (HUD에서 3개 배치)
        "body": """A modern mobile casual game UI sprite of a STAR RATING ICON — a classic 5-point
star shape used for the ★1/★2/★3 result rating in K-Food Master Stage 3 (음식 평가), single
hero star centered on the canvas. The HUD will display three of these stars in a row, this
anchor is the SINGLE star sprite for that purpose.

Element form: a clean classic 5-POINT STAR shape — symmetric pentagram outline with the top
point pointing up, all 5 outer points equal length, all 5 inner notches equal depth. Star
diameter approximately 65-75% of image width.
- FILL: vibrant warm GOLDEN YELLOW #FFC83D single fill (slightly warmer than the tap-ring
  yellow, more golden tone for star rating warmth) with optional soft 1-layer cel shading
  hint on the bottom-right side using a slightly deeper gold #E5A82F (~30% area on
  bottom-right) and ONE small bright white #FFFFFF specular highlight on the upper-left
  point (~8% of star area) suggesting polished golden gleam.
- OUTLINE: slim bold WARM DARK #2D1D14 outline 2-3px wrapping the full pentagram silhouette
  for clean rembg cutout readability.

USE-HINT ACCENT: NO sparkle around the star, NO motion line, NO label text, NO multiple
stars (this is a SINGLE star sprite — the HUD will instantiate 3 of these for ★1/★2/★3
display). Optional very subtle inner pentagram crease line (faint warm dark hairline) along
the 5 valley axes connecting outer points to center, suggesting the geometric pentagram
construction — this is a SUBTLE accent visible only at close inspection.

%s

Important also: this is a SINGLE STAR RATING ICON sprite — the icon MUST read as a CLASSIC
5-POINT GOLDEN STAR with the top point pointing up, symmetric pentagram shape, vibrant warm
golden yellow fill with slim warm dark outline. NOT a 6-point star (Star of David, NOT a
hexagram), NOT a 4-point star (compass star, NOT a 4-pointed sparkle), NOT an 8-point or
multi-point sparkle burst (those are VFX-05 sparkle_multi territory), NOT a sheriff badge
star with letters inside, NOT a Christmas decoration star with patterns inside, NOT a star
emoji with eyes/face, NOT a country flag star. The single standalone clean 5-point golden
star icon on the Cool Sage background is the hero — instantly recognizable as a game rating
star."""
    },
    {
        "id": "UI-03",
        "name": "heart_life",
        "kind": "ui",
        "usage": "HUD life count (라이프 시스템)",
        # §5.12.3 heart life — classic mobile game red heart, single sprite
        "body": """A modern mobile casual game UI sprite of a HEART LIFE ICON — a classic
rounded heart shape used for the HUD life counter (라이프 시스템) in K-Food Master, single
hero heart centered on the canvas. The HUD will display 3-5 of these hearts side by side,
this anchor is the SINGLE heart sprite for that purpose.

Element form: a clean classic ROUNDED HEART shape — two symmetric upper lobes meeting at a
center cleft on top, tapering to a soft pointed bottom tip, full bilaterally symmetric.
Heart width approximately 65-75% of image width.
- FILL: vibrant warm CORAL RED #FF5C5C single fill (slightly warmer/coral than pure red,
  consistent with modern mobile casual tone, not blood red, not pink) with optional soft
  1-layer cel shading hint on the bottom-right lobe using deeper coral #E54545 (~25-30% area
  on bottom-right) and ONE small bright white #FFFFFF specular highlight on the upper-left
  lobe (~10% of heart area, classic mobile game heart shine spot) suggesting clean glossy
  surface.
- OUTLINE: slim bold WARM DARK #2D1D14 outline 2-3px wrapping the full heart silhouette
  for clean rembg cutout readability.

USE-HINT ACCENT: NO heartbeat motion line, NO sparkle, NO label text, NO multiple hearts
(this is a SINGLE heart sprite — the HUD will instantiate 3-5 for life count display). NO
arrow piercing the heart (this is a game life heart, NOT a romantic Valentine pierced
heart). The heart shape is in a clean upright resting state.

%s

Important also: this is a SINGLE HEART LIFE ICON sprite — the icon MUST read as a CLEAN
ROUNDED HEART with two symmetric upper lobes + center cleft + tapered bottom tip, vibrant
warm coral red fill with slim warm dark outline. NOT a anatomical realistic human heart
(NOT medical organ illustration, NOT with arteries/veins/atria, NOT 3D realistic), NOT a
broken heart split in two pieces, NOT a pierced heart with arrow, NOT a Valentine card heart
with frilly lace edges, NOT a flame heart, NOT a heart emoji with eyes/face. The single
standalone clean rounded coral red heart icon on the Cool Sage background is the hero —
instantly recognizable as a game life counter heart."""
    },
    {
        "id": "UI-04",
        "name": "coin_currency",
        "kind": "ui",
        "usage": "HUD coin currency",
        # §5.12.4 coin icon — front-facing round golden coin with center symbol or rim
        "body": """A modern mobile casual game UI sprite of a COIN CURRENCY ICON — a classic
round golden coin used for the HUD currency display in K-Food Master, single hero coin
centered on the canvas. The HUD will display this beside a numeric counter (e.g., "Coin
× 1240"), this anchor is the SINGLE coin sprite.

Element form: a clean front-facing ROUND COIN shape — perfect circle outline with a
slightly raised rim ring + flat central face. Coin diameter approximately 65-75% of image
width.
- OUTER RIM: a thin concentric ring (approximately 6-8% of coin radius wide) around the
  outer edge in slightly deeper gold #E5A82F single fill, suggesting the raised coin rim.
- CENTRAL FACE: the main body of the coin in vibrant warm GOLDEN YELLOW #FFC83D single fill
  with optional soft 1-layer cel shading hint on the bottom-right (deeper gold #E5A82F,
  ~25-30% area) and ONE small bright white #FFFFFF specular highlight crescent on the
  upper-left (~12% of coin area, classic glossy coin shine).
- CENTER SYMBOL: a stylized minimal SYMBOL in the center — choice of (option A) a clean
  star pentagram outline (matching the game's star rating motif, slim warm dark outline
  ~30% of coin area) OR (option B) a clean simple "W" letterform (Korean won currency hint,
  bold sans-serif warm dark stroke ~35% of coin area). For this anchor use option A (star
  pentagram outline) for visual harmony with UI-02 star_rating cross-asset consistency.
- OUTLINE: slim bold WARM DARK #2D1D14 outline 2-3px wrapping the full coin circle for
  clean rembg cutout readability.

USE-HINT ACCENT: NO sparkle around the coin, NO motion line, NO multiple stacked coins
(this is a SINGLE coin sprite — the HUD will instantiate 1 beside the counter number). Coin
is shown front-facing flat (NO 3D tilted perspective, NO edge view, NO falling/flipping
motion).

%s

Important also: this is a SINGLE COIN CURRENCY ICON sprite — the icon MUST read as a CLEAN
ROUND GOLDEN COIN with a raised rim ring + central star pentagram symbol + glossy specular
highlight, slim warm dark outline. NOT a poker chip (NO casino color stripes around edge,
NO suit symbol like club/diamond/heart/spade), NOT a US quarter / penny / Euro coin
realistic (NO real-world currency face profiles, NO eagle/portrait/national emblem), NOT a
medal with ribbon (NO ribbon attachment), NOT a yin-yang coin (NO swirl pattern), NOT a
crypto coin Bitcoin logo, NOT a stack of coins (this is SINGLE coin sprite). The single
standalone clean front-facing golden coin with star symbol on the Cool Sage background is
the hero."""
    },
    {
        "id": "UI-05",
        "name": "timer_bar",
        "kind": "ui",
        "usage": "Stage 2C 조리 시간 게이지 horizontal progress bar",
        # §5.12.5 timer bar — horizontal progress bar with empty track + colored fill
        "body": """A modern mobile casual game UI sprite of a TIMER PROGRESS BAR — a clean
horizontal cooking time gauge used for the K-Food Master Stage 2C 조리 시간 (cooking time
mini-game), single hero progress bar centered horizontally on the canvas.

Element form: a HORIZONTAL ROUNDED RECTANGLE PROGRESS BAR composed of TWO LAYERS (track +
fill).
- TRACK (empty background): a wide horizontal rounded rectangle (approximately 80-85% of
  image width × 18-22% of image height, fully rounded pill-shaped end caps) in soft
  off-white #F0EBE0 single fill with slim warm dark outline 2-3px wrapping the full pill
  silhouette. This is the empty/remaining portion of the timer bar.
- FILL (elapsed portion): a colored rounded rectangle nested inside the track from the LEFT
  edge, filling approximately 60-65% of the track width (leaving the right 35-40% empty),
  with the same rounded pill end on the LEFT side and a clean vertical edge on the RIGHT
  side where the fill currently ends. The fill color is a vibrant TIME-SAFE GREEN #6CC04A
  single fill (suggesting the cooking time is in the safe zone, before overcooking) with
  optional soft 1-layer cel shading on the bottom half (deeper green #4FA033, ~30% area
  bottom strip) and ONE small bright white #FFFFFF specular highlight strip along the top
  edge (~12% of fill area, classic glossy progress bar gleam).
- TIMING INDICATOR (optional small accent): at the boundary where the green fill ends and
  empty track begins (right edge of the fill), a small thin warm dark vertical tick mark
  (~3-4px wide × full track height) marking the current cooking progress position.

USE-HINT ACCENT: NO label text inside or around the bar, NO numeric percentage, NO clock
icon, NO motion line. The bar is shown in a clean static snapshot of "~60-65% cooked"
state. Optional very subtle 1-2 small bubble dots (faint cream #F5F0E0 ~20% alpha) on top
of the green fill area, suggesting the gentle cooking simmer — these are SUBTLE accents
visible only at close inspection.

%s

Important also: this is a TIMER PROGRESS BAR UI sprite — the bar MUST read as a CLEAN
HORIZONTAL PILL-SHAPED PROGRESS BAR with empty cream track + green fill from the left
covering ~60-65%, slim warm dark outline. NOT a vertical bar (this is HORIZONTAL), NOT a
circular progress ring (UI-01 territory and different mechanic), NOT a XP/level bar with
segmented chunks (this is SMOOTH continuous fill), NOT a health bar style with red/yellow
gradient transition (this is SOLID single-color green fill), NOT a loading bar with
animated stripes (this is CLEAN flat fill no stripes), NOT a hourglass icon (NO hourglass
shape, NO sand). The single standalone clean horizontal pill-shaped timer progress bar with
~60-65% green fill on the Cool Sage background is the hero — instantly recognizable as a
cooking time gauge."""
    },
    {
        "id": "UI-06",
        "name": "settings_gear",
        "kind": "ui",
        "usage": "menu settings gear icon",
        # §5.12.6 settings gear — classic 8-cog gear icon with center hole
        "body": """A modern mobile casual game UI sprite of a SETTINGS GEAR ICON — a classic
cogwheel gear used for the menu settings button in K-Food Master, single hero gear centered
on the canvas.

Element form: a clean front-facing COGWHEEL GEAR shape — circular gear body with 8 equally
spaced rectangular tooth nubs around the perimeter + a central round hole. Gear diameter
approximately 65-75% of image width.
- GEAR BODY: the main circular body (approximately 75% of total icon diameter, inner from
  the outer tooth tips) in soft NEUTRAL GRAY #B8BCC0 single fill with optional soft
  1-layer cel shading on the bottom-right (deeper gray #8A8E92, ~25-30% area) and ONE
  small bright white #FFFFFF specular highlight crescent on the upper-left (~10% of body
  area).
- 8 TEETH: 8 equally spaced rectangular nub teeth around the perimeter (each tooth
  approximately 12% of body radius long × 14% of body radius wide, with subtly rounded
  outer corners, NOT super sharp pointed), all in the same neutral gray fill as the body,
  positioned at 12/1:30/3/4:30/6/7:30/9/10:30 clock positions for clean radial symmetry.
- CENTRAL HOLE: a round transparent hole at the absolute center of the gear (approximately
  22-28% of total icon diameter), rendered as Cool Sage #C8D5C0 fill matching the
  background to suggest a true hole through the gear (this is critical for rembg post-
  processing — the hole must remain transparent in the final asset).
- OUTLINE: slim bold WARM DARK #2D1D14 outline 2-3px wrapping the full gear silhouette
  (outer teeth perimeter) AND the inner central hole edge for clean readability.

USE-HINT ACCENT: NO motion line suggesting rotation, NO sparkle, NO label text. The gear
is shown in a clean static front-facing state (NO tilted 7/8 perspective).

%s

Important also: this is a SETTINGS GEAR ICON sprite — the icon MUST read as a CLASSIC
CIRCULAR COGWHEEL with 8 evenly spaced rectangular teeth + central round transparent hole,
neutral gray fill with slim warm dark outline. NOT a steampunk gear with intricate
mechanical detail (NO multiple stacked gears, NO chain links, NO clockwork gears), NOT a
clock face (NO numbers, NO hands), NOT a 3D rendered gear (NO depth shading suggesting
volume), NOT a circular saw blade (NO sharp triangular teeth like a saw), NOT a wagon
wheel (NO spokes from center). The single standalone clean front-facing 8-tooth gray gear
with center hole on the Cool Sage background is the hero — instantly recognizable as the
settings/options menu icon."""
    },
    {
        "id": "UI-07",
        "name": "back_arrow",
        "kind": "ui",
        "usage": "navigation back arrow",
        # §5.12.7 back arrow — left-pointing chevron-style arrow, clean bold
        "body": """A modern mobile casual game UI sprite of a BACK ARROW ICON — a clean
left-pointing chevron-style arrow used for navigation back button in K-Food Master, single
hero arrow centered on the canvas.

Element form: a bold LEFT-POINTING ARROW shape (chevron-style) — the arrow head is a
left-pointing wedge with two slanted lines meeting at a single point on the LEFT side, and
a horizontal shaft extending to the RIGHT from the point. Arrow total width approximately
65-75% of image width.
- ARROW HEAD: two equally angled diagonal stroke lines meeting at the LEFT-MOST tip point
  — upper line going from the tip up-right at ~45 degrees, lower line going from the tip
  down-right at ~45 degrees, each stroke approximately 14-18% of image width long with
  rounded line caps. The two lines form an opening "<" wedge shape.
- ARROW SHAFT: a horizontal stroke line extending from the LEFT-MOST tip point to the
  RIGHT-MOST end at the center-right of the icon, approximately 50-55% of image width long.
- STROKE: all 3 lines (arrow head 2 + shaft 1) drawn as bold uniform 18-22px thick warm
  dark #2D1D14 strokes with cleanly rounded line caps and the arrow head + shaft joining
  cleanly at the tip point (one continuous arrow silhouette).
- The arrow form is SOLID warm dark stroke (NOT outlined hollow), the entire arrow is a
  single dark silhouette readable instantly as "go back left".
- Optional: a subtle ROUNDED RECTANGLE BUTTON BG behind the arrow (approximately 85% of
  image dimensions, rounded corners ~12px radius) in soft off-white #F0EBE0 single fill
  with slim warm dark outline 2-3px, suggesting the tappable button area. The arrow sits
  centered on this button background. The bg is OPTIONAL — if included it should be a
  subtle support shape, NOT competing with the arrow visual weight.

USE-HINT ACCENT: NO motion line suggesting backward swipe, NO sparkle, NO label text
("BACK" not needed, the arrow direction is self-evident).

%s

Important also: this is a BACK ARROW NAVIGATION ICON sprite — the arrow MUST read as a
CLEAN LEFT-POINTING CHEVRON ARROW (head + shaft) in bold warm dark stroke on optional soft
cream rounded button bg. NOT a right-pointing arrow (this is LEFT-pointing for "back"),
NOT an up/down arrow, NOT a curved U-turn arrow (NO curved arc), NOT an undo arrow
(circular arrow with hook, NO), NOT a double-chevron "<<" (this is SINGLE chevron <), NOT
a triangular play button rotated (NOT a solid filled triangle). The single standalone
clean left-chevron back arrow on the Cool Sage background is the hero — instantly
recognizable as the navigation back button."""
    },
    # ═══════════════════ VFX 5장 ═══════════════════
    {
        "id": "VFX-01",
        "name": "perfect_glow_ring",
        "kind": "vfx",
        "usage": "Stage 2A perfect tap feedback yellow burst ring",
        # §5.13.1 perfect glow — radial yellow burst ring + optional PERFECT text
        "body": """A modern mobile casual game VFX sprite of a PERFECT TAP GLOW RING — a vibrant
radial yellow burst feedback used when the player nails the perfect rhythm tap in K-Food
Master Stage 2A, single hero VFX centered on the canvas. This sprite is shown briefly
(0.3-0.5s) over the tap point as PASS feedback.

Element form: a RADIAL EXPANDING YELLOW BURST RING — a thick circular ring with multiple
short outward radial spikes giving a burst/star aura impression.
- INNER GLOW CORE: a slightly transparent bright yellow #FFE066 circular core
  (approximately 35-40% of image width diameter) at the center, single fill, suggesting
  the energetic glow center.
- MAIN BURST RING: a thick vibrant bright yellow #FFD23F ring (outer edge at ~65-70% of
  image width diameter, inner edge at ~45-50%, so the ring stroke is ~18% of image width
  thick) with optional soft cel shading hint, slim warm dark outline 2-3px on both inner
  and outer edges of the ring stroke for clean readability.
- RADIAL BURST SPIKES: 8-12 short triangular spike rays extending OUTWARD from the burst
  ring, each spike approximately 12-18% of image width long × 4-6% wide at the base
  tapering to a sharp point, evenly spaced around the ring perimeter at 30-degree
  intervals (8 spikes) or 24-degree intervals (12 spikes), same bright yellow #FFD23F fill
  with slim warm dark outline.
- OPTIONAL CENTER LABEL: a small bold sans-serif English caps "PERFECT!" label in WHITE
  #FFFFFF text with slim warm dark outline 2-3px, centered horizontally in the inner glow
  core area (~25-30% of image width text width). The label is OPTIONAL — if included it
  must be bold legible English caps only (NO Korean hangul). For this anchor INCLUDE the
  "PERFECT!" label for clear feedback semantics.
- OUTLINE: slim warm dark #2D1D14 outline 2-3px wrapping the full burst silhouette (outer
  spike tips) for clean rembg cutout readability.

USE-HINT ACCENT: optional 3-5 tiny additional sparkle dots (bright white #FFFFFF, ~2-3%
of image width each, with small 4-point sparkle cross shapes) scattered around the burst
ring exterior (between or beyond the spikes), adding subtle festive accent — these are
SUBTLE supplementary accents.

%s

Important also: this is a PERFECT TAP GLOW RING VFX sprite — the VFX MUST read as a
RADIAL YELLOW BURST RING with central glow + thick yellow ring + 8-12 outward spike rays +
optional bold "PERFECT!" English label, slim warm dark outline. NOT a sun icon (NO solid
filled sun face), NOT a firework explosion (NO multi-color sparks radiating, NO smoke
trails), NOT an aura halo with mystical glow (NO ethereal gradient blur), NOT a target
reticle (this is celebratory BURST, not aiming UI), NOT a manga speed line burst (NO
parallel slash lines from edges, the rays here are radial OUTWARD from center). The single
standalone clean radial yellow burst ring on the Cool Sage background is the hero —
instantly recognizable as a positive PASS feedback effect."""
    },
    {
        "id": "VFX-02",
        "name": "star_burst",
        "kind": "vfx",
        "usage": "Stage 3 star earn moment radial star burst",
        # §5.13.2 star burst — central star + radial sparkle rays + supporting confetti
        "body": """A modern mobile casual game VFX sprite of a STAR BURST CELEBRATION — a
joyful radial burst featuring a central golden star surrounded by radiating sparkle rays,
used when the player earns a ★1/★2/★3 rating in K-Food Master Stage 3, single hero VFX
centered on the canvas. This sprite is shown briefly (0.4-0.6s) when each star is awarded.

Element form: a CENTRAL STAR + RADIATING RAYS + SUPPORTING SPARKLES composition.
- CENTRAL STAR: a classic 5-point golden star (similar to UI-02 star_rating) at the center,
  approximately 35-40% of image width in star diameter, vibrant warm GOLDEN YELLOW
  #FFC83D single fill with soft cel shading on bottom-right (deeper gold #E5A82F) + ONE
  bright white #FFFFFF specular highlight on upper-left point + slim warm dark outline
  2-3px.
- RADIATING RAYS: 6-8 elongated triangular light rays extending OUTWARD from the central
  star, each ray approximately 18-25% of image width long × 5-8% wide at the base
  tapering to a sharp point, evenly spaced around the star at 45-degree intervals (8 rays)
  or 60-degree (6 rays). Ray fill is soft bright WARM GOLDEN #FFD962 with slight
  transparency hint (suggesting energetic light beams) + slim warm dark outline 2-3px on
  each ray edge for clean readability.
- SUPPORTING SPARKLES: 5-7 small additional sparkle accents scattered around the burst
  exterior (between or beyond the rays), each sparkle is a small 4-point sparkle cross
  shape (~4-6% of image width each, bright white #FFFFFF with slim warm dark outline)
  giving a festive celebration aura. Sparkle positions are slightly asymmetric organic
  (not perfectly geometric grid) for natural celebratory feel.
- OUTLINE: slim warm dark #2D1D14 outline 2-3px wrapping all elements for clean rembg
  cutout readability.

USE-HINT ACCENT: NO label text (this is pure visual celebration, the rated star count is
communicated by UI-02 star count separately, this VFX is just the burst moment). NO
confetti pieces with multiple colors (keep it golden+white celebration palette only).

%s

Important also: this is a STAR BURST CELEBRATION VFX sprite — the VFX MUST read as a
CENTRAL 5-POINT GOLDEN STAR + 6-8 RADIATING LIGHT RAYS + 5-7 SCATTERED SUPPORTING
SPARKLES, golden+white celebration palette, slim warm dark outline. NOT a multi-color
confetti explosion (NO red/blue/green pieces, keep golden+white only), NOT a firework
explosion with cascading trails, NOT a sun ray burst (the center is STAR shape not sun
disc), NOT a Christmas tree star decoration (NO tree below, isolated burst), NOT a Star
Wars logo style starburst with text (NO "STAR" text). The single standalone clean star
burst with central golden 5-point star + radiating golden rays + scattered white sparkles
on the Cool Sage background is the hero — instantly recognizable as a star earn moment
celebration."""
    },
    {
        "id": "VFX-03",
        "name": "steam_swirl",
        "kind": "vfx",
        "usage": "Stage 2C cooking active feedback white steam wisp",
        # §5.13.3 steam swirl — 2-3 rising white wisps with curl
        "body": """A modern mobile casual game VFX sprite of a STEAM SWIRL — a soft rising
cooking steam wisp feedback shown during active cooking in K-Food Master Stage 2C, single
hero VFX centered on the canvas. This sprite is overlaid on top of pots/pans while cooking
is in progress (looping animation).

Element form: 2-3 RISING STEAM WISP SHAPES — soft cloud-like organic curving shapes that
rise from the bottom of the frame upward and slightly outward with a gentle swirl curl at
the top.
- WISP 1 (center main): a tall S-curve rising wisp from the lower-center of the frame
  upward, approximately 60-70% of image height, starting as a wider base (~15% image
  width) at the bottom and tapering to a thinner curl at the top (~8% image width) with
  a gentle leftward-then-rightward S-curve sway, ending in a small rounded curl at the top.
- WISP 2 (left supporting): a shorter S-curve rising wisp from the lower-left area,
  approximately 50% of image height, starting wider base (~12% image width) at the bottom
  and tapering to thin curl at top (~6% image width) with a rightward-then-leftward curve
  (mirror of wisp 1 for organic asymmetry), ending in a small rounded curl.
- WISP 3 (right supporting, optional): a similar shorter S-curve rising wisp from the
  lower-right area, approximately 45% of image height with leftward curve.
- WISP FILL: soft semi-transparent OFF-WHITE #F8F4EC single fill (very slight warm cream
  tint, suggesting natural cooking steam, NOT pure stark white) with subtle 1-layer
  shading hint of softer cool gray-white #E8E4DC on the lower portion of each wisp
  (~25-30% area on lower half, suggesting the slightly cooler base of the rising steam).
  Steam has gentle organic cloud-like edge curvature, NOT geometric hard shapes.
- OUTLINE: slim warm dark #2D1D14 outline 2-3px wrapping each wisp silhouette for clean
  rembg cutout readability. (The outline is functional for rembg edge detection — the
  wisps remain visually soft because the fill is high-key cream not stark white.)

USE-HINT ACCENT: NO sparkle, NO label text, NO heat distortion lines, NO bubbles, NO
cooking pot underneath (this is JUST the steam wisp sprite, the pot is a separate TOOL-02
anchor — they layer together in-game).

%s

Important also: this is a STEAM SWIRL VFX sprite — the VFX MUST read as 2-3 ORGANIC RISING
STEAM WISPS with S-curve sway + tapered top with small curl + soft off-white fill + slim
warm dark outline. NOT a single straight vertical line of steam (NO straight pillar, the
wisps must curve organically), NOT a thick smoke cloud (this is light cooking STEAM not
heavy smoke, fill is high-key cream not dark gray), NOT a fire/flame (NO red/orange tones,
NO pointed flame tips — those are TOOL-01 burner flame territory), NOT a tornado/cyclone
funnel (the curls are gentle wisps not violent vortex), NOT a genie smoke from lamp (no
mystical effect). The single standalone clean rising steam wisps on the Cool Sage
background is the hero — instantly recognizable as gentle cooking steam feedback."""
    },
    {
        "id": "VFX-04",
        "name": "heart_float",
        "kind": "vfx",
        "usage": "Stage 3 family reaction star3 moment floating hearts",
        # §5.13.4 heart float — 3-5 rising hearts (size variation, slight rotation)
        "body": """A modern mobile casual game VFX sprite of a HEART FLOAT BURST — a joyful
group of small floating hearts rising upward, used as ★3 family reaction celebration in
K-Food Master Stage 3 (특히 어머니 ★3 reaction), single hero VFX centered on the canvas.
This sprite is shown briefly (0.6-0.9s) overlaid on the family reaction portrait when ★3
is earned.

Element form: 3-5 FLOATING HEART SHAPES at varying sizes and slight rotations, arranged
in a loose ascending vertical cluster suggesting upward floating motion.
- HEART 1 (largest, lower-center): the lead heart approximately 30% of image width,
  positioned in the lower-center of the frame, vertically upright (no rotation), vibrant
  warm CORAL RED #FF5C5C single fill (matching UI-03 heart_life color for consistency)
  with soft cel shading on bottom-right (deeper coral #E54545) + small bright white
  specular highlight on upper-left lobe + slim warm dark #2D1D14 outline 2-3px.
- HEART 2 (medium, upper-left): approximately 22% of image width, positioned in the
  upper-left area at about 65-70% of image height up, slightly rotated ~15 degrees
  counter-clockwise (tilting left), same coral red fill + slim warm dark outline.
- HEART 3 (medium, upper-right): approximately 22% of image width, positioned in the
  upper-right area at about 70-75% of image height up, slightly rotated ~15 degrees
  clockwise (tilting right, mirror of heart 2), same coral red fill + slim warm dark
  outline.
- HEART 4 (small, top): approximately 14% of image width, positioned at the top center
  about 85-90% of image height up, slightly rotated ~10 degrees (random direction),
  same coral red fill + slim warm dark outline. Optional slightly lighter saturation to
  suggest "fading upward".
- HEART 5 (smallest, optional): approximately 10% of image width, positioned at any small
  gap (e.g., between heart 1 and heart 3), same coral red fill + slim warm dark outline.
- OUTLINE: slim warm dark #2D1D14 outline 2-3px wrapping each heart silhouette for clean
  rembg cutout readability.

USE-HINT ACCENT: optional very subtle 2-3 tiny "floating motion" dots (small ~1-2% image
width white dots) trailing below the larger hearts to suggest upward floating motion —
these are very SUBTLE accents. NO label text, NO pink sparkles around hearts (keep coral
red only for color harmony).

%s

Important also: this is a HEART FLOAT BURST VFX sprite — the VFX MUST read as 3-5
COLLEAGUE COLORFUL ROUNDED HEARTS at varying sizes and slight rotations arranged in an
ascending loose vertical cluster (suggesting upward float), vibrant warm coral red fill
with slim warm dark outline. NOT a single large heart (this is a CLUSTER of multiple
hearts), NOT pink/magenta hearts (keep coral red consistent with UI-03 heart_life), NOT
anatomical hearts, NOT broken hearts, NOT pierced hearts with arrows, NOT a heart-shaped
bouquet of flowers (just hearts, no flowers), NOT Valentine's day decorative hearts with
frilly lace. The single standalone clean group of floating coral red hearts on the Cool
Sage background is the hero — instantly recognizable as a joyful family reaction
celebration effect."""
    },
    {
        "id": "VFX-05",
        "name": "sparkle_multi",
        "kind": "vfx",
        "usage": "general celebration bonus moment",
        # §5.13.5 sparkle multi — 5-8 4-point sparkles, various sizes, scattered
        "body": """A modern mobile casual game VFX sprite of a SPARKLE MULTI BURST — a
festive cluster of multiple 4-point sparkle accents scattered across the frame, used as
general bonus / combo / celebration moment feedback in K-Food Master, single hero VFX
centered on the canvas. This sprite is shown briefly (0.3-0.5s) for various positive
moments not covered by VFX-01/02/04.

Element form: 6-9 FOUR-POINT SPARKLE CROSS SHAPES at varying sizes and positions,
scattered in a loose organic cluster covering most of the frame area.
- SPARKLE CROSS SHAPE: each sparkle is a classic 4-point "plus / diamond" cross — two
  elongated diamond/leaf shapes crossing perpendicularly at their center point, the
  vertical diamond slightly taller and the horizontal diamond slightly wider, creating a
  twinkling star sparkle shape. Each sparkle has BRIGHT WHITE #FFFFFF single fill with
  subtle WARM GOLDEN YELLOW #FFE066 inner glow hint at the very center (~25% of sparkle
  size) and slim warm dark #2D1D14 outline 2-3px wrapping the full 4-point silhouette.
- SPARKLE 1-2 (largest, center area): 2 large sparkles each approximately 25-30% of
  image width, positioned slightly off-center (one upper-left, one lower-right) for
  visual balance.
- SPARKLE 3-5 (medium, mid-distance): 3 medium sparkles each approximately 15-20% of
  image width, scattered around the larger sparkles at organic positions (upper-right,
  mid-left, lower-center).
- SPARKLE 6-9 (small, edge accents): 3-4 small sparkles each approximately 8-12% of
  image width, scattered near the frame edges in remaining gaps for festive density.
- COLOR PALETTE: the sparkles are all bright white + warm golden center glow only —
  NO multi-color (no red/blue/green sparkles, this is gold+white celebration consistent
  with VFX-01/02). Slight size variation creates depth/twinkle suggestion.
- POSITIONING: organic asymmetric scatter (not perfect geometric grid) for natural
  celebration feel, with comfortable padding from frame edges for rembg cutout safety.
- OUTLINE: slim warm dark #2D1D14 outline 2-3px wrapping each sparkle silhouette for
  clean rembg cutout readability.

USE-HINT ACCENT: NO connecting lines between sparkles, NO trail or motion lines, NO
central focal element (the sparkles ARE the hero collectively, no single dominant element
in the middle).

%s

Important also: this is a SPARKLE MULTI BURST VFX sprite — the VFX MUST read as a
SCATTERED CLUSTER OF 6-9 FOUR-POINT WHITE+GOLD SPARKLE CROSSES at varying sizes, organic
asymmetric layout, slim warm dark outline. NOT a starburst with central solid element
(VFX-02 territory), NOT a single large sparkle (this is MULTIPLE sparkles), NOT
multi-color confetti (keep white+gold only), NOT snowflakes (NO 6-point snowflake with
fractal arms — these are 4-point sparkle crosses), NOT geometric sparkle grid (organic
scatter), NOT plus signs / cross icons (the elongated diamond shape is sparkle not plus).
The single standalone clean scattered cluster of white+gold 4-point sparkles on the Cool
Sage background is the hero — instantly recognizable as a general celebration bonus
feedback effect."""
    },
]


def build_prompt(body: str) -> str:
    """body의 첫 %s를 STYLE_SUFFIX_UI로 교체. body의 다른 % 문자(예: 75%, ~25% 등)는
    .format / f-string과 달리 .replace로 안전 보존 (gen_food/gen_ingredient/gen_reaction/
    gen_tool에서 동일 패턴 fix).
    """
    return body.replace("%s", STYLE_SUFFIX_UI, 1)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="M1 후반 UI 7장 + VFX 5장 = 12 anchor 자동 생성 (transparent-friendly sprite)"
    )
    parser.add_argument(
        "--only", type=str, default="",
        help="콤마구분 UI/VFX ID만 (예: UI-01,VFX-01). 빈 값=전체 12장."
    )
    parser.add_argument("--model", default="gpt-image-1", choices=["dall-e-3", "gpt-image-1"])
    parser.add_argument(
        "--size", default="1024x1024",
        help="dall-e-3: 1024x1024 권장. gpt-image-1: 1024x1024 / 1536x1024 / 1024x1536."
    )
    parser.add_argument(
        "--quality", default="medium",
        help="dall-e-3: standard ($0.04) / hd ($0.08). gpt-image-1: low/medium/high/auto."
    )
    parser.add_argument(
        "--out-dir", type=Path,
        default=PROJECT_ROOT / "assets-raw" / "ui_vfx_anchors_m1",
        help="출력 디렉터리"
    )
    parser.add_argument(
        "--version", type=str, default="v1",
        help="파일명 suffix (예: v1 → UI-01_tap_target_ring_v1.png)"
    )
    args = parser.parse_args()

    only_set = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    selected = [u for u in UIS if (only_set is None or u["id"] in only_set)]

    if not selected:
        sys.exit(f"❌ --only 매칭 UI/VFX 없음. 유효 ID: {[u['id'] for u in UIS]}")

    args.out_dir.mkdir(parents=True, exist_ok=True)

    # cost estimate
    if args.model == "dall-e-3":
        unit = 0.080 if args.quality == "hd" else 0.040
    else:
        unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
        unit = unit_map.get(args.quality, 0.042)
    est_total = unit * len(selected)
    print("=" * 70)
    print("🎨 M1 후반 UI 7 + VFX 5 anchor 생성 시작 (transparent-friendly sprite, ADR-007 호환)")
    print(f"   모델: {args.model} / 품질: {args.quality} / 사이즈: {args.size}")
    print(f"   대상: {len(selected)}장 ({[u['id'] for u in selected]})")
    print(f"   비용 예상: ${unit:.3f}/장 × {len(selected)} = ${est_total:.2f}")
    print(f"   출력: {args.out_dir}")
    print("=" * 70)

    api_key = load_api_key()
    client = OpenAI(api_key=api_key)

    successes: list[str] = []
    failures: list[tuple[str, str]] = []
    t0 = time.time()

    for i, ui in enumerate(selected, 1):
        uid = ui["id"]
        name = ui["name"]
        kind = ui["kind"]
        usage = ui["usage"]
        out_path = args.out_dir / f"{uid}_{name}_{args.version}.png"
        prompt = build_prompt(ui["body"])

        print(f"\n[{i}/{len(selected)}] {uid} ({kind}) usage={usage}")
        print(f"   → {out_path.name}")
        t_start = time.time()
        try:
            generate_image(
                client=client,
                prompt=prompt,
                output_path=out_path,
                model=args.model,
                size=args.size,
                quality=args.quality,
            )
            elapsed = time.time() - t_start
            print(f"   ⏱️  {elapsed:.1f}s")
            successes.append(uid)
        except Exception as exc:
            elapsed = time.time() - t_start
            print(f"   ❌ FAIL ({elapsed:.1f}s): {exc!r}")
            failures.append((uid, repr(exc)))

    total_elapsed = time.time() - t0
    print("\n" + "=" * 70)
    print(f"✅ 완료: {len(successes)}/{len(selected)} 장 — 총 {total_elapsed/60:.1f}분")
    if successes:
        print(f"   성공: {', '.join(successes)}")
    if failures:
        print(f"   실패 {len(failures)}장:")
        for uid, err in failures:
            print(f"     - {uid}: {err}")
    print(f"   비용 예상: ${unit * len(successes):.2f}")
    print(f"   저장 경로: {args.out_dir}")
    print("=" * 70)


if __name__ == "__main__":
    main()
