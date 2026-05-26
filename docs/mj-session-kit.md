# MJ Session Kit — Week 1 Anchor Lock 실행 키트

> 버전: **v0.1** · 작성: 2026-05-24 · 작성자: art-director
> 상위 문서: [`art-style-guide.md`](art-style-guide.md) v0.2 §10 게이트, [`prompts-library.md`](prompts-library.md) v0.2 §3·§4, [`art-anchor-rubric.md`](art-anchor-rubric.md)
> 본 문서 범위: 사용자(MJ Standard plan 결제 완료)가 **Discord/web에서 copy-paste만으로** Week 1 anchor 10장을 실행하기 위한 단계별 키트.
> 게이트 통과 = M1 art sprint 진입 prerequisite.

---

## 0. 한 줄 목적

> **"art-director가 prompt를 쓰고, 사용자는 MJ에서 돌리고, art-director가 결과를 채점한다."**
> 본 문서는 사용자가 한 손에 들고 MJ Discord에 차례로 붙여넣을 수 있는 **실행 키트**다.

---

## 1. 세션 흐름 (총 3 Step + 평가)

```
[Step 0] sref anchor 후보 2장 (캐릭터용 1 + 환경용 1) 먼저 생성
                  │
                  ▼  best 1장씩 upscale → 두 URL 확보 (--sref 시드)
                  │
[Step 1] 캐릭터 5장 (CH-01~CH-05) 일괄 — niji 6 + 캐릭터 sref
[Step 2] 환경 5장 (BG-01~BG-05) 일괄 — v6.1 + 환경 sref
                  │
                  ▼
[Step 3] art-director 평가 (G1~G7 rubric, `art-anchor-rubric.md`)
                  │
                  ▼  종합 LOCK / minor reroll / 재작성 판정
        PASS → prompts-library §0 표에 sref URL 영구 기록 → M1 sprint kick-off
        FAIL → 실패 게이트 집중 reroll, 최대 3 라운드
```

### 1.1 왜 Step 0 sref anchor를 먼저 뽑나
- niji 6는 `--cref` 미지원 → 캐릭터 일관성은 **공유 sref URL 1개**로만 잡힌다.
- Step 0에서 가장 핵심 1장(주인공)이 정해지면, 그 sref가 CH-02~CH-05까지 공통 시드가 된다.
- 환경도 동일 — BG-01(청과상)이 시각 톤의 anchor가 되어 BG-02~05에 sref로 부착된다.
- **만약 Step 0을 건너뛰고 5장씩 한꺼번에 돌리면**: sref 없이 prompt만으로 일관성 강제 → 5장이 다른 IP 캐릭터처럼 보일 확률 ≈ 70% (MJ 약점 R-A4).

### 1.2 모델 분리 (절대 헷갈리지 말 것)
| Step | 대상 | 모델 |
|------|------|------|
| 0a, 1 | 캐릭터 5장 | `--niji 6` |
| 0b, 2 | 환경 5장 | `--v 6.1` |

---

## 2. Step 0 — sref Anchor 후보 생성 (가장 먼저)

### 2.1 Step 0a — 캐릭터 sref 후보 (CH-01 주인공)

**왜 주인공이 캐릭터 sref**: 주인공은 Tier 1 L1부터 L25까지 항상 등장 + CH-04·CH-05 표정 variant의 base + 어머니/아버지 일관성 anchor. **가장 많이 파생되므로 가장 먼저 lock**.

**MJ Discord에 그대로 붙여넣기**:
```
chibi mascot character, young Korean cooking-loving person, wearing simple beige apron over soft mustard hoodie, holding a small wooden ladle, neutral friendly smile, neutral idle pose, full body character sheet, chibi mascot character, head to body ratio 1 to 1.7, big head small body, LINE Friends meets Cookie Run aesthetic, picture book illustration, mitten hands (simplified four-finger), bean-shaped dot eyes with single highlight, soft pink circular cheek blush, no nose detail, three-quarter view, full body, character sheet on plain cream background, late afternoon golden hour soft lighting, warm rim light from upper-right, clean line art with soy-dark outline (no pure black), single-layer cel shading --ar 1:1 --stylize 300 --niji 6 --no anime girl, manga style, big sparkly eyes, school uniform, fanservice, sexy, realistic, photorealistic, 3D render, hyperdetailed, front symmetric face, individual finger detail, dark gritty
```

**절차**:
1. 위 prompt를 `/imagine`에 붙여넣고 4 variation grid 생성.
2. 4장 중 **G1·G2·G5·G6** 가장 잘 맞는 1장 골라 `U1`~`U4` 버튼으로 upscale.
3. Upscale 결과 이미지 우클릭 → **"이미지 링크 복사"** → 그 URL이 캐릭터 `--sref` 시드. 메모장에 `CHAR_SREF_URL = <붙여넣기>` 형태로 저장.
4. (선택) seed 값도 메모해 두면 재현성 ↑ (`/show <job_id>` → metadata).

