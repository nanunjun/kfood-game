# Result Screen 2.0 — Rewarding + Explanatory

> 버전: **v2.0 (2026-06-04)** · 작성자: game-designer
> Scope: **Result Screen UX 2.0** — 라운드 종료 보상감 ↑ + 점수 형성 이유 명확화. Cooking mechanic 변경 X. 광고/IAP/Analytics/release 무관.
> 상위 문서: [`systems/cooking-mechanics.md` v0.7](cooking-mechanics.md) · [`systems/guest-system-v2.md` v2.0](guest-system-v2.md) · [`balance-config.md` v0.6](../balance-config.md) · [`decisions.md` ADR-009 + ADR-010](../decisions.md#adr-009) · 코드 ref: `godot-project/scripts/gameplay/result_screen.gd`, `scripts/autoload/save_manager.gd` (v2 schema), `scripts/autoload/reward_calc.gd`, `scripts/autoload/mood_system.gd`
>
> Data: [`data/recipe_xp.csv`](../../data/recipe_xp.csv) (신설), [`data/reaction_templates.csv`](../../data/reaction_templates.csv) (신설), [`godot-project/data/guests.csv`](../../godot-project/data/guests.csv), [`godot-project/data/menus.csv`](../../godot-project/data/menus.csv)

---

## 0. 정신 — 결과 화면이 "왜 좋고 왜 나쁜지" 말한다

현재 ResultScreen (`result_screen.gd`):
- 5 라인 압축: 음식 이름 / dish 일러스트 / reaction face / ★ + Score% / "Prep X Method Y Timing Z"
- "왜 잘했는지" 설명 0. compat·mood·friendship 누적 wire 0. progression sense 0.

v2.0 목표:
- **6 행 score breakdown** (prep / cook / season / plating / compat / mood / reward_bonus) — 각 row가 raw value + 시각 + 코인 기여를 보여줌
- **4-level emotion reaction** — guest별 reaction text가 "왜 좋아했는지/싫어했는지" 설명 ("Mina loved the spicy kick!")
- **Recipe XP** — 음식별 누적 leveling, level up시 signature line/보너스 reveal
- **New Record** — (food_id, guest_id) pair best score 갱신 시 badge + 500 코인 bonus
- **Milestone unlock 보상 표시** — Friendship Lv 3 / 7 / 10 도달 시 결과 화면에서 toast or banner로 직접 reveal

cooking mechanic은 손 안 댐 — 점수 산정 로직은 그대로, **display layer가 풍부**해진다.

---

## 1. Score Breakdown — 6 rows 데이터 모델

### 1.1 Row 정의 표

> 사용자 명시 컬럼: prep_score / cook_score / seasoning_score / plating_score / compatibility_bonus / mood_bonus_or_penalty / reward_bonus. **7 항목 = 4 base + 3 modifier**. UI 표시는 시각 그룹으로 묶는다 (base 4 + modifier 3).

| # | row_id | label (en) | source | raw value | 시각 표시 | 코인 기여 (예시) |
|---|--------|-----------|--------|-----------|----------|----------------|
| 1 | `prep_score` | Prep | rhythm_proto `_cat_acc.prep` 평균 | 0~1.0 float | progress bar (blue) + % + ★1~3 conv | `+ ₩(base × 0.20 × prep_score)` |
| 2 | `cook_score` | Cook | rhythm_proto `_cat_acc.cook` 평균 | 0~1.0 float | progress bar (orange) + % + ★1~3 conv | `+ ₩(base × 0.20 × cook_score)` |
| 3 | `seasoning_score` | Season | rhythm_proto `_cat_acc.season` 평균 | 0~1.0 float | progress bar (red) + % + ★1~3 conv | `+ ₩(base × 0.20 × seasoning_score)` |
| 4 | `plating_score` | Plating | rhythm_proto `dish_bonus` (`_dish_pick` 결과) | 0~1.0 float (1.0 / 0.6 / 0.2 / 0.0) | dish thumb + label (Best / OK / Wrong) | `+ ₩(base × 0.20 × plating_score)` |
| 5 | `compatibility_bonus` | Compat | RewardCalc.bonus_multiplier(compat) | multiplier 0.70x~1.30x | compat % bar (RewardCalc.compat_color) + multiplier pill | `× compat_multiplier` (전체 곱) |
| 6 | `mood_bonus_or_penalty` | Mood | mood_mult_fav (fav hit 있을 때) 또는 mood_mult_dis (dis hit 있을 때) 영향분 표시 | "+20%" / "-10%" 라벨 | mood_badge 재활용 + label | (이미 compat에 반영, "explanation" 용도 — 코인 별도 가산 X) |
| 7 | `reward_bonus` | Guest Bonus | guest.reward_bonus (CSV) | 1.15x~2.00x | guest portrait + "× guest_bonus" pill | `× guest.reward_bonus` (전체 곱) |

### 1.2 4-Factor Weights (cooking-mechanics §5 / balance-config §5 sync — 변경 X)

cooking-mechanics 4-factor 가중치 25/20/20/35는 그대로:
```
score_pre = (ingredient × 0.25) + (prep × 0.20) + (method × 0.20) + (timing × 0.35)
```

> **Result Screen에서 보여주는 4 base row와 위 4-factor는 1:1 매핑이 아님**:
> - `prep_score` (UI) = `_cat_acc.prep` (chop/roll/knead 평균) → 4-factor의 prep + ingredient 일부
> - `cook_score` (UI) = `_cat_acc.cook` (boil/stirfry/panfry 평균) → 4-factor의 method
> - `seasoning_score` (UI) = `_cat_acc.season` 평균 → 4-factor의 season
> - `plating_score` (UI) = `dish_bonus` (best/2nd/bad) → 4-factor의 timing 일부 + plating dish_bonus
>
> 단순화를 위해 **UI에서는 phase 카테고리 4종으로 보여주고**, ★ 임계 산정은 cooking-mechanics 공식 그대로 사용. UI label은 플레이어 직관 우선.

### 1.3 코인 기여 공식 (Result Screen 표시용)

```
base_coin = economy.coin_per_star_by_tier[tier][stars]            // balance-config §10
compat_mult = RewardCalc.bonus_multiplier(compat)                  // 0.70~1.30
guest_mult  = guest.reward_bonus                                   // 1.15~2.00

# 각 base row 코인 attribution (display 전용, 합산해도 final과 일치하도록 정규화)
factor_share = {prep:0.20, cook:0.20, season:0.20, plating:0.20, ingredient:0.20}
displayed_coin_per_row = base_coin × factor_share[row] × score_for_row × compat_mult × guest_mult

# 전체 합
final_coin = base_coin × compat_mult × guest_mult + (new_record ? 500 : 0) + milestone_payout
```

> 시각 분해는 "기분 좋음" 목적. 실제 SaveManager는 `final_coin` 한 번에 add_money. `displayed_coin_per_row`는 UI 라벨 표시 전용.

### 1.4 시각 mapping 예시 — Junho × 김치찌개 (happy) ★3

```
컨텍스트:
  stars = 3, score_pre = 0.95, compat = 93, mood = happy
  base_coin = 20 (T1 ★3) → 이미 적용된 reward 값
  guest.reward_bonus = 1.20 (Junho)
  compat_mult = 1.30 (compat >=90)

Row breakdown:
  Prep      ████████░░ 92%   ★★★  +₩4
  Cook      ███████░░░ 78%   ★★☆  +₩3
  Season    ████████░░ 88%   ★★★  +₩4
  Plating   pot_clay   ★Best +₩4   (best dish = 1.0)

Modifier rows:
  Compat    93% ●●●●●● Perfect match!  × 1.30x
  Mood      [Happy badge] +20% favor   (already in compat)
  Bonus     Junho friend    × 1.20x

Coin total:
  base 20 × 1.30 × 1.20 = ₩31
  + NEW RECORD bonus +₩500 (if applicable)
  + Friendship Lv 3 toast: +₩500 (if just hit)
  = TOTAL ₩1031
```

### 1.5 시각 mapping 예시 — Mother × 김치찌개 (picky) ★1

```
컨텍스트:
  stars = 1, score_pre = 0.45, compat = 49, mood = picky
  Mother fav=[mild,sweet,hearty,umami], dis=[spicy,oily,bitter]
  Kimchi fav hit = {umami,hearty} = 2 → fav_score = 2×12×1.1 = 26.4
  Kimchi dis hit = {spicy} = 1     → dis_score = 1×18×1.5 = 27.0

Row breakdown:
  Prep      ████░░░░░░ 42%   ★☆☆  +₩1
  Cook      █████░░░░░ 50%   ★☆☆  +₩2
  Season    ███░░░░░░░ 30%   ★☆☆  +₩1
  Plating   pot_metal  ★OK   +₩2

Modifier rows:
  Compat    49% ●●●○○○ Mediocre 😐  × 0.85x
  Mood      [Picky badge] Mother is picky today (-50% dislike weight!)
  Bonus     Mother family × 1.35x

Coin total:
  base 10 × 0.85 × 1.35 = ₩11
  No NEW RECORD
  = TOTAL ₩11
```

> **Result Screen이 "왜 11원밖에 안 나왔는지" 한눈에**: compat 49% mediocre × picky mood × spicy dislike hit. mother는 김치찌개 picky day에 피하라는 교훈.

---

## 2. Emotion Reaction — 4 levels + text generation

### 2.1 Emotion Level 결정 룰

| level | 조건 | guest avatar (mood_badge 재활용) | tween | sfx |
|-------|------|------------------------|-------|-----|
| **excellent** | compat ≥ 90 OR (★3 + compat ≥ 70) | `happy` (😋) | scale 1.0 → 1.20 punch | `sting_perfect` |
| **good** | (compat 70~89) OR (★3 + compat ≥ 50) | `easy` (~) | scale 1.0 → 1.10 | `sting_good` |
| **okay** | (compat 50~69) OR ★2 | `picky` (?) | scale 1.0 → 1.05 small | `sting_ok` |
| **bad** | (compat < 50) OR ★1 | `grumpy` (>(:) | scale 1.0 → 0.95 sag | `sting_bad` |

**우선순위 (둘 다 만족 시 더 높은 level)**:
```
level = max(level_from_compat, level_from_stars)
where:
  level_from_compat = excellent(≥90) / good(70~89) / okay(50~69) / bad(<50)
  level_from_stars  = excellent(★3 + compat≥70) / good(★3 alone) / okay(★2) / bad(★1)
```

**근거**:
- compat이 좋아도 ★ 낮으면 ("guest는 만족했는데 요리 자체가 엉성") → okay level이 합리적
- compat 낮은데 ★3 ("요리는 잘했는데 guest 취향 X") → good level까지만 (excellent는 둘 다 충족)

### 2.2 Reaction Text Generation Rule

`data/reaction_templates.csv` 8 guests × 4 levels = **32 templates** lock. evaluator 3종 추가 = 32 + 12 = **44 templates** 총.

**Placeholder 치환 규칙**:
- `{top_matched_flavor}` = food.flavor_tags ∩ guest.favorite_flavors 중 첫 번째 (`pipe-separated order` 기준)
- `{top_disliked_flavor}` = food.flavor_tags ∩ guest.disliked_flavors 중 첫 번째
- `{missing_favorite}` = guest.favorite_flavors - food.flavor_tags 중 첫 번째 (guest가 원했는데 음식에 없는 flavor)
- placeholder가 비어있으면 ("excellent인데 fav hit 0") → fallback generic text 사용

**Pseudo-code**:
```gdscript
func emotion_text(guest: Dictionary, food: Dictionary, stars: int, compat: int, mood: String) -> String:
    var level := _emotion_level(stars, compat)              # excellent/good/okay/bad
    var fav_hits = food.flavor_tags.filter(t in guest.favorite_flavors)
    var dis_hits = food.flavor_tags.filter(t in guest.disliked_flavors)
    var missing  = guest.favorite_flavors.filter(t not in food.flavor_tags)

    var tpl := ReactionDB.template(guest.guest_id, level)   # CSV row
    var text := tpl.template_text
    text = text.replace("{top_matched_flavor}", fav_hits[0] if !fav_hits.is_empty() else "flavor")
    text = text.replace("{top_disliked_flavor}", dis_hits[0] if !dis_hits.is_empty() else "")
    text = text.replace("{missing_favorite}", missing[0] if !missing.is_empty() else "depth")

    # mood-aware postfix (optional, level=bad일 때 mood가 grumpy/picky면 추가)
    if level == "bad" and mood in ["grumpy", "picky"]:
        text += "  (" + guest.name + " was " + mood + " today.)"
    return text
```

### 2.3 사용자 verbatim 검증 — 도출 가능 여부

**사용자 명시 예시 1**: `"Mina loved the spicy kick!" — Mina + 김치찌개 (compat 92%)`

❌ **persona 충돌**: Mina favorite=[sweet, savory, oily], 김치찌개 flavor=[spicy, salty, umami, fermented, hearty]. fav_hit=0 → compat 92% 도달 불가능. guest-system-v2 §4.1에서 이미 검증: **Mina × 김치찌개 = 50% (neutral)**.

✅ **재해석으로 도출 가능 (guest-system-v2 §4.1' Junho 치환)**:
- "Junho roared 'Now THAT is a kick!' — perfect spicy hit." — Junho + 김치찌개 (compat 93%, happy mood)
- 사용자 verbatim의 정신(spicy hit 칭찬)을 Junho 페르소나로 보존.

✅ **만약 Mina로 유지하고 싶다면 음식 변경**: Mina × 떡볶이 (sweet+spicy+savory 일부 hit)
- Mina × 떡볶이 hit_fav: {savory} = 1, hit_dis: {} = 0, mood=happy → fav_score = 1×12×1.2 = 14.4, raw = 64
- 64%는 excellent (90+) 아님. **여전히 사용자 verbatim 92%는 Mina 페르소나와 불일치**.

→ **결정**: persona 정합 우선. 사용자 verbatim은 illustrative — 실제 게임에선 Junho × 김치찌개로 매핑되어 "Junho roared 'Now THAT is a kick!'"로 표시. balance-config v0.5 §13.8 이미 이 해석 lock.

**사용자 명시 예시 2**: `"Junho liked it, but wanted more savory depth." — Junho + 김밥 (compat 63%)`

✅ **도출 가능**:
```
F = gimbap = [mild, salty, savory, fresh]
G_fav (Junho) = [spicy, salty, hearty]
G_dis (Junho) = [sweet, bitter]
M = easy → mood_mult_fav=1.0, mood_mult_dis=0.7

hit_fav = |{salty}| = 1   (spicy/hearty miss)
hit_dis = 0
fav_score = 1 × 12 × 1.0 = 12
dis_score = 0
raw = 50 + 12 = 62%   ✅ (목표 63% 일치, 1% 차이 acceptable)

Emotion level = good (compat 70~89 미만, 50~69 → okay) ... 잠깐, 62%는 okay 범위.
```

→ **사용자 verbatim "Junho liked it" 정신은 good 수준이나, compat 62%는 okay band**. 

**해결**: csv template `junho,okay` row 텍스트를 "Junho shrugged — it was okay but not bold enough." → "Junho liked it, but wanted more {missing_favorite}." 로 톤 조정 가능. 단 "liked it"이 okay 톤보다 약간 긍정적 → game-designer 권고: **okay band는 "liked it, wanted more X" 톤 유지** (사용자 verbatim 그대로 mirror).

```csv
junho,okay,"Junho liked it, but wanted more {missing_favorite}.",1 fav hit borderline
```

→ Junho × 김밥 (easy) 예상 결과:
- template `junho,okay` = `"Junho liked it, but wanted more {missing_favorite}."`
- `{missing_favorite}` = Junho fav - food = [spicy, hearty] 중 첫 번째 = **spicy**
- 최종 = **"Junho liked it, but wanted more spicy."** 

→ 사용자 verbatim "wanted more savory depth"와 약간 다름 (savory vs spicy). Junho fav에 spicy가 1순위라 spicy 도출. **사용자 verbatim의 "savory"는 placeholder hint** — actual template은 guest persona top fav 우선.

**최종 verbatim 검증 표**:

| 사용자 verbatim | guest+food+mood 매핑 | 실제 도출 텍스트 | 일치도 |
|----------------|---------------------|----------------|--------|
| "Mina loved the spicy kick!" | (persona 불일치) → Junho + 김치찌개 + happy | "Junho roared 'Now THAT is a kick!' — perfect spicy hit." | 정신 ✅ (kick + spicy 보존), 화자 변경 |
| "Junho liked it, but wanted more savory depth." | Junho + 김밥 + easy = 62% | "Junho liked it, but wanted more spicy." | 정신 ✅ (liked + wanted more), flavor 변경 (savory → spicy, Junho fav 1순위) |

> 사용자가 "verbatim 100% 보존" 원하면 reaction_templates.csv를 (food_id, guest_id, emotion) triple로 확장 = 12 × 7 × 4 = 336 row. 본 v2.0은 (guest, emotion) 2-key 32 templates lock — placeholder가 변동을 흡수.

### 2.4 Template 풀 — 8 selectable guests × 4 levels = 32 + evaluator 3 × 4 = 44

`data/reaction_templates.csv` lock. 위 §2.2 룰로 placeholder 치환.

| guest | excellent | good | okay | bad |
|-------|-----------|------|------|-----|
| Junho | "Now THAT is a kick!" + {flavor} | "wanted more punch" | "okay but not bold enough" | "too {dis} for him" |
| Mina | "sweet and perfect — love it!" | "wished for more {missing}" | "alright I guess" | "too {dis} for her" |
| Riley | "Whoa that zing is amazing!" | "wanted a sharper {missing} edge" | "fine, but plain" | "too {dis}" |
| Mrs.Lee | "Just right. Deep savory touch." | "missed some {missing} depth" | "acceptable, not memorable" | "too {dis}, lacking refinement" |
| Seoyeon | "Exactly the comfort I needed!" | "hoping for more {missing}" | "underseasoned for me" | "too {dis}, not her home taste" |
| Mother | "Just like home, my child." | "needs more {missing}" | "Hmm, it's alright." | "A little heavy for me today." |
| Father | "Now THAT hits the spot!" | "Could use more {missing}." | "Not bad. Needs more punch." | "too {dis}, not his style" |
| Mystery Diner | satisfied nod | small approving glance | expression unchanged | closed notebook silently |
| Daniel Kim | "Posting this right now!" | "Decent. Wanted more {missing}." | "borderline content" | "Not sure I'd recommend." |
| Goldspoon | "You have earned it." | "Promising. Refine {missing}." | "Adequate." | "Not yet at our standard." |

---

## 3. Recipe XP System

### 3.1 누적 공식

```
xp_per_round = 10 × stars + (compat / 10)             # ★3 + compat 90 = +39 XP
              + (new_record ? +20 bonus : 0)

# recipe_xp[food_id] += xp_per_round   (cap MAX_XP from lv10_cumxp)
```

> 평균 round: ★2 + compat 60 = 20 + 6 = **26 XP/round**. lv 3 도달 (250 cumxp T1) = ~10 round.

### 3.2 Curve — T1 / T2 차등

`data/recipe_xp.csv` 12 음식 × 10 level. Tier 1/T2/T2-difficult curve 3종:

| level | T1 cumxp (라면/김밥/잔치국수) | T1-mid cumxp (떡볶이/김치찌개/콘도그/해물파전/순두부) | T2 cumxp (비빔밥/된장찌개/잡채/불고기/매운탕/갈비) |
|:-:|:-:|:-:|:-:|
| 1 | 0 | 0 | 0 |
| 2 | 100 | 120 | 140~160 |
| 3 | 250 | 280 | 320~360 |
| 4 | 450 | 500 | 560~620 |
| 5 | 700 | 780 | 860~940 |
| 6 | 1000 | 1120 | 1220~1320 |
| 7 | 1400 | 1540 | 1660~1780 |
| 8 | 1900 | 2040 | 2200~2340 |
| 9 | 2500 | 2640 | 2840~3000 |
| 10 | 3200 | 3360 | 3600~3780 |

> 평균 26 XP/round → T1 lv10 도달 = ~120 round. 12 음식 × ~120 round = ~1400 round contents. LiveOps long-tail OK.

### 3.3 Level Up Reward

| recipe lv | T1/T1-mid 보상 | T2 보상 | 가치 |
|:-:|------|------|------|
| 2 | +₩300 | +₩400 | 초기 동기 |
| 3 | signature line unlock (`signature_line` CSV) | same | persona depth |
| 4 | +₩500 | +₩650 | mid 부스트 |
| 5 | perfect_window +5ms (this food only) | same | skill aid |
| 6 | +₩800 | +₩1000 | |
| 7 | signature dish glow (plating dish_best에 영구 glow effect) | same | 시각 보상 |
| 8 | +₩1200 | +₩1500 | |
| 9 | reward_bonus_perm +0.05 (this food's base reward × 1.05) | same | end-game compounding |
| 10 | "Master of X" title unlock + max badge | same | bragging right |

> level up 보상 wire는 `cooking.recipe.level_up_rewards` Remote Config로 운영 가능. balance-config §14 신설 (아래).

### 3.4 Result Screen 표시

```
Recipe Level: Ramyeon Lv 4 → Lv 5  [████░░░░░░] 450/700 XP
+39 XP this round
[Level Up!] tween + sting_levelup sfx
"New: perfect_window +5ms — easier timing on Ramyeon!"
```

---

## 4. New Record Logic

### 4.1 Key/Value

- **storage key**: `(food_id, guest_id)` pair (tuple). SaveManager v2 `data.records[food_id][guest_id] = best_score_int`.
- **value**: `score_final_int` = `int(round(score_pre × 100))` (0~100 integer). 동률은 갱신 X.
- **first record**: `data.records[food_id][guest_id]` 부재 시 → 첫 라운드는 항상 NEW RECORD (기준선 설정).

### 4.2 Bonus

- 갱신 시 **+₩500 one-time** (balance-config `economy.new_record_bonus_coin = 500` lock).
- Result Screen에 `"★ NEW RECORD!"` badge + glow + sting_record sfx.
- 같은 라운드에서 milestone 동시 도달 시: NEW RECORD bonus + milestone payout 둘 다 add (additive, not exclusive).

### 4.3 Display

```
result_screen 상단:
  ★ NEW RECORD!   95% (prev 87%)   +₩500
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  pulsing border, gold tint
```

### 4.4 Save Schema (v2 유지 — 신규 dict만 추가)

```
data.records = {
  "t1_002": {
    "junho": 95,
    "mina":  82,
  },
  "m_kimchi_jjigae": {
    "junho": 93,
  },
  ...
}
```

> v2 schema bump 불필요 — 기존 SaveManager `_default_data()`에 `"records": {}` 한 줄 추가 + `_merge()`가 backward compat 자동 처리. v3 bump 안 해도 됨.

`data.recipe_xp = { "t1_002": 250, "m_kimchi_jjigae": 130, ... }`도 동일하게 추가.

---

## 5. Milestone Unlock 보상 — Result Screen 표시

### 5.1 Milestone 정의 (balance-config §13.4 sync, 변경 X)

| friendship_lv | 보상 | Result Screen 표시 |
|:-:|------|----|
| 3 | one-time ₩500 + special line_ok unlock | **Toast** 우상단 슬라이드: `"💝 Friendship Lv 3 with Junho! +₩500"` |
| 7 | signature dish unlock + compat +5% perm (this guest only) | **Banner** 중앙 풀: `"⭐ Junho's Signature Unlocked! Kimchi Stew always compat +5% with Junho"` + 2 sec hold |
| 10 | portrait skin unlock + reward_bonus +0.10x perm | **Full-screen overlay**: portrait skin reveal + `"💎 MAX Friendship! Junho's premium portrait + permanent ×1.30 reward bonus"` + confetti tween |

### 5.2 Result Screen Flow

```
[Score Reveal] → [4 base rows fill] → [Modifier rows fill] → [Total Coin pop]
                                                                  │
                                                                  ▼
                                              [NEW RECORD badge if applies]
                                                                  │
                                                                  ▼
                                              [Recipe Level Up if applies]
                                                                  │
                                                                  ▼
                                          [Friendship Milestone if applies]
                                                                  │
                                                                  ▼
                                                    [Retry/Next/Menu buttons]
```

Total reveal time budget: ~3.5s (score 1.5s + modifiers 1s + bonuses 1s). Skip tap accelerates.

### 5.3 Wire — SaveManager hook

```gdscript
# rhythm_proto._on_round_end() 끝에서:
var leveled_up_recipe = RecipeXP.add(food_id, xp_per_round)         # 신규 autoload
var record_broken    = SaveManager.check_record(food_id, guest_id, score_int)
SaveManager.add_friendship(guest_id, delta)                          # 이미 있음, milestone toast queue 자동
# milestone은 SaveManager.friendship_milestone_pending(guest_id)로 result_screen에서 consume
result_screen.setup(stars, score, breakdown, ..., {
  "leveled_up_recipe": leveled_up_recipe,
  "record_broken": record_broken,
  "milestone_just_hit": SaveManager.friendship_milestone_pending(guest_id),
})
```

---

## 6. Guest Avatar 표정 → Emotion 매핑

### 6.1 권고 — mood_badge 재활용 (asset 0 추가)

현 codebase: `MoodBadge` 컴포넌트 (`scripts/ui/components/mood_badge.gd`) + `MoodSystem` 5 mood (hungry/happy/easy/picky/grumpy) — 이미 art-director가 만들어둔 색·아이콘 자산.

**매핑**:

| emotion_level | mood_badge mood | 사유 |
|---------------|----------------|------|
| excellent | `happy` (smile :)) | 만족 최고치 |
| good | `easy` (~) | 평온한 긍정 |
| okay | `picky` (?) | 보류·미묘 |
| bad | `grumpy` (>(:) | 불만 |

> `hungry` (H)는 결과 화면에서 안 씀 (라운드 전 mood badge로 이미 노출). result reaction은 4 level만.

### 6.2 후속 art-director 옵션 (별도 sprint, 본 v2.0 외)

art-director가 추후 reaction 4 levels 전용 일러스트(guest별 4 표정 = 8 × 4 = 32 sprite) 만들면 mood_badge 대체 가능. 본 v2.0은 **0 추가 asset** = ship 즉시 가능.

---

## 7. 데이터 변경 요약

### 7.1 신설 파일

| 경로 | 내용 | row 수 |
|------|------|-------|
| `data/recipe_xp.csv` | 12 음식 × Lv 2~10 누적 XP + level_up_reward + signature_line | 12 |
| `data/reaction_templates.csv` | 8 selectable guests + 3 evaluators × 4 emotion = 44 templates | 44 |

### 7.2 기존 파일 변경

| 경로 | 변경 |
|------|------|
| `docs/balance-config.md` | v0.5 → **v0.6**: §14 신설 (Recipe XP curve / New Record bonus / Result Screen 2.0 wire Remote Config 키 8개) |
| `docs/decisions.md` | **ADR-010 신설**: Result Screen 2.0 — pure UX/display layer, mechanic 무영향, ADR-009 후속 |
| `docs/systems/result-screen-v2.md` | (본 문서) 신설 |

### 7.3 향후 godot-dev sprint (코드 영역, 본 sprint 외)

- `scripts/autoload/recipe_xp.gd` 신규 autoload — CSV load + add(food_id, xp) → 레벨업 감지
- `scripts/autoload/save_manager.gd` — `records: Dictionary` + `recipe_xp: Dictionary` 2 dict 추가 (v2 schema 유지, `_default_data()` 1 줄 add)
- `scripts/gameplay/result_screen.gd` v2 rewrite — 6 rows breakdown + emotion 4-level + milestone display
- `scripts/autoload/reaction_db.gd` 신규 autoload — reaction_templates.csv load + template(guest_id, level) lookup + placeholder 치환
- `scripts/autoload/reward_calc.gd` — `score_breakdown_rows()` 신규 함수 (6 rows 구성)

---

## 8. Remote Config 키 추가 (balance-config §14 신설용)

| 키 | 기본값 | 타입 | 설명 |
|----|--------|------|------|
| `result.score_breakdown.show_modifier_rows` | `true` | bool | compat/mood/bonus 3 modifier row 표시 여부 |
| `result.reaction.emotion_levels` | `["excellent","good","okay","bad"]` | string[] | 4 emotion level id |
| `result.reaction.compat_thresholds` | `[90,70,50]` | int[] | compat → level 임계 (≥90/≥70/≥50) |
| `result.reaction.star_overrides` | `{"3":"good","2":"okay","1":"bad"}` | object | ★ → minimum emotion level (combined with compat) |
| `result.recipe_xp.formula` | `{"per_star":10,"per_compat_div":10,"new_record_bonus":20}` | object | XP 산식 변수 |
| `result.recipe_xp.max_level` | `10` | int | 최대 recipe level |
| `result.record.new_record_bonus_coin` | `500` | int | NEW RECORD 갱신 1회 보상 |
| `result.record.first_record_counts` | `true` | bool | 첫 라운드도 NEW RECORD 처리 |
| `result.milestone.reveal_styles` | `{"3":"toast","7":"banner","10":"overlay"}` | object | level별 reveal 시각 스타일 |
| `result.milestone.overlay_duration_sec` | `2.5` | float | Lv 10 portrait overlay 노출 시간 |

---

## 9. 검증 시나리오 (3종)

### 9.1 Mrs.Lee × 잔치국수 (happy) ★3 (compat 93%)

```
Row breakdown:
  Prep    ████████░░ 88%  ★★★  +₩4
  Cook    ███████░░░ 75%  ★★☆  +₩3
  Season  █████████░ 92%  ★★★  +₩5
  Plating bowl_ceramic ★Best +₩4

Modifier rows:
  Compat  93% Perfect match!  × 1.30x
  Mood    [Happy] +20% favor
  Bonus   Mrs.Lee mentor × 1.30x

Coin: 20 × 1.30 × 1.30 = ₩34
NEW RECORD: prev 87 → 93. +₩500
Recipe Janchi Lv 3 → Lv 4. +₩500 reward.

TOTAL ₩1034.

Reaction (excellent):
  "Mrs. Lee closed her eyes — 'Just right. That deep savory touch.'"
```

### 9.2 Father × 떡볶이 (grumpy) ★2 (compat 69%)

```
Row breakdown:
  Prep    ███████░░░ 70%  ★★☆  +₩3
  Cook    ██████░░░░ 62%  ★★☆  +₩2
  Season  ████████░░ 80%  ★★★  +₩3
  Plating bowl_brass ★OK +₩2

Modifier rows:
  Compat  69% (neutral)    × 1.00x
  Mood    [Grumpy] -50% favor (high risk!)
  Bonus   Father family × 1.25x

Coin: 15 × 1.00 × 1.25 = ₩19

NO new record (prev 78), NO milestone, no recipe level up (still Lv 2)

Reaction (okay, since compat 50~69):
  "Father grunted — 'Not bad. Needs more punch honestly.'"
```

### 9.3 Mother × 김치찌개 (picky) ★1 (compat 49%) — 첫 라운드

```
Row breakdown:
  Prep    ███░░░░░░░ 30%  ★☆☆  +₩0.5
  Cook    █████░░░░░ 50%  ★☆☆  +₩1
  Season  ███░░░░░░░ 30%  ★☆☆  +₩0.5
  Plating bowl_glass ★Wrong +₩0

Modifier rows:
  Compat  49% Mediocre 😐  × 0.85x
  Mood    [Picky] +50% penalty (be careful!)
  Bonus   Mother family × 1.35x

Coin: 10 × 0.85 × 1.35 = ₩11

NEW RECORD (first time for this pair): +₩500
Friendship Mother +1 → Lv 1 (no milestone)

TOTAL ₩511.

Reaction (bad — compat<50):
  "Mother frowned — 'A little heavy for me today, dear.'"
```

---

## 10. 변경 이력

- **2026-06-04 v2.0** — 신설 spec. Result Screen 2.0 (ADR-010과 동시 lock). 6 row breakdown (prep/cook/season/plating + compat/mood/guest_bonus). 4-level emotion reaction (excellent/good/okay/bad) + 44 reaction templates (8 guests + 3 evaluators × 4 levels). Recipe XP system (12 음식 × Lv 1~10 + signature line + level up rewards). New Record (food, guest) pair best + ₩500 bonus. Milestone unlock display (Lv 3 toast / Lv 7 banner / Lv 10 overlay). mood_badge 재활용 (0 추가 asset). 사용자 verbatim 검증 (Mina × 김치찌개 persona 불일치 → Junho × 김치찌개 happy로 재해석 / Junho × 김밥 easy = 62% okay band 일치).
