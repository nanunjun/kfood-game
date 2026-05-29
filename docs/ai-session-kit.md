# AI Session Kit — Week 1 Anchor Lock + M1 음식 12 실행 키트 (modern mobile casual, ChatGPT)

> 버전: **v1.3 (2026-05-27, M1 음식 12 세션 추가) — supersedes v1.2**
> 파일명: **`ai-session-kit.md`**
> 작성자: art-director
> 상위 문서: [`art-style-guide.md` v1.2 §10](art-style-guide.md), [`prompts-library.md` v1.3 §3·§4·§5.2](prompts-library.md), [`art-anchor-rubric.md` v1.3](art-anchor-rubric.md)
> 본 문서 범위:
>   - **Week 1 anchor 10장** (캐릭터 5 + 환경 5, §1~§8 v1.2 lock 유지)
>   - **M1 음식 12장 hero shot plated dish** (§M1 v1.3 신설)
> 게이트 통과 = M1/M2 art sprint 진입 prerequisite.

> **v1.3 변경 (2026-05-27, M1 음식 12 세션 추가)**: prompts-library v1.3 음식 12 anchor sync. §M1 신설 — 사용자가 ChatGPT 세션 1~2회로 음식 12장 hero shot plated dish를 실행하는 copy-paste 순서. 생성 순서 = T1 단순 → T2 어려움 (라면 anchor 시드 → 호떡 → ... → 갈비구이 마지막). 예상 소요 ~1.5~2.5h. subject anchor 단어 통일 = "modern mobile casual game food card illustration of Korean [음식명]" 공통. reference image upload = F-01 lock 후 F-02~F-12 모두에 첨부. 결과 인계 schema = food_id / image URL / Round / 평가 메모 12행. §1~§8 (Week 1 anchor 워크플로) 무변경.

> **v1.2 변경 (2026-05-27, modern mobile casual sync)** (archived): iter2 사용자 진단 "올드함" 반영, prompts-library v1.2 sync. Step 0a/0b prompt 갱신, ChatGPT 특화 약점 3종 추가 (베이지/Cookie Run frosting/절구).

---

## 0. 한 줄 목적

> **"art-director가 prompt를 쓰고, 사용자는 ChatGPT에 붙여넣고, art-director가 결과를 채점한다."**
> 본 문서는 사용자가 한 손에 들고 ChatGPT 채팅창에 차례로 붙여넣을 **실행 키트**.

---

## 1. 세션 흐름 (총 3 Step + 평가)

```
[Step 0] subject anchor 정의 + (선택) reference image 후보 2장 먼저 생성
                  │
                  ▼  best 1장씩 → 두 파일 확보 (anchor file 시드)
                  │
[Step 1] 캐릭터 5장 (CH-01~05) 일괄 — 같은 채팅 세션 + 캐릭터 anchor reference upload
[Step 2] 환경 5장 (BG-01~05) 일괄 — 같은 채팅 세션 + 환경 anchor reference upload
                  │
                  ▼
[Step 3] art-director 평가 (G1~G7 rubric, `art-anchor-rubric.md` v1.1)
                  │
                  ▼  종합 LOCK / minor reroll / 재작성 판정
        PASS → prompts-library §0 표에 파일 경로 + subject anchor 문장 영구 기록 → M1 sprint kick-off
        FAIL → 실패 게이트 집중 follow-up reroll, 최대 3 라운드
```

### 1.1 왜 Step 0 anchor를 먼저 뽑나
- ChatGPT는 MJ `--sref` 같은 explicit lock 메커니즘이 없다. 대신 **(a) subject anchor 문장 동일 복사 + (b) reference image upload + (c) 같은 채팅 세션 follow-up** 3축으로 일관성 lock.
- Step 0에서 핵심 1장(주인공)이 정해지면 CH-02~05 reference로 upload. 환경도 BG-01(청과상)이 5가게 톤 anchor.
- **Step 0 건너뛰고 5장 일괄 시**: subject anchor 문장만으로 일관성 강제 → 5장이 다른 IP처럼 보일 확률 ≈ 60% (MJ sref 없는 ChatGPT는 lock 메커니즘 약함).

### 1.2 도구 통일 (v1.0과 차이)

| Step | 대상 | 도구 |
|------|------|------|
| 0a, 1 | 캐릭터 5장 | **ChatGPT (GPT-4o image / DALL-E)** (v1.0은 MJ v6.1) |
| 0b, 2 | 환경 5장 | **ChatGPT** |

> **ChatGPT 단일 도구 통일**: 모델 선택 param 없음 (내부 자동). dual model 운영 risk 0 (도구 특성상 자동 달성). reference image upload + subject anchor 문장으로 캐릭터·환경 일관성 lock.

---

## 2. Step 0 — Anchor 후보 생성 (가장 먼저)

### 2.1 Step 0a — 캐릭터 anchor 후보 (CH-01 주인공)

**왜 주인공이 캐릭터 anchor**: 주인공은 Tier 1 L1부터 L25까지 항상 등장 + CH-04·CH-05 표정 variant base + 어머니/아버지 일관성 anchor. **가장 많이 파생되므로 가장 먼저 lock**.

**ChatGPT 채팅창에 붙여넣기** (v1.2 modern mobile casual prompt, prompts-library §3 CH-01 sync):
```
A modern mobile casual game illustration of a young Korean cooking character in chibi mascot proportions.
The character has a signature bowl-cut black hair (rounded helmet shape), a neutral-friendly excited expression,
two small black dot eyes, a small arc smile, light pink soft cheek blush, no nose.
The character wears a soft white apron over a vibrant orange hoodie and brown shorts.
Dynamic energetic action pose: one foot forward, body slightly tilted, holding a modern enameled frying pan
in the left mitten hand and a small spatula in the right mitten hand, actively stirring food in the pan
with 1-2 motion line streaks indicating movement.
Three-quarter view, full body.
Background is solid soft mint color (#9BE0D2), cool tone, no beige.

Format: square 1:1.
Style: modern mobile casual game character, clean 2D illustration in Royal Match (Dream Games 2021)
modern saturated palette + Subway Surfers chibi energy.
Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), single color fill with optional soft 1-layer cel shading.
Vibrant saturated colors at 80-90 percent saturation, warm/cool palette balance.
Single ambient ellipse shadow under feet.

Important: the character must hold a FRYING PAN with spatula (NOT a mortar and pestle, NOT a 절구).
Hair must be bowl-cut style (rounded black helmet shape).
Avoid beige background, cream paper background, scrapbook, storybook, kraft paper, vintage texture, golden hour,
Cookie Run, Cookie Run Kingdom frosting style, Toca Boca, Toon Blast over-cartoony,
deep dark pink cheek, heavy blush, mortar and pestle, stirring with mortar,
anime girl, manga style, big sparkly eyes, school uniform, fanservice or sexy elements,
realistic or photorealistic rendering, 3D render, octane or unreal engine,
any texture, noise, painterly or hand-painted feel, watercolor, gradient mesh,
multi-layer complex shading, hyperdetailed, individual finger detail, nose detail,
Japanese (kimono), Chinese (qipao), dark, gritty, cinematic,
sleeping, eyes closed peaceful, sad, crying.
```

**절차**:
1. ChatGPT 새 채팅 시작 → 위 prompt 붙여넣고 1 image 생성 (~10~30s)
2. 결과 image 다운로드 → `C:\Projects\kfood-game\assets-raw\2026-05-2x_CH-01_v1.png` 저장
3. (대안) ChatGPT가 생성한 image 우클릭 → "이미지 주소 복사" 또는 채팅 share link 메모
4. `CHAR_ANCHOR_FILE = <파일 경로>` 메모

**판단 기준 (v1.2)** (1 image 결과):
- bowl-cut hair LOCK (다른 헤어스타일 = 탈락)
- 머리:몸 1:1.5~2 범위
- dynamic stirring pose with frying pan + spatula (절구/정적 standing = 탈락)
- 손이 mitten/nub (손가락 5개 또렷 = 탈락)
- 눈이 검정 점 (반짝/홍채 = anime 누수 탈락)
- 의상 saturation 80~90% (muted = 탈락)
- **배경 soft mint cool tone (베이지/크림 = 즉시 탈락 LOCK)**
- cheek = light pink #FFCFCF (deep dark pink Cookie Run 톤 = 탈락)
- slim outline 2~3px (heavy 4px+ = 탈락)
- scrapbook/storybook 톤 없음 (Cookie Run frosting style = 탈락)

