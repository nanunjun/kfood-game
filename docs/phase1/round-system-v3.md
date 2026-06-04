# Round System v3 — Data-Driven Round (M1)

> (c) 코드 일반화 산출. 라면 하드코딩 라운드(`rhythm_proto.gd`)를 **12메뉴 데이터 주도** 라운드로 리팩터.
> 데이터 소스: `recipes-balance-phase1.md`(양념·그릇·튜닝). 언어: **English-first**, 한국어는 문화적 부제(`name_kr`)로만.
> 연동: `menu-roster-phase1.md`(12메뉴), `characters-phase1.md`(손님), `build-plan-phase1.md`(M1·M2).

## 1. 한 줄
F5 → 메뉴 그리드 → 메뉴 선택 → `request → chop → boil → season → plating → reveal → result` → 메뉴 복귀.
메뉴별 양념·그릇 궁합·손님·완성샷이 **CSV에서 로드**된다. CSV 한 줄 추가 = 메뉴 추가.

## 2. 데이터 의존 트리
```
data/menus.csv ─┐
                ├─▶ MenuDB (parser, no class_name; preload)
data/guests.csv ┘        │
                         ├─▶ menu_select.gd  (그리드: unlocked(level) 카드)
                         └─▶ rhythm_proto.gd (RhythmRound: 라운드 실행)
                                  │
   SeasoningGauge.COLORS/display_name ──┘ (양념 색·영어 표기)
   RhythmJudge.windows/judge/hold_score ─┘ (판정)
   autoload: BeatClock / Tuning / FeedbackBus / HapticManager / AudioManager
```

## 3. 데이터 스키마 (CSV)
### `data/menus.csv` (12행)
`menu_id, name_en, name_kr, intro_en, seasonings, dish_best, dish_2nd, dish_bad, guest_id, unlock_level, food_img, ready`
- `seasonings` = `id:axis:umax` 를 `|` 로 구분. axis ∈ {sweet,salty,spicy,sour,umami}. 예: `soup:salty:5|gochugaru:spicy:5`.
- `dish_*` = vessel id (아래 §5). `ready` = 완성샷 PNG 존재 여부(0이면 placeholder).
- `intro_en` = 첫 등장 설명 ("Korean instant noodle soup") — 영어 정책의 "romanized + 설명".
### `data/guests.csv` (5명, 평가자는 Phase 1 후속)
`guest_id, name, vec, tol, line_enter, line_ok, line_bad, role`
- `vec` = `sweet|salty|spicy|sour|umami` 5축 0~1. `tol` 작을수록 정밀 요구(레벨↑에서 작은 손님 배치).
- 대사 3종(enter/ok/bad)은 **영어**. 캐릭터별 톤(Junho 직설·Mrs. Lee 따뜻·Riley 외국인 친구).

## 4. 라운드 흐름 (rhythm_proto.gd = `RhythmRound`)
- `static var pending_menu_id` — `menu_select`가 씬 전환 전에 설정.
- `_ready`: `MenuDB.get_menu(id)` + `get_guest` 로드 → `_slots`(양념) / `_dish_options`(best·2nd·bad **셔플**) 구성. `ready==0`이면 "Final art coming soon" 토스트.
- **request**: 손님 얼굴 + `"line_enter"` + "Let's make {Menu} ({intro})".
- **chop**: 비트 탭 ×N (RhythmJudge 윈도우, 레벨별).
- **boil**: Hold 게이지(목표 ~1.2s, hold_score).
- **season**: `_slots` 마다 버튼 동적 생성("Gochugaru +" 등, 색=SeasoningGauge.COLORS). 5초 카운트다운. 힌트 = 손님 dominant axis 자연어("Tip: Junho loves a spicy kick.").
- **plating**: `_dish_options` 3개 버튼("Aluminum Pot (양은냄비)").
- **reveal**: 선택 그릇에 음식이 담긴 모습(`_build_vessel`) + radial 글로우(궁합 tier별 세기) + 배지("perfect match for Ramyeon! ▲▲" / "a decent pairing ▲" / "not quite right ▼").
- **result**: `S = clamp(0.25·chop + 0.15·hold + 0.60·season + dish_bonus, 0, 1)`. 별 + 손님 대사(점수별 ok/중립/bad) + off-axis 힌트("a bit too much spice"). 탭 → 메뉴 그리드.

