# Placeholder Audit — Premium V1 Screens (2026-06-04)

> 작성: art-director · 대상: pm, godot-dev, ui-designer
> 대상: `assets-raw/_screenshots/premium_v1/01~04_*.png` (4 screens)
> 비교: `assets-raw/_screenshots/guest_v2/`, `cooking_framework_v2/`, `result_v2/`
> 결론: 시각적 완성도 65% — 5 priority axis 모두 procedural placeholder 잔존

---

## 0. Audit 요약 (한 줄)

> Premium V1 (drop shadow / glossy / ribbon / sparkle / coin spray)로 framing은 AAA급 완성. 그러나 **character / cooking tool visual / result hero / guest avatar / placeholder food card 5축**은 모두 procedural ColorRect + 단색 panel + 첫 글자 letter로 채워져 있어, **"화면에서 시선이 멈추는 모든 지점"이 visual stub**. premium chrome ≠ premium content.

---

## 1. Screen-by-Screen Audit

### 1.1 `01_menu_select.png` — Menu Select

| Element | Visual State | Code Source | Status |
|---------|-------------|-------------|--------|
| Hanging wooden signboard "K-Food Master" | procedural Panel + Label | `menu_select.gd:49~79` | **placeholder** (No real wood-grain texture) |
| Lv/market pill, Gold wallet pill | procedural gradient pill | `menu_select.gd:566~636` | OK (premium polish 충분) |
| Card frame + drop shadow | DropShadowPanel | `drop_shadow_panel.gd` | OK |
| Plate (warm glow + cream BG) | StyleBoxFlat + Gradient | `menu_select.gd:198~227` | OK (frame OK, content이 문제) |
| **Dish thumb (Ramyeon/Gimbap/Tteokbokki/Janchi/Bibimbap)** | premium_v2 PNG LOCK | `t1_002.png` 등 | **OK** (LOCK 활용) |
| **Dish thumb (Kimchi Stew, Lv4)** | "Art coming soon" Label | `menu_select.gd:242~251` | **CRITICAL placeholder** — premium card 안 본문이 텍스트 |
| Lv rarity tag | flat Panel + color | `menu_select.gd:253~271` | OK (game-y로 충분) |
| TODAY'S PICK ribbon | GoldRibbonBanner + sparkle | `gold_ribbon_banner.gd` | OK |
| Best guest mini-badge (Junho/Mina/etc.) | tinted circle + initial letter "J" / "M" | `menu_select.gd:462~480` | **placeholder** (5 guests × 0 art) |
| Cook CTA glossy button | GlossyButton | `glossy_button.gd` | OK |
| Stock counter | text-only | inline | acceptable |
| Locked overlay "UNLOCK Lv X" | flat pill | `menu_select.gd:374~394` | OK |
| Market BG (재래시장) | MarketBG procedural | `market_bg.gd` | **placeholder** (BG-01~05 art LOCK 미통합) |

**핵심 문제**:
1. Lv4 Kimchi Stew = `t2_009`는 menus.csv에 `ready=false`로 thumb이 빠진 채 "Art coming soon" 텍스트 표시. → **premium_v2 12 LOCK에 kimchi_jjigae 포함 미확인** (실제로는 `F-09_kimchi_jjigae_v1.png` 존재! ready flag만 false)
2. 모든 mini-badge avatar = colored circle + letter. **Junho/Mina/Riley/Mrs.Lee/Seoyeon 5명의 캐릭터 art가 LOCK된 적 없음** (week1-anchors는 CH-01 protagonist + CH-02/03 mother/father만)

---

### 1.2 `02_guest_select.png` — Guest Select

| Element | Visual State | Code Source | Status |
|---------|-------------|-------------|--------|
| Card frame + drop shadow + border | DropShadowPanel | `guest_card_v2.gd:66` | OK |
| compat 80pt hero number | HeroNumberBounce | `hero_number_bounce.gd` | OK |
| Friendship stars `*` repeated | unicode `*` text | `guest_card_v2.gd:89` | **placeholder** (UI-02 star_rating LOCK 미통합) |
| **Avatar 240x240 circle (J / F / M / R)** | **AVATAR_TINT + letter** | `guest_card_v2.gd:111~154` | **CRITICAL placeholder** — guest 카드의 가장 큰 시각 요소가 색깔 동그라미 |
| Avatar inner radial highlight | GradientTexture2D procedural | `guest_card_v2.gd:126~141` | OK (gloss simulation) |
| Mood badge overlay | MoodBadgeScript procedural | `mood_badge.gd` | acceptable |
| Like/Avoid flavor tag | FlavorTagBadge procedural | `flavor_tag_badge.gd` | OK |
| Reward bonus band gold | RewardBonusBadge | `reward_bonus_badge.gd` | OK |
| RECOMMENDED ribbon gold | sparkle halo | `guest_card_v2.gd:254~322` | OK |
| Cook CTA | GlossyButton | OK |

