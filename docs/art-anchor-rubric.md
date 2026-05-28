# Art Anchor Rubric — Week 1 게이트 평가 표 (modern mobile casual, ChatGPT)

> 버전: **v1.2 (2026-05-27, modern mobile casual sync) — supersedes v1.1**
> 작성자: art-director
> 상위 문서: [`art-style-guide.md` v1.2 §10](art-style-guide.md), [`ai-session-kit.md` v1.2](ai-session-kit.md), [`prompts-library.md` v1.2](prompts-library.md)
> 본 문서 범위: 사용자가 AI Session Kit으로 생성한 **10 anchor (CH-01~05 + BG-01~05) + Step 0 anchor 후보 2 = 12세트**를 art-director가 **G1~G7 + G_new** 게이트로 PASS/CONDITIONAL/FAIL 판정하는 rubric.
> 본 게이트 통과 = M1 art sprint 진입 prerequisite.

> **v1.2 변경 (2026-05-27, modern mobile casual sync)**: iter2 사용자 진단 "올드함" 반영, art-style-guide v1.2 sync. §1 평가 단위 무변경. §2 **G3 컬러 criteria 갱신** ("채도 75~85% + flat" → "**modern saturation 80~90% + cool/warm balance + slim outline 2~3px**"). §2 **G5 단순성 criteria 갱신** ("Crossy Road 옆 fail-test" → "**Royal Match 옆 fail-test, 베이지/scrapbook/storybook 즉시 FAIL**"). §2 G6 W3 painterly 정의에 storybook/scrapbook 누수 추가. §2 **G_new 신설** = modern mobile casual 인상 평가 항목 (dynamic pose + cool tone bg + 80~90% saturation + slim outline 4종 동시 충족 / Royal Match side-by-side test). §3 평가 표에 G_new 컬럼 추가. §4 종합 LOCK 조건 — "8 LOCK + subject anchor 2 PASS" 무변경, but G_new는 G1과 함께 critical (G_new FAIL이면 종합 FAIL). §5 ADR-005 cut anim mini-게이트 무변경. §6 Decisions Log에 iter2 라운드 추가 (G5/G_new FAIL → v1.2 reset 트리거).

> **v1.0 reset 배경 (2026-05-27)**: 사용자 art-style lock = Subway Surfers / Crossy Road / Stack 계열 flat. v0.1 mascot 7항 게이트(G1~G7)을 flat 톤 기준으로 재구성. G5는 "mitten/eye/blush 마스코트 시그니처"에서 **"단순성 (디테일 최소)"**로, G7은 "조명·시점 통일"에서 **"모바일 가독성"**으로 항목 의미 변경.

---

## 0. 한 줄 목적

> **"10 anchor 각각이 7 게이트 모두 통과하면 LOCK. LOCK이 모이면 M1 시작."**
> flat 톤은 mascot 대비 detail 적어 일관성 lock 안정성 ↑ 기대. ChatGPT는 sref 부재로 캐릭터 일관성 lock이 MJ 대비 약한 trade-off가 있으나, reference image upload + subject anchor 문장 + 같은 채팅 세션 3축 운영으로 보완.

---

## 1. 평가 단위 & 라벨

### 1.1 평가 단위
- **10 anchor** = CH-01~05 (5) + BG-01~05 (5)
- **2 subject anchor 후보** = Step 0a (캐릭터 anchor) + Step 0b (환경 anchor) — subject anchor 자체 PASS 별도 평가 (M1 sprint reference image upload 시드로 적합한가)
- 합계 **12세트**

### 1.2 셀 라벨

| 라벨 | 의미 | 후속 액션 |
|------|------|----------|
| **PASS** | 게이트 기준 충족, 그대로 사용 가능 | 다음 게이트로 진행 |
| **CONDITIONAL** | 60~80% 충족, Photoshop 보정 또는 minor reroll로 회수 가능 | art-director가 보정 vs reroll 결정 |
| **FAIL** | 60% 미만, 해당 anchor 재생성 필요 | `mj-session-kit.md` §6 reroll 트리거 적용 |

### 1.3 종합 판정 (anchor 단위)

