# K-Food Master GDD (Game Design Document)

> 버전: **v2.1** · 최초 작성: 2026-05-23 · 최종 개정: 2026-05-23
> 본 문서는 **K-Food Master**의 게임 디자인 문서.
> v2.1 변경 요약: [ADR-004](decisions.md#adr-004) 반영 — Unity → Godot 4.6 (GDScript only) 엔진 전환, §8 Tech Stack / §6.3 데이터 형식 / §12.3 기술 의존성 / §13 R10 갱신.
> v2.0 변경 요약: pm 관점의 KPI(§11) / 의존성(§12) / 리스크(§13) / Go-NoGo 판정 기준(§14) 신설.

---

## 1. Concept
- 한식 요리 매칭 게임. **재료 선택 + 조리 방법 + 조리 시간**의 3단계 점수.
- **사회적 progression**: 1인분에서 시작 → 가족 식사 → 친구 초대 → 파티로 확장.
- **3-stream 수익 모델** (프로그래매틱 광고 + Store Ads + IAP), 캐주얼 모바일 게임. *(상세: §5)*

## 2. Core Loop (30~60초 1 cycle)
Round는 **3-scene 구조**로 진행 (수퍼마켓 → 키친 → 식탁). 상세 UI/연출: [`systems/cooking-mechanics.md`](systems/cooking-mechanics.md) §1.

1. **요리 선택** (또는 자동 배정)
2. 🏪 **재래시장 — 재료 선택 단계** (15~30초) *(가게 5종 순회: 청과/정육/어물/곡물/잡화)*
3. 🍳 **키친 — 조리 방법 선택 단계** (5~10초)
4. 🍳 **키친 — 조리 시간 단계** (타이밍 게임)
5. 🍽 **식탁 — 캐릭터 시식 + 점수 계산 + ★ 등급 + 보상** *(tier에 따라 식탁 인원 변화: 혼밥→가족→친구→파티)*

```
[요리 배정] → [재료] → [방법] → [타이밍] → [채점/보상] → 다음 요리
       ↑___________________________________________________|
```

## 3. Scoring System
- **공식**: `재료 정확도 × 방법 정확도 × 시간 정확도 = 총점`
- 각 항목 0.0 ~ 1.0 정규화 → 곱 후 100점 환산
- **별 등급**
  - ★☆☆ : 50점 이상
  - ★★☆ : 75점 이상
  - ★★★ : 90점 이상
- 별 3개 시 보상 ×2, 일정 별 누적 시 다음 tier 해금

## 4. Progression (5 tiers)

| Tier | 레벨 범위 | 인분 | 음식 예시 | 사회적 컨텍스트 | 광고 트리거 추가 | MVP 포함? |
|------|----------|------|----------|---------------|----------------|----------|
| 1 | 1~10 | 1인분 단품 | 라면, 김밥, 계란말이, 떡볶이, 떡국 | 혼밥 | Hint, Retry | ✅ **MVP** |
| 2 | 11~25 | 2인분 단품 | 비빔밥, 김치찌개, 제육볶음, 갈비찜 | 가족 식사 | Skin unlock | ✅ **MVP** |
| 3 | 26~50 | 3인분 + 사이드 | 삼겹살 + 김치 + 쌈, 부대찌개 + 라면사리, 닭갈비 + 볶음밥 | 친구 초대 (캐릭터 1~3명) | 부스트 아이템 | Post-launch M3~M4 |
| 4 | 51~80 | 4~6인분 다중 요리 | 한정식 4찬, 잔칫상, 백반 5첩 | 친목 모임 | 시간 연장 | Post-launch M5~M6 |
| 5 | 81+ | 풀코스 파티 | 한정식 코스, 결혼식 잔칫상, 명절상 (설날/추석) | 파티 (10인+) | 파티 부스트 | Post-launch M5~M6 |

**규칙 (디자인 비전 — 5-tier 풀)**
- 각 tier 진입 시 **새로운 친구 캐릭터 unlock** (Tier 1·2는 가족 단위, Tier 3+는 친구).
- **MVP는 Tier 1~2만 구현** ([ADR-003](decisions.md#adr-003-mvp-first-전환--34개월-출시--점진-확대-supersedes-adr-002)). Tier 3~5는 시장 검증 후 LiveOps로 추가.
- 5-tier 디자인 비전은 cooking-mechanics 등 시스템 문서에 그대로 보존 — post-launch 빠른 확장 위해.

## 5. Monetization

### 5.1 Revenue Streams
1. **Stream A — Programmatic Ads** (AppLovin MAX)
2. **Stream B — Sponsored / Affiliate Ads** (한식 재료 매장 — online & offline)
3. **Stream C — IAP** (Google Play Billing)

> 유료 앱 모델은 사용하지 않음 (Free-to-Play 전제).

### 5.2 Stream A — Programmatic Ads
**AppLovin MAX Mediation** 기반.

- **Rewarded Video** 트리거
  - 재료 힌트
  - 오답 무료 1회 (재시도)
  - 시간 perfect 구간 확대 (난이도 완화)
  - 친구 초대 unlock 가속
  - Daily 보너스 2x
- **Interstitial**: **3 레벨마다 1회** (FTUE 5분 이내에는 노출 금지)
- **Banner**: 메인 메뉴/상점 등 비-게임플레이 화면 한정 (게임플레이 중 미노출)

### 5.3 Stream B — Store Ads (NEW)

**목적**: 한식 재료 구매처를 게임 내에서 안내하여 affiliate commission 또는 sponsored 수익 창출. 게임 테마와 직접 연관되므로 UX 친화적이며 광고 거부감이 낮음.

**두 가지 매장 타입**
- **온라인 매장**: 쿠팡, Amazon, H-Mart 등 (affiliate link)
- **오프라인 매장**: Google Places / 카카오맵 API로 근처 한식 마트 표시

**노출 지점**
- 재료 상세 카드: "이 재료 어디서 사나요?" 버튼
- 요리 완료 화면: "직접 만들어볼래요? 재료 보기"
- 데일리 레시피: 재료 패키지 affiliate
- 메인 메뉴 배너: Sponsored brand *(post-launch)*
- 로딩 화면: Sponsored "Powered by ..." *(post-launch)*

**MVP 범위**
- Amazon Associates 통합 (글로벌 한식 카테고리)
- 쿠팡 Partners 통합 (한국 유저)
- **재료 상세 카드 + 요리 완료 화면**에만 노출
- Offline 매장: Google Places API로 무료 표시 (수익 X, UX 가치만)

**Post-launch 확장**
- 비비고, CJ제일제당, 농심 등 한식 brand 직접 영업 (sponsored deal)
- 위치 기반 오프라인 매장 sponsored
- 추가 affiliate 네트워크 통합

**기술 아키텍처**
- 백엔드: **Firebase Functions** — 지역/언어 기반 매장 매칭, 동적 affiliate link 생성
- 클라이언트는 `ingredient_id`만 전송, 링크는 백엔드에서 동적 제공
- → **앱 업데이트 없이 파트너 추가/변경/A/B 가능**

**Disclosure 요구사항**
- 모든 매장 노출에 **"광고" 또는 "Sponsored" 라벨 필수**
- Privacy Policy에 affiliate 사용 명시
- **Google Play / FTC / 표시광고법** 준수

**수익 예상 (DAU 1,000 기준)**
| 구분 | 월 예상 |
|------|--------|
| Affiliate | $30 ~ $100 (초기) |
| Sponsored (post-launch DAU 10K+) | $3,000+ |
| Offline 매장 표시 | $0 (UX 가치) |

### 5.4 Stream C — IAP
**Google Play Billing Library** 기반.

- **Remove Ads**: $2.99 — 배너/전면 제거, 보상형은 유지
- **Coin Pack**: 단계별 (예: $0.99 / $4.99 / $9.99 / $19.99)
- **Korean Food Pack DLC**: 지역별 특별 메뉴 셋 (전라도 한정식, 제주 향토 등)

### 5.5 통합 수익 예상

**DAU 1,000 기준 (MVP 시점)**
| Stream | 월 예상 |
|--------|--------|
| A (프로그래매틱 광고) | ~$1,350 |
| B (매장 광고 — affiliate only) | ~$50 |
| C (IAP) | ~$1,650 |
| **합계** | **~$3,000/월** |

**성숙기 (DAU 10K+ · sponsored brand 확보)**
| Stream | 월 예상 |
|--------|--------|
| A | scale 비례 |
| B | $3,000+ |
| C | scale 비례 |
| **합계** | **~$10,000+/월** |

## 6. Data Structure

### 6.1 Foods (50+)
```
id              : string (예: "tteokbokki_classic")
name_ko         : string
name_en         : string
tier            : int (1~5)
ingredients     : Ingredient[]
cooking_methods : CookingMethod[]
cook_time_sec   : float
region          : enum (서울/경상/전라/제주/북한/기타)
difficulty      : int (1~5)
```

### 6.2 Ingredients (100+)
```
id        : string
name_ko   : string
name_en   : string
category  : enum (채소/육류/해산물/곡물/장류/양념/유제품/기타)
image     : Sprite ref
```

### 6.3 Friends (15+)
```
id            : string
name          : string
preferences   : FoodTag[]   // 좋아하는/싫어하는 음식 태그
unlock_level  : int
```

> 데이터는 Godot `Resource` (`.tres`) 또는 CSV/JSON → Resource 변환 파이프라인 권장 ([ADR-004](decisions.md#adr-004)).

## 7. Differentiation
- **한식 특화**: K-food 한류 흐름 활용 (글로벌 인지도 증가 중)
- **사회적 progression**: 혼자 → 파티로 이어지는 **정서적 arc** (단순 점수 게임 차별화)
- **타이밍 게임 요소**: 짧고 만족스러운 피드백 → **TikTok / Shorts viral** 가능성

## 8. Tech Stack

> [ADR-004](decisions.md#adr-004) 채택으로 **Godot 4.6 (GDScript only)**로 전환. C#/.NET 미사용. Firebase / Places / 카카오맵 / Amazon Associates / 쿠팡 Partners 등 engine-agnostic 항목은 모두 무변경.

- **엔진**: **Godot 4.6 (또는 4.5.2 LTS 라인), GDScript only** (C#/.NET 미사용)
- **광고 (Stream A)**: **AppLovin MAX Godot plugin** (공식, `AppLovin/AppLovin-MAX-Godot`, v1.2.0+ / 2025-04-24)
  - AdMob / Meta Audience Network 등 mediated networks 지원, UMP 통합, Amazon Publisher Services 통합 가이드 제공
- **백엔드 / 분석**: Firebase
  - **클라이언트**: **Godotx Firebase** (`godot-x/firebase`, MIT) — Core / Analytics / Crashlytics
  - Analytics, Remote Config, Crashlytics
  - **Cloud Functions** — Stream B 매장 매칭 / 동적 affiliate link 생성
- **위치 (Stream B)**: Google Places API (오프라인 매장), 한국 지역은 카카오맵 API 검토
- **Affiliate (Stream B)**: Amazon Associates, 쿠팡 Partners (MVP), 추가 네트워크는 post-launch
- **결제 (Stream C)**: **Godot Foundation Google Play Billing plugin** (직접 유지보수)
- **Games Services**: **Godot Google Play Games Services plugin** (Foundation), iOS는 추후 **Godot StoreKit 2 plugin**
- **테스트**: Android instrumented tests **Firebase Test Lab** 통합
- **UI / 폰트**: Godot 4.x 내장 Label / RichTextLabel + 한국어 웹폰트 (예: Pretendard, 본고딕)

## 9. MVP Scope (출시 시점)

> **[ADR-003](decisions.md#adr-003-mvp-first-전환--34개월-출시--점진-확대-supersedes-adr-002) 채택으로 MVP-first 전환.** 3~4개월 내 최소 검증 가능한 MVP 출시 → 실데이터 기반 점진 확대.

### 9.1 콘텐츠
- **음식 10~15개** (game-designer 권고 후 확정, 권장 ~12개)
- **Tier 1~2만** (1인분 단품 + 2인분 — §4)
- **친구 캐릭터 1~2명** (가족 단위 — Tier 2에서 등장)
- **다점포 5가게 모두 유지** (청과/정육/어물/곡물/잡화 — 핵심 차별점, 깎지 않음) — [`systems/cooking-mechanics.md`](systems/cooking-mechanics.md) §2.2
- **Scene 3 식탁 배경 2종** (Tier 1 혼밥 + Tier 2 가족)
- Tier 3~5 (친구 초대 / 친목 모임 / 파티) → **Post-launch** (§10.2)

### 9.2 시스템
- 광고 Stream A (AppLovin MAX) — full
- **광고 Stream B — Affiliate만** (Amazon Associates, 쿠팡 Partners). Brand sponsored는 post-launch.
- IAP — **Remove Ads + Coin Pack 4단** (Korean Food Pack DLC는 post-launch)
- Firebase Analytics + Remote Config + Crashlytics + Cloud Functions

### 9.3 i18n / 플랫폼
- 언어: **한국어 + 영어**
- 플랫폼: **Android only** (iOS는 post-launch — §10.2)

## 10. Roadmap

> **ADR-003 채택으로 3~4개월 MVP + 후속 LiveOps 12개월.**

### 10.1 Pre-Launch (MVP, 3~4개월)

| Milestone | 기간 | 산출물 / 게이트 |
|-----------|------|---------------|
| **M0 — 기획·디자인 finalize** | 3~4주 | GDD lock, **MVP 음식 12개 확정**(game-designer), 친구 1~2명 personality, art anchor 2종 lock (게이트), screen-flow 완료 |
| **M1 — Art production sprint** | 3~4주 | 캐릭터 1~2명 마스코트 + reaction 6컷, 재래시장 5가게 + 입구, 키친, **식탁 2종 (Tier 1·2)**, 재료 카드 ~20개, UI/VFX/트랜지션 |
| **M2 — 코드 구현** *(M1 후반과 병행)* | 4~6주 | Unity 3-stage 메커닉, Firebase backend, AppLovin MAX, IAP, **Stream B affiliate (Amazon·쿠팡)** |
| **M3 — QA + Closed Beta + Soft Launch** | 2~4주 | 내부 QA, closed beta, soft launch (Asia 1 시장), 폴리시 → Global launch |
| **총** | **3~4개월** | 2026-05 시작 → **2026-08~09 launch** 예상 |

> **게이트**: M0 종료 시 pm + game-designer + art-director reality check. 일정 ±20% 초과 시 scope 재조정.
> **Dual-track 권장**: M2~M3 동안 Tier 3 자산 40% pre-production (post-launch 콘텐츠 지속력 확보).

### 10.2 Post-Launch LiveOps (12개월)

| 시점 | 추가 |
|------|------|
| **Month 1~2** | 음식 +5~10개, Tier 3 unlock 준비 (자산 100% 완성) |
| **Month 3~4** | 친구 +3~5명, **Tier 3 (친구 초대) 출시** + Korean Food Pack DLC 1차 |
| **Month 5~6** | **Tier 4~5 (친목 모임 + 파티) 출시**, 멀티 요리 메커닉 |
| **Month 7~8** | 시즌 이벤트 1차 (추석/설날), brand sponsored 영업 시작 |
| **Month 9~12** | iOS 출시, 콘텐츠 +30개·친구 +10명 누적, Tier 6 검토 |

## 11. Success Metrics / KPI 목표

> MVP 출시 시점 기준. 모든 수치는 **Firebase Analytics + AppLovin MAX 대시보드 + Google Play Console** 교차 확인.

### 11.1 Engagement / Retention
| 지표 | MVP 목표 | 우수 (top quartile) |
|------|---------|---------------------|
| D1 retention | ≥ 35% | ≥ 45% |
| D7 retention | ≥ 15% | ≥ 22% |
| D30 retention | ≥ 5% | ≥ 10% |
| 평균 세션 길이 | ≥ 4분 | ≥ 7분 |
| 일일 세션 수 / DAU | ≥ 2.5 | ≥ 4 |
| FTUE 완주율 | ≥ 70% | ≥ 85% |

### 11.2 Monetization
| 지표 | MVP 목표 | 비고 |
|------|---------|------|
| ARPDAU | ≥ $0.03 | 캐주얼 평균 $0.02~0.05 |
| Rewarded ad 시청률 (eligible 유저 기준) | ≥ 25% | GDD §5.2 트리거 5종 합산 |
| Interstitial CTR | 모니터링만 | 정책 조정용 |
| IAP 전환율 (Remove Ads) | ≥ 1.0% (D30) | $2.99 단일 SKU 기준 |
| Stream B (Store Ads) CTR | ≥ 3% (재료 카드) | affiliate 클릭 → 전환 별도 추적 |

### 11.3 Gameplay Health
| 지표 | 목표 | 의미 |
|------|------|------|
| Round당 평균 ★ | 1.5 ~ 2.2 | 너무 쉬움(>2.5) / 너무 어려움(<1.0) 경계 |
| Stage 3 PERFECT 비율 | 25 ~ 40% | 타이밍 게임 난이도 검증 |
| 레벨 fail rate | 10 ~ 25% | rewarded ad "재시도" 발생 유도 구간 |
| 크래시-free 세션 | ≥ 99% | Crashlytics 기준 |

### 11.4 분석 이벤트 (필수 트래킹 — data-analyst와 sync)
- `round_start` (food_id, tier)
- `stage_complete` (stage_no, accuracy)
- `round_complete` (score, stars, used_hint)
- `ad_request` / `ad_impression` / `ad_clicked` (placement)
- `store_ad_click` (ingredient_id, store_type, partner)
- `iap_initiate` / `iap_complete` (sku)
- `ftue_step` (step_no)
- `app_open` / `app_background`

## 12. Dependencies

### 12.1 외부 계정 / 승인
| 항목 | 책임 | 리드타임 | MVP 차단? |
|------|------|---------|----------|
| Google Play Console publisher 계정 | 사용자 | 1~3일 + $25 | ✅ Yes |
| Firebase 프로젝트 (Analytics/Crashlytics/Remote Config/Functions) | backend-dev | 즉시 | ✅ Yes |
| AppLovin MAX 계정 + Android SDK 키 | 사용자 + unity-dev | 1주 (심사) | ✅ Yes |
| Amazon Associates 가입 + 한식 카테고리 승인 | 사용자 | 1~2주 + 사후 매출 심사 | ⚠️ Stream B만 차단 |
| 쿠팡 Partners 가입 (한국 거주자 요건) | 사용자 | 1주 | ⚠️ Stream B만 차단 |
| Google Places API key + billing 활성화 | backend-dev | 즉시 | ⚠️ Stream B 오프라인만 |

### 12.2 라이선스 / 법무
| 항목 | 상태 | 비고 |
|------|------|------|
| Pretendard 폰트 (OFL) | 무료 사용 가능 | 라이선스 고지 필수 |
| 본고딕 / Noto Sans KR (SIL OFL) | 무료 사용 가능 | 동일 |
| 일러스트 — 자체 제작 또는 라이선스 구매 | 미정 | art-director가 Phase 2 결정 |
| Privacy Policy (affiliate / 광고 / 데이터 수집) | 미작성 | Stream B follow-up |
| Disclosure 라벨 (광고/Sponsored) | 미정 | Google Play / FTC / 한국 표시광고법 동시 충족 |
| COPPA / 13세 미만 정책 | 미결정 | 타겟 연령에 따라 광고 ID 정책 변경 |

### 12.3 기술 의존성
- **Godot 4.6 (또는 4.5.2 LTS 라인)** — FOSS, 매출 게이트 없음 ([ADR-004](decisions.md#adr-004))
- **AppLovin MAX Godot plugin** v1.2.0+ → 안정 버전 lock 필요
- **Godot Foundation Google Play Billing plugin**
- **Godotx Firebase** (`godot-x/firebase`, MIT) — Analytics / Crashlytics
- Firebase Cloud Functions Node 20 런타임
- Android API 24+ (AppLovin MAX Godot plugin v1.2.0 요구사항 재확인 후 finalize — godot-dev follow-up)

## 13. Risks & Mitigations

| # | 리스크 | 영향 | 가능성 | 완화안 |
|---|-------|------|-------|--------|
| R1 | 광고 노출 빈도 과다 (3 stream 동시 운영) → D1/D7 하락 | High | Med | Stream A/B placement 충돌 매트릭스 작성, A/B로 최적 빈도 도출 |
| R2 | 한식 글로벌 인지도 편차 (서구권 부대찌개/잡채 인지도 낮음) | Med | High | i18n에 음식 설명 카드(영양/유래) 동봉, 친숙 음식부터 tier 1 배치 |
| R3 | Stage 3 타이밍 게임 저성능 단말 프레임드롭 → 판정 왜곡 | High | Med | fixed timestep 보간, low-end QA 단말 셋 확보 (cooking-mechanics.md §10) |
| R4 | Amazon Associates commission 인하 (선례 多) | Low | High | 쿠팡 Partners + 다중 affiliate 네트워크로 분산 |
| R5 | K-food 트렌드 cooling (정점 후 하락) | Med | Med | 12개월 내 출시 + 시즌 이벤트로 신선도 유지 |
| R6 | iOS Apple App Store affiliate link 정책 제한 | Med | Med | iOS 출시 시 Stream B 비활성화 또는 in-app browser 우회 검토 |
| R7 | Firebase Functions cold-start으로 매장 카드 응답 지연 (>1s) | Low | Med | min-instances=1 또는 클라이언트 로컬 캐시 |
| R8 | 한식 일러스트 라이선스 분쟁 (스톡 vs 자체 제작) | High | Low | 자체 제작 원칙, 외주 시 work-for-hire 계약 명문화 |
| R9 | Google Play 정책 위반 (광고 disclosure 미흡) | Critical | Low | 런칭 전 정책 체크리스트 + 법무 1회 검토 |
| R10 | ~~Unity LTS 라이프사이클 종료~~ → **ADR-004 채택으로 해소**. Godot 4.5.2 LTS / 4.6 라이프사이클 추적은 godot-dev follow-up | Low | Low | FOSS — 강제 마이그레이션 압력 없음, 분기별 release note 모니터링 |

## 14. Go / No-Go 판정 기준 (MVP 출시)

> 모든 항목 **GO**여야 정식 출시. 단 ⚠️ 항목은 1개까지 conditional release 허용.

### 14.1 품질 (Hard Gates)
- [ ] 크래시-free 세션 ≥ 99% (내부 베타 1주 기준)
- [ ] AAB 파일 크기 ≤ 100 MB (Google Play 권장)
- [ ] Stage 3 60 fps 유지 — low-end 단말(Galaxy A 시리즈) 검증
- [ ] FTUE 완주율 ≥ 70% (내부 플레이테스트 N=20+)
- [ ] 음식 30개 × 친구 5명 콘텐츠 완비 (GDD §9 MVP Scope)

### 14.2 수익화 (Hard Gates)
- [ ] AppLovin MAX 어댑터 ≥ 3개 통합 (Meta, Google, AppLovin Exchange)
- [ ] IAP `remove_ads` Google Play Console 등록 + 테스트 결제 통과
- [ ] Stream B affiliate link 백엔드(Functions) 응답 시간 P95 ≤ 800ms

### 14.3 정책 / 법무 (Hard Gates)
- [ ] Privacy Policy 게시 (개인정보/광고/affiliate 명시)
- [ ] Stream B 모든 노출 지점에 "광고"/"Sponsored" 라벨 적용
- [ ] Google Play Data Safety 폼 정확 작성
- [ ] COPPA / 13세 미만 정책 결정 및 적용

### 14.4 ⚠️ Conditional (1개까지 허용)
- [ ] iOS 출시 — 명시적 Out of Scope (Month 6)
- [ ] 시즌 이벤트 — 명시적 Out of Scope (Month 3)
- [ ] Stream B sponsored brand 직접 영업 — Phase 2

### 14.5 판정 책임
- **GO/No-Go 회의**: 출시 1주 전, 참석 — pm + unity-dev + backend-dev + qa-tester
- **승인 권한**: pm 단독 (사용자가 pm role 위임 시 사용자)

---

## 부록: 미확정 / Follow-up

### 게임플레이 / 밸런스
- [ ] 별 등급 임계값(50/75/90) 플레이테스트로 검증
- [ ] Friend preference 시스템 상세: 선호 일치 시 점수 보너스 가중치 정의
- [ ] Tier별 친구 unlock 시 등장 캐릭터 5명 캐스팅 확정 (MVP 범위)

### Stream A — Programmatic Ads
- [ ] Interstitial "3 레벨마다" 빈도 — 광고 매출 vs D1 리텐션 A/B 필요

### Stream B — Store Ads
- [ ] Amazon Associates 계정 신청 + 한식 카테고리 승인 정책 검토
- [ ] 쿠팡 Partners 계정 신청 + 한국 거주자 요건 확인
- [ ] Firebase Cloud Functions 매장 매칭 백엔드 스펙 작성 (입력: `ingredient_id` + locale, 출력: 매장 리스트 + 동적 affiliate URL)
- [ ] Google Places API 쿼터 / 과금 정책 검토 (DAU 1K · 10K 시 예상 비용)
- [ ] 카카오맵 API 도입 여부 결정 (한국 정확도 vs 단일 API 단순성)
- [ ] Privacy Policy 초안 — affiliate / sponsored 사용 명시
- [ ] Disclosure 라벨링 UX (광고 / Sponsored) — Google Play / FTC / 한국 표시광고법 동시 충족안

### Stream C — IAP
- [ ] Coin Pack 정확한 가격 라인업 / 환율별 현지화

---

## 변경 이력
- **v2.1 (2026-05-23)** — [ADR-004](decisions.md#adr-004) 반영. §8 Tech Stack을 Godot 4.6 + Godot Foundation plugin 셋(IAP / GPGS / StoreKit) + Godotx Firebase + AppLovin MAX 공식 Godot plugin으로 갱신. §6.3 데이터 형식 `ScriptableObject` → Godot `Resource (.tres)`. §12.3 기술 의존성 Godot 스택 반영, R10 Unity LTS 종료 리스크 해소.
- **v2.0 (2026-05-23)** — pm 관점 §11~§14 신설: KPI 목표(retention/monetization/gameplay health), Dependencies(외부 계정·라이선스·기술), Risks 10개, MVP Go/No-Go 판정 기준.
- **v1.0 (2026-05-23)** — 최초 작성. Concept, Core Loop, Scoring, 5-tier Progression(확정 표), 3-stream Monetization, Data Structure, Differentiation, Tech Stack, MVP Scope, Post-Launch Roadmap.
