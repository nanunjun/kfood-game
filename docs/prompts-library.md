# Prompts Library — K-Food Master MVP

> 버전: **v1.2 (2026-05-27, modern mobile casual reset) — supersedes v1.1**
> 작성자: art-director
> 상위 문서: [`art-style-guide.md` v1.2](art-style-guide.md), [`ai-session-kit.md` v1.2](ai-session-kit.md), [`art-anchor-rubric.md` v1.2](art-anchor-rubric.md), [`decisions.md` ADR-003](decisions.md#adr-003-mvp-first-전환--34개월-출시--점진-확대-supersedes-adr-002), [`decisions.md` ADR-005](decisions.md#adr-005), [`art-workload-estimate.md` v4.1](art-workload-estimate.md)
> 본 문서 범위: Week 1 anchor lock = **캐릭터 5 + 환경 5 = 10장 프롬프트**. 음식 12 / cut anim / 양친 reaction 6컷 / 재료 / UI / VFX는 M1 sprint (§3~§5 placeholder).
> 도구: **ChatGPT (GPT-4o image / DALL-E)** 영구 lock.

> **v1.2 변경 (2026-05-27, modern mobile casual reset)**: iter2 사용자 진단 "올드함" 반영. §0 anchor 표 + §0.1 ChatGPT subject anchor 운영 무변경 (v1.1 sync 유지). §1 모델 선택 정책 무변경. **§2 STYLE_SUFFIX_BG / STYLE_SUFFIX_CHAR 전면 재작성** — Royal Match + Subway Surfers reference, 채도 80~90%, cool tone bg (soft mint default), slim outline 2~3px, dynamic action pose, soft 1-layer cel shading 허용, 베이지/scrapbook/storybook/mortar/이탈리아 awning 회피 LOCK. **§3 캐릭터 5종 prompts 재작성** — bowl-cut hair lock + dynamic stirring pose (프라이팬+spatula 또는 냄비+국자, 절구 회피) + cool mint bg + light pink cheek + slim outline. **§4 환경 5종 prompts 재작성** — modern flat clean (재래시장 손맛 texture 제거), cool tone sky, awning 색 v1.2 sync (이탈리아 회피), no characters in shop lock. §5 placeholder 도구 매핑 sync (절구 회피 + 프라이팬/냄비/도마+칼/김밥말이 4종). 각 prompt format은 v1.1 자연어 + Important: avoid 동일.

> **v1.1 변경 (2026-05-27)** (archived): MJ → ChatGPT 영구 변경. 자연어 prompt + "Important: avoid ..." negative + follow-up 대화형 reroll로 통일.

---

## 0. Anchor Lock 표 (게이트 통과 후 채움)

> Week 1 게이트 PASS 후 **모든 M1 sprint 자산은 본 표의 anchor image 파일을 reference upload + subject anchor 문장 동일 복사**로 운영.

| ID | Subject | 파일 경로 | ChatGPT 세션 URL | subject anchor 문장 | Status |
|----|---------|----------|------------------|---------------------|--------|
| CH-01 | 주인공 (base) | TBD | TBD | TBD | pending |
| CH-02 | 어머니 | TBD | TBD | TBD | pending |
| CH-03 | 아버지 | TBD | TBD | TBD | pending |
| CH-04 | 주인공 Happy (★3 reaction) | TBD | TBD | TBD | pending |
| CH-05 | 주인공 Subtle (★1·★2 reaction) | TBD | TBD | TBD | pending |
| BG-01 | 청과상 🥬 | TBD | TBD | TBD | pending |
| BG-02 | 정육점 🥩 | TBD | TBD | TBD | pending |
| BG-03 | 어물전 🐟 | TBD | TBD | TBD | pending |
| BG-04 | 곡물상 🌾 | TBD | TBD | TBD | pending |
| BG-05 | 잡화점 🫙 | TBD | TBD | TBD | pending |

### 0.1 ChatGPT subject anchor 운영 (sref 대체 메커니즘)

> ChatGPT는 MJ `--sref`/`--cref` 같은 explicit lock 메커니즘이 없다. 대신 **3축 운영**으로 일관성 lock:
>
> 1. **Subject anchor 단어 동일 유지** (필수): 캐릭터/환경 핵심 description을 4 variant prompt에서 **동일 단어 sentence로 그대로 복사**. 예: 주인공은 모든 prompt에 `"young Korean cooking character wearing beige apron over orange hoodie, two small black dot eyes, small arc smile, mitten hands"` 한 문장 동일 복사.
> 2. **Reference image upload** (선택, 강력): Step 0 lock anchor를 ChatGPT에 첨부 → "이 이미지와 같은 스타일·outline·features로 [새 subject]를 그려줘" 명령. style transfer 정확도가 MJ sref 대비 약간 낮으나 충분.
> 3. **같은 채팅 세션 안 follow-up** (보조): CH-01 생성 직후 같은 세션에서 CH-02~05 follow-up. ChatGPT는 세션 context로 직전 image 스타일을 일부 기억한다 (세션 전환 시 손실).

| Anchor 시드 | 결정 위치 (Step 0) | 적용 대상 anchor | 운영 방식 |
|------------|------------------|----------------|---------|
| `CHAR_ANCHOR_FILE` | Step 0a — 주인공 best image | CH-01, CH-02, CH-03, CH-04, CH-05 | (1) subject anchor 문장 동일 + (2) Step 0a image reference upload + (3) 같은 채팅 세션 follow-up |
| `BG_ANCHOR_FILE` | Step 0b — 청과상 best image | BG-01, BG-02, BG-03, BG-04, BG-05 | 동일 |

**원칙**:
- 한 번 lock한 anchor file은 sprint 종료까지 변경 금지 (변경 시 pm 승인 필수)
- 모델 선택 param 없음 (ChatGPT 단일 model 내부 자동)
- M1 sprint 모든 파생 자산(cut anim, 음식 카드, reaction variant)도 본 anchor file reference upload + subject anchor 문장 의무 사용

### 0.2 사용자 결과 인계 schema

> 사용자가 ChatGPT 세션 종료 후 art-director에게 결과를 들고 올 때 본 schema로 묶어 전달.

```
Anchor ID: <CH-01 | CH-02 | ... | BG-05 | STEP-0a | STEP-0b>
ChatGPT 세션 URL: <chat.openai.com/c/... 또는 share link>
이미지 파일 경로: <C:\Projects\kfood-game\assets-raw\2026-05-2x_CH-01_v1.png>
subject anchor 문장 (실제 prompt에 사용한 한 줄): <"young Korean cooking character wearing beige apron over orange hoodie, ...">
Reference image upload 사용 여부: <yes (Step 0a 파일 첨부) | no (text-only prompt)>
Round: <R1 | R2 | R3>
follow-up 횟수 (reroll): <0 | 1 | 2>
사용자 1차 평가 메모 (선택): <자유 메모>
```

art-director는 위 schema를 받아 [`art-anchor-rubric.md`](art-anchor-rubric.md) §3 표를 채워 LOCK/CONDITIONAL/FAIL 판정.

---

## 1. Model 선택 정책 (ChatGPT 단일 model)

### 1.1 결론

- **캐릭터 5장 (CH-01~05)**: ChatGPT (GPT-4o image / DALL-E)
- **환경 5장 (BG-01~05)**: ChatGPT (GPT-4o image / DALL-E)

> ChatGPT는 내부 모델 선택 param 없음 (자동). MJ v1.0의 v6.1 vs niji 6 dual model 운영 → ChatGPT 단일 model 통일로 sref cross-호환·합성 톤 차이 risk 0 (도구 특성상 자동 달성).

### 1.2 ChatGPT default 누수 차단 (필수 negative)

모든 prompt 끝에 다음 "Important: avoid ..." 필수:

```
Important: avoid realistic or photorealistic rendering, 3D render, octane or unreal engine,
any texture, noise, grain, painterly or hand-painted feel, watercolor,
gradient mesh, complex multi-layer cel shading, hyperdetailed elements,
cinematic or gritty tones, golden hour or dramatic lighting,
anime girl, manga, big sparkly eyes, school uniform, fanservice or sexy elements,
Japanese (kimono, tokyo, sushi, fuji, noren), Chinese (qipao, blue-and-white porcelain, chinese lantern).
```

---

## 2. 공통 프롬프트 구조 & Suffix

### 2.1 프롬프트 구조 (모든 anchor 공통, ChatGPT 자연어)

```
[Subject 자연어 description]
+ [Style 자연어 단어 (flat 2D illustration, hyper-casual ...)]
+ [Composition (square 1:1 format / wide 16:9 landscape)]
+ [Surface (single color fill, bold outline ...)]
+ [Important: avoid ...]
```

### 2.2 공통 Suffix — **환경 5장 (BG-01~05)**

모든 환경 prompt 끝에 동일하게 부착:

```
[STYLE_SUFFIX_BG]
Format: wide 16:9 landscape.
Style: modern mobile casual game art, clean 2D illustration in Royal Match (Dream Games 2021) aesthetic,
applied to a Korean traditional market interpreted with modern flat clean tone.
Slim bold dark outline 2-3px (warm dark, not pure black), single color fill with optional soft 1-layer cel shading.
Vibrant saturated colors at 80-90 percent saturation, warm/cool palette balance.
Background sky in cool tone: soft mint (#9BE0D2) or pastel teal (#5FB8C4) light variant
or subtle cool gradient top-to-bottom. NO beige, NO cream paper, NO scrapbook background.
Single signature color per shop (cabbage green / gochu red / sea blue / grain tan / jang brown).
Clean minimal composition, only 1-2 signature icons per shop, no people in foreground,
the shop is empty waiting for a customer.
Awning is solid signature color with one accent trim color (NO red-green-white Italian flag stripes).

Important: avoid beige background, cream paper background, scrapbook, storybook, kraft paper, vintage texture, golden hour, sunset warm lighting,
Cookie Run, Cookie Run Kingdom frosting style, Toca Boca, Toon Blast over-cartoony,
realistic or photorealistic rendering, 3D render, octane or unreal engine,
any texture, noise, grain, painterly or hand-painted feel, watercolor, gradient mesh,
multi-layer complex shading, hyperdetailed elements, cinematic, gritty,
Italian flag awning, red-green-white stripes, traditional Korean mortar, mortar and pestle,
Japanese (Tokyo, Chinatown, kimono, sushi, Fuji, noren),
Chinese (qipao, blue-and-white porcelain, chinese lantern),
anime girl, manga, cluttered composition,
any English or Korean text legibly readable (use solid block placeholders only),
people, customers, shop owner.
```

> "Minimal stylization": ChatGPT는 stylize 숫자 param 없음 → 자연어 단어로 톤 강도 유도 ("minimal / moderate / highly stylized").

### 2.3 공통 Suffix — **캐릭터 5장 (CH-01~05)**

```
[STYLE_SUFFIX_CHAR]
Format: square 1:1.
Style: modern mobile casual game character, clean 2D illustration in Royal Match (Dream Games 2021)
modern saturated palette + Subway Surfers chibi energy. Chibi mascot proportions,
head to body ratio approximately 1 to 1.7 (big head, small body), dynamic energetic action pose
(not static standing) with 1-2 motion line streaks.
Single color fill on clothing (2-3 color blocks max) with optional soft 1-layer cel shading.
Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), geometric rounded shapes.
Simple facial features: two small black dot eyes, small arc smile, no nose,
optional LIGHT pink (#FFCFCF) cheek blush (NOT deep Cookie Run pink).
Mitten or nub hands (no individual fingers visible).
Three-quarter view, full body, plain soft mint (#9BE0D2) cool tone background
(NO beige, NO cream paper background).
Vibrant saturated colors at 80-90 percent saturation, warm/cool balance.
Single ambient ellipse shadow under feet.

Important: avoid beige background, cream paper background, scrapbook, storybook, kraft paper, vintage texture, golden hour,
Cookie Run, Cookie Run Kingdom frosting style, Toca Boca, Toon Blast over-cartoony,
deep dark pink cheek, heavy blush,
anime girl, manga style, big sparkly eyes, school uniform, fanservice or sexy elements,
realistic or photorealistic rendering, 3D render, octane or unreal engine,
any texture, noise, painterly or hand-painted feel, watercolor, gradient mesh,
multi-layer complex shading, hyperdetailed elements, individual finger detail, nose detail,
traditional Korean mortar, mortar and pestle, stirring with mortar,
Japanese (kimono, geisha), Chinese (qipao),
dark, gritty, cinematic, golden hour or dramatic lighting,
sleeping, eyes closed peaceful, sad, crying.
```

> **Anchor lock 후 운영**: CH-01의 best image를 `CHAR_ANCHOR_FILE`로 §0 표에 기록 → CH-02~05 생성 시 같은 채팅 세션에서 reference image upload + "이 이미지와 같은 outline·features·컬러 톤으로" follow-up. BG도 동일.

### 2.4 anchor consistency 운영 규칙 (sref 대체)

> 운영 매핑 표는 §0.1, 결과 인계 schema는 §0.2 참조.

1. **Round 1 (탐색)**: subject anchor 문장만으로 1 image 생성. 만족 시 다음 anchor로.
2. **Round 2 (Lock)**: Round 1 best를 ChatGPT에 reference upload → 같은 prompt + "이 이미지와 동일한 스타일·outline·features 유지" follow-up → 일관성 강화 확인.
3. **Round 3 (Anchor 확정)**: Round 2 best를 anchor로 §0 표 기록. M1 모든 자산의 anchor file.
4. **금지**: 한 번 lock한 anchor file은 sprint 종료까지 변경 금지.
5. **Style transfer 강도 조정**: ChatGPT는 sw 숫자 param 없음 → follow-up에서 "더 reference image와 비슷하게" 또는 "reference 톤 약간만 차용하고 더 단순하게" 자연어로 조정.
6. **세션 분기**: CH-01·CH-02·CH-03 (캐릭터) 한 세션 / CH-04·CH-05 (reaction variant) 한 세션 / BG-01~05 (환경) 한 세션 권장. ChatGPT는 세션 안에서만 context 일관성 유지하므로.

---

## 3. 캐릭터 Anchor Prompts (5장)

> Step 0a 생성 후 같은 채팅 세션 안에서 CH-02~05 follow-up 권장. 또는 새 세션 시작 시 Step 0a image를 reference upload.

### CH-01 — 주인공 (base, v1.2 dynamic stirring + bowl-cut)

**의도**: Tier 1 혼밥 시점 주인공. CH-04/05 표정 variant의 base. 캐릭터 anchor 시드.

**Prompt** (ChatGPT 채팅창에 그대로 붙여넣기):
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

[STYLE_SUFFIX_CHAR]

Important also: the character must hold a FRYING PAN with spatula (NOT a mortar and pestle, NOT a 절구).
Hair must be bowl-cut style (rounded black helmet shape).
```

**Expected output 특징**: bowl-cut hair, dynamic stirring pose with pan+spatula, soft mint cool bg, light pink cheek, slim 2-3px outline, 80-90% saturation.

**Reroll 트리거** (follow-up 대화 형식):
- G_new modernity FAIL (베이지/scrapbook 누수): "이 이미지를 더 modern Royal Match style로 다시 그려줘. 베이지 배경을 soft mint cool tone (#9BE0D2)로 교체, scrapbook/storybook 느낌 완전 제거."
- 절구(mortar) 누수: "이 이미지를 다시 그려줘. 절구(mortar and pestle)를 modern enameled frying pan + spatula로 교체, dynamic stirring pose 유지."
- G2 dynamic pose FAIL (정적 standing): "이 이미지를 다시 그려줘. dynamic action stirring pose로 강조 — 한 발 앞으로, 몸 기울임, motion line 1-2개 추가."
- G3 채도 FAIL (muted): "이 이미지를 다시 그려줘. vibrant saturated 80-90% 채도로 강조, warm/cool 균형 (cool mint bg + warm orange hoodie)."
- G6 (W3 painterly/storybook 누수) FAIL: "이 이미지를 더 clean modern mobile casual로 다시 그려줘. storybook, scrapbook, painterly 톤 완전 제거, Royal Match style clean 2D."

### CH-02 — 어머니 (Tier 2 가족, base, v1.2)

**의도**: Tier 2 가족 식탁. 한복 jeogori 실루엣만 (자수/디테일 X). 주인공과 페어 일관성.

**Prompt**:
```
A modern mobile casual game illustration of a gentle Korean mother character in chibi mascot proportions, early 50s.
She wears a simple V-collar jeogori top in vivid persimmon color (#FF8A1F) over wide-leg cool teal pants,
with a round bun hairstyle rendered as a simple dark circle shape on top (no ornament detail).
Warm closed-arc smile, two small black dot eyes, no nose, LIGHT pink (#FFCFCF) soft cheek blush.
Dynamic friendly pose: holding a small white rice bowl with both mitten hands, slight body tilt,
showing warmth (not static standing). Full body, three-quarter view.
Background is solid soft mint (#9BE0D2) cool tone (NO beige, NO cream paper).
Slim bold dark outline 2-3px, single color fill with optional soft 1-layer cel shading.

This character is in the same modern mobile casual Royal Match + Subway Surfers style as the main character anchor
(young Korean cooking character with bowl-cut hair, soft white apron, vibrant orange hoodie), as the same family IP.

[STYLE_SUFFIX_CHAR]

Important also: avoid Japanese kimono, geisha, Chinese qipao, embroidery or pattern on jeogori (plain solid color),
mortar and pestle, beige background, scrapbook tone.
```

**Reference image upload 권장**: Step 0a CH-01 best image 첨부 → "이 reference와 같은 outline 두께·features·flat 톤·컬러 saturation으로 어머니 캐릭터를 같은 family IP로 그려줘."

**Reroll 트리거** (follow-up):
- G4 일본 기모노 누수: "이 이미지를 다시 그려줘. 옷섶이 오른쪽으로 여며진 Korean hanbok jeogori V-collar로 명확히 만들고, kimono 요소를 완전히 제거해줘."
- G1 주인공 페어 깨짐: "이 이미지를 다시 그려줘. reference image와 같은 outline 두께, 같은 점 눈/호 입 스타일, 같은 단색 fill 톤으로 family 일관성을 강화해줘."
- G5 jeogori 자수 폭주: "이 이미지를 다시 그려줘. jeogori를 완전 단색 solid fill로, 자수·무늬·패턴 모두 제거, plain fabric flat으로."

### CH-03 — 아버지 (Tier 2 가족, base, v1.2)

**의도**: Tier 2 가족 식탁. 어머니와 페어 일관성.

**Prompt**:
```
A modern mobile casual game illustration of a kind Korean father character in chibi mascot proportions, early 50s.
He wears a solid warm brown cardigan over a plain white shirt and a soft white apron (NOT beige apron),
with short salt-and-pepper hair rendered as a simple gray-and-black solid shape (no individual strands).
Warm closed-arc smile, two small black dot eyes, no nose, optional LIGHT pink (#FFCFCF) cheek blush.
Dynamic friendly pose: holding modern wooden chopsticks in one mitten hand, the other hand near chin
in a thoughtful "tasting" gesture, slight body tilt. Full body, three-quarter view.
Background is solid soft mint (#9BE0D2) cool tone (NO beige, NO cream paper).
Slim bold dark outline 2-3px, single color fill with optional soft 1-layer cel shading.

This character is paired with the mother character in the same family,
in the same modern mobile casual Royal Match + Subway Surfers style as the main character anchor.

[STYLE_SUFFIX_CHAR]

Important also: avoid young anime boy or teenager look (this is a mature 50s mascot character),
thick beard or heavy mustache, school student look,
mortar and pestle, beige background, scrapbook tone.
```

**Reference image upload 권장**: Step 0a CH-01 best + CH-02 best 모두 첨부 → "두 reference와 같은 family IP로, 아버지 캐릭터를."

**Reroll 트리거** (follow-up):
- young anime boy로 빠짐: "이 이미지를 다시 그려줘. 50대 mature father로 강조, salt-and-pepper hair, 절대 teenager/school boy 아님."
- G1 어머니 페어 깨짐: "이 이미지를 다시 그려줘. 어머니 reference와 같은 family flat art style, 같은 outline 두께."
- G5 머리카락 strand 폭주: "이 이미지를 다시 그려줘. 머리카락을 simple solid color shape 하나로, 개별 strand 모두 제거."

### CH-04 — 주인공 Happy (★3 reaction, v1.2)

**의도**: Scene 3 ★3 시식 reaction. CH-01과 동일 캐릭터 인식 필수.

**Prompt**:
```
A modern mobile casual game illustration of the same young Korean cooking character (same bowl-cut black hair,
soft white apron over vibrant orange hoodie), showing a joyful "wow delicious" expression.
Mouth open in a delighted O-shape, two upward curved happy arc eyes (smiling, not closed-sad),
LIGHT pink (#FFCFCF) cheek blush (NOT deep dark Cookie Run pink).
Small simple flat geometric heart and star icons around the head as accent (single color, not detailed sparkle).
Both mitten hands raised near cheeks in delight, dynamic energetic pose.
Three-quarter view, bust-up portrait (head and shoulders).
Background is solid soft mint (#9BE0D2) cool tone (NO beige).
Slim bold dark outline 2-3px, single color fill with soft 1-layer cel shading.

[STYLE_SUFFIX_CHAR]

Important also: the eyes are upward curved happy arcs (smiling), NOT closed sleeping or sad eyes.
Avoid sleeping, drowsy, sad closed eyes, crying tears, deep dark pink cheek,
mortar and pestle, beige background, scrapbook tone, Cookie Run frosting style.
The hearts and stars must be simple flat geometric icons in single color (not detailed sparkle effects).
```

**Reference image upload 강력 권장**: Step 0a CH-01 best 첨부 → "이 reference 캐릭터와 정확히 같은 의상·outline·features 유지, 단 표정만 happy reaction으로 변경."

**Reroll 트리거** (follow-up):
- G1 CH-01과 다른 캐릭터: "이 이미지를 다시 그려줘. reference 캐릭터 의상(beige apron + orange hoodie)을 정확히 일치시키고, 같은 outline 두께·features."
- sleeping/eyes closed로 빠짐: "이 이미지를 다시 그려줘. 눈을 upward curved happy arc (웃는 호)로, 절대 sleeping이나 sad closed 아니게."
- G5 sparkle hearts detail 폭주: "이 이미지를 다시 그려줘. hearts와 stars를 simple flat geometric single color icon으로 단순화."

### CH-05 — 주인공 Subtle (★1·★2 공통, v1.2)

**의도**: ★1·★2 공통 차분한 만족 reaction.

**Prompt**:
```
A modern mobile casual game illustration of the same young Korean cooking character (same bowl-cut black hair,
soft white apron over vibrant orange hoodie), showing a soft satisfied small arc smile with a slight head tilt.
Two small black dot eyes (open, looking forward, alert), optional LIGHT pink (#FFCFCF) cheek blush.
No stars, no hearts.
One mitten hand near chin in a "hmm tasty" gesture, slight body tilt for warmth (not static).
Bust-up portrait, three-quarter view.
Background is solid soft mint (#9BE0D2) cool tone (NO beige).
Slim bold dark outline 2-3px, single color fill with soft 1-layer cel shading.

[STYLE_SUFFIX_CHAR]

Important also: the eyes are open as two small black dots, looking forward and alert.
Avoid sleeping, eyes closed peaceful, sad, crying tears, deep dark pink cheek,
mortar and pestle, beige background, scrapbook tone, Cookie Run frosting style.
```

**Reference image upload 강력 권장**: Step 0a CH-01 best 첨부.

**Reroll 트리거** (follow-up):
- sleeping 누수: "이 이미지를 다시 그려줘. 눈을 open 상태로, 두 개의 검정 점, alert content expression, 절대 sleeping/closed eyes 아님."
- 슬픔 표정으로 빠짐: "이 이미지를 다시 그려줘. gentle satisfied smile, mildly positive, content expression."

---

## 4. 환경 Anchor Prompts (5장 — 재래시장 5가게)

> 5장은 **같은 시장 안 옆가게**로 인식되어야 함 (G1).
> 모든 BG는 **빈 가게 (no people)** — 캐릭터는 Godot 레이어 합성.
> 각 BG는 외관 + 매대를 한 컷에. **가게당 시그니처 shape 1~2개만** (단순성).
> Step 0b BG-01 lock 후 BG-02~05는 reference image upload 권장.

### BG-01 — 청과상 🥬 (v1.2 modern flat clean)

**시그니처**: Cabbage Green Vivid `#52C160`

**Prompt**:
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

[STYLE_SUFFIX_BG]
```

**Expected output 특징**: 양배추 + 사과 2개만, awning solid green + sage trim (이탈리아 회피), cool teal sky, no people, modern flat clean, 채도 80-90%.

**Reroll 트리거** (follow-up):
- G_new modernity FAIL (베이지/scrapbook 누수): "이 이미지를 더 modern Royal Match style로 다시 그려줘. 베이지/크림 배경을 cool teal sky로 교체, scrapbook/storybook/vintage 톤 완전 제거."
- 이탈리아 awning 누수: "이 이미지를 다시 그려줘. awning을 solid cabbage green + cool sage trim 단순 패턴으로, red-green-white Italian flag stripe 절대 금지."
- 사람 누수: "이 이미지를 다시 그려줘. 가게 안에 사람(손님/주인) 절대 없음, 빈 storefront만."
- G5 손맛 texture 누수: "이 이미지를 더 modern flat clean으로 다시 그려줘. 종이 거친 texture, 나무 grain 과다, 손맛 vintage 톤 완전 제거."
- G4 일본 시장 누수: "이 이미지를 다시 그려줘. Korean modern interpretation 시장, Japanese/Tokyo 요소 제거."

### BG-02 — 정육점 🥩 (v1.2)

**시그니처**: Gochu Red Vivid `#F23E3E`

**Prompt**:
```
A modern mobile casual game illustration of a Korean traditional market butcher shop storefront,
interpreted with clean modern flat tone (Royal Match aesthetic). The single signature color is vivid gochu red.
Only 1-2 large simple icons: a red round Korean-style lantern hanging and a modern clean cutting board.
The awning above is solid gochu red with a single warm white trim band (NO multi-color stripes).
A simple white tile back wall is a clean flat block. A small price tag appears as a solid block placeholder.
The shop is empty, waiting for a customer (NO people, NO animals, NO meat shown explicitly).
Background sky is solid pastel teal (#5FB8C4) light variant or subtle cool gradient.
Front-facing or slight three-quarter view, eye-level.
Slim bold dark outline 2-3px, single color fill with optional soft 1-layer cel shading.

[STYLE_SUFFIX_BG]

Important also: clean family-friendly modern mobile game art with no blood, no carcass, no raw meat closeup, no gore.
Only the red lantern and cutting board are visible as signature icons.
The red color is vivid but not neon (80-90 percent saturation).
NO Chinese chinatown lantern style (this is Korean), NO beige background, NO scrapbook tone.
```

**Reference image upload 권장**: Step 0b BG-01 best 첨부.

**Reroll 트리거** (follow-up):
- 잔혹 묘사: "이 이미지를 다시 그려줘. family-friendly, no blood, no carcass, only lantern과 cutting board만 signature icon으로."
- G3 빨강 100% 채도: "이 이미지를 다시 그려줘. 빨간 색을 75-80 percent saturation으로 (not neon)."
- G4 중국 등롱 누수: "이 이미지를 다시 그려줘. lantern을 Korean style로, NOT Chinese lantern, NOT chinatown."

### BG-03 — 어물전 🐟 (v1.2)

**시그니처**: Accent Sea `#2E8AC4`

**Prompt**:
```
A modern mobile casual game illustration of a Korean traditional market seafood shop storefront,
interpreted with clean modern flat tone (Royal Match aesthetic). The single signature color is vivid sea blue.
Only 1-2 large simple icons: one stylized cute fish silhouette and a white ice block.
The awning above is solid sea blue with a single soft mint trim band (NO multi-color stripes).
The shop is empty, waiting for a customer (NO people; the fish is a simplified cute icon, not realistic).
Background sky is solid soft mint (#9BE0D2) light variant or subtle cool gradient.
Front-facing or slight three-quarter view, eye-level.
Slim bold dark outline 2-3px, single color fill with optional soft 1-layer cel shading.

[STYLE_SUFFIX_BG]

Important also: this is a Korean seafood market, NOT Japanese sushi shop, NOT Tsukiji.
Avoid dead-eye fish, bloody fish, raw sashimi, beige background, scrapbook tone.
The fish icon is a simplified cute geometric shape, friendly modern mobile casual game style.
```

**Reference image upload 권장**: Step 0b BG-01 best 첨부.

**Reroll 트리거** (follow-up):
- G4 일본 스시집: "이 이미지를 다시 그려줘. Korean seafood market 분위기로, NOT Japanese sushi shop, NOT Tsukiji."
- 비린 사실적 묘사: "이 이미지를 다시 그려줘. fish를 simplified cute geometric icon으로, friendly mobile game style."

### BG-04 — 곡물상 🌾 (v1.2)

**시그니처**: Grain Tan `#D8A86A`

**Prompt**:
```
A modern mobile casual game illustration of a Korean traditional market grain shop storefront,
interpreted with clean modern flat tone (Royal Match aesthetic). The single signature color is warm tan.
Only 1-2 large simple icons: a tan burlap sack trapezoid and a modern wooden scoop.
The awning above is solid warm tan with a single warm brown trim band (NO cream awning).
The shop is empty (NO people).
Background sky is solid soft mint (#9BE0D2) or pastel teal cool tone (NO beige sky, NO warm cream sky).
Front-facing or slight three-quarter view, eye-level.
Slim bold dark outline 2-3px, single color fill with optional soft 1-layer cel shading.

[STYLE_SUFFIX_BG]

Important also: vary the tones with tan, warm brown and a small red bean sack accent dot to avoid an all-tan flat look.
Burlap sacks are simple geometric trapezoid shapes with minimal detail (no burlap weave texture, no vintage scrapbook).
Background must be cool tone (NOT warm cream, NOT beige).
```

**Reference image upload 권장**: Step 0b BG-01 best 첨부.

**Reroll 트리거** (follow-up):
- G3 전체 노랑 단일: "이 이미지를 다시 그려줘. tan, brown, cream의 다양한 톤으로, red bean sack을 accent dot으로 추가."
- G5 마대 detail 폭주: "이 이미지를 다시 그려줘. burlap sack을 simple geometric trapezoid로, weave texture 제거."

### BG-05 — 잡화점 🫙 (v1.2)

**시그니처**: Jang Brown `#7A5238`

**Prompt**:
```
A modern mobile casual game illustration of a Korean traditional market general goods shop storefront (japhwajeom),
interpreted with clean modern flat tone (Royal Match aesthetic). The single signature color is jang brown.
Only 1-2 large simple icons: a large brown round-bottom Korean onggi pottery jar (dark brown earthen)
and a smaller modern seasoning bottle.
The awning above is solid warm brown with a single cream trim band.
The shop is empty (NO people).
Background sky is solid soft mint (#9BE0D2) or pastel teal cool tone (NO beige sky).
Front-facing or slight three-quarter view, eye-level.
Slim bold dark outline 2-3px, single color fill with optional soft 1-layer cel shading.

[STYLE_SUFFIX_BG]

Important also: the onggi is a Korean dark brown earthen jar with rounded bottom,
NOT a Chinese vase, NOT Japanese ceramic, NOT blue-and-white porcelain.
The onggi color is warm dark brown (jang brown signature), not pure black.
NO mortar and pestle on display, NO beige background, NO scrapbook tone.
```

**Reference image upload 강력 권장**: Step 0b BG-01 best 첨부.

**Reroll 트리거** (follow-up):
- G4 중국 청화백자 / 일본 도자기: "이 이미지를 다시 그려줘. Korean onggi pottery, dark brown earthen jar with rounded bottom으로 명확히. NOT Chinese vase, NOT Japanese ceramic, NOT blue-and-white porcelain."
- G3 옹기 순흑: "이 이미지를 다시 그려줘. onggi를 warm dark brown (jang brown signature)으로, 순흑 아님."

---

## 5. M1 Sprint Placeholder (본 sprint 범위 외)

### 5.1 음식 12개 (mvp-food-selection v2.1)

> M1 sprint 본격 작성. 본 sprint(Week 1)는 art-style-guide §4.2 단순화 가이드만 정의.
> **공유 anchor**: 첫 음식(예: 라면) anchor lock 후 그 image를 11개 prompt에 reference upload.
> **도구**: ChatGPT (캐릭터·환경과 동일 — anchor cross-호환 가능).
> **포맷**: square 1:1 format. 배경 단색 크림 `#FAEFD8`. 시점 top-down 또는 7/8 top-down.

| 슬롯 | 음식 | Tier | Status |
|------|------|------|--------|
| F-01 | 떡볶이 | T1 | pending M1 |
| F-02 | 김밥 | T1 | pending M1 |
| F-03 | 라면 | T1 | pending M1 (FTUE 후보 → anchor 시드 후보) |
| F-04 | 한국식 콘도그 | T1 | pending M1 |
| F-05 | 호떡 | T1 | pending M1 |
| F-06 | 해물파전 | T1 | pending M1 |
| F-07 | 김치볶음밥 | T1 | pending M1 |
| F-08 | 비빔밥 | T2 | pending M1 |
| F-09 | 갈비구이 | T2 | pending M1 |
| F-10 | 김치찌개 | T2 | pending M1 |
| F-11 | 잡채 | T2 | pending M1 |
| F-12 | 순두부찌개 | T2 | pending M1 |

### 5.2 ADR-005 칼/도마 + Cut Style 6종 (M1 sprint)

> art-style-guide §5 가이드 기반. 본 sprint는 prompt frame만 placeholder.

**칼/도마 base prompt** (ChatGPT 자연어):
```
A flat 2D illustration of a knife and wooden cutting board, top-down view.
Simple knife silhouette (gray blade + brown handle), bold 3px black outline.
Brown rectangular cutting board with 2-3 horizontal grain lines, rounded corners.
Hyper-casual mobile game style, single color fill, no shading.
Plain warm cream background. Format: square 1:1. Minimal stylization.

Important: avoid realistic, photorealistic, 3D render, texture, painterly,
hyperdetailed, gore, blood, raw meat.
```

**Cut style 6종 frame placeholder** (각 frame 1: whole / frame 2: cutting / frame 3: cut):

| Cut style | Frame 수 | Prompt 핵심 변수 (자연어) |
|-----------|---------|--------------------------|
| 다지기 (mince) | 2 (whole → minced dots) | "ingredient minced into many small dots, scattered evenly" |
| 채썰기 (julienne) | 2 (whole → thin sticks) | "ingredient julienned into thin parallel sticks" |
| 어슷썰기 (diagonal slice) | 3 (whole → mid → done) | "ingredient diagonally sliced into parallelogram pieces" |
| 통썰기 (round slice) | 2 (whole → rounds) | "ingredient round-sliced into evenly spaced discs" |
| 송송썰기 (small chop) | 2 (whole → segments) | "scallion chopped into small segments" |
| 깍둑썰기 (cube) | 3 (whole → mid → cubes) | "ingredient cubed into small dice pieces" |

> ChatGPT는 frame sequence를 같은 채팅 세션 안에서 "앞 frame과 동일 ingredient base, cut state만 변경" follow-up으로 일관성 lock.

**ingredient cut variation**: 음식 12 × hero ingredient 1~2 = ~24 sprite. 각 "whole + cut" 2장만.

### 5.3 양친 reaction 6컷 (U-2 동시 unlock)

| ID | Subject | 상속 anchor |
|----|---------|------------|
| CH-02-S | 어머니 Subtle (★1·★2) | CH-02 lock image |
| CH-02-H | 어머니 Happy (★3) | CH-02 lock image |
| CH-03-S | 아버지 Subtle (★1·★2) | CH-03 lock image |
| CH-03-H | 아버지 Happy (★3) | CH-03 lock image |
| (CH-04, CH-05) | 주인공 본 sprint에서 lock | — |

> 6컷 합계 = (어머니 S+H) + (아버지 S+H) + (주인공 본 sprint CH-04·05) = 6컷.
> 모든 reaction prompt에 "Important: avoid sleeping, eyes closed peaceful, sad, crying" 필수 (tier-1-2-flow §3.3.1 sync).
> 각 prompt에 CH-02 / CH-03 lock image를 reference upload하여 일관성 lock.

### 5.4 재료 카드 / UI / VFX (M1 sprint 후반)

- 재료 ~20개: 음식 anchor의 hero ingredient crop으로 시작 → 부족 재료만 별도 prompt
- UI 일러스트 ~7개: 장바구니, 메모지, 간판 5종 등 — flat 톤 단순 icon (간판 텍스트는 W1으로 placeholder block만, 한글 후보정)
- VFX ~4~5개: 픽업 빛, shake, 타이머 펄스, ★ 등급 — flat 톤이라 simple shape 변화로 충분

---

## 6. 변경 이력

- **2026-05-27 v1.2** (modern mobile casual reset, supersedes v1.1) — iter2 사용자 진단 "올드함" 반영. §0/§0.1/§0.2 anchor 표 운영 무변경 (v1.1 sync 유지). §1 모델 선택 무변경. **§2.2 STYLE_SUFFIX_BG 재작성** — Royal Match modern saturated 80~90% + cool tone bg (soft mint / pastel teal) + slim outline 2~3px + awning solid + accent trim (이탈리아 회피) + soft 1-layer cel shading 허용. 회피 negative 확장: beige/cream paper/scrapbook/storybook/kraft paper/vintage texture/golden hour/Cookie Run/Toca Boca/Toon Blast/Italian flag awning/mortar and pestle/shop owner. **§2.3 STYLE_SUFFIX_CHAR 재작성** — Royal Match + Subway Surfers chibi energy + dynamic action pose with motion lines + light pink cheek (#FFCFCF, Cookie Run 진한 분홍 회피) + soft mint cool bg + slim outline 2~3px + 80~90% saturation. **§3 캐릭터 5종 prompts 전면 재작성** — CH-01 bowl-cut hair LOCK + 프라이팬+spatula dynamic stirring (절구 회피 명시) + soft mint bg + light pink cheek + warm orange hoodie + cool teal pants(CH-02) 등 warm/cool 균형. CH-02~05 family IP reference inheritance 갱신 (anchor file = CH-01 bowl-cut + 소프트 흰 앞치마 + 비비드 오렌지 후드 기준). 각 prompt에 v1.2 신규 reroll 트리거 (G_new modernity FAIL / 절구 누수 / G2 dynamic pose FAIL / G3 채도 FAIL / G6 painterly+storybook 누수 / 베이지 누수 / 이탈리아 awning 누수 / 사람 누수 / 손맛 texture 누수) 추가. **§4 환경 5종 prompts 전면 재작성** — Royal Match modern flat clean, awning v1.2 sync (이탈리아 회피, solid + 1 trim), cool tone sky (soft mint or pastel teal light variant), no people LOCK 명시 강화, "재래시장 손맛" texture 제거 LOCK, 채도 80~90% 상향. §5 도구 매핑 sync (절구 회피 + 프라이팬+spatula 9/12 + 냄비+국자 3~4/12 + 도마+칼 ADR-005 + 김밥말이 1/12). format은 v1.1 자연어 + Important: avoid 동일 유지. M1 placeholder 음식 12 / cut anim / 양친 reaction 6컷 / 재료 / UI / VFX 무변경 (본 sprint 범위 외).
- **2026-05-27 v1.1** (ChatGPT 영구 sync from MJ, supersedes v1.0) — art 도구 영구 변경 (사용자 confirm 2026-05-27). MJ 전용 param/구문(`--ar 1:1`, `--ar 16:9`, `--stylize 100`, `--sref`, `--sw`, `--v 6.1`, `--niji 6`, `--no X, Y`) 모두 제거. ChatGPT 자연어 형식 ("square 1:1 format" / "wide 16:9 landscape" / "minimal/moderate/highly stylized" / "Important: avoid ...")으로 전면 재작성. §0 anchor 표 컬럼 변경 (MJ Job ID/sref URL/seed → ChatGPT 세션 URL/파일 경로/subject anchor 문장). §0.1 **sref 운영 → subject anchor 운영** 재작성 — sref URL 대체 메커니즘 3축: (1) subject anchor 단어 4 variant prompt에서 동일 sentence 복사 + (2) reference image upload (선택, 강력) + (3) 같은 채팅 세션 안 follow-up. §0.2 결과 인계 schema 갱신 (4-grid 선택 칸 제거, ChatGPT 세션 URL + reference image 사용 여부 + follow-up 횟수 컬럼 추가). §1 모델 선택 정책 — ChatGPT 단일 model (내부 자동, dual model 운영 개념 제거). §2 STYLE_SUFFIX_BG / STYLE_SUFFIX_CHAR ChatGPT 자연어 재작성 (Format/Style/Important: avoid 구조). §2.4 anchor consistency 운영 규칙 (sref 대체) — Round 1·2·3 follow-up 대화로 lock, sw 숫자 대체로 "더 reference와 비슷하게" 자연어, 세션 분기 권장. §3 캐릭터 5종 prompt ChatGPT 자연어로 전면 재작성 — 각 prompt에 Expected output 특징 + Reference image upload 권장 + Reroll 트리거 follow-up 대화 형식. §4 환경 5종 prompt 동일 재작성. §5 M1 placeholder ChatGPT 형식 — 칼/도마 base prompt 자연어, cut anim frame은 같은 채팅 세션 follow-up으로 일관성 lock, 양친 reaction은 CH-02/CH-03 lock image reference upload.
- **2026-05-27 v1.0** (archived; MJ 기반) — scratch rewrite, hyper-casual flat, v6.1 single model. MJ comma+--param 형식 prompts.
- **2026-05-24 v0.3** (archived; mascot 톤) — 주인공 선택형 남/여 분리. CH-01 → CH-01a + CH-01b.
- **2026-05-24 v0.2** (archived; mascot 톤) — Week 1 anchor lock 키트 연동.
- **2026-05-23 v0.1** (archived; mascot 톤) — 초안.
