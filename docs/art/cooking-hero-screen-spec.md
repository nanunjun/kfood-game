# Cooking Hero Screen Spec (P0.5) — K-Food Master

> 버전: v1.0 (2026-06-06) · 작성: art-director
> 상위: [`style-bible-v1.md`](style-bible-v1.md) (모든 시각 규약), [`art-anchor-rubric.md`](../art-anchor-rubric.md) (Hero Screenshot Test)
> 성격: **단 1장의 Cooking Screen mockup** = 모든 future art 의 benchmark. 모든 screen 재설계 X.
> 생성: **gpt-image-1** (`tools/gen_image.py`) — main thread 가 실행. 본 spec 의 §3 prompt 그대로.

---

## 1. Hero Screen 컨셉 — "뚝배기 라면, 끓는 순간" (Timing Stage)

플레이어가 3초 안에 이해해야 할 4가지(사용자 LOCK):
1. **무슨 음식** → 뚝배기 안 끓는 라면 (노란 면 + 빨간 국물 + 노른자 + 파)
2. **무슨 action** → 불 위에서 끓이는 중 (steam + 거품 + 타이밍 게이지 cue)
3. **한식이다** → 뚝배기(dolsot) + 놋그릇 곁들임 + 재래시장/분식집 톤 (Korean signal 3+)
4. **premium mobile game** → soft volumetric + warm cozy + 정돈된 UI hint + 일관 톤

### 1.1 화면 구성 (Cooking "Timing" 단계 기준)

기존 빌드의 가장 약한 화면(`phase_a_art_swap/06_timing_ramyeon.png` = 회색 사실적 냄비 + 베이지 + 빨간 awning 충돌)을 Style Bible 로 재상상한 것이 이 Hero. RESKIN benchmark.

| 영역 | 내용 |
|------|------|
| **상단** | warm wood 선반 후경 (soft depth, 옹기/뚝배기 실루엣 1~2) + 작은 손님 캐릭터 1명이 카운터 너머로 watching (Junho, 기대 표정) |
| **중앙 (영웅)** | **뚝배기(dolsot) 안 끓는 라면** — 노란 면 wave + 빛나는 빨간 국물 + 노른자 1점 + 파 + 김(steam) 2~3 가닥 올라옴. 화면 식욕 중심. 뚝배기는 warm charcoal 질그릇 + bold cocoa outline. 아래 warm 불꽃 glow. |
| **곁들임** | 옆에 작은 **놋그릇(brass)** 김치 1종 + 한식 수저 (Korean signal 보강) |
| **하단** | warm oak countertop + **타이밍 게이지 UI hint** (가로 바 + gold "perfect zone" — action cue) + persimmon "STOP" 버튼 placeholder (텍스트 없는 둥근 버튼, 텍스트는 overlay) |
| **배경** | cream `#FBF3E4` warm 키친, cool-mint 절대 금지 |

> 텍스트(STOP, % 등)는 **이미지에 넣지 않음** — placeholder block 만. Godot UI overlay 가 실제 텍스트.

---

## 2. Korean Identity Signals (최소 3개 visible — 이 mockup 은 4개)

| # | Signal | 화면 위치 |
|---|--------|----------|
| 1 | **뚝배기 (dolsot stone pot)** | 중앙 영웅 — 끓는 라면 담긴 warm 질그릇 |
| 2 | **놋그릇 (brass bowl)** | 곁들임 김치 그릇 |
| 3 | **한식 곁들임 (김치 + 한식 수저)** | 뚝배기 옆 |
| 4 | **재래시장/분식집 warm wood 선반 + 옹기 실루엣** | 후경 |

> (대체 옵션: 후경에 한글 분식집 간판 placeholder block 1개 추가 가능 — 단 텍스트 깨짐 위험으로 형태 실루엣만, 실제 글자는 overlay.)

---

## 3. gpt-image-1 생성 Prompt (main thread 실행용 — FULL TEXT)

> 아래 전체를 그대로 `--prompt` 또는 prompt 파일로. Style Bible §1.2 키워드 + Cooking Diary/Animal Restaurant/Travel Town 톤 + Korean signal 4 + Hero Test 목표 반영.