**탈락이면 follow-up 대화 reroll** (같은 채팅 세션 안에서):
- 베이지 누수: "이 이미지를 다시 그려줘. 배경을 soft mint (#9BE0D2) cool tone solid color로 교체, 베이지/크림/scrapbook 톤 완전 제거."
- 절구 누수: "이 이미지를 다시 그려줘. 절구(mortar and pestle)를 modern enameled frying pan + spatula로 교체, dynamic stirring pose 유지."
- modernity FAIL: "이 이미지를 더 modern Royal Match (Dream Games 2021) style로 다시 그려줘. Cookie Run frosting style, storybook, scrapbook 톤 완전 제거, clean modern flat + soft 1-layer shading."
- 같은 follow-up 2회 reroll 후에도 탈락이면 §6 트리거 참조.

---

### 2.2 Step 0b — 환경 anchor 후보 (BG-01 청과상)

**왜 청과상이 환경 anchor**: 5가게 중 가장 한식적·시각적으로 풍부 (양배추 round green + 사과 red dot + 천막). Cabbage Green이 베이스 팔레트에서 가장 자연스러운 시그니처.

**ChatGPT 채팅창에 붙여넣기** (v1.2 modern mobile casual prompt, prompts-library §4 BG-01 sync, 새 채팅 권장):
```
A modern mobile casual game illustration of a Korean traditional market vegetable shop storefront,
interpreted with clean modern flat tone (Royal Match aesthetic). The single signature color is vivid cabbage green.
Only 1-2 large simple icons: a round green cabbage and a red apple in clean wooden baskets.
The awning above is solid vivid cabbage green with a single cool sage trim band
(NO red-green-white Italian flag stripes, NO multi-color stripe pattern).
The simple wooden stall is a clean modern brown rectangle (slim grain lines only, no heavy texture).
A small price tag appears as a solid block placeholder (no readable text).
The shop is empty, waiting for a customer (NO people, NO shop owner, NO customers).
Background sky is solid pastel teal (#5FB8C4) light variant or subtle cool gradient (top→bottom cool tone).
Front-facing or slight three-quarter view, eye-level.
Slim bold dark outline 2-3px, single color fill with optional soft 1-layer cel shading.

Format: wide 16:9 landscape.
Style: modern mobile casual game art, clean 2D illustration in Royal Match (Dream Games 2021) aesthetic,
applied to a Korean traditional market interpreted with modern flat clean tone.
Vibrant saturated colors at 80-90 percent saturation, warm/cool palette balance.
Background sky in cool tone (soft mint or pastel teal). NO beige, NO cream paper, NO scrapbook background.

Important: avoid beige background, cream paper background, scrapbook, storybook, kraft paper, vintage texture, golden hour, sunset warm lighting,
Cookie Run, Cookie Run Kingdom frosting style, Toca Boca, Toon Blast over-cartoony,
realistic or photorealistic rendering, 3D render, octane or unreal engine,
any texture, noise, grain, painterly or hand-painted feel, watercolor, gradient mesh,
multi-layer complex shading, hyperdetailed, cinematic, gritty,
Italian flag awning, red-green-white stripes, traditional Korean mortar, mortar and pestle,
Japanese (Tokyo, Chinatown, kimono, sushi, Fuji, noren),
Chinese (qipao, blue-and-white porcelain, chinese lantern),
anime girl, manga, cluttered composition,
any English or Korean text legibly readable (use solid block placeholders only),
people, customers, shop owner.
```

**절차**:
1. ChatGPT 새 채팅 → 위 prompt 붙여넣고 1 image 생성
2. 결과 다운로드 → `BG_ANCHOR_FILE = <파일 경로>` 메모

**판단 기준 (v1.2)**:
- 일본·중국 시장 인상 없음 (간판 placeholder blank block PASS)
- **awning이 solid + 1 trim** (이탈리아 red-green-white stripe = 즉시 탈락 LOCK)
- **배경 sky가 cool tone (pastel teal/soft mint)** — 베이지/크림/golden hour = 즉시 탈락 LOCK
- 가게 시그니처 컬러 cabbage green이 천막/간판/icon에 명확 (채도 80~90%)
- 1~2개 시그니처 icon만 있고 detail 폭주 없음
- 사람 없음 (BG는 빈 가게, no shop owner)
- "재래시장 손맛" texture 없음 (modern flat clean)
- scrapbook/storybook 톤 없음

---

### 2.3 Step 0 완료 체크
- [ ] `CHAR_ANCHOR_FILE` 확보 (1 image 파일)
- [ ] `BG_ANCHOR_FILE` 확보 (1 image 파일)
- [ ] 두 파일 경로 메모장에 저장
- [ ] Step 1·2에서 ChatGPT에 reference image upload + subject anchor 문장 사용

> **주의**: Step 0a 결과를 그대로 CH-01로 채택 가능 (시간 절약). Step 1에서 reference upload + follow-up "이 reference와 같은 features로" 한 번 더 돌리면 안정성 ↑.

---

## 3. Step 1 — 캐릭터 Anchor 5장 (ChatGPT)

> 각 anchor = **prompt 1줄 → 1 image → 파일 저장**.
> CH-02~05 생성 시 `CHAR_ANCHOR_FILE` reference image upload 강력 권장.
> 같은 채팅 세션 안에서 CH-01~05를 순차 follow-up하는 방식도 OK (세션 context로 일관성 일부 유지).

### Anchor CH-01 — 주인공 (base)
- **Prompt**: §2.1 Step 0a와 동일
- **Reference upload**: 없음 (이것이 anchor 시드)
- **Reroll 트리거** (follow-up 대화):
  - G5 단순성 FAIL: "이 이미지를 더 단순하게 다시 그려줘. flat 2D illustration 톤 유지하면서 모든 detail 최소화."
  - G2 비율 FAIL: "이 이미지를 다시 그려줘. 머리:몸 비율 1:1.7 chibi mascot으로 더 강조."
  - G6 (W2 photoreal 누수) FAIL: "이 이미지를 더 flat한 2D illustration으로 다시 그려줘. 3D render, gradient mesh 제거."

> Step 0a 결과를 그대로 CH-01로 채택 가능 (시간 절약).

---

### Anchor CH-02 — 어머니 (base)
- **Reference upload**: `CHAR_ANCHOR_FILE` (Step 0a 주인공) 첨부 → "이 reference와 같은 family IP로"
- **Prompt** (ChatGPT 채팅창에 reference 첨부 후 붙여넣기):
```
이 reference 캐릭터와 같은 flat hyper-casual mobile game style, 같은 outline 두께,
같은 점 눈/호 입 features로, 어머니 캐릭터를 같은 family IP로 그려줘.

A flat 2D illustration of a gentle Korean mother character in chibi mascot proportions, early 50s.
She wears a simple V-collar jeogori top in soft persimmon color over wide-leg navy pants,
with a round bun hairstyle rendered as a simple circle shape on top (no ornament detail).
Warm closed-arc smile, two small black dot eyes, no nose, soft pink cheek blush.
Mitten-style hands hold a small rice bowl. Full body standing pose, three-quarter view.
Single color fill clothing (jeogori in persimmon, pants in navy), bold 3px black outline,
geometric rounded shapes.

Format: square 1:1. Style: flat 2D illustration, hyper-casual mobile game character,
Subway Surfers meets Crossy Road simplicity, no shading, no highlights, no texture,
plain warm cream background, bold saturated 75-85 percent.
Minimal stylization.

Important: avoid anime girl, manga, big sparkly eyes, school uniform, fanservice or sexy,
realistic or photorealistic, 3D render, octane, unreal engine, any texture, noise,
painterly, hand-painted, watercolor, gradient mesh, complex shading, hyperdetailed,
individual finger detail, nose detail, Japanese kimono, geisha, Chinese qipao,
embroidery or pattern on the jeogori (plain solid color only),
dark, gritty, cinematic, golden hour.
```
- **Reroll 트리거** (follow-up):
  - G4 일본 기모노 누수: "이 이미지를 다시 그려줘. 옷섶이 오른쪽으로 여며진 Korean hanbok jeogori V-collar로 명확히, kimono 요소 제거."
  - G1 주인공 페어 깨짐: "이 이미지를 다시 그려줘. reference와 같은 outline 두께, 같은 features 스타일, 같은 컬러 saturation으로 family 일관성 강화."
  - G5 jeogori 자수 폭주: "이 이미지를 다시 그려줘. jeogori를 완전 단색 solid fill로, 자수·무늬 모두 제거."

**ChatGPT 약점 사전 경고 (FLAG)**: ChatGPT의 한복 묘사는 MJ niji 6보다 안정적이나 여전히 기모노 누수 확률 ≈ 25~30%. 옷섶이 왼쪽으로 여며져 있으면 즉시 follow-up reroll.

---

