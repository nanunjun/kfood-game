# UI Components — 재사용 컴포넌트 카탈로그

> 버전: **v0.2** · 갱신일: 2026-05-24 · 작성자: ui-designer
> 상위 문서: [`screen-flow.md`](screen-flow.md), [`tier-1-2-flow.md`](tier-1-2-flow.md), [`ftue.md`](ftue.md), [`../art-style-guide.md`](../art-style-guide.md), [`../decisions.md` ADR-004](../decisions.md#adr-004-엔진-선택--godot-46-gdscript-only-채택-claudemd-implicit-unity-정식-대체)
> **MVP scope**: 본 카탈로그는 Tier 1·2 + 다점포 5가게 + 식탁 2종 운영에 필요한 컴포넌트만. Tier 3~5 / 파티 모드 컴포넌트는 post-launch.
> **엔진**: Godot 4.6 (GDScript only). 컴포넌트 = **Godot Scene (.tscn)** 단위로 1:1 매핑. 컨벤션은 ADR-004 참조 (파일명 `snake_case.tscn` / `snake_case.tres` / `snake_case.gd`, 클래스명 PascalCase).

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

## 5. 타이밍 게이지 (Timing Bar)

| 항목 | 값 |
|------|-----|
| 용도 | Scene 2 Stage 3 — 가로 게이지 + 인디케이터 |
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

## 16. Layout / 시그니처 그리드 요약

| 요소 | 위치 | Z-order |
|------|------|---------|
| 상단 HUD (코인·라이프·Lv·Pause) | top, height 60px | 100 |
| 요리 카드 (floating) | top, below HUD | 90 |
| Scene BG | full | 0 |
| 카드/캐릭터 area | center | 50 |
| 하단 액션 바 (타이머·CTA·바구니) | bottom, height 100px | 100 |
| Banner 광고 | bottom (메인 메뉴만) | 100 |
| Modal / Toast | full overlay | 200 |

---

## 17. Decisions Log (이번 sprint)

| # | 결정 | 근거 |
|---|------|------|
| CP-01 | 카탈로그를 별도 파일(`components.md`)로 분리 | screen-flow / tier / ftue가 컴포넌트를 참조할 때 SSOT 필요 |
| CP-02 (v0.2) | 모든 상태 default/hover/pressed/disabled 일관 | 1인 개발 친화, **Godot Scene (.tscn) 설계와 1:1 매핑** (ADR-004) |
| CP-03 | Hover = long-press 0.3s 시각 hint로만 사용 | 모바일 portrait UX 표준 |
| CP-04 | Sound hook 위치만 mark, 실제 사운드는 M2~M3 | sound-guide.md 신설 시점에 매핑 (엔진 독립) |
| CP-05 (v0.2) | 컴포넌트 = 1 Scene(.tscn) + 1 Resource(.tres) + 1 GDScript(.gd) 트리플 | ADR-004 Godot 컨벤션. 디자이너가 .tres 편집으로 밸런스 조정 가능 (ScriptableObject 대체 패턴) |

---

## 18. ⚙️ Confirm 필요 / 다음 sprint 이월

1. **컴포넌트 별 정확한 px / dp 수치** — Godot Scene(.tscn) 작성 시 godot-dev와 sync. 본 문서는 비율만.
2. **라이프 시스템 사용 여부** (HUD 컴포넌트 영향) — pm 확정.
3. **Banner 광고 정확한 위치 / IAP Remove Ads 토글** — backend-dev / godot-dev sync (AppLovin MAX Godot plugin, ADR-004).
4. **사운드 hook 정식 ID 명명** — sound-guide.md 신설 시점.
5. **Godot Resource(.tres) 스키마 표준** — IngredientResource / StoreResource / FoodResource / CharacterResource / TimingResource / CookingMethodResource 6종 스키마 잠금 — godot-dev 다음 sprint.

---

## 19. 변경 이력
- **2026-05-24 v0.2** — Godot 전환 sync, 컨벤션은 ADR-004 참조. 15종 컴포넌트 모두에 **Godot 매핑** 행 추가 (Unity prefab → Godot Scene .tscn, ScriptableObject → Resource .tres, MonoBehaviour → GDScript .gd, Assets/ → godot-project/scenes/·scripts/·resources/·assets/). State는 Godot Control Node theme override 또는 AnimationPlayer 기반 명시. 사운드 hook 위치 무변경(엔진 독립). 식탁 캐릭터 영역(§6) + Pause/모달(§15)은 양친 L11 동시 unlock 컷씬(tier-1-2-flow §3.4 v0.2)으로 sync. CP-02 라벨 갱신 + CP-05 신설. Confirm #5(Resource 스키마) 신규.
- **2026-05-23 v0.1** — 초안. 15종 컴포넌트(재료 카드·가게 선반·시장 입구 layout·키친 도구 슬롯·타이밍 게이지·식탁 캐릭터 영역·★ rating·타이머·코인 HUD·Hint 버튼·요리 카드·장바구니 미리보기·CTA·Toast·Pause/모달) + Layout Z-order. art-style 톤 매핑 + sound hook 위치 mark.
