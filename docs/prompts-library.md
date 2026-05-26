# Prompts Library — K-Food Master MVP

> 버전: **v0.3** · 갱신일: 2026-05-24 · 작성자: art-director
> 상위 문서: [`art-style-guide.md`](art-style-guide.md), [`mj-session-kit.md`](mj-session-kit.md), [`art-anchor-rubric.md`](art-anchor-rubric.md), [`decisions.md` ADR-003](decisions.md#adr-003-mvp-first-전환--34개월-출시--점진-확대-supersedes-adr-002), [`systems/cooking-mechanics.md` §2 §5.1](systems/cooking-mechanics.md), [`art-workload-estimate.md` v3.0](art-workload-estimate.md)
> 본 문서 범위: Week 1 anchor lock용 캐릭터 6 + 환경 5 = **11장 프롬프트**. 음식 12개는 다음 sprint(§5 placeholder).
> v0.3 변경 핵심: 주인공 선택형(남/여) 결정 반영 → CH-01 → **CH-01a 남자 + CH-01b 여자** 분리. 캐릭터 anchor 5 → 6. sref 운영은 **공유 1개**(CH-01a base, CH-01b는 같은 sref로 derive) 유지.
> 도구: Midjourney v6 + niji 6 (둘 다 사용, 항목별 선택). Stable Diffusion은 보조(MVP 비핵심).
> **실행 키트**: 사용자가 MJ Discord에서 copy-paste 실행할 단계별 키트는 `mj-session-kit.md` 참조. 결과 평가 rubric은 `art-anchor-rubric.md` 참조.

---

## 0. Anchor Lock 표 (게이트 통과 후 채움)

> Week 1 게이트 PASS 후 **모든 M1 sprint 자산은 본 표의 `--sref` URL을 의무 사용**.
> 표 채워지기 전까지 M1 sprint 시작 금지 ([`art-workload-estimate.md` §5.2 Blocker #1](art-workload-estimate.md)).

| ID | Subject | 채택 모델 | MJ Job ID | `--sref` URL | seed | Status |
|----|---------|----------|-----------|--------------|------|--------|
| CH-01a | 주인공 남자 (혼밥) | TBD | TBD | TBD | TBD | ⏳ |
| CH-01b | 주인공 여자 (혼밥) | TBD | TBD | TBD | TBD | ⏳ |
| CH-02 | 어머니 | TBD | TBD | TBD | TBD | ⏳ |
| CH-03 | 아버지 | TBD | TBD | TBD | TBD | ⏳ |
| CH-04 | 주인공 Happy (★3 reaction) — 본 sprint는 남/여 중 base 1종만; 나머지는 M1 | TBD | TBD | TBD | TBD | ⏳ |
| CH-05 | 주인공 Subtle (★1·★2 reaction) — 본 sprint는 남/여 중 base 1종만; 나머지는 M1 | TBD | TBD | TBD | TBD | ⏳ |
| BG-01 | 청과상 🥬 | TBD | TBD | TBD | TBD | ⏳ |
| BG-02 | 정육점 🥩 | TBD | TBD | TBD | TBD | ⏳ |
| BG-03 | 어물전 🐟 | TBD | TBD | TBD | TBD | ⏳ |
| BG-04 | 곡물상 🌾 | TBD | TBD | TBD | TBD | ⏳ |
| BG-05 | 잡화점 🫙 | TBD | TBD | TBD | TBD | ⏳ |

### 0.1 sref 운영 — Step 0에서 결정된 sref를 어느 anchor에 적용하는지 매핑 (v0.2)

> [`mj-session-kit.md`](mj-session-kit.md) §2 Step 0에서 결정한 2개 sref URL을 본 표대로 부착.
> sref URL 1개는 한 모델군 내에서만 의미가 있으므로 캐릭터(niji)와 환경(v6.1)은 별도 sref.

| sref 시드 | 결정 위치 (Step 0) | 적용 대상 anchor | `--sw` 권장 |
|----------|------------------|----------------|------------|
| `CHAR_SREF_URL` | Step 0a — 주인공 prompt 1차 best upscale | CH-01, CH-02, CH-03, CH-04, CH-05 (전 캐릭터) | 기본 100, CH-02·CH-03(가족 페어)은 150, CH-04·CH-05(표정 variant)는 200 |
| `BG_SREF_URL` | Step 0b — 청과상 prompt 1차 best upscale | BG-01, BG-02, BG-03, BG-04, BG-05 (전 환경) | 기본 100, 톤 불일치 시 150~200 |

**원칙**:
- 한 번 lock한 sref는 sprint 종료까지 변경 금지 (변경 시 모든 파생 자산 영향 → pm 승인 필수)
- niji 6 sref를 v6.1 prompt에 부착하지 말 것 (반대도 동일) — 모델 간 sref는 비호환
- M1 sprint 모든 파생 자산(reaction variant, 추가 BG, 음식 카드)도 본 표의 sref를 의무 사용

### 0.2 사용자 결과 인계 schema (art-director 평가용, v0.2)

> 사용자가 MJ 세션 종료 후 art-director에게 결과를 들고 올 때 본 schema로 묶어 전달.
> 12세트(Step 0 후보 2 + CH-01~05 + BG-01~05) 모두 동일 형식.

```
Anchor ID: <CH-01 | CH-02 | ... | BG-05 | STEP-0a | STEP-0b>
MJ 출력 URL: <upscale 1장 Discord CDN URL>
또는 로컬 파일 경로: <C:\Projects\kfood-game\assets-raw\...>
sref URL 사용: <CHAR_SREF_URL 값 | BG_SREF_URL 값 | none(Step 0)>
seed (있으면): <숫자>
4-grid 선택 칸: <U1 | U2 | U3 | U4>
Round: <R1 | R2 | R3>
사용자 1차 평가 메모 (선택): <자유 메모>
```

art-director는 위 schema를 받아 `art-anchor-rubric.md` §3 표를 채워 LOCK/CONDITIONAL/FAIL 판정.

---

## 1. Model 선택 정책 (v6 vs niji 6)

### 1.1 결론
- **캐릭터 5장 (CH-01 ~ CH-05)**: `--niji 6`
- **환경 5장 (BG-01 ~ BG-05)**: `--v 6.1`

### 1.2 근거
| 항목 | v6.1 | niji 6 | 선택 |
|------|------|--------|------|
| Chibi 마스코트 일관성 | △ (3D 렌더로 빠짐) | ◎ (anime/chibi 안전구역) | **niji 6 — 캐릭터** |
| 손가락 단순화(mitten) 준수 | △ | ◯ | niji 6 |
| 큰 머리·점 눈 chibi 비율 | △ | ◎ (가장 안정적) | niji 6 |
| 사실적 시장 텍스처 (나무·천막·과일) | ◎ | △ (배경이 평면 anime 톤으로 빠짐) | **v6.1 — 환경** |
| 골든아워 조명 자연스러움 | ◎ | ◯ | v6.1 |
| 한국 재래시장 인지 정확도 | ◯ (Korean traditional market 키워드 잘 받음) | △ (일본 시장 인상으로 빠지기 쉬움) | v6.1 |
| 일관 컬러 팔레트 유지 | ◯ (`--sref` 잘 받음) | ◎ (anime 톤이 자연스럽게 일관) | tied |

**리스크**: 캐릭터(niji)와 환경(v6.1)이 다른 모델이므로 **합성 시 톤 차이 발생 가능**. 완화안:
- 캐릭터·환경 둘 다 같은 `--sref` URL 1개를 공유 (캐릭터 anchor CH-01 lock 후 그 URL을 BG prompt에도 동시 투입)
- 최종 합성 단계에서 LUT 1장으로 톤 통일

### 1.3 niji 6의 anime girl 누수 차단
niji는 인물에서 `anime girl` 톤이 새어나오기 쉽다 ([art-style-guide.md §1.2](art-style-guide.md)). 모든 niji 프롬프트에 다음 negative 필수:
```
--no anime girl, manga style, big sparkly eyes, school uniform, fanservice, sexy, mature
```

---

## 2. 공통 프롬프트 구조 & Suffix

### 2.1 프롬프트 구조 (모든 anchor 공통)
```
[Subject] + [Style] + [Composition] + [Lighting] + [Camera] + [Parameters] + [Negative]
```
- **Subject**: 무엇이 그려지는지 (1줄)
- **Style**: chibi mascot, picture book illustration, K-food 등 §1.2 채택 형용사
- **Composition**: 시점, 배치, 소품 밀도
- **Lighting**: 골든아워 + 주광 방향
- **Camera**: 3/4, 7/8, eye-level 등
- **Parameters**: `--ar`, `--stylize`, `--sref`, `--v` / `--niji`
- **Negative** (`--no`): §7 art-style-guide.md MJ 약점 회피 룰 + 모델별 누수 차단

### 2.2 공통 Suffix — **환경 5장 (BG-01~05) 일관성 강제**
모든 환경 prompt 끝에 다음을 동일하게 부착:
```
[STYLE_SUFFIX_BG]
warm hand-painted picture book illustration, cozy stylized 2D,
Korean traditional market (Namdaemun style),
late afternoon golden hour lighting, warm sunlight from upper-right 45 degrees,
soft cream background sky, limited palette of persimmon orange / gochu red / cabbage green / sea blue / grain tan / jang brown,
clean composition, no people in foreground, shop is empty waiting for customer,
--ar 16:9 --stylize 200 --v 6.1
--no realistic, photorealistic, 3D render, octane, unreal engine,
       Japanese, Tokyo, Chinatown, anime girl, manga, dark, gritty,
       hyperdetailed, cluttered, text in english, korean text legible
```

### 2.3 공통 Suffix — **캐릭터 5장 (CH-01~05) 일관성 강제**
모든 캐릭터 prompt 끝에 다음을 동일하게 부착:
```
[STYLE_SUFFIX_CHAR]
chibi mascot character, head to body ratio 1 to 1.7, big head small body,
LINE Friends meets Cookie Run aesthetic, picture book illustration,
mitten hands (simplified four-finger), bean-shaped dot eyes with single highlight,
soft pink circular cheek blush, no nose detail,
three-quarter view, full body, character sheet on plain cream background,
late afternoon golden hour soft lighting, warm rim light from upper-right,
clean line art with soy-dark outline (no pure black), single-layer cel shading,
--ar 1:1 --stylize 300 --niji 6
--no anime girl, manga style, big sparkly eyes, school uniform, fanservice, sexy,
       realistic, photorealistic, 3D render, hyperdetailed,
       front symmetric face, individual finger detail, dark gritty
```

> **Anchor lock 후 운영**: CH-01의 best 1장 upscale URL을 `--sref https://...` 형태로 §0 표에 기록 → CH-02~CH-05 prompt에 추가 부착. BG도 동일 (BG-01 best 1장의 sref를 BG-02~05에 부착).

### 2.4 `--sref` 운영 규칙
> sref 적용 매핑 표는 §0.1, 사용자 결과 인계 schema는 §0.2 참조.

1. **Round 1 (탐색)**: `--sref` 없이 prompt만으로 4 variation 생성. 베스트 1장 upscale.
2. **Round 2 (Lock)**: Round 1 베스트의 upscale URL을 `--sref <url>` 형태로 같은 prompt에 추가 → 다시 4 variation. 일관성 강화 확인.
3. **Round 3 (Anchor 확정)**: Round 2 베스트를 **anchor**로 §0 표에 기록. 그 URL이 모든 M1 sprint 자산의 sref 시드.
4. **금지**: 한 번 lock한 sref URL은 sprint 종료까지 변경 금지. 변경 필요 시 ADR 또는 pm 승인.
5. **`--sw` (style weight)**: 기본 100. 캐릭터·환경 톤 통일 부족 시 200까지 상향 검토.
6. **`--cref` (character reference)**: niji 6는 `--cref` 미지원 — 캐릭터 일관성은 `--sref` + character sheet 1장 + Photoshop 후보정 조합으로 해결.

---

## 3. 캐릭터 Anchor Prompts (5장)

### CH-01 — 주인공 (혼밥, Tier 1)
**의도**: Tier 1 혼밥 진행의 시점 주인공. 어디서나 등장 가능한 중립 표정 idle. 추후 CH-04·CH-05의 base.

```
chibi mascot character, young Korean cooking-loving person,
wearing simple beige apron over soft mustard hoodie, holding a small wooden ladle,
neutral friendly smile, neutral idle pose, full body character sheet,

[STYLE_SUFFIX_CHAR]
```

- **Variation 권장**: 4장 생성 → 머리 비례·시선 자연스러움 기준 1장 선택
- **Round 2 sref**: 첫 베스트의 upscale URL을 다시 같은 prompt에 부착
- **MJ 약점 메모**: niji가 "anime girl"로 빠지면 hoodie + apron 강조, `school uniform` negative 강화

### CH-02 — 어머니 (Tier 2 가족)
**의도**: Tier 2 가족 식탁 등장. 모던 80% + 전통 20% — 100% 한복 금지(MJ가 한복 디테일에서 폭주).

```
chibi mascot character, gentle Korean mother in her early 50s,
wearing modernized hanbok-inspired top (simple jeogori silhouette in soft persimmon)
over modern wide-leg pants, soft round bun hairstyle with simple binyeo ornament,
warm caring smile, holding a small bowl of rice, standing pose, full body character sheet,
--sref [CH-01_URL_after_lock]

[STYLE_SUFFIX_CHAR]
```

- **공유 sref**: CH-01 lock 후 URL 부착하여 주인공과 같은 IP로 보이게
- **MJ 약점 메모**: 한복 모티프가 무거우면 일본 기모노로 빠짐 → `Korean hanbok, jeogori, NOT kimono, NOT japanese` 명시. `--no kimono, geisha, japanese` 추가.

### CH-03 — 아버지 (Tier 2 가족)
**의도**: Tier 2 가족 식탁 등장. 가장 친근 — 카디건+앞치마. 어머니와 페어 일관성 핵심.

```
chibi mascot character, kind Korean father in his early 50s,
wearing soft brown cardigan over checkered shirt and beige apron,
short salt-and-pepper hair, round friendly face, warm smile with eye crinkles,
holding wooden chopsticks, standing pose, full body character sheet,
--sref [CH-01_URL_after_lock]

[STYLE_SUFFIX_CHAR]
```

- **MJ 약점 메모**: niji가 아버지를 "young anime boy"로 그리는 경향 → `father in his early 50s, salt-and-pepper hair, gentle wrinkles` 강조

### CH-04 — 주인공 Happy 표정 (★3 reaction)
**의도**: Scene 3 식탁에서 ★3 시식 reaction. CH-01과 **완전히 동일한 캐릭터**여야 함.

```
same chibi mascot character as anchor [주인공],
joyful "wow delicious" expression, mouth open in delighted O-shape,
sparkle hearts and tiny stars around head, both mitten hands raised to cheeks in delight,
three-quarter view, bust-up portrait (head and shoulders),
--sref [CH-01_URL_after_lock] --sw 200

[STYLE_SUFFIX_CHAR]
```

- **sw 200**: 시드 일관성 최대화 — 같은 캐릭터로 인식되어야 함
- **MJ 약점 메모**: `same character as` 문구는 niji가 약간 받아준다. 그래도 다른 캐릭터로 그려지면 Photoshop에서 CH-01의 머리+눈 합성 후보정

### CH-05 — 주인공 Subtle 표정 (★1·★2 공통)
**의도**: ★1·★2 공통 nod/미소 reaction.

```
same chibi mascot character as anchor [주인공],
soft satisfied smile with slight head tilt, one mitten hand near chin in "hmm tasty" gesture,
calm content expression (no stars, no hearts), bust-up portrait,
three-quarter view,
--sref [CH-01_URL_after_lock] --sw 200

[STYLE_SUFFIX_CHAR]
```

---

## 4. 환경 Anchor Prompts (5장 — 재래시장 5가게)

> 5장은 **같은 시장 안의 옆가게**로 인식되어야 한다. §2.2의 STYLE_SUFFIX_BG가 그 일관성을 강제.
> 모든 BG는 **빈 가게 (no people)** 상태로 생성 — 캐릭터·인물은 Unity 레이어에서 합성.
> 각 BG는 **외관 + 매대를 한 컷에 포함하는 3/4 시점**.

### BG-01 — 청과상 🥬
```
Korean traditional market vegetable shop storefront,
piles of fresh cabbages, white radishes (mu), green onions in bundles,
red apples and persimmons in wooden baskets, leafy greens hanging,
striped red-and-blue awning above, warm string lights, handwritten price tags,
wooden stall with worn texture, glimpse of neighboring shops in soft background blur,
empty shop waiting for customer (no people),
three-quarter view from customer perspective, eye-level slightly elevated,

[STYLE_SUFFIX_BG]
```

- **시그니처 컬러**: Cabbage Green `#6FB077` (천막·간판 강조)
- **공유 sref**: 첫 lock 이후 `--sref [BG-01_URL]`을 BG-02~05에도 부착

### BG-02 — 정육점 🥩
```
Korean traditional market butcher shop storefront,
white tile back wall, glass display refrigerator showing pork belly and short ribs,
red lantern hanging at entrance, stainless steel hooks above, clean wooden cutting board,
striped red awning, handwritten price tags in placeholder glyphs,
empty shop waiting for customer (no people, no animals shown whole),
three-quarter view from customer perspective, eye-level slightly elevated,
--sref [BG-01_URL_after_lock]

[STYLE_SUFFIX_BG]
```

- **시그니처 컬러**: Gochu Red `#E63946`
- **MJ 약점 메모**: 통째 동물·잔혹 묘사 회피 — `no whole animals shown, clean and appetizing, family-friendly` 강조. negative에 `gore, blood, hanging carcass` 추가

### BG-03 — 어물전 🐟
```
Korean traditional market seafood shop storefront,
shaved ice display tray with stylized cute fish (mackerel, hairtail), cuttlefish, shrimp,
blue-striped awning above, light blue rubber gloves and stainless trays,
ice crystals catching golden afternoon light, water droplet highlights,
handwritten price tags in placeholder glyphs,
empty shop waiting for customer (no people),
three-quarter view from customer perspective, eye-level slightly elevated,
--sref [BG-01_URL_after_lock]

[STYLE_SUFFIX_BG]
```

- **시그니처 컬러**: Sea Blue `#4A9BC4`
- **MJ 약점 메모**: 비린/그로테스크 회피 — `stylized cute fish, appetizing, picture book friendly` 명시

### BG-04 — 곡물상 🌾
```
Korean traditional market grain shop storefront,
burlap sacks of rice, barley, red beans, soybeans arranged in rows,
wooden scoops (doitbak) sticking out of sacks, brass weighing scale on counter,
warm tan and golden brown color palette, dust motes in golden afternoon light,
handwritten price tags in placeholder glyphs,
empty shop waiting for customer (no people),
three-quarter view from customer perspective, eye-level slightly elevated,
--sref [BG-01_URL_after_lock]

[STYLE_SUFFIX_BG]
```

- **시그니처 컬러**: Grain Tan `#D9B382`

### BG-05 — 잡화점 🫙
```
Korean traditional market general goods shop storefront (japhwajeom),
large brown onggi pottery jars holding doenjang, ganjang, gochujang,
shelves of seasoning bottles, dried laver (gim) bundles, dried seaweed,
warm brown and amber tones, soft golden afternoon light glowing on pottery glaze,
handwritten price tags in placeholder glyphs,
empty shop waiting for customer (no people),
three-quarter view from customer perspective, eye-level slightly elevated,
--sref [BG-01_URL_after_lock]

[STYLE_SUFFIX_BG]
```

- **시그니처 컬러**: Jang Brown `#8C6A4E`
- **MJ 약점 메모**: 옹기(onggi)를 중국 항아리·일본 도자기로 그리는 경향 → `Korean onggi pottery, dark brown earthen jar, NOT chinese vase, NOT japanese ceramic` 명시

---

## 5. Food Anchor Placeholder (다음 sprint)

> **현 sprint 범위 외**: 음식 12개 anchor 프롬프트는 game-designer의 **MVP 음식 12개 선정 권고서** 수령 후 작성.
> [`art-workload-estimate.md` §6 이번 주 즉시 액션](art-workload-estimate.md), [`decisions.md` ADR-003 §Follow-up Actions](decisions.md#adr-003).
> 본 sprint(Week 1)는 캐릭터 5 + 환경 5만 lock하고, 음식 anchor는 Week 2~3에서 작성.

### 5.1 음식 anchor 작성 시 적용할 규칙 (사전 정의)
- **모델**: `--v 6.1` (음식 텍스처는 v6.1이 강함)
- **포맷**: 정사각 (`--ar 1:1`)
- **시점**: top-down 3/4
- **배경**: 단색 크림 `#F8E9D2` + 미세 종이 텍스처 ([art-style-guide.md §5](art-style-guide.md))
- **공유 sref**: 12개 음식 카드는 첫 음식(예: 라면) anchor lock 후 그 sref를 11개에 부착
- **K-touch**: 음식명 영문 직역 + Korean food 강제 (예: `tteokbokki Korean spicy rice cake`)

### 5.2 12개 슬롯 (game-designer 선정 대기)
| 슬롯 | 음식 후보 (Tier) | 가게 조합 (cooking-mechanics §2.2 기준) | Status |
|------|----------------|-------------------------------------|--------|
| 1~6 | Tier 1 단품 (라면/김밥/계란말이/떡볶이/떡국/?) | 곡물+잡화 위주, 일부 청과 | ⏳ pending game-designer |
| 7~12 | Tier 2 단품 (비빔밥/김치찌개/제육볶음/갈비찜/?) | 5가게 다양 분포 | ⏳ pending game-designer |

> game-designer가 12개 확정 → 본 §5에 정식 프롬프트 12개 작성 → 캐릭터/환경 anchor와 같은 절차로 lock.

---

## 6. 재료 카드 / UI / VFX Prompts (다음 sprint)

> 음식 anchor 확정 후 일괄 작성. MVP scope ~20개 재료, ~14개 UI/VFX.
> 재료는 음식 anchor에서 등장한 재료의 부분 crop으로 시작 → 부족한 재료만 별도 prompt.

---

## 7. 변경 이력
- **2026-05-24 v0.2** — Week 1 anchor lock 실행 키트(`mj-session-kit.md`) + 평가 rubric(`art-anchor-rubric.md`) 신설 연동. §0.1 sref 운영 매핑 표(CHAR_SREF_URL → CH 5장 / BG_SREF_URL → BG 5장, `--sw` 권장값 포함) 신설. §0.2 사용자 결과 인계 schema 신설(art-director 평가 입력 형식 명시). §2.4 sref 운영 규칙에 §0.1·§0.2 link 한 줄. §3~§6 본문은 무변경(M1 sprint 이월 음식·재료·UI·VFX placeholder 유지).
- **2026-05-23 v0.1** — 초안. ADR-003 MVP scope(친구 1~2 가족 단위, 식탁 2종) 반영. 캐릭터 5장(주인공+어머니+아버지+표정 variant 2) prompt — niji 6. 환경 5장(재래시장 5가게) prompt — v6.1. STYLE_SUFFIX 2종으로 일관성 강제. `--sref` 운영 규칙 3 라운드 정의. 음식 12개는 §5 placeholder로 다음 sprint 이월.