```
A warm, cozy mobile cooking game screen in the style of Cooking Diary and Animal Restaurant, with the warm wood textures and soft depth shadows of Travel Town. Hero subject: a bubbling Korean ramen boiling inside a traditional Korean dolsot stone pot (warm charcoal earthenware with a bold dark cocoa-brown outline) on a warm oak kitchen countertop. The ramen has glossy golden noodle waves, a rich deep-red warm broth, a single soft egg yolk, and chopped green scallions, with 2 to 3 soft translucent steam wisps rising from the surface and a gentle warm orange fire glow underneath. Beside it, a small Korean brass bowl of kimchi and a Korean spoon as a side dish. In the warm cream-colored background, soft-focus wooden shelves hold blurred silhouettes of Korean onggi pottery jars and small stone pots, giving cozy depth layers. In the upper area, one friendly chibi character with a rounded storybook face and soft 2-tone shading watches eagerly over the counter with an excited smile. At the bottom, a hint of clean rounded mobile game UI: a soft horizontal timing gauge bar with a glowing gold target zone, and one large rounded warm-persimmon action button (no text, blank placeholder). Soft volumetric hand-drawn illustration, muted warm beige-cream-oak palette with persimmon and gold accents, soft drop shadows, rounded soft shapes, premium but warm and inviting, polished casual mobile game art. Vertical phone composition.

Important: avoid Royal Match style, glossy plastic, over-saturated neon, cool mint or teal background, flat single color fill, hyper-casual minimalism, scrapbook noise texture, grunge, photorealistic, 3D render, octane, unreal engine, anime girl, manga, Japanese, kimono, sushi, ramen-shop noren, Chinese, qipao, chinese lantern, Italian flag awning, golden hour overexposed, any text, letters, words, or Korean characters.
```

### 3.1 실행 명령 (main thread — PowerShell)

```powershell
# 1순위: 세로 hero (phone 비율), 고품질
py tools/gen_image.py `
  --prompt-file docs/art/_hero_prompt.txt `
  --out assets-raw/hero/cooking_hero_ramen_v1.png `
  --model gpt-image-1 --size 1024x1536 --quality high --background opaque
```

> prompt 가 길어 `--prompt-file` 권장. §3 코드블록 전체를 `docs/art/_hero_prompt.txt` (UTF-8) 로 저장 후 실행.
> 대안 size: `1024x1536` (phone 세로) 권장. 가로 비교용은 `1536x1024`.

### 3.2 Iteration 가이드 (follow-up reroll)

- cool-mint 누수 시: "배경을 cool mint 대신 warm cream/beige, Animal Restaurant cozy 톤으로 다시."
- 음식이 작거나 안 식욕적: "뚝배기 라면을 화면 중심으로 더 크게, 식욕나게, 김을 더 또렷이."
- glossy 폭주: "glossy plastic 느낌 줄이고 hand-drawn soft shading 으로, 윤기는 국물 표면 1~2점만."
- 한식 signal 약함: "뚝배기 + 놋그릇 + 김치를 더 또렷한 한식 형태로, 일본/중국 톤 제거."
- 텍스트 깨짐 출력: "모든 글자/숫자 제거하고 빈 placeholder block 으로."

---

## 4. 합격 기준 — Hero Screenshot Test (style-bible §9.2)

생성물이 아래 6+/7 (HT4 한식 + HT7 일관성 필수) 충족 시 LOCK → 모든 future art benchmark.

| # | 질문 | 이 mockup 목표 |
|---|------|---------------|
| HT1 | 무슨 게임? | 쿠킹 게임 (뚝배기+불+게이지) |
| HT2 | 무슨 음식? | 라면 (면+국물+노른자) |
| HT3 | 무슨 action? | 끓이는 중 + 타이밍 (steam + 게이지 + STOP 버튼) |
| HT4 | 어느 나라? | **한국** (뚝배기+놋그릇+김치+옹기 = 4 signal) ★필수 |
| HT5 | premium? | soft volumetric + 정돈 UI + warm cozy |
| HT6 | cozy? | warm cream/oak + 친근 손님 캐릭터 |
| HT7 | 일관성? | 음식/캐릭터/UI/배경 모두 cozy premium-casual 단일 톤 ★필수 |

FAIL 시 §3.2 follow-up 으로 최대 3 라운드 reroll → 3 라운드 FAIL 시 pm 에스컬레이션.

---

## 5. Before / After

- **Before**: `assets-raw/_screenshots/phase_a_art_swap/06_timing_ramyeon.png` — 회색 **사실적 metallic 냄비** + 베이지 그라데이션 + **빨간 줄무늬 awning(이탈리아 톤)** + 회색 게이지. 톤 충돌(realistic pot ↔ flat UI), 한식 signal 0, 음식 안 보임(빈 냄비).
- **After (이 Hero)**: 뚝배기 끓는 라면(식욕 영웅) + 놋그릇 김치 + warm oak + 손님 watching + persimmon STOP + gold 게이지. 한식 signal 4, 단일 cozy 톤, Hero Test 6+/7 목표.