- 7 게이트 모두 PASS → **LOCK** (anchor 확정)
- 1~2 CONDITIONAL + 나머지 PASS → **CONDITIONAL LOCK** (보정 후 LOCK)
- 1 FAIL 또는 3+ CONDITIONAL → **REROLL** (재생성)
- 2+ FAIL → **REWRITE** (prompt 재설계)

---

## 2. G1~G7 게이트 정의 & PASS 기준 (flat 톤)

### G1 — flat 일관성
- **정의**: 캐릭터 5장이 한 시트 위에서 "같은 IP"로 인식. 환경 5장이 한 시장 안 옆가게로 인식. ChatGPT는 sref 부재로 가장 취약한 항목 → reference image upload + subject anchor 문장 + 같은 채팅 세션 follow-up 3축 운영 필수.
- **PASS 기준**:
  - 캐릭터: 5장 모두 같은 outline 두께(2~4px) + 같은 features 톤(점 눈/호 입) + 같은 컬러 톤(saturated 75~85%)
  - 환경: 5장 모두 같은 천막 shape + 같은 outline 두께 + 같은 컬러 톤
  - **시각 측정**: contact sheet 2×5 → 외부인 5초 안에 "한 IP/한 시장" 답
- **FAIL 시 액션**: reference image 재첨부 + follow-up "이 reference image와 같은 outline·features·컬러 톤으로 일관성 강화" + 같은 채팅 세션에서 재생성. 안 되면 새 세션에서 anchor file을 직접 보여주며 step-by-step style transfer 요청.

### G2 — chibi 비율 + flat 단순성
- **정의**: 캐릭터의 머리:몸 1:1.5~2, mitten/nub 손, 점 눈, 호 입. 환경의 가게당 shape 1~2 (over-detail FAIL).
- **PASS 기준**:
  - 캐릭터: 머리 폭 vs 몸 길이 측정 → 1.5~2 범위. 손가락 5개 또렷이 보이면 FAIL. 눈에 반짝/홍채/속눈썹 있으면 FAIL (점만 PASS). 입 vertices 3개 초과 FAIL.
  - 환경: 가게당 시그니처 shape 2개 초과 시 CONDITIONAL, 5개 이상 시 FAIL.
- **FAIL 시 액션**: `oversized head chibi 1:1.7, mitten hands no fingers, simple dot eyes, small arc smile` 강화 / 환경은 `only 1-2 signature icons, minimal detail`

### G3 — modern saturated 컬러 (v1.2 갱신)
- **정의**: art-style-guide §6 베이스 + 가게 시그니처 안에 머묾. **채도 80~90% 범위** (v1.1 75~85% → 상향). **warm/cool 균형** (v1.2 cool tone 1+ 사용 필수 — bg 또는 accent).
- **PASS 기준**:
  - 모든 색이 §6.1 v1.2 베이스(Persimmon Vivid `#FF8A1F`, Gochu Red Vivid `#F23E3E`, Cabbage Green Vivid `#52C160`, Soft Mint `#9BE0D2`, Pastel Teal `#5FB8C4`, Cool Sage `#C8D5C0` 등) 인접 톤(±15% HSL)
  - 가게 BG는 시그니처 컬러(§3.4)가 천막/간판/주요 진열에 명확
  - 채도 spot 5개 검사 → **채도 100% 또는 70% 미만 영역 없음** (modern saturated 강조, neon 금지 + 무광 금지)
  - **cool tone 1종 이상 사용** (bg 또는 accent에 Soft Mint/Pastel Teal/Cool Sage/Accent Sea 중 1+)
  - **slim outline 2~3px** (v1.1 2~4px → 2~3px 상향 — modern Royal Match style)
- **FAIL 시 액션**: LUT 1장 일괄 color-grade. LUT 못 잡으면 `vibrant saturated 80-90 percent saturation, warm/cool balance, cool mint background` 강화 → reroll

### G4 — K-touch 명료
- **정의**: 외부인 0.5초 안에 "한국"으로 식별. 일본·중국 누수 0건.
- **PASS 기준**:
  - 캐릭터: 한복 모티프(jeogori V-collar) 또는 평범 캐주얼 — 기모노·치파오·하카마 형태 없음
  - 환경: 천막/간판/소품이 한국 재래시장 (Namdaemun/Gwangjang) — 일본 노렌·중국 등롱·후지산 없음
  - 옹기(BG-05)는 한국 onggi (dark brown earthen, round bottom) — 청화백자/매끈 흰 도자기 시 FAIL
  - 간판 글리프가 한글 닮은 placeholder block (가타카나·한자 단독 FAIL)
