# Premium Redesign v1 — Visual Quality Sprint Hand-off

> 버전: **v0.1** · 작성일: 2026-06-04 · 작성자: ui-designer
> 상위 문서: [`visual-audit-2026-06.md`](visual-audit-2026-06.md), [`components.md` v0.6](components.md), [`screen-flow.md` v0.5](screen-flow.md), [`result-screen-v2-layout.md` v0.1](result-screen-v2-layout.md), [`guest-select-v2-layout.md` v0.1](guest-select-v2-layout.md), [`food-select-compat.md` v0.1](food-select-compat.md)
> 후속 sprint owner: **godot-dev** (구현) + **art-director** (placeholder swap art)
> Scope: **시각 only** — gameplay / 데이터 구조 / scoring / progression 무변경.
> Reference: Royal Match (Dream Games) · Travel Town (Magmatic) · Cooking Madness (Mobaska) · Merge Mansion (Metacore)

---

## 0. 핵심 원칙 (4 reference 추출)

1. **Glossy 3D button/icon** — 모든 인터랙티브 요소에 인너 하이라이트 + 외곽 lip + drop shadow
2. **Character always visible** — 4 screen 모두 character 1명 이상 + idle breathing
3. **Reward = burst** — PERFECT / NEW RECORD / +coin는 particle + scale bounce + count-up 필수
4. **Color story** — 한 화면 5색 이하 + gold 액센트 일관
5. **Depth via shadow** — 모든 카드 drop shadow 8~16px Y-offset
6. **Hero shot scale** — dish / character 60~80% screen width 차지 가능 여부 검토

### 색상 palette (premium casual lock — hex 코드)
| 토큰 | hex | 용도 |
|------|-----|------|
| `bg_cream` | `#FFF4E1` | 화면 BG / 카드 BG |
| `bg_cream_warm` | `#FFE9CC` | 카드 BG (selected/hover) |
| `accent_gold` | `#FFC857` | 별 / NEW RECORD / premium liner |
| `accent_gold_dark` | `#D89B2F` | gold gradient bottom + outline |
| `cta_persimmon` | `#F4A261` | primary CTA BG top |
| `cta_persimmon_dark` | `#D87A3F` | primary CTA BG bottom (gradient) |
| `cta_red` | `#E63946` | warning / "Best" emphasis |
| `cta_green` | `#52B788` | compat ≥ 75% good |
| `cta_orange` | `#FF8C42` | compat 50~74% ok |
| `cta_gray` | `#9E9E9E` | disabled / sub text |
| `text_dark` | `#3A2E1F` | primary text (Soy Dark) |
| `text_dark_soft` | `#5A4B36` | secondary text |
| `text_white` | `#FFFFFF` | on-button text |
| `shadow_warm` | `#3A2E1F` alpha 25% | drop shadow base |

### Typography lock
- **Primary**: Pretendard Bold (KR + EN)
- **Hero number (score / compat %)**: Pretendard ExtraBold 64~80pt + 2px white stroke + drop shadow 4px
- **CTA**: Pretendard Bold 24pt white + 2px dark stroke
- **Card title (dish/guest name)**: Pretendard Bold 28pt dark
- **Sub-line (한글 sub / hint)**: Pretendard Medium 16pt dark_soft
- **Tag pill text**: Pretendard SemiBold 14pt

---

## 1. Screen 1 — Menu Select Premium Redesign

### 1.1 Redesign items (priority)

| # | item | priority | 변경 area | reference |
|---|------|:---:|------|-----|
| MS-R1 | **Hero "Today's Pick" 띠** — 최상단 best compat 음식 1개를 large card (가로 풀폭 510 → 1040 한 줄, 높이 280) + sparkle pulse + ✨RECOMMENDED 띠 | **P0** | top Y 130~440 신설 | Royal Match goal card |
| MS-R2 | **카드 dish image 영역 swap** — `assets-raw/foods/` 12 음식 anchor 활용 (R1~R8 등 lock된 PNG) — placeholder "Art coming soon" 전부 제거 | **P0** | card body | Cooking Madness hero dish |
| MS-R3 | **카드 drop shadow 12px Y-offset + 4px inner highlight (top 20%)** — Travel Town 3D depth layering | **P0** | card BG | Travel Town |
| MS-R4 | **mini-badge 확대 + glow halo** — 현 110×106 → 130×130, best compat (≥90%) 카드는 gold halo radial 80px pulse 1Hz | **P1** | card top-right | Royal Match glossy sphere |
| MS-R5 | **CTA "Cook · Stock 3" → glossy gradient button** (`cta_persimmon` top → `cta_persimmon_dark` bottom + 2px inner highlight top + 2px dark lip bottom) | **P0** | card CTA | Royal Match |
| MS-R6 | **상단 wallet ₩50,000 → glossy gold pill icon + bouncing digit on 변화** — coin icon `#FFC857` 32×32 + 텍스트 24pt bold + drop shadow 4px | **P1** | top HUD | Royal Match coin HUD |
| MS-R7 | **header awning 차양 → 시장 atmosphere로 강화** — 차양 아래에 distant booth silhouette 1px stroke 추가 (3 booth silhouette, opacity 30%) | **P2** | header BG | Travel Town wood texture |
| MS-R8 | **카드 행간 16 → 24px + 카드 padding 12 → 20px** — breathing space | **P0** | grid gap | universal |
| MS-R9 | **mini-badge "Best: Junho" caption → speech bubble micro tail (▼ tail 8px)** — chip이 avatar에서 나오는 말풍선 느낌 | **P2** | mini-badge | Merge Mansion |
| MS-R10 | **disabled / locked 카드 시각 cue** — 단순 grayscale → "🔒 Locked at Lv 5" pill overlay + 자물쇠 아이콘 48px | **P1** | card disabled | Royal Match |

