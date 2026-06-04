# Art Needs v2 — 메타 개편 신규 아트 슬롯

> v2.0 메타 개편으로 필요한 **신규 아트 슬롯** 목록. 톤은 기존 **premium v2**(라면 레퍼런스 LOCK: 반사실적·글로시·부피감, 컷아웃) 유지. 배경 규칙: 음식·재료·도구·그릇=검정 또는 흰 단색 → 컷아웃(`tools/cutout_bg.py`), 캐릭터=흰 배경. M1 anchor 프롬프트는 **키워드만** 제안(전체 프롬프트는 별도 sprint).
> 기존 음식 12 아트는 **재사용**(추가 생성 없음).

## 0. 슬롯 총량 요약
| 카테고리 | 신규 슬롯 수 | 비고 |
|---|---|---|
| 캐릭터 15명 × 표정 3 | ~45 (또는 base 15 + 표정 변형) | star1/2/3 |
| 도구 9종 × 3티어 | 27 (기본 9 기존 활용 가능 → +프로 9 +마스터 9 = 18 신규) | |
| 그릇 9종 × (빈/담긴) | ~18 (빈 9 + 음식 담긴 합성은 런타임 가능 시 9) | |
| 재료 티어(특산품·명품) | ~12~20 | 명품 브랜드 톤 |
| 인벤토리/트로피 룸/플레이팅 UI | ~8 | UI |
| **합계(대략)** | **~110 슬롯** | 단계적 생성 |

---

## 1. 캐릭터 15명 (premium, 흰 배경)
`characters-v2 §2.2` 외형 키워드 기반. 각 캐릭터 = **동일 캐릭터 3표정**(star1 보통 / star2 만족 / star3 감동), star1 먼저 → 레퍼런스로 2/3.
| ID | 키워드 프롬프트(요약) |
|---|---|
| C1 엄마 | round warm face, tied-back hair, apron, gentle |
| C2 아빠 | greying hair, cardigan, cozy but discerning |
| C3 조카(8세) | small, big eyes, hoodie, rosy cheeks, cheerful |
| C4 절친 | casual hoodie, glasses, easygoing |
| C5 매운맛 선배 | short hair, flame necktie, confident smirk |
| C6 새콤 친구 | lively, ponytail, fresh bright outfit |
| C7 트레이너 | athletic, training wear, water bottle |
| C8 어르신 | white permed hair, hanbok cardigan, kind sharp eyes |
| C9 미식 취미 | trendy casual, note habit |
| C10 블로거 | camera, analytical look |
| C11 요리강사 | chef apron, measuring tools |
| C12 호텔셰프 | chef coat, focused |
| C13 평론가 | suit, glasses, notebook, rare smile |
| C14 외국 미식가 | foreign features, curious earnest |
| C15 마스터셰프 | white double-breasted coat, charisma, masterful |
> 공통: premium STYLE + chibi mascot 1:1.8 + 흰 배경 isolated + soft contact shadow + 3표정 일관성. (가족 2명 = 기존 reaction 리워크.)