- **FAIL 시 액션**: `Korean traditional market (Namdaemun, Gwangjang), Korean onggi pottery, NOT Japanese, NOT Chinese` 강화

### G5 — 단순성 (modern clean, v1.2 갱신)
- **정의**: **"Royal Match 옆에 놓아도 어색하지 않은가?"** fail-test. clean modern flat + **soft 1-layer cel shading 1단 허용** (v1.2 변경). 다층 cel-shading / scrapbook / storybook / texture 누수 0. **베이지/크림/kraft paper 배경 즉시 FAIL (v1.2 LOCK)**.
- **PASS 기준** (모두 충족 시):
  - 의상/소품에 패턴/무늬 없음 (single color fill + soft 1-layer cel shading만)
  - 다층 shading layer 보이지 않음 (multi-layer cel-shading FAIL)
  - texture/noise/grain 보이지 않음 (canvas/paper/kraft texture FAIL)
  - **scrapbook/storybook/vintage 톤 0** (v1.2 신설)
  - **베이지/크림/kraft paper 배경 0** (v1.2 LOCK)
  - 캐릭터: 점 눈 + 호 입 + nub/mitten 손 3종 모두 단순
  - 환경: 가게당 시그니처 shape 1~2개만 (5개 이상 = clutter FAIL)
- **자체 question**: "이 anchor를 Royal Match screenshot 옆에 두면 같은 시대로 보이는가?" → "아니오"면 CONDITIONAL/FAIL
- **FAIL 시 액션**: `modern mobile casual game art, Royal Match aesthetic, clean modern flat, NO scrapbook, NO storybook, NO beige background, soft 1-layer shading only` 강화. negative에 `scrapbook, storybook, kraft paper, vintage, beige, cream paper, multi-layer shading` 추가.

### G6 — ChatGPT 약점 회피 (flat 특화 세분화, 10항)
- **정의**: art-style-guide §7 약점 10항(W1~W10) 중 본 anchor에서 발생 0건. ChatGPT는 MJ와 약점 분포 다름 — **한글 텍스트 깨짐(W1, Very High)**, photoreal(W2), painterly(W3), 캐릭터 일관성 lock 실패(W9, Very High) 4종이 high freq.
- **세분화 (즉시 follow-up reroll 트리거)**:

| # | 약점 (ChatGPT 특화) | PASS 기준 | 발생 시 |
|---|-------------------|----------|--------|
| W1 | **한글 텍스트 깨짐** (간판/가격표) | blank cream block placeholder, no readable text | Very High 빈도 — **후보정 default**. CONDITIONAL (Photoshop overlay). prompt에 placeholder block만 명시. |
| W2 | **photoreal / 3D render 누수** (default) | flat 2D illustration 톤, photoreal/3D render 톤 없음 | 즉시 follow-up: "이 이미지를 더 flat한 2D illustration으로, 3D render, octane, unreal, gradient mesh 제거." |
| W3 | **digital painting / painterly / storybook 누수 (v1.2)** | clean modern flat with soft 1-layer shading, painterly/hand-painted/watercolor/scrapbook/storybook 톤 없음 | 즉시 follow-up: "이 이미지를 더 clean한 modern Royal Match style로, painterly/watercolor/storybook/scrapbook 제거, single color fill + soft 1-layer shading만." |
| W4 | **손가락 detail 누수** | mitten/nub 또는 손 숨김 | 즉시 follow-up: "이 이미지를 다시 그려줘. 손을 mitten으로, no individual fingers." |
| W5 | **한식 → 일본 누수** | 기모노·노렌·후지산·sushi 없음 | 즉시 follow-up: "Korean style로 명확히, NOT Japanese, NOT kimono, NOT tokyo, NOT sushi." |
| W6 | **한식 → 중국 누수** | 청화백자·중국 등롱·치파오 없음 | 즉시 follow-up: "Korean onggi/한국 시장 톤으로, NOT Chinese, NOT chinatown, NOT qipao, NOT blue-and-white porcelain." |
| W7 | **복잡한 composition 약함 (multi-character scene)** | single subject per image | 즉시 follow-up: "single subject만 그려줘, 캐릭터/가게 따로." Multi-character는 본 sprint 범위 X (Godot 레이어 합성). |
| W8 | **자연어 prompt 길이 한계** (modifier 무시) | 핵심 modifier 모두 반영 | 즉시 follow-up 분할 — 한 번에 1~2 modifier만 강조 "이 이미지에서 X 요소만 강조해서 다시 그려줘." |
| W9 | **reference 없이 캐릭터 일관성 lock 실패** (sref 부재) | reference 캐릭터와 같은 outline·features·컬러 | 즉시 follow-up: reference image 재첨부 + "reference 캐릭터의 outline 두께·features·컬러 톤 정확히 유지." 안 되면 새 세션에서 step-by-step style transfer. |
| W10 | **anime girl / 정면 over-detail 누수** | 점 눈 + 호 입 (홍채/속눈썹/반짝 0) | 즉시 follow-up: "simple two black dot eyes, minimal facial features, NO sparkle eyes, NO school uniform." |

