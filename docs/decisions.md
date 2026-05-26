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