### 1.2 Before/After ASCII sketch

```
BEFORE (현재):                            AFTER (redesign):

┌──────────────────────────┐              ┌──────────────────────────┐
│  K-Food Master  (title)  │              │ 💰 50,000  ❤️❤️❤️  Lv.8  │ ← glossy coin
│  choose a dish (sub)     │              ├──────────────────────────┤
│  Lv 8 · Gwangjang       │              │ ✨ TODAY'S PICK ✨ pulse │
├──────────────────────────┤              │ ┌──────────────────────┐ │
│ ┌──────┐  ┌──────┐       │              │ │ [Hero dish 1040×260] │ │ ← P0 R1
│ │ Lv1  │  │ Lv1  │       │              │ │  Tteokbokki  92%★    │ │
│ │ Ramy │  │ Gimb │       │              │ │  Best: Mina  Cook ▶  │ │ ← glossy
│ │ Cook │  │ Cook │       │              │ └──────────────────────┘ │
│ └──────┘  └──────┘       │              ├──────────────────────────┤
│ ┌──────┐  ┌──────┐       │              │ ┌──────┐  ┌──────┐       │
│ │ Lv2  │  │ Lv3  │       │              │ │ ▣ Dish│  │ ▣ Dish│      │ ← real art (R2)
│ │ Tteok│  │ Janch│       │              │ │ glossy│  │ glossy│      │
│ │ Cook │  │ Cook │       │              │ │ shadow│  │ shadow│      │ ← P0 R3
│ └──────┘  └──────┘       │              │ │ CTA▼ │  │ CTA▼ │       │ ← gradient CTA
│ ┌──────┐  ┌──────┐       │              │ └──────┘  └──────┘       │
│ │Art   │  │Art   │       │              │ ┌──────┐  ┌──────┐       │
│ │coming│  │coming│       │              │ │ ▣ Dish│  │ 🔒 Lv5│      │ ← lock cue (R10)
│ │ soon │  │ soon │       │              │ │       │  │       │      │
│ └──────┘  └──────┘       │              │ └──────┘  └──────┘       │
└──────────────────────────┘              └──────────────────────────┘
시각 quality 3/10                          시각 quality 7~8/10
```

### 1.3 Placeholder art 재활용
- **존재 art** (재활용 즉시 가능, `assets-processed/foods/`):
  - R1~R8 hero food anchors (12 음식 LOCK 2026-05-31)
  - 가게 시그니처 컬러 swatch (5 store .tres)
  - 코인 아이콘 (Sesame Gold)
- **신규 art 권고 (P2 — MVP 후)**:
  - 시장 atmosphere distant booth silhouette (header BG layer)
  - "TODAY'S PICK" gold ribbon banner (CP-31 NEW RECORD ribbon 재활용 가능)

### 1.4 4 Goal 기여 mapping
| Goal | element | impact |
|------|---------|:---:|
| 정보 density | Today's Pick + best mini-badge + locked pill | +3 |
| Hierarchy | Hero 띠 + drop shadow + glossy CTA | +3 |
| Character | mini-badge avatar 60→80px + speech bubble tail | +1 |
| Reward | glossy gold coin pill | +1 |

---

## 2. Screen 2 — Guest Select Premium Redesign

### 2.1 Redesign items

| # | item | priority | 변경 area | reference |
|---|------|:---:|------|-----|
| GS-R1 | **avatar swap to character art** — 단색 원 + 1-letter → real character anchor (CH-01~CH-05 LOCK 2026-05-31 활용) | **P0** | card avatar 240×240 | Royal Match King mascot |
| GS-R2 | **avatar idle breathing animation** — Tween scale 1.0 → 1.02 → 1.0 2s loop, `Tween.TRANS_SINE TRANS_IN_OUT` | **P0** | avatar Sprite2D | Travel Town |
| GS-R3 | **mood badge 확대 + face emote 통합** — 40×40 → 80×80, mood별 sprite (excited/happy/neutral/grumpy/sad) overlay 우하단 -16px offset | **P0** | mood badge | Merge Mansion |
| GS-R4 | **speech bubble micro 추가 — "Today I want hot stew!"** — avatar 우상단에서 ▲ tail 말풍선 (200×80), 한 줄 한글 sub line | **P1** | card upper area | Merge Mansion |
| GS-R5 | **RECOMMENDED 띠 Z-order 최상위 + sparkle particle 12개 idle** — sub-bar "Auto: Junho" 뒤에 가리는 문제 해결 + 별빛 idle | **P0** | best card overlay | Cooking Madness |
| GS-R6 | **compat % 강조 — 화면 좌상단 hero 80pt + gradient** — 단순 "93%" → gradient `accent_gold` → `accent_gold_dark` + 2px white stroke + drop shadow 6px | **P0** | "93% compat" text | Cooking Madness PERFECT |
| GS-R7 | **flavor tag pill redesign — glossy mini-pill + 2-letter abbr** — 현 "Sa Salty" → "🌶 Spicy" 32×24 pill + icon 16×16 + glossy inner highlight | **P1** | likes/avoids row | Royal Match |
| GS-R8 | **REWARD 띠 강조** — 현 회색 + "guest ×1.50x" 14pt → green band + "+50% ₩ BONUS" 24pt bold + coin icon | **P0** | card bottom band | Cooking Madness |
| GS-R9 | **카드 외곽 stroke 4 → 6px + compat color glow halo (best card만 gold 80px halo)** | **P1** | card border | Royal Match |
| GS-R10 | **친밀도 별점 (friendship ★★★★★) 우상단 강조** — 14pt 회색 → 18pt gold + "Family" / "Friend" / "Mentor" label 강조 | **P2** | card top-right | Travel Town |