- **PASS 기준**: W1~W10 모두 0건
- **CONDITIONAL**: W1 한글 텍스트 깨짐 1건만 발생 + Photoshop/엔진 UI overlay 후보정 가능 (~100% 발생하므로 본 anchor 단계에서는 default CONDITIONAL 처리)
- **FAIL**: W2/W3/W4/W5/W6/W7/W9/W10 중 1건이라도 발생 (follow-up reroll 필요)

### G7 — 모바일 가독성
- **정의**: 1024×1024 anchor를 256×256으로 축소 시 캐릭터/가게/음식 식별 가능 (모바일 small screen test).
- **PASS 기준**:
  - 캐릭터: 256px 축소 시 features(점 눈/호 입) 식별 가능, 의상 컬러 block 식별
  - 환경: 256px 축소 시 가게 시그니처 컬러 + 시그니처 icon 1~2개 식별
  - outline 두께가 256px에서 보이지 않으면 FAIL (너무 얇은 1px outline)
  - 컬러 충돌(인접 색 contrast 부족) 시 CONDITIONAL
- **FAIL 시 액션**: `bold 3-4px outline, high contrast colors, mobile small screen readability` 강화 → 또는 anchor 1장에 outline 두께 보정 (Photoshop)

> **v0.1과의 차이**: v0.1 G7은 "조명·시점 통일"이었음. flat 톤은 조명 표현 거의 없어(§art-style-guide §3.2) 게이트 의미 ↓ → G7을 **모바일 가독성**으로 재배치. 시점 통일은 G1(일관성)로 흡수.

### G_new — modern mobile casual 인상 (v1.2 신설)
- **정의**: "이 anchor를 **Royal Match (Dream Games 2021) / Subway Surfers screenshot 옆에 두면 같은 시대/같은 카테고리로 보이는가?**" 외부인 5초 평가에서 "modern mobile casual" 카테고리 일치.
- **PASS 기준** (모두 충족 시):
  - **dynamic action pose** (캐릭터, 정적 standing FAIL — iter1/iter2 학습 보존)
  - **cool tone bg** (Soft Mint / Pastel Teal / Cool Sage / Cream-white 중 1, 베이지 FAIL)
  - **80~90% 채도** (muted FAIL)
  - **slim outline 2~3px** (heavy 4px+ FAIL)
  - 4종 동시 한 시트 안에 충족
  - **Cookie Run 2021 / Toca Boca / Toon Blast / scrapbook / storybook 톤 0** (즉시 FAIL)
- **FAIL 시 액션**: 즉시 follow-up: "이 이미지를 더 modern Royal Match (Dream Games 2021) style로 다시 그려줘. 베이지/scrapbook/Cookie Run 톤 완전 제거, cool mint background + dynamic action pose + 80-90% vibrant saturation + slim 2-3px outline 4종 동시 충족."
- **art-director note**: G_new는 G1과 함께 **critical** — G_new FAIL이면 다른 게이트 PASS여도 종합 FAIL (v1.2 reset 트리거 사유).

---

## 3. 평가 표 (10 anchor × 7 게이트)

