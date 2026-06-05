# Director Audit — 2026-06-04

**Auditor**: Senior Mobile Game UI/UX Director
**Method**: Visual audit of latest screenshots ONLY. Prior reports ignored.
**Verdict mode**: Brutally honest. No flattery.

**Source of truth (screenshots inspected)**:
- `assets-raw/_screenshots/phase_bc_avatar_swap/01_menu_select.png`
- `assets-raw/_screenshots/phase_bc_avatar_swap/02_guest_select.png`
- `assets-raw/_screenshots/phase_bc_avatar_swap/03_cooking.png`
- `assets-raw/_screenshots/phase_bc_avatar_swap/04_result_top.png`
- `assets-raw/_screenshots/phase_bc_avatar_swap/04_result_bottom.png`
- `assets-raw/_screenshots/phase_a_art_swap/01_slice_ramen.png` … `08_plate_tteokbokki.png`

**Reference targets**: Cooking Diary, Merge Mansion, Royal Match.

---

## 1. Critical Issues (max 10)

> Each issue is judged from what is **literally visible** in the screenshots, not from spec docs.

| # | Issue | Screen | Severity |
|---|-------|--------|----------|
| 1 | **Cooking screen looks like a prototype.** The dish art is a static painted PNG hovering in a beige void. There is no kitchen, no countertop, no steam, no shadow under the pan. Compared to Cooking Diary it reads as a placeholder mock. | 03_cooking, all phase_a 01–08 | Blocker |
| 2 | **Giant orange TAP/STIR/STOP/FLIP buttons crash into the dish art** and cover ~30% of the screen. They are flat orange rectangles with no bevel, no glow, no haptic state. **This is the single most prototype-looking element in the game.** | phase_a 01,02,04,06,08 | Blocker |
| 3 | **Result screen has a brown empty oval where the finished-dish hero art should sit** (literal placeholder ellipse with the dish name text dropped inside). This is a missing-asset shipping bug visually. | 04_result_top | Blocker |
| 4 | **Score "8800" is occluded by the "NEW RECORD!" pill** — the most emotional moment of the loop is unreadable. The stars row `***__` is rendered as ASCII-style asterisks instead of actual star sprites. | 04_result_top, 04_result_bottom | Blocker |
| 5 | **Menu select cards have three competing red gradient banners** (TODAY'S PICK ribbon, the level chip, the COOK button) plus a yellow Lv chip, gold coin pill, and recipe icon — six attention-grabbing chips per card. The eye has nowhere to land. | 01_menu_select | High |
| 6 | **Guest select cards leak into each other**: a half-cut row at bottom, a partially-obscured "RECOMMENDED" ribbon at top, overlapping compatibility chips. **Looks like a debug grid view, not a casting screen.** | 02_guest_select | High |
| 7 | **Step header typography is identical across all 8 cooking modules** ("Step 1/4 · Slice" in tiny black serif on cream) — no visual difference between Slice / Stir / Flip / Roll / Plate. No icon, no color cue, no progress dots. Players cannot pre-attune to the mechanic. | phase_a 01–08 | High |
| 8 | **The red-and-white awning border is pasted on top of every screen including cooking and result**, eating 5% of vertical space and clipping the score number and step title on result/cooking screens. It is a decorative element behaving like a UI bug. | All screens | High |
| 9 | **Avatar art and dish art are from different style worlds.** Dish art is painterly/saturated (Cooking Diary-ish). Avatars are flat cartoon with hard outlines and pastel skin (Toca-ish). Side-by-side on the result screen they fight each other. Premium games unify style. | 02_guest_select, 04_result_top | High |
| 10 | **"Art coming soon" text is shipped inside a live card** on the menu (Kimchi Stew slot, Lv 4). This is a TODO leaking into production UI. | 01_menu_select | Blocker |

**Prototype verdict per screen**:
- Menu select: **Late prototype** — art exists but layout is unfinished.
- Guest select: **Prototype** — clipping, overlap, debug-grid feel.
- Cooking (all 8): **Prototype** — orange button rectangles + empty beige background.
- Result: **Prototype** — placeholder oval + occluded score = ship-blocker visual.

---

## 2. High ROI Fixes

Ranked by `(visual_impact × player_perception) / effort`. 1 = highest ROI.

| Rank | Fix | Effort (d) | Visual Impact (1–5) | Perception (1–5) | ROI Score |
|------|-----|------------|---------------------|------------------|-----------|
| 1 | Replace TAP/STIR/FLIP/STOP rectangles with a **circular glossy action puck** anchored bottom-center (90 dp inset), with press/release/hit/miss states + ring pulse on beat | 1.5 | 5 | 5 | 16.7 |
| 2 | **Kill the brown placeholder oval** on result. Show the actual cooked dish PNG + plate shadow + 2 steam wisps + 3 sparkle particles on reveal | 1 | 5 | 5 | 25.0 |
| 3 | **Move "NEW RECORD!" pill above the score**, not on top of it. Replace ASCII stars with 5 gold star sprites that pop-in sequentially (60 ms stagger) | 0.5 | 4 | 5 | 40.0 |
| 4 | Add a **single shared cooking background**: dark wood counter + soft vignette + warm key light from upper-left. One asset, used by all 8 modules. Removes the beige-void prototype look instantly | 1 | 5 | 4 | 20.0 |
| 5 | **Awning border**: remove from cooking + result screens. Keep only on menu select. (It is signaling "shop", which is the menu screen's job, not gameplay.) | 0.25 | 3 | 3 | 36.0 |
| 6 | Menu cards: **drop to two chips max** (Lv + Stock). Move COOK button to a single full-width bottom CTA per card. Promote the dish art to ~60% of card height | 1 | 4 | 4 | 16.0 |
| 7 | Guest cards: **2-up grid with snap scroll**, full-card height, no clipped rows. RECOMMENDED ribbon corner-folded inside the card, not floating above | 1.5 | 4 | 4 | 10.7 |
| 8 | Replace step header text with **icon + colored module tag** (knife / wok / pan / pot / mat / plate), each module has its own accent color so muscle memory builds | 1 | 3 | 4 | 12.0 |
| 9 | Add **dish reveal sequence on result**: 200 ms zoom-in + 100 ms star pop + 300 ms score count-up + 200 ms guest reaction. Same assets, just sequencing | 1 | 4 | 5 | 20.0 |
| 10 | Unify avatar style to match dish painterly tone: add **soft inner shadow + warm rim light** on avatars. No re-draw needed, shader/overlay only | 1 | 3 | 3 | 9.0 |
| 11 | Replace the "Art coming soon" Kimchi Stew slot with a **locked card state** (dish silhouette + padlock + "Unlock at Lv 4") — same data, no prototype text | 0.25 | 3 | 4 | 48.0 |
| 12 | **Press-state for every button**: 4 dp downward translate + 8% darken + 60 ms tween. Single shared style. Game instantly feels responsive | 0.5 | 3 | 5 | 30.0 |

**Top 3 to ship first**: #3 (stars/record pill), #11 (locked card), #2 (kill placeholder oval). All under 2 days combined, all visible on first 30 seconds of play.

---

## 3. Screen Redesign Specs

### 3.1 Menu Select (`01_menu_select.png`)

**Wireframe**:
```
┌──────────────────────────────┐
│  K-Food Master         63,168 │  ← compact top bar (no subtitle)
│  Lv 8 · Gwangjang             │
├──────────────────────────────┤
│  ┌────────────┐ ┌────────────┐│
│  │  [DISH ART]│ │ [DISH ART] ││  ← 60% of card = art
│  │     XL     │ │     XL     ││
│  │            │ │            ││
│  │ Ramyeon    │ │ Gimbap     ││  ← title only
│  │ ⭐ Lv 1    │ │ ⭐ Lv 1    ││  ← single chip
│  │ ┌────────┐ │ │ ┌────────┐ ││
│  │ │  COOK  │ │ │ │  COOK  │ ││  ← full-width CTA
│  │ └────────┘ │ │ └────────┘ ││
│  └────────────┘ └────────────┘│
│  ┌────────────┐ ┌────────────┐│
│  │  Tteokbokki│ │ Janchi     ││
│  │  Lv 2      │ │ M Lv 3     ││  ← mystery diner = corner badge only
│  │            │ │            ││
│  └────────────┘ └────────────┘│
│  ┌────────────┐ ┌────────────┐│
│  │   🔒       │ │ [DISH ART] ││  ← locked = silhouette + padlock
│  │  Unlock    │ │            ││
│  │  Lv 4      │ │ Bibimbap   ││
│  └────────────┘ └────────────┘│
└──────────────────────────────┘
```

- **Priority**: P0 dish art + Lv chip + COOK. P1 currency, location. P2 "TODAY'S PICK" (turn into 1 subtle gold corner ribbon on hero card, not a banner across).
- **Remove**: Junho/Mrs. Lee quote subtitles (they belong on guest select), the "TODAY'S PICK" red banner, "Stock 3" text on the COOK button, the "Art coming soon" text.
- **Enlarge**: Dish art to 60% of card height. Currency pill +20%.
- **Move**: Mystery diner indicator to **top-right corner badge only** (no separate row). Recipe icon → remove from cards, merge into Lv chip.
- **Text → Visual**: "Lv 1/2/3" → star count (1–5 stars). "Stock 3" → 3 dots beneath the COOK button. Locked card → silhouette + padlock icon, no "Art coming soon" text.

---

### 3.2 Guest Select (`02_guest_select.png`)

**Wireframe**:
```
┌──────────────────────────────┐
│  ←  Who'll love your         │
│     Kimchi Stew?              │
│  ░░░░░░░░░░░░░░ Auto: Junho   │  ← collapsed sub-bar
├──────────────────────────────┤
│  ┌────────────────────────┐  │
│  │ ★ RECOMMENDED  90%     │  │  ← full card, corner-fold ribbon
│  │ ┌─────┐  Junho         │  │
│  │ │ AVA │  Friend        │  │
│  │ │     │                │  │
│  │ └─────┘  Likes 🌶️ 🧂 ❤️ │  │
│  │          Avoids 🥛 🥬   │  │
│  │  ┌──────────────────┐  │  │
│  │  │ COOK FOR JUNHO   │  │  │  ← full-width CTA per card
│  │  └──────────────────┘  │  │
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │              79%       │  │
│  │ ┌─────┐  Father        │  │
│  │ │ F   │  Family        │  │
│  │ └─────┘                │  │
│  └────────────────────────┘  │
│   ↓ scroll for more guests   │
└──────────────────────────────┘
```

- **Priority**: P0 avatar + name + compat %. P1 likes/avoids. P2 friendship Lv bar.
- **Remove**: Half-clipped bottom row (force full-card snap-scroll). The duplicate "compat" word top-left of each card. "★ Friendship" chip top-right (move to inside).
- **Enlarge**: Avatar circle +30%. Compat % to 36 sp gold. Name to 22 sp bold.
- **Move**: RECOMMENDED ribbon → folded into top-left corner of the recommended card only. "Reward" pill → inside card under CTA, not floating.
- **Text → Visual**: "Spicy/Salty/Sweet/Sour/Umami" labels → only emoji icons (🌶️ 🧂 🍯 🍋 🍱). Friendship Lv → ring gauge around avatar instead of separate text.

---

### 3.3 Cooking (any of the 8 modules — use `06_timing_ramyeon.png` as canonical)

**Wireframe**:
```
┌──────────────────────────────┐
│  ←   🔪 STEP 1/4   ●●●○      │  ← icon + dots, no awning here
├──────────────────────────────┤
│   ┌──────────────────────┐   │
│   │                      │   │
│   │   [DARK WOOD COUNTER │   │
│   │    + VIGNETTE]       │   │
│   │                      │   │
│   │     ╭──────╮          │   │
│   │     │ POT  │  ~steam  │   │
│   │     │      │           │   │
│   │     ╰──────╯          │   │
│   │   ████████░░░         │   │  ← progress on the pot, not floating
│   │                      │   │
│   └──────────────────────┘   │
│                              │
│                              │
│            ╭───╮              │
│           │ ⬤  │             │  ← circular action puck, 96 dp
│            ╰───╯              │     glossy, ring pulse on beat
│       (tap when in gold zone) │
└──────────────────────────────┘
```

- **Priority**: P0 dish + action puck + timing cue. P1 step header. P2 mood/guest reaction (small bottom-left chip, not full character row).
- **Remove**: The awning border. The flat orange TAP/STIR/STOP/FLIP rectangles. The "Beat 2/4 · 0.23s" debug text. The grey "MISS" badge mid-dish.
- **Enlarge**: Dish art to 55% of screen height, centered. Action puck to 96 dp with 24 dp glow halo.
- **Move**: Action button → circular puck bottom-center (90 dp safe inset). Progress bar → attached to the cookware itself (rim of pot). Hungry/Happy mood chip → small 36 dp bottom-left corner.
- **Text → Visual**: "Tap anywhere on each beat…" instruction → **first-time only** floating coach card that auto-dismisses in 2 s. "Beat 2/4" → ring of 4 dots around the puck, filling on each beat. "MISS" text → red flash on puck + screen shake. "PERFECT!" → gold burst particle on puck.

---

### 3.4 Result (`04_result_top.png` + `04_result_bottom.png`)

**Wireframe**:
```
┌──────────────────────────────┐
│            Served!            │
│                              │
│       ╭────────────╮          │
│       │            │          │  ← REAL dish art (no oval)
│       │ [DISH PNG] │          │     with plate shadow + steam
│       │   + steam  │          │
│       ╰────────────╯          │
│                              │
│      Kimchi Stew (김치찌개)   │
│                              │
│       ⭐⭐⭐ ⭑ ⭑              │  ← actual star sprites
│                              │
│         NEW RECORD!           │  ← above score, not on top
│                              │
│           8,800               │  ← 56 sp gold, count-up anim
│                              │
│   ┌──────────────────────┐   │
│   │ ┌─┐ Junho            │   │  ← guest reaction bubble
│   │ │A│ "Spicy kick!"    │   │
│   │ └─┘ 93% ●●●●●●●●●░    │   │
│   └──────────────────────┘   │
│                              │
│   ────── Tap to see ──────   │  ← collapsed by default
│         breakdown ↓           │
│                              │
│  [Cook Again] [Other] [Menu] │  ← bottom bar, no overlap
└──────────────────────────────┘
```

- **Priority**: P0 dish reveal + score + stars + guest reaction. P1 rewards (coins, XP). P2 breakdown (Prep/Cook/Season/Plating) — **hide behind expand**.
- **Remove**: The brown placeholder oval. The ASCII `***__` stars. The "Score Breakdown" block in default view (move behind a tap-to-expand). The duplicate `₩50,000` pill floating over the buttons. The awning border on this screen.
- **Enlarge**: Dish art to 40% of screen. Score number to 56 sp gold with tween. Guest reaction avatar to 80 dp.
- **Move**: "NEW RECORD!" pill above the score, not over it. Action bar (Cook Again / Other / Menu) sticks to bottom safe-area with no overlap. Rewards block above the breakdown, not below.
- **Text → Visual**: Score breakdown bars stay (they're fine when revealed) but the SECTION is collapsed initially — first impression is dish + score + stars + reaction, not a stat sheet. Compat % → ring gauge around the guest avatar.

---

## 4. Korean Food Learning Layer

### Requirements (restated)
- Teach Korean food naturally
- ≤ 5 seconds to read
- No long paragraphs
- US players age 8–60
- Must **increase** retention, not gate it

### Design Principle
**The dish itself is the teacher.** No quiz, no modal, no popup. Knowledge is delivered as a 1-line "flavor card" that slides in **once per dish**, the first time you cook it, on the result screen as the dish is revealed. After that, it's accessible only on tap (dish name → flip-card).

### Mockup

**A. First-cook flavor card (auto, 2.5 s)**
```
┌──────────────────────────────┐
│       [DISH ART revealed]    │
│                              │
│   ┌──────────────────────┐   │
│   │ 🇰🇷  KIMCHI STEW      │   │  ← slides up from dish, 300 ms
│   │     김치찌개           │   │
│   │  "Spicy & soulful —   │   │
│   │   Korea's comfort hug" │   │
│   │   🌶️🌶️ · 🍲 stew       │   │  ← spice + category icons
│   └──────────────────────┘   │
│                              │
│   (auto-dismiss in 2.5 s, or │
│    tap dish name later to    │
│    see again)                │
└──────────────────────────────┘
```

**B. Persistent access — dish name acts as a flip button**
- On any screen that shows the dish name, a tiny ⓘ next to the name.
- Tap → 200 ms flip → same flavor card on back.
- Tap again → flip back to dish.

### Screen Flow
```
[Menu select] → [Guest select] → [Cooking] → [Result reveal]
                                                   │
                                                   ▼
                                      [Flavor card slides in]
                                       (only on first cook of this dish)
                                                   │
                                          2.5 s auto-dismiss
                                                   │
                                                   ▼
                                      [Normal result UI]
                                                   │
                                       (dish name ⓘ tap anytime)
```

- **Trigger**: First successful cook (any rank) of a dish, ONCE per dish per save. Tracked in save file.
- **Dismiss**: Auto after 2.5 s, OR tap-anywhere skip.
- **Re-access**: Tap ⓘ next to dish name on menu, guest, cooking, or result screen.
- **Never blocks gameplay**, never gates progression, never requires a tap to dismiss to continue.

### Sample Content (≤ 5 second read)

| Dish | EN Name | KR Name | One-line Flavor | Icons |
|------|---------|---------|-----------------|-------|
| Ramyeon | Ramyeon | 라면 | "Slurp-worthy spicy noodles — Korea's 3 a.m. friend" | 🌶️🌶️ · 🍜 noodle |
| Gimbap | Gimbap | 김밥 | "Seaweed roll with rainbow inside — picnic in a bite" | 🌿 · 🍙 rolled |
| Kimchi Stew | Kimchi Stew | 김치찌개 | "Spicy & soulful — Korea's comfort hug" | 🌶️🌶️ · 🍲 stew |
| Bibimbap | Bibimbap | 비빔밥 | "Mix-it-all rice bowl — every bite is different" | 🌶️ · 🍚 bowl |

**Why this works**:
- One line ≤ 60 characters → reads in 2 s.
- Spice + category icon → instantly classifies dish.
- Tag line includes one **memorable emotional hook** ("3 a.m. friend", "comfort hug", "picnic in a bite", "every bite different") — sticks.
- No history paragraphs, no ingredient lists, no quiz.
- Auto-dismiss → doesn't fight retention.

### What NOT to do (rejected patterns)
- ❌ Loading-screen Korean food trivia → players skip / hate forced reads.
- ❌ Encyclopedia tab → 95% of players never open it; pure dev cost.
- ❌ Quiz unlock gate → reduces D1 retention by gating fun.
- ❌ Long-form recipe story → violates 5-second rule.

---

## 5. Two-Week Polish Roadmap (10 working days)

**Hard constraints**:
- NO new gameplay systems
- NO new CSV schemas
- NO new progression mechanics
- NO new monetization
- Only: UI polish, character presentation, emotional payoff, Korean food identity, premium mobile feel

### Day-by-day

| Day | Theme | Tasks | Owner |
|-----|-------|-------|-------|
| **D1** | Kill prototype look (result) | (a) Remove brown placeholder oval, wire dish PNG + plate shadow + 2 steam wisps. (b) Move "NEW RECORD!" pill above score. (c) Replace ASCII `***__` with 5 gold star sprites + sequential pop. | godot-dev + art-director |
| **D2** | Kill prototype look (cooking buttons) | Replace all 8 modules' orange TAP/STIR/FLIP/STOP/PRESS&HOLD rectangles with a single **circular glossy action puck** prefab. Add press/release/hit/miss states + ring pulse on beat. | godot-dev |
| **D3** | Cooking environment | Add **shared cooking background**: dark wood counter + vignette + warm key light. Replace beige void on all 8 modules. Add plate shadow under dish art. Add 2-wisp idle steam loop. | art-director + godot-dev |
| **D4** | Step header + module identity | Replace text-only step header with **icon + accent-color module tag** per module (knife/wok/pan/pot/mat/plate). Add 4-dot beat ring around the action puck. Remove awning border from cooking + result screens. | ui-designer spec + godot-dev |
| **D5** | Result reveal sequence | Sequence: 200 ms dish zoom-in → 100 ms star pop → 300 ms score count-up → 200 ms guest reaction slide-in. Collapse "Score Breakdown" by default behind tap-to-expand. Fix overlapping `₩50,000` pill. | godot-dev |
| **D6** | Menu card cleanup | Two chips max (Lv stars + Stock dots). Promote dish art to 60% card height. Full-width COOK CTA. Replace "Art coming soon" with locked-state silhouette + padlock. Remove duplicate ribbons. | ui-designer spec + godot-dev |
| **D7** | Guest card cleanup | Full-card snap-scroll (no clipped rows). Avatar +30%. Compat % 36 sp gold. RECOMMENDED ribbon → corner-fold. Likes/avoids → emoji-only chips. Friendship → ring gauge around avatar. | ui-designer spec + godot-dev |
| **D8** | Korean food learning layer | Implement first-cook flavor card (2.5 s auto-dismiss + tap-skip). Add ⓘ flip-card to dish name on menu/guest/result. Write 12 flavor-card strings (one per dish). Save-file flag per dish. | godot-dev + pm copy |
| **D9** | Press-state + haptics + audio polish | Global 4 dp / 8% darken / 60 ms press tween on every button. Light haptic on tap, medium haptic on PERFECT, heavy on NEW RECORD. Confirm SFX layering on result reveal. | godot-dev |
| **D10** | Avatar style unification + final pass | Add soft inner shadow + warm rim light overlay on avatar sprites (shader, no re-draw). Final QA pass: capture before/after screenshots of all 4 screens + all 8 cooking modules. Compare to Cooking Diary / Royal Match reference. | art-director + qa-tester |

### What is explicitly **NOT** in this sprint
- New cooking modules
- New dishes / new guests
- New friendship rewards
- New IAP / ad placements
- New CSV columns
- New scenes
- Tutorial rework (FTUE stays as-is)
- Localization expansion

### Definition of Done
A neutral viewer shown screenshots of menu / guest / cooking / result **cannot tell which is from K-Food Master and which is from Cooking Diary** at first glance. If they can still tell ours apart by the orange-rectangle button or beige-void background, D2/D3 failed.

---

## 6. Final Verdict

### Production quality reachable in 2 weeks? **Conditional YES.**

**Why YES is possible**:
- Core art (dish illustrations, avatars) is already at production tier. The painterly dish art on the menu screen is genuinely good.
- The systems work — guest compat, scoring, friendship, rhythm — they just look like a prototype wearing them.
- All 10 critical issues are **presentation**, not architecture. None require new code paths, only swap-outs.
- The roadmap is achievable: 6 of 10 days are pure UI/asset swaps, 3 are sequencing/polish, 1 is the learning layer.

**Conditions that must be met (non-negotiable)**:
1. **D1 + D2 + D3 ship together or none ship.** Fixing the result oval without fixing the cooking buttons still leaves the game looking like a prototype. The "prototype feel" comes from cooking + result together.
2. **No new features sneak in.** If a designer asks for "just one more guest", reject. The point of this sprint is polish density, not surface area.
3. **Art director must own the shared cooking background asset (D3).** Without it, the action-puck swap (D2) still sits in a beige void. The background is the single highest-impact asset of the whole sprint.
4. **Avatar/dish style unification (D10) is the riskiest item.** If shader overlay doesn't sell it, accept that v1 ships mismatched and schedule a v2 avatar re-skin post-launch. Do not let it block the sprint.

**Why I am NOT saying unconditional YES**:
- The current cooking screens (all 8) are far from Cooking Diary quality. Even after D2+D3, they will be **acceptable casual mobile**, not **premium**. True premium needs ingredient drop animations, chopping debris particles, oil splatter on flip, steam volumetric — none of which are in this sprint and none should be.
- "Production quality" measured against Royal Match / Merge Mansion would require character animation, cinematic camera, and dish 3D — out of scope.
- Measured against **Cooking Diary mid-tier mobile cooking sim**, YES, this sprint gets us there.

**Bottom line**: Ship the 10-day roadmap as-defined. Resist scope creep. The game will not look like a prototype after D10. It will not yet look like Royal Match. That is the correct target for this stage.
