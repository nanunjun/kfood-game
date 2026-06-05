# Food Select — Compatibility 표시 Spec

> 버전: **v0.1** · 갱신일: 2026-06-04 · 작성자: ui-designer
> 상위 문서: [`screen-flow.md` v0.4](screen-flow.md), [`components.md` v0.4](components.md), [`guest-select-v2-layout.md` v0.1](guest-select-v2-layout.md), [`../friends-system.md` v0.3](../friends-system.md)
> 관련: `godot-project/scenes/menu_select.tscn` + `scripts/ui/menu_select.gd`
> Scope: **Food Select (menu_select.tscn)** 에서 compat % 표시 + Food → Guest 정보 passing.
>
> Guest Select v2 (`guest-select-v2-layout.md`)와 짝. 본 문서는 **Food Select 측 compat 시각화** + **flow 결정 (선 음식, 후 게스트)** + **passing 구조**.

---

## 0. 핵심 결정

| # | 결정 | 근거 |
|---|------|------|
| FC-1 | **flow = 선 음식 → 후 게스트** (현 flow 유지) | 현 menu_select.tscn → guest_select.tscn 흐름 변경 X, lift 최소 |
| FC-2 | **Food Select 카드에 "best guest preview" mini-badge 추가** | 음식 선택 직전에 "이 음식 → 어머니 best 92%" 미리보기, 선택 motivation |
| FC-3 | **Guest Select 카드에 "이 음식 compat %" large badge** (primary) | 음식 1개 → 게스트 N개 비교가 main 의사결정 |
| FC-4 | **compat 시각화 = bar + 컬러 + 텍스트 라벨** 삼중 (CP-24) | 5-second rule + color-blind safe |
| FC-5 | **compat % 범위 매핑 = 5 tier** (PERFECT 90+/GOOD 75+/OK 50+/LOW 30+/BAD <30) | 5 axis 정합, friends-system §3 5-axis 색상 sync |
| FC-6 | **mini-badge 위치 = Food card 우상단 chip 자리** (현 evaluator/guest chip 자리 재활용) | 현 menu_select.gd `chip` 노드 재사용, 디자인 일관 |

---

## 1. Food Select 측 — 음식 카드 compat preview

### 1.1 현 menu_select.gd 카드 구조 (470×500)

```
┌────────────────────────────────────────┐ ← Food card 470×500
│ ┌──┐                          ┌────┐   │ ← top row: Lv tag + guest chip
│ │Lv│                          │ 👤 │   │
│ └──┘                          └────┘   │
├────────────────────────────────────────┤
│                                        │
│    [ Food illustration plate ]         │
│      (398×250)                         │
│                                        │
├────────────────────────────────────────┤
│ "Kimchi Stew (김치찌개)"               │ ← name
│ "Junho: Bring it on..." (hint)         │ ← guest hint
├────────────────────────────────────────┤
│ [ Cook · Stock 3 ]                     │ ← CTA (gochujang red)
└────────────────────────────────────────┘
```

### 1.2 v2 추가 요소 — "Best Guest Preview" mini-badge

현 chip (X 372 Y 14, 84×84 원형) 위치 그대로 활용, 표시 내용만 변경:

```
┌────────────────────────────────────────┐
│ ┌──┐                       ┌────────┐  │
│ │Lv│                       │ [av]   │  │ ← guest avatar (60×60)
│ └──┘                       │  92%   │  │   + compat % 24pt
│                            └────────┘  │   외곽 = compat color
│                            "Best:Mina" │ ← caption 18pt
│    [ Food illustration ]               │
│                                        │
└────────────────────────────────────────┘
```

| 항목 | 값 |
|------|-----|
| Position | 카드 우상단 X 360~470 Y 14~120 (현 chip Y 14~98 확장) |
| Size | 110×106 (chip 84→100 + caption 18pt row) |
| BG | rounded rect 24px, BG = compat color (PERFECT=gold/GOOD=green/OK=yellow/LOW=orange/BAD=red) |
| Content | (1) guest avatar 60×60 원 + (2) "92%" 24pt bold + (3) "Best: Mina" 18pt caption 한 줄 |
| Tooltip (long-press) | "Mina loves spicy. 92% match." |
| Evaluator level | evaluator 있을 때 = chip 그대로 (purple ring "⭐ Watching" — 기존 디자인) |
| state | best compat ≥ 90% → 1Hz sparkle pulse |