**핵심 문제**:
1. **5 guest 모두 visual identity = 색깔 + 첫 글자**. premium 디자인 (drop shadow / hero number / ribbon)이 풍부할수록, 정작 "누구를 위해 요리하는가"의 face가 비어있는 대비가 더 두드러짐.
2. Father / Mother는 이미 `CH-02_mother_v2.png` + `CH-03_father.png` + reaction R-01~06 LOCK 보유. **import만 안 되어 있음** (godot-project/art/ 폴더 character 폴더 자체 부재).
3. Friendship `*-----` 텍스트는 vector star icon으로 대체해야 (LOCK된 UI-02 star_rating 활용).

---

### 1.3 `03_cooking.png` — Cooking Module (Slice)

| Element | Visual State | Code Source | Status |
|---------|-------------|-------------|--------|
| NowCookingBanner (Step 2/5 Slice) | premium banner + dots | `now_cooking_banner.gd` + `step_progress_dots.gd` | OK |
| Level pill (Lv 3) | DropShadow gold | `cooking_module_runner.gd:228~247` | OK |
| Howto Label "Tap anywhere on each beat as the knife drops" | Label | `slice_module.gd:46~50` | OK |
| **Background of cooking surface** | MarketBG light | `market_bg.gd` | **placeholder** (kitchen이 아닌 generic warm tone) |
| **Tteokbokki dish illustration in cooking area** | premium_v2 thumb (t1_002) | banner image | **WRONG context** — 음식 완성 image가 cooking 중 한가운데 떠있음 (조리도구가 표시되어야 할 자리) |
| PERFECT! gold text | Label burst | TextFeedback | OK |
| MISS badge orange pill | flat pill | inline | acceptable |
| **TAP big orange pad (1000x420)** | flat ColorRect | `slice_module.gd:53~63` | **CRITICAL placeholder** — 화면 하단 50%가 단색 사각형 + "TAP" 텍스트 |
| **Cutting board (procedural board 500x220)** | StyleBoxFlat brown | `slice_module.gd:34~41` | **placeholder** (TOOL anchor LOCK 됐는데 미사용 — `cutting_board.png` import는 됨) |
| **Knife visual** | 부재 | — | **MISSING** (LOCK된 도구 art 미통합) |
| **Ingredient sprite (재료가 도마에서 잘림)** | 부재 | — | **MISSING** (ingredient_anchors_m1 24장 LOCK 활용 X) |
| Guest mini avatar (bottom-left "J Hungry!") | colored circle + letter | `cooking_module_runner.gd:169~225` | **placeholder** (same as menu) |

**핵심 문제**:
1. Cooking 화면이 시각적으로 가장 비어 있음. **TOOL-01~12 + cutting_board + cut_anchors LOCK 모두 import 됐으나** procedural rectangle 우선 사용.
2. "음식 완성 image가 cooking 시작부터 떠있음" → **stage가 진행될수록 ingredient → 부분 조합 → 완성**으로 morph되어야 함. 현재는 그냥 PNG 정적 표시.
3. 8 cooking module × 0 module별 art identity (slice/arrange/stir/flip/timing/season/roll/plate 모두 같은 procedural pad).

---

### 1.4 `04_result_top.png` + `04_result_bottom.png` — Result Screen V2

#### Top section

| Element | Visual State | Code Source | Status |
|---------|-------------|-------------|--------|
| Stripe awning (red/cream) | procedural | MarketBG light | acceptable |
| Served! label | Label | `result_screen_v2.gd:116~122` | OK |
| **Dish hero image** | premium_v2 PNG (food_img) OR beige bowl placeholder | `result_screen_v2.gd:124~161` | **MIXED** — Kimchi Stew screenshot은 placeholder beige circle 노출 (`ready=false` 동일 원인) |
| Dish name (EN + KR) | Label | OK | OK |
| Compat bar 93% | CompatBarScript | OK | OK |
| **Junho emotion reaction strip** (J letter avatar + speech bubble) | EmotionReaction procedural | `emotion_reaction.gd:82~155` | **CRITICAL placeholder** — Result의 emotion peak moment가 ColorRect circle + 글자 |
| Speech bubble (cream box + tail) | procedural Panel + Polygon2D | `emotion_reaction.gd:136~155` | OK (bubble shape OK, tail OK) |
| Stars `***__` text | text repeat | `result_screen_v2.gd:213~222` | **placeholder** (UI-02 star_rating LOCK 미통합) |
| Hero score 8800 | HeroNumberBounce gold | OK | OK |
| **NEW RECORD! gold ribbon** | GoldRibbonBanner | OK | OK |

#### Bottom section

| Element | Visual State | Code Source | Status |
|---------|-------------|-------------|--------|
| Score Breakdown 6 rows | ScoreBreakdownRowScript | OK | OK |
| Bar fills (green/orange) | procedural ColorRect bar | inline | OK |
| Rewards section (gold coin pill, XP, Friendship) | RewardBoxScript | OK | OK |
| Lv3 Friendship milestone toast | MilestoneToastScript | OK | acceptable |
| Sticky CTA 3 buttons | GlossyButton x 3 | OK | OK |
| Wallet pill | Premium gold gradient | OK | OK |

