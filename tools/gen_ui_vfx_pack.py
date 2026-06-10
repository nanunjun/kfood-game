"""
K-Food Master — Art Production Sprint 1 / Priority 3 (UI Theme) + Priority 4 (VFX).

Style Bible v1 §6/§7 (warm matte premium UI, radius 24/28, Cocoa shadow, gold-brass
절제) + §8 (subtle VFX — NO screen explosion / shake). This driver generates the
PRODUCTION reskin asset SHEETS; many are flat-on-transparent (rembg-ready) so the
godot-dev can slice/9-slice them.

PRIORITY 3 — UI THEME PACK
  ui_card_frame    — 음식/guest card frame (radius 28, Cocoa outline 3px, soft shadow)
  ui_panel_frame   — 대사/패널 frame (radius 24, BG Cream, soft shadow, 말풍선 tail variant)
  ui_button_family — primary (Persimmon) + secondary (Gold/Warm White) + disabled
  ui_ribbon_family — premium gold-brass ribbon/banner (RECORD/★ — gold절제 frame)
  ui_icon_family   — coin / heart / star / friendship / lock / settings (warm flat icons)

  9-SLICE NOTE (captured in docs): the FRAMES (card / panel / button) should be
  authored as 9-slice / NinePatch friendly — round corners + a plain stretchable
  center. RECOMMENDATION = these frames are BETTER DONE PROCEDURALLY in Godot
  (StyleBoxFlat: corner_radius 24/28, bg_color warm fill, border Cocoa 3px,
  shadow_color Cocoa @18-25% + shadow_size) — perfectly crisp at any size, recolorable,
  zero texture memory, no AI-resize artifacts. The AI sheet generated here is the
  VISUAL SPEC / fallback texture; for shipping, prefer the StyleBoxFlat values. The
  ICON family and RIBBON (organic shapes, gold-brass sheen) ARE worth generating as
  art (hard to do procedurally). See docs/art/asset-production-sprint1.md §P3.

PRIORITY 4 — VFX PACK (subtle only, Style Bible §8)
  vfx_steam        — soft white curved wisp 2-3 가닥 (뚝배기 끓음 signal), semi-transparent
  vfx_sparkle      — 4-point gold sparkle cluster (excellent/RECORD only), small
  vfx_oil_splash   — small warm oil droplet arc (조리 cue), subtle
  vfx_cooking_glow  — soft warm radial glow (갓 조리 윤기), low opacity
  vfx_friendship_gain— soft warm heart/friendship pop (서빙 happy), gentle

  All VFX = transparent PNG sprite (or simple horizontal sprite-strip frames), SUBTLE
  warm tone, NO screen explosion, NO multi-color confetti, NO camera shake.

Usage:
    py tools/gen_ui_vfx_pack.py --group ui                    # UI 5 sheets
    py tools/gen_ui_vfx_pack.py --group vfx                   # VFX 5 sprites
    py tools/gen_ui_vfx_pack.py --group all                   # 10 전체
    py tools/gen_ui_vfx_pack.py --only ui_icon_family         # 1개만 (test)
    py tools/gen_ui_vfx_pack.py --only vfx_steam --quality high

Default:
    model    = gpt-image-1
    quality  = medium ($0.042/img × 10 = ~$0.42 total)
    size     = 1024x1024 (square sheet)
    background= transparent (icons/VFX/frames on alpha — rembg/9-slice ready)
    out_dir  = assets-raw/ui_vfx_pack_m2/
    version  = v1
    파일명   = {asset_id}_{version}.png
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
# STYLE_SUFFIX_UI / STYLE_SUFFIX_VFX — Style Bible v1 §7 (warm matte premium UI) /
# §8 (subtle VFX). transparent bg (rembg/9-slice ready) + Cocoa outline + warm palette.
# ─────────────────────────────────────────────────────────────────────────────
STYLE_SUFFIX_UI = """Format: square 1:1 sheet on a FULLY TRANSPARENT background (the
UI elements float on alpha, ready for slicing / 9-slice / recolor — NO solid
background fill, NO scene).

