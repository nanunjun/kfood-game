"""
K-Food Master — Gimbap HIGH-ANGLE PAINTERLY asset driver (단면금지·standalone·baked X).

승인된 시각 교정 계획 실행: docs/design/gimbap-visual-quality-rebuild-v1.md §3-8.

═══════════════════════════════════════════════════════════════════════════════
핵심 LOCK (계획서 §3 — top-down ↔ painterly 긴장 해소안 = "제3의 길"):
  현 gimbap gameplay 화면이 procedural vector geometry(직사각/캡슐/원/점선)거나
  이전 AI sprite 가 3/4 oblique(비스듬) + 단면 baked 라 둘 다 거부됨.
  → 각 조리 state 를 HIGH-ANGLE (~70-80°) PAINTERLY game-art 로 재생성한다.
    · 직각 top-down(90°)도 아니고, oblique 3/4(45-55°)도 아닌, "거의 위에서
      내려다본 부드러운 채색" — top-down(위에서 봄) + painterly(volume/highlight/
      contact shadow) 동시. NOT flat vector, NOT rectangle, NOT procedural.
    · Roll state 1~5 는 단면(end-cap/spiral) 노출 0 — 단면은 "썰린 조각(piece)" 에서만.
    · bottom(near, 화면 하단) → top(far, 상단) curl. mat 회전/twist 금지 (player-POV LOCK).
    · standalone transparent — mat/board/그릇/쟁반/손/UI 함께 굽지 않음 (합성은 Godot).
  north star / Style Bible 톤: warm cozy / soft volumetric / cocoa outline / NOT flat.

  ★ 영상 GROUND TRUTH LOCK (2026-06-13, 김밥집 사장 영상 기반):
    완성 김밥(roll_finished / roll_finished_loose / roll_finished_burst / gimbap_roll_for_slice)
    = "매끈한 반들반들 검은 김 원통(CLOSED LOG)". 겉은 김 표면 하나 + seam 한 줄만, 단면(spiral/
    rice-ring/end-cap)은 절대 안 보임. 단면은 "썰었을 때(gimbap_piece_*)" 에만 노출.
    → 이 4개는 slot_mode="closed" (SMOOTH_CLOSED_LOG). 이전에 완성 roll 을 단면 보이게
      그린 것은 틀림 — 완성 김밥 겉모습 = 닫힌 매끈한 검은 통. 기법 문서:
      docs/design/gimbap-rolling-technique-v1.md.
═══════════════════════════════════════════════════════════════════════════════

생성 그룹 (계획서 §2/§5/§6/§11):
  roll      Roll 6-state + 2 variant (loose/burst) — 최우선 GATE (단면 조기노출 0)
  build     bamboo_mat / seaweed / rice / filling × 4 (carrot/egg/spinach/danmuji) painterly
  carrot    whole / on_board / strips_good / strips_bad (Julienne)
  slice     roll_for_slice / piece_good / piece_collapse (단면 appetizing / 쏟아짐)
  plate     wooden_tray_topdown (real 나무 tray, box corner 아님)
  tool      board_topdown / knife_topdown (procedural 교체용 painterly)

성격: standalone transparent, baked X (Asset Architecture Lock NEVER-merge mandate).
  출력: assets-raw/gimbap_painterly_m2/{id}.png  → 검수 후 res://art/sprites/...

생성은 main thread. Roll 먼저 생성 → 검수(단면 0 + painterly + high-angle 확인) → 나머지 batch.

Usage:
    # Roll 게이트 먼저 (최우선 — 6 state, 검수 게이트)
    py tools/gen_gimbap_painterly.py --group roll --background transparent

    # Roll 1장만 빠른 검수 (first_fold = 단면금지 핵심 검증)
    py tools/gen_gimbap_painterly.py --only roll_first_fold --background transparent

    # Roll 검수 통과 후 나머지 그룹 batch
    py tools/gen_gimbap_painterly.py --group build --background transparent
    py tools/gen_gimbap_painterly.py --group carrot,slice,plate,tool --background transparent

    # 전체 (Roll 검수 후 권장)
    py tools/gen_gimbap_painterly.py --all --background transparent

Default:
    model=gpt-image-1 / quality=medium / background=opaque(검수, production은 transparent)
    size: roll/slice = 1536x1024 (가로 우세 log), 나머지 = 1024x1024
    out=assets-raw/gimbap_painterly_m2/
"""

import argparse
import sys
import time
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT / "tools"))

from gen_image import generate_image, load_api_key  # noqa: E402

if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")

from openai import OpenAI  # noqa: E402


# ─────────────────────────────────────────────────────────────────────────────
# HIGH_ANGLE — 계획서 §3.2 핵심 1·3. 70-80° near-top-down painterly (제3의 길).
# oblique(45-55°) 도 90° flat-top 도 아닌 "거의 위에서 내려다본" 각도 → volume 살되
# 비스듬 아님. player-POV: 하단=near, 상단=far, edge 가 frame 과 평행. mat 회전 금지.
# (음식·도구·표면 공통 부착.)
# ─────────────────────────────────────────────────────────────────────────────
HIGH_ANGLE = """
CAMERA — HIGH-ANGLE NEAR-TOP-DOWN, PAINTERLY (CRITICAL — this is the "third path": neither a flat
90-degree blueprint top-down nor a slanted 3/4 product shot): The camera looks DOWN at the work from
a very steep HIGH ANGLE of roughly 70 to 80 degrees — almost straight overhead, as a seated cook
gazes down at the food right in front of them, but tilted just enough that the object reads with real
ROUNDED VOLUME and soft thickness (NOT a flat paper-thin diagram). The long form lies HORIZONTAL, its
long axis running LEFT-TO-RIGHT, its edges PARALLEL to the top and bottom of the frame. The NEAR side
(closest to the player) is the BOTTOM of the frame; the FAR side is the TOP. We look down onto the
TOP surface.
ABSOLUTELY NOT: a flat 2D paper-thin top-down vector with no volume, an oblique 3/4 product / catalog
angle (45-55 degrees), a side-on elevation, a low hero angle, a slanted / rotated / tilted layout,
the object turned into a DIAMOND / RHOMBUS / PARALLELOGRAM, a view from across the table. The form
reads STRAIGHT-ON, edges square to the frame, seen from a steep 70-80 degree overhead — high enough
to read as "looking down", tilted enough to keep painterly volume."""


