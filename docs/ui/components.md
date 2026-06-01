# UI Components — 재사용 컴포넌트 카탈로그

> 버전: **v0.3** · 갱신일: 2026-05-31 · 작성자: ui-designer
> 상위 문서: [`screen-flow.md` v0.3](screen-flow.md), [`scene-2-kitchen-layout.md` v0.1](scene-2-kitchen-layout.md), [`tier-1-2-flow.md`](tier-1-2-flow.md), [`ftue.md`](ftue.md), [`../art-style-guide.md`](../art-style-guide.md), [`../systems/cooking-mechanics.md` v0.6](../systems/cooking-mechanics.md), [`../decisions.md` ADR-004](../decisions.md#adr-004-엔진-선택--godot-46-gdscript-only-채택-claudemd-implicit-unity-정식-대체), [`../decisions.md` ADR-005](../decisions.md#adr-005), [`../decisions.md` ADR-007](../decisions.md#adr-007)
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

---

## 22. Decisions Log (이번 sprint)

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

---

## 23. ⚙️ Confirm 필요 / 다음 sprint 이월

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

---

## 24. 변경 이력
- **2026-05-31 v0.3** — ADR-005 4-stage 메커닉 + ADR-007 basic_pantry 지원 컴포넌트 **CP-18~22 5종 신설**. CP-18 도마(cutting board, Stage 2A tap target, CUT-00 art anchor 의존) / CP-19 Knife indicator (위↕아래 motion, AnimationPlayer "knife_loop", BPM speed_scale, perfect ±80ms Gold glow halo, Option 1 motion lock = Y position translation only) / CP-20 Tool sprite (TOOL-01~12 generic swap layer, Stage 2B 카드 → 2C dock Tween arc motion) / CP-21 Timing bar (Stage 2C, full width Y 1150~1280, PERFECT 10%/20% Gold + 빗금, food.cook_time_sec 기반 Tween linear, 구 §5 통합) / CP-22 Kitchen rack (basic_pantry 5종 옹기, 우측 상단 Y 130~340, interactive X visual cue only, 양념재우기 round arc motion). §5 (기존 Timing bar)는 CP-21 alias로 deprecation 표시. §16 Z-order에 Kitchen rack(80) + Stage 2A/2B/2C 영역(50) + 캐릭터(40) 신규 layer 추가. Decisions CP-06~10 신설 + Confirm #6~10 신설. 의존 art lock: CUT-00 + CUT-01~06 + TOOL-01~12 + ING-01~12 whole + ICUT-01~12 cut + CH-01 (모두 2026-05-31 LOCK 완료) + 옹기 5종 (Post-M1 pending). 상위 신규 문서 `scene-2-kitchen-layout.md` v0.1 (Stage 2A/2B/2C layout detail) 참조.
- **2026-05-24 v0.2** — Godot 전환 sync, 컨벤션은 ADR-004 참조. 15종 컴포넌트 모두에 **Godot 매핑** 행 추가 (Unity prefab → Godot Scene .tscn, ScriptableObject → Resource .tres, MonoBehaviour → GDScript .gd, Assets/ → godot-project/scenes/·scripts/·resources/·assets/). State는 Godot Control Node theme override 또는 AnimationPlayer 기반 명시. 사운드 hook 위치 무변경(엔진 독립). 식탁 캐릭터 영역(§6) + Pause/모달(§15)은 양친 L11 동시 unlock 컷씬(tier-1-2-flow §3.4 v0.2)으로 sync. CP-02 라벨 갱신 + CP-05 신설. Confirm #5(Resource 스키마) 신규.
- **2026-05-23 v0.1** — 초안. 15종 컴포넌트(재료 카드·가게 선반·시장 입구 layout·키친 도구 슬롯·타이밍 게이지·식탁 캐릭터 영역·★ rating·타이머·코인 HUD·Hint 버튼·요리 카드·장바구니 미리보기·CTA·Toast·Pause/모달) + Layout Z-order. art-style 톤 매핑 + sound hook 위치 mark.