### 2.2 Before/After ASCII sketch

```
BEFORE:                                   AFTER:

┌────────────────┐                        ┌────────────────┐
│ ✨RECOMMENDED  │ (잘림)                  │  ✨RECOMMENDED  │ ← sparkle 12 (R5)
│ 93%       ★★☆ │                        │ ╔════════════╗ │ ← halo (R9)
│ compat        │                        │ ║ 93%  ★★★★★ ║│ ← hero (R6/R10)
│  ┌─────┐      │                        │ ║ "Today I... "║│ ← speech (R4)
│  │  J  │ 😊   │ ← single letter        │ ║ ┌────┐  😊  ║│ ← face anchor (R1)
│  └─────┘      │   small mood            │ ║ │REAL│ 😊  ║│ ← idle breath (R2)
│  Junho        │                        │ ║ │AVAT│ big  ║│ ← big mood (R3)
│  Friend       │                        │ ║ └────┘      ║│
│ Likes 🌶Sa H  │ ← small text           │ ║ Junho ★Friend║│
│ Avoids Sw B   │                        │ ║ 🌶 Sw Hr     ║│ ← glossy pill (R7)
│ REWARD x1.5x  │ ← weak                 │ ║════════════ ║│
│ Cook for J >  │                        │ ║+50% ₩ BONUS ║│ ← strong (R8)
└────────────────┘                        │ ║ Cook ▶      ║│
                                          │ ╚════════════╝│
                                          └────────────────┘
시각 3/10                                  시각 8/10
```

### 2.3 Placeholder art 재활용
- **존재 art** (재활용):
  - CH-01~CH-05 character anchors (5 캐릭터 LOCK 2026-05-31) — `assets-processed/characters/`
  - mood reaction v3 코믹 sprite (5 mood × 5 character) — LOCK
  - flavor icon 5종 (🌶 Spicy / 🧂 Salty / 🍯 Sweet / 🌿 Herbal / 💧 Umami)
- **신규 art 권고**:
  - speech bubble template (cream + brown stroke + ▲ tail, art-director 1시간)

### 2.4 4 Goal 기여
| Goal | element | impact |
|------|---------|:---:|
| 정보 density | speech bubble + reward bonus + friendship label | +2 |
| Hierarchy | hero compat 80pt + halo glow + RECOMMENDED Z fix | +3 |
| Character | real avatar + idle breathing + face mood swap | +4 ← **largest gain** |
| Reward | +50% BONUS band + sparkle on best card | +2 |

---

## 3. Screen 3 — Cooking Screen Premium Redesign (8 module 공통)

### 3.1 Redesign items

| # | item | priority | 변경 area | reference |
|---|------|:---:|------|-----|
| CK-R1 | **상단 "Now Cooking" 띠 강화** — dish thumbnail 80×80 + dish name 24pt bold + guest avatar 60×60 + "for Junho" → ALL 8 module 공통 상시 | **P0** | top Y 60~180 | Cooking Madness hero dish |
| CK-R2 | **dish-in-progress sprite 중앙 통합** — slice/arrange/stir/flip/roll/plate 각 module에서 dish 진행 sprite를 화면 중앙 Y 400~800 visible (현재 placeholder ColorRect 대체) | **P0** | module body | Cooking Madness dish sequence |
| CK-R3 | **PERFECT burst 강화** — chip 색 → 화면 중앙 "PERFECT!" 80pt gold gradient scale 0.5→1.2→1.0 bounce + 16 sparkle particle radial + chime visual ring | **P0** | judgement feedback | Cooking Madness PERFECT |
| CK-R4 | **CTA button glossy gradient + module-specific icon** — 현 단조 orange 사각형 → `cta_persimmon` gradient + inner highlight + 도구 아이콘 (TAP = 👆 / STOP = ✋ / FLIP = 🔄 / PRESS&HOLD = ✊) | **P0** | bottom CTA | Royal Match |
| CK-R5 | **timing module: indicator 화살표 + gold halo zone** — 현 막대만 → ▼ 인디케이터 + gold zone pulse halo 1Hz + "WAIT FOR GOLD" 가이드 | **P0** | timing module | rhythm game polish |
| CK-R6 | **arrange module: 슬롯 hover glow** — 빈 슬롯에 재료 hover/match 시 gold ring pulse | **P1** | arrange module slot | universal |
| CK-R7 | **slice module: 도마 + 칼 sprite swap to real art (CUT-00 + CUT-01~06 LOCK)** — 현재 procedural placeholder → 실제 도마 + 식재료 sprite | **P0** | slice module | CP-18 + CP-19 fulfillment |
| CK-R8 | **guest reaction mini-thumbnail 우하단** — 화면 우하단 X 880~1040 Y 1500~1660 에 guest avatar 160×160 + idle breathing + 한 입 먹는 짧은 idle animation | **P1** | bottom-right corner | Cooking Madness customer wait |
| CK-R9 | **step progress dots** — "Step 1/4" 텍스트 → ●○○○ 4개 dot (현재 step = gold filled) + 8pt gap, top center | **P0** | progress indicator | Travel Town |
| CK-R10 | **flip module: pan + 김(steam) + sizzle particle** — 검은 oval pan은 유지 + cooking_vfx_active steam GPUParticles2D 추가 | **P1** | flip module | Cooking Madness atmosphere |
| CK-R11 | **module transition cross-fade** — slice→arrange→... 시 dish sprite cross-fade 0.4s + Tween + "Step Complete" toast | **P1** | runner.gd transition | universal |