# ─────────────────────────────────────────────────────────────────────────────
# NO_CROSS_SECTION — Roll state 1~5 단면 절대금지 (계획서 §3.2 원리2, §6).
# gpt-image-1 이 "이미 썰린 김밥의 spiral end-cap"을 그리지 않게 못박음. 단면은 finished/slice만.
# ─────────────────────────────────────────────────────────────────────────────
NO_CROSS_SECTION = """
NO CUT CROSS-SECTION — ABSOLUTELY CRITICAL (this gimbap is being ROLLED, it is NOT sliced, NOT
finished): Show ONLY the OUTSIDE wrapped seaweed surface of the rolling log (and, where still open,
the flat OPEN bed of rice and fillings seen from above). The spiral cross-section — the round end-cap
showing a ring of white rice around colorful fillings — MUST be HIDDEN, not visible at all. Do NOT
show a circular spiral pinwheel end, do NOT show a cut face, do NOT show a rice-ring cross-section,
do NOT show a coiled spiral inside a ring, do NOT show a sliced round piece. The log's ENDS are not
the subject and do not face the camera. It must read as a sheet partway through being WRAPPED, never
as a finished gimbap shown end-on, never as an already-cut slice."""


# ─────────────────────────────────────────────────────────────────────────────
# SMOOTH_CLOSED_LOG — 사용자 김밥집 영상 ground truth LOCK (2026-06-13).
# 실제 완성 김밥 = 매끈한 반들반들 검은 김 원통. 겉은 김 표면 하나(seam 한 줄)만 보이고
# 단면(spiral / rice-ring / end-cap)은 절대 안 보임 — 단면은 "썰었을 때만" 노출.
# 내가 계속 틀린 것: 완성 roll 을 단면 보이게 그림 → 완성 김밥 겉모습 = 닫힌 검은 통.
# roll_finished / loose / burst / gimbap_roll_for_slice 에 부착.
# ─────────────────────────────────────────────────────────────────────────────
SMOOTH_CLOSED_LOG = """
SMOOTH CLOSED LOG — ABSOLUTELY CRITICAL (this is a FINISHED whole gimbap roll, exactly as a Korean
gimbap shop owner makes it — a smooth glossy dark seaweed (nori) CYLINDER, a CLOSED LOG): show ONLY
the outer seaweed SKIN of the cylinder plus a single faint SEAM line where the sheet laps shut along
the length. The round CUT END is NOT facing the camera. There is NO spiral cross-section, NO ring of
rice, NO ring of fillings, NO pinwheel, NO coiled center, NO visible inside at all — that appears ONLY
when the roll is sliced. The ends of the log point left and right (off toward the sides), they are not
turned toward the viewer. It must read as a sealed, sleek, reflective black-green seaweed tube whose
whole surface is unbroken smooth nori — never as an end-on slice, never as a cut piece."""


# ─────────────────────────────────────────────────────────────────────────────
# PHYSICAL_CURL — 실제 물리적 fold (scale 흉내 금지, 계획서 §6). near edge → far 로 wrap.
# ─────────────────────────────────────────────────────────────────────────────
PHYSICAL_CURL = """
PHYSICAL ROLL — the seaweed-and-rice SHEET is genuinely WRAPPING into a log (NOT a flat image
squashed or scaled): The NEAR edge (bottom of the frame, closest to the player) lifts, bends UPWARD
and OVER, and wraps toward the FAR (top) edge. You see the real curved 3D body of the OUTSIDE of the
roll — the rounded soft bend of the seaweed catching the top-left light along its outer skin — and,
where it is still open, the flat open bed of rice and the row of fillings lying on top, seen from
above. The boundary between the rolled part and the still-flat part is a soft rounded ridge running
LEFT-TO-RIGHT. ABSOLUTELY NOT: a flat sheet merely squashed/scaled, a flat stretched rectangle, a 2D
image just made narrower, a finished closed log shown end-on, a sliced piece, a taco with a visible
spiral."""