### Anchor CH-03 — 아버지 (base)
- **Reference upload**: `CHAR_ANCHOR_FILE` + CH-02 best image 모두 첨부 → "두 reference와 같은 family IP로"
- **Prompt**:
```
이 두 reference 캐릭터(주인공 + 어머니)와 같은 family IP로, 같은 flat hyper-casual style,
같은 outline 두께·features 톤으로 아버지 캐릭터를 그려줘.

A flat 2D illustration of a kind Korean father character in chibi mascot proportions, early 50s.
He wears a solid brown cardigan over a plain white shirt and beige apron,
with short salt-and-pepper hair rendered as a simple gray-and-black solid shape (no individual strands).
Warm closed-arc smile, two small black dot eyes, no nose, optional soft cheek blush.
Mitten-style hands hold wooden chopsticks. Full body standing pose, three-quarter view.
Single color fill clothing (cardigan in brown, shirt white, apron beige), bold 3px black outline,
geometric rounded shapes.

Format: square 1:1. Style: flat 2D illustration, hyper-casual mobile game character,
Subway Surfers meets Crossy Road simplicity, no shading, no highlights, no texture,
plain warm cream background, bold saturated 75-85 percent.
Minimal stylization.

Important: avoid anime girl, young anime boy or teenager look (this is a mature 50s mascot character),
school uniform, sexy, realistic or photorealistic, 3D render, octane, unreal engine,
any texture, noise, painterly, hand-painted, watercolor, gradient mesh, complex shading,
hyperdetailed, individual finger detail, nose detail, Japanese kimono, Chinese qipao,
thick beard or heavy mustache, dark, gritty, cinematic.
```
- **Reroll 트리거** (follow-up):
  - young anime boy로 빠짐: "이 이미지를 다시 그려줘. 50대 mature father로 강조, salt-and-pepper hair, 절대 teenager/school boy 아님."
  - G1 어머니 페어 깨짐: "이 이미지를 다시 그려줘. 어머니 reference와 같은 family flat art style 강화."
  - G5 머리카락 strand 폭주: "이 이미지를 다시 그려줘. 머리카락을 simple solid color shape 하나로."

---

### Anchor CH-04 — 주인공 Happy (★3 reaction)
- **Reference upload**: `CHAR_ANCHOR_FILE` (Step 0a 주인공) 첨부 강력 권장
- **Prompt**:
```
이 reference 주인공 캐릭터와 정확히 같은 의상(beige apron + orange hoodie), 같은 outline·features 유지,
단 표정만 joyful "wow delicious" happy reaction으로 변경하여 그려줘.

A flat 2D illustration of the same young Korean cooking character (same beige apron over orange hoodie),
showing a joyful "wow delicious" expression. Mouth open in a delighted O-shape,
two upward curved happy arc eyes (smiling, not closed-sad), bright pink cheek blush.
Small simple flat geometric heart and star icons around the head as accent.
Both mitten hands raised to cheeks in delight.
Three-quarter view, bust-up portrait (head and shoulders).
Single color fill, bold 3px black outline.

Format: square 1:1. Style: flat 2D illustration, hyper-casual mobile game character,
Subway Surfers meets Crossy Road simplicity, no shading, no highlights,
plain warm cream background, bold saturated 75-85 percent.
Minimal stylization.

Important: the eyes are upward curved happy arcs (smiling), NOT closed sleeping or sad eyes.
Hearts and stars are simple flat geometric icons in single color (not detailed sparkle effects).
Avoid anime girl, manga, big sparkly eyes, school uniform, sexy, realistic, photorealistic,
3D render, octane, unreal engine, any texture, noise, painterly, hand-painted, watercolor,
gradient mesh, complex shading, hyperdetailed, individual finger detail, nose detail,
Japanese, Chinese, dark, gritty, sleeping, eyes closed peaceful, sad, crying tears, drowsy.
```
- **Reroll 트리거** (follow-up):
  - G1 CH-01 다른 캐릭터: "이 이미지를 다시 그려줘. reference 캐릭터 의상(beige apron + orange hoodie)을 정확히 일치, 같은 outline·features."
  - sleeping/eyes closed로 빠짐: "이 이미지를 다시 그려줘. 눈을 upward curved happy arc(웃는 호)로, 절대 sleeping이나 sad closed 아님."
  - G5 sparkle hearts detail 폭주: "이 이미지를 다시 그려줘. hearts와 stars를 simple flat geometric single color icon으로."

---

### Anchor CH-05 — 주인공 Subtle (★1·★2)
- **Reference upload**: `CHAR_ANCHOR_FILE` (Step 0a 주인공) 첨부 강력 권장
- **Prompt**:
```
이 reference 주인공 캐릭터와 정확히 같은 의상·outline·features 유지,
단 표정만 soft satisfied subtle reaction으로 변경하여 그려줘.

A flat 2D illustration of the same young Korean cooking character (same beige apron over orange hoodie),
showing a soft satisfied small arc smile with a slight head tilt.
Two small black dot eyes (open, looking forward, alert), optional soft pink cheek blush.
No stars, no hearts.
One mitten hand near chin in a "hmm tasty" gesture.
Bust-up portrait, three-quarter view.
Single color fill, bold 3px black outline.

Format: square 1:1. Style: flat 2D illustration, hyper-casual mobile game character,
Subway Surfers meets Crossy Road simplicity, no shading, no highlights,
plain warm cream background, bold saturated 75-85 percent.
Minimal stylization.

Important: the eyes are open as two small black dots, looking forward and alert.
Avoid anime girl, manga, big sparkly eyes, school uniform, sexy, realistic, photorealistic,
3D render, octane, unreal engine, any texture, noise, painterly, hand-painted, watercolor,
gradient mesh, complex shading, hyperdetailed, individual finger detail, nose detail,
Japanese, Chinese, dark, gritty, sleeping, eyes closed peaceful, sad, crying.
```
- **Reroll 트리거** (follow-up):
  - sleeping 누수: "이 이미지를 다시 그려줘. 눈을 open 상태(두 개의 검정 점)로, alert content expression, 절대 sleeping/closed 아님."
  - 슬픔 표정으로 빠짐: "이 이미지를 다시 그려줘. gentle satisfied smile, mildly positive, content expression."

---

### 3.6 양친 reaction variant placeholder (본 sprint 범위 외)

> **U-2 결정**: 어머니/아버지 L11 동시 unlock. reaction 6컷 = 어머니 ★1/2/3 + 아버지 ★1/2/3.
> **본 sprint(Week 1)는 base anchor(CH-02 + CH-03)만 lock**. reaction 6컷은 후속 sprint(M1 초)에서 CH-02·CH-03 image를 reference upload하여 생성.

| 후속 variant ID | Subject | 상속 anchor |
|----------------|---------|------------|
| CH-02-S | 어머니 Subtle (★1·★2) | CH-02 lock image |
| CH-02-H | 어머니 Happy (★3) | CH-02 lock image |
| CH-03-S | 아버지 Subtle (★1·★2) | CH-03 lock image |
| CH-03-H | 아버지 Happy (★3) | CH-03 lock image |
| (CH-04, CH-05) | 주인공 본 sprint | 본 sprint CH-04·05 |

> 6컷 = (어머니 S+H) + (아버지 S+H) + (주인공 본 sprint CH-04·05) = 6컷.
> 모든 reaction prompt에 sleeping 회피 negative 필수.

---

## 4. Step 2 — 환경 Anchor 5장 (ChatGPT)

> 모든 BG는 **빈 가게 (no people)**. BG-02~05 생성 시 `BG_ANCHOR_FILE` reference image upload 권장.
> 5장은 같은 시장 안 옆가게로 인식 (G1). 새 채팅 세션 시작 권장 (캐릭터/환경 분리).

### Anchor BG-01 — 청과상 🥬 (Cabbage Green)
- **Reference upload**: 없음 (이것이 환경 anchor 시드)
- **Prompt**: §2.2 Step 0b와 동일
- **Reroll 트리거** (follow-up):
  - G5 detail 폭주: "이 이미지를 더 minimal하게 다시 그려줘. signature icon 1-2개만 남기고 나머지 제거."
  - G4 일본 시장: "이 이미지를 다시 그려줘. Korean Namdaemun 시장 분위기로, Japanese/Tokyo 요소 제거."
  - G6 (W2/W3) texture/painterly 누수: "이 이미지를 더 clean한 flat color blocks로 다시 그려줘. texture, painterly 제거."

> Step 0b 결과를 그대로 BG-01로 채택 가능.

---