> **결정 FC-6**: 카드 디자인 변경 최소화. 현 chip 자리 재활용 → "고민 없이 어디로 보낼지 미리보기".

### 1.3 정보 비공개 옵션 (디자인 옵션)

⚙️ **option toggle (game-designer 결정 필요)**:
- 옵션 1: 항상 mini-badge 노출 (음식 → guest 매칭 hint 항상 visible)
- 옵션 2: friendship Lv 1+ 게스트만 mini-badge 노출 (1회 cook 후 unlock)
- 옵션 3: FTUE 5분 이후 mini-badge unlock (FTUE 동안 단순화)

**ui-designer 권고**: **옵션 2** (friendship 1+ unlock). 신규 게스트는 "?" mini-badge로 가린 상태 → cook 1회 후 compat 노출 → discovery 동기 + 첫 cook은 "탐색"으로 의도.

---

## 2. Compatibility 공식 (game-designer 위임 — UI 측 가정)

UI는 0~100% int 가정. 공식 자체는 game-designer 위임. **추정 공식 (game-designer confirm 필요)**:

```
compat = base_match(food.axis, guest.like_axis, guest.dislike_axis) 
       + friendship_bonus(intimacy)
       + mood_modifier(today_mood)

// base_match = like_axis 매치율 - dislike_axis 매치율 (0~80 range)
// friendship_bonus = intimacy × 2 (0~10)
// mood_modifier = mood table (-10~+10)
// clamp 0~100
```

예시 (friends-system §3.6 net 효과 활용):
- Kimchi Stew (spicy+salty+mild) → Mina (spicy=like, sweet=like, salty=neutral, mild=neutral) → 
  base = 2/3 like = 67% + friendship 4 (★★★★☆) ×2 = +8 + mood happy +3 = **78%**
- Kimbap (salty+mild) → Mina (mild=neutral, salty=neutral) → 
  base = 0 like match = 30% baseline + friendship 4 ×2 = +8 + mood happy +3 = **41%**

> 본 예시는 추정. **game-designer가 `compat_score(menu_id, guest_id) -> int` 함수 lock 필요**.

### 2.1 시각 매핑 (CP-24 compat_bar spec sync)

| compat % | 라벨 | 컬러 | bar fill | 카드 외곽 | 띠 |
|----------|------|------|---------|----------|-----|
| 90~100 | **PERFECT MATCH** | Gold `#FFC857` + 빗금 | 90~100% gold | 6px gold + glow | ✨RECOMMENDED (best 1장) |
| 75~89 | **GOOD MATCH** | Green `#7DB76F` | 75~89% green | 5px green | - |
| 50~74 | **OK** | Yellow `#E8C547` | 50~74% yellow | 4px yellow | - |
| 30~49 | **LOW** | Orange `#F4A261` | 30~49% orange | 3px orange | - |
| 0~29 | **BAD MATCH** | Red `#E63946` + dashed | 0~29% red | 3px red dashed | "⚠ Not a fit" |

---

## 3. Guest Select 측 — compat large badge (primary)

> `guest-select-v2-layout.md` §2.2 zone과 동일. 본 절은 cross-reference.

```
Card 510×680, top-left zone X 16~280 Y 16~80:

┌──────────────────────────┐
│  92% MATCH               │ ← compat % 36pt bold + 라벨 18pt
│  ▓▓▓▓▓▓▓▓▓▓░░░          │ ← compat bar (CP-24, full inside badge)
│                          │
└──────────────────────────┘
   gold BG + glow (PERFECT)
```