**판단 기준 (4 variation 중 1장 고를 때)**:
- 머리:몸 비율 1:1.5~2 안에 들어왔나
- 손이 mitten(뭉친 4손가락)이거나 안 보이게 처리됐나 — 손가락 5개 또렷이 보이면 탈락
- 눈이 점/콩알 형태인가 — 큰 반짝이 눈동자면 탈락(anime girl 누수)
- 정면 얼굴이 아니라 3/4 시점인가
- 골든아워 따뜻한 톤이 들어왔나

**다 탈락이면**: 같은 prompt로 `/imagine` 한 번 더 (reroll). 2회 reroll 후에도 다 탈락이면 §6 트리거 표 참조하여 prompt 미세 조정 후 재시도.

---

### 2.2 Step 0b — 환경 sref 후보 (BG-01 청과상)

**왜 청과상이 환경 sref**: 5가게 중 가장 한식적·시각적으로 풍부(양배추·무·대파·천막·알전구 모두 포함) + Cabbage Green이 베이스 팔레트와도 가장 자연스럽게 어울림. 환경 톤의 anchor로 적합.

**MJ Discord에 그대로 붙여넣기**:
```
Korean traditional market vegetable shop storefront, piles of fresh cabbages, white radishes (mu), green onions in bundles, red apples and persimmons in wooden baskets, leafy greens hanging, striped red-and-blue awning above, warm string lights, handwritten price tags, wooden stall with worn texture, glimpse of neighboring shops in soft background blur, empty shop waiting for customer (no people), three-quarter view from customer perspective, eye-level slightly elevated, warm hand-painted picture book illustration, cozy stylized 2D, Korean traditional market (Namdaemun style), late afternoon golden hour lighting, warm sunlight from upper-right 45 degrees, soft cream background sky, limited palette of persimmon orange / gochu red / cabbage green / sea blue / grain tan / jang brown, clean composition, no people in foreground, shop is empty waiting for customer --ar 16:9 --stylize 200 --v 6.1 --no realistic, photorealistic, 3D render, octane, unreal engine, Japanese, Tokyo, Chinatown, anime girl, manga, dark, gritty, hyperdetailed, cluttered, text in english, korean text legible
```

**절차**:
1. 위 prompt로 4 variation grid 생성.
2. **G3·G4·G5·G7** 기준 1장 골라 upscale.
3. Upscale URL 복사 → `BG_SREF_URL = <붙여넣기>` 메모.

**판단 기준**:
- 일본 시장·중국 시장 인상이 없는가 (간판 글리프가 일본어 가타카나로 빠지면 탈락)
- 골든아워 오른쪽 위 45도 주광이 들어왔나
- 5가게 시그니처 컬러 Cabbage Green이 천막·간판에 명확히 보이나
- 천막(awning)·알전구·나무 좌판·손글씨 가격표 중 최소 3개가 화면 안에 있나
- 사람이 등장 안 했나 (인물은 Unity 레이어에서 합성, BG는 빈 가게)

---

### 2.3 Step 0 완료 체크
- [ ] `CHAR_SREF_URL` 확보 (upscale 1장)
- [ ] `BG_SREF_URL` 확보 (upscale 1장)
- [ ] 두 URL을 메모장에 저장
- [ ] Step 1·2에서 모든 prompt의 `[CHAR_SREF_URL]` / `[BG_SREF_URL]` 자리에 위 두 URL을 그대로 치환

> **주의**: Step 0a에서 뽑은 주인공 1장은 그대로 CH-01 anchor 후보가 된다 (다음 Step 1에서 별도로 다시 안 돌려도 됨 — 단, Step 1에서 sref를 부착하여 한 번 더 돌리면 더 안정된 결과 가능. 시간 절약이 우선이면 Step 1에서 CH-01은 스킵하고 Step 0a 결과를 CH-01로 채택).

---

## 3. Step 1 — 캐릭터 Anchor 5장 (niji 6)

> 각 anchor는 **prompt 1줄 → 4 variation grid → 1장 upscale → URL 기록**.
> Step 0a `CHAR_SREF_URL`을 `[CHAR_SREF_URL]` 자리에 그대로 붙여넣기.

