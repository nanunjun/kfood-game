# AI Comparison Test — Art Style 시각 비교 키트 (ChatGPT 기반)

> 버전: **v1.1 (2026-05-27, ChatGPT conversion)**
> 작성자: art-director
> 상위 문서: [`art-style-guide.md` v1.0](art-style-guide.md), [`ai-session-kit.md` v1.1](ai-session-kit.md), [`decisions.md` ADR-002 / ADR-005](decisions.md)
> 본 문서 범위: art-style **lock 전** 시각 비교 prerequisite. 같은 subject × 4 style variant ChatGPT 생성 → 사용자 직접 비교 → 시각 기반 lock → 그 후 full session kit 재작성.

> **도구 변경 사유**: 사용자 2026-05-27 ChatGPT pivot (영구 변경, 2026-05-27 confirm). Midjourney param/4-grid/upscale 개념 제거, ChatGPT 자연어/single-image/대화형 reroll로 재구성. 본 문서는 v1.0 (Midjourney 기반)의 같은 비교 의도(2 subject × 4 style variant)를 유지하되, 도구 차이로 인한 prompt 형식 · 워크플로 · 시간 · 비용을 재산정한다. 파일명 rename(`mj-comparison-test.md` → `ai-comparison-test.md`)은 2026-05-27 main thread가 처리 완료. 다른 art 문서 5종도 같은 날짜에 ChatGPT 영구 sync 완료 (art-style-guide v1.1 / prompts-library v1.1 / ai-session-kit v1.1 / art-anchor-rubric v1.1 / art-workload-estimate v4.1).

---

## 0. 목적

사용자가 art-style 결정에서 reversal cycle을 겪었다 (5/23 mascot lock → 5/24 reject "너무 복잡, 모바일 게임 톤" → 5/27 flat lock → 5/27 mascot 복원 제안). 근본 원인은 **텍스트 기반 옵션 비교가 추상적**이라 실제 시각 결과를 상상하지 못한 것. 본 키트는 **같은 subject 2개를 4가지 style variant로 동시 생성**하여 사용자가 화면 위에서 1:1 비교 후 시각 기반으로 lock하게 한다. 이 비교 lock이 끝나야 session kit를 해당 variant로 재작성하고 Week 1 anchor sprint 진입한다.

---

## 1. Subject 선정 (2개 고정)

비교에 사용할 subject 2개는 art-style 차이가 가장 잘 드러나는 항목으로 한정한다.

| Subject | 선정 이유 | 드러나는 차이 |
|---------|----------|--------------|
| **A. 주인공 캐릭터** (chef boy in apron, 한식 요리 도구, 도마 앞) | Tier 1 L1부터 모든 scene에 등장, reaction variant base | 캐릭터 expressiveness, detail 밀도, outline 두께, 표정 features 처리 |
| **B. 청과상 가게** (재래시장 produce stall, 5가게 시그니처 컬러 green) | 5가게 anchor 중 가장 한식적·시각 풍부, 환경 base | 환경 texture, perspective, shading, 공간감, 시그니처 컬러 표현 |

> 두 subject 모두 캐릭터 포즈와 가게 angle은 4 variant에서 **동일하게 고정**한다 (§7 Step 0 anchor). 그래야 비교가 style modifier 차이로만 환원된다.

---

## 2. Style Variants (4개) 개요

| Variant | 톤 한 줄 정의 | 출처 |
|---------|--------------|------|
| **V1. Cookie Run / Chibi Mascot** | 라인프렌즈 친근함 + Cookie Run 식감 + 재래시장 손맛 (anime mascot 영향 자연어 표현) | v0.2 baseline 복원 |
| **V2. Hyper-Casual Flat** | Subway Surfers / Crossy Road / Stack 계열 단색 fill + bold outline | v1.0 현재 lock |
| **V3. Cookie Run + Simplified** | V1 캐릭터 톤 유지, BUT 골든아워 OFF + texture OFF + 환경 디테일 -50% | V1·V2 중간 (신설) |
| **V4. Toca Boca / Among Us Hybrid** | round chibi + 단색 fill + 단순 features + 친근 캐릭터 | 신설 대안 |

> ChatGPT는 모델 선택 param이 없다 (내부 자동). V1의 anime mascot 영향은 prompt 자연어로 표현한다 ("in Japanese anime mascot style influence").

### 2.1 Variant 별 핵심 식별 요소

#### V1 — Cookie Run / Chibi Mascot
- 비율: chibi 1:1.5~2, mitten 손, 점 눈 + 분홍 볼터치
- 조명: 골든아워 단일 directional, 부드러운 그림자
- 텍스처: 시장 손맛 (천막 천 weave, 마대 burlap, 도마 grain 가시화)
- 컬러: 채도 60~70% warm, sun-kissed
- 환경 디테일: 5가게 시그니처 + sub-prop 2~3 (등불, 짚, 가격표지)