### Anchor BG-02 — 정육점 🥩 (Gochu Red)
- **Reference upload**: `BG_ANCHOR_FILE` (Step 0b 청과상) 첨부 → "이 reference 가게와 같은 시장 안 옆가게로"
- **Prompt**:
```
이 reference 가게와 같은 시장 안 옆가게로, 같은 outline 두께, 같은 천막 shape,
같은 컬러 톤 (saturation 75-85%)으로 정육점을 그려줘.

A flat 2D illustration of a Korean traditional market butcher shop storefront,
hyper-casual mobile game style. The single signature color is bold red.
Only 1-2 large simple icons: a red round lantern hanging and a brown wooden cutting board.
A striped red awning above is rendered as flat color blocks.
A simple white tile back wall is a flat block. A handwritten price tag appears as a blank cream block.
The shop is empty, waiting for a customer (no people, no animals, no meat shown explicitly).
Front-facing or slight three-quarter view, eye-level.
Geometric rounded shapes, bold 3px black outline, single color fill.

Format: wide 16:9 landscape. Style: flat 2D illustration, hyper-casual mobile game art,
Subway Surfers meets Crossy Road aesthetic, Korean traditional market (Namdaemun style),
bold saturated 75-85 percent (red bold but not neon), soft cream background sky,
clean minimal composition. Minimal stylization.

Important: clean family-friendly mobile game art with no blood, no carcass, no raw meat, no gore.
Only lantern and cutting board are visible as signature icons.
Avoid realistic, photorealistic, 3D render, octane, unreal engine, any texture, noise, grain,
painterly, hand-painted, watercolor, gradient mesh, complex shading, hyperdetailed, cinematic, gritty,
Japanese (Tokyo, Chinatown, kimono, sushi), Chinese (qipao, blue-and-white porcelain, chinese lantern),
anime girl, manga, cluttered, any English or Korean text legibly readable, people, customers.
```
- **Reroll 트리거** (follow-up):
  - 잔혹 묘사: "이 이미지를 다시 그려줘. family-friendly, no blood, no carcass, only lantern과 cutting board만."
  - G3 빨강 100% 채도: "이 이미지를 다시 그려줘. 빨간 색을 75-80 percent saturation으로 (not neon)."

**ChatGPT 약점 사전 경고**: ChatGPT는 정육점에 사실적 고기 표현 추가 확률 ≈ 25~30% (MJ v6.1 25%와 유사). 통 카르카스·핏물 보이면 즉시 follow-up reroll.

---

### Anchor BG-03 — 어물전 🐟 (Sea Blue)
- **Reference upload**: `BG_ANCHOR_FILE` 첨부
- **Prompt**:
```
이 reference 가게와 같은 시장 안 옆가게로, 같은 outline·천막 shape·컬러 톤으로 어물전을 그려줘.

A flat 2D illustration of a Korean traditional market seafood shop storefront,
hyper-casual mobile game style. The single signature color is sea blue.
Only 1-2 large simple icons: one stylized cute fish silhouette and a white ice block.
A blue-striped awning above is rendered as flat color blocks.
The shop is empty (no people; the fish is a simplified cute icon, not realistic).
Front-facing or slight three-quarter view, eye-level.
Geometric rounded shapes, bold 3px black outline, single color fill.

Format: wide 16:9 landscape. Style: flat 2D illustration, hyper-casual mobile game art,
Subway Surfers meets Crossy Road aesthetic, Korean traditional market (Namdaemun style),
bold saturated 75-85 percent, soft cream background sky, clean minimal composition.
Minimal stylization.

Important: this is a Korean seafood market, NOT Japanese sushi shop, NOT Tsukiji.
Fish icon is simplified cute geometric shape, friendly hyper-casual mobile game style.
Avoid dead-eye fish, bloody fish, raw sashimi, realistic, photorealistic, 3D render, octane,
unreal engine, any texture, noise, grain, painterly, hand-painted, watercolor, gradient mesh,
complex shading, hyperdetailed, cinematic, gritty,
Japanese (Tokyo, Chinatown, kimono, sushi, Fuji), Chinese (qipao, blue-and-white porcelain),
anime girl, manga, cluttered, any English or Korean text legibly readable, people, customers.
```
- **Reroll 트리거** (follow-up):
  - G4 일본 스시집: "이 이미지를 다시 그려줘. Korean seafood market, NOT Japanese sushi shop, NOT Tsukiji."
  - 비린 사실적 묘사: "이 이미지를 다시 그려줘. fish를 simplified cute geometric icon으로."

---

### Anchor BG-04 — 곡물상 🌾 (Grain Tan)
- **Reference upload**: `BG_ANCHOR_FILE` 첨부
- **Prompt**:
```
이 reference 가게와 같은 시장 안 옆가게로, 같은 outline·천막 shape·컬러 톤으로 곡물상을 그려줘.

A flat 2D illustration of a Korean traditional market grain shop storefront,
hyper-casual mobile game style. The single signature color is warm tan.
Only 1-2 large simple icons: a tan burlap sack trapezoid and a brown wooden scoop.
A warm cream awning above is rendered as flat color blocks.
The shop is empty (no people).
Front-facing or slight three-quarter view, eye-level.
Geometric rounded shapes, bold 3px black outline, single color fill.

Format: wide 16:9 landscape. Style: flat 2D illustration, hyper-casual mobile game art,
Subway Surfers meets Crossy Road aesthetic, Korean traditional market (Namdaemun style),
bold saturated 75-85 percent (vary tan/brown/cream with red bean sack accent),
soft cream background sky, clean minimal composition.
Minimal stylization.

Important: burlap sacks are simple geometric trapezoid shapes with minimal detail (no burlap weave texture).
Avoid all-yellow flat look, realistic, photorealistic, 3D render, octane, unreal engine,
any texture, noise, grain, painterly, hand-painted, watercolor, gradient mesh, complex shading,
hyperdetailed, cinematic, gritty, Japanese, Chinese, anime girl, manga, cluttered,
any English or Korean text legibly readable, people, customers.
```
- **Reroll 트리거** (follow-up):
  - G3 전체 노랑 단일: "이 이미지를 다시 그려줘. tan, brown, cream의 다양한 톤으로, red bean sack을 accent dot으로."
  - G5 마대 detail 폭주: "이 이미지를 다시 그려줘. burlap sack을 simple geometric trapezoid로, weave texture 제거."

---

### Anchor BG-05 — 잡화점 🫙 (Jang Brown)
- **Reference upload**: `BG_ANCHOR_FILE` 첨부 (강력 권장 — 옹기/도자기 누수 high freq)
- **Prompt**:
```
이 reference 가게와 같은 시장 안 옆가게로, 같은 outline·천막 shape·컬러 톤으로 잡화점(japhwajeom)을 그려줘.

A flat 2D illustration of a Korean traditional market general goods shop storefront (japhwajeom),
hyper-casual mobile game style. The single signature color is jang brown.
Only 1-2 large simple icons: a large brown round-bottom Korean onggi pottery jar (dark brown earthen)
and a smaller seasoning bottle.
A warm brown awning above is rendered as flat color blocks.
The shop is empty (no people).
Front-facing or slight three-quarter view, eye-level.
Geometric rounded shapes, bold 3px black outline, single color fill.

Format: wide 16:9 landscape. Style: flat 2D illustration, hyper-casual mobile game art,
Subway Surfers meets Crossy Road aesthetic, Korean traditional market (Namdaemun style),
bold saturated 75-85 percent, soft cream background sky, clean minimal composition.
Minimal stylization.

Important: the onggi is a Korean dark brown earthen jar with rounded bottom,
NOT a Chinese vase, NOT Japanese ceramic, NOT blue-and-white porcelain.
The onggi color is warm dark brown (jang brown signature), not pure black.
Avoid realistic, photorealistic, 3D render, octane, unreal engine, any texture, noise, grain,
painterly, hand-painted, watercolor, gradient mesh, complex shading, hyperdetailed, cinematic,
gritty, Japanese (kimono, sushi), Chinese (qipao, blue-and-white porcelain, chinese vase),
anime girl, manga, cluttered, any English or Korean text legibly readable, people, customers.
```
- **Reroll 트리거** (follow-up):
  - G4 중국 청화백자 / 일본 도자기: "이 이미지를 다시 그려줘. Korean onggi pottery, dark brown earthen jar with rounded bottom으로. NOT Chinese vase, NOT Japanese ceramic, NOT blue-and-white porcelain."
  - G3 옹기 순흑: "이 이미지를 다시 그려줘. onggi를 warm dark brown (jang brown signature)으로, 순흑 아님."

**ChatGPT 약점 사전 경고**: ChatGPT는 "pottery jar"를 중국 청화백자·일본 도자기로 그릴 확률 ≈ 30~35% (MJ v6.1 30%와 유사). 첫 시도에서 푸른 무늬·매끈 흰 도자기면 즉시 follow-up reroll.

---

## 5. Step 3 — 결과 평가 (art-director 인계)

### 5.1 사용자 인계 schema