### Anchor CH-01 — 주인공 (혼밥, base)
- **Model**: niji 6
- **Prompt**:
```
chibi mascot character, young Korean cooking-loving person, wearing simple beige apron over soft mustard hoodie, holding a small wooden ladle, neutral friendly smile, neutral idle pose, full body character sheet, chibi mascot character, head to body ratio 1 to 1.7, big head small body, LINE Friends meets Cookie Run aesthetic, picture book illustration, mitten hands (simplified four-finger), bean-shaped dot eyes with single highlight, soft pink circular cheek blush, no nose detail, three-quarter view, full body, character sheet on plain cream background, late afternoon golden hour soft lighting, warm rim light from upper-right, clean line art with soy-dark outline (no pure black), single-layer cel shading --ar 1:1 --stylize 300 --niji 6 --sref [CHAR_SREF_URL] --no anime girl, manga style, big sparkly eyes, school uniform, fanservice, sexy, realistic, photorealistic, 3D render, hyperdetailed, front symmetric face, individual finger detail, dark gritty
```
- **Parameters**: `--niji 6 --ar 1:1 --stylize 300 --sref [CHAR_SREF_URL]`
- **Variations 권장**: 4장 grid → G1~G7 가장 만족하는 1장 upscale.
- **Reroll 트리거**:
  - G2(비율) FAIL → prompt에 `oversized head, chibi 1:1.6 proportions, small body` 강조 추가
  - G6(손가락) FAIL → `mitten hands, hands hidden in apron pocket` 추가
  - G6(anime girl 누수) FAIL → `--no` 뒤에 `kawaii anime, cute anime girl, school uniform` 더 강화
- **Expected output**: 1024×1024 PNG, 캐릭터 1인 full body, 골든아워, 마스코트 톤.

> Step 0a 결과를 그대로 CH-01로 채택해도 무방 (시간 절약).

---

### Anchor CH-02 — 어머니 (Tier 2 가족, base)
- **Model**: niji 6
- **Prompt**:
```
chibi mascot character, gentle Korean mother in her early 50s, wearing modernized hanbok-inspired top (simple jeogori silhouette in soft persimmon) over modern wide-leg pants, soft round bun hairstyle with simple binyeo ornament, warm caring smile, holding a small bowl of rice, standing pose, full body character sheet, chibi mascot character, head to body ratio 1 to 1.7, big head small body, LINE Friends meets Cookie Run aesthetic, picture book illustration, mitten hands (simplified four-finger), bean-shaped dot eyes with single highlight, soft pink circular cheek blush, no nose detail, three-quarter view, full body, character sheet on plain cream background, late afternoon golden hour soft lighting, warm rim light from upper-right, clean line art with soy-dark outline (no pure black), single-layer cel shading --ar 1:1 --stylize 300 --niji 6 --sref [CHAR_SREF_URL] --sw 150 --no anime girl, manga style, big sparkly eyes, school uniform, fanservice, sexy, realistic, photorealistic, 3D render, hyperdetailed, front symmetric face, individual finger detail, dark gritty, kimono, geisha, japanese, chinese qipao
```
- **Parameters**: `--niji 6 --ar 1:1 --stylize 300 --sref [CHAR_SREF_URL] --sw 150`
- **Variations 권장**: 4장 grid → 1장 upscale.
- **Reroll 트리거**:
  - G4(한복이 일본 기모노로) FAIL → `Korean hanbok jeogori with V-shape collar, NOT kimono, NOT japanese clothing` 강화
  - G1(주인공과 다른 IP로) FAIL → `--sw 200`으로 상향, prompt 첫 줄에 `same art style as anchor reference, sibling character` 추가
  - G5(머리 정수리 비녀 폭주) FAIL → `simple round bun, minimal hair ornament` 강조
- **Expected output**: 어머니 단독 full body, 친근한 미소, 한복 모티프 단순화.

**MJ 약점 사전 경고 (FLAG)**: niji 6의 한복 묘사는 일본 기모노로 빠질 확률 ≥ 40%. 1차 시도에서 옷섶이 왼쪽으로 여며져 있거나(기모노 방향) 오비(허리띠)가 두꺼우면 즉시 reroll.

---

### Anchor CH-03 — 아버지 (Tier 2 가족, base)
- **Model**: niji 6
- **Prompt**:
```
chibi mascot character, kind Korean father in his early 50s, wearing soft brown cardigan over checkered shirt and beige apron, short salt-and-pepper hair, round friendly face, warm smile with eye crinkles, holding wooden chopsticks, standing pose, full body character sheet, chibi mascot character, head to body ratio 1 to 1.7, big head small body, LINE Friends meets Cookie Run aesthetic, picture book illustration, mitten hands (simplified four-finger), bean-shaped dot eyes with single highlight, soft pink circular cheek blush, no nose detail, three-quarter view, full body, character sheet on plain cream background, late afternoon golden hour soft lighting, warm rim light from upper-right, clean line art with soy-dark outline (no pure black), single-layer cel shading --ar 1:1 --stylize 300 --niji 6 --sref [CHAR_SREF_URL] --sw 150 --no anime girl, manga style, young anime boy, school uniform, sexy, realistic, photorealistic, 3D render, hyperdetailed, front symmetric face, individual finger detail, dark gritty, beard heavy, mustache thick
```
- **Parameters**: `--niji 6 --ar 1:1 --stylize 300 --sref [CHAR_SREF_URL] --sw 150`
- **Variations 권장**: 4장 grid → 1장 upscale.
- **Reroll 트리거**:
  - **niji 6의 흔한 실패: 아버지를 20대 anime boy로 그림** → `father in his early 50s, salt-and-pepper hair, gentle wrinkles around eyes, mature kind face` 강화 + `--no young anime boy, teenager, school student` 강화
  - G1(어머니와 페어 일관성 깨짐) FAIL → `--sw 200`, prompt에 `paired with mother character, same family, same art style anchor` 추가