### 3.2 Before/After ASCII sketch (timing module 예시)

```
BEFORE (timing):                          AFTER (timing):

┌──────────────────────────┐              ┌──────────────────────────┐
│ awning (frame only)      │              │ 💰  ❤️  Lv  ⏸             │
│ Step 1/4 · Timing        │              │ ┌──────────────────────┐ │
│ Wait until gold...       │              │ │ ● ○ ○ ○  Now Cooking │ │ ← step dots (R9)
│                          │              │ │ [dish] Tteokbokki ▶  │ │ ← banner (R1)
│   (dead zone)            │              │ │ for Junho [av] 😊    │ │
│                          │              │ └──────────────────────┘ │
│                          │              │                          │
│                          │              │   ┌────────────────┐     │
│                          │              │   │ Tteokbokki     │     │ ← dish (R2)
│                          │              │   │ pot bubbling   │     │
│  ████████░░░░ 74%        │ ← weak       │   │ steam particle │     │
│                          │              │   └────────────────┘     │
│                          │              │                          │
│  ┌──────────────────┐    │              │   ▼ indicator (R5)       │
│  │      STOP         │    │ ← plain     │  ████████▓▓▒▒ ✨gold     │
│  └──────────────────┘    │              │  WAIT FOR GOLD            │
│ footer (frame only)      │              │                          │
└──────────────────────────┘              │ ┌──────────────────────┐ │
                                          │ │ ✋  STOP             │ │ ← glossy (R4)
                                          │ └──────────────────────┘ │
                                          │           [avatar guest] │ ← mini (R8)
                                          └──────────────────────────┘
시각 2/10                                  시각 7/10
```

### 3.3 Placeholder art 재활용
- **존재 art**:
  - 12 음식 hero anchors (slice/arrange/stir/flip/roll/plate 진행 sprite로 활용 가능)
  - CUT-00 (도마) + CUT-01~06 (knife) + ICUT-01~12 (cut ingredient) — LOCK
  - TOOL-01~12 (조리 도구) — LOCK
  - CH-01~05 character anchors (cooking screen guest mini)
- **신규 art 권고 (M2 art-director)**:
  - dish-in-progress sprite per module per food (12 음식 × 4~8 module = 60~96 sprite, 대량) → MVP는 hero anchor 단일 활용 + module overlay only
  - PERFECT burst sparkle PNG sprite sheet (16 frame, particle)
  - steam particle texture (cooking_vfx)

### 3.4 4 Goal 기여
| Goal | element | impact |
|------|---------|:---:|
| 정보 density | Now Cooking banner + step dots + guest mini | +3 |
| Hierarchy | dish sprite center + PERFECT burst | +3 |
| Character | guest mini bottom-right idle breathing | +2 |
| Reward | PERFECT burst + sparkle 16 + scale bounce | +3 ← **largest gain** |

---

## 4. Screen 4 — Result Screen v2 Premium Redesign

### 4.1 Redesign items