## 2. 도구 9종 × 3티어 (premium, 흰 배경)
기본 9종은 art-prompts-premium-assets §A로 이미 정의됨(대기). 추가로 **프로 9 + 마스터 9** 신규.
| 도구 | 기본 | 프로(중급 마감) | 마스터(장인 톤 키워드) |
|---|---|---|---|
| 칼 | 기존 | brushed steel, better handle | **mirror-polished blade, brass bolster, 장인 각인(maker's mark), subtle gold accent** |
| 도마 | 기존 | thicker hardwood | **premium acacia/edge-grain, branded burn mark, oiled sheen** |
| 냄비 | 기존 | heavier steel | **hammered copper/clad, gleaming, riveted handle** |
| 팬 | 기존 | matte coat | **forged carbon steel, seasoned glossy, premium rivets** |
| 웍 | 기존 | — | **hand-hammered steel, deep patina sheen** |
| 국자/주걱 | 기존 | — | **polished stainless, ergonomic premium, engraved** |
| 김발 | 기존 | — | **fine premium bamboo, silk-tie, lacquer sheen** |
| 튀김솥 | 기존 | — | **double-wall steel, gold-tone trim** |
| 양념볼 | 기존 | — | **celadon/brass premium bowl, glossy glaze** |
> 마스터 = 금속 광택 강화 + 장인 표식(각인/브랜드) + 골드/구리 악센트로 시각적 "최고급" 신호. 흰 배경 isolated 컷아웃.

## 3. 서빙 그릇 9종 (premium, 검정 또는 흰 배경)
각 그릇 **빈 상태** 필수. "음식 담긴" 상태는 런타임 합성 가능하면 생략, 어려우면 음식×그릇 주요 조합만 별도.
| 그릇 | 티어 | 키워드 |
|---|---|---|
| 일반 사기 그릇 | basic | plain white-grey ceramic bowl, simple |
| 나무 소반/그릇 | pro | warm wooden bowl/tray, grain sheen |
| 모던 화이트 플레이트 | pro | clean modern white plate, glossy |
| 옹기 | award | dark earthenware onggi pot, matte clay sheen |
| 백자 | award | Korean white porcelain, pristine, subtle celadon |
| 돌솥 | award | hot stone bowl (dolsot), dark granite, sizzling tone |
| 유리 디너웨어 | award | modern clear glass dish, cool highlights |
| 유기(놋그릇) | award | brass/bronze Korean yugi, warm golden metallic sheen |
| 명품 도자기 | award | artisan tea-bowl tone (이도다완), refined glaze, masterpiece |
> 음식↔그릇 매칭 표는 `scoring-v2 §11`/`schema-delta §5`. 컷아웃 동일 파이프라인.

### 3.1 음식 × 권장 그릇 매칭(아트 합성 우선순위)
| 음식 | 권장 그릇 |
|---|---|
| 순두부찌개 | 옹기 / 돌솥 |
| 비빔밥 | 돌솥 |
| 잡채 | 백자 |
| 떡볶이·콘도그 | 나무 소반 |
| 갈비구이·불고기(한정식) | 유기 / 명품 도자기 |
| 잔치국수·라면 | 백자 / 사기 |

## 4. 재료 티어 아트 (특산품·명품)
기본 재료는 기존 재료 아트 재사용. **특산품·명품은 브랜드 톤 신규**.
| 티어 | 슬롯 예시 | 키워드 |
|---|---|---|
| 특산품 | 영양 고춧가루, 신안 천일염, 의성 마늘 | premium pouch/jar, regional label tone(글자 가독 회피), fresher vivid |
| 명품 | 순창 정통 고추장, 횡성 한우, 트러플장 | luxury branded jar/cut, gold-accent label tone, glossy premium |
> 라벨 글자는 가독 텍스트 회피(브랜드 "톤"만). 컷아웃용 단색 배경.

## 5. UI 신규 슬롯
| 슬롯 | 용도 |
|---|---|
| 인벤토리 패널 | 보유 재료 + 잔여 횟수 게이지, 0이면 회색 |
| 플레이팅 그릇 선택 그리드 | 5초 타이머, 보유 그릇 카드 |
| 트로피 룸 진열장 | 마스터 도구 6 + 어워드 그릇 6, 빈 슬롯 실루엣 |
| 미각 힌트 카드 | 친구 카드의 정성 힌트(아이콘) |
| 다인 디너 상판 | 게스트 2~4인 좌석 + 만족 표시 |
| 경제 HUD | 보유 자금(원), 보상 팝업 |
| 코스 진행 바 | 한정식 다중 메뉴 |
| 칭호/엔딩 배지 | "한식 명인" |
> UI는 기존 UITheme(테라코타·크림) 톤과 정합. premium 일러스트 악센트.

## 5.5 시장 월드 아트 (worldbuilding·markets)
| 슬롯 | 수 | 비고 |
|---|---|---|
| 시장 BG | 10 (기본6+지역4) | 풀 16:9 장면. 핵심 시장은 시간대(새벽/낮/저녁) 변주 |
| 상인 NPC | 10 | 흰 배경 컷아웃, 소품·복장 디테일, 방언 캐릭터 포함 |
| 가판대·소품·간판 | 3 세트 | 가판대 베이스, 시장 소품 세트, 카테고리 간판 아이콘 |
| 이벤트 컷씬 | 2+ | 새벽 경매·도매 특가(+한정입고/명절 응용) |
> 톤: 진짜 한국 시장 디테일(빨간 차양·플라스틱 박스·LED 가격표) + 양식화, 미화 없이 따뜻하게. 전체 프롬프트 `image_prompts_v2_markets.md`.

## 5.6 플레이어 선택 · 신규 메뉴 (v2.3)
| 슬롯 | 수 | 비고 |
|---|---|---|
| 플레이어 프리셋 | 5 × (풀바디+표정3종+부엌포즈) | Mia·Alex·Jin·Sora·Pat. `image_prompts_v2_characters §C` |
| 캐릭터 선택 화면 UI | 1 | 5-slot 캐러셀, 1줄 소개 영역 |
| 오프닝 컷씬 배경 | 2~3 | 도착·첫 부엌·첫 손님(텍스트 오버레이용) |
| 신규 메뉴 