#### V2 — Hyper-Casual Flat
- 비율: chibi 1:1.5~2, mitten 손, 점 눈, 호 입 (V1과 동일)
- 조명: 거의 없음 (단일 ambient), 그림자 ellipse 1개
- 텍스처: 0 (clean flat color, NO grain/noise/canvas)
- 컬러: 채도 75~85% bold saturated
- 환경 디테일: 가게당 시그니처 icon 1~2개만

#### V3 — Cookie Run + Simplified (mid-tone)
- 캐릭터: V1과 동일 (chibi + mitten + 점 눈 + 분홍 볼터치)
- 조명: 골든아워 OFF → 단일 ambient (V2와 유사)
- 텍스처: OFF (clean flat fill)
- 환경: 5가게 시그니처 컬러 + 시그니처 icon 1~2개 (V2와 유사)
- **핵심 의도**: V1 캐릭터 친근함 + V2 환경 단순함 = 1인 제작 sustainable + 모바일 가독성 + Cookie Run IP 친근함

#### V4 — Toca Boca / Among Us Hybrid
- 비율: round chibi 1:1.3 (V1·V2·V3보다 둥글둥글)
- 캐릭터 형태: round body + round head, 사지 nub (Among Us 영향)
- features: 눈만 (입 생략 가능, Among Us처럼 단순)
- 컬러: 채도 70~80% pastel + accent
- 환경: Toca Boca 톤 — round prop, 단색 fill, 손맛 약간 (V2와 V1 사이)
- **핵심 의도**: V1·V2·V3 모두 안 맞으면 mobile casual의 또 다른 줄기 (Toca Boca 시리즈 = 글로벌 ARPDAU top tier)

---

## 3. 비교 평가 기준 (사용자 자가 평가)

세션 종료 후 사용자가 8장(2 subject × 4 variant)을 한 화면에 펼친 뒤 다음 5축으로 평가한다.

| # | 평가축 | 질문 | 우선순위 |
|---|--------|------|---------|
| C1 | **첫인상** | 4 variant 중 어느 톤이 "K-Food Master"라는 게임 이름에 가장 자연스럽게 맞는가? | High |
| C2 | **모바일 가독성** | 핸드폰 small thumbnail(256px)로 축소했을 때 어느 variant가 가장 잘 보이는가? | High |
| C3 | **캐릭터 표현력** | 어느 variant가 ★1/★2/★3 reaction variant 만들기 적합한가 (표정 차이 가시성)? | Med |
| C4 | **환경 차별화** | 5가게 시그니처 컬러 + 한식 K-touch가 어느 variant에서 가장 명료한가? | High |
| C5 | **작업 부담 직감** | 어느 variant가 1인 제작 sustainable한 느낌인가? (디테일 부담) | Med |

> Lock 결정: C1·C2·C4가 같은 variant이면 그것을 lock. 갈리면 "두 variant의 hybrid" 요청 가능 (예: "V3 캐릭터 + V2 환경" 또는 "V2 캐릭터 + V1 환경 텍스처 절반").

---

## 4. Subject A — 주인공 (4 variant prompt, ChatGPT 자연어)

> 모든 prompt에서 캐릭터 핵심 description은 동일 (3/4 view, full body standing, beige apron over orange hoodie, holding wooden spatula, neutral smile, plain cream background). **style modifier만 변경**.
> 정사각형 (square 1:1 format) 고정. ChatGPT에 1 image씩 request. 결과 저장 후 다음 prompt로.

---

