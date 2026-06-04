# Phase 1 MVP — 스코프 선언

> **Phase 1 = 출시 가능한 최소 핵심.** 풀 v2 설계(시장 10·메뉴 41·12레벨·다인 등)는 `docs/phase2_archive/`에 보존, Phase 1은 그 부분집합만 빌드.
> 정체성·톤은 유지: **한식 문화 컬렉션 게임 / 글로벌 타깃 / Golden Spoon 브랜딩 / 자연어 손님 UI / 숫자 비노출**.

## Phase 1 한눈에
| 영역 | Phase 1 | Phase 2(archive) |
|---|---|---|
| 시장 | **2** (동네·노량진) | 가락동·경동·광장·남대문·전주·부산·안동·통인 |
| 메뉴 | **12** (L1~8, 해산물 포함) | 13~41 + DLC |
| 친구 | **5** (Mina·Junho·Riley·Mrs.Lee·Sora) | Park 부부·Daniel Kim·Sunny·Tae-min·Yuna·Hana·Do-yoon·Elena |
| 평가자 | **3** (Mystery Diner·Food Blogger·Golden Spoon Inspector) | Famous Vlogger·Celebrity Chef |
| 레벨 | **L1~8** (L8 = 엔딩 보스) | L9~12 |
| 난이도 | ±0.40 → ±0.10 | → ±0.05 |
| 재료 티어 | Basic + 특산품(2티어) | + 명품(3티어) |
| 도구 티어 | Basic + Pro(2티어) | + Master 풀 트리 |
| 그릇 티어 | Basic + Pro(2티어) | + Master 어워드 |
| 다인 디너 | **없음**(전부 단일 손님) | L8~12 전체 |
| 엔딩 보상 | Master 도구 1 + Master 그릇 1(상징물) | 풀 트로피 룸·"한식 명인" |
| DLC | 없음 | 전주·부산·궁중·길거리 |

## 유지 시스템 (Phase 1)
플레이어 5종 선택 · 리듬 코어 + 양념 게이지 UI + 자연어 손님 발화 · 5축 미각 벡터(백엔드) · 그릇 매칭 페이즈 · 재료/도구/그릇 2티어 · 횟수제 재료 소모 · 시장 평판 · 온보딩 R1~15 · 광고 보상(재료+1·그릇 리롤·손님 힌트·부활·출석) · 사운드 BPM-정렬 인제스트.

## Phase 2 예고 (L8 엔딩 컷씬)
L8 Golden Spoon Inspector 클리어 → 엔딩 컷씬 + **"Phase 2: 전국의 시장과 궁중요리, 그리고 디너 파티가 곧 열립니다 (Coming Soon)"** 예고. Master 도구·그릇 1종씩 = Phase 2로 이어지는 상징물.

## Phase 1 문서 세트 (docs/phase1/)
- `README.md`(본 문서) · `GDD-phase1.md` · `menu-roster-phase1.md` · `characters-phase1.md` · `markets-phase1.md` · `unlock-tree-phase1.md` · `image_prompts_phase1.md`
> 시스템 수식·스키마는 풀 문서(`scoring-v2`·`economy-balance-v1`·`schema-delta-v2` 등) 그대로 사용하되, **콘텐츠는 본 Phase 1 세트가 단일 출처**. 코드/데이터는 다음 sprint에서 Phase 1 기준으로 빌드.
