# Dish-Specific Recipe Correctness Matrix v1

> 작성: game-designer · 2026-06-07 · 트리거: 사용자 "Players should feel they are making a *specific* Korean dish, not random cooking modules with random assets."
> 상태: **PROPOSAL — matrix + audit only. 구현 보류 (승인 대기).**
> 범위: NO new systems / NO new dishes / NO new monetization. scoring·progression 정합 (기존 levels/balance 범위). cooking-fun-redesign(progression-and-variety)와는 **별개** — 본 문서는 recipe correctness layer.
> 상위/관련: [`cooking-modules-v1.md` v1.2](../systems/cooking-modules-v1.md), [`cooking-mechanics.md` v0.7](../systems/cooking-mechanics.md), [`data/dish_modules.csv`](../../data/dish_modules.csv), [`docs/foods-database.csv`](../foods-database.csv), [`docs/ingredients-database.csv`](../ingredients-database.csv), [`godot-project/scripts/gameplay/art_registry.gd`](../../godot-project/scripts/gameplay/art_registry.gd)

---

## 0. 왜 지금 "random" 느낌인가 (핵심 진단)

세 가지 layer가 각각 따로 맞춰져 있고, **dish identity를 하나로 묶는 "recipe correctness" layer가 없다.**

1. **Data layer는 비교적 정확** — `docs/foods-database.csv` / `docs/ingredients-database.csv`는 dish별 ingredient가 잘 정의됨 (떡볶이=어묵·떡·고추장, 비빔밥=당근·시금치·콩나물·밥·계란·고추장 등).
2. **Asset-mapping layer(`art_registry.gd`)가 data를 무시하고 substitute로 채움** — standalone sprite가 8 ingredient(green_onion/carrot/kimchi/tofu/beef/egg/rice/noodle)밖에 없어, 모든 dish의 slice/stir/timing이 **"제일 가까운 8개 중 하나"로 강제 매핑**된다. 그래서:
   - 떡볶이 slice = `["green_onion","chopped"]` (어묵 sprite 없음 → 대파로 대체)
   - 갈비 slice = `["green_onion","chopped"]` (마늘 sprite 없음 → 대파)
   - 불고기 stir = `["beef","cooked"]`, 떡볶이 stir = `["kimchi","cooked"]` (떡볶이에 김치 pile 표시 = 사용자 발견 #3)
   - 순두부 timing = `["tofu","block→cubed"]`이지만 stew 안 끓는 연출 아님
3. **Module layer는 generic** — slice/stir/season/plate가 어떤 dish든 같은 vessel·같은 motion·같은 양념병. Plate는 vessel 선택이 점수(best/2nd/bad)에만 연결되고 **실제로 그 그릇에 음식이 담기지 않는다** (사용자 발견 #4).

결론: **재료·도구·그릇·visual state를 dish_id 단위로 "정답 1세트"로 묶는 lock table이 없다.** 본 문서가 그 table을 정의한다. 구현은 art_registry의 substitute 매핑을 dish-correct 매핑으로 교체 + 누락 asset 생성 (승인 후).

---

## 1. Recipe Correctness Layer — 7-field 정의 (모든 dish 공통 schema)

각 dish는 다음 7개로 lock:

1. **Correct core ingredients** (반드시 등장 — Stage 1 정답 + cooking 중 표시)
2. **Correct prepared states** (각 재료가 cooking 중 어떤 cut/cooked 상태로 보여야 하는가)
3. **Correct tools** (slice 칼/도마, cook vessel, active tool)
4. **Correct vessels** (cook vessel + plate vessel — 둘 다 dish-correct)
5. **Correct module sequence** (현 `dish_modules.csv`와 대조)
6. **Correct visual state per module** (각 module이 화면에 무엇을 보여야 하는가)
7. **Banned wrong assets** (이 dish에서 절대 나오면 안 되는 것)

---

## 2. 12-Dish Recipe Matrix

> mvp v2.2 12 dish. **주의**: 김치찌개(`m_kimchi_jjigae`)는 mvp v2.2에서 **불고기(t2_014)로 교체**됨. 사용자 예시 "Kimchi Stew"는 가장 유사한 stew인 **순두부찌개(Sundubu Jjigae, t2_013)**에 적용한다. `m_kimchi_jjigae`/`m_doenjang_jjigae`/`m_maeuntang`은 `godot-project/data/dish_modules.csv`에만 잔존하는 **stale 행** (audit §A-0 참조).

---

### 2.1 Ramyeon — 라면 (t1_002) · Tier 1

| field | 값 |
|---|---|
| core ingredients | ramyeon noodle(라면사리), green onion(대파), egg(계란), ramyeon soup powder(스프) |
| optional | seaweed(김) garnish |
| **banned** | 김치 pile, 당근, 두부, 면 외 곡물(밥·당면·소면) |
| prepared states | green onion → **chopped (송송, CUT-05)** / noodle raw → cooked / egg → cracked-in (whole→cooked) |
| tools | chef_knife + cutting_board (slice) · **pot** (cook) |
| vessels | cook=pot / **plate=noodle_bowl (양은냄비/사발)** |
| module sequence | **Slice → Timing → Season → Plate** (현 CSV 일치 ✅) |
| visual per module | Slice: 대파 송송 / Timing: pot에서 면 raw→cooked + 끓는 거품 / Season: 스프(붉은) 가루 1-tap, 면 위 / Plate: noodle_bowl에 담긴 라면 + 계란/김 |
| learning principle | "라면은 끓이는 9초 타이밍이 전부" (timing signature) |
| guest hook | spicy 0.6 / umami 0.6 — "3am comfort"; ★3 = 후루룩 슬랍 |

---

### 2.2 Tteokbokki — 떡볶이 (t1_003) · Tier 1

| field | 값 |
|---|---|
| core ingredients | rice cake(떡, **NOT 김치**), fish cake(어묵), gochujang(고추장), green onion(대파) |
| optional | 삶은 계란, 양배추 |
| **banned** | **김치 (사용자 발견 #3 — 현재 stir에 김치 pile 표시됨)**, 당근 julienne, 두부, 면류 |
| prepared states | fish cake → **어슷썰기 (diagonal, CUT-03)** / rice cake → whole(가래떡 단면) / gochujang sauce coating |
| tools | chef_knife + cutting_board · **frying_pan/얕은 냄비** (졸이기) · spatula |
| vessels | cook=frying_pan / **plate=wide_plate (빨간 분식 접시)** |
| module sequence | **Slice → Season → Stir → Timing → Plate** (현 CSV 일치 ✅) |
| visual per module | Slice: 어묵 어슷 5조각 / Season: 고추장 dollop(붉은 paste) / **Stir: 떡+어묵을 빨간 고추장 양념에 졸이기 (NO 김치)** / Timing: 빨간 윤기 sauce 졸아듦 / Plate: 빨간 떡볶이 |
| learning principle | "고추장 양념을 떡에 졸이는 stir+season" |
| guest hook | spicy 0.8 — "#1 street snack"; ★3 = 빨간 윤기 |

---

### 2.3 Gimbap — 김밥 (t1_004) · Tier 1

| field | 값 |
|---|---|
| core ingredients | seaweed(김), rice(밥), danmuji(단무지·노란), carrot(당근), spinach(시금치), egg(계란지단), ham/소시지 |
| optional | 오이, 우엉 |
| **banned** | 고추장/김치(매운 재료 — 김밥은 mild), 면류, 두부 |
| prepared states | 재료 모두 **긴 strip (long-band)** / rice 펼침 / 완성 후 통썰기(CUT-04 round) cut |
| tools | **rolling_mat (김발)** + chef_knife (cut) |
| vessels | cook=없음(no-cook) / **plate=wooden_tray (도마 cut layout)** |
| module sequence | **Arrange → Roll → Slice → Plate** (현 CSV 일치 ✅) |
| visual per module | Arrange: 김 위에 5색 strip(단무지·당근·시금치·계란·햄) 가로 band 정렬 / Roll: 김발 forward drag 말기 (halfway→finished) / Slice: 완성 roll 8조각 통썰기 / Plate: wooden_tray에 cut 8조각 layout |
| learning principle | "5색 정렬 → 김발 말기 → 통썰기" 3-ceremony |
| guest hook | savory 0.5 — "소풍 도시락 정서"; ★3 = 깔끔한 단면 |

> Roll 자산은 이미 long-strip wide layout 보유 (`roll/*_strip_long.png` 7종 — audit §B 참조). 김밥 correctness는 **자산 거의 충족** (가장 정확한 dish).

---

### 2.4 Kimchi Fried Rice — 김치볶음밥 (t1_005) · Tier 1

| field | 값 |
|---|---|
| core ingredients | kimchi(김치), rice(밥), egg(계란프라이), green onion(대파), ham/소시지 |
| optional | 김가루, 참기름 |
| **banned** | 고추장(김치볶음밥은 김치 자체가 매운맛 — gochujang 불필요), 면류, 두부 |
| prepared states | kimchi → **깍둑썰기 (diced, CUT-06)** / rice → whole bowl / egg → fried (whole→cooked) |
| tools | chef_knife + cutting_board · **frying_pan/wok** · spatula |
| vessels | cook=frying_pan / **plate=wide_plate + 계란프라이 위** |
| module sequence | **Slice → Stir → Timing → Plate** (현 CSV 일치 ✅) |
| visual per module | Slice: 김치 깍둑 / **Stir: wok에서 김치+밥 볶기 (빠른 작은 원, kimchi_cooked sprite — 여기는 김치 정답)** / Timing: 볶기 / Plate: 둥근 접시 + 계란프라이 |
| learning principle | "wok 강불 볶기 + 김치 향" |
| guest hook | spicy 0.6 / 발효 — "냉장고 털이"; ★3 = 고슬고슬 |

---

### 2.5 Haemul Pajeon — 해물파전 (t1_006) · Tier 1

| field | 값 |
|---|---|
| core ingredients | scallion(쪽파), pancake batter(부침가루+계란), squid(오징어), shrimp(새우), clam(조개) |
| optional | 홍고추, 간장 dip |
| **banned** | 고추장/김치, 떡, 밥/면, 소고기 |
| prepared states | scallion → **송송썰기 (fine, CUT-05)** / 해물 → whole(통) / batter → 부침 panfry / **flip 뒤집기** |
| tools | chef_knife + cutting_board · **frying_pan (panfry)** · spatula/뒤집개 |
| vessels | cook=frying_pan / **plate=wide_plate (부침개 도마) + 간장+식초 종지** |
| module sequence | **Slice → Flip → Timing → Plate** (현 CSV 일치 ✅) |
| visual per module | Slice: 쪽파 송송 / Flip: 둥근 전을 panfry 위에서 flick 뒤집기(MVP single, C-3) / Timing: 가장자리 crisp / Plate: 둥근 부침개 + 간장 dip |
| learning principle | "비 오는 날 전 부치기 — flip 타이밍" |
| guest hook | oily 0.6 — "비 오는 날"; ★3 = crispy edge |

> 현 `flip_module` FLIP_FOOD 매핑 = `["beef","raw","cooked"]` (소고기 sprite). **전(pancake) 자산 없음 → 소고기로 대체 중 = 오류 (audit §A-3).**

---

### 2.6 Korean Corn Dog — 한국식 콘도그 (t1_007) · Tier 1

| field | 값 |
|---|---|
| core ingredients | sausage(소시지), mozzarella(모짜렐라), batter(부침가루/반죽), bread crumb(빵가루), sugar(설탕) |
| optional | 케첩, 머스타드 |
| **banned** | 고추장/김치, 채소 cut, 면/밥, 소고기 |
| prepared states | 소시지+모짜렐라 꼬치 → batter dip(DIP-00) → 빵가루 코팅 → deepfry → 설탕 |
| tools | **batter bowl (DIP)** · 꼬치 · 튀김 vessel (frying_pan 대체) |
| vessels | cook=frying_pan(deepfry) / **plate=wooden_tray (꼬치 stand) + 설탕/케첩 stripe** |
| module sequence | **Slice → Flip → Timing → Plate** (현 CSV — slice는 DIP-00 substitute) |
| visual per module | Slice/Dip: 칼 cut 대신 **batter bowl에 dip 3회** / Flip: 회전 dip flip / Timing: 튀김 8s 갈색화 / Plate: 꼬치 stand + 설탕 |
| learning principle | "칼질 없는 dip+튀김 — 치즈 스트레치" |
| guest hook | sweet 0.5 / oily — "viral SNS"; ★3 = 치즈 pull |

> 콘도그는 slice가 cut이 아닌 **batter dip substitute** (foods-database `prep_cut_style=DIP-00`). 현 art_registry slice 매핑 = `["green_onion","chopped"]` placeholder = 오류 (audit §A-3).

---

### 2.7 Janchi Guksu — 잔치국수 (t1_008) · Tier 1

| field | 값 |
|---|---|
| core ingredients | somen(소면), anchovy broth(멸치 육수), egg garnish(계란지단), seaweed(김), green onion(대파), zucchini(애호박) |
| optional | 다진마늘, 간장 양념 |
| **banned** | 고추장/김치(잔치국수는 mild clear broth), 라면사리/당면, 두부, 소고기 |
| prepared states | green onion → 송송(CUT-05) / egg → 지단 strip / somen → cooked / 맑은 육수 |
| tools | chef_knife + cutting_board · **pot (육수 boil)** |
| vessels | cook=pot / **plate=noodle_bowl (흰 사발)** |
| module sequence | **Slice → Timing → Arrange → Plate** (현 CSV 일치 ✅) |
| visual per module | Slice: 대파 송송 / Timing: 맑은 육수 boil 12s / Arrange: 고명(계란지단·김·쪽파) 면 위 radial 정렬 / Plate: 흰 사발 맑은 국물 |
| learning principle | "잔치 면 — 맑은 육수 + 정성 고명 arrange" |
| guest hook | mild/umami 0.7 — "잔칫날"; ★3 = 정갈한 고명 |

> 현 art_registry에 **소면(somen) 자산 없음** → noodle(라면사리)로 대체. timing TIMING_FOOD = `["noodle","raw","cooked"]`. 시각상 라면면과 구분 안 됨 = 약한 오류 (audit §A-5).

---

### 2.8 Bibimbap — 비빔밥 (t2_008) · Tier 2 · **사용자 상세 예시 dish**

| field | 값 |
|---|---|
| core ingredients | rice(밥 base), carrot(당근), spinach(시금치), bean sprout(콩나물), beef(소고기·다짐), egg(계란 후라이/노른자), **gochujang(고추장 — paste)** |
| optional | 애호박, 도라지, 참깨, 김가루 |
| **banned** | **gochugaru(고춧가루 가루 — 사용자 발견 #10: 비빔밥은 gochujang paste여야 함)**, 면류, 김치, 양념병(seasoning bottle) |
| prepared states | carrot → 채썰기(julienne CUT-02) / 나물 데침 / beef 다짐 cooked / egg 후라이 / **gochujang = dollop(붉은 paste 한 덩이)** |
| tools | chef_knife + cutting_board · **spoon/비빔 그릇** (mix) |
| vessels | cook=dolsot(돌솥) 또는 brass_bowl / **plate=brass_bowl (놋그릇, 사용자 발견 #11: vessel 틀림) + 참깨** |
| module sequence | **Slice → Arrange → Season → Stir → Plate** (현 CSV 일치 ✅) |
| visual per module | Slice: 당근 채썰기 / **Arrange: rice base 위 radial 색 toppings (당근·시금치·콩나물·소고기·계란 — 오방색)** / **Season: gochujang dollop 중앙에 한 덩이 (NOT 고춧가루 bottle)** / **Stir: bowl mix — 밥+나물 비비기 (NO noodles, 사용자 발견 #12 cross-ref: bowl churn)** / **Plate: brass_bowl(놋그릇) 안에 비빔밥 (선택 vessel 안에 실제로 담김)** |
| learning principle | "5색 = 오방색 균형 / 바닥부터 비비기 / 고추장 paste" |
| guest hook | spicy 0.5 — "rainbow bowl, 5색 = 5 elements"; ★3 = 균일 비빔 |

> **사용자 상세 예시 verbatim 반영**: Arrange=rice base + radial 색 toppings / Season=gochujang dollop NOT gochugaru bottle / Stir=bowl mix NO noodles / Plate=선택 vessel(놋그릇) 안.
> 현 자산: `bibimbap_content_only.png` 보유 (Plate에서 brass_bowl과 합성 가능 — 유일하게 content_only 있는 dish). stir STIR_FOOD = `["beef","cooked"]` (비비기는 beef churn — noodle 아님 ✅, but rice/나물 mix 시각 부재).

---

### 2.9 Japchae — 잡채 (t2_010) · Tier 2

| field | 값 |
|---|---|
| core ingredients | glass noodle(당면), carrot(당근), spinach(시금치), shiitake(표고), beef(소고기·strip), 간장, 참기름 |
| optional | 양파, 목이버섯, 계란지단 |
| **banned** | 라면면/소면, 고추장/김치(잡채는 mild 간장 base), 두부 |
| prepared states | carrot → 채썰기(CUT-02) / 당면 cooked(투명 윤기) / beef strip / 간장+참기름 코팅 |
| tools | chef_knife + cutting_board · **frying_pan/chopsticks** (toss) |
| vessels | cook=frying_pan / **plate=wide_plate (백자 접시) + 참깨** |
| module sequence | **Slice → Arrange → Stir → Timing → Plate** (현 CSV 일치 ✅) |
| visual per module | Slice: 당근 채썰기 / Arrange: 6색 채소 정렬 / **Stir: 당면 toss (좌우 swipe, noodle_cooked sprite — 여기는 면 정답)** / Timing: 볶기 16s / Plate: 백자 접시 윤기 당면 |
| learning principle | "당면 toss — 명절 정서 / 간장 base mild" |
| guest hook | sweet 0.5 / umami — "명절 잔치"; ★3 = 윤기 당면 |

---

### 2.10 Galbi-gui — 갈비구이 (t2_012) · Tier 2

| field | 값 |
|---|---|
| core ingredients | LA갈비/꽃갈비(beef rib), garlic(마늘·다짐), pear(배), green onion(대파), 간장, 설탕, 참기름, 깨 |
| optional | 후추, 양파 |
| **banned** | 면/밥, 고추장/김치, 두부, 떡 |
| prepared states | garlic → **다지기(mince CUT-01, 140 BPM)** / 갈비 whole(bone-in) / 양념 코팅 / grill 양면 |
| tools | chef_knife + cutting_board · **grill_pan** · tongs(집게) |
| vessels | cook=grill_pan / **plate=wide_plate (긴 grill 플레이트) + 쌈채소 사이드** |
| module sequence | **Slice → Season → Timing → Flip → Plate** (현 CSV 일치 ✅) |
| visual per module | Slice: **마늘 다지기 (빠른 down-stroke 山)** / Season: 양념 1-tap(간장+설탕+참기름) / Timing: grill perfect 좁음(0.04) "BBQ는 타이밍" / Flip: 집게로 양면 grill flip / Plate: 긴 plate 양면 grill |
| learning principle | "BBQ는 타이밍이 핵심 (perfect 좁음) / 배로 연육" |
| guest hook | savory/umami 0.7 — "BBQ 잔치"; ★3 = 그릴 자국 |

> 현 slice 매핑 = `["green_onion","chopped"]` (마늘 sprite 없음 → 대파 대체 = 오류 #A). flip = `["beef","raw","cooked"]` (갈비는 beef 정답 ✅).

---

### 2.11 Sundubu Jjigae — 순두부찌개 (t2_013) · Tier 2 · **사용자 "Kimchi Stew" 예시 reconcile dish**

| field | 값 |
|---|---|
| core ingredients | soft tofu(순두부), kimchi(김치·매운 base), anchovy(멸치 육수), gochugaru(고춧가루), zucchini(호박), egg(계란), green onion(대파) |
| optional | 바지락, 돼지고기 |
| **banned** | 면/밥, 고추장 dollop(순두부는 gochugaru 가루 base — 비빔밥과 반대), 양념병 위 placement |
| prepared states | zucchini → 통썰기(round CUT-04) / **tofu = 끓는 뚝배기 속에서 자연 분쇄 (block→broken in stew, NOT cubed pile)** / **kimchi = stew 안에 잠김 (NOT bowl 위 placed — 사용자 발견 #9)** / egg → 깨서 풀기 |
| tools | chef_knife + cutting_board · **earthenware_bowl(뚝배기)** (boil) |
| vessels | cook=earthenware_bowl / **plate=earthenware_bowl (검은 뚝배기) + 계란** |
| module sequence | **Slice → Timing → Season → Plate** (현 CSV 일치 ✅) |
| visual per module | Slice: 호박 통썰기 / **Timing: 뚝배기 안에서 보글보글 끓기 — 순두부+김치 stew 안에 잠김, 거품/김** / Season: 고춧가루(가루 톡톡) + 계란 crack-in / Plate: 검은 뚝배기 보글보글 + 계란 노른자 |
| learning principle | "stew = 재료가 국물 안에 잠겨 끓는다 (위에 올리는 게 아님)" |
| guest hook | spicy 0.7 / umami — "돌솥 보글보글"; ★3 = 끓는 거품 |

> **사용자 "Kimchi Stew" 예시 reconcile**: kimchi가 stew 안에 잠겨야 함 (현 timing TIMING_FOOD = `["tofu","block","cubed"]` → 두부 cube pile만, 김치도 stew 잠김도 없음 = 오류 #A-9). gochugaru = 가루(season powder) — 비빔밥 gochujang dollop과 명확히 구분.

---

### 2.12 Bulgogi — 불고기 (t2_014) · Tier 2 · **사용자 상세 예시 dish (김치찌개 supersede)**

| field | 값 |
|---|---|
| core ingredients | thin-sliced beef(얇은 소고기), 간장, pear(배), garlic(다진마늘), 설탕, 참기름, onion(양파), shiitake(표고), green onion(대파) |
| optional | 당근, 당면 사리(전골식 — MVP 제외) |
| **banned** | **noodle/면 (사용자 발견 #12: 불고기가 noodle visual 사용 중)**, 고추장/김치, 두부 |
| prepared states | **beef = 얇은 슬라이스 fan (marinade, NOT noodle, NOT minced)** / 양념재우기 marinade(MAR-00 60 BPM 마사지) / onion 채썰기(부 hero) / stir 양념 코팅 |
| tools | **marinade bowl(손바닥 마사지)** · chef_knife · frying_pan · spatula |
| vessels | cook=frying_pan / **plate=brass_bowl(무쇠/유기 그릇) + 쪽파** |
| module sequence | **Season(marinade) → Slice → Stir → Timing → Plate** (현 CSV 일치 ✅, dish_modules는 `season|slice|stir|timing|plate`) |
| visual per module | **Season(marinade): 얇은 소고기를 marinade bowl에서 마사지 (beef_marinated sprite)** / Slice: 양파 채썰기 / **Stir: 양념 코팅 볶기 — 얇은 고기+양파 (NO noodle sprite)** / Timing: 볶기 16s / Plate: 무쇠 그릇 양념 코팅 + 쪽파 |
| learning principle | "양념재우기 = 한국 가정 손맛 마사지 / 얇은 고기" |
| guest hook | sweet 0.5 / umami 0.7 — "K-BBQ 시그니처"; ★3 = 윤기 코팅 |

> **사용자 발견 #12 반영**: 불고기 stir이 noodle/mixing visual 사용 중 — 현 STIR_FOOD = `["beef","cooked"]`인데 (✅ beef), 그러나 stir variant inference에서 `t2_014`가 명시 안 됨 → `default` 또는 잡채와 혼동 위험. beef_marinated sprite 보유 ✅ (marinade에서 사용 가능).

---

## 3. 12-Dish 요약 표 (correct ingredient / vessel / module / banned)

| dish | correct core | cook→plate vessel | signature module | **banned** |
|---|---|---|---|---|
| 라면 | 면·대파·계란·스프 | pot → noodle_bowl | Timing(끓이기) | 김치·당근·두부 |
| 떡볶이 | 떡·어묵·고추장·대파 | frying_pan → wide_plate | Stir+Season | **김치**·면·두부 |
| 김밥 | 김·밥·단무지·당근·계란·햄 | (no-cook) → wooden_tray | Roll | 고추장·면·두부 |
| 김치볶음밥 | 김치·밥·계란·대파 | frying_pan → wide_plate | Stir(wok) | 고추장·면·두부 |
| 해물파전 | 쪽파·해물·부침가루 | frying_pan → wide_plate | Flip | 고추장·떡·소고기 |
| 콘도그 | 소시지·모짜렐라·반죽·빵가루·설탕 | frying_pan → wooden_tray | Flip(dip) | 채소cut·면·소고기 |
| 잔치국수 | 소면·멸치육수·계란·김·대파 | pot → noodle_bowl | Timing+Arrange | 고추장·김치·당면 |
| 비빔밥 | 밥·당근·시금치·콩나물·소고기·계란·**고추장** | dolsot/brass → **brass_bowl** | Arrange+Stir | **고춧가루병**·면·김치 |
| 잡채 | 당면·당근·시금치·표고·소고기·간장 | frying_pan → wide_plate | Stir(toss) | 소면·고추장·두부 |
| 갈비구이 | 갈비·마늘·배·대파·간장·설탕 | grill_pan → wide_plate | Timing(좁음)+Flip | 면·고추장·두부 |
| 순두부찌개 | 순두부·**김치**·멸치·고춧가루·호박·계란 | earthenware → earthenware | Timing(끓이기) | 면·고추장dollop·위에올리기 |
| 불고기 | 얇은소고기·간장·배·마늘·설탕·양파·표고 | frying_pan → brass_bowl | Season(marinade) | **면**·고추장·두부 |

---

## A. Incorrect Current Mapping Audit (현 코드/CSV 오류 전부)

> 출처: `art_registry.gd` (SLICE_INGREDIENT / STIR_FOOD / FLIP_FOOD / TIMING_FOOD / FOOD_VESSEL / PLATE_VESSEL), `plate_module.gd`, `stir_module.gd`, `season_module.gd`, `slice_module.gd`, `data/dish_modules.csv`, `godot-project/data/dish_modules.csv`.

### A-0. Stale dish 행 — `godot-project/data/dish_modules.csv` (구조 오류)

| 현 상태 | 정확해야 할 것 |
|---|---|
| `godot-project/data/dish_modules.csv`에 `m_kimchi_jjigae`/`m_doenjang_jjigae`/`m_maeuntang` 행 존재 + 불고기(t2_014) 행 **없음** | mvp v2.2는 t2_014(불고기)가 김치찌개 supersede. 이 godot 사본은 `data/dish_modules.csv`(정본, t2_014 포함)와 **불일치**. → 정본 12행으로 sync, m_* stew 3행 제거. art_registry의 TIMING_FOOD/FOOD_VESSEL/PLATE_VESSEL에도 m_kimchi_jjigae 등 dead 매핑 잔존 → 제거. |

### A-1. Slice ingredient 오류 (substitute로 대체 — `SLICE_INGREDIENT`)

| dish | 현 상태 | 정확해야 할 것 |
|---|---|---|
| 떡볶이 t1_003 | `["green_onion","chopped"]` (대파) | **어묵 어슷썰기 (fish_cake diagonal)** — 어묵 sprite 없음 |
| 김밥 t1_004 | `["carrot","julienne"]` | **단무지 통썰기 (danmuji round)** — 단무지 sprite 없음 |
| 콘도그 t1_007 | `["green_onion","chopped"]` (placeholder) | **batter dip (DIP-00, 칼 cut 아님)** — slice 자체가 부적합 |
| 갈비 t2_012 | `["green_onion","chopped"]` (대파) | **마늘 다지기 (garlic mince CUT-01)** — 마늘 sprite 없음 |
| 순두부 t2_013 | `["green_onion","chopped"]` (대파) | **호박 통썰기 (zucchini round)** — 호박 sprite 없음 |
| 불고기 t2_014 | `["green_onion","julienne"]` (대파) | **양파 채썰기 (onion julienne)** — 양파 sprite 없음 |

> 6/12 dish의 slice 재료가 substitute. 정답 재료 sprite 부재가 근본 원인 → §B asset 생성으로 해결.

### A-2. Stir 재료 오류 (`STIR_FOOD`)

| dish | 현 상태 | 정확해야 할 것 |
|---|---|---|
| **떡볶이 t1_003** | **`["kimchi","cooked"]` — 김치 pile churn (사용자 발견 #3)** | **떡+어묵을 빨간 고추장 양념에 졸이기. 김치 표시 금지** |
| 김치볶음밥 t1_005 | `["kimchi","cooked"]` | ✅ 정답 (김치볶음밥은 김치 churn 맞음) |
| 비빔밥 t2_008 | `["beef","cooked"]` | 밥+나물+고추장 bowl mix (beef만 churn = 부분 정확, rice/나물 시각 부재) |
| 잡채 t2_010 | `["noodle","cooked"]` | ✅ 정답 (당면 toss) |
| 불고기 t2_014 | `["beef","cooked"]` | ✅ beef 맞음. but stir variant inference에 t2_014 미등록 → default fallback (사용자 발견 #12 "mixing visual") |

### A-3. Flip 재료 오류 (`FLIP_FOOD`)

| dish | 현 상태 | 정확해야 할 것 |
|---|---|---|
| 해물파전 t1_006 | `["beef","raw","cooked"]` (소고기!) | **둥근 파전(pancake) raw→cooked** — 전 sprite 없음 (사용자 발견: 소고기 뒤집힘) |
| 콘도그 t1_007 | `["beef","raw","cooked"]` (소고기!) | **콘도그 batter 회전 dip+flip** — 콘도그 sprite 없음 |
| 갈비 t2_012 | `["beef","raw","cooked"]` | ✅ 정답 (갈비 양면 grill) |

### A-4. Timing 재료 오류 (`TIMING_FOOD`)

| dish | 현 상태 | 정확해야 할 것 |
|---|---|---|
| 순두부 t2_013 | `["tofu","block","cubed"]` | **stew 안에서 순두부+김치 끓기 (보글보글). 현재는 cube pile만, 국물·김치·끓는 연출 부재 (사용자 발견 #9)** |
| 잔치국수 t1_008 | `["noodle","raw","cooked"]` | 소면(somen) 정답인데 라면면 sprite 재사용 — 시각 구분 약함 |
| 김치볶음밥 t1_005 | `["kimchi","whole","cooked"]` | ✅ 대체로 정답 |

### A-5. Vessel·Plate 오류

| dish | 현 상태 | 정확해야 할 것 |
|---|---|---|
| **전체 (Plate module)** | **선택 vessel이 점수(best/2nd/bad)에만 연결, action zone dish hero는 vessel 무관하게 동일. content_only 없는 11 dish는 vessel 생략(Option B). 선택한 그릇에 음식이 실제로 안 담김 (사용자 발견 #4)** | **각 dish content_only + correct vessel 합성 → 선택 vessel 안에 실제 음식 담김** |
| 비빔밥 t2_008 | PLATE_VESSEL = `brass_bowl` ✅ but dolsot도 정답 후보 | brass_bowl(놋그릇) 정답 — 사용자 발견 #11과 정합 (이미 brass) |
| 라면 t1_002 | FOOD_VESSEL cook=`noodle_bowl` | cook은 **pot** 정답 (noodle_bowl은 plate). 끓이기 vessel이 그릇으로 잘못 매핑 |

### A-6. Season 오류 (`season_module.gd` SEASONING_STYLES)

| dish | 현 상태 | 정확해야 할 것 |
|---|---|---|
| 비빔밥 t2_008 | season default = gochujang style 있으나 **호출 시 seasoning param 미전달 → 기본 gochujang으로 떨어지지만 "bottle tilt" 연출 (사용자 발견 #10: gochugaru-like bottle)** | **gochujang = dollop (paste 한 덩이, bottle 아님)**. 비빔밥 season을 dollop 연출로 분리 필요 |
| 순두부 t2_013 | (season은 sequence상 존재) | **gochugaru = 가루 powder bottle** — 비빔밥과 반대. 현재 둘 다 같은 bottle 연출 = 구분 안 됨 |
| 양념병 scale | season_module bottle `tex.size = Vector2(220,400)` 고정, 음식 hero 대비 작음 (사용자 발견 #2) | bottle scale ↑ + particle 자연화 |

### A-7. 도구 scale·Heat UI 오류 (cross-system — 구현 시 godot-dev)

| 항목 | 현 상태 | 정확해야 할 것 |
|---|---|---|
| Knife scale (사용자 발견 #1) | slice_module KNIFE_RECT 200×360, 도마(BOARD_RECT 720×460)·재료 대비 작음 | 칼 scale ↑ (도마 폭의 ~40% 칼날 visible) |
| Fire/heat UI (사용자 발견 #5) | timing module heat dial + perfect_width 너무 넓음 (Tier 1 perfect 0.10~) | heat zone 시각 명확화 + Tier별 zone 좁힘 (§E 난이도) |
| Cutting style 차이 (#6) | slice_module CUT_STYLES는 angle/speed 다르나 **label 한글 only("다지기"/"어슷썰기")** | 영문 label 병기 또는 gameplay 차이 강화 (§D) |

---

## B. Assets Needed for Correctness

> 현 standalone: ingredient 20 state-sprites (8 base × states) + tool 22 + vessel 10 + roll 14. content_only 1(비빔밥).

### B-1. Content-only food sprites (Plate 정확성 — 선택 vessel 안에 담기)

| dish | 현황 | 조치 |
|---|---|---|
| 비빔밥 | `bibimbap_content_only.png` 있음 | **기존 활용** |
| 김밥 | roll/`gimbap_roll_finished_content_only.png` 있음 | **기존 활용** (wooden_tray cut layout) |
| 떡볶이 | 없음 | **신규 generation** (그릇 없는 빨간 떡볶이 mound) |
| 라면 | 없음 | **신규 generation** (그릇 없는 라면 면+국물 — or pot 단독) |
| 순두부찌개(Kimchi Stew reconcile) | 없음 | **신규 generation** (뚝배기 없는 stew content — 끓는 순두부+김치) |
| 잔치국수 | 없음 | **신규 generation** (사발 없는 면+고명 content) |

> 사용자 명시 content_only 6종 중 **2종(비빔밥·김밥) 기존 충족, 4종 신규**.

### B-2. Correct ingredient sprites (현 8 base에 없는 정답 재료)

신규 generation 필요 (각 whole + prepared state):

| ingredient | state 필요 | 쓰이는 dish | 우선순위 |
|---|---|---|---|
| **fish cake (어묵)** | whole + 어슷(diagonal) | 떡볶이 | P0 |
| **rice cake (떡)** | whole(가래떡 단면) | 떡볶이 | P0 |
| **garlic (마늘)** | whole + 다짐(mince 山) | 갈비 | P1 |
| **danmuji (단무지)** | whole + 통썰기 | 김밥 | P1 (roll strip은 있음, slice용 별도) |
| **zucchini (호박)** | whole + 통썰기 | 순두부·잔치국수 | P1 |
| **onion (양파)** | whole + 채썰기 | 불고기·잡채 | P1 |
| **soft tofu (순두부)** | block + stew-broken | 순두부 (현 tofu_block은 단단 두부) | P1 |
| **pancake/전** | raw batter + cooked(둥근 전) | 해물파전 | P2 (flip) |
| **corndog (콘도그)** | batter dip + fried | 콘도그 | P2 (flip) |
| **somen (소면)** | raw bundle + cooked | 잔치국수 | P2 |
| **gochujang dollop** | paste 한 덩이 | 비빔밥 season | P1 (season 구분) |
| **gochugaru powder** | 가루 | 순두부 season | P2 (현 particle로 대체 가능) |

### B-3. 기존 활용 가능 (신규 불필요)

- 대파(green_onion whole/chopped/julienne), 당근(whole/sliced/julienne/diced), 김치(whole/chopped/cooked), 소고기(raw/marinated/cooked), 계란(whole/cooked), 밥(rice_bowl), 면(noodle raw/cooked), 두부(block/cubed — 단단 두부 dish용).
- vessel 10종 모두 충분 (pot/dolsot/frying_pan/grill_pan/mixing_bowl/noodle_bowl/brass_bowl/wooden_tray/wide_plate/earthenware_bowl).
- tool 충분 (chef_knife/cutting_board/ladle/spatula/tongs/rolling_mat/seasoning_bottle/spoon/chopsticks).

---

## C. Prioritized Fix List (승인 후 구현 대상 — P0/P1/P2)

> scoring/progression 무변경. 데이터·asset-매핑 layer만 교체 + asset 생성.

### P0 — Critical mapping (즉시 "specific dish" 체감, asset 일부 신규)

1. **떡볶이 stir에서 김치 pile 제거** (사용자 #3) — STIR_FOOD `t1_003` `kimchi`→떡/어묵 졸이기 시각. 어묵·떡 sprite 신규(B-2 P0).
2. **불고기 noodle visual 제거** (사용자 #12) — stir variant inference에 `t2_014` 등록(beef 코팅, noodle 아님). 자산 기존 충족(beef_marinated).
3. **비빔밥 gochugaru→gochujang dollop** (사용자 #10) — season을 비빔밥 한정 dollop 연출. gochujang dollop sprite(B-2 P1).
4. **순두부 stew 안 김치/끓기** (사용자 #9) — timing을 stew(국물+김치 잠김+거품)로. content_only 신규(B-1).
5. **godot/data dish_modules.csv stale 행 제거 + art_registry m_* dead 매핑 제거** (A-0) — code/data 정합.

### P1 — Plate correctness + slice 재료 (vessel 안에 담기)

6. **Plate: 선택 vessel 안에 음식 실제로 담기** (사용자 #4) — 4 dish content_only 신규(떡볶이·라면·순두부·잔치국수) + correct vessel 합성. 비빔밥·김밥 기존 활용.
7. **slice 정답 재료 매핑** (A-1) — 어묵/마늘/호박/양파/단무지 sprite 신규 후 SLICE_INGREDIENT 교체.
8. **비빔밥 vessel 확정** (사용자 #11) — brass_bowl(놋그릇) lock (이미 PLATE_VESSEL=brass_bowl ✅, dolsot 후보 제거).
9. **라면 cook vessel = pot** (A-5) — FOOD_VESSEL `t1_002` noodle_bowl→pot (plate만 noodle_bowl).

### P2 — Polish (flip 자산 + label + scale)

10. **해물파전·콘도그 flip 정답 자산** (A-3) — 전/콘도그 sprite 신규, FLIP_FOOD 교체.
11. **Cutting style 영문 label + gameplay 차이** (사용자 #6, #7) — §D 권고 채택.
12. **Knife/bottle scale + heat UI + particle** (사용자 #1·#2·#5) — godot-dev tuning (자산 무관).
13. **소면 자산** (잔치국수 A-4) — somen sprite 신규.

---

## D. Cutting Style Rule (사용자 #6·#7)

### D-1. 현 상태
`slice_module.gd` CUT_STYLES는 이미 **angle + speed band로 gameplay 차이 존재**:
- mince(다지기): angle 90°, speed 1600~3200 (빠름)
- julienne(채썰기): 90°, 900~1800
- diagonal(어슷썰기): **60° (대각)**, 900~1800
- round(통썰기): 90°, 500~1100 (느림)
- fine(송송썰기): 90°, 1200~2400

**문제 1**: label이 **한글 only** (`"label": "다지기"`) → US 플레이어 인지 불가 (사용자 #7).
**문제 2**: angle 차이는 diagonal(60°)만 실제 방향 다름, 나머지는 speed band만 달라 **체감 차이 약함** (사용자 #6).

### D-2. 권고 (scoring 무변경 범위)

**채택안 = 영문 label 병기 + 시각 target shape 차별 (gameplay logic은 기존 angle/speed 유지)**:

| cut style | 영문 label (표면) | gameplay 차이 (기존 유지) | 추가 시각 차별 (저비용) |
|---|---|---|---|
| 다지기 | **Mince** | 90°, 빠른 짧은 stroke | 조각 = 잘게 다진 山 (작은 조각 다수) |
| 채썰기 | **Julienne** | 90°, 중속 | 조각 = 긴 strip |
| 어슷썰기 | **Diagonal** | **60° 대각 drag** (이미 방향 다름) | 조각 = 타원 대각 단면 |
| 통썰기 | **Round** | 90°, 느린 full slice | 조각 = 둥근 full 단면 |
| 송송썰기 | **Fine Chop** | 90°, 중속 fine | 조각 = 얇은 링 다수 |
| 깍둑썰기 | **Dice** | 90° | 조각 = 정육면체 cube |

- **label**: `"Diagonal · 어슷썰기"` 식 영문 primary + 한글 secondary (i18n icon-first 정책 정합 — 영어 minimal + 한식 어휘 학습).
- **gameplay 차이**: 기존 angle(diagonal 60°)/speed band 유지 (scoring 도메인 [0,100] 무변경). diagonal만 방향 명확 다름 → **나머지는 target piece-shape 시각으로 차별** (drag logic 동일, 결과 sprite/조각 모양만 다름).
- **권고 우선순위**: 영문 label은 **즉시 (P2-11)**, target shape 차별은 cut sprite 생성과 묶어 점진. **gameplay drag-direction 추가 차별은 비권고** (입력 복잡도↑, 캐주얼 진입장벽 — Casual mode 정신 위반).

---

## E. Difficulty by Level (현 scoring/progression 정합 — 신규 system X)

> `menus-v2.csv` unlock_level(1~12) + `balance-config` perfect_window/prep 판정창 범위 내에서 **dish-correctness가 난이도와 함께 진화**. 신규 system 없이 기존 perfect_window·tap_count·distractor·prep window 튜닝으로 표현.

| Lv band | 입력 난이도 (기존 파라미터) | recipe correctness 표현 | 예 (비빔밥 plating) |
|---|---|---|---|
| **Lv1** (intro) | wide zone / forgiving (perfect_width 넓음, prep window 넓음, distractor 0~1) | core ingredient만, 단순 시퀀스 | 3 topping radial arrange (당근·시금치·계란) |
| **Lv2** | narrow zone, +ingredient (distractor 1, prep window ↓) | optional ingredient 1개 추가, light guest 등장 | 4~5 topping arrange |
| **Lv3** | multi-step + failure visual (timing perfect ↓, flip/stir 추가) | banned ingredient distractor 등장 (틀리면 visual fail), wrong cut 페널티 | 5 topping + gochujang dollop 정밀 위치 |
| **Lv4+** | guest target shift + tight (perfect_width 좁음, guest 선호 변동) | guest별 선호 ingredient 정확도 가중 (선호 hit reaction↑) | 6 topping + bowl mix 균일도 |
| **Lv5 (Golden Spoon)** | symmetry / tightest (Recipe XP mastery, critic) | **plating symmetry 평가** (radial 색 균형 = ★3 게이트) | 6색 symmetry radial — 좌우 색 균형 = Golden Spoon |

- **정합**: 모두 기존 `perfect_window_ms` / `prep_taps` / `distractor_per_store_by_tier` / Guest 2.0 선호 / food-critic Golden Spoon으로 표현 가능 — **신규 system 0건**.
- **failure visual (Lv3+)**: 잘못된 재료/cut 선택 시 dish가 "잘못 만들어진" 시각 (예: 떡볶이에 김치 넣으면 색 탁함) — banned asset rule을 negative feedback으로 재활용.
- **Lv5 symmetry**: 비빔밥 6색 radial 배치의 좌우/상하 색 균형도 = arrange accuracy의 symmetry 항. 기존 arrange accuracy(correct_placement/total_slots) 위에 symmetry bonus만 (scoring 가중 무변경, display bonus).

---

## F. 핵심 통찰 요약

1. **근본 원인 = asset-mapping layer가 data를 무시하고 8 base ingredient로 substitute** — data(foods/ingredients CSV)는 정확하나 art_registry가 "제일 가까운 sprite"로 강제 → dish identity 붕괴. 해결 = **dish-correct lock table** (본 §2) + 누락 asset 12종 생성.
2. **Plate가 "선택만 하고 안 담김"** — vessel 선택이 점수에만 연결되고 시각 합성이 안 됨. content_only 4종 추가로 "선택 그릇에 실제로 담기는" 체감 완성.
3. **김치의 3중 오용** — 떡볶이 stir(틀림)·순두부 stew(위에 올림, stew 안 아님)·비빔밥(gochugaru로 오인). 김치/고추장/고춧가루 3종을 dish별로 명확히 분리해야 "specific dish" 체감.
4. **cutting style은 mechanic은 이미 차별화됨, label만 한글 only** — 영문 label 병기가 최저비용 최대효과 (사용자 #7).
5. **난이도는 기존 파라미터로 충분** — 신규 system 없이 perfect_window·distractor·Guest 선호·Golden Spoon symmetry로 5-tier 표현 가능.

---

## G. 변경 이력
- 2026-06-07 v1 — 초안. 12-dish recipe matrix(7-field) + incorrect mapping audit(A-0~A-7) + assets needed(B) + prioritized fix(P0/P1/P2) + cutting style 권고(D) + difficulty by level(E). **matrix + audit only, 구현 보류 (승인 대기).**