# ─────────────────────────────────────────────────────────────────────────────
# STYLE_SUFFIX — north star / Style Bible 톤 LOCK + standalone(baked X) + flat-vector 금지.
# 계획서 §3.2 원리4 (painterly 품질) + §12 (NOT flat vector / NOT box placeholder).
# 기존 gimbap roll 세트 + north star 와 한 톤. %s 1개 → BACKGROUND_HINT 교체.
# ─────────────────────────────────────────────────────────────────────────────
STYLE_SUFFIX = """
STYLE — PAINTERLY HERO GAME-ART (CRITICAL — this must escape the flat-vector placeholder look that
was rejected): Premium cozy mobile cooking-game illustration in the warm storybook tone of the
K-Food Master north star (Cooking Diary / Travel Town / Merge Mansion warmth). A single HERO object
with REAL VOLUME, soft VOLUMETRIC SHADING, TACTILE TEXTURE and believable thickness — hand-drawn /
hand-painted 2D, NOT flat. Soft 2-to-3-step gradient shading (NEVER a flat single-color fill, NEVER
one solid block, NEVER a vector clip-art shape).

CONSISTENCY LOCK (one set with the existing gimbap art + north star):
- LIGHTING: a single warm KEY LIGHT from the TOP-LEFT (consistent), a soft rim light, and ONE or TWO
  small specular highlights (a gentle sesame-oil sheen — NOT glossy plastic).
- OUTLINE: a warm dark COCOA outline (#3A2A1E) at ~3-4px, slight hand-drawn weight variation (warm,
  NOT a cold uniform vector stroke).
- CONTACT SHADOW: a soft warm contact shadow directly beneath the object (cocoa #3A2A1E at ~18-22%
  alpha) cast straight DOWN for grounded depth — soft, NOT a hard black ellipse.
- TEXTURE: the grain of white rice, the matte pebbled sheen of dark seaweed, the soft body of each
  colorful filling, the bamboo / wood grain — real surface texture, not flat color.
- SEAWEED: deep dark green-black (very dark forest-green fading to warm near-black, NOT pure flat
  black), matte pebbled. RICE: warm cream-white (#FAF4E6), plump readable grains (NOT a white
  rectangle). FILLINGS: warm orange carrot, golden-yellow egg, fresh green spinach, bright clean
  yellow danmuji.
- PALETTE: warm cozy muted (mid saturation ~55-78%), appetizing and inviting.

COMPOSITION — STANDALONE (Asset Architecture Lock: NEVER bake co-assets together):
- A SINGLE hero subject centered, occupying ~62-76% of the frame.
- NO bamboo mat under the food (unless the mat IS the subject), NO cutting board (unless the board IS
  the subject), NO plate, NO bowl, NO tray (unless the tray IS the subject), NO knife (unless the
  knife IS the subject), NO chopsticks, NO hands, NO fingers, NO arms, NO characters, NO kitchen
  scene, NO text, NO labels, NO arrows. The mat / board / hands / UI are composited later in Godot.

IMPORTANT — avoid (must read as a PAINTERLY premium hero, NEVER a flat vector placeholder, NEVER a
UI icon): flat vector, flat single-color fill, flat icon, vector clip-art, sticker, emoji, pictogram,
glyph, color block, simple geometric shape, rounded-rectangle placeholder, box-corner panel,
symbolic placeholder, silhouette, infographic, app icon, simplified UI icon, MS-paint, blueprint /
schematic / dashed-line diagram, a flat sheet merely scaled or squashed, a 2D rectangle pretending to
have volume, Cookie Run frosting, Toca Boca, over-saturated neon, glossy plastic coating, mirror
chrome, cool sage / mint / teal / cold background, beige void / kraft / scrapbook / vintage noise
texture, golden-hour overexposed, photorealistic photo, 3D octane / unreal render, food photography,
anime, manga, watermark, any English or Korean text, Japanese sushi maki / nigiri, Chinese cuisine
leak.
%s"""

BACKGROUND_HINT = (
    "BACKGROUND: warm cream (Rice Cream #FBF3E4), uniform and clean — OR a fully transparent cutout "
    "(clean crisp silhouette, NO black smudge, NO dark halo, NO grey fringe) when a transparent "
    "background is requested. ABSOLUTELY NO cool sage / mint / teal / cold background."
)


# ─────────────────────────────────────────────────────────────────────────────
# slot 채우기. slot_mode (item["slot_mode"], 기본은 n_slots 호환):
#   "ha"     = HIGH_ANGLE → STYLE       (평면 setup / 도구 / 표면 / 썰린 조각 단면 OK 컷)
#   "roll"   = NO_CROSS_SECTION → PHYSICAL_CURL → HIGH_ANGLE → STYLE  (Roll 말리는 state 2~5)
#   "closed" = SMOOTH_CLOSED_LOG → HIGH_ANGLE → STYLE   (완성 김밥 = 매끈 검은 통, 단면 0)
#              ← 사용자 영상 ground truth LOCK (roll_finished/loose/burst/roll_for_slice)
# 하위호환: slot_mode 없으면 n_slots(2/4) → ha/roll 매핑.
# ─────────────────────────────────────────────────────────────────────────────
def build_prompt(item: dict) -> str:
    body = item["body"]
    style = STYLE_SUFFIX.replace("%s", BACKGROUND_HINT)
    mode = item.get("slot_mode")
    if mode is None:
        mode = "roll" if item.get("n_slots", 2) == 4 else "ha"
    if mode == "roll":
        body = body.replace("%s", NO_CROSS_SECTION, 1)
        body = body.replace("%s", PHYSICAL_CURL, 1)
        body = body.replace("%s", HIGH_ANGLE, 1)
        body = body.replace("%s", style, 1)
    elif mode == "closed":
        body = body.replace("%s", SMOOTH_CLOSED_LOG, 1)
        body = body.replace("%s", HIGH_ANGLE, 1)
        body = body.replace("%s", style, 1)
    else:  # "ha"
        body = body.replace("%s", HIGH_ANGLE, 1)
        body = body.replace("%s", style, 1)
    return body