Style: warm cozy premium-casual mobile game UI, Cooking Diary tidy chrome + Animal
Restaurant cozy warmth. Clean 2D, MATTE fill (NOT glossy plastic), soft and rounded.

UI RULES (Style Bible v1 §7):
- Rounded corners everywhere (cozy = round, NO sharp right angles). Buttons radius
  ~24px, cards radius ~28px, chips fully pill (radius = height/2), small icons ~12px.
- MATTE warm fill (NOT glossy, NOT Royal Match glassy plastic). Only the premium
  ribbon/frame may carry a subtle gentle gold-brass sheen — used sparingly.
- Soft warm DROP SHADOW: Cocoa #3A2A1E at ~18-25% alpha, offset down, soft blur
  (NOT a pure-black hard shadow).
- Outline (where used): Cocoa #3A2A1E ~3px on cards/buttons (warm dark, NOT pure
  black). Not too thick.

PALETTE (Style Bible §2): Persimmon #E8732C primary CTA, Sesame Gold #F2B33D +
Brass #B98A3E premium accents, BG Cream #FBF3E4 / Steamed #FFFCF6 surfaces, Cocoa
#3A2A1E outline/shadow. Mid-saturation 55-78% warm (NOT Royal Match 80-90% punch).

Important: avoid solid background fill (keep it TRANSPARENT), glossy plastic, glassy
specular UI, Royal Match style, cool mint UI, teal, neon, sharp right-angle corners,
pure black shadow, hyper-casual flat (keep soft warm depth), scrapbook noise,
photorealistic, 3D render, gradient mesh, gold frame overload (gold-brass is
restrained, premium-only),
any English or Korean text legibly readable (icons are pictograms only; all text
labels are added later as Godot UI overlay — NO baked-in letters/words)."""

STYLE_SUFFIX_VFX = """Format: square 1:1 on a FULLY TRANSPARENT background (the VFX
floats on alpha, ready as a game sprite — NO solid background, NO scene, NO object
underneath; just the effect itself).

Style: warm cozy premium-casual mobile game VFX, SUBTLE (Style Bible v1 §8 — Cooking
Diary "tasty steam / gentle sparkle" level, explicitly NOT Royal Match screen
explosion). Clean 2D, soft, semi-transparent where appropriate.

VFX RULES (Style Bible §8):
- SUBTLE and restrained — a small, tasteful effect, NOT a full-screen burst, NOT a
  confetti storm, NOT camera shake, NOT neon glow.
- Warm tone only: soft white / cream for steam, Sesame Gold #F2B33D for sparkle,
  Persimmon #E8732C for warm glow. NO cool-tone VFX, NO multi-color rainbow confetti.
- Semi-transparent soft edges (steam/glow 40-60% alpha, fading out). Sparkles are
  simple flat 4-point gold stars (NO detailed anime ray bursts).
- Single clean effect centered, sized to read as one game sprite (or a simple
  left-to-right sprite strip of 3-4 frames if motion is described).