- **Expected output**: 아버지 단독 full body, 카디건+앞치마, 친근한 미소.

**MJ 약점 사전 경고 (FLAG)**: niji 6는 "아버지(50대)"를 "젊은 anime boy"로 그리는 경향 ≥ 50%. 1차 시도에서 청년 얼굴이면 즉시 reroll, 머리에 흰머리 섞임 + 눈가 주름 강조.

---

### Anchor CH-04 — 주인공 Happy 표정 (★3 reaction)
- **Model**: niji 6
- **Prompt**:
```
same chibi mascot character as anchor reference, young Korean cooking-loving person in beige apron over mustard hoodie, joyful "wow delicious" expression, mouth open in delighted O-shape, sparkle hearts and tiny stars around head, both mitten hands raised to cheeks in delight, three-quarter view, bust-up portrait (head and shoulders), chibi mascot character, head to body ratio 1 to 1.7, LINE Friends meets Cookie Run aesthetic, picture book illustration, mitten hands (simplified four-finger), bean-shaped dot eyes with single highlight, soft pink circular cheek blush, no nose detail, plain cream background, late afternoon golden hour soft lighting, warm rim light from upper-right, clean line art with soy-dark outline (no pure black), single-layer cel shading --ar 1:1 --stylize 300 --niji 6 --sref [CHAR_SREF_URL] --sw 200 --no anime girl, manga style, big sparkly eyes, school uniform, fanservice, sexy, realistic, photorealistic, 3D render, hyperdetailed, front symmetric face, individual finger detail, dark gritty, sleeping, eyes closed peaceful, crying tears
```
- **Parameters**: `--niji 6 --ar 1:1 --stylize 300 --sref [CHAR_SREF_URL] --sw 200`
- **Variations 권장**: 4장 grid → 1장 upscale.
- **Reroll 트리거**:
  - G1(CH-01과 다른 캐릭터로) FAIL → `--sw 250` 상향, 의상 묘사 더 정확히 일치 (`exact same beige apron and mustard hoodie as reference`)
  - G6(입이 비대칭) FAIL → `symmetric round O-shape mouth, centered` 강조
  - sleeping/eyes-closed로 빠짐 → negative에 `sleeping, eyes closed, drowsy` 강화 (tier-1-2-flow §3.3.1 sleeping 회피 sync)
- **Expected output**: 주인공 bust-up, ★3 환희 표정, 하트/별 VFX.

---

### Anchor CH-05 — 주인공 Subtle 표정 (★1·★2 공통)
- **Model**: niji 6
- **Prompt**:
```
same chibi mascot character as anchor reference, young Korean cooking-loving person in beige apron over mustard hoodie, soft satisfied smile with slight head tilt, one mitten hand near chin in "hmm tasty" gesture, calm content expression (no stars, no hearts, eyes open looking forward), bust-up portrait, three-quarter view, chibi mascot character, head to body ratio 1 to 1.7, LINE Friends meets Cookie Run aesthetic, picture book illustration, mitten hands (simplified four-finger), bean-shaped dot eyes with single highlight, soft pink circular cheek blush, no nose detail, plain cream background, late afternoon golden hour soft lighting, warm rim light from upper-right, clean line art with soy-dark outline (no pure black), single-layer cel shading --ar 1:1 --stylize 300 --niji 6 --sref [CHAR_SREF_URL] --sw 200 --no anime girl, manga style, big sparkly eyes, school uniform, fanservice, sexy, realistic, photorealistic, 3D render, hyperdetailed, front symmetric face, individual finger detail, dark gritty, sleeping, eyes closed peaceful, sad, crying
```
- **Parameters**: `--niji 6 --ar 1:1 --stylize 300 --sref [CHAR_SREF_URL] --sw 200`
- **Variations 권장**: 4장 grid → 1장 upscale.
- **Reroll 트리거**:
  - sleeping/눈 감김으로 빠짐 → `eyes open, looking at viewer, alert content expression` 강조 + `--no sleeping, eyes closed`
  - 표정이 슬픔으로 빠짐 → `gentle satisfied smile, mild positive` 강조
