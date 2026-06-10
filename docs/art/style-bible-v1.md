# Style Bible v1 — K-Food Master

> 버전: **v1.0 (2026-06-06) — UNIFIED VISUAL LANGUAGE LOCK**
> 작성: art-director
> 상위 지시 (사용자 LOCK): "The current bottleneck is visual identity. Before any additional implementation: Create Style Bible v1."
> 성격: **RESKIN (NOT reboot)** — 모든 gameplay/CSV/systems 보존, presentation layer만 단일 언어로 통합.
> Target references (LOCKED): **Cooking Diary · Animal Restaurant · Travel Town**. **NOT Royal Match** (too saturated/glossy/corp — scope 밖).
> 본 문서가 supersede: `art-style-guide.md` v1.2 §1·§6·§7 의 "Royal Match cool-mint / NO beige LOCK" 방향 (브리프 변경에 따라 무효화). v1.2의 chibi 비율/도구 매핑/ChatGPT 약점 회피는 보존.
> **EXTEND (2026-06-08)**: 본 v1 = FOUNDATION. **`style-north-star-v1.md` (Style Bible v2)** 가 본 문서를 supersede 하지 않고 extend — canonical reference `assets-raw/style/north_star_hanhana_v1.png` 로 구체화 + 환경 depth 상향 + 캐릭터 host "한하나" 도입. v1 팔레트와 100% 정합. 신규 작업은 v2 + 본 v1 를 함께 참조.

---

## 0. 왜 Style Bible v1 인가 — 시각 언어 충돌 진단

현 프로젝트에 **4~5개 시각 언어가 동시 존재**. 한 게임으로 안 보임. 이것이 P0 병목.

| # | 충돌 소스 | 현재 톤 | 증거 (screenshot) |
|---|----------|--------|------------------|
| 1 | 초기 art-style-guide v1.1 | hyper-casual flat, slim outline, single fill | cut/ingredient anchor |
| 2 | premium_v2 음식 12장 | Royal Match/Cooking Madness **volumetric glossy** (soft gradient, specular, glossy egg) | `premium_v1/03_cooking.png` (떡볶이) |
| 3 | 캐릭터 + guest avatar | **chibi mascot** bust-up (bowl-cut, mitten, warm storybook) | `phase_bc_avatar_swap/02_guest_select.png` |
| 4 | 조리도구 / cut / ingredient | flat + bold outline + **volumetric wood board / glossy knife** | `d1_d2_d3_polish/03_cooking_slice.png` |
| 5 | UI chrome | **warm beige/cream gradient** panels, gold frames, orange buttons | `d1_d2_d3_polish/01_result_top.png` |
| 6 | art-style-guide v1.2 (문서상 target) | Royal Match cool-mint, "NO beige" LOCK | 문서 vs 실제 빌드 충돌 |

**핵심 모순**: 실제 빌드는 이미 **warm beige + volumetric food + storybook chibi** (= Cooking Diary/Animal Restaurant 톤에 근접) 인데, 문서(v1.2)는 "cool-mint, NO beige, Royal Match" 를 강제하며 정반대로 끌어당김. 결과 = 빌드는 따뜻한데 도구/UI는 어디로 갈지 몰라 톤이 흩어짐.

### 0.1 RESOLVE 원칙 (단일 언어로 통합하는 방법)

> **결정: warm cozy premium-casual 으로 통합. v1.2의 "cool-mint / NO beige LOCK" 를 무효화하고, 실제 빌드의 warm beige + volumetric food 방향을 정식 채택하여 4~5개 톤을 하나로 봉합.**

| 충돌 축 | 어느 쪽으로 RESOLVE | 근거 |
|--------|-------------------|------|
| flat hyper-casual ↔ volumetric premium | **soft volumetric (1~2단 gradient + 1 specular)** 채택. flat은 bug. | 브리프 target 3종 모두 soft shading. premium_v2 음식이 이미 이 톤이고 가장 완성도 높음. flat 도구/cut을 premium 쪽으로 끌어올림. |
| cool-mint bg ↔ warm beige bg | **warm beige/cream/wood 채택**. v1.2 "NO beige" 무효화. | Cooking Diary(warm kitchen)·Animal Restaurant(muted cozy)·Travel Town(warm wood) 모두 warm. 실제 빌드도 warm. cool-mint는 Royal Match 잔재 — scope 밖. |
| chibi storybook char ↔ flat char | **chibi storybook bust 채택**, premium soft shading로 통일 | 브리프 "character-forward, hand-drawn warmth". 음식과 같은 soft shading 규약 공유. |
| Royal Match glossy ↔ Animal Restaurant hand-drawn | **중간 = "polished storybook"**. specular는 음식에만 1점, UI는 matte soft. | 브리프 "premium casual, NOT Royal Match". glossy 폭주 회피, hand-drawn warmth 우선. |

