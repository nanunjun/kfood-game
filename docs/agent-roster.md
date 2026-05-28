# Agent Roster — K-Food Master

> K-Food Master 프로젝트의 sub-agent 팀 구성표.
> 각 agent 정의 파일: [`../.claude/agents/`](../.claude/agents/)
> Claude는 작업 성격에 따라 아래 표를 참고하여 적절한 agent에 위임한다.

## Phase 1 — MVP 코어 팀

| Agent | 정의 파일 | 주요 책임 | 산출물 위치 | 코드 작성 |
|-------|----------|----------|------------|----------|
| **pm** | `.claude/agents/pm.md` | 제품 의사결정, GDD/로드맵/ADR 유지, feature spec 작성 후 위임 | `docs/GDD.md`, `docs/roadmap.md`, `docs/decisions.md`, `docs/specs/feature-*.md`, `CHANGELOG.md` | ❌ |
| **game-designer** | `.claude/agents/game-designer.md` | 메커닉/밸런스/콘텐츠 설계 (3단계 점수 + 5-tier) | `docs/systems/cooking-mechanics.md`, `docs/balance-config.md`, `docs/foods-database.csv`, `docs/ingredients-database.csv` | ❌ |
| **godot-dev** | `.claude/agents/godot-dev.md` | Godot 4.x GDScript 구현, SDK 통합 (AppLovin MAX Godot plugin, Godot Foundation Google Play Billing, Godotx Firebase) | `godot-project/scripts/**` | ✅ (단 `.tscn` 씬 / `.tres` 리소스 편집은 Godot Editor 우선) |
| **backend-dev** | `.claude/agents/backend-dev.md` | Firebase Functions(TS) + Firestore, API 계약 관리 | `functions/**`, `docs/api-contracts.md` | ✅ |
| **ui-designer** | `.claude/agents/ui-designer.md` | 화면/플로우/인터랙션 설계 (one-thumb, 5-second rule, portrait) | `docs/ui-spec.md`, `docs/screen-flow.md` | ❌ |
| **qa-tester** | `.claude/agents/qa-tester.md` | 테스트 케이스 작성, 버그 리포트(severity), 자동화 실행 | `tests/**`, `docs/test-plan.md`, `docs/test-cases/**` | 테스트만 ✅ / 버그 수정 ❌ |

## Phase 2 — Post-MVP / Launch 준비

| Agent | 정의 파일 | 주요 책임 | 산출물 위치 |
|-------|----------|----------|------------|
| **art-director** | `.claude/agents/art-director.md` | 아트 스타일, **ChatGPT (GPT-4o image / DALL-E 3) 프롬프트** ([ADR-006](decisions.md#adr-006-art-생성-도구-pivot--midjourney--chatgpt-gpt-4o-image--dall-e-3) 2026-05-27 pivot, 이전 Midjourney deprecated), 에셋 관리 **+ Phase 2 sound (BGM/SFX/rhythm) 겸직 (ADR-005 결정)** | `docs/art-style-guide.md`, `docs/prompts-library.md`, `docs/ai-session-kit.md`, `docs/art-anchor-rubric.md`, `docs/art-workload-estimate.md`, `docs/sound-guide.md` (신설 예정), `assets-raw/`, `assets-processed/` |
| **marketing** | `.claude/agents/marketing.md` | ASO 키워드, 스토어 리스팅, 마케팅 카피 | `docs/aso-keywords.md`, `docs/store-listing-copy.md`, `marketing/` |
| **data-analyst** | `.claude/agents/data-analyst.md` | KPI, A/B 테스트 설계, 분석 이벤트 정의 | `docs/kpi-dashboard.md`, `docs/analytics-events.md`, `docs/ab-test-plans.md` |

> **sound-designer agent 신설 X** ([ADR-005](decisions.md#adr-005) 2026-05-26 결정). 1인 sprint sound 작업량 1~2주 추정 + 별도 agent 오버헤드 불필요 → **art-director가 Phase 2 sound 겸직**. ADR-005에 따라 M2 minimum 1~2주 sound 작업 (BPM 메트로놈 + 칼질 SFX) 진입 시 art-director에 위임.

## 위임 가이드 (Claude → sub-agent)

| 사용자 요청 유형 | 1차 위임 대상 | 비고 |
|-----------------|--------------|------|
| "X 기능 추가하자" | **pm** → spec 작성 → godot-dev/backend-dev | pm이 spec 만들고 적절한 dev에 위임 |
| "밸런스 조정 / 새 음식 추가" | **game-designer** | 밸런스 표/DB만 수정, 코드 X |
| "이 화면 어떻게 만들지" | **ui-designer** | 스펙만 작성 → 이후 godot-dev에 인계 |
| "이 스크립트 작성/수정" | **godot-dev** | `godot-project/scripts/` 한정, `.tscn`/`.tres` Editor 편집 우선 |
| "Cloud Function / API 설계" | **backend-dev** | 시크릿(affiliate ID 등) 클라이언트 노출 절대 X |
| "릴리스 전 / feature 끝나고 테스트" | **qa-tester** | severity 명시, 직접 fix X (찾으면 pm에게 보고) |
| "아트 / 프롬프트 / 아이콘" | **art-director** (Phase 2) | MVP 단계는 placeholder |
| "스토어 메타데이터 / 광고 카피" | **marketing** (Phase 2) | |
| "이벤트 정의 / KPI / A/B" | **data-analyst** (Phase 2) | |

## 운영 원칙

- **Single Source of Truth**: 각 agent가 "owner"인 문서는 다른 agent가 직접 편집하지 않음 (변경 필요 시 owner에게 요청).
- **Phase 분리**: Phase 2 agent는 MVP 출시 전까지 호출 최소화. 단, art placeholder나 ASO 키워드 사전 리서치는 예외.
- **코드 작성 권한**: godot-dev / backend-dev / qa-tester(테스트) 만 보유. 나머지는 문서/스펙만.
- **CHANGELOG**: 모든 의미 있는 작업은 pm 또는 작업 주체가 `CHANGELOG.md`에 한 줄 추가.