- **Expected output**: 주인공 bust-up, 조용한 만족 표정, VFX 없음.

---

### 3.6 어머니/아버지 reaction variant placeholder (본 sprint 범위 외)

> **U-2 결정(어머니/아버지 L11 동시 unlock)에 따라 reaction 6컷 필요** = 어머니 ★1/2/3 + 아버지 ★1/2/3.
> **본 sprint(Week 1)는 base anchor(CH-02 어머니 1장 + CH-03 아버지 1장)만 lock**. reaction 6컷 variant는 **후속 sprint(M1 초)**에서 CH-02·CH-03의 sref를 base로 같은 패턴(CH-04·CH-05 = 주인공 표정 variant)으로 생성.
> 본 키트는 ADR-003 MVP scope 준수를 위해 양친 reaction 6컷 prompt를 본 sprint에 작성하지 않는다 — base anchor lock 우선.

| 후속 variant ID | Subject | 상속 sref |
|----------------|---------|----------|
| CH-02-S | 어머니 Subtle (★1·★2) | CH-02 lock URL |
| CH-02-H | 어머니 Happy (★3) | CH-02 lock URL |
| CH-03-S | 아버지 Subtle (★1·★2) | CH-03 lock URL |
| CH-03-H | 아버지 Happy (★3) | CH-03 lock URL |
| (CH-04, CH-05) | 주인공 표정 2종 | 본 sprint CH-04·CH-05 |

> 6컷 합계 = (어머니 S+H) + (아버지 S+H) + (주인공 S+H, 본 sprint CH-04·CH-05) = 6컷.
> Subtle/Happy 둘 다 sleeping 회피 negative 필수 (tier-1-2-flow §3.3.1 sync).

---

## 4. Step 2 — 환경 Anchor 5장 (v6.1)

> 모든 BG는 **빈 가게 (no people)** 상태. `[BG_SREF_URL]` 자리에 Step 0b URL 치환.
> 5장은 같은 시장 안의 옆가게로 인식되어야 함 (G1).

### Anchor BG-01 — 청과상 🥬 (시그니처: Cabbage Green)
- **Model**: v6.1
- **Prompt**:
```
Korean traditional market vegetable shop storefront, piles of fresh cabbages, white radishes (mu), green onions in bundles, red apples and persimmons in wooden baskets, leafy greens hanging, striped red-and-blue awning above, warm string lights, handwritten price tags, wooden stall with worn texture, glimpse of neighboring shops in soft background blur, empty shop waiting for customer (no people), three-quarter view from customer perspective, eye-level slightly elevated, warm hand-painted picture book illustration, cozy stylized 2D, Korean traditional market (Namdaemun style), late afternoon golden hour lighting, warm sunlight from upper-right 45 degrees, soft cream background sky, limited palette of persimmon orange / gochu red / cabbage green / sea blue / grain tan / jang brown, clean composition --ar 16:9 --stylize 200 --v 6.1 --no realistic, photorealistic, 3D render, octane, unreal engine, Japanese, Tokyo, Chinatown, anime girl, manga, dark, gritty, hyperdetailed, cluttered, text in english, korean text legible, people, customers, shopkeeper
```
- **Parameters**: `--v 6.1 --ar 16:9 --stylize 200 --sref [BG_SREF_URL]`
- **Variations 권장**: 4장 grid → 1장 upscale.
- **Reroll 트리거**:
  - G4(일본 시장 인상) FAIL → `Namdaemun market, Gwangjang market, Korean street market with hangul-style glyphs on signs` 강화
  - G7(낮 정오/밤 조명으로 빠짐) FAIL → `late afternoon 5pm, warm golden hour, long shadows toward lower-left` 강조
- **Expected output**: 2048×1152 PNG, 청과상 외관+매대, 빈 가게.

> Step 0b 결과를 그대로 BG-01로 채택 가능 (시간 절약).

---

