# Asset Production List v1 — Placeholder Swap Sprint (2026-06-04)

> 작성: art-director · 대상: pm, godot-dev, ui-designer
> 근거: [`placeholder-audit-2026-06.md`](placeholder-audit-2026-06.md)
> 비용 단위: GPT-4o image / DALL-E 3 ≈ **$0.042/장** (ChatGPT Plus $20/월 plan 안에서 한도 내 무료)
> 시간 단위: anchor 1장 ≈ **0.4~0.6h** (master prompt + reference upload + 2~3 iteration + rembg → import)

---

## 0. Top-line Numbers

| 작업 단위 | PNG 신규 | 기존 LOCK import만 | 총 작업 시간 | 외부 비용 (Plus plan 한도 가정 무료) |
|----------|---------|-------------------|-------------|--------------------------------------|
| **P0 Sprint** (Character + Tool) | **41장** | 47 import | **24~30h** | **~$1.7** (image gen cost) |
| **P1 Sprint** (Result hierarchy + Guest card) | **3장** | 5 import (UI/VFX) | **2~3h** | **~$0.1** |
| **P2 Sprint** (Menu polish + BG) | **0장** | 5 import (BG-01~05) + 1 polish anchor | **3~4h** | **~$0.04** |
| **합계 (P0+P1+P2)** | **44장** | **57 import** | **29~37h** | **~$1.9** |

> 코드측 placeholder swap (procedural → TextureRect) 작업은 godot-dev 4~6h 추가 (별도 추정).

---

## 1. P0 — Character Art Integration (CRITICAL, 즉시 시작)

### 1.A Guest Avatar (bust-up, used in menu/guest/cooking/result)

| ID | Guest | File name | Size | Reference | Notes |
|----|-------|-----------|------|-----------|-------|
| CH-A-01 | junho | `CH-junho_avatar_v1.png` | 1024x1024 | 새 디자인 (한국 20대 남성, friend, casual modern) | spicy preference visual cue (어깨 살짝 으쓱) |
| CH-A-02 | mina | `CH-mina_avatar_v1.png` | 1024x1024 | 새 디자인 (한국 20대 여성, friend, bright) | sweet preference (밝은 미소) |
| CH-A-03 | riley | `CH-riley_avatar_v1.png` | 1024x1024 | 새 디자인 (서양 20대, friend, blue-tone) | umami curious (호기심 표정) |
| CH-A-04 | mrs_lee | `CH-mrs_lee_avatar_v1.png` | 1024x1024 | 새 디자인 (한국 40대 여성, neighbor) | fermented expert (자상한 표정) |
| CH-A-05 | seoyeon | `CH-seoyeon_avatar_v1.png` | 1024x1024 | 새 디자인 (한국 30대 여성, blogger) | sour curious (살짝 평가하는 표정) |

**소계**: 5장 × 0.5h = **2.5h**, 비용 ~$0.21

### 1.B Guest Emotion Variants (×4 emotions per guest)

각 guest 별로 ★1 bad / ★2 okay / ★3 good / ★4-5 excellent 4 expression. 같은 채팅 세션 내 follow-up sequence (avatar reference 고정).

| Guest | Emotions | Count |
|-------|----------|-------|
| junho | bad / okay / good / excellent | 4 |
| mina | 동일 | 4 |
| riley | 동일 | 4 |
| mrs_lee | 동일 | 4 |
| seoyeon | 동일 | 4 |

**소계**: 20장 × 0.4h = **8h**, 비용 ~$0.84

### 1.C 기존 LOCK Mother/Father import (코드 hook + 사용)

| File (LOCK 위치) | Target (godot-project/art/) | Used in |
|------------------|----------------------------|---------|
| `assets-raw/week1-anchors/CH-02_mother_v2.png` | `godot-project/art/sprites/character/mother_01_avatar.png` | menu/guest/cooking/result |
| `assets-raw/week1-anchors/CH-03_father.png` | `godot-project/art/sprites/character/father_01_avatar.png` | 동일 |
| `assets-raw/transparent_m1/reaction_anchors_m1/R-01~03_mother_star1~3_v2.png` (3장) | `godot-project/art/sprites/reaction/mother_01_{bad,okay,good}.png` | emotion_reaction.gd |
| `assets-raw/transparent_m1/reaction_anchors_m1/R-04~06_father_star1~3_v2.png` (3장) | `godot-project/art/sprites/reaction/father_01_{bad,okay,good}.png` | 동일 |

**소계**: 8장 import 작업 = **0.5h**, 비용 $0

### 1.D Protagonist 활용 (CH-01)