# ═════════════════════════════════════════════════════════════════════════════
# GROUP: roll — Roll 6-state + 2 variant (최우선 GATE, 단면 조기노출 0). landscape.
#   state 1 = 평면 setup (n2). state 2~5 = 말리는 중 (n4, 단면금지). state 6 = finished 통째.
# ═════════════════════════════════════════════════════════════════════════════
ROLL = [
    {
        "id": "roll_flat_setup",
        "name": "Roll s1 — 평평 setup (mat+김+밥+filling 평면, 말림 0)",
        "size": "1536x1024",
        "n_slots": 2,
        "body": """A painterly HERO illustration of a gimbap fully LAID OUT FLAT before any rolling
(아직 안 말린 평평 setup): a wide flat sheet of dark green-black matte seaweed lies flat, an even bed of
plump warm cream-white rice (readable grains, NOT a white rectangle) is pressed on top, and a single
neat HORIZONTAL ROW of colorful fillings — a stripe of orange julienned carrot, a stripe of golden
egg, a stripe of fresh dark-green spinach, a stripe of bright yellow danmuji — runs LEFT-TO-RIGHT
across the rice. Everything is OPEN and FLAT — nothing is rolled or curled, no bend anywhere, the
whole sheet lies flat. A thin seal margin of bare seaweed shows along the far (top) edge. The long
edges are parallel to the top and bottom of the frame.
%s
%s""",
    },
    {
        "id": "roll_edge_lift",
        "name": "Roll s2 — near(하단) edge 들림, filling 보임",
        "size": "1536x1024",
        "n_slots": 4,
        "body": """A painterly HERO illustration of a gimbap at the VERY START of rolling — the NEAR
(bottom) edge just beginning to lift (하단 edge 살짝 들림). The wide flat sheet with its bed of rice
still lies mostly OPEN and flat, but the bottom edge closest to the viewer has just curled UPWARD a
little — a gentle upward bend of the seaweed lip lifting off the table, beginning to wrap. The
colorful filling row (orange carrot, golden egg, dark-green spinach, yellow danmuji) is STILL fully
visible and not yet covered — almost nothing is wrapped yet, the earliest curl. Only a soft shadow
under the lifted lip.
%s
%s
%s
%s""",
    },
    {
        "id": "roll_first_fold",
        "name": "Roll s3 — near edge filling 위로 fold (단면 금지, 김 바깥면만)",
        "size": "1536x1024",
        "n_slots": 4,
        "body": """A painterly HERO illustration of a gimbap at the FIRST FOLD of rolling (하단 edge가
속재료 위로 한 번 접힘). The near (bottom) edge has bent up and OVER, folding forward so the FRONT part
of the colorful filling row is now COVERED and tucked under the wrapping seaweed — a rounded soft BUMP
/ ridge of dark seaweed has formed along the bottom (near) part of the frame, running left-to-right —
while the BACK portion (toward the far/top edge) is still OPEN and flat with rice and the rest of the
filling row peeking out above the fold. The folded front is a smooth ROUNDED ridge of seaweed skin
(not a sharp crease, not laid flat) — only the OUTSIDE seaweed surface of the fold shows, the inside
is hidden.
%s
%s
%s
%s""",
    },
    {
        "id": "roll_curling",
        "name": "Roll s4 — 절반 말린 log (상단 평평, 단면 금지)",
        "size": "1536x1024",
        "n_slots": 4,
        "body": """A painterly HERO illustration of a gimbap ABOUT HALF ROLLED (절반쯤 말린 김밥 — 하단부는
둥근 log, 상단부는 평평 김 남음). The bottom (near) HALF has wrapped up into a rounded soft LOG of dark
seaweed — a smooth bulging horizontal body running left-to-right across the lower frame — while the
top (far) HALF is still an OPEN flat flap of seaweed with a bed of rice and the remaining filling
lying flat and visible, about to be wrapped. A clear soft rounded ridge separates the rolled log from
the still-flat flap. Only the OUTSIDE seaweed skin of the log shows — the round end / spiral inside is
HIDDEN. Real round volume on the log, soft top-left sheen along its top.
%s
%s
%s
%s""",
    },
    {
        "id": "roll_compression",
        "name": "Roll s5 — 거의 완성 + 양손 압축 (tight, 단면 금지)",
        "size": "1536x1024",
        "n_slots": 4,
        "body": """A painterly HERO illustration of a gimbap ALMOST FULLY ROLLED and being firmly
COMPRESSED tight (거의 다 말려 단단히 압축 중). The sheet is wrapped nearly all the way into a horizontal
LOG (running left-to-right) with only a SHORT remaining flap of seaweed at the far (top) edge about
to seal. The log is firm, round, evenly compressed — a clean tight cylinder body of dark seaweed with
a gentle sesame-oil sheen along its top, the wrap snug and smooth (a well-pressed roll). Only the
OUTSIDE seaweed skin shows — the round end / spiral cross-section is HIDDEN. A clean firm tight log,
mid-rolling, not yet sealed shut.
%s
%s
%s
%s""",
    },
    {
        "id": "roll_finished",
        "name": "Roll s6 — 완성 매끈 검은 통 (smooth glossy nori cylinder, seam 1줄, 단면 0)",
        "size": "1536x1024",
        "slot_mode": "closed",
        "body": """A painterly HERO illustration of ONE FINISHED gimbap roll, exactly as a Korean gimbap
shop owner presents it — a SMOOTH GLOSSY DARK SEAWEED (NORI) CYLINDER, a sealed closed LOG, whole and
UNCUT (완성된 김밥 한 줄 통째 — 매끈하고 반들반들한 검은 김 원통, 안 썰림). A firm clean ROUNDED horizontal log of
deep dark green-black seaweed with a sleek reflective sesame-oil SHEEN running along its top, its long
axis running LEFT-TO-RIGHT, and a single faint SEAM line where the sheet laps shut along the length.
Real round volume, soft top-left highlight. The whole outer surface is unbroken smooth nori — ONLY
the outer seaweed skin and that one seam show; the ROUND CUT END is NOT facing the camera and there is
NO spiral, NO rice ring, NO filling ring visible (that appears only when sliced). A clean tight
perfect roll, a sleek black-green seaweed tube (the GOOD result).
%s
%s
%s""",
    },
    {
        "id": "roll_finished_loose",
        "name": "Roll s6 variant — 헐거운 매끈 검은 통 (살짝 우는 표면, seam 살짝 뜸, 단면 0)",
        "size": "1536x1024",
        "slot_mode": "closed",
        "body": """A painterly HERO illustration of a FINISHED gimbap roll rolled LOOSE with too little
pressure — still a CLOSED smooth dark seaweed (nori) LOG, just under-pressed (헐겁게 말린 완성 김밥 통 —
약한 압력, 살짝 우는 표면). A horizontal CYLINDER (running left-to-right) wrapped in dark glossy seaweed but
clearly SLACK and a bit LUMPY — the outer nori skin looks slightly slumped, softly wavy and uneven, and
the single SEAM along the length gapes a little OPEN, under-pressed and floppy. The surface is still
the unbroken outer seaweed skin — the ROUND CUT END is NOT facing the camera, NO spiral / rice ring /
filling ring is visible (that only shows when sliced). A soft loose closed log, clearly NOT a clean
tight roll, but NOT torn open (the LOOSE result).
%s
%s
%s""",
    },
    {
        "id": "roll_finished_burst",
        "name": "Roll s6 variant — 과압축 갈라진 통 (김 split + rice 삐져나옴, 단면은 아님)",
        "size": "1536x1024",
        "slot_mode": "closed",
        "body": """A painterly HERO illustration of a FINISHED gimbap roll squeezed with TOO MUCH pressure
so the wrap has burst — still a CLOSED log shown along its length, not an end-on slice (너무 세게 눌러
터진 완성 김밥 통 — 김이 갈라지고 밥이 삐져나옴, 단면 노출은 아님). A horizontal CYLINDER (running left-to-right) of
dark seaweed CRUSHED too hard: the glossy nori skin has SPLIT and CRACKED along the TOP of the wrap and
warm cream-white rice is being SQUEEZED OUT, bulging up through the split; the log is FLATTENED and
deformed (pressed wider and lower, not a clean round tube), over-compressed and blown-out. The split
and bulging rice are along the TOP surface — the ROUND CUT END is NOT facing the camera, this is NOT
a sliced spiral cross-section, NO pinwheel rice-ring is shown. Still a whole gimbap, just over-pressured
and ruptured along its length (the BURST result).
%s
%s
%s""",
    },
]


