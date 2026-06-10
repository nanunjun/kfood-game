# Ingredient & Tool Art LOCK — Hero Asset Mandate

> 버전: **v1.0 (2026-06-06) — INGREDIENT/TOOL HERO ART LOCK**
> 작성: art-director
> 상위 지시 (사용자 LOCK): *"Ingredients and tools are NOT UI icons. They are hero art assets."*
> 성격: **Style Bible v1 §5 (Food) 의 ingredient/tool 확장 addendum** — gameplay/CSV/systems 미변경, art production spec only.
> Supersede: `gen_ingredient_anchors_m1.py` / `gen_ingredient_cut_anchors_m1.py` / `gen_tool_anchors_m1.py` 의 "Cool Sage bg + simple geometric flat fill + slim outline + Cookingo flat clean" 방향 (= flat-ish UI-icon 톤, 본 LOCK 으로 무효화).
> 정합 reference: Style Bible v1 §1·§2·§5, Hero benchmark `assets-raw/hero/cooking_hero_ramen_v1.png`.
> 짝 문서: `docs/art/asset-architecture-lock.md` — 본 문서는 **품질**(volume/lighting/texture/depth, NOT UI icon), 아키텍처 lock 은 **분리**(5-layer, NEVER merge ingredient+tool). 둘 다 통과해야 production PASS.

---

## 0. 왜 이 LOCK 인가 — 현 ingredient/tool 의 flat-ish bug

| 클러스터 | 현 상태 (BEFORE) | 문제 |
|---------|-----------------|------|
| `ingredient_anchors_m1` | Cool Sage bg + 도마/칼 scene + slim 2-3px outline + single fill | 재료가 **scene 안에 묻힘** (hero 아님), flat-ish, cool 톤 |
| `cut_anchors_m1` / `ingredient_cut_anchors_m1` | 도마 위 cut 결과 + Cool Sage bg | 위와 동일 — 도마가 hero 를 가림, UI infographic 느낌 |
| `tool_anchors_m1` | white/sage bg + "simple geometric flat fill" + slim cel shading 1단 | **clip-art UI icon** 느낌 (특히 pot/ladle/spatula), volume/texture/depth 부재, 한식 정체성 약함 |

> **핵심 진단**: 기존 도구 prompt 가 명시적으로 `simple geometric flat fill shapes`, `Cookingo flat clean`, `slim outline 2-3px`, `single color fill` 를 강제 → 결과가 **UI 아이콘**. 사용자 mandate = **Cooking Diary / Travel Town / Merge Mansion item quality** (volume / lighting / texture / depth). 두 방향은 양립 불가. 본 LOCK 이 flat 방향을 폐기하고 volumetric hero 로 전환.

---

## 1. 사용자 LOCKED Mandate (verbatim — 절대 규칙)

> **"Ingredients and tools are NOT UI icons. They are hero art assets.**
> **Never use: flat vectors / color blocks / geometric shapes / symbolic placeholders / infographic-style / simplified UI icons.**
> **Every ingredient must be recognizable without text. Every tool must be recognizable without text.**
> **Target quality: Cooking Diary / Travel Town / Merge Mansion item quality.**
> **All tools illustrated with: volume / lighting / texture / depth. No vector icon style. If an asset looks like a UI icon, reject it.**
> **Hero Asset Test: if the ingredient is shown alone, the player should immediately identify it. No text."**

---

## 2. DO / DON'T (hero art vs UI icon)

### 2.1 절대 금지 (= 즉시 REJECT)

- `flat vector` / `flat single-color fill` / `flat icon` / `vector clipart`
- `color block` / `geometric shape` / `symbolic placeholder` / `pictogram` / `glyph`
- `infographic style` / `instructional diagram` / `recipe-card icon` / `app icon`
- `simplified UI icon` / `sticker` / `emoji` / `silhouette`
- `slim uniform outline` 만 의존하는 평면 (outline 으로 형태만 그린 flat)
- 단일 cel-shade 1단으로 끝나는 평면 (volume 없는 flat)
- Cool Sage / mint / teal 배경 (Style Bible v1 §2 무효화)

### 2.2 필수 (= hero asset PASS 조건)