| File (LOCK) | Target | Used in |
|-------------|--------|---------|
| `assets-raw/week1-anchors/CH-01_protagonist.png` | `godot-project/art/sprites/character/player_avatar.png` | tutorial / settings header (optional P1) |

**P0 합계**: 신규 **25장** + import **9장**, ~**11h**, 비용 ~$1.05

---

## 2. P0 — Cooking Tool Visuals

### 2.A 8 Module Backplate (조리 surface별 다른 시각 identity)

각 module의 cooking surface가 procedural ColorRect → 모듈별 specific BG/stage scene.

| Module | Backplate concept | File name | Size |
|--------|------------------|-----------|------|
| slice | 도마 + 칼 + 손 silhouette + 빛 spotlight | `MOD-01_slice_stage_v1.png` | 1080x800 |
| arrange | 5 slot 김밥 김 위 ingredient placement spotlight | `MOD-02_arrange_stage_v1.png` | 1080x800 |
| stir | 팬 위 top-down 스푼 swirl trail | `MOD-03_stir_stage_v1.png` | 1080x800 |
| flip | 팬 측면 view + tossing trajectory ghost | `MOD-04_flip_stage_v1.png` | 1080x800 |
| timing | 타이머 풍 burner + bubble pop pattern | `MOD-05_timing_stage_v1.png` | 1080x800 |
| season | 양념통 + 떨어지는 양념 sparkle | `MOD-06_season_stage_v1.png` | 1080x800 |
| roll | 김발 + rolling motion arrow | `MOD-07_roll_stage_v1.png` | 1080x800 |
| plate | 3 vessel choice + 상차림 hint | `MOD-08_plate_stage_v1.png` | 1080x800 |

**소계**: 8장 × 0.6h = **4.8h**, 비용 ~$0.34

### 2.B 기존 LOCK Tool import 활용 (이미 godot-project/art/sprites/tool/ 에 9장 있으나 module에서 사용 X)

코드 hook만 필요 (신규 PNG 0장). 도구 LOCK는 이미 import 완료, **module 코드의 procedural ColorRect를 TextureRect로 교체** = godot-dev 작업.

| Tool LOCK | 활용 module |
|-----------|------------|
| TOOL-01 stovetop_gas_burner | timing, stir, flip의 BG element |
| TOOL-02 pot_yangun | timing (boil) |
| TOOL-03 frying_pan | stir, flip |
| TOOL-04 deep_fryer_pot | flip (deepfry variant) |
| TOOL-05 grill_wire_grate | timing (galbi) |
| TOOL-06 ladle | stir의 hand 도구 |
| TOOL-07 wok_spatula | stir (alt) |
| TOOL-08 turner_flipper | flip |
| TOOL-09 tongs | flip (galbi) |
| TOOL-10 bamboo_rolling_mat | roll |
| TOOL-11 mixing_bowl | season |
| TOOL-12 korean_bbq_scissors | plate (cut on table) |
| cutting_board (cut_anchors) | slice |
| cut_sliced_rounds | slice (visual feedback) |

**소계**: 신규 0장, godot-dev 코드 swap ~3h (별도 추정), 비용 $0

### 2.C 신규 cut style 5장 (LOCK은 있는데 art/ 폴더 미import)

| File (LOCK) | Target |
|-------------|--------|
| `cut_style_cube_v1.png` | `godot-project/art/sprites/cut/cut_cube.png` |
| `cut_style_diagonal_v1.png` | `godot-project/art/sprites/cut/cut_diagonal.png` |
| `cut_style_julienne_v1.png` | `godot-project/art/sprites/cut/cut_julienne.png` |
| `cut_style_mince_v1.png` | `godot-project/art/sprites/cut/cut_mince.png` |
| `cut_style_whole_v1.png` | `godot-project/art/sprites/cut/cut_whole.png` |

**소계**: import 5장 = **0.4h**, 비용 $0

**P0 cooking 합계**: 신규 **8장** + import **5장** (+ tool 9장 이미 import됨), ~**5.2h**, 비용 ~$0.34

**P0 GRAND TOTAL** (character + cooking): **신규 33장 + import 14장, ~16.2h, 비용 ~$1.39**

---

## 3. P1 — Result Screen Hierarchy

### 3.A Vector star sprite (★) — UI-02 LOCK 활용 + state variant

| State | File | Source |
|-------|------|--------|
| empty | `star_empty.png` | `UI-02_star_rating_v1.png` 변형 (filter) |
| half | `star_half.png` | 신규 PNG (LOCK 변형) |
| full | `star_full.png` | UI-02 그대로 |

**소계**: 신규 1장 (star_half) + import 2장 = **0.5h**, 비용 ~$0.04

