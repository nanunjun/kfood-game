# Art Production Sprint 1 — Style Bible v1 production assets

> 버전: **v1.0 (2026-06-06)** · 작성: art-director
> 상위: [`style-bible-v1.md`](style-bible-v1.md) LOCKED (warm cozy premium-casual / Cooking Diary · Animal Restaurant · Travel Town / **NOT Royal Match**)
> 성격: **production reskin** — 기존 Cool Sage / Royal Match anchor 톤을 Style Bible v1 warm 톤으로 생산.
> 도구: ChatGPT (gpt-image-1) — ADR-006. driver = `tools/gen_character_pack.py` / `gen_environment_pack.py` / `gen_ui_vfx_pack.py`.
> Hero benchmark: `assets-raw/hero/cooking_hero_ramen_v1.png` (7/7 PASS) = 모든 asset 톤 기준.

---

## 0. Asset list (총 43 PNG)

| Priority | Pack | 수량 | driver | 출력 dir |
|----------|------|-----|--------|---------|
| **P1** (gate) | Character Production Pack | **28** (7 char × 4 emotion) | `gen_character_pack.py` | `assets-raw/character_pack_m2/` |
| **P2** | Environment Pack L1~L5 | **5** | `gen_environment_pack.py` | `assets-raw/environment_pack_m2/` |
| **P3** | UI Theme Pack | **5 sheets** (card/panel/button/ribbon/icon family) | `gen_ui_vfx_pack.py --group ui` | `assets-raw/ui_vfx_pack_m2/` |
| **P4** | VFX Pack | **5 sprites** (steam/sparkle/oil/glow/friendship) | `gen_ui_vfx_pack.py --group vfx` | `assets-raw/ui_vfx_pack_m2/` |
| | **총계** | **43 PNG** | | |

### P1 — 28 PNG (gate, character-first)
7 character × {neutral, happy, excited, disappointed}:
`junho_*` `mina_*` `riley_*` `mrs_lee_*` `seoyeon_*` `mother_01_*` `father_01_*`
파일명: `{guest_id}_{emotion}_v1.png` (예: `junho_neutral_v1.png`).
- 5 친구/멘토 = guests.csv 매핑 + **OLD Cool Sage avatar (assets-raw/guest_avatars_m1/) → warm 톤 production reskin**.
- **mother_01 / father_01 = 신규 bust avatar** (기존엔 reaction R-01~06만 존재, bust 아바타 0건).

### P2 — 5 PNG
`L1_home_kitchen` / `L2_snack_shop` / `L3_traditional_market` / `L4_food_alley` / `L5_prestige_restaurant` (`_v1.png`).
- 기존 BG-01~05 (재료 가게 storefront)와 **다른 cooking 환경** (플레이어가 요리하는 backdrop, L1→L5 격상).

### P3 — 5 UI sheets
`ui_card_frame` / `ui_panel_frame` / `ui_button_family` / `ui_ribbon_family` / `ui_icon_family` (`_v1.png`, transparent).
- 기존 UI-01~07 reskin. 9-slice 권고는 §6.

### P4 — 5 VFX sprites
`vfx_steam` / `vfx_sparkle` / `vfx_oil_splash` / `vfx_cooking_glow` / `vfx_friendship_gain` (`_v1.png`, transparent).
- 기존 VFX-01~05 reskin. subtle only (Style Bible §8).

---

## 1. Silhouette + Color Identity 표 (Style Bible §4.1 silhouette test)

> **규칙**: 7명을 흑백 실루엣으로 축소해도 **머리모양 + 상의 컬러 block 1개**로 구분 가능해야 PASS.