**한 줄 통합 정의 (§1) 가 모든 것의 anchor.**

---

## 1. 한 줄 정의 (UNIFIED)

> **"Cooking Diary 의 따뜻한 키친 + Animal Restaurant 의 hand-drawn storybook 온기 + Travel Town 의 warm wood/soft depth — 그 위에 한식(뚝배기·놋그릇·재래시장) 정체성을 올린 cozy premium-casual."**

- **톤 3축**: `warm` (베이지/우드/석양 아닌 따뜻한 중성) + `cozy` (storybook hand-drawn 온기) + `premium-casual` (soft volumetric, 정돈된 UI, 과하지 않은 polish).
- **food/character/UI/environment 가 "같은 게임"으로 보이는 4 lock**:
  1. **공통 soft shading 규약** — 모든 오브젝트 1~2단 gradient + warm dark outline 3~4px (음식·캐릭터·도구·UI 동일).
  2. **공통 warm 팔레트** — §2 단일 팔레트 (food warm tone + neutral cream/wood + 한식 accent).
  3. **공통 corner/shadow 규약** — round corner, soft drop shadow (§7 UI).
  4. **공통 outline color** — 모든 outline = `Cocoa #3A2A1E` (순흑 금지, warm dark).
- **NOT**: Royal Match 채도 폭주/glossy 폭발, cool mint/teal 지배 bg, hyper-casual flat single-fill, scrapbook 거친 종이 texture(온기는 OK, noise는 NO), 일본·중국 누수.

### 1.1 레퍼런스 좌표 (LOCKED 브리프)

