# Result Screen v2 — Layout & Animation Spec

> 버전: **v0.1** · 갱신일: 2026-06-04 · 작성자: ui-designer
> 상위 문서: [`screen-flow.md` v0.5](screen-flow.md), [`components.md` v0.5](components.md), [`../friends-system.md` v0.3](../friends-system.md), [`guest-select-v2-layout.md` v0.1](guest-select-v2-layout.md), [`food-select-compat.md` v0.1](food-select-compat.md), [`../systems/cooking-mechanics.md` v0.6](../systems/cooking-mechanics.md), [`../decisions.md` ADR-005](../decisions.md#adr-005)
>
> **목표**: Round 종료 직후 "**왜 이 점수인가**" 5초 안에 인식 + "다시 만들어볼까" emotion hook. 기존 `result_screen.gd` (구 inline reveal)를 **신 PackedScene `scenes/ui/result_screen_v2.tscn`**으로 교체.
> **scope**: gameplay only (광고/IAP/Analytics 무관). cooking mechanics 변경 X.
> **viewport**: 1080×1920 portrait, safe area Y 60~1860 (top/bottom 60 reserved for HUD/gesture).
> **i18n lock (2026-05-27)**: 영어 primary + 한글 sub line per text.

---

## 0. Layout 옵션 비교 + 권고

### 0.1 옵션 비교

| 옵션 | Pros | Cons | 5-sec rule | 판정 |
|------|------|------|:----------:|:----:|
| **A. 단일 scroll screen** (ScrollContainer, 본 spec 채택) | 정보 풍부 + 한 화면 narrative arc / 위→아래 = 결과 → 감정 → 보상 → 행동 자연 흐름 / animation sequence cinematic | Above-the-fold = Summary + Reaction만, Rewards/Breakdown은 스크롤 | ✅ Summary + Reaction만 5초로도 인식 가능 | ✅ |
| B. 2~3 tab sub-screens (Summary → Breakdown → Rewards) | tap당 정보 focus | tap 2~3회 = 모바일 캐주얼에 무거움 / "왜 점수?" 답이 분산 | ❌ Tab 전환 비용 | ❌ |
| C. Compact dashboard (모든 정보 단일 view, 작은 폰트) | 스크롤 0 / 한눈에 | 폰트 14pt 이하 → 노안/저시력 접근성 ↓ / 시각 noise ↑ / 5-second rule 역효과 | ⚠ 정보 과밀 | ❌ |

**권고: 옵션 A — 단일 ScrollContainer screen.**

근거:
1. 7 sections 정보 밀도 — Compact (C) 시 가독성 sacrifice / Tab (B) 시 narrative arc 깨짐.
2. **Above-the-fold (Y 0~1300, 스크롤 전) = Summary + Emotional Reaction 1.5 sections만** → 5-second rule 보장.
3. 스크롤 후 Score Breakdown + Rewards 노출 → "더 알고 싶을 때만" 읽는 progressive disclosure.
4. CTA 3개는 **sticky bottom (Y 1700~1860)** 으로 항상 도달 가능 (스크롤 위치 무관).

### 0.2 ASCII sketch (single scroll screen, 1080×1920)

```
Y    ┌─────────────────────────────────────────┐
0    │ Top HUD: 💰 1240   ❤️❤️❤️   Lv.7   ⏸    │ ← stationary (60px)
60   ├─────────────────────────────────────────┤  ━━━━━━━━━━━━━━━━━━━
     │                                         │
     │     [§1 Dish + Guest Summary]           │  Section 1
     │     ┌─────────────┐  ┌─────────────┐    │  (Y 80~620, 540h)
     │     │ Dish 460×460│  │ Guest 240   │    │  Above-the-fold
     │     │   (F-XX)    │  │   (avatar)  │    │
     │     │             │  │  + mood     │    │
     │     └─────────────┘  └─────────────┘    │
     │       Tteokbokki         Mina          │
     │       떡볶이             ★★★☆☆        │
     │                                         │
     │      [ 92% Compat — PERFECT MATCH ]     │ ← CP-24 large
     │                                         │
640  ├─────────────────────────────────────────┤  ━━━━━━━━━━━━━━━━━━━
     │                                         │
     │     [§4 Emotional Reaction]             │  Section 4
     │      💬 "Mina loved the spicy kick!"    │  (Y 640~1100, 460h)
     │         미나가 매콤한 맛에 푹 빠졌어요! │  Above-the-fold
     │                                         │
     │     ┌──────────────────────┐            │
     │     │   Speech bubble +    │            │
     │     │  Guest avatar 280×280│ ← CP-26    │
     │     │   (mood = excellent) │   reuse    │
     │     └──────────────────────┘            │
     │                                         │
     │   [✨ NEW RECORD ✨]                    │ ← CP-31 (conditional)
1100 ├─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┤  ━━ scroll fold ━━
     │     [§7 ★ Stars + Total Score]          │  Section 7 (visible
     │       ★★★    Score 92%                  │   on scroll 시작)
     │                                         │  (Y 1100~1280, 180h)
1280 ├─────────────────────────────────────────┤
     │                                         │
     │     [§2 Score Breakdown — 6 rows]       │  Section 2
     │     ┌────────────────────────────┐      │  (Y 1280~2000, 720h)
     │     │ Prep        ★★★  +24       │ CP-28│  scroll-required
     │     │ Cook        ★★☆  +18       │      │
     │     │ Season      ★★★  +22       │      │
     │     │ Plating     ★★☆  +15       │      │
     │     │ Compat bonus     +15%      │      │
     │     │ Mood bonus       +5%       │      │
     │     │ Reward total     ×1.20     │      │
     │     └────────────────────────────┘      │
2000 ├─────────────────────────────────────────┤
     │                                         │
     │     [§3 Rewards]                        │  Section 3
     │     ┌────────────────────────────┐      │  (Y 2000~2600, 600h)
     │     │ 💰 +1,800 ₩  (count-up)    │ CP-29│
     │     │ 📖 +24 XP  (Tteokbokki)    │      │
     │     │ ♥ Mina  +12 friendship     │      │
     │     │   [▓▓▓▓▓▓▓░░] Lv 2 → 60/100│      │
     │     │   ✨ Milestone Lv 3!        │ CP-32│
     │     └────────────────────────────┘      │
2600 ├─────────────────────────────────────────┤  scroll end
     │     (padding 100px)                     │
2700 ├═════════════════════════════════════════┤
     │ [§5 STICKY CTA bar — always visible]    │  stationary
     │ ┌──────┐ ┌────────────┐ ┌──────┐        │  (Y 1700~1860)
     │ │ Cook │ │ Choose     │ │ Menu │        │  140h + 60 margin
     │ │ Again│ │ Other Guest│ │      │        │
     │ └──────┘ └────────────┘ └──────┘        │
1860 └─────────────────────────────────────────┘
```

> **주의**: Y 1100~2700은 **ScrollContainer 내부**. STICKY CTA는 ScrollContainer 외부 CanvasLayer 위에 stationary. Above-the-fold = Y 0~1300 (HUD + Summary + Reaction + Stars 상단 일부 = 5초 노출).

---

## 1. 7 Sections Placement (좌표 spec)

> 좌표는 ScrollContainer 내부 content 기준 (HUD 60 제외).
> **Above-the-fold** = scroll position 0 기준 Y 0~1300 (1920 - 60 HUD - 560 사용자 view margin).

### 1.1 §1 Dish + Guest Summary (Y 80~620, 540h)

| Element | Position (x, y, w, h) | Notes |
|---------|----------------------|-------|
| Dish image (F-XX) | (60, 100, 460, 460) | TextureRect, expand=ignore_size, stretch=keep_aspect_centered |
| Dish name (en) | (60, 580, 460, 60) | 48pt Pretendard Bold, center, color DARK |
| Dish name (kr sub) | (60, 640, 460, 36) | 24pt Pretendard Regular, opacity 0.65 |
| Guest avatar | (620, 200, 240, 240) | CP-26 mood overlay 우하단 (이번 round mood) |
| Guest name (en) | (560, 460, 360, 50) | 40pt center |
| Guest name (kr) | (560, 510, 360, 32) | 22pt center, opacity 0.65 |
| Friendship stars | (560, 550, 360, 40) | ★★★☆☆ (Lv 0~5), Sesame Gold |
| **Compat large badge (CP-24)** | (60, 690, 960, 110) | "92% PERFECT MATCH" + bar 하단. **section 1과 4 사이 bridge**. |

### 1.2 §4 Emotional Reaction (Y 820~1280, 460h)

> 의도적으로 §7 별점/점수보다 **위에** 배치 — "감정 → 점수" 흐름 (점수 → 감정이 아닌). cooking-mech §6.3 정합.

| Element | Position (x, y, w, h) | Notes |
|---------|----------------------|-------|
| Speech bubble BG | (60, 820, 960, 180) | rounded panel, cream, drop shadow |
| Reaction text (en) | (100, 850, 880, 60) | 36pt bold, color DARK, e.g. "Mina loved the spicy kick!" |
| Reaction text (kr) | (100, 910, 880, 40) | 24pt regular, opacity 0.7, "미나가 매콤한 맛에 푹 빠졌어요!" |
| Bubble tail | (520, 990, 40, 30) | speech bubble tail pointing down to avatar |
| Guest avatar (reaction state) | (400, 1030, 280, 280) | CP-30 emotion_reaction. **mood_badge sprite 재활용** — excellent/good/okay/bad 표정 swap |
| NEW RECORD badge (CP-31) | (340, 1180, 400, 80) | conditional. 등장 시 reaction 위 -28px overlap |

### 1.3 §7 ★ Stars + Total Score (Y 1280~1480, 200h)

| Element | Position (x, y, w, h) | Notes |
|---------|----------------------|-------|
| Star row (★ rating CP-7) | (340, 1280, 400, 100) | 3 star slots 120px each, 좌→우 fade-in 0.3s/별 |
| Total score | (60, 1390, 960, 70) | "Score 92%" 56pt bold, center, count-up 0→92 over 0.8s |
| Sub label | (60, 1460, 960, 30) | "Total accuracy" 20pt, opacity 0.6 |

### 1.4 §2 Score Breakdown — 6 rows (Y 1480~2200, 720h)

> **CP-28 score_breakdown_row** 6회 반복. 각 row 110px height + 10px gap.

| Row | Label (en / kr) | Value example | Bar/icon | y |
|-----|-----------------|---------------|----------|---|
| 1 | Prep / 손질 | ★★★ +24% | bar 0~100% | 1500 |
| 2 | Cook / 조리 | ★★☆ +18% | bar | 1610 |
| 3 | Seasoning / 양념 | ★★★ +22% | bar | 1720 |
| 4 | Plating / 플레이팅 | ★★☆ +15% | bar | 1830 |
| 5 | Compat bonus / 궁합 보너스 | +15% | gold tint | 1940 |
| 6 | Mood bonus / 기분 보너스 | +5% | mood color tint | 2050 |
| Total | Reward multiplier | **× 1.20** | summary band | 2160 |

> 현재 cooking-mechanics §5는 prep/method/timing 3 axis. **plating/seasoning은 future-proof (post-launch)** — MVP에서는 plating/seasoning row = "—" 또는 hide. game-designer M2 confirm 필요.

### 1.5 §3 Rewards (Y 2210~2700, 490h)

> **CP-29 reward_box** 단일 panel + 내부 4 component:

| Component | Position (x, y, w, h) | Anim |
|-----------|----------------------|------|
| Reward panel BG | (60, 2210, 960, 480) | cream rounded panel |
| 💰 Coins earned | (100, 2240, 880, 80) | "+1,800 ₩" 48pt Sesame Gold, count-up 0→1800 over 1.0s |
| 📖 Recipe XP | (100, 2330, 880, 60) | "+24 XP (Tteokbokki)" 32pt |
| ♥ Friendship gained | (100, 2400, 880, 60) | "+12 with Mina" 32pt |
| Friendship bar | (100, 2470, 880, 50) | CP-29 sub: bar fill anim start→end, "Lv 2 (60/100)" label below |
| Milestone unlock (conditional) | (100, 2540, 880, 130) | CP-32 milestone_toast inline expand (Lv 3/7/10만) |

### 1.6 §5 Sticky CTA Bar (Y 1700~1860, stationary)

> ScrollContainer 외부 CanvasLayer. 스크롤 위치 무관 항상 표시.

| Button | Position (x, y, w, h) | Style |
|--------|----------------------|-------|
| BG strip | (0, 1700, 1080, 220) | cream + shadow top edge (스크롤 영역과 분리감) |
| **Cook Again** (primary) | (40, 1740, 300, 140) | Persimmon BG, 36pt Bold white. **동일 음식 + 동일 게스트 즉시 재시작.** |
| **Choose Other Guest** | (380, 1740, 380, 140) | Sesame Gold BG, 32pt Bold. **동일 음식, Guest Select v2로 복귀.** |
| **Back to Menu** | (800, 1740, 240, 140) | Cream + outline, 28pt regular. **Menu Select로 복귀.** |

**CTA 선택 근거**:
- Primary = Cook Again (실패/성공 무관 가장 빈번 → 좌측, 가장 큰 viz weight)
- Secondary = Choose Other Guest (Guest 2.0 sprint의 hook — 다른 손님 시도 유도)
- Tertiary = Back to Menu (이탈)

### 1.7 §6 UX polish — animation placeholders

> §3 timing sequence 참조.

---

## 2. Animation Sequence Timing (0~5.5s reveal)

> Round 종료 → ResultScreen v2 fade-in **0.5s** 직후부터 시작. 사용자 tap 시 모든 anim 즉시 skip (final state로 jump).

```
t (sec)  0    0.5   1.0   1.5   2.0   2.5   3.0   3.5   4.0   4.5   5.0
         │    │     │     │     │     │     │     │     │     │     │
[Scene fade-in]                                                       
─────●═══●                                                            
                                                                      
[Dish image scale 0.94→1.0 + idle bob loop]                          
       ●═══●═══●═══...                                                
                                                                      
[Guest avatar fade-in + mood badge pop]                              
            ●═══●                                                     
                                                                      
[Compat large badge fade-in + bar fill 0→92%]                        
                 ●═══●═══●                                            
                                                                      
[Speech bubble slide-up from y+40 + reaction text typewriter]         
                            ●═══●═══●                                 
                                                                      
[Guest reaction sprite swap (neutral → excellent) + 1.14x bounce]    
                                    ●═●═●                             
                                                                      
[★ Stars fade-in 0.3s/star (좌→우)]                                  
                                          ●═●═●                       
                                                                      
[Total score count-up 0→92 over 0.8s]                                
                                                ●═══●═══●             
                                                                      
[NEW RECORD badge slide-in from top-right (conditional)]              
                                                      ●═══●           
                                                                      
[Sticky CTA bar slide-up from y+220]                                  
                                                            ●═══●     
                                                                      
[Sound stings]                                                        
🔊 result_open                                                        
              🔊 dish_settle                                          
                       🔊 compat_reveal                               
                                  🔊 reaction_text_typing             
                                          🔊 star_chime ×N            
                                                      🔊 new_record   
                                                                      
[user can scroll after t=4.5s — Score Breakdown / Rewards reveal     
 happens on scroll (lazy fade-in per row 0.2s stagger as it enters    
 viewport).]                                                          

t (sec)  5.0   5.5  ...   on scroll
[Score Breakdown 6 rows sequential reveal (only when scrolled into view)]
         row1 ●═●                                                      
              row2 ●═●                                                 
                   row3 ●═●                                            
                        row4 ●═●                                       
                             row5 ●═●                                  
                                  row6 ●═●                             
                                                                      
[Coin count-up 0→1800 over 1.0s (triggered on §3 reward panel enter viewport)]
         ●═══●═══●═══●═══●                                            
                                                                      
[Friendship bar fill 0→target_xp over 1.2s]                          
                       ●═══●═══●═══●═══●                              
                                                                      
[Milestone unlock toast (Lv 3/7/10) — slide-down + sparkle particle]  
                                          ●═══●                       
```

### 2.1 Timing 표 (각 element 명시)

| Element | Start (s) | Duration (s) | Easing | Notes |
|---------|-----------|--------------|--------|-------|
| Scene fade-in | 0.0 | 0.5 | linear | Control.modulate.a 0→1 |
| Dish image | 0.5 | 0.35 | SINE | scale 0.94→1.0 + alpha 0→1 |
| Dish idle bob | 0.85 | loop 3.2s | SINE | y ±8 sine, 무한 |
| Guest avatar fade-in | 0.8 | 0.4 | SINE | alpha 0→1 |
| Guest mood badge pop | 1.0 | 0.3 | BACK out | scale 0.8→1.0 |
| Compat large badge | 1.0 | 0.5 | linear | alpha 0→1 |
| Compat bar fill | 1.2 | 0.8 | OUT_CUBIC | progress 0→target_pct |
| Speech bubble | 1.6 | 0.4 | BACK out | y+40→y, alpha 0→1 |
| Reaction text typewriter | 1.8 | 1.2 | linear | char-by-char 약 40 chars/s |
| Guest reaction sprite swap | 2.4 | 0.0 | — | texture swap (neutral → mood sprite) |
| Guest reaction bounce | 2.4 | 0.4 | BACK out | scale 1.0→1.14→1.0 |
| ★ Star 1 fade-in | 3.0 | 0.3 | SINE | alpha + scale 0.8→1.0 |
| ★ Star 2 fade-in | 3.3 | 0.3 | SINE | (위와 동일) |
| ★ Star 3 fade-in | 3.6 | 0.3 | SINE | ★3일 때만 particle burst trigger |
| Total score count-up | 3.6 | 0.8 | OUT_CUBIC | Label.text 0→target_pct |
| NEW RECORD badge | 4.2 | 0.5 | BACK out | from x+200→x 좌측 slide + alpha |
| Sticky CTA bar | 4.5 | 0.4 | OUT_CUBIC | y+220→y slide-up |
| **Total above-the-fold sequence** | — | **~5.0s** | — | 5-second rule 살짝 over, 사용자 tap으로 skip 가능 |
| Score row 1 (on scroll) | scroll trigger | 0.3 | SINE | bar fill 0→pct + label alpha |
| Score row 2~6 | +0.2 stagger | 0.3 each | SINE | sequential |
| Coin count-up (on §3 viewport) | scroll trigger | 1.0 | OUT_CUBIC | 0→target_won |
| Friendship bar fill | scroll trigger + 0.2 | 1.2 | OUT_CUBIC | start_xp → end_xp |
| Milestone toast | scroll trigger + 1.2 | 0.6 | BACK out | (Lv 3/7/10 only) slide-down + sparkle |

### 2.2 Skip 처리

- 사용자 tap (어디든) → **모든 in-progress Tween skip → final state**.
- skip 이후에도 dish idle bob loop는 유지 (정서 hook).
- Sticky CTA bar는 skip 직후 즉시 interactive 활성.

---

## 3. Emotion Reaction Visual Mapping (CP-30)

> **권고: mood_badge (CP-26) sprite asset 재활용** + speech bubble + reaction text 조합. 신규 reaction asset 비용 0.

### 3.1 4-tier mood ↔ sprite mapping

| Score tier | Mood label | Sprite (CP-26 reuse) | BG tint | Particle | Sound |
|------------|------------|----------------------|---------|----------|-------|
| **Excellent** (★3, 90+%) | "loved" | mood `happy` 😍 (pink tint) | Pink `#F4A2C7` 20% | ♥ + ✨ burst | `reaction_loved` |
| **Good** (★2, 75~89%) | "liked" | mood `hungry` 😋 (gold tint) | Gold `#FFC857` 15% | ✨ subtle | `reaction_liked` |
| **Okay** (★1, 50~74%) | "okay" | mood `easy` 🙂 (neutral) | Neutral 0% | — | `reaction_okay` |
| **Bad** (0★, <50%) | "didn't like" | mood `grumpy` 😡 (red tint) | Red `#E63946` 15% | (none) | `reaction_bad` |

### 3.2 Reaction text 예시 (game-designer M2 lock)

> 음식 axis (spicy/sweet/salty/oily/mild) × guest like/dislike 매트릭스에서 자동 생성. friends-system v0.3 §2 Voice 톤 참조.

```
# Excellent (★3) — guest like axis match
"Mina loved the spicy kick!"
"미나가 매콤한 맛에 푹 빠졌어요!"

# Good (★2) — partial match
"Junho liked it, but wanted more savory depth."
"준호가 좋아했지만 짭조름함이 조금 부족했어요."

# Okay (★1) — neutral
"Mom said it was okay."
"엄마는 괜찮다고 하셨어요."

# Bad (0★) — dislike axis match
"Dad pushed it away — too oily for him."
"아빠는 기름져서 한 입만 드셨어요."
```

**Text generation rule (game-designer M2)**:
```
if score >= 0.90:
    template = LOVED_TEMPLATE[matched_like_axis]  # 5 axis × 1 template
elif score >= 0.75:
    template = LIKED_TEMPLATE[partial_match_axis]
elif score >= 0.50:
    template = OKAY_NEUTRAL[guest_id]  # generic per guest
else:
    template = BAD_TEMPLATE[matched_dislike_axis]
```

### 3.3 Avatar swap timing

- Round 종료 시점: avatar **neutral** sprite (CH-XX_neutral).
- t=2.4s (reaction trigger): texture swap → mood sprite (`happy/hungry/easy/grumpy`).
- Bounce 1.14x scale (BACK out) + 동시 BG tint fade-in (0.3s).
- 사운드 sting 1회.

---

## 4. Milestone Unlock Visual (Lv 3/7/10)

### 4.1 적용 임계

> friends-system v0.3 § 친구 Lv 시스템 정합. M2 game-designer confirm.

| Lv | Milestone | Reward example |
|----|-----------|----------------|
| **Lv 3** | "Close Friend" | +500 ₩ bonus + 카드 frame upgrade |
| **Lv 7** | "Best Friend" | +1500 ₩ bonus + new outfit unlock |
| **Lv 10** | "Soulmate" | +3000 ₩ + special recipe unlock |
| (Lv 2, 4~6, 8~9) | (no milestone) | XP only |

### 4.2 시각 spec — **inline expand within §3 Rewards** (NOT modal)

> **권고: inline expand within reward_box (CP-29) panel**. 별도 modal/banner = 흐름 끊김.

```
┌────────────────────────────────────────┐
│ §3 Rewards panel                       │
│ 💰 +1,800 ₩                            │
│ 📖 +24 XP                              │
│ ♥ Mina +12                             │
│ [▓▓▓▓▓▓▓░░] Lv 2 → 3 (60/100→0/200)   │
│                                        │
│  ┌──────────────────────────────────┐  │  ← expand on Lv 3/7/10 trigger
│  │ ✨ MILESTONE UNLOCKED ✨         │  │   gold gradient BG
│  │   Close Friend! (Lv 3)           │  │   36pt bold
│  │   +500 ₩ bonus  +card frame      │  │   sparkle particle
│  └──────────────────────────────────┘  │
│                                        │
└────────────────────────────────────────┘
```

### 4.3 Animation

| Step | t (relative to scroll-in) | Action |
|------|--------------------------|--------|
| 0 | 0.0s | Friendship bar 도달 후 0.3s 대기 |
| 1 | 0.3s | reward_box 자체 height 130px expand (Tween OUT_CUBIC) |
| 2 | 0.4s | Milestone toast BG fade-in + gold gradient |
| 3 | 0.5s | 텍스트 typewriter ("MILESTONE UNLOCKED" → milestone name → reward) |
| 4 | 0.8s | sparkle particle burst (GPUParticles2D 30 particles, 1s) |
| 5 | 0.8s | 🔊 `milestone_unlock` sting (sparkle + chime, 1.2s) |
| 6 | 2.0s | (전체 maintain 동안 미세 glow pulse 1Hz) |

### 4.4 Sound 강조

- 🔊 `milestone_unlock` = 2 layer (sparkle 0~0.3s + chime 0.3~1.2s).
- 다른 anim sound (count-up / bar fill)은 milestone trigger 시 -6dB ducking.

---

## 5. 3 CTA Placement (sticky bottom)

> §1.6 좌표 표 sync. 본 절은 인터랙션 결과/상태 spec.

### 5.1 Cook Again (primary, 좌측)

| 항목 | 값 |
|------|-----|
| Position | (40, 1740, 300, 140) |
| Style | Persimmon `#F4A261` gradient + Soy Dark 2px outline + drop shadow |
| Label | "Cook Again" 36pt Bold white + "한 번 더" 18pt sub |
| State (default) | idle + pulse 1Hz 살짝 (primary 강조) |
| State (pressed) | 0.95x flash 0.1s |
| Action | `pending_menu_id` 유지 + `pending_guest_id` 유지 → Round 즉시 재시작 (Scene 1 진입, fade 0.5s) |
| Sound | 🔊 `cta_primary_tap` |

### 5.2 Choose Other Guest (secondary, 중앙)

| 항목 | 값 |
|------|-----|
| Position | (380, 1740, 380, 140) |
| Style | Sesame Gold `#FFC857` BG + Soy Dark outline + shadow |
| Label | "Choose Other Guest" 32pt Bold + "다른 손님 고르기" 18pt sub |
| State (default) | idle |
| State (pressed) | 0.95x flash |
| Action | `pending_menu_id` 유지 + `pending_guest_id` 클리어 → `guest_select.tscn` (Guest Select v2) 진입 (slide-down 0.4s) |
| Sound | 🔊 `cta_secondary_tap` |

### 5.3 Back to Menu (tertiary, 우측)

| 항목 | 값 |
|------|-----|
| Position | (800, 1740, 240, 140) |
| Style | Cream `#F8E9D2` BG + Soy Dark 1px outline (less weight) |
| Label | "Menu" 28pt Regular + "메뉴" 16pt sub |
| State (default) | idle |
| State (pressed) | 0.95x flash |
| Action | `pending_menu_id` + `pending_guest_id` 모두 클리어 → `menu_select.tscn` 진입 (fade 0.6s) |
| **Side-effect** | Interstitial 광고 트리거 조건 평가 (3 레벨마다 1회, screen-flow §2.1) |
| Sound | 🔊 `cta_tertiary_tap` |

### 5.4 시각 weight 매핑

```
viz weight:  Cook Again > Choose Other Guest > Menu
            (300×140)     (380×140 secondary)  (240×140 tertiary)
            primary       secondary             tertiary
            persimmon     gold                  cream
            pulse 1Hz     static                static
```

---

## 6. Save Compatibility (friendship + best score)

### 6.1 신규 save schema (Autoload `SaveManager.gd` 위임)

```gdscript
# resources/save/save_data.tres 신규 필드
{
    "friendship": {
        "mother_01": {"lv": 3, "xp_in_lv": 60, "xp_total": 360},
        "father_01": {"lv": 2, "xp_in_lv": 30, "xp_total": 130},
        "mina": {...}, "junho": {...}, ...
    },
    "best_scores": {
        # key = "menu_id::guest_id" composite
        "f_tteokbokki::mina": {"score": 0.92, "stars": 3, "ts": 1717488000},
        "f_tteokbokki::junho": {"score": 0.85, "stars": 3, "ts": ...},
        ...
    },
    "milestones_unlocked": {
        "mina": [3],  # Lv 3 unlocked, Lv 7/10 pending
        ...
    }
}
```

### 6.2 Old save migration

> godot-dev 책임. 본 문서는 UX 측면 결정만.

| Old field | New field | Migration |
|-----------|-----------|-----------|
| (없음 friendship) | `friendship.{guest}` | default = Lv 0, xp 0 |
| `best_score.{menu_id}` (guest 무관) | `best_scores.{menu_id}::{guest_id}` | 기존 = `best_scores.{menu_id}::__legacy__` 키로 보존 |
| (없음 milestones) | `milestones_unlocked.{guest}` | default = [] |

### 6.3 NEW RECORD 판정

```gdscript
# UI 측 호출 (godot-dev 구현)
var key = "%s::%s" % [menu_id, guest_id]
var prev = SaveManager.best_score(key)
var new_best = score > prev
if new_best:
    SaveManager.save_best_score(key, score, stars)
# UI: new_best == true 시 CP-31 NEW RECORD badge 노출 (t=4.2s anim)
```

### 6.4 Legacy result_screen.gd 처리

- 기존 `result_screen.gd` (구 inline reveal)는 **deprecated** (rhythm_proto 내부 reveal로 대체된 이력).
- v2 sprint = **new `scenes/ui/result_screen_v2.tscn`** + `scripts/ui/result_screen_v2.gd` 신설.
- Round → 기존 inline reveal 폐기 → `result_screen_v2.tscn` 풀스크린 진입으로 통합 (screen-flow §5 v0.5 정합).

---

## 7. Layout Decisions Log

| # | 결정 | 근거 |
|---|------|------|
| RS-01 | 단일 ScrollContainer screen (옵션 A) | 5-sec rule = Summary + Reaction above-the-fold / Breakdown/Rewards = progressive disclosure |
| RS-02 | Emotional Reaction (§4) > Total Score (§7) **위에 배치** | "감정 hook → 점수" 흐름. cooking-mech §6.3 정합 |
| RS-03 | Mood sprite (CP-26) reuse for emotion reaction | 신규 reaction asset 비용 0, 일관성 ↑ |
| RS-04 | Milestone unlock = inline expand within §3 Rewards (NOT modal) | 흐름 끊김 회피, scroll narrative 유지 |
| RS-05 | 3 CTA = sticky bottom (ScrollContainer 외부) | 스크롤 위치 무관 도달성 100% |
| RS-06 | CTA 시각 weight: Cook Again > Choose Other Guest > Menu | primary = 재시도 빈도 최대, secondary = Guest 2.0 sprint hook |
| RS-07 | Above-the-fold reveal sequence = 0~5s (5-sec rule 살짝 over) | scene fade 0.5s 포함, 사용자 tap skip 가능 |
| RS-08 | Score Breakdown / Rewards = lazy reveal on scroll-into-viewport | 진입 시 모든 anim 동시 = noise, scroll trigger로 분산 |
| RS-09 | best_score key = `menu_id::guest_id` composite | guest 별 NEW RECORD 추적 가능 (Guest 2.0 정합) |
| RS-10 | Legacy result_screen.gd deprecate, v2 PackedScene 신설 | rhythm_proto inline reveal도 폐기, 풀스크린 v2로 통합 |

---

## 8. ⚙️ Confirm / 다음 sprint 이월

1. **plating / seasoning row 데이터 source** — game-designer M2. 현재 cooking-mech §5는 prep/method/timing 3 axis만. plating/seasoning은 future-proof — MVP에서 row hide vs "—" 표기 vs 3 row만 표시 (4 row 제거) — pm/game-designer 확정.
2. **reaction_text 템플릿 LOVED/LIKED/OKAY/BAD axis별** — game-designer M2. friends-system v0.3 §2 Voice 톤 참조하여 5 axis × 4 tier = 20 template 작성.
3. **friendship XP 곡선 (Lv 1→10)** — game-designer M2. 각 Lv 임계 xp / round당 +xp 공식 / Lv 3/7/10 milestone reward 값.
4. **best_score `__legacy__` migration policy** — godot-dev / pm 확정. legacy score를 어느 guest에 귀속 vs default guest로 분배 vs 그냥 별도 표시.
5. **Interstitial 광고 트리거 Back to Menu 시 정확히** — godot-dev sync. 3 레벨 마다 1회는 cooking-mech 정합, 본 RS는 hook만.
6. **sound sting ID 명명** — sound-guide.md 신설 시점 (M2~M3).
7. **CP-31 NEW RECORD badge sprite art** — art-director Post-M1. gold ribbon + sparkle, 400×80 정사각 또는 가로형.
8. **CP-32 milestone_toast badge sprite** — art-director Post-M1. Lv 3 (Close Friend) / Lv 7 (Best Friend) / Lv 10 (Soulmate) 3종 icon.

---

## 9. 변경 이력
- **2026-06-04 v0.1** — 초안. Result Screen 2.0 sprint, 단일 ScrollContainer + sticky CTA + 7 sections placement + animation sequence 0~5s + emotion reaction mood_badge reuse + milestone inline expand + save schema v2. components v0.5 (CP-28~32) / screen-flow v0.5 sync. 의존: game-designer M2 (plating/seasoning row / reaction template / friendship XP curve / milestone reward) + art-director Post-M1 (NEW RECORD + milestone badge sprite) + godot-dev (PackedScene + Tween 구현 + save migration).