| ID | 캐릭터 | **Silhouette anchor** (흑백 구분) | **Color anchor** (고유색) | Korean food personality cue |
|----|--------|-----------------------------------|---------------------------|------------------------------|
| `junho` | Junho | 짧은 spiky-front 머리, 둥근 얼굴 | **Persimmon→Gochu 레드** 후드 #E8732C/#D84338 | chili/flame 가슴 모티프, spicy 호방 |
| `mina` | Mina | **side ponytail** + 작은 hair clip | **warm yellow/cream** 톱 (Sesame Gold tint) | strawberry/heart 모티프, sweet 발랄 |
| `riley` | Riley | 짧은 wavy + **freckle** dots | **blue-tone** 후드 (warm-lean blue, lemon accent) | lemon-slice 모티프, **유일 비-Korean honey-blonde** |
| `mrs_lee` | Mrs Lee | **permed wavy** 중간머리 + **round glasses** | **mauve top + beige cardigan** (earthy) | 멘토 아주머니, fermented/집밥 |
| `seoyeon` | Seoyeon | **긴 생머리** 어깨까지 + 앞머리 | **cream/oat turtleneck** (plum accent) | gold stud, 따뜻 집밥 homebody |
| `mother_01` | Mother | **round-bun** (흰머리 섞임) + apron strap | **warm coral** jeogori-실루엣 톱 | 담백 home-style, 자애 |
| `father_01` | Father | **salt-pepper 짧은머리**, 넓은 어깨 | **tan/camel** 단색 카디건 | 호방 bold, hearty |

### 1.1 구분 충돌 risk (driver에 강제한 분리)
- **Mrs Lee ↔ Mother** (둘 다 50s Korean 여성, top risk): Mrs Lee = permed wavy + glasses + mauve+beige / Mother = round-bun + **warm coral** + apron. driver `identity_prompt`에 CRITICAL 절로 명시.
- **Mina ↔ Seoyeon** (둘 다 젊은 여성): Mina = side ponytail + yellow / Seoyeon = long straight + oat-cream. 머리형태 + 색 둘 다 분리.
- **Father ↔ Mrs Lee** (둘 다 salt-pepper): Father = 짧은 남성머리 + tan 단색 + 넓은 어깨 / Mrs Lee = permed wavy 여성 + glasses + mauve.
- **6명 dark-hair convention** vs **Riley honey-blonde**: Riley만 외국인 identity로 머리색 분리 = 의도된 design point.

### 1.2 Color uniqueness 분포 (한 화면 동시 등장해도 충돌 0)
warm-red(junho) / yellow(mina) / blue(riley) / mauve-beige(mrs_lee) / oat-cream(seoyeon) / coral(mother) / tan(father) — 7색 모두 분리. blue(riley) 1개로 cool accent 균형, 나머지는 warm 계열 내 hue/value 분리.

---

## 2. Production prompts (요약 — full prompt는 driver inline + prompts-library.md §5.16/§2.7)

### P1 character (7 neutral identity + 3 emotion delta)
- **STYLE_SUFFIX_CHARACTER** (28장 공통): bust-up 1:1 / storybook chibi 1:1.3~1.6 / **BG Cream #FBF3E4** (Cool Sage 폐기) / **Cocoa #3A2A1E outline 3-4px** (slim 2-3px 폐기) / soft 2-tone cel (base×0.85) / **warm peach blush #E89A7A** (cool pink 폐기) / muted 55-78% (Royal Match 80-90% 폐기) / dot eyes + 1 highlight + 작은 nose cue.
- **7 neutral identity_prompt**: §1 표의 silhouette+color anchor를 자연어로 lock (subject anchor 자연어 통일 = sref 대체).
- **3 emotion delta** (image edit, base = neutral, Style Bible §4.5 ★ mapping):
  - happy (good/★4): eye-crescent ^_^ + O smile + 1-2 gold sparkle.
  - excited (excellent/★5): GIANT crescent + WIDE open + 양손 raised + 2-3 sparkle (§8 subtle, NOT explosion).
  - disappointed (bad/★1): **lowered eyebrows HERO cue** + small ㅡ mouth + head tilt + 1 sweat-drop — **NOT crying/teardrop** (R-01/R-04 sad teardrop 명시 회피).

### P2 env (5)
- **STYLE_SUFFIX_ENV** (5장 공통): wide landscape / **3-band parallax-ready** (FG counter / MID props / BG warm-gray silhouette, 명도 분리 + Cocoa soft shadow, blur X) / warm wood Oak #D6A56B + Walnut #A6753F / Korean texture = 형태 (뚝배기/놋/onggi/소반/한지/기와) / 캐릭터 비포함.
- **L1~L5 격상**: L1 cream+oak 소박 → L2 분식집 철판+멜라민 → L3 시장 wood+onggi+기와 silhouette depth → L4 먹자골목 밤 warm lantern bokeh → L5 한정식 walnut+brass+한지 full depth.