| # | item | priority | 변경 area | reference |
|---|------|:---:|------|-----|
| RS-R1 | **§1 dish hero shot — real art swap + steam idle** — placeholder beige oval → 12 음식 hero anchor 460×460 + steam particle 8 idle loop + sparkle 4 idle | **P0** | §1 Summary dish area | Cooking Madness dish reveal |
| RS-R2 | **avatar real character + idle breath** — Guest Select와 동일 (R1/R2) | **P0** | §4 Reaction avatar | Royal Match mascot |
| RS-R3 | **Score number bounce-in + gold gradient + glow halo** — "Score 8800" 36pt black → 80pt ExtraBold gradient gold + 6px drop shadow + scale 0.5→1.2→1.0 0.6s bounce + halo pulse 1Hz | **P0** | Score Total | Cooking Madness PERFECT |
| RS-R4 | **★★★ star rating burst** — 좌→우 fade 0.3s/별 + 마지막 별에 16 sparkle radial burst + chime ring visual | **P0** | star rating | Cooking Madness 3-star |
| RS-R5 | **NEW RECORD ribbon hero** — 210×60 → 540×100 full-width gold ribbon + sparkle 24개 + scale 0.3→1.0 slide-in from top + 0.5s shake | **P0** | NEW RECORD badge | Royal Match level complete |
| RS-R6 | **Coin count-up + spray** — "+9,100 coin" 32pt orange → 64pt gold gradient + digit count-up tween 1.5s + coin spray 20 particles from center to HUD wallet position | **P0** | §3 Rewards | Cooking Madness coin spray |
| RS-R7 | **friendship bar fill animation + milestone burst** — bar fill Tween 1.0s + milestone Lv 3 unlock 시 toast 위 sparkle 12 + scale bounce | **P0** | §3 Friendship | Travel Town progression |
| RS-R8 | **Sticky CTA hierarchy** — Cook Again (primary, glossy gradient persimmon big) > Choose Other Guest (secondary, cream outlined) > Back to Menu (tertiary, text-only) | **P0** | sticky bottom | Royal Match next-level CTA |
| RS-R9 | **speech bubble redesign — round + tail + breathing pulse** — 현 사각 cream BG → rounded 16px + ▲ tail 좌측 + idle scale 1.0→1.01 pulse 2s loop | **P1** | §4 speech bubble | Merge Mansion |
| RS-R10 | **mood badge 확대 + face emote** — 40 → 80px overlay + 5 mood face sprite (CH 캐릭터 mood swap) | **P0** | reaction avatar overlay | Guest Select R3 |
| RS-R11 | **Score Breakdown row 색상 코드 + bar fill animation** — bar 회색 → row별 색상 (Prep blue / Cook orange / Season red / Plating green / Compat gold / Mood pink) + 좌→우 fill 0.5s sequential | **P1** | §2 Breakdown 6 row | Merge Mansion category color |
| RS-R12 | **compat bar 길이 풀폭 + label "PERFECT MATCH" 추가** — 300px → 540px full-width + 라벨 "PERFECT MATCH 93%" 28pt bold | **P1** | compat bar | Royal Match |

### 4.2 Before/After ASCII sketch (Above-the-fold)

```
BEFORE:                                   AFTER:

┌──────────────────────────┐              ┌──────────────────────────┐
│ awning (frame)           │              │ 💰  ❤️  Lv  ⏸            │
│   Served!                │              ├──────────────────────────┤
│   ╭──────────╮           │              │      Served!             │
│   │ Kimchi   │ ← placeh  │              │   ┌────────────────┐     │
│   │ Stew     │           │              │   │ ▣ REAL DISH    │     │ ← real art (R1)
│   ╰──────────╯           │              │   │   460×460      │     │
│   Kimchi Stew            │              │   │   steam idle   │     │
│   ████░░░ 93%            │ ← thin       │   │   sparkle ✨   │     │
│   compatibility w/...    │              │   └────────────────┘     │
│                          │              │  Kimchi Stew (김치찌개)   │
│  ┌──────────┐ ┌────┐     │              │ ████████████████ 93%     │ ← full (R12)
│  │ J  speech│ │    │     │              │  ✨ PERFECT MATCH ✨      │
│  │ excellent│ │    │     │              │                          │
│  └──────────┘ └────┘     │              │ ┌────────┐ ╭──────────╮  │
│   Junho                  │              │ │ REAL   │ │"Junho    │  │ ← bubble (R9)
│   ★★★__                 │              │ │ AVATAR │ │ loved... │  │
│   Score 8800             │ ← plain      │ │idle 😊 │ │ EXCELLENT│  │
│   ★ NEW RECORD ★         │ ← small      │ └────────┘ ╰──────────╯  │ ← face (R10)
└──────────────────────────┘              │  ★★★ → sparkle burst!    │ ← (R4)
                                          │  ✨ Score 8800 ✨        │ ← bounce (R3)
                                          ├══════════════════════════│
                                          │  ★ NEW RECORD ★          │ ← hero ribbon (R5)
                                          │ ─sparkle 24─slide─in     │
                                          ├──────────────────────────┤
                                          │ scroll for breakdown...  │
                                          ├──────────────────────────┤
                                          │ [Cook Again ▶] glossy    │ ← P0 (R8)
                                          │ [Choose Other] [Menu]    │
                                          └──────────────────────────┘
시각 4/10                                  시각 8.5/10
```

### 4.3 Placeholder art 재활용
- **존재 art**:
  - 12 음식 hero anchors (R1 dish hero)
  - CH-01~05 + 5 mood swap (R2/R10)
  - NEW RECORD gold ribbon sprite (현재 작음, 확대 swap 가능)
  - 코인 아이콘 + 별 아이콘
- **신규 art 권고 (P1)**:
  - sparkle particle PNG (16 frame) — 4 screen 공통
  - steam particle PNG (cooking + result)
  - speech bubble round template

### 4.4 4 Goal 기여
| Goal | element | impact |
|------|---------|:---:|
| 정보 density | 6 row 색상 코드 + compat label | +2 |
| Hierarchy | Score hero bounce + NEW RECORD hero ribbon + CTA tier | +4 ← **largest gain** |
| Character | real avatar + face mood + breathing | +3 |
| Reward | coin spray + count-up + sparkle + friendship fill | +4 ← **largest gain** |

---

## 5. 4 Goal 종합 mapping (after redesign)

| Goal | 현 | 목표 | 주력 기여 screen |
|------|:--:|:--:|------|
| **정보 density** | 5/10 | 8/10 | Menu (R1/R10) + Cooking (R1/R9) + Result (R11) |
| **시각 hierarchy** | 4/10 | 8/10 | Menu (R1/R3/R5) + Result (R3/R5/R8) + Cooking (R4) |
| **character presence** | 2/10 | 8/10 | Guest (R1/R2/R3) + Result (R2/R10) + Cooking (R8) + Menu (R4) |
| **reward presentation** | 3/10 | 9/10 | Result (R3/R5/R6/R7) + Cooking (R3) + Menu (R6) |

