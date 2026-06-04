# Build Plan — Phase 1 (스프린트 계획)

> Phase 1을 Godot 4.x로 빌드하는 작업 순서·마일스톤·체크리스트. 우선순위 = `production-priorities.md`(손맛·reveal·플레이팅 60%). 스키마 = `data-schema-phase1.md`. 손맛 = `rhythm-prototype-spec.md`.
> **환경 주의**: 이 작업 환경엔 Godot 바이너리 없음 → 빌드·실행은 사용자 머신. 본 저장소엔 `preflight_check.py`(정적 검사)로 깨짐 차단.

## 0. 마일스톤 개요
| M | 목표 | 산출 | 게이트 |
|---|---|---|---|
| **M0 손맛 프로토타입** (1주) | 1메뉴 라운드로 "손맛 좋다" 검증 | 라면/잔치국수 4페이즈 + 5중 피드백 + 게이지 | QA(`rhythm §12`) 5명 중 4명 ≥4점 |
| **M1 코어 시스템** | 라운드 일반화 + 점수 v2 + 그릇 매칭 + 경제·인벤토리 | 12메뉴 가동, 시장 2, 재료 횟수제 | 12메뉴 라운드 정상, preflight PASS |
| **M2 콘텐츠 wiring** | 캐릭터 15·레벨 L1~8·서사 컷씬·온보딩 | 손님 등장·자연어·해금 그래프 | L1→L8 통플레이 가능 |
| **M3 폴리시 패스** | reveal·플레이팅 연출·SFX layering·햅틱 | 메뉴별 reveal, 플레이팅 snap | 폴리시 3영역 체크리스트 통과 |
| **M4 출시 후보** | 광고 보상·세이브·정산·엔딩·빌드 | Android AAB + 데스크탑 | 크래시 0, 세이브 안정, 엔딩 |

## 1. M0 — 손맛 프로토타입 (최우선, 독립 슬라이스)
> 경제·해금·세이브 없이 **리듬 손맛만** 검증. `rhythm-prototype-spec` 그대로 구현.
작업 순서:
1. autoload `BeatClock`(오디오클럭, §13 스니펫)·`Tuning`(다이얼)·`HapticManager`·`FeedbackBus`.
2. `JudgmentZone` + `judge()` + `JudgmentWindow.tres`(레벨별 ms).
3. `NoteSpawner` + `NotePool`(32) + 등속 강하 + 서브픽셀 정렬.
4. `FeedbackBus`: 파티클풀·팝업풀·글로우·SFX버스 → 5중 동시 트리거.
5. `SeasoningGauge`(고춧가루·간장) + tap/hold 입력.
6. 4페이즈 압축(칼질→양념→끓이기→플레이팅 confirm).
7. DebugPanel(튜닝 다이얼) + metrics 로깅 + 캘리브레이션 UI.
8. Android·데스크탑 export 확인.
**DoD**: 60fps(최저≥55), 입력 trip ≤16ms, 5중 자극 전부 작동, 판정분포 정상, 정성 인터뷰 통과.

## 2. M1 — 코어 시스템
**[2026-06-03 진행] 데이터 주도 라운드 일반화 완료** — `round-system-v3.md` 참조. 라면 하드코딩 → `data/menus.csv`+`guests.csv` + `menu_db.gd` + 일반화된 `RhythmRound`. 12메뉴 메뉴 그리드(`menu_select`)에서 선택→완주. 양념·그릇 궁합 메뉴별 데이터. English-first. preflight 254 PASS + 12메뉴 perfect-play sanity PASS.
1. ✅ 데이터화(M1 채택안): .tres 대신 **CSV 마스터 + MenuDB 파서**(경량·런타임 편집·에디터 불필요). 추가 메뉴 = CSV 1줄.
2. ✅ 라운드 일반화: request→chop→boil→season(동적 슬롯)→plating(그릇 best/2nd/bad)→reveal(그릇별 형태)→채점(0.25/0.15/0.60+dishwareBonus).
3. ✅ 그릇 매칭 페이즈 + dishwareBonus(best+0.12/2nd+0.05/bad−0.08).
4. ⏳ 경제·인벤토리: 시드 5만, 횟수제 소모, 재구매, 시장 2 + 평판 2티어 — **다음 청크**.
5. ✅ 12메뉴 wiring(9 PNG 재사용 + 3 placeholder `ready=0`).
   ⏳ Level 차등(가중·θ·tol 레벨별 데이터화), 손님 선택 UI(L3+), 페이즈 변주(볶기/부치기/말기), 완성샷 3종 생성·ingest.
