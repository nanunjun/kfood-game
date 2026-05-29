# Art Style Guide — K-Food Master MVP

> 버전: **v1.2 (2026-05-27, modern mobile casual reset) — supersedes v1.1**
> 작성자: art-director
> 상위 문서: [`decisions.md` ADR-003 §MVP Scope](decisions.md#adr-003-mvp-first-전환--34개월-출시--점진-확대-supersedes-adr-002), [`decisions.md` ADR-005](decisions.md#adr-005), [`art-workload-estimate.md` v4.1](art-workload-estimate.md), [`systems/cooking-mechanics.md` v0.5 §2·§X](systems/cooking-mechanics.md), [`systems/mvp-food-selection.md` v2.1](systems/mvp-food-selection.md)
> 실행 키트·평가 rubric: [`ai-session-kit.md`](ai-session-kit.md) v1.2, [`art-anchor-rubric.md`](art-anchor-rubric.md) v1.2
> 본 문서 범위: MVP (Tier 1~2, 친구 양친 2명, 식탁 2종, 다점포 5가게, ADR-005 칼/도마 cut style 6종)
> 사운드 가이드는 별도(`docs/systems/sound-guide.md`, M2~M3에 신설).

> **v1.2 변경 (2026-05-27, modern mobile casual reset)**: iter2 (A-V3_iter2.png, B-V3_iter2.png) 결과 사용자 진단 — "전반적으로 올드해 보임". 3가지 critique: (1) 베이지/크림 배경 = scrapbook/storybook 톤 → 모바일 UI mismatch, (2) 절구(mortar) 도구 = 한식 전통이지만 cooking 메커니즘 직접 매핑 X (시각 misleading), (3) Cookie Run Kingdom (2021) baseline은 warmth는 잡으나 현대 모바일 casual 톤 부족. **v1.2 핵심 shift**: §1 톤 한 줄 정의 = **Royal Match (Dream Games 2021) clean modern saturated + Subway Surfers chibi energy + 한국 재래시장 K-touch** 로 재작성 (Cookie Run/Subway-Surfers-only/Crossy-Road 모두 superseded). §2 캐릭터 chibi 1:1.5~2 + bowl-cut + mitten 비율 lock 유지, cheek blush soft-pink tone-down + dynamic/energetic pose 강조 추가. §3 환경 5가게 시그니처 컬러 유지, **"재래시장 손맛" texture/scrapbook 톤 제거** → modern flat clean. §5 도구 가이드 **재작성** — 절구 회피 LOCK, cooking-mechanics §2A 정합 4종 도구만 (프라이팬+spatula 9/12, 냄비+국자 4/12, 도마+칼 ADR-005 전체, 김밥말이 김밥 특수). §6 컬러 채도 70~78% → **80~90%** 상승, cool tone 1~2 추가 (현재 warm-heavy 보정). §7 배경 가이드 **재작성** — 베이지/크림 회피 LOCK, **solid saturated cool tone (soft mint/pastel teal/cool sage) 1순위 권고**. §9 게이트 G_new 신설 = modern mobile casual 인상 평가 항목. §11 ADR-002 §#5 정합성 판정 = **A (category 안 modern reference shift, ADR amendment 불필요)** — pm sign-off 영역에 flag.

> **v1.1 변경 (2026-05-27)** (archived in v1.1): art 도구를 Midjourney → **ChatGPT (GPT-4o image / DALL-E)로 영구 변경**. 자연어 prompt + "Important: avoid ..." negative + 대화형 reroll로 통일. §7 약점 회피를 MJ 약점 10항 → **ChatGPT 약점 10항**으로 재정의.

> **v1.0 reset 배경 (2026-05-27)** (archived): Subway Surfers / Crossy Road / Stack 계열 하이퍼캐주얼 flat. v1.2에서 modern mobile casual로 shift (Crossy Road geometric 단순성은 의도적으로 일부 후퇴, modernity 우선).

---

## 1. 한 줄 정의

> **"Royal Match (Dream Games 2021) clean modern saturated palette + Subway Surfers chibi energy + 한국 재래시장 K-touch."**
> 모바일 small screen에서 **현대 mobile casual 톤**으로 한식 cooking matching을 표현. 베이지/scrapbook/storybook 톤 완전 회피, **clean saturated palette + dynamic chibi action + cool tone bg**로 modernity 우선. 디테일은 의도적으로 최소화하되 Crossy Road 수준 geometric 단순성에서는 일부 후퇴 (캐릭터 expressive pose + 음식 식욕 표현 필요). 정체성 3요소: **clean saturated palette + dynamic chibi pose + bold outline (slim 2~3px)**.

### 1.1 레퍼런스 좌표 (v1.2 사용자 critique 반영 reset)

| 레퍼런스 | 차용 요소 | 차용 안 함 |
|---------|----------|-----------|
| **Royal Match (Dream Games, 2021)** [PRIMARY] | clean modern saturated palette (teal/coral/mint cool-warm 균형), character-driven warmth, soft modern gradient bg, slim bold outline 2~3px, modern mobile casual UI 친화, juicy shape language | King-style raid puzzle UI 자체, monarchy/castle 테마, narrative cutscene |
| **Subway Surfers** [SECONDARY, character action only] | chibi head-heavy 비율 (1:1.5~2), dynamic energetic pose, mitten 손, 점 눈/호 입, 친근 mascot 톤 | 도시 그래피티 톤, hover-board, flat-only 단순성 (우리는 expressive pose + 약간의 shading 허용) |
| **Cooking Madness** (참고 only) | cooking 장르 톤 reference (음식 식욕 표현, 키친 환경 친근감) | 과채도 cartoony 톤, over-cluttered UI |
| **회피 reference** (v1.2 명시 reject) | — | **Cookie Run Kingdom 2021** (warmth는 살지만 올드함), **Toon Blast** (over-saturated cartoony), **Crossy Road / Stack / Voodoo flat-only** (V2에서 사용자 reject), **Toca Boca** (V4에서 사용자 reaction 미흡), **베이지/scrapbook/storybook 톤 일체** |

### 1.2 핵심 형용사 (style words — ChatGPT 자연어 prompt 투입용)

**채택**: `modern mobile casual game art`, `clean 2D illustration`, `Royal Match style`, `Dream Games aesthetic`, `vibrant saturated colors`, `juicy cartoon shapes`, `chibi mascot`, `dynamic energetic pose`, `cool tone background`, `soft mint`, `pastel teal`, `cool sage`, `slim bold outline 2-3px`, `single color fill with soft shading`, `Korean K-food`, `Korean traditional market modern interpretation`

**금지** (prompt의 "Important: avoid ..." 절에 명시): `beige background`, `cream paper background`, `scrapbook`, `storybook`, `kraft paper`, `vintage texture`, `Cookie Run`, `Cookie Run Kingdom`, `Toca Boca`, `realistic`, `photorealistic`, `hyperdetailed`, `texture noise`, `painterly`, `hand-painted`, `watercolor`, `3D render`, `octane`, `unreal`, `anime girl`, `manga`, `cinematic`, `gritty`, `gradient mesh`, `Italian flag awning`, `red-green-white stripes`, `mortar and pestle`, `traditional mortar`, `Cookie Run frosting style`

> ChatGPT default로 베이지/painterly/storybook 톤을 추가하려 함 → `modern mobile casual game art, clean saturated, cool tone background, NO beige, NO scrapbook` 본문 + "Important: avoid beige background, cream paper, scrapbook, storybook" 양쪽에 강제. modernity는 안 잡힐 때 follow-up "이 이미지를 더 modern Royal Match style 톤으로 다시 그려줘, 베이지 배경을 cool mint로 교체"로 재유도.

> ChatGPT는 내부 모델 선택 param 없음 (자동). default로 painterly/digital painting/3D render 톤을 추가하려 함 → `flat 2D illustration, single color fill, NO texture, NO photorealistic`을 prompt 본문 + "Important: avoid ..." 양쪽에 강제. anime girl 누수 위험은 ChatGPT가 MJ niji 6보다 낮으나 여전히 negative 명시 필수.

### 1.3 K-touch 체크리스트 (모든 자산 만족)

- [ ] **음식 인지성**: 단순화해도 음식임을 0.5초 안에 식별 (라면 = 둥근 그릇 + 노란 면 wave + 빨간 국물 / 김밥 = 검정 cylinder + 컬러 dot section / 떡볶이 = 빨간 사각 block + 흰 떡 cylinder)
- [ ] **가게 시그니처 컬러 1개**: 5가게는 한 컬러로만 식별 (청과 green / 정육 red / 어물 blue / 곡물 tan / 잡화 brown)
- [ ] **한식 정체성**: 일본·중국 표현 누수 차단 (옹기 = 한국 onggi, 한복 = 단순 jeogori 실루엣, 시장 = Namdaemun modern interpretation)
- [ ] **간판/텍스트**: ChatGPT는 한글 텍스트 거의 100% 깨짐. anchor 단계에서는 "solid block placeholder"로만 — 모든 텍스트는 후보정 (Photoshop / 게임 엔진 UI overlay)
- [ ] **modernity self-check (v1.2 신설)**: 디테일 추가하고 싶을 때마다 "Royal Match 옆에 두면 어색하지 않은가?"로 self-check. 베이지/scrapbook/storybook 톤이 보이면 즉시 reroll.
- [ ] **베이지/scrapbook 회피 (v1.2 LOCK)**: 배경에 beige/cream/kraft paper/vintage texture가 있으면 즉시 FAIL. cool tone solid 또는 cream-white(#fafafa) 외에는 사용 금지.

---

## 2. 캐릭터 디자인 룰

### 2.1 비율 (v1.2 lock, iter1/iter2 학습 보존)

- **머리 : 몸 = 1 : 1.5 ~ 2.0** (head-heavy chibi 유지 — Subway Surfers Jake 비례)
- 머리 폭 ≈ 어깨 폭 ×1.2~1.3
- 손/발: **mitten 또는 nub** (손가락 없음) — ChatGPT 손가락 약점 자동 회피
- 키: 어머니 1.0, 아버지 1.05, 주인공 0.9 (참고용)
- **머리 스타일 LOCK (v1.2 iter1/iter2 학습 보존)**: 주인공 = **bowl-cut hair** (검정 단색 둥근 helmet shape). 어머니 = 둥근 bun, 아버지 = salt-and-pepper short hair.

### 2.2 얼굴 features (modern mobile casual emoji 수준, v1.2 tone-down)

- **눈**: 단순 검정 **점** 2개 (또는 짧은 호) — 흰자/홍채/속눈썹/하이라이트 모두 X. Royal Match 캐릭터 눈 톤 reference.
- **입**: 단순 **호 1줄** (웃음) 또는 **짧은 직선** (중립) — vertices 3개 이하. ★3 Happy reaction은 O-shape mouth 허용.
- **코**: **생략** (디테일 폭주 트리거 회피)
- **볼터치 (v1.2 tone-down)**: **light pink** (Accent Pink Blush `#FFCFCF` — 기존 `#FFB6B6`보다 ~15% 밝게), 선택적. Cookie Run 진한 분홍 회피. 없어도 PASS.
- **시점**: 3/4 또는 정면 모두 허용. base anchor는 **3/4 + dynamic action pose** 권장 (v1.2 iter1/iter2 학습 보존).

### 2.3 pose / expression (v1.2 신설 — dynamic + energetic 강조)

- **base pose**: 정적 standing → **dynamic action pose**로 lock (iter1/iter2 사용자 평가 best). 예: 주인공이 **프라이팬을 들고 spatula로 stirring하는 dynamic motion** (한 발 앞으로, 몸 기울임, motion line 1~2 streak).
- **expression**: friendly + slightly excited (modern mobile casual mascot 톤). 절구 stirring 대신 **프라이팬 + spatula stirring** 또는 **냄비 + 국자 ladling**.
- motion line: black ink streak 1~2개 (motion 강조 modern casual 시그니처). Cookie Run 두꺼운 sparkle 회피.

### 2.4 의상 (single color block + slim bold outline, v1.2 sync)

- **주인공**: 단색 후드/티셔츠 1개 + 단색 앞치마 1개 (총 2 컬러 block). 앞치마 = beige가 아닌 **white/soft mint/coral** 중 선택 (v1.2 베이지 회피).
- **어머니**: 단순화한 jeogori **실루엣** (V-collar shape만, 자수/디테일 X) + 단색 바지/치마. 컬러 2~3 block.
- **아버지**: 단색 카디건 + 단색 셔츠. 컬러 2 block.
- **모든 의상**: §6 컬러 팔레트에서만 선택. 패턴/무늬 0.

### 2.5 outline / shadow / shading (v1.2 modern soft shading 1단 허용)

- **외곽 라인**: **2~3 px** (1024px canvas 기준, v1.1 2~4px → 2~3px slim화 — Royal Match modern slim outline sync), **Soy Dark `#2D1D14`**. 순흑은 회피 (modernity 위해 약간 warm dark).
- **내부 라인**: 외곽과 동일 두께 또는 약간 얇게 (의상 분리선만)
- **shadow**: 캐릭터 발밑 **단일 톤 ambient ellipse** 1개 (#000 25~30% alpha)
- **shading (v1.2 신설)**: 의상/얼굴에 **soft 1-layer cel shading 1단 허용** (base color × 0.85 multiply, 하단 1/3). Royal Match modern juicy 톤 sync. 다층 cel-shading 금지.
- **highlight**: 음식 + 의상 highlight 1점 허용 (modern juicy 톤). 캐릭터 얼굴/머리에는 X.

### 2.6 표정 시트 (reaction anchor용)

각 캐릭터는 2~3 표정만 anchor lock:
1. **Neutral** (대기 — Scene 1·2 idle, dynamic action pose 유지)
2. **Happy** (★3 reaction — 호 입을 더 크게 / O-shape mouth 허용 + 눈 호로 변경 + light pink 볼)
3. **Subtle** (★1·★2 공통 — 작은 호 입, 눈은 그대로)

> modern casual 톤에서 표정 = **features 형태 변화 + 색 변화 + slight pose**로 표현.
> **U-2 sync**: 어머니/아버지 L11 동시 unlock. base anchor(CH-02, CH-03)는 본 sprint에서 lock, reaction 6컷(어머니 ★1/2/3 + 아버지 ★1/2/3)은 후속 sprint(M1 초). 모든 reaction prompt에 "Important: avoid sleeping, eyes closed peaceful" 필수.

---

## 3. 환경 디자인 룰

### 3.1 시점·구도

- **Scene 1 입구**: 정면 또는 살짝 3/4, 화면 하단 1/3에 좌판(단순 사각 block), 상단 2/3에 천막 + 간판 (단색 block)
- **Scene 1 가게 내부**: 정면 매대 (flat 톤은 perspective 최소화 — 옆에서 본 sliced view 권장)
- **Scene 2 키친**: 정면 카운터 + 가스레인지/도마가 화면 중앙 (큰 block으로 처리)
- **Scene 3 식탁**: top-down 또는 7/8 (top-down이 flat 톤에 가장 자연스럽다 — 상차림 시인성 + 음식 실루엣 명확)

### 3.2 조명·shadow (v1.2 modern soft shading)

- 조명: 단일 톤 ambient + **soft 1-layer cel shading** (의상/소품에 base × 0.85 multiply 하단 1/3). Royal Match modern juicy 톤.
- 그림자: 캐릭터/큰 오브젝트 발밑 **단일 ellipse** (선택)
- 하늘: **cool tone solid 권고 (soft mint / pastel teal / cool sage)** — v1.2 §7 lock. 베이지/크림 회피.

### 3.3 소품 밀도 (의도적 최소화 + modern clean — v1.2 손맛 텍스처 제거)

- **가게당 시그니처 아이콘 1~2개만** (청과 = 양배추 + 사과 / 정육 = 빨간 등 + 도마 / 어물 = 물고기 1마리 + 얼음 / 곡물 = 마대 + 됫박 / 잡화 = 옹기 항아리)
- **재래시장 "손맛" texture 제거 LOCK (v1.2)**: 종이 거친 texture / 나무 grain 과다 / scrapbook 느낌 모두 회피 → modern flat clean.
- 배경 후경 (옆가게, 행인): **블러 X — 단색 실루엣**으로 분리
- **BG에 인물 비포함 LOCK (v1.2 iter1/iter2 학습 보존)**: 가게 = 빈 storefront. 손님/주인 캐릭터 모두 X. 캐릭터는 Godot 레이어 합성.
- 천막(awning) 패턴: **이탈리아 국기 회피 LOCK** (빨강-녹색-흰색 stripe 조합 금지 — iter1/iter2 학습 보존). 추천: 단색 + accent 1색 (예: cabbage green 단색 + cool sage trim).

### 3.4 5가게 시각 카탈로그 (v1.2 awning 색 조정 + modern flat clean)

| 가게 | 시그니처 컬러 | 핵심 shape 1~2개 | awning 색 (v1.2 이탈리아 회피) |
|------|-------------|-----------------|------------------------------|
| 🥬 청과상 | Cabbage Green `#5FB868` | 둥근 양배추 + 빨간 사과 | green solid + cool sage trim (red-green-white 금지) |
| 🥩 정육점 | Gochu Red `#E94F4F` | 빨간 등불 + 갈색 도마 | red solid + warm white trim |
| 🐟 어물전 | Sea Blue `#3E9BD6` | 단순 물고기 실루엣 + 흰 얼음 block | blue solid + soft mint trim |
| 🌾 곡물상 | Grain Tan `#D8A86A` | 마대 자루 + 누런 곡물 무더기 | tan solid + warm brown trim |
| 🫙 잡화점 | Jang Brown `#7A5238` | 옹기 항아리 | warm brown solid + cream trim |

---

## 4. 음식 가이드 (Final 12 — mvp-food-selection v2.1, v1.3 prompts-library §5.2 sync)

> 음식 12개 anchor prompts는 M1 sprint([`prompts-library.md` v1.3 §5.2](prompts-library.md)). 본 §4는 톤 가이드.

### 4.1 음식 카드 공통 룰 (v1.3 베이지 회피 sync)

- **카드 비율**: 1:1 (512×512)
- **배경**: **Cool Sage `#C8D5C0`** (1순위) 또는 **Cream-white `#FAFAFA`** (보조) — v1.3 베이지 `#FAEFD8` deprecated (베이지 회피 LOCK sync §7). 종이 텍스처 X.
- **시점**: top-down 또는 7/8 top-down (음식 실루엣 명확)
- **shadow**: 카드 하단 단일 ambient ellipse 1개 (#000 ~25% alpha)
- **outline**: 2~3px Soy Dark `#2D1D14` (warm dark, slim)
- **specular highlight**: 음식 표면 1점만 허용 (juicy 표현 — modern flat이라도 음식 식욕은 중요)
- **그릇/접시**: **white baekja 흰색** 또는 **pale celadon `#E8F0E8` 연회색** + bold outline. 무늬 X. 검정 일본식 donburi/ramen bowl 회피.

### 4.2 12 음식 단순화 가이드

| # | 음식 | flat 실루엣 (목표) |
|---|------|-------------------|
| 1 | 떡볶이 | 빨간 사각 block(소스) + 흰 떡 cylinder 3~4개 |
| 2 | 김밥 | 검정 cylinder + 단면에 컬러 dot 4~5개 (노랑/주황/녹색/빨강) |
| 3 | 라면 | 흰 둥근 그릇 + 노란 면 wave + 빨간 국물 + 계란 노른자 1점 |
| 4 | 한국식 콘도그 | 갈색 막대 + 모짜렐라 stretch line 1~2줄 + 빨간 케첩 zigzag |
| 5 | 호떡 | 갈색 둥근 disc + 흑설탕 dark dot 중앙 |
| 6 | 해물파전 | 둥근 disc + 녹색 파 줄 + 새우 1마리 + 오징어 ring 1개 |
| 7 | 김치볶음밥 | 둥근 mound + 빨강·노랑·녹색 dot 혼합 + 계란 노른자 1점 |
| 8 | 비빔밥 | 둥근 그릇 + 5~6 컬러 section (방사형) + 중앙 노른자 1점 |
| 9 | 갈비구이 | 갈색 고기 block + 그릴 grain line 2~3 + 흰 뼈 단순화 |
| 10 | 김치찌개 | 검정 뚝배기 + 빨간 국물 + 흰 두부 block 2개 |
| 11 | 잡채 | 갈색 면 swirl + 컬러 채소 dot 5~6 |
| 12 | 순두부찌개 | 검정 뚝배기 + 빨간 국물 + 흰 순두부 mound + 노른자 1점 |

> 모든 음식 = **그릇 1 shape + 메인 2~4 element + accent dot 1~3** 구조로 분해.

---

## 5. 도구 가이드 (v1.2 재작성 — cooking-mechanics 직접 매핑, 절구 회피 LOCK)

> v1.2 핵심 shift: iter2 사용자 critique — 절구(mortar)는 한식 전통이지만 **cooking-mechanics §2A rhythm tap (Stage 2A 재료 준비, ADR-005)** 직접 매핑 X → 비주얼 misleading. 도구 시각은 게임 메커니즘과 1:1 정합.
> v1.2 도구 시각 톤: **modern flat clean + colored saturated metallic 또는 clean enameled** (전통 brown wood with grain 회피).

### 5.1 음식 12 → 도구 매핑 (v1.2 신설, cooking-mechanics §2 sync)

| 도구 | 적용 음식 (12 중) | 비중 |
|------|-----------------|------|
| **프라이팬 + spatula** | 떡볶이, 김치볶음밥, 제육볶음(=잡채?), 콘도그, 호떡, 김치전(=해물파전?), 해물파전, 잡채, 갈비구이 | **9/12** |
| **냄비 + 국자** | 김치찌개, 순두부찌개, 라면, 떡국(=N/A, 12 외) | 4/12 (떡국 미포함 시 3/12 — 김치찌개/순두부찌개/라면) |
| **도마 + 칼** | ADR-005 Stage 2A 모든 음식 (hero ingredient 1~2개) | 전체 (Stage 2A) |
| **김밥말이 (bamboo mat)** | 김밥 (특수) | 1/12 |
| **절구 (mortar) — LOCK 회피** | 없음 (v1.2 사용자 critique) | 0/12 |

> Tier 2 비빔밥은 도마+칼 (Stage 2A)만 노출. 메인 cook은 그릇 mixing — 도구 표현은 도마+칼 + 큰 그릇으로 충분.

### 5.2 도구별 시각 가이드 (v1.2 modern flat, traditional wood grain 회피)

- **프라이팬 + spatula**: 검정 또는 dark teal **enameled metallic round pan** (handle brown wood OK, but body 단색 metallic). spatula = soft mint or coral handle + gray flat blade. **전통 무쇠팬 dark grain 회피**.
- **냄비 + 국자**: clean enameled white 또는 cream **stockpot** + 단색 handle. 국자 = wood handle + metallic bowl. **유기/놋쇠 traditional 회피**.
- **도마 + 칼** (ADR-005 §5.3): clean modern board (soft cream solid 또는 cool sage solid) + slim grain line 2~3개만. 칼 = modern chef knife silhouette. **두꺼운 traditional brown wood with heavy grain 회피**.
- **김밥말이**: bamboo mat 자연 색 + 단순 stripe pattern (modern flat 표현).
- **절구 (LOCK 회피)**: 모든 prompt에 "Important: avoid mortar and pestle, traditional Korean mortar, 절구" 강제. 사용자 critique 반영.

### 5.3 ADR-005 칼 / 도마 cut anim 가이드 (v1.2 modern 시각 톤 sync)

- **칼**: modern chef knife silhouette (gray blade + soft handle color). slim outline 2~3px.
- **도마**: clean rectangle (soft cream `#FAFAF5` 또는 cool sage `#C8D5C0` solid) + slim grain line 2~3개 (subtle, 거의 안 보이게). round corner.
- 위에서 본 top-down 시점 (rhythm tap UX에 자연스러움)

### 5.4 6종 cut style (frame 수 최소화, v1.2 무변경 from v1.1)

| Cut style | 결과 shape | Frame 수 |
|-----------|----------|----------|
| 다지기 (mince) | 작은 dot 다수 | 2 frame (whole → minced dots) |
| 채썰기 (julienne) | 가는 막대 다수 | 2 frame (whole → thin sticks) |
| 어슷썰기 (diagonal slice) | 평행사변형 slice 3~5 | 3 frame (whole → mid-cut → done) |
| 통썰기 (round slice) | 둥근 disc 3~5 | 2 frame (whole → round slices) |
| 송송썰기 (chop, 파류) | 짧은 segment 다수 | 2 frame (whole → small segments) |
| 깍둑썰기 (cube) | 작은 cube 다수 | 3 frame (whole → mid → cubes) |

> 평균 **2~3 frame/cut style** × 6 = **12~18 frame** total (mascot 톤 v3.1 18~24 frame 대비 -25~33%, v1.2 무변경)
> rhythm tap의 hit 순간 + after 상태만 표현하면 충분. mid-cut frame은 통썰기/어슷썰기/깍둑썰기 3종에만 추가.

### 5.5 ingredient cut variation

- 음식 12개 × hero ingredient 1~2개 → ~24 sprite
- "whole" + "cut" 2장만으로 충분 (v1.2 무변경)

---

## 6. 컬러 팔레트 (v1.2 재작성 — 채도 80~90% + cool tone 추가)

> v1.2 핵심 shift: 채도 70~78% (v1.1 표기 75~85%지만 실 anchor는 70~78%) → **80~90% 상승** (Royal Match modern vibrant saturated 톤 sync). **warm + cool 균형** (v1.1 warm-heavy 보정 — cool tone 2종 추가).
> 모바일 small screen 가독성 + modern mobile casual 인상 우선.

### 6.1 베이스 팔레트 (전 자산 공통, v1.2 채도 +12~15%p 상향 + cool tone 추가)

| 역할 | HEX (v1.2) | 이름 | 사용처 | 변경 |
|------|-----|------|--------|------|
| Primary Warm | `#FF8A1F` | Persimmon Vivid | CTA, 곶감, 단호박, 강조 | v1.1 `#FF9A3C` → 더 vivid |
| Primary Red | `#F23E3E` | Gochu Red Vivid | 김치/고추장/떡볶이, shake VFX, 정육 | v1.1 `#E94F4F` → 채도 +10%p |
| Secondary Green | `#52C160` | Cabbage Green Vivid | 청과상, 채소, "성공" 톤 | v1.1 `#5FB868` → 채도 +10%p |
| **Cool Mint** (v1.2 신설) | `#9BE0D2` | Soft Mint | **BG 1순위 (cool tone)**, freshness, accent | v1.2 신설 — cool tone 균형 |
| **Cool Teal** (v1.2 신설) | `#5FB8C4` | Pastel Teal | BG sub, 어물전 연계, accent | v1.2 신설 — cool tone 균형 |
| **Cool Sage** (v1.2 신설) | `#C8D5C0` | Cool Sage | BG sub (모던 fresh), trim, 도마 surface | v1.2 신설 |
| Accent Gold | `#FFC81F` | Sesame Gold Vivid | ★ 등급, 노른자 | v1.1 `#FFD23F` → 채도 +5%p |
| Neutral Wood | `#A67049` | Market Wood | 도마(only traditional 표현 시), 좌판 | 무변경 (사용 최소화) |
| Neutral Dark | `#2D1D14` | Soy Dark | outline (slim 2~3px) | 무변경 |
| **Background Warm-White** (v1.2 신설) | `#FAFAFA` | Cream White | BG 2순위 (cream-white, clean modern) | v1.2 신설 — 베이지 회피 대체 |
| ~~Secondary Cream~~ (v1.2 deprecated) | ~~`#FAEFD8`~~ | ~~Rice Cream~~ | v1.2 **deprecated** — 베이지 회피 LOCK | v1.2 deprecated |
| ~~Background Sky Cream~~ (v1.2 deprecated) | ~~`#FFF1D6`~~ | ~~Sky Cream~~ | v1.2 **deprecated** — 베이지 회피 LOCK | v1.2 deprecated |

### 6.2 가게 시그니처 컬러 (Scene 1, v1.2 채도 +10%p 상향)

§3.4 표 참조. 모든 시그니처 = 채도 80~90% 범위 (v1.1 75~85% → +10%p).

### 6.3 액센트 (음식·VFX 전용, v1.2 cool tone 추가)

| 역할 | HEX | 사용처 | 변경 |
|------|-----|--------|------|
| Accent Sea | `#2E8AC4` | 어물전, 물·얼음 | v1.1 `#3E9BD6` → 채도 +8%p |
| Accent Jang | `#7A5238` | 옹기, 잡화점, 갈비 | 무변경 |
| Accent Mustard | `#E8B639` | 단무지, 노른자 sub | 무변경 |
| Accent Pink Blush (v1.2 tone-down) | `#FFCFCF` | 캐릭터 볼터치, 분홍 | v1.1 `#FFB6B6` → **lighter pink** (Cookie Run 진한 분홍 회피) |
| **Accent Coral** (v1.2 신설) | `#FF8A7A` | UI accent, soft warm-cool 브릿지 | v1.2 신설 — Royal Match coral sync |

---

## 7. 배경 가이드 (v1.2 신설 — 베이지/크림 회피 LOCK)

> v1.2 핵심 shift: iter2 사용자 critique — 베이지/크림 배경 = scrapbook/storybook 톤 → 모바일 UI mismatch. 베이지/크림/kraft paper/vintage texture **회피 LOCK**.

### 7.1 배경 옵션 (1순위~4순위)

| 옵션 | 톤 | 권장도 | 사용처 |
|------|-----|-------|--------|
| **(a) Solid saturated cool tone** ★ 1순위 | Soft Mint `#9BE0D2` / Pastel Teal `#5FB8C4` / Cool Sage `#C8D5C0` | **★★★ 권고** | 캐릭터 anchor / 환경 anchor / 음식 카드 default |
| (b) Cream-white (warm white) | `#FAFAFA` | ★★ 보조 | 음식 카드 sub, character/scene을 main으로 살릴 때 |
| (c) Subtle gradient | top light cool → bottom slightly deeper cool | ★ 환경 only | 환경 BG (Scene 1·2 입구), 캐릭터 X (단색 권고) |
| (d) 투명 PNG | alpha | ★ UI 합성 | 캐릭터 시트 (Godot 레이어 합성), 음식 카드 in-game UI |

### 7.2 v1.2 1순위 권고 (Solid saturated cool tone)

**근거**:
- modern mobile casual 톤 (Royal Match aesthetic) 직접 정합
- cooking 테마 freshness (mint/teal = fresh ingredient, cool sage = kitchen sage tone) 연관
- warm-heavy palette(고추/김치/곶감 = warm) 와 **자연스러운 대조** → 음식/캐릭터 pop ↑
- 베이지 회피 LOCK + 모바일 small screen 가독성 ↑

**구체 권고**:
- 캐릭터 anchor (CH-01~05): **Soft Mint `#9BE0D2`** solid bg 1순위
- 환경 anchor (BG-01~05) 하늘: **Pastel Teal `#5FB8C4` light variant** 또는 **Soft Mint** subtle gradient (top → bottom)
- 음식 카드 (F-01~12, M1): **Cool Sage `#C8D5C0`** solid 또는 cream-white `#FAFAFA` 중 선택

### 7.3 회피 LOCK (v1.2)

- **베이지/크림 일체** (`#FAEFD8`, `#FFF1D6`, `#F5E6C8` 등 warm-yellow-cream 톤) → **즉시 reroll**
- **scrapbook / storybook / kraft paper / vintage texture** → 즉시 reroll
- **golden hour 톤 / sunset warm** → 즉시 reroll
- 모든 prompt에 "Important: avoid beige background, cream paper, scrapbook, storybook, kraft paper, vintage texture, golden hour" 강제

---

## 8. ChatGPT 약점 회피 룰 (flat 톤 특화, 10항 재구성)

> v1.0의 MJ 약점 10항을 ChatGPT 영구 변경(2026-05-27)에 맞춰 재정의. ChatGPT (GPT-4o image / DALL-E)는 MJ와 약점 분포가 다르다 — sref/--ar/--stylize 같은 명시적 lock 메커니즘이 없어 **자연어 prompt 일관성과 follow-up 대화 iteration**으로 회피한다.

| # | 약점 | 발생 빈도 | 회피 룰 (자연어 / negative / follow-up) |
|---|------|---------|----------------------------------------|
| W1 | **한글 텍스트 깨짐** (간판/가격표/메뉴판) | **Very High (~100%)** | ChatGPT는 한글을 모두 가짜 한자/글리프로 출력. anchor 단계에서 모든 텍스트는 `blank cream block placeholder, no readable text, no characters`로 명시. 모든 텍스트는 Photoshop/엔진 UI overlay 후보정. |
| W2 | **photoreal / 3D render 누수** (default 경향) | High | prompt 본문에 `flat 2D illustration, NO photorealistic, NO 3D render, NO texture` 명시 + "Important: avoid realistic, photorealistic, 3D render, octane, unreal engine, gradient mesh." 강제. follow-up: "이 이미지를 더 flat한 2D illustration으로 다시 그려줘." |
| W3 | **digital painting / illustration detail 누수** | High | `flat design, single color fill, NO painterly, NO hand-painted, NO watercolor, NO complex shading` 강제. follow-up: "painterly/watercolor 톤을 제거하고 단색 fill만 남겨줘." |
| W4 | **손가락 detail 누수** | Low~Med (flat 톤 자동 완화, but ChatGPT 인체 detail 추가 경향 MJ보다 높음) | `mitten hands, nub hands, no individual fingers visible`. follow-up: "손을 mitten으로 다시 그려줘, 손가락 detail 제거." |
| W5 | **한식 → 일본 누수** (옹기, 한복, 시장) | High | `Korean K-food, Korean traditional market (Namdaemun, Gwangjang), Korean hanbok jeogori, Korean onggi pottery` 강제 + "Important: avoid Japanese, kimono, tokyo, sushi, fuji, noren." follow-up에서 Korean 키워드 반복 강조. |
| W6 | **한식 → 중국 누수** (청화백자, 빨간 등롱) | Med~High | `Korean style, dark brown earthen onggi` + "Important: avoid Chinese, chinatown, qipao, blue-and-white porcelain, chinese lantern." |
| W7 | **복잡한 composition 약함 (특히 multi-character scene)** | Med | ChatGPT는 한 image 안에 캐릭터 2명 이상 + 환경 + 소품 같이 그릴 때 비율/포즈/스타일 collision 빈번. 본 MVP는 **single subject per image** 원칙 (캐릭터는 Godot 레이어 합성). multi-character 필요 시 한 명씩 따로 생성 후 합성. |
| W8 | **자연어 prompt 길이 한계 (token 소비 ↑)** | Med | 자연어로 modifier 풀어쓰면 prompt 가독성·일관성 ↓. 본 prompt-library는 [Subject] + [Style] + [Composition] + [Surface/Negative] 4 블록 구조로 간결하게. 불필요한 형용사 중복 제거. follow-up 대화로 부족분 채움 (한 번에 다 넣지 말 것). |
| W9 | **reference image 없이 캐릭터 일관성 lock 어려움 (sref 대체 메커니즘 부재)** | **Very High** | MJ `--sref` 대체로 **(a) subject anchor 단어 4 variant prompt에서 동일 유지** (예: "beige apron over orange hoodie" 한 줄을 모든 prompt에 동일 복사) + **(b) lock된 anchor image를 ChatGPT에 reference로 upload 후 style transfer 요청** (선택). CH-02~05는 가능한 한 같은 채팅 세션 안에서 follow-up으로 "앞서 그린 주인공과 같은 스타일·outline·features로" 명시. |
| W10 | **anime girl / 정면 over-detail 누수** | Med (MJ niji 6보다 ↓, but default detail 추가 경향 있음) | `simple two black dot eyes, minimal facial features, NO sparkle eyes` + "Important: avoid anime girl, manga, big sparkly eyes, school uniform, fanservice." |

### 7.1 컬러 채도 폭주 (보조 룰)

채도 100% / neon 누수 빈도 Med. `bold saturated colors 75-85 percent saturation, not neon, not muted` 자연어 강제 (ChatGPT는 숫자 param 없으므로 단어로만 유도).

### 7.2 shape over-complex (보조 룰)

디테일 폭주 빈도 Med. `simple geometric shapes, only 1-2 signature icons per shop, minimal detail, hyper-casual mobile game style` 강제. 1 image 안에 element 5개 초과 시 follow-up "더 minimal하게 다시 그려줘, signature icon만 남기고 detail 제거" 반복.

---

## 9. 자산 export 규격

| 카테고리 | 해상도 | 포맷 | 폴더 |
|---------|--------|------|------|
| BG (Scene 1·2·3) | 2048×1152 (16:9) | PNG (투명 X) | `assets-processed/bg/` |
| 캐릭터 시트 | 1024×1024 투명 | PNG (alpha) | `assets-processed/char/` |
| 캐릭터 reaction | 1024×1024 투명 | PNG (alpha) | `assets-processed/char/reactions/` |
| 음식 카드 | 512×512 투명 | PNG (alpha) | `assets-processed/food/` |
| 재료 카드 | 256×256 투명 | PNG (alpha) | `assets-processed/ingredient/` |
| 칼/도마 / cut anim frame | 512×512 투명 | PNG sequence | `assets-processed/cut/` |
| UI 일러스트 | 가변 (~512) 투명 | PNG (alpha) | `assets-processed/ui/` |
| VFX 시트 | 1024×1024 atlas | PNG (alpha) | `assets-processed/vfx/` |
| **원본** | ChatGPT 출력 최대 (default 고해상도) | PNG | `assets-raw/` (날짜·anchor ID 명명) |

**파일명 컨벤션**: `{category}_{name}_{variant}_v{n}.png`
예: `char_mother_happy_v1.png`, `bg_market_entrance_v2.png`, `food_kimbap_v1.png`, `cut_julienne_f02_v1.png`

---

## 10. Week 1 Anchor Lock Gate (v1.2 — G1~G7 + G_new modernity)

> 본 게이트 통과 = M1 art sprint 진입 신호.
> Anchor별 PASS/CONDITIONAL/FAIL 셀 단위 평가표는 [`art-anchor-rubric.md` v1.1](art-anchor-rubric.md), 실행 키트는 [`ai-session-kit.md` v1.1](ai-session-kit.md).

### 10.1 게이트 8항 (v1.2 — G_new modernity 추가)

| # | 항목 | PASS 기준 (modern mobile casual, ChatGPT) |
|---|------|------------------------------|
| **G1** | **일관성** | 캐릭터 5장이 한 시트 위에서 "같은 IP"로 인식 (같은 outline 두께 + 같은 features 톤 + 같은 컬러 톤). 환경 5장도 한 시장 안 옆가게로 인식. ChatGPT는 sref 부재 → **subject anchor 단어 동일 유지 + reference image upload + 같은 채팅 세션 안 follow-up**으로 일관성 lock. |
| **G2** | **chibi 비율 + dynamic pose (v1.2 갱신)** | 캐릭터: 머리:몸 1:1.5~2, mitten/nub 손, 점 눈, 호 입, **bowl-cut hair (주인공)**, **dynamic action pose** (정적 standing FAIL). 환경: 가게당 shape 1~2 (over-detail FAIL). |
| **G3** | **modern saturated 컬러 (v1.2 갱신)** | §6 베이스 + 가게 시그니처 안에 머묾. **채도 80~90% 범위** (v1.1 75~85% → 상향). **warm/cool 균형** (v1.2 cool tone 1+ 사용 필수 — bg 또는 accent). 100% 또는 70% 미만 FAIL. |
| **G4** | **K-touch 명료** | 외부인이 0.5초 안에 "한국"으로 식별. 일본·중국·이탈리아 표현 누수 0건. 옹기·jeogori 실루엣·재래시장 modern interpretation 식별 가능. **이탈리아 국기 awning 회피 LOCK**. |
| **G5** | **단순성 (modern clean — v1.2 갱신)** | "Royal Match 옆에 놓아도 어색하지 않은가?" fail-test. clean modern flat + soft 1-layer shading 허용. scrapbook/storybook/texture 누수 FAIL. **베이지/크림 배경 즉시 FAIL** (v1.2 LOCK). |
| **G6** | **ChatGPT 약점 회피 (modern 특화)** | §8 약점 10항(W1~W10) 중 5+5 anchor에서 발생 0건. 특히 W1(한글 텍스트), W2(photoreal), W3(painterly/storybook), W9(캐릭터 일관성 lock) 4종이 0. W1은 후보정 가능하므로 CONDITIONAL 허용. |
| **G7** | **모바일 가독성** | 1024×1024 anchor를 256×256으로 축소했을 때 캐릭터/가게/음식 식별 가능. **modern saturation 80~90%가 가독성 도움** — outline slim 2~3px + 채도 ↑ 조합 검증. |
| **G_new** | **modern mobile casual 인상 (v1.2 신설)** | "이 anchor를 Royal Match / Subway Surfers screenshot 옆에 두면 같은 시대/같은 카테고리로 보이는가?" 외부인 평가 5초 안에 "modern mobile casual" 카테고리 일치. **베이지/scrapbook/Cookie Run 2021/Toca Boca 톤 0**. **dynamic pose + cool tone bg + 80~90% saturation + slim outline** 4종이 한 시트 안에서 동시 충족. |

### 10.2 PASS Top 3 우선순위 (v1.2 갱신)

1. **G_new modern mobile casual 인상 (v1.2 신설 1순위)** — v1.2 핵심 reset 사유. 베이지/scrapbook/Cookie Run 2021 톤이 보이면 즉시 reroll. Royal Match-side-by-side test.
2. **G1 일관성** — 깨지면 M1 전체 재작업 위험. ChatGPT sref 부재 → 3축 운영.
3. **G3 modern saturated 컬러 + G7 모바일 가독성** — 80~90% saturation + cool tone 균형이 modernity와 가독성 양쪽 핵심.

### 10.3 PASS 판정 절차

1. 캐릭터 5 + 환경 5를 한 페이지(2×5 grid) contact sheet 작성
2. art-director 자체 G1~G7 체크 → 결과 §11 Decisions 로그
3. pm에게 contact sheet + 결과 공유 → 최종 PASS/FAIL
4. PASS → 채택된 anchor image 파일 경로 + subject anchor 단어 sentence를 `prompts-library.md` §0에 영구 기록 → M1 모든 자산이 동일 subject anchor 문장 + 동일 reference image upload 운영
5. FAIL → 가장 큰 실패 1~2항 집중 reroll (follow-up 대화), 최대 3 라운드. 3 라운드 FAIL 시 pm 에스컬레이션.

### 10.4 게이트 시점·예산

- **목표 시점**: M0 Week 1 종료
- **ChatGPT 예산**: 10 anchor × 평균 2~3 generation (4-grid 없어 reroll 1~2회 발생 가능) = ~25~35 generations. ChatGPT Plus $20/월 DALL-E 무제한 → 한계 비용 0.
- **art-director 작업 시간**: 8~12h (MJ v1.0과 동일 — 도구 변경이 평가 시간에 큰 영향 없음)

---

## 11. ADR-005 정합성 sync (ChatGPT 단일 image 기준)

[ADR-005](decisions.md#adr-005) Stage 2A 재료 준비 — 칼/도마 + cut style 6종 + hero ingredient cut variation.

**flat 톤 + ChatGPT 영구 변경 영향**:
- frame 수: mascot 톤 v3.1 18~24 frame → flat 톤 **12~18 frame** (-25~33%, 도구 무관)
- 생성 방식: MJ 4-grid → ChatGPT **1 image per request**. cut anim frame은 sequence이므로 각 frame을 같은 채팅 세션 follow-up으로 "앞 frame과 동일 ingredient base, cut state만 변경" 명시하여 일관성 lock.
- 단위 시간: mascot 톤 0.5~0.7h/frame → flat 톤 **0.3~0.4h/frame** (-40~50%, 단순 shape 변환 + ChatGPT iteration 속도 빠름)
- 합계 (cut anim): **~5~7h** (mascot v3.1 ~9~17h 대비 -50% 이상)
- ingredient cut variation: ~24 sprite × 0.2h = **~5h** (whole + cut 2장만)
- ADR-005 art 추가 합계 (flat, ChatGPT): **~12~18h** (v3.1 pm reality check 25~35h 대비 -50% 이상)

**Stage 2A art workload는 art-workload-estimate v4.1 §0.1에 정식 반영.**

---

## 12. ADR-002 §Decision #5 정합성 flag (v1.2 신설)

> v1.2 reset이 ADR-002 §Decision #5 ("마스코트 캐릭터 스타일 — Chibi / Cookie Run / 라인프렌즈 풍")와의 정합성을 어떻게 처리하는가.

### 12.1 art-director 판정: **A — Category 안 modern reference shift, ADR amendment 불필요**

**근거**:
1. ADR-002 §#5의 핵심 의도는 **"마스코트 (Chibi) 스타일 채택, 사실적 일러스트 회피"** 카테고리 선언. "Cookie Run / 라인프렌즈"는 reference 예시.
2. v1.2 Royal Match + Subway Surfers shift도 **chibi mascot 카테고리 안에서의 reference 갱신**. chibi 1:1.5~2 비율, mitten 손, 점 눈, dynamic mascot pose 모두 보존. 카테고리 자체는 무변경.
3. ADR-002 §#5 텍스트 자구("Cookie Run / 라인프렌즈")의 reference 부분만 stale — 카테고리는 무변경. **pm 영역에서 cross-ref 註 정도면 충분, full ADR amendment 불필요**.

### 12.2 pm 위임 사항

- pm에게 본 §12 보고 → ADR-002 §#5 옆에 cross-ref 註 추가 권고 ("v1.2 art-style-guide에서 Cookie Run/라인프렌즈 reference → Royal Match/Subway Surfers로 shift, 카테고리는 chibi mascot 유지").
- 또는 pm 판단으로 ADR-007 신규 (Art reference shift) 채택도 가능. 단 art-director는 amendment 불필요 의견.

---

## 13. Anchor Images (Placeholder)

> Week 1 anchor lock 게이트 통과 후 확정 이미지 파일 경로 + ChatGPT 채팅 URL(선택) + subject anchor 문장으로 채움.

### 13.1 캐릭터 Anchor (5장)

| ID | Subject | 파일 경로 | ChatGPT 세션 URL | subject anchor 문장 | Status |
|----|---------|----------|------------------|---------------------|--------|
| CH-01 | 주인공 (base) | TBD | TBD | TBD | pending |
| CH-02 | 어머니 (Tier 2 가족) | TBD | TBD | TBD | pending |
| CH-03 | 아버지 (Tier 2 가족) | TBD | TBD | TBD | pending |
| CH-04 | 주인공 Happy (★3 reaction) | TBD | TBD | TBD | pending |
| CH-05 | 주인공 Subtle (★1·★2 reaction) | TBD | TBD | TBD | pending |

### 13.2 환경 Anchor (5장)

| ID | Subject | 파일 경로 | ChatGPT 세션 URL | subject anchor 문장 | Status |
|----|---------|----------|------------------|---------------------|--------|
| BG-01 | 청과상 🥬 | TBD | TBD | TBD | pending |
| BG-02 | 정육점 🥩 | TBD | TBD | TBD | pending |
| BG-03 | 어물전 🐟 | TBD | TBD | TBD | pending |
| BG-04 | 곡물상 🌾 | TBD | TBD | TBD | pending |
| BG-05 | 잡화점 🫙 | TBD | TBD | TBD | pending |

> 음식 12개 / cut anim / 양친 reaction 6컷 anchor는 M1 sprint(`prompts-library.md` §3~5 placeholder).

---

## 14. Decisions Log (게이트 결과 누적)

| 라운드 | 날짜 | G1 | G2 | G3 | G4 | G5 | G6 | G7 | G_new | 종합 | 비고 |
|-------|------|----|----|----|----|----|----|----|------|------|------|
| iter2 | 2026-05-27 | pending | pending | pending | pending | FAIL (베이지/scrapbook) | pending | pending | **FAIL (올드함)** | **FAIL** | v1.2 reset 트리거 |
| iter3 | TBD | pending | pending | pending | pending | pending | pending | pending | pending | pending | v1.2 prompt 검증 |

---

## 15. 변경 이력

- **2026-05-27 v1.2** (modern mobile casual reset, supersedes v1.1) — iter2 (A-V3_iter2.png, B-V3_iter2.png) 사용자 진단 "전반적으로 올드해 보임" 반영. 3 critique: 베이지/크림 배경 (scrapbook/storybook mismatch), 절구(mortar) 도구 (cooking-mechanics 직접 매핑 X), Cookie Run Kingdom 2021 baseline modernity 부족. §1 톤 한 줄 정의 = **Royal Match (Dream Games 2021) + Subway Surfers chibi energy + 한국 재래시장 K-touch** 재작성. §1.1 reference 표 reset (Royal Match primary, Subway Surfers character-only secondary). §1.2 형용사 modern mobile casual 키워드 채택 + 베이지/Cookie Run/Toca Boca/mortar 금지 명시. §1.3 modernity self-check + 베이지 회피 LOCK 추가. §2 캐릭터 — bowl-cut hair LOCK (iter1/iter2 학습 보존), dynamic action pose 강조 (§2.3 신설), cheek blush light pink tone-down (`#FFCFCF`), §2.5 slim outline 2~3px + soft 1-layer cel shading 허용. §3 환경 — "재래시장 손맛" texture 제거 LOCK, no characters in shop LOCK (iter1/iter2 학습 보존), 이탈리아 국기 awning 회피 LOCK (§3.4 awning 색 조정). §5 **도구 가이드 재작성** — 음식 12 × 도구 매핑 (프라이팬+spatula 9/12, 냄비+국자 3~4/12, 도마+칼 ADR-005 전체, 김밥말이 1/12), **절구 회피 LOCK**, modern flat enameled/colored metallic 톤 (traditional brown wood grain 회피). §6 **컬러 팔레트 재작성** — 채도 70~78% → 80~90% 상승, cool tone 3종 신설 (Soft Mint/Pastel Teal/Cool Sage) + Cream White + Accent Coral, ~~Rice Cream/Sky Cream deprecated~~ (베이지 회피 LOCK). §7 **배경 가이드 재작성/신설** — (a) Solid cool tone 1순위 / (b) Cream-white 보조 / (c) Subtle cool gradient / (d) 투명 PNG. 베이지/scrapbook/golden hour 회피 LOCK. §8~§11 번호 +1 shift. §10 게이트 G1~G7 + **G_new modernity 신설** (Royal Match side-by-side test), Top 3 우선순위 = G_new / G1 / G3+G7. §12 ADR-002 §#5 정합성 판정 = **A (chibi mascot 카테고리 안 reference shift, full ADR amendment 불필요, pm cross-ref 註 권고)**. §14 Decisions Log에 iter2 FAIL + iter3 pending 추가. ADR-005 cut anim frame 수 / sound deferral / engine 무변경. art-workload-estimate 시간 무변동 예상 (v4.1 무변경).
- **2026-05-27 v1.1** (ChatGPT 영구 sync from MJ, supersedes v1.0) — art 도구를 Midjourney → **ChatGPT (GPT-4o image / DALL-E)로 영구 변경** (사용자 confirm 2026-05-27). MJ Standard $30/월 → ChatGPT Plus $20/월 (~33% 절감, DALL-E 무제한). 도구 관련 모든 표기 sync: §1.2 형용사 prompt 투입 형식 자연어 변경 (MJ comma+--param → ChatGPT 자연어 문장 + "Important: avoid ..."), v6.1/niji 6 모델 선택 언급 제거. §1.3 K-touch 체크리스트 한글 텍스트 항목 갱신 (ChatGPT는 한글 ~100% 깨짐). §7 MJ 약점 10항 → **ChatGPT 약점 10항(W1~W10) 재구성**: W1 한글 텍스트 깨짐 (Very High), W2 photoreal, W3 painterly, W4 손가락 detail, W5 일본 누수, W6 중국 누수, W7 복잡 composition 약함 (multi-character scene), W8 자연어 prompt 길이 한계, W9 reference 없이 캐릭터 일관성 lock 어려움 (sref 대체 메커니즘 부재 — subject anchor 단어 동일 유지 + reference image upload + 같은 채팅 세션 follow-up 3축 운영), W10 anime girl + 정면 over-detail. §8 자산 export 원본을 MJ upscale → ChatGPT 출력 default 고해상도. §9 G6 게이트 갱신 (ChatGPT 약점 회피 W1~W10), G1 PASS 기준에 sref 부재 대비책 명시, §9.4 예산 ~25~35 generations + ChatGPT Plus 한계 비용 0. §10 ADR-005 cut anim ChatGPT 1 image per request + 같은 채팅 세션 follow-up 일관성 lock 방식 추가. §11 anchor 표 컬럼을 MJ job ID/`--sref` URL → ChatGPT 세션 URL + subject anchor 문장으로 변경. §1 톤(hyper-casual flat) / §2~§6 컬러·디자인 룰 / §1.1 레퍼런스 좌표 (Subway Surfers/Crossy Road/Stack) 모두 v1.0 lock 유지.
- **2026-05-27 v1.0** (scratch rewrite — hyper-casual flat, supersedes v0.2) — 사용자 art-style reset lock (Subway Surfers / Crossy Road / Stack 계열). mascot 톤(라인프렌즈 + Cookie Run + 재래시장 손맛) → **flat geometric K-food**로 baseline 전환. §1 한 줄 정의·레퍼런스 좌표·형용사 채택/금지 재구성. §2 캐릭터: nub/mitten 손 + 점 눈 + 호 입 + single color fill + 2~4px black outline + shading 없음. §3 환경: 가게당 shape 1~2, perspective 최소화, shadow 거의 없음. §4 음식 12 단순화 가이드 (그릇 + 메인 + accent dot 분해). §5 ADR-005 칼/도마 + cut style 6종 가이드 신설 (frame 수 12~18, mascot 대비 -25~33%). §6 컬러 팔레트 채도 75~85% 상향 + HEX 갱신. §7 MJ 약점 flat 특화 재작성 (photoreal/texture/illustration detail 3종이 high freq). §9 게이트 7항 flat 기준 재구성 (G5 단순성 / G7 모바일 가독성 추가). §10 ADR-005 art workload 감소율 반영.
- **2026-05-24 v0.2** — (archived; mascot 톤. git diff로 복구 가능) Week 1 anchor lock 실행 키트 + 평가 rubric 연동. U-2 sync. reaction sleeping 회피.
- **2026-05-23 v0.1** — (archived; mascot 톤) 초안. ADR-002 마스코트 + ADR-003 MVP scope.