각 anchor(10 + Step 0 후보 2 = 12세트)에 대해 다음 1세트:

```
Anchor ID: CH-01 (또는 BG-03 등)
ChatGPT 세션 URL: https://chatgpt.com/c/... (share link 또는 채팅 URL)
이미지 파일 경로: C:\Projects\kfood-game\assets-raw\2026-05-2x_CH-01_v1.png
subject anchor 문장 (실제 prompt에 사용한 한 줄): "young Korean cooking character wearing beige apron over orange hoodie, ..."
Reference image upload 사용 여부: yes (Step 0a 파일 첨부) / no
Round (R1 / R2 / R3): R1
follow-up 횟수 (reroll): 0 / 1 / 2
사용자 1차 평가 메모 (선택): "어머니가 약간 일본 느낌, 판정 부탁"
```

**전체 묶음 권장**: 메모장 또는 마크다운 1장에 12개 블록.

### 5.2 art-director가 다음 turn에 할 일
1. 12장(12세트)을 [`art-anchor-rubric.md` v1.1](art-anchor-rubric.md) §3 표에 채워 PASS/FAIL/CONDITIONAL
2. **종합 LOCK 조건**: 10 anchor 중 최소 8 LOCK + anchor 시드 2 PASS → Week 1 게이트 통과
3. PASS → `prompts-library.md` v1.1 §0 표에 파일 경로/subject anchor 문장/ChatGPT 세션 URL 영구 기록 → `art-style-guide.md` v1.1 §11 anchor 표 갱신 → M1 sprint kick-off
4. FAIL → §6 트리거 처방 → 사용자에게 follow-up reroll 키트 재발급

---

## 6. Reroll 트리거 매핑 (게이트 FAIL → follow-up 조정)

| FAIL 게이트 | 증상 | follow-up 대화 |
|------------|------|---------------|
| **G1 일관성** | 5장이 다른 IP | "이 이미지를 다시 그려줘. reference image와 같은 outline 두께·features 톤·컬러 saturation으로 family/같은 시장 일관성 강화." + reference image 재첨부 |
| **G2 비율·단순** | 머리:몸 1:1 또는 1:3 / 가게 shape 5개+ | "이 이미지를 다시 그려줘. 머리:몸 1:1.7 chibi mascot 강조, 머리를 키우고 몸을 작게" / "signature icon 1-2개만 남기고 detail 모두 제거" |
| **G3 컬러** | 채도 100% 또는 30% 미만 | "이 이미지를 다시 그려줘. bold saturated 75-85 percent, not neon, not muted으로 컬러 톤 조정" |
| **G4 K-touch** | 일본·중국 인상 | "이 이미지를 다시 그려줘. Korean traditional market (Namdaemun, Gwangjang)으로 명확히, NOT Japanese, NOT Chinese 강조" |
| **G5 단순성 (Crossy Road test)** | 디테일 폭주 / shading 누수 / texture | "이 이미지를 더 단순하게 다시 그려줘. flat design, single color fill, NO shading, NO texture, minimal detail, Crossy Road aesthetic" |
| **G6 ChatGPT 약점 (flat 특화)** | (아래 6.1 참조) | (각 항목별) |
| **G7 모바일 가독성** | 256px 축소 시 features 안 보임 / outline 너무 얇음 | "이 이미지를 다시 그려줘. bold 3-4px outline, high contrast colors, mobile small screen에서 잘 보이게" |

### 6.1 G6 ChatGPT 약점 세분화 (flat 특화) — 즉시 follow-up reroll 트리거

| 약점 | 증상 | 즉시 follow-up |
|------|------|---------------|
| W1 한글 텍스트 깨짐 | 간판/가격표 가짜 한자/글리프 | "이 이미지를 다시 그려줘. 간판/가격표를 blank cream block placeholder로, no readable text" (또는 Photoshop 후보정) |
| W2 photoreal 누수 | photoreal/3D render 톤 | "이 이미지를 더 flat한 2D illustration으로 다시 그려줘. 3D render, octane, unreal 제거" |
| W3 painterly 누수 | hand-painted/watercolor 톤 | "이 이미지를 더 clean한 flat design으로 다시 그려줘. painterly, watercolor 톤 제거, single color fill만" |
| W4 손가락 detail | 5개 손가락 또렷 | "이 이미지를 다시 그려줘. 손을 mitten으로, no individual fingers visible" |
| W5 일본 인상 | 기모노·후지산·sushi | "이 이미지를 다시 그려줘. Korean style로 명확히, NOT Japanese, NOT kimono, NOT sushi, NOT Fuji" |
| W6 중국 인상 | 청화백자·치파오·중국 등롱 | "이 이미지를 다시 그려줘. Korean onggi 또는 한국 시장 톤으로, NOT Chinese, NOT chinatown, NOT qipao, NOT blue-and-white porcelain" |
| W7 복잡 composition (multi-character 누수) | 캐릭터 2명+ 가게/소품 동시 | "이 이미지를 다시 그려줘. single subject만, 캐릭터/가게 따로 그리기" |
| W8 prompt 길이 한계 | 일부 modifier 무시됨 | follow-up 짧게 분할 — 한 번에 1~2 modifier만 강조 |
| W9 캐릭터 일관성 lock 실패 | reference와 다른 캐릭터 | reference image 재첨부 + "reference 캐릭터의 outline 두께·features·컬러 톤을 정확히 유지" |
| W10 anime girl / 정면 over-detail | 큰 반짝 눈 + 교복 | "이 이미지를 다시 그려줘. simple two black dot eyes, minimal facial features, NO sparkle eyes, NO school uniform" |

---

## 7. 예상 소요 시간 (flat 톤, ChatGPT, 1차 시도 기준)

| 단계 | 작업 | 예상 시간 |
|------|------|----------|
| Step 0a | 캐릭터 anchor 후보 (1 image) | 3~7분 (ChatGPT 1 image ~10~30s + 평가) |
| Step 0b | 환경 anchor 후보 (1 image) | 3~7분 |
| Step 1 | 캐릭터 5장 × (1 image + 평가) | 15~25분 (Step 0a를 CH-01로 채택 가능 시 -3~5분) |
| Step 2 | 환경 5장 × (1 image + 평가) | 15~25분 |
| 파일 저장/메모 정리 | 메모장 정리, 파일 경로 기록 | 10분 |
| **총합 (reroll 없이 1차)** | | **45~75분 (≈ 0.75~1.25시간)** |

**reroll 포함 현실 예상**: ChatGPT는 4-grid 없어 1 image fail 시 follow-up 1회 더 필요 (MJ는 grid 중 best 선택 가능). 평균 2~3장 follow-up 필요 → **+15~25분** → **총 ~1~1.5시간** (MJ 1.5~2.5시간 대비 -25~40%).

> 4-grid 손실 trade-off vs 자연어 iteration 속도 + DALL-E 무제한 한계 비용 0 + ChatGPT 1 image 생성 속도 빠름(~10~30s vs MJ grid ~30~60s)으로 시간 단축 효과.
> **ChatGPT Plus $20/월** 한계 비용 0 (DALL-E 무제한). MJ Standard $30/월 fast hour 소비 제약 없음.

### 7.1 까다로움 사전 경고 (flat 톤, ChatGPT 특화)

| 경고 | 빈도 | 대응 |
|------|------|------|
| **한글 텍스트 ~100% 깨짐** | Very High | blank block placeholder 강제, 모든 텍스트 Photoshop 후보정 |
| **photoreal 누수** (ChatGPT default detail 추가 경향) | High | "flat 2D illustration, NO photorealistic, NO 3D" 강제. R1에서 1~2장 follow-up 예상. |
| **painterly / watercolor 누수** (ChatGPT illustration default) | Med~High | "flat design, single color fill, NO painterly" 강제. |
| **texture noise 누수** | Med | "clean flat color, NO texture, NO noise" 강제. |
| **한식 → 일본/중국 누수** (옹기/한복/시장) | Med~High | K-touch 키워드 강화 (Namdaemun, jeogori, onggi). G4 R1에서 1~2장 follow-up 예상. |
| **캐릭터 일관성 lock 실패** (sref 부재) | High | reference image upload 필수 + subject anchor 문장 동일 복사 + 같은 채팅 세션 follow-up 3축 운영 |
| **cut style 6종 (M1 sprint)** = simple shape 변화 표현 → ChatGPT over-render 가능성 | Med | M1 진입 시 cut anim 별도 키트에서 frame 단위 prompt + 같은 채팅 세션 follow-up + "only shape change, minimal detail" 강제 |
| **베이지/크림 배경 default 강함 (v1.2 신설)** | **Very High** | ChatGPT는 illustration default로 warm beige/cream paper 톤을 강하게 추가하려 함. "solid soft mint (#9BE0D2) cool tone background, NO beige, NO cream paper" 본문+negative 양쪽 강제. follow-up 1~2회 reroll 예상. |
| **Cookie Run frosting style 누수 (v1.2 신설)** | Med | ChatGPT가 chibi mascot 톤에 sugar-coated frosting/sparkle 추가 경향. "modern Royal Match aesthetic, NOT Cookie Run, NO frosting, NO sparkle" 강제. |
| **절구 traditional 누수 (v1.2 신설)** | Med | "Korean cooking character"에 ChatGPT가 절구(mortar and pestle) 추가 경향. "holding a modern enameled frying pan with spatula, NO mortar, NO pestle, NO 절구" 강제. |

