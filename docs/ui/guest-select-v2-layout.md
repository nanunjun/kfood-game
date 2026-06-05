# Guest Select v2 — Layout Spec (Guest System 2.0)

> 버전: **v0.1** · 갱신일: 2026-06-04 · 작성자: ui-designer
> 상위 문서: [`screen-flow.md` v0.4](screen-flow.md), [`components.md` v0.4](components.md), [`food-select-compat.md` v0.1](food-select-compat.md), [`../friends-system.md` v0.3](../friends-system.md), [`../phase1/guest-select-ui.md`](../phase1/guest-select-ui.md) (v1 supersede)
> 관련: `godot-project/scenes/guest_select.tscn` + `scripts/ui/guest_select.gd`
> Scope: **Guest 2.0** — guest_select.tscn 전면 재설계. Food Select 직후 진입, 6개 정보 (avatar / friendship / likes / dislikes / today's mood / reward bonus) + 음식별 compat % 시각화.
>
> **카드 layout 옵션 비교 + 채택 (옵션 A) + sketch + zone 좌표 + state**. 데이터/공식은 game-designer 위임 (mood 5종 + reward_bonus 산출은 신규 spec 필요).

---

## 0. 핵심 결정

| # | 결정 | 근거 |
|---|------|------|
| GS-1 | **layout = 옵션 A (2-column grid, 카드 압축형)** 채택 | 5+게스트 동시 비교(누가 best?) 1-thumb scroll, 정보 6종 + compat 모두 fit. 옵션 B/C 비교 §1 |
| GS-2 | **카드 크기 = 510×680** (현 470×360 확장) | 정보 6종 + compat % + reward bonus 모두 수직 stack, 1-thumb scroll OK |
| GS-3 | **compat %는 카드 우상단 large badge** + 카드 외곽 색상 sync | 5-second rule — 한눈에 best guest 인식 |
| GS-4 | **mood badge = avatar overlay (우하단 작은 원)** | avatar identity 유지하면서 daily 변화 즉각 인지 |
| GS-5 | **likes/dislikes = horizontal tag cluster** (avatar 하단) | 3+2 = 최대 5개 tag, 한 줄 가로 fit |
| GS-6 | **reward bonus = 카드 하단 띠 (배경색 + 큰 텍스트)** | "왜 이 손님인가" 선택 motivation, CTA 바로 위 |
| GS-7 | **Auto Select 제거** (food 별로 best compat 자동 추천 → Recommended 배지 1장) | UX 단순화, 사용자가 의도적 선택. best 카드만 ✨RECOMMENDED 띠 |

---

## 1. Layout 옵션 비교

### 옵션 A — 2-column grid (압축형 카드) ✅ 채택

```
┌────────────┐ ┌────────────┐
│ Card 510×  │ │ Card 510×  │
│  680       │ │  680       │
└────────────┘ └────────────┘
┌────────────┐ ┌────────────┐
│   ...      │ │   ...      │
└────────────┘ └────────────┘
```

| Pros | Cons |
|------|------|
| 5+ 게스트 동시 비교 (한눈에 best compat) | 카드당 정보 압축 → 폰트 25~30pt 필요 |
| 1-thumb scroll 친화 (수직만) | 카드 폭 510px = 1080-2col-padding |
| 현 guest_select.gd 구조 유지 (수정 적음) | reward bonus 띠 등 6 정보 stack 디자인 필수 |

**판정**: ✅ **best fit for MVP 5+ guest scale**.

### 옵션 B — 단일 카드 carousel (큰 카드 1개 + swipe)

```
        ◀  ┌─────────────┐  ▶
           │ Big Card    │
           │ 880 × 1300  │
           │ (1 guest)   │
           └─────────────┘
        · · · ● · · · ·  (page dots)
```

| Pros | Cons |
|------|------|
| 정보 6종 + compat 시각화 풍성 (큰 avatar, 큰 mood) | **동시 비교 불가** → 5+ guest 중 best 찾기 swipe 5회 |
| 정서 강함 (어머니 fullshot) | 5-second rule 위배 (swipe scan) |
| | post-launch 친구 10명 추가 시 swipe 10회 |

**판정**: ❌ Tier 2 가족 2~3명만 등장 시점은 OK이나 post-launch 확장에서 cost ↑. MVP는 비교 가능성 우선.

### 옵션 C — 리스트 (가로 row, 5 정보 horizontal)

```
┌──────────────────────────────────────┐
│ [av] Mina  ★★★☆☆  🌶🍬 ❌🧂  😋  +15% │
└──────────────────────────────────────┘
┌──────────────────────────────────────┐
│ [av] Junho ★★★★☆  🌶🧂 ❌🍬  😐  +5%  │
└──────────────────────────────────────┘
```

| Pros | Cons |
|------|------|
| 1080px 폭 활용 → 정보 row 가로 fit | 가로 너무 dense → 5-second 스캔 어려움 |
| 5~10 guest 수직 fit (대량 확장 친화) | avatar 작아짐 (60×60), 정서 ↓ |
| | mobile 1-thumb 좌측~우측 끝 정보 시인성 ↓ |

**판정**: ❌ post-launch 친구 10명 confirm 시 재고. MVP는 카드 시인성 우선.

---

## 2. 채택 layout — 옵션 A 상세 (510×680 카드)

### 2.1 화면 전체 (1080×1920 portrait)

```
┌────────────────────────────────────────────────────────┐
│ 상단 HUD (Y 0~120):  💰 1,240   ❤️❤️❤️   Lv.7   ⏸     │ Z 100
├────────────────────────────────────────────────────────┤
│ Y 130~250: Title                                       │
│   "Who's eating Kimchi Stew?"                          │
│   "김치찌개 — 누가 먹을까요?"  (한글 sub)              │
├────────────────────────────────────────────────────────┤
│ Y 260~330: Sub-bar                                     │
│   [‹ Back]            [🔥 Best: Mina 92%] (info pill) │
├────────────────────────────────────────────────────────┤
│ Y 340~1820: ScrollContainer (2-col grid)               │
│                                                        │
│   ┌──────────┐  ┌──────────┐                           │
│   │ Card 1   │  │ Card 2   │  ← 510 × 680              │
│   │ Mina     │  │ Junho    │     h_sep 30 / v_sep 30   │
│   │ 92% MATCH│  │ 63% OK   │                           │
│   └──────────┘  └──────────┘                           │
│   ┌──────────┐  ┌──────────┐                           │
│   │ Card 3   │  │ Card 4   │                           │
│   │ Riley    │  │ Mrs.Lee  │                           │
│   │ 48% LOW  │  │ 75% GOOD │                           │
│   └──────────┘  └──────────┘                           │
│   ┌──────────┐                                         │
│   │ Card 5   │                                         │
│   │ Seoyeon  │                                         │
│   │ 80% GOOD │                                         │
│   └──────────┘                                         │
│                                                        │
├────────────────────────────────────────────────────────┤
│ Y 1830~1920: bottom safe area (banner ad excluded —   │
│              gameplay flow)                            │
└────────────────────────────────────────────────────────┘
```

### 2.2 카드 zone 좌표 (510×680, 카드 내부 origin (0,0))

```
┌────────────────────────────────────────────┐ ← Card 510×680
│ Y 0~80:  ┌──────────────┐  ┌─────────┐   │
│          │ Compat Badge │  │ FRIENDS │   │  ← (1) compat % badge (large)
│          │  92% MATCH   │  │ ★★★☆☆  │   │     (2) friendship stars
│          └──────────────┘  └─────────┘   │
│          (X 16~280 Y 16~80)              │
│          (X 296~494 Y 16~64)             │
├────────────────────────────────────────────┤
│ Y 100~340: AVATAR (240×240, center)       │  ← (3) avatar (chibi bust)
│          X 135~375 Y 100~340             │     Position: center (X 255)
│                                  ┌──┐    │
│                                  │😋│    │  ← (4) mood badge overlay
│                                  └──┘    │     (X 320~390 Y 270~340)
│                                          │
├────────────────────────────────────────────┤
│ Y 360~410: NAME                          │
│          "Mina (미나)" 36pt center        │
├────────────────────────────────────────────┤
│ Y 430~485: LIKES row                      │  ← (5a) likes 3 tags
│   "Likes:  🌶 Spicy  🍬 Sweet  🥒 Crisp" │
├────────────────────────────────────────────┤
│ Y 495~550: DISLIKES row                   │  ← (5b) dislikes 2 tags
│   "Avoids: ❌🧂 Salty  ❌🥩 Fatty"        │     (red ❌ overlay)
├────────────────────────────────────────────┤
│ Y 570~640: REWARD BONUS band              │  ← (6) reward bonus
│   ┌──────────────────────────────────┐   │     full-width band
│   │  ⭐ +15% Reward (₩+1,800)        │   │     gradient gold BG
│   └──────────────────────────────────┘   │
├────────────────────────────────────────────┤
│ Y 650~680: CTA "Cook for Mina ▶"         │  ← Primary button
│   gochujang red, 38pt                    │     (carries compat color trim)
└────────────────────────────────────────────┘
```

### 2.3 카드 외곽 색상 (compat % 매핑)

| compat % | 외곽 border | 카드 BG tint | tag label |
|----------|------------|--------------|-----------|
| 90~100% | Gold `#FFC857` 6px + glow | Cream + 5% gold | **PERFECT MATCH** |
| 75~89% | Green `#7DB76F` 5px | Cream | **GOOD MATCH** |
| 50~74% | Yellow `#E8C547` 4px | Cream | **OK** |
| 30~49% | Orange `#F4A261` 3px | Cream + 3% gray | **LOW** |
| <30% | Red `#E63946` 3px + dashed | Cream + 5% gray | **BAD MATCH** |

> 외곽 색상 = compat color (CP-24 spec sync). 한눈에 best guest 인식.

### 2.4 ✨ RECOMMENDED 띠 (best card only)

```
┌────────────────────────────────────────┐
│  ✨ RECOMMENDED FOR THIS DISH  ✨      │ ← Y -28 (카드 top 위 28px overlap)
└─┬──────────────────────────────────────┘    gold gradient BG, 28pt white text
  │ Card                                      pulse 1Hz subtle scale 1.0→1.02
```

- best compat % 카드 1장 한정 (5+ guest 중 max).
- best 끼리 동률(±2%) 시 friendship 높은 쪽 우선.
- ✨ 띠는 카드 위 28px overlap, scroll 시 함께 이동.

---

## 3. 정보 요소 6종 상세 spec

### 3.1 Avatar (240×240, center)

| 항목 | 값 |
|------|-----|
| 비율 | 정사각 1:1, 240×240px (chibi bust-up, 어깨 위까지) |
| Position | X 135~375 Y 100~340 (카드 중앙 상단) |
| Art anchor | CH-01~05 (mother/father는 친구 카드와 별도 anchor) |
| Placeholder (현재) | tinted circle (현 `AVATAR_TINT` dict) + 이름 첫 글자 64pt |
| Border | 6px round (외곽 = compat color) |
| Hover (long-press) | 1.05× scale + 외곽 Gold halo glow |

### 3.2 Friendship Level (우상단, 296~494 Y 16~64)

| 항목 | 값 |
|------|-----|
| 형식 | "FRIENDS" 라벨 12pt + `★★★☆☆` 28pt (0~5 stars) |
| 색상 | Sesame Gold `#FFC857` filled / Cream `#F8E9D2` empty |
| 데이터 | `SaveManager.intimacy_of(gid)` floor (0~5 정수) |
| 표시 | 카드 우상단 (compat badge와 같은 행, 카드 폭 절반씩 분할) |
| state | filled stars >= 4 시 reaction sparkle 0.3s loop 1Hz |
| 호환 | post-launch 6~10 friendship 확장 시 `★★★★★⁺` (+ heart) 표기 |

> game-designer: friendship → likes/dislikes 변동(레벨 올라가면 mood 변화 폭) 후속 spec 필요. UI는 0~5 표시만.

### 3.3 Likes (Y 430~485, 3 tags horizontal)

| 항목 | 값 |
|------|-----|
| 형식 | "Likes:" 라벨 22pt + tag badge × 1~3 |
| Tag badge | icon (32px) + 라벨 (20pt) 가로 = 110×40px each, h_sep 12 |
| Tag colors | spicy=`#E63946` / sweet=`#F4A2C7` / salty=`#7AB7E0` / oily=`#C9A567` / mild=`#A8C77E` / umami=`#8A6B4A` |
| Icons | spicy 🌶 / sweet 🍬 / salty 🧂 / oily 🥩 / mild 🥒 / umami 🍄 |
| 데이터 | game-designer `friends-system.md` §3.3 `like` axis (5종 중 1~3개) |
| placeholder | 현 `vec` dominant axis만 노출 → spec 잠금 후 like[] / dislike[] 분리 |

### 3.4 Dislikes (Y 495~550, 2 tags horizontal)

| 항목 | 값 |
|------|-----|
| 형식 | "Avoids:" 라벨 22pt + tag badge × 1~2 |
| Tag badge | 동일 110×40px, **빨간 ❌ overlay 우상단** (16×16, opacity 90%) |
| 채도 | tag color 채도 -30% (dislike 시각 약화) |
| 데이터 | `friends-system.md` §3.3 `dislike` axis (5종 중 1~2개) |

### 3.5 Today's Mood (avatar 우하단 overlay, 70×70)

| Mood | Icon | 효과 | 카드 색조 |
|------|:----:|------|----------|
| **hungry** | 😋 | compat % +5% / reward +5% | gold tint |
| **happy** | 😍 | compat % +3% / reward +10% | pink tint |
| **easy** | 🙂 | 영향 없음 (default) | neutral |
| **picky** | 😐 | compat % -5% / reward -5% | gray tint |
| **grumpy** | 😡 | compat % -10% / reward -10% | red tint |

| 항목 | 값 |
|------|-----|
| Position | avatar 우하단 overlap (X 320~390 Y 270~340) |
| Size | 70×70 circle, white border 3px, mood color BG |
| Icon | 48pt emoji 또는 SVG (icon-first per i18n lock) |
| Tooltip (long-press) | mood 이름 + 효과 ("Hungry! Reward +5%") |
| 데이터 | game-designer **mood rotation spec 위임** — daily seed or per-round random |

> ⚙️ game-designer: mood 5종 매핑 + daily/per-round rotation 결정 필요. UI는 5종 icon + 효과 매핑만 spec.

### 3.6 Reward Bonus (Y 570~640, full-width band)

| 항목 | 값 |
|------|-----|
| 형식 | full-width band 478×70px (X 16~494) |
| BG | gradient (compat color → lighter shade, horizontal) |
| 텍스트 | "⭐ +15% Reward" 28pt bold + "(₩+1,800)" 22pt sub |
| 색상 | 텍스트 white + drop shadow 1px |
| 데이터 | base_reward × (1 + bonus%) = compat + friendship + mood 합산 |
| state | bonus ≥ 20% 시 ★ particle 1초 1회 sparkle |

> ⚙️ game-designer: reward_bonus 공식 정의 필요. UI는 % + ₩ 표기만.

---

## 4. State 전환

| State | 트리거 | 시각 |
|-------|-------|------|
| **default** | scene enter | 카드 idle |
| **enter** | scene enter t=0~0.4s | 카드 좌→우 cascade fade-in 0.1s offset per card |
| **best card pulse** | best compat 카드 한정 | ✨RECOMMENDED 띠 1Hz scale 1.0→1.02 loop |
| **hover (long-press 0.3s)** | tap hold | 카드 1.03× + Gold halo |
| **pressed** | tap release | 0.95× flash 0.1s + transition out |
| **disabled** (post-launch friendship lock) | friendship 0 + lock 조건 | 회색 + 🔒 자물쇠 + "Reach Friendship Lv 2 to unlock" |

---

## 5. Z-order (Guest Select Scene)

| 요소 | Y range | Z |
|------|--------|---|
| BG (MarketBG) | full | 0 |
| HUD | Y 0~120 | 100 |
| Title + Sub-bar | Y 130~330 | 90 |
| ScrollContainer | Y 340~1820 | 50 |
| Card (510×680) | inside scroll | 50 |
| Avatar / Friendship / Likes / Dislikes / Reward band | inside card | 60 |
| Compat badge | inside card top | 65 |
| Mood badge overlay on avatar | inside card | 70 |
| ✨RECOMMENDED 띠 (best only) | card top -28 | 75 |
| Modal / Toast | full overlay | 200 |

---

## 6. Cross-screen state (Food → Guest)

```
[Menu Select tap "Cook"]
   ├─ RhythmRound.pending_menu_id = menu_id   (existing)
   ├─ GuestSelect.pending_menu_id = menu_id   (existing)
   └─ (NEW) GuestSelect.last_food_compat = {gid -> compat%}  ← precompute 1회
       │
       │ guest_select._ready() 시 compat % 카드별 표시
       │ best guest 자동 식별 → ✨RECOMMENDED 띠
       ▼
[Guest Select scene enter]
   ├─ for gid in selectable_guest_ids():
   │     compat = CompatCalc.score(menu_id, gid)  ← game-designer 공식
   │     friendship = SaveManager.intimacy_of(gid)
   │     mood = MoodSystem.today(gid)             ← game-designer 위임
   │     reward = base × (1 + bonus(compat, friendship, mood))
   │     card.set(avatar, friendship, likes, dislikes, mood, reward, compat)
   └─ best_gid = argmax(compat) → card.show_recommended_badge()
```

> 상세 cross-screen passing은 `food-select-compat.md` §4 참조.

---

## 7. 접근성 / 안전영역

- **One-thumb**: CTA "Cook for X" 카드 하단 (Y 650~680), 카드 자체 = 510px = 1-thumb 도달 OK.
- **5-second rule**: 카드 외곽 색상(compat) + ✨RECOMMENDED 띠로 best guest 즉시 식별.
- **Color-blind**: compat 시각은 **색상 + 텍스트 라벨 (PERFECT/GOOD/OK/LOW/BAD)** 이중. mood는 **icon + 텍스트** 이중.
- **Bottom safe area**: Y 1830~1920 (Android nav bar) 비워둠.
- **i18n lock**: 모든 라벨 영어 primary + 한글 sub. mood/tag = icon-first.

---

## 8. art-director / game-designer dependency

| 의존 항목 | 담당 | M2 lock 필요 |
|----------|------|-------------|
| Mood 5종 icon (😋😍🙂😐😡) | art-director or SVG library | M2 alpha |
| Tag icon 6종 (🌶🍬🧂🥩🥒🍄) | art-director | M2 alpha |
| Friend avatar (junho/mina/riley/mrs_lee/seoyeon) chibi bust | art-director sprint 2 | placeholder OK MVP |
| ✨ RECOMMENDED 띠 ribbon art | art-director | M2 alpha (SVG OK) |
| compat 공식 (0~100%) | **game-designer** | M2 lock — `food-select-compat.md` §2 spec |
| mood rotation 공식 | **game-designer** | M2 lock — daily seed or per-round |
| reward bonus 공식 | **game-designer** | M2 lock — compat×friendship×mood 합산 |
| likes/dislikes axis → 3+2 표시 lift | **game-designer** | guest CSV에 `likes[]`/`dislikes[]` 컬럼 신설 (현 `vec`는 score용) |

---

## 9. godot-dev 후속 spec

- `guest_select.tscn` v2 = 신 layout (현 procedural script 유지 가능, 또는 PackedScene으로 전환).
- `guest_select.gd` v2:
  - `pending_menu_id` 유지 (Food → Guest passing).
  - 신규: `_compute_compat(menu_id, guest_id) -> int` (game-designer 공식 import).
  - 신규: `_today_mood(guest_id) -> String` (mood system import).
  - 신규: `_make_card_v2(guest, compat, friendship, mood, reward)` — §2.2 zone 정확 매핑.
  - 신규: `_show_recommended_badge(card)` — best card 한정.
- 신규 Autoload (제안): `CompatCalc.gd` + `MoodSystem.gd` (game-designer가 공식 lock 후 godot-dev 구현).
- 컴포넌트 CP-23~27 (`components.md` v0.4) Godot Scene 매핑 — 신규 `scenes/ui/guest_card_v2.tscn` / `compat_bar.tscn` / `flavor_tag_badge.tscn` / `mood_badge.tscn` / `reward_bonus_badge.tscn`.

---

## 10. Decisions Log

| # | 결정 | 근거 |
|---|------|------|
| GS-1 | layout = 옵션 A 2-col grid | 5+ guest 동시 비교, 1-thumb scroll |
| GS-2 | 카드 510×680 | 6 정보 + compat % 수직 stack fit |
| GS-3 | compat % 우상단 large badge + 카드 외곽 색상 sync | 5-second rule, 한눈 인식 |
| GS-4 | mood badge = avatar 우하단 overlay | identity 유지 + daily 변화 인지 |
| GS-5 | likes/dislikes = horizontal tag cluster | 3+2 = 5 tags 가로 fit |
| GS-6 | reward bonus = full-width 띠 (compat color gradient) | CTA 바로 위, 선택 motivation 강화 |
| GS-7 | Auto Select 제거 → best card ✨RECOMMENDED 띠 | 의도적 선택 UX, best 추천 보존 |

---

## 11. 변경 이력
- **2026-06-04 v0.1** — Guest 2.0 sprint 초안. 6 정보 (avatar/friendship/likes/dislikes/mood/reward) + compat % 시각화 spec. 옵션 A 채택 (2-col grid 510×680). zone 좌표 + state + cross-screen passing + dependency. game-designer mood/reward 공식 + likes/dislikes 분리 컬럼 위임. components CP-23~27 신설 (`components.md` v0.4 sync).