### 3.B `ready` flag 수정 (Kimchi Stew 등)

신규 PNG 0장. **`menus.csv` 데이터 수정** (godot-dev / game-designer 작업). Kimchi Stew의 `F-09_kimchi_jjigae_v1.png`는 이미 LOCK 됐는데 menus.csv ready=false. → ready=true 변경하면 즉시 placeholder beige bowl 사라짐. **art 작업 0h, 데이터 작업 5분.**

### 3.C 12 음식 ready flag 전수 점검

LOCK된 PNG 12장 중 menus.csv에 ready=true로 hook 안 된 것이 있는지 전수 확인 = game-designer 작업. art-director 추정 영향 = 0~3 dish placeholder 추가 회복.

**P1 합계**: 신규 **1장** + import **2장**, ~**0.5h**, 비용 ~$0.04

---

## 4. P1 — Guest Card Simplification

### 4.A 시각 noise 제거 가이드 (신규 art 없음, ui-designer 작업)

현 guest_card_v2.gd가 510x680 panel에 담은 element:
1. compat 80pt hero
2. Friendship stars `*-----` (텍스트)
3. Avatar 240x240 + initial letter (P0에서 해결)
4. Mood badge 100x100
5. Name 40pt + Role 18pt
6. Likes 1~3 flavor tag
7. Avoids 1~2 flavor tag
8. Reward bonus band
9. RECOMMENDED ribbon
10. Cook CTA

**권고 simplify** (ui-designer hand-off):
- Friendship stars → 작은 vector star × 5 (P1 §3.A)와 통합
- Likes/Avoids 7개 axis 모든 표시 → top 2 + top 1로 축소
- 모든 캡션 ("compat" / "Friendship X/10")의 font weight 한 단계 down → hero number만 부각

**소계**: 신규 art 0장 (3.A와 통합)

---

## 5. P2 — Menu Card Polish

### 5.A Market BG import (LOCK 5장)

| File (LOCK) | Target | Used in |
|-------------|--------|---------|
| `BG-01_greengrocer_v4.png` | `godot-project/art/bg/market_greengrocer.png` | menu_select (Lv 1~2) |
| `BG-02_butcher_v4.png` | `godot-project/art/bg/market_butcher.png` | menu_select (Lv 3~4) |
| `BG-03_fishmonger_v5.png` | `godot-project/art/bg/market_fishmonger.png` | menu_select (Lv 5~6) |
| `BG-04_grain_shop_v4.png` | `godot-project/art/bg/market_grain.png` | menu_select (Lv 7~8) |
| `BG-05_sauces_v4.png` | `godot-project/art/bg/market_sauces.png` | menu_select (Lv 9+) |

**소계**: import 5장 = **0.4h**, 비용 $0
**효과**: MarketBG procedural → level별 다른 시장 가게 BG. menu_select / cooking 모두 시각 풍부도 ↑.

### 5.B 추가 polish (선택)

- **drop shadow ribbon 좌우 fade edge** (sprite 1장 → ribbon corner 자연스러움 ↑): `ribbon_fade_edge.png` 신규 1장 (선택)
- **lock icon** vector (현 "UNLOCK Lv X" 텍스트 옆): `lock_icon.png` 신규 1장 (선택)

**P2 합계**: 신규 **0~2장** (선택) + import **5장**, ~**0.5~1h**, 비용 ~$0.04~0.08

---

## 6. Character Expression Matrix (Per Guest × Emotion)

| Guest | bad (★1) | okay (★2) | good (★3) | excellent (★4-5) | Source |
|-------|----------|-----------|-----------|-----------------|--------|
| junho | new | new | new | new | gen P0 |
| mina | new | new | new | new | gen P0 |
| riley | new | new | new | new | gen P0 |
| mrs_lee | new | new | new | new | gen P0 |
| seoyeon | new | new | new | new | gen P0 |
| mother_01 | LOCK R-01 v2 | (avatar) | LOCK R-02 v2 | LOCK R-03 v2 | import only |
| father_01 | LOCK R-04 v2 | (avatar) | LOCK R-05 v2 | LOCK R-06 v2 | import only |
| **합계** | **신규 5 + LOCK 2** | **신규 5 + base 2** | **신규 5 + LOCK 2** | **신규 5 + LOCK 2** | |

> mother/father는 ★2 okay state가 LOCK에 부재. avatar 기본 표정 재사용 OK (P2에서 ★2 v1 신규 가능 = 추가 2장).

---

## 7. Dependency Graph

