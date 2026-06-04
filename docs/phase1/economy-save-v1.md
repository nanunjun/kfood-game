# Economy & Save v1 — progression that sticks (M1+)

> 레벨업이 실제로 이어지게. `save_manager.gd`(autoload) = JSON 세이브 + 경제 + 레벨업. English-first(데이터). 연동: `levels-v1`(보상·시장), `round-system-v3`(라운드), `menu_select`(그리드).

## 1. 저장 시스템
- 위치: `user://kfood_save.json` (Godot 표준, Android internal storage). JSON `version:1`.
- 자동 저장: 돈 변동·재고 소비·라운드 기록·친밀도·설정 변경 시 write-through. (메뉴 그리드 진입 시 최신 로드.)
- 로드 시 기본값에 **얕은 머지**(`_merge`) → 업데이트로 새 필드 추가돼도 기존 세이브 호환. `version`으로 향후 마이그레이션.
- 손상 시 경고 후 새 세이브.

### 스키마 (v1)
```
version, level, money, clears_at_level,
reputation{home,noryangjin,gwangjang},
stock{menu_id:int},                      # 메뉴별 잔여 서빙
unlocks{markets:[...]},                   # 메뉴·손님은 level로 파생
stats{plays, passes, best_stars{menu_id:int}, total_stars},
intimacy{guest_id:float 0..5},
player_char, settings{haptics,volume,subtitle_kr}
```

## 2. 경제
- 시드 **₩50,000**(`SEED_MONEY`). 표기 영어 "₩50,000"(그리드 우상단).
- 라운드 통과 시 보상 = `Level.reward × (1.3 if S≥star4 else 1.0)` → `add_money`. (실패 0.)
- **재료=횟수제 소모(간이)**: 메뉴별 서빙 `stock`(시작 3). 라운드 진입 시 1 소비(`consume_stock`). 0이면 그리드에서 "Out of stock" + **Restock ₩2,000(+3)** 버튼(`restock`). → 디렉티브 "0이면 메뉴 잠금" 충족(메뉴별 재고 키 = menu_id, 별도 재료 카탈로그 불필요한 경량 모델).
- 도구·그릇 구매/어워드는 Phase 2(스키마 자리만; Phase 1 미노출).

## 3. 레벨업 트리거
- 통과 라운드마다 `clears_at_level++`, 시장 평판 +1. `CLEARS_REQ`={L1:4,L2:5,L3:5,L4:6,L5:6,L6:7,L7:8} 도달 시 레벨 ↑(총 ~41라운드 L1→L8, 디렉티브 30~50 부합).
- 레벨업 시: `level++`, 새 시장 unlock(`Level.market`), `level_up` 시그널 + `_pending_levelup` 세팅.
- 그리드 진입 시 `consume_levelup_notice()` → **토스트** "Level Up! ▲ Level 4 — Noryangjin market unlocked!"(영어, 2.6s 후 페이드).
- 새 메뉴·손님·시장은 `level` 기준 자동 파생(그리드가 `unlock_level ≤ level`만 개방, 초과는 회색 "(locked)").
- **L8 Golden Spoon 클리어 = Phase 1 엔딩 트리거**(엔딩 컷씬 연결은 후속; 현재 클리어 기록까지).

## 4. 코드 연동
- `rhythm_proto._ready`: `consume_stock(menu_id)`.
- `rhythm_proto._finish`: 통과 시 `add_money(reward)`; `record_round(menu_id, stars, passed, market)`; 비-evaluator면 `add_intimacy(guest_id, +1/0/−0.5)`.
- `menu_select`: `level()`·`money()`·`stock_of()` 읽어 표시, restock·levelup 토스트.
- 구버전 A2 API(`record_result/best_of/is_cleared/cleared_count/three_star_count/total_stars`) 보존 → 기존 스크립트 무수정 호환.

## 5. 검증 시나리오
- 새 세이브 → 라운드 통과 → 돈↑·stock↓·best_stars 기록 → 재시작 후 유지(JSON write-through).
- perfect 반복 → ~41라운드에 L8 도달(토스트·시장 해금 연쇄).
- stock 0 → 메뉴 "Out of stock", Restock로 복구(₩2,000 차감, 잔액 부족 시 무동작).
- preflight PASS + 코드 := 안전.

## A/B
- **[A/B] 시드머니**: A=50,000(디폴트) / B=30,000(긴장↑). 디폴트 A.
- **[A/B] 레벨업 기준**: A=클리어 수(디폴트, 명확) / B=시장 평판 합(탐험 유도). 디폴트 A.
- **[A/B] 재고 시작/리스톡**: A=3 / +3@₩2,000(디폴트) / B=5 / +5@₩3,000. 디폴트 A.