| 요소 | hero art DO | UI icon DON'T |
|------|------------|---------------|
| **Volume** | 둥근 입체 form, 3/4 view 로 두께·깊이 표현, 음영으로 부피감 | flat 평면, 두께 없는 실루엣 |
| **Lighting** | top-left key light + soft rim/ambient, 1~2개 specular 윤기 | 균일 무광 fill, 광원 없음 |
| **Texture** | 재료 표면 질감 (파의 결, 당근 단면 결, 김치 잎맥, 무쇠/놋쇠 결, 우드 grain) | 매끈한 단색 fill, 질감 0 |
| **Depth** | soft contact shadow, 전/후 레이어, ambient occlusion 느낌 | 평면 위 떠 있는 아이콘 |
| **Outline** | warm Cocoa `#3A2A1E` 3~4px (약간 두께 변화 = hand-drawn 온기) | 차가운 균일 vector stroke |
| **Palette** | Style Bible v1 §2 warm cozy (food warm tone + cream/wood) | neon / 80~90% 폭주 채도 / cool 톤 |
| **Identity** | 한식 정체성 (대파/김치/뚝배기/석쇠/놋수저 형태로) | 일반 generic / 일·중 누수 / 무국적 |

### 2.3 BEFORE → AFTER (구체)

| asset | BEFORE (flat-ish, REJECT) | AFTER (volumetric hero, LOCK) |
|-------|--------------------------|------------------------------|
| 대파 whole | Cool Sage bg + 도마+칼 scene, slim outline, 떠 있는 flat 파 | Cream bg, 파 단독 hero, 흰뿌리→초록잎 gradient + 결 texture, cocoa outline, soft contact shadow |
| 뚝배기 X 양은냄비 | white bg, flat 단색 silver, 매끈 무광, **clip-art UI 아이콘** | warm charcoal 뚝배기(dolsot) earthenware texture, top-left 광택 1점, 두꺼운 입체 벽, cream bg, cocoa outline |
| 김치 | flat 빨강 블록, 잎맥 없음 | 속 채워진 입체 포기, 잎맥 결 texture, 양념 윤기 specular, 깊이 음영 |

---

## 3. Hero Asset Test (rubric — REJECT 기준)

> 단독(背景 없이 1개)으로 3초 노출 → 다음 전부 PASS 해야 LOCK. **하나라도 FAIL = REJECT & reroll/follow-up.**

| # | 항목 | PASS 기준 | FAIL = REJECT |
|---|------|-----------|---------------|
| **HA1** | **즉시 식별 (no text)** | 텍스트 없이 단독으로 "대파/당근/김치/뚝배기/석쇠" 등 3초 내 식별 | 무엇인지 모호 / 텍스트 라벨 의존 |
| **HA2** | **Volume** | 둥근 입체 + 3/4 두께·깊이 보임 | flat 평면 / 실루엣 |
| **HA3** | **Lighting** | top-left key + soft shadow + specular 1~2점 | 균일 무광 / 광원 부재 |
| **HA4** | **Texture** | 표면 질감 (재료 결 / 금속·우드 grain) 보임 | 매끈 단색 fill / 질감 0 |
| **HA5** | **Depth** | soft contact shadow + 레이어 깊이 | 평면 위 떠 있는 아이콘 |
| **HA6** | **NOT UI icon** | hero illustration 으로 보임 | **flat vector / color block / geometric / infographic / app-icon 느낌 → 즉시 REJECT** |
| **HA7** | **Style Bible 톤** | warm cozy palette + cocoa outline + 한식 정체성 | cool/mint bg / neon / 무국적 / 일·중 누수 |

**LOCK 조건: HA1~HA7 전원 PASS (HA1 식별 + HA6 NOT-UI-icon 은 절대 필수).**
> HA6 단독 FAIL("UI 아이콘 같다") 하나만으로도 reject — 사용자 mandate 의 "If an asset looks like a UI icon, reject it."

---

## 4. 생성 톤 규약 (Style Bible v1 정합)

- **bg**: `BG Cream #FBF3E4` (또는 gpt-image-1 `background=transparent`). Cool Sage/mint 금지.
- **outline**: `Cocoa #3A2A1E` 3~4px, hand-drawn 온기 (균일 vector stroke 금지).
- **shading**: soft 2~3단 gradient + top-left key light + soft rim. specular 1~2점 (재료 윤기/금속 sheen). 단, Royal Match glossy plastic 폭주 금지 — "갓 손질/조리된" 따뜻한 윤기 만큼.
- **palette**: Style Bible v1 §2 — food warm tone (Persimmon/Gochu Red/Sesame Leaf/Egg Yolk/Grill Brown), 한식 시그널(Dolsot Charcoal/Brass), cream/oak/walnut.
- **single hero per image**: 재료 1종 / 도구 1개 단독. scene/도마/손/캐릭터/다른 도구 없음 (cut variant 도 도마 scene 제거 — cut 결과 그 자체가 hero).
- **view**: 재료 3/4 또는 살짝 top-down, 도구 3/4 (form+volume+functional surface). 평면 도구(석쇠/김발)는 살짝 tilted top-down.
- **한식 정체성**: 뚝배기(Dolsot Charcoal earthenware) / 석쇠(round wire grate) / 놋(brass) / 양은(warm metallic, but NOT flat clip-art).