| 항목 | 값 |
|------|-----|
| Size | 264×64 (X 16~280 Y 16~80) |
| 형식 | "92%" 36pt + "MATCH" 라벨 18pt 한 행, bar 8px 하단 |
| BG | compat color filled, rounded 16px |
| Glow | PERFECT(90+) 한정 Gold halo 1Hz pulse |
| 외곽 | white border 2px |

---

## 4. Cross-screen state passing (Food → Guest)

### 4.1 현 구조 (v1)

```gdscript
# menu_select.gd _on_pick
RoundScript.pending_menu_id = menu_id
RoundScript.pending_guest_id = ""
if evaluator level:
    change_scene_to_file("rhythm_proto.tscn")
else:
    GuestSelectScript.pending_menu_id = menu_id
    change_scene_to_file("guest_select.tscn")
```

### 4.2 v2 추가 passing (Guest 2.0)

```gdscript
# menu_select.gd v2 _on_pick (식별 변경 없음)
GuestSelectScript.pending_menu_id = menu_id   # existing
# compat은 guest_select가 _ready()에서 menu_id 기반으로 자체 계산
# → 추가 passing 변수 불필요 (low coupling)

# menu_select.gd v2 _make_card (mini-badge 표시용)
for menu in all menus:
    best_gid = CompatCalc.best_guest(menu_id)
    best_compat = CompatCalc.score(menu_id, best_gid)
    card._set_mini_badge(best_gid, best_compat)  # 신규
```

### 4.3 guest_select.gd v2 _ready()

```gdscript
func _ready() -> void:
    var menu_id = pending_menu_id
    var best_gid = ""
    var best_compat = -1
    
    for gid in MenuDB.selectable_guest_ids():
        var compat = CompatCalc.score(menu_id, gid)      # 0~100
        var friendship = sm.intimacy_of(gid)              # 0~5
        var mood = MoodSystem.today(gid)                  # "hungry"/"happy"/...
        var reward = RewardCalc.bonus(compat, friendship, mood)  # +X%
        var card = _make_card_v2(gid, compat, friendship, mood, reward)
        grid.add_child(card)
        if compat > best_compat:
            best_compat = compat
            best_gid = gid
    
    # ✨RECOMMENDED 띠 best card 한정
    _show_recommended(best_gid)
```

### 4.4 Autoload 신규 (game-designer + godot-dev sync)

- **`CompatCalc.gd`** (Autoload): `score(menu_id, guest_id) -> int`, `best_guest(menu_id) -> String`
- **`MoodSystem.gd`** (Autoload): `today(guest_id) -> String` (daily seed 또는 per-round random — game-designer 결정)
- **`RewardCalc.gd`** (Autoload 또는 helper): `bonus(compat, friendship, mood) -> int` (% int 반환)

---

## 5. Flow 다이어그램 (Food → Guest, v2)

```
┌──────────────────────────────────────────┐
│ Menu Select (menu_select.tscn)           │
│ ┌─────────┐ ┌─────────┐                  │
│ │Food 1   │ │Food 2   │                  │
│ │ [Lv][?] │ │ [Lv][👤]│  ← chip = best   │
│ │ 🍜      │ │ 🍲      │     guest mini   │
│ │ Ramen   │ │ Kimchi  │     (92% / 78%)  │
│ │ [Cook]  │ │ [Cook]  │                  │
│ └─────────┘ └─────────┘                  │
└────────────────┬─────────────────────────┘
                 │ tap "Cook" → pending_menu_id = "t2_xxx"
                 ▼
┌──────────────────────────────────────────┐
│ Guest Select (guest_select.tscn v2)      │
│ Title: "Who's eating Kimchi Stew?"       │
│ ┌─────────┐ ┌─────────┐                  │
│ │Mina     │ │Junho    │                  │
│ │ 92%🌟   │ │ 63% OK  │  ← compat badge  │
│ │ [av]😋  │ │ [av]😐  │     +mood overlay│
│ │ Likes:  │ │ Likes:  │                  │
│ │ Dislike │ │ Dislike │                  │
│ │ +15% rew│ │ +5% rew │                  │
│ │ [Cook ▶]│ │ [Cook ▶]│                  │
│ └─────────┘ └─────────┘                  │
│ ✨ Mina = RECOMMENDED                    │
└────────────────┬─────────────────────────┘
                 │ tap "Cook for X" → pending_guest_id = gid
                 ▼
┌──────────────────────────────────────────┐
│ Rhythm Round (rhythm_proto.tscn)         │
│ (gameplay 변경 X)                        │
└──────────────────────────────────────────┘
```