### Anchor BG-02 — 정육점 🥩 (시그니처: Gochu Red)
- **Model**: v6.1
- **Prompt**:
```
Korean traditional market butcher shop storefront, white tile back wall, glass display refrigerator showing pork belly and short ribs neatly arranged, red lantern hanging at entrance, stainless steel hooks above (empty hooks, decorative only), clean wooden cutting board on counter, striped red awning, handwritten price tags in placeholder glyphs, empty shop waiting for customer (no people, no whole animal carcasses, clean and appetizing, family-friendly), three-quarter view from customer perspective, eye-level slightly elevated, warm hand-painted picture book illustration, cozy stylized 2D, Korean traditional market (Namdaemun style), late afternoon golden hour lighting, warm sunlight from upper-right 45 degrees, soft cream background sky, limited palette of persimmon orange / gochu red / cabbage green / sea blue / grain tan / jang brown, clean composition --ar 16:9 --stylize 200 --v 6.1 --sref [BG_SREF_URL] --no realistic, photorealistic, 3D render, octane, unreal engine, Japanese, Tokyo, Chinatown, anime girl, manga, dark, gritty, hyperdetailed, cluttered, text in english, korean text legible, people, customers, shopkeeper, gore, blood, hanging carcass, raw meat closeup gross
```
- **Parameters**: `--v 6.1 --ar 16:9 --stylize 200 --sref [BG_SREF_URL]`
- **Variations 권장**: 4장 grid → 1장 upscale.
- **Reroll 트리거**:
  - 잔혹·핏물 묘사 → `clean appetizing display, no blood, family friendly picture book` 강조
  - G3(빨강 채도 폭주) FAIL → `muted gochu red, not saturated, soft warm red lantern only` 조정
- **Expected output**: 정육점 외관+냉장 진열대, 마스코트 톤으로 부드럽게.

**MJ 약점 사전 경고 (FLAG)**: v6.1은 정육점을 사실적·그로테스크하게 그릴 확률 ≥ 30%. 1차 시도에서 통 카르카스(통째 동물)·핏물이 보이면 즉시 reroll.

---

### Anchor BG-03 — 어물전 🐟 (시그니처: Sea Blue)
- **Model**: v6.1
- **Prompt**:
```
Korean traditional market seafood shop storefront, shaved ice display tray with stylized cute fish (mackerel, hairtail), cuttlefish, shrimp arranged neatly, blue-striped awning above, light blue rubber gloves and stainless trays, ice crystals catching golden afternoon light, water droplet highlights, handwritten price tags in placeholder glyphs, empty shop waiting for customer (no people, stylized cute fish appetizing and picture-book friendly), three-quarter view from customer perspective, eye-level slightly elevated, warm hand-painted picture book illustration, cozy stylized 2D, Korean traditional market (Namdaemun style), late afternoon golden hour lighting, warm sunlight from upper-right 45 degrees, soft cream background sky, limited palette of persimmon orange / gochu red / cabbage green / sea blue / grain tan / jang brown, clean composition --ar 16:9 --stylize 200 --v 6.1 --sref [BG_SREF_URL] --no realistic, photorealistic, 3D render, octane, unreal engine, Japanese, Tokyo, Chinatown, anime girl, manga, dark, gritty, hyperdetailed, cluttered, text in english, korean text legible, people, customers, shopkeeper, gore, bloody fish, dead-eye fish, sushi shop, Japanese fishmonger
```
- **Parameters**: `--v 6.1 --ar 16:9 --stylize 200 --sref [BG_SREF_URL]`
- **Variations 권장**: 4장 grid → 1장 upscale.
- **Reroll 트리거**:
  - G4(일본 스시집·생선가게로) FAIL → `Korean seafood market, NOT Japanese sushi shop, NOT Tsukiji` 강화
  - 비린 사실적 묘사 → `stylized cute cartoon fish, big eyes friendly, picture book illustration` 강조
- **Expected output**: 어물전 외관+얼음 매대, 부드러운 어물 묘사.

---

### Anchor BG-04 — 곡물상 🌾 (시그니처: Grain Tan)
- **Model**: v6.1
- **Prompt**:
```
Korean traditional market grain shop storefront, burlap sacks of rice, barley, red beans, soybeans arranged in rows with open tops showing grain inside, wooden scoops (doitbak) sticking out of sacks, brass weighing scale on counter, warm tan and golden brown color palette, dust motes floating in golden afternoon light, handwritten price tags in placeholder glyphs, empty shop waiting for customer (no people), three-quarter view from customer perspective, eye-level slightly elevated, warm hand-painted picture book illustration, cozy stylized 2D, Korean traditional market (Namdaemun style), late afternoon golden hour lighting, warm sunlight from upper-right 45 degrees, soft cream background sky, limited palette of persimmon orange / gochu red / cabbage green / sea blue / grain tan / jang brown, clean composition --ar 16:9 --stylize 200 --v 6.1 --sref [BG_SREF_URL] --no realistic, photorealistic, 3D render, octane, unreal engine, Japanese, Tokyo, Chinatown, anime girl, manga, dark, gritty, hyperdetailed, cluttered, text in english, korean text legible, people, customers, shopkeeper
```
- **Parameters**: `--v 6.1 --ar 16:9 --stylize 200 --sref [BG_SREF_URL]`
- **Variations 권장**: 4장 grid → 1장 upscale.
- **Reroll 트리거**:
  - G3(전체 톤이 너무 노랗게 단일색) FAIL → `varied tones of warm tan, soft brown, cream, with red bean sack as accent` 추가
  - 마대 자루 디테일 폭주 → `simple burlap sacks, clean composition, limited detail` 강조
