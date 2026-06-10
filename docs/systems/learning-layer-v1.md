# Learning Layer v1 — Korean Food Discovery (P5)

> 버전: **v1.0 (2026-06-05)** · 작성자: game-designer
> Status: **Accepted** · [ADR-013](../decisions.md#adr-013) P5 (Polish Phase, Pillar 1+2)
> 상위 문서: [`decisions.md` ADR-013](../decisions.md#adr-013), [`product-brief-locked.md`](../product-brief-locked.md), [`result-screen-v2.md` v2.0](result-screen-v2.md)
> 데이터: [`data/learning_facts.csv`](../../data/learning_facts.csv) (신설, 12 row × 4 fact)
>
> **목표 (브리프 verbatim)**:
> - Player feeling #2: **"I learned about Korean food."**
> - "optional / never interrupt gameplay / **< 5 seconds**"
> - "increase retention, not decrease."
> - Success gate: 플레이어가 10분 후 dish / ingredient / guest를 **기억**한다.

---

## 0. 헌법 (4-line constitution)

1. **Optional, never blocking** — Learning content는 gameplay flow를 절대 막지 않는다. 무시해도 게임 진행 100% 동일.
2. **Under 5 seconds** — 한 번에 paragraph가 아닌 1~2 fact만. 자동 노출은 2.5s, 재접근은 사용자 능동.
3. **Memorable, not academic** — US 8~60세 친화. 어려운 단어 회피, "외울 만한" 한 줄 hook. 영어 primary + 한글 음식명 sub.
4. **No new system** — Result Screen 2.0(ADR-010) reveal 시점에 flavor card 패턴으로 얹는 display layer. scoring/progression/sequence 무영향.

---

## 1. 4 Fact Type

각 dish는 **4 fact**를 갖는다. 각 fact ≤ 60 char.

| fact type | 정의 | 예시 (Kimchi Stew) | CSV 컬럼 |
|-----------|------|---------------------|----------|
| **Food Fact** | 음식 한 줄 소개 (정서·맥락 hook) | "The bubbling pot that warms a cold day." | `food_fact` |
| **Ingredient Fact** | 핵심 재료 1종 spotlight | "Aged kimchi: older means deeper, tangier flavor." | `ingredient_fact` |
| **Cooking Tip** | 실전 조리 팁 1개 | "Older kimchi creates a richer, sour broth." | `cooking_tip` |
| **Culture Fact** | 한식 문화·정서 | "Shared from one pot is Korean jeong (정)." | `culture_fact` |

> **fact type별 톤 가이드**:
> - Food Fact = "이게 뭔지" + 정서적 한 줄 (3am comfort / picnic roll / rainy day).
> - Ingredient Fact = 한 재료의 영어 음차 + 짧은 설명 (Gochugaru / Danmuji / Dangmyeon / Sundubu). 영어 화자가 발음·기억 가능하게.
> - Cooking Tip = 실제로 따라할 수 있는 1개 (30s short noodles / brush sesame oil / mix from bottom). "내가 요리했다" 체감 강화.
> - Culture Fact = jeong(정) / 오방색 / 명절 feast / 학교 분식 등 한식 정서 transfer.

---

## 2. 12-Dish Fact Content (전체)

> `data/learning_facts.csv` 1:1 sync. 8 핵심 (브리프 Pillar 1 우선) + 잔여 4 = 12 음식 전체 커버.
> food_id는 foods-database.csv / recipe_xp.csv 정합 (Kimchi Stew = `m_kimchi_jjigae`, recipe_xp.csv row 존재).

### 2.1 8 핵심 dish (브리프 명시)

| # | dish (한글) | Food Fact | Ingredient Fact | Cooking Tip | Culture Fact |
|---|------------|-----------|-----------------|-------------|--------------|
| 1 | **Ramyeon** 라면 | Korea's #1 comfort food, slurped at 3am. | Gochugaru: sun-dried Korean chili flakes. | Cook noodles 30s short for the perfect chew. | An egg cracked in = instant Korean upgrade. |
| 2 | **Gimbap** 김밥 | The picnic roll every Korean kid grew up on. | Danmuji: bright yellow pickled radish crunch. | Brush the seaweed with sesame oil for shine. | Mom-made gimbap means a school field trip. |
| 3 | **Bibimbap** 비빔밥 | A rainbow bowl you mix into one bite. | Gochujang: fermented red chili paste, sweet-spicy. | Mix from the bottom so every grain gets sauce. | Five colors = five elements, balance in a bowl. |
| 4 | **Kimchi Stew** 김치찌개 | The bubbling pot that warms a cold day. | Aged kimchi: older means deeper, tangier flavor. | Older kimchi creates a richer, sour broth. | Shared from one pot is Korean jeong (정). |
| 5 | **Galbi-gui** 갈비구이 | The star of any Korean BBQ table. | Short ribs marinated in soy, pear, and garlic. | Grated pear tenderizes the beef naturally. | Grilling at the table is a shared celebration. |
| 6 | **Japchae** 잡채 | Glassy noodles that shine at every party. | Dangmyeon: chewy noodles made from sweet potato. | Toss noodles in sesame oil so they never clump. | No Korean holiday feast is complete without it. |
| 7 | **Tteokbokki** 떡볶이 | Chewy rice cakes in sweet-spicy red sauce. | Tteok: pillowy rice cakes, soft and bouncy. | Simmer the sauce till it coats every cake. | The #1 street snack outside every Korean school. |
| 8 | **Sundubu Jjigae** 순두부찌개 | Silky tofu stew that arrives still bubbling. | Sundubu: uncurdled tofu, soft as custard. | Crack a raw egg in the boiling pot to finish. | Served in a hot stone pot to stay piping hot. |

### 2.2 잔여 4 dish (full coverage)

| # | dish (한글) | Food Fact | Ingredient Fact | Cooking Tip | Culture Fact |
|---|------------|-----------|-----------------|-------------|--------------|
| 9 | **Haemul Pajeon** 해물파전 | A crispy seafood pancake for rainy days. | Buchu and squid give it the sea-and-green crunch. | High heat makes the edges crackly-crisp. | Koreans crave pajeon when the rain falls. |
| 10 | **Korean Corn Dog** 한국식 콘도그 | The viral cheese-pull street snack. | Mozzarella: the stretch that broke the internet. | Roll in sugar right after frying while hot. | A modern Korean twist that went global on social. |
| 11 | **Janchi Guksu** 잔치국수 | Warm noodle soup served at celebrations. | Somyeon: thin wheat noodles in clear broth. | Rinse noodles in cold water for a clean bite. | Janchi means feast; once a wedding-day dish. |
| 12 | **Kimchi Fried Rice** 김치볶음밥 | Leftover rice and kimchi, fried into magic. | Kimchi: fermented cabbage, Korea's soul food. | Use day-old rice so it fries up loose, not mushy. | The classic fridge-cleanout meal in every home. |

> **char count 검증**: 48 fact 모두 ≤ 60 char. 최장 = "Gochujang: fermented red chili paste, sweet-spicy." (49 char). 영어 primary, 한글 음식명만 sub (한글 본문 fact 회피 — 글로벌 화자 가독성).

---

## 3. Learning UI — Flavor Card 패턴 (mockup spec, ui-designer 후속)

> ui-designer가 result-screen-v2-layout.md에 통합. 본 §3은 UX 의도 + non-blocking 룰만 lock.

### 3.1 노출 시점 (Result Screen 2.0 emotion-first 순서 정합)

ADR-013 §4 Result Screen 순서: ① Guest reaction → ② Friendship → ③ Reward → ④ Score breakdown.
**Learning flavor card = dish reveal 직후 (① 이전, 0.5초 dish plating 연출과 동시) 또는 ① reaction과 병행 표시**.

```
[Result Screen 진입]
   │
   ▼ (완성 dish가 그릇에 담겨 reveal, 0.5s)
┌─ Flavor Card (auto, 2.5s) ───────────────┐
│  🍜 Ramyeon  라면                          │
│  "Korea's #1 comfort food, slurped at 3am."│  ← Food Fact (1개)
│  💡 Cook noodles 30s short for the chew.   │  ← Cooking Tip (1개)
│                              [ⓘ flip]      │
└────────────────────────────────────────────┘
   │  (2.5s 후 auto-dismiss, gameplay 진행 무중단)
   ▼
[① Guest reaction → ② Friendship → ③ Reward → ④ breakdown]
```

### 3.2 non-blocking 룰 (LOCKED)

- **auto-dismiss 2.5s** — 사용자 입력 없이 자동 사라짐. 게임은 그동안 Result flow 계속.
- **무시 가능** — 카드를 안 봐도 진행 100% 동일. tap-to-continue를 카드가 막지 않음 (카드 위/옆을 tap하면 즉시 dismiss + Result 진행).
- **< 5초 보장** — 1회 노출 = 4 fact 중 **1~2개만** 표시 (paragraph 아님). Food Fact는 항상 + 나머지 3 중 1개 rotation.
- **재접근 = ⓘ flip-card** — 우하단 ⓘ 아이콘 tap → 카드가 뒤집혀 4 fact 전체 노출 (이때만 능동적으로 읽기, 여전히 dismiss 자유).

### 3.3 fact rotation 룰 (반복 노출 시 신선도)

같은 음식을 반복 플레이해도 매번 같은 fact만 보면 지겨움 → rotation:

| 노출 회차 | auto 표시 fact (1~2개) |
|:--------:|------------------------|
| 1회차 (첫 cook) | Food Fact + Cooking Tip |
| 2회차 | Food Fact + Ingredient Fact |
| 3회차 | Food Fact + Culture Fact |
| 4회차+ | Food Fact만 (또는 ⓘ flip 유도) |

- rotation index = SaveManager `recipe_xp[food_id]` 레벨 또는 별도 play count로 결정 (godot-dev 선택, 신규 schema 불필요 — 기존 recipe_xp dict 재활용 권장).
- **Food Fact는 항상 anchor** (음식 정체성 한 줄 = 매번 reinforcement = 기억 강화 = success gate).

### 3.4 Encyclopedia 재접근 (선택, post-P5)

> ADR-013 brief reward 중 "Encyclopedia unlock"과 cross (P6 Critic reward에도 등장). 본 P5는 in-result flavor card만 lock.

- Critic badge unlock 또는 dish mastery 시 해당 음식 4 fact가 **도감(Encyclopedia)** 에 영구 등록 (post-P5 follow-up).
- 도감 = main menu에서 접근, 4 fact + 그릇 art + critic badge 표시. 본 sprint scope 외 (P6 §badge encyclopedia entry와 연결만 명시).

---

## 4. Retention 정당화 ("decrease 아니라 increase")

| 우려 | 완화 |
|------|------|
| 텍스트가 gameplay flow를 끊는다 | auto-dismiss 2.5s + 무시 가능 + Result flow 병행 (절대 blocking 아님) |
| 한 번 본 fact 반복 = 지겨움 | §3.3 rotation (회차별 다른 fact) + Food Fact만 anchor 유지 |
| 영어권 8세에게 어렵다 | ≤ 60 char + 일상 단어 + 한글은 음식명만 (본문 영어) |
| 학습이 게임을 무겁게 한다 | "academic" 회피 — hook/정서/실전 팁 위주 (3am / cheese-pull / jeong) |

**retention 기여 메커니즘**:
- **호기심 보상** — "왜 김치찌개는 오래 묵은 김치?"의 답을 cooking tip이 줌 → 다음 cook의 의미 부여.
- **success gate 직결** — Food Fact anchor 반복 = 10분 후 dish 기억 (브리프 ship 게이트).
- **guest 연결** — Ingredient/Culture Fact가 guest reaction("deep savory")의 맥락을 줌 → Pillar 3·4("guest enjoyed it" / "cook again") 강화.

---

## 5. godot-dev / ui-designer 후속 impl spec

### 5.1 godot-dev (P5 wire)

- **`data/learning_facts.csv` loader**: `LearningDB.get_facts(food_id) -> Dictionary` (food_fact / ingredient_fact / cooking_tip / culture_fact). 기존 MenuDB CSV loader 패턴 재활용.
- **flavor card scene**: Result Screen 2.0 진입 시 instantiate, 2.5s Timer로 auto-dismiss. AnimationPlayer fade-in 0.3s / fade-out 0.3s.
- **rotation index**: 기존 `recipe_xp[food_id]` 또는 신규 `play_count[food_id]` (SaveManager schema bump 불필요 — recipe_xp dict 재활용 권장). §3.3 표 매핑.
- **non-blocking 보장**: 카드는 Result flow Timer/입력을 **block하지 않는 별도 CanvasLayer**. tap-to-continue가 카드를 통과.
- **ⓘ flip 버튼**: tap 시 카드 뒤집어 4 fact 전체 (auto-dismiss Timer 일시정지, 카드 외부 tap 시 재개+dismiss).

### 5.2 ui-designer (P5 layout)

- result-screen-v2-layout.md에 **flavor card zone** 추가 (dish reveal 상단 또는 reaction과 병행). emotion-first 순서(ADR-013 §4)를 막지 않는 위치.
- 카드 디자인: 음식 emoji/그릇 art + 음식명(영어 primary, 한글 sub) + 1~2 fact + ⓘ flip 아이콘.
- ⓘ flip 애니메이션 spec (card flip transition).
- char ≤ 60 기준 폰트 크기/줄바꿈 (1~2 line 안에 fit, 8세 가독성).
- (선택) Encyclopedia entry 화면 spec — post-P5, P6 badge와 연결.

### 5.3 content (game-designer, 본 sprint resolved)

- [x] `data/learning_facts.csv` 12 row × 4 fact 신설
- [x] 8 핵심 + 잔여 4 = 12 음식 full coverage
- [x] char ≤ 60 검증 / 영어 primary + 한글 음식명 sub / US 8~60 친화 톤

---

## 6. 관련 문서

- [ADR-013](../decisions.md#adr-013) — Polish Phase, P5 Learning Layer (본 문서의 정식 ADR)
- [`data/learning_facts.csv`](../../data/learning_facts.csv) — 12 음식 × 4 fact (본 sprint 신설)
- [`result-screen-v2.md` v2.0](result-screen-v2.md) — flavor card 노출 시점 (emotion-first 순서 정합)
- [`food-critic-v1.md`](food-critic-v1.md) — P6, "Korean food fact unlock" reward + Encyclopedia 연결
- [`foods-database.csv`](../foods-database.csv) / [`recipe_xp.csv`](../../data/recipe_xp.csv) — food_id 정합