# ═════════════════════════════════════════════════════════════════════════════
# GROUP: build — painterly build layers (재료가 real food 로 읽혀야, 계획서 §2.2/§5).
#   mat/seaweed/rice/filling 4종. high-angle painterly strip (vector line 금지). n2.
# ═════════════════════════════════════════════════════════════════════════════
BUILD = [
    {
        "id": "mat_painterly",
        "name": "Build — bamboo mat painterly (warm 김발 평면)",
        "size": "1536x1024",
        "n_slots": 2,
        "body": """A painterly HERO illustration of a Korean gimbap bamboo rolling mat (김발) lying
COMPLETELY FLAT, seen from a high overhead angle: a WIDE FLAT RECTANGLE of thin round bamboo sticks
tied side by side, the sticks running HORIZONTALLY (left-to-right), four edges PARALLEL to the frame
(a true rectangle, NOT a trapezoid, NOT receding). Warm honey oak / walnut bamboo color (#D8A86A
tones) with soft top-left light giving each round stick a gentle highlight and real grain, a couple
of cotton tie-strings across it, subtle thickness. It is EMPTY — just the warm painterly mat. NOT a
flat tan rectangle, NOT a vector grid.
%s
%s""",
    },
    {
        "id": "seaweed_painterly",
        "name": "Build — seaweed sheet painterly (진녹-흑 textured)",
        "size": "1536x1024",
        "n_slots": 2,
        "body": """A painterly HERO illustration of a single sheet of dried seaweed (김) for gimbap,
lying flat seen from a high overhead angle: a wide flat rectangle of deep dark green-black MATTE
seaweed with a fine pebbled micro-texture and a subtle sheen along the top-left, the edges slightly
crisp/wavy like real toasted gim (NOT a plain solid black rectangle, NOT flat vector). Real surface
texture, soft volumetric edge. Edges parallel to the frame.
%s
%s""",
    },
    {
        "id": "rice_painterly",
        "name": "Build — rice layer painterly (낟알 texture, 흰 rectangle 아님)",
        "size": "1536x1024",
        "n_slots": 2,
        "body": """A painterly HERO illustration of an even bed of cooked white rice for gimbap, pressed
flat into a thin wide layer, seen from a high overhead angle: warm cream-white rice (#FAF4E6) made of
many plump readable individual GRAINS with a soft sticky sheen and gentle volume, spread evenly. It
must read clearly as RICE GRAINS (NOT a flat white rectangle, NOT a smooth white block, NOT vector).
Soft top-left highlight catching the moist grains, slightly uneven natural edge.
%s
%s""",
    },
    {
        "id": "filling_carrot_painterly",
        "name": "Build filling — carrot strip painterly (주황 채, volume)",
        "size": "1024x1024",
        "n_slots": 2,
        "body": """A painterly HERO illustration of a long bundle of julienned CARROT for gimbap filling:
slender matchstick strips of warm ORANGE carrot (#E8732C) bundled into a long horizontal strip, each
stick with soft volume, a moist highlight and real thickness (NOT a flat orange band, NOT a vector
line). Appetizing fresh carrot, warm orange, clearly carrot.
%s
%s""",
    },
    {
        "id": "filling_egg_painterly",
        "name": "Build filling — egg strip painterly (노랑 지단, volume)",
        "size": "1024x1024",
        "n_slots": 2,
        "body": """A painterly HERO illustration of a long strip of golden-yellow EGG omelette (지단) for
gimbap filling: a long horizontal band of soft golden-yellow pan-fried egg sliced into a thick strip,
with a tender soft surface, a gentle sheen, and real thickness / volume (NOT a flat yellow band, NOT
vector). Warm golden egg, clearly cooked egg omelette.
%s
%s""",
    },
    {
        "id": "filling_spinach_painterly",
        "name": "Build filling — spinach strip painterly (진녹 나물, volume)",
        "size": "1024x1024",
        "n_slots": 2,
        "body": """A painterly HERO illustration of a long bundle of seasoned SPINACH (시금치나물) for
gimbap filling: a long horizontal bundle of cooked dark-green wilted leafy spinach, soft glossy
leaves clustered with real volume and a moist seasoned sheen (NOT a green onion, NO white bulb, NO
long hollow stem, NOT a flat green band, NOT vector). Dark green wilted leafy greens, clearly cooked
spinach namul.
%s
%s""",
    },
    {
        "id": "filling_danmuji_painterly",
        "name": "Build filling — danmuji strip painterly (밝은 노랑 단무지, volume)",
        "size": "1024x1024",
        "n_slots": 2,
        "body": """A painterly HERO illustration of a long strip of yellow pickled radish DANMUJI (단무지)
for gimbap filling: a long horizontal rectangular strip of BRIGHT CLEAN YELLOW (#F5D547) pickled
radish with a slightly translucent glossy crisp surface and real thickness / volume (NOT orange, NOT
carrot — clearly distinct yellow; NOT a flat band, NOT vector). Bright clean yellow danmuji, crisp
and glossy.
%s
%s""",
    },
]