---

## 6. 신규 시각 component (components.md v0.6 등록)

| ID | name | 용도 | 사용 screen |
|----|------|------|------|
| CP-33 | `glossy_button` | Royal Match-style gradient + inner highlight + outer lip 인터랙티브 button | 4 screen 공통 CTA |
| CP-34 | `drop_shadow_card` | Travel Town-style 12~16px Y-offset soft shadow ColorRect 또는 NinePatchRect | 4 screen 공통 card |
| CP-35 | `sparkle_particle` | GPUParticles2D 16 sparkle radial burst, 0.4s lifetime | PERFECT / NEW RECORD / best card |
| CP-36 | `character_idle_animator` | Tween scale 1.0→1.02 loop 2s + optional eye blink swap 4s | guest avatar (Guest/Result/Cooking) |
| CP-37 | `hero_number_bounce` | scale 0.5→1.2→1.0 bounce 0.6s + gold gradient + drop shadow + halo pulse | Score / compat % / coin count |
| CP-38 | `gold_ribbon_banner` | full-width 540×100 gold gradient ribbon + sparkle 24 + slide-in from top | NEW RECORD / TODAY'S PICK / milestone |
| CP-39 | `coin_spray_particle` | 20 coin GPUParticles2D from origin to HUD wallet position 1.5s tween | Result coin reward + Cooking PERFECT |
| CP-40 | `now_cooking_banner` | 상단 horizontal banner (dish thumb 80×80 + name + guest avatar 60×60 + "for X") | Cooking 8 module 공통 |
| CP-41 | `step_progress_dots` | ●○○○ 4 dot indicator (current = gold filled + scale 1.2) | Cooking step | 

> 상세 spec은 `components.md` v0.6에서 §22~30로 추가.

---

## 7. godot-dev Sprint Hand-off — 파일별 변경 list

### 7.1 Menu Select (`godot-project/scenes/menu_select.tscn` + `scripts/ui/menu_select.gd`)
| 작업 | priority | est |
|------|:--:|:--:|
| Today's Pick hero card 노드 추가 (Y 130~440 Panel + dish image TextureRect + ✨RECOMMENDED label) | P0 | 2h |
| 카드 dish image 영역 — placeholder TextureRect를 `assets-processed/foods/{food_id}.png` 동적 로드로 swap | P0 | 1h |
| 카드 drop shadow ColorRect (Y +12 offset, alpha 25%, modulate `shadow_warm`) + inner highlight Panel (top 20%) | P0 | 1h |
| CTA "Cook · Stock 3" → `CP-33 GlossyButton` 인스턴스로 교체 (gradient persimmon + 2px highlight + 2px lip) | P0 | 1h |
| 코인 HUD 32pt + gold pill BG + drop shadow | P1 | 30m |
| 카드 행간 16→24px (GridContainer add_theme_constant_override) + 카드 padding 12→20px | P0 | 15m |
| mini-badge halo glow (best card만, ColorRect circular + AnimationPlayer pulse 1Hz) | P1 | 30m |
| disabled 카드 "🔒 Locked at Lv N" pill overlay | P1 | 1h |

### 7.2 Guest Select (`godot-project/scenes/guest_select.tscn` + `scripts/ui/guest_select.gd` + `scripts/ui/guest_card_v2.gd`)
| 작업 | priority | est |
|------|:--:|:--:|
| avatar TextureRect — 단색 fill + Label "J" 제거, `assets-processed/characters/{char_id}.png` 로드 | P0 | 1h |
| `CP-36 CharacterIdleAnimator` Tween 부착 (Sprite2D pivot center) | P0 | 30m |
| mood badge 40→80px + 5 mood sprite swap (`assets-processed/moods/{char_id}_{mood}.png`) | P0 | 1h |
| speech bubble micro 추가 (Panel + Label + ▲ tail Polygon2D) — `Today I want X!` template | P1 | 1h |
| RECOMMENDED 띠 Z-order 75 → 150 (sub-bar 위로) + `CP-35 SparkleParticle` 인스턴스 부착 | P0 | 30m |
| compat % "93%" 24pt → 80pt + gradient gold + 2px stroke + drop shadow 6px | P0 | 30m |
| flavor tag pill redesign — `CP-33 GlossyButton` mini variant (32×24 + 2-letter abbr + glossy) | P1 | 2h |
| REWARD 띠 강조 — "+50% ₩ BONUS" 24pt bold + coin icon + green band | P0 | 30m |
| 카드 외곽 stroke 4→6px + best card gold halo (ColorRect circular 80px radius) | P1 | 30m |