### A-V1 — Cookie Run / Chibi Mascot
**Prompt** (ChatGPT 채팅창에 그대로 붙여넣기):
```
A warm friendly illustration of a young Korean cooking character in a square 1:1 format. The character has chibi mascot proportions (head to body ratio 1:1.8), wearing a beige apron over an orange hoodie. They hold a small wooden spatula in mitten-style hands. Features: neutral warm smile, two small black dot eyes, soft pink circular cheek blush, no nose, round bun-like hairstyle. Pose: three-quarter view, full body standing.

Lighting: golden hour soft directional lighting from upper left, warm cinematic glow on the character, soft drop shadow under feet, gentle highlight on the hoodie shoulder. Surface: subtle hand-painted apron texture (canvas weave hint). 

Style: Cookie Run Kingdom style meets Line Friends mascot vibe, K-pop traditional market warmth, with Japanese anime mascot style influence in the friendly chibi expression. Highly stylized painterly rendering with soft 2-layer shading. Bold 2-3px outline in dark soy color. Saturated 60-70 percent warm palette. Plain warm cream background.

Important: avoid anime girl style, big sparkly eyes, school uniform, fanservice or sexy elements, realistic or photorealistic rendering, 3D render, hyperdetailed elements, individual finger detail, Japanese (kimono), Chinese (qipao), dark or gritty tones.
```
**Reroll 트리거 (follow-up 대화 형식)**:
- anime girl로 빠지면: "이 이미지를 다시 그려줘. anime girl 느낌, 큰 sparkly 눈, 교복 요소를 모두 제거하고, Cookie Run Kingdom mascot처럼 친근한 chibi로 다시 시도해줘."
- flat 톤으로 빠짐(painterly 누수 ↓): "이 이미지를 더 painterly하게, golden hour의 warm glow와 soft 2-layer shading을 더 분명하게 다시 그려줘."
**Expected output 특징**: warm golden glow + 캐릭터 표면에 soft shading 2 layer + 천막/앞치마 texture hint + 채도 차분.

---

### A-V2 — Hyper-Casual Flat
**Prompt**:
```
A flat 2D illustration of a young Korean cooking character in a square 1:1 format. The character has chibi mascot proportions (head to body ratio 1:1.7), wearing a beige apron over an orange hoodie. They hold a small wooden spatula in mitten-style hands. Features: neutral warm small arc smile, two small black dot eyes, no nose, optional pink circular cheek blush. Pose: three-quarter view, full body standing.

Surface: single color fill on the clothing (orange hoodie + beige apron, 2 color blocks), bold 3px black outline, geometric rounded shapes. No shading, no highlights, no texture, no golden hour lighting. Plain cream background.

Style: Subway Surfers character vibe meets Crossy Road simplicity meets Stack clean color grading. Hyper-casual mobile game character with minimal stylization. Bold saturated colors at 75-85 percent saturation.

Important: avoid anime girl style, manga style, big sparkly eyes, school uniforms, fanservice or sexy elements, realistic or photorealistic rendering, 3D render, octane or unreal engine looks, any texture or noise, painterly or hand-painted feel, watercolor, gradient mesh, complex multi-layer cel shading, hyperdetailed elements, individual finger detail, nose detail, Japanese (kimono), Chinese (qipao), dark or gritty tones, cinematic golden hour or dramatic lighting.
```
**Reroll 트리거 (follow-up)**:
- photoreal 누수: "이 이미지를 더 flat한 2D illustration으로 다시 그려줘. 3D render나 octane/unreal 느낌, gradient mesh를 완전히 제거하고, 단색 fill과 bold outline만 남겨줘."
- shading 누수: "이 이미지를 다시 그려줘. shading과 highlight를 모두 제거하고, 단일 color fill만 사용해서 완전히 flat하게 만들어줘."
**Expected output 특징**: 단색 fill 의상, 그림자 없음, 디테일 0에 가까움, 채도 bold.

---

### A-V3 — Cookie Run + Simplified (mid-tone)
**Prompt**:
```
A flat illustration of a friendly young Korean cooking character with Cookie Run Kingdom mascot warmth, in a square 1:1 format. The character has chibi proportions (head to body ratio 1:1.8), wearing a beige apron over an orange hoodie. They hold a small wooden spatula in mitten-style hands. Features: neutral warm smile with a slight upward curve, two small black dot eyes, soft pink circular cheek blush, no nose, round bun-like hairstyle rendered as a solid shape. Pose: three-quarter view, full body standing.

Surface: single color fill on clothing with a very subtle 1-layer ambient shading only (no golden hour, no directional light). Clean flat color with no texture, no canvas weave. Soft drop shadow ellipse under the feet only. Bold 2-3px outline in dark soy color.

Style: Cookie Run mascot character expressiveness applied to hyper-casual mobile game art simplicity. K-pop friendly mascot vibe without hand-painted texture. Moderate stylization. Saturated 70-78 percent palette, balanced between warm and bold. Plain warm cream background.

Important: avoid anime girl style, manga style, big sparkly eyes, school uniforms, fanservice or sexy elements, realistic or photorealistic rendering, 3D render, octane or unreal engine, any texture, noise, canvas weave, painterly or hand-painted feel, watercolor, gradient mesh, multi-layer cel shading, golden hour or dramatic lighting, hyperdetailed elements, individual finger detail, nose detail, Japanese (kimono), Chinese (qipao), dark or gritty tones.
```
**Reroll 트리거 (follow-up)**:
- 너무 V1(painterly 누수): "이 이미지를 더 clean하고 flat하게 다시 그려줘. painterly texture와 canvas weave를 모두 제거하고, ambient shading은 1-layer만 남겨줘."
- 너무 V2(차가운 단조): "이 이미지를 다시 그려줘. Cookie Run mascot warmth, pink cheek blush, friendly chibi 친근함을 더 살리되, 표면은 여전히 flat하게 유지해줘."
**Expected output 특징**: 캐릭터는 chibi mascot 친근함 유지, BUT 표면은 거의 flat, 그림자 ellipse 1개만, 텍스처 0.

