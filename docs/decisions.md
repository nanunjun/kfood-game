# Architecture Decision Records (ADR)

> K-Food Master 프로젝트의 주요 의사결정 기록.
> 형식: 1 decision = 1 record. 비가역·고비용·복수 stakeholder 영향이 있는 결정만 기록.
> Owner: **pm**

## 인덱스
| # | 제목 | 상태 | 날짜 |
|---|------|------|------|
| 001 | *(미작성 — 재래시장 다점포 메커닉 채택)* | Unrecorded | 2026-05-23 |
| 002 | 자체 제작 + AI 도구 + 마스코트 스타일 + Full Feature MVP | **Superseded by [ADR-003](#adr-003)** | 2026-05-23 |
| **003** | **MVP-first 전환 — 3~4개월 출시 + 점진 확대 (supersedes ADR-002)** | **Accepted** | **2026-05-23** |
| **004** | **엔진 선택 — Godot 4.6 (GDScript only) 채택 (CLAUDE.md implicit Unity 정식 대체)** | **Accepted** | **2026-05-23** |
| **005** | **메커닉 확장 — 3-stage → 4-stage (Stage 2A 재료 준비 신설, rhythm tap, Option C optional skill bonus)** | **Accepted** | **2026-05-26** |
| **006** | **Art 생성 도구 pivot — Midjourney → ChatGPT (GPT-4o image / DALL-E 3)** | **Accepted** | **2026-05-27** |
| **007** | **기본 양념 자동 제공 — Basic Pantry SKU 분리 (Stage 1 진열대 제외 + Kitchen 자동 rack)** | **Accepted** | **2026-05-31** |
| **009** | **Guest System 2.0 — 12 flavor × 7 selectable guests × mood × friendship (supersedes Guest 1.0 + friends-system v0.3 axis 모델)** | **Accepted** | **2026-06-04** |
| **010** | **Result Screen 2.0 — 6 row breakdown + 4 emotion + recipe XP + new record + milestone reveal (pure display layer, mechanic 무영향, ADR-009 후속)** | **Accepted** | **2026-06-04** |
| **011** | **8-Module Cooking Pipeline — Slice/Arrange/Stir/Flip/Timing/Season/Roll/Plate 8 reusable modules로 12 음식 sequence 표현 (avoid per-dish minigame)** | **Accepted** | **2026-06-04** |
| **012** | **Action-First Cooking Interaction — 8 module input-layer 재설계 (tap/hold/button → drag/tilt/swipe/flick). 추상 button mechanic → 실제 조리 동작 시뮬레이션. ADR-011 input-layer amendment (scoring/sequence/progression 무변경)** | **Accepted** | **2026-06-05** |

> **ADR-001 backfill 권장**: 재래시장 다점포 메커닉 결정은 `systems/cooking-mechanics.md` §2 + `CHANGELOG.md`에 기록됐으나 ADR 형식 미작성. 필요 시 사후 backfill.

---

## ADR-002: 자체 제작 + AI 도구 + 마스코트 스타일 + Full Feature MVP

- **Status**: ⚠️ **Superseded by [ADR-003](#adr-003)** (2026-05-23 same-day reversal)
- **Date**: 2026-05-23
- **Deciders**: 사용자 (pm role 위임)
- **상위 트리거**: [`art-workload-estimate.md`](art-workload-estimate.md) v1.0 권장(외주 $1.5k~4k) 대안 검토

> 본 ADR의 결정 1~3·5(외주 X / Asset Store / AI 도구 / 마스코트 스타일)는 ADR-003에서도 **유지**됨.
> ADR-003이 뒤집은 부분은 **결정 #4 — "MVP full feature, 일정 8~12개월"** 한 항목.

### Context

직전 art-director 워크로드 estimate에서 다음을 권장:
- Option A (Scene 1 단일 비주얼) + 4~5주 sprint
- **친구 5명 캐릭터 + ★ reaction은 MJ 약점 → illustrator 외주 ($1.5k~4k)**
- UI 아이콘 / 사운드 / BGM은 Asset Store 구매

사용자가 다음 5가지 제약·선호를 제시:
- 외주 미사용 (자체 제작 원칙)
- AI 도구(Midjourney, Suno, Stable Diffusion 등) 적극 활용
- Asset Store 구매 적극 활용
- MVP에서 **full feature 검증** (콘텐츠 깎지 않음)
- 일정 연장 수용 가능

### Decision

다음 5가지를 동시에 채택:

1. **외주 미사용**: 친구 캐릭터 포함 모든 art는 자체 제작
2. **Asset Store 구매 적극**: UI 아이콘, 사운드 팩, BGM 등 가능한 구매
   > → [ADR-004](#adr-004)에서 "Asset Store" 의미 재정의 (paid marketplace 아닌 engine-agnostic 무료 asset 소스 — Kenney / OpenGameArt / Itch / Freesound + Godot Asset Library 무료 항목).
3. **AI 도구 활용**: Midjourney(이미지), Suno(BGM), Stable Diffusion(보조) 등
   > → [ADR-006](#adr-006-art-생성-도구-pivot--midjourney--chatgpt-gpt-4o-image--dall-e-3) (2026-05-27)에서 Midjourney 부분만 **ChatGPT (GPT-4o image / DALL-E 3)**로 변경. Suno/Stable Diffusion 부분은 그대로 유지.
4. **MVP full feature**: 다점포 5가게 / 친구 5명 / Scene 3 tier 5종 / 파티 모드 / Tier 5 콘텐츠 전부 MVP 포함
5. **캐릭터 art 전략**: **마스코트 스타일 (Cookie Run / Chibi 풍)** 채택
   - 근거: MJ 친화적 일관성, K-게임 검증 스타일(쿠키런·라인프렌즈), viral 친화도

### Consequences

**Positive**
- MVP 시점에 full vision 검증 가능 → 시장 반응 데이터 신뢰도 ↑
- 마스코트 스타일은 MJ 캐릭터 일관성 약점을 우회 (chibi 비율은 디테일 차이가 덜 두드러짐)
- 외주 의존성·비용·계약 오버헤드 0
- 자체 제작 스킬 자산 축적 → post-launch 콘텐츠 운영에 재활용

**Negative**
- **MVP 일정 4~5주 → 8~12개월로 연장** (10배+)
- 1인 장기 제작 동기 유지 리스크 (Risk R-A1)
- 8~12개월 사이 시장 변화 리스크: K-food 트렌드, 경쟁작, 광고 정책 (Risk R-A2)
- 마스코트 스타일은 사실적/감성적 reaction 표현 한계 (Scene 3 시식 연출이 다소 단순화될 가능성)

**완화안**
- 마일스톤(M0~M3) 단위 release plan으로 진척 가시화 (GDD §10)
- 주간 progress 점검을 `CHANGELOG.md`에 명시
- 분기별 GDD revisit + 월별 경쟁작 리뷰 (research/)
- **M0 종료 시점에 Go/No-Go 게이트** — 일정 reality check, 필요 시 scope 재조정

### Alternatives Considered

| 대안 | 거절 이유 |
|------|----------|
| v1.0 권장 그대로 (외주 $1.5k~4k) | 사용자 외주 미선호 |
| Feature를 깎아 4~5주 MVP 유지 (Tier 1~3만, 친구 3명) | full feature 검증 우선 원칙 위배 |
| 외주 일부만 (캐릭터만 외주) | 자체 제작 원칙 위배, 스타일 일관성 부담 |
| 사실적 일러스트 (Ghibli-ish) | MJ 캐릭터 일관성 어려움, 결국 외주 필요해짐 |
| 픽셀 아트 / 미니멀 | viral 친화도 낮음, K-게임 트렌드 미스매치 |

### Follow-up Actions
- [ ] art-director: 마스코트 anchor 5장 + 재래시장 anchor 5장 생성 → **Week 1 anchor lock 게이트**
- [ ] art-director: `docs/art-style-guide.md`, `docs/prompts-library.md` 신설
- [ ] game-designer: 친구 5명 personality + 호불호 시스템 디자인 (마스코트 스타일에 맞게)
- [ ] ui-designer: 다점포 `docs/screen-flow.md` (병렬 진행 가능)
- [ ] pm: M0 게이트 일정 확정 + 주간 진척 리뷰 cadence 결정
- [ ] pm: M0 종료 시 reality check 게이트 운영

### 관련 문서
- [art-workload-estimate.md v2.0](art-workload-estimate.md) — 본 ADR 기준 워크로드 (ADR-003으로 v3.0 재계산됨)
- [GDD.md §9 MVP Scope / §10 Roadmap](GDD.md) — full feature + 8~12개월 마일스톤 (ADR-003으로 재정의됨)
- [systems/cooking-mechanics.md](systems/cooking-mechanics.md) — 변경 없음 (메커닉 자체는 동일)

---

## ADR-003: MVP-first 전환 — 3~4개월 출시 + 점진 확대 (supersedes ADR-002)

- **Status**: Accepted
- **Date**: 2026-05-23
- **Deciders**: 사용자 (pm role 위임)
- **Supersedes**: [ADR-002](#adr-002-자체-제작--ai-도구--마스코트-스타일--full-feature-mvp) (결정 #4 한 항목만 반전, 나머지 유지)
- **상위 트리거**: ADR-002 채택 후 사용자 재검토 — 1인 개발 burnout 리스크 + 시장 검증 없는 장기 투자 회피

### Context

ADR-002(같은 날 채택)는 full feature MVP + 8~12개월 일정을 확정했다. 채택 직후 사용자가 다음을 재평가:

- **1인 개발 burnout 리스크**: 8~12개월 단일 sprint는 동기·체력 유지 어려움 (ADR-002 자체가 R-A1으로 flag)
- **시장 검증 부재 리스크**: 검증 없이 8~12개월 투자 후 시장 반응이 부정적이면 손실 폭이 너무 큼
- **빠른 학습 루프 필요**: 실데이터 기반 의사결정이 디자인 직관보다 신뢰도 ↑
- **콘텐츠 확장은 LiveOps 모델에서 흔함**: merge·casual 장르는 launch 후 콘텐츠 추가가 표준

→ **MVP-first 전환**: 3~4개월 내 최소 검증 가능한 MVP 출시 → 실데이터 기반으로 점진 확대.

### Decision

ADR-002의 결정 #1~3, #5는 유지. **결정 #4(MVP full feature, 8~12개월)만 다음으로 대체**:

#### MVP Scope (3~4개월 출시 목표)
| 항목 | 결정 |
|------|------|
| 음식 수 | **10~15개** (game-designer 권고 후 확정, 권장 ~12개) |
| Tier | **1~2만** (1인분 단품 + 2인분) |
| 친구 캐릭터 | **1~2명** (가족 단위, Tier 2에서 등장) |
| 다점포 메커닉 | **5가게 모두 유지** (핵심 차별점, 깎지 않음) |
| Scene 3 식탁 배경 | **2종** (Tier 1 혼밥 + Tier 2 가족) |
| 광고 Stream B Sponsored | **Affiliate (Amazon·쿠팡) 만** — brand sponsored는 post-launch |
| IAP | **Remove Ads + Coin Pack** — Korean Food Pack DLC는 post-launch |

#### Post-Launch Roadmap (LiveOps)
| 시점 | 추가 |
|------|------|
| Month 1~2 | 음식 +5~10개, Tier 3 unlock 준비 |
| Month 3~4 | 친구 +3~5명, **Tier 3 (친구 초대) 출시** |
| Month 5~6 | **Tier 4~5 (친목 모임 + 파티)** |
| Month 7~12 | 시즌 이벤트, brand sponsored, 추가 콘텐츠 |

#### ADR-002에서 유지되는 결정
1. 외주 미사용 (자체 제작)
2. Asset Store 구매 적극
3. AI 도구 활용 (Midjourney, Suno, Stable Diffusion)
   > → [ADR-006](#adr-006-art-생성-도구-pivot--midjourney--chatgpt-gpt-4o-image--dall-e-3) (2026-05-27)에서 Midjourney → **ChatGPT (GPT-4o image / DALL-E 3)** 변경. Suno는 M2~M3 deferred 유지, Stable Diffusion(보조)는 미사용 유지.
5. 마스코트 캐릭터 스타일 (Chibi / Cookie Run / 라인프렌즈 풍)

### Consequences

**Positive**
- **일정 8~12개월 → 3~4개월** (MVP 도달 ~70% 단축)
- **Art workload ~228h → ~80h** (MVP) — 핵심 절감은 음식(50→12), 친구(5→2), Scene 3(5→2종)
- **시장 검증 우선** — 실데이터(retention/ARPDAU/Stream B CTR) 기반으로 후속 콘텐츠 투자 결정
- **Burnout 리스크 완화** — 짧은 sprint 후 launch 만족감 → LiveOps로 페이스 조절
- **현금 예산 절감**: MJ Standard 8개월 → 4개월 + 후속 월별 = 절감 ~$120
- 다점포 메커닉은 깎지 않아 **K-stylistic 차별점 유지**

**Negative**
- **시장 인상에서 콘텐츠 빈약 보일 가능성** (음식 12개) — ASO 키워드 / 스토어 스크린샷에서 보강 필요
- **친구 1~2명만으로 정서적 arc 제한** — Tier 1~2의 사회적 progression(혼밥→가족)만 표현
- **Tier 3~5 검증 지연** — 친목 모임·파티 메커닉의 시장 반응은 post-launch 데이터로만 확인
- **신규 리스크 R-A11: post-launch 콘텐츠 production 지속력** — launch 후 LiveOps cadence 유지 못 하면 retention 하락
  - 완화: launch 전 음식 +5~10개·Tier 3 자산을 **40% pre-production** 권장 (M2~M3 동안 dual-track)

### Alternatives Considered

| 대안 | 거절 이유 |
|------|----------|
| **ADR-002 유지** (full feature 8~12개월) | 1인 burnout + 시장 검증 지연 리스크 큼 |
| 미니멀 MVP (음식 5개, Tier 1만, 친구 0명) | 다점포 메커닉 가치 검증 불가 (5가게는 음식 다양성 필요), Scene 3 정서 arc 무의미 |
| Tier 1~3 (친구 초대 포함) MVP | 친구 시스템 디자인이 burnout 트리거 — Tier 2까지로 더 보수 |
| 4~5주 미니 MVP (ADR-002 검토 시 거절됐던 v1.0 권장) | 다점포 메커닉이 충분히 들어가지 않음, 음식 너무 적음 |

### Follow-up Actions

#### 즉시 (이번 주)
- [ ] **pm**: MJ Standard Plan 결제 ($30/월) — 변경 없음
- [ ] **pm**: Suno Pro 결제 **보류** (사운드는 M2~M3에서 시작)
- [ ] **art-director**: 캐릭터 + 환경 anchor 각 5장 생성 (스타일 결정은 MVP scope와 무관, ADR-002 작업 그대로 진행)
- [ ] **game-designer**: **1순위 작업 변경** — `balance-config.md`가 아니라 **MVP 음식 12개 선정** 권고서

#### M0 (1개월) — 기획·디자인 finalize
- [ ] game-designer: MVP 음식 12개 확정 (인지도·재료 다양성·시각적 매력·난이도 분포 기준)
- [ ] game-designer: 친구 1~2명 personality + 호불호 (가족 단위 — 어머니/아버지 등)
- [ ] ui-designer: 다점포 screen-flow + Tier 1~2 UI flow
- [ ] art-director: anchor 2종 lock 게이트 통과
- [ ] pm: Tier 3~5 → post-launch 마이그레이션 로드맵 작성 (코드 hooks 사전 설계)

#### M1~M3 (2~3개월) — 본 production
- [ ] M1 art sprint **3~4주** (이전 3~4개월 → 큰 축소)
- [ ] M2 코드 구현 + sound 시작
- [ ] M3 QA + soft launch
- [ ] **dual-track**: launch 전 Tier 3 자산 40% pre-production (post-launch 콘텐츠 지속력 확보)

### 관련 문서
- [art-workload-estimate.md v3.0](art-workload-estimate.md) — 본 ADR 반영하여 ~80h 재계산
- [GDD.md §4 / §9 / §10](GDD.md) — Tier MVP/post-launch 분리, 3~4개월 + LiveOps 로드맵
- [systems/cooking-mechanics.md](systems/cooking-mechanics.md) — 5-tier 디자인 비전 유지, MVP scope callout 추가

### 결정 추적성 (Audit)

같은 날 ADR-002 → ADR-003 reversal은 **flip-flop이 아니라 검증된 의사결정 과정**임을 명시:
- ADR-002 채택 → 일정 8~12개월 본격 인식 → 1인 sprint 현실성 재평가 → ADR-003
- 두 ADR 모두 보존하여 추론 경로 추적 가능
- 향후 비슷한 scope 결정 시 본 케이스 reference

---

## ADR-004: 엔진 선택 — Godot 4.6 (GDScript only) 채택 (CLAUDE.md implicit Unity 정식 대체)

- **Status**: **Accepted**
- **Date**: 2026-05-23
- **Deciders**: 사용자 (pm role 위임)
- **Supersedes**: **엔진 선택 — CLAUDE.md implicit "Unity 2022 LTS" (ADR로 정식화된 적 없음)**. ADR-002 / ADR-003은 **supersede 하지 않음** — 본 ADR은 engine + language 선택만 lock한다 (외주 미사용 / AI 도구 / 마스코트 스타일 / MVP scope / 3~4개월 일정 모두 무변경).

### Context

`CLAUDE.md`에 "엔진: Unity 2022 LTS"가 명시되어 있으나 정식 ADR로 채택된 적 없는 implicit 선택이었다 (GDD.md §8·§12.3, agent-roster.md `unity-dev`, .claude/agents/unity-dev.md 등 다수 문서가 이에 implicit 의존). 사용자가 "Unity → Godot 교체"를 제안. 우려 3건(Stream A 광고 SDK / Asset Store / 코딩 컨벤션 재작성)을 사용자가 fact pack으로 반박, main thread가 핵심 fact를 검증.

**검증된 Fact 1 — AppLovin MAX 공식 Godot plugin**
- Repository: `AppLovin/AppLovin-MAX-Godot` (GitHub) — main thread 검증 완료, **v1.2.0 / 2025-04-24 릴리즈**
- Owner: AppLovin Inc. 본사 직접 유지보수 (월 단위 정기 업데이트)
- 공식 통합 가이드: developers.applovin.com/en/max/godot/
- Godot Asset Library 배포
- AdMob, Meta Audience Network 등 mediated networks 모두 지원
- Amazon Publisher Services 통합 가이드 제공
- 사용자 동의(UMP), 개인정보 API 지원
- Godot 4.x Android+iOS 지원 — main thread 검증
- **결론**: Stream A 수익 흔들림 없음. eCPM 하락 우려 무근거.

**검증된 Fact 2 — Asset Store 우려 overstated**
- Godot Asset Library는 코드/template 부족하나, K-Food는 어차피 자체 구현(다점포 메커닉 unique)이라 영향 미미.
- 시각 asset(PNG, audio, 폰트, 아이콘)은 engine-agnostic — Kenney, OpenGameArt, Itch, Flaticon, Freesound, Zapsplat 등 동일 사용 가능.
- ADR-002 #3 MJ + Suno 자체 제작이 art 전략이라 paid marketplace 의존 자체가 작음.
- art-workload-estimate.md v3.0 spot-check 결과 Unity-specific 의존 표현 없음 — **워크로드 ~80h 무변경 확인**.

**검증된 Fact 3 — 컨벤션 재작성 trivial**
- CLAUDE.md 5~10줄 수정(함수/변수 snake_case, 클래스/Node PascalCase, 파일명 snake_case.gd, 상수 UPPER_SNAKE_CASE)으로 충분.
- **GDScript only 사용 (C#/.NET 사용 안 함)** → .NET runtime mobile overhead 우려 0.

**Godot Foundation Mobile 인프라**
- Godot 4.6 / 4.5.2 mobile 개선 집중.
- Foundation 직접 유지보수 plugin: **Godot Google Play Billing** (IAP) / **Godot Google Play Games Services** / **Godot StoreKit 2** (iOS).
- **Godotx Firebase** (`godot-x/firebase`, MIT 라이선스): Core / Analytics / Crashlytics.
- Android instrumented tests (Firebase Test Lab) 통합 가능.

**선택 이유 요약**
1. AppLovin MAX 공식 Godot plugin 확인 → Stream A 무흔들림.
2. 1인 개발 — Godot의 가벼움(설치/빌드/iteration 속도) 우선.
3. GDScript iteration 속도 — Unity C# 컴파일 대비 hot-reload 친화.
4. FOSS — 라이선스/매출 게이트 부담 0.
5. Godot Foundation mobile 투자 + 공식 mobile plugin(IAP/GPGS/StoreKit) 셋이 자체 구현 부담 제거.

### Decision

1. **Engine = Godot 4.6 (또는 4.5.2 LTS 라인)**
2. **Language = GDScript only** (C#/.NET 미사용 — mobile runtime overhead 회피)
3. **Ads (Stream A) = AppLovin MAX 공식 Godot plugin** (`AppLovin/AppLovin-MAX-Godot`, v1.2.0+)
4. **IAP (Stream C) = Godot Foundation Google Play Billing plugin**
5. **Analytics / Crashlytics = Godotx Firebase** (`godot-x/firebase`, MIT)
6. **Games Services = Godot Google Play Games Services** (Foundation), iOS는 추후 StoreKit 2 plugin
7. **테스트 = Android instrumented tests (Firebase Test Lab) 통합**

> 본 결정은 **엔진/언어/모바일 SDK 스택만 lock**한다. ADR-002 (외주 미사용 / AI 도구 / 마스코트) · ADR-003 (MVP scope: 음식 12 / Tier 1~2 / 친구 1~2, 일정 3~4개월) 정합성 무변경.

> → **ADR-005에서 메커닉 깊이 확장 (3-stage → 4-stage rhythm tap)**. 콘텐츠 양·엔진·언어는 무변경, MVP scope 메커닉만 확장.

### ADR-002 / ADR-003 정합성

| ADR-002 결정 | 본 ADR 영향 |
|--------------|------------|
| #1 외주 미사용 | 무변경 |
| #2 Asset Store 적극 | **의미 재정의** — paid marketplace 의존 아니라 engine-agnostic 무료 asset 소스(Kenney/OpenGameArt/Itch/Freesound 등) + Godot Asset Library 무료 항목 |
| #3 AI 도구 (MJ/Suno/SD) | 무변경 (engine-agnostic) |
| #5 마스코트 스타일 | 무변경 |

| ADR-003 결정 | 본 ADR 영향 |
|--------------|------------|
| MVP scope (음식 12, Tier 1~2, 친구 1~2, 다점포 5가게, Scene 3 2종) | 무변경 |
| 3~4개월 일정 | 무변경 |
| Post-launch LiveOps 로드맵 | 무변경 |
| 광고/IAP 통합 범위 | SDK 표면만 Godot plugin으로 교체, 비즈니스 로직 무변경 |

### Consequences

**Positive**
- **가벼움**: Godot editor 설치/빌드/iteration 속도 Unity 대비 우월 — 1인 개발에 적합.
- **AppLovin MAX 공식 plugin 확보** → Stream A 무흔들림, eCPM 영향 0.
- **GDScript iteration 속도**: hot-reload 친화, C# 컴파일 대기 제거.
- **FOSS / 라이선스 부담 0**: Unity 매출 게이트·Runtime Fee 류 정책 리스크 회피.
- **Foundation 공식 mobile plugin**: IAP / GPGS / StoreKit 자체 구현 부담 제거.
- **컨벤션 재작성 비용 trivial** (30분, CLAUDE.md 5~10줄).
- **C#/.NET 미사용** → mobile binary 크기 / cold start / runtime overhead 우려 0.

**Negative**
- **생태계 자료 풍부도 차이**: Unity 대비 한국어 학습 자료 적음, 1인 학습 곡선 존재 (그러나 GDScript 단순성으로 완화).
- **paid asset marketplace 부재**: Unity Asset Store 류 통합 marketplace 없음 (engine-agnostic 무료 asset 소스로 대체, 영향 미미).
- **일부 mediation network plugin 부재 가능성**: Yodo1 / ironSource 등 일부 mediated SDK는 Godot 공식 plugin 우회 무 — AppLovin MAX 단일 mediation으로 충분 (GDD §5.2).
- **Unity 2022 LTS R10 리스크 회피 대가**: Godot 자체 LTS 라이프사이클(4.5.2 vs 4.6) 추적 필요 — 단, FOSS라 강제 마이그레이션 압력은 낮음.
- **`unity-project/` 폴더 및 다수 문서 라벨 갱신 필요** (Follow-up 처리).

### Alternatives Considered

| 대안 | 거절 이유 |
|------|----------|
| Unity 2022 LTS 유지 (현 implicit 선택) | Unity 매출 게이트·Runtime Fee 정책 리스크, 빌드/iteration 무거움 — 1인 개발 부담. R10 (2026년 말 LTS 종료) 마이그레이션 압력. |
| Unity → Godot full mono (C#) | mobile .NET runtime overhead·binary 크기·cold start 우려. GDScript only 대비 toolchain 복잡도 ↑. 사용자 제외 명시. |
| Godot 4 신규 prototype 병제 검증 | 1인 개발 듀얼 트랙 burnout 리스크. 핵심 fact(AppLovin 공식 plugin) 검증됐기에 prototype 게이트 불필요. |

### Follow-up Actions

#### 문서 갱신 (이번 turn 완료)
- [x] CLAUDE.md — 엔진/언어/네이밍/빌드/폴더구조/Claude 작업 가이드/Sub-Agent Team 갱신
- [x] docs/GDD.md §8 Tech Stack — Godot 4.6 + Godot Foundation plugin 셋 + Godotx Firebase 추가
- [x] docs/agent-roster.md — `unity-dev` → `godot-dev` 행 갱신, 위임 가이드 갱신
- [x] .claude/agents/godot-dev.md — 신설 (unity-dev.md 구조 동일 패턴)
- [x] docs/art-workload-estimate.md v3.0 — spot-check 완료 (영향 없음 확인, 본문 변경 없음, ~80h 무변경)
- [x] docs/decisions.md ADR-002 §Decision #2 옆 註 — Asset Store 의미 재정의

#### main thread 처리 영역 (이번 turn 미실시)
- [ ] **main thread (Bash)**: `.claude/agents/unity-dev.md` 삭제 — 경로: `C:\Projects\kfood-game\.claude\agents\unity-dev.md`
- [ ] **main thread**: `unity-project/` 폴더 → `godot-project/` rename (현재 폴더 내부 파일 거의 없음, OS 조작은 main thread 영역)
- [ ] **main thread**: `CHANGELOG.md` ADR-004 한 줄 추가 (pm 영역 아님)

#### 후속 sprint 이월
- [ ] **ui-designer**: `docs/ui-spec.md` / `docs/components.md` 등에 잔존하는 "Unity prefab" 표현 → Godot "Scene/Node(.tscn)"로 일괄 갱신 (이번 turn은 ui-designer 영역이므로 미수정).
- [ ] **game-designer**: `docs/balance-config.md` Remote Config 구현 전략은 **Firebase Remote Config로 통일 권고** (Godotx Firebase Remote Config 모듈 사용 가능성 검증 포함).
- [ ] **godot-dev**: Godot 4.x export 환경 셋업 (Android export template 설치, JDK/Android SDK toolchain, AAB 빌드 검증).
- [ ] **godot-dev**: Godotx Firebase plugin 의존 추가 + 초기 Analytics/Crashlytics 부트스트랩.
- [ ] **godot-dev**: AppLovin MAX Godot plugin Asset Library 설치 절차 검증 (Android API 24+ 요구사항 plugin v1.2.0 기준 재확인).
- [ ] **pm**: GDD.md §12.3 기술 의존성 표의 "Unity LTS 종료" 리스크(R10) 항목 다음 revisit 시 Godot 4.5.2 LTS / 4.6 라이프사이클로 갱신.
- [ ] **backend-dev**: Firebase Functions / Firestore 무변경 (engine-agnostic), 단 클라이언트 SDK 호출부는 Godotx Firebase 인터페이스 기준 재검토.

### 관련 문서
- [CLAUDE.md](../CLAUDE.md) — 엔진/언어/컨벤션/빌드/폴더구조 갱신
- [GDD.md §8 Tech Stack](GDD.md) — Godot 4.6 스택 반영
- [agent-roster.md](agent-roster.md) — `godot-dev` 행 반영
- [.claude/agents/godot-dev.md](../.claude/agents/godot-dev.md) — 신설
- [art-workload-estimate.md v3.0](art-workload-estimate.md) — spot-check 결과 영향 없음, 본문 무변경
- AppLovin MAX Godot plugin: `AppLovin/AppLovin-MAX-Godot` (v1.2.0 / 2025-04-24, main thread 검증)
- 공식 가이드: developers.applovin.com/en/max/godot/

---

## ADR-005: 메커닉 확장 — 3-stage → 4-stage (Stage 2A 재료 준비 신설, rhythm tap, Option C optional skill bonus)

- **Status**: **Accepted**
- **Date**: 2026-05-26
- **Deciders**: 사용자 (pm role 위임)
- **Supersedes**: 없음. **ADR-003 scope 확장** — MVP 메커닉 깊이 추가 (콘텐츠 양·엔진·MVP-first 정신 무변경, §ADR-003 정합성 검토에서 별도 reconciliation).
- **상위 트리거**: 사용자가 Stage 2 (조리 방법) 단일 카드 선택의 메커닉 빈약함을 재평가. 한식 cutting 기법(다지기/채썰기 등)이 게임 표현 기회로 미활용. rhythm tap 메커닉 + knife indicator visual cue로 깊이 추가 가능.

### Context

기존 GDD §2 + cooking-mechanics v0.4 §2~§3은 3-stage 곱셈 채점:
- Stage 1 재료 / Stage 2 조리 방법(단일 카드) / Stage 3 조리 시간(timing)
- `score = accuracy_ingredients × accuracy_method × accuracy_timing`

사용자가 다음을 제안:
1. **Stage 2 분할**: 2A 재료 준비 (cutting) / 2B 조리 방법 / 2C 조리 시간
2. 음식당 1~2개 "hero ingredient"만 prep (전부 prep은 부담)
3. **Knife indicator visual cue** — 칼이 자동 위아래 움직임, 도마 닿기 직전 = perfect tap (별도 rhythm UI 없이 게임 비주얼 통합)
4. **Cut Styles 6종** — 다지기 / 채썰기 / 어슷썰기 / 통썰기 / 송송썰기 / 깍둑썰기
5. **Per-Food BPM Design** — Tier 1 BPM 70~110 (3~6 taps), Tier 2 BPM 90~140 (5~8 taps)
6. **Total Score 가중 평균** — 재료 25% × 준비 20% × 방법 20% × 시간 35% (cooking-mechanics v0.4 §3 곱셈 모델 supersede)
7. **Skip 옵션** — Rewarded Video 시청 시 auto-perfect (Stream A 자연스러운 트리거)

### pm Cross-cutting 사전 검토 (ADR 채택 전)

- **ADR-003 MVP-first 정합성**: 콘텐츠 양 (음식 12 / Tier 1~2 / 친구 1~2 / Scene 2종) 무변경 — 메커닉 깊이만 추가. ADR-003 §"K-stylistic 차별점은 깎지 않음" 정신에 부합 (한식 cutting 표현). **단 scope creep 위험은 인정**.
- **사용자 "+1주" reality check**: pm 독립 평가는 **+2~3주**. 근거 = audio engine (BPM 메트로놈 / latency 처리) + UI (Knife indicator + 도마 화면) + art (칼 + 도마 1 set + cut style별 anim 3~4 frames × 6 + hero ingredient cut variation) + balance (4-factor 가중치 검증 + BPM/tap 음식별 매핑) + tutorial (FTUE 5-step → 6-step). 작업 표면이 5개 영역 cross-cutting.
- **Art-style reset 의존**: 사용자가 2026-05-24에 Cookie Run baseline 거부 + 새 reference 결정 보류 중. art-director 작업은 art-style lock 후로 격리해야 함 → R-A14 신설.
- **Sound deferral 충돌**: ADR-003 §즉시 액션에서 사운드 M2~M3 deferred. rhythm은 사운드 강의존 (BPM 메트로놈) — visual cue 우선 mitigation이 있지만 **최소 1~2주 sound 작업이 M2에 끼어들어야 함**. 전체 사운드(BGM/ambient) M2~M3 deferred 정책은 유지, BPM 메트로놈 + 칼질 SFX만 M2 minimum 추가.
- **Total score 공식 변경**: cooking-mechanics v0.4 §3 곱셈 모델 → 가중 평균으로 supersede. 한 stage 0이면 round 0 (곱셈) → 가중 평균으로 부드러움 (skip + miss 시 ★0 risk ↓). C-4 lock(45/45/10)과 정합 (가족 정서 부드러움).
- **Perfect window 수치 충돌**: 사용자 명시 ±100ms vs pm 80ms 권고 → ✅ **2026-05-26 ±80ms LOCKED** (사용자 confirm, pm 권고 채택). alpha에서 fail rate 검증 후 Remote Config로 ±100ms 완화 옵션.
- **Skip auto-perfect 점수**: 사용자 spec 1.0 (auto-perfect) vs pm 권고 0.9 (skill bonus 명분 유지) → ✅ **2026-05-26 0.9 LOCKED**. cut style anim art workload(+25~35h) 대비 engage ROI 확보.

### Decision

> 註 (2026-05-31): **[ADR-007](#adr-007-기본-양념-자동-제공--basic-pantry-sku-분리-stage-1-진열대-제외--kitchen-자동-rack) 양념 자동 제공으로 Stage 2A marinade rhythm 정합 명시** — 양념(간장/고추장/참기름/설탕/소금) 자동 제공된 상태에서 불고기 60 BPM 양념재우기는 마사지 rhythm으로 유지. ADR-005 4-stage 흐름 / Cut Styles 6종 / 가중 평균 공식 / Skip 옵션 등 본문 변경 없음.

**Option C — optional skill bonus rhythm tap 4-stage 채택**.

#### 4-stage 흐름 (Scene 변경 없음, Scene 2 내 sub-flow)

```
Scene 1 시장 (Stage 1 재료)
  ↓
Scene 2 키친
  ├── Stage 2A 재료 준비 (rhythm tap, 1~2 hero ingredient)
  │   - Skip 가능 (📺 Rewarded Video → auto-perfect)
  ├── Stage 2B 조리 방법 (단일 카드 선택)
  └── Stage 2C 조리 시간 (timing, 기존 Stage 3)
  ↓
Scene 3 식탁 (채점 + ★)
```

#### Cut Styles (6종 한식)
다지기 / 채썰기 / 어슷썰기 / 통썰기 / 송송썰기 / 깍둑썰기

#### Scoring 룰 (Stage 2A 재료 준비)
- **Perfect (±80ms)**: 100% — ✅ LOCKED 2026-05-26 (pm 권고 채택, 사용자 원안 ±100ms override)
- **Good (±200ms)**: 60%
- **Miss**: 0%
- 전체 평균 = prep 점수

#### Total Score Formula (cooking-mechanics §3 곱셈 supersede)
```
total = (재료 × 0.25) + (준비 × 0.20) + (방법 × 0.20) + (시간 × 0.35)
★1 ≥ 30%, ★2 ≥ 60%, ★3 ≥ 90%
```

#### Per-Food BPM Design (high-level — 정확 수치는 game-designer 후속)
- Tier 1: BPM 70~110, 3~6 taps
- Tier 2: BPM 90~140, 5~8 taps
- 다지기 = 가장 빠름 (140 BPM)
- 통썰기 = 가장 느림 (70 BPM)
- 양념 재우기 = 60 BPM (마사지 식)

#### Visual Cue (Knife Indicator)
- 칼이 자동 위아래 움직임
- 도마 닿기 직전 = perfect tap 타이밍
- **별도 rhythm UI 없이 게임 비주얼 통합** (게임 톤 일관성)

#### Mobile Latency Handling
- MVP: visual cue 우선, **perfect window ±80ms LOCKED** (Knife indicator visual cue로 mobile audio latency mitigate). 사용자 원안 ±100ms은 alpha에서 fail rate 검증 후 Remote Config로 완화 옵션.
- Post-launch: audio offset 사용자 calibration 옵션

#### Tutorial (FTUE Step 추가)
- Round 1: BPM 60, 2 taps, 시각 가이드 full
- Round 2~3: BPM 80, 점진적 가이드 제거
- Round 4+: 정상 BPM

### Consequences

**Positive**
- **메커닉 깊이 ↑**: 단순 timing → tap rhythm 추가, 깊이 있는 cooking matching 표현.
- **한식 cutting 기법 6종 시각 노출**: K-stylistic touch ↑ (다지기/채썰기 등 한식 고유 cutting 명명 + 비주얼).
- **Rewarded Video 자연스러운 트리거**: Skip 옵션 = Stream A CTR ↑ (사용자가 자발적으로 광고 선택).
- **Optional이라 캐주얼 유저 진입장벽 유지**: 어려우면 Skip → auto-perfect로 진행 가능.
- **가중 평균 공식**: 한 stage 0이어도 전체 round 0 아님 → 가족 정서 부드러움 (C-4 lock 정신 ↔ 정합).

**Negative**
- **일정 영향 +1주(사용자 추정) vs +2~3주(pm reality check)**:
  - 사용자 추정: +1주
  - pm 평가: **+2~3주** — 근거: audio engine(BPM 메트로놈 + latency calibration) + UI(Knife indicator + 도마 화면 + FTUE 확장) + art(칼/도마 1 set + cut style anim 3~4 frames × 6 cut style + hero ingredient cut variation) + balance(4-factor 가중치 검증 + BPM/tap 음식별 매핑) + tutorial 확장. 5개 영역 cross-cutting.
- **Art workload +20~25h (사용자) vs +25~35h (pm)**:
  - 6 cut style × 3~4 frames 애니메이션 + hero 재료 cut variation (raw + cut 2종) + 마스코트 simpler style 재작업 가능성 포함.
  - art-workload-estimate v3.1에서 placeholder lock.
- **Sound 의존성 ↑ — ADR-003 사운드 M2~M3 deferred 정책과 충돌**:
  - mitigation: MVP는 visual cue 우선, BPM 메트로놈 SFX + 칼질 SFX만 M2 minimum 1~2주 작업 추가 (BGM/ambient 전체 deferred는 유지).
- **Mobile audio latency 위험** (기기별 ±100ms 차이) — R-A13 신설. Knife indicator visual cue로 mitigate, post-launch calibration UI.
- **가중 평균 공식 = cooking-mechanics §3 곱셈 모델과 충돌** — 본 ADR로 곱셈 모델 supersede 명시. cooking-mechanics v0.5에서 본격 reconciliation.

### Alternatives Considered

| 대안 | 거절 이유 |
|------|----------|
| **Option A — 필수 rhythm (skip X)** | 캐주얼 진입장벽 ↑, FTUE 부담 ↑, fail rate 폭증 위험 |
| **Option B — rhythm 없음 (기존 3-stage 유지)** | 메커닉 깊이 부족, 한식 cutting 표현 기회 상실 |
| **Option C — optional skill bonus, skip 가능** | **채택** — 깊이 추가 + 진입장벽 유지의 균형 |
| **Option D — 별도 mini-game scene** | Scene 트랜지션 복잡도 ↑, MVP scope creep, 게임 흐름 단절 |

### ADR-003 정합성 검토

**MVP scope 위반 여부**: 음식 12 / Tier 1~2 / 친구 1~2 / Scene 2종 lock **무변경**. 메커닉 깊이 추가는 scope creep이지만 ADR-003 §"K-stylistic 차별점은 깎지 않음" 정신에 부합 (한식 cutting 표현).

**일정 영향**:
- ADR-003 일정: 3~4개월
- ADR-005 추가: **+1~3주** (사용자 1주 / pm 2~3주)
- 결과: **3~4개월 → 3.5~4.5개월** (ADR-003 일정 buffer 초과 가능성)
- **M0 reality check 게이트에서 재평가 권고** (ADR-003 §Follow-up 그대로 활용)

**Sound deferral 변경**:
- ADR-003: 사운드 M2~M3 전체 deferred
- ADR-005: **M2에 minimum 1~2주 sound 작업 추가** (BPM 메트로놈 + 칼질 SFX만)
- 전체 사운드 (BGM/ambient 등) M2~M3 deferred는 **유지**

**총 결론**: ADR-005는 ADR-003 supersede 아님 — scope 메커닉 깊이만 확장. ADR-003 follow-up 그대로 진행, ADR-005 follow-up은 병렬.

### 신규 Risk 등록

| # | 리스크 | 영향 | 가능성 | 완화안 |
|---|--------|------|-------|--------|
| **R-A13** | Mobile audio latency (기기별 ±100ms 차이) → rhythm tap 판정 왜곡 | 중 | 중 | visual cue 우선 (Knife indicator), perfect window 넓게(±80~100ms), post-launch calibration UI |
| **R-A14** | Art-style reset 의존 (현재 보류 상태) → cut animation 발주 BLOCKED | 중 | 고 | art-director 작업은 art-style lock 후 진입. 그 전까지 game-designer / ui-designer 사양 작업만 진행 |
| **R-A15** | Sound deferral 충돌 (ADR-003 M2~M3 → ADR-005 M2 minimum 1~2주 추가) | 중 | 중 | ADR-005 본문에서 minimum sound 작업 명시 + ADR-003 sound deferral 부분 amend. 전체 deferred는 유지 |
| **R-A16** | 일정 +1~3주 out-of-bound 위험 (3~4개월 → 3.5~4.5개월) | 고 | 중 | M0 reality check 게이트에서 ADR-003 일정 4개월 + 0.5 buffer 재평가. 초과 시 scope 추가 축소 검토 |

### Follow-up Actions (우선순위 순)

#### 1순위 — game-designer (즉시)
- [ ] `foods-database.csv` 갱신: **prep_ingredient / prep_cut_style / prep_bpm / prep_tap_count** 4 컬럼 추가 + 12음식 hero 재료 매핑
- [ ] `ingredients-database.csv` 갱신: **cut_variations** 컬럼 추가 (각 재료의 적용 가능 cut style 리스트)
- [ ] `balance-config.md` v0.2 → **v0.3**: 4-factor 가중치 lock (25/20/20/35), BPM/tap 범위 by tier, perfect/good window, Skip 시 auto-perfect 공식 (본 ADR에서 high-level만 추가 — 정확 수치는 game-designer 본격 sprint)
- [ ] `cooking-mechanics.md` v0.4 → **v0.5**: §2 4-stage Core Loop + §3 가중 평균 공식 supersede + §X 재료 준비 신설 (rhythm tap 룰 / Knife indicator / Perfect/Good/Miss 판정 / Skip 옵션 광고 트리거 / FTUE rhythm 흐름)

#### 2순위 — ui-designer (game-designer와 병렬 가능)
- [ ] `docs/ui/screen-flow.md` v0.2 → **v0.3**: Scene 2 sub-flow에 Stage 2A 재료 준비 (도마 + Knife indicator) 추가
- [ ] `docs/ui/components.md` v0.4 → 신규 컴포넌트 추가: **CP-18 KnifeIndicator** (자동 위아래 모션 + perfect zone), **CP-19 CuttingBoard** (도마 + hero 재료 배치)
- [ ] `docs/ui/ftue.md`: FTUE 5-step → **6-step** (Round 1 rhythm tutorial 추가)

#### 3순위 — art-director (**BLOCKED on art-style reset**)
- [ ] art-style lock 후 진입. 현재 reference 결정 보류 중이라 작업 시작 불가.
- [ ] 작업 항목 (lock 후): 칼/도마 art 1 set + cut style별 애니메이션 (3~4 frames × 6 cut style) + hero 재료 cut variation (raw + cut 2종)
- [ ] sound 겸직 결정 (본 ADR 결정 — 아래 참조)

#### 4순위 — godot-dev (M2 sprint 진입 시)
- [ ] Stage 2A rhythm tap 메커닉 구현 (audio offset / latency handling 포함)
- [ ] Knife indicator AnimationPlayer 구현
- [ ] Skip 버튼 → Rewarded Video 연결 (AppLovin MAX Godot plugin)
- [ ] 4-factor 가중 평균 채점 공식 구현 (balance-config v0.3 Remote Config 키 wire)

#### Sound-designer 신규 agent 신설 여부 (본 ADR 결정)

현 `agent-roster.md`에 sound-designer 없음. 본 ADR에서 결정:

- **결정: art-director가 sound 겸직 (sound-designer 신규 신설 X)**.
- 근거: 1인 sprint sound 작업량 1~2주 추정. 별도 agent 오버헤드 (정의 파일 + 위임 가이드 + tool 권한 설계 등) 불필요. art-director가 이미 ChatGPT/Suno 등 AI 도구를 다루는 전문가 (ADR-002 + ADR-006).
- agent-roster.md 한 줄 추가 + art-director 행 역할 한 줄에 "+ Phase 2 sound (BGM/SFX/rhythm) 겸직" 명시.

### 관련 문서
- [GDD.md §2 / §6.3 / §13](GDD.md) — 4-stage Core Loop sync + Risk 4건 추가
- [systems/cooking-mechanics.md v0.5](systems/cooking-mechanics.md) — §2 4-stage + §3 가중 평균 supersede + §X 재료 준비 placeholder
- [balance-config.md v0.3](balance-config.md) — §5~§8 신설 (4-factor weights / Prep Rhythm / BPM by Tier / Skip Bonus)
- [art-workload-estimate.md v3.1](art-workload-estimate.md) — +25~35h placeholder (art-style lock 후 정확 산정)
- [agent-roster.md](agent-roster.md) — sound-designer 신설 X, art-director 겸직 결정
- ADR-003 (MVP-first) — scope 정합성 검토 통과, 일정만 reality check 대상
- ADR-004 (Godot 4.6) — engine 무관, 영향 없음

---

## ADR-006: Art 생성 도구 pivot — Midjourney → ChatGPT (GPT-4o image / DALL-E 3)

- **Status**: **Accepted**
- **Date**: 2026-05-27
- **Deciders**: 사용자 (pm role 위임)
- **Supersedes**: [ADR-002](#adr-002-자체-제작--ai-도구--마스코트-스타일--full-feature-mvp) §Decision #3 **일부** (Midjourney → ChatGPT). Suno(BGM)·Stable Diffusion(보조) 부분은 무변경. ADR-003 §"ADR-002에서 유지되는 결정" #3 carryover도 본 ADR에 의해 부분 갱신.
- **상위 트리거**: 사용자 2026-05-23 MJ Standard $30/월 결제 → 5일 뒤(2026-05-27) ChatGPT pivot 결정. 사유 추정: ChatGPT 대화형 iteration 선호 + Discord UX 부담 + 이미 ChatGPT Plus 구독 예정(추가 비용 회피). art-style 결정 cycle에서 visual comparison test(`ai-comparison-test.md` v1.1)의 필요성도 강화.

### Context

ADR-002 #3은 art 생성 주력 도구로 Midjourney를 명시했고, ADR-003에서도 결정 #3로 carryover됐다. MJ Standard $30/월 결제(2026-05-23) 직후 사용자가 다음 5일간 사용성을 재평가:

- **대화형 iteration 선호**: ChatGPT 자연어 대화 기반 reroll/refine이 사용자 작업 흐름에 맞음. MJ Discord UX는 채널/슬래시 명령 부담.
- **비용 중복 회피**: 사용자 ChatGPT Plus $20/월 구매 예정 → MJ $30/월과 합치면 $50/월. ChatGPT 단일화 시 -$30/월.
- **reference image upload 강점**: ChatGPT는 사용자가 올린 reference 이미지를 그대로 style transfer 입력으로 사용 가능 → 마스코트 anchor lock 시 visual continuity 통제 용이.
- **art-comparison-test 형식 합치**: `docs/ai-comparison-test.md` v1.1이 이미 ChatGPT 형식으로 전환 완료.

### Decision

1. **Art 생성 도구 = ChatGPT (GPT-4o image / DALL-E 3)**.
2. **Plan = ChatGPT Plus $20/월** (DALL-E 무제한 + GPT-4o image 액세스).
3. **MJ Standard $30/월** = 다음 billing cycle 전 **취소** (main thread 실행).
4. **Suno (BGM)** = 무변경 (M2~M3 deferred 유지, ADR-003).
5. **Stable Diffusion (보조)** = 무변경 (현재 미사용 유지).
6. **워크플로 변경**: sref(style reference) 코드 기반 lock 메커니즘 부재 → **subject anchor 자연어 통일 + reference image upload + master prompt 템플릿** 3종으로 대체.

### Consequences

**Positive**
- **비용 -33%/월** ($30 → $20). MVP art 비용 추정 ~70% 절감 (MJ ~$60~90 vs ChatGPT ~$20~25, 4개월 MVP 기준).
- **대화형 iteration 속도 ↑** — Discord 슬래시 명령 → 자연어 reroll/refine.
- **reference image upload 정확도 ↑** — 마스코트 anchor lock 후 style transfer 일관성.
- **단일 구독으로 통합** — tool/billing 단순화.

**Negative**
- **sref 기반 캐릭터 일관성 lock 메커니즘 부재** → subject anchor 자연어 통일 + reference image upload로 대체 (workflow 부담 약간 ↑).
- **4-grid (MJ U/V) 손실** → 1 image fail 시 reroll 1~2회 trade-off.
- **한글 텍스트 깨짐 위험** (간판/가격표 등). placeholder 영문 → 후처리 한글 합성 권장.
- **워크로드 estimate 재산정 필요** (art-director 영역, 본 ADR scope 외).

### Alternatives Considered

| 대안 | 거절 이유 |
|------|----------|
| MJ Standard 유지 | 사용자 ChatGPT 선호 + 비용 중복 부담 |
| Stable Diffusion 자체 호스팅 | 1인 dev 환경 셋업 부담, ChatGPT 익숙도 ↑ |
| 양립 (MJ + ChatGPT 둘 다 사용) | tool fragmentation, 비용 중복 ($50/월), workflow 분산 |

### Follow-up Actions

#### art-director (병렬 진행 중)
- [x] `docs/ai-comparison-test.md` v1.1 — ChatGPT 형식 완료 (사전)
- [ ] 5종 art 문서 ChatGPT 영구 sync: `art-style-guide.md`, `prompts-library.md`, `ai-session-kit.md` (rename 후), `art-anchor-rubric.md`, `art-workload-estimate.md`

#### main thread
- [ ] MJ Standard 구독 취소 (다음 billing cycle 전)
- [ ] `CHANGELOG.md` ADR-006 한 줄 추가

#### pm (이번 turn 완료)
- [x] ADR-002 §Decision #3 옆 cross-ref 註 추가
- [x] ADR-003 §"ADR-002에서 유지되는 결정" #3 옆 cross-ref 註 추가
- [x] ADR-005 §Sound-designer 본문 MJ 참조 한 줄 sync
- [x] `.claude/agents/art-director.md` frontmatter + 본문 sync
- [x] `docs/agent-roster.md` art-director 행 sync
- [x] `docs/friends-system.md` MJ 참조 한 줄 sync
- [x] `CLAUDE.md` grep 점검 (MJ 명시 없음 확인, 변경 없음)

### 관련 문서
- [ADR-002 §Decision #3](#adr-002-자체-제작--ai-도구--마스코트-스타일--full-feature-mvp) — Midjourney 부분 supersede 대상
- [ADR-003 §"ADR-002에서 유지되는 결정"](#adr-003-mvp-first-전환--34개월-출시--점진-확대-supersedes-adr-002) — carryover 부분 갱신
- [ai-comparison-test.md v1.1](ai-comparison-test.md) — ChatGPT 형식 변환 완료
- art-director 5종 art 문서 (병렬 sync 중)

---

## ADR-007: 기본 양념 자동 제공 — Basic Pantry SKU 분리 (Stage 1 진열대 제외 + Kitchen 자동 rack)

- **Status**: **Accepted** (사용자 default 수용 2026-05-31)
- **Date**: 2026-05-31
- **Deciders**: 사용자 (pm role 위임)
- **Supersedes**: 없음. **[ADR-005](#adr-005-메커닉-확장--3-stage--4-stage-stage-2a-재료-준비-신설-rhythm-tap-option-c-optional-skill-bonus) scope amendment** — Stage 2A 양념재우기는 marinade rhythm으로 유지, ADR-005 본문 변경 없음 명시.
- **상위 트리거**: game-designer 보고(2026-05-30) "양념 제거 ripple 분석" — 사용자 verbatim 제안 "간장, 고추장, 참기름, 소금, 설탕과 같은 기본 양념은 구매하러 가지 않아도 되고 그냥 제공하는게 어때?"

### Context

- 사용자 verbatim: "간장, 고추장, 참기름, 소금, 설탕과 같은 기본 양념은 구매하러 가지 않아도 되고 그냥 제공하는게 어때?"
- 게임 cooking matching 부담 ↓ + UX 단순화 의도 (Stage 1 시간 단축, 양념 찾기 mini-game 제거).
- 잡화점 SKU 양념 비중 = **45% (13/29 정답)** — 양념 제거 시 잡화점 floor 12 → 10, 떡볶이/잡채 4 → 3가게 강등 (game-designer ripple 분석 인용).
- ADR-005 4-stage 흐름 중 Stage 2A 양념재우기(불고기 60 BPM CUT-00)는 marinade rhythm — 양념이 자동 제공된 상태에서 마사지 rhythm으로 정합 유지 가능.

### Decision

1. **`is_basic_pantry: bool` 컬럼 신설** (`docs/ingredients-database.csv`).
2. **기본 양념 5종** (간장 / 고추장 / 참기름 / 설탕 / 소금) = `is_basic_pantry = true`.
3. **Stage 1 잡화점 진열대에서 basic_pantry 재료 제외** (사용자 선택 X — 진열대 노출 자체 차단).
4. **`accuracy_ingredients` 공식 분모 N에서 basic_pantry 제외** (Stage 1 채점 영향 0).
5. **Scene 2 키친 진입 시 basic_pantry rack 자동 배치** (시각만, 사용자 인터랙션 X — 한식 정서 시각 강화).
6. **Stage 2A 양념재우기 (불고기 60 BPM CUT-00) marinade rhythm 유지** (양념 자동 제공된 상태에서 마사지 rhythm — ADR-005 정합).

### Consequences

**Positive**
- **사용자 부담 ↓** — 양념 찾기 mini-game 제거.
- **UX 단순화** — Stage 1 시간 단축.
- **Kitchen 양념 rack** — 한식 정서 시각 강화 (간장 / 고추장 항아리 등 visual presence).

**Negative**
- **잡화점 SKU 다양성 ↓** (29 정답 → 17, 12개 항목 감소).
- **떡볶이 · 잡채 4가게 → 3가게 강등** (다점포 다양성 minor ↓, store-distribution v1.3에서 반영).
- **Art 자산 변경** — 가게 양념 진열 art 제거 + kitchen 양념 rack art 신설 (art-director follow-up).
- **balance-config Remote Config 키 신설**:
  - `cooking.basic_pantry_ingredient_ids` (list of ingredient id)
  - `cooking.stage1.exclude_basic_pantry` (bool, default true)
  - `cooking.accuracy.exclude_basic_pantry` (bool, default true)

### Alternatives Considered

| 대안 | 거절 이유 |
|------|----------|
| **양념도 Stage 1에서 모두 선택** (현 default 유지) | UX 부담 + 양념 찾기 mini-game 가치 낮음 (한식 양념은 기본 가정) |
| **basic_pantry 양념 일부만 자동 제공** (예: 소금/설탕만) | scope 모호, Remote Config 복잡도 ↑, 사용자 verbatim 5종 명시 |
| **양념 카테고리 전체 자동 제공** (basic_pantry 외 양념도 포함) | 음식별 hero 양념(예: 고춧가루) 차별화 상실, scope creep |

### ADR-005 정합성

- ADR-005 §Decision 본문 (4-stage 흐름 / Cut Styles 6종 / 가중 평균 25/20/20/35 / Skip 옵션 / Knife indicator / BPM 설계) **무변경**.
- Stage 2A 양념재우기(불고기 60 BPM CUT-00 marinade rhythm)는 양념이 자동 제공된 상태에서 **마사지 rhythm**으로 유지 — ADR-007에 의해 정합.
- ADR-005 §Decision 헤더 옆에 cross-ref 한 줄 註 추가 (본 ADR과 동시).

### Follow-up Actions

#### 1순위 — game-designer (즉시)
- [ ] `docs/ingredients-database.csv` — `is_basic_pantry` 컬럼 신설, 간장 / 고추장 / 참기름 / 설탕 / 소금 = true.
- [ ] `docs/foods-database.csv` — 12음식 정답 재료 중 basic_pantry 5종 표기 분리 (accuracy_ingredients 분모 산정용).
- [ ] `docs/store-distribution.md` v1.3 — 잡화점 floor 12 → 10, 떡볶이 / 잡채 가게 수 4 → 3 강등 반영.
- [ ] `docs/balance-config.md` — Remote Config 키 신설:
  - `cooking.basic_pantry_ingredient_ids`
  - `cooking.stage1.exclude_basic_pantry` (default true)
  - `cooking.accuracy.exclude_basic_pantry` (default true)
- [ ] `docs/systems/cooking-mechanics.md` — Stage 1 §재료 선택에 basic_pantry 제외 룰 명시 + accuracy_ingredients 분모 공식 갱신.

#### 2순위 — ui-designer (game-designer 병렬)
- [ ] `docs/ui/screen-flow.md` — Scene 2 키친 진입 시 basic_pantry rack 자동 배치 (시각만, 인터랙션 X) 명시.
- [ ] `docs/ui/components.md` — **CP-20 BasicPantryRack** 신규 컴포넌트 (간장 / 고추장 / 참기름 / 설탕 / 소금 항아리 5종 visual presence).
- [ ] `docs/ui/ftue.md` — Stage 1 튜토리얼에서 basic_pantry 양념은 "이미 제공됨" 한 줄 안내 (사용자 선택 X 명시).

#### 3순위 — art-director (**BLOCKED on art-style reset 일부, ADR-005 R-A14 carryover**)
- [ ] 가게 양념 진열 art **제거** (잡화점 양념 SKU art 미사용 처리).
- [ ] **kitchen basic_pantry rack art 신설** (간장 항아리 / 고추장 항아리 / 참기름 병 / 설탕 통 / 소금 통 — 5종 visual set).
- [ ] art-workload-estimate v3.2 — 가게 art -X, kitchen rack +Y 산정.

#### 4순위 — godot-dev (M2 sprint 진입 시)
- [ ] `is_basic_pantry` 컬럼 Resource(.tres) 로드 + Stage 1 진열대 filter 구현.
- [ ] `accuracy_ingredients` 분모에서 basic_pantry 제외 공식 구현.
- [ ] Scene 2 키친 BasicPantryRack 자동 배치 (사용자 인터랙션 X — 시각만).
- [ ] Remote Config 3개 키 wire (`cooking.basic_pantry_ingredient_ids` / `cooking.stage1.exclude_basic_pantry` / `cooking.accuracy.exclude_basic_pantry`).

### 관련 문서
- [ADR-003 §MVP scope](#adr-003-mvp-first-전환--34개월-출시--점진-확대-supersedes-adr-002) — MVP 음식 12 / Tier 1~2 무변경
- [ADR-005 §Decision](#adr-005-메커닉-확장--3-stage--4-stage-stage-2a-재료-준비-신설-rhythm-tap-option-c-optional-skill-bonus) — Stage 2A marinade rhythm 정합 cross-ref
- [ingredients-database.csv](ingredients-database.csv) — `is_basic_pantry` 컬럼 신설 대상
- [foods-database.csv](foods-database.csv) — accuracy_ingredients 분모 산정용 basic_pantry 분리
- [store-distribution.md v1.3](store-distribution.md) — 떡볶이 / 잡채 3가게 강등 반영
- [balance-config.md](balance-config.md) — Remote Config 키 신설
- [systems/cooking-mechanics.md](systems/cooking-mechanics.md) — Stage 1 basic_pantry 제외 룰 명시
- game-designer 보고 (2026-05-30 양념 제거 ripple 분석)

---

## ADR-009: Guest System 2.0 — 12 flavor × 7 selectable guests × mood × friendship (supersedes Guest 1.0 + friends-system v0.3 axis 모델)

- **Status**: **Accepted**
- **Date**: 2026-06-04
- **Deciders**: 사용자 (pm role 위임), game-designer 작성
- **Supersedes**:
  - **Guest System 1.0** (현 codebase `data/guests.csv` v2.3 + `phase1/guest-select-ui.md` v1) — guest selection이 사실상 "Auto Select" dominant choice로 수렴, 전략적 결정이 아니었음.
  - **[`friends-system.md` v0.3](friends-system.md)** §3 Preference Axis 5종(spicy/sweet/salty/oily/mild) × {like, neutral, dislike} 매트릭스 모델 — `friends.like_bonus_pct=0.05` ±5% 가산 메커닉은 점수 영향 미미 + ★ 임계 불변 정책으로 게임플레이 가시성 부족.
- **상위 트리거**: 사용자 verbatim "Implement Guest System 2.0. Goal: Make guest selection a meaningful strategic decision."

### Context

현 시스템 한계:
1. **guests.csv v2.3**: vec 5-dim (rhythm_proto cooking match 용도) + line_enter/ok/bad만 보유. preference 시스템 없음, friendship 표시만 있고 누적 보상 없음.
2. **friends-system v0.3**: ±5% per axis 가산은 score_pre 합산이라 ★ 변동 거의 없고 (★ 임계 불변 정책), guest별 차별화가 미미 → "Auto Select" dominant.
3. **friend 모델 mismatch**: friends-system은 mother/father 가족 2명 L11 동시 unlock, guests.csv는 글로벌 친구 5명 자유 unlock — 두 source 모두 다른 모델로 운영.

→ guest selection을 **매일 변하는 mood + flavor 매칭 + friendship 누적 + 가시적 보상 multiplier**로 격상.

### Decision

#### 1. Data Model 확장

- **`data/menus.csv` + 1 컬럼**: `flavor_tags` (pipe-separated, 2~5 tag) — 12 음식 모두 매핑.
- **`data/guests.csv` + 5 컬럼**: `favorite_flavors`, `disliked_flavors`, `reward_bonus` (1.15~2.00), `friendship_level_initial` (default 0), `mood_pool` (3~5 mood pipe-separated).
- **`data/flavors.csv` 신설**: 12 flavor 카테고리 (spicy/sweet/salty/oily/mild/umami/sour/bitter/savory/fresh/hearty/fermented) — friends-system v0.3 axis 5종을 superset으로 포함.

#### 2. Compat 공식 (lock)

```
hit_fav = |food.flavor_tags ∩ guest.favorite_flavors|
hit_dis = |food.flavor_tags ∩ guest.disliked_flavors|
fav_score = hit_fav × 12 × mood_mult_fav[mood]
dis_score = hit_dis × 18 × mood_mult_dis[mood]
compat = clamp(50 + fav_score − dis_score, 0, 100)
```

#### 3. Mood Rotation (5 mood × daily seed)

- mood: `hungry / happy / easy / picky / grumpy` (multiplier matrix → balance-config §13.2)
- daily seed: `hash(today_iso + guest_id)` → deterministic per (date, guest)
- guest별 mood_pool 후보 list (3~5 entries, 중복 허용 = 가중치 효과)

#### 4. Compat → Reward Multiplier curve

- compat ≥ 90 → 1.30x / 70~89 → 1.15x / 50~69 → 1.00x / 30~49 → 0.85x / <30 → 0.70x
- `final_reward = base_reward × guest.reward_bonus × compat_multiplier(compat)`
- 점수 (★) 영향 X — 4-factor 그대로. **compat은 코인 보상에만 영향** (스킬 평가 vs guest fit 평가 분리).

#### 5. Friendship 0~10 + Milestone 3 / 7 / 10

- `delta = stars + (1 if compat ≥ 80 else 0)` per round
- Lv 3: ₩500 gift + special line_ok / Lv 7: compat +5% perm / Lv 10: reward_bonus +0.10x perm + portrait skin

#### 6. Guest Pool 통합 (friends-system mismatch 해결)

**selectable 7 + evaluator 3 = 10 guests 통합 풀**:

| 풀 | guest |
|----|------|
| selectable friends (5) | junho / mina / riley / mrs_lee / seoyeon |
| selectable **family** (2, friends-system 흡수) | **mother_01** / **father_01** (L11 동시 unlock 유지) |
| auto-pick evaluators (3) | mystery_diner / blogger_daniel / goldspoon (`MenuDB.selectable_guest_ids()` 제외 유지) |

- **friends-system v0.3 §3 axis 매트릭스 deprecated** (본 ADR이 supersede). mother/father personality (§2) + L11 unlock 결정 (§1) + reaction 표현 (§3.8)은 유지.
- 가족 별도 unlock track 안 거절 — 통합 풀이 mood × compat × friendship 시스템 일관성 ↑.

#### 7. UI 정책

- compat % 점수 **비표시** (default `guest.compat.show_score_in_ui = false`) — 전략적 모호함 유지, 플레이어가 mood + flavor tag 자연어 hint로 추정.
- mood badge 표시 ("Today: 😋 Hungry") + 1-line hint ("They'll love spicy today!").
- friendship 0~10 → ★ 5단계 (`floor(friendship / 2)` 매핑).

### Consequences

**Positive**
- **Guest selection 전략적 결정으로 격상**: compat 분포 30~95 range로 의미있게 분산. mood가 매일 바뀌어 같은 guest의 최적 음식이 변화.
- **friendship 누적 progression**: 7 guest × MAX = ~50 round LiveOps 콘텐츠. milestone 3 단계로 동기 다양화.
- **reward 가시성 ↑**: ±5% 미미한 가산 → 0.70x~1.30x compat × 1.15x~2.00x guest = 최대 **2.6x reward gap** (Junho 최악 ~₩4000 vs goldspoon 최고 ~₩39000 in same round). guest 선택이 보상에 직접 영향.
- **friends-system mismatch 해소**: 통합 풀 10 guests, single source of truth (data/guests.csv).
- **flavor 12종 superset**: friends-system v0.3 axis 5종 포함 → 마이그레이션 부담 최소 (axis 5종 → flavor_tags 변환만).
- **Schema 안정**: post-launch 친구 +3~5명 추가 시 row append만, 공식·키 변경 X.

**Negative**
- **SaveManager schema migration 필요** — `data.friendship: Dictionary` 신규 필드 (godot-dev follow-up, version 1 → 2). 기존 `data.intimacy` (float 0~5)와 분리 운영 또는 마이그레이션 (godot-dev 결정 spec).
- **UI 작업 ripple**: guest_select.gd 카드에 mood badge + flavor hint 추가 필요 (ui-designer follow-up).
- **balance-config Remote Config 키 +9** (guest.compat.* / guest.friendship.* / guest.mood.*) — Remote Config schema 부담.
- **CSV 컬럼 + 6 (menus +1 / guests +5)**: 콘텐츠 작업자 학습 곡선 (도큐 `guest-system-v2.md` v2.0으로 mitigate).
- **사용자 verbatim 92% 예시 reconciliation**: "김치찌개 + Mina(favorite=spicy/sour) = 92%" 예시는 illustrative. 실제 Mina persona는 sweet tooth (line_enter "I've got a serious sweet tooth!") → Mina favorite=sweet/savory/oily 설계. 92% 케이스는 Junho × 김치찌개 (happy mood)로 재해석 (compat 93% 검증). 사용자 verbatim의 의도 = "특정 조합이 high compat → high reward"는 정확히 충족.

### Alternatives Considered

| 대안 | 거절 이유 |
|------|----------|
| friends-system v0.3 ±5% 모델 유지 | guest selection이 의미있는 결정으로 격상 안 됨 (사용자 verbatim goal 미달) |
| compat 점수 UI 표시 (compat % 직접 노출) | 전략적 모호함 상실, RPG-식 min-max gaming 유도 → 캐주얼 톤 위배 |
| flavor 5 axis 그대로 (friends-system 호환만) | 12 음식 × 5 axis 표현력 부족, mood × flavor 조합 깊이 부족. 12 카테고리가 한식 변별에 적합 (fermented/umami/hearty 등 한식 시그니처 추가) |
| family 별도 unlock track | guest 시스템 통합성 손실, mood/compat 일관성 깨짐. 통합 풀 + unlock_level 다르게 운영하면 충분 |
| compat을 ★ 임계 영향까지 확장 | 스킬 평가 (★) vs guest fit (compat) 정합성 깨짐. friend를 잘 골랐다고 ★이 늘면 직관 위반 |
| mood 7+ (romantic / nostalgic 등 추가) | MVP scope creep. 5 mood로 mood × compat 분산 충분 검증. post-launch 시즌 한정 mood hook 보존 |

### ADR-003 / ADR-005 / ADR-007 정합성

- **ADR-003 MVP scope**: 음식 12 / Tier 1~2 / 친구 1~2 → 본 ADR로 **친구 풀 7 selectable (family 흡수)** 변경. ADR-003 §"친구 1~2" 명시는 family 단위 의미 (혼밥 → 가족 정서 arc). family 2 unlock은 L11 동시 그대로, friends 5는 이미 guests.csv에 있던 기존 풀 → MVP scope 실질적 추가 0. **scope 위반 없음**.
- **ADR-005 4-stage 메커닉**: 본 ADR은 점수 공식 (4-factor) 무변경. compat은 코인 보상에만 wire → 메커닉 충돌 0.
- **ADR-007 basic_pantry**: 본 ADR은 ingredient 시스템 무변경. flavor_tags는 food 모델 확장이라 ingredient 분리 정책과 직교.

### Follow-up Actions

#### 1순위 — game-designer (이번 sprint 완료)
- [x] `data/flavors.csv` 신설 (12 카테고리)
- [x] `data/guests.csv` 5 컬럼 확장 (favorite_flavors / disliked_flavors / reward_bonus / friendship_level_initial / mood_pool) + 7 selectable + 3 evaluator
- [x] `data/menus.csv` `flavor_tags` 컬럼 추가 + 12 음식 매핑
- [x] `docs/systems/guest-system-v2.md` v2.0 신설 (full spec)
- [x] `docs/balance-config.md` v0.4 → v0.5 (§13 Guest System 2.0 wire 신설 + friends.* 3 키 deprecated mark)
- [x] `docs/decisions.md` ADR-009 신설 (본 ADR)

#### 2순위 — pm (즉시)
- [ ] `docs/friends-system.md` v0.4 patch — §3 Preference Axis deprecated mark + 본 ADR cross-ref. §1 (L11 동시 unlock) + §2 (Mother/Father personality) + §3.8 reaction은 유지.
- [ ] `docs/phase1/guest-select-ui.md` v2 — mood badge + flavor hint 추가 spec (ui-designer 영역과 cross). family 2 카드 추가.

#### 3순위 — godot-dev (M2/M3 sprint)
- [ ] **SaveManager schema migration v1 → v2**:
  - `data["friendship"] = {}` 신규 (int 0~10 per guest_id). 기존 `data["intimacy"]` (float 0~5) — 마이그레이션 또는 dual 운영 결정.
  - `_default_data()` 갱신 + `_load()` 마이그레이션 로직 (`if data["version"] < 2: migrate_v1_to_v2()`).
- [ ] **`scripts/gameplay/guest_model.gd` 신설**: GuestDB.get_guest() 확장 — favorite_flavors / disliked_flavors / reward_bonus / mood_pool field load.
- [ ] **`scripts/gameplay/compatibility.gd` 신설**: `Compatibility.compute(food_id, guest_id) -> int` (0~100) + `Compatibility.reward_multiplier(compat) -> float` + `Compatibility.mood_of_the_day(guest_id) -> String`.
- [ ] **`scripts/gameplay/menu_db.gd` 확장**: `get_menu().flavor_tags` field load (pipe-separated parse).
- [ ] **`scripts/gameplay/round_result.gd` (또는 RoundSummary)**: round 종료 시 friendship_delta 계산 + SaveManager.add_friendship(guest_id, delta) + milestone 발동 체크 + UI toast 트리거.
- [ ] **`scripts/ui/guest_select.gd` 확장**: mood badge + flavor hint 자연어 1-line + friendship ★ 5단계 표시 + family 2 카드 (mother/father unlock_level=11 check).
- [ ] **Remote Config wire (선택, M3+)**: balance-config §13.6 9 키 → ConfigService에 노출.

#### 4순위 — ui-designer (godot-dev 병렬)
- [ ] guest card mood badge UI spec (icon + label "Today: hungry").
- [ ] flavor hint 자연어 generation 룰 ("They'll love spicy heat today!" / "Avoid oily today.").
- [ ] friendship milestone toast UI (Lv 3/7/10 도달 시).

#### 5순위 — qa-tester (M3 alpha)
- [ ] compat 공식 검증 (3 검증 케이스 + extreme cases — guest-system-v2.md §4 / balance-config §13.8).
- [ ] mood rotation determinism 검증 (같은 날 = 같은 mood, 다음 날 = 새 mood).
- [ ] friendship persist 검증 (save reload 후 누적 유지).
- [ ] guest selection 분포 KPI 검증 (Auto Select 비율 ≤ 40% target — 전략 결정 활성화 신호).

### 관련 문서
- [`systems/guest-system-v2.md` v2.0](systems/guest-system-v2.md) — full spec (본 ADR이 lock하는 핵심 spec)
- [`balance-config.md` v0.5 §13](balance-config.md) — Remote Config 키 + 공식 wire
- [`friends-system.md` v0.3](friends-system.md) — §3 axis 매트릭스 deprecated (본 ADR supersede). §1·§2·§3.8 유지
- [`phase1/guest-select-ui.md`](phase1/guest-select-ui.md) — v2 patch follow-up (ui-designer)
- [`data/flavors.csv`](../data/flavors.csv) — 12 flavor 카테고리 lock
- [`data/guests.csv`](../godot-project/data/guests.csv) — 5 신규 컬럼 적용
- [`data/menus.csv`](../godot-project/data/menus.csv) — flavor_tags 컬럼 적용
- ADR-003 (MVP-first) — 친구 풀 7 selectable로 변경 명시 (family 흡수, scope 위반 없음)
- ADR-005 (4-stage 메커닉) — 점수 공식 무변경, compat은 코인 wire 분리 정합


---

## ADR-010: Result Screen 2.0 — Rewarding + Explanatory display layer

- **Status**: ✅ **Accepted**
- **Date**: 2026-06-04
- **Deciders**: 사용자 (사양 명시) → game-designer (spec lock)
- **상위 트리거**: ADR-009 Guest System 2.0 후속. 라운드 보상감 ↑ + "왜 좋고 왜 나쁜지" 설명 부재 문제. 현 `result_screen.gd` 5라인 압축 → 정보량 빈약, progression sense 없음, compat/mood/friendship 누적 wire 없음.

### Context

ADR-009로 Guest System 2.0 (12 flavor × 7 guest × 5 mood × friendship 0~10)이 lock된 후 라운드 종료 화면은 다음 정보를 보여줘야 함:
1. **점수가 왜 그렇게 나왔는지** — prep / cook / season / plating 4 base + compat / mood / guest_bonus 3 modifier
2. **이 guest가 만족했는지** — 4 emotion level × persona 톤 reaction text
3. **이 음식이 얼마나 숙련됐는지** — Recipe XP (음식별 누적 leveling)
4. **새 기록인지** — (food, guest) pair best score 갱신
5. **friendship 누적 milestone에 도달했는지** — Lv 3 / 7 / 10 도달 시 즉시 reveal

현 ResultScreen은 (1) 일부만 ("Prep X Method Y Timing Z" 한 줄), (2)~(5) 전부 부재.

### Decision

**Result Screen 2.0을 pure display layer rewrite로 도입한다. Cooking mechanic은 손대지 않는다.**

핵심 결정:

1. **6 row breakdown** (4 base + 3 modifier) — prep_score / cook_score / seasoning_score / plating_score / compatibility_bonus / mood_bonus_or_penalty / reward_bonus. 각 row가 raw value + 시각 + 코인 기여를 표시.
2. **4-level emotion reaction** — excellent (compat ≥90 OR ★3+compat≥70) / good (compat 70~89 OR ★3) / okay (compat 50~69 OR ★2) / bad (compat <50 OR ★1). `level = max(level_from_compat, level_from_stars)`.
3. **44 reaction templates** — 8 selectable guests + 3 evaluators × 4 emotion levels. placeholder `{top_matched_flavor}` / `{top_disliked_flavor}` / `{missing_favorite}` 치환으로 음식·mood 변동 흡수. `data/reaction_templates.csv` 신설.
4. **Recipe XP system** — 음식별 누적 (Lv 1~10), `xp = 10 × stars + (compat/10) + (new_record ? +20 : 0)`. T1/T1-mid/T2 3종 curve. 9 단계 level up reward (signature line / perfect_window +5ms / signature dish glow / reward_bonus_perm +0.05 / Master title 등). `data/recipe_xp.csv` 신설.
5. **New Record** — storage key `(food_id, guest_id)` pair, value = score_final integer 0~100. 갱신 시 +₩500 one-time. 첫 라운드도 NEW RECORD (기준선).
6. **Milestone reveal styles** — Lv 3 toast (corner slide) / Lv 7 banner (center pool) / Lv 10 full-screen overlay (portrait reveal + confetti). milestone payout은 NEW RECORD bonus와 additive.
7. **mood_badge 재활용** — emotion 4 level을 기존 5 mood badge 중 4개 (happy/easy/picky/grumpy)로 매핑. **asset 0 추가**. art-director 후속 sprint에서 전용 4 reaction 일러스트로 교체 가능 (선택).
8. **SaveManager v2 schema 유지** — `records: Dictionary` + `recipe_xp: Dictionary` 2 dict만 추가. v3 bump 불필요 (`_merge()` backward compat 자동).
9. **점수 vs 보상 분리** (v0.5 §13.7 재확인) — ★ 임계 score는 4-factor cooking만 평가. compat / recipe_xp / new_record / milestone은 코인·XP 누적에만 wire.

### Alternatives Considered

| 대안 | 평가 |
|------|------|
| A. 4 row만 (4-factor cooking) — modifier 3 row 생략 | Reject. compat/mood/guest_bonus를 숨기면 "왜 이만큼 받았는지" 설명 불가 → Guest System 2.0 가치 0 |
| B. 12 음식 × 7 guest × 4 emotion = 336 templates lock (full triple) | Reject. 콘텐츠 부담 ↑, persona 일관성 ↓. placeholder 치환으로 (guest, emotion) 2-key 44 templates 충분 |
| C. Recipe XP를 음식 12개 통합 single XP로 단순화 | Reject. 음식별 progression sense 사라짐. 단순 통합 XP는 곧 player level과 redundant |
| D. NEW RECORD를 food_id only (guest 무관) | Reject. Guest System 2.0의 핵심 "이 손님을 위해 이 음식"이 (food, guest) pair best로 강화됨 |
| E. Milestone reveal을 별도 menu 진입 시 표시 | Reject. 즉각성 손실. Result Screen이 milestone "fireworks moment" 적기 |
| F. 전용 reaction 일러스트 4 level × 8 guest = 32 sprite 즉시 발주 | Reject (이 sprint). asset 0 추가 ship 우선, post-launch 개선 |

### Consequences

✅ **Positive**:
- 라운드 종료 보상감 ↑ — 4 row breakdown으로 "내가 어디 잘했고 어디 못했는지" 명확. compat/mood로 "이 guest가 좋아한 이유" 설명.
- Guest System 2.0 가치 노출 — compat/mood/friendship 누적이 모두 result에서 시각화.
- LiveOps long-tail — 12 음식 × Lv 10 × 7 guest = ~1400 round 깊이의 progression.
- 코드 변경 최소 — SaveManager 2 dict 추가 + RewardCalc 1 함수 + result_screen 1 rewrite + 신규 autoload 2개 (recipe_xp / reaction_db).
- asset 0 추가 (mood_badge 재활용) — ship 즉시 가능.

⚠️ **Negative**:
- 표시 정보 ↑ → screen real-estate 부담. 6 row를 mobile portrait에서 어떻게 배치? → ui-designer 후속 sprint 필요 (스크롤 vs 카드 vs 페이지 토글).
- emotion text 치환 결과가 어색할 가능성 (placeholder가 비어있는 edge case). fallback generic text 필요 — game-designer post-alpha 튜닝.
- 사용자 verbatim ("Mina loved the spicy kick") persona 불일치는 Junho 치환으로 회피했지만 사용자가 verbatim 100% 보존 요구 시 (food, guest, emotion) triple csv로 확장 필요 (336 row).

🔄 **Follow-ups**:
- ui-designer: Result Screen 2.0 mobile portrait 1080×1920 layout — 6 row + milestone overlay 어떻게 fold (스크롤 / 카드 / 페이지)
- godot-dev: SaveManager `records` + `recipe_xp` dict 추가, RecipeXP autoload 신규, ReactionDB autoload 신규, result_screen.gd v2 rewrite
- art-director (선택): emotion 4 levels × 8 guest 전용 일러스트 (mood_badge 대체 시)
- qa-tester: NEW RECORD 첫 라운드 처리 검증 / milestone reveal flow 검증 / recipe level up reward 동시 발생 검증

### Open Tasks

#### 1순위 — game-designer (본 sprint resolved)
- [x] 6 row breakdown 데이터 모델 lock (§14.1)
- [x] 4 emotion level rule + 44 templates (`data/reaction_templates.csv`)
- [x] Recipe XP curve 12 음식 × Lv 1~10 (`data/recipe_xp.csv`)
- [x] New Record logic + bonus (₩500 + first-record-counts)
- [x] Milestone reveal style lock (Lv 3 toast / Lv 7 banner / Lv 10 overlay)

#### 2순위 — godot-dev (다음 sprint)
- [ ] SaveManager: `records: Dictionary` + `recipe_xp: Dictionary` 2 dict 추가, `check_record(food_id, guest_id, score_int) -> bool` 신규
- [ ] RecipeXP autoload 신규 (CSV load + `add(food_id, xp) -> int level_up_count`)
- [ ] ReactionDB autoload 신규 (reaction_templates.csv load + `template(guest_id, level) -> Dictionary` + placeholder 치환 helper)
- [ ] RewardCalc 확장: `score_breakdown_rows(prep, cook, season, plating, compat, mood, guest_bonus) -> Array[Dictionary]`
- [ ] result_screen.gd v2 rewrite — 6 row + emotion 4-level + new record badge + milestone reveal
- [ ] rhythm_proto.gd `_on_round_end()` wire — recipe XP add + record check + result_screen.setup() 확장 dict

#### 3순위 — ui-designer
- [ ] Result Screen 2.0 mobile portrait 1080×1920 layout spec (6 row fold 전략, milestone reveal style 시각화)
- [ ] emotion 4-level mood_badge 매핑 visual confirmation
- [ ] milestone Lv 10 portrait skin overlay 디자인 spec

#### 4순위 — qa-tester (M3 alpha)
- [ ] NEW RECORD 첫 라운드 = true 처리 검증
- [ ] (food, guest) pair best 정합성 (다른 guest 라운드는 영향 X)
- [ ] milestone reveal + NEW RECORD + recipe level up 동시 발생 시 stack 검증 (3 reveal 순차?)
- [ ] reaction text placeholder edge case (fav_hit=0 OR dis_hit=0 OR missing=empty)
- [ ] mood_badge 재활용 표정이 reaction level 4종에 직관적인지 (excellent=happy, good=easy, okay=picky, bad=grumpy) UX 검증

### 관련 문서
- [`systems/result-screen-v2.md` v2.0](systems/result-screen-v2.md) — full spec (본 ADR이 lock하는 핵심 spec)
- [`balance-config.md` v0.6 §14](balance-config.md) — Remote Config 키 10종 + 공식·curve
- [`data/recipe_xp.csv`](../data/recipe_xp.csv) — Recipe XP curve 12 row × Lv 2~10
- [`data/reaction_templates.csv`](../data/reaction_templates.csv) — 44 reaction templates (8 + 3 × 4 emotion)
- ADR-009 (Guest System 2.0) — 본 ADR이 후속, compat/mood/friendship wire가 Result Screen에 노출
- ADR-005 (4-stage 메커닉) — 점수 공식 무변경, Result Screen은 display only


---

## ADR-011: 8-Module Cooking Pipeline — Slice/Arrange/Stir/Flip/Timing/Season/Roll/Plate

- **Status**: ✅ **Accepted**
- **Date**: 2026-06-04
- **Deciders**: 사용자 (사양 명시 verbatim) → game-designer (spec lock)
- **상위 트리거**: 사용자 verbatim:
  > "Define 8 reusable cooking modules: Slice / Arrange / Stir / Flip / Timing / Season / Roll / Plate. Every dish must be represented as a sequence of modules. Create a dish-to-module matrix. Goal: Players should feel they are cooking a specific Korean dish. Avoid creating unique minigames per dish. Reuse modules."

### Context

현 상태:
1. **ADR-005** (4-stage meta) = Stage 1 시장 / 2A 재료 준비 / 2B 조리 방법 / 2C 조리 시간 — **high-level meta-stage**. mechanic primitive 정의는 부재.
2. **rhythm_proto.gd 7-phase token** = chop / boil / season / stirfry / panfry / roll / knead — **현재 활성 구현**이나 음식 추가 시 token 비대화 위험. knead는 호떡 superseded 이후 미사용 dead code.
3. **음식 12개 × 음식별 unique flow 코딩 위험** — 만약 12 음식 = 12 unique minigame scene이면 code surface 폭증 (12 .tscn × 12 .gd) + 신규 음식 1개 추가마다 신규 mini-game 1세트 개발 부담.

→ **8 reusable module 풀로 12 음식 = 12 sequence 조합 표현**. 신규 음식 추가 = sequence row 1개 추가만 (코드 0건).

### Decision

#### 1. 8 Modules lock (no add, no remove)

| # | id | interaction | Korean feel anchor |
|:-:|----|-------------|---------------------|
| 1 | **slice** | rhythm tap (BPM-driven 칼+도마) | 6 cut style (다지기·채썰기·어슷·통·송송·깍둑) |
| 2 | **arrange** | drag/drop placement | 김밥 5색 / 비빔밥 6색 정렬 미학 |
| 3 | **stir** | tap rhythm (MVP) 또는 swipe circular | wok stir / bibim / toss |
| 4 | **flip** | single perfect-window tap | 해물파전·콘도그·갈비 양면 |
| 5 | **timing** | gauge fill + perfect window | 끓이기·볶기·굽기·튀기기 cook timing |
| 6 | **season** | 1-tap auto-pour (default) / marinade rhythm (sub) | basic_pantry + 양념재우기 (ADR-007 정합) |
| 7 | **roll** | swipe motion | 김밥 김발 |
| 8 | **plate** | drag/drop + garnish | 12 음식 시그니처 그릇·고명 |

신규 음식 추가 시 **이 8 module 풀에서만 sequence 조합**. 신규 module 0건.

#### 2. Dish-to-module matrix (12 음식 × sequence)

`docs/systems/cooking-modules-v1.md` §2 + `data/dish_modules.csv` 신설. 12 음식 모두 3~5 module sequence로 표현. 평균 4.4 module/음식. 시그니처 step 1~2개 식별 (§4.2).

#### 3. Korean identity preservation 4-layer

1. **Sequence permutation** — 같은 module도 순서가 다르면 다른 음식
2. **Signature step** — 음식별 1~2 hero module로 identity anchor
3. **Visual variation per module** — Slice 1 module = 8가지 한식 cutting 어휘 노출
4. **Plate signature** — 12 음식 = 12 그릇 art, terminal sealing

#### 4. ADR-005 / ADR-007 정합 (no supersede)

- **ADR-005** (4-stage meta): **무변경**. 8 module은 4-stage 안의 low-level primitive. Stage 2A 재료 준비 = Slice (또는 Season marinade variant). Stage 2C 조리 시간 = Timing.
- **ADR-007** (basic_pantry): **무변경**. Season module의 default interaction = "basic_pantry 1-tap auto-pour" (시각 ambience). Stage 1에서 양념 "고르기" X 정합 유지.
- **rhythm_proto.gd 7-phase**: 본 ADR로 **supersede**. migration map은 cooking-modules-v1.md §5에 lock. knead 제거 (호떡 N-1 superseded 이후 dead code). 8 module로 reorganize.

#### 5. Migration scope (godot-dev 후속 sprint spec)

- `rhythm_proto.gd` → `cooking_module_runner.gd` rename + module-based dispatch
- 8 module × 1 reusable .tscn scene = 8 module scene
- dish recipe data = sequence 정의 (.tres per food OR `data/dish_modules.csv` single source)
- **본 sprint = design only**. 코드 구현은 godot-dev 별도 sprint (Sprint M3 권고)

### Alternatives Considered

| 대안 | 평가 |
|------|------|
| A. 12 음식 = 12 unique minigame (per-dish scene) | **Reject** (사용자 verbatim 명시 회피). code surface 폭증, 신규 음식 추가 비용 ↑ |
| B. 4 module만 (Slice / Cook / Season / Plate — Cook이 Timing+Stir+Flip 통합) | Reject. Cook 통합은 mechanic 변별 약화 → Korean dish identity layer 부족 (라면 끓이기 vs 갈비 굽기 vs 콘도그 튀기기가 같은 module이 됨) |
| C. 12 module (Slice / Arrange / Stir / Flip / Timing / Season / Roll / Plate / Knead / Steam / Boil / Grill) | Reject. Knead는 미사용 (호떡 superseded). Boil/Grill은 Timing 변주로 충분. module 수 ↑ = reuse 분포 sparse |
| D. **8 module (Slice / Arrange / Stir / Flip / Timing / Season / Roll / Plate)** | **Accept** — 사용자 verbatim. reuse 분포 healthy (Plate 12 / Timing 11 / Slice 10) + Korean cutting 6종 노출 보존 + 김밥 Roll 정체성 유지 |
| E. 7 module (Plate 제거, Timing이 plate UI 흡수) | Reject. Plate는 음식별 그릇·garnish 시그니처 = dish identity sealing layer. 통합 시 정체성 약화 |

### Consequences

✅ **Positive**:
- **신규 음식 추가 비용 ↓** — sequence row 1줄 추가만 (코드 0건)
- **8 module polish가 12 음식 체감으로 multiply** — Plate 1주 polish = 12 음식 모두 향상
- **art workload predictable** — module별 art + 음식별 variation (Slice 6 cut style 기존 lock + Plate 12 그릇 신규)
- **Korean identity 4-layer로 "specific dish 느낌" 보존** — sequence + signature step + visual variation + Plate signature
- **현 7-phase 정리** — knead dead code 제거, panfry/stirfry → Flip+Timing / Stir+Timing 분리로 명료성 ↑

⚠️ **Negative**:
- **migration ripple** — rhythm_proto.gd refactor 필요 (Sprint M3 권고). 현재 활성 코드 (M2 sprint 진행 중)와의 충돌 관리 필요.
- **Plate art workload spike** — 12 그릇 + ~24 garnish art (art-director 후속 sprint, art-style lock 후)
- **Stir interaction MVP lock** — swipe circular vs tap rhythm 중 alpha 후 확정. MVP는 tap rhythm 권고 (latency 부담 ↓).
- **Flip post-launch deferred** — 해물파전 full flip은 MVP single tap fallback (C-3 lock 유지). post-launch Remote Config 활성화.

🔄 **Follow-ups**:
- game-designer (본 sprint): `cooking-modules-v1.md` 신설 + `data/dish_modules.csv` 신설 + `balance-config.md` v0.7 §15 신설 + ADR-011 신설
- godot-dev (Sprint M3 권고): rhythm_proto.gd → cooking_module_runner.gd refactor + 8 module scene + dish recipe data load
- ui-designer: 8 module별 FTUE 가이드 패턴 (특히 Arrange 첫 노출, Roll 첫 swipe, Slice rhythm tap 첫 onboarding)
- art-director (art-style lock 후): 8 module × Korean variation art workload 재산정 (Plate 12 그릇 + Slice 6 cut style + Roll 김발 anim 등)
- qa-tester (M3 alpha): module 재사용성 KPI (음식별 sequence flow 자연스러움 검증 + Korean dish identity 인지율 ≥ 75% target)

### Open Tasks

#### 1순위 — game-designer (본 sprint resolved)
- [x] 8 module spec (id / interaction / input / output / metric / Korean feel)
- [x] 12-dish module sequence matrix
- [x] Module reusability 분포 분석 (Plate 12 / Timing 11 / Slice 10 / Stir 5 / Season 5 / Arrange 4 / Flip 3 / Roll 1)
- [x] Korean identity preservation strategy (4-layer)
- [x] 7-phase → 8-module migration map

#### 2순위 — godot-dev (Sprint M3)
- [ ] rhythm_proto.gd → cooking_module_runner.gd refactor spec 작성
- [ ] 8 module별 reusable .tscn scene 설계
- [ ] dish recipe data load (.tres per food OR CSV-driven sequence parser)
- [ ] knead token 제거 + Arrange/Plate enum 신규 추가

#### 3순위 — ui-designer
- [ ] 8 module별 FTUE 가이드 spec (Arrange 첫 노출 / Roll swipe / Slice rhythm 등 신규 interaction 학습)
- [ ] Plate module UI — 그릇 선택 (1~3 후보) + garnish drag/drop 컴포넌트 spec (CP-21~ 신규)

#### 4순위 — art-director (art-style lock 후)
- [ ] Plate 음식별 그릇 12종 art (사발/접시/뚝배기/플레이트/도마 layout 등)
- [ ] Plate garnish 6~8종 (참깨/김가루/계란지단/쪽파/마늘/고춧가루)
- [ ] 8 module × Korean variation art workload v3.3 재산정

#### 5순위 — qa-tester (M3 alpha)
- [ ] Module 재사용성 검증 — 같은 module(Slice 등)이 음식별 다르게 느껴지는지 (visual variation 효과 검증)
- [ ] "Specific Korean dish 느낌" 인지율 측정 (qualitative survey + cooking flow 자연스러움 평가)
- [ ] Sequence 길이 분포 (3~5 step) 적정성 검증 (단조 회피 + 지겨움 회피 trade-off)

### 관련 문서
- [`systems/cooking-modules-v1.md` v1.0](systems/cooking-modules-v1.md) — full spec (본 ADR이 lock하는 핵심 spec)
- [`balance-config.md` v0.7 §15](balance-config.md) — module별 BPM/window/threshold lock + dish-to-module wire
- [`data/dish_modules.csv`](../data/dish_modules.csv) — 12 음식 × module sequence (본 sprint 신설)
- [`cooking-mechanics.md` v0.7](systems/cooking-mechanics.md) — Stage 룰 (4-stage meta 정합)
- [`motion-spec.md` v0.1](systems/motion-spec.md) — 음식 × 도구 × motion (module별 motion 참조)
- ADR-005 (4-stage 메커닉) — high-level meta-stage 무변경, 8 module은 low-level primitive
- ADR-007 (basic_pantry) — Season module default 정합
- ADR-008 — rhythm_proto.gd 7-phase token 본 ADR로 supersede (knead 제거)

---

## ADR-012: Action-First Cooking Interaction — 8 module input-layer 재설계

- **Status**: ✅ **Accepted**
- **Date**: 2026-06-05
- **Deciders**: 사용자 (사양 명시 verbatim) → game-designer (spec lock)
- **Type**: **[ADR-011](#adr-011) input-layer amendment** (supersede 아님 — 8 module 구성 / scoring / sequence / progression 무변경, input gesture만 재설계)
- **상위 트리거**: 사용자 verbatim:
  > "Do not design minigames. Design cooking actions. The player should perform a cooking action. The cooking action itself becomes the gameplay. Every cooking module should mimic a real cooking action. The mechanic should emerge from the cooking process itself. Never start with 'What button mechanic should we use?' Start with 'What is the real cooking action?' Then build gameplay around that action."

### Context

ADR-011은 8 reusable module로 12 음식 sequence를 표현하도록 lock했으나, 각 module의 interaction이 **추상 button/puck mechanic**으로 정의됨:

- slice = beat tap (자동 칼 위아래 + 도마 닿기 직전 tap)
- season = 1-tap auto-pour button
- roll = swipe/hold button
- timing = 정지 meter perfect-window tap
- stir = tap rhythm (좌/우 박자 tap)
- flip = single perfect-window tap

→ 사용자 평가: 이것은 **"button pressing"이지 "cooking"이 아니다**. 플레이어가 "ADD를 눌렀다"를 느끼지 "양념을 더했다"를 느끼지 못함.

**WRONG → CORRECT 원칙**:

| | WRONG (button) | CORRECT (action) |
|---|---|---|
| season | Tap Button | tilt seasoning bottle, control amount, particles fall |
| slice | Beat Tap | move knife through ingredient, pieces split |
| roll | Hold Button | roll bamboo mat forward, control pressure/timing |
| timing | Timing Bar (stop meter) | control stove heat, prevent overflow |
| plate | (이미 drag) | drag food onto plate, arrange presentation |

**Player feeling target**:
- "I added seasoning" NOT "I pressed ADD"
- "I rolled gimbap" NOT "I held a button"
- "I cut carrots" NOT "I tapped a beat"
- "I controlled the heat" NOT "I stopped a meter"

### Decision

#### 1. 8 module input gesture를 action-first로 재설계 (구성·scoring 무변경)

| module | before (ADR-011 button) | after (ADR-012 action) | gesture |
|--------|-------------------------|------------------------|---------|
| **slice** | rhythm tap | move knife through ingredient, pieces split | vertical drag |
| **arrange** | drag/drop snap | place ingredients into pattern (색·순서) | press-drag-release |
| **stir** | tap rhythm | continuous wok/bowl motion, churn | continuous circular swipe |
| **flip** | single tap | flip pancake / rotate corndog | directional flick |
| **timing** | stop a meter | control stove heat, prevent overflow | vertical drag (heat dial) |
| **season** | 1-tap auto-pour | tilt seasoning bottle, control amount | tilt + hold |
| **roll** | hold button | roll bamboo mat forward, release timing | forward drag + release |
| **plate** | drag/drop + garnish | (이미 action — 무변경) | drag + place |

#### 2. Score emerges from action (4-factor 무변경)

각 action의 결과 state(**under / perfect / over**)가 기존 output signal(`accuracy_prep` / `accuracy_arrange` / `accuracy_cook` / `flip_score` / `accuracy_timing` / `accuracy_season` / `accuracy_roll` / `plate_bonus`)으로 **결정론적 매핑**. 입력→점수 **변환 함수만** 재정의. 4-factor 가중치(25/20/20/35) / ★ 임계(30/60/90) / `module_completed(score)` signal contract 전부 무변경. 상세 매핑 표 = [`action-first-cooking-v1.md` §6](systems/action-first-cooking-v1.md).

#### 3. Korean technique = action identity

- **slice**: cut style 6종이 서로 다른 drag 동작 (다지기 짧고 빠른 반복 drag / 채썰기 길고 균일 drag / 어슷썰기 대각 drag).
- **season**: 양념 종류별 다른 tilt (고춧가루 톡톡 / 간장 긴 줄기 / 참기름 drizzle / 양념재우기 tilt-massage).
- **음식별 hero action**이 조리 정체성 전달 (김밥=roll forward drag / 갈비=좁은 heat zone / 불고기=marinade tilt-massage).

#### 4. ADR-011 / ADR-005 / ADR-007 정합 (no supersede)

- **ADR-011**: 8 module 구성 / dish_modules.csv sequence / reuse 분포 / scoring **무변경**. interaction 컬럼만 amend.
- **ADR-005**: 4-stage meta **무변경**. Knife indicator(자동 칼 tap) input만 deprecated → 손가락 drag. 가중 평균 공식 / Skip auto-perfect 무변경.
- **ADR-007**: basic_pantry **무변경**. Season default = 가벼운 tilt(auto-pour 대체, 시각 only). 양념 "고르기" 행위 X 유지.

#### 5. deprecated (input gesture only, mechanic deprecation 아님)

- ADR-005 Knife indicator (자동 위아래 + tap) → slice vertical drag
- ADR-011 stir "tap rhythm" → continuous swipe (Remote Config `stir_interaction_mode = "continuous_swipe"`)
- ADR-011 flip "single window tap" → directional flick
- ADR-011 timing "정지 meter perfect tap" → heat dial 지속 조절

> 이 4개는 output signal·scoring·점수 분포 전부 동일. input gesture만 교체.

### Alternatives Considered

| 대안 | 평가 |
|------|------|
| A. ADR-011 button mechanic 유지 | **Reject** (사용자 verbatim 명시 회피). "button pressing"이지 "cooking" 아님 |
| B. 음식별 unique action minigame 신설 | Reject. 사용자 verbatim "Do not design minigames". ADR-011 8-module reuse 원칙 위배 |
| C. **8 module input-layer만 action으로 재설계 (scoring/sequence/progression 무변경)** | **Accept** — 사용자 원칙 정확 충족 + ADR-011 framework 보존 + scoring 안정성 유지 |
| D. scoring도 action 기반으로 재설계 (4-factor 폐기) | Reject. progression/economy/recipe XP ripple 폭증. 입력만 바꿔도 "cooking 느낌" 충족 |

### Consequences

✅ **Positive**:
- **"cooking 느낌" 달성** — 모든 module이 실제 한식 조리 동작 모방. "I cut / I seasoned / I rolled / I controlled heat".
- **scoring 안정성** — 4-factor / ★ 임계 / signal contract 무변경 → progression/economy/balance 전부 ripple 0.
- **sequence 무변경** — dish_modules.csv 12 음식 sequence 동일. 코드 0건 추가.
- **Korean identity 강화** — cut style이 손가락 동작으로 학습됨 (다지기 vs 채썰기 = 다른 drag).
- **구현 난이도 관리 가능** — easy 3 / medium 5 / hard 0. 물리 엔진 불필요, Transform anim + drag sampling 수준.

⚠️ **Negative**:
- **input 인프라 신설** — TouchGestureRecognizer 공통 유틸 (drag path / tilt / flick velocity / 각속도). godot-dev Sprint M3.
- **mobile latency/정밀도** — continuous swipe 각속도 sampling, flick velocity threshold가 기기별 편차. alpha 검증 필요.
- **FTUE 재설계** — gesture 학습(drag-cut / tilt / heat dial)이 tap보다 onboarding step 부담 ↑. ui-designer.
- **art-director 영향** — slice sprite split anim 방식 (shader mask vs 2-piece), heat dial UI. art-style lock 후.

🔄 **Follow-ups**:
- game-designer (본 sprint): `action-first-cooking-v1.md` 신설 + `cooking-modules-v1.md` v1.1 cross-ref + balance-config `stir_interaction_mode` 갱신 + ADR-012 신설
- godot-dev (Sprint M3): TouchGestureRecognizer 공통 유틸 + 8 module action input 구현 (우선순위 slice → timing → plate → stir → season → arrange → flip → roll)
- ui-designer: gesture FTUE 재설계 (drag-cut / tilt / heat dial / flick / forward-roll 학습) + heat dial UI 컴포넌트 + arrange vs plate 혼동 방지
- art-director (art-style lock 후): slice split anim 방식 + heat dial/불꽃 시각 + season 입자 emit
- qa-tester (M3 alpha): action 체감 인지율 ("cooking 느낌" survey) + gesture 정밀도/latency 검증 + flick velocity 기기별 band

### Open Tasks

#### 1순위 — game-designer (본 sprint resolved)
- [x] 8 module action-first 설계 (real action / input gesture / visual sim / 3 states / score emergence / Korean technique)
- [x] 신규 설계 3개 (arrange place-into-pattern / stir continuous swipe / flip directional flick)
- [x] score 매핑 (action 결과 → output signal, 4-factor 무변경 audit)
- [x] button → action 전환표 + 구현 난이도 estimate
- [x] godot-dev 구현 우선순위 권고 (slice 1순위 — 10/12 음식)

#### 2순위 — godot-dev (Sprint M3)
- [ ] TouchGestureRecognizer 공통 유틸 (drag path / tilt 각도 / flick velocity / continuous swipe 각속도)
- [ ] slice drag-cut (sprite split anim + cut 위치/속도/개수 scoring)
- [ ] timing heat dial (zone 유지율 + overflow 게이지)
- [ ] stir continuous swipe (각속도 적분 → 회전 수)
- [ ] flip directional flick (velocity vector + C-3 fallback)
- [ ] season tilt + roll forward drag + arrange place
- [ ] Remote Config `stir_interaction_mode` default "continuous_swipe" 갱신

#### 3순위 — ui-designer
- [ ] gesture FTUE 재설계 (6-step → action 학습)
- [ ] heat dial UI 컴포넌트 (다이얼/노브 + overflow 게이지)
- [ ] arrange(raw 재료) vs plate(완성 음식) 혼동 방지 cue

#### 4순위 — art-director (art-style lock 후)
- [ ] slice sprite split anim (shader mask vs 2-piece)
- [ ] heat dial 불꽃/끓음 강도 시각 + overflow
- [ ] season 양념 입자 emit (가루/액체/drizzle)

#### 5순위 — qa-tester (M3 alpha)
- [ ] "cooking 느낌" 인지율 (button vs action 체감 차이 survey)
- [ ] gesture 정밀도/latency 기기별 검증
- [ ] flick velocity threshold 음식별 band 적정성

### 관련 문서
- [`systems/action-first-cooking-v1.md` v1.0](systems/action-first-cooking-v1.md) — full spec (본 ADR이 lock하는 핵심 spec)
- [`systems/cooking-modules-v1.md` v1.1](systems/cooking-modules-v1.md) — 8 module 구성 (interaction action-first cross-ref)
- [`balance-config.md` v0.7 §15](balance-config.md) — module BPM/window/threshold (stir_interaction_mode 갱신)
- [`cooking-mechanics.md` v0.7](systems/cooking-mechanics.md) — 4-stage 룰 (scoring 무변경)
- [`data/dish_modules.csv`](../data/dish_modules.csv) — 12 음식 × sequence (무변경)
- ADR-011 (8-module) — 본 ADR이 input-layer amend (구성/scoring/sequence 무변경)
- ADR-005 (4-stage) — Knife indicator input만 deprecated, meta 무변경
- ADR-007 (basic_pantry) — Season default 정합


