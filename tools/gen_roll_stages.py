"""
K-Food Master — Gimbap STAGED ROLL sprites (ROLLING PROCESS, NO cut cross-section, player-POV).

사용자 거부 (2026-06-10, 현 staged sprite 재생성 트리거):
  현 staged sprite(edge_lift/first_fold/cylinder_forming/compressed_loose/compressed_tight)가
  **spiral 단면(cut cross-section / end-cap)을 노출** → "이미 썰린/완성된 김밥"처럼 보인다 (말리는
  과정이 아님). + 완성 cylinder 조기노출 + side-roll(옆에서 본 통나무) 시점.
  거부 verbatim 요지: "showing finished gimbap at the start" / "side-view cylinder on a top-down mat".

핵심 교정 LOCK (2026-06-10):
  김밥 마는 **과정**을 단계별로. **단면(spiral end-cap) 절대 노출 금지** — 단면은 Slice 때만.
  - 모든 roll state = 김(dark seaweed)에 싸인 **log의 바깥면(OUTSIDE surface)**만 보임 (썰린 단면 X).
  - 완성 cylinder는 **finished_cylinder state에만** (중간 state는 말리는 중 — wave/log 바깥면).
  - **bottom→top player-POV**: 도마를 위에서 내려다보는 시점. near edge=화면 하단, 김밥이
    하단(near)에서 위(far)로 말림. cross-section은 "숨겨져 있음 — this is mid-rolling not sliced".

Player-POV (사용자 LOCK 유지, 단면 노출만 제거):
  화면 하단 = 플레이어/손, 상단 = far side. "내가 요리한다" 느낌. 도마를 똑바로 내려다보는
  **TOP-DOWN / high-angle plan view** (mat/roll = 수평 직사각, edge가 frame과 평행, near edge=하단,
  far edge=상단, bottom→top 말기). docs/design/player-pov-camera-v1.md §4 정합.
  **비스듬 금지**: oblique 3/4 product angle / diamond·rhombus·parallelogram / side-on cylinder
    절대 금지. 거부 핵심 = "side-view cylinder on a top-down mat".

성격: **standalone transparent, baked X** (Asset Architecture Lock NEVER-merge mandate).
  - 김발/도마/쟁반/그릇/손과 함께 굽지 않는다. 합성은 Godot runtime 책임.
  - Style Bible v1 톤: warm cozy, Cocoa #3A2A1E outline 3~4px, soft volumetric shading,
    top-left key light. cool sage/mint 금지, flat/UI-icon 금지.
  - 기존 roll asset(gimbap_roll_halfway / finished_content_only)과 한 세트로 보이게 톤 정합.

핵심 차이 (NO cross-section, 말리는 과정):
  이 driver의 모든 sprite는 **물리적으로 말리는 중인 sheet/log 의 바깥 김 표면**만 보여준다.
  단면(spiral cross-section / cut end / end-cap) 절대 금지. "이미 썰린 김밥" / "side-view 완성
  통나무" 금지. 각 단계 = curl 진행도가 명확히 다른 sprite (단순 scale 금지).

신규 staged set (player-POV, bottom→top curl, NO cross-section — 사용자 명시 6장):
  gimbap_roll_flat_setup        — state 1: 평평한 김+밥+가로 filling strip (말림 0). top-down 평면.
  gimbap_roll_edge_lift         — state 2: near(하단) edge 살짝 들림, filling 아직 다 보임.
  gimbap_roll_first_fold        — state 3: 하단 edge가 filling 위로 한 번 접힘, 하단에 둥근 bump.
                                            단면 금지 (접힌 김 바깥면만).
  gimbap_roll_half_roll         — state 4: 절반쯤 말린 wave/log (하단=둥근 log, 상단=평평 김 남음).
                                            단면 금지 — log 바깥(김 표면)만.
  gimbap_roll_compressed_loose  — state 5a: 거의 다 말린 loose log (상단 짧은 flap), 단면 금지.
  gimbap_roll_compressed_tight  — state 5c: 거의 다 말린 over-pressed log (납작/터짐), 단면 금지.
  gimbap_roll_finished_cylinder — state 6: 완성 둥근 log cylinder (김 바깥면, end-cap 금지). 통째.

  (state 5b perfect-compressed = 기존 gimbap_roll_finished_content_only 재사용 — 생성 X.
   neutral_cylinder 신규 finished_cylinder 와 5b 의 차이: 5b 는 단면 1조각 보임[slice preview],
   finished_cylinder 는 단면 0 — 순수 마는 과정 마지막. roll module 의 finished swap 용.)

출력:
  assets-raw/roll_assets_m2/{id}.png   → 검수 후 res://art/sprites/roll/{id}.png

Usage:
    py tools/gen_roll_stages.py --background transparent                       # 신규 staged 6장
    py tools/gen_roll_stages.py --only gimbap_roll_first_fold --background transparent
    py tools/gen_roll_stages.py --regen-mat --background transparent           # bamboo_mat_large 평면 재생성
    py tools/gen_roll_stages.py --regen-base --background transparent          # base 보강 (halfway pov)
    py tools/gen_roll_stages.py --all --background transparent                 # staged 6 + mat + base

Default:
    model=gpt-image-1 / quality=medium ($0.063/img @1536x1024) / size=1536x1024(landscape) /
    out=roll_assets_m2/ / background=opaque(검수) — production 은 transparent 권장
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
# NO_CROSS_SECTION — 모든 ROLLING staged sprite body 에 부착하는 단면-금지 강제 절.
# 거부 핵심 교정: gpt-image-1 이 "이미 썰린/완성된 김밥의 spiral 단면(end-cap)"을 그리지
# 않게 못박는다. 모든 말리는 state 는 김 바깥면(OUTSIDE seaweed surface)만. 단면은 Slice 때만.
# (flat_setup 은 단면 자체가 없으므로 부착 안 함.)
# ─────────────────────────────────────────────────────────────────────────────
NO_CROSS_SECTION = """
NO CUT CROSS-SECTION — ABSOLUTELY CRITICAL (this gimbap is being ROLLED, it is NOT sliced and NOT
finished): Show ONLY the OUTSIDE wrapped seaweed surface of the rolling log. The spiral
cross-section (the round end-cap that shows a ring of white rice around colorful fillings) MUST be
HIDDEN / not visible at all — this is mid-rolling, NOT a sliced or cut piece. Do NOT show a circular
spiral pinwheel end, do NOT show the cut face, do NOT show the rice-ring cross-section, do NOT show
a coiled spiral inside a ring. The log's ENDS are not the subject and are not facing the camera; we
look at the long OUTSIDE of the roll (the dark seaweed skin / the flat sheet and bed of rice while
it is still open). It must read as a sheet that is partway through being WRAPPED, never as a finished
gimbap log shown end-on, never as an already-cut slice.
ABSOLUTELY NOT: a spiral cross-section, a pinwheel cut end, a visible end-cap, a rice-ring around
fillings, a sliced round piece, a finished cut gimbap, a side-on log resting end-toward-camera."""


PHYSICAL_CURL = """
PHYSICAL ROLL — the seaweed-and-rice SHEET is genuinely WRAPPING into a log (NOT a flat stretched
image, NOT a finished cut log): The NEAR edge (the bottom edge of the frame, closest to the
viewer/player) lifts and bends UPWARD and OVER, wrapping toward the FAR (top) edge. You see the
real curved 3D body of the OUTSIDE of the roll — the rounded soft bend of the seaweed catching the
light along its OUTER skin, and where it is still open, the flat OPEN bed of rice and the row of
fillings still lying on top (seen from ABOVE, never from the end). The boundary between the rolled
part and the still-flat part is a soft rounded ridge that runs LEFT-TO-RIGHT across the frame.
ABSOLUTELY NOT: a flat sheet merely squashed or scaled, a flat stretched rectangle, a 2D image
just made narrower, a finished closed log shown end-on, a sliced piece, a taco with a visible
spiral. It MUST read as a sheet PHYSICALLY wrapping from the bottom (near) edge upward, OUTSIDE
surface only."""


PLAYER_POV = """
CAMERA — PLAYER POV, TOP-DOWN HIGH-ANGLE PLAN VIEW (CRITICAL — the player is the one cooking,
looking straight DOWN at their own work on the mat): A near-overhead TOP-DOWN view: the camera is
high above the work, looking almost straight DOWN at the bamboo mat / board lying FLAT on the table,
as if the seated player gazes down at the roll right in front of them (a very steep high angle,
roughly 70-80 degrees, close to a plan view). The roll lies as a HORIZONTAL form whose long axis
runs LEFT-TO-RIGHT across the frame, its long edges PARALLEL to the top and bottom of the frame.
The NEAR edge (closest to the player) is at the BOTTOM of the frame; the FAR edge is at the TOP. The
wrapping goes from the bottom (near) edge straight UP toward the top (far) edge. We look down onto
the TOP and the rolling OUTSIDE of the sheet — we do NOT look at the ROUND END of the log.
ABSOLUTELY NOT: a side-on elevation, a log lying end-toward the camera, an oblique 3/4 product
angle, a slanted / rotated / tilted layout, the mat or roll turned into a DIAMOND or RHOMBUS or
PARALLELOGRAM, a catalog/product three-quarter angle, a low hero angle, a view from across the
table looking at someone else cooking. The mat outline and the roll read STRAIGHT-ON, edges square
to the frame (horizontal and vertical), exactly as the cook sees it looking straight down."""


# ─────────────────────────────────────────────────────────────────────────────
# STYLE_SUFFIX — Style Bible v1 일관성 LOCK (gen_roll_assets.py / gen_roll_strips.py 동일 톤).
# standalone single hero, baked 금지. 기존 roll 세트와 한 톤으로 보이게. 끝 %s 1개 → 교체.
# ─────────────────────────────────────────────────────────────────────────────
STYLE_SUFFIX = """
STYLE (HERO ASSET — NOT a UI icon):
Premium cozy mobile game art in the style of Cooking Diary, Travel Town and Merge Mansion.
A single HERO illustrated object with real VOLUME, LIGHTING, TEXTURE and DEPTH — hand-drawn 2D
game illustration with soft volumetric shading: 2-3 step soft gradient (NEVER flat single-fill,
NEVER one solid color block). Rounded dimensional form, believable thickness, tactile surface
texture (the grain of the white rice, the matte pebbled sheen of the dark seaweed, the soft body
of each colorful filling).