> 본 표는 사용자가 결과 인계 직후 art-director가 채움.
> 빈 칸은 PASS/CONDITIONAL(C)/FAIL. N/A는 캐릭터-only 게이트에서 환경 anchor 해당 안 될 때.

### 3.1 캐릭터 anchor 평가 (v1.2 G_new 컬럼 추가)

| Anchor | G1 일관성 | G2 비율·dynamic pose | G3 modern saturated | G4 K-touch | G5 modern clean | G6 약점 회피 | G7 모바일 가독성 | G_new modernity | 종합 |
|--------|----------|---------------------|--------------------|-----------|----------------|------------|----------------|----------------|------|
| CH-01 주인공 | pending | pending | pending | pending | pending | pending | pending | pending | pending |
| CH-02 어머니 | pending | pending | pending | pending | pending | pending | pending | pending | pending |
| CH-03 아버지 | pending | pending | pending | pending | pending | pending | pending | pending | pending |
| CH-04 주인공 Happy | pending | pending | pending | pending | pending | pending | pending | pending | pending |
| CH-05 주인공 Subtle | pending | pending | pending | pending | pending | pending | pending | pending | pending |

### 3.2 환경 anchor 평가 (v1.2 G_new 컬럼 추가)

| Anchor | G1 일관성 | G2 비율·단순 | G3 modern saturated | G4 K-touch | G5 modern clean | G6 약점 회피 | G7 모바일 가독성 | G_new modernity | 종합 |
|--------|----------|-------------|--------------------|-----------|----------------|------------|----------------|----------------|------|
| BG-01 청과상 | pending | N/A(비율) | pending | pending | pending | pending | pending | pending | pending |
| BG-02 정육점 | pending | N/A(비율) | pending | pending | pending | pending | pending | pending | pending |
| BG-03 어물전 | pending | N/A(비율) | pending | pending | pending | pending | pending | pending | pending |
| BG-04 곡물상 | pending | N/A(비율) | pending | pending | pending | pending | pending | pending | pending |
| BG-05 잡화점 | pending | N/A(비율) | pending | pending | pending | pending | pending | pending | pending |

> G2의 chibi 비율 부분은 환경 N/A, 단순성(shape 1~2) 부분은 BG에도 적용 — 평가 시 단순성 측면만 채점.

### 3.3 Subject anchor 후보 평가 (Step 0)

> sref URL 대체 — reference image upload + subject anchor 문장의 일관성 시드 적합성 평가.

| anchor | 평가 기준 | 결과 |
|--------|----------|------|
| Step 0a (캐릭터, CH-01 base) | reference image style transfer test 1 PASS (CH-02~05에 upload 시 같은 IP 인식 강제 가능). subject anchor 문장이 4 variant prompt에서 그대로 복사 가능한가. | pending |
| Step 0b (환경, BG-01 base) | reference image style transfer test 1 PASS (BG-02~05에 upload 시 같은 시장 인식 강제 가능). 시그니처 컬러 + 천막 shape이 환경 anchor 시드로 적합. | pending |

---

## 4. Anchor Lock 종합 게이트

### 4.1 Week 1 PASS 조건 (v1.2 G_new 추가, 모두 충족 시 LOCK)

1. **10 anchor 중 최소 8 LOCK** (개별 anchor 8 게이트 모두 PASS — G1~G7 + G_new, W1 한글 텍스트 깨짐은 CONDITIONAL default 허용)
2. **캐릭터 anchor reference image style transfer test 1 PASS** (Step 0a) — CH-02·CH-03 같은 family 인식 가능 확인
3. **환경 anchor reference image style transfer test 1 PASS** (Step 0b) — BG-02·BG-03 같은 시장 인식 가능 확인
4. **G_new modernity 8/10 anchor 충족 (v1.2 신설 critical)** — G_new FAIL이 3 anchor 이상이면 전체 FAIL → v1.2 reset 재실행 또는 pm 에스컬레이션 (iter2의 학습 — G_new가 무너지면 다른 게이트 PASS여도 사용자 reject 위험 높음).

> 8 LOCK + subject anchor 2 PASS = Week 1 게이트 통과 → M1 sprint kick-off.

### 4.2 부분 통과 정책