## 5. 그릇(Vessel) 시스템 — `MenuDB.VESSELS`
| id | EN | KR(부제) | kind | reveal 형태 |
|---|---|---|---|---|
| pot_metal | Aluminum Pot | 양은냄비 | metal | 깊은 그릇 + 양옆 손잡이 |
| bowl_ceramic | Porcelain Bowl | 사기 대접 | ceramic | 깊은 그릇 |
| pot_stone | Stone Pot | 돌솥 | stone | 깊은 그릇(어두운 돌) |
| pot_clay | Earthenware | 뚝배기 | clay | 깊은 그릇(흙갈색) |
| bowl_glass | Glass Bowl | 유리 그릇 | glass | 반투명(α 0.85) |
| bowl_brass | Brassware | 유기 | brass | 깊은 그릇(놋쇠 금) |
| board_wood | Wooden Tray | 나무 소반 | wood | 얕고 넓음 |
| plate_wide | Wide Plate | 넓은 접시 | plate | 얕고 넓음 |
- 궁합 보너스: best +0.12 / 2nd +0.05 / bad −0.08 / 중립 0 (`MenuDB.dish_bonus`).
- 음식: `ready==1`이면 `food_img` PNG를 그릇 위에 배치, 아니면 stylized food mound(placeholder).

## 6. 채점 일반화
- 양념: 슬롯마다 `optimal = round(guest.vec[axis] * umax)`, `err = |applied-optimal|/umax`, `slot = clamp(1-(err/tol)², 0,1)`. 평균.
- 가중 0.25/0.15/0.60 + 그릇 보너스 (현재 코드 상수; Level별 차등은 후속 — recipes-balance §b θ_pass·tol 표 참조).
- 별: ≥0.92★5 / 0.80★4 / 0.68★3 / 0.55★2 / else ★1.
- **검증(`tools` 시뮬)**: 12메뉴 전부 perfect play S=1.00 ≥ θ_pass(해당 레벨) → 깨지는 메뉴 없음.

## 7. 메뉴 추가법 (sanity)
1. `data/menus.csv`에 한 줄 추가(양념·그릇·guest·unlock_level·food_img·ready).
2. 새 양념 id면 `seasoning_gauge.gd`의 `COLORS`+`NAMES`에 색·영어명 추가.
3. 새 그릇이면 `menu_db.gd`의 `VESSELS`에 추가.
4. 완성샷 PNG 넣고 `ready=1`. 없으면 `ready=0`(placeholder로도 플레이 가능).
→ 재시작하면 그리드에 카드가 자동 등장.

## 8. 미완성 자산 정책 (placeholder)
- 완성샷 없는 3종(`m_kimchi_jjigae`·`m_doenjang_jjigae`·`m_maeuntang`) = `ready=0`. food mound + "Final art coming soon" 토스트. **플레이는 정상**.
- 손맛(rhythm 피드백)·사운드는 placeholder 없이 풀 적용(프로덕션 우선순위 위반 X).

## 9. 남은 작업 (다음 청크)
- Level.tres/levels.csv로 가중·θ·tol **레벨 차등** 데이터화(현재 코드 상수).
- 손님 선택 UI(L3+) + 등장 모션 강화 + 표정 아트.
- 메뉴별 조리 페이즈 변주(볶기/부치기/말기 — 현재 chop+boil 공통).
- 완성샷 3종 생성 → ingest → `ready=1`.
- 평가자 3종(Golden Spoon) 데이터 추가.

## A/B
- **[A/B] vessel 표시 순서**: A=셔플(디폴트, 위치 단서 제거) / B=고정. 디폴트 A.
- **[A/B] placeholder 토스트**: A=상시 표시(디폴트) / B=첫 1회만. 디폴트 A.
