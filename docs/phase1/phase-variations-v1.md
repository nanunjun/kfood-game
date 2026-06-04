# Phase Variations v1 — 페이즈 4종 + 메뉴 매핑 (M1+)

> 손맛 차별화. 12메뉴가 "칼질·끓이기·양념"으로 똑같던 것을 **음식별 조리 동작**으로 다양화.
> 페이즈 시퀀스는 `data/menus.csv`의 `phases` 컬럼(`chop|stirfry|season` 형식)에서 로드. English-first.
> 구현: `rhythm_proto.gd`(phase-queue state machine). 연동: `round-system-v3.md`, `levels-v1.md`.

## 1. 페이즈 7종 (기존 3 + 신규 4)
| 토큰 | 이름(UI) | 카테고리 | 입력 | 채점 |
|---|---|---|---|---|
| `chop` | Chop | prep | 비트에 맞춰 탭 ×N(낙하 노트) | 평균 판정(P/G/M) |
| `boil` | Boil | cook | 길게 홀드(끓이는 시간) | hold_score(목표 1.2s) |
| `season` | Season | season | 양념 버튼 탭(5초) | 손님 미각 대비 편차 |
| `stirfry` | Stir-fry | cook | **좌/우 탭**(화살표 방향 따라, ×8) | 방향 일치 + 타이밍 |
| `panfry` | Pan-fry | cook | **FLIP 타이밍 탭**(진행바 + 뒤집기 2회) | 뒤집기 근접도 평균 |
| `roll` | Roll | prep | **길게 홀드**(말기, 목표 1.5s) | hold_score |
| `knead` | Mix | prep | **빠른 연타**(3초, 목표 12탭) | min(1, taps/target) |

> 카테고리 = 점수 버킷. **prep**(손질·말기·비비기) / **cook**(끓이기·볶기·부치기) / **season**(간). 같은 버킷 내 여러 페이즈는 평균. 채점 가중은 `levels-v1`의 w_prep/w_cook/w_season.

## 2. 메뉴별 페이즈 시퀀스 (Phase 1)
| 메뉴 | phases |
|---|---|
| Ramyeon | chop · boil · season |
| Gimbap | chop · **roll** |
| Tteokbokki | chop · **stirfry** · season |
| Janchi Guksu | chop · boil |
| Kimchi Stew | chop · boil · season |
| Bibimbap | chop · boil · **knead**(비비기) |
| Doenjang Stew | chop · boil · season |
| Japchae | chop · boil · **stirfry** · season |
| Bulgogi | chop · **stirfry** |
| Haemul Pajeon | chop · **panfry** |
| Spicy Fish Stew | chop · boil · season |
| Sundubu Jjigae | chop · boil · season |
> 플레이팅·reveal은 모든 메뉴 공통 말미. 시퀀스에 season 없는 메뉴(Gimbap·Janchi·Bibimbap·Bulgogi)는 prep/cook/그릇으로 채점(미각 손님 영향 ↓).

## 3. 입력 메커닉 상세
- **Stir-fry**: 좌/우에서 화살표 노트가 중앙선으로 슬라이드. 화면 좌(<540)/우(≥540) 탭이 노트 방향과 일치하고 good 윈도우 안이면 판정. 방향 틀리면 무시(미탭). 8노트, 간격 520ms.
- **Pan-fry**: 진행바가 4.5초에 걸쳐 자동 충전(전 색 raw→golden lerp). 1.5s·3.0s에 "★ FLIP NOW! ★" 윈도우(±340ms) 오픈 → 탭 근접도가 점수. 놓치면 0.
- **Roll**: 누르고 있으면 김밥 말기 진행바가 참(목표 1.5s, tol 0.35). 끝에서 떼면 hold_score. 너무 길거나 짧으면 감점.
- **Mix(Knead)**: 3초 동안 연타. 탭마다 그릇 회전 + 살짝 스케일 펄스. 목표 12탭 도달 시 만점.

## 4. 5중 자극(손맛 폴리시) — 페이즈 공통
모든 비트/판정은 `FeedbackBus.hit(result, pos)`로 라우팅 → **팝업 라벨 + 화면 플래시 + SFX + 햅틱 + (풀 노트)** 일괄. 신규 페이즈도 동일 경로 사용해 폴리시 균질.
- Stir-fry: 좌우 탭마다 hit. / Pan-fry: 뒤집기 성공 hit(P/G), 놓침 hit(M). / Roll: 릴리스 1회 hit. / Mix: 탭마다 hit(GOOD) + 그릇 회전.

## 5. 시각 모션 (현재 프로토타입 = 도형, 아트 스왑 대기)
| 페이즈 | 현재(프로토) | 목표 아트(production-priorities) |
|---|---|---|
| Stir-fry | 웍(타원) + 재료 조각, 중앙선 | 팬 회전 + 김 폴리시, 주걱 |
| Pan-fry | 팬 + 전(raw→golden 색변화) | 노릇 그라데이션 + 기름 튀김 파티클 |
| Roll | 김 매트 + 진행바 | 김 위 재료 구르는 모션 |
| Mix | 그릇 + 5색 재료 회전 | 비비는 회전 + 색 섞임 |
> 도형 단계로도 플레이 완결. 아트는 파일명 규칙으로 후반 스왑(프로덕션 우선순위 위반 X — 손맛·사운드는 이미 풀).

## 6. SFX 매핑 (CC0 인제스트 큐)
| 페이즈 | 사운드 컨셉 | 현재 키(재사용) |
|---|---|---|
| Stir-fry | "치이익~ 쓱쓱~"(기름·주걱) | `ui_select`/`judge_*` via FeedbackBus |
| Pan-fry | "지글지글" + 뒤집기 "쉬익" | `judge_good`/`judge_perfect` |
| Roll | 부드러운 "쓰윽~" | `ui_select` |
| Mix | "휘이익~ 휘이익~" | `ui_select` |
> 전용 루프(sizzle 등)는 CC0 인제스트(`ingest_sfx.py`) 후 키 추가 — 미존재 키 호출 회피 위해 현재는 기존 키 재사용.

## 7. 확장 (메뉴에 페이즈 추가)
`menus.csv`의 `phases`만 편집(`chop|boil|stirfry|season`). 토큰은 §1의 7종. 미지원 토큰은 라운드에서 skip(안전). 새 페이즈 타입 추가 시 `rhythm_proto.gd`의 `_next_phase` match + `PHASE_NAMES`/`PHASE_CAT` + `_start_*` 함수.

## A/B
- **[A/B] Stir-fry 노트 수**: A=8(디폴트) / B=레벨 비례 8~16. 디폴트 A(후속 레벨 스케일).
- **[A/B] Pan-fry 뒤집기 횟수**: A=2(디폴트) / B=3(L6+). 디폴트 A.
- **[A/B] season 없는 메뉴 미각 반영**: A=prep/cook만(디폴트) / B=소폭 반영. 디폴트 A.