- **Expected output**: 곡물상 외관+마대 자루 진열, 따뜻한 황토 톤.

---

### Anchor BG-05 — 잡화점 🫙 (시그니처: Jang Brown)
- **Model**: v6.1
- **Prompt**:
```
Korean traditional market general goods shop storefront (japhwajeom), large brown onggi pottery jars holding doenjang, ganjang, gochujang, shelves of seasoning bottles, dried laver (gim) bundles, dried seaweed, warm brown and amber tones, soft golden afternoon light glowing on pottery glaze, handwritten price tags in placeholder glyphs, empty shop waiting for customer (no people, Korean onggi pottery with dark brown earthen finish), three-quarter view from customer perspective, eye-level slightly elevated, warm hand-painted picture book illustration, cozy stylized 2D, Korean traditional market (Namdaemun style), late afternoon golden hour lighting, warm sunlight from upper-right 45 degrees, soft cream background sky, limited palette of persimmon orange / gochu red / cabbage green / sea blue / grain tan / jang brown, clean composition --ar 16:9 --stylize 200 --v 6.1 --sref [BG_SREF_URL] --no realistic, photorealistic, 3D render, octane, unreal engine, Japanese, Tokyo, Chinatown, anime girl, manga, dark, gritty, hyperdetailed, cluttered, text in english, korean text legible, people, customers, shopkeeper, chinese vase, japanese ceramic, blue-and-white porcelain
```
- **Parameters**: `--v 6.1 --ar 16:9 --stylize 200 --sref [BG_SREF_URL]`
- **Variations 권장**: 4장 grid → 1장 upscale.
- **Reroll 트리거**:
  - G4(중국 청화백자·일본 도자기로) FAIL → `Korean onggi pottery, dark brown earthen jar, NOT Chinese vase, NOT Japanese ceramic, NOT blue-and-white porcelain` 강화
  - 옹기 색이 너무 검정으로 빠짐 → `warm dark brown onggi with subtle amber glaze, not pure black` 조정
- **Expected output**: 잡화점 외관+옹기 진열, 한국 옹기 정체성.

**MJ 약점 사전 경고 (FLAG)**: v6.1은 "pottery jar"를 중국 청화백자·일본 도자기로 그릴 확률 ≥ 35%. 첫 시도에서 푸른 무늬 도자기·매끈한 흰 도자기면 즉시 reroll.

---

## 5. Step 3 — 결과 평가 (art-director 인계)

### 5.1 사용자가 들고 와야 할 형식 (다음 turn schema)

각 anchor(총 10 + Step 0 후보 2)에 대해 아래 정보 1세트:

```
Anchor ID: CH-01 (또는 BG-03 등)
MJ 출력 URL: https://cdn.discordapp.com/attachments/... (upscale 1장)
또는 로컬 파일 경로: C:\Projects\kfood-game\assets-raw\2026-05-26_CH-01_v1.png
sref URL (Step 0에서 결정 후 적용): https://...
seed 값 (있으면): 1234567890
4-grid 중 선택한 칸: U2 (좌하단)
Round (1차 시도 / 2차 reroll / 3차): R1
사용자 1차 평가 메모 (선택): "어머니가 살짝 일본 느낌인데 잘 모르겠음, 판정 부탁"
```

**전체 묶음 형식 권장**: 메모장 또는 마크다운 1장에 12개 블록(Step 0 후보 2 + CH-01~05 + BG-01~05).

### 5.2 art-director가 다음 turn에 할 일
1. 12장(또는 12세트)을 `art-anchor-rubric.md` G1~G7 표에 채워 PASS/FAIL/CONDITIONAL 판정.
2. **종합 LOCK 조건**: 10 anchor 중 최소 8 LOCK + 캐릭터 sref 1 PASS + 환경 sref 1 PASS → Week 1 게이트 통과.
3. PASS → `prompts-library.md` §0 표에 sref URL·job ID·seed 영구 기록 → `art-style-guide.md` §9 anchor 표 갱신 → M1 sprint kick-off.
4. FAIL → 실패 항목별 reroll 처방 (§6 트리거 표 참조) → 사용자에게 reroll 키트 재발급.

---

## 6. Reroll 트리거 매핑 (게이트 FAIL → prompt 조정)