Important: avoid solid background fill (keep it TRANSPARENT), screen explosion, big
particle burst, confetti storm, multi-color VFX, camera shake implication, neon glow,
cool-tone effect, lens flare, Royal Match style, glossy 3D particles, photorealistic,
octane render, detailed anime ray bursts,
any English or Korean text, any object/dish/character underneath the effect (the VFX
is isolated on transparency)."""


# ─────────────────────────────────────────────────────────────────────────────
# UI assets (Priority 3) — id / group / body. STYLE_SUFFIX_UI auto-append (%s).
# ─────────────────────────────────────────────────────────────────────────────
UI_ASSETS = [
    {
        "id": "ui_card_frame",
        "group": "ui",
        "body": """A warm cozy mobile game UI CARD FRAME asset (for food cards and guest
cards), on a transparent background. Draw a single ROUNDED RECTANGLE CARD with corner
radius about 28px: a warm Steamed #FFFCF6 / BG Cream #FBF3E4 matte fill, a Cocoa #3A2A1E
outline about 3px, and a soft warm Cocoa drop shadow (#3A2A1E ~20% alpha, offset down,
soft). The inner area is EMPTY (ready to hold a food image + label later). Author it
9-SLICE FRIENDLY: the four rounded corners are crisp and the straight edges + center
are uniform so it can stretch. Provide the card large and centered. NO content inside,
NO text. %s""",
    },
    {
        "id": "ui_panel_frame",
        "group": "ui",
        "body": """A warm cozy mobile game UI PANEL FRAME asset (for dialogue panels and
info panels), on a transparent background. Draw a single ROUNDED RECTANGLE PANEL with
corner radius about 24px: a warm BG Cream #FBF3E4 matte fill, a subtle Cocoa #3A2A1E
soft drop shadow (~18% alpha), optional thin Cocoa outline. Include, beside the main
panel, a SECOND small variant: the same panel with a single small SPEECH-BUBBLE TAIL
(a small rounded triangle pointer) at the lower-left — for character dialogue. Author
9-SLICE FRIENDLY (crisp rounded corners + uniform stretchable edges/center). Inner area
EMPTY, NO text. %s""",
    },
    {
        "id": "ui_button_family",
        "group": "ui",
        "body": """A warm cozy mobile game UI BUTTON FAMILY asset sheet, on a transparent
background, arranged as a neat vertical or grid set of rounded-rectangle buttons (corner
radius ~24px each, all EMPTY of text). Include 3 button states/types: (1) PRIMARY CTA —
solid Persimmon #E8732C matte fill with a subtle 4px darker bottom bevel and a soft warm
Cocoa drop shadow (this is the main "Cook" button look). (2) SECONDARY — Sesame Gold
#F2B33D or BG Warm White #FFFCF6 fill with a Cocoa #3A2A1E ~3px outline, same radius and
shadow. (3) DISABLED — a muted Warm Gray #8C8074 flat version, lower contrast. Matte
(NOT glossy). Author 9-SLICE FRIENDLY. NO text on any button. %s""",
    },
    {
        "id": "ui_ribbon_family",
        "group": "ui",
        "body": """A warm cozy mobile game UI RIBBON / BANNER FAMILY asset sheet, on a
transparent background — the PREMIUM celebration frames (for NEW RECORD / ★ rating /
prestige). Draw a small set of 2-3 banner shapes: (1) a horizontal RIBBON BANNER with
folded ends, (2) a small pennant/award ribbon with a rosette, (3) a star-topped header
band. Fill with Sesame Gold #F2B33D + Brass #B98A3E two-tone (this is the ONE place a
SUBTLE gentle gold-brass sheen is allowed — a restrained premium highlight, NOT a glossy
gold explosion), Cocoa #3A2A1E outline, soft warm shadow. These are the special-occasion
frames (use sparingly in-game). Inner area EMPTY, NO text. %s""",
    },
    {
        "id": "ui_icon_family",
        "group": "ui",
        "body": """A warm cozy mobile game UI ICON FAMILY sheet, on a transparent