---

### A-V4 — Toca Boca / Among Us Hybrid
**Prompt**:
```
A flat 2D illustration of a round chubby Korean cooking character in Toca Boca world style mixed with Among Us round simplicity, in a square 1:1 format. The character has very round chibi proportions (head to body ratio 1:1.3), wearing a beige apron over an orange hoodie as solid color blocks. They hold a small wooden spatula in round nub hands. Features: two tiny black dot eyes, the mouth is optionally simplified or omitted in Among Us style, no nose. The body is a round circular shape. Pose: three-quarter view, full body standing.

Surface: single color fill, bold 3px outline in dark soy color, no shading, no highlights. Minimal stylization.

Style: Toca Boca character vibe meets Among Us geometric simplicity. Friendly approachable global mobile casual game art. Soft pastel-leaning saturated palette at 70-80 percent. Plain warm cream background.

Important: avoid anime girl style, manga style, big sparkly eyes, school uniforms, fanservice or sexy elements, realistic or photorealistic rendering, 3D render, octane or unreal engine, any texture or noise, painterly or hand-painted feel, watercolor, gradient mesh, multi-layer cel shading, golden hour or dramatic lighting, hyperdetailed elements, individual finger detail, nose detail, tall human proportions, slim body, Japanese (kimono), Chinese (qipao), dark or gritty tones.
```
**Reroll 트리거 (follow-up)**:
- 너무 인간 비율로 빠짐: "이 이미지를 다시 그려줘. 훨씬 더 round chibi 1:1.3 비율로, 둥글둥글한 body와 oversized round head로 강조해줘."
- detail 폭주: "이 이미지를 더 단순하게 다시 그려줘. single color fill만 사용하고, shading 제거, features를 최소화해줘."
**Expected output 특징**: 매우 round + 매우 단순 features + Toca Boca pastel 톤. V2보다 둥글고 친근, V1보다 디테일 적음.

---

## 5. Subject B — 청과상 가게 (4 variant prompt, ChatGPT 자연어)

> 모든 prompt에서 가게 핵심 description은 동일 (Korean traditional market vegetable shop, 시그니처 컬러 cabbage green, 양배추 + 사과 icon, 천막, 좌판, no people, front-facing or slight 3/4 view). **style modifier만 변경**.
> Wide 16:9 landscape format 고정. ChatGPT에 1 image씩 request.

---

### B-V1 — Cookie Run / Chibi Mascot
**Prompt**:
```
A warm friendly illustration of a Korean traditional market vegetable shop storefront in a wide 16:9 landscape format. The signature color is cabbage green. Round green cabbages and red apples are piled in wooden baskets. A striped red-and-blue awning hangs above with a subtle fabric weave texture. The weathered wooden stall shows grain detail. A handwritten paper price tag and a hanging onggi jar accent prop are visible. The shop is empty, waiting for a customer (no people). 

Lighting: golden hour warm directional lighting from upper left. Soft drop shadows under the produce. Gentle highlights on the cabbages. Subtle market warmth conveyed via wooden grain, fabric weave, and paper texture hints.

Style: Cookie Run Kingdom style meets Studio Ghibli market warmth. Korean traditional market (Namdaemun / Gwangjang style). Highly stylized painterly rendering with soft 2-layer shading. Bold 2-3px outline in dark soy color. Saturated 60-70 percent warm palette. Soft cream background sky.

Important: avoid realistic or photorealistic rendering, 3D render, octane or unreal engine, hyperdetailed elements, cinematic or gritty tones, Japanese (Tokyo, Chinatown, kimono, sushi, Fuji), Chinese (qipao, blue-and-white porcelain), anime girl, manga, people, customers, gore or dark elements.
```
**Reroll 트리거 (follow-up)**:
- flat 톤으로 빠짐: "이 이미지를 더 painterly하게 다시 그려줘. golden hour의 warm glow, fabric weave texture hint, soft 2-layer shading을 더 분명하게 살려줘."
- K-touch 누수: "이 이미지를 다시 그려줘. Korean Namdaemun 시장 분위기로 명확히 만들고, Japanese 또는 Chinese 시장 요소(kimono, sushi, qipao, blue-and-white porcelain)를 완전히 제거해줘."
**Expected output 특징**: golden glow + 천막 weave texture hint + 도마 grain + 캐릭터 표면에 부드러운 shading + 시그니처 사이드 prop (옹기, 종이) 추가.

