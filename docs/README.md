# docs/

게임 기획 및 설계 문서 보관소.

## 용도
- **GDD (Game Design Document)**: 핵심 루프, cooking matching 시스템, 진행 곡선
- **시스템 설계**: 저장(Save), 광고/IAP 정책, 분석(Analytics) 이벤트 정의
- **아트/사운드 가이드**: 컬러 팔레트, UI 톤앤매너, 한식 일러스트 스타일 가이드
- **밸런스 시트**: 아이템 가격, 보상 곡선, 재화 흐름 (CSV / Excel)
- **회의/결정 기록**: ADR (Architecture Decision Record) 형식 권장

## 권장 파일 구조
```
docs/
├── gdd.md                  ← 핵심 기획서
├── systems/                ← 개별 시스템 상세
│   ├── cooking-mechanics.md
│   ├── monetization.md
│   └── progression.md
├── art/                    ← 비주얼 가이드
├── balance/                ← 수치 밸런싱 (csv/xlsx)
└── decisions/              ← ADR
```

## 규칙
- Markdown 우선, 다이어그램 필요 시 Mermaid 사용
- 외부 이미지는 `docs/images/`에 두고 상대경로 참조