**DoD**: ✅ 임의 메뉴 라운드 완주 + preflight PASS. ⏳ 보상·재고는 경제 청크에서.

## 3. M2 — 콘텐츠 wiring
1. CharacterDefinition 15 인스턴스(친구5·평가자3·상인2·플레이어5) + 자연어 발화(scoring §0 매핑) + 표정 3종.
2. LevelDefinition L1~8 + 해금 그래프(`unlock-tree-phase1`) + 시장 개방(L4 노량진).
3. 플레이어 선택 화면(5종 캐러셀) + 오프닝 컷씬 3씬 + 레벨 서사 비트 컷씬.
4. 온보딩 R0~R15 게이팅(시스템 한 겹씩).
5. 평가자 등장(Mystery Diner L3 → Blogger L5 → Inspector L8 보스) + 엔딩 컷씬 + "Phase 2 Coming Soon".
**DoD**: 신규 세이브로 L1→L8 통플레이, 엔딩 도달.

## 4. M3 — 폴리시 패스 (production-priorities 3영역)
1. **음식 reveal**(메뉴 12 각): 김/윤기/글로우 입자 + 줌인·기울기 + 완성 sting 3등급(reveal 스펙 후속 문서 기준).
2. **플레이팅**: 그릇 캐러셀 스와이프+chime, 담기 애니, "+15% Match!" reward, garnish 1슬롯.
3. **손맛 마감**: SFX layering 패스(`sound-guide §0.5`) + 햅틱 + 판정 차등 최종 튜닝.
**DoD**: 폴리시 3영역 체크리스트 통과, reveal 스크린샷 "광고감".

## 5. M4 — 출시 후보
광고 보상(재료+1·그릇 리롤·손님 힌트·부활·출석) + Remove Ads IAP · 세이브 안정성 · 정산·결과 화면 · 엔딩 · 설정(햅틱/오프셋/볼륨) · Android AAB·데스크탑 빌드 · 스토어 메타(positioning 카피).
**DoD**: 크래시 0, 세이브 마이그레이션 안전, L1~8 + 엔딩 + Phase2 예고.

## 6. 의존성 순서 (요약)
```
M0(손맛, 독립) ─┐
                ├─▶ M1(시스템) ─▶ M2(콘텐츠) ─▶ M3(폴리시) ─▶ M4(출시)
스키마/임포터 ──┘            ▲ 아트 인제스트(병행: 프롬프트 생성→컷아웃→반영)
```
- **아트는 병행 트랙**: 친구5·평가자3·신규메뉴3·시장2 BG·UI를 `image_prompts_phase1`로 외부 생성 → `cutout_bg.py` → 반영. M2 전까지 들어오면 됨(placeholder로 선개발 가능).
- 사운드: CC0 인제스트 + 박자 정렬(`audio-pipeline-v1`) → M0/M3 손맛에 투입.

## 7. 리스크 레지스터
| 리스크 | 영향 | 완화 |
|---|---|---|
| 햅틱 세기 제어(Godot 기본 미흡) | 손맛 -1 | 플러그인/JNI 브리지 조기 spike, 미지원 fallback |
| 모바일 오디오 레이턴시 편차 | 판정 어긋남 | 캘리브레이션 UI 필수, audio_offset 저장 |
| 60fps 미달(파티클 다발) | 손맛 붕괴 | 풀링·GPUParticles·draw call 예산, 저사양 프리셋 |
| 아트 생성 지연 | M2 지연 | placeholder 우선 개발, 아트 후반 스왑(파일명 규칙) |
| 스코프 크리프 | 일정 | production-priorities 컷 순서 룰 적용 |

## 8. 즉시 착수 항목 (이번 sprint 시작점)
1. M0 autoload 4종 + JudgmentZone + 노트풀 스캐폴드.
2. 스키마 스크립트 필드 추가(FoodDefinition + 신규 리소스) — 병행.
3. CC0 SFX 박자 정렬 1차(칼질·양념·끓음·플레이팅·완성 sting).
> 본 계획 + `rhythm-prototype-spec` + `data-schema-phase1`만으로 M0 착수 가능. M0 통과(손맛 검증) 후 M1로.