---

### B-V2 — Hyper-Casual Flat
**Prompt**:
```
A flat 2D illustration of a Korean traditional market vegetable shop storefront in hyper-casual mobile game style, in a wide 16:9 landscape format. The single signature color is cabbage green. Only 1-2 large simple icons are shown: a round green cabbage and a red apple. A striped red-and-blue awning above is rendered as flat color blocks with no texture. The simple wooden stall is a brown rectangle. A handwritten price tag appears as a blank cream block. The shop is empty (no people). View: front-facing or slight three-quarter, eye-level.

Surface: geometric rounded shapes, bold 3px black outline, single color fill, no shading, no highlights, no texture, no golden hour. Minimal stylization.

Style: Subway Surfers meets Crossy Road meets Stack aesthetic applied to a Korean traditional market (Namdaemun style). Bold saturated colors at 75-85 percent saturation. Soft cream background sky. Clean minimal composition.

Important: avoid realistic or photorealistic rendering, 3D render, octane or unreal engine, any texture, noise, grain, fabric weave, wooden grain, painterly or hand-painted feel, watercolor, gradient mesh, complex shading, multi-layer cel shading, hyperdetailed elements, cinematic, gritty, golden hour or dramatic lighting, Japanese (Tokyo, Chinatown, kimono, sushi, Fuji), Chinese (qipao, blue-and-white porcelain), anime girl, manga, cluttered composition, any English or Korean text, people, customers.
```
**Reroll 트리거 (follow-up)**:
- texture/painterly 누수: "이 이미지를 더 clean하고 flat하게 다시 그려줘. 모든 texture, painterly 요소, golden hour를 제거하고 단색 color blocks만 남겨줘."
- detail 폭주: "이 이미지를 더 minimal하게 다시 그려줘. 양배추와 사과 1-2개 signature icon만 남기고 나머지 디테일은 제거해줘."
**Expected output 특징**: 양배추 + 사과 2개만, 천막 단색 stripe, shading 0, texture 0, bold saturated.

---

### B-V3 — Cookie Run + Simplified (mid-tone)
**Prompt**:
```
A flat illustration of a warm Korean traditional market vegetable shop storefront with Cookie Run friendly mascot warmth, in a wide 16:9 landscape format. The single signature color is cabbage green. Only 1-2 simple icons: a round green cabbage and a red apple. The striped red-and-blue awning above is rendered as flat color blocks with no texture. A simple wooden stall is a brown rectangle with a very subtle 1-line grain hint only. A blank cream price tag block is visible. The shop is empty (no people). View: front-facing or slight three-quarter.

Surface: single color fill with a very subtle 1-layer ambient shading only (no golden hour, no directional light). Clean flat color with no canvas weave, no fabric texture. Soft drop shadow ellipse under the cabbage pile only. Bold 2-3px outline in dark soy color. Moderate stylization.

Style: Cookie Run Kingdom mascot warmth applied to hyper-casual mobile game simplicity. Korean traditional market (Namdaemun style). Saturated 70-78 percent palette. Soft cream background sky.

Important: avoid realistic or photorealistic rendering, 3D render, octane or unreal engine, any texture, noise, grain, fabric weave, painterly or hand-painted feel, watercolor, gradient mesh, multi-layer cel shading, golden hour or dramatic lighting, hyperdetailed elements, cinematic, gritty, Japanese (Tokyo, Chinatown, kimono, sushi, Fuji), Chinese (qipao, blue-and-white porcelain), anime girl, manga, cluttered composition, any English or Korean text, people, customers.
```
**Reroll 트리거 (follow-up)**:
- V1 톤으로 빠짐: "이 이미지를 더 clean하고 flat하게 다시 그려줘. painterly texture를 모두 제거하고 ambient shading 1-layer만 남겨줘."
- V2 톤으로 빠짐(너무 차가움): "이 이미지를 다시 그려줘. Cookie Run mascot warmth와 friendly market feel을 더 살려주되, 표면은 여전히 flat하게 유지해줘."
**Expected output 특징**: 양배추 + 사과 2개 (V2 수준), 도마 grain hint 1줄만, 천막 단색 stripe, ambient 그림자 ellipse, painterly 텍스처 0.

---

