# Art Style Guide — K-Food Master MVP

> 버전: **v0.2** · 갱신일: 2026-05-24 · 작성자: art-director
> 상위 문서: [`decisions.md` ADR-002 §Decision #5](decisions.md#adr-002-자체-제작--ai-도구--마스코트-스타일--full-feature-mvp) (마스코트 스타일 채택), [`decisions.md` ADR-003 §MVP Scope](decisions.md#adr-003-mvp-first-전환--34개월-출시--점진-확대-supersedes-adr-002), [`art-workload-estimate.md` v3.0](art-workload-estimate.md), [`systems/cooking-mechanics.md` §2 §5.1](systems/cooking-mechanics.md)
> 실행 키트·평가 rubric: [`mj-session-kit.md`](mj-session-kit.md), [`art-anchor-rubric.md`](art-anchor-rubric.md)
> 본 문서 범위: MVP (Tier 1~2, 친구 1~2명, 식탁 2종, 다점포 5가게)
> 사운드 가이드는 별도(`docs/systems/sound-guide.md`, M2~M3에 신설).

---

## 0. 한 줄 정의

> **"라인프렌즈 친근함 + Cookie Run 식감(食感) + 한국 재래시장의 손맛."**
> 어디서 봐도 K-food임을 즉시 알 수 있는 **마스코트 chibi + 한식 모티프**. MJ가 안정적으로 뽑을 수 있는 안전 구역에 의도적으로 머문다.

---

## 1. 컨셉 톤 (Mood Board, 텍스트 기반)

### 1.1 레퍼런스 좌표
| 레퍼런스 | 차용 요소 | 차용 안 함 |
|---------|----------|-----------|
| **Cookie Run: Kingdom** | 풍부한 그라데이션, 음식 의인화, 즙(juicy) 하이라이트 | 과장된 액션 포즈, 전투 VFX |
| **LINE Friends (브라운/코니)** | 단순 실루엣, 큰 머리, 친근한 표정, 굵은 라인 | 흑백 라인아트만, 무광 색 |
| **Animal Crossing (모동숲)** | 따뜻한 파스텔 배경, 작은 디테일이 가득한 소품, 평온한 일상감 | 3D 모델링, 카메라 자유 회전 |
| **마쉬멜로우 한복 카카오 이모티콘** | 한복/한식 모티프의 귀여운 단순화 | 정적 단일 일러스트 (우린 시트 변형 필요) |
| **Genshin·Honkai chibi 굿즈** | chibi 비율의 정면/측면/3/4 시점 시트 운영 | 셀 셰이딩 라인 |

### 1.2 핵심 형용사 (style words — MJ prompt에 그대로 투입)
**채택**: `chibi`, `mascot`, `kawaii`, `cute`, `soft`, `cozy`, `warm`, `hand-painted texture`, `Korean traditional market`, `K-food`, `picture book illustration`, `stylized 2D`

**금지**: `realistic`, `photorealistic`, `hyperdetailed`, `anime girl`, `manga`, `dark`, `gritty`, `noir`, `cyberpunk`, `3D render`, `cinematic`, `epic`

> niji 6는 `anime girl` 톤이 새어나오기 쉬워 negative에 반드시 포함. v6는 `3D render`로 빠지기 쉬워 negative 필수.

### 1.3 K-touch 체크리스트 (모든 자산이 만족할 것)
- [ ] **재료/요리에 한식 정체성**: 라면 = 노란 봉지+빨간 글씨 톤, 김치 = 빨간 양념 + 배추 결, 떡 = 흰 윤기, 김 = 검녹색 매트
- [ ] **간판에 한글 흔적**: MJ가 한글을 못 쓰므로 anchor 단계에서는 "한글 같은 글리프" 정도만 허용 → **모든 텍스트는 Photoshop 후보정으로 정정**
- [ ] **재래시장 시그니처**: 빨강·파랑 줄무늬 천막 (천막 awning), 나무 좌판, 알전구, 비닐 차단막, 손글씨 가격표
- [ ] **계절/시간대**: MVP는 **늦오후 골든아워** 단일 — 따뜻한 황금빛으로 일관성 lock
- [ ] **사람 살이의 흔적**: 잘 닦인 매대보다 약간 어수선한 진열, 가격표 손글씨, 흠집·찌그러짐 1~2개 — "정 있는" 톤

---

## 2. 컬러 팔레트

> MJ 출력은 컬러 진폭이 크다. **palette 강제는 prompt만으로는 불완전 → anchor lock 후 Photoshop에서 color-grade LUT 1장으로 통일**.

### 2.1 베이스 팔레트 (전 자산 공통)

| 역할 | HEX | 이름 | 사용처 |
|------|-----|------|--------|
| Primary Warm | `#F4A261` | Persimmon | CTA, 핵심 강조, 곶감/단호박 |
| Primary Red | `#E63946` | Gochu Red | 김치/고추장/떡볶이, 빨간 shake VFX |
| Secondary Cream | `#F8E9D2` | Rice Cream | 배경 베이스, 식탁보 |
| Secondary Green | `#6FB077` | Cabbage Green | 청과상, 채소, "성공" 톤 |
| Accent Gold | `#FFC857` | Sesame Gold | ★ 등급, 황금시간 조명 |
| Neutral Wood | `#8C6A4E` | Market Wood | 좌판, 간판 프레임 |
| Neutral Dark | `#3D2C1E` | Soy Dark | 라인 외곽 (순흑 사용 금지) |
| Background Sky | `#FFE9C4` | Golden Hour Sky | 모든 BG의 하늘/뒤편 |

### 2.2 가게별 시그니처 컬러 (Scene 1)

각 가게는 한 가지 시그니처 컬러로 식별성을 잡는다. 간판·천막·진열대 강조에 사용.

| 가게 | 시그니처 | HEX | 메모 |
|------|---------|-----|------|
| 🥬 청과상 | Cabbage Green | `#6FB077` | 잎채소 결 + 노란 알전구 |
| 🥩 정육점 | Gochu Red | `#E63946` | 빨간 등불, 흰 타일 배경 (정육점 특유) |
| 🐟 어물전 | Sea Blue | `#4A9BC4` | 얼음 하이라이트, 푸른 천막 |
| 🌾 곡물상 | Grain Tan | `#D9B382` | 누런 마대 자루, 갈색 통 |
| 🫙 잡화점 | Jang Brown | `#8C6A4E` | 옹기 항아리, 갈색·황갈 톤 |

> 5색이 한 화면(재래시장 입구)에 동시에 들어와도 충돌하지 않도록, **모든 시그니처 컬러는 같은 채도대(~60~70%) + 명도대(~55~65%)** 안에 머문다. 채도 100%는 금지.

---

## 3. 캐릭터 디자인 룰

### 3.1 비율
- **머리 : 몸 = 1 : 1.5 ~ 2.0** (chibi)
- 머리 폭 ≈ 어깨 폭 ×1.3 (라인프렌즈식)
- 손/발은 미트(mitten) 형태로 단순화 — **손가락 1개 형태(엄지+뭉친 4개) 권장** → MJ 손가락 약점 회피
- 키 (canvas 비례): 어머니 1.0 기준, 아버지 1.05, 주인공 0.9

### 3.2 얼굴
- 눈: **점·콩알 형태** (눈동자 + 흰 반사점 1개). **홍채/속눈썹 디테일 금지**
- 입: 짧은 호(arc) 또는 v자, 웃을 때만 살짝 벌어짐
- 코: 작은 점 1개 또는 생략
- 볼터치: 분홍색 원형 (Persimmon 톤) — **모든 캐릭터 공통 시그니처**
- **정면 얼굴 금지** — 3/4 시점이 anchor. 정면이 필요하면 살짝 기울인 7/8 정면.

> MJ가 정면 얼굴에서 비대칭을 자주 만든다. 3/4 또는 7/8로 안전구역 확보.

### 3.3 의상
- 주인공: 단순 후드/티셔츠 + 앞치마 (요리사 모티프)
- 어머니: **단순화한 한복 저고리 + 모던한 바지** (전통 80% + 모던 20%) — 100% 한복은 MJ가 디테일 폭주
- 아버지: 카디건 + 셔츠 + 앞치마 (가장 친근)
- 의상 컬러는 §2.1 베이스 팔레트에서만 선택

### 3.4 라인 / 셰이딩
- 외곽 라인: **3~4 px (1024px canvas 기준)**, Soy Dark `#3D2C1E`
- 내부 라인: 외곽의 60% 두께
- **순흑 라인 금지** — Soy Dark만 사용
- 그림자: 1단 큐셰이딩 (cel-shading 1 layer), 컬러는 베이스의 명도 -20%, 채도 +10%
- 하이라이트: 1단, 흰색이 아니라 베이스의 명도 +30%, 채도 -10%
- 음식·과일은 추가로 specular 하이라이트 1점 (juicy 표현)

### 3.5 표정 시트 (reaction anchor용)
각 캐릭터는 3개 표정만 anchor lock:
1. **Neutral** (대기 — Scene 1·2 idle)
2. **Happy** (★3 시식 반응 — Scene 3, "와!" 입 벌림 + 하트/별 VFX)
3. **Subtle** (★1·★2 공통 — 살짝 끄덕임 / 미소)

> [`cooking-mechanics.md` §10.1 #11](systems/cooking-mechanics.md) 결정에 따라 reaction은 ★3만 차별, ★1·★2는 공통. **친구 2명 × 3 표정 = 6컷**이 reaction anchor 총량.
> **U-2 sync (2026-05-24)**: 어머니/아버지 L11 동시 unlock 결정([`ui/tier-1-2-flow.md` §3.3 v0.2](ui/tier-1-2-flow.md))에 따라 reaction 6컷 = 어머니 ★1/2/3 + 아버지 ★1/2/3. 본 sprint(Week 1)는 base anchor(어머니/아버지 각 1장)만 lock, reaction variant 6컷은 후속 sprint. **모든 reaction prompt에 `--no sleeping, eyes closed peaceful` 필수** (tier-1-2-flow §3.3.1 단계 흐름이 활성 표정 노출에 의존하므로 sleeping 회피가 필수 원칙).

---

## 4. 환경 디자인 룰

### 4.1 시점·구도
- **Scene 1 입구**: 3/4 perspective, eye-level, 화면 하단 1/3에 좌판, 상단 2/3에 천막·간판·하늘
- **Scene 1 가게 내부**: 정면 매대, 약간 위에서 내려다보는 살짝 high angle (진열 시인성)
- **Scene 2 키친**: 정면 카운터, 가스레인지·도마가 화면 중앙
- **Scene 3 식탁**: 식탁을 정면에서 약간 위에서 본 7/8 top-down (상차림 시인성 + 인물 얼굴 동시 노출)

### 4.2 조명 (전 자산 공통 — 일관성 핵심)
- **시간대**: 늦오후 골든아워 (오후 4~5시 한국 늦봄)
- **주광**: 오른쪽 위 45도에서 들어오는 따뜻한 황금빛 `#FFC857`
- **보조광**: 왼쪽 아래에서 약하게 차오르는 크림 톤 `#F8E9D2`
- **그림자 방향**: 화면 왼쪽 아래로 길게
- **하늘**: 항상 Golden Hour Sky `#FFE9C4` (밤/낮 변화 없음 — MVP 단순화)

### 4.3 소품 밀도
- 매대당 핵심 소품 5~8개 (너무 많으면 MJ가 디테일 폭주)
- 배경 후경(천막, 옆가게, 행인)은 **블러 + 채도 -30%**로 자동 분리
- 캐릭터(MVP는 행인 제외)는 BG에 미포함 — BG는 빈 가게 상태로 anchor (인물 합성은 unity 레이어에서)

### 4.4 한식·재래시장 시그니처 소품 카탈로그
| 영역 | 필수 소품 |
|------|----------|
| 입구 | 빨강·파랑 줄무늬 천막 awning, 알전구 줄, 손글씨 입간판, 비닐 차단막 |
| 청과상 🥬 | 양배추·배추 더미, 무, 사과, 대파 묶음, 나무 좌판 |
| 정육점 🥩 | 흰 타일 벽, 빨간 등, 갈고리, 진열 냉장고, 정육 도마 |
| 어물전 🐟 | 얼음 매대, 푸른 천막, 스테인리스 트레이, 고무장갑 |
| 곡물상 🌾 | 누런 마대 자루, 됫박(되), 갈색 통, 천칭 저울 |
| 잡화점 🫙 | 옹기 항아리(된장·간장·고추장), 양념 병, 마른 미역, 김 묶음 |
| 키친 | 가스레인지, 뚝배기, 무쇠팬, 도마, 양념 통, 행주 |
| 식탁 (혼밥) | 1인 상, 작은 밥공기, 김치 종지, 수저 1벌 |
| 식탁 (가족) | 2~4인 식탁, 가운데 큰 찌개, 반찬 4~6종, 따뜻한 펜던트 조명 |

---

## 5. 음식·재료 카드 룰

> 음식 12개 / 재료 ~20개. 정사각 카드 포맷.

- **카드 비율**: 1:1 (512×512 권장)
- **배경**: 단색 크림 `#F8E9D2` + 미세 종이 텍스처 (모든 카드 통일)
- **시점**: top-down 3/4 (45도 위에서, 음식 전체 보임)
- **그림자**: 카드 하단에 부드러운 원형 드롭섀도우
- **하이라이트**: 음식 표면에 specular 1~2점 (juicy)
- **외곽 처리**: 카드 모서리 8 px round, 외곽 라인 없음 (배경 크림으로 분리)
- **그릇/접시**: 한식 도자기 톤 (백자 또는 분청). 화려한 무늬 금지.

---

## 6. UI / VFX 룰

### 6.1 UI 일러스트
- 장바구니: 갈색 라탄 바구니 + 캐릭터 마스코트와 동일 라인 두께
- 메모지: 한지 톤 + 손글씨 폰트 (Photoshop 후처리, Pretendard 손글씨 변형)
- 가게 간판: §2.2 시그니처 컬러 + 한글 후처리

### 6.2 VFX
- 픽업 빛: Sesame Gold `#FFC857` 원형 펄스
- 빨간 shake: Gochu Red `#E63946` 0.2s flash
- 타이머 펄스: 50% 이하부터 Persimmon → Gochu Red 색 전환
- ★ 등급: 별은 Sesame Gold + 흰 specular, ★3에 한해 주변 small particle burst

---

## 7. MJ 약점 회피 규칙 (Must-Follow)

> MVP 일정의 R-A4 (캐릭터 일관성) / R-A5 (한국적 디테일) 완화를 위한 강제 룰.

| 약점 | 회피 룰 |
|------|--------|
| **손가락 5개 오류** | mitten 손 강제, prompt에 `mitten hands, simplified four-finger hand` |
| **정면 얼굴 비대칭** | 정면 금지, 3/4 또는 7/8 시점만, prompt에 `three-quarter view` |
| **한글 텍스트 깨짐** | anchor 단계에서 한글 시도 금지, 간판은 "글리프 placeholder"로만, **모든 텍스트는 Photoshop 후보정** |
| **여러 인물 얼굴 일관성** | 환경 BG는 인물 비포함으로 생성, 인물은 별도 시트에서 합성 |
| **눈동자 사시 / 비대칭** | 점·콩알 눈 강제 (홍채 디테일 금지) |
| **음식이 서양 디저트로 빠짐** | prompt에 반드시 `Korean food, K-food` + 음식명 영문 직역 (예: `tteokbokki spicy rice cake`) |
| **재래시장이 일본 시장으로 빠짐** | prompt에 `Korean traditional market, Namdaemun market style` 명시, `Japanese`, `Tokyo`, `Chinatown` negative |
| **chibi가 anime girl로 빠짐** | `chibi mascot, picture book illustration` 강제, `anime girl, manga` negative |
| **3D 렌더 톤으로 빠짐** | `2D illustration, hand-painted` 강제, `3D render, octane, unreal` negative |
| **과도한 디테일 폭주** | `simple, clean composition, limited palette` 강제 |

---

## 8. 자산 export 규격

| 카테고리 | 해상도 | 포맷 | 폴더 |
|---------|--------|------|------|
| BG (Scene 1·2·3) | 2048×1152 (16:9) | PNG (투명 X) | `assets-processed/bg/` |
| 캐릭터 시트 | 1024×1024 투명 | PNG (alpha) | `assets-processed/char/` |
| 캐릭터 reaction | 1024×1024 투명 | PNG (alpha) | `assets-processed/char/reactions/` |
| 음식 카드 | 512×512 투명 | PNG (alpha) | `assets-processed/food/` |
| 재료 카드 | 256×256 투명 | PNG (alpha) | `assets-processed/ingredient/` |
| UI 일러스트 | 가변 (~512) 투명 | PNG (alpha) | `assets-processed/ui/` |
| VFX 시트 | 1024×1024 atlas | PNG (alpha) | `assets-processed/vfx/` |
| **원본** | MJ upscale 최대 | PNG | `assets-raw/` (날짜·anchor ID 명명) |

**파일명 컨벤션**: `{category}_{name}_{variant}_v{n}.png`
예: `char_mother_happy_v1.png`, `bg_market_entrance_v2.png`, `food_kimbap_v1.png`

---

## 9. Anchor Images (Placeholder)

> 본 섹션은 Week 1 anchor lock 게이트 통과 후 확정 이미지·MJ job ID·`--sref` URL로 채운다.
> 게이트 통과 전에는 placeholder.

### 9.1 캐릭터 Anchor (5장)
| ID | Subject | 파일 | MJ job ID | `--sref` URL | Status |
|----|---------|------|-----------|-------------|--------|
| CH-01 | 주인공 (혼밥, 정면 3/4) | TBD | TBD | TBD | ⏳ pending |
| CH-02 | 어머니 (Tier 2 가족) | TBD | TBD | TBD | ⏳ pending |
| CH-03 | 아버지 (Tier 2 가족) | TBD | TBD | TBD | ⏳ pending |
| CH-04 | 주인공 Happy 표정 (★3 reaction) | TBD | TBD | TBD | ⏳ pending |
| CH-05 | 주인공 Subtle 표정 (★1/★2 reaction) | TBD | TBD | TBD | ⏳ pending |

### 9.2 환경 Anchor (5장)
| ID | Subject | 파일 | MJ job ID | `--sref` URL | Status |
|----|---------|------|-----------|-------------|--------|
| BG-01 | 청과상 🥬 외관 + 내부 매대 | TBD | TBD | TBD | ⏳ pending |
| BG-02 | 정육점 🥩 외관 + 내부 매대 | TBD | TBD | TBD | ⏳ pending |
| BG-03 | 어물전 🐟 외관 + 내부 매대 | TBD | TBD | TBD | ⏳ pending |
| BG-04 | 곡물상 🌾 외관 + 내부 매대 | TBD | TBD | TBD | ⏳ pending |
| BG-05 | 잡화점 🫙 외관 + 내부 매대 | TBD | TBD | TBD | ⏳ pending |

> 음식 12개 anchor는 game-designer의 음식 12개 선정 권고서 수령 후 다음 sprint에서 작성 (`prompts-library.md` §Food Anchor Placeholder 참조).

---

## 10. Week 1 Anchor Lock Gate — PASS/FAIL 체크리스트

> 본 게이트 통과 = M1 art sprint 진입 신호.
> [`art-workload-estimate.md` §5.2 Production Blocker 순위 #1](art-workload-estimate.md).
> 게이트 운영자: art-director (자체 평가) + pm (최종 승인).

### 10.1 게이트 항목 (7항, 모두 PASS여야 통과)

> Anchor별 PASS/CONDITIONAL/FAIL 셀 단위 평가표(10 anchor × 7 게이트)와 종합 LOCK 조건은 [`art-anchor-rubric.md`](art-anchor-rubric.md) 참조. 사용자 MJ 실행 단계별 키트는 [`mj-session-kit.md`](mj-session-kit.md) 참조.


| # | 항목 | PASS 기준 | FAIL 시 액션 |
|---|------|----------|-------------|
| **G1** | **스타일 일관성** | 캐릭터 5장이 한 시트 위에 나란히 놓였을 때 "같은 IP의 캐릭터"로 인식됨. 환경 5장도 한 시장 안의 옆가게로 인식됨. | `--sref` URL을 재생성, 같은 anchor에서 prompt 재시도. 3회 실패 시 anchor 자체 재선정. |
| **G2** | **chibi 비율 적합성** | 캐릭터 5장 모두 머리:몸 = 1:1.5~2.0 범위. 손은 mitten. 눈은 점/콩알. | 비율이 깨진 컷을 재생성, 또는 Photoshop으로 머리/몸 비례 보정 후 재평가. |
| **G3** | **컬러 팔레트 준수** | 5+5 = 10장 모두 §2 베이스 팔레트 안에 머묾. 가게 5종은 §2.2 시그니처 컬러가 명확히 식별됨. 채도 100% 영역 없음. | LUT 1장 작성하여 일괄 color-grade 후 재평가. LUT로 못 잡으면 prompt에서 컬러 키워드 강화 후 재생성. |
| **G4** | **K-touch 명료성** | 외부인이 봤을 때 "한국 시장"·"한국 음식"임이 5초 안에 식별됨. 일본·중국 시장 인상이 없음. | prompt에 `Korean traditional market, Namdaemun style` 강화 + 일본/중국 negative 추가. 간판 글리프가 일본어로 빠졌으면 후보정. |
| **G5** | **조명·시점 통일** | 환경 5장 모두 §4.2 골든아워 + 오른쪽 위 45도 주광 일치. 캐릭터 시트는 3/4 또는 7/8 시점 일치. | 어긋난 컷만 재생성. anchor URL이 흔들렸으면 가장 좋은 1장으로 `--sref` 재고정 후 나머지 재생성. |
| **G6** | **MJ 약점 회피** | §7 약점 10개 중 5+5 anchor에서 발생한 사례 0건 (손가락 오류·정면 얼굴 비대칭·anime girl·3D 렌더 빠짐·한글 시도 등). | 발생 항목에 대해 §7 회피 룰 prompt 재적용. 후보정 가능한 건 보정, 불가능한 건 재생성. |
| **G7** | **Unity 임포트 검증** | anchor 중 BG 1장 + 캐릭터 1장을 §8 규격으로 export → `unity-project/Assets/Art/_anchor/`에 임포트 → Sprite Renderer로 빈 씬에 배치 → 흐리거나 alpha 깨짐 없음. (R-A9 완화) | export 파이프라인 수정 (해상도/포맷/알파). PSD 중간 저장 누락이면 워크플로 보강. |

### 10.2 게이트 PASS 기준 (Top 3 우선순위)

지연 발생 시 우선 통과해야 할 3항:
1. **G1 스타일 일관성** — 일관성이 깨지면 M1 sprint 전체 재작업 위험. **가장 비싸다.**
2. **G6 MJ 약점 회피** — 약점이 anchor에 들어가면 모든 파생 자산에 증식. anchor에서 잡지 못한 약점은 30개+ 자산에서 반복됨.
3. **G4 K-touch 명료성** — 차별점 자체. 일본·중국 인상이 섞이면 ASO·스토어 인상에서 즉시 실점.

### 10.3 PASS 판정 절차
1. 캐릭터 5장 + 환경 5장을 한 페이지(grid 2×5)로 contact sheet 작성
2. art-director 자체 G1~G7 체크 → 결과 본 문서 §11 Decisions 로그
3. pm에게 contact sheet + 체크 결과 공유 → 최종 PASS/FAIL 판정
4. PASS → `--sref` URL 10개를 `prompts-library.md` §0 Anchor Lock 표에 영구 기록 (이후 M1 모든 자산에 동일 sref 강제)
5. FAIL → 가장 큰 실패 항목 1~2개에 집중하여 재생성, 최대 3 라운드. 3 라운드 후에도 FAIL 시 → pm 에스컬레이션 + scope/스타일 재논의

### 10.4 게이트 시점·예산
- **목표 시점**: M0 Week 1 종료 (2026-05-23 + 7일)
- **MJ 예산**: anchor 10장 × 라운드 평균 3회 × 4 variation = ~120 generations (Standard Plan 한 달 fast hours 안에 충분)
- **art-director 작업 시간**: 10~16h (anchor lock 사전 작업, `art-workload-estimate.md` §4.1)

---

## 11. Decisions Log (anchor 게이트 결과 누적)

> 게이트 라운드마다 결과 추가.

| 라운드 | 날짜 | G1 | G2 | G3 | G4 | G5 | G6 | G7 | 종합 | 비고 |
|-------|------|----|----|----|----|----|----|----|------|------|
| R1 | TBD | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | — |

---

## 12. 변경 이력
- **2026-05-24 v0.2** — Week 1 anchor lock 실행 키트(`mj-session-kit.md`) + 평가 rubric(`art-anchor-rubric.md`) 신설 연동. §10.1 게이트 항목 상단에 rubric 참조 한 줄. §3.5 표정 시트에 U-2 sync(어머니/아버지 L11 동시 unlock으로 reaction 6컷 = 양친 ★1/2/3) + reaction prompt sleeping 회피 원칙 한 줄. 본문 룰(컬러·비율·조명·MJ 약점 10항·게이트 7항) 무변경.
- **2026-05-23 v0.1** — 초안. ADR-002 마스코트 톤 + ADR-003 MVP scope에 맞춰 작성. 캐릭터 룰(머리:몸 1:1.5~2, mitten 손, 점 눈), 컬러 팔레트(베이스 8 + 가게 5), 조명 통일(골든아워), MJ 약점 회피 10항, Week 1 게이트 7항 + PASS top 3 정의. anchor 이미지는 placeholder.