### P3 UI (5 sheets)
- **STYLE_SUFFIX_UI**: transparent / matte warm fill (glossy X) / round corner (button 24 / card 28 / chip h/2) / Cocoa shadow @18-25% / gold-brass 절제 (ribbon만 sheen).
- card frame (9-slice) / panel frame (+말풍선 tail variant, 9-slice) / button family (primary Persimmon / secondary Gold·White / disabled) / ribbon family (gold-brass premium) / icon family (coin/heart/star/friendship/lock/settings).

### P4 VFX (5 sprites)
- **STYLE_SUFFIX_VFX**: transparent / subtle (§8) / warm tone only / semi-transparent soft edge / 확폭발·confetti·shake·neon 금지.
- steam (2-3 wisp 40-60% alpha) / sparkle (3-4 gold 4-point) / oil splash (4-6 droplet arc) / cooking glow (warm radial halo) / friendship gain (2-3 warm heart pop).

---

## 3. Style compliance review (각 priority가 Style Bible 어떻게 준수)

### P1 character → Style Bible §1·§2·§4
| Lock | 준수 |
|------|------|
| §1 공통 soft shading | soft 2-tone cel (base + base×0.85) — hyper-casual single-fill / Royal Match glossy 사이 |
| §1 공통 warm 팔레트 | §2 단일 팔레트, muted 55-78%, BG Cream bg |
| §1 공통 Cocoa outline | 3-4px #3A2A1E (순흑 X, 약간 hand-drawn) |
| §4.2 storybook chibi | 1:1.3~1.6 (hyper-casual 1:2보다 덜 과장), mitten hands |
| §4.3 face warmth | dot eyes + 1 highlight + 작은 nose + warm peach blush #E89A7A |
| §4.5 emotion sheet | 4 emotion = bad/okay/good/excellent ★ mapping, disappointed = subtle (NOT crying) |

### P2 env → Style Bible §6
| Lock | 준수 |
|------|------|
| §6.2 Travel Town depth | 3-band 명도 분리 + Cocoa soft shadow (blur X) = parallax-ready |
| §6.2 warm wood | Oak #D6A56B + Walnut #A6753F, grain 2-3 line만 (noise X) |
| §6.2 Korean texture=온기 | 뚝배기/놋/onggi/소반/한지/기와 = 형태 signal, scrapbook noise X |
| §6.2 BG 캐릭터 비포함 | empty environment, character는 Godot 레이어 |
| §6.1 L1→L5 격상 | 소박(cream+oak) → 고급(walnut+brass+한지) 단계 명확 |
| §6.2 천막 LOCK | single color + 1 accent, 이탈리아 빨강-녹색-흰색 금지 |

### P3 UI → Style Bible §7
| Lock | 준수 |
|------|------|
| §7.1 button | Persimmon CTA radius 24 + bottom bevel + Cocoa shadow, matte |
| §7.1 card/panel | radius 28/24, BG Warm White/Cream, Cocoa outline 3px |
| §7.1 premium frame | ribbon만 gold-brass sheen (남발 X) |
| §7.2 round corner | 직각 금지, 전 요소 round |
| §7.2 shadow | Cocoa @18-25% (순흑 X) |
| §7.3 cool mint UI 금지 | transparent + warm 팔레트만 |

### P4 VFX → Style Bible §8
| Lock | 준수 |
|------|------|
| §8 subtle premium | 화면 폭발/confetti/shake/neon 금지, 핵심 1-2 효과 |
| §8 warm tone | white/cream steam, gold sparkle, persimmon glow — cool-tone VFX 금지 |
| §8 steam signal | 2-3 wisp 반투명 = 한식 끓음 핵심 |

---

## 4. Before / After framing

### P1 — 기존 Cool Sage avatar → warm storybook
| 축 | BEFORE (`gen_guest_avatars.py`, assets-raw/guest_avatars_m1/) | AFTER (`gen_character_pack.py`, character_pack_m2/) |
|----|------|------|
| 배경 | Cool Sage #C8D5C0 | **BG Cream #FBF3E4** (warm) |
| outline | slim 2-3px warm dark #2D1D14 | **Cocoa 3-4px #3A2A1E** |
| 채도 | Royal Match saturated 80-90% | **muted warm 55-78%** (Animal Restaurant) |
| shading | flat single-fill / 1-layer cel | **soft volumetric 2-tone** (base×0.85) |
| 비율 | chibi 1:1.7 (hyper-casual) | **storybook chibi 1:1.3~1.6** |
| blush | light pink #FFCFCF (cool) | **warm peach #E89A7A @40%** |
| 톤 레퍼런스 | Royal Match + Subway Surfers | **Cooking Diary + Animal Restaurant** |
| 캐릭터 수 | 5 (친구/멘토만) | **7** (+ mother_01 / father_01 신규 bust) |