---

## 6. Back navigation

- Guest Select `‹ Back` → Menu Select. **pending_menu_id 유지** (다시 다른 게스트 선택 가능).
- 또는 Menu Select에서 다른 음식 선택 시 pending_menu_id overwrite.
- Round 진입 후 Back은 cooking-mechanics 정합 (현 flow 그대로).

---

## 7. 접근성

- compat 시각 = **컬러 + 텍스트 라벨 + bar fill ratio** 삼중 (color-blind safe).
- mini-badge tap → tooltip ("Mina loves spicy. 92% match.").
- mini-badge font ≥ 18pt (one-thumb 시인성).
- evaluator level은 chip 그대로 "⭐ Watching" — 기존 일관.

---

## 8. art-director / game-designer dependency

| 항목 | 담당 | 비고 |
|------|------|------|
| compat 공식 lock | **game-designer** | M2 — `compat_score(menu, guest) -> int 0~100` |
| best_guest precompute 캐시 | godot-dev | menu_select 카드별 best_gid 1회 계산 |
| Mini-badge avatar art | art-director | placeholder = AVATAR_TINT 원형 OK |
| compat bar 시각 컴포넌트 | ui-designer + godot-dev | CP-24 `compat_bar.tscn` 구현 |
| mood / friendship / reward 공식 | **game-designer** | `guest-select-v2-layout.md` §3.5/3.6 위임 |
| likes/dislikes axis lift to display | **game-designer** | guests.csv 신규 컬럼 `likes`/`dislikes` |

---

## 9. godot-dev 후속 spec

- `menu_select.tscn` v2: 카드 chip 자리 mini-badge로 확장 (현 84×84 원 → 110×106 chip+caption).
- `menu_select.gd` v2 `_make_card()` 갱신:
  - 신규: `CompatCalc.best_guest(menu_id)` 호출
  - chip 노드 내용 → mini-badge (avatar + % + caption)
  - evaluator level은 기존 chip 디자인 유지
- `compat_bar.tscn` (CP-24) 신규 컴포넌트 — Guest Select + Food Select 양쪽 재사용.
- `flavor_tag_badge.tscn` (CP-25), `mood_badge.tscn` (CP-26), `reward_bonus_badge.tscn` (CP-27) 신설.
- 신규 Autoload `CompatCalc.gd` / `MoodSystem.gd` / `RewardCalc.gd` — game-designer 공식 lock 후 implement.

---

## 10. Decisions Log

| # | 결정 | 근거 |
|---|------|------|
| FC-1 | flow = 선 음식 → 후 게스트 (현 유지) | lift 최소, UX 익숙 |
| FC-2 | Food Select 카드 best guest mini-badge | 음식 선택 전 미리보기 motivation |
| FC-3 | Guest Select 카드 compat large badge (primary) | 의사결정 main focus |
| FC-4 | compat 시각 = bar + 컬러 + 라벨 삼중 (CP-24) | color-blind safe |
| FC-5 | 5 tier (90+/75+/50+/30+/<30) PERFECT/GOOD/OK/LOW/BAD | friends-system axis 매핑 + 직관 |
| FC-6 | mini-badge 위치 = 현 chip 자리 재활용 | 디자인 일관, 변경 최소 |

---

## 11. 변경 이력
- **2026-06-04 v0.1** — 초안. Food Select 카드 best guest mini-badge + Guest Select 카드 compat large badge. 5-tier 시각 매핑. cross-screen passing (pending_menu_id + CompatCalc/MoodSystem/RewardCalc Autoload). flow 다이어그램. game-designer 공식 위임 항목 정리.