### B-V4 — Toca Boca / Among Us Hybrid
**Prompt**:
```
A flat 2D illustration of a round friendly Korean traditional market vegetable shop in Toca Boca world style, in a wide 16:9 landscape format. The single signature color is cabbage green. A round chubby cabbage and a round red apple are the main icons. The round soft-edged striped awning above is rendered as solid color blocks. A round wooden stall has very soft corners. A blank cream price tag block is visible. The shop is empty (no people). View: front-facing or slight three-quarter, eye-level.

Surface: very rounded geometric shapes everywhere (no sharp angles). Bold 3px outline in dark soy color. Single color fill, no shading, no highlights, no texture. Minimal stylization.

Style: Toca Boca friendly world aesthetic meets Among Us geometric simplicity applied to a Korean traditional market (Namdaemun style). Soft pastel-leaning saturated palette at 70-80 percent. Soft cream background sky. Clean minimal round composition.

Important: avoid realistic or photorealistic rendering, 3D render, octane or unreal engine, any texture, noise, grain, painterly or hand-painted feel, watercolor, gradient mesh, multi-layer cel shading, golden hour or dramatic lighting, hyperdetailed elements, cinematic, gritty, sharp angular shapes, Japanese (Tokyo, Chinatown, kimono, sushi, Fuji), Chinese (qipao, blue-and-white porcelain), anime girl, manga, cluttered composition, any English or Korean text, people, customers.
```
**Reroll 트리거 (follow-up)**:
- 너무 평범 flat (V2 클론): "이 이미지를 다시 그려줘. 모든 corner를 더 둥글게, Toca Boca friendly round world 느낌을 훨씬 강조해줘."
- detail 폭주: "이 이미지를 더 minimal하게 다시 그려줘. main signature icon만 남기고 detail은 제거해줘."
**Expected output 특징**: 모든 shape이 더 둥글고 친근, 의도적으로 부드러운 corner, pastel-leaning saturation, Toca Boca 시리즈 톤.

---

## 6. 사용자 세션 흐름

```
[Step 1] 8 prompt 모두 ChatGPT에 입력 (1 image per request)
              │
              ▼  필요 시 follow-up 대화로 reroll ("make this more flat" 등)
              │
[Step 2] 8 image 다운로드 → 한 화면에 펼쳐 비교
              - Subject A 4컷 row (V1·V2·V3·V4)
              - Subject B 4컷 row (V1·V2·V3·V4)
              - 2 row × 4 column = 2×4 contact sheet (스크린샷 또는 OS 폴더 정렬)
              │
              ▼
[Step 3] §3 비교 평가 기준 5축 (C1~C5)으로 사용자 자가 평가
              - 어느 variant lock? 또는 어느 두 variant hybrid?
              │
              ▼
[Step 4] 결정 → art-director에게 전달 → full session kit v1.x 재작성
              (다음 sprint: 캐릭터 5장 + 환경 5장 anchor 키트)
```

### 6.1 평가 단계에서 사용자 1차 메모 schema (선택)

```
A-V1: <간단 메모, 예: "따뜻하긴 한데 디테일 너무 많음">
A-V2: <"단순한 건 좋은데 차가운 느낌">
A-V3: <"이게 가장 균형 잡힘?">
A-V4: <"너무 둥글둥글, 한식 안 맞음">

B-V1: <...>
B-V2: <...>
B-V3: <...>
B-V4: <...>

종합 선호: V_  (또는 "V3 캐릭터 + V2 환경 hybrid" 같은 조합)
모바일 256px 축소 test: V_가 가장 잘 보임
사용자 직감: V_가 1인 제작 sustainable
```

---

## 7. Step 0 — Subject 통일 anchor (사전 권고)

비교가 의미 있으려면 4 variant 모두 **같은 subject**(주인공 같은 포즈/구도, 청과상 같은 angle)여야 한다. 본 sprint는 다음을 권고한다.

### 7.1 Reference image 사용 여부

| 항목 | 권고 | 이유 |
|------|------|------|
| **Reference image 업로드 사용** | **하지 마라** | V1은 painterly/golden hour, V2는 flat/no shading. reference image 부착하면 한 톤이 다른 톤으로 contamination → 비교 의미 사라짐. ChatGPT는 이미지 업로드 기능을 제공하지만 본 비교 test에선 사용 안 함. |
| **subject anchor 고정** | **prompt 첫 문장으로** | "young Korean cooking character + beige apron + orange hoodie + 3/4 view full body" 같은 캐릭터 description은 4 variant prompt에서 동일 문장으로 유지 (이미 §4 prompt에 반영). |
| **포즈/구도 통일** | **3/4 view full body (Subject A) / front-facing slight 3/4 (Subject B)**로 고정 | 이미 §4·§5 prompt에 반영. |