# ═════════════════════════════════════════════════════════════════════════════
# GROUP: carrot — Julienne 당근 state (계획서 §2.1/§5). whole 보유 OK 이나 일관 위해 포함.
#   당근 명확 — 소시지/rectangle/debris 금지. n2.
# ═════════════════════════════════════════════════════════════════════════════
CARROT = [
    {
        "id": "carrot_whole",
        "name": "Carrot — whole 당근 1개 (taper+꼭지, painterly)",
        "size": "1024x1024",
        "n_slots": 2,
        "body": """A painterly HERO illustration of ONE whole fresh CARROT seen from a high overhead
angle: a single tapering orange carrot (#E8732C) with a gently narrowing tip and a small fresh GREEN
leafy top, real rounded volume, a soft moist orange highlight along the top-left, subtle skin texture
(NOT a sausage, NOT a flat orange oval, NOT a rectangle, NOT vector). Clearly a fresh carrot.
%s
%s""",
    },
    {
        "id": "carrot_on_board",
        "name": "Carrot — 도마 위 당근 section (가로 눕힘, painterly)",
        "size": "1024x1024",
        "n_slots": 2,
        "body": """A painterly HERO illustration of a peeled CARROT section lying HORIZONTALLY ready to
be julienned, seen from a high overhead angle: a thick peeled orange carrot log (#E8732C) lying on
its side, the green top trimmed off, the cut end flat, real rounded volume and a moist highlight,
ready for slicing into matchsticks. STANDALONE carrot section only — NO cutting board baked in (the
board is composited later). Clearly carrot, NOT a sausage, NOT a rectangle.
%s
%s""",
    },
    {
        "id": "carrot_strips_good",
        "name": "Carrot — 긴 고른 채 (clean julienne, painterly)",
        "size": "1024x1024",
        "n_slots": 2,
        "body": """A painterly HERO illustration of a neat pile of CLEAN even julienned CARROT
matchsticks (얇고 균일한 당근 채): many thin uniform orange carrot strips (#E8732C) of the SAME thickness,
laid tidily and parallel into a gathered bundle, each stick slender with a moist highlight and real
volume, gleaming and appetizing — a clean professional julienne. NOT chunky, NOT uneven, NOT a flat
band, NOT vector. Clearly even carrot matchsticks (the GOOD result).
%s
%s""",
    },
    {
        "id": "carrot_strips_bad",
        "name": "Carrot — uneven 굵은 채 (bad julienne, painterly)",
        "size": "1024x1024",
        "n_slots": 2,
        "body": """A painterly HERO illustration of an UNEVEN messy pile of julienned CARROT (두께 제각각
chunky 당근 채): orange carrot strips (#E8732C) of WILDLY DIFFERENT thicknesses — some thin, some thick
chunky blocks — mixed and scattered into a tilted uneven heap, irregular and clumsy (still carrot,
just badly cut). Real volume and highlights, NOT a flat band, NOT vector. Clearly UNEVEN chunky carrot
(the BAD result).
%s
%s""",
    },
]