| 상황 | 정책 |
|------|------|
| 9~10 LOCK + subject anchor 2 PASS | 완전 통과, 즉시 M1 진입 |
| 8 LOCK + subject anchor 2 PASS | 통과, FAIL/CONDITIONAL 2 anchor는 M1 첫 주 reroll 병행 |
| 6~7 LOCK + subject anchor 2 PASS | **CONDITIONAL** — 부족한 anchor에 1 라운드 follow-up reroll 집중 (3~5일) |
| subject anchor 1 FAIL | **FAIL** — anchor 재생성 우선, 모든 파생 anchor 재생성 |
| 5 이하 LOCK | **FAIL** — pm 에스컬레이션, prompt/스타일 재논의 |

> flat 톤은 mascot 대비 reroll 빈도 ↓ 기대 → R1에서 8 LOCK 달성 확률 향상. ChatGPT sref 부재로 G1 캐릭터 일관성 lock이 가장 큰 risk — Step 0a anchor 품질이 G1 통과 핵심.

### 4.3 Lock 후 의무

- PASS된 subject anchor 파일 경로 2 + 10 anchor 파일 경로/subject anchor 문장을 `prompts-library.md` §0에 영구 기록
- `art-style-guide.md` §11 anchor 표 placeholder → 실제 파일 경로/ChatGPT 세션 URL 갱신
- M1 sprint 모든 자산은 본 anchor file을 reference image upload + subject anchor 문장 동일 복사 의무 사용 (변경 시 pm 승인)

### 4.4 라운드 예산

- **R1 (1차 시도)**: 사용자 ~1~1.5h ChatGPT 세션, art-director 평가 0.5h
- **R2 (follow-up reroll)**: 부족 anchor 집중, 사용자 +15~30분
- **R3 (재시도)**: R2 후에도 FAIL이면 → pm 에스컬레이션

---

## 5. ADR-005 cut anim 추가 anchor 게이트 (M1 진입 시) — placeholder

> 본 sprint(Week 1)는 cut anim 평가 범위 외. M1 진입 후 별도 mini-게이트.
> ChatGPT는 frame sequence를 같은 채팅 세션 안 follow-up으로 일관성 lock (1 image per request 워크플로).

| 항목 | M1 PASS 기준 (placeholder, ChatGPT) |
|------|------------------------------------|
| 칼/도마 anchor | flat 톤 일관성 (CH/BG anchor file과 같은 outline 톤), 단순 silhouette. 1 image 생성 후 reference로 cut anim sequence에 upload. |
| Cut style 6종 frame 일관성 | 6종 모두 같은 ingredient base + cut state만 차이. 같은 채팅 세션에서 frame 1 → frame 2 follow-up "앞 frame과 동일 ingredient base, cut state만 변경"로 sequence 일관성 lock. frame 2~3개 안정. |
| ingredient cut variation 24장 | 음식 12 hero ingredient × whole+cut 2장. 같은 음식 anchor file을 reference upload하여 각 ingredient에 적용. |

> M1 sprint 진입 후 본 §5를 정식 rubric으로 확장.

---

## 6. Decisions Log

| 라운드 | 날짜 | LOCK 수 | CONDITIONAL | FAIL | subject anchor PASS | G_new PASS 수 | 종합 | art-director 메모 | pm 승인 |
|-------|------|--------|-------------|------|--------------------|---------------|------|------------------|--------|
| iter2 | 2026-05-27 | 0 | — | 10 (G5/G_new FAIL) | FAIL | 0/10 | **FAIL** | iter2 사용자 진단 "올드함" (베이지/절구/Cookie Run 2021) → v1.2 reset 트리거 | superseded |
| iter3 | TBD | pending | pending | pending | pending | pending | pending | v1.2 prompt 검증 | pending |

---

## 7. 변경 이력