| FAIL 게이트 | 증상 | prompt 조정 |
|------------|------|------------|
| **G1 일관성** | 5장이 다른 IP로 보임 | `--sw 200` 또는 `--sw 250`, prompt 첫 줄에 `same art style as anchor reference, sibling character/shop` 추가 |
| **G2 비율** | 머리:몸 1:1 또는 1:3 등 chibi 깨짐 | `oversized head, chibi proportions 1 to 1.7, small compact body, mascot toy proportions` |
| **G3 컬러** | 채도 100% 폭주 또는 팔레트 이탈 | `muted palette, low saturation 60-70 percent, limited palette` 강화 + prompt 컬러 키워드 명시 |
| **G4 K-touch** | 일본·중국 시장 인상 | `Korean traditional market (Namdaemun, Gwangjang style), NOT Japanese, NOT Chinese, hangul-style glyphs` |
| **G5 mitten/eye/blush** | 손가락 5개·반짝눈·볼터치 없음 | `mitten hands four-finger simplified, bean-shaped dot eyes, soft pink round cheek blush` 강화 + `--no individual finger detail, sparkly anime eyes` |
| **G6 MJ 약점 세분화** | (아래 6.1 참조) | (각 항목별) |
| **G7 조명** | 정오·밤·차가운 조명 | `late afternoon 5pm golden hour, warm sunlight from upper-right 45 degrees, long shadows toward lower-left` |

### 6.1 G6 MJ 약점 세분화 — 즉시 reroll 트리거

| 약점 | 증상 | 즉시 reroll 트리거 prompt |
|------|------|------------------------|
| 손가락 개수 오류 | 5개 손가락 또렷이 보임 | `mitten hands, hands hidden in pocket or behind back`, `--no individual finger detail` |
| 정면 얼굴 비대칭 | 정면 얼굴이 좌우 비대칭 | `three-quarter view, 7/8 front view, slight head turn`, `--no front symmetric face` |
| 텍스트 누수 | 영문/일본어 간판 깨진 글자 | `placeholder glyphs only, no readable text`, `--no text in english, japanese kanji, korean text legible` |
| 일본 인상 누수 | 기모노·후지산·일본 간판 | `Korean style, NOT Japanese, NOT kimono, NOT Tokyo`, `--no japanese, kimono, geisha` |
| 중국 인상 누수 | 청화백자·중국 등롱 | `Korean style, NOT Chinese, NOT chinatown`, `--no chinese, qipao, blue-and-white porcelain, paper lantern chinese` |
| 3D 렌더 누수 | 매끈한 3D 셰이딩·octane 톤 | `2D illustration, hand-painted, picture book style`, `--no 3D render, octane, unreal engine, CGI, blender` |

---

## 7. 예상 소요 시간 (1차 시도 기준)

| 단계 | 작업 | 예상 시간 |
|------|------|----------|
| Step 0a | 캐릭터 sref 후보 (4 variation + upscale) | 5~10분 |
| Step 0b | 환경 sref 후보 (4 variation + upscale) | 5~10분 |
| Step 1 | 캐릭터 5장 × (4 variation + upscale) | 25~40분 |
| Step 2 | 환경 5장 × (4 variation + upscale) | 25~40분 |
| URL/seed 기록 | 메모장 정리 | 10분 |
| **총합 (reroll 없이 1차 시도)** | | **70분 ~ 110분 (≈ 1.5시간)** |

**reroll 포함 현실 예상**: 1차 시도에서 평균 3~4장 reroll 필요 → **+30~60분** → 총 **2~3시간**.

> MJ Standard plan (fast hours 15h/월) 대비 충분 (1 세션 ~2 fast hours 소비 추정).

---

## 8. 사용자 체크리스트 (세션 시작 전 확인)

- [ ] MJ Standard plan 결제 완료 + Discord에서 `/imagine` 사용 가능 확인
- [ ] 메모장(또는 노션·옵시디언) 열어 두기 — sref URL/seed 12세트 기록용
- [ ] 본 문서를 한 화면에, MJ Discord를 다른 화면에 두기 (alt-tab 최소화)
- [ ] Step 0부터 순서대로 진행 (Step 1을 먼저 시작하면 sref 부착 불가)
- [ ] 4-grid에서 1장도 만족 못 하면 같은 prompt로 reroll 1회 → 그래도 안 되면 §6 트리거 표 참조
- [ ] 모든 결과 URL을 art-director에게 §5.1 schema 형식으로 묶어 전달

---

## 9. 변경 이력
- **2026-05-24 v0.1** — 초안. Step 0 sref 후보 2장(주인공+청과상) + Step 1 캐릭터 5 + Step 2 환경 5 + Step 3 평가 인계 흐름 정의. 10 anchor copy-paste prompt + reroll 트리거 매핑(G1~G7 + G6 세분화 6항) + 예상 소요 시간(1.5h 1차/2~3h reroll 포함). U-2 양친 동시 unlock 반영 — 본 sprint는 어머니/아버지 각 base 1장, reaction 6컷은 후속 sprint placeholder(§3.6).