> **결론**: Step 0 reference image 후보 생성은 본 sprint 범위 외. 8 prompt를 reference 없이 바로 ChatGPT에 입력 → 같은 subject description으로 자연스러운 통일성 확보. 비교 후 lock된 variant로 full kit 진입할 때 그제서야 Step 0 anchor 후보 생성.

### 7.2 Stylization 차등 사유 (ChatGPT 자연어 표현)

- V1: **highly stylized painterly** (painterly 톤 강조)
- V2: **minimal stylization** (flat 단순 톤 유지, default 추가 detail 억제)
- V3: **moderate stylization** (mid-tone)
- V4: **minimal stylization** (단순 round 톤)

> stylization 강도 표현도 variant 정체성의 일부. 동일하게 맞추면 V1 톤이 묻힌다. ChatGPT는 숫자 param이 없으므로 단어 차이로 톤 구분을 유도한다.

---

## 8. 예상 소요 시간 및 비용

| 단계 | 작업 | 시간 |
|------|------|------|
| Step 1 | 8 image generation × ~15s | ~2분 (ChatGPT 1 image per request) |
| Step 2 | 2×4 contact sheet 만들기 (스크린샷 또는 OS 폴더 정렬) | ~10분 |
| Step 3 | §3 5축 자가 평가 | ~10~20분 |
| Step 4 | 결과 art-director 전달 (파일 경로 + 메모) | ~5분 |
| **총합** | | **~30~40분** |

**v1.0 (MJ) 대비 단축**: ~50~65분 → ~30~40분 (**약 30~40% 단축**). 1 image generation 시간 단축(MJ grid ~30~60s → ChatGPT ~10~30s) + upscale 단계 제거(ChatGPT default 고해상도).

**비용**:
- MJ Standard fast hour ~0.7~0.8h ($30/15h = $0.04/h × 0.8h = ~$1.6 sunk) → **ChatGPT Plus $20/월 (DALL-E 무제한) 가정 시 한계 비용 0**
- ChatGPT Pro $200/월은 GPT-4o image priority 처리 (속도 + quality 약간 향상)

> reroll 1~2장 발생 시 +5~10분 (ChatGPT iteration 속도 빠름).

⚠️ **단점**: ChatGPT는 4-grid 없음 → 1 image fail 시 reroll 1회 더 (MJ는 grid 중 best 선택 가능). 단 ChatGPT iteration 속도가 빨라 시간 손실은 미미.

---

## 9. 사용자 체크리스트 (세션 시작 전)

- [ ] ChatGPT Plus 또는 Pro 구독 + 이미지 생성 기능 활성화 확인
- [ ] (Pro 구독 X면) DALL-E 3 무료 제한(일 ~2 image) 확인 — 8장은 1일에 다 못 할 수 있음 → 며칠 분할 또는 Plus 업그레이드
- [ ] 결과 image 저장 경로 정리 (예: `Downloads/kfood-comparison/A-V1.png`, `B-V3.png` 등)
- [ ] 본 문서 한 화면 + ChatGPT 다른 탭
- [ ] 8 prompt 순서: A-V1 → A-V2 → A-V3 → A-V4 → B-V1 → B-V2 → B-V3 → B-V4 (subject 단위로 묶어야 비교 쉬움)
- [ ] 결과 image 한 장도 만족 못 하면 §4·§5 Reroll 트리거 follow-up 문구로 같은 채팅에서 재시도
- [ ] 8 image 완료되면 2×4 contact sheet 만들고 §3 5축 평가
- [ ] 결과 + 선호 variant + 메모를 art-director에게 §6.1 schema로 전달

---

## 10. 비교 후 art-director가 다음 turn에 할 일

1. 사용자가 전달한 8 image 경로 + §6.1 메모 + lock 결정 수신
2. lock된 variant(또는 hybrid 조합)로 **session kit v1.x 재작성**
   - 캐릭터 5장 (CH-01~05) prompt (ChatGPT 자연어 형식)
   - 환경 5장 (BG-01~05) prompt (ChatGPT 자연어 형식)
   - Step 0 anchor 후보 prompt (lock된 톤으로)
   - Reroll follow-up 트리거 갱신
3. **`art-style-guide.md` v1.x 갱신**
   - §1 한 줄 정의 / 레퍼런스 좌표 / 형용사 채택·금지 lock된 variant 기준
   - §2 캐릭터 룰 / §3 환경 룰 / §6 컬러 팔레트 조정
   - §11 anchor 표 갱신 준비