### 7.3 Cooking Screen (`godot-project/scenes/cooking_module_runner.tscn` + 8 module scenes + `scripts/gameplay/cooking_module_runner.gd`)
| 작업 | priority | est |
|------|:--:|:--:|
| `CP-40 NowCookingBanner` 인스턴스 → cooking_module_runner.tscn 상단 Y 60~180 (8 module 공통) | P0 | 2h |
| 각 module scene (slice/arrange/stir/flip/roll/plate) 중앙 Y 400~800 dish-in-progress Sprite2D 노드 추가 (현 placeholder 대체) | P0 | 4h (8 module) |
| `CP-35 SparkleParticle` + "PERFECT!" 80pt Label bounce 0.6s scale + center reveal — `_perfect_burst()` 함수 강화 | P0 | 2h |
| 8 module CTA button → `CP-33 GlossyButton` + module-specific 아이콘 (TAP/STOP/FLIP/PRESS&HOLD) | P0 | 2h |
| timing module: ▼ indicator Sprite + gold zone halo ColorRect pulse 1Hz | P0 | 1h |
| slice module: CUT-00 도마 + CUT-01~06 칼 sprite swap (현 procedural 대체) | P0 | 1h |
| arrange module: 슬롯 hover gold ring pulse | P1 | 1h |
| guest mini-thumbnail 우하단 X 880~1040 Y 1500~1660 (160×160 avatar + idle breath) | P1 | 1h |
| `CP-41 StepProgressDots` 4 dot indicator → header 우측 | P0 | 1h |
| flip module: steam GPUParticles2D + sizzle particle | P1 | 1h |
| module transition cross-fade (Tween 0.4s + "Step Complete" toast) | P1 | 1h |

### 7.4 Result Screen v2 (`godot-project/scenes/ui/result_screen_v2.tscn` + sub-scenes + `scripts/ui/result_screen_v2.gd`)
| 작업 | priority | est |
|------|:--:|:--:|
| §1 dish hero — placeholder oval 제거, `assets-processed/foods/{food_id}.png` 460×460 + `CP-35 SparkleParticle` idle + steam particle | P0 | 1h |
| §4 avatar real char + `CP-36 CharacterIdleAnimator` + mood face swap 80×80 (Guest Select R1/R3 재사용) | P0 | 30m |
| Score number — Label "Score 8800" → `CP-37 HeroNumberBounce` scale 0.5→1.2→1.0 0.6s + gradient gold + halo | P0 | 1h |
| ★★★ star rating — 좌→우 fade 0.3s/별 + 마지막 별 sparkle burst (`CP-35`) + chime ring visual | P0 | 1h |
| NEW RECORD — `new_record_badge.tscn` → `CP-38 GoldRibbonBanner` 540×100 + sparkle 24 + slide-in from top + shake 0.5s | P0 | 1h |
| `reward_box.tscn` coin label → `CP-39 CoinSprayParticle` + count-up tween 1.5s (digit Label.text loop) | P0 | 1h |
| friendship bar fill Tween 1.0s + milestone toast `CP-35` sparkle 12 + scale bounce | P0 | 1h |
| Sticky CTA hierarchy — Cook Again primary `CP-33 GlossyButton` large + Choose Other secondary cream outlined + Menu tertiary text-only | P0 | 1h |
| speech bubble redesign — Panel round 16px + tail Polygon2D + Tween scale 1.0→1.01 pulse 2s loop | P1 | 30m |
| `score_breakdown_row.tscn` — bar fill Tween 0.5s sequential + row별 색상 (Prep blue / Cook orange / Season red / Plating green / Compat gold / Mood pink) | P1 | 1h |
| compat bar 풀폭 540px + 라벨 "PERFECT MATCH 93%" 28pt | P1 | 30m |

### 7.5 신규 component 구현 (`godot-project/scenes/ui/` + `scripts/ui/`)
| component | file | est |
|------|------|:--:|
| CP-33 GlossyButton | `scenes/ui/glossy_button.tscn` + `scripts/ui/glossy_button.gd` (gradient Panel + inner highlight Panel + outer lip ColorRect + Tween hover/press) | 2h |
| CP-34 DropShadowCard | `scenes/ui/drop_shadow_card.tscn` (ColorRect alpha 25% + Y offset 12) — single PackedScene, all card 적용 | 30m |
| CP-35 SparkleParticle | `scenes/ui/sparkle_particle.tscn` (GPUParticles2D 16 radial + lifetime 0.4s + texture sparkle.png placeholder) | 1h |
| CP-36 CharacterIdleAnimator | `scripts/ui/character_idle_animator.gd` (attach to Sprite2D, Tween scale 1.0→1.02 loop) | 30m |
| CP-37 HeroNumberBounce | `scenes/ui/hero_number_bounce.tscn` + script (Label + Tween scale 0.5→1.2→1.0 0.6s + halo Sprite + gradient shader) | 2h |
| CP-38 GoldRibbonBanner | `scenes/ui/gold_ribbon_banner.tscn` (NinePatchRect gold + sparkle particle + AnimationPlayer slide-in + shake) | 2h |
| CP-39 CoinSprayParticle | `scenes/ui/coin_spray_particle.tscn` (GPUParticles2D coin texture, 20 emit, Tween to HUD position) | 2h |
| CP-40 NowCookingBanner | `scenes/ui/now_cooking_banner.tscn` (HBoxContainer + dish thumb + name Label + guest avatar + "for X" Label) | 1h |
| CP-41 StepProgressDots | `scenes/ui/step_progress_dots.tscn` (HBoxContainer + N TextureRect dot + current = gold filled scale 1.2) | 1h |

### 7.6 sprint 총 estimate
- **P0 only**: ~32h (1 sprint 1주, godot-dev solo)
- **P0 + P1**: ~48h (1.5 sprint)
- **P0 + P1 + P2**: ~52h (1.5 sprint + P2 마무리)

