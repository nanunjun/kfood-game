# K-Food Master

## 프로젝트 개요
- **프로젝트명**: K-Food Master
- **컨셉**: 한식(떡볶이, 김밥, 김치, 비빔밥 등)을 **재료 선택 + 조리 방법 + 조리 시간** 3단계로 완성하는 cooking matching 캐주얼 모바일 게임
- **장르**: Casual / Cooking Matching (타이밍 게임 포함)
- **타겟 플랫폼**: Android (iOS는 추후 검토)
- **엔진**: **Godot 4.6 (또는 4.5.2 LTS 라인), GDScript only** — [ADR-004](docs/decisions.md#adr-004) 참조 (C#/.NET 미사용)

## 수익 모델
- **광고**: AppLovin MAX Mediation — **AppLovin MAX 공식 Godot plugin** (`AppLovin/AppLovin-MAX-Godot`)
  - Rewarded Video (보상형)
  - Interstitial (전면)
  - Banner (배너)
- **IAP (In-App Purchase)** — Godot Foundation **Google Play Billing plugin**
  - Remove Ads: $2.99 (배너/전면 제거, 보상형은 유지)

## 코딩 컨벤션
- **언어**: **GDScript (Godot 4.x). C#/.NET 미사용.**
- **네이밍**:
  - 클래스 / Node: `PascalCase`
  - 함수 / 변수: `snake_case`
  - private 멤버: 선행 underscore `_snake_case` (Godot 관례)
  - 상수: `UPPER_SNAKE_CASE`
  - 파일명: `snake_case.gd` (스크립트), `snake_case.tscn` (씬), `snake_case.tres` (리소스)
  - 시그널: `snake_case`
- **변수명**: 영어 사용 (`player_score`, `tteokbokki_level` 등 — snake_case로 작성)
- **주석**: 한국어 허용 (특히 게임 디자인 의도, 한식 메커닉 설명)
- **파일 인코딩**: UTF-8 (BOM 없음)
- **줄바꿈**: LF 권장 (`.gitattributes`로 통제)

## 빌드
- **방식**: Godot Export (Android export template 사용)
- **출력 경로**: `build/` 폴더 (git ignore)
- **포맷**: AAB (Android App Bundle) — Google Play 업로드용
- **번들 ID 예시**: `com.{studio}.kfoodmaster` (확정 시 갱신)
- **최소 SDK**: Android 7.0 (API 24) 권장 — **AppLovin MAX Godot plugin v1.2.0 요구사항 재확인 follow-up** (godot-dev)

## 폴더 구조
```
kfood-game/
├── CLAUDE.md              ← 이 파일 (프로젝트 헌법)
├── CHANGELOG.md           ← 작업 로그 / working memory
├── .gitignore
├── docs/                  ← 기획 문서, GDD, 시스템 설계, ADR
├── godot-project/         ← Godot 4.x 프로젝트 루트 (project.godot, scenes/, scripts/, resources/...)
├── assets-raw/            ← 원본 에셋 (PSD, 고해상도 일러스트, 음원 원본)
├── assets-processed/      ← Godot 임포트용 가공 에셋 (PNG, OGG, 스프라이트 시트)
├── marketing/             ← 스토어 메타데이터, 스크린샷, ASO, 광고 소재
├── research/              ← 경쟁작 분석, 시장 조사, 유저 리서치
└── build/                 ← AAB/APK 빌드 산출물 (git ignore)
```

> 참고: 기존 `unity-project/` 폴더는 ADR-004에 따라 `godot-project/`로 rename 예정 (실 파일/폴더 OS 조작은 main thread 영역).

## Claude 작업 가이드
- 새 기능/시스템 작업 시작 시 `CHANGELOG.md`에 항목 추가
- Godot 스크립트는 `godot-project/scripts/` 하위에 도메인별 폴더로 분리
  (`gameplay/`, `ui/`, `ads/`, `iap/`, `save/`, `analytics/` 등)
- 한식 아이템 데이터는 **Godot `Resource` (`.tres`)** 기반으로 관리 (디자이너 친화적 — Unity ScriptableObject 대응)
- AppLovin MAX (공식 Godot plugin) / Godot Foundation Google Play Billing / Godotx Firebase (`godot-x/firebase`) 등 SDK 작업 시 **공식 plugin 명시** + 버전 lock 확인 후 진행
- 빌드 산출물(`build/`)은 절대 커밋하지 않음
- `.tscn` (씬) / `.tres` (리소스) 바이너리/텍스트 편집은 가급적 Godot Editor에서 처리 — 텍스트 diff가 가능하더라도 godot-dev는 스크립트 위주 편집을 우선

## Sub-Agent Team
프로젝트는 **9개 sub-agent**로 책임을 분리한다. 정의: [`.claude/agents/`](.claude/agents/), 요약표: [`docs/agent-roster.md`](docs/agent-roster.md).

| Phase | Agent | 역할 |
|-------|-------|------|
| MVP | `pm` | 제품 의사결정, GDD/ADR/로드맵, feature spec 작성 |
| MVP | `game-designer` | 메커닉/밸런스/콘텐츠 설계 |
| MVP | `godot-dev` | Godot 4.x GDScript 구현 (godot-project/scripts/) |
| MVP | `backend-dev` | Firebase Functions + Firestore |
| MVP | `ui-designer` | 화면/플로우 스펙 |
| MVP | `qa-tester` | 테스트 케이스, 버그 리포트 |
| Post-MVP | `art-director` | 아트 스타일, 프롬프트, 에셋 |
| Post-MVP | `marketing` | ASO, 스토어 리스팅, 카피 |
| Post-MVP | `data-analyst` | KPI, A/B, 분석 이벤트 |

**위임 원칙**: 작업 성격이 명확한 agent에 해당하면 해당 agent를 호출. 모호하면 `pm`에 먼저 위임하여 spec 작성 후 분배. 자세한 위임 가이드는 `docs/agent-roster.md` 참조.