### P2 — 기존 storefront BG → L1-L5 cooking 환경
| 축 | BEFORE (BG-01~05, bg_anchors_m1/) | AFTER (L1~L5, environment_pack_m2/) |
|----|------|------|
| 목적 | 5 재료 가게 storefront (청과/정육/어물/곡물/양념) | **5 cooking 환경** (요리하는 backdrop) |
| 배경 | Cool Sage #C8D5C0 solid | **warm cream/wood + 3-band depth** |
| depth | 단일 storefront 평면 | **parallax-ready 3-layer** (Travel Town) |
| 진행 | 5 가게 (병렬) | **L1→L5 격상** (성장 = 환경 upgrade) |
| 톤 | Royal Match modern saturated | **warm cozy** (Oak/Walnut/brass) |

> BG-01~05는 폐기 아님 — 재료 선택 가게 화면용으로 별도 보존. L1~L5는 cooking backdrop으로 신규 역할.

---

## 5. main thread 실행 명령 (P1 character 먼저 — gate)

### Step 1 — P1 character pack (gate, 최우선)
```powershell
# (1) test 1장 (junho neutral) — 시각 확인 먼저
py tools/gen_character_pack.py --phase B --only junho --quality medium      # 1 × $0.042, ~30s

# (2) Phase B 7 neutral batch — 7 identity + silhouette 확인 + LOCK
py tools/gen_character_pack.py --phase B --quality medium                   # 7 × $0.042 ≈ $0.29, ~3min

# (3) Phase C 21 emotion (Phase B neutral 필수 prerequisite)
py tools/gen_character_pack.py --phase C --quality medium                   # 21 × $0.042 ≈ $0.88, ~7-9min

# 또는 전체 28 한 번에
py tools/gen_character_pack.py --phase ALL --quality medium                 # 28 × $0.042 ≈ $1.18, ~10-12min
```
> **권장 순서**: (1) test → 시각 OK → (2) Phase B 7장 → **silhouette test (흑백 축소 7명 구분) + Mrs Lee≠Mother 확인** → LOCK → (3) Phase C. Phase B가 anchor seed라 여기서 톤이 틀어지면 emotion 21장 전부 재생성 필요 → Phase B 게이트가 비용 절감 핵심.

### Step 2 — P2 environment pack
```powershell
py tools/gen_environment_pack.py --only L1 --quality medium                 # test 1장
py tools/gen_environment_pack.py --quality medium                          # 5 × $0.042 ≈ $0.21, ~3min
```

### Step 3 — P3 UI + P4 VFX
```powershell
py tools/gen_ui_vfx_pack.py --only ui_icon_family --quality medium          # test 1 sheet
py tools/gen_ui_vfx_pack.py --group ui --quality medium                     # 5 × $0.042 ≈ $0.21
py tools/gen_ui_vfx_pack.py --group vfx --quality medium                    # 5 × $0.042 ≈ $0.21
```

### Step 4 — post-process (rembg transparent, godot import)
- character/VFX/UI = `tools/strip_bg.py` 또는 rembg로 transparent (ADR-007 호환), 게임 size crop.
- character 240×240 또는 180×180, env는 1536-wide 유지, UI/VFX는 transparent 그대로.

---

## 6. 9-slice / procedural 권고 (UI frame)

> **결론: FRAME(card/panel/button)은 procedural(StyleBoxFlat) 우선, ICON+RIBBON은 art.**