```
[P0.1 Character avatar 5 gen]
       |
       v
[P0.2 Character emotion 20 gen] ← reference upload (avatar)
       |
       v
[godot-dev: AVATAR_TINT → load(avatar.png) swap]
       |
       v
[P1.4 Guest card simplification — visible after avatar swap]

[P0.3 Mother/Father import 8장 (병렬, 의존 없음)] → emotion_reaction.gd 코드 swap

[P0.5 Cut style import 5장 (병렬)] → slice_module.gd swap
[P0.6 Tool 9장 already imported] → 8 module 코드 swap
[P0.7 Module backplate 8 gen (병렬)] → 8 module 코드 BG swap
       |
       v
[Cooking 화면 시각 완성]

[P1.3 Vector star 3 state] → result + guest card
[P1.5 menus.csv ready flag 점검 — game-designer 의존, 5분 작업]

[P2.5 BG-01~05 import] → market_bg.gd 코드 swap
```

**Critical path**: P0.1 → P0.2 → godot-dev swap = ~8~10h 가능 (병렬화 최대).

---

## 8. Per-File Master Prompt 템플릿 (5 guests avatar용)

> ChatGPT (GPT-4o image) 작업 시 ADR-006 정책 = 자연어 + reference upload + master prompt. 캐릭터 일관성 lock을 위해 같은 채팅 세션 사용.

**Master prompt (반복 사용 anchor)**:
```
modern Korean mobile casual cooking game character avatar,
subject: [GUEST DESCRIPTION HERE],
bust-up portrait, slightly 3/4 angle facing right,
modern saturated palette (no beige storybook tone),
clean cel-shaded with soft rim light,
transparent background, no text, no border,
1024x1024 square, friendly approachable expression,
art-style anchor: same as attached reference (premium_v2 food anchor cleanliness)
```

**Per-guest subject anchor**:
- junho: "Korean man, 25yo, short black hair, casual hoodie, friendly grin, slight spicy-loving cocky energy"
- mina: "Korean woman, 23yo, long brown hair with pastel highlights, cute denim jacket, bright sweet smile"
- riley: "Western (American) person, 27yo, short blonde curly hair, plaid shirt, curious umami-explorer expression"
- mrs_lee: "Korean woman, 45yo, neat short bob, modest beige cardigan, warm wise expression, fermented-food expert"
- seoyeon: "Korean woman, 32yo, sharp bob with bangs, modern minimal outfit, food-blogger-evaluating gaze"

**Emotion follow-up prompts** (avatar 생성 후 같은 세션):
```
same character, same outfit, same lighting, transparent background,
expression change: [bad / okay / good / excellent emotion]
```

---

## 9. Production Order (실행 순서)

| Day | Task | Output | Time |
|-----|------|--------|------|
| D1 AM | mother/father import 8장 + 코드 swap | emotion_reaction.gd 2 guests 시각 회복 | 1h |
| D1 PM | Tool 9 + cut 5 import + 8 module 코드 swap | cooking 화면 procedural → real tool | 4h |
| D2 AM | 5 guest avatar 생성 (병렬 ChatGPT session 분할) | CH-A-01~05 | 3h |
| D2 PM | godot-dev: AVATAR_TINT → load() swap | 3 screen (menu/guest/result) 즉시 시각 변경 | 1.5h (godot-dev) |
| D3 | 20 emotion 생성 (5 guest × 4) | reaction sprite | 8h |
| D4 AM | 8 module backplate 생성 | MOD-01~08 | 4.8h |
| D4 PM | Vector star 3 state + BG import 5 + menus.csv ready 점검 | P1 + P2 완료 | 2h |
| D5 | godot-dev integration sweep + smoke test | placeholder → art 완전 swap | 4h (godot-dev) |

**총 art 작업**: 약 **29~37h** (5 work days @ 6h)
**총 godot-dev 작업**: 약 **4~6h** (placeholder swap 코드)
**총 비용**: **~$1.9** (ChatGPT Plus plan 한도 내, 실 절감)

---

## 10. Acceptance Criteria

- [ ] 5 guests 모두 avatar PNG로 표시 (menu/guest/cooking/result 4 screen)
- [ ] Kimchi Stew 포함 12 음식 모두 menu_select에 thumb 표시 (Art coming soon 0건)
- [ ] 8 cooking module 모두 다른 backplate art 보유 (slice ≠ stir ≠ plate)
- [ ] Cooking 화면 procedural ColorRect TAP pad 제거 → tool sprite + 재료 sprite overlay
- [ ] Result Stars `*` 텍스트 0건 → vector star sprite × 5
- [ ] Friendship `*-----` 텍스트 0건 → 동일
- [ ] Market BG 5 가게 level별 다른 BG 표시