| 레퍼런스 | 차용 (DO) | 차용 안 함 (DON'T) |
|---------|----------|-------------------|
| **Cooking Diary** [PRIMARY tone] | warm cozy kitchen, soft 1~2단 shading, friendly rounded character, 음식 식욕 표현, 정돈된 UI chrome | over-realistic food photo 톤, hidden-object 화면 밀도 |
| **Animal Restaurant** [PRIMARY warmth] | hand-drawn 온기, muted cozy palette (채도 절제), storybook charm, **character-forward**, 약간의 손그림 outline 질감 | 흑백/sepia 미니멀, 동물 캐릭터 자체(우리는 사람 chibi), 너무 어두운 톤 |
| **Travel Town** [PRIMARY depth] | warm **wood texture**, soft **depth shadow** (레이어 분리), expressive character, 전경/후경 layering, isometric-ish 공간감 | merge-2 grid UI 자체, 과한 isometric, 너무 많은 동시 오브젝트 |
| **Cooking Madness / premium_v2** [참고 only] | 음식 volumetric 식욕 표현 (이미 보유한 떡볶이 톤) | glossy 폭주, 과채도 |
| **회피 LOCK** | — | **Royal Match** (채도/glossy/corp), **cool mint/teal 지배 bg** (v1.2 잔재), **hyper-casual flat single-fill**, **scrapbook noise texture**, Cookie Run frosting, Toca Boca, 일본/중국 누수, golden-hour 과포화 |

### 1.2 ChatGPT (gpt-image-1) 자연어 키워드

**채택 (prompt 본문)**: `warm cozy mobile game art`, `Cooking Diary style`, `Animal Restaurant storybook warmth`, `Travel Town warm wood`, `hand-drawn casual illustration`, `soft volumetric shading`, `soft gradient`, `warm beige and cream palette`, `wood texture`, `soft depth shadow`, `cozy kitchen`, `friendly chibi character`, `Korean food`, `Korean dolsot stone pot`, `Korean brass bowl`, `Korean traditional market`, `premium casual mobile game`, `polished but warm`, `rounded soft shapes`

**금지 (prompt 의 "Important: avoid ..." 절)**: `Royal Match style`, `glossy plastic`, `over-saturated neon`, `cool mint background`, `teal dominant`, `flat single color fill`, `hyper-casual`, `scrapbook noise texture`, `grunge`, `Cookie Run frosting`, `Toca Boca`, `photorealistic`, `3D render`, `octane`, `unreal`, `anime girl`, `manga`, `Japanese`, `kimono`, `sushi`, `Chinese`, `qipao`, `chinese lantern`, `Italian flag awning`, `golden hour overexposed`, `text`, `letters`, `Korean characters`

> gpt-image-1 default 경향: 너무 매끈한 3D/glossy 또는 너무 채도 높은 cartoony. → `soft hand-drawn 2D illustration, muted warm palette, NOT glossy, NOT 3D` 를 본문 + avoid 양쪽 강제. cool-mint 누수 시 follow-up "배경을 cool mint 대신 warm cream/beige 로 다시, Animal Restaurant cozy 톤으로."

---

## 2. Color Palette (단일 팔레트 — food + char + UI + env 통일)

> 단일 warm cozy 팔레트. 채도는 **절제 (mid-saturation 55~78%)** — Animal Restaurant muted 온기 기준. Royal Match 80~90% 폭주 회피. 기존 Cool Sage `#C8D5C0` / persimmon 등을 reconcile하여 흡수.

### 2.1 Core (전 자산 공통)

| 역할 | HEX | 이름 | 사용처 |
|------|-----|------|--------|
| **Primary Warm** | `#E8732C` | Persimmon | CTA 버튼, 강조, 곶감/단호박, "Cook Again" |
| **Primary Red** | `#D84338` | Gochu Red | 김치/고추장/떡볶이 소스, 정육, 위험/spicy cue |
| **Secondary Green** | `#6FA94B` | Sesame Leaf | 채소, 청과, 성공/긍정 톤, 파/오이 |
| **Accent Gold** | `#F2B33D` | Sesame Gold | ★ 등급, 노른자, NEW RECORD, premium frame |
| **Accent Brass** | `#B98A3E` |놋 Brass | 놋그릇/유기, gold frame highlight, prestige 톤 |
| **Cocoa (Outline)** | `#3A2A1E` | Cocoa | **모든 outline (3~4px), 텍스트 dark** — 순흑 금지 |

### 2.2 Neutral / Surface (warm beige/cream/wood — v1.2 "NO beige" 무효화하고 정식 채택)

| 역할 | HEX | 이름 | 사용처 |
|------|-----|------|--------|
| **BG Cream** | `#FBF3E4` | Rice Cream | 화면 배경 1순위, 카드 안쪽, panel base |
| **BG Warm White** | `#FFFCF6` | Steamed | 카드 표면, 밝은 패널, 음식 그릇 흰자 |
| **Wood Light** | `#D6A56B` | Oak | countertop, cutting board, 좌판, 가구 (Travel Town wood) |
| **Wood Dark** | `#A6753F` | Walnut | wood depth shadow, 가구 측면, 진한 우드 |
| **Warm Gray** | `#8C8074` | Stone Taupe | 비활성 UI, sub label, metallic 그림자 |
| **Shadow Warm** | `#3A2A1E @ 18~25%` | — | drop shadow (순흑 X, cocoa alpha) |

### 2.3 한식 Food Warm Tones (음식 표현 전용)

| 역할 | HEX | 사용처 |
|------|-----|--------|
| Broth Red | `#C9402F` | 김치찌개/순두부/라면 국물 (깊은 따뜻한 빨강) |
| Egg Yolk | `#F5B731` | 노른자, 단무지 |
| Rice White | `#FAF4E6` | 밥, 떡, 두부 (순백 X, 살짝 cream) |
| Grill Brown | `#8A5A32` | 갈비/고기 구이 grain |
| Scallion | `#7FB04A` | 파, 부추 garnish |
| Dolsot Charcoal | `#4A3B30` | 뚝배기/돌솥 외벽 (warm charcoal, 검정 X) |

### 2.4 절제 규약 (Animal Restaurant muted 기준)

- 한 화면 안 **고채도(>70%) 컬러는 음식 + CTA 1개에만**. 나머지는 cream/wood/warm-gray neutral 로 받침.
- **DO**: Persimmon CTA 1개 + 음식 풍부한 색 + cream/wood 배경 → 음식이 pop.
- **DON'T**: cool mint/teal 배경 (v1.2 잔재 — 즉시 reroll), neon, 화면 절반 이상 채도>70%, 순흑 outline, 순백 표면.
- 기존 `Cool Sage #C8D5C0` reconcile: **deprecated as background**. 채소/garnish 의 sub green 으로만 잔존 허용 (`Sesame Leaf #6FA94B` 우선).

---

## 3. Typography System

> 게임 = **영어 primary + 한글 sub** (i18n icon-first 메모 sync). 폰트는 warm/rounded 계열로 cozy 톤 보강. 한글/영어 모두 커버하는 패밀리 우선.

| 역할 | 폰트 (권장) | 한글 대응 | 사용처 |
|------|-----------|----------|--------|
| **Heading** | Baloo 2 / Fredoka (rounded, friendly) | Cafe24 Ssurround, 배민 주아 | 화면 타이틀, 음식 이름, "NEW RECORD!" |
| **Body** | Nunito / Quicksand | Pretendard, Noto Sans KR | 설명 문장, 대사 ("Junho loved the spicy kick!") |
| **Number** | Baloo 2 ExtraBold (tabular) | (동일) | 점수, 타이머(0.27s), %, ₩50,000 |
| **Label** | Nunito SemiBold (uppercase, letter-spacing) | Pretendard Medium | 칩/배지("SPICY", "FRIEND"), 버튼 |

### 3.1 Size Scale (1080×1920 base, px)

| 단계 | px | weight | 용도 |
|------|-----|--------|------|
| H1 | 64 | ExtraBold | 화면 타이틀, RECORD |
| H2 | 48 | Bold | 음식 이름, panel 헤더 |
| H3 | 36 | Bold | step 표시("Step 1/4 · Slice") |
| Body | 30 | Regular/Medium | 대사, 설명 |
| Number-L | 72 | ExtraBold | 핵심 점수 |
| Label | 24 | SemiBold | 칩, 배지 |
| Caption | 22 | Medium | 보조 라벨(친밀도 %, 한글 sub) |

### 3.2 규약

- **DO**: heading/number rounded weight 로 cozy. dark 텍스트 = `Cocoa #3A2A1E`. 한글 sub 는 영어보다 1단계 작게 + Caption weight.
- **DON'T**: gpt-image-1 으로 텍스트 생성 금지 (한글 100% 깨짐, 영어도 신뢰 X) — **모든 텍스트는 Godot UI overlay**. mockup 에는 텍스트 "placeholder block" 만.
- 칩/배지: pill 모양(corner radius = height/2) + label 24px + icon 우선(i18n).

---

## 4. Character Style Guide (CHARACTER-FIRST)

> 브리프 최우선: **"character quality > environment quantity"**. 7 character 가 IP 핵심. 모두 **chibi storybook bust** + §1 공통 soft shading. Animal Restaurant 의 hand-drawn 온기 + Cooking Diary friendly.

### 4.1 7 Character Roster (silhouette identity)

| ID | 캐릭터 | 역할 | silhouette / color anchor | 표정 cue |
|----|--------|------|--------------------------|---------|
| Junho | 준호 | Friend (20s 남, 한국) | bowl-ish 짧은 검정머리, **빨강/주황 후드**, 둥근 얼굴 | spicy 좋아함 → 활기찬 미소, 어깨 으쓱 |
| Mina | 미나 | Friend (20s 여, 한국) | 단발+ side bang, **soft yellow/cream 톱**, bright | sweet 좋아함 → 밝은 눈웃음 |
| Riley | 라일리 | Friend (20s 서양) | 곱슬 금발/주황, **blue 톤 의상**, 주근깨 | umami 호기심 → 한쪽 눈썹 올림 |
| Mrs Lee | 이씨 아주머니 | Neighbor (40s 여, 한국) | 둥근 bun + 안경, **green 가디건**, 자상 | fermented 전문 → 따뜻한 끄덕임 |
| Seoyeon | 서연 | Blogger (30s 여, 한국) | 긴 생머리 + 앞머리, **muted purple/plum**, 세련 | sour 호기심 → 살짝 평가하는 눈 |
| Mother | 어머니 | Family | 둥근 bun(흰머리 섞임), **jeogori 실루엣(자수X) + warm coral** | 자애로운 미소 |
| Father | 아버지 | Family | salt-and-pepper 짧은머리, **단색 카디건 + tan** | 든든한 미소 |

> **silhouette identity rule**: 7명을 흑백 실루엣으로 축소해도 머리모양 + 상의 컬러 block 1개로 구분 가능해야 PASS. 이것이 character-first 의 1차 테스트.

### 4.2 Proportion Lock (chibi storybook)

- **머리:몸 = 1:1.3~1.6** (bust-up 기준 — storybook 은 hyper-casual 1:2 보다 살짝 덜 과장. Animal Restaurant 톤). 화면에는 **가슴 위 bust** 만 노출 (avatar 용도).
- 머리 폭 ≈ 어깨 폭 × 1.1~1.25.
- 손 노출 시 **mitten/nub** (손가락 detail X — gpt-image-1 약점 회피). 인사 손(Junho 처럼)은 둥근 mitten.

### 4.3 Face Features (storybook warmth — hyper-casual flat 보다 1단 풍부)

- **눈**: 검정 둥근 점 + **작은 흰 하이라이트 1점** 허용 (storybook 온기 — hyper-casual "점만" 보다 따뜻). 속눈썹은 여성 캐릭터에 짧게 1~2 가닥만.
- **입**: 호 1줄(미소) / O(기쁨) / 작은 직선(중립). vertices 절제.
- **코**: 아주 작은 점/짧은 호 1개 허용 (storybook 은 코 생략보다 작은 코가 더 따뜻).
- **볼터치**: soft warm blush `#E89A7A @ 40%` (cool pink 아닌 warm peach — cozy 톤). 거의 모든 캐릭터에 옅게.

### 4.4 Outline / Shading 규약 (§1 공통 — 음식/UI 와 동일)

- **외곽 outline**: **3~4px**, `Cocoa #3A2A1E` (warm dark, 순흑 X). Animal Restaurant 의 살짝 손그림 느낌 outline — 완벽히 균일할 필요 없음(약간의 굵기 변화 OK = hand-drawn 온기).
- **shading**: **soft 2단** (base + base×0.85 그림자, 부드러운 gradient 경계). 의상/머리/얼굴에 적용. hyper-casual single-fill 금지, Royal Match 다층 glossy 금지 → 그 중간.
- **highlight**: 머리 1점, 의상 어깨 1점 정도 soft (subtle). 음식만큼 glossy 하지 않게.
- **bust shadow**: avatar 원형 frame 안에서 하단 soft ambient.

### 4.5 Emotion Sheet (4 reaction per guest — 결과 화면)

각 guest: **bad(★1) / okay(★2~3) / good(★4) / excellent(★5)** 4 표정. 같은 채팅 세션 내 reference-lock follow-up 으로 생성(일관성).
- bad: 처진 눈썹 + 작은 ㅡ 입 (실망, NOT 자는 표정 — "avoid eyes closed peaceful, sleeping" 필수).
- okay: 중립 미소.
- good: 눈웃음 + 호 입.
- excellent: O-shape 입 + 반짝 눈 + 두 손 듦(Junho result 처럼) + sparkle 2~3.

### 4.6 DO / DON'T

- **DO**: 7명 silhouette+color 로 즉시 구분, soft 2단 shading, warm peach blush, hand-drawn 온기 outline, bust-up 구도.
- **DON'T**: 손가락 detail, anime big sparkly eyes, 자는 표정(bad reaction), cool pink blush, 균일 vector outline(너무 차가움), 한 캐릭터에 컬러 block 4개 초과.

---

## 5. Food Style Guide (volumetric vs flat RESOLVE)

> **RESOLVE: premium_v2 volumetric 채택을 정식화.** flat 음식은 bug. 단, Royal Match glossy 폭주는 Cooking Diary 의 "식욕나지만 따뜻한" 톤으로 절제. 음식 = 게임 주인공 → 가장 풍부하게 그리되 §1 공통 outline/팔레트 공유.

### 5.1 공통 룰

- **시점**: 7/8 top-down (그릇 안 내용 + 입체감 동시). 카드 1:1 (512²) 또는 그릇 단독.
- **shading**: **soft 2~3단 gradient** (premium_v2 톤 유지) — 음식만 캐릭터/UI 보다 1단 더 풍부 허용.
- **specular**: 표면 1~2점 (국물 광택, 노른자, 면). Royal Match 처럼 전체 glossy plastic 코팅 금지 — "갓 조리된 윤기" 만큼만.
- **outline**: 3~4px `Cocoa #3A2A1E` (§1 공통 — 캐릭터/UI 와 동일 두께·색).
- **background (카드)**: `BG Cream #FBF3E4` 또는 투명 PNG. **cool sage/mint 금지** (v1.2 잔재 무효화).

### 5.2 한식 정체성 (그릇 = 시그널)

| 음식군 | 그릇 (한식 시그널) | 표현 |
|--------|------------------|------|
| 찌개/국 (김치찌개·순두부·라면) | **뚝배기 dolsot** (`Dolsot Charcoal #4A3B30` warm 질그릇, 검정 X) | 끓는 국물 + steam + 거품 |
| 밥/비빔밥 | **놋그릇 brass** (`Brass #B98A3E`) 또는 백자 흰그릇 | 방사형 나물 색 section |
| 구이/갈비 | 무쇠팬 또는 돌판 + 한식 곁들임 | grill grain + 윤기 |
| 분식 (떡볶이·김밥·호떡·콘도그) | 백자 접시 / 분식집 멜라민 | 이미 premium_v2 톤 (떡볶이 = 기준작) |

> **DON'T**: 검정 일본식 donburi/라멘 bowl, 청화백자(중국), 그릇 무늬 과다. **DO**: 따뜻한 뚝배기/놋그릇/백자 + bold outline.

### 5.3 premium_v2 reskin 방향

기존 premium_v2 12장은 톤이 거의 맞음(떡볶이 = 기준). reskin = (1) 배경을 cool sage→cream 통일, (2) outline 색 cocoa 통일, (3) glossy 과한 1~2장만 specular 1단 낮춤. **대부분 재사용, 부분 보정**.

---

## 6. Environment Style Guide (L1~L5 진화)

> 브리프: **warm wood / soft depth / Korean texture (noise 아닌 온기)**. Travel Town 의 layering + warm wood 가 핵심. 5단계 = 플레이어 성장 = 환경 격상.

### 6.1 L1~L5 진화 규약

| Lv | 공간 | warm 톤 anchor | Korean texture signal | depth |
|----|------|---------------|----------------------|-------|
| **L1 Home Kitchen** | 집 부엌 | cream wall + oak countertop | 밥솥, 김치냉장고, 작은 뚝배기 선반 | 얕은 1단 depth |
| **L2 Snack Shop (분식집)** | 동네 분식집 | warm tile + 멜라민 톤 | 떡볶이 철판, 어묵 국물통, 손글씨 메뉴(텍스트 overlay) | 카운터 전/후경 2단 |
| **L3 Market (재래시장)** | 재래시장 가판 | wood 좌판 + 천막 | 옹기, 마대자루, Namdaemun 톤 천막(이탈리아국기 X) | 가판 + 옆가게 실루엣 3단 |
| **L4 Food Alley (먹자골목)** | 먹자골목 밤 | warm 등불 + 우드 | 포장마차 천막, 연탄불, 한글 간판(overlay) | 골목 깊이 + 등불 bokeh |
| **L5 Prestige Restaurant** | 고급 한정식 | dark walnut + brass + 한지 톤 | 놋그릇 진열, 한지 조명, 소반(소반상) | full depth, brass 반사 |

### 6.2 규약

- **depth shadow (Travel Town)**: 전경 오브젝트 아래 soft drop shadow + warm-gray 후경 실루엣으로 레이어 분리. 블러 X — 단색 실루엣 + 명도 차.
- **warm wood (Travel Town)**: countertop/가구 = `Oak #D6A56B` + `Walnut #A6753F` 측면 그림자. wood grain 은 subtle line 2~3개만(noise 텍스처 X).
- **Korean texture = 온기**: 옹기/한지/천막/소반 = 형태로 한식. 거친 종이 noise/scrapbook 은 금지(온기는 컬러/형태로, noise 로 X).
- **BG에 캐릭터 비포함**: 빈 공간 anchor. 캐릭터는 Godot 레이어 합성.
- **천막 awning**: 단색 + accent 1색. 빨강-녹색-흰색(이탈리아) 금지 LOCK.

### 6.3 DO / DON'T

- **DO**: warm wood, soft depth layering, 한식 형태 signal, 단계별 격상(L1 소박 → L5 brass 고급).
- **DON'T**: cool mint 벽, scrapbook noise, 캐릭터 in-BG, 이탈리아 천막, 일본 노렌/중국 등롱.

---

## 7. UI Style Guide (glossy vs flat RESOLVE)

> **RESOLVE: warm matte premium.** premium_v2 gold-glossy 프레임 ↔ flat 의 충돌을 "warm rounded card + subtle soft shadow + matte fill + 1 gold accent frame(중요 요소만)" 으로 통합. Cooking Diary 의 정돈된 UI + Animal Restaurant 의 cozy.

### 7.1 Component 규약

| 요소 | 규약 |
|------|------|
| **Button (primary CTA)** | fill `Persimmon #E8732C`, corner radius **24px**, 하단 darker bevel 4px(살짝 입체), soft drop shadow(`#3A2A1E @18%`, y+6, blur 12), 텍스트 white H2. matte(glossy X). |
| **Button (secondary)** | fill `Gold #F2B33D` 또는 `BG Warm White`, cocoa outline 3px, 동일 radius/shadow. |
| **Card (음식/guest)** | fill `BG Warm White #FFFCF6`, corner radius **28px**, cocoa outline 3px(또는 outline 없이 soft shadow), inner padding 충분. |
| **Panel (대사/패널)** | fill `BG Cream #FBF3E4`, radius 24px, soft shadow. 대사 패널은 말풍선 꼬리 1개. |
| **Badge / Chip (pill)** | corner radius = height/2, fill = 의미색(spicy=red, sweet=gold...), label 24px, icon 우선. |
| **Premium Frame (RECORD/★)** | `Gold #F2B33D` + `Brass #B98A3E` 2톤 프레임 — **이것만** 약간의 glossy/반짝 허용(특별함 신호). 남발 X. |

### 7.2 공통 규약

- **corner radius**: 버튼 24 / 카드 28 / 칩 = h/2 / 작은 아이콘 12. 직각 모서리 금지(cozy = round).
- **drop shadow**: `Cocoa #3A2A1E @ 18~25%`, y+6, blur 12. 순흑 그림자 금지.
- **outline**: 카드/버튼 cocoa 3px (§1 공통). 너무 두꺼운 4px+ 는 무거움.
- **frame/장식**: gold-brass premium frame 은 RECORD·★·prestige 에만. 일반 UI 는 matte.

### 7.3 DO / DON'T

- **DO**: warm matte fill, round corner, soft cocoa shadow, gold frame 절제 사용, icon-first 칩.
- **DON'T**: 전면 glossy plastic, 순흑 그림자, cool mint UI, 직각 모서리, 한 화면 gold frame 3개+, 한글 텍스트를 이미지로 생성.

---

## 8. VFX Style Guide (subtle premium — NOT Royal Match 폭발)

> 브리프 + 사용자: subtle premium. Cooking Diary 의 "맛있어 보이는 김/반짝" 수준. Royal Match 의 화면 폭발/과한 파티클 회피.

| VFX | 규약 |
|-----|------|
| **Steam (김)** | 뚝배기/냄비 위 soft white 곡선 wisp 2~3 가닥, 반투명(40~60% alpha), 위로 사라짐. 한식 "끓음" 핵심 signal. |
| **Sparkle (반짝)** | 4-point soft star, gold `#F2B33D`, 2~3개, excellent reaction/RECORD 에만. 작게. |
| **Perfect / Hit (rhythm tap)** | warm ring pulse 1회(persimmon→투명) + "PERFECT!" 텍스트 gold(overlay) + sparkle 2. 화면 흔들림 금지. |
| **Star burst (★ 결과)** | ★ 하나씩 pop-in(scale bounce) + 각 ★ 에 sparkle 1. 폭발 파티클 X — 순차 등장. |
| **Steam/aroma trail (서빙)** | 음식→손님 사이 soft aroma 곡선 1개(점선 아닌 부드러운 line) → 손님 happy. |

### 8.1 규약

- **DO**: soft 반투명, warm 톤(gold/cream/persimmon), 절제된 개수(화면당 핵심 1~2 VFX), 음식 식욕/끓음 강조.
- **DON'T**: 화면 폭발, 다색 confetti 폭주, 화면 흔들림(camera shake), neon glow, cool-tone VFX, 동시 5+ 파티클.

---

## 9. Screenshot Mood Board (Hero Screenshot Test 기준)

> 모든 화면의 합격 기준 = **Hero Screenshot Test** (§9.2). mood 방향 = warm / inviting / Korean / premium-casual.

### 9.1 Mood 방향 (생성할 reference 묘사)

- **전체 인상**: 따뜻한 오후 부엌의 cozy 한 빛. cream/oak/persimmon 이 지배, 음식이 화면의 식욕 중심, 손님 캐릭터가 따뜻하게 지켜봄.
- **Cooking Diary 차용**: 정돈된 따뜻한 키친 카운터, 식욕나는 음식 클로즈.
- **Animal Restaurant 차용**: muted 온기, hand-drawn 캐릭터 표정, storybook 친근함.
- **Travel Town 차용**: warm wood countertop, 전/후경 soft depth, 공간감.
- **Korean 차용**: 뚝배기에서 김 오르는 라면/찌개, 놋그릇, 재래시장 천막 또는 분식집 톤.

### 9.2 Hero Screenshot Test (rubric — `art-anchor-rubric.md` 와 별도 §, App Store/TikTok/Reddit 인식 기준)

스크린샷 1장을 **3초 노출 → 외부인(타겟 아닌 사람)** 에게 보였을 때:

| # | 질문 | PASS 기준 |
|---|------|-----------|
| **HT1** | 무슨 게임? | "요리/쿠킹 게임" 3초 내 식별 |
| **HT2** | 무슨 음식? | "라면/찌개 등 구체 음식" 식별 (그릇+내용으로) |
| **HT3** | 무슨 action? | "끓이는/써는/타이밍 맞추는 중" 식별 (도구+UI cue) |
| **HT4** | 어느 나라? | **"한국/한식"** 식별 (뚝배기/놋그릇/시장/한글 간판 중 3+ signal) |
| **HT5** | premium? | "잘 만든 모바일 게임" 인상 (대충/프로토타입 아님) — soft shading + 정돈 UI + 일관 톤 |
| **HT6** | cozy? | "따뜻하고 들어가고 싶은" 정서 (warm 톤 + 친근 캐릭터) |
| **HT7** | 일관성? | 음식/캐릭터/UI/배경이 **"같은 게임"** (톤 충돌 0) |

**PASS = HT1~HT7 중 6개+ (HT4 한식 + HT7 일관성 필수).** App Store 첫 스크린샷 / TikTok 썸네일 / Reddit r/AndroidGaming 스크롤 정지 테스트.

### 9.3 DO / DON'T (Hero)

- **DO**: 음식이 화면 영웅(식욕), 한식 그릇/도구 명확, 손님 watching, warm 톤, UI cue 최소 1개로 action 전달.
- **DON'T**: 화면 절반 빈 cream(밋밋), 음식이 작아서 안 보임, 한식 signal 2개 이하, 톤 충돌(flat 도구 + glossy 음식 혼재), 텍스트 깨짐 노출.

---

## 10. 적용 순서 / 변경 이력

- 적용 roadmap: [`art-production-roadmap-v2.md`](art-production-roadmap-v2.md)
- Hero Screen mockup: [`cooking-hero-screen-spec.md`](cooking-hero-screen-spec.md)
- **2026-06-06 v1.0**: 4~5개 시각 언어 충돌을 단일 cozy premium-casual 로 RESOLVE. v1.2 "Royal Match cool-mint / NO beige LOCK" 무효화, warm beige+volumetric food 방향 정식 채택. 8 section lock (palette/typo/char/food/env/UI/VFX/mood). character-first. Cooking Diary/Animal Restaurant/Travel Town target LOCK.