---

## 8. 사용자 체크리스트 (세션 시작 전 확인)

- [ ] **ChatGPT Plus $20/월 구독 완료** (DALL-E 무제한 사용 가능) — MJ Standard 결제 X, main thread가 다음 billing 전 취소 권고 예정
- [ ] ChatGPT 이미지 생성 기능 활성화 확인 (GPT-4o image / DALL-E 3)
- [ ] 메모장 열어두기 — 파일 경로/subject anchor 문장/ChatGPT 세션 URL 12세트 기록
- [ ] 본 문서 한 화면 + ChatGPT 다른 탭/창
- [ ] Step 0부터 순서대로 (Step 1 먼저 시작하면 reference upload anchor 없음)
- [ ] anchor 결과 image를 `C:\Projects\kfood-game\assets-raw\` 폴더에 저장 (날짜 + anchor ID 명명: `2026-05-2x_CH-01_v1.png`)
- [ ] CH-01·02·03 한 세션 / CH-04·05 한 세션 / BG-01~05 한 세션 권장 (ChatGPT context 일관성)
- [ ] 1 image 결과가 의도와 다르면 같은 채팅에서 follow-up "이 이미지를 더 X하게 다시 그려줘" → 안 되면 §6 트리거 참조
- [ ] 모든 결과 파일 경로/세션 URL을 art-director에게 §5.1 schema로 묶어 전달

---

---

## M1 — 음식 12 Anchor 세션 가이드 (v1.3 신설)

> Week 1 anchor 10장 lock candidate 이후 진행. **Week 1 lock candidate evaluation과 병행 진행 가능** (다른 anchor 사용 — 음식 카드는 캐릭터 anchor에 reference 의존 X).
> 본 §M1은 사용자가 ChatGPT 세션 1~2회로 12장 음식 hero shot plated dish를 실행하는 키트.

### M1.1 한 줄 목적

> **"라면 anchor 1장 lock → 그 image reference upload + 11개 prompt copy-paste → 12장 식탁 plated dish 완성."**

### M1.2 세션 흐름 (총 2 Step + 평가)

```
[M1 Step 0] F-01 Ramyeon anchor 시드 lock (1 image)
                  │
                  ▼  best 1장 → FOOD_ANCHOR_FILE 확보
                  │
[M1 Step 1] T1 음식 6장 follow-up (F-02 Hotteok ... F-07 Pajeon) — 한 세션 / FOOD_ANCHOR_FILE reference upload
[M1 Step 2] T2 음식 5장 follow-up (F-08 Bibimbap ... F-12 Galbi-gui) — 새 세션 / FOOD_ANCHOR_FILE reference upload
                  │
                  ▼
[M1 Step 3] art-director 평가 (G1~G7 + G_new + G_food, art-anchor-rubric.md §5.5 음식 평가 적용)
                  │
                  ▼  종합 LOCK / minor reroll / 재작성 판정
        PASS → prompts-library §0 표 F-01~F-12 행 영구 기록 → M1 ingredient/UI sprint kick-off
        FAIL → 실패 음식 집중 follow-up reroll, 최대 3 라운드
```

### M1.3 도구 통일

| Step | 대상 | 도구 |
|------|------|------|
| M1 Step 0 | F-01 Ramyeon anchor 시드 (1 image) | **ChatGPT (GPT-4o image / DALL-E 3)** |
| M1 Step 1 | T1 음식 6장 (F-02~F-07) follow-up | ChatGPT + FOOD_ANCHOR_FILE reference upload |
| M1 Step 2 | T2 음식 5장 (F-08~F-12) follow-up | ChatGPT + FOOD_ANCHOR_FILE reference upload (새 세션) |

> **세션 분기 권장**: 한 세션 안 12장 follow-up은 ChatGPT context 한계 (~6장 안정). **T1 6장 한 세션 + T2 5장 한 세션** 분리 권장. 새 세션 시작 시 FOOD_ANCHOR_FILE 재upload.

### M1.4 생성 순서 (난도 오름차순 + 한식↔타국 risk 고려)

| 순서 | 슬롯 | 음식 (English) | Tier | 난도 / 누수 risk |
|-----|------|---------------|------|-----------------|
| 1 (anchor 시드) | F-01 | **Ramyeon** | T1 | 쉬움 / 일본 ramen 누수 M |
| 2 | F-02 | Hotteok | T1 | 쉬움 / 누수 L |
| 3 | F-04 | Tteokbokki | T1 | 중간 / 중식 nian gao 누수 M |
| 4 | F-05 | Kimchi Fried Rice | T1 | 중간 / **중식 fried rice 누수 HIGH** |
| 5 | F-07 | Haemul Pajeon | T1 | 중간 / 일본 okonomiyaki 누수 H |
| 6 | F-09 | Kimchi Jjigae | T2 | 중간 / **중식 hot pot 누수 HIGH** |
| 7 (T2 새 세션) | F-10 | Sundubu Jjigae | T2 | 중간 / 중식 mapo tofu 누수 M |
| 8 | F-03 | Kimbap | T1 | 어려움 / **일본 maki sushi 누수 VERY HIGH** |
| 9 | F-08 | Bibimbap | T2 | 어려움 / Western Buddha bowl 누수 M |
| 10 | F-11 | Japchae | T2 | 어려움 / **중식 lo mein 누수 VERY HIGH** |
| 11 | F-06 | Korean Corn Dog | T1 | 어려움 / **미국 corn dog 누수 VERY HIGH** |
| 12 | F-12 | Galbi-gui | T2 | 가장 어려움 / **일본 야키니쿠 + 미국 BBQ 누수 VERY HIGH** |

> **세션 분기 권장 cut**: 1~6 한 세션 / 7~12 새 세션 (위 6항이 T2 + 어려운 risk 후순위로 한 세션).

### M1.5 M1 Step 0 — F-01 Ramyeon anchor 시드 (가장 먼저)

**왜 라면이 음식 anchor**: 시각 단순 (그릇 + 면 + 국물 + 노른자), 글로벌 SS 인지도, FTUE 2순위. 11장 reference 시드로 plate/bowl 스타일 통일.

**ChatGPT 채팅창에 붙여넣기** (prompts-library §5.2 F-01 + STYLE_SUFFIX_FOOD 풀어쓴 형태):
```
A modern mobile casual game food card illustration of Korean Ramyeon (spicy noodle soup), top-down view.
A white round porcelain bowl (Korean baekja style, clean white, NOT black Japanese ramen bowl) is filled
with vibrant orange-red spicy gochugaru broth. Yellow wavy curly egg noodles emerge from the broth
in a soft swirl (Korean instant ramyeon style, NOT straight Japanese ramen noodles).
A single sunny-side-up egg with a bright yellow yolk sits in the center.
3-5 small green spring onion (pa) chopped dots float on the surface as garnish.
One small red chili pepper slice as accent.
Single subtle ambient ellipse shadow under the bowl.