background, arranged as a clean grid of 6 simple flat pictogram icons (rounded, friendly,
each filled with a single warm color + Cocoa #3A2A1E ~2-3px outline + tiny soft shadow):
(1) COIN — a warm Sesame Gold #F2B33D / Brass round coin. (2) HEART — a soft warm
Persimmon/coral heart (life/health). (3) STAR — a Sesame Gold 5-point star (rating).
(4) FRIENDSHIP — two small warm hearts or a clasped-hands/people pair pictogram (warm
coral). (5) LOCK — a small rounded padlock (Warm Gray #8C8074 + Cocoa outline). (6)
SETTINGS — a rounded gear (Warm Gray + Cocoa outline). Consistent matte warm style,
consistent outline weight, consistent rounded friendly shapes. NO text, NO labels. %s""",
    },
]


# ─────────────────────────────────────────────────────────────────────────────
# VFX assets (Priority 4) — id / group / body. STYLE_SUFFIX_VFX auto-append (%s).
# ─────────────────────────────────────────────────────────────────────────────
VFX_ASSETS = [
    {
        "id": "vfx_steam",
        "group": "vfx",
        "body": """A warm cozy mobile game STEAM VFX sprite, on a transparent background.
Draw 2-3 soft white-to-cream curved STEAM WISPS rising upward and gently fading out
(semi-transparent, ~40-60% alpha at the base fading toward 0 at the top), the classic
"뚝배기 is bubbling / hot food" signal. Soft rounded curved ribbon shapes, NOT sharp, NOT
a big cloud. SUBTLE — just a tasteful rising steam. Optionally provide as a small 3-frame
left-to-right sprite strip showing the wisps rising. NO bowl/pot underneath, just the
steam isolated on transparency. %s""",
    },
    {
        "id": "vfx_sparkle",
        "group": "vfx",
        "body": """A warm cozy mobile game SPARKLE VFX sprite, on a transparent background.
Draw a small cluster of 3-4 flat 4-POINT SPARKLE STARS in Sesame Gold #F2B33D (varied
sizes, simple clean flat geometric stars — NOT detailed anime ray bursts, NOT a confetti
storm), the "excellent reaction / NEW RECORD" accent. SUBTLE and restrained (Style Bible
§8) — a small tasteful sparkle accent, NOT a full-screen burst. Optionally a 3-frame
pop-in sprite strip (small → full → fade). NO object underneath, just sparkles on
transparency. %s""",
    },
    {
        "id": "vfx_oil_splash",
        "group": "vfx",
        "body": """A warm cozy mobile game OIL SPLASH VFX sprite, on a transparent
background. Draw a small, gentle arc of 4-6 warm golden OIL DROPLETS (soft rounded
droplet shapes, warm Sesame Gold / amber tone with a tiny soft highlight, semi-
transparent), the subtle "sizzling / frying" cooking cue. SUBTLE — a small tasteful
droplet arc, NOT a violent splatter, NOT a big splash. Optionally a 3-frame sprite
strip. NO pan/food underneath, just the droplets on transparency. %s""",
    },
    {
        "id": "vfx_cooking_glow",
        "group": "vfx",
        "body": """A warm cozy mobile game COOKING GLOW VFX sprite, on a transparent
background. Draw a single soft warm RADIAL GLOW — a gentle Persimmon #E8732C to Sesame
Gold #F2B33D warm halo, brightest in the center fading smoothly to transparent at the
edges (low opacity, ~30-50% at center), the "freshly cooked / appetizing warmth" glow
placed behind a finished dish. SUBTLE and soft (Style Bible §8) — a gentle warm halo,
NOT a neon glow, NOT a lens flare, NOT a bright burst. Just the soft glow isolated on
transparency. %s""",
    },
    {
        "id": "vfx_friendship_gain",
        "group": "vfx",
        "body": """A warm cozy mobile game FRIENDSHIP GAIN VFX sprite, on a transparent
background. Draw a small gentle pop of 2-3 soft warm HEARTS (warm Persimmon/coral, soft
rounded heart shapes with a tiny highlight, semi-transparent, floating upward) — the
"friendship increased / guest is happy after serving" reward feedback. SUBTLE and sweet
(Style Bible §8) — a small tasteful heart pop, NOT a heart explosion, NOT a confetti
storm. Optionally a soft warm aroma curve line connecting up to the hearts (a gentle
curved line, NOT a dotted path). Optionally a 3-frame float-up sprite strip. NO
character/food underneath, just the hearts on transparency. %s""",
    },
]


def build_prompt(asset: dict) -> str:
    suffix = STYLE_SUFFIX_UI if asset["group"] == "ui" else STYLE_SUFFIX_VFX
    return asset["body"].replace("%s", suffix, 1)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Priority 3 UI Theme + Priority 4 VFX pack — 5 UI sheets + 5 VFX "
        "sprites (Style Bible v1 §7 warm matte premium UI + §8 subtle VFX, transparent)"
    )
    parser.add_argument(
        "--group", type=str, default="all", choices=["ui", "vfx", "all"],
        help="ui = 5 UI sheets / vfx = 5 VFX sprites / all = 10 전체",
    )
    parser.add_argument(
        "--only", type=str, default="",
        help="콤마구분 asset ID만 (예: ui_icon_family,vfx_steam). 빈 값 = group 전체.",
    )
    parser.add_argument("--model", default="gpt-image-1", choices=["dall-e-3", "gpt-image-1"])
    parser.add_argument("--size", default="1024x1024")
    parser.add_argument("--quality", default="medium")
    parser.add_argument(
        "--background", default="transparent",
        choices=["transparent", "opaque", "auto"],
        help="UI/VFX는 transparent 권장 (9-slice/rembg ready).",
    )
    parser.add_argument(
        "--out-dir", type=Path,
        default=PROJECT_ROOT / "assets-raw" / "ui_vfx_pack_m2",
        help="출력 디렉터리",
    )
    parser.add_argument("--version", type=str, default="v1")
    args = parser.parse_args()

    pool = UI_ASSETS + VFX_ASSETS
    if args.only:
        only_set = {x.strip() for x in args.only.split(",") if x.strip()}
        selected = [a for a in pool if a["id"] in only_set]
    elif args.group == "ui":
        selected = UI_ASSETS
    elif args.group == "vfx":
        selected = VFX_ASSETS
    else:
        selected = pool

    if not selected:
        sys.exit(f"selection mismatch. Valid IDs: {[a['id'] for a in pool]}")

    args.out_dir.mkdir(parents=True, exist_ok=True)

    if args.model == "dall-e-3":
        unit = 0.080 if args.quality == "hd" else 0.040
    else:
        unit_map = {"low": 0.011, "medium": 0.042, "high": 0.167, "auto": 0.042}
        unit = unit_map.get(args.quality, 0.042)
    est_total = unit * len(selected)

    print("=" * 70)
    print("Priority 3 UI + Priority 4 VFX pack (gpt-image-1, Style Bible v1 warm)")
    print(f"   model: {args.model} / quality: {args.quality} / bg: {args.background}")
    print(f"   targets: {len(selected)} ({[a['id'] for a in selected]})")
    print(f"   est cost: ${unit:.3f} x {len(selected)} = ${est_total:.2f}")
    print(f"   output: {args.out_dir}")
    print("=" * 70)

    api_key = load_api_key()
    client = OpenAI(api_key=api_key)

    successes: list[str] = []
    failures: list[tuple[str, str]] = []
    t0 = time.time()

    for i, asset in enumerate(selected, 1):
        aid = asset["id"]
        out_path = args.out_dir / f"{aid}_{args.version}.png"
        prompt = build_prompt(asset)

        print(f"\n[{i}/{len(selected)}] {aid} -> {out_path.name}")
        t_start = time.time()
        try:
            generate_image(
                client=client,
                prompt=prompt,
                output_path=out_path,
                model=args.model,
                size=args.size,
                quality=args.quality,
                background=args.background,
            )
            print(f"   elapsed {time.time() - t_start:.1f}s")
            successes.append(aid)
        except Exception as exc:
            print(f"   FAIL ({time.time() - t_start:.1f}s): {exc!r}")
            failures.append((aid, repr(exc)))

    total_elapsed = time.time() - t0
    print("\n" + "=" * 70)
    print(f"DONE: {len(successes)}/{len(selected)} imgs -- total {total_elapsed / 60:.1f} min")
    if successes:
        print(f"   success: {', '.join(successes)}")
    if failures:
        print(f"   fail {len(failures)}:")
        for aid, err in failures:
            print(f"     - {aid}: {err}")
    print(f"   est cost: ${unit * len(successes):.2f}")
    print(f"   output path: {args.out_dir}")
    print("=" * 70)


if __name__ == "__main__":
    main()