---

## 8. Before/After Screenshot 캡처 plan (godot-dev 후속)

### 8.1 Before (이미 디스크 존재 — 캡처 불필요)
- Menu Select: `assets-raw/_screenshots/guest_v2/01_menu_select.png`
- Guest Select: `assets-raw/_screenshots/guest_v2/02_guest_select.png` + `03_guest_select_spec_locked.png`
- Cooking 8 module: `assets-raw/_screenshots/cooking_framework_v2/01~06_*.png`
- Result v2: `assets-raw/_screenshots/result_v2/01~04_*.png` (top + bottom 각 4개)

### 8.2 After (godot-dev 후속 sprint 종료 시 캡처)
- 디렉터리: `assets-raw/_screenshots/premium_v1/`
- shot script: 각 screen별 PackedScene + shot_*.tscn (`shot_menu.tscn` / `shot_guest.tscn` / `shot_cooking_*` / `shot_result_v2_launch.tscn` 기존 활용)
- 캡처 scenario:
  1. **Menu Select** — Lv 8 / 6 음식 / Tteokbokki = best 92% (TODAY'S PICK hero), Kimchi Stew = Lv 5 locked
  2. **Guest Select** — Kimchi Stew 선택 후, Junho 93% (RECOMMENDED + sparkle), 나머지 5인 비교
  3. **Cooking** — Tteokbokki / slice module Step 2/4 + PERFECT burst 순간 + Now Cooking banner + guest mini
  4. **Result v2** — Kimchi Stew + Junho 93% compat + Score 8800 + NEW RECORD ribbon + Milestone Lv 3 toast
- 비교 보고서: `docs/ui/before-after-premium-v1.md` (godot-dev 작성, A/B side-by-side image embed)

---

## 9. 후속 의존

| 의존 | 누구 | 무엇 | 시기 |
|------|------|------|------|
| Character idle breathing scale param 결정 | game-designer | 1.0→1.02 vs 1.0→1.05 / 2s vs 1.5s loop | M2 first week |
| dish-in-progress sprite (12 음식 × 4~8 module) | art-director | MVP는 hero anchor 단일 + module overlay 권고 | post-MVP backlog |
| sparkle particle PNG sprite sheet 16 frame | art-director | 4 screen 공통, MVP = simple PNG OK | this sprint |
| steam particle PNG | art-director | cooking + result 공통, MVP = simple white circle OK | this sprint |
| speech bubble round template | art-director | cream + brown stroke + ▲ tail, 1h 작업 | this sprint |
| coin texture (HUD spray용) | art-director | 기존 코인 아이콘 재활용 | already exists |
| analytics event for celebration FX | data-analyst | "perfect_burst_seen" / "new_record_celebrated" 카운트 | post-MVP |

---

## 10. Decisions Log
| # | 결정 | 근거 | 의존 |
|---|------|------|------|
| PR-1 | 4 screen 모두 placeholder art (단색 fill / 1-letter avatar) 즉시 제거, 기존 hero food + character anchor 재활용 | 시각 quality gap 가장 큰 원인 + art 이미 LOCK | godot-dev sprint 1주 |
| PR-2 | glossy 3D button + drop shadow + sparkle particle = MVP 전체 시각 baseline | Royal Match / Travel Town 공통 분모 + cost 낮음 | CP-33~35 신설 |
| PR-3 | character idle breathing 모든 avatar 강제 | character presence 가장 시급 (2/10) | CP-36 신설 |
| PR-4 | reward celebration (PERFECT / NEW RECORD / coin spray)는 Cooking + Result 핵심 hook | Cooking Madness benchmark + 현 점수 3/10 | CP-37~39 신설 |
| PR-5 | Menu Select에 Today's Pick hero card 신설 | Royal Match goal card + 5-sec rule 충족 | M2 menu_select.gd 수정 |
| PR-6 | Cooking 8 module 공통 NowCookingBanner + StepProgressDots | dish + guest 항상 visible (현재 부재) + 진행감 | CP-40/41 신설 |
| PR-7 | Result Sticky CTA tier 3단계 (primary glossy / secondary outlined / tertiary text) | Royal Match next-level CTA pattern + hierarchy 약점 해결 | CP-33 large variant |
| PR-8 | shot_*.tscn 기존 캡처 스크립트 재활용 + after screenshot은 `assets-raw/_screenshots/premium_v1/` | 기존 godot-dev workflow 정합 | sprint 종료 시 |

---

## 11. Open questions

1. **dish-in-progress sprite** — MVP scope 안에 12 음식 × 4~8 module = 60~96 sprite 신규 art 가능한가? (현 권고 = hero anchor 단일 활용 + module visual은 overlay/particle/CTA로 다양화)
2. **PERFECT burst sparkle PNG** — placeholder 흰색 원으로 시작 OK? art-director sprint 동시 진행?
3. **speech bubble template** — art-director 1h 작업 vs godot-dev procedural Polygon2D? (권고: procedural MVP, art polish post-MVP)
4. **NEW RECORD shake effect** — 0.5s shake 가속도 강도 game-designer 조정 필요? (권고: amplitude 4px, frequency 30Hz default)
5. **Menu Select Today's Pick rotation logic** — 매번 best compat? 매일 1회 셔플? (gameplay 무변경 원칙 → 매번 best compat, score 계산 X)