CONSISTENCY LOCK — this MUST match the existing gimbap roll set (Style Bible v1):
- LIGHTING: a single warm KEY LIGHT from the TOP-LEFT (consistent direction), with a soft rim
  light and ONE or TWO small specular highlights (a gentle just-rolled sesame-oil sheen along the
  seaweed — NOT a glossy plastic coating). No second/opposite/flat lighting.
- OUTLINE: a warm dark COCOA outline (#3A2A1E) of consistent ~3-4px weight, with slight hand-drawn
  weight variation (warm, not a cold uniform vector stroke).
- SEAWEED: deep dark green-black (a very dark forest-green fading toward warm near-black, NOT pure
  flat black), MATTE with a subtle pebbled texture. RICE: warm cream-white (#FAF4E6), plump grains.
  FILLINGS: warm orange carrot, golden-yellow egg, fresh green vegetable (the same gimbap fillings
  as the existing set).
- PALETTE: warm cozy muted palette (mid saturation ~55-78%), appetizing and inviting — exactly the
  same warmth as the existing gimbap_roll_halfway and gimbap_roll_finished assets (one set).

COMPOSITION (STANDALONE — Asset Architecture Lock: never bake co-assets together):
- A SINGLE hero rolling gimbap centered, occupying ~62-74% of the frame.
- NO bamboo rolling mat under it, NO cutting board, NO plate, NO bowl, NO tray, NO dish, NO knife,
  NO chopsticks, NO hands, NO fingers, NO arms, NO characters, NO other props, NO kitchen scene,
  NO text, NO labels, NO arrows. This is JUST the rolling gimbap itself — the mat / board / hands /
  UI are composited later in Godot.
- A soft warm contact shadow directly beneath the roll (cocoa #3A2A1E at ~18-22% alpha) for
  grounded depth — soft, not a hard black ellipse.

BACKGROUND:
- Warm cream background (Rice Cream #FBF3E4), uniform and clean (or a fully transparent cutout when
  transparent background is requested).
- ABSOLUTELY NO cool sage, NO mint, NO teal, NO cold background (deprecated by Style Bible v1).

IMPORTANT — avoid (this must read as a premium hero illustration, NEVER a UI icon, NEVER fake):
flat vector, flat single-color fill, flat icon, vector clipart, sticker, emoji, pictogram, glyph,
color block, simple geometric shape, symbolic placeholder, silhouette, infographic, app icon,
simplified UI icon, MS paint, amateurish, single flat cel-shade with no volume, a flat sheet that
is merely scaled/squashed, a flat stretched image, a 2D rectangle pretending to roll, Cookie Run
frosting, Toca Boca, over-saturated neon, glossy plastic coating, mirror chrome, cool sage / mint
/ teal background, beige paper / kraft / scrapbook / vintage noise texture, golden hour
overexposed, photorealistic photo, 3D octane / unreal render, food photography, anime, manga,
watermark, any English or Korean text, Japanese sushi maki / nigiri leak, Japanese nori-with-raw
-fish, Chinese cuisine leak, the food sitting on a bamboo mat / board / plate / tray, any second
co-asset baked into the frame, any hands / fingers, any arrows or UI overlays,
a spiral cut cross-section, a pinwheel end-cap, a sliced round gimbap piece, a finished log shown
end-on, a side-view cylinder."""


# ─────────────────────────────────────────────────────────────────────────────
# STAGED ROLL SPRITES — 말리는 과정 단계 (player-POV top-down, bottom→top, NO cross-section).
#   flat_setup body 끝 %s 2개: PLAYER_POV → STYLE_SUFFIX (말림 0 → curl/단면 절 불필요).
#   rolling body 끝 %s 4개: NO_CROSS_SECTION → PHYSICAL_CURL → PLAYER_POV → STYLE_SUFFIX.
# ─────────────────────────────────────────────────────────────────────────────
STAGED_ROLLS = [
    {
        "id": "gimbap_roll_flat_setup",
        "name": "state 1 — 평평 setup (Flat Setup, 말림 0)",
        "n_slots": 2,  # PLAYER_POV, STYLE_SUFFIX (말림 0 — curl/단면 절 없음)
        "body": """A HERO illustration of a gimbap fully LAID OUT FLAT before any rolling has started
(아직 안 말린 평평 setup — 김 위에 밥, 그 위에 가로 속재료 한 줄). Seen from directly ABOVE looking
straight DOWN: a wide flat rectangle of dark seaweed lies flat, an even bed of plump white rice is
pressed flat on top of it, and a single neat HORIZONTAL ROW of colorful fillings (a stripe of orange
julienned carrot, a stripe of golden egg, a stripe of fresh green vegetable) runs LEFT-TO-RIGHT
across the rice. Everything is OPEN and FLAT — nothing is rolled, nothing is curled, no bend
anywhere, the whole sheet lies completely flat like a placemat seen from above. The long edges of
the sheet are parallel to the top and bottom of the frame.
%s
%s""",
    },
    {
        "id": "gimbap_roll_edge_lift",
        "name": "state 2 — 하단 edge 살짝 들림 (Edge Lift)",
        "n_slots": 4,
        "body": """A HERO illustration of a gimbap at the VERY START of rolling — the NEAR (bottom)
edge just beginning to lift (김밥 말기 시작, 하단 edge 살짝 들림). The wide flat sheet of seaweed with
its bed of white rice still lies mostly OPEN and flat, but the bottom edge closest to the viewer has
just curled UPWARD a little — a gentle upward bend of the near edge, the seaweed lip lifting off the
table so you can see it is starting to wrap. The colorful filling row (orange carrot, golden egg,
green vegetable) laid horizontally across the rice is STILL fully visible and not yet covered —
almost nothing is wrapped yet, this is the earliest curl. We look straight DOWN onto the flat open
top and the slightly raised near lip. Only a soft shadow under the lifted lip.
%s
%s
%s
%s""",
    },
    {
        "id": "gimbap_roll_first_fold",
        "name": "state 3 — 하단 edge가 filling 위로 한 번 접힘 (First Fold)",
        "n_slots": 4,
        "body": """A HERO illustration of a gimbap at the FIRST FOLD of rolling (김밥 첫 말기 — 하단
edge가 속재료 위로 한 번 접힘). The near (bottom) edge has now bent up and OVER, folding forward so the
FRONT part of the colorful filling row is now COVERED and tucked under the wrapping seaweed — a
rounded soft BUMP / ridge of dark seaweed has formed along the bottom (near) part of the frame,
running left-to-right, while the BACK portion (toward the top/far edge) is still OPEN and flat with
rice and the rest of the filling row still peeking out above the fold. The folded front is a smooth
ROUNDED ridge of seaweed skin (not a sharp flat crease, not laid flat) — only the OUTSIDE seaweed
surface of the fold shows, the inside spiral is hidden. We look straight DOWN from above.
%s
%s
%s
%s""",
    },
    {
        "id": "gimbap_roll_half_roll",
        "name": "state 4 — 절반쯤 말린 wave/log (Half Roll)",
        "n_slots": 4,
        "body": """A HERO illustration of a gimbap ABOUT HALF ROLLED (절반쯤 말린 김밥 — 하단부는 둥근
log, 상단부는 평평 김 남음). Seen straight from ABOVE: the bottom (near) HALF has wrapped up into a
rounded soft LOG of dark seaweed — a smooth bulging horizontal cylinder-body of seaweed skin running
left-to-right across the lower part of the frame — while the top (far) HALF is still an OPEN flat
flap of seaweed with a bed of white rice and the remaining filling still lying flat and visible,
about to be wrapped. A clear soft rounded ridge separates the rolled log from the still-flat flap.
Only the OUTSIDE seaweed skin of the rolled log shows — the round end / spiral inside is HIDDEN
(this is mid-rolling, not sliced). Real round volume on the log, soft top-left light along its top.
%s
%s
%s
%s""",
    },
    {
        "id": "gimbap_roll_compressed_loose",
        "name": "state 5a — 거의 다 말린 loose log (Compressed Loose, weak pressure)",
        "n_slots": 4,
        "body": """A HERO illustration of a gimbap ALMOST FULLY ROLLED but LOOSE, rolled with too little
pressure (거의 다 말린 김밥 — 약한 압력으로 느슨함). Seen straight from ABOVE: the sheet is wrapped nearly
all the way into a horizontal LOG (running left-to-right) with only a SHORT remaining flap of
seaweed-and-rice still unwrapped at the far (top) edge, about to seal. But the log is LOOSE and a bit
LUMPY / not tightly compressed — the seaweed wraps a little slackly, the body looks slightly slumped
and uneven with soft gaps along the wrap, clearly under-pressed and a little floppy. Only the OUTSIDE
seaweed skin shows — the round end / spiral cross-section is HIDDEN (this is mid-rolling, not
sliced). A soft loose rounded log, clearly NOT a clean tight roll, but also NOT torn.
%s
%s
%s
%s""",
    },
    {
        "id": "gimbap_roll_compressed_tight",
        "name": "state 5c — 거의 다 말린 over-pressed log (Compressed Tight, too much pressure)",
        "n_slots": 4,
        "body": """A HERO illustration of a gimbap rolled with TOO MUCH pressure (너무 세게 눌러 말린
김밥 — 강한 압력으로 납작/터짐). Seen straight from ABOVE: the sheet is wrapped nearly all the way into a
horizontal LOG (running left-to-right) with a short remaining flap at the far (top) edge, but it has
been CRUSHED too hard — the dark seaweed has SPLIT and CRACKED along the top of the wrap and white
rice is being SQUEEZED OUT / bulging through the split, and the log is FLATTENED / deformed (pressed
wider and lower, not a clean round tube). It clearly looks over-compressed and burst — messy,
blown-out. Only the OUTSIDE seaweed skin and the split bulging rice show along the length of the log
— the round END / spiral cross-section is HIDDEN (this is over-pressed mid-rolling, NOT a sliced
piece). Still a gimbap (rice + seaweed + colorful fillings), just over-pressured and ruptured.
%s
%s
%s
%s""",
    },
    {
        "id": "gimbap_roll_finished_cylinder",
        "name": "state 6 — 완성 둥근 log cylinder (Finished Cylinder, NO cut end)",
        "n_slots": 4,
        "body": """A HERO illustration of ONE FINISHED tightly-rolled gimbap log, fully wrapped and
sealed, whole and UNCUT (완성된 김밥 한 줄 통째 — 안 썰린 통김밥). Seen straight from ABOVE looking down:
a firm clean ROUNDED horizontal LOG of gimbap wrapped smoothly in dark green-black matte seaweed,
its long axis running LEFT-TO-RIGHT across the frame, the seam where the sheet laps closed running
neatly along the length. A gentle sesame-oil sheen runs along the top of the seaweed skin. The log
is whole and uncut. ONLY the smooth OUTSIDE seaweed skin of the wrapped log shows along its whole
length — the ROUND END / spiral cross-section is HIDDEN and NOT facing the camera (this is a whole
uncut roll, NOT a sliced piece, NOT shown end-on). A clean tight perfect roll (the GOOD result).
%s
%s
%s
%s""",
    },
]


# ─────────────────────────────────────────────────────────────────────────────
# MAT 재생성 — bamboo_mat_large 가 oblique 3/4 receding trapezoid(비스듬) 라서 top-down 평면 직사각
# 으로 재생성. --regen-mat 로만 활성. 동일 id 덮어쓰기 → res://art/sprites/roll/bamboo_mat_large.png.
# 단면/curl 절 불필요 (음식 아님). PLAYER_POV(top-down) + STYLE_SUFFIX 2 slot.
# ─────────────────────────────────────────────────────────────────────────────
MAT_REGEN = [
    {
        "id": "bamboo_mat_large",
        "name": "bamboo mat — top-down 평면 직사각 재생성 (flat plan-view, 덮어쓰기)",
        "n_slots": 2,
        "body": """A HERO illustration of a Korean gimbap bamboo rolling mat (김발) lying COMPLETELY FLAT
on a table, seen from straight ABOVE (top-down plan view). It is a WIDE FLAT RECTANGLE of thin round
bamboo sticks tied side by side, the bamboo sticks running HORIZONTALLY (left-to-right), so the mat
reads as a clean flat horizontal rectangle whose four edges are PARALLEL to the frame edges (a true
rectangle, NOT a trapezoid, NOT receding into depth, NOT a diamond). Warm honey-bamboo color
(#D8A86A / market wood tones) with soft top-left light giving each round stick a gentle highlight, a
couple of cotton tie-strings across it, very subtle thickness. It is empty — JUST the flat mat. We
look straight DOWN onto its flat top face.
ABSOLUTELY NOT: an oblique 3/4 product angle, a receding trapezoid that narrows toward the top, a
tilted / slanted / perspective view, a diamond or rhombus, a low hero angle, a side-on edge view,
any food / rice / seaweed on it. The mat must be a flat top-down rectangle, edges square to the
frame.
%s
%s""",
    },
]


# ─────────────────────────────────────────────────────────────────────────────
# BASE 보강 — 기존 halfway 가 side-roll(좌→우) 이면 player-POV(bottom→top, NO cross-section)로 재생성.
# --regen-base 로만 활성. 신규 id(_pov) 안전 생성. (finished 단면 정면은 더 이상 재생성 안 함 —
# finished_cylinder 가 단면 0 마는-과정 마지막을 담당.)
# ─────────────────────────────────────────────────────────────────────────────
BASE_REGEN = [
    {
        "id": "gimbap_roll_halfway_pov",
        "name": "halfway — player-POV bottom→top, NO cross-section 재생성",
        "n_slots": 4,
        "body": """A HERO illustration of a HALF-ROLLED Korean gimbap caught mid-roll, in player POV
(반쯤 말린 김밥, 플레이어 시점). Seen straight from ABOVE: the near (bottom) half has already wrapped up
into a rounded soft LOG of dark seaweed running left-to-right, while the FAR (top) half is still an
OPEN flat flap of seaweed with a bed of white rice and the colorful filling row (orange carrot,
golden egg, green vegetable) still visible and flat, not yet wrapped — clearly a roll IN PROGRESS,
rolled from the bottom edge upward. Only the OUTSIDE seaweed skin of the rolled log shows — the round
end / spiral cross-section is HIDDEN (mid-rolling, not sliced).
%s
%s
%s
%s""",
    },
]


def build_prompt(item: dict) -> str:
    """body의 %s 슬롯을 채운다.
    n_slots==2: PLAYER_POV → STYLE_SUFFIX (말림 0 / 음식 아님 — 단면·curl 절 불필요).
    n_slots==4: NO_CROSS_SECTION → PHYSICAL_CURL → PLAYER_POV → STYLE_SUFFIX (말리는 state).
    """
    body = item["body"]
    n = item.get("n_slots", 4)
    if n == 2:
        body = body.replace("%s", PLAYER_POV, 1)
        body = body.replace("%s", STYLE_SUFFIX, 1)
    else:
        body = body.replace("%s", NO_CROSS_SECTION, 1)
        body = body.replace("%s", PHYSICAL_CURL, 1)
        body = body.replace("%s", PLAYER_POV, 1)
        body = body.replace("%s", STYLE_SUFFIX, 1)
    return body


def collect_jobs(only: set | None, regen_mat: bool, regen_base: bool, do_all: bool):
    items = list(STAGED_ROLLS)
    if regen_mat or do_all:
        items = items + list(MAT_REGEN)
    if regen_base or do_all:
        items = items + list(BASE_REGEN)
    jobs = []
    for a in items:
        if only and a["id"] not in only:
            continue
        jobs.append((a["id"], a["name"], a))
    return jobs


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Gimbap STAGED ROLL sprites — 말리는 과정, NO cross-section, player-POV top-down "
                    "(standalone, baked X)"
    )
    parser.add_argument("--only", type=str, default="",
                        help="콤마구분 asset id만 (예: gimbap_roll_first_fold,gimbap_roll_half_roll)")
    parser.add_argument("--regen-mat", action="store_true",
                        help="bamboo_mat_large 를 top-down 평면 직사각으로 재생성 (덮어쓰기)")
    parser.add_argument("--regen-base", action="store_true",
                        help="기존 halfway 를 player-POV NO-cross-section 으로 재생성 (halfway_pov)")
    parser.add_argument("--all", action="store_true",
                        help="staged 6장 + mat 1장 + base 1장 전부")
    parser.add_argument("--model", default="gpt-image-1", choices=["dall-e-3", "gpt-image-1"])
    parser.add_argument("--size", default="1536x1024",
                        help="landscape 권장 (roll = 가로 우세 log). gpt-image-1: 1536x1024")
    parser.add_argument("--quality", default="medium", help="gpt-image-1: low/medium/high/auto")
    parser.add_argument("--background", default="opaque",
                        choices=["transparent", "opaque", "auto"],
                        help="transparent=알파 PNG(production) / opaque=Cream bg(검수)")
    parser.add_argument("--out-dir", type=Path,
                        default=PROJECT_ROOT / "assets-raw" / "roll_assets_m2")
    args = parser.parse_args()

    only = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    jobs = collect_jobs(only, args.regen_mat, args.regen_base, args.all)

    if not jobs:
        sys.exit("❌ 매칭 작업 없음 (--only / --regen-mat / --regen-base / --all 확인)")

    args.out_dir.mkdir(parents=True, exist_ok=True)

    # 비용: gpt-image-1 1536x1024 medium ≈ $0.063/img (1024² medium $0.042 대비 가로 비례).
    is_landscape = args.size in ("1536x1024", "1024x1536")
    unit_map = {"low": 0.016, "medium": 0.063, "high": 0.25, "auto": 0.063}
    unit_sq = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
    if args.model == "dall-e-3":
        unit = 0.080 if args.quality == "hd" else 0.040
    else:
        unit = (unit_map if is_landscape else unit_sq).get(args.quality, 0.063 if is_landscape else 0.042)
    est_total = unit * len(jobs)

    print("=" * 72)
    print("🍙 Gimbap STAGED ROLL 생성 — 말리는 과정, NO cross-section, player-POV (Style Bible v1)")
    print(f"   only={sorted(only) if only else '-'} regen_mat={args.regen_mat} "
          f"regen_base={args.regen_base} all={args.all}")
    print(f"   모델={args.model} 품질={args.quality} 사이즈={args.size}(landscape) 배경={args.background}")
    print(f"   대상: {len(jobs)}장  비용예상: ${unit:.3f}/장 × {len(jobs)} = ${est_total:.2f}")
    print(f"   출력: {args.out_dir}")
    print("=" * 72)

    client = OpenAI(api_key=load_api_key())
    successes, failures = [], []
    t0 = time.time()

    for i, (item_id, name, item) in enumerate(jobs, 1):
        fname = f"{item_id}.png"
        out_path = args.out_dir / fname
        prompt = build_prompt(item)

        print(f"\n[{i}/{len(jobs)}] {name} → {fname}")
        t_start = time.time()
        try:
            generate_image(
                client=client, prompt=prompt, output_path=out_path,
                model=args.model, size=args.size, quality=args.quality,
                background=args.background,
            )
            print(f"   ⏱️  {time.time() - t_start:.1f}s")
            successes.append(fname)
        except Exception as exc:
            print(f"   ❌ FAIL ({time.time() - t_start:.1f}s): {exc!r}")
            failures.append((fname, repr(exc)))

    print("\n" + "=" * 72)
    print(f"✅ 완료: {len(successes)}/{len(jobs)} — 총 {(time.time() - t0)/60:.1f}분")
    if failures:
        print(f"   실패 {len(failures)}장:")
        for fname, err in failures:
            print(f"     - {fname}: {err}")
    print(f"   비용 예상: ${unit * len(successes):.2f}")
    print(f"   경로: {args.out_dir}")
    print("   → 검수(단면 노출 0 확인) 후 res://art/sprites/roll/ 배포")
    print("   → godot-dev: ArtRegistry ROLL_KEYS 갱신 + roll_module staged swap 매핑")
    print("=" * 72)


if __name__ == "__main__":
    main()