| UI 요소 | 권고 | 근거 |
|---------|------|------|
| **card / panel / button frame** | **procedural (Godot StyleBoxFlat) 우선** — AI sheet는 visual spec/fallback | 단순 round-rect + 단색 fill + outline + shadow = StyleBoxFlat로 100% 재현. 장점: 어느 size에서도 crisp, 런타임 recolor, texture memory 0, AI resize artifact 없음. `corner_radius=24/28`, `bg_color`=warm fill, `border_width=3`+`border_color`=Cocoa, `shadow_color`=Cocoa@18-25%+`shadow_size`. → godot-dev에 StyleBoxFlat 값 전달이 9-slice PNG보다 우월. |
| (대안) 9-slice PNG | frame을 art로 쓸 경우 **9-slice/NinePatch 친화** 생성 (모서리 crisp + 가운데 stretch) | driver prompt에 "9-SLICE FRIENDLY" 명시함. StyleBoxFlat로 표현 안 되는 장식 프레임(텍스처 결, 손그림 outline 질감)을 원할 때만 PNG. |
| **icon family** | **art (AI 생성) 권장** | coin/heart/star/friendship/lock/settings = 유기적 pictogram, procedural 어려움. transparent PNG sprite로 생성 후 import. |
| **ribbon family** | **art (AI 생성) 권장** | folded ribbon/rosette/gold-brass sheen = 곡선+그라데이션, procedural 비효율. premium 장식이라 art가 적합. |

> **요약**: 프레임은 procedural이 art보다 낫다 (crisp + recolor + 메모리). 아이콘/리본은 art가 낫다. driver는 양쪽 다 만들 수 있게 frame sheet도 생성하되(visual spec/fallback), **godot-dev에는 frame=StyleBoxFlat, icon/ribbon=texture 권고**.

---

## 7. 비용 / 시간 estimate

| Pack | 수량 | unit (medium) | 비용 | 시간 (생성) |
|------|-----|---------------|------|-----------|
| P1 character (B 7 + C 21) | 28 | $0.042 | **~$1.18** | ~10-12 min |
| P2 environment | 5 | $0.042 | **~$0.21** | ~3 min |
| P3 UI sheets | 5 | $0.042 | **~$0.21** | ~3 min |
| P4 VFX sprites | 5 | $0.042 | **~$0.21** | ~3 min |
| **소계 (1-pass)** | **43** | | **~$1.81** | **~20 min** |
| reroll 버퍼 (×1.5, ChatGPT 약점 reroll) | +22 | $0.042 | +$0.92 | +10 min |
| **현실 estimate (reroll 포함)** | **~65 gen** | | **~$2.7** | **~30 min 생성 + 검수/post-process 별도** |

- post-process(rembg/crop) + 검수(silhouette test, Hero Screenshot Test) = 별도 0.5~1일 작업.
- high quality($0.167) 사용 시 ×4 비용 (~$7.2). **medium 권장** (anchor 톤 확인 충분), Hero/store 노출용만 high.

### 7.1 ChatGPT 약점 reroll risk top (driver에 negative로 강제했으나 잔존)
- **P1**: Mrs Lee↔Mother confused ~30% / disappointed→crying 누수 ~25% / excited→Royal Match explosion 또는 Looney Tunes 누수 ~25% / mina→anime girl 누수 ~30% / 6 char→Western cartoon 누수 ~35% (Riley 제외).
- **P2**: Cool Sage/cool-mint 잔재 누수 / 천막→이탈리아 stripe 누수 / depth band 안 살고 평면화 / 일본·중국 건축 누수.
- **P3/P4**: transparent 대신 solid bg / glossy 누수 / VFX 과폭발(confetti) / text 베이킹.
- 누수 시 follow-up: "배경을 cool sage/mint 대신 warm cream #FBF3E4, Animal Restaurant cozy 톤으로 다시" 형식 자연어 reroll (sref 대체).

---

## 8. 검수 게이트
- **P1 silhouette test** (Style Bible §4.1): Phase B 7 neutral을 흑백 축소 → 7명 구분 PASS. Mrs Lee≠Mother 필수.
- **P1 emotion gradient**: 4 emotion이 bad<okay<good<excellent로 명확 (disappointed=subtle, NOT crying).
- **P1 family IP consistency**: 같은 캐릭터 4 emotion이 hair/outfit/proportion 동일.
- **전체 Hero Screenshot Test** (§9.2): L1~L5 backdrop + 음식 + 캐릭터 합성 시 6+/7 (HT4 한식 + HT7 일관성 필수).
- **cross-cultural 누수 0건**: 일본/중국/Western(Riley 제외) 누수 reject.