**핵심 문제**:
1. Result의 emotion strip = 화면 시선의 정점. Junho 색깔 동그라미 + "J"는 5초 typewriter reveal 동안 표시되는데, 5명 guests 모두 같은 placeholder.
2. Stars text `*` repeat은 다른 모든 premium 요소와 어울리지 않는 ASCII 폴백 느낌. UI-02 vector star가 LOCK된 상태에서 미통합.
3. Hero dish의 beige bowl fallback은 Kimchi Stew처럼 ready=false인 dish 한정 — 실제 premium_v2 LOCK 활용한 dish는 OK.

---

## 2. Art LOCK ↔ Code 통합 Gap 분석

### 2.1 폴더 inventory

| Category | LOCK (assets-raw/transparent_m1/) | Imported (godot-project/art/) | Code 사용 | Gap |
|----------|----------------------------------|-------------------------------|----------|-----|
| Food (premium_v2) | 12 (F-01~F-12) | 12 (t1_002~t2_014) | OK menu_select + banner + result | **음식 11/12** (Kimchi Stew = `t2_009` ready=false flag 문제) |
| Background (5가게) | 5 (BG-01~05) | **0** | MarketBG procedural only | **5/5 미import + 미통합** |
| Character avatar/bust (guests) | 0 (week1-anchors는 protagonist/mother/father만) | 0 | tinted circle + initial letter | **5 guests × 1 avatar = 5장 부재** |
| Character (mother/father) | 2 (CH-02_mother_v2 / CH-03_father) | 0 | tinted circle | **2 imported 안 됨** |
| Reaction (mother/father x ★1/2/3) | 6 (R-01~R-06) | 0 | EmotionReaction procedural | **6 imported 안 됨** |
| Reaction (5 guests x emotion) | 0 | 0 | procedural | **5 guests × 4 emotion = 20장 부재** |
| Cooking tools | 12 (TOOL-01~12) | 9 (boil/stirfry/panfry/deepfry/grill/roll/mix/toss/marinate) | **module 내 미사용** | **9 imported, 0 used in modules** |
| Ingredient whole | 12 (F-01~F-12_whole) | 12 (t1_002~t2_014_whole) | shopping_registry만? | **12 imported, cooking modules 미사용** |
| Ingredient cut | 12 (F-01~F-12_cut) | 12 (t1_002~t2_014_cut) | 동일 | **12 imported, cooking modules 미사용** |
| Cut style | 7 (CUT-00~06) | 2 (cutting_board + cut_sliced_rounds) | slice module 미사용 | **5/7 미import + 미통합** |
| UI icons (star/heart/coin/timer/gear/back/tap_ring) | 7 (UI-01~07) | 5 (timer_bar/tap_target_ring/star_rating/heart_life/coin_currency) | **미사용** (text/emoji fallback) | **5 imported, 0 used** |
| VFX (perfect/star/steam/heart/sparkle) | 5 (VFX-01~05) | 3 (perfect_glow_ring/star_burst/steam_swirl) | particle/sparkle만 procedural | **3 imported, 0 used** |

### 2.2 정량 요약

| Status | Count |
|--------|-------|
| LOCK + import + code 사용 | **12** (food premium_v2) |
| LOCK + import + code **미사용** | **40+** (tools 9 / ingredient whole 12 / ingredient cut 12 / UI 5 / VFX 3 / cut 2) |
| LOCK + **미import** + code 미사용 | **18+** (BG 5 / mother+father 2 / reaction 6 / cut 5) |
| **LOCK 자체 부재** | **25+** (5 guests avatar + 5 guests × 4 emotion + 8 module backplate) |

> **80%의 LOCK된 art가 코드에서 시각적으로 활용되지 않음.** Premium V1 chrome (drop shadow / glossy / ribbon)이 채워준 시각 만족도는 ~65%, 나머지 35% gap = LOCK art import + procedural placeholder swap만으로 즉시 회수 가능.

---

## 3. Priority Matrix (5축)

| Priority | Axis | 현 상태 | 신규 PNG 필요 | 기존 LOCK 활용 가능 |
|----------|------|--------|--------------|--------------------|
| **P0** | Character art integration | 5 guests = colored circle + letter | **avatar 5 + emotion 20 = 25장** | mother/father avatar+reaction은 LOCK 활용 (8장) |
| **P0** | Cooking tool visuals | procedural ColorRect pad | **module backplate 8장** | TOOL anchor 12 + ingredient 24 + cut 7 = 즉시 import만 |
| **P1** | Result screen hierarchy | dish beige fallback / `*` text | **3장** (vector star sprite × 3 state) + ready=true flag fix | UI-02 star_rating LOCK 활용 |
| **P1** | Guest card simplification | 시각 noise + placeholder avatar | 0장 신규 | 위 character avatar 5장과 통합 |
| **P2** | Menu card polish | TODAY'S PICK + locked OK | 0장 신규 (polish만) | BG anchor 5 import로 market 배경 LOCK 활용 |