Format: square 1:1.
View: top-down (overhead) — Royal Match food card aesthetic.
Style: modern mobile casual game food card, clean 2D illustration in Royal Match (Dream Games 2021)
plated dish aesthetic. Hero shot of a finished plated Korean dish.
Slim bold dark outline 2-3px (warm dark #2D1D14), single color fill with optional soft 1-layer cel shading
and one small specular highlight on the broth surface (juicy appetite).
Vibrant saturated colors at 80-90 percent saturation, warm food + cool plate balance.
Background is solid Cool Sage (#C8D5C0) cool tone.

Important: this is Korean Ramyeon, NOT Japanese ramen, NOT miso ramen, NOT tonkotsu.
The broth is bright vibrant orange-red (gochugaru spicy), NOT brown miso, NOT pale white tonkotsu.
The noodles are visibly curly wavy yellow, NOT straight thin Japanese ramen noodles.
The bowl is clean white Korean baekja, NOT a black Japanese donburi bowl with bamboo accents.
NO narutomaki pink spiral fish cake, NO nori seaweed sheet on top, NO chashu pork slices.
Avoid beige background, cream paper background, scrapbook, storybook, kraft paper, vintage texture,
golden hour, sunset warm lighting, Cookie Run frosting style, Toca Boca, Toon Blast over-cartoony,
realistic or photorealistic, 3D render, octane, unreal engine, food photography,
any texture, noise, grain, painterly, hand-painted, watercolor, gradient mesh,
multi-layer complex shading, hyperdetailed, cinematic, gritty,
human characters, hands holding the food, cooking action, kitchen environment background,
any English or Korean text legibly readable on the dish.
```

**절차**:
1. ChatGPT 새 채팅 시작 → 위 prompt 붙여넣고 1 image 생성 (~10~30s)
2. 결과 image 다운로드 → `C:\Projects\kfood-game\assets-raw\2026-05-2x_F-01_v1.png` 저장
3. `FOOD_ANCHOR_FILE = <파일 경로>` 메모

**판단 기준** (1 image 결과):
- bowl 흰 백자 (검정 Japanese donburi = 탈락)
- 면 꼬불꼬불 curly (직선 thin = 탈락)
- broth bright orange-red (갈색 miso/흰 tonkotsu = 탈락)
- 노른자 중앙 1개 (없음 = 탈락)
- bg Cool Sage `#C8D5C0` 또는 Cream-white (베이지/scrapbook = 즉시 탈락)
- saturation 80~90% (muted = 탈락)
- slim outline 2~3px (heavy 4px+ = 탈락)
- no characters/hands (캐릭터 등장 = 탈락)
- narutomaki/nori/chashu 없음 (등장 = 탈락)

**탈락 시 follow-up reroll** (같은 채팅 세션):
- 일본 ramen 누수: "이 이미지를 다시 그려줘. Korean Ramyeon으로 명확히 — 흰 백자 bowl + 꼬불꼬불 curly yellow noodles + bright orange-red gochugaru broth. NOT Japanese ramen, NOT miso, NOT tonkotsu, NOT narutomaki, NOT chashu, NOT nori sheet."
- 베이지 누수: "이 이미지를 다시 그려줘. 배경을 Cool Sage `#C8D5C0` solid color로 교체, 베이지/크림/scrapbook 톤 완전 제거."
- 캐릭터 누수: "이 이미지를 다시 그려줘. NO characters, NO hands, NO cooking action. 식탁 위 plated dish hero shot만."

### M1.6 M1 Step 1 — T1 음식 6장 follow-up (F-02~F-07, F-09 포함)

> 같은 채팅 세션 안에서 FOOD_ANCHOR_FILE을 첫 message에 첨부 → 각 음식 prompt를 차례로 follow-up.

**세션 시작 message** (FOOD_ANCHOR_FILE 첨부 후):
```
이 reference image는 우리 게임의 음식 카드 anchor야. 흰 백자 bowl / Cool Sage 배경 / slim 2-3px outline /
saturation 80-90% / no characters / Korean K-food plated hero shot 톤을 유지해. 다음 11개 음식 카드를
같은 visual style로 생성할 거야.

먼저 F-02 Hotteok부터 시작하자:

[F-02 Hotteok prompt — prompts-library §5.2 F-02 full prompt copy-paste]
```

**copy-paste 순서** (각 음식마다 1 image → 평가 → 다음 prompt):

1. **F-02 Hotteok** — `prompts-library.md §5.2 F-02` 전체 prompt
2. **F-04 Tteokbokki** — `prompts-library.md §5.2 F-04` 전체 prompt
3. **F-05 Kimchi Fried Rice** — `prompts-library.md §5.2 F-05` 전체 prompt
4. **F-07 Haemul Pajeon** — `prompts-library.md §5.2 F-07` 전체 prompt
5. **F-09 Kimchi Jjigae** — `prompts-library.md §5.2 F-09` 전체 prompt
6. (T2 첫 1장 — 한 세션 안 6장 분담) **F-10 Sundubu Jjigae** — `prompts-library.md §5.2 F-10` 전체 prompt

**각 음식 prompt 끝에 추가 instruction** (subject anchor 일관성 강화):
```
... (prompt 본문) ...

Important also: maintain the same visual style as the reference image I attached at the start of this session
(Korean K-food plated hero shot, white baekja or pale celadon plate/bowl, slim 2-3px outline,
Cool Sage #C8D5C0 background, saturation 80-90%, no characters, no hands, no cooking action).
```

**각 음식 1차 결과 평가** (~10초):
- 그 음식의 식별 핵심 시각 요소 (§5.2 각 음식 항목 참조) 충족?
- 한식↔타국식 누수 없음? (음식별 누수 risk 명시 참조)
- bg / outline / saturation 톤이 anchor와 일치?
- 캐릭터/손/cooking action 없음?

**탈락 시 즉시 follow-up** (그 음식 prompt §5.2 reroll 트리거 직접 copy-paste).

### M1.7 M1 Step 2 — T2 음식 5장 follow-up (F-08, F-03, F-11, F-06, F-12)

> 새 ChatGPT 채팅 세션 시작 (T1 세션 context 분리). FOOD_ANCHOR_FILE 재첨부.

**세션 시작 message**: M1.6와 동일 (reference 첨부 + style 일관성 instruction).

**copy-paste 순서** (난도 오름차순):

7. **F-03 Kimbap** — `prompts-library.md §5.2 F-03` 전체 prompt (일본 maki sushi 누수 risk VERY HIGH, 첫 시도 reroll 2~3회 예상)
8. **F-08 Bibimbap** — `prompts-library.md §5.2 F-08` 전체 prompt
9. **F-11 Japchae** — `prompts-library.md §5.2 F-11` 전체 prompt (중식 lo mein 누수 risk VERY HIGH)
10. **F-06 Korean Corn Dog** — `prompts-library.md §5.2 F-06` 전체 prompt (미국 corn dog 누수 risk VERY HIGH)
11. **F-12 Galbi-gui** — `prompts-library.md §5.2 F-12` 전체 prompt (일본 야키니쿠 + 미국 BBQ 누수 risk VERY HIGH, 최대 3 reroll 예상)

> 위 5장 모두 누수 risk HIGH+ → 각 음식 평균 follow-up 2~3회 예상. F-12가 가장 까다로움 (마지막에 배치, 사용자 fatigue 시 다음 세션 분리 가능).

### M1.8 사용자 결과 인계 schema (12장 12행 메모장)

> 음식 12 평가 인계 schema. 각 음식 1세트.

```
Anchor ID: F-01 (또는 F-02 등)
food_id: t1_002 (foods-database.csv 매핑)
음식 (English): Ramyeon (Spicy Noodle Soup)
ChatGPT 세션 URL: https://chatgpt.com/c/... (share link)
이미지 파일 경로: C:\Projects\kfood-game\assets-raw\2026-05-2x_F-01_v1.png
Round: R1 (또는 R2 / R3)
follow-up 횟수 (reroll): 0 (또는 1, 2, 3)
한식 식별 PASS? (yes/no): yes
한식↔타국식 누수? (특정 risk 명시 가능): no (또는 "Japanese ramen 누수, ttukbaegi 아닌 검정 donburi")
Tier 시각 구분 PASS? (T1=단순 / T2=풍성): yes
사용자 1차 평가 메모 (선택): "면 직선으로 빠졌으나 1회 reroll로 회수, 노른자 위치 OK"
```

**전체 묶음 권장**: 메모장 또는 마크다운 1장에 12개 블록. assets-raw/ 폴더에 모든 image 저장.

### M1.9 예상 소요 시간 (1차 시도 기준)

| 단계 | 작업 | 예상 시간 |
|------|------|----------|
| M1 Step 0 | F-01 Ramyeon anchor 시드 (1 image + 평가) | 5~10분 |
| M1 Step 1 | T1 6장 (F-02/04/05/07/09/10) × (1 image + 평가 + reroll) | 40~60분 (평균 1~2 reroll) |
| M1 Step 2 | T2 5장 (F-03/08/11/06/12) × (1 image + 평가 + reroll) | 50~80분 (평균 2~3 reroll, F-06/F-12가 무거움) |
| 파일 저장/메모 정리 | 12행 schema 메모장 작성 | 15~20분 |
| **총합 (reroll 포함 현실 예상)** | | **1.5~2.5시간 (90~150분)** |

> ChatGPT Plus $20/월 한계 비용 0 (DALL-E 무제한). 1 image 생성 ~10~30s × 평균 18~25 generations = ~5~10분 순 생성 시간 + 평가/메모 시간 dominant.

### M1.10 까다로움 사전 경고 (음식 12 특화)

| 경고 | 빈도 | 대응 |
|------|------|------|
| **F-03 Kimbap → Japanese maki sushi 누수** | **Very High (~70%)** | THICK 3cm + matte gim + cooked vegetables + danmuji yellow + NO raw fish/wasabi/gari 강제. R1에서 2~3회 reroll 예상. |
| **F-06 Korean Corn Dog → 미국 corn dog 누수** | **Very High (~80%)** | mozzarella cheese stretch + crispy panko crumb + ketchup AND mustard zigzag 강제. American smooth cornmeal negative. |
| **F-11 Japchae → 중식 lo mein 누수** | **Very High (~70%)** | translucent brown-amber sweet potato glass noodles (dangmyeon, see-through) + 깨 generous sprinkle + NOT yellow egg noodles 강제. |
| **F-12 Galbi-gui → 일본 야키니쿠 + 미국 BBQ 누수** | **Very High (~60% + 30%)** | VISIBLE WHITE RIB BONE running through each meat piece (대문자) + shiny brown soy-pear marinade + 상추 ssam side. 가장 어려움. |
| **F-09 Kimchi Jjigae → 중식 hot pot 누수** | **High (~50%)** | 검정 ttukbaegi (rounded thick rim, individual portion) + red-orange gochugaru. |
| **F-05 Kimchi Fried Rice → 중식 fried rice 누수** | **High (~50%)** | red-orange kimchi color dominant + sunny-side-up whole egg on top + NO peas/carrots Western mirepoix. |
| **F-07 Haemul Pajeon → Japanese okonomiyaki 누수** | **High (~40%)** | long thick green scallions dominant + 새우/오징어 + NO mayo squiggle/bonito flakes/aonori. |
| **anchor 일관성 lock 약화** (T1/T2 세션 분기 시) | Med | T2 새 세션 시작 시 FOOD_ANCHOR_FILE 재첨부 + style 일관성 instruction 명시 필수 |
| **plate/bowl 컬러 안 통일됨** | Med | "white baekja or pale celadon" + reference image upload + "same plate style as reference" 강조 |
| **Tier 1/2 시각 구분 약함** | Med | T1 = "single bowl, 2-3 garnish" / T2 = "Tier 2 abundance, generously filled" 명시. T2는 6+ vegetable color 또는 3+ rib pieces 등 abundance 키워드. |

### M1.11 사용자 체크리스트 (M1 세션 시작 전)

- [ ] **Week 1 anchor lock candidate evaluation 결과 무관**으로 진행 가능 (음식 카드는 캐릭터/환경과 독립)
- [ ] `prompts-library.md §5.2 F-01~F-12` 12장 전체 prompt 한 화면에 열어두기
- [ ] 메모장 열어두기 — 12행 schema (food_id / 파일 경로 / Round / follow-up 횟수 / 평가 메모)
- [ ] `assets-raw/` 폴더 준비 (`2026-05-2x_F-01_v1.png` ~ `2026-05-2x_F-12_v1.png` 12장 저장)
- [ ] M1 Step 0 (F-01 Ramyeon) 먼저 lock → 그 후 F-02~F-12 follow-up
- [ ] T1 (1~6) 한 세션 / T2 (7~12) 새 세션 분리 권장
- [ ] 새 세션 시작 시 FOOD_ANCHOR_FILE (F-01 lock image) 재첨부 + style 일관성 instruction 명시
- [ ] 음식별 누수 risk 명시 (§M1.10 참조) — F-03/F-06/F-11/F-12 4종은 reroll 2~3회 예상
- [ ] 결과 12장 image + 12행 schema 메모장을 art-director에게 인계

---

## 9. 변경 이력

- **2026-05-27 v1.3** (M1 음식 12 세션 추가, supersedes v1.2) — prompts-library v1.3 음식 12 anchor sync. **§M1 신설** — F-01 Ramyeon anchor 시드 lock (Step 0) → T1 6장 한 세션 follow-up (Step 1, F-02/04/05/07/09/10) → T2 5장 새 세션 follow-up (Step 2, F-03/08/11/06/12). 생성 순서 = 난도 오름차순 + 누수 risk 후순위. subject anchor 단어 통일 = "modern mobile casual game food card illustration of Korean [음식명]" 공통. reference image upload = F-01 lock 후 11장 모두 첨부 + style 일관성 instruction 명시. 결과 인계 schema = food_id / image URL / Round / follow-up 횟수 / 한식 식별 PASS / Tier 시각 구분 PASS / 평가 메모 12행. 예상 소요 ~1.5~2.5h. §M1.10 까다로움 사전 경고 — F-03 Kimbap (Japanese maki sushi VH 70%) / F-06 Corn Dog (American VH 80%) / F-11 Japchae (Chinese lo mein VH 70%) / F-12 Galbi-gui (Japanese yakiniku VH 60% + American BBQ 30%) / F-09 Kimchi Jjigae (Chinese hot pot H 50%) / F-05 Kimchi Fried Rice (Chinese H 50%) / F-07 Pajeon (Japanese okonomiyaki H 40%). §1~§8 Week 1 anchor 워크플로 무변경.
- **2026-05-27 v1.2** (modern mobile casual sync, supersedes v1.1) — iter2 사용자 진단 "올드함" 반영, prompts-library v1.2 sync. **Step 0a CH-01 prompt 갱신** — bowl-cut hair LOCK + 프라이팬+spatula dynamic stirring (절구 회피 명시) + soft mint cool bg + light pink cheek + slim 2~3px outline + 80~90% saturation + 베이지/Cookie Run/storybook/scrapbook 회피 LOCK. **Step 0b BG-01 prompt 갱신** — modern flat clean (재래시장 손맛 texture 제거) + awning solid + 1 trim (이탈리아 회피) + cool tone sky + no people/no shop owner LOCK. **판단 기준 갱신** — 베이지 즉시 탈락 / 이탈리아 awning 즉시 탈락 / Cookie Run frosting 탈락 / 절구 탈락 추가. 워크플로 / 세션 분기 / 시간 (~1~1.5h) / 비용 모두 무변경. §7.1 ChatGPT 특화 사전 경고에 v1.2 신규 약점 3종 추가 (베이지 default Very High / Cookie Run frosting Med / 절구 traditional Med). Step 1~2 (CH-02~05, BG-02~05) prompt는 prompts-library §3·§4 v1.2 prompt 사용 (본 키트는 Step 0a/0b만 inline, 나머지는 prompts-library 참조).
- **2026-05-27 v1.1** (ChatGPT 영구 sync from MJ, supersedes v1.0) — art 도구 영구 변경 (사용자 confirm 2026-05-27). 파일명 `mj-session-kit.md` → `ai-session-kit.md` (main thread 처리). MJ Discord `/imagine` + 4-grid + upscale 개념 제거, ChatGPT 채팅창 + 1 image per request + follow-up 대화 reroll로 재구성. §1.2 도구 통일 (MJ v6.1 → ChatGPT 단일 model, 모델 선택 param 없음 자동). §2 Step 0 sref anchor 후보 → **subject anchor 정의 + 선택적 reference image upload**로 재작성 — sref URL placeholder 모두 제거, 파일 경로 + subject anchor 문장으로 대체. §3 캐릭터 5장 ChatGPT 자연어 prompt + reference image upload 절차 + follow-up 대화 reroll 형식으로 전면 재작성. §4 환경 5장 동일 재작성. §5 사용자 인계 schema "4-grid 선택 칸" 컬럼 제거, "ChatGPT 세션 URL + 이미지 파일 경로 + subject anchor 문장 + reference upload 사용 여부 + follow-up 횟수" 컬럼 보강. §6 reroll 트리거 G6 ChatGPT 약점 10항(W1~W10) 재구성 — W1 한글 텍스트 깨짐 (Very High), W2 photoreal, W3 painterly, W7 복잡 composition multi-character, W9 캐릭터 일관성 lock 실패 (sref 부재) 신규. §7 예상 소요 시간 MJ 1.5~2.5h → **ChatGPT ~1~1.5h** (4-grid 손실 vs 자연어 iteration 속도 + DALL-E 무제한 + 1 image 생성 속도 빠름). 비용 MJ Standard $30/월 fast hour 소비 → ChatGPT Plus $20/월 한계 비용 0. §7.1 ChatGPT 특화 사전 경고 (한글 깨짐 Very High, 캐릭터 일관성 lock High). §8 체크리스트 MJ Standard → ChatGPT Plus 구독 확인. §3.6 양친 reaction placeholder 무변경 (U-2 sync, reference upload 운영).
- **2026-05-27 v1.0** (archived; MJ 기반) — scratch rewrite, hyper-casual flat, v6.1 single model, MJ Discord copy-paste 키트.
- **2026-05-24 v0.1** (archived; mascot 톤) — 초안. niji 6 캐릭터 + v6.1 환경 dual model.
