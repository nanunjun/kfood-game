# UI Components — 재사용 컴포넌트 카탈로그

> 버전: **v0.6** · 갱신일: 2026-06-04 · 작성자: ui-designer
> 상위 문서: [`screen-flow.md` v0.5](screen-flow.md), [`scene-2-kitchen-layout.md` v0.1](scene-2-kitchen-layout.md), [`tier-1-2-flow.md`](tier-1-2-flow.md), [`ftue.md`](ftue.md), [`guest-select-v2-layout.md` v0.1](guest-select-v2-layout.md), [`food-select-compat.md` v0.1](food-select-compat.md), [`result-screen-v2-layout.md` v0.1](result-screen-v2-layout.md), [`visual-audit-2026-06.md` v0.1](visual-audit-2026-06.md), [`premium-redesign-v1.md` v0.1](premium-redesign-v1.md), [`../art-style-guide.md`](../art-style-guide.md), [`../systems/cooking-mechanics.md` v0.6](../systems/cooking-mechanics.md), [`../friends-system.md` v0.3](../friends-system.md), [`../decisions.md` ADR-004](../decisions.md#adr-004-엔진-선택--godot-46-gdscript-only-채택-claudemd-implicit-unity-정식-대체), [`../decisions.md` ADR-005](../decisions.md#adr-005), [`../decisions.md` ADR-007](../decisions.md#adr-007)
>
> **v0.6 변경 (2026-06-04)**: **Premium Redesign v1 시각 컴포넌트 CP-33~41 9종 신설**. Royal Match / Travel Town / Cooking Madness / Merge Mansion 4 reference 게임 시각 패턴 차용 lock. CP-33 glossy_button (gradient + inner highlight + outer lip + Tween, 4 screen CTA 공통) / CP-34 drop_shadow_card (12~16px Y-offset soft shadow, 모든 card 공통) / CP-35 sparkle_particle (GPUParticles2D 16 radial burst 0.4s, PERFECT/NEW RECORD/best card) / CP-36 character_idle_animator (Tween scale 1.0→1.02 loop 2s, 모든 avatar) / CP-37 hero_number_bounce (scale 0.5→1.2→1.0 0.6s + gradient gold + halo, Score / compat % / coin count) / CP-38 gold_ribbon_banner (540×100 gold ribbon + sparkle 24 + slide-in from top, NEW RECORD / TODAY'S PICK / milestone) / CP-39 coin_spray_particle (20 coin GPUParticles2D from origin to HUD wallet, Result reward + Cooking PERFECT) / CP-40 now_cooking_banner (dish thumb 80 + name + guest avatar 60 + "for X", Cooking 8 module 공통) / CP-41 step_progress_dots (●○○○ 4 dot, current = gold filled scale 1.2, Cooking step). §16 Z-order에 premium visual layer (drop shadow Z=45 / glossy inner highlight Z=55 / NEW RECORD hero ribbon Z=180 / sparkle burst Z=200 / coin spray Z=210) 추가. Decisions PR-1~8 신설 (`premium-redesign-v1.md` §10). Confirm #23~28 신설. 의존: art-director (sparkle particle PNG / steam particle PNG / speech bubble round template, this sprint) + godot-dev (P0 32h, 1-week sprint).
>
> **v0.5 변경 (2026-06-04)**: **Result Screen 2.0 컴포넌트 CP-28~32 5종 신설** — CP-28 score_breakdown_row (6 row 공통 컴포넌트, label/star/value/bar) / CP-29 reward_box (coins count-up + XP + friendship bar fill + milestone inline expand) / CP-30 emotion_reaction (avatar + speech bubble + reaction text, mood_badge sprite 재활용) / CP-31 new_record_badge (gold ribbon slide-in, best score 갱신 시) / CP-32 milestone_toast (Lv 3/7/10 unlock 시 inline expand, gold gradient + sparkle particle). §16 Z-order에 Result Screen layer (Sticky CTA 100 / ScrollContainer content 50 / Emotion reaction speech bubble 60 / NEW RECORD overlap 70 / Milestone toast inline 65) 추가. Decisions CP-16~20 신설 + Confirm #17~22 신설. 상위 신규 문서 `result-screen-v2-layout.md` v0.1 정합. 의존: game-designer M2 (plating/seasoning row data / reaction template 5 axis × 4 tier / friendship XP curve / milestone reward) + art-director Post-M1 (NEW RECORD ribbon + milestone Lv 3/7/10 badge) + godot-dev (PackedScene + Tween + save migration menu_id::guest_id composite key).
>
> **v0.4 변경 (2026-06-04)**: **Guest 2.0 컴포넌트 CP-23~27 5종 신설** — CP-23 guest_card_v2 (510×680, avatar + friendship + likes + dislikes + mood + reward + compat) / CP-24 compat_bar (0~100% bar + 컬러 + 라벨 삼중, Food Select mini-badge + Guest Select large badge 공유) / CP-25 flavor_tag_badge (5 axis like/dislike tag) / CP-26 mood_badge (5 mood overlay) / CP-27 reward_bonus_badge (% + ₩ full-width 띠). §16 Z-order에 Guest Select 카드 내부 layer (compat badge / mood overlay / RECOMMENDED 띠) 추가. Decisions CP-11~15 신설 + Confirm #11~14 신설. 상위 신규 문서 `guest-select-v2-layout.md` v0.1 + `food-select-compat.md` v0.1 정합. 의존: game-designer compat_score() + mood rotation + reward bonus 공식 lock (M2 pending).
> **MVP scope**: 본 카탈로그는 Tier 1·2 + 다점포 5가게 + 식탁 2종 + **ADR-005 4-stage** (Stage 2A/2B/2C) 운영에 필요한 컴포넌트만. Tier 3~5 / 파티 모드 컴포넌트는 post-launch.
> **엔진**: Godot 4.6 (GDScript only). 컴포넌트 = **Godot Scene (.tscn)** 단위로 1:1 매핑. 컨벤션은 ADR-004 참조 (파일명 `snake_case.tscn` / `snake_case.tres` / `snake_case.gd`, 클래스명 PascalCase).
> **Motion lock (v0.3)**: ADR-005 4-stage 신규 컴포넌트는 **Option 1 = Godot Transform animation** (단일 sprite 회전/이동, AnimationPlayer + Tween 조합). 회전 각도 변경 없이 Y position translation 또는 X position translation으로 motion 구현.

> **v0.3 변경 (2026-05-31)**: ADR-005 4-stage 메커닉 (Stage 2A 재료 준비 rhythm tap / Stage 2B 조리 방법 / Stage 2C 조리 시간) + ADR-007 basic_pantry kitchen rack 지원 컴포넌트 **CP-18~22 5종 신설**: CP-18 도마(cutting board) / CP-19 Knife indicator / CP-20 Tool sprite (TOOL-01~12 generic swap layer) / CP-21 Timing bar (Stage 2C 게이지) / CP-22 Kitchen rack (basic_pantry 옹기 5종). art lock 의존: CUT-00 + CUT-01~06 + TOOL-01~12 + ING-01~12 whole + ICUT-01~12 cut (모두 2026-05-31 LOCK 완료). 기존 §5 Timing bar (Stage 3 단일 화면 기준)는 ADR-005 4-stage 정합으로 **CP-21에 통합** — §5는 alias로 유지. §16 Z-order에 Stage 2A/2B/2C sub-flow 신규 layer 추가. Decisions Log CP-06~09 신설.

---

## 0. 표 읽는 법

- **State**: default / hover / pressed / disabled (모바일이라 hover는 long-press 시각 hint로만). Godot Control Node `theme_override` 또는 `AnimationPlayer` 기반으로 state 전환 구현.
- **Art tone**: `art-style-guide.md` §2 팔레트 / §3 라인 / §6 UI 규칙과 매핑.
- **Sound hook**: 인터랙션별 SFX 트리거 위치 (M2~M3 deferred, 위치만 mark) — 엔진 독립.
- ⚙️ = 다음 sprint(balance-config / asset) 확정 필요.
- **Godot 매핑 컨벤션 (v0.2)**:
  - 각 컴포넌트 = 1개 **Godot Scene (.tscn)** = `godot-project/scenes/ui/{snake_case}.tscn`
  - 데이터 정의(밸런스/색상 등)는 **Resource (.tres)** = `godot-project/resources/ui/{snake_case}.tres`
  - 동작 스크립트는 **GDScript** = `godot-project/scripts/ui/{snake_case}.gd` (class_name PascalCase)
  - 자산(art) 참조 = `godot-project/assets/` 하위 (art-style §8 export 폴더는 import 시 매핑)

---

## 1. 재료 카드 (Ingredient Card)

| 항목 | 값 |
|------|-----|
| 용도 | Scene 1 가게 내부 진열대, FTUE 안내 |
| 비율 | 1:1 정사각, 256×256 (art-style §8) |
| BG | 단색 크림 `#F8E9D2` + 미세 종이 텍스처 |
| 외곽 | 8px round, 라인 없음 (배경 분리) |
| 일러스트 | top-down 3/4 시점, specular 1점 |
| 라벨 | 재료명 한글 (Pretendard, 14pt) — 카드 하단 |
| **default** | 보통 배경, 살짝 그림자 |
| **hover (long-press 0.3s)** | 1.05x scale + Sesame Gold 외곽 글로우 |
| **pressed** | 0.95x scale + 0.1s flash |
| **disabled (FTUE 오답 잠금)** | 채도 -50% + 회색 오버레이 |
| Sound hook | 🔊 `pickup_chime` (정답), `wrong_shake` (오답) |
| 비고 | FTUE Step 1·2 한정 정답 글로우 모드 별도 |
| **Godot 매핑** | `scenes/ui/ingredient_card.tscn` (TextureButton + Label + 그림자 ColorRect). State는 `AnimationPlayer` 4 state. 재료 데이터는 `resources/ingredient/{name}.tres` (IngredientResource — `texture` / `display_name` / `store_id`). 스크립트 `scripts/ui/ingredient_card.gd` (class_name `IngredientCard`). |

---

## 2. 가게 선반 (Store Shelf)

| 항목 | 값 |
|------|-----|
| 용도 | Scene 1 가게 내부 — 재료 카드 진열 |
| Layout | 3×2 그리드 또는 가로 4열 1행 (재료 수에 따라 자동) |
| BG | §art-style §4.4 가게별 시그니처 컬러 + 소품 |
| 카드 간격 | 16px (1024px 기준) |
| **default** | 가게 BG 위에 카드 정렬 |
| **disabled (FTUE Step 1)** | 잠금 가게 4개는 🔒 회색 오버레이 |
| Sound hook | 🔊 `shelf_idle_loop` (정육 칼질 / 어물 얼음 등 가게별 ambient) |
| 비고 | 9개 이상 재료 시 좌우 스와이프 페이지 (cooking-mech §10.1 #3) |
| **Godot 매핑** | `scenes/ui/store_shelf.tscn` (GridContainer + IngredientCard 인스턴스). 가게별 시그니처 컬러는 `resources/store/{store_id}.tres` (StoreResource). 스와이프는 `ScrollContainer` + `scripts/ui/store_shelf.gd` (class_name `StoreShelf`). |

---

## 3. 시장 입구 Layout (Market Entrance)

| 항목 | 값 |
|------|-----|
| 용도 | Scene 1 입구 — 가게 5종 + 빈 칸 1 |
| Layout | **2×3 부채꼴 그리드** (screen-flow SF-01) |
| 간판 크기 | 화면 폭 20% 정사각 (1-thumb 안전영역) |
| 간판 디자인 | 시그니처 컬러 BG + 한글 + 이모지 1개 |
| **default** | 간판 idle (살짝 swaying 0.5s loop) |
| **hover (탭 직전)** | 0.05x 확대 + Sesame Gold 글로우 |
| **pressed** | 0.95x + 0.4s zoom-in 트랜지션 |
| **disabled (FTUE Step 1)** | 4개 가게 회색 + 🔒 (Step 2에서 잠금 1개 해제) |
| Sound hook | 🔊 `signboard_tap` + `store_enter_chime` |
| 빈 칸 처리 | post-launch 6번째 가게 슬롯 (양념가게 분리 후보) |
| **Godot 매핑** | `scenes/ui/market_entrance.tscn` (BG TextureRect + 5x StoreSignboard 인스턴스 + 빈 슬롯). 간판 = `scenes/ui/store_signboard.tscn` (PackedScene). swaying은 `AnimationPlayer` loop. 진입 트랜지션은 `scripts/ui/market_entrance.gd` (class_name `MarketEntrance`) → `SceneTree.change_scene_to_packed()`. |

---

## 4. 키친 도구 슬롯 (Cooking Tool Slot)

| 항목 | 값 |
|------|-----|
| 용도 | Scene 2 Stage 2 조리법 선택 카드 |
| 비율 | 1:1, 200×200 |
| BG | 크림 + 도구 일러스트 (가스레인지/무쇠팬/찜기/오븐) |
| 라벨 | 조리법 한글 ("끓이기/볶기/찌기/굽기") |
| **default** | idle |
| **pressed** | 0.95x + 도구로 재료 옮겨가는 0.5s 모션 트리거 |
| **disabled (FTUE Step 3)** | 정답 외 카드 회색 |
| **glow (FTUE 정답 표시)** | Sesame Gold 펄스 + 화살표 ↗ |
| Sound hook | 🔊 `method_correct` (정답), `method_wrong` (오답) |
| **Godot 매핑** | `scenes/ui/cooking_tool_slot.tscn` (TextureButton + Label + 글로우 ColorRect). 조리법 데이터 `resources/cooking_method/{name}.tres` (CookingMethodResource). FTUE glow는 별도 `AnimationPlayer` "ftue_glow" track. 스크립트 `scripts/ui/cooking_tool_slot.gd`. |

---

## 5. 타이밍 게이지 (Timing Bar) — DEPRECATED alias for CP-21 (v0.3)

> v0.3 (2026-05-31): ADR-005 4-stage 정합으로 **CP-21 Timing bar로 통합**. 본 §5는 alias만 유지 (기존 reference 호환). 최신 spec은 §21 CP-21 참조.

| 항목 | 값 |
|------|-----|
| 용도 | Scene 2 **Stage 2C** (구 Stage 3) — 가로 게이지 + 인디케이터 |
| 비율 | 가로 전체 폭 0.8 × 60px 높이 |
| 구간 색상 | miss = 회색 / good = Sesame Gold 50% / **PERFECT** = Sesame Gold 100% + 빗금(접근성, cooking-mech §10.1 #6) |
| 인디케이터 | 흰 화살표 ▼, 좌→우 왕복 |
| **default** | PERFECT 폭 10% (T1 default) |
| **rewarded ad 적용 / FTUE** | PERFECT 폭 20% 확대 |
| **pressed (탭 시)** | 0.2s flash + 판정 결과 텍스트 ("PERFECT!" / "GOOD" / "MISS") |
| Sound hook | 🔊 `tap_perfect` / `tap_good` / `tap_miss` 차등 |
| 접근성 | 색상 + 빗금 이중 (color-blind safe) |
| **Godot 매핑** | `scenes/ui/timing_bar.tscn` (TextureProgressBar + 인디케이터 Sprite2D + 빗금 TextureRect). 인디케이터 이동은 `Tween` (좌→우 왕복). PERFECT 폭 데이터는 `resources/timing/{food_id}.tres` (TimingResource — `perfect_width` / `good_width` / `cook_time`). 스크립트 `scripts/ui/timing_bar.gd` (class_name `TimingBar`). |

---

## 6. 식탁 캐릭터 영역 (Diner Character Area)

| 항목 | 값 |
|------|-----|
| 용도 | Scene 3 식탁 — 캐릭터 시식 reaction 표시 |
| 캐릭터 비율 | art-style §3.1 (머리:몸 1:1.5~2.0, chibi) |
| 시점 | 3/4 또는 7/8 정면 |
| Layout (Tier 1) | 1인 중앙 |
| Layout (Tier 2) | 2~3인 가로 정렬 (주인공·어머니·아버지) |
| **idle (시식 전)** | Neutral 표정 |
| **eat motion (0.8s)** | 한 입 먹는 모션 |
| **★3 reaction** | Happy 표정 (입 벌림 "와!") + 하트/별 VFX |
| **★1·★2 reaction** | Subtle 표정 (살짝 끄덕) |
| **preference match (T2)** | 해당 캐릭터 reaction 0.3s 먼저 + ♡ VFX |
| Sound hook | 🔊 `eat_chomp` (시식), `reaction_star3` / `reaction_subtle` |
| 비고 | art anchor CH-01~CH-05 (art-style §9.1). **양친 L11 동시 unlock 후 L11~25 식탁 3인 일관** (tier-1-2-flow §3.2 / §3.4) |
| **Godot 매핑** | `scenes/ui/diner_character_area.tscn` (HBoxContainer + 1~3x `diner_character.tscn` 인스턴스). 각 캐릭터 = `scenes/ui/diner_character.tscn` (Sprite2D + `AnimationPlayer` (idle / eat / star3_happy / subtle)). 캐릭터 데이터 `resources/character/{character_id}.tres` (CharacterResource — `texture_neutral` / `texture_happy` / `texture_subtle` / `preferences`). 스크립트 `scripts/ui/diner_character.gd` (class_name `DinerCharacter`). |

---

## 7. ★ Rating 표시 (Star Rating)

| 항목 | 값 |
|------|-----|
| 용도 | Scene 3 점수 등급 표기 |
| 별 색상 | Sesame Gold `#FFC857` + 흰 specular |
| 위치 | 점수 텍스트 위, 가로 정렬 3개 슬롯 |
| **★0 (0~49점)** | 회색 별 3개 |
| **★1 (50~74)** | 첫 별만 Gold + sparkle |
| **★2 (75~89)** | 별 2개 Gold + sparkle |
| **★3 (90+)** | 별 3개 Gold + **particle burst** + small chime |
| Sound hook | 🔊 `score_tally` (등장), `star3_chime` (★3 한정) |
| 애니메이션 | 좌→우 순차 fade-in 0.3s/별 |
| **Godot 매핑** | `scenes/ui/star_rating.tscn` (HBoxContainer + 3x TextureRect 별 + particle GPUParticles2D). 좌→우 fade는 `AnimationPlayer` "stars_in". 스크립트 `scripts/ui/star_rating.gd` (class_name `StarRating`) — `show_rating(stars: int, score: int)`. |

---

## 8. 타이머 (Timer Bar)

| 항목 | 값 |
|------|-----|
| 용도 | Scene 1 공통 / Scene 2 Stage 2 |
| 비율 | 가로 전체 0.7 × 24px |
| 색상 | 100~50% = Persimmon `#F4A261` / 50~20% = Gochu Red `#E63946` / 20~0% = 펄스 빨강 |
| **default** | 부드러운 감소 (1초 단위) |
| **50% 트리거** | 색 전환 + `📺 힌트` 버튼 활성 |
| **20% 트리거** | 펄스 애니 0.3s 주기 |
| **0% 만료** | Stage 강제 종료 + 결과 처리 |
| Sound hook | 🔊 `timer_warn_50` (50% 전환), `timer_warn_20` (20% 펄스) |
| **Godot 매핑** | `scenes/ui/timer_bar.tscn` (TextureProgressBar + `Timer` 노드). 색 전환은 `AnimationPlayer` "warn_50" / "warn_20". 50% 트리거에서 `signal warn_50_reached` emit → Hint 버튼 활성. 스크립트 `scripts/ui/timer_bar.gd` (class_name `TimerBar`). |

---

## 9. 코인 HUD (Coin HUD)

| 항목 | 값 |
|------|-----|
| 용도 | 상단 HUD 좌측 — 보유 코인 표기 |
| Layout | `💰 [숫자]` 가로 정렬 |
| Font | Pretendard Bold 16pt |
| Color | Sesame Gold + Soy Dark 외곽 1px |
| **default** | idle |
| **+X 트리거 (보상)** | "+50" 초록 텍스트 0.6s float-up 후 fade |
| **-X 트리거 (사용)** | "-100" 빨강 텍스트 동일 |
| **pressed** | 0.95x + 상점 화면 진입 |
| Sound hook | 🔊 `coin_get` / `coin_spend` |
| **Godot 매핑** | `scenes/ui/coin_hud.tscn` (TextureRect 💰 + Label + float-up Label 인스턴스). float-up은 `Tween` (Label position.y -= 30 over 0.6s + modulate.a fade). 스크립트 `scripts/ui/coin_hud.gd` (class_name `CoinHud`). 잔액은 `Autoload` SaveSystem (싱글톤)에서 구독. |

---

## 10. Hint 버튼 (Rewarded Ad Hint)

| 항목 | 값 |
|------|-----|
| 용도 | Scene 1 Stage 1 — 50% 타이머 이후 활성 |
| 위치 | 화면 우측 하단 |
| 디자인 | 라탄 바구니 + 📺 아이콘 (art-style §6.1) |
| **disabled (타이머 50% 초과)** | 회색 + 자물쇠 |
| **default (50% 이하)** | Persimmon 펄스 |
| **pressed** | 0.95x + 광고 SDK 호출 |
| **after-use (Round당 1회)** | 회색 + "사용됨" |
| Sound hook | 🔊 `hint_unlock` (활성 전환), `hint_use` (탭) |
| **Godot 매핑** | `scenes/ui/hint_button.tscn` (TextureButton + 라탄 바구니 일러스트 + 자물쇠 ColorRect overlay). 펄스는 `AnimationPlayer` "active_pulse". 광고 SDK 호출은 `Autoload` AdManager(`scripts/ads/ad_manager.gd`)의 `show_rewarded()` 메서드 → AppLovin MAX Godot plugin (ADR-004). 스크립트 `scripts/ui/hint_button.gd`. |

---

## 11. 요리 카드 (Food Card)

| 항목 | 값 |
|------|-----|
| 용도 | Scene 1·2 상단 floating — 현재 요리 표시 |
| 비율 | 가로 long card, 512×120 |
| BG | 크림 + 한지 손글씨 폰트 |
| 구성 | 좌측: 요리 일러스트 / 중앙: 이름 + 인분 배지 / 우측: 재료 N개 카운터 |
| 인분 배지 (T1) | Cream BG + "1인분" 텍스트 |
| 인분 배지 (T2) | Gochu Red BG + "2인분" + ★ 가족 라벨 |
| **5가게 음식 (김밥)** | 하단 `🥬🥩🐟🌾🫙 0/5` 인디케이터 추가 (떡국은 v2.0 reshuffle로 post-launch 격리) |
| Sound hook | 🔊 `round_start_jingle` (등장) |
| **Godot 매핑** | `scenes/ui/food_card.tscn` (HBoxContainer = 일러스트 TextureRect + VBoxContainer(이름 Label + 인분 배지 Panel) + 재료 카운터 Label + 가게 인디케이터 HBoxContainer). 음식 데이터 `resources/food/{food_id}.tres` (FoodResource — `display_name` / `serving_count` / `tier` / `ingredient_ids` / `store_ids`). 등장 모션은 `AnimationPlayer` "round_start". 스크립트 `scripts/ui/food_card.gd` (class_name `FoodCard`). |

---

## 12. 장바구니 미리보기 (Cart Preview)

| 항목 | 값 |
|------|-----|
| 용도 | Scene 1 입구·가게 내부 양쪽 — 픽업 진행 표시 |
| 위치 | 하단 우측, 라탄 바구니 아이콘 + 카운터 `🛒 2/4` |
| **default** | idle |
| **pickup 트리거** | 카드가 바구니로 슬라이드 인 0.3s 모션 |
| **pressed (확장)** | 모달 — 픽업한 재료 리스트 + 남은 재료 카운트 |
| Sound hook | 🔊 `cart_add` |
| **Godot 매핑** | `scenes/ui/cart_preview.tscn` (TextureButton + Label 카운터). 슬라이드 인 모션은 `Tween` (picked card duplicate → 바구니 위치로 이동). 확장 모달은 `scenes/ui/cart_modal.tscn` (PackedScene). 상태는 `Autoload` RoundState 싱글톤 구독. 스크립트 `scripts/ui/cart_preview.gd` (class_name `CartPreview`). |

---

## 13. CTA Button (공용)

| 항목 | 값 |
|------|-----|
| 용도 | 모든 화면 다음 액션 ("플레이" / "다음 요리" / "메뉴로" / "함께 요리하기") |
| 비율 | 가로 280 × 세로 72 (1-thumb 친화) |
| BG | Persimmon `#F4A261` gradient + 외곽 Soy Dark 2px |
| Font | Pretendard Bold 20pt 흰색 |
| **default** | idle + soft drop shadow |
| **hover (long-press)** | 1.05x + Sesame Gold 외곽 글로우 |
| **pressed** | 0.95x + 0.1s flash |
| **disabled** | 채도 -60% + 회색 |
| Sound hook | 🔊 `button_tap` |
| Anchored CTA | FTUE 시 단일 highlighted CTA = 펄스 0.5s 주기 추가 |
| **Godot 매핑** | `scenes/ui/cta_button.tscn` (Button + 그림자 ColorRect). theme override = `resources/ui/cta_button_theme.tres`. State 전환은 `theme_override_styles` + `Tween`. FTUE 펄스는 별도 `AnimationPlayer` "ftue_pulse" loop. 스크립트 `scripts/ui/cta_button.gd` (class_name `CtaButton`) — `set_label(text)` / `set_pulse(enabled)`. |

---

## 14. Toast 알림

| 항목 | 값 |
|------|-----|
| 용도 | 짧은 안내 ("이 가게에는 없어요" / "장보기 완료!" / 다점포 미세 hint) |
| 위치 | 화면 중앙 또는 상단 1/3 |
| BG | Soy Dark 80% + 흰 텍스트 |
| 등장 | 0.3s fade-in |
| 유지 | 1.5s default (다점포 hint는 2.0s) |
| 종료 | 0.3s fade-out 자동 |
| Sound hook | 🔊 `toast_appear` (subtle) |
| **Godot 매핑** | `scenes/ui/toast.tscn` (Panel + Label + `Timer`). fade는 `AnimationPlayer` "toast_in_out" (in 0.3s → hold 1.5/2.0s → out 0.3s). `Autoload` ToastManager(`scripts/ui/toast_manager.gd`)를 통해 전역 호출: `Toast.show("메시지", duration)`. |

---

## 15. Pause / 모달 (Pause Menu, FTUE Modal, Unlock 컷씬)

| 항목 | 값 |
|------|-----|
| 용도 | 일시정지 / FTUE step transition / **양친 동시 unlock 컷씬 (L11)** |
| BG | 화면 어둡게 (Soy Dark 60%) + 중앙 카드 |
| 카드 BG | 크림 + 8px round + 외곽 2px |
| 닫기 | 우상단 ✕ (또는 `Skip All` FTUE 한정) |
| **default** | 0.4s scale-in (0.9→1.0) |
| **dismissed** | 0.3s fade-out |
| Sound hook | 🔊 `modal_open` / `modal_close` / `cutscene_family_unlock` (L11 컷씬) |
| 비고 | **L11 양친 동시 unlock 컷씬은 카드 대신 풀스크린 식탁 BG + 어머니/아버지 동시 fade-in** (tier-1-2-flow §3.4 v0.2) |
| **Godot 매핑** | `scenes/ui/modal.tscn` (CanvasLayer + ColorRect dim + Panel 카드). unlock 컷씬은 별도 `scenes/ui/family_unlock_cutscene.tscn` (풀스크린 TextureRect + 3x DinerCharacter + 말풍선 + CTA). 양친 0.6s 시차 fade-in은 `AnimationPlayer` "cutscene_intro" (어머니 트랙 → 아버지 트랙 0.6s offset). 스크립트 `scripts/ui/modal.gd` / `scripts/ui/family_unlock_cutscene.gd`. |

---

## 16. Layout / 시그니처 그리드 요약 (v0.3 갱신)

| 요소 | 위치 | Z-order |
|------|------|---------|
| 상단 HUD (코인·라이프·Lv·Pause) | top, height 60px (1080×1920 기준 Y 0~120) | 100 |
| 요리 카드 (floating) | top, below HUD (Y 360~480) | 90 |
| **Kitchen rack (CP-22, basic_pantry, Scene 2 only)** | **top right (Y 130~340, X 820~1060)** | **80** |
| Scene BG | full | 0 |
| 카드/캐릭터 area | center (Y 600~1100 visual focus zone) | 50 |
| **Stage 2A 도마 (CP-18) + Knife (CP-19)** | **Y 1100~1450 X 240~840 (one-thumb zone)** | **50** |
| **Stage 2B Tool cards (cooking_tool_slot)** | **Y 1100~1500 X 100~980 (3~4 카드)** | **50** |
| **Stage 2C Timing bar (CP-21)** | **Y 1150~1280 X 60~1020 (full width)** | **50** |
| 캐릭터 (CH-01 chibi optional, Scene 2) | Y 1100~1450 X 750~1060 | 40 |
| 하단 액션 바 (타이머·CTA·바구니) | bottom, height 100px (Y 1700~1920) | 100 |
| Banner 광고 | bottom (메인 메뉴만) | 100 |
| **Guest Select 카드 (CP-23, 510×680)** | **scroll 내부 grid 2-col** | **50** |
| **CP-23 카드 내부 — name/likes/dislikes/reward band** | **카드 internal layer** | **60** |
| **CP-24 compat_bar / large badge (Guest Select 카드 좌상단)** | **inside CP-23, X 16~280 Y 16~80** | **65** |
| **CP-26 mood_badge (avatar overlay 우하단)** | **inside CP-23, X 320~390 Y 270~340** | **70** |
| **✨ RECOMMENDED 띠 (best card 한정)** | **CP-23 top 위 -28px overlap** | **75** |
| **CP-24 mini-badge (Food Select 카드 우상단)** | **menu_select 카드 X 360~470 Y 14~120** | **60** |
| **Result Screen ScrollContainer content (Summary/Reaction/Stars/Breakdown/Rewards)** | **Y 60~2700 scrollable** | **50** |
| **CP-30 emotion_reaction speech bubble** | **Result Screen Y 820~1000** | **60** |
| **CP-32 milestone_toast inline expand (within CP-29)** | **Result Screen Y 2540~2670** | **65** |
| **CP-31 NEW RECORD badge (Result Screen reaction overlap)** | **Result Screen Y 1180~1260 (above guest reaction)** | **70** |
| **Result Screen Sticky CTA bar (Cook Again / Choose Other / Menu)** | **stationary Y 1700~1920** | **100** |
| **(v0.6) Drop shadow Card layer (모든 card 공통, CP-34)** | **card 아래 Y+12 offset** | **45** |
| **(v0.6) Glossy inner highlight layer (모든 button/card 공통, CP-33)** | **button/card top 20% region overlay** | **55** |
| **(v0.6) Hero Number bounce halo (Score/compat %, CP-37)** | **hero number 뒤 radial halo** | **48** |
| **(v0.6) Now Cooking banner (Cooking 8 module 공통, CP-40)** | **Y 60~180 above HUD** | **95** |
| **(v0.6) Step Progress dots (Cooking, CP-41)** | **Y 60~120 right of banner** | **96** |
| **(v0.6) Today's Pick hero card (Menu Select, CP-38 reuse)** | **Y 130~440 top of menu** | **75** |
| **(v0.6) Gold Ribbon banner hero (NEW RECORD / TODAY'S PICK, CP-38)** | **above content slide-in from top** | **180** |
| **(v0.6) Sparkle particle burst (PERFECT / NEW RECORD / best card, CP-35)** | **on top of content** | **200** |
| **(v0.6) Coin spray particle (Result + Cooking, CP-39)** | **from emit origin to HUD wallet** | **210** |
| Modal / Toast | full overlay | 200 |

---

## 17. CP-18 도마 (Cutting Board, Stage 2A) — v0.3 신설

| 항목 | 값 |
|------|-----|
| 용도 | Scene 2 **Stage 2A** 재료 준비 (ADR-005 rhythm tap) — 칼이 닿는 tap target |
| Art anchor | CUT-00 (cutting board base, warm brown wood `#A67049`, art-anchor §5.7) |
| 위치 | Y 1100~1450 X 240~840 (one-thumb zone, 600×350px area) |
| 비율 | 가로 600 × 세로 350px (도마 sprite native ratio), pivot 중앙 |
| Tap target | **전체 도마 영역 = 단일 Button** (X 240~840 Y 1100~1450 어디든 인식) |
| 상태 | **idle** = static / **knife_approaching** = subtle highlight (Knife indicator Y 1050+ 도달 시) / **perfect_hit** = Gold flash 0.1s + shake 0.2s + chunk particle 1회 / **good_hit** = Cream flash 0.1s + 약한 shake / **miss_hit** = Red flash 0.1s + 약한 shake X축 |
| Sprite layer | (1) 도마 base (CUT-00) Z=50 / (2) Ingredient sprite (ING-XX whole → ICUT-XX cut cross-fade) Z=55 |
| Sound hook | 🔊 `cut_perfect` / `cut_good` / `cut_miss` (chop SFX 차등) |
| 비고 | 마지막 tap (n/n) 완료 시 ING-XX whole → ICUT-XX cut cross-fade 0.3s. 양념재우기 round 한정으로 marinade bowl로 대체 가능 (양념재우기 variant는 scene-2-kitchen-layout §1.3 참조). |
| **Godot 매핑** | `scenes/ui/cutting_board.tscn` (Node2D + 도마 Sprite2D + Ingredient Sprite2D + tap area Button overlay). 상태 전환은 `AnimationPlayer` "perfect_hit" / "good_hit" / "miss_hit" + chunk particle GPUParticles2D. 스크립트 `scripts/ui/cutting_board.gd` (class_name `CuttingBoard`) — `register_tap(timing_delta_ms: int) -> CutResult` / `swap_to_cut_sprite(icut_id: String)`. cut data Resource `resources/cut_style/{cut_id}.tres` (CutStyleResource — `cut_sprite_id` / `audio_id`). |

---

## 18. CP-19 Knife Indicator (Stage 2A) — v0.3 신설

| 항목 | 값 |
|------|-----|
| 용도 | Scene 2 **Stage 2A** 재료 준비 — 칼 sprite 위↕아래 motion = rhythm tap **visual cue** (별도 게이지 X) |
| Art anchor | CUT-00 base의 LEFT side static knife와 동일 silver-gray slim silhouette (art-anchor §5.7 G_cut_3 정합) |
| 위치 | X = 도마 중앙 (X 540) / Y range = **900 (위 정점) ~ 1150 (도마 닿기, 250px translation)** |
| 비율 | 가로 80 × 세로 300px (knife sprite native), pivot 칼끝 (Y 0 = 칼끝, Y 300 = 손잡이 위) |
| **Motion (Option 1 lock)** | **AnimationPlayer "knife_loop" infinite** — Y position keyframe only (회전 각도 변경 X, Option 1 motion lock). 1 cycle: t=0.0s Y=900 (정점) → t=0.5×cycle Y=900 hold → t=0.7×cycle Y=1150 (도마 닿기, **perfect 순간**) → t=1.0×cycle Y=900 복귀. cycle = `60_000 / bpm` ms. |
| BPM 조정 | `AnimationPlayer.speed_scale = bpm / 60.0` (60 BPM base, 90 BPM → 1.5x speed) |
| Perfect zone visual | 도마 닿기 직전 ±80ms 구간에 칼이 Y 1120~1150 위치 → **subtle Gold glow halo** (칼끝 around 30px radius). player가 시각으로 "지금!" 인식 |
| 상태 | **idle** = AnimationPlayer paused / **playing** = loop (default) / **paused** = tap 직후 0.1s freeze (visual feedback) / **stopped** = 마지막 tap 완료 시점 정지 |
| Sound hook | 🔊 `knife_swoosh_down` (Y 1100 통과 시점), `knife_swoosh_up` (Y 950 통과 시점) — 60 BPM 기준 1 cycle 2회 SFX |
| 접근성 | 칼끝 30px Gold glow + Perfect 시점 빗금 cue (color-blind safe) |
| 비고 | **CUT-00 base의 LEFT side static knife는 art anchor 참조용**, 실제 게임에서는 도마 중앙 X 540 위치로 reposition (배경/일관성 보존). 양념재우기 round는 칼 → 손 sprite로 swap 후보 (M2 art-director sprint, MVP fallback은 칼 motion 재사용). |
| **Godot 매핑** | `scenes/ui/knife_indicator.tscn` (Node2D + Knife Sprite2D + glow halo Sprite2D + AnimationPlayer "knife_loop"). AnimationPlayer Y position track keyframe 4개 (정점 hold / 도마 닿기 / 정점 복귀). 스크립트 `scripts/ui/knife_indicator.gd` (class_name `KnifeIndicator`) — `set_bpm(bpm: int)` / `start_loop()` / `pause_briefly(duration_ms: int)` / `stop()` / `signal knife_hit_bottom` (도마 닿는 순간 emit, CuttingBoard와 timing sync에 사용). |

---

## 19. CP-20 Tool Sprite (Stage 2B/2C generic, TOOL-01~12 swap layer) — v0.3 신설

| 항목 | 값 |
|------|-----|
| 용도 | Scene 2 **Stage 2B 조리 방법 선택 카드 sprite** + **Stage 2C dock된 도구 sprite** — TOOL-01~12 generic swap layer |
| Art anchor | TOOL-01~12 (가스레인지/냄비/후라이팬/깊은튀김냄비/그릴/국자/주걱/뒤집개/집게/김발/mixing bowl/한식가위, art-anchor §5.11 G_tool, 2026-05-31 LOCK) |
| 비율 | 1:1, 240×240px (Stage 2B 카드 사이즈) 또는 400×400px (Stage 2C dock 위치) — Sprite2D scale로 조정 |
| Sprite swap | `set_tool(tool_id: String)` 호출 시 TextureRect.texture 교체 (resource path `assets-processed/tools/TOOL-XX.png`). 동적 swap으로 음식별 도구 변경 |
| **Motion (Stage 2B 카드 → 2C dock)** | **Tween dock animation** — Stage 2B 카드 tap → t=0.0s 카드 0.95x flash → t=0.1s 카드가 Y 1100~1500 (카드 위치) → Y 600~1000 (가스레인지 위 dock 위치) Tween 0.4s arc + scale 240→400 → t=0.5s dock 완료 (Stage 2C 시작) |
| 상태 (카드 모드) | **default** = idle / **pressed** = 0.95x flash 0.1s / **dock_motion** = Tween 0.4s arc / **disabled** = 회색 (FTUE 정답 외 카드) |
| 상태 (dock 모드) | **idle_in_pan** = static (도구 위에 음식 sprite overlay) / **cooking_vfx_active** = burner glow + steam particle |
| Sound hook | 🔊 `tool_select` (카드 tap), `tool_dock` (dock 완료) |
| 비고 | **CP-04 키친 도구 슬롯 (cooking_tool_slot.tscn)은 카드 wrapper**, CP-20은 **순수 sprite layer** — CP-04가 CP-20을 child로 가짐. CP-20 단독으로 Stage 2C dock 위치에 instance 가능 (카드 wrapper 없이). 음식별 method_options 컬럼이 TOOL-XX id list 결정 (game-designer foods CSV, M2 lock). |
| **Godot 매핑** | `scenes/ui/tool_sprite.tscn` (Sprite2D + AnimationPlayer "dock_motion" / "cooking_vfx_active"). Tool data Resource `resources/cooking_tool/{tool_id}.tres` (CookingToolResource — `texture` / `display_name` / `audio_id` / `cooking_vfx_id`). 스크립트 `scripts/ui/tool_sprite.gd` (class_name `ToolSprite`) — `set_tool(tool_id)` / `play_dock_animation(target_pos: Vector2)` / `start_cooking_vfx(vfx_id: String)`. |

---

## 20. CP-21 Timing Bar (Stage 2C) — v0.3 신설 (구 §5 통합)

| 항목 | 값 |
|------|-----|
| 용도 | Scene 2 **Stage 2C 조리 시간** — 가로 게이지 + 인디케이터 ▼ + Perfect ±80ms window (ADR-005 §6) |
| Art tone | 기본 §5와 동일 (Sesame Gold + 빗금 접근성) |
| 위치 | **Y 1150~1280 X 60~1020 (full width 960px × 130px height)** |
| 비율 | 가로 960 × 세로 130px (게이지 본체 60px + 인디케이터 area 70px) |
| 구간 색상 | miss = 회색 `#999999` / good = Sesame Gold 50% `#FFE89C` / **PERFECT** = Sesame Gold 100% `#FFC857` + 45도 빗금(접근성) |
| 구간 너비 | miss 60% (양쪽 합) / good 30% (양쪽 합) / **PERFECT 10%** (Rewarded ad 시 **20%**, FTUE 한정도 20%) |
| 인디케이터 | 흰 화살표 ▼, 16×24px, 좌→우 왕복 (Tween linear) |
| Cycle 시간 | 1 왕복 = `food.cook_time_sec` (요리별, resources/food/{food_id}.tres `cook_time_sec`) |
| Perfect zone visual | PERFECT 구간 위에 **Gold glow halo pulse** 1Hz (player가 시각으로 "여기!" 인식) |
| **Perfect ±80ms 변환** | `perfect_pixel_width = bar_width × perfect_ratio` (10% = 96px, 20% = 192px). cook_time_sec 기반 인디케이터 속도 = `960 / cook_time_sec` px/s. 80ms window = `0.08 × 960 / cook_time_sec` px. **balance-config §6 sync**. |
| 상태 | **default** = 좌→우 Tween 중 / **paused** = Tween paused (Pause 메뉴 시) / **judged** = 인디케이터 정지 + 결과 텍스트 ("PERFECT!" / "GOOD" / "MISS") 0.5s fade |
| Sound hook | 🔊 `tap_perfect` / `tap_good` / `tap_miss` 차등 + `bar_tick` (인디케이터 PERFECT 구간 통과 시 옵션) |
| 접근성 | 색상 + 빗금 이중 (color-blind safe). PERFECT zone Gold glow halo + 빗금 추가 강조 |
| 비고 | tap 입력은 **별도 Button (TapArea Y 1380~1620)** 또는 화면 전체 탭. CP-21 자체는 시각 게이지만. Rewarded ad 트리거 시 `set_rewarded_active(true)` 호출 → PERFECT 폭 10% → 20% 즉시 확장 (Tween 0.2s). |
| **Godot 매핑** | `scenes/ui/timing_bar.tscn` (Control + 5개 구간 ColorRect + 빗금 TextureRect overlay + 인디케이터 Sprite2D + Gold glow halo Sprite2D + AnimationPlayer "halo_pulse"). 인디케이터 이동은 `Tween` linear 좌→우. Timing data Resource `resources/food/{food_id}.tres` `cook_time_sec` / `perfect_ratio_default` 컬럼. 스크립트 `scripts/ui/timing_bar.gd` (class_name `TimingBar`) — `start_with_cook_time(sec: float)` / `judge_tap() -> TimingResult` / `set_rewarded_active(bool)` / `signal tap_judged(result: TimingResult)`. |

---

## 21. CP-22 Kitchen Rack (Scene 2, basic_pantry visual cue) — v0.3 신설 (ADR-007)

| 항목 | 값 |
|------|-----|
| 용도 | Scene 2 **전체 (Stage 2A/2B/2C 공통)** — basic_pantry 5종 (간장/고추장/설탕/참기름/소금) 시각 cue, 사용자 인터랙션 X |
| 정합 | ADR-007 + cooking-mechanics §2.2.7 + balance-config §4A |
| Art anchor | 옹기 5종 (간장 옹기 / 고추장 옹기 / 설탕 단지 / 참기름 호리병 / 소금 항아리) — **art-director Post-M1 sprint 신규** (현재 placeholder, M2 art LOCK 후 sprite swap) |
| 위치 | **Y 130~340 X 820~1060 (우측 상단, HUD 아래)** |
| 비율 | 가로 240 × 세로 210px (5 옹기 가로 정렬, 각 40×40px + 간격 8px + padding 16px) |
| **interactive** | **NO** (시각 cue only, 사용자 탭 X) |
| 상태 | **hidden** = Scene 1 / Scene 3 / **idle** = Scene 2 default fade-in 0.3s / **dim** = Stage 2B/2C 동안 50% opacity (포커스 전환) / **highlight** = 양념재우기 round 시 해당 양념 3종 (간장+설탕+참기름) Gold glow 0.5s pulse / **arc_to_marinade** = 양념재우기 round 시 highlight 후 marinade bowl로 자동 이동 Tween 1.0s arc trajectory |
| Sound hook | 🔊 `pantry_arc_swoosh` (양념재우기 옹기 이동 시) |
| 비고 | 5 옹기 sprite는 art-director Post-M1 LOCK 후 swap. MVP placeholder = §1 ingredient_card.tscn 5개 mini (40×40px) 임시 사용 가능. Stage 2A 양념재우기 variant (불고기 t2_014 / 갈비구이 t2_012) 한정으로 arc motion 활성 — 다른 음식은 dim만. |
| **Godot 매핑** | `scenes/ui/kitchen_rack.tscn` (Node2D + HBoxContainer + 5x Sprite2D 옹기 + AnimationPlayer "fade_in" / "dim_to_50" / "highlight_pulse" / "arc_to_marinade"). Pantry data Resource `resources/ingredient/basic_pantry.tres` (배열 5종 id + texture path). 스크립트 `scripts/ui/kitchen_rack.gd` (class_name `KitchenRack`) — `fade_in()` / `dim(opacity: float)` / `highlight_for_marinade(ingredient_ids: Array)` / `arc_to_target(target_pos: Vector2, duration: float)`. Autoload `RoundState` 구독 (현재 음식의 marinade 필요 여부 자동 판단). |

---

## 22. CP-23 Guest Card v2 (Guest Select 2.0) — v0.4 신설

> 상세 zone + state는 `guest-select-v2-layout.md` v0.1 §2 참조.

| 항목 | 값 |
|------|-----|
| 용도 | Guest Select scene (guest_select.tscn) 게스트 카드 — avatar + friendship + likes + dislikes + mood + reward + compat % 통합 |
| 비율 | 가로 510 × 세로 680px (2-col grid 1080-padding-sep 기준) |
| BG | Cream `#F8E9D2` + 5~10% compat color tint (PERFECT은 gold tint 보강) |
| 외곽 | 3~6px round, **두께·컬러 = compat tier 매핑** (PERFECT 6px gold + glow / GOOD 5px green / OK 4px yellow / LOW 3px orange / BAD 3px red dashed) |
| 내부 layout (zone) | (1) top row Y 0~80: CP-24 compat large badge X 16~280 + friendship stars X 296~494 / (2) avatar 240×240 center X 135~375 Y 100~340 + CP-26 mood overlay X 320~390 Y 270~340 / (3) name Y 360~410 / (4) CP-25 likes row Y 430~485 / (5) CP-25 dislikes row Y 495~550 / (6) CP-27 reward bonus band Y 570~640 / (7) CTA "Cook for X" Y 650~680 |
| ✨ RECOMMENDED 띠 | best compat card 1장 한정, 카드 top -28px overlap, gold gradient BG, 28pt white text, 1Hz pulse 1.0→1.02 |
| 상태 | **default** = idle / **enter** = scene enter 0.1s offset per card cascade fade-in 0.4s / **hover (long-press 0.3s)** = 1.03× + Gold halo / **pressed** = 0.95× flash 0.1s / **disabled** (friendship lock, post-launch) = 회색 + 🔒 + "Reach Lv 2 to unlock" |
| Sound hook | 🔊 `guest_card_appear` (cascade), `guest_card_select` (tap) |
| 비고 | post-launch 친구 N명까지 layout 그대로 확장 (2-col scroll). 카드 폭 510px = 1-thumb 도달 OK. avatar는 art-director sprint 2 chibi bust-up, MVP placeholder = AVATAR_TINT 원형 + 첫글자. |
| **Godot 매핑** | `scenes/ui/guest_card_v2.tscn` (Panel + child layout VBoxContainer + AnimationPlayer "enter_cascade" / "hover_halo" / "recommended_pulse"). Guest data Resource `resources/guest/{guest_id}.tres` (GuestResource — `avatar_neutral` / `name_en` / `name_kr` / `likes[]` / `dislikes[]` / `friendship_threshold_unlock`). 스크립트 `scripts/ui/guest_card_v2.gd` (class_name `GuestCardV2`) — `set(guest_id, compat, friendship, mood, reward)` / `show_recommended()` / `signal card_pressed(guest_id)`. |

---

## 23. CP-24 Compat Bar / Badge (compat % 시각화) — v0.4 신설

> 상세 매핑은 `food-select-compat.md` v0.1 §2.1 참조.

| 항목 | 값 |
|------|-----|
| 용도 | compat % 0~100 시각화 — Guest Select 카드 좌상단 **large badge** + Food Select 카드 우상단 **mini-badge** 두 mode 공유 |
| Mode A (large badge, Guest Select) | 264 × 64px (X 16~280 Y 16~80 of CP-23). "92%" 36pt bold + "MATCH" 라벨 18pt + bar 8px 하단. BG = compat color, glow PERFECT only. |
| Mode B (mini-badge, Food Select) | 110 × 106px (X 360~470 Y 14~120 of menu card). avatar 60×60 + "92%" 24pt + "Best: Mina" 18pt caption. BG = compat color rounded 24. |
| 시각 매핑 | 5 tier: 90~100 PERFECT (Gold `#FFC857` + 빗금) / 75~89 GOOD (Green `#7DB76F`) / 50~74 OK (Yellow `#E8C547`) / 30~49 LOW (Orange `#F4A261`) / 0~29 BAD (Red `#E63946` + dashed) |
| 시각 삼중 (접근성) | (1) **컬러** + (2) **bar fill ratio (0~100%)** + (3) **텍스트 라벨 (PERFECT/GOOD/OK/LOW/BAD)** color-blind safe |
| 상태 | **default** = static / **pulse (PERFECT 한정)** = Gold halo 1Hz / **tap (mini-badge)** = tooltip "X loves Y. NN% match." (long-press) |
| 데이터 입력 | `set_compat(percent: int 0~100, mode: String "large" or "mini", avatar_tex: Texture2D = null, caption: String = "")` |
| Sound hook | 🔊 `compat_reveal` (scene enter cascade per card) |
| 비고 | game-designer `compat_score(menu, guest) -> int 0~100` 공식 lock 필요 (M2). UI는 int input만 받음. |
| **Godot 매핑** | `scenes/ui/compat_bar.tscn` (Panel + Label % + Label 라벨 + ProgressBar bar + glow Sprite2D for PERFECT). Compat tier data Resource `resources/ui/compat_tiers.tres` (CompatTierResource — array of {min_pct, color, label, border_width, dashed: bool}). 스크립트 `scripts/ui/compat_bar.gd` (class_name `CompatBar`) — `set_compat(pct, mode)` / `set_mini_content(avatar, caption)` / `tier_color(pct) -> Color` (static helper). |

---

## 24. CP-25 Flavor Tag Badge (likes / dislikes) — v0.4 신설

| 항목 | 값 |
|------|-----|
| 용도 | guest likes (1~3 axis) + dislikes (1~2 axis) horizontal cluster 표시 — Guest Card v2 row 2개 (Y 430~485 likes / Y 495~550 dislikes) |
| 비율 | 110 × 40px per tag (icon 32px + 라벨 20pt + padding) |
| Layout | HBoxContainer h_sep 12px, max 3 likes / max 2 dislikes per row |
| 컬러 매핑 (5 axis) | spicy `#E63946` (🌶) / sweet `#F4A2C7` (🍬) / salty `#7AB7E0` (🧂) / oily `#C9A567` (🥩) / mild `#A8C77E` (🥒) / umami `#8A6B4A` (🍄, post-launch) |
| 라벨 | English ("Spicy" / "Sweet" / "Salty" / "Oily" / "Mild" / "Umami") icon-first per i18n lock |
| Dislike state | 동일 디자인 + **빨간 ❌ overlay 우상단** (16×16, opacity 90%) + 채도 -30% |
| 상태 | **default** = static / **hover (long-press)** = 1.1× tooltip "Loves spicy heat" (like) or "Avoids salty foods" (dislike) |
| 데이터 입력 | `set_tag(axis: String, is_dislike: bool)` — axis ∈ {spicy/sweet/salty/oily/mild/umami} |
| Sound hook | 🔊 `tag_tooltip` (long-press) |
| 비고 | game-designer guests.csv에 **`likes` / `dislikes` 신규 컬럼** lift 필요 (현 `vec` dict는 score용, 표시용 분리). MVP fallback = vec dominant axis 1개 like + lowest axis 1개 dislike 자동 변환. |
| **Godot 매핑** | `scenes/ui/flavor_tag_badge.tscn` (Panel + HBoxContainer + Icon TextureRect + Label + ❌ overlay TextureRect). Axis data Resource `resources/ui/flavor_axes.tres` (배열 6 axis: id / color / icon_path / display_name_en / display_name_kr). 스크립트 `scripts/ui/flavor_tag_badge.gd` (class_name `FlavorTagBadge`) — `set_tag(axis, is_dislike)` / `static tier_color(axis) -> Color` / `static icon_path(axis) -> String`. |

---

## 25. CP-26 Mood Badge (today's mood overlay) — v0.4 신설

| 항목 | 값 |
|------|-----|
| 용도 | guest avatar 우하단 mood overlay — today's mood (5종) 시각 + 효과 hint |
| 비율 | 70 × 70px circle, white border 3px |
| Position (CP-23 내부) | X 320~390 Y 270~340 (avatar 우하단 overlap) |
| Mood 5종 | (1) **hungry** 😋 → compat +5% / reward +5% / gold tint / (2) **happy** 😍 → compat +3% / reward +10% / pink tint / (3) **easy** 🙂 → 0 (default) / neutral / (4) **picky** 😐 → compat -5% / reward -5% / gray tint / (5) **grumpy** 😡 → compat -10% / reward -10% / red tint |
| BG color | mood tint 매핑 (gold/pink/neutral/gray/red) |
| Icon | 48pt emoji 또는 SVG (icon-first per i18n lock 2026-05-27) |
| 상태 | **default** = static / **hover (long-press)** = tooltip "Hungry! Reward +5%" / **change** (daily reset 트리거) = 0.5s scale 0.8→1.0 pop + sparkle |
| 데이터 입력 | `set_mood(mood: String)` — mood ∈ {hungry/happy/easy/picky/grumpy} |
| Sound hook | 🔊 `mood_change_pop` (daily reset only), `mood_tooltip` (long-press) |
| 비고 | game-designer **mood rotation 공식 lock 필요** (M2): daily seed (player_id + date hash) 또는 per-round random. UI는 5종 매핑만. |
| **Godot 매핑** | `scenes/ui/mood_badge.tscn` (Panel + circle BG + Label icon emoji or TextureRect SVG + AnimationPlayer "mood_change_pop"). Mood data Resource `resources/ui/moods.tres` (배열 5 mood: id / icon / bg_color / compat_mod / reward_mod / tooltip_en / tooltip_kr). 스크립트 `scripts/ui/mood_badge.gd` (class_name `MoodBadge`) — `set_mood(mood_id)` / `static get_mood_data(mood_id) -> Dictionary`. |

---

## 26. CP-27 Reward Bonus Badge (full-width 띠) — v0.4 신설

| 항목 | 값 |
|------|-----|
| 용도 | Guest Card v2 reward bonus 표기 (Y 570~640, 478×70 full-width band) |
| 비율 | 478 × 70px (X 16~494 of CP-23, CTA 바로 위) |
| BG | gradient horizontal (compat color → lighter shade 30%) |
| 텍스트 | "⭐ +15% Reward" 28pt bold white + "(₩+1,800)" 22pt sub white |
| Drop shadow | 1px black 50% (텍스트 시인성) |
| 상태 | **default** = static / **bonus ≥ 20%** = ★ particle 1초 1회 sparkle / **negative bonus** (mood grumpy + dislike match) = "⚠ -10% Reward" red tint BG |
| 데이터 입력 | `set_bonus(percent: int -50~+50, base_won: int) -> won_delta: int 자동 계산` |
| Sound hook | 🔊 `bonus_appear` (cascade), `bonus_sparkle` (≥20% only) |
| 비고 | game-designer **reward_bonus 공식 lock** 필요 (M2): `bonus(compat, friendship, mood) -> int %`. 합산 범위 -20% ~ +30% 권장 (밸런스). |
| **Godot 매핑** | `scenes/ui/reward_bonus_badge.tscn` (Panel + GradientTexture2D BG + HBoxContainer Label + GPUParticles2D sparkle). Bonus formula는 Autoload `RewardCalc.gd` 위임. 스크립트 `scripts/ui/reward_bonus_badge.gd` (class_name `RewardBonusBadge`) — `set_bonus(pct, base_won)` / `compute_won_delta(pct, base) -> int`. |

---

## 27. CP-28 Score Breakdown Row (6 row 공통, Result Screen §2) — v0.5 신설

| 항목 | 값 |
|------|-----|
| 용도 | Result Screen v2 §2 Score Breakdown 6 row 공통 컴포넌트 — Prep / Cook / Seasoning / Plating / Compat bonus / Mood bonus 동일 layout 재사용 |
| 비율 | 가로 960 × 세로 100px (X 60~1020 of Result Screen, 10px gap between rows) |
| BG | Cream `#F8E9D2` rounded 6px + drop shadow 1px |
| Layout (좌→우) | (1) Icon 48×48 X 16~64 / (2) Label en + kr X 80~480 (Pretendard 28pt bold + 18pt sub) / (3) Stars 3-slot X 500~640 (CP-7 mini) / (4) Bar X 660~880 (TextureProgressBar 220×24, fill 0~100%) / (5) Value X 900~960 ("+24%" 32pt bold Sesame Gold) |
| 상태 | **hidden** = scroll 진입 전 alpha 0 / **revealing** = scroll viewport 진입 시 bar fill 0→target 0.3s + 라벨 alpha 0→1 / **revealed** = static / **bonus row variant** (Compat/Mood bonus rows): icon 자리 = compat color circle / mood emoji, stars 자리 hide, value 자리 = "+15%" gold gradient pill |
| Row 6종 type | (1) `prep` icon=🔪 / (2) `cook` icon=🍳 / (3) `seasoning` icon=🧂 / (4) `plating` icon=🍽 / (5) `compat_bonus` (bonus variant) / (6) `mood_bonus` (bonus variant) |
| 데이터 입력 | `set_row(row_type: String, label_en: String, label_kr: String, stars: int 0~3, percent: int 0~100, value_text: String)` |
| Sound hook | 🔊 `breakdown_row_reveal` (per row, -6dB ducking under previous) |
| 비고 | MVP는 prep/cook(=method)/timing 3 axis만 cooking-mech §5에서 lift. plating/seasoning은 future-proof — pm/game-designer confirm 후 row hide 또는 "—" 표기 (result-screen-v2-layout §1.4). |
| **Godot 매핑** | `scenes/ui/score_breakdown_row.tscn` (HBoxContainer + Icon TextureRect + VBoxContainer Label + StarRating mini + TextureProgressBar + Label value). Tween bar fill 0→target. Row type Resource `resources/ui/breakdown_row_types.tres` (배열 6 type: id / icon_path / variant: String "score" or "bonus"). 스크립트 `scripts/ui/score_breakdown_row.gd` (class_name `ScoreBreakdownRow`) — `set_row(...)` / `reveal(delay_sec: float)` / `signal row_revealed`. |

---

## 28. CP-29 Reward Box (Result Screen §3) — v0.5 신설

| 항목 | 값 |
|------|-----|
| 용도 | Result Screen v2 §3 Rewards 단일 panel — coins earned + Recipe XP + friendship gained + friendship bar + milestone (conditional) 통합 |
| 비율 | 가로 960 × 세로 480px (X 60~1020 Y 2210~2690 of Result Screen, conditional expand +130px if milestone) |
| BG | Cream `#F8E9D2` rounded 12px + Soy Dark outline 2px + drop shadow 4px |
| 내부 layout | (1) 💰 Coins band Y 30~110: "+1,800 ₩" 48pt Sesame Gold count-up animation / (2) 📖 XP band Y 120~180: "+24 XP (Tteokbokki)" 32pt / (3) ♥ Friendship band Y 190~250: "+12 with Mina" 32pt / (4) friendship bar Y 260~310: TextureProgressBar 880×40 fill 0→target 1.2s + "Lv 2 (60/100)" label below / (5) milestone toast (CP-32) inline expand Y 330~460 conditional |
| 상태 | **hidden** = scroll 진입 전 / **revealing_coins** = scroll trigger + 0.0s coin count-up 0→target 1.0s OUT_CUBIC / **revealing_xp** = +1.0s xp label alpha fade-in 0.3s / **revealing_friendship** = +1.3s label fade-in + bar fill 0→target 1.2s / **milestone_expand** (conditional Lv 3/7/10) = +2.5s panel height tween +130px + CP-32 toast inline reveal / **revealed** = static |
| Coin count-up | `count_label.text = str(lerp(0, target_won, t)) + " ₩"` Tween 1.0s OUT_CUBIC, 🔊 `coin_count_loop` (tick per 100 ₩) + `coin_final` (last tick) |
| Friendship bar fill | TextureProgressBar value 0→target. Lv-up 발생 시 bar 100% 도달 후 reset 0 + label "Lv N → Lv N+1" flash 0.4s + milestone trigger (Lv 3/7/10) |
| 데이터 입력 | `set_reward(coins_won: int, xp_gained: int, food_name: String, guest_name: String, friendship_start: int, friendship_end: int, lv_start: int, lv_end: int, milestone_unlocked: int = 0)` |
| Sound hook | 🔊 `reward_panel_reveal` (panel scroll-in), `coin_count_loop` / `coin_final`, `friendship_bar_fill` (loop 1.2s), `friendship_lv_up_chime` (Lv-up only), `milestone_unlock` (CP-32 trigger) |
| 비고 | friendship XP curve = game-designer M2 (각 Lv 임계 xp + Lv 3/7/10 milestone reward). MVP placeholder = Lv 0→1=100, 1→2=200, ..., +100*lv (linear). |
| **Godot 매핑** | `scenes/ui/reward_box.tscn` (Panel + VBoxContainer + 4 sub-Panel + CP-32 instance hidden by default). Tween coin count-up = `coin_label.text = "+" + str(int(lerp(0, target, t))) + " ₩"`. Friendship XP curve Resource `resources/friendship/xp_curve.tres` (FriendshipXpCurveResource — array of Lv threshold + milestone Lv list [3,7,10]). 스크립트 `scripts/ui/reward_box.gd` (class_name `RewardBox`) — `set_reward(...)` / `reveal()` / `_animate_coin_count_up(target: int)` / `_animate_friendship_bar(start: int, end: int, lv_start: int, lv_end: int)` / `signal milestone_triggered(lv: int)`. |

---

## 29. CP-30 Emotion Reaction (Result Screen §4, mood_badge reuse) — v0.5 신설

| 항목 | 값 |
|------|-----|
| 용도 | Result Screen v2 §4 emotional reaction — guest avatar (mood sprite swap) + speech bubble + reaction text 4-tier (excellent/good/okay/bad) |
| 비율 | 가로 960 × 세로 460px (X 60~1020 Y 820~1280 of Result Screen) |
| BG | transparent (위에 speech bubble panel + avatar TextureRect 별도) |
| Speech bubble | X 60~1020 Y 820~1000 rounded panel 180h cream + drop shadow + tail (Y 990~1020 pointing down to avatar) |
| Avatar (mood swap) | X 400~680 Y 1030~1310 280×280 TextureRect — Round 시작 시 neutral sprite, reveal anim 2.4s 시점 texture swap → mood sprite (CP-26 sprite 재활용) |
| Reaction text | X 100~980 Y 850~950 (en 36pt bold + kr 24pt regular sub) — typewriter animation (40 chars/s) |
| 4-tier mapping (score → mood sprite) | **Excellent** (★3, 90+%) = `happy` 😍 sprite + Pink `#F4A2C7` 20% tint + ♥+✨ burst / **Good** (★2, 75~89%) = `hungry` 😋 sprite + Gold `#FFC857` 15% tint + ✨ subtle / **Okay** (★1, 50~74%) = `easy` 🙂 sprite neutral / **Bad** (0★, <50%) = `grumpy` 😡 sprite + Red `#E63946` 15% tint |
| 상태 | **idle (round 종료 직후)** = neutral avatar + speech bubble hidden / **bubble_in** = t=1.6s bubble Y+40→Y slide-up + alpha 0→1 / **text_typing** = t=1.8s typewriter en + kr text / **mood_swap** = t=2.4s avatar texture swap + 1.14x bounce + BG tint fade-in 0.3s / **revealed** = static + particle (excellent only) |
| 데이터 입력 | `set_reaction(tier: String "excellent"/"good"/"okay"/"bad", reaction_text_en: String, reaction_text_kr: String, guest_id: String)` |
| Sound hook | 🔊 `reaction_text_typing` (typewriter loop), `reaction_loved` / `reaction_liked` / `reaction_okay` / `reaction_bad` (mood swap 시점 tier별 1회), `reaction_particle` (excellent only) |
| 비고 | reaction text 템플릿 = game-designer M2 (5 axis × 4 tier = 20 template, friends-system v0.3 §2 Voice 톤). mood sprite asset = CP-26 mood_badge에서 lift (5 mood 중 happy/hungry/easy/grumpy 4개 사용, picky는 미사용). |
| **Godot 매핑** | `scenes/ui/emotion_reaction.tscn` (Control + Panel speech bubble + Sprite2D bubble tail + TextureRect avatar + Label en + Label kr + GPUParticles2D heart_sparkle). Text typewriter = `text_label.visible_characters` increment Tween. Avatar swap = `texture = mood_sprite_for_tier(tier)`. Mood sprite Resource `resources/ui/mood_sprites.tres` (배열 5 mood: id / sprite_path) — CP-26과 공유. Reaction text Resource `resources/ui/reaction_templates.tres` (배열 axis × tier 매트릭스). 스크립트 `scripts/ui/emotion_reaction.gd` (class_name `EmotionReaction`) — `set_reaction(...)` / `reveal()` / `_play_typewriter(text: String, duration_sec: float)` / `_swap_mood_sprite(tier: String)` / `signal reaction_complete`. |

---

## 30. CP-31 NEW RECORD Badge (Result Screen, conditional) — v0.5 신설

| 항목 | 값 |
|------|-----|
| 용도 | Result Screen v2 — best score 갱신 시 reaction 위 -28px overlap slide-in (Y 1180~1260 of Result Screen) |
| 비율 | 가로 400 × 세로 80px (X 340~740, center) |
| BG | Gold gradient horizontal `#FFC857`→`#FFE89C` + Soy Dark outline 2px + 8px round |
| 텍스트 | "✨ NEW RECORD ✨" 36pt Pretendard Bold white + drop shadow 2px black 60% |
| 아트 anchor | art-director Post-M1 sprint pending — gold ribbon shape + sparkle decoration (현재 placeholder = solid gold rounded rect + text only) |
| 상태 | **hidden** (default) = invisible / **slide_in** = t=4.2s reveal anim x+200→x 좌측 slide 0.5s BACK out + alpha 0→1 / **revealed** = static + 1Hz scale 1.0→1.02 micro pulse / **sparkle_particle** = +0.5s GPUParticles2D 20 particles burst 1s |
| 데이터 입력 | `set_visible(new_best: bool)` — visible=true 시 slide_in 트리거 |
| Sound hook | 🔊 `new_record_chime` (slide_in 시점 1회, 2 layer: sting 0~0.3s + bell 0.3~0.8s) |
| 비고 | best score 판정 = `score > SaveManager.best_score(menu_id::guest_id)`. composite key (menu_id::guest_id) = result-screen-v2-layout §6.3. |
| **Godot 매핑** | `scenes/ui/new_record_badge.tscn` (Panel + GradientTexture2D BG + Label + GPUParticles2D sparkle + AnimationPlayer "slide_in" / "micro_pulse"). 스크립트 `scripts/ui/new_record_badge.gd` (class_name `NewRecordBadge`) — `show_badge()` / `hide_badge()`. |

---

## 31. CP-32 Milestone Toast (Result Screen, Lv 3/7/10 unlock) — v0.5 신설

| 항목 | 값 |
|------|-----|
| 용도 | Result Screen v2 §3 Rewards 내부 inline expand — friendship Lv 3/7/10 도달 시 milestone unlock 시각 강조. NOT modal/popup — reward_box (CP-29) 내부 130px expand. |
| 비율 | 가로 880 × 세로 130px (X 100~980 Y 2540~2670 within reward_box, conditional expand) |
| BG | Gold gradient horizontal `#FFC857`→`#FFE89C` + Sesame Gold outline 3px + 12px round |
| 텍스트 layout | (1) Title "✨ MILESTONE UNLOCKED ✨" Y 10~40 36pt bold white center / (2) Milestone name Y 50~85 32pt bold Soy Dark (예: "Close Friend! (Lv 3)") / (3) Reward sub Y 90~125 22pt regular (예: "+500 ₩ bonus  +card frame upgrade") |
| Milestone 3종 | (1) **Lv 3** = "Close Friend" + 500 ₩ + card frame upgrade / (2) **Lv 7** = "Best Friend" + 1,500 ₩ + new outfit / (3) **Lv 10** = "Soulmate" + 3,000 ₩ + special recipe unlock |
| 상태 | **hidden** (default) = invisible, reward_box height 480 / **expand** = reward_box height tween 480→610 0.3s OUT_CUBIC + toast BG fade-in 0~0.4s / **text_reveal** = +0.4s typewriter title → name → reward sub (총 0.6s) / **sparkle_burst** = +0.8s GPUParticles2D 30 particles burst 1s / **revealed** = static + 1Hz glow pulse |
| 아트 anchor | art-director Post-M1 sprint pending — milestone icon 3종 (Lv 3 Close Friend / Lv 7 Best Friend / Lv 10 Soulmate). 현재 placeholder = ✨ emoji + text only. |
| 데이터 입력 | `show_milestone(lv: int)` — lv ∈ {3, 7, 10}만 valid. 다른 lv = no-op. |
| Sound hook | 🔊 `milestone_unlock` (expand 시점, 2 layer: sparkle 0~0.3s + chime 0.3~1.2s). 동시 ducking으로 다른 anim sound -6dB. |
| 비고 | Lv 3/7/10 milestone reward = game-designer M2 confirm. friendship XP curve와 함께 lock. |
| **Godot 매핑** | `scenes/ui/milestone_toast.tscn` (Panel + GradientTexture2D BG + VBoxContainer Label×3 + GPUParticles2D sparkle + AnimationPlayer "expand" / "glow_pulse"). Milestone data Resource `resources/friendship/milestones.tres` (배열 3 milestone: lv / name_en / name_kr / reward_won / reward_extra). 스크립트 `scripts/ui/milestone_toast.gd` (class_name `MilestoneToast`) — `show_milestone(lv)` / `_get_milestone_data(lv) -> Dictionary`. |

---

## 32. CP-33 Glossy Button (Royal Match-style premium CTA) — v0.6 신설

| 항목 | 값 |
|------|-----|
| 용도 | 4 screen 공통 premium CTA — Menu Select Cook 버튼 / Guest Select Cook for X / Cooking 8 module CTA (TAP/STOP/FLIP/PRESS&HOLD) / Result Sticky CTA 3종 |
| 비율 | base 280×72 (small) / 480×100 (medium) / 720×140 (large hero) — variant prop |
| BG | **gradient vertical** top `cta_persimmon` `#F4A261` → bottom `cta_persimmon_dark` `#D87A3F` + 2px outer lip Soy Dark + 2px inner highlight top 20% (white 30% gradient) |
| Font | Pretendard Bold 24pt (small) / 28pt (medium) / 36pt (large) white + 2px Soy Dark stroke + 2px drop shadow |
| 모서리 | 24px round (small) / 32px round (medium/large) |
| Drop shadow | Y+8px Soy Dark alpha 35% (small) / Y+12px (medium) / Y+16px (large) |
| **default** | idle gradient + inner highlight |
| **hover (long-press 0.3s)** | 1.03× scale + gold halo 30px around button + brightness +10% |
| **pressed** | 0.95× scale + 0.1s flash + shadow shrink Y+8→Y+4 (button "눌리는" 느낌) |
| **disabled** | gradient 채도 -60% + 회색 + outline gray + label opacity 50% |
| Icon variant | 좌측에 24×24 / 32×32 / 48×48 icon TextureRect 추가 가능 (TAP=👆 / STOP=✋ / FLIP=🔄 / PRESS=✊ / Cook=🍳) |
| Color variant | primary persimmon (default) / secondary cream (cream BG + brown stroke + brown text, outlined style) / tertiary text-only (BG transparent + label only) |
| Sound hook | 🔊 `button_tap_glossy` (small), `button_press_premium` (medium/large) |
| 비고 | 기존 CP-13 CTA Button 대체. CP-13는 backward-compat alias로 유지. premium-redesign-v1 §7 7.1~7.4 모든 CTA가 본 컴포넌트로 교체. |
| **Godot 매핑** | `scenes/ui/glossy_button.tscn` (Button + Panel BG (StyleBoxFlat gradient) + Panel inner_highlight (top 20% gradient white 30%) + ColorRect outer_lip + ColorRect drop_shadow + Label + TextureRect icon optional). Variant property = "small"/"medium"/"large", color_variant = "primary"/"secondary"/"tertiary". 스크립트 `scripts/ui/glossy_button.gd` (class_name `GlossyButton`) — `set_label(text)` / `set_icon(tex)` / `set_variant(size, color)` / `set_disabled(bool)` / `signal pressed_premium`. |

---

## 33. CP-34 Drop Shadow Card (Travel Town-style 3D depth) — v0.6 신설

| 항목 | 값 |
|------|-----|
| 용도 | 모든 카드/패널에 일관 적용 — Menu Select food card / Guest Select card v2 / Result reward_box / Cooking banner — depth 일관 |
| Type | **PackedScene** (Panel + child ColorRect shadow) 또는 NinePatchRect StyleBox |
| Shadow color | `shadow_warm` = Soy Dark `#3A2E1F` alpha 25% |
| Shadow offset | Y+12px (default card) / Y+16px (large card / hero) / Y+8px (small card / pill) — variant prop |
| Shadow blur | (Godot 4.x StyleBoxFlat) shadow_size 8px default, 12px large, 4px small |
| Shadow opacity tween | hover 시 25% → 35% + Y offset +4 (카드 "더 떠 있는" 느낌) |
| **default** | static shadow |
| **hover** | shadow opacity 25→35% + Y+4 ease_out 0.2s |
| **pressed** | shadow opacity 25→15% + Y-4 (눌림) |
| Sound hook | (없음 — passive visual) |
| 비고 | 단일 PackedScene을 카드들 child로 instance. card BG 위 Z=45로 stack (Z-order §16 정합). |
| **Godot 매핑** | `scenes/ui/drop_shadow_card.tscn` (ColorRect alpha 25% + size offset Y+12 + StyleBoxFlat shadow_size 8). Variant property = "small"/"default"/"large". 스크립트 `scripts/ui/drop_shadow_card.gd` (class_name `DropShadowCard`) — `set_variant(size)` / `set_state(state: String "default"/"hover"/"pressed")`. |

---

## 34. CP-35 Sparkle Particle (PERFECT / NEW RECORD / best card celebration) — v0.6 신설

| 항목 | 값 |
|------|-----|
| 용도 | celebration FX — PERFECT cook burst / NEW RECORD ribbon / Guest Select best card idle / Result Score reveal / Result milestone toast |
| Type | GPUParticles2D (Godot 4.x) + sparkle texture (PNG sprite sheet 16 frame 또는 simple white 4-point star) |
| Particle count | 16 (default burst) / 24 (NEW RECORD large) / 30 (milestone) / 4~6 (idle) — variant prop |
| Emission | radial from origin, angle 0~360°, speed 80~120 px/s, gravity 0 |
| Lifetime | 0.4s (burst) / 1.2s (NEW RECORD) / 1.0s (milestone) / loop infinite (idle 6 particles cycle) |
| Color | `accent_gold` `#FFC857` + white center + alpha fade-out |
| Scale | 0.5→0.0 over lifetime (size shrink) |
| Trigger | `burst()` 1-shot (PERFECT / NEW RECORD / milestone) / `idle_loop()` (best card 항상 visible) |
| **default** | hidden, emitting=false |
| **bursting** | emitting=true 1-shot, 자동 stop after lifetime |
| **looping** | emitting=true infinite, loop every 1.5s |
| Sound hook | 🔊 `sparkle_burst_chime` (burst), `sparkle_idle_subtle` (looping, optional very low volume) |
| 비고 | art-director sprint: sparkle PNG 16 frame sprite sheet 신규 (또는 MVP placeholder = procedural white 4-point star Polygon2D). |
| **Godot 매핑** | `scenes/ui/sparkle_particle.tscn` (GPUParticles2D + ParticleProcessMaterial radial emit + Texture sparkle.png placeholder). Sparkle texture path = `assets-processed/vfx/sparkle.png` (art-director 신규 또는 MVP procedural). 스크립트 `scripts/ui/sparkle_particle.gd` (class_name `SparkleParticle`) — `burst(count: int = 16, lifetime: float = 0.4)` / `idle_loop(count: int = 6)` / `stop_loop()` / `signal burst_complete`. |

---

## 35. CP-36 Character Idle Animator (avatar breathing / blink) — v0.6 신설

| 항목 | 값 |
|------|-----|
| 용도 | 모든 character avatar — Guest Select 카드 avatar / Result Screen Emotion Reaction avatar / Cooking guest mini-thumbnail / Menu Select mini-badge avatar |
| Type | Tween (Godot 4.x `create_tween()`) attached to Sprite2D 또는 TextureRect |
| Breathing | scale 1.0 → 1.02 → 1.0 loop 2s `TRANS_SINE TRANS_IN_OUT` — premium-redesign-v1 §9 game-designer confirm 필요 (1.0→1.02 vs 1.0→1.05) |
| Eye blink (optional) | 4초마다 0.15s간 eye_closed sprite swap (CP-26 mood sprite 활용, blink 변형 art-director sprint pending — MVP는 omit) |
| Pivot | sprite center (avatar 중앙) |
| **default** | breathing active |
| **paused** | tween paused (Pause 메뉴 시) |
| **stopped** | tween stopped, scale 1.0 (Result Reaction mood_swap 직후 잠시 stop) |
| Sound hook | (없음 — passive idle) |
| 비고 | 모든 avatar에 자동 부착 (factory function). Result Reaction mood swap 시 1.14x bounce는 별도 Tween (idle은 일시 stop). |
| **Godot 매핑** | `scripts/ui/character_idle_animator.gd` (class_name `CharacterIdleAnimator`, RefCounted). API = `static attach(target: Node2D or Control, breath_amplitude: float = 0.02, period: float = 2.0) -> CharacterIdleAnimator`. 내부에 `Tween` 보관. `pause()` / `resume()` / `stop()`. AnimationPlayer 대체 가능. PackedScene 불필요 (script-only). |

---

## 36. CP-37 Hero Number Bounce (Score / compat % / coin count premium reveal) — v0.6 신설

| 항목 | 값 |
|------|-----|
| 용도 | 핵심 숫자 hero reveal — Result Screen Score (예 "Score 8800") / Guest Select compat hero (예 "93%") / Menu Select Today's Pick compat ("92%") / coin count-up final value |
| 비율 | Label width auto / height 80~100pt 기준 |
| Font | Pretendard ExtraBold 64pt (default) / 80pt (large hero) + 2px white stroke + 6px drop shadow Soy Dark alpha 50% |
| Color | gradient vertical `accent_gold` `#FFC857` → `accent_gold_dark` `#D89B2F` (shader 또는 GradientTexture2D) |
| Halo | radial gradient behind text — `accent_gold` alpha 40% → 0% over 120px radius, 1Hz pulse 1.0→1.05 scale |
| Reveal animation | scale 0.5 → 1.2 → 1.0 over 0.6s `TRANS_BACK TRANS_OUT` (overshoot bounce) + alpha 0→1 over 0.3s |
| Halo trigger | reveal anim 시작 +0.3s 후 halo fade-in 0.2s |
| **hidden** | invisible, scale 0.5, halo invisible |
| **revealing** | bounce anim active |
| **revealed** | static scale 1.0 + halo 1Hz pulse loop |
| Sound hook | 🔊 `hero_number_reveal_chime` (reveal trigger, 2-layer sting + bell) |
| 비고 | text content change 시 (예: coin count-up 1500→1800) 별도 Tween — 본 컴포넌트는 한 번의 reveal animation 만. count-up은 CP-39 또는 별도 tween. |
| **Godot 매핑** | `scenes/ui/hero_number_bounce.tscn` (Label + halo Sprite2D + AnimationPlayer "reveal_bounce" + AnimationPlayer "halo_pulse_loop"). Gradient 적용은 `theme_override_styles/font_color` + GradientTexture2D 또는 shader (`hero_gradient.gdshader`). 스크립트 `scripts/ui/hero_number_bounce.gd` (class_name `HeroNumberBounce`) — `set_value(text: String)` / `reveal()` / `set_variant(size: String "default"/"large")` / `signal reveal_complete`. |

---

## 37. CP-38 Gold Ribbon Banner (NEW RECORD / TODAY'S PICK / milestone hero) — v0.6 신설

| 항목 | 값 |
|------|-----|
| 용도 | hero celebration banner — Result Screen NEW RECORD (CP-31 대체 upgrade) / Menu Select Today's Pick 띠 / milestone 알림 / FTUE achievement |
| 비율 | base 540×100 (default hero) / 1040×60 (Menu Select Today's Pick 전체 폭 변형) — variant prop |
| BG | NinePatchRect gold ribbon shape (좌우 fishtail cut, art-director new sprite 권장) — MVP placeholder = rounded rect gradient `accent_gold` → `accent_gold_dark` + 2px outline Soy Dark |
| Font | Pretendard ExtraBold 36pt white + 2px Soy Dark stroke + 3px drop shadow + ✨ prefix/suffix icon |
| Sparkle | CP-35 SparkleParticle 인스턴스 부착 — 24 particles burst on slide-in + 4 particles idle loop |
| Slide-in animation | Y -120 → Y target over 0.5s `TRANS_BACK TRANS_OUT` (overshoot 위에서 내려오는 hero ribbon) + 0.5s shake amplitude 4px frequency 30Hz |
| Pulse loop | revealed 후 1Hz scale 1.0→1.02 micro pulse |
| **hidden** | invisible, Y -120 |
| **slide_in** | t=0~0.5s slide + shake + sparkle burst |
| **revealed** | static + micro pulse + sparkle idle (idle 4 particles 1.5s cycle) |
| Sound hook | 🔊 `gold_ribbon_slide_in` (slide_in 시점 2-layer chime + bell, ducking -6dB other) |
| 비고 | 기존 CP-31 NEW RECORD Badge를 본 컴포넌트로 통합/upgrade. CP-31는 backward-compat alias. art-director sprint: gold ribbon NinePatch sprite (fishtail cut) 신규 권장. |
| **Godot 매핑** | `scenes/ui/gold_ribbon_banner.tscn` (NinePatchRect gold ribbon + Label + SparkleParticle child + AnimationPlayer "slide_in" + "shake" + "micro_pulse"). Variant property = "default"/"wide". 스크립트 `scripts/ui/gold_ribbon_banner.gd` (class_name `GoldRibbonBanner`) — `set_label(text)` / `set_variant(size)` / `show_banner()` / `hide_banner()` / `signal slide_in_complete`. |

---

## 38. CP-39 Coin Spray Particle (Result reward + Cooking PERFECT) — v0.6 신설

| 항목 | 값 |
|------|-----|
| 용도 | coin reward emit + tween from origin to HUD wallet — Result Screen §3 Rewards coin reveal + Cooking PERFECT bonus moment + Menu Select wallet update |
| Type | GPUParticles2D + coin texture (기존 코인 아이콘 sprite 재활용, `assets-processed/ui/coin.png`) |
| Particle count | 20 coins (default) / 30 coins (Result big reward) / 10 coins (Cooking PERFECT small) — variant prop |
| Emission | origin = emit position, spread 60° upward, speed 200~400 px/s |
| Gravity | 600 (downward arc) + Tween redirect to HUD wallet 위치 over 1.2s |
| Scale | 0.5 → 1.0 → 0.3 over lifetime (born → peak → consumed by wallet) |
| Lifetime | 1.5s (default) / 2.0s (Result big) |
| HUD wallet target | UI 상단 좌측 wallet 위치 (Menu Select X=80 Y=60 / Result X=80 Y=60) — autoload `UiNav.wallet_position()` 참조 |
| Sound hook | 🔊 `coin_spray_arc` (emit 시점 loop 1.5s, pitch shift up over time), `coin_consumed_chime` (각 코인 wallet 도달 시 미세 tick + ducking) |
| **default** | hidden |
| **spraying** | t=0~1.5s emit + Tween arc to wallet |
| **consumed** | particles 도달 후 wallet number flash + coin_HUD update 트리거 |
| 비고 | wallet 위치는 autoload UiNav 또는 scene별 노드 reference. emit origin은 caller가 set_origin(pos)으로 지정. |
| **Godot 매핑** | `scenes/ui/coin_spray_particle.tscn` (GPUParticles2D + Texture coin.png + ParticleProcessMaterial). Tween redirect는 별도 spawn 후 individual coin Sprite2D Tween (또는 ParticleProcessMaterial attractor). 스크립트 `scripts/ui/coin_spray_particle.gd` (class_name `CoinSprayParticle`) — `spray(count: int, origin: Vector2, target: Vector2, duration: float = 1.5)` / `signal spray_complete`. |

---

## 39. CP-40 Now Cooking Banner (Cooking 8 module 공통 상단) — v0.6 신설

| 항목 | 값 |
|------|-----|
| 용도 | Cooking Screen 8 module (slice/arrange/stir/flip/timing/season/roll/plate) **공통 상단** — 현재 요리 중인 dish + 누구를 위해 cook 중인지 상시 visible (premium-redesign-v1 CK-R1 fulfillment) |
| 비율 | 가로 960 × 세로 120px (X 60~1020 Y 60~180 of Cooking Screen) |
| BG | Cream `#FFF4E1` rounded 16px + outer lip 2px Soy Dark + drop shadow 8px (CP-34) |
| Layout (좌→우) | (1) Dish thumbnail X 16~96 80×80 TextureRect (음식 hero anchor) + steam particle micro (CP-35 idle 4) / (2) Dish name X 112~600 ("Tteokbokki" 28pt bold + "떡볶이" 16pt sub kr) / (3) "for" 라벨 X 620~660 16pt soft / (4) Guest avatar X 680~740 60×60 circle + idle breathing (CP-36) / (5) Guest name X 760~960 ("Junho" 22pt bold + mood emoji 24×24 우측) |
| **default** | static + dish steam idle + avatar breathing |
| **hover (dish tap)** | dish thumbnail 1.05× + brief tooltip "Tteokbokki — your goal!" |
| Sound hook | 🔊 `now_cooking_banner_appear` (Cooking entry, 1회 fade-in) |
| 비고 | Cooking 8 module scene 모두 상단에 본 컴포넌트 instance. `cooking_module_runner.tscn`에서 child로 single instance. 8 sub-module은 본 banner 아래에서만 content. |
| **Godot 매핑** | `scenes/ui/now_cooking_banner.tscn` (Panel BG + DropShadowCard + HBoxContainer + TextureRect dish + SparkleParticle steam + VBoxContainer name + Label "for" + TextureRect avatar + CharacterIdleAnimator + Label guest name + Label mood). 스크립트 `scripts/ui/now_cooking_banner.gd` (class_name `NowCookingBanner`) — `set_dish(food_id, name_en, name_kr)` / `set_guest(guest_id, name, mood)` / Cooking entry 시 cooking_module_runner.gd가 호출. |

---

## 40. CP-41 Step Progress Dots (Cooking step indicator) — v0.6 신설

| 항목 | 값 |
|------|-----|
| 용도 | Cooking Screen step 진행 dot indicator — 현재 "Step 1/4" 텍스트만 → visual dot indicator (premium-redesign-v1 CK-R9 fulfillment) |
| 비율 | 가로 240 × 세로 40px per 4-step (8-step 변형은 480 가로) — dots count variant prop |
| Layout | HBoxContainer h_sep 16px, dot 24px diameter |
| Position | Now Cooking banner 아래 Y 200~240 또는 상단 우측 X 800~1040 Y 60~100 (compact) — variant prop |
| Dot 3 state | (1) **completed** = `accent_gold` `#FFC857` filled + checkmark 14×14 white center / (2) **current** = `accent_gold` filled + scale 1.2× + 1Hz pulse halo / (3) **upcoming** = gray `#E0E0E0` filled stroke 2px |
| Transition | step 변화 시 (예: 1→2) current 완료 ✓ swap 0.3s + 다음 dot scale 1.0→1.2 + halo fade-in 0.3s |
| **default** | step 0 = all upcoming gray |
| **progress** | step N = (0~N-1) completed + (N) current + (N+1~max) upcoming |
| **complete** | step = max+1 = all completed + last dot scale 1.4 + sparkle burst (CP-35) |
| Sound hook | 🔊 `step_advance_tick` (each step 변화), `step_complete_chime` (last step) |
| 비고 | Cooking 8 module sequence는 음식별 가변 (dish_modules.csv 의존). dots count = sequence length. 음식별 step count는 cooking_module_runner.gd에서 lift. |
| **Godot 매핑** | `scenes/ui/step_progress_dots.tscn` (HBoxContainer + N TextureRect dot 인스턴스 + AnimationPlayer per dot "complete" / "current_pulse"). 스크립트 `scripts/ui/step_progress_dots.gd` (class_name `StepProgressDots`) — `set_total_steps(n: int)` / `set_current_step(step: int 0~n)` / `advance_step()` / `signal sequence_complete`. |

---

## 41. Decisions Log (이번 sprint)

| # | 결정 | 근거 |
|---|------|------|
| CP-01 | 카탈로그를 별도 파일(`components.md`)로 분리 | screen-flow / tier / ftue가 컴포넌트를 참조할 때 SSOT 필요 |
| CP-02 (v0.2) | 모든 상태 default/hover/pressed/disabled 일관 | 1인 개발 친화, **Godot Scene (.tscn) 설계와 1:1 매핑** (ADR-004) |
| CP-03 | Hover = long-press 0.3s 시각 hint로만 사용 | 모바일 portrait UX 표준 |
| CP-04 | Sound hook 위치만 mark, 실제 사운드는 M2~M3 | sound-guide.md 신설 시점에 매핑 (엔진 독립) |
| CP-05 (v0.2) | 컴포넌트 = 1 Scene(.tscn) + 1 Resource(.tres) + 1 GDScript(.gd) 트리플 | ADR-004 Godot 컨벤션. 디자이너가 .tres 편집으로 밸런스 조정 가능 (ScriptableObject 대체 패턴) |
| **CP-06 (v0.3)** | **Stage 2A Knife indicator (CP-19) = Y position translation only**, 회전 각도 변경 X (Option 1 motion lock) | ADR-005 §2A + art-anchor §5.7 G_cut_3 LEFT side static 정합, Godot Transform animation 단일 sprite 최저 cost |
| **CP-07 (v0.3)** | **Stage 2A 도마 (CP-18) = 전체 영역 단일 Button** (X 240~840 Y 1100~1450 어디든 tap 인식) | 5-second rule + one-thumb zone fingerprint tolerance |
| **CP-08 (v0.3)** | **CP-20 Tool sprite = 카드 wrapper (CP-04)와 분리된 순수 sprite layer** | Stage 2B 카드 → 2C dock motion 시 동일 sprite 재사용 (cost ↓), 음식별 TOOL-XX swap 단순화 |
| **CP-09 (v0.3)** | **CP-22 Kitchen rack = interactive X, visual cue only** | ADR-007 basic_pantry 정책 "사용자 양념 고르기 행위 X" 정합 (cooking-mech §2A.X) |
| **CP-10 (v0.3)** | **Stage 2B → 2C transition = Scene 유지** (게이지 바 fade-in만, 가스레인지 + 도구 + 음식 sprite 재사용) | 시각 일관성 + 빠른 흐름, scene-2-kitchen-layout §2.3 정합 |
| **CP-11 (v0.4)** | **CP-23 Guest Card v2 = 510×680, 옵션 A (2-col grid)** layout | 5+ guest 동시 비교, 1-thumb scroll, 6 정보 + compat 모두 fit. 옵션 B carousel/C list 비교 거부 (guest-select-v2-layout §1) |
| **CP-12 (v0.4)** | **CP-24 compat_bar = 시각 삼중 (color + bar + label)** | color-blind safe, 5-second rule. 5 tier PERFECT/GOOD/OK/LOW/BAD 매핑 |
| **CP-13 (v0.4)** | **CP-26 mood overlay = avatar 우하단 위치** (identity 유지) | avatar 정체성 보존하면서 daily 변화 즉각 인지 (BG tint + icon 이중) |
| **CP-14 (v0.4)** | **CP-27 reward bonus = full-width 띠** (CTA 바로 위) | 선택 motivation 직접 강화, "왜 이 손님인가" 시각화 |
| **CP-15 (v0.4)** | **CP-24 large/mini 2 mode 공유** (Guest Select 카드 좌상단 + Food Select 카드 우상단) | 재사용성 ↑, 시각 일관, Food/Guest 양쪽 compat 표시 한 컴포넌트로 cover |
| **CP-16 (v0.5)** | **CP-28 score_breakdown_row 6 row 공통 컴포넌트** (Prep / Cook / Seasoning / Plating / Compat bonus / Mood bonus 동일 layout) | DRY + scroll 진입 시 sequential reveal (0.2s stagger)로 narrative tempo 유지. bonus variant는 stars hide + value pill 강조 |
| **CP-17 (v0.5)** | **CP-29 reward_box 단일 panel 통합** (coins + XP + friendship bar + milestone inline expand) | 정보 인접 배치로 "보상 인식" 한 시야로 종합. milestone은 modal X = scroll 흐름 끊김 회피 (RS-04 정합) |
| **CP-18 (v0.5)** | **CP-30 emotion_reaction = CP-26 mood_badge sprite asset 재활용** (4 mood sprite로 4 tier 매핑) | 신규 reaction asset 비용 0, art-director sprint 부담 ↓, 일관성 ↑. happy/hungry/easy/grumpy 4종 사용 (picky 미사용) |
| **CP-19 (v0.5)** | **CP-31 NEW RECORD = reaction 위 overlap slide-in** (별도 banner/modal X) | 감정 hook과 인접 = "이 손님이 너의 best moment였어" emotion 강화 |
| **CP-20 (v0.5)** | **CP-32 milestone_toast = reward_box (CP-29) 내부 inline expand** (height tween +130px) | Lv 3/7/10 milestone은 narrative 일부 — modal로 분리 시 sticky CTA 도달 흐름 깨짐. inline = 자연 reveal |
| **PR-1 (v0.6)** | **4 screen placeholder art (단색 fill / 1-letter avatar) 즉시 제거**, 기존 food hero + character anchor 재활용 | 시각 quality gap (3.5/10 → 8/10) 가장 큰 원인. art 이미 2026-05-31 LOCK. `premium-redesign-v1.md` §10 PR-1 |
| **PR-2 (v0.6)** | **glossy 3D button (CP-33) + drop shadow (CP-34) + sparkle particle (CP-35) = MVP 전체 시각 baseline** | Royal Match / Travel Town 공통 분모. cost 낮음 (script-driven). 단일 sprint 안에 4 screen fan-out 가능 |
| **PR-3 (v0.6)** | **CP-36 character idle breathing 모든 avatar 강제 부착** | character presence 가장 시급 (audit 2/10). factory attach() = boilerplate 0 |
| **PR-4 (v0.6)** | **reward celebration (CP-35/37/38/39)는 Cooking + Result 핵심 hook** | Cooking Madness benchmark. 현 reward presentation 3/10 → 9/10 목표 |
| **PR-5 (v0.6)** | **Menu Select에 Today's Pick hero card (CP-38 wide variant)** 신설 | Royal Match goal card 패턴 + 5-sec rule 충족. gameplay 무변경 (compat 표시만) |
| **PR-6 (v0.6)** | **Cooking 8 module 공통 CP-40 NowCookingBanner + CP-41 StepProgressDots** | dish + guest 항상 visible (현재 부재). cooking_module_runner.tscn에 single instance |
| **PR-7 (v0.6)** | **Result Sticky CTA tier 3단계** (primary glossy / secondary outlined / tertiary text-only) | Royal Match next-level CTA pattern + hierarchy 약점 해결. CP-33 3 color variant 활용 |
| **PR-8 (v0.6)** | **shot_*.tscn 기존 캡처 스크립트 재활용 + after screenshot은 `assets-raw/_screenshots/premium_v1/`** | godot-dev 기존 workflow 정합. before/after 비교 보고서 (docs/ui/before-after-premium-v1.md, godot-dev 작성) |

---

## 42. ⚙️ Confirm 필요 / 다음 sprint 이월

1. **컴포넌트 별 정확한 px / dp 수치** — Godot Scene(.tscn) 작성 시 godot-dev와 sync. 본 문서는 비율 + scene-2-kitchen-layout v0.1에서 Stage 2A/2B/2C는 절대 px 명시.
2. **라이프 시스템 사용 여부** (HUD 컴포넌트 영향) — pm 확정.
3. **Banner 광고 정확한 위치 / IAP Remove Ads 토글** — backend-dev / godot-dev sync (AppLovin MAX Godot plugin, ADR-004).
4. **사운드 hook 정식 ID 명명** — sound-guide.md 신설 시점.
5. **Godot Resource(.tres) 스키마 표준** — IngredientResource / StoreResource / FoodResource / CharacterResource / TimingResource / CookingMethodResource + **(v0.3 신규) CutStyleResource / CookingToolResource** 8종 스키마 잠금 — godot-dev M2 sprint.
6. **(v0.3 신규) 양념재우기 손 sprite 미작성** — M2 art-director sprint 위임. MVP fallback = CP-19 칼 motion 재사용. pm 협의 필요.
7. **(v0.3 신규) CP-22 Kitchen rack 옹기 5종 individual sprite** — art-director Post-M1 sprint LOCK 후 swap. MVP placeholder = ingredient_card 5개 mini.
8. **(v0.3 신규) CP-19 Knife indicator BPM `speed_scale` 정확 매핑** — balance-config §7 음식별 prep_bpm lock 후 verify. perfect ±80ms window가 BPM 60~140 전 range에서 hit 가능한지 검증.
9. **(v0.3 신규) CP-20 Tool sprite 음식별 method_options 컬럼 lock** — game-designer foods CSV M2 sprint.
10. **(v0.3 신규) CP-21 Timing bar perfect_ratio_default 음식 12 lock** — balance-config v0.3.3 §7 후속.
11. **(v0.4 신규) CP-24 compat_score 공식 lock** — **game-designer M2 sprint**. `compat_score(menu_id, guest_id) -> int 0~100`. base_match(food.axis vs guest.like/dislike) + friendship_bonus + mood_modifier 합산. 5 tier 임계 (90/75/50/30) confirm.
12. **(v0.4 신규) CP-26 mood rotation 공식 lock** — **game-designer M2 sprint**. daily seed (player_id + date hash) vs per-round random vs guest별 mood timeline. mood 5종 → compat/reward 정확 mod 값.
13. **(v0.4 신규) CP-27 reward bonus 공식 lock** — **game-designer M2 sprint**. `bonus(compat, friendship, mood) -> int %`. 범위 -20% ~ +30% 권장. base_reward 음식별 cap CSV에서 lift.
14. **(v0.4 신규) guests.csv 신규 컬럼 `likes` / `dislikes` lift** — **game-designer M2 sprint**. 현 `vec` (sweet/salty/spicy/sour/umami)는 score용 수치 — UI 표시용 like_axis[] / dislike_axis[] (1~3 / 1~2 axis id list) 신설.
15. **(v0.4 신규) Friend avatar (junho/mina/riley/mrs_lee/seoyeon) chibi bust-up art** — **art-director Post-M1 sprint**. CH-01~05 외에 친구 5종 anchor 신설. MVP placeholder = AVATAR_TINT 원형 + 이름 첫글자.
16. **(v0.4 신규) mood / tag icon set** — **art-director Post-M1 sprint** 또는 무료 SVG icon library 라이선스 확인. 5 mood (😋😍🙂😐😡) + 6 axis (🌶🍬🧂🥩🥒🍄) 통일 스타일.
17. **(v0.5 신규) CP-28 plating / seasoning row 데이터 source** — **game-designer M2 sprint**. 현재 cooking-mech §5는 prep/method(=cook)/timing 3 axis만. plating/seasoning은 future-proof — MVP에서 row hide vs "—" 표기 vs prep/cook/timing 3 row만 표시 (4 row 제거) 결정 필요.
18. **(v0.5 신규) CP-30 reaction text 템플릿 5 axis × 4 tier = 20 template** — **game-designer M2 sprint**. friends-system v0.3 §2 Voice 톤 참조. 어머니/아버지/Mina/Junho 등 각 guest별 personality 반영.
19. **(v0.5 신규) CP-29 friendship XP curve + Lv 임계** — **game-designer M2 sprint**. Lv 0~10 각 임계 xp / round당 +xp 공식 (compat × stars × base) / Lv 3/7/10 milestone reward 값 확정.
20. **(v0.5 신규) CP-32 milestone Lv 3/7/10 reward 정확값** — **game-designer M2 sprint**. Close Friend (Lv 3) / Best Friend (Lv 7) / Soulmate (Lv 10) — bonus ₩ + extra unlock (card frame / outfit / recipe) confirm.
21. **(v0.5 신규) CP-31 NEW RECORD sprite + CP-32 milestone Lv 3/7/10 badge sprite** — **art-director Post-M1 sprint**. gold ribbon shape + milestone 3종 icon (Close Friend / Best Friend / Soulmate).
22. **(v0.5 신규) save migration `__legacy__` best_score policy** — **godot-dev / pm 확정**. 기존 단일 best_score (guest 무관) → composite `menu_id::guest_id` 전환 시 legacy 값 처리 방식 (default guest 귀속 vs 별도 키 보존 vs migration discard).
23. **(v0.6 신규) CP-36 idle breathing scale amplitude + period** — **game-designer M2 confirm**. 1.0→1.02 vs 1.0→1.05 / 2s vs 1.5s loop. 권고: 1.0→1.02 / 2s `TRANS_SINE` (subtle premium).
24. **(v0.6 신규) CP-35 sparkle particle PNG sprite sheet (16 frame radial star)** — **art-director this sprint**. MVP fallback = procedural white 4-point star Polygon2D. 4 screen 공통 자산.
25. **(v0.6 신규) CP-38 gold ribbon NinePatch sprite (fishtail cut)** — **art-director this sprint**. MVP fallback = rounded rect gradient + outline (NEW RECORD ribbon polish).
26. **(v0.6 신규) steam particle PNG (Cooking + Result dish hero용)** — **art-director this sprint**. MVP fallback = simple white circle alpha 60% GPUParticles2D.
27. **(v0.6 신규) coin spray emit origin + HUD wallet position autoload** — **godot-dev sprint**. `UiNav.wallet_position()` autoload helper 신설 vs scene별 노드 ref. 권고: autoload (4 screen 공통 HUD layout 일관).
28. **(v0.6 신규) CP-40 NowCookingBanner Cooking 8 module 공통 부착 방식** — **godot-dev sprint**. `cooking_module_runner.tscn`에서 single instance vs 각 sub-module .tscn 내부 instance. 권고: runner single instance (DRY + 음식별 sequence 무관 일관).

---

## 43. 변경 이력
- **2026-06-04 v0.6** — **Premium Redesign v1 시각 컴포넌트 CP-33~41 9종 신설** (Royal Match / Travel Town / Cooking Madness / Merge Mansion 4 reference 차용). CP-33 glossy_button (gradient + inner highlight + outer lip + 3 size variant + 3 color variant, 4 screen CTA 공통, CP-13 alias 유지) / CP-34 drop_shadow_card (Y+8/12/16 offset variant, 모든 card 공통, single PackedScene child instance) / CP-35 sparkle_particle (GPUParticles2D 16/24/30 radial burst + 4 idle loop, PERFECT/NEW RECORD/best card/Result Score reveal) / CP-36 character_idle_animator (script-only Tween scale 1.0→1.02 loop 2s `TRANS_SINE`, factory `attach()`, 모든 avatar) / CP-37 hero_number_bounce (scale 0.5→1.2→1.0 0.6s `TRANS_BACK OUT` + gradient gold + halo 1Hz pulse, Score/compat %/coin count) / CP-38 gold_ribbon_banner (540×100 또는 1040×60 wide variant + NinePatch + sparkle 24 burst + slide-in BACK_OUT + shake, CP-31 alias 통합 upgrade) / CP-39 coin_spray_particle (10/20/30 coin GPUParticles2D + Tween arc to HUD wallet 1.5s, Result reward + Cooking PERFECT) / CP-40 now_cooking_banner (dish thumb 80 + steam particle + dish name en/kr + guest avatar 60 + breathing + guest name + mood emoji, Cooking 8 module 공통 single instance) / CP-41 step_progress_dots (●○○○ N dot HBox + completed/current/upcoming 3 state + 변화 시 transition tween, Cooking step indicator). §16 Z-order에 premium visual layer 9 row 추가 (Z=45 drop shadow / Z=48 hero halo / Z=55 glossy highlight / Z=75 Today's Pick hero / Z=95 NowCooking banner / Z=96 step dots / Z=180 NEW RECORD hero / Z=200 sparkle burst / Z=210 coin spray). Decisions PR-1~8 별도 `premium-redesign-v1.md` §10 lock. Confirm #23~28 신설. 의존: art-director (sparkle PNG / steam PNG / gold ribbon NinePatch, this sprint, MVP fallback procedural) + godot-dev (P0 32h 1-week sprint, premium-redesign-v1 §7 7.1~7.5 file별 변경 list) + game-designer (CP-36 breathing scale amplitude/period confirm). 상위 신규 문서 `visual-audit-2026-06.md` v0.1 (4 screen audit) + `premium-redesign-v1.md` v0.1 (redesign spec + sprint hand-off) 정합.
- **2026-06-04 v0.5** — **Result Screen 2.0 컴포넌트 CP-28~32 5종 신설**. CP-28 score_breakdown_row (6 row 공통, label icon stars bar value, 2 variant: score / bonus) / CP-29 reward_box (단일 panel = coins count-up + XP + friendship bar fill + milestone inline expand, height +130 conditional) / CP-30 emotion_reaction (avatar mood swap + speech bubble + typewriter text, mood_badge sprite 4종 재활용) / CP-31 new_record_badge (gold ribbon slide-in, best score 갱신 시 reaction 위 overlap) / CP-32 milestone_toast (reward_box 내부 inline expand, Lv 3/7/10, gold gradient + sparkle particle 30). §16 Z-order에 Result Screen layer 5종 (Sticky CTA 100 / ScrollContainer content 50 / speech bubble 60 / milestone toast 65 / NEW RECORD overlap 70) 추가. Decisions CP-16~20 신설 + Confirm #17~22 신설. 상위 신규 문서 `result-screen-v2-layout.md` v0.1 정합. 의존: game-designer M2 (plating/seasoning data / reaction template 20개 / friendship XP curve / milestone reward) + art-director Post-M1 (NEW RECORD ribbon + milestone Lv 3/7/10 badge 3종) + godot-dev (PackedScene + Tween + save migration menu_id::guest_id composite key).
- **2026-06-04 v0.4** — **Guest 2.0 컴포넌트 CP-23~27 5종 신설**. CP-23 guest_card_v2 (510×680, avatar + friendship + likes + dislikes + mood + reward + compat 통합, ✨RECOMMENDED 띠 best card) / CP-24 compat_bar (large/mini 2 mode 공유, 5 tier 시각 삼중 color+bar+label) / CP-25 flavor_tag_badge (5+1 axis like/dislike, ❌ overlay 채도 -30%) / CP-26 mood_badge (5 mood overlay, avatar 우하단, daily change pop) / CP-27 reward_bonus_badge (full-width 띠, gradient compat color, ★ sparkle ≥20%). §16 Z-order에 Guest Select 카드 내부 layer (50/60/65/70/75) + Food Select mini-badge layer (60) 추가. Decisions CP-11~15 신설 + Confirm #11~16 신설. 상위 신규 문서 `guest-select-v2-layout.md` v0.1 + `food-select-compat.md` v0.1 정합. 의존: game-designer compat_score()/mood rotation/reward bonus 공식 + guests.csv likes/dislikes 컬럼 lift (M2). art-director: friend 5종 avatar + mood/tag icon set (Post-M1).
- **2026-05-31 v0.3** — ADR-005 4-stage 메커닉 + ADR-007 basic_pantry 지원 컴포넌트 **CP-18~22 5종 신설**. CP-18 도마(cutting board, Stage 2A tap target, CUT-00 art anchor 의존) / CP-19 Knife indicator (위↕아래 motion, AnimationPlayer "knife_loop", BPM speed_scale, perfect ±80ms Gold glow halo, Option 1 motion lock = Y position translation only) / CP-20 Tool sprite (TOOL-01~12 generic swap layer, Stage 2B 카드 → 2C dock Tween arc motion) / CP-21 Timing bar (Stage 2C, full width Y 1150~1280, PERFECT 10%/20% Gold + 빗금, food.cook_time_sec 기반 Tween linear, 구 §5 통합) / CP-22 Kitchen rack (basic_pantry 5종 옹기, 우측 상단 Y 130~340, interactive X visual cue only, 양념재우기 round arc motion). §5 (기존 Timing bar)는 CP-21 alias로 deprecation 표시. §16 Z-order에 Kitchen rack(80) + Stage 2A/2B/2C 영역(50) + 캐릭터(40) 신규 layer 추가. Decisions CP-06~10 신설 + Confirm #6~10 신설. 의존 art lock: CUT-00 + CUT-01~06 + TOOL-01~12 + ING-01~12 whole + ICUT-01~12 cut + CH-01 (모두 2026-05-31 LOCK 완료) + 옹기 5종 (Post-M1 pending). 상위 신규 문서 `scene-2-kitchen-layout.md` v0.1 (Stage 2A/2B/2C layout detail) 참조.
- **2026-05-24 v0.2** — Godot 전환 sync, 컨벤션은 ADR-004 참조. 15종 컴포넌트 모두에 **Godot 매핑** 행 추가 (Unity prefab → Godot Scene .tscn, ScriptableObject → Resource .tres, MonoBehaviour → GDScript .gd, Assets/ → godot-project/scenes/·scripts/·resources/·assets/). State는 Godot Control Node theme override 또는 AnimationPlayer 기반 명시. 사운드 hook 위치 무변경(엔진 독립). 식탁 캐릭터 영역(§6) + Pause/모달(§15)은 양친 L11 동시 unlock 컷씬(tier-1-2-flow §3.4 v0.2)으로 sync. CP-02 라벨 갱신 + CP-05 신설. Confirm #5(Resource 스키마) 신규.
- **2026-05-23 v0.1** — 초안. 15종 컴포넌트(재료 카드·가게 선반·시장 입구 layout·키친 도구 슬롯·타이밍 게이지·식탁 캐릭터 영역·★ rating·타이머·코인 HUD·Hint 버튼·요리 카드·장바구니 미리보기·CTA·Toast·Pause/모달) + Layout Z-order. art-style 톤 매핑 + sound hook 위치 mark.