# ═════════════════════════════════════════════════════════════════════════════
# GROUP: slice — 통썰기 (계획서 §2.4/§7). roll_for_slice = volume cylinder, piece 단면 노출 OK
#   (Slice 단계 = 단면 appetizing / 쏟아짐 시각). landscape roll, square pieces. n2.
# ═════════════════════════════════════════════════════════════════════════════
SLICE = [
    {
        "id": "gimbap_roll_for_slice",
        "name": "Slice — 썰기 전 완성 roll (매끈한 검은 통 가로로 누움, seam 1줄, 단면 0)",
        "size": "1536x1024",
        "slot_mode": "closed",
        "body": """A painterly HERO illustration of ONE finished whole gimbap roll LYING HORIZONTALLY,
ready to be sliced — a SMOOTH GLOSSY DARK SEAWEED (NORI) CYLINDER, a sealed closed LOG, as a Korean
gimbap shop owner sets it on the board before cutting (썰기 전 완성 김밥 — 가로로 누운 매끈한 검은 김 통). A
firm clean ROUNDED horizontal cylinder of deep dark green-black seaweed with a sleek sesame-oil sheen,
long axis running LEFT-TO-RIGHT, a single faint SEAM along the length, real round VOLUME, and a soft
contact shadow cast straight down beneath it. The log is whole and UNCUT — the whole outer surface is
unbroken smooth nori, ONLY the outer skin and seam show; the round CUT END is NOT facing the camera and
NO spiral / rice ring is visible (it is about to be cut, not yet sliced — the cross-section appears only
once it is sliced into pieces). A premium appetizing sleek black-green roll, NOT a flat capsule, NOT
vector.
%s
%s
%s""",
    },
    {
        "id": "gimbap_piece_good",
        "name": "Slice — good 조각 단면 (rice+seaweed+컬러 속 appetizing)",
        "size": "1024x1024",
        "n_slots": 2,
        "body": """A painterly HERO illustration of ONE perfectly sliced GIMBAP PIECE shown end-on so the
beautiful spiral CROSS-SECTION faces the viewer (한 조각, 단면 보임): a clean round piece with an outer
ring of dark seaweed, a ring of plump warm cream-white rice, and a tidy cluster of colorful fillings
at the center — orange carrot, golden egg, dark-green spinach, bright yellow danmuji — all neatly held
together in a tight round disc, glossy and appetizing. Real volume, soft top-left light, a moist sheen,
contact shadow beneath. A clean uniform tight slice (the GOOD result), NOT collapsed, NOT vector.
%s
%s""",
    },
    {
        "id": "gimbap_piece_collapse",
        "name": "Slice — collapse 조각 (filling 쏟아진 broken, 시각)",
        "size": "1024x1024",
        "n_slots": 2,
        "body": """A painterly HERO illustration of ONE BADLY sliced gimbap piece COLLAPSING, its filling
SPILLING OUT (무너진 조각 — 속 쏟아짐): a loose uneven round piece whose seaweed-and-rice ring has come
apart, so the colorful fillings — orange carrot, golden egg, dark-green spinach, yellow danmuji — are
falling / slumping OUT of the cross-section, rice loosening, the disc lopsided and broken, uneven
thickness, a gaping seam. Clearly a messy collapsed slice with the insides tumbling out (the BAD
result, shown VISUALLY — not as text). Still real painterly food with volume and shadow, NOT vector.
%s
%s""",
    },
]


# ═════════════════════════════════════════════════════════════════════════════
# GROUP: plate — 담기 (계획서 §2.5/§8). real 나무 tray (box corner 금지). n2.
# ═════════════════════════════════════════════════════════════════════════════
PLATE = [
    {
        "id": "wooden_tray_topdown",
        "name": "Plate — real 나무 tray (box corner 아님, painterly 평면)",
        "size": "1536x1024",
        "n_slots": 2,
        "body": """A painterly HERO illustration of an EMPTY warm wooden Korean serving TRAY / lunchbox
seen from a high overhead angle: a real warm oak / walnut wooden tray with soft ROUNDED corners,
visible wood grain, a gentle raised rim, soft top-left light and a contact shadow beneath — a cozy
inviting wooden serving surface (NOT a flat rounded-rectangle box-corner panel, NOT a vector UI
placeholder, NOT a cold geometric box). It is EMPTY, ready for gimbap pieces to be arranged on it
later. Real wood texture and volume.
%s
%s""",
    },
]


# ═════════════════════════════════════════════════════════════════════════════
# GROUP: tool — procedural 교체용 painterly 도구 (계획서 §5). board / knife. n2.
# ═════════════════════════════════════════════════════════════════════════════
TOOL = [
    {
        "id": "board_topdown_painterly",
        "name": "Tool — cutting board painterly (procedural 교체, 결+shadow)",
        "size": "1536x1024",
        "n_slots": 2,
        "body": """A painterly HERO illustration of an EMPTY wooden CUTTING BOARD seen from a high
overhead angle: a warm oak / walnut chopping board, a flat rounded-corner wooden surface with rich
visible wood GRAIN, soft top-left light, a subtle bevel/thickness on the near edge, and a soft contact
shadow beneath. Cozy warm kitchen wood (NOT a flat tan rectangle, NOT a vector panel, NOT a
box-corner placeholder). Empty board, edges parallel to the frame, real wood texture and volume.
%s
%s""",
    },
    {
        "id": "knife_topdown_painterly",
        "name": "Tool — kitchen knife painterly (날 광택+나무 handle, procedural 교체)",
        "size": "1024x1024",
        "n_slots": 2,
        "body": """A painterly HERO illustration of ONE kitchen chef's KNIFE seen from a high overhead
angle, lying flat: a polished steel BLADE with a soft metallic sheen and a clean specular highlight
along the edge, joined to a warm wooden HANDLE with visible grain, a small bolster between them, soft
top-left light and a contact shadow beneath. A premium real kitchen knife (NOT a flat grey polygon,
NOT a vector clip-art knife, NOT a geometric shape). Real metal sheen and wood texture, blade and
handle clearly readable.
%s
%s""",
    },
]


