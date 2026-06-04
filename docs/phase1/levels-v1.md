# Levels v1 — 8레벨 데이터 명세 + 튜닝 곡선 + Evaluator (M1+)

> 점수 가중·판정 윈도우·θ_pass·tol·별점·보상을 **`data/levels.csv`로 외부화**(디자이너 튜닝). 코드(`rhythm_proto.gd`)는 메뉴의 unlock_level로 Level을 로드해 자동 적용.
> 난이도 철학: **초반 관대 → 후반 미쉐린(Golden Spoon)급 엄격**. 연동: `recipes-balance-phase1`(원 수치), `phase-variations-v1`(가중 버킷), `worldbuilding-v1`(서사 비트).

## 1. Level 데이터 필드 (`data/levels.csv`)
`level, perfect_ms, good_ms, tol, w_prep, w_cook, w_season, w_dish, theta, star2, star3, star4, star5, reward, market, evaluator`
- **perfect_ms / good_ms**: 리듬 판정 반폭(half-window). Tuning 스케일과 곱해 적용.
- **tol**: 양념 편차 허용(작을수록 정밀).
- **w_prep / w_cook / w_season**: 점수 카테고리 가중(prep=손질·말기·비비기 / cook=끓이기·볶기·부치기 / season=간). 존재하는 카테고리만 정규화 합산.
- **w_dish**: 그릇 보너스 크기(best=+w / 2nd=+0.42w / bad=−0.67w).
- **theta**: 통과선. **star2~5**: 별점 임계. **reward**: 통과 시 코인(우수=star4↑면 ×1.3).
- **market**: 해금 시장(home/noryangjin/gwangjang). **evaluator**: 등장 평가자 id(빈칸=일반 손님).

## 2. 튜닝 곡선 (L1 → L8)
| L | perfect/good ms | tol | w_prep/cook/season | w_dish | θ | ★5 | reward | market | evaluator |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 90 / 200 | 0.40 | 0.30/0.20/0.50 | 0.12 | 0.55 | 0.92 | 6,000 | home | — |
| 2 | 80 / 180 | 0.36 | 0.30/0.20/0.50 | 0.12 | 0.60 | 0.93 | 8,000 | home | — |
| 3 | 72 / 160 | 0.32 | 0.28/0.22/0.50 | 0.13 | 0.64 | 0.93 | 10,000 | home | **Mystery Diner** |
| 4 | 64 / 140 | 0.27 | 0.28/0.24/0.48 | 0.13 | 0.68 | 0.94 | 13,000 | noryangjin | — |
| 5 | 56 / 120 | 0.22 | 0.27/0.25/0.48 | 0.14 | 0.72 | 0.94 | 15,000 | noryangjin | **Daniel Kim** |
| 6 | 48 / 104 | 0.18 | 0.27/0.26/0.47 | 0.15 | 0.76 | 0.95 | 18,000 | noryangjin | — |
| 7 | 42 / 92 | 0.14 | 0.26/0.27/0.47 | 0.16 | 0.82 | 0.96 | 21,000 | noryangjin | — |
| 8 | 36 / 80 | 0.10 | 0.25/0.28/0.47 | 0.18 | 0.88 | 0.97 | 24,000 | gwangjang | **Golden Spoon** |
> 윈도우·tol는 단조 축소(엄격), θ·별점·w_dish는 상승(정밀·그릇 비중↑), reward 상승. 검증: 전 레벨 perfect play S=1.00 ≥ θ. 중급(0.75 acc + 2nd 그릇)은 L1~6 통과·L7~8 탈락 → 의도된 "후반 마스터리 요구".

## 3. 적용 (코드)
- 라운드 `level = menu.unlock_level` → `MenuDB.get_level(level)`.
- 판정: `_windows() = [perfect_ms·scale, good_ms·scale]`.
- 양념: `_seasoning_score()`가 `tol` 사용.
- 최종: `base = Σ(w_cat·avg_acc_cat) / Σ(w_cat)` (존재 카테고리만), `S = clamp(base + dish_bonus(w_dish), 0, 1)`.
- 별: star5/4/3/2 임계. 통과: `S ≥ θ`. 보상: 통과 시 reward(우수 ×1.3) — 결과 화면에 "Earned N coins".

## 4. 메뉴 그리드 표시 (`menu_select.gd`)
- 상단: "Level N · {market} market".
- 카드: 좌상단 레벨 배지 "L3", 잠금 메뉴(레벨 초과)는 회색 + "(locked)" + disabled.
- 평가자 레벨 카드엔 "★ {Evaluator name}" 표기(보라). Phase 1은 current_level=8(전 메뉴 개방).

## 5. Evaluator 등장 흐름 (Phase 1 단순화)
| 트리거 | 평가자 | 톤 | 효과 |
|---|---|---|---|
| L3 | **Mystery Diner** | 정체 모름, 침묵, 별점만 | request에 보라 얼굴 + "A quiet guest watches…", 결과 대사 최소 |
| L5 | **Daniel Kim** (Local Food Blogger) | SNS 리뷰어 | "smile for the photo!", 통과 시 "Posting this — looks amazing!" |
| L8 | **Golden Spoon Inspector** | 보스, 엄격, Phase 1 엔딩 트리거 | "observes in silence", tol 0.16(최고 정밀) |
> **현재 구현**: 해당 레벨의 메뉴는 일반 손님 대신 평가자가 등장(라운드 `_is_evaluator`). 배너 "Level N · {Evaluator} is watching". 미각 벡터는 평가자값 사용.
> **후속(Phase 2)**: "레벨 첫 라운드에만" 등장 + 풀 컷씬 + SNS 한 컷 + 보스 연출. 현재는 데모용으로 그 레벨 메뉴에 상시 등장.

## 6. Level 전환 (Phase 1 = 경량)
- 현재: 라운드 결과로 별·보상 계산·표시. **누적 평판/돈 → 레벨업**은 경제·세이브 청크에서 연결(미구현).
- 레벨업 연출: 짧은 영어 토스트 + 잠금해제 알림(Phase 1) → Phase 2 풀 컷씬(`worldbuilding-v1` 12비트).

## 7. 확장 (튜닝)
`levels.csv` 한 셀만 바꾸면 즉시 반영(코드 수정 X). 예: L7 너무 어려우면 `good_ms` ↑ 또는 `theta` ↓. 신규 레벨은 행 추가(get_level은 범위 밖 clamp).

## A/B
- **[A/B] w_dish 곡선**: A=0.12→0.18(디폴트) / B=고정 0.12. 디폴트 A(후반 그릇 중요도↑).
- **[A/B] evaluator 등장 빈도**: A=그 레벨 메뉴 상시(디폴트, 데모) / B=레벨 첫 라운드만(Phase 2). 디폴트 A.
- **[A/B] reward ×우수 배수**: A=1.3(디폴트) / B=1.5. 디폴트 A.