- **2026-05-27 v1.2** (modern mobile casual sync, supersedes v1.1) — iter2 사용자 진단 "올드함" 반영, art-style-guide v1.2 sync. §1 평가 단위 무변경 (10 anchor + Step 0 후보 2). §2 G3 컬러 criteria 갱신 — 채도 75~85% → **80~90%** 상향 + warm/cool 균형 + slim outline 2~3px 명시. §2 G5 단순성 criteria 갱신 — Crossy Road fail-test → **Royal Match fail-test**, 베이지/scrapbook/storybook/kraft paper 배경 즉시 FAIL LOCK, soft 1-layer cel shading 허용 명시. §2 G6 W3 painterly 정의에 storybook/scrapbook 누수 추가. §2 **G_new 신설** = modern mobile casual 인상 평가 (dynamic pose + cool tone bg + 80~90% saturation + slim outline 4종 동시 충족 / Royal Match side-by-side test / Cookie Run 2021/Toca Boca/Toon Blast 톤 0). G_new는 G1과 함께 critical (G_new FAIL이면 종합 FAIL). §3 캐릭터/환경 평가 표에 G_new 컬럼 추가. §4 종합 LOCK 조건에 G_new 8/10 anchor 충족 조건 추가 (FAIL 3+ anchor면 전체 FAIL). §5 ADR-005 cut anim mini-게이트 무변경. §6 Decisions Log에 iter2 라운드 추가 (G5/G_new FAIL → v1.2 reset 트리거 superseded 표시 + iter3 pending).
- **2026-05-27 v1.1** (ChatGPT 영구 sync from MJ, supersedes v1.0) — art 도구 영구 변경 (사용자 confirm 2026-05-27). §1 평가 단위 "sref 후보 2" → **"subject anchor 후보 2"** 명칭 sync. §2 G1 PASS 기준 ChatGPT sref 부재 대비책 명시 (reference image upload + subject anchor 문장 + 같은 채팅 세션 follow-up 3축). §2 G6 약점 세분화 mascot 6항 / flat 10항(6a~6j) → **ChatGPT 약점 10항(W1~W10) 재구성**: W1 한글 텍스트 깨짐 Very High (CONDITIONAL default 후보정 default), W2 photoreal, W3 painterly, W4 손가락, W5 일본, W6 중국, W7 복잡 composition multi-character 신규, W8 자연어 prompt 길이 한계 신규, W9 reference 없이 캐릭터 일관성 lock 실패 Very High 신규 (sref 부재 대체), W10 anime girl + 정면 over-detail. CONDITIONAL/FAIL 정책 갱신 — W1만 CONDITIONAL default. §3 sref URL 컬럼 제거 → 파일 경로 + subject anchor 문장 + ChatGPT 세션 URL 컬럼 보강. §3.3 평가 표제 "sref 후보 평가" → **"Subject anchor 후보 평가"** 명칭 sync, "G1 일관성 시드로 적합" → "reference image style transfer test 1 PASS"로 평가 기준 재정의. §4 종합 LOCK 조건 "sref 2 PASS" → **"subject anchor reference image style transfer test 2 PASS"**. §4.3 Lock 후 의무 sref URL → 파일 경로 sync. §4.4 라운드 예산 사용자 R1 1.5~2.5h → ~1~1.5h sync (ai-session-kit v1.1 §7). §5 ADR-005 cut anim mini-게이트 ChatGPT 1 image per request 워크플로 + 같은 채팅 세션 follow-up sequence 일관성 lock 방식 추가. §6 Decisions Log 컬럼 "sref PASS" → "subject anchor PASS" sync.
- **2026-05-27 v1.0** (archived; MJ 기반) — scratch rewrite, hyper-casual flat. mascot 7항 게이트 → flat 톤 기준 재구성. **G5**: "mitten/eye/blush 마스코트 시그니처" → **"단순성 (디테일 최소, Crossy Road fail-test)"**. **G7**: "조명·시점 통일" → **"모바일 가독성 (256px 축소 test)"** (flat은 조명 표현 거의 없어 G7 의미 변경, 시점 통일은 G1로 흡수). **G6**: 약점 세분화를 mascot 6항(손가락/정면/텍스트/일본/중국/3D) → **flat 10항** (photoreal/painterly/texture/손가락/정면 over-detail/텍스트/일본/중국/anime/shape complex)로 확장 — flat 톤에서 가장 빈번한 누수 photoreal/painterly/texture 3종(6a/6b/6c)을 high freq로 표시. §4 종합 게이트(8 LOCK + sref 2 PASS) 무변경. §5 ADR-005 cut anim 추가 anchor 게이트 placeholder 신설 (M1 진입 시 정식화).
- **2026-05-24 v0.1** (archived; mascot 톤) — 초안. art-style-guide §10 게이트 7항을 anchor별 rubric 셀로 분해.