GROUPS = {
    "roll": ROLL,
    "build": BUILD,
    "carrot": CARROT,
    "slice": SLICE,
    "plate": PLATE,
    "tool": TOOL,
}


# ─────────────────────────────────────────────────────────────────────────────
# job 수집 / 비용
# ─────────────────────────────────────────────────────────────────────────────
def collect_jobs(groups: set | None, only: set | None, do_all: bool):
    if do_all:
        selected_groups = list(GROUPS.keys())
    elif groups:
        selected_groups = [g for g in GROUPS if g in groups]
    else:
        selected_groups = []

    items: list[dict] = []
    seen: set[str] = set()
    for g in selected_groups:
        for it in GROUPS[g]:
            if it["id"] not in seen:
                items.append(it)
                seen.add(it["id"])

    # --only 는 group 무시하고 id 로 직접 선택 (전 그룹 검색)
    if only:
        items = []
        seen.clear()
        for g in GROUPS.values():
            for it in g:
                if it["id"] in only and it["id"] not in seen:
                    items.append(it)
                    seen.add(it["id"])

    return [(it["id"], it["name"], it) for it in items]


def unit_cost(size: str, quality: str) -> float:
    is_landscape = size in ("1536x1024", "1024x1536")
    land = {"low": 0.016, "medium": 0.063, "high": 0.25, "auto": 0.063}
    sq = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
    return (land if is_landscape else sq).get(quality, 0.063 if is_landscape else 0.042)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Gimbap HIGH-ANGLE PAINTERLY asset driver — 단면금지·standalone·baked X "
                    "(계획서 gimbap-visual-quality-rebuild-v1 §3-8)"
    )
    parser.add_argument("--group", type=str, default="",
                        help=f"콤마구분 group ({'/'.join(GROUPS)}). roll 먼저 권장.")
    parser.add_argument("--only", type=str, default="",
                        help="콤마구분 asset id만 (group 무시, 예: roll_first_fold)")
    parser.add_argument("--all", action="store_true", help="전 group 전부 (Roll 검수 후 권장)")
    parser.add_argument("--model", default="gpt-image-1", choices=["dall-e-3", "gpt-image-1"])
    parser.add_argument("--quality", default="medium", help="gpt-image-1: low/medium/high/auto")
    parser.add_argument("--background", default="opaque",
                        choices=["transparent", "opaque", "auto"],
                        help="transparent=알파 PNG(production) / opaque=Cream bg(검수)")
    parser.add_argument("--size-override", default="",
                        help="모든 asset 강제 size (기본은 asset별 size 사용)")
    parser.add_argument("--out-dir", type=Path,
                        default=PROJECT_ROOT / "assets-raw" / "gimbap_painterly_m2")
    args = parser.parse_args()

    groups = {x.strip() for x in args.group.split(",") if x.strip()} if args.group else None
    only = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    jobs = collect_jobs(groups, only, args.all)

    if not jobs:
        sys.exit("❌ 매칭 작업 없음 — --group roll 또는 --only <id> 또는 --all 지정. "
                 f"groups: {list(GROUPS)}")

    args.out_dir.mkdir(parents=True, exist_ok=True)

    est_total = 0.0
    for _id, _name, it in jobs:
        size = args.size_override or it.get("size", "1024x1024")
        est_total += unit_cost(size, args.quality)

    print("=" * 74)
    print("🍙 Gimbap HIGH-ANGLE PAINTERLY 생성 — 단면금지·standalone·baked X (계획서 §3-8)")
    print(f"   group={sorted(groups) if groups else '-'} only={sorted(only) if only else '-'} "
          f"all={args.all}")
    print(f"   모델={args.model} 품질={args.quality} 배경={args.background} "
          f"size={args.size_override or '(asset별)'}")
    print(f"   대상: {len(jobs)}장  비용예상: ${est_total:.2f}")
    print(f"   출력: {args.out_dir}")
    print("=" * 74)

    client = OpenAI(api_key=load_api_key())
    successes, failures = [], []
    t0 = time.time()

    for i, (item_id, name, item) in enumerate(jobs, 1):
        size = args.size_override or item.get("size", "1024x1024")
        fname = f"{item_id}.png"
        out_path = args.out_dir / fname
        prompt = build_prompt(item)

        print(f"\n[{i}/{len(jobs)}] {name} → {fname} ({size})")
        t_start = time.time()
        try:
            generate_image(
                client=client, prompt=prompt, output_path=out_path,
                model=args.model, size=size, quality=args.quality,
                background=args.background,
            )
            print(f"   ⏱️  {time.time() - t_start:.1f}s")
            successes.append(fname)
        except Exception as exc:
            print(f"   ❌ FAIL ({time.time() - t_start:.1f}s): {exc!r}")
            failures.append((fname, repr(exc)))

    print("\n" + "=" * 74)
    print(f"✅ 완료: {len(successes)}/{len(jobs)} — 총 {(time.time() - t0)/60:.1f}분")
    if failures:
        print(f"   실패 {len(failures)}장:")
        for fname, err in failures:
            print(f"     - {fname}: {err}")
    print(f"   비용 예상: ${est_total * len(successes) / max(len(jobs), 1):.2f}")
    print(f"   경로: {args.out_dir}")
    print("   → 검수: high-angle painterly(70-80°) + 단면금지(roll s1~s5) + NOT flat vector 확인")
    print("   → 검수 통과 후 res://art/sprites/ 배포 + godot-dev procedural→painterly swap")
    print("=" * 74)


if __name__ == "__main__":
    main()