4. **`prompts-library.md` v1.x §0** anchor placeholder 갱신 (lock 후 실제 anchor는 Week 1 sprint에서 채움)
5. CHANGELOG에 art-style lock 결정 + comparison test 결과 한 줄 기록 (main thread 영역, art-director는 별도 메모만 보고)
6. **다음 sprint 예상 시간**: full session kit v1.x + `art-style-guide.md` v1.x 재작성 + `prompts-library.md` v1.x §0 갱신 = **art-director 작업 ~3~5h**

---

## 11. 제약 / 한계

- 이미지 생성은 본 art-director 작업 범위 외 (사용자 ChatGPT 세션 직접 수행).
- 본 v1.1 작성 시점(2026-05-27)에는 comparison test 단일 파일만 ChatGPT 변환됨. 이후 같은 날짜(2026-05-27)에 `art-style-guide.md` v1.1 / `prompts-library.md` v1.1 / `ai-session-kit.md` v1.1 (renamed from `mj-session-kit.md`) / `art-anchor-rubric.md` v1.1 / `art-workload-estimate.md` v4.1 **모두 ChatGPT 영구 sync 완료**.
- v0.2 baseline / v1.0 lock 모두 git에 보존되어 있어 별도 backup 없음.
- 4 variant 중 어느 하나라도 사전 거절 없음. 사용자 비교 결정 우선.
- CHANGELOG / decisions.md / 메모리 본 sprint 범위 외 (main thread 영역).
- ChatGPT는 4-grid variation 미제공 → 1 image 결과가 의도와 다르면 follow-up 대화로 재시도 (시간 trade-off 발생 가능하나 iteration 속도가 빨라 미미).

---

## 12. 변경 이력

- **2026-05-27 v1.1 cross-ref sync (in-place)** — 본 turn에서 cross-ref만 정정: 상위 문서 참조 `mj-session-kit.md` → `ai-session-kit.md` v1.1 (rename 완료), §11 다른 art 문서 5종 ChatGPT 영구 sync 완료 명시 (별도 sprint 이월 → 같은 sprint 완료). 본문(§4·§5 prompt, §6 흐름, §8 시간) 무변경.
- **2026-05-27 v1.1** — ChatGPT (GPT-4o image / DALL-E) conversion. Midjourney param/4-grid/upscale 개념 제거, 자연어 prompt + Avoid 형식 negative + 대화형 reroll로 재구성. 8 prompt 본문(§4·§5) ChatGPT 자연어 문장형으로 전면 재작성 (--ar → "square 1:1 format" 또는 "wide 16:9 landscape format", --stylize 100/150/200 → "minimal/moderate/highly stylized", --niji 6 → "Japanese anime mascot style influence" 자연어 보존, --no X,Y,Z → "Important: avoid X, Y, Z."). Reroll 트리거를 ChatGPT follow-up 대화 형식("이 이미지를 더 X하게 다시 그려줘")으로 갱신. 워크플로(§6) Step 1.5 upscale 제거 (ChatGPT default 고해상도). Step 0 anchor(§7) reference image 업로드 사용 X 권고 유지(variant contamination 회피). 시간(§8) ~50~65분 → ~30~40분 단축 (4-grid 없어 reroll 1회 더 가능성 trade-off). 비용 MJ fast hour ~$1.6 sunk → ChatGPT Plus $20/월 구독 한계 비용 0. 체크리스트(§9) MJ Discord → ChatGPT Plus/Pro 구독 확인 + DALL-E 무료 일 제한 경고. 다음 sprint(§10) full session kit 재작성을 ChatGPT 자연어 prompt 기준으로 명시. §11에 다른 art 문서들의 MJ 가정 sync는 별도 sprint 이월 명시. v1.0 (MJ 기반)은 git diff로 보존. 파일명은 mj-comparison-test.md 유지 (rename은 별도 sprint, 다른 문서 sync와 함께 처리 권장).
- **2026-05-27 v1.0** — 신설. art-style reversal cycle(5/23 mascot lock → 5/24 reject → 5/27 flat lock → 5/27 mascot 복원 제안) 종결용 시각 비교 키트. Subject 2개(주인공 + 청과상) × Style Variant 4개(V1 Cookie Run mascot / V2 Hyper-Casual Flat / V3 Cookie Run + Simplified mid-tone / V4 Toca Boca + Among Us hybrid) = 8 prompt copy-paste ready (Midjourney 기준). §3 5축 평가 기준(C1 첫인상 / C2 모바일 가독성 / C3 캐릭터 표현력 / C4 환경 차별화 / C5 작업 부담 직감). §7 Step 0 sref 사용 X 권고 (variant contamination 방지). §8 예상 ~50~65분 + MJ ~0.7~0.8 fast hour. §10 비교 후 art-director full session kit 재작성 sprint 예고.
